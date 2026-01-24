--// Services
local DSS = game:GetService("DataStoreService")
-- Retrieve the ordered DataStore that tracks all players' time spent (sorted highest to lowest)
local DataStore = DSS:GetOrderedDataStore("TimeSpentBoard1")

print("[LEADERBOARD] Time Played leaderboard server script started")

--// Functions
-- Formats seconds into a readable time format for display
-- Examples: 45 -> "45s", 90 -> "1m 30s", 3661 -> "1h 1m"
local function formatTime(seconds)
	if seconds < 60 then
		return seconds .. "s"
	elseif seconds < 3600 then
		local minutes = math.floor(seconds / 60)
		local remainingSeconds = seconds % 60
		if remainingSeconds > 0 then
			return minutes .. "m " .. remainingSeconds .. "s"
		else
			return minutes .. "m"
		end
	else
		local hours = math.floor(seconds / 3600)
		local remainingMinutes = math.floor((seconds % 3600) / 60)
		if remainingMinutes > 0 then
			return hours .. "h " .. remainingMinutes .. "m"
		else
			return hours .. "h"
		end
	end
end

--// Variables
-- The countdown timer text label that shows "Updating board in X seconds"
local counter = workspace.TimeSpentLeaderboard.UpdateBoardTimer.Timer:WaitForChild("TextLabel")
-- The SurfaceGui that displays the leaderboard on a part
local UI = workspace.TimeSpentLeaderboard.ScoreBlock:WaitForChild("SurfaceGui")
-- The template frame to clone for each player in the leaderboard
local basePlayerFrame = UI:WaitForChild("BasePlayerFrame")
-- The ScrollingFrame that contains all the player entries
local boardFrame = UI:WaitForChild("ScrollingFrame")

--// Functions
-- Saves all currently online players' time spent data to the DataStore
-- This ensures the leaderboard rankings stay up-to-date with current session data
local function SaveData()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		local plr_key = "id_"..player.UserId.."_Time Played"

		-- Get the raw time spent value (stored on player)
		local timeSpent = player:FindFirstChild("Time Played")

		local success, result = pcall(function()
			if timeSpent then
				DataStore:SetAsync(plr_key, timeSpent.Value)
			end
		end)

		if not success then 
			warn(result)
		end
	end
end

-- Fetches the top 50 players by time spent from the DataStore
-- Returns a table with player info: { Player = name, TimeSpent = seconds, Rank = position }
local function getTop50Players()
	local isAscending = false  -- false = highest time first
	local pageSize = 50
	-- Get sorted data from DataStore (automatically sorted by value, highest first)
	local pages = DataStore:GetSortedAsync(isAscending, pageSize)
	local top50 = pages:GetCurrentPage()

	local top = {}

	for rank, data in ipairs(top50) do
		local dataName = data.key  -- Key format: "id_{userid}_Time Played"
		local userId = tonumber(dataName:split('_')[2])
		local timeSpent = data.value
		
		-- Get the player's username by their UserId (works even if they're offline)
		local name = "Unknown"
		local success, nameResult = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId)
		end)
		
		if success and nameResult then
			name = nameResult
		else
			print("[LEADERBOARD] Failed to get name for userId: " .. tostring(userId))
		end

		-- Create player entry with rank, name, and time spent
		local currentPlayer =  { Player = name, TimeSpent = timeSpent, Rank = rank, }
		table.insert(top, rank, currentPlayer)
	end

	return top
end

-- Clears all player entry frames from the leaderboard (for updating)
local function ClearList()
	task.spawn(function()	
		for _, plrFrame in pairs(boardFrame:GetChildren()) do
			if not plrFrame:IsA("Frame") then continue end
			plrFrame:Destroy()
			task.wait(0.25)  -- Small delay for visual effect
		end
	end)
end

-- Main update function: saves data, clears old leaderboard, and displays top 50 players
local function UpdateList()
	SaveData()
	ClearList()
	local top50 = getTop50Players()
	
	task.spawn(function()	
		-- Populate leaderboard with top 50 players
		for _, plr in ipairs(top50) do
			local frame = basePlayerFrame:Clone()
			frame.Parent = boardFrame
			
			-- Set the player name, formatted time, and rank
			frame.Plr.Text = tostring(plr.Player)
			frame.Amount.Text = formatTime(plr.TimeSpent)
			frame.Rank.Text = tostring(plr.Rank)
			
			frame.Visible = true
			task.wait(0.25)  -- Small delay for visual effect
		end
	end)
end

--// Main Loop: Update the leaderboard every 60 seconds
task.spawn(function()
	while true do
		UpdateList()
		-- Countdown timer: shows how long until next update
		for count=60,0,-1 do
			counter.Text = "Updating board in "..count.." seconds"
            task.wait(1)
		end
	end
end)