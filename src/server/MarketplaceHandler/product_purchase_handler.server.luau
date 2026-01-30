local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Product ID to reward mapping
local PRODUCTS = {
	[3524349207] = {coins = 1000, robux = 9, name = "1k Coins"},
	[3524349395] = {coins = 10000, robux = 29, name = "10k Coins"},
	[3524349600] = {coins = 50000, robux = 67, name = "50k Coins"},
	[3524349778] = {coins = 100000, robux = 99, name = "100k Coins"},
	[3524350143] = {coins = 500000, robux = 349, name = "500k Coins"},
	[3524350377] = {coins = 1000000, robux = 649, name = "1m Coins"},
	[1693043785] = {coins = 2000, robux = 9, name = "Starter Pack"},
	[1692813873] = {coins = 6000, robux = 39, name = "Pro Starter Pack"},
	[3525290187] = {skipRebirth = true, robux = 29, name = "Skip Rebirth"},
	[3525842684] = {rouletteSpin = true, robux = 19, name = "Roulette Spin"},
}

-- ProcessReceipt callback function
local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	
	-- Player left before receipt was processed
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Get product information
	local productId = receiptInfo.ProductId
	local productData = PRODUCTS[productId]
	
	if not productData then
		warn("Unknown product purchased: " .. productId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Get player's raw coins value (stored directly on player, not in leaderstats)
	local coins = player:FindFirstChild("Coins")
	if not coins then
		warn("Player " .. player.Name .. " does not have Coins stat!")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Handle skip rebirth product
	if productData.skipRebirth then
		local rebirths = player:FindFirstChild("Rebirths")
		if rebirths then
			-- Reset coins and strength to 0
			coins.Value = 0
			local strength = player:FindFirstChild("Strength")
			if strength then
				strength.Value = 0
			end
			
			-- Increment rebirth count (MaxCoins and MaxStrength stay unchanged)
			rebirths.Value = rebirths.Value + 1
			
			print(player.Name .. " used Skip Rebirth! Now has " .. rebirths.Value .. " rebirths")
		end
		
		-- Track robux spent
		local robuxSpent = player:FindFirstChild("Robux Spent")
		if robuxSpent and productData.robux then
			robuxSpent.Value = robuxSpent.Value + productData.robux
		end
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	-- Handle roulette spin product
	if productData.rouletteSpin then
		-- Wait for RouletteHandler to be available
		local maxWait = 0
		while not _G.RouletteHandlePaidSpin and maxWait < 50 do
			task.wait(0.1)
			maxWait = maxWait + 1
		end
		
		if _G.RouletteHandlePaidSpin then
			_G.RouletteHandlePaidSpin(player)
		else
			warn("RouletteHandler not loaded! Cannot process paid spin")
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		-- Track robux spent
		local robuxSpent = player:FindFirstChild("Robux Spent")
		if robuxSpent and productData.robux then
			robuxSpent.Value = robuxSpent.Value + productData.robux
		end
		
		print(player.Name .. " purchased a Roulette Spin!")
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	-- Grant the coins WITHOUT multipliers (purchased coins should not be multiplied)
	-- Wait for AutoMultiplier to be available
	local maxWait = 0
	while not _G.AutoMultiplier and maxWait < 50 do
		task.wait(0.1)
		maxWait = maxWait + 1
	end
	
	if _G.AutoMultiplier then
		_G.AutoMultiplier.addCoinsRaw(player, productData.coins)
	else
		-- Fallback: add directly (shouldn't happen but just in case)
		coins.Value = coins.Value + productData.coins
	end
	
	-- Track robux spent for leaderboard
	local robuxSpent = player:FindFirstChild("Robux Spent")
	if robuxSpent and productData.robux then
		robuxSpent.Value = robuxSpent.Value + productData.robux
	end
	
	print(player.Name .. " purchased " .. productData.name .. " and received " .. productData.coins .. " coins")
	
	-- Return PurchaseGranted to finalize the transaction
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Set the callback
MarketplaceService.ProcessReceipt = processReceipt

