-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioTriggers.lua
--  Author(s):  John Comes, Drew Staltman
--  Summary  :  Generalized trigger functions for scenarios.
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

DebugAreaTrigger = false
---------------------------------------------------------------------
-- CreateAreaTrigger
-- This will create an area trigger around <rectangle>.  It will fire when <categoy> is met of <aiBrain>.
-- onceOnly means it will not continue to run after the first time it fires.
-- invert meants it will fire when units are NOT in the area.  Useful for testing if someone has defeated a base.
-- number refers to the number of units it will take to fire.  If not inverted.  It will fire when that
--		many are in the area. If inverted, it will fire when less than that many are in the area.

-- CreateMultipleAreaTrigger
-- CreateMultipleBrainAreaTrigger
-- CreateMultipleBrainMultipleAreaTrigger
-- same as CreateAreaTrigger except you can supply the function with a table of Rects. and in the mult brain version a table of brains
-- 		multiple rect support allows you to have irregular area dimensions
-- 		multiple brain support allows you to use a single areaTriggerThread to check for any matches across multiple armies
---------------------------------------------------------------------
function CreateAreaTrigger(callbackFunction, rectangle, category, onceOnly, invert, aiBrain, number, requireBuilt)
    --LOG('*SCENARIO DEBUG: FORKING AREA TRIGGER THREAD')
    return ForkThread(AreaTriggerThread, callbackFunction, {rectangle}, category, onceOnly, invert, {aiBrain}, number, requireBuilt)
end
function CreateMultipleAreaTrigger(callbackFunction, rectangleTable, category, onceOnly, invert, aiBrain, number, requireBuilt)
    return ForkThread(AreaTriggerThread, callbackFunction, rectangleTable, category, onceOnly, invert, {aiBrain}, number, requireBuilt)
end
function CreateMultipleBrainAreaTrigger(callbackFunction, rectangle, category, onceOnly, invert, brains, number, requireBuilt)
    return ForkThread(AreaTriggerThread, callbackFunction, {rectangle}, category, onceOnly, invert, brains, number, requireBuilt)
end
function CreateMultipleBrainMultipleAreaTrigger(callbackFunction, rectangleTable, category, onceOnly, invert, brains, number, requireBuilt)
    return ForkThread(AreaTriggerThread, callbackFunction, rectangleTable, category, onceOnly, invert, brains, number, requireBuilt)
