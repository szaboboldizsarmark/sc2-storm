---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_U03/SC2_CA_U03_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_U03/SC2_CA_U03_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_U03/SC2_CA_U03_OpNIS.lua')
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
local KrakkenUtils			= import('/lua/sim/ScenarioFramework/ScenarioGameUtilsKrakken.lua')

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

ScenarioInfo.AssignedObjectives = {}

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local P1_TimeLimit								= 900	-- Time at which we force advancement of op to Part2 (seconds)
local P1_ForceCompleteUnitMin					= 25	-- number of player units at which we will force complete P1, if too much time has passed.
local P2_EnemMain_AirDefReplacementSize			= 4		-- after innitial group is destroyed, number of children in ScenarioInfo.P2_ENEM01_AirDef_01_OpAI
local P2_EnemMain_LandDefReplacemetChildcount	= 3		-- after innitial group is destroyed, number of children in ScenarioInfo.P2_ENEM01_LandDef_01_OpAI
local P2_Enem_DestroyerMidPatrolPlatoonCount	= 2		-- MaxActivePlatoons for ScenarioInfo.P2_ENEM01_Naval_01_OpAI

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
-- P1 Destroyer patrols: 	groups: P1_ENEM01_Destoyer_01 through P1_ENEM01_Destoyer_03
--							FUNCTION: OnPopulate() ('P1_ENEM01_Destoyer_0')
--							Does not attack player.
--
--
-- P1 Small gunship patrol:	P1_ENEM01_Gunships01
--							FUNCTION: OnPopulate()
--							TUNE: size in editor (add/remove units from group)
--							Does not attack player.
--
--
-- P2 Base Air Defense:		group: P2_ENEM01_BaseAirPatrol_01, P2_ENEM01_BaseAirPatrol_02
--							FUNCTION: Set up in P2_Setup() and P2_ENEM01_AISetup()
--							TUNE: initial group size in editor. Passed to OpAI:
--								+ScenarioInfo.P2_ENEM01_AirDef_01_OpAI
--							TUNE: P2_EnemMain_AirDefReplacementSize: child count after innitial group is destroyed
--
--
-- P2 Base Land Defense:	group: P2_ENEM01_BaseLandPatrol_01
--							FUNCTION: Set up in P2_Setup() and P2_ENEM01_AISetup()
--							TUNE: initial group size in editor. Passed to OpAI:
--								+ScenarioInfo.P2_ENEM01_LandDef_01_OpAI
--							TUNE: P2_EnemMain_LandDefReplacemetChildcount: child count after innitial group is destroyed
--
--
-- P2 Mid-Bay Entry, Air:	groups: P2_ENEM01_GunshipPatrol_01, P2_ENEM01_GunshipPatrol_02, P2_ENEM01_GunshipPatrol_03
--							FUNCTION: Set up in P2_Setup() and P2_ENEM01_AISetup()
--							TUNE: size in editor. Group 03 is set up to be passed to OpAI, tho this is not currently enabled:
--								+ScenarioInfo.P2_ENEM01_MidAir_01_OpAI
--								NOTE: we want player to have permanent success, thus no replenishment and, if we did consider
--								replenishment, we only do so for one group.
--
--
-- P2 Mid-Bay, Naval:		groups: P2_ENEM01_NavalPatrol_01, P2_ENEM01_NavalPatrol_02
--							FUNCTION: Set up in P2_Setup() and P2_ENEM01_AISetup()
--							TUNE: group size in editor. Not replenished.
--
--
-- P2 Offense: Air Attack to Player:
--							FUNCTION: Set up in P2_Setup() and P2_ENEM01_AISetup()
--							OpAI: small air attack OpAI that is sent to player.
--								+ScenarioInfo.P2_ENEM01_AirAttack_OpAI
--
--
-- P2 Offense: : Naval Patrol, Middle:
--							FUNCTION: Set up in P2_Setup() and P2_ENEM01_AISetup()
--							OpAI: single unit platoon of a destroyer that moves to the bay mouth area.
--								+ScenarioInfo.P2_ENEM01_Naval_01_OpAI
--								Number of destroyers to be mainted for this patrol/attack:
--							TUNE: P2_Enem_DestroyerMidPatrolPlatoonCount: MaxActivePlatoons for ScenarioInfo.P2_ENEM01_Naval_01_OpAI

