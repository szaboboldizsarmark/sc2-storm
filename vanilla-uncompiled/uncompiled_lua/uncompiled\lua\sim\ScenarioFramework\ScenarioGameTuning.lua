--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- WARNING: THIS IS AN EXPORTED OUTPUT FILE ONLY
-- Any edits made directly to this file will be lost - see Campaign Design
-- for proper methods of data setting.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameTuning.lua
--  Author(s):  Brian Fricks
--  Summary  :  Data used for operation tuning.
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  Color Data - used for all campaign armies
color_UEF_PLAYER = {'FF12369c','FFedb816','FF2a4eb0',}
color_ILL_PLAYER = {'FF0b610b','FFa2b0a2','FF0b610b',}
color_CYB_PLAYER = {'FF9d1111','FFcecece','FF9d1111',}
color_GEN_ARMY01 = {'FFd3d350','FFFFFFFF','FFd3d350',}
color_GEN_ARMY02 = {'FF735858','FFFFFFFF','FF735858',}
color_GEN_ARMY03 = {'FF828caf','FFFFFFFF','FF828caf',}

color_TUT_ALLY01 = {'FF0f6496','FFce9d07','FF0f6496',}
color_TUT_ENEM01 = {'FFc8140a','FFFFFFFF','FFc8140a',}

color_UEF_ENEM01_U05 = {'FF224a16','FFd2791a','FFd2791a',}
color_UEF_ENEM01_I03 = {'FF29458e','FFce9d07','FF29458e',}
color_UEF_ENEM01_I04 = {'FF29458e','FFce9d07','FF29458e',}
color_UEF_ENEM02_I04 = {'FF29458e','FFce9d07','FF29458e',}
color_UEF_ENEM01_I06 = {'FF0e72a5','FFea7e0a','FF0e72a5',}

color_ILL_GUARDIAN_C03 = {'FFebba24','FFa2b0a2','FFebba24',}
color_ILL_GUARDIAN_C04 = {'FFebba24','FFa2b0a2','FFebba24',}
color_ILL_GUARDIAN_C05 = {'FFebba24','FFa2b0a2','FFebba24',}

color_ILL_ENEM01_I02 = {'FFb81212','FFa2b0a2','FFb81212',}
color_ILL_ENEM01_I05 = {'FFb81212','FFa2b0a2','FFb81212',}
color_ILL_ENEM01_I06 = {'FFebba24','FFa2b0a2','FFebba24',}

color_CYB_ENEM01_I01 = {'FF9d1111','FFcecece','FF9d1111',}
color_CYB_ENEM01_I06 = {'FF9d1111','Ffcecece','FF9d1111',}

color_RODGERS = {'FF224a16','FFd2791a','FFd2791a',}
color_GREER = {'FF1e3c5a','FFf1d378','FF1e3c5a',}
color_GAUGE = {'FFebba24','FF000000','FFebba24',}
color_COLEMAN = {'FF224a16','FFd2791a','FF67c04d',}
color_ZOE = {'FFac8307','FF1c1c1c','FFac8307',}
color_FBOY_ALLY = {'FF254873','FF888fa2','FF254873',}
color_FBOY_ENEM = {'FF433f20','FFe8b311','FF433f20',}
color_FBOY_FACTORY = {'FF86857e','FF050c22','FF86857e',}
color_DINO_C03 = {'FF555f19','FFFFFFFF','FF555f19',}
color_ARTIFACT_C06 = {'FFc0580b','FF0f6496','FFc0580b',}
color_ROGUE_C02 = {'FFd8a50d','FF1c1c1c','FFd8a50d',}

color_CIV_U01 = {'FF777e91','FF2b3b76','FF777e91',}
color_CIV_U04 = {'FFa99887','FFa99887','FFa99887',}
color_CIV_U05 = {'FF0b610b','FFa2b0a2','FF86be76',}
color_CIV_I01 = {'FF94761c','FFa2b0a2','FF94761c',}
color_CIV_I02 = {'FF3a3e39','FF9ca39b','FF3a3e39',}
color_CIV_I03 = {'FF2f4f2f','FF2b2408','FF2f4f2f',}
color_CIV_I05 = {'FF86be76','FFa2b0a2','FF86be76',}
color_CIV_C03 = {'FFd3d350','FFFFFFFF','FFd3d350',}