end
function AreaTriggerThread(callbackFunction, rectangleTable, category, onceOnly, invert, brains, number, requireBuilt, name)
    local recTable, brainIndexes = {}, {}
    table.resizeandclear(recTable, rectangleTable)
    local index = 1
    for k,v in rectangleTable do
        if type(v) == 'string' then
            recTable[index] = ScenarioUtils.AreaToRect(v)
        else
            recTable[index] = v
        end
        index = index + 1
    end

    table.resizeandclear(brainIndexes, brains)
    index = 1
    for k,v in brains do
        brainIndexes[index] = v:GetArmyIndex()
        index = index + 1
    end
    if table.empty(brainIndexes) then brainIndexes = false end

    local totalEntities = {}
    while true do
        local amount = 0
        -- Reusing the old memory for this table leaves the old memory hanging around but saves a ton of memory allocations
        table.clear(totalEntities)
        index = 1
        for k, v in recTable do
            local entities = GetUnitsInRect( v )
            if entities then
                for ke, ve in entities do
                    totalEntities[index] = ve
                    index = index + 1
                end
            end
        end
        local triggered = false
        local triggeringEntity
        local triggeringEntityIndex = 1
        local numEntities = table.getn(totalEntities)
        if numEntities > 0 then
            for k, v in totalEntities do
                local contains = EntityCategoryContains(category, v)
                if not contains then
                    continue
                end

                if requireBuilt and v:IsBeingBuilt() then
                    continue
                end

                if brainIndexes and not table.find( brainIndexes, v:GetArmy() ) then
                    continue
                end

                amount = amount + 1
                --If we want to trigger as soon as one of a type is in there, kick out immediately.
                if not number then
                    triggeringEntity = v
                    triggered = true
                    break
                --If we want to trigger on an amount, then add the entity into the triggeringEntity table
                --so we can pass that table back to the callback function.
                else
                    if not triggeringEntity then
                        triggeringEntity = {}
                    end
                    triggeringEntity[triggeringEntityIndex] = v
                    triggeringEntityIndex = triggeringEntityIndex + 1
                end
            end
        end

        --Check to see if we have a triggering amount inside in the area.
        if number and ((amount >= number and not invert) or (amount < number and invert)) then
            triggered = true
        end

		-- help debug area triggers
		if DebugAreaTrigger then
			local color = triggered and "LimeGreen" or "LightYellow"
			for k,v in recTable do
				-- map to ogrid
				local collisionX0 = math.floor(v.x0 / 4) -- shift right log2 units/grid
				local collisionZ0 = math.floor(v.y0 / 4)
				local collisionX1 = math.floor((v.x1 + 4-1) / 4) -- add units per grid-1 and shift right log2 units/grid
				local collisionZ1 = math.floor((v.y1 + 4-1) / 4)

				-- map back to coordinates
				local xDelta = collisionX1 - collisionX0
				local zDelta = collisionZ1 - collisionZ0
				collisionX0 = collisionX0 * 4
				collisionZ0 = collisionZ0 * 4
				collisionX1 = collisionX0 + (xDelta*4)
				collisionZ1 = collisionZ0 + (zDelta*4)


				local z = GetSurfaceHeight((collisionX0 + collisionX1)/2, (collisionZ0+collisionZ1)/2)
				local p0 = Vector(collisionX0, z, collisionZ0)
				local p1 = Vector(collisionX1, z, collisionZ0)
				local p2 = Vector(collisionX1, z, collisionZ1)
				local p3 = Vector(collisionX0, z, collisionZ1)

				local p10 = Vector(collisionX0, z+5, collisionZ0)
				local p11 = Vector(collisionX1, z+5, collisionZ0)
				local p12 = Vector(collisionX1, z+5, collisionZ1)
				local p13 = Vector(collisionX0, z+5, collisionZ1)
				DrawLine(p0,p1, color)
				DrawLine(p1,p2, color)
				DrawLine(p2,p3, color)
				DrawLine(p3,p0, color)

				DrawLine(p10,p11, color)
				DrawLine(p11,p12, color)
				DrawLine(p12,p13, color)
				DrawLine(p13,p10, color)

				DrawLine(p0,p10, color)
				DrawLine(p1,p11, color)
				DrawLine(p2,p12, color)
				DrawLine(p3,p13, color)
			end

			if triggered then
				if type(triggeringEntity) == "table" then
					for _,unit in triggeringEntity do
						local pos = unit:GetPosition()
						DrawCircle(pos, 1, color)
					end
				else
					DrawCircle(triggeringEntity:GetPosition(), 1, color )
				end
			end
		end

        --TRIGGER IF:
        --You don't want a specific amount and the correct unit category entered
        --You don't want a specific amount, there are no longer the category inside and you wanted the test inverted
        --You want a specific amount and we have enough.
        if ( triggered and not invert and not number) or (not triggered and invert and not number) or (triggered and number) then
			callbackFunction(triggeringEntity)

            if onceOnly then
                return
            end
        end
        WaitTicks(1)
    end
end

---------------------------------------------------------------------
-- CreateThreatTriggerAroundUnit
-- Fires when the threat level of <unit> of size <rings> is related to <value>
---------------------------------------------------------------------
function CreateThreatTriggerAroundUnit(callbackFunction, aiBrain, unit, rings, onceOnly, value, greater)
    return ForkThread(ThreatTriggerAroundUnitThread, callbackFunction, aiBrain, unit, rings, onceOnly, value, greater)
end
function ThreatTriggerAroundUnitThread(callbackFunction, aiBrain, unit, rings, onceOnly, value, greater, name)
    while not unit:IsDead() do
        local threat = aiBrain:GetThreatAtPosition(unit:GetPosition(), rings, true)
        if greater and threat >= value then
            callbackFunction()

            if onceOnly then
                return
            end
        elseif not greater and threat <= value then
            callbackFunction()

            if onceOnly then
                return
            end
        end
        WaitSeconds(0.5)
    end
end

