---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings				= import('/maps/SC2_CA_C01/SC2_CA_C01_OpStrings.lua')
local OpDialog				= import('/maps/SC2_CA_C01/SC2_CA_C01_OpDialog.lua')
local OpNIS					= import('/maps/SC2_CA_C01/SC2_CA_C01_OpNIS.lua')
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
ScenarioInfo.ARMY_CIVL01 = 3

ScenarioInfo.AssignedObjectives = {}

ScenarioInfo.AdaptiveResponse = true -- adaptive response flag

local Download_Progress_Counter = 0
local Veterancy_Counter = 0
---------------------------------------------------------------------
-- GENERAL SETTINGS/VARIABLES:
---------------------------------------------------------------------
local ARMY_PLAYER = ScenarioInfo.ARMY_PLAYER
local ARMY_ENEM01 = ScenarioInfo.ARMY_ENEM01
local ARMY_CIVL01 = ScenarioInfo.ARMY_CIVL01

---------------------------------------------------------------------
-- TUNING AND TIMING RELATED SETTINGS:
---------------------------------------------------------------------
local PLAYER_ProtoBrainHealth		= 10000		-- proto-brain health

local Primary_ProtoBrainTimerOBJ	= 1203		-- proto-brain protect objective timer
local Hidden_PostDefenseTimerOBJ	= 280		-- hidden objective defense timer which begins after the primary objective is complete

local PlayerOverwhelmedDelay		= 45		-- this will set the stream delay when the enemy is overwhleming the player

local TransportStream_MinimumDelay	= 7			-- this is the minimum delay timer between enemy transport streams
local TransportStreamDelay			= 20		-- enemy transport stream delay
local AirStreamDelay				= 35		-- enemy air stream delay during op and before the final objective is triggered
local AirStreamDelay_FinalStage		= 25		-- enemy air stream delay during the final stage of the OP

local PlayerLand_Response			= { Count = 40, Gunships = 8 }	-- enemy gunship platoon size that are created based on total units player has built
local PlayerExp_Response			= { Count = 1, Gunships = 10 }	-- enemy gunship platoon size that are created based on total experimentals player has built
local PlayerAir_Response			= { Count = 15, Fighters = 10 }	-- enemy fighter/bomber platoon size that are created based on total air units player has built
local PlayerDefense_Response		= { Count = 10, Gunships = 5 }	-- enemy gunship platoon size that are created base on the total defensive turrets player has built

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
	ScenarioGameSetup.SetupPlayerArmy(		ARMY_PLAYER,	ScenarioGameTuning.C01_PLAYER)
	ScenarioGameSetup.SetupNonPlayerArmy(	ARMY_ENEM01,	ScenarioGameTuning.C01_ARMY_ENEM01)
	ScenarioGameSetup.SetupGenericArmy(		ARMY_CIVL01,	ScenarioGameTuning.color_CYB_PLAYER)
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

	LOG('----- P1_Setup: Setup for the player CDR.')
	ScenarioInfo.INTRONIS_GroupCDR = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Commander_Group')
	ScenarioInfo.PLAYER_CDR = ScenarioInfo.UnitNames[ARMY_PLAYER]['PLAYER_CDR']
	ScenarioInfo.PLAYER_CDR:SetCustomName(ScenarioGameNames.CDR_Ivan)
	ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

	ScenarioInfo.INTRONIS_CommanderTransport = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'INTRONIS_CommanderTransport')

	-- Set up player units
	ScenarioInfo.P1_PLAYER_Starting_Base = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'P1_PLAYER_Starting_Base')

	-- Starting engineers and a patrol for them
	ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_Init_Eng_01')
	ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_Init_Eng_02')

	-- Player special units. Gate is critical, so cannot be allowed to be killed.
	ScenarioInfo.P1_PLAYER_Gate = ScenarioUtils.CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_Gate')
	ScenarioInfo.P1_PLAYER_Gate:SetCustomName(ScenarioGameNames.UNIT_SCB3101)
	ProtectUnit(ScenarioInfo.P1_PLAYER_Gate)

	-- Proto-Brain Complex
	ScenarioInfo.P1_PLAYER_Brain = ScenarioUtils.CreateArmyUnit('ARMY_CIVL01', 'P1_PLAYER_Exp_Brain')
	ScenarioInfo.P1_PLAYER_Brain:SetMaxHealth(PLAYER_ProtoBrainHealth)
	ScenarioInfo.P1_PLAYER_Brain:AdjustHealth(ScenarioInfo.P1_PLAYER_Brain, PLAYER_ProtoBrainHealth)
	ScenarioInfo.P1_PLAYER_Brain:SetCustomName(ScenarioGameNames.UNIT_C01_ProtoBrain)
	ScenarioInfo.P1_PLAYER_Brain:SetCapturable(false)
end