-----------------------------------------------------------------------------
-- Global Buff Data
U01_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff04", PC_NORM = "debuff01", PC_HARD = "buff03", XB_EASY = "debuff05", XB_NORM = "debuff02", XB_HARD = "buff02", }
U02_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff04", XB_EASY = "debuff04", XB_NORM = "debuff02", XB_HARD = "buff03", }
U02_ARMY_ALLY01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff04", XB_EASY = "debuff04", XB_NORM = "debuff02", XB_HARD = "buff03", }
U03_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff02", PC_NORM = "buff01", PC_HARD = "buff05", XB_EASY = "debuff03", XB_NORM = "debuff01", XB_HARD = "buff03", }
U04_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff02", PC_NORM = "buff01", PC_HARD = "buff05", XB_EASY = "debuff03", XB_NORM = nil, XB_HARD = "buff04", }
U04_ARMY_EXP01_BUFFS = { PC_EASY = nil, PC_NORM = nil, PC_HARD = nil, XB_EASY = nil, XB_NORM = nil, XB_HARD = nil, }
U04_ARMY_EXPENEM_BUFFS = { PC_EASY = "debuff02", PC_NORM = "buff01", PC_HARD = "buff05", XB_EASY = "debuff03", XB_NORM = nil, XB_HARD = "buff04", }
U04_ARMY_EXPALLY_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff04", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
U05_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff04", }
U06_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff04", }
U06_ARMY_REACTOR_BUFFS = { PC_EASY = nil, PC_NORM = nil, PC_HARD = nil, XB_EASY = nil, XB_NORM = nil, XB_HARD = nil, }
U06_ARMY_ALLY01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff04", }

I01_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff04", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I02_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff04", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I03_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff04", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I04_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I04_ARMY_ENEM02_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I04_ARMY_ALLY01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I05_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I05_ARMY_ALLY01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
I06_ARMY_UEF01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff07", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff04", }
I06_ARMY_ILLUM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff07", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff04", }
I06_ARMY_CYBRAN01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff07", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff04", }
I06_ARMY_ALLY01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff07", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff04", }

C01_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff07", XB_NORM = "debuff04", XB_HARD = "buff03", }
C02_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = "buff01", PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
C03_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff03", PC_NORM = nil, PC_HARD = "buff05", XB_EASY = "debuff04", XB_NORM = "debuff01", XB_HARD = "buff03", }
C04_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff04", PC_NORM = nil, PC_HARD = "buff06", XB_EASY = "debuff05", XB_NORM = "debuff01", XB_HARD = "buff04", }
C04_ARMY_ALLYUEF_BUFFS = { PC_EASY = "debuff04", PC_NORM = nil, PC_HARD = "buff06", XB_EASY = "debuff05", XB_NORM = "debuff01", XB_HARD = "buff04", }
C04_ARMY_ALLYILL_BUFFS = { PC_EASY = "debuff04", PC_NORM = nil, PC_HARD = "buff06", XB_EASY = "debuff05", XB_NORM = "debuff01", XB_HARD = "buff04", }
C05_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff04", PC_NORM = nil, PC_HARD = "buff07", XB_EASY = "debuff05", XB_NORM = "debuff01", XB_HARD = "buff04", }
C06_ARMY_ENEM01_BUFFS = { PC_EASY = "debuff05", PC_NORM = nil, PC_HARD = "buff09", XB_EASY = "debuff06", XB_NORM = "debuff01", XB_HARD = "buff05", }
C06_ARMY_ART_BUFFS = { PC_EASY = "debuff05", PC_NORM = nil, PC_HARD = "buff09", XB_EASY = "debuff06", XB_NORM = "debuff01", XB_HARD = "buff05", }