---------------------------------------------------------------------
-- CreateThreatTriggerAroundPosition
-- Fires when the threat level of <position> of size <rings> is related to <value>
-- if <greater> is true it will fire if the threat is greater than <value>
---------------------------------------------------------------------
function CreateThreatTriggerAroundPosition(callbackFunction, aiBrain, posVector, rings, onceOnly, value, greater)
    return ForkThread(ThreatTriggerAroundPositionThread, callbackFunction, aiBrain, posVector, rings, onceOnly, value, greater)
end

function ThreatTriggerAroundPositionThread(callbackFunction, aiBrain, posVector, rings, onceOnly, value, greater, name)
    if type(posVector) == 'string' then
        posVector = ScenarioUtils.MarkerToPosition(posVector)
    end
    while true do
        local threat = aiBrain:GetThreatAtPosition(posVector, rings, true)
        if greater and threat >= value then
            callbackFunction()

            if onceOnly then
                return
            end
        elseif not greater and threat <= value then
            callbackFunction()

            if onceOnly then
                return
            end
        end
        WaitSeconds(0.5)
    end
end

---------------------------------------------------------------------
-- CreateTimerTrigger
-- Fire the <cb> function after <seconds> number of seconds.
-- you can have the function repeant <repeatNum> times which will fire every <seconds>
-- until <repeatNum> is met
---------------------------------------------------------------------
function CreateTimerTrigger(callbackFunction, seconds, name, displayBool, onTickFunc)
    return ForkThread(TimerTriggerThread, callbackFunction, seconds, name, displayBool, onTickFunc)
end
function TimerTriggerThread(callbackFunction, seconds, name, displayBool, onTickFunc)
    if displayBool then

        local ticking = true
        local targetTime = math.floor(GetGameTimeSeconds()) + seconds

        while ticking do
            onTickFunc(targetTime - math.floor(GetGameTimeSeconds()))

            if targetTime - math.floor(GetGameTimeSeconds()) < 0 then
                ticking = false
            end

            WaitSeconds(1)
        end
    else
        WaitSeconds(seconds)
    end

    callbackFunction()
end


---------------------------------------------------------------------
-- CreateGroupDeathTrigger
-- Single line Group Death Trigger creation
-- When all units in <group> are destoyed, <cb> function will be called
---------------------------------------------------------------------
function CreateGroupDeathTrigger(callbackFunction, group)
    return ForkThread(GroupDeathTriggerThread, callbackFunction, group)
end
function GroupDeathTriggerThread(callbackFunction, group, name)
    local allDead = false
    while not allDead do
        allDead = true
        for k, v in group do
            if not v:IsDead() then
                allDead = false
                break
            end
        end
        if allDead then
            callbackFunction()
        end
        WaitSeconds(0.5)
    end
end

---------------------------------------------------------------------
-- CreateSubGroupDeathTrigger
-- Single line Sub Group Death Trigger creation
-- When <num> <cat> units in <group> are destroyed, <cb> function will be called
---------------------------------------------------------------------
function CreateSubGroupDeathTrigger(callbackFunction, group, num)
    return ForkThread(SubGroupDeathTriggerThread, callbackFunction, group, num)
end
function SubGroupDeathTriggerThread(callbackFunction, group, num, name)
    local numDead = 0
    while(numDead < num) do
        numDead = 0
        for k, v in group do
            if(v:IsDead()) then
                numDead = numDead + 1
            end
            if(numDead == num) then
                callbackFunction()
                break
            end
        end
        WaitSeconds(0.5)
    end
end

---------------------------------------------------------------------
-- CreatePlatoonDeathTrigger
-- Single line Platoon Death Trigger creation
-- When all units in <platoon> are destroyed, <cb> function will be called
---------------------------------------------------------------------
function CreatePlatoonDeathTrigger( cb, platoon )
	platoon.Callbacks.OnDestroyed:Add(cb)
end

---------------------------------------------------------------------
-- CreateArmyStatTrigger
-- === triggerTable spec === -
-- {
--     { StatType = string, -- Examples: Units_Active, Units_Killed, Enemies_Killed, Economy_Trend_Mass, Economy_TotalConsumed_Energy
--       CompareType = string, -- GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual
--       Value = integer,
--       Category = category, -- Only used with "Units" triggers
--     },
--  }

