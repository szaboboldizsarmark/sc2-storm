---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_U01/SC2_CA_U01_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_U01/SC2_CA_U01_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_U01/SC2_CA_U01_OpNIS.lua')
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
local TransportUtils		= import('/lua/sim/ScenarioFramework/ScenarioGameUtilsTransport.lua')
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

ScenarioInfo.HiddenObjectiveSuccess = true

ScenarioInfo.COURTYARD_ASSAULT_UNITS = {}
ScenarioInfo.PLAYER_TANK_COUNT = 0
ScenarioInfo.PLAYER_INTERLUDE_UNIT_COUNT = 0

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
local DELAY_UNIT_REBUILD_PROMPT		= 10.0		-- dialog prompt - fairly rote - no need to tune really
local DELAY_UNIT_KILLED_CHECK		= 60.0		-- dialog prompt - fairly rote - no need to tune really
local DELAY_RESEARCH_REMINDER		= 240.0		-- dialog prompt - fairly rote - no need to tune really

-- PART 1 core tuning variables:
local DELAY_BEFORE_BOT_ATTACKS		= 60.0		-- primary pacing meter, after this delay, the P1 bots will start splitting off and attacking
local DELAY_BETWEEN_BOT_ATTACKS		= 30.0		-- once the DELAY_BEFORE_BOT_ATTACKS has passed, this interval is used for scheduling the waves
local ALLY01_ItemHealthCourtyard_SM	= 200		-- health value being forced for all small courtyard enemy targets
local ALLY01_ItemHealthCourtyard_LG	= 2000		-- health value being forced for all large courtyard enemy targets

-- PART 2 core tuning variables:
local DELAY_RESEARCH_SETUP			= 16.0		-- delay after the start of the interlude before we proceed with research instructions
local DELAY_HINTVO_01				= 20.0		-- delay for some hint VO that will play during part 1 only
local DELAY_HINTVO_02				= 50.0		-- delay for some hint VO that will play during part 1 only
local DELAY_HINTVO_03				= 80.0		-- delay for some hint VO that will play during part 1 only
local DELAY_FORCED_TRANSITION		= 120.0		-- after research is assigned, how long to wait before forcing a transition?
local DELAY_ONRESEARCH_TRANSITION	= 20.0		-- after research is completed, how long to wait before forcing a transition?
local DELAY_ONUNITCOUNT_TRANSITION	= 10.0		-- after reaching significant unit count, how long to wait before forcing a transition?
local DELAY_BEFORE_SECONDWAVE		= 65.0		-- after reinforcements have begun, how long to wait before launching the second attack?
local AUTO_TRANSITION_COUNT			= 10		-- required number of units before auto-advancing
local ALLY01_ItemHealthApproach_SM	= 4000		-- health value being forced for all small approach enemy targets
local ALLY01_ItemHealthApproach_LG	= 12000		-- health value being forced for all large approach enemy targets

-- PART 2 reinforcements tuning variables:
local PLAYER_Zone1TransCount		= 6			-- number of transports to send to zone 1 for the main player reinforcements
local PLAYER_Zone1UnitCount			= 4			-- number of units per transport for the main player reinforcements