function P1_Main()
	LOG('----- P1_Main')
	-- --------------------------------------------
	-- Objective Related Triggers and Timers
	-- --------------------------------------------

	-- Assign the initial primary objective. Kept separate for neatness in this script.
	P1_AssignInitialPrimaryObjective()

	-- delayed assignment of a build secondary, so we dont get too much VO up front
	ScenarioFramework.CreateTimerTrigger (P1_BuildSecondary_Prep, 12)

	-- trigger to assign research secondary objectives
	ScenarioFramework.CreateTimerTrigger (P1_ResearchSecondary_Prep, 20)

	-- Timer trigger to advance the Op to the next Objective and complete the Defend
	-- objective.
	ScenarioFramework.CreateTimerTrigger (P1_Escape_Prep, Primary_ProtoBrainTimerOBJ)

	-- Timer trigger that launches post primary objective waves during the hidden objective duration
	ScenarioFramework.CreateTimerTrigger (Gunship_Wave, Primary_ProtoBrainTimerOBJ + 45)
	ScenarioFramework.CreateTimerTrigger (SoulRipper_Wave, Primary_ProtoBrainTimerOBJ + 90)
	ScenarioFramework.CreateTimerTrigger (Gunship_Wave, Primary_ProtoBrainTimerOBJ + 140)
	ScenarioFramework.CreateTimerTrigger (SoulRipper_Wave, Primary_ProtoBrainTimerOBJ + 210)

	-- Timer trigger that spawns a single soulripper to hunt down and destroy your ACU
	ScenarioFramework.CreateTimerTrigger (SoulRipper_Assassin, Primary_ProtoBrainTimerOBJ + 15)

	-- Timer triggers for all download progression VO to be played
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 60)
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 300)
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 600)
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 840)
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 1020)
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 1080)
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 1164)
	ScenarioFramework.CreateTimerTrigger (Progress_Download_VO, 1200)

	-- --------------------------------------------
	-- Streaming Attacks, Triggered Attacks, and Final Attacks
	-- --------------------------------------------

	-- This Op uses three general attacks: a stream of air attacks, a stream of
	-- transported land attacks, and instances of Experimental Transports bringing
	-- in large numbers of units (along routes different from the 'normal' land transport
	-- attacks).

	-- Set up some flags used by the stream
	ScenarioInfo.TransportStreamAllowed = true
	ScenarioInfo.StreamDifficulty = 1

	-- Carefully time 3 inital light transport attacks before the transport stream begins,
	-- due to the difficulty of the transport stream on start
	ScenarioFramework.CreateTimerTrigger (P1_EarlyTransportAttack, 15)
	ScenarioFramework.CreateTimerTrigger (P1_EarlyTransportAttack, 90)
	ScenarioFramework.CreateTimerTrigger (P1_EarlyTransportAttack, 120)
	ScenarioFramework.CreateTimerTrigger (P1_EarlyTransportAttack, 150)

	-- Begin the normal transport stream attacks after the light ones are finished,
	-- and set a timer that will increase the transport stream difficulty after a while.
	ScenarioFramework.CreateTimerTrigger (P1_TransportStreamThread, 210)
	ScenarioFramework.CreateTimerTrigger (P1_TransportStream_Difficulty, 420)
	ScenarioFramework.CreateTimerTrigger (P1_TransportStream_Difficulty, 840)

	-- Delay the air stream for a short while, so we ramp things up gradually.
	-- Create 3 timer triggers that will progressively increment a flag that effects
	-- the air stream difficulty, and that create a sizable air attack each for each
	-- time we increment.
	-- AirAttackDifficulty starts a 0 and is being used as a multiplier to increase the delay between streams and has to start at 0
	ScenarioInfo.AirAttackDifficulty = 0
	ScenarioFramework.CreateTimerTrigger (P1_EnableAirAttackStream, 120)
	ScenarioFramework.CreateTimerTrigger (P1_Air_AttackAndIncrement, 380)
	ScenarioFramework.CreateTimerTrigger (P1_Air_AttackAndIncrement, 700)
	ScenarioFramework.CreateTimerTrigger (P1_Air_AttackAndIncrement, 940)

	-- Have a beefy land attack roll in, via experimental transports. Time some
	-- VO to play when the transports pass over the player base area
	ScenarioFramework.CreateTimerTrigger (P1_ExperimentalTransportAttack, 600)
	ScenarioFramework.CreateTimerTrigger (P1_ExperimentalTransportAttack_VO, 612)

	-- This triggers the Final Attack that represents the break between the defend
	-- objective and the requirement to escape. The timing of this trigger needs
	-- to be maintained so the units land at just the right point, relative to the
	-- (currently) 20 minute timespan of the Defend objective.
	ScenarioFramework.CreateTimerTrigger (P1_FinalTransportAttack, 1180)

	-- Once we are in the Final stage, begin periodic strong land attacks, using
	-- the basic experimental land attack sequence (ie, normal attack, not the final
	-- attack sequence). This will keep the pressure very high for any player who
	-- tries their luck hanging out instead of escaping.
	-- This thread will also set a flag marking the beginning of the Final Stage,
	-- which other unit-generating threads will respond to.
	ScenarioFramework.CreateTimerTrigger (P1_FinalStage_ExpAttackThread, 1320)

	-- Create timer triggers for 2 lines of VO. Timer based works fine because this OP has a set duration and these will always play
	ScenarioFramework.CreateTimerTrigger (P1_Gauge_Banter_01, 70)
	ScenarioFramework.CreateTimerTrigger (P1_Gauge_Banter_02, 450)

	-- Create timer triggers that enable enemy buffs via research
	ScenarioFramework.CreateTimerTrigger (P1_EnableEnemyLandShields, Primary_ProtoBrainTimerOBJ * 0.5)
	ScenarioFramework.CreateTimerTrigger (P1_EnableEnemyAirDamage, Primary_ProtoBrainTimerOBJ * 0.8)

	-- Create timer triggers to apply veterancy to all enemy land units
	ScenarioFramework.CreateTimerTrigger (P1_EnemyVeterancy, Primary_ProtoBrainTimerOBJ * 0.4)
	ScenarioFramework.CreateTimerTrigger (P1_EnemyVeterancy, Primary_ProtoBrainTimerOBJ * 0.7)
	ScenarioFramework.CreateTimerTrigger (P1_EnemyVeterancy, Primary_ProtoBrainTimerOBJ * 0.9)
	ScenarioFramework.CreateTimerTrigger (P1_EnemyVeterancy, Primary_ProtoBrainTimerOBJ)

	-- Fork a thread that watches the Commander's location relative and that will spawn
	-- a gunship attack against the Commander, if too far afield.
	ScenarioInfo.TrackCommanderAllowed = true
	ForkThread(P1_TrackCommanderLocation)
	ForkThread(P1_AdaptiveResponseThread)
end

function P1_EnableEnemyLandShields()
	LOG('----- P1_EnableEnemyLandShields: Give enemy land shields')
	ArmyBrains[ARMY_ENEM01]:CompleteResearch( {'CLP_SHIELD'} )
end

function P1_EnableEnemyAirDamage()
	LOG('----- P1_EnableEnemyAirDamage: Give enemy air damage research buff')
	ArmyBrains[ARMY_ENEM01]:CompleteResearch( {'CAB_DAMAGE'} )
end

function Progress_Download_VO()
	LOG('----- Progress_Download_VO: Play VO')
	Download_Progress_Counter = Download_Progress_Counter + 1

	-- play download progression VO at 5%
	if Download_Progress_Counter == 1 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_PROGRESS_010)
	-- play download progression VO at 25%
	elseif Download_Progress_Counter == 2 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_PROGRESS_020)
	-- play download progression VO at 50%
	elseif Download_Progress_Counter == 3 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_PROGRESS_030)
	-- play download progression VO at 70%
	elseif Download_Progress_Counter == 4 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_PROGRESS_040)
	-- play download progression VO at 85%
	elseif Download_Progress_Counter == 5 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_PROGRESS_050)
	-- play download progression VO at 90%
	elseif Download_Progress_Counter == 6 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_PROGRESS_060)
	-- play download progression VO at 97%
	elseif Download_Progress_Counter == 7 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_PROGRESS_070)
	-- play download completion VO at 100%
	elseif Download_Progress_Counter == 8 then
		ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_COMPLETED_010)
	end
