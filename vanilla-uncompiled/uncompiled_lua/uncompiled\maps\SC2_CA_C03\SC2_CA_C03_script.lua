---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_C03/SC2_CA_C03_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_C03/SC2_CA_C03_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_C03/SC2_CA_C03_OpNIS.lua')
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
ScenarioInfo.ARMY_ALLY01 = 2
ScenarioInfo.ARMY_ENEM01 = 3
ScenarioInfo.ARMY_ALIEN01 = 4
ScenarioInfo.ARMY_STRUCTURES = 5
ScenarioInfo.ARMY_GANTRY = 6

ScenarioInfo.AssignedObjectives = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALIEN01 = ScenarioInfo.ARMY_ALIEN01
local ARMY_STRUCTURES = ScenarioInfo.ARMY_STRUCTURES
local ARMY_GANTRY = ScenarioInfo.ARMY_GANTRY

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
ScenarioInfo.P1_StreamUnitCap			= 37

local P2_DelayBetweenResidualAttacks 	= 35
local P2_ResidualAttackMaxSize 			= 3

local TechCaptureCount = 0

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

	LOG('CAMPAIGN OPERATION FLOW:::: OnPopulate: Create Weather')
	local WeatherDefinition = {
		MapStyle = "Tundra",
		WeatherTypes = {
			{
				Type = "WhitePatchyClouds03",
				Chance = 1.0,
			},
		},
		Direction = {0,0,0},
	}
	Weather.CreateWeather(WeatherDefinition)

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy	(ARMY_PLAYER,		ScenarioGameTuning.C03_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(ARMY_ENEM01,		ScenarioGameTuning.C03_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy	(ARMY_ALLY01,		ScenarioGameTuning.color_ZOE)
	ScenarioGameSetup.SetupGenericArmy	(ARMY_ALIEN01,		ScenarioGameTuning.color_DINO_C03)
	ScenarioGameSetup.SetupGenericArmy	(ARMY_STRUCTURES,	ScenarioGameTuning.color_CIV_C03)
	ScenarioGameSetup.SetupGenericArmy	(ARMY_GANTRY,		ScenarioGameTuning.color_CIV_C03)
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

	CreateObjectiveTarget()

	-- This group of enemies is near the target, so can be told to directly attack it (during the NIS)
	ScenarioInfo.NIS_ATTACKERS = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Init_Attack_Land_01')

	--# Set up sundry neutral structures and units in the map
	ScenarioUtils.CreateArmyGroup('ARMY_STRUCTURES', 'P1_STRUCTURES_AirCamp_01')
	ScenarioUtils.CreateArmyGroup('ARMY_STRUCTURES', 'P1_STRUCTURES_AirCamp_02')
	ScenarioUtils.CreateArmyGroup('ARMY_STRUCTURES', 'P1_STRUCTURES_LandCamp_01')
	local eng = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'P1_STRUCTURES_AirCamp01_Engineer')
	ScenarioFramework.GroupPatrolChain( {eng}, 'P1_STRUCTURES_AirCamp01_Chain' )
	eng = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'P1_STRUCTURES_AirCamp02_Engineer')
	ScenarioFramework.GroupPatrolChain( {eng}, 'P1_STRUCTURES_AirCamp02_Chain' )

	-- Set up tech caches, with death triggers. Along with a set that will be created at start of part2,
	-- killing all of them results in hidden objective completing.
	local tech = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')
	for k, v in tech do
		ScenarioFramework.CreateUnitDeathTrigger(TechKilledCallback, v)
	end

	--# Create player starting units, and hide them for the NIS. Set up a table to track any units
	-- whose shields we disable for the NIS (e dont see shields with no units showing), so we can
	-- turn these shields back on later.
	ScenarioInfo.PLAYER_CDR = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_CDR')
	ScenarioInfo.PLAYER_ENGINEERS = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_ENGINEERS')

	ScenarioInfo.PLAYER_StartingLand = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Init_Land')
	ScenarioInfo.PLAYER_StartingBomber = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitAir_Bombers_01')
	ScenarioInfo.PLAYER_StartingGunship = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitAir_Gunships_01')
	ScenarioInfo.PLAYER_StartingTransport = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitAir_Transports')

	ScenarioInfo.EnterTeleporter = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'EnterTeleporter')

	---TODO: the CDR handling for this operation needs to be revised so it can cleanly work without reliance on the transports and NIS timing - bfricks 6/7/09
	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Ivan)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )
end

