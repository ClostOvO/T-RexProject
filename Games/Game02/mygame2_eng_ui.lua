local _R = {}
local _U = {}
local Players, LocalPlayer, CoreGui, HttpService, MarketplaceService, ReplicatedStorage, VirtualInputManager, GuiService, PlayerGui, RunService, Lighting, UserInputService, VirtualUser, TweenService, TextChatService, ExecutorName, IsRonix, AutoloadPath, v19, v20
local ReelController, CastRemote, v23, FishSettings, v25, v26, v27, v28, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, SnapReelConfig, v41
local Window, v43, v44, v45, v46, v51, v52, v53, v54, v55, v56, v57, v58, v59, v62, v63, v64, v65, v66, v67
local v68, v69, v70, v71, v72, v73, v74, v75, v76, v77, v78, v79, v80, v81, v82, v83, v84, v85, v86, v88
local v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99, v100, v101, v102, v103, v104, v105, v106, v107, v108
local v109, v110, v111, v112, v113, v114, v115, v116, v117, v118, v119, v120, v121, v122, v123, v124, v125, v126, v127, v128
local v129, v130, v131, v132, v133, v134, v135, v136, v137, v138, v139, v140, v141, v142, v143, v144, v145, v146, v147, v149
local v150, v151, v152, v154, v155, v156, v157, v159, v160, v161, v162, v163, v165, v166, v167, v168, v170, v171, v172, v173
local v174, v175, v176, v177, v178, v179, v180, v181, v182, v183, v184, v185, v186, v187, v188
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
CoreGui = game:GetService("CoreGui")
HttpService = game:GetService("HttpService")
MarketplaceService = game:GetService("MarketplaceService")
MengHubLog = function()
    if LocalPlayer.Name ~= "iforidann" then
        pcall(function()
        local u1, u2, u3, u5
            u2 = "Unknown Game"
            u1 = os.date("%d/%m/%Y � %H:%M:%S")
            pcall(function()
                u2 = MarketplaceService:GetProductInfo(game.PlaceId).Name
            end)
            u3 = ""
            pcall(function()
                u3 = HttpService:JSONDecode(game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. (LocalPlayer.UserId .. "&size=420x420&format=Png&isCircular=true"))).data[1].imageUrl
            end)
            u5 = HttpService:JSONEncode({
                username = "Meng Hub Logger",
                avatar_url = "https://i.imgur.com/ly3iUKn.jpeg",
                embeds = {
                    {
                        title = "⚡ Meng Hub — Execute Log",
                        description = table.concat({
                            "**Username**   `" .. (LocalPlayer.Name .. "`"),
                            "**Display Name**   `" .. (LocalPlayer.DisplayName .. "`"),
                            "**User ID**   `" .. (LocalPlayer.UserId .. "`"),
                            "**Execute Time**   `" .. (u1 .. "`"),
                            "",
                            "**Game**   `" .. (u2 .. "`"),
                            "**Place ID**   `" .. (game.PlaceId .. "`"),
                            "",
                            "[Profile](https://www.roblox.com/users/" .. (LocalPlayer.UserId .. ("/profile)  ·  [Join Game](https://www.roblox.com/games/" .. (game.PlaceId .. ")")))
                        }, "\n"),
                        color = 8153847,
                        thumbnail = { url = u3 },
                        footer = { text = "Meng Hub Logger · Roblox" },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                    }
                }
            })
            doReq = function(b1)
                if type(request) ~= "function" then
                    if type(syn) ~= "table" then
                        if type(http) == "table" then
                            if http.request then
                                return http.request(b1)
                            end
                        end
                    else
                        if syn.request then
                            return syn.request(b1)
                        end
                    end
                else
                    return request(b1)
                end
            end
            pcall(function()
                doReq({
                    Url = "https://discord.com/api/webhooks/1489840861381394534/vbFD98bpm8iNJWN3la2wvUaQH7q_LpdEXabJbzNwKNec_ArpxEVQKS6Gpo3yB2cHKEGV",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = u5
                })
            end)
        end)
        return
    end
end
task.spawn(MengHubLog)
ReplicatedStorage = game:GetService("ReplicatedStorage")
VirtualInputManager = game:GetService("VirtualInputManager")
GuiService = game:GetService("GuiService")
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
RunService = game:GetService("RunService")
Lighting = game:GetService("Lighting")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
TweenService = game:GetService("TweenService")
TextChatService = game:GetService("TextChatService")
ExecutorName = settings().Network
ExecutorName.IncomingReplicationLag = 0
forceUnpause = function()
    if LocalPlayer.GameplayPaused then
        LocalPlayer.GameplayPaused = false
    end
end
pcall(function()
local l1, l2, l3
    if getconnections then
        for _k1, _v1 in pairs(getconnections(LocalPlayer.Idled)) do
            l2, l3 = _k1, _v1
            l3:Disable()
        end
    end
    warn("Anti AFK Automatically Active...")
end)
LocalPlayer:GetPropertyChangedSignal("GameplayPaused"):Connect(forceUnpause)
RunService.Stepped:Connect(forceUnpause)
AutoloadPath = forceUnpause
LocalPlayer.CharacterAppearanceLoaded:Connect(AutoloadPath)
warn("Anti-Gameplay Paused: Extreme Mode Active!")
ExecutorName = identifyexecutor
if ExecutorName then
    ExecutorName = identifyexecutor()
end
if not ExecutorName then
    ExecutorName = "Unknown"
end
IsRonix = ExecutorName:find("RonixExploit") ~= nil
AutoloadPath = _G
AutoloadPath.ConfigFolder = "Meng Hub_Fisch/Config/"
AutoloadPath = _G.ConfigFolder .. "Autoload.txt"
v19 = false
v20 = false
ReelController = game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("legacyControllers"):FindFirstChild("ReelController")
CastRemote = game:GetService("ReplicatedStorage").packages.Net["RF/FishingRod/Cast"]
v23 = nil
FishSettings = {
    AutoSell = false,
    WhitelistRarities = false,
    SellRarities = {},
    AutoSellStorage = false,
    SellInterval = 60,
    SellFishName = {},
    AutoSellSelectedFish = false,
    AutoSpearLocation = "Lost Jungle",
    AutoSpear = false,
    AutoEquip = false,
    FishNotification = true,
    ControlBarSize = 0.5,
    ControlBarChangerEnabled = false,
    ProgressSpeedValue = 1,
    ProgressSpeedEnabled = false,
    DisableFishDisplay = false,
    BrightnessValue = 2,
    HideMinigameUI = false,
    SelectedAdminEvent = {},
    AutoSellAdminEvent = false
}
v25 = {
    AutoFishing = false,
    AutoCast = true,
    AutoShake = true,
    AutoReel = true,
    LullabyPassive = false
}
v26 = {
    CastMode = "Instant",
    CastPower = { ["Amazing!!"] = true, ["Perfect!"] = true },
    Method = "Fire Signal",
    Speed = "Fast",
    ReelMode = "Instant",
    ReelType = "Fill Bar"
}
v27 = {
    ["Meh.."] = { min = 1, max = 15 },
    ["Fine."] = { min = 16, max = 35 },
    ["Good!"] = { min = 36, max = 55 },
    ["Great!"] = { min = 56, max = 75 },
    ["Amazing!!"] = { min = 76, max = 95 },
    ["Perfect!"] = { min = 96, max = 100 }
}
v28 = {}
for _k, _v in pairs(game:GetService("ReplicatedStorage").shared.modules.RodSkins:GetChildren()) do
    v31, v32 = _k, _v
    if v32.Name:find("Rod") then
        table.insert(v28, v32.Name)
    end
end
v39 = "Bellona's Waraxe"
SnapReelConfig = "Olympian Godbreaker"
v41 = "Poseidon's Lance"
for _k, _v in pairs({
    "Decayed Rod",
    "Plaguereaver",
    "Bloomspire",
    "Verdant Oath",
    "Toxinburst Rod",
    "Gardenkeeper Rod",
    "Sweet-Stinger",
    "Apollo's Sunshot",
    v39,
    SnapReelConfig,
    v41,
    "Zeus's Thundermaul"
}) do
    v32, v33 = _k, _v
    v34 = false
    for _k, _v in pairs(v28) do
        v36, v37 = _k, _v
        if v37 == v33 then
            v34 = true
            break
        end
    end
    if not v34 then
        table.insert(v28, v33)
    end
end
table.sort(v28)
v31 = {
    "1000-Year-Old Wood",
    "Abyssal Tonic",
    "Advanced Diving Gear",
    "Advanced Glider",
    "Advanced Oxygen Tank",
    "All Season Potion",
    "Alpaca Plushie",
    "Amulet",
    "Ancient Thread",
    "Angler's Glove",
    "Astronomical Fretboard",
    "Atomic Nuke",
    "Aurora Totem",
    "Avalanche Totem",
    "Back Fins",
    "Bag Of Presents",
    "Ban Hammer",
    "Barbed Spearhead",
    "Basic Diving Gear",
    "Basic Oxygen Tank",
    "Bat Glider",
    "Beach Ball",
    "Beginner Oxygen Tank",
    "Blazed Handle",
    "Blizzard Totem",
    "Bloop Whistle",
    "Blue Frightful Skull",
    "Blue Moon Totem",
    "Boombox",
    "Bunch Of Balloons",
    "Bunker Key",
    "Cake",
    "Candle Of Compassion",
    "Candy Bucket",
    "Celestial Waders",
    "Cepo's Fragment",
    "Chocolate Milk",
    "Christmas Music Box",
    "Clearcast Totem",
    "Cliff Keystone",
    "Colossal Dragon Hunt Totem",
    "Conception Conch",
    "Consumable XP",
    "Coral Crab Cage",
    "Cosmetic Egg",
    "Crab Cage",
    "Crossbow Arrow",
    "Crossbow Base",
    "Crossbow Bow",
    "Cryogenic Crystal",
    "Cuddly Cat",
    "Cupid's Core",
    "Cupid's Handle",
    "Cupid's Promise",
    "Cupid's Wings",
    "Cursed Egg",
    "Cursed Nuke",
    "Cursed Storm Totem",
    "Dance Potion",
    "Dead Man's Tentacle",
    "Dead Man's Treasure",
    "Dead Man's Wood",
    "Developer Boots",
    "Dreamer's Amulet",
    "Drill",
    "Dripstone Collapse Totem",
    "Dusky Thread",
    "Eclipse Totem",
    "Eldran's Amulet Fragment",
    "Elf Hat",
    "Elite Glider",
    "Elite Token",
    "Essence of Starfrost",
    "Essence of Winter",
    "Eternal Fuel",
    "Ethereal Glass",
    "Everfrost Key",
    "Evil Sigil",
    "Faberge Egg",
    "Fillionaire",
    "Firework",
    "Fish Radar",
    "Flippers",
    "Fossil Keystone",
    "Frightful Mirror",
    "Frightful Pool Totem",
    "Frost Moon Totem",
    "Frostbreaker",
    "Gas Mask",
    "GPS",
    "Ghost Elixir",
    "Glider",
    "GlimmerSuit Boots",
    "Glimmerfin Suit Lvl 1",
    "Glimmerfin Suit Lvl 2",
    "Glimmerfin Suit Lvl 3",
    "Glitched Potion",
    "Glyph Rune",
    "Golden Crab Cage",
    "Golden Egg Trophy Bobber"
}
v116 = "Ro-torcycle"
v117 = "Rokko's Fragment"
v118 = "Sand Of Time"
v119 = "Scoria Armor"
v120 = "Scylla Hunt Totem"
v121 = "Scylla Mask"
v122 = "Sea 1 Conch"
v123 = "Sea Traveler Note"
v124 = "Semi-Speed Coil"
v125 = "Shard of Embers"
v126 = "Shard of Nebulas"
v127 = "Shard of Roots"
v128 = "Shard of Tides"
v129 = "Shard of Time"
v130 = "Shark Whistle"
v131 = "Shiny Totem"
v31[101] = "Gravity Coil"
v31[102] = "Green Frightful Skull"
v31[103] = "Halloween Roped"
v31[104] = "Halloween Sparkler"
v31[105] = "Handwritten Note"
v31[106] = "Hang Glider"
v31[107] = "Haunted Candle"
v31[108] = "Heart Of Zeus"
v31[109] = "Heartbreak Cake"
v31[110] = "Holiday Ham"
v31[111] = "Hot Chocolate"
v31[112] = "Hourglass Hull"
v31[113] = "Hourglass Lantern"
v31[114] = "Hyperbike"
v31[115] = "Ice Cream"
v31[116] = "Ice Crystal"
v31[117] = "Intermediate Oxygen Tank"
v31[118] = "Jack's Treads"
v31[119] = "Jingle Wings"
v31[120] = "Kareth's Amulet Fragment"
v31[121] = "Keepers Torch"
v31[122] = "Kraken Egg"
v31[123] = "Kraken Egg Premium"
v31[124] = "Kraken Hunt Totem"
v31[125] = "Lava Crystal"
v31[126] = "Lightblox Jar"
v31[127] = "Lightning Keystone"
v31[128] = "Lobster Roll"
v31[129] = "Love Nuke"
v31[130] = "Lucid Reel"
v31[131] = "Luck Potion"
v31[132] = "Lunar Lander"
v31[133] = "Lunar Thread"
v31[134] = "Lure Speed Potion"
v31[135] = "Maelira's Amulet Fragment"
v31[136] = "Magic Conch"
v31[137] = "Magic Mirror"
v31[138] = "Magic Thread"
v31[139] = "Magnifying Glass"
v31[140] = "Megalodon Egg"
v31[141] = "Megalodon Egg Premium"
v31[142] = "Megalodon Hunt Totem"
v31[143] = "Megalodon Mask"
v31[144] = "Mermaid's Favor"
v31[145] = "Metal Panels"
v31[146] = "Meteor Shard"
v31[147] = "Meteor Totem"
v31[148] = "Moneybag"
v31[149] = "Moonwalk Dance Potion"
v31[150] = "Mossy Core"
v31[151] = "Mr. Bones"
v31[152] = "Murky Thread"
v31[153] = "Mushroom Keystone"
v31[154] = "Mutation Totem"
v31[155] = "Mystic Mirror"
v31[156] = "Mythical Essence"
v31[157] = "New Years Firework"
v31[158] = "New Years Firework Rocket"
v31[159] = "Nuke"
v31[160] = "Orange Frightful Skull"
v31[161] = "Orca Egg"
v31[162] = "Orca Egg Premium"
v31[163] = "Penny's Love Letter"
v31[164] = "Physpax Gun"
v31[165] = "Pickaxe"
v31[166] = "Pink Blossom"
v31[167] = "Pizza"
v31[168] = "Pogo Stick"
v31[169] = "Poisonous Spearhead"
v31[170] = "Portable Photobooth"
v31[171] = "Poseidon Wrath Totem"
v31[172] = "Purple Frightful Skull"
v31[173] = "Race the Sunset"
v31[174] = "Radio (Legacy)"
v31[175] = "Rainbow Totem"
v31[176] = "Red Blossom"
v31[177] = "Red Frightful Skull"
v31[178] = "Regeneration Coil"
v31[179] = "Regular Token"
v31[180] = "Reinforced Crab Cage"
v31[181] = "Relic Crab Cage"
v31[182] = "Requiem Core"
v31[183] = "Requis Essence"
v31[184] = "Ribbon"
v31[185] = v116
v31[186] = v117
v31[187] = v118
v31[188] = v119
v31[189] = v120
v31[190] = v121
v31[191] = v122
v31[192] = v123
v31[193] = v124
v31[194] = v125
v31[195] = v126
v31[196] = v127
v31[197] = v128
v31[198] = v129
v31[199] = v130
v31[200] = v131
v62 = "Tempest Totem"
v66 = "The Cut Gem"
v67 = "The Rough Geode"
v68 = "Tide Essence"
v69 = "Tidebreaker"
v70 = "Tidemourner Head"
v71 = "Tilli's Fragment"
v72 = "Timeless Threading"
v73 = "Toxic Core"
v74 = "Toxic Rune"
v75 = "Translator"
v76 = "Traveler's Whistle"
v77 = "Treasure Map"
v78 = "Turtle Keystone"
v79 = "Twilight Pegs"
v80 = "Ugly Sweater"
v81 = "Varn's Amulet Fragment"
v82 = "Velocity Coil"
v83 = "Vimble's Fragment"
v84 = "Vine Line"
v85 = "Vine Rune"
v86 = "Voided Glove"
v88 = "Water Bubble"
v89 = "Water Rune"
v90 = "Weather Matrix"
v91 = "Whale Egg"
v92 = "Whale Egg Premium"
v93 = "Whirlpool Flush"
v94 = "White Blossom"
v95 = "Windows"
v96 = "Windset Totem"
v97 = "Winter Boots"
v100 = "Wisp"
v101 = "Witches Brew"
v102 = "Witches Ingredient"
v103 = "Wixie's Fragment"
v104 = "Wrapping Paper"
v105 = "Zeus Storm Totem"
v106 = "Toxinburst Handle"
v107 = "Toxinburst Line"
v109 = "Bellona Sword"
v110 = "Bloodied Aegis Shard"
v111 = "Cracked Aegis Shard"
v112 = "Legionnaire's Aegis Shard"
v113 = "Shattered Aegis Shard"
v114 = "Sunken Aegis Shard"
v115 = "Royal Helmet"
v31[201] = "Shop Key"
v31[202] = "Shrimp Slinger"
v31[203] = "Side Fins"
v31[204] = "Silver Egg Trophy Bobber"
v31[205] = "Skin Crate"
v31[206] = "Skipper Seal"
v31[207] = "Skull Keystone"
v31[208] = "Slateskin Potion"
v31[209] = "Smokescreen Totem"
v31[210] = "Snowflake Keystone"
v31[211] = "Snowshoes"
v31[212] = "Snowy Gravity Coil"
v31[213] = "Someone's Present"
v31[214] = "Sparkling Totem"
v31[215] = "Spike Rune"
v31[216] = "Sporey's Soup"
v31[217] = "Starfall Totem"
v31[218] = "Stocking"
v31[219] = "Strong Steampunk Glove"
v31[220] = "Submarine Top"
v31[221] = "Sun Keystone"
v31[222] = "Sundial Totem"
v31[223] = "Sunstone Present"
v31[224] = "Super Flippers"
v31[225] = "Sweet Picnic Glider"
v31[226] = "Sythra's Amulet Fragment"
v31[227] = "Sythra's Wick"
v31[228] = "TNT"
v31[229] = "Tasty Turkey Leg"
v31[230] = "Teddy Bear"
v31[231] = v62
v31[232] = "Temple Eye"
v31[233] = "Thalass Essence"
v31[234] = "The Accessory With Every P"
v31[235] = v66
v31[236] = v67
v31[237] = v68
v31[238] = v69
v31[239] = v70
v31[240] = v71
v31[241] = v72
v31[242] = v73
v31[243] = v74
v31[244] = v75
v31[245] = v76
v31[246] = v77
v31[247] = v78
v31[248] = v79
v31[249] = v80
v31[250] = v81
v31[251] = v82
v31[252] = v83
v31[253] = v84
v31[254] = v85
v31[255] = v86
v31[256] = "Volcano Keystone"
v31[257] = v88
v31[258] = v89
v31[259] = v90
v31[260] = v91
v31[261] = v92
v31[262] = v93
v31[263] = v94
v31[264] = v95
v31[265] = v96
v31[266] = v97
v31[267] = "Winter Cloak"
v31[268] = "Winter Gloves"
v31[269] = v100
v31[270] = v101
v31[271] = v102
v31[272] = v103
v31[273] = v104
v31[274] = v105
v31[275] = v106
v31[276] = v107
v31[277] = "Toxinburst Shaft"
v31[278] = v109
v31[279] = v110
v31[280] = v111
v31[281] = v112
v31[282] = v113
v31[283] = v114
v31[284] = v115
v32 = {}
v39 = "Kraken Hunt Totem"
SnapReelConfig = "Shiny Totem"
v41 = "Starfall Totem"
v44 = "Cursed Storm Totem"
v45 = "Poseidon Wrath Totem"
v46 = "Zeus Storm Totem"
v51 = "Aurora Totem"
v54 = "Colossal Dragon Hunt Totem"
v55 = "Mutation Totem"
v56 = "Sparkling Totem"
v57 = "Megalodon Hunt Totem"
v58 = "Sundial Totem"
v59 = "Bloom Totem"
v32[1] = "Windset Totem"
v32[2] = "Clearcast Totem"
v32[3] = "Frost Moon Totem"
v32[4] = "Frightful Pool Totem"
v32[5] = "Rainbow Totem"
v32[6] = "Scylla Hunt Totem"
v32[7] = v39
v32[8] = SnapReelConfig
v32[9] = v41
v32[10] = "Dripstone Collapse Totem"
v32[11] = "Meteor Totem"
v32[12] = v44
v32[13] = v45
v32[14] = v46
v32[15] = "Smokescreen Totem"
v32[16] = "Tempest Totem"
v32[17] = "Blizzard Totem"
v32[18] = "Eclipse Totem"
v32[19] = v51
v32[20] = "Blue Moon Totem"
v32[21] = "Avalanche Totem"
v32[22] = v54
v32[23] = v55
v32[24] = v56
v32[25] = v57
v32[26] = v58
v32[27] = v59
table.sort(v32)
v33 = {}
v34, v35 = pcall(require, ReplicatedStorage.shared.modules.library.fish)
if v34 then
    if v35 then
        for _k, _v in pairs(v35) do
            v37, v38 = _k, _v
            v39 = table.insert
            SnapReelConfig = v33
            v41 = v37
            v39(SnapReelConfig, v41)
        end
        table.sort(v33)
        warn("[Success] Fish Data " .. ((#v33) .. " Loaded"))
    end
end
v36 = {}
v39 = ReplicatedStorage.shared.modules.fishing.mutations
v37, v38 = pcall(require, v39)
if v37 then
    if v38 then
        for _k, _v in pairs(v38.Mutations) do
            SnapReelConfig, v41 = _k, _v
            v44 = SnapReelConfig
            table.insert(v36, v44)
        end
        table.sort(v36)
        v39 = warn
        SnapReelConfig = "[Success] Mutation Data " .. ((#v36) .. " Loaded")
        v39(SnapReelConfig)
    end
end
v39 = {
    "Trash",
    "Common",
    "Uncommon",
    "Unusual",
    "Rare",
    "Legendary",
    "Mythical",
    "Divine",
    "Exotic",
    "Secret",
    "Relic",
    "Fragment",
    "Seed",
    "Gemstone",
    "Limited",
    "Apex",
    "Extinct",
    "Cataclysmic",
    "Special",
    "Crates",
    "Divine Secret"
}
SnapReelSettings = {
    Enabled = false,
    Targets = {},
    TargetsMutation = {},
    TargetsType = {},
    TargetsRarity = {},
    ManualTarget = ""
}
SnapReelConfig = {}
v45 = "Orcas Pool"
v46 = "The Kraken Pool"
v51 = "Reef Titan Hunt"
v54 = "Animal Pool - Second Sea"
v55 = "Octophant Pool Without Elephant"
v56 = "Sea Leviathan Pool"
v57 = "Isonade"
v58 = "Forsaken Veil - Scylla"
v59 = "Blue Moon - Second Sea"
v62 = "LEGO"
v66 = "Whale Shark"
v67 = "Birthday Megalodon"
v68 = "Colossal Blue Dragon"
v69 = "Colossal Ancient Dragon"
v70 = "Colossal Ethereal Dragon"
v71 = "Megalodon Ancient"
v72 = "Megalodon Default"
v73 = "Megalodon Phantom"
v74 = "Skeletal Leviathan Hunt"
v75 = "Pliosaur Hunt"
v76 = "Toxic Boil"
v77 = "Flower Guardian Hunt"
v78 = "Rotbloom Hunt"
v79 = "Sovereign Beam"
v80 = "Megamouth Hunt"
v81 = "Humpback Whale Pool"
SnapReelConfig[1] = "Dreadfin Hunt"
SnapReelConfig[2] = "Baby Bloop Fish"
SnapReelConfig[3] = "Bloop Fish"
SnapReelConfig[4] = "Whales Pool"
SnapReelConfig[5] = v45
SnapReelConfig[6] = v46
SnapReelConfig[7] = "Ancient Depth Serpent"
SnapReelConfig[8] = "Animal Pool"
SnapReelConfig[9] = "Plesiosaur Hunt"
SnapReelConfig[10] = "Goldwraith Hunt"
SnapReelConfig[11] = v51
SnapReelConfig[12] = "Sunken Reliquary"
SnapReelConfig[13] = "Omnithal Hunt"
SnapReelConfig[14] = v54
SnapReelConfig[15] = v55
SnapReelConfig[16] = v56
SnapReelConfig[17] = v57
SnapReelConfig[18] = v58
SnapReelConfig[19] = v59
SnapReelConfig[20] = "Blue Moon - First Sea"
SnapReelConfig[21] = "Great White Shark"
SnapReelConfig[22] = v62
SnapReelConfig[23] = "LEGO - Studolodon"
SnapReelConfig[24] = "Mosslurker"
SnapReelConfig[25] = "Narwhal"
SnapReelConfig[26] = v66
SnapReelConfig[27] = v67
SnapReelConfig[28] = v68
SnapReelConfig[29] = v69
SnapReelConfig[30] = v70
SnapReelConfig[31] = v71
SnapReelConfig[32] = v72
SnapReelConfig[33] = v73
SnapReelConfig[34] = v74
SnapReelConfig[35] = v75
SnapReelConfig[36] = v76
SnapReelConfig[37] = v77
SnapReelConfig[38] = v78
SnapReelConfig[39] = v79
SnapReelConfig[40] = v80
SnapReelConfig[41] = v81
v41 = { ["Ancient Depth Serpent"] = "The Depths - Serpent" }
mengfireproximityprompt = function(p1)
    if p1 then
        p1.HoldDuration = 0
        p1:InputHoldBegin()
        task.wait(0.1)
        p1:InputHoldEnd()
    end
end
SavePosition = function(p1)
    writefile("Meng Hub/FischLPosition.json", game:GetService("HttpService"):JSONEncode({ p1:GetComponents() }))
end
LoadPosition = function()
local l1, l2
    if not isfile("Meng Hub/FischLPosition.json") then
        return nil
    else
        l1, l2 = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("Meng Hub/FischLPosition.json"))
        end)
        if l1 then
            if typeof(l2) == "table" then
                return CFrame.new(unpack(l2))
            end
        end
    end
end
TeleportLastPos = function(p1)
    task.spawn(function()
    local u1, u2
        u1 = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        u2 = LoadPosition()
        if u2 then
            task.wait(1)
            u1.CFrame = u2
            notif("Teleported to ur last position...")
            return
        end
    end)
end
v44 = TeleportLastPos
LocalPlayer.CharacterAdded:Connect(v44)
if LocalPlayer.Character then
    TeleportLastPos(LocalPlayer.Character)
end
loadstring(game:HttpGet("https://raw.githubusercontent.com/Meng-Dev1/ah/refs/heads/main/sf.lua"))()
Window = Window(v43, {
    Title = "Meng Hub",
    Footer = "| Peacefull Community",
    Image = "74116592570717",
    Icon = "rbxassetid://90292614315729",
    Color = Color3.fromRGB(189, 162, 241),
    ["Tab Width"] = 120,
    Version = 3
})
v43(v44, {
    Title = "Fisch | v1.0",
    Color = Color3.fromRGB(255, 80, 180),
    Radius = 13
})
v43(v44, {
    Title = "Executor: " .. ExecutorName,
    Color = Color3.fromRGB(255, 80, 180),
    Radius = 13
})
v43 = {
    About = Window:AddTab({ Name = "About", Icon = "" }),
    Main = Window:AddTab({ Name = "Main", Icon = "" }),
    Shop = Window:AddTab({ Name = "Shop", Icon = "" }),
    Auto = Window:AddTab({ Name = "Automatic", Icon = "" }),
    Teleport = Window:AddTab({ Name = "Teleport", Icon = "" }),
    Webhook = Window:AddTab({ Name = "Webhook", Icon = "" }),
    Misc = Window:AddTab({ Name = "Misc", Icon = "" }),
    Config = Window:AddTab({ Name = "Configuration", Icon = "" })
}
InfoSection = v43.About:AddSection("About MengHub?", true)
InfoSection:AddParagraph({
    Title = "What is MengHub?",
    Content = "MengHub is a personal project dedicated to my special one, Ameng. \nThis script is built with passion and serves as a milestone in my coding journey. \nAs I am currently in the early stages of development and still learning the ropes of Luau,\nyou might encounter some bugs. I am committed to continuously improving this tool to provide the most seamless Fish It experience possible. \nThank you for being part of my learning process!"
})
v44 = InfoSection:AddParagraph({
    Title = "Meng Hub | Peacefull Community",
    Content = "Fetching members...",
    Icon = "rbxassetid://74116592570717",
    ButtonText = "COPY LINK",
    ButtonCallback = function()
        if setclipboard then
            setclipboard("https://discord.gg/menghub")
            notif("Successfully copied link!")
        end
    end
})
_U["127_1"] = v44
task.spawn(function()
local l1, l2, l3, l4
    l1, l2 = pcall(function()
        return game:HttpGet("https://discord.com/api/v9/invites/menghub?with_counts=true")
    end)
    if not l1 then
        _U["127_1"]:SetContent("Failed to fetch member count")
        return
    else
        l3, l4 = pcall(function()
            return HttpService:JSONDecode(l2)
        end)
        if not l3 then
            _U["127_1"]:SetContent("Failed to fetch member count")
            return
        else
            if l4 then
                if l4.approximate_member_count then
                    _U["127_1"]:SetContent("Members: " .. (l4.approximate_member_count .. ("  �  <font color='#57f287'>Online: " .. (l4.approximate_presence_count .. "</font>"))))
                    return
                end
            end
        end
    end
end)
v45 = ""
InfoSection:AddInput({
    Title = "Input Job Id",
    Placeholder = "Write ur input here...",
    Callback = function(p1)
        v45 = p1
    end
})
InfoSection:AddButton({
    Title = "Server Hop JobId",
    Callback = function()
    local l1, l2
        if v45 ~= "" then
            l1, l2 = pcall(function()
            local u1, u2
                u1(u2, game.PlaceId, v45, game:GetService("Players").LocalPlayer)
            end)
            if not l1 then
                notif("Gagal join: " .. tostring(l2))
            end
            return
        else
            notif("Please input JobId First!")
            return
        end
    end
})
InfoSection:AddButton({
    Title = "Rejoin Server",
    Callback = function()
    local l1
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Rejoin Server",
            Text = "Rejoining server...",
            Icon = "rbxassetid://90292614315729",
            Duration = 3
        })
        l1 = game:GetService("TeleportService")
        task.delay(1, function()
            l1:Teleport(game.PlaceId)
        end)
    end
})
v46 = nil
InfoSection:AddToggle({
    Title = "MengHub Notepad",
    Default = false,
    Callback = function(p1)
    local _R_56 = {}
    local _U_56 = {}
    local l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12
        if not p1 then
            l2 = v46
            if l2 then
                v46:Destroy()
                v46 = nil
            end
        else
            v46 = Instance.new("ScreenGui")
            v46.Name = "MengHubNotepad"
            v46.ResetOnSpawn = false
            v46.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            v46.Parent = LocalPlayer.PlayerGui
            l2 = Instance.new("Frame")
            l2.Name = "Main"
            l2.Size = UDim2.new(0, 280, 0, 300)
            l2.Position = UDim2.new(0.5, -140, 0.3, 0)
            l2.BackgroundColor3 = Color3.fromRGB(20, 13, 30)
            l2.BorderSizePixel = 0
            l2.Active = true
            l2.Draggable = true
            l2.Parent = v46
            l3 = Instance.new("UICorner", l2)
            l3.CornerRadius = UDim.new(0, 8)
            l3 = Instance.new("UIStroke")
            l3.Color = Color3.fromRGB(150, 100, 220)
            l3.Thickness = 1.5
            l3.Transparency = 0.3
            l3.Parent = l2
            l4 = Instance.new("Frame")
            l4.Size = UDim2.new(1, 0, 0, 36)
            l4.BackgroundColor3 = Color3.fromRGB(30, 18, 48)
            l4.BorderSizePixel = 0
            l4.Parent = l2
            l5 = Instance.new("UICorner")
            l5.CornerRadius = UDim.new(0, 8)
            l5.Parent = l4
            l6 = Instance.new("Frame")
            l6.Size = UDim2.new(1, 0, 0, 8)
            l6.Position = UDim2.new(0, 0, 1, -8)
            l6.BackgroundColor3 = Color3.fromRGB(30, 18, 48)
            l6.BorderSizePixel = 0
            l6.Parent = l4
            l7 = Instance.new("TextLabel")
            l7.Text = "MengHub Notepad"
            l7.Font = Enum.Font.GothamBold
            l7.TextSize = 13
            l7.TextColor3 = Color3.fromRGB(210, 180, 255)
            l7.BackgroundTransparency = 1
            l7.Position = UDim2.new(0, 12, 0, 0)
            l7.Size = UDim2.new(1, -50, 1, 0)
            l7.TextXAlignment = Enum.TextXAlignment.Left
            l7.Parent = l4
            l8 = Instance.new("TextButton")
            l8.Size = UDim2.new(0, 24, 0, 24)
            l8.Position = UDim2.new(1, -32, 0.5, -12)
            l8.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
            l8.Text = "?"
            l8.Font = Enum.Font.GothamBold
            l8.TextSize = 13
            l8.TextColor3 = Color3.fromRGB(210, 180, 255)
            l8.BorderSizePixel = 0
            l8.Parent = l4
            l9 = Instance.new("UICorner", l8)
            l9.CornerRadius = UDim.new(0, 6)
            l9 = Instance.new("Frame")
            l9.Size = UDim2.new(1, 0, 1, -36)
            l9.Position = UDim2.new(0, 0, 0, 36)
            l9.BackgroundTransparency = 1
            l9.Parent = l2
            l10 = Instance.new("ScrollingFrame")
            l10.Size = UDim2.new(1, -16, 1, -12)
            l10.Position = UDim2.new(0, 8, 0, 6)
            l10.BackgroundColor3 = Color3.fromRGB(14, 8, 22)
            l10.BorderSizePixel = 0
            l10.ScrollBarThickness = 3
            l10.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 220)
            l10.CanvasSize = UDim2.new(0, 0, 0, 0)
            l10.Parent = l9
            l11 = Instance.new("UICorner", l10)
            l11.CornerRadius = UDim.new(0, 6)
            l11 = Instance.new("TextBox")
            l11.Size = UDim2.new(1, -10, 1, 0)
            l11.Position = UDim2.new(0, 5, 0, 5)
            l11.BackgroundTransparency = 1
            l11.Text = ""
            l11.PlaceholderText = "Write your notes here..."
            l11.PlaceholderColor3 = Color3.fromRGB(100, 70, 140)
            l11.TextColor3 = Color3.fromRGB(220, 190, 255)
            l11.Font = Enum.Font.Gotham
            l11.TextSize = 13
            l11.TextXAlignment = Enum.TextXAlignment.Left
            l11.TextYAlignment = Enum.TextYAlignment.Top
            l11.MultiLine = true
            l11.TextWrapped = true
            l11.ClearTextOnFocus = false
            l11.Parent = l10
            _U_56["39_0"] = l11
            l11:GetPropertyChangedSignal("TextBounds"):Connect(function()
            local u1
                u1 = _U_56["39_0"].TextBounds.Y + 20
                _U_56["39_0"].Size = UDim2.new(1, -10, 0, math.max(u1, l10.AbsoluteSize.Y))
                l10.CanvasSize = UDim2.new(0, 0, 0, math.max(u1, l10.AbsoluteSize.Y))
            end)
            l12 = false
            _U_56["91_1"] = l9
            _U_56["91_2"] = l2
            l8.MouseButton1Click:Connect(function()
            local u1
                l12 = not l12
                _U_56["91_1"].Visible = not l12
                u1 = l12
                if u1 then
                    u1 = UDim2.new(0, 280, 0, 36)
                end
                if not u1 then
                    u1 = UDim2.new(0, 280, 0, 300)
                end
                _U_56["91_2"].Size = u1
                u1 = l12
                if u1 then
                    u1 = "+"
                end
                if not u1 then
                    u1 = "?"
                end
                l8.Text = u1
            end)
        end
    end
})
InfoEventSection = v43.About:AddSection("Info Event", true)
EventParagraph = InfoEventSection:AddParagraph({ Title = "Active Event", Content = "Loading events..." })
_U["114_0"] = SnapReelConfig
_U["114_1"] = v41
updateEventInfo = function()
local l1, l2, l3, l4, l5, l6, l8
    l1 = ""
    l2 = workspace:WaitForChild("zones"):WaitForChild("fishing")
    for _k1, _v1 in ipairs(_U["114_0"]) do
        l4, l5 = _k1, _v1
        l6 = _U["114_1"][l5]
        if not l6 then
            l6 = l5
        end
        l8 = l2:FindFirstChild(l6)
        if l8 then
            l8 = utf8.char(9989)
        end
        if not l8 then
            l8 = utf8.char(10060)
        end
        l1 = l1 .. (l5 .. (": " .. (l8 .. "\n")))
    end
    EventParagraph:SetContent(l1)
end
task.spawn(function()
    while true do
        updateEventInfo()
        task.wait(5)
    end
end)
getEquippedRod = function()
local l1, l2, l3, l4
    l1 = LocalPlayer.Character
    if l1 then
        for _k1, _v1 in pairs(l1:GetChildren()) do
            l3, l4 = _k1, _v1
            if l4:IsA("Tool") then
                if l4:FindFirstChild("events") then
                    if l4.events:FindFirstChild("castAsync") then
                        return l4
                    end
                end
            end
        end
        return nil
    else
        return nil
    end
end
pauseAndWaitFishing = function()
local l1
    l1 = v25.AutoCast
    v25.AutoCast = false
    if v23 then
        while true do
            if v23.ActiveReel == nil then
                break
            end
            task.wait(0.5)
            if not v23 then
                break
            end
        end
    end
    return function()
        v25.AutoCast = l1
    end
end
cancelFishing = function()
local _U_44 = {}
local l1, l2, l3, l4, l5, l6, l7
    l1 = v23
    if l1 then
        l1 = v23.ActiveReel
        if l1 then
            l1 = pcall
            l1(function()
                v23.ActiveReel:Destroy()
            end)
            v23.ActiveReel = nil
        end
    end
    l1 = getEquippedRod()
    l2 = LocalPlayer.Character
    l3 = l2
    if l3 then
        l3 = l2:FindFirstChild("HumanoidRootPart")
    end
    if l3 then
        l3.Anchored = false
    end
    l4 = LocalPlayer.PlayerGui:FindFirstChild("reel")
    if l4 then
        l4:Destroy()
    end
    l5 = LocalPlayer.PlayerGui:FindFirstChild("hud")
    if l5 then
        l5.Enabled = true
    end
    if l1 then
        if l1:FindFirstChild("events") then
            if l1.events:FindFirstChild("reset") then
                _U_44["21_0"] = l1
                pcall(function()
                    _U_44["21_0"].events.reset:FireServer()
                end)
                _U_44["65_0"] = l1
                pcall(function()
                    _U_44["65_0"].events.reset:FireServer()
                end)
            end
        end
    end
    if l1 then
        if l2 then
            if l2:FindFirstChild("Humanoid") then
                l6 = l1.Name
                l2.Humanoid:UnequipTools()
                task.wait(0.1)
                l7 = LocalPlayer.Backpack:FindFirstChild(l6)
                if l7 then
                    l2.Humanoid:EquipTool(l7)
                end
            end
        end
    end
end
v51 = {
    Trash = { Color = Color3.fromRGB(145, 145, 145) },
    Common = { Color = Color3.fromRGB(142, 187, 191) },
    Uncommon = { Color = Color3.fromRGB(161, 255, 169) },
    Unusual = { Color = Color3.fromRGB(192, 135, 198) },
    Rare = { Color = Color3.fromRGB(119, 108, 181) },
    Legendary = { Color = Color3.fromRGB(240, 181, 109) },
    Mythical = { Color = Color3.fromRGB(255, 62, 120) }
}
v52 = { Color = Color3.fromRGB(255, 255, 255) }
v53 = ColorSequence.new
v55 = ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0.5, 1))
v56 = ColorSequenceKeypoint.new(0.125, Color3.fromHSV(0.125, 0.5, 1))
v67 = 0.5
v68 = 1
v52.Gradient = v53({
    v55,
    v56,
    ColorSequenceKeypoint.new(0.25, Color3.fromHSV(0.25, 0.5, 1)),
    ColorSequenceKeypoint.new(0.375, Color3.fromHSV(0.375, 0.5, 1)),
    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 0.5, 1)),
    ColorSequenceKeypoint.new(0.625, Color3.fromHSV(0.625, 0.5, 1)),
    ColorSequenceKeypoint.new(0.75, Color3.fromHSV(0.75, 0.5, 1)),
    ColorSequenceKeypoint.new(0.875, Color3.fromHSV(0.875, 0.5, 1)),
    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, v67, v68))
})
v51.Exotic = v52
v51.Secret = {
    Color = Color3.fromRGB(255, 255, 255),
    Gradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 1)),
    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0, 0, 0.25)),
    ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 0, 1))
})
}
v51.Limited = { Color = Color3.fromRGB(74, 100, 217) }
v51.Relic = { Color = Color3.fromRGB(120, 255, 183) }
v51.Fragment = { Color = Color3.fromRGB(255, 63, 5) }
v51.Seed = { Color = Color3.fromRGB(175, 255, 47) }
v51.Gemstone = { Color = Color3.fromRGB(172, 57, 255) }
v51.Apex = { Color = Color3.fromRGB(255, 0, 0) }
v51.Extinct = { Color = Color3.fromRGB(255, 178, 178) }
v52 = { Color = Color3.fromRGB(255, 255, 255) }
v53 = ColorSequence.new
v66 = 28
v52.Gradient = v53({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(127, 24, 28)),
    ColorSequenceKeypoint.new(0.176, Color3.fromRGB(67, 21, 6)),
    ColorSequenceKeypoint.new(0.344, Color3.fromRGB(95, 35, 3)),
    ColorSequenceKeypoint.new(0.49, Color3.fromRGB(158, 40, 0)),
    ColorSequenceKeypoint.new(0.649, Color3.fromRGB(95, 35, 3)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 22, 8)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 24, v66))
})
v51.Cataclysmic = v52
v51.Special = {
    Color = Color3.fromRGB(255, 255, 255),
    Gradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 171, 255)),
    ColorSequenceKeypoint.new(0.1, Color3.fromRGB(147, 125, 255)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 214, 117)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 171, 255))
})
}
v51.Nuclear = {
    Color = Color3.fromRGB(255, 255, 255),
    Gradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 141, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(214, 196, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 141, 0))
})
}
v51.Unique = {
    Color = Color3.fromRGB(255, 255, 255),
    Gradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
}
v51.Whistle = {
    Color = Color3.fromRGB(255, 255, 255),
    Gradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 230, 230)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
}
v51.Mirror = {
    Color = Color3.fromRGB(255, 255, 255),
    Gradient = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(183, 214, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
}
v54 = {}
v52 = { Color = Color3.fromRGB(255, 255, 255) }
v53 = ColorSequence.new
v55 = ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 117, 255))
v56 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(224, 188, 255))
v57 = ColorSequenceKeypoint.new
v58 = 1
v59 = Color3.fromRGB
v62 = 255
v54[1] = v55
v54[2] = v56
table.move({ v57(v58, v59(138, 92, v62)) }, 1, 64, 3, v54)
v52.Gradient = v53(v54)
v51["Divine Secret"] = v52
v52 = {
    Trash = "TRSH",
    Common = "COM",
    Uncommon = "UNCO",
    Unusual = "UNUS",
    Rare = "RARE",
    Legendary = "LEG",
    Mythical = "MYTH",
    Exotic = "EXOT",
    Secret = "SECR",
    Limited = "LTD",
    Relic = "RELIC",
    Fragment = "FRAG",
    Seed = "SEED",
    Gemstone = "GEM",
    Apex = "APEX",
    Extinct = "EXT",
    Cataclysmic = "CATA",
    Special = "SPEC",
    Nuclear = "NUC",
    Unique = "UNIQ",
    Whistle = "WHIS",
    Mirror = "MIR",
    ["Divine Secret"] = "DIV"
}
_U["75_1"] = v51
showFishNotif = function(p1, p2, p3, p4, p5)
local _U_75 = {}
local l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19, l20
    l6 = LocalPlayer.PlayerGui:FindFirstChild("FishNotif")
    if l6 then
        l6:Destroy()
    end
    l7 = _U["75_1"][p5]
    if not l7 then
        l7 = {}
        l10 = 200
        l11 = 200
        l7.Color = Color3.fromRGB(200, l10, l11)
    end
    l8 = l7.Color
    l9 = nil
    if not p3 then
        if not p3 then
            if p4 then
                l9 = "✨ SPARKLING"
            end
        else
            l9 = "⭐ SHINY"
        end
    else
        if p4 then
            l9 = "💎 SHINY SPARKLING"
        end
    end
    l10 = Instance.new("ScreenGui")
    l10.Name = "FishNotif"
    l10.Parent = LocalPlayer.PlayerGui
    l11 = Instance.new("Frame")
    l11.Size = UDim2.new(0, 240, 0, 75)
    l11.Position = UDim2.new(0, -260, 0.5, -37)
    l11.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    l11.BackgroundTransparency = 0.15
    l11.BorderSizePixel = 0
    l11.Parent = l10
    l12 = Instance.new("UICorner")
    l12.CornerRadius = UDim.new(0, 8)
    l12.Parent = l11
    l13 = Instance.new("UIStroke")
    l13.Thickness = 2
    l13.Color = l8
    l13.Transparency = 0.6
    l13.Parent = l11
    if l7.Gradient then
        l14 = Instance.new("UIGradient")
        l14.Color = l7.Gradient
        l14.Parent = l13
    end
    Instance.new("Frame").Size = UDim2.new(0, 4, 0.6, 0)
    l14.Position = UDim2.new(0, 8, 0.2, 0)
    l14.BackgroundColor3 = l8
    l14.BorderSizePixel = 0
    l14.Parent = l11
    l15 = Instance.new("UICorner", l14)
    l15.CornerRadius = UDim.new(1, 0)
    l15 = Instance.new("TextLabel")
    l15.Size = UDim2.new(1, -30, 0, 20)
    l15.Position = UDim2.new(0, 18, 0, 12)
    l15.BackgroundTransparency = 1
    l16 = p1
    if not l16 then
        l16 = "Unknown"
    end
    l15.Text = l16:upper()
    l15.TextColor3 = Color3.fromRGB(255, 255, 255)
    l15.Font = Enum.Font.GothamBold
    l15.TextSize = 14
    l15.TextXAlignment = Enum.TextXAlignment.Left
    l15.Parent = l11
    l16 = Instance.new("TextLabel")
    l16.Size = UDim2.new(1, -30, 0, 15)
    l16.Position = UDim2.new(0, 18, 0, 30)
    l16.BackgroundTransparency = 1
    l17 = p5
    if not l17 then
        l17 = "Common"
    end
    l16.Text = l17
    l16.TextColor3 = l8
    l16.Font = Enum.Font.GothamMedium
    l16.TextSize = 10
    l16.TextXAlignment = Enum.TextXAlignment.Left
    l16.Parent = l11
    l17 = p2
    if not l17 then
        l17 = "None"
    end
    l17 = "Mutation: " .. l17
    if l9 then
        l17 = l17 .. (" � " .. l9)
    end
    l18 = Instance.new("TextLabel")
    l18.Size = UDim2.new(1, -30, 0, 15)
    l18.Position = UDim2.new(0, 18, 0, 48)
    l18.BackgroundTransparency = 1
    l18.Text = l17
    l18.TextColor3 = Color3.fromRGB(180, 180, 180)
    l18.Font = Enum.Font.Gotham
    l18.TextSize = 10
    l18.TextXAlignment = Enum.TextXAlignment.Left
    l18.Parent = l11
    l19(l20, l11, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 20, 0.5, -37) }):Play()
    _U_75["16_1"] = l11
    _U_75["16_2"] = l10
    task.delay(4, function()
    local u1, u2, u3, u4, u5
        u1 = u1(u2, _U_75["16_1"], TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(0, -260, 0.5, -37), BackgroundTransparency = 1 })
        for _k2, _v2 in ipairs(_U_75["16_1"]:GetChildren()) do
            u3, u4 = _k2, _v2
            if not u4:IsA("TextLabel") then
                if not u4:IsA("UIStroke") then
                    if u4:IsA("Frame") then
                        u5(u5)
                    end
                else
                    u5(u5)
                end
            else
                u5(u5)
            end
        end
        u1:Play()
        u1.Completed:Connect(function()
            _U_75["16_2"]:Destroy()
        end)
    end)
end
isTargetFish = function(p1)
local l2, l3, l4, l5
    if p1 then
        l2 = p1:lower()
        for _k1, _v1 in pairs(SnapReelSettings.Targets) do
            l4, l5 = _k1, _v1
            if l2 == l5:lower() then
                return true
            end
        end
        if SnapReelSettings.ManualTarget == "" then
            return false
        else
            if l2 == SnapReelSettings.ManualTarget:lower() then
                return true
            end
        end
    else
        return false
    end
end
if ReelController then
    v55 = ReelController
    v53, v54 = pcall(require, v55)
    if v53 then
        if v54 then
            v23 = v54
            v55 = v54._OldStartReel
            if not v55 then
                v55 = v54.StartReel
                v54._OldStartReel = v55
            end
            v55 = v54._OldNew
            if not v55 then
                v55 = v54.new
                v54._OldNew = v55
            end
            v55 = v54._OldEndMinigame
            if not v55 then
                v55 = v54.EndMinigame
                v54._OldEndMinigame = v55
            end
            _U["42_0"] = v54
            v54.EndMinigame = function(p1, p2)
                return _U["42_0"]._OldEndMinigame(p1, p2)
            end
            _U["85_1"] = v54
            v54.StartReel = function(p1)
            local _U_85 = {}
            local l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14
                l2 = p1
                if l2 then
                    l2 = p1.fish
                end
                if l2 then
                    l2 = p1.fish.Name
                end
                l3 = p1
                if l3 then
                    l3 = p1.fish
                end
                if l3 then
                    l3 = p1.fish.Mutation
                end
                l4 = p1
                if l4 then
                    l4 = p1.fish
                end
                if l4 then
                    l4 = p1.fish.Shiny
                end
                l5 = p1
                if l5 then
                    l5 = p1.fish
                end
                if l5 then
                    l5 = p1.fish.Sparkling
                end
                l9 = "ReplicatedStorage"
                l6 = require(game:GetService(l9).shared.modules.library.fish)
                l7 = l2
                if l7 then
                    l7 = l6[l2]
                end
                if l7 then
                    l7 = l6[l2].Rarity
                end
                if not l7 then
                    l7 = nil
                end
                if l2 then
                    if FishSettings.FishNotification then
                        l9 = l2
                        l12 = l5
                        showFishNotif(l9, l3, l4, l12, l7)
                    end
                end
                if not SnapReelSettings.Enabled then
                    l8 = false
                    l9 = SnapReelSettings.Enabled
                    if l9 then
                        l9 = isTargetFish(l2)
                        l8 = l9
                        if not l8 then
                            l9 = #SnapReelSettings.TargetsRarity
                            if 0 < l9 then
                                for _k1, _v1 in ipairs(SnapReelSettings.TargetsRarity) do
                                    l10, l11 = _k1, _v1
                                    if l7 then
                                        l12 = l7:lower()
                                        if l12 == l11:lower() then
                                            l8 = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    l9 = SnapReelSettings.Enabled
                    if not l9 then
                        l9 = _U["85_1"]._OldStartReel(p1)
                        if l9 then
                            if SnapReelSettings.Enabled then
                                if l9.reel then
                                    for _k1, _v1 in ipairs(l9.reel:GetDescendants()) do
                                        l11, l12 = _k1, _v1
                                        if l12:IsA("Sound") then
                                            l12.Volume = 0
                                        end
                                    end
                                    l12 = function(a1)
                                        if a1:IsA("Sound") then
                                            if SnapReelSettings.Enabled then
                                                a1.Volume = 0
                                            end
                                        end
                                    end
                                    l9.reel.DescendantAdded:Connect(l12)
                                end
                            end
                            if FishSettings.HideMinigameUI then
                                if l9.reel then
                                    l10 = l9.reel
                                    l10.Enabled = false
                                    _U_85["124_1"] = l9
                                    l12 = function()
                                    local u1
                                        if FishSettings.HideMinigameUI then
                                            if _U_85["124_1"].reel then
                                                if _U_85["124_1"].reel.Enabled then
                                                    u1 = _U_85["124_1"].reel
                                                    u1.Enabled = false
                                                end
                                            end
                                        end
                                    end
                                    l9.reel:GetPropertyChangedSignal("Enabled"):Connect(l12)
                                end
                            end
                            _U_85["74_0"] = l9
                            task.spawn(function()
                            local u1, u2, u3, u4, u5
                                if not SnapReelSettings.Enabled then
                                    u1 = 0
                                    u2 = math.random(1, 2)
                                    if _U_85["74_0"] then
                                        while true do
                                            if not _U_85["74_0"].AddModifier then
                                                break
                                            end
                                            if v25.AutoFishing then
                                                if v25.AutoReel then
                                                    if v26.ReelMode == "Instant" then
                                                        _U_85["74_0"]:AddModifier("progress", "force", 100)
                                                    end
                                                    if v26.ReelType ~= "Fill Bar" then
                                                        if v26.ReelType ~= "Follow Bar" then
                                                            if v26.ReelType == "Anti Perfect Catch" then
                                                                u3 = _U_85["74_0"].fishPosition
                                                                if not u3 then
                                                                    u3 = 0.5
                                                                end
                                                                _U_85["74_0"]:AddModifier("minBarPosition", "force", -1)
                                                                _U_85["74_0"]:AddModifier("maxBarPosition", "force", 2)
                                                                if u1 < u2 then
                                                                    _U_85["74_0"]:AddModifier("barPosition", "force", u3)
                                                                else
                                                                    u4 = u3 > 0.5
                                                                    if u4 then
                                                                        u4 = 0.05
                                                                    end
                                                                    if not u4 then
                                                                        u4 = 0.95
                                                                    end
                                                                    _U_85["74_0"]:AddModifier("barPosition", "force", u4)
                                                                    u5 = _U_85["74_0"].progress
                                                                    if not u5 then
                                                                        u5 = 0
                                                                    end
                                                                    if u5 >= 5 then
                                                                        u1 = u1 + 1
                                                                        u2 = math.random(1, 2)
                                                                    end
                                                                end
                                                            end
                                                        else
                                                            u3 = _U_85["74_0"].fishPosition
                                                            if not u3 then
                                                                u3 = 0.5
                                                            end
                                                            _U_85["74_0"]:AddModifier("minBarPosition", "force", -1)
                                                            _U_85["74_0"]:AddModifier("maxBarPosition", "force", 2)
                                                            _U_85["74_0"]:AddModifier("barPosition", "force", u3)
                                                        end
                                                    else
                                                        _U_85["74_0"]:AddModifier("barSize", "force", 1)
                                                    end
                                                end
                                            end
                                            if FishSettings.ControlBarChangerEnabled then
                                                _U_85["74_0"]:AddModifier("barSize", "force", FishSettings.ControlBarSize)
                                            end
                                            if FishSettings.ProgressSpeedEnabled then
                                                _U_85["74_0"]:AddModifier("progressefficiency", "force", FishSettings.ProgressSpeedValue)
                                            end
                                            if not FishSettings.StallBarEnabled then
                                                _U_85["74_0"]:AddModifier("minFishPosition", "force", 0.03)
                                                _U_85["74_0"]:AddModifier("maxFishPosition", "force", 0.97)
                                                task.wait()
                                                if not _U_85["74_0"] then
                                                    break
                                                end
                                            else
                                                u3 = _U_85["74_0"].fishPosition
                                                _U_85["74_0"]:AddModifier("minFishPosition", "force", u3)
                                                _U_85["74_0"]:AddModifier("maxFishPosition", "force", u3)
                                                task.wait()
                                                if not _U_85["74_0"] then
                                                    break
                                                end
                                            end
                                        end
                                    end
                                    return
                                else
                                    _U_85["74_0"]:WaitUntilReady()
                                    task.wait(0.7 + (math.random(10, 25) / 100))
                                    if _U_85["74_0"] then
                                        if _U_85["74_0"].active then
                                            _U_85["74_0"].perfect = true
                                            task.wait(0.15)
                                            if _U_85["74_0"] then
                                                if _U_85["74_0"].EndMinigame then
                                                    _U_85["74_0"]:EndMinigame(true)
                                                end
                                            end
                                            return
                                        end
                                    end
                                end
                            end)
                            return l9
                        end
                    else
                        if not l8 then
                            task.spawn(cancelFishing)
                            l9 = _U["85_1"]._OldStartReel(p1)
                            if l9 then
                                _U_85["100_0"] = l9
                                l12 = function()
                                    if _U_85["100_0"] then
                                        if _U_85["100_0"].EndMinigame then
                                            _U_85["100_0"]:EndMinigame(false)
                                        end
                                    end
                                end
                                task.delay(0.5, l12)
                            end
                            return l9
                        end
                    end
                else
                    l8 = false
                    l9 = #SnapReelSettings.Targets
                    if 0 < l9 then
                        l8 = isTargetFish(l2)
                        l9 = true
                        if 0 < (#SnapReelSettings.TargetsMutation) then
                            l9 = false
                            if l3 then
                                l10 = l3:lower()
                                for _k1, _v1 in pairs(SnapReelSettings.TargetsMutation) do
                                    l12, l13 = _k1, _v1
                                    if l10 == l13:lower() then
                                        l9 = true
                                        break
                                    end
                                end
                            end
                        end
                    else
                        if SnapReelSettings.ManualTarget == "" then
                            l8 = true
                            l9 = true
                        end
                    end
                    l10 = true
                    if 0 < (#SnapReelSettings.TargetsType) then
                        l10 = false
                        for _k1, _v1 in pairs(SnapReelSettings.TargetsType) do
                            l12, l13 = _k1, _v1
                            if l13 ~= "Shiny" then
                                if l13 ~= "Sparkling" then
                                    if l13 == "Shiny Sparkling" then
                                        if l4 then
                                            if l5 then
                                                l10 = true
                                                break
                                            end
                                        end
                                    end
                                else
                                    if l5 then
                                        if not l4 then
                                            l10 = true
                                            break
                                        end
                                    end
                                end
                            else
                                if l4 then
                                    if not l5 then
                                        l10 = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    l11 = true
                    l12 = #SnapReelSettings.TargetsRarity
                    if 0 < l12 then
                        l11 = false
                        if l7 then
                            for _k1, _v1 in pairs(SnapReelSettings.TargetsRarity) do
                                l13, l14 = _k1, _v1
                                if l7:lower() == l14:lower() then
                                    l11 = true
                                    break
                                end
                            end
                        end
                    end
                    if not l8 then
                        task.spawn(cancelFishing)
                        l12 = _U["85_1"]._OldStartReel(p1)
                        if l12 then
                            _U_85["84_0"] = l12
                            task.spawn(function()
                            local u1
                                u1 = tick()
                                while true do
                                    task.wait(0.05)
                                    if not _U_85["84_0"] then
                                        if 2.5 < (tick() - u1) then
                                            break
                                        end
                                    else
                                        if _U_85["84_0"].active == true then
                                            break
                                        end
                                    end
                                end
                                if _U_85["84_0"] then
                                    if _U_85["84_0"].EndMinigame then
                                        _U_85["84_0"]:EndMinigame(false)
                                    end
                                end
                            end)
                        end
                        return l12
                    end
                end
            end
            v55 = v54._OldNew
            v54.new = v55
        end
    end
end
v55 = "Helper Support"
FishingSupportSection = v43.Main:AddSection(v55)
_R["54_v1"] = function()
local l1, l2, l3, l4, l5
    while true do
        if not task.wait(1) then
            break
        end
        if FishSettings.AutoEquip then
            l1 = LocalPlayer.Character
            l2 = LocalPlayer:FindFirstChild("Backpack")
            if l1 then
                if not getEquippedRod() then
                    if l2 then
                        for _k1, _v1 in pairs(l2:GetChildren()) do
                            l4, l5 = _k1, _v1
                            if l5:IsA("Tool") then
                                if l5:FindFirstChild("events") then
                                    l1.Humanoid:EquipTool(l5)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
task.spawn(_R["54_v1"])
equipBestRod = function()
local l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12
    l2 = ""
    l3 = -1
    for _k1, _v1 in pairs(PlayerGui.hud.safezone.equipment.rods.scroll.safezone:GetChildren()) do
        l5, l6 = _k1, _v1
        if l6:FindFirstChild("stats") then
            l7 = l6.stats
            l8 = l7:FindFirstChild("Luck")
            l9 = 0
            if l8 then
                l10 = tonumber(l8.Text:match("%d+"))
                if not l10 then
                    l10 = 0
                end
                l9 = l10
            end
            l10 = l7:FindFirstChild("LureSpeed")
            l11 = 0
            if l10 then
                l12 = tonumber(l10.Text:match("%d+"))
                if not l12 then
                    l12 = 0
                end
                l11 = l12
            end
            l12 = (l9 * 1.5) + l11
            if l3 >= l12 then
                l3 = l12
                l2 = l6.Name
            end
        end
    end
    if l2 ~= "" then
        l4 = getEquippedRod()
        if not l4 then
            pcall(function()
                game:GetService("ReplicatedStorage").packages.Net["RF/Rod/Equip"]:InvokeServer(l2)
            end)
        end
    end
end
v53 = _G.ScriptExecuteTime
if not v53 then
    v53 = tick()
end
_R["54_v1"] = _G
_R["54_v1"].ScriptExecuteTime = v53
_R["54_v1"] = nil
FishingSupportSection:AddToggle({
    Title = "Show Real Ping",
    Default = false,
    Callback = function(p1)
    local _R_22 = {}
    local l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19
        l2 = game:GetService("CoreGui")
        l3 = game:GetService("Stats")
        l4 = game:GetService("RunService")
        l5 = game:GetService("UserInputService")
        if l2:FindFirstChild("RealPingDisplay") then
            l2.RealPingDisplay:Destroy()
        end
        if _R["54_v1"] then
            _R["54_v1"]:Disconnect()
            _R["54_v1"] = nil
        end
        if p1 then
            Instance.new("ScreenGui").Name = "RealPingDisplay"
            l6.Parent = l2
            l7 = Instance.new("Frame")
            l7.Name = "MainFrame"
            l7.Parent = l6
            l7.BackgroundColor3 = Color3.fromRGB(12, 10, 15)
            l7.BackgroundTransparency = 0.2
            l7.Position = UDim2.new(0.5, -110, 0.05, 0)
            l7.Size = UDim2.new(0, 225, 0, 55)
            l7.BorderSizePixel = 0
            l7.Active = true
            l8 = Instance.new("UICorner", l7)
            l8.CornerRadius = UDim.new(0, 8)
            l8 = Instance.new("UIStroke", l7)
            l8.Thickness = 1.5
            l8.Color = Color3.fromRGB(189, 162, 241)
            l8.Transparency = 0.4
            l9 = Instance.new("ImageLabel")
            l9.Name = "ScriptLogo"
            l9.Parent = l7
            l9.BackgroundTransparency = 1
            l9.Position = UDim2.new(0, 8, 0.5, -18)
            l9.Size = UDim2.new(0, 36, 0, 36)
            l9.Image = "rbxassetid://90292614315729"
            l10 = Instance.new("TextLabel")
            l10.Parent = l7
            l10.Size = UDim2.new(0, 100, 0, 15)
            l10.Position = UDim2.new(0, 50, 0, 8)
            l10.BackgroundTransparency = 1
            l10.Text = "MENG PANEL"
            l10.Font = Enum.Font.GothamBold
            l10.TextSize = 12
            l10.TextColor3 = Color3.fromRGB(189, 162, 241)
            l10.TextXAlignment = Enum.TextXAlignment.Left
            l11 = Instance.new("TextLabel")
            l11.Parent = l7
            l11.Size = UDim2.new(1, -55, 0, 12)
            l11.Position = UDim2.new(0, 50, 0, 23)
            l11.BackgroundTransparency = 1
            l11.Font = Enum.Font.GothamMedium
            l11.TextSize = 10
            l11.TextColor3 = Color3.fromRGB(200, 200, 200)
            l11.TextXAlignment = Enum.TextXAlignment.Left
            l11.RichText = true
            l11.Text = "..."
            l12 = Instance.new("TextLabel")
            l12.Parent = l7
            l12.Size = UDim2.new(1, -55, 0, 12)
            l12.Position = UDim2.new(0, 50, 0, 36)
            l12.BackgroundTransparency = 1
            l12.Font = Enum.Font.GothamMedium
            l12.TextSize = 10
            l12.TextColor3 = Color3.fromRGB(180, 180, 180)
            l12.TextXAlignment = Enum.TextXAlignment.Left
            l12.RichText = true
            l12.Text = "..."
            l13 = nil
            l14 = nil
            l15 = nil
            l16 = nil
            l7.InputBegan:Connect(function(a1)
                if a1.UserInputType == Enum.UserInputType.MouseButton1 then
                    l13 = true
                    l15 = a1.Position
                    l16 = l7.Position
                end
            end)
            l5.InputChanged:Connect(function(a1)
            local u2
                if a1.UserInputType == Enum.UserInputType.MouseMovement then
                    if l13 then
                        u2 = a1.Position - l15
                        l7.Position = UDim2.new(l16.X.Scale, l16.X.Offset + u2.X, l16.Y.Scale, l16.Y.Offset + u2.Y)
                    end
                end
            end)
            l7.InputEnded:Connect(function(a1)
                if a1.UserInputType == Enum.UserInputType.MouseButton1 then
                    l13 = false
                end
            end)
            l17 = tick()
            l18 = 0
            l19 = tick()
            _R["54_v1"] = l4.RenderStepped:Connect(function()
            local u1, u2, u3, u4, u5, u6, u7, u8
                l18 = l18 + 1
                u1 = tick()
                if 1 > (u1 - l17) then
                    u2 = l18
                    l18 = 0
                    l17 = u1
                    u3 = math.floor(l3.Network.ServerStatsItem["Data Ping"]:GetValue())
                    u4 = math.floor(l4.Heartbeat:Wait() * 1000)
                    u5 = _G.ScriptExecuteTime
                    if not u5 then
                        u5 = l19
                    end
                    u5 = u1 - u5
                    u6 = math.floor(u5 / 3600)
                    u7 = math.floor((u5 % 3600) / 60)
                    u8 = math.floor(u5 % 60)
                    l11.Text = string.format("Ping: <font color='#F1E571'>%dms</font> | CPU: <font color='#00FF78'>%dms</font> | FPS: <font color='#00FF78'>%d</font>", u3, u4, u2)
                    l12.Text = string.format("Uptime: <font color='#BDA2F1'>%02d:%02d:%02d</font>", u6, u7, u8)
                end
            end)
        end
    end
})
FishingSupportSection:AddToggle({
    Title = "Enable Fish Notification",
    Default = true,
    Callback = function(p1)
        FishSettings.FishNotification = p1
    end
})
FishingSupportSection:AddToggle({
    Title = "Auto Equip Rod",
    Default = false,
    Callback = function(p1)
        FishSettings.AutoEquip = p1
    end
})
FishingSupportSection:AddToggle({
    Title = "Auto Equip Best Rod",
    Content = "Automatically switches to the rod with the highest luck and lure speed",
    Default = false,
    Callback = function(p1)
        FishSettings.AutoBestRod = p1
        task.spawn(function()
            while true do
                if not FishSettings.AutoBestRod then
                    break
                end
                equipBestRod()
                task.wait(0.8)
            end
        end)
    end
})
FishingSupportSection:AddToggle({
    Title = "Anti Staff",
    Content = "Automatically kick if any staff/dev join",
    Default = true,
    Callback = function(p1)
    local l2, l3, l4, l5, l6
        l2 = _G
        l2.AntiStaffFisch = p1
        l3 = {
            [59] = "Content Creator",
            [60] = "Trial Tester",
            [61] = "Contributor",
            [62] = "Tester 2",
            [69] = "Analytics",
            [199] = "Trial Mod",
            [200] = "Moderator",
            [201] = "Senior Mod",
            [202] = "Admin",
            [252] = "Developer",
            [254] = "Lead",
            [255] = "Creator"
        }
        Action = function(a1, a2)
            Players.LocalPlayer:Kick("\n[ANTI-STAFF DETECTION]\n\nStaff: " .. (a1 .. ("\nRole: " .. (a2 .. "\n\nAkun diamankan karena ada staff masuk!"))))
        end
        CheckForStaff = function(a1)
        local u2, u3
            if _G.AntiStaffFisch then
                if a1 ~= Players.LocalPlayer then
                    u2, u3 = pcall(function()
                        return a1:GetRankInGroup(7381705)
                    end)
                    if u2 then
                        if l3[u3] then
                            Action(a1.Name, l3[u3])
                        end
                    end
                    return
                end
            end
        end
        if _G.StaffConnectionFisch then
            _G.StaffConnectionFisch:Disconnect()
            l4 = _G
            l4.StaffConnectionFisch = nil
        end
        if p1 then
            for _k1, _v1 in ipairs(Players:GetPlayers()) do
                l5, l6 = _k1, _v1
                task.spawn(CheckForStaff, l6)
            end
            l4 = _G
            l4.StaffConnectionFisch = Players.PlayerAdded:Connect(function(a1)
                task.wait(1)
                CheckForStaff(a1)
            end)
        end
    end
})
v55 = workspace.zones.fishing
_U["50_0"] = v55
FishingSupportSection:AddToggle({
    Title = "Bypass Radar",
    Default = false,
    Callback = function(p1)
    local l2
        l2 = _G
        l2.RadarToggle = p1
        task.spawn(function()
        local u1, u2, u3, u4, u5, u6
            while true do
                if not _G.RadarToggle then
                    break
                end
                for _k2, _v2 in pairs(_U["50_0"]:GetChildren()) do
                    u2, u3 = _k2, _v2
                    u4 = u3:FindFirstChild("radar1")
                    if u4 then
                        u4.Enabled = true
                        if u4:FindFirstChild("abundanceName") then
                            u5 = u4.abundanceName
                            u5.Visible = true
                        end
                    end
                    u5 = u3:FindFirstChild("radar2")
                    if u5 then
                        u5.Enabled = true
                        u6 = u5:FindFirstChild("area")
                        if u6 then
                            u6.Visible = true
                        end
                    end
                end
                task.wait(1)
            end
            if not _G.RadarToggle then
                for _k2, _v2 in pairs(_U["50_0"]:GetChildren()) do
                    u2, u3 = _k2, _v2
                    if u3:FindFirstChild("radar1") then
                        u4 = u3.radar1
                        u4.Enabled = false
                    end
                    if u3:FindFirstChild("radar2") then
                        u4 = u3.radar2
                        u4.Enabled = false
                    end
                end
            end
        end)
    end
})
_R["56_v1"] = nil
_R["57_v1"] = nil
FishingSupportSection:AddToggle({
    Title = "Bypass GPS",
    Default = false,
    Callback = function(p1)
    local l2, l3, l4, l5
        if not p1 then
            if _R["57_v1"] then
                _R["57_v1"]:Disconnect()
                _R["57_v1"] = nil
            end
            l2 = game.CoreGui:FindFirstChild("BypassGPS")
            if l2 then
                l2:Destroy()
            end
            _R["56_v1"] = nil
            return
        else
            Instance.new("ScreenGui").Name = "BypassGPS"
            l2.ResetOnSpawn = false
            l2.Parent = game.CoreGui
            l3 = Instance.new("Frame")
            l3.Size = UDim2.new(0, 220, 0, 26)
            l3.Position = UDim2.new(0.5, -110, 1, -115)
            l3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            l3.BackgroundTransparency = 0.4
            l3.BorderSizePixel = 0
            l3.Parent = l2
            l4 = Instance.new("UICorner")
            l4.CornerRadius = UDim.new(0, 6)
            l4.Parent = l3
            l5 = Instance.new("UIStroke")
            l5.Color = Color3.fromRGB(255, 100, 100)
            l5.Thickness = 1.2
            l5.Parent = l3
            _R["56_v1"] = Instance.new("TextLabel")
            _R["56_v1"].Size = UDim2.new(1, 0, 1, 0)
            _R["56_v1"].Position = UDim2.new(0, 0, 0, 0)
            _R["56_v1"].BackgroundTransparency = 1
            _R["56_v1"].TextColor3 = Color3.fromRGB(255, 255, 255)
            _R["56_v1"].TextSize = 13
            _R["56_v1"].Font = Enum.Font.GothamBold
            _R["56_v1"].TextXAlignment = Enum.TextXAlignment.Center
            _R["56_v1"].Text = "XYZ: 0, 0, 0"
            _R["56_v1"].Parent = l3
            _R["57_v1"] = game:GetService("RunService").RenderStepped:Connect(function()
            local u1, u2, u3
                u1 = game.Players.LocalPlayer.Character
                if u1 then
                    u2 = u1:FindFirstChild("HumanoidRootPart")
                    if u2 then
                        u3 = u2.Position
                        _R["56_v1"].Text = string.format("XYZ: %.1f, %.1f, %.1f", u3.X, u3.Y, u3.Z)
                    end
                end
            end)
            return
        end
    end
})
_R["58_v1"] = ""
_R["59_v1"] = ""
_R["62_v1"] = false
v63 = Color3.fromRGB(190, 150, 255)
v64 = Color3.fromRGB(0, 255, 255)
GetInitialData = function()
local l1, l2
    l1 = game.Players.LocalPlayer.Character
    if not l1 then
        l1 = game.Players.LocalPlayer.CharacterAdded:Wait()
    end
    l2 = l1:WaitForChild("HumanoidRootPart", 5):WaitForChild("user", 5)
    if l2 then
        _R["58_v1"] = l2.user.Text
        _R["59_v1"] = l2.level.Text
    end
end
task.spawn(GetInitialData)
v67 = function()
local l1, l2, l3, l4, l5
    if _R["62_v1"] then
        l1 = game.Players.LocalPlayer.Character
        l2 = l1
        if l2 then
            l2 = l1:FindFirstChild("HumanoidRootPart")
        end
        if l2 then
            l2 = l1.HumanoidRootPart:FindFirstChild("user")
        end
        l3 = utf8.char(57344)
        if l2 then
            if l2:FindFirstChild("user") then
                l4 = l2.user
                l4.Text = "Protected" .. (" " .. l3)
                l4 = l2.user
                l4.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        l4 = workspace:FindFirstChild(game.Players.LocalPlayer.Name)
        if l4 then
            if l4:FindFirstChild("fishinfo") then
                if l4.fishinfo:FindFirstChild("Author") then
                    l5 = l4.fishinfo.Author
                    l5.Text = "Protected (@menghubteam)"
                    l5.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
        return
    end
end
RunService.Heartbeat:Connect(v67)
v65 = stopAnimHookEnabled
if not v65 then
    v65 = false
end
stopAnimHookEnabled = v65
v65 = stopAnimConn
if not v65 then
    v65 = nil
end
stopAnimConn = v65
ApplyNoAnimation = function(p1)
local l2, l3, l4
    if stopAnimConn then
        stopAnimConn:Disconnect()
        stopAnimConn = nil
    end
    if stopAnimHookEnabled then
        if p1 then
            for _k1, _v1 in ipairs(p1:GetPlayingAnimationTracks()) do
                l3, l4 = _k1, _v1
                l4:Stop(0)
            end
            stopAnimConn = p1.AnimationPlayed:Connect(function(a1)
                if stopAnimHookEnabled then
                    task.defer(function()
                        pcall(function()
                            a1:Stop(0)
                        end)
                    end)
                end
            end)
        end
    end
end
FishingSupportSection:AddToggle({
    Title = "Disable Animations",
    Default = false,
    Callback = function(p1)
    local l2, l3, l4
        stopAnimHookEnabled = p1
        if not p1 then
            if stopAnimConn then
                stopAnimConn:Disconnect()
                stopAnimConn = nil
            end
        else
            l2 = LocalPlayer.Character
            l3 = l2
            if l3 then
                l3 = l2:FindFirstChildOfClass("Humanoid")
            end
            l4 = l3
            if l4 then
                l4 = l3:FindFirstChildOfClass("Animator")
            end
            if l4 then
                ApplyNoAnimation(l4)
            end
        end
    end
})
LocalPlayer.CharacterAdded:Connect(function(p1)
local l2, l3
    l2 = p1:WaitForChild("Humanoid", 10)
    l3 = l2
    if l3 then
        l3 = l2:WaitForChild("Animator", 10)
    end
    if stopAnimHookEnabled then
        if l3 then
            ApplyNoAnimation(l3)
        end
    end
end)
FishingSupportSection:AddToggle({
    Title = "Protect Identity",
    Default = false,
    Callback = function(p1)
    local l2, l3, l4
        _R["62_v1"] = p1
        if not p1 then
            l2 = game.Players.LocalPlayer.Character
            l3 = l2
            if l3 then
                l3 = l2:FindFirstChild("HumanoidRootPart")
            end
            if l3 then
                l3 = l2.HumanoidRootPart:FindFirstChild("user")
            end
            if l3 then
                l4 = l3.user
                l4.Text = _R["58_v1"]
                l4 = l3.user
                l4.TextColor3 = Color3.new(1, 1, 1)
            end
        end
    end
})
FishingSupportSection:AddToggle({
    Title = "Disable Obtained Fish",
    Default = false,
    Callback = function(p1)
    local l2, l3, l4, l5, l6, l7
        l2 = LocalPlayer.PlayerGui.hud.safezone.announcements
        if not p1 then
            FishSettings.DisableFishDisplay = false
            for _k1, _v1 in ipairs(l2:GetChildren()) do
                l4, l5 = _k1, _v1
                if l5.Name == "catch" then
                    l6 = l5:FindFirstChild("vp")
                    l7 = l5:FindFirstChild("Shine")
                    if l6 then
                        l6.Visible = true
                    end
                    if l7 then
                        l7.Visible = true
                    end
                end
            end
            return
        else
            FishSettings.DisableFishDisplay = true
            return
        end
    end
})
LocalPlayer.PlayerGui.hud.safezone.announcements.ChildAdded:Connect(function(p1)
local l2, l3
    if p1.Name == "catch" then
        if FishSettings.DisableFishDisplay then
            l2 = p1:FindFirstChild("vp")
            l3 = p1:FindFirstChild("Shine")
            if l2 then
                l2.Visible = false
            end
            if l3 then
                l3.Visible = false
            end
        end
    end
end)
FishingSection = v43.Main:AddSection("Fishing Features")
FishingSection:AddSubSection("Super Fast Catch")
getPowerBar = function()
local l1, l3
    l1 = LocalPlayer.Character
    if not l1 then
        l1 = LocalPlayer.CharacterAdded:Wait()
    end
    l3 = l1:WaitForChild("HumanoidRootPart"):FindFirstChild("power")
    if not l3 then
        return nil
    else
        return l3:FindFirstChild("bar", true)
    end
end
task.spawn(function()
local _R_61 = {}
local _U_61 = {}
local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10
    while true do
        task.wait()
        if v25.AutoFishing then
            if v25.AutoCast then
                l1 = PlayerGui:FindFirstChild("shakeui")
                if not l1 then
                    l2 = getEquippedRod()
                    if l2 then
                        if l2:FindFirstChild("events") then
                            if l2.events:FindFirstChild("castAsync") then
                                l3 = game.Players.LocalPlayer.Character
                                if l3 then
                                    l4 = l3:FindFirstChild("HumanoidRootPart")
                                end
                                l5 = l2:FindFirstChild("char")
                                if not l5 then
                                    l6 = {}
                                    for _k1, _v1 in pairs(v26.CastPower) do
                                        l8, l9 = _k1, _v1
                                        l10 = v27[l8]
                                        if l10 then
                                            table.insert(l6, l10)
                                        end
                                    end
                                    if (#l6) == 0 then
                                        l8 = l6
                                        l9 = v27["Perfect!"]
                                        table.insert(l8, l9)
                                    end
                                    l7 = l6[math.random(1, #l6)]
                                    l10 = l7.max
                                    l8 = math.random(l7.min, l10)
                                    l9 = v26.CastMode
                                    if l9 ~= "Instant" then
                                        l9 = game:GetService("VirtualInputManager")
                                        l10 = true
                                        _U_61["90_0"] = l9
                                        _U_61["90_3"] = l8
                                        pcall(function()
                                        local u1, u3
                                            _U_61["90_0"]:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                            u1 = tick() + 2.5
                                            if tick() >= u1 then
                                                while true do
                                                    if not v25.AutoCast then
                                                        break
                                                    end
                                                    u3 = getPowerBar()
                                                    if not u3 then
                                                        task.wait()
                                                        if tick() < u1 then
                                                            _U_61["90_0"]:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                                            task.wait(0.1)
                                                            return
                                                        end
                                                    end
                                                end
                                                l10 = false
                                            end
                                        end)
                                    else
                                        _U_61["116_1"] = l8
                                        pcall(function()
                                            CastRemote:InvokeServer(_U_61["116_1"], _U_61["116_1"] >= 96)
                                        end)
                                        l9 = task.wait
                                        _R_61["10_v2"] = 0.1
                                        l9(_R_61["10_v2"])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
local l1, l2, l3, l4, l5, l6
    while true do
        task.wait(0.01)
        if v25.AutoFishing then
            if v25.AutoShake then
                l1 = PlayerGui:FindFirstChild("shakeui")
                if l1 then
                    if l1.Enabled then
                        l2 = l1:FindFirstChild("safezone")
                        if l2 then
                            l3 = nil
                            for _k1, _v1 in ipairs(l2:GetChildren()) do
                                l5, l6 = _k1, _v1
                                if l6:IsA("GuiButton") then
                                    l3 = l6
                                    break
                                end
                            end
                            if l3 then
                                if v26.Method ~= "Fire Signal" then
                                    if v26.Method == "Navigation" then
                                        l3.Visible = true
                                        GuiService.SelectedObject = l3
                                        if GuiService.SelectedObject == l3 then
                                            l4 = game:GetService("VirtualInputManager")
                                            l4:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                            task.wait(0.01)
                                            l4:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                        end
                                        GuiService.SelectedObject = nil
                                        l4 = task.wait
                                        l5 = v26.Speed == "Fast"
                                        if l5 then
                                            l5 = 0.05
                                        end
                                        if not l5 then
                                            l5 = 0.2
                                        end
                                        l4(l5)
                                    end
                                else
                                    l3.Visible = false
                                    if not firesignal then
                                        for _k1, _v1 in pairs(getconnections(l3.Activated)) do
                                            l5, l6 = _k1, _v1
                                            l6:Fire()
                                        end
                                        if v26.Speed ~= "Fast" then
                                            task.wait(0.15)
                                        else
                                            task.wait()
                                        end
                                    else
                                        firesignal(l3.Activated)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
FishingSection:AddToggle({
    Title = "Auto Fish",
    Default = false,
    Keybind = true,
    Callback = function(p1)
    local _R_66 = {}
    local l2
        v25.AutoFishing = p1
        if not p1 then
            l2 = game:GetService("VirtualInputManager")
            pcall(function()
                l2:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end
})
FishingSection:AddToggle({
    Title = "Auto Cast",
    Default = true,
    Callback = function(p1)
        v25.AutoCast = p1
    end
})
FishingSection:AddToggle({
    Title = "Auto Shake",
    Default = true,
    Callback = function(p1)
        v25.AutoShake = p1
    end
})
FishingSection:AddToggle({
    Title = "Auto Reel",
    Default = true,
    Callback = function(p1)
        v25.AutoReel = p1
    end
})
FishingSection:AddToggle({
    Title = "Instant Bobber",
    Default = true,
    Callback = function(p1)
        v25.InstantBobber = p1
        BobberProcessed = {}
    end
})
_R["66_v1"] = {}
findWater = function(p1)
local l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16
    l2 = p1.Position
    l3 = l2.X
    l4 = l2.Z
    l5 = Vector3.new(l3, l2.Y + 5, l4)
    l6 = Vector3.new(0, -150, 0)
    RaycastParams.new().FilterType = Enum.RaycastFilterType.Include
    l7.FilterDescendantsInstances = { workspace.Terrain }
    l8 = workspace:Raycast(l5, l6, l7)
    if not l8 then
        OverlapParams.new().FilterType = Enum.RaycastFilterType.Exclude
        l9.FilterDescendantsInstances = { game.Players.LocalPlayer.Character, workspace.Terrain }
        l10 = l10(l11, CFrame.new(l3, l2.Y - 15, l4), Vector3.new(4, 50, 4), l9)
        l11 = -99999
        l12 = false
        for _k1, _v1 in ipairs(l10) do
            l14, l15 = _k1, _v1
            if l15.Name:lower():find("water") then
                l16 = l15.Position.Y + (l15.Size.Y / 2)
                if l16 >= (l2.Y + 3) then
                    if l11 >= l16 then
                        l11 = l16
                        l12 = true
                    end
                end
            end
        end
        if not l12 then
            return Vector3.new(l3, l2.Y - 2, l4)
        else
            return Vector3.new(l3, l11, l4)
        end
    else
        if l8.Material == Enum.Material.Water then
            return Vector3.new(l3, l8.Position.Y, l4)
        end
    end
end
RunService.RenderStepped:Connect(function()
local _R_103 = {}
local _U_103 = {}
local l1, l2, l3, l4, l5
    if not v25.InstantBobber then
        _R["66_v1"] = {}
        return
    else
        l1 = game.Players.LocalPlayer.Character
        l2 = l1
        if l2 then
            l4 = "HumanoidRootPart"
            l2 = l1:FindFirstChild(l4)
        end
        l3 = l1
        if l3 then
            l3 = l1:FindFirstChildOfClass("Tool")
        end
        if l3 then
            if l2 then
                l4 = l3:FindFirstChild("bobber")
                if l4 then
                    if l4:IsA("BasePart") then
                        l4.CanCollide = false
                        l4.CanTouch = true
                        l4.CanQuery = true
                        l4.Massless = true
                        if not _R["66_v1"][l4] then
                            _R["66_v1"][l4] = findWater(l2)
                            l4.AssemblyLinearVelocity = Vector3.zero
                            l4.AssemblyAngularVelocity = Vector3.zero
                            _U_103["32_1"] = l4
                            l4.Destroying:Once(function()
                                _R["66_v1"][_U_103["32_1"]] = nil
                            end)
                        end
                        l5 = _R["66_v1"][l4]
                        if l5 then
                            l4.CFrame = CFrame.new(l5.X, l5.Y + (math.sin(tick() * 3) * 0.05), l5.Z)
                            l4.AssemblyLinearVelocity = Vector3.zero
                            l4.AssemblyAngularVelocity = Vector3.zero
                        end
                        return
                    end
                end
            end
        end
    end
end)
FishingSection:AddSubSection("Minigame Spoofer")
FishingSection:AddSlider({
    Title = "Control Bar",
    Min = 0.05,
    Max = 1,
    Increment = 0.05,
    Default = 0.05,
    Callback = function(p1)
        FishSettings.ControlBarSize = p1
    end
})
FishingSection:AddToggle({
    Title = "Control Bar Changer",
    Default = false,
    Callback = function(p1)
        FishSettings.ControlBarChangerEnabled = p1
    end
})
FishingSection:AddSlider({
    Title = "Progress Speed",
    Min = 100,
    Max = 2000,
    Increment = 10,
    Default = 100,
    Callback = function(p1)
        FishSettings.ProgressSpeedValue = (p1 / 100) + 1
    end
})
FishingSection:AddToggle({
    Title = "Progress Speed Changer",
    Default = false,
    Callback = function(p1)
        FishSettings.ProgressSpeedEnabled = p1
    end
})
FishingSection:AddToggle({
    Title = "Stall Bar",
    Content = "This feature will freeze fish bar",
    Default = false,
    Callback = function(p1)
        FishSettings.StallBarEnabled = p1
    end
})
FishingSection:AddSubSection("Farm Settings")
task.spawn(function()
local l1, l2
    while true do
        task.wait(0.1)
        if v25.LullabyPassive then
            l1 = LocalPlayer.Character
            l2 = l1
            if l2 then
                l2 = l1:FindFirstChildOfClass("Tool")
            end
            if l2 then
                if l2.Name:lower():find("lullaby") then
                    pcall(function()
                        ReplicatedStorage.packages.Net["RE/MetronomeBuff/Input"]:FireServer(true)
                    end)
                end
            end
        end
    end
end)
FishingSection:AddDropdown({
    Title = "Cast Mode",
    Options = { "Legit", "Instant" },
    Default = "Instant",
    Callback = function(p1)
        v26.CastMode = p1
    end
})
_R["74_v1"] = "Great!"
_R["75_v1"] = "Amazing!!"
_R["76_v1"] = "Perfect!"
FishingSection:AddDropdown({
    Title = "Cast Power",
    Options = {
        "Meh..",
        "Fine.",
        "Good!",
        _R["74_v1"],
        _R["75_v1"],
        _R["76_v1"]
    },
    Multi = true,
    Default = { "Amazing!!", "Perfect!" },
    Callback = function(p1)
    local l2, l3, l4, l5, l6
        v26.CastPower = {}
        for _k1, _v1 in pairs(p1) do
            l3, l4 = _k1, _v1
            l5 = type(l3) == "string"
            if l5 then
                l5 = l3
            end
            if not l5 then
                l5 = l4
            end
            l6 = v26.CastPower
            l6[l5] = true
        end
    end
})
FishingSection:AddDropdown({
    Title = "Shake Methode",
    Options = { "Navigation", "Fire Signal" },
    Default = "Fire Signal",
    Callback = function(p1)
        v26.Method = p1
    end
})
FishingSection:AddDropdown({
    Title = "Shake Speed",
    Options = { "Slow", "Fast" },
    Default = "Fast",
    Callback = function(p1)
        v26.Speed = p1
    end
})
FishingSection:AddDropdown({
    Title = "Reel Mode",
    Options = { "Legit", "Instant" },
    Default = "Instant",
    Callback = function(p1)
        v26.ReelMode = p1
    end
})
v71 = "Fill Bar"
v72 = "Follow Bar"
_R["73_v1"] = "Anti Perfect Catch"
FishingSection:AddDropdown({
    Title = "Reeling Mode",
    Options = {
        v71,
        v72,
        _R["73_v1"]
    },
    Default = "Fill Bar",
    Callback = function(p1)
        v26.ReelType = p1
    end
})
FishingSection:AddToggle({
    Title = "Stack Lullaby Passive",
    Default = false,
    Callback = function(p1)
        v25.LullabyPassive = p1
    end
})
FishingSection:AddToggle({
    Title = "Hide Minigame UI",
    Default = false,
    Callback = function(p1)
        FishSettings.HideMinigameUI = p1
    end
})
FishingSection:AddButton({
    Title = "Cancel Fishing",
    Callback = function()
        cancelFishing()
    end
})
FishingSection:AddButton({
    Title = "Instant Respawn / Reset",
    Callback = function()
    local _U_81 = {}
    local l1, l2, l3, l4, l5
        l1 = LocalPlayer.Character
        if l1 then
            l4 = "HumanoidRootPart"
            l2 = l1:FindFirstChild(l4)
            if l2 then
                l3 = l2.CFrame
                l4 = nil
                _U_81["82_1"] = l3
                l4 = LocalPlayer.CharacterAdded:Connect(function(a1)
                local u2
                    l4:Disconnect()
                    l4 = nil
                    u2 = a1:WaitForChild("HumanoidRootPart", 5)
                    if u2 then
                        if u2.Anchored then
                            u2:GetPropertyChangedSignal("Anchored"):Wait()
                        end
                        task.wait(3.2)
                        u2.CFrame = _U_81["82_1"]
                        notif("Respawned and teleported back!")
                        return
                    else
                        notif("Respawn failed!")
                        return
                    end
                end)
                l5 = l1:FindFirstChild("Humanoid")
                if l5 then
                    l5.Health = 0
                end
                return
            else
                l3 = notif
                l4 = "HumanoidRootPart not found!"
                l3(l4)
                return
            end
        else
            l3 = "Character not found!"
            notif(l3)
            return
        end
    end
})
v67 = game:GetService("ReplicatedStorage").packages.Net["RE/Nuke"]
for _k, _v in pairs(getconnections(v67.OnClientEvent)) do
    _R["69_v1"], _R["70_v1"] = _k, _v
    _R["70_v1"]:Disable()
end
_R["68_v1"] = false
NukeSection = v43.Main:AddSection("Nuke")
_U["28_1"] = v67
NukeSection:AddToggle({
    Title = "Auto Nuke Minigame",
    Default = false,
    Callback = function(p1)
    local l2, l3, l4
        _R["68_v1"] = p1
        if not p1 then
            for _k1, _v1 in pairs(getconnections(_U["28_1"].OnClientEvent)) do
                l3, l4 = _k1, _v1
                l4:Enable()
            end
            return
        else
            for _k1, _v1 in pairs(getconnections(_U["28_1"].OnClientEvent)) do
                l3, l4 = _k1, _v1
                l4:Disable()
            end
            return
        end
    end
})
v67.OnClientEvent:Connect(function()
    if _R["68_v1"] then
        return
    end
end)
SpearSection = v43.Main:AddSection("Auto Spear")
SpearSection:AddDropdown({
    Title = "Spear Location",
    Content = "Select location to teleport",
    Options = {
        "Lost Jungle",
        "Coral Bastion",
        "Tidefall",
        "Colapse Ruin",
        "Crowned Ruins"
    },
    Default = FishSettings.AutoSpearLocation,
    Callback = function(p1)
        FishSettings.AutoSpearLocation = p1
    end
})
SpearSection:AddToggle({
    Title = "Enable Spearfishing",
    Content = "Teleport and catch spear fish",
    Default = false,
    Callback = function(p1)
    local l2
        FishSettings.AutoSpear = p1
        if p1 then
            if LocalPlayer.Character then
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if FishSettings.AutoSpearLocation ~= "Lost Jungle" then
                        if FishSettings.AutoSpearLocation ~= "Coral Bastion" then
                            if FishSettings.AutoSpearLocation ~= "Tidefall" then
                                if FishSettings.AutoSpearLocation ~= "Colapse Ruin" then
                                    if FishSettings.AutoSpearLocation == "Crowned Ruins" then
                                        l2 = LocalPlayer.Character.HumanoidRootPart
                                        l2.CFrame = CFrame.new(3050.45, -1137.82, 2062.73) * CFrame.Angles(math.rad(-180), math.rad(7.32), math.rad(-180))
                                    end
                                else
                                    l2 = LocalPlayer.Character.HumanoidRootPart
                                    l2.CFrame = CFrame.new(3085.12, -1133.9, 1737.09) * CFrame.Angles(math.rad(0), math.rad(44.08), math.rad(0))
                                end
                            else
                                l2 = LocalPlayer.Character.HumanoidRootPart
                                l2.CFrame = CFrame.new(3000.22, -1110.21, 774.12) * CFrame.Angles(math.rad(-180), math.rad(-11.25), math.rad(180))
                            end
                        else
                            l2 = LocalPlayer.Character.HumanoidRootPart
                            l2.CFrame = CFrame.new(2597.93, -1102.88, 872.26) * CFrame.Angles(math.rad(0), math.rad(-10.22), math.rad(0))
                        end
                    else
                        l2 = LocalPlayer.Character.HumanoidRootPart
                        l2.CFrame = CFrame.new(-2843.53, 128.94, -2155.38) * CFrame.Angles(math.rad(0), math.rad(-37.58), math.rad(0))
                    end
                end
            end
        end
    end
})
task.spawn(function()
local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10
    while true do
        task.wait(0.1)
        if FishSettings.AutoSpear then
            l1 = workspace:FindFirstChild("Spearfishing Water")
            if l1 then
                for _k1, _v1 in pairs(l1:GetChildren()) do
                    l3, l4 = _k1, _v1
                    l5 = l4:FindFirstChild("ZoneFish")
                    if l5 then
                        for _k1, _v1 in pairs(l5:GetChildren()) do
                            l7, l8 = _k1, _v1
                            if not FishSettings.AutoSpear then
                                break
                            end
                            l9 = l8:GetAttribute("UID")
                            if not l9 then
                                l9 = l8.Name
                            end
                            if l9 then
                                l10 = game:GetService("ReplicatedStorage").packages.Net["RE/SpearFishing/Minigame"]
                                l10:FireServer(l9)
                                task.wait(1.1)
                                l10:FireServer(l9, true)
                                task.wait()
                            end
                        end
                    end
                end
            end
        end
    end
end)
SnapReelSection = v43.Main:AddSection("Snap Reel")
SnapFishName = SnapReelSection:AddDropdown({
    Title = "Snap Filter Fish",
    Options = v33,
    Default = {},
    Multi = true,
    Callback = function(p1)
    local l2
        if type(p1) ~= "string" then
            l2 = SnapReelSettings
            l2.Targets = p1
            return
        else
            l2 = SnapReelSettings
            l2.Targets = { p1 }
            return
        end
    end
})
SnapFishRarity = SnapReelSection:AddDropdown({
    Title = "Snap Filter Rarity",
    Options = v39,
    Default = {},
    Multi = true,
    Callback = function(p1)
    local l2
        if type(p1) ~= "string" then
            l2 = SnapReelSettings
            l2.TargetsRarity = p1
            return
        else
            l2 = SnapReelSettings
            l2.TargetsRarity = { p1 }
            return
        end
    end
})
SnapFishType = SnapReelSection:AddDropdown({
    Title = "Snap Filter Type",
    Options = {
        "Shiny",
        "Sparkling",
        "Shiny Sparkling"
    },
    Default = {},
    Multi = true,
    Callback = function(p1)
    local l2
        if type(p1) ~= "string" then
            l2 = SnapReelSettings
            l2.TargetsType = p1
            return
        else
            l2 = SnapReelSettings
            l2.TargetsType = { p1 }
            return
        end
    end
})
SnapFishMutation = SnapReelSection:AddDropdown({
    Title = "Snap Filter Mutation",
    Options = v36,
    Default = {},
    Multi = true,
    Callback = function(p1)
    local l2, l3, l4, l5
        if type(p1) ~= "string" then
            l2 = SnapReelSettings
            l2.TargetsMutation = p1
            l2 = {}
        else
            l2 = SnapReelSettings
            l2.TargetsMutation = { p1 }
            l2 = {}
        end
        for _k1, _v1 in pairs(p1) do
            l4, l5 = _k1, _v1
            table.insert(l2, tostring(l4) .. (" = " .. tostring(l5)))
        end
        print("{" .. (table.concat(l2, ", ") .. "}"))
    end
})
SnapFishManualTarget = SnapReelSection:AddInput({
    Title = "Target Fish (if it is not in the dropdown)",
    Content = "Use if no fish name on list",
    Placeholder = "Write ur input here",
    Callback = function(p1)
    local l2
        l2 = SnapReelSettings
        l2.ManualTarget = p1
    end
})
SnapReelSection:AddToggle({
    Title = "Snap Reel",
    Content = "Released if the fish does not meet the target",
    Default = false,
    Keybind = true,
    Callback = function(p1)
    local l2
        l2 = SnapReelSettings
        l2.Enabled = p1
    end
})
SnapReelSection:AddButton({
    Title = "Reset All Filter",
    Callback = function()
    local l1
        l1 = SnapReelSettings
        l1.Targets = {}
        l1 = SnapReelSettings
        l1.TargetsRarity = {}
        l1 = SnapReelSettings
        l1.TargetsType = {}
        l1 = SnapReelSettings
        l1.TargetsMutation = {}
        l1 = SnapReelSettings
        l1.ManualTarget = {}
        SnapFishName:Set({})
        SnapFishRarity:Set({})
        SnapFishType:Set({})
        SnapFishMutation:Set({})
        SnapFishManualTarget:Set("")
    end
})
SellSection = v43.Main:AddSection("Sell Features")
_R["69_v1"] = 0
_R["70_v1"] = 0
v71 = game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/Settings/Edit")
v71:FireServer("showShakeProgress", true)
task.spawn(function()
local l1, l2
    while true do
        if FishSettings.AutoSell then
            l1 = tick() - _R["69_v1"]
            l2 = FishSettings.SellInterval
            if not l2 then
                l2 = 60
            end
            if l2 > l1 then
                ReplicatedStorage.events.ShadySellAll:InvokeServer(true)
                task.wait(1)
                ReplicatedStorage.events.SellAll:InvokeServer(true)
                _R["69_v1"] = tick()
            end
        end
        task.wait(1)
    end
end)
_U["8_1"] = v39
_U["8_2"] = v71
task.spawn(function()
local l1, l2, l3, l4, l5
    while true do
        if FishSettings.WhitelistRarities then
            l1 = {}
            l2 = {}
            if FishSettings.SellRarities then
                for _k1, _v1 in ipairs(FishSettings.SellRarities) do
                    l4, l5 = _k1, _v1
                    l2[l5] = true
                end
            end
            for _k1, _v1 in ipairs(_U["8_1"]) do
                l4, l5 = _k1, _v1
                l1[l5] = l2[l5] == true
            end
            _U["8_2"]:FireServer("autosell", l1)
        end
        task.wait()
    end
end)
task.spawn(function()
local _R_59 = {}
local _U_59 = {}
local l1, l2, l3
    while true do
        l1 = FishSettings.AutoSellStorage
        if l1 then
            l1 = tick()
            l2 = _R["70_v1"]
            if not l2 then
                l2 = 0
            end
            l1 = l1 - l2
            l2 = FishSettings.SellInterval
            if not l2 then
                l2 = 60
            end
            if l2 > l1 then
                l1 = game:GetService("ReplicatedStorage").events.SellAllStorage
                _U_59["79_0"] = l1
                task.spawn(function()
                    _U_59["79_0"]:InvokeServer()
                end)
                task.wait(0.5)
                l2 = LocalPlayer.PlayerGui.hud.safezone.prompt.confirm
                if l2 then
                    if not firesignal then
                        l2.Active = true
                        l2.Selectable = true
                        l3 = game:GetService("GuiService")
                        l3.SelectedObject = l2
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        task.wait(0.1)
                        l3 = game:GetService("GuiService")
                        l3.SelectedObject = nil
                    else
                        firesignal(l2.MouseButton1Click)
                        firesignal(l2.MouseButton1Down)
                        firesignal(l2.Activated)
                    end
                end
                _R["70_v1"] = tick()
            end
        end
        l1 = task.wait
        l1(1)
    end
end)
SellSection:AddInput({
    Title = "Sell Interval (s)",
    Placeholder = "Write ur input here",
    Callback = function(p1)
        FishSettings.SellInterval = tonumber(p1)
    end
})
SellSection:AddToggle({
    Title = "Auto Sell All",
    Content = "Include Shady S$ (Priority Shady first)",
    Default = FishSettings.AutoSell,
    Callback = function(p1)
        FishSettings.AutoSell = p1
    end
})
SellSection:AddToggle({
    Title = "Auto Sell Storage",
    Default = false,
    Callback = function(p1)
        FishSettings.AutoSellStorage = p1
    end
})
SellSection:AddDropdown({
    Title = "Sell by Rarities",
    Options = {
        "Crates",
        "Trash",
        "Common",
        "Uncommon",
        "Unusual",
        "Rare",
        "Legendary",
        "Mythical",
        "Exotic",
        "Secret",
        "Limited",
        "Relic",
        "Fragment",
        "Seed",
        "Gemstone",
        "Apex",
        "Extinct",
        "Special",
        "Divine Secret"
    },
    Default = {},
    Multi = true,
    Callback = function(p1)
        FishSettings.SellRarities = p1
    end
})
SellSection:AddToggle({
    Title = "Whitelist Auto Sell",
    Default = FishSettings.WhitelistRarities,
    Callback = function(p1)
        FishSettings.WhitelistRarities = p1
    end
})
_U["386_0"] = v39
_U["386_1"] = v71
SellSection:AddButton({
    Title = "Unwhitelist All",
    Callback = function()
    local l1, l2, l3, l4
        l1 = {}
        for _k1, _v1 in ipairs(_U["386_0"]) do
            l3, l4 = _k1, _v1
            l1[l4] = false
        end
        _U["386_1"]:FireServer("autosell", l1)
    end
})
SellSection:AddSubSection("Auto Sell Storage (AA)")
IsAdminEventMatching = function()
local l1, l2, l4, l5, l6, l7
    l1 = game:GetService("ReplicatedStorage"):FindFirstChild("world")
    if l1 then
        l2 = l1:FindFirstChild("AdminEventText")
        if not l2 then
            return false
        else
            if l2:IsA("StringValue") then
                l4 = l2.Value:gsub("<[^>]*>", ""):gsub("Admin Event:%s*", ""):lower()
                for _k1, _v1 in pairs(FishSettings.SelectedAdminEvents) do
                    l6, l7 = _k1, _v1
                    if l7 then
                        if string.find(l4, l6:lower()) then
                            return true
                        end
                    end
                end
            end
        end
    else
        return false
    end
end
task.spawn(function()
local _R_357 = {}
local _U_357 = {}
local l1, l2, l3
    while true do
        task.wait(2)
        l1 = FishSettings.AutoSellAdminEvent
        if l1 then
            l1 = IsAdminEventMatching()
            if l1 then
                l1 = game:GetService("ReplicatedStorage").events.SellAllStorage
                _U_357["273_0"] = l1
                task.spawn(function()
                    _U_357["273_0"]:InvokeServer()
                end)
                task.wait(0.8)
                l2 = LocalPlayer.PlayerGui:FindFirstChild("hud")
                if l2 then
                    l2 = LocalPlayer.PlayerGui.hud.safezone.prompt.confirm
                end
                if l2 then
                    if l2.Visible then
                        if not firesignal then
                            l2.Active = true
                            l2.Selectable = true
                            l3 = game:GetService("GuiService")
                            l3.SelectedObject = l2
                            task.wait(0.1)
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            task.wait(0.05)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            task.wait(0.1)
                            l3 = game:GetService("GuiService")
                            l3.SelectedObject = nil
                        else
                            firesignal(l2.MouseButton1Click)
                            firesignal(l2.Activated)
                        end
                    end
                end
                task.wait(20)
            end
        end
    end
end)
SellSection:AddDropdown({
    Title = "Select Admin Abuse",
    Options = {
        "Buffed Goldstorm",
        "Goldstorm",
        "Blackout"
    },
    Default = {},
    Multi = true,
    Callback = function(p1)
        FishSettings.SelectedAdminEvents = p1
    end
})
SellSection:AddToggle({
    Title = "Auto Sell Storage (Admin Event)",
    Default = false,
    Callback = function(p1)
        FishSettings.AutoSellAdminEvent = p1
    end
})
SellSection:AddSubSection("Inventory Specific")
FishDropdown = SellSection:AddDropdown({
    Title = "Select Fish For Sell",
    Options = { "Loading..." },
    Default = {},
    Multi = true,
    Callback = function(p1)
        FishSettings.SellFishName = p1
    end
})
UpdateFishDropdown = function()
local l1, l2, l3, l4, l5, l6
    l1 = LocalPlayer:FindFirstChild("Backpack")
    l2 = {}
    l3 = {}
    if l1 then
        for _k1, _v1 in pairs(l1:GetChildren()) do
            l5, l6 = _k1, _v1
            if l6:IsA("Tool") then
                if not l6:FindFirstChild("events") then
                    if not l3[l6.Name] then
                        table.insert(l2, l6.Name)
                        l3[l6.Name] = true
                    end
                end
            end
        end
    end
    table.sort(l2)
    FishDropdown:SetValues(l2)
end
UpdateFishDropdown()
SellSection:AddButton({
    Title = "Refresh Fish List",
    Callback = function()
        UpdateFishDropdown()
        notif("List refreshed!")
    end
})
SellSpecificToggle = SellSection:AddToggle({
    Title = "Auto Sell Selected Fish",
    Default = false,
    Callback = function(p1)
        FishSettings.AutoSellSelectedFish = p1
    end
})
v72 = game:GetService("ReplicatedStorage").events.Sell
_U["258_1"] = v72
sellFishByName = function(p1, p2, p3)
local l4, l5, l6, l7
    l4 = {}
    for _k1, _v1 in pairs(p3:GetChildren()) do
        l6, l7 = _k1, _v1
        if l7:IsA("Tool") then
            if l7.Name == p1 then
                table.insert(l4, l7)
            end
        end
    end
    if (#l4) ~= 0 then
        for _k1, _v1 in pairs(l4) do
            l6, l7 = _k1, _v1
            if not FishSettings.AutoSellSelectedFish then
                break
            end
            if l7:IsDescendantOf(p3) then
                p2:EquipTool(l7)
                task.spawn(function()
                    _U["258_1"]:InvokeServer()
                end)
                task.wait(0.01)
            end
        end
        return #l4
    else
        return 0
    end
end
task.spawn(function()
local l1, l2, l3, l4, l5, l6, l7, l8
    while true do
        task.wait(1)
        if FishSettings.AutoSellSelectedFish then
            if next(FishSettings.SellFishName) then
                l1 = LocalPlayer:FindFirstChild("Backpack")
                l2 = LocalPlayer.Character
                l3 = l2
                if l3 then
                    l3 = l2:FindFirstChildOfClass("Humanoid")
                end
                if l1 then
                    if l3 then
                        l4 = 0
                        for _k1, _v1 in pairs(FishSettings.SellFishName) do
                            l6, l7 = _k1, _v1
                            if not FishSettings.AutoSellSelectedFish then
                                break
                            end
                            if l7 then
                                l8 = sellFishByName(l7, l3, l1)
                                if 0 < l8 then
                                    l4 = l4 + l8
                                    task.wait(0.1)
                                end
                            end
                        end
                        if 0 < l4 then
                            task.wait(0.5)
                        end
                        l5 = false
                        for _k1, _v1 in pairs(FishSettings.SellFishName) do
                            l7, l8 = _k1, _v1
                            if l8 then
                                if l1:FindFirstChild(l8) then
                                    l5 = true
                                    break
                                end
                            end
                        end
                        if not l5 then
                            notif("All selected fish sold!")
                            FishSettings.AutoSellSelectedFish = false
                            SellSpecificToggle:Set(false)
                        end
                    end
                end
            end
        end
    end
end)
_R["73_v1"] = ""
_R["74_v1"] = ""
_R["75_v1"] = v31[1]
_R["76_v1"] = ""
_R["77_v1"] = 1
_R["78_v1"] = 1
ShopSection = v43.Shop:AddSection("Shop Item")
ShopSection:AddSubSection("Rod Shop")
ShopSection:AddDropdown({
    Title = "Select Rod",
    Content = "Select rod u want to buy",
    Options = v28,
    Default = v28[1],
    Callback = function(p1)
        _R["73_v1"] = p1
    end
})
ShopSection:AddButton({
    Title = "Buy Selected Rod",
    Callback = function()
        if _R["73_v1"] == "" then
            notif("Please select a rod first!")
            return
        else
            game:GetService("ReplicatedStorage").events.purchase:FireServer(_R["73_v1"], "Rod", nil, 1)
            notif("Sent purchase request for: " .. _R["73_v1"])
            return
        end
    end
})
ShopSection:AddSubSection("Bait Shop")
ShopSection:AddDropdown({
    Title = "Select Bait",
    Content = "Choose a Bait to Purchase",
    Options = {
        "Common Crate",
        "Tropical Bait Crate",
        "Carbon Crate",
        "Bait Crate",
        "Quality Bait Crate",
        "Coral Geode",
        "Volcanic Geode",
        "Obsidian-Bone",
        "Golden Shrimp Bait",
        "Whale Bait",
        "Festival Bait Crate"
    },
    Default = {},
    Callback = function(p1)
        _R["74_v1"] = p1
    end
})
ShopSection:AddInput({
    Title = "Buy Ammount (Bait)",
    Content = "Buy selected Bait as much u want",
    Placeholder = "Write ur input here",
    Callback = function(p1)
    local l2
        l2 = tonumber(p1)
        if not l2 then
            _R["78_v1"] = 1
            return
        else
            if 0 < l2 then
                _R["78_v1"] = math.floor(l2)
                return
            end
        end
    end
})
ShopSection:AddButton({
    Title = "Buy Selected Bait",
    Callback = function()
    local l1, l3, l4, l5, l6
        if _R["74_v1"] == "" then
            notif("Select a bait first!")
        else
            l1 = game:GetService("ReplicatedStorage"):FindFirstChild("events")
            if l1 then
                l1 = game:GetService("ReplicatedStorage").events:FindFirstChild("purchase")
            end
            if l1 then
                l3 = ({
                    ["Obsidian-Bone"] = true,
                    ["Golden Shrimp Bait"] = true,
                    ["Whale Bait"] = true
                })[_R["74_v1"]]
                if l3 then
                    l3 = "Bait"
                end
                if not l3 then
                    l3 = "Fish"
                end
                l4 = _R["78_v1"]
                l5 = _R["78_v1"]
                if 0 < l4 then
                    while true do
                        l6 = math.min(l4, 1000)
                        l1:FireServer(_R["74_v1"], l3, nil, l6)
                        l4 = l4 - l6
                        task.wait(0.1)
                        if 0 >= l4 then
                            break
                        end
                    end
                end
                notif("Bought " .. (l5 .. ("x " .. (_R["74_v1"] .. "!"))))
            end
        end
    end
})
ShopSection:AddSubSection("Item Shop")
ShopSection:AddDropdown({
    Title = "Select an Item",
    Content = "Choose an item from the shop",
    Options = v31,
    Default = v31[1],
    Callback = function(p1)
        _R["75_v1"] = p1
    end
})
ItemInput = ShopSection:AddInput({
    Title = "Custom Item Name",
    Content = "If item not found in list",
    Callback = function(p1)
        _R["76_v1"] = p1
    end
})
ShopSection:AddInput({
    Title = "Purchase Quantity",
    Content = "Ammount to buy item",
    Placeholder = "Write ur input here",
    Callback = function(p1)
    local l2
        l2 = tonumber(p1)
        if not l2 then
            l2 = 1
        end
        _R["77_v1"] = l2
    end
})
ShopSection:AddButton({
    Title = "Buy Selected Item",
    Callback = function()
    local l1, l2, l3, l4, l5
        l1 = game:GetService("ReplicatedStorage"):FindFirstChild("events")
        if l1 then
            l1 = game:GetService("ReplicatedStorage").events:FindFirstChild("purchase")
        end
        if l1 then
            l2 = ""
            if _R["76_v1"] == "" then
                if _R["75_v1"] ~= "" then
                    if _R["75_v1"] ~= nil then
                        l2 = _R["75_v1"]
                    end
                end
            else
                if _R["76_v1"] ~= nil then
                    l2 = _R["76_v1"]
                end
            end
            if l2 == "" then
                notif("Please select an item or enter a custom name!")
            else
                l3 = _R["77_v1"]
                l4 = _R["77_v1"]
                if 0 < l3 then
                    while true do
                        l5 = math.min(l3, 50)
                        l1:FireServer(l2, "Item", nil, l5)
                        l3 = l3 - l5
                        task.wait(0.1)
                        if 0 >= l3 then
                            break
                        end
                    end
                end
                notif("Bought " .. (l4 .. ("x " .. (l2 .. "!"))))
                _R["76_v1"] = ""
                ItemInput:Set("")
            end
        end
    end
})
_R["79_v1"] = 1
_R["80_v1"] = 1
_R["81_v1"] = false
_R["82_v1"] = false
_R["83_v1"] = false
_R["84_v1"] = false
_R["85_v1"] = {}
_R["86_v1"] = nil
v88 = {
    ["Luck Boost"] = {
        dialogId = 9,
        statusKey = "LuckMerlin",
        durationMin = 30
    },
    ["XP Boost"] = {
        dialogId = 7,
        statusKey = "XpMultiplyMerlin",
        durationMin = 30
    },
    ["Lure Boost"] = {
        dialogId = 10,
        statusKey = "LureMerlin",
        durationMin = 30
    },
    ["Twisted Relic"] = {
        dialogId = 11,
        statusKey = nil,
        durationMin = 0
    }
}
reEquipRod = function()
local l1, l2, l3, l4, l5, l6
    l1 = LocalPlayer.Character
    l2 = LocalPlayer:FindFirstChild("Backpack")
    if l1 then
        if l2 then
            l3 = l1:FindFirstChildOfClass("Humanoid")
            for _k1, _v1 in pairs(l2:GetChildren()) do
                l5, l6 = _k1, _v1
                if l6:IsA("Tool") then
                    if l6:FindFirstChild("events") then
                        l3:EquipTool(l6)
                        break
                    end
                end
            end
        end
    end
end
parseTimer = function(p1)
local l2, l3, l4
    if not p1 then
        return 0
    else
        if p1 ~= "" then
            l2, l3, l4 = p1:match("(%d+):(%d+):(%d+)")
            if not l2 then
                return 0
            else
                return (tonumber(l2) + (tonumber(l3) / 60)) + (tonumber(l4) / 3600)
            end
        end
    end
end
getBoostHours = function(p1)
local l2, l3, l4, l5, l6
    if p1 then
        l2 = LocalPlayer.PlayerGui.hud.safezone:FindFirstChild("statuses")
        if l2 then
            for _k1, _v1 in ipairs(l2:GetChildren()) do
                l4, l5 = _k1, _v1
                if l5.Name:find(p1, 1, true) then
                    l6 = l5:FindFirstChild("timer")
                    if l6 then
                        return parseTimer(l6.Text)
                    end
                end
            end
            return 0
        else
            return 0
        end
    else
        return 0
    end
end
goToMerlin = function(p1, p2)
local l3
    p2:UnequipTools()
    task.wait(0.5)
    p1.Anchored = false
    p1.CFrame = CFrame.new(-954.5, 222.19, -986.11) * CFrame.Angles(math.rad(-2.2), math.rad(-28.2), math.rad(-0.48))
    task.wait(1)
    l3 = workspace.world.npcs:WaitForChild("Merlin", 10)
    if l3 then
        mengfireproximityprompt(l3.ProximityPrompt)
        task.wait(0.5)
        return true
    else
        return false
    end
end
_U["384_3"] = v88
doMerlinBuy = function()
local _U_384 = {}
local l1, l2, l3, l4, l5, l6, l7, l9, l10, l11, l12, l13, l14, l15, l16, l17
    if not _R["82_v1"] then
        l2 = _R["85_v1"]
        if next(l2) then
            _R["82_v1"] = true
            l1 = LocalPlayer.Character
            l2 = l1
            if l2 then
                l2 = l1:FindFirstChild("HumanoidRootPart")
            end
            l3 = l1
            if l3 then
                l5 = "Humanoid"
                l3 = l1:FindFirstChildOfClass(l5)
            end
            l4 = game:GetService("ReplicatedStorage").packages.Net["RF/DialogInteract"]
            if not l2 then
                _R["82_v1"] = false
                return
            else
                if l3 then
                    l5 = pauseAndWaitFishing()
                    l6 = l2.CFrame
                    l7 = {}
                    if goToMerlin(l2, l3) then
                        for _k1, _v1 in pairs(_R["85_v1"]) do
                            l10, l11 = _k1, _v1
                            l12 = _U["384_3"][l10]
                            if l12 then
                                l13 = 1
                                if _R["84_v1"] then
                                    if l12.statusKey then
                                        l13 = math.max(0, math.ceil((8 - getBoostHours(l12.statusKey)) / (l12.durationMin / 60)))
                                    end
                                end
                                if 0 < l13 then
                                    l14 = 1
                                    l15 = l13
                                    l16 = 1
                                    for _i1 = l14, l15, l16 do
                                        l17 = _i1
                                        l4:InvokeServer(l12.dialogId, 1)
                                        task.wait(0.2)
                                    end
                                    l14 = table.insert
                                    l15 = l7
                                    l16 = _R["84_v1"]
                                    if l16 then
                                        l16 = " x" .. l13
                                    end
                                    if not l16 then
                                        l16 = ""
                                    end
                                    l14(l15, l10 .. l16)
                                end
                            end
                        end
                        if 0 < (#l7) then
                            notif("Merlin: " .. table.concat(l7, ", "))
                        end
                        l2.Anchored = true
                        l2.CFrame = l6
                        _U_384["468_0"] = l2
                        _U_384["468_1"] = l5
                        task.delay(1, function()
                            _U_384["468_0"].Anchored = false
                            reEquipRod()
                            _U_384["468_1"]()
                        end)
                        _R["82_v1"] = false
                        return
                    else
                        _R["82_v1"] = false
                        l5()
                        return
                    end
                end
            end
        end
    end
end
_U["182_3"] = v88
startMerlinAutoLoop = function()
    if not _R["86_v1"] then
        _R["86_v1"] = task.spawn(function()
        local u1, u2, u3, u4, u5, u6
            print("[Merlin] loop start, items:", next(_R["85_v1"]))
            print("[Merlin] AutoEnabled:", _R["83_v1"])
            task.spawn(doMerlinBuy)
            while true do
                if not _R["83_v1"] then
                    break
                end
                task.wait(5)
                u1 = false
                for _k2, _v2 in pairs(_R["85_v1"]) do
                    u3, u4 = _k2, _v2
                    u5 = _U["182_3"][u3]
                    if u5 then
                        if u5.statusKey then
                            u6 = getBoostHours(u5.statusKey)
                            if not _R["84_v1"] then
                                if u6 > 0 then
                                    u1 = true
                                    break
                                end
                            else
                                if u6 >= (8 - (u5.durationMin / 60)) then
                                    u1 = true
                                    break
                                end
                            end
                        end
                    end
                end
                if u1 then
                    task.spawn(doMerlinBuy)
                    task.wait(10)
                end
            end
            _R["86_v1"] = nil
        end)
        return
    end
end
MerlinSection = v43.Shop:AddSection("Merlin")
MerlinSection:AddDropdown({
    Title = "Purchase Option",
    Content = "This option for buy relic",
    Options = {
        "1x",
        "2x",
        "5x",
        "10x",
        "25x",
        "50x"
    },
    Default = "1x",
    Callback = function(p1)
    local l3
        l3 = ({
            ["1x"] = 1,
            ["2x"] = 2,
            ["5x"] = 3,
            ["10x"] = 4,
            ["25x"] = 5,
            ["50x"] = 6
        })[p1]
        if not l3 then
            l3 = 1
        end
        _R["79_v1"] = l3
    end
})
MerlinSection:AddInput({
    Title = "Purchase Amount",
    Placeholder = "Write ur input here",
    Callback = function(p1)
    local l2, l3
        l2 = tonumber(p1)
        l3 = l2
        if l3 then
            l3 = l2 > 0
        end
        if l3 then
            l3 = math.floor(l2)
        end
        if not l3 then
            l3 = 1
        end
        _R["80_v1"] = l3
    end
})
MerlinSection:AddButton({
    Title = "Buy Relic (Option x Amount)",
    Callback = function()
    local _U_475 = {}
    local l1, l2, l3, l4, l5, l8, l9, l10, l11
        l1 = game:GetService("ReplicatedStorage").packages.Net["RF/DialogInteract"]
        l2 = LocalPlayer.Character
        l3 = l2
        if l3 then
            l3 = l2:FindFirstChild("HumanoidRootPart")
        end
        if l3 then
            l4 = pauseAndWaitFishing()
            l5 = l3.CFrame
            if goToMerlin(l3, l2:FindFirstChildOfClass("Humanoid")) then
                if not _R["81_v1"] then
                    mengfireproximityprompt(workspace.world.npcs.Merlin.ProximityPrompt)
                    _R["81_v1"] = true
                    task.wait(1)
                end
                l8 = 1
                l9 = _R["80_v1"]
                l10 = 1
                for _i1 = l8, l9, l10 do
                    l11 = _i1
                    l1:InvokeServer(3, _R["79_v1"])
                    task.wait(0.15)
                end
                l3.CFrame = l5
                _U_475["229_0"] = l3
                task.delay(1, function()
                    _U_475["229_0"].Anchored = false
                    reEquipRod()
                    l4()
                end)
                return
            else
                l4()
                return
            end
        end
    end
})
MerlinSection:AddDivider()
_U["361_1"] = v88
MerlinSection:AddDropdown({
    Title = "Select Merlin Items",
    Content = "Choose items to auto buy",
    Options = {
        "Luck Boost",
        "XP Boost",
        "Lure Boost",
        "Twisted Relic"
    },
    Multi = true,
    Default = {},
    Callback = function(p1)
    local l2, l3, l4, l5
        _R["85_v1"] = {}
        for _k1, _v1 in pairs(p1) do
            l3, l4 = _k1, _v1
            l5 = type(l4) == "string"
            if l5 then
                l5 = l4
            end
            if not l5 then
                l5 = type(l3) == "string"
                if l5 then
                    l5 = l3
                end
            end
            if not l5 then
                l5 = nil
            end
            if l5 then
                if _U["361_1"][l5] then
                    _R["85_v1"][l5] = true
                end
            end
        end
        print("[Merlin] selected:", next(_R["85_v1"]))
    end
})
MerlinSection:AddToggle({
    Title = "Auto Purchase Merlin",
    Content = "Buy selected items when boost expires",
    Default = false,
    Callback = function(p1)
        _R["83_v1"] = p1
        if not p1 then
            _R["86_v1"] = nil
            return
        else
            startMerlinAutoLoop()
            return
        end
    end
})
MerlinSection:AddToggle({
    Title = "Stack Boost (Auto refill up to 8h)",
    Content = "Buy until all selected boosts reach 8h stack",
    Default = false,
    Callback = function(p1)
        _R["84_v1"] = p1
        if p1 then
            if _R["83_v1"] then
                task.spawn(doMerlinBuy)
            end
        end
    end
})
_R["89_v1"] = ""
_R["90_v1"] = 1
TotemSection = v43.Shop:AddSection("Totem Shop")
TotemSection:AddInput({
    Title = "Buy Ammount (Totem)",
    Content = "Buy selected Totem as much u want",
    Placeholder = "Write ur input here",
    Callback = function(p1)
    local l2
        l2 = tonumber(p1)
        if not l2 then
            _R["90_v1"] = 1
            return
        else
            if 0 < l2 then
                _R["90_v1"] = math.floor(l2)
                return
            end
        end
    end
})
TotemSection:AddDropdown({
    Title = "Select Totem",
    Content = "Choose a Totem to Purchase",
    Options = v32,
    Default = {},
    Callback = function(p1)
        _R["89_v1"] = p1
    end
})
TotemSection:AddButton({
    Title = "Buy Selected Totem",
    Callback = function()
    local l1, l2, l3, l4
        if _R["89_v1"] == "" then
            notif("Select totem first!")
        else
            l1 = game:GetService("ReplicatedStorage"):FindFirstChild("events")
            if l1 then
                l1 = game:GetService("ReplicatedStorage").events:FindFirstChild("purchase")
            end
            if l1 then
                l2 = _R["90_v1"]
                l3 = _R["90_v1"]
                if 0 < l2 then
                    while true do
                        l4 = math.min(l2, 50)
                        l1:FireServer(_R["89_v1"], "Item", nil, l4)
                        l2 = l2 - l4
                        task.wait(0.1)
                        if 0 >= l2 then
                            break
                        end
                    end
                end
                notif("Bought " .. (_R["90_v1"] .. ("x " .. (_R["89_v1"] .. "!"))))
            end
        end
    end
})
v91 = PlayerGui.hud.safezone:FindFirstChild("shipwright")
BoatSection = v43.Shop:AddSection("Boat Shop")
_U["263_0"] = v91
BoatSection:AddButton({
    Title = "Open/Close Boat Shop UI",
    Callback = function()
        if not _U["263_0"] then
            print("UI Shipwright tidak ditemukan!")
            return
        else
            _U["263_0"].Visible = not _U["263_0"].Visible
            return
        end
    end
})
v92 = PlayerGui.hud.safezone:FindFirstChild("BlackMarket")
BlackmarketSection = v43.Shop:AddSection("Black Market")
_U["524_0"] = v92
BlackmarketSection:AddButton({
    Title = "Open/Close Black Market UI",
    Callback = function()
        if not _U["524_0"] then
            print("UI Blackmarket tidak ditemukan!")
            return
        else
            _U["524_0"].Visible = not _U["524_0"].Visible
            return
        end
    end
})
v93 = PlayerGui.hud.safezone:FindFirstChild("DailyShop")
DailyShopSection = v43.Shop:AddSection("Daily Shop")
_U["335_0"] = v93
DailyShopSection:AddButton({
    Title = "Open/Close Daily Shop UI",
    Callback = function()
        if _U["335_0"] then
            _U["335_0"].Visible = not _U["335_0"].Visible
        end
    end
})
v94 = {
    Enabled = false,
    SelectedDayTotems = {},
    SelectedNightTotems = {},
    LastCycle = "",
    UseDelay = 60,
    LastUseTime = 0
}
v95 = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("worldstatuses")
_U["195_0"] = v95
v96 = function()
local l1, l2
    l1 = _U["195_0"]:FindFirstChild("cycle1")
    l2 = l1
    if l2 then
        l2 = l1:FindFirstChild("iconContainer")
    end
    if l2 then
        l2 = l1.iconContainer:FindFirstChild("nextIcon")
    end
    if l2 then
        if l2.Image ~= "rbxassetid://16956670840" then
            if l2.Image ~= "rbxassetid://16956671093" then
                return "Day"
            else
                return "Day"
            end
        else
            return "Night"
        end
    else
        return "Day"
    end
end
_U["440_1"] = v94
UseTotem = function(p1)
local l2, l3, l4, l5
    if p1 then
        if p1 ~= "" then
            l2 = LocalPlayer.Character
            l3 = LocalPlayer.Backpack
            l4 = l3:FindFirstChild(p1)
            if l4 then
                if l2 then
                    l5 = l2:FindFirstChildOfClass("Tool")
                    l4.Parent = l2
                    task.wait(0.2)
                    l4:Activate()
                    task.wait(0.5)
                    l4.Parent = l3
                    if l5 then
                        if l5.Parent ~= l2 then
                            l5.Parent = l2
                        end
                    end
                    _U["440_1"].LastUseTime = tick()
                end
            end
            return
        end
    end
end
UseTotems = function(p1)
local l2, l3, l4
    for _k1, _v1 in ipairs(p1) do
        l3, l4 = _k1, _v1
        UseTotem(l4)
        task.wait(0.8)
    end
end
_U["417_0"] = v95
_U["417_1"] = v94
_U["417_2"] = v96
task.spawn(function()
local l1, l2, l3
    l1 = _U["417_0"]:WaitForChild("cycle1", 10)
    l2 = l1
    if l2 then
        l2 = l1:WaitForChild("iconContainer", 10)
    end
    l3 = l2
    if l3 then
        l3 = l2:WaitForChild("nextIcon", 10)
    end
    if l3 then
        l3:GetPropertyChangedSignal("Image"):Connect(function()
        local u1, u2
            if _U["417_1"].Enabled then
                task.wait(0.3)
                u1 = _U["417_2"]()
                if _U["417_1"].LastCycle ~= u1 then
                    _U["417_1"].LastCycle = u1
                    _U["417_1"].LastUseTime = 0
                    u2 = u1 == "Night"
                    if u2 then
                        u2 = _U["417_1"].SelectedNightTotems
                    end
                    if not u2 then
                        u2 = _U["417_1"].SelectedDayTotems
                    end
                    if next(u2) then
                        UseTotems(u2)
                    end
                end
                return
            end
        end)
        return
    else
        warn("[AutoTotem] nextIcon tidak ditemukan")
        return
    end
end)
_U["193_0"] = v94
_U["193_1"] = v96
task.spawn(function()
local l1, l3
    while true do
        if not task.wait(2) then
            break
        end
        if _U["193_0"].Enabled then
            l1 = _U["193_1"]()
            _U["193_0"].LastCycle = l1
            if _U["193_0"].UseDelay > (tick() - _U["193_0"].LastUseTime) then
                l3 = l1 == "Night"
                if l3 then
                    l3 = _U["193_0"].SelectedNightTotems
                end
                if not l3 then
                    l3 = _U["193_0"].SelectedDayTotems
                end
                if next(l3) then
                    UseTotems(l3)
                end
            end
        end
    end
end)
AutoTotemSection = v43.Auto:AddSection("Totem")
_U["359_0"] = v94
AutoTotemSection:AddDropdown({
    Title = "Select Day Totem",
    Options = v32,
    Multi = true,
    Default = {},
    Callback = function(p1)
    local l2, l3, l4
        _U["359_0"].SelectedDayTotems = {}
        for _k1, _v1 in pairs(p1) do
            l3, l4 = _k1, _v1
            table.insert(_U["359_0"].SelectedDayTotems, l4)
        end
    end
})
_U["183_0"] = v94
AutoTotemSection:AddDropdown({
    Title = "Select Night Totem",
    Options = v32,
    Multi = true,
    Default = {},
    Callback = function(p1)
    local l2, l3, l4
        _U["183_0"].SelectedNightTotems = {}
        for _k1, _v1 in pairs(p1) do
            l3, l4 = _k1, _v1
            table.insert(_U["183_0"].SelectedNightTotems, l4)
        end
    end
})
_U["166_0"] = v94
AutoTotemSection:AddSlider({
    Title = "Use Totem Delay (seconds)",
    Content = "Re-use totem every X seconds",
    Min = 1,
    Max = 120,
    Default = v94.UseDelay,
    Callback = function(p1)
        _U["166_0"].UseDelay = p1
    end
})
_U["396_0"] = v94
AutoTotemSection:AddToggle({
    Title = "Auto Totem",
    Default = false,
    Callback = function(p1)
        _U["396_0"].Enabled = p1
        if not p1 then
            _U["396_0"].LastCycle = ""
            _U["396_0"].LastUseTime = 0
        end
    end
})
v97 = {
    Enabled = false,
    SelectedPotions = {},
    CheckInterval = 30,
    LastCheckTime = 0
}
UsePotion = function(p1)
local l2, l3, l4, l5
    if not p1 then
        return false
    else
        if p1 ~= "" then
            l2 = LocalPlayer.Character
            l3 = LocalPlayer.Backpack
            l4 = l3:FindFirstChild(p1)
            if not l4 then
                return false
            else
                if l2 then
                    l5 = l2:FindFirstChildOfClass("Tool")
                    l4.Parent = l2
                    task.wait(0.2)
                    if l4 then
                        if l4.Parent then
                            l4:Activate()
                        end
                    end
                    task.wait(0.5)
                    if l4 then
                        if l4.Parent then
                            l4.Parent = l3
                        end
                    end
                    if l5 then
                        if l5.Parent ~= l2 then
                            l5.Parent = l2
                        end
                    end
                    print("Used: " .. p1)
                    return true
                end
            end
        end
    end
end
_U["521_0"] = v97
task.spawn(function()
local l2, l3, l4, l5
    while true do
        if not task.wait(1) then
            break
        end
        if _U["521_0"].Enabled then
            if _U["521_0"].CheckInterval > (tick() - _U["521_0"].LastCheckTime) then
                _U["521_0"].LastCheckTime = tick()
                l2 = _U["521_0"].SelectedPotions
                for _k1, _v1 in ipairs(l2) do
                    l4, l5 = _k1, _v1
                    if not _U["521_0"].Enabled then
                        break
                    end
                    if type(l5) == "string" then
                        UsePotion(l5)
                        if l4 >= (#l2) then
                            task.wait(0.8)
                        end
                    end
                end
            end
        end
    end
end)
PotionSection = v43.Auto:AddSection("Potions")
_U["215_0"] = v97
PotionSection:AddToggle({
    Title = "Auto Use Potions",
    Default = false,
    Callback = function(p1)
        _U["215_0"].Enabled = p1
        _U["215_0"].LastCheckTime = 0
    end
})
_U["191_0"] = v97
PotionSection:AddDropdown({
    Title = "Select Potions",
    Options = {
        "All Season Potion",
        "Luck Potion",
        "Lure Speed Potion",
        "Glitched Potion"
    },
    Default = {},
    Multi = true,
    Callback = function(p1)
        _U["191_0"].SelectedPotions = p1
    end
})
_U["142_0"] = v97
PotionSection:AddInput({
    Title = "Potions Check Interval (seconds)",
    Default = "30",
    Callback = function(p1)
    local l2
        l2 = tonumber(p1)
        if l2 then
            _U["142_0"].CheckInterval = l2
        end
    end
})
v98 = {
    "Abyssal (Enchant)",
    "Blessed (Enchant)",
    "Blessed Song (Enchant)",
    "Blood Reckoning (Enchant)",
    "Breezed (Enchant)",
    "Chaotic (Enchant)",
    "Chronos (Enchant)",
    "Clever (Enchant)",
    "Controlled (Enchant)",
    "Divine (Enchant)",
    "Flashline (Enchant)",
    "Ghastly (Enchant)",
    "Hasty (Enchant)",
    "Hunter (Enchant)",
    "Insight (Enchant)",
    "Long (Enchant)",
    "Lucky (Enchant)",
    "Momentum (Enchant)",
    "Mutated (Enchant)",
    "Noir (Enchant)",
    "Quality (Enchant)",
    "Resilient (Enchant)",
    "Scavenger (Enchant)",
    "Scrapper (Enchant)",
    "Sea King (Enchant)",
    "Steady (Enchant)",
    "Storming (Enchant)",
    "Swift (Enchant)",
    "Unbreakable (Enchant)",
    "Wormhole (Enchant)",
    "Anomalous (Exalted)",
    "Ferocious (Exalted)",
    "Herculean (Exalted)",
    "Immortal (Exalted)",
    "Mystical (Exalted)",
    "Piercing (Exalted)",
    "Quantum (Exalted)",
    "Sea Overlord (Exalted)",
    "Fractured (Twisted)",
    "Greed (Twisted)",
    "Pharaohs Curse (Twisted)",
    "Putrid (Twisted)",
    "Rage (Twisted)",
    "Weak (Twisted)",
    "Wobbly (Twisted)"
}
table.sort(v98)
v99 = {
    "Cryogenic (Cosmic)",
    "Glittered (Cosmic)",
    "Overclocked (Cosmic)",
    "Sea Prince (Cosmic)",
    "Tenacity (Cosmic)",
    "Tryhard (Cosmic)",
    "Vicious (Cosmic)",
    "Wise (Cosmic)"
}
table.sort(v99)
_R["100_v1"] = {}
_R["101_v1"] = {}
_R["102_v1"] = "Enchant Relic"
_R["103_v1"] = false
_R["104_v1"] = nil
_R["105_v1"] = nil
v106 = {
    ["Enchant Relic"] = "Enchant Relic",
    ["Exalted Relic"] = "Exalted Relic",
    ["Cosmic Relic"] = "Cosmic Relic",
    ["Twisted Relic"] = "Twisted Relic"
}
getCurrentEnchant = function()
local l1, l2
    l1 = { slot1 = "", slot2 = "" }
    l2 = pcall(function()
    local u2, u3, u4, u5, u6
        for _k2, _v2 in pairs(LocalPlayer.PlayerGui.hud.safezone.equipment.rods.scroll.safezone:GetChildren()) do
            u3, u4 = _k2, _v2
            if u4:IsA("Frame") then
                if u4:FindFirstChild("equip") then
                    if u4.equip.Text == "[Equipped]" then
                        u5 = u4.rod.enchants
                        clean = function(b1)
                        local w3
                            if b1 then
                                w3 = b1:gsub("<[^>]+>", ""):gsub("[^%a%s]", " "):lower():match("^%s*(.-)%s*$")
                                if not w3 then
                                    w3 = ""
                                end
                                return w3
                            else
                                return ""
                            end
                        end
                        l1.slot1 = clean(u5.enchant.Text)
                        u6 = u5:FindFirstChild("detail")
                        if u6 then
                            if u6:FindFirstChild("secondary") then
                                l1.slot2 = clean(u6.secondary.Text)
                            end
                        end
                    end
                end
            end
        end
    end)
    return l1
end
isTargetEnchant = function(p1)
local l2, l3, l4, l5, l6, l8, l9
    if p1 then
        l2 = true
        l3 = true
        if next(_R["100_v1"]) then
            l2 = false
            for _k1, _v1 in pairs(_R["100_v1"]) do
                l5, l6 = _k1, _v1
                if l8(l9, tostring(l5):gsub(" %(.*%)", ""):lower():match("^%s*(.-)%s*$")) then
                    l2 = true
                    break
                end
            end
        end
        if next(_R["101_v1"]) then
            l3 = false
            for _k1, _v1 in pairs(_R["101_v1"]) do
                l5, l6 = _k1, _v1
                if l8(l9, tostring(l5):gsub(" %(.*%)", ""):lower():match("^%s*(.-)%s*$")) then
                    l3 = true
                    break
                end
            end
        end
        l4 = l2
        if l4 then
            l4 = l3
        end
        return l4
    else
        return false
    end
end
_U["455_0"] = v106
doEnchant = function()
local _U_455 = {}
local l1, l2
    l1 = game:GetService("ReplicatedStorage").packages.Net["RF/EnchantAltar/Interact"]
    l2 = _U["455_0"][_R["102_v1"]]
    if not l2 then
        l2 = "Enchant Relic"
    end
    _U_455["542_1"] = l2
    pcall(function()
        l1:InvokeServer(_U_455["542_1"])
    end)
end
startAutoEnchant = function()
    if _R["104_v1"] then
        stopAutoEnchant()
    end
    _R["103_v1"] = true
    _R["104_v1"] = task.spawn(function()
    local u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12
        u1 = LocalPlayer.Character
        if not u1 then
            u1 = LocalPlayer.CharacterAdded:Wait()
        end
        u2 = u1:FindFirstChild("HumanoidRootPart")
        u3 = u1:FindFirstChildOfClass("Humanoid")
        if u2 then
            if u3 then
                u2.CFrame = CFrame.new(1309.15, -802.43, -88.44) * CFrame.Angles(math.rad(-180), math.rad(-10.94), math.rad(180))
                task.wait(0.2)
            end
        end
        while true do
            if not _R["103_v1"] then
                break
            end
            if not _R["103_v1"] then
                break
            end
            u4 = getCurrentEnchant()
            if not isTargetEnchant(u4) then
                u5 = LocalPlayer.Backpack:FindFirstChild(_R["102_v1"])
                if not u5 then
                    u5 = u1
                    if u5 then
                        u5 = u1:FindFirstChild(_R["102_v1"])
                    end
                end
                if u5 then
                    if u5.Parent == LocalPlayer.Backpack then
                        u3:EquipTool(u5)
                        task.wait(0.4)
                    end
                    doEnchant()
                    u7 = 1
                    u8 = 15
                    u9 = 1
                    for _i2 = u7, u8, u9 do
                        u10 = _i2
                        if not _R["103_v1"] then
                            break
                        end
                        task.wait(0.1)
                    end
                    if not _R["103_v1"] then
                        break
                    end
                    u7 = getCurrentEnchant()
                    if not isTargetEnchant(u7) then
                        u9 = 1
                        u10 = 55
                        u11 = 1
                        for _i2 = u9, u10, u11 do
                            u12 = _i2
                            if not _R["103_v1"] then
                                break
                            end
                            task.wait(0.1)
                        end
                    else
                        _R["103_v1"] = false
                        task.spawn(function()
                            if _R["105_v1"] then
                                _R["105_v1"]:Set(false)
                            end
                        end)
                        u8 = notif
                        u9 = u7.slot1:upper()
                        u10 = u7.slot2 ~= ""
                        if u10 then
                            u10 = " | Slot2: " .. u7.slot2:upper()
                        end
                        if not u10 then
                            u10 = ""
                        end
                        u8("Target didapat! Slot1: " .. (u9 .. u10))
                        break
                    end
                else
                    notif("Relic Habis!")
                    _R["103_v1"] = false
                    task.spawn(function()
                        if _R["105_v1"] then
                            _R["105_v1"]:Set(false)
                        end
                    end)
                    break
                end
            else
                _R["103_v1"] = false
                task.spawn(function()
                    if _R["105_v1"] then
                        _R["105_v1"]:Set(false)
                    end
                end)
                u5 = notif
                u6 = u4.slot1:upper()
                u7 = u4.slot2 ~= ""
                if u7 then
                    u7 = " | Slot2: " .. u4.slot2:upper()
                end
                if not u7 then
                    u7 = ""
                end
                u5("Target didapat! Slot1: " .. (u6 .. u7))
                break
            end
        end
        _R["104_v1"] = nil
    end)
end
stopAutoEnchant = function()
    _R["103_v1"] = false
    _R["104_v1"] = nil
end
EnchantSection = v43.Auto:AddSection("Enchant")
EnchantSection:AddDropdown({
    Title = "Enchant Target",
    Options = v98,
    Multi = true,
    Callback = function(p1)
    local l2, l3, l4, l5
        _R["100_v1"] = {}
        for _k1, _v1 in pairs(p1) do
            l3, l4 = _k1, _v1
            l5 = type(l3) == "string"
            if l5 then
                l5 = l3
            end
            if not l5 then
                l5 = l4
            end
            _R["100_v1"][l5] = true
        end
    end
})
EnchantSection:AddDropdown({
    Title = "Secondary Enchant Target",
    Options = v99,
    Multi = true,
    Callback = function(p1)
    local l2, l3, l4, l5
        _R["101_v1"] = {}
        for _k1, _v1 in pairs(p1) do
            l3, l4 = _k1, _v1
            l5 = type(l3) == "string"
            if l5 then
                l5 = l3
            end
            if not l5 then
                l5 = l4
            end
            _R["101_v1"][l5] = true
        end
    end
})
EnchantSection:AddDropdown({
    Title = "Select Relic Type",
    Options = {
        "Enchant Relic",
        "Exalted Relic",
        "Cosmic Relic",
        "Twisted Relic"
    },
    Default = "Enchant Relic",
    Callback = function(p1)
        _R["102_v1"] = p1
    end
})
_R["105_v1"] = EnchantSection:AddToggle({
    Title = "Auto Enchant Altar",
    Default = false,
    Callback = function(p1)
        if not p1 then
            stopAutoEnchant()
            return
        else
            startAutoEnchant()
            return
        end
    end
})
EnchantSection:AddButton({
    Title = "Teleport To Enchant Altar",
    Callback = function()
    local l1, l2
        l1 = LocalPlayer.Character
        l2 = l1
        if l2 then
            l2 = l1:FindFirstChild("HumanoidRootPart")
        end
        if l2 then
            l2.CFrame = CFrame.new(1309.15, -802.43, -88.44) * CFrame.Angles(math.rad(-180), math.rad(-10.94), math.rad(180))
        end
    end
})
v107 = {
    selectedAppraiser = "Appraiser",
    autoAppraiseRunning = false,
    appraiserPromptFired = false,
    appraiseThread = nil,
    selectedMutations = {},
    selectedTier = "None",
    selectedSize = "None",
    appraiserCFrames = {
        Appraiser = CFrame.new(447.7, 150.55, 206.82) * CFrame.Angles(0, math.rad(-87.13), 0),
        ["Drowned Appraiser"] = CFrame.new(3169.98, -1099.82, 774.97) * CFrame.Angles(math.rad(0.04), math.rad(0.64), math.rad(-0.1))
    },
    appraiserPromptPaths = {
        Appraiser = function()
        local l1, l2
            l1 = workspace.world.npcs:WaitForChild("Appraiser", 10)
            l2 = l1
            if l2 then
                l2 = l1:FindFirstChildOfClass("ProximityPrompt")
            end
            return l2
        end,
        ["Drowned Appraiser"] = function()
        local l1, l2
            l1 = workspace.world.npcs:WaitForChild("DrownedAppraiser", 10)
            l2 = l1
            if l2 then
                l2 = l1:FindFirstChildOfClass("ProximityPrompt")
            end
            return l2
        end
    },
    appraiserDialogIds = { Appraiser = 6, ["Drowned Appraiser"] = 6 },
    appraiseMutationList = {
        "None",
        "Sweet",
        "Mourned",
        "Fallen",
        "Coral",
        "Spooky",
        "Frightful",
        "Vined",
        "Poisoned",
        "Shrouded",
        "Spirit",
        "Beachy",
        "Popsicle",
        "Summer",
        "Mythical",
        "Greedy",
        "Abyssal",
        "Fossilized",
        "Lunar",
        "Midas",
        "Glossy",
        "Silver",
        "Mosaic",
        "Hexed",
        "Electric",
        "Crimson",
        "Festive",
        "Jolly",
        "Scorched",
        "Darkened",
        "Translucent",
        "Frozen",
        "Negative",
        "Albino",
        "Amber",
        "Giant",
        "Fabulous",
        "Unlucky",
        "Jackpot",
        "Tryhard",
        "Decayed",
        "Honey",
        "Floral"
    }
}
table.sort(v107.appraiseMutationList)
table.remove(v107.appraiseMutationList, table.find(v107.appraiseMutationList, "None"))
table.insert(v107.appraiseMutationList, 1, "None")
_U["318_0"] = v107
checkAppraise = function(p1)
local l2, l3, l4, l5, l6, l7, l8
    l2 = p1:FindFirstChild("fishinfo")
    l3 = l2
    if l3 then
        l3 = l2:FindFirstChild("Info")
    end
    if l3 then
        l3 = l2.Info:FindFirstChild("Subvalues")
    end
    if l3 then
        l4 = l3.ContentText:lower()
        if l4 ~= "" then
            if _U["318_0"].selectedTier == "None" then
                if _U["318_0"].selectedSize == "None" then
                    l5 = false
                    for _k1, _v1 in pairs(_U["318_0"].selectedMutations) do
                        l7, l8 = _k1, _v1
                        l5 = true
                        break
                    end
                    if not l5 then
                        if _U["318_0"].selectedTier ~= "None" then
                            return true, l4
                        else
                            if _U["318_0"].selectedSize == "None" then
                                if not l5 then
                                    return false
                                end
                            end
                        end
                    else
                        for _k1, _v1 in pairs(_U["318_0"].selectedMutations) do
                            l7, l8 = _k1, _v1
                            l8 = l4:find(l7, 1, true)
                            if not l8 then
                                return false
                            end
                        end
                    end
                else
                    if not l5(l6, _U["318_0"].selectedSize:lower(), 1, true) then
                        return false
                    end
                end
            else
                for _k1, _v1 in _U["318_0"].selectedTier:lower():gmatch("%S+") do
                    l6, l7 = _k1, _v1
                    l7 = l4:find(l6, 1, true)
                    if not l7 then
                        return false
                    end
                end
            end
        else
            return false
        end
    else
        return false
    end
end
AppraiseSection = v43.Auto:AddSection("Appraise")
_U["217_0"] = v107
AppraiseSection:AddDropdown({
    Title = "Select Tier Appraise",
    Options = {
        "None",
        "Shiny",
        "Sparkling",
        "Shiny Sparkling"
    },
    Default = "None",
    Callback = function(p1)
        _U["217_0"].selectedTier = p1
    end
})
_U["329_0"] = v107
AppraiseSection:AddDropdown({
    Title = "Select Size Appraise",
    Options = {
        "None",
        "Big",
        "Giant"
    },
    Default = "None",
    Callback = function(p1)
        _U["329_0"].selectedSize = p1
    end
})
_U["406_0"] = v107
AppraiseSection:AddDropdown({
    Title = "Select Mutation Appraise",
    Options = v107.appraiseMutationList,
    Default = "None",
    Callback = function(p1)
    local l2
        _U["406_0"].selectedMutations = {}
        if type(p1) == "string" then
            if p1 ~= "" then
                if p1 ~= "None" then
                    l2 = _U["406_0"].selectedMutations
                    l2[p1:lower()] = true
                end
            end
        end
    end
})
_U["198_0"] = v107
AppraiseSection:AddDropdown({
    Title = "Select Appraise Location",
    Options = { "Appraiser", "Drowned Appraiser" },
    Default = "Appraiser",
    Callback = function(p1)
        _U["198_0"].selectedAppraiser = p1
    end
})
_U["411_0"] = v107
AppraiseToggle = AppraiseSection:AddToggle({
    Title = "Auto Appraise On Held",
    Default = false,
    Callback = function(p1)
        _U["411_0"].autoAppraiseRunning = p1
        if not p1 then
            if _U["411_0"].appraiseThread then
                task.cancel(_U["411_0"].appraiseThread)
                _U["411_0"].appraiseThread = nil
                _U["411_0"].appraiserPromptFired = false
            end
        else
            _U["411_0"].appraiseThread = task.spawn(function()
            local u1, u2, u3, u4, u5, u6
                u1 = game.Players.LocalPlayer
                u2 = u1.Character
                if not u2 then
                    u2 = u1.CharacterAdded:Wait()
                end
                u3 = u2:WaitForChild("HumanoidRootPart")
                u4 = game:GetService("ReplicatedStorage").packages.Net["RF/DialogInteract"]
                if not _U["411_0"].appraiserPromptFired then
                    u5 = u3.CFrame
                    u3.CFrame = _U["411_0"].appraiserCFrames[_U["411_0"].selectedAppraiser]
                    task.wait(1)
                    u6 = _U["411_0"].appraiserPromptPaths[_U["411_0"].selectedAppraiser]()
                    if u6 then
                        mengfireproximityprompt(u6)
                        task.wait(1)
                    end
                    u3.CFrame = u5
                    task.wait(0.2)
                    _U["411_0"].appraiserPromptFired = true
                end
                while true do
                    if not _U["411_0"].autoAppraiseRunning then
                        _U["411_0"].appraiseThread = nil
                        _U["411_0"].appraiserPromptFired = false
                        return
                    else
                        u5, u6 = checkAppraise(u2)
                        if u5 then
                            break
                        end
                        u4:InvokeServer(_U["411_0"].appraiserDialogIds[_U["411_0"].selectedAppraiser], 1)
                        task.wait(0.1)
                        u4:InvokeServer(1, 1)
                        task.wait(0.1)
                        u4:InvokeServer(3, 1)
                        task.wait(0.3)
                    end
                end
                _U["411_0"].autoAppraiseRunning = false
                AppraiseToggle:Set(false)
                notif("Target appraise ketemu! " .. u6)
            end)
        end
    end
})
v108 = require(ReplicatedStorage.packages.Net)
v109 = v108:RemoteFunction("Storage/RequestBulkMove")
v110 = v108:RemoteEvent("Backpack/Favourite")
v111 = require(ReplicatedStorage.client.legacyControllers.DataController)
v112 = require(ReplicatedStorage.client.modules.ui.Backpack.itemDisplayInfo)
_R["113_v1"] = {}
v111.InventoryReplicator:Observe({ "Inventory" }, function(p1)
local l2
    l2 = p1
    if not l2 then
        l2 = {}
    end
    _R["113_v1"] = l2
end)
_R["114_v1"] = false
_R["115_v1"] = 30
_R["116_v1"] = nil
_R["117_v1"] = {}
_R["118_v1"] = ""
_R["119_v1"] = {}
_R["120_v1"] = {}
_R["121_v1"] = {}
_R["122_v1"] = true
_R["123_v1"] = false
normalizeOpts = function(p1)
local l2, l3, l4, l5
    l2 = {}
    if type(p1) ~= "string" then
        if type(p1) == "table" then
            for _k1, _v1 in pairs(p1) do
                l4, l5 = _k1, _v1
                if type(l4) ~= "number" then
                    if type(l4) == "string" then
                        if l5 == true then
                            l2[l4] = true
                        end
                    end
                else
                    if type(l5) == "string" then
                        l2[l5] = true
                    end
                end
            end
        end
    else
        l2[p1] = true
    end
    return l2
end
_U["477_0"] = v112
getRarityOfItem = function(p1)
local l2, l3
    if not p1 then
        return nil
    else
        if p1.name then
            l2 = _U["477_0"][p1.name]
            l3 = l2
            if l3 then
                l3 = l2.rarity
            end
            if not l3 then
                l3 = nil
            end
            return l3
        end
    end
end
getMutation = function(p1)
local l2
    if p1 then
        l2 = p1.sub
        if l2 then
            l2 = p1.sub.Mutation
        end
        if not l2 then
            l2 = nil
        end
        return l2
    else
        return nil
    end
end
itemMatches = function(p1)
local l2, l3, l4, l5, l6, l7, l8
    l2 = next(_R["119_v1"]) ~= nil
    l3 = next(_R["120_v1"]) ~= nil
    l4 = next(_R["121_v1"]) ~= nil
    if l2 then
        l5 = l2
        if l5 then
            l5 = _R["119_v1"][p1.name] == true
        end
        l6 = l3
        if l6 then
            l6 = _R["120_v1"][getRarityOfItem(p1)] == true
        end
        l7 = l4
        if l7 then
            l7 = _R["121_v1"][getMutation(p1)] == true
        end
        if not _R["122_v1"] then
            l8 = l5
            if not l8 then
                l8 = l6
            end
            if not l8 then
                l8 = l7
            end
            return l8
        else
            if not l2 then
                if not l3 then
                    if not l4 then
                        return true
                    else
                        if not l7 then
                            return false
                        end
                    end
                else
                    if not l6 then
                        return false
                    end
                end
            else
                if not l5 then
                    return false
                end
            end
        end
    else
        if not l3 then
            if not l4 then
                return false
            end
        end
    end
end
getInventoryFishNames = function()
local l1, l2, l3, l4, l5
    l1 = {}
    l2 = {}
    for _k1, _v1 in pairs(_R["113_v1"]) do
        l4, l5 = _k1, _v1
        if l5.name then
            if not l1[l5.name] then
                l1[l5.name] = true
                table.insert(l2, l5.name)
            end
        end
    end
    table.sort(l2)
    return l2
end
_U["449_1"] = v110
_U["449_2"] = v111
bulkSetFavourite = function(p1, p2)
local l3, l4, l5, l6
    if (#p1) ~= 0 then
        for _k1, _v1 in ipairs(p1) do
            l4, l5 = _k1, _v1
            if _R["113_v1"][l5] then
                if not _R["113_v1"][l5].sub then
                    l6 = _R["113_v1"][l5]
                    l6.sub = {}
                end
                l6 = _R["113_v1"][l5].sub
                l6.Favourited = p2
            end
            _U["449_1"]:FireServer(l5, p2)
            task.wait()
        end
        _U["449_2"].DataChanged:Fire("Inventory", _R["113_v1"], _R["113_v1"])
        return
    end
end
withAquariumTeleport = function(p1)
local _U_376 = {}
local l2, l3, l4, l5, l6, l7
    l2 = LocalPlayer.Character
    if l2 then
        l5 = "HumanoidRootPart"
        l3 = l2:FindFirstChild(l5)
        if l3 then
            l5 = l3.CFrame
            l6 = true
            l4 = pauseAndWaitFishing()
            _U_376["262_2"] = l5
            l7 = task.spawn(function()
                while true do
                    if not l6 then
                        break
                    end
                    l3.CFrame = _U_376["262_2"]
                    l3.AssemblyLinearVelocity = Vector3.zero
                    task.wait()
                end
            end)
            ReplicatedStorage.packages.Net["RE/PersonalAquarium/Join"]:FireServer(LocalPlayer.CharacterAppearanceId)
            task.wait(1.2)
            p1()
            task.wait(0.2)
            l6 = false
            task.cancel(l7)
            l4()
            return
        end
    end
end
stopAutoStorage = function()
    if _R["116_v1"] then
        task.cancel(_R["116_v1"])
        _R["116_v1"] = nil
    end
end
_U["456_3"] = v111
_U["456_4"] = v109
startAutoStorage = function()
    stopAutoStorage()
    _R["116_v1"] = task.spawn(function()
        while true do
            if not _R["114_v1"] then
                break
            end
            if 0 < (#_R["117_v1"]) then
                withAquariumTeleport(function()
                local w1, w2, w3, w4, w5, w6
                    w1 = _U["456_3"].InventoryReplicator:Index({ "Inventory" })
                    if w1 then
                        w2 = {}
                        for _k3, _v3 in pairs(w1) do
                            w4, w5 = _k3, _v3
                            w6 = getRarityOfItem(w5)
                            if w6 then
                                if table.find(_R["117_v1"], w6) then
                                    table.insert(w2, w4)
                                end
                            end
                        end
                        if 0 < (#w2) then
                            _U["456_4"]:InvokeServer(w2, false)
                        end
                        return
                    end
                end)
            end
            if _R["118_v1"] ~= "" then
                withAquariumTeleport(function()
                local w1, w2, w3, w4, w5, w6, w7
                    w1 = _U["456_3"].InventoryReplicator:Index({ "Inventory" })
                    if w1 then
                        w2 = {}
                        for _k3, _v3 in pairs(w1) do
                            w4, w5 = _k3, _v3
                            if w5.name then
                                if w6(w7, _R["118_v1"]:lower(), 1, true) then
                                    table.insert(w2, w4)
                                end
                            end
                        end
                        if 0 < (#w2) then
                            _U["456_4"]:InvokeServer(w2, false)
                        end
                        return
                    end
                end)
            end
            task.wait(_R["115_v1"])
        end
    end)
end
print("Waiting 0.5s")
task.wait(0.5)
_R["124_v1"] = 30
_R["125_v1"] = false
_R["126_v1"] = nil
_R["127_v1"] = false
_R["128_v1"] = false
_R["129_v1"] = {}
v130 = ReplicatedStorage.packages.Net["RE/PersonalAquarium/PurchaseFishFood"]
v131 = ReplicatedStorage.packages.Net["RE/PersonalAquarium/ActivateFishFood"]
AquariumSection = v43.Auto:AddSection("Aquarium")
AquariumSection:AddToggle({
    Title = "Auto Claim Aquarium",
    Default = false,
    Callback = function(p1)
        _R["125_v1"] = p1
        if not p1 then
            if _R["126_v1"] then
                task.cancel(_R["126_v1"])
                _R["126_v1"] = nil
            end
        else
            _R["126_v1"] = task.spawn(function()
            local u1
                u1 = ReplicatedStorage.packages.Net["RE/PersonalAquarium/ClaimRewards"]
                if _R["125_v1"] then
                    while true do
                        u1:FireServer()
                        task.wait(_R["124_v1"])
                        if not _R["125_v1"] then
                            break
                        end
                    end
                end
            end)
        end
    end
})
AquariumSection:AddInput({
    Title = "Claim Delay (s)",
    Default = _R["124_v1"],
    Callback = function(p1)
    local l2
        l2 = tonumber(p1)
        if l2 then
            if 0 < l2 then
                _R["124_v1"] = l2
            end
        end
    end
})
AquariumSection:AddSubSection("Fish Food")
AquariumSection:AddDropdown({
    Title = "Select Foods",
    Options = {
        "GuppiesBest",
        "SplashSnacks",
        "FishChow"
    },
    Default = {},
    Multi = true,
    Callback = function(p1)
    local l2
        l2 = type(p1) == "string"
        if l2 then
            l2 = { p1 }
        end
        if not l2 then
            l2 = p1
        end
        _R["129_v1"] = l2
    end
})
AquariumSection:AddToggle({
    Title = "Auto Buy Selected Foods",
    Default = false,
    Callback = function(p1)
        _R["127_v1"] = p1
    end
})
AquariumSection:AddToggle({
    Title = "Auto Use Selected Foods",
    Default = false,
    Callback = function(p1)
        _R["128_v1"] = p1
    end
})
_U["348_2"] = v130
_U["348_4"] = v131
task.spawn(function()
local l1, l2, l3
    while true do
        if not task.wait(5) then
            break
        end
        if _R["127_v1"] then
            if 0 < (#_R["129_v1"]) then
                for _k1, _v1 in ipairs(_R["129_v1"]) do
                    l2, l3 = _k1, _v1
                    _U["348_2"]:FireServer(l3)
                    task.wait(0.3)
                end
            end
        end
        if _R["128_v1"] then
            if 0 < (#_R["129_v1"]) then
                for _k1, _v1 in ipairs(_R["129_v1"]) do
                    l2, l3 = _k1, _v1
                    _U["348_4"]:FireServer(l3)
                    task.wait(0.3)
                end
            end
        end
    end
end)
StorageSection = v43.Auto:AddSection("Storage")
StorageSection:AddSubSection("Preffed By Name")
StorageSection:AddInput({
    Title = "Fish Name",
    Placeholder = "Write ur input here (e.g. Megalodon)",
    Callback = function(p1)
        _R["118_v1"] = p1
    end
})
_U["161_1"] = v111
_U["161_2"] = v109
StorageSection:AddButton({
    Title = "Add Fish By Name Into Storage",
    Callback = function()
        if _R["118_v1"] ~= "" then
            withAquariumTeleport(function()
            local u1, u2, u3, u4, u5, u6, u7
                u1 = _U["161_1"].InventoryReplicator:Index({ "Inventory" })
                if u1 then
                    u2 = {}
                    for _k2, _v2 in pairs(u1) do
                        u4, u5 = _k2, _v2
                        if u5.name then
                            if u6(u7, _R["118_v1"]:lower(), 1, true) then
                                table.insert(u2, u4)
                            end
                        end
                    end
                    if 0 < (#u2) then
                        _U["161_2"]:InvokeServer(u2, false)
                    end
                    return
                end
            end)
            return
        end
    end
})
_U["427_1"] = v111
_U["427_2"] = v109
StorageSection:AddButton({
    Title = "Remove Fish By Name From Storage",
    Callback = function()
        if _R["118_v1"] ~= "" then
            withAquariumTeleport(function()
            local u1, u2, u3, u4, u5, u6, u7
                u1 = _U["427_1"].StorageReplicator:Index({ "Storage" })
                if u1 then
                    u2 = {}
                    for _k2, _v2 in pairs(u1) do
                        u4, u5 = _k2, _v2
                        if u5.name then
                            if u6(u7, _R["118_v1"]:lower(), 1, true) then
                                table.insert(u2, u4)
                            end
                        end
                    end
                    if 0 < (#u2) then
                        _U["427_2"]:InvokeServer(u2, true)
                    end
                    return
                end
            end)
            return
        end
    end
})
StorageSection:AddSubSection("Preffed By Rarity")
StorageSection:AddDropdown({
    Title = "Select Rarities",
    Options = v39,
    Default = {},
    Multi = true,
    Callback = function(p1)
    local l2
        l2 = type(p1) == "string"
        if l2 then
            l2 = { p1 }
        end
        if not l2 then
            l2 = p1
        end
        _R["117_v1"] = l2
    end
})
_U["158_1"] = v111
_U["158_2"] = v109
StorageSection:AddButton({
    Title = "Add All Fishes With Selected Rarities Into Storage",
    Callback = function()
        if (#_R["117_v1"]) ~= 0 then
            withAquariumTeleport(function()
            local u1, u2, u3, u4, u5, u6
                u1 = _U["158_1"].InventoryReplicator:Index({ "Inventory" })
                if u1 then
                    u2 = {}
                    for _k2, _v2 in pairs(u1) do
                        u4, u5 = _k2, _v2
                        u6 = getRarityOfItem(u5)
                        if u6 then
                            if table.find(_R["117_v1"], u6) then
                                table.insert(u2, u4)
                            end
                        end
                    end
                    if 0 < (#u2) then
                        _U["158_2"]:InvokeServer(u2, false)
                    end
                    return
                end
            end)
            return
        end
    end
})
_U["170_1"] = v111
_U["170_2"] = v109
StorageSection:AddButton({
    Title = "Remove All Fishes With Selected Rarities From Storage",
    Callback = function()
        if (#_R["117_v1"]) ~= 0 then
            withAquariumTeleport(function()
            local u1, u2, u3, u4, u5, u6
                u1 = _U["170_1"].StorageReplicator:Index({ "Storage" })
                if u1 then
                    u2 = {}
                    for _k2, _v2 in pairs(u1) do
                        u4, u5 = _k2, _v2
                        u6 = getRarityOfItem(u5)
                        if u6 then
                            if table.find(_R["117_v1"], u6) then
                                table.insert(u2, u4)
                            end
                        end
                    end
                    if 0 < (#u2) then
                        _U["170_2"]:InvokeServer(u2, true)
                    end
                    return
                end
            end)
            return
        end
    end
})
StorageSection:AddSubSection("Auto Storage")
StorageSection:AddInput({
    Title = "Auto Storage Interval",
    Default = "30",
    Placeholder = "Write ur input here...",
    Callback = function(p1)
    local l2
        l2 = tonumber(p1)
        if l2 then
            if 0 < l2 then
                _R["115_v1"] = l2
            end
        end
        if _R["114_v1"] then
            startAutoStorage()
        end
    end
})
StorageSection:AddToggle({
    Title = "Enable Auto Storage",
    Default = false,
    Callback = function(p1)
        _R["114_v1"] = p1
        if not p1 then
            stopAutoStorage()
            return
        else
            startAutoStorage()
            return
        end
    end
})
FavoriteSection = v43.Auto:AddSection("Favorite")
FavoriteDropdown = v132(v133, {
    Title = "Select Fish to Favorite",
    Options = getInventoryFishNames(),
    Default = {},
    Multi = true,
    Callback = function(p1)
        _R["119_v1"] = normalizeOpts(p1)
    end
})
FavoriteSection:AddDropdown({
    Title = "Select Rarity to Favorite",
    Options = v39,
    Default = {},
    Multi = true,
    Callback = function(p1)
        _R["120_v1"] = normalizeOpts(p1)
    end
})
FavoriteSection:AddDropdown({
    Title = "Select Mutation to Favorite",
    Options = v36,
    Default = {},
    Multi = true,
    Callback = function(p1)
        _R["121_v1"] = normalizeOpts(p1)
    end
})
FavoriteSection:AddDropdown({
    Title = "Select Mode",
    Options = { "Strict", "Non-Strict" },
    Default = "Strict",
    Callback = function(p1)
        _R["122_v1"] = p1 == "Strict"
    end
})
FavoriteSection:AddButton({
    Title = "Refresh Fish",
    Callback = function()
        FavoriteDropdown:SetValues(getInventoryFishNames())
        _R["119_v1"] = {}
    end
})
FavoriteSection:AddToggle({
    Title = "Auto Favorite Fish",
    Callback = function(p1)
        _R["123_v1"] = p1
        if p1 then
            task.spawn(function()
            local u1, u2, u3, u4
                while true do
                    if not _R["123_v1"] then
                        break
                    end
                    u1 = {}
                    for _k2, _v2 in pairs(_R["113_v1"]) do
                        u3, u4 = _k2, _v2
                        if not _R["123_v1"] then
                            break
                        end
                        if itemMatches(u4) then
                            if not u4.sub then
                                table.insert(u1, u3)
                            end
                        end
                    end
                    bulkSetFavourite(u1, true)
                    task.wait(2)
                end
            end)
            return
        end
    end
})
FavoriteSection:AddButton({
    Title = "Unfavorite All",
    Callback = function()
    local l1, l2, l3, l4
        _R["123_v1"] = false
        task.wait(0.1)
        l1 = {}
        for _k1, _v1 in pairs(_R["113_v1"]) do
            l3, l4 = _k1, _v1
            if l4.sub then
                if l4.sub.Favourited then
                    table.insert(l1, l3)
                end
            end
        end
        bulkSetFavourite(l1, false)
    end
})
MiningSection = v43.Auto:AddSection("Mining Dripstone")
v132 = false
v133 = {
    [1] = CFrame.new(3143.34, -1101.96, 1624.77),
    [2] = CFrame.new(3906.72, -1092.81, 912.64),
    [3] = CFrame.new(2947.59, -1102.42, 72.65),
    [4] = CFrame.new(3121.78, -1127.33, 2050.75),
    [5] = CFrame.new(3099.19, -1100.61, 1126.36),
    [6] = CFrame.new(3377.82, -1098.53, 945.29)
}
StatusLabel = MiningSection:AddParagraph({ Title = "Mining Status:", Content = "Idle" })
MiningSection:AddToggle({
    Title = "Enable Auto Mining",
    Default = false,
    Callback = function(p1)
    local _U_398 = {}
    local l2, l3, l4
        v132 = p1
        if p1 then
            l2 = LocalPlayer.Character
            l3 = l2
            if l3 then
                l3 = l2:FindFirstChild("Humanoid")
            end
            l4 = l2
            if l4 then
                l4 = l2:FindFirstChild("HumanoidRootPart")
            end
            task.spawn(function()
            local _R_366 = {}
            local _U_366 = {}
            local u1, u2
                u1 = 1
                u2 = v132
                if u2 then
                    while true do
                        u2 = v133[u1]
                        if u2 then
                            _U_366["139_1"] = u2
                            task.spawn(function()
                                pcall(function()
                                    LocalPlayer:RequestStreamAroundAsync(_U_366["139_1"].Position, 100)
                                end)
                            end)
                            u1 = u1 + 1
                            if (#v133) >= u1 then
                                u1 = 1
                            end
                        end
                        task.wait(0.6)
                        u2 = v132
                        if not u2 then
                            break
                        end
                    end
                end
            end)
            _U_398["259_1"] = l4
            _U_398["259_2"] = l3
            task.spawn(function()
            local u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13
                while true do
                    if not v132 then
                        break
                    end
                    u1 = {}
                    for _k2, _v2 in pairs(workspace:GetChildren()) do
                        u3, u4 = _k2, _v2
                        if u4.Name:find("DripstoneMineable") then
                            table.insert(u1, u4)
                        end
                    end
                    if 0 >= (#u1) then
                        StatusLabel:SetContent("Scanning for Dripstones")
                    else
                        StatusLabel:SetContent("Dripstone Found! Switching...")
                        u2 = _U_398["259_1"].CFrame
                        u3 = pauseAndWaitFishing()
                        _U_398["259_2"]:UnequipTools()
                        task.wait(0.5)
                        u4 = LocalPlayer.Backpack:FindFirstChild("Pickaxe")
                        if u4 then
                            _U_398["259_2"]:EquipTool(u4)
                            task.wait(0.3)
                        end
                        for _k2, _v2 in ipairs(u1) do
                            u6, u7 = _k2, _v2
                            if not v132 then
                                break
                            end
                            if u7:IsDescendantOf(workspace) then
                                u8 = u7:IsA("Model")
                                if u8 then
                                    u8 = u7:GetPivot().Position
                                end
                                if not u8 then
                                    u8 = u7.Position
                                end
                                u9 = CFrame.new
                                u10 = CFrame.new(u8)
                                u9 = u9(((u10 * CFrame.new(0, 2, 5))).Position, u8)
                                StatusLabel:SetContent("Mining: " .. u7.Name)
                                _U_398["259_1"].CFrame = u9
                                task.wait(0.3)
                                u10(u11, Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                                u10 = tick()
                                u11 = tick()
                                while true do
                                    task.wait()
                                    if 2 > (tick() - u11) then
                                        u12(u13, Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                                        u11 = tick()
                                    end
                                    if not u7:IsDescendantOf(workspace) then
                                        break
                                    end
                                    if 15 < (tick() - u10) then
                                        break
                                    end
                                    if not v132 then
                                        break
                                    end
                                end
                            end
                        end
                        u5 = {}
                        for _k2, _v2 in pairs(workspace:GetChildren()) do
                            u7, u8 = _k2, _v2
                            if u8.Name:find("DripstoneMineable") then
                                table.insert(u5, u8)
                            end
                        end
                        if (#u5) == 0 then
                            StatusLabel:SetContent("All done! Returning...")
                            _U_398["259_1"].CFrame = u2
                            _U_398["259_1"].Anchored = false
                            if typeof(reEquipRod) == "function" then
                                reEquipRod()
                            end
                            u3()
                            task.wait(2)
                        end
                    end
                    task.wait(1)
                end
                StatusLabel:SetContent("Stopped")
            end)
            return
        else
            l4 = "Idle"
            StatusLabel:SetContent(l4)
            return
        end
    end
})
v134 = {
    Enabled = false,
    AnglerKey = "Moosewood Village",
    YDistance = 0,
    WithSnapReel = false
}
v135 = {
    ["Moosewood Village"] = {
        NpcName = "Moosewood Angler",
        CF = CFrame.new(480.9, 150.53, 297.84) * CFrame.Angles(math.rad(-180), math.rad(6.76), math.rad(180)),
        FishingCF = CFrame.new(552.99, 152.77, 312.96) * CFrame.Angles(math.rad(-3.53), math.rad(67.66), math.rad(4.47))
    },
    ["Roslit Hamlet"] = {
        NpcName = "Roslit Angler",
        CF = CFrame.new(-1508.89, 138.34, 690.73) * CFrame.Angles(math.rad(0), math.rad(52.16), math.rad(0)),
        FishingCF = CFrame.new(-1513.76, 139.45, 789.97) * CFrame.Angles(math.rad(180), math.rad(-14.57), math.rad(180))
    },
    ["Sunstone Island"] = {
        NpcName = "Sunstone Angler",
        CF = CFrame.new(-888.62, 133.81, -1113.74) * CFrame.Angles(math.rad(0), math.rad(-1.68), math.rad(0)),
        FishingCF = CFrame.new(-839.29, 133.17, -1180.25) * CFrame.Angles(math.rad(0), math.rad(-57.53), math.rad(0))
    },
    ["Terrapin Island"] = {
        NpcName = "Terrapin Angler",
        CF = CFrame.new(-152.03, 144.14, 1954.19) * CFrame.Angles(math.rad(0), math.rad(9.48), math.rad(0)),
        FishingCF = CFrame.new(-201.69, 131.45, 1886.81) * CFrame.Angles(math.rad(0), math.rad(-3.26), math.rad(0))
    },
    ["The Depths"] = {
        NpcName = "The Depths Angler",
        CF = CFrame.new(978.78, -702.87, 1233.94) * CFrame.Angles(math.rad(0), math.rad(-59.84), math.rad(0)),
        FishingCF = CFrame.new(869.58, -737.92, 1243.95) * CFrame.Angles(math.rad(180), math.rad(86.16), math.rad(-180))
    },
    ["Ancient Isle"] = {
        NpcName = "Ancient Isle Angler",
        CF = CFrame.new(5734.25, 176.99, -48.81) * CFrame.Angles(math.rad(0), math.rad(-45.14), math.rad(0)),
        FishingCF = CFrame.new(6004.94, 240.49, 553.8) * CFrame.Angles(math.rad(-180), math.rad(50.52), math.rad(180))
    },
    ["Forsaken Shores"] = {
        NpcName = "Forsaken Shores Angler",
        CF = CFrame.new(-2699.14, 164.75, 1797.4) * CFrame.Angles(math.rad(-180), math.rad(84.19), math.rad(180)),
        FishingCF = CFrame.new(-2697.19, 139.65, 1852.08) * CFrame.Angles(math.rad(0), math.rad(-87.56), math.rad(0))
    },
    ["Crimson Cavern"] = {
        NpcName = "Crimson Cavern Angler",
        CF = CFrame.new(-1068.99, -360.98, -4813.3) * CFrame.Angles(math.rad(0), math.rad(77.28), math.rad(0)),
        FishingCF = CFrame.new(-1109.38, -364.76, -4836.36) * CFrame.Angles(math.rad(0), math.rad(-58.35), math.rad(0))
    },
    ["Luminescent Cavern"] = {
        NpcName = "Luminescent Cavern Angler",
        CF = CFrame.new(-1042.94, -336.85, -4081.59) * CFrame.Angles(math.rad(180), math.rad(40.76), math.rad(180)),
        FishingCF = CFrame.new(-1028.78, -337.57, -4096.74) * CFrame.Angles(math.rad(0), math.rad(-66.91), math.rad(0))
    },
    ["Scoria Reach"] = {
        NpcName = "ScoriaReachAngler",
        CF = CFrame.new(-5137.95, 153.8, -1331.79) * CFrame.Angles(math.rad(-180), math.rad(-49.17), math.rad(-180)),
        FishingCF = CFrame.new(-5431.78, 185.61, -1582.82) * CFrame.Angles(math.rad(0), math.rad(79.88), math.rad(0))
    }
}
v136 = {
    Moosewood = "Moosewood Village",
    Roslit = "Roslit Hamlet",
    Sunstone = "Sunstone Island",
    Terrapin = "Terrapin Island",
    ["The Depths"] = "The Depths",
    ["Ancient Isle"] = "Ancient Isle",
    ["Forsaken Shores"] = "Forsaken Shores",
    ["Crimson Cavern"] = "Crimson Cavern",
    ["Luminescent Cavern"] = "Luminescent Cavern",
    ["Scoria Reach"] = "Scoria Reach"
}
v137 = {
    ActiveLoop = nil,
    IsFishing = false,
    _hookedSnapReel = false,
    _prevSnapEnabled = nil,
    _prevSnapTargets = nil,
    _prevSnapManual = nil
}
anglerStatus = function(p1)
    if anglerLabel then
        anglerLabel:SetContent(p1)
    end
end
getEquippedRodForAngler = function()
local l1, l2, l3, l4
    l1 = LocalPlayer.Character
    if l1 then
        for _k1, _v1 in pairs(l1:GetChildren()) do
            l3, l4 = _k1, _v1
            if l4:IsA("Tool") then
                if l4:FindFirstChild("events") then
                    if l4.events:FindFirstChild("castAsync") then
                        return l4
                    end
                end
            end
        end
        return nil
    else
        return nil
    end
end
getActiveQuest = function()
local l1, l2, l3
    l1, l2 = pcall(function()
    local u1, u2, u3, u4, u5, u6, u7
        u1 = LocalPlayer.PlayerGui.hud.deviceinset.quests.template.main
        u2 = u1.subtitle.Text
        u3 = u1.Line1.Text
        if not u2 then
            return nil
        else
            if u2 ~= "" then
                if not u3 then
                    return nil
                else
                    if u3 ~= "" then
                        u4 = nil
                        for _k2, _v2 in pairs(v136) do
                            u6, u7 = _k2, _v2
                            if u2:find(u6, 1, true) then
                                u4 = u7
                                break
                            end
                        end
                        return { fish = u3, key = u4 }
                    end
                end
            end
        end
    end)
    l3 = l1
    if l3 then
        l3 = l2
    end
    if not l3 then
        l3 = nil
    end
    return l3
end
getAnglerPP = function(p1)
local l2, l3
    l2 = workspace:FindFirstChild("world")
    if l2 then
        l2 = workspace.world:FindFirstChild("npcs")
    end
    if not l2 then
        l3 = workspace:FindFirstChild(p1)
        if not l3 then
            return nil
        else
            return l3:FindFirstChildWhichIsA("ProximityPrompt", true)
        end
    else
        l3 = l2:FindFirstChild(p1)
        if l3 then
            return l3:FindFirstChildWhichIsA("ProximityPrompt", true)
        end
    end
end
teleportTo = function(p1)
local l2
    l2 = LocalPlayer.Character
    if l2 then
        l2 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    if l2 then
        l2.CFrame = p1
        task.wait(0.7)
    end
end
equipRodForAngler = function()
local l1, l2, l3, l4, l5, l6
    l1 = LocalPlayer.Character
    l2 = LocalPlayer:FindFirstChild("Backpack")
    if l1 then
        if l2 then
            l3 = l1:FindFirstChildOfClass("Humanoid")
            for _k1, _v1 in pairs(l2:GetChildren()) do
                l5, l6 = _k1, _v1
                if l6:IsA("Tool") then
                    if l6:FindFirstChild("events") then
                        l3:EquipTool(l6)
                        break
                    end
                end
            end
        end
    end
end
hasFish = function(p1)
local l2, l3, l4
    for _k1, _v1 in ipairs(LocalPlayer.Backpack:GetChildren()) do
        l3, l4 = _k1, _v1
        if l4:IsA("Tool") then
            if l4.Name == p1 then
                return true
            end
        end
    end
    if not LocalPlayer.Character then
        return false
    else
        for _k1, _v1 in ipairs(LocalPlayer.Character:GetChildren()) do
            l3, l4 = _k1, _v1
            if l4:IsA("Tool") then
                if l4.Name == p1 then
                    return true
                end
            end
        end
    end
end
equipFish = function(p1)
local l2, l3, l4
    l2 = LocalPlayer.Character
    l3 = l2
    if l3 then
        l3 = l2:FindFirstChildOfClass("Humanoid")
    end
    if l3 then
        if not l2:FindFirstChild(p1) then
            l4 = LocalPlayer.Backpack:FindFirstChild(p1)
            if l4 then
                l3:EquipTool(l4)
                task.wait(0.5)
            end
            return
        end
    end
end
clickDialogOption = function(p1)
local _U_419 = {}
local l2, l3, l4, l5, l6, l7, l8
    l2 = nil
    l3 = nil
    l4 = nil
    l5 = tick()
    while true do
        l2 = LocalPlayer.PlayerGui:FindFirstChild("options")
        l6 = l2
        if l6 then
            l6 = l2:FindFirstChild("safezone")
        end
        l3 = l6
        l6 = l3
        if l6 then
            l6 = l3:FindFirstChild(p1)
        end
        l4 = l6
        if not l4 then
            l6 = task.wait
            l6(0.1)
        end
        if l4 then
            break
        end
        l6 = tick() - l5
        if 2 < l6 then
            break
        end
    end
    if l4 then
        l6 = l4:FindFirstChildWhichIsA("TextButton", true)
        if not l6 then
            l6 = l4:FindFirstChildWhichIsA("ImageButton", true)
        end
        if not l6 then
            l6 = l4
        end
        if not firesignal then
            l7 = game:GetService("GuiService")
            l8 = game:GetService("VirtualInputManager")
            l7.SelectedObject = l6
            task.wait(0.1)
            l8:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.05)
            l8:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait(0.1)
            l7.SelectedObject = nil
            task.wait(0.3)
            return true
        else
            _U_419["256_0"] = l6
            pcall(function()
                firesignal(_U_419["256_0"].MouseButton1Click)
            end)
            _U_419["145_0"] = l6
            pcall(function()
                firesignal(_U_419["145_0"].Activated)
            end)
            task.wait(0.3)
            return true
        end
    else
        l6 = false
        return l6
    end
end
restoreSnapReel = function()
local l1, l2
    if v137._hookedSnapReel then
        l1 = SnapReelSettings
        l2 = v137._prevSnapEnabled
        if not l2 then
            l2 = false
        end
        l1.Enabled = l2
        l1 = SnapReelSettings
        l2 = v137._prevSnapTargets
        if not l2 then
            l2 = {}
        end
        l1.Targets = l2
        l1 = SnapReelSettings
        l2 = v137._prevSnapManual
        if not l2 then
            l2 = ""
        end
        l1.ManualTarget = l2
        v137._hookedSnapReel = false
        v137._prevSnapEnabled = nil
        v137._prevSnapTargets = nil
        v137._prevSnapManual = nil
    end
end
applySnapReel = function()
local l1, l2
    if v134.WithSnapReel then
        l1 = getActiveQuest()
        if l1 then
            if l1.fish then
                if l1.fish ~= "" then
                    if not v137._hookedSnapReel then
                        v137._prevSnapEnabled = SnapReelSettings.Enabled
                        v137._prevSnapTargets = SnapReelSettings.Targets
                        v137._prevSnapManual = SnapReelSettings.ManualTarget
                        v137._hookedSnapReel = true
                    end
                    l2 = SnapReelSettings
                    l2.Enabled = true
                    l2 = SnapReelSettings
                    l2.Targets = {}
                    l2 = SnapReelSettings
                    l2.ManualTarget = l1.fish
                    anglerStatus("Snap Reel aktif ? " .. l1.fish)
                    return
                end
            end
        end
    else
        restoreSnapReel()
        return
    end
end
stopAnglerLoop = function()
    if v137.ActiveLoop then
        task.cancel(v137.ActiveLoop)
        v137.ActiveLoop = nil
    end
    v137.IsFishing = false
end
stopAnglerFishing = function()
    restoreSnapReel()
    stopAnglerLoop()
end
startAnglerFastFishing = function()
local l1, l2
    stopAnglerLoop()
    v137.IsFishing = true
    applySnapReel()
    l1 = game:GetService("ReplicatedStorage").packages.Net["RF/FishingRod/Cast"]
    l2 = LocalPlayer:WaitForChild("PlayerGui")
    v137.ActiveLoop = task.spawn(function()
    local _R_230 = {}
    local _U_230 = {}
    local u2, u3, u4, u5, u6, u7, u8, u9
        while true do
            if not v137.IsFishing then
                break
            end
            if LocalPlayer.Character then
                u2 = getEquippedRodForAngler()
                if u2 then
                    u3 = l2:FindFirstChild("shakeui")
                    u4 = l2:FindFirstChild("reel")
                    if not u3 then
                        if not u4 then
                            if u2:FindFirstChild("events") then
                                if u2.events:FindFirstChild("reset") then
                                    _U_230["428_0"] = u2
                                    pcall(function()
                                        _U_230["428_0"].events.reset:FireServer()
                                    end)
                                end
                            end
                            task.wait(0.1)
                            pcall(function()
                                l1:InvokeServer(99.5, false, true)
                                task.wait(0.1)
                            end)
                            task.wait(0.95)
                        end
                    end
                    if u3 then
                        if u3.Enabled then
                            u5 = u3:FindFirstChild("safezone")
                            u6 = u5
                            if u6 then
                                u6 = u5:FindFirstChild("button")
                            end
                            if u6 then
                                if u6.Visible then
                                    u7 = u6:FindFirstChildOfClass("UIScale")
                                    if u7 then
                                        u8 = u7.Scale
                                        task.wait(0.05)
                                        u9 = u7.Scale
                                        if math.abs(u9 - u8) >= 0.01 then
                                            if 0.9 < u9 then
                                                game:GetService("ReplicatedStorage").packages.Net["RE/LureShake/Shake"]:FireServer()
                                                task.wait(0.15)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                else
                    task.wait(0.5)
                end
            else
                u2 = task.wait
                u2(0.5)
            end
        end
    end)
end
anglerCleanup = function()
local l1, l2
    stopAnglerFishing()
    pcall(cancelFishing)
    task.wait(0.3)
    l1 = LocalPlayer.Character
    l2 = l1
    if l2 then
        l2 = l1:FindFirstChildOfClass("Humanoid")
    end
    if l2 then
        l2:UnequipTools()
    end
end
anglerLoop = function()
local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10
    while true do
        if not v134.Enabled then
            break
        end
        l1 = getActiveQuest()
        l2 = nil
        l3 = nil
        l4 = nil
        if not l1 then
            l3 = v134.AnglerKey
            l4 = v135[l3]
            if l4 then
                stopAnglerFishing()
                pcall(cancelFishing)
                task.wait(0.3)
                l5 = LocalPlayer.Character
                l6 = l5
                if l6 then
                    l6 = l5:FindFirstChildOfClass("Humanoid")
                end
                l7 = l5
                if l7 then
                    l7 = l5:FindFirstChild("HumanoidRootPart")
                end
                if l7 then
                    if l6 then
                        l6:UnequipTools()
                    end
                    task.wait(0.3)
                    anglerStatus("Teleporting to " .. (l3 .. "..."))
                    teleportTo(l4.CF * CFrame.new(0, v134.YDistance, 0))
                    anglerStatus("Talking to Angler...")
                    l8 = getAnglerPP(l4.NpcName)
                    if l8 then
                        mengfireproximityprompt(l8)
                        task.wait(1)
                        l9 = getActiveQuest()
                        if not l9 then
                            anglerStatus("Accepting quest...")
                            clickDialogOption("1option")
                            task.wait(1.5)
                            l9 = getActiveQuest()
                        end
                        if not l9 then
                            anglerStatus("Couldn't read quest. Retrying...")
                            task.wait(2)
                        else
                            if l9.fish then
                                if l9.fish ~= "" then
                                    l2 = l9.fish
                                    if l9.key then
                                        l3 = l9.key
                                        l10 = v135[l3]
                                        if not l10 then
                                            l10 = l4
                                        end
                                        l4 = l10
                                    end
                                    if l4 then
                                        if l4.FishingCF then
                                            anglerStatus("Farming: " .. (l2 .. (" at " .. l3)))
                                            stopAnglerFishing()
                                            pcall(cancelFishing)
                                            task.wait(0.3)
                                            l5 = LocalPlayer.Character
                                            l6 = l5
                                            if l6 then
                                                l6 = l5:FindFirstChildOfClass("Humanoid")
                                            end
                                            if l6 then
                                                l6:UnequipTools()
                                            end
                                            task.wait(0.2)
                                            teleportTo(l4.FishingCF)
                                            task.wait(0.5)
                                            equipRodForAngler()
                                            task.wait(0.3)
                                            startAnglerFastFishing()
                                        end
                                    end
                                    l5 = 0
                                    while true do
                                        if not v134.Enabled then
                                            break
                                        end
                                        if hasFish(l2) then
                                            break
                                        end
                                        task.wait(1)
                                        l5 = l5 + 1
                                        if (l5 % 10) == 0 then
                                            anglerStatus("Hunting " .. (l2 .. ("... (" .. (l5 .. "s)"))))
                                        end
                                    end
                                    if not v134.Enabled then
                                        break
                                    end
                                    stopAnglerFishing()
                                    pcall(cancelFishing)
                                    task.wait(0.5)
                                    l6 = LocalPlayer.Character
                                    l7 = l6
                                    if l7 then
                                        l7 = l6:FindFirstChildOfClass("Humanoid")
                                    end
                                    l8 = l6
                                    if l8 then
                                        l8 = l6:FindFirstChild("HumanoidRootPart")
                                    end
                                    if l8 then
                                        if l7 then
                                            l7:UnequipTools()
                                        end
                                        task.wait(0.3)
                                        anglerStatus("Got " .. (l2 .. "! Equipping..."))
                                        equipFish(l2)
                                        anglerStatus("Returning to Angler...")
                                        teleportTo(l4.CF * CFrame.new(0, v134.YDistance, 0))
                                        anglerStatus("Submitting quest...")
                                        l9 = getAnglerPP(l4.NpcName)
                                        if l9 then
                                            mengfireproximityprompt(l9)
                                        end
                                        task.wait(1)
                                        clickDialogOption("1option")
                                        task.wait(1.5)
                                        equipRodForAngler()
                                        anglerStatus("Quest submitted! Looping...")
                                        task.wait(1)
                                    else
                                        task.wait(1)
                                    end
                                end
                            end
                        end
                    else
                        anglerStatus("ProximityPrompt not found! Retry...")
                        task.wait(2)
                    end
                else
                    task.wait(1)
                end
            else
                anglerStatus("Angler not found!")
                task.wait(2)
            end
        else
            if l1.fish then
                if l1.key then
                    l2 = l1.fish
                    l3 = l1.key
                    l4 = v135[l3]
                    anglerStatus("Quest aktif: " .. (l2 .. (" (" .. (l3 .. ")"))))
                end
            end
        end
    end
    anglerCleanup()
    anglerStatus("Waiting..")
end
AnglerSection = v43.Auto:AddSection("Angler")
anglerLabel = AnglerSection:AddParagraph({ Title = "Status", Content = "Waiting.." })
AnglerSection:AddDropdown({
    Title = "Select Angler",
    Options = {
        "Moosewood Village",
        "Roslit Hamlet",
        "Sunstone Island",
        "Terrapin Island",
        "The Depths",
        "Ancient Isle",
        "Forsaken Shores",
        "Crimson Cavern",
        "Luminescent Cavern",
        "Scoria Reach"
    },
    Default = "Moosewood Village",
    Callback = function(p1)
        v134.AnglerKey = p1
    end
})
AnglerSection:AddSlider({
    Title = "Y Distance",
    Min = -50,
    Max = 10,
    Increment = 0.1,
    Default = 0,
    Callback = function(p1)
        v134.YDistance = p1
    end
})
AnglerSection:AddToggle({
    Title = "With Snap Reel",
    Default = false,
    Callback = function(p1)
        v134.WithSnapReel = p1
        if not p1 then
            restoreSnapReel()
        else
            if v137.IsFishing then
                applySnapReel()
            end
        end
    end
})
AnglerSection:AddToggle({
    Title = "Auto Angler Quest",
    Default = false,
    Callback = function(p1)
        v134.Enabled = p1
        if not p1 then
            stopAnglerFishing()
            anglerStatus("Stopping... (finishing current cast)")
            return
        else
            task.spawn(anglerLoop)
            return
        end
    end
})
SelectedCrate = "Common Crate"
AmountToOpen = 1
AutoOpenEnabled = false
v138 = nil
getPrompt = function()
local l1
    if not v138 then
        l1 = PlayerGui:FindFirstChild("over")
        if l1 then
            v138 = l1:FindFirstChild("prompt")
            return v138
        else
            return nil
        end
    else
        if v138.Parent then
            return v138
        end
    end
end
waitUntil = function(p1, p2)
local l3, l4, l5
    l3 = tick()
    if p1() then
        return true
    else
        while true do
            l4 = tick() - l3
            l5 = p2
            if not l5 then
                l5 = 1
            end
            if l5 < l4 then
                task.wait()
                if p1() then
                    break
                end
            else
                return false
            end
        end
    end
end
OpenBaitSection = v43.Auto:AddSection("Open Bait")
OpenBaitSection:AddDropdown({
    Title = "Select Crate To Open",
    Options = {
        "Common Crate",
        "Tropical Bait Crate",
        "Carbon Crate",
        "Bait Crate",
        "Quality Bait Crate",
        "Coral Geode",
        "Volcanic Geode",
        "Festival Bait Crate"
    },
    Default = "Common Crate",
    Callback = function(p1)
        SelectedCrate = p1
    end
})
OpenBaitSection:AddInput({
    Title = "Input Ammount Create",
    Placeholder = "Write ur input here (max 1000)",
    Callback = function(p1)
    local l2, l3
        l2 = math.min
        l3 = tonumber(p1)
        if not l3 then
            l3 = 1
        end
        AmountToOpen = l2(l3, 1000)
    end
})
OpenBaitToggle = OpenBaitSection:AddToggle({
    Title = "Enable Open Bait",
    Default = false,
    Callback = function(p1)
        AutoOpenEnabled = p1
        task.spawn(function()
        local _R_487 = {}
        local _U_487 = {}
        local u1, u2, u3, u4, u5, u6, u7, u8, u9, u11, u12
            u1 = game:GetService("VirtualInputManager")
            u2 = game:GetService("GuiService")
            u3 = AutoOpenEnabled
            if u3 then
                while true do
                    u3 = LocalPlayer.Character
                    if u3 then
                        u4 = u3:FindFirstChildOfClass("Humanoid")
                        u5 = u3:FindFirstChild("HumanoidRootPart")
                        u6 = LocalPlayer:FindFirstChild("Backpack")
                        u7 = u6
                        if u7 then
                            u9 = SelectedCrate
                            u7 = u6:FindFirstChild(u9)
                        end
                        if not u7 then
                            u7 = u3
                            if u7 then
                                u9 = SelectedCrate
                                u7 = u3:FindFirstChild(u9)
                            end
                        end
                        if u7 then
                            u8 = u3:FindFirstChild(SelectedCrate)
                            if not u8 then
                                if u4 then
                                    u4:EquipTool(u7)
                                end
                                _U_487["385_0"] = u3
                                waitUntil(function()
                                    return _U_487["385_0"]:FindFirstChild(SelectedCrate) ~= nil
                                end, 1)
                                u9 = u3:FindFirstChild(SelectedCrate)
                                u8 = u9
                            end
                            if u8 then
                                u8:Activate()
                            end
                            u9 = nil
                            if waitUntil(function()
                            local w1
                                u9 = getPrompt()
                                w1 = u9
                                if w1 then
                                    w1 = u9.Visible
                                end
                                return w1
                            end, 1) then
                                if u9 then
                                    u11 = u9:FindFirstChild("amount")
                                    if u11 then
                                        if u11:IsA("TextBox") then
                                            u11.Text = tostring(AmountToOpen)
                                            u11:ReleaseFocus(true)
                                        end
                                    end
                                    u12 = u9:FindFirstChild("confirm")
                                    if u12 then
                                        u2.SelectedObject = u12
                                        u1:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                        u1:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                    end
                                    waitUntil(function()
                                        return not u9.Visible
                                    end, 1)
                                end
                            end
                            u3 = AutoOpenEnabled
                            if not u3 then
                                break
                            end
                        else
                            warn("Crate habis: " .. SelectedCrate)
                            AutoOpenEnabled = false
                            OpenBaitToggle:Set(false)
                            if u5 then
                                u5.Anchored = false
                            end
                            break
                        end
                    else
                        task.wait(0.3)
                        u3 = AutoOpenEnabled
                        if not u3 then
                            break
                        end
                    end
                end
            end
        end)
    end
})
v139 = false
v140 = {}
v149 = {
    -1347.87,
    126.43,
    -945.27
}
_R["150_v1"] = {}
_R["151_v1"] = -1177.34
v152 = 126.43
_R["150_v1"][1] = _R["151_v1"]
_R["150_v1"][2] = v152
_R["150_v1"][3] = -1605.49
SPAWN_LOCATIONS = {
    Moosewood = {
        {
            290.29,
            126.43,
            557.53
        },
        {
            290.29,
            126.43,
            -166.46
        },
        {
            864.11,
            126.43,
            246.67
        },
        {
            107.76,
            126.43,
            -58.89
        },
        {
            618.5,
            126.43,
            491.74
        },
        {
            943.13,
            126.43,
            -166.46
        },
        {
            698.04,
            126.43,
            -369.59
        }
    },
    ["Forsaken Shores"] = {
        {
            -2452.66,
            126.43,
            2039.97
        }
    },
    ["Mushgrove Swamp"] = {
        {
            2897.56,
            126.43,
            -1002.77
        },
        {
            2312.53,
            126.43,
            -982.02
        },
        {
            2597.56,
            126.43,
            -1105.67
        },
        {
            2274.03,
            126.43,
            -726.41
        },
        {
            2423.26,
            126.43,
            -1105.67
        },
        {
            2340.93,
            126.43,
            -530.36
        },
        {
            2735.56,
            126.43,
            -1105.67
        }
    },
    ["Roslit Bay"] = {
        {
            -1172.32,
            126.43,
            557.53
        },
        {
            -1463.88,
            126.43,
            -43.8
        },
        {
            -1210.97,
            126.43,
            192.5
        },
        {
            -1936.32,
            126.43,
            -43.8
        },
        {
            -1960.34,
            126.43,
            882.74
        }
    },
    ["Sunstone Island"] = {
        {
            -1160.73,
            126.43,
            -908.68
        },
        {
            -1081.77,
            126.43,
            -1410.6
        },
        {
            -673.1,
            126.43,
            -1477.34
        },
        {
            -844.32,
            126.43,
            -1566.86
        },
        {
            -1388.49,
            126.43,
            -1722.59
        },
        {
            -1362.63,
            126.43,
            -1126.56
        },
        v149,
        _R["150_v1"]
    },
    ["Terrapin Island"] = {
        {
            495.79,
            126.43,
            1904.47
        },
        {
            5.38,
            126.43,
            1626.4
        },
        {
            307.58,
            126.43,
            1626.4
        }
    }
}
v141 = {}
for _k, _v in pairs(SPAWN_LOCATIONS) do
    _R["143_v1"], _R["144_v1"] = _k, _v
    for _k, _v in ipairs(_R["144_v1"]) do
        v146, v147 = _k, _v
        v149 = v141
        _R["150_v1"] = { name = _R["143_v1"], coord = v147 }
        table.insert(v149, _R["150_v1"])
    end
end
formatTime = function(p1)
    return string.format("%dD %02dH %02dM", math.floor(p1 / 86400), math.floor((p1 % 86400) / 3600), math.floor((p1 % 3600) / 60))
end
getNextSunkenDrop = function(p1)
local l2, l3, l4, l5, l6
    l2 = p1 / 60
    l3 = 0
    l4 = nil
    while true do
        l4 = 60 + (70 * l3)
        l3 = l3 + 1
        if l2 >= l4 then
            break
        end
    end
    l5 = l4 * 60
    l6 = math.floor(l5 - p1)
    return formatTime(l5), formatTime(l6), l6
end
getChestsFolder = function()
local l1
    l1 = workspace:FindFirstChild("world")
    if l1 then
        l1 = workspace.world:FindFirstChild("ActiveChestsFolder")
    end
    if l1 then
        l1 = workspace.world.ActiveChestsFolder:FindFirstChild("Pad")
    end
    if l1 then
        l1 = workspace.world.ActiveChestsFolder.Pad:FindFirstChild("Chests")
    end
    return l1
end
findPrompt = function(p1)
local l2, l3, l4, l5, l6
    l2 = p1:FindFirstChild("RootPart")
    if not l2 then
        l3 = p1:FindFirstChild("Chest")
        if not l3 then
            for _k1, _v1 in ipairs(p1:GetDescendants()) do
                l5, l6 = _k1, _v1
                if l6:IsA("ProximityPrompt") then
                    return l6
                end
            end
            return nil
        else
            if l3:FindFirstChild("Main") then
                l4 = l3.Main:FindFirstChild("Prompt")
                if l4 then
                    return l4
                end
            end
        end
    else
        if l2:FindFirstChild("Main") then
            l3 = l2.Main:FindFirstChild("Prompt")
            if l3 then
                return l3
            end
        end
    end
end
runSunkenClaim = function()
local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13
    if not v139 then
        v139 = true
        l1 = LocalPlayer.Character
        l2 = l1
        if l2 then
            l2 = l1:FindFirstChild("HumanoidRootPart")
        end
        l3 = l1
        if l3 then
            l3 = l1:FindFirstChild("Humanoid")
        end
        if l2 then
            l4 = l2.CFrame
            l5 = pauseAndWaitFishing()
            if l3 then
                l3:UnequipTools()
            end
            task.wait(0.2)
            l6 = getChestsFolder()
            l7 = l6
            if l7 then
                l7 = l6:GetChildren()
            end
            if not l7 then
                l7 = {}
            end
            l8 = {}
            for _k1, _v1 in ipairs(l7) do
                l10, l11 = _k1, _v1
                if not v140[l11] then
                    table.insert(l8, l11)
                end
            end
            for _k1, _v1 in ipairs(l8) do
                l10, l11 = _k1, _v1
                if not _G.AutoTeleportSunken then
                    break
                end
                l12 = l11:FindFirstChild("RootPart")
                if not l12 then
                    l12 = l11:FindFirstChild("Chest")
                end
                if not l12 then
                    l12 = l11.PrimaryPart
                end
                if l12 then
                    l2.CFrame = CFrame.new(l12.Position + Vector3.new(0, 3, 0))
                    task.wait(0.3)
                end
                l13 = findPrompt(l11)
                if not l13 then
                    task.wait(0.1)
                else
                    fireproximityprompt(l13)
                    v140[l11] = true
                    task.wait(0.5)
                end
            end
            for _k1, _v1 in pairs(v140) do
                l10, l11 = _k1, _v1
                if not l10.Parent then
                    v140[l10] = nil
                end
            end
            task.wait(0.1)
            l2.CFrame = l4
            if typeof(reEquipRod) == "function" then
                reEquipRod()
            end
            l5()
            v139 = false
            return
        else
            v139 = false
            return
        end
    end
end
_R["142_v1"] = 1
task.spawn(function()
local _R_134 = {}
local _U_134 = {}
local l1
    while true do
        task.wait(0.2)
        l1 = _G.AutoTeleportSunken
        if not l1 then
            l1 = task.wait
            l1(1)
        else
            l1 = v139
            if not l1 then
                l1 = v141[_R["142_v1"]]
                if l1 then
                    _U_134["291_0"] = l1
                    task.spawn(function()
                    local u1
                        u1 = Vector3.new(_U_134["291_0"].coord[1], _U_134["291_0"].coord[2], _U_134["291_0"].coord[3])
                        pcall(function()
                            LocalPlayer:RequestStreamAroundAsync(u1, 100)
                        end)
                    end)
                end
                _R["142_v1"] = _R["142_v1"] + 1
                if (#v141) >= _R["142_v1"] then
                    _R["142_v1"] = 1
                end
            end
        end
    end
end)
task.spawn(function()
local l1, l2, l3, l4, l5
    while true do
        task.wait(0.3)
        if _G.AutoTeleportSunken then
            if not v139 then
                l1 = getChestsFolder()
                if l1 then
                    l2 = false
                    for _k1, _v1 in ipairs(l1:GetChildren()) do
                        l4, l5 = _k1, _v1
                        if not v140[l5] then
                            l2 = true
                            break
                        end
                    end
                    if l2 then
                        runSunkenClaim()
                    end
                end
            end
        end
    end
end)
AutoClaimSection = v43.Auto:AddSection("Auto Claim Features")
AutoClaimSection:AddSubSection("Sunken Chests")
SunkenParagraph = AutoClaimSection:AddParagraph({ Title = "Server Uptime Status", Content = "Loading..." })
AutoClaimSection:AddToggle({
    Title = "Auto Sunken Chests",
    Default = false,
    Callback = function(p1)
    local l2
        l2 = _G
        l2.AutoTeleportSunken = p1
    end
})
AutoClaimSection:AddButton({
    Title = "Teleport to Sunken Chests",
    Callback = function()
        task.spawn(function()
        local _R_484 = {}
        local _U_484 = {}
        local u1, u2, u3, u4, u5, u6, u7, u8, u9
            u1 = LocalPlayer.Character
            u2 = u1
            if u2 then
                u2 = u1:FindFirstChild("HumanoidRootPart")
            end
            if u2 then
                for _k2, _v2 in ipairs(v141) do
                    u4, u5 = _k2, _v2
                    u6 = Vector3.new(u5.coord[1], u5.coord[2], u5.coord[3])
                    _U_484["389_1"] = u6
                    pcall(function()
                        LocalPlayer:RequestStreamAroundAsync(_U_484["389_1"], 100)
                    end)
                    task.wait(0.1)
                end
                task.wait(0.5)
                u3 = getChestsFolder()
                u4 = u3
                if u4 then
                    u4 = u3:GetChildren()
                end
                if not u4 then
                    u4 = {}
                end
                u5 = false
                for _k2, _v2 in ipairs(u4) do
                    u7, u8 = _k2, _v2
                    u9 = u8:FindFirstChild("RootPart")
                    if not u9 then
                        u9 = u8:FindFirstChild("Chest")
                    end
                    if not u9 then
                        u9 = u8.PrimaryPart
                    end
                    if u9 then
                        u2.CFrame = CFrame.new(u9.Position + Vector3.new(0, 3, 0))
                        u5 = true
                        break
                    end
                end
                if not u5 then
                    u6 = notif
                    u6("No sunken chests found!")
                end
                return
            end
        end)
    end
})
task.spawn(function()
local l1, l2, l3, l4, l5
    l1 = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("serverInfo"):WaitForChild("serverInfo"):WaitForChild("uptime")
    parseUptimeText = function(a1)
    local u2, u3, u4, u5
        u2 = tonumber(a1:match("(%d+)D"))
        if not u2 then
            u2 = 0
        end
        u3 = tonumber(a1:match("(%d+)H"))
        if not u3 then
            u3 = 0
        end
        u4 = tonumber(a1:match("(%d+)M"))
        if not u4 then
            u4 = 0
        end
        u5 = tonumber(a1:match("(%d+)S"))
        if not u5 then
            u5 = 0
        end
        return (((u2 * 86400) + (u3 * 3600)) + (u4 * 60)) + u5
    end
    l2, l3 = pcall(function()
    local u1, u2, u3, u4, u5, u7, u8
        u1 = parseUptimeText(l1.Text)
        u2 = formatTime(u1)
        u3, u4, u5 = getNextSunkenDrop(u1)
        u7(u8, string.format("Uptime: %s | Next Drop: %s (In: %dM)", u2, u3, math.floor(u5 / 60)))
    end)
    if l2 then
        while true do
            task.wait(0.5)
            l2, l3 = pcall(function()
            local u1, u2, u3, u4, u5, u7, u8
                u1 = parseUptimeText(l1.Text)
                u2 = formatTime(u1)
                u3, u4, u5 = getNextSunkenDrop(u1)
                u7(u8, string.format("Uptime: %s | Next Drop: %s (In: %dM)", u2, u3, math.floor(u5 / 60)))
            end)
            if not l2 then
                break
            end
        end
    end
    l4(l5, "Error: " .. tostring(l3))
end)
AutoClaimSection:AddSubSection("Treasure Map")
AutoClaimSection:AddButton({
    Title = "Repair All Map",
    Callback = function()
    local l1, l2, l3, l4, l5, l6, l7, l8, l9
        l1 = game:GetService("ReplicatedStorage").packages.Net["RF/DialogInteract"]
        l2 = LocalPlayer.Character
        if l2 then
            l2 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        l3 = LocalPlayer:FindFirstChild("Backpack")
        if l2 then
            l4 = 0
            for _k1, _v1 in pairs(l3:GetChildren()) do
                l6, l7 = _k1, _v1
                if l7.Name == "Treasure Map" then
                    l4 = l4 + 1
                end
            end
            if l4 < 2 then
                l5 = l2.CFrame
                l2.CFrame = CFrame.new(-2826, 214.58, 1518) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))
                task.wait(0.5)
                l6 = workspace.world.npcs:WaitForChild("Jack Marrow", 5)
                if l6 then
                    if not l6:FindFirstChildWhichIsA("ProximityPrompt", true) then
                        warn("ProximityPrompt not found in Jack Marrow!")
                        if not l1 then
                            warn("Remote tidak ditemukan!")
                        else
                            l8, l9 = pcall(function()
                                l1:InvokeServer(1, 2)
                            end)
                            if not l8 then
                                warn("Gagal invoke dialog: " .. l9)
                            end
                        end
                    else
                        mengfireproximityprompt(l6.ProximityPrompt)
                        task.wait(1.5)
                    end
                    l2.CFrame = l5
                    return
                else
                    warn("Jack Marrow NPC not found!")
                    return
                end
            else
                notif("You need at least 2 treasure maps to repair!")
                return
            end
        end
    end
})
AutoClaimSection:AddButton({
    Title = "Auto Claim All Chest",
    Callback = function()
        task.spawn(function()
        local u1, u2, u3, u4, u5, u6, u7, u8, u9, u10
            u1 = workspace:FindFirstChild("world")
            if u1 then
                u1 = workspace.world:FindFirstChild("chests")
            end
            if not u1 then
                return notif("No chests found!")
            else
                if (#u1:GetChildren()) ~= 0 then
                    u2 = LocalPlayer.Character
                    u3 = u2
                    if u3 then
                        u3 = u2:FindFirstChild("HumanoidRootPart")
                    end
                    if u3 then
                        u4 = u3.CFrame
                        u5 = {}
                        for _k2, _v2 in ipairs(u1:GetChildren()) do
                            u7, u8 = _k2, _v2
                            u9 = u8:FindFirstChildWhichIsA("ProximityPrompt", true)
                            u10 = u8:IsA("BasePart")
                            if u10 then
                                u10 = u8
                            end
                            if not u10 then
                                u10 = u8:FindFirstChildWhichIsA("BasePart", true)
                            end
                            if u9 then
                                if u10 then
                                    u9.MaxActivationDistance = 9999
                                    u9.HoldDuration = 0
                                    table.insert(u5, { prompt = u9, part = u10 })
                                end
                            end
                        end
                        for _k2, _v2 in ipairs(u5) do
                            u7, u8 = _k2, _v2
                            if u8.prompt then
                                if u8.prompt.Parent then
                                    if u8.part then
                                        if u8.part.Parent then
                                            u3.CFrame = u8.part.CFrame + Vector3.new(0, 3, 0)
                                            task.wait(0.3)
                                            fireproximityprompt(u8.prompt)
                                            task.wait(0.5)
                                        end
                                    end
                                end
                            end
                        end
                        u3.CFrame = u4
                        notif("All chests claimed!")
                        return
                    end
                end
            end
        end)
    end
})
AutoClaimSection:AddButton({
    Title = "Teleport to Jack Marrow",
    Callback = function()
    local l1, l2, l3
        l1 = LocalPlayer.Character
        if not l1 then
            l1 = LocalPlayer.CharacterAdded:Wait()
        end
        l2 = l1:FindFirstChild("HumanoidRootPart")
        l3 = l1:FindFirstChildOfClass("Humanoid")
        if l2 then
            if l3 then
                l2.Anchored = true
                l2.CFrame = CFrame.new(-2826, 214.58, 1518) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))
                task.delay(1, function()
                    if l2 then
                        l2.Anchored = false
                    end
                end)
            end
        end
    end
})
_R["143_v1"] = false
_R["144_v1"] = nil
AutoClaimSection:AddSubSection("Starfall")
v149 = AutoClaimSection:AddParagraph({ Title = "☄️ Starfall Status", Content = "Scanning for Craters..." })
findStarCraters = function()
local l1, l2, l3, l4
    l1 = {}
    for _k1, _v1 in pairs(workspace:GetChildren()) do
        l3, l4 = _k1, _v1
        if l4.Name == "StarCrater" then
            if l4:IsA("Model") then
                table.insert(l1, l4)
            end
        end
    end
    return l1
end
collectCrater = function(p1)
local l2, l3, l4, l5, l6
    l2 = LocalPlayer.Character
    l3 = l2
    if l3 then
        l3 = l2:FindFirstChild("HumanoidRootPart")
    end
    if l3 then
        l4 = p1:FindFirstChildWhichIsA("ProximityPrompt", true)
        if l4 then
            l5 = l4.Parent:IsA("BasePart")
            if l5 then
                l5 = l4.Parent.CFrame
            end
            if not l5 then
                l5 = p1:GetPivot()
            end
            l5 = l5 * CFrame.new(0, 2.5, 0)
            l6 = 0
            l4.HoldDuration = 0
            l4.RequiresLineOfSight = false
            if p1.Parent then
                while true do
                    if not _R["143_v1"] then
                        break
                    end
                    if l6 < 25 then
                        break
                    end
                    l3.Velocity = Vector3.zero
                    l3.CFrame = l5
                    mengfireproximityprompt(l4)
                    task.wait()
                    l6 = l6 + 1
                    if not p1.Parent then
                        break
                    end
                end
            end
            return
        end
    end
end
_U["320_0"] = v149
task.spawn(function()
local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10
    while true do
        l1 = findStarCraters()
        if 0 >= (#l1) then
            _U["320_0"]:SetContent("Status: 🌌 Clear (No Craters)")
            task.wait(1)
        else
            l2 = {}
            for _k1, _v1 in pairs(l1) do
                l4, l5 = _k1, _v1
                for _k1, _v1 in pairs(l5:GetChildren()) do
                    l7, l8 = _k1, _v1
                    if l8:IsA("Model") then
                        if l8.Name ~= "Cracks" then
                            l9 = l8.Name
                            l10 = l2[l8.Name]
                            if not l10 then
                                l10 = 0
                            end
                            l2[l9] = l10 + 1
                        end
                    end
                end
            end
            l4 = "Found: " .. ((#l1) .. (" Craters\n" .. (string.rep("━", 15) .. "\n")))
            for _k1, _v1 in pairs(l2) do
                l6, l7 = _k1, _v1
                l4 = l4 .. ("✨" .. (" " .. (l6 .. (" : " .. (l7 .. "x\n")))))
            end
            _U["320_0"]:SetContent(l4)
            task.wait(1)
        end
    end
end)
StarCraterToggle = AutoClaimSection:AddToggle({
    Title = "Auto Collect Star Crater",
    Default = false,
    Callback = function(p1)
    local _U_380 = {}
    local l2, l3
        _R["143_v1"] = p1
        if p1 then
            l2 = LocalPlayer.Character
            l3 = l2
            if l3 then
                l3 = l2:FindFirstChild("HumanoidRootPart")
            end
            if l3 then
                _R["144_v1"] = l3.CFrame
            end
            _U_380["296_2"] = l3
            task.spawn(function()
            local u1, u2, u3, u4
                while true do
                    if not _R["143_v1"] then
                        return
                    else
                        u1 = findStarCraters()
                        if (#u1) == 0 then
                            break
                        end
                        for _k2, _v2 in pairs(u1) do
                            u3, u4 = _k2, _v2
                            if not _R["143_v1"] then
                                break
                            end
                            if u4.Parent then
                                collectCrater(u4)
                            end
                            task.wait(0.02)
                        end
                        task.wait(0.3)
                    end
                end
                if _R["144_v1"] then
                    if _U_380["296_2"] then
                        _U_380["296_2"].CFrame = _R["144_v1"]
                    end
                end
                pcall(function()
                    notif("All StarCraters Collected!")
                end)
                StarCraterToggle:Set(false)
            end)
            return
        end
    end
})
CosmicToggle = AutoClaimSection:AddToggle({
    Title = "Auto Collect Cosmic Relic",
    Default = false,
    Callback = function(p1)
    local _U_176 = {}
    local l2, l3
        if p1 then
            l2 = LocalPlayer.Character
            l3 = l2
            if l3 then
                l3 = l2:FindFirstChild("HumanoidRootPart")
            end
            if l3 then
                _R["144_v1"] = l3.CFrame
            end
            _U_176["431_0"] = l3
            task.spawn(function()
            local u2, u3, u4, u5, u6, u7, u8, u9, u10, u11
                while true do
                    if not CosmicToggle.Value then
                        break
                    end
                    u2 = false
                    for _k2, _v2 in pairs(findStarCraters()) do
                        u4, u5 = _k2, _v2
                        if not CosmicToggle.Value then
                            break
                        end
                        for _k2, _v2 in pairs(u5:GetChildren()) do
                            u7, u8 = _k2, _v2
                            if u8:IsA("Model") then
                                if u8.Name == "Cosmic Relic" then
                                    u2 = true
                                    u9 = u8:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if u9 then
                                        u10 = u9.Parent:IsA("BasePart")
                                        if u10 then
                                            u10 = u9.Parent.CFrame
                                        end
                                        if not u10 then
                                            u10 = u8:GetPivot()
                                        end
                                        u10 = u10 * CFrame.new(0, 2.5, 0)
                                        u9.HoldDuration = 0
                                        u9.RequiresLineOfSight = false
                                        u11 = 0
                                        if u8.Parent then
                                            while true do
                                                if not CosmicToggle.Value then
                                                    break
                                                end
                                                if u11 < 25 then
                                                    break
                                                end
                                                _U_176["431_0"].Velocity = Vector3.zero
                                                _U_176["431_0"].CFrame = u10
                                                mengfireproximityprompt(u9)
                                                task.wait()
                                                u11 = u11 + 1
                                                if not u8.Parent then
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if u2 then
                        task.wait(0.3)
                    else
                        if _R["144_v1"] then
                            if _U_176["431_0"] then
                                _U_176["431_0"].CFrame = _R["144_v1"]
                            end
                        end
                        pcall(function()
                            notif("All Cosmic Relics Collected!")
                        end)
                        CosmicToggle:Set(false)
                        break
                    end
                end
            end)
            return
        end
    end
})
_R["150_v1"] = {}
_R["151_v1"] = nil
AutoClaimSection:AddSubSection("Flower (Living Garden)")
FlowerToggle = AutoClaimSection:AddToggle({
    Title = "Auto Collect Flower",
    Default = false,
    Callback = function(p1)
        AutoCollectFlower = p1
        task.spawn(function()
        local u1, u2, u4, u5, u6, u7, u8, u9, u10
            while true do
                if not AutoCollectFlower then
                    break
                end
                u1 = LocalPlayer.Character
                u2 = u1
                if u2 then
                    u2 = u1:FindFirstChild("HumanoidRootPart")
                end
                if u2 then
                    u4 = {}
                    for _k2, _v2 in pairs(workspace.LivingGarden.FlowersSpawners:GetChildren()) do
                        u6, u7 = _k2, _v2
                        if u7.Name:match("LivingGardenFlower_") then
                            table.insert(u4, u7)
                        end
                    end
                    u5 = true
                    for _k2, _v2 in pairs(u4) do
                        u7, u8 = _k2, _v2
                        if not _R["150_v1"][u8.Name] then
                            u5 = false
                            break
                        end
                    end
                    if not u5 then
                        u6 = u2.CFrame
                        for _k2, _v2 in pairs(u4) do
                            u8, u9 = _k2, _v2
                            if not AutoCollectFlower then
                                break
                            end
                            if not _R["150_v1"][u9.Name] then
                                u10 = u9:FindFirstChild("RootPart")
                                if u10 then
                                    u10 = u9.RootPart:FindFirstChild("ProximityPrompt")
                                end
                                if u10 then
                                    u2.CFrame = u9.RootPart.CFrame * CFrame.new(0, 3, 0)
                                    task.wait(0.15)
                                    if AutoCollectFlower then
                                        mengfireproximityprompt(u10)
                                        _R["150_v1"][u9.Name] = true
                                        task.wait(0.2)
                                    end
                                end
                            end
                        end
                        if u2 then
                            u2.CFrame = u6
                        end
                        if _R["151_v1"] then
                            task.cancel(_R["151_v1"])
                        end
                        _R["151_v1"] = task.delay(math.random(180, 300), function()
                            _R["150_v1"] = {}
                            _R["151_v1"] = nil
                        end)
                        task.wait(1)
                    else
                        AutoCollectFlower = false
                        FlowerToggle:Set(false)
                        break
                    end
                else
                    task.wait(1)
                end
            end
        end)
    end
})
AutoClaimSection:AddSubSection("Auto Claim Shell")
AutoConvertShellToggle = AutoClaimSection:AddToggle({
    Title = "Auto Convert Shell (Sync Mode)",
    Default = false,
    Callback = function(p1)
    local _U_218 = {}
    local l2, l3, l4
        l2 = _G
        l2.AutoConvertShellActive = p1
        if p1 then
            l2 = game.Players.LocalPlayer
            l3 = game:GetService("ReplicatedStorage").packages.Net["RE/MermaidCove/AltarClaim"]
            l4 = CFrame.new(-3826.95, -1284.29, 499.28) * CFrame.Angles(0, math.rad(-77.83), 0)
            _U_218["347_0"] = l2
            task.spawn(function()
            local u1, u2, u3, u4, u5, u6, u7, u8
                while true do
                    if not _G.AutoConvertShellActive then
                        break
                    end
                    u1 = _U_218["347_0"].Character
                    u2 = _U_218["347_0"]:FindFirstChild("Backpack")
                    u3 = u2
                    if u3 then
                        u3 = u2:FindFirstChild("Shell")
                    end
                    if not u3 then
                        u3 = u1
                        if u3 then
                            u3 = u1:FindFirstChild("Shell")
                        end
                    end
                    if u3 then
                        if u1 then
                            if u1:FindFirstChild("HumanoidRootPart") then
                                if 5 < ((u1.HumanoidRootPart.Position - l4.Position)).Magnitude then
                                    u4 = u1.HumanoidRootPart
                                    u4.CFrame = l4
                                    task.wait(0.2)
                                end
                                if u3.Parent ~= u1 then
                                    u3.Parent = u1
                                    task.wait(0.1)
                                end
                                while true do
                                    if not u1:FindFirstChild("Shell") then
                                        break
                                    end
                                    if not _G.AutoConvertShellActive then
                                        break
                                    end
                                    u4 = workspace.world.map["Mermaid Cove"].Podium.ShellPodium.ShellAltar:FindFirstChildOfClass("ProximityPrompt")
                                    if u4 then
                                        fireproximityprompt(u4)
                                    end
                                    u5 = 1
                                    u6 = 5
                                    u7 = 1
                                    for _i2 = u5, u6, u7 do
                                        u8 = _i2
                                        l3:FireServer()
                                    end
                                    task.wait()
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
            return
        end
    end
})
ShellParagraph = AutoClaimSection:AddParagraph({ Title = "Status", Content = "Waiting..." })
AutoClaimShellToggle = AutoClaimSection:AddToggle({
    Title = "Enable Auto Claim Shell",
    Default = false,
    Callback = function(p1)
    local _U_321 = {}
    local l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19, l20, l21
    local l22, l23, l24, l25, l26, l27, l28, l29, l30, l31, l32, l33, l34, l35, l36, l37, l38, l39, l40, l41
    local l42, l43, l44, l45, l46, l47, l48, l49, l50, l51, l52, l53, l54, l55, l56, l57, l58, l59, l60, l61
    local l62, l63, l64
        l2 = _G
        l2.AutoClaimShellActive = p1
        if p1 then
            l2 = game.Players.LocalPlayer
            l3 = l2.Character
            if not l3 then
                l3 = l2.CharacterAdded:Wait()
            end
            l4 = l3:WaitForChild("HumanoidRootPart")
            l5 = l4.CFrame
            l6 = {}
            l7 = CFrame.new(5653.43115, 131.743729, 825.979431, 0.37218821, 0, -0.928157449, 0, 1, 0, 0.928157449, 0, 0.37218821)
            l8 = CFrame.new(5861.35889, 133.931259, 155.618607, 0.65720737, 0, -0.753709853, 0, 1, 0, 0.753709853, 0, 0.65720737)
            l9 = CFrame.new(5932.375, 130.721024, -33.7657204, -0.218390107, 0, 0.975861609, 0, 1, 0, -0.975861609, 0, -0.218390107)
            l10 = CFrame.new(5835.56787, 130.931259, 188.20137, 0.940715492, 0, -0.339196682, 0, 1, 0, 0.339196682, 0, 0.940715492)
            l11 = CFrame.new(5579.21729, 129.370377, -228.249268, 0.133758724, 0, 0.991014004, 0, 1, 0, -0.991014004, 0, 0.133758724)
            l12 = CFrame.new(5571.19824, 129.370377, -213.690933, 0.133758724, 0, 0.991014004, 0, 1, 0, -0.991014004, 0, 0.133758724)
            l13 = CFrame.new(5632.38525, 129.370377, -156.998703, 0.133758724, 0, 0.991014004, 0, 1, 0, -0.991014004, 0, 0.133758724)
            l14 = CFrame.new(6385.55322, 132.421265, 558.542847, 0.232250631, 0, 0.972656012, 0, 1, 0, -0.972656012, 0, 0.232250631)
            l15 = CFrame.new(5592.63721, 133.786316, 676.416443, -0.461523771, 0, -0.887127876, 0, 1, 0, 0.887127876, 0, -0.461523771)
            l16 = CFrame.new(5584.71582, 134.714508, 655.272095, 0.351612747, 0, -0.936145604, 0, 1, 0, 0.936145604, 0, 0.351612747)
            l17 = CFrame.new(5589.15674, 131.80896, -67.4562683, -0.556532025, 0, 0.83082664, 0, 1, 0, -0.83082664, 0, -0.556532025)
            l18 = CFrame.new(5863.92236, 130.897903, -47.3043442, 0.279838026, 0, 0.960047305, 0, 1, 0, -0.960047305, 0, 0.279838026)
            l19 = CFrame.new(5523.81738, 135.651001, 579.869019, 0.351612747, 0, -0.936145604, 0, 1, 0, 0.936145604, 0, 0.351612747)
            l20 = CFrame.new(6255.40674, 134.318787, 265.155273, -0.597488284, 0, 0.801877677, 0, 1, 0, -0.801877677, 0, -0.597488284)
            l21 = CFrame.new(5854.99707, 132.897903, -3.32150269, 0.20603776, 0, 0.978543997, 0, 1, 0, -0.978543997, 0, 0.20603776)
            l22 = CFrame.new(5937.87988, 129.814041, 14.1959295, -0.0137473345, 0, 0.999905586, 0, 1, 0, -0.999905586, 0, -0.0137473345)
            l23 = CFrame.new(5812.54883, 139.49707, 306.765442, 0.999218464, 0, -0.0395277552, 0, 1, 0, 0.0395277552, 0, 0.999218464)
            l24 = CFrame.new(5795.66113, 132.719315, 407.276855, -0.0075545311, 0, -0.999971449, 0, 1, 0, 0.999971449, 0, -0.0075545311)
            l25 = CFrame.new(6225.84863, 134.318787, 237.315338, -0.878950596, 0, 0.476912946, 0, 1, 0, -0.476912946, 0, -0.878950596)
            l26 = CFrame.new(5833.38232, 137.813232, 223.572479, 0.940715492, 0, -0.339196682, 0, 1, 0, 0.339196682, 0, 0.940715492)
            l27 = CFrame.new(1777.71484, 129.346313, -2536.96851, 0.998806417, 0, -0.0488436893, 0, 1, 0, 0.0488436893, 0, 0.998806417)
            l28 = CFrame.new(1781.84839, 130.475876, -2519.03052, 0.996225417, 0.0717962235, -0.048787944, -0.07188043, 0.997413278, 2.86934664e-05, 0.0486638024, 0.00347831286, 0.998809159)
            l29 = CFrame.new(1716.38855, 134.59642, -2532.71436, 0.998806417, 0, -0.0488436893, 0, 1, 0, 0.0488436893, 0, 0.998806417)
            l30 = CFrame.new(1733.79822, 120.59642, -2565.83081, 0.987110436, 0, -0.160040721, 0, 1, 0, 0.160040721, 0, 0.987110436)
            l31 = CFrame.new(-2678.51855, 128.884567, 1825.25342, 0.606805265, 0, -0.794850528, 0, 1, 0, 0.794850528, 0, 0.606805265)
            l32 = CFrame.new(-2646.2334, 129.684219, 1395.36243, 0.999647617, 0.00773759373, 0.0253922697, -0.00536827371, 0.995736778, -0.0920841247, -0.0259965267, 0.091915369, 0.99542743)
            l33 = CFrame.new(-3060.94897, 124.426491, 1474.23853, 0.399642348, 0, -0.916671157, 0, 1, 0, 0.916671157, 0, 0.399642348)
            l34 = CFrame.new(-2625.30396, 129.179184, 1379.54114, 0.626767755, 0.0581540652, -0.777033031, -0.0923749059, 0.99572432, 1.00471079e-05, 0.773711264, 0.0717720538, 0.629459858)
            l35 = CFrame.new(-2462.48657, 128.486298, 1579.73193, 0.748012304, 0, 0.663684964, 0, 1, 0, -0.663684964, 0, 0.748012304)
            l36 = CFrame.new(-2463.61523, 131.159698, 1535.6405, 0.79437083, 0.147166133, 0.589336157, -0.0881893188, 0.987869442, -0.127814829, -0.60099721, 0.0495592207, 0.797713161)
            l37 = CFrame.new(-2655.33276, 133.956146, 1814.74414, 0.365496337, 0, -0.930812836, 0, 1, 0, 0.930812836, 0, 0.365496337)
            l38 = CFrame.new(-2708.74951, 131.590851, 1188.47278, 0.82706219, 0, -0.562110543, 0, 1, 0, 0.562110543, 0, 0.82706219)
            l39 = CFrame.new(-3652.59131, 129.045242, 781.045837, -0.371175766, 0.112579159, 0.921712816, 0.143835485, 0.987612963, -0.0627054274, -0.917354882, 0.109300286, -0.382770777)
            l40 = CFrame.new(-3590.72388, 129.223694, 568.815796, 0.0338863134, 0.035477031, 0.998795867, 0.13959083, 0.98940587, -0.0398794264, -0.989629269, 0.140774101, 0.0285750628)
            l41 = CFrame.new(-3405.6106, 130.275848, 251.907486, 0.624854267, 0.0816541538, -0.776459813, 0.0408543721, 0.989733756, 0.13695997, 0.779671788, -0.117301792, 0.615103424)
            l42 = CFrame.new(-3527.28027, 130.120102, 540.549438, 0.989994347, 1.58948824e-05, 0.141107067, 0.0190873407, 0.990793884, -0.134026647, -0.13981016, 0.135378987, 0.980880022)
            l43 = CFrame.new(-3835.33203, 130.266357, 347.964417, -0.535208344, 0.162277058, -0.828986347, 0.167011663, 0.982329965, 0.0844689384, 0.828045428, -0.0932419077, -0.552853346)
            l44 = CFrame.new(-3088.60962, 125.849342, -2227.229, -0.491637945, 0, -0.87079972, 0, 1, 0, 0.87079972, 0, -0.491637945)
            l45 = CFrame.new(-2595.87109, 125.849342, -1883.86816, -0.706340909, 0, -0.707871795, 0, 1, 0, 0.707871795, 0, -0.706340909)
            l46 = CFrame.new(-2468.95557, 128.987076, -1977.5321, 0.417386472, 0, -0.908729076, 0, 1, 0, 0.908729076, 0, 0.417386472)
            l47 = CFrame.new(-2459.51465, 125.849342, -2275.23511, -0.706340909, 0, -0.707871795, 0, 1, 0, 0.707871795, 0, -0.706340909)
            l48 = CFrame.new(-2379.60034, 128.987076, -2042.70166, 0.864887714, 0, -0.501965404, 0, 1, 0, 0.501965404, 0, 0.864887714)
            l49 = CFrame.new(-2405.10742, 128.987076, -2020.60974, 0.417386472, 0, -0.908729076, 0, 1, 0, 0.908729076, 0, 0.417386472)
            l50 = CFrame.new(-2413.08179, 128.987076, -2003.62451, 0.705480337, 0, -0.708729565, 0, 1, 0, 0.708729565, 0, 0.705480337)
            l51 = CFrame.new(-3055.20044, 125.849342, -2254.875, -0.491637945, 0, -0.87079972, 0, 1, 0, 0.87079972, 0, -0.491637945)
            l52 = CFrame.new(-2325.97144, 128.987076, -2102.09546, -0.551149845, 0, -0.834406257, 0, 1, 0, 0.834406257, 0, -0.551149845)
            l53 = CFrame.new(-2667.62476, 125.849342, -1822.4635, -0.706340909, 0, -0.707871795, 0, 1, 0, 0.707871795, 0, -0.706340909)
            l54 = CFrame.new(-2444.47974, 128.987076, -1993.72449, 0.417386472, 0, -0.908729076, 0, 1, 0, 0.908729076, 0, 0.417386472)
            l55 = CFrame.new(-3023.80957, 125.849342, -2297.25659, -0.706340909, 0, -0.707871795, 0, 1, 0, 0.707871795, 0, -0.706340909)
            l56 = CFrame.new(413.352539, 132.630173, 378.553101, 0.75609678, 0, 0.654459894, 0, 1, 0, -0.654459894, 0, 0.75609678)
            l57 = CFrame.new(435.00415, 132.630173, 361.490814, 0.654701233, 0, 0.755887806, 0, 1, 0, -0.755887806, 0, 0.654701233)
            l58 = CFrame.new(362.676727, 129.487762, 279.368927, 0.999983251, 0, 0.00578355044, 0, 1, 0, -0.00578355044, 0, 0.999983251)
            l59 = CFrame.new(358.433258, 129.956299, 185.843613, 0.982601047, 0, 0.185728684, 0, 1, 0, -0.185728684, 0, 0.982601047)
            l60 = CFrame.new(357.574615, 129.480942, 202.948975, 0.982601047, 0, 0.185728684, 0, 1, 0, -0.185728684, 0, 0.982601047)
            l61 = CFrame.new(369.302612, 131.424057, 320.272034, 0.75609678, 0, 0.654459894, 0, 1, 0, -0.654459894, 0, 0.75609678)
            l62 = CFrame.new(-1538.58545, 130.508606, 407.204559, 0.272463858, 0, 0.962166011, 0, 1, 0, -0.962166011, 0, 0.272463858)
            l63 = CFrame.new(-1621.96631, 130.508606, 581.007202, 0.735795379, 0, 0.677203953, 0, 1, 0, -0.677203953, 0, 0.735795379)
            l64 = CFrame.new(-1488.74377, 130.508606, 414.505676, 0.041434288, 0, 0.999141216, 0, 1, 0, -0.999141216, 0, 0.041434288)
            l6[1] = l7
            l6[2] = l8
            l6[3] = l9
            l6[4] = l10
            l6[5] = l11
            l6[6] = l12
            l6[7] = l13
            l6[8] = l14
            l6[9] = l15
            l6[10] = l16
            l6[11] = l17
            l6[12] = l18
            l6[13] = l19
            l6[14] = l20
            l6[15] = l21
            l6[16] = l22
            l6[17] = l23
            l6[18] = l24
            l6[19] = l25
            l6[20] = l26
            l6[21] = l27
            l6[22] = l28
            l6[23] = l29
            l6[24] = l30
            l6[25] = l31
            l6[26] = l32
            l6[27] = l33
            l6[28] = l34
            l6[29] = l35
            l6[30] = l36
            l6[31] = l37
            l6[32] = l38
            l6[33] = l39
            l6[34] = l40
            l6[35] = l41
            l6[36] = l42
            l6[37] = l43
            l6[38] = l44
            l6[39] = l45
            l6[40] = l46
            l6[41] = l47
            l6[42] = l48
            l6[43] = l49
            l6[44] = l50
            l6[45] = l51
            l6[46] = l52
            l6[47] = l53
            l6[48] = l54
            l6[49] = l55
            l6[50] = l56
            l6[51] = l57
            l6[52] = l58
            l6[53] = l59
            l6[54] = l60
            l6[55] = l61
            l6[56] = l62
            l6[57] = l63
            l6[58] = l64
            l6[59] = CFrame.new(-1429.39026, 130.508606, 692.966003, 0.999996185, 0, -0.00276230182, 0, 1, 0, 0.00276230182, 0, 0.999996185)
            l6[60] = CFrame.new(-1441.03003, 129.773682, 748.556274, 0.877354503, 0.0595770404, -0.47612983, -0.00840319507, 0.99401778, 0.108894795, 0.479769111, -0.091538325, 0.872606635)
            l6[61] = CFrame.new(-277.766693, 137.585281, 1972.96582, 0.061527133, 0, 0.998105407, 0, 1, 0, -0.998105407, 0, 0.061527133)
            l6[62] = CFrame.new(-214.824249, 132.524658, 1895.04797, 0.235776424, 0, 0.971807301, 0, 1, 0, -0.971807301, 0, 0.235776424)
            l6[63] = CFrame.new(-261.935608, 132.842606, 2015.04688, -0.191194296, -0.210340247, 0.958750129, -9.29832458e-06, 0.976769686, 0.214291722, -0.981552243, 0.0409624353, -0.186754704)
            l6[64] = CFrame.new(-248.441879, 135.628418, 2017.90662, -0.958763242, -0.210297734, -0.191177279, -0.214253575, 0.97677809, 2.17165798e-05, 0.186733216, 0.0409812257, -0.981555939)
            table.move({ CFrame.new(-264.803192, 133.141052, 1932.81702, -0.479995728, 0, 0.877270877, 0, 1, 0, -0.877270877, 0, -0.479995728) }, 1, 64, 65, l6)
            l7 = false
            _U_321["219_2"] = l2
            _U_321["219_3"] = l4
            task.spawn(function()
            local _R_219 = {}
            local u1, u2, u3, u4, u5, u6
                u1 = 1
                if _G.AutoClaimShellActive then
                    while true do
                        if not l7 then
                            u2 = 0
                            u3 = 2
                            u4 = 1
                            for _i2 = u2, u3, u4 do
                                u5 = _i2
                                u6 = l6[(((u1 + u5) - 1) % (#l6)) + 1]
                                if u6 then
                                    pcall(function()
                                        _U_321["219_2"]:RequestStreamAroundAsync(u6.Position, 100)
                                    end)
                                end
                            end
                            ShellParagraph:SetContent("Scanning " .. (u1 .. ("/" .. (#l6))))
                            if (#l6) <= u1 then
                                u1 = u1 + 1
                            else
                                u1 = 1
                                if not l7 then
                                    _U_321["219_3"].CFrame = l5
                                    ShellParagraph:SetContent("Cycle Done. At Base.")
                                    task.wait(1)
                                    AutoClaimShellToggle:Set(false)
                                end
                            end
                        end
                        task.wait(0.2)
                        if not _G.AutoClaimShellActive then
                            break
                        end
                    end
                end
            end)
            _U_321["413_1"] = l4
            task.spawn(function()
            local u1, u2, u3, u4, u5
                while true do
                    if not _G.AutoClaimShellActive then
                        break
                    end
                    u1 = {}
                    for _k2, _v2 in pairs(workspace:GetChildren()) do
                        u3, u4 = _k2, _v2
                        if u4.Name == "Shell" then
                            u5 = u4:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if u5 then
                                if u5.Enabled then
                                    table.insert(u1, { model = u4, prompt = u5 })
                                end
                            end
                        end
                    end
                    if 0 < (#u1) then
                        l7 = true
                        for _k2, _v2 in ipairs(u1) do
                            u3, u4 = _k2, _v2
                            if not _G.AutoClaimShellActive then
                                break
                            end
                            ShellParagraph:SetContent("Sniping Shell...")
                            _U_321["413_1"].CFrame = CFrame.new(u4.model:GetPivot().Position + Vector3.new(0, 3, 0))
                            task.wait(0.2)
                            fireproximityprompt(u4.prompt)
                            task.wait(0.2)
                        end
                        _U_321["413_1"].CFrame = l5
                        l7 = false
                    end
                    task.wait(0.5)
                end
            end)
            return
        else
            l4 = "Disabled"
            ShellParagraph:SetContent(l4)
            return
        end
    end
})
v152 = require(game:GetService("ReplicatedStorage").shared.modules.SharedCrabCage)
_R[153] = require(game:GetService("ReplicatedStorage").shared.modules.library.crabcages)
v154 = {
    SelectedCage = "Crab Cage",
    DeployEnabled = false,
    ClaimEnabled = false,
    DeployThread = nil,
    ClaimThread = nil
}
v155 = game:GetService("ReplicatedStorage").packages.Net["RF/CrabCage/Place"]
v156 = game:GetService("ReplicatedStorage").packages.Net["RF/CrabCage/Claim"]
v157 = RaycastParams.new()
v157.FilterType = Enum.RaycastFilterType.Include
v157.FilterDescendantsInstances = { workspace:WaitForChild("zones"):WaitForChild("fishing") }
_U["488_2"] = v152
GetDeployCFrame = function()
local l1, l2, l3, l6, l8, l9
    l1 = LocalPlayer.Character
    l2 = l1
    if l2 then
        l2 = l1:FindFirstChild("HumanoidRootPart")
    end
    if l2 then
        l3 = workspace.CurrentCamera
        l6 = workspace:Raycast(l3.CFrame.Position, l3.CFrame.LookVector * 256, v157)
        if not l6 then
            return nil
        else
            return l8(l9, l6.Position, CFrame.lookAt(l6.Position, l2.Position))
        end
    else
        return nil
    end
end
_U["287_2"] = v152
AutoAimPreview = function(p1)
local l2, l3, l5, l6, l7, l9, l10, l11, l12, l13, l14
    l2 = LocalPlayer.Character
    l3 = l2
    if l3 then
        l3 = l2:FindFirstChild("HumanoidRootPart")
    end
    if l3 then
        for _k1, _v1 in ipairs({
            l3.CFrame * CFrame.new(0, 0, -8),
            l3.CFrame * CFrame.new(5, 0, -8),
            l3.CFrame * CFrame.new(-5, 0, -8),
            l3.CFrame * CFrame.new(8, 0, 0),
            l3.CFrame * CFrame.new(-8, 0, 0)
        }) do
            l6, l7 = _k1, _v1
            l9 = l9(l10, l7.Position + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), v157)
            if l9 then
                p1._PreviewModel:PivotTo(l11(l12, l9.Position, CFrame.lookAt(l9.Position, l3.Position)))
                for _k1, _v1 in p1._PreviewModel:GetDescendants() do
                    l13, l14 = _k1, _v1
                    if l14:IsA("BasePart") then
                        l14.Color = Color3.fromRGB(125, 255, 105)
                    end
                end
                p1._CurrentError = nil
                return true
            end
        end
        return false
    else
        return false
    end
end
DeployCages = function()
local _R_206 = {}
local _U_206 = {}
local l1, l2, l3, l4, l5, l6, l7, l9, l10
    l1 = LocalPlayer.Character
    l2 = LocalPlayer.Backpack
    if l1 then
        l3 = l1:FindFirstChildOfClass("Humanoid")
    end
    l4 = require(game:GetService("ReplicatedStorage").client.legacyControllers.CrabCageController)
    l5 = require(game:GetService("ReplicatedStorage").shared.modules.library.crabcages)
    if v154.DeployEnabled then
        while true do
            l1 = LocalPlayer.Character
            l2 = LocalPlayer.Backpack
            l6 = l1
            if l6 then
                l6 = l1:FindFirstChildOfClass("Humanoid")
            end
            l3 = l6
            l6 = l2:FindFirstChild(v154.SelectedCage)
            if not l6 then
                l6 = l1
                if l6 then
                    l6 = l1:FindFirstChild(v154.SelectedCage)
                end
            end
            if not l6 then
                break
            end
            if l6.Parent ~= l1 then
                l9 = l6
                l3:EquipTool(l9)
                task.wait(0.5)
            end
            l7 = l4._PreviewModel
            if l7 then
                l9 = l4
                if AutoAimPreview(l9) then
                    l9 = l7:GetPivot()
                    l10 = l5.byName[v154.SelectedCage]
                    if l10 then
                        l10 = l5.byName[v154.SelectedCage].Id
                    end
                    if not l10 then
                        l10 = 1
                    end
                    _U_206["473_1"] = l9
                    _U_206["473_2"] = l10
                    task.spawn(function()
                        pcall(function()
                            v155:InvokeServer(_U_206["473_1"], _U_206["473_2"])
                        end)
                    end)
                    task.wait()
                    if not v154.DeployEnabled then
                        v154.DeployThread = nil
                        return
                    end
                else
                    l9 = task.wait
                    l10 = 0.5
                    l9(l10)
                end
            else
                l9 = 0.3
                task.wait(l9)
            end
        end
        notif("Crab Cage habis!")
        v154.DeployEnabled = false
    end
end
ClaimCages = function()
local _R_169 = {}
local _U_169 = {}
local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10
    l1 = require(game:GetService("ReplicatedStorage").client.legacyControllers.CrabCageController)
    l2 = require(game:GetService("ReplicatedStorage").shared.modules.SharedCrabCage)
    if v154.ClaimEnabled then
        while true do
            l3 = LocalPlayer.Character
            l4 = l3
            if l4 then
                l4 = l3:FindFirstChild("HumanoidRootPart")
            end
            l5 = l4
            if l5 then
                l5 = l4.CFrame
            end
            l6 = {}
            for _k1, _v1 in pairs(l1.ActiveCages) do
                l8, l9 = _k1, _v1
                if l9.data.s == l2.CageState.Claimable then
                    if not l9.pending then
                        table.insert(l6, { id = l8, cage = l9 })
                    end
                end
            end
            if 0 < (#l6) then
                table.sort(l6, function(a1, a2)
                local u3, u4, u5
                    u3 = a1.cage.pos.Position
                    u4 = a2.cage.pos.Position
                    u5 = l4
                    if u5 then
                        u5 = l4.Position
                    end
                    if not u5 then
                        u5 = Vector3.zero
                    end
                    return ((u3 - u5)).Magnitude < ((u4 - u5)).Magnitude
                end)
                for _k1, _v1 in ipairs(l6) do
                    l8, l9 = _k1, _v1
                    if not v154.ClaimEnabled then
                        break
                    end
                    l3 = LocalPlayer.Character
                    l10 = l3
                    if l10 then
                        l10 = l3:FindFirstChild("HumanoidRootPart")
                    end
                    l4 = l10
                    if l4 then
                        l4.CFrame = l9.cage.pos * CFrame.new(0, 0, 5)
                        task.wait(0.1)
                    end
                    l10 = l9.cage
                    l10.pending = "claim"
                    _U_169["465_1"] = l9
                    pcall(function()
                        v156:InvokeServer(_U_169["465_1"].id)
                    end)
                end
                l3 = LocalPlayer.Character
                l7 = l3
                if l7 then
                    l9 = "HumanoidRootPart"
                    l7 = l3:FindFirstChild(l9)
                end
                l4 = l7
                if l4 then
                    if l5 then
                        l4.CFrame = l5
                    end
                end
            end
            task.wait(2)
            if not v154.ClaimEnabled then
                break
            end
        end
    end
    v154.ClaimThread = nil
end
CrabCage = v43.Auto:AddSection("Crab Cage")
_R["166_v1"] = "Relic Crab Cage"
CrabCage:AddDropdown({
    Title = "Select Crab Cage",
    Options = {
        "Crab Cage",
        "Coral Crab Cage",
        "Golden Crab Cage",
        "Reinforced Crab Cage",
        _R["166_v1"]
    },
    Default = "Crab Cage",
    Callback = function(p1)
        v154.SelectedCage = p1
    end
})
CrabCage:AddToggle({
    Title = "Crab Cage Deploy",
    Default = false,
    Callback = function(p1)
        v154.DeployEnabled = p1
        if p1 then
            if not v154.DeployThread then
                v154.DeployThread = task.spawn(DeployCages)
            end
        end
    end
})
CrabCage:AddToggle({
    Title = "Crab Cage Claim",
    Default = false,
    Callback = function(p1)
        v154.ClaimEnabled = p1
        if p1 then
            if not v154.ClaimThread then
                v154.ClaimThread = task.spawn(ClaimCages)
            end
        end
    end
})
_R["165_v1"] = 0.955
_R[158] = {
    ["???"] = CFrame.new(Vector3.new(497.28, -655.42, -1770.71), Vector3.new(497.28, -655.42, -1770.71) + Vector3.new(0.416, 0, 0.909)),
    ["Abyssal Zenith"] = CFrame.new(-13587.12, -11048.69, 150.76) * CFrame.Angles(math.rad(0), math.rad(84.1), math.rad(0)),
    ["Ancient Archives"] = CFrame.new(-3169.66, -747.26, 1707.43) * CFrame.Angles(math.rad(1.63), math.rad(-2.59), math.rad(0.07)),
    ["Ancient Isle"] = CFrame.new(6009.13, 196.5, 291.15) * CFrame.Angles(math.rad(-180), math.rad(6.19), math.rad(180)),
    ["Atlantean Storm"] = CFrame.new(-3655.41, 131.52, 784.57) * CFrame.Angles(math.rad(180), math.rad(-20.3), math.rad(180)),
    Atlantis = CFrame.new(Vector3.new(-4260.43, -603.4, 1825.14), Vector3.new(-4260.43, -603.4, 1825.14) + Vector3.new(0.231, 0, 0.973)),
    ["Birch Cay"] = CFrame.new(Vector3.new(1688.56, 147.51, -2388.44), Vector3.new(1688.56, 147.51, -2388.44) + Vector3.new(0.474, 0, -0.88)),
    ["Blue Moon - First Sea"] = CFrame.new(Vector3.new(2743.25, 131.5, 2512.18), Vector3.new(2743.25, 131.5, 2512.18) + Vector3.new(0.328, 0, -0.945)),
    ["Boreal Pines"] = CFrame.new(21398.31, 136.31, 3868.33) * CFrame.Angles(math.rad(180), math.rad(62.21), math.rad(-180)),
    ["Brine Pool"] = CFrame.new(Vector3.new(-1787.6, -142.69, -3384.5), Vector3.new(-1787.6, -142.69, -3384.5) + Vector3.new(0, 0, -1)),
    ["Calm Zone"] = CFrame.new(-4324.18, -11184.44, 3673.34) * CFrame.Angles(math.rad(0), math.rad(-16.56), math.rad(0)),
    ["Carrot Garden"] = CFrame.new(Vector3.new(3719.45, -1127.99, -1089.54), Vector3.new(3719.45, -1127.99, -1089.54) + Vector3.new(0.663, 0, -0.749)),
    ["Castaway Cliffs"] = CFrame.new(617.36, 161.43, -1834.32) * CFrame.Angles(math.rad(0), math.rad(49.97), math.rad(0)),
    ["Challenger's Deep"] = CFrame.new(670.2, -3357.35, -1693.42) * CFrame.Angles(math.rad(-180), math.rad(-76.9), math.rad(-180)),
    ["Collapsed Ruins"] = CFrame.new(Vector3.new(3143.34, -1101.96, 1624.77), Vector3.new(3143.34, -1101.96, 1624.77) + Vector3.new(0, 0, 1)),
    ["Coral Bestion"] = CFrame.new(Vector3.new(2524.73, -1096.11, 849.94), Vector3.new(2524.73, -1096.11, 849.94) + Vector3.new(-0.131, 0, 0.991)),
    ["Crimson Cavern"] = CFrame.new(-1009.28, -340.64, -4882.14) * CFrame.Angles(math.rad(-180), math.rad(-2.88), math.rad(-180)),
    ["Crowned Ruins"] = CFrame.new(Vector3.new(3121.78, -1127.33, 2050.75), Vector3.new(3121.78, -1127.33, 2050.75) + Vector3.new(-0.054, 0, 0.999)),
    ["Cryogenic Canal"] = CFrame.new(Vector3.new(19988.45, 913.86, 5407.79), Vector3.new(19988.45, 913.86, 5407.79) + Vector3.new(-0.225, 0, -0.974)),
    ["Crystal Cove"] = CFrame.new(1373.33, -603.41, 2336.49) * CFrame.Angles(math.rad(0), math.rad(-26.64), math.rad(0)),
    ["Crystal Fissure"] = CFrame.new(Vector3.new(21731.42, 134.47, 4001.87), Vector3.new(21731.42, 134.47, 4001.87) + Vector3.new(0.575, 0, 0.818)),
    ["Cultist Lair"] = CFrame.new(Vector3.new(4260.41, -2003, -4677.1), Vector3.new(4260.41, -2003, -4677.1) + Vector3.new(-0.115, 0, -0.993)),
    ["Cultist Lair - Entrance"] = CFrame.new(Vector3.new(50.77, -288.42, 1910.56), Vector3.new(50.77, -288.42, 1910.56) + Vector3.new(0.003, 0, -1)),
    ["Disolate Deep"] = CFrame.new(Vector3.new(-1493.85, -234.7, -2837.54), Vector3.new(-1493.85, -234.7, -2837.54) + Vector3.new(-0.171, 0, -0.985)),
    ["Detonator's Rest"] = CFrame.new(Vector3.new(-1403.91, -843.74, -3482.22), Vector3.new(-1403.91, -843.74, -3482.22) + Vector3.new(0.206, 0, 0.979)),
    ["Earmark Island"] = CFrame.new(Vector3.new(1279.13, 140.1, 542.61), Vector3.new(1279.13, 140.1, 542.61) + Vector3.new(-0.047, 0, -0.999)),
    ["Ethereal Abyss"] = CFrame.new(Vector3.new(-3790.56, -566.77, 1852.19), Vector3.new(-3790.56, -566.77, 1852.19) + Vector3.new(-0.328, 0, 0.945)),
    ["Ethereal Trial"] = CFrame.new(Vector3.new(-3803.22, -664.01, 1830.52), Vector3.new(-3803.22, -664.01, 1830.52) + Vector3.new(0.039, 0, 0.999)),
    ["Executive Headquaters"] = CFrame.new(Vector3.new(-37.26, -246.55, 205.14), Vector3.new(-37.26, -246.55, 205.14) + Vector3.new(0.129, 0, 0.992)),
    ["Forgotten Tample"] = CFrame.new(Vector3.new(-5125.93, -1759.56, -9871.6), Vector3.new(-5125.93, -1759.56, -9871.6) + Vector3.new(-0.001, 0, 1)),
    ["Forsaken Shores"] = CFrame.new(-2699.87, 130.61, 1423.95) * CFrame.Angles(math.rad(-180), math.rad(-12.24), math.rad(180)),
    ["Frigid Cavern"] = CFrame.new(Vector3.new(19800.15, 424.73, 5346.64), Vector3.new(19800.15, 424.73, 5346.64) + Vector3.new(-0.231, 0, -0.973)),
    ["Ghost Tavern"] = CFrame.new(Vector3.new(295.04, 800, -6893.89), Vector3.new(295.04, 800, -6893.89) + Vector3.new(-0.103, 0, -0.995)),
    ["Glacial Grotto"] = CFrame.new(Vector3.new(19934.08, 1211.92, 5282.95), Vector3.new(19934.08, 1211.92, 5282.95) + Vector3.new(0.601, 0, -0.799)),
    ["Grand Reef"] = CFrame.new(Vector3.new(-3618.28, 140, 502.1), Vector3.new(-3618.28, 140, 502.1) + Vector3.new(0, 0, -1)),
    ["Haddock Rock"] = CFrame.new(Vector3.new(-527.92, 156.33, -464.76), Vector3.new(-527.92, 156.33, -464.76) + Vector3.new(-0.233, 0, -0.972)),
    ["Half of Whisper"] = CFrame.new(Vector3.new(4313.69, -2234.82, -4681.31), Vector3.new(4313.69, -2234.82, -4681.31) + Vector3.new(-0.353, 0, -0.936)),
    ["Harvesters Spike"] = CFrame.new(Vector3.new(-1260.49, 134.6, 1579.02), Vector3.new(-1260.49, 134.6, 1579.02) + Vector3.new(-0.391, 0, -0.92)),
    ["Inner Tidefall Castle"] = CFrame.new(Vector3.new(4542.61, -1101.11, 946.08), Vector3.new(4542.61, -1101.11, 946.08) + Vector3.new(0.148, 0, 0.989)),
    ["Keepers Altar"] = CFrame.new(Vector3.new(1319.22, -805.29, -105.08), Vector3.new(1319.22, -805.29, -105.08) + Vector3.new(-0.041, 0, -0.999)),
    ["Kraken Pool"] = CFrame.new(Vector3.new(-4398.01, -996.26, 2051.75), Vector3.new(-4398.01, -996.26, 2051.75) + Vector3.new(-0.13, 0, -0.992)),
    ["Lost Jungle"] = CFrame.new(Vector3.new(-2708.26, 150.2, -2054.09), Vector3.new(-2708.26, 150.2, -2054.09) + Vector3.new(-0.463, 0, -0.886)),
    ["Liminescent Cavern"] = CFrame.new(-982.57, -334.48, -4128.87) * CFrame.Angles(math.rad(-180), math.rad(17.14), math.rad(180)),
    ["Merlins Hut"] = CFrame.new(Vector3.new(-946.89, 222.42, -985.54), Vector3.new(-946.89, 222.42, -985.54) + Vector3.new(0.314, 0, -0.949)),
    Mineshaft = CFrame.new(-723.16, -864.75, -118.71) * CFrame.Angles(math.rad(180), math.rad(35.7), math.rad(-180)),
    Moosewood = CFrame.new(495.5, 160.8, 236.58) * CFrame.Angles(math.rad(-180), math.rad(34.91), math.rad(180)),
    ["Mossjaw Rest"] = CFrame.new(Vector3.new(-4857.97, -1790.56, -10220.56), Vector3.new(-4857.97, -1790.56, -10220.56) + Vector3.new(0.017, 0, -0.999)),
    Mushgrove = CFrame.new(Vector3.new(2666.55, 133.5, -758.31), Vector3.new(2666.55, 133.5, -758.31) + Vector3.new(-0.002, 0, -1)),
    ["Mysterious Crack"] = CFrame.new(Vector3.new(-1108.5, -292.26, -3279.06), Vector3.new(-1108.5, -292.26, -3279.06) + Vector3.new(0.002, 0, -1)),
    ["Mysterious River"] = CFrame.new(Vector3.new(-1019.86, -325.13, -3748.9), Vector3.new(-1019.86, -325.13, -3748.9) + Vector3.new(0.002, 0, -1)),
    ["Northern Expedition"] = CFrame.new(-1881.33, 130.13, 3740.5) * CFrame.Angles(math.rad(0), math.rad(-26.12), math.rad(0)),
    ["OverGrowth Caves"] = CFrame.new(20298.65, 271.44, 5515.72) * CFrame.Angles(math.rad(180), math.rad(-9.07), math.rad(-180)),
    ["Passage of Oaths"] = CFrame.new(Vector3.new(4363.88, -2482.57, -4682.22), Vector3.new(4363.88, -2482.57, -4682.22) + Vector3.new(-0.009, 0, -1)),
    ["Poseidon Tample"] = CFrame.new(Vector3.new(-4285.63, -683.42, 1168.26), Vector3.new(-4285.63, -683.42, 1168.26) + Vector3.new(-0.036, 0, -0.999)),
    ["Poseidon Trial"] = CFrame.new(Vector3.new(-3807.24, -550.69, 1082.53), Vector3.new(-3807.24, -550.69, 1082.53) + Vector3.new(0.623, 0, -0.782)),
    ["Roslit Bay"] = CFrame.new(Vector3.new(-1684.01, 156.08, 439.96), Vector3.new(-1684.01, 156.08, 439.96) + Vector3.new(-0.001, 0, -1)),
    ["Roslit Volcano"] = CFrame.new(Vector3.new(-1896.77, 176.63, 302.68), Vector3.new(-1896.77, 176.63, 302.68) + Vector3.new(0.261, 0, 0.965)),
    ["Roslit Hamlet"] = CFrame.new(Vector3.new(-1459.95, 133.14, 701.61), Vector3.new(-1459.95, 133.14, 701.61) + Vector3.new(0, 0, -1)),
    ["Roslit Pond"] = CFrame.new(Vector3.new(-1787.08, 148.07, 636.5), Vector3.new(-1787.08, 148.07, 636.5) + Vector3.new(0.202, 0, 0.979)),
    ["Scoria Reach"] = CFrame.new(-5065.83, 137.99, -1358.46) * CFrame.Angles(math.rad(0), math.rad(61.97), math.rad(0)),
    ["Snow Burrow"] = CFrame.new(Vector3.new(2759.1, 97.95, 2602.91), Vector3.new(2759.1, 97.95, 2602.91) + Vector3.new(-0.055, 0, -0.998)),
    Snowcap = CFrame.new(Vector3.new(2799.17, 143.06, 2567.33), Vector3.new(2799.17, 143.06, 2567.33) + Vector3.new(0.238, 0, 0.971)),
    ["Snowcap Cave"] = CFrame.new(Vector3.new(2873.89, 144.51, 2601.3), Vector3.new(2873.89, 144.51, 2601.3) + Vector3.new(-0.374, 0, -0.927)),
    ["Statue Of Sovereignty"] = CFrame.new(Vector3.new(-138.67, 146.95, -1130.52), Vector3.new(-138.67, 146.95, -1130.52) + Vector3.new(0.289, 0, 0.957)),
    ["Sunken Depths"] = CFrame.new(Vector3.new(-4978.62, -694.01, 1821.56), Vector3.new(-4978.62, -694.01, 1821.56) + Vector3.new(-0.046, 0, -0.999)),
    ["Sunken Reliquary"] = CFrame.new(Vector3.new(2947.59, -1102.42, 72.65), Vector3.new(2947.59, -1102.42, 72.65) + Vector3.new(0.127, 0, -0.992)),
    ["Sunken Trial"] = CFrame.new(Vector3.new(-4937.98, -595.12, 1837.59), Vector3.new(-4937.98, -595.12, 1837.59) + Vector3.new(0.027, 0, -1)),
    ["Sunstone Island"] = CFrame.new(Vector3.new(-1047.27, 202.84, -1111.12), Vector3.new(-1047.27, 202.84, -1111.12) + Vector3.new(-0.2, 0, 0.98)),
    ["Sunstone Rift"] = CFrame.new(Vector3.new(-1032.72, -561.13, -1344.93), Vector3.new(-1032.72, -561.13, -1344.93) + Vector3.new(-0.602, 0, 0.799)),
    ["Terrapin Island"] = CFrame.new(Vector3.new(-55.44, 133.12, 2029.67), Vector3.new(-55.44, 133.12, 2029.67) + Vector3.new(0.023, 0, 0.999)),
    ["Terrapin Island Cave"] = CFrame.new(Vector3.new(51.42, 152.97, 2006.59), Vector3.new(51.42, 152.97, 2006.59) + Vector3.new(0.036, 0, -0.999)),
    ["Thalassar's Secret"] = CFrame.new(Vector3.new(2888.87, -578.06, 1255.43), Vector3.new(2888.87, -578.06, 1255.43) + Vector3.new(0.097, 0, -0.995)),
    ["The Arch"] = CFrame.new(Vector3.new(1005.17, 132.93, -1241.42), Vector3.new(1005.17, 132.93, -1241.42) + Vector3.new(-0.122, 0, -0.993)),
    ["The Bunker"] = CFrame.new(Vector3.new(1846.38, -327.14, -2384.53), Vector3.new(1846.38, -327.14, -2384.53) + Vector3.new(0.22, 0, -0.975)),
    ["The Depths"] = CFrame.new(Vector3.new(952.22, -711.66, 1230.06), Vector3.new(952.22, -711.66, 1230.06) + Vector3.new(0.13, 0, -0.992)),
    ["The Depths - Maze"] = CFrame.new(Vector3.new(1162.42, -729.79, 1311.02), Vector3.new(1162.42, -729.79, 1311.02) + Vector3.new(-0.313, 0, -0.95)),
    ["The Keeper's Secret"] = CFrame.new(Vector3.new(2234.31, -802.77, 1035.99), Vector3.new(2234.31, -802.77, 1035.99) + Vector3.new(-0.016, 0, -1)),
    ["The Sanctum"] = CFrame.new(4379.89, -2710.07, -4677.15) * CFrame.Angles(math.rad(-180), math.rad(-84.96), math.rad(-180)),
    ["The Void"] = CFrame.new(Vector3.new(-32099.49, 10010.04, -23302.99), Vector3.new(-32099.49, 10010.04, -23302.99) + Vector3.new(0.639, 0, -0.769)),
    Tidefall = CFrame.new(Vector3.new(3906.72, -1092.81, 912.64), Vector3.new(3906.72, -1092.81, 912.64) + Vector3.new(0.24, 0, 0.971)),
    ["Treasure Island"] = CFrame.new(Vector3.new(8293, 192.13, -17212.79), Vector3.new(8293, 192.13, -17212.79) + Vector3.new(-0.595, 0, -0.804)),
    Trident = CFrame.new(Vector3.new(-1481.28, -223.51, -2221.96), Vector3.new(-1481.28, -223.51, -2221.96) + Vector3.new(0.176, 0, -0.984)),
    ["Trident Entrance"] = CFrame.new(Vector3.new(-1476.97, -224.07, -2313.51), Vector3.new(-1476.97, -224.07, -2313.51) + Vector3.new(0.143, 0, -0.99)),
    ["Underground Music Venue"] = CFrame.new(Vector3.new(2051.02, -643.5, 2472.21), Vector3.new(2051.02, -643.5, 2472.21) + Vector3.new(0.038, 0, 0.999)),
    ["Underwater Cave"] = CFrame.new(Vector3.new(3204.82, -399.22, 976.88), Vector3.new(3204.82, -399.22, 976.88) + Vector3.new(0.706, 0, 0.708)),
    ["Underwater Opening"] = CFrame.new(Vector3.new(3219.6, 132.91, 847.59), Vector3.new(3219.6, 132.91, 847.59) + Vector3.new(-0.291, 0, -0.957)),
    ["Upper Snowcap"] = CFrame.new(Vector3.new(2822.26, 283.83, 2544.17), Vector3.new(2822.26, 283.83, 2544.17) + Vector3.new(0.56, 0, -0.829)),
    ["Veil of the Forsaken"] = CFrame.new(Vector3.new(-2357.54, -11177.86, 7106.8), Vector3.new(-2357.54, -11177.86, 7106.8) + Vector3.new(-0.345, 0, -0.939)),
    Vertigo = CFrame.new(Vector3.new(-72.79, -506.79, 1538.82), Vector3.new(-72.79, -506.79, 1538.82) + Vector3.new(0.05, 0, 1)),
    ["Vertigo Dip"] = CFrame.new(Vector3.new(-20.53, -702.61, 1232.18), Vector3.new(-20.53, -702.61, 1232.18) + Vector3.new(0.081, 0, 0.997)),
    ["Zeus Trial"] = CFrame.new(Vector3.new(-4296.86, -665.89, 2426.31), Vector3.new(-4296.86, -665.89, 2426.31) + Vector3.new(-0.005, 0, -1)),
    ["Zeus's Rod Room"] = CFrame.new(Vector3.new(-4307.33, -606.6, 2723.37), Vector3.new(-4307.33, -606.6, 2723.37) + Vector3.new(0.297, 0, _R["165_v1"])),
    ["Volcanic Vents"] = CFrame.new(-3419.89, -2273.48, 3768.51) * CFrame.Angles(math.rad(0), math.rad(-1.64), math.rad(0)),
    ["Above The Clouds"] = CFrame.new(1499.65, 2594.74, -1751.13) * CFrame.Angles(math.rad(0), math.rad(-10.37), math.rad(0)),
    ["Toxic Grove"] = CFrame.new(-2756.08, -317.17, -2251.43) * CFrame.Angles(math.rad(0), math.rad(-13.54), math.rad(0)),
    ["Living Garden"] = CFrame.new(-2475.57, -317.67, -2873.54) * CFrame.Angles(math.rad(0), math.rad(-64.99), math.rad(0)),
    ["Nectar Den"] = CFrame.new(-2026.41, -302.04, -3239.62) * CFrame.Angles(math.rad(0), math.rad(-7.82), math.rad(0)),
    ["Everturn Forest"] = CFrame.new(2519.81, 166.07, -2591.29) * CFrame.Angles(math.rad(-180), math.rad(64.62), math.rad(180)),
    ["Bellona's Frenzy of War"] = CFrame.new(-8794.94, -2361.67, 851.17) * CFrame.Angles(math.rad(180), math.rad(-0.53), math.rad(-180)),
    ["Apollo's Song of Light"] = CFrame.new(-8831.62, -2904.73, 661.08) * CFrame.Angles(math.rad(0), math.rad(-4.45), math.rad(0)),
    ["Poseidon's Storm of Floods"] = CFrame.new(-8736.11, -3184.83, 746.87) * CFrame.Angles(math.rad(0), math.rad(44.38), math.rad(0)),
    ["Zeus's Thunder of Chaos"] = CFrame.new(-8815.1, -3534.33, 623.62) * CFrame.Angles(math.rad(180), math.rad(12.13), math.rad(-180)),
    ["Hades' Underworld of Indefinite"] = CFrame.new(-8868.21, -4243.17, 514.04) * CFrame.Angles(math.rad(0), math.rad(83), math.rad(0)),
    Aether = CFrame.new(-95.52, -654.75, 977.04) * CFrame.Angles(math.rad(0), math.rad(-9.95), math.rad(0)),
    Hawaii = CFrame.new(-1341.58, 130.32, -39929.91) * CFrame.Angles(math.rad(-180), math.rad(-88.99), math.rad(-180))
}
_R["159_v1"] = CFrame.new(-2769.01, -1024.54, 6196.56)
_R["160_v1"] = CFrame.Angles
_R["161_v1"] = math.rad(0)
_R["162_v1"] = math.rad(90)
_R["163_v1"] = math.rad
_R[158]["(NEW) The Shady Bazzar"] = _R["159_v1"] * _R["160_v1"](_R["161_v1"], _R["162_v1"], _R["163_v1"](0))
Locations = _R[158]
_R[158] = {}
for _k, _v in pairs(Locations) do
    _R["160_v1"], _R["161_v1"] = _k, _v
    _R["162_v1"] = table.insert
    _R["163_v1"] = _R[158]
    _R["162_v1"](_R["163_v1"], _R["160_v1"])
end
table.sort(_R[158])
GetPlayerList = function()
local l1, l2, l3, l4
    l1 = {}
    for _k1, _v1 in ipairs(Players:GetPlayers()) do
        l3, l4 = _k1, _v1
        if l4 ~= LocalPlayer then
            table.insert(l1, l4.Name)
        end
    end
    table.sort(l1)
    return l1
end
UpdateNPCDropdown = function()
local l1, l2, l3, l4, l5, l6, l7
    l1 = {}
    for _k1, _v1 in pairs(workspace.world.npcs:GetChildren()) do
        l3, l4 = _k1, _v1
        if not l4:IsA("Model") then
            if l4:IsA("Folder") then
                for _k1, _v1 in pairs(l4:GetChildren()) do
                    l6, l7 = _k1, _v1
                    if l7:IsA("Model") then
                        table.insert(l1, l7.Name)
                    end
                end
            end
        else
            table.insert(l1, l4.Name)
        end
    end
    table.sort(l1)
    TeleNPCDropdown:SetValues(l1)
end
_R["159_v1"] = ""
_R["160_v1"] = ""
_R["161_v1"] = ""
_R["162_v1"] = ""
_R["163_v1"] = ""
_U["269_0"] = SnapReelConfig
_U["269_1"] = v41
getActiveEvents = function()
local l1, l2, l3, l4, l5, l6, l7
    l1 = {}
    l2 = workspace:WaitForChild("zones"):WaitForChild("fishing")
    for _k1, _v1 in ipairs(_U["269_0"]) do
        l4, l5 = _k1, _v1
        l6 = _U["269_1"][l5]
        if not l6 then
            l6 = l5
        end
        l7 = l2:FindFirstChild(l6)
        if l7 then
            if l7:IsA("BasePart") then
                table.insert(l1, l5)
            end
        end
    end
    return l1
end
TeleSection = v43.Teleport:AddSection("Teleport")
TeleSection:AddSubSection("Teleport Location")
TeleSection:AddDropdown({
    Title = "Select Location",
    Options = _R[158],
    Default = _R[158][1],
    Callback = function(p1)
        _R["160_v1"] = p1
    end
})
TeleCordinate = TeleSection:AddInput({
    Title = "Teleport Cordinate",
    Placeholder = "Write ur input here (x, y, z)",
    Callback = function(p1)
        _R["159_v1"] = p1
    end
})
TeleSection:AddButton({
    Title = "Teleport to Location",
    Callback = function()
    local l1, l2, l3, l4, l5
        l1 = LocalPlayer.Character
        if l1 then
            if l1:FindFirstChild("HumanoidRootPart") then
                if _R["159_v1"] == "" then
                    if _R["160_v1"] == "" then
                        notif("Please select a location or enter coordinates!")
                        return
                    else
                        if Locations[_R["160_v1"]] then
                            l2 = l1.HumanoidRootPart
                            l2.Anchored = true
                            l2 = l1.HumanoidRootPart
                            l2.CFrame = Locations[_R["160_v1"]]
                            notif("Teleported to: " .. _R["160_v1"])
                            task.delay(1, function()
                            local u1
                                if l1.HumanoidRootPart.Anchored then
                                    u1 = l1.HumanoidRootPart
                                    u1.Anchored = false
                                end
                            end)
                            return
                        end
                    end
                else
                    l2, l3, l4 = _R["159_v1"]:match("([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+)")
                    if not l2 then
                        notif("Invalid coordinate format! Use: x, y, z")
                        return
                    else
                        if l3 then
                            if l4 then
                                l5 = l1.HumanoidRootPart
                                l5.CFrame = CFrame.new(tonumber(l2), tonumber(l3), tonumber(l4))
                                _R["159_v1"] = ""
                                TeleCordinate:Set(_R["159_v1"])
                                notif("Teleported to coordinate: " .. _R["159_v1"])
                                return
                            end
                        end
                    end
                end
            end
        end
    end
})
TeleSection:AddToggle({
    Title = "Click on Teleport",
    Default = false,
    Keybind = true,
    Callback = function(p1)
    local l2
        if not p1 then
            if _G.ClickTeleport then
                _G.ClickTeleport:Disconnect()
                l2 = _G
                l2.ClickTeleport = nil
            end
        else
            l2 = _G
            l2.ClickTeleport = game:GetService("UserInputService").InputBegan:Connect(function(a1, a2)
            local u3, u4, u5, u6, u7
                if not a2 then
                    if a1.UserInputType == Enum.UserInputType.MouseButton1 then
                        u3 = LocalPlayer.Character
                        if u3 then
                            RaycastParams.new().FilterDescendantsInstances = { u3 }
                            u4.FilterType = Enum.RaycastFilterType.Exclude
                            u5 = workspace.CurrentCamera:ScreenPointToRay(a1.Position.X, a1.Position.Y)
                            u6 = workspace:Raycast(u5.Origin, u5.Direction * 5000, u4)
                            if u6 then
                                u7 = u3:FindFirstChild("HumanoidRootPart")
                                if u7 then
                                    u7.CFrame = CFrame.new(u6.Position + Vector3.new(0, 3, 0))
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})
TeleSection:AddSubSection("Teleport Event Zone")
TeleEventDropdown = _R[164](_R["165_v1"], {
    Title = "Select Event Location",
    Options = getActiveEvents(),
    Default = {},
    Callback = function(p1)
        _R["163_v1"] = p1
    end
})
TeleSection:AddButton({
    Title = "Refresh Event List",
    Callback = function()
    local l1
        l1 = getActiveEvents()
        TeleEventDropdown:SetValues(l1)
        notif("Found " .. ((#l1) .. " active events"))
    end
})
TeleportEventPos = function(p1, p2)
local l3, l4, l5
    l3 = LocalPlayer.Character
    if not l3 then
        notif("Character not found!")
        return
    else
        if l3:FindFirstChild("HumanoidRootPart") then
            l4 = l3.HumanoidRootPart
            l4.Anchored = true
            if p1 ~= "Skeletal Leviathan Hunt" then
                if p1 ~= "Pliosaur Hunt" then
                    if p1 ~= "Forsaken Veil - Scylla" then
                        if p1 ~= "Toxic Boil" then
                            if p1 ~= "Rotbloom Hunt" then
                                l5 = l3.HumanoidRootPart
                                l5.CFrame = CFrame.new(p2.Position + Vector3.new(0, 25, 0))
                                task.delay(1, function()
                                local u1
                                    if l3.HumanoidRootPart.Anchored then
                                        u1 = l3.HumanoidRootPart
                                        u1.Anchored = false
                                    end
                                end)
                                return
                            else
                                l4 = l3.HumanoidRootPart
                                l4.CFrame = CFrame.new(-2461.51, -277.69, -2449.09) * CFrame.Angles(math.rad(180), math.rad(7.49), math.rad(-180))
                                task.delay(1, function()
                                local u1
                                    if l3.HumanoidRootPart.Anchored then
                                        u1 = l3.HumanoidRootPart
                                        u1.Anchored = false
                                    end
                                end)
                                return
                            end
                        else
                            l4 = l3.HumanoidRootPart
                            l4.CFrame = CFrame.new(-2584.12, -318.39, -2204.97) * CFrame.Angles(math.rad(0), math.rad(39.5), math.rad(0))
                            task.delay(1, function()
                            local u1
                                if l3.HumanoidRootPart.Anchored then
                                    u1 = l3.HumanoidRootPart
                                    u1.Anchored = false
                                end
                            end)
                            return
                        end
                    else
                        l4 = l3.HumanoidRootPart
                        l4.CFrame = CFrame.new(-2522.45, -11221.99, 6939.69) * CFrame.Angles(math.rad(-180), math.rad(-82.8), math.rad(-180))
                        task.delay(1, function()
                        local u1
                            if l3.HumanoidRootPart.Anchored then
                                u1 = l3.HumanoidRootPart
                                u1.Anchored = false
                            end
                        end)
                        return
                    end
                else
                    l4 = l3.HumanoidRootPart
                    l4.CFrame = CFrame.new(3037.26, -1133.4, 1613.36) * CFrame.Angles(math.rad(-180), math.rad(13.68), math.rad(-180))
                    task.delay(1, function()
                    local u1
                        if l3.HumanoidRootPart.Anchored then
                            u1 = l3.HumanoidRootPart
                            u1.Anchored = false
                        end
                    end)
                    return
                end
            else
                l4 = l3.HumanoidRootPart
                l4.CFrame = CFrame.new(-5494.48, 189.94, -1557.52) * CFrame.Angles(math.rad(0), math.rad(87.09), math.rad(0))
                task.delay(1, function()
                local u1
                    if l3.HumanoidRootPart.Anchored then
                        u1 = l3.HumanoidRootPart
                        u1.Anchored = false
                    end
                end)
                return
            end
        end
    end
end
_U["208_1"] = v41
TeleSection:AddButton({
    Title = "Teleport to Event",
    Callback = function()
    local l1, l3
        if not _R["163_v1"] then
            notif("Select an event first!")
            return
        else
            if _R["163_v1"] ~= "" then
                l1 = _U["208_1"][_R["163_v1"]]
                if not l1 then
                    l1 = _R["163_v1"]
                end
                l3 = workspace:WaitForChild("zones"):WaitForChild("fishing"):FindFirstChild(l1)
                if not l3 then
                    notif("Event not found or inactive!")
                    return
                else
                    if l3:IsA("BasePart") then
                        TeleportEventPos(_R["163_v1"], l3)
                        notif("Teleported to " .. _R["163_v1"])
                        return
                    end
                end
            end
        end
    end
})
TelePlayerSection = v43.Teleport:AddSection("Teleport To Player")
TelePlayerDropdown = _R[164](_R["165_v1"], {
    Title = "Select Player",
    Options = GetPlayerList(),
    Default = {},
    Callback = function(p1)
        _R["161_v1"] = p1
    end
})
TelePlayerSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
    local l1, l2, l3, l4
        l1 = {}
        for _k1, _v1 in ipairs(Players:GetPlayers()) do
            l3, l4 = _k1, _v1
            if l4 ~= LocalPlayer then
                table.insert(l1, l4.Name)
            end
        end
        l4 = l1
        if not l4 then
            l4 = {}
        end
        l2(l3, l4)
    end
})
TelePlayerSection:AddButton({
    Title = "Teleport To Player",
    Callback = function()
    local _U_272 = {}
    local l1, l2, l3, l4
        if _R["161_v1"] ~= "" then
            l1 = Players:FindFirstChild(_R["161_v1"])
            if not l1 then
                notif("Player not found!")
                return
            else
                if l1.Character then
                    l2 = l1.Character:FindFirstChild("HumanoidRootPart")
                    l3 = LocalPlayer.Character
                    l4 = l3
                    if l4 then
                        l4 = l3:FindFirstChild("HumanoidRootPart")
                    end
                    if not l2 then
                        notif("Failed to teleport!")
                        return
                    else
                        if l4 then
                            l4.Anchored = true
                            l4.CFrame = l2.CFrame * CFrame.new(0, 0, 3)
                            notif("Teleported to: " .. _R["161_v1"])
                            _U_272["316_0"] = l4
                            task.delay(1, function()
                                if _U_272["316_0"] then
                                    _U_272["316_0"].Anchored = false
                                end
                            end)
                            return
                        end
                    end
                end
            end
        else
            notif("Please select a player first!")
            return
        end
    end
})
TeleNPCSection = v43.Teleport:AddSection("Teleport To NPC")
TeleNPCDropdown = TeleNPCSection:AddDropdown({
    Title = "Select NPC",
    Values = { "Loading..." },
    Default = {},
    Callback = function(p1)
        _R["162_v1"] = p1
    end
})
TeleNPCSection:AddButton({
    Title = "Refresh NPC",
    Callback = function()
        UpdateNPCDropdown()
    end
})
TeleNPCSection:AddButton({
    Title = "Teleport To NPC",
    Callback = function()
    local l1, l2, l3, l4, l6, l7
        if _R["162_v1"] ~= "" then
            l1 = workspace.world.npcs:FindFirstChild(_R["162_v1"], true)
            l2 = game.Players.LocalPlayer.Character
            l3 = l2
            if l3 then
                l3 = l2:FindFirstChild("HumanoidRootPart")
            end
            if l1 then
                if l3 then
                    l4 = l1:FindFirstChild("HumanoidRootPart")
                    if not l4 then
                        l4 = l1:FindFirstChildWhichIsA("BasePart")
                    end
                    if l4 then
                        game.Players.LocalPlayer:RequestStreamAroundAsync(l4.Position)
                        task.wait(0.1)
                        l6(l7, l4.CFrame * CFrame.new(0, 0, -3))
                    end
                end
            end
        end
    end
})
UpdateNPCDropdown()
_R["165_v1"] = {}
cfToTable = function(p1)
    return { p1:GetComponents() }
end
tableToCf = function(p1)
    return CFrame.new(unpack(p1))
end
LoadPositions = function()
local l2, l3
    if not isfile("Fisch_SavedPos.json") then
        _R["165_v1"] = {}
        return
    else
        _R["165_v1"] = l2(l3, readfile("Fisch_SavedPos.json"))
        return
    end
end
SaveToFile = function()
    writefile("Fisch_SavedPos.json", HttpService:JSONEncode(_R["165_v1"]))
end
UpdateDropdown = function()
local l1, l2, l3, l4
    l1 = {}
    for _k1, _v1 in pairs(_R["165_v1"]) do
        l3, l4 = _k1, _v1
        table.insert(l1, l3)
    end
    PositionDropdown:SetValues(l1)
end
LoadPositions()
_R["166_v1"] = ""
v167 = ""
SavePosSection = v43.Teleport:AddSection("Save Position")
SavePosSection:AddInput({
    Title = "Name Spot",
    Placeholder = "Write ur input here",
    Callback = function(p1)
        _R["166_v1"] = p1
    end
})
PositionDropdown = SavePosSection:AddDropdown({
    Title = "Saved Position",
    Content = "Select a Saved Position to Teleport",
    Options = { "Loading Data..." },
    Default = {},
    Callback = function(p1)
        v167 = p1
    end
})
SavePosSection:AddButton({
    Title = "Save Position",
    Callback = function()
    local l1, l2
        if _R["166_v1"] ~= "" then
            l1 = game.Players.LocalPlayer.Character
            l2 = l1
            if l2 then
                l2 = l1:FindFirstChild("HumanoidRootPart")
            end
            if l2 then
                _R["165_v1"][_R["166_v1"]] = cfToTable(l2.CFrame)
                SaveToFile()
                UpdateDropdown()
            end
        end
    end,
    SubTitle = "Teleport To Position",
    SubCallback = function()
    local l1, l2
        if v167 ~= "" then
            if _R["165_v1"][v167] then
                l1 = game.Players.LocalPlayer.Character
                l2 = l1
                if l2 then
                    l2 = l1:FindFirstChild("HumanoidRootPart")
                end
                if l2 then
                    l2.CFrame = tableToCf(_R["165_v1"][v167])
                end
            end
        end
    end
})
SavePosSection:AddButton({
    Title = "Delete Selected Position",
    Callback = function()
        if v167 ~= "" then
            _R["165_v1"][v167] = nil
            SaveToFile()
            UpdateDropdown()
            v167 = ""
        end
    end
})
UpdateDropdown()
v168 = {
    URL = "",
    DisplayMode = "Money Only",
    Delay = 300,
    ShowFishValue = false,
    CensorUsername = false,
    DiscordID = "",
    EnableMentions = false,
    Enabled = false,
    LastSent = 0,
    StartTime = tick()
}
getUptime = function()
local l1
    l1 = math.floor(tick() - v168.StartTime)
    return string.format("%02d:%02d:%02d", math.floor(l1 / 3600), math.floor((l1 % 3600) / 60), l1 % 60)
end
getUsername = function()
local l1, l2
    l1 = LocalPlayer.Name
    if v168.CensorUsername then
        l2 = math.ceil((#l1) * 0.3)
        l1 = l1:sub(1, l2) .. string.rep("*", (#l1) - l2)
    end
    return l1
end
getMoney = function()
local l1, l2, l3
    l1, l2 = pcall(function()
        return LocalPlayer.PlayerGui.hud.safezone.coins.Text:gsub("[^%d]", "")
    end)
    l3 = l1
    if l3 then
        l3 = l2
    end
    if not l3 then
        l3 = "0"
    end
    return l3
end
getLevel = function()
local l1, l2, l3
    l1, l2 = pcall(function()
        return LocalPlayer.PlayerGui.hud.safezone.lvl.Text:gsub("[^%d]", "")
    end)
    l3 = l1
    if l3 then
        l3 = l2
    end
    if not l3 then
        l3 = "0"
    end
    return l3
end
getFishValue = function()
local _R_190 = {}
local _U_190 = {}
local l1, l2, l3, l4, l6, l7, l8, l9
    l1, l2 = pcall(function()
        return require(game:GetService("ReplicatedStorage").shared.modules.fishing)
    end)
    l3, l4 = pcall(function()
        return require(game:GetService("ReplicatedStorage").client.legacyControllers.DataController)
    end)
    if not l1 then
        return 0
    else
        if l3 then
            l6 = 0
            for _k1, _v1 in pairs(l4.InventoryReplicator:Index({ "Inventory" })) do
                l8, l9 = _k1, _v1
                _U_190["222_2"] = l9
                pcall(function()
                local u1
                    u1 = l2:SellFish(LocalPlayer, _U_190["222_2"], true)
                    if u1 then
                        l6 = l6 + u1
                    end
                end)
            end
            return math.ceil(l6)
        end
    end
end
formatValue = function(p1)
    if 1000000000 <= p1 then
        if 1000000 <= p1 then
            if 1000 <= p1 then
                return "$" .. p1
            else
                return string.format("$%.2fK", p1 / 1000)
            end
        else
            return string.format("$%.2fM", p1 / 1000000)
        end
    else
        return string.format("$%.2fB", p1 / 1000000000)
    end
end
buildEmbed = function()
local l1, l2, l3, l4, l5, l6, l7, l8
    censor = function(a1)
    local u2
        u2 = math.ceil((#a1) * 0.3)
        return a1:sub(1, u2) .. string.rep("*", (#a1) - u2)
    end
    l1 = LocalPlayer.DisplayName
    l2 = LocalPlayer.Name
    l3 = v168.CensorUsername
    if l3 then
        l1 = censor(l1)
        l3 = censor(l2)
        l2 = l3
    end
    l3 = ""
    pcall(function()
    local u1
        u1 = request
        if not u1 then
            u1 = http_request
        end
        if not u1 then
            u1 = http
            if u1 then
                u1 = http.request
            end
        end
        l3 = game:GetService("HttpService"):JSONDecode(u1({
            Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. (LocalPlayer.UserId .. "&size=420x420&format=Png&isCircular=false"),
            Method = "GET"
        }).Body).data[1].imageUrl
    end)
    l4 = {}
    if v168.DisplayMode == "Level Only" then
        table.insert(l4, {
            name = "🎮 Level",
            value = getLevel(),
            inline = true
        })
    end
    if v168.DisplayMode == "Money Only" then
        table.insert(l4, {
            name = "💰 Money",
            value = getMoney() .. " C$",
            inline = true
        })
    end
    if v168.ShowFishValue then
        table.insert(l4, {
            name = "🐟 Fish Value",
            value = formatValue(getFishValue()),
            inline = true
        })
    end
    if 0 < (#l4) then
        if ((#l4) % 3) ~= 0 then
            table.insert(l4, {
                name = "​",
                value = "​",
                inline = true
            })
        end
    end
    table.insert(l4, {
        name = "⏱ Uptime",
        value = "`" .. (getUptime() .. "`"),
        inline = true
    })
    table.insert(l4, {
        name = "🖥 Script",
        value = "MengHub | Fisch",
        inline = true
    })
    l5 = table.insert
    l6 = l4
    l7 = { name = "⚡ Executor" }
    l8 = identifyexecutor
    if l8 then
        l8 = identifyexecutor()
    end
    if not l8 then
        l8 = "Unknown"
    end
    l7.value = l8
    l7.inline = true
    l5(l6, l7)
    l5 = {
        embeds = {
            {
                author = { name = l1 .. (" (@" .. (l2 .. ")")), icon_url = l3 },
                color = 11119017,
                fields = l4,
                thumbnail = { url = l3 },
                footer = { text = "MengHub | Fisch  •  " .. os.date("%d/%m/%Y %H:%M"), icon_url = l3 }
            }
        }
    }
    if v168.EnableMentions then
        if v168.DiscordID ~= "" then
            l5.content = "<@" .. (v168.DiscordID .. ">")
        end
    end
    return game:GetService("HttpService"):JSONEncode(l5)
end
sendWebhook = function()
local l1, l2
    if v168.URL ~= "" then
        l1, l2 = pcall(function()
        local u1
            u1 = request
            if not u1 then
                u1 = http_request
            end
            if not u1 then
                u1 = http
                if u1 then
                    u1 = http.request
                end
            end
            if u1 then
                u1({
                    Url = v168.URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = buildEmbed()
                })
                return
            else
                warn("Executor tidak support HTTP request")
                return
            end
        end)
        return
    else
        warn("Webhook URL kosong!")
        return
    end
end
task.spawn(function()
    while true do
        if v168.Enabled then
            if v168.Delay > (tick() - v168.LastSent) then
                sendWebhook()
                v168.LastSent = tick()
            end
        end
        task.wait(1)
    end
end)
WebhookSection = v43.Webhook:AddSection("Webhook")
WebhookSection:AddSubSection("Webhook Configuration")
WebhookSection:AddInput({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(p1)
        v168.URL = p1
    end
})
WebhookSection:AddDropdown({
    Title = "Display Mode",
    Options = {
        "Nothing",
        "Level Only",
        "Money Only",
        "Level + Money"
    },
    Default = "Money Only",
    Callback = function(p1)
        v168.DisplayMode = p1
    end
})
WebhookSection:AddSlider({
    Title = "Webhook Delay (s)",
    Min = 15,
    Max = 3600,
    Default = 300,
    Callback = function(p1)
        v168.Delay = p1
    end
})
WebhookSection:AddToggle({
    Title = "Show Total Fish Value",
    Default = false,
    Callback = function(p1)
        v168.ShowFishValue = p1
    end
})
WebhookSection:AddToggle({
    Title = "Censor Username",
    Default = false,
    Callback = function(p1)
        v168.CensorUsername = p1
    end
})
WebhookSection:AddSubSection("Notification Settings")
WebhookSection:AddInput({
    Title = "Discord ID",
    Placeholder = "Your Discord User ID",
    Callback = function(p1)
        v168.DiscordID = p1
    end
})
WebhookSection:AddToggle({
    Title = "Enable Mentions",
    Default = false,
    Callback = function(p1)
        v168.EnableMentions = p1
    end
})
WebhookSection:AddSubSection("Controls")
WebhookSection:AddButton({
    Title = "Test Webhook",
    Callback = function()
        sendWebhook()
    end
})
WebhookSection:AddToggle({
    Title = "Enable Webhook",
    Default = false,
    Callback = function(p1)
        v168.Enabled = p1
        if p1 then
            v168.StartTime = tick()
            v168.LastSent = 0
        end
    end
})
BoosterSection = v43.Misc:AddSection("Booster FPS")
BoosterSection:AddToggle({
    Title = "Disable 3D Render",
    Content = "Will make white screen and no render map!",
    Default = false,
    Callback = function(p1)
        if typeof(RunService.Set3dRenderingEnabled) == "function" then
            RunService:Set3dRenderingEnabled(not p1)
        end
    end
})
_R["170_v1"] = workspace:FindFirstChildOfClass("Terrain")
_R["171_v1"] = game:GetService("Lighting")
_R["172_v1"] = game:GetService("StarterGui")
_R["173_v1"] = game:GetService("SoundService")
_R["174_v1"] = Enum.SurfaceType.SmoothNoOutlines
_R["175_v1"] = Enum.Material.SmoothPlastic
_R["176_v1"] = Enum.Technology.Legacy
_R["177_v1"] = Enum.QualityLevel.Level01
_R["178_v1"] = Enum.MeshPartDetailLevel.Level01
_R["179_v1"] = Enum.QualityLevel.Automatic
_R["180_v1"] = Enum.MeshPartDetailLevel.DistanceBased
_R["181_v1"] = Enum.SavedQualitySetting.Automatic
_R["182_v1"] = Enum.SavedQualitySetting.QualityLevel1
_R["183_v1"] = Enum.ReverbType.NoReverb
_R["184_v1"] = Enum.ListenerType.Camera
_R["185_v1"] = Color3.new(1, 1, 1)
_R["186_v1"] = {
    "TopSurface",
    "BottomSurface",
    "LeftSurface",
    "RightSurface",
    "FrontSurface",
    "BackSurface"
}
_R["187_v1"] = {
    ParticleEmitter = true,
    Trail = true,
    Beam = true,
    Fire = true,
    Smoke = true,
    Sparkles = true,
    ForceField = true,
    Explosion = true,
    BloomEffect = true,
    BlurEffect = true,
    ColorCorrectionEffect = true,
    SunRaysEffect = true,
    DepthOfFieldEffect = true,
    Atmosphere = true,
    Decal = true,
    Texture = true,
    SurfaceAppearance = true,
    SpecialMesh = true,
    BlockMesh = true,
    CylinderMesh = true,
    PointLight = true,
    SpotLight = true,
    SurfaceLight = true,
    Accessory = true,
    Hat = true,
    Shirt = true,
    Pants = true,
    ShirtGraphic = true,
    CharacterMesh = true,
    BodyColors = true,
    Clothing = true,
    HumanoidDescription = true
}
_R["188_v1"] = {
    enabled = false,
    connections = {},
    processedObjects = setmetatable({}, { __mode = "k" }),
    origStates = {
        lighting = {},
        water = {},
        camera = {}
    }
}
_U["197_0"] = _R["188_v1"]
_U["197_1"] = _R["187_v1"]
_U["197_2"] = _R["175_v1"]
_U["197_3"] = _R["186_v1"]
_U["197_4"] = _R["174_v1"]
_optimizeObj = function(p1)
local l2, l3, l4, l5
    if not _U["197_0"].processedObjects[p1] then
        l2 = _U["197_0"].processedObjects
        l2[p1] = true
        if not _U["197_1"][p1.ClassName] then
            if p1:IsA("BasePart") then
                p1.Material = _U["197_2"]
                p1.CastShadow = false
                p1.Reflectance = 0
                l2 = 1
                l3 = 6
                l4 = 1
                for _i1 = l2, l3, l4 do
                    l5 = _i1
                    p1[_U["197_3"][l5]] = _U["197_4"]
                end
            end
            return
        else
            p1:Destroy()
            return
        end
    end
end
_U["313_0"] = _R["188_v1"]
_U["313_1"] = _R["187_v1"]
_U["313_2"] = _R["175_v1"]
_U["313_3"] = _R["186_v1"]
_U["313_4"] = _R["174_v1"]
_optimizeChar = function(p1)
local l2
    if p1 then
        if not _U["313_0"].processedObjects[p1] then
            l2 = _U["313_0"].processedObjects
            l2[p1] = true
            pcall(function()
            local u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11
                u1 = p1:GetDescendants()
                u2 = 1
                u3 = #u1
                u4 = 1
                for _i2 = u2, u3, u4 do
                    u5 = _i2
                    u6 = u1[u5]
                    if not _U["313_1"][u6.ClassName] then
                        if not u6:IsA("BasePart") then
                            if u6:IsA("Humanoid") then
                                u7 = u6:GetPlayingAnimationTracks()
                                u8 = 1
                                u9 = #u7
                                u10 = 1
                                for _i2 = u8, u9, u10 do
                                    u11 = _i2
                                    u7[u11]:Stop(0)
                                end
                                u6.HealthDisplayDistance = 0
                                u6.NameDisplayDistance = 0
                            end
                        else
                            if u6.Name == "Head" then
                                u6.Transparency = 1
                            end
                            u6.Material = _U["313_2"]
                            u6.CastShadow = false
                            u6.Reflectance = 0
                            u7 = u6.Name == "HumanoidRootPart"
                            if not u7 then
                                u7 = u6.Name == "Head"
                            end
                            u6.CanCollide = u7
                            u7 = 1
                            u8 = 6
                            u9 = 1
                            for _i2 = u7, u8, u9 do
                                u10 = _i2
                                u6[_U["313_3"][u10]] = _U["313_4"]
                            end
                        end
                    else
                        u6:Destroy()
                    end
                end
            end)
            return
        end
    end
end
_U["153_0"] = _R["188_v1"]
_potatoCleanup = function()
local l1, l2, l3, l4, l5
    l1 = _U["153_0"].connections
    l2 = 1
    l3 = #l1
    l4 = 1
    for _i1 = l2, l3, l4 do
        l5 = _i1
        pcall(l1[l5].Disconnect, l1[l5])
    end
    _U["153_0"].connections = {}
    _U["153_0"].processedObjects = setmetatable({}, { __mode = "k" })
end
_U["309_0"] = _R["170_v1"]
_U["309_1"] = _R["188_v1"]
_U["309_2"] = _R["171_v1"]
_U["309_3"] = _R["185_v1"]
_U["309_4"] = _R["176_v1"]
_U["309_5"] = _R["173_v1"]
_U["309_6"] = _R["183_v1"]
_U["309_7"] = _R["184_v1"]
_U["309_8"] = _R["177_v1"]
_U["309_9"] = _R["178_v1"]
_U["309_10"] = _R["182_v1"]
_U["309_11"] = _R["172_v1"]
_applyWorldSettings = function()
local _R_309 = {}
local l1, l2, l3, l4, l5, l6
    if _U["309_0"] then
        pcall(function()
        local u1
            u1 = _U["309_1"].origStates
            u1.water = {
                WaterReflectance = _U["309_0"].WaterReflectance,
                WaterWaveSize = _U["309_0"].WaterWaveSize,
                WaterWaveSpeed = _U["309_0"].WaterWaveSpeed,
                WaterTransparency = _U["309_0"].WaterTransparency
            }
            _U["309_0"].WaterWaveSize = 0
            _U["309_0"].WaterWaveSpeed = 0
            _U["309_0"].WaterReflectance = 0
            _U["309_0"].WaterTransparency = 1
            _U["309_0"].Decoration = false
        end)
        l1 = _U["309_0"]:FindFirstChildOfClass("Clouds")
        if l1 then
            l1:Destroy()
        end
    end
    pcall(function()
    local u1
        u1 = _U["309_1"].origStates
        u1.lighting = {
            GlobalShadows = _U["309_2"].GlobalShadows,
            Brightness = _U["309_2"].Brightness,
            Technology = _U["309_2"].Technology
        }
        _U["309_2"].GlobalShadows = false
        _U["309_2"].FogEnd = 9000000000
        _U["309_2"].Brightness = 0
        _U["309_2"].OutdoorAmbient = _U["309_3"]
        _U["309_2"].Ambient = _U["309_3"]
        _U["309_2"].Technology = _U["309_4"]
        _U["309_2"].EnvironmentDiffuseScale = 0
        _U["309_2"].EnvironmentSpecularScale = 0
        _U["309_2"].ShadowSoftness = 0
    end)
    l1 = _U["309_2"]:GetChildren()
    l2 = 1
    l3 = #l1
    l4 = 1
    for _i1 = l2, l3, l4 do
        l5 = _i1
        l6 = l1[l5]
        if l6:IsA("PostEffect") then
            pcall(l6.Destroy, l6)
        else
            if not l6:IsA("Atmosphere") then
                if l6:IsA("Sky") then
                    pcall(function()
                        l6.StarCount = 0
                        l6.SunAngularSize = 0
                        l6.MoonAngularSize = 0
                        l6.CelestialBodiesShown = false
                        l6.SkyboxBk = ""
                        l6.SkyboxDn = ""
                        l6.SkyboxFt = ""
                        l6.SkyboxLf = ""
                        l6.SkyboxRt = ""
                        l6.SkyboxUp = ""
                    end)
                end
            end
        end
    end
    pcall(function()
        _U["309_5"].AmbientReverb = _U["309_6"]
        _U["309_5"]:SetListener(_U["309_7"])
    end)
    pcall(function()
    local u1
        u1 = settings().Rendering
        u1.QualityLevel = _U["309_8"]
        u1.MeshPartDetailLevel = _U["309_9"]
        u1.EditQualityLevel = _U["309_8"]
    end)
    pcall(function()
    local u1
        u1 = UserSettings():GetService("UserGameSettings")
        u1.SavedQualityLevel = _U["309_10"]
    end)
    pcall(function()
    local u1, u2
        u1 = workspace.CurrentCamera
        if u1 then
            u2 = _U["309_1"].origStates
            u2.camera = { FieldOfView = u1.FieldOfView }
            u1.FieldOfView = 70
        end
    end)
    pcall(function()
        _U["309_11"]:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
    end)
end
_U["238_0"] = _R["170_v1"]
_U["238_1"] = _R["188_v1"]
_U["238_2"] = _R["171_v1"]
_U["238_3"] = _R["179_v1"]
_U["238_4"] = _R["180_v1"]
_U["238_5"] = _R["181_v1"]
_U["238_6"] = _R["172_v1"]
_restoreWorldSettings = function()
    if _U["238_0"] then
        if _U["238_1"].origStates.water.WaterReflectance ~= nil then
            pcall(function()
            local u1
                u1 = _U["238_1"].origStates.water
                _U["238_0"].WaterReflectance = u1.WaterReflectance
                _U["238_0"].WaterWaveSize = u1.WaterWaveSize
                _U["238_0"].WaterWaveSpeed = u1.WaterWaveSpeed
                _U["238_0"].WaterTransparency = u1.WaterTransparency
                _U["238_0"].Decoration = true
            end)
        end
    end
    pcall(function()
    local u1
        u1 = _U["238_1"].origStates.lighting
        if u1.GlobalShadows ~= nil then
            _U["238_2"].GlobalShadows = u1.GlobalShadows
            _U["238_2"].Brightness = u1.Brightness
            _U["238_2"].Technology = u1.Technology
        end
    end)
    pcall(function()
    local u1
        u1 = workspace.CurrentCamera
        if u1 then
            if _U["238_1"].origStates.camera.FieldOfView then
                u1.FieldOfView = _U["238_1"].origStates.camera.FieldOfView
            end
        end
    end)
    pcall(function()
    local u1
        u1 = settings().Rendering
        u1.QualityLevel = _U["238_3"]
        u1.MeshPartDetailLevel = _U["238_4"]
    end)
    pcall(function()
    local u1
        u1 = UserSettings():GetService("UserGameSettings")
        u1.SavedQualityLevel = _U["238_5"]
    end)
    pcall(function()
        _U["238_6"]:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        _U["238_6"]:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
    end)
    _U["238_1"].origStates = {
        lighting = {},
        water = {},
        camera = {}
    }
end
_U["132_0"] = _R["188_v1"]
BoosterSection:AddToggle({
    Title = "Reduce Map (Potato Mode)",
    Default = false,
    Callback = function(p1)
    local l2
        _U["132_0"].enabled = p1
        _potatoCleanup()
        if p1 then
            _applyWorldSettings()
            task.spawn(function()
            local u1, u2, u4, u5, u6, u7, u8, u9, u10, u11
                while true do
                    if not _U["132_0"].enabled then
                        break
                    end
                    _U["132_0"].processedObjects = setmetatable({}, { __mode = "k" })
                    u1 = workspace:GetDescendants()
                    u2 = #u1
                    u4 = 1
                    u5 = u2
                    u6 = 50
                    for _i2 = u4, u5, u6 do
                        u7 = _i2
                        if not _U["132_0"].enabled then
                            break
                        end
                        u8 = u7
                        u9 = math.min((u7 + 50) - 1, u2)
                        u10 = 1
                        for _i2 = u8, u9, u10 do
                            u11 = _i2
                            _optimizeObj(u1[u11])
                        end
                        task.wait()
                    end
                    if not _U["132_0"].enabled then
                        break
                    end
                    for _k2, _v2 in ipairs(Players:GetPlayers()) do
                        u5, u6 = _k2, _v2
                        if u6.Character then
                            task.defer(_optimizeChar, u6.Character)
                        end
                    end
                    u4 = 600
                    if 0 < u4 then
                        while true do
                            if not _U["132_0"].enabled then
                                break
                            end
                            task.wait(1)
                            u4 = u4 - 1
                            if 0 >= u4 then
                                break
                            end
                        end
                    end
                    if _U["132_0"].enabled then
                        pcall(_applyWorldSettings)
                    end
                end
            end)
            l2 = _U["132_0"].connections
            l2[(#_U["132_0"].connections) + 1] = Players.PlayerAdded:Connect(function(a1)
            local u2
                u2 = _U["132_0"].connections
                u2[(#_U["132_0"].connections) + 1] = a1.CharacterAdded:Connect(function(b1)
                    if _U["132_0"].enabled then
                        task.delay(0.2, function()
                            if _U["132_0"].enabled then
                                _optimizeChar(b1)
                            end
                        end)
                        return
                    end
                end)
                if a1.Character then
                    task.defer(_optimizeChar, a1.Character)
                end
            end)
            l2 = _U["132_0"].connections
            l2[(#_U["132_0"].connections) + 1] = LocalPlayer.CharacterAdded:Connect(function(a1)
                if _U["132_0"].enabled then
                    task.delay(0.2, function()
                        if _U["132_0"].enabled then
                            _optimizeChar(a1)
                        end
                    end)
                    return
                end
            end)
            l2 = _U["132_0"].connections
            l2[(#_U["132_0"].connections) + 1] = workspace.DescendantAdded:Connect(function(a1)
                if _U["132_0"].enabled then
                    _optimizeObj(a1)
                    return
                end
            end)
            return
        else
            _restoreWorldSettings()
            return
        end
    end
})
_R["170_v2"] = false
_R["173_v2"] = {
    Title = "Remove Other Player",
    Content = "This feature will hide other player from ur visual"
}
_R["174_v2"] = _R["170_v2"]
if not _R["174_v2"] then
    _R["174_v2"] = false
end
_R["173_v2"].Default = _R["174_v2"]
_R["173_v2"].Callback = function(p1)
local l2, l3, l4, l5, l6
    _R["170_v2"] = p1
    l2 = function(a1, a2)
    local u3, u4, u5, u6
        for _k2, _v2 in pairs(a1:GetDescendants()) do
            u4, u5 = _k2, _v2
            if u5:IsA("BasePart") then
                u6 = a2
                if u6 then
                    u6 = 1
                end
                if not u6 then
                    u6 = 0
                end
                u5.LocalTransparencyModifier = u6
            end
        end
    end
    l3 = function(a1)
        a1.CharacterAdded:Connect(function(b1)
            if _R["170_v2"] then
                task.wait(0.5)
                l2(b1, true)
            end
        end)
        if a1.Character then
            l2(a1.Character, _R["170_v2"])
        end
    end
    for _k1, _v1 in pairs(game.Players:GetPlayers()) do
        l5, l6 = _k1, _v1
        if l6 ~= game.Players.LocalPlayer then
            l3(l6)
            if l6.Character then
                l2(l6.Character, p1)
            end
        end
    end
end
_R["171_v2"](_R["172_v2"], _R["173_v2"])
UtilitySection = v43.Misc:AddSection("Player Utility")
_R["171_v2"] = false
_R["172_v2"] = nil
_R["173_v2"] = {}
_R["174_v2"] = false
_R["175_v2"] = nil
_R["176_v2"] = nil
_R["177_v2"] = nil
_R["178_v2"] = nil
_R["179_v2"] = 0
_R["181_v2"] = false
_R["182_v2"] = 16
_R["183_v2"] = false
_R["184_v2"] = nil
findWaterHeight = function(p1)
local l2, l3, l4
    RaycastParams.new().FilterType = Enum.RaycastFilterType.Include
    l2.FilterDescendantsInstances = { workspace.Terrain }
    l2.IgnoreWater = false
    l3 = l3(l4, Vector3.new(p1.X, p1.Y + 10, p1.Z), Vector3.new(0, -200, 0), l2)
    if not l3 then
        return nil
    else
        if l3.Material == Enum.Material.Water then
            return l3.Position.Y
        end
    end
end
ensurePart = function()
    if not _R["175_v2"] then
        _R["175_v2"] = Instance.new("Part")
        _R["175_v2"].Name = "WW_Part"
        _R["175_v2"].Size = Vector3.new(40, 0.2, 40)
        _R["175_v2"].Anchored = true
        _R["175_v2"].CanCollide = false
        _R["175_v2"].Transparency = 1
        _R["175_v2"].Material = Enum.Material.SmoothPlastic
        _R["175_v2"].Parent = workspace
        return
    else
        if _R["175_v2"].Parent then
            return
        end
    end
end
cleanup = function()
    if _R["176_v2"] then
        _R["176_v2"]:Disconnect()
        _R["176_v2"] = nil
    end
    if _R["175_v2"] then
        _R["175_v2"]:Destroy()
        _R["175_v2"] = nil
    end
    _R["177_v2"] = nil
    _R["178_v2"] = nil
end
startLoop = function()
local l1, l2
    l1 = LocalPlayer.Character
    if not l1 then
        l1 = LocalPlayer.CharacterAdded:Wait()
    end
    l2 = l1:WaitForChild("HumanoidRootPart")
    ensurePart()
    _R["177_v2"] = findWaterHeight(l2.Position)
    _R["178_v2"] = l2.Position
    _R["176_v2"] = RunService.Heartbeat:Connect(function()
    local u1, u2, u3, u4, u5, u6, u7, u8
        if _R["174_v2"] then
            u1 = LocalPlayer.Character
            if u1 then
                u2 = u1:FindFirstChild("HumanoidRootPart")
                if u2 then
                    u3 = u2.Position
                    u4 = tick()
                    u5 = _R["178_v2"]
                    if u5 then
                        u5 = ((u3 - _R["178_v2"])).Magnitude > 30
                    end
                    u6 = (u4 - _R["179_v2"]) > 0.4
                    if u5 then
                        u7 = findWaterHeight(u3)
                        if u7 then
                            _R["177_v2"] = u7
                        end
                        _R["178_v2"] = u3
                        _R["179_v2"] = u4
                    end
                    if _R["177_v2"] then
                        ensurePart()
                        _R["175_v2"].Position = Vector3.new(u3.X, _R["177_v2"] + 0.1, u3.Z)
                        u7 = u3.Y
                        u8 = u7 > (_R["177_v2"] - 0.5)
                        if u8 then
                            u8 = u7 < (_R["177_v2"] + 6)
                        end
                        _R["175_v2"].CanCollide = u8
                        return
                    end
                end
            end
        end
    end)
end
_R["185_v2"] = nil
onCharAdded = function(p1)
    if _R["174_v2"] then
        task.wait(1)
        if _R["174_v2"] then
            cleanup()
            startLoop()
        end
        return
    end
end
UtilitySection:AddButton({
    Title = "Reedem All Active Codes",
    Callback = function()
    local l1
        l1 = game:GetService("ReplicatedStorage").events.runcode
        task.spawn(function()
        local u1, u2, u3, u4, u5, u6, u7
            u1, u2 = pcall(function()
                return game:HttpGet("https://fischipedia.org/wiki/Codes")
            end)
            if u1 then
                u3 = {}
                u4 = false
                for _k2, _v2 in u2:gmatch("[^\n]+") do
                    u6, u7 = _k2, _v2
                    if u6:find("Active Codes") then
                        u4 = true
                    end
                    u7 = u6:find("Inactive Codes")
                    if u7 then
                        u4 = false
                    end
                    if u4 then
                        u7 = u6:match("<td>([A-Za-z0-9]+)</td>")
                        if u7 then
                            table.insert(u3, u7)
                        end
                    end
                end
                if (#u3) ~= 0 then
                    for _k2, _v2 in ipairs(u3) do
                        u6, u7 = _k2, _v2
                        l1:FireServer(u7)
                        task.wait(0.1)
                    end
                    return
                else
                    warn("Codes not found")
                    return
                end
            else
                warn("Gagal fetch wiki:", u2)
                return
            end
        end)
    end
})
UtilitySection:AddButton({
    Title = "Discovery All Locations",
    Callback = function()
    local l1, l3, l4, l5, l6, l7
        l1 = game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("discoverlocation")
        l3 = {}
        for _k1, _v1 in pairs(workspace:WaitForChild("zones"):WaitForChild("fishing"):GetChildren()) do
            l5, l6 = _k1, _v1
            l7 = l6.Name
            if not l3[l7] then
                l3[l7] = true
                l1:FireServer(l7)
                task.wait(0.1)
            end
        end
    end
})
UtilitySection:AddDivider()
UtilitySection:AddToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(p1)
    local _R_409 = {}
    local _U_409 = {}
    local l2, l3, l4, l5, l6, l7, l8
        l2 = v20
        if l2 then
            l2 = v19
            if not l2 then
                _R["171_v2"] = p1
                l2 = _R["172_v2"]
                if l2 then
                    _R["172_v2"]:Disconnect()
                    _R["172_v2"] = nil
                end
                if not p1 then
                    l2 = LocalPlayer.Character
                    if l2 then
                        l3 = l2:FindFirstChildOfClass("Humanoid")
                        l4 = l2:FindFirstChild("HumanoidRootPart")
                        if l4 then
                            l5 = l4.AssemblyLinearVelocity.Y
                            l4.AssemblyLinearVelocity = Vector3.new(0, math.clamp(l5, -50, 0), 0)
                            l4.AssemblyAngularVelocity = Vector3.zero
                        end
                        l5 = {}
                        for _k1, _v1 in pairs(l2:GetDescendants()) do
                            l7, l8 = _k1, _v1
                            if l8:IsA("BasePart") then
                                if not l8.Anchored then
                                    l5[l8] = true
                                    l8.Anchored = true
                                end
                            end
                        end
                        for _k1, _v1 in pairs(l2:GetDescendants()) do
                            l7, l8 = _k1, _v1
                            if l8:IsA("BasePart") then
                                if _R["173_v2"][l8] == nil then
                                    l8.CanCollide = true
                                else
                                    l8.CanCollide = _R["173_v2"][l8]
                                end
                            end
                        end
                        _U_409["471_0"] = l2
                        _U_409["471_1"] = l5
                        _U_409["471_2"] = l3
                        task.defer(function()
                        local u1, u2, u3
                            if _U_409["471_0"] then
                                if _U_409["471_0"].Parent then
                                    for _k2, _v2 in pairs(_U_409["471_1"]) do
                                        u2, u3 = _k2, _v2
                                        if u2 then
                                            if u2.Parent then
                                                u2.Anchored = false
                                            end
                                        end
                                    end
                                    if _U_409["471_2"] then
                                        if _U_409["471_2"].Parent then
                                            _U_409["471_2"]:ChangeState(Enum.HumanoidStateType.GettingUp)
                                        end
                                    end
                                    return
                                end
                            end
                        end)
                        _R["173_v2"] = {}
                        return
                    else
                        l3 = {}
                        _R["173_v2"] = l3
                        return
                    end
                else
                    _R["173_v2"] = {}
                    l2 = LocalPlayer.Character
                    if l2 then
                        for _k1, _v1 in pairs(l2:GetDescendants()) do
                            l4, l5 = _k1, _v1
                            if l5:IsA("BasePart") then
                                _R["173_v2"][l5] = l5.CanCollide
                            end
                        end
                    end
                    l5 = function()
                    local u1, u2, u3, u4
                        u1 = LocalPlayer.Character
                        if u1 then
                            for _k2, _v2 in pairs(u1:GetDescendants()) do
                                u3, u4 = _k2, _v2
                                if u4:IsA("BasePart") then
                                    u4.CanCollide = false
                                end
                            end
                            return
                        end
                    end
                    l3 = game:GetService("RunService").Heartbeat:Connect(l5)
                    _R["172_v2"] = l3
                    return
                end
            end
        end
    end
})
ApplyWalkspeed = function()
local l1, l2
    if _R["183_v2"] then
        l1 = LocalPlayer.Character
        if l1 then
            l2 = l1:FindFirstChild("Humanoid")
            if l2 then
                if l2.WalkSpeed ~= _R["182_v2"] then
                    l2.WalkSpeed = _R["182_v2"]
                end
            end
        end
        return
    end
end
ToggleWalkspeedLoop = function(p1)
local l2, l3
    if _R["184_v2"] then
        _R["184_v2"]:Disconnect()
        _R["184_v2"] = nil
    end
    if not p1 then
        l2 = LocalPlayer.Character
        if l2 then
            l3 = l2:FindFirstChild("Humanoid")
            if l3 then
                l3.WalkSpeed = 16
            end
        end
    else
        _R["184_v2"] = RunService.Heartbeat:Connect(ApplyWalkspeed)
    end
end
LocalPlayer.CharacterAdded:Connect(function(p1)
    if _R["183_v2"] then
        task.wait(0.5)
        ApplyWalkspeed()
    end
end)
UtilitySection:AddSlider({
    Title = "Walkspeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(p1)
        _R["182_v2"] = p1
        if _R["183_v2"] then
            ApplyWalkspeed()
        end
    end
})
UtilitySection:AddToggle({
    Title = "Enable Walkspeed",
    Default = false,
    Callback = function(p1)
        _R["183_v2"] = p1
        ToggleWalkspeedLoop(p1)
    end
})
_R["186_v2"] = nil
UtilitySection:AddToggle({
    Title = "Full Brightness",
    Default = false,
    Callback = function(p1)
        if v20 then
            if not v19 then
                if not p1 then
                    if _R["186_v2"] then
                        _R["186_v2"]:Disconnect()
                    end
                else
                    if _R["186_v2"] then
                        _R["186_v2"]:Disconnect()
                    end
                    _R["186_v2"] = game:GetService("RunService").RenderStepped:Connect(function()
                        Lighting.Brightness = 2
                        Lighting.ClockTime = 14
                        Lighting.FogEnd = 100000
                        Lighting.GlobalShadows = false
                        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                    end)
                end
                return
            end
        end
    end
})
_R["187_v2"] = nil
UtilitySection:AddToggle({
    Title = "Freeze Player",
    Default = false,
    Callback = function(p1)
    local _R_151 = {}
    local _U_151 = {}
    local l2, l3, l4
        l2 = game.Players.LocalPlayer.Character
        l3 = l2
        if l3 then
            l3 = l2:FindFirstChild("HumanoidRootPart")
        end
        l4 = _R["187_v2"]
        if l4 then
            _R["187_v2"]:Disconnect()
            _R["187_v2"] = nil
        end
        if p1 then
            if l3 then
                l4 = l3.CFrame
                _U_151["205_0"] = l3
                _U_151["205_1"] = l4
                _R["187_v2"] = game:GetService("RunService").Heartbeat:Connect(function()
                    if not _U_151["205_0"] then
                        if _R["187_v2"] then
                            _R["187_v2"]:Disconnect()
                        end
                    else
                        if _U_151["205_0"].Parent then
                            _U_151["205_0"].Velocity = Vector3.new(0, 0, 0)
                            _U_151["205_0"].RotVelocity = Vector3.new(0, 0, 0)
                            _U_151["205_0"].CFrame = _U_151["205_1"]
                        end
                    end
                end)
            end
        end
    end
})
_R["188_v2"] = nil
UtilitySection:AddToggle({
    Title = "Anti Swim / Infinite Oxygen",
    Default = false,
    Callback = function(p1)
    local _U_129 = {}
    local l2, l3
        l2 = LocalPlayer.Character
        if not l2 then
            l2 = LocalPlayer.CharacterAdded:Wait()
        end
        l3 = _G
        l3.AntiSwim = p1
        if not _G.AntiSwim then
            if _R["188_v2"] then
                _R["188_v2"]:Disconnect()
                _R["188_v2"] = nil
            end
            if l2:FindFirstChildOfClass("Humanoid") then
                l2:FindFirstChildOfClass("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            end
        else
            _U_129["445_0"] = l2
            _R["188_v2"] = RunService.Heartbeat:Connect(function()
            local u1
                if _U_129["445_0"]:FindFirstChildOfClass("Humanoid") then
                    u1 = _U_129["445_0"]:FindFirstChildOfClass("Humanoid")
                    if u1:GetState() == Enum.HumanoidStateType.Swimming then
                        u1:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                        u1:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
    end
})
UtilitySection:AddToggle({
    Title = "Walk on Water",
    Default = false,
    Callback = function(p1)
        _R["174_v2"] = p1
        if not p1 then
            if _R["185_v2"] then
                _R["185_v2"]:Disconnect()
                _R["185_v2"] = nil
            end
            cleanup()
            return
        else
            if _R["185_v2"] then
                _R["185_v2"]:Disconnect()
            end
            _R["185_v2"] = LocalPlayer.CharacterAdded:Connect(onCharAdded)
            startLoop()
            return
        end
    end
})
UtilitySection:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(p1)
        _R["181_v2"] = p1
    end
})
UserInputService.JumpRequest:Connect(function()
    if _R["181_v2"] then
        if LocalPlayer.Character then
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)
hideConnections = {}
UtilitySection:AddToggle({
    Title = "Hide Character",
    Default = false,
    Callback = function(p1)
    local l2, l3, l4, l5
        for _k1, _v1 in ipairs(hideConnections) do
            l3, l4 = _k1, _v1
            l4:Disconnect()
        end
        hideConnections = {}
        l2 = LocalPlayer.Character
        if l2 then
            isRod = function(a1)
            local u2
                u2 = a1
                if not u2 then
                    return false
                else
                    while true do
                        if not u2:IsA("Tool") then
                            u2 = u2.Parent
                            if not u2 then
                                break
                            end
                        else
                            return true
                        end
                    end
                end
            end
            lockPart = function(a1)
                if not isRod(a1) then
                    if a1:IsA("BasePart") then
                        a1.LocalTransparencyModifier = 1
                        table.insert(hideConnections, a1:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
                            a1.LocalTransparencyModifier = 1
                        end))
                    end
                    return
                end
            end
            if not p1 then
                for _k1, _v1 in ipairs(hideConnections) do
                    l4, l5 = _k1, _v1
                    l5:Disconnect()
                end
                hideConnections = {}
                for _k1, _v1 in ipairs(l2:GetDescendants()) do
                    l4, l5 = _k1, _v1
                    if l5:IsA("BasePart") then
                        l5.LocalTransparencyModifier = 0
                    end
                end
                return
            else
                for _k1, _v1 in ipairs(l2:GetDescendants()) do
                    l4, l5 = _k1, _v1
                    lockPart(l5)
                end
                table.insert(hideConnections, l2.DescendantAdded:Connect(function(a1)
                    lockPart(a1)
                end))
                return
            end
        end
    end
})
defaultZoom = 128
zoomConn = nil
MaxZoomToggle = UtilitySection:AddToggle({
    Title = "Max Zoom 1000",
    Content = "Increase max camera distance",
    Default = false,
    Callback = function(p1)
    local l2
        l2 = Players.LocalPlayer
        if zoomConn then
            zoomConn:Disconnect()
            zoomConn = nil
        end
        if not p1 then
            l2.CameraMaxZoomDistance = defaultZoom
            l2.CameraMinZoomDistance = 0.5
            return
        else
            l2.CameraMaxZoomDistance = 1000
            l2.CameraMinZoomDistance = 0.5
            zoomConn = l2.CharacterAdded:Connect(function()
                task.wait(0.3)
                l2.CameraMaxZoomDistance = 1000
                l2.CameraMinZoomDistance = 0.5
            end)
            return
        end
    end
})
_R["171_v3"] = false
_R["173_v3"] = 1
_R["174_v3"] = nil
_R["175_v3"] = nil
getRoot = function(p1)
local l2
    l2 = p1:FindFirstChild("HumanoidRootPart")
    if not l2 then
        l2 = p1:FindFirstChild("Torso")
    end
    if not l2 then
        l2 = p1:FindFirstChild("UpperTorso")
    end
    return l2
end
NOFLY = function()
local l1, l2, l3, l4, l5, l6
    _R["171_v3"] = false
    l1 = LocalPlayer.Character
    if l1 then
        l2 = l1:FindFirstChildOfClass("Humanoid")
        if l2 then
            l2.PlatformStand = false
        end
        l3 = l1:FindFirstChild("HumanoidRootPart")
        if l3 then
            for _k1, _v1 in pairs(l3:GetChildren()) do
                l5, l6 = _k1, _v1
                if l6:IsA("BodyGyro") then
                    l6:Destroy()
                end
            end
        end
    end
end
sFLY = function(p1)
local _U_293 = {}
local l2, l3, l4, l5, l6, l7, l8
    l2 = LocalPlayer
    l3 = l2.Character
    if not l3 then
        l3 = l2.CharacterAdded:Wait()
    end
    l6 = "Humanoid"
    l4 = l3:FindFirstChildOfClass(l6)
    if not l4 then
        l6 = "Humanoid"
        l4 = l3:WaitForChild(l6)
    end
    l5 = getRoot(l3)
    l6 = {
        F = 0,
        B = 0,
        L = 0,
        R = 0,
        Q = 0,
        E = 0
    }
    l7 = {
        F = 0,
        B = 0,
        L = 0,
        R = 0,
        Q = 0,
        E = 0
    }
    l8 = 0
    if _R["174_v3"] then
        _R["174_v3"]:Disconnect()
    end
    if _R["175_v3"] then
        _R["175_v3"]:Disconnect()
    end
    _U_293["423_3"] = l4
    _U_293["423_5"] = l6
    FLY = function()
    local u1, u2, u3
        _R["171_v3"] = true
        u1 = Instance.new("BodyGyro")
        u2 = Instance.new("BodyVelocity")
        u3 = Vector3.new(9000000000, 9000000000, 9000000000)
        u1.P = 90000
        u1.MaxTorque = u3
        u1.CFrame = l5.CFrame
        u1.Parent = l5
        u2.Parent = l5
        u2.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
        task.spawn(function()
        local w1, w2
            while true do
                task.wait()
                w1 = workspace.CurrentCamera
                if not p1 then
                    _U_293["423_3"].PlatformStand = true
                end
                w2 = (_U_293["423_5"].L + _U_293["423_5"].R) ~= 0
                if not w2 then
                    w2 = (_U_293["423_5"].F + _U_293["423_5"].B) ~= 0
                end
                if not w2 then
                    w2 = (_U_293["423_5"].Q + _U_293["423_5"].E) ~= 0
                end
                if w2 then
                    w2 = _R["173_v3"] * 50
                end
                if not w2 then
                    w2 = 0
                end
                l8 = w2
                if l8 == 0 then
                    u2.Velocity = Vector3.zero
                    u1.CFrame = w1.CFrame
                    if not _R["171_v3"] then
                        break
                    end
                else
                    u2.Velocity = ((w1.CFrame.LookVector * (_U_293["423_5"].F + _U_293["423_5"].B)) + ((w1.CFrame * CFrame.new(_U_293["423_5"].L + _U_293["423_5"].R, (((_U_293["423_5"].F + _U_293["423_5"].B) + _U_293["423_5"].Q) + _U_293["423_5"].E) * 0.2, 0).p) - w1.CFrame.p)) * l8
                    l7 = {
                        F = _U_293["423_5"].F,
                        B = _U_293["423_5"].B,
                        L = _U_293["423_5"].L,
                        R = _U_293["423_5"].R
                    }
                    u1.CFrame = w1.CFrame
                    if not _R["171_v3"] then
                        break
                    end
                end
            end
            u1:Destroy()
            u2:Destroy()
            _U_293["423_3"].PlatformStand = false
        end)
    end
    _U_293["184_0"] = l6
    _R["174_v3"] = UserInputService.InputBegan:Connect(function(a1)
    local u2
        u2 = a1.KeyCode
        if u2 ~= Enum.KeyCode.W then
            if u2 ~= Enum.KeyCode.S then
                if u2 ~= Enum.KeyCode.A then
                    if u2 ~= Enum.KeyCode.D then
                        if u2 ~= Enum.KeyCode.E then
                            if u2 == Enum.KeyCode.Q then
                                if true then
                                    _U_293["184_0"].E = -1
                                end
                            end
                        else
                            if true then
                                _U_293["184_0"].Q = 1
                            end
                        end
                    else
                        _U_293["184_0"].R = 1
                    end
                else
                    _U_293["184_0"].L = -1
                end
            else
                _U_293["184_0"].B = -1
            end
        else
            _U_293["184_0"].F = 1
        end
    end)
    _U_293["402_0"] = l6
    _R["175_v3"] = UserInputService.InputEnded:Connect(function(a1)
    local u2
        u2 = a1.KeyCode
        if u2 ~= Enum.KeyCode.W then
            if u2 ~= Enum.KeyCode.S then
                if u2 ~= Enum.KeyCode.A then
                    if u2 ~= Enum.KeyCode.D then
                        if u2 ~= Enum.KeyCode.E then
                            if u2 == Enum.KeyCode.Q then
                                _U_293["402_0"].E = 0
                            end
                        else
                            _U_293["402_0"].Q = 0
                        end
                    else
                        _U_293["402_0"].R = 0
                    end
                else
                    _U_293["402_0"].L = 0
                end
            else
                _U_293["402_0"].B = 0
            end
        else
            _U_293["402_0"].F = 0
        end
    end)
    FLY()
end
mobilefly = function(p1)
local l2, l3, l4, l5, l6, l7, l8
    _R["171_v3"] = true
    l2 = p1.Character
    if not l2 then
        l2 = p1.CharacterAdded:Wait()
    end
    l3 = l2:WaitForChild("HumanoidRootPart")
    l4 = l2:FindFirstChildOfClass("Humanoid")
    l5 = workspace.CurrentCamera
    l6 = require(p1:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    l7 = Instance.new("BodyVelocity")
    l8 = Instance.new("BodyGyro")
    l7.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
    l8.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
    l8.P = 1000
    l8.D = 50
    l7.Parent = l3
    l8.Parent = l3
    l4.PlatformStand = true
    task.spawn(function()
    local u1
        while true do
            if not _R["171_v3"] then
                break
            end
            if not task.wait() then
                break
            end
            u1 = l6:GetMoveVector()
            l8.CFrame = l5.CFrame
            l7.Velocity = ((l5.CFrame.RightVector * u1.X) + (l5.CFrame.LookVector * (-u1.Z))) * (_R["173_v3"] * 50)
        end
        l4.PlatformStand = false
        l7:Destroy()
        l8:Destroy()
    end)
end
UtilitySection:AddSubSection("Fly Features")
UtilitySection:AddSlider({
    Title = "Fly Speed",
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(p1)
        _R["173_v3"] = p1
    end
})
UtilitySection:AddToggle({
    Title = "Enable Fly",
    Default = false,
    Callback = function(p1)
        if v20 then
            if not v19 then
                if not p1 then
                    NOFLY()
                    return
                else
                    if not UserInputService.TouchEnabled then
                        sFLY()
                        return
                    else
                        mobilefly(LocalPlayer)
                        return
                    end
                end
            end
        end
    end
})
MiscSection = v43.Misc:AddSection("Misc")
_R["176_v3"] = nil
MiscSection:AddToggle({
    Title = "Auto Friend Request",
    Content = "Automatically send friend requests to all players in server.",
    Default = false,
    Callback = function(p1)
    local l2
        l2 = _G
        l2.AutoFriend = p1
        if p1 then
            task.spawn(function()
            local _R_133 = {}
            local _U_133 = {}
            local u1, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12
                u1 = game.Players.LocalPlayer
                u3 = 0
                u4 = 0
                u5 = 0
                for _k2, _v2 in ipairs(game:GetService("Players"):GetPlayers()) do
                    u7, u8 = _k2, _v2
                    if not _G.AutoFriend then
                        break
                    end
                    if u8 ~= u1 then
                        _U_133["425_1"] = u8
                        u9, u10 = pcall(function()
                            return u1:IsFriendsWith(_U_133["425_1"].UserId)
                        end)
                        if not u9 then
                            _U_133["412_1"] = u8
                            u11, u12 = pcall(function()
                                u1:RequestFriendship(_U_133["412_1"])
                            end)
                            if not u11 then
                                u5 = u5 + 1
                                task.wait(5)
                            else
                                u3 = u3 + 1
                                task.wait(5)
                            end
                        else
                            if u10 then
                                u4 = u4 + 1
                            end
                        end
                    end
                end
            end)
        end
    end
})
MiscSection:AddToggle({
    Title = "Auto Accept Friend Request",
    Default = false,
    Callback = function(p1)
    local _R_397 = {}
    local l3, l4, l5
        if not p1 then
            if _R["176_v3"] then
                _R["176_v3"]:Disconnect()
                _R["176_v3"] = nil
            end
        else
            l3 = game:GetService("CoreGui"):WaitForChild("RobloxGui"):WaitForChild("NotificationFrame")
            l4 = game:GetService("GuiService")
            l5 = game:GetService("VirtualInputManager")
            _R["176_v3"] = l3.ChildAdded:Connect(function(a1)
            local u2
                task.wait(0.2)
                u2 = a1:FindFirstChild("Button1")
                if u2 then
                    if u2.Text == "Accept" then
                        l4.SelectedObject = u2
                        task.wait(0.1)
                        l5:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        l5:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        l4.SelectedObject = nil
                    end
                end
            end)
        end
    end
})
VisualSection = v43.Misc:AddSection("Visual/ESP Features")
_R["177_v3"] = false
_R["178_v3"] = false
_R["179_v3"] = false
createESP = function(p1, p2, p3)
local l4, l5, l6
    if not p1:FindFirstChild("VisualESP") then
        l4 = Instance.new("BillboardGui")
        l4.Name = "VisualESP"
        l4.AlwaysOnTop = true
        l4.Size = UDim2.new(0, 100, 0, 50)
        l5 = p1:FindFirstChild("Head")
        if not l5 then
            l5 = p1:FindFirstChildWhichIsA("BasePart")
        end
        l4.Adornee = l5
        l4.ExtentsOffset = Vector3.new(0, 3, 0)
        l4.Parent = p1
        l5 = Instance.new("TextLabel")
        l5.Parent = l4
        l5.BackgroundTransparency = 1
        l5.Size = UDim2.new(1, 0, 1, 0)
        l5.Text = p2
        l5.TextColor3 = p3
        l5.TextStrokeTransparency = 0
        l5.TextScaled = true
        l5.Font = Enum.Font.SourceSansBold
        l6 = Instance.new("Highlight")
        l6.Name = "VisualESP_Highlight"
        l6.Adornee = p1
        l6.OutlineColor = p3
        l6.OutlineTransparency = 0
        l6.FillColor = p3
        l6.FillTransparency = 0.8
        l6.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        l6.Parent = p1
        return
    end
end
createEventESP = function(p1, p2, p3)
local _U_324 = {}
local l4, l5, l6
    l6 = "VisualESP"
    l4 = p1:FindFirstChild(l6)
    if not l4 then
        l4 = Instance.new("BillboardGui")
        l4.Name = "VisualESP"
        l4.AlwaysOnTop = true
        l4.Size = UDim2.new(0, 200, 0, 60)
        l4.Adornee = p1
        l4.StudsOffset = Vector3.new(0, 10, 0)
        l4.Parent = p1
        l5 = Instance.new("TextLabel")
        l5.Parent = l4
        l5.BackgroundTransparency = 1
        l5.Size = UDim2.new(1, 0, 0.6, 0)
        l5.Text = p2
        l5.TextColor3 = p3
        l5.TextStrokeTransparency = 0
        l5.TextSize = 18
        l5.Font = Enum.Font.SourceSansBold
        l6 = Instance.new("TextLabel")
        l6.Parent = l4
        l6.BackgroundTransparency = 1
        l6.Size = UDim2.new(1, 0, 0.4, 0)
        l6.Position = UDim2.new(0, 0, 0.6, 0)
        l6.Text = "0 studs"
        l6.TextColor3 = Color3.fromRGB(255, 255, 255)
        l6.TextStrokeTransparency = 0
        l6.TextSize = 14
        l6.Font = Enum.Font.SourceSans
        _U_324["204_0"] = l4
        _U_324["204_4"] = l6
        task.spawn(function()
            while true do
                if not _U_324["204_0"].Parent then
                    break
                end
                if not _R["179_v3"] then
                    break
                end
                if LocalPlayer.Character then
                    if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        _U_324["204_4"].Text = string.format("%.0f studs", ((LocalPlayer.Character.HumanoidRootPart.Position - p1.Position)).Magnitude)
                    end
                end
                task.wait(0.5)
            end
        end)
        return
    end
end
clearNPCEsp = function()
local l1, l2, l3
    for _k1, _v1 in pairs(workspace.world.npcs:GetDescendants()) do
        l2, l3 = _k1, _v1
        if l3.Name == "VisualESP" then
            l3:Destroy()
        end
    end
end
clearPlayerEsp = function()
local l1, l2, l3, l4, l5, l6
    for _k1, _v1 in pairs(game.Players:GetPlayers()) do
        l2, l3 = _k1, _v1
        if l3.Character then
            for _k1, _v1 in pairs(l3.Character:GetChildren()) do
                l5, l6 = _k1, _v1
                if l6.Name == "VisualESP" then
                    l6:Destroy()
                end
            end
        end
    end
end
clearEventEsp = function()
local l2, l3, l4
    for _k1, _v1 in pairs(workspace:WaitForChild("zones"):WaitForChild("fishing"):GetDescendants()) do
        l3, l4 = _k1, _v1
        if l4.Name == "VisualESP" then
            l4:Destroy()
        end
    end
end
refreshNPCEsp = function()
local l2, l3, l4, l5, l6, l7, l8
    if _R["177_v3"] then
        for _k1, _v1 in pairs({
            "Construction NPC's",
            "Fischgiving NPC's",
            "Valentides NPCs",
            "Appraiser",
            "Arnold",
            "Captain Ahab",
            "Daisy",
            "Fisher",
            "Henry",
            "Idle Fishing NPC Moosewood",
            "Idle Fishing NPC Moosewood2",
            "Inn Keeper",
            "Latern Keeper",
            "Lucas",
            "Marc Merchant",
            "Marley",
            "Marlon Friend",
            "Mods Lantern Keeper",
            "Moosewood Angler",
            "Moosewood Shipwright",
            "Paul",
            "Phineas",
            "Pierre",
            "Quiet Synph",
            "Sage",
            "Spirit of Light",
            "Willow"
        }) do
            l3, l4 = _k1, _v1
            l5 = workspace.world.npcs:FindFirstChild(l4)
            if l5 then
                if not l5:IsA("Model") then
                    if l5:IsA("Folder") then
                        for _k1, _v1 in pairs(l5:GetChildren()) do
                            l7, l8 = _k1, _v1
                            if l8:IsA("Model") then
                                createESP(l8, l8.Name, Color3.fromRGB(255, 200, 0))
                            end
                        end
                    end
                else
                    createESP(l5, l4, Color3.fromRGB(255, 255, 0))
                end
            end
        end
        return
    end
end
refreshPlayerEsp = function()
local l1, l2, l3
    if _R["178_v3"] then
        for _k1, _v1 in pairs(game.Players:GetPlayers()) do
            l2, l3 = _k1, _v1
            if l3 ~= game.Players.LocalPlayer then
                if l3.Character then
                    createESP(l3.Character, l3.Name, Color3.fromRGB(255, 255, 255))
                end
            end
        end
        return
    end
end
_U["199_1"] = SnapReelConfig
refreshEventEsp = function()
local l1, l2, l3, l4, l5
    if _R["179_v3"] then
        l1 = workspace:WaitForChild("zones"):WaitForChild("fishing")
        for _k1, _v1 in ipairs(_U["199_1"]) do
            l3, l4 = _k1, _v1
            l5 = l1:FindFirstChild(l4)
            if l5 then
                if l5:IsA("BasePart") then
                    createEventESP(l5, l4, Color3.fromRGB(0, 255, 255))
                end
            end
        end
        return
    end
end
task.spawn(function()
    while true do
        if not task.wait(5) then
            break
        end
        if _R["177_v3"] then
            refreshNPCEsp()
        end
        if _R["178_v3"] then
            refreshPlayerEsp()
        end
        if _R["179_v3"] then
            refreshEventEsp()
        end
    end
end)
VisualSection:AddToggle({
    Title = "Character ESP",
    Default = false,
    Callback = function(p1)
        _R["178_v3"] = p1
        if p1 then
            refreshPlayerEsp()
            return
        else
            clearPlayerEsp()
            return
        end
    end
})
VisualSection:AddToggle({
    Title = "NPC ESP",
    Default = false,
    Callback = function(p1)
        _R["177_v3"] = p1
        if p1 then
            refreshNPCEsp()
            return
        else
            clearNPCEsp()
            return
        end
    end
})
VisualSection:AddToggle({
    Title = "Zone Event ESP",
    Default = false,
    Callback = function(p1)
        _R["179_v3"] = p1
        if p1 then
            refreshEventEsp()
            return
        else
            clearEventEsp()
            return
        end
    end
})
VisualSection:AddSubSection("Avatar Changer")
_R["180_v3"] = false
_R["181_v3"] = nil
LoadAsetKeKarakter = function(p1, p2, p3)
local l4, l5, l6, l7, l8, l9, l10, l11, l12
    l4 = p1:GetChildren()
    ApplyMesh = function(a1)
    local u2, u3
        if a1:IsA("CharacterMesh") then
            u2 = p2:FindFirstChild(a1.Name)
            if u2 then
                if u2.ClassName == a1.ClassName then
                    u2:Destroy()
                end
            end
            u3 = a1:Clone()
            u3.Parent = p2
        end
    end
    for _k1, _v1 in pairs(l4) do
        l6, l7 = _k1, _v1
        if l7:IsA("Folder") then
            for _k1, _v1 in pairs(l7:GetChildren()) do
                l9, l10 = _k1, _v1
                ApplyMesh(l10)
            end
        else
            if not l7:IsA("Model") then
                ApplyMesh(l7)
            end
        end
    end
    for _k1, _v1 in pairs(l4) do
        l6, l7 = _k1, _v1
        if not l7:IsA("SpecialMesh") then
            if l7:IsA("Decal") then
                if l7.Name == "face" then
                    if p3 then
                        if p3:FindFirstChild("face") then
                            p3.face:Destroy()
                        end
                        l8 = l7:Clone()
                        l8.Parent = p3
                    end
                end
            end
        else
            if p3 then
                l8 = p3:FindFirstChildOfClass("SpecialMesh")
                if not l8 then
                    l8 = Instance.new("SpecialMesh", p3)
                end
                l8.MeshType = Enum.MeshType.FileMesh
                l8.MeshId = l7.MeshId
                l8.TextureId = l7.TextureId
            end
        end
    end
    for _k1, _v1 in pairs(l4) do
        l6, l7 = _k1, _v1
        if l7:IsA("Accessory") then
            l8 = l7:Clone()
            l9 = l8:FindFirstChild("Handle")
            if l9 then
                l10 = l9:FindFirstChildOfClass("Attachment")
                if l10 then
                    l11 = p2:FindFirstChild(l10.Name, true)
                    if l11 then
                        l12 = Instance.new("Weld")
                        l12.Part0 = l9
                        l12.Part1 = l11.Parent
                        l12.C0 = l10.CFrame
                        l12.C1 = l11.CFrame
                        l12.Parent = l9
                    end
                end
                l9.CanCollide = false
                l9.Massless = true
                l8.Parent = p2
            end
        end
    end
end
ApplyFakeAvaAppearance = function()
local _U_281 = {}
local l1, l2
    l1 = LocalPlayer.Character
    if l1 then
        l2 = _R["181_v3"]
        if l2 then
            l2 = l1:FindFirstChildOfClass("Humanoid")
            if l2 then
                _U_281["130_2"] = l2
                task.spawn(function()
                local _U_130 = {}
                local u1, u2, u3, u4, u5, u6, u7, u8
                    u1, u2 = pcall(function()
                        return game:GetService("Players"):GetCharacterAppearanceAsync(_R["181_v3"])
                    end)
                    if not u1 then
                        u3 = warn
                        u3("Gagal load data avatar!")
                        return
                    else
                        if u2 then
                            for _k2, _v2 in pairs(l1:GetChildren()) do
                                u4, u5 = _k2, _v2
                                if u5:IsA("Accessory") then
                                    u5:Destroy()
                                end
                            end
                            u3 = l1:FindFirstChild("Head")
                            if u3 then
                                for _k2, _v2 in pairs(u3:GetChildren()) do
                                    u5, u6 = _k2, _v2
                                    if u6:IsA("SpecialMesh") then
                                        u6:Destroy()
                                    end
                                end
                                u4 = Instance.new("SpecialMesh", u3)
                                u4.MeshType = Enum.MeshType.Head
                                u4.Scale = Vector3.new(1, 1, 1)
                            end
                            for _k2, _v2 in pairs({
                                BodyDepthScale = 1,
                                BodyHeightScale = 1,
                                BodyWidthScale = 1,
                                HeadScale = 1,
                                BodyTypeScale = 0,
                                BodyProportionScale = 0
                            }) do
                                u6, u7 = _k2, _v2
                                u8 = _U_281["130_2"]:FindFirstChild(u6)
                                if u8 then
                                    u8.Value = u7
                                end
                            end
                            task.wait(0.1)
                            LoadAsetKeKarakter(u2, l1, u3)
                            _U_130["525_1"] = u3
                            pcall(function()
                            local w1, w2, w3, w4, w5
                                w1 = game:GetService("Players"):GetCharacterAppearanceInfoAsync(_R["181_v3"])
                                if _U_130["525_1"] then
                                    if w1.assets then
                                        for _k3, _v3 in pairs(w1.assets) do
                                            w3, w4 = _k3, _v3
                                            if w4.assetType.name == "Face" then
                                                if _U_130["525_1"]:FindFirstChild("face") then
                                                    _U_130["525_1"].face:Destroy()
                                                end
                                                w5 = Instance.new("Decal", _U_130["525_1"])
                                                w5.Name = "face"
                                                w5.Texture = "rbxassetid://" .. w4.id
                                                break
                                            end
                                        end
                                    end
                                end
                            end)
                            return
                        end
                    end
                end)
                return
            end
        end
    end
end
_R["186_v3"] = "Self Avatar"
_R["187_v3"] = "WoozyNate"
_R["188_v3"] = "Nicholas"
VisualSection:AddDropdown({
    Title = "Fake Avatar",
    Options = {
        _R["186_v3"],
        _R["187_v3"],
        _R["188_v3"],
        "yvlyf",
        "traevp",
        "J0LLY",
        "LucashDev",
        "CEOofIsaac",
        "Stealthy",
        "Wildes",
        "Talon",
        "Relukt",
        "Sammy",
        "Diesel",
        "S4ans03",
        "Aura",
        "iJava",
        "White Guy",
        "Purple King",
        "Kachaaaa Gay",
        "Mpruyyy"
    },
    Default = "Self Avatar",
    Callback = function(p1)
        _R["181_v3"] = ({
            ["Self Avatar"] = LocalPlayer.UserId,
            WoozyNate = 146089324,
            Nicholas = 909635,
            yvlyf = 181751703,
            traevp = 471607078,
            J0LLY = 1073847038,
            LucashDev = 2525651744,
            CEOofIsaac = 63238912,
            Stealthy = 56602747,
            Wildes = 40397833,
            Talon = 75974130,
            Relukt = 65042011,
            Sammy = 2678001507,
            Diesel = 9123921576,
            S4ans03 = 35439794,
            Aura = 2275806428,
            iJava = 276557820,
            ["White Guy"] = 8843268357,
            ["Purple King"] = 9070758608,
            ["Kachaaaa Gay"] = 8956318334,
            Mpruyyy = 8340163775
        })[p1]
        if _R["180_v3"] then
            ApplyFakeAvaAppearance()
        end
    end
})
_R["185_v3"] = function(p1)
    _R["180_v3"] = p1
    if p1 then
        ApplyFakeAvaAppearance()
    end
end
VisualSection:AddToggle({
    Title = "Fake Avatar",
    Default = false,
    Keybind = true,
    Callback = _R["185_v3"]
})
LocalPlayer.CharacterAdded:Connect(function(p1)
    if _R["180_v3"] then
        ApplyFakeAvaAppearance()
    end
end)
SelectedConfig = ""
CurrentLoaded = "None"
ConfigFolder = _G.ConfigFolder
AutoloadPath = ConfigFolder .. "Autoload.txt"
_R["182_v3"] = ConfigFolder:split("/")[1]
_R["184_v3"] = _R["182_v3"]
_R["183_v3"] = isfolder(_R["184_v3"])
if not _R["183_v3"] then
    _R["183_v3"] = makefolder
    _R["184_v3"] = _R["182_v3"]
    _R["183_v3"](_R["184_v3"])
end
_R["184_v3"] = ConfigFolder
_R["183_v3"] = isfolder(_R["184_v3"])
if not _R["183_v3"] then
    _R["183_v3"] = makefolder
    _R["184_v3"] = ConfigFolder
    _R["183_v3"](_R["184_v3"])
end
_R["184_v3"] = AutoloadPath
_R["183_v3"] = isfile(_R["184_v3"])
if _R["183_v3"] then
    _R["184_v3"] = AutoloadPath
    _R["183_v3"] = readfile(_R["184_v3"])
end
if not _R["183_v3"] then
    _R["183_v3"] = "None"
end
AutoloadConfig = _R["183_v3"]
GetConfigList = function()
local l1, l2, l3, l4
    l1 = {}
    if isfolder(ConfigFolder) then
        for _k1, _v1 in pairs(listfiles(ConfigFolder)) do
            l3, l4 = _k1, _v1
            if l4:sub(-5) == ".json" then
                table.insert(l1, l4:match("([^/\\]+)$"):gsub(".json", ""))
            end
        end
    end
    return l1
end
ConfigSection = v43.Config:AddSection("Configuration")
ConfigParagraph = ConfigSection:AddParagraph({
    Title = "Config Manager",
    Icon = "settings",
    Content = "Current: " .. (CurrentLoaded .. (" | Autoload: " .. AutoloadConfig))
})
UpdateStatus = function()
local l1, l2
    if ConfigParagraph then
        l1 = CurrentLoaded:match("([^/\\]+)$")
        if not l1 then
            l1 = CurrentLoaded
        end
        l2 = AutoloadConfig:match("([^/\\]+)$")
        if not l2 then
            l2 = AutoloadConfig
        end
        ConfigParagraph:SetContent("Current: " .. (l1 .. (" | Autoload: " .. l2)))
    end
end
task.spawn(function()
    task.wait(1.5)
    if AutoloadConfig ~= "None" then
        v19 = true
        if LoadConfigFromFile(AutoloadConfig) then
            CurrentLoaded = AutoloadConfig
            UpdateStatus()
        end
        task.wait(1)
        v19 = false
    end
    v20 = true
end)
ConfigSection:AddInput({
    Title = "Config Name",
    Content = "Enter the name for u config",
    Placeholder = "Input Here",
    Callback = function(p1)
        SelectedConfig = p1
    end
})
ConfigDropdown = _R["183_v3"](_R["184_v3"], {
    Title = "Select Config",
    Content = "Choose from exists configs",
    Options = GetConfigList(),
    Callback = function(p1)
        SelectedConfig = p1
    end
})
ConfigSection:AddButton({
    Title = "Save Config",
    Callback = function()
        if SelectedConfig then
            if SelectedConfig ~= "" then
                notif("Config " .. (SelectedConfig .. " saved"))
                SaveConfig(SelectedConfig)
                ConfigDropdown:SetValues(GetConfigList())
            end
        end
    end,
    SubTitle = "Load Config",
    SubCallback = function()
        v19 = true
        if LoadConfigFromFile(SelectedConfig) then
            CurrentLoaded = SelectedConfig
            UpdateStatus()
            notif("Config " .. (SelectedConfig .. " loaded"))
            ConfigDropdown:SetValues(GetConfigList())
        end
        task.wait(0.5)
        v19 = false
    end
})
ConfigSection:AddButton({
    Title = "Delete Config",
    Callback = function()
    local l1
        l1 = ConfigFolder .. (SelectedConfig .. ".json")
        if isfile(l1) then
            delfile(l1)
            ConfigDropdown:SetValues(GetConfigList())
        end
    end,
    SubTitle = "Set Autoload",
    SubCallback = function()
        if SelectedConfig == "" then
            notif("Pilih config terlebih dahulu")
            return
        else
            AutoloadConfig = SelectedConfig
            writefile(AutoloadPath, AutoloadConfig)
            UpdateStatus()
            notif("Berhasil set config menjadi autoload")
            return
        end
    end
})
ConfigSection:AddButton({
    Title = "Refresh List",
    Callback = function()
        ConfigDropdown:SetValues(GetConfigList())
    end,
    SubTitle = "Clear Autoload",
    SubCallback = function()
        AutoloadConfig = "None"
        if isfile(AutoloadPath) then
            delfile(AutoloadPath)
        end
        UpdateStatus()
        notif("Berhasil menghapus autoload config")
    end
})
ConfigSection:AddButton({
    Title = "Reset All Elements to Default",
    Callback = function()
        v20 = false
        ConfigData = { _version = CURRENT_VERSION }
        if LoadConfigElements then
            LoadConfigElements()
        end
        CurrentLoaded = "None"
        UpdateStatus()
        task.wait(0.5)
        v20 = true
    end
})
ExternalJSONInput = ""
ConfigSection:AddSubSection("Load From External")
ConfigSection:AddInput({
    Title = "External Config JSON",
    Content = "Paste ur raw JSON config here",
    Callback = function(p1)
        ExternalJSONInput = p1
    end
})
ConfigSection:AddButton({
    Title = "Load External JSON",
    Callback = function()
    local l1, l2
        if ExternalJSONInput == "" then
            notif("JSON input kosong!")
            return
        else
            if ExternalJSONInput ~= nil then
                l1, l2 = pcall(function()
                    return HttpService:JSONDecode(ExternalJSONInput)
                end)
                if not l1 then
                    notif("JSON tidak valid! Cek formatnya")
                    return
                else
                    if l2 then
                        v19 = true
                        ConfigData = l2
                        if LoadConfigElements then
                            LoadConfigElements()
                        end
                        CurrentLoaded = "External JSON"
                        UpdateStatus()
                        notif("Berhasil load config dari external JSON")
                        task.wait(0.5)
                        v19 = false
                        return
                    end
                end
            end
        end
    end,
    SubTitle = "Export Config",
    SubCallback = function()
        if SelectedConfig == "" then
            notif("Pilih dan load dulu, dan select kembali config yang ingin di import!")
            return
        else
            if SelectedConfig ~= nil then
                setclipboard(HttpService:JSONEncode(ConfigData))
                notif("Config " .. (SelectedConfig .. " berhasil di-copy ke clipboard!"))
                return
            end
        end
    end
})
LastPosSection = v43.Config:AddSection("Last Position Features")
LastPosSection:AddParagraph({
    Title = "Tutorial Teleport",
    Content = "\r\n<b><font color=\"rgb(252, 119, 216)\">AUTO TELEPORT?</font></b>\r\nClick <b><font color=\"rgb(252, 119, 216)\">Save Position</font></b> to save your current position!\r\n\r\n<b><font color=\"rgb(252, 119, 216)\">HOW TO LOAD?</font></b>\r\nThis feature will auto-sync your last position when executed, so you will teleport automatically!\r\n\r\n<b><font color=\"rgb(252, 119, 216)\">HOW TO RESET?</font></b>\r\nClick <b><font color=\"rgb(252, 119, 216)\">Reset Position</font></b> to clear your saved position.\r\n    "
})
LastPosSection:AddButton({
    Title = "Save Position",
    Callback = function()
    local l1
        l1 = LocalPlayer.Character
        if l1 then
            l1 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        if l1 then
            SavePosition(l1.CFrame)
            notif("Successfully saved position")
        end
    end,
    SubTitle = "Reset Position",
    SubCallback = function()
        if isfile("Meng Hub/FischLPosition.json") then
            delfile("Meng Hub/FischLPosition.json")
        end
        notif("Successfully reset last position")
    end
})
LastPosSection:AddButton({
    Title = "Teleport To Save Location",
    Callback = function()
    local l1, l2
        l1 = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        l2 = LoadPosition()
        if l2 then
            task.wait(1)
            l1.CFrame = l2
            notif("Teleported to ur last position...")
            return
        else
            notif("You don't have save position before..")
            return
        end
    end
})
SetupEffect = function(p1, p2)
local l3
    l3 = Lighting:FindFirstChild(p2)
    if not l3 then
        l3 = Instance.new(p1)
    end
    l3.Name = p2
    l3.Parent = Lighting
    return l3
end
CC = SetupEffect("ColorCorrectionEffect", "ClientGraphicCC")
Bloom = SetupEffect("BloomEffect", "ClientGraphicBloom")
GrapichSection = v43.Config:AddSection("Grapichs Custom")
_R["187_v3"] = "Default"
_R["188_v3"] = "Warm"
GrapichSection:AddDropdown({
    Title = "Select Grapich",
    Options = {
        _R["187_v3"],
        _R["188_v3"],
        "Cool",
        "Cinematic",
        "Vibrant",
        "Anti Lag/Low"
    },
    Default = "Vibrant",
    Callback = function(p1)
    local l2
        l2 = CC
        l2.TintColor = Color3.fromRGB(255, 255, 255)
        l2 = CC
        l2.Saturation = 0
        l2 = CC
        l2.Contrast = 0
        l2 = CC
        l2.Brightness = 0
        l2 = Bloom
        l2.Intensity = 0.5
        Lighting.ExposureCompensation = 0
        if p1 ~= "Warm" then
            if p1 ~= "Cool" then
                if p1 ~= "Cinematic" then
                    if p1 ~= "Vibrant" then
                        if p1 == "Anti-Lag/Low" then
                            l2 = CC
                            l2.Saturation = -0.2
                            l2 = Bloom
                            l2.Intensity = 0
                            Lighting.GlobalShadows = false
                            Lighting.ExposureCompensation = -0.3
                        end
                    else
                        l2 = CC
                        l2.Saturation = 0.3
                        l2 = CC
                        l2.Contrast = 0.1
                        Lighting.ExposureCompensation = -0.2
                    end
                else
                    l2 = CC
                    l2.TintColor = Color3.fromRGB(200, 200, 200)
                    l2 = CC
                    l2.Saturation = -0.1
                    l2 = CC
                    l2.Contrast = 0.2
                    Lighting.ExposureCompensation = -0.5
                end
            else
                l2 = CC
                l2.TintColor = Color3.fromRGB(180, 230, 255)
            end
        else
            l2 = CC
            l2.TintColor = Color3.fromRGB(255, 210, 160)
            l2 = CC
            l2.Saturation = 0.05
        end
    end
})
sendServerStatusEmbed = function()
local _U_160 = {}
local l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19, l20, l21
local l22, l23, l24, l25, l26, l27
    l2 = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    l3 = game:GetService("HttpService")
    l4 = {}
    l13 = "Plesiosaur Hunt"
    l16 = "Sunken Reliquary"
    l17 = "Omnithal Hunt"
    l23 = "Blue Moon - Second Sea"
    l4[1] = "Dreadfin Hunt"
    l4[2] = "Baby Bloop Fish"
    l4[3] = "Bloop Fish"
    l4[4] = "Whales Pool"
    l4[5] = "Orcas Pool"
    l4[6] = "The Kraken Pool"
    l4[7] = "Ancient Depth Serpent"
    l4[8] = "Animal Pool"
    l4[9] = l13
    l4[10] = "Goldwraith Hunt"
    l4[11] = "Reef Titan Hunt"
    l4[12] = l16
    l4[13] = l17
    l4[14] = "Animal Pool - Second Sea"
    l4[15] = "Octophant Pool Without Elephant"
    l4[16] = "Sea Leviathan Pool"
    l4[17] = "Isonade"
    l4[18] = "Forsaken Veil - Scylla"
    l4[19] = l23
    l4[20] = "Blue Moon - First Sea"
    l4[21] = "Great White Shark"
    l4[22] = "LEGO"
    l4[23] = "LEGO - Studolodon"
    l4[24] = "Mosslurker"
    l4[25] = "Narwhal"
    l4[26] = "Whale Shark"
    l4[27] = "Birthday Megalodon"
    l4[28] = "Colossal Blue Dragon"
    l4[29] = "Colossal Ancient Dragon"
    l4[30] = "Colossal Ethereal Dragon"
    l4[31] = "Megalodon Ancient"
    l4[32] = "Megalodon Default"
    l4[33] = "Megalodon Phantom"
    l4[34] = "Skeletal Leviathan Hunt"
    l4[35] = "Pliosaur Hunt"
    l4[36] = "Toxic Boil"
    l4[37] = "Flower Guardian Hunt"
    l4[38] = "Rotbloom Hunt"
    l4[39] = "Sovereign Beam"
    l4[40] = "Megamouth Hunt"
    l4[41] = "Humpback Whale Pool"
    l5 = { ["Ancient Depth Serpent"] = "The Depths - Serpent" }
    l6 = {}
    pcall(function()
    local u1, u2, u3, u4, u5, u6, u7
        u1 = workspace:WaitForChild("zones", 3):WaitForChild("fishing", 3)
        for _k2, _v2 in ipairs(l4) do
            u3, u4 = _k2, _v2
            u7 = l5[u4]
            if not u7 then
                u7 = u4
            end
            u5 = u5(u6, u7)
            if u5 then
                if u5:IsA("BasePart") then
                    table.insert(l6, u4)
                end
            end
        end
    end)
    l7 = #l6
    l8 = "None"
    pcall(function()
    local u1
        u1 = l2.hud.safezone.worldstatuses["1_adminevent"].label.Text
        if u1 then
            if u1 ~= "" then
                if u1:lower() ~= "weather status" then
                    l8 = u1
                end
            end
        end
    end)
    l9 = "Unknown"
    l10 = 0
    l12 = function()
    local u1, u2, u3, u4, u5
        u1 = l2.serverInfo.serverInfo.uptime.Text
        l9 = u1:gsub("^[Uu]ptime:%s*", "")
        u2 = tonumber(u1:match("(%d+)D"))
        if not u2 then
            u2 = 0
        end
        u3 = tonumber(u1:match("(%d+)H"))
        if not u3 then
            u3 = 0
        end
        u4 = tonumber(u1:match("(%d+)M"))
        if not u4 then
            u4 = 0
        end
        u5 = tonumber(u1:match("(%d+)S"))
        if not u5 then
            u5 = 0
        end
        l10 = (((u2 * 86400) + (u3 * 3600)) + (u4 * 60)) + u5
    end
    pcall(l12)
    l11 = "Unknown"
    if 0 < l10 then
        fmtTime = function(a1)
            return string.format("%dD %02dH %02dM", math.floor(a1 / 86400), math.floor((a1 % 86400) / 3600), math.floor((a1 % 3600) / 60))
        end
        l12 = l10 / 60
        l13 = 0
        l14 = nil
        while true do
            l14 = 60 + (70 * l13)
            l13 = l13 + 1
            if l12 >= l14 then
                break
            end
        end
        l15 = l14 * 60
        l16 = math.floor(l15 - l10)
        l17 = math.floor(l16 / 60)
        l11 = string.format("%s (In: %dM)", fmtTime(l15), l17)
    end
    l12 = "Unknown"
    pcall(function()
        l12 = l2.serverInfo.serverInfo.region.Text:gsub("^[Rr]egion:%s*", "")
    end)
    l13 = "Unknown"
    pcall(function()
        l13 = l2.hud.safezone.worldstatuses["3_weather"].label.Text
    end)
    l14 = #game:GetService("Players"):GetPlayers()
    l15 = game.Players.MaxPlayers
    l16 = 0
    l17 = 0
    pcall(function()
    local u1, u2, u4, u5, u6, u7, u8, u9
        u1 = workspace:GetChildren()
        u2 = {}
        for _k2, _v2 in ipairs({
            u1[117],
            u1[121],
            u1[123],
            u1[124],
            u1[125],
            workspace:FindFirstChild("StarCrater")
        }) do
            u5, u6 = _k2, _v2
            if u6 then
                if u6.Name == "StarCrater" then
                    if not u2[u6] then
                        u2[u6] = true
                        l16 = l16 + 1
                        for _k2, _v2 in ipairs(u6:GetDescendants()) do
                            u8, u9 = _k2, _v2
                            if u9.Name == "Cosmic Relic" then
                                l17 = l17 + 1
                            end
                        end
                    end
                end
            end
        end
    end)
    l18 = game.JobId ~= ""
    if l18 then
        l18 = game.JobId
    end
    if not l18 then
        l18 = "N/A"
    end
    l19 = tostring(game.PlaceId)
    l20 = l18 ~= "N/A"
    if l20 then
        l23 = 8
        l20 = "#" .. l18:sub(1, l23)
    end
    if not l20 then
        l20 = "#unknown"
    end
    l21 = nil
    if l7 ~= 0 then
        l22 = {}
        l23 = ""
        for _k1, _v1 in ipairs(l6) do
            l25, l26 = _k1, _v1
            l27 = l25 == 1
            if l27 then
                l27 = l26
            end
            if not l27 then
                l27 = ", " .. l26
            end
            if 52 >= ((#l23) + (#l27)) then
                l23 = l23 .. l27
            else
                table.insert(l22, "> " .. l23)
                l23 = l26
            end
        end
        if l23 ~= "" then
            table.insert(l22, "> " .. l23)
        end
        l24 = "**" .. (l20 .. "**")
        l21 = table.concat(l22, "\n")
        l22 = table.concat
        l23 = {
            l24,
            "`" .. (l18 .. "`"),
            "",
            "**Active Events** - " .. (tostring(l7) .. " active"),
            l21,
            "",
            "**Admin Event**",
            "> " .. l8,
            "",
            "**Server Info**",
            "> Uptime       :  " .. l9,
            "> Next Sunken Drop  :  " .. l11,
            "> Players      :  " .. (l14 .. (" / " .. l15)),
            "> Weather      :  " .. l13,
            "> Region       :  " .. l12,
            "",
            "**Star Craters** - " .. (tostring(l16) .. ("   |   **Cosmic Relics** - " .. tostring(l17))),
            "",
            "-# Place ID: " .. l19
        }
        l23 = l23(l24, {
            username = "Meng Hub | Tracker Fisch",
            avatar_url = "https://cdn.discordapp.com/attachments/1446133670254477374/1482166768356167761/Nama_Proyek_58.png?ex=69b5f6de&is=69b4a55e&hm=b24ebdc98cc0dd6f9f852712c83dbba6d72118d53c93b8d7a5ae07cd1ca9574d&",
            embeds = {
                {
                    title = "Fisch Server Status",
                    description = l22(l23, "\n"),
                    color = 7079897,
                    thumbnail = {
                        url = "https://cdn.discordapp.com/attachments/1446133670254477374/1482166768356167761/Nama_Proyek_58.png?ex=69b5f6de&is=69b4a55e&hm=b24ebdc98cc0dd6f9f852712c83dbba6d72118d53c93b8d7a5ae07cd1ca9574d&"
                    },
                    footer = { text = "Fisch Server Monitor - Auto-update" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }
            }
        })
        doReq = function(a1)
            if type(request) ~= "function" then
                if type(syn) ~= "table" then
                    if type(http) == "table" then
                        if http.request then
                            return http.request(a1)
                        end
                    end
                else
                    if syn.request then
                        return syn.request(a1)
                    end
                end
            else
                return request(a1)
            end
        end
        _U_160["535_0"] = l23
        pcall(function()
            doReq({
                Url = "https://discord.com/api/webhooks/1482169259428937860/BxlIntycii5M8HqQ4tJCL2ms44hEHQcytHEOaOZnfBdDw4_QFxxGGD0Ho1mlHhEfbS6e",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = _U_160["535_0"]
            })
        end)
        return
    else
        l24 = "**" .. (l20 .. "**")
        l22 = table.concat
        l23 = {
            l24,
            "`" .. (l18 .. "`"),
            "",
            "**Active Events** - " .. (tostring(l7) .. " active"),
            "> *No active events*",
            "",
            "**Admin Event**",
            "> " .. l8,
            "",
            "**Server Info**",
            "> Uptime       :  " .. l9,
            "> Next Sunken Drop  :  " .. l11,
            "> Players      :  " .. (l14 .. (" / " .. l15)),
            "> Weather      :  " .. l13,
            "> Region       :  " .. l12,
            "",
            "**Star Craters** - " .. (tostring(l16) .. ("   |   **Cosmic Relics** - " .. tostring(l17))),
            "",
            "-# Place ID: " .. l19
        }
        l23 = l23(l24, {
            username = "Meng Hub | Tracker Fisch",
            avatar_url = "https://cdn.discordapp.com/attachments/1446133670254477374/1482166768356167761/Nama_Proyek_58.png?ex=69b5f6de&is=69b4a55e&hm=b24ebdc98cc0dd6f9f852712c83dbba6d72118d53c93b8d7a5ae07cd1ca9574d&",
            embeds = {
                {
                    title = "Fisch Server Status",
                    description = l22(l23, "\n"),
                    color = 7079897,
                    thumbnail = {
                        url = "https://cdn.discordapp.com/attachments/1446133670254477374/1482166768356167761/Nama_Proyek_58.png?ex=69b5f6de&is=69b4a55e&hm=b24ebdc98cc0dd6f9f852712c83dbba6d72118d53c93b8d7a5ae07cd1ca9574d&"
                    },
                    footer = { text = "Fisch Server Monitor - Auto-update" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }
            }
        })
        doReq = function(a1)
            if type(request) ~= "function" then
                if type(syn) ~= "table" then
                    if type(http) == "table" then
                        if http.request then
                            return http.request(a1)
                        end
                    end
                else
                    if syn.request then
                        return syn.request(a1)
                    end
                end
            else
                return request(a1)
            end
        end
        _U_160["535_0"] = l23
        pcall(function()
            doReq({
                Url = "https://discord.com/api/webhooks/1482169259428937860/BxlIntycii5M8HqQ4tJCL2ms44hEHQcytHEOaOZnfBdDw4_QFxxGGD0Ho1mlHhEfbS6e",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = _U_160["535_0"]
            })
        end)
        return
    end
end
task.spawn(function()
    while true do
        task.wait(1)
        if game:IsLoaded() then
            break
        end
    end
    task.wait(2)
    sendServerStatusEmbed()
end)
task.wait(0.5)
v20 = true
setfpscap(999)
_R["185_v3"] = notif
_R["186_v3"] = "Window Loaded"
_R["185_v3"](_R["186_v3"])
