---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_I04/SC2_CA_I04_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_I04/SC2_CA_I04_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_I04/SC2_CA_I04_OpNIS.lua')
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
local CannonUtils			= import('/lua/sim/ScenarioFramework/ScenarioGameUtilsUnitCannon.lua')

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
ScenarioInfo.ARMY_ALLY01 = 2
ScenarioInfo.ARMY_ENEM01 = 3
ScenarioInfo.ARMY_ENEM02 = 4

ScenarioInfo.AssignedObjectives = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ENEM02 = ScenarioInfo.ARMY_ENEM02

local UnitCannonFiredVO = false
local UnitCannonAttackVO = false
local UnitCannonSpottedVO = false
local UnitCannonDestroyed = false

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local PlayerStartIntelRadius						= 9001	-- radius of player's starting radar intel that should cover the entire map

local EnemyLandAttack01_TIMER						= 83	-- first enemy land attack timer
local EnemyLandAttack02_TIMER						= 153	-- second enemy land attack timer
local EnemyLandAttack03_TIMER						= 223	-- three enemy land attack timer
local EnemyLandAttack04_TIMER						= 303	-- fourth enemy land attack timer
local EnemyLandAttack05_TIMER						= 373	-- fifth enemy land attack timer
local EnemyLandAttack06_TIMER						= 443	-- six enemy land attack timer
local EnemyLandAttack07_TIMER						= 513	-- seventh enemy land attack timer
local EnemyLandAttack08_TIMER						= 583	-- eighth enemy land attack timer
local EnemyLandAttack09_TIMER						= 653	-- ninth enemy land attack timer

local GaugeTransport_TIMER							= 51	-- gauge's transport sequence timer

local P1_ENEM01_Air_AttackPlayer_01_OpAI_CHILDCOUNT	= 1		-- ENEM01 custom air platoon (AirAttackPlayer) child count
local P1_ENEM01_Air_AttackGauge_01_OpAI_CHILDCOUNT	= 1 	-- ENEM01 custom air platoon (AirAttackGauge) child count
local P2_ENEM02_MML_Attack_01_OpAI_CHILDCOUNT		= 2		-- ENEM02 custom land platoon (MMLAttackPlayer) child count

local P1_ALLY01_Megalith_Assault_OpAI_CHILDCOUNT	= 2		-- gauge's megalith child count (do not change for now)
local P1_ALLY01_Air_Assault_OpAI_CHILDCOUNT			= 1		-- gauge's custom air platoon (CybranAirAttack) child count

local nNumCDRsDestroyed								= 0		-- tracking value for CDR deaths

---------------------------------------------------------------------
-- CUSTOM PLATOONS:
---------------------------------------------------------------------
local AirAttackPlayer = {
	'UEF_AirAttackPlayer_Platoon',
	{
		{ 'uua0101', 1 }, -- UEF fighters
		{ 'uua0102', 4 }, -- UEF bombers
	},
}

local AirAttackGauge = {
	'UEF_AirAttackGauge_Platoon',
	{
		{ 'uua0101', 1 }, -- UEF fighters
		{ 'uua0102', 5 }, -- UEF bombers
	},
}

local CybranAirAttack = {
	'CYB_AirAttack_Platoon',
	{
		{ 'uca0104', 4 }, -- CYBRAN fighter/bombers
	},
}

local MMLAttackPlayer = {
	'UEF_MMLAttack_Platoon',
	{
		{ 'uul0104', 4 }, -- UEF mobile missile launchers
		{ 'uul0103', 2 }, -- UEF assault bots
	},
}

local LandAttack = {
	'CYB_LandAttack_Platoon',
	{
		{ 'ucl0204', 1 }, -- UEF mobile missile launchers
		{ 'ucl0103', 5 }, -- UEF assault bots
	},
}

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
-- P1: Enemy land attack timers:	Timed triggers that send groups of land units from the central
--									area toward the player's starting area. These are spaced evenly
--									apart to keep a steady stream of land attacks on the player.
--									The final attack should not exceed 600 seconds.
--									FUNCTION: P1_Setup()
--									TUNE: ... _TIMER
--
--
-- P1: Air attack, Player:			Light air attacks sent from ENEM01's base towards the player's
--									starting base on OP start. These are custom air platoons that
--									do increase in size after the central enemy base is destroyed.
--									These are mainly to keep light pressure on the player and enforce
--									the idea the player should go land on OP start.
--									FUNCTION: P1_AISetup_ENEM01_Main()
--									TUNE: AirAttackPlayer
--
--
-- P1: Air attack, ALLY01:			Light air attack sent from ENEM01's base towards ALLY01's base.
--									These are custom air platoons consisting mainly of bombers.
--									These are only designed to increase the OP activity and should
--									not significantly damage gauge's units.
--									FUNCTION: P1_OpAI_ENEM01()
--									TUNE: AirAttackGauge
--
--
-- P1: Ally air attack, ENEM01:		Light air attacks sent from ALLY01's base towards ENEM01's base.
--									These are custom bomber platoons that are only designed to
--									increase the OP activity from gauge.
--									FUNCTION: P1_AISetup_ALLY01_Main()
--									TUNE: CybranAirAttack
--
--
-- P2: Land attack, ENEM02:			Medium land attack sent from ENEM02's base towards the player's
--									base. These are custom land platoons consisting mainly of MMLs.
--									These are triggered after the megalith's enter the central area.
--									FUNCTION: P2_OpAI_ENEM02_MML()
--									TUNE: MMLAttackPlayer
--
--
-- P1/P2: Enemy OpAI attacks:		Custom platoon attacks sent from the enemy towards the player and
--									his/her ally. Child count should not exceed 3.
--									FUNCTIONS: P1_OpAI_ENEM01(), P2_OpAI_ENEM02_MML()
--									TUNE: ... _CHILDCOUNT
--
--
-- P1: Ally OpAI attacks:			Custom platoon attacks sent from ALLY01 toward the enemy. Child
--									count should not exceed 3. If
--									'P1_ALLY01_Megalith_Assault_OpAI_CHILDCOUNT' is changed then other
--									dependancy triggers will also need to be changed.
--									FUNCTION: P2_OpAI_ALLY01_Main()
--									TUNE: ... _CHILDCOUNT

---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.1,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.I04_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.I04_ARMY_ENEM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM02,	ScenarioGameTuning.I04_ARMY_ENEM02)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ALLY01,	ScenarioGameTuning.I04_ARMY_ALLY01)
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
		areaStart		= 'AREA_01',			-- if valid, the area to be used for setting the starting playable area
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

	LOG('----- P1_Setup: Create commanders')
	ScenarioInfo.ENEMAIR_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEMAIR_CDR')
	ScenarioInfo.ENEMAIR_CDR:SetCustomName(ScenarioGameNames.CDR_Mosley)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEMAIR_CDR, 3)

	ScenarioInfo.ENEMLAND_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ENEM02', 'ENEMLAND_CDR')
	ScenarioInfo.ENEMLAND_CDR:SetCustomName(ScenarioGameNames.CDR_Kita)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEMLAND_CDR, 3)

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.ENEMAIR_CDR:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.ENEMLAND_CDR:RemoveCommandCap('RULEUCC_Reclaim')

	-- CDR death damage triggers
	ScenarioFramework.CreateUnitDeathTrigger(ENEMAIR_CDR_DeathDamage, ScenarioInfo.ENEMAIR_CDR)
	ScenarioFramework.CreateUnitDeathTrigger(ENEMLAND_CDR_DeathDamage, ScenarioInfo.ENEMLAND_CDR)

	ScenarioFramework.GroupPatrolChain({ScenarioInfo.ENEMAIR_CDR}, 'ArmyBase_ENEM01_Main_Base_EngineerChain')
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.ENEMLAND_CDR}, 'ArmyBase_ENEM02_Main_Base_EngineerChain')

	----------------------------------------------
	-- Op Flow Timers, and other settings
	----------------------------------------------
	ScenarioInfo.P1_ENEM01_Gunship_DefenseTable = {}

	-----------------------------------------------
	-- Setup starting groups, platoons, and patrols
	-----------------------------------------------

	LOG('----- P1_Setup: Create starting base managers and opais')
	-- Set their bases up
	P1_AISetup_ENEM01_Main()
	P1_AISetup_ENEM02_Main()

	LOG('----- P1_Setup: Create starting units, groups, platoons for the enemy')
	-- create initial land platoon for UEF LAND enemy
	ScenarioInfo.LandPatrol01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Patrol01')

	ScenarioInfo.DefensePatrol01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Defense01')

	-- create initial land attack groups that rally at the central base and attack the enemy one at a time
	ScenarioInfo.LandAttack01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack01')
	ScenarioInfo.LandAttack02 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack02')
	ScenarioInfo.LandAttack03 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack03')
	ScenarioInfo.LandAttack04 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack04')
	ScenarioInfo.LandAttack05 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack05')
	ScenarioInfo.LandAttack06 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack06')
	ScenarioInfo.LandAttack07 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack07')
	ScenarioInfo.LandAttack08 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack08')
	ScenarioInfo.LandAttack09 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack09')
	ScenarioInfo.LandAttack10 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM02', 'ENEM02_InitLand_Attack10')

	-- get all land units from the the just created land groups and give them a veterancy buff
	local landGroup = ArmyBrains[ARMY_ENEM02]:GetListOfUnits(categories.uul0101 + categories.uul0103,false)
	for k, unit in landGroup do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 3)
	end

	-- create initial gunship platoon for UEF AIR enemy
	-- Moved so it can be seen in NIS_OPENING -#### balfieri 09/23/09
	ScenarioInfo.Gunships01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'ENEM01_InitAir_Gunships01', 'AttackFormation')

	--#Commenting out for now ~cdaroza