function P1_Main()
	-- Send the main chunk of enemies individually along a patrol to the Research Station
	local units = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Init_Attack_Land_02')
	for k, v in units do
		for i = 1, 3 do
			IssuePatrol( {v}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_InitAttack_marker_0' .. i ))
		end
	end

	----------------------------------------------
	-- Primary Objective M1_obj10 - Defend Lab
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Defend Lab.')
	local descText = OpStrings.C03_M1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C03_M1_obj10_SURV_PART1)
	ScenarioInfo.M1_obj10 = SimObjectives.Protect(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.C03_M1_obj10_NAME,		-- title
		descText,							-- description

		{
			MarkUnits = true,
			Units = {ScenarioInfo.ALLY01_Station},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	local curPos = ScenarioInfo.ALLY01_Station:GetPosition()
	ScenarioInfo.FAIL_Position = {curPos[1], curPos[2], curPos[3]}

	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if not result then
				-- pass in the data required to use the center pos for our fail NIS
				Defeat(true, ScenarioInfo.FAIL_Position, OpDialog.C03_STATION_DESTROY)
			end
		end
	)

	-- vo when player researches jumpjets
	ScenarioFramework.CreateOnResearchTrigger( JumpjetResearchVO, ArmyBrains[ARMY_PLAYER], 'CLA_JUMPJETS', 'complete' )

	---------------
	-- Attack Stream
	---------------

	-- Start the stream after a delay. For a brief period after the stream starts, we will use a clamped stream
	-- unit cap, before increasing the cap to the normal level for the stream.
	ScenarioInfo.P1_StreamAllowed = true
	ScenarioFramework.CreateTimerTrigger (function() ForkThread(P1_EnemyStream) end, 37)
	ScenarioFramework.CreateTimerTrigger (function() ScenarioInfo.P1_StreamUnitCap = 58 end, 97)

	-- Set stage based on time. At 2 points, increment a value that the stream uses as a
	-- basis for growing stream difficulty. Also, we spawn in an attack each time we increment.
	ScenarioInfo.P1_StreamStage = 1
	ScenarioFramework.CreateTimerTrigger(P1_IncrementStreamStageTo2, 215)
	ScenarioFramework.CreateTimerTrigger(P1_IncrementStreamStageTo3, 330)

	-- Timer that will send in an Experimental, whose death marks the end of the Part.
	ScenarioFramework.CreateTimerTrigger(P1_SpawnExperimentalAttack, 480)

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 25)
end

function P1_IncrementStreamStageTo2()
	LOG('----- P1: Increasing stage from 1 to 2, and launching attack.')

	-- Increase the stage count to 2, for the stream thread to check and base its difficulty on.
	ScenarioInfo.P1_StreamStage = 2

	-- Send in an attack
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PeriodicAttack_Group_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Stream_Route_02')
end

function P1_IncrementStreamStageTo3()
	LOG('----- P1: Increasing stage from 2 to 3, and launching attack.')

	-- Increase the stage count to 3, for the stream thread to check and base its difficulty on.
	ScenarioInfo.P1_StreamStage = 3

	-- Send in an attack consisting of the stage 2 attack, and an additional group.
	local platoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PeriodicAttack_Group_01', 'AttackFormation')
	local platoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PeriodicAttack_Group_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon1, 'P1_ENEM01_Stream_Route_02')
	ScenarioFramework.PlatoonPatrolChain(platoon2, 'P1_ENEM01_Stream_Route_02')
end

