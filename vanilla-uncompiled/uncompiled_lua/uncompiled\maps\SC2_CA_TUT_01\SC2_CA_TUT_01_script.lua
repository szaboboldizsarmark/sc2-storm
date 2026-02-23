---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_TUT_01/SC2_CA_TUT_01_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_TUT_01/SC2_CA_TUT_01_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_TUT_01/SC2_CA_TUT_01_OpNIS.lua')
local ScenarioUtils			= import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework		= import('/lua/sim/ScenarioFramework.lua')
local ScenarioGameSetup		= import('/lua/sim/ScenarioFramework/ScenarioGameSetup.lua')
local ScenarioGameTuning	= import('/lua/sim/ScenarioFramework/ScenarioGameTuning.lua')
local ScenarioGameEvents	= import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua')
local ScenarioGameCleanup	= import('/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua')
local ScenarioPlatoonAI 	= import('/lua/AI/ScenarioPlatoonAI.lua')
local SimObjectives			= import('/lua/sim/SimObjectives.lua')
local SimPingGroups			= import('/lua/sim/SimPingGroup.lua')
local RandomFloat			= import('/lua/system/utilities.lua').GetRandomFloat
local RandomInt				= import('/lua/system/utilities.lua').GetRandomInt

local NIS					= import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua')

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

local BuildObjectivesCompleted = 0
local BuildStartedSafetyCount = 0

local platformIndex = 1

if IsXbox() then
	platformIndex = 2
end

if ScenarioInfo.Options.UseGamePad then
	platformIndex = 2
end

---------------------------------------------------------------------
-- GLOBAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
ScenarioInfo.ARMY_PLAYER = 1
ScenarioInfo.ARMY_ENEM01 = 2
ScenarioInfo.ARMY_ALLY01 = 3
ScenarioInfo.ARMY_CAPTURE = 4

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.tutorial = true

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01
local ARMY_CAPTURE = ScenarioInfo.ARMY_CAPTURE

---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.1,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= 50,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
		NearZoom		= 30,
	}

	import('/lua/system/Utilities.lua').UserConRequest('ui_RenderIcons false')

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupGenericArmy(		ARMY_PLAYER,	ScenarioGameTuning.color_UEF_PLAYER)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_ENEM01,	ScenarioGameTuning.color_TUT_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_ALLY01,	ScenarioGameTuning.color_TUT_ALLY01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CAPTURE,	ScenarioGameTuning.color_TUT_ENEM01)
end

---------------------------------------------------------------------
function OnStart(self)
	ScenarioGameSetup.CAMPAIGN_OnStart()
end

