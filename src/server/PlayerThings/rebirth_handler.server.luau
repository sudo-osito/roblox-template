--// Rebirth Handler
--// Processes rebirth requests from clients
--// Resets Coins and Strength to 0 (or starting value) but keeps MaxCoins and MaxStrength intact
--// This allows leaderboards to show peak values while resetting player progress

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvent structure if it doesn't exist
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = Shared:FindFirstChild("RemoteEvents")
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = Shared
end

local RebirthEvent = RemoteEvents:FindFirstChild("RebirthRequest")
if not RebirthEvent then
	RebirthEvent = Instance.new("RemoteEvent")
	RebirthEvent.Name = "RebirthRequest"
	RebirthEvent.Parent = RemoteEvents
end

-- Configuration: Change these values to adjust rebirth requirements and rewards
local REBIRTH_CONFIG = {
	-- Base coins required for FIRST rebirth
	baseCoins = 100000,
	-- Base strength required for FIRST rebirth
	baseStrength = 1500,
	-- Exponential multiplier for COINS per rebirth (1.5 = 50% increase each time)
	-- Examples: 1.5 = moderate, 2.0 = aggressive, 1.3 = gentle
	coinsMultiplier = 2.5,
	-- Exponential multiplier for STRENGTH per rebirth (can be different from coins)
	-- Examples: 1.8 = harder strength scaling, 1.3 = easier strength scaling
	strengthMultiplier = 1.5,
	-- Whether to reset coins to 0 or a starting value
	resetCoinsTo = 0,
	-- Whether to reset strength to 0 or a starting value
	resetStrengthTo = 0,
}

-- Calculates the required coins/strength for next rebirth based on current rebirth count
-- Formula: requirement = baseRequirement * (multiplier ^ currentRebirths)
local function calculateRequirements(currentRebirths)
	-- Cap the multiplier to prevent infinity (max rebirth level for calculation is 10)
	local cappedRebirths = math.min(currentRebirths, 10)
	
	local requiredCoins = math.floor(REBIRTH_CONFIG.baseCoins * (REBIRTH_CONFIG.coinsMultiplier ^ cappedRebirths))
	local requiredStrength = math.floor(REBIRTH_CONFIG.baseStrength * (REBIRTH_CONFIG.strengthMultiplier ^ cappedRebirths))
	
	-- Ensure values don't become infinity
	requiredCoins = math.min(requiredCoins, 9e15)  -- Cap at 9 quadrillion
	requiredStrength = math.min(requiredStrength, 9e15)
	
	return requiredCoins, requiredStrength
end

-- Validates if player meets rebirth requirements
-- Returns: success (boolean), errorMessage (string or nil)
local function canRebirth(player)
	local coins = player:FindFirstChild("Coins")
	local strength = player:FindFirstChild("Strength")
	local rebirths = player:FindFirstChild("Rebirths")
	
	if not coins or not strength or not rebirths then
		return false, "Player data not found"
	end
	
	-- Calculate exponential requirements based on current rebirth count
	local requiredCoins, requiredStrength = calculateRequirements(rebirths.Value)
	
	if coins.Value < requiredCoins then
		return false, "Not enough coins! Need at least " .. requiredCoins .. " (you have " .. coins.Value .. ")"
	end
	
	if strength.Value < requiredStrength then
		return false, "Not enough strength! Need at least " .. requiredStrength .. " (you have " .. strength.Value .. ")"
	end
	
	return true, nil
end

-- Processes the rebirth for a player
-- Resets current coins and strength but keeps max values for leaderboards
local function processRebirth(player)
	local coins = player:FindFirstChild("Coins")
	local strength = player:FindFirstChild("Strength")
	local rebirths = player:FindFirstChild("Rebirths")
	local maxCoins = player:FindFirstChild("MaxCoins")
	local maxStrength = player:FindFirstChild("MaxStrength")
	
	if not coins or not strength or not rebirths then
		warn("Player " .. player.Name .. " is missing required values for rebirth")
		return false, "Missing player data"
	end
	
	-- Check requirements
	local canDo, errorMsg = canRebirth(player)
	if not canDo then
		return false, errorMsg
	end
	
	-- Perform rebirth
	-- Reset current values
	coins.Value = REBIRTH_CONFIG.resetCoinsTo
	strength.Value = REBIRTH_CONFIG.resetStrengthTo
	
	-- MaxCoins and MaxStrength remain unchanged - this is the key!
	-- The leaderboards save MaxCoins and MaxStrength, so peak values stay on leaderboards
	
	-- Increment rebirth count
	rebirths.Value = rebirths.Value + 1
	
	-- Calculate next rebirth requirements for logging
	local nextCoins, nextStrength = calculateRequirements(rebirths.Value)
	
	print(player.Name .. " rebirthed! Now has " .. rebirths.Value .. " rebirths")
	print("  - Max coins on leaderboard: " .. (maxCoins and maxCoins.Value or "N/A"))
	print("  - Max strength on leaderboard: " .. (maxStrength and maxStrength.Value or "N/A"))
	print("  - Next rebirth requires: " .. nextCoins .. " coins, " .. nextStrength .. " strength")
	
	return true, "Successfully rebirthed!"
end

-- Handle rebirth requests from clients
RebirthEvent.OnServerEvent:Connect(function(player)
	local success, message = processRebirth(player)
	
	-- Send result back to client
	-- You can create a separate RemoteEvent for responses if needed
	-- For now, we'll just print the result
	if success then
		print("Rebirth success for " .. player.Name)
		-- Optional: Fire a RemoteEvent back to client to show success message
	else
		warn("Rebirth failed for " .. player.Name .. ": " .. (message or "Unknown error"))
		-- Optional: Fire a RemoteEvent back to client to show error message
	end
end)

print("Rebirth handler initialized")