function P1_EnemyStream()
	local baseDelay = 17
	local aaChance = .30
	local pdWeight = 3		-- wieght of player point defense towers.
	local landLevel = 2

	while ScenarioInfo.P1_StreamAllowed do

		-- Get info on player and Enemy unit counts
		local playerBasic = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits((categories.MOBILE * categories.LAND) + categories.AIR - categories.uca0901)
		local playerPDRaw = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0101)
		local playerAirCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.AIR)
		local enemyCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		local playerPDWeighted =  playerPDRaw * pdWeight
		local playerCount = playerBasic + playerPDWeighted

		LOG('----- P1: stream: player count = ', repr(playerCount))
		LOG('----- P1: stream: enemy count = ', repr(enemyCount))

		local delay = baseDelay

		-- The more units player has, the shorter the delay between waves will be.
		if playerCount < 21 then
			delay = delay + 4
		elseif playerCount >= 21 and playerCount <= 31 then
			delay = delay + 1
		elseif playerCount > 31 and playerCount <= 38 then
			delay = delay - 2
		elseif playerCount > 38 and playerCount <= 50 then
			delay = delay - 4
		elseif playerCount > 50 then
			delay = delay - 9
		end

		-- Check what stage of the stream we are in, and set values based on that.
		-- Stage 1: mobile AA is rare, and we are using the normal land unit mix.
		-- Spawn loop delay is normal.
		if ScenarioInfo.P1_StreamStage == 1 then
			aaChance = 0.28 -- out of 1
			landLevel = 2

		-- Stage 2: mobile AA is still rare, but land unit mix now includes a more difficult unit.
		-- Spawn loop delay is a bit faster now.
		elseif ScenarioInfo.P1_StreamStage == 2 then
			aaChance = .34
			landLevel = 3
			delay = delay - 3
		-- Stage 3: mobile AA is now much more common, to encourage the player to go land. Land
		-- unit mix is now back to normal. Spawn loop delay is much faster.
		elseif ScenarioInfo.P1_StreamStage == 3 then
			aaChance = .39
			landLevel = 2
			delay = delay - 6
		end

		LOG('----- P1: stream: raw delay = ', repr(delay))
		-- force a minimum safe delay, in case we get too low a value
		if delay < 4 then delay = 4 end
		LOG('----- P1: stream: adjusted delay = ', repr(delay))

		-- Check enemy unit count. This serves two purposes: to not overwhelm the player, but also to introduce natural
		-- pauses when we get a lot of units onmap. When we are riding this limit (such as after a major attack is spawned), we
		-- get good pauses/breaks in the attack stream. Tune this as needed.
		if enemyCount < 58 then
			local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Stream_Unit_0' .. Random(1 , landLevel), 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Stream_Route_0'.. Random(1 , 3))

			-- Spawn in a bit of AA as well. If we are in stage 3 of the attack, we want more
			-- mobile AA, varying the makeup of the stream: player will now need to consider switching
			-- to land units. Avoid this, however, if the player doesn't have much Air to speak of.
			local rnd = Random()
			LOG('----- P1: stream: AA chance is ' .. aaChance .. ' and rnd is ' .. rnd)
			if rnd < aaChance and playerAirCount >= 6 then
				LOG('----- P1: stream: spawning anti-air this round.')
				local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Stream_Unit_AA', 'AttackFormation')
				ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Stream_Route_0'.. Random(1 , 3))

			-- If the player doesn't have much Air, then in these cases, occasionally send in some extra tanks,
			-- as c.p., this situation means the player has shifted to land one way or another.
			elseif rnd < aaChance and playerAirCount < 3 then
				LOG('----- P1: stream: failed to spawn mobileAA - player has too little air. ')
				if (Random(1,3)) == 1 then
					LOG('----- P1: stream: Successful 1 in 3 chance to spawn ground instead. ')
					local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Stream_Unit_01', 'AttackFormation')
					ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Stream_Route_0'.. Random(1 , 3))
				end
			end
		end

		-- If the enemy unit count is high, then do a long pause. This both lets unit count soften (in case the player is
		-- getting overwhelmed) but also, as we tend to ride this cap, helps us introduce natural breaks and pauses in the flow.
		if enemyCount >= 58 then
			LOG('----- P1: stream: Enemy is getting too many units in the field. Using a long wait. ')
			WaitSeconds(37)

		-- Otherwise, wait for the amount we have come up with based on stage and player unit count.
		else
			WaitSeconds(delay)
		end
		LOG('------------------')
	end
end

function P1_SpawnExperimentalAttack()
	LOG('----- P1: Spawn final experimental attack')

	-- Create an experimental platoon as a final bang. Its death will mark the end of the Part, resulting in the retreat.
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PeriodicAttack_Experimental_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Stream_Route_01')
	ScenarioFramework.CreatePlatoonDeathTrigger (P1_EnemyRetreat, platoon)
end

function P1_EnemyRetreat()
	LOG('----- P1: Enemy retreats')
	-- Here, we will send the enemy units on a retreat patrol, and trigger delay
	-- some VO pointing this out (to give time for the change of direction to take place)

	-- flag to disable the stream
	ScenarioInfo.P1_StreamAllowed = false

	-- Grab all the units in the play area, and send them on a retreat patrol. However,
	-- those that are a bit west might get caught up on terrain when they move to this patrol. So,
	-- in their case, first move them to a central point, *then* send them to the patrol.
	ScenarioInfo.P1_ResidualEnemyUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'AREA_1', ArmyBrains[ARMY_ENEM01])
	for k, unit in ScenarioInfo.P1_ResidualEnemyUnits do
		if (unit and not unit:IsDead()) then
			local location = unit:GetPosition()
			local locX = location[1]

			IssueClearCommands({unit})

			if locX < 437 then
				IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_West_Retreat_Point' ))
				ScenarioFramework.GroupPatrolChain( {unit}, 'P1_ENEM01_Retreat_Patrol' )
			else
				ScenarioFramework.GroupPatrolChain( {unit}, 'P1_ENEM01_Retreat_Patrol' )
			end
		end
	end

	ScenarioFramework.CreateTimerTrigger(P1_RetreatVO, 5)