-- tracking variables:
local ALLY01_ItemCountCourtyard		= 0			-- tracking value for number of courtyard items
local ALLY01_ItemCountApproach		= 0			-- tracking value for number of approach items

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
-- basically this is an operation built around two waves of attacks - one during part1, one during part2

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

	local WeatherDefinition = {
		MapStyle = "Tundra",
		WeatherTypes = {
			{
				Type = "DuskClouds01",
				Chance = 1.0,
			},
		},
		Direction = {0,0,0},
	}
	Weather.CreateWeather(WeatherDefinition)

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.U01_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.U01_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_ALLY01,	ScenarioGameTuning.color_CIV_U01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CIVL01,	ScenarioGameTuning.color_CIV_U01)

	LOG('----- OnPopulate: Update Build and Research Restrictions.')
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.ALLUNITS) 				-- Restrict all units

	-- enable builders
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0001, true)		-- Enable construction of the UEF land factory
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0002, true)		-- Enable engineer

	-- enable non-research bound structures
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0101, true)		-- Enable PD tower
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0701, true)		-- Enable mass extractor
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0702, true)		-- Enable energy production facility

	-- enable non-research bound mobile units
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0101, true)		-- Enable tank
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0104, true)		-- Enable m-truck

	-- enable selected addons
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0111, true)		-- Enable PD add-ons
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0211, true)		-- Enable shield add-ons
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
		areaStart		= 'AREA_2',				-- if valid, the area to be used for setting the starting playable area
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
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	LOG('----- P1_Setup: Setup scenario units.')
	-- ally starting units
	ScenarioInfo.ALLY01_COMM_ARRAY			= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_COMM_ARRAY')

	ScenarioInfo.ALLY01_APPROACH_ITEMS		= ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'ITEMS_APPROACH')
	ScenarioInfo.APPROACH_UNIT_ZONE_1		= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'APPROACH_UNIT_ZONE_1')
	ScenarioInfo.APPROACH_UNIT_ZONE_2		= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'APPROACH_UNIT_ZONE_2')
	ScenarioInfo.APPROACH_UNIT_ZONE_3		= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'APPROACH_UNIT_ZONE_3')
	ScenarioInfo.APPROACH_UNIT_ZONE_4		= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'APPROACH_UNIT_ZONE_4')
	ScenarioInfo.APPROACH_UNIT_ZONE_5		= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'APPROACH_UNIT_ZONE_5')
	ScenarioInfo.APPROACH_UNIT_ZONE_6		= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'APPROACH_UNIT_ZONE_6')

	ScenarioInfo.ALLY01_COURTYARD_ITEMS		= ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'ITEMS_COURTYARD')
	ScenarioInfo.CYARD_UNIT_ZONE_1			= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'CYARD_UNIT_ZONE_1')
	ScenarioInfo.CYARD_UNIT_ZONE_2			= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'CYARD_UNIT_ZONE_2')
	ScenarioInfo.CYARD_UNIT_ZONE_3			= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'CYARD_UNIT_ZONE_3')
	ScenarioInfo.CYARD_UNIT_ZONE_4			= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'CYARD_UNIT_ZONE_4')
	ScenarioInfo.CYARD_UNIT_ZONE_5			= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'CYARD_UNIT_ZONE_5')
	ScenarioInfo.CYARD_UNIT_ZONE_6			= ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'CYARD_UNIT_ZONE_6')

	ScenarioInfo.ALLY01_TOWERS_GATE			= ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'ALLY01_TOWERS_GATE')
	ScenarioInfo.ALLY01_WALL_TOWERS_NORTH	= ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'ALLY01_WALL_TOWERS_NORTH')
	ScenarioInfo.ALLY01_WALL_TOWERS_SOUTH	= ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'ALLY01_WALL_TOWERS_SOUTH')
	ScenarioInfo.NIS_NUKED_UNITS_AREA_01	= ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'NIS_NUKED_UNITS_AREA_01')
	ScenarioInfo.NIS_NUKED_UNITS_AREA_02	= ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'NIS_NUKED_UNITS_AREA_02')

	-- protect key units
	ProtectUnit(ScenarioInfo.ALLY01_COMM_ARRAY)

	-- make sure a few items in the courtyard do not immediately die - we want to wait for the player to get nearby
	ProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_1)
	ProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_2)
	ProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_3)
	ProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_4)
	ProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_5)
	ProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_6)
	ScenarioInfo.CYARD_UNIT_ZONE_1:SetDoNotTarget(false)
	ScenarioInfo.CYARD_UNIT_ZONE_2:SetDoNotTarget(false)
	ScenarioInfo.CYARD_UNIT_ZONE_3:SetDoNotTarget(false)
	ScenarioInfo.CYARD_UNIT_ZONE_4:SetDoNotTarget(false)
	ScenarioInfo.CYARD_UNIT_ZONE_5:SetDoNotTarget(false)
	ScenarioInfo.CYARD_UNIT_ZONE_6:SetDoNotTarget(false)

	-- likewise, make sure a few items in the approach area do not immediately die - we want to wait for the player to get nearby
	ProtectUnit(ScenarioInfo.APPROACH_UNIT_ZONE_1)
	ProtectUnit(ScenarioInfo.APPROACH_UNIT_ZONE_2)
	ProtectUnit(ScenarioInfo.APPROACH_UNIT_ZONE_3)
	ProtectUnit(ScenarioInfo.APPROACH_UNIT_ZONE_4)
	ProtectUnit(ScenarioInfo.APPROACH_UNIT_ZONE_5)
	ProtectUnit(ScenarioInfo.APPROACH_UNIT_ZONE_6)
	ScenarioInfo.APPROACH_UNIT_ZONE_1:SetDoNotTarget(false)
	ScenarioInfo.APPROACH_UNIT_ZONE_2:SetDoNotTarget(false)
	ScenarioInfo.APPROACH_UNIT_ZONE_3:SetDoNotTarget(false)
	ScenarioInfo.APPROACH_UNIT_ZONE_4:SetDoNotTarget(false)
	ScenarioInfo.APPROACH_UNIT_ZONE_5:SetDoNotTarget(false)
	ScenarioInfo.APPROACH_UNIT_ZONE_6:SetDoNotTarget(false)

	-- add these custom units to the main courtyard list
	table.insert(ScenarioInfo.ALLY01_COURTYARD_ITEMS, ScenarioInfo.CYARD_UNIT_ZONE_2)
	table.insert(ScenarioInfo.ALLY01_COURTYARD_ITEMS, ScenarioInfo.CYARD_UNIT_ZONE_3)
	table.insert(ScenarioInfo.ALLY01_COURTYARD_ITEMS, ScenarioInfo.CYARD_UNIT_ZONE_4)
	table.insert(ScenarioInfo.ALLY01_COURTYARD_ITEMS, ScenarioInfo.CYARD_UNIT_ZONE_5)

	-- do some other ally unit handling
	P1_AllyUnitSetup()

	-- set starting health
	SetStartingGroupHealth(ScenarioInfo.ALLY01_WALL_TOWERS_NORTH, 1)
	SetStartingGroupHealth(ScenarioInfo.ALLY01_WALL_TOWERS_SOUTH, 1)

	-- player starting units
	ScenarioInfo.FACTORY_01				= ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'FACTORY_01')
	ScenarioInfo.FACTORY_02				= ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'FACTORY_02')
	ScenarioInfo.MASS_01				= ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'MASS_01')
	ScenarioInfo.MASS_02				= ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'MASS_02')
	ScenarioInfo.POWER_01				= ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'POWER_01')
	ScenarioInfo.POWER_02				= ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'POWER_02')
	ScenarioInfo.PLAYER_TANKS_01		= ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_TANKS_01')
	ScenarioInfo.PLAYER_TANKS_02		= ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'PLAYER_TANKS_02')

	-- count the tanks and store it
	ScenarioInfo.PLAYER_TANK_COUNT = table.getn(ScenarioInfo.PLAYER_TANKS_01) + table.getn(ScenarioInfo.PLAYER_TANKS_02)
	if ScenarioInfo.PLAYER_TANK_COUNT < 8 then
		WARN('WARNING: ScenarioInfo.PLAYER_TANK_COUNT < 8 - bug bfricks, this is not properly supported and might lead to some dialog wonkiness. - bfricks 9/24/09')
	end

	LOG('----- P1_Setup: Setup player intel')
	ScenarioFramework.CreateIntelAtLocation(400, 'P1_INTEL', ARMY_PLAYER, 'Vision')
end

function P1_Main()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Kill Assault Bots
	----------------------------------------------
	LOG('----- P1_Main: Primary Objective M1_obj10 - Kill Assault Bots.')
	local descText = OpStrings.U01_M1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U01_M1_obj10_SURV_PART1)
	-- now create the objective
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',                   	-- status
		OpStrings.U01_M1_obj10_NAME,  		-- title
		descText,  							-- description
		{
			MarkUnits = true,
			Units = ScenarioInfo.COURTYARD_ASSAULT_UNITS,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	LOG('----- P1_Main: M1 AddProgressCallback(s)')
	ScenarioInfo.M1_obj10:AddProgressCallback(
		function(current)
			if current == 10 then
				-- play dialog
				LOG('----- P1_Main: Dialogue: U01_ALLY_REINFORCEMENTS_010')
				ScenarioFramework.Dialogue(OpDialog.U01_ALLY_REINFORCEMENTS_010)
			end
		end
	)

	LOG('----- P1_Main: M1 AddResultCallback(s)')
	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				-- complete the hidden objective if needed
				if ScenarioInfo.HiddenObjectiveSuccess then
					ForkThread(HiddenObjectiveCompleteThread)
				else
					---NOTE: we give the player these points for sure, but they get more if they complete the hidden objective - bfricks 11/22/09
					-- give some bonus points to the player
					ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U01_M1_obj10_SURV_PART1, ARMY_PLAYER, 3.0)
				end
				LOG('----- P1_Main: Dialogue: U01_M1_obj10_COMPLETE')
				ScenarioFramework.Dialogue(OpDialog.U01_M1_obj10_COMPLETE, ResearchInterlude)
			end
		end
	)

	-- and now we unprotect the target units - so the player can kill them
	UnProtectGroup(ScenarioInfo.COURTYARD_ASSAULT_UNITS)

	-- begin handling player unit deaths
	UnitDeathVOTriggers()

	-- handle the p1 hidden objective
	for k, unit in ScenarioInfo.PLAYER_TANKS_01 do
		ScenarioFramework.CreateUnitDeathTrigger( HiddenObjectiveFailed, unit )
	end
	for k, unit in ScenarioInfo.PLAYER_TANKS_02 do
		ScenarioFramework.CreateUnitDeathTrigger( HiddenObjectiveFailed, unit )
	end
