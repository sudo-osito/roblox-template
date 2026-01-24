local players = game:GetService("Players")
local button = workspace:WaitForChild("SpawnLocation")

button.Touched:Connect(function(hit)
	local player = players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	local coins = player:WaitForChild("Coins")
	if not coins then return end

	coins.Value += 50
	
end)