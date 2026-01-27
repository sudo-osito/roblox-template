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

RebirthButton.MouseButton1Click:Connect(function()
    RebirthGUI.Visible = true
end)

closeRebirthGUI.MouseButton1Click:Connect(function()
    RebirthGUI.Visible = false
end)