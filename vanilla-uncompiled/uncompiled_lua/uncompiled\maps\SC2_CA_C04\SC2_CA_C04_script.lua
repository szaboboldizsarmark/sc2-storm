---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_C04/SC2_CA_C04_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_C04/SC2_CA_C04_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_C04/SC2_CA_C04_OpNIS.lua')
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
ScenarioInfo.ARMY_ALLYUEF = 3
ScenarioInfo.ARMY_ALLYILL = 4

ScenarioInfo.AssignedObjectives = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALLYUEF = ScenarioInfo.ARMY_ALLYUEF
local ARMY_ALLYILL = ScenarioInfo.ARMY_ALLYILL

local ReservoirAttackCounter = 0

local nNumCDRsDestroyed = 0

local DarkenoidAttackFlag = false

local PlayerNotAtStartLocation = false

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local ReservoirAttack_TIMER01 = 480		-- Initial time before the reservoir group send some assault blocks to attack
local ReservoirAttack_TIMER02 = 1020	-- Second timer that will send more assault blocks to attack from the reservoir group

local LandAttackUEFNorth = {
	'LandAttackUEFNorth',	-- unique custom platoon name
	{
		{ 'uil0101', 3 },	-- Illuminate tanks
		{ 'uil0103', 2 }, 	-- Illuminate assault bots
	},
}

local LandAttackILLSouth = {
	'LandAttackILLSouth',	-- unique custom platoon name
	{
		{ 'uil0101', 3 },	-- Illuminate tanks
		{ 'uil0103', 2 }, 	-- Illuminate assault bots
	},
}

---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	-- NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.1,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.C04_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.C04_ARMY_ENEM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ALLYUEF,	ScenarioGameTuning.C04_ARMY_ALLYUEF)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ALLYILL,	ScenarioGameTuning.C04_ARMY_ALLYILL)

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

	-- create units used in the opening NIS sequence - including the player CDR, Transports and death trigger 'JTM 9/9/09'
	LOG('----- P1_Setup: Setup for the player CDR.')

	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')

	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Transport_Group1')
	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_02')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group1, 5)

	ScenarioInfo.INTRONIS_Group2 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Transport_Group2')
	ScenarioInfo.INTRONIS_Group2Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_03')

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Ivan)

	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	LOG('----- P1_Setup: Create commanders')
	-- Create our commanders
	ScenarioInfo.ENEM01_CDR_Burkett 	= ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_CDR_Burkett')
	ScenarioInfo.ENEM01_CDR_Larson      = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_CDR_Larson')
	ScenarioInfo.ENEM01_CDR_Walker	    = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_CDR_Walker')
	ScenarioInfo.ALLYUEF_CDR			= ScenarioUtils.CreateArmyUnit('ARMY_ALLYUEF', 'ALLYUEF_CDR')
	ScenarioInfo.ALLYILL_CDR			= ScenarioUtils.CreateArmyUnit('ARMY_ALLYILL', 'ALLYILL_CDR')

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.ENEM01_CDR_Burkett:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.ENEM01_CDR_Larson:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.ENEM01_CDR_Walker:RemoveCommandCap('RULEUCC_Reclaim')

	---NOTE: in order to limit the chances of failed missions, ally CDRs that can be killed should not reclaim or repair - bfricks 12/8/09
	ScenarioInfo.ALLYUEF_CDR:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.ALLYUEF_CDR:RemoveCommandCap('RULEUCC_Repair')
	ScenarioInfo.ALLYILL_CDR:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.ALLYILL_CDR:RemoveCommandCap('RULEUCC_Repair')

	---NOTE: and also to further limit the chances of accidental overly early failed missions - we will disable targeting for some time - bfricks 1/6/10
	ScenarioInfo.ALLYUEF_CDR:SetDoNotTarget(true)
	ScenarioInfo.ALLYILL_CDR:SetDoNotTarget(true)
	ScenarioFramework.CreateTimerTrigger(
		function()
			LOG('----- ALLY SAFETY TIMER EXPIRED: Ally commanders are now being set as potential targets for the enemy.')
			if ScenarioInfo.ALLYUEF_CDR and not ScenarioInfo.ALLYUEF_CDR:IsDead() then
				ScenarioInfo.ALLYUEF_CDR:SetDoNotTarget(false)
			end

			if ScenarioInfo.ALLYILL_CDR and not ScenarioInfo.ALLYILL_CDR:IsDead() then
				ScenarioInfo.ALLYILL_CDR:SetDoNotTarget(false)
			end
		end,
		900
	)

	---NOTE: and because the repair flag will get reset by NISs - lets tag this unit with data to prevent that - bfricks 12/8/09
	if not ScenarioInfo.ALLYUEF_CDR.ScenarioUnitData then
		ScenarioInfo.ALLYUEF_CDR.ScenarioUnitData = {}
	end
	ScenarioInfo.ALLYUEF_CDR.ScenarioUnitData.RepairRestricted = true

	---NOTE: and because the repair flag will get reset by NISs - lets tag this unit with data to prevent that - bfricks 12/8/09
	if not ScenarioInfo.ALLYILL_CDR.ScenarioUnitData then
		ScenarioInfo.ALLYILL_CDR.ScenarioUnitData = {}
	end
	ScenarioInfo.ALLYILL_CDR.ScenarioUnitData.RepairRestricted = true

	-- give the illuminate CDRs a veterancy level
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_CDR_Burkett, 3)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_CDR_Larson, 4)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_CDR_Walker, 5)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ALLYUEF_CDR, 3)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ALLYILL_CDR, 3)

	-- set custom names
	ScenarioInfo.ALLYILL_CDR:SetCustomName(ScenarioGameNames.CDR_Thalia)
	ScenarioInfo.ALLYUEF_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)


	ScenarioInfo.ENEM01_CDR_Burkett:SetCustomName(ScenarioGameNames.CDR_Burkett)
	ScenarioInfo.ENEM01_CDR_Larson:SetCustomName(ScenarioGameNames.CDR_Larson)
	ScenarioInfo.ENEM01_CDR_Walker:SetCustomName(ScenarioGameNames.CDR_Walker)

	-- CDR death damage triggers
	ScenarioFramework.CreateUnitDeathTrigger(ENEM01_CDR_Burkett_DeathDamage, ScenarioInfo.ENEM01_CDR_Burkett)
	ScenarioFramework.CreateUnitDeathTrigger(ENEM01_CDR_Larson_DeathDamage, ScenarioInfo.ENEM01_CDR_Larson)
	ScenarioFramework.CreateUnitDeathTrigger(ENEM01_CDR_Walker_DeathDamage, ScenarioInfo.ENEM01_CDR_Walker)

	LOG('----- P1_Setup: Create commander patrol chain')
	-- Patrol commands given to all enemy acu's instead of adding them as an engineer for the base to avoid 'easy'
	-- kills for the player if the enemy ACU move to rebuild a destroyed base structure on the edge of a base.
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.ENEM01_CDR_Burkett}, ScenarioPlatoonAI.GetRandomPatrolRoute('ArmyBase_ENEM01_West_Base_CDRChain'))
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.ENEM01_CDR_Larson}, ScenarioPlatoonAI.GetRandomPatrolRoute('ArmyBase_ENEM01_East_Base_CDRChain'))
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.ENEM01_CDR_Walker}, ScenarioPlatoonAI.GetRandomPatrolRoute('ArmyBase_ENEM01_Main_Base_CDRChain'))
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.ALLYUEF_CDR}, ScenarioPlatoonAI.GetRandomPatrolRoute('ArmyBase_ALLYUEF_Main_Base_CDRChain'))
	ScenarioFramework.GroupPatrolRoute({ScenarioInfo.ALLYILL_CDR}, ScenarioPlatoonAI.GetRandomPatrolRoute('ArmyBase_ALLYILL_Main_Base_CDRChain'))

	LOG('----- P1_Setup: Create starting base managers and opais')
	-- Set their bases up
	P1_AISetup_ALLYUEF()
	P1_AISetup_ALLYILL()
	P1_AISetup_ENEM01_West()
	P1_AISetup_ENEM01_East()
	P1_AISetup_ENEM01_Main()

	-- Table to contain the enemy reservoir platoons in the middle area.
	ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable = {}

	-- Create the starting engineers and units for player
	ScenarioInfo.P1_PLAYER_Engineer01 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Engineer01')
	ScenarioInfo.P1_PLAYER_StartingUnits = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_StartingUnits')

	-- Create initial enemy land attack groups
	ScenarioInfo.P1_ENEM01_LandAttack01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_LandAttack02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack02', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_LandAttack03 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack03', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_LandAttack04 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack04', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_LandAttack05 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack05', 'AttackFormation')

	-- get all land units from the west base and give them a veterancy buff
	local enemyLand = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.uil0101 + categories.uil0103 + categories.uil0104,false)
	for k, unit in enemyLand do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 5)
	end

	-- Create some base structures outside the base managers to avoid potential rebuild
	ScenarioInfo.ArmyBase_ENEM01_WestBase = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_West_Base_NoRebuild')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.ArmyBase_ENEM01_WestBase, 3)
	ScenarioInfo.ArmyBase_ENEM01_EastBase = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_East_Base_NoRebuild')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.ArmyBase_ENEM01_EastBase, 4)
	ScenarioInfo.ArmyBase_ENEM01_MainBase = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Main_Base_NoRebuild')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.ArmyBase_ENEM01_MainBase, 5)

	-- Create the Temples,  flag them protected, and seet their beacon points.
	ScenarioInfo.P1_ENEM01_Temple01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Temple_01')
	ScenarioInfo.P1_ENEM01_Temple02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Temple_02')
	ProtectUnit(ScenarioInfo.P1_ENEM01_Temple01)
	ProtectUnit(ScenarioInfo.P1_ENEM01_Temple02)
	IssueTransportUnload({ScenarioInfo.P1_ENEM01_Temple01}, ScenarioUtils.MarkerToPosition('P1_Temple01_Destination'))
	IssueTransportUnload({ScenarioInfo.P1_ENEM01_Temple02}, ScenarioUtils.MarkerToPosition('P1_Temple02_Destination'))

	-- L33t trick to get the beacon this tick (and set the beacons to protected immediately)
	ForkThread(
		function()
			local beacon = ScenarioInfo.P1_ENEM01_Temple01:GetTeleportBeacon()
			while not beacon do
			    WaitTicks(1)
			    beacon = ScenarioInfo.P1_ENEM01_Temple01:GetTeleportBeacon()
			end
			ProtectUnit(beacon)
			LOG('*SCENARIO DEBUG: Setting beacon')
			ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_Temple01_Beacon'] = beacon
		end
	)

	ForkThread(
		function()
			local beacon = ScenarioInfo.P1_ENEM01_Temple02:GetTeleportBeacon()
			while not beacon do
			    WaitTicks(1)
			    beacon = ScenarioInfo.P1_ENEM01_Temple02:GetTeleportBeacon()
			end
			ProtectUnit(beacon)
			LOG('*SCENARIO DEBUG: Setting beacon')
			ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_Temple02_Beacon'] = beacon
		end
	)

	-- Create the starting Blocks that act as the reservoir. These will be dealt with as platoons, so
	-- create platoons for each member and add them to it. Add each to the platoon table that we will
	-- draw from for some attacks. As well, set each as a platoon that fulfills the platoon count for
	-- the OpAI that maintains this group.
	local units = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Main_InitBlocks')
	for k, v in units do
		local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
		ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {v}, 'Attack', 'AttackFormation' )
		table.insert(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable, platoon)
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Main_ReservoirDef_Patrol_01')
		ScenarioInfo.ENEM01_Main_Land_Reservoir_OpAI:AddActivePlatoon(platoon, false)
	end

	-- Create tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')