end

function P1_RetreatVO()
	-- Play the retreat confirmation VO, and then complete the Part.
	-- For clarity and flow, we want to do one then the other, instead of jumbled together.
	ScenarioFramework.Dialogue(OpDialog.C03_M1_obj10_COMPLETE, P2_Setup)

	-- complete the Part 1 objective
	ScenarioInfo.M1_obj10:ManualResult(true)

	-- Reward for finishing part1.
	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C03_M1_obj10_SURV_PART1, ARMY_PLAYER, 3.0)
end

function P1_ResearchSecondary_VO()
	LOG('----- P1: Research secondary VO, assignment')
	ScenarioFramework.Dialogue(OpDialog.C03_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.C03_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.C03_S1_obj10_NAME,	-- title
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
				ScenarioFramework.Dialogue(OpDialog.C03_RESEARCH_FOLLOWUP_GIANTTRANSPORT_010)
			end
		end
	)
end

function JumpjetResearchVO()
	-- up until the dino is spawned, play some VO when player researched jumpjets.
	if not ScenarioInfo.P2_DinoSpawned then
		ScenarioFramework.Dialogue(OpDialog.C03_RESEARCH_FOLLOWUP_JUMPJET_010)
	end
end

---------------------------------------------------------------------
-- PART 2:
---------------------------------------------------------------------
function P2_Setup()
	LOG('----- P2_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 2

	-- Setting this to false again here, to help ease of testing.
	ScenarioInfo.P1_StreamAllowed = false

	-- Neutral capturable gantry base
	ScenarioUtils.CreateArmyGroup('ARMY_STRUCTURES', 'P2_STRUCTURES_ExpCamp01')

	-- Enemy base defense
	for i = 1, 3 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_InitDef_Land_0' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_LandDef_Patrol_0' .. i)
	end

	-- Create the special gantry that the dino will reveal out of.
	ScenarioInfo.P2_GANTRY_DinoFactory = ScenarioUtils.CreateArmyUnit('ARMY_GANTRY', 'P2_GANTRY_DinoFactory')
	ProtectUnit(ScenarioInfo.P2_GANTRY_DinoFactory)


	-- Enemy Commander, the objective unit
	ScenarioInfo.ENEM01_CDR	= ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_CDR')
	ScenarioInfo.ENEM01_CDR:SetCustomName(ScenarioGameNames.CDR_Knox)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_CDR, 3)
	ScenarioFramework.GroupPatrolChain( {ScenarioInfo.ENEM01_CDR}, 'P2_ENEM01_MainBase_CDR_Patrol' )

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.ENEM01_CDR:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.DINO_BLOWS_UP_01	= ScenarioUtils.CreateArmyUnit('ARMY_GANTRY', 'DINO_BLOWS_UP_01')
	ScenarioInfo.DINO_BLOWS_UP_02	= ScenarioUtils.CreateArmyUnit('ARMY_GANTRY', 'DINO_BLOWS_UP_02')
	ScenarioInfo.DINO_BLOWS_UP_03	= ScenarioUtils.CreateArmyUnit('ARMY_GANTRY', 'DINO_BLOWS_UP_03')

	ProtectUnit(ScenarioInfo.DINO_BLOWS_UP_01)
	ProtectUnit(ScenarioInfo.DINO_BLOWS_UP_02)
	ProtectUnit(ScenarioInfo.DINO_BLOWS_UP_03)

	-- Create CDR death trigger for damage management
	ScenarioFramework.CreateUnitDeathTrigger(ENEM01_CDR_DeathDamage, ScenarioInfo.ENEM01_CDR)

	-- Create an Economy Area. Put a pre-named selection of these into a group that the player
	-- can destroy. When they do, we will fork a thread to keep the enemy economy bottomed out.
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_Econ_Area')
	ScenarioInfo.P2_ENE01_BaseEconUnits = {}
	for i = 1, 5 do
		local unit = ScenarioInfo.UnitNames[ARMY_ENEM01]['P2_ENEM01_EconUnit0' .. i]
		table.insert(ScenarioInfo.P2_ENE01_BaseEconUnits, unit)
	end

	ScenarioFramework.CreateGroupDeathTrigger(
		function()
			local curStoredMass = ArmyBrains[ARMY_ENEM01]:GetEconomyStored('Mass')
			local curStoredEnergy = ArmyBrains[ARMY_ENEM01]:GetEconomyStored('Energy')

			ArmyBrains[ARMY_ENEM01]:TakeResource('MASS', curStoredMass)
			ArmyBrains[ARMY_ENEM01]:TakeResource('ENERGY', curStoredEnergy)
			if ScenarioInfo.M2_obj10.Active then -- play VO pointing out the econ change, if the enemy CDR is still around.
				ScenarioFramework.Dialogue(OpDialog.C03_ENEM_ECON_020)
			end
		end,
		ScenarioInfo.P2_ENE01_BaseEconUnits
	)


	-- Set up tech caches, with death triggers. Along with a set that was created at start of part1,
	-- killing all of them results in hidden objective completing.
	local tech = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_TechCache')
	for k, v in tech do
		ScenarioFramework.CreateUnitDeathTrigger(TechKilledCallback, v)
	end

	-- Set up enemy AI. This must be called at the end of this function.
	P2_AISetup_ENEM01()

	-- transition to the NIS and onto P2_Main()
	ForkThread(P2_Transition)
