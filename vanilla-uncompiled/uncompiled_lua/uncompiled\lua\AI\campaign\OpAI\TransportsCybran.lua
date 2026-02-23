


-- ChildrenTypes
--   CybranTransports

local SmallAttackMinimum = 1


CAIOperationAIBlueprint {
    Name = 'TransportsCybran',
    DefaultAIBehavior = 'TransportPool',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {

        CAIFactoryBuilderBlueprint {
            Name = 'CybranTransports_Transports_1',
            MasterName = 'Transports',
            BuilderType = 'Air',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'uca0901', 4 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                    { ConditionName = 'HaveCategoryLessThanOrEqual', Parameters = { categories.uca0901, 2 } },
                },
            },
            ChildrenTypes = { 'CybranTransports', },
            Priority = 1000,
        },
    },
}

