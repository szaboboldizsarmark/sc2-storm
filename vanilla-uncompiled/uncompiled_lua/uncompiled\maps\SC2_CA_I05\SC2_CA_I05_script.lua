---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_I05/SC2_CA_I05_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_I05/SC2_CA_I05_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_I05/SC2_CA_I05_OpNIS.lua')
local ScenarioUtils			= import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework		= import('/lua/sim/ScenarioFramework.lua')
local ScenarioGameSetup		= import('/lua/sim/ScenarioFramework/ScenarioGameSetup.lua')
local ScenarioGameTuning	= import('/lua/sim/ScenarioFramework/ScenarioGameTuning.lua')
local ScenarioGameEvents	= import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua')
local ScenarioGameCleanup	= import('/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua')
local ScenarioGameNames		= import('/lua/sim/ScenarioFramework/ScenarioGameNames.lua')
local ScenarioPlatoonAI 	= import('/lua/ai/ScenarioPlatoonAI.lua')
local SimObjectives			= import('/lua/sim/SimObjectives.lua')
local SimPingGroups			= import('/lua/sim/SimPingGroup.lua')
local RandomFloat			= import('/lua/system/utilities.lua').GetRandomFloat
local RandomInt				= import('/lua/system/utilities.lua').GetRandomInt
local Weather				= import('/lua/sim/weather.lua')

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
ScenarioInfo.ARMY_ALLY01 = 3
ScenarioInfo.ARMY_CIVL01 = 4

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.P1_EnemyHasPulledBack = false
ScenarioInfo.P1_EnemyAssaultBlockPlatoons = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01
local ARMY_CIVL01 = ScenarioInfo.ARMY_CIVL01

local EnemyAirAttackCounter = 0
local GaugeAttackPlatoonCount = 0

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local ObjectiveTargetHealth				= 300000	-- Max health value of the primary objective building

local PlayerStartIntelRadius			= 9001		-- radius of player's starting radar intel that should cover the entire map
local PlayerAtPlatform_Units 			= 28		-- num land units required on platform to trigger enemy retreat
local PlayerAtPlatform_CheckSeconds		= 20		-- interval for unit count check --WARNING: go too high, and the player could leave the area, thus failing the check.
local PlayerAntiAirUnitCount_A			= 10		-- Player unit threshold at which enemy air attacks at player will become stronger.
local PlayerAntiAirUnitCount_B			= 20		-- Player unit threshold at which enemy air attacks at player will become stronger.
local PlayerTotalUnitCount				= 45		-- Player unit threshold at which enemy air attacks at player will become stronger.

local GaugeBeginsAttacks_FailsafeDelay	= 90		-- Delay in seconds from start of Op at which Gauge will begin his air attacks.
local GaugeInitAirAttackSize			= 9			-- Multiple of 3, number of units per attack from Gauge, while he attacks nearest platform -to be replaced when enemy goes defensive. Note: Must be same or larger than AirTriggerAmount, to trigger the distract response from enemy!

local EnemyDefenseAirPlatoon_Size		= 10		-- attempted size of enemy defensive air platoon, when enemy is forced to retreat
local EnemyPopcornAttackSize_Player		= 3			-- Multiple of 3, number of units for popcorn air attacks vs player
local EnemyPopcornAttackSize_Gauge		= 3			-- Multiple of 3, number of units for popcorn air attacks vs Gauge
local AirTriggerAmount					= 8 		-- Number of player or ally units that will trigger the 'distract' air response from enemy.

-- unique custom platoon: CYBRAN fighter/bombers
local AllyAirAttack01 = {
	'Cybran_AirAttack01_Platoon',
	{
		{ 'uca0104', GaugeInitAirAttackSize },
	},
}

-- unique custom platoon: ILLUMINATE fighter/bombers
local AirAttackPlayer = {
	'Illuminate_AirAttack01_Platoon',
	{
		{ 'uia0104', EnemyPopcornAttackSize_Player },
	},
}

-- unique custom platoon: ILLUMINATE fighter/bombers
local AirAttackGauge = {
	'Illuminate_AirAttack02_Platoon',
	{
		{ 'uia0104', EnemyPopcornAttackSize_Gauge },
	},
}

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------

-- P1: Ally air attack, ENEM01:		Air attacks sent from gauge towards the enemy. These are
--									custom air platoons (AllyAirAttack01) consisting of
--									fighter/bombers sent in multiples of 3.
--									FUNCTIONS: P1_Main(), P1_Ally_AISetup()
--									TUNE: GaugeBeginsAttacks_FailsafeDelay	-- failsafe delay timer
--										  GaugeInitAirAttackSize			-- platoon size
--										  AllyAirAttack01					-- platoon units
--
--
-- P1: Plaform unit check, player:	A player land unit check on the platform that will send enemy
--									units towards that particular span to help and retreat back to
--									thier patrols when the threat is gone.
--									FUNCTION: P1_VerifyPlayerAtCampThread(area)
--									TUNE: PlayerAtPlatform_ ...
--
--
-- P1: Air attacks, player:			Air attacks from the enemy sent toward the player that increase
--									according the amount of player anti-air units as well as total
--									player units. An army stat trigger calls
--									'P1_StrengthenEnemyAttacks' which is a counter which can enable
--									an OpAI and increase the child count of the air attacks.
--									FUNCTION: P1_Main()
--									TUNE: PlayerAntiAirUnitCount_ ...
--										  PlayerTotalUnitCount
--
--
-- P1: Air platoon size, defense:	Size of the enemy air platoon which maintains the base defense
--									patrol.
--									FUNCTION: P1_EnemyPullsBack()
--									TUNE: EnemyDefenseAirPlatoon_Size
--
-- P1: Enemy air platoon, units:	Custom enemy air platoons sent at gauge and the player from the
--									east and west bases. Fighter/bomber composition.
--									FUNCTION: P1_ENEM01_AISetup()
--									TUNE: AirAttackPlayer
--										  AirAttackGauge

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.I05_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.I05_ARMY_ENEM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ALLY01,	ScenarioGameTuning.I05_ARMY_ALLY01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CIVL01,	ScenarioGameTuning.color_CIV_I05)

	LOG('CAMPAIGN OPERATION FLOW:::: OnPopulate: Create Weather')
	local WeatherDefinition = {
		MapStyle = "Tundra",
		WeatherTypes = {
			{
				Type = "WhitePatchyClouds",
				Chance = 1.0,
			},
		},
		Direction = {0,0,0},
	}
	Weather.CreateWeather(WeatherDefinition)
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

	-----# Set up Gauge and his units #-----

	-- Set up Gauge, flag him as protected (keeps him safe from enemy, and from the player)
	ScenarioInfo.ALLY01_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_CDR')
	ScenarioInfo.ALLY01_CDR:SetCustomName(ScenarioGameNames.CDR_Gauge)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ALLY01_CDR, 3)

	---NOTE: its decided, Gauge MUST live - we will not try and handle his death - largely because it would require an extra protect objective
	---			that is hardly worth our effort - and gives away the importance of the character - bfricks 10/18/09
	ProtectUnit(ScenarioInfo.ALLY01_CDR)

	-- create gauges backbase area, and flag as untouchable (both so the enemy cant damage or attack it,
	-- and also so the player can't mess around with the units either).
	local group = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_BackBase')
	ProtectGroup(group)

	-- create the Nukes, protect them
	ScenarioInfo.P1_ALLY01_Nuke_01 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'P1_ALLY01_Nuke_01')
	ScenarioInfo.P1_ALLY01_Nuke_02 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'P1_ALLY01_Nuke_02')
	ScenarioInfo.P1_ALLY01_Nuke_03 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'P1_ALLY01_Nuke_03')
	ProtectUnit(ScenarioInfo.P1_ALLY01_Nuke_02)
	ProtectUnit(ScenarioInfo.P1_ALLY01_Nuke_01)
	ProtectUnit(ScenarioInfo.P1_ALLY01_Nuke_03)

	---NOTE: in this case we do NOT want to use SetAttackerEnabled(false) - because we just want the TML disabled - not the nukes - bfricks 9/30/09
	ScenarioInfo.P1_ALLY01_Nuke_01:SetWeaponEnabledByLabel( 'TacticalMissile01', false )
	ScenarioInfo.P1_ALLY01_Nuke_02:SetWeaponEnabledByLabel( 'TacticalMissile01', false )
	ScenarioInfo.P1_ALLY01_Nuke_03:SetWeaponEnabledByLabel( 'TacticalMissile01', false )

	-- Gauge's transports, that are on the map just for show and continuity.
	ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_InitTransports')

