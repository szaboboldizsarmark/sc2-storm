---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_U06/SC2_CA_U06_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_U06/SC2_CA_U06_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_U06/SC2_CA_U06_OpNIS.lua')
local ScenarioUtils			= import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework		= import('/lua/sim/ScenarioFramework.lua')
local ScenarioGameSetup		= import('/lua/sim/ScenarioFramework/ScenarioGameSetup.lua')
local ScenarioGameTuning	= import('/lua/sim/ScenarioFramework/ScenarioGameTuning.lua')
local ScenarioGameEvents	= import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua')
local ScenarioGameCleanup	= import('/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua')
local ScenarioGameNames		= import('/lua/sim/ScenarioFramework/ScenarioGameNames.lua')
local ScenarioPlatoonAI 	= import('/lua/AI/ScenarioPlatoonAI.lua')
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
ScenarioInfo.ARMY_REACTOR = 3
ScenarioInfo.ARMY_ALLY01 = 4

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.P2_TransportAttacksPaused		= false
ScenarioInfo.P2_HeavyTrans_LandAtPlayer		= true
ScenarioInfo.P2_PauseCounter 				= 0

-- Base group, and variable-sized additional group:
-- Potential units to use:
			-- P2_ENEM01_HeavyTransAttack_Tank
			-- P2_ENEM01_HeavyTransAttack_AssaultBot
			-- P2_ENEM01_HeavyTransAttack_MobArtillery
			-- P2_ENEM01_HeavyTransAttack_MMissile
			-- P2_ENEM01_HeavyTransAttack_AA
			-- P2_ENEM01_HeavyTransAttack_ShieldGen
			-- P2_ENEM01_HeavyTransAttack_MobAntiMissile
-- ***WARNING: the sum of these two tables must not be greater than the capacity of a UEF transport! ***
ScenarioInfo.P2_HeavyTransportAttack_BaseGroup = {
	'P2_ENEM01_HeavyTransAttack_Tank', 			-- 1
	'P2_ENEM01_HeavyTransAttack_Tank',			-- 2
	'P2_ENEM01_HeavyTransAttack_Tank',			-- 3
	'P2_ENEM01_HeavyTransAttack_Tank',			-- 4
	'P2_ENEM01_HeavyTransAttack_AssaultBot',	-- 5
	'P2_ENEM01_HeavyTransAttack_AssaultBot',	-- 6
}

ScenarioInfo.P2_HeavyTransportAttack_AddSpawnOrder = {
	'P2_ENEM01_HeavyTransAttack_Tank', 			-- 1
	'P2_ENEM01_HeavyTransAttack_Tank',			-- 2
	'P2_ENEM01_HeavyTransAttack_Tank',			-- 3
	'P2_ENEM01_HeavyTransAttack_AssaultBot',	-- 4
	'P2_ENEM01_HeavyTransAttack_AssaultBot',	-- 5
	'P2_ENEM01_HeavyTransAttack_MobArtillery',	-- 6
	'P2_ENEM01_HeavyTransAttack_MobArtillery',	-- 7
	'P2_ENEM01_HeavyTransAttack_ShieldGen',		-- 8
	'P2_ENEM01_HeavyTransAttack_MMissile',		-- 9
	'P2_ENEM01_HeavyTransAttack_MMissile',		-- 10
}

-- Part 2 Heavy Transport Attack destinations:
ScenarioInfo.P2_HeavyTrans_PlayerDestinations = {
	'P2_TransHeavy_Landing_01',
	'P2_TransHeavy_Landing_02',
	'P2_TransHeavy_Landing_03',
}
ScenarioInfo.P2_HeavyTrans_ReactorDestinations = {
	'P2_TransHeavy_AltLanding_01',
	'P2_TransHeavy_AltLanding_02',
	'P2_TransHeavy_AltLanding_03',
}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_REACTOR = ScenarioInfo.ARMY_REACTOR
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01

-- create a set of tracking values for managing the unique start scenario
local P2_PlayerUnlockList = nil

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local P2_HeavyTransportCount						= 0
local SurgicalTriggerCounter						= 0

-- Part2 Light Transport Attack Stream unit-type weighting values.
local P2_TransportStreamLight_ShieldWeight 			= 7
local P2_TransportStreamLight_PointDefWeight 		= 3
local P2_TransportStreamLight_ExperimentalWeight 	= 33
local P2_TransportStreamLight_MobLandWeight 		= 1
local P2_TransportStreamLight_GunshipWeight 		= 3
local P2_TransportStreamLight_BomberWeight 			= 2
local P2_TransportStreamLight_WeightMultiplier		= 0.55	-- lower value means gentler difficulty curve

-- Part2 Heavy Transport Attack Stream settings and attack makeup.
local P2_TransportStreamHeavy_Mod					= 10
local P2_HeavyTransportAttack_Delay					= 330

-- Part2 Air Attack weights and delays.
local P2_LightAirAttackDelay						= 95	-- delay between light offmap air attacks, seconds.
local P2_HeavyAirAttackDelay						= 590
local P2_AirStream_ShieldWeight						= 6
local P2_AirStream_AATowerWeight					= 8
local P2_AirStream_FighterWeight					= 4.5
local P2_AirStream_MobileAAWeight					= 5
local P2_AirStream_MobileShieldWeight 				= 1
local P2_AirStream_GeneralLandWeight				= 1

---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.3,		-- 1.3 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	-- perform special handling for the player - unique to this operation
	SpecialPlayerSetup_Step1()

	-- now setup all the other armies
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.U06_ARMY_ENEM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_REACTOR,	ScenarioGameTuning.U06_ARMY_REACTOR)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ALLY01,	ScenarioGameTuning.U06_ARMY_ALLY01)

	-- start anti-nuke managers for any enemy anti-nuke launchers
	import('/lua/sim/ScenarioFramework/ScenarioGameUtilsAntiNuke.lua').StartAntiNukeManagers()
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
		areaStart		= 'P1_Playable_Area',	-- if valid, the area to be used for setting the starting playable area
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

	LOG('----- P1_Setup: Setup for the player CDR.')
	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Starting_Mobiles_1')
	ScenarioInfo.INTRONIS_Group2 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Starting_Mobiles_2')
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_CommanderGroup')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group1, 1)
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group2, 1)

	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_01')
	ScenarioInfo.INTRONIS_Group2Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_02')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_03')

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- perform special handling for the player - unique to this operation
	SpecialPlayerSetup_Step2()


	---- Enemy Setup, Attacks in progress:
	-- land from the NE
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitAttack_Ground_01', 'AttackFormation')
	for i = 2, 3 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitAttack_Ground_0' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_TransAttack_Attack_Chain_01')
	end

	-- land from the West
	for i = 1, 2 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitAttack_Groundb_0' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ALLY01_LandAttack_01_Chain') -- convenient chain to use
	end

	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AirAttack_Group_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_AirAttack_Chain')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitAttack_Air_01', 'AttackFormation')
	RandomPatrolThread(platoon, 'P2_ALLY01_MainAir_Defense_Chain', ARMY_ENEM01)


	---- Enemy Setup, player barriers, and some death triggers for a couple, to trigger VO.
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_WestGroup_01_Patrol')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_03', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_WestGroup_03_Patrol')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_05', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_WestGroup_05_Patrol')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_06', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_WestGroup_06_Patrol')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_07', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_WestGroup_07_Patrol')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_08', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_WestGroup_08_Patrol')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_09', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_WestGroup_09_Patrol')
	local platoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_02', 'AttackFormation')
	local platoon4 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_WestGroup_04', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon2, 'P1_ENEM01_WestGroup_02_Patrol')
	ScenarioFramework.PlatoonPatrolChain(platoon4, 'P1_ENEM01_WestGroup_04_Patrol')
	ScenarioFramework.CreatePlatoonDeathTrigger(P1_AllyBanter01_VO, platoon2)
	ScenarioFramework.CreatePlatoonDeathTrigger(P1_AllyBanter02_VO, platoon4)

	---- Enemy Units
	---NOTE: there were originally intended as NIS only - but for awhile now they have been a part of the gameplay - so making it official
	---			additionally - in P1_MAIN, I am now giving these air units something to do - bfricks 12/6/09
	ScenarioInfo.OPENING_AIR	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'OPENING_AIR')
	ScenarioInfo.OPENING_GROUND	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'OPENING_GROUND')

	---- Ally Setup
	ScenarioInfo.ALLY_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_CDR')
	ScenarioInfo.ALLY_CDR:SetCustomName(ScenarioGameNames.CDR_Greer)
	ScenarioFramework.GroupPatrolChain( {ScenarioInfo.ALLY_CDR}, 'ArmyBase_P1_ALLY01_Main_Base_EngineerChain' )
	ProtectUnit(ScenarioInfo.ALLY_CDR)

	---NOTE: because it can look bad, protected ally CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.ALLY_CDR:RemoveCommandCap('RULEUCC_Reclaim')

	ScenarioUtils.CreateArmyGroup( 'ARMY_ALLY01', 'P1_AllyWreckage', true ) -- wreckage

	-- Initial patrols in West area
	for i = 1, 4 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_WestGroup_0' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ALLY01_GeneralWest_Patrol')
	end

	-- Initial patrols at base
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_BasePatrol_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ALLY01_LandAttack_01_Chain')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_BasePatrol_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ALLY01_LandAttack_01_Chain')
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_InitAirDef_01', 'AttackFormation')
	RandomPatrolThread(platoon, 'P2_ALLY01_MainAir_Defense_Chain', ARMY_ALLY01)


	-- Sationary group to the west, to get shot up, and some sundry out structures as well.
	 ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_BaseSationary_01', 'AttackFormation')
	ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_WestStructures_01')

	P1_AllyAISetup()
end