end

function P1_EnemyVeterancy()
	Veterancy_Counter = Veterancy_Counter + 1
end

---------------------------------------------------------------------
-- OBJECTIVES AND VO EVENTS
---------------------------------------------------------------------
function P1_AssignInitialPrimaryObjective()
	----------------------------------------------
	-- Primary Objective M1_obj10 - Defend the Brain
	----------------------------------------------
	LOG('----- P1: Assign Primary Objective M1_obj10 - Defend the Brain.')
	ScenarioInfo.M1_obj10 = SimObjectives.Protect(
		'primary',						-- type
		'incomplete',					-- status
		OpStrings.C01_M1_obj10_NAME,	-- title
		OpStrings.C01_M1_obj10_DESC,	-- description
		{
			MarkUnits = true,
			Units = {ScenarioInfo.P1_PLAYER_Brain},
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M1_obj10)

	local curPos = ScenarioInfo.P1_PLAYER_Brain:GetPosition()
	ScenarioInfo.FAIL_Position = {curPos[1], curPos[2], curPos[3]}

	ScenarioInfo.M1_obj10:AddResultCallback(
		function(result)
			if(result == false) and not ScenarioInfo.M2_obj10.Complete then
				-- pass in the data required to use the center pos for our fail NIS
				Defeat(true, ScenarioInfo.FAIL_Position, OpDialog.C01_DOWNLOAD_PROGRESS_INTERRUPTED_010)
			end
		end
	)
	-- play download start VO, and when completed start the download effect.
	ScenarioFramework.Dialogue(OpDialog.C01_DOWNLOAD_START_010, P1_BeginBrainEffects)
end

function P1_BeginBrainEffects()
	LOG('----- P1: Starting the proto-brain download effects.')
	-- Proto-Brain effects
	ScenarioInfo.P1_PLAYER_Brain.AmbientEffectsBag = {}
	table.insert( ScenarioInfo.P1_PLAYER_Brain.AmbientEffectsBag, CreateAttachedEmitter( ScenarioInfo.P1_PLAYER_Brain, -2, ScenarioInfo.P1_PLAYER_Brain:GetArmy(), '/effects/emitters/units/scenario/protobrain/ambient/protobrain_amb_01_symbol_emit.bp' ) )
	table.insert( ScenarioInfo.P1_PLAYER_Brain.AmbientEffectsBag, CreateAttachedEmitter( ScenarioInfo.P1_PLAYER_Brain, -2, ScenarioInfo.P1_PLAYER_Brain:GetArmy(), '/effects/emitters/units/scenario/protobrain/ambient/protobrain_amb_02_lines_emit.bp' ) )
	table.insert( ScenarioInfo.P1_PLAYER_Brain.AmbientEffectsBag, CreateAttachedEmitter( ScenarioInfo.P1_PLAYER_Brain, -2, ScenarioInfo.P1_PLAYER_Brain:GetArmy(), '/effects/emitters/units/scenario/protobrain/ambient/protobrain_amb_03_glow_emit.bp' ) )
	table.insert( ScenarioInfo.P1_PLAYER_Brain.AmbientEffectsBag, CreateAttachedEmitter( ScenarioInfo.P1_PLAYER_Brain, -2, ScenarioInfo.P1_PLAYER_Brain:GetArmy(), '/effects/emitters/units/scenario/protobrain/ambient/protobrain_amb_04_flatring_emit.bp' ) )

end

function P1_BuildSecondary_Prep()
	ScenarioFramework.Dialogue(OpDialog.C01_S2_obj10_ASSIGN, P1_BuildSecondary_Assign)
end

function P1_BuildSecondary_Assign()
	----------------------------------------------
	-- Secondary Objective S2_obj10 - Build Shields
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S2_obj10 - Build Shields.')
	local descText = OpStrings.C01_S2_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C01_S2_obj10_MAKE_SHIELDS)
	ScenarioInfo.S2_obj10 = SimObjectives.ArmyStatCompare(
		'secondary',						-- type
		'incomplete',						-- status
		OpStrings.C01_S2_obj10_NAME,		-- title
		descText,							-- description
		'build',
		{
			Army = 1,
			StatName = 'Units_Active',
			CompareOp = '>=',
			Value = 1,
			Category = categories.ucb0202,
			ShowProgress = true,
		}
	)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.S2_obj10)

	ScenarioInfo.S2_obj10:AddResultCallback(
		function(result)
			-- Only play the success VO if we are still at an appropriate
			-- point in the op (ie, if the player isn't completed with the the
			-- main Defense objective yet).
			if result and (ScenarioInfo.M1_obj10.Active) then
				ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C01_S2_obj10_MAKE_SHIELDS, ARMY_PLAYER, 3.0)
				ScenarioFramework.Dialogue(OpDialog.C01_S2_obj10_COMPLETE)
			end
		end
	)
end

function P1_ResearchSecondary_Prep()
	ScenarioFramework.Dialogue(OpDialog.C01_RESEARCH_UNLOCK, P1_ResearchSecondary_Assign)
end

function P1_ResearchSecondary_Assign()
	-- unlock research
	local success = ScenarioGameSetup.UnlockPlayerResearch(ARMY_PLAYER)

	-- bail if for some reason we do not have correct data (Warnings are automated in the ScenarioFramework function already)
	if not success then
		return
	end

	-- concatenate descText using the OpString info and the name of the research tech.
	local descText = OpStrings.C01_S1_obj10_NAME .. ScenarioGameEvents.AddResearchNames()

	----------------------------------------------
	-- Secondary Objective S1_obj10 - Research Technology
	----------------------------------------------
	LOG('----- P1: Assign Secondary Objective S1_obj10 - Research Technology.')
	ScenarioInfo.S1_obj10 = SimObjectives.Research(
		'secondary',					-- type
		'incomplete',					-- status
		OpStrings.C01_S1_obj10_NAME,	-- title
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
			--the confirmation VO isnt appropriate if we are already making our escape
			if result and ScenarioInfo.M1_obj10.Active then
				ScenarioFramework.Dialogue(OpDialog.C01_RESEARCH_FOLLOWUP_MEGALITH_010)
			end
		end
	)
end

function P1_Escape_Prep()
	-- Brackman as completed the download, so here we complete that objective, play
	-- some VO, then trigger the in-base transport scenario, with Gage dropping
	-- off units right at the players base. Once this is in place, we then assign the
	-- final objective

	-- Complete the Defend objective
	ScenarioInfo.M1_obj10:ManualResult(true)

	ScenarioFramework.Dialogue(OpDialog.C01_M1_obj10_COMPLETE, P1_Escape)
