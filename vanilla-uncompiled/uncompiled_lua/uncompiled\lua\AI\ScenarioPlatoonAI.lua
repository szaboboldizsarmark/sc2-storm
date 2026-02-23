--****************************************************************************
--**
--**  File     :  /lua/ai/ScenarioPlatoonAI.lua
--**  Author(s):  Drew Staltman
--**
--**  Summary  :  Houses a number of AI threads that are used in operations
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local Utilities = import('/lua/system/utilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local PlatoonPatrolRoute = import('/lua/sim/ScenarioFramework.lua').PlatoonPatrolRoute
local PlatoonPatrolChain = import('/lua/sim/ScenarioFramework.lua').PlatoonPatrolChain
local GroupPatrolRoute = import('/lua/sim/ScenarioFramework.lua').GroupPatrolRoute
local BuildingTemplates = import('/lua/ai/BuildingTemplates.lua').BuildingTemplates

--------------------------------------------------------------------
---- PlatoonAttackClosestUnit
----     - Attacks Closest Unit the AI Brain knows about
---- PlatoonData -
--------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: PlatoonAttackClosestUnit = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function PlatoonAttackClosestUnit(platoon)
    local aiBrain = platoon:GetBrain()
    local target

    while not target do
        target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS)
        WaitSeconds(3)
    end

    platoon:Stop()

    local cmd = platoon:AggressiveMoveToLocation( target:GetPosition() )
    while aiBrain:PlatoonExists(platoon) do
        if target ~= nil then
            if target:IsDead() or not platoon:IsCommandsActive(cmd) then
                target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS-categories.WALL)
                if target and not target:IsDead() then
                    platoon:Stop()
                    cmd = platoon:AggressiveMoveToLocation( target:GetPosition() )
                end
            end
        else
            target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS)
        end
        WaitSeconds(17)
    end
end

----------------------------------------------------
-- function: BuildOnce = AddFunction     doc = ""
--
-- parameter 0: string    platoon = "default_platoon"
--
----------------------------------------------------
function BuildOnce(platoon)
    local aiBrain = platoon:GetBrain()
    if aiBrain:PBMHasPlatoonList() then
        aiBrain:PBMSetPriority(platoon, 0)
    else
        platoon.BuilderHandle:SetPriority(0)
    end
end

--------------------------------------------------------------------------------------------------------------
-- function: DefaultOSBasePatrol = AddFunction   doc = "Please work function docs."
--
-- parameter 0: string   platoon     = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function DefaultOSBasePatrol(platoon)
    local aiBrain = platoon:GetBrain()
    local master = string.sub(platoon.PlatoonData.BuilderName, 11)
    local facIndex = aiBrain:GetFactionIndex()
    local chain = false
    if platoon.PlatoonData.LocationType and Scenario.Chains[aiBrain.Name .. '_' .. platoon.PlatoonData.LocationType .. '_BasePatrolChain'] then
        chain = aiBrain.Name .. '_' .. platoon.PlatoonData.LocationType .. '_BasePatrolChain'
    elseif Scenario.Chains[master .. '_BasePatrolChain'] then
        chain = master .. '_BasePatrolChain'
    elseif Scenario.Chains[aiBrain.Name .. '_BasePatrolChain'] then
        chain = aiBrain.Name .. '_BasePatrolChain'
    end
    if chain then
        platoon.PlatoonData.PatrolChain = chain
        PatrolThread(platoon)
    end
end

--------------------------------------------------------------------
---- PlatoonAssignOrders
----     - Assigns orders from the editor to a platoon
---- PlatoonData -
----     OrderName - Name of the Order from the editor
----     Target - Handle to Unit used in orders that require a target (OPTIONAL)
--------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: PlatoonAssignOrders = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function PlatoonAssignOrders(platoon)
    platoon:Stop()
    local data = platoon.PlatoonData
    if not data.OrderName then
        error('*SCENARIO PLATOON AI ERROR: No OrderName given to PlatoonAssignOrders AI Function', 2)
        return false
    end
    ScenarioUtils.AssignOrders( data.OrderName, platoon, data.Target)
end

--------------------------------------------------------------------
---- PlatoonAttackHighestThreat
----     - Attacks Location on the map with the highest threat
---- PlatoonData -
--------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: PlatoonAttackHighestThreat = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function PlatoonAttackHighestThreat(platoon)
    local patrol = false
    local aiBrain = platoon:GetBrain()
    local location,threat = aiBrain:GetHighestThreatPosition(1, true)
    platoon:Stop()
    local cmd = platoon:AggressiveMoveToLocation(location)
    while aiBrain:PlatoonExists(platoon) do
        if not platoon:IsCommandsActive(cmd) then
            location,threat = aiBrain:GetHighestThreatPosition(1, true)
            if threat > 0 then
                platoon:Stop()
                cmd = platoon:AggressiveMoveToLocation(location)
            end
        end
        WaitSeconds(13)
    end
