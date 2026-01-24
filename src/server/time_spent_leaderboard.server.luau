--// Services
local DSS = game:GetService("DataStoreService")
local DataStore = DSS:GetOrderedDataStore("TimeSpentBoard1")

print("[LEADERBOARD] Time Played leaderboard server script started")

--// Functions
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
local counter = workspace.TimeSpentLeaderboard.UpdateBoardTimer.Timer:WaitForChild("TextLabel")
local UI = workspace.TimeSpentLeaderboard.ScoreBlock:WaitForChild("SurfaceGui")
local basePlayerFrame = UI:WaitForChild("BasePlayerFrame")
local boardFrame = UI:WaitForChild("ScrollingFrame")

--// Functions
local function SaveData()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		local plr_key = "id_"..player.UserId.."_Time Played"

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

local function getTop50Players()
	local isAscending = false
	local pageSize = 50
	local pages = DataStore:GetSortedAsync(isAscending, pageSize)
	local top50 = pages:GetCurrentPage()

	local top = {}

	for rank, data in ipairs(top50) do
		local dataName = data.key
		local userId = tonumber(dataName:split('_')[2])
		local timeSpent = data.value
		
		-- Get name with error handling
		local name = "Unknown"
		local success, nameResult = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId)
		end)
		
		if success and nameResult then
			name = nameResult
		else
			print("[LEADERBOARD] Failed to get name for userId: " .. tostring(userId))
		end

		local currentPlayer =  { Player = name, TimeSpent = timeSpent, Rank = rank, }
		table.insert(top, rank, currentPlayer)
	end

	return top
end

local function ClearList()
	task.spawn(function()	
		for _, plrFrame in pairs(boardFrame:GetChildren()) do
			if not plrFrame:IsA("Frame") then continue end
			plrFrame:Destroy()
			task.wait(0.25)
		end
	end)
end

local function UpdateList()
	SaveData()
	ClearList()
	local top50 = getTop50Players()
	
	task.spawn(function()	
		for _, plr in ipairs(top50) do
			local frame = basePlayerFrame:Clone()
			frame.Parent = boardFrame
			
			frame.Plr.Text = tostring(plr.Player)
			frame.Amount.Text = formatTime(plr.TimeSpent)
			frame.Rank.Text = tostring(plr.Rank)
			
			frame.Visible = true
			task.wait(0.25)
		end
	end)
end

task.spawn(function()
	while true do
		UpdateList()
		for count=60,0,-1 do
			counter.Text = "Updating board in "..count.." seconds"
            task.wait(1)
		end
	end
end)