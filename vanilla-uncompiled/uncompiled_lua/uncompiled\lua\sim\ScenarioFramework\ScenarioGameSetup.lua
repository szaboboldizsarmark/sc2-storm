-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameSetup.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for scenario setup functions.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---------------------------------------------------------------------
-- COMMON FUNCTIONS:
---------------------------------------------------------------------
local SimCamera				= import('/lua/sim/SimCamera.lua').SimCamera
local CameraFadeOut			= import('/lua/sim/ScenarioFramework/ScenarioCinematics.lua').CameraFadeOut
local CameraFadeIn			= import('/lua/sim/ScenarioFramework/ScenarioCinematics.lua').CameraFadeIn
local SetPlayableArea		= import('/lua/sim/ScenarioFramework.lua').SetPlayableArea
local CreateArmyStatTrigger	= import('/lua/sim/ScenarioTriggers.lua').CreateArmyStatTrigger

---------------------------------------------------------------------
-- CAMPAIGN_OnPopulate:
function CAMPAIGN_OnPopulate(tblCameraData)
	LOG('----- CAMPAIGN_OnPopulate: InitializeScenarioArmies.')
	ScenarioUtils.InitializeScenarioArmies()

	LOG('----- CAMPAIGN_OnPopulate: Lock Input, add custom UI load screen, fade to black.')
	LockInput()
	CameraFadeOut(0.0)

	if tblCameraData then
		LOG('----- CAMPAIGN_OnPopulate: Update camera defaults.')
		SimCamera('WorldCamera'):UpdateDefaults(tblCameraData)
	else
		WARN('CAMPAIGN_OnPopulate: no tblCameraData defined.')
	end
end

---------------------------------------------------------------------
-- CAMPAIGN_OnStart:
function CAMPAIGN_OnStart()
	LOG('----- CAMPAIGN_OnStart: Hide non-player Score Displays.')
	for i = 2, table.getn(ArmyBrains) do
		SetArmyShowScore(i, false)
		SetIgnorePlayableRect(i, true)
	end
end
---------------------------------------------------------------------
-- CAMPAIGN_OnInitCamera:
function CAMPAIGN_OnInitCamera(data)
	ForkThread(OnInitCameraThread,data)
end

function OnInitCameraThread(data)
	local funcSetup		= data.funcSetup		-- if valid, the function to be called while the load screen is up
	local funcNIS		= data.funcNIS			-- if valid, the NIS sequence to be launched
	local funcMain		= data.funcMain			-- if valid, the function to be called after the NIS
	local areaStart		= data.areaStart		-- if valid, the area to be used for setting the starting playable area

	if funcSetup then
		LOG('----- CAMPAIGN_OnInitCamera: begin funcSetup.')
		funcSetup()
	else
		WARN('CAMPAIGN_OnInitCamera: no funcSetup defined.')
	end

	-- LoadAllowPlayerReady means that the player can now click to advance into the game because we are done with the loading
	-- Until the user clicks to advance, we will loop here.
	Sync.LoadAllowPlayerReady = true
	while not UIGetTransitionToGame() do
		WaitTicks(1)
	end

	if funcNIS then
		LOG('----- CAMPAIGN_OnInitCamera: begin funcNIS.')
		funcNIS()
	else
		CameraFadeIn(2.0)
		WARN('CAMPAIGN_OnInitCamera: no funcNIS defined. Pass this along to Campaign design - a valid funcNIS must be specified.')
	end

	ScenarioInfo.PropDecayDisabled = false

	if areaStart then
		LOG('----- CAMPAIGN_OnInitCamera: SetPlayableArea:[', areaStart, ']')
		SetPlayableArea(areaStart, false)
	else
		WARN('CAMPAIGN_OnInitCamera: no areaStart defined.')
	end

	if funcMain then
		LOG('----- CAMPAIGN_OnInitCamera: begin funcMain.')
		funcMain()
	else
		WARN('CAMPAIGN_OnInitCamera: no funcMain defined. Pass this along to Campaign design - a valid funcMain must be specified.')
	end

	if ScenarioInfo.Options.NoNIS then
		LOG('----- CAMPAIGN_OnInitCamera: wait 2 seconds, then restore input and the UI.')
		WaitSeconds(2.0)
		UnlockInput()
	else
		LOG('----- CAMPAIGN_OnInitCamera: restore input and the UI.')
		UnlockInput()
	end
	Sync.DeactivateUI = false