---------------------------------------------------------------------
-- OPERATION FLOW:
---------------------------------------------------------------------
function OnPopulate(scenario)
	-- construct the camera data
	---NOTE: for other available settings review: //depot/sc2/main/data/lua/system/CameraDefaults.lua
	local camData = {
		MinSpinPitch	= 0.35,		-- 0.1 = default	The min pitch resulting from a spin.
		MaxZoomMult		= 1.4,		-- 1.1 = default	Extra zoom out buffer so we can see the borders of the map clearly.
		FarZoom			= -1,		-- -1 = default		Farthest mouse can zoom out from terrain, measured in LOD units, -1 to ignore.
	}

	-- pass the data through
	ScenarioGameSetup.CAMPAIGN_OnPopulate(camData)

	LOG('----- OnPopulate: Setup Army Tuning.')
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.U03_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.U03_ARMY_ENEM01)
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

	-- create our path-blocking hoo-ha
	ScenarioInfo.O_GRID_BLOCKERS = ScenarioFramework.BlockOGrids('O_GRID_BLOCKERS', 'ARMY_ENEM01')

	LOG('----- P1_Setup: Setup for the player CDR.')
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )


	--# Create Enemey units
	-- Extractors and tech cache
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Extractors')
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')

	-- Destroyer patrols
	for i = 1, 3 do
		local units = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Destoyer_0' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(units, 'P1_ENEMY01_DestrPatrol_0' .. i)
	end

	-- Small gunship patrol over the Destroyer area
	local gunships = ScenarioUtils.CreateArmyGroup( 'ARMY_ENEM01', 'P1_ENEM01_Gunships01' )
	for k, v in gunships do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('P1_ENEM01_Gunship_Patrol_01'))
	end
end

function P1_Main()
	local radar = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_Radar']
	if radar and not radar:IsDead() then
		ProtectUnit(radar)
	end

	----------------------------------------------
	-- Primary Objective M1_obj10 - Build Mass
	----------------------------------------------
	LOG('----- P1_Main: Assign Primary Objective M1_obj10 - Build Mass.')
	local descText = OpStrings.U03_M1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U03_M1_obj10_MAKE_MASS)
	ScenarioInfo.M1_obj10 = SimObjectives.CategoriesInArea(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.U03_M1_obj10_NAME,			-- title
		descText,								-- description
		'build',								-- Action
		{
			---NOTE: I decided to remove the area marking and rely just on the arrow - speak with me before changing this back
			---			the rationale is a compromise to narrow the scope of area area-objective visualization issues to just U06 - bfricks 11/28/09
			AddArrow = true,
			ArrowHeight = 10.0,
			Requirements = {
				{Area = 'P1_Extractor_Site_01', Category = categories.uub0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
				{Area = 'P1_Extractor_Site_02', Category = categories.uub0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
				{Area = 'P1_Extractor_Site_03', Category = categories.uub0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
				{Area = 'P1_Extractor_Site_04', Category = categories.uub0701 + categories.ucb0701, CompareOp = '>=', Value = 1, ArmyIndex = ARMY_PLAYER},
			},
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)
	ScenarioInfo.M1_obj10:AddProgressCallback(
		function(current, total)
			if current == 1 then
				ScenarioFramework.Dialogue(OpDialog.U03_M1_obj10_EXTRACTOR_BUILT)
			end
		end
	)
	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U03_M1_obj10_MAKE_MASS, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.U03_M1_obj10_COMPLETE, P2_Setup)
			end
		end
	)

	-- Hidden objective trigger (build an experimental carrier)
	ScenarioFramework.CreateArmyStatTrigger (P1_HiddenObj1Complete, ArmyBrains[ARMY_PLAYER], 'P1_HiddenObj1',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uux0104}})


	---# VO related triggers #---

	-- VO on spotting enemy naval patrol
	ScenarioFramework.CreateArmyIntelTrigger(function() ScenarioFramework.Dialogue(OpDialog.U03_CYBRAN_NAVAL_REVEAL_010) end,
	 ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true, categories.ucs0103, true, ArmyBrains[ARMY_ENEM01])

	-- Confirmation when the player kills any of the Cybran extractors
	ScenarioFramework.CreateArmyStatTrigger (P1_ConfirmationVO_ExtractorKilled, ArmyBrains[ARMY_ENEM01], 'P1_ConfirmationVO_ExtractorKilled',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ucb0701}})

	-- after a bit - launch some VO about the value of submarines
	ScenarioFramework.CreateTimerTrigger (P1_AdviceVO_Submarine, 25)

	-- and after a bit longer, launch the research unlock dialog
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 60)

	-- When player has built a Cruiser, provide information on the unit
	ScenarioFramework.CreateArmyStatTrigger (P1_AdviceVO_CruiserBuilt, ArmyBrains[ARMY_PLAYER], 'P1_PlayerBuiltCruiser',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uus0102}})

	-- When player has built a Battleship, provide information on the unit
	ScenarioFramework.CreateArmyStatTrigger (P1_AdviceVO_BattleshipBuilt, ArmyBrains[ARMY_PLAYER], 'P1_PlayerBuiltBattleship',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uus0105}})

	-- After a while, check how many factories the player has. If they havent built any extra,
	-- play some VO advising they do so.
	ScenarioFramework.CreateTimerTrigger (PlayerFactoryAdvice_Check, 300)

	-- timer that will force the advancement of the op, after a period of time
	ScenarioFramework.CreateTimerTrigger (P1_PlayerUnitCheck, P1_TimeLimit)
