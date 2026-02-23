version = 3
ScenarioInfo = {
    devname = 'D1_201_1K: 2v2 LAND/NAVAL',
    name = '<LOC SC2_DLC_MAPNAME_0014>[4] Seraphim Isles (2v2)',
    x360_name = '<LOC SC2_DLC_MAPNAME_0014>[4] Seraphim Isles (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_D1_201_1K',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_D1_201_1K',
    size = {1024, 1024},
    map = '/maps/SC2_D1_201_1K/SC2_D1_201_1K.scmap',
    save = '/maps/SC2_D1_201_1K/SC2_D1_201_1K_save.lua',
    script = '/maps/SC2_D1_201_1K/SC2_D1_201_1K_script.lua',
    norushradius = 75.000000,
    norushoffsetX_ARMY_1 = -45.000000,
    norushoffsetY_ARMY_1 = 10.000000,
    norushoffsetX_ARMY_2 = 45.000000,
    norushoffsetY_ARMY_2 = -10.000000,
    norushoffsetX_ARMY_3 = -30.000000,
    norushoffsetY_ARMY_3 = -10.000000,
    norushoffsetX_ARMY_4 = 30.000000,
    norushoffsetY_ARMY_4 = 10.000000,
    mappack = 4,
    StartPositions = {
                ['ARMY_1'] = { 231.5, 31.538, 576.5 },
                ['ARMY_2'] = { 792.5, 31.537, 447.5 },
                ['ARMY_3'] = { 442.5, 32.813, 873.5 },
                ['ARMY_4'] = { 580.5, 32.814, 149.5 },
    },
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'ARMY_1','ARMY_2','ARMY_3','ARMY_4',} },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_EXTRA' ),
            },
        },
    }}
