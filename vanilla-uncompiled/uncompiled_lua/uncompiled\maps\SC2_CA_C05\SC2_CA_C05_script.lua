---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_C05/SC2_CA_C05_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_C05/SC2_CA_C05_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_C05/SC2_CA_C05_OpNIS.lua')
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
local CarrierUtils			= import('/lua/sim/ScenarioFramework/ScenarioGameUtilsCarrier.lua')

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

local DestroAttackersKilled	= 0
---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------

-- Unit-type weighting values, for event checks.
local P1_Player_ShieldWeight 		= 6
local P1_Player_PointDefWeight 		= 2
local P1_Player_ExperimentalWeight 	= 38
local P1_Player_MobLandWeight 		= 1
local P1_Player_GunshipWeight 		= 2
local P1_Player_BomberWeight 		= 3
local P1_Player_Naval1Weight		= 8
local P1_Player_Naval2Weight		= 10

---------------------------------------------------------------------
-- SYSTEM OUTLINE:
---------------------------------------------------------------------
-- an enemy base with OpAIs plus a custom destroyer and carrier sequence for the early part of the operation

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.C05_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.C05_ARMY_ENEM01)

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
		funcNIS			= OpNIS.NIS_OPENING, 	-- if valid, the non-critical NIS sequence to be launched
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

	ScenarioInfo.P1_PlayerInitEng = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Init_Eng')
	local air = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_PLAYER', 'P1_PLAYER_Init_Air_01', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(air, 'INTRO_PlayerStartingAir_PatrolChain')
	ScenarioInfo.P1_PlayerInitLand = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Init_Land_01')

	--# Set up enemy units
	P1_AISetup_ENEM01()
	-- Enable land walk for enemy naval, and the land move speed bonus.
	ArmyBrains[ARMY_ENEM01]:CompleteResearch( {'CSP_LANDWALKING'} )

	ScenarioInfo.ENEM01_CDR = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_CDR')
	ScenarioInfo.ENEM01_CDR:SetCustomName(ScenarioGameNames.CDR_Stockwell)
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.ENEM01_CDR, 4)

	---NOTE: because it can look bad, enemy CDRs do not reclaim - bfricks 12/8/09
	ScenarioInfo.ENEM01_CDR:RemoveCommandCap('RULEUCC_Reclaim')

	-- CDR death damage triggers
	ScenarioFramework.CreateUnitDeathTrigger(ENEM01_CDR_DeathDamage, ScenarioInfo.ENEM01_CDR)

	-- Give enemy intel on map
	ScenarioFramework.CreateIntelAtLocation(400, 'P1_ENEM01_IntelLocation', ARMY_ENEM01, 'Radar')

	-- setup the starting carriers and destroyers
	P1_CarrierSetup()
	P1_DestroyerSetup()

	-- one-off naval patrols around enemy base area
	for i = 1, 2 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_EMEM01_NavalDef_0' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_NavalDef_Chain_0' .. i)
	end

	-- Create tech caches
	ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_TechCache')

end

