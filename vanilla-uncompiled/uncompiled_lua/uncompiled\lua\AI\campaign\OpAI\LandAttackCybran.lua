-- ChildrenTypes
--   CybranAssaultBots
--   CybranMobileArtillery
--   CybranMobileMissiles
--   CybranComboDefense


-- Condition categories for Normal units, and Strong units
local NormalUnitCategories =(categories.uub0202 + categories.uib0202 + categories.ucb0202) +	-- all shields
							(categories.uub0101 + categories.uib0101 + categories.ucb0101 + categories.uub0104) + -- pd and uef art
							(((categories.MOBILE * categories.LAND) - categories.ENGINEER) + categories.COMMAND) + -- all land mobs minus engineers, but include cdr
							(categories.MOBILE * categories.AIR * categories.ANTISURFACE) + -- all air that can attack the ground
							(categories.FACTORY)

local StrongUnitCategories =(categories.EXPERIMENTAL) +
							(categories.NUKE + categories.uub0105 + categories.ucb0105)


-- Level 1 threshold and attack platoons:
local Cybran_Level1_NormalUnits = 1

local Attack_Level1_1 = {{{ 'ucl0103', 1 },},}		local Level1_1_Types = {'CybranAssaultBots',}


-- Level 2 threshold and attack platoons:
local Cybran_Level2_NormalUnits = 13

local Attack_Level2_1 = {{{ 'ucl0103', 2 },},}		local Level2_1_Types = {'CybranAssaultBots',}
local Attack_Level2_2 = {{{ 'ucl0102', 2 },},}		local Level2_2_Types = {'CybranMobileArtillery',}
local Attack_Level2_3 = {{{ 'ucl0103', 1 },{ 'ucl0102', 1 },},}		local Level2_3_Types = {'CybranAssaultBots', 'CybranMobileArtillery',}


-- Level 3 threshold and attack platoons:
local Cybran_Level3_NormalUnits = 24

local Attack_Level3_1 = {{{ 'ucl0103', 3 },},}		local Level3_1_Types = {'CybranAssaultBots',}
local Attack_Level3_2 = {{{ 'ucl0102', 3 },},}		local Level3_2_Types = {'CybranMobileArtillery',}
local Attack_Level3_3 = {{{ 'ucl0103', 2 },{ 'ucl0204', 1 },},}		local Level3_3_Types = {'CybranAssaultBots', 'CybranComboDefense',}
local Attack_Level3_4 = {{{ 'ucl0102', 2 },{ 'ucl0204', 1 },},}		local Level3_4_Types = {'CybranMobileArtillery', 'CybranComboDefense',}

-- Level 4 threshold and attack platoons:
local Cybran_Level4_NormalUnits = 45
local Cybran_Level4_StrongUnits = 1

local Attack_Level4_1 = {{{ 'ucl0103', 4 },},}		local Level4_1_Types = {'CybranAssaultBots',}
local Attack_Level4_2 = {{{ 'ucl0102', 4 },},}		local Level4_2_Types = {'CybranMobileArtillery',}
local Attack_Level4_3 = {{{ 'ucl0104', 4 },},}		local Level4_3_Types = {'CybranMobileMissiles',}
local Attack_Level4_4 = {{{ 'ucl0103', 2 },{ 'ucl0102', 1 },{ 'ucl0204', 1 },},}	local Level4_4_Types = {'CybranAssaultBots', 'CybranMobileArtillery', 'CybranComboDefense',}
local Attack_Level4_5 = {{{ 'ucl0102', 3 },{ 'ucl0204', 1 },},}		local Level4_5_Types = {'CybranMobileArtillery', 'CybranComboDefense',}
local Attack_Level4_6 = {{{ 'ucl0104', 3 },{ 'ucl0204', 1 },},}		local Level4_6_Types = {'CybranMobileMissiles', 'CybranComboDefense',}

-- Level 5 threshold and attack platoons:
local Cybran_Level5_NormalUnits = 60
local Cybran_Level5_StrongUnits = 2

local Attack_Level5_1 = {{{ 'ucl0104', 4 },{ 'ucl0204', 1 },},}		local Level5_1_Types = {'CybranMobileMissiles', 'CybranComboDefense',}
local Attack_Level5_2 = {{{ 'ucl0103', 2 },{ 'ucl0102', 2 },{ 'ucl0104', 1 },},}	local Level5_2_Types = {'CybranAssaultBots', 'CybranMobileArtillery', 'CybranMobileArtillery',}
local Attack_Level5_3 = {{{ 'ucl0103', 6 },},}		local Level5_3_Types = {'CybranAssaultBots',}
local Attack_Level5_4 = {{{ 'ucl0102', 6 },},}		local Level5_4_Types = {'CybranMobileArtillery',}
local Attack_Level5_5 = {{{ 'ucl0104', 6 },},}		local Level5_5_Types = {'CybranMobileMissiles',}
local Attack_Level5_6 = {{{ 'ucl0103', 3 },{ 'ucl0102', 3 },{ 'ucl0204', 1 },},}	local Level5_6_Types = {'CybranAssaultBots', 'CybranMobileArtillery', 'CybranComboDefense',}
local Attack_Level5_7 = {{{ 'ucl0103', 2 },{ 'ucl0104', 4 },},}		local Level5_7_Types = {'CybranAssaultBots', 'CybranMobileMissiles',}
local Attack_Level5_8 = {{{ 'ucl0103', 1 },{ 'ucl0102', 4 },{ 'ucl0204', 1 },},}	local Level5_8_Types = {'CybranAssaultBots', 'CybranMobileArtillery', 'CybranComboDefense',}

