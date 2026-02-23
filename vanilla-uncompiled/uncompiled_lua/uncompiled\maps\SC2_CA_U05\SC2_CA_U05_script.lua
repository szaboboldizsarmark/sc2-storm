---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_U05/SC2_CA_U05_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_U05/SC2_CA_U05_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_U05/SC2_CA_U05_OpNIS.lua')
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
ScenarioInfo.ARMY_CIVL01 = 3

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.P1_CommanderWarningCount = 0

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_CIVL01 = ScenarioInfo.ARMY_CIVL01

local Location01RouteMod = 'b'
local Location02RouteMod = 'b'

local P2_NukeTarget = 0
local P2_NukeEventsAllowed = true

ScenarioInfo.P1_AllowTransports = true

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local P1_SecondaryAssignDelay			= 98	-- Delay before assigning the Kriptor research objective. Idealy, we allow some time for player to get comfy.
local P1_IncreaseStreamTime1			= 170	-- Time delay from start of op for the three points at which we make the attack stream harder (seconds)
local P1_IncreaseStreamTime2			= 370
local P1_IncreaseStreamTime3			= 580
local P1_PartOneDuration				= 690	-- Length of Part1 (seconds)
local P1_TransportDuration				= 550	-- Set transport flag to false. We need time for transports to clean up, so we dont have a new one spawned when the sequence is supposed to be done. (seconds)
local P1_FirstMainAttackTime			= 370	-- Time from start for first main attack (seconds)
local P1_SecondMainAttackTime			= 660	-- Time from start for second main attack. Must occur before end of part1 (seconds)
local P1_ExpResponseDelay				= 37	-- delay between air attacks against player experimentals (seconds)
local P1_AllyUnitHealth					= 6200	-- health value being forced for all various ally items at the east and west popcorn buffer camps

local P2_NukeDelay						= 75 	-- Time between nuke launches in Part2

local P2_Counter_FatboyWeight 			= 20
local P2_Counter_ShieldWeight 			= 3
local P2_Counter_PDWeight 				= 5


---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
-- P1 Initial Player Mobiles	Initial groups of air and land for player. Tune size in editor. F3 Search: IPMD
--								Created in function OnPopulate()
--								NOTE: in editor, these groups are found in folder "PLAYER_P1_Starting_Defense_Mobile"
--
--
-- P1 Initial Enemy Attacks		Attacks in progress from enemy (air, land) that swing by the Civ structures in front of player base first.
--								Tune size in editor, F3 Search: IEAM
--								Created in function OnPopulate()
--								NOTE: in editor, these groups are found in folder "Initial_attacks"
--
--
-- P1 Periodic Main Attacks		Periodic timer-based larger attacks from offmap, from a number of locations.
--								Tune size in editor. F3 Search: EPMA
--								Created in functions P1_MainAttack_01() and P1_MainAttack_02()
--								NOTE: groups found in editor in folder "P1>Attack_groups"
--
--
-- P1 NonOPAI Surgical Response	Gunship response to player building experimentals. Number of groups sent based on player experimental count.
--								Tune size of base group in editor. F3 Search: ESRE
--								Created in function P1_PlayerLandExperimentalResponse(), which is called by trigger loop series.
--								NOTE: base groups found in editor in folder "P1>Attack_groups"
--
--
-- P1 Enemy Attack Stream		Streaming air and land attacks from offmap throughout Part1. Will adjust to higher-order base attack size
--								if player builds experimentals. Intensity ramps up over time.
--								Created in function P1_EnemyStream()
--								NOTE: in editor, the stream attack groups are found in "P1>Stream_Air" and "P1>Stream_Land"
--
--								Tuning: Intesity ramp-up timing: Timer trigger delays in script: variables P1_IncreaseStreamTime1 through P1_IncreaseStreamTime3
--										Timer triggers are in function P1_Main(), and found at F3 Search: ASTD
--								Tuning: Player unit count thresholds (defines main delay modifier)	F3 Search: ASUC
--
--
-- P2 Gunship Response Exp.		Group of gunships created if player starts Part 2 with experimentals. They will not attack
--								until player advances experimentals to middle of map. F3 Search: GREX
--								Tune size in editor, Created in function P2_Setup()
--								NOTE: group found in editor in folder "P2>Starting_Patrols>P2_ENEM01_Gunship_ExpResponseA"
--
--
-- P2 Kriptor Response			Group of land units that patrols in front of Enemy Main. If player moves Kriptor into middle,
--								this group will advance towards player base. F3 Search: LBKR
--								Tune size in editor, Created in function P2_Setup()
--								NOTE: group found in editor in folder "P2>Starting_Patrols>P2_ENEM01_Land_KriptorResponse"
--
--
-- P2 Enemy OpAI Attacks			Three bases (Mid main, West, and East) generate OpAI attacks. Mid base creates large attacks,
--								the West and East smaller attacks.
--								Set up in function P2_BaseAISetup()
--								Tune makeup and size via OpAI settings. Note that some use custom small platoons, so childcount
--								defines size as multiplier.
--
--
-- P2 Main Base OpAIs:
--								midBaseLand_OpAI
--								midBaseAir_OpAI
--
--
-- P2 West Base OpAIs:
--								westBaseLand_OpAI
--								westBaseAir_OpAI
--
--
-- P2 East Base OpAIs:
--								eastBaseLand2_OpAI
--								eastBaseAir_OpAI

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.U05_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.U05_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CIVL01,	ScenarioGameTuning.color_CIV_U05)

	ArmyBrains[ARMY_PLAYER]:CompleteResearch( {'ULU_FATBOY'} )

	LOG('CAMPAIGN OPERATION FLOW:::: OnPopulate: Create Weather')
	local WeatherDefinition = {
		MapStyle = "Tundra",
		WeatherTypes = {
			{
				Type = "WhitePatchyClouds02",
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

	LOG('----- P1_Setup: Set up starting Groups, Platoons, and Patrols')
	-- Player starting unit setup
	ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Starting_Defense_Stationary')
	ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Starting_Sundry')

	LOG('----- P1_Setup: Setup for the player CDR.')
	ScenarioInfo.PLAYER_CDR = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_CDR')
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Create intel for player use
	ScenarioFramework.CreateIntelAtLocation(500, 'PLAYER_Radar_Marker', ARMY_PLAYER, 'Radar')

	-- Player Starting Patrols <IPMD>
	ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_PLAYER', 'P1_PLAYER_Starting_Defense_Mobile_01', 'AttackFormation')
	ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_PLAYER', 'P1_PLAYER_Starting_Defense_Mobile_02', 'AttackFormation')
	local air = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_PLAYER', 'P1_PLAYER_Starting_Defense_Mobile_03', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(air, 'P1_PLAYER_BasePatrol_Air_01')

	-- player engineers
	ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_PLAYER', 'P1_PLAYER_Starting_Engineer_01', 'AttackFormation')

	---# Civ Setup #---
	-- Civilian town
	ScenarioInfo.P1_CIVL01_Town = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P1_CIVL01_Town')
	ScenarioInfo.P1_CIVL01_West = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P1_CIVL01_West')
	ScenarioInfo.P1_CIVL01_East = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P1_CIVL01_East')

	-- protect the city until we are ready to nuke-it
	ProtectGroup(ScenarioInfo.P1_CIVL01_West)
	ProtectGroup(ScenarioInfo.P1_CIVL01_East)

	-- create the anti-nuke
	local antinuke = ScenarioInfo.UnitNames[ARMY_CIVL01]['CIVL01_AntiNuke']
	antinuke:SetCustomName(ScenarioGameNames.UNIT_U05_MissileDefense)
	ProtectUnit(antinuke)

	-- Civ camps in front of player base. Death triggers will update the attack routes that the
	-- enemy streaming attacks use, once they no longer need to attack the civ.
	local group = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P1_CIV01_Camp_West')
	ScenarioFramework.CreateGroupDeathTrigger(P1_UpdateAttackRoute1, group)
	for k, unit in group do
		unit:SetMaxHealth( P1_AllyUnitHealth )
		unit:AdjustHealth( unit, P1_AllyUnitHealth )
	end

	local group = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P1_CIV01_Camp_East')
	ScenarioFramework.CreateGroupDeathTrigger(P1_UpdateAttackRoute2, group)
	for k, unit in group do
		unit:SetMaxHealth( P1_AllyUnitHealth )
		unit:AdjustHealth( unit, P1_AllyUnitHealth )
	end

	local group = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P1_CIV01_Camp_West_02')
	for k, unit in group do
		unit:SetMaxHealth( P1_AllyUnitHealth )
		unit:AdjustHealth( unit, P1_AllyUnitHealth )
	end

	local group = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P1_CIV01_Camp_East_02')
	for k, unit in group do
		unit:SetMaxHealth( P1_AllyUnitHealth )
		unit:AdjustHealth( unit, P1_AllyUnitHealth )
	end

end

function P1_Main()
	-- start Transports
	StartTransportEvacuation()

	----------------------------------------------
	-- Primary Objective M1_obj10 - Prepare and Defend
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Prepare and Defend.')
	local descText = OpStrings.U05_M1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U05_M1_obj10_SURV_PART1)
	ScenarioInfo.M1_obj10 = SimObjectives.Basic(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.U05_M1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('protect'),	-- Action
		{
			Areas = {
				'CAMERA_ZOOM_AREA_01',
				'CAMERA_ZOOM_AREA_02',
				'CAMERA_ZOOM_AREA_03',
				'CAMERA_ZOOM_AREA_04',
			}
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)
	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U05_M1_obj10_SURV_PART1, ARMY_PLAYER, 3.0)
			end
		end
	)

	-- Initial attacks, intended to represent the leftover units of the enemy, from the NIS.
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitLand_NearGroup_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Init_Mid1_Chain')
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_InitLand_NearGroup_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Init_Mid3_Chain')

	--Hidden objective trigger (player builds 4 experimentals)
	ScenarioFramework.CreateArmyStatTrigger (P1_HiddenObj1Complete, ArmyBrains[ARMY_PLAYER], 'PlayerBuilt4Exp',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.EXPERIMENTAL}})


	-- These timers ratchet up the intensity of the stream of enemy units coming in to base <ASTD>
	ScenarioFramework.CreateTimerTrigger (P1_StreamTimedIncrement1, P1_IncreaseStreamTime1)
	ScenarioFramework.CreateTimerTrigger (P1_StreamTimedIncrement1, P1_IncreaseStreamTime2)
	ScenarioFramework.CreateTimerTrigger (P1_StreamTimedIncrement1, P1_IncreaseStreamTime3)

	-- Spawn periodic attacks that mix in with the stream. Note that these attacks must be spawned before
	-- Part1 ends, or they will fail a check. So, keep the second attack spawned before Part2 is triggered
	-- below.
	ScenarioFramework.CreateTimerTrigger (P1_MainAttack_01, P1_FirstMainAttackTime)
	ScenarioFramework.CreateTimerTrigger (P1_MainAttack_02, P1_SecondMainAttackTime)

	-- Flag that the stream is allowed, set it starting at the basic rate, and set the stream to start shortly.
	-- The delay is so we dont get an accidental large attack accumulating at the time-mop structures. Also, note that
	-- the timer trigger forks for us.
	ScenarioInfo.StreamAttackAllowed = true
	ScenarioInfo.P1_StreamLevel = 0
	ScenarioFramework.CreateTimerTrigger (P1_EnemyStream, 10)

	-- VO announcing Secondary objective info and assignment (and research unlocked).
	ScenarioFramework.CreateTimerTrigger (P1_AssignSecondary_VO, P1_SecondaryAssignDelay)

	-- Triggers to detect a built fatboy or kriptor, and play confirmation VO
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerBuiltFatboy_VO, ArmyBrains[ARMY_PLAYER], 'P1_PlayerBuiltFatboy_VO',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0101}})

	-- VO that will remind to the player of the usefulness of shields/towers, if they dont have many built.
	ScenarioFramework.CreateTimerTrigger (P1_ShieldReminder_VO, 240)
	ScenarioFramework.CreateTimerTrigger (P1_DefenseTowerReminder_VO, 360)

	-- Banter based on player losing Experimentals.
	ScenarioFramework.CreateArmyStatTrigger (P1_Banter03_VO, ArmyBrains[ARMY_PLAYER], 'EnemyKilled1Exp',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL}})

	-- Create a trigger loop that will, during part1, respond to a threshold of
	-- player experimentals with gunships and fighters. Note that the first instance gives
	-- the player a brief window before being attacked by the response setup.
	ScenarioFramework.CreateArmyStatTrigger (P1_InitialPlayerLandExpResponse, ArmyBrains[ARMY_PLAYER], 'P1_PlayerExperimentalCheck_Land_Init',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL * categories.LAND}})
	ScenarioFramework.CreateArmyStatTrigger (P1_InitialPlayerAirExpResponse, ArmyBrains[ARMY_PLAYER], 'P1_PlayerExperimentalCheck_Air_Init',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL * categories.AIR}})


	-- Timer that finishes Part 1 of the Op, and advances the Op to Part 2.
	-- This should be longer than any triggered scripted attacks going on.
	-- We shut down the transport sequence a little earlier than the end of Part, so we dont
	-- have transports trying to land when part 2 is under way.
	ScenarioFramework.CreateTimerTrigger (P1_EndPartOne, P1_PartOneDuration)
	ScenarioFramework.CreateTimerTrigger (P1_EndTransportSequence, P1_TransportDuration)


	-- Inital attacks-in-progress groups around the player base (air can use the land route, so they start with
	-- the civ camps). These begin at start, after the NIS ends, adding to the units that are present in the NIS. <IEAM>
	for i = 1, 2 do
		local group = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_InitLand_0' .. i)
		for k, v in group do
			ScenarioFramework.GroupPatrolRoute( { v }, ScenarioUtils.ChainToPositions('P1_ENEM01_InitLand_0' .. i))
		end
	end

	for i = 1, 2 do
		local group = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_InitAir_0' .. i)
		for k, v in group do
			ScenarioFramework.GroupPatrolRoute( { v }, ScenarioUtils.ChainToPositions('P1_ENEM01_InitLand_0' .. i))
		end
	end
