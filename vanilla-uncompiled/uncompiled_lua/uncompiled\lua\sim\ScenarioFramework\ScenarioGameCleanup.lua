--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for scenario cleanup functions.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local PlayMusicEventByHandle = import('/lua/sim/ScenarioFramework/ScenarioGameMusic.lua').PlayMusicEventByHandle


---------------------------------------------------------------------
-- GetPlayerName()
-- simple function to return a player name
---------------------------------------------------------------------
function GetPlayerName()
	-- determine our potential name
	local name = import('/lua/sim/ScenarioFramework/ScenarioGameNames.lua').CDR_Maddox
	if ScenarioInfo.campaignID == 'Cybran' then
		name = import('/lua/sim/ScenarioFramework/ScenarioGameNames.lua').CDR_Ivan
	elseif ScenarioInfo.campaignID == 'Illuminate' then
		name = import('/lua/sim/ScenarioFramework/ScenarioGameNames.lua').CDR_Thalia
	end

	return name
end

---------------------------------------------------------------------
-- PlayerDeath(playerUnit)
-- handling for the player defeat in the event of death
---------------------------------------------------------------------
function PlayerDeath(playerUnit)
	-- handle the escape pod scenario
	local podList = {}
	local cdrList = {}
	podList = ArmyBrains[1]:GetListOfUnits(categories.ESCAPEPOD, false)
	cdrList = ArmyBrains[1]:GetListOfUnits(categories.ucl0001 + categories.uil0001 + categories.uul0001, false)

	local foundAlivePOD = nil
	local foundAliveCDR = nil

	for k, unit in podList do
		if unit and not unit:IsDead() then
			foundAlivePOD = unit
			break
		end
	end

	for k, unit in cdrList do
		if unit and not unit:IsDead() then
			foundAliveCDR = unit
			break
		end
	end

	-- handle all the cases where we want to early out
	if foundAlivePOD and foundAliveCDR then
		error('ERROR: PlayerDeath somehow encountered both an alive CDR and an alive POD at the same time - bad stuff!')
		return
	elseif foundAlivePOD then
		LOG('^^^^^^^^ESCAPE POD HANDLER^^^^^^^^PLAYER DEATH HANDLING: foundAlivePOD')
		local name = GetPlayerName()
		ScenarioInfo.PLAYER_CDR = foundAlivePOD
		ScenarioInfo.PLAYER_CDR:SetCustomName(name)
		import('/lua/sim/ScenarioTriggers.lua').CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

		import('/lua/sim/ScenarioTriggers.lua').CreateUnitBuiltTrigger(
			function(builder, unitBeingBuilt)
				LOG('^^^^^^^^ESCAPE POD HANDLER^^^^^^^^PLAYER DEATH HANDLING: new CDR built')
				local name = GetPlayerName()
				ScenarioInfo.PLAYER_CDR = unitBeingBuilt
				import('/lua/sim/ScenarioTriggers.lua').CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )

				ForkThread(
					function()
						WaitTicks(1)
						LOG('^^^^^^^^ESCAPE POD HANDLER^^^^^^^^PLAYER DEATH HANDLING: setting custom name')
						if ScenarioInfo.PLAYER_CDR and not ScenarioInfo.PLAYER_CDR:IsDead() then
							ScenarioInfo.PLAYER_CDR:SetCustomName(name)
						end
					end
				)
			end,
			ScenarioInfo.PLAYER_CDR,
			categories.ucl0001 + categories.uil0001 + categories.uul0001
		)
		return
	elseif foundAliveCDR then
		LOG('^^^^^^^^ESCAPE POD HANDLER^^^^^^^^PLAYER DEATH HANDLING: foundAliveCDR')
		local name = GetPlayerName()
		ScenarioInfo.PLAYER_CDR = foundAliveCDR
		ScenarioInfo.PLAYER_CDR:SetCustomName(name)
		import('/lua/sim/ScenarioTriggers.lua').CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR )
		return
	end

	-- flag completion status
	ScenarioInfo.OpEnded = true
	ScenarioInfo.OpVictorious = false
	ScenarioInfo.SecondariesComplete = false

	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: after SC2, replace this with just using ScenarioInfo.OpEnded - due to proximity to ship - that change feels unsafe at this time
	---			so creating this new variable as our best fix for the objectives lock - bfricks 1/7/10
	ScenarioInfo.ReadyToBlockObjectiveUpdates = true
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	local ent = nil
	if playerUnit then
		-- spawn an entity at the location and orientation of the unit
		ent = import('/lua/sim/Entity.lua').Entity()

		local pos = {}
		local playerPOS = playerUnit:GetPosition()
		pos = {playerPOS[1], playerPOS[2], playerPOS[3]}

		Warp(ent,pos)
		ent:SetOrientation(playerUnit:GetOrientation(), true)

		-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
		import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 100, true, 90001, 90001, ArmyBrains)
	end

	local screamDialog = nil
	if ScenarioInfo.campaignID then
		if ScenarioInfo.campaignID == 'Cybran' then
			screamDialog = GetRandomPlayerScream_CYB()
		elseif ScenarioInfo.campaignID == 'Illuminate' then
			screamDialog = GetRandomPlayerScream_ILL()
		elseif ScenarioInfo.campaignID == 'UEF' then
			screamDialog = GetRandomPlayerScream_UEF()
		end
	end

	-- clear the dialog queue
	import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').FlushDialogueQueue(true)

	-- disable all combat
	import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').DisableAllUnitAttackers()

	-- fire of a death NIS
	ForkThread(
		function()
			if ent then
				import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua').RandomNIS(ent,screamDialog)
			end

			-- play some fail music
			PlayMusicEventByHandle('OP_COMPLETE_PLAYERDEATH')

			KillGame()
		end
	)
