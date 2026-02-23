version = 3
ScenarioInfo = {
    devname = 'MP_204: 4 FFA LAND',
    name = '<LOC SC2_MAPNAME_0032>[4] Geothermal Borehole (FFA)',
    x360_name = '<LOC SC2_MAPNAME_0033>[4] Geothermal Borehole',
    x360_maptype = '4FFA',
    description = 'SC2_MP_204',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_204',
    size = {1024, 1024},
    map = '/maps/SC2_MP_204/SC2_MP_204.scmap',
    save = '/maps/SC2_MP_204/SC2_MP_204_save.lua',
    script = '/maps/SC2_MP_204/SC2_MP_204_script.lua',
    norushradius = 85.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    norushoffsetX_ARMY_4 = 0.000000,
    norushoffsetY_ARMY_4 = 0.000000,
    StartPositions = {
    			['ARMY_3'] = { 513.5, 177.438, 257.5 },
                ['ARMY_4'] = { 512.5, 177.438, 767.5 },
                ['ARMY_2'] = { 770.5, 177.441, 511.5 },
                ['ARMY_1'] = { 254.5, 177.438, 512.5 },

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
