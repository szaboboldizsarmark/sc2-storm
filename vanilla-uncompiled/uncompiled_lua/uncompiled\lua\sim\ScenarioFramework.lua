-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework.lua
--  Author(s):  John Comes, Drew Staltman
--  Summary  :  Functions for use in the Operations.
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local TriggerFile		= import('/lua/sim/ScenarioTriggers.lua')
local ScenarioUtils		= import('/lua/sim/ScenarioUtilities.lua')

---------------------------------------------------------------------
-- Sets the playable area for an operation to rect size.
-- this function allows you to use ScenarioUtilities function AreaToRect for the rectangle.
-- the value for rect can be either an Area (string) or a rectangle.
---------------------------------------------------------------------
function SetPlayableArea(rect)
	if type(rect) == 'string' then
		rect = ScenarioUtils.AreaToRect(rect)
	end

	local x0 = rect.x0 - math.mod(rect.x0 , 4)
	local y0 = rect.y0 - math.mod(rect.y0 , 4)
	local x1 = rect.x1 - math.mod(rect.x1, 4)
	local y1 = rect.y1 - math.mod(rect.y1, 4)

	LOG(string.format('Debug: SetPlayableArea before round : %s,%s %s,%s',rect.x0,rect.y0,rect.x1,rect.y1))
	LOG(string.format('Debug: SetPlayableArea after round : %s,%s %s,%s',x0,y0,x1,y1))

	ScenarioInfo.MapData.PlayableRect = {x0,y0,x1,y1}
	rect.x0 = x0
	rect.x1 = x1
	rect.y0 = y0
	rect.y1 = y1

	SetPlayableRect( x0, y0, x1, y1 )
	import('/lua/SimSync.lua').SyncPlayableRect(rect)
end

---------------------------------------------------------------------
-- Returns the number of <cat> units in <area> belonging to <brain>
---DEV NOTE: This was used once in FA to check to see if any units were present in a town
---					after a map expansion had occured - if the check returned true, dialog
---					and a special scripted event would occur. - bfricks 1/5/09
---------------------------------------------------------------------
function NumCatUnitsInArea(cat, area, brain)
	if type(area) == 'string' then
		area = ScenarioUtils.AreaToRect(area)
	end
	local entities = GetUnitsInRect(area)
	local result = 0
	if entities then
		local filteredList = EntityCategoryFilterDown(cat, entities)

		for k, v in filteredList do
			if(v:GetAIBrain() == brain) then
				result = result + 1
			end
		end
	end

	return result
end

---------------------------------------------------------------------
-- Returns the units in <area> of <cat> belonging to <brain>
---DEV NOTE: GetCatUnitsInArea - bfricks 1/5/09
---					This was used often in FA to see if certain units were present
---					in an area as a part of a scripted attack or other action.
---					In some cases NumCatUnitsInArea might have been preferable.
---------------------------------------------------------------------
function GetCatUnitsInArea(cat, area, brain)
	if type(area) == 'string' then
		area = ScenarioUtils.AreaToRect(area)
	end
	local entities = GetUnitsInRect(area)
	local result = {}
	if entities then
		local filteredList = EntityCategoryFilterDown(cat, entities)

		for k, v in filteredList do
			if(v:GetAIBrain() == brain) then
				table.insert(result, v)
			end
		end
	end

	return result
end

---------------------------------------------------------------------
-- Creates a visible area for <vizArmy> at <vizLocation> of <vizRadius> size.
-- If vizLifetime is 0, the entity lasts forever.  Otherwise for <vizLifetime> seconds.
-- Function returns an entitiy so you can destroy it later if you want
---DEV NOTE: CreateVisibleAreaLocation is used during NIS's and other points to
---					provide intel previews of locations. - bfricks 1/5/09
---------------------------------------------------------------------
function CreateVisibleAreaLocation(vizRadius, vizLocation, vizLifetime, vizArmy)
	if type(vizLocation) == 'string' then
		vizLocation = ScenarioUtils.MarkerToPosition(vizLocation)
	end
	local spec = {
		X = vizLocation[1],
		Z = vizLocation[3],
		Radius = vizRadius,
		LifeTime = vizLifetime,
		Army = vizArmy:GetArmyIndex(),
	}
	local ent = import('/lua/sim/VizMarker.lua').VizMarker(spec)
	return ent
