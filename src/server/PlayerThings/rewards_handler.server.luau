--// Rewards Handler
--// Handles session-based playtime rewards
--// Players can claim rewards once per session based on playtime

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvent structure if it doesn't exist
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = Shared:FindFirstChild("RemoteEvents")
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = Shared
end

local RewardsEvent = RemoteEvents:FindFirstChild("ClaimReward")
if not RewardsEvent then
	RewardsEvent = Instance.new("RemoteEvent")
	RewardsEvent.Name = "ClaimReward"
	RewardsEvent.Parent = RemoteEvents
end

-- Reward configuration: {time required in seconds, coins, strength}
local REWARD_CONFIG = {
	[1] = {time = 300, coins = 1000, strength = 0},       -- 5m: 1000 coins
	[2] = {time = 600, coins = 0, strength = 100},        -- 10m: 100 strength
	[3] = {time = 1200, coins = 5000, strength = 0},      -- 20m: 5000 coins
	[4] = {time = 1800, coins = 0, strength = 300},       -- 30m: 300 strength
	[5] = {time = 2700, coins = 15000, strength = 0},     -- 45m: 15000 coins
	[6] = {time = 3600, coins = 0, strength = 1000},      -- 1h: 1000 strength
	[7] = {time = 4800, coins = 30000, strength = 0},     -- 1h 20m: 30000 coins
	[8] = {time = 6000, coins = 70000, strength = 0},     -- 1h 40m: 70000 coins
	[9] = {time = 7200, coins = 140000, strength = 0},    -- 2h: 140000 coins
	[10] = {time = 8400, coins = 0, strength = 3000},     -- 2h 20m: 3000 strength
	[11] = {time = 9600, coins = 0, strength = 6000},     -- 2h 40m: 6000 strength
	[12] = {time = 10800, coins = 0, strength = 0, grantVIP = true}, -- 3h: VIP Perks
}

-- Track claimed rewards per player (session-based, not saved)
local playerClaimedRewards = {}

-- Validate and process reward claim
local function processRewardClaim(player, rewardId)
	-- Get player data
	local sessionTime = player:FindFirstChild("Session Time")
	local coins = player:FindFirstChild("Coins")
	local strength = player:FindFirstChild("Strength")
	
	if not sessionTime or not coins or not strength then
		warn("Player " .. player.Name .. " missing required data")
		return false, "Missing player data"
	end
	
	-- Validate reward ID
	local rewardData = REWARD_CONFIG[rewardId]
	if not rewardData then
		warn("Invalid reward ID: " .. tostring(rewardId))
		return false, "Invalid reward"
	end
	
	-- Check if already claimed this session
	if not playerClaimedRewards[player.UserId] then
		playerClaimedRewards[player.UserId] = {}
	end
	
	if playerClaimedRewards[player.UserId][rewardId] then
		warn("Player " .. player.Name .. " already claimed reward " .. rewardId)
		return false, "Already claimed"
	end
	
	-- Check if player has enough session time
	if sessionTime.Value < rewardData.time then
		warn("Player " .. player.Name .. " not enough time for reward " .. rewardId)
		return false, "Not enough time"
	end
	
	-- Mark as claimed
	playerClaimedRewards[player.UserId][rewardId] = true
	
	-- Wait for AutoMultiplier to be available
	local maxWait = 0
	while not _G.AutoMultiplier and maxWait < 50 do
		task.wait(0.1)
		maxWait = maxWait + 1
	end
	
	-- Give rewards (raw amounts, bypass multipliers)
	if rewardData.coins > 0 then
		if _G.AutoMultiplier and _G.AutoMultiplier.addCoinsRaw then
			_G.AutoMultiplier.addCoinsRaw(player, rewardData.coins)
		else
			-- Fallback: direct add
			coins.Value = coins.Value + rewardData.coins
		end
	end
	
	if rewardData.strength > 0 then
		if _G.AutoMultiplier and _G.AutoMultiplier.addStrengthRaw then
			_G.AutoMultiplier.addStrengthRaw(player, rewardData.strength)
		else
			-- Fallback: direct add
			strength.Value = strength.Value + rewardData.strength
		end
	end
	
	-- Grant VIP perks if this is the VIP reward
	if rewardData.grantVIP then
		local rewardVIP = player:FindFirstChild("RewardVIP")
		if rewardVIP then
			rewardVIP.Value = true
			print(player.Name .. " has been granted permanent VIP perks!")
		end
	end
	
	print(player.Name .. " claimed Reward " .. rewardId .. ": +" .. rewardData.coins .. " coins, +" .. rewardData.strength .. " strength")
	
	return true, "Success"
end

-- Handle reward claims from clients
RewardsEvent.OnServerEvent:Connect(function(player, rewardId)
	local success, message = processRewardClaim(player, rewardId)
	
	if not success then
		warn("Reward claim failed for " .. player.Name .. ": " .. message)
	end
end)

-- Cleanup when player leaves
game.Players.PlayerRemoving:Connect(function(player)
	if playerClaimedRewards[player.UserId] then
		playerClaimedRewards[player.UserId] = nil
	end
end)

print("Rewards handler initialized")