end

function HiddenObjectiveFailed()
	ScenarioInfo.HiddenObjectiveSuccess = false
end

function P1_AllyUnitSetup()
	for i, unit in ScenarioInfo.ALLY01_COURTYARD_ITEMS do
		-- increment our count
		ALLY01_ItemCountCourtyard = ALLY01_ItemCountCourtyard + 1

		-- adjust health
		if EntityCategoryContains( categories.scb0002, unit ) then
			SetStartingUnitHealth(unit, ALLY01_ItemHealthCourtyard_LG)
		else
			SetStartingUnitHealth(unit, ALLY01_ItemHealthCourtyard_SM)
		end

		-- disable any death weapons
		unit:SetDeathWeaponEnabled(false)
	end

	for i, unit in ScenarioInfo.ALLY01_APPROACH_ITEMS do
		-- protect the approach units until part3
		ProtectUnit(unit)

		-- adjust health
		if EntityCategoryContains( categories.scb0002, unit ) then
			SetStartingUnitHealth(unit, ALLY01_ItemHealthApproach_LG)
		else
			SetStartingUnitHealth(unit, ALLY01_ItemHealthApproach_SM)
		end

		-- increment our count
		ALLY01_ItemCountApproach = ALLY01_ItemCountApproach + 1

		-- disable any death weapons
		unit:SetDeathWeaponEnabled(false)
	end
end
---------------------------------------------------------------------
-- Research Interlude:
---------------------------------------------------------------------
function ResearchInterlude()
	LOG('----- ResearchInterlude: Dialogue: U01_BANTER_020')
	ScenarioFramework.Dialogue(OpDialog.U01_BANTER_020)

	ScenarioInfo.PLAYER_INTERLUDE_UNIT_COUNT = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.MOBILE * categories.LAND)

	----------------------------------------------
	-- Primary Objective M1_obj20 - Build up Defenses
	----------------------------------------------
	LOG('----- ResearchInterlude: Assign Primary Objective M1_obj20 - Build up Defenses.')
	ScenarioInfo.M1_obj20 = SimObjectives.Basic(
		'primary',										-- type
		'incomplete',									-- status
		OpStrings.U01_M1_obj20_NAME,					-- title
		OpStrings.U01_M1_obj20_DESC,					-- description
		SimObjectives.GetActionIcon('build'),			-- Action
		{
			Areas = {
				'CAMERA_ZOOM_AREA_01',
				'CAMERA_ZOOM_AREA_02',
				'CAMERA_ZOOM_AREA_03',
			}
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj20)

	-- setup a trigger for when Zoe will come on-line to introduce research
	ScenarioFramework.CreateTimerTrigger(ResearchObjectiveSetup, DELAY_RESEARCH_SETUP)
end

function HiddenObjectiveCompleteThread()
	-- give a small delay here to keep from objective stacking
	WaitSeconds(2.0)

	----------------------------------------------
	-- Hidden Objective H1_obj10 - Survivor
	----------------------------------------------
	LOG('----- ResearchInterlude: Complete Hidden Objective H1_obj10 - Survivor')
	local descText = OpStrings.U01_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U01_H1_obj10_SURV_PART1)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.U01_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('protect'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U01_H1_obj10_SURV_PART1, ARMY_PLAYER, 3.0)
end

function ResearchObjectiveSetup()
	ScenarioFramework.Dialogue(OpDialog.U01_RESEARCH_SETUP_010, ResearchSecondary_VO)
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0801, true) -- Enable research facility
end

function ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.U01_RESEARCH_UNLOCK, ResearchSecondary_Assign)

	-- call dialog when the player builds a research station
	ScenarioFramework.CreateArmyStatTrigger(
		function()
			LOG('----- ResearchSecondary_VO: Dialogue: U01_RESEARCH_STATION_BUILT_010')
			ScenarioFramework.Dialogue(OpDialog.U01_RESEARCH_STATION_BUILT_010)
		end,
		ArmyBrains[ARMY_PLAYER],
		'PLAYER_RESEARCH_STATION_CHECK',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'GreaterThanOrEqual',
				Value = 1,
				Category = categories.uub0801,
			},
		}
	)
end

function ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.U01_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- ResearchSecondary_Assign: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.U01_S1_obj10_NAME,	-- title
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
				ScenarioFramework.Dialogue(OpDialog.U01_RESEARCH_FOLLOWUP_ARTILLERY_010)

				-- once research is completed - we will force the P2_ReinforcementSequence on this trigger
				ScenarioFramework.CreateTimerTrigger(P2_ReinforcementSequence, DELAY_ONRESEARCH_TRANSITION)
			end
		end
	)

	-- after a bit, play some hint VO
	ScenarioFramework.CreateTimerTrigger(HintVO_01, DELAY_HINTVO_01)
	ScenarioFramework.CreateTimerTrigger(HintVO_02, DELAY_HINTVO_02)
	ScenarioFramework.CreateTimerTrigger(HintVO_03, DELAY_HINTVO_03)

	-- once research is assigned - we will force the P2_ReinforcementSequence on this trigger
	ScenarioFramework.CreateTimerTrigger(P2_ReinforcementSequence, DELAY_FORCED_TRANSITION)

	-- if the player reaches this specific thresh-hold - we will force the P2_ReinforcementSequence on this trigger
	ScenarioFramework.CreateArmyStatTrigger(
		function()
			-- once the set number of units has been reached - we will force the P2_ReinforcementSequence on this trigger
			ScenarioFramework.CreateTimerTrigger(P2_ReinforcementSequence, DELAY_ONUNITCOUNT_TRANSITION)
		end,
		ArmyBrains[ARMY_PLAYER],
		'AddUnitCountTrgger_CHECK',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'GreaterThanOrEqual',
				Value = ScenarioInfo.PLAYER_INTERLUDE_UNIT_COUNT + AUTO_TRANSITION_COUNT,
				Category = categories.MOBILE * categories.LAND,
			},
		}
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, DELAY_RESEARCH_REMINDER)

	-- give some bonus points to the player
	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U01_ZZ_EXTRA_JUMPSTART_RESEARCH, ARMY_PLAYER, 3.0)
end