---------------------------------------------------------------------
function OnInitCamera(scen)
	-- construct the data table
	local data = {
		funcSetup		= P1_Setup,					-- if valid, the function to be called while the load screen is up
		funcNIS			= OpNIS.NIS_OPENING,		-- if valid, the non-critical NIS sequence to be launched
		funcMain		= funcAssignCameraPan,		-- if valid, the function to be called after the NIS
		areaStart		= 'PLAYABLE_AREA',			-- if valid, the area to be used for setting the starting playable area
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnInitCamera(data)
end


---------------------------------------------------------------------
-- PART 1: Setup
---------------------------------------------------------------------
function P1_Setup()
	LOG('----- P1_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 1

	-- fully restrict all research
	for techName, tech in ResearchDefinitions do
		ArmyBrains[ARMY_PLAYER]:ResearchRestrict( {techName}, true )
	end

	-- disallow the player earning any research
	ArmyBrains[ARMY_PLAYER]:SetMaxStorage('RESEARCH', 0)

	LOG('----- P1_Setup: Setup for the player CDR.')
	ScenarioInfo.PLAYER_CDR = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_CDR')
	ScenarioInfo.PLAYER_CDR:SetCustomName(LOC('<LOC CHARACTER_0024>ACU'))
	ProtectUnit(ScenarioInfo.PLAYER_CDR)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Player cannot build any units
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.ALLUNITS)

	-- At start, ACU is unselectable, untargetable
	ScenarioInfo.PLAYER_CDR:SetUnSelectable(true)
	ScenarioInfo.PLAYER_CDR:SetDoNotTarget(true)

	-- Set Economy to zero at start
	ArmyBrains[ARMY_PLAYER]:TakeResource('MASS', 1600 )
	ArmyBrains[ARMY_PLAYER]:TakeResource('ENERGY', 4000 )

	-- Lock the player out of the research tree
	Sync.LockResearch = true

	-- Turn off ACU economy
	ScenarioInfo.PLAYER_CDR:SetProductionPerSecondEnergy ( 0 )
	ScenarioInfo.PLAYER_CDR:SetProductionPerSecondMass ( 0 )
	ScenarioInfo.PLAYER_CDR:SetProductionPerSecondResearch ( 0 )
end

---------------------------------------------------------------------
-- Camera Pan
---------------------------------------------------------------------
function funcAssignCameraPan()
	ScenarioFramework.CreateIntelAtLocation(150, 'PLAYER_START', ARMY_PLAYER, 'Vision')

	ScenarioFramework.SetPlayableArea('CAM_AREA', false)

	SetupAmbientFighters()

	funcCamera_Pan()
end

function funcCamera_Pan()

	local str1 = LOC(OpStrings.TUT01_Obj_CameraPan_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CameraPan_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_CameraPan = SimObjectives.Camera(
		'primary',								-- type
		'incomplete',							-- title
		OpStrings.TUT01_Obj_CameraPan_NAME,		-- title
		descText,								-- description
	        {
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_01' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_02' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_03' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_04' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_05' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_06' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_07' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_08' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_09' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_10' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_11' ),
	            ScenarioUtils.MarkerToPosition( 'PAN_OBJ_12' ),
	        }
	    )

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_CameraPan)

	ShowUI(OpStrings.TUT01_Obj_CameraPan_UI[platformIndex])

	--Force complete after passing through two
	ScenarioInfo.Obj_CameraPan:AddProgressCallback(
		function(current, total)
			if current == 2 then
				ScenarioInfo.Obj_CameraPan:ManualResult(true)
				if platformIndex == 2 then
					Zoom_TransitionThread()
				else
					Rotate_TransitionThread()
				end
			end
		end
	)
end

function Rotate_TransitionThread()
	ForkThread(
		function()
			OpNIS.NIS_ROTATE()
			funcCamera_Rotate()
		end
	)
end

function funcCamera_Rotate()

	--heavily restricted playable area
	ScenarioFramework.SetPlayableArea('RESTRICTED', false)

	local str1 = LOC(OpStrings.TUT01_Obj_CameraRotate_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CameraRotate_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_CameraRotate = SimObjectives.Camera(
		'primary',								-- type
		'incomplete',							-- title
		OpStrings.TUT01_Obj_CameraRotate_NAME,	-- title
		descText,								-- description
	        {
	            ScenarioUtils.MarkerToPosition( 'ROTATE_OBJ_01' ),
	            ScenarioUtils.MarkerToPosition( 'ROTATE_OBJ_02' ),
	            ScenarioUtils.MarkerToPosition( 'ROTATE_OBJ_03' ),
	        }
	    )

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_CameraRotate)

	ShowUI(OpStrings.TUT01_Obj_CameraRotate_UI[platformIndex])

	ScenarioInfo.Obj_CameraRotate:AddResultCallback(
		function(result)
			Tilt_TransitionThread()
		end
	)
end

function Tilt_TransitionThread()
	ForkThread(
		function()
			OpNIS.NIS_TILT()
			funcCamera_Tilt()
		end
	)
end

function funcCamera_Tilt()

	--heavily restricted playable area
	ScenarioFramework.SetPlayableArea('RESTRICTED', false)

	local str1 = LOC(OpStrings.TUT01_Obj_CameraTilt_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CameraTilt_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_CameraTilt = SimObjectives.Camera(
		'primary',								-- type
		'incomplete',							-- title
		OpStrings.TUT01_Obj_CameraTilt_NAME,	-- title
		descText,								-- description
	        {
	            ScenarioUtils.MarkerToPosition( 'TILT_OBJ_02' ),
	        }
	    )

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_CameraTilt)

	ShowUI(OpStrings.TUT01_Obj_CameraTilt_UI[platformIndex])

	ScenarioInfo.Obj_CameraTilt:AddResultCallback(
		function(result)
			Zoom_TransitionThread()
		end
	)
end

function Zoom_TransitionThread()
	import('/lua/system/Utilities.lua').UserConRequest('cam_FarZoom 75')

	--heavily restricted playable area
	ScenarioFramework.SetPlayableArea('RESTRICTED', false)

	ForkThread(
		function()
			OpNIS.NIS_ZOOM()
			funcCamera_Zoom()
		end
	)
end

function funcCamera_Zoom()

	local str1 = LOC(OpStrings.TUT01_Obj_CameraZoom_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CameraZoom_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_CameraZoom = SimObjectives.Camera(
		'primary',								-- type
		'incomplete',							-- title
		OpStrings.TUT01_Obj_CameraZoom_NAME,	-- title
		descText,								-- description
	        {
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_01' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_02' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_03' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_04' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_05' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_06' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_07' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_08' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_09' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_10' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_11' ),
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ_12' ),
	        }
	    )

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_CameraZoom)

	ShowUI(OpStrings.TUT01_Obj_CameraZoom_UI[platformIndex])

	--Force complete after passing through one zoom
	ScenarioInfo.Obj_CameraZoom:AddProgressCallback(
		function(current, total)
			if current == 1 then
				ScenarioInfo.Obj_CameraZoom:ManualResult(true)
				Selection_Setup()
			end
		end
	)
end

---------------------------------------------------------------------
-- Selection
---------------------------------------------------------------------
function Selection_Setup()
	-- expand the playable area
	ScenarioFramework.SetPlayableArea('CAM_AREA', false)

	-- Now let's select the ACU
	SetupAmbientGunships()

	Selection_TransitionThread()
end

function Selection_TransitionThread()
	ForkThread(
		function()
			OpNIS.NIS_SELECTION_INTRO()
			funcSelect_Single()
		end
	)
end

function funcSelect_Single()

	local str1 = LOC(OpStrings.TUT01_Obj_SelectSingle_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_SelectSingle_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_SelectSingle = SimObjectives.Basic(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT01_Obj_SelectSingle_NAME,	-- title
		descText,								-- description
		SimObjectives.GetActionIcon('locate'),	-- Action
		{
		}
	)

	ScenarioInfo.PLAYER_CDR:SetUnSelectable(false)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_SelectSingle)

	ShowUI(OpStrings.TUT01_Obj_SelectSingle_UI[platformIndex])

	ScenarioFramework.CreateUnitSelectedTrigger(onSelect, ScenarioInfo.PLAYER_CDR)
end

function onSelect()
	if ScenarioInfo.TUT_OnSelectFunctionCalled then
		return
	end

	ScenarioInfo.TUT_OnSelectFunctionCalled = true

	ScenarioInfo.Obj_SelectSingle:ManualResult(true)

	ScenarioInfo.P2_Selection_Transport01 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P2_Selection_Transport01')
	ScenarioInfo.P2_Selection_Transport01:SetUnSelectable(true)
	ScenarioInfo.P2_Selection_Transport01:SetDoNotTarget(true)

	func_NIS_COMBAT_TransportGroups()

	ScenarioFramework.Dialogue(OpDialog.TUT1_MOVE_ASSIGN, Move_Setup)
end

---------------------------------------------------------------------
-- Move
---------------------------------------------------------------------
function Move_Setup()
	LOG('----- Move Setup:')
	-- Expand area for move and attack command
	ScenarioFramework.SetPlayableArea('MOVE_AREA', false)
	ScenarioFramework.CreateIntelAtLocation(50, 'MOVE_MARKER', ARMY_PLAYER, 'Vision')
	funcCommands_Move()
end

function funcCommands_Move()

	local str1 = LOC(OpStrings.TUT01_Obj_CommandsMove_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CommandsMove_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_CommandsMove = SimObjectives.CategoriesInArea(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT01_Obj_CommandsMove_NAME,	-- title
		descText,								-- description
		'move',									-- Action
		{
			AddArrow = true,
			Requirements = {
				{Area = 'MOVE_TRIGGER_03', Category = categories.ALLUNITS, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
			},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_CommandsMove)

	--Mark your path
	ScenarioInfo.arrow01 = TutCreateArrow('Move_Markers_01')
	ScenarioInfo.arrow02 = TutCreateArrow('Move_Markers_02')
	ScenarioInfo.arrow03 = TutCreateArrow('Move_Markers_03')

	ShowUI(OpStrings.TUT01_Obj_CommandsMove_UI[platformIndex])

	--CreateAreaTrigger( callbackFunction, rectangle, category, onceOnly, invert, aiBrain, number, requireBuilt)
	ScenarioFramework.CreateAreaTrigger(destroyArrow01, ScenarioUtils.AreaToRect('MOVE_TRIGGER_01'),
		categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 1)

	ScenarioFramework.CreateAreaTrigger(destroyArrow02, ScenarioUtils.AreaToRect('MOVE_TRIGGER_02'),
		categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 1)

	ScenarioFramework.CreateAreaTrigger(destroyArrow03, ScenarioUtils.AreaToRect('MOVE_TRIGGER_03'),
		categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 1)

	ScenarioInfo.Obj_CommandsMove:AddResultCallback(
		function(result)
			funcCommands_Attack_SetupThread()
		end
	)
end

function funcCommands_Attack_SetupThread()

	--create power gens
	ScenarioFramework.SetPlayableArea('BATTLE_AREA', false)
	ScenarioFramework.CreateIntelAtLocation(75, 'COMBAT_MARKER', ARMY_PLAYER, 'Vision')
	ScenarioInfo.Attack_Structures = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'Attack_Structures')

	--Create capture unit
	ScenarioInfo.CAPTURE_UNIT = ScenarioUtils.CreateArmyUnit('ARMY_CAPTURE', 'CAPTURE_UNIT')
	ScenarioInfo.CAPTURE_UNIT:SetCustomName(LOC('<LOC CAPTURE_UNIT_0000>Capture Unit'))

	ProtectUnit(ScenarioInfo.CAPTURE_UNIT)

	ScenarioInfo.CAPTURE_UNIT:SetUnSelectable(true)
	ScenarioInfo.CAPTURE_UNIT:SetDoNotTarget(true)

	for k, v in ScenarioInfo.Attack_Structures do
		v:SetCapturable(false)
		v:SetReclaimable(false)
	end

	Attack_TransitionThread()
end

function Attack_TransitionThread()
	ForkThread(
		function()
			ScenarioInfo.PlayerTanks = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uul0101, false )
			OpNIS.NIS_COMMANDS_ATTACK()
			funcCommands_Attack()
		end
	)
end

function funcCommands_Attack()

	local str1 = LOC(OpStrings.TUT01_Obj_CommandsAttack_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CommandsAttack_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_CommandsAttack = SimObjectives.KillOrCapture(
		'primary',									-- type
		'incomplete',								-- status
		OpStrings.TUT01_Obj_CommandsAttack_NAME,	-- title
		descText,									-- description
		{
			FlashVisible = true,
			MarkUnits = true,
			Units = ScenarioInfo.Attack_Structures,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_CommandsAttack)

	ShowUI(OpStrings.TUT01_Obj_CommandsAttack_UI[platformIndex])

	ScenarioFramework.CreateAreaTrigger(function() ScenarioFramework.Dialogue(OpDialog.TUT1_ATTACK_HINT) end, ScenarioUtils.AreaToRect('RANGE_AREA'),
		categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 1)

	ScenarioInfo.Obj_CommandsAttack:AddResultCallback(
		function(result)
			ScenarioFramework.Dialogue(OpDialog.TUT1_ATTACK_COMPLETE, funcCapture_Assign)
		end
	)
end

---------------------------------------------------------------------
-- Capture/Special Abilities
---------------------------------------------------------------------

function funcCapture_Assign()

	ScenarioFramework.Dialogue(OpDialog.TUT1_CAPTURE_ASSIGN)

	local str1 = LOC(OpStrings.TUT02_Obj_Capture_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_Capture_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Capture = SimObjectives.Capture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_Capture_NAME,		-- title
		descText,								-- description
		{
			FlashVisible = true,
			MarkUnits = true,
			Units = {ScenarioInfo.CAPTURE_UNIT},
		}

	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Capture)

	ScenarioInfo.CAPTURE_UNIT:SetCapturable(true)
	ScenarioInfo.CAPTURE_UNIT:SetUnSelectable(false)

	ShowUI(OpStrings.TUT02_Obj_Capture_UI[platformIndex])

	ScenarioInfo.Obj_Capture:AddResultCallback(
		function(result)
			ScenarioFramework.Dialogue(OpDialog.TUT1_CAPTURE_COMPLETE, BasicCombatSetup)
		end
	)
end


---------------------------------------------------------------------
-- Basic Combat
---------------------------------------------------------------------

function BasicCombatSetup()
	ScenarioFramework.SetPlayableArea('COMBAT_AREA', false)
	ScenarioFramework.CreateIntelAtLocation(100, 'COMBAT_MARKER01', ARMY_PLAYER, 'Vision')

	ScenarioInfo.Combat_EnemyObjectiveUnits = {}
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'TUT01_Combat_Mobiles', 'AttackFormation')

	local units = platoon:GetPlatoonUnits()
	for k, v in units do
		if v and not v:IsDead() then
			table.insert(ScenarioInfo.Combat_EnemyObjectiveUnits, v)
		end
	end

	for k, v in ScenarioInfo.Combat_EnemyObjectiveUnits do
		v:SetCapturable(false)
		v:SetReclaimable(false)
	end

	BasicCombatSetup_TransitionThread()
end

function BasicCombatSetup_TransitionThread()

	ScenarioInfo.P2_Selection_Transport02 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P2_Selection_Transport02')

	ScenarioInfo.P2_Selection_Transport02:SetUnSelectable(true)
	ScenarioInfo.P2_Selection_Transport02:SetDoNotTarget(true)

	ForkThread(
		function()
			OpNIS.NIS_COMBAT()
			funcBasicCombat()
		end
	)
end

function funcBasicCombat()

	local str1 = LOC(OpStrings.TUT01_Obj_Combat_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CommandsAttack_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Combat = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.TUT01_Obj_Combat_NAME,	-- title
		descText,							-- description
		{
			FlashVisible = true,
			MarkUnits = true,
			Units = ScenarioInfo.Combat_EnemyObjectiveUnits,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Combat)

	ShowUI(OpStrings.TUT01_Multiselect2_UI[platformIndex])

	ScenarioFramework.CreateAreaTrigger(function() IssueMove(ScenarioInfo.Combat_EnemyObjectiveUnits, ScenarioUtils.MarkerToPosition( 'COMBAT_MARKER01' )) end,
		ScenarioUtils.AreaToRect('COMBAT_MOVE'), categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1)

	ScenarioInfo.Obj_Combat:AddProgressCallback(
		function(current)
			if current == 4 then
				ScenarioFramework.Dialogue(OpDialog.TUT1_COMBAT_HINT01)
			end
		end
	)

	ScenarioInfo.Obj_Combat:AddResultCallback(
		function(result)
			ScenarioInfo.PLAYER_CDR:SetProductionPerSecondEnergy ( 5 )
			ScenarioInfo.PLAYER_CDR:SetProductionPerSecondMass ( 1 )
			funcBuild_Factory_Setup()
		end
	)
end

function funcBuild_Factory_Setup()
	ForkThread(
		function()
			OpNIS.NIS_PART2_OPENING()
			funcBuild_Factory()
		end
	)
end

function funcBuild_Factory()
	ScenarioFramework.SetPlayableArea('FACTORY_AREA', false)

	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0001, true)		-- Land Factory

	funcGiveEconomy('uub0001')

	local str1 = LOC(OpStrings.TUT02_Obj_BuildFactory_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_BuildFactory_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Build_Factory = SimObjectives.ArmyStatCompare(
		'primary',									-- type
		'incomplete',								-- status
		OpStrings.TUT02_Obj_BuildFactory_NAME,		-- title
		descText,									-- description
		'build',
		{
			Army = 1,
			StatName = 'Units_Active',
			CompareOp = '>=',
			Value = 1,
			Category = categories.uub0001,
			ShowProgress = true,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Build_Factory)

	ShowUI(OpStrings.TUT02_Obj_BuildFactory_UI[platformIndex])

	ScenarioInfo.Obj_Build_Factory:AddResultCallback(
		function(result)
			-- Get a 'list' (will be one unit) of player factories, and make them unkillable etc. We need to ensure
			-- that one factory makes it to the Addon NIS, as that NIS will zoom to it.
			ScenarioInfo.PlayerLandFactory = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.uub0001, false )
			for k, v in ScenarioInfo.PlayerLandFactory do
        		v:SetReclaimable(false)
        		v:SetCapturable(false)
        		v:SetCanBeKilled(false)
			end
			ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uub0001)
			ScenarioFramework.Dialogue(OpDialog.TUT1_ECON_HINT10, funcBuild_AllCompleteCheck)
		end
	)

	-- When the player begins building the unit, proceed to the next build objective assignment
	ScenarioFramework.CreateArmyStatTrigger (funcBuildMass_VO, ArmyBrains[ARMY_PLAYER], 'funcBuild_Factory_TRIGGER',
			{{StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uub0001}})
end

function funcBuildMass_VO()

	-- create engineers, and move them ahead. Set them as protected.
	ScenarioInfo.PLAYER_ENGINEERS01 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_ENGINEERS01')
	ScenarioInfo.PLAYER_ENGINEERS02 = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_ENGINEERS02')

	ProtectUnit(ScenarioInfo.PLAYER_ENGINEERS01)
	ProtectUnit(ScenarioInfo.PLAYER_ENGINEERS02)

	IssueMove( {ScenarioInfo.PLAYER_ENGINEERS01}, ScenarioUtils.MarkerToPosition( 'ENGINEER_DESTINATION_01' ) )
	IssueMove( {ScenarioInfo.PLAYER_ENGINEERS02}, ScenarioUtils.MarkerToPosition( 'ENGINEER_DESTINATION_02' ) )

	-- while the engineers are moving, introduce the next objective
	ForkThread(
		function()
			OpNIS.NIS_MASS()
			funcBuild_Mass()
		end
	)
end

function funcBuild_Mass()
	-- reset build restrictions, so player doesnt try to build a duplicate unit.
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0701, true)		-- Mass Extractor

	funcGiveEconomy('uub0701')

	local str1 = LOC(OpStrings.TUT02_Obj_BuildMass_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_BuildFactory_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Build_Mass = SimObjectives.ArmyStatCompare(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_BuildMass_NAME,		-- title
		descText,								-- description
		'build',
		{
			Army = 1,
			StatName = 'Units_Active',
			CompareOp = '>=',
			Value = 1,
			Category = categories.uub0701,
			ShowProgress = true,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Build_Mass)
	ScenarioInfo.Obj_Build_Mass:AddResultCallback(
		function(result)
			ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.uub0701)
			funcBuild_AllCompleteCheck()
		end
	)

	-- When the player begins building the unit, proceed to the next build objective assignment
	ScenarioFramework.CreateArmyStatTrigger (funcBuildEnergy_VO, ArmyBrains[ARMY_PLAYER], 'funcBuild_Mass_TRIGGER',
			{{StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uub0701}})
end

function funcBuildEnergy_VO()
	ScenarioFramework.Dialogue(OpDialog.TUT1_POWER_ASSIGN, funcBuild_Energy)
end

function funcBuild_Energy()
	-- reset build restrictions, so player doesnt try to build a duplicate unit.
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0702, true)		-- Power Gen

	funcGiveEconomy('uub0702')

	local str1 = LOC(OpStrings.TUT02_Obj_BuildEnergy_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_BuildFactory_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Build_Energy = SimObjectives.ArmyStatCompare(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_BuildEnergy_NAME,	-- title
		descText,								-- description
		'build',
		{
			Army = 1,
			StatName = 'Units_Active',
			CompareOp = '>=',
			Value = 1,
			Category = categories.uub0702,
			ShowProgress = true,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Build_Energy)
	ScenarioInfo.Obj_Build_Energy:AddResultCallback(
		function(result)
			funcBuild_AllCompleteCheck()
		end
	)
end

function funcBuild_AllCompleteCheck()

	-- each time a build objective is completed incremenet and check, to see if all three are done.
	BuildObjectivesCompleted = BuildObjectivesCompleted + 1

	if BuildObjectivesCompleted == 3 then
		LOG('----- P1: Build objectives completed.')
		ScenarioFramework.Dialogue(OpDialog.TUT1_ALLBUILT, MobileBuild_TransitionThread)
	end
end

---------------------------------------------------------------------
-- Build Mobile Units
---------------------------------------------------------------------

function MobileBuild_TransitionThread()
	ForkThread(
		function()
			OpNIS.NIS_BUILD_INTRO()
			func_MobileBuild()
		end
	)
end

function func_MobileBuild()

	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.ALLUNITS)
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0101, true)		-- Tank
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0001, true)		-- Land Factory
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0702, true)		-- Power Gen
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0701, true)		-- Mass Extractor

	funcGiveEconomy('uul0101')
	funcGiveEconomy('uul0101')

	local totalTanks = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uul0101)
	ScenarioInfo.ObjTotalTanks = totalTanks + 2

	local str1 = LOC(OpStrings.TUT02_Obj_MobileBuild_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_MobileBuild_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_MobileBuild = SimObjectives.ArmyStatCompare(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_MobileBuild_NAME,	-- title
		descText,								-- description
		'build',
		{
			Army = 1,
			StatName = 'Units_Active',
			CompareOp = '>=',
			Value = ScenarioInfo.ObjTotalTanks,
			Category = categories.uul0101,
			ShowProgress = true,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_MobileBuild)

	ShowUI(OpStrings.TUT02_Obj_MobileBuild_UI[platformIndex])

	-- add progress callback for special VO events
	ScenarioInfo.Obj_MobileBuild:AddProgressCallback(
		function(current, total)
			LOG('----- P1: Mobile Build objective, progress: ', current)
			-- at certain points, call functions that will play advisory VO based off checks on player units.
			local tanksPlus = totalTanks + 1
			if current == tanksPlus then
				ScenarioFramework.Dialogue(OpDialog.TUT1_BUILD_HINT_010)
				ShowUI(OpStrings.TUT01_Rally_UI[platformIndex])
			end
		end
	)
	ScenarioInfo.Obj_MobileBuild:AddResultCallback(
		function(result)
			ScenarioFramework.Dialogue(OpDialog.TUT1_BUILD_COMPLETE, funcAddons_Build)
		end
	)
end

---------------------------------------------------------------------
-- Factory Add-ons
---------------------------------------------------------------------

function funcAddons_Build()

	ScenarioFramework.Dialogue(OpDialog.TUT1_NIS_ADD_ASSIGN)

	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.ALLUNITS)

	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0001, true)		-- Land Factory
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0702, true)		-- Power Gen
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0701, true)		-- Mass Extractor
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0211, true)		-- Shield Addon
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0111, true)		-- Shield Addon

	funcGiveEconomy('uum0211')
	funcGiveEconomy('uum0111')

	local str1 = LOC(OpStrings.TUT02_Obj_BuildAddon_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_BuildAddon_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2

	ScenarioInfo.Obj_Build_Addon = SimObjectives.Basic(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_BuildAddon_NAME,	-- title
		descText,								-- description
		SimObjectives.GetActionIcon('build'),	-- Action
		{
		}
	)

	---NOTE: solution for the add-ons not being counted in the unit cap, therefore not showing up with ArmyStatCompare - bfricks 11/10/09
	ForkThread(
		function()
			while ScenarioInfo.Obj_Build_Addon.Active do
				local list = {}
				local count = 0
				list = ArmyBrains[ARMY_PLAYER]:GetListOfUnits( categories.uum0211 + categories.uum0111, true, false )

				for k, v in list do
					if not v:IsBeingBuilt() then
						count = count + 1
					end
				end

				if count == 2 then
					ScenarioInfo.Obj_Build_Addon:ManualResult(true)
					ScenarioFramework.Dialogue(OpDialog.TUT1_ADD_COMPLETE, End_Combat_01_Setup)
					break
				else
			    	WaitTicks(5)
			    end
			end
		end
	)

	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Build_Addon)

	ShowUI(OpStrings.TUT02_Obj_BuildAddon_UI[platformIndex])
