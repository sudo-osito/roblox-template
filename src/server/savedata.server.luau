--// Services
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local DataStore = DSS:GetOrderedDataStore("CoinsBoard1")
local DataStore2 = DSS:GetOrderedDataStore("TimeSpentBoard1")

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

local function OnPlayerAdded(player)
	local plr_key = "id_"..player.UserId.."_Coins"
	local plr_key2 = "id_"..player.UserId.."_Time Played"

	local success, data = pcall(function()
		return DataStore:GetAsync(plr_key)
	end)
	
	local success2, data2 = pcall(function()
		return DataStore2:GetAsync(plr_key2)
	end)

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = player  -- Parent to player, not stats, so it won't show on leaderboard
	if success then 
		coins.Value = data or 0 
	end

	-- Create a display version of coins
	local coinsDisplay = Instance.new("StringValue")
	coinsDisplay.Name = "Coins"
	coinsDisplay.Parent = stats
	coinsDisplay.Value = formatCoins(coins.Value)

	-- Update coins display whenever coins change
	coins.Changed:Connect(function()
		coinsDisplay.Value = formatCoins(coins.Value)
	end)

	local timeSpent = Instance.new("IntValue")
	timeSpent.Name = "Time Played"
	timeSpent.Parent = player  -- Parent to player, not stats, so it won't show on leaderboard
	if success2 then
		timeSpent.Value = data2 or 0
	end

	-- Create a display version of time played
	local timePlayedDisplay = Instance.new("StringValue")
	timePlayedDisplay.Name = "Time Played"
	timePlayedDisplay.Parent = stats
	timePlayedDisplay.Value = formatTime(timeSpent.Value)

	-- Update display whenever time spent changes
	timeSpent.Changed:Connect(function()
		timePlayedDisplay.Value = formatTime(timeSpent.Value)
	end)

	-- Increment time spent in background
	task.spawn(function()
		while player.Parent do
			task.wait(1)
			timeSpent.Value = timeSpent.Value + 1
		end
	end)
end

local function OnServerShutdown()
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		local plr_key = "id_"..player.UserId.."_Coins"
		local plr_key2 = "id_"..player.UserId.."_Time Played"

		local coins = player.leaderstats.Coins
		local timeSpent = player:FindFirstChild("Time Played")

		local success, result = pcall(function()
			DataStore:SetAsync(plr_key, coins.Value)
			if timeSpent then
				DataStore2:SetAsync(plr_key2, timeSpent.Value)
			end
		end)

		if not success then 
			warn(result)
		end
	end
end

local function OnPlayerRemoving(player)
	local plr_key = "id_"..player.UserId.."_Coins"
	local plr_key2 = "id_"..player.UserId.."_Time Played"

	local coins = player.leaderstats.Coins
	local timeSpent = player:FindFirstChild("Time Played")

	local success, result = pcall(function()
		DataStore:SetAsync(plr_key, coins.Value)
		if timeSpent then
			DataStore2:SetAsync(plr_key2, timeSpent.Value)
		end
	end)

	if not success then 
		warn(result)
	end
end

--// Conections
game.Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
game:BindToClose(OnServerShutdown)