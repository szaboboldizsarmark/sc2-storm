-- ChildrenTypes
--   UEFTanks
--   UEFMobileArtillery
--   UEFAssaultBots
--   UEFMobileAntiAir
--   UEFMobileMissiles
--   UEFMobileAntiMissiles
--   UEFMobileShields


-- Condition categories for Normal units, and Strong units
local NormalUnitCategories =(categories.uub0202 + categories.uib0202 + categories.ucb0202) +	-- all shields
							(categories.uub0101 + categories.uib0101 + categories.ucb0101 + categories.uub0104) + -- pd and uef art
							(((categories.MOBILE * categories.LAND) - categories.ENGINEER) + categories.COMMAND) + -- all land mobs minus engineers, but include cdr
							(categories.MOBILE * categories.AIR * categories.ANTISURFACE) + -- all air that can attack the ground
							(categories.FACTORY)

local StrongUnitCategories =(categories.EXPERIMENTAL) +
							(categories.NUKE + categories.uub0105 + categories.ucb0105)


-- Level 1 threshold and attack platoons:
local UEF_Level1_NormalUnits = 1

local Attack_Level1_1 = {{{ 'uul0101', 1 },},}		local Level1_1_Types = {'UEFTanks',}


-- Level 2 threshold and attack platoons:
local UEF_Level2_NormalUnits = 8

local Attack_Level2_1 = {{{ 'uul0101', 2 },},}						local Level2_1_Types = {'UEFTanks',}
local Attack_Level2_2 = {{{ 'uul0103', 2 },},}						local Level2_2_Types = {'UEFAssaultBots',}
local Attack_Level2_3 = {{{ 'uul0101', 1 },{ 'uul0102', 1 },},}		local Level2_3_Types = {'UEFTanks', 'UEFMobileArtillery',}
local Attack_Level2_4 = {{{ 'uul0101', 1 },{ 'uul0103', 1 },},}		local Level2_4_Types = {'UEFTanks', 'UEFAssaultBots',}
local Attack_Level2_5 = {{{ 'uul0101', 1 },{ 'uul0105', 1 },},}		local Level2_5_Types = {'UEFTanks', 'UEFMobileAntiAir',}


-- Level 3 threshold and attack platoons:
local UEF_Level3_NormalUnits = 17

local Attack_Level3_1 = {{{ 'uul0101', 3 },},}						local Level3_1_Types = {'UEFTanks',}
local Attack_Level3_2 = {{{ 'uul0103', 3 },},}						local Level3_2_Types = {'UEFAssaultBots',}
local Attack_Level3_3 = {{{ 'uul0102', 3 },},}						local Level3_3_Types = {'UEFMobileArtillery',}
local Attack_Level3_4 = {{{ 'uul0104', 3 },},}						local Level3_4_Types = {'UEFMobileMissiles',}
local Attack_Level3_5 = {{{ 'uul0101', 2 },{ 'uul0105', 1 },},}		local Level3_5_Types = {'UEFTanks', 'UEFMobileAntiAir',}
local Attack_Level3_6 = {{{ 'uul0103', 2 },{ 'uul0105', 1 },},}		local Level3_6_Types = {'UEFAssaultBots', 'UEFMobileAntiAir',}


-- Level 4 attacks:
local UEF_Level4_NormalUnits = 33
local UEF_Level4_StrongUnits = 1

local Attack_Level4_1 = {{{ 'uul0101', 4 },},}						local Level4_1_Types = {'UEFTanks',}
local Attack_Level4_2 = {{{ 'uul0103', 4 },},}						local Level4_2_Types = {'UEFAssaultBots',}
local Attack_Level4_3 = {{{ 'uul0102', 4 },},}						local Level4_3_Types = {'UEFMobileArtillery',}
local Attack_Level4_4 = {{{ 'uul0104', 4 },},}						local Level4_4_Types = {'UEFMobileMissiles',}
local Attack_Level4_5 = {{{ 'uul0101', 3 },{ 'uul0201', 1 },},}		local Level4_5_Types = {'UEFTanks', 'UEFMobileShields',}
local Attack_Level4_6 = {{{ 'uul0103', 3 },{ 'uul0105', 1 },},}		local Level4_6_Types = {'UEFAssaultBots', 'UEFMobileAntiAir',}
local Attack_Level4_7 = {{{ 'uul0102', 2 },{ 'uul0104', 1 },{ 'uul0105', 1 },},}		local Level4_7_Types = {'UEFMobileArtillery', 'UEFMobileMissiles', 'UEFMobileAntiAir',}
local Attack_Level4_8 = {{{ 'uul0101', 1 },{ 'uul0104', 2 },{ 'uul0201', 1 },},}		local Level4_8_Types = {'UEFTanks', 'UEFMobileMissiles', 'UEFMobileShields',}


-- Level 5 attacks:
local UEF_Level5_NormalUnits = 48
local UEF_Level5_StrongUnits = 2