function P1_Main()
	LOG('----- P1_Main:')

	P1_AssignObjectives()

	-- Hidden objective.
	ScenarioFramework.CreateArmyStatTrigger (P1_HiddenObj1Complete, ArmyBrains[ARMY_PLAYER], 'HiddenObj_BuildKraken',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ucx0113}})

	--Get the enemy commander on patrol.
	IssueClearCommands({ScenarioInfo.ENEM01_CDR})
	ScenarioFramework.GroupPatrolChain( {ScenarioInfo.ENEM01_CDR}, 'P1_ENEM01_EnemCDR_Patrol' )

	-- timer to assign research secondary objective, if for some reason the early attacking destroyers
	-- dont get killed.
	---NOTE: make sure this time is never BEFORE the destroyer NIS - bfricks 9/30/09
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_VO, 300)

	-- Start a thread that will track how the player is doing, and trigger events based
	-- of that at different points.
	ForkThread(P1_EventThread)

	-- Failsafe event timers, if player does not build up quickly enough to trigger the
	-- events otherwise.
	ScenarioFramework.CreateTimerTrigger (P1_BeginCarrierAttack, 480)
	ScenarioFramework.CreateTimerTrigger (P1_EnableAirAttacks, 490)

	-- After a brief delay, send in the Destroyer attack (this can be triggerd by player proximity as well)
	ScenarioFramework.CreateTimerTrigger (P1_EarlyDestroyerAttack, 65)

	-- When player completes mass fab research, enable a mass fab targetting surgical
	ScenarioFramework.CreateOnResearchTrigger( P1_EnableMassFabSurgical, ArmyBrains[ARMY_PLAYER], 'CBA_MASSCONVERSION', 'complete' )

	------------------------------
	-- VO TRIGGERS:
	------------------------------

	-- VO: on spotting a krakken
	ScenarioFramework.CreateArmyIntelTrigger(function() ScenarioFramework.Dialogue(OpDialog.C05_KRAKKEN_WARNING) end,
	 ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true, categories.ucx0113, true, ArmyBrains[ARMY_ENEM01])

	-- VO: on spotting a willfindja
	ScenarioFramework.CreateArmyIntelTrigger(function() ScenarioFramework.Dialogue(OpDialog.C05_WILLFIND_WARNING) end,
	 ArmyBrains[ARMY_PLAYER], 'LOSNow', false, true, categories.uix0102, true, ArmyBrains[ARMY_ENEM01])

	-- VO: when player kills a krakken
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C05_KRAKKEN_KILLED) end,
			ArmyBrains[ARMY_ENEM01], 'PlayerKilledKraken',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ucx0113}})
	-- VO: when player kills a willfindja
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C05_WILLFIND_DESTROYED) end,
			ArmyBrains[ARMY_ENEM01], 'PlayerKilledWillfind',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uix0102}})

	-- VO: banter when player loses engineer
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C05_ILL_BANTER_010) end,
			ArmyBrains[ARMY_PLAYER], 'P1_PlayerLostEngineer',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ENGINEER}})

	-- VO: banter when player loses a numer of naval units
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C05_ILL_BANTER_020) end,
			ArmyBrains[ARMY_PLAYER], 'P1_PlayerLostNaval',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 7, Category = categories.NAVAL}})

	-- VO: banter when player loses a factory
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C05_ILL_BANTER_030) end,
			ArmyBrains[ARMY_PLAYER], 'P1_PlayerLostFactory',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY}})

	-- VO: debate when player has six mass extractors (hopefully a calm moment)
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C05_BANTER_DEBATE_010) end,
			ArmyBrains[ARMY_PLAYER], 'P1_PlayerBuiltMass',
			{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 6, Category = categories.ucb0701}})

	-- VO: debate when player kills an experimental
	ScenarioFramework.CreateArmyStatTrigger (function() ScenarioFramework.Dialogue(OpDialog.C05_BANTER_DEBATE_020) end,
			ArmyBrains[ARMY_ENEM01], 'P1_EnemLostExperimental',
			{{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.EXPERIMENTAL}})
end

function P1_CarrierSetup()
	-- Carriers, for objectives
	ScenarioInfo.P1_ENEM01_Carrier_01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Carrier_01')
	ScenarioInfo.P1_ENEM01_Carrier_02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Carrier_02')
	ScenarioInfo.P1_ENEM01_Carrier_03 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Carrier_03')

	CarrierUtils.SetupCYBAircraftCarrier(
		{
			carrierUnit			= ScenarioInfo.P1_ENEM01_Carrier_01,	-- unit to be used as the parent carrier
			nMaxGunshipCount	= 2,									-- number of gunships to maintain
			nMaxFighterCount	= 9,									-- number of fighter-bombers to maintain
			nSpawnDelay			= 7.5,									-- time between each spawn
			strArmyName			= 'ARMY_ENEM01',						-- name of the army for the carrier and its children
			nThreatRadius		= 80.0,									-- radius about the carrier to be considered the threat range
			onDeathPatrolChain	= 'P1_PlayerBaseArea_Attack_Chain',		-- optional patrol when a carrier dies, otherwise, all children scatter-patrol
			CarrierPatrol		= 'P1_ENEM01_Carrier01_Chain',			-- optional patrol for the carrier to follow, works in unison with building and unloading
		}
	)

	CarrierUtils.SetupCYBAircraftCarrier(
		{
			carrierUnit			= ScenarioInfo.P1_ENEM01_Carrier_02,	-- unit to be used as the parent carrier
			nMaxGunshipCount	= 3,									-- number of gunships to maintain
			nMaxFighterCount	= 12,									-- number of fighter-bombers to maintain
			nSpawnDelay			= 5.0,									-- time between each spawn
			strArmyName			= 'ARMY_ENEM01',						-- name of the army for the carrier and its children
			nThreatRadius		= 80.0,									-- radius about the carrier to be considered the threat range
			onDeathPatrolChain	= 'P1_PlayerBaseArea_Attack_Chain',		-- optional patrol when a carrier dies, otherwise, all children scatter-patrol
			CarrierPatrol		= 'P1_ENEM01_Carrier02_Chain',			-- optional patrol for the carrier to follow, works in unison with building and unloading
		}
	)

	CarrierUtils.SetupCYBAircraftCarrier(
		{
			carrierUnit			= ScenarioInfo.P1_ENEM01_Carrier_03,	-- unit to be used as the parent carrier
			nMaxGunshipCount	= 3,									-- number of gunships to maintain
			nMaxFighterCount	= 12,									-- number of fighter-bombers to maintain
			nSpawnDelay			= 5.0,									-- time between each spawn
			strArmyName			= 'ARMY_ENEM01',						-- name of the army for the carrier and its children
			nThreatRadius		= 80.0,									-- radius about the carrier to be considered the threat range
			onDeathPatrolChain	= 'P1_PlayerBaseArea_Attack_Chain',		-- optional patrol when a carrier dies, otherwise, all children scatter-patrol
			CarrierPatrol		= 'P1_ENEM01_Carrier03_Chain',			-- optional patrol for the carrier to follow, works in unison with building and unloading
		}
	)