end

function P2_Transition()
	OpNIS.NIS_REVEAL_ENEMY()
	P2_Main()
end

function P2_Main()
	----------------------------------------------
	-- Primary Objective M2_obj10 - Destroy Enemy
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M2_obj10 - Recover DNA, Destroy Enemy.')
	ScenarioInfo.M2_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.C03_M2_obj10_NAME,		-- title
		OpStrings.C03_M2_obj10_DESC,		-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.ENEM01_CDR},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)


	----------------------------------------------
	-- Primary Objective M2_obj20 - Defend Lab (part2)
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M2_obj20 - Defend Lab. (part2)')
	ScenarioInfo.M2_obj20 = SimObjectives.Protect(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.C03_M2_obj20_NAME,		-- title
		OpStrings.C03_M2_obj20_DESC,		-- description

		{
			MarkUnits = true,
			Units = {ScenarioInfo.ALLY01_Station},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj20)

	ScenarioInfo.M2_obj20:AddResultCallback(
		function(result)
			if not result then
				-- pass in the data required to use the center pos for our fail NIS
				Defeat(true, ScenarioInfo.FAIL_Position)
			end
		end
	)

	-- After a brief pause, point out that the enemy front line is well defended, but that
	-- jump-jet units could instead sneak around the side to tool the enemy econ.
	ScenarioFramework.CreateTimerTrigger(P2_EnemyEconPrompt, 35)

	-- setup the CDR for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEM01_CDR, P2_RevealDino)

	-- Begin a thread that will periodically send a few of the P1 residual units in for an attack.
	ForkThread(P2_ResidualUnitDrain_Thread)
end

function P2_ResidualUnitDrain_Thread()
	-- Periodically peel off a few of the left-over units from P1, and send them in on an attack.
	-- Size of the attack is P2_ResidualAttackMaxSize, and delay between attacks is P2_DelayBetweenResidualAttacks

	while not ScenarioInfo.OpEnded and table.getn(ScenarioInfo.P1_ResidualEnemyUnits) > 0 do

		-- Wait first instead of after, so the first attack we get is not instantaneous (ie, a few units will
		-- begin their retreat but immediately turn around to attack again, which would look poor).
		WaitSeconds(P2_DelayBetweenResidualAttacks)

		LOG('----- P2: Sending Residual attack')
		for k, unit in ScenarioInfo.P1_ResidualEnemyUnits do
			if k <= P2_ResidualAttackMaxSize then
				if unit and not unit:IsDead() then
					IssueClearCommands({unit})
					ScenarioFramework.GroupPatrolChain( {unit}, 'P2_ENEM01_ResidualUnit_Attack_Chain' )
				end
			end
		end
	end
end

function P2_EnemyEconPrompt()
	ScenarioFramework.Dialogue( OpDialog.C03_ENEM_ECON_010 )
end