end


---------------------------------------------------------------------
-- Ending Combat
---------------------------------------------------------------------


function End_Combat_01_Setup()

	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0001, true)		-- Land Factory
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0701, true)		-- Mass Extractor
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0702, true)		-- Power Gen
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0101, true)		-- Tank

	ScenarioFramework.SetPlayableArea('FINAL_COMBAT_AREA', false)
	ScenarioFramework.CreateIntelAtLocation(250, 'CDR_INITIAL_LOCATION', ARMY_PLAYER, 'Vision')

	ScenarioUtils.CreateArmyGroup( 'ARMY_ENEM01', 'TUT02_Combat1_Structures' )
	ScenarioInfo.EndCombatObjectives = ScenarioUtils.CreateArmyGroup( 'ARMY_ENEM01', 'EndCombatObjectives' )

	ArmyBrains[ARMY_PLAYER]:GiveResource('MASS', 3200 )
	ArmyBrains[ARMY_PLAYER]:GiveResource('ENERGY', 4000 )

	ArmyBrains[ARMY_ENEM01]:GiveResource('MASS', 9001 )
	ArmyBrains[ARMY_ENEM01]:GiveResource('ENERGY', 9001 )

	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'TUT02_Combat1_Mobiles', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'TUT02_Combat1_Mobiles')

	for k, unit in ScenarioInfo.EndCombatObjectives do
		IssueBuildFactory( {unit}, 'uul0101', 5 )
		IssueFactoryRallyPoint( {unit}, ScenarioUtils.MarkerToPosition( 'Base_Marker' ) )
	end

	End_Combat_01_TransitionThread()