function P1_Main()
	----------------------------------------------
	-- Primary Objective 1 - Rescue Ally
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Rescue Ally.')
	local descText = OpStrings.U06_M1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U06_M1_obj10_HELP_GREER)
	ScenarioInfo.M1_obj10 = SimObjectives.CategoriesInArea(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.U06_M1_obj10_NAME,		-- title
		descText,							-- description
		'protect',							-- Action
		{
			MarkArea = true,
			Requirements = {
				{Area = 'P1_ObjectiveArea', Category = categories.ALLUNITS, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
			},
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)
	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				-- Turn off attack stream
				ScenarioInfo.P1_StreamAttacksAllowed = false

				-- Begin setup, that will lead to the NIS
				P2_Setup()
			end
		end
	)

	-- Begin the stream of transport attacks against ally. Each call the the attack function begins an instance of a looping
	-- spawn/attack sequence.
	ScenarioInfo.P1_StreamAttacksAllowed = true
	ForkThread(P1_LandAttackWithTransport)
	ScenarioFramework.CreateTimerTrigger (P1_LandAttackWithTransport, 30)
	ScenarioFramework.CreateTimerTrigger (P1_LandAttackWithTransport, 60)

	-- Air attack stream, death-trigger based.
	ScenarioFramework.CreateTimerTrigger (P1_AirAttackStream, 20)
	ScenarioFramework.CreateTimerTrigger (P1_AirAttackStream, 50)

	-- make the opening air group really easy to kill
	for k, unit in ScenarioInfo.OPENING_AIR do
		if unit and not unit:IsDead() then
			unit:DisableShield()
			unit:SetMaxHealth( 1 )
			unit:AdjustHealth( unit, 1 )
		end
	end

	-- send the opening air units around and to Greer
	IssueFormMove(ScenarioInfo.OPENING_AIR, ScenarioUtils.MarkerToPosition('OPENING_AIR_MOVE_01'), 'AttackFormation', 0 )
	IssueFormMove(ScenarioInfo.OPENING_AIR, ScenarioUtils.MarkerToPosition('OPENING_AIR_MOVE_02'), 'AttackFormation', 0 )
	IssueFormPatrol(ScenarioInfo.OPENING_AIR, ScenarioUtils.MarkerToPosition('OPENING_AIR_PATROL_01'), 'AttackFormation', 0 )
	IssueFormPatrol(ScenarioInfo.OPENING_AIR, ScenarioUtils.MarkerToPosition('OPENING_AIR_PATROL_02'), 'AttackFormation', 0 )
	IssueFormPatrol(ScenarioInfo.OPENING_AIR, ScenarioUtils.MarkerToPosition('OPENING_AIR_PATROL_03'), 'AttackFormation', 0 )
end

function P1_AllyAISetup()
	LOG('---- P1: Setting up ally base and OpAI')
	---- Ally main base
	local levelTable_P1_ALLY01_Main_Base 	= { P1_ALLY01_MainBase_100 = 100,
												P1_ALLY01_MainBase_90 = 90,
												P1_ALLY01_MainBase_80 = 80}
	ScenarioInfo.ArmyBase_P1_ALLY01_Main_Base = ArmyBrains[ARMY_ALLY01].CampaignAISystem:AddBaseManager('ArmyBase_P1_ALLY01_Main_Base',
		 'P1_ALLY01_MainBase_Marker', 50, levelTable_P1_ALLY01_Main_Base)
	ScenarioInfo.ArmyBase_P1_ALLY01_Main_Base:	StartNonZeroBase(3)

	-- Set a folder of units in the ally base to protected. These units will get effectively unprotected when they are swapped to the player army.
	local tblData = ScenarioUtils.FindUnitGroup( 'P1_ALLY01_MainBase_100', Scenario.Armies['ARMY_ALLY01'].Units )
	for k, v in tblData.Units do
		local unit = ScenarioInfo.UnitNames[ARMY_ALLY01][k] -- .Units is 'name' = {stuff} , so we use the key here to get the name string.
		ProtectUnit(unit)
	end
	local tblData = ScenarioUtils.FindUnitGroup( 'P1_ALLY01_MainBase_90', Scenario.Armies['ARMY_ALLY01'].Units )
	for k, v in tblData.Units do
		local unit = ScenarioInfo.UnitNames[ARMY_ALLY01][k]
		ProtectUnit(unit)
	end

	-- basic land attack
	ScenarioInfo.P1_ALLY01_LandAttack_01_OpAI		= ScenarioInfo.ArmyBase_P1_ALLY01_Main_Base:AddOpAI('LandAttackUEF', 'P1_ALLY01_LandAttack_01_OpAI', {} )
	local P1_ALLY01_LandAttack_01_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_ALLY01_LandAttack_01_Chain',},}
	ScenarioInfo.P1_ALLY01_LandAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_LandAttack_01_OpAI_Data )

	ScenarioInfo.P1_ALLY01_LandAttack_01_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ALLY01_LandAttack_01_OpAI:		SetMaxActivePlatoons(2)

	-- Defense Air patrol
	ScenarioInfo.P1_ALLY01_AirDef_01_OpAI			= ScenarioInfo.ArmyBase_P1_ALLY01_Main_Base:AddOpAI('AirFightersUEF', 'P1_ALLY01_AirDef_01_OpAI', {} )
	local P1_ALLY01_AirDef_01_OpAI_Data				= {PatrolChain = 'P2_ALLY01_MainAir_Defense_Chain',}
	ScenarioInfo.P1_ALLY01_AirDef_01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', P1_ALLY01_AirDef_01_OpAI_Data )

	ScenarioInfo.P1_ALLY01_AirDef_01_OpAI:			SetChildCount(2) -- Size of each platoon
	ScenarioInfo.P1_ALLY01_AirDef_01_OpAI:			SetMaxActivePlatoons(2)
end

function P1_AirAttackStream()
	if ScenarioInfo.P1_StreamAttacksAllowed then
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AirAttack_Group_01', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ALLY01_LandAttack_01_Chain')
		ScenarioFramework.CreatePlatoonDeathTrigger (P1_AirAttackStream, platoon)
	end
end

function P1_LandAttackWithTransport()
	if ScenarioInfo.P1_StreamAttacksAllowed then
		LOG('----- P2: Transport Attack being created')

		local data = {
			armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
			units					= 'P1_ENEM01_TransAttack_Group_01',		-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= 'P1_ENEM01_TransAttack_Transport_01',	-- unit handle for the actual transport
			approachChain			= nil,									-- optional chainName for the approach travel route
			unloadDest				= 'P2_ENEM01_TransAttack_Landing_01',	-- destination for the transport drop-off
			returnDest				= 'P1_TransAttack_Return_Marker',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
			OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
			onUnloadCallback		= P1_TransAttackLanding,				-- optional function to call when the transport finishes unloading
		}
		TransportUtils.SpawnTransportDeployGroup(data)
	end
end

function P1_TransAttackLanding(platoon)
	if platoon and ArmyBrains[ScenarioInfo.ARMY_PLAYER]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain (platoon, 'P2_ENEM01_TransAttack_Attack_Chain_01')
		ScenarioFramework.CreatePlatoonDeathTrigger (P1_LandAttackWithTransport, platoon)
	end
end

function P1_AllyBanter01_VO()
	if ScenarioInfo.PartNumber == 1 then
		LOG('----- P1: banter VO playing.')
		ScenarioFramework.Dialogue(OpDialog.U06_BANTER_GREER_010)
	end
end

function P1_AllyBanter02_VO()
	if ScenarioInfo.PartNumber == 1 then
		LOG('----- P1: banter VO playing.')
		ScenarioFramework.Dialogue(OpDialog.U06_BANTER_GREER_020)
	end
end

function OnSelect_CDR()
	if ScenarioInfo.PartNumber == 1 then
		if not ScenarioInfo.OnSelect_CDR_Selected then
			LOG('----- P1: OnSelect_CDR()')
			ScenarioInfo.OnSelect_CDR_Selected = true

			Sync.ShowUIDialog = { OpStrings.ONSELECT_CDR, "<LOC _OK>OK", "", "", "", "", "" }

		    ---		if(not Sync.PrintText) then
		    ---		    Sync.PrintText = {}
		    ---		end
            ---
			---		-- print custom information
			---		local data = {
			---			text = LOC(OpStrings.ONSELECT_CDR),
			---			size = 24,
			---			color = 'ffffffff',
			---			duration = 5.0,
			---			location = 'center'
			---		}
            ---
			---		table.insert(Sync.PrintText, data)
		end
	end
end

---------------------------------------------------------------------
-- PART 2:
---------------------------------------------------------------------
function P2_Setup()
	LOG('----- P2_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 2

	-- allow player to build units again normally
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, P2_PlayerUnlockList)

	-- Create tables for West-Camp and East-Camp fighter platoons that get destroyed when the camp switch is blown up.
	ScenarioInfo.P2_WestCampAirPlatoons = {}
	ScenarioInfo.P2_EastCampAirPlatoons = {}

	------------------
	-- Objective units
	------------------

	-- Reactor. Protected until switches are destroyed.
	ScenarioInfo.P2_ReactorStructure = ScenarioUtils.CreateArmyUnit('ARMY_REACTOR', 'P2_ReactorStructure')
	ProtectUnit(ScenarioInfo.P2_ReactorStructure)
	ScenarioInfo.P2_ReactorStructure:SetCustomName(ScenarioGameNames.UNIT_SCB1601)


	-- 3 reactor switches. These are objective units, and as well, when west/east die, a special event takes place.
	ScenarioInfo.P2_ReactorSwitch_West = ScenarioUtils.CreateArmyUnit('ARMY_REACTOR', 'P2_ReactorSwitch_West')
	ScenarioInfo.P2_ReactorSwitch_Central = ScenarioUtils.CreateArmyUnit('ARMY_REACTOR', 'P2_ReactorSwitch_Central')
	ScenarioInfo.P2_ReactorSwitch_East = ScenarioUtils.CreateArmyUnit('ARMY_REACTOR', 'P2_ReactorSwitch_East')

    ScenarioInfo.P2_ReactorSwitch_West:SetReclaimable(false)
    ScenarioInfo.P2_ReactorSwitch_West:SetCapturable(false)
    ScenarioInfo.P2_ReactorSwitch_West:SetCanBeKilled(false)
	ScenarioInfo.P2_ReactorSwitch_West:SetCustomName(ScenarioGameNames.UNIT_SCB1602)
	ScenarioFramework.CreateUnitHealthRatioTrigger( P2_WestSwitchResponse, ScenarioInfo.P2_ReactorSwitch_West, .05, true, true )


    ScenarioInfo.P2_ReactorSwitch_Central:SetReclaimable(false)
    ScenarioInfo.P2_ReactorSwitch_Central:SetCapturable(false)
    ScenarioInfo.P2_ReactorSwitch_Central:SetCanBeKilled(false)
	ScenarioInfo.P2_ReactorSwitch_Central:SetCustomName(ScenarioGameNames.UNIT_SCB1602)
	ScenarioFramework.CreateUnitHealthRatioTrigger( P2_CentralSwitchResponse, ScenarioInfo.P2_ReactorSwitch_Central, .05, true, true )

    ScenarioInfo.P2_ReactorSwitch_East:SetReclaimable(false)
    ScenarioInfo.P2_ReactorSwitch_East:SetCapturable(false)
    ScenarioInfo.P2_ReactorSwitch_East:SetCanBeKilled(false)
	ScenarioInfo.P2_ReactorSwitch_East:SetCustomName(ScenarioGameNames.UNIT_SCB1602)
	ScenarioFramework.CreateUnitHealthRatioTrigger( P2_EastSwitchResponse, ScenarioInfo.P2_ReactorSwitch_East, .05, true, true )

	ScenarioInfo.P2_ObjectiveSwitches = {}
	table.insert(ScenarioInfo.P2_ObjectiveSwitches, ScenarioInfo.P2_ReactorSwitch_West)
	table.insert(ScenarioInfo.P2_ObjectiveSwitches, ScenarioInfo.P2_ReactorSwitch_Central)
	table.insert(ScenarioInfo.P2_ObjectiveSwitches, ScenarioInfo.P2_ReactorSwitch_East)

	------------------
	-- General Enemy setup
	------------------

	-- Mid area defensive structures (surrounds the mid Switch)
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_Mid_DefenseStructures')

	-- Patrols that circle the Central Switch (close enough to be destroyed by its explosion)
	ScenarioInfo.P2_ENEM01_MidSwitchPatrol01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Mid_SwitchPatrol_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P2_ENEM01_MidSwitchPatrol01, 'P2_ENEM01_Mid_SwitchPatrol_01_Chain')
	ScenarioInfo.P2_ENEM01_MidSwitchPatrol02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Mid_SwitchPatrol_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P2_ENEM01_MidSwitchPatrol01, 'P2_ENEM01_Mid_SwitchPatrol_02_Chain')

	-- Two Experimental platoons in the back central area, which will move toward the player when all 3 switches are destroyed.
	ScenarioInfo.P2_CentralExperimentalGroup_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_MidLand_01', 'AttackFormation')
	ScenarioInfo.P2_CentralExperimentalGroup_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_MidLand_02', 'AttackFormation')
	ScenarioInfo.P2_CentralExperimentalGroup_03 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_MidLand_03', 'AttackFormation')
	-- If any of these near the players base, the attack streams will unpause until there are none around again.
	-- Also, another set of distance triggers looks to see if the player kills the Kriptors before they clear the bridge. If so,
	-- we dont set a failure flag that is checked at the end of the Op.
	-- And finally, we generate a list of all the kriptors - which we will use to force complete the objective if they are all killed
	ScenarioInfo.KriptorList = {}
	local units = ScenarioInfo.P2_CentralExperimentalGroup_01:GetPlatoonUnits()
    for k,v in units do
        if EntityCategoryContains( categories.uux0111, v ) then
        	table.insert(ScenarioInfo.KriptorList,v)
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P2_PauseTransportAttacks, v, 'P2_ExperimentalCheckLocation', 110 )
        	ScenarioFramework.CreateUnitToMarkerDistanceTrigger( function() ScenarioInfo.P2_FailedHiddenObj2 = true end, v, 'P2_HiddenObjective_Distance_Marker', 116)
        end
    end
   	local units = ScenarioInfo.P2_CentralExperimentalGroup_02:GetPlatoonUnits()
    for k,v in units do
        if EntityCategoryContains( categories.uux0111, v ) then
        	table.insert(ScenarioInfo.KriptorList,v)
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P2_PauseTransportAttacks, v, 'P2_ExperimentalCheckLocation', 110 )
        	ScenarioFramework.CreateUnitToMarkerDistanceTrigger( function() ScenarioInfo.P2_FailedHiddenObj2 = true end, v, 'P2_HiddenObjective_Distance_Marker', 116)
        end
    end
 	local units = ScenarioInfo.P2_CentralExperimentalGroup_03:GetPlatoonUnits()
    for k,v in units do
        if EntityCategoryContains( categories.uux0111, v ) then
        	table.insert(ScenarioInfo.KriptorList,v)
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P2_PauseTransportAttacks, v, 'P2_ExperimentalCheckLocation', 110 )
        	ScenarioFramework.CreateUnitToMarkerDistanceTrigger( function() ScenarioInfo.P2_FailedHiddenObj2 = true end, v, 'P2_HiddenObjective_Distance_Marker', 116)
        end
    end

	-- add a death trigger for the kriptos - if they all die, complete the objective
	ScenarioFramework.CreateGroupDeathTrigger( function() P1_HiddenObj2Complete(true) end, ScenarioInfo.KriptorList )

	-- setup enemy bases and OpAIs: function should run at end of P2_Setup(). Broken out to separate bases for clarity.
	P2_AISeteup_WestAirCamp()
	P2_AISeteup_EastAirCamp()
	P2_AISeteup_BridgeBase()

	-- Give permanent viz for the reactor, and the surrounding area.
	ScenarioFramework.CreateIntelAtLocation(125, 'P2_ReactorArea_Vis_Marker', ARMY_PLAYER, 'Vision')

	-- Create p2 area tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_TechCache')

	ForkThread(P2_Transition)