--	-- Gauge's land group transport and attached units
--	ScenarioInfo.NISTransport_01 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'P1_ALLY01_NISTransport_01')
--	ScenarioInfo.P1_ALLY01_NISTransport_Units = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_NISTransport_Units')

	-- Gauge's starting air platoon. We will send this at the enemy soon after the start of the Op, to demonstrate
	-- the 'distraction' mechanism. So, we want this platoon to stick around: flag it as protected, and give it
	-- a *move* command, instead of a patrol, so it doesnt wander off. When the time comes for it to attack
	-- we will unprotect it.
	ScenarioInfo.P1_ALLY01_InitalAttack_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_InitialAir_Attack_01', 'AttackFormation')
	ScenarioFramework.PlatoonMoveChain(ScenarioInfo.P1_ALLY01_InitalAttack_01, 'P1_ALLY01_MainBase_AirDef_Chain_01')
	ProtectGroup(ScenarioInfo.P1_ALLY01_InitalAttack_01:GetPlatoonUnits())

	-- Start gauge's base. Always keep this call at the end of this Gauge-related section of the script, as P1_Ally_AISetup
	-- will deal with units created above.
	P1_Ally_AISetup()

	-----# Enemy Setup #-----

	-- Set up the Mass Camp near the player start area
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_MassCamp_Structures')
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_MassCamp_Engineers', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_MassCamp_Engineer_Chain')
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_MassCamp_MobileDef', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_MassCamp_LandDef_Chain')

	-- Set up the Teleporter and its related units: teleporter should be only capturable. Health is lowered, with
	-- engineers repairing it.
	ScenarioInfo.P1_ENEM01_Teleporter = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_ENEM01_Teleporter')
	ScenarioInfo.P1_ENEM01_Teleporter:SetCustomName(ScenarioGameNames.UNIT_I05_SpaceTemple)
	-- Flag as unkillable
	ScenarioInfo.P1_ENEM01_Teleporter:SetCanBeKilled(false)

	-- Objective structure
	CreateObjectiveTarget()

	-- Camp structures
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_CampStructures_01')
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_CampStructures_02')
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_CampStructures_03')
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_CampStructures_04')

	-- Camp initial defense patrols (handles passed to OpAIs)
	ScenarioInfo.P1_ENEM01_Camp01_LandDef_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampGarrison_Land_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_Camp02_LandDef_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampGarrison_Land_02', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_Camp03_LandDef_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampGarrison_Land_03', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_Camp04_LandDef_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampGarrison_Land_04', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Camp01_LandDef_01, 'P1_ENEM01_Camp01_LandPatrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Camp02_LandDef_01, 'P1_ENEM01_Camp02_LandPatrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Camp03_LandDef_01, 'P1_ENEM01_Camp03_LandPatrol_01')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Camp04_LandDef_01, 'P1_ENEM01_Camp04_LandPatrol_01')

	-- Starting roving patrols for each camp area (camp 3 gets extra, as gauge focuses on this group)
	ScenarioInfo.P1_ENEM01_Camp01_Rover = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampRovers_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_Camp02_Rover = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampRovers_02', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_Camp03a_Rover = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampRovers_03a', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_Camp03b_Rover = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampRovers_03b', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_Camp04_Rover = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_CampRovers_04', 'AttackFormation')
	ForkThread(RandomPatrolThread,ScenarioInfo.P1_ENEM01_Camp01_Rover, 'P1_RoverPatrol_Camp01')
	ForkThread(RandomPatrolThread,ScenarioInfo.P1_ENEM01_Camp02_Rover, 'P1_RoverPatrol_Camp02')
	ForkThread(RandomPatrolThread,ScenarioInfo.P1_ENEM01_Camp03a_Rover, 'P1_RoverPatrol_Camp03')
	ForkThread(RandomPatrolThread,ScenarioInfo.P1_ENEM01_Camp03b_Rover, 'P1_RoverPatrol_Camp03')
	ForkThread(RandomPatrolThread,ScenarioInfo.P1_ENEM01_Camp04_Rover, 'P1_RoverPatrol_Camp04')

	-- Main Base related units
	ScenarioInfo.P1_MainBase_AirPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_MainBase_Init_Air' , 'AttackFormation')

	-- Create tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')

	-- Get a list of all starting air units and give them veterancy
	local enemyAir = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.uia0104,false)
	for k, unit in enemyAir do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 3)
	end

	-- Start the bases
	P1_ENEM01_AISetup()

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_StartingUnits')
	ScenarioInfo.INTRONIS_Group2 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_StartingUnits')
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')

	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')
	ScenarioInfo.INTRONIS_Group2Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_02')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_03')

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Thalia)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )


	-- Disable any tml upgrades on gauge's factories
	ScenarioInfo.P1_ALLY01_Factory01 = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_ALLY01_Factory01']
	ScenarioInfo.P1_ALLY01_Factory01:SetWeaponEnabledByLabel( 'TacticalMissile01', false )

	ScenarioInfo.P1_ALLY01_Factory02 = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_ALLY01_Factory02']
	ScenarioInfo.P1_ALLY01_Factory02:SetWeaponEnabledByLabel( 'TacticalMissile01', false )

	ScenarioInfo.P1_ALLY01_Factory02 = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_ALLY01_Factory02']
	ScenarioInfo.P1_ALLY01_Factory02:SetWeaponEnabledByLabel( 'TacticalMissile01', false )
end

function P1_Main()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Destroy the Command Center
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Destroy the Command Center.')
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.I05_M1_obj10_NAME,			-- title
		OpStrings.I05_M1_obj10_DESC,			-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			ArrowOffset = -4.0,
			ArrowSize = 0.3,
			Units = {ScenarioInfo.P1_ENEM01_Objective_Structure},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	-- setup the command center for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P1_ENEM01_Objective_Structure, LaunchVictoryNIS)

	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				--if the rover threads are still running, turn them off
				ScenarioInfo.ContinueWatchThread = false

				-- destroy the antinukes near the obj unit in preperation
				-- for Gauge doing a nuke.
				local antinukes = ScenarioFramework.GetCatUnitsInArea(categories.uib0203, 'MainPlatform_Area', ArmyBrains[ARMY_ENEM01])
				for k, v in antinukes do
					if v and not v:IsDead() then
						v:Kill()
					end
				end
			end
		end
	)

	-- create radar intel for player that covers the entire map
	ScenarioFramework.CreateIntelAtLocation(PlayerStartIntelRadius, 'ARMY_PLAYER', ARMY_PLAYER, 'Radar')

	-- Trigger VO when the player gets some land units in one of the camps
	ScenarioFramework.CreateMultipleAreaTrigger(P1_PlayerLandAdvice_VO,
		{
			'Camp_01_Area',
			'Camp_02_Area',
			'Camp_03_Area',
			'Camp_04_Area',
		},
		categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 3)

	-- Set up the rover scenario
	P1_BeginRoverScenario()


	-- Initial Attacks: Created here so the attacks dont take place during the NIS. Be sure to obscure this.
	local platoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Init_AirAttack_Player_01', 'AttackFormation')
	local platoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Init_AirAttack_Ally_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon1, 'P1_ENEM01_InitAir_Attack_Chain_01')
	ScenarioFramework.PlatoonPatrolChain(platoon2, 'P1_ENEM01_InitAir_AttackAlly_Chain_01')

	----------------------------------------------
	--Timers and Timed Events, Triggers, Etc
	----------------------------------------------

	--# Basic Triggered VO:

	-- delay an intel trigger that results in vo when player spots the command center (to give intel time to clear).
	ScenarioFramework.CreateTimerTrigger (P1_DelayIntelTrigger, 10)
	-- VO warning player to avoid air, when they build an air factory
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerAirFactoryBuilt_VO, ArmyBrains[ARMY_PLAYER], 'P1_PlayerAirFactoryBuilt_VO',
			{{StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uib0002}})
	-- VO warning player to avoid air, when they build some air units
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerBuiltAirUnits_VO, ArmyBrains[ARMY_PLAYER], 'P1_PlayerBuiltAirUnits_VO',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.AIR}})
	-- VO warning player to avoid air, when they lose some air units
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerLostAirUnit_VO, ArmyBrains[ARMY_PLAYER], 'P1_PlayerLostAirUnit_VO',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.AIR}})
	-- VO encouraging player when they reach the general enemy base area.
	ScenarioFramework.CreateAreaTrigger(P1_PlayerReachedBase_VO, 'ENEM01_MainBase_Area_Large',
		 categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 1 )

	-- VO that assigns the Capture objective
	ScenarioFramework.CreateTimerTrigger (P1_CaptureSecondary_VO, 10)

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 60)

	-- trigger to complete the hidden objective
	ScenarioFramework.CreateArmyUnitCategoryVeterancyTrigger(HiddenObjective, ArmyBrains[ARMY_PLAYER], categories.uil0001, 5)

	-- Create handles to all 3 mass extractors for mass objective intel trigger
	ScenarioInfo.ENEM01_ME01 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_ME01']
	ScenarioInfo.ENEM01_ME02 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_ME02']
	ScenarioInfo.ENEM01_ME03 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_ME03']


	-- Assign the mass objective when the player gets within range of a mass extractor
	ScenarioFramework.CreateArmyIntelTrigger(P1_AssignBuildSecondary_VO, ArmyBrains[ARMY_PLAYER], 'LOSNow', ScenarioInfo.ENEM01_ME01, true,
		 categories.ALLUNITS , true, ArmyBrains[ARMY_ENEM01])
	ScenarioFramework.CreateArmyIntelTrigger(P1_AssignBuildSecondary_VO, ArmyBrains[ARMY_PLAYER], 'LOSNow', ScenarioInfo.ENEM01_ME02, true,
		 categories.ALLUNITS , true, ArmyBrains[ARMY_ENEM01])
	ScenarioFramework.CreateArmyIntelTrigger(P1_AssignBuildSecondary_VO, ArmyBrains[ARMY_PLAYER], 'LOSNow', ScenarioInfo.ENEM01_ME03, true,
		 categories.ALLUNITS , true, ArmyBrains[ARMY_ENEM01])
	ScenarioFramework.CreateAreaTrigger(P1_AssignBuildSecondary_VO, 'Mass_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1 )


	--# Triggers that will enable, then increase or change, enemy air attacks.
	ScenarioFramework.CreateArmyStatTrigger (P1_StrengthenEnemyAttacks, ArmyBrains[ARMY_PLAYER], 'P1_StrengthenEnemyAttacks1',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = PlayerAntiAirUnitCount_A, Category = categories.ANTIAIR}})
	ScenarioFramework.CreateArmyStatTrigger (P1_StrengthenEnemyAttacks, ArmyBrains[ARMY_PLAYER], 'P1_StrengthenEnemyAttacks2',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = PlayerAntiAirUnitCount_B, Category = categories.ANTIAIR}})
	ScenarioFramework.CreateArmyStatTrigger (P1_StrengthenEnemyAttacks, ArmyBrains[ARMY_PLAYER], 'P1_StrengthenEnemyAttacks3',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = PlayerTotalUnitCount, Category = categories.ALL}})


	-- Gauge begins his initial attack, which will demonstrate the distracted rover response
	ScenarioFramework.CreateTimerTrigger (P1_GaugeBeginsAttack, GaugeBeginsAttacks_FailsafeDelay)

	-- Turn rebuild of enemy base structures off if 2 of any factory are destroyed
	ScenarioFramework.CreateArmyStatTrigger (Base_Rebuild_OFF, ArmyBrains[ARMY_ENEM01], 'Base_Rebuild_OFF',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.uib0011 + categories.uib0001 + categories.uib0002}})

	-- a set of triggers for each camp area, to detect player land or experimentals. These will result
	-- in the enemy pulling back (if, in the case of land units, a subsequent recheck is passed).
	for i = 1, 4 do
		local area = 'Camp_0' .. i .. '_Area'
		LOG('----- P1_Main: Triggers created for area ', repr(area))
		-- area trigger for experimental: if player gets an experimental into the area, shut down immediately.
		ScenarioFramework.CreateAreaTrigger(P1_EnemyPullsBack, area, categories.EXPERIMENTAL, true, false, ArmyBrains[ARMY_PLAYER], 1 )

		-- area trigger for land units: if player gets n land units in an area, begin a recheck to verify they really have taken control.
		ScenarioFramework.CreateAreaTrigger(
			function()
				ForkThread(P1_VerifyPlayerAtCampThread, area)
			end,
			area,
			categories.LAND,
			true,
			false,
			ArmyBrains[ARMY_PLAYER],
			20
		)


	end