end

function P1_AssignSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.U05_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.U05_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P2: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.U05_S1_obj10_NAME,	-- title
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
				ScenarioFramework.Dialogue(OpDialog.U05_RESEARCH_FOLLOWUP_KRIPTOR_010)
			end
		end
	)
	ScenarioFramework.CreateArmyStatTrigger(
		KriptorBuiltVO,
		ArmyBrains[ARMY_PLAYER],
		'P1KriptorBuilt',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'GreaterThanOrEqual',
				Value = 1,
				Category = categories.uux0111
			}
		}
	)
end

function P1_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Tech Lover
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H1_obj10 - Tech Lover')
	local descText = OpStrings.U05_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U05_H1_obj10_MAKE_EXPS)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.U05_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('build'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U05_H1_obj10_MAKE_EXPS, ARMY_PLAYER, 3.0)
end

function KriptorBuiltVO()
	LOG('----- P1: Completed secondary objective 1 - build Kriptor')
	ScenarioFramework.Dialogue(OpDialog.U05_KRIPTOR_BUILT_010)
end

function P1_CommanderLocationWarning()
	-- Warning VO if players CDR wanders out front of the base
	ScenarioInfo.P1_CommanderWarningCount = ScenarioInfo.P1_CommanderWarningCount + 1
	if ScenarioInfo.P1_CommanderWarningCount == 1 then
		ScenarioFramework.Dialogue(OpDialog.U05_P1_LOCATION_WARNING_010)
	elseif ScenarioInfo.P1_CommanderWarningCount == 2 then
		ScenarioFramework.Dialogue(OpDialog.U05_P1_LOCATION_WARNING_020)
	end
end

function P1_InitialPlayerLandExpResponse()
	-- the first time we detect a player exp, give some extra time before we start attacking it
		LOG('------ P1 Surgical: first land exp detected. Main trigger will be recreated in soon.')
	ScenarioFramework.CreateTimerTrigger (P1_CreateLandExpCheckTrigger, 37)
end

function P1_CreateLandExpCheckTrigger()
	-- if the player gets more than 1 experimental.
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerLandExperimentalResponse, ArmyBrains[ARMY_PLAYER], 'P1_PlayerExperimentalCheck_Land',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL * categories.LAND}})
end


function P1_PlayerLandExperimentalResponse()
	-- We have detected that the player has over a threshold of experimentals. Create a gunship platoon, and send it to attack
	-- each experimental. When the platoon dies, we will recreate the check triggers, after a slight pause. <ESRE>
	if ScenarioInfo.PartNumber == 1 then
		LOG('----- P1: Land Experimental Response')

		-- Get a list of experimentals to attack, and a count of experimentals. However, if the
		-- player has any Kirptors going on, inflate the count a touch, so we get a little extra gunships coming out to attack.
		local experimentals = ArmyBrains[ARMY_PLAYER]:GetListOfUnits( categories.EXPERIMENTAL * categories.LAND, false )
		local expCount = table.getn(experimentals)
		local kriptors = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uux0111)
		local gunshipGroupCount = 1
		if kriptors >= 1 then expCount = expCount + 1 end

		LOG('----- P1: Player has exp:', expCount )

		-- Set how many mini-groups of gunships to spawn in and send as one at the player experimentals.
		-- We use a single small group of gunships, spawned in multiple times. The minimum useful
		-- number of mini-groups is 2, which we will send if the player has 1 exp. If the player
		-- has 2 or more experimentals, we will send in 3 mini-groups, as at this point, we do want
		-- to actually get rid of one exp. More than 3 mini-groups of gunships, howeverm, would
		-- be too strong.
		if expCount == 0 then gunshipGroupCount = 1 end	-- safety
		if expCount == 1 then gunshipGroupCount = 2 end
		if expCount == 2 then gunshipGroupCount = 3 end
		if expCount == 3 then gunshipGroupCount = 3 end
		if expCount > 3 then gunshipGroupCount = 3 end

		LOG('----- P1: Groups to send:', gunshipGroupCount )
		-- for safety, check that we have an experimental
		if expCount > 0 then
			LOG('----- P1: Sending gunships')
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i = 1, gunshipGroupCount do
				local units = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Gunship_ExpResponse')
				ScenarioFramework.SetGroupVeterancyLevel(units, 3)
				for k, v in units do
					ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {v}, 'Attack', 'AttackFormation' )
				end
			end

			-- queue up attacks, and then a patrol to go to if they kill all exps.
			for k, v in experimentals do
				if v and not v:IsDead() then
					platoon:AttackTarget(v)
				end
			end
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_InitLand_02')
			ScenarioFramework.CreatePlatoonDeathTrigger (P1_DelayRespawnAntiLandExp, platoon)
		else
			-- reset the check trigger again shortly.
			ScenarioFramework.CreateTimerTrigger (P1_CreateLandExpCheckTrigger, P1_ExpResponseDelay)
		end
	end
