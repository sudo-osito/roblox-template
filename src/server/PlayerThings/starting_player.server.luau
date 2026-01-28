local players = game:GetService("Players")

local function onCharacterAdded(character)
    local highlight = Instance.new("Highlight")
    highlight.Parent = character

    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.FillTransparency = 1

    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.OutlineTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded

    character:WaitForChild("Humanoid").WalkSpeed = 30
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Handle existing players
for _, player in ipairs(players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Handle new players
players.PlayerAdded:Connect(onPlayerAdded)
