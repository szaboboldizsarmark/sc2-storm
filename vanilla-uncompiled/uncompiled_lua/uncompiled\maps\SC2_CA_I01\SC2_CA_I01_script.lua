---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_I01/SC2_CA_I01_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_I01/SC2_CA_I01_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_I01/SC2_CA_I01_OpNIS.lua')
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

ScenarioInfo.EnemyArmada = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01
local ARMY_CIVL01 = ScenarioInfo.ARMY_CIVL01

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local BargeMaxHeath				= 150000		-- Max health value of the north barge blockade unit
local SoulRipperHealthIncrement	= 4100			-- Increment used to determine the Max health value of the Soul Ripper unit
local BargeVisRadius			= 110			-- Visual Radius of the barge blockade units
local PlayerStartIntelRadius	= 500			-- Radius of start player's radar, that the player gets intel from

local Wave01_DELAY				= 60			-- Wave01 movement delay
local Wave02_DELAY				= 240			-- Wave02 movement delay
local Wave03_DELAY				= 390			-- Wave03 movement delay
local Wave04_DELAY				= 540			-- Wave04 movement delay
local Wave05_DELAY				= 690			-- Wave05 movement delay
local Wave06_DELAY				= 870			-- Wave06 movement delay

-- wave 01 unit composition
local Wave01_Gunships			= 0				-- Wave01 Gunship Count
local Wave01_FighterBombers		= 4				-- Wave01 Fighter/Bomber Count
local Wave01_Destroyers			= 2				-- Wave01 Destroyer Count
local Wave01_Battleships		= 1				-- Wave01 Battleship Count

-- wave 02 unit composition
local Wave02_Gunships			= 0				-- Wave02 Gunship Count
local Wave02_FighterBombers		= 8				-- Wave02 Fighter/Bomber Count
local Wave02_Destroyers			= 4				-- Wave02 Destroyer Count
local Wave02_Battleships		= 1				-- Wave02 Battleship Count

-- wave 03 unit composition
local Wave03_Gunships			= 2				-- Wave03 Gunship Count
local Wave03_FighterBombers		= 8				-- Wave03 Fighter/Bomber Count
local Wave03_Destroyers			= 2				-- Wave03 Destroyer Count
local Wave03_Battleships		= 2				-- Wave03 Battleship Count

-- wave 04 unit composition
local Wave04_Gunships			= 0				-- Wave04 Gunship Count
local Wave04_FighterBombers		= 0				-- Wave04 Fighter/Bomber Count
local Wave04_Destroyers			= 3				-- Wave04 Destroyer Count
local Wave04_Battleships		= 1				-- Wave04 Battleship Count

-- wave 05 unit composition
local Wave05_Gunships			= 8				-- Wave05 Gunship Count
local Wave05_FighterBombers		= 12			-- Wave05 Fighter/Bomber Count
local Wave05_Destroyers			= 5				-- Wave05 Destroyer Count
local Wave05_Battleships		= 3				-- Wave05 Battleship Count

-- wave 06 unit composition
local Wave06_Gunships			= 8				-- Wave06 Gunship Count
local Wave06_FighterBombers		= 15			-- Wave06 Fighter/Bomber Count
local Wave06_Destroyers			= 6				-- Wave06 Destroyer Count
local Wave06_Battleships		= 3				-- Wave06 Battleship Count


---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.3,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.I01_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.I01_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_ALLY01,	ScenarioGameTuning.color_CIV_I01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CIVL01,	ScenarioGameTuning.color_CIV_I01)
end

---------------------------------------------------------------------
function OnStart(self)
	ScenarioGameSetup.CAMPAIGN_OnStart()
end

---------------------------------------------------------------------
function OnInitCamera(scen)
	---NOTE: I01 needs a few extra seconds before we begin the standard launch process to allow for some custom wreckage units around the map - bfricks 11/14/09

	ForkThread(
		function()
			-- create sunken ships, and other misc destruction units, and kill them
			local group = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'FOR_KILL')
			WaitSeconds(0.1)
			ForceGroupDeath(group)

			WaitSeconds(3.0)

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
	)
