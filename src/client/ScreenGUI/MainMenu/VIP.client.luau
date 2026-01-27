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

VIPButton.MouseButton1Click:Connect(function()
    VIPGUI.Visible = true
end)

closeVIPGUI.MouseButton1Click:Connect(function()
    VIPGUI.Visible = false
end)