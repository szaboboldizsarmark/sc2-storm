---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_U02/SC2_CA_U02_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_U02/SC2_CA_U02_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_U02/SC2_CA_U02_OpNIS.lua')
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

ScenarioInfo.P2_SouthGunshipsDead = false
ScenarioInfo.P1_AllyVO_Blocked = false

ScenarioInfo.P1_EndPartCounter = 0
ScenarioInfo.P1_AttacksAllowed = true

---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_ALLY01 = ScenarioInfo.ARMY_ALLY01

local Gunship_AllyPlatoonVOCount		= 0
local AllyPlatoonVOCount 				= 0
local AllyPlatoonDeathCount				= 0

local P2_CounterattackNilCounter 		= 0

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------

local P1_OffmapPlayer_Min			= 5		-- minimum wieghted value for an offmap air attack
local P1_OffmapPlayer_MinExtra		= 8		-- minimum wieghted value for extra units to be added to the minimum attack
local P1_OffmapPlayer_MinSize		= 2 	-- number of fighterbombers in the basic minimum-sized offmap air attack
local P1_OffmapPlayer_PlayerMod		= 4		-- how many points of Strength result in an attacking unit spawned?
local P1_OffmapPlayer_DelayMin		= 19	-- delay min between attacks, after the attacking platoon has been killed
local P1_OffmapPlayer_DelayMax		= 35	-- delay max between attacks, after the attacking platoon has been killed

local P1_Player_AATowerWeight		= 1.3	-- Weighting for each type of unit tracked for offmap attacks
local P1_Player_aaAddonWeight		= 1
local P1_Player_FightersWeight		= 1
local P1_Player_GunshipWeight		= 0.75

local P2_Counterattack_PlayerMod 	= 3		-- Weighting for num player units to create on counterattack aircraft.

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
--
--
-- P3 Ally, Enemy Setup:	The ally and enemy both use hand-spawned initial defenders and attacks.
--							Enemy defense patrols (air, land) are not maintained. This is to ensure that
--							player progress feels substantial, and to minimize pushback. Ally initial land
--							patrols are just for show and initial activity, and are as well not maintained by
--							OpAI. Note that the enemy Economy area to the west, and the enemy Defensive Line
--							to the south, as well are not maintained via OpAI, for the same reasons.
--
--							Initial attacks are hand created, so we have attacks in progress when the Part begins.
--							These attacks are generally created with handle, and subsequently passed to the respective
--							OpAIs as active platoons.
--							FUNCTION: P2_Setup, with some initial attack handles subsequently used in OpAI, functions
--								P2_SetupAllyAI and P2_SetupEnemyAI.
--
--
-- P3 air to player OpAI:	Light air attack west, against Player. Uses a custom platoon, instead of
--							normal adaptive OpAI.
--							FUNCTION: P2_SetupEnemyAI
--							TUNE: Child, script, AirAttackPlayer01. OpAI, ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI
--								Size, ChildCount (number of custom children AirAttackPlayer01. Keep value as multiple of
--								enemy base air factory count, for efficieny).
--
--
-- P3 air to ally OpAI:		Sizable non-custom ground attacks south to ally.
--							FUNCTION: P2_SetupEnemyAI
--							TUNE: OpAI, ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI.
--
--
-- P3 Ally Attacks:			Land attacks north against Enemy, that importnatly contain no anti-air (encourages player to help).
--							Uses just tanks, currently.
--							FUNCTION: P2_SetupAllyAI
--							TUNE: OpAI, ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.U02_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.U02_ARMY_ENEM01)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ALLY01,	ScenarioGameTuning.U02_ARMY_ALLY01)

	LOG('----- OnPopulate: Update Build and Research Restrictions.')
	ScenarioFramework.AddRestriction(ARMY_PLAYER, categories.ALLUNITS) 				-- Restrict all units

	-- enable builders
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0002, true)		-- Enable construction of the UEF air factory
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0002, true)		-- Enable engineer

	-- enable non-research bound structures
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0102, true)		-- Enable AA tower
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0301, true)		-- Enable radar
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0801, true)		-- Enable research facility
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0701, true)		-- Enable mass extractor
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0702, true)		-- Enable energy production facility

	-- enable non-research bound mobile units
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uua0102, true)		-- Enable Bomber
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uua0101, true)		-- Enable Fighter

	-- enable selected addons
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0121, true)		-- Enable AA add-ons
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0141, true)		-- Enable intel add-ons
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
		areaStart		= 'P1_PlayableArea',	-- if valid, the area to be used for setting the starting playable area
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

	-- create units used in the opening NIS sequence - including the player CDR
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')
	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_Transport_01')

	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Maddox)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	-- Starting Intel
	ScenarioFramework.CreateIntelAtLocation(275, 'PLAYER_Radar_Marker', ARMY_PLAYER, 'Radar')

	-- Structures, wreckage, engineers, air patrol
	ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Starting_Structures')
	ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'zWRECKAGE', true)
	ScenarioInfo.PlayerInitEngineers = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Starting_Engineers')
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_PLAYER', 'P1_PLAYER_Starting_AA_01', 'AttackFormation')
	-- ScenarioFramework.PlatoonPatrolChain(units, 'P1_PLAYER01_Def_Patrol_01') Trying out a no-patrol opening.

	-- VO trigger, when engineers are dead, tell player to build more.
	ScenarioFramework.CreateGroupDeathTrigger(AdviseVO_Engineers, ScenarioInfo.PlayerInitEngineers)

	---------------
	-- Enemy  Setup:
	---------------

	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_South_Init_Land_01', 'AttackFormation')
	local engineer = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_South_Init_Eng', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_South_Defense_Land_Patrol_01')
	ScenarioFramework.PlatoonPatrolChain(engineer, 'P1_ENEM01_South_Area_EngineerChain')

	-- gunship patrol for objective
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_South_Init_Air_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_South_Defense_Air_Patrol_01')
	ScenarioInfo.P2_ObjectiveAirUnits = platoon:GetPlatoonUnits()

	-- Objective structures
	ScenarioInfo.P1_EnemyObjStructures = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_South_Area')

	-- Create p1 area tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')

	---------------
	-- Ally Setup:
	---------------

	ScenarioInfo.ALLY01_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ALLY01', 'ALLY01_CDR')
	ScenarioInfo.ALLY01_CDR:SetCustomName(ScenarioGameNames.CDR_Coleman)
	ProtectUnit(ScenarioInfo.ALLY01_CDR)

	---NOTE: because it can look bad, protected ally CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.ALLY01_CDR:RemoveCommandCap('RULEUCC_Reclaim')

	-- Ally initial patrols
	for i = 1, 2 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_Main_Init_Land_0' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ALLY01_Main_Defense_Land_Patrol_0' .. i)
	end

	-- initial attack, to hand to ally opai, and a stationary group to be fighting immediately. Ally init attack
	-- will trigger some informative VO.
	ScenarioInfo.P1_ALLY01_Main_InitLandAttack01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ALLY01', 'P1_ALLY01_Init_LandAttack_01', 'AttackFormation')
	ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Init_LandAttack_02_Stationary')

	-- Ally base setup
	P1_AllyAISetup()
