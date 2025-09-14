DARK_EXPLORATION = DARK_EXPLORATION or {}

-- Configuration
DARK_EXPLORATION.CONFIG = {
    DarknessLevel = 0.05, -- How dark the map should be (0-1)
    WeaponSpawnChance = 0.3, -- Chance for weapon to spawn when searching
    MaxWeapons = 3, -- Maximum weapons player can carry
    SoundEventInterval = {min = 30, max = 120}, -- Time between sound events (seconds)
    CheatPenalty = {first = "kill", second = "kick"}, -- Penalties for cheating
    LambdaSymbol = "models/props_lab/huladoll.mdl" -- Using hula doll as lambda symbol placeholder
}

-- Available weapons (HL2 assets)
DARK_EXPLORATION.WEAPONS = {
    "weapon_crowbar",
    "weapon_pistol",
    "weapon_357",
    "weapon_smg1",
    "weapon_ar2",
    "weapon_shotgun",
    "weapon_crossbow",
    "weapon_rpg",
    "weapon_frag"
}

-- Sound events table
DARK_EXPLORATION.SOUNDS = {
    "physics/metal/metal_large_debris1.wav",
    "physics/metal/metal_large_debris2.wav",
    "physics/wood/wood_crate_break1.wav",
    "physics/wood/wood_crate_break2.wav",
    "physics/glass/glass_sheet_break1.wav",
    "physics/glass/glass_sheet_break2.wav",
    "ambient/energy/zap1.wav",
    "ambient/energy/zap2.wav",
    "ambient/energy/zap3.wav"
}

-- Random objects for lambda rooms
DARK_EXPLORATION.LAMBDA_OBJECTS = {
    "models/props_c17/furniturecouch001a.mdl",
    "models/props_c17/furniturechair001a.mdl",
    "models/props_c17/furnituretable001a.mdl",
    "models/props_c17/furnituretable002a.mdl",
    "models/props_junk/wood_crate001a.mdl",
    "models/props_junk/wood_crate002a.mdl",
    "models/props_junk/trashdumpster01a.mdl",
    "models/props_c17/gravestone001a.mdl",
    "models/props_c17/gravestone002a.mdl",
    "models/props_c17/gravestone003a.mdl"
}