---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_I02/SC2_CA_I02_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_I02/SC2_CA_I02_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_I02/SC2_CA_I02_OpNIS.lua')
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
ScenarioInfo.ARMY_CIV01 = 3

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.P1_ObjectiveUnits = {}

ScenarioInfo.P2_ObjectiveUnits = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_CIV01 = ScenarioInfo.ARMY_CIV01

local MobileUnitThreshold = true
---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local P2_EnableWest_WestTeleAttack_TIMER 		= 90		-- West support base OpAI timer
local P2_EnableEast_EastTeleAttack_TIMER 		= 105		-- East support base OpAI timer
local P2_EnableEast_MidTeleAttack_TIMER 		= 75		-- East support base OpAI timer

local P1_ENEM01_East_TeleEast_01_OpAI_DELAY		= 45		-- East enemy teleport land attack delay
local P1_ENEM01_East_TeleMid_01_OpAI_DELAY		= 75		-- East enemy middle teleport land attack delay
local P1_ENEM01_West_TeleWest_01_OpAI_DELAY		= 60		-- West enemy teleport land attack delay

local P1_PlayerIntelRadius						= 225
local P2_EnemyIntelRadius						= 10000
local P2_PlayerIntelRadius						= 10000

local PlayerStartingUnits						= 42		-- Must equal the total starting mobile player units
---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
-- PART 1:
--		basically a series of platoons that can be adjusted in size and composition from the editor.
--		Each platoon is timed using the function: P1_AttackThread (which is a good place to see the names of the platoons as well)

-- PART 2:
--		in the new simplified form, this is just a defended base, and three OpAIs - West, East, and Middle
--		to adjust these go to the following functions:
--			P2_AISetup_Enemy_West
--			P2_AISetup_Enemy_East

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.I02_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.I02_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CIV01,		ScenarioGameTuning.color_CIV_I02)
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

	---- Set up enemy structures
	ScenarioInfo.P1_ENEM01_Defenses_01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Defense_01')

	---- Set up enemy structures that will be kiled during the intro NIS
	ScenarioInfo.P1_ENEM01_Defense_KillOnStart = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Defense_KillOnStart')

	---- Give unique handles to each unit that will be killed during the NIS
	ScenarioInfo.P1_ENEM01_RADAR01 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_RADAR01']
	ScenarioInfo.P1_ENEM01_EP01 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_EP01']

	ScenarioInfo.P1_ENEM01_PD01 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_PD01']
	ScenarioInfo.P1_ENEM01_PD02 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_PD02']
	ScenarioInfo.P1_ENEM01_PD03 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_PD03']
	ScenarioInfo.P1_ENEM01_PD04 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_PD04']

	ScenarioInfo.P1_ENEM01_AA01 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA01']
	ScenarioInfo.P1_ENEM01_AA02 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA02']
	ScenarioInfo.P1_ENEM01_AA03 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA03']
	ScenarioInfo.P1_ENEM01_AA04 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA04']
	ScenarioInfo.P1_ENEM01_AA05 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA05']
	ScenarioInfo.P1_ENEM01_AA06 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA06']
	ScenarioInfo.P1_ENEM01_AA07 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA07']
	ScenarioInfo.P1_ENEM01_AA08 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA08']
	ScenarioInfo.P1_ENEM01_AA09 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA09']
	ScenarioInfo.P1_ENEM01_AA10 = ScenarioInfo.UnitNames[ARMY_ENEM01]['P1_ENEM01_AA10']

	---- Reduce the health for all inital structures we want to die quickly during NIS
	for k, unit in ScenarioInfo.P1_ENEM01_Defense_KillOnStart do
		unit:SetMaxHealth(1)
		unit:AdjustHealth(unit, 1)
	end

	---- Set up enemy units
	ScenarioInfo.P1_ENEM01_Tank_01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'Tank_01')
		ScenarioInfo.P1_ENEM01_Tank_01:SetMaxHealth(Random (10,250))
		ScenarioInfo.P1_ENEM01_Tank_01:AdjustHealth(ScenarioInfo.P1_ENEM01_Tank_01, Random (50,300))
	ScenarioInfo.P1_ENEM01_Tank_02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'Tank_02')
		ScenarioInfo.P1_ENEM01_Tank_02:SetMaxHealth(Random (10,250))
		ScenarioInfo.P1_ENEM01_Tank_02:AdjustHealth(ScenarioInfo.P1_ENEM01_Tank_02, Random (50,300))
	ScenarioInfo.P1_ENEM01_Tank_03 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'Tank_03')
		ScenarioInfo.P1_ENEM01_Tank_03:SetMaxHealth(Random (10,250))
		ScenarioInfo.P1_ENEM01_Tank_03:AdjustHealth(ScenarioInfo.P1_ENEM01_Tank_03, Random (50,300))
	ScenarioInfo.P1_ENEM01_Bot_01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'Bot_01')
		ScenarioInfo.P1_ENEM01_Bot_01:SetMaxHealth(Random (10,250))
		ScenarioInfo.P1_ENEM01_Bot_01:AdjustHealth(ScenarioInfo.P1_ENEM01_Bot_01, Random (50,300))
	ScenarioInfo.P1_ENEM01_Bot_02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'Bot_02')
		ScenarioInfo.P1_ENEM01_Bot_02:SetMaxHealth(Random (10,250))
		ScenarioInfo.P1_ENEM01_Bot_02:AdjustHealth(ScenarioInfo.P1_ENEM01_Bot_02, Random (50,300))


	ScenarioInfo.P1_ENEM01_MidAttack_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_Mid_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_MidAttack_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_Mid_02', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_MidAttack_03 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_Mid_03', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_MidAttack_04 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_Mid_04', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_MidAttack_05 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_Mid_05', 'AttackFormation')

	ScenarioInfo.P1_ENEM01_WestAttack_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_West_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_WestAttack_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_West_02', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_WestAttack_03 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_West_03', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_WestAttack_04 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_West_04', 'AttackFormation')

	ScenarioInfo.P1_ENEM01_EastAttack_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_East_01', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_EastAttack_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_East_02', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_EastAttack_03 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_East_03', 'AttackFormation')
	ScenarioInfo.P1_ENEM01_EastAttack_04 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandAttack_East_04', 'AttackFormation')

	-- Create east and west base wings (for visibility in P1 just in case)
	ScenarioInfo.P1_ENEM01_EastBaseWing_01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'east_base_wing')
	ScenarioInfo.P1_ENEM01_WestBaseWing_01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'west_base_wing')

	-- Add enemy defensive units to objective table
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_MidAttack_01)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_MidAttack_02)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_MidAttack_03)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_MidAttack_04)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_MidAttack_05)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_WestAttack_01)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_WestAttack_02)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_WestAttack_03)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_WestAttack_04)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_EastAttack_01)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_EastAttack_02)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_EastAttack_03)
	AddPlatoonUnitsToTable(ScenarioInfo.P1_ObjectiveUnits, ScenarioInfo.P1_ENEM01_EastAttack_04)

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitLand_01')
	ScenarioInfo.INTRONIS_Group2 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_InitLand_02')
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')

	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')
	ScenarioInfo.INTRONIS_Group1Transport:SetMaxHealth(200)
	ScenarioInfo.INTRONIS_Group1Transport:AdjustHealth(ScenarioInfo.INTRONIS_Group1Transport, 200)

	ScenarioInfo.INTRONIS_Group2Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_02')
	ScenarioInfo.INTRONIS_Group2Transport:SetMaxHealth(200)
	ScenarioInfo.INTRONIS_Group2Transport:AdjustHealth(ScenarioInfo.INTRONIS_Group2Transport, 200)

	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_03')
	ScenarioInfo.INTRONIS_CommanderTransport:SetMaxHealth(200)
	ScenarioInfo.INTRONIS_CommanderTransport:AdjustHealth(ScenarioInfo.INTRONIS_CommanderTransport, 200)

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Thalia)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Create p1 area tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')
end

