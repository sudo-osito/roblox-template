local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = playerGui:WaitForChild("ScreenGui", 5)
if not ScreenGui then
    warn("ScreenGui not found in PlayerGui after 5 seconds!")
    return
end

local MainMenu = ScreenGui:WaitForChild("MainMenu")
local RewardsFrame = MainMenu:WaitForChild("RewardsFrame")
local RewardsButton = RewardsFrame:WaitForChild("InvisibleButton")

local SubMenus = playerGui:WaitForChild("SubMenus", 5)
if not SubMenus then
    warn("SubMenus not found in PlayerGui!")
    return
end

local RewardsGUI = SubMenus:WaitForChild("RewardsGUI")
local closeRewardsGUI = RewardsGUI:WaitForChild("CloseRewards")

RewardsGUI.Visible = false

RewardsButton.Activated:Connect(function()
    if RewardsGUI.Visible == true then
        RewardsGUI.Visible = false
        return
    else RewardsGUI.Visible = true
    end
end)

closeRewardsGUI.Activated:Connect(function()
    RewardsGUI.Visible = false
end)

-- // HERE STARTS THE BORING PART // GIFTING FREE STUFF TO KIDS SO THEY KEEP PLAYING
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SubMenus = playerGui:WaitForChild("SubMenus")
local RewardsGUI = SubMenus:WaitForChild("RewardsGUI")

-- Get RemoteEvent for claiming rewards
local RewardsEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemoteEvents"):WaitForChild("ClaimReward")

local Reward1Text = RewardsGUI.Reward1:WaitForChild("TimeLeftLabel")
local Reward2Text = RewardsGUI.Reward2:WaitForChild("TimeLeftLabel")
local Reward3Text = RewardsGUI.Reward3:WaitForChild("TimeLeftLabel")
local Reward4Text = RewardsGUI.Reward4:WaitForChild("TimeLeftLabel")
local Reward5Text = RewardsGUI.Reward5:WaitForChild("TimeLeftLabel")
local Reward6Text = RewardsGUI.Reward6:WaitForChild("TimeLeftLabel")
local Reward7Text = RewardsGUI.Reward7:WaitForChild("TimeLeftLabel")
local Reward8Text = RewardsGUI.Reward8:WaitForChild("TimeLeftLabel")
local Reward9Text = RewardsGUI.Reward9:WaitForChild("TimeLeftLabel")
local Reward10Text = RewardsGUI.Reward10:WaitForChild("TimeLeftLabel")
local Reward11Text = RewardsGUI.Reward11:WaitForChild("TimeLeftLabel")
local Reward12Text = RewardsGUI.Reward12:WaitForChild("TimeLeftLabel")


local Reward1Button = RewardsGUI.Reward1:WaitForChild("ClaimButton")
local Reward2Button = RewardsGUI.Reward2:WaitForChild("ClaimButton")
local Reward3Button = RewardsGUI.Reward3:WaitForChild("ClaimButton")
local Reward4Button = RewardsGUI.Reward4:WaitForChild("ClaimButton")
local Reward5Button = RewardsGUI.Reward5:WaitForChild("ClaimButton")
local Reward6Button = RewardsGUI.Reward6:WaitForChild("ClaimButton")
local Reward7Button = RewardsGUI.Reward7:WaitForChild("ClaimButton")
local Reward8Button = RewardsGUI.Reward8:WaitForChild("ClaimButton")
local Reward9Button = RewardsGUI.Reward9:WaitForChild("ClaimButton")
local Reward10Button = RewardsGUI.Reward10:WaitForChild("ClaimButton")
local Reward11Button = RewardsGUI.Reward11:WaitForChild("ClaimButton")
local Reward12Button = RewardsGUI.Reward12:WaitForChild("ClaimButton")

-- Reward configuration: {timeRequired (seconds), textLabel, button}
local REWARDS = {
	{id = 1, time = 300, text = Reward1Text, button = Reward1Button},      -- 5m
	{id = 2, time = 600, text = Reward2Text, button = Reward2Button},      -- 10m
	{id = 3, time = 1200, text = Reward3Text, button = Reward3Button},     -- 20m
	{id = 4, time = 1800, text = Reward4Text, button = Reward4Button},     -- 30m
	{id = 5, time = 2700, text = Reward5Text, button = Reward5Button},     -- 45m
	{id = 6, time = 3600, text = Reward6Text, button = Reward6Button},     -- 1h
	{id = 7, time = 4800, text = Reward7Text, button = Reward7Button},     -- 1h 20m
	{id = 8, time = 6000, text = Reward8Text, button = Reward8Button},     -- 1h 40m
	{id = 9, time = 7200, text = Reward9Text, button = Reward9Button},     -- 2h
	{id = 10, time = 8400, text = Reward10Text, button = Reward10Button},  -- 2h 20m
	{id = 11, time = 9600, text = Reward11Text, button = Reward11Button},  -- 2h 40m
	{id = 12, time = 10800, text = Reward12Text, button = Reward12Button}, -- 3h - VIP Reward
}

-- Track which rewards have been claimed this session
local claimedRewards = {}

-- Format seconds into readable time (e.g., "1h 20m", "45m", "30s")
local function formatTime(seconds)
	if seconds <= 0 then return "Claim!" end
	
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

-- Update reward display
local function updateRewards()
	local sessionTime = player:FindFirstChild("Session Time")
	if not sessionTime then return end
	
	for _, reward in ipairs(REWARDS) do
		local timeLeft = reward.time - sessionTime.Value
		
		if claimedRewards[reward.id] then
			-- Already claimed
			reward.text.Text = "Claimed!"
			reward.button.Interactable = false
			reward.button.Active = false
		elseif timeLeft <= 0 then
			-- Ready to claim
			reward.text.Text = "Claim!"
			reward.button.Interactable = true
			reward.button.Active = true
		else
			-- Still waiting
			reward.text.Text = formatTime(timeLeft)
			reward.button.Interactable = false
			reward.button.Active = false
		end
	end
end

-- Setup claim buttons
for _, reward in ipairs(REWARDS) do
	reward.button.Activated:Connect(function()
		if not claimedRewards[reward.id] then
			-- Mark as claimed locally (prevent spam clicking)
			claimedRewards[reward.id] = true
			reward.text.Text = "Claimed!"
			reward.button.Interactable = false
			reward.button.Active = false
			
			-- Send claim request to server
			RewardsEvent:FireServer(reward.id)
		end
	end)
end

-- Wait for Session Time to exist
task.spawn(function()
	local sessionTime = player:WaitForChild("Session Time", 10)
	if sessionTime then
		-- Update every second
		while true do
			updateRewards()
			task.wait(1)
		end
	else
		warn("Session Time not found!")
	end
end)