end

function End_Combat_01_TransitionThread()
	ForkThread(
		function()
			OpNIS.NIS_END_COMBAT()
			funcEndCombat()
		end
	)
end

function funcEndCombat()

	local str1 = LOC(OpStrings.TUT02_Obj_Combat1_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CommandsAttack_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Combat1 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.TUT02_Obj_Combat1_NAME,	-- title
		descText,							-- description
		{
			FlashVisible = true,
			MarkUnits = true,
			Units = ScenarioInfo.EndCombatObjectives,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Combat1)

	ScenarioFramework.CreateAreaTrigger(PD_Warning, ScenarioUtils.AreaToRect('PD_AREA'),
		categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1)

	ScenarioInfo.Obj_Combat1:AddResultCallback(
		function(result, lastKilledUnit)
			if result then
				local tableVictoryData = {}

				local victoryUnit = ScenarioInfo.PLAYER_CDR
				if lastKilledUnit and not lastKilledUnit:IsDead() then
					victoryUnit = lastKilledUnit
				end

				tableVictoryData.Unit = victoryUnit
				tableVictoryData.Position = victoryUnit:GetPosition()
				tableVictoryData.Heading = victoryUnit:GetHeading()

				ForkThread(OpNIS.NIS_VICTORY, tableVictoryData)
			end
		end
	)
end

function PD_Warning()
	ScenarioFramework.Dialogue(OpDialog.TUT1_PD_WARN)
end



---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function funcGiveEconomy(unit, number)
	local unitBp = GetUnitBlueprintByName(unit)

	local massCost = unitBp.Economy.MassValue
	local energyCost = unitBp.Economy.EnergyValue

	ArmyBrains[ARMY_PLAYER]:GiveResource('MASS', massCost )
	ArmyBrains[ARMY_PLAYER]:GiveResource('ENERGY', energyCost )
end

function SetupAmbientFighters()
	ScenarioInfo.Ambient_Fighters = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'Ambient_Fighters')
	ScenarioFramework.GroupPatrolChain(ScenarioInfo.Ambient_Fighters, 'Ambient_Chain_01')

	for k, unit in ScenarioInfo.Ambient_Fighters do
		unit:SetUnSelectable(true)
		unit:SetDoNotTarget(true)
		ProtectUnit(unit)
	end
