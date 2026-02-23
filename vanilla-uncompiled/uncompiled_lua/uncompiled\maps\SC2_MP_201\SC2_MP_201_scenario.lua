version = 3
ScenarioInfo = {
    devname = 'MP_201: 1v1 LAND/NAVAL',
    name = '<LOC SC2_MAPNAME_0026>[2] Markon Bridge (1v1)',
    x360_name = '<LOC SC2_MAPNAME_0027>[2] Markon Bridge',
    x360_maptype = '1v1',
    x360_ranked = true,
    description = 'SC2_MP_201',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_201',
    size = {1024, 1024},
    map = '/maps/SC2_MP_201/SC2_MP_201.scmap',
    save = '/maps/SC2_MP_201/SC2_MP_201_save.lua',
    script = '/maps/SC2_MP_201/SC2_MP_201_script.lua',
    norushradius = 100.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    StartPositions = {
				['ARMY_2'] = { 677.5, 36.495, 416.5 },
                ['ARMY_1'] = { 346.5, 36.506, 607.5 },
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
