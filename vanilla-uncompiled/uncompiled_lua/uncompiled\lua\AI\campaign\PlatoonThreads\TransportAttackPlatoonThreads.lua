local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')


-- TransportPool - This thread moves transports into the transport pool and optionally moves them to a point
-- Data = {
--   TransportMoveLocation = string|position, - the location to move transports to
-- }

CAIPlatoonThreadBlueprint {
    Name = 'TransportPool',
    Function = function(platoon, data)
        local aiBrain = platoon:GetBrain()
        local tPool = aiBrain:GetPlatoonUniquelyNamed('TransportPool')
        local location = false
        if data then
            if data.TransportMoveLocation then
                if type(data.TransportMoveLocation) == 'string' then
                    location = ScenarioUtils.MarkerToPosition(data.TransportMoveLocation)
                else
                    location = data.TransportMoveLocation
                end
            end
        end

        if not tPool then
            tPool = aiBrain:MakePlatoon( 'None', 'None' )
            tPool:UniquelyNamePlatoon('TransportPool')
        end

        for k,unit in platoon:GetPlatoonUnits() do
            aiBrain:AssignUnitsToPlatoon('TransportPool', {unit}, 'Scout', 'GrowthFormation' )
            if location then
                IssueMove( {unit}, location )
            end
        end
    end,
}

