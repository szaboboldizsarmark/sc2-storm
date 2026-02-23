---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_TUT_02/SC2_CA_TUT_02_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_TUT_02/SC2_CA_TUT_02_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_TUT_02/SC2_CA_TUT_02_OpNIS.lua')
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

---------------------------------------------------------------------
-- GLOBAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
ScenarioInfo.ARMY_PLAYER = 1
ScenarioInfo.ARMY_ENEM01 = 2
ScenarioInfo.ARMY_ALLY01 = 3

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.tutorial = true

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01

local BuildObjectivesCompleted = 0
local BuildStartedSafetyCount = 0
local BuildSafetyTimer = 300 				-- number of seconds after all 3 builds have been started at which point we will force complete the objectives.

local platformIndex = 1

if IsXbox() then
	platformIndex = 2
end

if ScenarioInfo.Options.UseGamePad then
	platformIndex = 2
end

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
		funcMain		= funcResearch_Assign,	-- if valid, the function to be called after the NIS
		areaStart		= 'PLAYABLE_AREA',		-- if valid, the area to be used for setting the starting playable area
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnInitCamera(data)
end

---------------------------------------------------------------------
-- P1_Setup
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

	ScenarioInfo.PLAYER_ENGINEERS = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_ENGINEERS')

	-- Player cannot build any units
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.ALLUNITS)

	-- Set Economy to zero at start
	ArmyBrains[ARMY_PLAYER]:TakeResource('MASS', 1600 )
	ArmyBrains[ARMY_PLAYER]:TakeResource('ENERGY', 4000 )

	-- Turn off ACU economy
	--ScenarioInfo.PLAYER_CDR:SetProductionPerSecondEnergy ( 0 )
	--ScenarioInfo.PLAYER_CDR:SetProductionPerSecondMass ( 0 )
	ScenarioInfo.PLAYER_CDR:SetProductionPerSecondResearch ( 0 )
end


---------------------------------------------------------------------
-- Research
---------------------------------------------------------------------

function funcResearch_Assign()

	ScenarioFramework.SetPlayableArea('FACTORY_AREA', false)

	--Set up research objective
	local UnlockList = {
		'ULB_RANGE',
	}
	local ObjectiveUnlock = {
		'ULU_ARTILLERY',
		'ULU_ASSAULTBOT',
	}

	local techCountTotal = 0
	local techCostTotal = 0

	-- unlock the ObjectiveUnlock lists of research
	ArmyBrains[ARMY_PLAYER]:ResearchRestrict( UnlockList, false )
	ArmyBrains[ARMY_PLAYER]:ResearchRestrict( ObjectiveUnlock, false )

	for k, tech in ObjectiveUnlock do
		techCostTotal = techCostTotal + ResearchDefinitions[tech].COST
		techCountTotal = techCountTotal + 1
	end

	for k, tech in UnlockList do
		techCostTotal = techCostTotal + ResearchDefinitions[tech].COST
		techCountTotal = techCountTotal + 1
	end

	-- set the max, and give the player all the points required
	ArmyBrains[ARMY_PLAYER]:SetMaxStorage('RESEARCH', techCostTotal)
	ArmyBrains[ARMY_PLAYER]:GiveResource('RESEARCH', techCostTotal)

	local str1 = LOC(OpStrings.TUT02_Obj_Research_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_Research_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Research = SimObjectives.Research(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_Research_NAME,		-- title
		descText,								-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ObjectiveUnlock,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Research)

	ShowUI(OpStrings.TUT02_Obj_Research_UI[platformIndex])

	LOG('----- Research objectives result callbacks')
	--confirmation VO when complete.
	ScenarioInfo.Obj_Research:AddResultCallback(
		function(result)
			if result then
				-- flag the player such that they can not store any research points
				ArmyBrains[ARMY_PLAYER]:SetMaxStorage('RESEARCH', 0)
				ScenarioFramework.Dialogue(OpDialog.TUT2_RESEARCH_COMPLETE, funcResearchComplete_NIS)
			end
		end
	)
end

function funcResearchComplete_NIS()

	ForkThread(
		function()
			--Bring in our tanks, move 'em for their close-up
			ScenarioInfo.Camera_Tank = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'Camera_Tank')
			ScenarioInfo.RESEARCH_TANKS = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'RESEARCH_TANKS')
			ProtectUnit(ScenarioInfo.Camera_Tank)

			IssueClearCommands({ScenarioInfo.Camera_Tank})
			IssueClearCommands(ScenarioInfo.RESEARCH_TANKS)
			IssueMove({ScenarioInfo.Camera_Tank}, ScenarioUtils.MarkerToPosition( 'Research_Tank_Dest' ))
			IssueMove(ScenarioInfo.RESEARCH_TANKS, ScenarioUtils.MarkerToPosition( 'Research_Tank_Dest' ))

			------- NIS to show the effect of the research.
			OpNIS.NIS_RESEARCH()

			funcFaceoff_Assign()
		end
	)
