---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_I06/SC2_CA_I06_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_I06/SC2_CA_I06_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_I06/SC2_CA_I06_OpNIS.lua')
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
ScenarioInfo.ARMY_ALLY01 = 2
ScenarioInfo.ARMY_UEF01 = 3
ScenarioInfo.ARMY_ILLUM01 = 4
ScenarioInfo.ARMY_CYBRAN01 = 5
ScenarioInfo.ARMY_GAUGE = 6

ScenarioInfo.AssignedObjectives = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01
local ARMY_UEF01 = ScenarioInfo.ARMY_UEF01
local ARMY_ILLUM01 = ScenarioInfo.ARMY_ILLUM01
local ARMY_CYBRAN01 = ScenarioInfo.ARMY_CYBRAN01
local ARMY_GAUGE = ScenarioInfo.ARMY_GAUGE

local CybranMegalithWarning_Played 		= false	-- Megalith attack on player flag
local CybranCreepWarning01_Played		= false	-- Cybran Creep Warning 1 VO flag
local CybranCreepWarning02_Played		= false	-- Cybran Creep Warning 2 VO flag
local CybranCreepWarning03_Played		= false	-- Cybran Creep Warning 3 VO flag

local nNumCDRsKilled					= 0		-- Number of commanders killed - which happens at least a few ticks after we increment nNumCDRsDestroyed
local nNumCDRsDestroyed					= 0		-- Number of commanders destroyed - meaning they have reached zero health and begun firing off their death NIS

local PlayerUnitThreshold = false

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local UEF_MediumAirDelay_TIMER				= 120			-- UEF air attack delay on player on OP Start
local UEF_LightAirDelay_TIMER				= 60			-- UEF air attack delay on player on OP Start
local ALLY_IntelAttackDelay_TIMER			= 0
local CYBRAN_CreepIncrement01_TIMER			= 300
local CYBRAN_CreepIncrement02_TIMER			= 600
local CYBRAN_CreepIncrement03_TIMER			= 1000
local CYBRAN_CreepIncrement04_TIMER			= 1500
local CYBRAN_CreepIncrement05_TIMER			= 1700

local ILLUM_AirAttackDelay_TIMER			= 0

local ILLUM_AirIncrement01_TIMER			= 600
local ILLUM_AirIncrement02_TIMER			= 1200
local ILLUM_AirIncrement03_TIMER			= 1800
local ILLUM_AirIncrement04_TIMER			= 2400
local ILLUM_AirIncrement05_TIMER			= 3000

local CYBRAN_BaseExpansion_TIMER			= 720

local UEF_AC1000Attack_TIMER				= 430
local CYBRAN_MegalithAttack_TIMER			= 1200
local ILLUM_ExperimentalAttack_TIMER		= 2700

local UEF_GunshipAttackResponse_DELAY		= 5

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.I06_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ALLY01,	ScenarioGameTuning.I06_ARMY_ALLY01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_UEF01,		ScenarioGameTuning.I06_ARMY_UEF01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ILLUM01,	ScenarioGameTuning.I06_ARMY_ILLUM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_CYBRAN01,	ScenarioGameTuning.I06_ARMY_CYBRAN01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_GAUGE,		ScenarioGameTuning.color_GAUGE)

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
	ScenarioInfo.UEF_CDR = ScenarioUtils.CreateArmyUnit('ARMY_UEF01', 'UEF_CDR')
	ScenarioInfo.UEF_CDR:SetCustomName(ScenarioGameNames.CDR_Teller)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.UEF_CDR, 3)

	ScenarioInfo.CYBRAN_CDR	= ScenarioUtils.CreateArmyUnit('ARMY_CYBRAN01', 'CYBRAN_CDR')
	ScenarioInfo.CYBRAN_CDR:SetCustomName(ScenarioGameNames.CDR_Hazelton)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.CYBRAN_CDR, 4)

	ScenarioInfo.ILLUM_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ILLUM01', 'ILLUM_CDR')
	ScenarioInfo.ILLUM_CDR:SetCustomName(ScenarioGameNames.CDR_Haen)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ILLUM_CDR, 5)

	ScenarioInfo.ALLY01_CDR	= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_CDR')
	ScenarioInfo.ALLY01_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ALLY01_CDR, 5)

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.UEF_CDR:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.CYBRAN_CDR:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.ILLUM_CDR:RemoveCommandCap('RULEUCC_Reclaim')

	---NOTE: in order to limit the chances of failed missions, ally CDRs that can be killed should not reclaim or repair - bfricks 12/8/09
	ScenarioInfo.ALLY01_CDR:RemoveCommandCap('RULEUCC_Reclaim')
	ScenarioInfo.ALLY01_CDR:RemoveCommandCap('RULEUCC_Repair')

	---NOTE: and because the repair flag will get reset by NISs - lets tag this unit with data to prevent that - bfricks 12/8/09
	if not ScenarioInfo.ALLY01_CDR.ScenarioUnitData then
		ScenarioInfo.ALLY01_CDR.ScenarioUnitData = {}
	end
	ScenarioInfo.ALLY01_CDR.ScenarioUnitData.RepairRestricted = true

	-- CDR death damage triggers
	ScenarioFramework.CreateUnitDeathTrigger(CYBRAN_CDR_DeathDamage, ScenarioInfo.CYBRAN_CDR)
	ScenarioFramework.CreateUnitDeathTrigger(ILLUM_CDR_DeathDamage, ScenarioInfo.ILLUM_CDR)
	ScenarioFramework.CreateUnitDeathTrigger(UEF_CDR_DeathDamage, ScenarioInfo.UEF_CDR)

	-- Set up the ally base manager early, so it doesnt pop in.
	P1_AISetup_ARMY_ALLY01()

	ScenarioInfo.ArmyBase_ALLY01_MainBase = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Main_Base_Outer')

	-- Set up the Enemy units that will be nuked
	ScenarioInfo.P1_CYBRAN01_Init = ScenarioUtils.CreateArmyGroup('ARMY_CYBRAN01', 'P1_CYBRAN01_Init')
	ScenarioInfo.P1_ILLUM01_Init = ScenarioUtils.CreateArmyGroup('ARMY_ILLUM01', 'P1_ILLUM01_Init')
	ScenarioInfo.P1_UEF01_Init = ScenarioUtils.CreateArmyGroup('ARMY_UEF01', 'P1_UEF01_Init')

	-- UEF Main base that is created outside of the base manager to avoid rebuild
	ScenarioInfo.ArmyBase_UEF01_MainBase = ScenarioUtils.CreateArmyGroup('ARMY_UEF01', 'P1_UEF01_Main_Base_NoRebuild')

	-- Cybran Main base that is created outside of the base manager to avoid rebuild
	ScenarioInfo.ArmyBase_CYBRAN01_MainBase = ScenarioUtils.CreateArmyGroup('ARMY_CYBRAN01', 'P1_CYBRAN01_Main_Base_NoRebuild')

	-- Illuminate Main base that is created outside of the base manager to avoid rebuild
	ScenarioInfo.ArmyBase_ILLUMINATE01_MainBase = ScenarioUtils.CreateArmyGroup('ARMY_ILLUM01', 'P1_ILLUM01_Main_Base_NoRebuild')

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_ENG')
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')

	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_03')

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Thalia)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Set up tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ILLUM01', 'P1_ILLUM_TechCache')
	ScenarioUtils.CreateArmyGroup('ARMY_UEF01', 'P1_UEF_TechCache')
	ScenarioUtils.CreateArmyGroup('ARMY_CYBRAN01', 'P1_CYBRAN_TechCache')

	-- Set Maddox to be untargetable until the mid-OP
	P1_Maddox_ProtectFlag()
end