end

function P1_Main()

	------------------
	-- Objectives
	------------------

	----------------------------------------------
	-- Primary Objective M1_obj10 - Destroy Enemy Commanders
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Destroy Enemy Commanders.')
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',						-- type
		'incomplete',					-- status
		OpStrings.C04_M1_obj10_NAME,	-- title
		OpStrings.C04_M1_obj10_DESC,	-- description
		{
			MarkUnits = true,
			Units = { ScenarioInfo.ENEM01_CDR_Burkett, ScenarioInfo.ENEM01_CDR_Larson, ScenarioInfo.ENEM01_CDR_Walker },
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	----------------------------------------------
	-- Primary Objective M2_obj10 - Defend Allies
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M2_obj10 - Defend Allies.')
	ScenarioInfo.M2_obj10 = SimObjectives.Protect(
		'primary',						-- type
		'incomplete',					-- status
		OpStrings.C04_M2_obj10_NAME,	-- title
		OpStrings.C04_M2_obj10_DESC,	-- description

		{
			MarkUnits = true,
			Units = {ScenarioInfo.ALLYUEF_CDR, ScenarioInfo.ALLYILL_CDR},
		}
	)

	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)

	local curPos01 = ScenarioInfo.ALLYUEF_CDR:GetPosition()
	ScenarioInfo.FAIL_PositionUEF = {curPos01[1], curPos01[2], curPos01[3]}

	local curPos02 = ScenarioInfo.ALLYILL_CDR:GetPosition()
	ScenarioInfo.FAIL_PositionILL = {curPos02[1], curPos02[2], curPos02[3]}

	ScenarioInfo.M2_obj10:AddResultCallback(
		function(result)
			if not result then
				-- first handle the case of Maddox being Alive still
				if ScenarioInfo.ALLYUEF_CDR and not ScenarioInfo.ALLYUEF_CDR:IsDead() then
					-- if possible, get the most recent position, otherwise use the store position
					if ScenarioInfo.ALLYILL_CDR then
						local curPos = ScenarioInfo.ALLYILL_CDR:GetPosition()
						local failPos = {curPos[1], curPos[2], curPos[3]}
						Defeat(true, failPos, OpDialog.C04_ALLY_DEATH)
					else
						Defeat(true, ScenarioInfo.FAIL_PositionILL, OpDialog.C04_ALLY_DEATH)
					end

				-- then handle the case of Thalia being Alive still
				elseif ScenarioInfo.ALLYILL_CDR and not ScenarioInfo.ALLYILL_CDR:IsDead() then
					-- if possible, get the most recent position, otherwise use the store position
					if ScenarioInfo.ALLYUEF_CDR then
						local curPos = ScenarioInfo.ALLYUEF_CDR:GetPosition()
						local failPos = {curPos[1], curPos[2], curPos[3]}
						Defeat(true, failPos, OpDialog.C04_ALLY_DEATH)
					else
						Defeat(true, ScenarioInfo.FAIL_PositionUEF, OpDialog.C04_ALLY_DEATH)
					end
				end
			end
		end
	)


	------------------
	-- Event Triggers
	------------------

	-- setup each possible ending unit for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEM01_CDR_Burkett, Launch_ENEM01_CDR03_DeathNIS)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEM01_CDR_Larson, Launch_ENEM01_CDR02_DeathNIS)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEM01_CDR_Walker, Launch_ENEM01_CDR01_DeathNIS)

	-- Send initial enemy land around west base on patrols
	if ScenarioInfo.P1_ENEM01_LandAttack01 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_LandAttack01) then
		ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P1_ENEM01_LandAttack01, 'P1_ENEM01_Land_AttackUEF01_01')
	end
	if ScenarioInfo.P1_ENEM01_LandAttack02 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_LandAttack02) then
		ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P1_ENEM01_LandAttack02, 'P1_ENEM01_Land_AttackUEF02_01')
	end
	if ScenarioInfo.P1_ENEM01_LandAttack03 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_LandAttack03) then
		ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P1_ENEM01_LandAttack03, 'P1_ENEM01_Land_AttackUEF03_01')
	end
	if ScenarioInfo.P1_ENEM01_LandAttack04 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_LandAttack04) then
		ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P1_ENEM01_LandAttack04, 'P1_ENEM01_Land_AttackUEF04_01')
	end
	if ScenarioInfo.P1_ENEM01_LandAttack05 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_LandAttack05) then
		ScenarioFramework.PlatoonPatrolChain (ScenarioInfo.P1_ENEM01_LandAttack05, 'P1_ENEM01_Land_AttackUEF05_01')
	end

	-- Create timer trigger that will start the player base check
	ScenarioFramework.CreateTimerTrigger (function() ForkThread(PlayerBaseCheck) end, 30)

	-- Create timer trigger that will start darkenoid attacks
	ScenarioFramework.CreateTimerTrigger( P1_ResearchSecondary_VO, 90 )

	-- Create timer trigger to assign research objective
	ScenarioFramework.CreateTimerTrigger( P1_ENEM01_DarkenoidAttackSecondary, 2100 )

	-- Initiate assault block attacks
	ScenarioFramework.CreateTimerTrigger (P1_ReservoirAttack, ReservoirAttack_TIMER01)

	-- Initiate a second wave of assault blocks
	ScenarioFramework.CreateTimerTrigger (P1_ReservoirAttack, ReservoirAttack_TIMER02)

	-- Unit health triggers for each enemy CDR when their health is reduced to 50% or less
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_Guard_Burkett, ScenarioInfo.ENEM01_CDR_Burkett, 0.5, true, true)
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_Guard_Larson, ScenarioInfo.ENEM01_CDR_Larson, 0.5, true, true)
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_Guard_Walker, ScenarioInfo.ENEM01_CDR_Walker, 0.5, true, true)

	-- Area trigger that will stop rebuild for the bases after half the factories are destroyed
	local catsToCheck = categories.uib0001 + categories.uib0002 + categories.uib0011
	ScenarioFramework.CreateAreaTrigger(P1_ENEM01_StopWestBaseRebuild, 'P1_West_Base_Area', categories.uib0001, true, true, ArmyBrains[ARMY_ENEM01], 3, false)
	ScenarioFramework.CreateAreaTrigger(P1_ENEM01_StopEastBaseRebuild, 'P1_East_Base_Area', categories.uib0002, true, true, ArmyBrains[ARMY_ENEM01], 3, false)
	ScenarioFramework.CreateAreaTrigger(P1_ENEM01_StopMainBaseRebuild, 'P1_Main_Base_Area', catsToCheck, true, true, ArmyBrains[ARMY_ENEM01], 7, false)

	-- Begin building darknoids to attack allies after CDR01 + CDR02 die
	ScenarioFramework.CreateArmyStatTrigger(P1_ENEM01_DarkenoidAttack, ArmyBrains[ARMY_ENEM01], 'P1_EnemyDarkenoidAttackAllies',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value= 2, Category = categories.uil0001}})

	-- Create army stat trigger for hidden objective tracking of soul ripper units built by player
	ScenarioFramework.CreateArmyStatTrigger (HiddenObjective, ArmyBrains[ARMY_PLAYER], 'HiddenObjective',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.ucx0112}})

	-- When player completes the Mass Conversion research upgrade, turn on a surgical OpAI that will target the upgraded
	-- power gens that are now mass convertors. (If we turned the opai earlier, it would still target the power gens, despite
	-- them being inocuous at that point).
	ScenarioFramework.CreateOnResearchTrigger( P1_EnableMassFabSurgical, ArmyBrains[ARMY_PLAYER], 'CBA_MASSCONVERSION', 'complete' )


	------------------
	-- VO Triggers
	------------------

	-- Create VO timer triggers for most of the banter
	ScenarioFramework.CreateTimerTrigger (P1_Ally_Banter_01, 150)
	ScenarioFramework.CreateTimerTrigger (P1_Ally_Banter_02, 300)
	ScenarioFramework.CreateTimerTrigger (P1_Ally_Banter_03, 500)
	ScenarioFramework.CreateTimerTrigger (P1_Ally_Banter_04, 75)


	-- VO update to player, when the enemy kills 'X' ally structures
	ScenarioFramework.CreateArmyStatTrigger(P1_AllyUpdate, ArmyBrains[ARMY_ALLYILL], 'P1_AllyUpdate',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.STRUCTURE}})

	-- Create unit damaged trigger for VO on the west illuminate CDR
	---NOTE: switching to a health ratio trigger -which fits the intentions correctly - bfricks 11/8/09
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_Burkett_Banter_03, ScenarioInfo.ENEM01_CDR_Burkett, 0.75, true, true)

	-- Create area trigger for VO on the west illuminate CDR
	ScenarioFramework.CreateAreaTrigger(P1_Burkett_Banter_01, 'P1_West_Base_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Create unit damaged trigger for VO on the middle illuminate CDR
	---NOTE: switching to a health ratio trigger -which fits the intentions correctly - bfricks 11/8/09
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_Larson_Banter_01, ScenarioInfo.ENEM01_CDR_Larson, 0.75, true, true)

	-- Create area trigger for VO on the east illuminate CDR
	ScenarioFramework.CreateAreaTrigger(P1_Larson_Banter_02, 'P1_East_Base_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Create unit damaged trigger for VO on the main illuminate CDR
	---NOTE: switching to a health ratio trigger -which fits the intentions correctly - bfricks 11/8/09
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_Walker_Banter_01, ScenarioInfo.ENEM01_CDR_Walker, 0.75, true, true)

	-- Create area trigger for VO on the main illuminate CDR
	ScenarioFramework.CreateAreaTrigger(P1_Walker_Banter_02, 'P1_Main_Base_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Create army stat trigger that will call VO when the player build 2 mass extractors
	ScenarioFramework.CreateArmyStatTrigger(P1_Burkett_Banter_02, ArmyBrains[ARMY_PLAYER], 'P1_Burkett_Banter_02',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ucb0701}})