end


---------------------------------------------------------------------
-- Faceoff
---------------------------------------------------------------------

function funcFaceoff_Assign()

	ScenarioInfo.TUT02_Combat1_Mobiles = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'TUT02_Combat1_Mobiles')
	IssueClearCommands(ScenarioInfo.TUT02_Combat1_Mobiles)
	IssueMove(ScenarioInfo.TUT02_Combat1_Mobiles, ScenarioUtils.MarkerToPosition( 'Attack_Tank_Dest' ))

	local str1 = LOC(OpStrings.TUT02_Obj_Faceoff_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CommandsAttack_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Faceoff = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_Faceoff_NAME,		-- title
		descText,								-- description
		{
			FlashVisible = true,
			MarkUnits = true,
			Units = ScenarioInfo.TUT02_Combat1_Mobiles,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Faceoff)

	ForkThread(
		function()
			while (ScenarioInfo.Obj_Faceoff.Active) do
				IssueClearCommands(ScenarioInfo.TUT02_Combat1_Mobiles)
				IssueMove(ScenarioInfo.TUT02_Combat1_Mobiles, ScenarioUtils.MarkerToPosition( 'Attack_Tank_Dest' ))
				WaitSeconds(6.0)
			end
		end
	)

	ScenarioInfo.Obj_Faceoff:AddResultCallback(
		function(result)
			ScenarioFramework.Dialogue(OpDialog.TUT2_FACEOFF_OVER, funcBuild_ResearchStation)
		end
	)
end

---------------------------------------------------------------------
-- Research Station
---------------------------------------------------------------------

function funcBuild_ResearchStation()

	ScenarioFramework.Dialogue(OpDialog.TUT2_STATION_ASSIGN)

	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0801, true)

	funcGiveEconomy('uub0801')

	local str1 = LOC(OpStrings.TUT02_Obj_BuildResearchStation_DESC)
	local str2 = LOC(OpStrings.TUT02_Obj_Build_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_BuildResearchStation = SimObjectives.ArmyStatCompare(
		'primary',										-- type
		'incomplete',									-- status
		OpStrings.TUT02_Obj_BuildResearchStation_NAME,	-- title
		descText,										-- description
		'build',
		{
			Army = 1,
			StatName = 'Units_Active',
			CompareOp = '>=',
			Value = 1,
			Category = categories.uub0801,
			ShowProgress = true,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_BuildResearchStation)

	ScenarioInfo.Obj_BuildResearchStation:AddResultCallback(
		function(result)
			ScenarioFramework.Dialogue(OpDialog.TUT2_STATION_COMPLETE, Transition)
		end
	)
end

---------------------------------------------------------------------
-- Transition
---------------------------------------------------------------------

function Transition()

	ScenarioFramework.SetPlayableArea('TRANSITION_AREA', false)

	import('/lua/system/Utilities.lua').UserConRequest('ui_RenderIcons true')
	import('/lua/system/Utilities.lua').UserConRequest('cam_FarZoom -1')

	OpNIS.NIS_TRANSITION()

	funcSetupFinal()

	funcStrategic_Assign()
end

---------------------------------------------------------------------
-- Strategic Mode
---------------------------------------------------------------------

function funcStrategic_Assign()

	ScenarioFramework.SetPlayableArea('BATTLE_AREA', false)

	local str1 = LOC(OpStrings.TUT02_Obj_Strategic_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CameraZoom_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_Strategic = SimObjectives.Camera(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_Strategic_NAME,		-- title
		descText,								-- description
	        {
	            ScenarioUtils.MarkerToPosition( 'ZOOM_OBJ' ),
	        }
	    )

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_Strategic)

    ScenarioInfo.Obj_Strategic:AddResultCallback(
        function()
            LOG('----- COMPLETE.')
            ScenarioFramework.Dialogue(OpDialog.TUT2_STRATEGIC_COMPLETE, funcFinalCombat_Transition)
        end
    )
end

function funcFinalCombat_Transition()
	--let's give everyone some money to play with
	ArmyBrains[ARMY_PLAYER]:GiveResource('MASS', 1600 )
	ArmyBrains[ARMY_PLAYER]:GiveResource('ENERGY', 4000 )

	ArmyBrains[ARMY_ENEM01]:GiveResource('MASS', 9001 )
	ArmyBrains[ARMY_ENEM01]:GiveResource('ENERGY', 9001 )

	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0001, true)		-- Land Factory
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0701, true)		-- Mass Extractor
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0702, true)		-- Power Gen
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0101, true)		-- Tank
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0211, true)		-- Addon
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0111, true)		-- Addon

	--Our two objective units
	ScenarioInfo.ENEM_OBJ = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM_OBJ')

	--Create south base
	ScenarioInfo.BASE_UNITS_SOUTH = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'BASE_UNITS_SOUTH')
	ScenarioInfo.BASE_MOBILES = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'BASE_MOBILES')

	--create north base
	ScenarioInfo.BASE_UNITS_NORTH = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'BASE_UNITS_NORTH')
	ScenarioInfo.BASE_MOBILES_NORTH = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'BASE_MOBILES_NORTH')

	--start up bases
	funcCreateFinaleFactories()

	--Give player veteran units, set them randomly to "can not kill"
	for k, unit in ScenarioInfo.REAL_BASE do
		if unit and not unit:IsDead() then
        	unit:SetVeterancy(5)
			local killed = RandomInt(1,3)
			if killed == 1 then
				unit:SetCanBeKilled(false)
 			end
 		end
	end

	--Set all player point defenses to invulnerable
	ScenarioInfo.PlayerPD = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetListOfUnits(categories.uub0101, false )
	for k, v in ScenarioInfo.PlayerPD do
		v:SetDoNotTarget(true)
		v:SetCanBeKilled(false)
	end

	ForkThread(
		function()
			funcStartSouth()
			OpNIS.NIS_FINALE()
			funcFinalCombat_Assign()
		end
	)
