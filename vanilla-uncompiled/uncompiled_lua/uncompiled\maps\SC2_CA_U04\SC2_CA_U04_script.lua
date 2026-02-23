---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_U04/SC2_CA_U04_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_U04/SC2_CA_U04_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_U04/SC2_CA_U04_OpNIS.lua')
local ScenarioUtils			= import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework		= import('/lua/sim/ScenarioFramework.lua')
local ScenarioGameSetup		= import('/lua/sim/ScenarioFramework/ScenarioGameSetup.lua')
local ScenarioGameTuning	= import('/lua/sim/ScenarioFramework/ScenarioGameTuning.lua')
local ScenarioGameEvents	= import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua')
local ScenarioGameCleanup	= import('/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua')
local ScenarioGameNames		= import('/lua/sim/ScenarioFramework/ScenarioGameNames.lua')
local ScenarioPlatoonAI		= import('/lua/AI/ScenarioPlatoonAI.lua')
local SimObjectives			= import('/lua/sim/SimObjectives.lua')
local SimPingGroups			= import('/lua/sim/SimPingGroup.lua')
local RandomFloat			= import('/lua/system/utilities.lua').GetRandomFloat
local RandomInt				= import('/lua/system/utilities.lua').GetRandomInt
local TransportUtils		= import('/lua/sim/ScenarioFramework/ScenarioGameUtilsTransport.lua')

---------------------------------------------------------------------
-- COMMON SCENARIO FRAMEWORK FUNCTIONS:
---------------------------------------------------------------------
-- PROTECT		== prevent damage, death, reclaim, capture, etc...
-- UNPROTECT	== allow damage, death, reclaim, capture, etc...
-- RESTRICT		== allow damage but prevent death. ***USE WITH CAUTION*** - review notes in: ScenarioFramework.lua
-- FORCE		== force death using the IssueKillSelf command.
-- DESTROY		== directly destroy - use for special cases only.

local ProtectUnit			= ScenarioFramework.ProtectUnit			-- usage example: ProtectUnit(unit)
local ProtectGroup			= ScenarioFramework.ProtectGroup		-- usage example: ProtectGroup(group)
local UnProtectUnit			= ScenarioFramework.UnProtectUnit		-- usage example: UnProtectUnit(unit)
local UnProtectGroup		= ScenarioFramework.UnProtectGroup		-- usage example: UnProtectGroup(group)
local RestrictUnitDeath		= ScenarioFramework.RestrictUnitDeath	-- usage example: RestrictUnitDeath(unit)
local RestrictGroupDeath	= ScenarioFramework.RestrictGroupDeath	-- usage example: RestrictGroupDeath(group)
local ForceUnitDeath		= ScenarioFramework.ForceUnitDeath		-- usage example: ForceUnitDeath(unit)
local ForceGroupDeath		= ScenarioFramework.ForceGroupDeath		-- usage example: ForceGroupDeath(group)
local DestroyUnit			= ScenarioFramework.DestroyUnit			-- usage example: DestroyUnit(unit)
local DestroyGroup			= ScenarioFramework.DestroyGroup		-- usage example: DestroyGroup(group)
local Defeat				= ScenarioGameCleanup.Defeat			-- usage example: Defeat()
local PlayerDeath			= ScenarioGameCleanup.PlayerDeath		-- usage example: PlayerDeath(playerUnit)

---------------------------------------------------------------------
-- GLOBAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
ScenarioInfo.ARMY_PLAYER = 1
ScenarioInfo.ARMY_ENEM01 = 2
ScenarioInfo.ARMY_EXP01 = 3
ScenarioInfo.ARMY_EXPENEM = 4
ScenarioInfo.ARMY_EXPALLY = 5

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.NWFatboySequenceEnabled 		= false
ScenarioInfo.SECaptureObjectiveComplete 	= false
ScenarioInfo.NWTimerFinished				= false
ScenarioInfo.InitialFatboysKilled			= false
ScenarioInfo.P1_TransportAttackInProgress	= false
ScenarioInfo.SouthWestGantryEnabled			= false

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_EXP01 = ScenarioInfo.ARMY_EXP01
local ARMY_EXPENEM = ScenarioInfo.ARMY_EXPENEM
local ARMY_EXPALLY = ScenarioInfo.ARMY_EXPALLY

local AlliedFatboyCallbackCount 	= 0
local AlliedFatboyDestroyedCount 	= 0
local EnemyFatboyDestroyedCount		= 0
local AlliedFatboyDamagedCount 		= 0
local NorthwestAllyFatboyVOCount 	= 0
local NorthwestEnemyFatboyVOCount 	= 0
local SoutheastAllyFatboyVOCount 	= 0
local SoutheastEnemyFatboyVOCount 	= 0
local GantryCaptureVOCount			= 0
local TransportAttackCount			= 0
local AllyFatboysKilled_VO			= 0

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local NWFatboy_EnableDelay			= 260	-- Failsafe delay from start of map for NW fatboy production to begins, if player doesnt complete objectives in time.
local SEFatboy_FailsafeDelay		= 300	-- after player kills the 2 initial SE fatboys, delay before enable SE fatboy production.

local CaptureGantryUnitMin_Player	= 5		-- number of units Player must keep in gantry capture area to take it over.
local CaptureGantryUnitMin_Enemy	= 8		-- number of units Enemy must keep in gantry capture area to take it over.

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
-- Initial SE Gantry Defense:		Initial groups of air and land defense at SE gantry, size tuned in editor. F3 Search, Air: ASEGD, Land: LSED
--									One-off, unmaintained by OpAI. Created in separate INTRONIS_... functions.
--
--
-- Initial NW Gantry Defense:		Initial groups of air and land defense at NW Gantry, size tuned in editor. F3 Search: NWGD
--									One-off, unmaintained by OpAI. Created in OnPopulate()
--
--
-- Enemy Gunship Patrols:			Initial groups are created in OnPopulate(), size tuned in editor. F3 Search: IGSP
--									Replenishment: Initial groups are passed to OpAIs, in P1_SetupEnemyOpAI().
--									Size of replenishment platoons from OpAI can be tuned in that function, via SetChildCount.
--									NOTE: in editor, see folder "P1>Air_Patrols>Gunships_for_Lanes" for list of groups.
--									NOTE: This includes the gunship patrols to the east of player at start (tho not the mixed air
--									patrol that is over the SE gantry proper).
--
--
-- One-off Enemy Gunship Patrols:	Initial gunship patrols, added at start, but not maintained. F3 Search: OEGP
--									One-off, unmaintained by OpAI. Created in OnPopulate()
--
--
-- Enemy Base Defense Patrols:		Initial groups are created in OnPopulate(), size tuned in editor. F3 Search: EBDP
--									Replenishment: Initial groups are passed to OpAIs, in P1_SetupEnemyOpAI().
--									Size/makeup of replenishment currently is pure adaptive.
--
--
-- base manager and opais:			Enemy base and OpAIs set up in: P1_SetupEnemyOpAI()
--									3 gantry bases and OpAIs set up in: GantryBasesSetup()

---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.5,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.U04_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.U04_ARMY_ENEM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_EXP01,		ScenarioGameTuning.U04_ARMY_EXP01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_EXPENEM,	ScenarioGameTuning.U04_ARMY_EXPENEM)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_EXPALLY,	ScenarioGameTuning.U04_ARMY_EXPALLY)
end

---------------------------------------------------------------------
function OnStart(self)
	ScenarioGameSetup.CAMPAIGN_OnStart()
end