end

---------------------------------------------------------------------
-- Defeat
-- handling for a player failure scenario
---------------------------------------------------------------------
function Defeat(bLaunchRandomNIS, NISPos, NISDialog)
	-- flag completion status
	ScenarioInfo.OpEnded = true
	ScenarioInfo.OpVictorious = false
	ScenarioInfo.SecondariesComplete = false

	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: after SC2, replace this with just using ScenarioInfo.OpEnded - due to proximity to ship - that change feels unsafe at this time
	---			so creating this new variable as our best fix for the objectives lock - bfricks 1/7/10
	ScenarioInfo.ReadyToBlockObjectiveUpdates = true
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	-- clear the dialog queue
	import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').FlushDialogueQueue(true)

	-- disable all combat
	import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').DisableAllUnitAttackers()

	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(NISPos, 100, true, 90001, 90001, ArmyBrains)

	-- if required, fire of a death NIS
	if bLaunchRandomNIS and NISPos then
		ForkThread(
			function()
				-- spawn an entity at the specified location
				local ent = import('/lua/sim/Entity.lua').Entity()
				Warp(ent,NISPos)

				-- using the ent, launch an NIS
				import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua').RandomNIS(ent,NISDialog)

				-- play some fail music
				PlayMusicEventByHandle('OP_COMPLETE_DEFEAT')

				KillGame()
			end
		)
	else
		-- and kill the game session
		ForkThread(KillGame)
	end
end


---------------------------------------------------------------------
-- Victory
-- handling for a player victory scenario
---------------------------------------------------------------------
function Victory()
	-- play the win music
	PlayMusicEventByHandle('OP_COMPLETE_VICTORY')

	-- flag completion status
	ScenarioInfo.OpEnded = true
	ScenarioInfo.OpVictorious = true
	ScenarioInfo.SecondariesComplete = true

	-- and kill the game session
	ForkThread(
		function()
			if ScenarioInfo.AssignedObjectives and ScenarioInfo.AssignedObjectives.VictoryCallbackList then
				for k, cb in ScenarioInfo.AssignedObjectives.VictoryCallbackList do
					cb()
					WaitSeconds(2.0)
				end
			end

			---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			---NOTE: after SC2, replace this with just using ScenarioInfo.OpEnded - due to proximity to ship - that change feels unsafe at this time
			---			so creating this new variable as our best fix for the objectives lock - bfricks 1/7/10
			ScenarioInfo.ReadyToBlockObjectiveUpdates = true
			---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

			KillGame()
		end
	)
end

