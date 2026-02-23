version = 3
ScenarioInfo = {
    devname = 'MP_006: 4 FFA LAND',
    name = '<LOC SC2_MAPNAME_0010>[4] Arctic Refuge (FFA)',
    x360_name = '<LOC SC2_MAPNAME_0011>[4] Arctic Refuge',
    x360_maptype = '4FFA',
    x360_ranked = true,
    pc_ranked = true,
    description = 'SC2_MP_006',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_006',
    size = {512, 512},
    map = '/maps/SC2_MP_006/SC2_MP_006.scmap',
    save = '/maps/SC2_MP_006/SC2_MP_006_save.lua',
    script = '/maps/SC2_MP_006/SC2_MP_006_script.lua',
    norushradius = 95.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
				['ARMY_1'] = { 407.5, 31.808, 129.5 },
                ['ARMY_2'] = { 110.5, 31.811, 385.5 },
                ['ARMY_3'] = { 382.5, 31.81, 402.5 },
                ['ARMY_4'] = { 126.5, 31.807, 114.5 },
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
