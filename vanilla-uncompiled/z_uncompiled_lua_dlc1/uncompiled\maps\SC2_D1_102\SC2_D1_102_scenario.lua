version = 3
ScenarioInfo = {
    devname = 'D1_102: 1v1 LAND',
    name = '<LOC SC2_DLC_MAPNAME_0010>[2] Desolatia (1v1)',
    x360_name = '<LOC SC2_DLC_MAPNAME_0010>[2] Desolatia (1v1)',
    x360_maptype = '1v1',
    description = 'SC2_D1_102',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_D1_102',
    size = {1024, 1024},
    map = '/maps/SC2_D1_102/SC2_D1_102.scmap',
    save = '/maps/SC2_D1_102/SC2_D1_102_save.lua',
    script = '/maps/SC2_D1_102/SC2_D1_102_script.lua',
    norushradius = 75.000000,
    norushoffsetX_ARMY_1 = -30.000000,
    norushoffsetY_ARMY_1 = 10.000000,
    norushoffsetX_ARMY_2 = 30.000000,
    norushoffsetY_ARMY_2 = -10.000000,
    mappack = 4,
    StartPositions = {
                ['ARMY_1'] = { 426.5, 240.305, 423.5 },
                ['ARMY_2'] = { 597.5, 240.304, 600.5 },
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
