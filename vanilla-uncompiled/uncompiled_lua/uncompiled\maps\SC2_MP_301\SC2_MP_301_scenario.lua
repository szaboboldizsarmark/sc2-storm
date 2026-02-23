version = 3
ScenarioInfo = {
    devname = 'MP_301: 1v1 LAND',
    name = '<LOC SC2_MAPNAME_0038>[2] Seraphim VII Site 3.11A (1v1)',
    x360_name = '<LOC SC2_MAPNAME_0039>[2] Seraphim VII Site 3.11A',
    x360_maptype = '1v1',
    x360_ranked = true,
    description = 'SC2_MP_301',
	mappack = 3,
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_301',
    size = {1024, 1024},
    map = '/maps/SC2_MP_301/SC2_MP_301.scmap',
    save = '/maps/SC2_MP_301/SC2_MP_301_save.lua',
    script = '/maps/SC2_MP_301/SC2_MP_301_script.lua',
    norushradius = 90.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    StartPositions = {
                ['ARMY_2'] = { 644.5, 216.164, 515.5 },
                ['ARMY_1'] = { 379.5, 216.164, 508.5 },
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
