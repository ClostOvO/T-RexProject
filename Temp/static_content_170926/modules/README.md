# Chilli Hub / Static Content Modular Codebase Guide
**Source**: `static_content_170926/f89d249a195wn04n10b81rk7a6i1q00.json`  
**Deobfuscation & Reconstruction Target**: `C:\Users\ClostO_O\AppData\Local\Real\workspace\static_content_170926\modules`

---

## 1. Complete Modular Structure Overview (13 Modules)

| Module File | Category Name | Core Remotes / APIs | Purpose & Key Mechanics |
| :--- | :--- | :--- | :--- |
| **`00_core_runtime.lua`** | **Core Runtime & Upvalues** | `Networking`, `Y[9]`, `Y[23]`, `Y[15]` | Service instantiations, 15-second remote watchdog, character accessors, coordinate constants (`SeparationLine`, `RiftMachine`), safe zone boundary math. |
| **`01_steal_farm_pathing.lua`** | **Auto Steal & Egg Pathing** | `DropFieldEgg`, `AskCarryEgg`, `AskFieldEggSnapshot` | Egg targeting algorithms (Nearest, Highest Value), multi-segment `legs()` interpolation, separation line stepping on foot to prevent BAC teleport rollback, auto-hop. |
| **`02_treadmill_speed.lua`** | **Treadmill & Speed Farming** | `RF/Treadmill/AskWearStill`, `AskDoff`, `AskTierRaise` | Automated treadmill belt mounting, speed listeners (`SpeedGained`), auto tier upgrades, treadmill hiding to improve client FPS, unstuck recovery. |
| **`03_butterfly_bloom_event.lua`** | **Butterfly Bloom & Wisp** | `RF/Butterflies/AskClaimNet`, `AskTradeUp`, `AskCraftEssence` | Automated net claiming at `NetStand`, 3D trajectory and velocity prediction via `ButterflyCatalog`, tier priority scoring formula, essence crafting. |
| **`04_fusery_mutations.lua`** | **Pet Fusery & Mutations** | `RF/Fusery/BeginFuse`, `AskUseMutationConsumable` | Fusion automation with briefing confirmation and reveal handling, rarity filters (Lowest/Highest first), boss mutation elixir application. |
| **`05_pen_hatching_satchel.lua`** | **Hatching & Pet Satchel** | `RF/EggWorld/AskHatch`, `RE/PetSatchel/SellSelection` | Automated egg incubation and claiming, pen placement rules ("Always" vs "Steal Idle"), bulk pet selling with whitelist protection. |
| **`06_minigames_special_events.lua`** | **Minigames & Events** | `RF/Fishing/Cast`, `RE/ShootingStar/Catch`, `RF/AlienLagoon/Trade` | Automated fishing system, Shooting Star tracker, Alien Lagoon pearl trading, Banjo Cricket rhythm claim, Away earnings, Codex redeem all. |
| **`07_player_movement_esp.lua`** | **Movement, ESP & Anti-Guard** | `AssemblyLinearVelocity`, `RagdollEndTime`, `Drawing` | Fast tween interpolation, Ragdoll TP desync exploit, speed boost clamp bypass, player/egg ESP, Anti-Guard connection disables (`gdP`). |
| **`08_ui_config_webhooks.lua`** | **UI Config & Webhooks** | `HttpService`, JSON Profiles, Discord Webhook | Auto save/load configuration profiles, startup presets, Discord rich embeds for rare egg notifications, FPS booster. |
| **`09_server_hop.lua`** | **Server Hop & Auto-Hop** | `TeleportService`, `HttpGet` Games API, `SAE_AutoHop.json` | Queries Roblox public server list, sort order (Least/Most Players, Random), 30-min visited cache, triggers on steal, rare egg, or idle. |
| **`10_combat_bat_swing.lua`** | **Combat & Bat Swing** | `RE/BatSwing/Trigger`, `RE/ToolTrigger/Trigger` | Weapon detector (bat/sword/hammer), cooldown attribute management, trajectory prediction with ping sync, attack sequence payload. |
| **`11_admin_abuse_live_events.lua`** | **Admin Abuse & Live Events** | `RF/LiveEvents/FetchRunning`, `RF/IslandWars/Fetch` | Admin Treadmill auto mounting/dismounting, Pete Space Raid phase tracking, Cursed Island Wars, Capture The Egg, AdminAbuseEggSpawn. |
| **`12_rig_sync_anti_desync.lua`** | **Rig Sync & Anti-Desync** | `RE/RigSync/AskRigWipe`, `ProbeSatchel`, `SeedSatchel` | Character desync / ghost mode (ServerBreakJoints, HipHeight=999), gear satchel sync, clean death / respawn recovery loop. |

---

## 2. Key Upvalues & Helper Reference

```lua
LocalPlayer                = game:GetService("Players").LocalPlayer
getHumanoid()              = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
getRootPart()              = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
isInsideSafeZone(pos)      = pos.X < 552.2 and pos.Y < 1000
getSeparationLinePos()     = Vector3.new(552.2, 67.67, 0)
getRiftMachinePos()        = Vector3.new(528.7, 70.57, -364.11)
isRagdolled()              = LocalPlayer:GetAttribute("RagdollEndTime") > Workspace:GetServerTimeNow()
invokeServerWithTimeout    = Calls remote with 15-second protective timeout (prevents BAC thread stall)
```

---

## 3. How to Use & Integrate with `mygame1_thai_ui_clean.lua`

1. **Server Hop (`09_server_hop.lua`)**:
   - Integrate the public server fetcher and visited server cache (`SAE_AutoHop.json`) into the Hop tab.
2. **Auto Bat Swing (`10_combat_bat_swing.lua`)**:
   - Implement the weapon reach calculation and `RE/BatSwing/Trigger` sequence payload (`UserId:Counter:Timestamp`) for defense while stealing.
3. **Admin Abuse & Events (`11_admin_abuse_live_events.lua`)**:
   - Add auto detection for Admin Treadmill, AdminAbuseEggSpawn, and Cursed Island Wars in the Events tab.
4. **Desync & RigSync (`12_rig_sync_anti_desync.lua`)**:
   - Use `RE/RigSync/AskRigWipe` handling and clean character reset patterns to prevent BAC-9511 disconnects.
