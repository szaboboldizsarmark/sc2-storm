-- ChildrenTypes
--   UEFFighters
--   UEFBombers
--   UEFGunships


-- Condition categories for Normal units, and Strong units
local NormalUnitCategories =(categories.uub0202 + categories.uib0202 + categories.ucb0202) +	-- all shields
							(categories.uub0101 + categories.uib0101 + categories.ucb0101 + categories.uub0104) + -- pd and uef art
							(((categories.MOBILE * categories.LAND) - categories.ENGINEER) + categories.COMMAND) + -- all land mobs minus engineers, but include cdr
							(categories.AIR) + -- all air (fighters included)
							(categories.FACTORY)

local StrongUnitCategories =(categories.EXPERIMENTAL) +
							(categories.NUKE + categories.uub0105 + categories.ucb0105)


-- Level 1 threshold and attack platoons:
local UEF_Level1_NormalUnits = 1

local Attack_Level1_1 = {{{ 'uua0101', 1 },},}		local Level1_1_Types = {'UEFFighters',}
local Attack_Level1_2 = {{{ 'uua0101', 1 },},}		local Level1_2_Types = {'UEFFighters',}
local Attack_Level1_3 = {{{ 'uua0102', 1 },},}		local Level1_3_Types = {'UEFBombers',}


-- Level 2 threshold and attack platoons:
local UEF_Level2_NormalUnits = 12

local Attack_Level2_1 = {{{ 'uua0101', 1 },},}		local Level2_1_Types = {'UEFFighters',}
local Attack_Level2_2 = {{{ 'uua0102', 1 },},}		local Level2_2_Types = {'UEFBombers',}


-- Level 3 threshold and attack platoons:
local UEF_Level3_NormalUnits = 23

local Attack_Level3_1 = {{{ 'uua0102', 1 },},}		local Level3_1_Types = {'UEFBombers',}
local Attack_Level3_2 = {{{ 'uua0101', 1 },{ 'uua0102', 1 },},}		local Level3_2_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level3_3 = {{{ 'uua0101', 1 },{ 'uua0102', 1 },},}		local Level3_3_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level3_4 = {{{ 'uua0101', 2 },},}		local Level3_4_Types = {'UEFFighters',}


-- Level 4 threshold and attack platoons:
local UEF_Level4_NormalUnits = 35

local Attack_Level4_1 = {{{ 'uua0101', 3 },},}		local Level4_1_Types = {'UEFFighters',}
local Attack_Level4_2 = {{{ 'uua0101', 2 },{ 'uua0102', 1 },},}		local Level4_2_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level4_3 = {{{ 'uua0101', 1 },{ 'uua0102', 2 },},}		local Level4_3_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level4_4 = {{{ 'uua0101', 2 },{ 'uua0103', 1 },},}		local Level4_4_Types = {'UEFFighters', 'UEFGunships',}
local Attack_Level4_5 = {{{ 'uua0103', 2 },},}		local Level4_5_Types = {'UEFGunships',}


-- Level 5 threshold and attack platoons:
local UEF_Level5_NormalUnits = 55

local Attack_Level5_1 = {{{ 'uua0102', 3 },},}		local Level5_1_Types = {'UEFBombers',}
local Attack_Level5_2 = {{{ 'uua0103', 3 },},}		local Level5_2_Types = {'UEFGunships',}
local Attack_Level5_3 = {{{ 'uua0101', 1 },{ 'uua0103', 2 },},}		local Level5_3_Types = {'UEFFighters', 'UEFGunships',}
local Attack_Level5_4 = {{{ 'uua0101', 1 },{ 'uua0102', 2 },},}		local Level5_4_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level5_5 = {{{ 'uua0102', 2 },{ 'uua0103', 1 },},}		local Level5_5_Types = {'UEFBombers', 'UEFGunships',}


-- Level 6 threshold and attack platoons:
local UEF_Level6_NormalUnits = 75

