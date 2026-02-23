--[[                                                                           ]]--
--[[  Automatically generated code (do not edit)                               ]]--
--[[                                                                           ]]--
--[[                                                                           ]]--
--[[  Scenario                                                                 ]]--
--[[                                                                           ]]--
Scenario = {
    Props = {
    },
    --[[                                                                           ]]--
    --[[  Areas                                                                    ]]--
    --[[                                                                           ]]--
    Areas = {
        ['AREA_01'] = {
            ['rectangle'] = RECTANGLE( 113.5, 161.5, 443.5, 361.5 ),
        },
    },
    --[[                                                                           ]]--
    --[[  Markers                                                                  ]]--
    --[[                                                                           ]]--
    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                ['ARMY_2'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.008, -0.649, 0.007, 0.76 ),
                    ['position'] = VECTOR3( 411.5, 188.951, 271.5 ),
                },
                ['ARMY_1'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.008, -0.649, 0.007, 0.76 ),
                    ['position'] = VECTOR3( 145.5, 188.952, 249.5 ),
                },
                ['SoundEmitter_SkyHigh'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_MP_004/snd_SC2_MP_004_Skyhigh' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 278.5, 200, 256.5 ),
                },
                ['Mass 01_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 405, 188.863, 277 ),
                },
                ['Mass 01'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 151, 188.924, 244 ),
                },
                ['Mass 02_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 418, 188.891, 277 ),
                },
                ['Mass 02'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 138, 188.89, 244 ),
                },
                ['Mass 03_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 403, 188.889, 266 ),
                },
                ['Mass 03'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 153, 188.924, 255 ),
                },
                ['Mass 04_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 416, 188.891, 264 ),
                },
                ['Mass 04'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 140, 188.925, 257 ),
                },
                ['Mass 06_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 354, 188.892, 224 ),
                },
                ['Mass 06'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 200, 188.924, 297 ),
                },
                ['Mass 07_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 300, 185.163, 288 ),
                },
                ['Mass 07'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 256, 185.18, 233 ),
                },
                ['Mass 08_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 319, 181.728, 215 ),
                },
                ['Mass 08'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 237, 181.762, 306 ),
                },
                ['Mass 05_mirrorXZ'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 349, 185.764, 330 ),
                },
                ['Mass 05'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 207, 185.245, 191 ),
                },
                ['Base Marker 01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Base Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 146.5, 188.924, 253.5 ),
                },
                ['Base Marker 02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Base Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 410.5, 188.924, 266.5 ),
                },
                ['Expansion Area 01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Expansion Area' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 390.5, 188.924, 224.5 ),
                },
                ['Expansion Area 02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Expansion Area' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 317.5, 185.199, 294.5 ),
                },
                ['Expansion Area 03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Expansion Area' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 167.5, 188.924, 294.5 ),
                },
                ['Expansion Area 04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Expansion Area' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 237.5, 185.214, 224.5 ),
                },
                ['Defensive Point 01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Defensive Point' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 366.5, 185.362, 282.5 ),
                },
                ['Defensive Point 02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Defensive Point' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 327.5, 181.881, 253.5 ),
                },
                ['Defensive Point 03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Defensive Point' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 191.5, 186.095, 235.5 ),
                },
                ['Defensive Point 04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Defensive Point' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 227.5, 181.841, 267.5 ),
                },
                ['Defensive Point 05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Defensive Point' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 276.5, 181.762, 261.5 ),
                },
                ['Rally Point 01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Rally Point' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 390.5, 188.151, 276.5 ),
                },
                ['Rally Point 02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Rally Point' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 163.5, 188.228, 243.5 ),
                },
                ['Default Path Node 01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Default Path Node' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 253.5, 181.762, 298.5 ),
                },
                ['Default Path Node 02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Default Path Node' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 305.5, 181.762, 223.5 ),
                },
                ['Default Path Node 03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Default Path Node' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 348.5, 185.213, 319.5 ),
                },
                ['Default Path Node 04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Default Path Node' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 213.5, 185.215, 204.5 ),
                },
            },
        },
    },
    Chains = {
    },
    --[[                                                                           ]]--
    --[[  Armies                                                                   ]]--
    --[[                                                                           ]]--
    Armies =  
    {
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_EXTRA'] =  
        {
            personality = '',
            plans = '',
            ['color'] = FLOAT( 1.0 ),
            faction = 0,
            Economy = {
                mass = 0,
                energy = 0,
            },
            Alliances = {
            },
            ['Units'] = GROUP {
                Units = {
                },
            },
        },
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_1'] =  
        {
            personality = '',
            plans = '/lua/ai/OpAI/DefaultBlankPlanlist.lua',
            ['color'] = FLOAT( 1.0 ),
            faction = 0,
            Economy = {
                mass = 0,
                energy = 0,
            },
            Alliances = {
            },
            ['Units'] = GROUP {
                Units = {
                },
            },
        },
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_2'] =  
        {
            personality = '',
            plans = '/lua/ai/OpAI/DefaultBlankPlanlist.lua',
            ['color'] = FLOAT( 1.0 ),
            faction = 0,
            Economy = {
                mass = 0,
                energy = 0,
            },
            Alliances = {
            },
            ['Units'] = GROUP {
                Units = {
                },
            },
        },
    },
}