function ResearchReminder1()
	if ScenarioInfo.S1_obj10.Active then
		LOG('----- ResearchReminder1: Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.U01_RESEARCH_REMINDER_010)
	end
end

function HintVO_01()
	if ScenarioInfo.PartNumber == 1 then
		LOG('----- HintVO_01: Dialogue: U01_HINT_DEFENSIVE_TOWERS')
		ScenarioFramework.Dialogue(OpDialog.U01_HINT_DEFENSIVE_TOWERS)
	end
end

function HintVO_02()
	if ScenarioInfo.PartNumber == 1 then
		if not ScenarioInfo.Killed02_Played then
			ScenarioInfo.Killed02_Played = true
			LOG('----- HintVO_01: Dialogue: U01_PLYR_UNIT_KILLED_020')
			ScenarioFramework.Dialogue(OpDialog.U01_PLYR_UNIT_KILLED_020)
		end
	end
end

function HintVO_03()
	if ScenarioInfo.PartNumber == 1 then
		if not ScenarioInfo.Killed03_Played then
			ScenarioInfo.Killed03_Played = true
			LOG('----- HintVO_01: Dialogue: U01_PLYR_UNIT_KILLED_030')
			ScenarioFramework.Dialogue(OpDialog.U01_PLYR_UNIT_KILLED_030)
		end
	end
end

---------------------------------------------------------------------
-- PART 2:
---------------------------------------------------------------------
function P2_ReinforcementSequence()
	-- early out if we are already in part 2
	if ScenarioInfo.PartNumber >= 2 then
		return
	end

	LOG('----- P2_ReinforcementSequence: firing off the sequence of events that will lead to the second attack.')
	ScenarioInfo.PartNumber = 2

	PLAYER_Reinforcements()

	-- begin second attack soon
	ScenarioFramework.CreateTimerTrigger (P2_Setup, DELAY_BEFORE_SECONDWAVE)
end

function P2_Setup()
	LOG('----- P2_Setup: Initial setup and creation of P3 units, commands, etc')
	-- clear the assault platoons tracking list
	ScenarioInfo.COURTYARD_ASSAULT_UNITS = {}

	-- new enemy units
	ScenarioInfo.ENEM01_EXPERIMENTAL_01	= ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_EXPERIMENTAL_01')
	ScenarioInfo.ENEM01_EXPERIMENTAL_02	= ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_EXPERIMENTAL_02')
	ScenarioInfo.ENEM01_ESCORT			= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_ESCORT')
	ScenarioInfo.ENEM01_SECONDWAVE_01	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_SECONDWAVE_01')
	ScenarioInfo.ENEM01_SECONDWAVE_02	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_SECONDWAVE_02')
	ScenarioInfo.ENEM01_SECONDWAVE_03	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_SECONDWAVE_03')
	ScenarioInfo.ENEM01_SECONDWAVE_04	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_SECONDWAVE_04')
	ScenarioInfo.ENEM01_SECONDWAVE_05	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_SECONDWAVE_05')
	ScenarioInfo.ENEM01_SECONDWAVE_06	= ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'ENEM01_SECONDWAVE_06')

	-- flag the megaliths with veterancy
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_EXPERIMENTAL_01, 5)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_EXPERIMENTAL_02, 5)

	-- unprotect the approach items
	UnProtectGroup(ScenarioInfo.ALLY01_APPROACH_ITEMS)

	ForkThread(P2_Transition)
end

function P2_Transition()
	-- clear out the bridge before triggering the NIS
	local playerUnitsOnBridge = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS - categories.MOBILE, 'AREA_PART2_CHECK', ArmyBrains[ARMY_PLAYER])
	if table.getn(playerUnitsOnBridge) > 0 then
		ForceGroupDeath(playerUnitsOnBridge)
	end

	OpNIS.NIS_REVEAL_ENEMY()
	P2_Main()
end

function P2_Main()
	LOG('----- P2_Main: AI Function(s) and Special Event Triggers (Attacks, Reminders, Scripted Vinettes)')

	-- complete the previous defense objective
	ScenarioInfo.M1_obj20:ManualResult(true)

	----------------------------------------------
	-- Primary Objective M2_obj10 - Kill the Experimental
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M2_obj10 - Kill the Experimental.')
	ScenarioInfo.M2_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',                   	-- status
		OpStrings.U01_M2_obj10_NAME,  		-- title
		OpStrings.U01_M2_obj10_DESC,  		-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			AlwaysInRadar = true,
			Units = { ScenarioInfo.ENEM01_EXPERIMENTAL_01,ScenarioInfo.ENEM01_EXPERIMENTAL_02 },
		}
	)
	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)

	ScenarioInfo.M2_obj10:AddProgressCallback(
		function(current)
			if current == 1 then
				ExperimentalProgressVO()
			end
		end
	)

	-- setup the experimentals for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEM01_EXPERIMENTAL_01, LaunchVictoryNIS)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEM01_EXPERIMENTAL_02, LaunchVictoryNIS)

	LOG('----- P2_Main: AI Function(s) and Special Event Triggers (Attacks, Reminders, Scripted Vinettes)')
	-- provide explicit commands for the approaching enemies
	P2_MainApproach()
	ForkThread(P2_SecondWaveAttackThread, ScenarioInfo.ENEM01_SECONDWAVE_01, ScenarioInfo.APPROACH_UNIT_ZONE_1, (DELAY_BETWEEN_BOT_ATTACKS * 0.8))
	ForkThread(P2_SecondWaveAttackThread, ScenarioInfo.ENEM01_SECONDWAVE_02, ScenarioInfo.APPROACH_UNIT_ZONE_2, (DELAY_BETWEEN_BOT_ATTACKS * 0.5))
	ForkThread(P2_SecondWaveAttackThread, ScenarioInfo.ENEM01_SECONDWAVE_03, ScenarioInfo.APPROACH_UNIT_ZONE_3, (DELAY_BETWEEN_BOT_ATTACKS * 3.0))
	ForkThread(P2_SecondWaveAttackThread, ScenarioInfo.ENEM01_SECONDWAVE_04, ScenarioInfo.APPROACH_UNIT_ZONE_4, (DELAY_BETWEEN_BOT_ATTACKS * 2.0))
	ForkThread(P2_SecondWaveAttackThread, ScenarioInfo.ENEM01_SECONDWAVE_05, ScenarioInfo.APPROACH_UNIT_ZONE_5, (DELAY_BETWEEN_BOT_ATTACKS * 4.8))
	ForkThread(P2_SecondWaveAttackThread, ScenarioInfo.ENEM01_SECONDWAVE_06, ScenarioInfo.APPROACH_UNIT_ZONE_6, (DELAY_BETWEEN_BOT_ATTACKS * 7.5))
end

function P2_SecondWaveAttackThread(group, targetUnit, forcedAttackDelay)
	-- clear any lingering commands
	IssueClearCommands( group )

	-- attack the target
	IssueAttack( group, targetUnit )

	local readyToProceed = false

	-- advance condition 1: player proximity
	ScenarioFramework.CreateUnitNearTypeTrigger( function() readyToProceed = true end, targetUnit, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 50.0 )

	-- advance condition 2: timer
	ScenarioFramework.CreateTimerTrigger( function() readyToProceed = true end, forcedAttackDelay )

	while not readyToProceed do
		WaitSeconds(1.1)
	end

	if targetUnit and not targetUnit:IsDead() then
		local health = RandomInt(1,ALLY01_ItemHealthApproach_LG)
		SetStartingUnitHealth(targetUnit, health)
		UnProtectUnit(targetUnit)
	end

	-- clear any lingering commands
	IssueClearCommands( group )

	-- enter the base
	IssueMove( group, ScenarioUtils.MarkerToPosition( 'ESCORT_MOVE_LOC' ) )
	IssuePatrol( group, ScenarioUtils.MarkerToPosition( 'ESCORT_MOVE_LOC' ) )
	IssuePatrol( group, ScenarioUtils.MarkerToPosition( 'ENEM01_LANDING_ZONE_' .. RandomInt(1,6) ) )