end

---------------------------------------------------------------------
-- Creates an intel radius of the specified type at the specified location for the specified army for the specified lifetime
-- if no intelLifetime is specified - it lasts forever
-- if a string is passed in for intelLocation, it will be interpreted as a marker
---DEV NOTE: adding this function to support scenarios that need custom intel handling. - bfricks 5/20/09
---------------------------------------------------------------------
function CreateIntelAtLocation(intelRadius, intelLocation, armyIndex, strIntelType, intelLifetime)
	if type(intelLocation) == 'string' then
		intelLocation = ScenarioUtils.MarkerToPosition(intelLocation)
	end

	local spec = {
		X = intelLocation[1],
		Z = intelLocation[3],
		Radius = intelRadius,
		LifeTime = intelLifetime or -1,
		Army = armyIndex,
		ExclusiveIntelType = strIntelType,
	}
	local ent = import('/lua/sim/VizMarker.lua').VizMarker(spec)
	return ent
end

---------------------------------------------------------------------
---DEV NOTE: ClearIntel is used to remove any intel provided through
---					the natural execution of a NIS - the concept being
---					that it was not intended for the player to have this
---					knowledge yet. - bfricks 1/5/09
---------------------------------------------------------------------
function ClearIntel(position, radius)
	local minX = position[1] - radius
	local maxX = position[1] + radius
	local minZ = position[3] - radius
	local maxZ = position[3] + radius
	FlushIntelInRect( minX, minZ, maxX, maxZ )
end

---------------------------------------------------------------------
-- BlockOGrids
---NOTE: now that we actually have more than one use for this moderate-hack, these names should be revised after SC2 - bfricks 12/11/09
---			UPDATE: we have still found a need for this system - but it is wildly awkward - so it needs a revision post SC2 - bfricks 1/27/10
---------------------------------------------------------------------
function BlockOGrids(chain,strArmyName,largeChain)
	local blockerList = {}

	if chain then
		if type(chain) == 'string' then
			chain = ScenarioUtils.ChainToPositions(chain)
		end

		-- for every position in this chain - create an o-grid blocker, and add it to a list stored on the parent
		for k, pos in chain do
			---local blocker = CreatePropHPR('/props/Gameplay/ogrid_blocker_prop.bp', pos[1], pos[2], pos[3],  0, 0, 0)
			local blocker = CreateUnitHPR('scb9999', strArmyName, pos[1], pos[2], pos[3],  0, 0, 0)
			ProtectUnit(blocker)
			table.insert(blockerList,blocker)
		end
	end

	---NOTE: largeChain is for a large scale o-grid blockers that are 9 x 9 - bfricks 1/27/10
	if largeChain then
		if type(largeChain) == 'string' then
			largeChain = ScenarioUtils.ChainToPositions(largeChain)
		end

		-- for every position in this chain - create an o-grid blocker, and add it to a list stored on the parent
		for k, pos in largeChain do
			---local blocker = CreatePropHPR('/props/Gameplay/ogrid_blocker_prop.bp', pos[1], pos[2], pos[3],  0, 0, 0)
			local blocker = CreateUnitHPR('scb9998', strArmyName, pos[1], pos[2], pos[3],  0, 0, 0)
			ProtectUnit(blocker)
			table.insert(blockerList,blocker)
		end
	end

	return blockerList
end

