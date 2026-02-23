local SmallAttackMinimum = 1
local MediumAttackMinimum = 15
local LargeAttackMinimum = 40



-- ChildrenTypes
--   UEFFatboy

CAIOperationAIBlueprint {
    Name = 'SingleFatboyAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_Fatboy_Single',
            BuilderType = 'Gantry',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uux0101', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFFatboy' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   UEFAC1000

CAIOperationAIBlueprint {
    Name = 'SingleAC1000Attack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_AC1000_Single',
            BuilderType = 'Gantry',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uux0102', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFAC1000' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   UEFStarKing

CAIOperationAIBlueprint {
    Name = 'SingleStarKingAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_StarKing_Single',
            BuilderType = 'Gantry',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uux0103', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFStarKing' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   UEFKingKriptor

CAIOperationAIBlueprint {
    Name = 'SingleKingKriptorAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_KingKriptor_Single',
            BuilderType = 'Gantry',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uux0111', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFKingKriptor' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   UEFAirFortress

CAIOperationAIBlueprint {
    Name = 'SingleAirFortressAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'UEF_AirFortress_Single',
            BuilderType = 'Gantry',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uux0112', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'UEFAirFortress' },
            Priority = 300,
        },
    },
}


