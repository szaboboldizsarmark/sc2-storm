version = 3
ScenarioInfo = {
    devname = 'MP_303: 4 Player 2v2 LAND',
    name = '<LOC SC2_MAPNAME_0042>[4] QAI Prototype Facility (2v2)',
    x360_name = '<LOC SC2_MAPNAME_0043>[4] QAI Prototype Facility (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_MP_303',
	mappack = 1,
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_303',
    size = {1024, 1024},
    map = '/maps/SC2_MP_303/SC2_MP_303.scmap',
    save = '/maps/SC2_MP_303/SC2_MP_303_save.lua',
    script = '/maps/SC2_MP_303/SC2_MP_303_script.lua',
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
 				['ARMY_2'] = { 638.5, 81.05, 386.5 },
                ['ARMY_4'] = { 385.5, 81.05, 386.5 },
                ['ARMY_1'] = { 385.5, 81.05, 637.5 },
                ['ARMY_3'] = { 638.5, 81.05, 637.5 },
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