end

function P2_MainApproach()
	-- clear any lingering commands
	IssueClearCommands({ScenarioInfo.ENEM01_EXPERIMENTAL_01})
	IssueClearCommands({ScenarioInfo.ENEM01_EXPERIMENTAL_02})
	IssueClearCommands(ScenarioInfo.ENEM01_ESCORT)

	-- the megaliths will start by advancing through the some of the zone units, then patrol into the base and attack the ACU
	IssueAttack( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, ScenarioInfo.APPROACH_UNIT_ZONE_2 )

	for k, unit in ScenarioInfo.ALLY01_TOWERS_GATE do
		if unit and not unit:IsDead() then
			IssueAttack( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, unit )
		end
	end

	IssueMove( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, ScenarioUtils.MarkerToPosition( 'EXPERIMENTAL_MOVE_LOC' ) )
	IssueMove( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, ScenarioUtils.MarkerToPosition( 'EXPERIMENTAL_MOVE_LOC_02' ) )
	IssueAttack( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, ScenarioInfo.PLAYER_CDR )

	IssueAttack( {ScenarioInfo.ENEM01_EXPERIMENTAL_02}, ScenarioInfo.APPROACH_UNIT_ZONE_2 )
	IssueAttack( {ScenarioInfo.ENEM01_EXPERIMENTAL_02}, ScenarioInfo.APPROACH_UNIT_ZONE_5 )
	IssueAttack( {ScenarioInfo.ENEM01_EXPERIMENTAL_02}, ScenarioInfo.APPROACH_UNIT_ZONE_3 )
	IssueMove( {ScenarioInfo.ENEM01_EXPERIMENTAL_02}, ScenarioUtils.MarkerToPosition( 'OUTSIDE_GATE_POS_3' ) )
	IssueAttack( {ScenarioInfo.ENEM01_EXPERIMENTAL_02}, ScenarioInfo.PLAYER_CDR )

	-- the escorts will divide up and randomly pick targets to chew through, then patrol chaotically around
	for k, unit in ScenarioInfo.ENEM01_ESCORT do
		-- pick up to eight random targets then patrol
		local maxCount = table.getn(ScenarioInfo.ALLY01_APPROACH_ITEMS)

		for i = 1,RandomInt(2,8) do
			local target = ScenarioInfo.ALLY01_APPROACH_ITEMS[RandomInt(1,maxCount)]

			if target and not target:IsDead() then
				IssueAttack({unit}, target)
			end
		end

		-- now patrol to a random end point, then the base
		IssuePatrol( {unit}, ScenarioUtils.MarkerToPosition( 'NIS_DEST_SECONDWAVE_0' .. RandomInt(1,6) ) )
		IssuePatrol( {unit}, ScenarioUtils.MarkerToPosition( 'ENEM01_LANDING_ZONE_' .. RandomInt(1,6) ) )
	end
end

---------------------------------------------------------------------
-- DIALOG TRIGGERS/ FUNCTIONS:
---------------------------------------------------------------------
function UnitDeathVOTriggers()
	-- start a chain of triggers for the player losing tanks
	PlayerUnitDeathTrigger01()

	-- handle ally courtyard item count drops below ALLY01_ItemCountCourtyard
	local fullCount = ArmyBrains[ARMY_ALLY01]:GetCurrentUnits(categories.ALLUNITS)
	ScenarioFramework.CreateArmyStatTrigger(
		function()
			LOG('----- UnitDeathVOTriggers: Dialogue: U01_ALLY_UNIT_KILLED_010')
			ScenarioFramework.Dialogue(OpDialog.U01_ALLY_UNIT_KILLED_010)
		end,
		ArmyBrains[ARMY_ALLY01],
		'ALLY01_COURTYARD_UNIT_CHECK_010',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'LessThan',
				Value = fullCount - 8,
				Category = categories.ALLUNITS,
			},
		}
	)

	-- add a call for the player losing a factory
	ScenarioFramework.CreateArmyStatTrigger(
		PlayerFactoryDeathCheckTrigger,
		ArmyBrains[ARMY_PLAYER],
		'PLAYER_FACTORY_CHECK_010',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'LessThan',
				Value = 2,
				Category = categories.uub0001,
			},
		}
	)

	-- add a call for the player losing a mass extractor
		ScenarioFramework.CreateArmyStatTrigger(
		PlayerExtractorDeathCheckTrigger,
		ArmyBrains[ARMY_PLAYER],
		'PLAYER_EXTRACTOR_CHECK_010',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'LessThan',
				Value = 2,
				Category = categories.uub0701,
			},
		}
	)

	-- add a call for the player losing a power generator
		ScenarioFramework.CreateArmyStatTrigger(
		PlayerPGenDeathCheckTrigger,
		ArmyBrains[ARMY_PLAYER],
		'PLAYER_PGEN_CHECK_010',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'LessThan',
				Value = 2,
				Category = categories.uub0702,
			},
		}
	)
end

function PlayerFactoryDeathCheckTrigger()
	-- after a delay, check how many factories the player has - if the player has not started a new factory, play the VO
	ScenarioFramework.CreateTimerTrigger(
		function()
			if ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0001) < 2 then
				LOG('----- PlayerFactoryDeathCheckTrigger: Dialogue: U01_PLYR_FACTORY_KILLED_010')
				ScenarioFramework.Dialogue(OpDialog.U01_PLYR_FACTORY_KILLED_010)
			end
		end,
		DELAY_UNIT_REBUILD_PROMPT
	)
end

function PlayerExtractorDeathCheckTrigger()
	-- after a delay, check how many extractors the player has - if the player has not started a new extractor, play the VO
	ScenarioFramework.CreateTimerTrigger(
		function()
			if ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0701) < 2 then
				LOG('----- PlayerExtractorDeathCheckTrigger: Dialogue: U01_PLYR_EXTRACTOR_KILLED_010')
				ScenarioFramework.Dialogue(OpDialog.U01_PLYR_EXTRACTOR_KILLED_010)
			end
		end,
		DELAY_UNIT_REBUILD_PROMPT
	)
end

function PlayerPGenDeathCheckTrigger()
	-- after a delay, check how many power generators the player has - if the player has not started a new pgen, play the VO
	ScenarioFramework.CreateTimerTrigger(
		function()
			if ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0702) < 2 then
				LOG('----- PlayerPGenDeathCheckTrigger: Dialogue: U01_PLYR_PGEN_KILLED_010')
				ScenarioFramework.Dialogue(OpDialog.U01_PLYR_PGEN_KILLED_010)
			end
		end,
		DELAY_UNIT_REBUILD_PROMPT
	)