-----------------------------------------------------------------------------
-- Score Data Tables
U01_SCORE = {TimeScale = {900,800,700,600,500,},CombatScale = {30,40,55,65,70,},ObjectivesScale = {1,2,3,3,4,},ResearchScale = {6,7,8,9,10,},}
U02_SCORE = {TimeScale = {2400,1800,1600,1400,1200,},CombatScale = {100,160,230,280,330,},ObjectivesScale = {1,2,3,4,5,},ResearchScale = {6,8,12,20,25,},}
U03_SCORE = {TimeScale = {2600,2200,2000,1800,1600,},CombatScale = {100,115,130,150,170,},ObjectivesScale = {1,2,3,4,5,},ResearchScale = {6,10,16,24,30,},}
U04_SCORE = {TimeScale = {2600,2400,2200,2000,1800,},CombatScale = {200,220,240,270,300,},ObjectivesScale = {1,2,3,4,5,},ResearchScale = {6,12,20,32,40,},}
U05_SCORE = {TimeScale = {2400,2200,2000,1800,1600,},CombatScale = {600,700,800,900,1000,},ObjectivesScale = {1,2,3,3,4,},ResearchScale = {7,15,25,40,50,},}
U06_SCORE = {TimeScale = {3600,3200,2800,2400,2000,},CombatScale = {500,535,570,610,650,},ObjectivesScale = {1,2,3,3,4,},ResearchScale = {7,20,35,58,70,},}

I01_SCORE = {TimeScale = {1200,1200,1200,1200,1200,},CombatScale = {90,90,90,90,90,},ObjectivesScale = {1,2,2,2,3,},ResearchScale = {8,11,14,17,20,},}
I02_SCORE = {TimeScale = {2100,1950,1800,1650,1500,},CombatScale = {320,340,360,380,400,},ObjectivesScale = {1,2,3,3,4,},ResearchScale = {8,12,16,22,26,},}
I03_SCORE = {TimeScale = {2100,1950,1800,1650,1500,},CombatScale = {100,120,140,160,180,},ObjectivesScale = {1,2,3,3,4,},ResearchScale = {8,12,16,25,30,},}
I04_SCORE = {TimeScale = {2800,2600,2400,2200,2000,},CombatScale = {280,320,350,375,400,},ObjectivesScale = {1,1,1,1,2,},ResearchScale = {8,16,24,34,40,},}
I05_SCORE = {TimeScale = {2600,2400,2200,2000,1800,},CombatScale = {180,220,250,275,300,},ObjectivesScale = {1,2,2,2,3,},ResearchScale = {8,18,28,47,54,},}
I06_SCORE = {TimeScale = {3900,3600,3300,3000,2700,},CombatScale = {400,500,600,750,900,},ObjectivesScale = {1,2,2,2,3,},ResearchScale = {8,20,32,60,70,},}

C01_SCORE = {TimeScale = {1800,1800,1800,1800,1800,},CombatScale = {550,620,650,675,700,},ObjectivesScale = {1,2,3,3,4,},ResearchScale = {10,14,18,26,30,},}
C02_SCORE = {TimeScale = {2600,2400,2200,2000,1800,},CombatScale = {320,420,500,580,700,},ObjectivesScale = {1,2,2,2,3,},ResearchScale = {10,15,20,30,35,},}
C03_SCORE = {TimeScale = {1800,1725,1650,1575,1500,},CombatScale = {280,320,350,375,400,},ObjectivesScale = {1,2,3,4,5,},ResearchScale = {10,16,22,34,40,},}
C04_SCORE = {TimeScale = {3600,3300,3000,2600,2400,},CombatScale = {220,320,400,450,500,},ObjectivesScale = {1,2,2,2,3,},ResearchScale = {10,18,26,42,50,},}
C05_SCORE = {TimeScale = {2600,2400,2200,2000,1800,},CombatScale = {150,220,250,275,300,},ObjectivesScale = {1,2,2,2,3,},ResearchScale = {10,20,30,50,60,},}
C06_SCORE = {TimeScale = {3900,3600,3300,3000,2700,},CombatScale = {500,800,1000,1100,1200,},ObjectivesScale = {1,2,2,2,3,},ResearchScale = {10,22,34,58,70,},}