end

function P1_Main()
	P1_AssignPrimaryObjectives()

	-- Begin offmap attack loops against ally: one immediate, and three more delayed.
	P1_AttackAllyOffmap01_CreateAttack()
	ScenarioFramework.CreateTimerTrigger (P1_AttackAllyOffmap02_CreateAttack, 10)
	ScenarioFramework.CreateTimerTrigger (P1_AttackAllyOffmap01_CreateAttack, 20)
	ScenarioFramework.CreateTimerTrigger (P1_AttackAllyOffmap02_CreateAttack, 40)

	-- start the check/attack loop against player, after a delay
	ScenarioFramework.CreateTimerTrigger(P1_AttackPlayerOffmap_CreateAttack, 35)

	-- After a delay, assign the research objective
	ScenarioFramework.CreateTimerTrigger(P1_ResearchObjective_VO, 25)

	---------------
	-- Advice VO triggers:
	---------------
	-- VO: mention rebuilding bonus.
	ScenarioFramework.CreateTimerTrigger(function()ScenarioFramework.Dialogue(OpDialog.U02_TIP_010) end, 43)

	-- VO: advice after second fighter built: General 2
	ScenarioFramework.CreateArmyStatTrigger (AdviseVO_GeneralAdvice2, ArmyBrains[ARMY_PLAYER], 'AdviseVO_GeneralAdvice2',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 9, Category = categories.AIR}})

	-- VO: advice when a factory has been built: turret addons
	ScenarioFramework.CreateArmyStatTrigger (AdviseVO_FactoryAA, ArmyBrains[ARMY_PLAYER], 'U02_BUILD_ADVICE_FACTORYAA_010',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uub0002}})

	-- VO: advice check if player hasnt built much mass
	ScenarioFramework.CreateTimerTrigger (AdviseVO_BuildMassExtractor, 250)

	-- VO: advice check if player hasnt built much AA
	ScenarioFramework.CreateTimerTrigger (AdviseVO_AntiAirTowers, 350)

	-- VO: advice check if player hasnt built extra factories
	ScenarioFramework.CreateTimerTrigger (AdviseVO_Factory, 430)
end

function P1_AssignPrimaryObjectives()
	----------------------------------------------
	-- Primary Objective 1 - Destroy Enemy Defenses
	----------------------------------------------
	LOG('----- P1: Assign primary objective 1: destroy enemy defenses.')
	local descText = OpStrings.U02_M1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U02_M1_obj10_KILL_STRUCTURES)
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.U02_M1_obj10_NAME,		-- title
		descText,							-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = ScenarioInfo.P1_EnemyObjStructures,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)
	ScenarioInfo.M1_obj10:AddProgressCallback(
		function(current)
			if current == 10 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_DESTROY_DEFENSE_OBJ_PROGRESS_010)
			end
		end
	)
	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if result then
				-- Update the ally land attack routes to ones that move straight through the defensive line, now that
				-- the defense structures are gone. (Up 'til now, they will do a single back-and-forth over the area).
				ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI_Data	= {AnnounceRoute = true, PatrolChains = { 'P1_ALLY01_LandAttack_01b', 'P1_ALLY01_LandAttack_02b',},}
				ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI:SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI_Data )

				-- reward, and increment the counter that will lead to part end if both objs are complete.
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U02_M1_obj10_KILL_STRUCTURES, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.U02_P1_DESTROY_DEFENSE_OBJ_COMPLETE_010, P1_EndPartCounter)
			end
		end
	)

	----------------------------------------------
	-- Primary Objective 2 - Destroy Enemy Gunships
	----------------------------------------------
	LOG('----- P1: Assign primary objective 2: destroy enemy gunships.')
	local descText = OpStrings.U02_M1_obj20_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U02_M1_obj20_KILL_GSHIPS)
	ScenarioInfo.M1_obj20 = SimObjectives.KillOrCapture(
		'primary',							-- type
		'incomplete',						-- status
		OpStrings.U02_M1_obj20_NAME,		-- title
		descText,							-- description
		{
			MarkUnits = true,
			Units = ScenarioInfo.P2_ObjectiveAirUnits,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj20)
	ScenarioInfo.M1_obj20:AddProgressCallback(
		function(current)
			if current == 3 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_DESTROY_GUNSHIP_OBJ_PROGRESS_010)
			end
		end
	)
	ScenarioInfo.M1_obj20:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U02_M1_obj20_KILL_GSHIPS, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.U02_P1_DESTROY_GUNSHIP_OBJ_COMPLETE_010, P1_EndPartCounter)
			end
		end
	)
end

function P1_ResearchObjective_VO()
	ScenarioFramework.Dialogue(OpDialog.U02_RESEARCH_UNLOCK, P1_AssignResearch)