function P1_Main()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Destroy Enemy Commanders
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Destroy Enemy Commanders.')
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.I06_M1_obj10_NAME,		-- title
		OpStrings.I06_M1_obj10_DESC,		-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.UEF_CDR, ScenarioInfo.CYBRAN_CDR, ScenarioInfo.ILLUM_CDR },
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	-- setup each possible ending unit for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.UEF_CDR, LaunchUEFCDRDeathNIS)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.CYBRAN_CDR, LaunchCybranCDRDeathNIS)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ILLUM_CDR, LaunchIllumCDRDeathNIS)

	----------------------------------------------
	-- Primary Objective M2_obj10 - Protect Ally
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M2_obj10 - Protect Ally.')
	ScenarioInfo.M2_obj10 = SimObjectives.Protect(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.I06_M2_obj10_NAME,		-- title
		OpStrings.I06_M2_obj10_DESC,		-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.ALLY01_CDR},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)

	local curPos = ScenarioInfo.ALLY01_CDR:GetPosition()
	ScenarioInfo.FAIL_Position = {curPos[1], curPos[2], curPos[3]}

	ScenarioInfo.M2_obj10:AddResultCallback(
		function(result)
			if not result then
				-- pass in the data required to use the center pos for our fail NIS
				if ScenarioInfo.ALLY01_CDR then
					local curPos = ScenarioInfo.ALLY01_CDR:GetPosition()
					ScenarioInfo.FAIL_Position = {curPos[1], curPos[2], curPos[3]}
				end
				Defeat(true, ScenarioInfo.FAIL_Position, OpDialog.I06_ALLY_DEATH)
			end
		end
	)

	-- Patrol command given to all enemy acu's instead of adding them as an engineer for the base to avoid 'easy'
	-- kills for the player if the enemy ACU move to rebuild a destroyed base structure on the edge of an enemy base.
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.UEF_CDR}, 'P1_UEF01_ACU_Chain_01')
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.CYBRAN_CDR}, 'P1_CYBRAN01_ACU_Chain_01')
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.ILLUM_CDR}, 'P1_ILLUMINATE_ACU_Chain_01')

	-- Set up and start each army's base and opais, etc.
	P1_AISetup_ARMY_UEF01()
	P1_AISetup_ARMY_CYBRAN01()
	P1_AISetup_ARMY_ILLUM01()

	P1_OpAI_UEF()
	P1_OpAI_Cybran()
	P1_OpAI_Illum()
	P1_OpAI_Ally()

	ScenarioInfo.P1_CybranPatrolLevel = 1
	ScenarioInfo.P1_Cybran_CreepPlatoonTable = {}

	ScenarioInfo.P1_IllumPatrolLevel = 0

	----------------------------------------------
	--VO triggers
	----------------------------------------------

	-- VO telling player to get to work.
	ScenarioFramework.Dialogue(OpDialog.I06_MADDOX_INSTRUCTIONS_010)

	-- VO triggered when the player builds a loyalty gun
	ScenarioFramework.CreateArmyStatTrigger(Loyalty_Gun_VO, ArmyBrains[ARMY_PLAYER], 'Loyalty_Gun_VO',
		{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uix0114}})

	-- VO triggered early by killing some UEF air. Reinforces what player should do:
	-- focus on UEF.
	ScenarioFramework.CreateArmyStatTrigger(P1_MaddoxUEFAdvice, ArmyBrains[ARMY_UEF01], 'P1_MaddoxUEFAdvice',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.AIR * categories.UEF}})

	-- VO triggered by UEF enemy building a gantry.
	ScenarioFramework.CreateArmyStatTrigger(P1_UEFGantryWarning, ArmyBrains[ARMY_UEF01], 'P1_UEFGantryWarning',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uub0012 * categories.UEF}})

	-- VO triggered when a player spots an AC1000 from Intel
	ScenarioFramework.CreateArmyIntelTrigger(P1_PLAYERIntelAC1000, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		 categories.uux0102, true, ArmyBrains[ARMY_UEF01])

	-- VO Congratulate/confirm when player destroys a AC1000:
	ScenarioFramework.CreateArmyStatTrigger(P1_PlayerKilledAC1000, ArmyBrains[ARMY_UEF01], 'P1_PlayerKilledAC1000',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0102 * categories.UEF}})

	-- VO Congratulate/confirm when player destroys a Megalith:
	ScenarioFramework.CreateArmyStatTrigger(P1_PlayerKilledMegalith, ArmyBrains[ARMY_CYBRAN01], 'P1_PlayerKilledMegalith',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ucx0101 * categories.CYBRAN}})

	-- VO Maddox warns player that a signifcant illuminate land force is headed toward his base
	ScenarioFramework.CreateAreaTrigger(P1_MaddoxLandWarning, 'P1_MaddoxVOTrigger_Area',
		categories.uil0101 + categories.uil0103, true, false, ArmyBrains[ARMY_ILLUM01], 6, false)

	-- VO Maddox warns player that the Illuminate experimentals are nearly to his base
	ScenarioFramework.CreateAreaTrigger(P1_MaddoxExpWarning, 'P1_MaddoxVOTrigger_Area',
		categories.uix0111 + categories.uix0101, true, false, ArmyBrains[ARMY_ILLUM01], 1, false)

	-- VO triggered when Illuminate base loses a number of structures
	ScenarioFramework.CreateArmyStatTrigger(P1_IllumBaseDamaged, ArmyBrains[ARMY_ILLUM01], 'P1_IllumBaseDamaged',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.uib0001 + categories.uib0002 + categories.uib0011}})

	-- VO triggered when a UEF base loses a number of structures
	ScenarioFramework.CreateArmyStatTrigger(P1_UEFBaseDamaged, ArmyBrains[ARMY_UEF01], 'P1_UEFBaseDamaged',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 3, Category = categories.uub0001 + categories.uub0002 + categories.uub0012}})

	-- VO triggered when a Cybran base loses a number of structures
	ScenarioFramework.CreateArmyStatTrigger(P1_CybranBaseDamaged, ArmyBrains[ARMY_CYBRAN01], 'P1_CybranBaseDamaged',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.ucb0001 + categories.ucb0002 + categories.ucb0011}})

	-- VO triggered when the Player's base loses a number of structures
	ScenarioFramework.CreateArmyStatTrigger(P1_PlayerBaseDamaged, ArmyBrains[ARMY_PLAYER], 'P1_PlayerBaseDamaged',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uib0001 + categories.uib0002 + categories.uib0011}})

	-- VO triggered when the Player loses an experimental
	ScenarioFramework.CreateArmyStatTrigger(P1_PlayerExpKilled, ArmyBrains[ARMY_PLAYER], 'P1_PlayerExpKilled',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.EXPERIMENTAL}})

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 25)

	-- Create area trigger that plays VO when player is near UEF base
	ScenarioFramework.CreateAreaTrigger(UEF_VO_Trigger, 'UEF_VO_Trigger_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Create area trigger that plays VO when player is near Cybran base
	ScenarioFramework.CreateAreaTrigger(CYB_VO_Trigger, 'P1_CybranCreepTrigger_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Create area trigger that plays VO when player is near ILL base
	ScenarioFramework.CreateAreaTrigger(ILL_VO_Trigger_01, 'P1_IllumBase_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Create area trigger that plays VO when player is near Maddox's base
	ScenarioFramework.CreateAreaTrigger(ALLY_VO_Trigger_01, 'P1_MaddoxBase_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Create army stat trigger that plays VO when the first AC-1000 is built by the UEF army
	ScenarioFramework.CreateArmyStatTrigger(ALLY_VO_Trigger_02, ArmyBrains[ARMY_UEF01], 'ALLY_VO_Trigger_02',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0102}})

	-- Create army stat trigger that completes the second hidden objective when the player builds a darkenoid
	ScenarioFramework.CreateArmyStatTrigger(HiddenObjective_02, ArmyBrains[ARMY_PLAYER], 'HiddenObjective_02',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uix0112}})

	-- Create army stat trigger that fails the first hidden objective if the player builds certain units
	local catsToExclude_Land = categories.uil0001 + categories.uil0002 + categories.uil0103
	local catsToExclude_Base = categories.uib0001 + categories.uib0701 + categories.uib0702 + categories.uib0704 + categories.uib0801
	local catsTrigger01 = categories.ALLUNITS - (catsToExclude_Land + catsToExclude_Base + categories.uil0105)
	local catsTrigger02 = categories.uil0105

	-- fail if we build anything outside the allowed list - but ignore the starting anti-air units
	ScenarioFramework.CreateArmyStatTrigger(
		FailedHiddenObjective,
		ArmyBrains[ARMY_PLAYER],
		'FailedHiddenObjective01',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'GreaterThanOrEqual',
				Value = 1,
				Category = catsTrigger01,
			}
		}
	)

	-- fail if we build more anti-air units than we started with
	ScenarioFramework.CreateArmyStatTrigger(
		FailedHiddenObjective,
		ArmyBrains[ARMY_PLAYER],
		'FailedHiddenObjective02',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'GreaterThanOrEqual',
				Value = 3,
				Category = catsTrigger02,
			}
		}
	)

	----------------------------------------------
	--Op Flow Timers, and other settings
	----------------------------------------------

	--# Timing: these triggeres represent the sequence of events throughout the Op.
	--# The Op is broken into 4 acts, each around 15 minutes or so. Act1 is a buildup stage
	--# for the player, with the UEF sending some air attacks in.

	--# Act 2 is the UEF starting AC1000 attacks against the player, which the player needs
	--# to withstand, and also needs to take out the UEF base.

	--# Act 3 sees the Cybran, who have slowly been advacing their defense so that it now is
	--# is effectively their offense, turn on Megaliths, which will move through their creep
	--# patrol (that is now at the player's doorstep).

	--# Act 4 has the Illuminate, who have been the main source of attacks against Maddox
	--# throughout the op, enable Darkenoids to send at Maddox. So, Act 4 is focused on
	--# defending Maddox against this attack, along with taking out the Illuminate.

	-- Delay until the UEF will turn on its more substantial air attack, to mix in with the popcorn attack.
	ScenarioFramework.CreateTimerTrigger(P1_EnableUEFMainAttacks, UEF_MediumAirDelay_TIMER)

	-- Delay for the light UEF air attack against the player
	ScenarioFramework.CreateTimerTrigger(P1_EnableUEFLightAttacks, UEF_LightAirDelay_TIMER)

	-- Delay the beginning of the Ally 'intel' attacks, to give the enemies time to get
	-- a sufficient bit of base up and running.
	ScenarioFramework.CreateTimerTrigger(P1_EnableAllyIntelAttacks, ALLY_IntelAttackDelay_TIMER)

	-- Delay the start of illuminate air attack for a short while
	ScenarioFramework.CreateTimerTrigger(P1_EnableIllumAirAttacks, ILLUM_AirAttackDelay_TIMER)

	-- Cybran patrol creep timers: slowly change the patrols used by the cybrans. Eventually
	-- their patrols will take them right to the player base. This should lead in to Part 3,
	-- which also sees the Megalith OpAI turned on.
	ScenarioFramework.CreateTimerTrigger(P1_CybranCreepIncrement, CYBRAN_CreepIncrement01_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_CybranCreepIncrement, CYBRAN_CreepIncrement02_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_CybranCreepIncrement, CYBRAN_CreepIncrement03_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_CybranCreepIncrement, CYBRAN_CreepIncrement04_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_CybranCreepIncrement, CYBRAN_CreepIncrement05_TIMER)

	-- Illuminate air creep timers: size of the air attacks increase over time
	ScenarioFramework.CreateTimerTrigger(P1_IllumAirIncrement, ILLUM_AirIncrement01_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_IllumAirIncrement, ILLUM_AirIncrement02_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_IllumAirIncrement, ILLUM_AirIncrement03_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_IllumAirIncrement, ILLUM_AirIncrement04_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_IllumAirIncrement, ILLUM_AirIncrement05_TIMER)

	-- Create area trigger around cybran base in case player attacks them first. This will increase the creep progression
	LOG('----- P1_Main: Cybran creep advancing.')
	ScenarioFramework.CreateAreaTrigger(P1_CybranCreepIncrement, 'P1_CybranCreepTrigger_Area',
			categories.ILLUMINATE * categories.MOBILE, true, false, ArmyBrains[ARMY_PLAYER], 3, false)

	-- Create area trigger if player sends an experimental at iluminate player
	ScenarioFramework.CreateAreaTrigger(P1_IlluminateExpResponse, 'AREA_1',
			categories.EXPERIMENTAL, true, false, ArmyBrains[ARMY_PLAYER], 2, false)

	-- Just ahead of Act 2 (which is the second 15-minute block), we want
	-- to have the Cybran build their gantry. During the same general period,
	-- we want to have the cybran try to build a small expansion base near Maddox.
	-- If they succeed in getting a factory built, trigger VO from Maddox pointing
	-- out what's going on.

	ScenarioFramework.CreateTimerTrigger(P1_EnableCybranExpansion, CYBRAN_BaseExpansion_TIMER)
	ScenarioFramework.CreateAreaTrigger(P1_CybranBuildingExpansion, 'P1_CybranExpansionBase_Area',
		 categories.ucb0002, true, false, ArmyBrains[ARMY_CYBRAN01], 1 )

	-- Each act is represented by an Experimental OpAI being turned on.
	ScenarioFramework.CreateTimerTrigger(P1_EnableUEFExperimentalAttacks, UEF_AC1000Attack_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_EnableCybranMegalithAttacks, CYBRAN_MegalithAttack_TIMER)
	ScenarioFramework.CreateTimerTrigger(P1_EnableIlluminateExpAttacks, ILLUM_ExperimentalAttack_TIMER)

	-- Unit health triggers for each enemy CDR when their health is reduced to 50% or less
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_UEFGuardCommander, ScenarioInfo.UEF_CDR, 0.5, true, true)
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_CYBGuardCommander, ScenarioInfo.CYBRAN_CDR, 0.5, true, true)
	ScenarioFramework.CreateUnitHealthRatioTrigger(P1_ILLGuardCommander, ScenarioInfo.ILLUM_CDR, 0.5, true, true)
end

function Loyalty_Gun_VO()
	ScenarioFramework.Dialogue(OpDialog.I06_HINT_LOYALTY_GUN)
end

function FailedHiddenObjective()
	LOG('----- FailHiddenObjective: PlayerUnitThreshold = false')
	-- player has built X type of units, hidden objective failed
	PlayerUnitThreshold = true
end

function P1_UEFGuardCommander()
	if not ScenarioInfo.UEF_CDRDamagedHeavily then
		ScenarioInfo.UEF_CDRDamagedHeavily = true
		local guardUnits = ScenarioFramework.GetCatUnitsInArea(categories.AIR, 'AREA_1', ArmyBrains[ARMY_UEF01])

		if guardUnits then
			IssueClearCommands(guardUnits)
			IssueGuard(guardUnits, ScenarioInfo.UEF_CDR)
		end
	end
end

function P1_CYBGuardCommander()
	if not ScenarioInfo.CYB_CDRDamagedHeavily then
		ScenarioInfo.CYB_CDRDamagedHeavily = true
		local guardUnits = ScenarioFramework.GetCatUnitsInArea(categories.AIR, 'AREA_1', ArmyBrains[ARMY_CYBRAN01])

		if guardUnits then
			IssueClearCommands(guardUnits)
			IssueGuard(guardUnits, ScenarioInfo.CYBRAN_CDR)
		end
	end
end

function P1_ILLGuardCommander()
	if not ScenarioInfo.ILL_CDRDamagedHeavily then
		ScenarioInfo.ILL_CDRDamagedHeavily = true
		local guardUnits = ScenarioFramework.GetCatUnitsInArea(categories.AIR, 'P1_IllumBase_Area', ArmyBrains[ARMY_ILLUM01])

		if guardUnits then
			IssueClearCommands(guardUnits)
			IssueGuard(guardUnits, ScenarioInfo.ILLUM_CDR)
		end
	end
end