function P1_Main()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Repulse Enemy Defenders
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Repulse Enemy Defenders.')
	local descText = OpStrings.I02_M1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I02_M1_obj10_KILL_WAVE1)
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.I02_M1_obj10_NAME,			-- title
		descText,								-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = ScenarioInfo.P1_ObjectiveUnits,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				-- Use a slight delay in beginning Part 2, so there isnt a sudden jarring
				-- change and transition the split second the final Part 1 objective unit is
				-- destroyed
				ScenarioFramework.CreateTimerTrigger (P2_Setup, 4)
			end
		end
	)

	-- Give the player intel for the P1 section of the map
	ScenarioFramework.CreateIntelAtLocation(P1_PlayerIntelRadius, 'ARMY_PLAYER', ARMY_PLAYER, 'Radar')

	-- Create army stat trigger for hidden objective tracking of mobile units built by player
	---NOTE: switching this to a history call so that you can't get a free pass for units that are killed - bfricks 11/21/09
	ScenarioFramework.CreateArmyStatTrigger (FailedHiddenObjective, ArmyBrains[ARMY_PLAYER], 'FailedHiddenObjective',
			{{StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = 31 + PlayerStartingUnits, Category = categories.MOBILE}})

	-- Start Attacks
	ForkThread(P1_AttackThread)
end

function FailedHiddenObjective()
	LOG('----- FailHiddenObjective: MobileUnitThreshold = false')
	-- player has built more than X units, hidden objective failed
	MobileUnitThreshold = false
end

function ValidateAndAttack(platoon, chain)
	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		for k, v in ScenarioUtils.ChainToPositions(chain) do
			IssueMove( platoon:GetPlatoonUnits(), v)
		end

		-- after a delay, send the units after the ACU
		ScenarioFramework.CreateTimerTrigger(
			function()
				---NOTE: at this point in the game, I feel comfortable with giving explicit
				---			kill orders to attack the player ACU for these sort of hand-placed units - bfricks 11/2/09
				IssueClearCommands(platoon:GetPlatoonUnits())
				IssueAttack(platoon:GetPlatoonUnits(), ScenarioInfo.PLAYER_CDR)
			end,
			25.0
		)

	end
end

function P1_AttackThread()
	ValidateAndAttack(ScenarioInfo.P1_ENEM01_MidAttack_01, 'P1_ENEM01_LandAttack_Mid_01_Chain')
	WaitSeconds(3.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_MidAttack_02, 'P1_ENEM01_LandAttack_Mid_01_Chain')
	WaitSeconds(3.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_MidAttack_03, 'P1_ENEM01_LandAttack_Mid_01_Chain')
	WaitSeconds(3.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_MidAttack_04, 'P1_ENEM01_LandAttack_Mid_01_Chain')
	WaitSeconds(3.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_MidAttack_05, 'P1_ENEM01_LandAttack_Mid_01_Chain')
	WaitSeconds(15.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_WestAttack_01, 'P1_ENEM01_LandAttack_West_01_Chain')
	WaitSeconds(2.0)
	ValidateAndAttack(ScenarioInfo.P1_ENEM01_EastAttack_01, 'P1_ENEM01_LandAttack_East_01_Chain')
	WaitSeconds(10.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_WestAttack_02, 'P1_ENEM01_LandAttack_West_01_Chain')
	WaitSeconds(2.0)
	ValidateAndAttack(ScenarioInfo.P1_ENEM01_EastAttack_02, 'P1_ENEM01_LandAttack_East_01_Chain')
	WaitSeconds(10.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_WestAttack_03, 'P1_ENEM01_LandAttack_West_01_Chain')
	WaitSeconds(2.0)
	ValidateAndAttack(ScenarioInfo.P1_ENEM01_EastAttack_03, 'P1_ENEM01_LandAttack_East_01_Chain')
	WaitSeconds(10.0)

	ValidateAndAttack(ScenarioInfo.P1_ENEM01_WestAttack_04, 'P1_ENEM01_LandAttack_West_01_Chain')
	WaitSeconds(2.0)
	ValidateAndAttack(ScenarioInfo.P1_ENEM01_EastAttack_04, 'P1_ENEM01_LandAttack_East_01_Chain')
