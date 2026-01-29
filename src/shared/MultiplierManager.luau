local MultiplierManager = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- //CONFIGURATION

local COIN_GAMEPASSES = {
    {id = 1691200287, multiplier = 2},
    {id = 1693043785, multiplier = 2},
    {id = 1692813873, multiplier = 3},
    {id = 1691824103, multiplier = 4},
    {id = 1691201385, multiplier = 8},
}

local STRENGTH_GAMEPASSES = {
    {id = 1691842059, multiplier = 2},
    {id = 1693043785, multiplier = 2},
    {id = 1692813873, multiplier = 3},
    {id = 1691824103, multiplier = 4},
    {id = 1691201385, multiplier = 8},
}

local REBIRTH_MULTIPLIER_PER_LEVEL = 0.5

-- Cache for gamepass ownership to avoid repeated API calls
local gamepassCache = {}

-- Cache for calculated multipliers per player
local multiplierCache = {}

-- Event connections per player (for cleanup)
local playerConnections = {}

-- //HELPER FUNCTIONS

local function checkGamepassOwnership(player, gamepassId)
    local playerId = player.UserId
    local cacheKey = playerId .. "_" .. gamepassId
    
    -- Return cached result if available
    if gamepassCache[cacheKey] ~= nil then
        return gamepassCache[cacheKey]
    end
    
    -- Check ownership with error handling
    local success, ownsPass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(playerId, gamepassId)
    end)
    
    local result = success and ownsPass or false
    gamepassCache[cacheKey] = result
    
    return result
end

local function calculateGamepassMultiplier(player, gamepasses)
    local highestMultiplier = 1
    
    for _, gamepass in ipairs(gamepasses) do
        if checkGamepassOwnership(player, gamepass.id) then
            -- Only keep the highest multiplier, don't stack them
            if gamepass.multiplier > highestMultiplier then
                highestMultiplier = gamepass.multiplier
            end
        end
    end
    
    return highestMultiplier
end

-- //PUBLIC FUNCTIONS

function MultiplierManager.checkCoinMultiplier(player)
    local playerId = player.UserId
    if multiplierCache[playerId] and multiplierCache[playerId].coin then
        return multiplierCache[playerId].coin
    end
    
    local mult = calculateGamepassMultiplier(player, COIN_GAMEPASSES)
    
    if not multiplierCache[playerId] then
        multiplierCache[playerId] = {}
    end
    multiplierCache[playerId].coin = mult
    
    return mult
end

function MultiplierManager.checkStrengthMultiplier(player)
    local playerId = player.UserId
    if multiplierCache[playerId] and multiplierCache[playerId].strength then
        return multiplierCache[playerId].strength
    end
    
    local mult = calculateGamepassMultiplier(player, STRENGTH_GAMEPASSES)
    
    if not multiplierCache[playerId] then
        multiplierCache[playerId] = {}
    end
    multiplierCache[playerId].strength = mult
    
    return mult
end

function MultiplierManager.checkRebirthMultiplier(player)
    local success, rebirths = pcall(function()
        return player.leaderstats:WaitForChild("Rebirths", 5)
    end)
    
    if not success or not rebirths then
        warn("Failed to get Rebirths for player:", player.Name)
        return 1
    end
    
    return 1 + (rebirths.Value * REBIRTH_MULTIPLIER_PER_LEVEL)
end

function MultiplierManager.checkGlobalMultiplier(player)
    local multiplier = 1
    
    -- Add your global multiplier logic here (events, VIP, etc.)
    -- Example: if isDoubleWeekend then multiplier *= 2 end
    
    return multiplier
end

function MultiplierManager.calculateGain(player, baseAmount, gainType)
    local globalMult = MultiplierManager.checkGlobalMultiplier(player)
    
    if gainType == "Coins" then
        local coinMult = MultiplierManager.checkCoinMultiplier(player)
        local rebirthMult = MultiplierManager.checkRebirthMultiplier(player)
        return math.floor(baseAmount * coinMult * rebirthMult * globalMult)
    elseif gainType == "Strength" then
        local strengthMult = MultiplierManager.checkStrengthMultiplier(player)
        return math.floor(baseAmount * strengthMult * globalMult)
    end
    
    return baseAmount
end

-- Get all multipliers for display purposes
function MultiplierManager.getAllMultipliers(player)
    local coinMult = MultiplierManager.checkCoinMultiplier(player)
    local strengthMult = MultiplierManager.checkStrengthMultiplier(player)
    local rebirthMult = MultiplierManager.checkRebirthMultiplier(player)
    local globalMult = MultiplierManager.checkGlobalMultiplier(player)
    
    return {
        Coin = coinMult,
        Strength = strengthMult,
        Rebirth = rebirthMult,
        Global = globalMult,
        TotalCoin = coinMult * rebirthMult * globalMult,
        TotalStrength = strengthMult * globalMult,
    }
end

-- Clear cache for a specific player (call on player leave)
function MultiplierManager.clearPlayerCache(player)
    local playerId = player.UserId
    
    -- Clear gamepass cache
    for key in pairs(gamepassCache) do
        if string.find(key, "^" .. playerId .. "_") then
            gamepassCache[key] = nil
        end
    end
    
    -- Clear multiplier cache
    if multiplierCache[playerId] then
        multiplierCache[playerId] = nil
    end
    
    -- Disconnect event listeners
    if playerConnections[playerId] then
        for _, connection in pairs(playerConnections[playerId]) do
            connection:Disconnect()
        end
        playerConnections[playerId] = nil
    end
end

-- Initialize player with automatic multiplier updates
function MultiplierManager.initializePlayer(player)
    local playerId = player.UserId
    playerConnections[playerId] = {}
    
    -- Pre-cache gamepasses
    task.spawn(function()
        calculateGamepassMultiplier(player, COIN_GAMEPASSES)
        calculateGamepassMultiplier(player, STRENGTH_GAMEPASSES)
    end)
    
    -- Listen for rebirth changes (invalidates coin multiplier)
    local rebirthConnection = player:WaitForChild("Rebirths").Changed:Connect(function()
        -- Clear multiplier cache on rebirth change
        if multiplierCache[playerId] then
            multiplierCache[playerId].coin = nil
        end
    end)
    table.insert(playerConnections[playerId], rebirthConnection)
    
    -- Listen for gamepass purchases (client-side only)
    if game:GetService("RunService"):IsClient() and player == Players.LocalPlayer then
        local purchaseConnection = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(purchaser, gamePassId, wasPurchased)
            if purchaser == player and wasPurchased then
                -- Clear caches to force fresh check
                MultiplierManager.clearPlayerCache(player)
                task.wait(0.5)
                -- Pre-cache again
                MultiplierManager.initializePlayer(player)
            end
        end)
        table.insert(playerConnections[playerId], purchaseConnection)
    end
end

return MultiplierManager
