-- T-RexProject/UniversalCode/01_config_lang.lua
-- Config defaults, schema validation, array/scalar migration, profile persistence, and 4-language lookup.

local HttpService = TRex.Services.HttpService

TRex.DEFAULT_CONFIG = {
	SchemaVersion = 2,
	Language = "th",
	Theme = "ชมพูซากุระ",
	Font = "โกธิคทันสมัย",
	FontSize = 14,
	GuiScalePercent = 100,
	BackgroundTransparency = 0.04,
	BackgroundBlur = false,
	ToggleKey = "RightControl",
	PanicKey = "End",
	AntiAFK = true,

	-- Farm: Auto Steal (full Temp parity)
	AutoSteal = false,
	AntiGuard = true,
	DropEggsAtSafeZone = false,
	StealMissingIndex = true,
	MoveToEgg = "Teleport",
	DeliveryMode = "Fast Tween",
	TeleportDelivery = "Fast Tween",
	TeleportZones = {
		"Titan Temple",
		"Light Dark",
		"Enchanted Forest",
		"Alien",
		"Cherry Blossom",
		"Cosmic",
		"Prehistoric",
	},
	DeliverySpeed = 100,
	StepCount = 3,
	FastTweenSpeed = 3300,
	StealPriority = "Highest Value",
	StealMinRarity = "Any",
	MinStealValue = 0,
	RarityMinValue = "Divine",
	CosmicMinValue = 0,
	SecretMinValue = 0,
	EternalMinValue = 0,
	DivineMinValue = 0,
	TargetAreas = {
		"Forest",
		"Desert",
		"Snow",
		"Lake",
		"Jungle",
		"Volcano",
		"Prehistoric",
		"Cosmic",
		"Abyss Ocean",
		"Cherry Blossom",
		"Light Dark",
		"Titan Temple",
		"Enchanted Forest",
		"Alien",
	},
	TargetSpecificEggs = {},

	-- Farm: Treadmill & Rotation
	AutoTreadmill = true,
	AutoWatchAds = false,
	AdminTreadmill = false,
	RotateFishingAndTreadmill = false,
	RotationSwitch = "Every Day",
	TreadmillMinutes = 1,
	FishingMinutes = 1,

	-- Farm: Progression
	AutoClaimMoney = true,
	AutoClaimIndex = true,
	AutoBuyTrail = true,
	AutoUpgradeTreadmill = true,
	AutoUpgradeBase = true,

	-- Farm: Keep / Place / Hatch / Mutate / Fuse / Favorite / Sell
	KeepEggs = false,
	KeepEggsSort = "Highest Value",
	KeepEggsMinRarity = "Divine",
	KeepEggsMinValue = 0,

	AutoPlaceEgg = false,
	PlaceEggRule = "Only Higher Value",
	PlaceEggOrder = "Highest Value",
	PlaceMissingIndex = false,
	PlaceRarities = {},
	PlaceSpecificEggs = {},
	MinPlaceValue = 0,
	MaxPlaceValue = 1e12,

	AutoHatch = false,
	AutoEquipBest = false,
	HatchMode = "All Ready",
	HatchSpecificEggs = {},
	HatchMinValue = 0,

	AutoMutate = false,
	MutationsToUse = {
		"Golden",
		"Rainbow",
		"Sakura",
		"GreatBloom",
		"Boss",
		"Monstrous",
		"Scrambled",
	},
	MutateTargetEggs = {},
	MutateMinValue = 0,

	AutoFusery = false,
	FuseMode = "Best",
	FuseMaxRarity = "Mythic",
	FuseSkipMutated = true,
	FuseSpecificSpecies = {},
	FuseMaxValue = 0,
	AutoSubmitFuse = false,
	AutoClaimFuse = false,

	AutoFavoritePets = false,
	AutoFavoriteEggs = false,
	FavoriteMinRarity = "Divine",
	FavoriteMinValue = 0,
	FavoriteMutations = {},
	AlwaysFavoriteSpecies = {},

	AutoSellPets = false,
	SellPetsMinRarity = "Any",
	SellPetsMaxValue = 0,
	BlacklistSellPets = {},
	KeepMutatedPets = true,
	KeepEquippedPets = true,
	KeepFavoritedPets = true,

	AutoSellEggs = false,
	AutoSellEggsThreshold = 105,
	SellEggsMaxValue = 0,
	BlacklistSellEggs = {},
	KeepMutatedEggs = true,

	-- Events & Minigames
	AutoButterfly = false,
	ButterflyMode = "Stick",
	ButterflyPriority = "Nearest",
	ButterflySpeed = 120,
	CatchButterflies = {},
	AutoClaimNet = true,
	AutoTradeButterfly = false,
	SmartTradeButterfly = false,
	AutoCraftEssence = false,
	AutoBanjoCricket = false,
	AutoWispQuest = false,
	AutoShootingStar = false,
	AutoStagePosition = false,

	AutoFishing = false,
	CastLuckBoost = false,
	FishingSpot = "Auto",
	FastLagoonTrips = true,
	AutoGetAlienRod = false,
	AutoCosmicEclipse = false,
	AutoSocketRelics = false,
	AutoClaimMastery = false,
	AutoTradePearls = false,

	-- Admin Abuse
	InstantStealV3 = false,
	AutoMinigameEggs = false,
	AutoCaptureEgg = false,
	CaptureHoldHeight = 45,
	CaptureKeepAwayDist = 45,
	CaptureTakeFromHolder = true,
	AutoCursedIslandWars = false,
	IslandWarsMode = "Enemies And Base",

	-- Player / Movement / Combat
	InstantPrompts = true,
	AntiRagdoll = true,
	AntiTrap = true,
	Invisibility = false,
	InvisibilityKey = "None",
	SpeedBoost = false,
	BoostSpeed = 65,
	InfiniteJump = false,
	JumpPowerValue = 50,

	AutoHit = false,
	HitMode = "Egg Holders",
	HitTargetPlayer = "",
	HitAura = false,
	SwapWeapons = false,
	SkipFriends = true,
	HitTween = true,
	HitMaxRange = 750,
	HitChaseSpeed = 400,
	HitLead = -275,
	HitSweep = 60,

	-- Render & ESP & HUDs
	EggESP = false,
	OwnBaseEggESP = false,
	OtherBaseEggESP = false,
	RevealEggContent = true,
	ESPMinRarity = "Any",
	ESPMinValue = 0,
	ESPFixedSize = false,
	ESPSizePercent = 100,
	ESPShowInfo = { "Name", "Rarity", "Mutation", "Value", "Weight", "Distance" },
	PlayerESP = false,
	PlayerTracker = false,
	ESPPlayerInfo = { "Name", "Distance", "Carrying", "Status" },
	GuardESP = false,
	ShowSafeZoneMarker = false,
	ShowInventoryValues = false,
	ShowFarmHUD = false,

	-- Server / Predictor / Webhook / Optimizer
	AutoHop = false,
	HopMode = "Least Players",
	HopCondition = "Match Steal Filter",
	HopDelaySeconds = 8,
	AutoRejoin = true,
	AutoLoadScript = false,

	PredictorEnabled = false,
	PredictorSort = "Value",
	PredictorFilter = "All",

	WebhookEnabled = false,
	WebhookUrl = "",
	WebhookPingEveryone = false,
	WebhookNotifyOn = { "Egg Stolen", "Egg Fused", "Inventory Full" },
	WebhookMinRarity = "Any",
	WebhookMinValue = 0,
	WebhookEggs = {},
	WebhookPostFished = false,
	WebhookFishedMinValue = 0,

	OptimizerEnabled = false,
	OptimizerMode = "Strong",
	HideMyEggs = false,
	HideOtherEggs = false,
	HideTreadmill = false,
	Disable3DRender = false,
	No3DBackground = "White",
	HideGameUI = false,
	FPSCapEnabled = false,
	FPSCapValue = 60,
	ShowFPSPingHUD = true,
	FPSPingSizePercent = 100,
}