end

function P1_DestroyerSetup()

	--# Set up the early destroyer attack that is sent at the player:
	-- Create destroyers that will be sent at the player soon after start of Op.
	-- Give them a death trigger for VO, etc.
	ScenarioInfo.P1_EnemDestroyer01 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Destroyer_01')
	ScenarioInfo.P1_EnemDestroyer02 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Destroyer_02')
	ScenarioInfo.P1_EnemDestroyer03 = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Destroyer_03')

	-- When both of these destroyers are killed, try to assign the research objective. (failsafe timer will try as well)
	ScenarioFramework.CreateUnitDestroyedTrigger(P1_AttackingDestroyerKilled, ScenarioInfo.P1_EnemDestroyer01)
	ScenarioFramework.CreateUnitDestroyedTrigger(P1_AttackingDestroyerKilled, ScenarioInfo.P1_EnemDestroyer02)
	ScenarioFramework.CreateUnitDestroyedTrigger(P1_AttackingDestroyerKilled, ScenarioInfo.P1_EnemDestroyer03)

	-- When a player gets near any of the destroyers, fire off the event (a safegaurd, if the player goes exploring).
	ScenarioFramework.CreateUnitNearTypeTrigger (P1_EarlyDestroyerAttack, ScenarioInfo.P1_EnemDestroyer01, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 36)
	ScenarioFramework.CreateUnitNearTypeTrigger (P1_EarlyDestroyerAttack, ScenarioInfo.P1_EnemDestroyer02, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 36)
	ScenarioFramework.CreateUnitNearTypeTrigger (P1_EarlyDestroyerAttack, ScenarioInfo.P1_EnemDestroyer03, ArmyBrains[ARMY_PLAYER], categories.ALLUNITS, 36)

	-- Further, if any of the units take damage (long range unit attacking the destros, for example, outside
	-- the range in the UnitNearTypeTrigger above), also begin the attack sequence.
	ScenarioFramework.CreateUnitDamagedTrigger(P1_EarlyDestroyerAttack, ScenarioInfo.P1_EnemDestroyer01, -1, nil, true)
	ScenarioFramework.CreateUnitDamagedTrigger(P1_EarlyDestroyerAttack, ScenarioInfo.P1_EnemDestroyer02, -1, nil, true)
	ScenarioFramework.CreateUnitDamagedTrigger(P1_EarlyDestroyerAttack, ScenarioInfo.P1_EnemDestroyer03, -1, nil, true)
end

function P1_EventThread()
	LOG('----- P1: Enabling event check thread.')
	local carrierEventCalled = false
	local airEventCalled = false
	local legsEventCalled = false
	local navalEventCalled = false

	while not carrierEventCalled or not airEventCalled or not legsEventCalled do
		while ScenarioInfo.OpNISActive do WaitSeconds(1.0) end

		local shield 		= P1_Player_ShieldWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0202)
		local pointDef 		= P1_Player_PointDefWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0101)
		local experimental 	= P1_Player_ExperimentalWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL)
		local mobileLand 	= P1_Player_MobLandWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.MOBILE * categories.LAND)
		local gunship 		= P1_Player_GunshipWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uca0103)
		local bomber 		= P1_Player_BomberWeight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.uca0104)
		local navalNormal	= P1_Player_Naval1Weight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucs0103 + categories.ucs0901)
		local navalStrong	= P1_Player_Naval2Weight * ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucs0105)

		-- create raw player value
		local rawPlayerValue = shield + pointDef + experimental + mobileLand + gunship + bomber + navalNormal + navalStrong
		local playerValue = rawPlayerValue - 25 -- allow some free starting units
		if playerValue < 0 then playerValue = 0 end
		LOG('----- P1: Event Thread: playerValue is ' .. playerValue)


		-- NAVAL: Enables, platoon count increases and resets
		if not navalEventCalled then
			if playerValue >= 20 then
				P1_EnableNavalAttacks()
				navalEventCalled = true
			end
		end

		if playerValue >= 49 then
			IncreaseNavalPlatoonCountTo_2()
		end
		if playerValue >= 69 then
			IncreaseNavalPlatoonCountTo_3()
		end

		if playerValue < 45 and ScenarioInfo.IncreaseNavalPlatoonCountTo2 == true then
			LOG('----- NAVAL: Decreasing Naval max platoons to 1.')
			ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:SetMaxActivePlatoons(1)
			ScenarioInfo.IncreaseNavalPlatoonCountTo2 = false
		end
		if playerValue < 65 and ScenarioInfo.IncreaseNavalPlatoonCountTo3 == true then
			LOG('----- NAVAL: Decreasing Naval max platoons to 2.')
			ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:SetMaxActivePlatoons(2)
			ScenarioInfo.IncreaseNavalPlatoonCountTo3 = false
		end


		-- Enable Air Attack opais when player hits threshold
		if not airEventCalled then
			if playerValue >= 26 then
				P1_EnableAirAttacks()
				airEventCalled = true
			end
		end

		-- begin the Carrier attack event when the player hits a threshold
		if not carrierEventCalled then
			if playerValue >= 34 then
				P1_BeginCarrierAttack()
				carrierEventCalled = true
			end
		end

		if not ScenarioInfo.KrakenAttacksEnabled then
			if playerValue >= 75 then
				P1_EnableKrakenAttacks()
			end
		end

		if carrierEventCalled and airEventCalled and legsEventCalled then
			LOG('----- P1: Event Thread: all events begun, shutting down thread shortly.')
		end

		LOG('-----------------------------------------------')
		WaitSeconds(5)
	end