end

function P1_PlayerUnitCheck()
	LOG('----- P1: Timer hit, checking player units')

	if ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ALLUNITS) >= P1_ForceCompleteUnitMin and not ScenarioInfo.M1_obj10.Complete then
		LOG('----- P1: Player has sufficient units, force completing Part 1.')
		ScenarioFramework.Dialogue(OpDialog.U03_M1_obj10_FORCE_COMPLETE, P2_Setup)

	-- If not, we will check again soon, if the objective hasnt already been completed.
	elseif not ScenarioInfo.M1_obj10.Complete then
		LOG('----- P1: Timer has hit zero, but player has insufficient units. Will recheck in 30 seconds')
		ScenarioFramework.CreateTimerTrigger (P1_PlayerUnitCheck, 30)
	end
end

function P1_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Master of the Seas
	----------------------------------------------
	LOG('----- Complete Hidden Objective H1_obj10 - Master of the Seas')
	local descText = OpStrings.U03_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U03_H1_obj10_MAKE_ATLANTIS)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.U03_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('build'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U03_H1_obj10_MAKE_ATLANTIS, ARMY_PLAYER, 3.0)
end

---------------------------------------------------------------------
-- PART 2:
---------------------------------------------------------------------
function P2_Setup()
	-- early out if we have already called P2_Setup - since there are two methods for this to be triggered
	if ScenarioInfo.PartNumber == 2 then
		return
	end

	-- destroy our path-blocking hoo-ha
	DestroyGroup(ScenarioInfo.O_GRID_BLOCKERS)

	LOG('----- P2_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 2

	-- Create Gauge, and set him to be damagable, but not capturable (he will gate out instead of getting killed)
	-- Put a trigger on him to detect if he gets drawn away. This will get him back to base, and then send
	-- him on a base area patrol again.
	ScenarioInfo.ENEM01_CDR	= ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_EnemyCDR')
	ScenarioInfo.ENEM01_CDR:SetCustomName(ScenarioGameNames.CDR_Gauge)
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.ENEM01_CDR}, 'P2_ENEM01_GaugeBasePatrol_Chain')
	ScenarioFramework.CreateAreaTrigger(P2_ReturnGaugeToBase, 'P2_ENEM01_GaugeLocationCheck_Area',
		categories.ucl0001, true, true, ArmyBrains[ARMY_ENEM01])
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_CDR, 3)
	ScenarioInfo.ENEM01_CDR:SetCanBeKilled(false)
	ScenarioInfo.ENEM01_CDR:SetReclaimable(false)
	ScenarioInfo.ENEM01_CDR:SetCapturable(false)

	-- setup a damage trigger on Gauge - when it fires off - advance to the special megalith ending
	---NOTE: switching to a health ratio trigger -which fits the intentions correctly - bfricks 11/8/09
	ScenarioFramework.CreateUnitHealthRatioTrigger(
		function()
			ForkThread(
				function()
					ScenarioInfo.ArmyBase_ENEM01_Main_Base:BaseActive(false) -- gauge base turned off.
					P2_GaugeExitSetup()
					OpNIS.NIS_GAUGE_ESCAPE()
					P2_GaugeExitCleanup()
				end
			)
		end,
		ScenarioInfo.ENEM01_CDR,
		0.5,
		true,
		true
	)

	-- The dispersed group of extractors, and other assorted structures near them
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_Extractors')
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_Extended_Structures')

	-- Set up enemy patrols
	-- air:
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_GunshipPatrol_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(units, 'P2_ENEMY01_GunshipPatrol_02')
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_GunshipPatrol_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(units, 'P2_ENEMY01_GunshipPatrol_01')
	ScenarioInfo.P2_ENEM02_MidAir_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_GunshipPatrol_03', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.P2_ENEM02_MidAir_01, 'P2_ENEMY01_GunshipPatrol_03')

	ScenarioInfo.P2_ENEM01_BaseAir_Def_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_BaseAirPatrol_01', 'AttackFormation')
	ScenarioInfo.P2_ENEM01_BaseAir_Def_02 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_BaseAirPatrol_02', 'AttackFormation')

	-- naval:
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_NavalPatrol_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(units, 'P2_ENEMY01_NavalPatrol_01')
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_NavalPatrol_02', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(units, 'P2_ENEMY01_NavalPatrol_02')
	-- land:
	ScenarioInfo.P2_ENEM01_BaseLand_Def_01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_BaseLandPatrol_01', 'AttackFormation')

	-- Base Manager setup. This should be called after the hand-spawned units are created, as some of them
	-- are passed to the OpAI's for use
	P2_ENEM01_AISetup()

	-- krakken:
	ScenarioInfo.P2_Kraken = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01','P2_ENEM01_Kraken')
	-- store a flag so we can know if the krakken is surfaced or not
	ScenarioInfo.P2_Kraken.Surfaced = true

	-- Create p2 area tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_TechCache')

	ForkThread(P2_Transition)