end

--------------------------------------------------------------------
---- PlatoonAttackLocation
----     - Attack moves to a specific location on the map
----     - After reaching location will attack highest threat
---- PlatoonData -
----     Location - (REQUIRED) location on the map to attack move to
--------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: PlatoonAttackLocation = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function PlatoonAttackLocation(platoon)
    platoon:Stop()
    local data = platoon.PlatoonData
    if not data.Location then
        error('*SCENARIO PLATOON AI ERROR: PlatoonAttackLocation requires a Location to operate', 2)
    end
    local location = data.Location
    if type(location) == 'string' then
        location = ScenarioUtils.MarkerToPosition(location)
    end
    local aiBrain = platoon:GetBrain()
    local cmd = platoon:AggressiveMoveToLocation(location)
    local threat = 0
    while aiBrain:PlatoonExists(platoon) do
        if not platoon:IsCommandsActive(cmd) then
            location, threat = platoon:GetBrain():GetHighestThreatPosition(1, true)
            platoon:Stop()
            cmd = platoon:AggressiveMoveToLocation(location)
        end
        WaitSeconds(13)
    end
end

--------------------------------------------------------------------
---- PlatoonAttackLocationList
----     - Attack moves to a location chosen from a list
----     - Location can be the highest threat or the lowest non-negative threat
----     - After reaching location will attack next location from the list
---- PlatoonData -
----     LocationList - (REQUIRED) location on the map to attack move to
----     LocationChain - (REQUIRED) Chain on the map to attack move to
----     High - true will attack highest threats first, false lowest - defaults to false/lowest
--------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: PlatoonAttackLocationList = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function PlatoonAttackLocationList(platoon)
    platoon:Stop()
    local location = nil
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData
    if not data.LocationList and not data.LocationChain then
        error('*SCENARIO PLATOON AI ERROR: PlatoonAttackLocationList requires a LocationList or LocationChain in PlatoonData to operate', 2)
    end
    local positions = {}
    if data.LocationChain then
        positions = ScenarioUtils.ChainToPositions(data.LocationChain)
    else
        for k,v in data.LocationList do
            if type(v) == 'string' then
                table.insert(positions, ScenarioUtils.MarkerToPosition(v))
            else
                table.insert(positions, v)
            end
        end
    end
    if data.High then
        location = PlatoonChooseHighest( platoon:GetBrain(), positions, 1)
    else
        location = PlatoonChooseLowestNonNegative( platoon:GetBrain(), positions, 1)
    end
    local cmd
    if location then
        cmd = platoon:AggressiveMoveToLocation(location)
    end
    while aiBrain:PlatoonExists(platoon) do
        if not location or not platoon:IsCommandsActive(cmd) then
            if data.High then
                location = PlatoonChooseHighest( platoon:GetBrain(), positions, 1, location )
            else
                location = PlatoonChooseLowestNonNegative( platoon:GetBrain(), positions, 1, location )
            end
            if location then
                platoon:Stop()
                cmd = platoon:AggressiveMoveToLocation(location)
            end
        end
        WaitSeconds(13)
    end
end


