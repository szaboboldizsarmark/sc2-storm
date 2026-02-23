-- Responsive Air Attacks triggered by player power gens of Cybran faction. This is intended to be enabled when a cybran
-- player has completed research on mass conversion addon, allowing power generators to act as mass fabs. This bp is separate
-- from the Illuminate/UEF mass-fab response to accomodate this dual nature of Cybran power generators.

-- This OpAI is intended to to use a category thread, that attacks individual land targets (instead of a general patrol).



local GenResponseMinimum 		= 2		-- min number of generators
local PlayerMinimumUnits		= 33	-- min number of units player must have for attack to be built

CAIOperationAIBlueprint {
    Name = 'AirResponseTargetCybPower',
    DefaultAIBehavior = 'Nothing',

    -- default ChildCount to 1, so this lower-importance opai doesnt blow out legit attacks.  Our main care here is
    -- poorly located player mass fabs, not the general fact that player happens to own some.
    ChildCount = 1,

    -- Player will always have power gens, so we need to be very careful with this opai, and default to 1 max plat.
    -- This opai will effectively stay on once enabled, so it needs to be slowed down, to allow other opais to build.
    MaxActivePlatoons = 1,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'ARTCP_Gunships_1',
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
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ucb0702, GenResponseMinimum } },
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, PlayerMinimumUnits } },
                },
            },
            ChildrenTypes = { 'UEFGunships', 'IlluminateGunships', 'CybranGunships' },
            Priority = 700, -- lower priority than other surgical responses, but higher than standard attacks.
        },
    },
}