end

function P1_BuildSecondary_Assign()
	----------------------------------------------
	-- Secondary Objective S1_obj10 - Build Mass
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S1_obj10 - Build Mass.')
	local descText = OpStrings.I05_S1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I05_S1_obj10_TAKE_MASS)
	ScenarioInfo.S1_obj10 = SimObjectives.CategoriesInArea(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.I05_S1_obj10_NAME,			-- title
		descText,								-- description
		'build',								-- Action
		{
			---NOTE: I decided to remove the area marking and rely just on the arrow - speak with me before changing this back
			---			the rationale is a compromise to narrow the scope of area area-objective visualization issues to just U06 - bfricks 11/28/09
			AddArrow = true,
			ArrowHeight = 10.0,
			Requirements = {
				{Area = 'SecondaryObj_Area_01', Category = categories.uib0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
				{Area = 'SecondaryObj_Area_02', Category = categories.uib0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
				{Area = 'SecondaryObj_Area_03', Category = categories.uib0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
				{Area = 'SecondaryObj_Area_04', Category = categories.uib0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
			},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)

	ScenarioInfo.S1_obj10:AddProgressCallback(
		function(current, total)
			-- Play some progress encouragement, unless the op is effectively already done
			if current == 1 and not (ScenarioInfo.P1_ENEM01_Objective_Structure:IsDead()) then
				ScenarioFramework.Dialogue(OpDialog.I05_S1_obj10_PROGRESS)
			end
		end
	)

	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I05_S1_obj10_TAKE_MASS, ARMY_PLAYER, 3.0)
			ScenarioFramework.Dialogue(OpDialog.I05_S1_obj10_COMPLETE)
		end
	)
end

function P1_CaptureSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.I05_P1_ASSIGN_GATE_010, P1_CaptureSecondary_Assign)
end

function P1_CaptureSecondary_Assign()
	----------------------------------------------
	-- Secondary Objective S2_obj10 - Capture the Teleporter
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S2_obj10 - Capture the Teleporter.')
	local descText = OpStrings.I05_S2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I05_S2_obj10_TAKE_TEMPLE)
	ScenarioInfo.S2_obj10 = SimObjectives.Capture(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.I05_S2_obj10_NAME,			-- title
		descText,								-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			ArrowOffset = 15.0,
			Units = {ScenarioInfo.P1_ENEM01_Teleporter},
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj10)
	ScenarioInfo.S2_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I05_S2_obj10_TAKE_TEMPLE, ARMY_PLAYER, 3.0)

				-- Instructional VO related to the Gate. Afterwards, begin Gauge's attacks (if he
				-- hasnt started already due to failsafe timer kicking in for him). This will be delayed
				-- briefly, to give time for the effect of the player experimenting with their new Teleporter.
				ScenarioFramework.Dialogue(OpDialog.I05_S2_obj10_COMPLETE, P1_GaugeBeginsAttack_Delay)

				-- Trigger to detect teleporter Beacon in one of the camp areas, confirmation VO
				ScenarioFramework.CreateMultipleAreaTrigger(P1_PlayerPlacedBeacon,
					{
						'Camp_01_Area',
						'Camp_02_Area',
						'Camp_03_Area',
						'Camp_04_Area',
					},
					categories.uib0902, true, false, ArmyBrains[ARMY_PLAYER], 1)

				-- get local handle for teleporter and flag it as unkillable
				local teleporter = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uix0113, false)
				for k, v in teleporter do
					v:SetCanBeKilled(false)
				end

				-- create trigger for follow-up VO tip regarding the space temple
				ScenarioFramework.CreateTimerTrigger (Temple_Tip_Vo, 12)
			end
		end
	)
end

function Temple_Tip_Vo()
	ScenarioFramework.Dialogue(OpDialog.I05_TEMPLE_TIP)
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.I05_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.I05_S3_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary Objective S2_obj10 - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S2_obj10 - Research Technology.')
	ScenarioInfo.S2_obj20 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.I05_S3_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj20)

	LOG('----- P1: research objectives result callbacks')
	--confirmation VO when complete.
	ScenarioInfo.S2_obj20:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.I05_RESEARCH_FOLLOWUP_AIRNOMO_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 300)
end

function ResearchReminder1()
	if ScenarioInfo.S2_obj20.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.I05_RESEARCH_REMINDER_010)
	end
end

function HiddenObjective()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Supreme Commander
	----------------------------------------------
	LOG('----- Assign Hidden Objective H1_obj10 - Supreme Commander')
	local descText = OpStrings.I05_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I05_H1_obj10_MAKE_SUPERACU)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',									-- type
		'complete',										-- status
		OpStrings.I05_H1_obj10_NAME,					-- title
		descText,										-- description
		SimObjectives.GetActionIcon('research'),		-- Action
		{
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I05_H1_obj10_MAKE_SUPERACU, ARMY_PLAYER, 3.0)
end

function Base_Rebuild_OFF()
	LOG('----- Base_Rebuild_OFF')
	ScenarioInfo.ArmyBase_ENEM01_West_Base:SetBuildAllStructures(false)
	ScenarioInfo.ArmyBase_ENEM01_East_Base:SetBuildAllStructures(false)
end

function P1_DelayIntelTrigger()
	-- VO when player sights Command Center
	-- SB per brian, make sure this plays in sequence after REACHED_ENEMY_010 vo 9.20.09
	ScenarioFramework.CreateArmyIntelTrigger(P1_CenterSighted_VO, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		 categories.scb2501, true, ArmyBrains[ARMY_ENEM01])
end

function P1_GaugeBeginsAttack_Delay()
	-- Delay Gauge's attacks briefly, to allow some breathing space between VO and events.
	ScenarioFramework.CreateTimerTrigger (P1_GaugeBeginsAttack, 45)
end

function P1_GaugeBeginsAttack()
	-- Gauge attacks. As this can be called via sequence or from a failsafe timer, ensure it happens only once.
	if not ScenarioInfo.P1_GaugeAttacksBegun then
		ScenarioInfo.P1_GaugeAttacksBegun = true
		LOG('----- P1: Gauge begins attack: sending in intial platoon.')
		-- Here, we take the starting air platoon that Guage has, flag its units back to killable and normal,
		-- and then hand it to the OpAI as the opening attack of his attack OpAI we turn on. The reason for this
		-- starting platoon is so we can on-demand show the 'distracted neighbors' dynamic.

		-- Set the platoon that Gauge's attack OpAI uses back to unprotected
		-- and then turn on that OpAI.
		IssueClearCommands(ScenarioInfo.P1_ALLY01_InitalAttack_01:GetPlatoonUnits())
		UnProtectGroup(ScenarioInfo.P1_ALLY01_InitalAttack_01:GetPlatoonUnits())

		-- VO from Gauge, and some delayed VO pointing out his discovering of the distract/assist mechanism
		ScenarioFramework.Dialogue(OpDialog.I05_P1_GAUGE_BUILT_010)
		ScenarioFramework.CreateTimerTrigger (P1_FirstGaugeAttackResultVO, 30)

		-- Pass in this inital platoon to the OpAI for it to use and send out, and turn the OpAI on.
		ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI:		AddActivePlatoon(ScenarioInfo.P1_ALLY01_InitalAttack_01, true)
		ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI:		Enable()
	end
end

function P1_FirstGaugeAttackResultVO()
	LOG('----- P1: Gauge plays roving air patrol discovery dialogue')
	-- Gauge plays VO that points out the distract/assist mechanism of the roving enemy air patrols
	ScenarioFramework.Dialogue(OpDialog.I05_GAUGE_ATTACK_RESULT_010)
end

function P1_VerifyPlayerAtCampThread(area)
	LOG('----- P1: Player detected in a camp area. Beginning verify check sequence')
	LOG('----- P1: area ', repr(area))

	-- Player has been detected in the passed in area. In this function, we will recheck for the player, a number of times,
	-- to verify that the player is substantively in the area and in control. Otherwise, we recreate the trigger that called
	-- this function to start the process over again.

	-- Check if its still appropriate for this to take place
	if not ScenarioInfo.P1_EnemyHasPulledBack then
		local count = 0
		while count <= PlayerAtPlatform_CheckSeconds do
			local numPlayer = ScenarioFramework.NumCatUnitsInArea(categories.LAND, area, ArmyBrains[ARMY_PLAYER])
			LOG('----- P1: player units in area ', repr(numPlayer))
			if numPlayer >= PlayerAtPlatform_Units then
				count = count + 1

			-- if we fail at some point in the check, due to the player dropping below the unit threshold, then
			-- end this thread and recreate the trigger that started this thread.
			else
				LOG('----- P1: Player failed to hold area. Resetting for area ', repr(area))
				ScenarioFramework.CreateAreaTrigger(
					function()
						ForkThread(P1_VerifyPlayerAtCampThread, area)
					end,
					area,
					categories.LAND,
					true,
					false,
					ArmyBrains[ARMY_PLAYER],
					28
				)

				return
			end
			WaitSeconds(1)
		end
		LOG('----- P1: Player controls area. Beginning enemy retreat.')
		-- Player has passed our check, so we can now have the enemy begin to pull back.
		P1_EnemyPullsBack()
	end
end