end

function P2_Transition()
	OpNIS.NIS_REVEAL_ENEMY()
	P2_Main()
end

function P2_Main()
	----------------------------------------------
	-- Primary Objective M2_obj10 - Destroy Gauge
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M2_obj10 - Destroy Gauge.')
	ScenarioInfo.M2_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.U03_M2_obj10_NAME,			-- title
		OpStrings.U03_M2_obj10_DESC,			-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.ENEM01_CDR},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)

	-- When player sights the Bay gunship defense, play some advisory VO
	ScenarioFramework.CreateArmyIntelTrigger(P2_GunshipAdvise, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		categories.uca0103, true, ArmyBrains[ARMY_ENEM01])

	-- VO on spotting enemy kraken
	ScenarioFramework.CreateArmyIntelTrigger(P2_KrakenSpotted_VO, ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true,
		categories.ucx0113, true, ArmyBrains[ARMY_ENEM01])

	-- kraken damaged to 50 percent, play VO.
	---NOTE: switching to a health ratio trigger -which fits the intentions correctly - bfricks 11/8/09
	ScenarioFramework.CreateUnitHealthRatioTrigger( function() ScenarioFramework.Dialogue(OpDialog.U03_KRAKEN_DAMAGE_050) end,
		ScenarioInfo.P2_Kraken, 0.5, true, true)

	P2_AssignKrakenObjective()

	-- When the enemy kills one more battleship than whatever we started part2 has having killed, play some brief taunt.
	local amount = ArmyBrains[ARMY_ENEM01]:GetBlueprintStat('Enemies_Killed',categories.uus0105) + 1
	ScenarioFramework.CreateArmyStatTrigger (P2_PlayerLostBattleship_VO, ArmyBrains[ARMY_PLAYER], 'PlayerBattleshipLost_VO',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = amount, Category = categories.uus0105}})

	-- When the player kills a particular mass extractor thats a bit out of the way, play a longer taunt.
	local unit = ScenarioInfo.UnitNames[ARMY_ENEM01]['P2_ENEM01_NW_Extractor']
	--ScenarioFramework.CreateUnitDestroyedTrigger(P2_PlayerDestroyedMass_VO, unit)
	ScenarioFramework.CreateUnitDeathTrigger(P2_PlayerDestroyedMass_VO, unit)
