---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_C02/SC2_CA_C02_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_C02/SC2_CA_C02_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_C02/SC2_CA_C02_OpNIS.lua')
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
ScenarioInfo.ARMY_OBJECTIVE = 3

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.AllowCaptureVO = true

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_OBJECTIVE = ScenarioInfo.ARMY_OBJECTIVE

local CaptureVOCount = 0

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------

--	The enemy in this map has three bases:
--		* Middle base:		Focuses solely on creating engineers who build turret chains towards player.
--							P1_ENEM01_Mid_BaseAI()
--
--		* East base:		Sends engineer capture attacks to player via land and water, and maintains
--							water area capture-engineer patrols to the east. Note: this base will try
--							to build a small turret chain towards Algorithm Generator when the player
--							enters that area.
--							P1_ENEM01_East_BaseAI()
--
--		* North base:		Sends engineer capture attacks to player via land. Note: this base will try
--							to build a small turret chain towards Algorithm Generator when the player
--							enters that area.
--							P1_ENEM01_North_BaseAI()
--
--	Flow:
--		* Attacks grow in size and number over time:
local StartNorthLightAttacks_Delay			= 60		-- North light attacks, 2 engineers
local StartEastLightAttacks_Delay			= 120		-- East base begins light attacks, 4 engineers
local IncreaseLightAttackCounts_Delay		= 300		-- East and North base increase max active platoon counts on light attacks
local StartEastHeavyAttack_Delay			= 350		-- East heavy attack OpAI turned on, 8 engineers
local StartNorthHeavyAttack_Delay			= 450		-- North heavy attack OpAI turned on, 8 engineers

--		* Player enters central choke-point area, or builds a mobile naval unit. NAVAL engineer-capture attacks begin.
--  	  P1_PlayerDetectedAtChokepoint(), P1_EnableNavalEngineerAttacks()
--
--		* Player sends naval east. Enemy moves east naval-area engineer patrols ahead.
--
--		* Player enters main Algorithm Generator area. Enemy response: 1) North and East bases
--		  begin building a line of turrets that stretch towards the Generator area, 2) Capture attacks
--		  are strengthened (ie, the appearance of a strong pushback against player).
--		  NOTE: at this point, we now pay attention to how the player is doing. When, after this point,
--		  they begin to do poorly, difficulty will decrease permantently, so Op does become a slog. The
--		  idea is that if the player mounted a reasonable attack at the middle, failed, and is now beat down,
--		  we dont want things to be a slog thereafter.
--		  P1_PlayerInMiddleCheck_Thread()

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.C02_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.C02_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_OBJECTIVE,	ScenarioGameTuning.color_ROGUE_C02)
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

	LOG('----- P1_Setup: Setup for the player CDR.')
	ScenarioInfo.PLAYER_CDR = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'PLAYER_CDR')
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Ivan)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	local radar = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_Starting_Radar')
	radar:SetIntelRadius('Radar', 360)
	ProtectUnit(radar)

	-- intel for enemy (must cover naval routes as well)
	ScenarioFramework.CreateIntelAtLocation(375, 'P1_ENEM01_IntelLocation_Marker', ARMY_ENEM01, 'Radar')

	--# Create starting player units
	ScenarioInfo.Engineers = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Engineers')
	ScenarioInfo.Warp_Units = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'Warp_Units')
	ScenarioInfo.EnterTeleporter = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'EnterTeleporter')
	ScenarioInfo.ExitTeleporter = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'ExitTeleporter')

	ProtectUnit(ScenarioInfo.ExitTeleporter)
	ScenarioInfo.ExitTeleporter:SetCustomName(ScenarioGameNames.UNIT_SCB3101)
	ProtectUnit(ScenarioInfo.EnterTeleporter)
	ScenarioInfo.EnterTeleporter:SetCustomName(ScenarioGameNames.UNIT_SCB3101)

	-- wire up the player ACU to do the ViralCaptureCheck
	ViralCaptureCheck(ScenarioInfo.PLAYER_CDR)

	-- wire up our player builders so they spread the ViralCaptureCheck
	for k, unit in ScenarioInfo.Engineers do
		ViralCaptureCheck(unit)
	end

	--# Create starting enemy units

	--Note: starting naval-area engineers are created in AIsetup, with their OpAIs (in P1_ENEM01_East_BaseAI())

	-- Objectve unit, set only to capturable.
	ScenarioInfo.P1_OBJECTIVE_AlgGenerator	= ScenarioUtils.CreateArmyUnit('ARMY_OBJECTIVE', 'P1_OBJECTIVE_AlgGenerator')
	ProtectUnit(ScenarioInfo.P1_OBJECTIVE_AlgGenerator)
	ScenarioInfo.P1_OBJECTIVE_AlgGenerator:SetCapturable(true)
	ScenarioInfo.P1_OBJECTIVE_AlgGenerator:SetReclaimable(true)
	ScenarioInfo.P1_OBJECTIVE_AlgGenerator:SetCustomName(ScenarioGameNames.UNIT_SCB3201)

	-- Create p1 area tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')