end

function P2_PlayerBuiltNukeLauncher(builder, nukeLauncher)
    if builder:GetArmy() != ARMY_PLAYER then
        return
    end

	-- uub0107 is the UEF Tactical/Nuclear missile launch facility
    if not EntityCategoryContains( categories.uub0107, nukeLauncher ) then
        return
    end

    local nukeWeapon = nukeLauncher:GetWeapon('NukeMissiles')

    if ( not nukeWeapon ) then
        error("No nuke weapon found named 'NukeMissiles' for nuke launcher")
        return
    end

    LOG('---- P2: Nuke Objective: Setting up nuke callbacks')
    local UUB0107 = import('/units/uef/uub0107/uub0107_script.lua').UUB0107
    nukeWeapon.OnWeaponFired = function(weapon)
        -- Call the function for the launcher
        P2_PlayerNukeLaunched(nukeLauncher)

        UUB0107.Weapons.NukeMissiles.OnWeaponFired(weapon)
    end
end

function P2_PlayerNukeLaunched(unit)
	if not ScenarioInfo.P2_NukeObjectiveCompleted then
		ScenarioInfo.P2_NukeObjectiveCompleted = true
		LOG('---- P2: Nuke Objective: Calling objective completion')
		P1_HiddenObj1Complete()
	end
end

function P2_Transition()
	-- Protect the player for the duration of the upcoming NIS
	---NOTE: while this is redundant, it should not be problematic - bfricks 10/18/09
	ProtectUnit(ScenarioInfo.PLAYER_CDR)

	OpNIS.NIS_REVEAL_ENEMY()

	-- Player CDR back to normal, now that the NIS is completed.
	---NOTE: while this is redundant, it should not be problematic - bfricks 10/18/09
	UnProtectUnit(ScenarioInfo.PLAYER_CDR)

	-- handle cleanup of all the special conditions
	SpecialPlayerCleanup()

	-- queue up the point award
	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U06_M1_obj10_HELP_GREER, ARMY_PLAYER, 3.0)

	P2_Main()
end

function P2_Main()
	LOG('----- P2_Main:')
	----------------------------------------------
	-- Primary Objective 3 - Destroy Reactor Shielding Relays
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective 3 - Destroy Sheilding relays.')
	local descText = OpStrings.U06_M2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U06_M2_obj10_KILL_RELAYS)
	ScenarioInfo.M2_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.U06_M2_obj10_NAME,		-- title
		descText,							-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = ScenarioInfo.P2_ObjectiveSwitches,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)
	ScenarioInfo.M2_obj10:AddProgressCallback(
		function(current)
			if current == 1 then
				ScenarioFramework.Dialogue(OpDialog.U06_M2_obj10_PROGRESS_010)
				ScenarioFramework.Dialogue(OpDialog.U06_BANTER_RODGERS_020)
			elseif current == 2 then
				ScenarioFramework.Dialogue(OpDialog.U06_M2_obj10_PROGRESS_020)
			end
		end
	)
	ScenarioInfo.M2_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U06_M2_obj10_KILL_RELAYS, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.U06_M2_obj10_COMPLETE)
				---NOTE: intentionally moving this specific objective to coincide with the dialog - it makes sense here due to the wording - bfricks 11/21/09
				P2_ReactorObjective()
			end
		end
	)

	-- Setup trigger for player building a nuke launcher; this is for the hidden objective
	local Unit = import('/lua/sim/Unit.lua').Unit
	Unit.ClassCallbacks.OnStopBuild:Add( P2_PlayerBuiltNukeLauncher )


	-- turn off the ally base manager
	ScenarioInfo.ArmyBase_P1_ALLY01_Main_Base:BaseActive(false)

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P2_ResearchSecondary_VO, 41)

	-- Enable a light transport attack stream, and a delayed heavy transport attack stream.
	ForkThread(P2_LightTransportStream_Thread)
	ScenarioFramework.CreateTimerTrigger(
		function()
			ForkThread(P2_HeavyTransportStream_Thread, 'P2_HeavyTrans_LandAtPlayer', ScenarioInfo.P2_HeavyTrans_PlayerDestinations)
		end,
		240
	)


	-- some VO from enemy when player kills a Kriptor.
	ScenarioFramework.CreateArmyStatTrigger (P2_EnemyBanter_VO, ArmyBrains[ARMY_ENEM01], 'P2_EnemyBanter_VO',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0111}})

	-- First heavy attack, and when we also start the heavy attack loop.
	ScenarioFramework.CreateTimerTrigger (P2_HeavyAttackLoop, 540)

	-- Enable light air attack loop after a delay
	ScenarioFramework.CreateTimerTrigger (P2_AirStreamThread, 95)


	-- Triggers that will begin a surgical response. Some will use a delay before actually calling the attack,
	-- so the player doesnt get hit immediately with a response.
	ScenarioFramework.CreateArmyStatTrigger (P2_SurgicalExpLand_Init, ArmyBrains[ARMY_PLAYER], 'P2_SurgicalExpLand',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category =(categories.EXPERIMENTAL * categories.LAND * categories.MOBILE) + categories.uub0105 + categories.NUKE}})

	ScenarioFramework.CreateArmyStatTrigger (P2_SurgicalExpAir_Init, ArmyBrains[ARMY_PLAYER], 'P2_SurgicalExpAir',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category =(categories.EXPERIMENTAL * categories.AIR)}})

	ScenarioFramework.CreateArmyStatTrigger (P2_SurgicalExcessAir, ArmyBrains[ARMY_PLAYER], 'P2_SurgicalExcessAir',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 55, Category = categories.AIR}})

	ScenarioFramework.CreateArmyStatTrigger (P2_SurgicalExcessLand, ArmyBrains[ARMY_PLAYER], 'P2_SurgicalExcessLand',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 75, Category =(categories.LAND * categories.MOBILE)}})

	ScenarioFramework.CreateArmyStatTrigger (P2_MassFabResponse_Init, ArmyBrains[ARMY_PLAYER], 'P2_MassFabResponse',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category =categories.uub0704}})
end

function P2_ReactorObjective()
	----------------------------------------------
	-- Primary Objective M2_obj10 - Destroy Reactor Core
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M2_obj10 - Destroy Reactor Core.')
	ScenarioInfo.M3_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.U06_M3_obj10_NAME,		-- title
		OpStrings.U06_M3_obj10_DESC,		-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			AlwaysVisible = true,
			ArrowOffset = -10.0,
			ArrowSize = 0.2,
			Units = {ScenarioInfo.P2_ReactorStructure},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M3_obj10)

	-- setup the reactor for a controlled death sequence
	UnProtectUnit(ScenarioInfo.P2_ReactorStructure)
	ScenarioInfo.P2_ReactorStructure:DisableShield()
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P2_ReactorStructure, LaunchVictoryNIS)
end

function P2_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.U06_RESEARCH_UNLOCK, P2_ResearchSecondary_Assign)
end

function P2_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.U06_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P2: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.U06_S1_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)

	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				-- play completion VO that is appropriate to the objective state: if the Relays
				-- still need to be destroyed, VO will focus on that. Otherwise, the VO will note
				-- the use of the researched unit for use against the final Reactor.
				if ScenarioInfo.M2_obj10.Active then
					LOG('----- P2: Research complete. Relay obj still active, playing VO focused on that.')
					ScenarioFramework.Dialogue(OpDialog.U06_RESEARCH_FOLLOWUP_NOAH_010)
				else
					LOG('----- P2: Research complete. Reactor obj is now active, playing VO focused on that.')
					ScenarioFramework.Dialogue(OpDialog.U06_RESEARCH_FOLLOWUP_NOAH_020)
				end
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 300)
end

function ResearchReminder1()
	if ScenarioInfo.S1_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.U06_RESEARCH_REMINDER_010)
	end
end

function P2_EnemyBanter_VO()
	LOG('----- P2: banter VO playing.')
	ScenarioFramework.Dialogue(OpDialog.U06_BANTER_RODGERS_010)
end

function P2_WestSwitchResponse()
	LOG('----- P2: West switch respons.')
	-- The switch is under attack and will soon be destroyed. Send all platoons back to it.
	for k, platoon in ScenarioInfo.P2_WestCampAirPlatoons do
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			platoon:Stop()
			ScenarioFramework.PlatoonPatrolChain (platoon, 'P2_ENEM01_WestAirCamp_SwitchPatrol')
		end
	end

	-- Turn off the OpAI's that are maintaining the air patrols
	ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI:Disable()

	-- give time for the platoon to get near the switch, before we destroy everything
	ScenarioFramework.CreateTimerTrigger (P2_WestSwitchDestroy, 5)
end

