---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_C06/SC2_CA_C06_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_C06/SC2_CA_C06_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_C06/SC2_CA_C06_OpNIS.lua')
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
local ArtifactUtils			= import('/lua/sim/ScenarioFramework/ScenarioGameUtilsArtifact.lua')

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
ScenarioInfo.ARMY_ART = 3

ScenarioInfo.AssignedObjectives = {}
ScenarioInfo.AllowEvaluationThread	= true

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ART = ScenarioInfo.ARMY_ART

local WestCoilsDestroyed = 0
local EastCoilsDestroyed = 0
local NumCoilsDestroyed = 0
local SpottedUnits = 0

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------

-- Unit-type weighting values, for event checks.
local P1_Player_ShieldWeight 		= 6
local P1_Player_PointDefWeight 		= 3
local P1_Player_ExperimentalWeight 	= 35
local P1_Player_ExperMiniWeight 	= 18
local P1_Player_MobLandWeight 		= 1
local P1_Player_GunshipWeight 		= 3
local P1_Player_BomberWeight 		= 2
local P1_Player_Naval1Weight		= 5
local P1_Player_Naval2Weight		= 10

-- OpAI enables and updates: maximum time (with a few '*' expceptions) for these events to happen
-- (adaptivity may have them happen sooner).
-- Using N * 60 because Im tired of trying to envision a 45 minute sequence in seconds. Stop laughing!!@
-- "--&&" indicates an event whose absence Im testing.
local West_EnableBasicLandAttacks_Delay		= 1.5						* 60 -- *
local East_EnableBasicLandAttacks_Delay		= 5						* 60 -- *
local West_EnableCapture_Delay				= 10					* 60
local West_EnableMegalith_Delay       		= 15.3					* 60
local West_EnableAirnomo_Delay				= 8.5						* 60
--&& local West_EnableColossus_Delay       		= 35						* 60
--&& local West_EnableExpansionBase_Delay		= 24					* 60 -- *

local East_EnableCapture_Delay        		= 15					* 60
local East_EnableMegalith_Delay       		= 18.2					* 60
local East_EnableAirnomo_Delay				= 19					* 60
local East_EnableColossus_Delay       		= 26					* 60
local East_EnableExpansionBase_Delay		= 18					* 60 -- *

local Main_EnableAirAttacks_Delay			= 5						* 60
local Main_EnableTransAttack_Delay    		= 20					* 60
local Main_TransAttackUpdated_Delay   		= 33					* 60
local Main_EnableSoulRipper_Delay     		= 41					* 60
local Main_EnableDarkenoid_Delay      		= 47					* 60

ScenarioInfo.P1_CaptureOpAIDelay_West 		= 20
ScenarioInfo.P1_CaptureOpAIDelay_East 		= 20


---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.35,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.C06_PLAYER, P1_HiddenObj1Complete)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.C06_ARMY_ENEM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ART,		ScenarioGameTuning.C06_ARMY_ART)

	-- One-off, give leg walking, as we start the player with land destros.
	ArmyBrains[ARMY_PLAYER]:CompleteResearch({'CSP_LANDWALKING'})

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
	ScenarioInfo.PLAYER_CDR = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_CDR')
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Ivan)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Create units to blow up
	ScenarioInfo.GuardianACUs = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'GuardianACUs')
	ScenarioInfo.BlowUps = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'BlowUps')

	-- Create player starting units peice by piece, for NIS use.
	-- Engineers
	ScenarioInfo.PLAYER_Engineer01 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_Engineer_01')
	ScenarioInfo.PLAYER_Engineer02 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_Engineer_02')
	ScenarioInfo.PLAYER_Engineer03 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_Engineer_03')

	-- Two groups (upper 01 and lower 02), devided into a front and back portion (back contains some shield and mob aa)
	ScenarioInfo.PLAYER_Group01_Front = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_InitLand_01_Front')
	ScenarioInfo.PLAYER_Group01_Back = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_InitLand_01_Back')
	ScenarioInfo.PLAYER_Group02_Front = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_InitLand_02_Front')
	ScenarioInfo.PLAYER_Group02_Back = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_InitLand_02_Back')

	-- Destroyers
	ScenarioInfo.PLAYER_InitLand_Destro_01 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_InitLand_Destro01')
	ScenarioInfo.PLAYER_InitLand_Destro_02 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_InitLand_Destro02')

	---------------
	-- Artifact Setup
	---------------

	-- Set up Artifact units: add them to a table to pass to the objective system,
	-- and add a death trigger to each set (east and west) which will enable/disable
	-- a reinforcement OpAI for the coils' areas.
	ScenarioInfo.ArtifactPowerCoils = {}
	for i = 1, 2 do
		local unit01 = ScenarioUtils.CreateArmyUnit('ARMY_ART', 'P1_ART_WestCoil_0' .. i)
		table.insert(ScenarioInfo.ArtifactPowerCoils, unit01)
		ScenarioFramework.CreateUnitDeathTrigger( P1_WestCoilDestroyed, unit01)
		ScenarioGameEvents.SetupUnitForControlledDeath(unit01, HandleCoilDestructionForNIS)	--Added for NIS
		unit01:SetCustomName(ScenarioGameNames.UNIT_SCB3601)
		AddCoilDamagedVOTrigger(unit01)


		local unit02 = ScenarioUtils.CreateArmyUnit('ARMY_ART', 'P1_ART_EastCoil_0' .. i)
		table.insert(ScenarioInfo.ArtifactPowerCoils, unit02)
		ScenarioFramework.CreateUnitDeathTrigger( P1_EastCoilDestroyed, unit02)
		ScenarioGameEvents.SetupUnitForControlledDeath(unit02, HandleCoilDestructionForNIS)	--Added for NIS
		unit02:SetCustomName(ScenarioGameNames.UNIT_SCB3601)
		AddCoilDamagedVOTrigger(unit02)
	end

	-- Set up the drone launchers, set them as invuln.
	ScenarioInfo.P1_DroneLauncherTable = {}
	for i = 1, 2 do
		for j = 1, 3 do
			local unit = ScenarioUtils.CreateArmyUnit('ARMY_ART', 'P1_ART_EastCoilLauncher_0' .. i .. '_0' .. j)
			table.insert(ScenarioInfo.P1_DroneLauncherTable, unit)
			ProtectUnit(unit)
			unit:SetUnSelectable(true)
		end
	end
	for i = 1, 2 do
		for j = 1, 3 do
			local unit = ScenarioUtils.CreateArmyUnit('ARMY_ART', 'P1_ART_WestCoilLauncher_0' .. i .. '_0' .. j)
			table.insert(ScenarioInfo.P1_DroneLauncherTable, unit)
			ProtectUnit(unit)
			unit:SetUnSelectable(true)
		end
	end

	---------------
	-- Gauge Setup
	---------------
	ScenarioInfo.GAUGE_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'GAUGE_CDR')
	ScenarioInfo.GAUGE_CDR:SetCustomName(ScenarioGameNames.CDR_Gauge)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.GAUGE_CDR, 5)

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.GAUGE_CDR:RemoveCommandCap('RULEUCC_Reclaim')

	-- CDR death damage triggers
	ScenarioFramework.CreateUnitDeathTrigger(GAUGE_CDR_DeathDamage, ScenarioInfo.GAUGE_CDR)

	---NOTE: restrict damage on gauge - above and independent of how we do the shielding field - bfricks 11/15/09
	---			and remember - we should NOT try and protect Gauge - or do anything that will conflict with his special death NIS handling
	ScenarioInfo.GAUGE_CDR:SetCanTakeDamage(false)

	-- Intel for gauge
	ScenarioFramework.CreateIntelAtLocation(480, 'GaugeIntelMarker', ARMY_ENEM01, 'Radar')

	--# Intro Attack: some for the NIS, some for after.
	ScenarioInfo.P1_InitialAttackTable = {}
	local platoon
	for i = 1, 4 do
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_IntroAttack_East_0' .. i , 'AttackFormation')
		table.insert(ScenarioInfo.P1_InitialAttackTable, platoon)
		platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_IntroAttack_West_0' .. i , 'AttackFormation')
		table.insert(ScenarioInfo.P1_InitialAttackTable, platoon)
	end
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_IntroAttack_Exp_01', 'AttackFormation')
	table.insert(ScenarioInfo.P1_InitialAttackTable, platoon)
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_IntroAttack_Mid_01', 'AttackFormation')
	table.insert(ScenarioInfo.P1_InitialAttackTable, platoon)

	-- Set up Gauge's bases and AI
	P1_AISeteup_EnemMain()
	P1_AISeteup_EnemSideWest()
	P1_AISeteup_EnemSideEast()
	P1_AISeteup_EnemFront()

	-- Now that Gauge's base is created, tell all of his factories to build an AA and Shield add on. MUST HAPPEN *AFTER* BASE
	-- CREATION ABOVE.
	local factories = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.ucb0001 + categories.ucb0002, false )
	for k, v in factories do
		if v and not v:IsDead() then
			IssueBuildFactory( {v}, 'ucm0121', 1 )
			IssueBuildFactory( {v}, 'ucm0211', 1 )
		end
	end

	-- Create a big wodge of Experimentals in Gauge's main backbase, who will hang out until a big final attack.
	ScenarioInfo.ExperimentalTrainPlatoonList = {}
	for i = 1, 2 do
		for j = 1, 3 do
			local platoon = import('/lua/sim/ScenarioUtilities.lua').CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_ExpGroup_' .. i .. '_0' .. j, 'AttackFormation')
			table.insert(ScenarioInfo.ExperimentalTrainPlatoonList, platoon)
		end
	end

	-- some defense at 2 of the coils
	local defenses = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_OuterStructures')
	ScenarioFramework.SetGroupVeterancyLevel(defenses, 5)

	-- Now that we have created Gauges units, turn on invulnerability for units in his main base. NOTE: this ignores Gauge himself
	-- since we want to manually protect him (because we are paranoid). Also, this must take place after the enemy has been created (for now).
	P1_GaugeUnitsInvuln()
end

function P1_Main()
	LOG('----- P1_Main: ')
	-- begin the thread that continues to evauluate how the player is doing
	ForkThread(EvaluatePlayerStrength_Thread)

	-- post-nis patrol for Gauge.
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.GAUGE_CDR}, ScenarioUtils.ChainToPositions('P1_ENEM01_GaugePatrol'))

	-- Timer triggers or EvaluatePlayerStrength_Thread will call these OpAI update functions, whichever gets there
	-- first. These timer triggers represent the longest wait we will allow for these events to take place. ( the string being
	-- sent is purely for debug/log purposes).
	-- However, note the 3 exceptions, which set a flag that is required for a particular event to take place. In these
	-- cases, this timer represents the *minimum* time before the event is allowed to take place.
	ScenarioFramework.CreateTimerTrigger (function() West_EnableCapture('timer') end, 		West_EnableCapture_Delay)
	ScenarioFramework.CreateTimerTrigger (function() West_EnableMegalith('timer') end,		West_EnableMegalith_Delay)
	ScenarioFramework.CreateTimerTrigger (function() West_EnableAirnomo('timer') end,		West_EnableAirnomo_Delay)
