local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local MultiplierManager = require(ReplicatedStorage.Shared.MultiplierManager)

-- Initialize the multiplier manager for this player
MultiplierManager.initializePlayer(player)

-- Wait for GUI elements
local CoinMultiplierText = player.PlayerGui:WaitForChild("ScreenGui").PlayerMultipliers.CoinMultiplier:WaitForChild("MultiplierText")
local StrengthMultiplierText = player.PlayerGui.ScreenGui.PlayerMultipliers.StrengthMultiplier:WaitForChild("MultiplierText")

-- Track event multipliers (updated by server)
local eventCoinMultiplier = 1
local eventStrengthMultiplier = 1

-- Function to update the displayed multipliers
local function updateMultipliers()
	local multipliers = MultiplierManager.getAllMultipliers(player)
	
	-- Apply event multipliers on top of everything
	local totalCoinMult = multipliers.TotalCoin * eventCoinMultiplier
	local totalStrengthMult = multipliers.TotalStrength * eventStrengthMultiplier
	
	CoinMultiplierText.Text = "x" .. tostring(totalCoinMult)
	StrengthMultiplierText.Text = "x" .. tostring(totalStrengthMult)
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

-- Listen for event notifications (updates event multipliers)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = Shared:WaitForChild("RemoteEvents")
local EventNotification = RemoteEvents:WaitForChild("EventNotification")

EventNotification.OnClientEvent:Connect(function(message, isEnding)
	-- Parse event multipliers from the message
	if message:find("DOUBLE COINS") then
		eventCoinMultiplier = 2
		eventStrengthMultiplier = 1
	elseif message:find("TRIPLE COINS") then
		eventCoinMultiplier = 3
		eventStrengthMultiplier = 1
	elseif message:find("DOUBLE STRENGTH") then
		eventCoinMultiplier = 1
		eventStrengthMultiplier = 2
	elseif message:find("SUPER EVENT") then
		eventCoinMultiplier = 2
		eventStrengthMultiplier = 2
	elseif isEnding then
		-- Event ended, reset multipliers
		eventCoinMultiplier = 1
		eventStrengthMultiplier = 1
	end
	
	updateMultipliers()
end)

-- Periodic update every 5 seconds as fallback (catches any missed changes)
task.spawn(function()
	while player.Parent do
		task.wait(5)
		updateMultipliers()
	end
end)