end

function AddPlatoonUnitsToTable(unitTable, platoon)
	for k, v in platoon:GetPlatoonUnits() do
		if v and not v:IsDead() then
			table.insert(unitTable, v)
		end
	end
end


---------------------------------------------------------------------
-- PART 2:
---------------------------------------------------------------------
function P2_Setup()
	LOG('----- P2_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 2

	-- Create the facility structure, flag to be protected.
	ScenarioInfo.P2_ENEM01_Experimental_Factory = ScenarioUtils.CreateArmyUnit('ARMY_CIV01', 'P2_ENEM01_Experimental_Factory')
	ScenarioInfo.P2_ENEM01_Experimental_Factory:SetDoNotTarget(true)
	ProtectUnit(ScenarioInfo.P2_ENEM01_Experimental_Factory)

	-- Give enemy full radar intel covering the entire map
	ScenarioFramework.CreateIntelAtLocation(P2_EnemyIntelRadius, 'Intel_Location', ARMY_ENEM01, 'Radar')

	-- AssaultBlock + some other land units out front as a defense at the end of the span
	ScenarioInfo.AssaultBlock = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_Middle_AssaultBlock')
	ScenarioFramework.CreateUnitDeathTrigger( P2_FrontDefendersDestroyed_VO, ScenarioInfo.AssaultBlock )

	-- Units that escort the assult block and move with it during the NIS
	ScenarioInfo.AssaultBlockEscort = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Middle_AssaultBlockEscort', 'AttackFormation')

	-- Illuminate air towers created outside of the base manager to avoid rebuild
	P2_AISetup_Enemy_West()
	P2_AISetup_Enemy_East()

	-- Army stat trigger that with disable all rebuilding on the illuminate bases after one factory has been destroyed
	ScenarioFramework.CreateArmyStatTrigger(P1_IllumBasesDamaged, ArmyBrains[ARMY_ENEM01], 'P1_IllumBasesDamaged',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uib0001 + categories.uib0002}})

	ScenarioInfo.P2_ENEM01_BaseFactories = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.uib0001 + categories.uib0002, false)

	-- Add enemy defensive units to the 'secure the facility' objective table
	for k, unit in ScenarioInfo.P2_ENEM01_BaseFactories do
		table.insert(ScenarioInfo.P2_ObjectiveUnits, unit)
	end

	-- Create enemy structures south of the east/west bases
	ScenarioInfo.P2_ENEM01_SouthBase = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'south_base', 'AttackFormation')

	-- create enemy defenders
	ScenarioInfo.P2_ENEM01_WestBase_Defense = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_West_MiddlePatrol_Init', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P2_ENEM01_WestBase_Defense, 5)

	ScenarioInfo.P2_ENEM01_EastBase_Defense = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_East_MiddlePatrol_Init', 'AttackFormation')
	ScenarioFramework.SetPlatoonVeterancyLevel(ScenarioInfo.P2_ENEM01_EastBase_Defense, 5)

	-- create enemy attackers
	ScenarioInfo.P2_ENEM01_Land_Attack = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Init_LandAttack_01', 'AttackFormation')

	-- Create east and west air defense patrols
	ScenarioInfo.P2_ENEM01_WestAirPatrol01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_WestBase_Air01')
	ScenarioInfo.P2_ENEM01_WestAirPatrol02 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_WestBase_Air02')
	ScenarioInfo.P2_ENEM01_WestAirPatrol03 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_WestBase_Air03')
	ScenarioInfo.P2_ENEM01_WestAirPatrol04 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_WestBase_Air04')

	ScenarioInfo.P2_ENEM01_EastAirPatrol01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_EastBase_Air01')
	ScenarioInfo.P2_ENEM01_EastAirPatrol02 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_EastBase_Air02')
	ScenarioInfo.P2_ENEM01_EastAirPatrol03 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_EastBase_Air03')
	ScenarioInfo.P2_ENEM01_EastAirPatrol04 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_EastBase_Air04')

	-- Create p2 area tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_TechCache')

	-- VO from Jaren
	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I02_M1_obj10_KILL_WAVE1, ARMY_PLAYER, 3.0)
	ScenarioFramework.Dialogue(OpDialog.I02_P2_INTEL_REVEAL_10, P2_Transition)
end

function P1_IllumBasesDamaged()
	LOG('----- P1_IllumBasesDamaged: player has destroyed some of the Illuminate factories.')
	-- Turn off rebuild to avoid penalizing the player
	ScenarioInfo.ArmyBase_ENEM01_West_Base:SetBuildAllStructures(false)
	ScenarioInfo.ArmyBase_ENEM01_East_Base:SetBuildAllStructures(false)