--&&	ScenarioFramework.CreateTimerTrigger (function() West_EnableColossus('timer') end,		West_EnableColossus_Delay)
	ScenarioFramework.CreateTimerTrigger (function() West_EnableBasicLandAttacks('timer') end,	West_EnableBasicLandAttacks_Delay)
--&&	ScenarioFramework.CreateTimerTrigger (West_EnableExpansionBase_Timer,					West_EnableExpansionBase_Delay)

	ScenarioFramework.CreateTimerTrigger (function() East_EnableCapture('timer') end,		East_EnableCapture_Delay)
	ScenarioFramework.CreateTimerTrigger (function() East_EnableMegalith('timer') end,		East_EnableMegalith_Delay)
	ScenarioFramework.CreateTimerTrigger (function() East_EnableAirnomo('timer') end,		East_EnableAirnomo_Delay)
	ScenarioFramework.CreateTimerTrigger (function() East_EnableColossus('timer') end,		East_EnableColossus_Delay)
	ScenarioFramework.CreateTimerTrigger (East_EnableBasicLandAttacks_Timer,				East_EnableBasicLandAttacks_Delay)
	ScenarioFramework.CreateTimerTrigger (East_EnableExpansionBase_Timer,					East_EnableExpansionBase_Delay)

	ScenarioFramework.CreateTimerTrigger (function() Main_EnableAirAttacks('timer') end,	Main_EnableAirAttacks_Delay)
	ScenarioFramework.CreateTimerTrigger (function() Main_EnableTransAttack('timer') end,	Main_EnableTransAttack_Delay)
	ScenarioFramework.CreateTimerTrigger (function() Main_TransAttackUpdated('timer') end,  Main_TransAttackUpdated_Delay)
	ScenarioFramework.CreateTimerTrigger (function() Main_EnableSoulRipper('timer') end,    Main_EnableSoulRipper_Delay)
	ScenarioFramework.CreateTimerTrigger (function() Main_EnableDarkenoid('timer') end,     Main_EnableDarkenoid_Delay)

	-- Assign objectives: Pri-Defeat Gauge, 2ndry-Destroy Defense System
	P1_AssignMainObjectives()

	-- after a brief pause, send in the initial attack stream
	ScenarioFramework.CreateTimerTrigger (P1_MoveInitialAttackers, 3)

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 25)

	-- Hidden objective: complete op with no experimentals.
	ScenarioFramework.CreateArmyStatTrigger (P1_HiddenObj2_Flag, ArmyBrains[ARMY_PLAYER], 'HiddenObj2_DetectExp',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL}})

	-- Delay the front mini-base's attack opai, so there is a brief lull after the initial attack wave and standard attacks.
	ScenarioFramework.CreateTimerTrigger (function() ScenarioInfo.P1_ENEM01_Front_LandAttack_01_OpAI:Enable() end, 120)

	-- Set up the sundry VO events that take place. There's a lot of them, so we'll keep them below in their own function for neatness.
	P1_SetupVOTriggers()
end

function P1_MoveInitialAttackers()
	-- Send in the waiting initial attackers.
	for k, platoon in ScenarioInfo.P1_InitialAttackTable do
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_IntroAttack_LandChain')
		end
	end
end

function P1_WestCoilDestroyed()
	-- Called by coil death triggers. When one is destroyed, turn on a reinforcement OpAI.
	-- But when the second (ie, the final one) is destroyed, turn that OpAI back off.
	WestCoilsDestroyed = WestCoilsDestroyed + 1
	if WestCoilsDestroyed == 1 then
		LOG('----- West Coil: enabling reinforcement OpAI.')
		-- In case the transport pool opai hasnt been turned on, do so
		ScenarioInfo.P1_ENEM01_Main_Transports:Enable()
		ScenarioInfo.P1_ENEM01_Main_TransWestCoil_01_OpAI:Enable()
	else
		LOG('----- West Coil: disabling reinforcement OpAI.')
		ScenarioInfo.P1_ENEM01_Main_TransWestCoil_01_OpAI:Disable()
	end
end

function P1_EastCoilDestroyed()
	-- Called by coil death triggers. When one is destroyed, turn on a reinforcement OpAI.
	-- But when the second (ie, the final one) is destroyed, turn that OpAI back off.
	EastCoilsDestroyed = EastCoilsDestroyed + 1
	if EastCoilsDestroyed == 1 then
		LOG('----- East Coil: enabling reinforcement OpAI.')
		-- In case the transport pool opai hasnt been turned on, do so
		ScenarioInfo.P1_ENEM01_Main_Transports:Enable()
		ScenarioInfo.P1_ENEM01_Main_TransEastCoil_01_OpAI:Enable()
	else
		LOG('----- East Coil: disabling reinforcement OpAI.')
		ScenarioInfo.P1_ENEM01_Main_TransEastCoil_01_OpAI:Disable()
	end
end

function P1_DisableWestAirDefense()
	LOG('----- P1: West base factories destroyed, disabling air cover OpAI from Main base')
	ScenarioFramework.Dialogue(OpDialog.C06_BASE_01_DESTROYED)

	-- The factory-type units of the West side base have been destroyed. So, disable
	-- the Main base OpAI that sends air patrols to the west.
	ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI:Disable()
end

function P1_DisableEastAirDefense()
	LOG('----- P1: East base factories destroyed, disabling air cover OpAI from Main base')
	ScenarioFramework.Dialogue(OpDialog.C06_BASE_02_DESTROYED)

	-- The factory-type units of the East side base have been destroyed. So, disable
	-- the Main base OpAI that sends air patrols to the east.
	ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI:Disable()
end

function P1_GaugeNukesCoils_Thread()
	LOG('----- P1_GaugeNukesCoils_Thread:')

	-- Gauge nukes the two areas that are sending drones to him. Delay between, just for look/feel.
	if ScenarioInfo.P1_ENEM01_GaugeNukeWest and not ScenarioInfo.P1_ENEM01_GaugeNukeWest:IsDead() and not ScenarioInfo.VictoryStarted then
		ScenarioInfo.P1_ENEM01_GaugeNukeWest:GiveNukeSiloAmmo(1)
		local westPos = ScenarioUtils.MarkerToPosition('P1_ENEM01_GaugeWestCoil_NukeSpot_01')
		IssueNuke({ScenarioInfo.P1_ENEM01_GaugeNukeWest}, westPos)
	end

	WaitSeconds(4)

	if ScenarioInfo.P1_ENEM01_GaugeNukeEast and not ScenarioInfo.P1_ENEM01_GaugeNukeEast:IsDead() and not ScenarioInfo.VictoryStarted then
		ScenarioInfo.P1_ENEM01_GaugeNukeEast:GiveNukeSiloAmmo(1)
		local eastPos = ScenarioUtils.MarkerToPosition('P1_ENEM01_GaugeEastCoil_NukeSpot_01')
		IssueNuke({ScenarioInfo.P1_ENEM01_GaugeNukeEast}, eastPos)
	end

	WaitSeconds(10)

	if ScenarioInfo.P1_ENEM01_GaugeNukeWest and not ScenarioInfo.P1_ENEM01_GaugeNukeWest:IsDead() and not ScenarioInfo.VictoryStarted then
		ScenarioInfo.P1_ENEM01_GaugeNukeWest:GiveNukeSiloAmmo(1)
		local westPos = ScenarioUtils.MarkerToPosition('P1_ENEM01_GaugeWestCoil_NukeSpot_02')
		IssueNuke({ScenarioInfo.P1_ENEM01_GaugeNukeWest}, westPos)
	end

	WaitSeconds(4)

	if ScenarioInfo.P1_ENEM01_GaugeNukeEast and not ScenarioInfo.P1_ENEM01_GaugeNukeEast:IsDead() and not ScenarioInfo.VictoryStarted then
		ScenarioInfo.P1_ENEM01_GaugeNukeEast:GiveNukeSiloAmmo(1)
		local westPos = ScenarioUtils.MarkerToPosition('P1_ENEM01_GaugeEastCoil_NukeSpot_02')
		IssueNuke({ScenarioInfo.P1_ENEM01_GaugeNukeEast}, westPos)
	end
end


---------------------------------------------------------------------
-- VO AND OBJECTIVE FUNCTIONS:
---------------------------------------------------------------------

function P1_AssignMainObjectives()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Defeat Gauge
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Defeat Gauge.')
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',						-- type
		'incomplete',					-- status
		OpStrings.C06_M1_obj10_NAME,	-- title
		OpStrings.C06_M1_obj10_DESC,	-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.GAUGE_CDR},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	-- setup Gauge for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.GAUGE_CDR, LaunchVictoryNIS)

	----------------------------------------------
	-- Secondary Objective S2_obj10 - Destroy the Defense System
	----------------------------------------------
	LOG('----- P1_Main: Assign Secondary Objective S1_obj10 -  Destroy the Defense System.')
	local descText = OpStrings.C06_S1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C06_S1_obj10_KILL_COIL4)
	ScenarioInfo.S1_obj10 = SimObjectives.KillOrCapture(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.C06_S1_obj10_NAME,	-- title
		descText,						-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			AlwaysVisible = true,
			ArrowOffset = 0.0,
			ArrowSize = 0.1,
			Units = ScenarioInfo.ArtifactPowerCoils,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)
	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				---NOTE: Gauge can not be unprotected - it will break the functionality of his death NIS
				---			instead we must simply remove the damage and targeting restrictions - bfricks 11/15/09
				ScenarioInfo.GAUGE_CDR:SetCanTakeDamage(true)
			end
		end
	)

	ScenarioInfo.S1_obj10:AddProgressCallback(
		function(current)
			if current == 1 then
				-- shift land attacks from main route to coil-area routes.
				LandAttackRoutesChange()
			elseif current == 2 then
				ScenarioFramework.Dialogue(OpDialog.C06_COIL_DESTROYED_020)
			elseif current == 3 then
				ScenarioFramework.Dialogue(OpDialog.C06_COIL_DESTROYED_030)
				ScenarioFramework.Dialogue(OpDialog.C06_GAUGE_COIL_BANTER_020)
			end
		end
	)
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.C06_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.C06_S2_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S2_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.C06_S2_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj10)

	ScenarioInfo.S2_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.C06_RESEARCH_FOLLOWUP_CREX_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 300)
end

function ResearchReminder1()
	if ScenarioInfo.S2_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.C06_RESEARCH_REMINDER_010)
	end
end
function P1_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Research Savant
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H1_obj10 - Research Savant')
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.C06_H1_obj10_NAME,			-- title
		OpStrings.C06_H1_obj10_DESC,			-- description
		SimObjectives.GetActionIcon('capture'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)
end

function P1_HiddenObj2Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Master of Pawns
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H2_obj10 - Master of Pawns')
	ScenarioInfo.H2_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.C06_H2_obj10_NAME,			-- title
		OpStrings.C06_H2_obj10_DESC,			-- description
		SimObjectives.GetActionIcon('protect'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H2_obj10)
end

function P1_HiddenObj2_Flag()
	LOG('----- Player built an experimental. Related hiddon obj will not pass.')
	ScenarioInfo.HiddenObj_PlayerBuiltExp = true
end

---------------------------------------------------------------------
-- AI SETUP AND RELATED FUNCTIONS:
---------------------------------------------------------------------

