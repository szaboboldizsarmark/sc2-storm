version = 3
ScenarioInfo = {
    devname = 'MP_304: 4 Player 2v2 LAND/NAVAL',
    name = '<LOC SC2_MAPNAME_0046>[4] Iskellian Coast (2v2)',
    x360_name = '<LOC SC2_MAPNAME_0047>[4] Iskellian Coast (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_MP_304_1K',
	mappack = 2,
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_304_1K',
    size = {1024, 1024},
    map = '/maps/SC2_MP_304_1K/SC2_MP_304_1K.scmap',
    save = '/maps/SC2_MP_304_1K/SC2_MP_304_1K_save.lua',
    script = '/maps/SC2_MP_304_1K/SC2_MP_304_1K_script.lua',
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
    			['ARMY_2'] = { 657.5, 120.433, 421.5 },
                ['ARMY_1'] = { 366.5, 120.433, 602.5 },
                ['ARMY_4'] = { 910.5, 123.239, 175.5 },
                ['ARMY_3'] = { 113.5, 123.239, 848.5 },
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
