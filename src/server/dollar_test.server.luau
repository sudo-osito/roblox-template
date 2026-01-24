local players = game:GetService("Players")
local button = workspace:WaitForChild("SpawnLocation")

button.Touched:Connect(function(hit)
	local player = players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	local leaderstats = player:WaitForChild("leaderstats")
	if not leaderstats then return end
	
	local coins = leaderstats:WaitForChild("Coins")
	if not coins then return end

	coins.Value += 50
	
end)