function P1_Maddox_ProtectFlag()
	LOG('----- P1: Main - Maddox Protected.')
	ScenarioInfo.ALLY01_CDR:SetDoNotTarget(true)
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.I06_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.I06_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.I06_S1_obj10_NAME,	-- title
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
			if not ScenarioInfo.CzarResearched and ArmyBrains[ARMY_PLAYER]:HasResearched('IAU_CZAR') then
				ScenarioInfo.CzarResearched = true
				ScenarioFramework.Dialogue(OpDialog.I06_RESEARCH_FOLLOWUP_DARKENOID_010)
			else
				ScenarioFramework.Dialogue(OpDialog.I06_RESEARCH_FOLLOWUP_LOYALTYGUN_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 300)
end

function ResearchReminder1()
	if ScenarioInfo.S1_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.I06_RESEARCH_REMINDER_010)
	end
end


function HiddenObjective_01()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Bot Lord
	----------------------------------------------
	LOG('----- Assign Hidden Objective H1_obj10 - Bot Lord')
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',									-- type
		'complete',										-- status
		OpStrings.I06_H1_obj10_NAME,					-- title
		OpStrings.I06_H1_obj10_DESC,					-- description
		SimObjectives.GetActionIcon('build'),			-- Action
		{
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)
end

function HiddenObjective_02()
	----------------------------------------------
	-- Hidden Objective H2_obj10 - A Czar is Born
	----------------------------------------------
	LOG('----- Assign Hidden Objective H2_obj10 - A Czar is Born')
	local descText = OpStrings.I06_H2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I06_H2_obj10_MAKE_DARKENOID)
	ScenarioInfo.H2_obj10 = SimObjectives.Basic(
		'secondary',									-- type
		'complete',										-- status
		OpStrings.I06_H2_obj10_NAME,					-- title
		descText,										-- description
		SimObjectives.GetActionIcon('build'),			-- Action
		{
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H2_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I06_H2_obj10_MAKE_DARKENOID, ARMY_PLAYER, 3.0)
end

function P1_EnableAllyIntelAttacks()
	if not ScenarioInfo.AllyIntelAttackStarted then
		LOG('----- P1: Enabling Ally intel attacks')
		-- Turn on the Ally opai that sends small air groups against the enemy,
		-- to reveal intel for the player's benefit.
		ScenarioInfo.AllyIntelAttackStarted = true
		ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:Enable()
	end
end

function P1_EnableIllumAirAttacks()
	if not ScenarioInfo.IllumAirAttackStarted then
		LOG('----- P1: Enabling Illuminate air attacks')
		-- Turn on the Illuminate opai that sends air groups against maddox.
		ScenarioInfo.IllumAirAttackStarted = true
		ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:Enable()
	end
end

function P1_EnableUEFMainAttacks()
	if not ScenarioInfo.UEFMainAttackStarted then
		LOG('----- P1: Enabling UEF main air attacks/OpAI')
		ScenarioInfo.UEFMainAttackStarted = true
		ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI:Enable()
	end
end

function P1_EnableUEFLightAttacks()
	if not ScenarioInfo.UEFLightAttackStarted then
		LOG('----- P1: Enabling UEF light air attacks/OpAI')
		ScenarioInfo.UEFLightAttackStarted = true
		ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI:Enable()
	end
end

function P1_EnableUEFGunshipAttacks()
	if not ScenarioInfo.UEFGunshipAttackStarted then
		LOG('----- P1: Enabling UEF gunship attacks/OpAI')
		ScenarioInfo.UEFGunshipAttackStarted = true
		ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI:Enable()
	end
end

function P1_EnableUEFExperimentalAttacks()
	if not ScenarioInfo.UEFExperimentalAttackStarted then
		LOG('----- P1: UEF Experimental attacks enabled')
		ScenarioInfo.UEFExperimentalAttackStarted = true
		ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI:Enable()
	end
end

function P1_EnableCybranExpansion()
	if not ScenarioInfo.CybranExpansionStarted then
		LOG('----- P1: Enabling Cybran expansion base')
		ScenarioInfo.CybranExpansionStarted = true
		ScenarioInfo.ArmyBase_CYBRAN01_Expansion_Base_01:StartEmptyBase(1)
	end
end

function P1_EnableCybranMegalithAttacks()
	if not ScenarioInfo.CybranMegalithAttackStarted then
		LOG('----- P1: Enabling Megalith attacks')
		ScenarioInfo.CybranMegalithAttackStarted = true
		ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI:Enable()
	end
end

function P1_EnableIlluminateExpAttacks()
	if not ScenarioInfo.IlluminateExpAttackStarted then
		LOG('----- P1: Enabling Illuminate Experimental land attacks')
		ScenarioInfo.IlluminateExpAttackStarted = true

		ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI:Enable()
		ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI:Enable()
		ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI:Enable()

		ScenarioFramework.Dialogue(OpDialog.I06_ILLUM_EXP_ATTACK_010)

		-- Trigger Maddox's mobile defense
		ForkThread(P1_MaddoxPatrolDefense)

		-- Create army stat trigger that plays VO when the first colossus is built by the illuminate army
		local illExpFactories = ScenarioFramework.GetCatUnitsInArea(categories.uib0011, 'P1_IllumBase_Area', ArmyBrains[ARMY_ILLUM01])
		for k, v in illExpFactories do
			ScenarioFramework.CreateUnitBuiltTrigger(ILL_VO_Trigger_02, v, categories.uix0111 )
		end
	end
end

function P1_IlluminateExpResponse(triggeringEntities)
	-- If the player builds more than one experimental the illuminate will send all the air to kill it
	if ScenarioInfo.ILLUM_CDR and not ScenarioInfo.ILLUM_CDR:IsDead() then
		LOG('----- P1: Enabling Illuminate Player Experimental Response')

		for k, experimental in triggeringEntities do
			if (experimental and not experimental:IsDead()) then
				ScenarioInfo.PlayerExperimental = experimental
				ScenarioFramework.CreateUnitDeathTrigger( P1_PlayerExpAreaTrigger, ScenarioInfo.PlayerExperimental)

				-- Get all the illuminate air units within the base area and attack and valid player experimentals
				local illumAirUnits = ScenarioFramework.GetCatUnitsInArea(categories.AIR, 'P1_IllumBase_Area', ArmyBrains[ARMY_ILLUM01])
				for k, airunit in illumAirUnits do
					if airunit and not airunit:IsDead() then
						IssueClearCommands({airunit})
						IssueAttack({airunit}, ScenarioInfo.PlayerExperimental)
						ScenarioFramework.GroupPatrolRoute({airunit}, ScenarioPlatoonAI.GetRandomPatrolRoute('P1_ILLUM01_Air_Defense_Chain_01'))
					end
				end

				LOG('----- P1: return')
				return
			end
		end
		LOG('----- P1: P1_PlayerExpAreaTrigger')
		P1_PlayerExpAreaTrigger()
	end
end

function P1_PlayerExpAreaTrigger()
	ForkThread(
		function()
			-- Waitseconds was put in due to an issue with CreateAreaTrigger returning dead units a continually looping after the unit died
			WaitSeconds(3.0)
			-- Create area trigger if player builds more than one experimental
			ScenarioFramework.CreateAreaTrigger(P1_IlluminateExpResponse, 'AREA_1', categories.EXPERIMENTAL, true, false, ArmyBrains[ARMY_PLAYER], 2, false)
		end
	)
end

function P1_MaddoxPatrolDefense()
	-- Disable the OpAI's that maintain the mobile land unit defense around Maddox's base
	ScenarioInfo.P1_ALLY01_Land01_OpAI:Disable()
	ScenarioInfo.P1_ALLY01_Land02_OpAI:Disable()

	-- Wait a short while to ensure bases complete the building of any mobile land units
	WaitSeconds(12)

	LOG('----- P1_MaddoxPatrolDefense - Get all of Maddoxs mobile land units and send them to defend')
	local maddoxMobileUnits = ScenarioFramework.GetCatUnitsInArea(categories.uul0103 + categories.uul0104, 'P1_MaddoxBase_Area', ArmyBrains[ARMY_ALLY01])

	if maddoxMobileUnits then
		IssueClearCommands(maddoxMobileUnits)
		IssueFormMove(maddoxMobileUnits, ScenarioUtils.MarkerToPosition( 'P1_ILLUM01_Air_AttackMaddox_Chain_01_14' ), 'AttackFormation', 0 )
	end

	-- VO Maddox sends his defense mobile land units out to a defense point awaiting the experimental attacks from the illuminate
	ScenarioFramework.Dialogue(OpDialog.I06_MADDOX_DEFENSE_10)

	LOG('----- P1_MaddoxPatrolDefense - Illuminate Experimental land units attack maddox')
	local illumExpUnits = ScenarioFramework.GetCatUnitsInArea(categories.uix0101 + categories.uix0111, 'P1_IllumBase_Area', ArmyBrains[ARMY_ILLUM01])
	if illumExpUnits then
		IssueClearCommands(illumExpUnits)
		ScenarioFramework.GroupPatrolChain(illumExpUnits, 'P1_ILLUM01_Land_AttackMaddox_Chain_01')
	end
end

function P1_IllumBaseDamaged()
	LOG('----- P1_IllumBaseDamaged: player has destroyed some of the Illuminate factories. Play VO')
	ScenarioFramework.Dialogue(OpDialog.I06_ILLUM_BASE_DAMAGED_010)

	-- Turn off rebuild to avoid penalizing the player
	ScenarioInfo.ArmyBase_ILLUM01_Main_Base:SetBuildAllStructures(false)
	ScenarioInfo.ArmyBase_ILLUM01_Air_Base:SetBuildAllStructures(false)
end

function P1_UEFBaseDamaged()
	LOG('----- P1_UEFBaseDamaged: player has destroyed some of the UEF factories. Play VO')
	ScenarioFramework.Dialogue(OpDialog.I06_UEF_BASE_DAMAGED_010)

	-- Turn off rebuild to avoid penalizing the player
	ScenarioInfo.ArmyBase_UEF01_Main_Base:SetBuildAllStructures(false)
end

function P1_CybranBaseDamaged()
	LOG('----- P1_CybranBaseDamaged: player has destroyed some of the Cybran factories. Play VO')
	ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_BASE_DAMAGED_010)

	-- Turn off rebuild to avoid penalizing the player
	ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:SetBuildAllStructures(false)
end

function P1_PlayerBaseDamaged()
	LOG('----- P1_PlayerBaseDamaged: enemy has destroyed some of the player factories. Play VO')
	ScenarioFramework.Dialogue(OpDialog.I06_PLAYER_BASE_DAMAGED_010)
end

function P1_PlayerExpKilled()
LOG('----- P1_PlayerExpKilled: enemy has destroyed a player experimental. Play VO')
	ScenarioFramework.Dialogue(OpDialog.I06_PLAYER_EXP_KILLED_010)
end

function P1_MaddoxUEFAdvice()
	LOG('----- P1: player has killed some UEF air. Play VO')

	local CYBAlive = ScenarioInfo.CYBRAN_CDR and not ScenarioInfo.CYBRAN_CDR:IsDead()
	local ILLAlive = ScenarioInfo.ILLUM_CDR and not ScenarioInfo.ILLUM_CDR:IsDead()

	-- Tell player to focus on UEF first.
	if CYBAlive and ILLAlive then
		ScenarioFramework.Dialogue(OpDialog.I06_UEF_FIRST_ATTACK_010)
	end
end

function P1_UEFGantryWarning()
	LOG('----- P1: UEF has built a Gantry. Play VO')

	-- Tell player to get ready for some air experimentals.
	ScenarioFramework.Dialogue(OpDialog.I06_UEF_GANTRY_BUILT_010)
end

function P1_PLAYERIntelAC1000()
	LOG('----- P1: Player spots an AC1000. Play VO')

	-- Play some VO when an AC1000 is spotted
	ScenarioFramework.Dialogue(OpDialog.I06_AC1000_SPOTTED_010)
end