local Attack_Level6_1 = {{{ 'uua0101', 4 },},}		local Level6_1_Types = {'UEFFighters',}
local Attack_Level6_2 = {{{ 'uua0101', 1 },{ 'uua0102', 3 },},}		local Level6_2_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level6_3 = {{{ 'uua0101', 3 },},}		local Level6_3_Types = {'UEFFighters',}
local Attack_Level6_4 = {{{ 'uua0101', 2 },{ 'uua0102', 2 },},}		local Level6_4_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level6_5 = {{{ 'uua0101', 2 },{ 'uua0103', 2 },},}		local Level6_5_Types = {'UEFFighters', 'UEFGunships',}
local Attack_Level6_6 = {{{ 'uua0102', 3 },{ 'uua0103', 1 },},}		local Level6_6_Types = {'UEFBombers', 'UEFGunships',}
local Attack_Level6_7 = {{{ 'uua0102', 1 },{ 'uua0103', 3 },},}		local Level6_7_Types = {'UEFBombers', 'UEFGunships',}


-- Level 7 threshold and attack platoons:
local UEF_Level7_NormalUnits = 100
local UEF_Level7_StrongUnits = 1

local Attack_Level7_1 = {{{ 'uua0101', 4 },{ 'uua0102', 1 },},}		local Level7_1_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level7_2 = {{{ 'uua0102', 5 },},}		local Level7_2_Types = {'UEFBombers',}
local Attack_Level7_3 = {{{ 'uua0103', 5 },},}		local Level7_3_Types = {'UEFGunships',}
local Attack_Level7_4 = {{{ 'uua0103', 5 },},}		local Level7_4_Types = {'UEFGunships',}
local Attack_Level7_5 = {{{ 'uua0101', 1 },{ 'uua0102', 4 },},}		local Level7_5_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level7_6 = {{{ 'uua0102', 2 },{ 'uua0103', 3 },},}		local Level7_6_Types = {'UEFBombers', 'UEFGunships',}
local Attack_Level7_7 = {{{ 'uua0102', 3 },{ 'uua0103', 2 },},}		local Level7_7_Types = {'UEFBombers', 'UEFGunships',}
local Attack_Level7_8 = {{{ 'uua0101', 2 },{ 'uua0103', 3 },},}		local Level7_8_Types = {'UEFFighters', 'UEFGunships',}


-- Level 8 threshold and attack platoons:
local UEF_Level8_NormalUnits = 140
local UEF_Level8_StrongUnits = 2

local Attack_Level8_1 = {{{ 'uua0101', 5 },{ 'uua0102', 1 },},}		local Level8_1_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level8_2 = {{{ 'uua0102', 6 },},}		local Level8_2_Types = {'UEFBombers',}
local Attack_Level8_3 = {{{ 'uua0103', 6 },},}		local Level8_3_Types = {'UEFGunships',}
local Attack_Level8_4 = {{{ 'uua0102', 3 },{ 'uua0103', 3 },},}		local Level8_4_Types = {'UEFBombers', 'UEFGunships',}
local Attack_Level8_5 = {{{ 'uua0101', 3 },{ 'uua0103', 3 },},}		local Level8_5_Types = {'UEFFighters', 'UEFGunships',}
local Attack_Level8_6 = {{{ 'uua0101', 2 },{ 'uua0102', 4 },},}		local Level8_6_Types = {'UEFFighters', 'IlluminateMobileAntiAir',}
local Attack_Level8_7 = {{{ 'uua0101', 1 },{ 'uua0103', 5 },},}		local Level8_7_Types = {'IlluminateTanks', 'UEFBombers',}
local Attack_Level8_8 = {{{ 'uua0102', 2 },{ 'uua0103', 4 },},}		local Level8_8_Types = {'UEFBombers', 'UEFGunships',}



-- Level 9 threshold and attack platoons:
local UEF_Level9_NormalUnits = 175
local UEF_Level9_StrongUnits = 3

local Attack_Level9_1 = {{{ 'uua0101', 1 },{ 'uua0102', 2 },},}		local Level9_1_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level9_2 = {{{ 'uua0102', 7 },},}		local Level9_2_Types = {'UEFBombers',}
local Attack_Level9_3 = {{{ 'uua0103', 7 },},}		local Level9_3_Types = {'UEFGunships',}
local Attack_Level9_4 = {{{ 'uua0102', 1 },{ 'uua0103', 2 },},}		local Level9_4_Types = {'UEFBombers', 'UEFGunships',}
local Attack_Level9_5 = {{{ 'uua0101', 2 },{ 'uua0102', 5 },},}		local Level9_5_Types = {'UEFFighters', 'UEFBombers',}
local Attack_Level9_6 = {{{ 'uua0101', 2 },{ 'uua0103', 5 },},}		local Level9_6_Types = {'UEFFighters', 'UEFGunships',}
local Attack_Level9_7 = {{{ 'uua0102', 3 },{ 'uua0103', 4 },},}		local Level9_7_Types = {'UEFBombers', 'UEFGunships',}
local Attack_Level9_8 = {{{ 'uua0102', 4 },{ 'uua0103', 3 },},}		local Level9_8_Types = {'UEFBombers', 'UEFGunships',}


