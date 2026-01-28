local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- GamePass ID to robux price mapping
local GAMEPASSES = {
	[1691824103] = {robux = 199, name = "VIP"},
	[1691201385] = {robux = 599, name = "Ultra VIP"},
	[1691200287] = {robux = 3, name = "x2 Strength"},
	[1691842059] = {robux = 6, name = "x2 Coins"},
}

-- Track gamepass purchases for robux spent leaderboard
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then
		return
	end
	
	local gamePassData = GAMEPASSES[gamePassId]
	if not gamePassData then
		return
	end
	
	-- Track robux spent for leaderboard
	local robuxSpent = player:FindFirstChild("Robux Spent")
	if robuxSpent then
		robuxSpent.Value = robuxSpent.Value + gamePassData.robux
		print(player.Name .. " purchased " .. gamePassData.name .. " gamepass (" .. gamePassData.robux .. " Robux)")
	end
end)

print("GamePass Purchase Handler initialized")