end

function P1_InitialPlayerAirExpResponse()
	-- the first time we detect a player exp, give some extra time before we start attacking it
	LOG('------ P1 Surgical: first air exp detected. Main trigger will be recreated in soon.')
	ScenarioFramework.CreateTimerTrigger (P1_CreateAirExpCheckTrigger, 37)
end

function P1_CreateAirExpCheckTrigger()
	-- if the player gets more than 1 experimental.
	ScenarioFramework.CreateArmyStatTrigger (P1_PlayerAirExperimentalResponse, ArmyBrains[ARMY_PLAYER], 'P1_PlayerExperimentalCheck_Air',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL * categories.AIR}})
end


function P1_PlayerAirExperimentalResponse()
	if ScenarioInfo.PartNumber == 1 then
		local experimentals = GetValidListOfUnits(categories.EXPERIMENTAL * categories.AIR)
		local num = table.getn(experimentals)
		local expList = SortEntitiesByDistanceXZ( ScenarioUtils.MarkerToPosition('P2_CounterAttack_DistanceSort_Location'), experimentals )

		-- 3 groups of fighters is all we'll need, even if the player has a lot of ac1000s.
		LOG('------ P1: AntiAC100): detected ' .. num .. ' ac1000s.')
		if num > 3 then
			num = 3
			LOG('------ P1: AntiAC100): clamped to ' .. num .. ' ac1000s for response.')
		end


		if num > 0 then -- entire list could theoretically be invalid/being built
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i = 1, num do
				-- 5 fighters created per ac1000
				for j = 1, 5 do
					local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_COUNTER_Single_Fighter')
					ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
				end
			end
			ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 3)

			LOG('------ P1: AntiAC100): send attack.')

			-- send out to attack each exp, and go on a patrol afterwards if still alive.
			for k, v in expList do
				platoon:AttackTarget(v)
			end
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_InitLand_02')
			ScenarioFramework.CreatePlatoonDeathTrigger (P1_DelayRespawnAntiAirExp, platoon)
		else
			ScenarioFramework.CreateTimerTrigger (P1_CreateAirExpCheckTrigger, P1_ExpResponseDelay)
		end
	end
end

function P1_DelayRespawnAntiLandExp()
	-- as the enemy gunships responding to player experimentals are spawned in instead of built,
	-- we want a slight delay before we recreate the detect triggers. Otherwise, the response will
	-- look a little too mechanical and immediate.
	ScenarioFramework.CreateTimerTrigger (P1_CreateLandExpCheckTrigger, P1_ExpResponseDelay)
end

function P1_DelayRespawnAntiAirExp()
	ScenarioFramework.CreateTimerTrigger (P1_CreateAirExpCheckTrigger, P1_ExpResponseDelay)
end

function P1_MainAttack_01()
	--Moderate combined attack, with land and air <EPMA>
	if ScenarioInfo.PartNumber == 1 then
		LOG('----- P1: Scripted Attack 01: spawning.')
		local platoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AttackGroups_West_Land', 'AttackFormation')
		local platoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AttackGroups_Mid_Air', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon1, 'P1_ENEM01_LandAttackRoute_01')
		ScenarioFramework.PlatoonPatrolChain(platoon2, 'P1_ENEM01_AirAttackRoute_02')

		local exp = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL)
		if exp > 0 then
			LOG('----- P1: Scripted Attack 01: player has experimentals. Adding extra attackers.')
			local platoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AttackGroups_Mid_Land', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon1, 'P1_ENEM01_LandAttackRoute_02')
		end

		-- play some VO when the attack is destroyed (place all the attackers in a group).
		local group = {}
		for k, v in platoon1:GetPlatoonUnits() do
			table.insert(group, v)
		end
		for k, v in platoon2:GetPlatoonUnits() do
			table.insert(group, v)
		end
		ScenarioFramework.CreateGroupDeathTrigger(P1_Banter01_VO, group)
	end
end

function P1_MainAttack_02()
	--Moderate combined attack, with land and air <EPMA>
	if ScenarioInfo.PartNumber == 1 then
		LOG('----- P1: Scripted Attack 02 spawning.')
		local platoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AttackGroups_Mid_Land', 'AttackFormation')
		local platoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AttackGroups_East_Air', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon1, 'P1_ENEM01_LandAttackRoute_02')
		ScenarioFramework.PlatoonPatrolChain(platoon2, 'P1_ENEM01_AirAttackRoute_03')

		local exp = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL)
		if exp > 0 then
			LOG('----- P1: Scripted Attack 02: player has experimentals. Adding extra attackers.')
			local platoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AttackGroups_East_Land', 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon1, 'P1_ENEM01_LandAttackRoute_03')
		end

		-- play some VO when the attack is destroyed (place all the attackers in a group).
		local group = {}
		for k, v in platoon1:GetPlatoonUnits() do
			table.insert(group, v)
		end
		for k, v in platoon2:GetPlatoonUnits() do
			table.insert(group, v)
		end
		ScenarioFramework.CreateGroupDeathTrigger(P1_Banter02_VO, group)
	end
end

function P1_DefenseTowerReminder_VO()
	-- if the player doesnt have many defense towers, remind them they are useful to build.
	local units = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uub0101 + categories.uub0102, false)
	if table.getn(units) < 12 then
		ScenarioFramework.Dialogue(OpDialog.U05_BUILD_ADVICE_010)
	end
end

function P1_ShieldReminder_VO()
	-- if the player doesnt have many shields, remind them they are useful to build.
	local units = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uub0202, false)
	if table.getn(units) < 3 then
		ScenarioFramework.Dialogue(OpDialog.U05_BUILD_ADVICE_020)
	end
end

function P1_PlayerBuiltFatboy_VO()
	ScenarioFramework.Dialogue(OpDialog.U05_FATBOY_BUILT_010)
end

function P1_Banter01_VO()
	LOG('----- P1: banter vo')
	ScenarioFramework.Dialogue(OpDialog.U05_BANTER_PRENUKE_010)
end

function P1_Banter02_VO()
	LOG('----- P1: banter vo')
	ScenarioFramework.Dialogue(OpDialog.U05_BANTER_PRENUKE_030)
end

function P1_Banter03_VO()
	if ScenarioInfo.PartNumber == 1 then
		LOG('----- P1: banter vo')
		ScenarioFramework.Dialogue(OpDialog.U05_BANTER_PRENUKE_020)
	end
end

function P1_EndTransportSequence()
	-- flag the transport sequence to no longer create transports. Note that any
	-- transport en-route will still do the landing sequence etc. So, we should
	-- call this function *earlier* than the end of part1.
	ScenarioInfo.P1_AllowTransports = false
end

function P1_EndPartOne()
	-- Flag the stream thread that its time to shut the stream down.
	ScenarioInfo.StreamAttackAllowed = false

	-- Based on timer, force complete the initial objective, and advance the op
	ScenarioInfo.M1_obj10:ManualResult(true)
	ScenarioFramework.Dialogue(OpDialog.U05_M1_obj10_COMPLETE, P2_Setup)
end

---------------------------------------------------------------------
-- P1 ATTACK STREAM FUNCTIONS:
---------------------------------------------------------------------
function P1_StreamTimedIncrement1()
	-- Increment the counter that is the basis of the difficulty of the Stream
	ScenarioInfo.P1_StreamLevel = ScenarioInfo.P1_StreamLevel + 1
	LOG('---- P1: Land Stream - Level incremented by timer trigger to ' .. ScenarioInfo.P1_StreamLevel)
end