end

---------------------------------------------------------------------
function UnlockPlayerResearch(nArmyIndex)
	-- early out with a warning if we do not have ResearchData, or either of the expected unlock lists
	if not ScenarioInfo.ResearchData then
		WARN('WARNING: UnlockPlayerResearch attempting to create a research objective when ScenarioInfo.ResearchData has not been defined, exiting early.')
		return false
	elseif not ScenarioInfo.ResearchData.StandardUnlock then
		WARN('WARNING: UnlockPlayerResearch attempting to create a research objective when ScenarioInfo.ResearchData.StandardUnlock has not been defined, exiting early.')
		return false
	elseif not ScenarioInfo.ResearchData.ObjectiveUnlock then
		WARN('WARNING: UnlockPlayerResearch attempting to create a research objective when ScenarioInfo.ResearchData.ObjectiveUnlock has not been defined, exiting early.')
		return false
	end

	-- unlock the StandardUnlock and ObjectiveUnlock lists of research
	ArmyBrains[nArmyIndex]:ResearchRestrict( ScenarioInfo.ResearchData.StandardUnlock, false )
	ArmyBrains[nArmyIndex]:ResearchRestrict( ScenarioInfo.ResearchData.ObjectiveUnlock, false )

	return true
end

---------------------------------------------------------------------
function SetupPlayerArmy(nArmyIndex, tblTuningData, cbOnAllResearchComplete)
	-- set color
	if tblTuningData.color then
		LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: SetArmyColor:[', tblTuningData.color[1], ', ', tblTuningData.color[2], ', ', tblTuningData.color[3], ']')
		SetArmyColor( nArmyIndex, tblTuningData.color[1], tblTuningData.color[2], tblTuningData.color[3] )
	else
		WARN('SCENARIO TUNING: SetupPlayerArmy: missing color. Default color will be set.')
	end

	-- set unit cap
	if tblTuningData.unitCap then
		---NOTE: for memory - we do a 250 unit cap for the XBOX player - bfricks 1/8/09
		local cap = tblTuningData.unitCap
		if ( IsXbox() or ScenarioInfo.Options.UseGamePad ) and cap > 250 then
			cap = 250
		end

		LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: SetArmyUnitCap:[', cap, ']')
		SetArmyUnitCap(nArmyIndex, cap)
	else
		WARN('SCENARIO TUNING: SetupPlayerArmy: missing unitCap. Default unitCap will be set.')
	end

	-- set starting mass
	local startMass = tblTuningData.mass
	if startMass then
		local defaultMass = ScenarioInfo.Options.InitialMass
		if defaultMass then
			ArmyBrains[nArmyIndex]:TakeResource('MASS', defaultMass)
		end

		if startMass > 0 then
			ArmyBrains[nArmyIndex]:GiveResource('MASS', startMass)
		end

		LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: replace default mass:[', defaultMass, '] with:[', startMass, ']')
	else
		WARN('SCENARIO TUNING: SetupPlayerArmy: missing starting mass allocation. Default mass will be awarded.')
	end

	-- set starting energy
	local startEnergy = tblTuningData.energy
	if startEnergy then
		local defaultEnergy = ScenarioInfo.Options.InitialEnergy
		if defaultEnergy then
			ArmyBrains[nArmyIndex]:TakeResource('ENERGY', defaultEnergy)
		end

		if startEnergy > 0 then
			ArmyBrains[nArmyIndex]:GiveResource('ENERGY', startEnergy)
		end

		LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: replace default energy:[', defaultEnergy, '] with:[', startEnergy, ']')
	else
		WARN('SCENARIO TUNING: SetupPlayerArmy: missing starting energy allocation. Default energy will be awarded.')
	end

	-- set starting research
	local startResearch = tblTuningData.research
	if startResearch then
		local defaultResearch = ScenarioInfo.Options.InitialResearch
		if defaultResearch then
			ArmyBrains[nArmyIndex]:TakeResource('RESEARCH', defaultResearch)
		end

		if startResearch > 0 then
			ArmyBrains[nArmyIndex]:GiveResource('RESEARCH', startResearch)
		end

		LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: replace default research points:[', defaultResearch, '] with:[', startResearch, ']')
	else
		WARN('SCENARIO TUNING: SetupPlayerArmy: missing starting research point allocation. Default research points will be awarded.')
	end

	-- impose research mod
	ScenarioUtils.SetupArmyDifficultyBuffs(nArmyIndex, {'CAMPAIGN_ResearchMod'})

	-- impose campaign specific research-experience progression
	if ResearchExperience and ResearchExperience.LevelMultiplier and ResearchExperience.ExperienceToLevel then
		ResearchExperience.ExperienceToLevel = {}
		ResearchExperience.LevelMultiplier = {}

		ResearchExperience.ExperienceToLevel = {
			25000,			-- 1	original: 5000
			30000,			-- 2	original: 10000
			35000,			-- 3	original: 15000
			40000,			-- 4	original: 20000
			45000,			-- 5	original: 25000
		}

		ResearchExperience.LevelMultiplier = {
			0.0002,			-- 1	original: 0.0008
			0.00015,		-- 2	original: 0.0006
			0.00011,		-- 3	original: 0.0004
			0.00008,		-- 4	original: 0.0003
			0.00005,		-- 5	original: 0.0002
		}
	end

	-- set score data table
	if tblTuningData.scoreData then
		ScenarioInfo.ScoreTuningData = tblTuningData.scoreData

		LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: setting starting score data.')
	end

	-- gather research data
	---NOTE: This entire section for handling player research involves some large tables of data
	---			potentially large enough that it would be good to do this entire process in code.
	---			TAGGED FOR REVIEW - bfricks 10/8/09
	if tblTuningData.opID then
		ScenarioInfo.ResearchData = {}
		ScenarioInfo.ResearchData.StandardUnlock = {}
		ScenarioInfo.ResearchData.ObjectiveUnlock = {}
		ScenarioInfo.ResearchData.TotalUnlockCount = 0
		ScenarioInfo.ResearchData.TotalCompletedCount = 0
		ScenarioInfo.ResearchData.TotalPointCount = 0

		local restrictList = {}
		local completeList = {}
		local unlockedList = {}
		local opID = tblTuningData.opID

		if opID < 101 or opID > 306 then
			error('SCENARIO TUNING: SetupPlayerArmy: invalid opID[', opID, '] specified for army[', nArmyIndex, ']. Pass bug to the campaign design team.')
			return
		end

		-- adjust opID by 1000, so that it matches the compareID format - which is 6 digits in length
		opID = opID * 1000

		for k, tech in ResearchDefinitions do
			local techName = k
			local compareID = tech.CampaignUnlockIndex
			local sorted = false

			if type(compareID) == "number" and compareID > 0 then
				local compareDelta = compareID - opID
				---LOG('SCENARIO TUNING: TESTING RESEARCH LIST:[', k, ']:[', tech, ']:[', compareID, ']:[', opID, ']:[', compareDelta, ']')

				if compareDelta == 1 then
					-- if the compareID is one greater than the adjusted opID - we are a standard unlock
					---LOG('SCENARIO TUNING: TESTING RESEARCH LIST: Add to StandardUnlock:[', techName, ']')
					table.insert(ScenarioInfo.ResearchData.StandardUnlock, techName)

					-- increment the total unlock count by 1
					ScenarioInfo.ResearchData.TotalUnlockCount = ScenarioInfo.ResearchData.TotalUnlockCount + 1

					-- increment the total point count by the cost of this technology
					ScenarioInfo.ResearchData.TotalPointCount = ScenarioInfo.ResearchData.TotalPointCount + tech.COST
				elseif compareDelta == 2 then
					-- if the compareID is two greater than the adjusted opID - we are an objective unlock
					---LOG('SCENARIO TUNING: TESTING RESEARCH LIST: Add to ObjectiveUnlock:[', techName, ']')
					table.insert(ScenarioInfo.ResearchData.ObjectiveUnlock, techName)

					-- increment the total unlock count by 1
					ScenarioInfo.ResearchData.TotalUnlockCount = ScenarioInfo.ResearchData.TotalUnlockCount + 1

					-- increment the total point count by the cost of this technology
					ScenarioInfo.ResearchData.TotalPointCount = ScenarioInfo.ResearchData.TotalPointCount + tech.COST
				elseif compareDelta == 3 then
					-- if the compareID is three greater than the adjusted opID - we are flagged for auto-completion
					---LOG('SCENARIO TUNING: TESTING RESEARCH LIST: Add to completeList:[', techName, ']')
					table.insert(completeList, techName)

					-- increment the total completed count by 1
					ScenarioInfo.ResearchData.TotalCompletedCount = ScenarioInfo.ResearchData.TotalCompletedCount + 1

				elseif compareDelta < 0 and compareDelta > -10000 then
					local alreadyComplete = false
					for i = 1,6 do
						if not alreadyComplete and compareDelta + (i * 1000) == 3 then
							-- if the compareID is three greater than the adjusted compareDelta - we are flagged for auto-completion - because of an earlier op
							---LOG('SCENARIO TUNING: TESTING RESEARCH LIST: Add to completeList:[', techName, ']')
							table.insert(completeList, techName)

							-- increment the total completed count by 1
							ScenarioInfo.ResearchData.TotalCompletedCount = ScenarioInfo.ResearchData.TotalCompletedCount + 1

							alreadyComplete = true
						end
					end

					if not alreadyComplete then
						-- in this situation, we are dealing with technology from an earlier operation - in the same campaign - so auto-unlock
						---LOG('SCENARIO TUNING: TESTING RESEARCH LIST: Add to unlockedList:[', techName, ']')
						table.insert(unlockedList, techName)

						-- increment the total unlock count by 1
						ScenarioInfo.ResearchData.TotalUnlockCount = ScenarioInfo.ResearchData.TotalUnlockCount + 1

						-- increment the total point count by the cost of this technology
						ScenarioInfo.ResearchData.TotalPointCount = ScenarioInfo.ResearchData.TotalPointCount + tech.COST
					end
				end
			end

			---TODO: we should really make a code-side function to auto-restrict research at the start of each operation, however
			---		in the meantime, this will do. - bfricks 6/16/09
			---LOG('SCENARIO TUNING: TESTING RESEARCH LIST: Add to restrictList:[', techName, ']')
			table.insert(restrictList, techName)
		end

		if table.getn(restrictList) > 0 then
			LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: auto restrict all research.')
			ArmyBrains[nArmyIndex]:ResearchRestrict( restrictList, true )
		end

		if table.getn(completeList) > 0 then
			LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: auto complete selected research.')
			ArmyBrains[nArmyIndex]:CompleteResearch( completeList )
		end

		if table.getn(unlockedList) > 0 then
			LOG('SCENARIO TUNING: SetupPlayerArmy[', nArmyIndex, ']: auto unlock selected research.')
			ArmyBrains[nArmyIndex]:ResearchRestrict( unlockedList, false )
		end

		LOG('SCENARIO TUNING: ScenarioInfo.ResearchData.TotalUnlockCount[', ScenarioInfo.ResearchData.TotalUnlockCount, ']')
		LOG('SCENARIO TUNING: ScenarioInfo.ResearchData.TotalCompletedCount[', ScenarioInfo.ResearchData.TotalCompletedCount, ']')
		LOG('SCENARIO TUNING: ScenarioInfo.ResearchData.TotalPointCount[', ScenarioInfo.ResearchData.TotalPointCount, ']')

		-- create a trigger that will fire off when the player has researched all possible research
		CreateArmyStatTrigger(
			function()
				local expectedCap = ScenarioInfo.ResearchData.TotalUnlockCount + ScenarioInfo.ResearchData.TotalCompletedCount
				local measuredCur = ArmyBrains[nArmyIndex]:GetArmyStat("Economy_Research_Learned_Count", 0.0).Value

				LOG('SCENARIO TUNING: ALL RESEARCH COMPELTE: expectedCap[', expectedCap, '] measuredCur[', measuredCur, ']')

				-- flag the army such that they can not store any research points
				ArmyBrains[nArmyIndex]:SetMaxStorage('RESEARCH', 0)

				-- pass bac to the op script, so it can so anything it wants on this event
				if cbOnAllResearchComplete then
					cbOnAllResearchComplete()
				end
			end,
			ArmyBrains[nArmyIndex],
			'PlayerResearchComplete[' .. nArmyIndex .. ']',
			{
				{
					StatType	= 'Economy_Research_Learned_Count',
					CompareType	= 'GreaterThanOrEqual',
					Value		= ScenarioInfo.ResearchData.TotalUnlockCount + ScenarioInfo.ResearchData.TotalCompletedCount,
				}
			}
		)

	else
		WARN('SCENARIO TUNING: SetupPlayerArmy: missing opID. Research will not be restricted, completed or locked.')
	end
