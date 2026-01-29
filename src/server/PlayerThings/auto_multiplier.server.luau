local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MultiplierManager = require(ReplicatedStorage.Shared.MultiplierManager)

-- Track previous values to detect gains
local previousValues = {}

-- Track when we're bypassing multipliers (for purchases)
local bypassMultiplier = {}

local function setupAutoMultipliers(player)
    local userId = player.UserId
    
    -- Wait for player data to load
    local coins = player:WaitForChild("Coins", 10)
    local strength = player:WaitForChild("Strength", 10)
    
    if not coins or not strength then
        warn("Failed to setup auto multipliers for", player.Name)
        return
    end
    
    -- Initialize tracking
    previousValues[userId] = {
        coins = coins.Value,
        strength = strength.Value
    }
    
    -- Flag to prevent infinite loops when we modify the value
    local isApplyingMultiplier = false
    
    -- COINS AUTO-MULTIPLIER
    coins.Changed:Connect(function(newValue)
        if isApplyingMultiplier then return end -- Prevent recursion
        
        local oldValue = previousValues[userId].coins
        local gain = newValue - oldValue
        
        -- Check if this is a bypassed addition (purchased coins)
        if bypassMultiplier[userId] and bypassMultiplier[userId].coins then
            bypassMultiplier[userId].coins = false
            previousValues[userId].coins = newValue
            return
        end
        
        -- Only apply multiplier if it's a gain (positive difference)
        if gain > 0 then
            isApplyingMultiplier = true
            
            -- Calculate what the multiplied gain should be
            local multipliedGain = MultiplierManager.calculateGain(player, gain, "Coins")
            
            -- Set the actual value: old value + multiplied gain
            coins.Value = oldValue + multipliedGain
            
            -- Update tracking
            previousValues[userId].coins = coins.Value
            
            isApplyingMultiplier = false
        else
            -- If it's a loss or no change, just update tracking
            previousValues[userId].coins = newValue
        end
    end)
    
    -- STRENGTH AUTO-MULTIPLIER
    strength.Changed:Connect(function(newValue)
        if isApplyingMultiplier then return end -- Prevent recursion
        
        local oldValue = previousValues[userId].strength
        local gain = newValue - oldValue
        
        -- Check if this is a bypassed addition (purchased strength)
        if bypassMultiplier[userId] and bypassMultiplier[userId].strength then
            bypassMultiplier[userId].strength = false
            previousValues[userId].strength = newValue
            return
        end
        
        -- Only apply multiplier if it's a gain (positive difference)
        if gain > 0 then
            isApplyingMultiplier = true
            
            -- Calculate what the multiplied gain should be
            local multipliedGain = MultiplierManager.calculateGain(player, gain, "Strength")
            
            -- Set the actual value: old value + multiplied gain
            strength.Value = oldValue + multipliedGain
            
            -- Update tracking
            previousValues[userId].strength = strength.Value
            
            isApplyingMultiplier = false
        else
            -- If it's a loss or no change, just update tracking
            previousValues[userId].strength = newValue
        end
    end)
    
    print("[AUTO-MULTIPLIER] Setup complete for", player.Name)
end

-- Setup for existing players
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        setupAutoMultipliers(player)
    end)
end

-- Setup for new players
Players.PlayerAdded:Connect(setupAutoMultipliers)

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
    previousValues[player.UserId] = nil
    bypassMultiplier[player.UserId] = nil
end)

-- PUBLIC FUNCTIONS: Add coins/strength without multipliers (for purchases)
local AutoMultiplier = {}

function AutoMultiplier.addCoinsRaw(player, amount)
    local userId = player.UserId
    if not bypassMultiplier[userId] then
        bypassMultiplier[userId] = {}
    end
    bypassMultiplier[userId].coins = true
    
    local coins = player:FindFirstChild("Coins")
    if coins then
        coins.Value = coins.Value + amount
    end
end

function AutoMultiplier.addStrengthRaw(player, amount)
    local userId = player.UserId
    if not bypassMultiplier[userId] then
        bypassMultiplier[userId] = {}
    end
    bypassMultiplier[userId].strength = true
    
    local strength = player:FindFirstChild("Strength")
    if strength then
        strength.Value = strength.Value + amount
    end
end

-- Expose globally for other scripts
_G.AutoMultiplier = AutoMultiplier

return AutoMultiplier
