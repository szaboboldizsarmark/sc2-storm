version = 3
ScenarioInfo = {
    devname = 'MP_302: 4 Player FFA LAND/NAVAL',
    name = '<LOC SC2_MAPNAME_0040>[4] Treallach Island (FFA)',
    x360_name = '<LOC SC2_MAPNAME_0041>[4] Treallach Island',
    x360_maptype = '4FFA',
	pc_ranked = true,
    description = 'SC2_MP_302',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_302',
    size = {1024, 1024},
    map = '/maps/SC2_MP_302/SC2_MP_302.scmap',
    save = '/maps/SC2_MP_302/SC2_MP_302_save.lua',
    script = '/maps/SC2_MP_302/SC2_MP_302_script.lua',
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
	 			['ARMY_4'] = { 390.5, 67.449, 343.5 },
                ['ARMY_2'] = { 682.5, 67.449, 392.5 },
                ['ARMY_3'] = { 631.5, 67.45, 682.5 },
                ['ARMY_1'] = { 342.5, 67.45, 633.5 },
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
