--// Services
local DSS = game:GetService("DataStoreService")
local LeaderboardAnimationManager = require(game.ReplicatedStorage.Shared.LeaderboardAnimationManager)
-- Retrieve the ordered DataStore that tracks all players' time spent (sorted highest to lowest)
local DataStore = DSS:GetOrderedDataStore("TimeSpentBoard1")

print("[LEADERBOARD] Time Played leaderboard server script started")

--// Functions
-- Formats seconds into a readable time format for display
-- Examples: 45 -> "45s", 90 -> "1m 30s", 3661 -> "1h 1m 1s"
local function formatTime(seconds)
	if seconds < 60 then
		return seconds .. "s"
	elseif seconds < 3600 then
		local minutes = math.floor(seconds / 60)
		local remainingSeconds = seconds % 60
		return minutes .. "m " .. remainingSeconds .. "s"
	else
		local hours = math.floor(seconds / 3600)
		local remainingMinutes = math.floor((seconds % 3600) / 60)
		local remainingSeconds = seconds % 60
		if remainingSeconds > 0 then
			return hours .. "h " .. remainingMinutes .. "m " .. remainingSeconds .. "s"
		else
			return hours .. "h " .. remainingMinutes .. "m"
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
-- NOTE: This is now handled by datastore_manager.server.luau
local function SaveData()
    -- Data is saved on player exit in savedata.server.luau
    -- This function is kept for backward compatibility
    return
end

-- Fetches the top 50 players by time spent from the cached DataStore manager
-- Returns a table with player info: { Player = name, TimeSpent = seconds, Rank = position }
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
	
	local cached = _G.DataStoreManager.getTimeLeaderboard()
	
	-- Convert cache format to expected format
	local result = {}
	for _, data in ipairs(cached) do
		table.insert(result, {
			Rank = data.Rank,
			Player = data.Player,
			TimeSpent = data.TimeSpent
		})
	end
	
	return result
end

-- Animation updater bound to this leaderboard's refresh cadence
local animUpdate = LeaderboardAnimationManager.bindToExternalTick("TimeSpentLeaderboard", function()
	return _G.DataStoreManager.getTop1TimePlayer()
end)

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
	-- Don't save data here - it's only saved on player exit in savedata.server.luau
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

-- Waits for cached leaderboard data to be available (used for the first load)
local function waitForInitialData(timeoutSeconds)
	local start = tick()
	while tick() - start < timeoutSeconds do
		local cache = _G.DataStoreManager and _G.DataStoreManager.getTimeLeaderboard()
		if cache and #cache > 0 then
			return true
		end
		task.wait(0.5)
	end
	return false
end

--// Main Loop: Update the leaderboard every 60 seconds (synced with DataStore Manager)
task.spawn(function()
	-- Wait for DataStore Manager to initialize
	local maxWait = 0
	while not _G.DataStoreManager and maxWait < 50 do
		task.wait(0.1)
		maxWait = maxWait + 1
	end

	-- Wait until cache for time leaderboard has data (or timeout), then show immediately
	waitForInitialData(8)
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