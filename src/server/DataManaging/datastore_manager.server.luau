--// DataStore Manager: Central hub for all DataStore operations
--// Caches leaderboard data in memory to avoid repeated queries
--// Batches requests to prevent queue buildup

local DSS = game:GetService("DataStoreService")
local CoinsDataStore = DSS:GetOrderedDataStore("CoinsBoard2")
local TimeDataStore = DSS:GetOrderedDataStore("TimeSpentBoard2")
local RebirthsDataStore = DSS:GetOrderedDataStore("RebirthsBoard2")
local StrengthDataStore = DSS:GetOrderedDataStore("StrengthBoard2")
local RobuxSpentDataStore = DSS:GetOrderedDataStore("RobuxSpentBoard2")

--// Cache storage (updates every 60 seconds)
local leaderboardCache = {
	coins = {},
	time = {},
	rebirths = {},
	strength = {},
	robuxSpent = {},
	lastUpdate = {
		coins = 0,
		time = 0,
		rebirths = 0,
		strength = 0,
		robuxSpent = 0
	}
}

--// Maximum cache age in seconds (update frequency)
local CACHE_LIFETIME = 60

--// Functions exposed via _G for other scripts
local Manager = {}

-- Get cached coins leaderboard (top 50)
-- Returns the cached data without making a new DataStore request
function Manager.getCoinsLeaderboard()
	return leaderboardCache.coins
end

-- Get cached time leaderboard (top 50)
-- Returns the cached data without making a new DataStore request
function Manager.getTimeLeaderboard()
	return leaderboardCache.time
end

-- Get top 1 player by coins (returns userId or nil)
function Manager.getTop1CoinPlayer()
	if #leaderboardCache.coins > 0 then
		return leaderboardCache.coins[1].UserId
	end
	return nil
end

-- Get top 1 player by time spent (returns userId or nil)
function Manager.getTop1TimePlayer()
	if #leaderboardCache.time > 0 then
		return leaderboardCache.time[1].UserId
	end
	return nil
end

-- Get cached rebirths leaderboard (top 50)
-- Returns the cached data without making a new DataStore request
function Manager.getRebirthsLeaderboard()
	return leaderboardCache.rebirths
end

-- Get top 1 player by rebirths (returns userId or nil)
function Manager.getTop1RebirthPlayer()
	if #leaderboardCache.rebirths > 0 then
		return leaderboardCache.rebirths[1].UserId
	end
	return nil
end

-- Get cached strength leaderboard (top 50)
-- Returns the cached data without making a new DataStore request
function Manager.getStrengthLeaderboard()
	return leaderboardCache.strength
end

-- Get top 1 player by strength (returns userId or nil)
function Manager.getTop1StrengthPlayer()
	if #leaderboardCache.strength > 0 then
		return leaderboardCache.strength[1].UserId
	end
	return nil
end

-- Get cached robux spent leaderboard (top 50)
-- Returns the cached data without making a new DataStore request
function Manager.getRobuxSpentLeaderboard()
	return leaderboardCache.robuxSpent
end

-- Get top 1 player by robux spent (returns userId or nil)
function Manager.getTop1RobuxSpentPlayer()
	if #leaderboardCache.robuxSpent > 0 then
		return leaderboardCache.robuxSpent[1].UserId
	end
	return nil
end

-- Fetch top 50 from DataStore and cache it
local function fetchCoinsLeaderboard()
	local success, pages = pcall(function()
		return CoinsDataStore:GetSortedAsync(false, 50)
	end)
	
	if not success then
		warn("[DATASTORE_MANAGER] Failed to fetch coins leaderboard: " .. tostring(pages))
		return
	end
	
	local top50 = pages:GetCurrentPage()
	local newCache = {}
	
	for rank, data in ipairs(top50) do
		local userId = tonumber(data.key:split('_')[2])
		local coins = data.value
		
		-- Get player name
		local playerName = "Unknown"
		local nameSuccess, nameResult = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId)
		end)
		
		if nameSuccess and nameResult then
			playerName = nameResult
		end
		
		table.insert(newCache, {
			Rank = rank,
			Player = playerName,
			UserId = userId,
			Coins = coins
		})
	end
	
	leaderboardCache.coins = newCache
	leaderboardCache.lastUpdate.coins = tick()
end

-- Fetch top 50 from DataStore and cache it
local function fetchTimeLeaderboard()
	local success, pages = pcall(function()
		return TimeDataStore:GetSortedAsync(false, 50)
	end)
	
	if not success then
		warn("[DATASTORE_MANAGER] Failed to fetch time leaderboard: " .. tostring(pages))
		return
	end
	
	local top50 = pages:GetCurrentPage()
	local newCache = {}
	
	for rank, data in ipairs(top50) do
		local userId = tonumber(data.key:split('_')[2])
		local timeSpent = data.value
		
		-- Get player name
		local playerName = "Unknown"
		local nameSuccess, nameResult = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId)
		end)
		
		if nameSuccess and nameResult then
			playerName = nameResult
		end
		
		table.insert(newCache, {
			Rank = rank,
			Player = playerName,
			UserId = userId,
			TimeSpent = timeSpent
		})
	end
	
	leaderboardCache.time = newCache
	leaderboardCache.lastUpdate.time = tick()