end

function funcFinalCombat_Assign()
	ArmyBrains[ARMY_PLAYER]:SetMaxStorage('RESEARCH', ScenarioInfo.MaxFinaleResearch)

	local str1 = LOC(OpStrings.TUT02_Obj_FinalCombat_DESC)
	local str2 = LOC(OpStrings.TUT01_Obj_CommandsAttack_UI[platformIndex])
	local descText = str1 .. "\n\n" .. str2
	ScenarioInfo.Obj_FinalCombat = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.TUT02_Obj_FinalCombat_NAME,	-- title
		descText,								-- description
		{
			FlashVisible = true,
			MarkUnits = true,
			Units = ScenarioInfo.ENEM_OBJ,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.Obj_FinalCombat)

	ScenarioFramework.CreateAreaTrigger(funcStartNorth, ScenarioUtils.AreaToRect('NORTH_TRIGGER'),
			categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1)

	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.TUT2_FINALE_FACTORY) end,
			ArmyBrains[ARMY_ENEM01], 'Player_Kill_Factory',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.uub0001}})

	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.TUT2_FINALE_MASS) end,
			ArmyBrains[ARMY_ENEM01], 'Player_Kill_Extractor',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.uub0701,categories.uub0702}})

	ScenarioInfo.Obj_FinalCombat:AddProgressCallback(
		function(current)
			if current == 1 then
				ScenarioFramework.Dialogue(OpDialog.TUT2_FINALE_PROGRESS)
			end
		end
	)
	ScenarioInfo.Obj_FinalCombat:AddResultCallback(
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

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function funcCreateFinaleFactories()

	ScenarioInfo.FACTORIES_SOUTH = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'FACTORIES_SOUTH')
	ScenarioInfo.FACTORIES_NORTH = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'FACTORIES_NORTH')

	IssueFactoryRallyPoint( ScenarioInfo.FACTORIES_SOUTH, ScenarioUtils.MarkerToPosition( 'ENEMY_BASE_SOUTH' ) )
	IssueFactoryRallyPoint( ScenarioInfo.FACTORIES_NORTH, ScenarioUtils.MarkerToPosition( 'ENEMY_BASE_NORTH' ) )

