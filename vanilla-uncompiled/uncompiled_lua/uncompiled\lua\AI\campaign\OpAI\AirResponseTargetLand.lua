-- Responsive Air Attacks triggered by powerful individual land units.
-- This OpAI is intended to to use a Target thread, that attacks individual land targets (instead of a general patrol).


local LandResponseMinimum 		= 1		-- min number of powerful land units that will trigger the condition
local PlayerMinimumUnits		= 30	-- min number of units player must have for attack to be built

CAIOperationAIBlueprint {
    Name = 'AirResponseTargetLand',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 3,
    MaxActivePlatoons = 2,

    FactoryBuilders = {
		-- Powerful land units: mobile land experimentals, heavy long range artillery, nuke launchers.
        CAIFactoryBuilderBlueprint {
            Name = 'ARTL_Gunships_1',
            BuilderType = 'Air',
            Platoons = {
                {
                    { 'uua0103', -1 },
                },
                 {
                    { 'uca0103', -1 },
                },
                {
                    { 'uia0103', -1 },
                },
            },
            Conditions = {
                {
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = {(categories.EXPERIMENTAL * categories.LAND * categories.MOBILE) + categories.uub0105 + categories.ucb0105 + categories.NUKE, LandResponseMinimum } },
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, PlayerMinimumUnits } },
                },
            },
            ChildrenTypes = { 'UEFGunships', 'IlluminateGunships', 'CybranGunships' },
            Priority = 800,
        },
    },
}