--	PlatoonRandomPatrol(ScenarioInfo.Gunships01, 'ArmyBase_ENEM01_Main_Base_Patrol_Air01')

	ScenarioInfo.P1_ENEM01_GUN38 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_GUN38']
	ScenarioInfo.P1_ENEM01_GUN54 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_GUN54']
	table.insert(ScenarioInfo.P1_ENEM01_Gunship_DefenseTable, ScenarioInfo.Gunships01)

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Transport_Group1')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group1, 1)
	ScenarioInfo.INTRONIS_Group2 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Transport_Group2')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group2, 1)
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')

	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')
	ScenarioInfo.INTRONIS_Group2Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_02')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_03')
	ProtectUnit(ScenarioInfo.INTRONIS_Group1Transport)
	ProtectUnit(ScenarioInfo.INTRONIS_Group2Transport)
	ProtectUnit(ScenarioInfo.INTRONIS_CommanderTransport)

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Thalia)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	ScenarioInfo.P1_PLAYER_ENG01 = ScenarioInfo.UnitNames[ARMY_PLAYER]['P1_PLAYER_ENG01']
	ScenarioInfo.P1_PLAYER_ENG02 = ScenarioInfo.UnitNames[ARMY_PLAYER]['P1_PLAYER_ENG02']

	-- Create tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')
end

function PlatoonRandomPatrol(platoon, chain)
	-- Give members of a platoon a random patrol using the points of a chain.
	if(platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon)) then
		for k, v in platoon:GetPlatoonUnits() do
			IssueClearCommands({v})
			ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(chain))
		end
	end
end

function P1_Main()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Destroy Enemy Commanders
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Destroy Enemy Commanders.')
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.I04_M1_obj10_NAME,		-- title
		OpStrings.I04_M1_obj10_DESC, 		-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.ENEMAIR_CDR, ScenarioInfo.ENEMLAND_CDR },
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	-- setup each possible ending unit for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEMAIR_CDR, LaunchENEM_CDRDeathNIS)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEMLAND_CDR, LaunchENEM_CDRDeathNIS)

	-- create initial gunship platoon for UEF AIR enemy
	ScenarioInfo.Air_AttackPlayer_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'ENEM01_InitAir_Offense01', 'AttackFormation')

	----------------------------------------------
	-- Sequence Timers
	----------------------------------------------

	-- create timer for when Gauge will arrive via transport
	ScenarioFramework.CreateTimerTrigger(P1_Gauge_ArrivalVO, GaugeTransport_TIMER)

	-- create timer for sequential land atacks from the central enemy base area
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack01, EnemyLandAttack01_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack02, EnemyLandAttack02_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack03, EnemyLandAttack03_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack04, EnemyLandAttack04_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack05, EnemyLandAttack05_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack06, EnemyLandAttack06_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack07, EnemyLandAttack07_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_ENEM01_LandAttack08, EnemyLandAttack08_TIMER)

	-- move LandAttack groups to central area
	IssueMove( ScenarioInfo.LandAttack01, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack02, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack03, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack04, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack05, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack06, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack07, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack08, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack09, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )
	IssueMove( ScenarioInfo.LandAttack10, ScenarioUtils.MarkerToPosition( 'P1_ENEM02_Central_Base_Rally01' ) )

	----------------------------------------------
	-- Unit and Patrol creation
	----------------------------------------------
	-- create radar intel for player that covers the entire map
	ScenarioFramework.CreateIntelAtLocation(PlayerStartIntelRadius, 'P1_ENEM02_Central_Base_Marker', ARMY_PLAYER, 'Radar')

	-- setup patrol chains for the enemy land units near the players starting area
	IssueAggressiveMove( ScenarioInfo.LandPatrol01, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )

	-- issue from move to markers around the central area
	for k, v in ScenarioInfo.LandAttack01 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack01_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack02 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack02_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack03 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack03_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack04 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack04_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack05 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack05_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack06 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack06_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack07 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack07_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack08 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack09_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack09 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack10_Rally' ), 'AttackFormation', 0 )
	end
	for k, v in ScenarioInfo.LandAttack10 do
		IssueFormMove( {v}, ScenarioUtils.MarkerToPosition( 'ENEM02_LandAttack10_Rally' ), 'AttackFormation', 0 )
	end

	-- Set up and start each army's base and opais, etc.
	P1_OpAI_ENEM01()

	----------------------------------------------
	-- General triggers
	----------------------------------------------
	-- Create army stat trigger for hidden objective tracking of experimental units built by player
	ScenarioFramework.CreateArmyStatTrigger (HiddenObjective, ArmyBrains[ARMY_PLAYER], 'HiddenObjective',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 8, Category = categories.EXPERIMENTAL}})

	----------------------------------------------
	-- VO triggers
	----------------------------------------------

	-- VO trigger telling the player to attack in tandem with the megaliths that have just been built
	ScenarioFramework.CreateArmyStatTrigger (P2_ALLY01MegalithBuilt, ArmyBrains[ARMY_ALLY01], 'P2_ALLY01MegalithBuilt',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ucx0101}})

	-- VO trigger when player kills 5 enemy air units
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerKilledInitialAir, ArmyBrains[ARMY_ENEM01], 'P1_PlayerKilledInitialAir',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.AIR}})

	-- VO trigger when the player kills the east UEF commander
	ScenarioFramework.CreateArmyStatTrigger (P3_CDR_EastDead, ArmyBrains[ARMY_ENEM02], 'P3_CDR_EastDead',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uul0001}})

	-- VO trigger when the player kills the north UEF commander
	ScenarioFramework.CreateArmyStatTrigger (P3_CDR_NorthDead, ArmyBrains[ARMY_ENEM01], 'P3_CDR_NorthDead',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uul0001}})

	-- VO trigger when the player attempts to assault the central area
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerCentralAttack, ArmyBrains[ARMY_ALLY01], 'P1_PlayerCentralAttack',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ucb0011}})

	-- VO trigger when the player takes out a significant portion of the enemy land being sent out from the central base
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerCentralKills, ArmyBrains[ARMY_ENEM02], 'P1_PlayerCentralKills',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 36, Category = categories.LAND * categories.UEF * categories.MOBILE}})

	-- VO trigger north of the central area warning the player of the gunships
	ScenarioFramework.CreateAreaTrigger(P1_AREA_NORTH_VO_TRIGGER, 'AREA_NORTH_VO_TRIGGER',
			categories.LAND * categories.ILLUMINATE * categories.MOBILE, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- VO trigger east of the central area telling the player that the east base is not defended against land
	ScenarioFramework.CreateAreaTrigger(P1_AREA_EAST_VO_TRIGGER, 'AREA_EAST_VO_TRIGGER',
			categories.LAND * categories.ILLUMINATE * categories.MOBILE, true, false, ArmyBrains[ARMY_PLAYER], 6, false)

	-- VO trigger at east enemy base telling the player they are doing well
	ScenarioFramework.CreateAreaTrigger(P2_PlayerUnitsAt_EastBase, 'AREA_EAST_BASE_TRIGGER',
			categories.ILLUMINATE * categories.MOBILE, true, false, ArmyBrains[ARMY_PLAYER], 12, false)

	-- VO trigger at north enemy base telling the player they are doing well
	ScenarioFramework.CreateAreaTrigger(P2_PlayerUnitsAt_NorthBase, 'AREA_NORTH_BASE_TRIGGER',
			categories.ILLUMINATE * categories.MOBILE, true, false, ArmyBrains[ARMY_PLAYER], 12, false)

	-- VO trigger that cues the banter from base alpha CDR
	ScenarioFramework.CreateAreaTrigger(P1_East_CDR_Banter_01, 'P2_AREA_Megalith_01',
			categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- VO trigger that plays when player spots the unit cannon
	ScenarioFramework.CreateArmyIntelTrigger(P1_UnitCannon_Spotted_01, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		 categories.uux0114, true, ArmyBrains[ARMY_ENEM01])

	-- VO trigger that plays when player spots the unit cannon
	ScenarioFramework.CreateArmyIntelTrigger(P1_UnitCannon_Spotted_01, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		 categories.uux0114, true, ArmyBrains[ARMY_ENEM02])

	-- Create army stat trigger that looks for the unit cannon to be built
	ScenarioFramework.CreateArmyStatTrigger(EastUnitCannonBuilt, ArmyBrains[ARMY_ENEM02], 'EastUnitCannonBuilt',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0114}})

	ScenarioFramework.CreateArmyStatTrigger(NorthUnitCannonBuilt, ArmyBrains[ARMY_ENEM01], 'NorthUnitCannonBuilt',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0114}})

	-- Create army stat trigger that turns on the megalith OpAI after both experimental factories are completely built
	ScenarioFramework.CreateArmyStatTrigger(P2_OpAI_ALLY01_Main, ArmyBrains[ARMY_ALLY01], 'P2_OpAI_ALLY01_Main',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ucb0011}})

	-- Create army stat trigger that plays general banter VO after gauge's land factory is built
	ScenarioFramework.CreateArmyStatTrigger(General_Banter_VO, ArmyBrains[ARMY_ALLY01], 'General_Banter_VO',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 3, Category = categories.ucb0102}})

	-- Create army stat trigger that plays ally banter VO after gauge's shields generators are built
	ScenarioFramework.CreateArmyStatTrigger(Ally_Banter_VO, ArmyBrains[ARMY_ALLY01], 'Ally_Banter_VO',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.ucb0202}})

	-- Create timer trigger that will play VO
	ScenarioFramework.CreateTimerTrigger (Alpha_Banter_VO, 20)
