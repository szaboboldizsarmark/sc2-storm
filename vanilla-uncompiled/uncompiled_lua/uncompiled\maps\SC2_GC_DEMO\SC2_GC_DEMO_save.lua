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
            ['rectangle'] = RECTANGLE( 198.439, 199.727, 826.561, 827.274 ),
        },
        ['ENEM_03'] = {
            ['rectangle'] = RECTANGLE( 158.28, 433.703, 326.72, 587.297 ),
        },
        ['ENEM_02'] = {
            ['rectangle'] = RECTANGLE( 426.28, 182.703, 594.72, 336.297 ),
        },
        ['ENEM_01'] = {
            ['rectangle'] = RECTANGLE( 687.28, 435.703, 855.721, 589.297 ),
        },
        ['AREA_02'] = {
            ['rectangle'] = RECTANGLE( 450.658, 641.984, 574.342, 709.016 ),
        },
    },
    --[[                                                                           ]]--
    --[[  Markers                                                                  ]]--
    --[[                                                                           ]]--
    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                ['Mass 09'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511.5, 177.403, 796.5 ),
                },
                ['Mass 12'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 524.5, 177.403, 754.5 ),
                },
                ['Mass 13'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 494.5, 177.403, 754.5 ),
                },
                ['SoundEmitter_Borehole_01'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Boreholes' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 377.5, -97.713, 329.5 ),
                },
                ['SoundEmitter_Borehole_02'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Boreholes' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 674.5, -1.057, 360.5 ),
                },
                ['SoundEmitter_Borehole_03'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Boreholes' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 296.5, -195.465, 616.5 ),
                },
                ['SoundEmitter_Borehole_04'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Boreholes' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 725.5, -251.56, 633.5 ),
                },
                ['SoundEmitter_Skyhigh'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Skyhigh' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 512.5, 200, 506.5 ),
                },
                ['SoundEmitter_Factory_01'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Factories' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 55.5, 182.147, 968.5 ),
                },
                ['SoundEmitter_Factory_02'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Factories' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 51.5, 181.878, 45.5 ),
                },
                ['SoundEmitter_Factory_03'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Factories' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 969.5, 182.349, 58.5 ),
                },
                ['SoundEmitter_Factory_04'] = {
                    ['EventName'] = STRING( 'SC2/SC2/Environments/SC2_CA_I04/snd_SC2_CA_I04_Factories' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 956.5, 182.498, 955.5 ),
                },
                ['NIS_CAM_04'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 3.126, 0.581, 0 ),
                    ['position'] = VECTOR3( 513.413, 213.612, 817.874 ),
                },
                ['NIS_CAM_03'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.309, 0.581, 0 ),
                    ['position'] = VECTOR3( 297.27, 213.612, 720.282 ),
                },
                ['NIS_CAM_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 3.142, 0.836, 0 ),
                    ['position'] = VECTOR3( 512.534, 221.287, 816.668 ),
                },
                ['NIS_CAM_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.639, 0.852, 0 ),
                    ['position'] = VECTOR3( 354.061, 472.162, 848.924 ),
                },
                ['ENEM01_INTEL'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 766.5, 177.437, 514.5 ),
                },
                ['ENEM02_INTEL'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511.5, 177.437, 259.5 ),
                },
                ['ENEM03_INTEL'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 256.5, 177.437, 510.5 ),
                },
                ['FANS_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 540.5, -813.568, 656.5 ),
                },
                ['FANS_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 600.5, -801.85, 637.5 ),
                },
                ['FANS_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 637.5, -792.293, 589.5 ),
                },
                ['FANS_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 655.5, -785.011, 534.5 ),
                },
                ['FANS_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 636.5, -775.321, 442.5 ),
                },
                ['NIS_CAM_OPENING'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.325, 0.915, 0 ),
                    ['position'] = VECTOR3( 757.525, 571.174, 746.377 ),
                },
                ['CENTER'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511.5, 177.436, 514.5 ),
                },
                ['FACTORY_ROLLOFF_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511.5, 177.437, 682.5 ),
                },
                ['FACTORY_ROLLOFF_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511.5, 177.437, 647.5 ),
                },
                ['MAIN_BASE'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 512.5, 177.437, 764.5 ),
                },
                ['NIS_CAM_FAN_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.183, 1.229, 0 ),
                    ['position'] = VECTOR3( 615.889, -165.937, 570.127 ),
                },
                ['NIS_CAM_FAN_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.183, -0.656, 0 ),
                    ['position'] = VECTOR3( 620.934, -798.039, 683.932 ),
                },
                ['NIS_CAM_FAN_03'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.545, 1.292, 0 ),
                    ['position'] = VECTOR3( 679.546, 704.826, 671.234 ),
                },
                ['NIS_CAM_FAN_04'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.435, -0.577, 0 ),
                    ['position'] = VECTOR3( 543.702, -551.922, 704.035 ),
                },
                ['NIS_CAM_SKY_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.78, 1.496, 0 ),
                    ['position'] = VECTOR3( 520.49, 674.504, 679.712 ),
                },
                ['FACTORY_ROLLOFF_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 253.5, 177.662, 530.5 ),
                },
            },
        },
    },
    Chains = {
        ['FANS'] = {
            Markers = {
                "FANS_01",
                "FANS_02",
                "FANS_03",
                "FANS_04",
                "FANS_05",
            },
        },
        ['FACTORY_ROLLOFF'] = {
            Markers = {
                "FACTORY_ROLLOFF_01",
                "FACTORY_ROLLOFF_02",
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
                ['ARMY_PLAYER'] = 'ENEMY',
                ['ARMY_ENEM02'] = 'ALLY',
                ['ARMY_ENEM03'] = 'ALLY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['ENEM01_BASE'] = GROUP {
                        Units = {
                            ['UNIT_21'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 715, 177.43, 527 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_22'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 715, 177.43, 537 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_23'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 715, 177.43, 497 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_24'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 715, 177.43, 487 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_120'] = {
                                type = 'ucb0701',
                                ['Position'] = VECTOR3( 788, 177.43, 512 ),
                                ['Orientation'] = VECTOR3( 0, 4.728, 0 ),
                            },
                            ['UNIT_121'] = {
                                type = 'ucb0701',
                                ['Position'] = VECTOR3( 759, 177.444, 484 ),
                                ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                            },
                            ['UNIT_124'] = {
                                type = 'ucb0801',
                                ['Position'] = VECTOR3( 749, 177.43, 493 ),
                                ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                            },
                            ['UNIT_125'] = {
                                type = 'ucb0801',
                                ['Position'] = VECTOR3( 779, 177.43, 514 ),
                                ['Orientation'] = VECTOR3( 0, 4.728, 0 ),
                            },
                            ['UNIT_147'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 761, 177.937, 536 ),
                                ['Orientation'] = VECTOR3( 0, 1.555, 0 ),
                            },
                            ['UNIT_148'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 749, 177.936, 536 ),
                                ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                            },
                            ['UNIT_149'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 784, 177.937, 486 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_150'] = {
                                type = 'ucb0102',
                                ['Position'] = VECTOR3( 772, 177.938, 486 ),
                                ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                            },
                            ['UNIT_151'] = {
                                type = 'ucb0101',
                                ['Position'] = VECTOR3( 745, 177.437, 500 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_153'] = {
                                type = 'ucb0101',
                                ['Position'] = VECTOR3( 757, 177.437, 497 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_155'] = {
                                type = 'ucb0101',
                                ['Position'] = VECTOR3( 772, 177.437, 510 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                            ['UNIT_156'] = {
                                type = 'ucb0101',
                                ['Position'] = VECTOR3( 772, 177.437, 518 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                            ['UNIT_157'] = {
                                type = 'ucb0101',
                                ['Position'] = VECTOR3( 782, 177.437, 507 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                            ['UNIT_193'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 720, 178.102, 532 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_192'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 720, 178.102, 492 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_162'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 729, 178.102, 480 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_159'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 729, 178.102, 545 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_163'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 740, 178.102, 474 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_160'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 740, 178.102, 552 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_195'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 788, 178.102, 505 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_194'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 759, 178.102, 491 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_164'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 750, 178.102, 468 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_161'] = {
                                type = 'uub0702',
                                ['Position'] = VECTOR3( 752, 178.102, 559 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_122'] = {
                                type = 'ucx0101',
                                ['Position'] = VECTOR3( 734, 177.405, 504 ),
                                ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                            },
                            ['UNIT_123'] = {
                                type = 'ucx0101',
                                ['Position'] = VECTOR3( 748, 177.406, 511 ),
                                ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                            },
                            ['UNIT_145'] = {
                                type = 'ucx0101',
                                ['Position'] = VECTOR3( 735, 177.437, 522 ),
                                ['Orientation'] = VECTOR3( 0, 4.697, 0 ),
                            },
                        },
                    },
                    ['EXP_BRAIN'] = {
                        type = 'ucx0115',
                        ['Position'] = VECTOR3( 780, 178.624, 545 ),
                        ['Orientation'] = VECTOR3( 0, 4.744, 0 ),
                    },
                    ['ENEM01_ARTY'] = GROUP {
                        Units = {
                            ['ENEM01_ARTY05'] = {
                                type = 'ucb0105',
                                ['Position'] = VECTOR3( 778, 177.755, 491 ),
                                ['Orientation'] = VECTOR3( 0, 4.744, 0 ),
                            },
                            ['ENEM01_ARTY04'] = {
                                type = 'ucb0105',
                                ['Position'] = VECTOR3( 755, 177.755, 531 ),
                                ['Orientation'] = VECTOR3( 0, 4.744, 0 ),
                            },
                            ['ENEM01_ARTY01'] = {
                                type = 'ucb0105',
                                ['Position'] = VECTOR3( 755, 177.755, 540 ),
                                ['Orientation'] = VECTOR3( 0, 4.744, 0 ),
                            },
                            ['ENEM01_ARTY02'] = {
                                type = 'ucb0105',
                                ['Position'] = VECTOR3( 778, 177.755, 482 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
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
            faction = 2,
            Economy = {
                mass = 0,
                energy = 0,
            },
            Alliances = {
                ['ARMY_ENEM01'] = 'ENEMY',
                ['ARMY_ENEM02'] = 'ENEMY',
                ['ARMY_ENEM03'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                            ['PLAYER_BASE'] = GROUP {
                                Units = {
                                    ['UNIT_10'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 498, 177.43, 714 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_11'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 484, 177.43, 714 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_12'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 527, 177.43, 714 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_13'] = {
                                        type = 'uub0101',
                                        ['Position'] = VECTOR3( 540, 177.43, 714 ),
                                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                                    },
                                    ['UNIT_14'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 478, 177.444, 728 ),
                                        ['Orientation'] = VECTOR3( 0, 4.76, 0 ),
                                    },
                                    ['UNIT_15'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 478, 177.443, 744 ),
                                        ['Orientation'] = VECTOR3( 0, 4.65, 0 ),
                                    },
                                    ['UNIT_16'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 498, 177.43, 744 ),
                                        ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                                    },
                                    ['UNIT_17'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 498, 177.443, 728 ),
                                        ['Orientation'] = VECTOR3( 0, 1.524, 0 ),
                                    },
                                    ['UNIT_18'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 525, 177.443, 744 ),
                                        ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                                    },
                                    ['UNIT_19'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 525, 177.443, 728 ),
                                        ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                                    },
                                    ['UNIT_25'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 545, 177.443, 744 ),
                                        ['Orientation'] = VECTOR3( 0, 1.508, 0 ),
                                    },
                                    ['UNIT_26'] = {
                                        type = 'uub0102',
                                        ['Position'] = VECTOR3( 545, 177.443, 728 ),
                                        ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                                    },
                                    ['UNIT_29'] = {
                                        type = 'uub0701',
                                        ['Position'] = VECTOR3( 512, 177.43, 797 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_72'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 503, 177.43, 794 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_73'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 521, 177.43, 794 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_93'] = {
                                        type = 'uub0801',
                                        ['Position'] = VECTOR3( 487, 177.437, 795 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_90'] = {
                                        type = 'uub0801',
                                        ['Position'] = VECTOR3( 537, 178.745, 795 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_08'] = {
                                        type = 'uua0901',
                                        ['Position'] = VECTOR3( 468.5, 177.437, 785.5 ),
                                        ['Orientation'] = VECTOR3( 0, 3.974, 0 ),
                                    },
                                    ['UNIT_09'] = {
                                        type = 'uua0901',
                                        ['Position'] = VECTOR3( 553.5, 177.437, 785.5 ),
                                        ['Orientation'] = VECTOR3( 0, 5.435, 0 ),
                                    },
                                    ['UNIT_104'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 554, 177.437, 761 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_117'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 554, 177.437, 773 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_126'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 461, 177.437, 763 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_270'] = {
                                        type = 'uub0702',
                                        ['Position'] = VECTOR3( 461, 177.437, 774 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                        },
                    },
                    ['P1_PLAYER_Engineers'] = GROUP {
                        Units = {
                            ['UNIT_01'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 504.5, 177.437, 766.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_02'] = {
                                type = 'uul0002',
                                ['Position'] = VECTOR3( 521.5, 177.437, 766.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                        },
                    },
                    ['P1_GUNSHIPS'] = GROUP {
                        Units = {
                            ['UNIT_165'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 627.5, 177.399, 504.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_55'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 633.5, 177.392, 503.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_166'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 625.5, 177.399, 507.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_54'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 631.5, 177.392, 506.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_167'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 627.5, 177.399, 510.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_53'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 633.5, 177.392, 509.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_168'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 626.5, 177.398, 513.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_52'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 632.5, 177.392, 512.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_169'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 627.5, 177.398, 516.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_46'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 633.5, 177.392, 515.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_170'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 626.5, 177.399, 519.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_45'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 632.5, 177.392, 518.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_44'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 638.5, 177.392, 505.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_43'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 636.5, 177.392, 508.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_42'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 638.5, 177.392, 511.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_41'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 637.5, 177.392, 514.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_40'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 638.5, 177.392, 517.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_39'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 637.5, 177.392, 520.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_38'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 644.5, 177.392, 504.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_37'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 642.5, 177.399, 507.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_36'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 644.5, 177.399, 510.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_35'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 643.5, 177.399, 513.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_34'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 644.5, 177.399, 516.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_33'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 643.5, 177.398, 519.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_32'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 649.5, 177.4, 518.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_31'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 651.5, 177.399, 515.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_30'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 653.5, 177.399, 512.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_28'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 652.5, 177.4, 509.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_27'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 649.5, 177.4, 506.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_06'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 649.5, 177.4, 512.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                        },
                    },
                    ['P1_BOMBERS'] = GROUP {
                        Units = {
                            ['UNIT_118'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 625.5, 178.057, 538.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_119'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 610.5, 179.437, 547.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_139'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 610.5, 179.445, 534.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_257'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 593.5, 180.437, 540.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_256'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 599.5, 180.437, 546.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_255'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 600.5, 180.39, 534.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_140'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 603.5, 180.105, 539.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_141'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 617.5, 178.811, 532.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_142'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 617.5, 178.77, 544.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_143'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 610.5, 179.437, 541.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                            ['UNIT_144'] = {
                                type = 'uua0102',
                                ['Position'] = VECTOR3( 617.5, 178.784, 538.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.571, 0 ),
                            },
                        },
                    },
                    ['P2_EXP'] = GROUP {
                        Units = {
                            ['UNIT_50'] = {
                                type = 'uux0101',
                                ['Position'] = VECTOR3( 516.5, 177.399, 426.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_49'] = {
                                type = 'uux0101',
                                ['Position'] = VECTOR3( 507.5, 177.4, 419.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                        },
                    },
                    ['P3_EXP'] = GROUP {
                        Units = {
                            ['UNIT_107'] = {
                                type = 'uux0102',
                                ['Position'] = VECTOR3( 375.5, 177.533, 511.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.76, 0 ),
                            },
                        },
                    },
                    ['PLAYER_CDR'] = {
                        type = 'uul0001',
                        ['Position'] = VECTOR3( 512.5, 177.399, 779.5 ),
                        ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                    },
                    ['PLAYER_LAND_FACTORY'] = {
                        type = 'uub0001',
                        ['Position'] = VECTOR3( 535, 177.43, 736 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['PLAYER_AIR_FACTORY'] = {
                        type = 'uub0002',
                        ['Position'] = VECTOR3( 488, 177.43, 736 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['PLAYER_KING'] = {
                        type = 'uux0111',
                        ['Position'] = VECTOR3( 356.5, 177.429, 509.5 ),
                        ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                    },
                    ['P2_LAND'] = GROUP {
                        Units = {
                            ['UNIT_258'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 504.5, 177.438, 349.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_187'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 504.5, 177.438, 352.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_177'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 504.5, 177.438, 377.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_68'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 506.5, 177.438, 364.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_178'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 505.5, 177.438, 373.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_259'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 507.5, 177.438, 349.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_188'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 507.5, 177.438, 352.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_179'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 507.5, 177.438, 377.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_69'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 509.5, 177.438, 364.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_180'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 508.5, 177.438, 373.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_260'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 510.5, 177.438, 349.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_189'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 510.5, 177.438, 352.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_181'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 510.5, 177.438, 377.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_70'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 512.5, 177.438, 364.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_182'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 511.5, 177.438, 373.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_261'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 513.5, 177.437, 349.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_190'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 513.5, 177.437, 352.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_183'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 513.5, 177.438, 377.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_71'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 515.5, 177.438, 364.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_184'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 514.5, 177.437, 373.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_262'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 516.5, 177.437, 349.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_191'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 516.5, 177.437, 352.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_185'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 516.5, 177.438, 377.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_74'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 518.5, 177.437, 364.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_186'] = {
                                type = 'uul0103',
                                ['Position'] = VECTOR3( 517.5, 177.437, 373.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_47'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 503.5, 177.438, 360.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_48'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 507.5, 177.438, 360.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_56'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 511.5, 177.438, 360.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_57'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 515.5, 177.437, 360.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_58'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 519.5, 177.437, 360.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_59'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 505.5, 177.438, 356.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_60'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 509.5, 177.438, 356.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_61'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 513.5, 177.437, 356.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_62'] = {
                                type = 'uul0101',
                                ['Position'] = VECTOR3( 517.5, 177.437, 356.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.142, 0 ),
                            },
                            ['UNIT_127'] = {
                                type = 'uul0104',
                                ['Position'] = VECTOR3( 511.5, 177.434, 368.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                            },
                            ['UNIT_128'] = {
                                type = 'uul0104',
                                ['Position'] = VECTOR3( 515.5, 177.434, 368.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                            },
                            ['UNIT_129'] = {
                                type = 'uul0104',
                                ['Position'] = VECTOR3( 504.5, 177.434, 368.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                            },
                            ['UNIT_130'] = {
                                type = 'uul0104',
                                ['Position'] = VECTOR3( 508.5, 177.434, 368.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.11, 0 ),
                            },
                        },
                    },
                    ['P2_GUNSHIPS'] = GROUP {
                        Units = {
                            ['UNIT_264'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 512.5, 177.455, 394.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_171'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 512.5, 177.455, 382.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_265'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 507.5, 177.454, 397.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_172'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 507.5, 177.455, 385.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_266'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 516.5, 177.455, 397.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_173'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 516.5, 177.454, 385.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_267'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 503.5, 177.454, 402.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_174'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 503.5, 177.454, 390.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_268'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 520.5, 177.455, 402.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_175'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 520.5, 177.455, 390.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_269'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 512.5, 177.455, 399.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                            ['UNIT_176'] = {
                                type = 'uua0103',
                                ['Position'] = VECTOR3( 512.5, 177.455, 387.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.157, 0 ),
                            },
                        },
                    },
                    ['PLAYER_EXP_AIR_FACTORY'] = {
                        type = 'uub0012',
                        ['Position'] = VECTOR3( 484, 192.531, 596 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['PLAYER_EXP_LAND_FACTORY'] = {
                        type = 'uub0011',
                        ['Position'] = VECTOR3( 511, 195.069, 512 ),
                        ['Orientation'] = VECTOR3( 0, 6.283, 0 ),
                    },
                    ['PLAYER_ILL_EXP_FACTORY'] = {
                        type = 'uib0011',
                        ['Position'] = VECTOR3( 253, 195.569, 478 ),
                        ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                    },
                    ['PLAYER_UNIT_CANNON'] = {
                        type = 'uux0114',
                        ['Position'] = VECTOR3( 433, 182.655, 484 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                },
            },
        },
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_ENEM02'] =  
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
                ['ARMY_PLAYER'] = 'ENEMY',
                ['ARMY_ENEM01'] = 'ALLY',
                ['ARMY_ENEM03'] = 'ALLY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['ENEM02_BASE'] = GROUP {
                        Units = {
                            ['UNIT_88'] = {
                                type = 'uib0001',
                                ['Position'] = VECTOR3( 499, 179.468, 246 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_89'] = {
                                type = 'uib0001',
                                ['Position'] = VECTOR3( 531, 179.468, 251 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_101'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 540, 178.958, 312 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_102'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 484, 178.958, 312 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_103'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 474, 177.436, 266 ),
                                ['Orientation'] = VECTOR3( 0, 1.555, 0 ),
                            },
                            ['UNIT_105'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 468, 177.436, 270 ),
                                ['Orientation'] = VECTOR3( 0, 0.094, 0 ),
                            },
                            ['UNIT_107'] = {
                                type = 'uib0702',
                                ['Position'] = VECTOR3( 487, 178.228, 220 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_116'] = {
                                type = 'uib0702',
                                ['Position'] = VECTOR3( 536, 178.228, 220 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_115'] = {
                                type = 'uib0702',
                                ['Position'] = VECTOR3( 517, 178.228, 220 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_108'] = {
                                type = 'uib0702',
                                ['Position'] = VECTOR3( 508, 178.228, 220 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_109'] = {
                                type = 'uib0702',
                                ['Position'] = VECTOR3( 555, 177.437, 255 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_110'] = {
                                type = 'uib0702',
                                ['Position'] = VECTOR3( 470, 178.228, 266 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_111'] = {
                                type = 'uib0702',
                                ['Position'] = VECTOR3( 470, 178.228, 251 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_112'] = {
                                type = 'uib0701',
                                ['Position'] = VECTOR3( 482, 177.439, 269 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_113'] = {
                                type = 'uib0701',
                                ['Position'] = VECTOR3( 544, 177.437, 265 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_114'] = {
                                type = 'uib0701',
                                ['Position'] = VECTOR3( 502, 177.439, 291 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_75'] = {
                                type = 'uib0202',
                                ['Position'] = VECTOR3( 487, 180.265, 253 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_76'] = {
                                type = 'uib0202',
                                ['Position'] = VECTOR3( 543, 180.265, 258 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_77'] = {
                                type = 'uib0701',
                                ['Position'] = VECTOR3( 484, 177.43, 240 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_78'] = {
                                type = 'uib0701',
                                ['Position'] = VECTOR3( 523, 177.43, 235 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_79'] = {
                                type = 'uib0002',
                                ['Position'] = VECTOR3( 514, 186.766, 274 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_240'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 507, 178.965, 293 ),
                                ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                            },
                            ['UNIT_236'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 543, 178.966, 290 ),
                                ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                            },
                            ['UNIT_235'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 533, 178.965, 287 ),
                                ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                            },
                            ['UNIT_234'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 500, 178.965, 296 ),
                                ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                            },
                            ['UNIT_233'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 492, 178.966, 290 ),
                                ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                            },
                            ['UNIT_80'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 506, 178.958, 284 ),
                                ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                            },
                            ['UNIT_81'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 521, 178.958, 284 ),
                                ['Orientation'] = VECTOR3( 0, 6.267, 0 ),
                            },
                            ['UNIT_82'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 503, 177.443, 277 ),
                                ['Orientation'] = VECTOR3( 0, 4.681, 0 ),
                            },
                            ['UNIT_84'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 525, 177.443, 277 ),
                                ['Orientation'] = VECTOR3( 0, 1.587, 0 ),
                            },
                            ['UNIT_95'] = {
                                type = 'uib0203',
                                ['Position'] = VECTOR3( 539.5, 177.43, 283.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_86'] = {
                                type = 'uib0203',
                                ['Position'] = VECTOR3( 488.5, 177.43, 283.5 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_97'] = {
                                type = 'uib0801',
                                ['Position'] = VECTOR3( 472, 177.43, 240 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_98'] = {
                                type = 'uib0801',
                                ['Position'] = VECTOR3( 557, 177.43, 265 ),
                                ['Orientation'] = VECTOR3( 0, 3.126, 0 ),
                            },
                            ['UNIT_146'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 538, 177.437, 261 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_196'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 524, 178.965, 261 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_199'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 542, 178.965, 243 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_202'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 492, 178.966, 256 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_203'] = {
                                type = 'uib0101',
                                ['Position'] = VECTOR3( 506, 178.965, 256 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_242'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 546, 177.437, 280 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_244'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 494, 177.437, 281 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_245'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 482, 177.437, 287 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_247'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 492, 177.437, 235 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_248'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 505, 177.437, 235 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_250'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 487, 177.442, 225 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_253'] = {
                                type = 'uib0102',
                                ['Position'] = VECTOR3( 536, 177.437, 225 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_254'] = {
                                type = 'uix0101',
                                ['Position'] = VECTOR3( 520.5, 177.437, 294.5 ),
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
        ['ARMY_ENEM03'] =  
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
                ['ARMY_PLAYER'] = 'ENEMY',
                ['ARMY_ENEM01'] = 'ALLY',
                ['ARMY_ENEM02'] = 'ALLY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['ENEM03_BASE'] = GROUP {
                        Units = {
                            ['UNIT_51'] = {
                                type = 'ucx0111',
                                ['Position'] = VECTOR3( 273.5, 177.541, 502.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.649, 0 ),
                            },
                            ['UNIT_106'] = {
                                type = 'uix0111',
                                ['Position'] = VECTOR3( 244.5, 177.437, 524.5 ),
                                ['Orientation'] = VECTOR3( 0, 1.555, 0 ),
                            },
                        },
                    },
                },
            },
        },
        --[[                                                                           ]]--
        --[[  Army                                                                     ]]--
        --[[                                                                           ]]--
        ['ARMY_TECH'] =  
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
                    ['PRELOAD_GROUP'] = GROUP {
                        Units = {
                        },
                    },
                },
            },
        },
    },
}