-- === COMPLETE LIST OF STAT TYPES === -
--		"Units_Active",
--		"Units_Killed",
--		"Units_History",
--		"Units_BeingBuilt"
--		"Enemies_Killed",
--		"Economy_TotalProduced_Energy",
--		"Economy_TotalConsumed_Energy",
--		"Economy_Income_Energy",
--		"Economy_Output_Energy",
--		"Economy_Stored_Energy",
--		"Economy_Reclaimed_Energy",
--		"Economy_MaxStorage_Energy",
--		"Economy_PeakStorage_Energy",
--		"Economy_TotalProduced_Mass",
--		"Economy_TotalConsumed_Mass",
--		"Economy_Income_Mass",
--		"Economy_Output_Mass",
--		"Economy_Stored_Mass",
--		"Economy_Reclaimed_Mass",
--		"Economy_MaxStorage_Mass",
--		"Economy_PeakStorage_Mass",
--		"Economy_Income_Research",
--		"Economy_Research_Units_Unlocked",
--		"Economy_Research_Learned_Count",
---------------------------------------------------------------------
function CreateArmyStatTrigger(callbackFunction, aiBrain, name, triggerTable)
    local spec = {
        Name = name,
        CallbackFunction = callbackFunction,
    }
    for num, trigger in aiBrain.TriggerList do
        if name == trigger.Name then
            error('*TRIGGER ERROR: Must use unique names for new triggers- Supplied name: '..trigger.Name, 2)
            return
        end
    end
    for num, triggerData in triggerTable do
        if string.find (triggerData.StatType, "Economy_") then
            aiBrain:GetArmyStat(triggerData.StatType, 0.0)
        else
            aiBrain:GetArmyStat(triggerData.StatType, 0)
        end
        if triggerData.Category then
            aiBrain:SetArmyStatsTrigger(triggerData.StatType, name, triggerData.CompareType, triggerData.Value, triggerData.Category)
        else
            aiBrain:SetArmyStatsTrigger(triggerData.StatType, name, triggerData.CompareType, triggerData.Value)
        end
    end
    table.insert(aiBrain.TriggerList, spec)
end

---------------------------------------------------------------------
-- CreateArmyIntelTrigger
-- Type = 'LOSNow'/'Radar'/'Sonar'/'Omni',
--        Blip = blip handle or false if you don't care,
-- Category = category of unit to trigger off of
-- OnceOnly = run it once
--        Value = true/false, true = when you get it, false = when you first don't have it
-- <aiBrain> refers to the intelligence you are monitoring.
-- <targetAIBrain> requires that the intelligence fires on seeing a specific brain's units
---------------------------------------------------------------------
function CreateArmyIntelTrigger(callbackFunction, aiBrain, reconType, blip, value, category, onceOnly, targetAIBrain)
    local spec = {
        CallbackFunction = callbackFunction,
        Type = reconType,
        Category = category,
        Blip = blip,
        Value = value,
        OnceOnly = onceOnly,
        TargetAIBrain = targetAIBrain,
    }
    aiBrain:SetupArmyIntelTrigger(spec)
end

---------------------------------------------------------------------
function CreateArmyUnitCategoryVeterancyTrigger(callbackFunction, aiBrain, category, level)
    local spec = {
        CallbackFunction = callbackFunction,
        Category = category,
        Level = level,
    }
    aiBrain:SetupBrainVeterancyTrigger(spec)
end

---------------------------------------------------------------------
-- CreateUnitDistanceTrigger
-- Checks if <unitOne> and <unitTwo> are less than <distance> from each other
-- if true calls <callbackFunction>
---------------------------------------------------------------------
function CreateUnitDistanceTrigger( callbackFunction, unitOne, unitTwo, distance )
    ForkThread( UnitDistanceTriggerThread, callbackFunction, unitOne, unitTwo, distance )
end
function UnitDistanceTriggerThread( callbackFunction, unitOne, unitTwo, distance )
    while not ( VDist3( unitOne:GetPosition(), unitTwo:GetPosition() ) < distance  ) do
        WaitSeconds(0.5)
    end
    callbackFunction()
end

---------------------------------------------------------------------
-- CreateUnitToPositionDistanceTrigger
-- Fires when <unit> and <marker> are less than or equal to <distance> apart
---------------------------------------------------------------------
function CreateUnitToPositionDistanceTrigger( callbackFunction, unit, marker, distance )
    ForkThread(UnitToPositionDistanceTriggerThread, callbackFunction, unit, marker, distance)
