--// Services
local DSS = game:GetService("DataStoreService")
local LeaderboardAnimationManager = require(game.ReplicatedStorage.Shared.LeaderboardAnimationManager)
-- Retrieve the ordered DataStore that tracks all players' coins (sorted highest to lowest)
local DataStore = DSS:GetOrderedDataStore("CoinsBoard2")


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
local counter = workspace.CoinsLeaderboard.UpdateBoardTimer.Timer:WaitForChild("TextLabel")
-- The SurfaceGui that displays the leaderboard on a part
local UI = workspace.CoinsLeaderboard.ScoreBlock:WaitForChild("SurfaceGui")
-- The template frame to clone for each player in the leaderboard
local basePlayerFrame = UI:WaitForChild("BasePlayerFrame")
-- The ScrollingFrame that contains all the player entries
local boardFrame = UI:WaitForChild("ScrollingFrame")

--// Functions
-- Saves all currently online players' coin data to the DataStore
-- This ensures the leaderboard rankings stay up-to-date with current session data
-- NOTE: This is now handled by datastore_manager.server.luau
local function SaveData()
    -- Data is saved on player exit in savedata.server.luau
    -- This function is kept for backward compatibility
    return
end

-- Fetches the top 50 players by coins from the cached DataStore manager
-- Returns a table with player info: { Player = name, Coins = amount, Rank = position }
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
	
	return _G.DataStoreManager.getCoinsLeaderboard()
end

-- Animation updater bound to this leaderboard's refresh cadence
local animUpdate = LeaderboardAnimationManager.bindToExternalTick("CoinsLeaderboard", function()
	return _G.DataStoreManager.getTop1CoinPlayer()
end)

-- Waits for cached leaderboard data to be available (used for the first load)
local function waitForInitialData(timeoutSeconds)
	local start = tick()
	while tick() - start < timeoutSeconds do
		local cache = _G.DataStoreManager and _G.DataStoreManager.getCoinsLeaderboard()
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
	-- Don't save data here - it's only saved on player exit in savedata.server.luau
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

--// Main Loop: Update the leaderboard every 60 seconds (synced with DataStore Manager)
task.spawn(function()
	-- Wait for DataStore Manager to initialize
	local maxWait = 0
	while not _G.DataStoreManager and maxWait < 50 do
		task.wait(0.1)
		maxWait = maxWait + 1
	end

	-- Wait until cache for coins leaderboard has data (or timeout), then show immediately
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


