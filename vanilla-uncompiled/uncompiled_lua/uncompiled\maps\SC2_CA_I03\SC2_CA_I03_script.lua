---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_I03/SC2_CA_I03_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_I03/SC2_CA_I03_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_I03/SC2_CA_I03_OpNIS.lua')
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
ScenarioInfo.ARMY_ALLY01 = 3
ScenarioInfo.ARMY_CIVL01 = 4

ScenarioInfo.AssignedObjectives = {}

-- How many experimentals will be in each wing? (necessary for some safety checks)
-- ***********THIS MUST BE SET TO MATCH NUMBER OF EXPS***********
ScenarioInfo.P1_Exp_ExperimentalsPerSide = 5

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01
local ARMY_CIVL01 = ScenarioInfo.ARMY_CIVL01

local GateMaxHeath			= 350000	-- Max health value of the north barge blockade unit

local HiddenObjectiveCount	= 0
local HiddenObjCaptured		= 0
local ShieldObjDestroyed	= 0

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------

local LandAttack_Delay			= 0			-- land attack delay between platoons triggered after the control centers are both down.
local AirAttack_Delay			= 70		-- air attack delay between platoons sent toward the player's starting area from both the north and south outpost

local LandPatrol_01_DELAY		= 70		-- UEF land patrol 1 attack delay on player
local LandPatrol_02_DELAY		= 140		-- UEF land patrol 2 attack delay on player

local PlayerLand_Response 		= { Count = 50, Bombers = 8 }	-- enemy bomber platoon size that are created based on total offense mobile land units player has built
local PlayerExp_Response 		= { Count = 1, Gunships = 4 }	-- enemy gunship platoon size that are created based on total experimental units player has built
local PlayerAir_Response		= { Count = 15, Fighters = 6 }	-- enemy fighter/bomber platoon size that are created based on total air units player has built
local PlayerTML_Response		= { Count = 1, Bombers = 2 }	-- enemy bomber platoon size that are created based on total tactical missile launcher 'base' units player has built

-- unique custom platoon name
local LandAttackCustom = {'UEF_LandAttackCustom',
	{
		{ 'uul0101', 2 },	-- UEF tanks
		{ 'uul0103', 2 }, 	-- UEF assault bots
	},
}

-- unique custom platoon name
local AirAttackBombers = {'UEF_AirAttackBombers',
	{
		{ 'uua0101', 1 },	-- UEF fighters
		{ 'uua0102', 3 },	-- UEF bombers
	},
}

-- unique custom platoon name
local AirAttackGunships = {'UEF_AirAttackGunships',
	{
		{ 'uua0103', 2 },	-- UEF gunships
	},
}

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------

-- P1: Enemy attack delays:			Time delay between the enemy attacks that occur throughout the OP.
--									The land attack delay begins when both prison control centers have
--									been destroyed. These should be light land attacks and increasing
--									this delay to a large value (>12) will render this attack ineffective
--									unless the custom platoon is modified first.
--									The air attack delay begins when the OP starts and are composed of
--									custom platoons sent from the North and South enemy outposts. The
--									OpAI's managing these attacks are disabled if the player destroys
--									the corresponding shield generator.
--									FUNCTION: P1_ENEM01_Setup()
--									TUNE: ... _Delay
--
-- P1: Land attack, Prison:			Light land attacks that begin after both prison control centers are
--									destroyed. Given a small patrol chain surrounding the prison structure
--									consisting of tanks and assault bots. Avoid the use of MML's as they
--									may be too much for the player.
--									FUNCTION: P1_ENEM01_Setup()
--									TUNE: LandAttackCustom
--
-- P1: Air attack, Outposts:		Light air attacks that begin on OP start and are sent on a patrol chain
--									around the player starting area. These attacks consist of bombers and
--									fighters sent from the north and south outposts until their
--									corresponding shield generator is killed.
--									FUNCTION: P1_ENEM01_Setup()
--									TUNE: AirAttackCustom
--
-- P1: Adaptive Enemy Responses:	Platoons that are created to attack a specific group or unit
--									that the player has built to prevent breaking of the OP. Each
--									response should not be overwhelming to the player, but should
--									deal a significant amount of damage on that particular target.
--									If all targets are eliminated the platoons should return to a
--									patrol route within the prison.
--									FUNCTION: P1_AdaptiveResponseThread()
--									TUNE: --- _Response

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.I03_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.I03_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_ALLY01,	ScenarioGameTuning.color_CIV_I03)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CIVL01,	ScenarioGameTuning.color_UEF_ENEM01_I03)
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

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_Group1 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Transport_Group1')
	ScenarioInfo.INTRONIS_Group2 = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Transport_Group2')
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group1, 2)
	ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.INTRONIS_Group2, 2)
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')

	ScenarioInfo.INTRONIS_Group1Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')
	ScenarioInfo.INTRONIS_Group2Transport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_02')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_03')

	-- Set custom name for player CDR and death trigger
	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Thalia)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Inital base structures created around the Intro NIS security station the player captures
	ScenarioInfo.INTRONIS_Outpost = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'Middle_Outpost')

	-- Set health values to 1 so they will die quickly during the NIS
	for k, unit in ScenarioInfo.INTRONIS_Outpost do
		unit:SetMaxHealth(100)
		unit:AdjustHealth(unit, 100)
	end

	-- Initial enemy group of tanks that will attack the player at the beginning of the OP
	ScenarioInfo.P1_ENEM01_Init_Land_Platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Init_Land_Attack', 'AttackFormation')

	-- Second enemy group of land that patrols and eventually attacks based on a timer
	ScenarioInfo.P1_ENEM01_Land_Patrol_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Land_Patrol_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Land_Patrol_01, 'ENEM01_P1_Land_Patrol_01')

	-- Third enemy group of land that patrols and eventually attacks based on a timer
	ScenarioInfo.P1_ENEM01_Land_Patrol_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Land_Patrol_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Land_Patrol_02, 'ENEM01_P1_Land_Patrol_02')

	-- Create the Point Defense group outside the Prison Base Manager so they are not rebuilt.
	ScenarioInfo.P1_ENEM01_Init_PD = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_PD')

	-- Create the INTRO_NIS AC-1000s
	ScenarioInfo.INTRONIS_AC1000_West = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'INTRONIS_AC1000_West')
	ScenarioInfo.INTRONIS_AC1000_East = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'INTRONIS_AC1000_East')

	-- setup all units for the gate
	CreateGateUnits()

	-- Prison structure to be captured
	ScenarioInfo.P1_ENEM01_Prison = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_ENEM01_Prison')
	ScenarioInfo.P1_ENEM01_Prison:SetCustomName(ScenarioGameNames.UNIT_SCB2303)
	ProtectUnit(ScenarioInfo.P1_ENEM01_Prison)
	ScenarioInfo.P1_ENEM01_Prison:SetCapturable(true)

	-- Initial Intel unit captured at OP start
	ScenarioInfo.P1_ENEM01_Intel = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Intel')
	ScenarioInfo.P1_ENEM01_Intel:SetCustomName(ScenarioGameNames.UNIT_SCB2301)
	ProtectUnit(ScenarioInfo.P1_ENEM01_Intel)
	ScenarioInfo.P1_ENEM01_Intel:SetCapturable(true)

	-- North Hidden objective structure
	ScenarioInfo.P1_ENEM01_Hidden_North = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_ENEM01_Hidden_North')
	ScenarioInfo.P1_ENEM01_Hidden_North:SetCustomName(ScenarioGameNames.UNIT_SCB2301)
	ProtectUnit(ScenarioInfo.P1_ENEM01_Hidden_North)
	ScenarioInfo.P1_ENEM01_Hidden_North:SetCapturable(true)
	ScenarioFramework.CreateUnitCapturedTrigger(P1_HiddenNorthCaptured, nil, ScenarioInfo.P1_ENEM01_Hidden_North)

	-- South Hidden objective structure
	ScenarioInfo.P1_ENEM01_Hidden_South = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_ENEM01_Hidden_South')
	ScenarioInfo.P1_ENEM01_Hidden_South:SetCustomName(ScenarioGameNames.UNIT_SCB2301)
	ProtectUnit(ScenarioInfo.P1_ENEM01_Hidden_South)
	ScenarioInfo.P1_ENEM01_Hidden_South:SetCapturable(true)
	ScenarioFramework.CreateUnitCapturedTrigger(P1_HiddenSouthCaptured, nil, ScenarioInfo.P1_ENEM01_Hidden_South)

	----------------------------------
	-- Set up enemy bases and units --
	----------------------------------

	-- Initial fighter patrols. Keep handles to pass to Opai's.
	local airPlatoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Init_AirDef_West', 'AttackFormation')
	local airPlatoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Init_AirDef_South', 'AttackFormation')
	local airPlatoon3 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Init_AirDef_East', 'AttackFormation')

	ScenarioFramework.SetPlatoonVeterancyLevel(airPlatoon1, 5)
	ScenarioFramework.SetPlatoonVeterancyLevel(airPlatoon2, 5)
	ScenarioFramework.SetPlatoonVeterancyLevel(airPlatoon3, 5)

	for k, unit in airPlatoon1:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute('ENEM01_P1_AirDefense_West'))

		-- for any of these init air units, add this trigger for some special case warning VO
		---NOTE: future air units shouldn't need this, on the assumption that if a unit died the player either got the warning, or didnt need it - bfricks 10/13/09
		ScenarioFramework.CreateUnitKilledUnitTrigger(P1_GateDirectAssault_VO, unit)
	end
	for k, unit in airPlatoon2:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute('ENEM01_P1_AirDefense_South'))

		-- for any of these init air units, add this trigger for some special case warning VO
		---NOTE: future air units shouldn't need this, on the assumption that if a unit died the player either got the warning, or didnt need it - bfricks 10/13/09
		ScenarioFramework.CreateUnitKilledUnitTrigger(P1_GateDirectAssault_VO, unit)
	end
	for k, unit in airPlatoon3:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute('ENEM01_P1_AirDefense_East'))

		-- for any of these init air units, add this trigger for some special case warning VO
		---NOTE: future air units shouldn't need this, on the assumption that if a unit died the player either got the warning, or didnt need it - bfricks 10/13/09
		ScenarioFramework.CreateUnitKilledUnitTrigger(P1_GateDirectAssault_VO, unit)
	end

	-- Create tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')

	--North Shield Objective structure
	ScenarioInfo.ObjectiveShield_North = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Shield_North')
	ScenarioFramework.CreateUnitDeathTrigger(P1_PlayerDestroyedNorthShield, ScenarioInfo.ObjectiveShield_North)

	--South Shield Objective structure
	ScenarioInfo.ObjectiveShield_South = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Shield_South')
	ScenarioFramework.CreateUnitDeathTrigger(P1_PlayerDestroyedSouthShield, ScenarioInfo.ObjectiveShield_South)

	--Table that holds the shield outpost units
	ScenarioInfo.ShieldOutpostUnits = {}

	table.insert(ScenarioInfo.ShieldOutpostUnits, ScenarioInfo.ObjectiveShield_North)
	table.insert(ScenarioInfo.ShieldOutpostUnits, ScenarioInfo.ObjectiveShield_South)