end

function funcStartSouth()
	IssueBuildFactory( ScenarioInfo.FACTORIES_SOUTH, 'uul0101', 10 )
 end

function funcStartNorth()
	IssueAggressiveMove( ScenarioInfo.BASE_MOBILES_NORTH, ScenarioUtils.MarkerToPosition( 'North_Attack' ) )

	IssueBuildFactory( ScenarioInfo.FACTORIES_NORTH, 'uul0104', 3 )
	IssueBuildFactory( ScenarioInfo.FACTORIES_NORTH, 'uul0101', 3 )
	IssueBuildFactory( ScenarioInfo.FACTORIES_NORTH, 'uul0104', 3 )
	IssueBuildFactory( ScenarioInfo.FACTORIES_NORTH, 'uul0101', 3 )
end

function funcSetupFinal()

	local UnlockList = {
		'ULB_RANGE',
		'ULU_ARTILLERY',
		'ULU_ASSAULTBOT',
		'ULU_SHIELDGENERATOR',
		'ULP_DOUBLEBARREL',
		'ULP_AA',
		'ULB_REGENERATION',
		'ULB_HEALTH',
		'ULB_RADAR',
		'ULB_VISION',
		'ULB_HEALTH',
		'ULB_HEALTH2',
	}

	ArmyBrains[ARMY_PLAYER]:CompleteResearch( {'ULU_ANTIMISSILE'} )
	ArmyBrains[ARMY_PLAYER]:CompleteResearch( {'ULB_HEALTH'} )
	ArmyBrains[ARMY_PLAYER]:CompleteResearch( {'ULB_HEALTH2'} )

	local techCountTotal = 0
	local techCostTotal = 0

	-- unlock the ObjectiveUnlock lists of research
	ArmyBrains[ARMY_PLAYER]:ResearchRestrict( UnlockList, false )

	for k, tech in UnlockList do
		if ResearchDefinitions[tech] and ResearchDefinitions[tech].COST then
			local cost = ResearchDefinitions[tech].COST
			if cost and cost > 0.0 then
				techCostTotal = techCostTotal + cost
			end
		else
			WARN('WARNING: somehow a technology in the UNLOCK list for TUT02 is invalid or has no defined COST!')
		end
		techCountTotal = techCountTotal + 1
	end

	-- store the max
	ScenarioInfo.MaxFinaleResearch = techCostTotal

	-- create a trigger that will fire off when the player has researched all possible research
	ScenarioFramework.CreateArmyStatTrigger(
		function()
			-- flag the player such that they can not store any research points
			ArmyBrains[ARMY_PLAYER]:SetMaxStorage('RESEARCH', 0)
		end,
		ArmyBrains[ARMY_PLAYER],
		'PlayerResearchComplete[' .. ARMY_PLAYER .. ']',
		{
			{
				StatType	= 'Economy_Research_Learned_Count',
				CompareType	= 'GreaterThanOrEqual',
				Value		= techCountTotal + ArmyBrains[ARMY_PLAYER]:GetArmyStat("Economy_Research_Learned_Count", 0.0).Value,
			}
		}
	)
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

function funcGiveEconomy(unit, number)
	local unitBp = GetUnitBlueprintByName(unit)

	local massCost = unitBp.Economy.MassValue
	local energyCost = unitBp.Economy.EnergyValue

	ArmyBrains[ARMY_PLAYER]:GiveResource('MASS', massCost )
	ArmyBrains[ARMY_PLAYER]:GiveResource('ENERGY', energyCost )
end
---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	ForkThread(Transition)
end

function OnShiftF4()
	ForkThread(Transition)
end

function OnShiftF5()
	ForkThread(Transition)
end

function ReportResearchPoints()
	ForkThread(
		function()
			while true do
				local curStoredResearch = ArmyBrains[ARMY_PLAYER]:GetEconomyStored('Research')
				LOG('------------- ReportResearchPoints:[', curStoredResearch, ']')
				WaitTicks(1)
			end
		end
	)
end