end

function P1_AssignResearch()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.U02_S1_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Primary Objective S1_obj10 - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective U02_S1_obj20_NAME - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.U02_S1_obj10_NAME,			-- title
		descText,								-- description
		{
			ShowProgress = true,
			AiBrain = ArmyBrains[ARMY_PLAYER],
			ResearchList = ScenarioInfo.ResearchData.ObjectiveUnlock,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)
	LOG('----- P2: research objectives result callbacks')
	--confirmation VO when complete.
	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioFramework.Dialogue(OpDialog.U02_RESEARCH_FOLLOWUP_GUNSHIP_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (P2_ResearchReminder1, 300)

	-- give some bonus points to the player
	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U02_ZZ_EXTRA_JUMPSTART_RESEARCH, ARMY_PLAYER, 3.0)
end

function P2_ResearchReminder1()
	if ScenarioInfo.S1_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.U02_RESEARCH_REMINDER_010)
	end
end

function P1_AttackPlayerOffmap_CreateAttack()
	if ScenarioInfo.P1_AttacksAllowed then

		----------------
		-- Calculate Value
		----------------

		-- check (and weight) counts of player units that can attack aircraft. We toss in a touch of gunships just so
		-- we can keep the attacks growing a bit as the player bulks up their army.
		local aaTowers 		= P1_Player_AATowerWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0102)
		local aaAddon 		= P1_Player_aaAddonWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uum0121)
		local fighters	 	= P1_Player_FightersWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0101)
		local gunships		= P1_Player_GunshipWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0103)

		-- create raw player value
		local PlayerStrength = aaTowers + aaAddon + fighters + gunships
		LOG('----- P1: PlayerStrength is ' .. PlayerStrength)

		----------------
		-- Create Attack
		----------------

		-- if player strength is above a minimum, then we will put together an attack
		if PlayerStrength >= P1_OffmapPlayer_Min then
			LOG('----- P1: Creating attack against player.')
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')

			-- add the minimum attack to the platoon. The first two are always bombers, the rest gunships.
			for i = 1, P1_OffmapPlayer_MinSize do
				if i <= 2 then
					local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_PlayerStream_FighterBomber')
					ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
				else
					local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_PlayerStream_Gunship')
					ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
				end
			end

				-- add extra units to the attack, if the player is doing ok.
			if PlayerStrength >= P1_OffmapPlayer_MinExtra then

				-- spawn an extra unit for the attack, for every PlayerMod points worth of PlayerStrength.
				local count = math.floor(PlayerStrength / P1_OffmapPlayer_PlayerMod)
				if count > 0 then
					LOG('----- P1: Adding extra unit to player attack: ' .. count)
					-- tinfoil hat: enforce a generous max.
					if count > 30 then count = 30 end
					for i = 1, count do
						-- make half of the extra units be gunships.
						local rnd = Random(1, 2)
						if rnd == 2 then
							local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_PlayerStream_Gunship')
							ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
						else
							local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_PlayerStream_FighterBomber')
							ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
						end
					end
				end
			end

			-- Send the platoon to one of two routes, and create a death trigger for it that will
			-- recall this function (after a delay)
			local route = Random (1, 2)
			if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
				ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Attack_MainAirAttack_0' .. route)
				ScenarioFramework.CreatePlatoonDeathTrigger(
							function()
								local delay = Random(P1_OffmapPlayer_DelayMin, P1_OffmapPlayer_DelayMax)
								ScenarioFramework.CreateTimerTrigger(P1_AttackPlayerOffmap_CreateAttack, delay)
							end,
							platoon
				)
			end

		-- Otherwise, check back soon to see if the player can handle another attack yet.
		else
			ScenarioFramework.CreateTimerTrigger (P1_AttackPlayerOffmap_CreateAttack, 10)
		end
	end
end

function P1_AttackAllyOffmap01_CreateAttack()
	if ScenarioInfo.P1_AttacksAllowed then
		-- Creat an attack, and give the platoon a death trigger to recreat the attack once dead.
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandStream_01', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_StreamAlly_Attack_Chain01')
		ScenarioFramework.CreatePlatoonDeathTrigger(P1_AttackAllyOffmap01_CreateAttack, platoon)
	end
end

function P1_AttackAllyOffmap02_CreateAttack()
	if ScenarioInfo.P1_AttacksAllowed then
		-- Creat an attack, and give the platoon a death trigger to recreat the attack once dead.
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_LandStream_02', 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_StreamAlly_Attack_Chain02')
		ScenarioFramework.CreatePlatoonDeathTrigger(P1_AttackAllyOffmap02_CreateAttack, platoon)
	end
end

function P1_AllyFormCallback(platoon)
	LOG('----- P1: Ally platoon FORM CALLBACK')
	-- Add a death trigger for the platoon, which will trigger VO.
	ScenarioFramework.CreatePlatoonDeathTrigger (P1_AllyPlatoonDeathCallback, platoon)


	-- Ally will play some VO asking for help when an attack platoon of his has been made.
	-- If the gunship patrol is still alive, he will ask for help with that in particular.
	-- Otherwise, he will ask for more general help.

	-- The second and third platoons formed (if the enemy gunships are still around) ask for specific gunship help.
	if not ScenarioInfo.M1_obj20.Complete then
		if not ScenarioInfo.P1_AllyVO_Blocked then
			Gunship_AllyPlatoonVOCount = Gunship_AllyPlatoonVOCount + 1
			LOG('----- P1: Ally platoon FORM CALLBACK: gunships still present. Callback ', Gunship_AllyPlatoonVOCount)
			if Gunship_AllyPlatoonVOCount == 4 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_ALLY_AID_GUNSHIP_010)
				P1_AllyVOBlock()
			elseif Gunship_AllyPlatoonVOCount == 16 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_ALLY_AID_GUNSHIP_020)
				P1_AllyVOBlock()
			end
		else
			LOG('----- P1: P1_AllyFormCallback: Ally VO is blocked, skipping VO.')
		end

	-- otherwise, on the first and second callbacks when the gunships arent around, ask for general help.
	else
		if not ScenarioInfo.P1_AllyVO_Blocked then
			AllyPlatoonVOCount = AllyPlatoonVOCount + 1
			LOG('----- P1: Ally platoon FORM CALLBACK: gunships dead, Callback ', AllyPlatoonVOCount)
			if AllyPlatoonVOCount == 2 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_ALLY_AID_010)
				P1_AllyVOBlock()
			elseif AllyPlatoonVOCount == 5 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_ALLY_AID_020)
				P1_AllyVOBlock()
			end
		else
			LOG('----- P1: P1_AllyFormCallback: Ally VO is blocked, skipping VO.')
		end
	end

	-- in case an ally unit actually makes it past the enemy to offmap, give each a distance trigger that will
	-- kill the unit offmap at a certain point.
	for k, v in platoon:GetPlatoonUnits() do
		if v and not v:IsDead() then
			ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P1_KillAllyUnit, v, 'P1_ALLY_Delete_Check_Location', 50)
		end
	end

	-- add the platoon to a table, which we will use during the transition nis to swap-and-move ahead of the main base swap.
	table.insert(ScenarioInfo.P1_AllyPlatoonTable, platoon)
