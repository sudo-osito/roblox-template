--// Event Handler
--// Spawns random events every 30 minutes with temporary multiplier boosts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Event configuration
local EVENTS = {
	{
		name = "Double Coins Event",
		rarity = 40,  -- 40% chance
		duration = 300,  -- 5 minutes
		coinMultiplier = 2,
		strengthMultiplier = 1,
		announcement = "🪙 DOUBLE COINS EVENT! 2x coins for 5 minutes!"
	},
	{
		name = "Double Strength Event",
		rarity = 40,  -- 40% chance
		duration = 300,  -- 5 minutes
		coinMultiplier = 1,
		strengthMultiplier = 2,
		announcement = "💪 DOUBLE STRENGTH EVENT! 2x strength for 5 minutes!"
	},
	{
		name = "Triple Coins Event",
		rarity = 15,  -- 15% chance (rarer)
		duration = 180,  -- 3 minutes
		coinMultiplier = 3,
		strengthMultiplier = 1,
		announcement = "🌟 TRIPLE COINS EVENT! 3x coins for 3 minutes!"
	},
	{
		name = "Super Event",
		rarity = 5,  -- 5% chance (very rare)
		duration = 240,  -- 4 minutes
		coinMultiplier = 2,
		strengthMultiplier = 2,
		announcement = "⚡ SUPER EVENT! 2x coins AND 2x strength for 4 minutes!"
	},
}

-- Time between events (30 minutes)
local EVENT_INTERVAL = 1800

-- Track current active event
local activeEvent = nil
local eventEndTime = 0

-- Create RemoteEvent for notifying clients
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteEvents = Shared:FindFirstChild("RemoteEvents")
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = Shared
end

local EventNotification = RemoteEvents:FindFirstChild("EventNotification")
if not EventNotification then
	EventNotification = Instance.new("RemoteEvent")
	EventNotification.Name = "EventNotification"
	EventNotification.Parent = RemoteEvents
end

-- Select a random event based on rarity weights
local function selectRandomEvent()
	local totalWeight = 0
	for _, event in ipairs(EVENTS) do
		totalWeight = totalWeight + event.rarity
	end
	
	local randomValue = math.random(1, totalWeight)
	local currentWeight = 0
	
	for _, event in ipairs(EVENTS) do
		currentWeight = currentWeight + event.rarity
		if randomValue <= currentWeight then
			return event
		end
	end
	
	return EVENTS[1]  -- Fallback
end

-- Get current event multipliers
local function getEventMultipliers()
	if activeEvent and os.time() < eventEndTime then
		return {
			coin = activeEvent.coinMultiplier,
			strength = activeEvent.strengthMultiplier
		}
	else
		return {
			coin = 1,
			strength = 1
		}
	end
end

-- Announce event to all players
local function announceEvent(message, isEnding)
	print("[EVENT] " .. message)
	
	-- Send to all players
	for _, player in ipairs(Players:GetPlayers()) do
		EventNotification:FireClient(player, message, isEnding or false)
	end
end

-- Expose to global for MultiplierManager to access
_G.EventMultipliers = {
	getMultipliers = getEventMultipliers,
	isEventActive = function()
		return activeEvent ~= nil and os.time() < eventEndTime
	end,
	getCurrentEvent = function()
		if activeEvent and os.time() < eventEndTime then
			return activeEvent.name
		end
		return nil
	end
}

-- Track server start time and first event time
local serverStartTime = os.time()
local firstEventTime = serverStartTime + 30  -- First event is 30 sec after start
local hasFirstEventOccurred = false
local nextEventStartTime = firstEventTime  -- When the next event will start

-- Start the event loop
task.spawn(function()
	-- Wait a bit before first event (30 seconds after server starts)
	task.wait(30)
	hasFirstEventOccurred = true
	
	while true do
		local event = selectRandomEvent()
		activeEvent = event
		eventEndTime = os.time() + event.duration
		
		announceEvent(event.announcement, false)
		
		-- Wait for event to complete
		task.wait(event.duration)
		
		-- Event ended
		if activeEvent == event then
			activeEvent = nil
			announceEvent("Event ended! Back to normal multipliers.", true)
		end
		
		-- Calculate next event start time
		nextEventStartTime = os.time() + EVENT_INTERVAL
		
		-- Now wait 30 minutes before next event
		task.wait(EVENT_INTERVAL)
	end
end)

-- Send current event status to new players
Players.PlayerAdded:Connect(function(player)
	task.wait(2)  -- Wait for client to load
	
	if activeEvent and os.time() < eventEndTime then
		local timeLeft = eventEndTime - os.time()
		local message = activeEvent.announcement .. " (" .. math.ceil(timeLeft) .. "s remaining)"
		EventNotification:FireClient(player, message, false)
	else
		-- No active event, tell client when next event is
		local timeUntilNext = nextEventStartTime - os.time()
		if timeUntilNext < 0 then
			timeUntilNext = 0  -- Safety check
		end
		EventNotification:FireClient(player, "Next event in " .. math.ceil(timeUntilNext) .. "s", true)
	end
end)

print("Event Handler initialized - Events will occur every 30 minutes")