end

function P2_AssignKrakenObjective()
	----------------------------------------------
	-- Secondary Objective S1_obj10 - Destroy the Kraken
	----------------------------------------------
	LOG('----- P2: Assign Secondary Objective S1_obj10 - Destroy the Kraken.')
	local descText = OpStrings.U03_S1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U03_S1_obj10_KILL_KRAKKEN)
	ScenarioInfo.S1_obj10 = SimObjectives.KillOrCapture(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.U03_S1_obj10_NAME,			-- title
		descText,								-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.P2_Kraken},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)

	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U03_S1_obj10_KILL_KRAKKEN, ARMY_PLAYER, 3.0)

				-- play VO appropriate to whether Gauge is around or not.
				if not ScenarioInfo.GaugeHasEscaped then
					ScenarioFramework.Dialogue(OpDialog.U03_P2_S1_COMPLETE_GAUGE)
				else
					ScenarioFramework.Dialogue(OpDialog.U03_P2_S1_COMPLETE_OPS)
				end
			end
		end
	)

	KrakkenUtils.LaunchKrakkenAI(ScenarioInfo.P2_Kraken, 'P2_ENEMY01_Kraken_Patrol', 'KRAKKEN_HOME', 'KRAKKEN_AREA', 30.0)
end

function P2_ReturnGaugeToBase()
	-- Gauge got pulled away from his base. Move him back to base, and when he gets near to it,
	-- send him on patrol.
	if not ScenarioInfo.P2_GaugeDefeated then
		if ScenarioInfo.ENEM01_CDR and not ScenarioInfo.ENEM01_CDR:IsDead() then
			LOG('----- P2: Gauge has strayed too far from his base. Sending him back him back.')
			IssueClearCommands({ScenarioInfo.ENEM01_CDR})
			IssueMove( {ScenarioInfo.ENEM01_CDR}, ScenarioUtils.MarkerToPosition( 'P2_ENEM01_CommanderDistanceCheck_Marker' ) )
			ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P2_ReturnGaugeToPatrol, ScenarioInfo.ENEM01_CDR, 'P2_ENEM01_CommanderDistanceCheck_Marker', 10 )
		end
	end
end

function P2_ReturnGaugeToPatrol()
	-- gauge is near his base again. Back on patrol now.
	if not ScenarioInfo.P2_GaugeDefeated then
		if ScenarioInfo.ENEM01_CDR and not ScenarioInfo.ENEM01_CDR:IsDead() then
			LOG('----- P2: Gauge is back to his base. Restarting his base area patrol')
			-- Back on patrol
			IssueClearCommands({ScenarioInfo.ENEM01_CDR})
			ScenarioFramework.GroupPatrolChain({ScenarioInfo.ENEM01_CDR}, 'P2_ENEM01_GaugeBasePatrol_Chain')
			-- Recreate a distance trigger that will again detect that he has strayed.
			ScenarioFramework.CreateAreaTrigger(P2_ReturnGaugeToBase, 'P2_ENEM01_GaugeLocationCheck_Area', categories.ucl0001, true, true, ArmyBrains[ARMY_ENEM01])
		end
	end
end

function P2_GaugeExitSetup()
	-- Flag that this event has begun, for other checks.
	ScenarioInfo.P2_GaugeDefeated = true


	-- get Gauge into position
	IssueClearCommands({ScenarioInfo.ENEM01_CDR})
	Warp( ScenarioInfo.ENEM01_CDR, ScenarioUtils.MarkerToPosition('NIS_GAUGE_ESCAPE_Gauge_WarpTo') )

	-- get the Megaliths ready
	ScenarioInfo.P2_Megalith01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_GaugeNIS_Megalith_01')
	ScenarioInfo.P2_Megalith02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_GaugeNIS_Megalith_01')
	ScenarioInfo.P2_Megalith03 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_GaugeNIS_Megalith_01')
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.P2_Megalith01, 5)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.P2_Megalith02, 5)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.P2_Megalith03, 5)

	-- store megaliths in a table
	ScenarioInfo.P2_MegalithUnits = {ScenarioInfo.P2_Megalith01, ScenarioInfo.P2_Megalith02, ScenarioInfo.P2_Megalith03}

	-- Protect the megaliths
	ProtectGroup(ScenarioInfo.P2_MegalithUnits)
