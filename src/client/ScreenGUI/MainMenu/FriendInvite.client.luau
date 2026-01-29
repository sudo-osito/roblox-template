local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("ScreenGui")
local InviteFriendButton = ScreenGui.MainMenu.FriendInvite.InvisibleButton

local DisplayedFriendBonus = ScreenGui.MainMenu.FriendInvite.InvisibleButton.StudTexture:WaitForChild("DisplayedBonus")

-- Check if player can send game invites
local canInvite = false
local success, result = pcall(function()
    return SocialService:CanSendGameInviteAsync(player)
end)

if success then
    canInvite = result
end

if not canInvite then
    InviteFriendButton.Visible = false
    return
end

-- Function to count friends in the game and update bonus display
local function updateFriendBonus()
    local friendsInGame = 0
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local success, isFriend = pcall(function()
                return player:IsFriendsWithAsync(otherPlayer.UserId)
            end)
            
            if success and isFriend then
                friendsInGame = friendsInGame + 1
            end
        end
    end
    
    local bonusPercentage = friendsInGame * 15
    DisplayedFriendBonus.Text = "+" .. bonusPercentage .. "%"
end

-- Update bonus when script starts
updateFriendBonus()

-- Update bonus when players join or leave
Players.PlayerAdded:Connect(function()
    task.wait(0.5) -- Small delay to ensure friend check works
    updateFriendBonus()
end)

Players.PlayerRemoving:Connect(updateFriendBonus)

InviteFriendButton.Activated:Connect(function()
    pcall(function()
        SocialService:PromptGameInvite(player)
    end)
end)