end

function P1_AllyAISetup()
	-----------------
	-- Base Manager
	-----------------

	local levelTable_P1_ALLY01_MainBase = { P1_ALLY01_Main_Base_100 = 100,}
	ScenarioInfo.ArmyBase_P1_ALLY01_MainBase = ArmyBrains[ARMY_ALLY01].CampaignAISystem:AddBaseManager('P1_ALLY01_Main_Base', 'P1_ALLY01_Main_Base_Marker', 70, levelTable_P1_ALLY01_MainBase)
	ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:StartNonZeroBase(3)
	ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:SetBaseInfiniteRebuild()	-- ally keeps rebuilding.
	ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:AddEngineer(ScenarioInfo.ALLY01_CDR)
	local eng = ScenarioUtils.CreateArmyGroup('ARMY_ALLY01', 'P1_ALLY01_Main_Init_Eng')
	for k, v in eng do
		if v and not v:IsDead() then
			ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:AddEngineer(v)
		end
	end

	-- Set a folder of units in the ally base to protected (folder is within P2_ALLY01_Main_Base_100).
	local tblData = ScenarioUtils.FindUnitGroup( 'P1_ALLY01_Main_Base_PROTECTED', Scenario.Armies['ARMY_ALLY01'].Units )
	for k, v in tblData.Units do
		local unit = ScenarioInfo.UnitNames[ARMY_ALLY01][k] -- .Units is 'name' = {stuff} , so we use the key here to get the name string.
		ProtectUnit(unit)
	end

	-- Of these protected units, get handles to the 3 ally factories, for the P2 NIS when we hand them to the player.
	ScenarioInfo.P1_ALLY_Factory_01 = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_Ally_Factory_01']
	ScenarioInfo.P1_ALLY_Factory_02 = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_Ally_Factory_02']
	ScenarioInfo.P1_ALLY_Factory_03 = ScenarioInfo.UnitNames[ARMY_ALLY01]['P1_Ally_Factory_03']

	-- build shield add-ons for each of the factories
	IssueBuildFactory( {ScenarioInfo.P1_ALLY_Factory_01}, 'uum0211', 1 )
	IssueBuildFactory( {ScenarioInfo.P1_ALLY_Factory_02}, 'uum0211', 1 )
	IssueBuildFactory( {ScenarioInfo.P1_ALLY_Factory_03}, 'uum0211', 1 )

	-- set the rest of the ally's structure to not be reclaimable (capturing is already disallowed for ally, globally).
	local allyStructures = ArmyBrains[ARMY_ALLY01]:GetListOfUnits(categories.STRUCTURE, false )
	for k, v in allyStructures do
		if v and not v:IsDead() then
			v:SetReclaimable(false)
		end
	end

	-- Create a table to hold all the following platoons that are built over time. Create this table before the OpAI.
	ScenarioInfo.P1_AllyPlatoonTable = {}


	-----------------
	-- OpAIs
	-----------------

	-- Land Attack 01
	local LandAttackEnem01 = {
		'UEF_LandAttack01_Platoon',
		{
			{ 'uul0101', 6 },
		},
	}
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI 			= ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:GenerateOpAIFromPlatoonTemplate(LandAttackEnem01, 'P1_ALLY01_Base_LandAttack_01_OpAI', {} )
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P1_ALLY01_LandAttack_01', 'P1_ALLY01_LandAttack_02',},}
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI:			EnableChildTypes( {'UEFTanks'} )
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI_Data )

	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI:			SetTargetArmyIndex(ARMY_ENEM01)
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI:			AddActivePlatoon(ScenarioInfo.P1_ALLY01_Main_InitLandAttack01, true)
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI.			FormCallback:Add(P1_AllyFormCallback)
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI:			SetChildCount(1)
	ScenarioInfo.P1_ALLY01_Base_LandAttack_01_OpAI:			SetMaxActivePlatoons(2)
end

function P1_EndPartCounter()
	LOG('JIRA TRACKING:--------------- P1_EndPartCounter: counter[', ScenarioInfo.P1_EndPartCounter, ']')
	ScenarioInfo.P1_EndPartCounter = ScenarioInfo.P1_EndPartCounter + 1
	if ScenarioInfo.P1_EndPartCounter == 2 then
		ScenarioInfo.P1_AttacksAllowed = false
		P2_Setup()
	elseif ScenarioInfo.P1_EndPartCounter > 2 then
		WARN('WARNING: somehow P1_EndPartCounter has been called too many times - this is indicative of a significant script issue - pass to Campaign Design.')
	end
end

