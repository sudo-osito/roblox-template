--// Event Notifications Client
--// Displays event announcements to players

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get UI elements
local ScreenGui = playerGui:WaitForChild("ScreenGui", 10)
if not ScreenGui then
    warn("ScreenGui not found!")
    return
end

local EventsFrame = ScreenGui:WaitForChild("Events")
local EventText = EventsFrame:WaitForChild("EventText")
local EventCountdownFrame = ScreenGui:WaitForChild("EventCountdown")
local CountdownLabel = EventCountdownFrame:WaitForChild("TextLabel")

-- Get RemoteEvent
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = Shared:WaitForChild("RemoteEvents")
local EventNotification = RemoteEvents:WaitForChild("EventNotification")

-- Track event state
local isEventActive = false
local eventEndTime = 0
local nextEventTime = 0

-- Format time into readable string (e.g., "5m 30s", "1h 20m", "45s")
local function formatTime(seconds)
    if seconds <= 0 then
        return "0s"
    end
    
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        if minutes > 0 then
            return string.format("%dh %dm", hours, minutes)
        else
            return string.format("%dh", hours)
        end
    elseif minutes > 0 then
        if secs > 0 then
            return string.format("%dm %ds", minutes, secs)
        else
            return string.format("%dm", minutes)
        end
    else
        return string.format("%ds", secs)
    end
end

-- Update countdown display
local function updateCountdown()
    local currentTime = os.time()
    
    if isEventActive and currentTime < eventEndTime then
        -- Event is active, show time remaining
        local timeLeft = eventEndTime - currentTime
        CountdownLabel.Text = formatTime(timeLeft) .. " left!"
    elseif nextEventTime > currentTime then
        -- No event, show time until next
        local timeUntil = nextEventTime - currentTime
        CountdownLabel.Text = formatTime(timeUntil) .. " until next event!"
    else
        -- Fallback
        CountdownLabel.Text = "Event starting soon!"
    end
end

-- Listen for event notifications from server
EventNotification.OnClientEvent:Connect(function(message, isEnding)
    print("[EVENT] " .. message)
    
    if isEnding then
        -- Event ended
        isEventActive = false
        eventEndTime = 0
        
        -- Parse time until next event from message
        local secondsUntilNext = string.match(message, "Next event in (%d+)s")
        if secondsUntilNext then
            nextEventTime = os.time() + tonumber(secondsUntilNext)
        else
            nextEventTime = os.time() + 1800  -- Default 30 minutes until next event
        end
        
        -- Hide event frame
        EventsFrame.Visible = false
    else
        -- Check if this is a "Next event" timing message (not an actual event)
        local secondsUntilNext = string.match(message, "Next event in (%d+)s")
        if secondsUntilNext then
            -- This is timing info, not an event start
            isEventActive = false
            eventEndTime = 0
            nextEventTime = os.time() + tonumber(secondsUntilNext)
            EventsFrame.Visible = false
        else
            -- Event started or update
            isEventActive = true
            
            -- Parse duration from message if it contains remaining time
            local remainingSeconds = string.match(message, "%((%d+)s remaining%)")
            if remainingSeconds then
                eventEndTime = os.time() + tonumber(remainingSeconds)
            else
                -- New event, extract duration from announcement
                -- Default durations based on event type
                if string.find(message, "DOUBLE COINS") or string.find(message, "DOUBLE STRENGTH") then
                    eventEndTime = os.time() + 300  -- 5 minutes
                elseif string.find(message, "TRIPLE COINS") then
                    eventEndTime = os.time() + 180  -- 3 minutes
                elseif string.find(message, "SUPER EVENT") then
                    eventEndTime = os.time() + 240  -- 4 minutes
                else
                    eventEndTime = os.time() + 300  -- Default 5 minutes
                end
            end
            
            -- Show event frame and set message
            EventsFrame.Visible = true
            EventText.Text = message
        end
    end
    
    updateCountdown()
end)

-- Update countdown every second
task.spawn(function()
    while true do
        task.wait(1)
        updateCountdown()
        
        -- Check if event ended
        if isEventActive and os.time() >= eventEndTime then
            isEventActive = false
            EventsFrame.Visible = false
            -- Don't set nextEventTime here - it will be updated by server announcement
        end
    end
end)

-- Initialize display
EventsFrame.Visible = false
updateCountdown()

