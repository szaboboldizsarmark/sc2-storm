--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameEvents.lua
--  Author(s): Brian Fricks
--  Summary  : Helper functions for common but very game-specific special case events.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---------------------------------------------------------------------
-- COMMON FUNCTIONS:
---------------------------------------------------------------------
local Entity			= import('/lua/sim/Entity.lua').Entity
local RandomFloat		= import('/lua/system/utilities.lua').GetRandomFloat
local RandomInt			= import('/lua/system/utilities.lua').GetRandomInt
local ForceUnitDeath	= import('/lua/sim/ScenarioFramework.lua').ForceUnitDeath

---------------------------------------------------------------------
function NukePosition(position, nRandomRange, useDecal)
	-- allow the user to simply pass in a marker name
	if type(position) == 'string' then
		position = ScenarioUtils.MarkerToPosition(position)
	end

	if nRandomRange then
		position[1] = position[1] + RandomFloat( (nRandomRange * -1.0), nRandomRange )
		position[3] = position[3] + RandomFloat( (nRandomRange * -1.0), nRandomRange )
	end

	local ent = Entity()
	Warp(ent, position)

	local tempNuke = ent:CreateProjectile('/effects/Entities/UEFNukeEffectController01/UEFNukeEffectController01_proj.bp', 0.0, 0.0, 0.0, nil, nil, nil):SetCollision(false)
	tempNuke.InnerDamage = 99915000
	tempNuke.InnerRadius = 20
	tempNuke.InnerToOuterSegmentCount = 10
	tempNuke.OuterDamage = 0
	tempNuke.OuterRadius = 40
	tempNuke.PulseCount = 10
	tempNuke.PulseDamage = 1000
	tempNuke.StunDuration = 5
	tempNuke.TimeToOuterRadius = 5
	tempNuke.UseNukeDecal = useDecal
	tempNuke:CreateNuclearExplosion()
end

---------------------------------------------------------------------
-- GetSortedUnitsAroundPosition
--		return a sorted list of units for the given brain within radius of the specified position, matching the specified cats
function GetSortedUnitsAroundPosition(position, nRadius, cats, brain)
	-- build a new pos - in case someone has given us a reference that is gibberish on the next tick
	local pos = {}
	if type(position) == 'string' then
		pos = ScenarioUtils.MarkerToPosition(position)
	else
		pos = {position[1], position[2], position[3]}
	end

	return SortEntitiesByDistanceXZ(pos, brain:GetUnitsAroundPoint(cats, pos, nRadius, 'ally'))
end

---------------------------------------------------------------------
-- KillUnitsAroundPosition
--		kill units within range of the specified position for all brains in the specified list of brains
--		allow for ACUs to be excluded
--		NOTE: this function will FORCE the kill, ignoring unit overrides
--
function KillUnitsAroundPosition(position, nRadius, bRestrictACUs, tableBrainList)
	-- build our category filter
	local cats = categories.ALLUNITS
	if bRestrictACUs then
		cats = cats - categories.COMMAND
	end

	for k, brain in tableBrainList do
		local units = GetSortedUnitsAroundPosition(position, nRadius, cats, brain)

		-- start a unit kill thread
		ForkThread(ForceKillUnitsThread, units)
	end
end

---------------------------------------------------------------------
-- DamageUnitsAroundPosition
--		damage units within range of the specified position for all brains in the specified list of brains
--		allow for ACUs to be excluded
--		allow for player damage to be different from all other units
--		NOTE: this function will FORCE the damage, ignoring unit overrides
--
function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	-- build our category filter
	local cats = categories.ALLUNITS
	if bRestrictACUs then
		cats = cats - categories.COMMAND
	end

	for k, brain in tableBrainList do
		local units = GetSortedUnitsAroundPosition(position, nRadius, cats, brain)

		-- apply damage based on if we are the player or not
		---NOTE: this assumes the player is index 1, which should be hard coded  - bfricks 11/15/09
		if brain:GetArmyIndex() == 1 then
			ForkThread(ForceDamageUnitsThread, units, nDamagePlayer)
		else
			ForkThread(ForceDamageUnitsThread, units, nDamageOther)
		end
	end
end

---------------------------------------------------------------------
-- ForceKillUnitsThread
--		given the list of units, kill them all with small duration increments between
--		NOTE: this function will FORCE the damage, ignoring unit overrides
--
function ForceKillUnitsThread(units)
	local countCur = 0
	local countMax = table.getn(units)

	for k, unit in units do
		-- kill the unit
		ForceUnitDeath(unit)

		-- increment the count
		countCur = countCur + 1

		-- make all the kills fit within 3 seconds if possible
		if countMax <= 30 then
			-- for smaller counts - just wait a tick between each kill
			WaitSeconds(0.1)
		elseif countMax <= 110 then
			-- for medium sized groups - spread the load some
			if countCur <= 100 then
				-- kill 5 per tick for 20 ticks
				local checkVal = countCur
				while checkVal > 0 do
					checkVal  = checkVal - 5
				end

				if checkVal == 0 then
					WaitSeconds(0.1)
				end
			else
				-- kill any remaining a tick apart
				WaitSeconds(0.1)
			end
		else
			-- and for very large groups kill 15 per tick
			local checkVal = countCur
			while checkVal > 0 do
				checkVal  = checkVal - 15
			end

			if checkVal == 0 then
				WaitSeconds(0.1)
			end
		end
	end
