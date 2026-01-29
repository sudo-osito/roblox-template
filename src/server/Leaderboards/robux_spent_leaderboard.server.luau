--// Services
local DSS = game:GetService("DataStoreService")
local LeaderboardAnimationManager = require(game.ReplicatedStorage.Shared.LeaderboardAnimationManager)
-- Retrieve the ordered DataStore that tracks all players' robux spent (sorted highest to lowest)
local DataStore = DSS:GetOrderedDataStore("RobuxSpentBoard2")

--// Functions
-- Formats numbers with comma separators (e.g., 1000000 -> "1,000,000")
local function formatWithCommas(number)
	local formatted = tostring(number)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

--// Variables
-- The countdown timer text label that shows "Updating board in X seconds"
local counter = workspace.RobuxSpentLeaderboard.UpdateBoardTimer.Timer:WaitForChild("TextLabel")
-- The SurfaceGui that displays the leaderboard on a part
local UI = workspace.RobuxSpentLeaderboard.ScoreBlock:WaitForChild("SurfaceGui")
-- The template frame to clone for each player in the leaderboard
local basePlayerFrame = UI:WaitForChild("BasePlayerFrame")
-- The ScrollingFrame that contains all the player entries
local boardFrame = UI:WaitForChild("ScrollingFrame")

--// Functions
-- Fetches the top 50 players by robux spent from the cached DataStore manager
-- Returns a table with player info: { Player = name, RobuxSpent = amount, Rank = position }
local function getTop50Players()
	-- Wait for DataStore manager to initialize if needed
	local maxWait = 0
	while not _G.DataStoreManager and maxWait < 50 do
		task.wait(0.1)
		maxWait = maxWait + 1
	end
	
	if not _G.DataStoreManager then
		warn("[LEADERBOARD] DataStore manager not found!")
		return {}
	end
	
	return _G.DataStoreManager.getRobuxSpentLeaderboard()
end

-- Animation updater bound to this leaderboard's refresh cadence
local animUpdate = LeaderboardAnimationManager.bindToExternalTick("RobuxSpentLeaderboard", function()
	return _G.DataStoreManager.getTop1RobuxSpentPlayer()
end)

-- Waits for cached leaderboard data to be available (used for the first load)
local function waitForInitialData(timeoutSeconds)
	local start = tick()
	while tick() - start < timeoutSeconds do
		local cache = _G.DataStoreManager and _G.DataStoreManager.getRobuxSpentLeaderboard()
		if cache and #cache > 0 then
			return true
		end
		task.wait(0.5)
	end
	return false
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

-- Main update function: Gets cached leaderboard and displays top 50 players
local function UpdateList()
	ClearList()
	local top50 = getTop50Players()
	
	task.spawn(function()	
		-- Populate leaderboard with top 50 players
		for _, plr in ipairs(top50) do
			local frame = basePlayerFrame:Clone()
			frame.Parent = boardFrame
			
			-- Set the player name, robux spent (with comma formatting), and rank
			frame.Plr.Text = tostring(plr.Player)
			frame.Amount.Text = formatWithCommas(plr.RobuxSpent)
			frame.Rank.Text = tostring(plr.Rank)
			
			frame.Visible = true
			task.wait(0.25)  -- Small delay for visual effect
		end
	end)
end

--// Main Loop: Update the leaderboard every 60 seconds (synced with DataStore Manager)
task.spawn(function()
	-- Wait for DataStore Manager to initialize
	local maxWait = 0
	while not _G.DataStoreManager and maxWait < 50 do
		task.wait(0.1)
		maxWait = maxWait + 1
	end

	-- Wait until cache for robux spent leaderboard has data (or timeout), then show immediately
	waitForInitialData(15)
	UpdateList()
	animUpdate()

	while true do
		-- Countdown timer: shows how long until next update
		for count=60,0,-1 do
			counter.Text = "Updating board in "..count.." seconds"
			task.wait(1)
		end
		UpdateList()
		animUpdate()
	end
end)