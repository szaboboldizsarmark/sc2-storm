-- Responsive Air Attacks triggered by player having an excess of air-based units.
-- This OpAI is intended to to use a Patrol thread, with the platoon sent to patrol to the player base.

local PlayerAirUnitsMin 		= 60

CAIOperationAIBlueprint {
    Name = 'AirResponsePatrolAir',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 3,
    MaxActivePlatoons = 3,

    FactoryBuilders = {
        -- An excess of air-based units
        CAIFactoryBuilderBlueprint {
            Name = 'ARPA_Fighters_1',
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
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.MOBILE * categories.AIR, PlayerAirUnitsMin} },
				},
            },
            ChildrenTypes = { 'UEFFighters', 'IlluminateFighterBombers', 'CybranFighterBombers' },
            Priority = 800,
        },
    },
}