-----------------------------------------------------------------------------
--  Bonus Research Point Rewards
U01_ZZ_EXTRA_JUMPSTART_RESEARCH = 3
U01_M1_obj10_SURV_PART1 = 3
U01_H1_obj10_SURV_PART1 = 5
U02_S2_obj10_KILL_ECONOMY = 5
U02_M1_obj10_KILL_STRUCTURES = 3
U02_M1_obj20_KILL_GSHIPS = 3
U02_H1_obj10_MAKE_NWMASS = 5
U02_ZZ_EXTRA_JUMPSTART_RESEARCH = 3
U03_S1_obj10_KILL_KRAKKEN = 5
U03_M1_obj10_MAKE_MASS = 5
U03_H1_obj10_MAKE_ATLANTIS = 5
U04_S1_obj10_KILL_FATBOYS = 3
U04_S2_obj10_TAKE_SOUTHEAST = 5
U04_S3_obj10_TAKE_NORTHWEST = 5
U05_M1_obj10_SURV_PART1 = 5
U05_M2_obj10_KILL_CDR = 5
U05_M3_obj10_KILL_NUKES = 5
U05_H1_obj10_MAKE_EXPS = 5
U06_M1_obj10_HELP_GREER = 5
U06_M2_obj10_KILL_RELAYS = 5
U06_H1_obj10_MAKE_NUKE = 5
U06_H2_obj10_STOP_KRIPTORS = 5

I01_S1_obj10_KILL_SOULRIPPER = 5
I02_M1_obj10_KILL_WAVE1 = 5
I03_S1_obj10_DROP_GATE = 5
I03_S3_obj10_KILL_SHIELDS = 5
I03_H1_obj10_TAKE_HID1 = 5
I03_H2_obj10_TAKE_HID2 = 5
I04_H1_obj10_MAKE_EXPS = 5
I04_ZZ_EXTRA_KILL_CDR1 = 5
I05_S1_obj10_TAKE_MASS = 5
I05_S2_obj10_TAKE_TEMPLE = 3
I05_H1_obj10_MAKE_SUPERACU = 5
I06_H2_obj10_MAKE_DARKENOID = 5
I06_ZZ_EXTRA_KILL_CDR1 = 5
I06_ZZ_EXTRA_KILL_CDR2 = 5

C01_S2_obj10_MAKE_SHIELDS = 5
C01_H1_obj10_SURV_TIMED = 5
C02_H1_obj10_TAKE_ROGUE = 5
C03_M1_obj10_SURV_PART1 = 5
C03_H1_obj10_TAKE_ALLTECH = 5
C04_ZZ_EXTRA_KILL_CDR1 = 5
C04_ZZ_EXTRA_KILL_CDR2 = 5
C04_H1_obj10_MAKE_SOULRIPPER = 5
C05_ZZ_EXTRA_KILL_DESTROYERS = 3
C05_S1_obj10_KILL_CARRIERS = 5
C05_H1_obj10_MAKE_KRAKKEN = 5
C06_ZZ_EXTRA_KILL_COIL1 = 5
C06_ZZ_EXTRA_KILL_COIL2 = 5
C06_ZZ_EXTRA_KILL_COIL3 = 5
C06_S1_obj10_KILL_COIL4 = 5

-----------------------------------------------------------------------------
--  UEF Campaign Armies
U01_PLAYER = {color = color_UEF_PLAYER,unitCap = 150,mass = 940,energy = 2150,research = 0,opID = 101,scoreData = U01_SCORE,}
U02_PLAYER = {color = color_UEF_PLAYER,unitCap = 150,mass = 940,energy = 2150,research = 0,opID = 102,scoreData = U02_SCORE,}
U03_PLAYER = {color = color_UEF_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 6,opID = 103,scoreData = U03_SCORE,}
U04_PLAYER = {color = color_UEF_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 12,opID = 104,scoreData = U04_SCORE,}
U05_PLAYER = {color = color_UEF_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 16,opID = 105,scoreData = U05_SCORE,}
U06_PLAYER = {color = color_UEF_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 22,opID = 106,scoreData = U06_SCORE,}

