


-- ChildrenTypes
--   UEFCruisers
--   UEFSubmarines
--   UEFBattleships

local SmallAttackMinimum = 1
local MediumAttackMinimum = 15
local LargeAttackMinimum = 40



CAIOperationAIBlueprint {
    Name = 'NavalAttackUEF',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 3,
    MaxActivePlatoons = 2,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Cruisers_1',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0102', 1 },
                },
                {
                    { 'uus0102', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFCruisers' },
            Priority = 200,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Cruisers_2',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0102', 2 },
                },
                {
                    { 'uus0102', 3 },
                },
                {
                    { 'uus0102', 4 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, MediumAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFCruisers' },
            Priority = 225,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Cruisers_3',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0102', 4 },
                },
                {
                    { 'uus0102', 5 },
                },
                {
                    { 'uus0102', 6 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                },
                -- Second conditions set
                --{
                --    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                --    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.FACTORY, 2 } },
                --},
            },
            ChildrenTypes = { 'UEFCruisers' },
            Priority = 250,
        },

        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Submarines_1',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0104', 1 },
                },
                {
                    { 'uus0104', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.NAVAL * categories.MOBILE, 1 } },
                },
            },
            ChildrenTypes = { 'UEFSubmarines' },
            Priority = 200,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Submarines_2',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0104', 2 },
                },
                {
                    { 'uus0104', 3 },
                },
                {
                    { 'uus0104', 4 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, MediumAttackMinimum } },
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.NAVAL * categories.MOBILE, 1 } },
                },
            },
            ChildrenTypes = { 'UEFSubmarines' },
            Priority = 225,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Submarines_3',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0104', 4 },
                },
                {
                    { 'uus0104', 5 },
                },
                {
                    { 'uus0104', 6 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.NAVAL * categories.MOBILE, 1 } },
                },
                -- Second conditions set
                --{
                --    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                --    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.FACTORY, 2 } },
                --},
            },
            ChildrenTypes = { 'UEFSubmarines' },
            Priority = 250,
        },

        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Battleships_1',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0105', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFBattleships' },
            Priority = 200,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Battleships_2',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0105', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, MediumAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFBattleships' },
            Priority = 225,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Battleships_3',
            BuilderType = 'Sea',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uus0105', 3 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                },
                -- Second conditions set
                --{
                --    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                --    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.FACTORY, 2 } },
                --},
            },
            ChildrenTypes = { 'UEFBattleships' },
            Priority = 250,
        },


    },
}