end

---------------------------------------------------------------------
-- ForceDamageUnitsThread
--		given the list of units, damage them all with small duration increments between
--		two exceptions are handled: units that are not supposed to die and ACUs, are not damaged past 1 health (avoids major headaches)
--		NOTE: this function will FORCE the damage, ignoring unit overrides
--
function ForceDamageUnitsThread(units, nDamageValue)
	local countCur = 0
	local countMax = table.getn(units)

	for k, unit in units do
		if unit and not unit:IsDead() then
			---NOTE: early out for anything flagged as no-cap cost, this is a quick method for ensuring we do not get any stray kills - bfricks 1/18/10
			local bp = unit:GetBlueprint()
			if bp and bp.General and bp.General.CapCost then
				if bp.General.CapCost == 0 then
					return
				end
			end

			local curHealth = unit:GetHealth()
			local adjDamage = nDamageValue
			if adjDamage > curHealth then
				if EntityCategoryContains( categories.COMMAND, unit ) or not unit.CanBeKilled then
					-- if the unit cannot die, or if they are a commander, do not damage them in a way that will kill them
					adjDamage = curHealth - 1
					unit:TakeDamage(unit, adjDamage, 'Damage')
				else
					-- kill the unit
					---NOTE: we do this so that visually the unit deaths look their best in NISs
					---			otherwise things get destroyed from the overkill damage - bfricks 11/15/09
					ForceUnitDeath(unit)
				end
			elseif adjDamage > 0.0 then
				-- damage the unit normally - it should durvive
				unit:TakeDamage(unit, adjDamage, 'Damage')
			end

			-- increment the count
			countCur = countCur + 1

			-- make all the kills fit within 3 seconds if possible
			if countMax <= 30 then
				-- for smaller counts - just wait a tick between each kill
				WaitSeconds(0.1)
			elseif countMax <= 110 then
				-- for medium sized groups - spread the load some
				if countCur <= 100 then
					-- kill 5 per tick for 20 ticks
					local checkVal = countCur
					while checkVal > 0 do
						checkVal  = checkVal - 5
					end

					if checkVal == 0 then
						WaitSeconds(0.1)
					end
				else
					-- kill any remaining a tick apart
					WaitSeconds(0.1)
				end
			else
				-- and for very large groups kill 15 per tick
				local checkVal = countCur
				while checkVal > 0 do
					checkVal  = checkVal - 15
				end

				if checkVal == 0 then
					WaitSeconds(0.1)
				end
			end
		end
	end
end

---------------------------------------------------------------------
function SetupUnitForControlledDeath(unit, callback)
	if not unit then WARN('WARNING: SetupUnitForControlledDeath failed due to an invalid unit - this is likely a major operation error - notify Campaign Design.') return end
	unit:SetReclaimable(false)
	unit:SetCapturable(false)
	unit:SetCanBeKilled(false)

	if not unit.ScenarioUnitData then
		unit.ScenarioUnitData = {}
	end

	unit.ScenarioUnitData.ReadyForControlledDeath = true

	unit.Callbacks.OnReclaimed:Add(
		function(destroyedUnit)
			if destroyedUnit and destroyedUnit.ScenarioUnitData and destroyedUnit.ScenarioUnitData.ReadyForControlledDeath then
				destroyedUnit.ScenarioUnitData.ReadyForControlledDeath = false
				WARN('WARNING: somehow a unit using SetupUnitForControlledDeath has been reclaimed - this should not be possible! - executing as if we were damaged to near zero.')
				callback(destroyedUnit)
			end
		end
   	)
    unit.Callbacks.OnCaptured:Add(
		function(destroyedUnit)
			if destroyedUnit and destroyedUnit.ScenarioUnitData and destroyedUnit.ScenarioUnitData.ReadyForControlledDeath then
				destroyedUnit.ScenarioUnitData.ReadyForControlledDeath = false
				WARN('WARNING: somehow a unit using SetupUnitForControlledDeath has been captured - this should not be possible! - executing as if we were damaged to near zero.')
				callback(destroyedUnit)
			end
		end
   	)

	import('/lua/sim/ScenarioTriggers.lua').CreateUnitHealthRatioTrigger(
		function(destroyedUnit)
			if destroyedUnit and destroyedUnit.ScenarioUnitData and destroyedUnit.ScenarioUnitData.ReadyForControlledDeath then
				destroyedUnit.ScenarioUnitData.ReadyForControlledDeath = false
				callback(destroyedUnit)
			end
		end,
		unit,
		0.01,
		true,
		true
	)
end

