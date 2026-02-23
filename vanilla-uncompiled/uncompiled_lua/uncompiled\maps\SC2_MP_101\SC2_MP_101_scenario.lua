version = 3
ScenarioInfo = {
    devname = 'MP_101: 1v1 LAND',
    name = '<LOC SC2_MAPNAME_0014>[2] Clarke Training Center (1v1)',
    x360_name = '<LOC SC2_MAPNAME_0015>[2] Clarke Training Center',
    x360_maptype = '1v1',
    x360_ranked = true,
    pc_ranked = true,
    description = 'SC2_MP_101',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_101',
    size = {1024, 1024},
    map = '/maps/SC2_MP_101/SC2_MP_101.scmap',
    save = '/maps/SC2_MP_101/SC2_MP_101_save.lua',
    script = '/maps/SC2_MP_101/SC2_MP_101_script.lua',
    norushradius = 75.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    StartPositions = {
				['ARMY_1'] = { 349.5, 110.046, 554.5 },
                ['ARMY_2'] = { 676.5, 110.008, 554.5 },
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