end

function SetupAmbientGunships()
	ScenarioInfo.Ambient_Gunships = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'Ambient_Gunships')
	ScenarioFramework.GroupPatrolChain(ScenarioInfo.Ambient_Gunships, 'Ambient_Chain_02')

	for k, unit in ScenarioInfo.Ambient_Gunships do
		unit:SetUnSelectable(true)
		unit:SetDoNotTarget(true)
		ProtectUnit(unit)
	end
end

function destroyArrow01()
	ScenarioInfo.arrow01:Destroy()
end

function destroyArrow02()
	ScenarioInfo.arrow02:Destroy()
	ScenarioFramework.Dialogue(OpDialog.TUT1_MOVE_HINT_010)
	ShowUI(OpStrings.TUT01_Multiselect_UI[platformIndex])
end

function destroyArrow03()
	ScenarioInfo.arrow03:Destroy()
end

function ShowUI(objective)
	--this is the call for PC/360 pop-up
	LOG('---------------- Grabbing a dialog, and displaying: ', objective)
	WaitTicks(1)
	Sync.ShowUIDialog = { objective, "<LOC _OK>OK", "", "", "", "", "", true }
end

function TutCreateArrow(marker, arrowHeightOverride)
	if type(marker) == 'string' then
		marker = import('/lua/sim/ScenarioUtilities.lua').GetMarker(marker)
	end

	-- adjust the arrow up a bit
	arrowHeightOverride = arrowHeightOverride or 2.0

	-- create the arrow object
	marker.Size = 4.0
	marker.position[2] = marker.position[2] + arrowHeightOverride
	local ArrowMarkerObj = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow(marker)

	-- return the handle to the arrow
	return ArrowMarkerObj