end

function PlayerBaseCheck()
	LOG('----- PlayerBaseCheck')

	while not PlayerNotAtStartLocation do
		LOG('----- Check player structures')
		-- If the player structure count is greater in the ally area of the map switch the PlayerNotAtStartingLocation flag to true
		local PlayerStructuresAtStartLocation = ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE, 'PLAYER_AREA', ArmyBrains[ARMY_PLAYER])
		local PlayerStructuresAtAllyLocation = ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE, 'P1_Ally_Base_Area', ArmyBrains[ARMY_PLAYER])

		if PlayerStructuresAtAllyLocation > PlayerStructuresAtStartLocation then
			LOG('----- PlayerNotAtStartLocation = true')

			PlayerNotAtStartLocation = true

			ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI:		Disable()
			ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI:		Disable()

			-- Too many land units of some types
			ScenarioInfo.P1_ENEM01_PlayerExcessLand2_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponsePatrolLand', 'P1_ENEM01_PlayerExcessLand2_OpAI', {} )
			local P1_ENEM01_PlayerExcessLand2_OpAI_Data			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_Darkenoid_Attack_01', },}
			ScenarioInfo.P1_ENEM01_PlayerExcessLand2_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_PlayerExcessLand2_OpAI_Data )
			ScenarioInfo.P1_ENEM01_PlayerExcessLand2_OpAI:		SetChildCount(2)
			ScenarioInfo.P1_ENEM01_PlayerExcessLand2_OpAI:		SetDefaultVeterancy(5)

			-- Too many air units
			ScenarioInfo.P1_ENEM01_PlayerExcessAir2_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponsePatrolAir', 'P1_ENEM01_PlayerExcessAir2_OpAI', {} )
			local P1_ENEM01_PlayerExcessAir2_OpAI_Data			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_Darkenoid_Attack_01', },}
			ScenarioInfo.P1_ENEM01_PlayerExcessAir2_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_PlayerExcessAir2_OpAI_Data )
			ScenarioInfo.P1_ENEM01_PlayerExcessAir2_OpAI:		SetChildCount(3)
			ScenarioInfo.P1_ENEM01_PlayerExcessAir2_OpAI:		SetDefaultVeterancy(5)
		end
		WaitSeconds(119)
	end
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.C04_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()

	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.C04_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.C04_S1_obj10_NAME,	-- title
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
				ScenarioFramework.Dialogue(OpDialog.C04_RESEARCH_FOLLOWUP_SOULRIPPER_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 480)
end

function ResearchReminder1()
	if ScenarioInfo.S1_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.C04_RESEARCH_REMINDER_010)
	end
end

function HiddenObjective()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Sultan of Soul
	----------------------------------------------
	LOG('----- Assign Hidden Objective H1_obj10 - Sultan of Soul')
	local descText = OpStrings.C04_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C04_H1_obj10_MAKE_SOULRIPPER)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',									-- type
		'complete',										-- status
		OpStrings.C04_H1_obj10_NAME,					-- title
		descText,										-- description
		SimObjectives.GetActionIcon('build'),			-- Action
		{
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C04_H1_obj10_MAKE_SOULRIPPER, ARMY_PLAYER, 3.0)
end

function P1_ENEM01_DarkenoidAttack()
	if not DarkenoidAttackFlag then
		if ScenarioInfo.ENEM01_CDR_Burkett:IsDead() and ScenarioInfo.ENEM01_CDR_Larson:IsDead() then
			if ScenarioInfo.ENEM01_CDR_Walker and not ScenarioInfo.ENEM01_CDR_Walker:IsDead() then
				LOG('----- P1_ENEM01_DarkenoidAttack: Begin darkenoid construction and attacks')
				ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI: Enable()
				ScenarioFramework.Dialogue(OpDialog.C04_ALLY_UPDATE_020)
				DarkenoidAttackFlag = true
			end
		end
	end
end

function P1_ENEM01_DarkenoidAttackSecondary()
	if not DarkenoidAttackFlag then
		if ScenarioInfo.ENEM01_CDR_Walker and not ScenarioInfo.ENEM01_CDR_Walker:IsDead() then
			LOG('----- P1_ENEM01_DarkenoidAttackSecondary: Begin darkenoid construction and attacks')
			ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI: Enable()
			ScenarioFramework.Dialogue(OpDialog.C04_ALLY_UPDATE_020)
			DarkenoidAttackFlag = true
		end
	end
end

function P1_ENEM01_StopWestBaseRebuild()
	LOG('----- P1_ENEM01_StopWestBaseRebuild: West base factories killed.')
	-- Turn off rebuild to avoid penalizing the player
	ScenarioInfo.ArmyBase_ENEM01_West_Base:SetBuildAllStructures(false)
end

function P1_ENEM01_StopEastBaseRebuild()
	LOG('----- P1_ENEM01_StopWestBaseRebuild: East base factories killed.')
	-- Turn off rebuild to avoid penalizing the player
	ScenarioInfo.ArmyBase_ENEM01_East_Base:SetBuildAllStructures(false)
end