---------------------------------------------------------------------
function OnInitCamera(scen)
	-- construct the data table
	local data = {
		funcSetup		= P1_Setup,				-- if valid, the function to be called while the load screen is up
		funcNIS			= OpNIS.NIS_OPENING,	-- if valid, the non-critical NIS sequence to be launched
		funcMain		= P1_Main,				-- if valid, the function to be called after the NIS
		areaStart		= 'AREA_1',				-- if valid, the area to be used for setting the starting playable area
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnInitCamera(data)
end

---------------------------------------------------------------------
-- PART 1:
---------------------------------------------------------------------
function P1_Setup()
	LOG('----- P1_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 1

	-- Intel for the NW area of the map, so enemy fatboys can see allied fatboys (otherwise, they are too weak against player/ally).
	ScenarioFramework.CreateIntelAtLocation(430, 'P1_ENEM01_IntelMarker_01', ARMY_EXPENEM, 'Radar')

	-- SE intel, on ramp. Permanent, but it should feel like its just an extension of the SE platform perma vis.
	ScenarioFramework.CreateIntelAtLocation(29.0, 'SEGantry_Ramp_VisLocation_Marker', ARMY_PLAYER, 'Vision', -1)

	-- These are used by the assignment function to decide which direction to send an attacking fatboy
	-- (towards the player, or towards the enemy)
	ScenarioInfo.NW_Gantry_Friendly = false
	ScenarioInfo.SE_Gantry_Friendly = false

	-- Set up the gantry areas and base managers etc
	GantryBasesSetup()

	------Enemy base and units ------
	ScenarioInfo.P1_EnemyCommander = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_EnemyCommander')
	ScenarioInfo.P1_EnemyCommander:SetCustomName(ScenarioGameNames.CDR_Coleman)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.P1_EnemyCommander, 4)
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.P1_EnemyCommander}, ScenarioUtils.ChainToPositions('P1_ENEM01_CDR_Patrol'))

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.P1_EnemyCommander:RemoveCommandCap('RULEUCC_Reclaim')

	-- CDR death damage triggers
	ScenarioFramework.CreateUnitDeathTrigger(P1_EnemyCommander_DeathDamage, ScenarioInfo.P1_EnemyCommander)

	-- Initial enemy base patrols. Keep a handle to hand into the repspective OpAI. <EBDP>
	ScenarioInfo.P1_ENEM01_InitAir_Def_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitAir_Def_01', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitAir_Def_01, 5)
	ScenarioInfo.P1_ENEM01_InitLand_Def_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitLand_Def_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitLand_Def_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitLand_Def_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitLand_Def_01, 'P1_ENEM01_MainBase_Def_Land_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitLand_Def_02, 'P1_ENEM01_MainBase_Def_Land_02')
	for k, v in ScenarioInfo.P1_ENEM01_InitAir_Def_01:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('P1_ENEM01_MainBase_Def_Air_01'))
	end

	-- Initial enemy gunship patrols. Need a handle to some to pass to the OpAIs that will renew the patrols. <IGSP>
	ScenarioInfo.P1_ENEM01_InitGunship_East_lower_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_East_lower_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitGunship_East_lower_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_East_lower_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_East_lower_01, 'P1_ENEM01_East_lower_Patrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_East_lower_02, 'P1_ENEM01_East_lower_Patrol_01')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_East_lower_01, 3)
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_East_lower_02, 3)


	ScenarioInfo.P1_ENEM01_InitGunship_East_upper_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_East_upper_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitGunship_East_upper_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_East_upper_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_East_upper_01, 'P1_ENEM01_East_upper_Patrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_East_upper_02, 'P1_ENEM01_East_upper_Patrol_01')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_East_upper_01, 4)
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_East_upper_02, 4)

	ScenarioInfo.P1_ENEM01_InitGunship_North_left_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_North_left_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitGunship_North_left_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_North_left_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_North_left_01, 'P1_ENEM01_North_left_Patrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_North_left_02, 'P1_ENEM01_North_left_Patrol_01')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_North_left_01, 5)
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_North_left_02, 5)

	ScenarioInfo.P1_ENEM01_InitGunship_North_right_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_North_right_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitGunship_North_right_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_North_right_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_North_right_01, 'P1_ENEM01_North_right_Patrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_North_right_02, 'P1_ENEM01_North_right_Patrol_01')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_North_right_01, 5)
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_North_right_02, 5)

	ScenarioInfo.P1_ENEM01_InitGunship_South_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_South_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitGunship_South_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_South_02', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_South_01, 3)
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_South_02, 3)

	ScenarioInfo.P1_ENEM01_InitGunship_West_lower_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_West_lower_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitGunship_West_lower_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_West_lower_02', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_West_lower_01, 3)
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_West_lower_02, 3)

	ScenarioInfo.P1_ENEM01_InitGunship_West_upper_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_West_upper_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_InitGunship_West_upper_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_West_upper_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_West_upper_01, 'P1_ENEM01_West_upper_Patrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_West_upper_02, 'P1_ENEM01_West_upper_Patrol_01')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_West_upper_01, 3)
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P1_ENEM01_InitGunship_West_upper_02, 3)

	-- one off patrols, unmaintained, to fill in some light areas as the player pushes their fatboys north and then east. <OEGP>
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_West_lower_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_West_LowerMid_Patrol_01')
	ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 2)
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitGunship_North_left_03', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_North_mid_Patrol_01')
	ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 2)

	-- Initial defenders at NW gantry <NWGD>
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_InitLand_NW_01')
	ScenarioInfo.P1_ENEM01_NWGantry_Init_Air_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_NWGantry_Init_Air_01', 'AttackFormation')
	for k, v in ScenarioInfo.P1_ENEM01_NWGantry_Init_Air_01:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('P1_ENEM01_NWGantry_AirPatrol_01'))
	end


	-- OpAIs and base from the enemy base:
	P1_SetupEnemyOpAI()

	-- Create intel for player use
	-- ScenarioFramework.CreateIntelAtLocation(450, 'PLAYER_Intel_Marker', ARMY_PLAYER, 'Radar') -- trying out more detailed, no-enemy-base, intel
	ScenarioFramework.CreateIntelAtLocation(325, 'PLAYER_Intel_Marker_NW', ARMY_PLAYER, 'Radar')
	ScenarioFramework.CreateIntelAtLocation(150, 'PLAYER_Intel_Marker_SW', ARMY_PLAYER, 'Radar')
	ScenarioFramework.CreateIntelAtLocation(183, 'PLAYER_Intel_Marker_SE', ARMY_PLAYER, 'Radar')
	ScenarioFramework.CreateIntelAtLocation(75, 'PLAYER_Intel_Marker_MID', ARMY_PLAYER, 'Radar')

	-- Civilian cannon fodder buildings. These are here mainly to take up space the player might
	-- be tempted to move into, and to give the enemy something dramatic to quickly chew through
	-- (both for the opening East gantry, and for the final teleport attack).
	local units = ScenarioUtils.CreateArmyGroup('ARMY_EXPALLY', 'P1_EXPALLY_CivBuildings_South')
	for k, v in units do v:SetIntelRadius('Vision', 40) end

	-- for the middle area, we want these structures to persist till the end when we nuke them.
	-- so, disable target so occasional passing gunships dont wander through the area.
	local units = ScenarioUtils.CreateArmyGroup('ARMY_EXPALLY', 'P1_EXPALLY_CivBuildings_Mid')
	for k, v in units do
		v:SetIntelRadius('Vision', 40)
		v:SetDoNotTarget(true)
	end

	-- Enemy gantry area building structures, and protect them. These are set up in a table
	-- with army info, for use in the gantry area capture sequences.
	ScenarioInfo.SE_Gantry_Buildings = {}
	for i = 1, 6 do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_EXP01', 'SE_GantryLocation_Building_' .. i)
		ProtectUnit(unit)

		local building = {}
		building.unit = unit
		building.army = ARMY_EXP01

		table.insert(ScenarioInfo.SE_Gantry_Buildings, building)
	end

	ScenarioInfo.NW_Gantry_Buildings = {}
	for i = 1, 6 do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_EXPENEM', 'NW_GantryLocation_Building_' .. i)
		ProtectUnit(unit)

		local building = {}
		building.unit = unit
		building.army = ARMY_EXPENEM

		table.insert(ScenarioInfo.NW_Gantry_Buildings, building)
	end

	ScenarioInfo.Player_Gantry_Buildings = {}
	for i = 1, 6 do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_EXP01', 'Player_GantryLocation_Building_' .. i)
		ProtectUnit(unit)

		local building = {}
		building.unit = unit
		building.army = ARMY_EXP01

		table.insert(ScenarioInfo.Player_Gantry_Buildings, building)
	end

	-- NIS Unit Setup
	ScenarioInfo.INTRONIS_UpperTrans = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Upper_Prop_Transport')
	ScenarioInfo.INTRONIS_Upper_Air = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'INTRONIS_Upper_Faux_AirUnits')
	ScenarioInfo.INTRONIS_FauxCDR = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Faux_PlayerCDR')

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'Player_CDR_Group')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Lower_Transport_01')
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Init_Eng')
	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Lower_Transport_02')

	-- setup for the player CDR
	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Permanent vis locs for the 3 gantry areas.
	ScenarioFramework.CreateVisibleAreaLocation( 60, ScenarioUtils.MarkerToPosition( 'GantryArea_01_Marker' ), -1, ArmyBrains[ARMY_PLAYER] )
	ScenarioFramework.CreateVisibleAreaLocation( 55, ScenarioUtils.MarkerToPosition( 'GantryArea_02_Marker' ), -1, ArmyBrains[ARMY_PLAYER] )
	ScenarioFramework.CreateVisibleAreaLocation( 55, ScenarioUtils.MarkerToPosition( 'GantryArea_03_Marker' ), -1, ArmyBrains[ARMY_PLAYER] )

	-- We want the Experimentals to have targets, so flash the area to give them intel on allied structures.
	-- Note that this is a vis loc for that army, not the player.
	ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'P1_EXP01_VisLoc_01' ), 1, ArmyBrains[ARMY_EXPENEM] )
	ScenarioFramework.CreateVisibleAreaLocation( 30, ScenarioUtils.MarkerToPosition( 'P1_EXP01_VisLoc_02' ), 1, ArmyBrains[ARMY_EXPENEM] )
	ScenarioFramework.CreateVisibleAreaLocation( 25, ScenarioUtils.MarkerToPosition( 'P1_EXP01_VisLoc_02' ), 1, ArmyBrains[ARMY_EXPENEM] )

	-- Create the players starting aircraft (for the lower area - shown flying in during the opening NIS)
	ScenarioInfo.P1_PLAYER_InitAir_Fighters_01 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitAir_Fighters_01')
	ScenarioInfo.P1_PLAYER_InitAir_Bombers_01 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitAir_Bombers_01')
	ScenarioInfo.P1_PLAYER_InitAir_Gunships_01 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitAir_Gunships_01')

	-- Create tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')
end

function P1_Main()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Destroy Enemy Commander
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Destroy Enemy Commander.')
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',						-- type
		'incomplete',					-- status
		OpStrings.U04_M1_obj10_NAME,	-- title
		OpStrings.U04_M1_obj10_DESC,	-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.P1_EnemyCommander},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	-- setup the commander for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P1_EnemyCommander, LaunchVictoryNIS)

	----------------------------------------------
	-- Secondary Objective S1_obj10 - Destroy Fatboys
	----------------------------------------------
	LOG('----- P1_Main: Assign Secondary Objective S1_obj10 - Destroy Fatboys.')
	local descText = OpStrings.U04_S1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U04_S1_obj10_KILL_FATBOYS)
	ScenarioInfo.S1_obj10 = SimObjectives.KillOrCapture(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.U04_S1_obj10_NAME,			-- title
		descText,								-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.P1_SEFatboy01, ScenarioInfo.P1_SEFatboy02},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)

	ScenarioInfo.S1_obj10:AddProgressCallback(
		function(current, total)
			if current == 1 then
				--some confrimation VO for the first
				ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_CONFIRMATION_010)
			end
		end
	)
	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U04_S1_obj10_KILL_FATBOYS, ARMY_PLAYER, 3.0)

				LOG('----- P1_Main: Both south fatboys killeded')
				ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_INSTRUCTION_010, P1_AssignSEGantryObjective)

				-- Flag that the Fatboys are destroyed, and call a function which will check this,
				-- and other flags, to determine if its time to advance the op.
				ScenarioInfo.InitialFatboysKilled = true
				P1_EnableNWSequence()
			end
		end
	)

	-- Give an antinuke to the players starting antinuke structure.
	--local antiNuke = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uub0203, false, true)
	local antiNuke = ScenarioInfo.UnitNames[ARMY_PLAYER]['P1_PLAYER_AntiNuke']
	--for k, v in antiNuke do
		antiNuke:GiveAntiNukeSiloAmmo(1)
	--end

	-- Send some waiting gunships on their patrol, now that they wont be a distraction in those spots during the NIS.
	if ScenarioInfo.P1_ENEM01_InitGunship_West_lower_01 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_InitGunship_West_lower_01) then
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_West_lower_01, 'P1_ENEM01_West_lower_Patrol_01')
	end
	if ScenarioInfo.P1_ENEM01_InitGunship_South_02 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_InitGunship_South_02) then
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_South_02, 'P1_ENEM01_South_Patrol_01')
	end
	if ScenarioInfo.P1_ENEM01_InitGunship_South_01 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_InitGunship_South_01) then
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_South_01, 'P1_ENEM01_South_Patrol_01')
	end
	if ScenarioInfo.P1_ENEM01_InitGunship_West_lower_02 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_InitGunship_West_lower_02) then
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_InitGunship_West_lower_02, 'P1_ENEM01_West_lower_Patrol_01')
	end


	--# VO:
	-- Enemy kills some fatboys
	ScenarioFramework.CreateArmyStatTrigger (P1_AllyFatboyKilled_VO, ArmyBrains[ARMY_EXPALLY], 'EnemyKilled1Fatboy',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0101}})
	ScenarioFramework.CreateArmyStatTrigger (P1_AllyFatboyKilled_VO, ArmyBrains[ARMY_EXPALLY], 'EnemyKilled3Fatboy',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.uux0101}})

	-- Player kills fatboys (4 means the 2 initial ones, and then the 2 more that come in thereafter)
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerKilledFatboys_VO, ArmyBrains[ARMY_EXPENEM], 'PlayerKilled3Fatboys',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.uux0101}})

	-- Player loses a mass extractor
	ScenarioFramework.CreateArmyStatTrigger (P1_EnemyKilledMass_VO, ArmyBrains[ARMY_PLAYER], 'EnemyKilledMass',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uub0701}})


	-- trigger to begin unlocking research
	ScenarioFramework.CreateTimerTrigger (P1_ZoeContact, 25)

	-- Failsafe timer to turn on the SE gantry, if the player is spending too long. The result is that
	-- fatboys will eventually begin moving in. On the other hand, if the player
	ScenarioFramework.CreateTimerTrigger(P1_EnableSEFatboyOpAI, SEFatboy_FailsafeDelay)

	-- Failsafe timer that will try to advance the Op (if the initial Kill Fatboys objective is complete),
	-- after setting a flag that the timer has ticked down.
	ScenarioFramework.CreateTimerTrigger(P1_NWTimerEnded, NWFatboy_EnableDelay)

	-- Detect the player in Colemans main base area. After a delayed check to verify the players presence, this will lead
	-- to scared or confident Coleman VO, or a reset of this trigger if the player didnt stick around.
	ScenarioFramework.CreateAreaTrigger(function() ForkThread(P1_PlayerAtColemanBaseThread) end, 'EnemyBaseArea_01',
		categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 5, false)