function P1_EnemyPullsBack()
	-- Here, the enemy will go through the steps of dismantling the Roving Air Defense
	-- system, and organizing the air units that are part of that system (if any remain)
	-- into a new platoon that will patrol the main base area.

	if not ScenarioInfo.P1_EnemyHasPulledBack then
		ScenarioInfo.P1_EnemyHasPulledBack = true
		LOG('----- P1: Enemy is pulling back.')

		-- Turn off the threads that watch and maintain the Roving Air groups.
		ScenarioInfo.ContinueWatchThread = false

		-- Turn off the Rover camps air replenishment OpAIs.
		ScenarioInfo.ENEM01_West_Rover01_OpAI:Disable()
		ScenarioInfo.ENEM01_West_Rover02_OpAI:Disable()
		ScenarioInfo.ENEM01_East_Rover03_OpAI:Disable()
		ScenarioInfo.ENEM01_East_Rover04_OpAI:Disable()

		-- Add all 4 camps' information tables to a new holding table, so we can
		-- easily manipulate them in one fell swoop, in preperation for dealing
		-- with the rover units.
		local mainTable = {}
		table.insert(mainTable, ScenarioInfo.Camp01_Rover_Info)
		table.insert(mainTable, ScenarioInfo.Camp02_Rover_Info)
		table.insert(mainTable, ScenarioInfo.Camp03_Rover_Info)
		table.insert(mainTable, ScenarioInfo.Camp04_Rover_Info)

		-- Go through each 'platoons' table (which contains some number of platoons)
		-- contained in each camp's info holding table, and add all the units in each
		-- platoon to a new table. Disband each platoon.
		local unitTable = {}

		-- for each camps info table
		for j, infoTable in mainTable do
			-- iterate through the platoons that are in the info table's 'platoons' table
			for key, platoon in infoTable.platoons do
				if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
					-- Get the units in the platoon, disband the platoon, then add the units
					-- to our temporary holding table of units, which will be dealt with.
					local units = platoon:GetPlatoonUnits()
					platoon:PlatoonDisband()
					for k, v in units do
						if v and not v:IsDead() then
							IssueClearCommands({v})
							table.insert(unitTable, v)
						end
					end
				end
			end
		end

		LOG('---- P1: PULLBACK: untable created, trying to form platoon.')

		-- Create the main base platoon that will patrol the central area:
		-- if we have any units available, try to add them to a platoon.
		if table.getn(unitTable) > 0 then
			-- create the platoon
			local mainPlatoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')

			-- a count we will incrememnt to compare to the size we want for the platoon
			local count = 0
			for k, v in unitTable do

				-- if we havent stocked the platoon with the number we want in it, then continue adding units to the platoon
				if count < EnemyDefenseAirPlatoon_Size then
					ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( mainPlatoon , {v}, 'Attack', 'AttackFormation' )
					count = count + 1
					--remove this unit from our table of available units, now that it has been added to a platoon
					table.remove(unitTable, k)
				end
			end

			-- Add the platoon as an active member for an OpAI, and turn on the OpAI
			if mainPlatoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(mainPlatoon) then
				ScenarioInfo.ENEM01_West_AirDef01_OpAI:AddActivePlatoon(mainPlatoon, true)
			end
			ScenarioInfo.ENEM01_West_AirDef01_OpAI:Enable()
			LOG('----- P1: PULLBACK: platoon creaated.')

			-- clean up the remainders
			if table.getn(unitTable) > 0 then
				LOG('----- P1: PULLBACK: leftover units being cleared.')
				for k, v in unitTable do
					IssueMove({v}, ScenarioUtils.MarkerToPosition('P1_ENEM01_AirOverstock_Delete_Marker'))
					ScenarioFramework.CreateUnitToMarkerDistanceTrigger( DestroyUnit, v, 'P1_ENEM01_AirOverstock_Delete_Marker', 20 )
				end
			end
		end

		-- Turn off 2 of the camp mobile antiair patrols, leaving 2 active
		ScenarioInfo.ENEM01_West_Camp01Land_OpAI:Disable()
		ScenarioInfo.ENEM01_East_Camp03Land_OpAI:Disable()

		-- Update the remaining these two land defense opais to use patrol chains that are at the main base, now that the
		-- enemy is pulling back into defense mode.
		ScenarioInfo.ENEM01_West_Camp02Land_OpAI_Data = {AnnounceRoute = true, PatrolChains = {'P1_ENEM01_WestBase_InnerLand_Chain_01',},}
		ScenarioInfo.ENEM01_East_Camp04Land_OpAI_Data = {AnnounceRoute = true, PatrolChains = {'P1_ENEM01_EastBase_InnerLand_Chain_01',},}
		ScenarioInfo.ENEM01_West_Camp02Land_OpAI:SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Camp02Land_OpAI_Data )
		ScenarioInfo.ENEM01_East_Camp04Land_OpAI: SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_East_Camp04Land_OpAI_Data )

		-- Update these remaining two land defense opais to include some anti-land units as well, so the player will encounter some
		-- nascent resistance
		ScenarioInfo.ENEM01_West_Camp02Land_OpAI:EnableChildTypes( {'IlluminateMobileAntiAir', 'IlluminateTanks'} )
		ScenarioInfo.ENEM01_East_Camp04Land_OpAI:EnableChildTypes( {'IlluminateMobileAntiAir', 'IlluminateTanks'} )

		-- Turn on opais that will build Assault Blocks to patrol at the end of each bridge
		ScenarioInfo.ENEM01_West_Block01_OpAI:Enable()
		ScenarioInfo.ENEM01_West_Block02_OpAI:Enable()
		ScenarioInfo.ENEM01_West_Block03_OpAI:Enable()
		ScenarioInfo.ENEM01_West_Block04_OpAI:Enable()

		-- Turn off Ally's custom move OpAI, and turn on a conventional one in its place.
		ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI:Disable()
		ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI:Enable()

		-- Turn on enemy land attacks that will patrol the 'inner arm' spans
		ScenarioInfo.ENEM01_East_LandAttack_OpAI:Enable()
		ScenarioInfo.ENEM01_East_LandAttack_OpAI:Enable()

		-- Set up a trigger that will detect player in the central enemy area near the Objective unit,
		-- and tell any Assault Blocks to move to a patrol there (and update their OpAIs to do the same)
		ScenarioFramework.CreateAreaTrigger(P1_PlayerAtMainObjectiveArea, 'MainPlatform_Area', categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 2 )

		-- After some time for the event to take place, play VO pointing it out.
		ScenarioFramework.CreateTimerTrigger (P1_EnemyRetreat_VO, 10)
	end
end

function P1_PlayerAtMainObjectiveArea()
	LOG('----- P1: Player detected in middle area. Moving existing assault blocks, updating their OpAI')

	-- Send any Assault Blocks that have been built by OpAI
	for k, platoon in ScenarioInfo.P1_EnemyAssaultBlockPlatoons do
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			IssueClearCommands(platoon:GetPlatoonUnits())
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Land_Inner_Chain_01')
		end
	end

	-- Update the assault block OpAIs to use a new patrol which is at the main objective area
	ScenarioInfo.ENEM01_West_Block01_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Land_Inner_Chain_01',},}
	ScenarioInfo.ENEM01_West_Block02_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Land_Inner_Chain_01',},}
	ScenarioInfo.ENEM01_West_Block03_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Land_Inner_Chain_01',},}
	ScenarioInfo.ENEM01_West_Block04_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Land_Inner_Chain_01',},}
	ScenarioInfo.ENEM01_West_Block01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block01_OpAI_Data )
	ScenarioInfo.ENEM01_West_Block02_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block02_OpAI_Data )
	ScenarioInfo.ENEM01_West_Block03_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block03_OpAI_Data )
	ScenarioInfo.ENEM01_West_Block04_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block04_OpAI_Data )
end

function P1_AllyPlatoonBuiltCallback()

	-- Play some VO for the first few times Gauge sends in attacks.
	GaugeAttackPlatoonCount = GaugeAttackPlatoonCount + 1
	if GaugeAttackPlatoonCount == 1 then
		ScenarioFramework.Dialogue(OpDialog.I05_P1_GAUGE_BUILT_020)

	elseif GaugeAttackPlatoonCount == 2 then
		ScenarioFramework.Dialogue(OpDialog.I05_P1_GAUGE_BUILT_030)

	elseif GaugeAttackPlatoonCount == 3 then
		ScenarioFramework.Dialogue(OpDialog.I05_P1_GAUGE_BUILT_040)

	elseif GaugeAttackPlatoonCount == 4 then
		ScenarioFramework.Dialogue(OpDialog.I05_P1_GAUGE_BUILT_050)
	end
end
---------------------------------------------------------------------
-- VO RELATED FUNCTIONS:
---------------------------------------------------------------------

function P1_AssignBuildSecondary_VO()
	-- VO for the build secondary. As this can be called from two places (failsafe timer, or completing the
	-- capture objective), ensure it only takes place once.
	if not ScenarioInfo.BuildSecondaryAssigned then
		ScenarioInfo.BuildSecondaryAssigned = true
		ScenarioFramework.Dialogue(OpDialog.I05_S1_obj10_ASSIGN, P1_BuildSecondary_Assign)
	end
end

function P1_PlayerLandAdvice_VO()
	-- Player got some land units on a platform. Play encouraging VO
	ScenarioFramework.Dialogue(OpDialog.I05_P1_ADVICE_010)
end

function P1_PlayerPlacedBeacon()
	-- Player has placed a Teleporter beacon. Play confirmation VO
	ScenarioFramework.Dialogue(OpDialog.I05_BEACON_DEPLOYED_010)
end

function P1_EnemyRetreat_VO()
	-- VO pointing out the enemy retreat
	ScenarioFramework.Dialogue(OpDialog.I05_ENEMY_RETREATS_010)
end

function P1_CenterSighted_VO()
	-- Player got sight range on the Command Center objective structure
	ScenarioFramework.Dialogue(OpDialog.I05_REACHED_ENEMY_020)
end

function P1_PlayerAirFactoryBuilt_VO()
	-- Player built an air factory. Play VO to advise going land.
	ScenarioFramework.Dialogue(OpDialog.I05_AIRFACTORY_BUILT_010)
end

function P1_PlayerBuiltAirUnits_VO()
	-- Player built an air units. Play VO to advise going land.
	ScenarioFramework.Dialogue(OpDialog.I05_AIR_BUILT_010)
end

function P1_PlayerLostAirUnit_VO()
	-- Player lost air units. Play VO to advise going land.
	ScenarioFramework.Dialogue(OpDialog.I05_AIR_DESTROYED_010)
end

function P1_PlayerReachedBase_VO()
	-- Player has reach the enemy back base. Play encouraging VO.
	ScenarioFramework.Dialogue(OpDialog.I05_REACHED_ENEMY_010)
end