end

function P2_GaugeExitCleanup()
	ScenarioInfo.M2_obj10:ManualResult(true)

	----------------------------------------------
	-- Primary Objective M2_obj20 - Destroy Megaliths
	----------------------------------------------
	LOG('----- P2: Assign Primary Objective M2_obj20 - Destroy Megaliths.')
	ScenarioInfo.M2_obj20 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.U03_M2_obj20_NAME,			-- title
		OpStrings.U03_M2_obj20_DESC,			-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			AlwaysInRadar = true,
			Units = ScenarioInfo.P2_MegalithUnits,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj20)

	-- Set the megalith flags back to normal, now that it is safe to kill them
	UnProtectGroup(ScenarioInfo.P2_MegalithUnits)

	-- setup each megalith for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P2_Megalith01, HandlePossibleVictory)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P2_Megalith02, HandlePossibleVictory)
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.P2_Megalith03, HandlePossibleVictory)

	-- Flag that gauge has escaped, for VO checks (flag instead of checking his Objective, as that
	-- may become an updated, instead of force-completed, objective)
	ScenarioInfo.GaugeHasEscaped = true
end

function P2_ENEM01_AISetup()
	--# Gauge's base
	local levelTable_ENEM01_Main_Base = {
		P2_ENEM01_MainBase_100 = 100,
		P2_ENEM01_MainBase_90 = 90,
	}

	ScenarioInfo.ArmyBase_ENEM01_Main_Base = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('ArmyBase_ENEM01_Main_Base',
		 'P2_ENEM01_MainBase_Marker', 50, levelTable_ENEM01_Main_Base)
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:StartNonZeroBase(1)


	--# Basic base air defense (Note: this OpAI uses children containing 1 unit. So, Child count equals platoon size)
	ScenarioInfo.P2_ENEM01_AirDef_01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirFightersCybran', 'P2_ENEM01_AirDef_01_OpAI', {} )
	ScenarioInfo.P2_ENEM01_AirDef_01_OpAI_Data	= {PatrolChain = 'P2_ENEMY01_Base_AirPAtrol_01',}
	ScenarioInfo.P2_ENEM01_AirDef_01_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', ScenarioInfo.P2_ENEM01_AirDef_01_OpAI_Data )

	ScenarioInfo.P2_ENEM01_AirDef_01_OpAI:		SetMaxActivePlatoons(2)
	ScenarioInfo.P2_ENEM01_AirDef_01_OpAI:		SetChildCount(P2_EnemMain_AirDefReplacementSize)
	ScenarioInfo.P2_ENEM01_AirDef_01_OpAI:		AddActivePlatoon(ScenarioInfo.P2_ENEM01_BaseAir_Def_01, true)
	ScenarioInfo.P2_ENEM01_AirDef_01_OpAI:		AddActivePlatoon(ScenarioInfo.P2_ENEM01_BaseAir_Def_02, true)


	--# Basic base land defense
	local EnemyLandChild_01 = {
		'Enemy_LandDefense_01',
		{
			{ 'ucl0104', 1 },
			{ 'ucl0204', 1 },
		},
	}
	ScenarioInfo.P2_ENEM01_LandDef_01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:GenerateOpAIFromPlatoonTemplate(EnemyLandChild_01, 'P2_ENEM01_LandDef_01_OpAI', {} )
	local P2_ENEM01_LandDef_01_OpAI_Data	 	= { AnnounceRoute = true, PatrolChains = { 'P2_ENEMY01_Base_LandPatrol_01', },}
	ScenarioInfo.P2_ENEM01_LandDef_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P2_ENEM01_LandDef_01_OpAI_Data )
	ScenarioInfo.P2_ENEM01_LandDef_01_OpAI:		SetChildCount(P2_EnemMain_LandDefReplacemetChildcount)
	ScenarioInfo.P2_ENEM01_LandDef_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P2_ENEM01_LandDef_01_OpAI:		AddActivePlatoon( ScenarioInfo.P2_ENEM01_BaseLand_Def_01, true)


	--# Light naval attack/patrol
	local EnemyDestroyerChild_01 = {
		'EnemyDestroyerChild_01',
		{
			{ 'ucs0103', 1 },
		},
	}
	local behaviorHubData = {
		Announce = true,
		Behaviors = {
			{ BehaviorName = 'AggressiveMove', Chain = 'P2_ENEM01_NavalAttack01_Approach' },	-- head out to the main area
			{ BehaviorName = 'Patrol', Chain = 'P2_ENEM01_NavalAttack01_Patrol' }, -- then begin a normal looping patrol there
		},
	}
	ScenarioInfo.P2_ENEM01_Naval_01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:GenerateOpAIFromPlatoonTemplate(EnemyDestroyerChild_01, 'P2_ENEM01_Naval_01_OpAI', {} )
	ScenarioInfo.P2_ENEM01_Naval_01_OpAI:		SetPlatoonThread( 'PlatoonBehaviorHub', behaviorHubData )
	ScenarioInfo.P2_ENEM01_Naval_01_OpAI:		SetChildCount(1)
	ScenarioInfo.P2_ENEM01_Naval_01_OpAI:		SetMaxActivePlatoons(P2_Enem_DestroyerMidPatrolPlatoonCount)


	--# General mid-area gunship patrol (disabled for now.)
	local EnemyGunshipChild_01 = {
		'EnemyGunshipChild_01',
		{
			{ 'uca0103', 4 },
		},
	}
	ScenarioInfo.P2_ENEM01_MidAir_01_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:GenerateOpAIFromPlatoonTemplate(EnemyGunshipChild_01, 'P2_ENEM01_MidAir_01_OpAI', {} )
	local P2_ENEM01_MidAir_01_OpAI_Data	 		= { AnnounceRoute = true, PatrolChains = { 'P2_ENEMY01_GunshipPatrol_04', },}
	ScenarioInfo.P2_ENEM01_MidAir_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P2_ENEM01_LandDef_01_OpAI_Data )
	ScenarioInfo.P2_ENEM01_MidAir_01_OpAI:		SetChildCount(1)
	ScenarioInfo.P2_ENEM01_MidAir_01_OpAI:		SetMaxActivePlatoons(1)
	--ScenarioInfo.P2_ENEM01_MidAir_01_OpAI:		AddActivePlatoon( ScenarioInfo.P2_ENEM02_MidAir_01, true)
	ScenarioInfo.P2_ENEM01_MidAir_01_OpAI:		Disable() -- this opai is set up for potential future use, if we decide to put push back against player more.


	--# Basic air attack against player
	ScenarioInfo.P2_ENEM01_AirAttack_OpAI		= ScenarioInfo.ArmyBase_ENEM01_Main_Base:AddOpAI('AirAttackCybran', 'P2_ENEM01_AirAttack_01_OpAI', {} )
	ScenarioInfo.P2_ENEM01_AirAttack_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P2_ENEMY01_AirAttack_Route_01',},}
	ScenarioInfo.P2_ENEM01_AirAttack_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P2_ENEM01_AirAttack_OpAI_Data )

	ScenarioInfo.P2_ENEM01_AirAttack_OpAI:		SetChildCount(1)
	ScenarioInfo.P2_ENEM01_AirAttack_OpAI:		AdjustPriority(1) -- favor attacks over defense patrols
	ScenarioInfo.P2_ENEM01_AirAttack_OpAI:		SetMaxActivePlatoons(2)