--------------------------------
-- Level 1 Attacks, priority 200
--------------------------------

CAIOperationAIBlueprint	{
    AnnounceBuilder = true,

	Name = 'AirAttackUEF',
	DefaultAIBehavior =	'Nothing',
	ChildCount = 3,
	MaxActivePlatoons =	2,

	FactoryBuilders	= {
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level1_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
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
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level1_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level1_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level1_NormalUnits } },
				},
			},
			ChildrenTypes =	Level1_2_Types,
			Priority = 200,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level1_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level1_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level1_NormalUnits } },
				},
			},
			ChildrenTypes =	Level1_3_Types,
			Priority = 200,
		},

--------------------------------
-- Level 2 Attacks, priority 215
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level2_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level2_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_1_Types,
			Priority = 215,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level2_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level2_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_2_Types,
			Priority = 215,
		},

--------------------------------
-- Level 3 Attacks, priority 230
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level3_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level3_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_1_Types,
			Priority = 230,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level3_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level3_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_2_Types,
			Priority = 230,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level3_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level3_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_3_Types,
			Priority = 230,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level3_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level3_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_4_Types,
			Priority = 230,
		},

--------------------------------
-- Level 4 Attacks, priority 245
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level4_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level4_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_1_Types,
			Priority = 245,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level4_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level4_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_2_Types,
			Priority = 245,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level4_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level4_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_3_Types,
			Priority = 245,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level4_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level4_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_4_Types,
			Priority = 245,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level4_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level4_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_5_Types,
			Priority = 245,
		},

--------------------------------
-- Level 5 Attacks, priority 260
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level5_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level5_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_1_Types,
			Priority = 260,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level5_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level5_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_2_Types,
			Priority = 260,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level5_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level5_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_3_Types,
			Priority = 260,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level5_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level5_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_4_Types,
			Priority = 260,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level5_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level5_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_5_Types,
			Priority = 260,
		},

--------------------------------
-- Level 6 Attacks, priority 275
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level6_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level6_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
			},
			ChildrenTypes =	Level6_1_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level6_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level6_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
			},
			ChildrenTypes =	Level6_2_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level6_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level6_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
			},
			ChildrenTypes =	Level6_3_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level6_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level6_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
			},
			ChildrenTypes =	Level6_4_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level6_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level6_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
			},
			ChildrenTypes =	Level6_5_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level6_6',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level6_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
			},
			ChildrenTypes =	Level6_6_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level6_7',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level6_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level6_NormalUnits } },
				},
			},
			ChildrenTypes =	Level6_7_Types,
			Priority = 275,
		},

--------------------------------
-- Level 7 Attacks, priority 290
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_1_Types,
			Priority = 290,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_2_Types,
			Priority = 290,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_3_Types,
			Priority = 290,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_4_Types,
			Priority = 290,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_5_Types,
			Priority = 290,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_6',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_6_Types,
			Priority = 290,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_7',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_7_Types,
			Priority = 290,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level7_8',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level7_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_8_Types,
			Priority = 290,
		},

--------------------------------
-- Level 8 Attacks, priority 305
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_1_Types,
			Priority = 305,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_2_Types,
			Priority = 305,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_3_Types,
			Priority = 305,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_4_Types,
			Priority = 305,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_5_Types,
			Priority = 305,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_6',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_6_Types,
			Priority = 305,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_7',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_7_Types,
			Priority = 305,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level8_8',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level8_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_8_Types,
			Priority = 305,
		},

--------------------------------
-- Level 9 Attacks, priority 320
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_1_Types,
			Priority = 320,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_2_Types,
			Priority = 320,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_3_Types,
			Priority = 320,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_4_Types,
			Priority = 320,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_5_Types,
			Priority = 320,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_6',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_6_Types,
			Priority = 320,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_7',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_7_Types,
			Priority = 320,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'AUEF_Level9_8',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'UEF',
			Platoons = Attack_Level9_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, UEF_Level9_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, UEF_Level9_StrongUnits } },
				},
			},
			ChildrenTypes =	Level9_8_Types,
			Priority = 320,
		},
	},
}