---------------------------------------------------------------------
-- ROVING ENEMY PLATOON RELATED FUNCTIONS:
---------------------------------------------------------------------
function P1_BeginRoverScenario()
	LOG('----- P1: Setting up rover scenario')

	-- set up the information used by the rover group watch thread (note: camp3 has extra starting units, as Gauge focuses on this camp)
	ScenarioInfo.ContinueWatchThread = true

	ScenarioInfo.Camp01_Rover_Info = { platoons = {ScenarioInfo.P1_ENEM01_Camp01_Rover}, homeChain = 'P1_RoverPatrol_Camp01', homeIsThreatened = false}
	ScenarioInfo.Camp02_Rover_Info = { platoons = {ScenarioInfo.P1_ENEM01_Camp02_Rover}, homeChain = 'P1_RoverPatrol_Camp02', homeisThreatened = false}
	ScenarioInfo.Camp03_Rover_Info = { platoons = {ScenarioInfo.P1_ENEM01_Camp03a_Rover, ScenarioInfo.P1_ENEM01_Camp03b_Rover}, homeChain = 'P1_RoverPatrol_Camp03', homeisThreatened = false}
	ScenarioInfo.Camp04_Rover_Info = { platoons = {ScenarioInfo.P1_ENEM01_Camp04_Rover}, homeChain = 'P1_RoverPatrol_Camp04', homeisThreatened = false}

	ScenarioInfo.Camp01_Rover_WaitingList = {}
	ScenarioInfo.Camp02_Rover_WaitingList = {}
	ScenarioInfo.Camp03_Rover_WaitingList = {}
	ScenarioInfo.Camp04_Rover_WaitingList = {}

	-- start a thread that manages what the rover group does based off
	-- things the bases set and modify.
	ForkThread(RoverWatchThread, ScenarioInfo.Camp01_Rover_Info, ScenarioInfo.Camp01_Rover_WaitingList)
	ForkThread(RoverWatchThread, ScenarioInfo.Camp02_Rover_Info, ScenarioInfo.Camp02_Rover_WaitingList)
	ForkThread(RoverWatchThread, ScenarioInfo.Camp03_Rover_Info, ScenarioInfo.Camp03_Rover_WaitingList)
	ForkThread(RoverWatchThread, ScenarioInfo.Camp04_Rover_Info, ScenarioInfo.Camp04_Rover_WaitingList)

	-- create a trigger that detects a player attack, which will set flags
	-- and modify things the rover threads watch.

	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp01_Threatened, 'Camp_01_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp02_Threatened, 'Camp_02_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp03_Threatened, 'Camp_03_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp04_Threatened, 'Camp_04_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )

end

function RoverWatchThread(roverInfo, requestedPatrolList)
	LOG('----- P1: A watcher thread was started')
	LOG(repr(requestedPatrolList))

	local onMyWay = false
	local currentPatrol = requestedPatrolList[1]

	while ScenarioInfo.ContinueWatchThread do

		-- if home is not under attack, and my current patrol does not match what is
		-- first in my list (ie, if a base has been removed a patrol from my list, resulting
		-- in a new patrol being top of the list), and if we arent already on our way home to defend
		-- despite not being told that home has become safe (onMyWay),
		if not roverInfo.homeIsThreatened and not onMyWay and (currentPatrol != requestedPatrolList[1]) then
			LOG('------ P1: Changing to new requested patrol')

			-- then switch my patrol to the first entry on my patrol list that my neighbors
			-- who need help put there.
			for key, platoon in roverInfo.platoons do
				if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
					for k, v in platoon:GetPlatoonUnits() do
						if(v and not v:IsDead()) then
							IssueClearCommands({v})
						end
					end
				end
			end

			-- If our request list is empty, then that means its time to return to home base and wait for more requests.
			-- otherwise, head to the next request.
			if requestedPatrolList[1] == nil then
				for key, platoon in roverInfo.platoons do
					if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
						ForkThread(RandomPatrolThread, platoon, roverInfo.homeChain)
					end
				end
			else
				for key, platoon in roverInfo.platoons do
					if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
						ForkThread(RandomPatrolThread, platoon, requestedPatrolList[1])
					end
				end
			end

			-- we are now on patrol for the first request in the list. While this remains the case
			-- (ie, until the requesting base clears this patrol from the waiting queue) we will persist
			-- with this patrol (our home base getting attacked notwithstandin).
			currentPatrol = requestedPatrolList[1]
		end

		-- however, if my home base is underattack, that takes priority.
		-- Check, however, that I am not already on my way there.
		if roverInfo.homeIsThreatened and not onMyWay then
			LOG('------ P1: Home is threatened, returning')

			for key, platoon in roverInfo.platoons do
				if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
					-- clear commands for each valid platoon
					for k, v in platoon:GetPlatoonUnits() do
						if(v and not v:IsDead()) then
							IssueClearCommands({v})
						end
					end
					-- and send it to the home patrol
					ForkThread(RandomPatrolThread, platoon, roverInfo.homeChain)
				end
			end
			onMyWay = true
		end

		-- reset onMyWay flag if my home base is safe but the flag is still set
		if not roverInfo.homeIsThreatened and onMyWay then
			LOG('------ P1: Home is no longer detected, but Im on my way there. Resetting flag for next tick.')

			onMyWay = false

			-- as well, reset currentPatrol, to trigger a recheck and reassign of the next requested patrol
			local currentPatrol ={}
		end

		WaitSeconds(5)
	end
end

function P1_Camp01_Threatened()
	LOG('----- P1: Camp 01 was threatened by player')

	-- A trigger detecting the player has appeared at the rover's home base got us here.
	-- Flag that the base is threatened for the rovers main watcher thread.
	ScenarioInfo.Camp01_Rover_Info.homeIsThreatened = true

	-- get in line with the bases neighbors rover groups by inserting this base
	-- patrol route into the neighbor rover groups patrol waiting list. Importantly,
	-- add the patrol to the end of their list, as its first come, first serve.

	--In this case, our only neighbor is Base 02
	if not (table.find( ScenarioInfo.Camp02_Rover_WaitingList, 'P1_RoverPatrol_Camp01' )) then
		table.insert(ScenarioInfo.Camp02_Rover_WaitingList, 'P1_RoverPatrol_Camp01')
	end

	-- create a trigger to detect when this home base is no longer under threat from the player.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp01_Safe, 'Camp_01_Area',
		 categories.ALLUNITS, true, true, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, 1 )

end

function P1_Camp01_Safe()
	LOG('----- P1: Camp 01 is now safe.')

	-- a trigger has decided that the home base is no longer under threat from the player.
	-- flag that we are not under threat any more for the bases rover watch thread.
	ScenarioInfo.Camp01_Rover_Info.homeIsThreatened = false

	-- earlier, I put myself in the queue of neighboring rover groups patrol waiting
	-- list. Remove my request from their queue, as we no longer need them. (their
	-- watch thread deals with these requests).

	--In camp01's case, our only neighbor is Base 2
	for k, v in ScenarioInfo.Camp02_Rover_WaitingList do
		if v == 'P1_RoverPatrol_Camp01' then
			table.remove(ScenarioInfo.Camp02_Rover_WaitingList, k)
		end
	end
	LOG('-----  P1: ', repr(ScenarioInfo.Camp02_Rover_WaitingList))

	-- reset the whole base squence by recreating a trigger to detect a player attack
	-- on this base.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp01_Threatened, 'Camp_01_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )
end

function P1_Camp02_Threatened()
	LOG('----- P1: Camp 02 was threatened by player')

	-- A trigger detecting the player has appeared at the rover's home base got us here.
	-- Flag that the base is threatened for the rovers main watcher thread.
	ScenarioInfo.Camp02_Rover_Info.homeIsThreatened = true

	-- get in line with the bases neighbors rover groups by inserting this base
	-- patrol route into the neighbor rover groups patrol waiting list. Importantly,
	-- add the patrol to the end of their list, as its first come, first serve.

	-- our neighbors are camp 1 and 3
	if not (table.find( ScenarioInfo.Camp01_Rover_WaitingList, 'P1_RoverPatrol_Camp02' )) then
		table.insert(ScenarioInfo.Camp01_Rover_WaitingList, 'P1_RoverPatrol_Camp02')
	end
	if not (table.find( ScenarioInfo.Camp03_Rover_WaitingList, 'P1_RoverPatrol_Camp02' )) then
		table.insert(ScenarioInfo.Camp03_Rover_WaitingList, 'P1_RoverPatrol_Camp02')
	end

	-- create a trigger to detect when this home base is no longer under threat from the player.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp02_Safe, 'Camp_02_Area',
		 categories.ALLUNITS, true, true, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, 1 )

end

function P1_Camp02_Safe()
	LOG('----- P1: Camp 02 is now safe.')

	-- a trigger has decided that the home base is no onger under threat from the player.
	-- flag that we are not under threat any more for the bases rover watch thread.
	ScenarioInfo.Camp02_Rover_Info.homeIsThreatened = false

	-- earlier, I put myself in the queue of neighboring rover groups patrol waiting
	-- list. Remove my request from their queue, as we no longer need them. (their
	-- watch thread deals with these requests).

	-- our neighbors are camp 1 and 3
	for k, v in ScenarioInfo.Camp01_Rover_WaitingList do
		if v == 'P1_RoverPatrol_Camp02' then
			table.remove(ScenarioInfo.Camp01_Rover_WaitingList, k)
		end
	end
	for k, v in ScenarioInfo.Camp03_Rover_WaitingList do
		if v == 'P1_RoverPatrol_Camp02' then
			table.remove(ScenarioInfo.Camp03_Rover_WaitingList, k)
		end
	end

	LOG('----- P1: ', repr(ScenarioInfo.Camp03_Rover_WaitingList))

	-- reset the whole base squence by recreating a trigger to detect a player attack
	-- on this base.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp02_Threatened, 'Camp_02_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )
end

function P1_Camp03_Threatened()
	LOG('----- P1: Camp 03 was threatened by player')

	-- A trigger detecting the player has appeared at the rover's home base got us here.
	-- Flag that the base is threatened for the rovers main watcher thread.
	ScenarioInfo.Camp03_Rover_Info.homeIsThreatened = true

	-- get in line with the bases neighbors rover groups by inserting this base
	-- patrol route into the neighbor rover groups patrol waiting list. Importantly,
	-- add the patrol to the end of their list, as its first come, first serve.

	-- our neighbors are camp 2 and 4
	if not (table.find( ScenarioInfo.Camp02_Rover_WaitingList, 'P1_RoverPatrol_Camp03' )) then
		table.insert(ScenarioInfo.Camp02_Rover_WaitingList, 'P1_RoverPatrol_Camp03')
	end
	if not (table.find( ScenarioInfo.Camp04_Rover_WaitingList, 'P1_RoverPatrol_Camp03' )) then
		table.insert(ScenarioInfo.Camp04_Rover_WaitingList, 'P1_RoverPatrol_Camp03')
	end

	-- create a trigger to detect when this home base is no longer under threat from the player.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp03_Safe, 'Camp_03_Area',
		 categories.ALLUNITS, true, true, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, 1 )

