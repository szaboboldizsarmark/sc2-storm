version = 3
ScenarioInfo = {
    devname = 'MP_007: 4 FFA LAND',
    name = '<LOC SC2_MAPNAME_0012>[4] Emerald Crater (FFA)',
    x360_name = '<LOC SC2_MAPNAME_0013>[4] Emerald Crater',
    x360_maptype = '4FFA',
    description = 'SC2_MP_007',
	mappack = 1,
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_007',
    size = {1024, 1024},
    map = '/maps/SC2_MP_007/SC2_MP_007.scmap',
    save = '/maps/SC2_MP_007/SC2_MP_007_save.lua',
    script = '/maps/SC2_MP_007/SC2_MP_007_script.lua',
    norushradius = 75.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
				['ARMY_4'] = { 200.5, 9.921, 498.5 },
                ['ARMY_1'] = { 523.5, 9.921, 189.5 },
                ['ARMY_3'] = { 826.5, 9.922, 511.5 },
                ['ARMY_2'] = { 506.5, 9.925, 821.5 },
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