end

function P1_EarlyDestroyerAttack()
	-- proximity or damage trigger for any unit in the destroyer attack will call this, so run once.
	if not ScenarioInfo.P1_StartedDestroAttack then
		ScenarioInfo.P1_StartedDestroAttack = true
		if (ScenarioInfo.P1_EnemDestroyer01 and not ScenarioInfo.P1_EnemDestroyer01:IsDead()) or (ScenarioInfo.P1_EnemDestroyer02 and not ScenarioInfo.P1_EnemDestroyer02:IsDead()) or (ScenarioInfo.P1_EnemDestroyer03 and not ScenarioInfo.P1_EnemDestroyer03:IsDead()) then
			LOG('----- P1: Launching the destroyer Attack.')
			-- play the Destroyer NIS, and right after it, have some intel persist for a brief span, so
			-- player is clear where things are taking place.
			ForkThread(
				function()
					OpNIS.NIS_DESTROYER_REVEAL()

					-- after the NIS, give the destroyers their expected gameplay movement orders
					ScenarioFramework.GroupPatrolRoute({ScenarioInfo.P1_EnemDestroyer01}, ScenarioUtils.ChainToPositions('P1_ENEM01_DestroyerAttack_Chain02'))
					ScenarioFramework.GroupPatrolRoute({ScenarioInfo.P1_EnemDestroyer02}, ScenarioUtils.ChainToPositions('P1_ENEM01_DestroyerAttack_Chain02'))
					ScenarioFramework.GroupPatrolRoute({ScenarioInfo.P1_EnemDestroyer03}, ScenarioUtils.ChainToPositions('P1_ENEM01_DestroyerAttack_Chain02'))
					ScenarioFramework.CreateIntelAtLocation(30, 'P1_EnemyDestroyerAttack_IntelLocation', ARMY_PLAYER, 'Radar', 15)

					-- turn on the light air attack opai.
					ScenarioInfo.P1_ENEM01_LightAir_01_OpAI:Enable()
				end
			)
		end
	end
end

function P1_EnableNavalAttacks()
	if not ScenarioInfo.NavalAttackStarted then
		LOG('----- P1: Beginning naval attacks.')
		ScenarioInfo.NavalAttackStarted = true
		ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:Enable()
	end
end

function IncreaseNavalPlatoonCountTo_2()
	if not ScenarioInfo.IncreaseNavalPlatoonCountTo2 then
		ScenarioInfo.IncreaseNavalPlatoonCountTo2 = true
		LOG('----- NAVAL: increasing max platoons to 2' )
		ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:SetMaxActivePlatoons(2)
	end
end

function IncreaseNavalPlatoonCountTo_3()
	if not ScenarioInfo.IncreaseNavalPlatoonCountTo3 then
		ScenarioInfo.IncreaseNavalPlatoonCountTo3 = true
		LOG('----- NAVAL: increasing max platoons to 3' )
		ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:SetMaxActivePlatoons(3)
	end
end

function P1_BeginCarrierAttack()
	if not ScenarioInfo.CarrierMoved then
		LOG('----- P1: Beginning carrier attack.')
		ScenarioInfo.CarrierMoved = true

		-- send the patrolling carrier in to the player base area.
		if ScenarioInfo.P1_ENEM01_Carrier_01 and not ScenarioInfo.P1_ENEM01_Carrier_01:IsDead() then
			CarrierUtils.UpdateCarrierPatrol(ScenarioInfo.P1_ENEM01_Carrier_01, 'P1_ENEM01_EarlyCarrierAttack_Chain')
		end
	end
end

function P1_EnableAirAttacks()
	-- turn main air attack OpAI on, turn off the light
	-- air attack.
	if not ScenarioInfo.AirAttacksEnabled then
		LOG('----- P1: Enabling Air Attacks.')
		ScenarioInfo.AirAttacksEnabled = true
		ScenarioInfo.P1_ENEM_AirAttack_01_OpAI:Enable()
		-- we leave the light attack opai enabled, as it has slightly lower priority, so will be superceded.
	end
end

