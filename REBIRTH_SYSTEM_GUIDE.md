# Rebirth System Implementation Guide

## Overview
This rebirth system allows players to reset their **current** Coins and Strength values while keeping their **maximum** values on the leaderboards. This creates progression where players can rebirth multiple times without losing their leaderboard ranking.

---

## How It Works

### Data Structure
Each player now has:
- **`Coins`** - Current coins (can be reset)
- **`MaxCoins`** - Highest coins ever reached (saved to leaderboard, never decreases)
- **`Strength`** - Current strength (can be reset)
- **`MaxStrength`** - Highest strength ever reached (saved to leaderboard, never decreases)
- **`Rebirths`** - Number of times rebirthed

### Key Behavior
1. **While Playing**: When `Coins` or `Strength` exceed their max values, `MaxCoins` or `MaxStrength` automatically update
2. **On Rebirth**: `Coins` and `Strength` reset to 0, but `MaxCoins` and `MaxStrength` stay the same
3. **Leaderboards**: Show `MaxCoins` and `MaxStrength`, so your peak achievement is always visible

---

## Files Modified/Created

### Modified Files:
1. **`savedata.server.luau`**
   - Added `MaxCoins` and `MaxStrength` tracking
   - Changed leaderboard saves to use max values instead of current values
   - Auto-updates max values when current exceeds them

### New Files:
1. **`shared/RemoteEvents/RebirthRequest.luau`** - RemoteEvent for client-server communication
2. **`server/PlayerThings/rebirth_handler.server.luau`** - Server-side rebirth logic
3. **`client/ScreenGUI/MainMenu/rebirth_example_usage.client.luau`** - Example usage code

---

## How to Implement the Rebirth Button

### Step 1: Get the RemoteEvent (Client Side)
In your rebirth button script (e.g., `Rebirth.client.luau`):

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RebirthEvent = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("RemoteEvents")
    :WaitForChild("RebirthRequest")
```

### Step 2: Fire the Event When Button is Clicked
```lua
-- When your rebirth button is clicked:
YourRebirthButton.Activated:Connect(function()
    -- Fire the rebirth request to server
    RebirthEvent:FireServer()
    
    -- Optional: Show loading UI, close menus, etc.
    RebirthGUI.Visible = false
end)
```

### Step 3: The Server Handles Everything Automatically
The `rebirth_handler.server.luau` script will:
- ✅ Validate player has enough coins and strength
- ✅ Reset `Coins` and `Strength` to 0
- ✅ Keep `MaxCoins` and `MaxStrength` unchanged
- ✅ Increment `Rebirths` counter
- ✅ Save to DataStore (happens automatically via periodic save)

---

## Configuration

### Rebirth Requirements
Edit `rebirth_handler.server.luau` to change requirements:

```lua
local REBIRTH_CONFIG = {
    minCoins = 1000,        -- Need 1000 coins to rebirth
    minStrength = 500,      -- Need 500 strength to rebirth
    resetCoinsTo = 0,       -- Reset coins to 0 (or any starting value)
    resetStrengthTo = 0,    -- Reset strength to 0 (or any starting value)
}
```

---

## Example Integration with Your Existing Code

In your `Rebirth.client.luau`, you probably have something like:

```lua
local RebirthButton = RebirthFrame:WaitForChild("InvisibleButton")
local RebirthGUI = SubMenus:WaitForChild("RebirthGUI")

-- Add this at the top:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RebirthEvent = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("RemoteEvents")
    :WaitForChild("RebirthRequest")

-- Then add this when player confirms rebirth:
local confirmButton = RebirthGUI:WaitForChild("ConfirmRebirthButton")
confirmButton.Activated:Connect(function()
    -- Fire rebirth request
    RebirthEvent:FireServer()
    
    -- Close the GUI
    RebirthGUI.Visible = false
end)
```

---

## Testing the System

### In Roblox Studio:
1. **Play the game**
2. **Give yourself coins/strength** (using your existing systems)
3. **Check leaderboards** - You should see your current values
4. **Fire the rebirth** - Click your rebirth button
5. **Verify**:
   - Your current coins/strength reset to 0
   - Leaderboards still show your max values
   - Rebirth counter incremented

### Console Commands for Testing (in Server Console):
```lua
-- Give yourself coins and strength for testing
local player = game.Players.PlayerName
player.Coins.Value = 5000
player.Strength.Value = 2000

-- Check max values
print(player.MaxCoins.Value, player.MaxStrength.Value)

-- Manually trigger rebirth (for testing)
local RebirthEvent = game.ReplicatedStorage.Shared.RemoteEvents.RebirthRequest
RebirthEvent:FireServer(player) -- Note: FireServer from server doesn't work, use client
```

---

## Advanced: Adding Feedback to the Player

If you want to show success/failure messages to the player:

### Create a Response RemoteEvent:
```lua
-- In shared/RemoteEvents/RebirthResponse.luau
return {
    className = "RemoteEvent"
}
```

### Update rebirth_handler.server.luau:
```lua
local RebirthResponse = ReplicatedStorage.Shared.RemoteEvents.RebirthResponse

RebirthEvent.OnServerEvent:Connect(function(player)
    local success, message = processRebirth(player)
    
    -- Send response back to client
    RebirthResponse:FireClient(player, success, message)
end)
```

### Handle in Client:
```lua
RebirthResponse.OnClientEvent:Connect(function(success, message)
    if success then
        -- Show success message
        print("✅ " .. message)
    else
        -- Show error message
        warn("❌ " .. message)
    end
end)
```

---

## Troubleshooting

### Issue: Leaderboard still shows current values
- **Check**: Make sure `savedata.server.luau` is using `MaxCoins` and `MaxStrength` in all save functions
- **Solution**: Review lines in PeriodicSaveData, OnPlayerRemoving, and OnServerShutdown

### Issue: MaxCoins/MaxStrength not updating
- **Check**: The `.Changed` connection on `Coins` and `Strength`
- **Solution**: Verify the comparison `if coins.Value > maxCoins.Value then maxCoins.Value = coins.Value end`

### Issue: RemoteEvent not found
- **Check**: Your project structure matches the paths
- **Solution**: Adjust the WaitForChild paths to match your actual ReplicatedStorage structure

---

## Summary

✅ **Leaderboards track peak values** (MaxCoins, MaxStrength)  
✅ **Rebirth resets current progress** (Coins, Strength → 0)  
✅ **Players keep their leaderboard position** even after rebirthing  
✅ **Easy to configure** requirements and rewards  
✅ **Simple to use** - just fire one RemoteEvent!

Now you can implement your rebirth button by simply calling `RebirthEvent:FireServer()` when the player clicks it!
