version = 3
ScenarioInfo = {
    devname = 'MP_005: 2v2 LAND',
    name = '<LOC SC2_MAPNAME_0008>[4] Fields of Isis (2v2)',
    x360_name = '<LOC SC2_MAPNAME_0009>[4] Fields of Isis (2v2)',
    x360_maptype = '2v2',
    x360_ranked = true,
    description = 'SC2_MP_005',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_005',
    size = {512, 512},
    map = '/maps/SC2_MP_005/SC2_MP_005.scmap',
    save = '/maps/SC2_MP_005/SC2_MP_005_save.lua',
    script = '/maps/SC2_MP_005/SC2_MP_005_script.lua',
    norushradius = 100.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
                ['ARMY_2'] = { 441.5, 30.744, 436.5 },
                ['ARMY_3'] = { 72.5, 30.745, 437.5 },
                ['ARMY_4'] = { 441.5, 30.745, 75.5 },
                ['ARMY_1'] = { 72.5, 30.746, 74.5 },
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
