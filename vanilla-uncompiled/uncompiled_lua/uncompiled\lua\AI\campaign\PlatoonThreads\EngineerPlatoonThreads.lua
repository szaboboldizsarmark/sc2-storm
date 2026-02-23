local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-- CaptureRoute - This thread randomly chooses a chain from a table and tells the platoon to patrol it
-- Data = {
--   CaptureChain = string, -- Name of chain to capture along
--   CaptureRadius = number or 15, -- Radius to search for captureable targets around platoon
--   AnnounceRoute = bool, -- if set it will announce which attack route the attack is on
-- }

function startPatrol(platoon, route, index)
    for k,v in route do
        platoon:MoveToLocation(v, false)
    end
end

function findCaptureTarget(platoon, route, radius, captureTargets)
    local platPos = platoon:GetPlatoonPosition()
    if not platPos then
        return false
    end
    
    local nearbyUnits = platoon:GetBrain():GetUnitsAroundPoint( categories.LAND + categories.NAVAL + categories.STRUCTURE - categories.UPGRADEMODULE, platPos, radius, 'Enemy' )
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
    Name = 'CaptureRoute',
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
                -- Checking if we are within 20 o-grids
                if not platoon:GetPlatoonPosition() then
                    LOG('*AI DEBUG: CaptureRoute Trying to get VDist3XZSq but platoon position was nil')
                    break
                end
                if not v then
                    LOG('*AI DEBUG: CaptureRoute Trying to get VDist3XZSq but v was nil')
                    break
                end
                if VDist3XZSq( platoon:GetPlatoonPosition(), v ) < 20 * 20 then
                    table.remove( patrolRoute, k )
                    break
                end
            end

            WaitSeconds(1)
        end
    end,
}

-- BuildExperimental - This thread tells an engineer to build an experimental at a location, give the experimental a behavior once built,
--                     and gives the engineer a behavior once building is complete
-- Data = {
--   experimentalID = string, -- ID of experimental to build
--   experimentalBehavior = fucntion, -- Platoon behavior to assign to the experimental
--   experimentalCategory = string or category -- Category of the experimental to check for the existence of
--   patrolChain = string -- Marker chain for the engineer to patrol
-- }

function doneBuildingCallback(data, eng, unitBeingBuilt)
    if data.experimentalBehavior and unitBeingBuilt and not unitBeingBuilt:IsDead() then
        data.experimentalBehavior(unitBeingBuilt)
    end
    eng.Callbacks.OnStopBuild:Remove(doneBuildingCallback)
end

CAIPlatoonThreadBlueprint {
    Name = 'BuildExperimental',
    Function = function(platoon, army, data)
        
        if data.Announce then
            if platoon.PlatoonData and platoon.PlatoonData.PlatoonName then
                LOG('*AI DEBUG: OpAI = ' .. platoon.PlatoonData.PlatoonName .. ' - building experimental - ' .. data.experimentalID)
            else
                LOG('*AI DEBUG: OpAI = unknown - building experimental - ' .. data.experimentalID)
            end
        end

        local route = ScenarioUtils.ChainToPositions(data.patrolChain)
        local patrolRoute = table.copy(route)
        local expCategory = data.experimentalCategory
        
        local aiBrain = platoon:GetBrain()
        local currentState = 'None'

        local engineer = platoon:GetPlatoonUnits()[1]        
        while aiBrain:PlatoonExists(platoon) do
            if currentState == 'Building' and engineer:IsIdleState() then
                currentState = 'None'
            end
            
            
            if type(expCategory) == 'string' then
                expCategory = ParseEntityCategory(string.lower(expCategory))
            end
                
            local numUnits = table.getn(aiBrain:GetListOfUnits( expCategory, false ))
            
            if numUnits == 0 and currentState != 'Building' then            
                local unitData = import('/lua/sim/ScenarioUtilities.lua').FindUnit(data.experimentalID, Scenario.Armies[army].Units)
                if not unitData then
                    if platoon.PlatoonData and platoon.PlatoonData.PlatoonName then
                        LOG('*AI DEBUG: OpAI = ' .. platoon.PlatoonData.PlatoonName .. ' - unable to find unit data for - ' .. data.experimentalID)
                    else
                        LOG('*AI DEBUG: OpAI = unknown - unable to find unit data for - ' .. data.experimentalID)
                    end
                end
                platoon:Stop()
                if engineer and not engineer:IsDead() then
                    currentState = 'Building'
                    aiBrain:BuildStructure(engineer, unitData.type, { unitData.Position[1], unitData.Position[3], 0}, false)
                    engineer.Callbacks.OnStopBuild:Add(doneBuildingCallback, data)
                end
            elseif currentState != 'Building' then
                platoon:Stop()
                if table.empty(patrolRoute) then
                    patrolRoute = table.copy(route)
                end
                currentState = 'Patrolling'
                startPatrol(platoon, patrolRoute)
            end
            WaitSeconds(10)
        end
    end,
}