U01_ARMY_ENEM01 = {color = color_GAUGE,unitCap = 300,massBoost = 0,energyBoost = 0,buffs = U01_ARMY_ENEM01_BUFFS,completedResearch = {},}
U02_ARMY_ENEM01 = {color = color_GAUGE,unitCap = 300,massBoost = 999999,energyBoost = 999999,buffs = U02_ARMY_ENEM01_BUFFS,completedResearch = {'CAU_GUNSHIP','CLU_ADV',},}
U02_ARMY_ALLY01 = {color = color_COLEMAN,unitCap = 300,massBoost = 999999,energyBoost = 999999,buffs = U02_ARMY_ALLY01_BUFFS,completedResearch = {},}
U03_ARMY_ENEM01 = {color = color_GAUGE,unitCap = 300,massBoost = 999999,energyBoost = 999999,buffs = U03_ARMY_ENEM01_BUFFS,completedResearch = {'CLU_MISSILETRUCK','CLU_ADV','CAU_GUNSHIP',},}
U04_ARMY_ENEM01 = {color = color_COLEMAN,unitCap = 400,massBoost = 0,energyBoost = 0,buffs = U04_ARMY_ENEM01_BUFFS,completedResearch = {'UAU_GUNSHIP',},}
U04_ARMY_EXP01 = {color = color_FBOY_FACTORY,unitCap = 40,massBoost = 999999,energyBoost = 999999,buffs = U04_ARMY_EXP01_BUFFS,completedResearch = {'ULU_FATBOY',},}
U04_ARMY_EXPENEM = {color = color_FBOY_ENEM,unitCap = 40,massBoost = 999999,energyBoost = 999999,buffs = U04_ARMY_EXPENEM_BUFFS,completedResearch = {'ULU_FATBOY',},}
U04_ARMY_EXPALLY = {color = color_FBOY_ALLY,unitCap = 100,massBoost = 999999,energyBoost = 999999,buffs = U04_ARMY_EXPALLY_BUFFS,completedResearch = {'ULU_FATBOY',},}
U05_ARMY_ENEM01 = {color = color_UEF_ENEM01_U05,unitCap = 300,massBoost = 999999,energyBoost = 999999,buffs = U05_ARMY_ENEM01_BUFFS,completedResearch = {'UAU_GUNSHIP','ULU_ASSAULTBOT','ULU_ARTILLERY','ULU_SHIELDGENERATOR',},}
U06_ARMY_ENEM01 = {color = color_RODGERS,unitCap = 425,massBoost = 999999,energyBoost = 999999,buffs = U06_ARMY_ENEM01_BUFFS,completedResearch = {'UAU_GUNSHIP','ULU_ASSAULTBOT','ULU_ARTILLERY','ULU_SHIELDGENERATOR','ULU_ANTIMISSILE','ULU_KINGKRIPTOR','ULU_FATBOY','UBU_DISRUPTORSTATION','UBU_TMLICBMCOMBODEFENSE','ULU_SHIELDGENERATOR','UAP_SHIELDS','UBP_AAUPGRADE','ULP_AA','UAB_TRANSPORTCAPACITY',},}
U06_ARMY_REACTOR = {color = color_RODGERS,unitCap = 40,massBoost = 999999,energyBoost = 999999,buffs = U06_ARMY_REACTOR_BUFFS,completedResearch = {},}
U06_ARMY_ALLY01 = {color = color_GREER,unitCap = 300,massBoost = 999999,energyBoost = 999999,buffs = U06_ARMY_ALLY01_BUFFS,completedResearch = {},}


-----------------------------------------------------------------------------
--  Illuminate Campaign Armies
I01_PLAYER = {color = color_ILL_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 0,opID = 201,scoreData = I01_SCORE,}
I02_PLAYER = {color = color_ILL_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 5,opID = 202,scoreData = I02_SCORE,}
I03_PLAYER = {color = color_ILL_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 10,opID = 203,scoreData = I03_SCORE,}
I04_PLAYER = {color = color_ILL_PLAYER,unitCap = 300,mass = 1590,energy = 3500,research = 15,opID = 204,scoreData = I04_SCORE,}
I05_PLAYER = {color = color_ILL_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 20,opID = 205,scoreData = I05_SCORE,}
I06_PLAYER = {color = color_ILL_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 25,opID = 206,scoreData = I06_SCORE,}