end

function Alpha_Banter_VO()
	-- play alpha base CDR VO banter if he exists
	if ScenarioInfo.ENEMAIR_CDR and not ScenarioInfo.ENEMAIR_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I04_UEF_ALPHA_BANTER_010)
	end
end

function Ally_Banter_VO()
	ScenarioFramework.Dialogue(OpDialog.I04_GENERAL_BANTER_010)
end

function General_Banter_VO()
	ScenarioFramework.Dialogue(OpDialog.I04_ALLY_BANTER_010)
end

function EastUnitCannonBuilt()
	-- create unit cannon handle
	ScenarioInfo.UnitCannon_East = ScenarioInfo.UnitNames[ARMY_ENEM02]['P1_ENEM02_UC01']
end

function NorthUnitCannonBuilt()
	-- create unit cannon handle
	ScenarioInfo.UnitCannon_North = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_UC01']
end

function AllyGroup_03_Attack()
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.NIS_AllyGroup_03, 'ArmyBase_ALLY01_Main_Base_AttackChain02')
end

function AllyGroup_04_Attack()
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.NIS_AllyGroup_04, 'ArmyBase_ALLY01_Main_Base_AttackChain02')
end

function P1_UnitCannon_Spotted_01()
	if not UnitCannonSpottedVO then
		UnitCannonSpottedVO = true
		-- play unit cannon spotted VO
		ScenarioFramework.Dialogue(OpDialog.I04_UNIT_CANNON_SPOTTED)
	end
end

function P1_UnitCannon_Fired()
	if not UnitCannonFiredVO then
		UnitCannonFiredVO = true
		UnitCannonSpottedVO = true
		-- play unit cannon fired but not spotted VO
		ScenarioFramework.Dialogue(OpDialog.I04_UNIT_CANNON_FIRED)
		-- VO trigger that plays when player spots the unit cannon
		if ScenarioInfo.UnitCannon_North and not ScenarioInfo.UnitCannon_North:IsDead() then
			ScenarioFramework.CreateArmyIntelTrigger(P1_UnitCannon_Spotted_02, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
				 categories.uux0114, true, ArmyBrains[ARMY_ENEM01])
		elseif ScenarioInfo.UnitCannon_East and not ScenarioInfo.UnitCannon_East:IsDead() then
			ScenarioFramework.CreateArmyIntelTrigger(P1_UnitCannon_Spotted_02, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
				 categories.uux0114, true, ArmyBrains[ARMY_ENEM02])
		end
	end
end

function P1_UnitCannon_Attacks()
	if not UnitCannonAttackVO then
		UnitCannonAttackVO = true
		-- play unit cannon persistent attack VO
		ScenarioFramework.Dialogue(OpDialog.I04_UNIT_CANNON_FIRED_AFTER_SPOTTED)
	end
end

function P1_UnitCannon_Spotted_02()
	-- play unit cannon spotted after it has fired
	ScenarioFramework.Dialogue(OpDialog.I04_UNIT_CANNON_SPOTTED_AFTER_FIRED)
end

function P1_UnitCannon_Destroyed()
	if not UnitCannonDestroyed then
		UnitCannonDestroyed = true
		-- play unit cannon destroyed VO
		ScenarioFramework.Dialogue(OpDialog.I04_UNIT_CANNON_DESTROYED)
	end
end

function P1_East_CDR_Banter_01()
	-- if alpha base land CDR is alive player VO
	if ScenarioInfo.ENEMLAND_CDR and not ScenarioInfo.ENEMLAND_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I04_UEF_BRAVO_BANTER_010)
	end
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.I04_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.I04_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.I04_S1_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)

	ScenarioInfo.S1_obj10:AddProgressCallback(
		function()
			if not ScenarioInfo.AntiMissileResearched and ArmyBrains[ARMY_PLAYER]:HasResearched('ILU_ANTIMISSILE') then
				ScenarioInfo.AntiMissileResearched = true
				ScenarioFramework.Dialogue(OpDialog.I04_RESEARCH_FOLLOWUP_ANTIMISSILE_010)
			elseif not ScenarioInfo.AssBlockResearched and ArmyBrains[ARMY_PLAYER]:HasResearched('ILU_URCHINOW') then
				ScenarioInfo.AssBlockResearched = true
				ScenarioFramework.Dialogue(OpDialog.I04_RESEARCH_FOLLOWUP_ASSAULTBLOCK_010)
			else
				ScenarioFramework.Dialogue(OpDialog.I04_RESEARCH_FOLLOWUP_COLOSSUS_010)
			end
		end
	)
end

function HiddenObjective()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Tech Fanatic
	----------------------------------------------
	LOG('----- Assign Hidden Objective H1_obj10 - Tech Fanatic')
	local descText = OpStrings.I04_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I04_H1_obj10_MAKE_EXPS)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.I04_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('build'),	-- Action
		{
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I04_H1_obj10_MAKE_EXPS, ARMY_PLAYER, 3.0)
end

function P1_PlayerKilledInitialAir()
	LOG('----- P1: player has killed some UEF air. Play VO')

	-- Tell player to build anti-air defenses instead of air units.
	ScenarioFramework.Dialogue(OpDialog.I04_UEF_AIR_DESTROYED_010)
end

function P1_PlayerCentralKills()
	LOG('----- P1: player has killed some enemy land units. Play VO')
	if ScenarioInfo.ALLYCYB_CDR and not ScenarioInfo.ALLYCYB_CDR:IsDead() then
		-- Tell player to build a larger land force to assault the central base.
		ScenarioFramework.Dialogue(OpDialog.I04_PLAYER_CENTRAL_KILLS_010)
	end
end

function P1_PlayerCentralAttack()
	LOG('----- P1: Gauge talking about megaliths. Play VO')
	local centralEnemyStructures = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE, ScenarioUtils.AreaToRect('P2_AREA_Megalith_01'), ArmyBrains[ARMY_ENEM02])

	if table.getn(centralEnemyStructures) > 0 then
		-- Gauge tells the player that he will focus on the center with megaliths
		ScenarioFramework.Dialogue(OpDialog.I04_PLAYER_CENTRAL_ATTACK_010)
	end
