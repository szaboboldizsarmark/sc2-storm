-- ChildrenTypes
--   CybranFighterBombers
--   CybranGunships


-- Condition categories for Normal units, and Strong units
local NormalUnitCategories =(categories.uub0202 + categories.uib0202 + categories.ucb0202) +	-- all shields
							(categories.uub0101 + categories.uib0101 + categories.ucb0101 + categories.uub0104) + -- pd and uef art
							(((categories.MOBILE * categories.LAND) - categories.ENGINEER) + categories.COMMAND) + -- all land mobs minus engineers, but include cdr
							(categories.AIR) + -- all air (fighters included)
							(categories.FACTORY) +
							(categories.COMMAND)


local StrongUnitCategories =(categories.EXPERIMENTAL) +
							(categories.NUKE + categories.uub0105 + categories.ucb0105)


-- Level 1 threshold and attack platoons:
local Cybran_Level1_NormalUnits = 1

local Attack_Level1_1 = {{{ 'uca0104', 1 },},}		local Level1_1_Types = {'CybranFighterBombers',}


-- Level 2 threshold and attack platoons:
local Cybran_Level2_NormalUnits = 12

local Attack_Level2_1 = {{{ 'uca0104', 2 },},}		local Level2_1_Types = {'CybranFighterBombers',}


-- Level 3 threshold and attack platoons:
local Cybran_Level3_NormalUnits = 30

local Attack_Level3_1 = {{{ 'uca0104', 2 },},}		local Level3_1_Types = {'CybranFighterBombers',}
local Attack_Level3_2 = {{{ 'uca0104', 1 },{ 'uca0103', 1 },},}		local Level3_2_Types = {'CybranFighterBombers', 'CybranGunships',}


-- Level 4 threshold and attack platoons:
local Cybran_Level4_NormalUnits = 55

local Attack_Level4_1 = {{{ 'uca0104', 3 },},}		local Level4_1_Types = {'CybranFighterBombers',}
local Attack_Level4_2 = {{{ 'uca0103', 3 },},}		local Level4_2_Types = {'CybranGunships',}
local Attack_Level4_3 = {{{ 'uca0104', 1 },{ 'uca0103', 2 },},}		local Level4_3_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level4_4 = {{{ 'uca0103', 2 },},}		local Level4_4_Types = {'CybranGunships',}


-- Level 5 threshold and attack platoons:
local Cybran_Level5_NormalUnits = 75

local Attack_Level5_1 = {{{ 'uca0103', 3 },},}		local Level5_1_Types = {'CybranGunships',}
local Attack_Level5_2 = {{{ 'uca0104', 4 },},}		local Level5_2_Types = {'CybranFighterBombers',}
local Attack_Level5_3 = {{{ 'uca0103', 4 },},}		local Level5_3_Types = {'CybranGunships',}
local Attack_Level5_4 = {{{ 'uca0104', 3 },{ 'uca0103', 1 },},}		local Level5_4_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level5_5 = {{{ 'uca0104', 1 },{ 'uca0103', 3 },},}		local Level5_5_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level5_6 = {{{ 'uca0104', 2 },{ 'uca0103', 1 },},}		local Level5_6_Types = {'CybranFighterBombers', 'CybranGunships',}


-- Level 6 threshold and attack platoons:
local Cybran_Level6_NormalUnits = 105
local Cybran_Level6_StrongUnits = 1

local Attack_Level6_1 = {{{ 'uca0104', 5 },},}		local Level6_1_Types = {'CybranFighterBombers',}
local Attack_Level6_2 = {{{ 'uca0103', 5 },},}		local Level6_2_Types = {'CybranGunships',}
local Attack_Level6_3 = {{{ 'uca0104', 2 },{ 'uca0103', 3 },},}		local Level6_3_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level6_4 = {{{ 'uca0104', 3 },{ 'uca0103', 2 },},}		local Level6_4_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level6_5 = {{{ 'uca0104', 4 },{ 'uca0103', 1 },},}		local Level6_5_Types ={'CybranFighterBombers', 'CybranGunships',}


-- Level 7 threshold and attack platoons:
local Cybran_Level7_NormalUnits = 140
local Cybran_Level7_StrongUnits = 2

