local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("ScreenGui", 5)
if not ScreenGui then
    warn("ScreenGui not found in PlayerGui after 5 seconds!")
    return
end

local MainMenu = ScreenGui:WaitForChild("MainMenu")
local VIPFrame = MainMenu:WaitForChild("VIPFrame")
local VIPButton = VIPFrame:WaitForChild("InvisibleButton")

local SubMenus = playerGui:WaitForChild("SubMenus", 5)
if not SubMenus then
    warn("SubMenus not found in PlayerGui!")
    return
end

local VIPGUI = SubMenus:WaitForChild("VIPGUI")
local closeVIPGUI = VIPGUI:WaitForChild("CloseVIP")

VIPGUI.Visible = false

VIPButton.Activated:Connect(function()
    if VIPGUI.Visible == true then
        VIPGUI.Visible = false
        return
    else VIPGUI.Visible = true
    end
end)

closeVIPGUI.Activated:Connect(function()
    VIPGUI.Visible = false
end)

-- // HERE STARTS THE FUN PART \\ -- MONEY 

local MarketplaceService = game:GetService("MarketplaceService")

local VIP = SubMenus.VIPGUI:WaitForChild("StoreOffer1")
local VIPBUY = VIP.BuyButtonFrame:WaitForChild("RealBuyButton")

local ULTRAVIP = SubMenus.VIPGUI:WaitForChild("StoreOffer2")
local ULTRAVIPBUY = ULTRAVIP.BuyButtonFrame:WaitForChild("RealBuyButton")

-- // FUNCTIONS TO BUY ---------------------------------------------------

local function BuyVIP()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1691824103)
end

local function BuyUltraVIP()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1691201385)
end

-- // BUTTON CONNECTIONS ---------------------------------------------------

VIPBUY.Activated:Connect(function()
    BuyVIP()
end)

ULTRAVIPBUY.Activated:Connect(function()
    BuyUltraVIP()
end)

-- // CHECK IF PASS OWNED FOR TEXT UPDATE ---------------------------------------------------

local VIPIconPart1 = VIP.BuyButtonFrame.CustomGUIStroke.Robux1
local VIPIconPart2 = VIP.BuyButtonFrame.CustomGUIStroke.Robux2
local VIPTextLabel1 = VIP.BuyButtonFrame.CustomGUIStroke.TextLabel1
local VIPTextLabel2 = VIP.BuyButtonFrame.CustomGUIStroke.TextLabel2

if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1691824103) then
    VIPIconPart1.Visible = false
    VIPIconPart2.Visible = false
    VIPTextLabel1.Text = "OWNED"
    VIPTextLabel2.Visible = false
end

-- -----------

local UltraVIPIconPart1 = ULTRAVIP.BuyButtonFrame.CustomGUIStroke.Robux1
local UltraVIPIconPart2 = ULTRAVIP.BuyButtonFrame.CustomGUIStroke.Robux2
local UltraVIPTextLabel1 = ULTRAVIP.BuyButtonFrame.CustomGUIStroke.TextLabel1
local UltraVIPTextLabel2 = ULTRAVIP.BuyButtonFrame.CustomGUIStroke.TextLabel2

if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1691201385) then
    UltraVIPIconPart1.Visible = false
    UltraVIPIconPart2.Visible = false
    UltraVIPTextLabel1.Text = "OWNED"
    UltraVIPTextLabel2.Visible = false
end