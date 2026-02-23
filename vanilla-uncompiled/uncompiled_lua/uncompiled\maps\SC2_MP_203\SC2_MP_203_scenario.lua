version = 3
ScenarioInfo = {
    devname = 'MP_203: 2v2 LAND/NAVAL',
    name = '<LOC SC2_MAPNAME_0030>[4] Mirror Island (2v2)',
    x360_name = '<LOC SC2_MAPNAME_0031>[4] Mirror Island (2v2)',
    x360_maptype = '2v2',
    x360_ranked = true,
    pc_ranked = true,
    description = 'SC2_MP_203',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_203',
    size = {1024, 1024},
    map = '/maps/SC2_MP_203/SC2_MP_203.scmap',
    save = '/maps/SC2_MP_203/SC2_MP_203_save.lua',
    script = '/maps/SC2_MP_203/SC2_MP_203_script.lua',
    norushradius = 80.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
     			['ARMY_4'] = { 421.5, 51.332, 297.5 },
                ['ARMY_1'] = { 601.5, 51.334, 299.5 },
                ['ARMY_3'] = { 601.5, 51.334, 722.5 },
                ['ARMY_2'] = { 420.5, 51.335, 723.5 },
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