end

function P1_EnableSEFatboyOpAI()
	if not ScenarioInfo.SouthWestGantryEnabled then
		LOG('----- P1: Turning on SouthEast fatboy OpAI')
		ScenarioInfo.SouthWestGantryEnabled = true
		ScenarioInfo.EXP01_SE_Fatboy_OpAI:Enable()
	end
end

function P1_AssignSEGantryObjective()
	----------------------------------------------
	-- Secondary Objective S2_obj10 - Take Over SE Gantry Area
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S2_obj10 - Take Over SE Gantry Area.')
	local descText = OpStrings.U04_S2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U04_S2_obj10_TAKE_SOUTHEAST)
	ScenarioInfo.S2_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.U04_S2_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('capture'),	-- Action
		{
			MarkUnits = true,
			Units = {ScenarioInfo.EXP01_SE_Gantry},
			Area = 'Gantry_3_Area',
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj10)

	-- Create the trigger that will kick off the SE gantry capture sequence
	ScenarioFramework.CreateAreaTrigger(P1_GantrySE_PlayerInArea, 'Gantry_3_Area',
		categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], CaptureGantryUnitMin_Player)
end

function P1_NWTimerEnded()
	-- flag that the failsafe timer has ticked down, and run a function that will check this,
	-- and other, flags to determine if its time to advance the Op.
	ScenarioInfo.NWTimerFinished = true
	P1_EnableNWSequence()
end

function P1_EnableNWSequence()
	-- When either a) the Failsafe timer has ticked down or b) the SE Capture objective is complete,
	-- we will enable the NW sequence, *if the Kill The Fatboys initial objective is complete* in either case.
	-- Among other things, this means we wont end up with more objectives (remember potential for research)
	-- than the UI can handle. This is sensible, because the fatboys are a very immediate threat to the player.
	local case1 = ScenarioInfo.NWTimerFinished and ScenarioInfo.InitialFatboysKilled
	local case2 = ScenarioInfo.InitialFatboysKilled and ScenarioInfo.SECaptureObjectiveComplete

	if case1 or case2 then
		if not ScenarioInfo.NWFatboySequenceEnabled then
			ScenarioInfo.NWFatboySequenceEnabled = true

			LOG('----- P1: Turning on NW fatboy OpAI')
			-- Turn on the NW fatboy OpAI
			ScenarioInfo.EXP01_NW_Fatboy_OpAI:Enable()

			-- also, send in the waiting fatboys that have been sitting stationary in the NW.
			if ScenarioInfo.P1_Init_NW_Fatboy_01 and ArmyBrains[ARMY_EXPENEM]:PlatoonExists( ScenarioInfo.P1_Init_NW_Fatboy_01) then
				ScenarioFramework.PlatoonMoveChain(ScenarioInfo.P1_Init_NW_Fatboy_01, 'EXP01_NW_Fatboy_Chain_Playerbound')
			end
			if ScenarioInfo.P1_Init_NW_Fatboy_02 and ArmyBrains[ARMY_EXPENEM]:PlatoonExists( ScenarioInfo.P1_Init_NW_Fatboy_02) then
				ScenarioFramework.PlatoonMoveChain(ScenarioInfo.P1_Init_NW_Fatboy_02, 'EXP01_NW_Fatboy_Chain_Playerbound')
			end

			-- Player allied SW gantry on now too.
			ScenarioInfo.EXPALLY_SW_Fatboy_OpAI:Enable()

			-- Play VO, assign objective.
			ScenarioFramework.Dialogue(OpDialog.U04_NW_EXP_INSTRUCTION_010, P1_AssignNWGantryObjective)
		end
	end
end