---------------------------------------------------------------------
-- CreateOGridBlockers
---NOTE: now that we actually have more than one use for this moderate-hack, these names should be revised after SC2 - bfricks 12/11/09
---			UPDATE: we have still found a need for this system - but it is wildly awkward - so it needs a revision post SC2 - bfricks 1/27/10
---------------------------------------------------------------------
function CreateOGridBlockers(parentUnit,chain,strArmyName,largeChain)
	if parentUnit and not parentUnit:IsDead() then
		-- if required, append the parent with a table for storing scenario unit data
		if not parentUnit.ScenarioUnitData then
			parentUnit.ScenarioUnitData = {}
		end
		parentUnit.ScenarioUnitData.OGRIDBlockers = BlockOGrids(chain,strArmyName,largeChain)

		-- add a destroyed trigger to the parent - when it dies, the blockers go away too
		TriggerFile.CreateUnitDestroyedTrigger(
			function(unit)
				if unit and unit.ScenarioUnitData and unit.ScenarioUnitData.OGRIDBlockers then
					for k, blocker in unit.ScenarioUnitData.OGRIDBlockers do
						blocker:Destroy()
					end
				end
			end,
			parentUnit
		)

	else
		WARN('WARNING: CreateOGridBlockers has been given an invalid or dead unit - bring to Campaign design.')
	end
end

---------------------------------------------------------------------
-- Build restriction notification for the UI
---------------------------------------------------------------------
function AddRestriction(army, categories)
	--LOG(repr(categories))
	import('/lua/sim/SimUIState.lua').SaveTechRestriction(categories)
	AddBuildRestriction(army, categories)
end

---------------------------------------------------------------------
function RemoveRestriction(army, categories, isSilent)
	--LOG(repr(categories))
	import('/lua/sim/SimUIState.lua').SaveTechAllowance(categories)
	if not isSilent then
		if not Sync.NewTech then Sync.NewTech = {} end
		table.insert(Sync.NewTech, EntityCategoryGetUnitList(categories))
	end
	RemoveBuildRestriction(army, categories)
end

---------------------------------------------------------------------
-- PROTECT:
---NOTE: prevent damage, death, reclaim, capture, etc... - bfricks 6/6/09
---------------------------------------------------------------------
function ProtectUnit(unit)
	if unit and not unit:IsDead() then
		if unit.OnTransport then
			WARN('WARNING: ProtectUnit is being called on a unit that is still on a transport. This flagging will be partially unset on drop off. Pass along to Campaign Design.')
		end
		unit:SetDoNotTarget(true)
		unit:SetCanBeKilled(false)
		unit:SetCanTakeDamage(false)
		unit:SetReclaimable(false)
		unit:SetCapturable(false)
	end
end
function ProtectGroup(group)
	for k, unit in group do
		ProtectUnit(unit)
	end
end

---------------------------------------------------------------------
-- UNPROTECT:
---NOTE: allow damage, death, reclaim, capture, etc... - bfricks 6/12/09
---------------------------------------------------------------------
function UnProtectUnit(unit)
	if unit and not unit:IsDead() then
		unit:SetDoNotTarget(false)
		unit:SetCanBeKilled(true)
		unit:SetCanTakeDamage(true)
		unit:SetReclaimable(true)
		unit:SetCapturable(true)
	end
end
function UnProtectGroup(group)
	for k, unit in group do
		UnProtectUnit(unit)
	end
end

---------------------------------------------------------------------
-- ALLOW DEATH:
---NOTE: allow damage and death. - bfricks 6/6/09
---NOTE: In looking over the usage cases - I am not seeing this as very critical
---			but conceptually, the idea is to use UnProtect with units most units
---			and use AllowUnitDeath with special cases that need to be restricted
---			from reclaim and capture. - bfricks 6/12/09
---------------------------------------------------------------------
function AllowUnitDeath(unit)
	if unit and not unit:IsDead() then
		unit:SetDoNotTarget(false)
		unit:SetCanTakeDamage(true)
		unit:SetCanBeKilled(true)
	end
end
function AllowGroupDeath(group)
	for k, unit in group do
		AllowUnitDeath(unit)
	end
end