end

---------------------------------------------------------------------
-- VO RELATED FUNCTIONS:
---------------------------------------------------------------------
function P1_ConfirmationVO_ExtractorKilled()
	ScenarioFramework.Dialogue(OpDialog.U03_M1_obj10_EXTRACTOR_DESTROYED)
end

function P1_AdviceVO_Submarine()
	ScenarioFramework.Dialogue(OpDialog.U03_ADVICE_SUBMARINE_010)
end

function P1_ResearchSecondary_VO()
	ScenarioFramework.Dialogue(OpDialog.U03_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.U03_S2_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective - Research Technology.')
	ScenarioInfo.S2_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.U03_S2_obj10_NAME,	-- title
		descText,						-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj10)

	ScenarioInfo.S2_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.U03_RESEARCH_FOLLOWUP_BATTLESHIP_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (P1_ResearchReminder1, 300)
end

function P1_ResearchReminder1()
	if ScenarioInfo.S2_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.U03_RESEARCH_REMINDER_010)
	end
end

function P1_AdviceVO_CruiserBuilt()
	if not ScenarioInfo.GaugeHasEscaped then
		ScenarioFramework.Dialogue(OpDialog.U03_ADVICE_CRUISER_010)
		ScenarioFramework.Dialogue(OpDialog.U03_TIP_030)
	end