end

function P1_AREA_NORTH_VO_TRIGGER()
	LOG('----- P1: North Area Trigger. Play VO')

	--HQ suggests fighters as a solution to the gunships
	if ScenarioInfo.ENEMAIR_CDR and not ScenarioInfo.ENEMAIR_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I04_PLAYER_HQ_NORTH_AREA_010)
	end
end

function P1_AREA_EAST_VO_TRIGGER()
	LOG('----- P1: East Area Trigger. Play VO')

	--HQ gives intel about the east enemy base
	if ScenarioInfo.ENEMLAND_CDR and not ScenarioInfo.ENEMLAND_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I04_PLAYER_HQ_EAST_AREA_010)
	end
end

function P1_AREA_SOUTH_VO_TRIGGER()
	LOG('----- P1: South Area Trigger. Play VO')

	--Gauge gives some advice
	ScenarioFramework.Dialogue(OpDialog.I04_ALLY_GAUGE_SOUTH_AREA_010)
end

function P1_AREA_WEST_VO_TRIGGER()
	LOG('----- P1: West Area Trigger. Play VO')

	--Gauge reminds the player of the primary objectives
	if ScenarioInfo.ALLYCYB_CDR and not ScenarioInfo.ALLYCYB_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I04_ALLY_GAUGE_WEST_AREA_010)
	end
end

function P2_PlayerUnitsAt_EastBase()
	LOG('----- P2: Player has a significant force around the east enemy base. Play VO')

	-- HQ tells the players good work.
	if ScenarioInfo.ENEMLAND_CDR and not ScenarioInfo.ENEMLAND_CDR:IsDead()then
		ScenarioFramework.Dialogue(OpDialog.I04_PLAYER_EAST_BASE_010)
	end
end

function P2_PlayerUnitsAt_NorthBase()
	LOG('----- P2: Player has a significant force around the north enemy base. Play VO')

	-- HQ tells the players good work.
	if ScenarioInfo.ENEMAIR_CDR and not ScenarioInfo.ENEMAIR_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I04_PLAYER_NORTH_BASE_010)
	end
end

function P2_Enem02BuildsMML()
	LOG('----- P2: ENEM02 has built MML. Play VO')

	-- Tell player to build mobile anti-missile units in response to the player building MML.
	ScenarioFramework.Dialogue(OpDialog.I04_ENEM02_BUILDS_MML_010)
end

function P2_ALLY01MegalithBuilt()
	LOG('----- P2: ALLY01 Megaliths are built. Play VO')
	local megaliths = ScenarioFramework.GetCatUnitsInArea(categories.ucx0101, 'GAUGE_BASE_AREA', ArmyBrains[ARMY_ALLY01])
	-- Flag megaliths and non-reclaimable so the player can't attempt any shenanigans with broomsticks
	for k, v in megaliths do
		v:SetReclaimable(false)
		ScenarioFramework.GroupPatrolChain({v}, 'ArmyBase_ALLY01_Main_Base_MegalithChain_01')
		ScenarioFramework.SetUnitVeterancyLevel(v, 5)
	end

	-- Tell player to attack together with his megaliths if there are enemy structures int he center
	ScenarioFramework.Dialogue(OpDialog.I04_ALLY01_MEGALITHS_BUILT_010)

	ScenarioInfo.ArmyBase_ENEM02_Main_Base:SetEngineerCount(2)
	ScenarioInfo.P1_ENEM01_Air_AttackGauge_01_OpAI:Enable()
	ScenarioInfo.ArmyBase_ENEM02_Central_Base:SetBuildAllStructures(false)

	-- Weapon damage adjustment function for the megaliths
	AdjustMegalithWeapons()
end

function P2_ALLY01MegalithKilled()
	LOG('----- P2: ALLY01 Megaliths are killed. Play VO')

	-- Tell player to capture central map area and attack UEF Land commander while he is crippled.
	ScenarioFramework.Dialogue(OpDialog.I04_ALLY01_MEGALITHS_DESTROYED_010)

	ScenarioInfo.P1_ENEM01_Air_AttackPlayer_01_OpAI:SetChildCount(2)
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:Disable()

	if ScenarioInfo.ENEMAIR_CDR and not ScenarioInfo.ENEMAIR_CDR:IsDead() then
		-- Enable single megalith attack OpAI sent at the north enemy base
		ScenarioInfo.P1_ALLY01_Megalith_North_OpAI:Enable()
		-- Enable land attack sent at the north base
		ScenarioInfo.P1_ALLY01_LandAttack_North_OpAI:Enable()
	elseif ScenarioInfo.ENEMLAND_CDR and not ScenarioInfo.ENEMLAND_CDR:IsDead() then
		-- Enable single megalith attack OpAI sent at the east enemy base
		ScenarioInfo.P1_ALLY01_Megalith_East_OpAI:Enable()
		-- Enable land attack sent at the east base
		ScenarioInfo.P1_ALLY01_LandAttack_East_OpAI:Enable()
	end

end

function P3_CDR_EastDead()
	LOG('----- P3_CDR_EastDead: ForkThread')
	ForkThread(P1_North_CDR_UnitCannon)
end

function P1_North_CDR_UnitCannon()
	-- Delay before alpha base banter VO is played
	WaitSeconds(9)
	if ScenarioInfo.ENEMAIR_CDR and not ScenarioInfo.ENEMAIR_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I04_UEF_ALPHA_BANTER_020)
	end

	-- Call gauge assist function
	P1_Gauge_AntiAirTransport()

	-- Fire unit cannon
	if ScenarioInfo.UnitCannon_North and not ScenarioInfo.UnitCannon_North:IsDead() then
 		local data = {
 			cannonUnit			= ScenarioInfo.UnitCannon_North,
 			strArmyName			= 'ARMY_ENEM01',
 			destChainName		= 'CANNON_LANDING_CHAIN',
 			shotsPerVolley		= 10,
 			delayBetweenVolleys	= 60.0,
 			ammoUnitType		= 'uul0101',
 			patrolChainName		= 'CANNON_AMMO_PATROL_CHAIN_FROM_AIR',
 		}
 		CannonUtils.StartCannon(data)

 		-- Create north unit cannon VO death trigger
 		ScenarioFramework.CreateUnitDeathTrigger( P1_UnitCannon_Destroyed, ScenarioInfo.UnitCannon_North)

		-- if the unit cannon has already been spotted play firing VO
 		if UnitCannonSpottedVO == true then
 			P1_UnitCannon_Attacks()
 		-- if the unit cannon has not already been spotted play alternate firing VO
 		elseif UnitCannonSpottedVO == false then
 			P1_UnitCannon_Fired()
 		end
 	end
end

function P3_CDR_NorthDead()
	LOG('----- P3_CDR_NorthDead: North UEF Commander Dead')
	ForkThread(P1_East_CDR_UnitCannon)
end

function P1_East_CDR_UnitCannon()
	WaitSeconds(9)
	if ScenarioInfo.ENEMAIR_CDR:IsDead() and not ScenarioInfo.ENEMLAND_CDR:IsDead() then
		-- Disable air attacks on north area, enable air attacks on east base
		ScenarioInfo.P1_ALLY01_Air_Assault_OpAI:Disable()
		ScenarioInfo.P1_ALLY01_Air_Assault_East_OpAI:Enable()
		P1_Gauge_AntiMissileTransport()
	end

	-- Fire unit cannon
	if ScenarioInfo.UnitCannon_East and not ScenarioInfo.UnitCannon_East:IsDead() then
 		local data = {
 			cannonUnit			= ScenarioInfo.UnitCannon_East,
 			strArmyName			= 'ARMY_ENEM02',
 			destChainName		= 'CANNON_LANDING_CHAIN',
 			shotsPerVolley		= 8,
 			delayBetweenVolleys	= 45.0,
 			ammoUnitType		= 'uul0103',
 			patrolChainName		= 'CANNON_AMMO_PATROL_CHAIN_FROM_LAND',
 		}
 		CannonUtils.StartCannon(data)

 		-- Create east unit cannon VO death trigger
 		ScenarioFramework.CreateUnitDeathTrigger( P1_UnitCannon_Destroyed, ScenarioInfo.UnitCannon_East)

		-- if the unit cannon has already been spotted play firing VO
 		if UnitCannonSpottedVO == true then
 			P1_UnitCannon_Attacks()
 		-- if the unit cannon has not already been spotted play alternate firing VO
 		elseif UnitCannonSpottedVO == false then
 			P1_UnitCannon_Fired()
 		end
 	end