end

function P2_Transition()
	ForkThread(
		function()
			OpNIS.NIS_REVEAL_ENEMY()
			P2_Main()
		end
	)
end

function P2_Main()
	-- Start patrols for the initial defenders, some with handles to pass to OpAI's
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM01_WestBase_Defense, 'P2_ENEM01_West_MidDefense_Chain')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM01_EastBase_Defense, 'P2_ENEM01_East_MidDefense_Chain')

	-- Start patrol for the initial attack
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM01_Land_Attack, 'P2_ENEM01_AttackMid_Chain_01')

	-- random patrol chains for east and west enemy air defense
	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_WestAirPatrol01, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_West_Air_Patrol01'))
	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_WestAirPatrol02, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_West_Air_Patrol01'))
	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_WestAirPatrol03, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_West_Air_Patrol01'))
	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_WestAirPatrol04, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_West_Air_Patrol01'))

	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_EastAirPatrol01, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_East_Air_Patrol01'))
	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_EastAirPatrol02, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_East_Air_Patrol01'))
	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_EastAirPatrol03, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_East_Air_Patrol01'))
	ScenarioFramework.GroupPatrolRoute(ScenarioInfo.P2_ENEM01_EastAirPatrol04, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_East_Air_Patrol01'))

	-- Set up enemy bases and teleport attacks
	P2_Enemy_West_Teleport()
	P2_Enemy_East_Teleport()
	P2_Enemy_Middle_Teleport()

	-- Give player full radar intel covering the entire map
	ScenarioFramework.CreateIntelAtLocation(P2_PlayerIntelRadius, 'Intel_Location', ARMY_PLAYER, 'Radar')

	-- Create army stat trigger checking for player air count
	ScenarioFramework.CreateArmyStatTrigger(P2_Enemy_Air_Defense, ArmyBrains[ARMY_PLAYER], 'P2_Enemy_Air_Defense',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value= 10, Category = categories.AIR}})

	-- Create army stat trigger checking for a large player air count
	ScenarioFramework.CreateArmyStatTrigger(P2_Enemy_Air_Defense_01, ArmyBrains[ARMY_PLAYER], 'P2_Enemy_Air_Defense_01',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value= 20, Category = categories.AIR}})

	-- Create army stat trigger checking for a large player air count
	ScenarioFramework.CreateArmyStatTrigger(P2_Enemy_Air_Defense_02, ArmyBrains[ARMY_PLAYER], 'P2_Enemy_Air_Defense_02',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value= 40, Category = categories.AIR}})

	-- Create timer trigger sending the assault block on an attack patrol
	ScenarioFramework.CreateTimerTrigger (P2_AssaultBlock, 720)

	----------------------------------------------
	-- Primary Objective M2_obj10 - Secure the Facility
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M2_obj10 - Secure the Facility.')
	ScenarioInfo.M2_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.I02_M2_obj10_NAME,			-- title
		OpStrings.I02_M2_obj10_DESC,			-- description
		{
			AddArrow = true,
			MarkUnits = true,
			FlashVisible = true,
			ArrowOffset = 3.0,
			Units = ScenarioInfo.P2_ObjectiveUnits,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)

	ScenarioInfo.M2_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.I02_P2_BASE_SECONDARY_COMPLETED_010)
				ScenarioFramework.CreateTimerTrigger (P2_RevealColossus, 8)
			end
		end
	)


	-- This will trigger VO when any enemy units teleport across the chasm into any the of defined areas
	ScenarioFramework.CreateAreaTrigger(P2_PlayTeleportVO, 'P2_West_Teleport_Area',
			categories.LAND * categories.MOBILE, true, false, ArmyBrains[ARMY_ENEM01], 1, false)
	ScenarioFramework.CreateAreaTrigger(P2_PlayTeleportVO, 'P2_East_Teleport_Area',
			categories.LAND * categories.MOBILE, true, false, ArmyBrains[ARMY_ENEM01], 1, false)

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P2_ResearchSecondary_VO, 25)

	---- Timers to enable the assorted opais over time
	ScenarioFramework.CreateTimerTrigger (P2_EnableWest_WestTeleAttack, P2_EnableWest_WestTeleAttack_TIMER)
	ScenarioFramework.CreateTimerTrigger (P2_EnableEast_EastTeleAttack, P2_EnableEast_EastTeleAttack_TIMER)
	ScenarioFramework.CreateTimerTrigger (P2_EnableEast_MidTeleAttack, P2_EnableEast_MidTeleAttack_TIMER)
end

function P2_AssaultBlock()
	LOG('----- P2_AssaultBlock: Assault block attacks CDR')
	if ScenarioInfo.AssaultBlock and not ScenarioInfo.AssaultBlock:IsDead() then
		IssueAttack ({ScenarioInfo.AssaultBlock}, ScenarioInfo.PLAYER_CDR)
	end
end

function P2_Enemy_Air_Defense()
	LOG('----- P2_Enemy_Air_Defense')
	-- Enable air defense OpAI's for the enemy if player builds 'X' air units
	P2_Enemy_West_Air_Defense()
	P2_Enemy_East_Air_Defense()
end

function P2_Enemy_Air_Defense_01()
	LOG('----- P2_Enemy_Air_Defense_01')
	ScenarioInfo.P1_ENEM01_West_Air_Defense_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_East_Air_Defense_OpAI:		SetMaxActivePlatoons(2)
end

function P2_Enemy_Air_Defense_02()
	LOG('----- P2_Enemy_Air_Defense_02')
	ScenarioInfo.P1_ENEM01_West_Air_Defense_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ENEM01_East_Air_Defense_OpAI:		SetMaxActivePlatoons(3)