-- Level 6 threshold and attack platoons:
local Cybran_Level6_NormalUnits = 78
local Cybran_Level6_StrongUnits = 3

local Attack_Level6_1 = {{{ 'ucl0103', 6 },{ 'ucl0204', 1 },},}		local Level6_1_Types = {'CybranAssaultBots', 'CybranComboDefense',}
local Attack_Level6_2 = {{{ 'ucl0104', 6 },{ 'ucl0204', 1 },},}		local Level6_2_Types = {'CybranMobileMissiles', 'CybranComboDefense',}
local Attack_Level6_3 = {{{ 'ucl0103', 8 },},}		local Level6_3_Types = {'CybranAssaultBots',}
local Attack_Level6_4 = {{{ 'ucl0102', 8 },},}		local Level6_4_Types = {'CybranMobileArtillery',}
local Attack_Level6_5 = {{{ 'ucl0104', 8 },},}		local Level6_5_Types = {'CybranMobileMissiles',}
local Attack_Level6_6 = {{{ 'ucl0103', 3 },{ 'ucl0102', 4 },{ 'ucl0204', 1 },},}	local Level6_6_Types = {'CybranAssaultBots', 'CybranMobileArtillery', 'CybranComboDefense',}
local Attack_Level6_7 = {{{ 'ucl0104', 6 },{ 'ucl0204', 2 },},}		local Level6_7_Types = {'CybranMobileMissiles', 'CybranComboDefense',}
local Attack_Level6_8 = {{{ 'ucl0102', 2 },{ 'ucl0104', 5 },{ 'ucl0204', 1 },},}	local Level6_8_Types = {'CybranMobileArtillery', 'CybranMobileMissiles', 'CybranComboDefense',}


--------------------------------
-- Level 1 Attacks, priority 200
--------------------------------

CAIOperationAIBlueprint	{
    -- AnnounceBuilder = true,

	Name = 'LandAttackCybran',
	DefaultAIBehavior =	'Nothing',
	ChildCount = 3,
	MaxActivePlatoons =	2,

	FactoryBuilders	= {
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level1_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
			Name = 'LCybran_Level2_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level2_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level2_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_2_Types,
			Priority = 225,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level2_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level2_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level2_NormalUnits } },
				},
			},
			ChildrenTypes =	Level2_3_Types,
			Priority = 225,
		},

--------------------------------
-- Level 3 Attacks, priority 250
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level3_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
			Name = 'LCybran_Level3_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level3_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level3_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_3_Types,
			Priority = 250,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level3_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level3_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level3_NormalUnits } },
				},
			},
			ChildrenTypes =	Level3_4_Types,
			Priority = 250,
		},

--------------------------------
-- Level 4 Attacks, priority 275
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level4_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_1_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level4_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_3_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level4_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_3_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level4_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_4_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level4_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_5_Types,
			Priority = 275,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level4_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level4_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level4_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level4_StrongUnits } },
				},
			},
			ChildrenTypes =	Level4_6_Types,
			Priority = 275,
		},

--------------------------------
-- Level 5 Attacks, priority 300
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_1,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_1_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_2,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_2_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_3,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_3_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_4,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_4_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_5,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_5_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_6_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_7',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_7_Types,
			Priority = 300,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level5_8',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level5_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level5_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level5_StrongUnits } },
				},
			},
			ChildrenTypes =	Level5_8_Types,
			Priority = 300,
		},

--------------------------------
-- Level 6 Attacks, priority 325
--------------------------------

		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level6_1',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
			Name = 'LCybran_Level6_2',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
			Name = 'LCybran_Level6_3',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
			Name = 'LCybran_Level6_4',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
			Name = 'LCybran_Level6_5',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
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
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level6_6',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_6,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_6_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level6_7',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_7,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_7_Types,
			Priority = 325,
		},
		 CAIFactoryBuilderBlueprint	{
			Name = 'LCybran_Level6_8',
			MasterName = 'LandAttack',
			BuilderType	= 'Land',
			Faction	= 'Cybran',
			Platoons = Attack_Level6_8,
			Conditions = {
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ NormalUnitCategories, Cybran_Level6_NormalUnits } },
				},
				{
					{ ConditionName	= 'TargetUnitsGreaterThanOrEqual', Parameters =	{ StrongUnitCategories, Cybran_Level6_StrongUnits } },
				},
			},
			ChildrenTypes =	Level6_8_Types,
			Priority = 325,
		},
	},
}
