-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variables
local ScreenGUI = playerGui:WaitForChild("ScreenGui")
local CurrenciesGUI = ScreenGUI:WaitForChild("Currencies")
local CoinsText = CurrenciesGUI.ScreenGui.Coins:WaitForChild("CoinAmmount")

-- Function to format coins display
local function formatCoins(coins)
	local suffixes = { "k", "m", "b", "t", "q" }
	local divisor = 1000
	
	if coins < 1000 then
		return tostring(coins)
	end
	
	for i, suffix in ipairs(suffixes) do
		if coins < divisor ^ (i + 1) then
			local value = coins / (divisor ^ i)
			return string.format("%.1f", value) .. suffix
		end
	end
	
	-- If larger than quadrillions
	local value = coins / (divisor ^ #suffixes)
	return string.format("%.1f", value) .. suffixes[#suffixes]
end

-- Function to update the coins display
local function updateCoinsDisplay()
	local coins = player:FindFirstChild("Coins")
	if coins then
		CoinsText.Text = "$" .. formatCoins(coins.Value)
	end
end

-- Wait for coins to exist
local coins = player:WaitForChild("Coins")

-- Initial update
updateCoinsDisplay()

-- Update whenever coins change
coins.Changed:Connect(updateCoinsDisplay)

local BuyCoinsButton = CurrenciesGUI.ScreenGui.Coins:WaitForChild("buyCoinsButton")

local StoreGUI = player.PlayerGui.SubMenus:WaitForChild("StoreGUI")

BuyCoinsButton.Activated:Connect(function()
	if StoreGUI.Visible == true then
		StoreGUI.Visible = false
	else StoreGUI.Visible = true
	end
end)