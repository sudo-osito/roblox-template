local players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Leaderboard = DSS:GetOrderedDataStore("CoinsBoard1")

--// Variables
local rig = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("Rig")
local first_place_tag = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("FirstPlaceTag")
local animationToPlay = workspace.DollarLeaderboard.FirstPlaceAvatar:WaitForChild("AnimationToPlay")
local currentAnimTrack = nil
local currentTop1UserId = nil

--// Functions
local function getTop1PlayerUserId()
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
    
    return userId
end

local function apply_top1_appearance_and_animation()
    local top1UserId = getTop1PlayerUserId()
    
    -- Only update if top player has changed
    if top1UserId == currentTop1UserId then
        return
    end
    
    currentTop1UserId = top1UserId
    
    if not top1UserId then
        print("[ANIM] No valid top1 player found")
        return
    end

    -- Stop old animation
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop() end)
    end

    -- Get player appearance by UserId (works even if player is not in this server)
    local success, humanoidDesc = pcall(function()
        return players:GetHumanoidDescriptionFromUserId(top1UserId)
    end)
    
    if not success or not humanoidDesc then
        print("[ANIM] Failed to get humanoid description for UserId: " .. top1UserId)
        currentTop1UserId = nil
        return
    end
    
    -- Get player name
    local playerName = "Unknown"
    local nameSuccess, nameResult = pcall(function()
        return game:GetService("Players"):GetNameFromUserIdAsync(top1UserId)
    end)
    
    if nameSuccess and nameResult then
        playerName = nameResult
    end
    
    pcall(function()
        -- Save BillboardGui before applying description
        local head = rig:FindFirstChild("Head")
        local savedBillboards = {}
        
        if head then
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("BillboardGui") then
                    table.insert(savedBillboards, child:Clone())
                end
            end
        end
        
        -- Delete any existing shirt and pants first
        local oldShirt = rig:FindFirstChild("Shirt")
        if oldShirt then oldShirt:Destroy() end
        
        local oldPants = rig:FindFirstChild("Pants")
        if oldPants then oldPants:Destroy() end
        
        -- Apply the description (updates body, face, and properties)
        rig.Humanoid:ApplyDescription(humanoidDesc)
        
        -- Restore BillboardGuis to the head
        head = rig:FindFirstChild("Head")
        if head then
            for _, billboard in pairs(savedBillboards) do
                billboard.Parent = head
            end
        end
        
        -- Set the display name
        rig.Humanoid.DisplayName = playerName
        
        print("[ANIM] Applied appearance for UserId: " .. top1UserId .. " (" .. playerName .. ")")
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
    print("[ANIM] Started playing animation for UserId: " .. top1UserId)
end

task.spawn(function()
    while true do
        task.wait(5)
        apply_top1_appearance_and_animation()
    end
end)