end

function P1_Escape()
	----------------------------------------------
	-- Primary Objective M2_obj10 - Escape via the Gate
	----------------------------------------------
	LOG('----- P1: Assign Primary Objective M2_obj10 - Escape via the Gate.')
	ScenarioInfo.M2_obj10 = SimObjectives.CategoriesInArea(
		'primary',						-- type
		'incomplete',					-- status
		OpStrings.C01_M2_obj10_NAME,	-- title
		OpStrings.C01_M2_obj10_DESC,	-- description
		'build',						-- Action
		{
			---NOTE: I decided to remove the area marking and rely just on the arrow - speak with me before changing this back
			---			the rationale is a compromise to narrow the scope of area area-objective visualization issues to just U06 - bfricks 11/28/09
			AddArrow = true,
			ArrowHeight = 10.0,
			Requirements = {
				{
					Area = 'Gate_Escape_Area',
					Category = categories.ucl0001,
					CompareOp = '>=',
					Value = 1,
					ArmyIndex = ARMY_PLAYER
				},
			},
		}
	)

	-- Timer trigger for the hidden objective which begins after the primary objective is complete
	LOG('----- P1_Escape: **************Timer trigger created for the hidden objective*************')
	ScenarioFramework.CreateTimerTrigger (P2_AssignHiddenObjective, Hidden_PostDefenseTimerOBJ)

	-- update ScenarioInfo.AssignedObjectives
	table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.M2_obj10)

	ScenarioInfo.M2_obj10:AddResultCallback(
		function(result)
			if result then
				ForkThread(OpNIS.NIS_VICTORY)
			end
		end
	)

	-- On last bit of VO exhorting the player to get out. This should broadly coincide with the
	-- massive final attack that comes in.
	ScenarioFramework.CreateTimerTrigger (P1_EscapeWarning_VO, 10)
end

function P2_AssignHiddenObjective()
	----------------------------------------------
	-- Hidden Objective H1_obj10 - Survival Expert
	----------------------------------------------
	LOG('----- P2_AssignHiddenObjective: **************P2_AssignHiddenObjective function start*************')
	if ScenarioInfo.P1_PLAYER_Brain and not ScenarioInfo.P1_PLAYER_Brain:IsDead() then
		LOG('----- P2: Assign Hidden Objective H1_obj10 - Survival Expert')
		local descText = OpStrings.C01_H1_obj10_DESC .. ScenarioGameEvents.AddResearchAwardString(ScenarioGameTuning.C01_H1_obj10_SURV_TIMED)
		ScenarioInfo.H1_obj10 = SimObjectives.Basic(
			'secondary',							-- type
			'complete',								-- status
			OpStrings.C01_H1_obj10_NAME,			-- title
			OpStrings.C01_H1_obj10_DESC,			-- description
			SimObjectives.GetActionIcon('protect'),	-- Action
			{
			}
		)
		-- update ScenarioInfo.AssignedObjectives
		table.insert(ScenarioInfo.AssignedObjectives, ScenarioInfo.H1_obj10)

		ScenarioGameEvents.AwardBonusResearchPoints(ScenarioGameTuning.C01_H1_obj10_SURV_TIMED, ARMY_PLAYER, 3.0)
	end
end

function P1_Gauge_Banter_01()
	-- Gauge banter VO dialog
	ScenarioFramework.Dialogue(OpDialog.C01_GAUGE_BANTER_010)
end

function P1_Gauge_Banter_02()
	-- Gauge banter VO dialog
	ScenarioFramework.Dialogue(OpDialog.C01_GAUGE_BANTER_020)
end

function P1_ExperimentalTransportAttack_VO()
	ScenarioFramework.Dialogue(OpDialog.C01_P1_ATTACK_WARNING_010)
end

function P1_EscapeWarning_VO()
	ScenarioFramework.Dialogue(OpDialog.C01_M2_obj10_UPDATE)
end


---------------------------------------------------------------------
-- EXPERIMENTAL, FINAL, STREAMING ATTACKS
---------------------------------------------------------------------
-- Sundry attack related functions
function P1_TransportStream_Difficulty()
	LOG('----- P1: Transport Stream difficulty incremented')

	-- This new setting will result in the transport stream switching to a slightly stronger
	-- attack group.
	-- this value is concatonated to load specific units and there are only 3 groups
	if ScenarioInfo.StreamDifficulty < 3 then
		ScenarioInfo.StreamDifficulty = ScenarioInfo.StreamDifficulty + 1
	end
end

function P1_EnableAirAttackStream()
	LOG('----- P1: Air Attack stream enabled')

	-- Flag the main air attack thread check, and begin the air attacks
	ScenarioInfo.AirStreamAllowed = true
	ForkThread(P1_AirStreamThread)
end

function P1_Air_AttackAndIncrement()
	LOG('----- P1: Air diff incremented, air attack spawned')

	-- Increment a flag that the air attack stream checks to judge difficulty.
	-- Send a sizable gunship attack at the player at each of these events.
	ScenarioInfo.AirAttackDifficulty = ScenarioInfo.AirAttackDifficulty + 1

	local enemyAirCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.AIR * categories.MOBILE)

	if enemyAirCount < 45 then
		local platoonCount = 2 + ScenarioInfo.AirAttackDifficulty
		for i = 1, platoonCount do
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AirAttack_Loc02_Group_02' , 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Loc02_AirAttack_Chain_0' .. Random (1, 2))
		end
	end
end

function P1_EarlyTransportAttack()
	LOG('----- P1: Light transport attack triggered')

	-- Send in a light attack (group01) against the player
	for i = 1, 3 do
		ForkThread(
			SpawnTransportGroupThread,
			'P1_ENEM01_Xport_Loc0' .. i .. '_Group_01',
			'P1_ENEM01_Xport_Loc0' .. i .. '_Group_01_Transport',
			nil,
			'Location0' .. i .. '_Xport_Landing_01',
			'Location0' .. i .. '_Xport_ReturnPoint',
			'P1_ENEM01_Loc0' .. i .. '_LandAttack_Chain_01'
		)
	end
end

function P1_ExperimentalTransportAttack()
	LOG('----- P1: Experimental Transport attack triggered')

	-- Send in a special transport attack, using alternate routes. This will
	-- take the transports over the player's base, for dramatic effect.
	-- the transports will be protected until they land so we ensure they don't die over the player's base
	for i = 1, 3 do
		ForkThread(
			SpawnTransportGroupThread,
			'P1_ENEM01_EXP_Transport_Loc0' .. i .. '_Group01',
			'P1_ENEM01_EXP_Transport_Loc0' .. i,
			'P1_ENEM01_EXP_TransportRoute_Loc0' .. i,
			'P1_ENEM01_EXP_Transport_Loc0' .. i .. '_Destination',
			'P1_ENEM01_EXP_Transport_ReturnPoint',
			'P1_ENEM01_EXP_AttackRoute_0' .. i,
			true
		)
		if i == 1 then
			WaitSeconds(4)
		end
	end
