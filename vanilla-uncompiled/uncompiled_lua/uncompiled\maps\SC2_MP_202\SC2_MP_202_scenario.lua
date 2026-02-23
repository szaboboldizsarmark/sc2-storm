version = 3
ScenarioInfo = {
    devname = 'MP_202: 2v2 LAND',
    name = '<LOC SC2_MAPNAME_0028>[4] Sinorok Rift Armory (2v2)',
    x360_name = '<LOC SC2_MAPNAME_0029>[4] Sinorok Rift Armory (2v2)',
    x360_maptype = '2v2',
    description = 'SC2_MP_202',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_202',
    size = {1024, 1024},
    map = '/maps/SC2_MP_202/SC2_MP_202.scmap',
    save = '/maps/SC2_MP_202/SC2_MP_202_save.lua',
    script = '/maps/SC2_MP_202/SC2_MP_202_script.lua',
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
				['ARMY_4'] = { 216.5, 84.857, 703.5 },
                ['ARMY_1'] = { 217.5, 84.857, 344.5 },
                ['ARMY_3'] = { 834.5, 84.858, 344.5 },
                ['ARMY_2'] = { 835.5, 84.858, 703.5 },
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