---------------------------------------------------------------------
-- PART 2:
---------------------------------------------------------------------
function P2_Setup()
	LOG('----- P2_Setup: Setting up needed units and visual activity for.')
	ScenarioInfo.PartNumber = 2

	-- destroy our path-blocking hoo-ha
	DestroyGroup(ScenarioInfo.O_GRID_BLOCKERS)

	-- enable builders
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0001, true)		-- Enable construction of the UEF land factory

	-- enable non-research bound structures
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uub0101, true)		-- Enable PD tower

	-- enable non-research bound mobile units
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0101, true)		-- Enable tank
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0104, true)		-- Enable m-truck
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uul0105, true)		-- Enable aa-truck

	-- enable selected addons
	ScenarioFramework.RemoveRestriction(ARMY_PLAYER, categories.uum0111, true)		-- Enable PD add-ons

	-------- Set up Enemy --------

	-- Enemy Intel
	ScenarioFramework.CreateIntelAtLocation(275, 'P2_ENEMY_Radar', ARMY_ENEM01, 'Radar')

	-- Main base starting patrols
	local land1 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Main_Init_Land_01', 'AttackFormation')
	local land2 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Main_Init_Land_02', 'AttackFormation')
	local air = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Main_Init_Air_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(land1, 'P2_ENEM01_Main_Defense_Land_Patrol_01')
	ScenarioFramework.PlatoonPatrolChain(land2, 'P2_ENEM01_Main_Defense_Land_Patrol_02')
	for k, v in air:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_Main_Defense_Air_Patrol_01'))
	end

	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Econ_Init_Land_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_Econ_Defense_Land_Patrol_01')

	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Econ_Init_Air_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_ENEM01_Econ_Defense_Air_Patrol_01')

	-- attack in progress, to hand to an OpAI after the NIS
	ScenarioInfo.P2_ENEM01_Main_InitLandAttack01 = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P2_ENEM01_Main_InitAttack_Land01', 'AttackFormation')

	-- Create Enemy Econ Area, and get a list of extractors for secondary obj
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_Econ_Area')
	ScenarioInfo.SecondaryEconUnits = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.ucb0701, false)

	-- Set up wreckage and tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P2_WRECKAGE', true)
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_TechCache')

	--# Set up the main base Base Manager
	P2_SetupEnemyAI()


	-- Generate a counterattack platoon to use after the NIS. In the mean time, have it use the base patrol.
	-- (note that we could get nil from the counterattack, if the player is doing poorly).
	ScenarioInfo.P2_AirCounterAttackPlatoon = P2_CreateCounterattackPlatoon()
	if ScenarioInfo.P2_AirCounterAttackPlatoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_AirCounterAttackPlatoon) then
		for k, v in ScenarioInfo.P2_AirCounterAttackPlatoon:GetPlatoonUnits() do
			if v and not v:IsDead() then
				ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_Main_Defense_Air_Patrol_01'))
			end
		end
	end


	ForkThread(P2_Transition)
end

function P2_Transition()
	--NOTE: due to the giving of units, at this point in the operation we force the unit cap higher to make room for the new units - bfricks 1/15/10
	SetArmyUnitCap(ARMY_PLAYER, 250)
	OpNIS.NIS_REVEAL_ENEMY()
	P2_Main()
end

function P2_Main()
	----------------------------------------------
	-- Primary Objective M2_obj10 - Destroy Enemy Factories
	----------------------------------------------
	LOG('----- P3: Assign Primary Objective M2_obj10 - Destroy Enemy Factories.')
	ScenarioInfo.M2_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.U02_M2_obj10_NAME,			-- objective name
		OpStrings.U02_M2_obj10_DESC,			-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = ScenarioInfo.P2_PrimaryObjectiveFactories,
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)
	-- Progress VO as they player attacks the defensive line, and when nearly complete,
	-- the Ally will go into holding pattern patrol to indicate readiness.
	ScenarioInfo.M2_obj10:AddProgressCallback(
		function(current, total)
			-- These values reflect the current placeholder units that depict the defensive line obj units
			if current == 1 then
				--play an encouragement VO
				ScenarioFramework.Dialogue(OpDialog.U02_P2_DESTROY_FACTORIES_OBJ_PROGRESS_010)
			elseif current == 3 then
				ScenarioFramework.Dialogue(OpDialog.U02_P2_DESTROY_FACTORIES_OBJ_PROGRESS_020)
			end
		end
	)
	ScenarioInfo.M2_obj10:AddResultCallback(
		function(result)
			if result then
				-- disable the enemy base manager so things behave cleanly during NIS.
				ScenarioInfo.ArmyBase_ENEM01_MainBase:BaseActive(false)
				ForkThread(OpNIS.NIS_VICTORY)
			end
		end
	)

	-- Hidden objective trigger
	ScenarioFramework.CreateAreaTrigger(P2_HiddenObj1Complete, 'P2_HiddenObj_Mass_Trigger_Area',
		 categories.uub0701 + categories.ucb0701, true, false, ArmyBrains[ARMY_PLAYER], 2)

	-- Delay assigning the Secondary Objective, to leave time for the Part 2
	-- opener to sink in.
	ScenarioFramework.CreateTimerTrigger (P2_AssignSecondaryVO, 15)

	-- Send our counterattack platoon (that most likely exists) on its looping attacks.
	P2_CounterattackFindTarget()

	-- Send an initial land attack in to the player's new land base (platoon created before the NIS).
	if ScenarioInfo.P2_ENEM01_Main_InitLandAttack01 and ArmyBrains[ARMY_ENEM01]:PlatoonExists(ScenarioInfo.P2_ENEM01_Main_InitLandAttack01) then
		ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI:AddActivePlatoon(ScenarioInfo.P2_ENEM01_Main_InitLandAttack01, true)
	end

	-- Disable the ally base manager.
	ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:BaseActive(false)
end