function P2_WestSwitchDestroy()
	LOG('----- P2: Destroying west switch related units.')

	-- Fire nuke at the site, and force destroy the switch
	ScenarioGameEvents.NukePosition(ScenarioInfo.P2_ReactorSwitch_West:GetPosition())
	ForceUnitDeath(ScenarioInfo.P2_ReactorSwitch_West)

	-- kill the west switch air patrols (they may not all have made it into the nuke radius, so lets kill them
	-- manually)
	for k, platoon in ScenarioInfo.P2_WestCampAirPlatoons do
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			for key, unit in platoon:GetPlatoonUnits() do
				if unit and not unit:IsDead() then
					unit:Kill()
				end
			end
		end
	end

	local pos = ScenarioUtils.MarkerToPosition('WestSwitch_NukeMarker')

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_PLAYER],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 32, true, 5000, 90001, brainList)

	-- Send in the west experimental group, toward the player, if it is still alive. Play
	-- some related VO, soon, if we havent already.
	if ScenarioInfo.P2_CentralExperimentalGroup_01 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_CentralExperimentalGroup_01) then
		ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P2_CentralExperimentalGroup_01, 'P2_ENEM01_MidExpAttack_01_Chain')
		ScenarioFramework.CreateTimerTrigger (function() P2_PlayExpWarningVo(ScenarioInfo.P2_CentralExperimentalGroup_01) end, 13)
	end

	-- disable the base manager
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampWest_Base:BaseActive(false)

	-- If we havent already, change the landing location of the Heavy Transport attacks to the reactor backbase area,
	-- in response to the player advance.
	P2_HeavyTransAttacksToReactor()
end

function P2_EastSwitchResponse()
	LOG('----- P2: East switch respons.')
	-- The switch is under attack and will soon be destroyed. Send all platoons back to it.
	for k, platoon in ScenarioInfo.P2_EastCampAirPlatoons do
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			platoon:Stop()
			ScenarioFramework.PlatoonPatrolChain (platoon, 'P2_ENEM01_EastAirCamp_SwitchPatrol')
		end
	end

	-- Turn off the OpAI's that are maintaining the air patrols
	ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI:Disable()

	-- give time for the platoon to get near the switch, before we destroy everything
	ScenarioFramework.CreateTimerTrigger (P2_EastSwitchDestroy, 5)
end

function P2_EastSwitchDestroy()
	LOG('----- P2: Destroying east switch related units.')

	-- Fire nuke at the site, and force destroy the switch
	ScenarioGameEvents.NukePosition(ScenarioInfo.P2_ReactorSwitch_East:GetPosition())
	ForceUnitDeath(ScenarioInfo.P2_ReactorSwitch_East)

	-- kill the east switch air patrols
	for k, platoon in ScenarioInfo.P2_EastCampAirPlatoons do
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			for key, unit in platoon:GetPlatoonUnits() do
				if unit and not unit:IsDead() then
					unit:Kill()
				end
			end
		end
	end

	local pos = ScenarioUtils.MarkerToPosition('EastSwitch_NukeMarker')

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_PLAYER],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 32, true, 5000, 90001, brainList)

	-- Send in the east experimental group, toward the player, if it is still alive. Delay some VO related to this,
	-- which will play if it hasnt done so already
	if ScenarioInfo.P2_CentralExperimentalGroup_02 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_CentralExperimentalGroup_02) then
		ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.P2_CentralExperimentalGroup_02, 'P2_ENEM01_MidExpAttack_02_Chain' )
		ScenarioFramework.CreateTimerTrigger( function() P2_PlayExpWarningVo(ScenarioInfo.P2_CentralExperimentalGroup_02) end, 9 )
	end

	-- turn off the base manager.
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampEast_Base:BaseActive(false)

	-- If we havent already, change the landing location of the Heavy Transport attacks to the reactor backbase area,
	-- in response to the player advance.
	P2_HeavyTransAttacksToReactor()
end

function P2_CentralSwitchResponse()
	LOG('----- P2: Central switch respons.')
	ScenarioFramework.CreateTimerTrigger (P2_CentralSwitchDestroy, 4)
end

function P2_CentralSwitchDestroy()
	LOG('----- P2: Destroying central switch related units.')

	-- Fire nuke at the site, and force destroy the switch
	ScenarioGameEvents.NukePosition(ScenarioInfo.P2_ReactorSwitch_Central:GetPosition())
	ForceUnitDeath(ScenarioInfo.P2_ReactorSwitch_Central)

	local pos = ScenarioUtils.MarkerToPosition('CentralSwitch_NukeMarker')

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_PLAYER],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 32, true, 5000, 90001, brainList)

	-- Delay the middle experimental group moving in, to give time for the relay switch blast to clear (otherwise,
	-- we might damage or lose the experimental)
	ScenarioFramework.CreateTimerTrigger (P2_CentralSwitchDestroy_ExpAdvance, 8)

	-- If we havent already, change the landing location of the Heavy Transport attacks to the reactor backbase area,
	-- in response to the player advance.
	P2_HeavyTransAttacksToReactor()
end

function P2_CentralSwitchDestroy_ExpAdvance()
	-- Send in the east experimental group, toward the player, if it is still alive.
	-- Add a timertrigger to eventually play some VO pointing out the event (if it hasnt happened before).
	if ScenarioInfo.P2_CentralExperimentalGroup_03 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_CentralExperimentalGroup_03) then
		ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.P2_CentralExperimentalGroup_03, 'P2_ENEM01_MidExpAttack_02_Chain' )
		ScenarioFramework.CreateTimerTrigger( function() P2_PlayExpWarningVo(ScenarioInfo.P2_CentralExperimentalGroup_03) end, 9 )
	end

	-- if the player is well stocked with powerful units, send in the patrolling fatboys that are near the mid switch, if
	-- they are still alive. In case the Kriptor is dead from the main attack above, try the VO/exp check on these two one-unit
	-- platoons as well, so some VO will fire off in any case.
	local expCount 	= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL * categories.MOBILE)
	if expCount >= 3 then
		if ScenarioInfo.P2_ENEM01_MidSwitchPatrol01 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_ENEM01_MidSwitchPatrol01) then
			IssueClearCommands( ScenarioInfo.P2_ENEM01_MidSwitchPatrol01:GetPlatoonUnits())
			ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.P2_ENEM01_MidSwitchPatrol01, 'P2_ENEM01_MidExpAttack_02_Chain' )
			ScenarioFramework.CreateTimerTrigger( function() P2_PlayExpWarningVo(ScenarioInfo.P2_ENEM01_MidSwitchPatrol02) end, 10 )
		end
		if ScenarioInfo.P2_ENEM01_MidSwitchPatrol02 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_ENEM01_MidSwitchPatrol02) then
			IssueClearCommands( ScenarioInfo.P2_ENEM01_MidSwitchPatrol02:GetPlatoonUnits())
			ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.P2_ENEM01_MidSwitchPatrol02, 'P2_ENEM01_MidExpAttack_02_Chain' )
			ScenarioFramework.CreateTimerTrigger( function() P2_PlayExpWarningVo(ScenarioInfo.P2_ENEM01_MidSwitchPatrol02) end, 11 )
		end
	end
end

function P2_PlayExpWarningVo(platoon)
	if not ScenarioInfo.P2_ExperimentalWarningVOPlayed then
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			local unitsOfCat = EntityCategoryFilterDown( categories.EXPERIMENTAL, platoon:GetPlatoonUnits() )
			-- if the platoon in question does in fact still contain an experimental (ie, player
			-- hasnt already destroyed it) then we will play warning VO, one time.
			if table.getn(unitsOfCat) > 0 then
				LOG('----- P2: Warn player an experimental is moving towards them.')
				-- play VO warning that ane xp is coming.
				ScenarioFramework.Dialogue(OpDialog.U06_EXPERIMENTAL_WARNING_010)
				ScenarioInfo.P2_ExperimentalWarningVOPlayed = true

				-- create a death trigger on the experimental, which will trigger confirmation VO
				if unitsOfCat[1] and not unitsOfCat[1]:IsDead() then
					ScenarioFramework.CreateUnitDeathTrigger(P2_ExperimentalDeathVO, unitsOfCat[1])
				end
			end
		end
	end
end

function P2_ExperimentalDeathVO()
	-- VO noting that the player has destroyed an incomnig experimental
	ScenarioFramework.Dialogue(OpDialog.U06_EXPERIMENTAL_DESTROYED_010)
end

function P2_HeavyTransAttacksToReactor()
	if not ScenarioInfo.P2_HeavyTrans_LandAtReactor then
		LOG('----- P2: Changing heavy transport landing locations to reactor backbase area.')

		-- flag existing attack stream to stop
		ScenarioInfo.P2_HeavyTrans_LandAtPlayer = false

		-- start a new instace of the stream, so we know we will get an immediate attack (we
		-- need a new flag to check, so pass in a different one). Create a new selection of landing
		-- locations, at the reactor backbase area.
		ScenarioInfo.P2_HeavyTrans_LandingDestinations = {'P2_TransHeavy_AltLanding_01', 'P2_TransHeavy_AltLanding_02', 'P2_TransHeavy_AltLanding_03' }
		ScenarioInfo.P2_HeavyTrans_LandAtReactor = true
		ForkThread(P2_HeavyTransportStream_Thread, 'P2_HeavyTrans_LandAtReactor', ScenarioInfo.P2_HeavyTrans_ReactorDestinations)

		-- Warn player that the enemy has changed its landing location. Delay a tad, so the attack has time to get
		-- substantively on map.
		ScenarioFramework.CreateTimerTrigger (P2_HeavyTransDestination_VO, 35)
	end
end

function P2_HeavyTransDestination_VO()
	LOG('----- P2: Play VO to warn player that landing destination is changed for heavy trans attacks.')
	-- Warn player heavy trans attack landing destination has changed.
	ScenarioFramework.Dialogue(OpDialog.U06_TRANSPORT_DESTINATION_CHANGE)
end

function P2_AISeteup_WestAirCamp()
	----------------------------------------------
	--Central-West Air Camp:
	----------------------------------------------

	---- Central Air Camp - West base setup
	local levelTable_P2_ENEM01_AirCampWest_Base 	= { P2_ENEM01_AirCampWest_100 = 100,
														P2_ENEM01_AirCampWest_90 = 90, }
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampWest_Base = 	ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P2_ENEM01_AirCampWest',
		 'P2_ENEM01_AirCampWest_Base_Marker', 50, levelTable_P2_ENEM01_AirCampWest_Base)
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampWest_Base:	StartNonZeroBase(1)
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampWest_Base:	SetBuildAllStructures(false)

	-- Air patrols over central area
	ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI		= ScenarioInfo.ArmyBase_P2_ENEM01_AirCampWest_Base:AddOpAI('AirFightersUEF', 'P2_ENEM01_WestCamp_AirDef01_OpAI', {} )
	local P2_ENEM01_WestCamp_AirDef01_OpAI_Data			= {PatrolChain = 'P2_ENEM01_WestAirCamp_AirPatrol_01',}
	ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', P2_ENEM01_WestCamp_AirDef01_OpAI_Data )

	ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI:		SetChildCount(4)	--AirFightersUEF opai uses child count of 1, so SetChildCount becomes the size of the resulting platoon.
	ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI.		FormCallback:Add( P2_WestCampAir_FormCallback)
	ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI:		AdjustPriority(1)	-- high pri: favor central area defense over camp defense. We dont want player to go mid with gunships until after they have dealt with camps.


	-- Air patrols the camp
	ScenarioInfo.P2_ENEM01_WestCamp_Def_OpAI			= ScenarioInfo.ArmyBase_P2_ENEM01_AirCampWest_Base:AddOpAI('AirFightersUEF', 'P2_ENEM01_WestCamp_Def_OpAI', {} )
	local P2_ENEM01_WestCamp_Def_OpAI_Data				= {PatrolChain = 'P2_ENEM01_WestAirCamp_SwitchPatrol',}
	ScenarioInfo.P2_ENEM01_WestCamp_Def_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', P2_ENEM01_WestCamp_Def_OpAI_Data )

	ScenarioInfo.P2_ENEM01_WestCamp_Def_OpAI:			SetChildCount(2) -- Size of each platoon
	ScenarioInfo.P2_ENEM01_WestCamp_Def_OpAI:			SetMaxActivePlatoons(3)
	ScenarioInfo.P2_ENEM01_WestCamp_Def_OpAI.			FormCallback:Add( P2_WestCampAir_FormCallback)


	---- Set up initial patrol platoons that will be handed to the OpAI:
	-- 3 platoons patrolling over the central area
	for i = 1, 3 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_AirCampWest_InitAir_0' .. i , 'AttackFormation')
		P2_WestCampAir_FormCallback(platoon)
		ScenarioInfo.P2_ENEM01_WestCamp_AirDef01_OpAI:AddActivePlatoon(platoon, true)
	end

	-- 2 defense platoons over the air camp
	for i = 1, 3 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_AirCampWest_DefPatrol' , 'AttackFormation')
		P2_WestCampAir_FormCallback(platoon)
		ScenarioInfo.P2_ENEM01_WestCamp_Def_OpAI:AddActivePlatoon(platoon, true)
	end