end

function P1_FinalTransportAttack()
	LOG('----- P1: Final Extreme attack triggered')

	-- Send in a final very large transport attack. This attack does to a series of
	-- unload destinations that are closer to the player's base. As well, each
	-- wave uses 1 of 3 possible unload destination points, per location.
	-- the transports will be unkillable until they land so we ensure they don't die over the player's base
	for j = 1, 3 do
		for i = 1, 3 do
			ForkThread(
				SpawnTransportGroupThread,
				'P1_ENEM01_EXP_Transport_Loc0' .. i .. '_Group01',
				'P1_ENEM01_EXP_Transport_Loc0' .. i,
				'P1_ENEM01_EXP_FinalTransportRoute_Loc0' .. i,
				'P1_ENEM01_EXP_TransportFinal_Loc0' .. i .. '_Destination_0' .. j,
				'P1_ENEM01_EXP_Transport_ReturnPoint',
				'P1_ENEM01_EXP_AttackRoute_0' .. i,
				true
			)
			if i == 1 then
				WaitSeconds(4)
			end
		end
		WaitSeconds(3)
	end
end

---------------------------------------------------------------------
-- PRIMARY THREADS:
---------------------------------------------------------------------
function P1_FinalStage_ExpAttackThread()
	LOG('----- P1: **** ENDGAME **** enabling repeat exp transport attack')

	-- Flag that we are now in the end game, so that a large number of units are
	-- thrown at the player at high rate
	ScenarioInfo.FinalStage = true

	-- Throw a very large land attack at the player very often. This is intended to be
	-- extremely and unrealisticly hard: the player needs to get out instead of stick around.
	while ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS) <= 85 do
		ForkThread(P1_ExperimentalTransportAttack)
		WaitSeconds(45)
	end
end

function P1_AdaptiveResponseThread()
	--Response flags
	ScenarioInfo.RespondingToLand = false
	ScenarioInfo.RespondingToExp = false
	ScenarioInfo.RespondingToAir = false
	ScenarioInfo.RespondingToDefense = false

	while ScenarioInfo.AdaptiveResponse do
		-- Collect information about all the players units --
		-- This retreives the total mobile land units the player has that are considered offensive
		local playerLandCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucl0102 + categories.ucl0103 + categories.ucl0104 + categories.ucl0204 )
		-- This retreives the total point defense, anti-air turret, and shield units the player has
		local playerDefenseCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0101 + categories.ucb0102 + categories.ucb0202 )
		-- This retreives the total air units the player has
		local playerAirCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.AIR * categories.CYBRAN )
		-- This retreives the total experimental units the player has. TBD if the player is allowed to build the Megalith II
		local playerExpCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.EXPERIMENTAL - categories.ucx0115 - categories.ucx0116 )
		-- This retreives the total units the player has within any of the enemy trasport landing zones
		local playerLZCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ALLUNITS * categories.CYBRAN )

		-- This is the enemy response based on the player's total mobile land units built
		if playerLandCount > PlayerLand_Response.Count and not ScenarioInfo.RespondingToLand then
			ScenarioInfo.RespondingToLand = true
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i=1, PlayerLand_Response.Gunships do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Response_Gunship')
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			end
			ScenarioFramework.CreatePlatoonDeathTrigger(function() ScenarioInfo.RespondingToLand = false end, platoon)
			local playerLand = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.ucl0102 + categories.ucl0103 + categories.ucl0104 + categories.ucl0204, false )
			LOG('----- P1: Adaptive Player Land Response Triggered')
			ScenarioFramework.PlatoonPatrolChain (platoon, 'GunshipResponse_PatrolBase')
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
			local playerExp = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.EXPERIMENTAL - categories.ucx0115 - categories.ucx0116, false )
			for k, v in playerExp do
				LOG('----- P1: Adaptive Player Experimental Response Triggered')
				IssueAttack(platoon:GetPlatoonUnits(), v)
			end
			-- After the experimental(s) have been destroyed move to a marker chain around the base
			ScenarioFramework.PlatoonPatrolChain (platoon, 'GunshipResponse_PatrolBase')
			ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 5)
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
			local playerAir = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.AIR * categories.CYBRAN, false )
			for k, v in playerAir do
				LOG('----- P1: Adaptive Player Air Response Triggered')
				IssueAttack(platoon:GetPlatoonUnits(), v)
			end
		end

		-- This is the enemy response based on the player's total base defense units built
		if playerDefenseCount > PlayerDefense_Response.Count and not ScenarioInfo.RespondingToDefense then
			ScenarioInfo.RespondingToDefense = true
			local platoon = ArmyBrains[ARMY_ENEM01]:MakePlatoon('', '')
			for i=1, PlayerDefense_Response.Gunships do
				local unit = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'P1_ENEM01_Response_Gunship')
				ScenarioFramework.SetUnitVeterancyLevel(unit, 5)
				ArmyBrains[ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
			end
			ScenarioFramework.CreatePlatoonDeathTrigger(function() ScenarioInfo.RespondingToDefense = false end, platoon)
			local playerDefense = ArmyBrains[ARMY_PLAYER]:GetListOfUnits(categories.ucb0101 + categories.ucb0102 + categories.ucb0202, false )

			LOG('----- P1: Adaptive Player Base Defense Response Triggered')
			for k, v in playerDefense do
				IssueAttack(platoon:GetPlatoonUnits(), v)
			end
			ScenarioFramework.PlatoonPatrolChain (platoon, 'GunshipResponse_PatrolBase')
		end

		-- time between player response checks
		WaitSeconds (13)
	end
end

function P1_AirStreamThread()
	-- This thread periodically sends in small air attack groups. It will
	-- pause between loops for a duration that is effected by growing difficulty
	-- flag, and how well or poorly the player is doing. The result is a growing
	-- trend of difficulty, that is strengthened or weakened due to player unit count.

	-- initialize these variables. One is a wait modifier based on player unit count, the
	-- second based on a growing difficulty trend.
	local waitMod1 = 0
	local waitMod2 = 0

	while ScenarioInfo.AirStreamAllowed do
		-- Collect information about the player and the enemy, to check against below.
		local playerUnitCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucl0204 + categories.uca0103 + categories.uca0104 + categories.ucl0102 + categories.ucl0103 + categories.ucl0104)
		local enemyAirCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.AIR * categories.MOBILE)
		local enemyUnitCountTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)

		LOG ('----- P1_AirStreamThread: playerUnitCount: ',(repr(playerUnitCount)))
		LOG ('----- P1_AirStreamThread: enemyAirCount: ',(repr(enemyAirCount)))

		-- Dont spawn units if a sizable amount of air is already in play, or if we have hit an overall
		-- hard limit of units (both are a sign that the player is overwhelmed)
		if enemyAirCount < 35 and enemyUnitCountTotal < 120 then
			local rndLoc = Random (1, 3)
			local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AirAttack_Loc0' .. rndLoc .. '_Group_0' .. Random (1, 2) , 'AttackFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'P1_ENEM01_Loc0' .. rndLoc .. '_AirAttack_Chain_0' .. Random (1, 2))
		end

		-- set a value that will modify a base wait time, based on how many units the player is doing
		-- If the player is doing poorly, we will add time to the wait; well, we will subtract from it.
		if playerUnitCount < 25 then
			waitMod1 = 13
		elseif playerUnitCount >= 26 and playerUnitCount < 40 then
			waitMod1 = 5
		elseif playerUnitCount >= 41 and playerUnitCount < 60 then
			waitMod1 = -5
		elseif playerUnitCount >= 61 and playerUnitCount < 80 then
			waitMod1 = -13
		elseif playerUnitCount >= 81 then
			waitMod1 = -20
		end

		-- the difficulty of the air setup grows over time, based on timer triggers that changes
		-- a value (ScenarioInfo.AirAttackDifficulty). Come up with a value to subtract from the base
		-- wait period to reflect this.
		waitMod2 = ScenarioInfo.AirAttackDifficulty * -2

		-- The delay will be modified by a combination of the above to values, reflecting a player
		-- unit count derived value, and a growing difficulty trend derived value.
		local delayModifier = waitMod1 + waitMod2

		-- paranoia. too much caffeine results in excessively paranoid checks like the following, for
		-- values that could never reach these amounts. We are checking if somehow the delayModifier
		-- would reduce our WaitSeconds period to less than zero.
		if delayModifier < -35 then delayModifier = 0 end
		LOG ('(air thread) Time till next air pass: ',(repr(35 + delayModifier)))

		-- Use the modified value for a wait, unless we are in the endgame, when we want overwhelming air.
		if not ScenarioInfo.FinalStage then
			WaitSeconds(AirStreamDelay + delayModifier)
		else
			WaitSeconds(AirStreamDelay_FinalStage)
		end
	end
