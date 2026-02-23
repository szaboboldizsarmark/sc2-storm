version = 3
ScenarioInfo = {
    devname = 'MP_003: 1v1 LAND/NAVAL',
    name = '<LOC SC2_MAPNAME_0004>[2] Finn\'s Revenge (1v1)',
    x360_name = '<LOC SC2_MAPNAME_0005>[2] Finn\'s Revenge',
    x360_maptype = '1v1',
    description = 'SC2_MP_003',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_003',
    size = {1024, 1024},
    map = '/maps/SC2_MP_003/SC2_MP_003.scmap',
    save = '/maps/SC2_MP_003/SC2_MP_003_save.lua',
    script = '/maps/SC2_MP_003/SC2_MP_003_script.lua',
    norushradius = 100.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    StartPositions = {
     			['ARMY_1'] = { 405.5, 20.536, 610.5 },
                ['ARMY_2'] = { 618.5, 20.536, 413.5 },
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