end
function UnitToPositionDistanceTriggerThread( cb, unit, marker, distance, name )
    if type(marker) == 'string' then
        marker = ScenarioUtils.MarkerToPosition(marker)
    end
    local fired = false
    while not fired do
        if unit:IsDead() then
            return
        else
            local position = unit:GetPosition()
            local value = VDist2( position[1], position[3], marker[1], marker[3])
            if value <= distance then
                fired = true
                cb(unit)
                return
            end
        end
        WaitSeconds(.5)
    end
end

---------------------------------------------------------------------
-- CreateUnitNearTypeTrigger
-- Function that fires when <unit> is near any unit of type <category> belonging to <brain> withing <distance>
---------------------------------------------------------------------
function CreateUnitNearTypeTrigger( callbackFunction, unit, brain, category, distance )
    return ForkThread( CreateUnitNearTypeTriggerThread, callbackFunction, unit, brain, category, distance )
end
function CreateUnitNearTypeTriggerThread( callbackFunction, unit, brain, category, distance, name )
    local fired = false
    while not fired do
        if unit:IsDead() then
            return
        else
            local position = unit:GetPosition()
            for k,catUnit in brain:GetListOfUnits(category, false) do
                if (VDist3( position, catUnit:GetPosition() ) < distance) and not catUnit:IsBeingBuilt() then
                    fired = true
                    callbackFunction(unit, catUnit)
                    return
                end
            end
        end
        WaitSeconds(.5)
    end
end

---------------------------------------------------------------------
-- CreateUnitBuiltTrigger
-- will fire off when the specified builderUnit builds a unit of the specified category
--
-- callbackFunction			- function to call when trigger fires off
-- unit						- unit being monitored
-- category					- required category for built unit to fire off the trigger
--
---------------------------------------------------------------------
function CreateUnitBuiltTrigger(callbackFunction, unit, category)
	local argTable = {
		callbackFunction,
		category,
	}

    unit.ClassCallbacks.OnStopBuild:Add( CheckUnitBuilt, nil, argTable )
end
function CheckUnitBuilt(argTable, builderUnit, builtUnit)
	local callbackFunction	= argTable[1]
	local category			= argTable[2]

	if builtUnit and not builtUnit:IsDead() and EntityCategoryContains(category, builtUnit) then
		callbackFunction(builderUnit, builtUnit)
		builderUnit.ClassCallbacks.OnStopBuild:Remove(import('/lua/sim/ScenarioTriggers.lua').CheckUnitBuilt)
	end
end

---------------------------------------------------------------------
-- CreateUnitDamagedTrigger
-- will fire off when damage from a single shot is either greater than the specified amount or of the specified damage type
-- can be flagged as one shot - which will NOT remove the underlying call from the callback system, but it will only fire once.
--
-- callbackFunction			- function to call when trigger fires off
-- unit						- unit being monitored
-- dealtDamageGreaterThan	- float indicated amount of damage that must be dealt for the trigger to fire. U -1 to ignore.
-- damagedByType			- damage type required when trigger is supposed to fire off when a certain type of damage is dealt. Use nil to ignore.
-- oneShot					- bool indicating if the trigger should only fire off once, or keep firing off
--
---*******************************************************************
---*******************************************************************
---*******************************************************************
---NOTE: this is really not the best way to do this - but our callback system has a limitation to how it can "remove" because it
---			removes by the handle to the function directly - which breaks if we call this function twice with two different sets of data but the same
---			callback function. - bfricks 11/8/09
---*******************************************************************
---*******************************************************************
---*******************************************************************
---------------------------------------------------------------------
function CreateUnitDamagedTrigger( callbackFunction, unit, dealtDamageGreaterThan, damagedByType, oneShot )
	local hasFired = false
	unit.Callbacks.OnDamaged:Add(
		function(damagedUnit, instigator, adjAmount, damageType)
			if not oneShot or not hasFired then
				--LOG('CheckUnitDamaged: dealtDamageGreaterThan[', dealtDamageGreaterThan, '] damagedByType[', damagedByType, '] oneShot[', oneShot, ']')
				if dealtDamageGreaterThan >= -1 and adjAmount > dealtDamageGreaterThan then
					-- case 1: if we care about how much damage has been dealt and we are damaged by
					--			a value greater than dealtDamageGreaterThan

					-- callback with the instigator responsible for the damage
					---TODO: work out with Gordon how best to handle the instigator - what we want here is the unit responsible for damage - bfricks 3/7/09
					hasFired = true
					callbackFunction(damagedUnit, instigator)
				elseif damagedByType and damagedByType == damageType then
					-- case 2: if we care about the type of damage that was dealt, and we are dealt damage by the specified type

					-- callback with the instigator responsible for the damage
					---TODO: work out with Gordon how best to handle the instigator - what we want here is the unit responsible for damage - bfricks 3/7/09
					hasFired = true
					callbackFunction(damagedUnit, instigator)
				elseif dealtDamageGreaterThan == -1 and not damagedByType then
					-- case 3: the most basic damaged check with no constraints

					-- callback with the instigator responsible for the damage
					---TODO: work out with Gordon how best to handle the instigator - what we want here is the unit responsible for damage - bfricks 3/7/09
					hasFired = true
					callbackFunction(damagedUnit, instigator)
				end
			end
		end
	)
