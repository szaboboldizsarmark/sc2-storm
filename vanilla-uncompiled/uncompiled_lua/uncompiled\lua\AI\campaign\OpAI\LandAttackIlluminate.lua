-- ChildrenTypes
--	 IlluminateTanks
--	 IlluminateAssaultBots
--	 IlluminateMobileAntiAir
--	 IlluminateMobileMissiles
--	 IlluminateMobileAntiMissiles
--	 IlluminateMobileArmorBoosters


-- Condition categories for Normal units, and Strong units
local NormalUnitCategories =(categories.uub0202 + categories.uib0202 + categories.ucb0202) +	-- all shields
							(categories.uub0101 + categories.uib0101 + categories.ucb0101 + categories.uub0104) + -- pd and uef art
							(((categories.MOBILE * categories.LAND) - categories.ENGINEER) + categories.COMMAND) + -- all land mobs minus engineers, but include cdr
							(categories.MOBILE * categories.AIR * categories.ANTISURFACE) + -- all air that can attack the ground
							(categories.FACTORY)

local StrongUnitCategories =(categories.EXPERIMENTAL) +
							(categories.NUKE + categories.uub0105 + categories.ucb0105)


-- Level 1 threshold and attack platoons:
local Illuminate_Level1_NormalUnits = 1

local Attack_Level1_1 = {{{ 'uil0101', 1 },},}		local Level1_1_Types = {'IlluminateTanks',}


-- Level 2 attacks:
local Illuminate_Level2_NormalUnits = 13

local Attack_Level2_1 = {{{ 'uil0101', 1 },{ 'uil0105', 1 },},}		local Level2_1_Types = {'IlluminateTanks', 'IlluminateMobileAntiAir',}
local Attack_Level2_2 = {{{ 'uil0101', 2 },},}						local Level2_2_Types = {'IlluminateTanks',}
local Attack_Level2_3 = {{{ 'uil0101', 1 },{ 'uil0103', 1 },},}		local Level2_3_Types = {'IlluminateTanks', 'IlluminateAssaultBots',}
local Attack_Level2_4 = {{{ 'uil0103', 2 },},}						local Level2_4_Types = {'IlluminateAssaultBots',}


-- Level 3 attacks:
local Illuminate_Level3_NormalUnits = 24

local Attack_Level3_1 = {{{ 'uil0101', 3 },},}						local Level3_1_Types = {'IlluminateTanks',}
local Attack_Level3_2 = {{{ 'uil0103', 3 },},}						local Level3_2_Types = {'IlluminateAssaultBots',}
local Attack_Level3_3 = {{{ 'uil0104', 2 },{ 'uil0105', 1 },},}		local Level3_3_Types = {'IlluminateMobileMissiles', 'IlluminateMobileAntiAir',}
local Attack_Level3_4 = {{{ 'uil0101', 2 },{ 'uil0105', 1 },},}		local Level3_4_Types = {'IlluminateTanks', 'IlluminateMobileAntiAir',}
local Attack_Level3_5 = {{{ 'uil0103', 2 },{ 'uil0104', 1 },},}		local Level3_5_Types = {'IlluminateAssaultBots', 'IlluminateMobileMissiles',}


-- Level 4 attacks:
local Illuminate_Level4_NormalUnits = 45
local Illuminate_Level4_StrongUnits = 1

local Attack_Level4_1 = {{{ 'uil0101', 4 },},}						local Level4_1_Types = {'IlluminateTanks',}
local Attack_Level4_2 = {{{ 'uil0103', 3 },{ 'uil0105', 1 },},}		local Level4_2_Types = {'IlluminateAssaultBots', 'IlluminateMobileAntiAir',}
local Attack_Level4_3 = {{{ 'uil0104', 4 },},}						local Level4_3_Types = {'IlluminateMobileMissiles',}
local Attack_Level4_4 = {{{ 'uil0103', 4 },},}						local Level4_4_Types = {'IlluminateAssaultBots',}
local Attack_Level4_5 = {{{ 'uil0105', 1 },{ 'uil0104', 3 },},}		local Level4_5_Types = {'IlluminateAssaultBots', 'IlluminateMobileMissiles',}
local Attack_Level4_6 = {{{ 'uil0101', 2 },{ 'uil0103', 1 },{ 'uil0203', 1 },},}		local Level4_6_Types = {'IlluminateTanks', 'IlluminateAssaultBots', 'IlluminateMobileAntiMissiles',}


-- Level 5 attacks:
local Illuminate_Level5_NormalUnits = 60
local Illuminate_Level5_StrongUnits = 2

