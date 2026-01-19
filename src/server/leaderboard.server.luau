local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MyDataStore = DataStoreService:GetDataStore("PlayerData")

local AUTOSAVE_INTERVAL = 60

-- =========================
-- LOAD DATA
-- =========================
local function setupLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local dollars = Instance.new("IntValue")
	dollars.Name = "Dollars"
	dollars.Value = 0
	dollars.Parent = leaderstats

	local success, data = pcall(function()
		return MyDataStore:GetAsync(player.UserId)
	end)

	if success and data then
		dollars.Value = data.dollars or 0
		print("Loaded dollars:", dollars.Value)
	else
		print("No data found, using default")
	end
end

Players.PlayerAdded:Connect(setupLeaderstats)

-- =========================
-- SAVE DATA (UpdateAsync)
-- =========================
local function savePlayer(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local dollars = leaderstats:FindFirstChild("Dollars")
	if not dollars then return end

	local success, err = pcall(function()
		MyDataStore:UpdateAsync(player.UserId, function(oldData)
			oldData = oldData or {}
			oldData.dollars = dollars.Value
			return oldData
		end)
	end)

	if success then
		print("Saved dollars:", dollars.Value)
	else
		warn("Failed to save:", err)
	end
end

Players.PlayerRemoving:Connect(savePlayer)

-- =========================
-- AUTOSAVE LOOP
-- =========================
task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
		print("Autosave completed")
	end
end)

-- =========================
-- BIND TO CLOSE
-- =========================
game:BindToClose(function()
	print("Server shutting down, saving all players...")
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
	task.wait(2) -- give datastore time
end)

