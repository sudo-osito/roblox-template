local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("ScreenGui", 5)
if not ScreenGui then
    warn("ScreenGui not found in PlayerGui after 5 seconds!")
    return
end

local Offers = ScreenGui:WaitForChild("Offers")
local RouletteButton = Offers.Offer1:WaitForChild("InvisibleButton")

local SubMenus = playerGui:WaitForChild("SubMenus", 5)
if not SubMenus then
    warn("SubMenus not found in PlayerGui!")
    return
end

local RouletteGUI = SubMenus:WaitForChild("RouletteGUI")
local closeRoulette = RouletteGUI:WaitForChild("CloseRoulette")

RouletteGUI.Visible = false

RouletteButton.Activated:Connect(function()
    if RouletteGUI.Visible == true then
        RouletteGUI.Visible = false
        return
    else RouletteGUI.Visible = true
    end
end)

closeRoulette.Activated:Connect(function()
    RouletteGUI.Visible = false
end)

-- // HERE STARTS THE FUN PART \\ -- MONEY 