function P1_AISeteup_EnemMain()

	----------------------------------------------
	--Enemy Main/Back Base:
	----------------------------------------------

	--# Main base setup
	local levelTable_ENEM01_Main_Base 	= { ENEM01_MainBase_100 = 100,
											ENEM01_MainBase_90 = 90,
											ENEM01_MainBase_80 = 80,
											ENEM01_MainBase_70Towers = 70,
											ENEM01_MainBase_60 = 60,
											ENEM01_MainBase_50 = 50, }
	ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P1_ENEM01_Main_Base',
		 'P1_ENEM01_MainBase_Marker', 130, levelTable_ENEM01_Main_Base)
	ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:StartNonZeroBase(2)
	ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:SetBaseInfiniteRebuild()

	-- Make some defenses be particularly powerful.
	local towers = GetUnitsFromFolder({'ENEM01_MainBase_70Towers'})
	for k, v in towers do
		if v and not v:IsDead() then
			ScenarioFramework.SetUnitVeterancyLevel(v, 5)
		end
	end

	-- Get a handle to Gauge's two nuke launchers.
	ScenarioInfo.P1_ENEM01_GaugeNukeWest = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_GaugeNukeWest']
	ScenarioInfo.P1_ENEM01_GaugeNukeEast = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_GaugeNukeEast']


	---------------
	-- General OpAI's
	---------------

	--# basic air attack against player
	ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirAttackCybran', 'P1_ENEM01_Main_AirAttack_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_AirAttack_01_Chain', 'P1_ENEM01_Main_AirAttack_02_Chain',},}
	ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:		SetAttackDelay(40)
	ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:		Disable()


	--# Defense Air patrols, Main base
	ScenarioInfo.P1_ENEM01_Main_BaseDefAir_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirFightersCybran', 'P1_ENEM01_Main_BaseDefAir_OpAI', {} )
	local P1_ENEM01_Main_BaseDefAir_OpAI_Data			= {PatrolChain = 'P1_ENEM01_Main_AirDefense_Chain',}
	ScenarioInfo.P1_ENEM01_Main_BaseDefAir_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', P1_ENEM01_Main_BaseDefAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_BaseDefAir_OpAI:		SetDefaultVeterancy(4)
	ScenarioInfo.P1_ENEM01_Main_BaseDefAir_OpAI:		SetChildCount(7) -- Size of each platoon
	ScenarioInfo.P1_ENEM01_Main_BaseDefAir_OpAI:		SetMaxActivePlatoons(2)


	--# Defense Air patrols, West side base				(main base provides air cover for West)
	ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirFightersCybran', 'P1_ENEM01_Main_WestDefAir_OpAI', {} )
	local P1_ENEM01_Main_WestDefAir_OpAI_Data			= {PatrolChain = 'P1_ENEM01_West_AirDefense_Chain',}
	ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', P1_ENEM01_Main_WestDefAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI:		SetDefaultVeterancy(3)
	ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI:		SetChildCount(6) -- Size of each platoon
	ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI:		AdjustPriority(-1) -- dont want the side bases impeding platoon building at main


	--# Defense Air patrols, East side base 			(main base provides air cover for East)
	ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirFightersCybran', 'P1_ENEM01_Main_EastDefAir_OpAI', {} )
	local P1_ENEM01_Main_EastDefAir_OpAI_Data			= {PatrolChain = 'P1_ENEM01_East_AirDefense_Chain',}
	ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', P1_ENEM01_Main_EastDefAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI:		SetDefaultVeterancy(3)
	ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI:		SetChildCount(6) -- Size of each platoon
	ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI:		AdjustPriority(-1) -- dont want the side bases impeding platoon building at main

	---------------
	-- Transport OpAI's
	---------------

	--# keep the transport pool stocked with transports
    ScenarioInfo.P1_ENEM01_Main_Transports 				= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('TransportsCybran', 'P1_ENEM01_Main_Transports', {} )
    local transportData 								= { TransportMoveLocation = 'P1_ENEM01_Main_TransportRally', }
    ScenarioInfo.P1_ENEM01_Main_Transports:				SetPlatoonThread( 'TransportPool', transportData)
    ScenarioInfo.P1_ENEM01_Main_Transports:				SetDefaultVeterancy(2)
    ScenarioInfo.P1_ENEM01_Main_Transports:				SetAttackDelay(30) -- TransportsCybran is max priority, so we need a break for other opais to get some time in.
    ScenarioInfo.P1_ENEM01_Main_Transports:				Disable()


	-- general trans attack data
    ScenarioInfo.P1_ENEM01_TransAttack01_Data = {
        PatrolChain  = 'P1_ENEM01_PlayerArea_Trans_PatrolChain_01',
        LandingChain = 'P1_ENEM01_PlayerArea_LandingChain01',
        TransportReturn = 'P1_ENEM01_Main_TransportRally',
    }

	-- reinforcements to west coil, transport data
    ScenarioInfo.P1_ENEM01_TransWestCoil01_Data = {
        PatrolChain  = 'P1_ENEM01_WestCoil_Trans_PatrolChain_01',
        LandingList  = {'P1_ENEM01_WestCoil_Trans_LandingPoint',},
        TransportReturn = 'P1_ENEM01_Main_TransportRally',
    }

	-- reinforcements to east coil, transport data
    ScenarioInfo.P1_ENEM01_TransEastCoil01_Data = {
        PatrolChain  = 'P1_ENEM01_EastCoil_Trans_PatrolChain_01',
        LandingList  = {'P1_ENEM01_EastCoil_Trans_LandingPoint',},
        TransportReturn = 'P1_ENEM01_Main_TransportRally',
    }

	-- transported capture engineers, transport data and child
    ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI_Data = {
        LandingChain  = 'P1_ENEM01_PlayerArea_LandingChain02',
        CaptureChain  = 'zz_SUBCHAIN_PlayerBaseArea_ForLand_Rear',
        CaptureRadius = 20,
        AnnounceRoute = true,
        TransportReturn = 'P1_ENEM01_Main_TransportRally',
    }

	local captureChild = {
		'ENEM01_MainCaptureEngineer_Child',
		{
			{ 'ucl0002', 6 },
		},
	}

	--# Basic land assault with transport, to player base area
	ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('LandAttackCybran', 'P1_ENEM01_Main_TransAttack_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI:		SetPlatoonThread( 'LandAssaultWithTransports', ScenarioInfo.P1_ENEM01_TransAttack01_Data )
	ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI:		SetAttackDelay(100)
	ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI:		Disable()


	--# Reinforce West power coil area
	ScenarioInfo.P1_ENEM01_Main_TransWestCoil_01_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('LandAttackCybran', 'P1_ENEM01_Main_TransWestCoil_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Main_TransWestCoil_01_OpAI:		SetPlatoonThread( 'LandAssaultWithTransports', ScenarioInfo.P1_ENEM01_TransWestCoil01_Data )
	ScenarioInfo.P1_ENEM01_Main_TransWestCoil_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Main_TransWestCoil_01_OpAI:		AdjustPriority(1) --This opai only lasts for a period, so lets make it count.
	ScenarioInfo.P1_ENEM01_Main_TransWestCoil_01_OpAI:		Disable()


	--# Reinforce East power coil area
	ScenarioInfo.P1_ENEM01_Main_TransEastCoil_01_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('LandAttackCybran', 'P1_ENEM01_Main_TransEastCoil_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Main_TransEastCoil_01_OpAI:		SetPlatoonThread( 'LandAssaultWithTransports', ScenarioInfo.P1_ENEM01_TransEastCoil01_Data )
	ScenarioInfo.P1_ENEM01_Main_TransEastCoil_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Main_TransEastCoil_01_OpAI:		AdjustPriority(1) --This opai only lasts for a period, so lets make it count.
	ScenarioInfo.P1_ENEM01_Main_TransEastCoil_01_OpAI:		Disable()


	--# Capture Engineers to player area
	ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:GenerateOpAIFromPlatoonTemplate(captureChild, 'P1_ENEM01_Main_TransCapEng_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI:		SetPlatoonThread( 'CaptureRouteWithTransports', ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI.		FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI:		SetAttackDelay(120)
	ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI:		SetChildCount(1)
	ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI:		Disable()


	---------------
	-- Experimental OpAI's
	---------------

	--# SoulRipper OpAI
	ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI				= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('SingleSoulRipperAttack', 'P1_ENEM01_Main_SoulRipper_OpAI', {} )
	local P1_ENEM01_Main_SoulRipper_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_AirAttack_01_Chain', 'P1_ENEM01_Main_AirAttack_02_Chain',},}
	ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_Main_SoulRipper_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:			SetAttackDelay(50)
	ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:			Disable()


	--# Darkenoid OpAI
	ScenarioInfo.P1_ENEM01_Main_Darkenoid_OpAI				= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('SingleDarkenoidAttack', 'P1_ENEM01_Main_Darkenoid_OpAI', {} )
	local P1_ENEM01_Main_Darkenoid_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_AirAttack_01_Chain', 'P1_ENEM01_Main_AirAttack_02_Chain',},}
	ScenarioInfo.P1_ENEM01_Main_Darkenoid_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_Main_Darkenoid_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_Darkenoid_OpAI:				SetAttackDelay(60)
	ScenarioInfo.P1_ENEM01_Main_Darkenoid_OpAI:				SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Main_Darkenoid_OpAI:				Disable()


	---------------
	-- Surgical OpAI's
	---------------

	--# Too many land units of some types
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessLand_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirResponsePatrolLand', 'P1_ENEM01_Main_PlayerExcessLand_OpAI', {} )
	local P1_ENEM01_Main_PlayerExcessLand_OpAI_Data			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_AirAttack_01_Chain', 'P1_ENEM01_Main_AirAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessLand_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_Main_PlayerExcessLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessLand_OpAI:		SetAttackDelay(25)
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessLand_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessLand_OpAI:		SetChildCount(1)


	--# Too many air units
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessAir_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirResponsePatrolAir', 'P1_ENEM01_Main_PlayerExcessAir_OpAI', {} )
	local P1_ENEM01_Main_PlayerExcessAir_OpAI_Data			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_AirAttack_01_Chain', 'P1_ENEM01_Main_AirAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessAir_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_Main_PlayerExcessAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessAir_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessAir_OpAI:		SetAttackDelay(20)
	ScenarioInfo.P1_ENEM01_Main_PlayerExcessAir_OpAI:		SetChildCount(2)


	-- Player builds powerful individual land units
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulLand_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirResponseTargetLand', 'P1_ENEM01_Main_PlayerPowerfulLand_OpAI', {} )
	local P1_ENEM01_Main_PlayerPowerfulLand_OpAI_Data		= {
    												    	PatrolChain = 'zz_SUBCHAIN_PlayerBaseArea_ForAir',
    												    	CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_MainBase_Marker' ),
    												    	CategoryList = {
    												    	    (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    												    	    categories.uub0105,	-- artillery
    												    	    categories.ucb0105,	-- artillery
    												    	    categories.NUKE,
    												   		 	},
    														}
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulLand_OpAI:	SetPlatoonThread( 'CategoryHunter', P1_ENEM01_Main_PlayerPowerfulLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulLand_OpAI:	SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulLand_OpAI:	SetAttackDelay(15)
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulLand_OpAI:	SetChildCount(1)


	-- Player builds air experimentals
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulAir_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:AddOpAI('AirResponseTargetAir', 'P1_ENEM01_Main_PlayerPowerfulAir_OpAI', {} )
	local P1_ENEM01_Main_PlayerPowerfulAir_OpAI_Data			= {
    														PatrolChain = 'zz_SUBCHAIN_PlayerBaseArea_ForAir',
    														CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_MainBase_Marker' ),
    														CategoryList = {
    														    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    															},
    														}
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulAir_OpAI:	SetPlatoonThread( 'CategoryHunter', P1_ENEM01_Main_PlayerPowerfulAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulAir_OpAI:	SetAttackDelay(55)
	ScenarioInfo.P1_ENEM01_Main_PlayerPowerfulAir_OpAI:	SetChildCount(2)


	---------------
	-- Initial Units, Sundry
	---------------

	-- initial air defense patrols for east/west/main bases
	for i = 1, 2 do
		local airMain = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Main_InitAirDef_01', 'AttackFormation')
		local airWest = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_West_InitAirDef_01', 'AttackFormation')
		local airEast = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_East_InitAirDef_01', 'AttackFormation')
		ScenarioInfo.P1_ENEM01_Main_BaseDefAir_OpAI:AddActivePlatoon(airMain, true)
		ScenarioInfo.P1_ENEM01_Main_WestDefAir_OpAI:AddActivePlatoon(airWest, true)
		ScenarioInfo.P1_ENEM01_Main_EastDefAir_OpAI:AddActivePlatoon(airEast, true)
	end

end

function P1_AISeteup_EnemSideWest()
	----------------------------------------------
	--Enemy Side Base, West:
	----------------------------------------------

	--# West side base setup
	local levelTable_ENEM01_WestSide_Base 	= { ENEM01_SideBaseWest_100 = 100,
												ENEM01_SideBaseWest_90 = 90, }
	ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P1_ENEM01_WestSide_Base',
		 'P1_ENEM01_WestSide_Base_Marker', 50, levelTable_ENEM01_WestSide_Base)
	ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:StartNonZeroBase(1)
	ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:SetBaseInfiniteRebuild()


	-- Get list of factories, and make a death trigger for them that will, when fired, disable the air cover
	-- the Main base is providing for this West base.
	local structures = GetUnitsFromFolder({'ENEM01_SideBaseWest_100', 'ENEM01_SideBaseWest_90'})
	ScenarioFramework.CreateGroupDeathTrigger( P1_DisableWestAirDefense, structures )


	---------------
	-- General OpAI's
	---------------

	--# basic land attack against player. Route will change based on triggered event.
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:AddOpAI('LandAttackCybran', 'P1_ENEM01_WestSide_LandAttack_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_WestSide_LandAttack_01_Chain', },}
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI:		SetAttackDelay(75)
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI:		Disable()

	---------------
	-- Experimental OpAI's
	---------------

	--# Megalith OpAI
	ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:AddOpAI('SingleMegalithAttack', 'P1_ENEM01_WestSide_Megalith_OpAI', {} )
	local P1_ENEM01_WestSide_Megalith_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_WestSide_LandAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_WestSide_Megalith_OpAI_Data )
	ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:			SetAttackDelay(60)
	ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:			Disable()


	--# AirNoMo OpAI
	ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:AddOpAI('SingleAirnomoAttack', 'P1_ENEM01_WestSide_Airnomo_OpAI', {} )
	local P1_ENEM01_WestSide_Airnomo_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_WestSide_LandAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_WestSide_Airnomo_OpAI_Data )
	ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI:			SetAttackDelay(45)
	ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI:			Disable()


	--# Colossus OpAI
	ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:AddOpAI('SingleColossusAttack', 'P1_ENEM01_WestSide_Colossus_OpAI', {} )
	local P1_ENEM01_WestSide_Colossus_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_WestSide_LandAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_WestSide_Colossus_OpAI_Data )
	ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI:			SetAttackDelay(100)
	ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI:			Disable()


	---------------
	-- Capture Engineer OpAI's
	---------------

	-- capture child template and capture data
	local captureChild = {
		'ENEM01_CaptureEngineer_Child',
		{
			{ 'ucl0002', 3 },
		},
	}

	local captureData = {
		CaptureChain = 'P1_ENEM01_West_CoilRoute_AttackChain',
		CaptureRadius = 20,
		CallbackFunction = P1_EnemyCaptureCallback,
	}


	--# Capture engineer OpAI
	ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI 			= ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:GenerateOpAIFromPlatoonTemplate(captureChild, 'P1_ENEM01_WestSide_Capture01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI:			SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI.			FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI:			SetChildCount(2)
	ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI:			SetAttackDelay( ScenarioInfo.P1_CaptureOpAIDelay_West )
	ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI:			Disable()

end

function P1_AISeteup_EnemSideEast()
	----------------------------------------------
	--Enemy Side Base, East:
	----------------------------------------------

	--# West side base setup
	local levelTable_ENEM01_EastSide_Base 	= { ENEM01_SideBaseEast_100 = 100,
												ENEM01_SideBaseEast_90 = 90, }
	ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P1_ENEM01_EastSide_Base',
		 'P1_ENEM01_EastSide_Base_Marker', 50, levelTable_ENEM01_EastSide_Base)
	ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:StartNonZeroBase(1)
	ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:SetBaseInfiniteRebuild()


	-- get list of factories, and make a death trigger for them that will, when fired, disable the air cover
	-- the Main base is providing for this East base.
	local factories = GetUnitsFromFolder({'ENEM01_SideBaseEast_100', 'ENEM01_SideBaseEast_90'})
	ScenarioFramework.CreateGroupDeathTrigger( P1_DisableEastAirDefense, factories )

	---------------
	-- General OpAI's
	---------------

	--# basic land attack against player
	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:AddOpAI('LandAttackCybran', 'P1_ENEM01_EastSide_LandAttack_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_EastSide_LandAttack_01_Chain', },}
	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI:		SetAttackDelay(105)
	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI:		Disable()

	---------------
	-- Experimental OpAI's
	---------------

	--# Megalith OpAI
	ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:AddOpAI('SingleMegalithAttack', 'P1_ENEM01_EastSide_Megalith_OpAI', {} )
	local P1_ENEM01_EastSide_Megalith_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_EastSide_LandAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_EastSide_Megalith_OpAI_Data )
	ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:			SetAttackDelay(50)
	ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:			Disable()


	--# AirNoMo OpAI
	ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:AddOpAI('SingleAirnomoAttack', 'P1_ENEM01_EastSide_Airnomo_OpAI', {} )
	local P1_ENEM01_EastSide_Airnomo_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_EastSide_LandAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_EastSide_Airnomo_OpAI_Data )
	ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI:			SetAttackDelay(60)
	ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI:			Disable()


	--# Colossus OpAI
	ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:AddOpAI('SingleColossusAttack', 'P1_ENEM01_EastSide_Colossus_OpAI', {} )
	local P1_ENEM01_EastSide_Colossus_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_EastSide_LandAttack_01_Chain',},}
	ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_EastSide_Colossus_OpAI_Data )
	ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI:			SetAttackDelay(85)
	ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI:			Disable()


	---------------
	-- Capture Engineer OpAI's
	---------------

	-- capture child template and capture data
	local captureChild = {
		'ENEM01_CaptureEngineer_Child',
		{
			{ 'ucl0002', 3 },
		},
	}

	local captureData = {
		CaptureChain = 'P1_ENEM01_East_CoilRoute_Attack_Chain',
		CaptureRadius = 20,
		CallbackFunction = P1_EnemyCaptureCallback,
	}


	--# Capture engineer OpAI
	ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI 			= ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:GenerateOpAIFromPlatoonTemplate(captureChild, 'P1_ENEM01_EastSide_Capture01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI:			SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI.			FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI:			SetChildCount(2)
	ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI:			SetAttackDelay( ScenarioInfo.P1_CaptureOpAIDelay_East )
	ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI:			Disable()
end

function P1_AISeteup_EnemFront()
	----------------------------------------------
	--Enemy Front Base:
	----------------------------------------------

	--# Front base setup
	local levelTable_ENEM01_Front_Base 	= { ENEM01_FrontBase_100 = 100,
											ENEM01_FrontBase_90 = 90, }
	ScenarioInfo.ArmyBase_P1_ENEM01_Front_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P1_ENEM01_Front_Base',
		 'P1_ENEM01_Front_Base_Marker', 50, levelTable_ENEM01_Front_Base)
	ScenarioInfo.ArmyBase_P1_ENEM01_Front_Base:StartNonZeroBase(1)

	-- VO: dialogue when gauge loses each of his satellite bases.
	structures = GetUnitsFromFolder({'ENEM01_FrontBase_100', 'ENEM01_FrontBase_90'})
	for k, v in structures do
		if v and not v:IsDead() then
			LOG('----- 3ZRB: ')
		end
	end
	ScenarioFramework.CreateGroupDeathTrigger(function() ScenarioFramework.Dialogue(OpDialog.C06_BASE_03_DESTROYED) end, structures )

	---------------
	-- General OpAI's
	---------------

	--# basic land attack against player
	ScenarioInfo.P1_ENEM01_Front_LandAttack_01_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01_Front_Base:AddOpAI('LandAttackCybran', 'P1_ENEM01_Front_LandAttack_01_OpAI', {} )
	local P1_ENEM01_Front_LandAttack_01_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Front_LandAttack01_Chain',},}
	ScenarioInfo.P1_ENEM01_Front_LandAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_Front_LandAttack_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_Front_LandAttack_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Front_LandAttack_01_OpAI:		Disable()

