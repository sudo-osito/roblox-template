local players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Leaderboard = DSS:GetOrderedDataStore("CoinsBoard1")

--// Variables
local rig = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("Rig")
local first_place_tag = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("FirstPlaceTag")
local animationToPlay = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("AnimationToPlay")
local currentAnimTrack = nil

--// Functions
local function getTop1Player()
    local isAscending = false
    local pageSize = 1
    local pages = Leaderboard:GetSortedAsync(isAscending, pageSize)
    local top1 = pages:GetCurrentPage()

    if #top1 < 1 then
        print("[TOP1] No players found in leaderboard")
        return nil
    end
    
    local data = top1[1]
    local keyParts = data.key:split('_')
    local userId = tonumber(keyParts[2])
    
    if not userId then
        print("[TOP1] Failed to parse userId from key: " .. data.key)
        return nil
    end
    
    local player = players:GetPlayerByUserId(userId)
    if not player then
        print("[TOP1] Top player (UserId: " .. userId .. ") is not in game")
        return nil
    end
    
    print("[TOP1] Found player: " .. player.Name .. " with UserId: " .. userId)
    return player
end



local function play_animation_for_top1_player()
    local top1Player = getTop1Player()
    
    if not top1Player then
        print("[ANIM] No valid top1 player found, skipping animation")
        return
    end

    -- Stop old animation
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop() end)
    end

    -- Apply player appearance and play animation
    local success, humanoidDesc = pcall(function()
        return players:GetHumanoidDescriptionFromUserId(top1Player.UserId)
    end)
    
    if not success or not humanoidDesc then
        print("[ANIM] Failed to get humanoid description for " .. top1Player.Name)
        print("[ANIM] Success: " .. tostring(success) .. " | HumanoidDesc: " .. tostring(humanoidDesc))
        return
    end
    
    pcall(function()
        -- Apply the description (which includes shirt and pants)
        rig.Humanoid:ApplyDescription(humanoidDesc)
        
        -- Wait for new shirt/pants to be created
        task.wait(0.1)
        
        -- Only destroy OLD shirt/pants that aren't from the new description
        -- Find newly created shirt/pants by checking their parent
        local newShirt = rig:FindFirstChild("Shirt")
        local newPants = rig:FindFirstChild("Pants")
        
        -- If no shirt/pants were created by description, the player might not have them
        -- In that case, keep the original ones
        if newShirt or newPants then
            -- Destroy any duplicates in descendants
            for _, item in pairs(rig:FindDescendantsOfClass("Shirt")) do
                if item ~= newShirt then
                    item:Destroy()
                end
            end
            for _, item in pairs(rig:FindDescendantsOfClass("Pants")) do
                if item ~= newPants then
                    item:Destroy()
                end
            end
        end
        
        print("[ANIM] Applied appearance for " .. top1Player.Name)
    end)
    
    if not animationToPlay or not animationToPlay:IsA("Animation") then
        print("[ANIM] Invalid animation object: " .. tostring(animationToPlay))
        return
    end
    
    local animSuccess, newTrack = pcall(function()
        return rig.Humanoid:LoadAnimation(animationToPlay)
    end)
    
    if not animSuccess or not newTrack then
        print("[ANIM] Failed to load animation")
        return
    end
    
    currentAnimTrack = newTrack
    currentAnimTrack:Play()
    print("[ANIM] Started playing animation for " .. top1Player.Name)
end

task.spawn(function()
    while true do
        task.wait(5)
        play_animation_for_top1_player()
    end
end)