---------------------------------------------------------------------
-- RESTRICT DEATH:
---NOTE: allow damage but prevent death. ***USE WITH CAUTION*** - bfricks 6/6/09
---			This is both heavy handed, and only to be used in rare cases where we want the threat of damage
---			but not the threat of complete death. - bfricks 6/6/09
---NOTE: In the few cases where this has been used, the un-restriction process looked like this:
---			1) ScenarioFramework.PauseUnitDeath(ScenarioInfo.PLAYER_CDR)
---			2) ScenarioFramework.CreateUnitDeathTrigger( PlayerDeath, ScenarioInfo.PLAYER_CDR)
---------------------------------------------------------------------
function RestrictUnitDeath(unit)
	if unit and not unit:IsDead() then
		unit.OnKilled = nil
		unit.OnDamage = RestrictDeathDamageOverride
		unit:SetCanBeKilled(false)
	end
end
function RestrictGroupDeath(group)
	for k, unit in group do
		RestrictUnitDeath(unit)
	end
end
function RestrictDeathDamageOverride(self, instigator, amount, vector, damageType)
	if self.CanTakeDamage then
		self:AdjustHealth(instigator, -amount)
	end
end

---------------------------------------------------------------------
-- FORCE DEATH:
---NOTE: force death using the IssueKillSelf command. - bfricks 6/6/09
---------------------------------------------------------------------
function ForceUnitDeath(unit)
	if unit and not unit:IsDead() then
		AllowUnitDeath(unit)
		IssueClearCommands({unit})
		IssueKillSelf( {unit})
	end
end
function ForceGroupDeath(group)
	AllowGroupDeath(group)
	IssueClearCommands(group)
	IssueKillSelf(group)
end

---------------------------------------------------------------------
-- Destroy:
---NOTE: directly destroy - use for special cases only. - bfricks 6/6/09
---------------------------------------------------------------------
function DestroyUnit(unit)
	if unit and not unit:IsDead() then
		unit:Destroy()
	end
end
function DestroyGroup(group)
	for k, unit in group do
		DestroyUnit(unit)
	end
end

----------------------------------------------------------------------
-- Experience:
-- Sets a units ability to gain experience on or off - Sorian 10/14/2009
----------------------------------------------------------------------
function SetUnitExperienceDisabled(unit, bool)
   	if unit and not unit:IsDead() then
		unit:SetExperienceDisabled(bool)
	end
end
function SetGroupExperienceDisabled(group, bool)
	for k, unit in group do
		SetUnitExperienceDisabled(unit, bool)
	end
end

----------------------------------------------------------------------
-- Veterancy:
-- Sets veternacy level - Mike R. 10/14/2009
----------------------------------------------------------------------
function SetUnitVeterancyLevel(unit, level)
   	if unit and not unit:IsDead() then
		unit:SetVeterancy(level)
	end
end

function SetGroupVeterancyLevel(group, level)
	for k, unit in group do
		SetUnitVeterancyLevel(unit, level)
	end
end

function SetPlatoonVeterancyLevel(platoon, level)
	for k, unit in platoon:GetPlatoonUnits() do
		SetUnitVeterancyLevel(unit, level)
	end
end