function P1_ENEM01_StopMainBaseRebuild()
	LOG('----- P1_ENEM01_StopMainBaseRebuild: Main base factories killed.')
	-- Turn off rebuild to avoid penalizing the player
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:SetBuildAllStructures(false)
end

function P1_Guard_Burkett()
	if not ScenarioInfo.Burkett_DamagedHeavily then
		LOG('----- P1_Guard_Burkett: Enemy CDR hurt order a guard of nearby units')
		ScenarioInfo.Burkett_DamagedHeavily = true

		local catsToCheck = categories.AIR + categories.LAND - categories.uil0002
		local baseUnits = ScenarioFramework.GetCatUnitsInArea(catsToCheck, 'P1_West_Base_Area', ArmyBrains[ARMY_ENEM01])

		if baseUnits then
			IssueClearCommands(baseUnits)
			IssueGuard(baseUnits, ScenarioInfo.ENEM01_CDR_Burkett)
		end
	end
end

function P1_Guard_Larson()
	if not ScenarioInfo.Larson_DamagedHeavily then
		LOG('----- P1_Guard_Larson: Enemy CDR hurt order a guard of nearby units')
		ScenarioInfo.Larson_DamagedHeavily = true

		local catsToCheck = categories.AIR + categories.LAND - categories.uil0002
		local baseUnits = ScenarioFramework.GetCatUnitsInArea(catsToCheck, 'P1_East_Base_Area', ArmyBrains[ARMY_ENEM01])

		if baseUnits then
			IssueClearCommands(baseUnits)
			IssueGuard(baseUnits, ScenarioInfo.ENEM01_CDR_Larson)
		end
	end
end

function P1_Guard_Walker()
	if not ScenarioInfo.Walker_DamagedHeavily then
		LOG('----- P1_Guard_Walker: Enemy CDR hurt order a guard of nearby units')
		ScenarioInfo.Walker_DamagedHeavily = true

		local catsToCheck = categories.AIR + categories.LAND - categories.uil0002
		local baseUnits = ScenarioFramework.GetCatUnitsInArea(catsToCheck, 'P1_Main_Base_Area', ArmyBrains[ARMY_ENEM01])

		if baseUnits then
			IssueClearCommands(baseUnits)
			IssueGuard(baseUnits, ScenarioInfo.ENEM01_CDR_Walker)
		end
	end
end

function P1_EnableMassFabSurgical()
	LOG('----- SURGICAL: Player completed mass fab upgrade research. Enabling Mass Fab surgical.')
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:Enable()
end

function P1_AddReservoirPlatoon(platoon)
	LOG('----- P1: Adding a unit to the reservoir platoon list via OpAI callback')
	table.insert(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable, platoon)
end

function P1_ReservoirAttack()
	LOG('----- P1_ReservoirAttack: triggered')

	-- Compact our list, to get rid of platoons that have been killed, but still exist as objects in our table.
	ScenarioInfo.ResTempTable = {}
	for k,v in ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable do
		if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
			table.insert (ScenarioInfo.ResTempTable, v)
		end
	end
	ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable = table.copy( ScenarioInfo.ResTempTable )


	ReservoirAttackCounter = ReservoirAttackCounter + 1
	local platoonCount = table.getn(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable)

	LOG('----- P1_ReservoirAttack: number: ', repr (ReservoirAttackCounter))
	LOG('----- P1_ReservoirAttack: platoon count: ', repr (platoonCount))

	-- Attack One
	if ReservoirAttackCounter == 1 then

		-- if there are more platoons than are needed for the final attack,
		-- then we can do an initial smaller attack. The current settings
		-- here assume that the pool is about 6 platoons (can vary if a platoon
		-- is built and added while we are in the middle of things), with each
		-- attack using 3 platoons from this pool, if possible.

		if platoonCount > 3 then
			LOG('----- P1_ReservoirAttack: performing first attack ')

			-- We have a maximum of 6 platoons potentially available, and our
			-- first attack should be 3 platoons, if possible.
			-- Our priority is the player getting attacked, preferably by two
			-- platoons. If there is still another available, it can go to Ally.
			-- The key thing is that we keep three platoons left over for the second,
			-- primary attack.

			-- Key issue: there will be a delay between when one of these platoons are formed,
			-- and when it actually shows up in our table. This is because we will not add the
			-- platoon unit it actually makes it to the middle Reservoir area. Otherwise,
			-- we might end up telling a platoon to use an attack route that does match where the
			-- new platoon is currently located (ie, just outside the factories that made it, away
			-- from the middle area.)

			local attackCounter = (platoonCount - 3)
			if attackCounter < 1 then attackCounter = 1 end

			LOG('----- P1_ReservoirAttack: First Attack: platoons available for this attack: ', repr (attackCounter))

			for i = 1, attackCounter do

				if ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1] and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]) then

					-- first platoon to the player, and then remove it from our table.
					if i == 1 then
						LOG('----- P1_ReservoirAttack: First Attack: one platoon sent to player ')

						-- TODO: replace this route with Space Temple use when able.
						IssueClearCommands(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits())
						IssueMove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Land_AttackPlayer_01_01' ) )
						IssueTransportLoad( ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioInfo.P1_ENEM01_Temple01 )
						if PlayerNotAtStartLocation == false then
							ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackPlayer_02')
						elseif PlayerNotAtStartLocation == true then
							ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackUEF01_01')
						end
						table.remove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable, 1)

					-- second platoon to the player, if the platoon exists, and remove.
					elseif i == 2 then
						LOG('----- P1_ReservoirAttack: First Attack: second platoon sent to player ')

						------TODO: replace this route with Space Temple use when able.
						IssueClearCommands(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits())
						IssueMove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Land_AttackPlayer_01_01' ) )
						IssueTransportLoad( ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioInfo.P1_ENEM01_Temple01 )
						if PlayerNotAtStartLocation == false then
							ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackPlayer_Alt')
						elseif PlayerNotAtStartLocation == true then
							ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackUEF01_01')
						end
						table.remove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable, 1)

					-- third platoon to our ally, if the platoon exists, and remove.
					elseif i == 3 then
						LOG('----- P1_ReservoirAttack: First Attack: one platoon sent to ally ')

						------TODO: replace this route with Space Temple use when able.
						IssueClearCommands(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits())
						IssueMove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Land_AttackPlayer_01_01' ) )
						IssueTransportLoad( ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioInfo.P1_ENEM01_Temple02 )
						ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackAlly_02')
						table.remove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable, 1)
					else
						WARN('WARNING: C04: attackCounter unsupported attackCounter value:[', attackCounter, ']')
					end
				end
			end
			ScenarioFramework.Dialogue(OpDialog.C04_MIDDLE_ATTACK_LIGHT_010)

		-- Otherwise, if we have 3 or less platoons left over in the reservoir area, then
		-- we will just throw them all at the player, and call this a final attack.
		else
			LOG('----- P1_ReservoirAttack: First Attack: Insufficient platoons! Using existing platoons to do a fake final attack. ')

			-- all remaining platoons to the player, for a final attack of sorts.
			for k, v in ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable do
				if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
					------TODO: replace this route with Space Temple use when able.
					IssueClearCommands(v:GetPlatoonUnits())
					IssueMove(v:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Land_AttackPlayer_01_01' ) )
					IssueTransportLoad( v:GetPlatoonUnits(), ScenarioInfo.P1_ENEM01_Temple01 )
					if PlayerNotAtStartLocation == false then
						ScenarioFramework.PlatoonPatrolChain(v, 'P1_ENEM01_Land_AttackPlayer_02')
					elseif PlayerNotAtStartLocation == true then
						ScenarioFramework.PlatoonPatrolChain(v, 'P1_ENEM01_Land_AttackUEF01_01')
					end
				end
			end
			-- Clear out the table, in case anything else tries to use the members.
			ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable = {}

			-- flag that we are going to call this the final attack, since we dont have enough for a second attack now.
			ScenarioInfo.P1_FinalBlockAttackCanceled = true

			-- 2 or more platoons is sufficient to make an event out of all this, and play our final attack VO for.
			if platoonCount >= 2 then
				ScenarioFramework.Dialogue(OpDialog.C04_MIDDLE_ATTACK_HEAVY_010)

			-- but if we only have a measly one platoon available, we are just going to use some humdrum warning that isnt
			-- as sensational.
			elseif platoonCount == 1 then
				ScenarioFramework.Dialogue(OpDialog.C04_MIDDLE_ATTACK_WEAK_010)
			end

		end

	-- Attack Two: check that our first attack didnt use up all available units, resulting in the final attack being cancelled.
	elseif ReservoirAttackCounter == 2 and not ScenarioInfo.P1_FinalBlockAttackCanceled then
		LOG('----- P1_ReservoirAttack: performing Second Attack. ')

		-- safety check
		if platoonCount > 0 then

			local attackCounter = platoonCount
			if attackCounter < 1 then attackCounter = 1 end

			LOG('----- P1_ReservoirAttack: Second Attack: platoons available for this attack: ', repr (attackCounter))

			for i = 1, attackCounter do

				if ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1] and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]) then

					-- first platoon to the player, and then remove it from our table.
					if i <= 3 then
						LOG('----- P1_ReservoirAttack: Second Attack: platoon sent to player, ', repr (i))

						------TODO: replace this route with Space Temple use when able.
						IssueClearCommands(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits())
						IssueMove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Land_AttackPlayer_01_01' ) )
						IssueTransportLoad( ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioInfo.P1_ENEM01_Temple01 )
						if PlayerNotAtStartLocation == false then
							ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackPlayer_Alt')
						elseif PlayerNotAtStartLocation == true then
							ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackUEF01_01')
						end
						table.remove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable, 1)

					-- Final platoon to ally. Should only be one left, but just in case, drain out a second. If we somehow
					-- end up with more platoons that we expected in the middle, we don't want to just dump the balance at
					-- the ally, as ally defense is a primary objective.
					elseif i > 3 or i <=5 then
						LOG('----- P1_ReservoirAttack: Second Attack: extra platoon sent to ally, ', repr (i))

						------TODO: replace this route with Space Temple use when able.
						IssueClearCommands(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits())
						IssueMove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Land_AttackPlayer_01_01' ) )
						IssueTransportLoad( ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1]:GetPlatoonUnits(), ScenarioInfo.P1_ENEM01_Temple02 )
						ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable[1], 'P1_ENEM01_Land_AttackAlly_02')
						table.remove(ScenarioInfo.P1_ENEM01_ReservoirPlatoonTable, 1)
					end
				end
			end

			-- 2 or more platoons is sufficient to make an event out of all this, and play our final attack VO for.
			if platoonCount >= 2 then
				LOG('----- P1_ReservoirAttack: Second Attack: enough platoons were available for proper VO.')

				ScenarioFramework.Dialogue(OpDialog.C04_MIDDLE_ATTACK_HEAVY_010)

			-- but if we only have a measly one platoon available, we are just going to use some humdrum warning that isnt
			-- as sensational.
			elseif platoonCount == 1 then
				LOG('----- P1_ReservoirAttack: Second Attack: too few platoons, playing weak VO.')

				ScenarioFramework.Dialogue(OpDialog.C04_MIDDLE_ATTACK_WEAK_010)
			end
		end
	end
