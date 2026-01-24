--// Services
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
-- CoinsBoard1: Stores player coin amounts (sorted highest to lowest for leaderboard)
local DataStore = DSS:GetOrderedDataStore("CoinsBoard1")
-- TimeSpentBoard1: Stores player time spent amounts (sorted highest to lowest for leaderboard)
local DataStore2 = DSS:GetOrderedDataStore("TimeSpentBoard1")

--// Functions
-- Converts seconds into a readable time format (e.g., 3661 -> "1h 1m")
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

-- Converts coin amounts into shortened format (e.g., 1500 -> "1.5k", 2000000 -> "2.0m")
-- Supports: k (thousands), m (millions), b (billions), t (trillions), q (quadrillions)
local function formatCoins(coins)
	local suffixes = { "k", "m", "b", "t", "q" }
	local divisor = 1000
	
	if coins < 1000 then
		return coins
	end
	
	for i, suffix in ipairs(suffixes) do
		if coins < divisor ^ (i + 1) then
			local value = coins / (divisor ^ i)
			return string.format("%.1f", value) .. suffix
		end
	end
	
	-- If larger than quadrillions
	local value = coins / (divisor ^ #suffixes)
	return string.format("%.1f", value) .. suffixes[#suffixes]
end

-- Called when a player joins the game
-- Loads their saved coins and time played from DataStore
-- Creates leaderstats folder with formatted display values
local function OnPlayerAdded(player)
	local plr_key = "id_"..player.UserId.."_Coins"
	local plr_key2 = "id_"..player.UserId.."_Time Played"

	-- Load coins from DataStore (returns nil if first time)
	local success, data = pcall(function()
		return DataStore:GetAsync(plr_key)
	end)
	
	-- Load time spent from DataStore (returns nil if first time)
	local success2, data2 = pcall(function()
		return DataStore2:GetAsync(plr_key2)
	end)

	-- Create leaderstats folder (required for leaderboard display)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	-- Raw coins value (stored on player, not visible in leaderboard)
	-- Used for calculations and DataStore saves
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = player  -- Parent to player, not stats, so it won't show on leaderboard
	if success then 
		coins.Value = data or 0 
	end

	-- Formatted coins display (shown in leaderboard as "1.5k", "2.3m", etc)
	local coinsDisplay = Instance.new("StringValue")
	coinsDisplay.Name = "Coins"
	coinsDisplay.Parent = stats
	coinsDisplay.Value = formatCoins(coins.Value)

	-- Update formatted display whenever raw coins change
	coins.Changed:Connect(function()
		coinsDisplay.Value = formatCoins(coins.Value)
	end)

	-- Raw time spent value (stored on player, not visible in leaderboard)
	-- Used for incrementing and DataStore saves
	local timeSpent = Instance.new("IntValue")
	timeSpent.Name = "Time Played"
	timeSpent.Parent = player  -- Parent to player, not stats, so it won't show on leaderboard
	if success2 then
		timeSpent.Value = data2 or 0
	end

	-- Formatted time display (shown in leaderboard as "1h 5m", "45s", etc)
	local timePlayedDisplay = Instance.new("StringValue")
	timePlayedDisplay.Name = "Time Played"
	timePlayedDisplay.Parent = stats
	timePlayedDisplay.Value = formatTime(timeSpent.Value)

	-- Update formatted display whenever time spent changes
	timeSpent.Changed:Connect(function()
		timePlayedDisplay.Value = formatTime(timeSpent.Value)
	end)

	-- Increment time spent by 1 second every second while player is in game
	task.spawn(function()
		while player.Parent do
			task.wait(1)
			timeSpent.Value = timeSpent.Value + 1
		end
	end)
end

-- Called when server is shutting down
-- Saves all online players' data to DataStore before shutdown
local function OnServerShutdown()
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		local plr_key = "id_"..player.UserId.."_Coins"
		local plr_key2 = "id_"..player.UserId.."_Time Played"

		-- Get raw coin and time values (not the formatted displays)
		local coins = player:FindFirstChild("Coins")
		local timeSpent = player:FindFirstChild("Time Played")

		local success, result = pcall(function()
			-- Save both values to their respective DataStores
			if coins then
				DataStore:SetAsync(plr_key, coins.Value)
			end
			if timeSpent then
				DataStore2:SetAsync(plr_key2, timeSpent.Value)
			end
		end)

		if not success then 
			warn(result)
		end
	end
end

-- Called when a player leaves the game
-- Saves their current coins and time spent to DataStore
local function OnPlayerRemoving(player)
	local plr_key = "id_"..player.UserId.."_Coins"
	local plr_key2 = "id_"..player.UserId.."_Time Played"

	-- Get raw coin and time values (not the formatted displays)
	local coins = player:FindFirstChild("Coins")
	local timeSpent = player:FindFirstChild("Time Played")

	local success, result = pcall(function()
		if coins then
			DataStore:SetAsync(plr_key, coins.Value)
		end
		if timeSpent then
			DataStore2:SetAsync(plr_key2, timeSpent.Value)
		end
	end)

	if not success then 
		warn(result)
	end
end

--// Player-related functions
-- Creates leaderstats folder with both raw and formatted versions of coins/time
local function OnPlayerAdded(player)
	local plr_key = "id_"..player.UserId.."_Coins"
	local plr_key2 = "id_"..player.UserId.."_Time Played"

	-- Load coins from DataStore
	local success, data = pcall(function()
		return DataStore:GetAsync(plr_key)
	end)
	
	-- Load time from DataStore
	local success2, data2 = pcall(function()
		return DataStore2:GetAsync(plr_key2)
	end)

	-- Create leaderstats folder for displaying formatted versions
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	-- Raw coins value stored on player (not in leaderstats) for calculations
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = player
	if success then 
		coins.Value = data or 0 
	end

	-- Formatted coins display in leaderstats (shows "1.5k" instead of 1500)
	local coinsDisplay = Instance.new("StringValue")
	coinsDisplay.Name = "Coins"
	coinsDisplay.Parent = stats
	coinsDisplay.Value = formatCoins(coins.Value)

	-- Auto-update formatted display whenever raw coins change
	coins.Changed:Connect(function()
		coinsDisplay.Value = formatCoins(coins.Value)
	end)

	-- Raw time value stored on player (not in leaderstats) for calculations
	local timeSpent = Instance.new("IntValue")
	timeSpent.Name = "Time Played"
	timeSpent.Parent = player
	if success2 then
		timeSpent.Value = data2 or 0
	end

	-- Formatted time display in leaderstats (shows "1h 5m" instead of 3900)
	local timePlayedDisplay = Instance.new("StringValue")
	timePlayedDisplay.Name = "Time Played"
	timePlayedDisplay.Parent = stats
	timePlayedDisplay.Value = formatTime(timeSpent.Value)

	-- Auto-update formatted display whenever raw time changes
	timeSpent.Changed:Connect(function()
		timePlayedDisplay.Value = formatTime(timeSpent.Value)
	end)

	-- Increment time spent every 1 second in background
	task.spawn(function()
		while player.Parent do
			task.wait(1)
			timeSpent.Value = timeSpent.Value + 1
		end
	end)
end

-- Saves player data when they leave the server
local function OnPlayerRemoving(player)
	local plr_key = "id_"..player.UserId.."_Coins"
	local plr_key2 = "id_"..player.UserId.."_Time Played"

	-- Get raw coin and time values from the player
	local coins = player:FindFirstChild("Coins")
	local timeSpent = player:FindFirstChild("Time Played")

	-- Save both values to their respective DataStores
	local success, result = pcall(function()
		if coins then
			DataStore:SetAsync(plr_key, coins.Value)
		end
		if timeSpent then
			DataStore2:SetAsync(plr_key2, timeSpent.Value)
		end
	end)

	if not success then 
		warn(result)
	end
end

-- Saves all player data when server is shutting down
local function OnServerShutdown()
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		local plr_key = "id_"..player.UserId.."_Coins"
		local plr_key2 = "id_"..player.UserId.."_Time Played"

		-- Get raw coin and time values from the player
		local coins = player:FindFirstChild("Coins")
		local timeSpent = player:FindFirstChild("Time Played")

		-- Save both values to their respective DataStores
		local success, result = pcall(function()
			if coins then
				DataStore:SetAsync(plr_key, coins.Value)
			end
			if timeSpent then
				DataStore2:SetAsync(plr_key2, timeSpent.Value)
			end
		end)

		if not success then 
			warn(result)
		end
	end
end

--// Connections
game.Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
game:BindToClose(OnServerShutdown)