local Attack_Level5_1 = {{{ 'uul0101', 4 },{ 'uul0201', 1 },},}		local Level5_1_Types = {'UEFTanks', 'UEFMobileShields',}
local Attack_Level5_2 = {{{ 'uul0103', 4 },{ 'uul0203', 1 },},}		local Level5_2_Types = {'UEFAssaultBots', 'UEFMobileAntiMissiles',}
local Attack_Level5_3 = {{{ 'uul0104', 4 },{ 'uul0203', 1 },},}		local Level5_3_Types = {'UEFMobileMissiles', 'UEFMobileAntiMissiles',}
local Attack_Level5_4 = {{{ 'uul0102', 5 },{ 'uul0201', 1 },},}		local Level5_4_Types = {'UEFMobileArtillery', 'UEFMobileShields',}
local Attack_Level5_5 = {{{ 'uul0101', 3 },{ 'uul0103', 2 },{ 'uul0105', 1 },},}		local Level5_5_Types = {'UEFTanks', 'UEFAssaultBots', 'UEFMobileAntiAir',}
local Attack_Level5_6 = {{{ 'uul0104', 4 },{ 'uul0105', 1 },{ 'uul0201', 1 },},}		local Level5_6_Types = {'UEFMobileMissiles', 'UEFMobileAntiAir', 'UEFMobileShields',}
local Attack_Level5_7 = {{{ 'uul0104', 5 },{ 'uul0203', 1 },},}		local Level5_7_Types = {'UEFMobileMissiles', 'UEFMobileAntiMissiles',}
local Attack_Level5_8 = {{{ 'uul0102', 5 },{ 'uil0201', 1 },},}		local Level5_8_Types = {'UEFMobileArtillery', 'UEFMobileShields',}
local Attack_Level5_9 = {{{ 'uil0103', 4 },{ 'uil0201', 2 },},}		local Level5_9_Types = {'UEFAssaultBots', 'UEFMobileShields',}


-- Level 6 attacks:
local UEF_Level6_NormalUnits = 69
local UEF_Level6_StrongUnits = 3

local Attack_Level6_1 = {{{ 'uul0101', 6 },{ 'uul0201', 1 },},}		local Level6_1_Types = {'UEFTanks', 'UEFMobileShields',}
local Attack_Level6_2 = {{{ 'uul0103', 6 },{ 'uul0203', 1 },},}		local Level6_2_Types = {'UEFAssaultBots', 'UEFMobileAntiMissiles',}
local Attack_Level6_3 = {{{ 'uul0104', 7 },{ 'uul0203', 1 },},}		local Level6_3_Types = {'UEFMobileMissiles', 'UEFMobileAntiMissiles',}
local Attack_Level6_4 = {{{ 'uul0102', 6 },{ 'uul0201', 2 },},}		local Level6_4_Types = {'UEFMobileArtillery', 'UEFMobileShields',}
local Attack_Level6_5 = {{{ 'uul0101', 2 },{ 'uul0103', 1 },{ 'uul0105', 1 },},}		local Level6_5_Types = {'UEFTanks', 'IlluminateAssaultBots', 'IlluminateMobileAntiMissiles',}
local Attack_Level6_6 = {{{ 'uul0101', 2 },{ 'uul0103', 2 },{ 'uul0102', 3 },{ 'uul0105', 1 },},}		local Level6_6_Types = {'IlluminateTanks', 'UEFAssaultBots', 'UEFMobileArtillery', 'UEFMobileAntiAir',}
local Attack_Level6_7 = {{{ 'uul0102', 1 },{ 'uul0104', 5 },{ 'uul0201', 1 },},}		local Level6_7_Types = {'UEFMobileArtillery', 'UEFMobileMissiles', 'UEFMobileShields',}
local Attack_Level6_8 = {{{ 'uul0103', 2 },{ 'uul0102', 5 },{ 'uul0201', 1 },},}		local Level6_8_Types = {'UEFAssaultBots', 'UEFMobileArtillery', 'UEFMobileShields',}
local Attack_Level6_9 = {{{ 'uul0101', 5 },{ 'uul0102', 1 },{ 'uul0201', 2 },},}		local Level6_9_Types = {'UEFTanks', 'UEFMobileArtillery', 'UEFMobileShields',}


--------------------------------
-- Level 1 Attacks, priority 200
--------------------------------

CAIOperationAIBlueprint	{
    --AnnounceBuilder = true,

	Name = 'LandAttackUEF',
	DefaultAIBehavior =	'Nothing',
	ChildCount = 3,
	MaxActivePlatoons =	2,

	FactoryBuilders	= {
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level1_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level1_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level1_NormalUnits } },
				},
			},
			ChildrenTypes =	Level1_1_Types,
			Priority = 200,
		},

--------------------------------
-- Level 2 Attacks, priority 225
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level2_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level2_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_1_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level2_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level2_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_2_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level2_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level2_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_3_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level2_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level2_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_4_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level2_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level2_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_5_Types,
			Priority = 225,
		},

--------------------------------
-- Level 3 Attacks, priority 250
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level3_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level3_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_1_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level3_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level3_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_2_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level3_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level3_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_3_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level3_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level3_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_4_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level3_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level3_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_5_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level3_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level3_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_6_Types,
			Priority = 250,
		},

--------------------------------
-- Level 4 Attacks, priority 275
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_1_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_2_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_3_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_4_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_5_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_6_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_7',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_7_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level4_8',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level4_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_8_Types,
			Priority = 275,
		},

--------------------------------
-- Level 5 Attacks, priority 300
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_1_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_2_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_3_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_4_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_5_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_6_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_7',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_7_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_8',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_8_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level5_9',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level5_9,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_9_Types,
			Priority = 300,
		},

--------------------------------
-- Level 6 Attacks, priority 325
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_1_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_2_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_3_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_4_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_5_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_61',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_6_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_7',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_7_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_8',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_8_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LUEF_Level6_9',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'UEF',
			Platoons = Attack_Level6_9,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_9_Types,
			Priority = 325,
		},
	},
}