function P1_AssignNWGantryObjective()
	----------------------------------------------
	-- Secondary Objective S3_obj10 - Take Over NW Gantry Area
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S3_obj10 - Take Over NW Gantry Area.')
	local descText = OpStrings.U04_S3_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U04_S3_obj10_TAKE_NORTHWEST)
	ScenarioInfo.S3_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.U04_S3_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('capture'),	-- Action
		{
			MarkUnits = true,
			Units = {ScenarioInfo.EXP01_NW_Gantry},
			Area = 'Gantry_1_Area',
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S3_obj10)

	-- create a trigger that will start the NW capture sequence
	ScenarioFramework.CreateAreaTrigger(P1_GantryNW_PlayerInArea, 'Gantry_1_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 7)
end

function P1_SetupEnemyOpAI()

	--# Note that while these are all set up, some are subsequently disabled for tuning. We will leave the set up data
	-- here, however, as this will change over time. Some of these OpAI's are enabled/disabled over time. So, if one is disabled,
	-- do check elsewhere in the script for where it might be enabled, to comment it out.


	-- Enemy main base
	local levelTable_ENEM01_MainBase 			= { P1_ENEM01_MainBase = 100, }
	ScenarioInfo.ArmyBase_ENEM01_MainBase 		= ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_MainBase',
			'ENEM01_ENEM01_MainBase_Marker', 50, levelTable_ENEM01_MainBase, false, 2)
	ScenarioInfo.ArmyBase_ENEM01_MainBase:StartNonZeroBase(5)
	ScenarioInfo.ArmyBase_ENEM01_MainBase:AddEngineerPatrolChain('ArmyBase_ENEM01_MainBase_eng01_EngineerChain')
	ScenarioInfo.ArmyBase_ENEM01_MainBase:AddEngineerPatrolChain('ArmyBase_ENEM01_MainBase_eng02_EngineerChain')
	ScenarioInfo.ArmyBase_ENEM01_MainBase:AddEngineerPatrolChain('ArmyBase_ENEM01_MainBase_eng03_EngineerChain')

	-- toughen up the aa towers
	local aaTowers = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.uub0102, false)
	for k, v in aaTowers do
		if v and not v:IsDead() then
			ScenarioFramework.SetUnitVeterancyLevel(v, 5)
		end
	end


	-- Gunships that patrol the lanes (3 will be turned off when the enemy loses the gantries)
	-- The closer each is to the enemy base, the higher the priority. This is to help mitigate
	-- the enemy base building replacement platoons for far away bases, when the near patrols
	-- are in need of help.

	-- Base child used by the enemy. Consider keeping the patrols close to the enemy base larger than those
	-- that are far flung (or, conversely, keeping the MaxActivePlatoon count higher, so we keep things responsive,
	-- but also keep the area tougher than other places on the map. Note that the enemy will have to build some of
	-- these platoons at start, if we hand in less starting platoons than the number of Active platoons the OpAI
	-- tries to maintain).
	local EnemyGunshipChild_6 = {
		'EnemyGunshipChild_6',
		{
			{ 'uua0103', 6 },
		},
	}
	local EnemyGunshipChild_9 = {
		'EnemyGunshipChild_9',
		{
			{ 'uua0101', 2 },
			{ 'uua0103', 8 },
		},
	}


	local ENEM01_GunshipPatrol_N_left_OpAI				= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_9, 'ENEM01_GunshipPatrol_N_left', {} )
	local ENEM01_GunshipPatrol_N_left_OpAI_Data	 		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_North_left_Patrol_01', },}
	ENEM01_GunshipPatrol_N_left_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', ENEM01_GunshipPatrol_N_left_OpAI_Data )
	ENEM01_GunshipPatrol_N_left_OpAI:					EnableChildTypes( {'UEFGunships'} )
	ENEM01_GunshipPatrol_N_left_OpAI:					SetChildCount(1)
	ENEM01_GunshipPatrol_N_left_OpAI:					SetMaxActivePlatoons(2)
	ENEM01_GunshipPatrol_N_left_OpAI:					SetDefaultVeterancy(3)
	ENEM01_GunshipPatrol_N_left_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_North_left_01, false)
	ENEM01_GunshipPatrol_N_left_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_North_left_02, false)
	ENEM01_GunshipPatrol_N_left_OpAI:					AdjustPriority(2)


	local ENEM01_GunshipPatrol_N_right_OpAI				= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_9, 'ENEM01_GunshipPatrol_N_right', {} )
	local ENEM01_GunshipPatrol_N_right_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_North_right_Patrol_01', },}
	ENEM01_GunshipPatrol_N_right_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', ENEM01_GunshipPatrol_N_right_OpAI_Data )
	ENEM01_GunshipPatrol_N_right_OpAI:					EnableChildTypes( {'UEFGunships'} )
	ENEM01_GunshipPatrol_N_right_OpAI:					SetChildCount(1)
	ENEM01_GunshipPatrol_N_right_OpAI:					SetMaxActivePlatoons(2)
	ENEM01_GunshipPatrol_N_right_OpAI:					SetDefaultVeterancy(4)
	ENEM01_GunshipPatrol_N_right_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_North_right_01, false)
	ENEM01_GunshipPatrol_N_right_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_North_right_02, false)
	ENEM01_GunshipPatrol_N_right_OpAI:					AdjustPriority(3) -- high pri, because its closest to enemy main


	local ENEM01_GunshipPatrol_E_upper_OpAI				= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_6, 'ENEM01_GunshipPatrol_E_upper', {} )
	local ENEM01_GunshipPatrol_E_upper_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_East_upper_Patrol_01', },}
	ENEM01_GunshipPatrol_E_upper_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', ENEM01_GunshipPatrol_E_upper_OpAI_Data )
	ENEM01_GunshipPatrol_E_upper_OpAI:					EnableChildTypes( {'UEFGunships'} )
	ENEM01_GunshipPatrol_E_upper_OpAI:					SetChildCount(1)
	ENEM01_GunshipPatrol_E_upper_OpAI:					SetMaxActivePlatoons(3)
	ENEM01_GunshipPatrol_E_upper_OpAI:					SetDefaultVeterancy(3)
	ENEM01_GunshipPatrol_E_upper_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_East_upper_01, false)
	ENEM01_GunshipPatrol_E_upper_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_East_upper_02, false)
	ENEM01_GunshipPatrol_E_upper_OpAI:					AdjustPriority(3) -- high pri, because its closest to enemy main


	local ENEM01_GunshipPatrol_E_lower_OpAI				= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_6, 'ENEM01_GunshipPatrol_E_lower', {} )
	local ENEM01_GunshipPatrol_E_lower_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_East_lower_Patrol_01', },}
	ENEM01_GunshipPatrol_E_lower_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', ENEM01_GunshipPatrol_E_lower_OpAI_Data )
	ENEM01_GunshipPatrol_E_lower_OpAI:					EnableChildTypes( {'UEFGunships'} )
	ENEM01_GunshipPatrol_E_lower_OpAI:					SetChildCount(1)
	ENEM01_GunshipPatrol_E_lower_OpAI:					SetMaxActivePlatoons(2)
	ENEM01_GunshipPatrol_E_lower_OpAI:					SetDefaultVeterancy(3)
	ENEM01_GunshipPatrol_E_lower_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_East_lower_01, false)
	ENEM01_GunshipPatrol_E_lower_OpAI:					AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_East_lower_02, false)
	ENEM01_GunshipPatrol_E_lower_OpAI:					AdjustPriority(2)


	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI			= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_6, 'ENEM01_GunshipPatrol_S', {} )
	local ENEM01_GunshipPatrol_S_OpAI_Data				= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_South_Patrol_01', },}
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ENEM01_GunshipPatrol_S_OpAI_Data )
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:			EnableChildTypes( {'UEFGunships'} )
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:			SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:			SetChildCount(1)
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:			SetMaxActivePlatoons(1)		-- players has to deal with this area early, so dont rub it in
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:			AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_South_01, false)
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:			AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_South_02, false)


	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI		= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_6, 'ENEM01_GunshipPatrol_W_upper', {} )
	local ENEM01_GunshipPatrol_W_upper_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_West_upper_Patrol_01', },}
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ENEM01_GunshipPatrol_W_upper_OpAI_Data )
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		EnableChildTypes( {'UEFGunships'} )
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		SetChildCount(1)
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_West_upper_01, false)
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_West_upper_02, false)
	ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:		AdjustPriority(1)


	ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI		= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_6, 'ENEM01_GunshipPatrol_W_lower', {} )
	local ENEM01_GunshipPatrol_W_lower_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_West_lower_Patrol_01', },}
	ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ENEM01_GunshipPatrol_W_lower_OpAI_Data )
	ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:		EnableChildTypes( {'UEFGunships'} )
	ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:		SetChildCount(1)
	ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:		AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_West_lower_01, false)
	ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:		AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitGunship_West_lower_02, false)


	--# Surgical Response OpAI's if the player builds over-powerful units, or builds too many of certain units. Child count == number sent.
	-- Too many land units of some types
	ScenarioInfo.ENEM01_PlayerExcessLand_OpAI			= ScenarioInfo.ArmyBase_ENEM01_MainBase:AddOpAI('AirResponsePatrolLand', 'ENEM01_PlayerExcessLand_OpAI', {} )
	local ENEM01_PlayerExcessLand_OpAI_Data				= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_PlayerBaseArea_Air_Chain', },}
	ScenarioInfo.ENEM01_PlayerExcessLand_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ENEM01_PlayerExcessLand_OpAI_Data )
	ScenarioInfo.ENEM01_PlayerExcessLand_OpAI:			SetChildCount(2)


	-- Too many air units
	ScenarioInfo.ENEM01_PlayerExcessAir_OpAI			= ScenarioInfo.ArmyBase_ENEM01_MainBase:AddOpAI('AirResponsePatrolAir', 'ENEM01_PlayerExcessAir_OpAI', {} )
	local ENEM01_PlayerExcessAir_OpAI_Data				= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_PlayerBaseArea_Air_Chain', },}
	ScenarioInfo.ENEM01_PlayerExcessAir_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ENEM01_PlayerExcessAir_OpAI_Data )
	ScenarioInfo.ENEM01_PlayerExcessAir_OpAI:			SetChildCount(2)


	-- Player builds powerful individual land units
	ScenarioInfo.ENEM01_PlayerPowerfulLand_OpAI			=ScenarioInfo.ArmyBase_ENEM01_MainBase:AddOpAI('AirResponseTargetLand', 'ENEM01_PlayerPowerfulLand_OpAI', {} )
	local ENEM01_PlayerPowerfulLand_OpAI_Data			= {
    													    	PatrolChain = 'P1_ENEM01_PlayerBaseArea_Air_Chain',
    													    	CenterPoint = ScenarioUtils.MarkerToPosition( 'ENEM01_ENEM01_MainBase_Marker' ),
    													    	CategoryList = {
    													    	    (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    													    	    categories.uub0105,	-- artillery
    													    	    categories.ucb0105,	-- artillery
    													    	    categories.NUKE,
    													   	 	},
    														}
	ScenarioInfo.ENEM01_PlayerPowerfulLand_OpAI:		SetPlatoonThread( 'CategoryHunter', ENEM01_PlayerPowerfulLand_OpAI_Data )
	ScenarioInfo.ENEM01_PlayerPowerfulLand_OpAI:		SetChildCount(2)


	-- Player builds air experimentals
	ScenarioInfo.ENEM01_PlayerPowerfulAir_OpAI			= ScenarioInfo.ArmyBase_ENEM01_MainBase:AddOpAI('AirResponseTargetAir', 'ENEM01_PlayerPowerfulAir_OpAI', {} )
	local ENEM01_PlayerPowerfulAir_OpAI_Data				= {
    															PatrolChain = 'P1_ENEM01_PlayerBaseArea_Air_Chain',
    															CenterPoint = ScenarioUtils.MarkerToPosition( 'ENEM01_ENEM01_MainBase_Marker' ),
    															CategoryList = {
    															    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    															},
    														}
	ScenarioInfo.ENEM01_PlayerPowerfulAir_OpAI:			SetPlatoonThread( 'CategoryHunter', ENEM01_PlayerPowerfulAir_OpAI_Data )
	ScenarioInfo.ENEM01_PlayerPowerfulAir_OpAI:			SetChildCount(2)


	--## Tuning: While OpAI's may be set up, we may find we want to turn some off over time, but still keep the data around.
	--## disable opAI's in this section of this function.

	-- As this is only Op 4, lets not replenish the South patrol (its a bit much this early in the game). This normally
	-- is turned on and off based on who owns the gantry area, but that is too complex (and difficult) a dynamic. Note
	-- that it *is* enabled elsewhere, so if we want this op permanently off, it needs to be commented out elsewhere as well.
	ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:Disable()


	-- Air and Land patrol OpAIs for the enemy main base.
	ScenarioInfo.ENEM01_AirDefense_01_OpAI				= ScenarioInfo.ArmyBase_ENEM01_MainBase:AddOpAI('AirAttackUEF', 'ENEM01_AirDefense_01_OpAI', {} )
	local ENEM01_ENEM01_AirDefense_01_OpAI_Data			= { PatrolChain = 'P1_ENEM01_MainBase_Def_Air_01',}
	ScenarioInfo.ENEM01_AirDefense_01_OpAI:				SetPlatoonThread( 'PatrolRandomizedPoints', ENEM01_ENEM01_AirDefense_01_OpAI_Data )
	ScenarioInfo.ENEM01_AirDefense_01_OpAI:				AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitAir_Def_01 , false)
	ScenarioInfo.ENEM01_AirDefense_01_OpAI:				SetDefaultVeterancy(5)
	ScenarioInfo.ENEM01_AirDefense_01_OpAI:				SetMaxActivePlatoons(1)


	ScenarioInfo.ENEM01_LandDefense_01_OpAI				= ScenarioInfo.ArmyBase_ENEM01_MainBase:AddOpAI('LandAttackUEF', 'ENEM01_LandDefense_01_OpAI', {} )
	local ENEM01_LandDefense_01_OpAI_Data	 			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_MainBase_Def_Land_01', },}
	ScenarioInfo.ENEM01_LandDefense_01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ENEM01_LandDefense_01_OpAI_Data )
	ScenarioInfo.ENEM01_LandDefense_01_OpAI:			AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitLand_Def_01 , false)
	ScenarioInfo.ENEM01_LandDefense_01_OpAI:			SetMaxActivePlatoons(1)


	ScenarioInfo.ENEM01_LandDefense_02_OpAI				= ScenarioInfo.ArmyBase_ENEM01_MainBase:AddOpAI('LandAttackUEF', 'ENEM01_LandDefense_02_OpAI', {} )
	local ENEM01_LandDefense_02_OpAI_Data	 			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_MainBase_Def_Land_02', },}
	ScenarioInfo.ENEM01_LandDefense_02_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ENEM01_LandDefense_02_OpAI_Data )
	ScenarioInfo.ENEM01_LandDefense_02_OpAI:			AddActivePlatoon( ScenarioInfo.P1_ENEM01_InitLand_Def_02 , false)
	ScenarioInfo.ENEM01_LandDefense_02_OpAI:			SetMaxActivePlatoons(1)

end