end

function PlayerUnitDeathTrigger01()
	-- handle player combat unit count drops below PLAYER_UnitActiveMin
	ScenarioFramework.CreateArmyStatTrigger(
		PlayerUnitDeathDialog01,
		ArmyBrains[ARMY_PLAYER],
		'PLAYER_UNIT_CHECK_010',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'LessThan',
				Value = ScenarioInfo.PLAYER_TANK_COUNT - 4,
				Category = categories.uul0101 + categories.uul0104,
			},
		}
	)
end

function PlayerUnitDeathDialog01()
	LOG('----- PlayerUnitDeathDialog01: Dialogue: U01_PLYR_UNIT_KILLED_010')
	ScenarioFramework.Dialogue(OpDialog.U01_PLYR_UNIT_KILLED_010)

	-- after a delay, create another stat trigger to continue to provide feedback if needed
	ScenarioFramework.CreateTimerTrigger(PlayerUnitDeathTrigger02, DELAY_UNIT_KILLED_CHECK)
end

function PlayerUnitDeathTrigger02()
	-- handle player combat unit count drops below PLAYER_UnitActiveMin
	ScenarioFramework.CreateArmyStatTrigger(
		PlayerUnitDeathDialog02,
		ArmyBrains[ARMY_PLAYER],
		'PLAYER_UNIT_CHECK_020',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'LessThan',
				Value = ScenarioInfo.PLAYER_TANK_COUNT - 6,
				Category = categories.uul0101 + categories.uul0104,
			},
		}
	)
end

function PlayerUnitDeathDialog02()
	if not ScenarioInfo.Killed02_Played then
		ScenarioInfo.Killed02_Played = true
		LOG('----- PlayerUnitDeathDialog02: Dialogue: U01_PLYR_UNIT_KILLED_020')
		ScenarioFramework.Dialogue(OpDialog.U01_PLYR_UNIT_KILLED_020)
	end

	-- after a delay, create another stat trigger to continue to provide feedback if needed
	ScenarioFramework.CreateTimerTrigger(PlayerUnitDeathTrigger03, DELAY_UNIT_KILLED_CHECK)
end

function PlayerUnitDeathTrigger03()
	-- handle player combat unit count drops below PLAYER_UnitActiveMin
	ScenarioFramework.CreateArmyStatTrigger(
		PlayerUnitDeathDialog03,
		ArmyBrains[ARMY_PLAYER],
		'PLAYER_UNIT_CHECK_030',
		{
			{
				StatType = 'Units_Active',
				CompareType = 'LessThan',
				Value = ScenarioInfo.PLAYER_TANK_COUNT - 8,
				Category = categories.uul0101 + categories.uul0104,
			},
		}
	)
end

function PlayerUnitDeathDialog03()
	if not ScenarioInfo.Killed03_Played then
		ScenarioInfo.Killed03_Played = true
		LOG('----- PlayerUnitDeathDialog03: Dialogue: U01_PLYR_UNIT_KILLED_030')
		ScenarioFramework.Dialogue(OpDialog.U01_PLYR_UNIT_KILLED_030)
	end
end

function ExperimentalProgressVO()
	LOG('----- ExperimentalProgressVO: Dialogue: U01_ENEM01_EXP_DAMAGED_010')
	ScenarioFramework.Dialogue(OpDialog.U01_ENEM01_EXP_DAMAGED_010)
end

---------------------------------------------------------------------
-- COMMON FUNCTIONS:
---------------------------------------------------------------------
function AttackCenter(group,pos)
	IssueClearCommands(group)
	IssueAggressiveMove( group, pos )
	IssueAggressiveMove( group, ScenarioUtils.MarkerToPosition( 'NIS_DEST_CDR_01' ) )
	IssueAttack( group, ScenarioInfo.PLAYER_CDR )
end

function AttackPosAndTarget(group,pos,target)
	IssueMove( group, pos )
	IssueAttack( group, target )
	IssueAggressiveMove( group, pos )
	IssueAggressiveMove( group, ScenarioUtils.MarkerToPosition( 'NIS_DEST_CDR_01' ) )
	IssueAttack( group, ScenarioInfo.PLAYER_CDR )
end

function P1_CourtyardAssault(bSkip)
	DeployEnemyTransport_01(2, bSkip)
	DeployEnemyTransport_02(3, bSkip)
	DeployEnemyTransport_03(4, bSkip)
	DeployEnemyTransport_04(5, bSkip)
	DeployEnemyTransport_05(7, bSkip)
	DeployEnemyTransport_06(4, bSkip)

	-- protect all of the assault units here - since they are created during the NIS
	ProtectGroup(ScenarioInfo.COURTYARD_ASSAULT_UNITS)

	-- setup all the transports
	AdjustTransport( ScenarioInfo.ENEM01_TRANSPORT_01 )
	AdjustTransport( ScenarioInfo.ENEM01_TRANSPORT_02 )
	AdjustTransport( ScenarioInfo.ENEM01_TRANSPORT_03 )
	AdjustTransport( ScenarioInfo.ENEM01_TRANSPORT_04 )
	AdjustTransport( ScenarioInfo.ENEM01_TRANSPORT_05 )
	AdjustTransport( ScenarioInfo.ENEM01_TRANSPORT_06 )

	-- unprotect these units if the player gets close enough to them, after the assault is launched
	ScenarioFramework.CreateUnitNearTypeTrigger( AttackWithGroup02, ScenarioInfo.CYARD_UNIT_ZONE_2, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 50.0 )
	ScenarioFramework.CreateUnitNearTypeTrigger( AttackWithGroup03, ScenarioInfo.CYARD_UNIT_ZONE_3, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 35.0 )
	ScenarioFramework.CreateUnitNearTypeTrigger( AttackWithGroup04, ScenarioInfo.CYARD_UNIT_ZONE_4, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 50.0 )
	ScenarioFramework.CreateUnitNearTypeTrigger( AttackWithGroup05, ScenarioInfo.CYARD_UNIT_ZONE_5, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 60.0 )

	-- alternately unprotect these units at intervals
	ScenarioFramework.CreateTimerTrigger( AttackWithGroup02, DELAY_BEFORE_BOT_ATTACKS + (DELAY_BETWEEN_BOT_ATTACKS * 1) )
	ScenarioFramework.CreateTimerTrigger( AttackWithGroup03, DELAY_BEFORE_BOT_ATTACKS + (DELAY_BETWEEN_BOT_ATTACKS * 2) )
	ScenarioFramework.CreateTimerTrigger( AttackWithGroup04, DELAY_BEFORE_BOT_ATTACKS + (DELAY_BETWEEN_BOT_ATTACKS * 3) )
	ScenarioFramework.CreateTimerTrigger( AttackWithGroup05, DELAY_BEFORE_BOT_ATTACKS + (DELAY_BETWEEN_BOT_ATTACKS * 4) )