end

function P2_AISeteup_EastAirCamp()
	----------------------------------------------
	--Central-East Air Camp:
	----------------------------------------------

	---- Central Air Camp - East base setup
	local levelTable_P2_ENEM01_AirCampEast_Base 	= { P2_ENEM01_AirCampEast_100 = 100,
														P2_ENEM01_AirCampEast_90 = 90, }
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampEast_Base = 	ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P2_ENEM01_AirCampEast',
		 'P2_ENEM01_AirCampEast_Base_Marker', 50, levelTable_P2_ENEM01_AirCampEast_Base)
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampEast_Base:	StartNonZeroBase(1)
	ScenarioInfo.ArmyBase_P2_ENEM01_AirCampEast_Base:	SetBuildAllStructures(false)


	-- Air patrols over central area
	ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI		= ScenarioInfo.ArmyBase_P2_ENEM01_AirCampEast_Base:AddOpAI('AirFightersUEF', 'P2_ENEM01_EastCamp_AirDef01_OpAI', {} )
	local P2_ENEM01_EastCamp_AirDef01_OpAI_Data	= {PatrolChain = 'P2_ENEM01_EastAirCamp_AirPatrol_01',}
	ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', P2_ENEM01_EastCamp_AirDef01_OpAI_Data )

	ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI:		SetChildCount(4)	--AirFightersUEF opai uses child count of 1, so SetChildCount becomes the size of the resulting platoon.
	ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI.		FormCallback:Add( P2_EastCampAir_FormCallback)
	ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI:		AdjustPriority(1)	-- high pri: favor central area defense over camp defense

	-- Defense Air patrols the camp
	ScenarioInfo.P2_ENEM01_EastCamp_Def_OpAI			= ScenarioInfo.ArmyBase_P2_ENEM01_AirCampEast_Base:AddOpAI('AirFightersUEF', 'P2_ENEM01_EastCamp_Def_OpAI', {} )
	local P2_ENEM01_EastCamp_Def_OpAI_Data				= {PatrolChain = 'P2_ENEM01_EastAirCamp_SwitchPatrol',}
	ScenarioInfo.P2_ENEM01_EastCamp_Def_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', P2_ENEM01_EastCamp_Def_OpAI_Data )

	ScenarioInfo.P2_ENEM01_EastCamp_Def_OpAI:			SetChildCount(2) -- Size of each platoon
	ScenarioInfo.P2_ENEM01_EastCamp_Def_OpAI:			SetMaxActivePlatoons(3)
	ScenarioInfo.P2_ENEM01_EastCamp_Def_OpAI.			FormCallback:Add( P2_EastCampAir_FormCallback)


	---- Set up initial patrol platoons that will be handed to the OpAI
	-- 3 platoons patrolling over the central area
	for i = 1, 3 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_AirCampEast_InitAir_0' .. i , 'AttackFormation')
		P2_EastCampAir_FormCallback(platoon)
		ScenarioInfo.P2_ENEM01_EastCamp_AirDef01_OpAI:AddActivePlatoon(platoon, true)
	end

	-- 2 defense platoons over the air camp
	for i = 1, 3 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_AirCampEast_DefPatrol' , 'AttackFormation')
		P2_EastCampAir_FormCallback(platoon)
		ScenarioInfo.P2_ENEM01_EastCamp_Def_OpAI:AddActivePlatoon(platoon, true)
	end
end

function P2_AISeteup_BridgeBase()
	----------------------------------------------
	--Bridge Area defensive base:
	----------------------------------------------

	---- Bridge Area minibase setup
	local levelTable_P2_ENEM01_Bridgebase 	= { P2_ENEM01_BridgeBase_100 = 100,
												P2_ENEM01_BridgeBase_90 = 90, }
	ScenarioInfo.ArmyBase_P2_ENEM01_Bridgebase = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P2_ENEM01_Bridgebase',
		 'P2_ENEM01_BridgeBase_Marker', 50, levelTable_P2_ENEM01_Bridgebase)
	ScenarioInfo.ArmyBase_P2_ENEM01_Bridgebase:	StartNonZeroBase(2)
	ScenarioInfo.ArmyBase_P2_ENEM01_Bridgebase:	SetBuildAllStructures(false)

	-- Air patrols over central area
	ScenarioInfo.P2_ENEM01_BridgeBase_LandDef01_OpAI		= ScenarioInfo.ArmyBase_P2_ENEM01_AirCampWest_Base:AddOpAI('LandAttackUEF', 'P2_ENEM01_BridgeBase_LandDef01_OpAI', {} )
	local P2_ENEM01_BridgeBase_LandDef01_OpAI_Data			= {PatrolChain = 'P2_ENEM01_BridgeBase_LandDef_Chain_01',}
	ScenarioInfo.P2_ENEM01_BridgeBase_LandDef01_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', P2_ENEM01_BridgeBase_LandDef01_OpAI_Data )
	ScenarioInfo.P2_ENEM01_BridgeBase_LandDef01_OpAI:		SetMaxActivePlatoons(2)


	---- Set up initial patrol platoons (some will be handed to the OpAI):
	-- initial land patrol
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_BridgeBase_InitLand_01', 'AttackFormation')
	ScenarioInfo.P2_ENEM01_BridgeBase_LandDef01_OpAI:AddActivePlatoon(platoon, true)

	-- air patrol. Not supported by opai, but setting up in this function for simplicity.
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_BridgeBase_InitAir_01', 'AttackFormation')
	RandomPatrolThread(platoon, 'P2_ENEM01_BridgeBase_AirDef_Chain_01', ARMY_ENEM01)
end


function P2_WestCampAir_FormCallback(platoon)
	LOG('----- P2: West camp air platoon added to table.')

	-- Add a newly created West Camp fighter platoon to the table of patrol platoons
	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		table.insert(ScenarioInfo.P2_WestCampAirPlatoons, platoon)
	end
end

function P2_EastCampAir_FormCallback(platoon)
	LOG('----- P2: East camp air platoon added to table.')

	-- Add a newly created East Camp fighter platoon to the table of patrol platoons
	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		table.insert(ScenarioInfo.P2_EastCampAirPlatoons, platoon)
	end
end


---------------------------------------------------------------------
-- P2 Attack Streams:
---------------------------------------------------------------------

function P2_LightTransportStream_Thread()

	-- This light attack stream varies the delay between attacks based on a weighted look at certain types of player units.
	-- First we take the amount of units of different types that the player has, and weight them. The sum of this is a raw
	-- look at how well the player is doing: a 'player value'. Because the player starts with some units, we disregard a portion
	-- off this raw value to come up with an adjusted player value. This adusted value is modified to come up with a value that
	-- represents the number of seconds we will subtract from our base delay.

	while not ScenarioInfo.OpEnded do
		-- pause the thread while flagged (generally, so we dont send an attack when the player has an experimental
		-- on their doorstep, or if we have an NIS running).
		while ScenarioInfo.P2_TransportAttacksPaused or ScenarioInfo.OpNISActive do
			WaitSeconds(1)
			if ScenarioInfo.OpEnded then
				return
			end
		end

		---------------------
		-- Generate Delay Value
		---------------------

		-- The base delay value we will be modifying.
		local baseDelay = 90

		-- Get enemy unit count, for a failsafe check
		local enemyCount 	= ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)

		-- Collect info about player units, and apply the weighting values to the unit counts.
		local shield 		= P2_TransportStreamLight_ShieldWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0202)
		local pointDef 		= P2_TransportStreamLight_PointDefWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0101)
		local experimental 	= P2_TransportStreamLight_ExperimentalWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL)
		local mobileLand 	= P2_TransportStreamLight_MobLandWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits((categories.MOBILE * categories.LAND) - categories.uul0105) -- dont count mobile AA, as these cannot defend against land.
		local gunship 		= P2_TransportStreamLight_GunshipWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0103)
		local bomber 		= P2_TransportStreamLight_BomberWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0102)

		-- Create the raw total weighted value of the player
		local playerValue = shield + pointDef + experimental + mobileLand + gunship + bomber
		LOG('----- TRANS LIGHT: raw player value: ' .. playerValue)

		-- Create an adjusted value that disregards an amount that is our buffer: this represents the units the player
		-- has started with, and any further amount we may want to act as a safety buffer. Dont allow the value to go below 0.
		local adjustedValue = playerValue - 73
		if adjustedValue < 0 then adjustedValue = 0 end	---- maybe we want the value to go negative, so we scale around 90 seconds, instead of only less-than 90.
		LOG('----- TRANS LIGHT: adjusted player value: ' .. adjustedValue)

		-- Create our delay modifier value: blunt the adjusted player value by a multiplier.
		local delayMod = adjustedValue * P2_TransportStreamLight_WeightMultiplier
		LOG('----- TRANS LIGHT: delay mod: ' .. delayMod)

		-- Create our final delay value, and clamp it to a safe range
		local delay = baseDelay - delayMod
		if delay < 37 then delay = 37 end
		if delay > 117 then delay = 117 end
		LOG('----- TRANS LIGHT: final delay value: ' .. delay)

		---------------------
		-- Spawn Attacks
		---------------------

		-- choose how many landing locations we can choose from, based on the delay. A short delay
		-- will result in a high number of landing locations.

		-- Final failsafe: dont spawn units if we are at unit cap.
		if enemyCount < (GetArmyUnitCap(ARMY_ENEM01) - 25) then
			local rndLocation = 1
			if delay <= 84 and delay > 78 then
				rndLocation = 2
			elseif delay <= 78 and delay > 70 then
				rndLocation = 3
			elseif delay <= 70 and delay > 55 then
				rndLocation = 4
			elseif delay <= 55 then
				rndLocation = 5
			end
			LOG('----- TRANSLIGHT: spawning attack. rndLoc: ' .. rndLocation)
			P2_LightTransportAttack(rndLocation)
		else
			LOG('----- TRANSLIGHT: Too close to unit cap, skipping attack.')
			LOG('----- ---------------------------------------------------')
		end

		---------------------
		-- Delay the Thread
		---------------------

		-- Delay the loop. However, if the enemy is building up a large number of units, take this as a sign
		-- that we are overdoing things, and use a longer wait.
		if enemyCount < (GetArmyUnitCap(ARMY_ENEM01) - 50) then
			WaitSeconds(delay)
		else
			LOG('----- TRANSLIGHT: enemy unit count too high. Using a long wait between attacks')
			WaitSeconds(180)
		end
	end
end

function P2_LightTransportAttack(rndLocation)
	LOG('----- TRANSLIGHT: Transport Attack being created')
	LOG('----- ------------------------------------------')
	-- Attack 1
	local data = {
		armyName				= 'ARMY_ENEM01',											-- name of the army for whom the transport and group are being created
		units					= 'P2_ENEM01_TransLight_Group_01',							-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= 'P2_ENEM01_TransLight_Transport_01',						-- unit handle for the actual transport
		approachChain			= nil,														-- optional chainName for the approach travel route
		unloadDest				= 'P2_TransLight_Landing_0' .. Random ( 1, rndLocation),	-- destination for the transport drop-off
		returnDest				= 'P2_ENEM01_TransAttack_Return_Marker',					-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,													-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,														-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,														-- optional function to call when the transport finishes unloading
		onUnloadCallback		= P2_LightTransLanding,										-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data)