end

function P1_Main()

	--# Start Base Managers
	--### Moved here from P1_Setup to keep enemy base out of NIS. -balfieri 10/16/2009
	P1_ENEM01_Mid_BaseAI()
	P1_ENEM01_North_BaseAI()
	P1_ENEM01_East_BaseAI()

	----------------------------------------------
	-- Primary Objective M1_obj10 - Capture Structure
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Capture Structure.')
	ScenarioInfo.M1_obj10 = SimObjectives.Capture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.C02_M1_obj10_NAME,		-- title
		OpStrings.C02_M1_obj10_DESC,		-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			ArrowOffset = -1.0,
			ArrowSize = 0.6,
			Units = {ScenarioInfo.P1_OBJECTIVE_AlgGenerator},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				ForkThread(
					function()
						ScenarioInfo.AssignedObjectives.VictoryCallbackList = {}
						if not ScenarioInfo.HiddenObj_EnemyCapturedUnit then
							table.insert(ScenarioInfo.AssignedObjectives.VictoryCallbackList, P1_HiddenObj2Complete)
						end

						-- not hugely necessary, but turn off all base managers before the NIS.
						-- NOTE: if the enabing of any of the expansions get put on a timer, then we will
						-- need to update these to have a check for if the expansion has been activated or not.
						ScenarioInfo.ArmyBase_ENEM01_Mid_Base:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_01:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_02:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_03:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_04:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_North_Base:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_North_Expansion_01:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_East_Base:BaseActive(false)
						ScenarioInfo.ArmyBase_ENEM01_East_Expansion_01:BaseActive(false)

						OpNIS.NIS_VICTORY()
					end
				)
			end
		end
	)


	-- When the player is near the chokepoint area, point out that the enemy has build anti-land
	-- turrets there, and turn on a naval-route attack by the enemy.
	ScenarioFramework.CreateAreaTrigger(P1_PlayerDetectedAtChokepoint, 'P1_Chokepoint_Area', categories.ALLUNITS, true, false, ArmyBrains[ARMY_PLAYER], 1)

	-- Enable the Naval rogue engineer attack OpAI when player builds a naval unit
	ScenarioFramework.CreateArmyStatTrigger (P1_EnableNavalEngineerAttacks, ArmyBrains[ARMY_PLAYER], 'P1_PlayerBuiltNaval',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.NAVAL * categories.MOBILE}})

	-- Detect the player advancing with naval to the east. This will result in the engineer patrols in that area
	-- pushing ahead to a new patrol, towards the incoming ships.
	ScenarioFramework.CreateAreaTrigger(P1_PlayerNavalDetectedEast, 'P1_Naval_Trigger_Area', categories.NAVAL, true, false, ArmyBrains[ARMY_PLAYER], 1)

	-- When we detect the player in the objective area, start a loop that will check and verify that they are substantively there.
	-- If so, the enemy will respond. Otherwise, the loop will continue watching for the event.
	-- Note: using an area trigger to start the thread, simply so we dont have it running the whole op in the backround. Setting it to detect
	-- 2 units, as that is the current minimum unit check by the loop (ie, two experimentals can satify the loop check).
	ScenarioFramework.CreateAreaTrigger(P1_PlayerInMiddleCheck_Thread, 'P1_Capture_Objective_AREA', categories.LAND, true, false, ArmyBrains[ARMY_PLAYER], 2, false)

	-- Detect when the enemy engineers build turrets in either of two areas. They will do se
	-- as a response to the player moving into the main middle objective area. When this happens
	-- play warning VO that points this response out.
	ScenarioFramework.CreateMultipleAreaTrigger(P1_PlayMiddleResponseVO, {'P1_North_TowerCheck_Area', 'P1_East_TowerCheck_Area'},
				categories.uib0101 + categories.uib0102, true, false, ArmyBrains[ARMY_ENEM01], 1)


	ScenarioFramework.CreateTimerTrigger (P1_TurretCreepVOWarning, 90)

	-- Start the enemy building the strings of towers in the middle area.
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_01:StartEmptyBase(2)
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_02:StartEmptyBase(2)
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_03:StartEmptyBase(2)

	-- trigger to assign research secondary objective
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 35)
	ScenarioFramework.CreateTimerTrigger (P1_BrackmanDialogue_VO, 500)

	-- Vo when player builds a battleship
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C02_BATTLESHIP_BUILT_010) end,
			ArmyBrains[ARMY_PLAYER], 'P1_PlayerBuiltBattleship',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ucs0105}})

	-- Vo when player loeses a battleship
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C02_BATTLESHIP_DESTROYED_010) end,
			ArmyBrains[ARMY_PLAYER], 'P1_PlayerLostBattleship',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ucs0105}})


	--------------------
	-- Difficulty Timers:
	--------------------

	ScenarioFramework.CreateTimerTrigger (P1_StartNorthLightAttacks, StartNorthLightAttacks_Delay)
	ScenarioFramework.CreateTimerTrigger (P1_StartEastLightAttacks, StartEastLightAttacks_Delay)

	-- slowly build add to the attacks with increasingly stronger and more frequent ones.
	ScenarioFramework.CreateTimerTrigger (P1_IncreaseLightAttackCounts, IncreaseLightAttackCounts_Delay)
	ScenarioFramework.CreateTimerTrigger (P1_StartEastHeavyCapture, StartEastHeavyAttack_Delay)
	ScenarioFramework.CreateTimerTrigger (P1_StartNorthHeavyCapture, StartNorthHeavyAttack_Delay)