end

function P3_ALLY01AssistFighters()
	LOG('----- P2: ALLY01 needs fighter support. Play VO')

	-- Tell player to build fighters to counter the gunship patrol defense that the UEF AIR commander maintains.
	ScenarioFramework.Dialogue(OpDialog.I04_ALLY01_ASSIST_FIGHTERS_010)
end

function P1_ENEM01_LandAttack01()
	LOG('----- P1: P1_ENEM01_LandAttack01')
	-- First land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack01, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack01, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function P1_ENEM01_LandAttack02()
	LOG('----- P1: P1_ENEM01_LandAttack02')
	-- Second land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack02, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack02, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function P1_ENEM01_LandAttack03()
	LOG('----- P1: P1_ENEM01_LandAttack03')
	-- Third land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack03, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack03, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function P1_ENEM01_LandAttack04()
	LOG('----- P1: P1_ENEM01_LandAttack04')
	-- Fourth land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack04, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack04, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function P1_ENEM01_LandAttack05()
	LOG('----- P1: P1_ENEM01_LandAttack05')
	-- Fifth land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack05, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack05, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function P1_ENEM01_LandAttack06()
	LOG('----- P1: P1_ENEM01_LandAttack06')
	-- Sixth land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack06, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack06, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function P1_ENEM01_LandAttack07()
	LOG('----- P1: P1_ENEM01_LandAttack07')
	-- Seventh land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack07, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack07, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function P1_ENEM01_LandAttack08()
	LOG('----- P1: P1_ENEM01_LandAttack08')
	-- Eighth land group sent toward the player
	IssueAggressiveMove( ScenarioInfo.LandAttack08, ScenarioUtils.MarkerToPosition( 'P1_PLAYER_Main_Base_Marker' ) )
	ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack08, 'ArmyBase_ENEM02_Central_Base_LandChain_01')
end

function AdjustMegalithWeapons()
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/22/09

	---NOTE: at this point - I do not consider this a temp function - we likely will need this sort of behavior for Ship - bfricks 9/30/09
	-- weapon damage adjustment to beef up gauge's megaliths to avoid building more of them. ~cdaroza
	local wpnROF = 4
	local wpnRNG = 90
	local wpnDMG = 1600
	local weapons = {'Laser01','Laser02','Laser03'}

	local megaliths = ArmyBrains[ARMY_ALLY01]:GetListOfUnits(categories.ucx0101, false)
	for k, unit in megaliths do
		for key, weapon in weapons do
			local wpn = unit:GetWeapon(weapon)
			if wpn then
				wpn:ChangeDamage(wpnDMG)
				wpn:ChangeRateOfFire(wpnROF)
				wpn:ChangeMaxRadius(wpnRNG)
			end
		end
	end
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end
---------------------------------------------------------------------
-- BASE AND OPAI SETUP:
---------------------------------------------------------------------
	-----## TABLE SETUP ## -----
function P1_Add_GunshipTable(platoon)
	table.insert(ScenarioInfo.P1_ENEM01_Gunship_DefenseTable, platoon)
end

function P1_Add_Air_AttackPlayerTable(platoon)
	table.insert(ScenarioInfo.P1_ENEM01_Air_Attack_OffenseTable, platoon)
end

function P1_AISetup_ENEM01_Main()
	LOG('----- P1: Set up UEF AIR ENEM01 Base')

	-----## BASE SETUP ## -----

	-- Initial base
	local levelTable_ENEM01_Main_Base = {
		P1_ENEM01_Main_Base_100 = 100,
		P1_ENEM01_Main_Base_90 = 90,
		P1_ENEM01_Main_Base_80 = 80,
	}

	ScenarioInfo.ArmyBase_ENEM01_Main_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Main_Base',
		 'P1_ENEM01_Main_Base_Marker', 70, levelTable_ENEM01_Main_Base)
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:StartNonZeroBase(3)
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddEngineer(ScenarioInfo.ENEMAIR_CDR)

	-- this will build the other 'half' of the base on game start for look and feel
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddBuildGroup('P1_ENEM01_Main_Add', 50)

	-- this will build the unit cannon post Intro NIS to avoid the reveal
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddBuildGroup('P1_ENEM01_Main_Unit_Cannon', 40)
end

