


-- ChildrenTypes
--   IlluminateFighterBombers



CAIOperationAIBlueprint {
    Name = 'AirFightersIlluminate',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 2,
    MaxActivePlatoons = 2,

    FactoryBuilders = {

        CAIFactoryBuilderBlueprint {
            Name = 'Illuminate_AirFighters_FighterBombers_1',
            BuilderType = 'Air',
            Faction = 'Illuminate',
            Platoons = {
                {
                    { 'uia0104', -1 },
                },
            },
            ChildrenTypes = { 'IlluminateFighterBombers' },
            Priority = 200,
        },
    },
}