function P2_AssignSecondary()
	----------------------------------------------
	-- Secondary Objective S2_obj10 - Destroy Enemy Economic Units
	----------------------------------------------
	LOG('----- P3: Assign Secondary Objective S2_obj10 - Destroy Enemy Economic Units.')
	local desc = OpStrings.U02_S2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U02_S2_obj10_KILL_ECONOMY)
	ScenarioInfo.S2_obj10 = SimObjectives.KillOrCapture(
		'secondary',							-- type
		'incomplete',							-- status
		OpStrings.U02_S2_obj10_NAME,			-- objective name
		desc,									-- description
		{
			MarkUnits = true,
			FlashVisible = true,
			Units = ScenarioInfo.SecondaryEconUnits,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj10)

	-- add progress update for dialog
	ScenarioInfo.S2_obj10:AddProgressCallback(
		function(current, total)
			if current == 1 then
				ScenarioFramework.Dialogue(OpDialog.U02_P2_DESTROY_MASS_OBJ_PROGRESS_010)
			elseif current == 2 then
				ScenarioFramework.Dialogue(OpDialog.U02_P2_DESTROY_MASS_OBJ_PROGRESS_020)
			end
		end
	)

	-- add result callback for special enemy economy kill
	ScenarioInfo.S2_obj10:AddResultCallback(
		function(result)
			if result then
				-- If the primary objective isn't yet completed, play the completion
				-- VO, and fork the thread that will tank the enemy economy.
				if(ScenarioInfo.M2_obj10.Active) then
					ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U02_S2_obj10_KILL_ECONOMY, ARMY_PLAYER, 3.0)
					ScenarioFramework.Dialogue(OpDialog.U02_P2_DESTROY_MASS_OBJ_COMPLETE, P2_TransportAttack)
					ForkThread(P2_KillEconomyThread)
				end
			end
		end
	)
end

function P2_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 -Economic Opportunist
	----------------------------------------------
	LOG('----- P2: Complete Hidden Objective H1_obj10 -Economic Opportunist')
	local descText = OpStrings.U02_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.U02_H1_obj10_MAKE_NWMASS)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.U02_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('build'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.U02_H1_obj10_MAKE_NWMASS, ARMY_PLAYER, 3.0)
end

function P2_SetupEnemyAI()
	-------- Create Enemy Main Base --------


	-----------------
	-- Base Manager
	-----------------

	local levelTable_ENEM01_MainBase = {
		P2_ENEM01_Main_Base = 100,
	}

	ScenarioInfo.ArmyBase_ENEM01_MainBase = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P2_ENEM01_Main_Base',
		'P2_ENEM01_Main_Base_Marker', 70, levelTable_ENEM01_MainBase)
	ScenarioInfo.ArmyBase_ENEM01_MainBase:StartNonZeroBase(1)
	ScenarioInfo.ArmyBase_ENEM01_MainBase:SetBuildAllStructures(false)	-- rebuild off, since this is a very early op.

	-- Starting engineers
	local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P2_ENEM01_Main_Init_Eng')
	for k, v in eng do
		ScenarioInfo.ArmyBase_ENEM01_MainBase:AddEngineer(v)
	end

	-- Objective factories
	ScenarioInfo.P2_PrimaryObjectiveFactories = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.ucb0001 + categories.ucb0002, false)

	-- Get air factories able to build quickly.
	local airFactoriess = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.ucb0002,false)
	for k, v in airFactoriess do
		if v and not v:IsDead() then
			ScenarioFramework.SetUnitVeterancyLevel(v, 5)
		end
	end

	local landFactoriess = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.ucb0001,false)
	for k, v in landFactoriess do
		if v and not v:IsDead() then
			ScenarioFramework.SetUnitVeterancyLevel(v, 2)
		end
	end


	-----------------
	-- OpAIs
	-----------------

	--# Basic air attack against player
	local AirAttackPlayer01 = {
		'Cybran_AirAttack01_Platoon',
		{
			{ 'uca0103', 1 },
			{ 'uca0104', 1 },
		},
	}
	ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI			= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(AirAttackPlayer01, 'ENEM01_Main_AirAttack_West_OpAI', {} )
	ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_West_AirAttack_01',},}
	ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI_Data )
	ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI:			SetChildCount(4)
	ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI:			SetMaxActivePlatoons(3)


	--# Basic land attack against ally
	local LandAttackAlly01 = {
		'Cybran_LandAttack01_Platoon',
		{
			{ 'ucl0103', 3 },
		},
	}
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI			= ScenarioInfo.ArmyBase_ENEM01_MainBase:GenerateOpAIFromPlatoonTemplate(LandAttackAlly01, 'ENEM01_Main_LandAttack_South_OpAI', {} )
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI_Data		= {AnnounceRoute = true, PatrolChains = { 'P2_ENEM01_South_LandAttack_02',},}
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI_Data )
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI:			EnableChildTypes( {'CybranAssaultBots', 'CybranComboDefense'} )
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI:			SetTargetArmyIndex(ARMY_ALLY01)
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI:			SetChildCount(2)
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI:			SetMaxActivePlatoons(8)
end

function P2_KillEconomyThread()
	-- Turn off the enemy OpAI's and repeatedly tank
	-- the enemy economy. No more attacks.

	ScenarioInfo.ENEM01_Main_AirAttack_West_OpAI:Disable()
	ScenarioInfo.ENEM01_Main_LandAttack_South_OpAI:Disable()

	while not ScenarioInfo.OpEnded do
		ArmyBrains[ARMY_ENEM01]:GiveResource('MASS', -5000)
		ArmyBrains[ARMY_ENEM01]:GiveResource('ENERGY', -5000)
		WaitSeconds(5)
	end
end


---------------------------------------------------------------------
-- PART2 OPENING COUNTERATTACK:
---------------------------------------------------------------------