end

function P1_Main()

	-- Flash intel for player on the prison gate
	ScenarioFramework.CreateVisibleAreaLocation( 5, ScenarioUtils.MarkerToPosition( 'Prison_Gate_Marker' ), 1, ArmyBrains[ARMY_PLAYER] )

	--------------------------------
	-- Experimental AC-1000 Setup --
	--------------------------------

	LOG('----- P1: Exps: Initial setup of AC-1000 experimentals')

	-- Flags the exp setup will use to judge where to send units
	ScenarioInfo.P1_PlayerAtNorth = false
	ScenarioInfo.P1_PlayerAtSouth = false

	-- Create the table we will store a shallow list of units in.
	ScenarioInfo.P1_EnemyExperimentals_West = {}
	ScenarioInfo.P1_EnemyExperimentals_East = {}

	-- Spawn each experimental, place them in the table, and give them a death trigger
	-- which will oversee a replacement being made.
	for i = 1, 5 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'ENEM01_P1_Exp_Area01_0' .. i, 'AttackFormation' )
		table.insert(ScenarioInfo.P1_EnemyExperimentals_West, platoon)
		ScenarioFramework.PlatoonPatrolChain(platoon, 'ENEM01_P1_Exp_Patrol_Area01_0' .. i)
		ScenarioFramework.CreatePlatoonDeathTrigger(
			function(platoon)
				LOG('----- P1: West platoon died')
				-- When this platoon dies, perform a reorder for the West.
				P1_Exp_ReorderMembers(ScenarioInfo.P1_EnemyExperimentals_West, platoon)
			end
			,
			platoon
		)

		for index, unit in platoon:GetPlatoonUnits() do
			-- for any of these init air units, add this trigger for some special case warning VO
			---NOTE: future air units shouldn't need this, on the assumption that if a unit died the player either got the warning, or didnt need it - bfricks 10/13/09
			ScenarioFramework.CreateUnitKilledUnitTrigger(P1_GateDirectAssault_VO, unit)
		end
	end
	for i = 1, 5 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'ENEM01_P1_Exp_Area02_0' .. i, 'AttackFormation' )
		table.insert(ScenarioInfo.P1_EnemyExperimentals_East, platoon)
		ScenarioFramework.PlatoonPatrolChain(platoon, 'ENEM01_P1_Exp_Patrol_Area02_0' .. i)
		ScenarioFramework.CreatePlatoonDeathTrigger(
			function(platoon)
				LOG('----- P1: East platoon died')
				-- When this platoon dies, perform a reorder for the East.
				P1_Exp_ReorderMembers(ScenarioInfo.P1_EnemyExperimentals_East, platoon)
			end
			,
			platoon
		)

		for index, unit in platoon:GetPlatoonUnits() do
			-- for any of these init air units, add this trigger for some special case warning VO
			---NOTE: future air units shouldn't need this, on the assumption that if a unit died the player either got the warning, or didnt need it - bfricks 10/13/09
			ScenarioFramework.CreateUnitKilledUnitTrigger(P1_GateDirectAssault_VO, unit)
		end
	end

	--Enemy base setup function
	P1_ENEM01_Setup()

	----------------------------------------------
	-- Primary Objective M1_obj10 - The Big House
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - The Big House.')
	ScenarioInfo.M1_obj10 = SimObjectives.Capture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.I03_M1_obj10_NAME,			-- title
		OpStrings.I03_M1_obj10_DESC,			-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			ArrowOffset = -2.0,
			ArrowSize = 0.8,
			Units = {ScenarioInfo.P1_ENEM01_Prison},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioInfo.ArmyBase_EnemMain:BaseActive(false)
				ScenarioInfo.ArmyBase_EnemNorth:BaseActive(false)
				ScenarioInfo.ArmyBase_EnemSouth:BaseActive(false)
				ForkThread(OpNIS.NIS_VICTORY)
			end
		end
	)

	-- Enable the air attack patrols on the player
	ScenarioInfo.P1_ENEM01_North_Base_OpAI:	Enable()
	ScenarioInfo.P1_ENEM01_South_Base_OpAI:	Enable()

	-- Timer trigger for enemy west land patrol to attack player
	ScenarioFramework.CreateTimerTrigger (P1_ENEM01_LandPatrol_01, LandPatrol_01_DELAY)

	-- Timer trigger for enemy southwest land patrol to attack player
	ScenarioFramework.CreateTimerTrigger (P1_ENEM01_LandPatrol_02, LandPatrol_02_DELAY)

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_Assign_VO, 25)

	-- This triggers VO telling the player that based on the intel they should bring mobile AA
	ScenarioFramework.Dialogue(OpDialog.I03_EXP_ADVICE_030)

	-- If required, call for the Lure (checks player spotting the AC1000s)
	ScenarioFramework.CreateArmyIntelTrigger(P1_LureSecondary_Assign, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		 categories.uux0102, true, ArmyBrains[ARMY_ENEM01])

	-- If required, call for the Lure (checks player entering the North Outpost zone)
	ScenarioFramework.CreateAreaTrigger(P1_LureSecondary_Assign, 'North_Outpost_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- If required, call for the Lure (checks player entering the South Outpost zone)
	ScenarioFramework.CreateAreaTrigger(P1_LureSecondary_Assign, 'South_Outpost_Area',
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)

	-- Calls the gate trigger creation
	P1_GateTriggerAssign()
	-- Calls the initial land attack function
	P1_InitLandAttack()
	-- forks the gunship leash check
	ForkThread(P1_ExperimentalGunship_Leash)
	-- forks the adaptive response thread
	ForkThread(P1_AdaptiveResponseThread)
end

function P1_ENEM01_LandPatrol_01()
	LOG('----- P1_ENEM01_LandPatrol_01: West land patrol enroute to player starting location')
	if ScenarioInfo.P1_ENEM01_Land_Patrol_01 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_Land_Patrol_01) then
		IssueClearCommands(ScenarioInfo.P1_ENEM01_Land_Patrol_01:GetPlatoonUnits())
		IssueFormMove( ScenarioInfo.P1_ENEM01_Land_Patrol_01, ScenarioUtils.MarkerToPosition( 'ARMY_PLAYER' ), 'AttackFormation', 0 )
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Land_Patrol_01, 'ENEM01_P1_Init_Land_Patrol')
	end