end

---------------------------------------------------------------------
-- PART 1:
---------------------------------------------------------------------
function P1_Setup()
	LOG('----- P1_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 1

	-- create capturable items
	ScenarioInfo.CapturableUnits = ScenarioUtils.CreateArmyGroup('ARMY_CIVL01', 'FOR_CAPTURE')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.CapturableUnits, 1)

	-- Create barge blockade with adjustable health and intel
	CreateBlockade()

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_InitLand_Offense01')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group1, 3)
	ScenarioInfo.INTRONIS_Group2 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_InitLand_Offense02')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group2, 3)
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_Commander_Group')

	--ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')
	--ScenarioInfo.INTRONIS_Group2Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_02')
	--ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_03')

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Thalia)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Createtech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')

	-- Create the Soul Ripper and set his health
	ScenarioInfo.SoulRipper = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_SoulRipper')
	if ScenarioInfo.Options.Difficulty == 3 then
		ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.SoulRipper, 5)
	elseif ScenarioInfo.Options.Difficulty == 2 then
		ScenarioInfo.SoulRipper.Level = 5
		local health = SoulRipperHealthIncrement * 2.0
		ScenarioInfo.SoulRipper:SetMaxHealth(health)
		ScenarioInfo.SoulRipper:AdjustHealth(ScenarioInfo.SoulRipper, health)
	else
		ScenarioInfo.SoulRipper.Level = 5
		local health = SoulRipperHealthIncrement
		ScenarioInfo.SoulRipper:SetMaxHealth(health)
		ScenarioInfo.SoulRipper:AdjustHealth(ScenarioInfo.SoulRipper, health)
	end
end

function P1_Main()
	-- create timer triggers that will spawn the cybran naval groups in waves
	CreateAttackWave( Wave01_DELAY, Wave01_Gunships, Wave01_FighterBombers, Wave01_Destroyers, Wave01_Battleships, false, true )
	CreateAttackWave( Wave02_DELAY, Wave02_Gunships, Wave02_FighterBombers, Wave02_Destroyers, Wave02_Battleships, false, false )
	CreateAttackWave( Wave03_DELAY, Wave03_Gunships, Wave03_FighterBombers, Wave03_Destroyers, Wave03_Battleships, false, false )
	CreateAttackWave( Wave04_DELAY, Wave04_Gunships, Wave04_FighterBombers, Wave04_Destroyers, Wave04_Battleships, true, false )
	CreateAttackWave( Wave05_DELAY, Wave05_Gunships, Wave05_FighterBombers, Wave05_Destroyers, Wave05_Battleships, true, false )
	CreateAttackWave( Wave06_DELAY, Wave06_Gunships, Wave06_FighterBombers, Wave06_Destroyers, Wave06_Battleships, true, false )
	ScenarioFramework.CreateTimerTrigger (LaunchSoulRipper, Wave04_DELAY + 45)

	----------------------------------------------
	-- Primary Objective M1_obj10 - Destroy the enemy Armada
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Destroy the enemy Armada.')
	ScenarioInfo.M1_obj10 = SimObjectives.Basic(
		'primary',										-- type
		'incomplete',									-- status
		OpStrings.I01_M1_obj10_NAME,					-- title
		OpStrings.I01_M1_obj10_DESC,					-- description
		SimObjectives.GetActionIcon('killorcapture'),	-- Action
		{
			MarkUnits = true,
			Units = ScenarioInfo.EnemyArmada,
			Areas = {
				'CAMERA_ZOOM_AREA_01',
				'CAMERA_ZOOM_AREA_02',
			}
		}
	)

	-- Update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	-- Create radar intel for player that covers the entire map
	ScenarioFramework.CreateIntelAtLocation(PlayerStartIntelRadius, 'PLAYER_Intel_Location', ARMY_PLAYER, 'Radar')

	-- Create area trigger for defeat if enemy naval units enter it
	ScenarioFramework.CreateAreaTrigger(
		function()
			-- pass in the data required to use the center pos for our fail NIS
			local rect = ScenarioUtils.AreaToRect('AREA_DEFEAT_TRIGGER')
	        local w = rect.x1 - rect.x0
	        local h = rect.y1 - rect.y0
	        local x = rect.x0 + ( w / 2.0 )
	        local z = rect.y0 + ( h / 2.0 )
			local pos = {x, GetTerrainHeight(x,z), z}
			Defeat(true, pos, OpDialog.I01_FAILED)
		end,
		'AREA_DEFEAT_TRIGGER',
		categories.CYBRAN * categories.NAVAL,
		true,
		false,
		ArmyBrains[ARMY_ENEM01],
		1,
		false
	)

	-- Create group death trigger for victory condition
	ScenarioFramework.CreateGroupDeathTrigger( Victory, ScenarioInfo.EnemyArmada )

	----------------------------------------------
	--VO triggers
	----------------------------------------------
	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (ResearchSecondary_VO, 25)

	-- area trigger that plays VO when enemy naval vessels enter the blockade area
	ScenarioFramework.CreateAreaTrigger(BlockadeProgress_VO, 'BLOCKADE_AREA',
		categories.NAVAL + categories.CYBRAN, true, false, ArmyBrains[ARMY_ENEM01], 1, false)

	-- army intel trigger that plays VO when the player has intel confirmation of an enemy aircraft carrier
	ScenarioFramework.CreateArmyIntelTrigger(AircraftCarrier_VO, ArmyBrains[ARMY_PLAYER], 'Radar', false, true,
		 categories.ucs0901, true, ArmyBrains[ARMY_ENEM01])