end

function P1_EnemyCaptureCallback(unit)
	LOG('----- P1: Player unit captured.')
	-- A player unit has been captured. If it is a mobile unit it, give it a patrol around the player base area.
	if unit and not unit:IsDead() then
		if EntityCategoryContains( categories.MOBILE, unit ) then
			LOG('----- P1: captured unit is valid and a mobile. Sending on patrol.')
			IssueClearCommands({unit})
			ScenarioFramework.GroupPatrolChain( {unit}, 'zz_SUBCHAIN_PlayerBaseArea_ForLand' )
		end
	end
	if not ScenarioInfo.UnitCaptureVOPlayed then
		ScenarioInfo.UnitCaptureVOPlayed = true
		 ScenarioFramework.Dialogue(OpDialog.C06_ENGINEER_CAPTURE)
	end
end

function P1_SetEngineerBuildRate(platoon)
	for k, v in platoon:GetPlatoonUnits() do
		if v and not v:IsDead() then
			v:SetCaptureRate(5.81)
			v:SetSpeedMult(2.4)
			v:SetMaxCaptureDistance(18) -- range at which an engineer can capture.
		end
	end
end

function LandAttackRoutesChange()
	LOG('----- Coil Respond: land attacks will now use side coil routes.')
	-- Shift the normal-land-attack routes for the two land bases to use coil-area routes, instead of the main front paths.
	-- This both changes things up, and makes the main paths a little more realistic to push through.
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_WestSide_LandAttack_01b_Chain', },}
	ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI_Data )

	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_EastSide_LandAttack_01b_Chain', },}
	ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI_Data )
end

---------------------------------------------------------------------
-- ATTACK ENABLES AND UPDATES:
---------------------------------------------------------------------

