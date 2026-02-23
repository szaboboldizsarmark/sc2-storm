-- Responsive Air Attacks triggered by powerful individual air units.
-- This OpAI is intended to to use a Target thread, that attacks individual air targets (instead of a general patrol).

local AirResponseMinimum 		= 1		-- min number of powerful air experimentals that will trigger the condition
local PlayerMinimumUnits		= 30	-- min number of units player must have for attack to be built

CAIOperationAIBlueprint {
    Name = 'AirResponseTargetAir',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 3,
    MaxActivePlatoons = 2,

    FactoryBuilders = {
        -- Powerful air units: mobile air experimentals
        CAIFactoryBuilderBlueprint {
            Name = 'ARTA_Fighters_1',
            BuilderType = 'Air',
            Platoons = {
                {
                    { 'uua0101', -1 },
                },
                {
                    { 'uca0104', -1 },
                },
                {
                    { 'uia0104', -1 },
                },
            },
            Conditions = {
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = {categories.EXPERIMENTAL * categories.AIR * categories.MOBILE, AirResponseMinimum } },
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, PlayerMinimumUnits } },
                },
            },
            ChildrenTypes = { 'UEFFighters', 'IlluminateFighterBombers', 'CybranFighterBombers' },
            Priority = 800,
        },
    },
}