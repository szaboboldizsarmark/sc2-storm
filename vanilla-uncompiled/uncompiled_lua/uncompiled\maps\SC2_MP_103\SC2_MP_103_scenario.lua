version = 3
ScenarioInfo = {
    devname = 'MP_103: 2v2 NAVAL',
    name = '<LOC SC2_MAPNAME_0018>[4] Weddell Isles (2v2)',
    x360_name = '<LOC SC2_MAPNAME_0019>[4] Weddell Isles (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_MP_103',
	mappack = 2,
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_103',
    size = {1024, 1024},
    map = '/maps/SC2_MP_103/SC2_MP_103.scmap',
    save = '/maps/SC2_MP_103/SC2_MP_103_save.lua',
    script = '/maps/SC2_MP_103/SC2_MP_103_script.lua',
    norushradius = 80.000000,
    norushoffsetX_ARMY_1 = 10.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = -10.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = -10.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 10.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
    			['ARMY_4'] = { 387.5, 18.384, 249.5 },
                ['ARMY_1'] = { 542.5, 18.384, 131.5 },
                ['ARMY_3'] = { 631.5, 18.384, 763.5 },
                ['ARMY_2'] = { 477.5, 18.387, 895.5 },
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