-- LandAssaultWithTransports - This thread loads units on a transport, moves them, then has them attack
-- Data = {
--     LandingList - (REQUIRED or LandingChain) List of possible locations for transports to unload units
--     LandingChain - (REQUIRED or LandingList) Chain of possible landing locations
--     TransportReturn - Location for transports to return to (they will attack with land units if this isn't set)
--     AttackPoints - (REQUIRED or AttackChain or PatrolChain) List of locations to attack.
--                                              The platoon attacks the highest threat first
--     AttackChain - (REQUIRED or AttackPoints or PatrolChain) Marker Chain of positions to attack
--     PatrolChain - (REQUIRED or AttackChain or AttackPoints) Chain of patrolling
--     RandomPatrol - Bool if you want the patrol things to be random rather than in order
-- }

CAIPlatoonThreadBlueprint {
    Name = 'LandAssaultWithTransports',
    Function = function(platoon, data)
        local aiBrain = platoon:GetBrain()
        local cmd

        if not data.AttackPoints and not data.AttackChain and not data.AssaultChains and not data.PatrolChain then
            if platoon.OpAIName then
                error('*SCENARIO PLATOON AI ERROR: LandAssaultWithTransports requires AttackPoints in PlatoonData to operate - OpAIName = ' .. platoon.OpAIName )
            else
                error('*SCENARIO PLATOON AI ERROR: LandAssaultWithTransports requires AttackPoints in PlatoonData to operate')
            end
        elseif not data.LandingList and not data.LandingChain and not data.AssaultChains then
            if platoon.OpAIName then
                error('*SCENARIO PLATOON AI ERROR: LandAssaultWithTransports requires LandingList in PlatoonData to operate - OpAIName = ' .. platoon.OpAIName )
            else
                error('*SCENARIO PLATOON AI ERROR: LandAssaultWithTransports requires LandingList in PlatoonData to operate')
            end
        end

        local assaultAttackChain, assaultLandingChain
        if data.AssaultChains then
            local tempChains = {}
            local tempNum = 0
            for landingChain, attackChain in data.AssaultChains do
                for num, pos in ScenarioUtils.ChainToPositions( attackChain ) do
                    if aiBrain:GetThreatAtPosition( pos, 1, true ) > 0 then
                        tempChains[landingChain] = attackChain
                        tempNum = tempNum + 1
                        break
                    end
                end
            end
            local pickNum = Random(1,tempNum)
            tempNum = 0
            for landingChain, attackChain in tempChains do
                tempNum = tempNum + 1
                if tempNum == pickNum then
                    assaultAttackChain = attackChain
                    assaultLandingChain = landingChain
                    break
                end
            end
        end

        -- Make attack positions out of chain, markers, or marker names
        local attackPositions = {}
        if data.AttackChain then
            attackPositions = ScenarioUtils.ChainToPositions(data.AttackChain)
        elseif assaultAttackChain then
            attackPositions = ScenarioUtils.ChainToPositions(assaultAttackChain)
        elseif data.AttackPoints then
            for k,v in data.AttackPoints do
                if type(v) == 'string' then
                    table.insert(attackPositions, ScenarioUtils.MarkerToPosition(v))
                else
                    table.insert(attackPositions, v)
                end
            end
        end

        -- make landing positions out of chain, markers, or marker names
        local landingPositions = {}
        if data.LandingChain then
            landingPositions = ScenarioUtils.ChainToPositions(data.LandingChain)
        elseif assaultLandingChain then
            landingPositions = ScenarioUtils.ChainToPositions(assaultLandingChain)
        else
            for k,v in data.LandingList do
                if type(v) == 'string' then
                    table.insert(landingPositions, ScenarioUtils.MarkerToPosition(v))
                else
                    table.insert(landingPositions, v)
                end
            end
        end

        platoon:Stop()

        -- Load transports
        if not GetLoadTransports(platoon) then
            return
        end

        -- move platoon along route
        if data.MovePath then
            for k,v in ScenarioUtils.ChainToPositions(data.MovePath) do
                cmd = platoon:MoveToLocation(v, false)
            end

            -- make sure we have a command then check if commands are finished every second
            if cmd then
                while platoon:IsCommandsActive(cmd) do
                    WaitSeconds(1)
                    if not aiBrain:PlatoonExists(platoon) then
                        return false
                    end
                end
            end
        end

        -- Find landing location and unload units at right spot
        local landingLocation
        if ScenarioInfo.Options.Difficulty and ScenarioInfo.Options.Difficulty == 3 then
            landingLocation = PlatoonChooseRandomNonNegative(aiBrain, landingPositions, 1)
        else
            landingLocation = PlatoonChooseRandomNonNegative(aiBrain, landingPositions, 1)
        end

        cmd = platoon:UnloadAllAtLocation(landingLocation)

        local attached = true
        while attached do
            --LOG('*TRANSPORT DEBUG: Units Attached - still moving')
            WaitSeconds(3)
            if not aiBrain:PlatoonExists(platoon) then
                return
            end

            attached = false
            for num, unit in platoon:GetPlatoonUnits() do
                if not unit:IsDead() and not EntityCategoryContains(categories.TRANSPORTATION, unit) and unit:IsUnitState('Attached') then
                    attached = true
                    break
                end
            end
        end

        --LOG('*TRANSPORT DEBUG: Units dropped off')

        if data.PatrolChain then
            if(data.TransportReturn) then
            	-- LOG('*AI DEBUG: Returning transports to pool Call')
                ReturnTransportsToPool(platoon,data)
            end

            if data.RandomPatrol then
                for k,v in import('/lua/AI/ScenarioPlatoonAI.lua').GetRandomPatrolRoute(ScenarioUtils.ChainToPositions(data.PatrolChain)) do
                    platoon:Patrol(v)
                end
            else
                for k,v in ScenarioUtils.ChainToPositions(data.PatrolChain) do
                    platoon:Patrol(v)
                end
            end
        else
            -- Patrol attack route by creating attack route
            local attackRoute = {}
            attackRoute = PlatoonChooseHighestAttackRoute(aiBrain, attackPositions, 1)
            -- Send transports back to base if desired
            if(data.TransportReturn) then
            	-- LOG('*AI DEBUG: Returning transports to pool Call')
                ReturnTransportsToPool(platoon,data)
            end

            for k,v in attackRoute do
                platoon:Patrol(v)
            end
        end
    end,
}

-- CaptureRouteWithTransports - This thread randomly chooses a chain from a table and tells the platoon to patrol it
-- Data = {
--   LandingChain = string, -- Name of chain of possible landing sites
--   LandingList = table, -- Table of possible landing sites
--   TransportReturn = string -- Name of position for transports to return to
--   CaptureChain = string, -- Name of chain to capture along
--   CaptureRadius = number or 15, -- Radius to search for captureable targets around platoon
--   AnnounceRoute = bool, -- if set it will announce which attack route the attack is on
-- }

function startPatrol(platoon, route)
    for k,v in route do
        platoon:MoveToLocation(v, false)
    end
end

function findCaptureTarget(platoon, route, radius, captureTargets)
    local nearbyUnits = platoon:GetBrain():GetUnitsAroundPoint( categories.LAND + categories.NAVAL + categories.STRUCTURE, platoon:GetPlatoonPosition(), radius, 'Enemy' )
    if not nearbyUnits or table.empty(nearbyUnits) then
        return false
    end

    for k,v in nearbyUnits do
        if not v:IsCapturable() or v:IsUnitState('BeingCaptured') then
            continue
        end

        local beingCaptured = false
        for _,unit in captureTargets do
            if v == unit then
                beingCaptured = true
            end
        end
        if beingCaptured then continue end

        return v
    end

    return false
end

function captureCallback(data, newUnit, captor)
    if newUnit and not newUnit:IsDead() and not newUnit.CaptureRouteCallback then
        newUnit.CaptureRouteCallback = true
        data.CallbackFunction(newUnit, captor)
    end
end

CAIPlatoonThreadBlueprint {
    Name = 'CaptureRouteWithTransports',
    Function = function(platoon, data)
        local chainName = data.CaptureChain

        local route = ScenarioUtils.ChainToPositions(chainName)
        local patrolRoute = table.copy(route)

        local radius = data.CaptureRadius or 15

        if data.AnnounceRoute then
            LOG('*AI DEBUG: OpAI = ' .. platoon.PlatoonData.PlatoonName .. ' - Attacking on route - ' .. chainName)
        end

        for k,v in platoon:GetPlatoonUnits() do
            if v:IsDead() then
                continue
            end

            v:RemoveCommandCap('RULEUCC_Reclaim')
            v:RemoveCommandCap('RULEUCC_Repair')
        end

        local aiBrain = platoon:GetBrain()
        local currentState = 'None'

        -- make landing positions out of chain, markers, or marker names
        local landingPositions = {}
        if data.LandingChain then
            landingPositions = ScenarioUtils.ChainToPositions(data.LandingChain)
        else
            for k,v in data.LandingList do
                if type(v) == 'string' then
                    table.insert(landingPositions, ScenarioUtils.MarkerToPosition(v))
                else
                    table.insert(landingPositions, v)
                end
            end
        end

        platoon:Stop()

        -- Load transports
        if not GetLoadTransports(platoon) then
            return
        end

        -- Find landing location and unload units at right spot
        local landingLocation
        if ScenarioInfo.Options.Difficulty and ScenarioInfo.Options.Difficulty == 3 then
            landingLocation = PlatoonChooseRandomNonNegative(aiBrain, landingPositions, 1)
        else
            landingLocation = PlatoonChooseRandomNonNegative(aiBrain, landingPositions, 1)
        end

        cmd = platoon:UnloadAllAtLocation(landingLocation)

        local attached = true
        while attached do
            WaitSeconds(3)
            if not aiBrain:PlatoonExists(platoon) then
                return
            end

            attached = false
            for num, unit in platoon:GetPlatoonUnits() do
                if not unit:IsDead() and not EntityCategoryContains(categories.TRANSPORTATION, unit) and unit:IsUnitState('Attached') then
                    attached = true
                    break
                end
            end
        end

        if(data.TransportReturn) then
        	-- LOG('*AI DEBUG: Returning transports to pool Call')
            ReturnTransportsToPool(platoon,data)
        end

        while aiBrain:PlatoonExists(platoon) do
            local totalCapturing = 0
            for k,v in platoon:GetPlatoonUnits() do
                if not v:IsDead() and v:IsUnitState('Capturing') then
                    totalCapturing = totalCapturing + 1
                end
            end
            if currentState == 'Capturing' and totalCapturing == 0 then
                currentState = 'None'
            end

            -- If we are too far away from route, return to route
            local captureTargets = {}
            local newTarget = findCaptureTarget(platoon, route, radius, captureTargets)

            -- If we are not capturing, test if anything is in range
            if currentState != 'Returning' and currentState != 'Capturing' and newTarget != false then
                platoon:Stop()
                for k,v in platoon:GetPlatoonUnits() do
                    newTarget = findCaptureTarget(platoon, route, radius, captureTargets)
                    if newTarget then
                        if data.CallbackFunction then
                            newTarget.Callbacks.OnCapturedNewUnit:Add(captureCallback, data)
                        end
                        table.insert(captureTargets, newTarget)
                        IssueCapture( {v}, newTarget )
                    else
                        break
                    end
                end
                currentState = 'Capturing'

            -- If we are not patrolling, start patrol
            elseif currentState != 'Patrolling' and currentState != 'Capturing' and currentState != 'Returning' then
                -- if the route is empty, start over
                if table.empty(patrolRoute) then
                    patrolRoute = table.copy(route)
                end
                startPatrol(platoon, patrolRoute)
                currentState = 'Patrolling'
            end

            for k,v in patrolRoute do
                -- Checking if we are within 7 o-grids
                if not platoon:GetPlatoonPosition() then
                    LOG('*AI DEBUG: CaptureRouteWithTransports Trying to get VDist3XZSq but platoon position was nil')
                    break
                end
                if not v then
                    LOG('*AI DEBUG: CaptureRoute Trying to get VDist3XZSq but v was nil')
                    break
                end
                if VDist3XZSq( platoon:GetPlatoonPosition(), v ) < 49 then
                    table.remove( patrolRoute, k )
                    break
                end
            end

            WaitSeconds(1)
        end
    end,
}


-- -----------------------------------------------------------------
-- Utility Function
-- Function that gets the correct number of transports for a platoon
-- -----------------------------------------------------------------
function GetTransportsThread(platoon)
    local data = platoon.PlatoonData
    local aiBrain = platoon:GetBrain()

    local neededSlots = GetNumSlotsNeeded(platoon)
    local numTransports = 0
    local transportsNeeded = neededSlots > 0
    local transSlotTable = {}

    if transportsNeeded then
        local pool = aiBrain:GetPlatoonUniquelyNamed( 'TransportPool' )
        if not pool then
            pool = aiBrain:MakePlatoon('None', 'None')
            pool:UniquelyNamePlatoon('TransportPool')
        end

        while transportsNeeded do
            neededSlots = GetNumSlotsNeeded(platoon)

            -- determine the number of slots we have at our disposal
            local availableSlots = 0
            for k,v in platoon:GetPlatoonUnits() do
                if not v:IsDead() then
                    if EntityCategoryContains( categories.TRANSPORTATION, v ) then
                        availableSlots = availableSlots + v:GetNumberOfStorageSlots()
                    end
                end
            end

            -- see if we have enough slots
            if availableSlots > neededSlots then
                transportsNeeded = false
            end

            if transportsNeeded then
                local location = platoon:GetPlatoonPosition()

                -- Determine distance of transports from platoon
                local transports = {}
                for k,unit in pool:GetPlatoonUnits() do
                    if EntityCategoryContains( categories.TRANSPORTATION, unit ) and not unit:IsUnitState('Busy') then
                        table.insert( transports, unit )
                    end
                end

                if table.getn(transports) > 0 then
                    local sortedList = SortEntitiesByDistanceXZ(location, transports)

                    -- Take transports as needed
                    for i=1,table.getn(sortedList) do
                        if transportsNeeded then
                            aiBrain:AssignUnitsToPlatoon(platoon, {sortedList[i]}, 'Scout', 'GrowthFormation')
                            numTransports = numTransports + 1

                            availableSlots = availableSlots + sortedList[i]:GetNumberOfStorageSlots()

                            if availableSlots > neededSlots then
                                transportsNeeded = false
                            end
                        end
                    end
                end
            end

            if transportsNeeded then
                WaitSeconds(7)
                if not aiBrain:PlatoonExists(platoon) then
                    return false
                end
                local unitFound = false
                for k,unit in platoon:GetPlatoonUnits() do
                    if not EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                        unitFound = true
                        break
                    end
                end
                if not unitFound then
                    ReturnTransportsToPool(platoon, data)
                    return false
                end
            end
        end
    end

    return numTransports
end

-- -------------------------------------------------------------
-- Utility Function
-- Returns the number of transports required to move the platoon
-- -------------------------------------------------------------
function GetNumSlotsNeeded(platoon)
    local slotsNeeded = 0

    for k, v in platoon:GetPlatoonUnits() do
        if EntityCategoryContains( categories.TRANSPORTATION, v ) or v:IsDead() then
            continue
        end
        slotsNeeded = slotsNeeded + v:GetBlueprint().Transport.StorageSize
    end

    return slotsNeeded
end

-- ------------------------------------------
-- Utility Function
-- Get and load transports with platoon units
-- ------------------------------------------
function GetLoadTransports(platoon)
    local numTransports = GetTransportsThread(platoon)

    if not numTransports then
        return false
    end

    platoon:Stop()
    IssueClearCommands( platoon:GetPlatoonUnits() )

    local aiBrain = platoon:GetBrain()
    WaitTicks(1)
    if not aiBrain:PlatoonExists(platoon) then
        return false
    end

    -- Move the units together
    local position = { 0, 0, 0 }
    for k,v in platoon:GetPlatoonUnits() do
        if EntityCategoryContains( categories.AIR, v ) then
            continue
        end

        position = v:GetPosition()
    end

    if position then
        --LOG('*TRANSPORT DEBUG: Moving platoon together - ' .. position[1] .. ', ' .. position[3] )
        platoon:MoveToLocation( position, false )
    else
        --LOG('*TRANSPORT DEBUG: No position')
    end

    local nearby = true
    repeat
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(platoon) then
            return false
        end
        nearby = true
        for k,v in platoon:GetPlatoonUnits() do
            if not position then
                LOG('*AI DEBUG: TransportAttackPlatoonThreads::GetLoadTransports Trying to get VDist3XZSq but position was nil')
                return false
            end
            if not v:GetPosition() then
                LOG('*AI DEBUG: CaptureRoute Trying to get VDist3XZSq but v:GetPosition() was nil')
                return false
            end
            local dist = VDist3XZSq(position, v:GetPosition())
            if not v:IsDead() and dist > 625 then
                nearby = false
                break
            end
        end
    until nearby

    -- Load transports
    local transportTable = {}
    local leftoverUnits = {}

    local scoutUnits = platoon:GetSquadUnits('scout') or {}

    for num,unit in scoutUnits do
        local id = unit:GetUnitId()
        table.insert( transportTable,
            {
                Transport = unit,
                RemainingSlots = unit:GetNumberOfStorageSlots(),
                Units = {},
            }
        )
    end

    transportTable, leftoverUnits = SortUnitsOnTransports(transportTable, platoon:GetPlatoonUnits())

    if table.getn(leftoverUnits) > 0 then
        WARN('*DEBUG: Leftover units in loading transports. I have no idea what to do about this, but Im working on it. Love, DFS')
    end

    -- Old load transports
    local monitorUnits = {}
    local cmds = {}
    for num, data in transportTable do
        if table.getn( data.Units ) > 0 then
            LOG('*AI DEBUG: Loading transports')
            for k,v in data.Units do
                if v:IsUnitState('Attached') then
                    LOG('*AI DEBUG: Unit attached = ' .. v:GetUnitId() )
                end
            end
            IssueClearCommands( data.Units )
            IssueClearCommands( { data.Transport } )
            data.Command = IssueTransportLoad( data.Units, data.Transport )
            for k,v in data.Units do table.insert( monitorUnits, v) end
        end
    end

    local attached = true
    repeat
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(platoon) then
            return false
        end
        attached = true
        for k,v in monitorUnits do
            if not v:IsDead() and not v:IsUnitState('Attached') then
                attached = false
                break
            end
        end

        if not attached then
            for num,data in transportTable do
                if not data.Command or not IsCommandDone(data.Command) then
                    continue
                end

                local i = table.getn( data.Units )
                if i == 0 then
                    continue
                end

                while i > 0 do
                    if data.Units[i]:IsUnitState('Attached') then
                        table.remove( data.Units, i )
                    end

                    i = i - 1
                end

                if table.getn( data.Units ) > 0 then
                    LOG('*TRANSPORT DEBUG: Reissuing transport load')
                    data.Command = IssueTransportLoad( data.Units, data.Transport )
                end
            end
        end

    until attached

    --LOG('*TRANSPORT DEBUG: Loading complete')

    -- Any units that aren't transports and aren't attached send back to pool
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')

    for k,unit in platoon:GetPlatoonUnits() do
        if unit:IsDead() then
            continue
        end

        if not EntityCategoryContains( categories.TRANSPORTATION, unit ) then
            if not unit:IsUnitState('Attached') then
                aiBrain:AssignUnitsToPlatoon( pool, {unit}, 'Unassigned', 'None' )
                --LOG('*DEBUG: ADDING UNIT TO LEFTOVER POOL')
            end
        end
    end
    return true
end


-- ------------------------------------------------
-- Utility function
-- Sorts units onto transports distributing equally
-- ------------------------------------------------
function SortUnitsOnTransports( transportTable, unitTable, numSlots )
    local leftoverUnits = {}
    for num, unit in unitTable do
        -- do not load any transports on other transports
        if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
            continue
        end

        local slotSize = unit:GetBlueprint().Transport.StorageSize
        local inserted = false

        for tNum,tData in transportTable do
            if tData.RemainingSlots >= slotSize then
                table.insert( tData.Units, unit )
                inserted = true
                tData.RemainingSlots = tData.RemainingSlots - slotSize
                break
            end
        end

        if not inserted then
            --LOG('*AI DEBUG: NO TRANSPORT FOUND')
            table.insert(leftoverUnits, unit)
        end
    end
    return transportTable, leftoverUnits
end

-- ------------------------------------------------------------------------------------
-- Utility Function
-- Takes transports in platoon, returns them to pool, flys them back to return location
-- ------------------------------------------------------------------------------------
function ReturnTransportsToPool(platoon, data)
    -- Put transports back in TPool
	-- LOG('*AI DEBUG: Returning transports to pool - Begin')
    local aiBrain = platoon:GetBrain()
    for k,unit in platoon:GetPlatoonUnits() do
        if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
			-- LOG('*AI DEBUG: Returning transports to pool - Unit found')
            -- If a route was given, reverse the route on return
            if data.TransportRoute then
				-- LOG('*AI DEBUG: Returning transports to pool - data.TransportRoute')
                aiBrain:AssignUnitsToPlatoon( 'TransportPool', {unit}, 'Scout', 'None' )
                for i=table.getn(data.TransportRoute),1,-1 do
                    if type(data.TransportRoute[1]) == 'string' then
                        IssueMove( {unit}, ScenarioUtils.MarkerToPosition(data.TransportRoute[i]) )
                    else
                        IssueMove( {unit}, data.TransportRoute[i])
                    end
                end
                if data.TransportReturn then
                    if type(data.TransportReturn) == 'string' then
                        IssueMove( {unit}, ScenarioUtils.MarkerToPosition(data.TransportReturn) )
                    else
                        IssueMove( {unit}, data.TransportReturn)
                    end
                end
                -- If a route chain was given, reverse the route on return
            elseif data.TransportChain then
				-- LOG('*AI DEBUG: Returning transports to pool - data.TransportChain')
                local transPositionChain = {}
                transPositionChain = ScenarioUtils.ChainToPositions(data.TransportChain)
                aiBrain:AssignUnitsToPlatoon( 'TransportPool', {unit}, 'Scout', 'None' )
                for i=table.getn(transPositionChain),1,-1 do
                    IssueMove( {unit}, transPositionChain[i] )
                end
                if data.TransportReturn then
                    if type(data.TransportReturn) == 'string' then
                        IssueMove( {unit}, ScenarioUtils.MarkerToPosition(data.TransportReturn) )
                    else
                        IssueMove( {unit}, data.TransportReturn)
                    end
                end
                -- return to Transport Return if no route
            else
				-- LOG('*AI DEBUG: Returning transports to pool - fall through')
                if data.TransportReturn then
					-- LOG('*AI DEBUG: Returning transports to pool - data.TransportReturn')
                    aiBrain:AssignUnitsToPlatoon( 'TransportPool', {unit}, 'Scout', 'None' )
                    if type(data.TransportReturn) == 'string' then
						-- LOG('*AI DEBUG: Returning transports to pool - data.TransportRoute as string')
                        IssueMove( {unit}, ScenarioUtils.MarkerToPosition(data.TransportReturn) )
                    else
						-- LOG('*AI DEBUG: Returning transports to pool - data.TransportRoute as position')
                        IssueMove( {unit}, data.TransportReturn)
                    end
                end
            end
        end
    end
end

-- -----------------------------------------
-- Utility Function
-- Returns location randomly with threat > 0
-- -----------------------------------------
function PlatoonChooseRandomNonNegative( aiBrain, locationList, ringSize )
    local landingList = {}
    for k, v in locationList do
        if aiBrain:GetThreatAtPosition( v, ringSize, true ) > 0 then
			WaitSeconds(0.1)
            table.insert(landingList, v)
        end
    end
    local loc = landingList[Random(1,table.getn(landingList))]
    if not loc then
        loc = locationList[Random(1,table.getn(locationList))]
    end
    return loc
end

-- -------------------------------------------------------
-- Utility Function
-- Arranges a route from highest to lowest based on threat
-- -------------------------------------------------------
function PlatoonChooseHighestAttackRoute(aiBrain, locationList, ringSize)
    local attackRoute = {}
    local tempRoute = {}

    for k, v in locationList do
        table.insert(tempRoute, v)
    end

    local num = table.getn(tempRoute)
    for i = 1, num do
        table.insert(attackRoute, PlatoonChooseHighest(aiBrain, tempRoute, ringSize))
        for k, v in tempRoute do
            if(attackRoute[i] == v) then
                table.remove(tempRoute, k)
                break
            end
        end
    end

    return attackRoute
end

-- ----------------------------------------
-- Utility Function
-- Returns location with the highest threat
-- ----------------------------------------
function PlatoonChooseHighest( aiBrain, locationList, ringSize, location )
    local bestLocation = locationList[1]
    local highestThreat = 0
    local currThreat = 0

    for k, v in locationList do
        currThreat = aiBrain:GetThreatAtPosition( v, ringSize, true )
		WaitSeconds(0.1)
        if(currThreat > highestThreat) and (not location or location ~= v) then
            highestThreat = currThreat
            bestLocation = v
        end
    end

    return bestLocation
end

