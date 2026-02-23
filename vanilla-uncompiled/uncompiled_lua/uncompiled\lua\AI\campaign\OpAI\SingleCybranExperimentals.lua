local SmallAttackMinimum = 1
local MediumAttackMinimum = 15
local LargeAttackMinimum = 40



-- ChildrenTypes
--   CybranMegalith

CAIOperationAIBlueprint {
    Name = 'SingleMegalithAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Cybran_Megalith_Single',
            BuilderType = 'Gantry',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucx0101', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'CybranMegalith' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   CybranSoulRipper

CAIOperationAIBlueprint {
    Name = 'SingleSoulRipperAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Cybran_SoulRipper_Single',
            BuilderType = 'Gantry',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucx0112', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'CybranSoulRipper' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   CybranExperimentalTransport

CAIOperationAIBlueprint {
    Name = 'SingleExperimentalTransportAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Cybran_ExperimentalTransport_Single',
            BuilderType = 'Gantry',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucx0102', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'CybranExperimentalTransport' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   CybranCybranzilla

CAIOperationAIBlueprint {
    Name = 'SingleCybranzillaAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Cybran_Cybranzilla_Single',
            BuilderType = 'Gantry',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'ucx0111', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'CybranCybranzilla' },
            Priority = 300,
        },
    },
}
