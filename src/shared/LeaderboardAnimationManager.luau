--// Shared module for playing animations on leaderboard rigs
--// Usage:
--// local LeaderboardAnimationManager = require(game.ServerScriptService.LeaderboardAnimationManager)
--// LeaderboardAnimationManager.playLeaderboardAnimation(workspacePath, getTopPlayerFunction)

local players = game:GetService("Players")

local LeaderboardAnimationManager = {}

-- Internal factory: builds an updater closure bound to a specific leaderboard rig
local function makeController(workspacePath, getTopPlayerFunction)
    -- Get references to the leaderboard components
    local leaderboardRoot = workspace:FindFirstChild(workspacePath)
    if not leaderboardRoot then
        print("[ANIM] Leaderboard not found: " .. workspacePath)
        return nil
    end
    
    local firstPlaceAvatar = leaderboardRoot:FindFirstChild("FirstPlaceAvatar")
    if not firstPlaceAvatar then
        print("[ANIM] FirstPlaceAvatar not found in " .. workspacePath)
        return nil
    end
    
    local rig = firstPlaceAvatar:WaitForChild("Rig")
    local animationToPlay = firstPlaceAvatar:WaitForChild("AnimationToPlay")
    
    -- Create a yellow highlight for the rig
    local highlight = Instance.new("Highlight")
    highlight.Parent = rig
    highlight.FillColor = Color3.new(1, 0.768627, 0)  -- Yellow
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.new(1, 0.815686, 0)  -- Yellow
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    
    -- Current playing animation (so we can stop it when switching players)
    local currentAnimTrack = nil
    -- Tracks which user is currently being displayed (prevents unnecessary updates)
    local currentTop1UserId = nil
    
    -- Gets the UserId of the top player from the provided function
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
        
        return getTopPlayerFunction()
    end
    
    -- Updates the rig to display the top player's appearance and plays their animation
    -- Only updates if the top player has changed (efficient performance)
    local function apply_top1_appearance_and_animation()
        local top1UserId = getTop1PlayerUserId()

        if not top1UserId then
            print("[ANIM] No valid top1 player found")
            return false
        end

        -- Skip if the top player hasn't changed (save performance)
        if top1UserId == currentTop1UserId then
            return true
        end

        currentTop1UserId = top1UserId

        -- Stop the currently playing animation before starting a new one
        if currentAnimTrack then
            pcall(function() currentAnimTrack:Stop() end)
        end

        -- Get the appearance data for the top player (works even if they're offline)
        local success, humanoidDesc = pcall(function()
            return players:GetHumanoidDescriptionFromUserId(top1UserId)
        end)
        
        if not success or not humanoidDesc then
            print("[ANIM] Failed to get humanoid description for UserId: " .. top1UserId)
            currentTop1UserId = nil
            return false
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
            
        end)
        
        -- Validate the animation exists
        if not animationToPlay or not animationToPlay:IsA("Animation") then
            print("[ANIM] Invalid animation object: " .. tostring(animationToPlay))
            return false
        end
        
        -- Load the animation onto the humanoid
        local animSuccess, newTrack = pcall(function()
            return rig.Humanoid:LoadAnimation(animationToPlay)
        end)
        
        if not animSuccess or not newTrack then
            print("[ANIM] Failed to load animation")
            return false
        end
        
        -- Play the animation
        currentAnimTrack = newTrack
        currentAnimTrack:Play()
        return true
    end
    return apply_top1_appearance_and_animation
end

--// Plays animation on a leaderboard rig (legacy: manages its own loop every 60s)
--// @param workspacePath: string - Path to the leaderboard in workspace (e.g., "CoinsLeaderboard")
--// @param getTopPlayerFunction: function - Function that returns the top player's UserId
function LeaderboardAnimationManager.playLeaderboardAnimation(workspacePath, getTopPlayerFunction)
    local apply = makeController(workspacePath, getTopPlayerFunction)
    if not apply then return end

    -- Try immediately; if not ready, retry every 5s until success, then fall back to 60s cadence
    local ok = apply()

    task.spawn(function()
        if not ok then
            local attempt = 0
            while attempt < 12 do -- up to ~1 minute of quick retries
                task.wait(5)
                if apply() then
                    break
                end
                attempt += 1
            end
        end

        while true do
            task.wait(60)
            apply()
        end
    end)
end

--// Binds animation updates to an external loop (e.g., leaderboard refresh cadence)
--// Returns an updater function to call whenever the leaderboard refreshes
function LeaderboardAnimationManager.bindToExternalTick(workspacePath, getTopPlayerFunction)
    local apply = makeController(workspacePath, getTopPlayerFunction)
    if not apply then
        return function() end
    end
    return apply
end

return LeaderboardAnimationManager