function P1_EnemyStream()
	LOG('----- P1: P1 Stream begun.')

	-- This function loops, checking how many units the player and enemy has, checking
	-- where in a growing trend of difficulty we should be, and deciding how many of a
	-- number of enemy groups are spawned and sent at the player. Its core purpose is to
	-- set the variable 'currentLevel' every loop, which ultimately represents the number of
	-- locations we will spawn attacks from each loop. As the Part progresses and the player
	-- as well), enemies will begin coming from more and more locations.


	-- every N loops, we will spawn some air
	local airPass = 0

	-- we will switch routes after the civilian camps in front of players base are destroyed,
	-- going from a custom route that veers in the camps direction, to the general route
	-- (for routes 1 and 2).
	local routeMod

	-- We will use different platoons if the player has experimentals. Normal platoons are
	-- named '_easy' and large platoons '_hard'.
	local groupMod = '_easy'

	while ScenarioInfo.StreamAttackAllowed and ScenarioInfo.PartNumber == 1 do

		-- currentLevel is the basis for how many units we spawn. Each loop, reset it
		-- to match the basis of where we are in the growing difficulty: P1_StreamLevel, which is
		-- slowly incremented by timer triggers elsewhere.
		local currentLevel = ScenarioInfo.P1_StreamLevel
		LOG('-----------------------------------')
		LOG('---- STREAM: (default currentlevel is ' .. currentLevel .. ')')

		-- at different points, we will want to check how the player and enemy are doing, unit-count wise
		-- the value adjustedCount is the final value we will check, which takes into account experimentals
		-- and adjusts the player unit count up, treating experimentals as counting for 15 normal units.
		local playerMobileCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.MOBILE - categories.uul0002)	-- mobile minus engineers
		local playerPDCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0101)
		local enemyUnitCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		local playerExpCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL)
		local adjustedCount = playerMobileCount + (playerExpCount * 17) + (playerPDCount * 4) -- weight the different types, and add up.
		LOG('---- STREAM: Player value is ' .. adjustedCount)

		-- If the enemy has accumulated more than N units, we should skip spawning more: the player
		-- probably has more than enough on their hands, and the purpose of the stream isnt really to
		-- overwhelm the player.
		if enemyUnitCount < 65 then

			-- A variety of different thresholds result in currentLevel being increased or decreased,
			-- based on how the player is doing. <ASUC>
			if adjustedCount < 23 then
				currentLevel = currentLevel - 2
			elseif adjustedCount >= 23 and adjustedCount <= 40 then
				currentLevel = currentLevel - 1
			elseif adjustedCount > 40 and adjustedCount <= 50 then
				currentLevel = currentLevel + 0
			elseif adjustedCount > 50 and adjustedCount <= 68 then
				currentLevel = currentLevel + 1
			elseif adjustedCount > 68 and adjustedCount <= 81 then
				currentLevel = currentLevel + 2
			elseif adjustedCount > 81 then
				currentLevel = currentLevel + 3
			end

			LOG('---- STREAM: CurrentLevel raw is ' .. currentLevel .. '...')

			-- As we have only up to 4 things to spawn, put currentLevel in that context.
			if currentLevel <= 0 then currentLevel = 1 end
			if currentLevel > 4 then currentLevel = 4 end

			LOG('---- STREAM: CurrentLevel normalized is ' .. currentLevel .. '.')

			-- if the player has experimentals or a lot of units in general, we switch to use the large ('..._hard')
			-- platoons. Otherwise, use the small normal sized platoons ('..._easy')).
			if playerExpCount > 0 or adjustedCount > 95 then
				groupMod = '_hard'
			else
				groupMod = '_easy'
			end

			-- Spawn a selection of groups 1 through 4, as dictated by currentLevel. As we are using a pause
			-- during this, check before each spawn that we are allowed to continue the stream (in case the Operation
			-- has continued to Part 2, for example, revealing our spawn areas).
			for i = 1, currentLevel do
				if ScenarioInfo.StreamAttackAllowed then
					-- when the civ camps are destroyed, swap from the 'b' routes to the normal attack routes.
					-- This is just for routes 1 and 2, otherwise just use the normal routes for 3 and 4. We
					-- set/update that route mods elsewhere.
					if i == 1 then routeMod = Location01RouteMod end
					if i == 2 then routeMod = Location02RouteMod end
					if i > 2 then routeMod = '' end
					local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PopcornLand_0' .. i .. groupMod, 'AttackFormation')
					ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_LandAttackRoute_0' .. i .. routeMod)
					WaitSeconds(1)
				end
			end
		end

		-- Air section: Every third round , do an air pass. (Spawning air every round
		-- would be a bit too heavy.)
		airPass = airPass + 1

		-- Check where we are, and if the enemy is getting overstocked with units (and that
		-- its still alright for the stream to be running).
		if airPass == 3 and enemyUnitCount < 65 and ScenarioInfo.StreamAttackAllowed then
			LOG('---- STREAM: Spawning air this round. airPass = ' .. airPass)

			-- If the player is doing very very well, lets take this as a sign we need to hit harder with air,
			-- and cheat the airPass counter up a bit, so we will spawn air more frequently. Otherwise,
			-- set it back to normal zero.
			if adjustedCount <= 145 then
				airPass = 0
			else
				airPass = 2
			end

			-- currentLevel is built to handle 4 groups of land units, whereas we only are using 3
			-- groups of air units. So, collapse this down to a new variable to be used for spawning.
			local airLevel = currentLevel
			if airLevel >= 4 then airLevel = 3 end
			LOG('---- STREAM: airLevel = ' .. airLevel)

			-- spawn the number of air groups as defined by airLevel
			for i = 1, airLevel do
				local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PopcornAir_0' .. i, 'AttackFormation')
				ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_AirAttackRoute_0' .. i)
			end
		end

		-- if the enemy has gotten up to N units, this is probably a sign that the player is beginning to have
		-- difficulty keeping up with them all. Slow things down so the player can catch up a bit.
		if enemyUnitCount > 52 then
			LOG('---- STREAM: enemyUnitCount over 52, waiting longer before next loop.')
			LOG('-----------------------------------')
			WaitSeconds(21)


		-- Player's value has gotten too high, so we will use a very short delay before next loop.
		elseif enemyUnitCount <= 52 and adjustedCount > 145 then
			LOG('---- STREAM: player value is very high, at ' .. adjustedCount .. ', so using a very short wait.')
			LOG('-----------------------------------')
			WaitSeconds(5)

		else
			LOG('---- STREAM: Normal pause between loop.')
			LOG('-----------------------------------')
			-- Vary the wait between loops to take into account the varying time spent in the loop.
			-- The goal here is to have broadly similar time betwen spawns at any one point
			WaitSeconds(9 + (5 - currentLevel))
		end
	end
end

function P1_UpdateAttackRoute1()
	LOG('----- P1: Civ camp 1 destroyed, updating route that stream attack uses.')

	-- The west civ camp has been destroyed, so update the route that stream route 1 uses, to no
	-- longer veer towards the civ buildings. We are switching from route '...01b' to '...01'
	Location01RouteMod = ''
end

function P1_UpdateAttackRoute2()
	LOG('----- P1: Civ camp 2 destroyed, updating route that stream attack uses.')

	-- The east civ camp has been destroyed, so update the route that stream route 1 uses, to no
	-- longer veer towards the civ buildings. We are switching from route '...01b' to '...01'
	Location02RouteMod = ''
end


---------------------------------------------------------------------
-- P1 TRANSPORT STREAM:
---------------------------------------------------------------------
function StartTransportEvacuation()
	-- define an interval between when each transport will begin their movement
	local startInterval = 6.0

	-- West Transports
	for i=1,3 do
		local transport = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_CIVL01_Trans_West')
		ProtectUnit(transport)
		transport:SetUnSelectable(true)

		-- increment the value of startinterval here, then pass it in, so the forkthread gets the correct mathematical duration
		local startInterval = startInterval * i

		-- create the landing marker str name
		local landingMarker = 'TRANS_LANDING_WEST_0' .. i
		ForkThread(
			function(startInterval,landingMarker)
				-- wait for the interval
				WaitSeconds(startInterval)

				-- begin loop
				P1_MoveUnitToLandingPoint(transport, 'P1_TransportEvac_West_Approach', 'P1_TransportEvac_West_Return',landingMarker)
			end,
			startInterval,
			landingMarker
		)
	end

	-- East Transports
	for i=1,3 do
		local transport = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_CIVL01_Trans_East')
		ProtectUnit(transport)
		transport:SetUnSelectable(true)

		-- increment the value of startinterval here, then pass it in, so the forkthread gets the correct mathematical duration
		local startInterval = startInterval * i

		-- create the landing marker str name
		local landingMarker = 'TRANS_LANDING_EAST_0' .. i
		ForkThread(
			function(startInterval,landingMarker)
				-- wait a beat so this set of transports is timed differently than the other two
				WaitSeconds(1.0)

				-- wait for the interval
				WaitSeconds(startInterval)

				-- begin loop
				P1_MoveUnitToLandingPoint(transport, 'P1_TransportEvac_East_Approach', 'P1_TransportEvac_East_Return',landingMarker)
			end,
			startInterval,
			landingMarker
		)
	end


	-- South Transports
	for i=1,6 do
		local transport = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_CIVL01_Trans_South01')
		ProtectUnit(transport)
		transport:SetUnSelectable(true)

		-- increment the value of startinterval here, then pass it in, so the forkthread gets the correct mathematical duration
		local startInterval = startInterval * i

		-- create the landing marker str name
		local landingMarker = 'TRANS_LANDING_SOUTH_0' .. i
		ForkThread(
			function(startInterval,landingMarker)
				-- wait a beat so this set of transports is timed differently than the other two
				WaitSeconds(2.0)

				-- wait for the interval
				WaitSeconds(startInterval)

				-- begin loop
				P1_MoveUnitToLandingPoint(transport, 'P1_TransportEvac_South_Approach', 'P1_TransportEvac_South_Return',landingMarker)
			end,
			startInterval,
			landingMarker
		)
	end
end