--------------------------------------------------------------------------------------------------------------------
---- MoveToThread
----     - Moves to a set of locations
----
---- PlatoonData
----     - MoveToRoute - List of locations to move to
----     - MoveChain - Chain of locations to move
----     - UseTransports - boolean, if true, use transports to move
----
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: MoveToThread = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function MoveToThread(platoon)
    local data = platoon.PlatoonData

    if(data) then
        if(data.MoveRoute or data.MoveChain) then
            local movePositions = {}
            if data.MoveChain then
                movePositions = ScenarioUtils.ChainToPositions(data.MoveChain)
            else
                for k, v in data.MoveRoute do
                    if type(v) == 'string' then
                        table.insert(movePositions, ScenarioUtils.MarkerToPosition(v))
                    else
                        table.insert(movePositions, v)
                    end
                end
            end
            if(data.UseTransports) then
                for k, v in movePositions do
                    platoon:MoveToLocation(v, data.UseTransports)
                end
            else
                for k, v in movePositions do
                    platoon:MoveToLocation(v, false)
                end
            end
        else
            error('*SCENARIO PLATOON AI ERROR: MoveToRoute or MoveChain not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end


--------------------------------------------------------------------------------------------------------------------
---- PatrolThread
----     - Patrols a set of locations
----
---- PlatoonData
----     - PatrolRoute - List of locations to patrol
----     - PatrolChain - Chain of locations to patrol
----
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: PatrolThread = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function PatrolThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if(data) then
        if(data.PatrolRoute or data.PatrolChain) then
            if data.PatrolChain then
                PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions(data.PatrolChain))
            else
                for k,v in data.PatrolRoute do
                    if type(v) == 'string' then
                        platoon:Patrol(ScenarioUtils.MarkerToPosition(v))
                    else
                        platoon:Patrol(v)
                    end
                end
            end
        else
            error('*SCENARIO PLATOON AI ERROR: PatrolRoute or PatrolChain not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end


--------------------------------------------------------------------------------------------------------------------
---- RandomPatrolThread
----     - Gives a platoon a random patrol path from a set of locations
----
---- PlatoonData
----     - PatrolRoute - List of locations to patrol
----     - PatrolChain - Chain of locations to patrol
----
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: RandomPatrolThread = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function RandomPatrolThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if(data) then
        if(data.PatrolRoute or data.PatrolChain) then
            if data.PatrolChain then
                PlatoonPatrolRoute(platoon,GetRandomPatrolRoute(data.PatrolChain))
            else
                local route = {}
                for k,v in data.PatrolRoute do
                    if type(v) == 'string' then
                        table.insert(route, ScenarioUtils.MarkerToPosition(v))
                    else
                        table.insert(route,v)
                    end
                end
                PlatoonPatrolRoute(platoon, GetRandomPatrolRoute(route))
            end
        else
            error('*SCENARIO PLATOON AI ERROR: PatrolRoute or PatrolChain not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end


--------------------------------------------------------------------------------------------------------------------
---- RandomDefensePatrolThread
----     - Gives a platoon a random patrol path from a set of locations
----
---- PlatoonData
----     - PatrolChain - Chain of locations to patrol
----
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: RandomDefensePatrolThread = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function RandomDefensePatrolThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if(data) then
        if(data.PatrolChain) then
            for k, v in platoon:GetPlatoonUnits() do
                GroupPatrolRoute({v}, GetRandomPatrolRoute(data.PatrolChain))
            end
        else
            error('*SCENARIO PLATOON AI ERROR: PatrolChain not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end

--------------------------------------------------------------------------------------------------------------------
---- PatrolChainPickerThread
----     - Gives a platoon a random patrol chain from a set of chains
----
---- PlatoonData
----     - PatrolChains - List of chains to choose from
----
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- function: PatrolChainPickerThread = AddFunction	doc = "Please work function docs."
--
-- parameter 0: string	platoon         = "default_platoon"
--
--------------------------------------------------------------------------------------------------------------
function PatrolChainPickerThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if(data) then
        if(data.PatrolChains) then
            local chain = Random(1, table.getn(data.PatrolChains))
            PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions(data.PatrolChains[chain]))
            --LOG('Picked chain number ', chain)
        else
            error('*SCENARIO PLATOON AI ERROR: PatrolChains not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end





-- -----------------
-- UTILITY FUNCTIONS
-- -----------------


-- ------------------------------------------------------
-- Utility Function
-- Set Ready Variable and wait for Wait Variable if given
-- ------------------------------------------------------
function ReadyWaitVariables(data)
    -- Set ready and check wait variable after upgraded and/or loaded on transport
    -- Just prior to moving the unit
    if data.ReadyVariable then
        ScenarioInfo.VarTable[data.ReadyVariable] = true
    end

    if data.WaitVariable then
        while not ScenarioInfo.VarTable[data.WaitVariable] do
            WaitSeconds(5)
            if not aiBrain:PlatoonExists(platoon) then
                return false
            end
        end
    end
    return true
end


-- ------------------------------------------------------
-- Utility function
-- Generates a random patrol route for RandomPatrolThread
-- ------------------------------------------------------
function GetRandomPatrolRoute(patrol)
	if type(patrol) == 'string' then
		patrol = ScenarioUtils.ChainToPositions(patrol)
	end

    local randPatrol = {}
    local tempPatrol = {}
    for k, v in patrol do
        table.insert(tempPatrol, v)
    end

    local num = table.getn(tempPatrol)
    local rand
    for i = 1, num do
        rand = Random(1, num + 1 - i)
        table.insert(randPatrol, tempPatrol[rand])
        table.remove(tempPatrol, rand)
    end

    return randPatrol
end


-- ------------------------------------------------
-- Utility Function
-- Returns location with lowest non-negative threat
-- ------------------------------------------------
function PlatoonChooseLowestNonNegative( aiBrain, locationList, ringSize, location )
    local bestLocation = {}
    local bestThreat = 0
    local currThreat = 0
    local locationSet = false

    for k, v in locationList do
        currThreat = aiBrain:GetThreatAtPosition( v, ringSize, true )
		WaitSeconds(0.1)
        if not location or location ~= v then
            if (currThreat < bestThreat and currThreat > 0) or not locationSet then
                locationSet = true
                bestThreat = currThreat
                bestLocation = v
            end
        end
    end
    if not locationSet then
        bestLocation = locationList[1]
    end

    return bestLocation
end

-- --------------------------------------------------------
-- Utility Function
-- Returns location with lowest threat (including negative)
-- --------------------------------------------------------
function PlatoonChooseLowest(aiBrain, locationList, ringSize, location)
    local bestLocation = {}
    local locationSet = false
    local bestThreat = 0
    local currThreat = 0

    for k, v in locationList do
        currThreat = aiBrain:GetThreatAtPosition(v, ringSize, true)
		WaitSeconds(0.1)
        if not location or location ~= v then
            if (currThreat < bestThreat ) or not locationSet then
                locationSet = true
                bestThreat = currThreat
                bestLocation = v
            end
        end
    end
    if not locationSet then
        bestLocation = locationList[1]
    end

    return bestLocation
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

-- -------------------------------------------------
-- Utility Function
-- Arranges a route from lowest to highest on threat
-- -------------------------------------------------
function PlatoonChooseLowestAttackRoute(aiBrain, locationList, ringSize)
    local attackRoute = {}
    local tempRoute = {}

    for k, v in locationList do
        table.insert(tempRoute, v)
    end

    local num = table.getn(tempRoute)
    for i = 1, num do
        table.insert(attackRoute, PlatoonChooseLowestNonNegative(aiBrain, tempRoute, ringSize))
        for k, v in tempRoute do
            if(attackRoute[i] == v) then
                table.remove(tempRoute, k)
                break
            end
        end
    end

    return attackRoute
end


-- ---------------------------------------
-- Utility Function
-- NOT USED - Creates a route to something
-- ---------------------------------------
function GetRouteToVector(platoon, squad)
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData

    -- All vectors in the table
    aiBrain:SetUpAttackVectorsToArmy()
    local vectorTable = aiBrain:GetAttackVectors()
    local lowX = 10000
    local lowZ = 10000
    local highX = -1
    local highZ = -1
    for k, vec in vectorTable do
        if vec[1] < lowX then
            lowX = vec[1]
        end
        if vec[1] > highX then
            highX = vec[1]
        end
        if vec[3] < lowZ then
            lowZ = vec[3]
        end
        if vec[3] > highZ then
            highZ = vec[3]
        end
    end

    -- Check if route needs to be generated
    local atkVector = aiBrain:PickBestAttackVector(platoon, squad, 'Enemy', data.CompareCategory, data.CompareType)
    local pltPosition = platoon:GetSquadPosition(squad)
    local moveEW, moveNS
    if lowX > pltPosition[1] and lowX < atkVector[1] then
        moveEW = true
    elseif highX < pltPosition[1] and highX > atkVector[1] then
        moveEW = true
    end
    if lowZ > pltPosition[3] and lowZ < pltPosition[3] then
        moveNS = true
    elseif highZ < pltPosition[3] and highZ > pltPosition[3] then
        moveNS = true
    end

    ---- Move vector out
    if moveEW or moveNS then
        if atkVector[4] < 0 then
            moveEW = 'west'
        elseif atkVector[4] > 0 then
            moveEW = 'east'
        end
        if atkVector[6] < 0 then
            moveNS = 'north'
        elseif atkVector[6] > 0 then
            moveNS = 'south'
        end
        local route = {}
        route[1] = { atkVector[1], atkVector[2], atkVector[3] }
        local firstPoint = false
        while not firstPoint do
            route[1][1] = route[1][1] - atkVector[4]
            route[1][3] = route[1][3] - atkVector[6]
            if route[1][1] < lowX or route[1][1] > highX then
                firstPoint = true
            elseif route[1][3] < lowZ or route[1][3] > highZ then
                firstPoint = true
            end
        end
    end
end

-- ------------------------------------------------------------------
-- Utility Function
-- Moves a platoon along a route holding up the thread until finished
-- ------------------------------------------------------------------
function MoveAlongRoute(platoon, route)
    local cmd = false
    local aiBrain = platoon:GetBrain()

    -- move platoon along route
    for k,v in route do
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
    return true
end