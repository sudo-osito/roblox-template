local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("ScreenGui", 5)
if not ScreenGui then
    warn("ScreenGui not found in PlayerGui after 5 seconds!")
    return
end

local MainMenu = ScreenGui:WaitForChild("MainMenu")
local RebirthFrame = MainMenu:WaitForChild("RebirthFrame")
local RebirthButton = RebirthFrame:WaitForChild("InvisibleButton")

local SubMenus = playerGui:WaitForChild("SubMenus", 5)
if not SubMenus then
    warn("SubMenus not found in PlayerGui!")
    return
end

local RebirthGUI = SubMenus:WaitForChild("RebirthGUI")
local closeRebirthGUI = RebirthGUI:WaitForChild("CloseRebirth")

RebirthGUI.Visible = false

RebirthButton.Activated:Connect(function()
    if RebirthGUI.Visible == true then
        RebirthGUI.Visible = false
        return
    else RebirthGUI.Visible = true
    end
end)

closeRebirthGUI.Activated:Connect(function()
    RebirthGUI.Visible = false
end)

-- // HERE STARTS THE FUN PART \\ -- MONEY 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RebirthButton = RebirthGUI:WaitForChild("RebirthInvisButton")
local SkipRebirthButton = RebirthGUI:WaitForChild("SkipRebirthInvisButton")

local SKIP_REBIRTH_PRODUCT_ID = 3525290187

RebirthButton.Activated:Connect(function()
    local RebirthEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemoteEvents"):WaitForChild("RebirthRequest")
    RebirthEvent:FireServer()
end)

SkipRebirthButton.Activated:Connect(function()
    -- Prompt purchase of skip rebirth product
    MarketplaceService:PromptProductPurchase(player, SKIP_REBIRTH_PRODUCT_ID)
end)

-- // GUI VISUAL STUFF ========================================================

local InformationFrame = RebirthGUI:WaitForChild("Information")
local From_RebirthLabel = InformationFrame.From:WaitForChild("RebirthLabel")
local From_MiltiplierLabel = InformationFrame.From:WaitForChild("MultiplierLabel")

local To_RebirthLevel = InformationFrame.To:WaitForChild("RebirthLabel")
local To_MultiplierLevel = InformationFrame.To:WaitForChild("MultiplierLabel")

-- Update rebirth information display
local function updateRebirthInfo()
    local rebirths = player:FindFirstChild("Rebirths")
    if not rebirths and player:FindFirstChild("leaderstats") then
        rebirths = player.leaderstats:FindFirstChild("Rebirths")
    end
    
    if not rebirths then 
        return 
    end
    
    local currentRebirths = rebirths.Value
    local nextRebirths = currentRebirths + 1
    
    -- Calculate multipliers (formula: 1 + rebirths * 0.5)
    local currentMultiplier = 1 + (currentRebirths * 0.5)
    local nextMultiplier = 1 + (nextRebirths * 0.5)
    
    -- Update display labels
    From_RebirthLabel.Text = "REBIRTH "..currentRebirths
    From_MiltiplierLabel.Text = currentMultiplier.."x COINS"
    
    To_RebirthLevel.Text = "REBIRTH "..nextRebirths
    To_MultiplierLevel.Text = nextMultiplier.."x COINS"
end

-- Update info when GUI opens
local mainRebirthButton = RebirthFrame:WaitForChild("InvisibleButton")
mainRebirthButton.Activated:Connect(function()
    if RebirthGUI.Visible then
        updateRebirthInfo()
    end
end)

-- Update info when rebirth count changes
task.spawn(function()
    task.wait(2)
    
    local playerRebirths = player:FindFirstChild("Rebirths")
    if not playerRebirths and player:FindFirstChild("leaderstats") then
        playerRebirths = player.leaderstats:FindFirstChild("Rebirths")
    end
    
    if playerRebirths then
        playerRebirths.Changed:Connect(updateRebirthInfo)
        updateRebirthInfo()
    end
end)

-- UPDATE REBIRTH PROGRESS BARS ==================================  

local CoinProgressBar = RebirthGUI.ProgressBars.CoinProgress.RealProgressBarBackground:WaitForChild("StudTexture")
local StrengthProgressBar = RebirthGUI.ProgressBars.StrengthProgress.RealProgressBarBackground:WaitForChild("StudTexture")

local x_outof_x_coins = RebirthGUI.ProgressBars.CoinProgress:WaitForChild("ProgressBarLabel")
local x_outof_x_strength = RebirthGUI.ProgressBars.StrengthProgress:WaitForChild("ProgressBarLabel")

-- Wait for player data to load from server
local playerCoins = player:WaitForChild("Coins", 10)
local playerStrength = player:WaitForChild("Strength", 10)
local playerRebirths = player:WaitForChild("Rebirths", 10)

if not playerCoins or not playerStrength or not playerRebirths then
	warn("Failed to load player data for progress bars!")
	return
end

-- Configuration (must match server config)
local REBIRTH_CONFIG = {
	baseCoins = 100000,
	baseStrength = 1500,
	coinsMultiplier = 2.5,
	strengthMultiplier = 1.5,
}

-- Calculate required coins/strength for next rebirth (same formula as server)
local function calculateRequirements(currentRebirths)
	local cappedRebirths = math.min(currentRebirths, 10)
	local requiredCoins = math.floor(REBIRTH_CONFIG.baseCoins * (REBIRTH_CONFIG.coinsMultiplier ^ cappedRebirths))
	local requiredStrength = math.floor(REBIRTH_CONFIG.baseStrength * (REBIRTH_CONFIG.strengthMultiplier ^ cappedRebirths))
	requiredCoins = math.min(requiredCoins, 9e15)
	requiredStrength = math.min(requiredStrength, 9e15)
	return requiredCoins, requiredStrength
end

-- Format large numbers (e.g., 1000 -> "1k", 1000000 -> "1m")
local function formatNumber(num)
	if num < 1000 then
		return tostring(math.floor(num))
	elseif num < 1000000 then
		return string.format("%.1fk", num / 1000)
	elseif num < 1000000000 then
		return string.format("%.1fm", num / 1000000)
	else
		return string.format("%.1fb", num / 1000000000)
	end
end

-- Update progress bars display
local function updateProgressBars()
	if not playerRebirths then return end
	
	local currentRebirths = playerRebirths.Value
	local requiredCoins, requiredStrength = calculateRequirements(currentRebirths)
	
	-- Calculate progress (0 to 1)
	local coinProgress = math.min(playerCoins.Value / requiredCoins, 1)
	local strengthProgress = math.min(playerStrength.Value / requiredStrength, 1)
	
	-- Update progress bar sizes (X Scale from 0 to 1)
	CoinProgressBar.Size = UDim2.new(coinProgress, 0, 1, 0)
	StrengthProgressBar.Size = UDim2.new(strengthProgress, 0, 1, 0)
	
	-- Update text labels
	x_outof_x_coins.Text = formatNumber(playerCoins.Value) .. " / " .. formatNumber(requiredCoins)
	x_outof_x_strength.Text = formatNumber(playerStrength.Value) .. " / " .. formatNumber(requiredStrength)
end

-- Connect to value changes
playerCoins.Changed:Connect(updateProgressBars)
playerStrength.Changed:Connect(updateProgressBars)
playerRebirths.Changed:Connect(updateProgressBars)

-- Initial update
updateProgressBars()

