version = 3
ScenarioInfo = {
    devname = 'MP_306: 3 Player FFA LAND',
    name = '<LOC SC2_MAPNAME_0050>[3] Shiva Prime (FFA)',
    x360_name = '<LOC SC2_MAPNAME_0051>[3] Shiva Prime',
    x360_maptype = "3FFA",
    description = 'SC2_MP_306',
    type = 'skirmish',
    starts = true,
    preview = '',
    reverbPreset = 'SC2_MP_306',
    size = {1024, 1024},
    map = '/maps/SC2_MP_306/SC2_MP_306.scmap',
    save = '/maps/SC2_MP_306/SC2_MP_306_save.lua',
    script = '/maps/SC2_MP_306/SC2_MP_306_script.lua',
    norushradius = 90.000000,
    norushoffsetX_ARMY_1 = 0.000000,
    norushoffsetY_ARMY_1 = 0.000000,
    norushoffsetX_ARMY_2 = 0.000000,
    norushoffsetY_ARMY_2 = 0.000000,
    norushoffsetX_ARMY_3 = 0.000000,
    norushoffsetY_ARMY_3 = 0.000000,
    StartPositions = {
    			['ARMY_1'] = { 379.5, 267.18, 642.5 },
                ['ARMY_2'] = { 440.5, 274.522, 341.5 },
                ['ARMY_3'] = { 680.5, 274.514, 578.5 },
    },
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'ARMY_1','ARMY_2','ARMY_3',} },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_EXTRA' ),
            },
        },
    }}