---------------------------------------------------------------------
---DEV NOTE: GiveUnitToArmy is a primary method for passing placed units from a civilian
---					or neutral army to the player - in some cases it is used for more general
---					situations. - bfricks 1/5/09
---
---CRITICAL NOTE: this function returns a handle to the NEW unit, in code this literally
---					deletes the old unit, and gives you a new handle to the new unit in the new army
---				IF there are any special settings applied to the unit - like damage restrictions
---					or triggers, they need to be recreated. - bfricks 3/19/09
---------------------------------------------------------------------
function GiveUnitToArmy(unit, newArmyIndex)
	if not unit then
		-- early out
		LOG('DEBUG: GiveUnitToArmy: is attempting to operate on an invalid value for the passed in unit.')
		return nil
	elseif unit:IsDead() then
		-- early out
		LOG('DEBUG: GiveUnitToArmy is attempting to operate on a dead passed in unit.')
		return nil
	end

	-- We need the brain to ignore army cap when transfering the unit
	-- do all necessary steps to set brain to ignore, then un-ignore if necessary the unit cap
	local newBrain = ArmyBrains[newArmyIndex]
	SetIgnoreArmyUnitCap(newArmyIndex, true)

	local unitToDestroy = nil

	-- if the unit is building something, destroy what it is trying to build so
	-- we dont end up with half-built original-army stuff laying around.
	if unit and unit.UnitBeingBuilt and not unit.UnitBeingBuilt:IsDead() and unit.UnitBeingBuilt:GetFractionComplete() != 1 then
		unitToDestroy = unit.UnitBeingBuilt
	end

	local newUnit = ChangeUnitArmy(unit, newArmyIndex)

	if unitToDestroy then
		unitToDestroy:Destroy()
	end

	if not newBrain.IgnoreArmyCaps then
		SetIgnoreArmyUnitCap(newArmyIndex, false)
	end
	return newUnit
end

---------------------------------------------------------------------
-- GiveGroupToArmy is giving a group of units to a new army.
--
-- group: 			The Group that is to be given to the new army
-- newArmyIndex: 	The index for the new army
--
---CRITICAL NOTE: this function returns a handle to the NEW group, in code for each unit, this literally
---					deletes the old unit, and gives you a new handle to the new unit in the new army
---				IF there are any special settings applied to the unit - like damage restrictions
---					or triggers, they need to be recreated. - bfricks 3/19/09
---------------------------------------------------------------------
function GiveGroupToArmy(group, newArmyIndex)
	-- We need the brain to ignore army cap when transfering the unit
	-- do all necessary steps to set brain to ignore, then un-ignore if necessary the unit cap
	local newBrain = ArmyBrains[newArmyIndex]
	SetIgnoreArmyUnitCap(newArmyIndex, true)
	local newGroup = {}
	for k, unit in group do

		local unitToDestroy = nil

		-- if the unit is building something, destroy what it is trying to build so
		-- we dont end up with half-built original-army stuff laying around.
		if unit.UnitBeingBuilt and not unit.UnitBeingBuilt:IsDead() and unit.UnitBeingBuilt:GetFractionComplete() != 1 then
			unitToDestroy = unit.UnitBeingBuilt
		end

		local newUnit = ChangeUnitArmy(unit, newArmyIndex)

		if unitToDestroy then
			unitToDestroy:Destroy()
		end

		table.insert(newGroup, newUnit)
		if not newBrain.IgnoreArmyCaps then
			SetIgnoreArmyUnitCap(newArmyIndex, false)
		end
	end
	return newGroup
end

---------------------------------------------------------------------
-- orders group to patrol a chain
---DEV NOTE: GroupPatrolChain is used extensively as a primary tool
---					for campaign scripted unit movement. Depending on the
---					organization of units in an operation, either this function
---					or PlatoonPatrolChain would be used. - bfricks 1/18/09
---------------------------------------------------------------------
function GroupPatrolChain(group, chain)
	for k,v in ScenarioUtils.ChainToPositions(chain) do
		IssuePatrol( group, v )
	end
end

---------------------------------------------------------------------
-- orders group to patrol a route
---DEV NOTE: GroupPatrolRoute is used extensively as a primary tool
---					for campaign scripted unit movement. Depending on the
---					organization of units in an operation, either this function
---					or PlatoonPatrolRoute would be used. - bfricks 1/18/09
---------------------------------------------------------------------
function GroupPatrolRoute(group, route)
	for k,v in route do
		if type(v) == 'string' then
			IssuePatrol(group, ScenarioUtils.MarkerToPosition(v))
		else
			IssuePatrol(group, v)
		end
	end
end

