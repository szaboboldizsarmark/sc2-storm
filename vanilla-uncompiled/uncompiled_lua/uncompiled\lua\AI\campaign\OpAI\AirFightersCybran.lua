


-- ChildrenTypes
--   CybranFighterBombers



CAIOperationAIBlueprint {
    Name = 'AirFightersCybran',
    DefaultAIBehavior = 'Nothing',
    ChildCount = 3,
    MaxActivePlatoons = 2,

    FactoryBuilders = {

        CAIFactoryBuilderBlueprint {
            Name = 'Cybran_AirFighters_FighterBombers_1',
            BuilderType = 'Air',
            Faction = 'Cybran',
            Platoons = {
                {
                    { 'uca0104', 1 },
                },
            },
            ChildrenTypes = { 'CybranFighterBombers' },
            Priority = 200,
        },
    },
}