function EvaluatePlayerStrength_Thread()
	--ScenarioInfo.AllowEvaluationThread = false
	while ScenarioInfo.AllowEvaluationThread do
		while ScenarioInfo.OpNISActive do WaitSeconds(1.0) end

		---------------
		-- Calculate Value
		---------------

		-- notice that we dont check for AA towers. This works to our favor, softening the blow of experimentals. But nevertheless, keep it in mind.
		local shield 		= P1_Player_ShieldWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0202)
		local pointDef 		= P1_Player_PointDefWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0101)
		local miniExper 	= P1_Player_ExperMiniWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucx0101 + categories.ucx0102 + categories.uix0101 + categories.uix0103) -- some minis/weaker experimentals to weight lower
		local experimental 	= P1_Player_ExperimentalWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL - categories.ucx0101 - categories.ucx0102 - categories.uix0101 - categories.uix0103)	-- experimentals minus a selection of minis and weaker units.
		local mobileLand 	= P1_Player_MobLandWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits((categories.MOBILE * categories.LAND) - categories.EXPERIMENTAL - categories.ucl0002)
		local gunship 		= P1_Player_GunshipWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uca0103)
		local bomber 		= P1_Player_BomberWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uca0104)
		local navalNormal	= P1_Player_Naval1Weight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucs0103 + categories.ucs0901)
		local navalStrong	= P1_Player_Naval2Weight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucs0105)

		-- create raw player value
		local playerRaw = shield + pointDef + miniExper + experimental + mobileLand + gunship + bomber + navalNormal + navalStrong

		-- remove an amount equal to an estimate of the player starting units value, to get a starting threshold.
		local PlayerStrength = playerRaw - 40
		if PlayerStrength < 0 then PlayerStrength = 0 end
		LOG('----- EVALTHREAD: playerRaw is  ' .. playerRaw .. ' and PlayerStrength is ' .. PlayerStrength)


		---------------
		-- General
		---------------

		-- Research (no timers used)
		-- CLP_SHIELD
		if PlayerStrength >= 105 then
			if not ScenarioInfo.EnemResearchShield then
				LOG('----- EVALTHREAD: unlocking enemy research CLP_SHIELD, at playerstrength ' .. PlayerStrength)
				ScenarioInfo.EnemResearchShield = true
				ArmyBrains[ARMY_ENEM01]:CompleteResearch({'CLP_SHIELD'})
			end
		end
	--& --### TODO: Evaluate the op with this research removed -GR 12/9/2009 6:57:29 PM
	--&	-- CLB_RATEOFFIRE  ---- NOTE: Testing op with this upgrade removed. It may be too substantial.
	--&	if PlayerStrength >= 95 then
	--&		if not ScenarioInfo.EnemResearchROF then
	--&			LOG('----- EVALTHREAD: unlocking enemy research CLB_RATEOFFIRE, at playerstrength ' .. PlayerStrength)
	--&			ScenarioInfo.EnemResearchROF = true
	--&			ArmyBrains[ARMY_ENEM01]:CompleteResearch({'CLB_RATEOFFIRE'})
	--&		end
	--&	end
	--&	-- CLB_MOVESPEED ---- NOTE: Testing op with this upgrade removed. It may be too substantial.
	--&	if PlayerStrength >= 115 then
	--&		if not ScenarioInfo.EnemResearchSpeed then
	--&			LOG('----- EVALTHREAD: unlocking enemy research CLB_MOVESPEED, at playerstrength ' .. PlayerStrength)
	--&			ScenarioInfo.EnemResearchSpeed = true
	--&			ArmyBrains[ARMY_ENEM01]:CompleteResearch({'CLB_MOVESPEED'})
	--&		end
	--&	end



		---------------
		-- West Base
		---------------

--&		-- Basic land attacks		-- Making this enabled by timer only.
--&		if PlayerStrength >= 1 then
--&			West_EnableBasicLandAttacks(' via Thread. Player strength is ' .. PlayerStrength)
--&		end

		-- Capture Engineer Attacks
		if PlayerStrength >= 100 then
			West_EnableCapture(' via Thread. Player strength is ' .. PlayerStrength)
		end
--&		-- Expansion Base: note, requires timer *and* PlayerStrength threshold.
--&		if PlayerStrength >= 140 then
--&			West_EnableExpansionBase(' via Thread. Player strength is ' .. PlayerStrength)
--&		end

		-- Airnomo
		if PlayerStrength >= 45 then
			West_EnableAirnomo(' via Thread.')
		end
		--* Airnomo: increase max platoons to 2
		if PlayerStrength >= 160 then
			West_IncreaseMaxAirnomoPlatoons(' via Thread. Player strength is ' .. PlayerStrength)
		end

		-- Megaliths
		if PlayerStrength >= 55 then
			West_EnableMegalith(' via Thread. Player strength is ' .. PlayerStrength)
		end
		--* Megaliths: increase max platoons to 2	-- testing with only max1 megaliths