end

function P1_StartNorthLightAttacks()
	LOG('----- P1: Enabling North light attacks')

	-- turn on the east base light capture attack, which uses 3 engineers.
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:Enable()
end

function P1_StartEastLightAttacks()
	LOG('----- P1: Enabling East light attacks')

	-- turn on the east base light capture attack, which uses 3 engineers.
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:Enable()
end

function P1_IncreaseLightAttackCounts()
	LOG('----- P1: Adding more light attacks')

	-- Set light attack OpAI's to maintain 3, instead of 1, attacks per.
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetMaxActivePlatoons(3)
end

function P1_StartEastHeavyCapture()
	LOG('----- P1: First heavy capture attack OpAI enabled')

	-- Turn on a heavy capture attack, and play VO pointing this
	-- out after a brief pause (enough so the larger groups can get
	-- within radar range, broadly speaking).
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:Enable()
	ScenarioFramework.CreateTimerTrigger(P1_EnemyBuildWarning, 90)
end

function P1_StartNorthHeavyCapture()
	LOG('----- P1: Second heavy capture attack OpAI enabled')

	-- Turn on a second heavy capture attack
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:Enable()
end

function P1_PlayerDetectedAtChokepoint()
	LOG('----- P1: Player is in the chokepoint area. Play VO, turn on naval route attack.')

	-- play VO pointing out that enemy has build land turrets in chokepoint area, and recommend a course of action.
	-- But, dont play it if the player has 2 or more exps in the general area: in that case, the VO will sound out of place,
	-- as player is most likely already tooling the defensive line, and it is not a noticable threat.

	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: this function is only safe without alliance data because the enemy has no experimentals - bfricks 1/7/10
	local count = table.getn( ArmyBrains[ARMY_ENEM01]:GetUnitsAroundPoint( categories.EXPERIMENTAL * categories.MOBILE * categories.ANTISURFACE,
    				ScenarioUtils.MarkerToPosition('P1_Chokepoint_Recheck_Marker'), 60 ) )
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	if count < 2 then
		LOG('----- P1: Player has less than 2 exps around the chokepoint, so we will play the warning VO.')
		ScenarioFramework.Dialogue(OpDialog.C02_LAND_TURRET_WARNING_010)
	else
		LOG('----- P1: Player has >= 2 experimentals, so we will skip the middle VO warning.')
	end

	-- Turn on a moderate naval-route attack against the player (enabled by player being at chokepoint,
	-- or building a naval unit).
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI:Enable()
end

function P1_EnableNavalEngineerAttacks()
	LOG('----- P1:Player built naval unit - enabling Naval engineer OpAI.')
	-- Turn on a moderate naval-route attack against the player (enabled by player being at chokepoint,
	-- or building a naval unit).
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI:Enable()
end