end

---------------------------------------------------------------------
-- BASE AND OPAI SETUP:
---------------------------------------------------------------------

function P1_Enemy_Teleport_Route_Generator()
	LOG('----- P1_Enemy_Teleport_Route_Generator')
	local rndLoc = Random (1, 2)

	if PlayerNotAtStartLocation == false then
		if rndLoc == 1 then
			P2_Enemy_Attack_01()
		elseif rndLoc == 2 then
			P2_Enemy_Attack_02()
		end
	elseif PlayerNotAtStartLocation == true then
		P2_Enemy_Attack_03()
	end
end

function P2_Enemy_Attack_01()
	LOG('----- P2_Enemy_Attack_01')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ENEM01_Land_AttackPlayer_01' },										-- to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_ENEM01_Temple_01', TeleporterArmyIndex = ARMY_ENEM01 },	-- move to gate
			{ BehaviorName = 'Patrol', Chain = 'P1_ENEM01_Land_AttackPlayer_02' }, 												-- attack player then loop around to allies
		},
	}
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_Attack_02()
	LOG('----- P2_Enemy_Attack_02')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ENEM01_Land_AttackPlayer_01' },										-- to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_ENEM01_Temple_01', TeleporterArmyIndex = ARMY_ENEM01 },	-- move to gate
			{ BehaviorName = 'Patrol', Chain = 'P1_ENEM01_Land_AttackPlayer_Alt' }, 											-- attack player then loop around to allies
		},
	}
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_Attack_03()
	LOG('----- P2_Enemy_Attack_03')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ENEM01_Land_AttackPlayer_01' },										-- to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_ENEM01_Temple_01', TeleporterArmyIndex = ARMY_ENEM01 },	-- move to gate
			{ BehaviorName = 'Patrol', Chain = 'P1_ENEM01_Land_AttackUEF01_01' },												-- attack player at ally location
		},
	}
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P1_AISetup_ALLYUEF()
	LOG('----- P1: Set up UEF Ally Base')

	------------------
	-- Base Setup
	------------------

	-- Initial base
	local levelTable_ALLYUEF_Main_Base 	= { P1_ALLYUEF_Main_Base_100 = 100,
											P1_ALLYUEF_Main_Base_90 = 90,
											P1_ALLYUEF_Main_Base_80 = 80, }
	ScenarioInfo.ArmyBase_ALLYUEF_Main_Base = ArmyBrains[ARMY_ALLYUEF].CampaignAISystem:AddBaseManager('ArmyBase_ALLYUEF_Main_Base',
		 'P1_ALLYUEF_Main_Base_Marker', 50, levelTable_ALLYUEF_Main_Base)
	ScenarioInfo.ArmyBase_ALLYUEF_Main_Base:StartNonZeroBase(3)

	-- in the case of our ally, we want infinite rebuild on.
	ScenarioInfo.ArmyBase_ALLYUEF_Main_Base:SetBaseInfiniteRebuild()

	-- a portion of base to rebuild
	ScenarioInfo.ArmyBase_ALLYUEF_Main_Base:AddBuildGroup('P1_ALLYUEF_Additional_Base', 70)

	-- get all defense structure units from the the just created base and give them a veterancy buff
	local uefDefense = ArmyBrains[ARMY_ALLYUEF]:GetListOfUnits(categories.uub0101 + categories.uub0102,false)
	for k, unit in uefDefense do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 3)
	end

	------------------
	-- OpAI's
	------------------

	-- basic land attack through the space temple beacon
	ScenarioInfo.ALLYUEF_Land_Attack01_OpAI				= ScenarioInfo.ArmyBase_ALLYUEF_Main_Base:AddOpAI('LandAttackUEF', 'ALLYUEF_Land_Attack01_OpAI', {} )
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ALLYUEF_Land_Attack01_01' },										  -- to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_Temple02_Beacon', TeleporterArmyIndex = ARMY_ENEM01 }, -- through temple to middle
			{ BehaviorName = 'Patrol', Chain = 'P1_ALLYUEF_Land_Attack01_02' }, 											  -- patrol through enemy main base area
		},
	}
	ScenarioInfo.ALLYUEF_Land_Attack01_OpAI:SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )

	ScenarioInfo.ALLYUEF_Land_Attack01_OpAI:			SetAttackDelay(10)
	ScenarioInfo.ALLYUEF_Land_Attack01_OpAI:			SetMaxActivePlatoons(4)

	-- basic fighter defense
	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI				= ScenarioInfo.ArmyBase_ALLYUEF_Main_Base:AddOpAI('AirAttackUEF', 'ALLYUEF_Air_Defense01_OpAI', {} )
	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI_Data		= { PatrolChain = 'P1_ALLYUEF_Air_Defense_01',}
	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI:			EnableChildTypes( {'UEFFighters'} )
	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ALLYUEF_Air_Defense01_OpAI_Data )

	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI:			SetAttackDelay(2)
	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI:			SetChildCount(2)
	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI:			SetMaxActivePlatoons(1)

	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLYUEF', 'P1_ALLYUEF_Main_InitAir_Def_01', 'AttackFormation')
	ScenarioInfo.ALLYUEF_Air_Defense01_OpAI:			AddActivePlatoon(platoon, true)

end

function P1_AISetup_ALLYILL()
	LOG('----- P1: Set up Illuminate Ally Base')

	------------------
	-- Base Setup
	------------------

	-- Initial base
	local levelTable_ALLYILL_Main_Base 	= { P1_ALLYILL_Main_Base_100 = 100,
											P1_ALLYILL_Main_Base_90 = 90,
											P1_ALLYILL_Main_Base_80 = 80, }
	ScenarioInfo.ArmyBase_ALLYILL_Main_Base = ArmyBrains[ARMY_ALLYILL].CampaignAISystem:AddBaseManager('ArmyBase_ALLYILL_Main_Base',
		 'P1_ALLYILL_Main_Base_Marker', 50, levelTable_ALLYILL_Main_Base)
	ScenarioInfo.ArmyBase_ALLYILL_Main_Base:StartNonZeroBase(3)

	--in the case of our ally, we want infinite rebuild on.
	ScenarioInfo.ArmyBase_ALLYILL_Main_Base:SetBaseInfiniteRebuild()

	-- a portion of base to rebuild
	ScenarioInfo.ArmyBase_ALLYILL_Main_Base:AddBuildGroup('P1_ALLYILL_Additional_Base', 70)

	-- get all defense structure units from the the just created base and give them a veterancy buff
	local illDefense = ArmyBrains[ARMY_ALLYILL]:GetListOfUnits(categories.uib0101 + categories.uib0102,false)
	for k, unit in illDefense do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 3)
	end

	------------------
	-- OpAI's
	------------------

	-- basic land attack
	ScenarioInfo.ALLYILL_Land_Attack01_OpAI				= ScenarioInfo.ArmyBase_ALLYILL_Main_Base:AddOpAI('LandAttackIlluminate', 'ALLYILL_Land_Attack01_OpAI', {} )
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ALLYILL_Land_Attack01_01' },										  -- to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_Temple02_Beacon', TeleporterArmyIndex = ARMY_ENEM01 }, -- through temple to middle
			{ BehaviorName = 'Patrol', Chain = 'P1_ALLYILL_Land_Attack01_02' }, 											  -- patrol through enemy main base area
		},
	}
	ScenarioInfo.ALLYILL_Land_Attack01_OpAI:SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )

	ScenarioInfo.ALLYILL_Land_Attack01_OpAI:			SetAttackDelay(10)
	ScenarioInfo.ALLYILL_Land_Attack01_OpAI:			SetMaxActivePlatoons(4)