end

function P1_ENEM01_LandPatrol_02()
	LOG('----- P1_ENEM01_LandPatrol_02: Southwest land patrol enroute to player starting location')
	if ScenarioInfo.P1_ENEM01_Land_Patrol_02 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_Land_Patrol_02) then
		IssueClearCommands(ScenarioInfo.P1_ENEM01_Land_Patrol_02:GetPlatoonUnits())
		IssueFormMove( ScenarioInfo.P1_ENEM01_Land_Patrol_02, ScenarioUtils.MarkerToPosition( 'ARMY_PLAYER' ), 'AttackFormation', 0 )
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Land_Patrol_02, 'ENEM01_P1_Init_Land_Patrol')
	end
end

function P1_AdaptiveResponseThread()
	-- Response flags
	ScenarioInfo.RespondingToLand = false
	ScenarioInfo.RespondingToExp = false
	ScenarioInfo.RespondingToAir = false
	ScenarioInfo.RespondingToTML = false

	while not ScenarioInfo.OpEnded do
		-- Collect information about all the players units --
		-- This retreives the total mobile land units the player has that are considered offensive
		local playerLandCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uil0101 + categories.uil0103 + categories.uil0104 + categories.uil0202 )
		-- This retreives the total air units the player has
		local playerAirCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.AIR * categories.ILLUMINATE )
		-- This retreives the total experimental units the player has
		local playerExpCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL)
		-- This retrieves the total 'base' tactical missile launcher units the player has
		local playerTMLCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uib0106)

		-- This is the enemy response based on the player's total mobile land units built
		if playerLandCount > PlayerLand_Response.Count and not ScenarioInfo.RespondingToLand then
			ScenarioInfo.RespondingToLand = true
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i=1, PlayerLand_Response.Bombers do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Response_Bomber')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			end
			ScenarioFramework.CreatePlatoonDeathTrigger(function() ScenarioInfo.RespondingToLand = false end, platoon)
			local playerLand = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uil0101 + categories.uil0103 + categories.uil0104 + categories.uil0202, false )
			for k, v in playerLand do
				LOG('----- P1: Adaptive Player Land Response Triggered')
				IssueAttack(platoon:GetPlatoonUnits(), v)
			end
			-- After the land unit(s) have been destroyed move platoon to a marker chain around the base
			ScenarioFramework.PlatoonPatrolChain (platoon, 'ALLY01_P1_AirPatrol_Prison')
		end

		-- This is the enemy response based on the player's total experimental units built
		if playerExpCount >= PlayerExp_Response.Count and not ScenarioInfo.RespondingToExp then
			ScenarioInfo.RespondingToExp = true
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i=1, PlayerExp_Response.Gunships do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Response_Gunship')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			end
			ScenarioFramework.CreatePlatoonDeathTrigger(function() ScenarioInfo.RespondingToExp = false end, platoon)
			local playerExp = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.EXPERIMENTAL, false )
			for k, v in playerExp do
				LOG('----- P1: Adaptive Player Experimental Response Triggered')
				IssueAttack(platoon:GetPlatoonUnits(), v)
			end
			-- After the experimental(s) have been destroyed move platoon to a marker chain around the base
			ScenarioFramework.PlatoonPatrolChain (platoon, 'ALLY01_P1_AirPatrol_Prison')
		end

		-- This is the enemy based dependant on the player's total air units built
		if playerAirCount > PlayerAir_Response.Count and not ScenarioInfo.RespondingToAir then
			ScenarioInfo.RespondingToAir = true
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i=1, PlayerAir_Response.Fighters do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Response_Fighter')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			end
			ScenarioFramework.CreatePlatoonDeathTrigger(function() ScenarioInfo.RespondingToAir = false end, platoon)
			local playerAir = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.AIR * categories.ILLUMINATE, false )
			for k, v in playerAir do
				LOG('----- P1: Adaptive Player Air Response Triggered')
				IssueAttack(platoon:GetPlatoonUnits(), v)
			end
			-- After the experimental(s) have been destroyed move platoon to a marker chain around the base
			ScenarioFramework.PlatoonPatrolChain (platoon, 'ENEM01_P1_AirDefense_South')
		end

		-- This is the enemy based dependant on the player's total tactical missile launcher 'base' units built
		if playerTMLCount > PlayerTML_Response.Count and not ScenarioInfo.RespondingToTML then
			ScenarioInfo.RespondingToTML = true
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i=1, PlayerTML_Response.Bombers do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Response_Bomber')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			end
			ScenarioFramework.CreatePlatoonDeathTrigger(function() ScenarioInfo.RespondingToTML = false end, platoon)
			local playerTML = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uib0106, false )
			for k, v in playerTML do
				LOG('----- P1: Adaptive Player TML Response Triggered')
				IssueAttack(platoon:GetPlatoonUnits(), v)
			end
			-- After the TML(s) have been destroyed move platoon to a marker chain around the base
			ScenarioFramework.PlatoonPatrolChain (platoon, 'ENEM01_P1_AirDefense_East')
		end

		-- time between player response checks
		WaitSeconds (13)
	end