---------------------------------------------------------------------
-- orders a platoon to patrol all teh points in a chain
---DEV NOTE: PlatoonPatrolChain is used extensively as a primary tool
---					for campaign scripted unit movement. Depending on the
---					organization of units in an operation, either this function
---					or GroupPatrolChain would be used. - bfricks 1/18/09
---------------------------------------------------------------------
function PlatoonPatrolChain(platoon, chain, squad)
	for k,v in ScenarioUtils.ChainToPositions(chain) do
		if squad then
			platoon:Patrol(v, squad)
		else
			platoon:Patrol(v)
		end
	end
end

---------------------------------------------------------------------
-- commands platoon to patrol a route
---DEV NOTE: PlatoonPatrolRoute was used in a few places in FA for
---					basic patrol instructions for several platoons. Depending on the
---					organization of units in an operation, either this function
---					or GroupPatrolRoute would be used. - bfricks 1/18/09
---------------------------------------------------------------------
function PlatoonPatrolRoute(platoon, route, squad)
	for k,v in route do
		if type(v) == 'string' then
			if squad then
				platoon:Patrol(ScenarioUtils.MarkerToPosition(v), squad)
			else
				platoon:Patrol(ScenarioUtils.MarkerToPosition(v))
			end
		else
			if squad then
				platoon:Patrol(v, squad)
			else
				platoon:Patrol(v)
			end
		end
	end
end

---------------------------------------------------------------------
-- Orders a platoon to attack move through a chain
---DEV NOTE: PlatoonAttackChain was used in a few places in FA to get
---					more specific results. - bfricks 1/5/09
---------------------------------------------------------------------
function PlatoonAttackChain(platoon, chain, squad)
	local cmd = false
	for k,v in ScenarioUtils.ChainToPositions(chain) do
		if squad then
			cmd = platoon:AggressiveMoveToLocation(v,squad)
		else
			cmd = platoon:AggressiveMoveToLocation(v)
		end
	end
	return cmd
end

---------------------------------------------------------------------
-- Orders a platoon to loop through a chain, using move to commands.
---DEV NOTE: Unused in FA, but a need for it has arisen in SC2. -gregr 3/19/2009 10:01:09 AM
---------------------------------------------------------------------
function PlatoonMoveChain( platoon, chain, squad )
    for k,v in ScenarioUtils.ChainToPositions(chain) do
        if squad then
            platoon:MoveToLocation(v, false, squad)
        else
            platoon:MoveToLocation(v, false)
        end
    end
end

---------------------------------------------------------------------
-- returns a list of positions around the passed in unit
---------------------------------------------------------------------
function GetPatrolChainAroundUnit(unit, radius)
	-- Creates a table of 9 locations around and at, a passed in unit.

	local unitLoc = unit:GetPosition()
	local patrolChain = {}

	local function AddOffsetPos(pos, xOffset, zOffset)
		local tempPos = {0,0,0,}
		tempPos[1] = pos[1] + xOffset
		tempPos[3] = pos[3] + zOffset
		tempPos[2] = GetSurfaceHeight(tempPos[1], tempPos[3])

		table.insert(patrolChain, tempPos)
	end

	AddOffsetPos(unitLoc, 0.0, 				0.0)
	AddOffsetPos(unitLoc, -1.0 * radius,	0.0)
	AddOffsetPos(unitLoc, -0.7 * radius,	-0.7 * radius)
	AddOffsetPos(unitLoc, 0.0, 				-1.0 * radius)
	AddOffsetPos(unitLoc, 0.7 * radius, 	-0.7 * radius)
	AddOffsetPos(unitLoc, 1.0 * radius, 	0.0)
	AddOffsetPos(unitLoc, 0.7 * radius, 	0.7 * radius)
	AddOffsetPos(unitLoc, 0.0, 				1.0 * radius)
	AddOffsetPos(unitLoc, -0.7 * radius, 	0.7 * radius)

	-- return the assembled table of locations.
	return patrolChain
end