function P2_CreateCounterattackPlatoon()
	LOG('----- P2: Generating counterattack platoon:')
	-- check counts of player units that can attack ground.
	local bombers 		= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0102)
	local gunships 		= ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uua0103)

	local unitCount = bombers + gunships

	-- For evey n units, create 1 attacking unit. Clamp the value if its too high.
	local attackSize = math.floor(unitCount / P2_Counterattack_PlayerMod)
	if attackSize > 27 then attackSize = 27 end
	LOG('----- P2: Generating counterattack platoon: unit count is ' .. unitCount .. ', attack size is ' .. attackSize )

	-- create the platoon, but, for the NIS, spread the units out a bit when they are spawned.
	if attackSize >= 1 then
		local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
		for i = 1, attackSize do
			local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_Counterattack_FighterBomber')
			local pos = unit:GetPosition()

			ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			Warp( unit, {pos[1] + Random(-25,25), pos[2], pos[3] + Random(-25,25)} )
		end

		-- return a handle to the newly created platoon
		return platoon
	else
		return nil
	end
end

function P2_CounterattackFindTarget()
	-- Work through the players gunships and bombers, using a cutom made platoon. We do this instead of a general patrol
	-- so we dont overwhelm the player (the platoon is made of fighter bombers), and instead just target what we care about
	-- (gunships and bombers).
	-- NOTE: this function assumes the enemy has intel: FindClosestUnit only returns targets in an intel area.
	if ScenarioInfo.P2_AirCounterAttackPlatoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists( ScenarioInfo.P2_AirCounterAttackPlatoon ) then
		LOG('----- P2: Counterattack sequence:')
		local target = ScenarioInfo.P2_AirCounterAttackPlatoon:FindClosestUnit('attack', 'Enemy', false, categories.uua0102 + categories.uua0103)

		-- attack nearest target and give the target a death trigger to call this function again.
		if target and not target:IsDead() then
			LOG('----- P2: Counterattack: targetting a unit')
			for k, v in ScenarioInfo.P2_AirCounterAttackPlatoon:GetPlatoonUnits() do
				if v and not v:IsDead() then
					IssueClearCommands({v})
				end
			end
			ScenarioInfo.P2_AirCounterAttackPlatoon:AttackTarget(target)
			-- after the death of the target, give some time for the platoon to do some damage before we find another target
			ScenarioFramework.CreateUnitDeathTrigger( P2_CounterattackLoopDelay, target )

		-- if the target is dead, however, then check again for another target very soon
		elseif target and target:IsDead() then
			LOG('----- P2: Counterattack: target is dead, trying another')
			ScenarioFramework.CreateTimerTrigger (P2_CounterattackFindTarget, 1)

		-- but if we get no target, double check a few more times, then send the platoon on a patrol somewhere.
		else
			LOG('----- P2: Counterattack: target is invalid.')
			P2_CounterattackNilCounter = P2_CounterattackNilCounter + 1
			if P2_CounterattackNilCounter == 4 then
				LOG('----- P2: Counterattack: 4th time target is invalid, going on patrol instead.')
				-- after 4 re-checks, it looks like we are finally out of targets, so the counterattack is over. Send the platoon
				-- on a normal patrol, to wrap things up.
				for k, v in ScenarioInfo.P2_AirCounterAttackPlatoon:GetPlatoonUnits() do
					if v and not v:IsDead() then
						IssueClearCommands({v})
						ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute('P2_ENEM01_Main_Defense_Air_Patrol_01'))
					end
				end
				return
			end

			-- check again shortly (after the potential return above).
			ScenarioFramework.CreateTimerTrigger (P2_CounterattackFindTarget, 1)
		end
	end
end

function P2_CounterattackLoopDelay()
	LOG('----- P2: Counterattack: counterattack target killed.')
	ScenarioFramework.CreateTimerTrigger(P2_CounterattackFindTarget, 6)
end


---------------------------------------------------------------------
-- PART2 TRANSPORT ATTACK:
---------------------------------------------------------------------

function P2_TransportAttack()
	LOG('----- P2: Spawn transport attack.')

	-- Create transports, make them not die
	ScenarioInfo.P2_TransAttack_Trans01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_TransAttack_Trans01')
	ScenarioInfo.P2_TransAttack_Trans02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_TransAttack_Trans02')
	ScenarioInfo.P2_TransAttack_Trans03 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P2_ENEM01_TransAttack_Trans03')
	ScenarioInfo.P2_TransAttack_Trans01:SetCanBeKilled(false)
	ScenarioInfo.P2_TransAttack_Trans02:SetCanBeKilled(false)
	ScenarioInfo.P2_TransAttack_Trans03:SetCanBeKilled(false)

	-- A distance trigger that fires when the middle transport gets over the enemy main base. This results in
	-- the warning VO, calling out the attack.
	ScenarioFramework.CreateUnitToMarkerDistanceTrigger(
		P2_TransAttackWarning_VO,
		ScenarioInfo.P2_TransAttack_Trans02,
		'P2_ENEM01_TransAttack_VO_Warning_Marker',
		50
	)

	local data01 = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= 'P2_ENEM01_TransAttack_LandGroup_01',	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.P2_TransAttack_Trans01,	-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'P2_ENEM01_TransAttack_Landing01',	-- destination for the transport drop-off
		returnDest				= 'P2_ENEM01_TransAttack_Return01',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= P2_TransAttackLanding_Callback1,		-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data01)

	local data02 = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= 'P2_ENEM01_TransAttack_LandGroup_01',	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.P2_TransAttack_Trans02,	-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'P2_ENEM01_TransAttack_Landing02',	-- destination for the transport drop-off
		returnDest				= 'P2_ENEM01_TransAttack_Return02',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= P2_TransAttackLanding_Callback2,		-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data02)

	local data03 = {
		armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
		units					= 'P2_ENEM01_TransAttack_LandGroup_01',	-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= ScenarioInfo.P2_TransAttack_Trans03,	-- unit handle for the actual transport
		approachChain			= nil,									-- optional chainName for the approach travel route
		unloadDest				= 'P2_ENEM01_TransAttack_Landing03',	-- destination for the transport drop-off
		returnDest				= 'P2_ENEM01_TransAttack_Return03',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,								-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,									-- optional destination for the group to be moved to after being dropped-off
		OnCreateCallback		= nil,									-- optional function to call when the transport finishes unloading
		onUnloadCallback		= P2_TransAttackLanding_Callback3,		-- optional function to call when the transport finishes unloading
	}
	TransportUtils.SpawnTransportDeployGroup(data03)
