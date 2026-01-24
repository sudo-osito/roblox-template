--// Services
local players = game:GetService("Players")

--// Variables
-- The rig model that will display the top 1 player's appearance
local rig = workspace.TimeSpentLeaderboard.FirstPlaceAvatar:WaitForChild("Rig")
-- The billboard GUI that displays the player's name and rank (preserved during updates)
local first_place_tag = workspace.TimeSpentLeaderboard.FirstPlaceAvatar:WaitForChild("FirstPlaceTag")
-- The animation to play on the rig (e.g., dancing animation)
local animationToPlay = workspace.TimeSpentLeaderboard.FirstPlaceAvatar:WaitForChild("AnimationToPlay")
-- Current playing animation (so we can stop it when switching players)
local currentAnimTrack = nil
-- Tracks which user is currently being displayed (prevents unnecessary updates)
local currentTop1UserId = nil

--// Functions
-- Gets the UserId of the player with the most time spent from the cached manager
local function getTop1PlayerUserId()
	-- Wait for DataStore manager to initialize if needed
	local maxWait = 0
	while not _G.DataStoreManager and maxWait < 50 do
		task.wait(0.1)
		maxWait = maxWait + 1
	end
	
	if not _G.DataStoreManager then
		print("[TOP1] DataStore manager not found!")
		return nil
	end
	
	return _G.DataStoreManager.getTop1TimePlayer()
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

--// Main Loop: Check for top 1 player changes every 60 seconds (synced with leaderboard updates)
task.spawn(function()
    while true do
        task.wait(60)
        -- Update the rig if the top player has changed
        apply_top1_appearance_and_animation()
    end
end)