---------------------------------------------------------------------
-- KillGame
-- Call to fork the ending of the operation
---------------------------------------------------------------------
function KillGame()
	-- always fade-to-black at this point
	Sync.NISFadeOut = { ["seconds"] = 3.0 }
	WaitSeconds(3.0)

	-- report the final score data to the log
	local scoreData = GetScoreDate(ScenarioInfo.ARMY_PLAYER)
	ReportScore(scoreData)

	if ScenarioInfo.OpVictorious then
		---NOTE: adding the voice event for operation completed - bfricks 12/6/09
		CreateSimSyncSound( Sound{ Bank = 'VOC', Cue = 'COMPUTER/VOC_COMPUTER_Operation_Complete_010' } )

		---NOTE: leaving this in here in case we decide to block this call when the HIH is up - bfricks 12/6/09
		--CreateSimSyncVoice( 'SC2/VOC/COMPUTER/VOC_COMPUTER_Operation_Complete_010' )
		--LOG('SIM: PLAY VOICE: [', str, ']')
	else
		---NOTE: adding the voice event for operation failed - bfricks 12/6/09
		CreateSimSyncSound( Sound{ Bank = 'VOC', Cue = 'COMPUTER/VOC_COMPUTER_Op_Failed_010' } )

		---NOTE: leaving this in here in case we decide to block this call when the HIH is up - bfricks 12/6/09
		--CreateSimSyncVoice( 'SC2/VOC/COMPUTER/VOC_COMPUTER_Op_Failed_010' )
		--LOG('SIM: PLAY VOICE: [', str, ']')
	end

	Sync.OperationComplete = {
		opKey			= ScenarioInfo.name,
		success			= ScenarioInfo.OpVictorious,
		difficulty		= ScenarioInfo.Options.Difficulty,
		allPrimary		= ScenarioInfo.OpVictorious,
		allSecondary	= ScenarioInfo.SecondariesComplete,
		campaignID		= ScenarioInfo.campaignID,
		ScoreSummary	= scoreData,
	}
	-- Fill in all of the objectives we completed
	Sync.OperationComplete.completedObjectives = {}
	if ScenarioInfo.AssignedObjectives then
		for k, objective in ScenarioInfo.AssignedObjectives do
			if objective.Complete then
			    table.insert(Sync.OperationComplete.completedObjectives, objective.Title)
			end
		end
	end
end

---------------------------------------------------------------------
function GetRandomPlayerScream_UEF()
	local screamDialog = nil

	local miscVO = import('/maps/SC2_MISC_VO/SC2_MISC_VO_OpDialog.lua')
	local screamList = {
		'MISC_MADDOX_SCREAM_010',
		'MISC_MADDOX_SCREAM_020',
		'MISC_MADDOX_SCREAM_030',
		'MISC_MADDOX_SCREAM_040',
		'MISC_DAXIL_MADDOX',
		'MISC_DAXIL_MIGRAINE',
	}

	if ScenarioInfo.name == 'SC2_CA_U01' then
		table.insert(screamList, 'MISC_RODGERS_MADDOX')
		table.insert(screamList, 'MISC_RODGERS_WATCHOUT')
	elseif ScenarioInfo.name == 'SC2_CA_U02' then
		table.insert(screamList, 'MISC_RODGERS_MADDOX')
		table.insert(screamList, 'MISC_RODGERS_WATCHOUT')
	elseif ScenarioInfo.name == 'SC2_CA_U03' then
		table.insert(screamList, 'MISC_RODGERS_MADDOX')
		table.insert(screamList, 'MISC_RODGERS_WATCHOUT')
	end

	local num = import('/lua/system/utilities.lua').GetRandomInt(1,table.getn(screamList))
	screamDialog = miscVO[screamList[num]]

	return screamDialog
end

---------------------------------------------------------------------
function GetRandomPlayerScream_ILL()
	local screamDialog = nil

	local miscVO = import('/maps/SC2_MISC_VO/SC2_MISC_VO_OpDialog.lua')
	local screamList = {
		'MISC_THALIA_SCREAM_010',
		'MISC_THALIA_SCREAM_020',
		'MISC_THALIA_SCREAM_030',
		'MISC_THALIA_SCREAM_040',
		'MISC_THALIA_SCREAM_050',
		'MISC_THALIA_SCREAM_060',
		'MISC_THALIA_SCREAM_070',
		'MISC_JARAN_SCREAM_010',
		'MISC_JARAN_SCREAM_020',
		'MISC_JARAN_SCREAM_030',
	}

	local num = import('/lua/system/utilities.lua').GetRandomInt(1,table.getn(screamList))
	screamDialog = miscVO[screamList[num]]

	return screamDialog
end

---------------------------------------------------------------------
function GetRandomPlayerScream_CYB()
	local screamDialog = nil

	local miscVO = import('/maps/SC2_MISC_VO/SC2_MISC_VO_OpDialog.lua')
	local screamList = {
		'MISC_IVAN_SCREAM_010',
		'MISC_IVAN_SCREAM_020',
		'MISC_IVAN_SCREAM_030',
		'MISC_IVAN_SCREAM_040',
		'MISC_IVAN_SCREAM_050',
		'MISC_IVAN_SCREAM_060',
		'MISC_DOC_SCREAM_010',
	}

	local num = import('/lua/system/utilities.lua').GetRandomInt(1,table.getn(screamList))
	screamDialog = miscVO[screamList[num]]

	return screamDialog