end

function P2_LightTransLanding(platoon)
	-- Called when a light transport attack lands
	if platoon and ArmyBrains[ScenarioInfo.ARMY_ENEM01]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain (platoon, 'P2_ENEM01_TransAttack_Attack_Chain_01')
	end
end


function P2_HeavyTransportStream_Thread(flag, destinationTable)
	-- This heavy attack stream generates regular attacks, varying the size of the attacks sent. First, we take a weighted
	-- look at the player to generate a 'player value'. Adjusted to take into account starting units, we devide this value
	-- by a modifier to come up with the number of extra units we will place onto transported attacks (above and beyond a base
	-- number of units). The makeup of the basic and additional units are defined in tables that list types of units. We create
	-- our attack groups by working through this list *in order*, generating units a varying number of times. So, the makeup
	-- and order of units within those lists represent an additional change in difficulty as well, if so wished.

	if not ScenarioInfo[flag] then
		LOG('----- TRANS HEAVY: Ending instance of loop - flag is now false!')
		LOG('----- ---------------------------------------------------')
	end

	while ScenarioInfo[flag] and not ScenarioInfo.OpEnded do
		-- pause the thread while flagged (generally, so we dont send an attack when the player has an experimental
		-- on their doorstep, or if we have an NIS going), or if enemy unit count is nearing unit cap.
		while ScenarioInfo.P2_TransportAttacksPaused or ScenarioInfo.OpNISActive or ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS) > (GetArmyUnitCap(ARMY_ENEM01) - 50) do
			WaitSeconds(1)
			if ScenarioInfo.OpEnded or not ScenarioInfo[flag] then
				LOG('----- TRANS HEAVY: Ending instance of loop - flag is now false, or operation has ended.')
				return
			end
		end

		---------------------
		-- Generate Additional Unit Value
		---------------------

		-- Collect info about player units, and apply the weighting values to the unit counts.
		local shield 		= P2_TransportStreamLight_ShieldWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0202)
		local pointDef 		= P2_TransportStreamLight_PointDefWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0101)
		local experimental 	= P2_TransportStreamLight_ExperimentalWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL)
		local mobileLand 	= P2_TransportStreamLight_MobLandWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits((categories.MOBILE * categories.LAND) - categories.uul0105) -- dont count mobile AA, as these cannot defend against land.
		local gunship 		= P2_TransportStreamLight_GunshipWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0103)
		local bomber 		= P2_TransportStreamLight_BomberWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0102)

		-- Create the raw total weighted value of the player
		local playerValue = shield + pointDef + experimental + mobileLand + gunship + bomber
		LOG('----- TRANS HEAVY: raw player value: ' .. playerValue)

		-- Create an adjusted value that disregards an amount that is our buffer: this represents the units the player
		-- has started with, and any further amount we may want to act as a safety buffer. Dont allow the value to go below 0.
		local adjustedValue = playerValue - 70
		if adjustedValue < 0 then adjustedValue = 0 end	---- maybe we want the value to go negative, so we scale around 90 seconds, instead of only less-than 90.
		LOG('----- TRANS HEAVY: adjusted player value: ' .. adjustedValue)

		-- find how many extra units per transport we will use: devide the adjusted player value by P2_TransportStreamHeavy_Mod. ie,
		-- for every P2_TransportStreamHeavy_Mod amount of player value, add another unit to each transport.
		local unitAdd = 0
		if adjustedValue > 0 then
			unitAdd = math.floor(adjustedValue / P2_TransportStreamHeavy_Mod)
		end
		LOG('----- TRANS HEAVY: initial unitAdd value: ' .. unitAdd)

		-- clamp the number of additional units to at most the number we have listed in the unit spawn order table.
		if unitAdd > table.getn(ScenarioInfo.P2_HeavyTransportAttack_AddSpawnOrder) then
			unitAdd = table.getn(ScenarioInfo.P2_HeavyTransportAttack_AddSpawnOrder)
		end
		LOG('----- TRANS HEAVY: adjusted unitAdd value: ' .. unitAdd)


		---------------------
		-- Spawn Attacks
		---------------------

		-- 3 Identical groups are assembled and transported in.

		-- First, create the transports. We do so here, instead of in the transport spawn/attack
		-- function, so we have a handle to a transport to check the unit limit of what it can carry
		-- (ie, to perform a safety check so we dont overload our transports).
		local trans1 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_HeavyTrans_Transport_01')
		local trans2 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_HeavyTrans_Transport_02')
		local trans3 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_HeavyTrans_Transport_03')

		-- Get the number of slots each transport has, to check against.
		local trans1NumSlots = trans1:GetNumberOfStorageSlots()
		local trans2NumSlots = trans2:GetNumberOfStorageSlots()
		local trans3NumSlots = trans3:GetNumberOfStorageSlots()

		-- Next, a base group is started (defined in table). Then, an adaptive amount (unitAdd) of a
		-- second list of units is spawned in and added to this platoon.
		local group1 = {}
		local group2 = {}
		local group3 = {}
		local unit1 = {}
		local unit2 = {}
		local unit3 = {}

		for k, v in ScenarioInfo.P2_HeavyTransportAttack_BaseGroup do
			-- Only spawn units if our transports have room. Otherwise, kill the loop.
			-- The check could be per unit spawn, but to keep it simple, if any counter is at
			-- zero, then we are going to call off creating anyunits, and wrap up the creating loop.
			if trans1NumSlots > 0 and trans2NumSlots > 0 and trans3NumSlots > 0 then
				unit1 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', v)
				unit3 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', v)
				unit2 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', v)
			else
				LOG('----- TRANS HEAVY: We tried to overload a transport (base group)! Breaking out of the load loop.')
				break
			end

			-- decrement: we are going to make the assumption that each unit takes only 1 slot.
			trans1NumSlots = trans1NumSlots - 1
			trans2NumSlots = trans2NumSlots - 1
			trans3NumSlots = trans3NumSlots - 1

			table.insert(group1, unit1)
			table.insert(group2, unit2)
			table.insert(group3, unit3)
		end
		for i = 1, unitAdd do
			if ScenarioInfo.P2_HeavyTransportAttack_AddSpawnOrder[i] then
				if trans1NumSlots > 0 and trans2NumSlots > 0 and trans3NumSlots > 0 then
					unit1 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', ScenarioInfo.P2_HeavyTransportAttack_AddSpawnOrder[i])
					unit2 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', ScenarioInfo.P2_HeavyTransportAttack_AddSpawnOrder[i])
					unit3 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', ScenarioInfo.P2_HeavyTransportAttack_AddSpawnOrder[i])
					table.insert(group1, unit1)
					table.insert(group2, unit2)
					table.insert(group3, unit3)

					trans1NumSlots = trans1NumSlots - 1
					trans2NumSlots = trans2NumSlots - 1
					trans3NumSlots = trans3NumSlots - 1
				else
					LOG('----- TRANS HEAVY: We tried to overload a transport (additional group)! Breaking out of the load loop.')
					break
				end
			end
		end

		-- Call an attack with our units etc.
		P2_HeavyTransportAttack_Spawn(group1, group2, group3, trans1, trans2, trans3, destinationTable)

		-- If the player gets extremely powerful, lower delay between attacks to 4 minutes
		if adjustedValue > 512 then
			LOG('----- TRANS HEAVY: player is now extremely powerful, at adjustedValue ' .. adjustedValue .. '. Decreasing delay between heavy transport attacks.')
			P2_HeavyTransportAttack_Delay = 240
		end

		-- Keep the delay at the default 5.5 minutes if the player is in a normal range.
		if adjustedValue < 410 then
			LOG('----- TRANS HEAVY: Player is below threshold. Delay will stay at 330.')
			P2_HeavyTransportAttack_Delay = 330
		end

		WaitSeconds(P2_HeavyTransportAttack_Delay)
	end

	LOG('----- TRANS HEAVY: Ending instance of loop - flag is now false, or operation has ended.')
end

function P2_HeavyTransportAttack_Spawn(group1, group2, group3, trans1, trans2, trans3, landingTable)
	LOG('----- TRANSHEAVY: Transport Attack being created')
	LOG('----- ------------------------------------------')
	-- Transport 1
	local data01 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					= group1,									-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= trans1,									-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= landingTable[1],							-- destination for the transport drop-off
		returnDest				= 'P2_ENEM01_TransAttack_Return_Marker',	-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,										-- optional function to call when the transport finishes unloading
		onUnloadCallback		= P2_HeavyTransLanding,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data01)

	-- Transport 2
	local data02 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					= group2,									-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= trans2,									-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= landingTable[2],							-- destination for the transport drop-off
		returnDest				= 'P2_ENEM01_TransAttack_Return_Marker',	-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,										-- optional function to call when the transport finishes unloading
		onUnloadCallback		= P2_HeavyTransLanding,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data02)

	-- Transport 3
	local data03 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					= group3,									-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= trans3,									-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= landingTable[3],							-- destination for the transport drop-off
		returnDest				= 'P2_ENEM01_TransAttack_Return_Marker',	-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,										-- optional function to call when the transport finishes unloading
		onUnloadCallback		= P2_HeavyTransLanding,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data03)

	-- Play some VO pointing out the attack, a couple times. Lets skip the first one, as it wont be that large.
	-- Delay the VO a bit, so the transports have time to get on map etc.
	P2_HeavyTransportCount = P2_HeavyTransportCount + 1
	if P2_HeavyTransportCount == 2 then
		ScenarioFramework.CreateTimerTrigger( function() ScenarioFramework.Dialogue(OpDialog.U06_HEAVY_ATTACK_WARNING_010) end, 12 )
	elseif P2_HeavyTransportCount == 3 then
		ScenarioFramework.CreateTimerTrigger( function() ScenarioFramework.Dialogue(OpDialog.U06_HEAVY_ATTACK_WARNING_020) end, 12 )
	end
end

function P2_HeavyTransLanding(platoon)
	if platoon and ArmyBrains[ScenarioInfo.ARMY_ENEM01]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain (platoon, 'P2_ENEM01_TransAttack_Attack_Chain_01')
	end
end

function P2_PauseTransportAttacks(unit)
	-- An exp has gotten near the player base. Pause the attack thread, and increment the count
	-- of how many units have neared the player and tried to puase.
	ScenarioInfo.P2_PauseCounter = ScenarioInfo.P2_PauseCounter + 1
	ScenarioInfo.P2_TransportAttacksPaused = true

	LOG('----- P2: Experimental is near player base. Pauseing attacks. Exp-at-base count: ' .. ScenarioInfo.P2_PauseCounter)

	-- Create a death trigger that will decrement the counter/try to unpause, if no exps are in the area still.
	ScenarioFramework.CreateUnitDeathTrigger( P2_UnPauseTransportAttacks, unit )
end

function P2_UnPauseTransportAttacks()
	-- a unit that paused the thread has died. Decrement the counter. If it hits zero,
	-- that means there are no units left near the player that requested a pause, and we
	-- can now unpause the attack threads.
	ScenarioInfo.P2_PauseCounter = ScenarioInfo.P2_PauseCounter - 1
	LOG('----- P2: Experimental at player base has died. Decrementing counter to: ' .. ScenarioInfo.P2_PauseCounter)
	if ScenarioInfo.P2_PauseCounter == 0 then
		LOG('----- P2: no exp near player base. Unpausing attacks.')
		ScenarioInfo.P2_TransportAttacksPaused = false
	end
end