end

function CreateAndProtectTransports()
	ScenarioInfo.PlayerNISTransports = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetListOfUnits(categories.uua0901, false )
	for k, v in ScenarioInfo.PlayerNISTransports do
		v:SetUnSelectable(true)
		v:SetDoNotTarget(true)
	end
end

function func_NIS_COMBAT_TransportGroups()
	-- group1
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= 'TUT01_Combat_Group01',					-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.P2_Selection_Transport01,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'TUT01_Combat_TransportDestination_01',	-- destination for the transport drop-off
			returnDest				= 'TUT01_Combat_TransportReturn',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= FlagTransportPlatoon_Callback,			-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= false,									-- will this transport be usable after the NIS?
		}
	)
end

function FlagTransportPlatoon_Callback(platoon)
	-- keep one group unkillable for safety, leave the other not so for some realism
	-- dont let this group of units be destroyed in any way, tho taking damage is ok.
	for k, v in platoon:GetPlatoonUnits() do
		if v and not v:IsDead() then
        	v:SetVeterancy(5)
        	v:SetReclaimable(false)
        	v:SetCapturable(false)
		end
	end
end
---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	ScenarioInfo.PLAYER_CDR:SetUnSelectable(false)
	Selection_Setup()
end

function OnShiftF4()
	ScenarioFramework.SetPlayableArea('COMBAT_AREA', false)
	ScenarioInfo.PLAYER_CDR:SetUnSelectable(false)
	funcBuild_Factory_Setup()
end

function OnShiftF5()
	ScenarioFramework.SetPlayableArea('COMBAT_AREA', false)
	ScenarioInfo.PLAYER_CDR:SetUnSelectable(false)
	End_Combat_01_Setup()
end