end

---------------------------------------------------------------------
function SetupNonPlayerArmy(nArmyIndex, tblTuningData)
	-- set color
	if tblTuningData.color then
		LOG('SCENARIO TUNING: SetupNonPlayerArmy[', nArmyIndex, ']: SetArmyColor:[', tblTuningData.color[1], ', ', tblTuningData.color[2], ', ', tblTuningData.color[3], ']')
		SetArmyColor( nArmyIndex, tblTuningData.color[1], tblTuningData.color[2], tblTuningData.color[3] )
	else
		WARN('SCENARIO TUNING: SetupNonPlayerArmy: missing color. Default color will be set.')
	end

	-- set unit cap
	if tblTuningData.unitCap then
		LOG('SCENARIO TUNING: SetupNonPlayerArmy[', nArmyIndex, ']: SetArmyUnitCap:[', tblTuningData.unitCap, ']')
		SetArmyUnitCap(nArmyIndex, tblTuningData.unitCap)
	else
		WARN('SCENARIO TUNING: SetupNonPlayerArmy: missing unitCap. Default unitCap will be set.')
	end

	-- give starting mass boost
	if tblTuningData.massBoost and tblTuningData.massBoost > 0 then
		LOG('SCENARIO TUNING: SetupNonPlayerArmy[', nArmyIndex, ']: give massBoost:[', tblTuningData.massBoost, ']')
		ArmyBrains[nArmyIndex]:GiveResource('MASS', tblTuningData.massBoost)
	end

	-- give starting energy boost
	if tblTuningData.energyBoost and tblTuningData.energyBoost > 0 then
		LOG('SCENARIO TUNING: SetupNonPlayerArmy[', nArmyIndex, ']: give energyBoost:[', tblTuningData.energyBoost, ']')
		ArmyBrains[nArmyIndex]:GiveResource('ENERGY', tblTuningData.energyBoost)
	end

	-- set global tuning buffs
	if tblTuningData.buffs then
		if ScenarioInfo.Options and ScenarioInfo.Options.Difficulty then
			local buffName = nil
			local diffIndex = ScenarioInfo.Options.Difficulty
			local strDiff = 'INVALID'
			if IsXbox()  or ScenarioInfo.Options.UseGamePad then
				if diffIndex == 1 then
					strDiff = 'XB_EASY'
					buffName = tblTuningData.buffs.XB_EASY
				elseif diffIndex == 2 then
					strDiff = 'XB_NORM'
					buffName = tblTuningData.buffs.XB_NORM
				elseif diffIndex == 3 then
					strDiff = 'XB_HARD'
					buffName = tblTuningData.buffs.XB_HARD
				else
					WARN('WARNING: unexpected diffilculy value:[', diffIndex, '] when attempting to process army:[', nArmyIndex, ']')
				end
			else
				if diffIndex == 1 then
					strDiff = 'PC_EASY'
					buffName = tblTuningData.buffs.PC_EASY
				elseif diffIndex == 2 then
					strDiff = 'PC_NORM'
					buffName = tblTuningData.buffs.PC_NORM
				elseif diffIndex == 3 then
					strDiff = 'PC_HARD'
					buffName = tblTuningData.buffs.PC_HARD
				else
					WARN('WARNING: unexpected diffilculy value:[', diffIndex, '] when attempting to process army:[', nArmyIndex, ']')
				end
			end

			if buffName then
				buffName = 'CAMPAIGN_' .. buffName
				LOG('SCENARIO TUNING: SetupNonPlayerArmy[', nArmyIndex, ']: apply global buff:[', buffName, '] for diffIndex:[', diffIndex, '] strDiff:[', strDiff, ']')
				ScenarioUtils.SetupArmyDifficultyBuffs(nArmyIndex, {buffName})
			else
				LOG('SCENARIO TUNING: SetupNonPlayerArmy[', nArmyIndex, ']: no global buffs required for diffIndex:[', diffIndex, '] strDiff:[', strDiff, ']')
			end
		else
			WARN('WARNING: Game Session has been launched without valid ScenarioInfo.Options and ScenarioInfo.Options.Difficulty!')
		end
	end

	-- set research
	if tblTuningData.completedResearch and table.getn(tblTuningData.completedResearch) > 0 then
		LOG('SCENARIO TUNING: SetupNonPlayerArmy[', nArmyIndex, ']: complete associated research.')
		ArmyBrains[nArmyIndex]:CompleteResearch( tblTuningData.completedResearch )
	end