function P1_PlayerKilledAC1000()
	LOG('----- P1: Player destroyed an AC1000. Play VO')

	-- Confirm player destroyed an AC1000
	ScenarioFramework.Dialogue(OpDialog.I06_AC1000_DESTROYED_010)
end

function P1_CybranBuildingExpansion()
	LOG('----- P1: Cybran have built a factor in their expanstion base')

	-- Play some VO related to the expansion base that the Cybran are building near Maddox.
	ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_EXPANSION_WARNING)
end

function P1_CybranMegalithWarning()
	LOG('----- P1: Cybran has built a megalith. Play VO')

	-- Point out that Cybran has built a megalith to send toward the player
	if ScenarioInfo.CYBRAN_CDR and not ScenarioInfo.CYBRAN_CDR:IsDead() then
		if not CybranMegalithWarning_Played then
			ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_MEGALITH_BUILT_010)
			CybranMegalithWarning_Played = true
		end
	end
end

function P1_PlayerKilledMegalith()
	LOG('----- P1: Player has destroyed a Megalith. Play VO')

	-- Confirm/congratulate player on destroying a megalith
	ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_MEGALITH_DESTROYED_010)
end

function P1_MaddoxExpWarning()
	LOG('----- P1_MaddoxExpWarning: Illuminate Experimentals near Maddoxs base. Play VO')

	-- Play VO Maddox warns player that Illuminate experimentals are close to his base
	ScenarioFramework.Dialogue(OpDialog.I06_MADDOX_DEFENSE_20)
end

function P1_MaddoxLandWarning()
	-- Play VO Maddox warns player that a significant Illuminate land force are nearing his base
	ScenarioFramework.Dialogue(OpDialog.I06_MADDOX_DEFENSE_30)
end

function UEF_VO_Trigger()
	-- Play I06_ALLY_BANTER_010
	ScenarioFramework.Dialogue(OpDialog.I06_ALLY_BANTER_010)
end

function CYB_VO_Trigger()
	if ScenarioInfo.CYBRAN_CDR and not ScenarioInfo.CYBRAN_CDR:IsDead() then
		-- Play Cybran CDR Banter VO
		ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_BANTER_010)
	end
end

function ILL_VO_Trigger_01()
	if ScenarioInfo.ILLUM_CDR and not ScenarioInfo.ILLUM_CDR:IsDead() then
		-- Play Illuminate CDR Banter VO
		ScenarioFramework.Dialogue(OpDialog.I06_ILL_BANTER_010)
	end
end

function ILL_VO_Trigger_02()
	if ScenarioInfo.ILLUM_CDR and not ScenarioInfo.ILLUM_CDR:IsDead() then
		-- Play Illuminate CDR Banter VO
		ScenarioFramework.Dialogue(OpDialog.I06_ILL_BANTER_020)
	end
end

function ALLY_VO_Trigger_01()
	-- Play Player CDR Banter VO
	ScenarioFramework.Dialogue(OpDialog.I06_ALLY_BANTER_020)
end

function ALLY_VO_Trigger_02()
	-- Play Player CDR Banter VO
	if ScenarioInfo.UEF_CDR and not ScenarioInfo.UEF_CDR:IsDead() then
		ScenarioFramework.Dialogue(OpDialog.I06_ALLY_BANTER_030)
	end
end

---------------------------------------------------------------------
-- BASES AND OPAI:
---------------------------------------------------------------------
function P1_AISetup_ARMY_UEF01()
	-- Initial UEF base
	local levelTable_UEF01_Main_Base = {
		P1_UEF01_Main_Base_100 = 100,
		P1_UEF01_Main_Base_90 = 90,
		P1_UEF01_Main_Base_80 = 80,
		P1_UEF01_Main_Base_70 = 70,
	}

	ScenarioInfo.ArmyBase_UEF01_Main_Base = ArmyBrains[ARMY_UEF01].CampaignAISystem:AddBaseManager('ArmyBase_UEF01_Main_Base',
		 'P1_UEF01_Main_Base_Marker', 80, levelTable_UEF01_Main_Base)
	ScenarioInfo.ArmyBase_UEF01_Main_Base:StartNonZeroBase(2)

	-- Base units that will be constructed onto the main base
	ScenarioInfo.ArmyBase_UEF01_Main_Base:AddBuildGroup('P1_UEF01_Main_BaseAdd_60', 60)
	ScenarioInfo.ArmyBase_UEF01_Main_Base:AddBuildGroup('P1_UEF01_Main_BaseAdd_50', 50)
	ScenarioInfo.ArmyBase_UEF01_Main_Base:AddBuildGroup('P1_UEF01_Main_BaseAdd_40', 40)
	ScenarioInfo.ArmyBase_UEF01_Main_Base:AddBuildGroup('P1_UEF01_Main_BaseAdd_30', 30)

	-- get all AA units from the the just created base and give them a veterancy buff
	local uefAA = ArmyBrains[ARMY_UEF01]:GetListOfUnits(categories.uub0102,false)
	for k, unit in uefAA do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 5)
	end
end

function P1_AISetup_ARMY_CYBRAN01()
	-- Initial CYBRAN base
	local levelTable_CYBRAN01_Main_Base = {
		P1_CYBRAN01_Main_Base_100 = 100,
		P1_CYBRAN01_Main_Base_90 = 90,
		P1_CYBRAN01_Main_Base_80 = 80,
	}

	ScenarioInfo.ArmyBase_CYBRAN01_Main_Base = ArmyBrains[ARMY_CYBRAN01].CampaignAISystem:AddBaseManager('ArmyBase_CYBRAN01_Main_Base',
		 'P1_CYBRAN01_Main_Base_Marker', 80, levelTable_CYBRAN01_Main_Base)
	ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:StartNonZeroBase(4)


	-- Base units that will be constructed onto the main base
	ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:AddBuildGroup('P1_CYBRAN01_Main_BaseAdd_60', 60)
	ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:AddBuildGroup('P1_CYBRAN01_Main_BaseAdd_50', 50)
	ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:AddBuildGroup('P1_CYBRAN01_Main_BaseAdd_40', 40)

	-- Small expansion camp overlooking the Ally. Turned on mid-op.
	ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:AddExpansionBase('ArmyBase_CYBRAN01_Expansion_Base_01')

	local expansionTable_Cybran_Expansion_01 = {
		P1_CYBRAN01_Expansion_Base_01_100 = 100,
		P1_CYBRAN01_Expansion_Base_01_90 = 90,
		P1_CYBRAN01_Expansion_Base_01_80 = 80,
	}

	ScenarioInfo.ArmyBase_CYBRAN01_Expansion_Base_01 = ArmyBrains[ARMY_CYBRAN01].CampaignAISystem:AddBaseManager('ArmyBase_CYBRAN01_Expansion_Base_01',
		 'P1_CYBRAN01_Expansion_Base_01_Marker', 50, expansionTable_Cybran_Expansion_01)

	-- get all structure defense units from the the just created base and give them a veterancy buff
	local cybranDefenses = ArmyBrains[ARMY_CYBRAN01]:GetListOfUnits(categories.ucb0101 + categories.ucb0102,false)
	for k, unit in cybranDefenses do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 2)
	end
end

function P1_AISetup_ARMY_ILLUM01()
	-- Initial base
	local levelTable_ILLUM01_Main_Base 	= { P1_ILLUM01_Main_Base_100 = 100,
											P1_ILLUM01_Main_Base_90 = 90,
											P1_ILLUM01_Main_Base_80 = 80,
											P1_ILLUM01_Main_Base_70 = 70,
											P1_ILLUM01_Main_Base_60 = 60,
											P1_ILLUM01_Main_Base_50 = 50,
										}
	ScenarioInfo.ArmyBase_ILLUM01_Main_Base = ArmyBrains[ARMY_ILLUM01].CampaignAISystem:AddBaseManager('ArmyBase_ILLUM01_Main_Base',
		 'P1_ILLUM01_Main_Base_Marker', 120, levelTable_ILLUM01_Main_Base)
	ScenarioInfo.ArmyBase_ILLUM01_Main_Base:StartNonZeroBase(4)

	-- Secondary air base
	local levelTable_ILLUM01_Air_Base 	= { P1_ILLUM01_Air_Base_100 = 100,
											P1_ILLUM01_Air_Base_90 = 90,
											P1_ILLUM01_Air_Base_80 = 80,
											P1_ILLUM01_Air_Base_70 = 70,
										}
	ScenarioInfo.ArmyBase_ILLUM01_Air_Base = ArmyBrains[ARMY_ILLUM01].CampaignAISystem:AddBaseManager('ArmyBase_ILLUM01_Air_Base',
		 'P1_ILLUM01_Air_Base_Marker', 50, levelTable_ILLUM01_Air_Base)
	ScenarioInfo.ArmyBase_ILLUM01_Air_Base:StartNonZeroBase(3)

	-- get all structure defense units from the the just created base and give them a veterancy buff
	local illumDefenses = ArmyBrains[ARMY_ILLUM01]:GetListOfUnits(categories.uib0101 + categories.uib0102,false)
	for k, unit in illumDefenses do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 5)
	end
end

function P1_AISetup_ARMY_ALLY01()
	-- Initial base
	local levelTable_ALLY01_Main_Base 	= { P1_ALLY01_Main_Base_100 = 100,
											P1_ALLY01_Main_Base_90 = 90,
											P1_ALLY01_Main_Base_80 = 80,
											P1_ALLY01_Main_Base_70 = 70,
									    }
	ScenarioInfo.ArmyBase_ALLY01_Main_Base = ArmyBrains[ARMY_ALLY01].CampaignAISystem:AddBaseManager('ArmyBase_ALLY01_Main_Base',
		 'P1_ALLY01_Main_Base_Marker', 75, levelTable_ALLY01_Main_Base)
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:StartNonZeroBase(2)
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddEngineer(ScenarioInfo.ALLY01_CDR)

	--in the case of our ally, we want infinite rebuild on.
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:SetBaseInfiniteRebuild()

	-- Outer defense 'ring' that is maintained in the first part of the OP
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddExpansionBase('P1_ALLY01_Main_Base_Outer')

	local expansionTable_ALLY01_OuterBase_01 = {
		P1_ALLY01_Main_Base_Outer_100 = 100,
		P1_ALLY01_Main_Base_Outer_90 = 90,
	}

	ScenarioInfo.P1_ALLY01_Main_Base_Outer = ArmyBrains[ARMY_ALLY01].CampaignAISystem:AddBaseManager('P1_ALLY01_Main_Base_Outer',
		 'P1_ALLY01_Main_Base_Marker', 75, expansionTable_ALLY01_OuterBase_01)

	ScenarioInfo.P1_ALLY01_Main_Base_Outer:StartEmptyBase(2)

	-- get all structure defense units from the the just created base and give them a veterancy buff
	local allyDefenses = ArmyBrains[ARMY_ALLY01]:GetListOfUnits(categories.uub0101 + categories.uub0102,false)
	for k, unit in allyDefenses do
		ScenarioFramework.SetUnitVeterancyLevel(unit, 1)
	end
end

