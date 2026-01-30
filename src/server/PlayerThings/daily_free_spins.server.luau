--// Daily Free Spins Handler
--// Resets free spins daily and grants bonus spins based on gamepasses owned

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

-- DataStore to track last login date for daily reset
local FreeSpinsDataStore = DataStoreService:GetDataStore("FreeSpinsDaily")

-- GamePass IDs that grant bonus free spins
local GAMEPASS_BONUS_SPINS = {
	[1691824103] = 10,   -- VIP: +10 spins
	[1691201385] = 30,   -- Ultra VIP: +30 spins
}

-- Base free spins per day
local BASE_FREE_SPINS = 3

-- Function to check if it's a new day since last login
local function isNewDay(lastLoginTime)
	if not lastLoginTime then
		return true  -- First time login
	end
	
	local now = os.time()
	local nowDate = os.date("*t", now)
	local lastDate = os.date("*t", lastLoginTime)
	
	-- Check if it's a different day
	if nowDate.year ~= lastDate.year or nowDate.yday ~= lastDate.yday then
		return true
	end
	
	return false
end

-- Function to calculate total free spins based on gamepasses
local function calculateFreeSpins(player)
	local totalSpins = BASE_FREE_SPINS
	local highestBonus = 0
	
	print("[FREE SPINS] Calculating spins for " .. player.Name)
	
	-- Check for reward VIP status first
	local rewardVIP = player:FindFirstChild("RewardVIP")
	if rewardVIP and rewardVIP.Value == true then
		highestBonus = 10  -- VIP gamepass bonus value
		print("[FREE SPINS] Player has RewardVIP, starting with +10 bonus")
	end
	
	-- Check each gamepass and find the highest bonus
	for gamePassId, bonusSpins in pairs(GAMEPASS_BONUS_SPINS) do
		local success, hasPass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
		end)
		
		if success then
			print("[FREE SPINS] GamePass " .. gamePassId .. ": " .. tostring(hasPass) .. " (bonus: " .. bonusSpins .. ")")
			if hasPass and bonusSpins > highestBonus then
				highestBonus = bonusSpins
			end
		else
			warn("[FREE SPINS] Failed to check gamepass " .. gamePassId)
		end
	end
	
	-- Only add the highest bonus, not stack them
	totalSpins = totalSpins + highestBonus
	
	print("[FREE SPINS] Total spins: " .. totalSpins .. " (base: " .. BASE_FREE_SPINS .. ", highest bonus: " .. highestBonus .. ")")
	
	return totalSpins
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	-- Wait for FreeSpins value to be created by savedata
	local freeSpins = player:WaitForChild("FreeSpins", 10)
	if not freeSpins then
		warn("FreeSpins value not found for " .. player.Name)
		return
	end
	
	-- Load last login time from DataStore
	local playerKey = "Player_" .. player.UserId
	local lastLoginTime = nil
	
	local success, data = pcall(function()
		return FreeSpinsDataStore:GetAsync(playerKey)
	end)
	
	if success then
		lastLoginTime = data
	end
	
	-- Check if it's a new day
	if isNewDay(lastLoginTime) then
		-- Grant daily free spins (base + gamepass bonuses)
		local totalSpins = calculateFreeSpins(player)
		freeSpins.Value = totalSpins
		print(player.Name .. " received " .. totalSpins .. " free spins for today!")
		
		-- Save current login time
		local saveSuccess = pcall(function()
			FreeSpinsDataStore:SetAsync(playerKey, os.time())
		end)
		
		if not saveSuccess then
			warn("Failed to save login time for " .. player.Name)
		end
	else
		-- Not a new day, keep existing free spins (don't reset)
		print(player.Name .. " already claimed free spins today. Remaining: " .. freeSpins.Value)
	end
end)

print("Daily Free Spins Handler loaded successfully!")
