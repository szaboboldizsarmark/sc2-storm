--------------------------------------------------------------------------------------------------------------------------------
--
--   This table will be used by the command UI to build the command hud and evaluate requests when a button is clicked
--
--------------------------------------------------------------------------------------------------------------------------------

UIOrdersTable = {

    -- COMMON: Orders common to most units
    -- TODO: Attack ground for 360?
    RULEUCC_Move = {
    	name = "<LOC SC2_ABILITIES_0000>Move",
    	helpText = "<LOC SC2_ABILITIES_0001>Issue a Move command",
    	bitmapId = 'move',
    	preferredSlot = 1,
    	behavior = 'StandardOrderBehavior',
    	exclude_gamepad_menu = true,
    },
    RULEUCC_Attack = {
    	name = "<LOC SC2_ABILITIES_0002>Attack",
    	helpText = "<LOC SC2_ABILITIES_0003>Issue an Attack command on an enemy unit or at a position",
    	bitmapId = 'attack',
    	preferredSlot = 2,
    	behavior = 'StandardOrderBehavior',
    	exclude_gamepad_menu = true,
    	reticle = 'Attack',
    },
    RULEUCC_Patrol = {
    	name = "<LOC SC2_ABILITIES_0004>Patrol",
    	helpText = "<LOC SC2_ABILITIES_0005>Create a patrol for the selected unit (or units) to follow",
    	bitmapId = 'patrol',
    	preferredSlot = 3,
    	behavior = 'StandardOrderBehavior',
    	exclude_gamepad_menu = true,
    },
    RULEUCC_Stop = {
		name = "<LOC SC2_ABILITIES_0006>Stop",
      	helpText = "<LOC SC2_ABILITIES_0007>Issue an immediate Stop command for any unit or structure",
      	bitmapId = 'stop',
      	preferredSlot = 4,
      	behavior = 'MomentaryOrderBehavior',
      	slot_pos = 2,
    },
    -- PAUSE replaces STOP for certain structures (e.g. artillery)
    RULEUCC_Pause = {
        name = "<LOC SC2_ABILITIES_0066>Pause",
        helpText = "<LOC SC2_ABILITIES_000>Tells a unit to freeze any activity until unpaused",
        bitmapId = 'pause',
        preferredSlot = 4,
        behavior = 'MomentaryOrderBehavior',
      	slot_pos = 2,
    },
    RULEUCC_Guard = {
    	name = "<LOC SC2_ABILITIES_0008>Guard/Assist",
    	helpText = "<LOC SC2_ABILITIES_0009>Assign the currently selected unit to Guard another",
    	bitmapId = 'assist',
    	preferredSlot = 5,
    	behavior = 'StandardOrderBehavior',
    },
    RULEUCC_RetaliateToggle = {
    	name = "<LOC SC2_ABILITIES_0010>Retaliate Toggle",
    	helpText = "<LOC SC2_ABILITIES_0011>Placeholder",
    	bitmapId = 'firemode_ground',
    	preferredSlot = 6,
    	behavior = 'RetaliateOrderBehavior',
    	initialStateFunc = 'RetaliateInitFunction',
    	exclude_gamepad_menu = true,
    },
	RULEUCC_KillSelf = {
		name = "<LOC SC2_ABILITIES_0024>Self-Destruct",
		helpText = "<LOC SC2_ABILITIES_0025>Issues an immediate self destruct, damaging nearby enemies",
		bitmapId = 'stop',
		behavior = 'MomentaryOrderBehavior',
	},

    -- BUILDERS: orders common to Engineers/ACU
    RULEUCC_Reclaim = {
    	name = "<LOC SC2_ABILITIES_0030>Reclaim",
    	helpText = "<LOC SC2_ABILITIES_0031>Use the selected unit to reclaim wreckage for Mass",
    	bitmapId = 'reclaim',
    	preferredSlot = 7,
    	behavior = 'StandardOrderBehavior',
    	exclude_gamepad_menu = true,
    },
    RULEUCC_Capture = {
    	name = "<LOC SC2_ABILITIES_0032>Capture",
    	helpText = "<LOC SC2_ABILITIES_0033>Capture an enemy unit or structure, giving you control of the unit",
    	bitmapId = 'capture',
    	preferredSlot = 11,
    	behavior = 'StandardOrderBehavior',
    	exclude_gamepad_menu = true,
    	reticle = 'Attack',
    },
    RULEUCC_Repair = {
    	name = "<LOC SC2_ABILITIES_0034>Repair",
    	helpText = "<LOC SC2_ABILITIES_0035>Order the selected unit or units to repair the target",
    	bitmapId = 'repair',
    	preferredSlot = 12,
    	behavior = 'StandardOrderBehavior',
    },

    -- ACU: Common and factional ACU orders
	overcharge = {
    	name = "<LOC SC2_ABILITIES_0071>Enter Overcharge Mode",
    	helpText = "Placeholder: Overcharge your main gun. For when you need a bit of extra oomph.",
    	bitmapId = 'overcharge',
    	preferredSlot = 8,
    	slot_pos = 3,
    	behavior = 'StandardOrderBehavior',
    	onframe = 'OverChargeFrame',
    },
	escapepod = {
        -- TODO: move this to DPAD DOWN
		name = "<LOC SC2_ABILITIES_0044>Launch Escape Pod",
		helpText = "<LOC SC2_ABILITIES_0045>Detaches the ACU control center, allowing for a quick escape at the cost of having to reconstruct the ACU body",
		warningText = "<LOC SC2_ABILITIES_0069>Your ACU is about to self-destruct and launch an Escape Pod. Confirm?", -- YES/NO
		bitmapId = 'escapepod',
		preferredSlot = 13,
		slot_pos = 3,
	},
	acu_hunker = {
		name = "<LOC SC2_ABILITIES_0050>Hunker",
		helpText = "<LOC SC2_ABILITIES_0051>Orders unit to go into \"Hunker\" mode, increasing its defense but limiting its functionality",
		bitmapId = 'hunker',
		preferredSlot = 14,
		slot_pos = 0,
	},

    -- TRANSPORT/SUB
    RULEUCC_Transport = {
    	name = "<LOC SC2_ABILITIES_0016>Unload",
    	helpText = "<LOC SC2_ABILITIES_0017>Unload the transport",
    	bitmapId = 'transport',
    	preferredSlot = 9,
    	behavior = 'StandardOrderBehavior',
    },
    RULEUCC_Ferry = {
   		name = "<LOC SC2_ABILITIES_0022>Ferry",
   		helpText = "<LOC SC2_ABILITIES_0023>Establish a ferry route between two positions",
   		bitmapId = 'ferry',
   		preferredSlot = 8,
   		behavior = 'StandardOrderBehavior',
   	},
    RULEUCC_Dock = {
    	name = "Dock",
    	helpText = "Placeholder: dock",
    	bitmapId = 'transport',
    },
    RULEUCC_Dive = {
    	name = "<LOC SC2_ABILITIES_0028>Dive/Surface",
    	helpText = "<LOC SC2_ABILITIES_0029>Send the currently selected unit or units to the briny depths or bring it/them to the surface",
    	bitmapId = 'dive',
    	preferredSlot = 11,
		behavior = 'MomentaryOrderBehavior',
    	--behavior = 'DiveOrderBehavior',
    	initialStateFunc = 'DiveInitFunction',
    },

    -- STRUCTURES: structure abilities common to all factions
    -- nukes/anti-nukes
    RULEUCC_SiloBuildAntiNuke = {
    	name = "<LOC SC2_ABILITIES_0012>Build Anti-Nuke",
    	helpText = "Construct an Anti-Nuclear defensive weapon, which will be automatically fired if under attack",
    	bitmapId = 'silobuildantinuke',
    	preferredSlot = 10,
    	behavior = 'MomentaryOrderBehavior',
    	slot_pos = 1,
    },
    RULEUCC_SiloBuildRedirectNuke = {
    	name = "<LOC SC2_ABILITIES_0096>Build Re-Directing Nuke",
    	helpText = "Construct an Anti-Nuclear defensive weapon, which will automatically return attacks",
    	bitmapId = 'silobuildredirectnuke',
    	preferredSlot = 10,
    	behavior = 'MomentaryOrderBehavior',
    	slot_pos = 1,
    },
    RULEUCC_SiloBuildNuke = {
    	name = "<LOC SC2_ABILITIES_0014>Build Nuke",
    	helpText = "<LOC SC2_ABILITIES_0015>Construct a nuclear missile",
    	bitmapId = 'silobuildnuke',
    	preferredSlot = 8,
    	behavior = 'MomentaryOrderBehavior',
    	slot_pos = 0,
    },
    RULEUCC_Nuke = {
    	name = "<LOC SC2_ABILITIES_0018>Launch Nuke",
    	helpText = "<LOC SC2_ABILITIES_0019>Launch a targeted nuclear strike at the selected destination",
    	bitmapId = 'nuke',
    	preferredSlot = 9,
    	behavior = 'StandardOrderBehavior',
    	ButtonTextFunc = 'NukeBtnText',
    },
    RULEUCC_SiloBuildEMP = {
    	name = "<LOC SC2_ABILITIES_EMP_0000>Charge Anti-Shield EMP",
    	helpText = "Construct an EMP missile",
    	bitmapId = 'silobuildemp',
    	preferredSlot = 8,
    	behavior = 'MomentaryOrderBehavior',
    	slot_pos = 0,
    },
    RULEUCC_EMP = {
    	name = "<LOC SC2_ABILITIES_EMP_0001>Launch Anti-Shield EMP",
    	helpText = "Launch a targeted EMP strike at the selected destination",
    	bitmapId = 'emp',
    	preferredSlot = 9,
    	behavior = 'StandardOrderBehavior',
    	ButtonTextFunc = 'NukeBtnText',
    },
    -- mass converter
 	convertenergy = {
		name = "<LOC SC2_ABILITIES_0040>Convert Energy to Mass",
		helpText = "<LOC SC2_ABILITIES_0041>On selection, convert a pool of energy to mass",
		bitmapId = 'massconv',
		preferredSlot = 7,
	},
	-- research converter
 	convertresearch = {
		name = "<LOC SC2_ABILITIES_0072>Convert Research to Mass",
		helpText = "On selection, convert a research point to mass",
		bitmapId = 'massconv',
		preferredSlot = 7,
	},
	-- mass converter for Cybran only
 	convertenergyid = {
		name = "<LOC SC2_ABILITIES_0040>Convert Energy to Mass",
		helpText = "<LOC SC2_ABILITIES_0041>On selection, convert a pool of energy to mass",
		bitmapId = 'massconv',
		preferredSlot = 7,
	},
	-- experimental gantry
	halfbake = {
		name = "<LOC SC2_ABILITIES_0046>Launch Half-Baked",
		helpText = "<LOC SC2_ABILITIES_0047>Allows you to prematurely launch Experimental units, at the cost of a chance the unit will fail",
		bitmapId = 'halfbaked',
		preferredSlot = 7,
	},

	unitcannon_fire = {
    	name = "<LOC SC2_ABILITIES_UC_FIRE_0001>Launch Units",
    	helpText = "<LOC SC2_ABILITIES_UC_FIRE_0002>Launch units at a position",
    	bitmapId = 'attack',
    	preferredSlot = 2,
    	behavior = 'StandardOrderBehavior',
    	exclude_gamepad_menu = true,
    },

    -- FACTIONAL UNIT ABILITIES
    -- UEF+CYBRAN
	RULEUCC_Jump = {
		name = "<LOC SC2_ABILITIES_0038>Jump Jets",
		helpText = "<LOC SC2_ABILITIES_0039>Jumps the currently select unit or units to the targeted destination",
		bitmapId = 'jump',
		preferredSlot = 10,
		behavior = 'StandardOrderBehavior',
		initialStateFunc = 'JumpInitFunction',
	},
	-- UEF
	-- fortified artillery
	hardenartillery = {
		name = "<LOC SC2_ABILITIES_0048>Harden Mode",
		helpText = "<LOC SC2_ABILITIES_0049>Converts cannon into a high damage, short range unit for a set duration",
		preferredSlot = 7,
		bitmapId = 'hartillery',
	},
	-- Deploy
	deploy = {
		name = "<LOC SC2_ABILITIES_0082>Deploy",
		helpText = "Deploys the UDF Base Assault\'s main weapon",
		preferredSlot = 7,
		bitmapId = 'knockback',
	},
	-- Recharge Shield
	rechargeshield = {
		name = "<LOC SC2_ABILITIES_0084>Recharge Shield",
		helpText = "Recharges the Aegis shield",
		preferredSlot = 7,
		bitmapId = 'knockback',
	},
	-- Speed Overdrive
	speedoverdrive = {
		name = "<LOC SC2_ABILITIES_0079>Engage Afterburner",
		helpText = "Gives a momentary speed boost",
		preferredSlot = 7,
		bitmapId = 'speedoverdrive',
	},
	-- experimental disrupter station
	disruptorstation = {
	    name = "<LOC SC2_ABILITIES_0058>Activate Disruptor Station",
	    behavior = 'MomentaryOrderBehavior',
	    slot_pos = 3,
	    bitmapId = 'incdisruption',
		preferredSlot = 7,
	},
	-- CYBRAN
	powerdetonate = {
		name = "<LOC SC2_ABILITIES_0052>Detonate",
		helpText = "<LOC SC2_ABILITIES_0053>Initiates a self-destruct on the unit, damaging nearby enemies",
		warningText = "<LOC SC2_ABILITIES_001>You are about to Detonate these units. Confirm?", -- YES/NO
		behavior = 'MomentaryOrderBehavior',
		bitmapId = 'killself',
		preferredSlot = 8,
	},
	triarmorhalfspeed = {
		name = "<LOC SC2_ABILITIES_0056>Engage Mega Armor",
		helpText = "<LOC SC2_ABILITIES_0057>Increases Armor and reduces Movement Speed for a set duration",
		behavior = 'MomentaryOrderBehavior',
		bitmapId = 'halftriarmor',
		preferredSlot = 9,
		slot_pos = 3,
	},
	mobile_hunker = {
		name = "<LOC SC2_ABILITIES_0050>Hunker",
		helpText = "<LOC SC2_ABILITIES_0051>Orders unit to go into \"Hunker\" mode, increasing its defense but limiting its functionality",
		bitmapId = 'hunker',
		preferredSlot = 14,
		slot_pos = 0,
	},
	-- bomb bouncer
	bombbouncercharge = {
        name = "<LOC SC2_ABILITIES_0059>Mega Blast Manual Charge",
        bitmapId = 'bbouncecharge',
        slot_pos = 3,
		preferredSlot = 11,
	},
	bombbouncermegablast = {
	    name = "<LOC SC2_ABILITIES_0060>Activate Mega Blast",
        bitmapId = 'bbouncedamage',
        slot_pos = 0,
		preferredSlot = 12,
	},
	-- experimental unit magnet
	magnet = {
	    name = "<LOC SC2_ABILITIES_0061>Activate Attractor",
        bitmapId = 'magnetpull',
        slot_pos = 3,
		preferredSlot = 11,
	},
	magnetpush = {
	    name = "<LOC SC2_ABILITIES_0062>Activate Repulsor",
        bitmapId = 'magnetpush',
        slot_pos = 0,
		preferredSlot = 12,
	},
	-- sneak-o-tron
	stealthfield = {
	    name = "<LOC SC2_ABILITIES_0088>Active Stealth Field",
        bitmapId = 'knockback',
        slot_pos = 0,
		preferredSlot = 7,
	},
	-- acu
	knockbackweapon = {
	    name = "<LOC SC2_ABILITIES_0063>Knockback",
        bitmapId = 'knockback',
        slot_pos = 1,
		preferredSlot = 9,
	},
	-- ILLUMINATE
    RULEUCC_Teleport = {
    	name = "<LOC SC2_ABILITIES_0020>Teleport",
    	helpText = "<LOC SC2_ABILITIES_0021>Instantly teleport the current unit or units from the current position to the destination",
    	bitmapId = 'teleport',
    	preferredSlot = 10,
    	behavior = 'StandardOrderBehavior',
    },
    RULEUCC_Sacrifice = {
    	name = "<LOC SC2_ABILITIES_0026>Sacrifice Capture",
    	helpText = "<LOC SC2_ABILITIES_0027>Sacrifice this unit to instantly capture an enemy unit.",
    	bitmapId = 'sacrifice',
    	preferredSlot = 13,
    	behavior = 'StandardOrderBehavior',
    },
	-- Structure Sacrifice
	structuresacrifice = {
		name = "<LOC SC2_ABILITIES_0089>Sacrifice",
		helpText = "<LOC SC2_ABILITIES_0090>Sacrifices the unit, healing nearby allies",
		warningText = "<LOC SC2_ABILITIES_002>You are about to Sacrifice these units. Confirm?", -- YES/NO
		behavior = 'MomentaryOrderBehavior',
		bitmapId = 'killself',
		preferredSlot = 8,
	},
    -- point defense
    point_defense_hunker = {
        name = "<LOC SC2_ABILITIES_0050>Hunker",
        helpText = "<LOC SC2_ABILITIES_0051>Orders unit to go into \"Hunker\" mode, increasing its defense but limiting its functionality",
		bitmapId = 'hunker',
		preferredSlot = 14,
		slot_pos = 0,
    },
    -- energy production facility
	electroshock = {
		name = "<LOC SC2_ABILITIES_0042>Electroshock",
		helpText = "<LOC SC2_ABILITIES_0043>Switches unit from producing to defending itself with a land-targeting energy beam weapon for a set period",
		bitmapId = 'electroshock',
		preferredSlot = 7,
	},
	-- radar
	radaroverdrive = {
		name = "<LOC SC2_ABILITIES_0054>Overdrive",
		helpText = "<LOC SC2_ABILITIES_0055>Increases Vision and Radar range for a set duration",
		bitmapId = 'radarovd',
		preferredSlot = 7,
	},
	-- radar overdrive experimental edition
	radaroverdrivexp = {
		name = "<LOC SC2_ABILITIES_0054>Overdrive",
		helpText = "<LOC SC2_ABILITIES_0055>Increases Vision and Radar range for a set duration",
		bitmapId = 'radarovd',
		preferredSlot = 7,
	},
	-- experimental magnetron
    pullinsmash = {
        name = "<LOC SC2_ABILITIES_0064>Activate/Deactivate Vortex",
        bitmapId = 'pullinsmash',
        slot_pos = 3,
		preferredSlot = 7,
    },
    -- acu
    roguenanites = {
        name = "<LOC SC2_ABILITIES_0065>Rogue Nanites",
        bitmapId = 'roguenanites',
        slot_pos = 1,
		preferredSlot = 9,
    },
	-- Shield Smasher
	shieldsmash = {
	    name = "<LOC SC2_ABILITIES_0091>Shield Smash",
        bitmapId = 'knockback',
        slot_pos = 0,
		preferredSlot = 7,
	},
--    templebeacon = {
--    	name = "<LOC SC2_ABILITIES_0067>Set Teleport Beacon",
--    	helpText = "<LOC SC2_ABILITIES_0068>Sets the teleport destination for the Space Temple",
--    	bitmapId = 'teleport',
--    	preferredSlot = 10,
--    	behavior = 'StandardOrderBehavior',
--    },

    --
    -- UNUSED: All unused beyond this point?
    --

    RULEUCC_Script = {
    	name = "Script",
    	helpText = "Placeholder: special_action",
    	bitmapId = 'overcharge',
    	preferredSlot = 8,
    	behavior = 'StandardOrderBehavior',
    	exclude_gamepad_menu = true,
    },
	RULEUCC_Ability = {
		name = "Ability",
		helpText = "Placeholder: ability",
		bitmapId = 'production',
		preferredSlot = 10,
	},
    -- Unit toggle rules
    RULEUTC_ShieldToggle = {
    	name = "Shield",
    	helpText = "Placeholder: toggle_shield",
    	bitmapId = 'shield',
    	preferredSlot = 8,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 0,
    },
    RULEUTC_WeaponToggle = {
    	name = "Weapon",
    	helpText = "Placeholder: toggle_weapon",
    	bitmapId = 'toggle-weapon',
    	preferredSlot = 8,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 1,
    },
    RULEUTC_JammingToggle = {
    	name = "Jamming",
    	helpText = "Placeholder: toggle_jamming",
    	bitmapId = 'jamming',
    	preferredSlot = 9,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 2,
    },
    RULEUTC_IntelToggle = {
    	name = "Intel",
    	helpText = "Placeholder: toggle_intel",
    	bitmapId = 'intel',
    	preferredSlot = 9,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 3,},
    RULEUTC_ProductionToggle = {
    	name = "Production",
    	helpText = "Placeholder: toggle_production",
    	bitmapId = 'production',
    	preferredSlot = 10,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 4,
    },
    RULEUTC_StealthToggle = {
    	name = "Stealth",
    	helpText = "Placeholder: toggle_stealth",
    	bitmapId = 'stealth',
    	preferredSlot = 10,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 5,
    },
    RULEUTC_GenericToggle = {
    	name = "Generic",
    	helpText = "Placeholder: toggle_generic",
    	bitmapId = 'production',
    	preferredSlot = 11,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 6,
    },
    RULEUTC_SpecialToggle = {
    	name = "Special",
    	helpText = "Placeholder: toggle_special",
    	bitmapId = 'activate-weapon',
    	preferredSlot = 12,
    	behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 7,
    },
    RULEUTC_CloakToggle = {
    	name = "Cloak",
    	helpText = "Placeholder: toggle_cloak",
    	bitmapId = 'intel-counter',
    	preferredSlot = 12, behavior = 'ScriptButtonOrderBehavior',
    	initialStateFunc = 'ScriptButtonInitFunction',
    	extraInfo = 8,
    },
}
