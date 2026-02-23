version = 3
ScenarioInfo = {
    devname = 'D1_301: 1v1 LAND',
    name = '<LOC SC2_DLC_MAPNAME_0018>[2] QAI Labs (1v1)',
    x360_name = '<LOC SC2_DLC_MAPNAME_0018>[2] QAI Labs (1v1)',
    x360_maptype = '1v1',
    description = 'SC2_D1_301',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_D1_301',
    size = {1024, 1024},
    map = '/maps/SC2_D1_301/SC2_D1_301.scmap',
    save = '/maps/SC2_D1_301/SC2_D1_301_save.lua',
    script = '/maps/SC2_D1_301/SC2_D1_301_script.lua',
    norushradius = 65.000000,
    norushoffsetX_ARMY_1 = 20.000000,
    norushoffsetY_ARMY_1 = -10.000000,
    norushoffsetX_ARMY_2 = -20.000000,
    norushoffsetY_ARMY_2 = 10.000000,
    mappack = 4,
    StartPositions = {
                ['ARMY_1'] = { 286.5, 353.054, 560.5 },
                ['ARMY_2'] = { 737.5, 353.054, 463.5 },
    },
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'ARMY_1','ARMY_2',} },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_EXTRA' ),
            },
        },
    }}