function GantryBasesSetup()
	----------------------------------------------
	--Base Manager and OpAI Setup for Gantry Bases
	----------------------------------------------

	----# SouthWest (Player) allied Gantry Base #----
	local levelTable_EXPALLY_SW_Gantry 				= { EXPALLY_SW_Gantry_Base = 100, }
	ScenarioInfo.ArmyBase_EXPALLY_SW_Gantry 	= ArmyBrains[ARMY_EXP01].CampaignAISystem:AddBaseManager('ArmyBase_EXPALLY_SW_Gantry',
		 'EXPALLY_Gantry_SW_Base_Marker', 50, levelTable_EXPALLY_SW_Gantry)
	ScenarioInfo.ArmyBase_EXPALLY_SW_Gantry:		StartNonZeroBase(0)

	-- sw (player area) opai
	ScenarioInfo.EXPALLY_SW_Fatboy_OpAI		= ScenarioInfo.ArmyBase_EXPALLY_SW_Gantry:AddOpAI('SingleFatboyAttack', 'EXPALLY_SW_Fatboy_OpAI', {} )
	local EXPALLY_SW_Fatboy_OpAI_Data 		= { AnnounceMove = true, MoveChain = 'EXPALLY_SW_Fatboy_Chain_Enemybound',}
	ScenarioInfo.EXPALLY_SW_Fatboy_OpAI:	SetPlatoonThread( 'MoveAlongChain', EXPALLY_SW_Fatboy_OpAI_Data )
	ScenarioInfo.EXPALLY_SW_Fatboy_OpAI:	SetMaxActivePlatoons(2)
	ScenarioInfo.EXPALLY_SW_Fatboy_OpAI.	FormCallback:Add(P1_SW_Fatboy_Callback)
	ScenarioInfo.EXPALLY_SW_Fatboy_OpAI:	Disable()


	----# NorthWest Gantry Base #----
	local levelTable_EXP01_NW_Gantry 			= { EXP01_NW_Gantry_Base = 100, }
	ScenarioInfo.ArmyBase_EXP01_NW_Gantry = ArmyBrains[ARMY_EXP01].CampaignAISystem:AddBaseManager('ArmyBase_EXP01_NW_Gantry',
		 'EXP01_Gantry_NW_Base_Marker', 50, levelTable_EXP01_NW_Gantry)
	ScenarioInfo.ArmyBase_EXP01_NW_Gantry:		StartNonZeroBase(0)

	-- nw opai
	ScenarioInfo.EXP01_NW_Fatboy_OpAI		= ScenarioInfo.ArmyBase_EXP01_NW_Gantry:AddOpAI('SingleFatboyAttack', 'EXP01_NW_Fatboy_OpAI', {} )
	local EXP01_NW_Fatboy_OpAI_Data 		= { AnnounceMove = true, MoveChain = 'EXP01_NW_Fatboy_Chain_Playerbound', }
	ScenarioInfo.EXP01_NW_Fatboy_OpAI:		SetPlatoonThread( 'MoveAlongChain', EXP01_NW_Fatboy_OpAI_Data )
	ScenarioInfo.EXP01_NW_Fatboy_OpAI:		Disable()
	ScenarioInfo.EXP01_NW_Fatboy_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.EXP01_NW_Fatboy_OpAI.		FormCallback:Add(P1_NW_Fatboy_Callback)


	----# SouthEast Gantry Base #----
	local levelTable_EXP01_SE_Gantry 			= { EXP01_SE_Gantry_Base = 100, }
	ScenarioInfo.ArmyBase_EXP01_SE_Gantry = ArmyBrains[ARMY_EXP01].CampaignAISystem:AddBaseManager('ArmyBase_EXP01_SE_Gantry',
		 'EXP01_Gantry_SE_Base_Marker', 50, levelTable_EXP01_SE_Gantry)
	ScenarioInfo.ArmyBase_EXP01_SE_Gantry:		StartNonZeroBase(0)

	ScenarioInfo.P1_Southeast_Gantry = ScenarioInfo.UnitNames[ARMY_EXP01]['EXP01_SE_Gantry'] --handle for NIS

	-- se opai
	ScenarioInfo.EXP01_SE_Fatboy_OpAI		= ScenarioInfo.ArmyBase_EXP01_SE_Gantry:AddOpAI('SingleFatboyAttack', 'EXP01_SE_Fatboy_OpAI', {} )
	local EXP01_SE_Fatboy_OpAI_Data			= { AnnounceMove = true, MoveChain = 'EXP01_SE_Fatboy_Chain_Playerbound', }
	ScenarioInfo.EXP01_SE_Fatboy_OpAI:		SetPlatoonThread( 'MoveAlongChain', EXP01_SE_Fatboy_OpAI_Data )
	ScenarioInfo.EXP01_SE_Fatboy_OpAI:		Disable()
	ScenarioInfo.EXP01_SE_Fatboy_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.EXP01_SE_Fatboy_OpAI.		FormCallback:Add(P1_SE_Fatboy_Callback)


	---------------------------------------
	--Sundry Fatboy and Gantry related things
	---------------------------------------

	ScenarioInfo.EXP01_SW_Gantry = ScenarioInfo.UnitNames[ARMY_EXP01]['EXP01_SW_Gantry']
	ScenarioInfo.EXP01_SW_Gantry:SetCustomName(ScenarioGameNames.UNIT_U04_Factory_SW)
	ProtectUnit(ScenarioInfo.EXP01_SW_Gantry)

	ScenarioInfo.EXP01_NW_Gantry = ScenarioInfo.UnitNames[ARMY_EXP01]['EXP01_NW_Gantry']
	ScenarioInfo.EXP01_NW_Gantry:SetCustomName(ScenarioGameNames.UNIT_U04_Factory_NW)
	ProtectUnit(ScenarioInfo.EXP01_NW_Gantry)

	ScenarioInfo.EXP01_SE_Gantry = ScenarioInfo.UnitNames[ARMY_EXP01]['EXP01_SE_Gantry']
	ScenarioInfo.EXP01_SE_Gantry:SetCustomName(ScenarioGameNames.UNIT_U04_Factory_SE)
	ProtectUnit(ScenarioInfo.EXP01_SE_Gantry)

	-- Two initial NW fatboys who hang out until called down, based on event flow. These are spawned in, so we
	-- get fast response when we send them to the player (instead of waiting for them to get built). Add a
	-- platoon death trigger to each, to try to play some VO from Coleman when they die.
	ScenarioInfo.P1_Init_NW_Fatboy_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_EXPENEM', 'EXPNW_Init_Fatboy_01', 'AttackFormation')
	ScenarioInfo.P1_Init_NW_Fatboy_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_EXPENEM', 'EXPNW_Init_Fatboy_02', 'AttackFormation')
	ScenarioInfo.EXP01_NW_Fatboy_OpAI:AddActivePlatoon(ScenarioInfo.P1_Init_NW_Fatboy_01, false)
	ScenarioInfo.EXP01_NW_Fatboy_OpAI:AddActivePlatoon(ScenarioInfo.P1_Init_NW_Fatboy_02, false)
	ScenarioFramework.CreatePlatoonDeathTrigger (P1_EnemyFatboyDestroyed, ScenarioInfo.P1_Init_NW_Fatboy_01)
	ScenarioFramework.CreatePlatoonDeathTrigger (P1_EnemyFatboyDestroyed, ScenarioInfo.P1_Init_NW_Fatboy_02)
	P1_CreateEffectsOnFatboy(ScenarioInfo.P1_Init_NW_Fatboy_01)
	P1_CreateEffectsOnFatboy(ScenarioInfo.P1_Init_NW_Fatboy_02)

end


---------------------------------------------------------------------
-- FATBOY OPAI CALLBACK AND ASSIGNMENT FUNCTIONS:
---------------------------------------------------------------------

function P1_SW_Fatboy_Callback(platoon)
	LOG('----- P1: Player area gantry: allied fatboy platoon created')

	-- Swap the fatboy to the allied fatboy army, get it into a fresh platoon, and
	-- add it back in as an active platoon to the OpAI that created it.
	local unit = platoon:GetPlatoonUnits()[1]

	-- swap army on the unit to friendly army
	local newUnit = ScenarioFramework.GiveUnitToArmy( unit, ARMY_EXPALLY )

	newUnit:SetCapturable(false)
	local platoon = ArmyBrains[ARMY_EXPALLY]:MakePlatoon('', '')
	ArmyBrains[ARMY_EXPALLY]:AssignUnitsToPlatoon( platoon, {newUnit}, 'Attack', 'AttackFormation' )
	ScenarioInfo.EXPALLY_SW_Fatboy_OpAI:AddActivePlatoon( platoon, true)
	P1_CreateEffectsOnFatboy(platoon)

	-- VO related counter
	AlliedFatboyCallbackCount = AlliedFatboyCallbackCount + 1

	-- Platoon death trigger and unit damage trigger, to trigger warning VO in those events.
	-- Distance trigger: when unit nears enemy base, increment counter that will lead to final enemy transport attack.
	for k, v in platoon:GetPlatoonUnits() do
		ScenarioFramework.CreateUnitDeathTrigger (P1_AlliedFatboyDestroyed, v)
		ScenarioFramework.CreateUnitDamagedTrigger(P1_AlliedFatboyDamaged, v, -1, nil, true)
		ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P1_TransAttackCheck, v, 'P1_Enemey_Base_MidPoint_Marker', 155 )
	end

	-- Platoon created VO.
	if AlliedFatboyCallbackCount == 1 then
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_HOME_EXP_BUILT_010)
		end
	elseif AlliedFatboyCallbackCount == 2 then
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_HOME_EXP_BUILT_020)
		end
	end
end

function P1_NW_Fatboy_Callback(platoon)
	LOG('----- P1: NW fatboy callback, platoon units:' .. table.getn(platoon:GetPlatoonUnits()))

	-- Take the platoon from the experimental opai callback, and send it allong with the necessary data
	P1_ExperimentalArmyAssign( platoon, 'EXP01_NW_Fatboy_Chain_Playerbound', 'EXP01_NW_Fatboy_Chain_Enemybound', ScenarioInfo.NW_Gantry_Friendly, ScenarioInfo.EXP01_NW_Fatboy_OpAI)

	-- Play VO appropriate to the army that will get an fatboy allied to them (separate function for cleanliness)
	P1_NorthwestFatboyBuiltVO()
end

function P1_SE_Fatboy_Callback(platoon)
	LOG('----- P1: SE fatboy callback, platoon units:'  .. table.getn(platoon:GetPlatoonUnits()))

	-- Take the platoon from the experimental opai callback, and send it along with the necessary data
	P1_ExperimentalArmyAssign( platoon, 'EXP01_SE_Fatboy_Chain_Playerbound', 'EXP01_SE_Fatboy_Chain_Enemybound', ScenarioInfo.SE_Gantry_Friendly, ScenarioInfo.EXP01_SE_Fatboy_OpAI)

	-- Play VO appropriate to the army that will get an fatboy allied to them (separate function for cleanliness)
	P1_SoutheasttFatboyBuiltVO()
end