function P2_AISetup_ENEM01()
	LOG('----- P2: Setting up enemy Base and OpAIs')
	----------------------
	-- Base Manager Setup
	----------------------

	-- Set up Enemy base
	local levelTable_ENEM01 = { P2_ENEM01_Main_Base_100 = 100,
								P2_ENEM01_Main_Base_90 = 90,}
	ScenarioInfo.ArmyBase_P2_ENEM01 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P2_ENEM01_Main_Base', 'P2_ENEM01_Main_Base_Marker', 50, levelTable_ENEM01)
	ScenarioInfo.ArmyBase_P2_ENEM01:StartNonZeroBase(2)


	----------------------
	-- OpAI Setup
	----------------------

	-- Basic air defense OpAI
	ScenarioInfo.P2_ENEM_AirDefense_01_OpAI				= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('AirFightersIlluminate', 'P2_ENEM_AirDefense_01_OpAI', {} )
	local P2_ENEM_AirDefense_01_OpAI_Data				= { PatrolChain = 'P2_ENEM01_AirDef_Patrol_01',}
	ScenarioInfo.P2_ENEM_AirDefense_01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', P2_ENEM_AirDefense_01_OpAI_Data )
	ScenarioInfo.P2_ENEM_AirDefense_01_OpAI:			SetChildCount(2)
	ScenarioInfo.P2_ENEM_AirDefense_01_OpAI:			SetMaxActivePlatoons(1)


	-- basic air attack against player
	ScenarioInfo.P1_ENEM01_AirAttackPlayer_01_OpAI		= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('AirAttackIlluminate', 'P1_ENEM01_AirAttackPlayer_01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_AirAttackPlayer_01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_AirAttackPlayer_Chain_01',},}
	ScenarioInfo.P1_ENEM01_AirAttackPlayer_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM01_AirAttackPlayer_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_AirAttackPlayer_01_OpAI:		EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.P1_ENEM01_AirAttackPlayer_01_OpAI:		SetMaxActivePlatoons(1)


	-- Basic land attack OpAI, heavy
	ScenarioInfo.P2_ENEM_LandAttack_01_OpAI 			= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('LandAttackIlluminate', 'P2_ENEM_LandAttack_01_OpAI', {} )
	local P2_ENEM_LandAttack_01_OpAI_data				= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_LandAttack_Route_01', 'P2_ENEM01_LandAttack_Route_02', 'P2_ENEM01_LandAttack_Route_03',},}
	ScenarioInfo.P2_ENEM_LandAttack_01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P2_ENEM_LandAttack_01_OpAI_data )
	ScenarioInfo.P2_ENEM_LandAttack_01_OpAI:			SetMaxActivePlatoons(3)


	-- Assault Block OpAI
	ScenarioInfo.P2_ENEM_AssaultBlock_OpAI				= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('SingleUrchinowAttack', 'P2_ENEM_AssaultBlock_OpAI', {} )
	ScenarioInfo.P2_ENEM_AssaultBlock_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_LandAttack_Route_01', 'P2_ENEM01_LandAttack_Route_02', 'P2_ENEM01_LandAttack_Route_03',},}
	ScenarioInfo.P2_ENEM_AssaultBlock_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P2_ENEM_AssaultBlock_OpAI_Data )
	ScenarioInfo.P2_ENEM_AssaultBlock_OpAI:				SetAttackDelay(57)
	ScenarioInfo.P2_ENEM_AssaultBlock_OpAI:				SetMaxActivePlatoons(2)


	---## Surgical Response OpAI's if the player builds over-powerful units, or builds too many of certain units.
	-- Too many land units of some types
	ScenarioInfo.P2_ENEM_PlayerExcessLand_OpAI			= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('AirResponsePatrolLand', 'P2_ENEM_PlayerExcessLand_OpAI', {} )
	local P2_ENEM_PlayerExcessLand_OpAI_Data			= { AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_AirResponse_Chain_01', },}
	ScenarioInfo.P2_ENEM_PlayerExcessLand_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P2_ENEM_PlayerExcessLand_OpAI_Data )
	ScenarioInfo.P2_ENEM_PlayerExcessLand_OpAI:			SetChildCount(3)

	-- Too many air units
	ScenarioInfo.P2_ENEM_PlayerExcessAir_OpAI			= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('AirResponsePatrolAir', 'P2_ENEM_PlayerExcessAir_OpAI', {} )
	local P2_ENEM_PlayerExcessAir_OpAI_Data				= { AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_AirResponse_Chain_01', },}
	ScenarioInfo.P2_ENEM_PlayerExcessAir_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P2_ENEM_PlayerExcessAir_OpAI_Data )
	ScenarioInfo.P2_ENEM_PlayerExcessAir_OpAI:			SetChildCount(3)


	-- Player builds powerful individual land units
	ScenarioInfo.P2_ENEM_PlayerPowerfulLand_OpAI	= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('AirResponseTargetLand', 'P2_ENEM_PlayerPowerfulLand_OpAI', {} )
	local P2_ENEM_PlayerPowerfulLand_OpAI_Data	= 	{
    												    PatrolChain = 'P2_ENEM01_PlayerBaseArea_Chain',
    												    CenterPoint = ScenarioUtils.MarkerToPosition( 'P2_ENEM01_Main_Base_Marker' ),
    												    CategoryList = {
    												        (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    												        categories.uub0105,	-- artillery
    												        categories.ucb0105,	-- artillery
    												        categories.NUKE,
    												    },
    												}
	ScenarioInfo.P2_ENEM_PlayerPowerfulLand_OpAI:	SetPlatoonThread( 'CategoryHunter', P2_ENEM_PlayerPowerfulLand_OpAI_Data )
	ScenarioInfo.P2_ENEM_PlayerPowerfulLand_OpAI:	SetChildCount(3)


	-- Player builds air experimentals
	ScenarioInfo.P2_ENEM_PlayerPowerfulAir_OpAI		= ScenarioInfo.ArmyBase_P2_ENEM01:AddOpAI('AirResponseTargetAir', 'P2_ENEM_PlayerPowerfulAir_OpAI', {} )
	local P2_ENEM_PlayerPowerfulAir_OpAI_Data		= {
    													PatrolChain = 'P2_ENEM01_PlayerBaseArea_Chain',
    													CenterPoint = ScenarioUtils.MarkerToPosition( 'P2_ENEM01_Main_Base_Marker' ),
    													CategoryList = {
    													    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    													},
    												}
	ScenarioInfo.P2_ENEM_PlayerPowerfulAir_OpAI:	SetPlatoonThread( 'CategoryHunter', P2_ENEM_PlayerPowerfulAir_OpAI_Data )
	ScenarioInfo.P2_ENEM_PlayerPowerfulAir_OpAI:	SetChildCount(3)


	----------------------
	-- Units to OpAI, etc
	----------------------

	-- Initial Air Defense platoon to hand to the airdef opai
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_InitDef_Air_01', 'AttackFormation')
	ScenarioInfo.P2_ENEM_AirDefense_01_OpAI:		AddActivePlatoon(platoon, true)

end

function P2_RevealDino(deathUnit)
	ForkThread(
		function()
			LOG('----- P2 Reveal Dino')
			-- Create the cybranosaur, send it to the player's base area, and set a trigger to detect it (which will
			-- shut it down).

			-- create and protect the unit
			ScenarioInfo.PlatoonDino = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALIEN01', 'P2_ENEM01_DinosaurGroup', 'AttackFormation')
			ScenarioInfo.P2_ALIEN01_Dinosaur = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_ALIEN01]['P2_ENEM01_Dinosaur']
			ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.P2_ALIEN01_Dinosaur, 5)

			-- Disable the enemy base, now that play focus has shifted to the dino.
			if ScenarioInfo.ArmyBase_P2_ENEM01 then
				ScenarioInfo.ArmyBase_P2_ENEM01:BaseActive(false)
			end

			ScenarioInfo.P2_DinoSpawned = true

			-- Calculate what its health will be, based on how well the player is doing:
			-- Data about player
			local playerLand = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits((categories.MOBILE * categories.LAND) + categories.AIR - categories.uca0901)
			local playerAir = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits( categories.AIR - categories.uca0901 )
			local playerPDRaw = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0101)
			local playerExpRaw = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL * categories.MOBILE * categories.ANTISURFACE)

			-- Weight it up and create values we'll check
			local playerExp = playerExpRaw * 20
			local playerPDWeighted =  playerPDRaw * 2
			local playerAirWeighted = playerAir * 2
			local playerCountRaw = playerLand + playerAirWeighted + playerPDWeighted + playerExp

			local healthMult = 1.0

			if playerCountRaw > 400 then
				healthMult = 10
			elseif playerCountRaw > 300 then
				healthMult = 6
			elseif playerCountRaw > 200 then
				healthMult = 4
			elseif playerCountRaw > 150 then
				healthMult = 3
			elseif playerCountRaw > 100 then
				healthMult = 2.0
			elseif playerCountRaw > 80 then
				healthMult = 1.5
			end

			LOG('----- P2 Reveal Dino: playerCountRaw:[', playerCountRaw, '] healthMult:[', healthMult, ']')

			local dinoHealth = ScenarioInfo.P2_ALIEN01_Dinosaur:GetHealth()
			local newHealth = dinoHealth * healthMult
			ScenarioInfo.P2_ALIEN01_Dinosaur:SetMaxHealth(newHealth)
			ScenarioInfo.P2_ALIEN01_Dinosaur:AdjustHealth(ScenarioInfo.P2_ALIEN01_Dinosaur, newHealth)

			-- setup the dino for a controlled death sequence
			ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P2_ALIEN01_Dinosaur, LaunchVictoryNIS)

			-- launch the NIS such that when it is finished we will proceed with this forked thread
			OpNIS.NIS_DINO(deathUnit)
			if ScenarioInfo.PlatoonDino and ArmyBrains[ARMY_ALIEN01]:PlatoonExists(ScenarioInfo.PlatoonDino) then
				ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.PlatoonDino, 'P2_ENEM01_LandAttack_Route_02')
			end

			P2_AssignDinoObjective()
		end
	)