function P1_MoveUnitToLandingPoint(unit, approachChain, returnChain,landingMarker)
	if unit and not unit:IsDead() then
		-- transports allowed only during Part1
		if ScenarioInfo.P1_AllowTransports then
			IssueClearCommands({unit})
			for k,v in ScenarioUtils.ChainToPositions(approachChain) do
				IssueMove( {unit}, v )
			end

			-- when landing use a specific point - so all the transports for this route don't stack up
			destination = ScenarioUtils.MarkerToPosition(landingMarker)
			IssueMove( {unit}, destination )

			ScenarioFramework.CreateUnitToMarkerDistanceTrigger(
				function()
					P1_MoveUnitToOffmap(unit, approachChain, returnChain,landingMarker)
				end,
				unit,
				destination,
				12.0
			)

		-- Part2 is over, so no more transports.
		else
			ForceUnitDeath(unit)
		end
	end
end

function P1_MoveUnitToOffmap(unit, approachChain, returnChain,landingMarker)
	if unit and not unit:IsDead() then
		---NOTE: with the new start mechanic, I have removed this randomness and increased the duration - so the evacs are more bursts of activity - bfricks 11/8/09
		WaitSeconds (24.0) -- Dist triggers are forked.

		local destination = nil
		for k,v in ScenarioUtils.ChainToPositions(returnChain) do
			IssueMove( {unit}, v )
			destination = v
		end

		ScenarioFramework.CreateUnitToMarkerDistanceTrigger(
			function()
				P1_MoveUnitToLandingPoint(unit, approachChain, returnChain,landingMarker)
			end,
			unit,
			destination,
			12.0
		)
	end
end

---------------------------------------------------------------------
-- PART 2:
---------------------------------------------------------------------
function P2_Setup()
	LOG('----- P2_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 2

	LOG('----- P2: Initial setup and creation of Part 2 units, commands, etc')
	ScenarioInfo.EnemyCommander = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_CDR')
	ScenarioInfo.EnemyCommander:SetCustomName(ScenarioGameNames.CDR_Lynch)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.EnemyCommander, 4)

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.EnemyCommander:RemoveCommandCap('RULEUCC_Reclaim')

	-- CDR death damage triggers
	ScenarioFramework.CreateUnitDeathTrigger(EnemyCommander_DeathDamage, ScenarioInfo.EnemyCommander)

	-- DEBUG: setting this flag is not necessary here, but is to aid debugging, which may start Part2
	-- without letting a timer-based setting of this flag complete. -Greg
	ScenarioInfo.P1_AllowTransports = false

	-- enemy nukes
	ScenarioInfo.P1_ENEM01_NukeLauncher1 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_ICBM_01')
	ScenarioInfo.P1_ENEM01_NukeLauncher2 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_ICBM_02')
	-- turn off the TML on the nuke launchers, as their range is too much for a small map.
	---NOTE: in this case we do NOT want to use SetAttackerEnabled(false) - because we just want the TML disabled - not the nukes - bfricks 9/30/09
	ScenarioInfo.P1_ENEM01_NukeLauncher1:SetWeaponEnabledByLabel( 'TacticalMissile01', false )
	ScenarioInfo.P1_ENEM01_NukeLauncher2:SetWeaponEnabledByLabel( 'TacticalMissile01', false )


	-- some Civ buildings out on the docks, to nuke
	ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'P2_CIVL01_CivBuildings')

	-- set up bases and opais
	P2_BaseAISetup()

	-- Starting Patrols
	local units1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_West_AirPatrol', 'AttackFormation')
	local units2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Mid_AirPatrol', 'AttackFormation')
	local units3 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_East_AirPatrol', 'AttackFormation')
	PlatoonRandomPatrol(units1, 'P2_ENEM01_WestAir_Patrol_01')
	PlatoonRandomPatrol(units2, 'P2_ENEM01_MidAir_Patrol_01')
	PlatoonRandomPatrol(units3, 'P2_ENEM01_EastAir_Patrol_01')


	--------------------------
	-- Anti-Experimental Patrols
	--------------------------

	-- Gunship patrol above enemy base, waiting for any experimental (land or air) to advance into the main area of the map.
	ScenarioInfo.P2_ENEM01_ExpResponse_Air_A = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Gunship_ExpResponseB', 'AttackFormation')
	PlatoonRandomPatrol(ScenarioInfo.P2_ENEM01_ExpResponse_Air_A, 'P2_ENEM01_MidAir_Patrol_01')
	ScenarioFramework.CreateAreaTrigger(P2_GunshipsAttackExp_A, 'P2_ExperimentalDetect_Area_Large',
		categories.EXPERIMENTAL, true, false, ArmyBrains[ARMY_PLAYER], 1 )


	-- As well, if the player has experimentals, create an *extra* group of gunships who will hang out above the main base, waiting for
	-- player land experimentals to advance before attacking exps.
	local numExp = table.getn(ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.EXPERIMENTAL * categories.LAND, false))
	if numExp > 0 then
		-- spawn in a large group of gunships, and put them in holding pattern.
		ScenarioInfo.P2_ENEM01_ExpResponse_Air_B = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Gunship_ExpResponseB', 'AttackFormation')
		PlatoonRandomPatrol(ScenarioInfo.P2_ENEM01_ExpResponse_Air_B, 'P2_ENEM01_MidAir_Patrol_01')

		-- Create an area trigger to detect player exps, that we will send the gunships to.
		ScenarioFramework.CreateAreaTrigger(P2_GunshipsAttackExp_B, 'P2_ExperimentalDetect_Area_Large',
			categories.EXPERIMENTAL * categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 1 )
	end


	-- Similarly, create a land platoon that patrols at the mid base rally point. Trigger will
	-- detect the player moving experimentals into the middle of the map, and send this platoon towards
	-- the player. <LBKR>
	ScenarioInfo.P2_ENEM01_ExpResponse_Land = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Land_KriptorResponse', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM01_ExpResponse_Land, 'P2_ENEM01_Mid_RallyArea_DefPatrol')

 	-- Player moves a fatboy or ac100 into anywhere near the midmap, send in a waiting patrol
	ScenarioFramework.CreateAreaTrigger(P2_ExperimentalResponse, 'P2_ExperimentalDetect_Area_Large',
		categories.uux0102 + categories.uux0101, true, false, ArmyBrains[ARMY_PLAYER], 1 )

	-- Player moves a Kriptor into a narrow portion of the midmap, send in a patrol. (Kriptor is short
	-- range, so this will delay sending the attack in, letting the player move out a bit more).
	ScenarioFramework.CreateAreaTrigger(P2_ExperimentalResponse, 'P2_ExperimentalDetect_Area_Large02',
		categories.uux0111, true, false, ArmyBrains[ARMY_PLAYER], 1 )


	ForkThread(P2_Transition)
end

function P2_Transition()
	OpNIS.NIS_REVEAL_ENEMY()

	---NOTE: custom clearing to hide the enemy base - unique handling for this operation - bfricks 11/14/09
	local rect = ScenarioUtils.AreaToRect('P2_ExperimentalDetect_Area_Large')
	FlushIntelInRect( rect.x0, rect.y0, rect.x1, rect.y1 )

	P2_Main()
end

function P2_Main()
	-- generate a general/targetted counterattack against the player.
	P2_CounterAttack()

	----------------------------------------------
	-- Primary Objective M2_obj10 - Destroy the Enemy CDR
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M2_obj10 - Destroy the Enemy CDR.')
	local descText = OpStrings.U05_M2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U05_M2_obj10_KILL_CDR)
	ScenarioInfo.M2_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.U05_M2_obj10_NAME,			-- title
		descText,								-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.EnemyCommander},
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)
	ScenarioInfo.M2_obj10:AddResultCallback(
		function(result)
			if result and ScenarioInfo.VictoryTracker < 3 then
				---NOTE: i changed this so the dialog only plays when you have not finished all three victory kills - bfricks 9/1/09
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U05_M2_obj10_KILL_CDR, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.U05_ENEMY_CDR_DESTROYED_010)
			end
		end
	)

	----------------------------------------------
	-- Primary Objective M3_obj10 - Destroy Enemy Nukes
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M3_obj10 - Destroy Enemy Nukes.')
	local descText = OpStrings.U05_M3_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U05_M3_obj10_KILL_NUKES)
	ScenarioInfo.M3_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.U05_M3_obj10_NAME,			-- title
		descText,								-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = { ScenarioInfo.P1_ENEM01_NukeLauncher1, ScenarioInfo.P1_ENEM01_NukeLauncher2 },
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M3_obj10)
	ScenarioInfo.M3_obj10:AddProgressCallback(
		function(current, total)
			-- We will disable the nuke setup when the enemy commander dies, so encouraging VO
			-- is not really appropriate.
			if current == 1 and ScenarioInfo.EnemyCommander and not ScenarioInfo.EnemyCommander:IsDead() then
				ScenarioFramework.Dialogue(OpDialog.U05_M3_obj10_PROGRESS_010)
			end
		end
	)
	ScenarioInfo.M3_obj10:AddResultCallback(
		function(result)
			if result and ScenarioInfo.VictoryTracker < 3 then
				---NOTE: i changed this so the dialog only plays when you have not finished all three victory kills - bfricks 9/1/09
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U05_M3_obj10_KILL_NUKES, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.U05_M3_obj10_COMPLETE)
			end
		end
	)

	-- enemy cdr on patrol, now that NIS is complete.
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.EnemyCommander}, ScenarioUtils.ChainToPositions('P2_ENEM01_CDR_Patrol'))

	-- setup each possible ending unit for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.EnemyCommander, HandlePossibleVictory)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P1_ENEM01_NukeLauncher1, HandlePossibleVictory)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P1_ENEM01_NukeLauncher2, HandlePossibleVictory)

	-- Looping nuke events, targetting the city.
	ForkThread(P2_NukeEvents_Thread)

	-- VO, banter based on player killing enemy factories.
	ScenarioFramework.CreateArmyStatTrigger (P2_Banter01_VO, ArmyBrains[ARMY_ENEM01], 'EnemyLost1Factory',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY}})
	ScenarioFramework.CreateArmyStatTrigger (P2_Banter02_VO, ArmyBrains[ARMY_ENEM01], 'EnemyLost4Factory',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.FACTORY}})