function P2_AirStreamThread()
	while not ScenarioInfo.OpEnded do

		-- Don't spawn units during an NIS.
		while ScenarioInfo.OpNISActive do
			WaitSeconds(2)
			if ScenarioInfo.OpEnded then
				return
			end
		end

		local value = P2_PlayerAirValueCheck('LightAirStream')
		local enemTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		local enemAir = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.AIR)

		if enemTotal < 355 and enemAir < 95 then
			LOG('----- LIGHT AIR STREAM: beginning air attack setup')

			-- for every N points of player value, add an extra unit to our light attack.
			-- But, keep them light, and clamp at a max value.
			local count = math.floor(value / 38)
			if count > 4 then count = 4 end
			local rnd = Random(1, 3)
			LOG('----- LIGHT AIR STREAM: extra unit count is ' .. count)

			-- occasionally send two attacks (for some variety), slighting softened. Otherwise, send in
			-- one normal attack.
			if rnd == 3 then
				LOG('----- LIGHT AIR STREAM: sending two attacks this round')
				-- use a half size or less number of extra units to add onto the basic attack size.
				local altCount = math.floor(count / 2)

				-- send one attack right now
				ForkThread(P2_AirStream_CreateAirAttack, altCount, 2, 0.0)

				-- send a second attack with a delay
				ForkThread(P2_AirStream_CreateAirAttack, altCount, 2, 9.0)
			else
				ForkThread(P2_AirStream_CreateAirAttack, count, 2)
			end

		-- Enemy unit counts are too high.
		else
			LOG('----- LIGHT AIR STREAM: enemy unit counts are too high. Skipping the requested attack')
		end

		--Pause between attacks
		WaitSeconds(P2_LightAirAttackDelay)
	end
end

function P2_HeavyAttackLoop()
	-- Create a heavy air attack, and create a timer trigger for another one.
	LOG('----- HEAVY AIR LOOP:')

	local value = P2_PlayerAirValueCheck('HeavyAirAttack')
	local enemTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
	local enemAir = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.AIR)

	if enemTotal < 325 and enemAir < 90 then
		-- for every N points of player value, add an extra unit to our attack.
		-- Clamp at a value, representing the max we expect the player to have to deal with.
		local count = math.floor(value / 15)
		if count > 9 then count = 9 end
		LOG('----- HEAVY AIR LOOP: creating attack. Units added to base attack will be: ' .. count)


		ForkThread(P2_AirStream_CreateAirAttack, count, 6)


	-- Enemy unit counts are too high.
	else
		LOG('----- HEAVY AIR LOOP: enemy unit counts are too high. Skipping the requested attack')
	end

	-- unless the operation is over, loop
	if not ScenarioInfo.OpEnded then
		ScenarioFramework.CreateTimerTrigger (P2_HeavyAttackLoop, P2_HeavyAirAttackDelay)
	end
end

function P2_AirStream_CreateAirAttack(size, baseSize, startDelay)
	-- delay if required
	if startDelay and startDelay > 0.0 then
		WaitSeconds(startDelay)
	end

	-- Size: number of extra units to add onto the basic attack
	-- baseSize: the number of bombers that make up our basic attack.

	-- Don't spawn units during an NIS.
	while ScenarioInfo.OpNISActive do
		WaitSeconds(3)
		if ScenarioInfo.OpEnded then
			return
		end
	end

	if not ScenarioInfo.OpEnded then
		LOG('----- CreateAirAttack: Creating platoon')
		local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')

		-- create the basic attack group (a number bombers)
		for i = 1, baseSize do
			local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_AirAttack_Bomber')
			ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
		end

		-- add in the extra units to the attack, randomly choosing types.
		if size > 0 then
			for i = 1, size do
				local rnd = Random(1, 2)
				local unit
				if rnd == 1 then
					unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_AirAttack_Bomber')
				else
					unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_AirAttack_Gunship')
				end
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			end
		end

		-- Send the platoon on its way
		local route = Random(1, 2)
		ScenarioFramework.PlatoonPatrolChain (platoon, 'P2_ENEM01_AirAttack_0' .. route .. '_Chain')
	else
		LOG('----- CreateAirAttack: attack requested, but not allowed to make one now.')
	end
end

function P2_PlayerAirValueCheck(caller)
	-- Collect weighed info about player
	shield			= P2_AirStream_ShieldWeight			* ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0202)
	AATower			= P2_AirStream_AATowerWeight		* ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0102)
	AATower			= P2_AirStream_FighterWeight		* ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0101)
	mobileAA		= P2_AirStream_MobileAAWeight		* ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uul0105)
	mobileShield	= P2_AirStream_MobileShieldWeight	* ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uul0201)
	landGeneral		= P2_AirStream_GeneralLandWeight	* ArmyBrains[ARMY_PLAYER]:GetCurrentUnits((categories.LAND * categories.MOBILE) - categories.uul0201) -- land minus mobshield, check above

	-- Get a raw value of this weighted look at the player
	local rawValue = shield + AATower + mobileAA + mobileShield + landGeneral
	LOG('----- AIR CHECK for ' ..caller .. ': raw player value: ' .. rawValue)

	-- Soften the value by a portion that broadly represents the players starting units, so we
	-- start off around zero, broadly speaking.
	local adjustedValue = rawValue - 35
	if adjustedValue < 0 then adjustedValue = 0 end
	LOG('----- AIR CHECK: adjustedValue player value: ' .. adjustedValue)

	return adjustedValue
end

---------------------------------------------------------------------
-- SURGICAL RESPONSE FUNCTIONS:
---------------------------------------------------------------------

function P2_SurgicalExpLand_Init()
	LOG('----- SURGICAL EXP LAND: First land exp detected. Triggering attack after a pause.')
	ScenarioFramework.CreateTimerTrigger(
		function()
			ScenarioFramework.CreateArmyStatTrigger (P2_SurgicalExpLand, ArmyBrains[ARMY_PLAYER], 'P2_SurgicalExpLandb',
					{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category =(categories.EXPERIMENTAL * categories.LAND * categories.MOBILE) + categories.uub0105 + categories.NUKE}})
		end,
		40
	)
end

function P2_SurgicalExpAir_Init()
	LOG('----- SURGICAL EXP AIR: First air exp detected. Triggering attack after a pause.')
	ScenarioFramework.CreateTimerTrigger(
		function()
			ScenarioFramework.CreateArmyStatTrigger (P2_SurgicalExpAir, ArmyBrains[ARMY_PLAYER], 'P2_SurgicalExpAirb',
					{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category =(categories.EXPERIMENTAL * categories.AIR)}})
		end,
		30
	)
end

function P2_MassFabResponse_Init()
	LOG('----- SURGICAL MASS FAB: First mass fab detected. Triggering attack after a pause.')
	ScenarioFramework.CreateTimerTrigger(
		function()
			ScenarioFramework.CreateArmyStatTrigger (P2_MassFabResponse, ArmyBrains[ARMY_PLAYER], 'P2_MassFabResponseb',
					{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category =categories.uub0704}})
		end,
		45
	)
end

function P2_SurgicalExpLand()
	-- Player has land experimentals, or powerful land units. Send a platoon to attack them.

	if not ScenarioInfo.OpEnded then

		-- Dont spawn surg attacks if we already have a lot of units around
		local enemTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		if enemTotal < 325 then
			LOG('----- SURGICAL EXP LAND: spawning anti land exp attack')

			-- Get a list of player experimentals, then sort them by distance, so we attack the closest first.
			local experimentals = ArmyBrains[ARMY_PLAYER]:GetListOfUnits((categories.EXPERIMENTAL * categories.LAND * categories.MOBILE) + categories.uub0105 + categories.NUKE, false)
			local expList = SortEntitiesByDistanceXZ( ScenarioUtils.MarkerToPosition('P2_ENEM01_ExpResponseCheck_Location'), experimentals )

			local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_SURGICAL_LandExp_Gunships', 'AttackFormation')
			for k, v in expList do
				if v and not v:IsDead() then
					platoon:AttackTarget(v)
				end
			end

			-- Final patrol to send units on, when they have completed their queued list of targets.
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_TransAttack_Attack_Chain_01') -- ok chain to use, to avoid excessive markers.

			-- modify a recheck delay slightly, based on how many experimentals the player has, up to a point.
			local delay = 75
			local delayMod = ((table.getn(experimentals) - 1) * 4) -- allow one 'free' exp, for which we wont modify the delay.
			if delayMod > 12 then delayMod = 12 end
			delay = delay - delayMod
			if delay < 45 then delay = 45 end -- TinFoil Hat
			LOG('----- SURGICAL EXP LAND: player has ' .. table.getn(experimentals) .. ', recheck delayMod will be ' .. delayMod .. ' seconds, for a delay of ' .. delay .. ' seconds.')


			-- Recreate an army stat trigger to detect target units again, but after a pause (is a bit too much
			-- to have a surgical attack respawn immediately.)
			ScenarioFramework.CreatePlatoonDeathTrigger(
				function()
					P2_SurigcalTriggerWithDelay(P2_SurgicalExpLand, 1, (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE) + categories.uub0105 + categories.NUKE, delayMod)
				end
				, platoon
			)

		-- if the enemy has too many units, skip the attack and try again later (ie, recreate the army stat trigger in a bit).
		else
			LOG('----- SURGICAL EXP LAND: Failed! Enemy has too many units already!')
			P2_SurigcalTriggerWithDelay(P2_SurgicalExpLand, 1, (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE) + categories.uub0105 + categories.NUKE, 60)
		end
	end
end

function P2_SurgicalExpAir()
	-- Player has air experimentals, or powerful land units. Send a platoon to attack them.
	if not ScenarioInfo.OpEnded then

		local enemTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		if enemTotal < 325 then
			LOG('----- SURGICAL EXP AIR: spawning anti land exp attack')

			-- Get a list of player experimentals, then sort them by distance, so we attack the closest first.
			local experimentals = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.EXPERIMENTAL * categories.AIR, false)
			local expList = SortEntitiesByDistanceXZ( ScenarioUtils.MarkerToPosition('P2_ENEM01_ExpResponseCheck_Location'), experimentals )

			local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_SURGICAL_AirExp_Fighters', 'AttackFormation')
			for k, v in expList do
				if v and not v:IsDead() then
					platoon:AttackTarget(v)
				end
			end

			-- Final patrol to send units on, when they have completed their queued list of targets.
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_TransAttack_Attack_Chain_01')

			-- Recreate an army stat trigger to detect target units again, but after a pause (is a bit too much
			-- to have a surgical attack respawn immediately)
			ScenarioFramework.CreatePlatoonDeathTrigger(
				function()
					P2_SurigcalTriggerWithDelay(P2_SurgicalExpAir, 1, categories.EXPERIMENTAL * categories.AIR, 50)
				end
				, platoon
			)


		-- if the enemy has too many units, skip the attack and try again later.
		else
			LOG('----- SURGICAL EXP AIR: Failed! Enemy has too many units already!')
			P2_SurigcalTriggerWithDelay(P2_SurgicalExpAir, 1, categories.EXPERIMENTAL * categories.AIR, 60)
		end
	end
end

function P2_SurgicalExcessAir()
	if not ScenarioInfo.OpEnded then

		local enemTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		if enemTotal < 325 then
			LOG('----- SURGICAL EXCESS AIR: spawning air attack to clean up excess air')

			-- Player has too much air. Send a response.
			local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_SURGICAL_AntiAir_Fighter', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_SURGICAL_ExcessUnit_Chain')

			ScenarioFramework.CreatePlatoonDeathTrigger(
				function()
					P2_SurigcalTriggerWithDelay(P2_SurgicalExcessAir, 55, categories.AIR, 45)
				end
				, platoon
			)

		-- Enemy has too many units, check back later.
		else
			LOG('----- SURGICAL EXCESS AIR: Failed! Enemy has too many units already!')
			P2_SurigcalTriggerWithDelay(P2_SurgicalExcessAir, 55, categories.AIR, 45)
		end
	end
