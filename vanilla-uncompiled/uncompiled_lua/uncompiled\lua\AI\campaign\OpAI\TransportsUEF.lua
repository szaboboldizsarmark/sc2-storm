


-- ChildrenTypes
--   UEFTransports

local SmallAttackMinimum = 1
local MediumAttackMinimum = 15
local LargeAttackMinimum = 40



CAIOperationAIBlueprint {
    Name = 'TransportsUEF',
    DefaultAIBehavior = 'TransportPool',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {

        CAIFactoryBuilderBlueprint {
            Name = 'UEFTransports_Transports_1',
            MasterName = 'Transports',
            BuilderType = 'Air',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uua0901', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                    { ConditionName = 'HaveCategoryLessThanOrEqual', Parameters = { categories.uua0901, 2 } },
                },
            },
            ChildrenTypes = { 'UEFTransports', },
            Priority = 1000,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEFTransports_Transports_2',
            MasterName = 'Transports',
            BuilderType = 'Air',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uua0901', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, MediumAttackMinimum } },
                    { ConditionName = 'HaveCategoryLessThanOrEqual', Parameters = { categories.uua0901, 4 } },
                },
            },
            ChildrenTypes = { 'UEFTransports', },
            Priority = 1000,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'UEFTransports_Transports_3',
            MasterName = 'Transports',
            BuilderType = 'Air',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uua0901', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                    { ConditionName = 'HaveCategoryLessThanOrEqual', Parameters = { categories.uua0901, 6 } },
                },
            },
            ChildrenTypes = { 'UEFTransports', },
            Priority = 1000,
        },

    },
}