end

function P1_TransportStreamThread()

	-- While not necessary, delcare these in advance to keep things neat and understandable
	local land1Dest = 'Location01_Xport_Landing_01'
	local land1return = 'Location01_Xport_ReturnPoint'
	local land1Chain = 'P1_ENEM01_Loc01_LandAttack_Chain_01'

	local land2Dest = 'Location02_Xport_Landing_01'
	local land2return = 'Location02_Xport_ReturnPoint'
	local land2Chain = 'P1_ENEM01_Loc02_LandAttack_Chain_01'

	local land3Dest = 'Location03_Xport_Landing_01'
	local land3return = 'Location03_Xport_ReturnPoint'
	local land3Chain = 'P1_ENEM01_Loc03_LandAttack_Chain_01'

	local waitMod = 0

	while ScenarioInfo.TransportStreamAllowed do
		-- at different points, we will want to check how the player and enemy are doing, unit-count wise
		local playerUnitCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ucb0101 + categories.ucl0204 + categories.uca0103 + categories.uca0104 + categories.ucl0102 + categories.ucl0103 + categories.ucl0104)
		local enemyLandCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS * categories.MOBILE)
		local enemyUnitCountTotal = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)

		LOG('----- P1_TransportStreamThread: playerUnitCount: ', repr(playerUnitCount))
		LOG('----- P1_TransportStreamThread: enemyLandCount: ', repr(enemyLandCount))
		LOG('----- P1_TransportStreamThread: enemyUnitCountTotal: ', repr(enemyUnitCountTotal))
		LOG('----- P1_TransportStreamThread: Stream difficulty: ', repr(ScenarioInfo.StreamDifficulty))

		-- update which transport groups we will use
		local land1 = 'P1_ENEM01_Xport_Loc01_Group_0' .. ScenarioInfo.StreamDifficulty
		local land1Trans = 'P1_ENEM01_Xport_Loc01_Group_0' .. ScenarioInfo.StreamDifficulty .. '_Transport'

		local land2 = 'P1_ENEM01_Xport_Loc02_Group_0' .. ScenarioInfo.StreamDifficulty
		local land2Trans = 'P1_ENEM01_Xport_Loc02_Group_0' .. ScenarioInfo.StreamDifficulty .. '_Transport'

		local land3 = 'P1_ENEM01_Xport_Loc03_Group_0' .. ScenarioInfo.StreamDifficulty
		local land3Trans = 'P1_ENEM01_Xport_Loc03_Group_0' .. ScenarioInfo.StreamDifficulty .. '_Transport'

		-- if the enemy doesn't have too many land units already in play (and isnt, in total, getting
		-- too many units going on)
		if enemyLandCount < 55 and enemyUnitCountTotal < 120 then

			-- Fork a spawn/move thread for each location, in order of middle, left, right (2, 1, 3).
			-- Keep things soft by using a short pause between each spawn
			ForkThread(SpawnTransportGroupThread, land2, land2Trans, nil, land2Dest, land2return, land2Chain)
			WaitSeconds(5)
			ForkThread(SpawnTransportGroupThread, land1, land1Trans, nil, land1Dest, land1return, land1Chain)
			WaitSeconds(5)
			ForkThread(SpawnTransportGroupThread, land3, land3Trans, nil, land3Dest, land3return, land3Chain)
		else
			LOG('----- P1_TransportStreamThread: ***** too many enemies or too many overall units! skipping this round ****')
		end

		-- We will modify the time between each spawn pass based on how
		-- well or poorly the player is doing
		if playerUnitCount < 25 then
			waitMod = 20
		elseif playerUnitCount > 45 and playerUnitCount < 70 then
			waitMod = -3
		elseif playerUnitCount > 71 and playerUnitCount < 90 then
			waitMod = -6
		elseif playerUnitCount > 91 then
			waitMod = -9
		end

		LOG('----- P1_TransportStreamThread: playerUnitCount: ', repr(playerUnitCount))

		-- Slow things down if the enemy is getting a lot of units stacked up. Probably is a sign
		-- that the player is getting a little overwhelmed
		if enemyLandCount > 35 then
			LOG('----- P1_TransportStreamThread: enemy land count high. LONG WAIT')
			WaitSeconds(PlayerOverwhelmedDelay)

		-- Otherwise, wait for a duration modified by how the player is doing, defined above
		else
			LOG('----- P1_TransportStreamThread: Wait time till next loop: ', repr(TransportStreamDelay + waitMod))

			-- if the delay we are going to use is less than a min value,
			-- reset it to that min value (in case we get too low, or negative).
			local delay = TransportStreamDelay + waitMod
			if delay < TransportStream_MinimumDelay then
				delay = TransportStream_MinimumDelay
			end
			WaitSeconds(delay)
		end
	end
