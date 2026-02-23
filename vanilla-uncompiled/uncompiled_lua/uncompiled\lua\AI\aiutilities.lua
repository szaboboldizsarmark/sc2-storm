--SC2 FIX NEED: file contains specific unit references that are no longer valid - needs reolution - bfricks 9/19/08
--****************************************************************************
--**
--**  File     :  /lua/AI/aiutilities.lua
--**  Author(s): John Comes, Dru Staltman
--**
--**  Summary  :
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BuildingTemplates = import('/lua/ai/BuildingTemplates.lua').BuildingTemplates
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utils = import('/lua/system/utilities.lua')
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')

function AIGetEconomyNumbers(aiBrain)
    --LOG('*AI DEBUG: RETURNING ECONOMY NUMBERS FROM AIBRAIN ', repr(aiBrain))
    local econ = {}
    econ.MassTrend = aiBrain:GetEconomyTrend('MASS')
    econ.EnergyTrend = aiBrain:GetEconomyTrend('ENERGY')
    econ.MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS')
    econ.EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
    econ.EnergyIncome = aiBrain:GetEconomyIncome('ENERGY')
    econ.MassIncome = aiBrain:GetEconomyIncome('MASS')
    econ.EnergyUsage = aiBrain:GetEconomyUsage('ENERGY')
    econ.MassUsage = aiBrain:GetEconomyUsage('MASS')
    econ.EnergyRequested = aiBrain:GetEconomyRequested('ENERGY')
    econ.MassRequested = aiBrain:GetEconomyRequested('MASS')
    econ.EnergyEfficiency = math.min(econ.EnergyIncome / econ.EnergyRequested, 2)
    econ.MassEfficiency = math.min(econ.MassIncome / econ.MassRequested, 2)
    econ.MassRequested = aiBrain:GetEconomyRequested('MASS')
    econ.EnergyStorage = aiBrain:GetEconomyStored('ENERGY')
    econ.MassStorage = aiBrain:GetEconomyStored('MASS')

    if aiBrain.EconomyMonitorThread then
        local econTime = aiBrain:GetEconomyOverTime()
        
        econ.EnergyRequestOverTime = econTime.EnergyRequested
        econ.MassRequestOverTime = econTime.MassRequested
        
        econ.EnergyEfficiencyOverTime = math.min(econTime.EnergyIncome / econTime.EnergyRequested, 2)
        econ.MassEfficiencyOverTime = math.min(econTime.MassIncome / econTime.MassRequested, 2)
    end
        
    if econ.MassStorageRatio != 0 then
        econ.MassMaxStored = econ.MassStorage / econ.MassStorageRatio
    else
        econ.MassMaxStored = econ.MassStorage
    end
    if econ.EnergyStorageRatio != 0 then
        econ.EnergyMaxStored = econ.EnergyStorage / econ.EnergyStorageRatio
    else
        econ.EnergyMaxStored = econ.EnergyStorage
    end
    return econ
end

function AIGetMarkerLocations(aiBrain, markerType)
    --LOG('*AI DEBUG: ARMY 2: Getting Marker Locations of Type ', markerType)
    local markerList = {}
    
    if markerType == 'Start Location' then
        local tempMarkers = AIGetMarkerLocations( aiBrain, 'Blank Marker') 
        for k,v in tempMarkers do
            if string.sub(v.Name,1,5) == 'ARMY_' then 
                table.insert(markerList, { Position = v.Position, Name = v.Name})
            end
        end   
    else
        local markers = ScenarioUtils.GetMarkers()
        if markers then
            for k, v in markers do
                if v.type == markerType then
                    table.insert(markerList, { Position = v.position, Name = k } )
                end
            end
        end
    end
    
    return markerList
end

function AIGetMarkerLocationsEx(aiBrain, markerType)
    --LOG('*AI DEBUG: ARMY 2: Getting Marker Locations of Type ', markerType)
    local markers = ScenarioUtils.GetMarkers()
    local markerList = {}
    --Make a list of all the markers in the scenario that are of the markerType
    if markers then
        for k, v in markers do
            if v.type == markerType then
                v.name = k
                table.insert(markerList, v )
            end
        end
    end
    return markerList
