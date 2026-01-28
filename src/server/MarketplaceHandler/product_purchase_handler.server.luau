local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Product ID to reward mapping
local PRODUCTS = {
	[3524349207] = {coins = 1000, name = "1k Coins"},
	[3524349395] = {coins = 10000, name = "10k Coins"},
	[3524349600] = {coins = 50000, name = "50k Coins"},
	[3524349778] = {coins = 100000, name = "100k Coins"},
	[3524350143] = {coins = 500000, name = "500k Coins"},
	[3524350377] = {coins = 1000000, name = "1m Coins"},
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
	
	-- Grant the coins (this will automatically update the formatted display in leaderstats)
	coins.Value = coins.Value + productData.coins
	
	print(player.Name .. " purchased " .. productData.name .. " and received " .. productData.coins .. " coins")
	
	-- Return PurchaseGranted to finalize the transaction
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Set the callback
MarketplaceService.ProcessReceipt = processReceipt

print("Product Purchase Handler initialized")
