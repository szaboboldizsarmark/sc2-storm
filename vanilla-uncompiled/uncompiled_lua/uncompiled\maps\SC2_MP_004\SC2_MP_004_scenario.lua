version = 3
ScenarioInfo = {
    devname = 'MP_004: 1v1 LAND',
    name = '<LOC SC2_MAPNAME_0006>[2] Spring Duel (1v1)',
    x360_name = '<LOC SC2_MAPNAME_0007>[2] Spring Duel',
    x360_maptype = '1v1',
 	pc_ranked = true,
    description = 'SC2_MP_004',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_004',
    size = {512, 512},
    map = '/maps/SC2_MP_004/SC2_MP_004.scmap',
    save = '/maps/SC2_MP_004/SC2_MP_004_save.lua',
    script = '/maps/SC2_MP_004/SC2_MP_004_script.lua',
    norushradius = 100.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    StartPositions = {
     			['ARMY_2'] = { 411.5, 188.951, 271.5 },
                ['ARMY_1'] = { 145.5, 188.952, 249.5 },
    },
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'ARMY_1','ARMY_2',} },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_EXTRA' ),
            },
        },
    }}
