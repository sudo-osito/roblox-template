local players = game:GetService("Players")

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local highlight = Instance.new("Highlight")
        highlight.Parent = character

        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.FillTransparency = 1

        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.OutlineTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded


        character:WaitForChild("Humanoid").WalkSpeed = 30
    end)
end)