local Attack_Level7_1 = {{{ 'uca0104', 6 },},}		local Level7_1_Types = {'CybranFighterBombers',}
local Attack_Level7_2 = {{{ 'uca0103', 6 },},}		local Level7_2_Types = {'CybranGunships',}
local Attack_Level7_3 = {{{ 'uca0104', 3 },{ 'uca0103', 3 },},}		local Level7_3_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level7_4 = {{{ 'uca0104', 2 },{ 'uca0103', 4 },},}		local Level7_4_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level7_5 = {{{ 'uca0104', 4 },{ 'uca0103', 2 },},}		local Level7_5_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level7_6 = {{{ 'uca0104', 1 },{ 'uca0103', 5 },},}		local Level7_6_Types = {'CybranFighterBombers', 'CybranGunships',}


-- Level 8 threshold and attack platoons:
local Cybran_Level8_NormalUnits = 175
local Cybran_Level8_StrongUnits = 3

local Attack_Level8_1 = {{{ 'uca0104', 7 },},}		local Level8_1_Types = {'CybranFighterBombers',}
local Attack_Level8_2 = {{{ 'uca0103', 7 },},}		local Level8_2_Types = {'CybranGunships',}
local Attack_Level8_3 = {{{ 'uca0104', 2 },{ 'uca0103', 5 },},}		local Level8_3_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level8_4 = {{{ 'uca0104', 5 },{ 'uca0103', 2 },},}		local Level8_4_Types = {'CybranFighterBombers', 'CybranGunships',}
local Attack_Level8_5 = {{{ 'uca0104', 1 },{ 'uca0103', 6 },},}		local Level8_5_Types = {'CybranFighterBombers', 'CybranGunships',}


--------------------------------
-- Level 1 Attacks, priority 200
--------------------------------

CAIOperationAIBlueprint	{
    -- AnnounceBuilder = true,

	Name = 'AirAttackCybran',
	DefaultAIBehavior =	'Nothing',
	ChildCount = 3,
	MaxActivePlatoons =	2,

	FactoryBuilders	= {
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level1_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level1_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level1_NormalUnits } },
				},
			},
			ChildrenTypes =	Level1_1_Types,
			Priority = 200,
		},

--------------------------------
-- Level 2 Attacks, priority 225
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level2_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level2_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_1_Types,
			Priority = 225,
		},

--------------------------------
-- Level 3 Attacks, priority 250
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level3_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level3_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_1_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level3_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level3_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_2_Types,
			Priority = 250,
		},

--------------------------------
-- Level 4 Attacks, priority 275
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level4_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_1_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level4_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_2_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level4_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_3_Types,
			Priority = 275,
		},

			 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level4_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
			},
			ChildrenTypes =	Level4_4_Types,
			Priority = 275,
		},

--------------------------------
-- Level 5 Attacks, priority 300
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level5_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_1_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level5_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_2_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level5_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_3_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level5_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_4_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level5_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_5_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level5_6',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
			},
			ChildrenTypes =	Level5_6_Types,
			Priority = 300,
		},

--------------------------------
-- Level 6 Attacks, priority 325
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level6_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_1_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level6_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_2_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level6_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_3_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level6_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_4_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level6_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_5_Types,
			Priority = 325,
		},

--------------------------------
-- Level 7 Attacks, priority 350
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level7_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level7_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_1_Types,
			Priority = 350,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level7_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level7_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_2_Types,
			Priority = 350,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level7_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level7_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_3_Types,
			Priority = 350,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level7_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level7_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_4_Types,
			Priority = 350,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level7_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level7_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_5_Types,
			Priority = 350,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level7_6',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level7_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level7_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level7_StrongUnits } },
				},
			},
			ChildrenTypes =	Level7_6_Types,
			Priority = 350,
		},

--------------------------------
-- Level 8 Attacks, priority 375
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level8_1',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level8_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_1_Types,
			Priority = 375,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level8_2',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level8_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_2_Types,
			Priority = 375,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level8_3',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level8_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_3_Types,
			Priority = 375,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level8_4',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level8_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_4_Types,
			Priority = 375,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'ACybran_Level8_5',
			MasterName = 'AirAttack',
			BuilderType	= 'Air',
			Faction	= 'Cybran',
			Platoons = Attack_Level8_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level8_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level8_StrongUnits } },
				},
			},
			ChildrenTypes =	Level8_5_Types,
			Priority = 375,
		},
	},
}