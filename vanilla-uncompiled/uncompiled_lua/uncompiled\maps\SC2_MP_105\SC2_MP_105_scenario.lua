version = 3
ScenarioInfo = {
    devname = 'MP_105: 1v1 LAND/NAVAL',
    name = '<LOC SC2_MAPNAME_0022>[2] Coalition Shipyard (1v1)',
    x360_name = '<LOC SC2_MAPNAME_0023>[2] Coalition Shipyard',
    x360_maptype = '1v1',
    x360_ranked = true,
    pc_ranked = true,
    description = 'SC2_MP_105',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_105',
    size = {1024, 1024},
    map = '/maps/SC2_MP_105/SC2_MP_105.scmap',
    save = '/maps/SC2_MP_105/SC2_MP_105_save.lua',
    script = '/maps/SC2_MP_105/SC2_MP_105_script.lua',
    norushradius = 100.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    StartPositions = {
	 			['ARMY_1'] = { 512.435, 77.998, 712.51 },
                ['ARMY_2'] = { 512.435, 77.999, 314.51 },
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
