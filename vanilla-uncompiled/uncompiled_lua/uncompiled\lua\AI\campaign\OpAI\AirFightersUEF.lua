


-- ChildrenTypes
--   UEFFighters



CAIOperationAIBlueprint {
    Name = 'AirFightersUEF',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 3,
    MaxActivePlatoons = 2,

    FactoryBuilders = {

        CAIFactoryBuilderBlueprint {
            Name = 'UEF_AirFighters_Fighters_1',
            BuilderType = 'Air',
            Faction = 'UEF',
            Platoons = {
                {
                    { 'uua0101', 1 },
                },
            },
            ChildrenTypes = { 'UEFFighters' },
            Priority = 200,
        },
    },
}