end

function P2_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.I02_RESEARCH_UNLOCK, P2_ResearchSecondary_Assign)
end

function P2_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.I02_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.I02_S1_obj10_NAME,	-- title
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
				ScenarioFramework.Dialogue(OpDialog.I02_RESEARCH_FOLLOWUP_ARMORENHANCER_010)
			end
		end
	)
end

function P2_FrontDefendersDestroyed_VO()
	 LOG('----- P2_FrontDefendersDestroyed_VO: Playing VO confirming that front defenders have been destroyed')

	 -- Note that the player has destroyed the Assault Block in front of the enemy base. If the
	 -- Assault Block ever gets downgraded, this VO may make less sense, as there are some sundry
	 -- defenders roaming about a bit more broadly in the general area.
	 ScenarioFramework.Dialogue(OpDialog.I02_P2_DEFENDERS_DESTROYED_010)
end

function P2_RevealColossus()
	if ScenarioInfo.ColossusRevealTriggered then
		return
	end

	ScenarioInfo.ColossusRevealTriggered = true

	-- sequence the reveal events
	ForkThread(
		function()
			LOG('----- P2 Reveal Colossus')
			-- Create the colossus, send it to the player's base area, and set a trigger to detect it (which will
			-- shut it down).
			ScenarioInfo.PlatoonColossus = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Colossus_Group', 'AttackFormation')

			-- get a handle to the Colossus
			ScenarioInfo.P2_Colossus = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_ENEM01]['P2_ENEM01_Colossus']

			-- We dont want the unit to be destroyed before the objective related to it is assigned.
			ProtectUnit(ScenarioInfo.P2_Colossus)

			-- launch the NIS such that when it is finished we will proceed with this forked thread
			OpNIS.NIS_COLOSSUS()

			-- give a few seconds and then launch the objectives dialog
			WaitSeconds(6.5)

			-- Unit health trigger on Colossus that will swap enemy army to player
			ScenarioFramework.CreateUnitHealthRatioTrigger(P2_ColossusDamaged, ScenarioInfo.P2_Colossus, .7, true, true)

			-- Set the Colossus flags back to normal, now that it is safe to kill it
			UnProtectUnit(ScenarioInfo.P2_Colossus)

			-- setup the Colossus for a controlled death sequence
			ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P2_Colossus, LaunchVictoryNIS)

			-- disable the two base managers, now that the focus of the op is on the Colossus.
			ScenarioInfo.ArmyBase_ENEM01_West_Base:BaseActive(false)
			ScenarioInfo.ArmyBase_ENEM01_East_Base:BaseActive(false)

			P2_AssignColossusObjective()
		end
	)
end

function P2_ColossusDamaged()
	---NOTE: tagged, problematic for unit cap, but deemed not worth fixing - bfricks 1/15/10
	-- VO from jaren informing the player he was able to acquire enemy control
	ScenarioFramework.Dialogue(OpDialog.I02_P2_FACILITY_SWAP_010)
	local enemyUnits = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE, 'P2_Playable_Area', ArmyBrains[ARMY_ENEM01])
	for k, unit in enemyUnits do
		if unit and not unit:IsDead() then
			ScenarioFramework.GiveUnitToArmy(unit, ARMY_PLAYER)
		end
	end
end

function P2_AssignColossusObjective()
	-- Colossus Objective VO
	ScenarioFramework.Dialogue(OpDialog.I02_M2_obj20_ASSIGN)

	----------------------------------------------
	-- Primary Objective M2_obj20 - Kill The Colossus
	----------------------------------------------
	LOG('----- P2: Assign Primary Objective M2_obj20 - Kill The Colossus.')
	ScenarioInfo.M2_obj20 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.I02_M2_obj20_NAME,			-- title
		OpStrings.I02_M2_obj20_DESC,			-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			AlwaysInRadar = true,
			Units = {ScenarioInfo.P2_Colossus},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj20)

	-- Colossus attack chain that will path towards the players starting location
	if ScenarioInfo.PlatoonColossus and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.PlatoonColossus) then
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.PlatoonColossus, 'P1_ENEM01_Colossus_Attack_Chain')
	end

	-- Create distance triggers from 3 markers that call a scan area for player units and kill function for the colossus
	ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P3_Colossus_Scan01, ScenarioInfo.P2_Colossus, 'P1_ENEM01_Colossus_Attack_Chain_01', 5)
	ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P3_Colossus_Scan02, ScenarioInfo.P2_Colossus, 'P1_ENEM01_Colossus_Attack_Chain_02', 5)
	ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P3_Colossus_Scan03, ScenarioInfo.P2_Colossus, 'P1_ENEM01_Colossus_Attack_Chain_03', 5)
	ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P3_Colossus_Scan04, ScenarioInfo.P2_Colossus, 'P1_ENEM01_Colossus_Attack_Chain_04', 5)
end

function HiddenObjective()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Master Tactician
	----------------------------------------------
	LOG('----- Assign Hidden Objective H1_obj10 - Master Tactician')
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',									-- type
		'complete',										-- status
		OpStrings.I02_H1_obj10_NAME,					-- title
		OpStrings.I02_H1_obj10_DESC,					-- description
		SimObjectives.GetActionIcon('build'),			-- Action
		{
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)
end