end

function SpawnTransportGroupThread(group, transporter, route, destination, returnloc, chain, unkillable)
	-- Create a transport, platoon. Load them up, send them out, and get them
	-- sorted out with subsequent commands and cleanup.

	-- group 		- group name of units to be spawned as platoon
	-- transporter 	- name of transport unit to create
	-- route		- OPTIONAL route for transport to take, instead of going direct to destination
	-- destination 	- name of transport unload destination marker
	-- return 		- name of marker transport will return to for destruction
	-- chain 		- marker chain transported platoon will follow once unloaded
	-- unkillable   - optional variable that will flag transport unkillable until they land

	local transport = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', transporter)
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', group, 'AttackFormation')
	local units = platoon:GetPlatoonUnits()

	-- if this is flagged to be unkillable until landed do so
	---NOTE: on review, I think it is clearer to the player to make the unkillable transports be truely protected
	---			so they are not even a factor in the combat - bfricks 11/3/09
	if unkillable then
		if transport and not transport:IsDead() then
			ProtectUnit(transport)
		end
	end

	-- attach, issue an unload, and quueue up a subsequent return for the transport.
	-- If a transport route has been passed in, then queue up that route prior to the final
	-- unlead destination.
	TransportUtils.AddUnitsToTransportStorage(units, {transport})
	if route != nil then
		for k, v in ScenarioUtils.ChainToPositions(route) do
			IssueMove({transport}, v)
		end
	end
	local command = IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(destination))
	IssueMove({transport}, ScenarioUtils.MarkerToPosition(returnloc))

	-- give veterancy buff to group
	if Veterancy_Counter == 1 then
		ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 1)
	elseif Veterancy_Counter == 2 then
		ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 2)
	elseif Veterancy_Counter == 3 then
		ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 3)
	elseif Veterancy_Counter == 4 then
		ScenarioFramework.SetPlatoonVeterancyLevel(platoon, 5)
	end

	-- Fork a thread to watch our platoon and send them on attack when appropriate. Also will
	-- set the transport up with a trigger to destroy the transport thereafter.
	ForkThread(TransportPlatoonAttackThread, platoon, transport, returnloc, command, chain)
end

function TransportPlatoonAttackThread(platoon, transport, returnloc, command, chain)
	-- Watch the transport's unload command. When it has completed, we can now tell
	-- the platoon to go on its attack. Also, we put a distance trigger on the transport,
	-- and send it home. The trigger will see it destroyed when it gets there.

	-- platoon 		- platoon being transported to location
	-- transport 	- transport unit
	-- returnloc	- return location for transport, where it will be destroyed
	-- command 		- the unload command the transport is using, and this thread will watch
	-- chain 		- attack chain platoon will attack with
	-- unkillable   - optional variable that will flag transport unkillable until they land

	-- Wait for the all units to be unattached and landed before we continue on and
	-- give them a patrol.
	local attached = true
	while attached do
		WaitSeconds(3)
		if transport:IsDead() then
			return
		end
		attached = false
		for num, unit in platoon:GetPlatoonUnits() do
			if not unit:IsDead() and unit:IsUnitState('Attached') then
				attached = true
				break
			end
		end
	end

	ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, returnloc, 10)

	if platoon and ArmyBrains[ARMY_ENEM01]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain(platoon, chain)
	end
end

function P1_TrackCommanderLocation()
	LOG('----- P1_TrackCommanderLocation: Enabling Tracking of Commander')

	-- Periodically check if the commander is too far away from the starting base area.
	-- If so, spawn a gunship attack that goes to the CDR. Keep things moderate by
	-- only allowing one attack at a time, via a deathtrigger-magaged flag.
	local marker = ScenarioUtils.MarkerToPosition('CommanderAttack_Marker')
	local distance = 80
	local unit = ScenarioInfo.PLAYER_CDR
	while ScenarioInfo.TrackCommanderAllowed do
		LOG('----- P1_TrackCommanderLocation: Player Commander location check, tick.')
		if not ScenarioInfo.CommanderUnderAttack then
			if not (unit:IsDead()) then
				local position = unit:GetPosition()
				local value = VDist2( position[1], position[3], marker[1], marker[3])
				if value >= distance then
					LOG('----- P1_TrackCommanderLocation: Creating platoon to attack Commander.')
					local units = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AirAttack_Loc02_Group_02', 'GrowthFormation')
					IssueAttack(units:GetPlatoonUnits(), ScenarioInfo.PLAYER_CDR)
					ScenarioFramework.CreatePlatoonDeathTrigger( P1_SetCommanderAttackable, units )
					ScenarioInfo.CommanderUnderAttack = true

					-- If we havent already, and if we are still in the main defend objective,
					-- play a warning once if the player moves their Commander unsafely far
					-- away from the main base area.
					if not ScenarioInfo.P1_CommanderLocationWarningPlayed then
						ScenarioInfo.P1_CommanderLocationWarningPlayed = true
						if ScenarioInfo.M1_obj10.Active then
							ScenarioFramework.Dialogue(OpDialog.C01_P1_CDR_WARNING_010)
						end
					end
				end
			end
		end
		WaitSeconds(45)
	end
end

function P1_SetCommanderAttackable()
	LOG('----- P1_SetCommanderAttackable: Platoon attacking commander is dead, flagging safe to create another.')
	-- The platoon attacking the commander has died, so another is now allowed to be created when
	-- needed.
	ScenarioInfo.CommanderUnderAttack = false
end