--&		if PlayerStrength >= 95 then
--&			West_IncreaseMaxMegalithPlatoons2(' via Thread. Player strength is ' .. PlayerStrength)
--&		end
--&		--* Megaliths: increase max platoons to 3 -- testing with only max1 megaliths
--&		if PlayerStrength >= 230 then
--&			West_IncreaseMaxMegalithPlatoons3(' via Thread. Player strength is ' .. PlayerStrength)
--&		end

		-- Colossus
		if PlayerStrength >= 100 then
			West_EnableColossus(' via Thread. Player strength is ' .. PlayerStrength)
		end
		--* Colossus: increase max platoons
		if PlayerStrength >= 200 then
			West_IncreaseMaxColossusPlatoons(' via Thread. Player strength is ' .. PlayerStrength)
		end


		-- West base: Adaptive platoon count resets, for '*' events above. Will only reset if this event has been triggered.
		-- be sure to do identical OpAI's in descending order here.
		if PlayerStrength < 160 and ScenarioInfo.WestIncreaseMaxAirnomoPlatoons == true then
			LOG('----- EVALTHREAD West: Decreasing Airnomo max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.WestIncreaseMaxAirnomoPlatoons = false
		end
		if PlayerStrength < 230 and ScenarioInfo.WestIncreaseMaxMegalithPlatoons3 == true then
			LOG('----- EVALTHREAD West: Decreasing Meglith max platoons to 2. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:SetMaxActivePlatoons(2)
			ScenarioInfo.WestIncreaseMaxMegalithPlatoons3 = false
		end
		if PlayerStrength < 95 and ScenarioInfo.WestIncreaseMaxMegalithPlatoons2 == true then
			LOG('----- EVALTHREAD West: Decreasing Meglith max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.WestIncreaseMaxMegalithPlatoons2 = false
		end
		if PlayerStrength < 200 and ScenarioInfo.WestIncreaseMaxColossusPlatoons == true then
			LOG('----- EVALTHREAD West: Decreasing Coloss max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.WestIncreaseMaxColossusPlatoons = false
		end


		---------------
		-- East Base
		---------------

		-- Basic land attacks
		if PlayerStrength >= 45 then
			East_EnableBasicLandAttacks_Strength(' via Thread. Player strength is ' .. PlayerStrength)
		end

		-- Capture Engineer Attacks
		if PlayerStrength >= 165 then
			East_EnableCapture(' via Thread. Player strength is ' .. PlayerStrength)
		end
		-- Expansion Base: note, requires timer *and* PlayerStrength threshold.
		if PlayerStrength >= 80 then
			East_EnableExpansionBase(' via Thread. Player strength is ' .. PlayerStrength)
		end


		-- Airnomo
		if PlayerStrength >= 75 then
			East_EnableAirnomo(' via Thread. Player strength is ' .. PlayerStrength)
		end
		--* Airnomo: increase max platoons to 2
		if PlayerStrength >= 105 then
			East_IncreaseMaxAirnomoPlatoons(' via Thread. Player strength is ' .. PlayerStrength)
		end

		-- Megaliths
		if PlayerStrength >= 90 then
			East_EnableMegalith(' via Thread. Player strength is ' .. PlayerStrength)
		end
		--* Megaliths: increase max platoons to 2
		if PlayerStrength >= 180 then
			East_IncreaseMaxMegalithPlatoons2(' via Thread. Player strength is ' .. PlayerStrength)
		end
--&		--* Megaliths: 75 max platoons to 3
--&		if PlayerStrength >= 275 then
--&			East_IncreaseMaxMegalithPlatoons3(' via Thread. Player strength is ' .. PlayerStrength)
--&		end

		-- Colossus
		if PlayerStrength >= 165 then
			East_EnableColossus(' via Thread. Player strength is ' .. PlayerStrength)
		end
--&		--* Colossus: increase max platoons	-- testing with east collos2 disabled, for total of max 3 colloss on map.
--&		if PlayerStrength >= 260 then
--&			East_IncreaseMaxColossusPlatoons(' via Thread. Player strength is ' .. PlayerStrength)
--&		end


		-- East base: Adaptive platoon count resets, for '*' events above.
		if PlayerStrength < 105 and ScenarioInfo.EastIncreaseMaxAirnomoPlatoons == true then
			LOG('----- EVALTHREAD East: Decreasing Airnomo max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.EastIncreaseMaxAirnomoPlatoons = false
		end
		if PlayerStrength < 275 and ScenarioInfo.EastIncreaseMaxMegalithPlatoons3 == true then
			LOG('----- EVALTHREAD East: Decreasing Meglith max platoons to 2. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:SetMaxActivePlatoons(2)
			ScenarioInfo.EastIncreaseMaxMegalithPlatoons3 = false
		end
		if PlayerStrength < 180 and ScenarioInfo.EastIncreaseMaxMegalithPlatoons2 == true then
			LOG('----- EVALTHREAD East: Decreasing Meglith max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.EastIncreaseMaxMegalithPlatoons2 = false
		end
		if PlayerStrength < 260 and ScenarioInfo.EastIncreaseMaxColossusPlatoons == true then
			LOG('----- EVALTHREAD West: Decreasing Coloss max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.EastIncreaseMaxColossusPlatoons = false
		end


		---------------
		-- Main Base
		---------------

		-- Air Attacks
		if PlayerStrength >= 43 then
			Main_EnableAirAttacks(' via Thread.')
		end
		-- Air Attacks: increase max platoons
		if PlayerStrength >= 83 then
			Main_IncreaseMaxAirAttackPlatoons2(' via Thread. Player strength is ' .. PlayerStrength)
		end
		--* Air Attacks: increase max platoons
		if PlayerStrength >= 150 then
			Main_IncreaseMaxAirAttackPlatoons3(' via Thread. Player strength is ' .. PlayerStrength)
		end

		-- Transport Attacks
		if PlayerStrength >= 80 then
			Main_EnableTransAttack(' via Thread. Player strength is ' .. PlayerStrength)
		end
		-- Transport Attacks: change landing points to behind player
		if PlayerStrength >= 195 then
			Main_TransAttackUpdated(' via Thread. Player strength is ' .. PlayerStrength)
		end
		-- Transport Attacks: capture engineers
		if PlayerStrength >= 260 then
			Main_EnableTransCapAttack(' via Thread. Player strength is ' .. PlayerStrength)
		end

		-- Soul Ripper
		if PlayerStrength >= 210 then
			Main_EnableSoulRipper(' via Thread. Player strength is ' .. PlayerStrength)
		end
		--* Soul Ripper: increase max platoons
		if PlayerStrength >= 290 then
			Main_IncreaseMaxSoulRipperPlatoons2(' via Thread. Player strength is ' .. PlayerStrength)
		end

		-- Darkenoid
		if PlayerStrength >= 270 then
			Main_EnableDarkenoid(' via Thread. Player strength is ' .. PlayerStrength)
		end
		--* Darkenoid: increase max platoons
		if PlayerStrength >= 350 then
			Main_IncreaseMaxDarkenoidPlatoons2(' via Thread. Player strength is ' .. PlayerStrength)
		end


		-- Main base: Adaptive platoon count resets
		if PlayerStrength < 145 and ScenarioInfo.MainIncreaseMaxAirAttackPlatoons3 == true then
			LOG('----- EVALTHREAD Main: Decreasing Air Attack max platoons to 2. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:SetMaxActivePlatoons(2)
			ScenarioInfo.MainIncreaseMaxAirAttackPlatoons3 = false
		end
		if PlayerStrength < 285 and ScenarioInfo.MainIncreaseMaxSoulRipperPlatoons2 == true then
			LOG('----- EVALTHREAD Main: Decreasing Soul Ripper max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.MainIncreaseMaxSoulRipperPlatoons2 = false
		end
		if PlayerStrength < 345 and ScenarioInfo.MainIncreaseMaxDarkenoidPlatoons2 == true then
			LOG('----- EVALTHREAD Main: Decreasing Darkenoid max platoons to 1. Playerstrength is at ' .. PlayerStrength)
			ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.MainIncreaseMaxDarkenoidPlatoons2 = false
		end


		WaitSeconds(6.3)
	end
end

function West_EnableBasicLandAttacks(flag)
	if not ScenarioInfo.WestEnableBasicLand then
		ScenarioInfo.WestEnableBasicLand = true
		LOG('----- West: basic land attacks enabled enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_LandAttack_01_OpAI:Enable()
	end
end

function West_EnableCapture(flag)
	if not ScenarioInfo.WestEnableCapture then
		ScenarioInfo.WestEnableCapture = true
		LOG('----- West: capture enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Capture01_OpAI:Enable()
		-- whichever base starts the captures, we globally give the op 10 minutes of normal delay capture. After that,
		-- we crank the rebuild delay way up, so things dont get repetative with the engineers.
		ScenarioFramework.CreateTimerTrigger (function() ScenarioInfo.P1_CaptureOpAIDelay_West = 240 end, 600 )
	end
end

function West_EnableMegalith(flag)
	if not ScenarioInfo.WestEnableMegalith then
		ScenarioInfo.WestEnableMegalith = true
		LOG('----- West: megalith enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:Enable()
	end
end

function West_IncreaseMaxMegalithPlatoons2(flag)
	if not ScenarioInfo.WestIncreaseMaxMegalithPlatoons2 then
		ScenarioInfo.WestIncreaseMaxMegalithPlatoons2 = true
		LOG('----- West: megalith max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:SetMaxActivePlatoons(2)
	end
end

function West_IncreaseMaxMegalithPlatoons3(flag)
	if not ScenarioInfo.WestIncreaseMaxMegalithPlatoons3 then
		ScenarioInfo.WestIncreaseMaxMegalithPlatoons3 = true
		LOG('----- West: megalith max platoons increased to 3 via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Megalith_OpAI:SetMaxActivePlatoons(3)
	end
end

function West_EnableAirnomo(flag)
	if not ScenarioInfo.WestEnableAirnomo then
		ScenarioInfo.WestEnableAirnomo = true
		LOG('----- West: Airnomo enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI:Enable()
	end
end

function West_IncreaseMaxAirnomoPlatoons(flag)
	if not ScenarioInfo.WestIncreaseMaxAirnomoPlatoons then
		ScenarioInfo.WestIncreaseMaxAirnomoPlatoons = true
		LOG('----- West: Airnomo max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Airnomo_OpAI:SetMaxActivePlatoons(2)
	end
end

function West_EnableExpansionBase_Timer()
	LOG('----- West: Expansion base timer finished. Setting timer flag.')
	-- Timer has finished, so flag that, time-wise, an eastern expansion base is allowed.
	ScenarioInfo.WestExpansionTimer = true
end

function West_EnableExpansionBase(flag)
	-- The expansion bases should be be built only after a period of time has passed, *and* when the player
	-- is doing fairly well. So, both a timer and the main player check thread turn this on together.
	if ScenarioInfo.WestExpansionTimer and not ScenarioInfo.West_EnableExpansionBase then
		ScenarioInfo.West_EnableExpansionBase = true
		LOG('----- West: adding expansion base via ' .. flag)

		ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:AddExpansionBase('ArmyBase_P1_ENEM01_WestExpansion_Base')
		local expansionTable_ENEM01_WestExpansion = {
			P1_ENEM01_WestExpansion_100 = 100,
			P1_ENEM01_WestExpansion_90 = 90,
			P1_ENEM01_WestExpansion_80 = 80,
		}
		ScenarioInfo.ArmyBase_P1_ENEM01_WestExpansion_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P1_ENEM01_WestExpansion_Base',
			 'ArmyBase_P1_ENEM01_WestExpansion_Base_Marker', 50, expansionTable_ENEM01_WestExpansion)
		ScenarioInfo.ArmyBase_P1_ENEM01_WestExpansion_Base:StartEmptyBase(1)
	end
end

function West_EnableColossus(flag)
	if not ScenarioInfo.WestEnableColossus then
		ScenarioInfo.WestEnableColossus = true
		LOG('----- West: colossus enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI:Enable()
	end
end

function West_IncreaseMaxColossusPlatoons(flag)
	if not ScenarioInfo.WestIncreaseMaxColossusPlatoons then
		ScenarioInfo.WestIncreaseMaxColossusPlatoons = true
		LOG('----- West: colossus max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_WestSide_Colossus_OpAI:SetMaxActivePlatoons(2)
	end
end

function East_EnableBasicLandAttacks_Timer()
	LOG('----- East:  Basic land attacks - setting timer flag.')
	-- Timer has finished, so flag that, time-wise, an eastern expansion base is allowed.
	ScenarioInfo.EastMainBeginLandTimer = true
end

function East_EnableBasicLandAttacks_Strength(flag)
	if ScenarioInfo.EastMainBeginLandTimer and not ScenarioInfo.EastEnableBasicLand then
		ScenarioInfo.EastEnableBasicLand = true
		LOG('----- East: basic land attacks enabled enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_LandAttack_01_OpAI:Enable()
	end
end

function East_EnableCapture(flag)
	if not ScenarioInfo.EastEnableCapture then
		ScenarioInfo.EastEnableCapture = true
		LOG('----- East: capture enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Capture01_OpAI:Enable()
		-- whichever base starts the captures, we globally give the op 10 minutes of normal delay capture. After that,
		-- we crank the rebuild delay way up, so things dont get repetative with the engineers.
		ScenarioFramework.CreateTimerTrigger (function() ScenarioInfo.P1_CaptureOpAIDelay_East = 240 end, 420 )
	end
end

function East_EnableMegalith(flag)
	if not ScenarioInfo.EastEnableMegalith then
		ScenarioInfo.EastEnableMegalith = true
		LOG('----- East: megalith enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:Enable()
	end
end

function East_IncreaseMaxMegalithPlatoons2(flag)
	if not ScenarioInfo.EastIncreaseMaxMegalithPlatoons2 then
		ScenarioInfo.EastIncreaseMaxMegalithPlatoons2 = true
		LOG('----- East: megalith max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:SetMaxActivePlatoons(2)
	end
end

function East_IncreaseMaxMegalithPlatoons3(flag)
	if not ScenarioInfo.EastIncreaseMaxMegalithPlatoons3 then
		ScenarioInfo.EastIncreaseMaxMegalithPlatoons3 = true
		LOG('----- East: megalith max platoons increased to 3 via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Megalith_OpAI:SetMaxActivePlatoons(3)
	end
end

function East_EnableAirnomo(flag)
	if not ScenarioInfo.EastEnableAirnomo then
		ScenarioInfo.EastEnableAirnomo = true
		LOG('----- East: Airnomo enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI:Enable()
	end
end

function East_IncreaseMaxAirnomoPlatoons(flag)
	if not ScenarioInfo.EastIncreaseMaxAirnomoPlatoons then
		ScenarioInfo.EastIncreaseMaxAirnomoPlatoons = true
		LOG('----- East: Airnomo max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Airnomo_OpAI:SetMaxActivePlatoons(2)
	end
end

function East_EnableExpansionBase_Timer()
	LOG('----- East: Expansion base timer finished. Setting timer flag.')
	-- Timer has finished, so flag that, time-wise, an eastern expansion base is allowed.
	ScenarioInfo.EastExpansionTimer = true
end

function East_EnableExpansionBase(flag)
	-- The expansion bases should be be built only after a period of time has passed, *and* when the player
	-- is doing fairly well. So, both a timer and the main player check thread turn this on together.
	if ScenarioInfo.EastExpansionTimer and not ScenarioInfo.East_EnableExpansionBase then
		ScenarioInfo.East_EnableExpansionBase = true
		LOG('----- East: adding expansion base via ' .. flag)

		ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:AddExpansionBase('ArmyBase_P1_ENEM01_EastExpansion_Base')
		local expansionTable_ENEM01_EastExpansion = {
			P1_ENEM01_EastExpansion_100 = 100,
			P1_ENEM01_EastExpansion_90 = 90,
			P1_ENEM01_EastExpansion_80 = 80,
		}
		ScenarioInfo.ArmyBase_P1_ENEM01_EastExpansion_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_P1_ENEM01_EastExpansion_Base',
			 'ArmyBase_P1_ENEM01_EastExpansion_Base_Marker', 50, expansionTable_ENEM01_EastExpansion)
		ScenarioInfo.ArmyBase_P1_ENEM01_EastExpansion_Base:StartEmptyBase(1)

		-- deactivate the base if the player twice kills the hlra in it.
		ScenarioFramework.CreateArmyStatTrigger (function()
						LOG('----- Player has killed 2 hlra. Disabling expansion base.')
						ScenarioInfo.ArmyBase_P1_ENEM01_EastExpansion_Base:BaseActive(false)
					end,
				ArmyBrains[ARMY_ENEM01], 'P1_PlayerKilledTwoHLRA',
				{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ucb0105}})
	end
end

function East_EnableColossus(flag)
	if not ScenarioInfo.EastEnableColossus then
		ScenarioInfo.EastEnableColossus = true
		LOG('----- East: colossus enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI:Enable()
	end
end

function East_IncreaseMaxColossusPlatoons(flag)	--& testing with this function unused, so we only have max 3 collos on map.
	if not ScenarioInfo.EastIncreaseMaxColossusPlatoons then
		ScenarioInfo.EastIncreaseMaxColossusPlatoons = true
		LOG('----- East: colossus max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_EastSide_Colossus_OpAI:SetMaxActivePlatoons(2)
	end
end

function Main_EnableAirAttacks(flag)
	if not ScenarioInfo.MainEnableAirAttacks then
		ScenarioInfo.MainEnableAirAttacks = true
		LOG('----- Main: Air Attacks enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:Enable()
	end
end

function Main_IncreaseMaxAirAttackPlatoons2(flag)
	if not ScenarioInfo.MainIncreaseMaxAirAttackPlatoons2 then
		ScenarioInfo.MainIncreaseMaxAirAttackPlatoons2 = true
		LOG('----- Main: Air Attack max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:SetMaxActivePlatoons(2)
	end
end

function Main_IncreaseMaxAirAttackPlatoons3(flag)
	if not ScenarioInfo.MainIncreaseMaxAirAttackPlatoons3 then
		ScenarioInfo.MainIncreaseMaxAirAttackPlatoons3 = true
		LOG('----- Main: Air Attack max platoons increased to 3 via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_AirAttack_01_OpAI:SetMaxActivePlatoons(3)
	end
end

function Main_EnableTransAttack(flag)
	if not ScenarioInfo.MainEnableTransAttack then
		ScenarioInfo.MainEnableTransAttack = true
		LOG('----- Main: transport attacks enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI:Enable()
		ScenarioInfo.P1_ENEM01_Main_Transports:Enable()
	end
end

function Main_EnableTransCapAttack(flag)
	if not ScenarioInfo.MainEnableTransCapAttack then
		ScenarioInfo.MainEnableTransCapAttack = true
		LOG('----- Main: transport capture attacks enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_Transports:Enable()
		ScenarioInfo.P1_ENEM01_Main_TransCapEng_01_OpAI:Enable()
	end
end

function Main_TransAttackUpdated(flag)
	if not ScenarioInfo.MainTransAttackUpdated then
		ScenarioInfo.MainTransAttackUpdated = true
		LOG('----- Main: transport attacks landing points changed via ' .. flag)
	    ScenarioInfo.P1_ENEM01_TransAttack01_Data = {
	        PatrolChain  = 'P1_ENEM01_PlayerArea_Trans_PatrolChain_01',
	        LandingChain = 'P1_ENEM01_PlayerArea_LandingChain02',
	        TransportReturn = 'P1_ENEM01_Main_TransportRally',
	    }
	    ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI:SetPlatoonThread( 'LandAssaultWithTransports', ScenarioInfo.P1_ENEM01_TransAttack01_Data )
	end
end

function Main_EnableSoulRipper(flag)
	if not ScenarioInfo.MainEnableSoulRipper then
		ScenarioInfo.MainEnableSoulRipper = true
		LOG('----- Main: soulripper enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:Enable()
	end
end

function Main_IncreaseMaxSoulRipperPlatoons2(flag)
	if not ScenarioInfo.MainIncreaseMaxSoulRipperPlatoons2 then
		ScenarioInfo.MainIncreaseMaxSoulRipperPlatoons2 = true
		LOG('----- Main: soulripper max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:SetMaxActivePlatoons(2)
	end
end

function Main_EnableDarkenoid(flag)
	if not ScenarioInfo.MainEnableDarkenoid then
		ScenarioInfo.MainEnableDarkenoid = true
		LOG('----- Main: darkenoid enabled via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_Darkenoid_OpAI:Enable()
	end
end

function Main_IncreaseMaxDarkenoidPlatoons2(flag)
	if not ScenarioInfo.MainIncreaseMaxDarkenoidPlatoons2 then
		ScenarioInfo.MainIncreaseMaxDarkenoidPlatoons2 = true
		LOG('----- Main: darkenoid max platoons increased to 2 via ' .. flag)
		ScenarioInfo.P1_ENEM01_Main_SoulRipper_OpAI:SetMaxActivePlatoons(2)
	end
end

function P1_EnableDroneLauncers()
	-- Calculate how many drones to activate per player-focused launcher.
	local shield 		= 4 * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0202)
	local pointDef 		= 1 * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0101)
	local miniExper 	= 14 * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucx0101 + categories.ucx0102 + categories.uix0101 + categories.uix0103) -- some minis/weaker experimentals to weight lower
	local experimental 	= 26 * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL - categories.ucx0101 - categories.ucx0102 - categories.uix0101 - categories.uix0103)	-- experimentals minus a selection of minis and weaker units.
	local mobileLand 	= 0.4 * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits((categories.MOBILE * categories.LAND) - categories.EXPERIMENTAL - categories.ucl0002)
	local gunship 		= P1_Player_GunshipWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uca0103)
	local bomber 		= P1_Player_BomberWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uca0104)
	local navalNormal	= P1_Player_Naval1Weight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucs0103 + categories.ucs0901)
	local navalStrong	= P1_Player_Naval2Weight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucs0105)

	local playerRaw = shield + pointDef + miniExper + experimental + mobileLand + gunship + bomber + navalNormal + navalStrong
	local PlayerStrength = playerRaw - 44
	if PlayerStrength < 0 then PlayerStrength = 0 end

	local amount = math.floor(PlayerStrength / 37)
	if amount < 5 then amount = 5 end
	if amount > 9 then amount = 9 end

	LOG('----- Drone Lunchers: Enabling. PlayerStrength is : ' .. PlayerStrength .. ', Drone Launchers: ' .. amount)

	-- Turn on launchers. The 4 nearest launchers to Gauge are focued on him, the rest on the player.
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[1], 'ARMY_ART', amount, 'P1_ART_DroneToPlayer_Chain01', 7, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[2], 'ARMY_ART', amount, 'P1_ART_DroneToPlayer_Chain02', 7, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[3], 'ARMY_ART', amount, 'P1_ART_DroneToPlayer_Chain03', 7, 4)

	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[4], 'ARMY_ART', 9, 'P1_ENEM01_DronePatrolAtGauge_Chain', 6, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[5], 'ARMY_ART', 9, 'P1_ENEM01_DronePatrolAtGauge_Chain', 6, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[6], 'ARMY_ART', 9, 'P1_ENEM01_DronePatrolAtGauge_Chain', 6, 4)

	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[7], 'ARMY_ART', 9, 'P1_ENEM01_DronePatrolAtGauge_Chain', 6, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[8], 'ARMY_ART', 9, 'P1_ENEM01_DronePatrolAtGauge_Chain', 6, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[9], 'ARMY_ART', 9, 'P1_ENEM01_DronePatrolAtGauge_Chain', 6, 4)

	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[10], 'ARMY_ART', amount, 'P1_ART_DroneToPlayer_Chain02', 7, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[11], 'ARMY_ART', amount, 'P1_ART_DroneToPlayer_Chain03', 7, 4)
	ArtifactUtils.ActivateDroneLauncher(ScenarioInfo.P1_DroneLauncherTable[12], 'ARMY_ART', amount, 'P1_ART_DroneToPlayer_Chain04', 7, 4)
end


---------------------------------------------------------------------
-- SUNDRY FUNCTIONS:
---------------------------------------------------------------------

function GetUnitsFromFolder(folderTable)
	-- Create a table of units that are stored in passed-in LED folder names, without recursing.
	-- folderTable: table of strings, each being the name of a folder of units in LED.
	local unitTable = {}
	for k, v in folderTable do
		local tblData = ScenarioUtils.FindUnitGroup( v, Scenario.Armies['ARMY_ENEM01'].Units )
		for k, v in tblData.Units do
			local unit = ScenarioInfo.UnitNames[ARMY_ENEM01][k]
			table.insert(unitTable, unit)
		end
	end
	return unitTable
end

function P1_EnemyBuiltArtillery_VO()
	ScenarioFramework.Dialogue(OpDialog.C06_LONG_RANGE_ARTY)
end

function P1_SetupVOTriggers()
	-- To keep things neat, keep this huge wodge of triggers in its own function.

	-- VO: banter when player loses a some mass extractors
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C06_BANTER_010) end,
		ArmyBrains[ARMY_PLAYER], 'P1_PlayerLostExtractors',
		{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 3, Category = categories.ucb0701}})

	-- VO: banter when player loses an experimental
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C06_BANTER_020) end,
		ArmyBrains[ARMY_PLAYER], 'P1_PlayerLostExperimental',
		{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL}})

	-- VO: banter when Gauge loses a factories
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C06_BANTER_030) end,
		ArmyBrains[ARMY_ENEM01], 'P1_GaugeLostFactories',
		{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 3, Category = categories.FACTORY}})

	-- VO: banter when Gauge loses experimentals
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C06_BANTER_040) end,
		ArmyBrains[ARMY_ENEM01], 'P1_GaugeLostExperimentals',
		{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 3, Category = categories.EXPERIMENTAL}})

	-- VO: last-chance dialogue from player when gauge is nearing death.
	---NOTE: switching to a health ratio trigger -which fits the intentions correctly - bfricks 11/8/09
	ScenarioFramework.CreateUnitHealthRatioTrigger(function() ScenarioFramework.Dialogue(OpDialog.C06_NEAR_VICTORY) end,
			ScenarioInfo.GAUGE_CDR, 0.5, true, true)

	-- VO: on spotting an illuminate unit (most likely an experimental), dialogue from Gauge.
	ScenarioFramework.CreateArmyIntelTrigger(function() ScenarioFramework.Dialogue(OpDialog.C06_ILLUMINATE_UNIT_SPOTTED) end, ArmyBrains[ARMY_PLAYER],
		'LOSNow', false, true, categories.ILLUMINATE, true, ArmyBrains[ARMY_ENEM01])

	-- VO: gauge notes unit mix after losing more illuminate units
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C06_MORE_EXPERIMENTALS) end,
		ArmyBrains[ARMY_ENEM01], 'P1_GaugeLostMoreExp',
		{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 6, Category = categories.EXPERIMENTAL}})

	-- VO: on spotting a Darkenoid.
	ScenarioFramework.CreateArmyIntelTrigger(function() ScenarioFramework.Dialogue(OpDialog.C06_DARKENOID_SPOTTED) end, ArmyBrains[ARMY_PLAYER],
		'LOSNow', false, true, categories.uix0112, true, ArmyBrains[ARMY_ENEM01])

	-- VO: on spotting a Colossus.
	ScenarioFramework.CreateArmyIntelTrigger(function() ScenarioFramework.Dialogue(OpDialog.C06_COLOSSUS_SPOTTED) end, ArmyBrains[ARMY_PLAYER],
		'LOSNow', false, true, categories.uix0111, true, ArmyBrains[ARMY_ENEM01])

	-- VO: point out that artillery has been built by enemy (delay to allow time for art. to fire)
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.CreateTimerTrigger (P1_EnemyBuiltArtillery_VO, 13) end, ArmyBrains[ARMY_ENEM01],
		'P1_EnemyBuiltArtillery', {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ucb0105}})

	-- VO: dialogue when enemy transports reach player backbase. Delayed to allow landing time.
	ScenarioFramework.CreateAreaTrigger(
		function()
			ScenarioFramework.CreateTimerTrigger(P1_TransportAttackBackbase_VO, 5)
		end,
		'P1_PlayerBackbaseAttack_Area',
		categories.uca0901,
		true,
		false,
		ArmyBrains[ARMY_PLAYER],
		1
	)
end

function P1_FirstCoilGaugeBanter_VO()
	ScenarioFramework.Dialogue(OpDialog.C06_GAUGE_COIL_BANTER_010)
end

function P1_TransportAttackBackbase_VO()
	ScenarioFramework.Dialogue(OpDialog.C06_TRANSPORTS_BACKDOOR)
end


---------------------------------------------------------------------
-- SPECIAL INV SHIELD MANAGEMENT:
---------------------------------------------------------------------
function P1_GaugeUnitsInvuln()
	LOG('----- Gauge base area invuln setup')
	-- set all units in the area to invuln, and add them to a table for later. Note: skipping Gauge, as we dont want to leave
	-- anything about thim to chance. He is manually invulned.


	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: this function is only safe without alliance data because the player is not nearby - bfricks 1/7/10
	local units = ArmyBrains[ARMY_ENEM01]:GetUnitsAroundPoint( categories.ALLUNITS - categories.AIR - categories.ucl0001, ScenarioUtils.MarkerToPosition('P1_ENEM01_GaugePlatformMiddle'), 73)
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	ScenarioInfo.P1_GaugeProtectedUnits_Table = {}
	for k, v in units do
		if v and not v:IsDead() then
        	-- ok to target, nothing else.
        	v:SetReclaimable(false)
        	v:SetCapturable(false)
        	v:SetCanBeKilled(false)
            v:SetCanTakeDamage(false)
            table.insert(ScenarioInfo.P1_GaugeProtectedUnits_Table, v)
		end
	end

	-- Gauge special VO damage trigger
	if ScenarioInfo.GAUGE_CDR and not ScenarioInfo.GAUGE_CDR:IsDead() then
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/22/09
		ScenarioInfo.GAUGE_CDR.OnDamage = function(self, instigator, amount, vector, damageType)
			import('/lua/sim/commanderunit.lua').CommanderUnit.OnDamage(self, instigator, amount, vector, damageType)

			if not ScenarioInfo.INVGaugeVOPlayed and ScenarioInfo.P1_GaugeProtectedUnits_Table then
				ScenarioInfo.INVGaugeVOPlayed = true
				ScenarioFramework.Dialogue(OpDialog.C06_GAUGE_DAMAGED_WHILE_INV)
			end
		end
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	end

	-- create the inv field around Gauge and his arsenal
	CreateInvField()
end

function P1_GaugeUnitsRemoveInvuln()
	LOG('----- Gauge base area invuln disabled.')
	for k, v in ScenarioInfo.P1_GaugeProtectedUnits_Table do
		if v and not v:IsDead() then
        	v:SetReclaimable(true)
        	v:SetCapturable(true)
        	v:SetCanBeKilled(true)
            v:SetCanTakeDamage(true)
		end
	end

	-- reset this table to nil
	ScenarioInfo.P1_GaugeProtectedUnits_Table = nil

	-- destroy the inv field around Gauge and his arsenal
	DestroyInvField()
end

function CreateInvField()
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/22/09
	ScenarioInfo.InvField = import('/lua/sim/Entity.lua').Entity()
	local pos = ScenarioUtils.MarkerToPosition('P1_ENEM01_GaugePlatformMiddle')
	Warp(ScenarioInfo.InvField,pos)
	ScenarioInfo.InvField:SetMesh('/meshes/Shield/Shield01_mesh')
	ScenarioInfo.InvField:SetDrawScale(150.0)
	ScenarioInfo.InvField:InitIntel(ARMY_PLAYER, 'Vision', 2.0)
	ScenarioInfo.InvField:EnableIntel('Vision')

	local bp01 = '/effects/emitters/ambient/terrain/c06/ambient_t_c06_01_electricity_emit.bp'
	local bp02 = '/effects/emitters/ambient/terrain/c06/ambient_t_c06_02_glow_emit.bp'
	local bp03 = '/effects/emitters/ambient/terrain/c06/ambient_t_c06_03_ring_emit.bp'

	CreateEmitterOnEntity( ScenarioInfo.InvField, ARMY_PLAYER, bp01 ):SetEmitterParam('LODCutoff', 9001)
	CreateEmitterOnEntity( ScenarioInfo.InvField, ARMY_PLAYER, bp02 ):SetEmitterParam('LODCutoff', 9001)
	CreateEmitterOnEntity( ScenarioInfo.InvField, ARMY_PLAYER, bp03 ):SetEmitterParam('LODCutoff', 9001)
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end

function DestroyInvField()
	if ScenarioInfo.InvField then
		ScenarioInfo.InvField:Destroy()
	end
end

function AddCoilDamagedVOTrigger(unit)
	if unit and unit.MyShield and unit.MyShield.OnDamage then
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/22/09

		-- allow for our custom VO and ensure these shields never actually take any damage
		unit.MyShield.OnDamage = function(self,instigator,amount,vector,type)
			import('/lua/sim/shield.lua').Shield.OnDamage(self,instigator,0.0,vector,type)

			if not ScenarioInfo.ShieldContactVOPlayed then
				ScenarioInfo.ShieldContactVOPlayed = true
				ScenarioFramework.Dialogue(OpDialog.C06_COIL_CONTACT_010)
			end

	    end
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	end
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function HandleCoilDestructionForNIS(unit)

	NumCoilsDestroyed = NumCoilsDestroyed + 1

	-- IF the first coil has been destroyed, then run NIS_FIRST_COIL_DOWN()
	if NumCoilsDestroyed == 1 then
		ForkThread(
			function()
				OpNIS.NIS_FIRST_COIL_DOWN(unit)
				ScenarioFramework.CreateTimerTrigger(P1_FirstCoilGaugeBanter_VO, 5)
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C06_ZZ_EXTRA_KILL_COIL1, ARMY_PLAYER, 3.0)
			end
		)

	elseif NumCoilsDestroyed == 2 then
		ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C06_ZZ_EXTRA_KILL_COIL2, ARMY_PLAYER, 3.0)

		---NOTE: before, we were just unflagging the unit as killable - that is broken because there is no certainty that the
		---			player will continue to kill this unit - so we have to force kill it. Down the road - when we have a better health ratio system
		---			this should be considerably more readible - bfricks 11/8/09
		-- otherwise we force kill the unit
		ForceUnitDeath(unit)

	elseif NumCoilsDestroyed == 3 then
		ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C06_ZZ_EXTRA_KILL_COIL3, ARMY_PLAYER, 3.0)

		---NOTE: before, we were just unflagging the unit as killable - that is broken because there is no certainty that the
		---			player will continue to kill this unit - so we have to force kill it. Down the road - when we have a better health ratio system
		---			this should be considerably more readible - bfricks 11/8/09
		-- otherwise we force kill the unit
		ForceUnitDeath(unit)

	-- IF the all coils have been destroyed, then run NIS_ALL_COILS_DOWN()
	elseif NumCoilsDestroyed == 4 then
		ForkThread(
			function()
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C06_S1_obj10_KILL_COIL4, ARMY_PLAYER, 3.0)

				---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				---NOTE: this is notmally the wrong way to do things - but was far faster than a fake-luanch mechanic - so we are foing this for now
				---			if for anyreason the timing of the NIS, or the gameplay pacing needs to change - we need to discuss changing this as a team
				---			before making further adjustments - bfricks 11/27/09
				ForkThread(
					function()
						WaitSeconds(10.0)
						P1_EnableDroneLauncers()
					end
				)
				---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
				---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

				OpNIS.NIS_ALL_COILS_DOWN(unit)

				-- in case the NIS got dev-skipped, set alliance here too.
				SetAlliance( ARMY_ART, ARMY_ENEM01, 'Enemy')

				-- Drone launchers are now attackable.
				for k, v in ScenarioInfo.P1_DroneLauncherTable do
					if v and not v:IsDead() then
						UnProtectUnit(v)
						v:SetUnSelectable(false)
						v:SetCapturable(false)	-- do this after UnProtect
						v:SetReclaimable(false)	-- do this after UnProtect
					end
				end

				-- Gauge and his base are now no longer invuln.
				P1_GaugeUnitsRemoveInvuln()

				-- Gauge nukes the coils that are sending drones at him, after a delay.
				ScenarioFramework.CreateTimerTrigger (function() ForkThread(P1_GaugeNukesCoils_Thread) end, 15)

				-- send the experimentals out
				if ScenarioInfo.ExperimentalTrainPlatoonList then
					local flip = true
					for i = 1,6 do
						local chain = flip and 'P1_ENEM01_ExpTrainWest_Chain' or 'P1_ENEM01_ExpTrainEast_Chain'
						if flip then
							flip = false
						else
							flip = true
						end

						LOG('HandleCoilDestructionForNIS: flip:[', flip, '] chain:[', chain, ']')

						local platoon = ScenarioInfo.ExperimentalTrainPlatoonList[i]
						if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
							ScenarioFramework.PlatoonPatrolChain (platoon, chain)
						end

						WaitSeconds(4)
					end
				end
			end
		)
	end

