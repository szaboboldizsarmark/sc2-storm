
-- 
CAIFactoryBuilderBlueprint {
    Name = 'BM Build Engineer',
    BuilderType = 'All',
    Faction = 'All',
    BuilderStartedCallback = function(builder, factory, constructionTemplate)
        local numBuilding = 0
        for _,unitTable in constructionTemplate do
            numBuilding = numBuilding + unitTable[2]
        end

        builder.BaseManager:SetEngineersBuilding(numBuilding)
    end,
    UnitFinishedCallback = function(builder, finishedUnit)
        if EntityCategoryContains( categories.ENGINEER, finishedUnit ) then
            builder.BaseManager:SetEngineersBuilding(-1)
        end
    end,
    Platoons = {
        {
            { 'uul0002', 1 },
        },
        {
            { 'uil0002', 1 },
        },
        {
            { 'ucl0002', 1 },
        },
    },
    Conditions = {
        -- First conditions set
        {
            { ConditionName = 'BaseManagerNeedsEngineerBuilt', Parameters = { 'uul0002' } },
        },
        {
            { ConditionName = 'BaseManagerNeedsEngineerBuilt', Parameters = { 'uil0002' } },
        },
        {
            { ConditionName = 'BaseManagerNeedsEngineerBuilt', Parameters = { 'ucl0002' } },
        },
    },
    Priority = 1000,
}