local NUMBER_BOUNDS = {
	FontSize = { 10, 20, true },
	GuiScalePercent = { 70, 140, true },
	BackgroundTransparency = { 0, 0.4, false },
	DeliverySpeed = { 80, 110, true },
	StepCount = { 1, 6, true },
	FastTweenSpeed = { 3000, 4500, true },
	MinStealValue = { 0, 1e15, false },
	CosmicMinValue = { 0, 1e15, false },
	SecretMinValue = { 0, 1e15, false },
	EternalMinValue = { 0, 1e15, false },
	DivineMinValue = { 0, 1e15, false },
	TreadmillMinutes = { 1, 60, true },
	FishingMinutes = { 1, 60, true },
	KeepEggsMinValue = { 0, 1e15, false },
	MinPlaceValue = { 0, 1e15, false },
	MaxPlaceValue = { 0, 1e15, false },
	HatchMinValue = { 0, 1e15, false },
	MutateMinValue = { 0, 1e15, false },
	FuseMaxValue = { 0, 1e15, false },
	FavoriteMinValue = { 0, 1e15, false },
	SellPetsMaxValue = { 0, 1e15, false },
	SellEggsMaxValue = { 0, 1e15, false },
	AutoSellEggsThreshold = { 20, 200, true },
	ButterflySpeed = { 40, 400, true },
	CaptureHoldHeight = { 10, 120, true },
	CaptureKeepAwayDist = { 10, 120, true },
	BoostSpeed = { 16, 200, true },
	JumpPowerValue = { 30, 150, true },
	HitMaxRange = { 100, 2000, true },
	HitChaseSpeed = { 80, 800, true },
	HitLead = { -600, 300, true },
	HitSweep = { 0, 150, true },
	ESPMinValue = { 0, 1e15, false },
	ESPSizePercent = { 50, 200, true },
	HopDelaySeconds = { 2, 120, true },
	WebhookMinValue = { 0, 1e15, false },
	WebhookFishedMinValue = { 0, 1e15, false },
	FPSCapValue = { 10, 360, true },
	FPSPingSizePercent = { 60, 160, true },
}