end

function P2_Banter01_VO()
	ScenarioFramework.Dialogue(OpDialog.U05_BANTER_POSTNUKE_010)
end

function P2_Banter02_VO()
	ScenarioFramework.Dialogue(OpDialog.U05_BANTER_POSTNUKE_020)
end

function P2_GunshipsAttackExp_A()
	-- Player has sent experimentals into the middle area. We respond by sending the waiting gunship platoon to them. (air and land)
	if ScenarioInfo.P2_ENEM01_ExpResponse_Air_A and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_ENEM01_ExpResponse_Air_A) then
		LOG('----- P2: Player experimental has moved into midmap. Sending gunships from a response group.')

		-- Get a list of player experimentals, then sort them by distance, so we attack the closest first, and
		-- the ones that may be in their base last.
		local experimentals = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.EXPERIMENTAL, false)
		local expList = SortEntitiesByDistanceXZ( ScenarioUtils.MarkerToPosition('P2_ENEM01_BaseMid_Marker'), experimentals )

		IssueClearCommands(ScenarioInfo.P2_ENEM01_ExpResponse_Air_A:GetPlatoonUnits())
		for k, v in expList do
			if v and not v:IsDead() then
				ScenarioInfo.P2_ENEM01_ExpResponse_Air_A:AttackTarget(v)
			end
		end
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM01_ExpResponse_Air_A, 'P2_ENEM01_General_MidPatrol_01')
	end
end

function P2_GunshipsAttackExp_B()
	-- Player has sent experimentals into the middle area. We respond by sending the waiting gunship platoon to them. (land exp)
	if ScenarioInfo.P2_ENEM01_ExpResponse_Air_B and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_ENEM01_ExpResponse_Air_B) then
		LOG('----- P2: Player land experimental has moved into midmap. Sending gunships from a response group.')

		-- Get a list of player experimentals, then sort them by distance, so we attack the closest first, and
		-- the ones that may be in their base last.
		local experimentals = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.EXPERIMENTAL * categories.LAND, false)
		local expList = SortEntitiesByDistanceXZ( ScenarioUtils.MarkerToPosition('P2_ENEM01_BaseMid_Marker'), experimentals )

		IssueClearCommands(ScenarioInfo.P2_ENEM01_ExpResponse_Air_B:GetPlatoonUnits())
		for k, v in expList do
			if v and not v:IsDead() then
				ScenarioInfo.P2_ENEM01_ExpResponse_Air_B:AttackTarget(v)
			end
		end
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM01_ExpResponse_Air_B, 'P2_ENEM01_General_MidPatrol_01')
	end
end

function P2_ExperimentalResponse()
	-- Player has moved an exp into the middle area. Send our rally point defense platoon towards the player's base.
	if not ScenarioInfo.P2_ExperimentalResponseComplete then
		ScenarioInfo.P2_ExperimentalResponseComplete = true
		if ScenarioInfo.P2_ENEM01_ExpResponse_Land and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_ENEM01_ExpResponse_Land ) then
			LOG('----- P2: Player has moved an exp into midmap, and a response platoon is still around. Sending it to player base. ')

			IssueClearCommands(ScenarioInfo.P2_ENEM01_ExpResponse_Land:GetPlatoonUnits())
			ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM01_ExpResponse_Land, 'P2_ENEM01_MidBase_Land_Chain_01')
		end
	end
end

function P2_NukeEvents_Thread()
	LOG('----- P2: nuke thread started')

	-- pause before we begin the nukes.
	WaitSeconds(P2_NukeDelay)

	while P2_NukeEventsAllowed do
		if not ScenarioInfo.P1_ENEM01_NukeLauncher1:IsDead() or not ScenarioInfo.P1_ENEM01_NukeLauncher2:IsDead() then
			local rndLauncer = Random(1, 2)
			if rndLauncer == 1 then
				P2_WestNuke(false)
			else
				P2_EastNuke(false)
			end
			LOG('----- P2: attempting to launch from nuke ' .. rndLauncer)

			WaitSeconds(P2_NukeDelay)
		else
			LOG('----- P2:all nuke launchers destroyed, ending nuke thread. ')
			P2_NukeEventsAllowed = false
		end
	end
end

function P2_WestNuke(retry)
	LOG('----- P2_WestNuke event:')
	-- if this nuke launcher is around, increment the target counter, and fire a nuke off.
	if ScenarioInfo.P1_ENEM01_NukeLauncher1 and not ScenarioInfo.P1_ENEM01_NukeLauncher1:IsDead() then
		-- there are ten markers as targets to nuke. Cycle through them, and start over when we've gone through them all.
		P2_NukeTarget = P2_NukeTarget + 1
		if P2_NukeTarget > 10 then P2_NukeTarget = 1 end

		ScenarioInfo.P1_ENEM01_NukeLauncher1:GiveNukeSiloAmmo(1)
		local pos = ScenarioUtils.MarkerToPosition('P1_NukeSpot_' .. P2_NukeTarget)
		IssueNuke({ScenarioInfo.P1_ENEM01_NukeLauncher1}, pos)
		ForkThread(DestroyCityPosThread,pos)

		LOG('----- P2_WestNuke: nuke launched at target ' .. P2_NukeTarget)

	-- if this launcher is dead, however, try the other one. Set the retry flag as true so that,
	-- if the other is also dead, we dont loop.
	else
		LOG('----- P2_WestNuke: west launcher is dead.')
		if not retry then
			P2_EastNuke(true)
		else
			return
		end
	end
end

function P2_EastNuke(retry)
	LOG('----- P2_EastNuke event:')
	-- if this nuke launcher is around, increment the target counter, and fire a nuke off.
	if ScenarioInfo.P1_ENEM01_NukeLauncher2 and not ScenarioInfo.P1_ENEM01_NukeLauncher2:IsDead() then
		-- there are ten markers as targets to nuke. Cycle through them, and start over when we've gone through them all.
		P2_NukeTarget = P2_NukeTarget + 1
		if P2_NukeTarget > 10 then P2_NukeTarget = 1 end

		ScenarioInfo.P1_ENEM01_NukeLauncher2:GiveNukeSiloAmmo(1)
		local pos = ScenarioUtils.MarkerToPosition('P1_NukeSpot_' .. P2_NukeTarget)
		IssueNuke({ScenarioInfo.P1_ENEM01_NukeLauncher2}, pos)
		ForkThread(DestroyCityPosThread,pos)

		LOG('----- P2_EastNuke: nuke launched at target ' .. P2_NukeTarget)

	-- if this launcher is dead, however, try the other one. Set the retry flag as true so that,
	-- if the other is also dead, we dont loop.
	else
		LOG('----- P2_EastNuke: east launcher is dead.')
		if not retry then
			P2_WestNuke(true)
		else
			return
		end
	end
end

function DestroyCityPosThread(pos)
	-- get units around the position and sort the list.
    local units = ArmyBrains[ARMY_CIVL01]:GetUnitsAroundPoint( categories.ALLUNITS, pos, 50, 'Ally')
	ScenarioFramework.AllowGroupDeath(units)
end