end

function P1_GateTriggerAssign()
	LOG('----- P1: Assign gate objective.')
	-- This will create the area trigger to assign the gate objective
	ScenarioFramework.CreateAreaTrigger(P1_GateAssignSecondary_VO, 'AREA_Gate_Objective_Trigger',
		categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1, false)
end

function P1_InitLandAttack()
	LOG('----- P1: Initial land attack.')
	if ScenarioInfo.P1_ENEM01_Init_Land_Platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P1_ENEM01_Init_Land_Platoon) then
		-- On OP start a small enemy land attack is sent toward the player
		ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P1_ENEM01_Init_Land_Platoon, 'ENEM01_P1_Init_Land_Patrol')
	end
end

function P1_HiddenNorthCaptured()
	HiddenObjCaptured = HiddenObjCaptured + 1
	-- Assign North Hidden Objective
	P1_HiddenNorthObj_Assign()
	UnProtectUnit(ScenarioInfo.P1_ENEM01_Hidden_North)
end

function P1_HiddenSouthCaptured()
	HiddenObjCaptured = HiddenObjCaptured + 1
	-- Assign South Hidden Objective
	P1_HiddenSouthObj_Assign()
	UnProtectUnit(ScenarioInfo.P1_ENEM01_Hidden_South)
end

function P1_GateAssignSecondary_VO()
	if not ScenarioInfo.VOLaunched_GateAssign and not ScenarioInfo.GATE_OBJECTIVE_COMPLETE then
		ScenarioInfo.VOLaunched_GateAssign = true

		-- Assign 'Out of Control' objective if it is not already
		-- VO played when gate objective assigned
		ScenarioFramework.Dialogue(OpDialog.I03_S1_obj10_ASSIGN, P1_GateAssignSecondary)
	end
end

function P1_GateDirectAssault_VO()
	-- only play this dialog if the player has not yet been to the south or north outposts AND they have not already played this dialog
	if not ScenarioInfo.P1_PlayerAtSouth and not ScenarioInfo.P1_PlayerAtNorth then
		if not ScenarioInfo.DirectAssaultWarningGiven then
			if ScenarioInfo.P1_ENEM01_Gate and not ScenarioInfo.P1_ENEM01_Gate:IsDead() then
				LOG('----- P1: P1_GateDirectAssault_VO')
				ScenarioInfo.DirectAssaultWarningGiven = true
				ScenarioFramework.Dialogue(OpDialog.I03_EXP_ADVICE_020)
			end
		end
	end
end

function P1_GateAssignSecondary()
	----------------------------------------------
	-- Secondary Objective S1_obj10 - Out of Control
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S1_obj10 - Out of Control.')
	local descText = OpStrings.I03_S1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I03_S1_obj10_DROP_GATE)
	ScenarioInfo.S1_obj10 = SimObjectives.KillOrCapture(
		'secondary',						-- type
		'incomplete',						-- complete
		OpStrings.I03_S1_obj10_NAME,		-- title
		descText,							-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = ScenarioInfo.GateControlUnits,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)

	ScenarioInfo.S1_obj10:AddProgressCallback(
		function(current, total)
			-- Play some progress encouragement when the first Center is destroyed (unless the primary is already done).
			if not ScenarioInfo.GATE_OBJECTIVE_COMPLETE and total == 2 and current == 1 then
				ScenarioFramework.Dialogue(OpDialog.I03_S1_obj10_PROGRESS_010)
			end
		end
	)
	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				GateDestroyed()
			end
		end
	)
end

function P1_ExperimentalGunship_Leash()
	LOG('----- P1: AC-1000 Leash.')
	while not ScenarioInfo.P1_PlayerAtSouth or not ScenarioInfo.P1_PlayerAtNorth do
		-- Any AC-1000 entering this area will be given an order to go back to a patrol in the prison
		local numAC1000 = ScenarioFramework.NumCatUnitsInArea(categories.uux0102, 'PLAYER_BASE_AREA', ArmyBrains[ARMY_ENEM01])

		LOG('----- P1_ExperimentalGunship_Check:', numAC1000)
		if numAC1000 >= 1 then
			-- if we need to leash - leash, otherwise wait 7 seconds then call P1_ExperimentalGunship_Check
			if not ScenarioInfo.P1_PlayerAtSouth then
				-- here is where we call new function call a list, platoon, and move bool
				P1_Exp_ReorderMembers(ScenarioInfo.P1_EnemyExperimentals_East, nil, true)
			end

			if not ScenarioInfo.P1_PlayerAtNorth then
				-- here is where we call new function call a list, platoon, and move bool
				P1_Exp_ReorderMembers(ScenarioInfo.P1_EnemyExperimentals_West, nil, true)
			end
		end
		WaitSeconds(7.0)
	end
end

function P1_ResearchSecondary_Assign_VO()
	--VO telling the player to research the teleport tech in the land:mobility tree
	ScenarioFramework.Dialogue(OpDialog.I03_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.I03_S2_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary Objective S2_obj10 - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S2_obj10 - Research Technology.')
	ScenarioInfo.S2_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.I03_S2_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj10)

	--confirmation VO when complete.
	ScenarioInfo.S2_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.I03_RESEARCH_FOLLOWUP_TELEPORT_010)

				ScenarioFramework.CreateTimerTrigger (TeleportHint, 20)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 300)
end

function ResearchReminder1()
	if ScenarioInfo.S2_obj10.Active then
		LOG('----- Research reminder 1.')
		ScenarioFramework.Dialogue(OpDialog.I03_RESEARCH_REMINDER_010)
	end
end

function TeleportHint()
	LOG('----- TeleportHint.')
	ScenarioFramework.Dialogue(OpDialog.I03_TELEPORT_HINT)
end