end

function AdjustTransport(unit)
	-- early out for invalid or dead units
	if not unit or unit:IsDead() then
		return
	end

	-- protect the transport - since it is created during the NIS
	unit:SetCanBeKilled(false)

	-- adjust health
	SetStartingUnitHealth(unit, RandomFloat(200,1000))

	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/29/09
	---			this specific case is only safe because these are throw-away units - bfricks 11/29/09
	local currSpeed = unit:GetBlueprint().Air.MaxAirspeed
	local destSpeed = 15.0
	local multSpeed = destSpeed/currSpeed

	-- modify the speeds
	unit:SetSpeedMult(multSpeed)
	unit:SetNavMaxSpeedMultiplier(multSpeed)
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end

function AttackWithGroup02()
	if ScenarioInfo.Group02Attacked then
		return
	end
	ScenarioInfo.Group02Attacked = true

	if ScenarioInfo.CYARD_UNIT_ZONE_2 and not ScenarioInfo.CYARD_UNIT_ZONE_2:IsDead() then
		SetStartingUnitHealth(ScenarioInfo.CYARD_UNIT_ZONE_2, 1)
		UnProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_2)
	end
	AttackCenter(ScenarioInfo.ENEM01_DEPLOYGROUP_02, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_2' ))
end

function AttackWithGroup03()
	if ScenarioInfo.Group03Attacked then
		return
	end
	ScenarioInfo.Group03Attacked = true

	if ScenarioInfo.CYARD_UNIT_ZONE_3 and not ScenarioInfo.CYARD_UNIT_ZONE_3:IsDead() then
		SetStartingUnitHealth(ScenarioInfo.CYARD_UNIT_ZONE_3, 1)
		UnProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_3)
	end
	AttackCenter(ScenarioInfo.ENEM01_DEPLOYGROUP_03, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_3' ))
end

function AttackWithGroup04()
	if ScenarioInfo.Group04Attacked then
		return
	end
	ScenarioInfo.Group04Attacked = true

	if ScenarioInfo.CYARD_UNIT_ZONE_4 and not ScenarioInfo.CYARD_UNIT_ZONE_4:IsDead() then
		SetStartingUnitHealth(ScenarioInfo.CYARD_UNIT_ZONE_4, 1)
		UnProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_4)
	end
	AttackCenter(ScenarioInfo.ENEM01_DEPLOYGROUP_04, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_4' ))
end

function AttackWithGroup05()
	if ScenarioInfo.Group05Attacked then
		return
	end
	ScenarioInfo.Group05Attacked = true

	if ScenarioInfo.CYARD_UNIT_ZONE_5 and not ScenarioInfo.CYARD_UNIT_ZONE_5:IsDead() then
		SetStartingUnitHealth(ScenarioInfo.CYARD_UNIT_ZONE_5, 1)
		UnProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_5)
	end
	AttackCenter(ScenarioInfo.ENEM01_DEPLOYGROUP_05, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_5' ))
end

function DeployEnemyTransport_01(unitCount, bSkip)
	ScenarioInfo.ENEM01_TRANSPORT_01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_TRANSPORT_01')
	ScenarioInfo.ENEM01_DEPLOYGROUP_01 = {}
	for k = 1, unitCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_BOT')
		table.insert( ScenarioInfo.COURTYARD_ASSAULT_UNITS, unit )
		table.insert(ScenarioInfo.ENEM01_DEPLOYGROUP_01, unit)
	end

	local data = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= ScenarioInfo.ENEM01_DEPLOYGROUP_01,	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.ENEM01_TRANSPORT_01,		-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'ENEM01_LANDING_ZONE_1',				-- destination for the transport drop-off
		returnDest				= 'ENEM01_TRANSPORT_EXIT_ZONE',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= LandingGroup_01,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data, bSkip)
end

function DeployEnemyTransport_02(unitCount, bSkip)
	ScenarioInfo.ENEM01_TRANSPORT_02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_TRANSPORT_02')
	ScenarioInfo.ENEM01_DEPLOYGROUP_02 = {}
	for k = 1, unitCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_BOT')
		table.insert( ScenarioInfo.COURTYARD_ASSAULT_UNITS, unit )
		table.insert(ScenarioInfo.ENEM01_DEPLOYGROUP_02, unit)
	end

	local data = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= ScenarioInfo.ENEM01_DEPLOYGROUP_02,	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.ENEM01_TRANSPORT_02,		-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'ENEM01_LANDING_ZONE_2',				-- destination for the transport drop-off
		returnDest				= 'ENEM01_TRANSPORT_EXIT_ZONE',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= LandingGroup_02,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data, bSkip)
end

function DeployEnemyTransport_03(unitCount, bSkip)
	ScenarioInfo.ENEM01_TRANSPORT_03 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_TRANSPORT_03')
	ScenarioInfo.ENEM01_DEPLOYGROUP_03 = {}
	for k = 1, unitCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_BOT')
		table.insert( ScenarioInfo.COURTYARD_ASSAULT_UNITS, unit )
		table.insert(ScenarioInfo.ENEM01_DEPLOYGROUP_03, unit)
	end

	local data = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= ScenarioInfo.ENEM01_DEPLOYGROUP_03,	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.ENEM01_TRANSPORT_03,		-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'ENEM01_LANDING_ZONE_3',				-- destination for the transport drop-off
		returnDest				= 'ENEM01_TRANSPORT_EXIT_ZONE',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= LandingGroup_03,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data, bSkip)
end

function DeployEnemyTransport_04(unitCount, bSkip)
	ScenarioInfo.ENEM01_TRANSPORT_04 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_TRANSPORT_04')
	ScenarioInfo.ENEM01_DEPLOYGROUP_04 = {}
	for k = 1, unitCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_BOT')
		table.insert( ScenarioInfo.COURTYARD_ASSAULT_UNITS, unit )
		table.insert(ScenarioInfo.ENEM01_DEPLOYGROUP_04, unit)
	end

	local data = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= ScenarioInfo.ENEM01_DEPLOYGROUP_04,	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.ENEM01_TRANSPORT_04,		-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'ENEM01_LANDING_ZONE_4',				-- destination for the transport drop-off
		returnDest				= 'ENEM01_TRANSPORT_EXIT_ZONE',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= LandingGroup_04,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data, bSkip)
end

