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
        ['Transport_Entry_Zone_01'] = {
            ['rectangle'] = RECTANGLE( 276.5, 262, 412.5, 393 ),
        },
        ['Enemy_Drop_Zone_02'] = {
            ['rectangle'] = RECTANGLE( 569.086, 387.003, 671.914, 471.997 ),
        },
        ['Gate_Escape_Area'] = {
            ['rectangle'] = RECTANGLE( 379.66, 555.614, 417.34, 595.386 ),
        },
        ['Enemy_Drop_Zone_01'] = {
            ['rectangle'] = RECTANGLE( 401.918, 312.589, 503.082, 440.411 ),
        },
        ['Transport_Entry_Zone_02'] = {
            ['rectangle'] = RECTANGLE( 619, 262, 748, 393 ),
        },
        ['Transport_Entry_Zone_03'] = {
            ['rectangle'] = RECTANGLE( 626.008, 544.501, 814.992, 706.499 ),
        },
        ['AREA_1'] = {
            ['rectangle'] = RECTANGLE( 319.5, 309.5, 709.5, 707.5 ),
        },
        ['Enemy_Drop_Zone_03'] = {
            ['rectangle'] = RECTANGLE( 588.92, 503.415, 690.08, 621.585 ),
        },
        ['Player_Safe_AREA'] = {
            ['rectangle'] = RECTANGLE( 442.5, 497.5, 542.5, 597.5 ),
        },
        ['ObjectiveArea_Shield'] = {
            ['rectangle'] = RECTANGLE( 466.5, 513.5, 528.5, 575.5 ),
        },
    },
    --[[                                                                           ]]--
    --[[  Markers                                                                  ]]--
    --[[                                                                           ]]--
    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                ['Blank Marker 58'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 476.5, 216.168, 515.5 ),
                },
                ['Blank Marker 67'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 593.5, 211.217, 445.5 ),
                },
                ['Location02_Xport_Landing_03'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 603.5, 208.604, 451.5 ),
                },
                ['Blank Marker 48'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 551.5, 216.168, 512.5 ),
                },
                ['Mass 03'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff808080' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Mass_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 511, 216.136, 528 ),
                },
                ['Blank Marker 23'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 475.5, 216.168, 562.5 ),
                },
                ['Blank Marker 56'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 546.5, 216.168, 549.5 ),
                },
                ['Blank Marker 118'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 634.5, 236.308, 663.5 ),
                },
                ['Blank Marker 18'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 476.5, 216.168, 562.5 ),
                },
                ['Blank Marker 112'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 567.5, 208.612, 393.5 ),
                },
                ['P1_ENEM01_EXP_Transport_Loc01_Destination'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 599.5, 208.613, 433.5 ),
                },
                ['Blank Marker 73'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 470.5, 216.199, 408.5 ),
                },
                ['Blank Marker 96'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 530.5, 216.169, 548.5 ),
                },
                ['Blank Marker 90'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 489.5, 216.169, 509.5 ),
                },
                ['Blank Marker 113'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 704.5, 208.625, 392.5 ),
                },
                ['Blank Marker 21'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 499.5, 216.168, 538.5 ),
                },
                ['Blank Marker 108'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 699.5, 208.619, 387.5 ),
                },
                ['Blank Marker 60'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 520.5, 216.168, 557.5 ),
                },
                ['Blank Marker 36'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 471.5, 216.169, 510.5 ),
                },
                ['Location02_Xport_Landing_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 583.5, 208.607, 432.5 ),
                },
                ['Blank Marker 78'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 527.5, 216.17, 551.5 ),
                },
                ['Blank Marker 59'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 521.5, 216.168, 512.5 ),
                },
                ['Location01_Xport_Landing_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 461.5, 208.598, 410.5 ),
                },
                ['Blank Marker 97'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 614.5, 215.623, 576.5 ),
                },
                ['Blank Marker 65'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 469.5, 216.169, 517.5 ),
                },
                ['Blank Marker 66'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 515.5, 216.168, 522.5 ),
                },
                ['Blank Marker 64'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 510.5, 216.167, 528.5 ),
                },
                ['Blank Marker 117'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 704.5, 239.769, 531.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc01_Destination_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 567.5, 212.841, 473.5 ),
                },
                ['Location01_Xport_ReturnPoint'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 280.5, 64.18, 283.5 ),
                },
                ['Blank Marker 22'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 547.5, 216.167, 557.5 ),
                },
                ['Location01_Xport_Landing_03'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 447.5, 208.601, 418.5 ),
                },
                ['Blank Marker 42'] = {
                    ['color'] = STRING( 'ff0000f5' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 530.5, 216.168, 494.5 ),
                },
                ['Blank Marker 84'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 520.5, 216.169, 518.5 ),
                },
                ['Blank Marker 35'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 490.5, 216.168, 477.5 ),
                },
                ['Blank Marker 91'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 467.5, 216.201, 411.5 ),
                },
                ['P3_Intro_NIS_Cam01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff808000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Camera_prop.bp' ),
                    ['orientation'] = VECTOR3( 3.142, 1.49, 0 ),
                    ['position'] = VECTOR3( 459.5, 218.375, 515.5 ),
                },
                ['Blank Marker 15'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 461.5, 216.168, 519.5 ),
                },
                ['Blank Marker 29'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 505.5, 216.168, 517.5 ),
                },
                ['Blank Marker 38'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 521.5, 216.168, 557.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc03_Destination_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 570.5, 214.275, 563.5 ),
                },
                ['Blank Marker 26'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 514.5, 216.167, 523.5 ),
                },
                ['Blank Marker 110'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 651.5, 208.605, 447.5 ),
                },
                ['Blank Marker 31'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 519.5, 216.168, 545.5 ),
                },
                ['Blank Marker 52'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 480.5, 216.168, 518.5 ),
                },
                ['Blank Marker 24'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 475.5, 216.168, 519.5 ),
                },
                ['Blank Marker 39'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 514.5, 216.167, 522.5 ),
                },
                ['Blank Marker 09'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 485.5, 216.169, 468.5 ),
                },
                ['Blank Marker 103'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 443.5, 208.617, 317.5 ),
                },
                ['Blank Marker 11'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 520.5, 216.168, 557.5 ),
                },
                ['Blank Marker 72'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 486.5, 216.17, 512.5 ),
                },
                ['P1_ENEM01_EXP_Transport_Loc03_Destination'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 626.5, 208.604, 579.5 ),
                },
                ['Blank Marker 119'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 623.5, 236.35, 523.5 ),
                },
                ['CAM_OPENING'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff808000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Camera_prop.bp' ),
                    ['orientation'] = VECTOR3( 2.859, 1.194, 0 ),
                    ['position'] = VECTOR3( 485.5, 218.219, 565.5 ),
                },
                ['Blank Marker 43'] = {
                    ['color'] = STRING( 'ff0000f5' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 475.5, 216.168, 563.5 ),
                },
                ['P1_Intro_NIS_VisLoc01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 501.5, 216.17, 553.5 ),
                },
                ['Blank Marker 106'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 366.5, 209.027, 317.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc01_Destination_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 560.5, 214.876, 482.5 ),
                },
                ['Blank Marker 06'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 492.5, 216.168, 473.5 ),
                },
                ['Blank Marker 50'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 475.5, 216.167, 563.5 ),
                },
                ['Blank Marker 46'] = {
                    ['color'] = STRING( 'ff0000f5' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 498.5, 216.168, 541.5 ),
                },
                ['Location03_Xport_Landing_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 620.5, 208.607, 565.5 ),
                },
                ['Mass 01'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff808080' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Mass_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 521, 216.137, 558 ),
                },
                ['Blank Marker 114'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 637.5, 239.675, 534.5 ),
                },
                ['Location03_Xport_Landing_03'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 614.5, 208.606, 593.5 ),
                },
                ['Blank Marker 27'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 472.5, 216.168, 533.5 ),
                },
                ['Blank Marker 32'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 474.5, 216.167, 545.5 ),
                },
                ['Location01_Xport_Landing_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 472.5, 208.606, 402.5 ),
                },
                ['Blank Marker 40'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 474.5, 216.168, 562.5 ),
                },
                ['Blank Marker 51'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 520.5, 216.167, 558.5 ),
                },
                ['Blank Marker 37'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 492.5, 216.168, 542.5 ),
                },
                ['P1_ENEM01_EXP_Transport_Loc02_Destination'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 456.5, 208.61, 403.5 ),
                },
                ['Blank Marker 13'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 494.5, 216.168, 565.5 ),
                },
                ['Blank Marker 16'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 564.5, 213.572, 476.5 ),
                },
                ['Blank Marker 34'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 448.5, 208.609, 404.5 ),
                },
                ['Blank Marker 61'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 614.5, 208.607, 591.5 ),
                },
                ['Blank Marker 30'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 481.5, 216.168, 517.5 ),
                },
                ['Blank Marker 33'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 474.5, 216.168, 562.5 ),
                },
                ['Blank Marker 19'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 469.5, 216.168, 530.5 ),
                },
                ['Blank Marker 102'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 400.5, 208.683, 429.5 ),
                },
                ['Blank Marker 107'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 393.5, 208.819, 437.5 ),
                },
                ['Blank Marker 45'] = {
                    ['color'] = STRING( 'ff0000f5' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 528.5, 216.169, 565.5 ),
                },
                ['Blank Marker 25'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 519.5, 216.168, 563.5 ),
                },
                ['Blank Marker 08'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 502.5, 216.168, 513.5 ),
                },
                ['Location02_Xport_ReturnPoint'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 739.5, 218.868, 304.5 ),
                },
                ['Blank Marker 57'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 476.5, 216.167, 563.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc01_Destination_03'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 574.5, 210.931, 465.5 ),
                },
                ['Blank Marker 55'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 602.5, 208.607, 568.5 ),
                },
                ['Blank Marker 104'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 334.5, 208.599, 387.5 ),
                },
                ['Blank Marker 20'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 508.5, 216.163, 570.5 ),
                },
                ['P3_Intro_NIS_VisLoc01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 456.5, 216.168, 515.5 ),
                },
                ['Blank Marker 116'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 577.5, 239.725, 615.5 ),
                },
                ['Blank Marker 41'] = {
                    ['color'] = STRING( 'ff0000f5' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 595.5, 208.607, 429.5 ),
                },
                ['Blank Marker 53'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 492.5, 216.168, 546.5 ),
                },
                ['Blank Marker 14'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 475.5, 216.168, 562.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc03_Destination_03'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 587.5, 208.608, 571.5 ),
                },
                ['Blank Marker 63'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 474.5, 216.168, 563.5 ),
                },
                ['Blank Marker 85'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 590.5, 215.718, 448.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc02_Destination_03'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 473.5, 211.082, 437.5 ),
                },
                ['Location02_Xport_Landing_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 591.5, 208.603, 442.5 ),
                },
                ['ARMY_PLAYER'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 484.5, 216.168, 552.5 ),
                },
                ['Blank Marker 47'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 618.5, 208.606, 453.5 ),
                },
                ['Blank Marker 62'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 521.5, 216.169, 564.5 ),
                },
                ['Blank Marker 109'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 599.5, 208.635, 320.5 ),
                },
                ['CommanderAttack_Marker'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 505.5, 216.168, 536.5 ),
                },
                ['Blank Marker 44'] = {
                    ['color'] = STRING( 'ff0000f5' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 473.5, 216.168, 513.5 ),
                },
                ['Blank Marker 115'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 707.5, 236.312, 608.5 ),
                },
                ['Blank Marker 17'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 515.5, 216.169, 521.5 ),
                },
                ['Blank Marker 12'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 474.5, 216.168, 545.5 ),
                },
                ['Blank Marker 10'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 481.5, 216.169, 512.5 ),
                },
                ['Blank Marker 111'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 690.5, 208.635, 323.5 ),
                },
                ['Location03_Xport_Landing_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 615.5, 208.608, 579.5 ),
                },
                ['Blank Marker 07'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 509.5, 216.168, 500.5 ),
                },
                ['Blank Marker 49'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 514.5, 216.167, 524.5 ),
                },
                ['Blank Marker 28'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 462.5, 208.607, 400.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc03_Destination_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 579.5, 210.602, 567.5 ),
                },
                ['Blank Marker 105'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 490.5, 208.61, 377.5 ),
                },
                ['ARMY_ENEM01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0.001, 0, 0, 1 ),
                    ['position'] = VECTOR3( 586.5, 208.608, 453.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc02_Destination_02'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 485.5, 216.004, 463.5 ),
                },
                ['P1_ENEM01_EXP_Transport_ReturnPoint'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 261.5, 156.017, 681.5 ),
                },
                ['Location03_Xport_ReturnPoint'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 775.5, 113.02, 638.5 ),
                },
                ['P1_ENEM01_EXP_TransportFinal_Loc02_Destination_01'] = {
                    ['color'] = STRING( 'ff800080' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '/env/common/props/markers/M_Blank_prop.bp' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 488.5, 216.168, 473.5 ),
                },
                ['GunshipResponse_PatrolBase_01'] = {
                    ['color'] = STRING( 'ffff0000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 537.5, 216.168, 503.5 ),
                },
                ['GunshipResponse_PatrolBase_02'] = {
                    ['color'] = STRING( 'ffff0000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 489.5, 216.167, 503.5 ),
                },
                ['GunshipResponse_PatrolBase_03'] = {
                    ['color'] = STRING( 'ffff0000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 537.5, 216.168, 546.5 ),
                },
                ['GunshipResponse_PatrolBase_04'] = {
                    ['color'] = STRING( 'ffff0000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 489.5, 216.167, 546.5 ),
                },
                ['P1_ENEM01_Loc03_AirAttack_Chain_01_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 499.5, 216.167, 538.5 ),
                },
                ['SoundEmitter_SkyHigh'] = {
                    ['EventName'] = STRING( 'Sc2/SC2/Environments/SC2_CA_C01/snd_SC2_CA_C01_Skyhigh' ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Sound' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 507.5, 216.062, 522.5 ),
                },
                ['Mass 04'] = {
                    ['size'] = FLOAT( 6.0 ),
                    ['amount'] = FLOAT( 100.0 ),
                    ['resource'] = BOOLEAN( true ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Mass' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 481, 216.133, 518 ),
                },
                ['GunshipResponse_PatrolBase_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 461.5, 214.177, 579.5 ),
                },
                ['GunshipResponse_PatrolBase_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 508.5, 216.17, 578.5 ),
                },
                ['GunshipResponse_PatrolBase_07'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 460.5, 216.167, 530.5 ),
                },
                ['INTRONIS_CommanderDestination_Marker'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, -0.404, 0, 0.915 ),
                    ['position'] = VECTOR3( 490.5, 216.167, 548.5 ),
                },
                ['INTRONIS_Transport_Landing_Marker_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 518.5, 216.166, 542.5 ),
                },
                ['INTRONIS_Transport_Return_Marker_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 274.5, 155.984, 536.5 ),
                },
                ['INTRONIS_Transport_Chain_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 673.5, 208.602, 305.5 ),
                },
                ['INTRONIS_Transport_Chain_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 623.5, 208.605, 395.5 ),
                },
                ['INTRONIS_Transport_Chain_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 608.5, 208.605, 432.5 ),
                },
                ['INTRONIS_Transport_Chain_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 562.5, 214.198, 479.5 ),
                },
                ['P1_ENEM01_Loc02_LandAttack_Chain_01_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 438.5, 212.767, 503.5 ),
                },
                ['P1_ENEM01_Loc02_LandAttack_Chain_01_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 419.5, 209.693, 516.5 ),
                },
                ['P1_ENEM01_Loc02_LandAttack_Chain_01_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 417.5, 208.606, 552.5 ),
                },
                ['P1_ENEM01_Loc02_LandAttack_Chain_01_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 427.5, 208.607, 586.5 ),
                },
                ['P1_ENEM01_Loc02_LandAttack_Chain_01_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 448.5, 208.606, 590.5 ),
                },
                ['P1_ENEM01_Loc02_LandAttack_Chain_01_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 480.5, 216.165, 576.5 ),
                },
                ['P1_ENEM01_Loc03_LandAttack_Chain_01_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 472.5, 216.167, 578.5 ),
                },
                ['P1_ENEM01_Loc03_LandAttack_Chain_01_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 445.5, 208.606, 590.5 ),
                },
                ['P1_ENEM01_Loc03_LandAttack_Chain_01_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 424.5, 208.607, 586.5 ),
                },
                ['P1_ENEM01_Loc03_LandAttack_Chain_01_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 414.5, 208.605, 551.5 ),
                },
                ['P1_ENEM01_Loc03_LandAttack_Chain_01_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 416.5, 209.006, 516.5 ),
                },
                ['P1_ENEM01_Loc03_LandAttack_Chain_01_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 438.5, 212.924, 505.5 ),
                },
                ['P1_ENEM01_Loc01_LandAttack_Chain_01_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 438.5, 213.011, 506.5 ),
                },
                ['P1_ENEM01_Loc01_LandAttack_Chain_01_02'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 418.5, 209.832, 513.5 ),
                },
                ['P1_ENEM01_Loc01_LandAttack_Chain_01_03'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 414.5, 208.605, 554.5 ),
                },
                ['P1_ENEM01_Loc01_LandAttack_Chain_01_04'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 426.5, 208.607, 583.5 ),
                },
                ['P1_ENEM01_Loc01_LandAttack_Chain_01_05'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 447.5, 208.606, 593.5 ),
                },
                ['P1_ENEM01_Loc01_LandAttack_Chain_01_06'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 472.5, 216.168, 575.5 ),
                },
                ['P1_ENEM01_EXP_TransportRoute_Loc03_01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 611.5, 208.607, 579.5 ),
                },
                ['NIS1_CAM_A_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.723, 0.459, 0 ),
                    ['position'] = VECTOR3( 787.798, 517.794, -1261.411 ),
                },
                ['NIS1_CAM_A_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.298, 0.554, 0 ),
                    ['position'] = VECTOR3( 636.912, 725.969, -1366.961 ),
                },
                ['NIS1_CAM_B_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.656, 0.172, 0 ),
                    ['position'] = VECTOR3( 515.5, 240.571, 580.5 ),
                },
                ['NIS1_CAM_B_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -3.139, 0.239, 0 ),
                    ['position'] = VECTOR3( 525.333, 235.203, 583.366 ),
                },
                ['NIS1_CAM_C_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 2.469, 0.081, 0 ),
                    ['position'] = VECTOR3( 517.5, 220.312, 537.5 ),
                },
                ['NIS1_CAM_C_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -2.096, 0.202, 0 ),
                    ['position'] = VECTOR3( 520.5, 223.025, 543.5 ),
                },
                ['NIS1_CAM_D_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -0.924, 0.113, 0 ),
                    ['position'] = VECTOR3( 505.369, 220.619, 532.145 ),
                },
                ['NIS1_CAM_D_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( -1.672, 0.642, 0 ),
                    ['position'] = VECTOR3( 529.807, 246.601, 542.087 ),
                },
                ['NIS1_CAM_E_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0, 0, 0 ),
                    ['position'] = VECTOR3( 433.5, 208.682, 351.5 ),
                },
                ['NIS1_CAM_E_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0, 0, 0 ),
                    ['position'] = VECTOR3( 430.5, 208.669, 351.5 ),
                },
                ['NIS1_CAM_F_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0, 0, 0 ),
                    ['position'] = VECTOR3( 433.5, 208.606, 346.5 ),
                },
                ['NIS1_CAM_F_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 0, 0, 0 ),
                    ['position'] = VECTOR3( 430.5, 208.606, 346.5 ),
                },
                ['Weather Generator 01'] = {
                    ['CloudSpread'] = FLOAT( 400.0 ),
                    ['CloudCount'] = FLOAT( 3.0 ),
                    ['CloudCountRange'] = FLOAT( 0.0 ),
                    ['CloudHeight'] = FLOAT( 0.0 ),
                    ['CloudHeightRange'] = FLOAT( 20.0 ),
                    ['CloudEmitterScale'] = FLOAT( 2.0 ),
                    ['CloudEmitterScaleRange'] = FLOAT( 1.0 ),
                    ['ForceType'] = STRING( 'None' ),
                    ['SpawnChance'] = FLOAT( 1.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Weather Generator' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 714.977, 202.719, 204.018 ),
                },
                ['Weather Generator 02'] = {
                    ['CloudSpread'] = FLOAT( 500.0 ),
                    ['CloudCount'] = FLOAT( 3.0 ),
                    ['CloudCountRange'] = FLOAT( 0.0 ),
                    ['CloudHeight'] = FLOAT( 0.0 ),
                    ['CloudHeightRange'] = FLOAT( 20.0 ),
                    ['CloudEmitterScale'] = FLOAT( 2.0 ),
                    ['CloudEmitterScaleRange'] = FLOAT( 1.0 ),
                    ['ForceType'] = STRING( 'None' ),
                    ['SpawnChance'] = FLOAT( 1.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Weather Generator' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( -125.023, 202.453, 133.018 ),
                },
                ['Weather Generator 03'] = {
                    ['CloudSpread'] = FLOAT( 300.0 ),
                    ['CloudCount'] = FLOAT( 2.0 ),
                    ['CloudCountRange'] = FLOAT( 0.0 ),
                    ['CloudHeight'] = FLOAT( 0.0 ),
                    ['CloudHeightRange'] = FLOAT( 10.0 ),
                    ['CloudEmitterScale'] = FLOAT( 2.0 ),
                    ['CloudEmitterScaleRange'] = FLOAT( 0.5 ),
                    ['ForceType'] = STRING( 'None' ),
                    ['SpawnChance'] = FLOAT( 1.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Weather Generator' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( -199.023, 202.505, 737.018 ),
                },
                ['TELEPORT_LOCATION01'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 418.5, 208.606, 577.5 ),
                },
                ['TELEPORT_LOCATION'] = {
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Blank Marker' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = QUATERNION( 0, 0, 0, 1 ),
                    ['position'] = VECTOR3( 409.5, 208.607, 577.5 ),
                },
                ['NIS_FINAL_CAM_01'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.563, 0.213, 0 ),
                    ['position'] = VECTOR3( 377.5, 220.093, 577.5 ),
                },
                ['NIS_FINAL_CAM_02'] = {
                    ['zoom'] = FLOAT( 0.0 ),
                    ['fov'] = FLOAT( 60.0 ),
                    ['color'] = STRING( 'ff008000' ),
                    ['type'] = STRING( 'Camera Info' ),
                    ['prop'] = STRING( '' ),
                    ['orientation'] = VECTOR3( 1.822, 0.067, 0 ),
                    ['position'] = VECTOR3( 383.056, 222.043, 584.918 ),
                },
            },
        },
    },
    Chains = {
        ['P1_ENEM01_EXP_AttackRoute_01'] = {
            Markers = {
                "Blank Marker 16",
                "Blank Marker 18",
                "Blank Marker 20",
                "Blank Marker 39",
            },
        },
        ['P1_ENEM01_EXP_AttackRoute_02'] = {
            Markers = {
                "Blank Marker 09",
                "Blank Marker 72",
                "Blank Marker 18",
                "Blank Marker 59",
                "Blank Marker 65",
                "Blank Marker 39",
            },
        },
        ['P1_ENEM01_EXP_AttackRoute_03'] = {
            Markers = {
                "Blank Marker 12",
                "Blank Marker 18",
                "Blank Marker 65",
                "Blank Marker 25",
                "Blank Marker 39",
            },
        },
        ['P1_ENEM01_EXP_FinalTransportRoute_Loc01'] = {
            Markers = {
                "Blank Marker 84",
                "Blank Marker 85",
            },
        },
        ['P1_ENEM01_EXP_FinalTransportRoute_Loc02'] = {
            Markers = {
                "Blank Marker 90",
                "Blank Marker 91",
            },
        },
        ['P1_ENEM01_EXP_FinalTransportRoute_Loc03'] = {
            Markers = {
                "Blank Marker 96",
                "Blank Marker 97",
            },
        },
        ['P1_ENEM01_EXP_TransportRoute_Loc01'] = {
            Markers = {
                "Blank Marker 66",
                "Blank Marker 67",
            },
        },
        ['P1_ENEM01_EXP_TransportRoute_Loc02'] = {
            Markers = {
                "Blank Marker 72",
                "Blank Marker 73",
            },
        },
        ['P1_ENEM01_EXP_TransportRoute_Loc03'] = {
            Markers = {
                "Blank Marker 78",
                "P1_ENEM01_EXP_TransportRoute_Loc03_01",
            },
        },
        ['P1_ENEM01_Loc01_AirAttack_Chain_01'] = {
            Markers = {
                "Blank Marker 28",
                "Blank Marker 29",
                "Blank Marker 30",
                "Blank Marker 31",
                "Blank Marker 32",
                "Blank Marker 33",
            },
        },
        ['P1_ENEM01_Loc01_AirAttack_Chain_02'] = {
            Markers = {
                "Blank Marker 34",
                "Blank Marker 35",
                "Blank Marker 36",
                "Blank Marker 37",
                "Blank Marker 38",
                "Blank Marker 39",
                "Blank Marker 40",
            },
        },
        ['P1_ENEM01_Loc01_LandAttack_Chain_01'] = {
            Markers = {
                "Blank Marker 09",
                "Blank Marker 10",
                "Blank Marker 11",
                "Blank Marker 12",
                "Blank Marker 13",
                "Blank Marker 14",
                "Blank Marker 15",
                "P1_ENEM01_Loc01_LandAttack_Chain_01_01",
                "P1_ENEM01_Loc01_LandAttack_Chain_01_02",
                "P1_ENEM01_Loc01_LandAttack_Chain_01_03",
                "P1_ENEM01_Loc01_LandAttack_Chain_01_04",
                "P1_ENEM01_Loc01_LandAttack_Chain_01_05",
                "P1_ENEM01_Loc01_LandAttack_Chain_01_06",
            },
        },
        ['P1_ENEM01_Loc02_AirAttack_Chain_01'] = {
            Markers = {
                "Blank Marker 41",
                "Blank Marker 42",
                "Blank Marker 43",
                "Blank Marker 44",
                "Blank Marker 45",
                "Blank Marker 46",
            },
        },
        ['P1_ENEM01_Loc02_AirAttack_Chain_02'] = {
            Markers = {
                "Blank Marker 47",
                "Blank Marker 48",
                "Blank Marker 49",
                "Blank Marker 50",
                "Blank Marker 51",
                "Blank Marker 52",
                "Blank Marker 53",
            },
        },
        ['P1_ENEM01_Loc02_LandAttack_Chain_01'] = {
            Markers = {
                "Blank Marker 16",
                "Blank Marker 17",
                "Blank Marker 18",
                "Blank Marker 19",
                "Blank Marker 20",
                "Blank Marker 21",
                "P1_ENEM01_Loc02_LandAttack_Chain_01_01",
                "P1_ENEM01_Loc02_LandAttack_Chain_01_02",
                "P1_ENEM01_Loc02_LandAttack_Chain_01_03",
                "P1_ENEM01_Loc02_LandAttack_Chain_01_04",
                "P1_ENEM01_Loc02_LandAttack_Chain_01_05",
                "P1_ENEM01_Loc02_LandAttack_Chain_01_06",
            },
        },
        ['P1_ENEM01_Loc03_AirAttack_Chain_01'] = {
            Markers = {
                "Blank Marker 55",
                "Blank Marker 56",
                "Blank Marker 57",
                "Blank Marker 58",
                "Blank Marker 59",
                "Blank Marker 60",
                "P1_ENEM01_Loc03_AirAttack_Chain_01_01",
            },
        },
        ['P1_ENEM01_Loc03_AirAttack_Chain_02'] = {
            Markers = {
                "Blank Marker 61",
                "Blank Marker 62",
                "Blank Marker 63",
                "Blank Marker 64",
                "Blank Marker 65",
            },
        },
        ['P1_ENEM01_Loc03_LandAttack_Chain_01'] = {
            Markers = {
                "Blank Marker 22",
                "Blank Marker 23",
                "Blank Marker 24",
                "Blank Marker 25",
                "Blank Marker 26",
                "Blank Marker 27",
                "P1_ENEM01_Loc03_LandAttack_Chain_01_01",
                "P1_ENEM01_Loc03_LandAttack_Chain_01_02",
                "P1_ENEM01_Loc03_LandAttack_Chain_01_03",
                "P1_ENEM01_Loc03_LandAttack_Chain_01_04",
                "P1_ENEM01_Loc03_LandAttack_Chain_01_05",
                "P1_ENEM01_Loc03_LandAttack_Chain_01_06",
            },
        },
        ['Transport_AirPatrol_Zone01'] = {
            Markers = {
                "Blank Marker 102",
                "Blank Marker 103",
                "Blank Marker 104",
                "Blank Marker 105",
                "Blank Marker 106",
                "Blank Marker 107",
            },
        },
        ['Transport_AirPatrol_Zone02'] = {
            Markers = {
                "Blank Marker 108",
                "Blank Marker 109",
                "Blank Marker 110",
                "Blank Marker 111",
                "Blank Marker 112",
                "Blank Marker 113",
            },
        },
        ['Transport_AirPatrol_Zone03'] = {
            Markers = {
                "Blank Marker 114",
                "Blank Marker 115",
                "Blank Marker 116",
                "Blank Marker 117",
                "Blank Marker 118",
                "Blank Marker 119",
            },
        },
        ['GunshipResponse_PatrolBase'] = {
            Markers = {
                "GunshipResponse_PatrolBase_01",
                "GunshipResponse_PatrolBase_02",
                "GunshipResponse_PatrolBase_03",
                "GunshipResponse_PatrolBase_04",
                "GunshipResponse_PatrolBase_05",
                "GunshipResponse_PatrolBase_06",
                "GunshipResponse_PatrolBase_07",
            },
        },
        ['INTRONIS_Transport_Chain'] = {
            Markers = {
                "INTRONIS_Transport_Chain_01",
                "INTRONIS_Transport_Chain_02",
                "INTRONIS_Transport_Chain_03",
                "INTRONIS_Transport_Chain_04",
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
        ['NIS_FINAL_CAM'] = {
            Markers = {
                "NIS_FINAL_CAM_01",
                "NIS_FINAL_CAM_02",
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
                ['ARMY_CIVL01'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                    ['P1'] = GROUP {
                        Units = {
                            ['Spawn_Location_02'] = GROUP {
                                Units = {
                                    ['Air'] = GROUP {
                                        Units = {
                                            ['P1_ENEM01_AirAttack_Loc02_Group_01'] = GROUP {
                                                Units = {
                                                    ['UNIT_413'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 716.5, 219.747, 300.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 5.856, 0 ),
                                                    },
                                                    ['UNIT_414'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 719.5, 219.661, 301.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 5.856, 0 ),
                                                    },
                                                    ['UNIT_415'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 722.5, 219.569, 302.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 5.856, 0 ),
                                                    },
                                                },
                                            },
                                            ['P1_ENEM01_AirAttack_Loc02_Group_02'] = GROUP {
                                                Units = {
                                                    ['UNIT_418'] = {
                                                        type = 'uca0103',
                                                        ['Position'] = VECTOR3( 722.5, 219.585, 298.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 5.873, 0 ),
                                                    },
                                                },
                                            },
                                        },
                                    },
                                    ['Land'] = GROUP {
                                        Units = {
                                            ['Group03'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc02_Group_03'] = GROUP {
                                                        Units = {
                                                            ['UNIT_24'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 751.5, 219.569, 336.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_26'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 748.5, 219.689, 336.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_50'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 751.5, 219.508, 338.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_27'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 751.5, 219.508, 334.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_51'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 748.5, 219.399, 338.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_25'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 748.5, 219.399, 334.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_28'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 751.5, 41.216, 332.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_02'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 748.5, 41.216, 332.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                        },
                                                    },
                                                    ['P1_ENEM01_Xport_Loc02_Group_03_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 756.5, 219.483, 334.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                },
                                            },
                                            ['Group01'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc02_Group_01'] = GROUP {
                                                        Units = {
                                                            ['UNIT_392'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 739.5, 218.542, 298.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_394'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 739.5, 218.729, 302.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_393'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 739.5, 218.729, 300.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_35'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 739.5, 41.208, 296.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                        },
                                                    },
                                                    ['P1_ENEM01_Xport_Loc02_Group_01_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 744.5, 218.417, 298.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                },
                                            },
                                            ['Group02'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc02_Group_02_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 750.5, 219.073, 316.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                    ['P1_ENEM01_Xport_Loc02_Group_02'] = GROUP {
                                                        Units = {
                                                            ['UNIT_398'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 745.5, 219.015, 314.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_53'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 743.5, 41.186, 314.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_52'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 743.5, 219.122, 316.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_30'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 745.5, 219.122, 316.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_47'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 745.5, 41.216, 318.5 ),
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
                            ['Experimental_Transport_Location_01'] = GROUP {
                                Units = {
                                    ['P1_ENEM01_EXP_Transport_Loc01_Group02'] = GROUP {
                                        Units = {
                                            ['UNIT_468'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 683.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_467'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 681.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_465'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 681.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_466'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 681.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_484'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 683.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_469'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 683.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['P1_ENEM01_EXP_Transport_Loc01_Group01'] = GROUP {
                                        Units = {
                                            ['UNIT_463'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 690.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_435'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 687.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_440'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 287.5, 236.312, 693.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_438'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 284.5, 236.312, 693.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_450'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 290.5, 236.332, 693.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_449'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 290.5, 236.332, 690.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_442'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 290.5, 236.332, 687.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_437'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 281.5, 236.312, 693.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_434'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 687.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_439'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 690.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_436'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 690.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_433'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 687.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['P1_ENEM01_EXP_Transport_Loc01'] = {
                                        type = 'ucx0102',
                                        ['Position'] = VECTOR3( 270.5, 236.949, 684.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['Spawn_Location_01'] = GROUP {
                                Units = {
                                    ['Air'] = GROUP {
                                        Units = {
                                            ['P1_ENEM01_AirAttack_Loc01_Group_01'] = GROUP {
                                                Units = {
                                                    ['UNIT_407'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 286.5, 231.844, 312.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0.75, 0 ),
                                                    },
                                                    ['UNIT_408'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 288.5, 230.595, 310.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0.75, 0 ),
                                                    },
                                                    ['UNIT_409'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 290.5, 229.372, 308.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0.75, 0 ),
                                                    },
                                                },
                                            },
                                            ['P1_ENEM01_AirAttack_Loc01_Group_02'] = GROUP {
                                                Units = {
                                                    ['UNIT_412'] = {
                                                        type = 'uca0103',
                                                        ['Position'] = VECTOR3( 291.5, 229.577, 305.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0.506, 0 ),
                                                    },
                                                },
                                            },
                                        },
                                    },
                                    ['Land'] = GROUP {
                                        Units = {
                                            ['Group03'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc01_Group_03'] = GROUP {
                                                        Units = {
                                                            ['UNIT_46'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 316.5, 229.371, 278.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_38'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 313.5, 229.371, 278.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_34'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 316.5, 229.377, 276.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_37'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 313.5, 229.377, 276.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_40'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 316.5, 229.104, 274.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_36'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 313.5, 229.104, 274.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                        },
                                                    },
                                                    ['P1_ENEM01_Xport_Loc01_Group_03_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 321.5, 229.505, 277.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                },
                                            },
                                            ['Group01'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc01_Group_01_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 293.5, 229.505, 296.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                    ['P1_ENEM01_Xport_Loc01_Group_01'] = GROUP {
                                                        Units = {
                                                            ['UNIT_380'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 287.5, 229.378, 295.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_397'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 287.5, 229.378, 298.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_44'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 287.5, 229.626, 292.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                            ['Group02'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc01_Group_02_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 307.5, 229.505, 286.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                    ['P1_ENEM01_Xport_Loc01_Group_02'] = GROUP {
                                                        Units = {
                                                            ['UNIT_41'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 301.5, 229.372, 282.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_39'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 301.5, 229.377, 288.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_45'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 301.5, 229.626, 285.5 ),
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
                            ['Experimental_Transport_Location_02'] = GROUP {
                                Units = {
                                    ['P1_ENEM01_EXP_Transport_Loc02_Group02'] = GROUP {
                                        Units = {
                                            ['UNIT_472'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 276.5, 236.317, 631.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_474'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 270.5, 236.317, 631.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_473'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 273.5, 236.317, 631.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_482'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 276.5, 236.317, 633.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_470'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 273.5, 236.317, 633.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_471'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 270.5, 236.317, 633.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['P1_ENEM01_EXP_Transport_Loc02_Group01'] = GROUP {
                                        Units = {
                                            ['UNIT_445'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 276.5, 236.317, 637.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_443'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 270.5, 236.317, 637.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_462'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 273.5, 236.317, 640.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_461'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 276.5, 236.317, 640.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_495'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 276.5, 236.312, 643.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_448'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 273.5, 236.312, 643.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_444'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 273.5, 236.317, 637.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_446'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 270.5, 236.317, 640.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_447'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 270.5, 236.312, 643.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_494'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 279.5, 236.332, 643.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_460'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 279.5, 236.332, 640.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_451'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 279.5, 236.332, 637.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['P1_ENEM01_EXP_Transport_Loc02'] = {
                                        type = 'ucx0102',
                                        ['Position'] = VECTOR3( 259.5, 236.949, 634.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['Experimental_Transport_Location_03'] = GROUP {
                                Units = {
                                    ['P1_ENEM01_EXP_Transport_Loc03_Group02'] = GROUP {
                                        Units = {
                                            ['UNIT_477'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 655.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_479'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 655.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_476'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 657.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_478'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 655.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_481'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 657.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_475'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 657.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['P1_ENEM01_EXP_Transport_Loc03_Group01'] = GROUP {
                                        Units = {
                                            ['UNIT_459'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 287.5, 236.312, 667.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_457'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 284.5, 236.312, 667.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_464'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 664.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_458'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 664.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_455'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 664.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_454'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 287.5, 236.317, 661.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_452'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 281.5, 236.317, 661.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_453'] = {
                                                type = 'ucl0103',
                                                ['Position'] = VECTOR3( 284.5, 236.317, 661.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_456'] = {
                                                type = 'ucl0204',
                                                ['Position'] = VECTOR3( 281.5, 236.312, 667.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_493'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 291.5, 236.332, 667.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_492'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 291.5, 236.332, 664.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['UNIT_485'] = {
                                                type = 'ucl0102',
                                                ['Position'] = VECTOR3( 291.5, 236.332, 661.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                    ['P1_ENEM01_EXP_Transport_Loc03'] = {
                                        type = 'ucx0102',
                                        ['Position'] = VECTOR3( 270.5, 236.949, 658.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['Spawn_Location_03'] = GROUP {
                                Units = {
                                    ['Air'] = GROUP {
                                        Units = {
                                            ['P1_ENEM01_AirAttack_Loc03_Group_01'] = GROUP {
                                                Units = {
                                                    ['UNIT_423'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 792.5, 236.311, 641.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 4.058, 0 ),
                                                    },
                                                    ['UNIT_419'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 796.5, 236.311, 636.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 4.058, 0 ),
                                                    },
                                                    ['UNIT_422'] = {
                                                        type = 'uca0104',
                                                        ['Position'] = VECTOR3( 794.5, 236.311, 638.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 4.058, 0 ),
                                                    },
                                                },
                                            },
                                            ['P1_ENEM01_AirAttack_Loc03_Group_02'] = GROUP {
                                                Units = {
                                                    ['UNIT_426'] = {
                                                        type = 'uca0103',
                                                        ['Position'] = VECTOR3( 794.5, 236.516, 646.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 4.023, 0 ),
                                                    },
                                                },
                                            },
                                        },
                                    },
                                    ['Land'] = GROUP {
                                        Units = {
                                            ['Group03'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc03_Group_03'] = GROUP {
                                                        Units = {
                                                            ['UNIT_490'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 763.5, 236.317, 608.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_489'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 766.5, 236.317, 608.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_32'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 766.5, 236.311, 606.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_33'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 763.5, 236.311, 606.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_49'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 766.5, 236.575, 610.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_43'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 763.5, 236.575, 610.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                        },
                                                    },
                                                    ['P1_ENEM01_Xport_Loc03_Group_03_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 772.5, 236.443, 608.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                },
                                            },
                                            ['Group01'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc03_Group_01_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 761.5, 236.443, 644.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                    ['P1_ENEM01_Xport_Loc03_Group_01'] = GROUP {
                                                        Units = {
                                                            ['UNIT_396'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 756.5, 236.317, 646.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_395'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 756.5, 236.317, 644.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_42'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 756.5, 237.832, 642.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                        },
                                                    },
                                                },
                                            },
                                            ['Group02'] = GROUP {
                                                Units = {
                                                    ['P1_ENEM01_Xport_Loc03_Group_02_Transport'] = {
                                                        type = 'uca0901',
                                                        ['Position'] = VECTOR3( 767.5, 236.443, 626.5 ),
                                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                    },
                                                    ['P1_ENEM01_Xport_Loc03_Group_02'] = GROUP {
                                                        Units = {
                                                            ['UNIT_405'] = {
                                                                type = 'ucl0103',
                                                                ['Position'] = VECTOR3( 761.5, 236.693, 627.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_21'] = {
                                                                type = 'ucl0104',
                                                                ['Position'] = VECTOR3( 761.5, 236.311, 629.5 ),
                                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                                            },
                                                            ['UNIT_48'] = {
                                                                type = 'ucl0102',
                                                                ['Position'] = VECTOR3( 761.5, 237.832, 625.5 ),
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
                            ['Response_Units'] = GROUP {
                                Units = {
                                    ['Single_Gunship'] = GROUP {
                                        Units = {
                                            ['P1_ENEM01_Response_Gunship'] = {
                                                type = 'uca0103',
                                                ['Position'] = VECTOR3( 730.5, 220.069, 321.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                            ['P1_ENEM01_Response_Fighter'] = {
                                                type = 'uca0104',
                                                ['Position'] = VECTOR3( 725.5, 220.08, 321.5 ),
                                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                            },
                                        },
                                    },
                                },
                            },
                            ['Gunship_Group01'] = GROUP {
                                Units = {
                                    ['UNIT_72'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 438.5, 111.629, 298.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_71'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 434.5, 111.877, 298.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_70'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 429.5, 112.186, 298.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_69'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 425.5, 112.434, 298.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_68'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 438.5, 103.136, 293.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_67'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 434.5, 103.383, 293.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_66'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 438.5, 96.34, 289.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_65'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 434.5, 96.588, 289.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_64'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 429.5, 103.692, 293.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_63'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 425.5, 103.939, 293.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_62'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 429.5, 96.897, 289.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_61'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 425.5, 97.13, 289.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['SoulRipper_Group01'] = GROUP {
                                Units = {
                                    ['SoulRipper_02'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 501.5, 69.331, 292.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['SoulRipper_01'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 486.5, 80.744, 293.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['SoulRipper_Group02'] = GROUP {
                                Units = {
                                    ['SoulRipper_04'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 726.5, 71.072, 538.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['SoulRipper_03'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 726.5, 73.196, 549.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['SoulRipper_Group03'] = GROUP {
                                Units = {
                                    ['SoulRipper_06'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 724.5, 42.057, 284.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['SoulRipper_05'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 734.5, 42.063, 284.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['Gunship_Group02'] = GROUP {
                                Units = {
                                    ['UNIT_86'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 746.5, 69.319, 528.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_85'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 742.5, 69.334, 528.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_82'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 737.5, 69.353, 528.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_81'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 733.5, 69.368, 528.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_80'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 746.5, 68.92, 524.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_79'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 742.5, 68.935, 524.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_78'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 746.5, 68.521, 520.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_77'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 742.5, 68.534, 520.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_76'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 737.5, 68.953, 524.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_75'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 733.5, 68.969, 524.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_74'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 737.5, 68.554, 520.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_73'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 733.5, 68.569, 520.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['Gunship_Group03'] = GROUP {
                                Units = {
                                    ['UNIT_96'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 734.5, 41.401, 342.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_95'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 730.5, 41.401, 342.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_94'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 725.5, 41.4, 342.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_93'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 721.5, 41.398, 342.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_92'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 734.5, 41.402, 337.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_91'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 730.5, 41.4, 337.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_90'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 734.5, 41.401, 333.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_89'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 730.5, 41.399, 333.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_88'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 725.5, 41.399, 337.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_87'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 721.5, 41.397, 337.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_84'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 725.5, 41.398, 333.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_83'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 721.5, 41.396, 333.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['SoulRipper_Group04'] = GROUP {
                                Units = {
                                    ['SoulRipper_08'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 734.5, 42.072, 311.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['SoulRipper_07'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 724.5, 42.069, 311.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['Gunship_Group04'] = GROUP {
                                Units = {
                                    ['UNIT_97'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 699.5, 41.377, 299.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_98'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 695.5, 41.375, 299.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_99'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 690.5, 41.411, 299.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_100'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 686.5, 41.44, 299.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_101'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 699.5, 41.374, 294.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_102'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 695.5, 41.392, 294.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_103'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 699.5, 41.376, 290.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_104'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 695.5, 41.405, 290.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_105'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 690.5, 41.429, 294.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_106'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 686.5, 41.453, 294.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_107'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 690.5, 41.437, 290.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_108'] = {
                                        type = 'uca0103',
                                        ['Position'] = VECTOR3( 686.5, 41.431, 290.5 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['SoulRipper_Assassin'] = GROUP {
                                Units = {
                                    ['SoulRipper_Assassin'] = {
                                        type = 'ucx0112',
                                        ['Position'] = VECTOR3( 662.5, 42.101, 295.5 ),
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
        ['ARMY_PLAYER'] =  
        {
            personality = '',
            plans = '',
            ['color'] = FLOAT( 1.0 ),
            faction = 1,
            Economy = {
                mass = 0,
                energy = 0,
            },
            Alliances = {
                ['ARMY_ENEM01'] = 'ENEMY',
            },
            ['Units'] = GROUP {
                Units = {
                    ['INITIAL'] = GROUP {
                        Units = {
                            ['UNIT_06'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 496.5, 216.171, 514.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_08'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 500.5, 216.171, 515.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_07'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 498.5, 216.171, 514.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_09'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 501.5, 216.171, 517.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_10'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 501.5, 216.171, 519.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_11'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 519.5, 216.171, 537.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_13'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 523.5, 216.171, 538.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_12'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 521.5, 216.171, 537.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_14'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 524.5, 216.171, 540.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_15'] = {
                                type = 'ucl0103',
                                ['Position'] = VECTOR3( 524.5, 216.171, 542.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_18'] = {
                                type = 'ucl0104',
                                ['Position'] = VECTOR3( 495.5, 216.165, 517.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_17'] = {
                                type = 'ucl0104',
                                ['Position'] = VECTOR3( 498.5, 216.165, 520.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_20'] = {
                                type = 'ucl0104',
                                ['Position'] = VECTOR3( 521.5, 216.165, 543.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_19'] = {
                                type = 'ucl0104',
                                ['Position'] = VECTOR3( 518.5, 216.165, 540.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_22'] = {
                                type = 'ucl0204',
                                ['Position'] = VECTOR3( 521.5, 216.168, 540.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                            ['UNIT_23'] = {
                                type = 'ucl0204',
                                ['Position'] = VECTOR3( 498.5, 216.167, 517.5 ),
                                ['Orientation'] = VECTOR3( 0, 0, 0 ),
                            },
                        },
                    },
                    ['P1'] = GROUP {
                        Units = {
                            ['Initial_Mobiles'] = GROUP {
                                Units = {
                                    ['Init_Engineers'] = GROUP {
                                        Units = {
                                            ['P1_PLAYER_Init_Eng_02'] = {
                                                type = 'ucl0002',
                                                ['Position'] = VECTOR3( 496.5, 216.175, 536.5 ),
                                                ['Orientation'] = VECTOR3( 0, 2.356, 0 ),
                                            },
                                            ['P1_PLAYER_Init_Eng_01'] = {
                                                type = 'ucl0002',
                                                ['Position'] = VECTOR3( 502.5, 216.175, 542.5 ),
                                                ['Orientation'] = VECTOR3( 0, 2.356, 0 ),
                                            },
                                        },
                                    },
                                    ['GROUP_32'] = GROUP {
                                        Units = {
                                        },
                                    },
                                    ['P1_PLAYER_Commander_Group'] = GROUP {
                                        Units = {
                                            ['PLAYER_CDR'] = {
                                                type = 'ucl0001',
                                                ['Position'] = VECTOR3( 661.5, 224.349, 342.5 ),
                                                ['Orientation'] = VECTOR3( 0, 2.215, 0 ),
                                            },
                                        },
                                    },
                                },
                            },
                            ['P1_PLAYER_Starting_Base'] = GROUP {
                                Units = {
                                    ['UNIT_480'] = {
                                        type = 'ucb0303',
                                        ['Position'] = VECTOR3( 517, 216.442, 522 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_355'] = {
                                        type = 'ucb0701',
                                        ['Position'] = VECTOR3( 481, 216.178, 518 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_491'] = {
                                        type = 'ucb0101',
                                        ['Position'] = VECTOR3( 503, 216.668, 562 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_487'] = {
                                        type = 'ucb0101',
                                        ['Position'] = VECTOR3( 477, 216.668, 536 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_361'] = {
                                        type = 'ucb0701',
                                        ['Position'] = VECTOR3( 511, 216.175, 528 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_356'] = {
                                        type = 'ucb0701',
                                        ['Position'] = VECTOR3( 521, 216.175, 558 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_352'] = {
                                        type = 'ucb0001',
                                        ['Position'] = VECTOR3( 473, 218.025, 545 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_353'] = {
                                        type = 'ucb0002',
                                        ['Position'] = VECTOR3( 494, 222.257, 566 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_05'] = {
                                        type = 'ucb0102',
                                        ['Position'] = VECTOR3( 482, 216.668, 550 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_04'] = {
                                        type = 'ucb0102',
                                        ['Position'] = VECTOR3( 489, 216.668, 557 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_03'] = {
                                        type = 'ucb0801',
                                        ['Position'] = VECTOR3( 506, 216.618, 568 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_29'] = {
                                        type = 'ucb0801',
                                        ['Position'] = VECTOR3( 395.205, 209.052, 550.45 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_16'] = {
                                        type = 'ucb0801',
                                        ['Position'] = VECTOR3( 471, 216.618, 533 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_54'] = {
                                        type = 'ucb0702',
                                        ['Position'] = VECTOR3( 512, 216.167, 521 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                    ['UNIT_31'] = {
                                        type = 'ucb0702',
                                        ['Position'] = VECTOR3( 518, 216.167, 527 ),
                                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                                    },
                                },
                            },
                            ['P1_PLAYER_Gate'] = {
                                type = 'scb3101',
                                ['Position'] = VECTOR3( 396.5, 208.607, 577.5 ),
                                ['Orientation'] = VECTOR3( 0, 4.712, 0 ),
                            },
                        },
                    },
                    ['INTRONIS_CommanderTransport'] = {
                        type = 'uca0901',
                        ['Position'] = VECTOR3( 662.5, 224.478, 346.5 ),
                        ['Orientation'] = VECTOR3( 0, 5.325, 0 ),
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
                    ['P1_PLAYER_Exp_Brain'] = {
                        type = 'ucx0115',
                        ['Position'] = VECTOR3( 475, 217.354, 564 ),
                        ['Orientation'] = VECTOR3( 0, 0, 0 ),
                    },
                    ['INITIAL'] = GROUP {
                        Units = {
                        },
                    },
                },
            },
        },
    },
}