end

---------------------------------------------------------------------
-- ReportScore
-- print to log the values of the score
---------------------------------------------------------------------
function ReportScore(scoreData)
	LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
	LOG('----------------BEGIN SCORE SUMMARY:---------------------')
	LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
	LOG('------------------------------------')
	LOG(ScenarioInfo.name)
	LOG(ScenarioInfo.campaignID)
	LOG('DIFFICULTY:[', ScenarioInfo.Options.Difficulty, ']')
	LOG('OPENING DURATION:[', ScenarioInfo.CampaignOpeningEndTime, ']')
	if IsXbox() then
		LOG('PLATFORM:[XBOX]')
	elseif ScenarioInfo.Options.UseGamePad then
		LOG('PLATFORM:[GAMEPAD-PC]')
	else
		LOG('PLATFORM:[PC]')
	end
	LOG('------------------------------------')
	LOG( repr(ScenarioInfo.ScoreTuningData) )
	LOG('------------------------------------')
	LOG( repr(ScenarioInfo.ScoreResults) )
	LOG('------------------------------------')
	LOG( repr(scoreData) )
	LOG('------------------------------------')
	LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
end

---------------------------------------------------------------------
-- GetScoreDate
-- return a table of army specific values for determining medal and star awards at the end of an operation
---------------------------------------------------------------------
function GetScoreDate(nArmyIndex)
	-- assign a point value associated with each full star
	local starLevelIncrement	= 1000		-- point value associated with each full star
	local overageScale_C		= 20		-- point value for each kill above the max star rating
	local overageScale_O		= 5000		-- point value for each objective above the max star rating
	local overageScale_R		= 200		-- point value for each researched technology above the max star rating
	local overageScale_T		= 4			-- point value for each second below the max star rating
	local nXBOXTimeLevelMult	= 1.1		-- multiplier to the TimeScale for the XBOX or Gamepad

	-- construct a ScoreSummary table - which will be filled in below
	local ScoreSummary = {}
	ScoreSummary.IsTutorial			= ScenarioInfo.tutorial or false
	ScoreSummary.MedalType			= ScenarioInfo.tutorial and 3 or ScenarioInfo.Options.Difficulty

	ScoreSummary.CombatPoints		= ScenarioInfo.tutorial and 5000 or 0	-- the number of points awarded for how solid the player did during combat - kill/death ratio
	ScoreSummary.CombatStars		= ScenarioInfo.tutorial and 5 or 0		-- stars earned for Time

	ScoreSummary.ObjectivesPoints	= ScenarioInfo.tutorial and 5000 or 0	-- the number of points awarded for the player completing objectives
	ScoreSummary.ObjectivesStars	= ScenarioInfo.tutorial and 5 or 0		-- stars earned for Time

	ScoreSummary.ResearchPoints		= ScenarioInfo.tutorial and 5000 or 0	-- the number of points awarded for the player completing research
	ScoreSummary.ResearchStars		= ScenarioInfo.tutorial and 5 or 0		-- stars earned for Time

	ScoreSummary.TimePoints			= ScenarioInfo.tutorial and 5000 or 0	-- the number of points awarded for how fast the player completed the operation
	ScoreSummary.TimeStars			= ScenarioInfo.tutorial and 5 or 0		-- stars earned for Time

	ScoreSummary.OverallPoints		= ScenarioInfo.tutorial and 20000 or 0	-- composite total points - sum of all categories + kill bonus (the bonus kicks in only for players who have max stars)
	ScoreSummary.OverallMedals		= ScenarioInfo.tutorial and 5 or 0		-- overall Medals earned

	-- find out how many objectives are complete
	local objectivesCompleted = 0
	if ScenarioInfo.AssignedObjectives then
		for k, objective in ScenarioInfo.AssignedObjectives do
			if objective.Complete then
				objectivesCompleted = objectivesCompleted + 1
			end
		end
	end

	-- find out how well the player did in terms of combat
	local unitsKilled = ArmyBrains[nArmyIndex]:GetArmyStat("Units_Killed", 0.0).Value
	local enemsKilled = ArmyBrains[nArmyIndex]:GetBlueprintStat("Enemies_Killed", categories.ALLUNITS)
	local researchPt1 = ArmyBrains[nArmyIndex]:GetEconomyStored('Research')
	local researchPt2 = ArmyBrains[nArmyIndex]:GetArmyStat("Economy_Income_Research", 0.0).Value

	-- initialize the current value for our four tracked stats
	local CombatValue		= enemsKilled
	local ObjectivesValue	= objectivesCompleted
	local ResearchValue		= ArmyBrains[nArmyIndex]:GetArmyStat("Economy_Research_Learned_Count", 0.0).Value
	local TimeValue			= GetGameTick() * 0.1

	LOG('TIME TRACKING: GetScoreDate: RAW TimeValue:[', TimeValue, ']' )
	LOG('TIME TRACKING: GetScoreDate: ScenarioInfo.CampaignOpeningEndTime:[', ScenarioInfo.CampaignOpeningEndTime, ']' )

	-- if needed, adjust the TimeValue by the duration of the opening NIS or skipped NIS length
	if ScenarioInfo.CampaignOpeningEndTime and ScenarioInfo.CampaignOpeningEndTime > 0 then
		TimeValue = TimeValue - ScenarioInfo.CampaignOpeningEndTime
	end

	if TimeValue <= 0.0 then
		WARN('WARNING: operation is attempting to complete with a negative time value of TimeValue:[', TimeValue, ']')
	end

	LOG('TIME TRACKING: GetScoreDate: ADJUSTED TimeValue:[', TimeValue, ']' )

	-- store the current values for our report
	ScenarioInfo.ScoreResults = {}
	ScenarioInfo.ScoreResults.Tech_Count = ResearchValue
	ScenarioInfo.ScoreResults.Game__Time = TimeValue
	ScenarioInfo.ScoreResults.Enem_Kills = enemsKilled
	ScenarioInfo.ScoreResults.Units_Lost = unitsKilled
	ScenarioInfo.ScoreResults.Objectives = ObjectivesValue
	ScenarioInfo.ScoreResults.ResearchP1 = researchPt1
	ScenarioInfo.ScoreResults.ResearchP2 = researchPt2

	-- early out with an empty ScoreSummary if there is no value for ScenarioInfo.ScoreTuning
	---NOTE: this will be common for maps that are not yet ship-shape - bfricks 11/9/09
	if not ScenarioInfo.ScoreTuningData then
		return ScoreSummary
	end

	-- get a handle to each of the different tuning scales
	local CombatScale		= ScenarioInfo.ScoreTuningData.CombatScale
	local ObjectivesScale	= ScenarioInfo.ScoreTuningData.ObjectivesScale
	local ResearchScale		= ScenarioInfo.ScoreTuningData.ResearchScale
	local TimeScale			= ScenarioInfo.ScoreTuningData.TimeScale
	local XBOXTimeScale		= nil

	-- apply the special case time multiplier
	if IsXbox() or ScenarioInfo.Options.UseGamePad then
		XBOXTimeScale = {}

		for i = 1, table.getn(TimeScale) do
			XBOXTimeScale[i] = TimeScale[i] * nXBOXTimeLevelMult
		end

		ScenarioInfo.ScoreTuningData.XBOXTimeScale = XBOXTimeScale
	end

	-- calculate combat score data
	local combatRet = GetPoints(starLevelIncrement, CombatValue, CombatScale, true)
	ScoreSummary.CombatPoints		= combatRet[1]
	ScoreSummary.CombatStars		= combatRet[2]

	-- calculate objectives score data
	local objectivesRet = GetPoints(starLevelIncrement, ObjectivesValue, ObjectivesScale, true)
	ScoreSummary.ObjectivesPoints	= objectivesRet[1]
	ScoreSummary.ObjectivesStars	= objectivesRet[2]

	-- calculate research score data
	local researchRet = GetPoints(starLevelIncrement, ResearchValue, ResearchScale, true)
	ScoreSummary.ResearchPoints		= researchRet[1]
	ScoreSummary.ResearchStars		= researchRet[2]

	-- calculate time score data
	local timeRet = GetPoints(starLevelIncrement, TimeValue, XBOXTimeScale or TimeScale, false)
	ScoreSummary.TimePoints			= timeRet[1]
	ScoreSummary.TimeStars			= timeRet[2]

	-- if we failed the mission - impose certain contraints automatically
	if not ScenarioInfo.OpVictorious then
		-- there is no time score for failure
		ScoreSummary.TimePoints = 0
		ScoreSummary.TimeStars = 0
	end

	-- calculate our raw points
	local rawTotalPoints = ScoreSummary.TimePoints + ScoreSummary.ObjectivesPoints + ScoreSummary.CombatPoints + ScoreSummary.ResearchPoints

	-- determine our medal count
	if rawTotalPoints >= (starLevelIncrement * 20) then
		ScoreSummary.OverallMedals = 5
	elseif rawTotalPoints >= (starLevelIncrement * 16) then
		ScoreSummary.OverallMedals = 4
	elseif rawTotalPoints >= (starLevelIncrement * 12) then
		ScoreSummary.OverallMedals = 3
	elseif rawTotalPoints >= (starLevelIncrement * 8) then
		ScoreSummary.OverallMedals = 2
	elseif rawTotalPoints >= (starLevelIncrement * 4) then
		ScoreSummary.OverallMedals = 1
	else
		ScoreSummary.OverallMedals = 0
	end

	-- if required, calculate overage bonuses
	local overage = 0
	if ScoreSummary.OverallMedals == 5 then
		local overC = combatRet[3] or 0
		local overO = objectivesRet[3] or 0
		local overR = researchRet[3] or 0
		local overT = timeRet[3] or 0

		local overC_Calc = overageScale_C * overC
		local overO_Calc = overageScale_O * overO
		local overR_Calc = overageScale_R * overR
		local overT_Calc = overageScale_T * overT

		ScenarioInfo.ScoreResults.BONUS_C = overC
		ScenarioInfo.ScoreResults.BONUS_O = overO
		ScenarioInfo.ScoreResults.BONUS_R = overR
		ScenarioInfo.ScoreResults.BONUS_T = overT
		ScenarioInfo.ScoreResults.BONUS_Z_C = overC_Calc
		ScenarioInfo.ScoreResults.BONUS_Z_O = overO_Calc
		ScenarioInfo.ScoreResults.BONUS_Z_R = overR_Calc
		ScenarioInfo.ScoreResults.BONUS_Z_T = overT_Calc

		overage = overC_Calc + overO_Calc +  overR_Calc + overT_Calc
	end

	-- add up the raw points plus the overage bonus
	local difficultyMultiplier = 0.5
	if ScenarioInfo.Options.Difficulty == 2 then
		difficultyMultiplier = 1.0
	elseif ScenarioInfo.Options.Difficulty == 3 then
		difficultyMultiplier = 2.0
	end
	ScoreSummary.OverallPoints = (rawTotalPoints + overage) * difficultyMultiplier

	-- return
	return ScoreSummary