end

function P1_AISetup_ENEM01_West()
	LOG('----- P1: Set up Enemy west Base')

	------------------
	-- Base Setup
	------------------

	-- Initial base
	local levelTable_ENEM01_West_Base 	= { P1_ENEM01_West_Base_100 = 100,
											P1_ENEM01_West_Base_90 = 90,
											P1_ENEM01_West_Base_80 = 80, }
	ScenarioInfo.ArmyBase_ENEM01_West_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_West_Base',
		 'P1_ENEM01_West_Base_Marker', 50, levelTable_ENEM01_West_Base)
	ScenarioInfo.ArmyBase_ENEM01_West_Base:StartNonZeroBase(2)

	-- We want the defenses to be exceedingly strong from the outside, with gates the only
	-- real way in. So, strong rebuild.
	ScenarioInfo.ArmyBase_ENEM01_West_Base:SetBaseInfiniteRebuild()

	-- a portion of base to rebuild
	ScenarioInfo.ArmyBase_ENEM01_West_Base:AddBuildGroup('P1_ENEM01_West_Additional_Base', 70)

	------------------
	--OpAI's
	------------------

	-- basic land attack against UEF Ally from the north
	ScenarioInfo.ENEM01_East_LandAttackUEF01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:GenerateOpAIFromPlatoonTemplate( LandAttackUEFNorth, 'ENEM01_East_LandAttackUEF01_OpAI_Data', {} )
	local ENEM01_East_LandAttackUEF01_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'P1_ENEM01_Land_AttackUEF01_01'},}
	ScenarioInfo.ENEM01_East_LandAttackUEF01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ENEM01_East_LandAttackUEF01_OpAI_Data )

	ScenarioInfo.ENEM01_East_LandAttackUEF01_OpAI:			SetChildCount(3)
	ScenarioInfo.ENEM01_East_LandAttackUEF01_OpAI:			SetAttackDelay(0)
	ScenarioInfo.ENEM01_East_LandAttackUEF01_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.ENEM01_East_LandAttackUEF01_OpAI:			SetDefaultVeterancy(5)

	-- basic land attack against Illuminate Ally from the south
	ScenarioInfo.ENEM01_East_LandAttackUEF02_OpAI			= ScenarioInfo.ArmyBase_ENEM01_West_Base:GenerateOpAIFromPlatoonTemplate( LandAttackILLSouth, 'ENEM01_East_LandAttackUEF02_OpAI_Data', {} )
	local ENEM01_East_LandAttackUEF02_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'P1_ENEM01_Land_AttackUEF02_01'},}
	ScenarioInfo.ENEM01_East_LandAttackUEF02_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ENEM01_East_LandAttackUEF02_OpAI_Data )

	ScenarioInfo.ENEM01_East_LandAttackUEF02_OpAI:			SetChildCount(3)
	ScenarioInfo.ENEM01_East_LandAttackUEF02_OpAI:			SetAttackDelay(0)
	ScenarioInfo.ENEM01_East_LandAttackUEF02_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.ENEM01_East_LandAttackUEF02_OpAI:			SetDefaultVeterancy(5)
end

function P1_AISetup_ENEM01_East()
	LOG('----- P1: Set up Enemy east Base')

	------------------
	-- Base Setup
	------------------

	-- Initial base
	local levelTable_ENEM01_East_Base 	= { P1_ENEM01_East_Base_100 = 100,
											P1_ENEM01_East_Base_90 = 90,
											P1_ENEM01_East_Base_80 = 80, }
	ScenarioInfo.ArmyBase_ENEM01_East_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_East_Base',
		 'P1_ENEM01_East_Base_Marker', 50, levelTable_ENEM01_East_Base)
	ScenarioInfo.ArmyBase_ENEM01_East_Base:StartNonZeroBase(3)

	-- We want the defenses to be exceedingly strong from the outside, with gates the only
	-- real way in. So, strong rebuild.
	ScenarioInfo.ArmyBase_ENEM01_East_Base:SetBaseInfiniteRebuild()

	-- a portion of base to rebuild
	ScenarioInfo.ArmyBase_ENEM01_East_Base:AddBuildGroup('P1_ENEM01_East_Additional_Base', 70)


end