function P1_ExperimentalArmyAssign(platoon, chainPlayer, chainEnemy, flag, opAI)
	-- platoon			- passed in platoon containing the fatboy
	-- routePlayer		- chain for attacking player
	-- chainEnemy		- chain for attacking enemy
	-- flag				- the bool that shows if the location is friendly or enemy
	-- opAI				- the OpAI that built this platoon

	-- This function is the callback for the two OpAI's which build fatboys. When called,
	-- it will check which side the particular gantry areas's allegiance is with, and send
	-- the fatboy on the appropriate patrol (ie, toward the player, or the enemy).

	local unit = platoon:GetPlatoonUnits()[1]
	 if type(unit) != 'table' then
		-- Warn if position 1 doesnt actually contain what we expected.
		WARN('***WARNING*** P1_ExperimentalArmyAssign: did not get a single fatboy from passed in platoon! Original platoon contained: ' .. table.getn(platoon:GetPlatoonUnits()))
	end
	IssueClearCommands({unit})

	LOG('----- DEBUG: ASSIGN, old platoon, units: = ' .. table.getn(platoon:GetPlatoonUnits()))

	-- If the gantry location is friendly,
	if flag == true then

		if unit and not unit:IsDead() then
			LOG('----- DEBUG: Friendly flag is true, adding Fatboy to allied exp army.')

			-- swap army on the unit to friendly army
			local newUnit = ScenarioFramework.GiveUnitToArmy( unit, ARMY_EXPALLY )

			-- We need to pass a platoon handle to the OpAI, so it can count our experimental
			-- for its max platoon count. So, create a new palatoon and put our freshly-swapped unit
			-- into it. Then, send it on its way.
			newUnit:SetCapturable(false)
			local platoon = ArmyBrains[ARMY_EXPALLY]:MakePlatoon('', '')
			ArmyBrains[ARMY_EXPALLY]:AssignUnitsToPlatoon( platoon, {newUnit}, 'Attack', 'AttackFormation' )
			ScenarioFramework.PlatoonPatrolChain(platoon, chainEnemy)
			P1_CreateEffectsOnFatboy(platoon)

			LOG('-----DEBUG: ASSIGN ENEMY CONTROLLED, friendly: NumUnits = ' .. table.getn(platoon:GetPlatoonUnits()))

			-- Pass platoon to OpAI
			opAI:AddActivePlatoon( platoon, false)

			-- when unit nears enemy base, increment counter that will lead to final enemy transport attack.
			ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P1_TransAttackCheck, newUnit, 'P1_Enemey_Base_MidPoint_Marker', 155 )

			-- Death will result in some VO.
			ScenarioFramework.CreateUnitDeathTrigger (P1_AlliedFatboyDestroyed, newUnit)
		else
			WARN('***WARNING*** P1_ExperimentalArmyAssign: (Friendly flag is true) Unit failed validity check!')
		end

	-- Gantry location is enemy-held.
	else
		if unit and not unit:IsDead() then
			LOG('-----DEBUG: Friendly flag is false, adding Fatboy to enemy exp army.')

			-- swap army on the unit to friendly army
			local newUnit = ScenarioFramework.GiveUnitToArmy( unit, ARMY_EXPENEM )

			-- We need to pass a platoon handle to the OpAI, so it can count our experimental
			-- for its max platoon count. So, create a new palatoon and put our freshly-swapped unit
			-- into it. Then, send it on its way.
			newUnit:SetCapturable(false)
			local platoon = ArmyBrains[ARMY_EXPENEM]:MakePlatoon('', '')
			ArmyBrains[ARMY_EXPENEM]:AssignUnitsToPlatoon( platoon, {newUnit}, 'Attack', 'AttackFormation' )
			ScenarioFramework.PlatoonPatrolChain(platoon, chainPlayer)
			P1_CreateEffectsOnFatboy(platoon)

			LOG('-----DEBUG: ASSIGN, enemy: NumUnits = ' .. table.getn(platoon:GetPlatoonUnits()))

			opAI:AddActivePlatoon( platoon, false)

			-- Death will result in some VO.
			ScenarioFramework.CreatePlatoonDeathTrigger (P1_EnemyFatboyDestroyed, platoon)
		else
			WARN('***WARNING*** P1_ExperimentalArmyAssign: (Friendly flag is false) Unit failed validity check!')
		end
	end
end

function P1_CreateEffectsOnFatboy(platoon)
	for k, unit in platoon:GetPlatoonUnits() do
		if unit and not unit:IsDead() then
			unit.AmbientEffectsBag = {}
			table.insert( unit.AmbientEffectsBag, CreateAttachedEmitter( unit, 'UUX0101', unit:GetArmy(), '/effects/emitters/units/scenario/zomfatboy/ambient/zomfatboy_amb_01_smoke_emit.bp' ) )
			table.insert( unit.AmbientEffectsBag, CreateAttachedEmitter( unit, 'UUX0101', unit:GetArmy(), '/effects/emitters/units/scenario/zomfatboy/ambient/zomfatboy_amb_02_sparks_emit.bp' ) )
			table.insert( unit.AmbientEffectsBag, CreateAttachedEmitter( unit, 'UUX0101', unit:GetArmy(), '/effects/emitters/units/scenario/zomfatboy/ambient/zomfatboy_amb_04_electriciy_emit.bp' ) )
			table.insert( unit.AmbientEffectsBag, CreateAttachedEmitter( unit, 'UUX0101', unit:GetArmy(), '/effects/emitters/units/scenario/zomfatboy/ambient/zomfatboy_amb_05_electriciy_emit.bp' ) )
			table.insert( unit.AmbientEffectsBag, CreateAttachedEmitter( unit, 'Turret02', unit:GetArmy(), '/effects/emitters/units/scenario/zomfatboy/ambient/zomfatboy_amb_03_sparks_emit.bp' ) )
			table.insert( unit.AmbientEffectsBag, CreateAttachedEmitter( unit, 'Turret04', unit:GetArmy(), '/effects/emitters/units/scenario/zomfatboy/ambient/zomfatboy_amb_03_sparks_emit.bp' ) )
		end
	end
end