end

function BlockadeProgress_VO()
	ScenarioFramework.Dialogue(OpDialog.I01_BLOCKADE_PROGRESS_010)
end

function BlockadeProgressDamaged_VO()
	ScenarioFramework.Dialogue(OpDialog.I01_BLOCKADE_PROGRESS_050)
end

function BlockadeProgressDown_VO()
	LOG('----- P1: cybran armada has made it past the blockade')
	ScenarioFramework.Dialogue(OpDialog.I01_BLOCKADE_DOWN_010)

	ForceUnitDeath(ScenarioInfo.Block01)
	ForceUnitDeath(ScenarioInfo.Block02)
	ForceUnitDeath(ScenarioInfo.Block04)

	IssueMove(ScenarioInfo.EnemyArmada, ScenarioUtils.MarkerToPosition('ENEM01_End'))
end

function AircraftCarrier_VO()
	ScenarioFramework.Dialogue(OpDialog.I01_AIRCRAFT_CARRIER_010)
end

function ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.I01_RESEARCH_UNLOCK, ResearchSecondary_Assign)
end

function ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.I01_S3_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S3_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.I01_S3_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S3_obj10)

	ScenarioInfo.S3_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.I01_RESEARCH_FOLLOWUP_SEAHUNTER_010)
			end
		end
	)
end