function P1_AISetup_ENEM01_Main()
	LOG('----- P1: Set up Enemy main Base')

	------------------
	-- Base Setup
	------------------

	-- Initial base
	local levelTable_ENEM01_Main_Base 	= { P1_ENEM01_Main_Base_100 = 100,
											P1_ENEM01_Main_Base_90 = 90,
											P1_ENEM01_Main_Base_80 = 80,
											P1_ENEM01_Main_Base_70 = 70, }
	ScenarioInfo.ArmyBase_ENEM01_Main_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Main_Base',
		 'P1_ENEM01_Main_Base_Marker', 50, levelTable_ENEM01_Main_Base)
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:StartNonZeroBase(4)

	------------------
	-- OpAIs
	------------------

	-- basic land attack against player
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_Main_Land_AtPlayer01_OpAI', {} )

	-- FormCallBack for the teleport route generator
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI. 		FormCallback:Add(P1_Enemy_Teleport_Route_Generator)

	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetChildCount(4)
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetAttackDelay(0)
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetTargetArmyIndex(ARMY_PLAYER)
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetDefaultVeterancy(5)

	-- basic land attack against ally
	ScenarioInfo.ENEM01_Main_Land_AtAlly01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('LandAttackIlluminate', 'ENEM01_Main_Land_AtAlly01_OpAI', {} )
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ENEM01_Land_AttackAlly_01' },									   -- move to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_ENEM01_Temple_02', TeleporterArmyIndex = ARMY_ENEM01 }, -- move to gate
			{ BehaviorName = 'Patrol', Chain = 'P1_ENEM01_Land_AttackAlly_02' },  											   -- attack allies then loop around to player
		},
	}
	ScenarioInfo.ENEM01_Main_Land_AtAlly01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
	ScenarioInfo.ENEM01_Main_Land_AtAlly01_OpAI:		SetChildCount(2)
	ScenarioInfo.ENEM01_Main_Land_AtAlly01_OpAI:		SetAttackDelay(5)
	ScenarioInfo.ENEM01_Main_Land_AtAlly01_OpAI:		SetTargetArmyIndex(ARMY_ALLYUEF)
	ScenarioInfo.ENEM01_Main_Land_AtAlly01_OpAI:		SetMaxActivePlatoons(5)
	ScenarioInfo.ENEM01_Main_Land_AtAlly01_OpAI:		SetDefaultVeterancy(2)

	-- opai to keep the Reservoir of strong platoons topped off
	ScenarioInfo.ENEM01_Main_Land_Reservoir_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('SingleUrchinowAttack', 'ENEM01_Main_Land_Reservoir_OpAI', {} )
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ENEM01_Land_AttackAlly_01' },									 	-- move to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_ENEM01_Temple_02', TeleporterArmyIndex = ARMY_ENEM01 },	-- to gate
			{ BehaviorName = 'Patrol', Chain = 'P1_ENEM01_Land_AttackAlly_02' },  												-- attack allies then loop around to player
		},
	}
	ScenarioInfo.ENEM01_Main_Land_Reservoir_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
	ScenarioInfo.ENEM01_Main_Land_Reservoir_OpAI.		FormCallback:Add( P1_AddReservoirPlatoon )
	ScenarioInfo.ENEM01_Main_Land_Reservoir_OpAI:		SetAttackDelay(0)
	ScenarioInfo.ENEM01_Main_Land_Reservoir_OpAI:		SetMaxActivePlatoons(6) -- if this number is increased, updated P1_ReservoirAttack.
	ScenarioInfo.ENEM01_Main_Land_Reservoir_OpAI:		Disable()

	-- Air defense patrol for Middle, with initial platoon
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_Main_EastDef_Air_OpAI', {} )
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI_Data		= {PatrolChain = 'P1_ENEM01_East_AirDef_Patrol_01',}
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI_Data )
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI:			SetChildCount(3)
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI:			SetAttackDelay(0)
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI:			EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI:			SetDefaultVeterancy(4)

	local platoonAir = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_East_InitAir_Def_01', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(platoonAir, 4)
	ScenarioInfo.ENEM01_Main_EastDef_Air_OpAI:			AddActivePlatoon(platoonAir, true)

	-- Air defense patrol for Main, with initial platoon
	ScenarioInfo.ENEM01_Main_Def_Air_OpAI				= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirAttackIlluminate', 'ENEM01_Main_Def_Air_OpAI', {} )
	ScenarioInfo.ENEM01_Main_Def_Air_OpAI_Data			= {PatrolChain = 'P1_ENEM01_Main_AirDef_Patrol_01',}
	ScenarioInfo.ENEM01_Main_Def_Air_OpAI:				SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.ENEM01_Main_Def_Air_OpAI_Data )
	ScenarioInfo.ENEM01_Main_Def_Air_OpAI:				SetAttackDelay(0)
	ScenarioInfo.ENEM01_Main_Def_Air_OpAI:				EnableChildTypes( {'IlluminateFighterBombers'} )
	ScenarioInfo.ENEM01_Main_Def_Air_OpAI:				SetMaxActivePlatoons(3)
	ScenarioInfo.ENEM01_Main_Def_Air_OpAI:				SetDefaultVeterancy(5)

	-- Set up initial patrol platoons that will be handed to the OpAI:
	-- Two air defense platoons over base
	for i = 1, 2 do
		local platoonAirDefense = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Main_InitAir_Defense_01', 'AttackFormation')
		ScenarioFramework.SetPlatoonVeterancyLevel(platoonAirDefense, 3)
		ScenarioInfo.ENEM01_Main_Def_Air_OpAI:			AddActivePlatoon(platoonAirDefense, true)
	end

	-- West Airnomo defense patrol for Main
	ScenarioInfo.ENEM01_Main_Def_Airnomo01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('SingleAirnomoAttack', 'ENEM01_Main_Def_Airnomo01_OpAI', {} )
	ScenarioInfo.ENEM01_Main_Def_Airnomo01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_AirnomoDef_Patrol_01',},}
	ScenarioInfo.ENEM01_Main_Def_Airnomo01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_Main_Def_Airnomo01_OpAI_Data )
	ScenarioInfo.ENEM01_Main_Def_Airnomo01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_Main_Def_Airnomo01_OpAI:		SetDefaultVeterancy(5)

	local platoonAirnomoWest = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Main_InitAirnomo_Defense_01', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(platoonAirnomoWest, 2)
	ScenarioInfo.ENEM01_Main_Def_Airnomo01_OpAI:		AddActivePlatoon(platoonAirnomoWest, true)

	-- East Airnomo defense patrol for Main
	ScenarioInfo.ENEM01_Main_Def_Airnomo02_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('SingleAirnomoAttack', 'ENEM01_Main_Def_Airnomo02_OpAI', {} )
	ScenarioInfo.ENEM01_Main_Def_Airnomo02_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_AirnomoDef_Patrol_02',},}
	ScenarioInfo.ENEM01_Main_Def_Airnomo02_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_Main_Def_Airnomo02_OpAI_Data )
	ScenarioInfo.ENEM01_Main_Def_Airnomo02_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_Main_Def_Airnomo02_OpAI:		SetDefaultVeterancy(5)

	local platoonAirnomoEast = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Main_InitAirnomo_Defense_02', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(platoonAirnomoEast, 2)
	ScenarioInfo.ENEM01_Main_Def_Airnomo02_OpAI:		AddActivePlatoon(platoonAirnomoEast, true)

	-- Main base Darknoid attack on allies
	ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('SingleDarkenoidAttack', 'ENEM01_Main_Darkenoid_AtAlly_OpAI', {} )
	ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_Darkenoid_Attack_01',},}
	ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI_Data )
	ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI:			SetDefaultVeterancy(4)
	ScenarioInfo.ENEM01_Main_Darkenoid_AtAlly_OpAI: 		Disable()

	ScenarioInfo.ENEM01_Main_AssaultBlock_AtAlly_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('SingleUrchinowAttack', 'ENEM01_Main_AssaultBlock_AtAlly_OpAI', {} )
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P1_ENEM01_Land_AttackAlly_01' },										-- move to temple
			{ BehaviorName = 'UseTeleporter', TeleporterUnitName = 'P1_ENEM01_Temple_02', TeleporterArmyIndex = ARMY_ENEM01 },	-- to gate
			{ BehaviorName = 'Patrol', Chain = 'P1_ENEM01_Land_AttackAlly_02' },  												-- attack allies then loop around to player
		},
	}
	ScenarioInfo.ENEM01_Main_AssaultBlock_AtAlly_OpAI:SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )

	------------------
	-- Surgical OpAIs
	------------------

	-- Surgical Response OpAI's if the player builds over-powerful units, or builds too many of certain units.
	-- TODO:: the anti-exp opais in the group below will need a new platoon thread for direct targetting of units swapped in.
	--  for now, Im setting up a formcallback to replicate that.


	-- Too many land units of some types
	ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponsePatrolLand', 'P1_ENEM01_PlayerExcessLand_OpAI', {} )
	local P1_ENEM01_PlayerExcessLand_OpAI_Data			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_ResponseAttackChain_01', },}
	ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_PlayerExcessLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI:		SetDefaultVeterancy(5)

	-- Too many air units
	ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponsePatrolAir', 'P1_ENEM01_PlayerExcessAir_OpAI', {} )
	local P1_ENEM01_PlayerExcessAir_OpAI_Data			= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_Main_ResponseAttackChain_01', },}
	ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_PlayerExcessAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI:		SetChildCount(3)
	ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI:		SetDefaultVeterancy(5)

	-- Player builds powerful individual land units
	ScenarioInfo.P1_ENEM01_PlayerPowerfulLand_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponseTargetLand', 'P1_ENEM01_PlayerPowerfulLand_OpAI', {} )
	local P1_ENEM01_PlayerPowerfulLand_OpAI_Data		= {
    													    PatrolChain = 'P1_ENEM01_Land_AttackUEF05_01',
    													    CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Main_Base_Marker' ),
    													    CategoryList = {
    													        (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    													        categories.uub0105,	-- artillery
    													        categories.ucb0105,	-- artillery
    													        categories.NUKE,
    													    },
    													}
	ScenarioInfo.P1_ENEM01_PlayerPowerfulLand_OpAI:		SetPlatoonThread( 'CategoryHunter', P1_ENEM01_PlayerPowerfulLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerPowerfulLand_OpAI:		SetChildCount(4)
	ScenarioInfo.P1_ENEM01_PlayerPowerfulLand_OpAI:		SetDefaultVeterancy(5)

	-- Player builds air experimentals
	ScenarioInfo.P1_ENEM01_PlayerPowerfulAir_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponseTargetAir', 'P1_ENEM01_PlayerPowerfulAir_OpAI', {} )
	local P1_ENEM01_PlayerPowerfulAir_OpAI_Data			= {
    														PatrolChain = 'P1_ENEM01_Land_AttackUEF05_01',
    														CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Main_Base_Marker' ),
    														CategoryList = {
    														    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    														},
    													}
	ScenarioInfo.P1_ENEM01_PlayerPowerfulAir_OpAI:		SetPlatoonThread( 'CategoryHunter', P1_ENEM01_PlayerPowerfulAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerPowerfulAir_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_PlayerPowerfulAir_OpAI:		SetDefaultVeterancy(5)

	-- Player builds mass fabs
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI			= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirResponseTargetCybPower', 'P1_ENEM01_PlayerMassFab_OpAI', {} )
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI_Data		= {
    												    	PatrolChain = 'P1_ENEM01_Land_AttackUEF05_01',
    												    	Announce = true,
    												    	CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Main_Base_Marker' ),
    												    	CategoryList = {
    												    		categories.ucb0702,	-- power generator (upgrades to mass fab)
    														},
    													}
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetPlatoonThread( 'CategoryHunter', ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetMaxActivePlatoons(1) -- more than 1 will blow out other attacks, as player will always have power.
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetAttackDelay(60) -- player will always have power gens, so we need to slow this opai down.
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		Disable()
end


---------------------------------------------------------------------
-- DIALOGUE:
---------------------------------------------------------------------

function P1_Ally_Banter_01()
	-- Play ally CDR VO banter
	ScenarioFramework.Dialogue(OpDialog.C04_ALLY_BANTER_010)
end

function P1_Ally_Banter_02()
	-- Play ally CDR VO banter
	ScenarioFramework.Dialogue(OpDialog.C04_ALLY_BANTER_020)
end

function P1_Ally_Banter_03()
	-- Play ally CDR VO banter
	ScenarioFramework.Dialogue(OpDialog.C04_ALLY_BANTER_030)
end

function P1_Ally_Banter_04()
	-- Play ally CDR VO banter
	ScenarioFramework.Dialogue(OpDialog.C04_ALLY_BANTER_040)
end

function P1_Burkett_Banter_01()
	-- Play Burkett's CDR VO banter
	if ScenarioInfo.ENEM01_CDR_Burkett and not ScenarioInfo.ENEM01_CDR_Burkett:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.C04_ILL01_BANTER_010)
	end
end

function P1_Burkett_Banter_02()
	-- Play Burkett's CDR VO banter
	if ScenarioInfo.ENEM01_CDR_Burkett and not ScenarioInfo.ENEM01_CDR_Burkett:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.C04_ILL01_BANTER_020)
	end
end

function P1_Burkett_Banter_03()
	-- Play Burkett's CDR VO banter
	if ScenarioInfo.ENEM01_CDR_Burkett and not ScenarioInfo.ENEM01_CDR_Burkett:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.C04_ILL01_BANTER_030)
	end
end

function P1_Larson_Banter_01()
	-- Play Larson's CDR VO banter
	if ScenarioInfo.ENEM01_CDR_Larson and not ScenarioInfo.ENEM01_CDR_Larson:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.C04_ILL02_BANTER_010)
	end
