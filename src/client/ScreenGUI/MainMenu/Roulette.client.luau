local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = Shared:WaitForChild("RemoteEvents")
local RouletteSpinEvent = RemoteEvents:WaitForChild("RouletteSpinRequest")
local RouletteClaimEvent = RemoteEvents:WaitForChild("RouletteClaimPrize")

local ScreenGui = playerGui:WaitForChild("ScreenGui", 5)
if not ScreenGui then
    warn("ScreenGui not found in PlayerGui after 5 seconds!")
    return
end

local Offers = ScreenGui:WaitForChild("Offers")
local RouletteButton = Offers.Offer1:WaitForChild("InvisibleButton")
local offerFreeSpinsLabel = RouletteButton:WaitForChild("FreeSpins")

local SubMenus = playerGui:WaitForChild("SubMenus", 5)
if not SubMenus then
    warn("SubMenus not found in PlayerGui!")
    return
end

local RouletteGUI = SubMenus:WaitForChild("RouletteGUI")
local closeRoulette = RouletteGUI:WaitForChild("CloseRoulette")
local prizesLabels = RouletteGUI:WaitForChild("PrizesLabels")

RouletteGUI.Visible = false

RouletteButton.Activated:Connect(function()
    if RouletteGUI.Visible == true then
        RouletteGUI.Visible = false
        return
    else RouletteGUI.Visible = true
    end
end)

closeRoulette.Activated:Connect(function()
    RouletteGUI.Visible = false
end)

-- // ROULETTE SPIN HALDLER \\ ---------------------------------------------

local wheel = RouletteGUI:WaitForChild("Roulette")

local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

Prizes = {
    ["Prize1"] = {
        prize = "Coins",
        amount = 1000,
        location = NumberRange.new(1, 45),
    }
    ,
    ["Prize2"] = {
        prize = "Coins",
        amount = 1000,
        location = NumberRange.new(46, 90),
    }
    ,
    ["Prize3"] = {
        prize = "Strength",
        amount = 500,
        location = NumberRange.new(91, 135),
    }
    ,
    ["Prize4"] = {
        prize = "Coins",
        amount = 1000,
        location = NumberRange.new(136, 180),
    }
    ,
    ["Prize5"] = {
        prize = "Strength",
        amount = 100,
        location = NumberRange.new(181, 225),
    }
    ,
    ["Prize6"] = {
        prize = "Coins",
        amount = 10000,
        location = NumberRange.new(226, 270),
    }
    ,
    ["Prize7"] = {
        prize = "Coins",
        amount = 1000,
        location = NumberRange.new(271, 315),
    }
    ,
    ["Prize8"] = {
        prize = "Rebirths",
        amount = 1,
        location = NumberRange.new(316, 360),
    }  
}

local freeSpinsButton = RouletteGUI:WaitForChild("FreeSpinsButton")
local paidSpinsButton = RouletteGUI:WaitForChild("PaidSpinsButton")

-- Get text labels
local freeSpinsText = RouletteGUI.FreeSpins.TextLabel
local paidSpinsText = RouletteGUI.PaidSpins.TextLabel

-- Track current free spins count
local currentFreeSpins = 0  -- Default starting value (server will update this)
local isSpinning = false  -- Prevent multiple simultaneous spins

-- Function to update free spins display
local function updateFreeSpinsDisplay()
    freeSpinsText.Text = currentFreeSpins .. " free spins left!"
    
    -- Update offer label
    if currentFreeSpins > 0 then
        offerFreeSpinsLabel.Text = currentFreeSpins .. " FREE SPINS!"
        offerFreeSpinsLabel.Visible = true
    else
        offerFreeSpinsLabel.Visible = false
    end
end

-- Function to update paid spins display
local function updatePaidSpinsDisplay()
    paidSpinsText.Text = "19"
end

-- Sync free spins from server
local freeSpinsValue = player:WaitForChild("FreeSpins", 10)
if freeSpinsValue then
    currentFreeSpins = freeSpinsValue.Value
    
    -- Listen for changes to free spins on server
    freeSpinsValue.Changed:Connect(function(newValue)
        currentFreeSpins = newValue
        updateFreeSpinsDisplay()
    end)
end

-- Initialize displays
updateFreeSpinsDisplay()
updatePaidSpinsDisplay()

freeSpinsButton.Activated:Connect(function()
    -- Check if player has free spins available
    if currentFreeSpins <= 0 then
        warn("No free spins available!")
        return
    end
    
    -- Prevent multiple spins at once
    if isSpinning then
        warn("Already spinning!")
        return
    end
    
    isSpinning = true
    
    -- Request spin from server
    RouletteSpinEvent:FireServer("free")
end)

paidSpinsButton.Activated:Connect(function()
    -- Prevent multiple spins at once
    if isSpinning then
        warn("Already spinning!")
        return
    end
    
    isSpinning = true
    
    -- Request paid spin from server (will prompt purchase)
    RouletteSpinEvent:FireServer("paid")
    
    -- Reset spinning state after a short delay (in case purchase is cancelled)
    task.delay(2, function()
        isSpinning = false
    end)
end)

-- Listen for server response
RouletteSpinEvent.OnClientEvent:Connect(function(responseType, randomNumber, freeSpinsRemaining)
    if responseType == "spin_approved" or responseType == "paid_spin_approved" then
        -- Update free spins count (only relevant for free spins)
        if responseType == "spin_approved" then
            currentFreeSpins = freeSpinsRemaining
            updateFreeSpinsDisplay()
        end
        
        -- Hide prize labels during spin
        prizesLabels.Visible = false
        
        -- Perform the spin animation
        -- Always start from 0 for consistent visual experience
        wheel.Rotation = 0
        
        local targetRotation = 360 * 5 + randomNumber  -- 5 full spins plus landing on the prize
        local goal = {Rotation = targetRotation}
        local tween = tweenService:Create(wheel, tweenInfo, goal)
        tween:Play()

        tween.Completed:Connect(function()
            -- Claim the prize from server
            RouletteClaimEvent:FireServer()
            
            -- Reset spinning state
            isSpinning = false
            
            -- Find which prize was won for display
            local selectedPrize = nil
            for prizeName, prizeInfo in pairs(Prizes) do
                if randomNumber >= prizeInfo.location.Min and randomNumber <= prizeInfo.location.Max then
                    selectedPrize = prizeInfo
                    break
                end
            end
            
            if selectedPrize then
                print("You won " .. selectedPrize.amount .. " " .. selectedPrize.prize .. "!")
                -- Here you can show a victory notification/popup
            end
            
            -- Wait 1.5 seconds so player can see what they won
            task.wait(1.5)
            
            -- Reset to 0 for next spin
            wheel.Rotation = 0
            prizesLabels.Visible = true
        end)
    end
end) 

