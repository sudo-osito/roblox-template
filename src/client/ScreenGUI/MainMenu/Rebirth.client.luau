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