function Gunship_Wave()
	local playerUnitCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ALLUNITS - categories.ucl0001 - categories.ucl0002)

	-- If playerUnitCount is less than 46 then send gunship group 1
	if playerUnitCount < 46 then
		ScenarioInfo.Gunship_Group01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'Gunship_Group01' )
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.Gunship_Group01, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.Gunship_Group01, 'P1_ENEM01_Loc01_AirAttack_Chain_02' )
	end

	-- If playerUnitCount is greater than 59 then send gunship group 2
	if playerUnitCount > 59 then
		ScenarioInfo.Gunship_Group02 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'Gunship_Group02' )
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.Gunship_Group02, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.Gunship_Group02, 'P1_ENEM01_Loc03_AirAttack_Chain_02' )
	end

	-- If playerUnitCount is greater than 74 then send gunship group 3
	if playerUnitCount > 74 then
		ScenarioInfo.Gunship_Group03 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'Gunship_Group03' )
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.Gunship_Group03, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.Gunship_Group03, 'P1_ENEM01_Loc02_AirAttack_Chain_02' )
	end

	-- If playerUnitCount is greater than 91 then send gunship group 4
	if playerUnitCount > 91 then
		ScenarioInfo.Gunship_Group04 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'Gunship_Group04' )
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.Gunship_Group04, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.Gunship_Group04, 'P1_ENEM01_Loc02_AirAttack_Chain_02' )
	end
end

function SoulRipper_Assassin()
	LOG('----- P1: Soul Ripper Assassin spawned. Destroy the chiphead!.')
	-- Murder. Death. Kill
	ScenarioInfo.SoulRipper_Assassin = ScenarioUtils.CreateArmyUnit('ARMY_ENEM01', 'SoulRipper_Assassin')
	ScenarioFramework.SetUnitVeterancyLevel(ScenarioInfo.SoulRipper_Assassin, 5)
	IssueMove({ScenarioInfo.SoulRipper_Assassin}, ScenarioInfo.PLAYER_CDR:GetPosition())
	IssueAttack({ScenarioInfo.SoulRipper_Assassin}, ScenarioInfo.PLAYER_CDR)
end

function SoulRipper_Wave()
	local playerUnitCount = ArmyBrains[ARMY_PLAYER]:GetCurrentUnits(categories.ALLUNITS - categories.ucl0001 - categories.ucl0002)

	-- If playerUnitCount is less than 51 then send soul ripper group 1
	if playerUnitCount < 51 then
		ScenarioInfo.SoulRipper_Group01 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'SoulRipper_Group01')
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.SoulRipper_Group01, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.SoulRipper_Group01, 'P1_ENEM01_Loc01_AirAttack_Chain_02' )
	end

	-- If playerUnitCount is greater than 59 then send soul ripper group 2
	if playerUnitCount > 59 then
		ScenarioInfo.SoulRipper_Group02 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'SoulRipper_Group02' )
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.SoulRipper_Group02, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.SoulRipper_Group02, 'P1_ENEM01_Loc03_AirAttack_Chain_02' )
	end

	-- If playerUnitCount is greater than 69 then send soul ripper group 3
	if playerUnitCount > 69 then
		ScenarioInfo.SoulRipper_Group03 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'SoulRipper_Group03' )
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.SoulRipper_Group03, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.SoulRipper_Group03, 'P1_ENEM01_Loc02_AirAttack_Chain_02' )
	end

	-- If playerUnitCount is greater than 81 then send soul ripper group 4
	if playerUnitCount > 81 then
		ScenarioInfo.SoulRipper_Group04 = ScenarioUtils.CreateArmyGroup('ARMY_ENEM01', 'SoulRipper_Group04' )
		ScenarioFramework.SetGroupVeterancyLevel(ScenarioInfo.SoulRipper_Group04, 5)
		ScenarioFramework.GroupPatrolChain( ScenarioInfo.SoulRipper_Group04, 'P1_ENEM01_Loc02_AirAttack_Chain_02' )
	end
end

function P1_CreateAirTrigger_Zone1(timerTrigger)
	LOG('----- P1: Creating trigger for Air Zone 1.')

	if timerTrigger then timerTrigger:Destroy() end
	ScenarioFramework.CreateAreaTrigger(P1_AirThreatened_Zone1 , 'Transport_Entry_Zone_01', categories.AIR, true, false, ArmyBrains[ARMY_PLAYER], 5 )
end

function P1_AirThreatened_Zone1()
	LOG('----- P1: Air zone 1 threatened. Creating patrol.')
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_AirAttack_Loc01_Group_01' , 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'Transport_AirPatrol_Zone01')

	ScenarioInfo.TimerTrigger = ScenarioFramework.CreateTimerTrigger (
		function()
			P1_CleanUpAirZone( ScenarioInfo.DeathTrigger, platoon, 'Location01_Xport_ReturnPoint')
			P1_CreateAirTrigger_Zone1()
		end
		,60)

	ScenarioInfo.DeathTrigger = ScenarioFramework.CreatePlatoonDeathTrigger(
		function()
			LOG('----- P1: ^^^^^^^^^^^^^^^^^^^ death trigger callback.')
			P1_CreateAirTrigger_Zone1(ScenarioInfo.TimerTrigger)
		end
		, platoon)
end

function P1_CleanUpAirZone(trigger, platoon, returnpoint)
	LOG('----- P1: Cleaning up air zone patrol')
	trigger:Destroy()
	if platoon then
		for k, v in platoon:GetPlatoonUnits() do
			if(v and not v:IsDead()) then
				IssueClearCommands({v})
				IssueMove( v, ScenarioUtils.MarkerToPosition( returnpoint ) )
				ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, v, returnpoint, 10)
			end
		end
	end
end


---------------------------------------------------------------------
-- DEBUG FUNCTIONS:
---------------------------------------------------------------------
function OnShiftF3()
	ForkThread(Debug_ReportEnemyUnitCount)
end

function Debug_ReportEnemyUnitCount()
	while not ScenarioInfo.Nothing do
		local enemyUnitCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.ALLUNITS)
		local enemyAirCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.AIR * categories.MOBILE)
		local enemyLandCount = ArmyBrains[ARMY_ENEM01]:GetCurrentUnits(categories.LAND * categories.MOBILE)

		LOG ('----- Enemy unit count: ',(repr(enemyUnitCount)))
		LOG ('----- Enemy air count: ',(repr(enemyAirCount)))
		LOG ('----- Enemy land count: ',(repr(enemyLandCount)))
		LOG ('-----')

		WaitSeconds(6)
	end
end


function OnShiftF4()
	SoulRipper_Assassin()
end

function OnShiftF5()
	ScenarioInfo.M1_obj10:ManualResult(true)
	ForkThread(OpNIS.NIS_VICTORY)
end


---------------------------------------------------------------------
-- NOTES:
---------------------------------------------------------------------