function P1_EnableKrakenAttacks()
	if not ScenarioInfo.KrakenAttacksEnabled then
		LOG('----- P1: Enabling kraken attacks.')
		ScenarioInfo.KrakenAttacksEnabled = true
		ScenarioInfo.P1_ENEM01_Kraken01_OpAI:Enable()
	end
end


---------------------------------------------------------------------
-- OBJECTIVE RELATED FUNCTIONS:
---------------------------------------------------------------------

function P1_AssignObjectives()

	----------------------------------------------
	-- Primary Objective M2_obj10 - Destroy the Enemy CDR
	----------------------------------------------
	LOG('----- P2_Main: Assign Primary Objective M2_obj10 - Destroy the Enemy CDR.')
	ScenarioInfo.M1_obj10 = SimObjectives.KillOrCapture(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.C05_M1_obj10_NAME,			-- title
		OpStrings.C05_M1_obj10_DESC,			-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.ENEM01_CDR},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)


	----------------------------------------------
	-- Secondary Objective 1 - Destroy Carriers
	----------------------------------------------
	LOG('-----  P1_Main: Assign  Secondary Objective 1 - Destroy Carriers')
	local descText = OpStrings.C05_S1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C05_S1_obj10_KILL_CARRIERS)
	ScenarioInfo.S1_obj10 = SimObjectives.KillOrCapture(
		'secondary',						-- type
		'incomplete',						-- status
		OpStrings.C05_S1_obj10_NAME,		-- title
		descText,							-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.P1_ENEM01_Carrier_01, ScenarioInfo.P1_ENEM01_Carrier_02, ScenarioInfo.P1_ENEM01_Carrier_03},
		}
	)
	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S1_obj10)
	ScenarioInfo.S1_obj10:AddResultCallback(
		function(result)
			if result then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C05_S1_obj10_KILL_CARRIERS, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.C05_S1_obj10_COMPLETE)
			end
		end
	)

	-- setup each possible ending unit for a controlled death sequence
	ScenarioGameEvents.SetupUnitForControlledDeath(ScenarioInfo.ENEM01_CDR, LaunchVictoryNIS)
end

function P1_AttackingDestroyerKilled()
	-- When both destroyers in the early attack are killed, we will try
	-- to assign the reseach objective (prefered method). A failsafe timer
	-- will also be operating as well.
	DestroAttackersKilled = DestroAttackersKilled + 1
	if DestroAttackersKilled == 3 then
		ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C05_ZZ_EXTRA_KILL_DESTROYERS, ARMY_PLAYER, 3.0)
		ScenarioFramework.Dialogue(OpDialog.C05_DESTROYER_KILLED, P1_ResearchSecondary_VO )
	end
end

function P1_ResearchSecondary_VO()
	if not ScenarioInfo.P1_ResearchAssigned then
		LOG('----- P1: Research secondary VO.')
		ScenarioInfo.P1_ResearchAssigned = true
		ScenarioFramework.Dialogue(OpDialog.C05_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
	end
end


function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.C05_S2_obj10_DESC .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary - Research Technology
	----------------------------------------------
	LOG('-----  P1_Main: Assign  Secondary Objective 3 - Research Technology')
	ScenarioInfo.S2_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.C05_S2_obj10_NAME,	-- title
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
				ScenarioFramework.Dialogue(OpDialog.C05_RESEARCH_FOLLOWUP_LANDWALKING_010)
			end
		end
	)

	-- Delayed VO to remind the player to complete the research.
	ScenarioFramework.CreateTimerTrigger (ResearchReminder1, 600)
end

function ResearchReminder1()
	if ScenarioInfo.S2_obj10.Active then
		LOG('----- Research reminder.')
		ScenarioFramework.Dialogue(OpDialog.C05_RESEARCH_REMINDER_010)
	end
end

function P1_HiddenObj1Complete()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Master of the Deep
	----------------------------------------------
	LOG('----- P1: Complete Hidden Objective H1_obj10 - Master of the Deep')
	local descText = OpStrings.C05_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C05_H1_obj10_MAKE_KRAKKEN)
	ScenarioInfo.H1_obj10 = SimObjectives.Basic(
		'secondary',							-- type
		'complete',								-- status
		OpStrings.C05_H1_obj10_NAME,			-- title
		descText,								-- description
		SimObjectives.GetActionIcon('capture'),	-- Action
		{
		}
	)
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

	ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C05_H1_obj10_MAKE_KRAKKEN, ARMY_PLAYER, 3.0)
end

function P1_CarrierWarning_VO()
	ScenarioFramework.Dialogue(OpDialog.C05_CARRIER_WARNING)
end


function P1_NavalLandWarning_VO()
	-- If the enemy base is still present, warn that naval is now using legs
	if ScenarioInfo.S1_obj10.Active then
		ScenarioFramework.Dialogue(OpDialog.C05_S2_obj10_COMPLETE)
	end
end

