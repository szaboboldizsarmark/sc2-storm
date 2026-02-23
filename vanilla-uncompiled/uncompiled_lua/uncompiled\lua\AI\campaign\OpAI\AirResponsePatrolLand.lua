-- Responsive Air Attacks triggered by player having an excess of certain land-based units.
-- This OpAI is intended to to use a Patrol thread, with the platoon sent to patrol to the player base.

local PlayerMobileNavalMin 		= 17	-- minimum player mobile naval units, minus engineers
local PlayerMobileLandMin 		= 70	-- minimum player mobile land units, minus engineers
local PlayerTurretsMin			= 18	-- minimum player defense turrets (excluding addons)
local PlayerNormalArtilleryMin	= 9		-- minimum player UEF normal artillery turrets
local PlayerShieldsMin			= 9		-- minimum player defense shields (excluding addons)

CAIOperationAIBlueprint {
    Name = 'AirResponsePatrolLand',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 3,
    MaxActivePlatoons = 3,

    FactoryBuilders = {
		-- An excess of land based units.
        CAIFactoryBuilderBlueprint {
            Name = 'ARPL_Gunships_1',
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
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { (categories.MOBILE * categories.NAVAL ) - categories.ENGINEER, PlayerMobileNavalMin} },
				},
                {
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { (categories.MOBILE * categories.LAND ) - categories.ENGINEER, PlayerMobileLandMin} },
				},
				{
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.uub0101 + categories.ucb0101 + categories.uib0101 + categories.uub0102 + categories.ucb0102 + categories.uib0102 , PlayerTurretsMin} },
				},
				{
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.uub0104 , PlayerNormalArtilleryMin}},
				},
				{
					{ ConditionName = 'TargetUnitsGreaterThanOrEqual', Parameters = { categories.uub0202 + categories.ucb0202 + categories.uib0202, PlayerShieldsMin} },
            	},
            },
            ChildrenTypes = { 'UEFGunships', 'IlluminateGunships', 'CybranGunships' },
            Priority = 800,
        },
    },
}