end

---------------------------------------------------------------------
-- GetPoints
-- Used to process a table of scale specific levels and return a points value given for the progress acheived
---------------------------------------------------------------------
function GetPoints(levelIncrement, currentValue, scaleTable, bGreaterThan)
	local points = 0
	local stars = 0
	local overage = 0

	if (levelIncrement > 0) and (currentValue > 0) and scaleTable then
		for k, starLevel in scaleTable do
			local starLevelReached = false
			if bGreaterThan then
				if currentValue >= starLevel then
					-- give full points for every level reached
					points = points + levelIncrement
					starLevelReached = true

					-- and give a star as well
					stars = stars + 1
				end
			else
				if currentValue <= starLevel then
					-- give full points for every level reached
					points = points + levelIncrement
					starLevelReached = true

					-- and give a star as well
					stars = stars + 1
				end
			end

			-- how much of a difference between our current value and the last starLevel we reached?
			local delt = 0

			-- how much of a difference between our incomplete starLevel and the last starLevel we reached?
			local need = 0

			-- if this is the first starLevel check - just use our values as is - other wise look at the difference using the scale
			if k <= 1 then
				delt = currentValue
				need = starLevel
			else
				delt = currentValue - scaleTable[k-1]
				need = starLevel - scaleTable[k-1]
			end

			-- if we havent earned a star - calculate partial points - then we are done, otherwise - determine out possible overage
			if not starLevelReached then
				-- zero out overage, since we didnt earn any
				overage = 0

				-- give partial points for any excess, then break
				if need > 0 then
					points = points + ( levelIncrement * (delt/need) )
				end

				LOG('ScoreSummary: calculating partials: points:[', points, '] delt:[', delt, '] need:[', need, ']')

				break
			else
				-- for increasing scales - the delt will be positive automatically, otherwise - force positive
				if bGreaterThan then
					overage = currentValue - scaleTable[k]
				else
					overage = (currentValue - scaleTable[k]) * -1
				end
			end
		end
	end

	return {points,stars,overage}
end