function P3_Colossus_Scan01()
	LOG('----- P3_Colossus_Scan01')
	IssueClearCommands({ScenarioInfo.P2_Colossus})
	WaitSeconds(0)

	local playerLandUnits = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS - categories.AIR, 'P3_Colossus_Scan01_Area', ArmyBrains[ARMY_PLAYER])
	local colossusPosition = ScenarioInfo.P2_Colossus:GetPosition()
	local sortedTargets = SortEntitiesByDistanceXZ( colossusPosition, playerLandUnits )
	for k, unit in sortedTargets do
		if not unit:IsDead() and not unit:IsEntityState('DoNotTarget') then
			ScenarioInfo.PlatoonColossus:AttackTarget( unit )
		end
	end
	IssueAggressiveMove( {ScenarioInfo.P2_Colossus}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Colossus_Attack_Chain_02' ) )
end

function P3_Colossus_Scan02()
	LOG('----- P3_Colossus_Scan02')
	IssueClearCommands({ScenarioInfo.P2_Colossus})
	WaitSeconds(5)
	local playerLandUnits = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS - categories.AIR, 'P3_Colossus_Scan02_Area', ArmyBrains[ARMY_PLAYER])
	local colossusPosition = ScenarioInfo.P2_Colossus:GetPosition()
	local sortedTargets = SortEntitiesByDistanceXZ( colossusPosition, playerLandUnits )
	for k, unit in sortedTargets do
		if not unit:IsDead() and not unit:IsEntityState('DoNotTarget') then
			ScenarioInfo.PlatoonColossus:AttackTarget( unit )
		end
	end
	IssueAggressiveMove( {ScenarioInfo.P2_Colossus}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Colossus_Attack_Chain_03' ) )
end

function P3_Colossus_Scan03()
	LOG('----- P3_Colossus_Scan03')
	IssueClearCommands({ScenarioInfo.P2_Colossus})
	WaitSeconds(5)
	local playerLandUnits = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS - categories.AIR, 'P3_Colossus_Scan03_Area', ArmyBrains[ARMY_PLAYER])
	local colossusPosition = ScenarioInfo.P2_Colossus:GetPosition()
	local sortedTargets = SortEntitiesByDistanceXZ( colossusPosition, playerLandUnits )
	for k, unit in sortedTargets do
		if not unit:IsDead() and not unit:IsEntityState('DoNotTarget') then
			ScenarioInfo.PlatoonColossus:AttackTarget( unit )
		end
	end
	IssueAggressiveMove( {ScenarioInfo.P2_Colossus}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_Colossus_Attack_Chain_04' ) )
end

function P3_Colossus_Scan04()
	LOG('----- P3_Colossus_Scan04')
	IssueClearCommands({ScenarioInfo.P2_Colossus})
	WaitSeconds(5)
	local playerLandUnits = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS - categories.AIR, 'P3_Colossus_Scan04_Area', ArmyBrains[ARMY_PLAYER])
	local colossusPosition = ScenarioInfo.P2_Colossus:GetPosition()
	local sortedTargets = SortEntitiesByDistanceXZ( colossusPosition, playerLandUnits )
	for k, unit in sortedTargets do
		if not unit:IsDead() and not unit:IsEntityState('DoNotTarget') then
			ScenarioInfo.PlatoonColossus:AttackTarget( unit )
		end
	end
	if ScenarioInfo.PLAYER_CDR and not ScenarioInfo.PLAYER_CDR:IsDead() then
		ScenarioInfo.PlatoonColossus:AttackTarget( ScenarioInfo.PLAYER_CDR )
		-- Call VO warning that the colossus is seeking out player CDR
		ScenarioFramework.CreateArmyIntelTrigger(P1_PlayColossusWarningVO, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		 categories.uix0111, true, ArmyBrains[ARMY_ENEM01])
	end
end

function P1_PlayColossusWarningVO()
	ScenarioFramework.Dialogue(OpDialog.I02_COLOSSUS_ATTACK_CDR)
end

function P2_PlayTeleportVO()
	LOG('----- P2_PlayTeleportVO')
	if not ScenarioInfo.P2_TeleportVOTriggerAdded then
		ScenarioInfo.P2_TeleportVOTriggerAdded = true
		-- Play VO pointing out that the enemy is using unit teleport ability
		ScenarioFramework.Dialogue(OpDialog.I02_P2_TELEPORT_WARNING_010)
	end
end

function AdjustTeleportRange(platoon)
	-- Increase enemy land unit teeport range enabling them to cross the chasm
	for k, unit in platoon:GetPlatoonUnits() do
		if unit and not unit:IsDead() then
			unit:SetTeleportRange(200)
		end
	end
end

---------------------------------------------------------------------
-- BASE AND OPAI SETUP:
---------------------------------------------------------------------
function P2_AISetup_Enemy_West()
	-- this is responsible for all PRE-NIS setup work

	LOG('----- P2_AISetup_Enemy_West: Setting up the West enemy base')
	----- West Base Manager -----
	local levelTable_ENEM01_West_Base = {
		P2_ENEM01_West_Base_100 = 100,
		P2_ENEM01_West_Base_90 = 90,
		P2_ENEM01_West_Base_80 = 80,
	}

	-- setup base manager - will create factory units
	ScenarioInfo.ArmyBase_ENEM01_West_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_West_Base',
		 'P2_ENEM01_West_Base_Marker', 50, levelTable_ENEM01_West_Base)
	ScenarioInfo.ArmyBase_ENEM01_West_Base:StartNonZeroBase(0)

	-- create engineers - that will be available post NIS
	ScenarioInfo.ArmyBase_ENEM01_West_Engineers = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_WestBase_Init_Eng')
end