end

function P1_Camp03_Safe()
	LOG('------ P1: Camp 03 is now safe.')

	-- a trigger has decided that the home base is no onger under threat from the player.
	-- flag that we are not under threat any more for the bases rover watch thread.
	ScenarioInfo.Camp03_Rover_Info.homeIsThreatened = false

	-- earlier, I put myself in the queue of neighboring rover groups patrol waiting
	-- list. Remove my request from their queue, as we no longer need them. (their
	-- watch thread deals with these requests).

	-- our neighbors are camp 2 and 4
	for k, v in ScenarioInfo.Camp02_Rover_WaitingList do
		if v == 'P1_RoverPatrol_Camp03' then
			table.remove(ScenarioInfo.Camp02_Rover_WaitingList, k)
		end
	end
	for k, v in ScenarioInfo.Camp04_Rover_WaitingList do
		if v == 'P1_RoverPatrol_Camp03' then
			table.remove(ScenarioInfo.Camp04_Rover_WaitingList, k)
		end
	end

	LOG('----- P1: ', repr(ScenarioInfo.Camp03_Rover_WaitingList))

	-- reset the whole base squence by recreating a trigger to detect a player attack
	-- on this base.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp03_Threatened, 'Camp_03_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )
end


function P1_Camp04_Threatened()
	LOG('----- P1: Camp 04 was threatened by player')

	-- A trigger detecting the player has appeared at the rover's home base got us here.
	-- Flag that the base is threatened for the rovers main watcher thread.
	ScenarioInfo.Camp04_Rover_Info.homeIsThreatened = true

	-- get in line with the bases neighbors rover groups by inserting this base
	-- patrol route into the neighbor rover groups patrol waiting list. Importantly,
	-- add the patrol to the end of their list, as its first come, first serve.

	-- our neighbor is only camp 3
	if not (table.find( ScenarioInfo.Camp03_Rover_WaitingList, 'P1_RoverPatrol_Camp04' )) then
		table.insert(ScenarioInfo.Camp03_Rover_WaitingList, 'P1_RoverPatrol_Camp04')
	end

	-- create a trigger to detect when this home base is no longer under threat from the player.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp04_Safe, 'Camp_04_Area',
		 categories.ALLUNITS, true, true, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, 1 )

end

function P1_Camp04_Safe()
	LOG('----- P1: Camp 04 is now safe.')

	-- a trigger has decided that the home base is no onger under threat from the player.
	-- flag that we are not under threat any more for the bases rover watch thread.
	ScenarioInfo.Camp04_Rover_Info.homeIsThreatened = false

	-- earlier, I put myself in the queue of neighboring rover groups patrol waiting
	-- list. Remove my request from their queue, as we no longer need them. (their
	-- watch thread deals with these requests).

	-- our neighbor is camp 3
	for k, v in ScenarioInfo.Camp03_Rover_WaitingList do
		if v == 'P1_RoverPatrol_Camp04' then
			table.remove(ScenarioInfo.Camp03_Rover_WaitingList, k)
		end
	end

	LOG('----- P1: ', repr(ScenarioInfo.Camp04_Rover_WaitingList))

	-- reset the whole base squence by recreating a trigger to detect a player attack
	-- on this base.
	ScenarioFramework.CreateMultipleBrainAreaTrigger(P1_Camp04_Threatened, 'Camp_04_Area',
		 categories.ALLUNITS, true, false, {ArmyBrains[ARMY_PLAYER], ArmyBrains[ARMY_ALLY01]}, AirTriggerAmount )
end

function P1_AddCamp01Platoon(platoon)
	-- Add the newly created platoon to the table of platoons contained in this camp area's info table
	table.insert (ScenarioInfo.Camp01_Rover_Info.platoons, platoon)

	-- Stop the current AI the platoon got from the OpAI, and then
	-- clear the platoon commands, in preperation for our new patrol.
	-- (not that StopAI() does not clear commands itself, so we need to
	-- both stop, and clear, here).
	platoon:StopAI()
	for k, v in platoon:GetPlatoonUnits() do
		if(v and not v:IsDead()) then
			IssueClearCommands({v})
		end
	end

	-- Go on patrol: if our waiting list is empty, head home. If not,
	-- head to the first patrol on our patrol waiting list.
	if ScenarioInfo.Camp01_Rover_WaitingList[1] == nil then
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp01_Rover_Info.homeChain)
		end
	else
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp01_Rover_WaitingList[1])
		end
	end
end

function P1_AddCamp02Platoon(platoon)
	-- Add the newly created platoon to the table of platoons contained in this camp area's info table
	table.insert (ScenarioInfo.Camp02_Rover_Info.platoons, platoon)

	platoon:StopAI()
	for k, v in platoon:GetPlatoonUnits() do
		if(v and not v:IsDead()) then
			IssueClearCommands({v})
		end
	end

	if ScenarioInfo.Camp01_Rover_WaitingList[1] == nil then
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp02_Rover_Info.homeChain)
		end
	else
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp02_Rover_WaitingList[1])
		end
	end
end

function P1_AddCamp03Platoon(platoon)
	-- Add the newly created platoon to the table of platoons contained in this camp area's info table
	table.insert (ScenarioInfo.Camp03_Rover_Info.platoons, platoon)

	platoon:StopAI()
	for k, v in platoon:GetPlatoonUnits() do
		if(v and not v:IsDead()) then
			IssueClearCommands({v})
		end
	end

	if ScenarioInfo.Camp01_Rover_WaitingList[1] == nil then
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp03_Rover_Info.homeChain)
		end
	else
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp03_Rover_WaitingList[1])
		end
	end
end

function P1_AddCamp04Platoon(platoon)
	-- Add the newly created platoon to the table of platoons contained in this camp area's info table
	table.insert (ScenarioInfo.Camp04_Rover_Info.platoons, platoon)

	platoon:StopAI()
	for k, v in platoon:GetPlatoonUnits() do
		if(v and not v:IsDead()) then
			IssueClearCommands({v})
		end
	end

	if ScenarioInfo.Camp01_Rover_WaitingList[1] == nil then
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp04_Rover_Info.homeChain)
		end
	else
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ForkThread(RandomPatrolThread, platoon, ScenarioInfo.Camp04_Rover_WaitingList[1])
		end
	end
end

---------------------------------------------------------------------
-- BASE MANAGER AND OPAI RELATED FUNCTIONS:
---------------------------------------------------------------------
function P1_Ally_AISetup()

	--# Gauge's base
	local levelTable_ALLY01_Main_Base = {
		P1_ALLY01_Base_100 = 100,
		P1_ALLY01_Base_90 = 90,
		P1_ALLY01_Base_80 = 80,
	}

	ScenarioInfo.ArmyBase_ALLY01_Main_Base = ArmyBrains[ARMY_ALLY01].CampaignAISystem:AddBaseManager('ArmyBase_ALLY01_Main_Base',
		 'P1_ALLY01_MainBase_Marker', 50, levelTable_ALLY01_Main_Base)
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:StartEmptyBase(2)
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddEngineer(ScenarioInfo.ALLY01_CDR)

	-- Make the base be "in progress", with just one chunk left, by spawning in all but that chunk (group 80 is the undone part).
	-- We do this so that Guage has just a touch of building left, to provide an excuse for Gauge delaying his initial attack.
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:SpawnGroup('P1_ALLY01_Base_90')
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:SpawnGroup('P1_ALLY01_Base_100')
	--in the case of our ally, we want infinite rebuild on.
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:SetBaseInfiniteRebuild()

	-- Ensure that a core of Gauge's base will never be destroyed, in case the enemy happens to do a little too well.
	-- While the NIS units (nukes) are elsewhere and fully protected, it would look icky if Gauge got completely beat down.
	-- Just to be safe, we set these to nocap, so the player cant mess with things either.
	---NOTE: went ahead and taggedthese all as protected - not worth getting too fancy here IMO. - bfricks 6/6/09
	local unit = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_ALLY01_Factory01']
	ProtectUnit(unit)

	local unit = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_ALLY01_Shield01']
	ProtectUnit(unit)

	local unit = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_ALLY01_Tower01']
	ProtectUnit(unit)

	local unit = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_ALLY01_Tower02']
	ProtectUnit(unit)

	--# Gauge's air attack against a nearby platform.
	-- First, he *moves* to and around on the nearbyplatform, before
	-- doing a normal patrol. This is to ensure that he gets there, and stays there for a while, so that the 'distracted neighbors'
	-- dynamic will definitely happen, and stay happening for a little while. Air units have a tendency to wander off, and we want
	-- Gauge to stay in the trigger area of the system in place on the platform for a while.


	ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI		= ScenarioInfo.ArmyBase_ALLY01_Main_Base:GenerateOpAIFromPlatoonTemplate(AllyAirAttack01, 'P1_ALLY01_AirAttack_01_OpAI', {} )
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'Move', Chain = 'P1_ALLY01_AttackSequence_MoveChain_01' }, -- move around on the near platform for a while
			{ BehaviorName = 'Patrol', Chain = 'P1_ALLY01_AirAttack_Chain_01' }, -- begin normal patrol
		},
	}
	ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )

	ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI:		SetTargetArmyIndex(ARMY_ENEM01)
	ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI.		FormCallback:Add( P1_AllyPlatoonBuiltCallback )
	ScenarioInfo.P1_ALLY01_AirAttack_01_OpAI:		Disable()

	--# Normal air attack OpAI (uses normal, instead of custom move, attack. Enabled when enemy retreats)
	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI		= ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddOpAI('AirAttackCybran', 'P1_ALLY01_AirAttack_02_OpAI', {} )
	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ALLY01_AirAttack_Route03_01',},}
	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI:		EnableChildTypes( {'CybranFighterBombers'} )
	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI_Data )

	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI:		SetTargetArmyIndex(ARMY_ENEM01)
	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.P1_ALLY01_AirAttack_02_OpAI:		Disable()
end

