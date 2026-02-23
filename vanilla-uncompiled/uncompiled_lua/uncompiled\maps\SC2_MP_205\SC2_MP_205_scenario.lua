version = 3
ScenarioInfo = {
    devname = 'MP_205: 3v3 - AIR',
    name = '<LOC SC2_MAPNAME_0034>[6] Corvana Chasm (3v3)',
    x360_name = '<LOC SC2_MAPNAME_0035>[4] Corvana Chasm (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_MP_205',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_205',
    size = {1024, 1024},
    map = '/maps/SC2_MP_205/SC2_MP_205.scmap',
    save = '/maps/SC2_MP_205/SC2_MP_205_save.lua',
    script = '/maps/SC2_MP_205/SC2_MP_205_script.lua',
    norushradius = 42.000000,
    norushoffsetX_ARMY_1 = -2.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    norushoffsetX_ARMY_5 = 0.000000,
    norushoffsetY_ARMY_5 = 0.000000,
    norushoffsetX_ARMY_6 = 0.000000,
    norushoffsetY_ARMY_6 = 0.000000,
    StartPositions = {
                ['ARMY_6'] = { 751.5, 163.71, 316.5 },
                ['ARMY_5'] = { 273.5, 163.708, 756.5 },
                ['ARMY_2'] = { 795.5, 159.193, 391.5 },
                ['ARMY_1'] = { 230.5, 159.182, 681.5 },
                ['ARMY_4'] = { 677.5, 159.287, 270.5 },
                ['ARMY_3'] = { 347.5, 159.276, 804.5 },

    },
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'ARMY_1','ARMY_2','ARMY_3','ARMY_4','ARMY_5','ARMY_6',} },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_EXTRA' ),
            },
        },
    }}
