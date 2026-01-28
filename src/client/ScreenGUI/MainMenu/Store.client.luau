local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("ScreenGui", 5)
if not ScreenGui then
    warn("ScreenGui not found in PlayerGui after 5 seconds!")
    return
end

local MainMenu = ScreenGui:WaitForChild("MainMenu")
local StoreFrame = MainMenu:WaitForChild("StoreFrame")
local StoreButton = StoreFrame:WaitForChild("InvisibleButton")

local SubMenus = playerGui:WaitForChild("SubMenus", 5)
if not SubMenus then
    warn("SubMenus not found in PlayerGui!")
    return
end

local StoreGUI = SubMenus:WaitForChild("StoreGUI")
local closeStoreGUI = StoreGUI:WaitForChild("CloseStore")

StoreGUI.Visible = false

StoreButton.MouseButton1Click:Connect(function()
    StoreGUI.Visible = true
end)

closeStoreGUI.MouseButton1Click:Connect(function()
    StoreGUI.Visible = false
end)

-- // HERE STARTS THE FUN PART \\ -- MONEY 

local VIP = SubMenus.StoreGUI.ScrollingFrame.StoreOffer1
local VIPBUY = VIP.BuyButtonFrame.RealBuyButton

VIPBUY.MouseButton1Click:Connect(function()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1691824103)
end)