---------------------------------------------------------------------
-- GANTRY TEAM SWAP FUNCTIONS:
---------------------------------------------------------------------
function P1_GantryNW_PlayerInArea()
	LOG('----- P1: Player detected in GantryNW area')
	-- To take over a gantry area, the attacking army must keep a number of units in the area while
	-- no defenders are present. If the attacker succeeds, Opais are turned on/off, and a flag is
	-- set so that fatboys created by the gantry will be assigned to an army allied to the attacker.
	-- A new trigger is set, which will replicate this process, but in revers: the attacker is now the
	-- defender. If the attacker fails, a new trigger is re-created, so they can try again to take the
	-- area.

	local captureSuccess = GantryCaptureThread(ScenarioInfo.NW_Gantry_Buildings, ARMY_EXPENEM, ARMY_EXPALLY, ARMY_PLAYER, ARMY_ENEM01, CaptureGantryUnitMin_Player, 'Gantry_1_Area')

	if captureSuccess then
		LOG('----- P1: Player now owns GantryNW area. Setting up')

		-- Player now owns this area.
		-- Flag that the build callback will check to see if Fatboys produced are enemy or friendly.
		-- Complete the NW secondary, if it was assigned.
		ScenarioInfo.NW_Gantry_Friendly = true
		if ScenarioInfo.S3_obj10.Active then
			LOG('----- P1: Manual complete of NW objective')
			ScenarioInfo.S3_obj10:ManualResult(true)
			ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U04_S3_obj10_TAKE_NORTHWEST, ARMY_PLAYER, 3.0)
		end

		if not ScenarioInfo.P1_NWGantryCapturedVOPlayed then
			--confirmation VO, first time.
			ScenarioInfo.P1_NWGantryCapturedVOPlayed = true
			ScenarioFramework.Dialogue(OpDialog.U04_NW_EXP_INSTRUCTION_020)
		end

		-- Disable the OpAI's that send enemy gunships to support Fatboys that move towards the player.
		ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:Disable()
		ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:Disable()

		-- Create new trigger to begin capture check sequence, but for Enemy.
		ScenarioFramework.CreateAreaTrigger(P1_GantryNW_EnemyInArea, 'Gantry_1_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_ENEM01], CaptureGantryUnitMin_Enemy)

	else
		-- player failed to hold area. Kill this thread, and recreate the trigger that started it off.
		-- This resets the whole scenario back to 'enemy still holds this area, player needs to capture it' mode,
		WaitSeconds(2.5)	-- need a pause so we dont get a rapid fire loop going on if other units are passing through.
		ScenarioFramework.CreateAreaTrigger(P1_GantryNW_PlayerInArea, 'Gantry_1_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], CaptureGantryUnitMin_Player)
	end
end

function P1_GantryNW_EnemyInArea()
	LOG('----- P1: Enemy detected in GantryNW area')
	-- This is the same as above, but for the enemy.

	local captureSuccess = GantryCaptureThread(ScenarioInfo.NW_Gantry_Buildings, ARMY_EXPALLY, ARMY_EXPENEM, ARMY_ENEM01, ARMY_PLAYER, CaptureGantryUnitMin_Enemy, 'Gantry_1_Area')

	if captureSuccess then
		LOG('----- P1: Enemy now owns GantryNW area. Setting up')

		ScenarioInfo.NW_Gantry_Friendly = false

		-- Enable the OpAI's that send enemy gunships to support Fatboys that move towards the player.
		ScenarioInfo.ENEM01_GunshipPatrol_W_upper_OpAI:Enable()
		ScenarioInfo.ENEM01_GunshipPatrol_W_lower_OpAI:Enable()

		-- create a trigger that looks for a player attempt at a capture
		ScenarioFramework.CreateAreaTrigger(P1_GantryNW_PlayerInArea, 'Gantry_1_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], CaptureGantryUnitMin_Player)
	else
		LOG('----- P1: Enemy failed to hold NW: killing thread in 2.5 seconds')

		WaitSeconds(2.5)
		ScenarioFramework.CreateAreaTrigger(P1_GantryNW_EnemyInArea, 'Gantry_1_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_ENEM01], CaptureGantryUnitMin_Enemy)
	end
end

function P1_GantrySE_PlayerInArea()
	LOG('----- P1: Player detected in GantrySE area')
	-- Duplicate of the above two-function set, but for the SE gantry area.

	-- Run the capture thread. It will return true/false based on how the capture attempt goes.
	local captureSuccess = GantryCaptureThread(
		ScenarioInfo.SE_Gantry_Buildings,
		ARMY_EXPENEM,
		ARMY_EXPALLY,
		ARMY_PLAYER,
		ARMY_ENEM01,
		CaptureGantryUnitMin_Player,
		'Gantry_3_Area'
	)

	if captureSuccess then
		LOG('----- P1: Player now owns GantrySE area. Setting up')

		-- Turn off the gunship patrols for the enemy that are there to support attacking fatboys.
		ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:Disable()

		if not ScenarioInfo.P1_SEGantryCapturedVOPlayed then
			--confirmation VO, first time.
			ScenarioInfo.P1_SEGantryCapturedVOPlayed = true
			ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_INSTRUCTION_020)
		end

		-- flag that the area is now player held, complete the related objective if it was assigned,
		-- and create the trigger that will check for the enemy attemps to recapture the area.
		ScenarioInfo.SE_Gantry_Friendly = true
		if ScenarioInfo.S2_obj10.Active then
			LOG('----- P1: Manual complete of SE objective')
			ScenarioInfo.S2_obj10:ManualResult(true)
			ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U04_S2_obj10_TAKE_SOUTHEAST, ARMY_PLAYER, 3.0)

			-- Flag that we have completed the capture objective, that we will check in the following function.
			-- Other flags are checked along with this one, to see if its time to advance the Op.
			ScenarioInfo.SECaptureObjectiveComplete = true
			P1_EnableNWSequence()

			-- enable the SE gantry, so it begins building a fatboy (this is called either here, or a timer
			-- elsewhere, if the player is taking too long).
			P1_EnableSEFatboyOpAI()
		end

		-- create a trigger that now looks out for the enemy trying to attack and recapture the gantry.
		ScenarioFramework.CreateAreaTrigger(P1_GantrySE_EnemyInArea, 'Gantry_3_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_ENEM01], CaptureGantryUnitMin_Enemy)
	else
		LOG('----- P1: Player failed to hold SE: killing thread in 2.5 seconds')

		WaitSeconds(2.5)
		ScenarioFramework.CreateAreaTrigger(P1_GantrySE_PlayerInArea, 'Gantry_3_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], CaptureGantryUnitMin_Player)
	end
end

function P1_GantrySE_EnemyInArea()
	LOG('----- P1: Enemy detected in GantrySE area')

	local captureSuccess = GantryCaptureThread(
		ScenarioInfo.SE_Gantry_Buildings,
		ARMY_EXPALLY,
		ARMY_EXPENEM,
		ARMY_ENEM01,
		ARMY_PLAYER,
		CaptureGantryUnitMin_Enemy,
		'Gantry_3_Area'
	)

	if captureSuccess then
		LOG('----- P1: Enemy now owns GantrySE area. Setting up')

		-- Now that the enemy owns this area, turn on the OpAIs that will support attacking fatboys.
		--# Commenting out for tuning: as this is only op4, we dont want to push back this much. -greg
		-- ScenarioInfo.ENEM01_GunshipPatrol_S_OpAI:Enable()

		ScenarioInfo.SE_Gantry_Friendly = false
		ScenarioFramework.CreateAreaTrigger(P1_GantrySE_PlayerInArea, 'Gantry_3_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], CaptureGantryUnitMin_Player)

	else
		LOG('----- P1: Enemy failed to hold SE area: killing thread in 2.5 seconds')

		WaitSeconds(2.5)
		ScenarioFramework.CreateAreaTrigger(P1_GantrySE_EnemyInArea, 'Gantry_3_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_ENEM01], CaptureGantryUnitMin_Enemy)
	end
end

function GantryCaptureThread(structures, oldExpArmy, newExpArmy, attackerArmy, defenderArmy, minAttackers, area)
	-- This function manages the 'capture' of a gantry area by an army. It checks for attacker units in an area,
	-- and will slowly go through a list of structures, swapping each from being part of one Experimental army
	-- to another. However, if the attackers fail to maintain a minimum number of units in the area, or if any
	-- defenders are present, the attempt will fail, and any progress made on the buildings (which act as a kind
	-- of visual counter) will be reset back to the original state.

	-- structures			table of indicator structures (must stay in order)
	-- oldExpArmy			original army that the indicator structures belongs to
	-- newExpArmy			new army that the indicator structures will be give to
	-- attackerArmy			player/enemy army: which is trying to take the gantry area
	-- defenderArmy			player/enemy army: which is trying to defend the gantry area
	-- minAttackers			minumum number of units the attacker must maintain to continue taking the area
	-- area					area that we check in to see if defender or attacker units are present in

	LOG('----- P1: Gantry Capture thread, for area' .. area)

	-- Play VO at the start of the first two player attempts to capture, unless we have already successfully captured
	-- a gantry area.
	if attackerArmy == ARMY_PLAYER and not ScenarioInfo.GantryCaptureVOSequenceComplete then
		-- so we dont blow this VO on situations that we know will instantly fail (ie, enemy is already present)
		-- first check that the area is clear before we try to play any VO.
		if ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS, area, ArmyBrains[ARMY_ENEM01]) == 0 then
			GantryCaptureVOCount = GantryCaptureVOCount + 1
			if GantryCaptureVOCount == 1 then
				ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_ATTEMPT_010)
			elseif GantryCaptureVOCount == 2 then
				ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_ATTEMPT_020)
			end
		end
	end

	for k, v in structures do
		if v.unit and not v.unit:IsDead() then
			-- wait at the start instead of end so attackers dont get a 'free' structure swapped over, with no wait.
			WaitSeconds(1.2)

			-- gather info on attaker and defender to check
			local numAttackers = ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS, area, ArmyBrains[attackerArmy])
			local numDefenders = ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS, area, ArmyBrains[defenderArmy])

			-- if the attackers have the required numeber of units present, and no defenders are around
			if numAttackers >= minAttackers and numDefenders == 0 then
				LOG('----- P1: Gantry Capture thread, for area' .. area .. ': pass.')

				-- then swap the structure to the new army, and set its army flag to the new army
				v.unit = ScenarioFramework.GiveUnitToArmy( v.unit, newExpArmy)
				v.army = newExpArmy
				ProtectUnit(v.unit)

			-- failed: insufficient attackers, or defenders were present
			else

				LOG('----- P1: Gantry Capture thread, for area' .. area .. ': FAILED')

				-- We need to undo any unit swapping we may have done, to set the structures back to their original army.
				-- If any of the structures is of the new army, then give that unit back to the old army, and set its army
				-- flag accordingly.
				for key, value in structures do

					-- if the army is of the new army, then we need to undo this
					if value.army == newExpArmy then
						value.unit = ScenarioFramework.GiveUnitToArmy( value.unit, oldExpArmy)
						value.army = oldExpArmy
						ProtectUnit(value.unit)
					end
				end

				-- Play a fail VO for the player, if we havent A)completed a capture already and B) already
				-- played some fail VO.
				-- To avoid and instant fail, which would waste this fail VO in cases where the player entered the
				-- trigger area while there was already enemy units present, only try to play the fail VO if we have
				-- already made some capture progress; ie, if we have already iterated at least once through the main for loop.
				if k > 1 then
					if attackerArmy == ARMY_PLAYER then
						if not ScenarioInfo.GantryCaptureVOSequenceComplete and not ScenarioInfo.GantryCapture_FailPlayed then
							ScenarioInfo.GantryCapture_FailPlayed =  true
							ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_FAIL_010)
						end
					end
				end

				-- Capture failed.
				return false
			end
		end
	end
	-- Set flag for the VO related to players first capture attempts, so no further VO is played.
	if attackerArmy == ARMY_PLAYER then
		ScenarioInfo.GantryCaptureVOSequenceComplete = true
	end

	-- Successful capture.
	return true
end

---------------------------------------------------------------------
-- FINAL TRANSPORT ATTACK RELATED FUNCTIONS:
---------------------------------------------------------------------
function P1_TransAttackCheck()
	LOG('----- P1: Allied fatboy detected in Enemy main base ')
	-- This function is called by allied fatboys distance triggers, when they near the enemy base.
	-- When a total of two has made it to the periphery of the enemy base, the enemy decides things
	--	are getting a little too sketchy, and so opts for a fullscale assault via transports.
	TransportAttackCount = TransportAttackCount + 1

	if not ScenarioInfo.VictoryNISBeginning then
		-- First allied fatboy at enemy base area
		if TransportAttackCount == 1 then
			LOG('----- P1: Fatboy at enemy 1, play VO ')
			--Coleman plays some VO when the player gets a fatboy in his general base area
			ScenarioFramework.Dialogue(OpDialog.U04_COLEMAN_ATTACK_010)

		-- Third allied fatboy nears allied base, enemy will begin transport attack
		elseif TransportAttackCount == 3 then
			LOG('----- P1: Fatboy at enemy 2, calling transport attack')
			-- let VO checks know the transport attack has begun, so some VO is now not appropriate to play.
			ScenarioInfo.P1_TransportAttackInProgress = true

			-- Disable the enemy base manager.
			ScenarioInfo.ArmyBase_ENEM01_MainBase:BaseActive(false)
			P1_BeginTransportAttackNIS()
		end
	else
		LOG('----- P1: Allied fatboy at Enemy, but victory NIS is in progress now.')
	end
end

function P1_BeginTransportAttackNIS()
	ForkThread(
		function()
			P1_TransAttackSetup()
			OpNIS.NIS_TRANSPORT_ATTACK()
			P1_TransAttackFollowup()
		end
	)
end

function P1_TransAttackSetup()
	-- create all units we need for the gameplay portion of the transport attack

	-- Create the attack group
	ScenarioInfo.P1_TransAttack_Units_01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_TransAttack_Units_01')
	ScenarioInfo.P1_TransAttack_Units_02 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_TransAttack_Units_02')
	ScenarioInfo.P1_TransAttack_Units_03 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_TransAttack_Units_03')

	-- Create the transports (Note: Transport 3 is the Commander transport)
	ScenarioInfo.P1_TransAttack_Transport_01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_TransAttack_Transport_01')
	ScenarioInfo.P1_TransAttack_Transport_02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_TransAttack_Transport_02')
	ScenarioInfo.P1_TransAttack_Transport_03 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_TransAttack_Transport_03')

	-- table for ease of checking if the transports exist elsewhere, etc.
	ScenarioInfo.P1_TransAttack_TransportTable = {}
	table.insert(ScenarioInfo.P1_TransAttack_TransportTable, ScenarioInfo.P1_TransAttack_Transport_01)
	table.insert(ScenarioInfo.P1_TransAttack_TransportTable, ScenarioInfo.P1_TransAttack_Transport_02)
	table.insert(ScenarioInfo.P1_TransAttack_TransportTable, ScenarioInfo.P1_TransAttack_Transport_03)

	-- Load the transports up
	TransportUtils.AddUnitsToTransportStorage(ScenarioInfo.P1_TransAttack_Units_01, {ScenarioInfo.P1_TransAttack_Transport_01})
	TransportUtils.AddUnitsToTransportStorage(ScenarioInfo.P1_TransAttack_Units_02, {ScenarioInfo.P1_TransAttack_Transport_02})
	TransportUtils.AddUnitsToTransportStorage(ScenarioInfo.P1_TransAttack_Units_03, {ScenarioInfo.P1_TransAttack_Transport_03})
end

