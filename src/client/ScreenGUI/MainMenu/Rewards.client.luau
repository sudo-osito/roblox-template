local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("ScreenGui", 5)
if not ScreenGui then
    warn("ScreenGui not found in PlayerGui after 5 seconds!")
    return
end

local MainMenu = ScreenGui:WaitForChild("MainMenu")
local RewardsFrame = MainMenu:WaitForChild("RewardsFrame")
local RewardsButton = RewardsFrame:WaitForChild("InvisibleButton")

local SubMenus = playerGui:WaitForChild("SubMenus", 5)
if not SubMenus then
    warn("SubMenus not found in PlayerGui!")
    return
end

local RewardsGUI = SubMenus:WaitForChild("RewardsGUI")
local closeRewardsGUI = RewardsGUI:WaitForChild("CloseRewards")

RewardsGUI.Visible = false

RewardsButton.Activated:Connect(function()
    if RewardsGUI.Visible == true then
        RewardsGUI.Visible = false
        return
    else RewardsGUI.Visible = true
    end
end)

closeRewardsGUI.Activated:Connect(function()
    RewardsGUI.Visible = false
end)