function P1_OpAI_UEF()
	LOG('----- P1: Set up OpAIs for UEF')

	--# generate our own custom AC1000 platoon with gunship escort
	local gunship_Platoon = {
		'Gunship_Platoon',
		{
			{ 'uua0103', 3 },
		},
	}
	--# Gunship OpAI, against player. This is only enabled if the cybran or illuminate CDR's are killed
	ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI		= ScenarioInfo.ArmyBase_UEF01_Main_Base:GenerateOpAIFromPlatoonTemplate(gunship_Platoon, 'P1_UEF_Gunship_ResponsePlayer_OpAI', {} )
	local P1_UEF_Gunship_ResponsePlayer_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_UEF01_Air_AttackPlayer_Chain_01', 'P1_UEF01_Air_AttackPlayer_Chain_02',},}
	ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI:	SetPlatoonThread( 'PatrolRandomRoute', P1_UEF_Gunship_ResponsePlayer_OpAI_Data )

	ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI:	SetAttackDelay(UEF_GunshipAttackResponse_DELAY)
	ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI:	SetChildCount(1)
	ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI:	SetMaxActivePlatoons(2)
	ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI:	SetDefaultVeterancy(3)
	ScenarioInfo.P1_UEF_Gunship_ResponsePlayer_OpAI:	Disable()


	--# Early popcorn/light attack against the player
	ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI		= ScenarioInfo.ArmyBase_UEF01_Main_Base:AddOpAI('AirAttackUEF', 'P1_UEF_Air_AttackPlayer_02_OpAI', {} )
	local P1_UEF_Air_AttackPlayer_02_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_UEF01_Air_AttackPlayer_Chain_01', 'P1_UEF01_Air_AttackPlayer_Chain_02',},}
	ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_UEF_Air_AttackPlayer_02_OpAI_Data )

	ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI:		SetDefaultVeterancy(3)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_02_OpAI:		Disable()


	--# basic air attack against player
	ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI		= ScenarioInfo.ArmyBase_UEF01_Main_Base:AddOpAI('AirAttackUEF', 'P1_UEF_Air_AttackPlayer_01_OpAI', {} )
	local P1_UEF_Air_AttackPlayer_01_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_UEF01_Air_AttackPlayer_Chain_01', 'P1_UEF01_Air_AttackPlayer_Chain_02',},}
	ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_UEF_Air_AttackPlayer_01_OpAI_Data )

	ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI:		SetChildCount(1)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI:		SetDefaultVeterancy(2)
	ScenarioInfo.P1_UEF_Air_AttackPlayer_01_OpAI:		Disable()




	--# basic light air defense patrol around base
	local airDefense_Platoon = {
		'Air_Platoon',
		{
			{ 'uua0101', 3 },
		},
	}
	ScenarioInfo.P1_UEF_Air_Defense_01_OpAI				= ScenarioInfo.ArmyBase_UEF01_Main_Base:GenerateOpAIFromPlatoonTemplate(airDefense_Platoon, 'P1_UEF_Air_Defense_01_OpAI', {} )
	local P1_UEF_Air_Defense_01_OpAI_Data				= { PatrolChain = 'P1_UEF01_Air_Defense_Chain_01',}
	ScenarioInfo.P1_UEF_Air_Defense_01_OpAI:			EnableChildTypes( {'UEFFighters'} )
	ScenarioInfo.P1_UEF_Air_Defense_01_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', P1_UEF_Air_Defense_01_OpAI_Data )

	ScenarioInfo.P1_UEF_Air_Defense_01_OpAI:			SetAttackDelay(0)	--give the player room to make gains when they attack, in stead of insta rebuild.
	ScenarioInfo.P1_UEF_Air_Defense_01_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_UEF_Air_Defense_01_OpAI:			SetMaxActivePlatoons(3)
	ScenarioInfo.P1_UEF_Air_Defense_01_OpAI:			SetDefaultVeterancy(5)


	--# AC1000 OpAI, against player. This should be enabled based on time or event, for the second phase of the map.
	ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI		= ScenarioInfo.ArmyBase_UEF01_Main_Base:AddOpAI('SingleAC1000Attack', 'P1_UEF_AC1000_AttackPlayer_OpAI', {} )
	local P1_UEF_AC1000_AttackPlayer_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_UEF01_Air_AttackPlayer_Chain_01', 'P1_UEF01_Air_AttackPlayer_Chain_02',},}
	ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_UEF_AC1000_AttackPlayer_OpAI_Data )

	ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI:		SetAttackDelay(180)
	ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI:		Disable()


end

function P1_OpAI_Cybran()
	LOG('----- P1: Set up OpAIs for Cybran')

	-- Land and air creep platoons, that will slowly move out accross the map, towards the player

	--# generate our own platoon, to skip adaptivity, for the land creep.
	local landCreepTemplate = {
		'Cybran_LandCreep_Platoon',
		{
			{ 'ucl0102', 2 }, -- artillery bot
			{ 'ucl0103', 2 }, -- assault bot
			{ 'ucl0204', 2 }, -- combo defense
		},
	}
	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI			= ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:GenerateOpAIFromPlatoonTemplate(landCreepTemplate, 'P1_CYBRAN01_Creep_Land01_OpAI', {} )
	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Creep01_Chain_01', },}

	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI_Data )
	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI.			FormCallback:Add( P1_CybranAddCreepPlatoons )
	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI:			SetMaxActivePlatoons(4)
	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI:			SetDefaultVeterancy(3)

	--# air creep
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI			= ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:AddOpAI('AirAttackCybran', 'P1_CYBRAN01_Creep_Air01_OpAI', {} )
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Creep01_Chain_01', },}
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI:			EnableChildTypes( {'CybranGunships'} )
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI_Data )

	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI.			FormCallback:Add( P1_CybranAddCreepPlatoons )
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI:			SetAttackDelay(10)
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI:			SetMaxActivePlatoons(3)
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI:			SetDefaultVeterancy(3)

	--# custom megalith platoon for base defense
	local singleMegalithPatrol = {
		'SingleMegalithPlatoon',
		{
			{ 'ucx0101', 1 },
		},
	}

	--# single megalith defense patrol around the cybran base
	ScenarioInfo.P1_CYBRAN_Mega_PatrolBase_OpAI			= ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:GenerateOpAIFromPlatoonTemplate(singleMegalithPatrol, 'P1_CYBRAN_Mega_PatrolBase_OpAI', {} )
	local P1_CYBRAN_Mega_PatrolBase_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Mega_Base_Chain_01', 'P1_CYBRAN01_Mega_Base_Chain_01',}, }
	ScenarioInfo.P1_CYBRAN_Mega_PatrolBase_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_CYBRAN_Mega_PatrolBase_OpAI_Data )
	ScenarioInfo.P1_CYBRAN_Mega_PatrolBase_OpAI:		SetMaxActivePlatoons(2)


	--# land attack against Maddox
	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI		= ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:AddOpAI('LandAttackCybran', 'P1_CYBRAN01_Land_AttackAlly_OpAI', {} )
	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Land_AttackMaddox_Chain_01', }, }
	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI:		DisableChildTypes( {'CybranMobileArtillery', 'CybranMobileMissiles'})
	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI_Data )

	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.P1_CYBRAN01_Land_AttackAlly_OpAI:		SetDefaultVeterancy(3)


	--# Megalith OpAI, for attacks in act 3 of the Op.
	ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI		= ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:AddOpAI('SingleMegalithAttack', 'P1_CYBRAN_Mega_AttackPlayer_OpAI', {} )
	local P1_CYBRAN_Mega_AttackPlayer_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Mega_Chain_01', }, }
	ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_CYBRAN_Mega_AttackPlayer_OpAI_Data )
	ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI.		FormCallback:Add(P1_CybranMegalithWarning)

	ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI:		SetAttackDelay(60)
	ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI:		Disable()


	--# Small air attack from the Cybran expansion, towards Ally
	ScenarioInfo.P1_CYBRAN01_Expansion_AttackAlly_OpAI		= ScenarioInfo.ArmyBase_CYBRAN01_Expansion_Base_01:AddOpAI('AirAttackCybran', 'P1_CYBRAN01_Expansion_AttackAlly_OpAI', {} )
	local P1_CYBRAN01_Expansion_AttackAlly_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Expansion_Air_AttackAlly_01',},}
	ScenarioInfo.P1_CYBRAN01_Expansion_AttackAlly_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_CYBRAN01_Expansion_AttackAlly_OpAI_Data )

	ScenarioInfo.P1_CYBRAN01_Expansion_AttackAlly_OpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_CYBRAN01_Expansion_AttackAlly_OpAI:		SetChildCount(1)
	ScenarioInfo.P1_CYBRAN01_Expansion_AttackAlly_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_CYBRAN01_Expansion_AttackAlly_OpAI:		SetDefaultVeterancy(4)

end