---------------------------------------------------------------------
-- returns the number of storage slots a group of units will take up.
---------------------------------------------------------------------
function GetNumSlotsRequired(units)
    local slotsNeeded = 0
    for k, v in units do
		if v and not v:IsDead() then
        	if EntityCategoryContains( categories.TRANSPORTATION, v ) then
        	    continue
        	end
        	slotsNeeded = slotsNeeded + v:GetBlueprint().Transport.StorageSize
		end
    end
    return slotsNeeded
end

--*******************************************************************
-- TRIGGER FUNCTIONS:
--*******************************************************************
function CreateAreaTrigger( callbackFunction, rectangle, category, onceOnly, invert, aiBrain, number, requireBuilt)
	return TriggerFile.CreateAreaTrigger(callbackFunction, rectangle, category, onceOnly, invert, aiBrain, number, requireBuilt)
end
function CreateMultipleAreaTrigger(callbackFunction, rectangleTable, category, onceOnly, invert, aiBrain, number, requireBuilt)
	return TriggerFile.CreateMultipleAreaTrigger(callbackFunction, rectangleTable, category, onceOnly, invert, aiBrain, number, requireBuilt)
end
function CreateMultipleBrainAreaTrigger(callbackFunction, rectangle, category, onceOnly, invert, brains, number, requireBuilt)
    return TriggerFile.CreateMultipleBrainAreaTrigger(callbackFunction, rectangle, category, onceOnly, invert, brains, number, requireBuilt)
end
function CreateTimerTrigger( cb, seconds, displayBool)
	return TriggerFile.CreateTimerTrigger(cb, seconds, displayBool)
end
function CreateUnitDamagedTrigger( callbackFunction, unit, dealtDamageGreaterThan, damagedByType, oneShot )
	TriggerFile.CreateUnitDamagedTrigger( callbackFunction, unit, dealtDamageGreaterThan, damagedByType, oneShot )
end
function CreateUnitHealthRatioTrigger( callbackFunction, unit, healthRatio, bLessThan, oneShot )
	TriggerFile.CreateUnitHealthRatioTrigger( callbackFunction, unit, healthRatio, bLessThan, oneShot )
end
function CreateUnitPercentageBuiltTrigger(callbackFunction, aiBrain, category, percent)
	TriggerFile.CreateUnitPercentageBuiltTrigger(callbackFunction, aiBrain, category, percent)
end
function CreateUnitDeathTrigger( cb, unit, camera )
	---NOTE: for the purposes of SC2 development - all death triggers will be treated identically to a destroyed trigger
	---			going forward (past SC2) we will depricate the distinction between these two concepts and only use the destroyed context - bfricks 11/14/09
	TriggerFile.CreateUnitDestroyedTrigger(cb, unit)
end
function CreateUnitResurrectedTrigger( cb, unit )
	TriggerFile.CreateUnitResurrectedTrigger(cb, unit)
end
function CreateUnitKilledUnitTrigger( cb, unit )
	TriggerFile.CreateUnitKilledUnitTrigger(cb, unit)
end
function CreateUnitDestroyedTrigger( cb, unit )
	TriggerFile.CreateUnitDestroyedTrigger(cb, unit)
end
function CreateUnitBuiltTrigger( cb, unit, category )
	TriggerFile.CreateUnitBuiltTrigger( cb, unit, category )
end
function CreateUnitCapturedTrigger( cbOldUnit, cbNewUnit, unit )
	TriggerFile.CreateUnitCapturedTrigger( cbOldUnit, cbNewUnit, unit )
end
function CreateUnitSelectedTrigger( cb, unit )
	TriggerFile.CreateUnitSelectedTrigger( cb, unit )
end
function CreateUnitStartBeingCapturedTrigger( cb, unit )
	TriggerFile.CreateUnitStartBeingCapturedTrigger( cb, unit )
end
function CreateUnitStopBeingCapturedTrigger( cb, unit )
	TriggerFile.CreateUnitStopBeingCapturedTrigger( cb, unit )
end
function CreateUnitFailedBeingCapturedTrigger( cb, unit )
	TriggerFile.CreateUnitFailedBeingCapturedTrigger( cb, unit )
