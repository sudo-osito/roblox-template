local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local MultiplierManager = require(ReplicatedStorage.Shared.MultiplierManager)

-- Initialize the multiplier manager for this player
MultiplierManager.initializePlayer(player)

-- Wait for GUI elements
local CoinMultiplierText = player.PlayerGui:WaitForChild("ScreenGui").PlayerMultipliers.CoinMultiplier:WaitForChild("MultiplierText")
local StrengthMultiplierText = player.PlayerGui.ScreenGui.PlayerMultipliers.StrengthMultiplier:WaitForChild("MultiplierText")

-- Function to update the displayed multipliers
local function updateMultipliers()
	local multipliers = MultiplierManager.getAllMultipliers(player)
	
	CoinMultiplierText.Text = "x" .. tostring(multipliers.TotalCoin)
	StrengthMultiplierText.Text = "x" .. tostring(multipliers.TotalStrength)
end

-- Initial update
updateMultipliers()

-- Update when rebirths change (affects coin multiplier)
local rebirths = player:WaitForChild("Rebirths")
rebirths.Changed:Connect(function()
	-- Just update - rebirth multiplier is NOT cached so it will recalculate automatically
	updateMultipliers()
end)

-- Listen for gamepass purchases (clears cache and updates)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(purchaser, gamePassId, wasPurchased)
	if purchaser == player and wasPurchased then
		-- Clear cache to force fresh gamepass check
		MultiplierManager.clearPlayerCache(player)
		task.wait(0.5) -- Small delay to ensure purchase is processed
		-- Re-initialize to restore event listeners
		MultiplierManager.initializePlayer(player)
		updateMultipliers()
	end
end)

-- Periodic update every 5 seconds as fallback (catches any missed changes)
task.spawn(function()
	while player.Parent do
		task.wait(5)
		updateMultipliers()
	end
end)