function P1_LureSecondary_Assign()
	if ScenarioInfo.LureObjectiveAssigned then
		return
	end

	ScenarioInfo.LureObjectiveAssigned = true

	----------------------------------------------
	-- Secondary Objective S3_obj10 - Insecure
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S3_obj10 - Insecure.')
	local descText = OpStrings.I03_S3_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I03_S3_obj10_KILL_SHIELDS)
	ScenarioInfo.S3_obj10 = SimObjectives.KillOrCapture(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.I03_S3_obj10_NAME,			-- title
		descText,								-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = ScenarioInfo.ShieldOutpostUnits,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S3_obj10)

	ScenarioInfo.S3_obj10:AddProgressCallback(
		function(current, total)
			-- Play some progress encouragement when the first outpost is attacked.
			if total == 2 and current == 1 then
				ScenarioFramework.Dialogue(OpDialog.I03_S3_obj10_PROGRESS_010)
			end
		end
	)

	--confirmation VO when complete.
	ScenarioInfo.S3_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I03_S3_obj10_KILL_SHIELDS, ARMY_PLAYER, 3.0)

				-- Disable OpAI's maintaining AC1000 platoons
				ScenarioInfo.P1_ENEM01_EXP_WEST_OpAI:Disable()
				ScenarioInfo.P1_ENEM01_EXP_EAST_OpAI:Disable()

				-- Check to see if either platoon exists then play related VO
				for k, v in ScenarioInfo.P1_EnemyExperimentals_West do
					if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
						ScenarioInfo.PlatoonExpWestExists = true
						break
					end
				end

				for k, v in ScenarioInfo.P1_EnemyExperimentals_East do
					if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
						ScenarioInfo.PlatoonExpEastExists = true
						break
					end
				end

				if ScenarioInfo.PlatoonExpWestExists and ScenarioInfo.PlatoonExpWestExists then
					ScenarioFramework.Dialogue(OpDialog.I03_S3_obj10_COMPLETE)
				end
			end
		end
	)
end

function P1_HiddenNorthObj_Assign()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Not The Bees!
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H1_obj10 - Not The Bees!')
	local descText = OpStrings.I03_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I03_H1_obj10_TAKE_HID1)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.I03_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('capture'),	-- Action
		{
		}
	)
	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I03_H1_obj10_TAKE_HID1, ARMY_PLAYER, 3.0)

	-- update ScenarioInfo.AssignedObjectives
	---NOTE: even though this is secrent and we are auto-completing, it still needs to be registered for score data. bfricks 6/7/09
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	-- if both hidden objectives are captured complete the third hidden objective
	if HiddenObjCaptured == 2 then
		HiddenObjective()
	end

	P1_HiddenObj_Sequence()
end

function P1_HiddenSouthObj_Assign()
	----------------------------------------------
	-- Hidden Objective H2_obj10 - Welcome to the Barbeque
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H2_obj10 - You Have 10 Seconds to Comply!.')
	local descText = OpStrings.I03_H2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.I03_H2_obj10_TAKE_HID2)
	ScenarioInfo.H2_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.I03_H2_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('capture'),	-- Action
		{
		}
	)
	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I03_H2_obj10_TAKE_HID2, ARMY_PLAYER, 3.0)

	-- update ScenarioInfo.AssignedObjectives
	---NOTE: even though this is secrent and we are auto-completing, it still needs to be registered for score data. bfricks 6/7/09
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H2_obj10)

	-- if both hidden objectives are captured complete the third hidden objective
	if HiddenObjCaptured == 2 then
		ScenarioFramework.CreateTimerTrigger(HiddenObjective, 5)
	end

	P1_HiddenObj_Sequence()
end

function HiddenObjective()
	----------------------------------------------
	-- Hidden Objective H3_obj10 - Agent Provocateur
	----------------------------------------------
	LOG('----- Assign Hidden Objective H3_obj10 - Agent Provocateur')
	ScenarioInfo.H3_obj10 = SimObjectives.Basic(
		'secondary',									-- type
		'complete',										-- status
		OpStrings.I03_H3_obj10_NAME,					-- title
		OpStrings.I03_H3_obj10_DESC,					-- description
		SimObjectives.GetActionIcon('capture'),			-- Action
		{												-- target
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H3_obj10)
end

function P1_HiddenObj_Sequence()
	-- This function controls the sequence of what is given to the player when a hidden objective is captured independently of the
	-- physical location. THis allows us to reward the player in the order we like. The second hidden objective the player captures
	-- could be more beneficial than just the first enforcing the idea its worthwhile for the player to go out of there way to accomplish this

	HiddenObjectiveCount = HiddenObjectiveCount + 1

	if HiddenObjectiveCount == 1 then
		LOG('----- P1_HiddenNorthObj_Assign: North Hidden OBJ Complete')

		-- create a handle to all enemy fighters and gunships and get a list of them all
		local airUnits = ScenarioFramework.GetCatUnitsInArea(categories.uua0101 + categories.uua0103, 'ENEM01_PRISON_AREA', ArmyBrains[ARMY_ENEM01])
		for k, v in airUnits do
			if v and not v:IsDead() then
				-- create a handle to all the new units then then them on a patrol route in the prison
				local newUnit = ScenarioFramework.GiveUnitToArmy(v, ARMY_ALLY01)
				ScenarioFramework.GroupPatrolRoute({newUnit}, ScenarioPlatoonAI.GetRandomPatrolRoute('ALLY01_P1_AirPatrol_Prison'))
			end
		end

		-- disable OpAI's control the prison air patrols
		ScenarioInfo.mainWestAirDefense01_OpAI:Disable()
		ScenarioInfo.mainSouthAirDefense01_OpAI:Disable()
		ScenarioInfo.mainEastAirDefense01_OpAI:Disable()

		-- VO played when completed
		ScenarioFramework.Dialogue(OpDialog.I03_H1_obj10_COMPLETE)

	elseif HiddenObjectiveCount == 2 then
		LOG('----- P1_HiddenSouthObj_Assign: South Hidden OBJ Complete')

		-- create a handle to all prison AA Towers and get a list of them all
		local defenses = ScenarioFramework.GetCatUnitsInArea(categories.uub0102 + categories.uub0202, 'ENEM01_PRISON_AREA', ArmyBrains[ARMY_ENEM01])
		for k, v in defenses do
			if v and not v:IsDead() then
				-- create a handle to all the new towers
				local newDefenses = ScenarioFramework.GiveUnitToArmy(v, ARMY_ALLY01)
			end
		end

		ScenarioInfo.ArmyBase_EnemMain:SetBuildGroupPriority( 'P1_ENEM01_Main_Defense', 0 )

		-- VO played when completed
		ScenarioFramework.Dialogue(OpDialog.I03_H2_obj10_COMPLETE)
	end

	P1_GateAssignSecondary_VO()
end

function P1_PlayerDestroyedNorthShield()
	LOG('----- P1_PlayerDestroyedNorthShield: Player destroyed the north shield!!')

	-- Shield destroyed counter
	ShieldObjDestroyed = ShieldObjDestroyed + 1

	local northOutpostAir = ScenarioFramework.GetCatUnitsInArea(categories.AIR, 'North_Outpost_Area', ArmyBrains[ARMY_ENEM01])

	ScenarioInfo.P1_PlayerAtNorth = true

	for k, v in ScenarioInfo.P1_EnemyExperimentals_West do
		if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
			IssueClearCommands(v:GetPlatoonUnits())
			ScenarioFramework.GroupPatrolRoute(v:GetPlatoonUnits(), ScenarioPlatoonAI.GetRandomPatrolRoute('ENEM01_P1_Exp_MoveTo_Area01_Patrol'))
		end
	end

	-- always disable these two OpAIs
	---NOTE: Daroza, this change means that we are turning off the north base, and the west AC1000s in this case always, I believe that is correct - bfricks 11/1/09
	ScenarioInfo.P1_ENEM01_North_Base_OpAI:Disable()
	ScenarioInfo.P1_ENEM01_EXP_WEST_OpAI:Disable()

	-- get all remaining outpost air units queuing up for an attack and put them on defensive patrol
	for k, v in northOutpostAir do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('ENEM01_P1_Exp_MoveTo_Area01_Patrol'))
	end

	-- If required, call for the Lure
	---NOTE: the lure already manages not getting called more than once - nothing redundant is needed - bfricks 11/1/09
	P1_LureSecondary_Assign()

	-- Check to see if the platoon exists then play related VO
	for k, v in ScenarioInfo.P1_EnemyExperimentals_West do
		if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
			ScenarioInfo.PlatoonExpWestExists = true
			break
		end
	end

	if ScenarioInfo.PlatoonExpWestExists then
		-- VO played dependant on status of shield and hidden objective units
		if ShieldObjDestroyed == 1 and HiddenObjCaptured == 0 then
			ScenarioFramework.Dialogue(OpDialog.I03_EXP_CONFIRMATION_010)
		elseif ShieldObjDestroyed == 2 and HiddenObjCaptured == 0 then
			ScenarioFramework.Dialogue(OpDialog.I03_EXP_CONFIRMATION_020)
		elseif ShieldObjDestroyed >= 1 and HiddenObjCaptured >= 1 then
			ScenarioFramework.Dialogue(OpDialog.I03_EXP_ADVICE_010)
		end
	end
