-- Responsive Air Attacks triggered by player mass fabricator units of UEF or Illuminate faction (Cybran mass fabs are upgraded
-- energy producers, which cannot be distinguished from an upgraded version).
-- This OpAI is intended to to use a category thread, that attacks individual land targets (instead of a general patrol).


local FabResponseMinimum 		= 1		-- min number of powerful land units that will trigger the condition
local PlayerMinimumUnits		= 20	-- min number of units player must have for attack to be built

CAIOperationAIBlueprint {
    Name = 'AirResponseTargetMassFab',
    DefaultAIBehavior = 'Nothing',
    -- default ChildCount to 1, so this lower-importance opai doesnt blow out legit attacks.  Our main care here is
    -- poorly located player mass fabs, not the general fact that player happens to own some.
    ChildCount = 1,
    MaxActivePlatoons = 2,

    FactoryBuilders = {
        CAIFactoryBuilderBlueprint {
            Name = 'ARTMF_Gunships_1',
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
                    { ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.uib0704 + categories.uub0704, FabResponseMinimum } },
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.ALLUNITS, PlayerMinimumUnits } },
                },
            },
            ChildrenTypes = { 'UEFGunships', 'IlluminateGunships', 'CybranGunships' },
            Priority = 700, -- lower priority than other surgical responses, but higher than standard attacks.
        },
    },
}