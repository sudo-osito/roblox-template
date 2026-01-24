--// Services
local DSS = game:GetService("DataStoreService")
local DataStore = DSS:GetOrderedDataStore("CoinsBoard1")

print("[LEADERBOARD] Coins leaderboard server script started")
--// Variables
local counter = workspace.DollarLeaderboard.UpdateBoardTimer.Timer:WaitForChild("TextLabel")
local UI = workspace.DollarLeaderboard.ScoreBlock:WaitForChild("SurfaceGui")
local basePlayerFrame = UI:WaitForChild("BasePlayerFrame")
local boardFrame = UI:WaitForChild("ScrollingFrame")

--// Functions
local function SaveData()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		local plr_key = "id_"..player.UserId.."_Coins"

		local coins = player.leaderstats.Coins

		local success, result = pcall(function()
			DataStore:SetAsync(plr_key, coins.Value)
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
		local coins = data.value
		
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

		local currentPlayer =  { Player = name, Coins = coins, Rank = rank, }
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
			frame.Amount.Text = tostring(plr.Coins)
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


