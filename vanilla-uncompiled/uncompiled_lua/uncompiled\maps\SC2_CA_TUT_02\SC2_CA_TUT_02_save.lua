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
        ['TRANSITION_AREA'] = {
            ['rectangle'] = RECTANGLE( 569.217, 363.695, 971.783, 665.305 ),
        },
        ['FACTORY_AREA'] = {
            ['rectangle'] = RECTANGLE( 664.678, 479.699, 761.55, 544.927 ),
        },
        ['BATTLE_AREA'] = {
            ['rectangle'] = RECTANGLE( 468.98, 92.352, 985.522, 947.276 ),
        },
        ['PLAYABLE_AREA'] = {
            ['rectangle'] = RECTANGLE( 509.988, 90.636, 1029.012, 932.364 ),
        },
        ['NORTH_TRIGGER'] = {
            ['rectangle'] = RECTANGLE( 682.391, 365.934, 764.669, 435.366 ),
        },
    },
    --[[                                                                           ]]--
    --[[  Markers                                                                  ]]--
    --[[                                                                           ]]--
    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                ['Mass 02'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 777, 36.125, 541 ),
                },
                ['Mass 01'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 781, 36.124, 505 ),
                },
                ['ENEMY_BASE_SOUTH'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 686.592, 41.166, 628.069 ),
                },
                ['gpnav Playable Island 01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'gpnav Playable Island' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511.5, 34, 530.5 ),
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
                ['Mass 03'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 724, 41.1, 650 ),
                },
                ['Mass 04'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 684, 41.102, 613 ),
                },
                ['ZOOM_OBJ'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 734.536, 102.842, 519.454 ),
                },
                ['Mass 05'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 714, 36.124, 495 ),
                },
                ['Mass 06'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 714, 36.125, 533 ),
                },
                ['Mass 07'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 745, 36.124, 511 ),
                },
                ['Tank_Dest'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 756.174, 36.12, 532.901 ),
                },
                ['Attack_Tank_Dest'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 747.361, 36.142, 513.512 ),
                },
                ['Research_Tank_Dest'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 734.5, 36.143, 520.5 ),
                },
                ['South_Attack_Chain_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 741.679, 41.112, 620.763 ),
                },
                ['South_Attack_Chain_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 753.539, 40.05, 608.486 ),
                },
                ['South_Attack_Chain_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 758.036, 37.228, 593.996 ),
                },
                ['South_Attack_Chain_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 745.122, 36.149, 569.19 ),
                },
                ['ENEMY_BASE_NORTH'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 695.651, 41.165, 390.65 ),
                },
                ['Mass 08'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 694, 41.096, 403 ),
                },
                ['Mass 09'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 730, 41.097, 378 ),
                },
                ['North_Attack'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 743.15, 40.68, 413.761 ),
                },
                ['NIS_CAMERA_OPENING_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.602, 0.204, 0 ),
                    ['position'] = VECTOR3( 213.193, 58.934, 510.304 ),
                },
                ['NIS_CAMERA_OPENING_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.592, 0.471, 0 ),
                    ['position'] = VECTOR3( 611.171, 157.103, 677.889 ),
                },
                ['NIS_SOUTH_REVEAL_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.602, 0.393, 0 ),
                    ['position'] = VECTOR3( 746.682, 57.578, 633.213 ),
                },
                ['NIS_SOUTH_REVEAL_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.131, 0.298, 0 ),
                    ['position'] = VECTOR3( 737.622, 50.407, 628.324 ),
                },
                ['NIS_BASE_REVEAL_04'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.78, 0.361, 0 ),
                    ['position'] = VECTOR3( 723.452, 45.604, 589.93 ),
                },
                ['NIS_BASE_REVEAL_03'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.293, 0.157, 0 ),
                    ['position'] = VECTOR3( 724.732, 38.878, 583.719 ),
                },
                ['NIS_BASE_REVEAL_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.733, 0.188, 0 ),
                    ['position'] = VECTOR3( 766.753, 44.337, 562.821 ),
                },
                ['NIS_BASE_REVEAL_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.278, 0.016, 0 ),
                    ['position'] = VECTOR3( 766.854, 41.332, 561.044 ),
                },
                ['NIS_NORTH_REVEAL_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.445, 0.503, 0 ),
                    ['position'] = VECTOR3( 770.089, 83.124, 380.855 ),
                },
                ['NIS_NORTH_REVEAL_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.571, 0.833, 0 ),
                    ['position'] = VECTOR3( 699.544, 94.792, 403.559 ),
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
        ['Ambient_Chain_02'] = {
            Markers = {
            },
        },
        ['South_Attack_Chain'] = {
            Markers = {
                "South_Attack_Chain_01",
                "South_Attack_Chain_02",
                "South_Attack_Chain_03",
                "South_Attack_Chain_04",
            },
        },
        ['markerChain01'] = {
            Markers = {
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
                            ['UNIT_27'] = {
                                type = 'uub0001',
                                ['Position'] = VECTOR3( 700, 37.052, 511 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_28'] = {
                                type = 'uub0701',
                                ['Position'] = VECTOR3( 714, 36.143, 495 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_31'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 721, 36.132, 495 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['PLAYER_CDR'] = {
                        type = 'uul0001',
                        ['Position'] = VECTOR3( 721.5, 36.103, 510.5 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['PLAYER_ENGINEERS'] = GROUP {
                        Units = {
                            ['PLAYER_ENGINEERS01'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 712.754, 36.128, 507.351 ),
                                ['Orientation'] = VECTOR3( 0, 0.471, 0 ),
                            },
                            ['PLAYER_ENGINEERS02'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 712.685, 36.141, 516.788 ),
                                ['Orientation'] = VECTOR3( 0, 0.565, 0 ),
                            },
                        },
                    },
                    ['RESEARCH_TANKS'] = GROUP {
                        Units = {
                            ['UNIT_32'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 739.5, 36.118, 533.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.707, 0 ),
                            },
                            ['UNIT_34'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 747.5, 36.119, 533.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.707, 0 ),
                            },
                            ['UNIT_35'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 742.5, 36.112, 538.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.707, 0 ),
                            },
                            ['UNIT_36'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 745.5, 36.111, 538.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.707, 0 ),
                            },
                        },
                    },
                    ['Camera_Tank'] = {
                        type = 'uul0101',
                        ['Position'] = VECTOR3( 743.5, 36.119, 533.5 ),
                        ['Orientation'] = VECTOR3( 0, 3.707, 0 ),
                    },
                    ['REAL_BASE'] = GROUP {
                        Units = {
                            ['ARMY'] = GROUP {
                                Units = {
                                    ['UNIT_130'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 745.823, 36.149, 569.338 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_106'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 700.735, 36.141, 566.475 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_18'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 705.368, 36.187, 464.331 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_131'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 749.682, 36.15, 567.125 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_107'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 704.594, 36.195, 564.262 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_19'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 709.227, 36.175, 462.118 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_132'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 754.216, 36.146, 565.164 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_108'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 709.128, 36.176, 562.301 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_62'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 713.761, 36.162, 460.157 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_133'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 759.156, 36.147, 565.046 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_109'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 714.068, 36.161, 562.183 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_63'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 718.701, 36.15, 460.039 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_134'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 764.753, 36.149, 565.745 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_110'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 719.665, 36.147, 562.882 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_64'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 724.298, 36.147, 460.738 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_135'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 770.012, 36.149, 567.998 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_111'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 724.924, 36.148, 565.135 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_65'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 729.557, 36.145, 462.991 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_136'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 771.929, 36.149, 571.398 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_112'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 726.841, 36.148, 568.535 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_66'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 731.474, 36.142, 466.391 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_137'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 767.468, 36.148, 571.766 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_113'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 722.38, 36.149, 568.903 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_67'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 727.013, 36.143, 466.759 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_138'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 761.646, 36.149, 569.286 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_114'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 716.558, 36.156, 566.423 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_68'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 721.191, 36.144, 464.279 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_139'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 756.764, 36.149, 569.397 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_115'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 711.676, 36.17, 566.534 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_69'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 716.309, 36.154, 464.39 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_140'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 751.996, 36.149, 570.537 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_116'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 706.908, 36.188, 567.674 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_70'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 711.541, 36.166, 465.53 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_141'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 749.733, 36.149, 572.987 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_117'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 704.645, 36.199, 570.124 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_71'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 709.278, 36.156, 467.98 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_142'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 755.71, 36.148, 574.918 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_118'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 710.622, 36.173, 572.055 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_72'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 715.255, 36.151, 469.911 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_143'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 760.799, 36.149, 573.574 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_119'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 715.712, 36.161, 570.711 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_73'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 720.345, 36.143, 468.567 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_144'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 764.403, 36.149, 575.432 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_120'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 719.315, 36.154, 572.569 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_74'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 723.948, 36.142, 470.425 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_145'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 760.225, 36.166, 578.493 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_121'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 715.137, 36.163, 575.63 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_75'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 719.77, 36.142, 473.486 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_76'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 782.466, 36.147, 458.69 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_77'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 785.802, 36.146, 461.859 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_78'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 788.168, 36.142, 465.931 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_79'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 790.718, 36.143, 470.867 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_80'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 791.443, 36.136, 476.068 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_81'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 785.382, 36.143, 470.939 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_82'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 783.077, 36.142, 466.51 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_83'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 777.848, 36.146, 461.355 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_84'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 785.015, 36.148, 454.071 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_85'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 789.75, 36.146, 460.202 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_86'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 793.551, 36.142, 464.861 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_87'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 795.532, 36.142, 470.539 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_88'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 795.148, 36.121, 481.88 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_89'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 798.294, 36.127, 479.722 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_90'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 801.239, 36.135, 476.837 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_91'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 773.154, 36.15, 457.106 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_92'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 777.127, 36.15, 453.028 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_93'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 781.452, 36.15, 450.213 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_94'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 790.653, 36.149, 452.385 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_95'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 796.547, 36.15, 457.06 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_96'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 800.204, 36.145, 462.311 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_97'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 801.851, 36.142, 468.321 ),
                                        ['Orientation'] = VECTOR3( 0, 3.079, 0 ),
                                    },
                                    ['UNIT_146'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 741.73, 36.149, 567.911 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_122'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 696.642, 35.914, 565.048 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_98'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 701.275, 36.173, 462.904 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_147'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 746.128, 36.148, 563.615 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_123'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 701.04, 36.16, 560.752 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_99'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 705.673, 36.192, 458.608 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_148'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 750.372, 36.145, 560.521 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_124'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 705.284, 36.183, 557.658 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_100'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 709.917, 36.176, 455.514 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_149'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 755.656, 36.143, 559.044 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_125'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 710.568, 36.16, 556.181 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_101'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 715.201, 36.162, 454.037 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_150'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 760.909, 36.143, 559.199 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_126'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 715.821, 36.153, 556.336 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_102'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 720.454, 36.15, 454.192 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_151'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 766.43, 36.143, 560.46 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_127'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 721.342, 36.144, 557.597 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_103'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 725.975, 36.149, 455.453 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_152'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 772.562, 36.146, 562.808 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_128'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 727.474, 36.145, 559.945 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_104'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 732.107, 36.148, 457.801 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_153'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 775.681, 36.15, 566.612 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_129'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 730.593, 36.146, 563.749 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_105'] = {
                                        type = 'uul0103',
                                        ['Position'] = VECTOR3( 735.226, 36.146, 461.605 ),
                                        ['Orientation'] = VECTOR3( 0, 2.717, 0 ),
                                    },
                                    ['UNIT_154'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 744.444, 36.142, 558.491 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_155'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 753.292, 36.141, 555.716 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_156'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 759.783, 36.141, 555.096 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_157'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 773.223, 36.141, 557.977 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_158'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 700.408, 36.103, 555.875 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_159'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 709.062, 36.151, 551.637 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_160'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 717.375, 36.146, 552.313 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_161'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 722.319, 36.142, 554.436 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_162'] = {
                                        type = 'uul0102',
                                        ['Position'] = VECTOR3( 728.286, 36.143, 556.179 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['STRUCTURES'] = GROUP {
                                Units = {
                                    ['PLAYER_FACTORIES'] = GROUP {
                                        Units = {
                                            ['UNIT_24'] = {
                                                type = 'uub0001',
                                                ['Position'] = VECTOR3( 753.223, 37.143, 468.583 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_41'] = {
                                                type = 'uub0001',
                                                ['Position'] = VECTOR3( 773.056, 37.12, 488.472 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_42'] = {
                                                type = 'uub0001',
                                                ['Position'] = VECTOR3( 788, 37.142, 517 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_43'] = {
                                                type = 'uub0001',
                                                ['Position'] = VECTOR3( 788, 37.123, 543 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['UNIT_29'] = {
                                        type = 'uub0701',
                                        ['Position'] = VECTOR3( 781.09, 36.141, 504.955 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_30'] = {
                                        type = 'uub0701',
                                        ['Position'] = VECTOR3( 777.039, 36.118, 540.872 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_38'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 772.939, 36.123, 542.844 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_39'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 776.989, 36.141, 507.035 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_54'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 712.014, 36.142, 490.832 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_55'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 723.195, 36.124, 490.832 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_56'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 747.208, 36.146, 460.305 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_57'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 759.198, 36.147, 460.143 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_58'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 764.821, 36.113, 482.341 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_59'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 779.793, 36.141, 511.118 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_60'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 694.24, 35.736, 502.563 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_61'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 694.045, 35.732, 519.285 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
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
                    ['TUT_02'] = GROUP {
                        Units = {
                            ['Combat1_Units'] = GROUP {
                                Units = {
                                    ['TUT02_Combat1_Mobiles'] = GROUP {
                                        Units = {
                                            ['UNIT_13'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 752.682, 36.143, 502.263 ),
                                                ['Orientation'] = VECTOR3( 0, 5.686, 0 ),
                                            },
                                            ['UNIT_14'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 755.682, 36.143, 502.263 ),
                                                ['Orientation'] = VECTOR3( 0, 5.686, 0 ),
                                            },
                                            ['UNIT_15'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 758.682, 36.143, 502.263 ),
                                                ['Orientation'] = VECTOR3( 0, 5.686, 0 ),
                                            },
                                            ['UNIT_16'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 761.682, 36.142, 502.263 ),
                                                ['Orientation'] = VECTOR3( 0, 5.686, 0 ),
                                            },
                                            ['UNIT_17'] = {
                                                type = 'uul0101',
                                                ['Position'] = VECTOR3( 764.682, 36.143, 502.263 ),
                                                ['Orientation'] = VECTOR3( 0, 5.686, 0 ),
                                            },
                                        },
                                    },
                                },
                            },
                            ['Combat2_Units'] = GROUP {
                                Units = {
                                },
                            },
                        },
                    },
                    ['CAPTURE_UNIT'] = GROUP {
                        Units = {
                            ['CAPTURE_UNIT'] = {
                                type = 'scb2301',
                                ['Position'] = VECTOR3( 730.17, 36.141, 505.322 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['ENEM_OBJ'] = GROUP {
                        Units = {
                            ['UNIT_44'] = {
                                type = 'uub0801',
                                ['Position'] = VECTOR3( 638.828, 41.165, 606.63 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_45'] = {
                                type = 'uub0801',
                                ['Position'] = VECTOR3( 634.559, 41.166, 408.114 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['ENEMY_BASE_SOUTH'] = GROUP {
                        Units = {
                            ['BASE_MOBILES'] = GROUP {
                                Units = {
                                    ['UNIT_175'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 741.282, 41.178, 645.636 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_170'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 715.116, 41.164, 625.754 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_176'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 744.282, 41.165, 645.636 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_171'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 719.361, 41.166, 627.835 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_177'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 747.282, 41.14, 645.636 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_172'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 730.187, 41.167, 631.906 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_178'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 750.282, 41.092, 645.636 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_173'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 723.835, 41.169, 628.893 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_179'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 753.282, 41.054, 645.636 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                    ['UNIT_174'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 726.649, 41.169, 630.145 ),
                                        ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                                    },
                                },
                            },
                            ['FACTORIES_SOUTH'] = GROUP {
                                Units = {
                                    ['FACTORY_SOUTH_01'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 634, 41.164, 621 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['FACTORY_SOUTH_02'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 658, 41.165, 611 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['FACTORY_SOUTH_03'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 679, 41.165, 666 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['FACTORY_SOUTH_04'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 700, 41.165, 650 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['BASE_UNITS_SOUTH'] = GROUP {
                                Units = {
                                    ['UNIT_05'] = {
                                        type = 'uub0301',
                                        ['Position'] = VECTOR3( 688, 41.165, 645 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_06'] = {
                                        type = 'uub0301',
                                        ['Position'] = VECTOR3( 646, 41.165, 616 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_07'] = {
                                        type = 'uub0701',
                                        ['Position'] = VECTOR3( 684, 41.726, 613 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_08'] = {
                                        type = 'uub0701',
                                        ['Position'] = VECTOR3( 724, 41.725, 650 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_09'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 677, 41.165, 608 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_10'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 670, 41.165, 608 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_11'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 716, 41.165, 641 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_12'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 716, 41.764, 648 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_21'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 684.717, 41.33, 643.925 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_22'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 722, 41.332, 644 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_23'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 664, 41.165, 620 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_47'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 650.403, 41.306, 631.121 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_46'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 669.204, 41.306, 645.703 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_25'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 673, 41.165, 657 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_26'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 643, 41.14, 627 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                        },
                    },
                    ['ENEMY_BASE_NORTH'] = GROUP {
                        Units = {
                            ['FACTORIES_NORTH'] = GROUP {
                                Units = {
                                    ['FACTORY_NORTH_01'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 671.359, 42.165, 352.069 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['FACTORY_NORTH_02'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 629.373, 42.166, 393.136 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['FACTORY_NORTH_03'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 651.265, 42.166, 410.328 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['FACTORY_NORTH_04'] = {
                                        type = 'uub0001',
                                        ['Position'] = VECTOR3( 700.187, 42.165, 365.566 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['BASE_UNITS_NORTH'] = GROUP {
                                Units = {
                                    ['UNIT_48'] = {
                                        type = 'uub0301',
                                        ['Position'] = VECTOR3( 690.229, 41.327, 359.471 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_49'] = {
                                        type = 'uub0301',
                                        ['Position'] = VECTOR3( 660.593, 41.327, 407.203 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_50'] = {
                                        type = 'uub0701',
                                        ['Position'] = VECTOR3( 730, 41.69, 378 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_180'] = {
                                        type = 'uub0701',
                                        ['Position'] = VECTOR3( 694, 41.691, 403 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_181'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 722.996, 41.764, 373.057 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_182'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 715.996, 41.764, 373.057 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_183'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 686.52, 41.763, 393.482 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_184'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 686.52, 41.764, 400.482 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_186'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 734.959, 41.332, 378.84 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_187'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 692.52, 41.331, 396.482 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_188'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 717.446, 41.331, 377.769 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_189'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 653.052, 41.309, 391.742 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_190'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 668.408, 41.311, 379.88 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_191'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 699.915, 41.331, 403.082 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_192'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 709.202, 41.331, 364.521 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['BASE_MOBILES_NORTH'] = GROUP {
                                Units = {
                                    ['UNIT_01'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 691.061, 41.165, 381.241 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_02'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 694.692, 41.165, 381.899 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_03'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 699.178, 41.165, 384.517 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_04'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 702.416, 41.165, 381.957 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_185'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 706.677, 41.165, 384.547 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_193'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 705.219, 41.165, 389.153 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_194'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 699.642, 41.165, 389.815 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_195'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 694.776, 41.165, 387.271 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_196'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 680.575, 41.165, 382.265 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_197'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 681.701, 41.165, 378.788 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_198'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 685.567, 41.165, 384.345 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_199'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 684.91, 41.165, 375.987 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_200'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 687.98, 41.165, 381.594 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_201'] = {
                                        type = 'uul0101',
                                        ['Position'] = VECTOR3( 688.235, 41.165, 374.988 ),
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