end

function AIGetMarkersAroundLocation( aiBrain, markerType, pos, radius, threatMin, threatMax, threatRings, threatType )
    local markers = AIGetMarkerLocations( aiBrain, markerType )
    local returnMarkers = {}
    for k,v in markers do
        local dist = VDist2( pos[1], pos[3], v.Position[1], v.Position[3] )
        if dist < radius then
            if not threatMin then
                table.insert( returnMarkers, v )
            else
                local threat = aiBrain:GetThreatAtPosition( v.Position, threatRings, true, threatType or 'Overall' )
                if threat >= threatMin and threat <= threatMax then
                    table.insert( returnMarkers, v )
                end
            end
        end
    end
    return returnMarkers
end




function AIGetClosestMarkerLocation(aiBrain, markerType, startX, startZ, extraTypes)
    local markerList = AIGetMarkerLocations(aiBrain, markerType)
    if extraTypes then
        for num, pType in extraTypes do
            local moreMarkers = AIGetMarkerLocations(aiBrain, pType)
            if table.getn(moreMarkers) > 0 then
                for k,v in moreMarkers do
                    table.insert(markerList, { Position = v.Position, Name = v.Name } )
                end
            end
        end
    end
    local loc, distance, lowest, name = nil
    for k, v in markerList do
        local x = v.Position[1]
        local y = v.Position[2]
        local z = v.Position[3]
        distance = VDist2(startX, startZ, x, z)
        if not lowest or distance < lowest then
            loc = v.Position
            name = v.Name
            lowest = distance
        end
    end
    return loc, name
end


function GetOwnUnitsAroundPoint( aiBrain, category, location, radius, min, max, rings, tType )
    local units = aiBrain:GetUnitsAroundPoint( category, location, radius, 'Ally' )
    local index = aiBrain:GetArmyIndex()
    local retUnits = {}
    local checkThreat = false
    if min and max and rings then
        checkThreat = true
    end
    for k,v in units do
        if not v:IsDead() and not v:IsBeingBuilt() and v:GetAIBrain():GetArmyIndex() == index then
            if checkThreat then
                local threat = aiBrain:GetThreatAtPosition( v:GetPosition(), rings, true, tType or 'Overall' )
                if threat >= min and threat <= max then
                    table.insert(retUnits, v)
                end
            else
                table.insert(retUnits, v)
            end
        end
    end
    return retUnits
end


function RandomLocation(x,z)
    local finalX = x + Random(-30, 30)
    while finalX <= 0 or finalX >= ScenarioInfo.size[1] do
        finalX = x + Random(-30, 30)
    end
    local finalZ = z + Random(-30, 30)
    while finalZ <= 0 or finalZ >= ScenarioInfo.size[2] do
        finalZ = z + Random(-30, 30)
    end
    local movePos = { finalX, 0, finalZ }
    local height = GetTerrainHeight( movePos[1], movePos[3] )
    if GetSurfaceHeight( movePos[1], movePos[3] ) > height then
        height = GetSurfaceHeight( movePos[1], movePos[3] )
    end
    movePos[2] = height
    return movePos
end



-- ======================= --
--     Cheat Utilities     --
-- ======================= --
function SetupCheat(aiBrain, cheatBool)
    if cheatBool then
        aiBrain.CheatEnabled = true
        
        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
        for k,v in pool:GetPlatoonUnits() do
            -- Apply build rate and income buffs
            ApplyCheatBuffs(v)
        end
        
    end
end

function ApplyCheatBuffs(unit)
    if EntityCategoryContains( categories.COMMAND, unit ) then
        ApplyBuff(unit, 'IntelCheat')
    end
    ApplyBuff(unit, 'CheatIncome')
    ApplyBuff(unit, 'CheatBuildRate')
end