end

function P1_PlayerDestroyedSouthShield()
	LOG('----- P1_PlayerDestroyedSouthShield: Player destroyed the south shield!')

	-- Shield destroyed counter
	ShieldObjDestroyed = ShieldObjDestroyed + 1

	local southOutpostAir = ScenarioFramework.GetCatUnitsInArea(categories.AIR, 'South_Outpost_Area', ArmyBrains[ARMY_ENEM01])

	ScenarioInfo.P1_PlayerAtSouth = true

	for k, v in ScenarioInfo.P1_EnemyExperimentals_East do
		if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
			IssueClearCommands(v:GetPlatoonUnits())
			ScenarioFramework.GroupPatrolRoute(v:GetPlatoonUnits(), ScenarioPlatoonAI.GetRandomPatrolRoute('ENEM01_P1_Exp_MoveTo_Area02_Patrol'))
		end
	end

	-- always disable these two OpAIs
	---NOTE: Daroza, this change means that we are turning off the south base, and the east AC1000s in this case always, I believe that is correct - bfricks 11/1/09
	ScenarioInfo.P1_ENEM01_South_Base_OpAI:Disable()
	ScenarioInfo.P1_ENEM01_EXP_EAST_OpAI:Disable()

	-- get all remaining outpost air units queuing up for an attack and put them on defensive patrol
	for k, v in southOutpostAir do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('ENEM01_P1_Exp_MoveTo_Area02_Patrol'))
	end

	-- If required, call for the Lure
	---NOTE: the lure already manages not getting called more than once - nothing redundant is needed - bfricks 11/1/09
	P1_LureSecondary_Assign()

	-- Check to see if the platoon exists then play related VO
	for k, v in ScenarioInfo.P1_EnemyExperimentals_East do
		if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
			ScenarioInfo.PlatoonExpEastExists = true
			break
		end
	end

	if ScenarioInfo.PlatoonExpEastExists then
		-- VO played dependant on status of shield and hidden objective units
		if ShieldObjDestroyed == 1 and HiddenObjCaptured == 0 then
			ScenarioFramework.Dialogue(OpDialog.I03_EXP_CONFIRMATION_010)
		elseif ShieldObjDestroyed == 2 and HiddenObjCaptured == 0 then
			ScenarioFramework.Dialogue(OpDialog.I03_EXP_CONFIRMATION_020)
		elseif ShieldObjDestroyed >= 1 and HiddenObjCaptured >= 1 then
			ScenarioFramework.Dialogue(OpDialog.I03_EXP_ADVICE_010)
		end
	end
end

function P1_ExpWestFormCallback(platoon)
	-- This is the callback for the west experimental OpAI. It is an intermediary step,
	-- so we can also pass in the table of platoons to the main callback
	P1_ExpFormCallback(ScenarioInfo.P1_EnemyExperimentals_West, platoon)
end

function P1_ExpEastFormCallback(platoon)
	-- This is the callback for the east experimental OpAI. It is an intermediary step,
	-- so we can also pass in the table of platoons to the main callback
	P1_ExpFormCallback(ScenarioInfo.P1_EnemyExperimentals_East, platoon)
end

function P1_ExpFormCallback(list, platoon)
	if not ScenarioInfo.OpEnded then
		LOG('----- P1_ExpFormCallback: list table is', list)

		-- Place theplatoon into our table
		table.insert(list, platoon)

		-- Create a new death trigger for the new unit
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ScenarioFramework.CreatePlatoonDeathTrigger(
				function(platoon)
						-- When this unit dies, call the function that will compact the ranks since we now have a
						-- blank spot in them.
						P1_Exp_ReorderMembers(list, platoon)
				end
				, platoon)
		end

		-- Clean up the list and get all its members to the appropriate patrol
		-- for their location.
		P1_Exp_ReorderMembers(list)
	end
end

function P1_Exp_ReorderMembers(list, platoon, bMove)
	LOG('----- P1_Exp_ReorderMembers: reorder experimentals.')
	-- This function compacts a unit table down, to get rid of spaces, and sends the units on patrol.
	-- In-game, the effect is to move the patrolling experimentals closer to the Gate, if some of
	-- their fellow patrollers have been killed off (leaving gaps in the ranks).

	-- before we clear the list, check which location (based of which list )we are dealing with
	-- (so we know where to send the patrol, in general, and in the particular case
	-- of the player attacking either the west or east areas.)

	local loc = 1
	local locAttackedFlag = ScenarioInfo.P1_PlayerAtNorth
	if list == ScenarioInfo.P1_EnemyExperimentals_West then
		LOG('----- P1_Exp_ReorderMembers: West experimental group being reordered')
		loc = 1
		locAttackedFlag = ScenarioInfo.P1_PlayerAtNorth
	elseif list == ScenarioInfo.P1_EnemyExperimentals_East then
		LOG('----- P1_Exp_ReorderMembers: East experimental group being reordered')
		loc = 2
		locAttackedFlag = ScenarioInfo.P1_PlayerAtSouth
	end

	if platoon then
		-- find the platoon in the list, and remove it
		local key = table.find( list, platoon )
		table.remove(list, key)
	end

	-- Send the newly compacted group of units to the patrols approriate to their new slot in the rank.
	for k, v in list do
		if v and ArmyBrains[ARMY_ENEM01]:PlatoonExists(v) then
			IssueClearCommands(v:GetPlatoonUnits())

			if bMove then
				--- do somethinfg here
				IssueMove(v:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('ENEM01_P1_Exp_Return_Area01_05'))
			end

			-- a safety check, that we havent somehow gotten a list with too many handles in it. We check
			-- against a value initially set during setup of the Part.
			if k <= ScenarioInfo.P1_Exp_ExperimentalsPerSide then

				-- Send the patrol to either the fort front, or the area the player has moved
				-- into that triggered a response. Go to which ever side (east or west) as decided above.
				if not locAttackedFlag then
					ScenarioFramework.PlatoonPatrolChain(v, 'ENEM01_P1_Exp_Patrol_Area0' .. loc .. '_0' .. k)
				else
					ScenarioFramework.PlatoonPatrolChain(v, 'ENEM01_P1_Exp_MoveTo_Area0' .. loc .. '_Patrol')
				end

			-- if, for some wierd reason, we actually got more entires in the table than
			-- the number of platoons we started with, then just send these these rogue extras
			-- to the first patrol.
			else
				LOG('----- P1_Exp_ReorderMembers: EXCESS PATROL')
				if not locAttackedFlag then
					ScenarioFramework.PlatoonPatrolChain(v, 'ENEM01_P1_Exp_Patrol_Area0' .. loc .. '_01')
				else
					ScenarioFramework.PlatoonPatrolChain(v, 'ENEM01_P1_Exp_MoveTo_Area0' .. loc .. '_Patrol')
				end
			end

		end
	end