end

---------------------------------------------------------------------
-- CreateUnitHealthRatioTrigger
-- will fire off when a unit's health is either below or above the specified health ratio (current / max)
-- can be flagged as one shot - which will NOT remove the underlying call from the callback system, but it will only fire once.
--
-- callbackFunction			- function to call when trigger fires off
-- unit						- unit being monitored
-- healthRatio				- current / max.
-- bLessThan				- bool indicating if the ratio must be less than or greater than the specified healthRatio.
-- oneShot					- bool indicating if the trigger should only fire off once, or keep firing off
--
---*******************************************************************
---*******************************************************************
---*******************************************************************
---NOTE: this is really not the best way to do this - but our callback system has a limitation to how it can "remove" because it
---			removes by the handle to the function directly - which breaks if we call this function twice with two different sets of data but the same
---			callback function. - bfricks 11/8/09
---*******************************************************************
---*******************************************************************
---*******************************************************************
---------------------------------------------------------------------
function CreateUnitHealthRatioTrigger( callbackFunction, unit, healthRatio, bLessThan, oneShot )
	local hasFired = false
	unit.Callbacks.OnDamaged:Add(
		function(affectedUnit)
			if not oneShot or not hasFired then
				local curRatio = affectedUnit:GetHealth() / affectedUnit:GetMaxHealth()
				--LOG( 'CreateUnitHealthRatioTrigger: healthRatio[', healthRatio, ']bLessThan[', bLessThan, ']oneShot[', oneShot, ']curRatio[', curRatio, ']' )
				if bLessThan then
					if curRatio <= healthRatio then
						-- callback with curRatio
						hasFired = true
						callbackFunction(affectedUnit, curRatio)
					end
				else
					if curRatio >= healthRatio then
						-- callback with curRatio
						hasFired = true
						callbackFunction(affectedUnit, curRatio)
					end
				end
			end
		end
	)
end

---------------------------------------------------------------------
-- CreateUnitDeathTrigger
-- Function that fires when <unit> dies
---------------------------------------------------------------------
function CreateUnitDeathTrigger(callbackFunction, unit)
    unit.Callbacks.OnKilled:Add(callbackFunction)
    unit.Callbacks.OnDestroyedOnTransport:Add(callbackFunction)
end

---------------------------------------------------------------------
-- CreateUnitResurrectedTrigger
-- Function that fires when <unit> is resurrected
---------------------------------------------------------------------
function CreateUnitResurrectedTrigger(callbackFunction, unit)
    unit.Callbacks.OnResurrected:Add(callbackFunction)
end

---------------------------------------------------------------------
-- CreateUnitKilledUnitTrigger
-- Function that fires when <unit> kills another unit
---------------------------------------------------------------------
function CreateUnitKilledUnitTrigger(callbackFunction, unit)
    unit.Callbacks.OnKilledUnit:Add(callbackFunction)
end