function DeployEnemyTransport_05(unitCount, bSkip)
	ScenarioInfo.ENEM01_TRANSPORT_05 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_TRANSPORT_05')
	ScenarioInfo.ENEM01_DEPLOYGROUP_05 = {}
	for k = 1, unitCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_BOT')
		table.insert( ScenarioInfo.COURTYARD_ASSAULT_UNITS, unit )
		table.insert(ScenarioInfo.ENEM01_DEPLOYGROUP_05, unit)
	end

	local data = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= ScenarioInfo.ENEM01_DEPLOYGROUP_05,	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.ENEM01_TRANSPORT_05,		-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'ENEM01_LANDING_ZONE_5',				-- destination for the transport drop-off
		returnDest				= 'ENEM01_TRANSPORT_EXIT_ZONE',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= LandingGroup_05,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data, bSkip)
end

function DeployEnemyTransport_06(unitCount, bSkip)
	ScenarioInfo.ENEM01_TRANSPORT_06 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_TRANSPORT_06')
	ScenarioInfo.ENEM01_DEPLOYGROUP_06 = {}
	for k = 1, unitCount do
		local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'ENEM01_BOT')
		table.insert( ScenarioInfo.COURTYARD_ASSAULT_UNITS, unit )
		table.insert(ScenarioInfo.ENEM01_DEPLOYGROUP_06, unit)
	end

	local data = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= ScenarioInfo.ENEM01_DEPLOYGROUP_06,	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.ENEM01_TRANSPORT_06,		-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'ENEM01_LANDING_ZONE_6',				-- destination for the transport drop-off
		returnDest				= 'ENEM01_TRANSPORT_EXIT_ZONE',			-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= LandingGroup_06,						-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data, bSkip)
end

function LandingGroup_01()
	ScenarioInfo.ENEM01_TRANSPORT_01:SetCanBeKilled(true)
	UnProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_1)

	AttackPosAndTarget(ScenarioInfo.ENEM01_DEPLOYGROUP_01, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_1' ), ScenarioInfo.CYARD_UNIT_ZONE_1)
end

function LandingGroup_02()
	ScenarioInfo.ENEM01_TRANSPORT_02:SetCanBeKilled(true)
	AttackPosAndTarget(ScenarioInfo.ENEM01_DEPLOYGROUP_02, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_2' ), ScenarioInfo.CYARD_UNIT_ZONE_2)
end

function LandingGroup_03()
	ScenarioInfo.ENEM01_TRANSPORT_03:SetCanBeKilled(true)
	AttackPosAndTarget(ScenarioInfo.ENEM01_DEPLOYGROUP_03, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_3' ), ScenarioInfo.CYARD_UNIT_ZONE_3)
end

function LandingGroup_04()
	ScenarioInfo.ENEM01_TRANSPORT_04:SetCanBeKilled(true)
	AttackPosAndTarget(ScenarioInfo.ENEM01_DEPLOYGROUP_04, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_4' ), ScenarioInfo.CYARD_UNIT_ZONE_4)
end

function LandingGroup_05()
	ScenarioInfo.ENEM01_TRANSPORT_05:SetCanBeKilled(true)
	AttackPosAndTarget(ScenarioInfo.ENEM01_DEPLOYGROUP_05, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_5' ), ScenarioInfo.CYARD_UNIT_ZONE_5)
end

function LandingGroup_06()
	ScenarioInfo.ENEM01_TRANSPORT_06:SetCanBeKilled(true)
	UnProtectUnit(ScenarioInfo.CYARD_UNIT_ZONE_6)

	AttackPosAndTarget(ScenarioInfo.ENEM01_DEPLOYGROUP_06, ScenarioUtils.MarkerToPosition( 'COURTYARD_ITEM_POS_6' ), ScenarioInfo.CYARD_UNIT_ZONE_6)
end

function PLAYER_Reinforcements()
	LOG('----- PLAYER_Reinforcements: launching player reinforcements')

	-- launch a group of reinforcments immediately
	for i = 1, PLAYER_Zone1TransCount do
		WaitSeconds(1.0)
		-- spawn a bunch of transports that fly in, deploy groups of units, then fly off
		local data = {
			armyName				= 'ARMY_ALLY01',									-- name of the army for whom the transport and group are being created
			units					= 'ALLY01_DEPLOYUNITS_' .. PLAYER_Zone1UnitCount,	-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= 'ALLY01_TRANSPORT',								-- unit handle for the actual transport
			approachChain			= nil,												-- optional chainName for the approach travel route
			unloadDest				= 'ALLY01_LANDING_ZONE_1_' .. i,					-- destination for the transport drop-off
			returnDest				= 'ALLY01_TRANSPORT_EXIT_ZONE',						-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,											-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,												-- optional destination for the group to be moved to after being dropped-off
			OnCreateCallback		= nil,												-- optional function to call when the transport finishes unloading
			onUnloadCallback		= PLAYER_Reinforcements_Arrived,					-- optional function to call when the transport finishes unloading
		}
		TransportUtils.SpawnTransportDeployGroup(data)
	end
end

function PLAYER_Reinforcements_Arrived(platoon)
	--NOTE: due to the giving of units, at this point in the operation we force the unit cap higher to make room for the new units - bfricks 1/15/10
	SetArmyUnitCap(ARMY_PLAYER, 250)
	ScenarioFramework.GiveGroupToArmy( platoon:GetPlatoonUnits(), ARMY_PLAYER )

	if not ScenarioInfo.ReinforcementsArrived then
		ScenarioInfo.ReinforcementsArrived = true
		-- play dialog
		LOG('----- PLAYER_Reinforcements_Arrived: Dialogue: U01_ALLY_REINFORCEMENTS_020')
		ScenarioFramework.Dialogue(OpDialog.U01_ALLY_REINFORCEMENTS_020)
	end
end

---------------------------------------------------------------------
-- TUNING FUNCTIONS:
---------------------------------------------------------------------
function SetStartingUnitHealth(unit, healthValue)
	if unit and not unit:IsDead() then
		unit:SetMaxHealth( healthValue )
		unit:AdjustHealth( unit, healthValue )
	end
end

function  SetStartingGroupHealth(group, healthValue)
	for i, unit in group do
		SetStartingUnitHealth(unit, healthValue)
	end
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function LaunchVictoryNIS(unit)
	if not ScenarioInfo.VictoryTracker then
		-- first time, we just set the value
		ScenarioInfo.VictoryTracker = 1
	else
		-- every other time we up the value
		ScenarioInfo.VictoryTracker = ScenarioInfo.VictoryTracker + 1
	end

	if ScenarioInfo.VictoryTracker == 2 then
		-- on the second kill, launch the Victory
		ForkThread(OpNIS.NIS_VICTORY, unit)
	else
		---NOTE: before, we were just unflagging the unit as killable - that is broken because there is no certainty that the
		---			player will continue to kill this unit - so we have to force kill it. Down the road - when we have a better health ratio system
		---			this should be considerably more readible - bfricks 11/8/09
		-- otherwise we force kill the unit
		ForceUnitDeath(unit)
	end
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3() -- Skip to MidOp
	P2_Setup()
end

function OnShiftF4() -- Skip to Victory
	LaunchVictoryNIS(ScenarioInfo.ENEM01_EXPERIMENTAL_01)
end