end

function P1_ENEM01_Setup()
	LOG('----- P1_ENEM01_Setup: Enemy Base managers and OpAI\'s.')
	-- Set up Enemy base AI
	ScenarioInfo.levelTable_EnemMain = {
		P1_ENEM01_Main_Base = 100,
		P1_ENEM01_Main_Defense = 90,
	}

	ScenarioInfo.ArmyBase_EnemMain 		= ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P1_ENEM01_Main_Base',
		 'P1_ENEM01_Main_Base_Marker', 50, ScenarioInfo.levelTable_EnemMain)
	ScenarioInfo.ArmyBase_EnemMain:		StartNonZeroBase(6)

	-- Set up North outpost AI
	local levelTable_EnemNorth 			= { P1_ENEM01_North_Base = 100, }
	ScenarioInfo.ArmyBase_EnemNorth 	= ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P1_ENEM01_North_Base',
		 'P1_ENEM01_North_Base_Marker', 50, levelTable_EnemNorth)
	ScenarioInfo.ArmyBase_EnemNorth:	StartNonZeroBase(0)

	-- Set up South outpost AI
	local levelTable_EnemSouth 			= { P1_ENEM01_South_Base = 100, }
	ScenarioInfo.ArmyBase_EnemSouth 	= ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P1_ENEM01_South_Base',
		 'P1_ENEM01_South_Base_Marker', 50, levelTable_EnemSouth)
	ScenarioInfo.ArmyBase_EnemSouth:	StartNonZeroBase(0)

	--------------------------------------------------
	-- Set up the OpAIs that the Base will maintain --
	--------------------------------------------------

	-- Base OpAI for the land factories
	ScenarioInfo.P1_ENEM01_Land_Base_OpAI			= ScenarioInfo.ArmyBase_EnemMain:GenerateOpAIFromPlatoonTemplate( LandAttackCustom, 'P1_ENEM01_Land_Base_OpAI', {} )
	local P1_ENEM01_Land_Base_OpAI_Data				= { PatrolChain = 'ENEM01_P1_Land_Response_Patrol',}
	ScenarioInfo.P1_ENEM01_Land_Base_OpAI:			SetPlatoonThread( 'PatrolRandomizedPoints', P1_ENEM01_Land_Base_OpAI_Data )

	ScenarioInfo.P1_ENEM01_Land_Base_OpAI:			SetAttackDelay(LandAttack_Delay)
	ScenarioInfo.P1_ENEM01_Land_Base_OpAI:			SetChildCount(2)
	ScenarioInfo.P1_ENEM01_Land_Base_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Land_Base_OpAI:			Disable()

	-- Base OpAI for the North Outpost
	ScenarioInfo.P1_ENEM01_North_Base_OpAI			= ScenarioInfo.ArmyBase_EnemNorth:GenerateOpAIFromPlatoonTemplate( AirAttackBombers, 'P1_ENEM01_North_Base_OpAI', {} )
	local P1_ENEM01_North_Base_OpAI_Data			= {AnnounceRoute = false, PatrolChains = { 'ENEM01_P1_Outpost_Attack_Patrol', },}
	ScenarioInfo.P1_ENEM01_North_Base_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_North_Base_OpAI_Data )

	ScenarioInfo.P1_ENEM01_North_Base_OpAI:			SetAttackDelay(AirAttack_Delay)
	ScenarioInfo.P1_ENEM01_North_Base_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ENEM01_North_Base_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_North_Base_OpAI:			Disable()

	-- Base OpAI for the South Outpost
	ScenarioInfo.P1_ENEM01_South_Base_OpAI			= ScenarioInfo.ArmyBase_EnemSouth:GenerateOpAIFromPlatoonTemplate( AirAttackGunships, 'P1_ENEM01_South_Base_OpAI', {} )
	local P1_ENEM01_South_Base_OpAI_Data			= {AnnounceRoute = false, PatrolChains = { 'ENEM01_P1_Outpost_Attack_Patrol', },}
	ScenarioInfo.P1_ENEM01_South_Base_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_South_Base_OpAI_Data )

	ScenarioInfo.P1_ENEM01_South_Base_OpAI:			SetAttackDelay(AirAttack_Delay)
	ScenarioInfo.P1_ENEM01_South_Base_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ENEM01_South_Base_OpAI:			SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_South_Base_OpAI:			Disable()

	-- North OpAI for experimental gunships
	ScenarioInfo.P1_ENEM01_EXP_WEST_OpAI			= ScenarioInfo.ArmyBase_EnemMain:AddOpAI('SingleAC1000Attack', 'P1_ENEM01_EXP_WEST_OpAI', {} )
	local P1_ENEM01_EXP_WEST_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ENEM01_P1_Exp_Patrol_Area01_01',},}
	ScenarioInfo.P1_ENEM01_EXP_WEST_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_EXP_WEST_OpAI_Data )
	ScenarioInfo.P1_ENEM01_EXP_WEST_OpAI:			SetMaxActivePlatoons(5)
	ScenarioInfo.P1_ENEM01_EXP_WEST_OpAI.			FormCallback:Add( P1_ExpWestFormCallback)
	for k, platoon in ScenarioInfo.P1_EnemyExperimentals_West do
		ScenarioInfo.P1_ENEM01_EXP_WEST_OpAI:AddActivePlatoon(platoon, true)
	end

	-- South OpAI for experimental gunships
	ScenarioInfo.P1_ENEM01_EXP_EAST_OpAI			= ScenarioInfo.ArmyBase_EnemMain:AddOpAI('SingleAC1000Attack', 'P1_ENEM01_EXP_EAST_OpAI', {} )
	local P1_ENEM01_EXP_EAST_OpAI_Data				= {AnnounceRoute = false, PatrolChains = { 'ENEM01_P1_Exp_Patrol_Area02_01',},}
	ScenarioInfo.P1_ENEM01_EXP_EAST_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_EXP_EAST_OpAI_Data )
	ScenarioInfo.P1_ENEM01_EXP_EAST_OpAI:			SetMaxActivePlatoons(5)
	ScenarioInfo.P1_ENEM01_EXP_EAST_OpAI.			FormCallback:Add( P1_ExpEastFormCallback)
	for k, platoon in ScenarioInfo.P1_EnemyExperimentals_East do
		ScenarioInfo.P1_ENEM01_EXP_EAST_OpAI:AddActivePlatoon(platoon, true)
	end

	-- 3 general fighter-only (ie, AA only) patrols over the main base area).
	ScenarioInfo.mainWestAirDefense01_OpAI		= ScenarioInfo.ArmyBase_EnemMain:AddOpAI('AirAttackUEF', 'P1_ENEM01_Init_AirDef_West', {} )
	ScenarioInfo.mainSouthAirDefense01_OpAI		= ScenarioInfo.ArmyBase_EnemMain:AddOpAI('AirAttackUEF', 'P1_ENEM01_Init_AirDef_South', {} )
	ScenarioInfo.mainEastAirDefense01_OpAI		= ScenarioInfo.ArmyBase_EnemMain:AddOpAI('AirAttackUEF', 'P1_ENEM01_Init_AirDef_East', {} )

	-- Specify what child types of units are used for each OpAI
	local mainWestAirDefense01_Disables 	= { 'UEFBombers', 'UEFGunships' }
	local mainSouthAirDefense01_Disables 	= { 'UEFBombers', 'UEFGunships' }
	local mainEastAirDefense01_Disables 	= { 'UEFBombers', 'UEFGunships' }

	-- Set up routes for each OpAI
	local mainWestAirDefense01_Data 	= { AnnounceRoute = true, PatrolChains = { 'ENEM01_P1_AirDefense_West', },}
	local mainSouthAirDefense01_Data 	= { AnnounceRoute = true, PatrolChains = { 'ENEM01_P1_AirDefense_South', },}
	local mainEastAirDefense01_Data 	= { AnnounceRoute = true, PatrolChains = { 'ENEM01_P1_AirDefense_East', },}

	ScenarioInfo.mainWestAirDefense01_OpAI:SetPlatoonThread( 'PatrolRandomRoute', mainWestAirDefense01_Data )
	ScenarioInfo.mainSouthAirDefense01_OpAI:SetPlatoonThread( 'PatrolRandomRoute', mainSouthAirDefense01_Data )
	ScenarioInfo.mainEastAirDefense01_OpAI:SetPlatoonThread( 'PatrolRandomRoute', mainEastAirDefense01_Data )

	-- Disable child types as specified above
	ScenarioInfo.mainWestAirDefense01_OpAI:DisableChildTypes( mainWestAirDefense01_Disables )
	ScenarioInfo.mainSouthAirDefense01_OpAI:DisableChildTypes( mainSouthAirDefense01_Disables )
	ScenarioInfo.mainEastAirDefense01_OpAI:DisableChildTypes( mainEastAirDefense01_Disables )

	ScenarioInfo.mainWestAirDefense01_OpAI:SetChildCount(4)
	ScenarioInfo.mainSouthAirDefense01_OpAI:SetChildCount(4)
	ScenarioInfo.mainEastAirDefense01_OpAI:SetChildCount(4)

	ScenarioInfo.mainWestAirDefense01_OpAI:SetMaxActivePlatoons(1)
	ScenarioInfo.mainSouthAirDefense01_OpAI:SetMaxActivePlatoons(1)
	ScenarioInfo.mainEastAirDefense01_OpAI:SetMaxActivePlatoons(1)