function P1_OpAI_ENEM01()
	LOG('----- P1: Set up OpAIs for ENEM01')

	--# gunship air defense patrol around base
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirAttackUEF', 'P1_ENEM01_Gunship_Defense_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI_Data		= { PatrolChain = 'ArmyBase_ENEM01_Main_Base_Patrol_Air01',}
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:			EnableChildTypes( {'UEFGunships'} )
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:			SetAttackDelay(240)
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:			AddActivePlatoon( ScenarioInfo.Gunships01, true)
	ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI.			FormCallback:Add( P1_Add_GunshipTable )


	--# constant air attacks on player throughout the OP
	ScenarioInfo.P1_ENEM01_Air_AttackPlayer_01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:GenerateOpAIFromPlatoonTemplate(AirAttackPlayer, 'P1_ENEM01_Air_AttackPlayer_01_OpAI', {} )
	local P1_ENEM01_Air_AttackPlayer_01_OpAI_Data			= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ENEM01_Main_Base_Patrol_Air02',},}
	ScenarioInfo.P1_ENEM01_Air_AttackPlayer_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_Air_AttackPlayer_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Air_AttackPlayer_01_OpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_ENEM01_Air_AttackPlayer_01_OpAI:		SetChildCount(P1_ENEM01_Air_AttackPlayer_01_OpAI_CHILDCOUNT)
	ScenarioInfo.P1_ENEM01_Air_AttackPlayer_01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_Air_AttackPlayer_01_OpAI:		AddActivePlatoon( ScenarioInfo.Air_AttackPlayer_01, true)


	--# bomber attacks on gauges base
	ScenarioInfo.P1_ENEM01_Air_AttackGauge_01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:GenerateOpAIFromPlatoonTemplate(AirAttackGauge, 'P1_ENEM01_Air_AttackGauge_01_OpAI', {} )
	local P1_ENEM01_Air_AttackGauge_01_OpAI_Data			= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ENEM01_Main_Base_Patrol_Air03',},}
	ScenarioInfo.P1_ENEM01_Air_AttackGauge_01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_Air_AttackGauge_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Air_AttackGauge_01_OpAI:			SetChildCount(P1_ENEM01_Air_AttackGauge_01_OpAI_CHILDCOUNT)
	ScenarioInfo.P1_ENEM01_Air_AttackGauge_01_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_Air_AttackGauge_01_OpAI:			Disable()


	--# Surgical Response OpAI's if the player builds over-powerful units, or builds too many of certain units. Enabled at gauge response.
	-- Too many land units of some types.
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessLand_OpAI		=  ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponsePatrolLand', 'P1_ENEM01_Air_PlayerExcessLand_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessLand_OpAI_Data	= { AnnounceRoute = true, PatrolChains = { 'ArmyBase_ENEM01_Main_Base_Patrol_Air02', },}
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessLand_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_Air_PlayerExcessLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessLand_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessLand_OpAI:		Disable()


	-- Too many air units
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessAir_OpAI			=  ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponsePatrolAir', 'P1_ENEM01_Air_PlayerExcessAir_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessAir_OpAI_Data	= { AnnounceRoute = true, PatrolChains = { 'ArmyBase_ENEM01_Main_Base_Patrol_Air02', },}
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessAir_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_Air_PlayerExcessAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessAir_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessAir_OpAI:		Disable()


	-- Player builds powerful individual land units
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulLand_OpAI		=  ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponseTargetLand', 'P1_ENEM01_Air_PlayerPowerfulLand_OpAI', {} )
	local P1_ENEM01_Air_PlayerPowerfulLand_OpAI_Data		= {
    											    			Announce = true,
    											    			PatrolChain = 'ArmyBase_ENEM01_Main_Base_Patrol_Air02',
    											    			CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Main_Base_Marker' ),
    											    			CategoryList = {
    											    			    (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    											    			    categories.uub0105,	-- artillery
    											    			    categories.ucb0105,	-- artillery
    											    			    categories.NUKE,
    											   		 		},
    														}
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulLand_OpAI:		SetPlatoonThread( 'CategoryHunter', P1_ENEM01_Air_PlayerPowerfulLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulLand_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulLand_OpAI:		Disable()


	-- Player builds air experimentals
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulAir_OpAI		=  ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponseTargetAir', 'P1_ENEM01_Air_PlayerPowerfulAir_OpAI', {} )
	local P1_ENEM01_Air_PlayerPowerfulAir_OpAI_Data			= {
    															Announce = true,
    															PatrolChain = 'ArmyBase_ENEM01_Main_Base_Patrol_Air02',
    															CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Main_Base_Marker' ),
    															CategoryList = {
    															    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    															},
    														}
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulAir_OpAI:		SetPlatoonThread( 'CategoryHunter', P1_ENEM01_Air_PlayerPowerfulAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulAir_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulAir_OpAI:		Disable()
end

function P1_AISetup_ENEM02_Main()
	LOG('----- P1: Set up UEF LAND enemy Base')

	-----## BASE SETUP ## -----

	-- Initial base
	local levelTable_ENEM02_Main_Base = {
		P1_ENEM02_Main_Base_100 = 100,
		P1_ENEM02_Main_Base_90 = 90,
		P1_ENEM02_Main_Base_80 = 80,
	}

	ScenarioInfo.ArmyBase_ENEM02_Main_Base = ArmyBrains[ARMY_ENEM02].CampaignAISystem:AddBaseManager('ArmyBase_ENEM02_Main_Base',
		 'P1_ENEM02_Main_Base_Marker', 70, levelTable_ENEM02_Main_Base)
	ScenarioInfo.ArmyBase_ENEM02_Main_Base:StartNonZeroBase(4)
	ScenarioInfo.ArmyBase_ENEM02_Main_Base:AddEngineer(ScenarioInfo.ENEMLAND_CDR)

	-- this will build the other 'half' of the base on game start for look and feel
	ScenarioInfo.ArmyBase_ENEM02_Main_Base:AddBuildGroup('P1_ENEM02_Main_Add', 50)

	-- this will build the unit cannon post Intro NIS to avoid the reveal
	ScenarioInfo.ArmyBase_ENEM02_Main_Base:AddBuildGroup('P1_ENEM02_Main_Unit_Cannon', 40)

	-- expansion base that will be built in the central part of the map
	ScenarioInfo.ArmyBase_ENEM02_Main_Base:AddExpansionBase('ArmyBase_ENEM02_Central_Base', 4)


	-----## EXPANSION BASE SETUP ## -----

	-- Expansion base
	local expansionTable_ENEM02_Central_Base = {
		P1_ENEM02_Central_Base_100 = 100,
		P1_ENEM02_Central_Base_90 = 90,
		P1_ENEM02_Central_Base_80 = 80,
		P1_ENEM02_Central_Base_70 = 70,
		P1_ENEM02_Central_Base_60 = 60,
	}

	ScenarioInfo.ArmyBase_ENEM02_Central_Base = ArmyBrains[ARMY_ENEM02].CampaignAISystem:AddBaseManager('ArmyBase_ENEM02_Central_Base',
		 'P1_ENEM02_Central_Base_Marker', 50, expansionTable_ENEM02_Central_Base)
	ScenarioInfo.ArmyBase_ENEM02_Central_Base:StartEmptyBase(6)
	ScenarioInfo.ArmyBase_ENEM02_Central_Base:SetBaseInfiniteRebuild()

end

function P1_AISetup_ALLY01_Main()
	LOG('----- P1: Set up Cybran ALLY01 Base')

	-----## BASE SETUP ## -----

	-- Initial base
	local levelTable_ALLY01_Main_Base = {
		P1_ALLY01_Main_Base_100 = 100,
		P1_ALLY01_Main_Base_90 = 90,
		P1_ALLY01_Main_Base_80 = 80,
		P1_ALLY01_Main_Base_70 = 70,
	}

	ScenarioInfo.ArmyBase_ALLY01_Main_Base = ArmyBrains[ARMY_ALLY01].CampaignAISystem:AddBaseManager('ArmyBase_ALLY01_Main_Base',
		 'P1_ALLY01_Main_Base_Marker', 50, levelTable_ALLY01_Main_Base)
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:StartEmptyBase(5)

	--in the case of our ally, we want infinite rebuild on.
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:SetBaseInfiniteRebuild()

	-- Add Gauge's CDR and starting engineers to the base engineer list
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddEngineer(ScenarioInfo.ALLYCYB_CDR)
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddEngineer(ScenarioInfo.ALLYCYB_ENG01)
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddEngineer(ScenarioInfo.ALLYCYB_ENG02)
end


function P2_OpAI_ALLY01_Main()
	LOG('----- P1: Setup Gauge\'s OpAI\'s')

	-- Initial Megalith attack on central base
	ScenarioInfo.P1_ALLY01_Megalith_Assault_OpAI			= ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddOpAI('SingleMegalithAttack', 'P1_ALLY01_Megalith_Assault_OpAI', {} )
	local P1_ALLY01_Megalith_Assault_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ALLY01_Main_Base_MegalithChain_01',},}
	ScenarioInfo.P1_ALLY01_Megalith_Assault_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_Megalith_Assault_OpAI_Data )
	ScenarioInfo.P1_ALLY01_Megalith_Assault_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ALLY01_Megalith_Assault_OpAI:			SetChildCount(2)
	ScenarioInfo.P1_ALLY01_Megalith_Assault_OpAI:  			Disable()

	-- Enable the primary meaglith attack if there are any enemy structures present in the central area
	local centralEnemyStructures = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE, ScenarioUtils.AreaToRect('P2_AREA_Megalith_01'), ArmyBrains[ARMY_ENEM02])

	if table.getn(centralEnemyStructures) > 0 then
		ScenarioInfo.P1_ALLY01_Megalith_Assault_OpAI:Enable()
	end

	-- Single Megalith OpAI sent toward north enemy base after the gunship response destroys the inital wave of megaliths
	ScenarioInfo.P1_ALLY01_Megalith_North_OpAI				= ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddOpAI('SingleMegalithAttack', 'P1_ALLY01_Megalith_North_OpAI', {} )
	local P1_ALLY01_Megalith_North_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ALLY01_Main_Base_AttackChain01',},}
	ScenarioInfo.P1_ALLY01_Megalith_North_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_Megalith_North_OpAI_Data )
	ScenarioInfo.P1_ALLY01_Megalith_North_OpAI:				SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ALLY01_Megalith_North_OpAI:				SetChildCount(1)
	ScenarioInfo.P1_ALLY01_Megalith_North_OpAI:				Disable()

	ScenarioInfo.P1_ALLY01_LandAttack_North_OpAI			= ScenarioInfo.ArmyBase_ALLY01_Main_Base:GenerateOpAIFromPlatoonTemplate(LandAttack, 'P1_ALLY01_LandAttack_North_OpAI', {} )
	local P1_ALLY01_LandAttack_North_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ALLY01_Main_Base_AttackChain01',},}
	ScenarioInfo.P1_ALLY01_LandAttack_North_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_LandAttack_North_OpAI_Data )
	ScenarioInfo.P1_ALLY01_LandAttack_North_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ALLY01_LandAttack_North_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ALLY01_LandAttack_North_OpAI:			Disable()

	-- Single Megalith OpAI sent toward east enemy base after the gunship response destroys the inital wave of megaliths and the north CDR is dead
	ScenarioInfo.P1_ALLY01_Megalith_East_OpAI				= ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddOpAI('SingleMegalithAttack', 'P1_ALLY01_Megalith_East_OpAI', {} )
	local P1_ALLY01_Megalith_East_OpAI_Data					= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ALLY01_Main_Base_AttackChain02',},}
	ScenarioInfo.P1_ALLY01_Megalith_East_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_Megalith_East_OpAI_Data )
	ScenarioInfo.P1_ALLY01_Megalith_East_OpAI:				SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ALLY01_Megalith_East_OpAI:				SetChildCount(1)
	ScenarioInfo.P1_ALLY01_Megalith_East_OpAI:				Disable()

	ScenarioInfo.P1_ALLY01_LandAttack_East_OpAI				= ScenarioInfo.ArmyBase_ALLY01_Main_Base:GenerateOpAIFromPlatoonTemplate(LandAttack, 'P1_ALLY01_LandAttack_East_OpAI', {} )
	local P1_ALLY01_LandAttack_East_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ALLY01_Main_Base_AttackChain02',},}
	ScenarioInfo.P1_ALLY01_LandAttack_East_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_LandAttack_East_OpAI_Data )
	ScenarioInfo.P1_ALLY01_LandAttack_East_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ALLY01_LandAttack_East_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ALLY01_LandAttack_East_OpAI:			Disable()

	LOG('----- P2: Gauge builds air platoons and attacks the north UEF base')

	ScenarioInfo.P1_ALLY01_Air_Assault_OpAI					= ScenarioInfo.ArmyBase_ALLY01_Main_Base:GenerateOpAIFromPlatoonTemplate(CybranAirAttack, 'P1_ALLY01_Air_Assault_OpAI', {} )
	local P1_ALLY01_Air_Assault_OpAI_Data					= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ALLY01_Main_Base_AttackChain01',},}
	ScenarioInfo.P1_ALLY01_Air_Assault_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_Air_Assault_OpAI_Data )
	ScenarioInfo.P1_ALLY01_Air_Assault_OpAI:				SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ALLY01_Air_Assault_OpAI:				SetChildCount(P1_ALLY01_Air_Assault_OpAI_CHILDCOUNT)

	-- Redirect air attacks if north CDR dies
	ScenarioInfo.P1_ALLY01_Air_Assault_East_OpAI			= ScenarioInfo.ArmyBase_ALLY01_Main_Base:GenerateOpAIFromPlatoonTemplate(CybranAirAttack, 'P1_ALLY01_Air_Assault_East_OpAI', {} )
	local P1_ALLY01_Air_Assault_East_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ALLY01_Main_Base_AttackChain02',},}
	ScenarioInfo.P1_ALLY01_Air_Assault_East_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ALLY01_Air_Assault_East_OpAI_Data )
	ScenarioInfo.P1_ALLY01_Air_Assault_East_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ALLY01_Air_Assault_East_OpAI:			SetChildCount(P1_ALLY01_Air_Assault_OpAI_CHILDCOUNT)
	ScenarioInfo.P1_ALLY01_Air_Assault_East_OpAI:			SetAttackDelay(30)
	ScenarioInfo.P1_ALLY01_Air_Assault_East_OpAI:			Disable()

	-- Area trigger that will send the gunship patrol to attack the megaliths
	ScenarioFramework.CreateAreaTrigger(P2_GunshipMegalithResponse, 'P2_AREA_Megalith_01',
			categories.STRUCTURE, true, true, ArmyBrains[ARMY_ENEM02], nil, false)

	-- Army stat trigger that initiates a MML building and attacking OpAI when X megaliths are killed
	ScenarioFramework.CreateArmyStatTrigger (P2_OpAI_ENEM02_MML, ArmyBrains[ARMY_ALLY01], 'P2_OpAI_ENEM02_MML',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ucx0101}})
	----------------------------------------------
	-- VO triggers
	----------------------------------------------

	-- VO trigger telling the player to secure the central map area after the Megaliths have been eliminated.
	-- Will also tell the player that he should attack the UEF Land Player while his forces are crippled.
	ScenarioFramework.CreateArmyStatTrigger (P2_ALLY01MegalithKilled, ArmyBrains[ARMY_ALLY01], 'P2_ALLY01MegalithKilled',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ucx0101}})

	-- VO trigger telling the player to build anti-missile units after it detects ENEM02 building Mobile Missile Launchers
	ScenarioFramework.CreateArmyStatTrigger (P2_Enem02BuildsMML, ArmyBrains[ARMY_ENEM02], 'P2_Enem02BuildsMML',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.uul0104}})