function P1_PlayerNavalDetectedEast()
	LOG('----- P1: Player naval units detected to the east.')

	-- Send all platoons to a new patrol that is ahead, towards the incoming player. This gives the sense
	-- of a response/attack, against the incoming player from the patrolling engineers
	for k, platoon in ScenarioInfo.P1_EnemyNavalPlatoons do
		if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_East_NavalCapture_Chain_01')
		end
	end

	-- update the opais that these platoons are associated with to use this new patrol chain.
	local captureData = {
		CaptureChain = 'P1_ENEM01_East_NavalCapture_Chain_01',
		CaptureRadius = 30,
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI:		SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI:		SetPlatoonThread( 'CaptureRoute', captureData )

end

function P1_PlayerInMiddleCheck_Thread()
	LOG('----- P1: Player units detected in obective area. Turning on a looping check.')
	--When the player moves a moderate force into the middle, check again a bit later to see if they are still there.

	while not ScenarioInfo.OpEnded do
		local units = ScenarioFramework.GetCatUnitsInArea(categories.LAND, ScenarioUtils.AreaToRect('P1_Capture_Objective_AREA'), ArmyBrains[ARMY_PLAYER])
		local exp = ScenarioFramework.GetCatUnitsInArea(categories.EXPERIMENTAL * categories.MOBILE * categories.ANTISURFACE, ScenarioUtils.AreaToRect('P1_Capture_Objective_AREA'), ArmyBrains[ARMY_PLAYER])

		-- of we have some units, or a couple exps, in the area, do our thang.
		if table.getn(units) >= 9 or table.getn(exp) >= 2 then
			LOG('----- P1: Player has triggered objective area check! Will check again soon ...')
			-- delay a bit before we recheck the player's presence, so we can verify they really are in control of the area.
			WaitSeconds(15)

			-- add an early out case since time has elapsed, and the op could have ended
			if ScenarioInfo.OpEnded then
				LOG('----- P1: Recheck thread: op has ended so killing the recheck thread.')
				return
			end
			units = ScenarioFramework.GetCatUnitsInArea(categories.LAND, ScenarioUtils.AreaToRect('P1_Capture_Objective_AREA'), ArmyBrains[ARMY_PLAYER])
			exp = ScenarioFramework.GetCatUnitsInArea(categories.EXPERIMENTAL * categories.MOBILE * categories.ANTISURFACE, ScenarioUtils.AreaToRect('P1_Capture_Objective_AREA'), ArmyBrains[ARMY_PLAYER])
			-- if the player continues to be present, that means they are in control, so we
			-- now turn on some expansion turret building, crank the attack knobs, and play some vo.
			if table.getn(units) >= 9 or table.getn(exp) >= 2 then
				LOG('----- P1: Player is in control of the objective area. Doing stuff and killing check thread!')
				ScenarioInfo.ArmyBase_ENEM01_North_Expansion_01:StartEmptyBase(1)
				ScenarioInfo.ArmyBase_ENEM01_East_Expansion_01:StartEmptyBase(1)

				P1_StrengthenCaptureAttacks()
				ScenarioFramework.Dialogue(OpDialog.C02_CAPTURE_INSTRUCTION_010)

				-- thread ends.
				return
			else
				LOG('----- P1: Player lost control of objective area. Continuing normal check thread ...')
			end
		end
		WaitSeconds(8)
	end
end

function P1_StrengthenCaptureAttacks()
	LOG('----- P1: Capture attacks set to strong')

	-- Set the capture attacks to be more frequent, and in higher counts.
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetAttackDelay(2)
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetMaxActivePlatoons(2)

	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetAttackDelay(2)
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetMaxActivePlatoons(2)

	-- heavy attacks dont need their counts increased, just drop the build delay.
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:			SetAttackDelay(2)
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:				SetAttackDelay(2)

	-- Create a trigger to watch how the player is doing overall. If their unit count drops, we will tone
	-- the capture attacks back down to normal.
	ScenarioFramework.CreateArmyStatTrigger(P1_SoftenCaptureAttacks, ArmyBrains[ARMY_PLAYER], 'P1_PlayerUnitCount_Capture',
			{{StatType = 'Units_Active', CompareType = 'LessThanOrEqual', Value = 13, Category = categories.ALLUNITS}})
end

function P1_SoftenCaptureAttacks()
	LOG('----- P1: Capture attacks set back to normal')

	-- as the player doesn't have many units, we should tone the capture attacks down. We don't
	-- want to steamroll the player if they are doing poorly. We won't try to loop this and set things back to
	-- difficult, as if the player gets down to a low number of units, we don't want a long slog for them to try
	-- to build back up and repeat (ie, let's keep the Op snappy).
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetAttackDelay(12)
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetMaxActivePlatoons(1)

	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetAttackDelay(12)
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetMaxActivePlatoons(1)

	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:			SetAttackDelay(12)
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:				SetAttackDelay(12)
end

function P1_SetEngineerBuildRate(platoon)
	-- Set passed in engineers to have a very very high build rate, fast move, and higher health.

	for k, v in platoon:GetPlatoonUnits() do
		if v and not v:IsDead() then
			v:SetCaptureRate(5.81)
			v:SetSpeedMult(2.51)
			v:SetMaxCaptureDistance(18) -- range at which an engineer can capture.

			--TODO: this stomps over tuning changes to engineers, so keep an eye on it. -Greg 11/6/2009 4:57:15 PM
			--v:SetMaxHealth( 2500 )
			--v:AdjustHealth( v, 2500 )
		end
	end
end

function P1_CaptureCallback(newUnit)
	LOG('----- P1: Capture Callback: ...')
	-- Send captured units on aggressive move to player start area. Note that we have the
	-- capturing engineer passed along to this function, if we want to use it.
	if newUnit and not newUnit:IsDead() then
		-- if the unit is naval, send them to the player area, and then on patrol near player base area
		if EntityCategoryContains( categories.NAVAL, newUnit ) then
			LOG('----- P1: Capture Callback: ... captured unit is NAVAL')
			IssueAggressiveMove({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_Destination_01' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_1' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_2' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_3' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_4' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_5' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_4' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_3' ))
			IssuePatrol({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_ENEM01_NavalCapture_DestinationPatrol_2' ))

		-- if they are a land unit, send them to a point in the middle of player base area
		else
			LOG('----- P1: Capture Callback: ... captured unit is GROUND')
			IssueAggressiveMove({newUnit}, ScenarioUtils.MarkerToPosition( 'P1_CapturedUnitAttack_Marker' ))
		end
	end

	-- VO played when an enemy engineer captures a unit. As many as VO events
	-- as needed can be added to this.
	if ScenarioInfo.AllowCaptureVO then
		CaptureVOCount = CaptureVOCount + 1
		if CaptureVOCount == 1 then
			-- Player VO related to player unit being captured, flag to disallow more, and
			-- start a timer that will count down to re-allow more capture event VO to play.
			ScenarioFramework.Dialogue(OpDialog.C02_UNIT_CAPTURED_010)

			ScenarioInfo.AllowCaptureVO = false
			ScenarioFramework.CreateTimerTrigger (P1_CaptureVOToggle, 60)

		elseif CaptureVOCount == 2 then
			--Playe another capture event VO
			ScenarioFramework.Dialogue(OpDialog.C02_UNIT_CAPTURED_020)
		end
	end

	-- Set a flag that we have successfully captured a unit. A hidden objective will check this flag.
	ScenarioInfo.HiddenObj_EnemyCapturedUnit = true
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.C02_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.C02_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.C02_S1_obj10_NAME,	-- title
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
			if not ScenarioInfo.JumpJetResearched and ArmyBrains[ARMY_PLAYER]:HasResearched('CLA_JUMPJETS') then
				ScenarioInfo.JumpJetResearched = true
				ScenarioFramework.Dialogue(OpDialog.C02_HINT_JUMPJET)
			else
				ScenarioFramework.Dialogue(OpDialog.C02_RESEARCH_FOLLOWUP_BATTLESHIP_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 540)
end

function ResearchReminder1()
	if ScenarioInfo.S1_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.C02_RESEARCH_REMINDER_010)
	end
end

function P1_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Master Thief
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H1_obj10 - Master Thief')
	local descText = OpStrings.C02_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C02_H1_obj10_TAKE_ROGUE)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.C02_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('capture'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C02_H1_obj10_TAKE_ROGUE, ARMY_PLAYER, 3.0)
end

function P1_HiddenObj2Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Great Escapist
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H2_obj10 - Great Escapist')
	ScenarioInfo.H2_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.C02_H2_obj10_NAME,			-- title
		OpStrings.C02_H2_obj10_DESC,			-- description
		SimObjectives.GetActionIcon('protect'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H2_obj10)
end

function P1_BrackmanDialogue_VO()
	LOG('----- Brackman VO.')
	ScenarioFramework.Dialogue(OpDialog.C02_BANTER_GAUGE_STORY)
end

function P1_CaptureVOToggle()
	LOG('----- P1: Setting capture vo to playable')

	-- flag capture related VO to be playable again.
	ScenarioInfo.AllowCaptureVO = true
end

function P1_TurretCreepVOWarning()
	LOG('----- P1: Warn player that enemy is doing turret creep')

	-- Warn the player that enemy is doing turret creep
	ScenarioFramework.Dialogue(OpDialog.C02_TURRET_WARNING_010)
end

function P1_EnemyBuildWarning()
	LOG('----- P1: Warn player that enemy is ramping up attacks')

	-- Warn the player that the enemy has ramped up capture engineer production
	ScenarioFramework.Dialogue(OpDialog.C02_ENGINEER_PRODUCTION_WARNING_010)
end

function P1_PlayMiddleResponseVO()
	LOG('----- P1: Warn player that enemy is building turrets near objective structure.')

	-- play VO pointing out that the enemy is trying to build turrets out to the objective structure.
	ScenarioFramework.Dialogue(OpDialog.C02_MIDDLE_TURRET_WARNING_010)
end

---------------------------------------------------------------------
-- BASE MANAGERS AND OPAIS:
---------------------------------------------------------------------
function P1_ENEM01_Mid_BaseAI()
	LOG('----- P1: Setting up Middle base and AI')

	----------------------------------
	----- BASES AND EXPANSIONS
	----------------------------------


	--# Initial Middle Base
	local levelTable_ENEM01_Mid_Base = { P1_ENEM01_Mid_Base_100 = 100,
											P1_ENEM01_Mid_Base_90 = 90,
										}
	ScenarioInfo.ArmyBase_ENEM01_Mid_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Mid_Base',
		 'P1_ENEM01_Mid_Base_Marker', 50, levelTable_ENEM01_Mid_Base)
	ScenarioInfo.ArmyBase_ENEM01_Mid_Base:StartNonZeroBase(5)
	-- some initial engineers for the base
	local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_MidBase_Init_Eng_01')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_Mid_Base:AddEngineer(v)
	end


	--# Middle Base Expansion 01, land def in chokepoint
	ScenarioInfo.ArmyBase_ENEM01_Mid_Base:AddExpansionBase('ArmyBase_ENEM01_Mid_Expansion_01')
	local expansionTable_EnemMid_Expansion_01 = {
		P1_ENEM01_Mid_Expansion_01_100 = 100,
		P1_ENEM01_Mid_Expansion_01_90 = 90,
		P1_ENEM01_Mid_Expansion_01_80 = 80,
		P1_ENEM01_Mid_Expansion_01_70 = 70,
		P1_ENEM01_Mid_Expansion_01_60 = 60,
		P1_ENEM01_Mid_Expansion_01_50 = 50,
	}
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_01 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Mid_Expansion_01',
		 'ENEM01_Mid_Expansion_01_Marker', 50, expansionTable_EnemMid_Expansion_01)
		local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Mid_Expansion_01_InitEng_01')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_01:AddEngineer(v)
	end


	--# Middle Base Expansion 02, AA tower line one, into main area of map
	ScenarioInfo.ArmyBase_ENEM01_Mid_Base:AddExpansionBase('ArmyBase_ENEM01_Mid_Expansion_02')
	local expansionTable_EnemMid_Expansion_02 = {
		P1_ENEM01_Mid_Expansion_02_100 = 100,
		P1_ENEM01_Mid_Expansion_02_90 = 90,
		P1_ENEM01_Mid_Expansion_02_80 = 80,
		P1_ENEM01_Mid_Expansion_02_70 = 70,
		P1_ENEM01_Mid_Expansion_02_60 = 60,
	}
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_02 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Mid_Expansion_02',
		 'ENEM01_Mid_Expansion_02_Marker', 50, expansionTable_EnemMid_Expansion_02)
		local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Mid_Expansion_02_InitEng_01')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_02:AddEngineer(v)
	end


	--# Middle Base Expansion 03, AA tower line two, into alternate main area of map
	ScenarioInfo.ArmyBase_ENEM01_Mid_Base:AddExpansionBase('ArmyBase_ENEM01_Mid_Expansion_03')
	local expansionTable_EnemMid_Expansion_03 = {
		P1_ENEM01_Mid_Expansion_03_100 = 100,
		P1_ENEM01_Mid_Expansion_03_90 = 90,
		P1_ENEM01_Mid_Expansion_03_80 = 80,
		P1_ENEM01_Mid_Expansion_03_70 = 70,
		P1_ENEM01_Mid_Expansion_03_60 = 60,
		P1_ENEM01_Mid_Expansion_03_50 = 50,
		P1_ENEM01_Mid_Expansion_03_40 = 40,
	}
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_03 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Mid_Expansion_03',
		 'ENEM01_Mid_Expansion_03_Marker', 50, expansionTable_EnemMid_Expansion_03)
		local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Mid_Expansion_03_InitEng_01')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_03:AddEngineer(v)
	end


	--# Special middle base expansion 04, AA tower line three, near player area. Ready at start of op.
	ScenarioInfo.ArmyBase_ENEM01_Mid_Base:AddExpansionBase('ArmyBase_ENEM01_Mid_Expansion_04')
	local expansionTable_EnemMid_Expansion_04 = {
		P1_ENEM01_Mid_Expansion_04_100 = 100,
	}
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_04 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Mid_Expansion_04',
		 'ENEM01_Mid_Expansion_04_Marker', 50, expansionTable_EnemMid_Expansion_04)

	-- We want this base to start built, with some additions, so its very visible at start what's happening.
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_04:StartNonZeroBase(1)

	-- Stuff the engineers will start building.
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_04:AddBuildGroup('P1_ENEM01_Mid_Expansion_04_90', 60)
	ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_04:AddBuildGroup('P1_ENEM01_Mid_Expansion_04_80', 50)

	-- a starting engineer for the expansion
	local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Mid_Expansion_04_InitEng_01')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_Mid_Expansion_04:AddEngineer(v)
	end