---------------------------------------------------------------------
function AwardBonusResearchPoints(numPoints, nArmyIndex, delay, bTechAward)
	-- early out if the operation is over
	if ScenarioInfo.OpEnded then
		return
	end

	ForkThread(
		function()
			if delay then
				WaitSeconds(delay)
			end

			-- early out if the operation is over
			if ScenarioInfo.OpEnded then
				return
			end

			-- and further delay if we are in the middle of an NIS
			while ScenarioInfo.OpNISActive do
				WaitTicks(1)
			end

		    if(not Sync.PrintText) then
		        Sync.PrintText = {}
		    end

			if numPoints < 2 then
				WARN('WARNINIG: research point reward set to only a single point- why? really? - its fixed to 2 minimum now.')
				numPoints = 2
			end

			local strText

			-- Is this a tech cache award?
			if bTechAward then
				strText =  LOC('<LOC SCENARIO_0610>Tech Cache Acquired: ') .. numPoints .. LOC('<LOC SCENARIO_0129> Points!')
			else
				strText = LOC('<LOC SCENARIO_0128>Research Reward: ') .. numPoints .. LOC('<LOC SCENARIO_0129> Points!')
			end


			LOG('RESEARCH POINT REWARD: Show Text: [', strText, ']')

			local data = {
				text = strText,
				size = 22,
				color = 'ffffffff',
				duration = 4.0,
				location = 'center'
			}

						table.insert(Sync.PrintText, data)

			---NOTE: adding the sound event for research points awarded - bfricks 12/6/09

			-- Tech Cache or Research Reward?
			if bTechAward then
				CreateSimSyncSound( Sound{ Bank = 'SC2', Cue = 'Interface/snd_UI_Tech_Cache' } )
			else
				CreateSimSyncSound( Sound{ Bank = 'SC2', Cue = 'Interface/snd_UI_Award_research' } )
			end

			-- small cosmetic delay so the eye can see the text and then the boost
			WaitSeconds(0.4)

			LOG('RESEARCH POINT REWARD: Give Points: [', numPoints, ']')

			-- award the points
			ArmyBrains[nArmyIndex]:GiveResource('RESEARCH', numPoints)


		end
	)
end

---------------------------------------------------------------------
function AddResearchNames()
	-- set the tracking string value to an easy to identify invalid state
	local researchNames = 'INVALID RESEARCH DATA'

	if ScenarioInfo and ScenarioInfo.ResearchData and ScenarioInfo.ResearchData.ObjectiveUnlock and ScenarioInfo.ResearchData.ObjectiveUnlock then
		-- since we should be valid, reset our tracking string
		researchNames = ''

		-- using our stored research data, build the list of objective tech names
		for k, tech in ScenarioInfo.ResearchData.ObjectiveUnlock do
			local screenName = ResearchDefinitions[tech] and ResearchDefinitions[tech].NAME or "INVALID"

			researchNames = researchNames ..  "        " .. screenName .. "\n"
		end
	else
		WARN('WARNING: AddResearchNames() was unable to fetch research data from ScenarioInfo - this should go to Campaign Design.')
	end

	return researchNames
end

---------------------------------------------------------------------
function AddResearchAwardString(numPoints)
	-- set the tracking string value to an easy to identify invalid state
	local awardString = LOC('<LOC SCENARIO_0130> (Research Reward: ') .. numPoints .. ' Points )'

	return awardString
end

---------------------------------------------------------------------
function SimulateCampaignResearchUnlock(nArmyIndex, opID)
	local restrictList = {}
	local completeList = {}
	local unlockedList = {}
	local objectiveList = {}

	-- adjust opID by 1000, so that it matches the compareID format - which is 6 digits in length
	opID = opID * 1000

	for k, tech in ResearchDefinitions do
		local techName = k
		local compareID = tech.CampaignUnlockIndex

		if type(compareID) == "number" and compareID > 0 then
			local compareDelta = compareID - opID
			if compareDelta == 1 then
				table.insert(unlockedList, techName)
			elseif compareDelta == 2 then
				table.insert(objectiveList, techName)
			elseif compareDelta == 3 then
				table.insert(completeList, techName)
			elseif compareDelta < 0 and compareDelta > -10000 then
				local alreadyComplete = false
				for i = 1,6 do
					if not alreadyComplete and compareDelta + (i * 1000) == 3 then
						table.insert(completeList, techName)
						alreadyComplete = true
					end
				end

				if not alreadyComplete then
					table.insert(unlockedList, techName)
				end
			end
		end
		table.insert(restrictList, techName)
	end

	if table.getn(restrictList) > 0 then
		ArmyBrains[nArmyIndex]:ResearchRestrict( restrictList, true )
	end

	if table.getn(objectiveList) > 0 then
		ArmyBrains[nArmyIndex]:ResearchRestrict( objectiveList, false )
	end

	if table.getn(completeList) > 0 then
		ArmyBrains[nArmyIndex]:CompleteResearch( completeList )
	end

	if table.getn(unlockedList) > 0 then
		ArmyBrains[nArmyIndex]:ResearchRestrict( unlockedList, false )
	end

	local totalUNLOCK = table.getn(objectiveList) + table.getn(unlockedList) + table.getn(completeList)
	local totalCOMPLETE = table.getn(completeList)

	LOG('REPORTING:[', opID, '] totalUNLOCK:[', totalUNLOCK, '] totalCOMPLETE:[', totalCOMPLETE, ']')

	return objectiveList
end