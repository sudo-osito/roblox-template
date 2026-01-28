local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")
local offers = screenGui:WaitForChild("Offers")

local Offer2_button = offers.Offer2.InvisibleButton
local Offer3_button = offers.Offer3.InvisibleButton

Offer2_button.MouseButton1Click:Connect(function()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1691200287)
end)

Offer3_button.MouseButton1Click:Connect(function()
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 1691842059)
end)