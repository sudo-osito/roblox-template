--// Services
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local DataStore = DSS:GetOrderedDataStore("CoinsBoard1")

--// Functions
local function OnPlayerAdded(player)
	local plr_key = "id_"..player.UserId.."_Coins"
	local success, data = pcall(function()
		return DataStore:GetAsync(plr_key)
	end)

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = stats
	print(success, data)
	if success then 
		coins.Value = data or 0 
	end
end

local function OnServerShutdown()
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

local function OnPlayerRemoving(player)
	local plr_key = "id_"..player.UserId.."_Coins"

	local coins = player.leaderstats.Coins
	local success, result = pcall(function()
		DataStore:SetAsync(plr_key, coins.Value)
	end)

	if not success then 
		warn(result)
	end
end

--// Conections
game.Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
game:BindToClose(OnServerShutdown)