end

function P2_TransAttackWarning_VO()
	-- trigger the music system with this event
	import('/lua/sim/ScenarioFramework/ScenarioGameMusic.lua').PlayMusicEventByHandle('U02_GEN_Enemy_Transports')

	-- Warn of transport attack
	ScenarioFramework.Dialogue(OpDialog.U02_TRANSPORT_ATTACK_010)
end

function P2_TransAttackLanding_Callback1(platoon)
	LOG('----- P2: Transport1 landing callback.')

	-- Send the attackers to the player's land base, and set the transports to be killable now.
	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_TransAttack_AttackRoute_01')
	end
	if ScenarioInfo.P2_TransAttack_Trans01 and not ScenarioInfo.P2_TransAttack_Trans01:IsDead() then
		ScenarioInfo.P2_TransAttack_Trans01:SetCanBeKilled(true)
	end
end

function P2_TransAttackLanding_Callback2(platoon)
	LOG('----- P2: Transport2 landing callback.')

	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_TransAttack_AttackRoute_02')
	end
	if ScenarioInfo.P2_TransAttack_Trans02 and not ScenarioInfo.P2_TransAttack_Trans02:IsDead() then
		ScenarioInfo.P2_TransAttack_Trans02:SetCanBeKilled(true)
	end
end
function P2_TransAttackLanding_Callback3(platoon)
	LOG('----- P2: Transport3 landing callback.')

	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P2_TransAttack_AttackRoute_03')
	end
	if ScenarioInfo.P2_TransAttack_Trans03 and not ScenarioInfo.P2_TransAttack_Trans03:IsDead() then
		ScenarioInfo.P2_TransAttack_Trans03:SetCanBeKilled(true)
	end
end

---------------------------------------------------------------------
-- DIALOGUE RELATED FUNCTIONS:
---------------------------------------------------------------------
 function AdviseVO_GeneralAdvice2()
	ScenarioFramework.Dialogue(OpDialog.U02_P1_BUILD_ADVICE_020)
 end

 function AdviseVO_BuildMassExtractor()
	-- if the player has less than 2 mass extractors, encourage them to build more.
	local num = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0701)
	if num <= 2 then
		ScenarioFramework.Dialogue(OpDialog.U02_BUILD_ADVICE_MASS_010)
	end
 end

 function AdviseVO_FactoryAA()
	-- if the player has less than 1 AA factory addons, encourage them to build more.
	local num = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uum0121)
	if num <= 1 then
		ScenarioFramework.Dialogue(OpDialog.U02_BUILD_ADVICE_FACTORYAA_010)
	end
 end

function AdviseVO_Engineers()
	-- if the player has no engineers, encourage them to build some.
	-- Although this is called by a death trigger on the initial engineers, still
	-- perform the check, as the player may have built additional engeers already.
	local num = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uul0002)
	if num == 0 then
		ScenarioFramework.Dialogue(OpDialog.U02_BUILD_ADVICE_ENGINEER_010)
	end
end

function AdviseVO_AntiAirTowers()
	-- if the player has few AA towers, encourage them to build some.
	local num = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0102)
	if num <= 2 then
		ScenarioFramework.Dialogue(OpDialog.U02_BUILD_ADVICE_AATOWER_010)
	end
end

function AdviseVO_Factory()
	-- if the player only has one air factory, advise them to build more.
	local num = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uub0002)
	if num <= 1 then
		ScenarioFramework.Dialogue(OpDialog.U02_BUILD_ADVICE_FACTORY_010)
	end
end

function P1_AllyPlatoonDeathCallback()
	LOG('----- P3: Ally platoon died')

	-- Play VO from ally or ops when an ally platoon dies, encouraging the player to aid the ally.

	if ScenarioInfo.PartNumber == 1 then
		if not ScenarioInfo.P1_AllyVO_Blocked then
			AllyPlatoonDeathCount = AllyPlatoonDeathCount + 1
			if AllyPlatoonDeathCount == 5 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_ALLY_INITATTACK_DESTROYED_010)
				P1_AllyVOBlock()
			elseif AllyPlatoonDeathCount == 9 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_ALLY_PLATOON_DESTROYED_010)
				P1_AllyVOBlock()
			elseif AllyPlatoonDeathCount == 14 then
				ScenarioFramework.Dialogue(OpDialog.U02_P1_ALLY_PLATOON_DESTROYED_020)
				P1_AllyVOBlock()
			end
		else
			LOG('----- P1: P1_AllyPlatoonDeathCallback VO: ally VO is currently blocked.')
		end
	end
end

function P2_AssignSecondaryVO()
	ScenarioFramework.Dialogue(OpDialog.U02_P2_DESTROY_MASS_OBJ_ASSIGN, P2_AssignSecondary)
end

function P1_AllyVOBlock()
	LOG('----- P1: Blocking ally VO for a short while.')
	ScenarioInfo.P1_AllyVO_Blocked = true
	ScenarioFramework.CreateTimerTrigger (P1_AllyVOAllow, 120)
end

function P1_AllyVOAllow()
	LOG('----- P1: Ally VO is now allowed.')
	ScenarioInfo.P1_AllyVO_Blocked = false
end

---------------------------------------------------------------------
-- UTILITY FUNCTIONS:
---------------------------------------------------------------------

function P1_KillAllyUnit(unit)
	LOG('----- P1: Killing Ally unit that made it out of playable area.')
	if ScenarioInfo.PartNumber == 1 then
		if unit and not unit:IsDead() then
			ForceUnitDeath(unit)
		end
	end
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	P2_Setup()
end

function OnShiftF4()
	ForkThread(OpNIS.NIS_VICTORY)
end


