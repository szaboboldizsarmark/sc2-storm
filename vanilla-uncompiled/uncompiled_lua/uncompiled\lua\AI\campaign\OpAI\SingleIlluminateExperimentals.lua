local SmallAttackMinimum = 1
local MediumAttackMinimum = 15
local LargeAttackMinimum = 40



-- ChildrenTypes
--   IlluminateAirnomo

CAIOperationAIBlueprint {
    Name = 'SingleAirnomoAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Illuminate_Airnomo_Single',
            BuilderType = 'Gantry',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uix0103', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'IlluminateAirnomo' },
            Priority = 300,
        },
    },
}

-- ChildrenTypes
--   IlluminateUrchinow

CAIOperationAIBlueprint {
    Name = 'SingleUrchinowAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Illuminate_Urchinow_Single',
            BuilderType = 'Gantry',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uix0101', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'IlluminateUrchinow' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   IlluminateColossus

CAIOperationAIBlueprint {
    Name = 'SingleColossusAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Illuminate_Colossus_Single',
            BuilderType = 'Gantry',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uix0111', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'IlluminateColossus' },
            Priority = 300,
        },
    },
}


-- ChildrenTypes
--   IlluminateDarkenoid

CAIOperationAIBlueprint {
    Name = 'SingleDarkenoidAttack',
    ChildCount = 1,
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'Illuminate_Darkenoid_Single',
            BuilderType = 'Gantry',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uix0112', 1 },
                },
            },
            Conditions = {
                -- First conditions set
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, SmallAttackMinimum } },
                },
            },
            ChildrenTypes = { 'IlluminateDarkenoid' },
            Priority = 300,
        },
    },
}