local SUPPORTED_LANGS = {
	["th"] = true,
	["en-us"] = true,
	["vi"] = true,
	["zh"] = true,
}

TRex.Config = {}
TRex.CurrentProfileName = "Default"
TRex.LangPacks = {}
TRex.CurrentLang = "th"

local function cloneTable(src)
	if type(src) ~= "table" then
		return src
	end
	local copy = {}
	for k, v in pairs(src) do
		copy[k] = cloneTable(v)
	end
	return copy
end

local function migrateLegacyFields(raw)
	if type(raw) ~= "table" then
		return {}
	end
	if raw.StealGoMode ~= nil and raw.MoveToEgg == nil then
		raw.MoveToEgg = raw.StealGoMode == "Walk" and "Walk" or "Teleport"
	end
	if raw.StealReturnMode ~= nil and raw.DeliveryMode == nil then
		if raw.StealReturnMode == "FastTween" or raw.StealReturnMode == "Fast Tween" then
			raw.DeliveryMode = "Fast Tween"
			raw.TeleportDelivery = raw.TeleportDelivery or "Fast Tween"
		elseif raw.StealReturnMode == "Walk" then
			raw.DeliveryMode = "Walk"
			raw.TeleportDelivery = raw.TeleportDelivery or "Walk"
		else
			raw.DeliveryMode = "Instant Steps"
			raw.TeleportDelivery = raw.TeleportDelivery or "Quick Steps"
		end
	end
	if raw.StealSortMode ~= nil and raw.StealPriority == nil then
		raw.StealPriority = raw.StealSortMode
	end
	if raw.TweenSpeed ~= nil and raw.FastTweenSpeed == nil then
		local spd = tonumber(raw.TweenSpeed) or 3300
		if spd < 3000 then
			spd = 3300
		end
		raw.FastTweenSpeed = spd
	end
	if raw.AutoTreadmillTier ~= nil and raw.AutoUpgradeTreadmill == nil then
		raw.AutoUpgradeTreadmill = raw.AutoTreadmillTier
	end
	if raw.AutoCollectAway ~= nil and raw.AutoClaimMoney == nil then
		raw.AutoClaimMoney = raw.AutoCollectAway
	end
	if raw.AutoRedeemCodex ~= nil and raw.AutoClaimIndex == nil then
		raw.AutoClaimIndex = raw.AutoRedeemCodex
	end
	if raw.WearBestPet ~= nil and raw.AutoEquipBest == nil then
		raw.AutoEquipBest = raw.WearBestPet
	end
	if raw.AutoBatSwing ~= nil and raw.AutoHit == nil then
		raw.AutoHit = raw.AutoBatSwing
	end
	if raw.CustomSpeedEnabled ~= nil and raw.SpeedBoost == nil then
		raw.SpeedBoost = raw.CustomSpeedEnabled
	end
	if raw.WalkSpeedValue ~= nil and raw.BoostSpeed == nil then
		local ws = tonumber(raw.WalkSpeedValue) or 65
		raw.BoostSpeed = math.max(16, ws)
	end
	if raw.LowPowerMode == true and raw.FPSCapEnabled == nil then
		raw.FPSCapEnabled = true
		raw.FPSCapValue = math.min(tonumber(raw.FPSCapValue) or 40, 40)
	end
	if raw.RevealEggContent100 ~= nil and raw.RevealEggContent == nil then
		raw.RevealEggContent = raw.RevealEggContent100
	end
	return raw
