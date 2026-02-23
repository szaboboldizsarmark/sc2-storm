--****************************************************************************
--**
--**  File     :  /lua/AI/aiattackutilities.lua
--**  Author(s): John Comes, Dru Staltman, Robert Oates, Gautam Vasudevan
--**
--**  Summary  : This file was completely rewritten to best take advantage of
--**             the new influence map stuff Daniel provided. 
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BuildingTemplates = import('/lua/ai/BuildingTemplates.lua').BuildingTemplates
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local AIUtils = import('/lua/ai/aiutilities.lua')

-- types of threat to look at based on composition of platoon
local ThreatTable =
{
    Land = 'AntiSurface',
    Water = 'AntiSurface',
    Amphibious = 'AntiSurface',
    Air = 'AntiAir',
}

-------------------------------------------------------
--   Function: GetNavalPlatoonMaxRange
--   Args:
--       aiBrain - aiBrain to use
--       platoon - platoon to find range for
--   Description:
--       Finds the maximum range of the platoon, returns false if T1 or no range
--   Returns:
--       number or bool
-------------------------------------------------------
function GetNavalPlatoonMaxRange(aiBrain, platoon)
    local maxRange = 0
    local platoonUnits = platoon:GetPlatoonUnits()
    for _,unit in platoonUnits do
        if unit:IsDead() then
            continue
        end
        
        for _,weapon in unit:GetBlueprint().Weapons do
            if not weapon.FireTargetLayerCaps or not weapon.FireTargetLayerCaps.Water then
                continue
            end
        
            --Check if the weapon can hit land from water
            local canAttackLand = string.find(weapon.FireTargetLayerCaps.Water, 'Land', 1, true)
            
            if canAttackLand and weapon.MaxRadius > maxRange then 
                isTech1 = EntityCategoryContains(categories.TECH1, unit)
                maxRange = weapon.MaxRadius
                
                if weapon.BallisticArc == 'RULEUBA_LowArc' then
                    selectedWeaponArc = 'low'
                elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                    selectedWeaponArc = 'high'
                else 
                    selectedWeaponArc = 'none'
                end
            end
        end
    end
    
    if maxRange == 0 then
        return false
    end
    
    --T1 naval units don't hit land targets very well. Bail out!
    if isTech1 then
        return false
    end
    
    return maxRange, selectedWeaponArc
end

-------------------------------------------------------
--   Function: CheckNavalPathing
--   Args:
--       aiBrain - aiBrain to use
--       platoon - platoon to find best target for
--       location - spot we want to get to
--       maxRange - maximum range of the platoon (can bombard from water)
--   Description:
--       Finds if the platoon can move to the location given, or close enough to bombard
--   Returns:
--       bool
-------------------------------------------------------
function CheckNavalPathing(aiBrain, platoon, location, maxRange, selectedWeaponArc)    
    local platoonUnits = platoon:GetPlatoonUnits()
    selectedWeaponArc = selectedWeaponArc or 'none'
    
    local success, bestGoalPos
    local threatTargetPos
    local isTech1 = false

    local inWater = GetTerrainHeight(location[1], location[2]) < GetSurfaceHeight(location[1], location[2]) - 2
    
    --if this threat is in the water, see if we can get to it
    if inWater then
        success, bestGoalPos = CheckPlatoonPathingEx(platoon, {location[1], 0, location[2]})
    end
    
    --if it is not in the water or we can't get to it, then see if there is water within weapon range that we can get to
    if not success and maxRange then
        --Check vectors in 8 directions around the threat location at maxRange to see if they are in water.
        local rootSaver = maxRange / 1.4142135623 --For diagonals. X and Z components of the vector will have length maxRange / sqrt(2)
        local vectors = {
            {location[1],             0, location[2] + maxRange},   --up
            {location[1],             0, location[2] - maxRange},   --down
            {location[1] + maxRange,  0, location[2]},              --right
            {location[1] - maxRange,  0, location[2]},              --left
            
            {location[1] + rootSaver,  0, location[2] + rootSaver},   --right-up
            {location[1] + rootSaver,  0, location[2] - rootSaver},   --right-down
            {location[1] - rootSaver,  0, location[2] + rootSaver},   --left-up
            {location[1] - rootSaver,  0, location[2] - rootSaver},   --left-down
        }
        
        --Sort the vectors by their distance to us.
        table.sort(vectors, function(a,b)
            local distA = VDist2Sq(platoonPosition[1], platoonPosition[3], a[1], a[3])
            local distB = VDist2Sq(platoonPosition[1], platoonPosition[3], b[1], b[3])
            
            return distA < distB
        end)
        
        --Iterate through the vector list and check if each is in the water. Use the first one in the water that has enemy structures in range.
        for _,vec in vectors do
            inWater = GetTerrainHeight(vec[1], vec[3]) < GetSurfaceHeight(vec[1], vec[3]) - 2
            
            if inWater then
                success, bestGoalPos = CheckPlatoonPathingEx(platoon, vec)
            end
            
            if success then
                success = not aiBrain:CheckBlockingTerrain(bestGoalPos, threatTargetPos, selectedWeaponArc)
            end
            
            if success then 
                --I hate having to do this check, but the influence map doesn't have enough resolution and without it the boats
                --will just get stuck on the shore. The code hits this case about once every 5-10 seconds on a large map with 4 naval AIs
                local numUnits = aiBrain:GetNumUnitsAroundPoint( categories.NAVAL + categories.STRUCTURE, bestGoalPos, maxRange, 'Enemy')
                if numUnits > 0 then
                    break
                else
                    success = false
                end
            end
        end
    end
    
    return bestGoalPos