function P1_OpAI_Illum()
	LOG('----- P1: Set up OpAIs for Illuminate')


	--# primary air attacks on maddox that escalate at tuning time invervals and when other enemy CDR's die
	local airAttackTemplate_01 = {
		'Illum_Air_Platoon_01',
		{
			{ 'uia0104', 6 },
		},
	}
	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate_01, 'P1_ILLUM01_Air_AttackMaddoxOpAI_01', {} )
	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackMaddox_Chain_01',},}
	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01_Data )

	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:		SetAttackDelay(30)
	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:		SetChildCount(1)
	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:		SetDefaultVeterancy(5)
	ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:       	Disable()



	--# custom air defense for the illuminate base
	local airDefenseTemplate = {
		'Illum_AirDefense_Platoon',
		{
			{ 'uia0104', 6 },
		},
	}

	ScenarioInfo.P1_ILLUM01_Air_Defense_01_OpAI			= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:GenerateOpAIFromPlatoonTemplate(airDefenseTemplate, 'P1_ILLUM01_Air_Defense_01_OpAI', {} )
	ScenarioInfo.P1_ILLUM01_Air_Defense_01_OpAI_Data	= { PatrolChain = 'P1_ILLUM01_Air_Defense_Chain_01',}
	ScenarioInfo.P1_ILLUM01_Air_Defense_01_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.P1_ILLUM01_Air_Defense_01_OpAI_Data )

	ScenarioInfo.P1_ILLUM01_Air_Defense_01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ILLUM01_Air_Defense_01_OpAI:		SetChildCount(1)
	ScenarioInfo.P1_ILLUM01_Air_Defense_01_OpAI:		SetDefaultVeterancy(5)


	--# custom air platoon for the illuminate air base
	local airAttackTemplate = {
		'Illum_AirAttack_Platoon',
		{
			{ 'uia0104', 3 },
			{ 'uia0103', 3 },
		},
	}
	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate, 'P1_ILLUM01_Air_Attack_01_OpAI', {} )
	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackPlayer_Chain_01',},}
	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI_Data )

	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI:			SetAttackDelay(0)
	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI:			SetDefaultVeterancy(4)
	ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI:			Disable()




	--# a small-group land attack against maddox enabled after either cybran or uef dies
	local illumLandTemplate = {
		'Illum_Land_Platoon',
		{
			{ 'uil0101', 2 },
			{ 'uil0103', 2 },
		},
	}
	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI		= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:GenerateOpAIFromPlatoonTemplate(illumLandTemplate, 'P1_ILLUM01_Land_AttackMaddoxOpAI', {} )
	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Land_AttackMaddox_Chain_01',},}
	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI_Data )

	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI:		SetChildCount(2)
	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI:		SetDefaultVeterancy(4)
	ScenarioInfo.P1_ILLUM01_Land_AttackMaddoxOpAI:		Disable()


	--# Universal Colossus OpAI for base defense, disabled when experimental assault is triggered
	local colossusTemplate = {
		'Illum_Colossus_Platoon',
		{
			{ 'uix0111', 1 },
		},
	}
	ScenarioInfo.P1_ILLUM01_Colossus_DefenseOpAI		= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:GenerateOpAIFromPlatoonTemplate(colossusTemplate, 'P1_ILLUM01_Colossus_DefenseOpAI', {} )
	ScenarioInfo.P1_ILLUM01_Colossus_DefenseOpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Collosus_Defense_Chain_01',},}
	ScenarioInfo.P1_ILLUM01_Colossus_DefenseOpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Colossus_DefenseOpAI_Data )


	--# Urchinow OpAI for base defense, disabled when experimental assault is triggered
	local urchinow01Template = {
		'Illum_Urchinow01_Platoon',
		{
			{ 'uix0101', 1 },
		},
	}
	ScenarioInfo.P1_ILLUM01_Urchinow01_DefenseOpAI		= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:GenerateOpAIFromPlatoonTemplate(urchinow01Template, 'P1_ILLUM01_Urchinow01_DefenseOpAI', {} )
	ScenarioInfo.P1_ILLUM01_Urchinow01_DefenseOpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Land_Defense_Chain_01',},}
	ScenarioInfo.P1_ILLUM01_Urchinow01_DefenseOpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Urchinow01_DefenseOpAI_Data )


	local urchinow02Template = {
		'Illum_Urchinow02_Platoon',
		{
			{ 'uix0101', 1 },
		},
	}
	ScenarioInfo.P1_ILLUM01_Urchinow02_DefenseOpAI		= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:GenerateOpAIFromPlatoonTemplate(urchinow02Template, 'P1_ILLUM01_Urchinow02_DefenseOpAI', {} )
	ScenarioInfo.P1_ILLUM01_Urchinow02_DefenseOpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Land_Defense_Chain_02',},}
	ScenarioInfo.P1_ILLUM01_Urchinow02_DefenseOpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Urchinow02_DefenseOpAI_Data )


	--# Experimental OpAI trigger on a timer OR when both UEF and Cybran CDR's die
	local expTemplate = {
		'Illum_Exp_Platoon',
		{
			{ 'uix0111', 1 },
			{ 'uix0101', 2 },
		},
	}
	ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI		= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:GenerateOpAIFromPlatoonTemplate(expTemplate, 'P1_ILLUM01_Exp_AttackMaddoxOpAI', {} )
	ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Land_AttackMaddox_Chain_01',},}
	ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI_Data )

	ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI:		SetDefaultVeterancy(3)
	ScenarioInfo.P1_ILLUM01_Exp_AttackMaddoxOpAI:		Disable()


	--# Large land OpAI enabled after UEF and Cybran CDR's die
	local illumLandWaveTemplate = {
		'Illum_LandWave_Platoon',
		{
			{ 'uil0101', 2 }, -- tank
			{ 'uil0103', 1 }, -- assault bot
			{ 'uil0105', 1 }, -- mobile anti air
		},
	}
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI		= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:GenerateOpAIFromPlatoonTemplate(illumLandWaveTemplate, 'P1_ILLUM01_LandWave_AttackMaddoxOpAI', {} )
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Land_AttackMaddox_Chain_01',},}
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI_Data )
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI:		SetAttackDelay(0)
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI:		SetChildCount(4)
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI:		SetDefaultVeterancy(5)
	ScenarioInfo.P1_ILLUM01_LandWave_AttackMaddoxOpAI:		Disable()


	------------------
	-- Surgical OpAIs
	------------------

	--#Land base: Surgical Response OpAI's if the player builds over-powerful units, or builds too many of certain units.
	-- Too many land units of some types
	local P1_ILLUM01l_PlayerExcessLand_OpAI			= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:AddOpAI('AirResponsePatrolLand', 'P1_ILLUM01l_PlayerExcessLand_OpAI', {} )
	local P1_ILLUM01l_PlayerExcessLand_OpAI_Data	= { AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackPlayer_Chain_01',},}
	P1_ILLUM01l_PlayerExcessLand_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ILLUM01l_PlayerExcessLand_OpAI_Data )
	P1_ILLUM01l_PlayerExcessLand_OpAI:				SetChildCount(3)


	-- Too many air units
	local P1_ILLUM01l_PlayerExcessAir_OpAI			= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:AddOpAI('AirResponsePatrolAir', 'P1_ILLUM01l_PlayerExcessAir_OpAI', {} )
	local P1_ILLUM01l_PlayerExcessAir_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackPlayer_Chain_01', },}
	P1_ILLUM01l_PlayerExcessAir_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ILLUM01l_PlayerExcessAir_OpAI_Data )
	P1_ILLUM01l_PlayerExcessAir_OpAI:				SetChildCount(3)


	-- Player builds powerful individual land units
	local P1_ILLUM01l_PlayerPowerfulLand_OpAI		=ScenarioInfo.ArmyBase_ILLUM01_Main_Base:AddOpAI('AirResponseTargetLand', 'P1_ILLUM01l_PlayerPowerfulLand_OpAI', {} )
	local P1_ILLUM01l_PlayerPowerfulLand_OpAI_Data	= {
    												    PatrolChain = 'P1_ILLUM01_Air_AttackPlayer_Chain_01',
    												    Announce = true,
    												    CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ILLUM01_Main_Base_Marker' ),
    												    CategoryList = {
    												        (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    												        categories.uub0105,	-- artillery
    												        categories.ucb0105,	-- artillery
    												        categories.NUKE,
    												   	},
    												}
	P1_ILLUM01l_PlayerPowerfulLand_OpAI:			SetPlatoonThread( 'CategoryHunter', P1_ILLUM01l_PlayerPowerfulLand_OpAI_Data )
	P1_ILLUM01l_PlayerPowerfulLand_OpAI:			SetChildCount(3)


	-- Player builds air experimentals
	local P1_ILLUM01l_PlayerPowerfulAir_OpAI		= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:AddOpAI('AirResponseTargetAir', 'P1_ILLUM01l_PlayerPowerfulAir_OpAI', {} )
	local P1_ILLUM01l_PlayerPowerfulAir_OpAI_Data	= {
    													PatrolChain = 'P1_ILLUM01_Air_AttackPlayer_Chain_01',
    												    Announce = true,
    													CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ILLUM01_Main_Base_Marker' ),
    													CategoryList = {
    													    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    													},
    												}
	P1_ILLUM01l_PlayerPowerfulAir_OpAI:				SetPlatoonThread( 'CategoryHunter', P1_ILLUM01l_PlayerPowerfulAir_OpAI_Data )
	P1_ILLUM01l_PlayerPowerfulAir_OpAI:				SetChildCount(3)


	-- Player builds mass fabs
	ScenarioInfo.P1_ILLUM01l_PlayerMassFab_OpAI			= ScenarioInfo.ArmyBase_ILLUM01_Main_Base:AddOpAI('AirResponseTargetMassFab', 'P1_ILLUM01l_PlayerMassFab_OpAI', {} )
	ScenarioInfo.P1_ILLUM01l_PlayerMassFab_OpAI_Data	= {
    												    PatrolChain = 'P1_ILLUM01_Air_AttackPlayer_Chain_01',
    												    Announce = true,
    												    CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ILLUM01_Main_Base_Marker' ),
    												    CategoryList = {
    												        	categories.uib0704,	-- mass convert
    													   	},
    													}
	ScenarioInfo.P1_ILLUM01l_PlayerMassFab_OpAI:		SetPlatoonThread( 'CategoryHunter', ScenarioInfo.P1_ILLUM01l_PlayerMassFab_OpAI_Data )
	ScenarioInfo.P1_ILLUM01l_PlayerMassFab_OpAI:		SetChildCount(2)



	--#Air base: Surgical Response OpAI's if the player builds over-powerful units, or builds too many of certain units.
	-- Too many land units of some types
	local P1_ILLUM01a_PlayerExcessLand_OpAI			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:AddOpAI('AirResponsePatrolLand', 'P1_ILLUM01a_PlayerExcessLand_OpAI', {} )
	local P1_ILLUM01a_PlayerExcessLand_OpAI_Data	= { AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackPlayer_Chain_01',},}
	P1_ILLUM01a_PlayerExcessLand_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ILLUM01a_PlayerExcessLand_OpAI_Data )
	P1_ILLUM01a_PlayerExcessLand_OpAI:				SetChildCount(2)


	-- Too many air units
	local P1_ILLUM01a_PlayerExcessAir_OpAI			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:AddOpAI('AirResponsePatrolAir', 'P1_ILLUM01a_PlayerExcessAir_OpAI', {} )
	local P1_ILLUM01a_PlayerExcessAir_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackPlayer_Chain_01', },}
	P1_ILLUM01a_PlayerExcessAir_OpAI:				SetPlatoonThread( 'PatrolRandomRoute', P1_ILLUM01a_PlayerExcessAir_OpAI_Data )
	P1_ILLUM01a_PlayerExcessAir_OpAI:				SetChildCount(2)


	-- Player builds powerful individual land units
	local P1_ILLUM01a_PlayerPowerfulLand_OpAI		=ScenarioInfo.ArmyBase_ILLUM01_Air_Base:AddOpAI('AirResponseTargetLand', 'P1_ILLUM01a_PlayerPowerfulLand_OpAI', {} )
	local P1_ILLUM01a_PlayerPowerfulLand_OpAI_Data	= {
    												    PatrolChain = 'P1_ILLUM01_Air_AttackPlayer_Chain_01',
    												    Announce = true,
    												    CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ILLUM01_Air_Base_Marker' ),
    												    CategoryList = {
    												        (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    												        categories.uub0105,	-- artillery
    												        categories.ucb0105,	-- artillery
    												        categories.NUKE,
    												   	},
    												}
	P1_ILLUM01a_PlayerPowerfulLand_OpAI:			SetPlatoonThread( 'CategoryHunter', P1_ILLUM01a_PlayerPowerfulLand_OpAI_Data )
	P1_ILLUM01a_PlayerPowerfulLand_OpAI:			SetChildCount(2)


	-- Player builds air experimentals
	local P1_ILLUM01a_PlayerPowerfulAir_OpAI		= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:AddOpAI('AirResponseTargetAir', 'P1_ILLUM01a_PlayerPowerfulAir_OpAI', {} )
	local P1_ILLUM01a_PlayerPowerfulAir_OpAI_Data	= {
    													PatrolChain = 'P1_ILLUM01_Air_AttackPlayer_Chain_01',
    												    Announce = true,
    													CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ILLUM01_Air_Base_Marker' ),
    													CategoryList = {
    													    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    													},
    												}
	P1_ILLUM01a_PlayerPowerfulAir_OpAI:				SetPlatoonThread( 'CategoryHunter', P1_ILLUM01a_PlayerPowerfulAir_OpAI_Data )
	P1_ILLUM01a_PlayerPowerfulAir_OpAI:				SetChildCount(2)
	P1_ILLUM01a_PlayerPowerfulAir_OpAI:				SetDefaultVeterancy(2)
end

function P1_OpAI_Ally()
	LOG('----- P1: Set up OpAIs for Ally')

	--# Small air attacks against each enemy, the purpose of which is to provide the player with intel.
	ScenarioInfo.P1_AllyIntellAttacks_PatrolChains 		= { 'P1_ALLY01_IntelAttack_Chain_01','P1_ALLY01_IntelAttack_Chain_02','P1_ALLY01_IntelAttack_Chain_03', }
	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI				= ScenarioInfo.ArmyBase_ALLY01_Main_Base:AddOpAI('AirAttackUEF', 'P1_ALLY01_IntelAttack_OpAI', {} )
	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI_Data		= {AnnounceRoute = true, PatrolChains = ScenarioInfo.P1_AllyIntellAttacks_PatrolChains,}
	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:			EnableChildTypes( {'UEFFighters', 'UEFBombers'} )
	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_IntelAttack_OpAI_Data )

	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:			SetAttackDelay(0)
	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:			SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:			Disable()

	--# Defense platoon that will remain at the ally base until illuminate experimental attacks begin
	local allyLandTemplate01 = {
		'Ally_Land_Platoon_01',
		{
			{ 'uul0104', 1 },
			{ 'uul0103', 1 },
		},
	}
	ScenarioInfo.P1_ALLY01_Land01_OpAI					= ScenarioInfo.ArmyBase_ALLY01_Main_Base:GenerateOpAIFromPlatoonTemplate(allyLandTemplate01, 'P1_ALLY01_Land01_OpAI', {} )
	ScenarioInfo.P1_ALLY01_Land01_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ALLY01_Land_Defense_Chain_01',},}
	ScenarioInfo.P1_ALLY01_Land01_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_Land01_OpAI_Data )
	ScenarioInfo.P1_ALLY01_Land01_OpAI:					SetMaxActivePlatoons(5)
	ScenarioInfo.P1_ALLY01_Land01_OpAI:					SetChildCount(2)

	--# Defense platoon that will remain at the ally base until illuminate experimental attacks begin
	local allyLandTemplate02 = {
		'Ally_Land_Platoon_02',
		{
			{ 'uul0104', 1 },
			{ 'uul0103', 1 },
		},
	}
	ScenarioInfo.P1_ALLY01_Land02_OpAI					= ScenarioInfo.ArmyBase_ALLY01_Main_Base:GenerateOpAIFromPlatoonTemplate(allyLandTemplate02, 'P1_ALLY01_Land02_OpAI', {} )
	ScenarioInfo.P1_ALLY01_Land02_OpAI_Data				= {AnnounceRoute = true, PatrolChains = { 'P1_ALLY01_Land_Defense_Chain_02',},}
	ScenarioInfo.P1_ALLY01_Land02_OpAI:					SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_Land02_OpAI_Data )
	ScenarioInfo.P1_ALLY01_Land02_OpAI:					SetMaxActivePlatoons(5)
	ScenarioInfo.P1_ALLY01_Land02_OpAI:					SetChildCount(2)