---------------------------------------------------------------------
-- CreateUnitDestroyedTrigger
-- Function that fires when <unit> is destroyed by death, reclaiming, or capturing
---------------------------------------------------------------------
function CreateUnitDestroyedTrigger(callbackFunction, unit)
    unit.Callbacks.OnReclaimed:Add(callbackFunction)
    unit.Callbacks.OnCaptured:Add(callbackFunction)
    unit.Callbacks.OnKilled:Add(callbackFunction)
    unit.Callbacks.OnDestroyedOnTransport:Add(callbackFunction)
end

---------------------------------------------------------------------
-- CreateUnitPercentageBuiltTrigger
-- Function that fires when <unit> is built to the specified <percent>
---------------------------------------------------------------------
function CreateUnitPercentageBuiltTrigger(callbackFunction, aiBrain, category, percent)
    aiBrain:AddUnitBuiltPercentageCallback(callbackFunction, category, percent)
end

---------------------------------------------------------------------
-- CreateUnitReclaimedTrigger
-- Function that fires when <unit> is reclaimed
---------------------------------------------------------------------
function CreateUnitReclaimedTrigger( callbackFunction, unit )
    unit.Callbacks.OnReclaimed:Add(callbackFunction)
end

---------------------------------------------------------------------
-- CreateUnitCapturedTrigger
-- When <unit> is captured cbOldUnit is called passing the old unit BEFORE it has switched armies,
-- cbNewUnit is called passing in the unit AFTER it has switched armies
---------------------------------------------------------------------
function CreateUnitCapturedTrigger( cbOldUnit, cbNewUnit, unit )
    if cbOldUnit then
        unit.Callbacks.OnCaptured:Add(cbOldUnit)
    end
    if cbNewUnit then
        unit.Callbacks.OnCapturedNewUnit:Add(cbNewUnit)
    end
end

----------------------------------------------------------------------
-- CreateUnitSelcetedTrigger
--
-- Adds a callback to trigger when a specific unit is selected
--
-- callbackFuntion           - function to call when the trigger fires
-- unit                      - unit to add the callback to
--
-----------------------------------------------------------------------
function CreateUnitSelectedTrigger( callbackFunction, unit)
    if not unit:IsDead() then
        unit.Callbacks.OnSelected:Add(callbackFunction)
    end
end

---------------------------------------------------------------------
-- CreateOnResearchTrigger
--
-- Aibrain research event trigger, allows to trigger events based off
-- of any research event.
--
-- callbackFunction			- function to call when trigger fires off
-- brain					- army AI brain
-- researchName				- research technology name, see Research.lua for names.
-- event					- research event to trigger off of. Currently supports event: 'complete'
--
---------------------------------------------------------------------
function CreateOnResearchTrigger( callbackFunction, brain, researchName, event )
	-- early check to see if we have already completed the research
	if brain:HasResearched(researchName) then
		callbackFunction(researchName, event)
	else
		brain:AddResearchCallback( callbackFunction, researchName, event )
	end
end

---------------------------------------------------------------------
-- NON FUNCTIONAL TRIGGERS:
---------------------------------------------------------------------
---DEV NOTE: no longer working - leaving in for now, potentially useful for tutorial - bfricks 3/11/2009 12:17PM
function CreateStartBuildTrigger(callbackFunction, unit, category)
    unit:AddOnStartBuildCallback(callbackFunction, category)
end

---DEV NOTE: no longer working - is this still needed? - bfricks 3/11/2009 12:17PM
function CreateUnitVeterancyTrigger(callbackFunction, unit)
    unit:AddUnitCallback(callbackFunction, 'OnVeteran')
end

-- No longer working; may not be needed - dstaltman
function CreateOnFailedToBuildTrigger(callbackFunction, unit)
--    unit:AddUnitCallback(callbackFunction, 'OnFailedToBuild')
end

-- No longer working; may not be needed - dstaltman
function CreateUnitStartCaptureTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnStartCapture' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitStopCaptureTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnStopCapture' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitStartBeingCapturedTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnStartBeingCaptured' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitStopBeingCapturedTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnStopBeingCaptured' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitFailedBeingCapturedTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnFailedBeingCaptured' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitFailedCaptureTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnFailedCapture' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitStopBeingBuiltTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnStopBeingBuilt' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitStartReclaimTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnStartReclaim' )
end

-- No longer working; may not be needed - dstaltman
function CreateUnitStopReclaimTrigger( cb, unit )
    unit:AddUnitCallback( cb, 'OnStopReclaim' )
end