end

function P1_ENEM01_North_BaseAI()
	LOG('----- P1: Setting up North base and AI')

	----------------------------------
	----- BASES AND EXPANSIONS
	----------------------------------

	--# Initial North Base
	local levelTable_ENEM01_North_Base = {
		P1_ENEM01_North_Base_100 = 100,
		P1_ENEM01_North_Base_90 = 90,
	}

	ScenarioInfo.ArmyBase_ENEM01_North_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_North_Base',
		 'P1_ENEM01_North_Base_Marker', 50, levelTable_ENEM01_North_Base)
	ScenarioInfo.ArmyBase_ENEM01_North_Base:StartNonZeroBase(4)
	-- some initial engineers for the base
	local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_NorthBase_Init_Eng_01')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_North_Base:AddEngineer(v)
	end


	--# Expansion near the objective area
	ScenarioInfo.ArmyBase_ENEM01_North_Base:AddExpansionBase('ArmyBase_ENEM01_North_Expansion_01')
	local expansionTable_EnemNorth_Expansion_01 = {
		P1_ENEM01_North_Expansion_01_100 = 100,
		P1_ENEM01_North_Expansion_01_90 = 90,
		P1_ENEM01_North_Expansion_01_80 = 80,
	}
	ScenarioInfo.ArmyBase_ENEM01_North_Expansion_01 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_North_Expansion_01',
		 'ENEM01_North_Expansion_01_Marker', 50, expansionTable_EnemNorth_Expansion_01)


	----------------------------------
	----- OPAIS
	----------------------------------

	-- Engineer Capture OpAI, Small
	local childTemplate1 = {
		'ENEM01_North_Engineer_01',
		{
			{ 'ucl0002', 2 },
		},
	}
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI = ScenarioInfo.ArmyBase_ENEM01_North_Base:GenerateOpAIFromPlatoonTemplate(childTemplate1, 'P1_ENEM01_North_Capture01_OpAI', {} )

	local captureData = {
		CaptureChain = 'P1_ENEM01_North_Capture_Chain_01',
		CaptureRadius = 20,
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI.			FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetAttackDelay(4.5)
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_North_Capture01_OpAI:			Disable()


	-- Engineer Capture OpAI, Large
	local childTemplate2 = {
		'ENEM01_North_Engineer_02',
		{
			{ 'ucl0002', 7 },
		},
	}
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI = ScenarioInfo.ArmyBase_ENEM01_North_Base:GenerateOpAIFromPlatoonTemplate(childTemplate2, 'P1_ENEM01_North_Capture02_OpAI', {} )

	local captureData = {
		CaptureChain = 'P1_ENEM01_North_Capture_Chain_02',
		CaptureRadius = 18, -- touch shorter than others, so final attack opai is a teensy bit softer, but still keeps the unit count up.
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:			SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI.			FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:			SetAttackDelay(9)
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:			SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ENEM01_North_Capture02_OpAI:			Disable()
end

function P1_ENEM01_East_BaseAI()
	LOG('----- P1: Setting up East base and AI')


	----------------------------------
	----- BASES AND EXPANSIONS
	----------------------------------

	--# Initial East Base
	local levelTable_ENEM01_East_Base = {
		P1_ENEM01_East_Base_100 = 100,
		P1_ENEM01_East_Base_90 = 90,
	}

	ScenarioInfo.ArmyBase_ENEM01_East_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_East_Base',
		 'P1_ENEM01_East_Base_Marker', 50, levelTable_ENEM01_East_Base)
	ScenarioInfo.ArmyBase_ENEM01_East_Base:StartNonZeroBase(4)
	-- some initial engineers for the base
	local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_EastBase_Init_Eng_01')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_East_Base:AddEngineer(v)
	end

	--# Expansion near the objective area
	ScenarioInfo.ArmyBase_ENEM01_East_Base:AddExpansionBase('ArmyBase_ENEM01_East_Expansion_01')
	local expansionTable_EnemEast_Expansion_01 = {
		P1_ENEM01_East_Expansion_01_100 = 100,
		P1_ENEM01_East_Expansion_01_90 = 90,
		P1_ENEM01_East_Expansion_01_80 = 80,
	}
	ScenarioInfo.ArmyBase_ENEM01_East_Expansion_01 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_East_Expansion_01',
		 'ENEM01_East_Expansion_01_Marker', 50, expansionTable_EnemEast_Expansion_01)


	----------------------------------
	----- OPAIS
	----------------------------------
	local childTemplate1 = {
		'ENEM01_East_Engineer_01',
		{
			{ 'ucl0002', 4 },
		},
	}


	-- Engineer Capture OpAI, Small
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI = ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(childTemplate1, 'P1_ENEM01_East_Capture01_OpAI', {} )
	local captureData = {
		CaptureChain = 'P1_ENEM01_North_Capture_Chain_02',
		CaptureRadius = 20,
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI.				FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetAttackDelay(4)
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetChildCount(1)
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_East_Capture01_OpAI:				Disable()


	-- Engineer Capture OpAI, Large
	local childTemplate2 = {
		'ENEM01_East_Engineer_01',
		{
			{ 'ucl0002', 7 },
		},
	}
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI = ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(childTemplate2, 'P1_ENEM01_East_Capture02_OpAI', {} )
	local captureData = {
		CaptureChain = 'P1_ENEM01_North_Capture_Chain_01',
		CaptureRadius = 20,
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:				SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI.				FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:				SetAttackDelay(12)
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:				SetChildCount(1)
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:				SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ENEM01_East_Capture02_OpAI:				Disable()


	-- Naval Engineer Capture OpAI, large
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI = ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(childTemplate2, 'P1_ENEM01_East_NavalCapture01_OpAI', {} )
	local captureData = {
		CaptureChain = 'P1_ENEM01_PatrolNaval_Near_04',	-- initial chain. updates when player nears.
		CaptureRadius = 30,
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI:		SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI.		FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI.		FormCallback:Add(P1_NavalPlatoonFormCallback) -- adds platoon to list
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI:		SetChildCount(1)
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI:		AdjustPriority(1)	-- A naval player could kill things quickly. So, make this opai be relatively higher pri, so we get a speedy response.


	-- Naval Engineer Capture OpAI, light
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI = ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(childTemplate1, 'P1_ENEM01_East_NavalCapture02_OpAI', {} )
	local captureData = {
		CaptureChain = 'P1_ENEM01_PatrolNaval_Near_02', -- initial chain. updates when player nears.
		CaptureRadius = 30,
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI:		SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI.		FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI.		FormCallback:Add(P1_NavalPlatoonFormCallback) -- adds platoon to list
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI:		SetChildCount(1)
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI:		AdjustPriority(1)	-- A naval player could kill things quickly. So, make this opai be relatively higher pri, so we get a speedy response.


	-- Naval Engineer Capture OpAI, ATTACK
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI = ScenarioInfo.ArmyBase_ENEM01_East_Base:GenerateOpAIFromPlatoonTemplate(childTemplate1, 'P1_ENEM01_East_NavalCapture03_OpAI', {} )
	local captureData = {
		CaptureChain = 'P1_ENEM01_EastNaval_AttackCapture_Chain_01',
		CaptureRadius = 25,
		CallbackFunction = P1_CaptureCallback,
	}
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI:		SetPlatoonThread( 'CaptureRoute', captureData )
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI.		FormCallback:Add(P1_SetEngineerBuildRate)
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI:		SetAttackDelay(10)
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI:		SetChildCount(1)
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P1_ENEM01_East_NavalCapture03_OpAI:		Disable()

	----------------------------------
	----- Initial platoons handed to OpAI's
	----------------------------------

	--# Initial Naval engineers:
	-- table to hold our initial platoons (used when we change their patrol when we want them to advance).
	ScenarioInfo.P1_EnemyNavalPlatoons = {}

	-- create initial small naval engineer capture patrols, add to table for when their patrol will change, and hand them to their OpAI (small opai)
	for i = 1, 3 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PatrolNaval_Small_0' .. i , 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_PatrolNaval_Near_0' .. i)
		table.insert(ScenarioInfo.P1_EnemyNavalPlatoons, platoon)
		ScenarioInfo.P1_ENEM01_East_NavalCapture02_OpAI:AddActivePlatoon(platoon, true) -- small attack opai
	end

	-- same for a single large naval capture engineer platoon (this platoon goes to the large opai)
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_PatrolNaval_Large_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_PatrolNaval_Near_04')
	table.insert(ScenarioInfo.P1_EnemyNavalPlatoons, platoon)
	ScenarioInfo.P1_ENEM01_East_NavalCapture01_OpAI:AddActivePlatoon(platoon, true) -- large attack opai

end

function P1_NavalPlatoonFormCallback(platoon)
	-- This function is called by naval engineer opais each time one is formed:
	--  add our new platoon to a list of naval platoons, for when we change their patrol chain,
	--  and that of their opai.
	table.insert(ScenarioInfo.P1_EnemyNavalPlatoons, platoon)
end

---------------------------------------------------------------------
-- CUSTOM HANDLING:
---------------------------------------------------------------------
function ViralCaptureCheck(builderUnit)
	-----LOG('ViralCaptureCheck::::::::::::::::::::::::::::::::: 000001')
	-- any builder created by the passed in builderUnit, will be able to spread this function onto any builder created
	-- as a result, all builders involved will be able to know if they ever capture a rogue engineer - which is the goal
	local cats = categories.ucl0001 + categories.ucl0002 + categories.ucl0002 + categories.ucb0001 + categories.ucb0002 + categories.ucb0003
	if builderUnit and not builderUnit:IsDead() and EntityCategoryContains(cats, builderUnit) then
		-----LOG('ViralCaptureCheck::::::::::::::::::::::::::::::::: 000002')
		-- add the viral capture check to future child builders
		builderUnit.Callbacks.OnStopBuild:Add(
			function(builderUnit, unitBeingBuilt)
				-----LOG('ViralCaptureCheck::::::::::::::::::::::::::::::::: 000003')
				if unitBeingBuilt and not unitBeingBuilt:IsDead() then
					-----LOG('ViralCaptureCheck::::::::::::::::::::::::::::::::: 000004')
					ViralCaptureCheck(unitBeingBuilt)
				end
			end
		)

		-- add the capture check to this builder
		builderUnit.Callbacks.OnStopCapture:Add(CustomOnStopCapture)
	end
end

function CustomOnStopCapture(self, target)
	-----LOG('ViralCaptureCheck::::::::::::::::::::::::::::::::: 000005')
	if target and not target:IsDead() and target != self then
		-----LOG('ViralCaptureCheck::::::::::::::::::::::::::::::::: 000006')
		if EntityCategoryContains(categories.ucl0002, target) then
			-----LOG('ViralCaptureCheck::::::::::::::::::::::::::::::::: 000007')
			-- sweet, we captured a unit that is an engineer and now properly in our army! Complete the hidden objective
			if not ScenarioInfo.EnemyEngineerCaptured then
				ScenarioInfo.EnemyEngineerCaptured = true
				if CaptureVOCount > 0 then
					ScenarioFramework.Dialogue(OpDialog.C02_PLAYER_CAPTURES_ENEMY_010, P1_HiddenObj1Complete)
				else
					ScenarioFramework.Dialogue(OpDialog.C02_PLAYER_CAPTURES_ENEMY_020, P1_HiddenObj1Complete)
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	--ForkThread( OpNIS.NIS_VICTORY )
	P1_StartEastHeavyCapture()
end

function OnShiftF4()
	local units = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS,false)
	for k, v in units do
		v:Kill()
	end
end
