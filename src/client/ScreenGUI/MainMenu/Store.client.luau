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

StoreButton.Activated:Connect(function()
    if StoreGUI.Visible == true then
        StoreGUI.Visible = false
        return
    else StoreGUI.Visible = true
    end
end)

closeStoreGUI.Activated:Connect(function()
    StoreGUI.Visible = false
end)

-- // HERE STARTS THE FUN PART \\ -- MONEY 
local MarketplaceService = game:GetService("MarketplaceService")

local VIP = SubMenus.StoreGUI.ScrollingFrame:WaitForChild("StoreOffer1")
local VIPBUY = VIP.BuyButtonFrame:WaitForChild("RealBuyButton")

local ULTRAVIP = SubMenus.StoreGUI.ScrollingFrame:WaitForChild("StoreOffer2")
local ULTRAVIPBUY = ULTRAVIP.BuyButtonFrame:WaitForChild("RealBuyButton")

local StarterPackOffer = SubMenus.StoreGUI.ScrollingFrame:WaitForChild("StoreOffer3")
local StarterPackBUY = StarterPackOffer.BuyButtonFrame:WaitForChild("RealBuyButton")

local ProStarterPackOffer = SubMenus.StoreGUI.ScrollingFrame:WaitForChild("StoreOffer4")
local ProStarterPackBUY = ProStarterPackOffer.BuyButtonFrame:WaitForChild("RealBuyButton")

-- ------

local CoinOffer1 = SubMenus.StoreGUI.ScrollingFrame.MoneyOffer:WaitForChild("Offer1")
local k1CoinsBuy = CoinOffer1.BuyButtonFrame:WaitForChild("RealBuyButton")

local CoinOffer2 = SubMenus.StoreGUI.ScrollingFrame.MoneyOffer:WaitForChild("Offer2")
local k10CoinsBuy = CoinOffer2.BuyButtonFrame:WaitForChild("RealBuyButton")

local CoinOffer3 = SubMenus.StoreGUI.ScrollingFrame.MoneyOffer:WaitForChild("Offer3")
local k50CoinsBuy = CoinOffer3.BuyButtonFrame:WaitForChild("RealBuyButton")

local CoinOffer4 = SubMenus.StoreGUI.ScrollingFrame.MoneyOffer:WaitForChild("Offer4")
local k100CoinsBuy = CoinOffer4.BuyButtonFrame:WaitForChild("RealBuyButton")

local CoinOffer5 = SubMenus.StoreGUI.ScrollingFrame.MoneyOffer:WaitForChild("Offer5")
local k500CoinsBuy = CoinOffer5.BuyButtonFrame:WaitForChild("RealBuyButton")

local CoinOffer6 = SubMenus.StoreGUI.ScrollingFrame.MoneyOffer:WaitForChild("Offer6")
local m1CoinsBuy = CoinOffer6.BuyButtonFrame:WaitForChild("RealBuyButton")


-- // FUNCTIONS TO BUY ---------------------------------------------------

local function BuyVIP()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1691824103)
end

local function BuyUltraVIP()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1691201385)
end

local function BuyStarterPack()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1693043785)
end

local function BuyProStarterPack()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1692813873)
end

-- ------

local function Buy1kCoins()
    game:GetService("MarketplaceService"):PromptProductPurchase(player, 3524349207)
end

local function Buy10kCoins()
    game:GetService("MarketplaceService"):PromptProductPurchase(player, 3524349395)
end

local function Buy50kCoins()
    game:GetService("MarketplaceService"):PromptProductPurchase(player, 3524349600)
end

local function Buy100kCoins()
    game:GetService("MarketplaceService"):PromptProductPurchase(player, 3524349778)
end

local function Buy500kCoins()
    game:GetService("MarketplaceService"):PromptProductPurchase(player, 3524350143)
end

local function Buy1mCoins()
    game:GetService("MarketplaceService"):PromptProductPurchase(player, 3524350377)
end

-- // BUTTON CONNECTIONS ---------------------------------------------------

VIPBUY.Activated:Connect(function()
    BuyVIP()
end)

ULTRAVIPBUY.Activated:Connect(function()
    BuyUltraVIP()
end)

StarterPackBUY.Activated:Connect(function()
    BuyStarterPack()
end)

ProStarterPackBUY.Activated:Connect(function()
    BuyProStarterPack()
end)

-- ------

k1CoinsBuy.Activated:Connect(function()
    Buy1kCoins()
end)

k10CoinsBuy.Activated:Connect(function()
    Buy10kCoins()
end)

k50CoinsBuy.Activated:Connect(function()
    Buy50kCoins()
end)

k100CoinsBuy.Activated:Connect(function()
    Buy100kCoins()
end)

k500CoinsBuy.Activated:Connect(function()
    Buy500kCoins()
end)

m1CoinsBuy.Activated:Connect(function()
    Buy1mCoins()
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

-- -----------

local StarterPackIconPart1 = StarterPackOffer.BuyButtonFrame.CustomGUIStroke.Robux1
local StarterPackIconPart2 = StarterPackOffer.BuyButtonFrame.CustomGUIStroke.Robux2
local StarterPackTextLabel1 = StarterPackOffer.BuyButtonFrame.CustomGUIStroke.TextLabel1
local StarterPackTextLabel2 = StarterPackOffer.BuyButtonFrame.CustomGUIStroke.TextLabel2

if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1693043785) then
    StarterPackIconPart1.Visible = false
    StarterPackIconPart2.Visible = false
    StarterPackTextLabel1.Text = "OWNED"
    StarterPackTextLabel2.Visible = false
end

-- -----------

local ProStarterPackIconPart1 = ProStarterPackOffer.BuyButtonFrame.CustomGUIStroke.Robux1
local ProStarterPackIconPart2 = ProStarterPackOffer.BuyButtonFrame.CustomGUIStroke.Robux2
local ProStarterPackTextLabel1 = ProStarterPackOffer.BuyButtonFrame.CustomGUIStroke.TextLabel1
local ProStarterPackTextLabel2 = ProStarterPackOffer.BuyButtonFrame.CustomGUIStroke.TextLabel2

if MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1692813873) then
    ProStarterPackIconPart1.Visible = false
    ProStarterPackIconPart2.Visible = false
    ProStarterPackTextLabel1.Text = "OWNED"
    ProStarterPackTextLabel2.Visible = false
end