end

-- Fetch top 50 from DataStore and cache it
local function fetchRebirthsLeaderboard()
	local success, pages = pcall(function()
		return RebirthsDataStore:GetSortedAsync(false, 50)
	end)
	
	if not success then
		warn("[DATASTORE_MANAGER] Failed to fetch rebirths leaderboard: " .. tostring(pages))
		return
	end
	
	local top50 = pages:GetCurrentPage()
	local newCache = {}
	
	for rank, data in ipairs(top50) do
		local userId = tonumber(data.key:split('_')[2])
		local rebirths = data.value
		
		-- Get player name
		local playerName = "Unknown"
		local nameSuccess, nameResult = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId)
		end)
		
		if nameSuccess and nameResult then
			playerName = nameResult
		end
		
		table.insert(newCache, {
			Rank = rank,
			Player = playerName,
			UserId = userId,
			Rebirths = rebirths
		})
	end
	
	leaderboardCache.rebirths = newCache
	leaderboardCache.lastUpdate.rebirths = tick()
end

-- Fetch top 50 from DataStore and cache it
local function fetchStrengthLeaderboard()
	local success, pages = pcall(function()
		return StrengthDataStore:GetSortedAsync(false, 50)
	end)
	
	if not success then
		warn("[DATASTORE_MANAGER] Failed to fetch strength leaderboard: " .. tostring(pages))
		return
	end
	
	local top50 = pages:GetCurrentPage()
	local newCache = {}
	
	for rank, data in ipairs(top50) do
		local userId = tonumber(data.key:split('_')[2])
		local strength = data.value
		
		-- Get player name
		local playerName = "Unknown"
		local nameSuccess, nameResult = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId)
		end)
		
		if nameSuccess and nameResult then
			playerName = nameResult
		end
		
		table.insert(newCache, {
			Rank = rank,
			Player = playerName,
			UserId = userId,
			Strength = strength
		})
	end
	
	leaderboardCache.strength = newCache
	leaderboardCache.lastUpdate.strength = tick()
	print("[DATASTORE_MANAGER] Updated strength leaderboard cache (" .. #newCache .. " players)")
end

-- Fetch top 50 from DataStore and cache it
local function fetchRobuxSpentLeaderboard()
	local success, pages = pcall(function()
		return RobuxSpentDataStore:GetSortedAsync(false, 50)
	end)
	
	if not success then
		warn("[DATASTORE_MANAGER] Failed to fetch robux spent leaderboard: " .. tostring(pages))
		return
	end
	
	local top50 = pages:GetCurrentPage()
	local newCache = {}
	
	for rank, data in ipairs(top50) do
		local userId = tonumber(data.key:split('_')[2])
		local robuxSpent = data.value
		
		-- Get player name
		local playerName = "Unknown"
		local nameSuccess, nameResult = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId)
		end)
		
		if nameSuccess and nameResult then
			playerName = nameResult
		end
		
		table.insert(newCache, {
			Rank = rank,
			Player = playerName,
			UserId = userId,
			RobuxSpent = robuxSpent
		})
	end
	
	leaderboardCache.robuxSpent = newCache
	leaderboardCache.lastUpdate.robuxSpent = tick()
	print("[DATASTORE_MANAGER] Updated robux spent leaderboard cache (" .. #newCache .. " players)")
end

--// Main Update Loop: Fetch leaderboards every 60 seconds (staggered to avoid queue buildup)
task.spawn(function()
	-- Initial fetch
	fetchCoinsLeaderboard()
	task.wait(2)
	fetchTimeLeaderboard()
	task.wait(2)
	fetchRebirthsLeaderboard()
	task.wait(2)
	fetchStrengthLeaderboard()
	task.wait(2)
	fetchRobuxSpentLeaderboard()
	
	while true do
		task.wait(60)
		
		-- Fetch all leaderboards with staggered timing
		-- This prevents simultaneous DataStore requests
		fetchCoinsLeaderboard()
		task.wait(2)
		fetchTimeLeaderboard()
		task.wait(2)
		fetchRebirthsLeaderboard()
		task.wait(2)
		fetchStrengthLeaderboard()
		task.wait(2)
		fetchRobuxSpentLeaderboard()
	end
end)

-- Expose manager functions globally so other scripts can use them
_G.DataStoreManager = Manager

print("[DATASTORE_MANAGER] Initialized - All leaderboards will be cached and updated every 60 seconds")