end

function CreateGateUnits()
	ScenarioInfo.P1_ENEM01_GateControl_West = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_GateControl_West')
	ScenarioInfo.P1_ENEM01_GateControl_West:SetCustomName(ScenarioGameNames.UNIT_SCB1103)

	ScenarioInfo.P1_ENEM01_GateControl_East = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_GateControl_East')
	ScenarioInfo.P1_ENEM01_GateControl_East:SetCustomName(ScenarioGameNames.UNIT_SCB1103)

	-- the gate is not reclaimable or capturable
	ScenarioInfo.P1_ENEM01_Gate = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Gate')
	ScenarioInfo.P1_ENEM01_Gate:SetCustomName(ScenarioGameNames.UNIT_SCB2302)
	ScenarioInfo.P1_ENEM01_Gate:SetReclaimable(false)
	ScenarioInfo.P1_ENEM01_Gate:SetCapturable(false)

	-- Table that holds the gate control units
	ScenarioInfo.GateControlUnits = {}

	table.insert(ScenarioInfo.GateControlUnits, ScenarioInfo.P1_ENEM01_GateControl_West)
	table.insert(ScenarioInfo.GateControlUnits, ScenarioInfo.P1_ENEM01_GateControl_East)

	-- set the gate health
	ScenarioInfo.P1_ENEM01_Gate:SetMaxHealth(GateMaxHeath)
	ScenarioInfo.P1_ENEM01_Gate:AdjustHealth(ScenarioInfo.P1_ENEM01_Gate, GateMaxHeath)

	-- create our path-blocking hoo-ha
	ScenarioFramework.CreateOGridBlockers(ScenarioInfo.P1_ENEM01_Gate,'O_GRID_BLOCKERS', 'ARMY_ENEM01')

	-- make sure to handle the gate death too
	ScenarioFramework.CreateUnitDeathTrigger(GateDestroyed, ScenarioInfo.P1_ENEM01_Gate)
end

function GateDestroyed()
	LOG('----- GateDestroyed: checking...')
	if not ScenarioInfo.GATE_OBJECTIVE_COMPLETE then
		LOG('----- GateDestroyed: executing')
		ScenarioInfo.GATE_OBJECTIVE_COMPLETE = true

		if not ScenarioInfo.S1_obj10 then
			LOG('----- GateDestroyed: calling for the secondary to be assigned')
			P1_GateAssignSecondary()
		end

		ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.I03_S1_obj10_DROP_GATE, ARMY_PLAYER, 3.0)

		-- Play some VO confirmation and advice, but not if the primary objective which the VO
		-- supports is already completed.
		if ScenarioInfo.M1_obj10.Active then
			LOG('----- GateDestroyed: playing dialog')
			ScenarioFramework.Dialogue(OpDialog.I03_S1_obj10_COMPLETE)
		end

		-- kill any of the gate associated stuff at this point
		ForceUnitDeath(ScenarioInfo.P1_ENEM01_Gate)
		ForceGroupDeath(ScenarioInfo.GateControlUnits)

		-- enable the associated OpAI
		if ScenarioInfo.P1_ENEM01_Land_Base_OpAI then
			ScenarioInfo.P1_ENEM01_Land_Base_OpAI:Enable()
		end
	end
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	ScenarioInfo.P1_ENEM01_Prison:SetCapturable(true)
end

function OnShiftF4()
	local westCount = table.getn(ScenarioInfo.P1_EnemyExperimentals_West)
	LOG('----- OnShiftF4: West count', repr(westCount))



end