end

function P1_AdviceVO_BattleshipBuilt()
	if not ScenarioInfo.GaugeHasEscaped then
		ScenarioFramework.Dialogue(OpDialog.U03_ADVICE_BATTLESHIP_010)
	end
end

function PlayerFactoryAdvice_Check()
	-- if the player hasnt built extra factories, play VO advising doing so.
	local factories = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0002 + categories.uub0003)
	if factories <= 2 then
		ScenarioFramework.Dialogue(OpDialog.U03_ADVICE_FACTORIES_010)
	end
end

function P2_GunshipAdvise()
	--if its not late in the op (Gauge gone), play some advisory VO
	if not ScenarioInfo.GaugeHasEscaped then
		ScenarioFramework.Dialogue(OpDialog.U03_P2_GUNSHIP_ADVISE_010)
	end
end

function P2_KrakenSpotted_VO()
	--play some banter when player spots the kraken
	if ScenarioInfo.P2_Kraken and not ScenarioInfo.P2_Kraken:IsDead() and not ScenarioInfo.GaugeHasEscaped then
		ScenarioFramework.Dialogue(OpDialog.U03_GAUGE_BANTER_KRAKEN)
	end
end

function P2_PlayerLostBattleship_VO()
	if not ScenarioInfo.GaugeHasEscaped then
		ScenarioFramework.Dialogue(OpDialog.U03_GAUGE_BANTER_01)
	end
end

function P2_PlayerDestroyedMass_VO()
	if not ScenarioInfo.GaugeHasEscaped then
		ScenarioFramework.Dialogue(OpDialog.U03_GAUGE_BANTER_02)
	end
end

---------------------------------------------------------------------
-- UNIT SPECIFIC NIS LAUNCHING:
---------------------------------------------------------------------
function HandlePossibleVictory(unit)
	if not ScenarioInfo.VictoryTracker then
		-- first time, we just set the value
		ScenarioInfo.VictoryTracker = 1
	else
		-- every other time we up the value
		ScenarioInfo.VictoryTracker = ScenarioInfo.VictoryTracker + 1
	end

	if ScenarioInfo.VictoryTracker == 3 then
		-- on the third time we launch the victory NIS
		LaunchVictoryNIS(unit)
	else
		---NOTE: before, we were just unflagging the unit as killable - that is broken because there is no certainty that the
		---			player will continue to kill this unit - so we have to force kill it. Down the road - when we have a better health ratio system
		---			this should be considerably more readible - bfricks 11/8/09
		-- otherwise we force kill the unit
		ForceUnitDeath(unit)
	end
end

function LaunchVictoryNIS(unit)
	ForkThread(OpNIS.NIS_VICTORY, unit)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	--P2_Setup()
	--P1_PlayerUnitCheck()
	LOG('----- Disabling main base.')
	ScenarioInfo.ArmyBase_ENEM01_Main_Base:BaseActive(false)
end

function OnShiftF4()
	ForkThread(
		function()
			ScenarioInfo.ArmyBase_ENEM01_Main_Base:BaseActive(false) -- gauge base turned off.
			P2_GaugeExitSetup()
			OpNIS.NIS_GAUGE_ESCAPE()
			P2_GaugeExitCleanup()
		end
	)
end

function OnShiftF5()
	LaunchVictoryNIS(ScenarioInfo.P2_Megalith01)
end

function OnShiftF6()
end
