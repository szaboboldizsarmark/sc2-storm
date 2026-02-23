version = 3
ScenarioInfo = {
    devname = 'MP_102: 2v2 LAND',
    name = '<LOC SC2_MAPNAME_0016>[4]Powderhorn Mesa (2v2)',
    x360_name = '<LOC SC2_MAPNAME_0017>[4]Powderhorn Mesa (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_MP_102',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_102',
    size = {1024, 1024},
    map = '/maps/SC2_MP_102/SC2_MP_102.scmap',
    save = '/maps/SC2_MP_102/SC2_MP_102_save.lua',
    script = '/maps/SC2_MP_102/SC2_MP_102_script.lua',
    norushradius = 65.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
	 			['ARMY_2'] = { 665.5, 95.728, 511.5 },
                ['ARMY_1'] = { 358.5, 95.728, 511.5 },
                ['ARMY_4'] = { 512.5, 95.731, 356.5 },
                ['ARMY_3'] = { 512.5, 95.731, 667.5 },
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