end

function P1_Larson_Banter_02()
	-- Play Larson's CDR VO banter
	if ScenarioInfo.ENEM01_CDR_Larson and not ScenarioInfo.ENEM01_CDR_Larson:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.C04_ILL02_BANTER_020)
	end
end

function P1_Walker_Banter_01()
	-- Play Walker's CDR VO banter
	if ScenarioInfo.ENEM01_CDR_Walker and not ScenarioInfo.ENEM01_CDR_Walker:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.C04_ILL03_BANTER_020)
	end
end

function P1_Walker_Banter_02()
	-- Play Walker's illuminate CDR VO banter
	if ScenarioInfo.ENEM01_CDR_Walker and not ScenarioInfo.ENEM01_CDR_Walker:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.C04_ILL03_BANTER_010)
	end
end

function P1_AllyUpdate()
	LOG('----- P1: VO update for player, based on ally killing n units')
	ScenarioFramework.Dialogue(OpDialog.C04_ALLY_UPDATE_010)
end

---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------
function ENEM01_CDR_Burkett_DeathDamage(CDRUnit)
	-- Play Burkett's Death VO
	ScenarioFramework.Dialogue(OpDialog.C04_BURKETT_DEATH_010)

	-- disable the west base
	P1_ENEM01_StopWestBaseRebuild()
	ScenarioInfo.ArmyBase_ENEM01_West_Base:BaseActive(false)

	-- Increase platoon size sent from main base
	if ScenarioInfo.ENEM01_CDR_Walker and not ScenarioInfo.ENEM01_CDR_Walker:IsDead() then
		ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetMaxActivePlatoons(4)
	end

	-- handle survivors
	local survivors = ScenarioFramework.GetCatUnitsInArea(categories.LAND * categories.MOBILE, 'P1_West_Base_Area', ArmyBrains[ARMY_ENEM01])
	IssueClearCommands(survivors)
	IssueAttack(survivors, ScenarioInfo.ALLYUEF_CDR)
	IssueAttack(survivors, ScenarioInfo.ALLYILL_CDR)

	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_ALLYUEF],
			ArmyBrains[ARMY_ALLYILL],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 50.0, true, 5000, 90001, brainList)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

function ENEM01_CDR_Larson_DeathDamage(CDRUnit)
	-- Play Larson's Death VO
	ScenarioFramework.Dialogue(OpDialog.C04_LARSON_DEATH_010)

	-- disable the east base
	P1_ENEM01_StopEastBaseRebuild()
	ScenarioInfo.ArmyBase_ENEM01_East_Base:BaseActive(false)

	-- Increase platoon size sent from main base
	if ScenarioInfo.ENEM01_CDR_Walker and not ScenarioInfo.ENEM01_CDR_Walker:IsDead() then
		ScenarioInfo.ENEM01_Main_Land_AtPlayer01_OpAI:		SetMaxActivePlatoons(5)
	end

	-- handle survivors
	local survivors = ScenarioFramework.GetCatUnitsInArea(categories.AIR - categories.uix0112, 'P1_East_Base_Area', ArmyBrains[ARMY_ENEM01])
	IssueClearCommands(survivors)
	IssueAttack(survivors, ScenarioInfo.ALLYUEF_CDR)
	IssueAttack(survivors, ScenarioInfo.ALLYILL_CDR)

	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_ALLYUEF],
			ArmyBrains[ARMY_ALLYILL],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 50.0, true, 5000, 90001, brainList)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

function ENEM01_CDR_Walker_DeathDamage(CDRUnit)
	-- Play Walker's Death VO
	ScenarioFramework.Dialogue(OpDialog.C04_WALKER_DEATH_010)

	-- disable the main base
	P1_ENEM01_StopMainBaseRebuild()
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:BaseActive(false)

	-- Disable ally attacks
	ScenarioInfo.ALLYILL_Land_Attack01_OpAI:Disable()
	ScenarioInfo.ALLYUEF_Land_Attack01_OpAI:Disable()

	-- handle survivors
	local survivors = ScenarioFramework.GetCatUnitsInArea(categories.LAND * categories.MOBILE, 'P1_Main_Base_Area', ArmyBrains[ARMY_ENEM01])
	IssueClearCommands(survivors)
	IssueAttack(survivors, ScenarioInfo.ALLYUEF_CDR)
	IssueAttack(survivors, ScenarioInfo.ALLYILL_CDR)

	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
			ArmyBrains[ARMY_ALLYUEF],
			ArmyBrains[ARMY_ALLYILL],
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
function Launch_ENEM01_CDR01_DeathNIS(unit)
	nNumCDRsDestroyed = nNumCDRsDestroyed + 1
	-- if all 3 enemy CDR's are dead complete defend allies objective
	if nNumCDRsDestroyed == 3 then
		LOG('----- Launch_ENEM01_CDR01_DeathNIS(unit): Primary Objective M2_obj10 - Defend Allies Complete')
		ScenarioInfo.M2_obj10:ManualResult(true)
	end
	ForkThread(
		function()
			OpNIS.NIS_ENEM01_CDR01_DEATH(unit, nNumCDRsDestroyed)
			if nNumCDRsDestroyed == 2 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C04_ZZ_EXTRA_KILL_CDR2, ARMY_PLAYER, 3.0)
			elseif nNumCDRsDestroyed == 1 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C04_ZZ_EXTRA_KILL_CDR1, ARMY_PLAYER, 3.0)
			end
		end
	)
end

function Launch_ENEM01_CDR02_DeathNIS(unit)
	nNumCDRsDestroyed = nNumCDRsDestroyed + 1
	-- if all 3 enemy CDR's are dead complete defend allies objective
	if nNumCDRsDestroyed == 3 then
		LOG('----- Launch_ENEM01_CDR02_DeathNIS(unit): Primary Objective M2_obj10 - Defend Allies Complete')
		ScenarioInfo.M2_obj10:ManualResult(true)
	end
	ForkThread(
		function()
			OpNIS.NIS_ENEM01_CDR02_DEATH(unit, nNumCDRsDestroyed)
			if nNumCDRsDestroyed == 2 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C04_ZZ_EXTRA_KILL_CDR2, ARMY_PLAYER, 3.0)
			elseif nNumCDRsDestroyed == 1 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C04_ZZ_EXTRA_KILL_CDR1, ARMY_PLAYER, 3.0)
			end
		end
	)

end

function Launch_ENEM01_CDR03_DeathNIS(unit)
	nNumCDRsDestroyed = nNumCDRsDestroyed + 1
	-- if all 3 enemy CDR's are dead complete defend allies objective
	if nNumCDRsDestroyed == 3 then
		LOG('----- Launch_ENEM01_CDR03_DeathNIS(unit): Primary Objective M2_obj10 - Defend Allies Complete')
		ScenarioInfo.M2_obj10:ManualResult(true)
	end
	ForkThread(
		function()
			OpNIS.NIS_ENEM01_CDR03_DEATH(unit, nNumCDRsDestroyed)
			if nNumCDRsDestroyed == 2 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C04_ZZ_EXTRA_KILL_CDR2, ARMY_PLAYER, 3.0)
			elseif nNumCDRsDestroyed == 1 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C04_ZZ_EXTRA_KILL_CDR1, ARMY_PLAYER, 3.0)
			end
		end
	)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	LOG("P1_ReservoirAttack()")
	P1_ReservoirAttack()
end

function OnShiftF4()
	Launch_ENEM01_CDR02_DeathNIS(ScenarioInfo.ENEM01_CDR02)
end

function OnShiftF5()
	Launch_ENEM01_CDR03_DeathNIS(ScenarioInfo.ENEM01_CDR03)
end