I01_ARMY_ENEM01 = {color = color_CYB_ENEM01_I01,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = I01_ARMY_ENEM01_BUFFS,completedResearch = {'CAU_GUNSHIP',},}
I02_ARMY_ENEM01 = {color = color_ILL_ENEM01_I02,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = I02_ARMY_ENEM01_BUFFS,completedResearch = {'ILA_TELEPORT','ILU_ARMORENHANCER','ILU_ASSAULTBOT','ILU_ANTIMISSILE','IBU_SHIELDGENERATOR','IBU_TMLICBMCOMBODEFENSE',},}
I03_ARMY_ENEM01 = {color = color_UEF_ENEM01_I03,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = I03_ARMY_ENEM01_BUFFS,completedResearch = {'UAU_AC1000TERROR','ULU_SHIELDGENERATOR','UBU_TMLICBMCOMBODEFENSE','UAU_GUNSHIP','ULU_ASSAULTBOT',},}
I04_ARMY_ENEM01 = {color = color_UEF_ENEM01_I04,unitCap = 150,massBoost = 9999999,energyBoost = 9999999,buffs = I04_ARMY_ENEM01_BUFFS,completedResearch = {'UAU_GUNSHIP','UBU_SHIELDGENERATOR','UBU_TMLICBMCOMBODEFENSE','UBU_FORTIFIEDARTILLERY','UBU_NOAHUNITCANNON','UAP_SHIELDS','UAB_HEALTH',},}
I04_ARMY_ENEM02 = {color = color_UEF_ENEM02_I04,unitCap = 250,massBoost = 9999999,energyBoost = 9999999,buffs = I04_ARMY_ENEM02_BUFFS,completedResearch = {'UBU_SHIELDGENERATOR','UBU_TMLICBMCOMBODEFENSE','UBU_FORTIFIEDARTILLERY','ULU_ASSAULTBOT','UBU_NOAHUNITCANNON','ULB_HEALTH',},}
I04_ARMY_ALLY01 = {color = color_GAUGE,unitCap = 150,massBoost = 9999999,energyBoost = 9999999,buffs = I04_ARMY_ALLY01_BUFFS,completedResearch = {'CBU_SHIELDGENERATOR','CLU_MEGALITHII','CLB_RATEOFFIRE','CLB_MOVESPEED','CLP_TRIARMORHALFSPEED','CLB_RADAR','CLB_HYPERALLOYS','CLU_ADV','CLU_MISSILETRUCK','CLB_REGENERATION',},}
I05_ARMY_ENEM01 = {color = color_ILL_ENEM01_I05,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = I05_ARMY_ENEM01_BUFFS,completedResearch = {'ILU_URCHINOW','ILU_AIRNOMO','IAU_GUNSHIP',},}
I05_ARMY_ALLY01 = {color = color_GAUGE,unitCap = 150,massBoost = 9999999,energyBoost = 9999999,buffs = I05_ARMY_ALLY01_BUFFS,completedResearch = {},}
I06_ARMY_UEF01 = {color = color_UEF_ENEM01_I06,unitCap = 150,massBoost = 9999999,energyBoost = 9999999,buffs = I06_ARMY_UEF01_BUFFS,completedResearch = {'UBU_SHIELDGENERATOR','UAU_GUNSHIP','UAU_AC1000TERROR','UBU_TMLICBMCOMBODEFENSE','UBU_FORTIFIEDARTILLERY',},}
I06_ARMY_ILLUM01 = {color = color_ILL_ENEM01_I06,unitCap = 200,massBoost = 9999999,energyBoost = 9999999,buffs = I06_ARMY_ILLUM01_BUFFS,completedResearch = {'IAU_CZAR','ILU_ASSAULTBOT','ILU_ANTIMISSILE','IBU_SHIELDGENERATOR','IBU_TMLICBMCOMBODEFENSE','IAU_GUNSHIP','IBU_TML','ILU_UNIVERSALCOLOSSUS','ILU_URCHINOW',},}
I06_ARMY_CYBRAN01 = {color = color_CYB_ENEM01_I06,unitCap = 200,massBoost = 9999999,energyBoost = 9999999,buffs = I06_ARMY_CYBRAN01_BUFFS,completedResearch = {'CLU_MEGALITHII','CLU_ADV','CBU_SHIELDGENERATOR','CBU_MISSILELAUNCHDEFENSE','CAU_GUNSHIP','CLP_SHIELD',},}
I06_ARMY_ALLY01 = {color = color_UEF_PLAYER,unitCap = 100,massBoost = 9999999,energyBoost = 9999999,buffs = I06_ARMY_ALLY01_BUFFS,completedResearch = {'UBU_SHIELDGENERATOR','ULU_ASSAULTBOT',},}


-----------------------------------------------------------------------------
--  Cybran Campaign Armies
C01_PLAYER = {color = color_CYB_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 0,opID = 301,scoreData = C01_SCORE,}
C02_PLAYER = {color = color_CYB_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 5,opID = 302,scoreData = C02_SCORE,}
C03_PLAYER = {color = color_CYB_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 10,opID = 303,scoreData = C03_SCORE,}
C04_PLAYER = {color = color_CYB_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 15,opID = 304,scoreData = C04_SCORE,}
C05_PLAYER = {color = color_CYB_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 20,opID = 305,scoreData = C05_SCORE,}
C06_PLAYER = {color = color_CYB_PLAYER,unitCap = 300,mass = 940,energy = 2150,research = 25,opID = 306,scoreData = C06_SCORE,}