local Attack_Level5_1 = {{{ 'uil0101', 3 },{ 'uil0103', 2 },},}						local Level5_1_Types = {'IlluminateTanks', 'IlluminateAssaultBots',}
local Attack_Level5_2 = {{{ 'uil0103', 3 },{ 'uil0104', 1 },{ 'uil0202', 1 },},}	local Level5_2_Types = {'IlluminateAssaultBots', 'IlluminateMobileMissiles', 'IlluminateMobileArmorBoosters',}
local Attack_Level5_3 = {{{ 'uil0104', 6 },},}										local Level5_3_Types = {'IlluminateTanks',}
local Attack_Level5_4 = {{{ 'uil0103', 5 },{ 'uil0202', 1 },},}						local Level5_4_Types = {'IlluminateAssaultBots', 'IlluminateMobileArmorBoosters',}
local Attack_Level5_5 = {{{ 'uil0101', 4 },{ 'uil0105', 1 },{ 'uil0203', 1 },},}	local Level5_5_Types = {'IlluminateTanks', 'IlluminateMobileAntiAir', 'IlluminateMobileAntiMissiles',}
local Attack_Level5_6 = {{{ 'uil0105', 1 },{ 'uil0104', 5 },},}						local Level5_6_Types = {'IlluminateMobileAntiAir', 'IlluminateMobileMissiles',}
local Attack_Level5_7 = {{{ 'uil0101', 2 },{ 'uil0103', 2 },{ 'uil0104', 2 },},}	local Level5_7_Types = {'IlluminateTanks', 'IlluminateAssaultBots', 'IlluminateMobileMissiles',}
local Attack_Level5_8 = {{{ 'uil0103', 1 },{ 'uil0104', 3 },{ 'uil0203', 1 },},}	local Level5_8_Types = {'IlluminateAssaultBots', 'IlluminateMobileMissiles', 'IlluminateMobileAntiMissiles',}


-- Level 6 attacks:
local Illuminate_Level6_NormalUnits = 78
local Illuminate_Level6_StrongUnits = 3

local Attack_Level6_1 = {{{ 'uil0101', 6 },{ 'uil0105', 1 },},}						local Level6_1_Types = {'IlluminateTanks', 'IlluminateMobileAntiAir',}
local Attack_Level6_2 = {{{ 'uil0103', 6 },{ 'uil0203', 1 },},}						local Level6_2_Types = {'IlluminateAssaultBots', 'IlluminateMobileAntiMissiles',}
local Attack_Level6_3 = {{{ 'uil0104', 6 },{ 'uil0202', 1 },},}						local Level6_3_Types = {'IlluminateMobileMissiles', 'IlluminateMobileArmorBoosters',}
local Attack_Level6_4 = {{{ 'uil0104', 7 },{ 'uil0203', 1 },},}						local Level6_4_Types = {'IlluminateMobileMissiles', 'IlluminateMobileAntiMissiles',}
local Attack_Level6_5 = {{{ 'uil0101', 3 },{ 'uil0103', 4 },{ 'uil0202', 1 },},}	local Level6_5_Types = {'IlluminateTanks', 'IlluminateAssaultBots', 'IlluminateMobileArmorBoosters',}
local Attack_Level6_6 = {{{ 'uil0103', 2 },{ 'uil0105', 1 },{ 'uil0104', 5 },},}	local Level6_6_Types = {'IlluminateAssaultBots', 'IlluminateMobileAntiAir', 'IlluminateMobileMissiles',}
local Attack_Level6_7 = {{{ 'uil0101', 2 },{ 'uil0103', 2 },{ 'uil0104', 2 },{ 'uil0203', 1 },{ 'uil0202', 1 },},}	local Level6_7_Types = {'IlluminateTanks', 'IlluminateAssaultBots', 'IlluminateMobileMissiles', 'IlluminateMobileAntiMissiles', 'IlluminateMobileArmorBoosters',}
local Attack_Level6_8 = {{{ 'uil0101', 3 },{ 'uil0105', 1 },{ 'uil0104', 4 },},}	local Level6_8_Types = {'IlluminateTanks', 'IlluminateMobileAntiAir', 'IlluminateMobileMissiles',}



--------------------------------
-- Level 1 Attacks, priority 200
--------------------------------

CAIOperationAIBlueprint	{
    -- AnnounceBuilder = true,

	Name = 'LandAttackIlluminate',
	DefaultAIBehavior =	'Nothing',
	ChildCount = 3,
	MaxActivePlatoons =	2,

	FactoryBuilders	= {
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level1_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level1_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level1_NormalUnits } },
				},
			},
			ChildrenTypes =	Level1_1_Types,
			Priority = 200,
		},


--------------------------------
-- Level 2 Attacks, priority 225
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level2_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level2_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_1_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level2_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level2_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_2_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level2_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level2_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_3_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level2_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level2_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_4_Types,
			Priority = 225,
		},

--------------------------------
-- Level 3 Attacks, priority 250
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level3_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level3_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_1_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level3_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level3_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_2_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level3_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level3_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_3_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level3_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level3_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_4_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level3_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level3_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_5_Types,
			Priority = 250,
		},

--------------------------------
-- Level 4 Attacks, priority 275
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level4_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level4_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_1_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level4_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level4_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_2_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level4_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level4_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_3_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level4_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level4_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_4_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level4_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level4_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_5_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level4_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level4_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_6_Types,
			Priority = 275,
		},

--------------------------------
-- Level 5 Attacks, priority 300
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_1_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_2_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_3_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_4_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_5_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_6_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_7',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_7_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level5_8',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level5_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_8_Types,
			Priority = 300,
		},

--------------------------------
-- Level 6 Attacks, priority 325
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_1_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_2_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_3_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_4_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_5_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_6_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_7',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_7_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LIlluminate_Level6_8',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Illuminate',
			Platoons = Attack_Level6_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Illuminate_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Illuminate_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_8_Types,
			Priority = 325,
		},
	},
}
