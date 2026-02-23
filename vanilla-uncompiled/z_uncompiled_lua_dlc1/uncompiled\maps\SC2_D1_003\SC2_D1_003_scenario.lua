version = 3
ScenarioInfo = {
    devname = 'D1_003: 2v2 LAND/NAVAL',
    name = '<LOC SC2_DLC_MAPNAME_0004>[4] Rigs (2v2, FFA)',
    x360_name = '<LOC SC2_DLC_MAPNAME_0005>[4] Rigs (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_D1_003',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_D1_003',
    size = {1024, 1024},
    map = '/maps/SC2_D1_003/SC2_D1_003.scmap',
    save = '/maps/SC2_D1_003/SC2_D1_003_save.lua',
    script = '/maps/SC2_D1_003/SC2_D1_003_script.lua',
    norushradius = 100.000000,
    norushoffsetX_ARMY_1 = 15.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = -15.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 15.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = -15.000000,
    mappack = 4,
    StartPositions = {
                ['ARMY_1'] = { 317.5, 260.152, 705.5 },
                ['ARMY_2'] = { 707.5, 260.154, 317.5 },
                ['ARMY_3'] = { 319.5, 260.154, 318.5 },
                ['ARMY_4'] = { 706.5, 260.153, 707.5 },
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