end

function P2_OpAI_ENEM02_MML()
	LOG('----- P2: Set up OpAIs for ENEM02 MML to attack player')

	--# platoon for MML that begin building when megaliths are built
	ScenarioInfo.P2_ENEM02_MML_Attack_01_OpAI			= ScenarioInfo.ArmyBase_ENEM02_Main_Base:GenerateOpAIFromPlatoonTemplate(MMLAttackPlayer, 'P2_ENEM02_MML_Attack_01_OpAI', {} )
	local P2_ENEM02_MML_Attack_01_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ArmyBase_ENEM02_Main_Base_MML_01',},}
	ScenarioInfo.P2_ENEM02_MML_Attack_01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P2_ENEM02_MML_Attack_01_OpAI_Data )
	ScenarioInfo.P2_ENEM02_MML_Attack_01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P2_ENEM02_MML_Attack_01_OpAI:			SetChildCount(P2_ENEM02_MML_Attack_01_OpAI_CHILDCOUNT)
end

function P2_GunshipMegalithResponse()
	LOG('----- P2: Enemy Gunship response to Megaliths')

	local gaugeMegaliths = ArmyBrains[ARMY_ALLY01]:GetListOfUnits(categories.ucx0101, false)

	-- IF megaliths exist then respond
	if table.getn(gaugeMegaliths) > 0 then
		-- play Vo dialogue warning the player of incoming gunships from the north
		ScenarioFramework.Dialogue(OpDialog.I04_PLAYER_WARNING_GUNSHIPS_010)

		-- this takes all the units in the gunship platoon table and looks for any megalith in the megaliths list, clears the gunship patrol command and attacks any megaliths
		local megaliths = ArmyBrains[ARMY_ALLY01]:GetListOfUnits(categories.ucx0101, false)
		for k , platoon in ScenarioInfo.P1_ENEM01_Gunship_DefenseTable do
			-- this will check if the gunship platoon even exists and clear its commands if it does
			if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
				IssueClearCommands(platoon:GetPlatoonUnits())
				-- for every megalith in the megaliths list that is valid it will isssue an attack
				for k, megalith in megaliths do
					if (megalith and not megalith:IsDead()) then
						--tell platoon to attack megaliths
						platoon:AttackTarget( megalith )
					end
				end
				-- this will order the remaining gunship platoon to return to their original base patrol
				ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:			AddActivePlatoon( ScenarioInfo.Gunships01, true)
				ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI_Data		= { PatrolChain = 'ArmyBase_ENEM01_Main_Base_Patrol_Air01',}
				ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.P1_ENEM01_Gunship_Defense_01_OpAI_Data )
			end
		end

		-- this will disable the megalith OpAI becuase everything in the middle	is destroyed
		ScenarioInfo.P1_ALLY01_Megalith_Assault_OpAI:Disable()
	end

	-- enable the Surgical response opais now, for the air base.
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessAir_OpAI:Enable()
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulAir_OpAI:Enable()
	ScenarioInfo.P1_ENEM01_Air_PlayerExcessLand_OpAI:Enable()
	ScenarioInfo.P1_ENEM01_Air_PlayerPowerfulLand_OpAI:Enable()

	-- Disable this base manager, now that the base is destroyed.
	ScenarioInfo.ArmyBase_ENEM02_Central_Base:BaseActive(false)

	P2_AssistAlly()
end

function P2_AssistAlly()
	-- VO trigger telling the player to build fighters to support ALLY01 to the north and deal with the gunship defense
	ScenarioFramework.CreateArmyStatTrigger(
		P3_ALLY01AssistFighters,
		ArmyBrains[ARMY_ALLY01],
		'P3_ALLY01AssistFighters',
		{
			{
				StatType = 'Units_Killed',
				CompareType = 'GreaterThanOrEqual',
				Value = 12,
				Category = categories.LAND * categories.MOBILE
			}
		}
	)
end

function P1_Gauge_ArrivalVO()
	ScenarioFramework.Dialogue(OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_010, P1_Gauge_ArrivalThread)
end