end

function TRex.sanitizeConfig(raw)
	local cleaned = {}
	local source = migrateLegacyFields(type(raw) == "table" and raw or {})
	for key, defaultVal in pairs(TRex.DEFAULT_CONFIG) do
		local val = source[key]
		if type(defaultVal) == "boolean" then
			if type(val) == "boolean" then
				cleaned[key] = val
			else
				cleaned[key] = defaultVal
			end
		elseif type(defaultVal) == "number" then
			local num = tonumber(val)
			if num == nil then
				num = defaultVal
			end
			local bounds = NUMBER_BOUNDS[key]
			if bounds then
				if bounds[3] then
					num = math.floor(num + 0.5)
				end
				num = math.clamp(num, bounds[1], bounds[2])
			end
			cleaned[key] = num
		elseif type(defaultVal) == "table" then
			if type(val) == "table" then
				local arr = {}
				for _, item in ipairs(val) do
					if type(item) == "string" or type(item) == "number" then
						table.insert(arr, tostring(item))
					end
				end
				cleaned[key] = arr
			else
				cleaned[key] = cloneTable(defaultVal)
			end
		else
			if type(val) == "string" then
				cleaned[key] = val
			else
				cleaned[key] = defaultVal
			end
		end
	end

	if not SUPPORTED_LANGS[cleaned.Language] then
		cleaned.Language = "th"
	end
	if TRex.UI and TRex.UI.THEMES and not TRex.UI.THEMES[cleaned.Theme] then
		cleaned.Theme = "ชมพูซากุระ"
	end
	if TRex.UI and TRex.UI.THAI_FONTS and not TRex.UI.THAI_FONTS[cleaned.Font] then
		cleaned.Font = "โกธิคทันสมัย"
	end
	return cleaned
end

local function getGamePaths()
	return {
		ConfigDir = "T-RexProject\\Games\\Game01\\Config",
		LangDir = "T-RexProject\\Games\\Game01\\Lang",
		MetaPath = "T-RexProject\\Games\\Game01\\Config\\Meta.json",
	}
end

