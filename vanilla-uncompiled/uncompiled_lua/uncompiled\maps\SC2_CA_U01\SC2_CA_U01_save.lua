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
        ['AREA_MOVE_CHECK'] = {
            ['rectangle'] = RECTANGLE( 510.5, 514.5, 582.5, 526.5 ),
        },
        ['AREA_COURTYARD_CHECK'] = {
            ['rectangle'] = RECTANGLE( 513, 409, 628, 508 ),
        },
        ['AREA_1'] = {
            ['rectangle'] = RECTANGLE( 379.5, 306.5, 659.5, 626.5 ),
        },
        ['AREA_2'] = {
            ['rectangle'] = RECTANGLE( 376.5, 307.5, 816.5, 627.5 ),
        },
        ['AREA_PART2_CHECK'] = {
            ['rectangle'] = RECTANGLE( 726.5, 432.5, 826.5, 472.5 ),
        },
        ['CAMERA_ZOOM_AREA_01'] = {
            ['rectangle'] = RECTANGLE( 606.5, 432.5, 666.5, 492.5 ),
        },
        ['CAMERA_ZOOM_AREA_02'] = {
            ['rectangle'] = RECTANGLE( 512.5, 450.5, 592.5, 530.5 ),
        },
        ['CAMERA_ZOOM_AREA_03'] = {
            ['rectangle'] = RECTANGLE( 407.5, 348.5, 687.5, 628.5 ),
        },
    },
    --[[                                                                           ]]--
    --[[  Markers                                                                  ]]--
    --[[                                                                           ]]--
    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                ['ALLY01_LANDING_ZONE_1_2'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 577.5, 110.015, 446.5 ),
                },
                ['ARMY_PLAYER'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.002, -0.722, 0.002, 0.692 ),
                    ['position'] = VECTOR3( 524.5, 109.82, 591.5 ),
                },
                ['NIS_DEST_PLANE_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 416.5, 98, 807.5 ),
                },
                ['ENEM01_LANDING_ZONE_2'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 635.5, 116.222, 443.5 ),
                },
                ['COURTYARD_ITEM_POS_3'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 504.5, 110.096, 586.5 ),
                },
                ['COURTYARD_ITEM_POS_6'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 547.5, 110.036, 439.5 ),
                },
                ['ALLY01_LANDING_ZONE_1_1'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 556.5, 110.038, 453.5 ),
                },
                ['ALLY01_LANDING_ZONE_1_6'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 578.5, 110.018, 476.5 ),
                },
                ['ALLY01_TRANSPORT_EXIT_ZONE'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 678.705, 118.615, 633.958 ),
                },
                ['ENEM01_LANDING_ZONE_1'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 622.5, 116.22, 486.5 ),
                },
                ['ENEM01_LANDING_ZONE_4'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 608.5, 116.219, 504.5 ),
                },
                ['ALLY01_LANDING_ZONE_1_4'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 557.5, 110.037, 470.5 ),
                },
                ['GATETARGET_POS_2'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 607.5, 109.968, 461.5 ),
                },
                ['ALLY01_LANDING_ZONE_1_7'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 566.5, 110.035, 477.5 ),
                },
                ['ALLY01_LANDING_ZONE_1_5'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 586.5, 110.002, 466.5 ),
                },
                ['GATETARGET_POS_1'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 607.5, 110.053, 469.5 ),
                },
                ['FACTORY_ROLLOFF_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.003, -0.013, 0, 1 ),
                    ['position'] = VECTOR3( 546.5, 110.043, 513.5 ),
                },
                ['ENEM01_LANDING_ZONE_3'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 591.5, 116.222, 521.5 ),
                },
                ['ESCORT_MOVE_LOC'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 593.5, 109.988, 464.5 ),
                },
                ['EXPERIMENTAL_MOVE_LOC_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 572.5, 110.029, 485.5 ),
                },
                ['EXPERIMENTAL_MOVE_LOC'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 569.5, 110.036, 468.5 ),
                },
                ['OUTSIDE_GATE_POS_3'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 662.5, 106.421, 464.5 ),
                },
                ['OUTSIDE_GATE_POS_2'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 649.5, 106.804, 471.5 ),
                },
                ['ENEM01_LANDING_ZONE_6'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 567.5, 116.223, 403.5 ),
                },
                ['OUTSIDE_GATE_POS_1'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 650.5, 106.686, 458.5 ),
                },
                ['NIS_DEST_TANKS_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 560.5, 110.033, 463.5 ),
                },
                ['NIS_DEST_TANKS_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 547.5, 110.051, 520.5 ),
                },
                ['NIS_DEST_CDR_00'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 551.5, 110.094, 571.5 ),
                },
                ['NIS_DEST_CDR_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.006, 0.169, -0.001, 0.986 ),
                    ['position'] = VECTOR3( 547.5, 110.051, 507.5 ),
                },
                ['ALLY01_LANDING_ZONE_1_8'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 564.5, 110.035, 447.5 ),
                },
                ['ENEM01_TRANSPORT_EXIT_ZONE'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 775.5, 99.578, 343.5 ),
                },
                ['COURTYARD_ITEM_POS_1'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 572.5, 110.032, 438.5 ),
                },
                ['COURTYARD_ITEM_POS_2'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 600.5, 110.112, 438.5 ),
                },
                ['COURTYARD_ITEM_POS_5'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 548.5, 116.223, 375.5 ),
                },
                ['FACTORY_ROLLOFF_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 561.5, 110.037, 513.5 ),
                },
                ['NIS_DEST_PLANE_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 672.5, 99.578, 368.5 ),
                },
                ['COURTYARD_ITEM_POS_4'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 528.5, 110.096, 596.5 ),
                },
                ['ALLY01_LANDING_ZONE_1_3'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 587.5, 109.983, 453.5 ),
                },
                ['ARMY_ENEM01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.002, -0.722, 0.002, 0.692 ),
                    ['position'] = VECTOR3( 735.5, 104.54, 450.5 ),
                },
                ['ENEM01_LANDING_ZONE_5'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 635.5, 116.222, 406.5 ),
                },
                ['SoundEmitter_Factory_02'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_U01/snd_SC2_CA_U01_Factory_Rumble' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 311.5, 146.954, 490.5 ),
                },
                ['SoundEmitter_Factory_01'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_U01/snd_SC2_CA_U01_Factory_Rumble' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 320.5, 164.66, 232.5 ),
                },
                ['SoundEmitter_SkyHigh'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_U01/snd_SC2_CA_U01_Skyhigh' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 545.5, 200.034, 500.5 ),
                },
                ['SoundEmitter_Bridge'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_U01/snd_SC2_CA_U01_Bridge' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 771.5, 101.352, 490.5 ),
                },
                ['P1_INTEL'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 538.5, 110.033, 472.5 ),
                },
                ['P3_INTEL'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 690.5, 106.112, 451.5 ),
                },
                ['NIS_DEST_ENG_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 547.5, 116.22, 383.5 ),
                },
                ['NIS_DEST_ENG_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 635.5, 116.219, 485.5 ),
                },
                ['CAM_OPENING_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.403, 0.506, 0 ),
                    ['position'] = VECTOR3( 633.93, 160.61, 572.179 ),
                },
                ['CAM_BUILDING_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.372, 0.518, 0 ),
                    ['position'] = VECTOR3( 536.191, 131.4, 592.804 ),
                },
                ['CAM_COURTYARD_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.105, 1.103, 0 ),
                    ['position'] = VECTOR3( 610.171, 199.03, 492.37 ),
                },
                ['CAM_GATE_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.105, 1.103, 0 ),
                    ['position'] = VECTOR3( 643.301, 144.451, 473.235 ),
                },
                ['CAM_EXPERIMENTAL_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.105, 1.103, 0 ),
                    ['position'] = VECTOR3( 757.668, 147.804, 460.893 ),
                },
                ['CAM_REINFORCEMENTS_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.105, 1.103, 0 ),
                    ['position'] = VECTOR3( 566.151, 159.14, 393.53 ),
                },
                ['CAM_RADAR_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.105, 1.103, 0 ),
                    ['position'] = VECTOR3( 362.904, 256.356, 265.943 ),
                },
                ['CAM_BUILDING_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -3.142, 0.675, 0 ),
                    ['position'] = VECTOR3( 516.009, 135.733, 598.034 ),
                },
                ['CAM_GATE_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.812, 1.068, 0 ),
                    ['position'] = VECTOR3( 619.248, 148.425, 482.761 ),
                },
                ['CAM_RADAR_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.262, 0.035, 0 ),
                    ['position'] = VECTOR3( 393.98, 170.174, 305.469 ),
                },
                ['CAM_EXPERIMENTAL_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.838, 0.396, 0 ),
                    ['position'] = VECTOR3( 762.739, 119.507, 462.914 ),
                },
                ['CAM_COURTYARD_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.026, 0.993, 0 ),
                    ['position'] = VECTOR3( 675.471, 327.329, 550.953 ),
                },
                ['CAM_GAMEPLAY_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -3.094, 1.103, 0 ),
                    ['position'] = VECTOR3( 563.502, 214.971, 548.13 ),
                },
                ['NIS_DEST_SECONDWAVE_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 720.5, 104.617, 406.5 ),
                },
                ['NIS_DEST_SECONDWAVE_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 689.5, 104.589, 406.5 ),
                },
                ['NIS_DEST_SECONDWAVE_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 664.5, 105.244, 418.5 ),
                },
                ['NIS_DEST_SECONDWAVE_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 728.5, 104.592, 493.5 ),
                },
                ['NIS_DEST_SECONDWAVE_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 702.5, 105.714, 489.5 ),
                },
                ['NIS_DEST_SECONDWAVE_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 661.5, 105.748, 507.5 ),
                },
                ['NIS_DEST_EXPERIMENTAL_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 727.5, 105.04, 460.5 ),
                },
                ['NIS_DEST_EXPERIMENTAL_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 729.5, 104.902, 446.5 ),
                },
                ['CDR_MOVE_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 572.5, 110.028, 477.5 ),
                },
                ['CAM_BUILDING_03'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.885, 0.314, 0 ),
                    ['position'] = VECTOR3( 552.19, 117.581, 574.394 ),
                },
                ['CAM_BUILDING_04'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.45, 0.283, 0 ),
                    ['position'] = VECTOR3( 600.029, 131.103, 614.713 ),
                },
                ['CAM_GATE_03'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.199, 0.958, 0 ),
                    ['position'] = VECTOR3( 606.862, 146.095, 478.041 ),
                },
                ['NIS1_CAM_A_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.738, -0.342, 0 ),
                    ['position'] = VECTOR3( 1105.547, -184.54, -58.285 ),
                },
                ['NIS1_CAM_A_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0.55, 0.286, 0 ),
                    ['position'] = VECTOR3( 265.682, 218.779, 113.218 ),
                },
                ['NIS1_CAM_B_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.555, 0.004, 0 ),
                    ['position'] = VECTOR3( 524.5, 114.041, 571.5 ),
                },
                ['NIS1_CAM_B_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.555, -0.122, 0 ),
                    ['position'] = VECTOR3( 529.5, 114.671, 571.5 ),
                },
                ['NIS1_CAM_C_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.707, 0.145, 0 ),
                    ['position'] = VECTOR3( 681.999, 127.917, 396.264 ),
                },
                ['NIS1_CAM_C_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.702, 0.11, 0 ),
                    ['position'] = VECTOR3( 630.984, 128.515, 555.056 ),
                },
                ['NIS1_CAM_D_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.335, 0.236, 0 ),
                    ['position'] = VECTOR3( 373.464, 167.483, 498.997 ),
                },
                ['NIS1_CAM_D_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.398, 0.471, 0 ),
                    ['position'] = VECTOR3( 408.538, 173.377, 528.777 ),
                },
                ['NIS3_CAM_A_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.608, -0.094, 0 ),
                    ['position'] = VECTOR3( 545.064, 116.635, 551.355 ),
                },
                ['NIS3_CAM_A_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.325, -0.063, 0 ),
                    ['position'] = VECTOR3( 552.102, 126.45, 518.356 ),
                },
                ['NIS3_CAM_B_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.885, 0.283, 0 ),
                    ['position'] = VECTOR3( 802.52, 109.313, 470.643 ),
                },
                ['NIS3_CAM_B_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.854, 0.283, 0 ),
                    ['position'] = VECTOR3( 792.848, 115.819, 458.74 ),
                },
                ['NIS3_CAM_C_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.963, 0.173, 0 ),
                    ['position'] = VECTOR3( 685.707, 117.539, 480.141 ),
                },
                ['NIS3_CAM_C_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.136, 0.44, 0 ),
                    ['position'] = VECTOR3( 653.514, 142.304, 494.682 ),
                },
                ['NIS1_CAM_E_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.262, 0.063, 0 ),
                    ['position'] = VECTOR3( 535.528, 114.792, 508.086 ),
                },
                ['NIS1_CAM_F_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.388, 0.082, 0 ),
                    ['position'] = VECTOR3( 628.5, 118.33, 481.5 ),
                },
                ['NIS1_CAM_F_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.822, 0.067, 0 ),
                    ['position'] = VECTOR3( 623.5, 119.388, 480.5 ),
                },
                ['NIS2_CAM_A_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.492, 0.031, 0 ),
                    ['position'] = VECTOR3( 764.323, 123.558, 473.504 ),
                },
                ['NIS2_CAM_A_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.121, 0.047, 0 ),
                    ['position'] = VECTOR3( 755.972, 124.463, 508.14 ),
                },
                ['NIS1_CAM_G_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.681, 0.098, 0 ),
                    ['position'] = VECTOR3( 549.5, 115.814, 574.5 ),
                },
                ['NIS1_CAM_G_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.681, 0.098, 0 ),
                    ['position'] = VECTOR3( 543.5, 115.269, 574.5 ),
                },
                ['NIS1_CAM_H_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0, 0, 0 ),
                    ['position'] = VECTOR3( 533.5, 110.093, 562.5 ),
                },
                ['NIS1_CAM_H_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0, 0, 0 ),
                    ['position'] = VECTOR3( 535.5, 110.093, 562.5 ),
                },
                ['NIS1_CAM_E_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.246, 0.283, 0 ),
                    ['position'] = VECTOR3( 572.247, 143.952, 478.95 ),
                },
                ['NIS_VIC_CAM_SHOT_5_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.272, 0.873, 0 ),
                    ['position'] = VECTOR3( 567.848, 118.761, 472.162 ),
                },
                ['NIS_VIC_CAM_SHOT_5_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0.175, 1.386, 0 ),
                    ['position'] = VECTOR3( 564.062, 778.197, 355.919 ),
                },
                ['NIS_VIC_CAM_SHOT_3_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 40.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0.974, 0.192, 0 ),
                    ['position'] = VECTOR3( 240.065, 237.492, 201.22 ),
                },
                ['NIS_VIC_CAM_SHOT_3_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 40.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0.974, 0.192, 0 ),
                    ['position'] = VECTOR3( 244.359, 196.902, 204.203 ),
                },
                ['NIS_VIC_CAM_SHOT_6_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.754, 0.698, 0 ),
                    ['position'] = VECTOR3( 640.36, 174.053, 391.652 ),
                },
                ['NIS_VIC_CAM_SHOT_6_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.356, 0.698, 0 ),
                    ['position'] = VECTOR3( 668.714, 242.857, 618.315 ),
                },
                ['NIS_VIC_CAM_SHOT_6_CenterOfInterest'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 563.5, 110.034, 473.5 ),
                },
                ['Mass 01'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 551, 110, 491 ),
                },
                ['Mass 02'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 557, 110.034, 491 ),
                },
                ['ENEM01_MOVE_RAMP_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 550.5, 110.094, 576.5 ),
                },
                ['ENEM01_MOVE_RAMP_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 585.5, 109.994, 485.5 ),
                },
                ['ENEM01_MOVE_RAMPTURN_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 579.5, 110.028, 469.5 ),
                },
                ['ENEM01_MOVE_RAMPTURN_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 588.5, 116.218, 569.5 ),
                },
                ['ENEM01_MOVE_RAMPTURN_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 595.5, 109.956, 456.5 ),
                },
                ['ENEM01_MOVE_RAMP_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 604.5, 110.034, 445.5 ),
                },
                ['NIS_NukeCams_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.34, 0.597, 0 ),
                    ['position'] = VECTOR3( 797.841, 201.698, 470.409 ),
                },
                ['NUKE_DESTINATION_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 338.5, 149.562, 265.5 ),
                },
                ['NUKE_DESTINATION_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 275.5, 149.565, 248.5 ),
                },
                ['NUKE_DESTINATION_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 636.5, 104.447, 537.5 ),
                },
                ['NUKE_DESTINATION_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 665.5, 103.521, 392.5 ),
                },
                ['NUKE_DESTINATION_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 700.5, 103.122, 381.5 ),
                },
                ['NUKE_DESTINATION_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 348.5, 149.565, 235.5 ),
                },
                ['NIS_NukeCams_03'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.372, 0.738, 0 ),
                    ['position'] = VECTOR3( 829.521, 474.844, 730.95 ),
                },
                ['NIS_NukeCams_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.403, -0.063, 0 ),
                    ['position'] = VECTOR3( 479.381, 134.633, 406.976 ),
                },
                ['NIS_CAM_END'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.372, 0.271, 0 ),
                    ['position'] = VECTOR3( 651.15, 148.082, 590.312 ),
                },
                ['Effect 05'] = {
                    ['EmitterTemplate'] = STRING( 'U01Steam01' ),
                    ['EmitterScale'] = FLOAT( 1.0 ),
                    ['EmitterOffset'] = VECTOR3( 0, 0, 0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Effect' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 431.179, 134.352, 571.517 ),
                },
                ['Effect 02'] = {
                    ['EmitterTemplate'] = STRING( 'U01Steam01' ),
                    ['EmitterScale'] = FLOAT( 1.0 ),
                    ['EmitterOffset'] = VECTOR3( 0, 0, 0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Effect' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 431.85, 135.5, 562.801 ),
                },
                ['Effect 03'] = {
                    ['EmitterTemplate'] = STRING( 'U01WaterfallTop01' ),
                    ['EmitterScale'] = FLOAT( 1.0 ),
                    ['EmitterOffset'] = VECTOR3( 0, 0, 0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Effect' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, -0.998, 0, 0.055 ),
                    ['position'] = VECTOR3( 924.5, -74.52, 274.5 ),
                },
                ['Player_Trans_Path_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 587.814, 116.218, 566.542 ),
                },
                ['Player_Trans_Path_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 640.879, 102.213, 581.048 ),
                },
                ['Player_Trans_Path_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 662.188, 97.427, 601.552 ),
                },
                ['Player_Trans_Path_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 714.693, 63.334, 637.225 ),
                },
                ['Player_Trans_Path_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 759.035, 38.032, 682.653 ),
                },
                ['Mass 03'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 518, 110.034, 552 ),
                },
                ['Mass 04'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 583, 110.065, 436 ),
                },
                ['NIS_VIC_CAM_SHOT_7_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.754, 0.33, 0 ),
                    ['position'] = VECTOR3( 749.559, 134.917, 358.979 ),
                },
                ['NIS_VIC_CAM_SHOT_7_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.628, 0.236, 0 ),
                    ['position'] = VECTOR3( 750.119, 119.405, 359.667 ),
                },
                ['NIS_VIC_FleeLocation'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 748.5, 98.741, 350.5 ),
                },
            },
        },
    },
    Chains = {
        ['ALLY01_LANDING_ZONE_1'] = {
            Markers = {
                "ALLY01_LANDING_ZONE_1_2",
                "ALLY01_LANDING_ZONE_1_1",
                "ALLY01_LANDING_ZONE_1_6",
                "ALLY01_LANDING_ZONE_1_4",
                "ALLY01_LANDING_ZONE_1_7",
                "ALLY01_LANDING_ZONE_1_5",
                "ALLY01_LANDING_ZONE_1_8",
                "ALLY01_LANDING_ZONE_1_3",
            },
        },
        ['COURTYARD_ITEM_POS'] = {
            Markers = {
                "COURTYARD_ITEM_POS_3",
                "COURTYARD_ITEM_POS_6",
                "COURTYARD_ITEM_POS_1",
                "COURTYARD_ITEM_POS_2",
                "COURTYARD_ITEM_POS_5",
                "COURTYARD_ITEM_POS_4",
            },
        },
        ['ENEM01_LANDING_ZONE'] = {
            Markers = {
                "ENEM01_LANDING_ZONE_2",
                "ENEM01_LANDING_ZONE_1",
                "ENEM01_LANDING_ZONE_4",
                "ENEM01_LANDING_ZONE_3",
                "ENEM01_LANDING_ZONE_6",
                "ENEM01_LANDING_ZONE_5",
            },
        },
        ['NIS1_CAM_A'] = {
            Markers = {
                "NIS1_CAM_A_01",
                "NIS1_CAM_A_02",
            },
        },
        ['NIS1_CAM_B'] = {
            Markers = {
                "NIS1_CAM_B_01",
                "NIS1_CAM_B_02",
            },
        },
        ['NIS1_CAM_C'] = {
            Markers = {
                "NIS1_CAM_C_01",
                "NIS1_CAM_C_02",
            },
        },
        ['NIS1_CAM_D'] = {
            Markers = {
                "NIS1_CAM_D_01",
                "NIS1_CAM_D_02",
            },
        },
        ['NIS3_CAM_A'] = {
            Markers = {
                "NIS3_CAM_A_01",
                "NIS3_CAM_A_02",
            },
        },
        ['NIS3_CAM_B'] = {
            Markers = {
                "NIS3_CAM_B_01",
                "NIS3_CAM_B_02",
            },
        },
        ['NIS3_CAM_C'] = {
            Markers = {
                "NIS3_CAM_C_01",
                "NIS3_CAM_C_02",
            },
        },
        ['NIS1_CAM_E'] = {
            Markers = {
                "NIS1_CAM_E_01",
                "NIS1_CAM_E_02",
            },
        },
        ['NIS1_CAM_F'] = {
            Markers = {
                "NIS1_CAM_F_01",
                "NIS1_CAM_F_02",
            },
        },
        ['NIS2_CAM_A'] = {
            Markers = {
                "NIS2_CAM_A_01",
                "NIS2_CAM_A_02",
            },
        },
        ['NIS1_CAM_G'] = {
            Markers = {
                "NIS1_CAM_G_01",
                "NIS1_CAM_G_02",
            },
        },
        ['NIS1_CAM_H'] = {
            Markers = {
                "NIS1_CAM_H_01",
                "NIS1_CAM_H_02",
            },
        },
        ['NIS_VIC_CAM_SHOT_2'] = {
            Markers = {
            },
        },
        ['NIS_VIC_CAM_SHOT_5'] = {
            Markers = {
                "NIS_VIC_CAM_SHOT_5_01",
                "NIS_VIC_CAM_SHOT_5_02",
            },
        },
        ['NIS_VIC_CAM_SHOT_3'] = {
            Markers = {
                "NIS_VIC_CAM_SHOT_3_01",
                "NIS_VIC_CAM_SHOT_3_02",
            },
        },
        ['NIS_VIC_CAM_SHOT_6'] = {
            Markers = {
                "NIS_VIC_CAM_SHOT_6_01",
                "NIS_VIC_CAM_SHOT_6_02",
                "NIS_VIC_CAM_SHOT_6_CenterOfInterest",
            },
        },
        ['NUKE_DESTINATION'] = {
            Markers = {
                "NUKE_DESTINATION_01",
                "NUKE_DESTINATION_02",
                "NUKE_DESTINATION_03",
                "NUKE_DESTINATION_04",
                "NUKE_DESTINATION_05",
                "NUKE_DESTINATION_06",
            },
        },
        ['Player_Trans_Path'] = {
            Markers = {
                "Player_Trans_Path_01",
                "Player_Trans_Path_02",
                "Player_Trans_Path_03",
                "Player_Trans_Path_04",
                "Player_Trans_Path_05",
            },
        },
        ['NIS_NukeCams'] = {
            Markers = {
                "NIS_NukeCams_01",
                "NIS_NukeCams_02",
                "NIS_NukeCams_03",
            },
        },
        ['NIS_VIC_CAM_SHOT_7'] = {
            Markers = {
                "NIS_VIC_CAM_SHOT_7_01",
                "NIS_VIC_CAM_SHOT_7_02",
                "NIS_VIC_FleeLocation",
            },
        },
    },
    --[[                                                                           ]]--
    --[[  Armies                                                                   ]]--
    --[[                                                                           ]]--
    Armies =  
    {
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_ALLY01'] =  
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
                ['ARMY_PLAYER'] = 'ALLY',
                ['ARMY_ENEM01'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['ITEMS_APPROACH'] = GROUP {
                        Units = {
                            ['UNIT_45'] = {
                                type = 'scb0002',
                                ['Position'] = VECTOR3( 704.5, 105.433, 421.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_32'] = {
                                type = 'scb0002',
                                ['Position'] = VECTOR3( 680.5, 105.793, 428.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_47'] = {
                                type = 'scb0002',
                                ['Position'] = VECTOR3( 658.5, 106.25, 440.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_60'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 713, 105.528, 412 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_52'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 689, 105.969, 419 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_61'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 704, 105.594, 412 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_53'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 680, 105.944, 419 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_62'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 704, 106.406, 431 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_54'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 680, 106.722, 438 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_63'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 713, 106.232, 431 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_81'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 710, 106.463, 464 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_80'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 679, 106.755, 478 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_79'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 694, 106.733, 464 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_55'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 689, 106.652, 438 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_56'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 667, 106.971, 450 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_57'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 658, 107.034, 450 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_58'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 667, 106.661, 431 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_59'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 658, 106.723, 431 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_74'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 702.5, 105.985, 449.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_69'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 670.5, 106.202, 477.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_51'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 718.5, 105.627, 463.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_30'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 686.5, 106.153, 463.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_75'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 702.5, 105.966, 463.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_70'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 670.5, 105.972, 491.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_65'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 718.5, 105.471, 477.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_48'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 686.5, 106.009, 477.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_76'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 702.5, 105.989, 456.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_71'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 670.5, 106.105, 484.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_66'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 718.5, 105.575, 470.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_64'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 686.5, 106.1, 470.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_77'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 694.5, 106.075, 456.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_72'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 662.5, 106.147, 484.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_67'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 710.5, 105.767, 470.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_25'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 678.5, 106.181, 470.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_78'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 710.5, 105.813, 456.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_73'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 678.5, 106.014, 484.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_68'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 726.5, 105.116, 470.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_49'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 694.5, 106.003, 470.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['TOWERS'] = GROUP {
                        Units = {
                            ['ALLY01_WALL_TOWERS_NORTH'] = GROUP {
                                Units = {
                                    ['UNIT_675'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 642, 116.785, 437 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_676'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 642, 116.785, 451 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_680'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 642, 116.785, 440 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_679'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 633, 116.785, 451 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['ALLY01_WALL_TOWERS_SOUTH'] = GROUP {
                                Units = {
                                    ['UNIT_682'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 631, 116.785, 478 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_707'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 640, 116.785, 492 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_714'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 631, 116.785, 492 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_681'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 640, 116.785, 478 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['ALLY01_TOWERS_GATE'] = GROUP {
                                Units = {
                                    ['UNIT_03'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 645, 107.038, 457 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_33'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 645, 107.155, 472 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                        },
                    },
                    ['ITEMS_COURTYARD'] = GROUP {
                        Units = {
                            ['UNIT_433'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 516, 110.692, 566 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_419'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 493, 110.693, 593 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_431'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 529, 110.687, 522 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_447'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 517, 110.595, 536 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_423'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 568, 116.819, 373 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_422'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 597, 110.67, 423 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_415'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 570, 110.558, 533 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_12'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 564, 110.032, 533 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_11'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 517, 109.977, 542 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_13'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 493, 110.095, 587 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_15'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 546, 110.095, 605 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_16'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 546, 110.095, 598 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_96'] = {
                                type = 'scb0002',
                                ['Position'] = VECTOR3( 563.5, 110.056, 548.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_85'] = {
                                type = 'scb0002',
                                ['Position'] = VECTOR3( 570.5, 109.976, 548.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_84'] = {
                                type = 'scb0002',
                                ['Position'] = VECTOR3( 493.5, 110.094, 570.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_24'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 540, 110.095, 592 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_23'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 540, 110.095, 611 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_21'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 526, 110.095, 612 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_26'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 517.5, 110.041, 476.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_95'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 525, 110.038, 435 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_28'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 531, 110.237, 429 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_27'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 517.5, 110.049, 470.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_29'] = {
                                type = 'scb0002',
                                ['Position'] = VECTOR3( 528.5, 110.046, 449.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_43'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 610.5, 110.055, 422.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                            ['UNIT_42'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 604.5, 110.029, 422.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                            ['UNIT_88'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 555, 116.222, 361 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                            ['UNIT_87'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 542, 116.222, 361 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                            ['UNIT_94'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 542, 110.034, 450 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_93'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 522, 110.074, 450 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_36'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 576, 109.793, 423 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_37'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 589.5, 109.947, 422.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_38'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 516, 110.094, 560 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_41'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 522, 110.094, 566 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_91'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 519, 116.221, 383 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_90'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 568, 116.22, 367 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_89'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 568, 116.22, 379 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_40'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 529, 110.09, 516 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_39'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 516, 110.093, 572 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_102'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 570, 109.98, 526 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_101'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 570, 109.946, 539 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_100'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 570, 110.019, 558 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_09'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 517, 109.983, 528 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_08'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 517, 110.071, 522 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_07'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 523, 110.113, 522 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_10'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 523, 110.018, 528 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_20'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 546, 110.092, 592 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_18'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 546, 110.092, 611 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_14'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 512, 110.094, 612 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_17'] = {
                                type = 'scb0003',
                                ['Position'] = VECTOR3( 510, 110.093, 566 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_22'] = {
                                type = 'scb0001',
                                ['Position'] = VECTOR3( 493, 110.096, 599 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['ALLY01_TRANSPORT'] = {
                        type = 'uua0901',
                        ['Position'] = VECTOR3( 354.5, 149.693, 273.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['ALLY01_DEPLOYUNITS_6'] = GROUP {
                        Units = {
                            ['ALLY01_DEPLOYUNITS_5'] = GROUP {
                                Units = {
                                    ['ALLY01_DEPLOYUNITS_4'] = GROUP {
                                        Units = {
                                            ['ALLY01_DEPLOYUNITS_3'] = GROUP {
                                                Units = {
                                                    ['ALLY01_DEPLOYUNITS_2'] = GROUP {
                                                        Units = {
                                                            ['ALLY01_DEPLOYUNITS_1'] = GROUP {
                                                                Units = {
                                                                    ['UNIT_31'] = {
                                                                        type = 'uul0101',
                                                                        ['Position'] = VECTOR3( 363.509, 149.565, 268.639 ),
                                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                                    },
                                                                },
                                                            },
                                                            ['UNIT_01'] = {
                                                                type = 'uul0101',
                                                                ['Position'] = VECTOR3( 363.891, 149.565, 273.291 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                        },
                                                    },
                                                    ['UNIT_02'] = {
                                                        type = 'uul0101',
                                                        ['Position'] = VECTOR3( 363.509, 149.565, 278.544 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                },
                                            },
                                            ['UNIT_04'] = {
                                                type = 'uul0104',
                                                ['Position'] = VECTOR3( 348.5, 149.559, 270.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['UNIT_05'] = {
                                        type = 'uul0104',
                                        ['Position'] = VECTOR3( 348.5, 149.559, 274.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['UNIT_06'] = {
                                type = 'uul0104',
                                ['Position'] = VECTOR3( 348.5, 149.559, 278.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['ALLY01_COMM_ARRAY'] = {
                        type = 'scb1101',
                        ['Position'] = VECTOR3( 308, 149.738, 240 ),
                        ['Orientation'] = VECTOR3( 0, 2.545, 0 ),
                    },
                    ['CYARD_UNIT_ZONE_4'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 538.5, 110.093, 601.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['CYARD_UNIT_ZONE_3'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 501.5, 110.094, 570.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['CYARD_UNIT_ZONE_5'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 548.5, 116.222, 363.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['CYARD_UNIT_ZONE_6'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 535.5, 110.031, 449.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['CYARD_UNIT_ZONE_1'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 582.5, 109.947, 425.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['CYARD_UNIT_ZONE_2'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 619.5, 110.029, 427.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['APPROACH_UNIT_ZONE_6'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 712.5, 105.358, 421.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['APPROACH_UNIT_ZONE_5'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 688.5, 105.754, 428.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['APPROACH_UNIT_ZONE_4'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 666.5, 106.194, 440.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['APPROACH_UNIT_ZONE_2'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 702.5, 105.882, 474.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['APPROACH_UNIT_ZONE_3'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 726.5, 104.955, 481.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['APPROACH_UNIT_ZONE_1'] = {
                        type = 'scb0002',
                        ['Position'] = VECTOR3( 662.5, 105.946, 494.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['NIS_NUKED_UNITS_AREA_01'] = GROUP {
                        Units = {
                            ['UNIT_19'] = {
                                type = 'uub0002',
                                ['Position'] = VECTOR3( 612, 112.983, 539 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_34'] = {
                                type = 'uub0002',
                                ['Position'] = VECTOR3( 626, 114.124, 521 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_35'] = {
                                type = 'uub0002',
                                ['Position'] = VECTOR3( 612, 111.362, 558 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_86'] = {
                                type = 'uub0701',
                                ['Position'] = VECTOR3( 623, 103.573, 548 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_97'] = {
                                type = 'uub0701',
                                ['Position'] = VECTOR3( 639, 105.63, 515 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_98'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 623, 103.069, 554 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_99'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 623, 104.197, 541 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_103'] = {
                                type = 'uub0011',
                                ['Position'] = VECTOR3( 642, 103.541, 550 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['NIS_NUKED_UNITS_AREA_02'] = GROUP {
                        Units = {
                            ['UNIT_104'] = {
                                type = 'uub0011',
                                ['Position'] = VECTOR3( 677, 120.366, 379 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                },
            },
        },
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_ENEM01'] =  
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
                ['ARMY_ALLY01'] = 'ENEMY',
                ['ARMY_PLAYER'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['ENEM01_ESCORT'] = GROUP {
                        Units = {
                            ['UNIT_360'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 790.5, 104.082, 439.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_378'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 793.5, 104.082, 446.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_367'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 791.5, 104.082, 460.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_366'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 793.5, 104.082, 455.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_361'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 801.5, 104.082, 442.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_363'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 795.5, 104.082, 449.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_368'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 807.5, 104.082, 458.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_358'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 795.5, 104.082, 443.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_374'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 789.5, 104.082, 451.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_379'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 793.5, 104.082, 443.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_371'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 793.5, 104.082, 458.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_362'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 808.5, 104.082, 446.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_373'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 786.5, 104.088, 453.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_370'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 795.5, 104.082, 458.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_376'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 793.5, 104.082, 452.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_375'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 793.5, 104.082, 449.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_380'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 793.5, 104.082, 440.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_377'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 795.5, 104.082, 440.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_359'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 795.5, 104.082, 446.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_364'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 795.5, 104.082, 455.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_369'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 807.5, 104.082, 454.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                            ['UNIT_372'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 795.5, 104.082, 452.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.625, 0 ),
                            },
                            ['UNIT_365'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 809.5, 104.082, 439.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.84, 0 ),
                            },
                        },
                    },
                    ['ENEM01_EXPERIMENTAL_02'] = {
                        type = 'ucx0101',
                        ['Position'] = VECTOR3( 801, 104.052, 457 ),
                        ['Orientation'] = VECTOR3( 0, 4.664, 0 ),
                    },
                    ['ENEM01_EXPERIMENTAL_01'] = {
                        type = 'ucx0101',
                        ['Position'] = VECTOR3( 801.5, 104.046, 449.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.664, 0 ),
                    },
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['ENEM01_TRANSPORT_06'] = {
                        type = 'uca0901',
                        ['Position'] = VECTOR3( 676.5, 101.614, 361.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.817, 0 ),
                    },
                    ['ENEM01_TRANSPORT_05'] = {
                        type = 'uca0901',
                        ['Position'] = VECTOR3( 683.5, 102.584, 372.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.817, 0 ),
                    },
                    ['ENEM01_TRANSPORT_04'] = {
                        type = 'uca0901',
                        ['Position'] = VECTOR3( 693.5, 105.079, 413.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.817, 0 ),
                    },
                    ['ENEM01_TRANSPORT_03'] = {
                        type = 'uca0901',
                        ['Position'] = VECTOR3( 685.5, 104.463, 402.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.817, 0 ),
                    },
                    ['ENEM01_TRANSPORT_02'] = {
                        type = 'uca0901',
                        ['Position'] = VECTOR3( 687.5, 103.286, 383.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.817, 0 ),
                    },
                    ['ENEM01_TRANSPORT_01'] = {
                        type = 'uca0901',
                        ['Position'] = VECTOR3( 697.5, 103.82, 390.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.817, 0 ),
                    },
                    ['ENEM01_BOT'] = {
                        type = 'ucl0103',
                        ['Position'] = VECTOR3( 686.5, 103.881, 394.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.756, 0 ),
                    },
                    ['NIS_FLEE'] = GROUP {
                        Units = {
                            ['UNIT_703'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 709.5, 103.924, 392.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_693'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 732.5, 104.256, 409.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_673'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 726.5, 104.032, 397.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_704'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 711.5, 104.259, 397.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_694'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 734.5, 104.375, 414.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_674'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 728.5, 104.131, 402.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_705'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 706.5, 104.519, 404.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_695'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 729.5, 104.836, 421.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_677'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 723.5, 104.596, 409.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_706'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 699.5, 103.958, 394.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_696'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 722.5, 104.772, 411.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_678'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 716.5, 104.405, 399.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_708'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 707.5, 103.839, 391.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_697'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 730.5, 104.297, 408.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_683'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 724.5, 104.062, 396.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_684'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 718.5, 105.15, 417.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_709'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 704.5, 104.244, 398.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_698'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 727.5, 104.737, 415.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_685'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 721.5, 104.437, 403.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_710'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 701.5, 103.536, 387.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_699'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 724.5, 104.375, 404.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_686'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 718.5, 103.994, 392.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_711'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 703.5, 103.802, 391.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_700'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 726.5, 104.467, 408.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_687'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 720.5, 104.153, 396.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_688'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 708.5, 104.792, 410.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_712'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 709.5, 104.299, 398.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_701'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 732.5, 104.516, 415.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_689'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 726.5, 104.239, 403.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_713'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 706.5, 103.704, 389.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_702'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 729.5, 104.25, 406.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_690'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 723.5, 103.975, 394.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_691'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 699.5, 104.69, 407.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                            ['UNIT_692'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 709.5, 104.051, 394.5 ),
                                ['Orientation'] = VECTOR3( 0, 0.55, 0 ),
                            },
                        },
                    },
                    ['ENEM01_SECONDWAVE'] = GROUP {
                        Units = {
                            ['ENEM01_SECONDWAVE_01'] = GROUP {
                                Units = {
                                    ['UNIT_623'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 678.5, 105.257, 520.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.152, 0 ),
                                    },
                                    ['UNIT_624'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 676.5, 105.228, 521.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.152, 0 ),
                                    },
                                    ['UNIT_626'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 673.5, 105.282, 520.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.152, 0 ),
                                    },
                                    ['UNIT_667'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 677.5, 105.341, 518.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.152, 0 ),
                                    },
                                    ['UNIT_630'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 675.5, 105.312, 519.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.152, 0 ),
                                    },
                                    ['UNIT_671'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 674.5, 105.199, 522.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.152, 0 ),
                                    },
                                },
                            },
                            ['ENEM01_SECONDWAVE_02'] = GROUP {
                                Units = {
                                    ['UNIT_625'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 694.989, 105.582, 512.04 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                    ['UNIT_627'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 693.438, 105.559, 514.403 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                    ['UNIT_628'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 691.477, 105.485, 514.807 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                    ['UNIT_668'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 696.951, 105.591, 511.633 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                    ['UNIT_629'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 693.032, 105.562, 512.442 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                    ['UNIT_669'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 691.07, 105.489, 512.853 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                    ['UNIT_670'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 695.395, 105.572, 513.999 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                    ['UNIT_672'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 697.355, 105.583, 513.594 ),
                                        ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                                    },
                                },
                            },
                            ['ENEM01_SECONDWAVE_03'] = GROUP {
                                Units = {
                                    ['UNIT_631'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 724.5, 104.56, 515.5 ),
                                        ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                                    },
                                    ['UNIT_632'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 721.5, 104.667, 515.5 ),
                                        ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                                    },
                                    ['UNIT_633'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 719.5, 104.833, 512.5 ),
                                        ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                                    },
                                    ['UNIT_715'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 724.5, 104.625, 512.5 ),
                                        ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                                    },
                                    ['UNIT_634'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 721.5, 104.729, 512.5 ),
                                        ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                                    },
                                    ['UNIT_716'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 719.5, 104.771, 515.5 ),
                                        ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                                    },
                                },
                            },
                            ['ENEM01_SECONDWAVE_06'] = GROUP {
                                Units = {
                                    ['UNIT_717'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 730.5, 103.705, 393.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.451, 0 ),
                                    },
                                    ['UNIT_718'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 732.5, 103.647, 393.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.451, 0 ),
                                    },
                                    ['UNIT_719'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 733.5, 103.791, 396.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.451, 0 ),
                                    },
                                    ['UNIT_720'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 729.5, 103.849, 395.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.451, 0 ),
                                    },
                                    ['UNIT_721'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 731.5, 103.791, 395.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.451, 0 ),
                                    },
                                    ['UNIT_722'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 734.5, 103.646, 394.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.451, 0 ),
                                    },
                                },
                            },
                            ['ENEM01_SECONDWAVE_05'] = GROUP {
                                Units = {
                                    ['UNIT_655'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 711.534, 103.068, 379.363 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                    ['UNIT_657'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 714.603, 103.14, 378.6 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                    ['UNIT_659'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 715.983, 103.259, 378.906 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                    ['UNIT_660'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 709.618, 102.952, 378.208 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                    ['UNIT_661'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 713.449, 103.185, 380.515 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                    ['UNIT_662'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 715.364, 103.305, 381.667 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                    ['UNIT_664'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 712.685, 103.021, 377.446 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                    ['UNIT_666'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 710.769, 102.903, 376.292 ),
                                        ['Orientation'] = VECTOR3( 0, 2.812, 0 ),
                                    },
                                },
                            },
                            ['ENEM01_SECONDWAVE_04'] = GROUP {
                                Units = {
                                    ['UNIT_653'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 697.5, 102.962, 379.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0.079, 0 ),
                                    },
                                    ['UNIT_654'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 699.5, 103.036, 379.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0.079, 0 ),
                                    },
                                    ['UNIT_656'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 700.5, 103.228, 382.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0.079, 0 ),
                                    },
                                    ['UNIT_658'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 696.5, 103.084, 381.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0.079, 0 ),
                                    },
                                    ['UNIT_663'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 698.5, 103.155, 381.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0.079, 0 ),
                                    },
                                    ['UNIT_665'] = {
                                        type = 'ucl0103',
                                        ['Position'] = VECTOR3( 701.5, 103.11, 380.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0.079, 0 ),
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_CIVL01'] =  
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
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                },
            },
        },
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_PLAYER'] =  
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
                ['ARMY_ALLY01'] = 'ALLY',
                ['ARMY_ENEM01'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['PLAYER_PLANES'] = GROUP {
                        Units = {
                            ['UNIT_740'] = {
                                type = 'uua0101',
                                ['Position'] = VECTOR3( 632.5, 116.117, 414.5 ),
                                ['Orientation'] = VECTOR3( 0, 5.908, 0 ),
                            },
                            ['UNIT_739'] = {
                                type = 'uua0101',
                                ['Position'] = VECTOR3( 636.5, 116.117, 413.5 ),
                                ['Orientation'] = VECTOR3( 0, 5.908, 0 ),
                            },
                            ['UNIT_738'] = {
                                type = 'uua0101',
                                ['Position'] = VECTOR3( 634.5, 116.117, 408.5 ),
                                ['Orientation'] = VECTOR3( 0, 5.908, 0 ),
                            },
                            ['UNIT_742'] = {
                                type = 'uua0101',
                                ['Position'] = VECTOR3( 630.5, 116.117, 410.5 ),
                                ['Orientation'] = VECTOR3( 0, 5.908, 0 ),
                            },
                            ['UNIT_743'] = {
                                type = 'uua0101',
                                ['Position'] = VECTOR3( 639.5, 116.117, 409.5 ),
                                ['Orientation'] = VECTOR3( 0, 5.908, 0 ),
                            },
                        },
                    },
                    ['PLAYER_CDR'] = {
                        type = 'uul0001',
                        ['Position'] = VECTOR3( 588.5, 116.182, 579.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.772, 0 ),
                    },
                    ['PLAYER_TANKS'] = GROUP {
                        Units = {
                            ['PLAYER_TANKS_01'] = GROUP {
                                Units = {
                                    ['UNIT_345'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 527.5, 110.092, 584.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_346'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 531.5, 110.092, 580.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_348'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 533.5, 110.092, 584.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_356'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 527.5, 110.092, 590.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_355'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 531.5, 110.092, 586.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_347'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 533.5, 110.092, 590.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_734'] = {
                                        type = 'uul0104',
                                        ['Position'] = VECTOR3( 524.5, 110.088, 586.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_735'] = {
                                        type = 'uul0104',
                                        ['Position'] = VECTOR3( 537.5, 110.088, 587.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['ENGINEER_06'] = {
                                        type = 'uul0002',
                                        ['Position'] = VECTOR3( 537.5, 110.092, 580.5 ),
                                        ['Orientation'] = VECTOR3( 0, 2.941, 0 ),
                                    },
                                    ['ENGINEER_05'] = {
                                        type = 'uul0002',
                                        ['Position'] = VECTOR3( 526.5, 110.093, 578.5 ),
                                        ['Orientation'] = VECTOR3( 0, 2.941, 0 ),
                                    },
                                },
                            },
                            ['PLAYER_TANKS_02'] = GROUP {
                                Units = {
                                    ['UNIT_349'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 543.5, 110.034, 514.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                    ['UNIT_350'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 547.5, 110.034, 511.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                    ['UNIT_351'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 543.5, 110.034, 507.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                    ['UNIT_357'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 539.5, 110.034, 510.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                    ['UNIT_381'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 539.5, 110.034, 517.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                    ['UNIT_352'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 547.5, 110.034, 518.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                    ['UNIT_736'] = {
                                        type = 'uul0104',
                                        ['Position'] = VECTOR3( 535.5, 110.047, 514.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                    ['UNIT_737'] = {
                                        type = 'uul0104',
                                        ['Position'] = VECTOR3( 551.5, 110.031, 515.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                                    },
                                },
                            },
                        },
                    },
                    ['PLAYER_ENGINEERS_01'] = GROUP {
                        Units = {
                            ['ENGINEER_02'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 590.5, 116.314, 516.5 ),
                                ['Orientation'] = VECTOR3( 0, 2.391, 0 ),
                            },
                            ['ENGINEER_01'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 592.5, 116.314, 520.5 ),
                                ['Orientation'] = VECTOR3( 0, 2.391, 0 ),
                            },
                        },
                    },
                    ['FACTORY_01'] = {
                        type = 'uub0001',
                        ['Position'] = VECTOR3( 561, 111.034, 501 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['PLAYER_ENGINEERS_02'] = GROUP {
                        Units = {
                            ['ENGINEER_04'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 531.5, 110.034, 547.5 ),
                                ['Orientation'] = VECTOR3( 0, 2.941, 0 ),
                            },
                            ['ENGINEER_03'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 534.5, 110.033, 548.5 ),
                                ['Orientation'] = VECTOR3( 0, 2.941, 0 ),
                            },
                        },
                    },
                    ['FACTORY_02'] = {
                        type = 'uub0001',
                        ['Position'] = VECTOR3( 547, 111.033, 481 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['MASS_01'] = {
                        type = 'uub0701',
                        ['Position'] = VECTOR3( 557, 110.594, 491 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['MASS_02'] = {
                        type = 'uub0701',
                        ['Position'] = VECTOR3( 551, 110.594, 491 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['POWER_01'] = {
                        type = 'uub0702',
                        ['Position'] = VECTOR3( 529, 110.689, 500 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['POWER_02'] = {
                        type = 'uub0702',
                        ['Position'] = VECTOR3( 529, 110.675, 494 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['PLAYER_TRANS'] = {
                        type = 'uua0901',
                        ['Position'] = VECTOR3( 577.031, 136.844, 566.131 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                },
            },
        },
    },
}