function P1_Gauge_ArrivalThread()
	ForkThread(
		function()
			-- Create Gauge and his transport
			ScenarioInfo.NIS_AllyCDR = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Commander_Group')
			ScenarioInfo.NIS_AllyGroup_01 = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Group_01')
			ScenarioInfo.NIS_AllyGroup_02 = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Group_02')
			ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.NIS_AllyGroup_02, 5)
			ScenarioInfo.NIS_AllyGroup_03 = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Group_03')
			ScenarioInfo.NIS_AllyGroup_04 = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Group_04')
			ScenarioInfo.NIS_AllyGroup_05 = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Group_05')
			ScenarioInfo.NIS_AllyGroup_06 = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Group_06')
			ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.NIS_AllyGroup_06, 5)

			-- get all of guages land units and increase their veterancy
			local gaugeLandUnits = ArmyBrains[ARMY_ALLY01]:GetListOfUnits(categories.ucl0103,false)
			for k, unit in gaugeLandUnits do
				ScenarioFramework.SetUnitVeterancyLevel(unit, 4)
			end

			ScenarioInfo.NIS_INTRONIS_Transport_01 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'INTRONIS_Transport_01')
			ScenarioInfo.NIS_INTRONIS_Transport_02 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'INTRONIS_Transport_02')
			ScenarioInfo.NIS_INTRONIS_Transport_03 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'INTRONIS_Transport_03')
			ScenarioInfo.NIS_INTRONIS_Transport_04 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'INTRONIS_Transport_04')
			ScenarioInfo.NIS_INTRONIS_Transport_05 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'INTRONIS_Transport_05')
			ScenarioInfo.NIS_INTRONIS_Transport_06 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'INTRONIS_Transport_06')
			ScenarioInfo.NIS_GaugeTransport = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'GAUGE_Transport_01')

			-- Set up Commander here (this is the earliest we can get a handle to him)
			ScenarioInfo.ALLYCYB_CDR = ScenarioInfo.UnitNames[ARMY_ALLY01]['ALLYCYB_CDR']
			ScenarioInfo.ALLYCYB_CDR:SetCustomName(ScenarioGameNames.CDR_Gauge)
			ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ALLYCYB_CDR, 3)

			-- Set up engineers here (this is the earliest we can get a handle to them)
			ScenarioInfo.ALLYCYB_ENG01 = ScenarioInfo.UnitNames[ARMY_ALLY01]['ALLYCYB_ENG01']
			ScenarioInfo.ALLYCYB_ENG02 = ScenarioInfo.UnitNames[ARMY_ALLY01]['ALLYCYB_ENG02']

			---NOTE: its decided, Gauge MUST live - we will not try and handle his death - largely because it would require an extra protect objective
			---			that is hardly worth our effort - and gives away the importance of the character - bfricks 10/18/09
			ProtectUnit(ScenarioInfo.ALLYCYB_CDR)

			-- VO trigger west of the central area telling the player that the west is secured
			ScenarioFramework.CreateAreaTrigger(P1_AREA_WEST_VO_TRIGGER, 'AREA_WEST_VO_TRIGGER',
			categories.LAND * categories.ILLUMINATE * categories.MOBILE, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

			-- Create gauge land unit death triggers
			ScenarioFramework.CreateGroupDeathTrigger( AllyGroup_03_Attack, ScenarioInfo.NIS_AllyGroup_01 )
			ScenarioFramework.CreateGroupDeathTrigger( AllyGroup_04_Attack, ScenarioInfo.NIS_AllyGroup_03 )

			-- Issue group patrols for gauge's initial land groups
			ScenarioFramework.GroupPatrolChain (ScenarioInfo.NIS_AllyGroup_01, 'ArmyBase_ALLY01_Main_Base_AttackChain02')
			ScenarioFramework.GroupPatrolChain (ScenarioInfo.NIS_AllyGroup_05, 'ArmyBase_ALLY01_Main_Base_AttackChain02')

			-- Create responsive enemy patrol chain from central land group
			ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack09, 'ArmyBase_ENEM01_Main_Base_Patrol_Air03')
			ScenarioFramework.GroupPatrolChain (ScenarioInfo.LandAttack10, 'ArmyBase_ENEM01_Main_Base_Patrol_Air03')

			OpNIS.NIS_ALLY_GAUGE_ARRIVAL()

			-- trigger to assign research secondary objective
			ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 20)

			ScenarioFramework.GroupPatrolChain( ScenarioInfo.NIS_AllyGroup_02, 'ALLY_Land_Attack01' )
			ScenarioFramework.GroupPatrolChain( ScenarioInfo.NIS_AllyGroup_06, 'ALLY_Land_Attack01' )
		end
	)
end

function P1_Gauge_AntiAirTransport()
	-- Transport sequence for north base assistance

	-- Create the transport, get a handle, flag it unkillable
	ScenarioInfo.AntiAir_Transport_01 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'AntiAir_Transport_01')
	ScenarioInfo.AntiAir_Transport_01 = ScenarioInfo.UnitNames[ARMY_ALLY01]['AntiAir_Transport_01']
	ScenarioInfo.AntiAir_Transport_01:SetCanBeKilled(false)

	local data = {
		armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
		units					= 'AntiAir_AllyGroup_01',					-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.AntiAir_Transport_01,		-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= 'ALLY_Transport_Landing_01',				-- destination for the transport drop-off
		returnDest				= 'ALLY_Transport_Return_Marker',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,										-- optional function to call when the transport finishes unloading
		onUnloadCallback		= AntiAir_Formup,							-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data)
end

function AntiAir_Formup(platoon)
	-- Gauge VO
	ScenarioFramework.Dialogue(OpDialog.I04_ALLY_GAUGE_TRANSPORT_010)
	-- Formation move to a marker
	IssueAggressiveMove( platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'ALLY_Transport_Formup_01' ))
	-- Flag the transport killable
	ScenarioInfo.AntiAir_Transport_01:SetCanBeKilled(true)
end

function P1_Gauge_AntiMissileTransport()
	-- Transport sequence for east base assistance

	-- Create the transport, get a handle, flag it unkillable
	ScenarioInfo.AntiLand_Transport_01 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'AntiLand_Transport_01')
	ScenarioInfo.AntiLand_Transport_01 = ScenarioInfo.UnitNames[ARMY_ALLY01]['AntiLand_Transport_01']
	ScenarioInfo.AntiLand_Transport_01:SetCanBeKilled(false)

	local data = {
		armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
		units					= 'AntiAir_AllyGroup_01',					-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.AntiLand_Transport_01,		-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= 'ALLY_Transport_Landing_02',				-- destination for the transport drop-off
		returnDest				= 'ALLY_Transport_Return_Marker',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,										-- optional function to call when the transport finishes unloading
		onUnloadCallback		= AntiLand_Formup,							-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data)
end

function AntiLand_Formup(platoon)
	-- Gauge VO
	ScenarioFramework.Dialogue(OpDialog.I04_ALLY_GAUGE_TRANSPORT_010)
	-- Formation move to a marker
	IssueAggressiveMove( platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'ALLY_Transport_Formup_02' ))
	-- Flag the transport killable
	ScenarioInfo.AntiLand_Transport_01:SetCanBeKilled(true)
end

---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------
function ENEMAIR_CDR_DeathDamage(CDRUnit)
	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ALLY01],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_ENEM02],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 50.0, true, 5000, 90001, brainList)

		-- Disable the commander's base, now that he is dead.
		ScenarioInfo.ArmyBase_ENEM01_Main_Base:BaseActive(false)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

function ENEMLAND_CDR_DeathDamage(CDRUnit)
	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ALLY01],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_ENEM02],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 50.0, true, 5000, 90001, brainList)

		-- Disable the commander's base, now that he is dead.
		ScenarioInfo.ArmyBase_ENEM02_Main_Base:BaseActive(false)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function LaunchENEM_CDRDeathNIS(unit)
	LOG('----- LaunchENEM_CDRDeathNIS: Launch CDr death NIS')
	nNumCDRsDestroyed = nNumCDRsDestroyed + 1
	if nNumCDRsDestroyed == 1 then
		ForkThread(
			function()
				OpNIS.NIS_FIRST_CDR_DEATH(unit, nNumCDRsDestroyed)
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I04_ZZ_EXTRA_KILL_CDR1, ARMY_PLAYER, 3.0)
			end
		)
	end
	if nNumCDRsDestroyed == 2 then
		-- all enemies are destroyed, so disable ally base manager, for neatness.
		if ScenarioInfo.ArmyBase_ALLY01_Main_Base then
			ScenarioInfo.ArmyBase_ALLY01_Main_Base:BaseActive(false)
		end
		ForkThread(OpNIS.NIS_SECOND_CDR_DEATH, unit, nNumCDRsDestroyed)
	end
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
--	P1_Gauge_ArrivalVO()

 	ScenarioInfo.UnitCannon_East = ScenarioUtils.CreateArmyUnit('ARMY_ENEM02', 'P1_ENEM02_UC01')
 	local data = {
 		cannonUnit			= ScenarioInfo.UnitCannon_East,
 		strArmyName			= 'ARMY_ENEM02',
 		destChainName		= 'CANNON_LANDING_CHAIN',
 		shotsPerVolley		= 10,
 		delayBetweenVolleys	= 20.0,
 		ammoUnitType		= 'uul0103',
 		patrolChainName		= 'CANNON_AMMO_PATROL_CHAIN',
 	}
 	CannonUtils.StartCannon(data)
end

function OnShiftF4()
	P1_Gauge_AntiAirTransport()
end

function OnShiftF5()
	P1_Gauge_AntiMissileTransport()
end
