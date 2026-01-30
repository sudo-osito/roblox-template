# Roulette System Implementation

## Overview
The roulette system has been fully implemented with the following features:
- **Free spins**: Players start with 3 free spins per session
- **Daily reset**: Free spins reset daily when players join
- **Gamepass bonuses**: Players with gamepasses get extra free spins daily
- **Paid spins**: Players can purchase additional spins with Robux
- **Server-side validation**: All prize distribution is handled server-side to prevent exploits

## Files Created/Modified

### New Files Created:
1. **[roulette_handler.server.luau](src/server/PlayerThings/roulette_handler.server.luau)**
   - Handles all spin requests (free and paid)
   - Validates free spin availability
   - Generates random results server-side
   - Awards prizes (Coins, Strength, Rebirths)
   - Integrates with AutoMultiplier for coin rewards

2. **[daily_free_spins.server.luau](src/server/PlayerThings/daily_free_spins.server.luau)**
   - Tracks daily logins using DataStore
   - Resets free spins each day
   - Calculates bonus spins from gamepasses
   - Base: 3 spins, VIP: +2 spins, Ultra VIP: +5 spins

3. **[RouletteSpinRequest.meta.json](src/shared/RemoteEvents/RouletteSpinRequest.meta.json)**
   - RemoteEvent for spin requests

4. **[RouletteClaimPrize.meta.json](src/shared/RemoteEvents/RouletteClaimPrize.meta.json)**
   - RemoteEvent for prize claiming

### Modified Files:
1. **[savedata.server.luau](src/server/DataManaging/savedata.server.luau)**
   - Added `FreeSpins` IntValue to player (starts at 3)
   - Not saved to DataStore (resets daily via daily_free_spins handler)

2. **[product_purchase_handler.server.luau](src/server/MarketplaceHandler/product_purchase_handler.server.luau)**
   - Added paid spin product (ID: 3525842684, 25 Robux)
   - Integrates with roulette_handler via `_G.RouletteHandlePaidSpin`

3. **[Roulette.client.luau](src/client/ScreenGUI/MainMenu/Roulette.client.luau)**
   - Complete rewrite for client-server communication
   - Syncs free spins count from server
   - Validates free spins before spinning
   - Prevents multiple simultaneous spins
   - Handles both free and paid spin animations
   - Claims prizes from server after animation completes

## How It Works

### Free Spins Flow:
1. Player clicks "Free Spin" button
2. Client checks if `currentFreeSpins > 0`
3. Client sends request to server via `RouletteSpinEvent:FireServer("free")`
4. Server validates and deducts 1 free spin
5. Server generates random number (1-360) and sends back to client
6. Client plays spin animation
7. After animation, client requests prize via `RouletteClaimEvent:FireServer()`
8. Server awards the prize based on the stored result

### Paid Spins Flow:
1. Player clicks "Paid Spin" button
2. Client sends request via `RouletteSpinEvent:FireServer("paid")`
3. Server prompts Robux purchase (25 Robux)
4. If purchased, `product_purchase_handler` calls `_G.RouletteHandlePaidSpin`
5. Same animation and prize flow as free spins

### Daily Reset Flow:
1. Player joins the server
2. `daily_free_spins` checks last login date from DataStore
3. If new day:
   - Calculate total spins: Base (3) + Gamepass bonuses
   - Set `player.FreeSpins.Value` to total
   - Save current time to DataStore
4. If same day:
   - Keep existing `FreeSpins.Value` (doesn't reset)

## Prize Configuration

All prizes are configured in both client and server (must match):

```lua
Prize1: 1000 Coins (1-45°)
Prize2: 1000 Coins (46-90°)
Prize3: 500 Strength (91-135°)
Prize4: 1000 Coins (136-180°)
Prize5: 100 Strength (181-225°)
Prize6: 10,000 Coins (226-270°) -- Jackpot!
Prize7: 1000 Coins (271-315°)
Prize8: 1 Rebirth (316-360°)
```

## Gamepass Bonuses

Configured in `daily_free_spins.server.luau`:

```lua
VIP (1691824103): +2 free spins daily
Ultra VIP (1691201385): +5 free spins daily
```

So a player with Ultra VIP gets 8 total spins per day (3 base + 5 bonus).

## UI Integration

The client script includes a basic visual feedback system:
- **Green button**: Has free spins available
- **Gray button**: No free spins available

You can customize this further by:
1. Adding a TextLabel to show exact spin count
2. Showing victory notifications/popups
3. Adding sound effects
4. Creating particle effects for wins

Example customization in [Roulette.client.luau](src/client/ScreenGUI/MainMenu/Roulette.client.luau):
```lua
-- Update this function to match your UI design
local function updateFreeSpinsDisplay()
    -- Example: Display text
    -- freeSpinsButton.TextLabel.Text = "Free Spins: " .. currentFreeSpins
    
    -- Current: Color feedback
    if currentFreeSpins <= 0 then
        freeSpinsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    else
        freeSpinsButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end
```

## Security Features

✅ All random generation happens server-side
✅ Free spin count validated server-side
✅ Prizes awarded server-side only
✅ Can't exploit client to get unlimited spins
✅ Can't manipulate prize results
✅ Robux purchases handled by Roblox MarketplaceService

## Testing Checklist

- [ ] Free spin button works when spins available
- [ ] Free spin button disabled when no spins
- [ ] Spin count decrements after each use
- [ ] Prizes are awarded correctly
- [ ] Paid spin prompts Robux purchase
- [ ] Daily reset works (test by rejoining next day)
- [ ] Gamepass bonuses apply correctly
- [ ] Multiple players can spin simultaneously
- [ ] Animation completes before prize is awarded

## Notes

- Free spins **do NOT persist** across server shutdowns (by design)
- Daily reset happens when joining a server, not at midnight
- If player owns multiple gamepasses, bonuses stack
- Paid spins have no daily limit
- Product ID 3525842684 must be configured in your Roblox game
