--// Services
local players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
-- Retrieve the coins leaderboard to find the #1 player
local Leaderboard = DSS:GetOrderedDataStore("CoinsBoard1")

--// Variables
-- The rig model that will display the top 1 player's appearance
local rig = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("Rig")
-- The billboard GUI that displays the player's name and rank (preserved during updates)
local first_place_tag = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("FirstPlaceTag")
-- The animation to play on the rig (e.g., dancing animation)
local animationToPlay = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("AnimationToPlay")
-- Current playing animation (so we can stop it when switching players)
local currentAnimTrack = nil
-- Tracks which user is currently being displayed (prevents unnecessary updates)
local currentTop1UserId = nil

--// Functions
-- Gets the UserId of the player with the most coins
local function getTop1PlayerUserId()
    local isAscending = false  -- false = highest coins first
    local pageSize = 1
    -- Get the single highest-ranked entry from the leaderboard
    local pages = Leaderboard:GetSortedAsync(isAscending, pageSize)
    local top1 = pages:GetCurrentPage()

    if #top1 < 1 then
        print("[TOP1] No players found in leaderboard")
        return nil
    end
    
    -- Extract UserId from the DataStore key (format: "id_{userid}_Coins")
    local data = top1[1]
    local keyParts = data.key:split('_')
    local userId = tonumber(keyParts[2])
    
    if not userId then
        print("[TOP1] Failed to parse userId from key: " .. data.key)
        return nil
    end
    
    return userId
end

-- Updates the rig to display the top 1 player's appearance and plays their animation
-- Only updates if the top player has changed (efficient performance)
local function apply_top1_appearance_and_animation()
    local top1UserId = getTop1PlayerUserId()
    
    -- Skip if the top player hasn't changed (save performance)
    if top1UserId == currentTop1UserId then
        return
    end
    
    currentTop1UserId = top1UserId
    
    if not top1UserId then
        print("[ANIM] No valid top1 player found")
        return
    end

    -- Stop the currently playing animation before starting a new one
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop() end)
    end

    -- Get the appearance data for the top 1 player (works even if they're offline)
    local success, humanoidDesc = pcall(function()
        return players:GetHumanoidDescriptionFromUserId(top1UserId)
    end)
    
    if not success or not humanoidDesc then
        print("[ANIM] Failed to get humanoid description for UserId: " .. top1UserId)
        currentTop1UserId = nil
        return
    end
    
    -- Get the player's username for display
    local playerName = "Unknown"
    local nameSuccess, nameResult = pcall(function()
        return game:GetService("Players"):GetNameFromUserIdAsync(top1UserId)
    end)
    
    if nameSuccess and nameResult then
        playerName = nameResult
    end
    
    pcall(function()
        -- Save BillboardGui before applying description (prevents deletion)
        local head = rig:FindFirstChild("Head")
        local savedBillboards = {}
        
        if head then
            -- Clone all BillboardGuis on the head so we can restore them later
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("BillboardGui") then
                    table.insert(savedBillboards, child:Clone())
                end
            end
        end
        
        -- Remove old shirt and pants (prevents conflicts with new appearance)
        local oldShirt = rig:FindFirstChild("Shirt")
        if oldShirt then oldShirt:Destroy() end
        
        local oldPants = rig:FindFirstChild("Pants")
        if oldPants then oldPants:Destroy() end
        
        -- Apply the new player's appearance (body, face, accessories, etc)
        rig.Humanoid:ApplyDescription(humanoidDesc)
        
        -- Restore the BillboardGui so it doesn't get deleted
        head = rig:FindFirstChild("Head")
        if head then
            for _, billboard in pairs(savedBillboards) do
                billboard.Parent = head
            end
        end
        
        -- Set the display name above the character
        rig.Humanoid.DisplayName = playerName
        
        print("[ANIM] Applied appearance for UserId: " .. top1UserId .. " (" .. playerName .. ")")
    end)
    
    -- Validate the animation exists
    if not animationToPlay or not animationToPlay:IsA("Animation") then
        print("[ANIM] Invalid animation object: " .. tostring(animationToPlay))
        return
    end
    
    -- Load the animation onto the humanoid
    local animSuccess, newTrack = pcall(function()
        return rig.Humanoid:LoadAnimation(animationToPlay)
    end)
    
    if not animSuccess or not newTrack then
        print("[ANIM] Failed to load animation")
        return
    end
    
    -- Play the animation
    currentAnimTrack = newTrack
    currentAnimTrack:Play()
    print("[ANIM] Started playing animation for UserId: " .. top1UserId)
end

--// Main Loop: Check for top 1 player changes every 5 seconds
task.spawn(function()
    while true do
        task.wait(5)
        -- Update the rig if the top player has changed
        apply_top1_appearance_and_animation()
    end
end)