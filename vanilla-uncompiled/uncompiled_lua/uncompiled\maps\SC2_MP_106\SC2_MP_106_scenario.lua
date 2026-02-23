version = 3
ScenarioInfo = {
    devname = 'MP_106: 4 Player 3v1 LAND',
    name = '<LOC SC2_MAPNAME_0024>[4] Coalition Command Center (3v1)',
    x360_name = '<LOC SC2_MAPNAME_0025>[4] Coalition Command Center (3v1)',
    x360_maptype = '3v1',
    description = 'SC2_MP_106',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_106',
    size = {1024, 1024},
    map = '/maps/SC2_MP_106/SC2_MP_106.scmap',
    save = '/maps/SC2_MP_106/SC2_MP_106_save.lua',
    script = '/maps/SC2_MP_106/SC2_MP_106_script.lua',
    norushradius = 60.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
				['ARMY_1'] = { 801.5, 153.467, 224.5 },
                ['ARMY_2'] = { 154.5, 126.373, 426.5 },
                ['ARMY_3'] = { 464.5, 131.699, 514.5 },
                ['ARMY_4'] = { 363.5, 118.589, 830.5 },
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