function P2_Enemy_West_Air_Defense()
	ScenarioInfo.P1_ENEM01_West_Air_Defense_OpAI		= ScenarioInfo.ArmyBase_ENEM01_West_Base:AddOpAI('AirFightersIlluminate', 'P1_ENEM01_West_Air_Defense_OpAI', {} )
	local P1_ENEM01_West_Air_Defense_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_West_Air_Defense', },}
	ScenarioInfo.P1_ENEM01_West_Air_Defense_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_West_Air_Defense_OpAI_Data )
	ScenarioInfo.P1_ENEM01_West_Air_Defense_OpAI:		SetMaxActivePlatoons(2)
end

function P2_Enemy_West_Teleport()
	-- update the number of engineers we use
	ScenarioInfo.ArmyBase_ENEM01_West_Base:SetEngineerCount(3)

	-- add our existing engineers
	IssueClearCommands(ScenarioInfo.ArmyBase_ENEM01_West_Engineers)
	for k, v in ScenarioInfo.ArmyBase_ENEM01_West_Engineers do
		if v and not v:IsDead() then
			ScenarioInfo.ArmyBase_ENEM01_West_Base:AddEngineer(v)
		end
	end

	----- OpAI -----
	local MTruckChild = {
		'WEST_MTruckChild',
		{
			{ 'uil0104', 2 },
			{ 'uil0101', 2 },
		},
	}

	---- basic land attack, west teleport
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_West_Base:GenerateOpAIFromPlatoonTemplate(MTruckChild, 'P1_ENEM01_West_TeleWest_01_OpAI', {} )

	-- FormCallBack for the teleport route generator
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI. 		FormCallback:Add(P2_Enemy_Teleport_Route_Generator_West)

	-- Adjust teleport range
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI.		FormCallback:Add(AdjustTeleportRange)

	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetAttackDelay(P1_ENEM01_West_TeleWest_01_OpAI_DELAY)
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetMaxActivePlatoons(6)
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		Disable()
end

function P2_Enemy_Teleport_Route_Generator_West()

	local rndLoc = Random (1, 5)

	if rndLoc == 1 then
		P2_Enemy_West_Teleport_01()
	elseif rndLoc == 2 then
		P2_Enemy_West_Teleport_02()
	elseif rndLoc == 3 then
		P2_Enemy_West_Teleport_03()
	elseif rndLoc == 4 then
		P2_Enemy_West_Teleport_04()
	elseif rndLoc == 5 then
		P2_Enemy_West_Teleport_05()
	end
end

function P2_Enemy_West_Teleport_01()
	LOG('----- P2_Enemy_West_Teleport_01')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_West_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackWest_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_SouthEast_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_West_Teleport_02()
	LOG('----- P2_Enemy_West_Teleport_02')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_West_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackWest_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_NorthEast_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_West_Teleport_03()
	LOG('----- P2_Enemy_West_Teleport_03')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_West_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackWest_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_NorthWest_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_West_Teleport_04()
	LOG('----- P2_Enemy_West_Teleport_04')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_West_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackWest_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_SouthWest_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_West_Teleport_05()
	LOG('----- P2_Enemy_West_Teleport_05')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_West_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_West_AttackWest_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_East_TeleDest01' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_AISetup_Enemy_East()
	-- this is responsible for all PRE-NIS setup work

	LOG('----- P2_AISetup_Enemy_East: Setting up the East enemy base')
	----- East Base Manager -----
	local levelTable_ENEM01_East_Base = {
		P2_ENEM01_East_Base_100 = 100,
		P2_ENEM01_East_Base_90 = 90,
		P2_ENEM01_East_Base_80 = 80,
	}
	-- setup base manager - will create factory units
	ScenarioInfo.ArmyBase_ENEM01_East_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_East_Base',
		 'P2_ENEM01_East_Base_Marker', 50, levelTable_ENEM01_East_Base)
	ScenarioInfo.ArmyBase_ENEM01_East_Base:StartNonZeroBase(0)

	-- create engineers - that will be available post NIS
	ScenarioInfo.ArmyBase_ENEM01_East_Engineers = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_EastBase_Init_Eng')
end

function P2_Enemy_East_Air_Defense()
	ScenarioInfo.P1_ENEM01_East_Air_Defense_OpAI		= ScenarioInfo.ArmyBase_ENEM01_East_Base:AddOpAI('AirFightersIlluminate', 'P1_ENEM01_East_Air_Defense_OpAI', {} )
	local P1_ENEM01_East_Air_Defense_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_East_Air_Defense', },}
	ScenarioInfo.P1_ENEM01_East_Air_Defense_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_East_Air_Defense_OpAI_Data )
	ScenarioInfo.P1_ENEM01_East_Air_Defense_OpAI:		SetMaxActivePlatoons(2)
end

function P2_Enemy_Middle_Teleport()

	----- OpAI -----
	local TankChild = {
		'EAST_TankChild',
		{
			{ 'uil0101', 2 },
			{ 'uil0103', 2 },
		},
	}

	---- basic land attack, middle teleport
	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI			= ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(TankChild, 'P1_ENEM01_East_TeleMid_01_OpAI', {} )
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Mid_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_Mid_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}

	-- Adjust teleport range
	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI.		FormCallback:Add(AdjustTeleportRange)

	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI:		SetAttackDelay(P1_ENEM01_East_TeleMid_01_OpAI_DELAY)
	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI:		Disable()
end