function CreateAttackWave(nDelay, nGunshipCount, nFighterBomberCount, nDestroyerCount, nBattleshipCount, bUseCarrier, bUseWarpPoint )
	-- first we setup the data table
	local WaveData = {}
	WaveData.AirUnits = {}
	WaveData.Destroyers = {}
	WaveData.Battleships = {}
	WaveData.CarrierUnit = nil

	-- build all the destroyers
	for i = 1, nDestroyerCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_Destroyer')
		table.insert(WaveData.Destroyers, unit)
		table.insert(ScenarioInfo.EnemyArmada, unit)

	end

	-- build all the battleships
	for i = 1, nBattleshipCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_Battleship')
		table.insert(WaveData.Battleships, unit)
		table.insert(ScenarioInfo.EnemyArmada, unit)
	end

	-- build the carrier - if required
    if bUseCarrier then
    	WaveData.CarrierUnit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_Carrier')
		table.insert(ScenarioInfo.EnemyArmada, WaveData.CarrierUnit)
	end

	ForkThread(
		function()
			-- for at least the first wave, we warp the units closer in and onto the play surface right away
			if bUseWarpPoint then
				for k, unit in WaveData.Destroyers do
					if unit and not unit:IsDead() then
						Warp( unit,  ScenarioUtils.MarkerToPosition('ENEM01_WARP_POINT') )
					end
				end
				for k, unit in WaveData.Battleships do
					if unit and not unit:IsDead() then
						Warp( unit,  ScenarioUtils.MarkerToPosition('ENEM01_WARP_POINT') )
					end
				end
			end

			-- wait before sending any units
			WaitSeconds(nDelay)

			-- send the destroyers first
			for k, unit in WaveData.Destroyers do
				IssueMove( {unit}, ScenarioUtils.MarkerToPosition('P1_ENEM01_NavalChain_0' .. k) )
				IssueMove( {unit}, ScenarioUtils.MarkerToPosition('ENEM01_Move') )
				if ScenarioInfo.Block03 and not ScenarioInfo.Block03:IsDead() then
					IssueAttack( {unit}, ScenarioInfo.Block03 )
				end
			end

			WaitSeconds(4.0)

			-- send the battleships next
			for k, unit in WaveData.Battleships do
				IssueMove( {unit}, ScenarioUtils.MarkerToPosition('P1_ENEM01_NavalChain_0' .. k) )
				IssueMove( {unit}, ScenarioUtils.MarkerToPosition('ENEM01_Move') )
				if ScenarioInfo.Block03 and not ScenarioInfo.Block03:IsDead() then
					IssueAttack( {unit}, ScenarioInfo.Block03 )
				end
			end

			WaitSeconds(4.0)

			-- send the carrier
			if WaveData.CarrierUnit then
				IssueMove( {WaveData.CarrierUnit}, ScenarioUtils.MarkerToPosition('P1_ENEM01_NavalChain_01') )
				IssueMove( {WaveData.CarrierUnit}, ScenarioUtils.MarkerToPosition('ENEM01_Move') )
				if ScenarioInfo.Block03 and not ScenarioInfo.Block03:IsDead() then
					IssueAttack( {WaveData.CarrierUnit}, ScenarioInfo.Block03 )
				end
			end

			WaitSeconds(2.0)

			-- build the gunships
			for i = 1, nGunshipCount do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_Gunship')
				table.insert(WaveData.AirUnits, unit)
			end

			-- build the bombers
			for i = 1, nFighterBomberCount do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_FighterBomber')
				table.insert(WaveData.AirUnits, unit)
			end

			-- have any air units guard the carrier, if a carrier exists, then patrol if it dies
			if WaveData.CarrierUnit then
				IssueGuard(WaveData.AirUnits, WaveData.CarrierUnit)
				IssuePatrol(WaveData.AirUnits, ScenarioUtils.MarkerToPosition( 'ENEM01_AirPatrol_01_01' ) )
			end

			-- have any air units guard the battleships, if any battleships exists, then patrol if it dies
			if WaveData.Battleships then
				for k, v in WaveData.Battleships do
					IssueGuard(WaveData.AirUnits, v)
					IssuePatrol(WaveData.AirUnits, ScenarioUtils.MarkerToPosition( 'ENEM01_AirPatrol_01_01' ) )
				end
			end

			-- have any air units guard the destroyers, if any destroyers exists, then patrol if it dies
			if WaveData.Destroyers then
				for k, v in WaveData.Destroyers do
					IssueGuard(WaveData.AirUnits, v)
					IssuePatrol(WaveData.AirUnits, ScenarioUtils.MarkerToPosition( 'ENEM01_AirPatrol_01_01' ) )
				end
			end
		end
	)
end

function LaunchSoulRipper()
	LOG('----- P2: soulripper has spawned north and will patrol and eventually attack the players base')

	-- Tell player that an incoming soulripper experimental is heading to his base shortly
	ScenarioFramework.Dialogue(OpDialog.I01_SOULRIPPER_ATTACK_010, AssignSoulRipperObjective)

	--guard cybran naval units
	local cybranNavalUnits = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.NAVAL, false)
	for k, v in cybranNavalUnits do
		IssueGuard( {ScenarioInfo.SoulRipper}, v )
	end

	-- get all player units except air and attack them with the soul ripper
	local playerUnits = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.ALLUNITS - categories.AIR, false)
	for k, v in playerUnits do
		-- Issue attack on player units if all other cybran naval units are dead
		IssueAttack( {ScenarioInfo.SoulRipper}, v )
	end