end
function CreateUnitStartCaptureTrigger( cb, unit )
	TriggerFile.CreateUnitStartCaptureTrigger( cb, unit )
end
function CreateUnitStopCaptureTrigger( cb, unit )
	TriggerFile.CreateUnitStopCaptureTrigger( cb, unit )
end
function CreateUnitFailedCaptureTrigger( cb, unit )
	TriggerFile.CreateUnitFailedCaptureTrigger( cb, unit )
end
function CreateUnitReclaimedTrigger( cb, unit )
	TriggerFile.CreateUnitReclaimedTrigger( cb, unit )
end
function CreateUnitStartReclaimTrigger( cb, unit )
	TriggerFile.CreateUnitStartReclaimTrigger( cb, unit )
end
function CreateUnitStopReclaimTrigger( cb, unit )
	TriggerFile.CreateUnitStopReclaimTrigger( cb, unit )
end
function CreateUnitVeterancyTrigger(cb, unit)
	TriggerFile.CreateUnitVeterancyTrigger(cb, unit)
end
function CreateGroupDeathTrigger( cb, group )
   return TriggerFile.CreateGroupDeathTrigger(cb, group)
end
function CreatePlatoonDeathTrigger( cb, platoon )
	TriggerFile.CreatePlatoonDeathTrigger( cb, platoon )
end
function CreateSubGroupDeathTrigger(cb, group, num)
	return TriggerFile.CreateSubGroupDeathTrigger(cb, group, num)
end
function CreateUnitDistanceTrigger( callbackFunction, unitOne, unitTwo, distance )
	TriggerFile.CreateUnitDistanceTrigger( callbackFunction, unitOne, unitTwo, distance )
end
function CreateArmyStatTrigger(callbackFunction, aiBrain, name, triggerTable)
	TriggerFile.CreateArmyStatTrigger(callbackFunction, aiBrain, name, triggerTable)
end
function CreateThreatTriggerAroundPosition(callbackFunction, aiBrain, posVector, rings, onceOnly, value, greater)
	TriggerFile.CreateThreatTriggerAroundPosition(callbackFunction, aiBrain, posVector, rings, onceOnly, value, greater)
end
function CreateThreatTriggerAroundUnit(callbackFunction, aiBrain, unit, rings, onceOnly, value, greater)
	TriggerFile.CreateThreatTriggerAroundUnit(callbackFunction, aiBrain, unit, rings, onceOnly, value, greater)
end
function CreateArmyIntelTrigger(callbackFunction, aiBrain, reconType, blip, value, category, onceOnly, targetAIBrain)
	TriggerFile.CreateArmyIntelTrigger(callbackFunction, aiBrain, reconType, blip, value, category, onceOnly, targetAIBrain)
end
function CreateArmyUnitCategoryVeterancyTrigger(callbackFunction, aiBrain, category, level)
	TriggerFile.CreateArmyUnitCategoryVeterancyTrigger(callbackFunction, aiBrain, category, level)
end
function CreateUnitToMarkerDistanceTrigger( callbackFunction, unit, marker, distance )
	TriggerFile.CreateUnitToPositionDistanceTrigger( callbackFunction, unit, marker, distance )
end
function CreateUnitNearTypeTrigger( callbackFunction, unit, brain, category, distance )
	return TriggerFile.CreateUnitNearTypeTrigger( callbackFunction, unit, brain, category, distance )
end
function CreateOnResearchTrigger( callbackFunction, brain, researchName, event )
	TriggerFile.CreateOnResearchTrigger( callbackFunction, brain, researchName, event )
end

--*******************************************************************
-- DIALOGUE FUNCTIONS:
--*******************************************************************
function Dialogue(dialogueTable, callback, critical, speaker)
	import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').Dialogue(dialogueTable, callback, critical, speaker)
end
function FlushDialogueQueue()
	import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').FlushDialogueQueue()
end