function TRex.saveConfig(profileName)
	local name = (type(profileName) == "string" and profileName ~= "") and profileName or TRex.CurrentProfileName or "Default"
	name = name:gsub("[^%w%-%_%s]", "_")
	TRex.CurrentProfileName = name
	local paths = getGamePaths()
	local payload = cloneTable(TRex.Config)
	payload._SelectedProfile = nil
	local okEncode, json = pcall(HttpService.JSONEncode, HttpService, TRex.sanitizeConfig(payload))
	if not okEncode then
		return false
	end
	local path = paths.ConfigDir .. "\\" .. name .. ".json"
	local ok = TRex.safeWriteFile(path, json)
	if ok then
		local metaOk, metaJson = pcall(HttpService.JSONEncode, HttpService, { ActiveProfile = name })
		if metaOk then
			TRex.safeWriteFile(paths.MetaPath, metaJson)
		end
	end
	return ok
end

function TRex.loadConfig(profileName)
	local paths = getGamePaths()
	local target = profileName
	if not target or target == "" then
		local metaRaw = TRex.safeReadFile(paths.MetaPath)
		if metaRaw then
			local okMeta, metaTbl = pcall(HttpService.JSONDecode, HttpService, metaRaw)
			if okMeta and type(metaTbl) == "table" and type(metaTbl.ActiveProfile) == "string" then
				target = metaTbl.ActiveProfile
			end
		end
	end
	target = (target and target ~= "") and target or "Default"
	TRex.CurrentProfileName = target

	local rawJson = TRex.safeReadFile(paths.ConfigDir .. "\\" .. target .. ".json")
	local decoded = nil
	if rawJson then
		local okDec, tbl = pcall(HttpService.JSONDecode, HttpService, rawJson)
		if okDec and type(tbl) == "table" then
			decoded = tbl
		end
	end
	local sanitized = TRex.sanitizeConfig(decoded)
	for k, v in pairs(sanitized) do
		TRex.Config[k] = v
	end
	TRex.CurrentLang = TRex.Config.Language or "th"
	return TRex.Config
end

function TRex.listProfiles()
	local paths = getGamePaths()
	local profiles = { "Default" }
	local seen = { Default = true }
	if type(listfiles) == "function" then
		local norm = TRex.normalizePath(paths.ConfigDir)
		local ok, entries = pcall(listfiles, norm)
		if ok and type(entries) == "table" then
			for _, full in ipairs(entries) do
				local fname = tostring(full):match("([^/\\]+)%.json$")
				if fname and fname ~= "Meta" and not seen[fname] then
					seen[fname] = true
					table.insert(profiles, fname)
				end
			end
		end
	end
	return profiles
end

function TRex.registerEmbeddedLang(packs)
	if type(packs) ~= "table" then
		return
	end
	for code, dict in pairs(packs) do
		if type(code) == "string" and type(dict) == "table" then
			TRex.LangPacks[code] = dict
		end
	end
end

function TRex.initLangPacks()
	local paths = getGamePaths()
	for code in pairs(SUPPORTED_LANGS) do
		local raw = TRex.safeReadFile(paths.LangDir .. "\\" .. code .. ".json")
		if raw then
			local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
			if ok and type(decoded) == "table" then
				TRex.LangPacks[code] = decoded
			end
		end
	end
	TRex.setLanguage(TRex.Config.Language or "th", true)
end

function TRex.setLanguage(langCode, skipSave)
	local code = SUPPORTED_LANGS[langCode] and langCode or "th"
	TRex.CurrentLang = code
	TRex.Config.Language = code
	if not skipSave then
		TRex.saveConfig(TRex.CurrentProfileName)
	end
end

function TRex.t(key, vars)
	if type(key) ~= "string" then
		return ""
	end
	local pack = TRex.LangPacks[TRex.CurrentLang] or TRex.LangPacks["th"] or {}
	local fallback = TRex.LangPacks["en-us"] or TRex.LangPacks["th"] or {}
	local text = pack[key] or fallback[key] or key
	if type(vars) == "table" then
		for k, v in pairs(vars) do
			text = text:gsub("{" .. tostring(k) .. "}", tostring(v))
		end
	end
	return text
end
