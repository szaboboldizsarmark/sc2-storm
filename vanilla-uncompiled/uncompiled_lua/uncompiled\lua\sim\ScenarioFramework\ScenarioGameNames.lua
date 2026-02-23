--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameNames.lua
--  Author(s): Brian Fricks
--  Summary  : Simple List of Scenario Names and naming utils.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

---------------------------------------------------------------------
-- COMMANDERS:
-- convention:
--	CDR_XXXXXXX	- for all placed ACUs

-- Player Commanders:
CDR_Maddox		= LOC('<LOC CHARACTER_0000>Dominic Maddox') 			-- U01-U06, I06, C04
CDR_Thalia		= LOC('<LOC CHARACTER_0001>Thalia Kael')				-- I01-I06, C04
CDR_Ivan		= LOC('<LOC CHARACTER_0002>Ivan Brackman') 			-- C01-C06

-- Non-player Commanders:
CDR_Knox		= LOC('<LOC CHARACTER_0003>Commander Knox') 			-- C03
CDR_Burkett		= LOC('<LOC CHARACTER_0004>Commander Burkett') 		-- C04
CDR_Larson		= LOC('<LOC CHARACTER_0005>Commander Larson')		-- C04
CDR_Walker		= LOC('<LOC CHARACTER_0006>Commander Walker')		-- C04
CDR_Stockwell	= LOC('<LOC CHARACTER_0007>Commander Stockwell')		-- C05
CDR_Gauge		= LOC('<LOC CHARACTER_0008>William Gauge')			-- U03, I04, I05, I06, C01, C06
CDR_Mosley		= LOC('<LOC CHARACTER_0009>Commander Mosley')		-- I04
CDR_Kita		= LOC('<LOC CHARACTER_0010>Commander Kita')			-- I04
CDR_Haen		= LOC('<LOC CHARACTER_0011>Commander Haen')			-- I06
CDR_Hazelton	= LOC('<LOC CHARACTER_0012>Commander Hazelton')		-- I06
CDR_Teller		= LOC('<LOC CHARACTER_0013>Commander Teller')		-- I06
CDR_Coleman		= LOC('<LOC CHARACTER_0014>Commander Coleman')		-- U02, U04
CDR_Lynch		= LOC('<LOC CHARACTER_0015>Commander Lynch')			-- U05
CDR_Greer		= LOC('<LOC CHARACTER_0016>Commander Greer')			-- U06

-- Added for LOC purposes
Sergeant_Daxil	= LOC('<LOC CHARACTER_0017>Sergeant Daxil')
Zoe_Snyder		= LOC('<LOC CHARACTER_0018>Dr. Zoe Snyder')
Colonel_Rodgers	= LOC('<LOC CHARACTER_0019>Colonel Rodgers')
Annika_Maddox	= LOC('<LOC CHARACTER_0020>Annika Maddox')
Jaran_Kael		= LOC('<LOC CHARACTER_0021>Jaran Kael')
Doctor_Brackman	= LOC('<LOC CHARACTER_0022>Dr. Brackman')
COMPUTER		= LOC('<LOC CHARACTER_0023>COMPUTER')
ACU				= LOC('<LOC CHARACTER_0024>ACU')

---------------------------------------------------------------------
-- SPECIAL NAMED UNITS:
-- convention:
--	UNIT_XXXXXXX - for all placed and named special units
--	unlike proper names, we will want to LOC tag all of these in case it matters
--

-- Scenario Units (needs to match the corresponding unit .bp - thus the naming convention)
UNIT_SCB1102 = LOC('<LOC SCENARIO_0131>Main Gate')
UNIT_SCB1103 = LOC('<LOC SCENARIO_0132>Gate Control Mechanism')
UNIT_SCB1601 = LOC('<LOC SCENARIO_0133>Reactor Core')
UNIT_SCB1602 = LOC('<LOC SCENARIO_0134>Reactor Relay Switch')
UNIT_SCB2101 = LOC('<LOC SCENARIO_0135>Naval Blockade')
UNIT_SCB2301 = LOC('<LOC SCENARIO_0136>Security Station')
UNIT_SCB2302 = LOC('<LOC SCENARIO_0137>Main Gate')
UNIT_SCB2303 = LOC('<LOC SCENARIO_0138>Prison Access Structure')
UNIT_SCB2304 = LOC('<LOC SCENARIO_0139>Gate Control Mechanism')
UNIT_SCB2501 = LOC('<LOC SCENARIO_0140>Science and Technology Center')
UNIT_SCB3101 = LOC('<LOC SCENARIO_0141>Brackman Teleporter')
UNIT_SCB3201 = LOC('<LOC SCENARIO_0142>Data Center')
UNIT_SCL3301 = LOC('<LOC SCENARIO_0143>Dinosaur')
UNIT_SCB3301 = LOC('<LOC SCENARIO_0144>Quantum Research Laboratories')
UNIT_SCB3601 = LOC('<LOC SCENARIO_0145>Power Coil')

-- Custom U04 needs
UNIT_U04_Factory_SW 	= LOC('<LOC SCENARIO_0146>Experimental Factory Alpha')
UNIT_U04_Factory_NW 	= LOC('<LOC SCENARIO_0147>Experimental Factory Charlie')
UNIT_U04_Factory_SE 	= LOC('<LOC SCENARIO_0148>Experimental Factory Bravo')

-- Custom U05 needs
UNIT_U05_MissileDefense	= LOC('<LOC SCENARIO_0149>Civilian Missile Defense')

-- Custom I05 needs
UNIT_I05_SpaceTemple	= LOC('<LOC SCENARIO_0150>Space Temple')

-- Custom C01 needs
UNIT_C01_ProtoBrain		= LOC('<LOC SCENARIO_0151>Proto Brain Complex')

-- Location References
LOCATION_Alpha			= LOC('<LOC SCENARIO_LOCATION_0000>Alpha')
LOCATION_Bravo			= LOC('<LOC SCENARIO_LOCATION_0001>Bravo')
LOCATION_Charlie		= LOC('<LOC SCENARIO_LOCATION_0002>Charlie')
LOCATION_Delta			= LOC('<LOC SCENARIO_LOCATION_0003>Delta')
LOCATION_North			= LOC('<LOC SCENARIO_LOCATION_0004>North')
LOCATION_South			= LOC('<LOC SCENARIO_LOCATION_0005>South')
LOCATION_East			= LOC('<LOC SCENARIO_LOCATION_0006>East')
LOCATION_West			= LOC('<LOC SCENARIO_LOCATION_0007>West')
LOCATION_Objective		= LOC('<LOC SCENARIO_LOCATION_0008>Objective Area')
LOCATION_Destination	= LOC('<LOC SCENARIO_LOCATION_0009>Destination Area')
LOCATION_Target			= LOC('<LOC SCENARIO_LOCATION_0010>Target Area')
LOCATION_Starting		= LOC('<LOC SCENARIO_LOCATION_0011>Starting Area')
LOCATION_Commander		= LOC('<LOC SCENARIO_LOCATION_0012>Commander Area')
LOCATION_LZ				= LOC('<LOC SCENARIO_LOCATION_0013>Landing Zone')
LOCATION_Base			= LOC('<LOC SCENARIO_LOCATION_0014>Base')
