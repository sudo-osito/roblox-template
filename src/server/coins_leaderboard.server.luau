--// Services
local DSS = game:GetService("DataStoreService")
-- Retrieve the ordered DataStore that tracks all players' coins (sorted highest to lowest)
local DataStore = DSS:GetOrderedDataStore("CoinsBoard1")

print("[LEADERBOARD] Coins leaderboard server script started")

--// Functions
-- Formats large coin amounts into readable abbreviations
-- Examples: 1500 -> "1.5k", 2000000 -> "2.0m", 5000000000 -> "5.0b"
local function formatCoins(coins)
	local suffixes = { "k", "m", "b", "t", "q" }
	local divisor = 1000
	
	if coins < 1000 then
		return tostring(coins)
	end
	
	for i, suffix in ipairs(suffixes) do
		if coins < divisor ^ (i + 1) then
			local value = coins / (divisor ^ i)
			return string.format("%.1f", value) .. suffix
		end
	end
	
	-- If larger than quadrillions, still show in quadrillions
	local value = coins / (divisor ^ #suffixes)
	return string.format("%.1f", value) .. suffixes[#suffixes]
end

--// Variables
-- The countdown timer text label that shows "Updating board in X seconds"
local counter = workspace.DollarLeaderboard.UpdateBoardTimer.Timer:WaitForChild("TextLabel")
-- The SurfaceGui that displays the leaderboard on a part
local UI = workspace.DollarLeaderboard.ScoreBlock:WaitForChild("SurfaceGui")
-- The template frame to clone for each player in the leaderboard
local basePlayerFrame = UI:WaitForChild("BasePlayerFrame")
-- The ScrollingFrame that contains all the player entries
local boardFrame = UI:WaitForChild("ScrollingFrame")

--// Functions
-- Saves all currently online players' coin data to the DataStore
-- This ensures the leaderboard rankings stay up-to-date with current session data
local function SaveData()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		local plr_key = "id_"..player.UserId.."_Coins"

		-- Get the raw coins value (stored on player, not in leaderstats)
		local coins = player:FindFirstChild("Coins")

		local success, result = pcall(function()
			if coins then
				DataStore:SetAsync(plr_key, coins.Value)
			end
		end)

		if not success then 
			warn(result)
		end
	end
end

-- Fetches the top 50 players by coins from the DataStore
-- Returns a table with player info: { Player = name, Coins = amount, Rank = position }
local function getTop50Players()
	local isAscending = false  -- false = highest coins first
	local pageSize = 50
	-- Get sorted data from DataStore (automatically sorted by value, highest first)
	local pages = DataStore:GetSortedAsync(isAscending, pageSize)
	local top50 = pages:GetCurrentPage()

	local top = {}

	for rank, data in ipairs(top50) do
		local dataName = data.key  -- Key format: "id_{userid}_Coins"
		local userId = tonumber(dataName:split('_')[2])
		local coins = data.value
		
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

		-- Create player entry with rank, name, and coins
		local currentPlayer =  { Player = name, Coins = coins, Rank = rank, }
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
			
			-- Set the player name, formatted coins, and rank
			frame.Plr.Text = tostring(plr.Player)
			frame.Amount.Text = formatCoins(plr.Coins)
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