function P2_BaseAISetup()

	-----------------
	--- Main Base
	-----------------

	-- note: dont add the enemy CDR as engineer, so he doesnt get tempted to wander out to the
	-- rally point area and repair.
	local levelTable = {P2_ENEM01_Base_Mid_100 = 100,
						P2_ENEM01_Base_Mid_90 = 90,}
	ScenarioInfo.ArmyBaseMid = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P2_ENEM01_Base_Mid',
		 'P2_ENEM01_BaseMid_Marker', 50, levelTable)
	ScenarioInfo.ArmyBaseMid:StartNonZeroBase(2)
	ScenarioInfo.ArmyBaseMid:SetBuildAllStructures(false)

	-- Sticking with manual rallies, so that placed rally markers dont interfere with nearby bases.
	for i = 1, 4 do
		local factory = ScenarioInfo.UnitNames[ARMY_ENEM01]['P2_ENEM01_Base_Mid_Factory0' .. i]
		IssueClearFactoryCommands( {factory} )
		IssueFactoryRallyPoint( {factory}, ScenarioUtils.MarkerToPosition( 'P2_ENEM01_MidBase_Rally' ) )
	end

	for i = 5, 7 do
	local factory = ScenarioInfo.UnitNames[ARMY_ENEM01]['P2_ENEM01_Base_Mid_Factory0' .. i .. 'a']
		IssueClearFactoryCommands( {factory} )
		IssueFactoryRallyPoint( {factory}, ScenarioUtils.MarkerToPosition( 'P2_ENEM01_MidBase_AirRally' ) )
	end


	-- Basic land attack
	local midBaseLand_OpAI 				= ScenarioInfo.ArmyBaseMid:AddOpAI('LandAttackUEF', 'Land_Attack_MidBase_01', {} )
	local midBaseLand_OpAI_data			= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_MidBase_Land_Chain_01', 'P2_ENEM01_MidBase_Land_Chain_02'},}
	midBaseLand_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', midBaseLand_OpAI_data )
	midBaseLand_OpAI:					SetMaxActivePlatoons(3)


	-- Basic air attack
	local midBaseAir_OpAI 				= ScenarioInfo.ArmyBaseMid:AddOpAI('AirAttackUEF', 'Air_Attack_MidBase_01', {} )
	local midBaseAir_OpAI_data			= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttackRoute_02',},}
	midBaseAir_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', midBaseAir_OpAI_data )
	midBaseAir_OpAI:					SetChildCount(2)
	midBaseAir_OpAI:					SetMaxActivePlatoons(3)


	--# Surgical Response OpAI's if the player builds over-powerful units, or builds too many of certain units.
	-- Too many land units of some types
	local ENEM01_PlayerExcessLand_OpAI			= ScenarioInfo.ArmyBaseMid:AddOpAI('AirResponsePatrolLand', 'ENEM01_PlayerExcessLand_OpAI', {} )
	local ENEM01_PlayerExcessLand_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttackRoute_02', },}
	ENEM01_PlayerExcessLand_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', ENEM01_PlayerExcessLand_OpAI_Data )
	ENEM01_PlayerExcessLand_OpAI:				SetChildCount(2)


	-- Too many air units
	local ENEM01_PlayerExcessAir_OpAI			= ScenarioInfo.ArmyBaseMid:AddOpAI('AirResponsePatrolAir', 'ENEM01_PlayerExcessAir_OpAI', {} )
	local ENEM01_PlayerExcessAir_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttackRoute_02', },}
	ENEM01_PlayerExcessAir_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', ENEM01_PlayerExcessAir_OpAI_Data )
	ENEM01_PlayerExcessAir_OpAI:				SetDefaultVeterancy(3)
	ENEM01_PlayerExcessAir_OpAI:				SetChildCount(2)


	-- Player builds powerful individual land units
	local ENEM01_PlayerPowerfulLand_OpAI		= ScenarioInfo.ArmyBaseMid:AddOpAI('AirResponseTargetLand', 'ENEM01_PlayerPowerfulLand_OpAI', {} )
	local ENEM01_PlayerPowerfulLand_OpAI_Data	= {
    												Announce = true,
    												PatrolChain = 'P1_ENEM01_AirAttackRoute_02',
    												CenterPoint = ScenarioUtils.MarkerToPosition( 'P2_ENEM01_BaseMid_Marker' ),
    												CategoryList = {
    												    (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    												    categories.uub0105,	-- artillery
    												    categories.ucb0105,	-- artillery
    												    categories.NUKE,
    												},
    											}
	ENEM01_PlayerPowerfulLand_OpAI:				SetPlatoonThread( 'CategoryHunter', ENEM01_PlayerPowerfulLand_OpAI_Data )
	ENEM01_PlayerPowerfulLand_OpAI:				SetDefaultVeterancy(5) -- small map needs heavy, fast response to exps
	ENEM01_PlayerPowerfulLand_OpAI:				SetChildCount(3)


	-- Player builds air experimentals
	local ENEM01_PlayerPowerfulAir_OpAI			= ScenarioInfo.ArmyBaseMid:AddOpAI('AirResponseTargetAir', 'ENEM01_PlayerPowerfulAir_OpAI', {} )
	local ENEM01_PlayerPowerfulAir_OpAI_Data	= {
    												Announce = true,
    												PatrolChain = 'P1_ENEM01_AirAttackRoute_02',
    												CenterPoint = ScenarioUtils.MarkerToPosition( 'P2_ENEM01_BaseMid_Marker' ),
    												CategoryList = {
    												    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    												},
    											}
	ENEM01_PlayerPowerfulAir_OpAI:				SetPlatoonThread( 'CategoryHunter', ENEM01_PlayerPowerfulAir_OpAI_Data )
	ENEM01_PlayerPowerfulAir_OpAI:				SetDefaultVeterancy(5)
	ENEM01_PlayerPowerfulAir_OpAI:				SetChildCount(2)


	-----------------
	--- West Base
	-----------------

	local levelTable = {P2_ENEM01_Base_West = 100,}
	ScenarioInfo.ArmyBaseWest = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P2_ENEM01_Base_West',
		 'P2_ENEM01_BaseWest_Marker', 50, levelTable)
	ScenarioInfo.ArmyBaseWest:StartNonZeroBase(1)
	ScenarioInfo.ArmyBaseWest:SetBuildAllStructures(false)

	local childTemplate3 = {
		'Mixed_Land_Platoon',
		{
			{ 'uul0101', 2 }, -- tank
			{ 'uul0103', 2 }, -- assault bot
		},
	}
	local westBaseLand_OpAI 			= ScenarioInfo.ArmyBaseWest:GenerateOpAIFromPlatoonTemplate(childTemplate3, 'westBaseLand_OpAI', {} )
	local westBaseLand_OpAI_data		= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_WestBase_Land_Chain_01',},}
	westBaseLand_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', westBaseLand_OpAI_data )
	westBaseLand_OpAI:					SetChildCount(1)
	westBaseLand_OpAI:					SetMaxActivePlatoons(3)

	-- small popcorn air opai, to keep activity up.
	local childTemplate1 = {
		'Generic_Bomber_Platoon',
		{
			{ 'uua0102', 3 },
		},
	}
	local westBaseAir_OpAI				= ScenarioInfo.ArmyBaseWest:GenerateOpAIFromPlatoonTemplate(childTemplate1, 'Air_Attack_WestBase_01', {} )
	local westBaseAir_OpAI_data			= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttackRoute_01',},}
	westBaseAir_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', westBaseAir_OpAI_data )
	westBaseAir_OpAI:					SetChildCount(1)
	westBaseAir_OpAI:					SetMaxActivePlatoons(3)


	-----------------
	--- East Base
	-----------------

	local levelTable = {P2_ENEM01_Base_East = 100,}
	ScenarioInfo.ArmyBaseEast = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P2_ENEM01_Base_East',
		 'P2_ENEM01_BaseEast_Marker', 50, levelTable)
	ScenarioInfo.ArmyBaseEast:StartNonZeroBase(1)
	ScenarioInfo.ArmyBaseEast:SetBuildAllStructures(false)


	-- small sneaky popcorn op to keep activity up, and to hit the player in a new spot, at range.
	local childTemplate2 = {
		'Mobile_Missile_Platoon',
		{
			{ 'uul0104', 3 }, -- mm
			{ 'uul0201', 1 }, -- mobile shield
		},
	}
	local eastBaseLand2_OpAI 			= ScenarioInfo.ArmyBaseEast:GenerateOpAIFromPlatoonTemplate(childTemplate2, 'Land_Attack_EastBase_02', {} )
	local eastBaseLand2_OpAI_data		= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_EastBase_Land_Chain_01',},}
	eastBaseLand2_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', eastBaseLand2_OpAI_data )
	eastBaseLand2_OpAI:					SetChildCount(1)
	eastBaseLand2_OpAI:					SetMaxActivePlatoons(3)

	local eastBaseAir_OpAI 				= ScenarioInfo.ArmyBaseEast:AddOpAI('AirAttackUEF', 'Air_Attack_EastBase_01', {} )
	local eastBaseAir_OpAI_data			= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttackRoute_03',},}
	local disablesAir 					= { 'UEFFighters' }
	eastBaseAir_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', eastBaseAir_OpAI_data )
	eastBaseAir_OpAI:					DisableChildTypes( disablesAir )
	eastBaseAir_OpAI:					SetChildCount(1)
	eastBaseAir_OpAI:					SetMaxActivePlatoons(3)


	-----------------
	--- Factory Buffs, etc
	-----------------

	-- Do this after all bases are created. Increase vet level of all bases.
	local factories = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.uub0001 + categories.uub0002, false )
	for k, v in factories do
		if v and not v:IsDead() then
			v:SetVeterancy(5)
		end
	end
end