function P1_NavalWarning_VO()
	LOG('---- P1: naval unit is near player, playing VO.')
	-- set flag so we no longer create distance triggers, play the VO.
	ScenarioInfo.P1_EnemyNavalWarningPlayed = true
	ScenarioFramework.Dialogue(OpDialog.C05_DESTROYER_WARNING)
end


---------------------------------------------------------------------
-- BASE MANAGER AND OPAI RELATED FUNCTIONS:
---------------------------------------------------------------------

function P1_AISetup_ENEM01()
	LOG('----- P1: Setting up enemy Base and OpAIs')

	----------------------
	-- Base Manager Setup
	----------------------

	-- Set up Enemy base
	local levelTable_ENEM01 = { P1_ENEM01_Main_Base_100 = 100,
								P1_ENEM01_Main_Base_90 = 90,}
	ScenarioInfo.ArmyBase_P1_ENEM01 = ArmyBrains[ARMY_ENEM01].CampaignAISystem:AddBaseManager('P1_ENEM01_Main_Base', 'P1_ENEM01_Main_Base_Marker', 50, levelTable_ENEM01)
	ScenarioInfo.ArmyBase_P1_ENEM01:StartNonZeroBase(4)

	-- initial engineers for it
	local eng = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'P1_ENEM01_Main_InitEng')
	for k, v in eng do
		ScenarioInfo.ArmyBase_P1_ENEM01:AddEngineer(v)
	end

	-- AA and shield addons for the factories.
	local factories = ArmyBrains[ARMY_ENEM01]:GetListOfUnits(categories.ucb0003 - categories.ucb0002, false )
	for k, factory in factories do
		if factory and not factory:IsDead() then
			-- aa and shield addon for all
			ArmyBrains[ARMY_ENEM01]:BuildUnit( factory, 'ucm0121', 1 )
			ArmyBrains[ARMY_ENEM01]:BuildUnit( factory, 'ucm0211', 1 )
        	-- torpedo for naval
        	if EntityCategoryContains( categories.ucb0003, factory ) then
        	    ArmyBrains[ARMY_ENEM01]:BuildUnit( factory, 'ucm0131', 1 )
        	end
		end
	end


	----------------------
	-- OpAI Setup
	----------------------

	-- Basic air defense OpAI
	ScenarioInfo.P1_ENEM_AirDefense_01_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('AirFightersCybran', 'P1_ENEM_AirDefense_01_OpAI', {} )
	local P1_ENEM_AirDefense_01_OpAI_Data			= { PatrolChain = 'P1_ENEM01_Main_AirDefense_Chain',}
	ScenarioInfo.P1_ENEM_AirDefense_01_OpAI:		SetPlatoonThread( 'PatrolRandomizedPoints', P1_ENEM_AirDefense_01_OpAI_Data )
	ScenarioInfo.P1_ENEM_AirDefense_01_OpAI:		SetChildCount(4)
	ScenarioInfo.P1_ENEM_AirDefense_01_OpAI:		SetMaxActivePlatoons(4)


	-- Naval Attack OpAI
	ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('NavalAttackCybran', 'P1_ENEM_NavalAttack_01_OpAI', {} )
	ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI_Data	= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_NavalAttack_Chain_01', 'P1_ENEM01_NavalAttack_Chain_02', 'P1_ENEM01_NavalAttack_Chain_03', },}
	ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI_Data)
	ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI.		FormCallback:Add(P1_NavalFormCallback)
	ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:		SetAttackDelay(47)
	ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM_NavalAttack_01_OpAI:		Disable()


	-- Light Air, early
	local Cybran_LightAir01 = {
		'Cybran_LightAir01',
		{
			{ 'uca0104', 2 },
		},
	}
	ScenarioInfo.P1_ENEM01_LightAir_01_OpAI 		= ScenarioInfo.ArmyBase_P1_ENEM01:GenerateOpAIFromPlatoonTemplate(Cybran_LightAir01, 'P1_ENEM01_LightAir_01_OpAI', {} )
	local P1_ENEM01_LightAir_01_OpAI_Data			= {AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_Chain_03',},}
	ScenarioInfo.P1_ENEM01_LightAir_01_OpAI:		SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_LightAir_01_OpAI_Data )
	ScenarioInfo.P1_ENEM01_LightAir_01_OpAI:		AdjustPriority(-1) -- so the main air attack will supercede, when the time comes.
	ScenarioInfo.P1_ENEM01_LightAir_01_OpAI:		SetAttackDelay(18)
	ScenarioInfo.P1_ENEM01_LightAir_01_OpAI:		SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ENEM01_LightAir_01_OpAI:		Disable()


	-- Air Attack OpAI
	ScenarioInfo.P1_ENEM_AirAttack_01_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('AirAttackCybran', 'P1_ENEM_AirAttack_01_OpAI', {} )
	ScenarioInfo.P1_ENEM_AirAttack_01_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_ENEM01_AirAttack_Chain_01', 'P1_ENEM01_AirAttack_Chain_02', 'P1_ENEM01_AirAttack_Chain_03', },}
	ScenarioInfo.P1_ENEM_AirAttack_01_OpAI:			SetPlatoonThread( 'PatrolRandomRoute', ScenarioInfo.P1_ENEM_AirAttack_01_OpAI_Data)
	ScenarioInfo.P1_ENEM_AirAttack_01_OpAI:			SetAttackDelay(24)
	ScenarioInfo.P1_ENEM_AirAttack_01_OpAI:			SetMaxActivePlatoons(3)
	ScenarioInfo.P1_ENEM_AirAttack_01_OpAI:			Disable()


	-- Kraken OpAI (unit is built by an engineer)
	local Cybran_Engineer01 = {
		'Cybran_Engineer1',
		{
			{ 'ucl0002', 1 }, --{ 'ucl0002', 1 },
		},
	}
	ScenarioInfo.P1_ENEM01_Kraken01_OpAI 		= ScenarioInfo.ArmyBase_P1_ENEM01:GenerateOpAIFromPlatoonTemplate(Cybran_Engineer01, 'P1_ENEM01_Kraken01_OpAI', {} )
	ScenarioInfo.P1_ENEM01_Kraken01_OpAI:		SetMaxActivePlatoons(1)
	ScenarioInfo.P1_ENEM01_Kraken01_OpAI:		AdjustPriority(1) -- This is the biggest attack, and only needs one engineer to get it going, so crank the priority. minute for minute, its worth it.
	ScenarioInfo.P1_ENEM01_Kraken01_OpAI.		FormCallback:Add(P1_KrakenEngineerCallback)
	ScenarioInfo.P1_ENEM01_Kraken01_OpAI:		Disable()


	--## Surgical OpAIs --##

	-- Too many land units of some types
	ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI	= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('AirResponsePatrolLand', 'P1_ENEM01_PlayerExcessLand_OpAI', {} )
	local P1_ENEM01_PlayerExcessLand_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_PlayerBaseArea_Attack_Chain', },}
	ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI:	SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_PlayerExcessLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerExcessLand_OpAI:	SetChildCount(3)


	-- Too many air units
	ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI		= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('AirResponsePatrolAir', 'P1_ENEM01_PlayerExcessAir_OpAI', {} )
	local P1_ENEM01_PlayerExcessAir_OpAI_Data		= { AnnounceRoute = true, PatrolChains = { 'P1_PlayerBaseArea_Attack_Chain', },}
	ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI:	SetPlatoonThread( 'PatrolRandomRoute', P1_ENEM01_PlayerExcessAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerExcessAir_OpAI:	SetChildCount(3)


	-- Player builds powerful individual land units
	ScenarioInfo.P1_ENEM01_PlayerPowerfulLand_OpAI	= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('AirResponseTargetLand', 'P1_ENEM01_PlayerPowerfulLand_OpAI', {} )
	local P1_ENEM01_PlayerPowerfulLand_OpAI_Data	= {
    												    PatrolChain = 'P1_PlayerBaseArea_Attack_Chain',
    												    CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_SurgicalResponse_Check_Location' ),
    												    CategoryList = {
    												        (categories.EXPERIMENTAL * categories.LAND * categories.MOBILE),
    												        categories.uub0105,	-- artillery
    												        categories.ucb0105,	-- artillery
    												        categories.NUKE,
    												    },
    												}
	ScenarioInfo.P1_ENEM01_PlayerPowerfulLand_OpAI:	SetPlatoonThread( 'CategoryHunter', P1_ENEM01_PlayerPowerfulLand_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerPowerfulLand_OpAI:	SetChildCount(3)


	-- Player builds air experimentals
	ScenarioInfo.P1_ENEM01_PlayerPowerfulAir_OpAI	= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('AirResponseTargetAir', 'P1_ENEM01_PlayerPowerfulAir_OpAI', {} )
	local P1_ENEM01_PlayerPowerfulAir_OpAI_Data		= {
    													PatrolChain = 'P1_PlayerBaseArea_Attack_Chain',
    													CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_SurgicalResponse_Check_Location' ),
    													CategoryList = {
    													    categories.EXPERIMENTAL * categories.AIR * categories.MOBILE,
    													},
    												}
	ScenarioInfo.P1_ENEM01_PlayerPowerfulAir_OpAI:	SetPlatoonThread( 'CategoryHunter', P1_ENEM01_PlayerPowerfulAir_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerPowerfulAir_OpAI:	SetChildCount(3)


	-- Player builds mass fabs
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI			= ScenarioInfo.ArmyBase_P1_ENEM01:AddOpAI('AirResponseTargetCybPower', 'P1_ENEM01_PlayerMassFab_OpAI', {} )
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI_Data		= {
    												    	PatrolChain = 'P1_ENEM01_AirAttack_Chain_02',
    												    	Announce = true,
    												    	-- check point is far the NW of the player base. We want to focus on mass fabs outside
    												    	-- the player base, not inside it, so this location is to try best catch distant mass
    												    	-- fabs (imperfect tho the results may be).
    												    	CenterPoint = ScenarioUtils.MarkerToPosition( 'P1_ENEM01_MassFabSurgical_Check' ),
    												    	CategoryList = {
    												    		categories.ucb0702,	-- power generator (upgrades to mass fab)
    														},
    													}
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetPlatoonThread( 'CategoryHunter', ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI_Data )
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetChildCount(4)
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetMaxActivePlatoons(1) -- more than 1 will blow out other attacks, as player will always have power.
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		SetAttackDelay(60) -- player will always have power gens, so we need to slow this opai down.
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:		Disable()

	----------------------
	-- Units for OpAIs, etc
	----------------------
	-- create initial air defenders, and hand them to their opai
	for i = 1, 4 do
		local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_Main_InitAir_Def_01', 'AttackFormation')
		ScenarioInfo.P1_ENEM_AirDefense_01_OpAI:AddActivePlatoon(platoon, true)
	end
end

function P1_NavalFormCallback(platoon)
	-- one time, add a distance trigger to a single unit from a passed in platoon, which will trigger some vo when the unit
	-- nears the player.
	if not ScenarioInfo.P1_EnemyNavalWarningPlayed then
		for k, v in platoon:GetPlatoonUnits() do
			if v and not v:IsDead() then
				ScenarioFramework.CreateUnitToMarkerDistanceTrigger( P1_NavalWarning_VO, v, 'P1_DestroyerVoDistance_Marker', 153)
				break
			end
		end
	end
end

function P1_KrakenEngineerCallback(engPlatoon)
    IssueClearCommands(engPlatoon:GetPlatoonUnits())
    local buildData = {
		experimentalID = 'P1_ENEM01_KrakenOpAI',			-- LED-give name of unit to build (location is used)
		experimentalBehavior = P1_KrakenBuiltCallback,		-- callback to run when the experimental is built.
		experimentalCategory = 'UCX0113',					-- which type of unit does this engineer track?
		patrolChain = 'P1_ENEM01_Main_Base_EngineerChain',	-- patrol chain for engineer to use while not building exps
        Announce = true,
	}

    local aiFunction = CAIPlatoonThreads['BuildExperimental'].Function
    engPlatoon:ForkAIThread(aiFunction, 'ARMY_ENEM01', buildData)
end

function P1_KrakenBuiltCallback(kraken)
	LOG('----Kraken callback', kraken)
	-- callback for freshly created kraken. Sent to attack platyer.
	ScenarioFramework.GroupPatrolChain( {kraken}, 'P1_ENEM01_NavalAttack_Chain_01' )
end

function P1_EnableMassFabSurgical()
	LOG('----- SURGICAL: Player completed mass fab upgrade research. Enabling Mass Fab surgical.')
	ScenarioInfo.P1_ENEM01_PlayerMassFab_OpAI:Enable()
end


---------------------------------------------------------------------
-- SUNDRY UTILITY FUNCTIONS:
---------------------------------------------------------------------

function RandomPatrolThread(platoon, chain)
	-- Give members of a platoon a random patrol using the points of a chain.
	if(platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon)) then
		for k, v in platoon:GetPlatoonUnits() do
			IssueClearCommands({v})
			ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(chain))
		end
	end
end


---------------------------------------------------------------------
-- CDR DEATH HANDLERS:
---------------------------------------------------------------------

function ENEM01_CDR_DeathDamage(CDRUnit)
	if CDRUnit then
		local endPos = {}
		local pos = CDRUnit:GetPosition()
		endPos = {pos[1], pos[2], pos[3]}

		local brainList = {
			ArmyBrains[ARMY_PLAYER],
			ArmyBrains[ARMY_ENEM01],
		}

		--function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		ScenarioGameEvents.DamageUnitsAroundPosition(endPos, 50.0, true, 5000, 90001, brainList)
	else
		WARN('WARNING: Somehow a CDR Death Handler was given an invalid unit reference - preventing custom death damage - pass to Campaign Design.')
	end
end

---------------------------------------------------------------------
-- VICTORY HANDLING:
---------------------------------------------------------------------
function LaunchVictoryNIS(unit)
	ScenarioInfo.ArmyBase_P1_ENEM01:BaseActive(false)
	ForkThread(OpNIS.NIS_VICTORY, unit)
end

---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	P1_EarlyDestroyerAttack()


	--CarrierUtils.CarrierUnload(ScenarioInfo.P1_ENEM01_Carrier_01)
end

function OnShiftF4()
	LaunchVictoryNIS(ScenarioInfo.ENEM01_CDR)

	--CarrierUtils.CarrierLoad(ScenarioInfo.P1_ENEM01_Carrier_01)
end


function OnShiftF5()
	CarrierUtils.UpdateCarrierPatrol(ScenarioInfo.P1_ENEM01_Carrier_01, 'P1_ENEM01_EarlyCarrierAttack_Chain')
end