end

---------------------------------------------------------------------
---NOTE: the unit cap management side of this function is quite arbitrary, potentially we can make this data-driven in the long run
---			for now it was easier to create this catch-all for the smaller armies we dont really care much about other than their color. - bfrick 7/6/09
function SetupGenericArmy(nArmyIndex, tblColorData)
	-- set color
	if tblColorData then
		LOG('SCENARIO TUNING: SetupGenericArmy[', nArmyIndex, ']: SetArmyColor:[', tblColorData[1], ', ', tblColorData[2], ', ', tblColorData[3], ']')
		SetArmyColor( nArmyIndex, tblColorData[1], tblColorData[2], tblColorData[3] )
	else
		WARN('SCENARIO TUNING: SetupGenericArmy: missing color. Default color will be set.')
	end

	-- set values for a warning and max unit count
	local warnCount = 150
	local maxCount = 200

	-- set the unit cap to the maxCount
	SetArmyUnitCap(nArmyIndex, maxCount)

	-- setup an ArmyStat trigger warning
	---NOTE: the intention here is to catch if any generic armies are exceeding warnCount units
	CreateArmyStatTrigger(
		function()
			WARN('GenericArmy[', nArmyIndex,'] has exceeded [', warnCount, '] units - this is potentially problematic, bring to the attention of Campaign Design.')
		end,
		ArmyBrains[nArmyIndex],
		'GenericArmyWaring[' .. nArmyIndex .. ']',
		{
			{
				StatType	= 'Units_Active',
				CompareType	= 'GreaterThanOrEqual',
				Value		= warnCount,
				Category 	= categories.ALLUNITS
			}
		}
	)
end