end

function Victory()
	ForkThread(
		function()
			-- Complete the objective
			ScenarioInfo.M1_obj10:ManualResult(true)

			-- create an empty list to use
			ScenarioInfo.AssignedObjectives.VictoryCallbackList = {}

			-- for each specific hidden objective you to complete
			if CheckBlockHealth() then
				table.insert(ScenarioInfo.AssignedObjectives.VictoryCallbackList, HiddenObjective )
			end

			WaitSeconds(5)

			OpNIS.NIS_VICTORY()
		end
	)
end

function AssignSoulRipperObjective()
	----------------------------------------------
	-- Secondary Objective S1_obj10 - Destroy the Soul Ripper
	----------------------------------------------
	LOG('----- P2: Assign Secondary Objective S1_obj10 - Destroy the Soul Ripper.')
	local descText = OpStrings.I01_S1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I01_S1_obj10_KILL_SOULRIPPER)
	ScenarioInfo.S1_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.I01_S1_obj10_NAME,		-- title
		descText,							-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			AlwaysInRadar = true,
			Units = {ScenarioInfo.SoulRipper},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)

	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I01_S1_obj10_KILL_SOULRIPPER, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.I01_SOULRIPPER_KILLED_010)
			end
		end
	)
end

function HiddenObjective()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Blockade Defense
	----------------------------------------------
	LOG('----- Assign Hidden Objective H1_obj10 - Blockade Defense')
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',									-- type
		'complete',										-- status
		OpStrings.I01_H1_obj10_NAME,					-- title
		OpStrings.I01_H1_obj10_DESC,					-- description
		SimObjectives.GetActionIcon('protect'),			-- Action
		{
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)
end

function CheckBlockHealth()
	local ret = false

	if ScenarioInfo.Block03 and not ScenarioInfo.Block03:IsDead() then
		if ScenarioInfo.Block03:GetHealthPercent() > 0.75 then
			ret = true
		end
	end

	return ret
end

function CreateBlockade()
	---NOTE: while there are four actual objects placed, only the third one will be used for taking and tracking damage
	---			all others will effectively be invalid targets just on the map for show - bfricks 11/8/09
	ScenarioInfo.Block03 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_BLOCK03')
	ScenarioInfo.Block03:SetIntelRadius('Vision', BargeVisRadius)
	ScenarioInfo.Block03:SetMaxHealth(BargeMaxHeath)
	ScenarioInfo.Block03:AdjustHealth(ScenarioInfo.Block03, BargeMaxHeath)
	ScenarioInfo.Block03:SetCustomName(ScenarioGameNames.UNIT_SCB2101)

	-- create the three faux blockades
	ScenarioInfo.Block01 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_BLOCK01')
	ScenarioInfo.Block02 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_BLOCK02')
	ScenarioInfo.Block04 = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_BLOCK04')
	ProtectUnit(ScenarioInfo.Block01)
	ProtectUnit(ScenarioInfo.Block02)
	ProtectUnit(ScenarioInfo.Block04)

	-- unit death trigger that plays VO when the blockade has been destroyed
	ScenarioFramework.CreateUnitDeathTrigger( BlockadeProgressDown_VO, ScenarioInfo.Block03 )

	-- unit heath ratio trigger that plays VO when the blockade has been reduced to half health
	ScenarioFramework.CreateUnitHealthRatioTrigger(BlockadeProgressDamaged_VO, ScenarioInfo.Block03, .5, true, true)

	-- create our path-blocking hoo-ha
	ScenarioFramework.CreateOGridBlockers(ScenarioInfo.Block03,'O_GRID_BLOCKERS', 'ARMY_ALLY01', 'O_GRID_BLOCKERS_LARGE')
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	import('/lua/system/Utilities.lua').UserConRequest('SallyShears')
	import('/lua/system/Utilities.lua').UserConRequest('dbg collision')
	import('/lua/system/Utilities.lua').UserConRequest('ren_SelectionMeshes')
	CreateBlockade()
end