function P1_TransAttackFollowup()
	-- after the NIS, send the real enemy CDR in with his group on attack.
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.P1_EnemyCommander}, ScenarioUtils.ChainToPositions('P1_ENEM01_TransAttack_LandAttack_02'))

	-- So the commander doesnt get distracted
	ScenarioInfo.P1_EnemyCommander:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.P1_EnemyCommander:RemoveCommandCap('RULEUCC_Repair')

	-- Threads to wait for the unload to finish, before giving passengers a patrol
	ForkThread(P1_TransUnloadWatchThread, ScenarioInfo.P1_TransAttack_Transport_01, ScenarioInfo.P1_TransAttack_Units_01, 'P1_ENEM01_TransAttack_LandAttack_01')
	ForkThread(P1_TransUnloadWatchThread, ScenarioInfo.P1_TransAttack_Transport_02, ScenarioInfo.P1_TransAttack_Units_02, 'P1_ENEM01_TransAttack_LandAttack_01')
	ForkThread(P1_TransUnloadWatchThread, ScenarioInfo.P1_TransAttack_Transport_03, ScenarioInfo.P1_TransAttack_Units_03, 'P1_ENEM01_TransAttack_LandAttack_02')
end

function P1_TransUnloadWatchThread(transport, group, chain)
	local attached = true
	while attached do
		WaitSeconds(3)
		if transport:IsDead() then
			return
		end
		attached = false
		for num, unit in group do
			if not unit:IsDead() and unit:IsUnitState('Attached') then
				attached = true
				break
			end
		end
	end
	ScenarioFramework.GroupPatrolRoute(group, ScenarioUtils.ChainToPositions(chain))
end

---------------------------------------------------------------------
-- VO AND RELATED FUNCTIONS:
---------------------------------------------------------------------
function P1_ZoeContact()
	ScenarioFramework.Dialogue(OpDialog.U04_ZOE_CONTACT, P1_ResearchSecondary_VO)
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.U04_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.U04_S4_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S4_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.U04_S4_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S4_obj10)

	ScenarioInfo.S4_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.U04_RESEARCH_FOLLOWUP_SHIELDS_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (P1_ResearchReminder1, 300)
end

function P1_ResearchReminder1()
	if ScenarioInfo.S4_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.U04_RESEARCH_REMINDER_010)
	end
end

function P1_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Brutal Conqueror
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H1_obj10 - Brutal Conqueror')
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.U04_H1_obj10_NAME,			-- title
		OpStrings.U04_H1_obj10_DESC,			-- description
		SimObjectives.GetActionIcon('kill'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)
end

function P1_AlliedFatboyDamaged()
	LOG('----- P1: Allied fatboy was damaged')
	-- Warn player fatboy is under attack. Using a counter in case we decided we want more instaces of damage VO.
	AlliedFatboyDamagedCount = AlliedFatboyDamagedCount + 1

	if AlliedFatboyDamagedCount == 1 then
		-- warn player that allied fatboy is under attack
		ScenarioFramework.Dialogue(OpDialog.U04_EXP_ALLY_FATBOY_DAMAGED_010)
	end
end

function P1_AlliedFatboyDestroyed()
	LOG('----- P1: Allied fatboy was destroyed')
	AlliedFatboyDestroyedCount = AlliedFatboyDestroyedCount + 1

	if AlliedFatboyDestroyedCount == 1 then
		-- Play VO noting that the first allied fatboy got destroyed, if the final transport attack isnt in progress.
		-- ( at that point, this VO doesnt really make sense, since the Op is nearly over).
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ALLY_FATBOY_DESTROYED_010)
		end
	elseif AlliedFatboyDestroyedCount == 2 then
		-- Play VO noting that the second allied fatboy got destroyed.
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ALLY_FATBOY_DESTROYED_020)
		end
	elseif AlliedFatboyDestroyedCount == 3 then
		-- Play VO noting that the third allied fatboy got destroyed.
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ALLY_FATBOY_DESTROYED_030)
		end

	-- So we don't get too predicatable, skip an ally fatboy death
	elseif AlliedFatboyDestroyedCount == 5 then
		-- Play VO noting that the fourt allied fatboy got destroyed.
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ALLY_FATBOY_DESTROYED_040)
		end
	end
end

function P1_EnemyFatboyDestroyed()
	LOG('----- P1: Enemy fatboy was destroyed')
	EnemyFatboyDestroyedCount = EnemyFatboyDestroyedCount + 1

	if EnemyFatboyDestroyedCount == 1 then
		-- Play VO noting that an enemy fatboy got destroyed, if the final transport attack isnt in progress.
		-- ( at that point, this VO doesnt really make sense, since the Op is nearly over).
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ENEMY_FATBOY_DESTROYED_010)
		end
	elseif EnemyFatboyDestroyedCount == 2 then
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ENEMY_FATBOY_DESTROYED_020)
		end

	-- Skip a death, so things dont get too predictable
	elseif EnemyFatboyDestroyedCount == 4 then
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ENEMY_FATBOY_DESTROYED_030)
		end
	elseif EnemyFatboyDestroyedCount == 5 then
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_EXP_ENEMY_FATBOY_DESTROYED_040)
		end
	end
end

function P1_NorthwestFatboyBuiltVO()
	LOG('----- P1: NW Gatry unit built VO ')

	-- Play VO noting that a fatboy has been built at the NW gantry.
	-- Check who holds the gantry (and thus which army the fatboy will get assigned to),
	-- and play the appropriate VO

	-- first, check that the final transport attack isnt in progress. As that represents the
	-- near-end of the op, it isnt appropriate to play this VO at that point.
	if not ScenarioInfo.P1_TransportAttackInProgress then
		if ScenarioInfo.NW_Gantry_Friendly == true then
			NorthwestAllyFatboyVOCount = NorthwestAllyFatboyVOCount + 1
			if NorthwestAllyFatboyVOCount == 1 then
				ScenarioFramework.Dialogue(OpDialog.U04_NW_EXP_ALLY_BUILT_010)
			end
		else
			NorthwestEnemyFatboyVOCount = NorthwestEnemyFatboyVOCount + 1
			if NorthwestEnemyFatboyVOCount == 1 then
				ScenarioFramework.Dialogue(OpDialog.U04_NW_EXP_ENEM_BUILT_010)
			end
		end
	end
end

function P1_SoutheasttFatboyBuiltVO()
	LOG('----- P1: SE Gatry unit built VO ')

	-- Play VO noting that a fatboy has been built at the SE gantry.
	-- Check who holds the gantry (and thus which army the fatboy will get assigned to),
	-- and play the appropriate VO

	-- first, check that the final transport attack isnt in progress. As that represents the
	-- near-end of the op, it isnt appropriate to play this VO at that point.
	if not ScenarioInfo.P1_TransportAttackInProgress then
		if ScenarioInfo.SE_Gantry_Friendly == true then
			SoutheastAllyFatboyVOCount = SoutheastAllyFatboyVOCount + 1
			if SoutheastAllyFatboyVOCount == 1 then
				ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_ALLY_BUILT_010)
			end
		else
			SoutheastEnemyFatboyVOCount = SoutheastEnemyFatboyVOCount + 1
			if SoutheastEnemyFatboyVOCount == 1 then
				ScenarioFramework.Dialogue(OpDialog.U04_SE_EXP_ENEM_BUILT_010)
			end
		end
	end
end

function P1_PlayerAtColemanBaseThread()
	WaitSeconds(5)
	local count = ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS, 'EnemyBaseArea_01', ArmyBrains[ARMY_PLAYER])

	-- If the player keeps a sizable force in the area, play VO from a worried Coleman
	if count >= 12 then
		-- Dont play the VO if we are in the end-game, and Coleman is already doing his Hail Mary.
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_ATTACK_COLEMAN_STRONG_010)
		end

	-- but if the player instead has a weak force in the area, then play VO from a confident Coleman.
	elseif count > 0 and count < 12 then
		if not ScenarioInfo.P1_TransportAttackInProgress then
			ScenarioFramework.Dialogue(OpDialog.U04_ATTACK_COLEMAN_WEAK_010)
		end

	-- if the player didnt actually stick around (perhaps they merely clipped the trigger area with a group)
	-- then wait a bit and reset the system to check again. Keep the detect value rather low, so we can catch a wussy
	-- group from the player as well as large groups (so we have the opportunity to play both types of related VO).
	else
		WaitSeconds(2)
		ScenarioFramework.CreateAreaTrigger(
			function()
				ForkThread(P1_PlayerAtColemanBaseThread)
			end,
			'EnemyBaseArea_01',
			categories.ALLUNITS,
			true,
			false,
			ArmyBrains[ARMY_PLAYER],
			5,
			false
		)
	end
end

function P1_AllyFatboyKilled_VO()
	LOG('----- P1: Ally fatboy death, VO: ')
	-- play some VO on the first and third fatboy lost.
	AllyFatboysKilled_VO = AllyFatboysKilled_VO + 1
	if AllyFatboysKilled_VO == 1 then
		ScenarioFramework.Dialogue(OpDialog.U04_BANTER_010)
	elseif AllyFatboysKilled_VO == 2 then
		ScenarioFramework.Dialogue(OpDialog.U04_BANTER_020)
	end
end

function P1_PlayerKilledFatboys_VO()
	LOG('----- P1:Player killed fatboys, VO ')
	ScenarioFramework.Dialogue(OpDialog.U04_BANTER_030)
end

function P1_EnemyKilledMass_VO()
	LOG('----- P1: Enemy killed mass, VO')
	ScenarioFramework.Dialogue(OpDialog.U04_BANTER_040)
end

---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------
function P1_EnemyCommander_DeathDamage(CDRUnit)
	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_EXPENEM],
			ArmyBrains[ARMY_EXPALLY],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 50.0, true, 5000, 90001, brainList)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function LaunchVictoryNIS(unit)
	-- set a flag for an exclusivity check, so the Hail Mary NIS doesnt happen.
	ScenarioInfo.VictoryNISBeginning = true

	ForkThread(
		function()
			-- disable the exp base managers, so things are clean for the NIS.
			ScenarioInfo.ArmyBase_EXPALLY_SW_Gantry:BaseActive(false)
			ScenarioInfo.ArmyBase_EXP01_NW_Gantry:BaseActive(false)
			ScenarioInfo.ArmyBase_EXP01_SE_Gantry:BaseActive(false)

			ScenarioInfo.AssignedObjectives.VictoryCallbackList = {}
			if not ScenarioInfo.S2_obj10.Complete and not ScenarioInfo.S3_obj10.Complete then
				table.insert(ScenarioInfo.AssignedObjectives.VictoryCallbackList, P1_HiddenObj1Complete)
			end
			OpNIS.NIS_VICTORY(unit)
		end
	)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	P1_EnableSEFatboyOpAI()
end

function OnShiftF4()
-- 	func_TRANSPORT_ATTACK_TransportsLoad()

	LaunchVictoryNIS(ScenarioInfo.P1_EnemyCommander)
end

function OnShiftF5()
	func_TRANSPORT_ATTACK_MoveTransports()
end

function OnCtrlF3()
	func_TRANSPORT_ATTACK_NukeSequence()
end

function OnCtrlF4()
	func_TRANSPORT_ATTACK_TransportsUnload()
end

function OnCtrlF5()
	func_TRANSPORT_ATTACK_Cleanup()
end

