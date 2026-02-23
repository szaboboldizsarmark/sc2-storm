version = 3
ScenarioInfo = {
    devname = 'D1_101_1K: 2v2 LAND',
    name = '<LOC SC2_DLC_MAPNAME_0008>[4] Etched Desert (2v2)',
    x360_name = '<LOC SC2_DLC_MAPNAME_0008>[4] Etched Desert (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_D1_101_1K',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_D1_101_1K',
    size = {1024, 1024},
    map = '/maps/SC2_D1_101_1K/SC2_D1_101_1K.scmap',
    save = '/maps/SC2_D1_101_1K/SC2_D1_101_1K_save.lua',
    script = '/maps/SC2_D1_101_1K/SC2_D1_101_1K_script.lua',
    norushradius = 95.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = -30.000000,
    norushoffsetY_ARMY_3 = 50.000000,
    norushoffsetX_ARMY_4 = 30.000000,
    norushoffsetY_ARMY_4 = -50.000000,
    mappack = 4,
    StartPositions = {
                ['ARMY_1'] = { 182.5, 28.526, 416.5 },
                ['ARMY_2'] = { 841.5, 28.526, 607.5 },
                ['ARMY_3'] = { 459.5, 28.526, 173.5 },
                ['ARMY_4'] = { 563.5, 28.526, 850.5 },
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