end

function P2_SurgicalExcessLand()
	if not ScenarioInfo.OpEnded then

		local enemTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		if enemTotal < 325 then
			LOG('----- SURGICAL EXCESS LAND: spawning air attack to clean up excess land')

			-- Player has too much air. Send a response.
			local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_SURGICAL_AntiLand_Gunships', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_SURGICAL_ExcessUnit_Chain')

			ScenarioFramework.CreatePlatoonDeathTrigger(
				function()
					P2_SurigcalTriggerWithDelay(P2_SurgicalExcessLand, 75, categories.LAND * categories.MOBILE, 70)
				end
				, platoon
			)

		-- Enemy has too many units, check back later.
		else
			LOG('----- SURGICAL EXCESS LAND: Failed! Enemy has too many units already!')
			P2_SurigcalTriggerWithDelay(P2_SurgicalExcessLand, 75, categories.LAND * categories.MOBILE, 60)
		end
	end
end

function P2_MassFabResponse()
	if not ScenarioInfo.OpEnded then
		local enemTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		if enemTotal < 325 then
			LOG('----- MASS FAB RESPONSE: player mass fabs detected')

			-- Respond to mass fabricators, if they are outside of the player's base area (ie, if the player is trying to
			-- duck the attacks by setting up shop elsewhere on the map).

			-- get a list of units, sort them by distance, so they stay in some kind of order from check to check.
			-- add any units outside the player base area to a target list.
			local units = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uub0704, false)
			local unitsSorted = SortEntitiesByDistanceXZ( ScenarioUtils.MarkerToPosition('P1_ALLY01_MainBase_Marker'), units )
			local validTargets = {}
			for k, v in unitsSorted do
				if v and not v:IsDead() and import('/lua/system/utilities.lua').XZDistanceTwoVectors( v:GetPosition(), ScenarioUtils.MarkerToPosition( 'P1_ALLY01_MainBase_Marker' ) ) > 98 then
					table.insert(validTargets, v)
				end
			end

			-- if we have targets that are outside the player base area, attack them
			if table.getn(validTargets) > 0 then
				LOG('----- MASS FAB RESPONSE: creating attack.')
				local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_SURGICAL_MassFab_Gunships', 'AttackFormation')
				for k, v in validTargets do
					if v and not v:IsDead() then
						platoon:AttackTarget(v)
					end
				end
				-- a patrol for after the target is dead
				ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_TransAttack_Attack_Chain_01')
				-- and when the platoon dies, call in another response check, after a while.
				ScenarioFramework.CreatePlatoonDeathTrigger(
					function()
						P2_SurigcalTriggerWithDelay(P2_MassFabResponse, 1, categories.uub0704, 70)
					end
					, platoon
				)

			-- else if no valid targets were found (ie, all mass fabs are in player base area), then recreate the check trigger soon.
			else
				LOG('----- MASS FAB RESPONSE: false alarm, mass fabs are in player base area')
				P2_SurigcalTriggerWithDelay(P2_MassFabResponse, 1, categories.uub0704, 60)
			end
		else
			LOG('-----MASS FAB RESPONSE: Failed! Enemy has too many units already!')
			P2_SurigcalTriggerWithDelay(P2_MassFabResponse, 1, categories.uub0704, 60)
		end
	end
end

function P2_SurigcalTriggerWithDelay(surgFunc, amount, unitCats, delay)
	-- surgFunc: callback for the newly created army stats trigger.
	-- amount: number of units to trigger the new army stats trigger.
	-- unitCats: unit categories the stat trigger should be set for.
	-- delay:  delay before we recreate the trigger

	-- Delay recreating an Army Stats trigger for surgical response a bit, after a surgical platoon has died.
	ScenarioFramework.CreateTimerTrigger (
		function()
			SurgicalTriggerCounter = SurgicalTriggerCounter + 1
			ScenarioFramework.CreateArmyStatTrigger (surgFunc, ArmyBrains[ARMY_PLAYER], 'P2_SurgicalTrigger_' .. SurgicalTriggerCounter,
				{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = amount, Category = unitCats}})
		end
		, delay
	)

end

---------------------------------------------------------------------
-- HIDDEN OBJECTIVES:
---------------------------------------------------------------------

function P1_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Nuke King
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H1_obj10 - Nuke King')
	local descText = OpStrings.U06_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U06_H1_obj10_MAKE_NUKE)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.U06_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('build'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U06_H1_obj10_MAKE_NUKE, ARMY_PLAYER, 3.0)
end

function P1_HiddenObj2Complete(bFromKill)
	-- early out if we have already completed this, or if Kriptors have gotten beyond the bridge (and thus set a failed flag)
	if ScenarioInfo.KriptorsKilled or ScenarioInfo.P2_FailedHiddenObj2 then
		return
	end

	-- only allow this function once
	ScenarioInfo.KriptorsKilled = true

	----------------------------------------------
	-- Hidden Objective H1_obj10 - You Shall Not Pass!
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H2_obj10 - You Shall Not Pass!')
	local descText = OpStrings.U06_H2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U06_H2_obj10_STOP_KRIPTORS)

	-- shorten the text down to just the basics if no research points are to be awarded
	if not bFromKill then
		descText = OpStrings.U06_H2_obj10_DESC
	end
	ScenarioInfo.H2_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.U06_H2_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('kill'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H2_obj10)

	-- if this is from a kill - award the points
	if bFromKill then
		ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U06_H2_obj10_STOP_KRIPTORS, ARMY_PLAYER, 3.0)
	end
end

---------------------------------------------------------------------
-- UTILITY FUNCTIONS:
---------------------------------------------------------------------

function RandomPatrolThread(platoon, chain, army)
	-- Give members of a platoon a random patrol using the points of a chain.
	if(platoon and ArmyBrains[army]:PlatoonExists(platoon)) then
		for k, v in platoon:GetPlatoonUnits() do
			if v and not v:IsDead() then
				IssueClearCommands({v})
				ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(chain))
			end
		end
	end
end

---------------------------------------------------------------------
-- SPECIAL HANDLING:
---------------------------------------------------------------------
function SpecialPlayerSetup_Step1()
	-- set up the player army as if it was just a generic army (custom handling for the special case part1 build/research/econ restrictions)
	ScenarioGameSetup.SetupGenericArmy( ARMY_PLAYER, ScenarioGameTuning.color_UEF_PLAYER )

	-- strip the player of any energy they might have
	local defaultEnergy = ScenarioInfo.Options.InitialEnergy
	if defaultEnergy then
		ArmyBrains[ARMY_PLAYER]:TakeResource('ENERGY', defaultEnergy)
	end
	-- strip the player of any mass they might have
	local defaultMass = ScenarioInfo.Options.InitialMass
	if defaultMass then
		ArmyBrains[ARMY_PLAYER]:TakeResource('MASS', defaultMass)
	end

	LOG('----- OnPopulate: Update Build and Research Restrictions.')
	-- build a list of all categories that are already restricted from the research system
	P2_PlayerUnlockList = categories.ALLUNITS
	local DefaultBuildRestrictions = import('/lua/sim/DefaultBuildRestrictions.lua').DefaultBuildRestrictions
	if DefaultBuildRestrictions then
		for k, cat in DefaultBuildRestrictions do
			P2_PlayerUnlockList = P2_PlayerUnlockList - cat
		end
	end

	-- now use the researchLockedCats list to only lock the player out of everything else
	ScenarioFramework.AddRestriction(ARMY_PLAYER, P2_PlayerUnlockList)

	-- and now fully restrict all research except ACU completed research items
	for techName, tech in ResearchDefinitions do
		ArmyBrains[ARMY_PLAYER]:ResearchRestrict( {techName}, true )
	end

	---NOTE: this is not the best way to do this with our setup, but it is the cleanest and safest for this stage of the project - bfricks 1/18/10
	ArmyBrains[ARMY_PLAYER]:CompleteResearch(
		{
			'UCA_HUNKER',
			'UCB_DAMAGE',
			'UCB_HEALTH',
			'UCB_REGENERATION',
			'UCP_AA',
		}
	)

	-- finally flag that we are in a state where selection callbacks will work
	ScenarioInfo.OnSelectCallbacksAllowed = true

	-- flag the player army such that they can not store any research points
	ArmyBrains[ARMY_PLAYER]:SetMaxStorage('RESEARCH', 0)
end

function SpecialPlayerSetup_Step2()
	-- flag the player ACU such that they produce no resources
	ScenarioInfo.PLAYER_CDR:SetProductionActive(false)

	-- setup a special trigger for when the player first selects their ACU
	ScenarioFramework.CreateUnitSelectedTrigger(OnSelect_CDR, ScenarioInfo.PLAYER_CDR)
end

function SpecialPlayerCleanup()
	-- enable econ production on the ACU
	ScenarioInfo.PLAYER_CDR:SetProductionActive(true)

	-- store any resources that have been aquired before we setup the player
	local curStoredMass = ArmyBrains[ARMY_PLAYER]:GetEconomyStored('Mass')
	local curStoredEnergy = ArmyBrains[ARMY_PLAYER]:GetEconomyStored('Energy')

	-- now properly setup the player army
	ScenarioGameSetup.SetupPlayerArmy(ARMY_PLAYER, ScenarioGameTuning.U06_PLAYER)

	-- now give the player their stored resources - to be nice
    ArmyBrains[ARMY_PLAYER]:GiveResource( 'MASS', curStoredMass )
	ArmyBrains[ARMY_PLAYER]:GiveResource( 'ENERGY', curStoredEnergy )

	-- enable research point accumulation again
	if ScenarioInfo.ResearchData and ScenarioInfo.ResearchData.TotalPointCount then
		ArmyBrains[ARMY_PLAYER]:SetMaxStorage('RESEARCH', ScenarioInfo.ResearchData.TotalPointCount)
	else
		WARN('WARNING: somehow U06 is being played without a valid ScenarioInfo.ResearchData or ScenarioInfo.ResearchData.TotalPointCount!')
	end

	-- finally unflag that we are in a state where selection callbacks will work
	ScenarioInfo.OnSelectCallbacksAllowed = false
end
---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function LaunchVictoryNIS(unit)
	--end any existing heavy attack loops that are running.
	ScenarioInfo.P2_HeavyTrans_LandAtPlayer = false
	ScenarioInfo.P2_HeavyTrans_LandAtReactor = false

	ForkThread(
		function()
			ScenarioInfo.ArmyBase_P2_ENEM01_Bridgebase:BaseActive(false)
			ScenarioInfo.AssignedObjectives.VictoryCallbackList = {}
			-- If player completed the operation before either killing the Kriptors or having them cross the bridge, they succeded at a hidden obj.
			if not ScenarioInfo.KriptorsKilled and not ScenarioInfo.P2_FailedHiddenObj2 then
				table.insert(ScenarioInfo.AssignedObjectives.VictoryCallbackList, P1_HiddenObj2Complete)
			end
			OpNIS.NIS_VICTORY(unit)
		end
	)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	LOG('----- ScenarioInfo.P2_HeavyTrans_LandAtPlayer is ' , ScenarioInfo.P2_HeavyTrans_LandAtPlayer)
	LOG('----- ScenarioInfo.P2_HeavyTrans_LandAtReactor is ' , ScenarioInfo.P2_HeavyTrans_LandAtReactor)

end
function OnShiftF4()
	ScenarioFramework.SetPlayableArea('P2_Playable_Area', false)
	import('/lua/system/Utilities.lua').UserConRequest('SallyShears')
	import('/lua/system/Utilities.lua').UserConRequest('dbg collision')
end

function OnShiftF5()
	if not ScenarioInfo.P2_FailedHiddenObj2 then
		P1_HiddenObj2Complete()
	end
end