C01_ARMY_ENEM01 = {color = color_GAUGE,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = C01_ARMY_ENEM01_BUFFS,completedResearch = {'CAB_HEALTH','CAP_SHIELDS','CAB_REGENERATION','CLB_HYPERALLOYS','CLP_SHIELD','CLB_RATEOFFIRE','CAB_RATEOFFIRE','CLB_MOVESPEED','CLP_TRIARMORHALFSPEED',},}
C02_ARMY_ENEM01 = {color = color_ROGUE_C02,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = C02_ARMY_ENEM01_BUFFS,completedResearch = {},}
C03_ARMY_ENEM01 = {color = color_ILL_GUARDIAN_C03,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = C03_ARMY_ENEM01_BUFFS,completedResearch = {'ILU_URCHINOW','ILU_ASSAULTBOT','IBU_SHIELDGENERATOR','IBU_TMLICBMCOMBODEFENSE','CAU_GUNSHIP',},}
C04_ARMY_ENEM01 = {color = color_ILL_GUARDIAN_C04,unitCap = 390,massBoost = 9999999,energyBoost = 9999999,buffs = C04_ARMY_ENEM01_BUFFS,completedResearch = {'ILU_URCHINOW','ILU_ASSAULTBOT','IBU_SHIELDGENERATOR','IBU_TMLICBMCOMBODEFENSE','ILU_AIRNOMO','IAU_CZAR','IBU_TML','ILU_UNIVERSALCOLOSSUS','ILU_ARMORENHANCER','IBU_POWERDOME','ILB_BUILDTIME','IAU_GUNSHIP',},}
C04_ARMY_ALLYUEF = {color = color_UEF_PLAYER,unitCap = 95,massBoost = 9999999,energyBoost = 9999999,buffs = C04_ARMY_ALLYUEF_BUFFS,completedResearch = {'UBU_SHIELDGENERATOR','ULU_ASSAULTBOT','UBU_MASSCONVERTOR','UBU_TMLICBMCOMBODEFENSE',},}
C04_ARMY_ALLYILL = {color = color_ILL_PLAYER,unitCap = 115,massBoost = 9999999,energyBoost = 9999999,buffs = C04_ARMY_ALLYILL_BUFFS,completedResearch = {'IBU_SHIELDGENERATOR','IBU_TMLICBMCOMBODEFENSE','ILU_ARMORENHANCER','ILU_ASSAULTBOT','IBU_POWERDOME',},}
C05_ARMY_ENEM01 = {color = color_ILL_GUARDIAN_C05,unitCap = 300,massBoost = 9999999,energyBoost = 9999999,buffs = C05_ARMY_ENEM01_BUFFS,completedResearch = {'IBU_SHIELDGENERATOR','IBU_TMLICBMCOMBODEFENSE','CSU_BATTLESHIP','CSU_CARRIER','CSU_KRAKKEN','CSB_SEAMOVESPEED','CAU_GUNSHIP',},}
C06_ARMY_ENEM01 = {color = color_GAUGE,unitCap = 450,massBoost = 9999999,energyBoost = 9999999,buffs = C06_ARMY_ENEM01_BUFFS,completedResearch = {'CBU_SHIELDGENERATOR','CLU_MEGALITHII','CLU_ADV','CBU_MISSILELAUNCHDEFENSE','CAU_GUNSHIP','CLU_MISSILETRUCK','CLP_ENGINEERPD','CCB_HEALTH','CCA_OVERCHARGE','CBB_RATEOFFIRE','CBB_BUILDTIME','ILU_UNIVERSALCOLOSSUS','IAU_CZAR','CBU_UNITMAGNET','CAU_SOULRIPPERII','CAU_TRANSPORT','ILU_AIRNOMO','CBU_LONGRANGEARTILLERY','CSP_LANDWALKING',},}
C06_ARMY_ART = {color = color_ARTIFACT_C06,unitCap = 150,massBoost = 9999999,energyBoost = 9999999,buffs = C06_ARMY_ART_BUFFS,completedResearch = {},}
