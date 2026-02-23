
--[[
-- If the brain has 0 mass extractors and we can build one; do it!
-- This at least makes it look like teh AI is trying to use resources properly
CAIEngineerBuilderBlueprint {
    Name = 'Mass Extractor - Have 0',
    EngineerType = {
        uul0002 = true,
    },
    Conditions = {
        {
            { 'HaveCategoryLessThanOrEqual', { categories.MASSEXTRACTION, 0 } },
        },
    },
    EngineerData = {
        ConstructionGoal = 'uub0001',
    },
    Priority = 1000,
}

-- If the brain has 0 power generators and we can build one; do it!
-- This at least makes it look like teh AI is trying to use resources properly
CAIEngineerBuilderBlueprint {
    Name = 'Power Generator - Have 0',
    EngineerType = {
        uul0002 = true,
    },
    Conditions = {
        {
            { 'HaveCategoryLessThanOrEqual', { categories.ENERGYPRODUCTION, 0 } },
        },
    },
    EngineerData = {
        ConstructionGoal = 'uub0001',
    },
    Priority = 975,
}
]]--


--[[
CAIEngineerBuilderBlueprint {
    Name = 'Patrol Base',
    EngineerType = {
        uul0002 = true,
    },
    Conditions = {
        {
            { 'BaseManagerNeedsEngineer', { categories.ENERGYPRODUCTION, 0 } },
        },
    },
    EngineerData = {
        ConstructionGoal = 'uub0001',
    },
    Priority = 975,
}
]]--

CAIEngineerBuilderBlueprint {
    Name = 'Default Base Manager Engineer Platoon',
    EngineerType = {
        uul0001 = true,
        ucl0001 = true,
        uil0001 = true,
        uul0002 = true,
        ucl0002 = true,
        uil0002 = true,
    },
    Conditions = {
        -- UEF Condition
        {
            { ConditionName = 'BaseManagerNeedsEngineer', Parameters = { 'uul0002' } },
        },
        -- Cybran Condition
        {
            { ConditionName = 'BaseManagerNeedsEngineer', Parameters = { 'ucl0002' } },
        },
        -- Illuminate Condition
        {
            { ConditionName = 'BaseManagerNeedsEngineer', Parameters = { 'uil0002' } },
        },
        -- UEF CDR Condition
        {
            { ConditionName = 'BaseManagerNeedsEngineer', Parameters = { 'uul0001' } },
        },
        -- Cybran CDR Condition
        {
            { ConditionName = 'BaseManagerNeedsEngineer', Parameters = { 'ucl0001' } },
        },
        -- Illuminate CDR Condition
        {
            { ConditionName = 'BaseManagerNeedsEngineer', Parameters = { 'uil0001' } },
        },
    },
    PlatoonThread = 'Base Manager Default Engineer',
    Priority = 950,
}