function P2_CounterAttack()
	LOG('----- P2 COUNTERATTACK: starting.')
	-- player value checks (some weighted)
	local catsLand		= (categories.LAND * categories.MOBILE) - categories.EXPERIMENTAL - categories.uul0001 - categories.uul0002
	local mobileLand 	= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(catsLand)
	local fatboy 		= P2_Counter_FatboyWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uux0101)
	local gunBomb		= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0102 + categories.uua0103)
	local fighters		= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0101)
	local kriptor		= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uux0111)
	local ac1000		= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uux0102)

	local defShield		= P2_Counter_ShieldWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0202)
	local defPDTurret	= P2_Counter_PDWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0101)
	local defAATurret	= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0102)

	-- ratings derived from the above
	local defLandRating	= defShield + defPDTurret
	local defAirRating	= defAATurret

	-- attack values
	local mainLand		= (mobileLand + fatboy) + (defLandRating * .4) -- primary land attack value relects land and a portion of defense.
	local mainGunBomb	= gunBomb + (defAirRating * 1.3) + ( fighters * .2)	-- primary air attack mainly looks at gunships/bombers, but in the context of air def.
	local mainFighter	= fighters + (defAirRating * 1.3) -- anti-fighter attack responds to fighters, but in the context of air defenses.

	-- report some logs, reporting values
	LOG('----- P2 COUNTERATTACK: mainLand value: ' .. mainLand)
	LOG('----- P2 COUNTERATTACK: mainGunBomb value: ' .. mainGunBomb)
	LOG('----- P2 COUNTERATTACK: mainFighter value: ' .. mainFighter)
	local totalUnits = 0

	-- land attack
	if (mobileLand + fatboy) > 40 then
		LOG('----- P2 COUNTERATTACK: Land Attack:  sufficient units for attack ( ' .. (mobileLand + fatboy) .. ').')
		-- number of waves to spawn: the land value, minus some 'free' units we will allow the player, devided n (units).
		-- ie, after allowing for 'free' units, for every n units the player has, we will send in one wave.
		local waves = math.floor ((mainLand-21) / 25)
		LOG('----- P2 COUNTERATTACK: Land Attack: raw waves requested is ' .. waves)

		if waves >= 1 then
			-- clamp the number of waves to a safe number
			if waves > 5 then waves = 5 end
			LOG('----- P2 COUNTERATTACK: Land Attack: adjusted waves will be ' .. waves)

			for location = 1, 3 do
				local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
				for attacks = 1, waves do
					local units = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM_COUNTER_Land0' .. location)
					for k, v in units do
						if v and not v:IsDead() then
							ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
						end
					end
				end
				ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_Counter_LandChain_0' .. location)
			end
		end
	end


	-- anti-gunship/bomber attack
	if gunBomb > 22 then
		LOG('----- P2 COUNTERATTACK: Anti Gunship/Bombers:  sufficient units for attack ( ' .. gunBomb .. ').')
		-- Number of fighters to spawn: rating minus some 'free' units we will let the player have, devided by an amount.
		-- So, we will get a fraction of the 'size' of the players air presence, not including some gimme units we wont count.
		local numResponders = math.floor ((mainGunBomb-23) / 1.6)
		if numResponders > 3 then
			LOG('----- P2 COUNTERATTACK: Anti Gunship/Bombers: requested attack size is ' .. numResponders)
			-- clamp the max count to a safe number
			if numResponders > 30 then numResponders = 30 end
			totalUnits = totalUnits + numResponders
			LOG('----- P2 COUNTERATTACK: Anti Gunship/Bombers: adjusted attack size is ' .. numResponders)

			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i = 1, numResponders do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_COUNTER_Single_Fighter')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
			end
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_AirAttackRoute_02')
		end
	end


	-- anti-fighter attack
	if fighters > 17 then
		LOG('----- P2 COUNTERATTACK: Anti Fighter:  sufficient units for attack ( ' .. fighters .. ').')
		-- number of units to send in: player general 'fighter' value (takes into acount defense), minus
		-- some free units, devided by a value.
		local numResponders = math.floor ((mainFighter-25) / 1.6)
		if numResponders > 3 then
			LOG('----- P2 COUNTERATTACK: Anti Fighter: requested attack size is ' .. numResponders)
			-- clamp the max count to a safe number
			if numResponders > 25 then numResponders = 25 end
			totalUnits = totalUnits + numResponders
			LOG('----- P2 COUNTERATTACK:Anti Fighter: adjusted attack size is ' .. numResponders)

			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i = 1, numResponders do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_COUNTER_Single_Fighter')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
			end
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_AirAttackRoute_02')
		end
	end


	-- anti-fatboy attack
	if fatboy >= 22 then -- (weighted value, not unit count)
		LOG('----- P2 COUNTERATTACK: Fatboys:  sufficient units for attack ( ' .. fatboy .. ').')
		-- get a list of guaranteed valid units, so we dont get dead/building units
		-- into our counts (which would make us overwhelm the player when they cant handle it).
		local fboys = GetValidListOfUnits(categories.uux0101)

		-- we will spawn in 5 gunships for every fatboy the player has, not including a 'free' fatboy we will ignore.
		local gshipCount = (table.getn(fboys) - 1) * 5
		if gshipCount > 20 then gshipCount = 20 end
		if gshipCount > 0 then -- tinfoil hat
			LOG('----- P2 COUNTERATTACK: Fatboys:  attack size will be ' .. gshipCount)
			totalUnits = totalUnits + gshipCount
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i = 1, gshipCount do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_COUNTER_Single_Gunship')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
			end
			P2_CounterAttack_TargetUnits(platoon, fboys, 'P2_ENEM01_MidAir_Patrol_01' )
		end
	end


	-- anti AC1000 attack
	if ac1000 >= 1 then
		LOG('----- P2 COUNTERATTACK: AC1000:  sufficient units for attack ( ' .. ac1000 .. ').')
		local acs = GetValidListOfUnits(categories.uux0102)

		-- we will spawn in 6 fighters for every ac1000 the player has
		local fighterCount = table.getn(acs) * 6
		if fighterCount > 20 then fighterCount = 20 end
		if fighterCount > 0 then -- tinfoil hat
			LOG('----- P2 COUNTERATTACK: AC1000:  attack size will be ' .. fighterCount)
			totalUnits = totalUnits + fighterCount
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i = 1, fighterCount do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_COUNTER_Single_Fighter')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
			end
			P2_CounterAttack_TargetUnits(platoon, acs, 'P2_ENEM01_MidAir_Patrol_01' )
		end
	end


	-- anti Kriptor attack
	if kriptor >= 1 then
		LOG('----- P2 COUNTERATTACK: Kriptor:  sufficient units for attack ( ' .. kriptor .. ').')
		local krips = GetValidListOfUnits(categories.uux0111)

		-- we will spawn in 8 gunships for every kriptor the player has
		local gshipCount = table.getn(krips) * 8
		if gshipCount > 16 then gshipCount = 16 end
		if gshipCount > 0 then -- tinfoil hat
			LOG('----- P2 COUNTERATTACK: Kriptor:  attack size will be ' .. gshipCount)
			totalUnits = totalUnits + gshipCount
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i = 1, gshipCount do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_COUNTER_Single_Gunship')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
			end
			P2_CounterAttack_TargetUnits(platoon, krips, 'P2_ENEM01_MidAir_Patrol_01' )
		end
	end

	LOG('----- P2 COUNTERATTACK: TOTALS:  number of non-land units spawned: ' .. totalUnits)
end

function GetValidListOfUnits(cats)
	-- given a set of categories, return a list of valid, alive, already-built units.
	local units = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(cats, false)
	local newList = {}
	for k, v in units do
		if v and not v:IsDead() and not v:IsBeingBuilt() then
			table.insert(newList, v)
		end
	end
	return newList
end

function P2_CounterAttack_TargetUnits(platoon, targets, patrol)
	-- send a platoon to attack a sorted-by-distance list of targets. Give them a patrol
	-- to go on if they live through the experience.
	local expList = SortEntitiesByDistanceXZ( ScenarioUtils.MarkerToPosition('P2_CounterAttack_DistanceSort_Location'), targets )

	IssueClearCommands(platoon:GetPlatoonUnits())
	for k, v in expList do
		if v and not v:IsDead() then
			platoon:AttackTarget(v)
		end
	end

	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		-- Final patrol to send units on, when they have completed their queued list of targets.
		ScenarioFramework.PlatoonPatrolChain(platoon, patrol)
	end
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

---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------
function EnemyCommander_DeathDamage(CDRUnit)
	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_CIVL01],
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
function HandlePossibleVictory(unit)
	if not ScenarioInfo.VictoryTracker then
		-- first time, we just set the value
		ScenarioInfo.VictoryTracker = 1
	else
		-- every other time we up the value
		ScenarioInfo.VictoryTracker = ScenarioInfo.VictoryTracker + 1
	end

	if ScenarioInfo.VictoryTracker == 3 then

		ScenarioInfo.ArmyBaseMid:BaseActive(false)
		ScenarioInfo.ArmyBaseWest:BaseActive(false)
		ScenarioInfo.ArmyBaseEast:BaseActive(false)

		ForkThread(OpNIS.NIS_VICTORY, unit)
	else
		---NOTE: before, we were just unflagging the unit as killable - that is broken because there is no certainty that the
		---		 player will continue to kill this unit - so we have to force kill it. Down the road - when we have a better health ratio system
		---		 this should be considerably more readible - bfricks 11/8/09
		-- 		 otherwise we force kill the unit
		ForceUnitDeath(unit)
	end
end

function LaunchVictoryNIS(unit)
	ForkThread(OpNIS.NIS_VICTORY, unit)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	P2_Setup()
end

function OnShiftF4()
	ForkThread(OpNIS.NIS_VICTORY, ScenarioInfo.EnemyCommander)
end