end


function P2_AssignDinoObjective()
	----------------------------------------------
	-- Secondary Objective S1_obj10 - Recover DNA, Destroy Enemy
	----------------------------------------------
	LOG('----- P2: Assign Primary Objective- Recover DNA, Destroy Enemy.')
	ScenarioInfo.M3_obj10 = SimObjectives.KillOrCapture(
		'primary',						-- type
		'incomplete',						-- status
		OpStrings.C03_M3_obj10_NAME,		-- title
		OpStrings.C03_M3_obj10_DESC,		-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			AlwaysInRadar = true,
			Units = {ScenarioInfo.P2_ALIEN01_Dinosaur},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M3_obj10)
end

function TechKilledCallback()
	LOG('----- Tech captured')
	TechCaptureCount = TechCaptureCount + 1
	if TechCaptureCount == 5 then
		----------------------------------------------
		-- Hidden Objective H1_obj10 - Cache and Carry
		----------------------------------------------
		LOG('----- P1: Complete Hidden Objective H1_obj10 - Cache and Carry')
		local descText = OpStrings.C03_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C03_H1_obj10_TAKE_ALLTECH)
		ScenarioInfo.H1_obj10 = SimObjectives.Basic(
			'secondary',							-- type
			'complete',								-- status
			OpStrings.C03_H1_obj10_NAME,			-- title
			descText,								-- description
			SimObjectives.GetActionIcon('kill'),	-- Action
			{
			}
		)
		table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

		ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C03_H1_obj10_TAKE_ALLTECH, ARMY_PLAYER, 3.0)
	end