end


function P1_CybranAddCreepPlatoons(platoon)
	table.insert(ScenarioInfo.P1_Cybran_CreepPlatoonTable, platoon)
end

function P1_CybranCreepIncrement()
	if ScenarioInfo.P1_CybranPatrolLevel > 5 then
		-- early out if we have already called this function more than five times
		return
	end

	LOG('----- P1_CybranCreepIncrement: Increment Cybran Creep counter')
	if not ScenarioInfo.CYBRAN_CDR:IsDead() then
		ScenarioInfo.P1_CybranPatrolLevel = ScenarioInfo.P1_CybranPatrolLevel + 1
		LOG('----- P1: Creep counter is ', repr (ScenarioInfo.P1_CybranPatrolLevel))

		-- Send all existing platoons to the new patrol
		for k, v in ScenarioInfo.P1_Cybran_CreepPlatoonTable do
			if v and ArmyBrains[ARMY_CYBRAN01]:PlatoonExists(v) then
				v:Stop()
				-- Point out that the Cybran are creeping, and later play some outright
				-- confirmation of this fact (and give some advice).

				if ScenarioInfo.P1_CybranPatrolLevel == 3 then
					if not CybranCreepWarning01_Played then
						ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_CREEP_010)
						CybranCreepWarning01_Played = true
					end

				elseif ScenarioInfo.P1_CybranPatrolLevel == 4 then
					if not CybranCreepWarning02_Played then
						ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_CREEP_020)
						CybranCreepWarning02_Played = true
					end

				elseif ScenarioInfo.P1_CybranPatrolLevel == 6 then
					if not CybranCreepWarning03_Played then
						ScenarioFramework.Dialogue(OpDialog.I06_CYBRAN_CREEP_030)
						CybranCreepWarning03_Played = true
					end
				end

				ScenarioFramework.PlatoonPatrolChain(v, 'P1_CYBRAN01_Creep01_Chain_0' .. ScenarioInfo.P1_CybranPatrolLevel)
			end
		end
	end

	-- Update the creep Opais with the new patrol data, so subsequent platoons go to the new patrol
	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Creep01_Chain_0' .. ScenarioInfo.P1_CybranPatrolLevel, },}
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_CYBRAN01_Creep01_Chain_0' .. ScenarioInfo.P1_CybranPatrolLevel, },}
	ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_CYBRAN01_Creep_Land01_OpAI_Data )
	ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_CYBRAN01_Creep_Air01_OpAI_Data )
end

function P1_IllumAirIncrement()
	if ScenarioInfo.OpEnded then
		return
	end

	LOG('----- P1_IllumAirIncrement: Increment Illuminate air counter')
	if ScenarioInfo.ILLUM_CDR and not ScenarioInfo.ILLUM_CDR:IsDead() then
		if ScenarioInfo.P1_IllumPatrolLevel < 7 then

			ScenarioInfo.P1_IllumPatrolLevel = ScenarioInfo.P1_IllumPatrolLevel + 1

			LOG('----- P1_IllumAirIncrement: Illuminate air counter is ', repr (ScenarioInfo.P1_IllumPatrolLevel))

			if ScenarioInfo.P1_IllumPatrolLevel == 1 then
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_01:		Disable()

				local airAttackTemplate_02 = {
					'Illum_Air_Platoon_02',
					{
						{ 'uia0104', 6 },
					},
				}

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate_02, 'P1_ILLUM01_Air_AttackMaddoxOpAI_02', {} )
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackMaddox_Chain_01',},}
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02_Data )

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02:		SetMaxActivePlatoons(1)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02:		SetAttackDelay(25)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02:		SetChildCount(1)

			elseif ScenarioInfo.P1_IllumPatrolLevel == 2 then
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_02:		Disable()

				local airAttackTemplate_03 = {
					'Illum_Air_Platoon_03',
					{
						{ 'uia0104', 4 },
						{ 'uia0103', 2 },
					},
				}

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate_03, 'P1_ILLUM01_Air_AttackMaddoxOpAI_03', {} )
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackMaddox_Chain_01',},}
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03_Data )

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03:		SetMaxActivePlatoons(1)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03:		SetAttackDelay(20)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03:		SetChildCount(1)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03:		SetDefaultVeterancy(1)

			elseif ScenarioInfo.P1_IllumPatrolLevel == 3 then
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_03:		Disable()

				local airAttackTemplate_04 = {
					'Illum_Air_Platoon_04',
					{
						{ 'uia0104', 1 },
						{ 'uia0103', 3 },
					},
				}

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate_04, 'P1_ILLUM01_Air_AttackMaddoxOpAI_04', {} )
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackMaddox_Chain_01',},}
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04_Data )

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04:		SetMaxActivePlatoons(1)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04:		SetAttackDelay(15)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04:		SetChildCount(2)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04:		SetDefaultVeterancy(2)

			elseif ScenarioInfo.P1_IllumPatrolLevel == 4 then
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_04:		Disable()

				local airAttackTemplate_05 = {
					'Illum_Air_Platoon_05',
					{
						{ 'uia0104', 2 },
						{ 'uia0103', 3 },
					},
				}

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate_05, 'P1_ILLUM01_Air_AttackMaddoxOpAI_05', {} )
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackMaddox_Chain_01',},}
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05_Data )

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05:		SetMaxActivePlatoons(1)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05:		SetAttackDelay(10)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05:		SetChildCount(2)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05:		SetDefaultVeterancy(3)

			elseif ScenarioInfo.P1_IllumPatrolLevel == 5 then
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_05:		Disable()

				local airAttackTemplate_06 = {
					'Illum_Air_Platoon_06',
					{
						{ 'uia0104', 2 },
						{ 'uia0103', 4 },
					},
				}

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate_06, 'P1_ILLUM01_Air_AttackMaddoxOpAI_06', {} )
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackMaddox_Chain_01',},}
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06_Data )

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06:		SetMaxActivePlatoons(1)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06:		SetAttackDelay(5)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06:		SetChildCount(2)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06:		SetDefaultVeterancy(4)

			elseif ScenarioInfo.P1_IllumPatrolLevel == 6 then
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_06:		Disable()

				local airAttackTemplate_07 = {
					'Illum_Air_Platoon_07',
					{
						{ 'uia0104', 4 },
						{ 'uia0103', 2 },
					},
				}

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07			= ScenarioInfo.ArmyBase_ILLUM01_Air_Base:GenerateOpAIFromPlatoonTemplate(airAttackTemplate_07, 'P1_ILLUM01_Air_AttackMaddoxOpAI_07', {} )
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ILLUM01_Air_AttackMaddox_Chain_01',},}
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07_Data )

				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07:		SetMaxActivePlatoons(1)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07:		SetAttackDelay(0)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07:		SetChildCount(3)
				ScenarioInfo.P1_ILLUM01_Air_AttackMaddoxOpAI_07:		SetDefaultVeterancy(5)
			end
		end
	end
end

---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------
function CYBRAN_CDR_DeathDamage(CDRUnit)
	LOG('----- P1: CYBRAN CDR KILLED')

	-- handle the generic cases
	P1_EnemyCommanderKilled()

	-- now handle the custom cases for this specific CDR
	if nNumCDRsKilled < 3 then
		-- Get all remaining experimentals attack player
		local experimentalUnits = ArmyBrains[ARMY_CYBRAN01]:GetListOfUnits(categories.EXPERIMENTAL, true)
		if experimentalUnits then
			IssueClearCommands(experimentalUnits)
			IssuePatrol( experimentalUnits, ScenarioUtils.MarkerToPosition('ARMY_PLAYER') )
			IssuePatrol( experimentalUnits, ScenarioUtils.MarkerToPosition('P1_ALLY01_Main_Base_Marker') )
		end

		-- get all remaining non experimentals and attack Maddox
		local mobileUnits = ArmyBrains[ARMY_CYBRAN01]:GetListOfUnits(categories.MOBILE - categories.EXPERIMENTAL, true)
		if mobileUnits then
			IssueClearCommands(mobileUnits)
			IssuePatrol( mobileUnits, ScenarioUtils.MarkerToPosition('P1_ALLY01_Main_Base_Marker') )
			IssuePatrol( mobileUnits, ScenarioUtils.MarkerToPosition('ARMY_PLAYER') )
		end

		-- if possible, enable the gunship attacks on player
		P1_EnableUEFGunshipAttacks()

		-- if possible, enable the AC1000 attacks on player
		P1_EnableUEFExperimentalAttacks()

		-- if possible, enable the illuminate attacks if two CDRs are dead
		if nNumCDRsKilled > 1 then
			P1_EnableIlluminateExpAttacks()
		end

		-- Illuminate air attack on maddox escalates
		P1_IllumAirIncrement()

		-- Disable the rebuilding of any base structures
		ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:SetBuildAllStructures(false)
		ScenarioInfo.ArmyBase_CYBRAN01_Main_Base:BaseActive(false)

		-- Increase AC1000 Veterancy if UEF is still active
		if ScenarioInfo.UEF_CDR and ScenarioInfo.ILLUM_CDR then
			ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI: SetDefaultVeterancy(3)
		elseif ScenarioInfo.UEF_CDR and not ScenarioInfo.ILLUM_CDR then
			ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI: SetDefaultVeterancy(5)
		end

	end

	for k, v in ScenarioInfo.P1_AllyIntellAttacks_PatrolChains do
		if v == 'P1_ALLY01_IntelAttack_Chain_01' then
			table.remove(ScenarioInfo.P1_AllyIntellAttacks_PatrolChains, k)
			ScenarioInfo.P1_ALLY01_IntelAttack_OpAI: SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_IntelAttack_OpAI_Data )
		end
	end

	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ALLY01],
			ArmyBrains[ARMY_UEF01],
			ArmyBrains[ARMY_ILLUM01],
			ArmyBrains[ARMY_CYBRAN01],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 75.0, true, 5000, 90001, brainList)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

