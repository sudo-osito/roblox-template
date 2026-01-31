--// Services
local players = game:GetService("Players")

--// Variables
-- The SpawnLocation button that gives coins when touched
local button = workspace:WaitForChild("SpawnLocation")

--// Event: When the button is touched
button.Touched:Connect(function(hit)
	-- Get the player who touched the button
	local player = players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	-- Get the raw coins value stored on the player (not the display version)
	-- NOTE: This is stored directly on player, not in leaderstats
	local coins = player:WaitForChild("Coins")
	if not coins then return end
	local rebirths = player:WaitForChild("Rebirths")
	if not rebirths then return end
	local strength = player:WaitForChild("Strength")
	if not strength then return end

	-- Add 50 coins (formatted display will automatically update via the Changed connection in savedata.lua)

	coins.Value = coins.Value + 50
	strength.Value = strength.Value + 10
	
end)