end





-------------------------------------------------------
--   Function: GetMostRestrictiveLayer
--   Args:
--       platoon - platoon to find best target for
--   Description:
--       set platoon.MovementLayer to the most restrictive movement layer 
--       of a given platoon, and return a representative unit
--   Returns:
--       The most restrictive layer of movement for a given platoon (string)
-------------------------------------------------------

function GetMostRestrictiveLayer(platoon)
    local unit = false
    platoon.MovementLayer = 'Air'
    for k,v in platoon:GetPlatoonUnits() do
        if not v:IsDead() then
            local mType = v:GetBlueprint().Physics.MotionType
            if ( mType == 'RULEUMT_AmphibiousFloating' or mType == 'RULEUMT_Hover' or mType == 'RULEUMT_Amphibious' ) and ( platoon.MovementLayer == 'Air' or platoon.MovementLayer == 'Water' ) then
                platoon.MovementLayer = 'Amphibious'
                unit = v
            elseif (mType == 'RULEUMT_Water' or mType == 'RULEUMT_SurfacingSub') and ( platoon.MovementLayer ~= 'Water' ) then
                platoon.MovementLayer = 'Water'
                unit = v
                break   --Nothing more restrictive than water, since there should be no mixed land/water platoons
            elseif mType == 'RULEUMT_Air' and platoon.MovementLayer == 'Air' then
                platoon.MovementLayer = 'Air'
                unit = v
            elseif ( mType == 'RULEUMT_Biped' or mType == 'RULEUMT_Land' ) and platoon.MovementLayer ~= 'Land' then
                platoon.MovementLayer = 'Land'
                unit = v
                break   --Nothing more restrictive than land, since there should be no mixed land/water platoons
            end
        end
    end

    return unit
end

-------------------------------------------------------
--   Function: PlatoonGenerateSafePathTo
--   Args:
--       aiBrain - aiBrain to use
--       platoonLayer - layer to use to generate safe path... e.g. 'Air', 'Land', etc.
--       start - table representing starting location
--       destination - table representing the destination location
--       optMaxMarkerDist - the maximum distance away a platoon should look for a pathing marker
--       optThreatWeight - the importance of threat when choosing a path. High weight generates longer, safer paths.
--   Description:
--       If there are pathing nodes available to this platoon's most restrictive movement type, then a path to the destination
--       can be generated while avoiding other high threat areas along the way.
--   Returns:
--       a table of locations representing the safest path to get to the specified destination
-------------------------------------------------------

function PlatoonGenerateSafePathTo(aiBrain, platoonLayer, start, destination, optThreatWeight, optMaxMarkerDist)   
        
    local location = start
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    
    --Get the closest path node at the platoon's position
    local startNode = GetClosestPathNodeInRadiusByLayer(location, optMaxMarkerDist, platoonLayer)
    if not startNode and platoonLayer == 'Amphibious' then
        return PlatoonGenerateSafePathTo(aiBrain, 'Land', start, destination, optThreatWeight, optMaxMarkerDist)
    end
    if not startNode then return false, 'NoStartNode' end
    
    --Get the matching path node at the destiantion
    local endNode = GetClosestPathNodeInRadiusByGraph(destination, optMaxMarkerDist, startNode.graphName)
    if not endNode and platoonLayer == 'Amphibious' then
        return PlatoonGenerateSafePathTo(aiBrain, 'Land', start, destination, optThreatWeight, optMaxMarkerDist)
    end    
    if not endNode then return false, 'NoEndNode' end
    
     --Generate the safest path between the start and destination
    local path = GeneratePath(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight)
    if not path and platoonLayer == 'Amphibious' then
        return PlatoonGenerateSafePathTo(aiBrain, 'Land', start, destination, optThreatWeight, optMaxMarkerDist)
    end    
    if not path then return false, 'NoPath' end
        
    --Insert the path nodes (minus the start node and end nodes, which are close enough to our start and destination) into our command queue.
    local finalPath = {}
    for i,node in path.path do
        if i > 1 and i < table.getn(path.path) then
              --platoon:MoveToLocation(node.position, false)
              table.insert(finalPath, node.position)
          end
    end

    --platoon:MoveToLocation(destination, false)
    table.insert(finalPath, destination)
    
    return finalPath
end



function AIFindUnitRadiusThreat( aiBrain, alliance, priTable, position, radius, tMin, tMax, tRing )
    local catTable = {}
    local unitTable = {}
    for k,v in priTable do
        table.insert( catTable, ParseEntityCategory(v) )
        table.insert( unitTable, {} )
    end

    local units = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, position, radius, alliance )
    for num, unit in units do
        for tNum, catType in catTable do
            if EntityCategoryContains( catType, unit ) then
                table.insert( unitTable[tNum], unit )
                break
            end
        end
    end

    local checkThreat = false
    if tMin and tMax and tRing then
        checkThreat = true
    end

    local distance = false
    local retUnit = false
    for tNum, catList in unitTable do
        for num, unit in catList do
            if not unit:IsDead() then
                local unitPos = unit:GetPosition()
                local useUnit = true
                if checkThreat then
					WaitSeconds(0.1)
                    local threat = aiBrain:GetThreatAtPosition( unitPos, tRing, true )
                    if not ( threat >= tMin and threat <= tMax ) then
                        useUnit = false
                    end
                end
                if useUnit then
                    local tempDist = VDist2( unitPos[1], unitPos[3], position[1], position[3] )
                    if tempDist < radius and ( not distance or tempDist < distance ) then
                        distance = tempDist
                        retUnit = unit
                    end
                end
            end
        end
        if retUnit then
            return retUnit
        end
    end
end