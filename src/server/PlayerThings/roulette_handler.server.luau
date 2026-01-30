--// Roulette Handler
--// Handles roulette spin requests and prize distribution
--// Free spins are limited per session, paid spins use dev products

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for AutoMultiplier to be available
local maxWait = 0
while not _G.AutoMultiplier and maxWait < 100 do
	task.wait(0.1)
	maxWait = maxWait + 1
end

if not _G.AutoMultiplier then
	warn("AutoMultiplier not loaded! Roulette prizes may not work correctly")
end

-- Create RemoteEvent structure if it doesn't exist
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = Shared:FindFirstChild("RemoteEvents")
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = Shared
end

local RouletteSpinEvent = RemoteEvents:FindFirstChild("RouletteSpinRequest")
if not RouletteSpinEvent then
	RouletteSpinEvent = Instance.new("RemoteEvent")
	RouletteSpinEvent.Name = "RouletteSpinRequest"
	RouletteSpinEvent.Parent = RemoteEvents
end

local RouletteClaimEvent = RemoteEvents:FindFirstChild("RouletteClaimPrize")
if not RouletteClaimEvent then
	RouletteClaimEvent = Instance.new("RemoteEvent")
	RouletteClaimEvent.Name = "RouletteClaimPrize"
	RouletteClaimEvent.Parent = RemoteEvents
end

-- Prize configuration matching the client
local PRIZES = {
	["Prize1"] = {prize = "Coins", amount = 1000, location = NumberRange.new(1, 45)},
	["Prize2"] = {prize = "Coins", amount = 1000, location = NumberRange.new(46, 90)},
	["Prize3"] = {prize = "Strength", amount = 500, location = NumberRange.new(91, 135)},
	["Prize4"] = {prize = "Coins", amount = 1000, location = NumberRange.new(136, 180)},
	["Prize5"] = {prize = "Strength", amount = 100, location = NumberRange.new(181, 225)},
	["Prize6"] = {prize = "Coins", amount = 10000, location = NumberRange.new(226, 270)},
	["Prize7"] = {prize = "Coins", amount = 1000, location = NumberRange.new(271, 315)},
	["Prize8"] = {prize = "Rebirths", amount = 1, location = NumberRange.new(316, 360)},
}

-- Track pending prizes (prizes that need to be claimed after spin animation)
local pendingPrizes = {}

-- Dev Product ID for paid spins
local PAID_SPIN_PRODUCT_ID = 3525842684

-- Handle free spin requests
RouletteSpinEvent.OnServerEvent:Connect(function(player, spinType)
	if spinType == "free" then
		-- Check if player has free spins
		local freeSpins = player:FindFirstChild("FreeSpins")
		if not freeSpins then
			warn("Player " .. player.Name .. " does not have FreeSpins value!")
			return
		end
		
		if freeSpins.Value <= 0 then
			-- No free spins available
			return
		end
		
		-- Deduct one free spin
		freeSpins.Value = freeSpins.Value - 1
		
		-- Generate random result
		local randomNumber = math.random(1, 360)
		
		-- Send back to client with random result
		RouletteSpinEvent:FireClient(player, "spin_approved", randomNumber, freeSpins.Value)
		
		-- Store the result for this player to claim later
		pendingPrizes[player.UserId] = randomNumber
		
	elseif spinType == "paid" then
		-- Prompt purchase for paid spin
		local success = pcall(function()
			MarketplaceService:PromptProductPurchase(player, PAID_SPIN_PRODUCT_ID)
		end)
		
		if not success then
			warn("Failed to prompt product purchase for " .. player.Name)
		end
	end
end)

-- Handle prize claiming after spin animation completes
RouletteClaimEvent.OnServerEvent:Connect(function(player)
	local pendingNumber = pendingPrizes[player.UserId]
	if not pendingNumber then
		warn("Player " .. player.Name .. " tried to claim prize but has no pending prize!")
		return
	end
	
	-- Find which prize they won
	local selectedPrize = nil
	for prizeName, prizeInfo in pairs(PRIZES) do
		if pendingNumber >= prizeInfo.location.Min and pendingNumber <= prizeInfo.location.Max then
			selectedPrize = prizeInfo
			break
		end
	end
	
	if not selectedPrize then
		warn("Could not determine prize for number " .. pendingNumber)
		return
	end
	
	-- Award the prize
	local success = false
	if selectedPrize.prize == "Coins" then
		if _G.AutoMultiplier then
			_G.AutoMultiplier.addCoinsRaw(player, selectedPrize.amount)
			success = true
		end
	elseif selectedPrize.prize == "Strength" then
		if _G.AutoMultiplier then
			_G.AutoMultiplier.addStrengthRaw(player, selectedPrize.amount)
			success = true
		end
	elseif selectedPrize.prize == "Rebirths" then
		local rebirths = player:FindFirstChild("Rebirths")
		if rebirths then
			rebirths.Value = rebirths.Value + selectedPrize.amount
			success = true
		end
	end
	
	if success then
		print(player.Name .. " won " .. selectedPrize.amount .. " " .. selectedPrize.prize .. " from roulette!")
		-- Clear the pending prize
		pendingPrizes[player.UserId] = nil
	else
		warn("Failed to award prize to " .. player.Name)
	end
end)

-- Handle paid spin purchases (add this to product purchase handler)
-- We'll store this in a global so the product purchase handler can use it
_G.RouletteHandlePaidSpin = function(player)
	-- Generate random result
	local randomNumber = math.random(1, 360)
	
	-- Send back to client with random result
	RouletteSpinEvent:FireClient(player, "paid_spin_approved", randomNumber, -1)
	
	-- Store the result for this player to claim later
	pendingPrizes[player.UserId] = randomNumber
end

-- Clean up pending prizes when player leaves
Players.PlayerRemoving:Connect(function(player)
	if pendingPrizes[player.UserId] then
		pendingPrizes[player.UserId] = nil
	end
end)

print("Roulette Handler loaded successfully!")