end

---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------
function GAUGE_CDR_DeathDamage(CDRUnit)
	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_ART],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 50.0, true, 5000, 90001, brainList)
	end
end

---------------------------------------------------------------------
-- VICTORY HANDLING:
---------------------------------------------------------------------
function LaunchVictoryNIS(unit)
	ForkThread(
		function()
			ScenarioInfo.VictoryStarted = true
			ScenarioInfo.ArmyBase_P1_ENEM01_Main_Base:BaseActive(false)
			ScenarioInfo.ArmyBase_P1_ENEM01_WestSide_Base:BaseActive(false)
			ScenarioInfo.ArmyBase_P1_ENEM01_EastSide_Base:BaseActive(false)
			ScenarioInfo.ArmyBase_P1_ENEM01_Front_Base:BaseActive(false)
			if ScenarioInfo.West_EnableExpansionBase then
				ScenarioInfo.ArmyBase_P1_ENEM01_WestExpansion_Base:BaseActive(false)
			end
			if ScenarioInfo.East_EnableExpansionBase then
				ScenarioInfo.ArmyBase_P1_ENEM01_EastExpansion_Base:BaseActive(false)
			end

			ScenarioInfo.AssignedObjectives.VictoryCallbackList = {}
			-- player completed without building exp.
			if not ScenarioInfo.HiddenObj_PlayerBuiltExp then
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
	ScenarioInfo.EastExpansionTimer = true
	East_EnableExpansionBase('test')
end

function OnShiftF4()
	-- import('/lua/system/Utilities.lua').UserConRequest('SallyShears')
	-- import('/lua/system/Utilities.lua').UserConRequest('dbg collision')
	--P1_EnableDroneLauncers()

	ScenarioInfo.P1_ENEM01_Main_Transports:Enable()
	ScenarioInfo.P1_ENEM01_Main_TransAttack_01_OpAI:Enable()
end

function OnShiftF5()
	ScenarioInfo.GAUGE_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'GAUGE_CDR')
	ScenarioInfo.GAUGE_CDR:SetCustomName(ScenarioGameNames.CDR_Gauge)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.GAUGE_CDR, 3)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.GAUGE_CDR, LaunchVictoryNIS)
	ScenarioInfo.GAUGE_CDR:SetCanTakeDamage(true)
end

function OnCtrlF3()
	local mass = 0
	local numMass = 0
	local reclaimables = GetReclaimablesInRect(0, 0, 1024, 1024)
	for k, v in reclaimables do
		if IsProp( v ) then
			numMass = v:GetMassValue()
			if numMass > 1 then
				--LOG('---- GETTING MASS VALUE FOR:[', v:GetBlueprint().BlueprintId, '], amount: ' .. numMass )
				mass = mass + numMass
			end
		end
	end
	LOG('---- MASS: Wreckage mass on map is: ' .. mass )
end