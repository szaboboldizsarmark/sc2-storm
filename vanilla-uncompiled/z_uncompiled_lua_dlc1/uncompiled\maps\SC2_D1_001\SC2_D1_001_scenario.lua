version = 3
ScenarioInfo = {
    devname = 'D1_001: 2v2 LAND',
    name = '<LOC SC2_DLC_MAPNAME_0020>[4] Way Station Zeta (2v2)',
    x360_name = '<LOC SC2_DLC_MAPNAME_0020>[4] Way Station Zeta (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_D1_001',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_D1_001',
    size = {1024, 1024},
    map = '/maps/SC2_D1_001/SC2_D1_001.scmap',
    save = '/maps/SC2_D1_001/SC2_D1_001_save.lua',
    script = '/maps/SC2_D1_001/SC2_D1_001_script.lua',
    mappack = 4,
    norushradius = 60.000000,
    norushoffsetX_ARMY_1 = 30.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = -30.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = -8.000000,
    norushoffsetY_ARMY_3 = -20.000000,
    norushoffsetX_ARMY_4 = 8.000000,
    norushoffsetY_ARMY_4 = 20.000000,
    StartPositions = {
                ['ARMY_1'] = { 365.5, 108, 490.5 },
                ['ARMY_2'] = { 656.5, 108, 535.5 },
                ['ARMY_3'] = { 288.5, 108, 564.5 },
                ['ARMY_4'] = { 731.5, 108, 460.5 },

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
