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
        ['MOVE_TRIGGER_04'] = {
            ['rectangle'] = RECTANGLE( 352.759, 626.142, 372.759, 646.142 ),
        },
        ['MOVE_TRIGGER_03'] = {
            ['rectangle'] = RECTANGLE( 364.956, 654.177, 412.86, 684.534 ),
        },
        ['MOVE_TRIGGER_02'] = {
            ['rectangle'] = RECTANGLE( 406.177, 690.399, 439.171, 708.361 ),
        },
        ['MOVE_TRIGGER_01'] = {
            ['rectangle'] = RECTANGLE( 392.294, 712.008, 469.501, 736.176 ),
        },
        ['MOVE_AREA'] = {
            ['rectangle'] = RECTANGLE( 298.903, 602.028, 511.343, 916.486 ),
        },
        ['COMBAT_AREA'] = {
            ['rectangle'] = RECTANGLE( 162.325, 510.368, 500.285, 799.472 ),
        },
        ['CAM_AREA'] = {
            ['rectangle'] = RECTANGLE( 354.592, 644.896, 510.528, 920.072 ),
        },
        ['BATTLE_AREA'] = {
            ['rectangle'] = RECTANGLE( 189.97, 530.499, 401.143, 686.793 ),
        },
        ['PLAYABLE_AREA'] = {
            ['rectangle'] = RECTANGLE( -8.769, 77.609, 510.255, 919.337 ),
        },
        ['FACTORY_AREA'] = {
            ['rectangle'] = RECTANGLE( 99.59, 494.376, 291.358, 594.48 ),
        },
        ['FINAL_COMBAT_AREA'] = {
            ['rectangle'] = RECTANGLE( 89.302, 372.081, 365.74, 619.21 ),
        },
        ['PD_AREA'] = {
            ['rectangle'] = RECTANGLE( 136.746, 455.278, 203.73, 486.81 ),
        },
        ['COMBAT_MOVE'] = {
            ['rectangle'] = RECTANGLE( 222.755, 595.836, 258.468, 634.756 ),
        },
        ['RANGE_AREA'] = {
            ['rectangle'] = RECTANGLE( 331.465, 618.657, 333.865, 654.515 ),
        },
        ['RESTRICTED'] = {
            ['rectangle'] = RECTANGLE( 407.43, 746.959, 458.64, 797.991 ),
        },
    },
    --[[                                                                           ]]--
    --[[  Markers                                                                  ]]--
    --[[                                                                           ]]--
    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                ['NIS_SELECTION_Cam_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 3.142, 0.342, 0 ),
                    ['position'] = VECTOR3( 316.047, 54.744, 607.467 ),
                },
                ['NIS_COMMANDS_Attack_Cam_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 3.142, 0.342, 0 ),
                    ['position'] = VECTOR3( 239.139, 36.926, 572.793 ),
                },
                ['TUT01_Combat_TransportDestination_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 241.817, 37.164, 642.666 ),
                },
                ['TUT01_Combat_TransportDestination_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 425.042, 51.331, 720.205 ),
                },
                ['TUT01_Combat2_Camera_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.278, 0.251, 0 ),
                    ['position'] = VECTOR3( 339.374, 63.724, 675.021 ),
                },
                ['TUT01_Combat_TransportReturn01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 170.372, 34, 769.09 ),
                },
                ['TUT01_Combat_TransportReturn'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 502.328, 34, 653.023 ),
                },
                ['gpnav Playable Island 01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'gpnav Playable Island' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511.5, 28.094, 530.5 ),
                },
                ['gpnav Playable Island 02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'gpnav Playable Island' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 864.5, 36.133, 772.5 ),
                },
                ['gpnav Playable Island 03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'gpnav Playable Island' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 155.5, 36.133, 761.5 ),
                },
                ['gpnav Playable Island 04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'gpnav Playable Island' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 155.5, 36.133, 265.5 ),
                },
                ['gpnav Playable Island 05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'gpnav Playable Island' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 860.5, 36.133, 271.5 ),
                },
                ['gpnav Playable Island 06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'gpnav Playable Island' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 154.5, 36.114, 506.5 ),
                },
                ['CAM_OPENING'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -3.142, 0.628, 0 ),
                    ['position'] = VECTOR3( 265.255, 108.391, 627.267 ),
                },
                ['PLAYER_START'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 432.867, 57.242, 771.438 ),
                },
                ['Ambient_Chain_01_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 728.261, 34, 848.705 ),
                },
                ['Ambient_Chain_01_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 608.821, 57.247, 859.429 ),
                },
                ['Ambient_Chain_01_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 471.484, 57.247, 694.316 ),
                },
                ['Ambient_Chain_01_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 337.382, 41.186, 520.396 ),
                },
                ['Ambient_Chain_01_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 49.424, 34, 573.614 ),
                },
                ['Ambient_Chain_01_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 200.268, 34, 813.44 ),
                },
                ['Ambient_Chain_01_07'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 362.446, 57.246, 831.809 ),
                },
                ['Ambient_Chain_01_08'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 597.325, 57.247, 879.827 ),
                },
                ['Ambient_Chain_01_09'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 821.512, 34, 792.312 ),
                },
                ['Ambient_Chain_02_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 482.646, 34, 441.539 ),
                },
                ['Ambient_Chain_02_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 85.332, 34, 296.622 ),
                },
                ['Ambient_Chain_02_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 61.283, 34, 551.81 ),
                },
                ['Ambient_Chain_02_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 476.729, 34, 558.298 ),
                },
                ['Ambient_Chain_03_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 706.62, 41.165, 638.109 ),
                },
                ['Ambient_Chain_03_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 423.756, 51.331, 695.935 ),
                },
                ['Ambient_Chain_03_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 181.998, 34, 666.674 ),
                },
                ['Ambient_Chain_03_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 187.106, 34, 355.395 ),
                },
                ['Ambient_Chain_03_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 58.288, 34, 281.957 ),
                },
                ['Ambient_Chain_03_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 51.064, 34, 729.812 ),
                },
                ['Ambient_Chain_03_07'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 101.629, 34, 900.768 ),
                },
                ['Ambient_Chain_03_08'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 643.389, 41.14, 392.717 ),
                },
                ['Ambient_Chain_03_09'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 996.136, 34, 814.086 ),
                },
                ['Ambient_Chain_03_10'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 858.89, 34, 918.827 ),
                },
                ['Ambient_Chain_03_11'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 158.212, 39.721, 472.175 ),
                },
                ['Ambient_Chain_03_12'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 809.218, 36.149, 585.494 ),
                },
                ['COMBAT_MARKER01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 243.053, 36.88, 615.002 ),
                },
                ['COMBAT_MARKER'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 267.221, 40.931, 633.929 ),
                },
                ['MOVE_MARKER'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 345.035, 41.165, 631.921 ),
                },
                ['Move_Markers_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 428.202, 51.331, 725.103 ),
                },
                ['Move_Markers_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 408.135, 51.331, 691.738 ),
                },
                ['Move_Markers_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 380.836, 46.863, 659.538 ),
                },
                ['COMBAT_CAM_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.602, 0.255, 0 ),
                    ['position'] = VECTOR3( 445.227, 71.971, 636.324 ),
                },
                ['PAN_OBJ_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 432.764, 57.247, 816.985 ),
                },
                ['PAN_OBJ_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 475.993, 51.33, 770.902 ),
                },
                ['PAN_OBJ_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 431.406, 51.33, 727.139 ),
                },
                ['PAN_OBJ_12'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 397.312, 52.747, 820.848 ),
                },
                ['PAN_OBJ_11'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 471.53, 53.518, 821.692 ),
                },
                ['PAN_OBJ_10'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 471.207, 54.111, 729.567 ),
                },
                ['PAN_OBJ_09'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 392.132, 51.331, 724.254 ),
                },
                ['PAN_OBJ_08'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 390.571, 53.045, 806.482 ),
                },
                ['PAN_OBJ_07'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 477.525, 53.198, 807.672 ),
                },
                ['PAN_OBJ_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 478.244, 51.33, 740.382 ),
                },
                ['PAN_OBJ_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 387.844, 51.33, 738.93 ),
                },
                ['PAN_OBJ_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 403.147, 51.331, 770.528 ),
                },
                ['ROTATE_OBJ_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 432.475, 51.326, 740.511 ),
                },
                ['ROTATE_OBJ_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 468.499, 51.332, 770.558 ),
                },
                ['ROTATE_OBJ_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 395, 51.331, 770.539 ),
                },
                ['TILT_OBJ_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 432.979, 57.247, 789.952 ),
                },
                ['TILT_OBJ_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 432.882, 79.912, 780.541 ),
                },
                ['ZOOM_OBJ_12'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 451.047, 81.089, 762.602 ),
                },
                ['ZOOM_OBJ_11'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 451.013, 80.857, 776.435 ),
                },
                ['ZOOM_OBJ_10'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 453.425, 80.659, 770.475 ),
                },
                ['ZOOM_OBJ_09'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 424.896, 79.81, 750.47 ),
                },
                ['ZOOM_OBJ_08'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 432.246, 80.669, 750.315 ),
                },
                ['ZOOM_OBJ_07'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 439.401, 79.819, 750.599 ),
                },
                ['ZOOM_OBJ_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 412.594, 81.093, 761.155 ),
                },
                ['ZOOM_OBJ_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 412.767, 82.544, 778.116 ),
                },
                ['ZOOM_OBJ_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 412.729, 81.246, 770.274 ),
                },
                ['ZOOM_OBJ_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 431.608, 80.403, 793.424 ),
                },
                ['ZOOM_OBJ_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 423.62, 81.513, 793.758 ),
                },
                ['ZOOM_OBJ_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 440.623, 80.98, 793.788 ),
                },
                ['BATTLE_MARKER'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 167.827, 36.276, 502.767 ),
                },
                ['NIS_ATTACK_CAM_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.744, 0.192, 0 ),
                    ['position'] = VECTOR3( 379.614, 51.603, 644.471 ),
                },
                ['NIS_OPENING_CAM_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0.738, 0.444, 0 ),
                    ['position'] = VECTOR3( 55.764, 157.607, 283.702 ),
                },
                ['NIS_OPENING_CAM_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0.487, 0.471, 0 ),
                    ['position'] = VECTOR3( 372.045, 87.942, 656.836 ),
                },
                ['Mass_01'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 212, 36.125, 528 ),
                },
                ['Mass_02'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 129, 36.107, 521 ),
                },
                ['Mass_03'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 195, 36.115, 520 ),
                },
                ['ENGINEER_DESTINATION_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 188.444, 36.22, 524.534 ),
                },
                ['ENGINEER_DESTINATION_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 194.759, 36.155, 511.912 ),
                },
                ['PART2_WARP'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 196.496, 36.228, 535.661 ),
                },
                ['CDR_INITIAL_LOCATION'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 171.38, 36.89, 528.779 ),
                },
                ['TUT02_Combat1_Mobiles_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 168.455, 41.154, 456.826 ),
                },
                ['TUT02_Combat1_Mobiles_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 164.266, 39.641, 477.08 ),
                },
                ['TUT02_Combat1_Mobiles_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 161.209, 37.242, 492.487 ),
                },
                ['Mass 05'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 152, 41.129, 425 ),
                },
                ['Mass 06'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 147, 41.13, 449 ),
                },
                ['NIS_ENDCOMBAT_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.388, 0.145, 0 ),
                    ['position'] = VECTOR3( 179.167, 51.426, 459.577 ),
                },
                ['NIS_ENDCOMBAT'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -3.016, 0.33, 0 ),
                    ['position'] = VECTOR3( 178.697, 69.687, 557.541 ),
                },
                ['Base_Marker'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 158.654, 41.166, 437.284 ),
                },
                ['SoundEmitter_Skyhigh'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_MP_203/snd_SC2_MP_203_Skyhigh' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 512.5, 200, 512.5 ),
                },
                ['SoundEmitter_Innerlake'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_MP_203/snd_SC2_MP_203_InnerLake' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 513.5, 34, 502.5 ),
                },
                ['SoundEmitter_Shore_01'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_MP_203/snd_SC2_MP_203_Ocean_Shore' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( -19.5, 34, 526.5 ),
                },
                ['SoundEmitter_Shore_02'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_MP_203/snd_SC2_MP_203_Ocean_Shore' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 1028.5, 34, 520.5 ),
                },
                ['SoundEmitter_OpenOcean_01'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_MP_203/snd_SC2_MP_203_Generic_Ocean' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( -100.5, 34, -129.5 ),
                },
                ['SoundEmitter_OpenOcean_02'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_MP_203/snd_SC2_MP_203_Generic_Ocean' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 1019.5, 34, 1119.5 ),
                },
            },
        },
    },
    Chains = {
        ['TUT01_Combat_Markers'] = {
            Markers = {
                "TUT01_Combat_TransportDestination_02",
                "TUT01_Combat_TransportDestination_01",
                "TUT01_Combat2_Camera_01",
                "TUT01_Combat_TransportReturn",
                "TUT01_Combat_TransportReturn01",
            },
        },
        ['Ambient_Chain_02'] = {
            Markers = {
            },
        },
        ['Ambient_Chain_01'] = {
            Markers = {
                "Ambient_Chain_01_01",
                "Ambient_Chain_01_02",
                "Ambient_Chain_01_03",
                "Ambient_Chain_01_04",
                "Ambient_Chain_01_05",
                "Ambient_Chain_01_06",
                "Ambient_Chain_01_07",
                "Ambient_Chain_01_08",
                "Ambient_Chain_01_09",
            },
        },
        ['Ambient_Chain_02'] = {
            Markers = {
                "Ambient_Chain_02_01",
                "Ambient_Chain_02_02",
                "Ambient_Chain_02_03",
                "Ambient_Chain_02_04",
            },
        },
        ['Move_Markers'] = {
            Markers = {
                "Move_Markers_01",
                "Move_Markers_02",
                "Move_Markers_03",
            },
        },
        ['PAN_OBJ'] = {
            Markers = {
                "PAN_OBJ_01",
                "PAN_OBJ_02",
                "PAN_OBJ_03",
                "PAN_OBJ_04",
                "PAN_OBJ_05",
                "PAN_OBJ_06",
                "PAN_OBJ_07",
                "PAN_OBJ_08",
                "PAN_OBJ_12",
                "PAN_OBJ_11",
                "PAN_OBJ_10",
                "PAN_OBJ_09",
            },
        },
        ['ROTATE_OBJ'] = {
            Markers = {
                "ROTATE_OBJ_01",
                "ROTATE_OBJ_02",
                "ROTATE_OBJ_03",
            },
        },
        ['TILT_OBJ'] = {
            Markers = {
                "TILT_OBJ_01",
                "TILT_OBJ_02",
            },
        },
        ['NIS_OPENING_CAM'] = {
            Markers = {
                "NIS_OPENING_CAM_01",
                "NIS_OPENING_CAM_02",
            },
        },
        ['TUT02_Combat1_Mobiles'] = {
            Markers = {
                "TUT02_Combat1_Mobiles_01",
                "TUT02_Combat1_Mobiles_02",
                "TUT02_Combat1_Mobiles_03",
            },
        },
        ['ZOOM_OBJ'] = {
            Markers = {
                "ZOOM_OBJ_01",
                "ZOOM_OBJ_10",
                "ZOOM_OBJ_07",
                "ZOOM_OBJ_04",
                "ZOOM_OBJ_02",
                "ZOOM_OBJ_11",
                "ZOOM_OBJ_08",
                "ZOOM_OBJ_05",
                "ZOOM_OBJ_03",
                "ZOOM_OBJ_12",
                "ZOOM_OBJ_09",
                "ZOOM_OBJ_06",
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
                ['ARMY_ENEM01'] = 'NEUTRAL',
                ['ARMY_PLAYER'] = 'ALLY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['TUT_01'] = GROUP {
                        Units = {
                            ['Ambient_Fighters'] = GROUP {
                                Units = {
                                    ['UNIT_25'] = {
                                        type = 'uua0101',
                                        ['Position'] = VECTOR3( 752.725, 34.008, 813.278 ),
                                        ['Orientation'] = VECTOR3( 0, 4.744, 0 ),
                                    },
                                    ['UNIT_26'] = {
                                        type = 'uua0101',
                                        ['Position'] = VECTOR3( 758.466, 34.008, 823.241 ),
                                        ['Orientation'] = VECTOR3( 0, 4.744, 0 ),
                                    },
                                    ['UNIT_27'] = {
                                        type = 'uua0101',
                                        ['Position'] = VECTOR3( 764.567, 34.008, 833.437 ),
                                        ['Orientation'] = VECTOR3( 0, 4.744, 0 ),
                                    },
                                },
                            },
                            ['Ambient_Gunships'] = GROUP {
                                Units = {
                                    ['UNIT_35'] = {
                                        type = 'uua0103',
                                        ['Position'] = VECTOR3( 538.278, 34.004, 494.819 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_36'] = {
                                        type = 'uua0103',
                                        ['Position'] = VECTOR3( 547.47, 34.004, 494.335 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_37'] = {
                                        type = 'uua0103',
                                        ['Position'] = VECTOR3( 555.212, 34.004, 494.819 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_38'] = {
                                        type = 'uua0103',
                                        ['Position'] = VECTOR3( 543.116, 34.004, 502.56 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_39'] = {
                                        type = 'uua0103',
                                        ['Position'] = VECTOR3( 552.309, 34.004, 503.044 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_40'] = {
                                        type = 'uua0103',
                                        ['Position'] = VECTOR3( 548.438, 34.004, 513.205 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                        },
                    },
                    ['TUT_02'] = GROUP {
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
                ['ARMY_ALLY'] = 'ALLY',
                ['ARMY_ENEM01'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['PLAYER_CDR'] = {
                        type = 'uul0001',
                        ['Position'] = VECTOR3( 432.998, 57.209, 772.399 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['TUT_01'] = GROUP {
                        Units = {
                            ['Transports'] = GROUP {
                                Units = {
                                    ['P2_Selection_Transport02'] = {
                                        type = 'uua0901',
                                        ['Position'] = VECTOR3( 263.894, 36.15, 718.46 ),
                                        ['Orientation'] = VECTOR3( 0, 3.393, 0 ),
                                    },
                                    ['P2_Selection_Transport01'] = {
                                        type = 'uua0901',
                                        ['Position'] = VECTOR3( 355.448, 41.174, 631.125 ),
                                        ['Orientation'] = VECTOR3( 0, 0.644, 0 ),
                                    },
                                },
                            },
                            ['Units'] = GROUP {
                                Units = {
                                    ['TUT01_Combat_Group02'] = GROUP {
                                        Units = {
                                            ['UNIT_50'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 262.464, 36.143, 720.917 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_07'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 261.998, 36.142, 718.092 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_51'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 265.464, 36.142, 720.917 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_08'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 264.998, 36.142, 718.092 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_52'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 268.464, 36.141, 720.917 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_09'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 267.998, 36.141, 718.092 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_53'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 271.464, 36.142, 720.917 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_10'] = {
                                                type = 'uul0103',
                                                ['Position'] = VECTOR3( 270.998, 36.141, 718.092 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_20'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 261.799, 36.142, 720.084 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_21'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 261.799, 36.142, 724.084 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_22'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 264.799, 36.141, 720.084 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_23'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 264.799, 36.142, 724.084 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['TUT01_Combat_Group01'] = GROUP {
                                        Units = {
                                            ['UNIT_01'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 355.451, 41.165, 630.098 ),
                                                ['Orientation'] = VECTOR3( 0, 3.519, 0 ),
                                            },
                                            ['UNIT_41'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 352.381, 41.165, 629.204 ),
                                                ['Orientation'] = VECTOR3( 0, 3.519, 0 ),
                                            },
                                            ['UNIT_24'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 351.737, 41.165, 633.391 ),
                                                ['Orientation'] = VECTOR3( 0, 3.519, 0 ),
                                            },
                                            ['UNIT_02'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 355.451, 41.165, 634.098 ),
                                                ['Orientation'] = VECTOR3( 0, 3.519, 0 ),
                                            },
                                            ['UNIT_11'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 358.451, 41.165, 630.098 ),
                                                ['Orientation'] = VECTOR3( 0, 3.519, 0 ),
                                            },
                                            ['UNIT_12'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 358.451, 41.165, 634.098 ),
                                                ['Orientation'] = VECTOR3( 0, 3.519, 0 ),
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                    ['PLAYER_ENGINEERS'] = GROUP {
                        Units = {
                            ['PLAYER_ENGINEERS01'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 209.69, 36.144, 499.079 ),
                                ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
                            },
                            ['PLAYER_ENGINEERS02'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 206.839, 36.147, 516.063 ),
                                ['Orientation'] = VECTOR3( 0, 4.885, 0 ),
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
                ['ARMY_ALLY'] = 'NEUTRAL',
                ['ARMY_PLAYER'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['TUT_01'] = GROUP {
                        Units = {
                            ['Commands_Units'] = GROUP {
                                Units = {
                                    ['Attack_Structures'] = GROUP {
                                        Units = {
                                            ['TUT01_Commands_Attack_Structure02'] = {
                                                type = 'uub0702',
                                                ['Position'] = VECTOR3( 321.507, 41.764, 623.537 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['TUT01_Commands_Attack_Structure01'] = {
                                                type = 'uub0702',
                                                ['Position'] = VECTOR3( 318.089, 41.764, 648.864 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['TUT01_Commands_Attack_Structure'] = {
                                                type = 'uub0702',
                                                ['Position'] = VECTOR3( 314.011, 41.765, 635.302 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                },
                            },
                            ['Combat_Units'] = GROUP {
                                Units = {
                                    ['TUT01_Combat_Mobiles'] = GROUP {
                                        Units = {
                                            ['UNIT_59'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 229.489, 36.15, 585.97 ),
                                                ['Orientation'] = VECTOR3( 0, 0.518, 0 ),
                                            },
                                            ['UNIT_45'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 220.324, 36.149, 593.367 ),
                                                ['Orientation'] = VECTOR3( 0, 1.524, 0 ),
                                            },
                                            ['UNIT_98'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 234.62, 36.149, 586.949 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_60'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 227.278, 36.149, 589.584 ),
                                                ['Orientation'] = VECTOR3( 0, 0.518, 0 ),
                                            },
                                            ['UNIT_46'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 221.978, 36.149, 598.377 ),
                                                ['Orientation'] = VECTOR3( 0, 1.524, 0 ),
                                            },
                                            ['UNIT_14'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 237.53, 36.149, 588.654 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_61'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 222.611, 36.149, 589.221 ),
                                                ['Orientation'] = VECTOR3( 0, 0.518, 0 ),
                                            },
                                            ['UNIT_47'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 220.267, 36.149, 603.163 ),
                                                ['Orientation'] = VECTOR3( 0, 1.524, 0 ),
                                            },
                                            ['UNIT_15'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 240.62, 36.149, 589.462 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_48'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 214.239, 36.149, 610.251 ),
                                                ['Orientation'] = VECTOR3( 0, 1.524, 0 ),
                                            },
                                            ['UNIT_16'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 243.62, 36.157, 588.564 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_49'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 218.156, 36.149, 607.899 ),
                                                ['Orientation'] = VECTOR3( 0, 1.524, 0 ),
                                            },
                                            ['UNIT_17'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 246.62, 36.18, 586.949 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['TUT01_Combat_Structures'] = GROUP {
                                        Units = {
                                        },
                                    },
                                    ['Non_Obj_Structures'] = GROUP {
                                        Units = {
                                        },
                                    },
                                },
                            },
                        },
                    },
                    ['TUT_02'] = GROUP {
                        Units = {
                            ['Combat1_Units'] = GROUP {
                                Units = {
                                    ['TUT02_Combat1_Mobiles'] = GROUP {
                                        Units = {
                                            ['UNIT_13'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 751.5, 40.561, 411.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_58'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 168.502, 41.165, 437.86 ),
                                                ['Orientation'] = VECTOR3( 0, 0.848, 0 ),
                                            },
                                            ['UNIT_57'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 158.855, 41.165, 437.452 ),
                                                ['Orientation'] = VECTOR3( 0, 0.848, 0 ),
                                            },
                                            ['UNIT_56'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 162.24, 41.021, 460.314 ),
                                                ['Orientation'] = VECTOR3( 0, 0.848, 0 ),
                                            },
                                            ['UNIT_55'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 175.919, 41.165, 446.951 ),
                                                ['Orientation'] = VECTOR3( 0, 0.848, 0 ),
                                            },
                                            ['UNIT_54'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 166.272, 41.166, 446.543 ),
                                                ['Orientation'] = VECTOR3( 0, 0.848, 0 ),
                                            },
                                            ['UNIT_46'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 153.064, 41.165, 445.775 ),
                                                ['Orientation'] = VECTOR3( 0, 0.848, 0 ),
                                            },
                                        },
                                    },
                                    ['TUT02_Combat1_Structures'] = GROUP {
                                        Units = {
                                            ['UNIT_18'] = {
                                                type = 'uub0702',
                                                ['Position'] = VECTOR3( 731, 36.796, 348 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_30'] = {
                                                type = 'uub0101',
                                                ['Position'] = VECTOR3( 148.089, 41.331, 432.228 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_33'] = {
                                                type = 'uub0101',
                                                ['Position'] = VECTOR3( 149.858, 41.331, 429.51 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_32'] = {
                                                type = 'uub0101',
                                                ['Position'] = VECTOR3( 148.406, 41.323, 453.673 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_31'] = {
                                                type = 'uub0101',
                                                ['Position'] = VECTOR3( 184.085, 41.331, 442.161 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_28'] = {
                                                type = 'uub0701',
                                                ['Position'] = VECTOR3( 147, 41.724, 449 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_29'] = {
                                                type = 'uub0701',
                                                ['Position'] = VECTOR3( 152, 41.723, 425 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['EndCombatObjectives'] = GROUP {
                                        Units = {
                                            ['UNIT_05'] = {
                                                type = 'uub0001',
                                                ['Position'] = VECTOR3( 138.837, 41.165, 436.414 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_06'] = {
                                                type = 'uub0001',
                                                ['Position'] = VECTOR3( 156.342, 41.079, 413.063 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
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
        ['ARMY_CAPTURE'] =  
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
                ['ARMY_ENEM01'] = 'NEUTRAL',
                ['ARMY_PLAYER'] = 'NEUTRAL',
            },
            ['Units'] = GROUP {
                Units = {
                    ['TUT_01'] = GROUP {
                        Units = {
                            ['CAPTURE_UNIT'] = GROUP {
                                Units = {
                                    ['CAPTURE_UNIT'] = {
                                        type = 'scb2301',
                                        ['Position'] = VECTOR3( 304.669, 41.166, 635.188 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}
