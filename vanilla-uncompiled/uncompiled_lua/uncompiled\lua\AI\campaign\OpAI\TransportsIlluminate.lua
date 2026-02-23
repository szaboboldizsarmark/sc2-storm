


-- ChildrenTypes
--   IlluminateTransports

local SmallAttackMinimum = 1
local MediumAttackMinimum = 15
local LargeAttackMinimum = 40



CAIOperationAIBlueprint {
    Name = 'TransportsIlluminate',
    DefaultAIBehavior = 'TransportPool',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {

        CAIFactoryBuilderBlueprint {
            Name = 'IlluminateTransports_Transports_1',
            MasterName = 'Transports',
            BuilderType = 'Air',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uia0901', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                    { ConditionName = 'HaveCategoryLessThanOrEqual', Parameters = { categories.uia0901, 2 } },
                },
            },
            ChildrenTypes = { 'IlluminateTransports', },
            Priority = 1000,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'IlluminateTransports_Transports_2',
            MasterName = 'Transports',
            BuilderType = 'Air',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uia0901', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, MediumAttackMinimum } },
                    { ConditionName = 'HaveCategoryLessThanOrEqual', Parameters = { categories.uia0901, 4 } },
                },
            },
            ChildrenTypes = { 'IlluminateTransports', },
            Priority = 1000,
        },
        CAIFactoryBuilderBlueprint {
            Name = 'IlluminateTransports_Transports_3',
            MasterName = 'Transports',
            BuilderType = 'Air',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uia0901', 2 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, LargeAttackMinimum } },
                    { ConditionName = 'HaveCategoryLessThanOrEqual', Parameters = { categories.uia0901, 6 } },
                },
            },
            ChildrenTypes = { 'IlluminateTransports', },
            Priority = 1000,
        },

    },
}
