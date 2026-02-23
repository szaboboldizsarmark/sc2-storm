---- ChildrenTypes: ignoring Aircraft carriers as they are relatively special-casey
--   CybranDestroyers		(ucs0103)
--   CybranBattleships		(ucs0105)


local normalCats = 	categories.uus0104 +												-- UEF submarines
					categories.BOMBER +													-- bombers
					categories.uua0103 + categories.uia0103 + categories.uca0103 +		-- gunships
					(categories.LAND * categories.MOBILE * categories.ILLUMINATE) +		-- Illuminate land
					(categories.SHIELD * categories.STRUCTURE) +						-- shield structures
					categories.COMMAND													-- Player CDR

local mediumCats =  categories.ucs0103 + categories.uus0102 +							-- Destroyers and Cruisers
					categories.ucs0901													-- Cybran carrier

local strongCats = (categories.EXPERIMENTAL * categories.ANTISURFACE) +					-- all antisurface experimentals
					categories.ucs0105 + categories.uus0105								-- battleships

local NormalUnitCount_Level1 = 4

local NormalUnitCount_Level2 = 12
local MediumUnitCount_Level2 = 4

local NormalUnitCount_Level3 = 22
local MediumUnitCount_Level3 = 7
local StrongUnitCount_Level3 = 1

local NormalUnitCount_Level4 = 28
local MediumUnitCount_Level4 = 9
local StrongUnitCount_Level4 = 3

local NormalUnitCount_Level5 = 37
local MediumUnitCount_Level5 = 11
local StrongUnitCount_Level5 = 5

local NormalUnitCount_Level6 = 46
local MediumUnitCount_Level6 = 14
local StrongUnitCount_Level6 = 6

local NormalUnitCount_Level7 = 54
local MediumUnitCount_Level7 = 18
local StrongUnitCount_Level7 = 8

CAIOperationAIBlueprint {
    Name = 'NavalAttackCybran',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 1,
    MaxActivePlatoons = 2,

    FactoryBuilders = {
		-- 1 destroyers
		CAIFactoryBuilderBlueprint {
			Name = 'Cybran_Naval_1',
            BuilderType = 'Sea',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucs0103', 1 },
                },
            },
            Conditions = {
				--Normal unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { normalCats, NormalUnitCount_Level1 } },
                },
            },
            ChildrenTypes = { 'CybranDestroyers' },
            Priority = 200,
		},
		-- 2 destroyers
		CAIFactoryBuilderBlueprint {
			Name = 'Cybran_Naval_2',
            BuilderType = 'Sea',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucs0103', 2 },
                },
            },
            Conditions = {
				--Normal unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { normalCats, NormalUnitCount_Level2 } },
                },
				--Medium unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { mediumCats, MediumUnitCount_Level2 } },
                },
            },
            ChildrenTypes = { 'CybranDestroyers' },
            Priority = 225,
		},
		-- 3 destroyers
		CAIFactoryBuilderBlueprint {
			Name = 'Cybran_Naval_3',
            BuilderType = 'Sea',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucs0103', 3 },
                },
            },
            Conditions = {
				--Normal unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { normalCats, NormalUnitCount_Level3 } },
                },
				--Medium unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { mediumCats, MediumUnitCount_Level3 } },
                },
                --Powerful unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { strongCats, StrongUnitCount_Level3 } },
                },
            },
            ChildrenTypes = { 'CybranDestroyers' },
            Priority = 250,
		},
		-- 6 destroyers
		CAIFactoryBuilderBlueprint {
            Name = 'Cybran_Naval_4',
            BuilderType = 'Sea',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucs0103', 6 },
                },
            },
            Conditions = {
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { normalCats, NormalUnitCount_Level4 } },
                },
				--Medium unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { mediumCats, MediumUnitCount_Level4 } },
                },
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { strongCats, StrongUnitCount_Level4 } },
                },
            },
            ChildrenTypes = { 'CybranDestroyers' },
            Priority = 275,
        },
        -- 3 battleships
		CAIFactoryBuilderBlueprint {
            Name = 'Cybran_Naval_5',
            BuilderType = 'Sea',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucs0105', 3 },
                },
            },
            Conditions = {
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { normalCats, NormalUnitCount_Level5 } },
                },
				--Medium unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { mediumCats, MediumUnitCount_Level5 } },
                },
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { strongCats, StrongUnitCount_Level5 } },
                },
            },
            ChildrenTypes = { 'CybranBattleships' },
            Priority = 300,
        },
        -- 3 battleships, 3 destroyers
		CAIFactoryBuilderBlueprint {
            Name = 'Cybran_Naval_6',
            BuilderType = 'Sea',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucs0103', 3 },
                    { 'ucs0105', 3 },
                },
            },
            Conditions = {
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { normalCats, NormalUnitCount_Level6 } },
                },
				--Medium unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { mediumCats, MediumUnitCount_Level6 } },
                },
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { strongCats, StrongUnitCount_Level6 } },
                },
            },
            ChildrenTypes = { 'CybranDestroyers', 'CybranBattleships' },
            Priority = 325,
        },
        -- 6 battleships
		CAIFactoryBuilderBlueprint {
            Name = 'Cybran_Naval_7',
            BuilderType = 'Sea',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucs0105', 6 },
                },
            },
            Conditions = {
				--Normal unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { normalCats, NormalUnitCount_Level7 } },
                },
				--Medium unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { mediumCats, MediumUnitCount_Level7 } },
                },
                --Powerful unit condition set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { strongCats, StrongUnitCount_Level7 } },
                },
            },
            ChildrenTypes = { 'CybranBattleships' },
            Priority = 350,
        },
    },
}