end

function CreateObjectiveTarget()
	-- Set up Ally units. Objective structure, and a radar for player convenience,
	-- which the enemy will avoid.
	ScenarioInfo.ALLY01_Station	= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_Station')
	ScenarioInfo.ALLY01_Station:SetCustomName(ScenarioGameNames.UNIT_SCB3301)

	-- give some intel around this unit
	---NOTE: decided to make sure we have a wide intel radius for the whole operation - if this winds up being problematic, let me know - bfricks 11/21/09
	---			updated with the big radius used for Radar and the smaller radius used for Vision - bfricks 11/29/09
	local unitPos = ScenarioInfo.ALLY01_Station:GetPosition()
	local intelPos = {unitPos[1],unitPos[2],unitPos[3]}
	ScenarioFramework.CreateIntelAtLocation(500.0, intelPos, ARMY_PLAYER, 'Radar', -1)
	ScenarioFramework.CreateIntelAtLocation(100.0, intelPos, ARMY_PLAYER, 'Vision', -1)

	-- depricating ogrid blocker - bfricks 1/8/10
	-- create our path-blocking hoo-ha
	--ScenarioFramework.CreateOGridBlockers(ScenarioInfo.ALLY01_Station,'O_GRID_BLOCKERS', 'ARMY_ALLY01')
end

---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------
function ENEM01_CDR_DeathDamage(CDRUnit)
	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
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
	if ScenarioInfo.M2_obj20 then
		ScenarioInfo.M2_obj20:ManualResult(true)
	end
	ForkThread(OpNIS.NIS_VICTORY, unit)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	--P2_Setup()
	P1_EnemyRetreat()
	--P1_SpawnExperimentalAttack()
end

function OnShiftF4()
	ScenarioFramework.SetPlayableArea('AREA_2', false)
 	import('/lua/system/Utilities.lua').UserConRequest('SallyShears')

	ScenarioInfo.DINO_BLOWS_UP_01	= ScenarioUtils.CreateArmyUnit('ARMY_GANTRY', 'DINO_BLOWS_UP_01')
	ScenarioInfo.DINO_BLOWS_UP_02	= ScenarioUtils.CreateArmyUnit('ARMY_GANTRY', 'DINO_BLOWS_UP_02')

	ProtectUnit(ScenarioInfo.DINO_BLOWS_UP_01)
	ProtectUnit(ScenarioInfo.DINO_BLOWS_UP_02)

	ScenarioInfo.ENEM01_CDR	= ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_CDR')
	ScenarioInfo.P2_GANTRY_DinoFactory = ScenarioUtils.CreateArmyUnit('ARMY_GANTRY', 'P2_GANTRY_DinoFactory')
	ProtectUnit(ScenarioInfo.P2_GANTRY_DinoFactory)
	P2_RevealDino(ScenarioInfo.ENEM01_CDR)
end

function OnShiftF5()
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
	LOG('---- MASS: Wreckage mass on map is: ' .. mass)
end