function P1_ENEM01_AISetup()

	----------------------------------------------
	-- WEST BASE ENEMY
	----------------------------------------------

	--# West base manager
	local levelTable_ENEM01_West_Base = {
		P1_ENEM01_MainBase_West_100 = 100,
		P1_ENEM01_MainBase_West_90 = 90,
	}

	ScenarioInfo.ArmyBase_ENEM01_West_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_West_Base',
		 'P1_ENEM01_WestBase_Marker', 50, levelTable_ENEM01_West_Base)
	ScenarioInfo.ArmyBase_ENEM01_West_Base:StartNonZeroBase(3)

	--# Roving Fighter: Camp01 group replenishment OpAI
	ScenarioInfo.ENEM01_West_Rover01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_West_Rover01_OpAI', {} )
	ScenarioInfo.ENEM01_West_Rover01_OpAI_Data		= { PatrolChain = 'P1_ENEM01_MainBase_AirPatrol_01',}
	ScenarioInfo.ENEM01_West_Rover01_OpAI:			EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_West_Rover01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_West_Rover01_OpAI_Data )
	ScenarioInfo.ENEM01_West_Rover01_OpAI:			SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_West_Rover01_OpAI:			SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_West_Rover01_OpAI.			FormCallback:Add( P1_AddCamp01Platoon )
	ScenarioInfo.ENEM01_West_Rover01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Rover01_OpAI:			AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp01_Rover, false) -- dont use the platoonthread data


	--# Roving Fighter: Camp02 group replenishment OpAI
	ScenarioInfo.ENEM01_West_Rover02_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_West_Rover02_OpAI', {} )
	ScenarioInfo.ENEM01_West_Rover02_OpAI_Data		= { PatrolChain = 'P1_ENEM01_MainBase_AirPatrol_01',}
	ScenarioInfo.ENEM01_West_Rover02_OpAI:			EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_West_Rover02_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_West_Rover02_OpAI_Data )
	ScenarioInfo.ENEM01_West_Rover02_OpAI:			SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_West_Rover02_OpAI:			SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_West_Rover02_OpAI.			FormCallback:Add( P1_AddCamp02Platoon )
	ScenarioInfo.ENEM01_West_Rover02_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Rover02_OpAI:			AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp02_Rover, false) -- dont use the platoonthread data


	--# Land Defense: Camp01 OpAI
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI		= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_West_Camp01Land_OpAI', {} )
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp01_LandPatrol_01',},}
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI:		EnableChildTypes( {'IlluminateMobileAntiAir'} )
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Camp01Land_OpAI_Data )
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI:		SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Camp01Land_OpAI:		AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp01_LandDef_01, true)


	--# Land Defense: Camp02 OpAI
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI		= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_West_Camp02Land_OpAI', {} )
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp02_LandPatrol_01',},}
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI:		EnableChildTypes( {'IlluminateMobileAntiAir'} )
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Camp02Land_OpAI_Data )
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI:		SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Camp02Land_OpAI:		AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp02_LandDef_01, true)


	--# Land Attack: Camp02 OpAI
	ScenarioInfo.ENEM01_West_LandAttack_OpAI		= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_West_LandAttack_OpAI', {} )
	ScenarioInfo.ENEM01_West_LandAttack_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_West_LandPatrol',},}
	ScenarioInfo.ENEM01_West_LandAttack_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_LandAttack_OpAI_Data )
	ScenarioInfo.ENEM01_West_LandAttack_OpAI:		SetDefaultVeterancy(3)
	ScenarioInfo.ENEM01_West_LandAttack_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_LandAttack_OpAI:		Disable()


	--#Air Attack 01 OpAI: popcorn air attack against player
	ScenarioInfo.ENEM01_West_AirAttack01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_West_Base:GenerateOpAIFromPlatoonTemplate(AirAttackPlayer, 'ENEM01_West_AirAttack01_OpAI', {} )
	ScenarioInfo.ENEM01_West_AirAttack01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_02',},}
	ScenarioInfo.ENEM01_West_AirAttack01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_AirAttack01_OpAI_Data )
	ScenarioInfo.ENEM01_West_AirAttack01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.ENEM01_West_AirAttack01_OpAI:		SetAttackDelay(20)


	--#Air Attack 02 OpAI: enabled (and modified) based on triggers detecting player growth)
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI		= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_West_AirAttack02_OpAI', {} )
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_02',},}
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_AirAttack02_OpAI_Data )
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI:		SetChildCount(1)
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI:		SetAttackDelay(45)
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_West_AirAttack02_OpAI:		Disable()


	--#Assault Block OpAI, turned on when enemy pulls back to defense mode. Camp01 platform bridge.
	ScenarioInfo.ENEM01_West_Block01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('SingleUrchinowAttack', 'ENEM01_West_Block01_OpAI', {} )
	ScenarioInfo.ENEM01_West_Block01_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp01_Block_Chain',},}
	ScenarioInfo.ENEM01_West_Block01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block01_OpAI_Data )
	ScenarioInfo.ENEM01_West_Block01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Block01_OpAI.			FormCallback:Add(P1_TrackAssaultBlocks)
	ScenarioInfo.ENEM01_West_Block01_OpAI:			SetTargetArmyIndex(ARMY_PLAYER)
	ScenarioInfo.ENEM01_West_Block01_OpAI:			Disable()


	--#Assault Block OpAI, turned on when enemy pulls back to defense mode. Camp02 platform bridge.
	ScenarioInfo.ENEM01_West_Block02_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('SingleUrchinowAttack', 'ENEM01_West_Block02_OpAI', {} )
	ScenarioInfo.ENEM01_West_Block02_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp02_Block_Chain',},}
	ScenarioInfo.ENEM01_West_Block02_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block02_OpAI_Data )
	ScenarioInfo.ENEM01_West_Block02_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Block02_OpAI.			FormCallback:Add(P1_TrackAssaultBlocks)
	ScenarioInfo.ENEM01_West_Block02_OpAI:			SetTargetArmyIndex(ARMY_PLAYER)
	ScenarioInfo.ENEM01_West_Block02_OpAI:			Disable()


	--#Assault Block OpAI, turned on when enemy pulls back to defense mode. Camp03 platform bridge.
	ScenarioInfo.ENEM01_West_Block03_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('SingleUrchinowAttack', 'ENEM01_West_Block03_OpAI', {} )
	ScenarioInfo.ENEM01_West_Block03_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp03_Block_Chain',},}
	ScenarioInfo.ENEM01_West_Block03_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block03_OpAI_Data )
	ScenarioInfo.ENEM01_West_Block03_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Block03_OpAI.			FormCallback:Add(P1_TrackAssaultBlocks)
	ScenarioInfo.ENEM01_West_Block03_OpAI:			SetTargetArmyIndex(ARMY_PLAYER)
	ScenarioInfo.ENEM01_West_Block03_OpAI:			Disable()


	--#Assault Block OpAI, turned on when enemy pulls back to defense mode. Camp04 platform bridge.
	ScenarioInfo.ENEM01_West_Block04_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('SingleUrchinowAttack', 'ENEM01_West_Block04_OpAI', {} )
	ScenarioInfo.ENEM01_West_Block04_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp04_Block_Chain',},}
	ScenarioInfo.ENEM01_West_Block04_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_Block04_OpAI_Data )
	ScenarioInfo.ENEM01_West_Block04_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_Block04_OpAI.			FormCallback:Add(P1_TrackAssaultBlocks)
	ScenarioInfo.ENEM01_West_Block04_OpAI:			SetTargetArmyIndex(ARMY_PLAYER)
	ScenarioInfo.ENEM01_West_Block04_OpAI:			Disable()


	--#Post-Switch Main Base air defense (we will hand this a platoon, made from the leftover Rovers)
	ScenarioInfo.ENEM01_West_AirDef01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_West_AirDef01_OpAI', {} )
	ScenarioInfo.ENEM01_West_AirDef01_OpAI_Data		= { PatrolChain = 'P1_ENEM01_MainBase_AirPatrol_01',}
	ScenarioInfo.ENEM01_West_AirDef01_OpAI:			EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_West_AirDef01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_West_AirDef01_OpAI_Data )
	ScenarioInfo.ENEM01_West_AirDef01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_West_AirDef01_OpAI:			SetChildCount(2)
	ScenarioInfo.ENEM01_West_AirDef01_OpAI:			SetAttackDelay(45)
	ScenarioInfo.ENEM01_West_AirDef01_OpAI:			Disable()


	-- Surgical: Too many land units of some types. (exps response is handled by other base)
	ScenarioInfo.P1_ENEM01_West_PlayerExcessLand_OpAI		=  ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('AirResponsePatrolLand', 'P1_ENEM01_West_PlayerExcessLand_OpAI', {} )
	ScenarioInfo.P1_ENEM01_West_PlayerExcessLand_OpAI_Data	= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_02', },}
	ScenarioInfo.P1_ENEM01_West_PlayerExcessLand_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_West_PlayerExcessLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_West_PlayerExcessLand_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_West_PlayerExcessLand_OpAI:		SetDefaultVeterancy(5)


	-- Surgical: Too many air units
	ScenarioInfo.P1_ENEM01_West_PlayerExcessAir_OpAI			=  ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('AirResponsePatrolAir', 'P1_ENEM01_West_PlayerExcessAir_OpAI', {} )
	ScenarioInfo.P1_ENEM01_West_PlayerExcessAir_OpAI_Data	= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_02', },}
	ScenarioInfo.P1_ENEM01_West_PlayerExcessAir_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_West_PlayerExcessAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_West_PlayerExcessAir_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_West_PlayerExcessAir_OpAI:		SetDefaultVeterancy(5)

	----------------------------------------------
	-- EAST BASE ENEMY
	----------------------------------------------

	--# East base manager
	local levelTable_ENEM01_East_Base = {
		P1_ENEM01_MainBase_East_100 = 100,
		P1_ENEM01_MainBase_East_90 = 90,
	}

	ScenarioInfo.ArmyBase_ENEM01_East_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_East_Base',
		 'P1_ENEM01_EastBase_Marker', 50, levelTable_ENEM01_East_Base)
	ScenarioInfo.ArmyBase_ENEM01_East_Base:StartNonZeroBase(3)

	-- get all AA units from the the just created bases and give them a veterancy buff
	local enemyAA = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.uib0102,false)
	for k, unit in enemyAA do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 5)
	end


	--# Roving Fighter: Camp03 group replenishment OpAI
	ScenarioInfo.ENEM01_East_Rover03_OpAI			= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_East_Rover03_OpAI', {} )
	ScenarioInfo.ENEM01_East_Rover03_OpAI_Data		= { PatrolChain = 'P1_ENEM01_MainBase_AirPatrol_01',}
	ScenarioInfo.ENEM01_East_Rover03_OpAI:			EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_East_Rover03_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_East_Rover03_OpAI_Data )
	ScenarioInfo.ENEM01_East_Rover03_OpAI:			SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_East_Rover03_OpAI:			SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_East_Rover03_OpAI.			FormCallback:Add( P1_AddCamp03Platoon )
	ScenarioInfo.ENEM01_East_Rover03_OpAI:			SetMaxActivePlatoons(2) -- extra, as gauge attacks this camp platform
	ScenarioInfo.ENEM01_East_Rover03_OpAI:			AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp03a_Rover, false) -- dont use the platoonthread data
	ScenarioInfo.ENEM01_East_Rover03_OpAI:			AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp03b_Rover, false) -- dont use the platoonthread data


	--# Roving Fighter: Camp04 group replenishment OpAI
	ScenarioInfo.ENEM01_East_Rover04_OpAI			= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_East_Rover04_OpAI', {} )
	ScenarioInfo.ENEM01_East_Rover04_OpAI_Data		= { PatrolChain = 'P1_ENEM01_MainBase_AirPatrol_01',}
	ScenarioInfo.ENEM01_East_Rover04_OpAI:			EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_East_Rover04_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_East_Rover04_OpAI_Data )
	ScenarioInfo.ENEM01_East_Rover04_OpAI:			SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_East_Rover04_OpAI:			SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_East_Rover04_OpAI.			FormCallback:Add( P1_AddCamp04Platoon )
	ScenarioInfo.ENEM01_East_Rover04_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_East_Rover04_OpAI:			AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp04_Rover, false) -- dont use the platoonthread data


	--# Land Defense: Camp03 OpAI
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI		= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_East_Camp03Land_OpAI', {} )
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp03_LandPatrol_01',},}
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI:		EnableChildTypes( {'IlluminateMobileAntiAir'} )
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_East_Camp03Land_OpAI_Data )
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI:		SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_East_Camp03Land_OpAI:		AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp03_LandDef_01, true)


	--# Land Attack: Camp03 OpAI
	ScenarioInfo.ENEM01_East_LandAttack_OpAI		= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_East_LandAttack_OpAI', {} )
	ScenarioInfo.ENEM01_East_LandAttack_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_East_LandPatrol',},}
	ScenarioInfo.ENEM01_East_LandAttack_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_East_LandAttack_OpAI_Data )
	ScenarioInfo.ENEM01_East_LandAttack_OpAI:		SetDefaultVeterancy(3)
	ScenarioInfo.ENEM01_East_LandAttack_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_East_LandAttack_OpAI:		Disable()


	--# Land Defense: Camp04 OpAI
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI		= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_East_Camp04Land_OpAI', {} )
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Camp04_LandPatrol_01',},}
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI:		EnableChildTypes( {'IlluminateMobileAntiAir'} )
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_East_Camp04Land_OpAI_Data )
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI:		SetTargetArmyIndex(ARMY_ALLY01) -- we know gauge will always have factories, so set focus on him.
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_East_Camp04Land_OpAI:		AddActivePlatoon(ScenarioInfo.P1_ENEM01_Camp04_LandDef_01, true)


	--# Basic Air patrol, main base
	ScenarioInfo.ENEM01_East_AirDef01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_East_AirDef01_OpAI', {} )
	ScenarioInfo.ENEM01_East_AirDef01_OpAI_Data		= { PatrolChain = 'P1_ENEM01_MainBase_AirPatrol_01',}
	ScenarioInfo.ENEM01_East_AirDef01_OpAI:			EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_East_AirDef01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_East_AirDef01_OpAI_Data )
	ScenarioInfo.ENEM01_East_AirDef01_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.ENEM01_East_AirDef01_OpAI:			SetChildCount(2)
	ScenarioInfo.ENEM01_East_AirDef01_OpAI:			SetDefaultVeterancy(2)
	ScenarioInfo.ENEM01_East_AirDef01_OpAI:			AddActivePlatoon(ScenarioInfo.P1_MainBase_AirPatrol, true)


	--#Air Attack 01 against Gauge OpAI
	ScenarioInfo.ENEM01_East_AirAttack01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_East_AirAttack01_OpAI', {} )
	ScenarioInfo.ENEM01_East_AirAttack01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_03',},}
	--ScenarioInfo.ENEM01_East_AirAttack01_OpAI:		EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_East_AirAttack01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_East_AirAttack01_OpAI_Data )
	ScenarioInfo.ENEM01_East_AirAttack01_OpAI:		SetTargetArmyIndex(ARMY_ALLY01)
	ScenarioInfo.ENEM01_East_AirAttack01_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.ENEM01_East_AirAttack01_OpAI:		SetChildCount(1)


	--#Air Attack 02 OpAI: popcorn air attack against Gauge
	ScenarioInfo.ENEM01_East_AirAttack02_OpAI		= ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(AirAttackGauge, 'ENEM01_East_AirAttack02_OpAI', {} )
	ScenarioInfo.ENEM01_East_AirAttack02_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_03',},}
	ScenarioInfo.ENEM01_East_AirAttack02_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_East_AirAttack02_OpAI_Data )
	ScenarioInfo.ENEM01_East_AirAttack02_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.ENEM01_East_AirAttack02_OpAI:		SetTargetArmyIndex(ARMY_ALLY01)


	-- Surgical: Player builds powerful individual land units (excess land/air handled by other base)
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulLand_OpAI		=  ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('AirResponseTargetLand', 'P1_ENEM01_East_PlayerPowerfulLand_OpAI', {} )
	local P1_ENEM01_East_PlayerPowerfulLand_OpAI_Data		= {
    											    			PatrolChain = 'P1_ENEM01_AirAttack_02',
    											    			CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_EastBase_Marker' ),
    											    			CategoryList = {
    											    			    (categories.EXPERIMENTAL * categories.LAND) - categories.uix0113, -- minus Teleporter.
    											    			    categories.uub0105,	-- artillery
    											    			    categories.ucb0105,	-- artillery
    											    			    categories.NUKE,
    											   		 		},
    														}
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulLand_OpAI:	SetPlatoonThread( 'CategoryHunter', P1_ENEM01_East_PlayerPowerfulLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulLand_OpAI:	SetChildCount(2)
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulLand_OpAI:	SetDefaultVeterancy(5)


	-- Surgical: Player builds air experimentals
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulAir_OpAI		=  ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('AirResponseTargetAir', 'P1_ENEM01_East_PlayerPowerfulAir_OpAI', {} )
	local P1_ENEM01_East_PlayerPowerfulAir_OpAI_Data			= {
    															PatrolChain = 'P1_ENEM01_AirAttack_02',
    															CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_EastBase_Marker' ),
    															CategoryList = {
    															    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    															},
    														}
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulAir_OpAI:		SetPlatoonThread( 'CategoryHunter', P1_ENEM01_East_PlayerPowerfulAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulAir_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_East_PlayerPowerfulAir_OpAI:		SetDefaultVeterancy(5)
end

function P1_StrengthenEnemyAttacks()
	LOG('----- P1: Increasing enemy air attacks')

	-- Change the enemy main attacks: first enable the attacks, then increase the size, then add another route the attacks can use.
	EnemyAirAttackCounter = EnemyAirAttackCounter + 1
	if EnemyAirAttackCounter == 1 then
		ScenarioInfo.ENEM01_West_AirAttack01_OpAI:		SetChildCount(4)
	elseif EnemyAirAttackCounter == 2 then
		ScenarioInfo.ENEM01_West_AirAttack02_OpAI:Enable()
	elseif EnemyAirAttackCounter == 3 then
		ScenarioInfo.ENEM01_West_AirAttack02_OpAI:SetChildCount(2)
		ScenarioInfo.ENEM01_West_AirAttack02_OpAI_Data = {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_02', 'P1_ENEM01_AirAttack_02',},}
		ScenarioInfo.ENEM01_West_AirAttack02_OpAI:SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_West_AirAttack02_OpAI_Data )
		ScenarioInfo.ENEM01_West_AirAttack02_OpAI:SetDefaultVeterancy(4)
	end
end

function P1_TrackAssaultBlocks(platoon)
	LOG('----- P1: Adding assault block platoon to list (form callback)')

	-- Add assault block platoons to a list, which we will use later for a mass-move of them
	-- in response to the player getting deep into the middle of the enemy base
	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		table.insert(ScenarioInfo.P1_EnemyAssaultBlockPlatoons, platoon)
	end
end

function CreateObjectiveTarget()
	ScenarioInfo.P1_ENEM01_Objective_Structure = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Objective_Structure')
	ScenarioInfo.P1_ENEM01_Objective_Structure:SetCustomName(ScenarioGameNames.UNIT_SCB2501)
	ScenarioInfo.P1_ENEM01_Objective_Structure:SetMaxHealth(ObjectiveTargetHealth)
	ScenarioInfo.P1_ENEM01_Objective_Structure:AdjustHealth(ScenarioInfo.P1_ENEM01_Objective_Structure, ObjectiveTargetHealth)
	ScenarioInfo.P1_ENEM01_Objective_Structure:SetCapturable(false)

	-- depricating ogrid blocker - bfricks 1/8/10
	-- create our path-blocking hoo-ha
	--ScenarioFramework.CreateOGridBlockers(ScenarioInfo.P1_ENEM01_Objective_Structure,'O_GRID_BLOCKERS', 'ARMY_ENEM01')
end

---------------------------------------------------------------------
-- GENERAL USE FUNCTIONS FOR OPERATION:
---------------------------------------------------------------------
function RandomPatrolThread(platoon, chain)
	-- Give members of a platoon a random patrol using the points of a chain.
	if(platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon)) then
		for k, v in platoon:GetPlatoonUnits() do
			IssueClearCommands({v})
			ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(chain))
		end
	end
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function LaunchVictoryNIS(unit)
	-- disable all base managers before victory NIS starts
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:BaseActive(false)
	ScenarioInfo.ArmyBase_ENEM01_West_Base:BaseActive(false)
	ScenarioInfo.ArmyBase_ENEM01_East_Base:BaseActive(false)

	ForkThread(OpNIS.NIS_VICTORY, unit)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	import('/lua/system/Utilities.lua').UserConRequest('SallyShears')
	import('/lua/system/Utilities.lua').UserConRequest('dbg collision')
	import('/lua/system/Utilities.lua').UserConRequest('ren_SelectionMeshes')
	CreateObjectiveTarget()
end

function OnShiftF4()
	LaunchVictoryNIS(ScenarioInfo.P1_ENEM01_Objective_Structure)
end

function TEST_NukeNis()
end