function P2_Enemy_East_Teleport()
	-- update the number of engineers we use
	ScenarioInfo.ArmyBase_ENEM01_East_Base:SetEngineerCount(3)

	-- add our existing engineers
	IssueClearCommands(ScenarioInfo.ArmyBase_ENEM01_East_Engineers)
	for k, v in ScenarioInfo.ArmyBase_ENEM01_East_Engineers do
		if v and not v:IsDead() then
			ScenarioInfo.ArmyBase_ENEM01_East_Base:AddEngineer(v)
		end
	end

	----- OpAI -----
	local ABotChild = {
		'EAST_MTruckChild',
		{
			{ 'uil0103', 4 },
		},
	}

	---- basic land attack, east teleport
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(ABotChild, 'P1_ENEM01_East_TeleEast_01_OpAI', {} )

	-- FormCallBack for the teleport route generator
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI. 		FormCallback:Add(P2_Enemy_Teleport_Route_Generator_East)

	-- Adjust teleport range
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI.		FormCallback:Add(AdjustTeleportRange)

	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetMaxActivePlatoons(4)
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetChildCount(2)
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetAttackDelay(P1_ENEM01_East_TeleEast_01_OpAI_DELAY)
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		Disable()
end

function P2_Enemy_Teleport_Route_Generator_East()

	local rndLoc = Random (1, 5)

	if rndLoc == 1 then
		P2_Enemy_East_Teleport_01()
	elseif rndLoc == 2 then
		P2_Enemy_East_Teleport_02()
	elseif rndLoc == 3 then
		P2_Enemy_East_Teleport_03()
	elseif rndLoc == 4 then
		P2_Enemy_East_Teleport_04()
	elseif rndLoc == 5 then
		P2_Enemy_East_Teleport_05()
	end
end

function P2_Enemy_East_Teleport_01()
	LOG('----- P2_Enemy_East_Teleport_01')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_East_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackEast_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_SouthWest_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_East_Teleport_02()
	LOG('----- P2_Enemy_East_Teleport_02')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_East_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackEast_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_NorthWest_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_East_Teleport_03()
	LOG('----- P2_Enemy_East_Teleport_03')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_East_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackEast_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_SouthEast_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_East_Teleport_04()
	LOG('----- P2_Enemy_East_Teleport_04')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_East_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackEast_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_NorthEast_TeleDest' },	-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_Enemy_East_Teleport_05()
	LOG('----- P2_Enemy_East_Teleport_05')
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackApproach_Chain_01' },		-- start patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_East_TeleDest' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_East_AttackEast_Chain_01' },			-- mid patrol chain
			{ BehaviorName = 'TeleportPlatoon',  TeleportMarkerName = 'P2_ENEM01_West_TeleDest01' },		-- teleport destination marker
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_Final_Teleport_Chain_01' },			-- final patrol chain
		},
	}
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
end

function P2_EnableWest_WestTeleAttack()
	LOG('----- P2: Turning on Westbase telewest opai')
	ScenarioInfo.P1_ENEM01_West_TeleWest_01_OpAI:Enable()
end

function P2_EnableWest_MidTeleAttack()
	LOG('----- P2: Turning on Westbase telemid opai')
	ScenarioInfo.P1_ENEM01_West_TeleMid_01_OpAI:Enable()
end

function P2_EnableEast_EastTeleAttack()
	LOG('----- P2: Turning on Eastbase teleeast opai')
	ScenarioInfo.P1_ENEM01_East_TeleEast_01_OpAI:Enable()
end

function P2_EnableEast_MidTeleAttack()
	LOG('----- P2: Turning on Eastbase telemid opai')
	ScenarioInfo.P1_ENEM01_East_TeleMid_01_OpAI:Enable()
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function LaunchVictoryNIS(unit)
	ForkThread(
		function()
			-- create an empty list to use
			ScenarioInfo.AssignedObjectives.VictoryCallbackList = {}

			-- for each specific hidden objective you to complete
			if MobileUnitThreshold == true then
				table.insert(ScenarioInfo.AssignedObjectives.VictoryCallbackList, HiddenObjective )
			end

			OpNIS.NIS_VICTORY(unit)
		end
	)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
end

function OnShiftF4()
	ScenarioFramework.SetPlayableArea('P2_Playable_Area', false)
	import('/lua/system/Utilities.lua').UserConRequest('SallyShears')

	-- Create the facility structure, flag to be protected.
	ScenarioInfo.P2_ENEM01_Experimental_Factory = ScenarioUtils.CreateArmyUnit('ARMY_CIV01', 'P2_ENEM01_Experimental_Factory')
	ScenarioInfo.P2_ENEM01_Experimental_Factory:SetDoNotTarget(true)
	ProtectUnit(ScenarioInfo.P2_ENEM01_Experimental_Factory)

	P2_RevealColossus()
end

function OnShiftF5()
	LaunchVictoryNIS(ScenarioInfo.P2_Colossus)
end

-- function OnShiftF5()
-- 	ScenarioFramework.SetPlayableArea('P2_Playable_Area', false)
-- 	import('/lua/system/Utilities.lua').UserConRequest('SallyShears')

-- 	ScenarioInfo.PlatoonColossus = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Colossus_Group', 'AttackFormation')

-- 	-- get a handle to the Colossus
-- 	ScenarioInfo.P2_Colossus = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_ENEM01]['P2_ENEM01_Colossus']

-- 	-- Unit health trigger on Colossus that will swap enemy army to player
-- 	ScenarioFramework.CreateUnitHealthRatioTrigger(P2_ColossusDamaged, ScenarioInfo.P2_Colossus, .7, true, true)

-- 	-- Set the Colossus flags back to normal, now that it is safe to kill it
-- 	UnProtectUnit(ScenarioInfo.P2_Colossus)

-- 	-- setup the Colossus for a controlled death sequence
-- 	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P2_Colossus, LaunchVictoryNIS)

-- 	P2_AssignColossusObjective()
-- end