function ILLUM_CDR_DeathDamage(CDRUnit)
	LOG('----- P1: ILLUMINATE CDR KILLED')

	-- handle the generic cases
	P1_EnemyCommanderKilled()

	-- now handle the custom cases for this specific CDR
	if nNumCDRsKilled < 3 then
		-- Get all remaining experimentals attack player
		local experimentalUnits = ArmyBrains[ARMY_ILLUM01]:GetListOfUnits(categories.EXPERIMENTAL, true)
		if experimentalUnits then
			IssueClearCommands(experimentalUnits)
			IssuePatrol( experimentalUnits, ScenarioUtils.MarkerToPosition('ARMY_PLAYER') )
			IssuePatrol( experimentalUnits, ScenarioUtils.MarkerToPosition('P1_ALLY01_Main_Base_Marker') )
		end

		-- get all remaining non experimentals and attack Maddox
		local mobileUnits = ArmyBrains[ARMY_ILLUM01]:GetListOfUnits(categories.MOBILE - categories.EXPERIMENTAL, true)
		if mobileUnits then
			IssueClearCommands(mobileUnits)
			IssuePatrol( mobileUnits, ScenarioUtils.MarkerToPosition('P1_ALLY01_Main_Base_Marker') )
			IssuePatrol( mobileUnits, ScenarioUtils.MarkerToPosition('ARMY_PLAYER') )
		end

		-- if possible, enable the cybran expansion base
		P1_EnableCybranExpansion()

		-- if possible, enable the cybran megalith attacks
		P1_EnableCybranMegalithAttacks()

		-- if possible, enable the gunship attacks on player
		P1_EnableUEFGunshipAttacks()

		-- if possible, enable the AC1000 attacks on player
		P1_EnableUEFExperimentalAttacks()

		-- Disable the rebuilding of any base structures
		ScenarioInfo.ArmyBase_ILLUM01_Main_Base:SetBuildAllStructures(false)
		ScenarioInfo.ArmyBase_ILLUM01_Main_Base:BaseActive(false)

		-- Increase AC1000 Veterancy if UEF is still active
		if ScenarioInfo.ILLUM_CDR and ScenarioInfo.CYBRAN_CDR then
			ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI: SetDefaultVeterancy(3)
		elseif ScenarioInfo.ILLUM_CDR and not ScenarioInfo.CYBRAN_CDR then
			ScenarioInfo.P1_UEF_AC1000_AttackPlayer_OpAI: SetDefaultVeterancy(5)
		end

		-- Increase veterancy of megalith attacks if cybran is alive
		if ScenarioInfo.CYBRAN_CDR and not ScenarioInfo.CYBRAN_CDR:IsDead() then
			ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI:SetDefaultVeterancy(5)
		end

	end

	for k, v in ScenarioInfo.P1_AllyIntellAttacks_PatrolChains do
		if v == 'P1_ALLY01_IntelAttack_Chain_02' then
			table.remove(ScenarioInfo.P1_AllyIntellAttacks_PatrolChains, k)
			ScenarioInfo.P1_ALLY01_IntelAttack_OpAI: SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_IntelAttack_OpAI_Data )
		end
	end

	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ALLY01],
			ArmyBrains[ARMY_UEF01],
			ArmyBrains[ARMY_ILLUM01],
			ArmyBrains[ARMY_CYBRAN01],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 75.0, true, 5000, 90001, brainList)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

function UEF_CDR_DeathDamage(CDRUnit)
	LOG('----- P1: UEF CDR KILLED')

	-- handle the generic cases
	P1_EnemyCommanderKilled()

	-- now handle the custom cases for this specific CDR
	if nNumCDRsKilled < 3 then
		-- Get all remaining experimentals attack player
		local experimentalUnits = ArmyBrains[ARMY_UEF01]:GetListOfUnits(categories.EXPERIMENTAL, true)
		if experimentalUnits then
			IssueClearCommands(experimentalUnits)
			IssuePatrol( experimentalUnits, ScenarioUtils.MarkerToPosition('ARMY_PLAYER') )
			IssuePatrol( experimentalUnits, ScenarioUtils.MarkerToPosition('P1_ALLY01_Main_Base_Marker') )
		end

		-- get all remaining non experimentals and attack Maddox
		local mobileUnits = ArmyBrains[ARMY_UEF01]:GetListOfUnits(categories.MOBILE - categories.EXPERIMENTAL, true)
		if mobileUnits then
			IssueClearCommands(mobileUnits)
			IssuePatrol( mobileUnits, ScenarioUtils.MarkerToPosition('P1_ALLY01_Main_Base_Marker') )
			IssuePatrol( mobileUnits, ScenarioUtils.MarkerToPosition('ARMY_PLAYER') )
		end

		-- if possible, enable the illuminate attacks if two CDRs are dead
		if nNumCDRsKilled > 1 then
			P1_EnableIlluminateExpAttacks()
		end

		-- Illuminate air attack on maddox escalates
		P1_IllumAirIncrement()

		-- if possible, enable the cybran expansion base
		P1_EnableCybranExpansion()

		-- if possible, enable the cybran megalith attacks
		P1_EnableCybranMegalithAttacks()

		-- Disable the rebuilding of any base structures
		ScenarioInfo.ArmyBase_UEF01_Main_Base:SetBuildAllStructures(false)
		ScenarioInfo.ArmyBase_UEF01_Main_Base:BaseActive(false)

		-- Increase veterancy of megalith attacks if cybran is alive
		if ScenarioInfo.CYBRAN_CDR and not ScenarioInfo.CYBRAN_CDR:IsDead() then
			ScenarioInfo.P1_CYBRAN_Mega_AttackPlayer_OpAI:SetDefaultVeterancy(3)
		end

	end

	for k, v in ScenarioInfo.P1_AllyIntellAttacks_PatrolChains do
		if v == 'P1_ALLY01_IntelAttack_Chain_03' then
			table.remove(ScenarioInfo.P1_AllyIntellAttacks_PatrolChains, k)
			ScenarioInfo.P1_ALLY01_IntelAttack_OpAI: SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_IntelAttack_OpAI_Data )
		end
	end

	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ALLY01],
			ArmyBrains[ARMY_UEF01],
			ArmyBrains[ARMY_ILLUM01],
			ArmyBrains[ARMY_CYBRAN01],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 75.0, true, 5000, 90001, brainList)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

function P1_EnemyCommanderKilled()
	-- When each commander is killed, play appropriate VO for this event, unless
	-- it is the 3rd death (at this point, the Objective system will play the
	-- objective completion VO). Also, after each death, remove the chain used
	-- by our ally to attack this commander's base, as there is now not much to
	-- attack there.

	nNumCDRsKilled = nNumCDRsKilled + 1

	-- So we dont imbalance things, lower the amount of intel attacks our ally sends out,
	-- to reflect diminishing number of enemies
	local intelAttackMaxPlatoon = 3 - nNumCDRsKilled
	if intelAttackMaxPlatoon > 0 then
		ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:SetMaxActivePlatoons(intelAttackMaxPlatoon)
	else
		ScenarioInfo.P1_ALLY01_IntelAttack_OpAI:SetMaxActivePlatoons(1)
	end

	-- Flag ally CDR as targetable after the first enemy CDR is killed.
	if nNumCDRsKilled == 1 then
		ScenarioInfo.ALLY01_CDR:SetDoNotTarget(false)
	end

	if nNumCDRsKilled == 2 then
		if ScenarioInfo.ILLUM_CDR and not ScenarioInfo.ILLUM_CDR:IsDead() then
			LOG('----- P1_EnemyCommanderKilled: UEF and Cybran CDRs killed, disable some OpAIs')
			ScenarioInfo.P1_ILLUM01_Colossus_DefenseOpAI:Disable()
			ScenarioInfo.P1_ILLUM01_Urchinow01_DefenseOpAI:Disable()
			ScenarioInfo.P1_ILLUM01_Urchinow02_DefenseOpAI:Disable()

			-- Enable Illuminate air attacks on player
			ScenarioInfo.P1_ILLUM01_Air_Attack_01_OpAI:Enable()

			-- Remove the engineers that maintain the outer wall portion of maddox's base
			ScenarioInfo.P1_ALLY01_Main_Base_Outer:SetBuildAllStructures(false)
			ScenarioInfo.ArmyBase_ALLY01_Main_Base:SetBuildAllStructures(false)
		end
	end
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function LaunchUEFCDRDeathNIS(unit)
	nNumCDRsDestroyed = nNumCDRsDestroyed + 1
	-- if all three enemy CDR's die and PlayerUnitThreshold = false then complete the first hidden objective
	if nNumCDRsDestroyed == 3 and PlayerUnitThreshold == false then
		HiddenObjective_01()
	end
	-- if all 3 enemy CDR's are dead complete protect ally objective
	if nNumCDRsDestroyed == 3 then
		LOG('----- LaunchUEFCDRDeathNIS(unit): Primary Objective M2_obj10 - Protect Ally Complete')
		ScenarioInfo.M2_obj10:ManualResult(true)

		-- disable the remaining secondary base managers of the now-dead enemy.
		ScenarioInfo.ArmyBase_CYBRAN01_Expansion_Base_01:BaseActive(false)
		ScenarioInfo.ArmyBase_ILLUM01_Air_Base:BaseActive(false)
	end
	ForkThread(
		function()
			OpNIS.NIS_UEF_CDR_DEATH(unit, nNumCDRsDestroyed)
			if nNumCDRsDestroyed == 2 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I06_ZZ_EXTRA_KILL_CDR2, ARMY_PLAYER, 3.0)
			elseif nNumCDRsDestroyed == 1 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I06_ZZ_EXTRA_KILL_CDR1, ARMY_PLAYER, 3.0)
			end
		end
	)
end

function LaunchCybranCDRDeathNIS(unit)
	nNumCDRsDestroyed = nNumCDRsDestroyed + 1
	-- if all three enemy CDR's die and PlayerUnitThreshold = false then complete the first hidden objective
	if nNumCDRsDestroyed == 3 and PlayerUnitThreshold == false then
		HiddenObjective_01()
	end
	-- if all 3 enemy CDR's are dead complete protect ally objective
	if nNumCDRsDestroyed == 3 then
		LOG('----- LaunchCybranCDRDeathNIS(unit): Primary Objective M2_obj10 - Protect Ally Complete')
		ScenarioInfo.M2_obj10:ManualResult(true)

		-- disable the remaining secondary base managers of the now-dead enemy.
		ScenarioInfo.ArmyBase_CYBRAN01_Expansion_Base_01:BaseActive(false)
		ScenarioInfo.ArmyBase_ILLUM01_Air_Base:BaseActive(false)
	end
	ForkThread(
		function()
			OpNIS.NIS_CYBRAN_CDR_DEATH(unit, nNumCDRsDestroyed)
			if nNumCDRsDestroyed == 2 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I06_ZZ_EXTRA_KILL_CDR2, ARMY_PLAYER, 3.0)
			elseif nNumCDRsDestroyed == 1 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I06_ZZ_EXTRA_KILL_CDR1, ARMY_PLAYER, 3.0)
			end
		end
	)
end

function LaunchIllumCDRDeathNIS(unit)
	nNumCDRsDestroyed = nNumCDRsDestroyed + 1
	-- if all three enemy CDR's die and PlayerUnitThreshold = false then complete the first hidden objective
	if nNumCDRsDestroyed == 3 and PlayerUnitThreshold == false then
		HiddenObjective_01()
	end
	-- if all 3 enemy CDR's are dead complete protect ally objective
	if nNumCDRsDestroyed == 3 then
		LOG('----- LaunchIllumCDRDeathNIS(unit): Primary Objective M2_obj10 - Protect Ally Complete')
		ScenarioInfo.M2_obj10:ManualResult(true)

		-- disable the remaining secondary base managers of the now-dead enemy.
		ScenarioInfo.ArmyBase_CYBRAN01_Expansion_Base_01:BaseActive(false)
		ScenarioInfo.ArmyBase_ILLUM01_Air_Base:BaseActive(false)
	end
	ForkThread(
		function()
			OpNIS.NIS_ILLUM_CDR_DEATH(unit, nNumCDRsDestroyed)
			if nNumCDRsDestroyed == 2 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I06_ZZ_EXTRA_KILL_CDR2, ARMY_PLAYER, 3.0)
			elseif nNumCDRsDestroyed == 1 then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I06_ZZ_EXTRA_KILL_CDR1, ARMY_PLAYER, 3.0)
			end
		end
	)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
-- 	nNumCDRsDestroyed = 2
-- 	LaunchUEFCDRDeathNIS(ScenarioInfo.UEF_CDR)
end

function OnShiftF4()
	LaunchIllumCDRDeathNIS(ScenarioInfo.ILLUM_CDR)
end

function OnShiftF5()
	LaunchCybranCDRDeathNIS(ScenarioInfo.CYBRAN_CDR)
end
