--****************************************************************************
--**
--**  File     :  /lua/ai/campaign/PlatoonThreads/BaseManagerPlatoonThreads.lua
--**  Author(s):  Drew Staltman
--**
--**  Summary  :  Houses a number of AI threads that are used by the Base Manager
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local AIEconUtils = import('/lua/ai/AIEconomyUtilities.lua')
local AIAttackUtils = import('/lua/ai/aiattackutilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TriggerFile = import('/lua/sim/scenariotriggers.lua')
local ScenarioPlatoonAI = import('/lua/ai/ScenarioPlatoonAI.lua')


-- Main function for base manager engineers
function BaseManagerSingleEngineerPlatoon(platoon, aiBrain, locationName)
    local bManager = aiBrain.CampaignAISystem.BaseManagers[locationName]
    local unit = platoon:GetPlatoonUnits()[1]
    unit.LocationName = locationName
    
    while aiBrain:PlatoonExists(platoon) do
        if bManager.Active and bManager.FunctionalityStates.Engineers then
        
            -- move to expansion base
            if bManager.FunctionalityStates.ExpansionBases and bManager:ExpansionBasesNeedEngineer(unit) then
                LOG('*AI DEBUG: ARMY ' .. unit:GetArmy() .. ' - Start Expanding base - ' .. locationName)
                ExpansionEngineer(platoon, unit, bManager)
                LOG('*AI DEBUG: ARMY ' .. unit:GetArmy() .. ' - Expanding base - ' .. locationName)

            -- finish unfinished buildings
            --elseif BMBC.UnfinishedBuildingsCheck( aiBrain, locationName ) then
            --    BuildUnfinishedStructures(platoon, aiBrain, locationName)

            -- try to build buildings
            elseif bManager:NeedAnyStructure(unit) then
                LOG('*AI DEBUG: ARMY ' .. unit:GetArmy() .. ' - Building structure at - ' .. locationName)
                BaseManagerEngineerThread( platoon, aiBrain, locationName )

            -- reclaim nearby wreckage/trees/rocks/people; never do this right now don't want to destroy props and stuff
            --elseif false and BMBC.BaseReclaimEnabled( aiBrain, locationName ) and MIBC.ReclaimablesInArea( aiBrain, locationName ) then
            --    BaseManagerReclaimThread( platoon )

            -- try to patrol
            elseif bManager.FunctionalityStates.Patrolling and not (unit:IsUnitState('Moving') or unit:IsUnitState('Patrolling')) then
                -- LOG('*AI DEBUG: ARMY ' .. unit:GetArmy() .. ' - Starting patrol base - ' .. locationName)
                if bManager.EngineerPatrolChains then
                    BaseManagerEngineerPatrol(platoon, aiBrain, locationName)
                end
            end
        else
            IssueClearCommands( {unit} )
        end
        WaitTicks( Random( 51, 113 ) )
    end
end

CAIPlatoonThreadBlueprint {
    Name = 'Base Manager Default Engineer',
    Function = BaseManagerSingleEngineerPlatoon,
}

function BaseManagerEngineerPatrol(platoon, aiBrain, locationName)
    local bManager = aiBrain.CampaignAISystem.BaseManagers[locationName]
    local patrolChain = ScenarioUtils.ChainToPositions( bManager:GetEngineerPatrolChain() )
    platoon:Stop()
    for k,v in patrolChain do
        platoon:Patrol(v)
    end
end

-- New base expansion
function ExpansionEngineer( platoon, unit, bManager )
    -- LOG('*AI DEBUG: ExpansionEngineer starting.')
    local aiBrain = bManager.AIBrain

    local cmd = false

    -- Find an expansion base and move there
    local expansionBase = false
    for num,eData in bManager.ExpansionBaseData do
        local base = aiBrain.CampaignAISystem.BaseManagers[eData.BaseName]
        if base then
            local count = base:GetCurrentEngineerCount()
            count = count + base:GetExpansionEngineerCount()

            -- If a base needs a new engineer
            if count < eData.Engineers then
                expansionBase = base

                -- Add unit as an expansion engineer
                base:AddExpansionEngineer(unit)

                platoon:Stop()

                -- If the unit needs to be transported - CURRENTLY NOT WORKING
                --if eData.TransportPlatoon or ( VDist3( platoon:GetPlatoonPosition(), base.Position ) > 150 ) then
                --    cmd = TransportUnitsToLocation( platoon, base.Position )
                --end

                -- Move to new location if not being transported
                if not cmd then
                    cmd = platoon:MoveToLocation( base.Position, false )
                end

                break
            end
        end
    end

    -- If we didn't find an expansion base; leave this function
    if not expansionBase then
        return
    end

    WaitSeconds(1)
    if not aiBrain:PlatoonExists(platoon) then
        LOG('*AI DEBUG: Platoon no longer exists')
        return
    end

    -- Wait until the platoon stops moving
    if cmd then
        while platoon:IsCommandsActive(cmd) do
            WaitSeconds(5)
            if not aiBrain:PlatoonExists(platoon) then
                return
            end
        end
    -- else
        -- LOG('*AI DEBUG: No valid command')
    end

    LOG('*AI DEBUG: ARMY ' .. unit:GetArmy() .. ': Expansion Engineer move complete; removing engineer')
    -- We should be at the base now; set up new base
    expansionBase:RemoveExpansionEngineer(unit)

    if aiBrain:PlatoonExists(platoon) then
        bManager:SetEngineersWorking(-1)
        bManager:RemoveEngineer(unit)
        aiBrain:DisbandPlatoon(platoon)
        expansionBase:AddEngineer(unit)
    end
end

-- Engineer build structures
function BaseManagerEngineerThread(platoon, aiBrain, locationName)
    platoon:Stop()
    local platoonUnits = platoon:GetPlatoonUnits()
    local factionIndex = platoon:GetFactionIndex()
    local armyIndex = aiBrain:GetArmyIndex()
    local eng

    for k, v in platoonUnits do
        if not v:IsDead() and EntityCategoryContains(categories.CONSTRUCTION, v) then
            if not eng then
                eng = v
            else
                IssueClearCommands( {v} )
                IssueGuard({v}, eng)
            end
        end
    end

    if not eng or eng:IsDead() then
        aiBrain:DisbandPlatoon(platoon)
        return
    end

    ---- CHOOSE APPROPRIATE BUILD FUNCTION AND SETUP BUILD VARIABLES ----
    local reference = false
    local refName = false
    local buildFunction
    local closeToBuilder
    local relative
    local baseTmplList = {}
    local nameSet = false
    if not aiBrain.CampaignAISystem.BaseManagers[locationName] then
        error('*AI DEBUG: Invalid base name for base manager engineer thread', 2)
    end
    local baseManager = aiBrain.CampaignAISystem.BaseManagers[locationName]
    local structurePriTable = { 'ALLUNITS' }
    -- If there is a construction block use the stuff from here
    buildFunction = BuildBaseManagerStructure

    ---- BUILD BUILDINGS HERE ----
    if eng:IsDead() then
        aiBrain:DisbandPlatoon(platoon)
    end
    local retBool, unitName
    local structurePriorities = {'T3Resource', 'T2Resource', 'T1Resource', 'T3EnergyProduction', 'T2EnergyProduction', 'T1EnergyProduction',
                            'T3MassCreation', 'T1LandFactory', 'T1AirFactory', 'T4LandExperimental1', 'T4LandExperimental2', 'T4AirExperimental1',
                            'T4SeaExperimental1', 'T3ShieldDefense', 'T2ShieldDefense', 'T3StrategicMissileDefense', 'T3Radar', 'T2Radar', 'T1Radar',
                            'T3AADefense', 'T3GroundDefense', 'T2AADefense', 'T2MissileDefense', 'T2GroundDefense', 'T2NavalDefense', 'ALLUNITS' }
    for dNum,levelData in baseManager.LevelNames do
        if levelData.Priority > 0 then
            for k,v in structurePriorities do
                local unitType = false
                if v ~= 'ALLUNITS' then
                    unitType = v
                end
                repeat
                    nameSet = false
                    local markedUnfinished = false
                    retBool, unitName = buildFunction(aiBrain, eng, aiBrain.CampaignAISystem.BaseManagers[locationName], levelData.Name, unitType, platoon)
                    if retBool then
                        repeat
                            if not nameSet then
                                WaitSeconds(0.1)
                            else
                                WaitSeconds(3)
                            end
                            if not aiBrain:PlatoonExists(platoon) then
                                return
                            end
                            if not markedUnfinished and eng:GetUnitBeingBuilt() then
                                baseManager.UnfinishedBuildings[unitName] = true
                            end
                            if not nameSet then
                                local buildingUnit = eng:GetUnitBeingBuilt()
                                if unitName and buildingUnit and not buildingUnit:IsDead() then
                                    nameSet = true
                                    local armyIndex = aiBrain:GetArmyIndex()
                                    if ScenarioInfo.UnitNames[armyIndex] and EntityCategoryContains( categories.STRUCTURE, buildingUnit ) then
                                        ScenarioInfo.UnitNames[armyIndex][unitName] = buildingUnit
                                    end
                                    buildingUnit.UnitName = unitName
                                end
                            end
                        until eng:IsDead() or eng:IsIdleState()
                        if not eng:IsDead() then
                            baseManager.UnfinishedBuildings[unitName] = false
                            baseManager:DecrementUnitBuildCounter(unitName)
                        end
                    end
                until not retBool
            end
        end
    end
    local tempPos = aiBrain.CampaignAISystem.BaseManagers[locationName]:GetPosition()
    platoon:MoveToLocation(tempPos, false)
end

-- Guts of the build thing
function BuildBaseManagerStructure(aiBrain, eng, baseManager, levelName, buildingType, platoon)
    local buildTemplate = aiBrain.BaseTemplates[baseManager.BaseName .. levelName].Template
    local buildList = aiBrain.BaseTemplates[baseManager.BaseName .. levelName].List
    local namesTable = aiBrain.BaseTemplates[baseManager.BaseName .. levelName].UnitNames
    local buildCounter = aiBrain.BaseTemplates[baseManager.BaseName .. levelName].BuildCounter
    if not buildTemplate or not buildList then
        return false
    end
    for k,v in buildTemplate do
        -- check if type (ex. T1AirFactory) is correct
        if (not buildingType or buildingType == 'ALLUNITS' or buildingType == v[1][1]) and baseManager:CheckStructureBuildable(v[1][1]) then
            local category
            for catName,catData in buildList do
                if catData.StructureType == v[1][1] then
                    category = catData.StructureCategory
                    break
                end
            end

            -- Make sure we can build the unit with this engineer
            if not category or not eng:CanBuild(category) then
                continue
            end

            -- Make sure we can afford the unit
            local economyStorage = AIEconUtils.GetEconomyStorage(aiBrain)
            local unitCost = AIEconUtils.GetUnitEconomyCost(category)
            if economyStorage.EnergyStorage < unitCost.Energy or economyStorage.MassStorage < unitCost.Mass then
                continue
            end

            -- iterate through build locations
            for num, location in v do
                -- Check if it can be built and then build
                if num <= 1 then
                    continue
                end

                if not aiBrain:CanBuildStructureAt( category, {location[1], 0, location[2]} ) then
                    continue
                end

                if not baseManager:CheckUnitBuildCounter(location,buildCounter) then
                    continue
                end

                -- Removed transport call as the pathing check was creating problems with base manager rebuilding
                -- TODO: develop system where base managers more easily rebuild in far away or hard to reach locations
                -- and TransportUnitsToLocation( platoon, {location[1], 0, location[2]} ) then

                -- LOG('*AI DEBUG: Base Manager Engineer building - ' .. category)
                IssueClearCommands({eng})
                aiBrain:BuildStructure(eng, category, location, false)
                local unitName = false
                if namesTable[location[1]][location[2]] then
                    unitName = namesTable[location[1]][location[2]]
                end
                return true, unitName
            end
        end
    end
    return false
end

-- Finish building structures that weren't finshed
function BuildUnfinishedStructures(platoon)
    platoon:Stop()
    local aiBrain = platoon:GetBrain()
    local platoonUnits = platoon:GetPlatoonUnits()
    local factionIndex = platoon:GetFactionIndex()
    local armyIndex = aiBrain:GetArmyIndex()
    local eng = platoonUnits[1]
    local bManager = aiBrain.CampaignAISystem.BaseManagers[locationName]

    if not eng or eng:IsDead() then
        aiBrain:DisbandPlatoon(platoon)
        return
    end

    --Otherwise help build whatever needs us
    local unfinishedBuildings = false
    repeat
        unfinishedBuildings = false
        local beingBuiltList = {}
        local buildingEngs = aiBrain:GetListOfUnits( categories.ENGINEER, false )
        -- Find all engineers building structures
        for k,v in buildingEngs do
            local buildingUnit = v:GetUnitBeingBuilt()
            if buildingUnit and buildingUnit.UnitName then
                beingBuiltList[buildingUnit.UnitName] = true
            end
        end
        -- Check all unfinished buildings to see if they need someone workin on them
        for k,v in bManager.UnfinishedBuildings do
            if v and ScenarioInfo.UnitNames[armyIndex][k] and not ScenarioInfo.UnitNames[armyIndex][k]:IsDead() then
                if not beingBuiltList[k] then
                    unfinishedBuildings = true
                    IssueClearCommands({eng})
                    IssueRepair({eng}, ScenarioInfo.UnitNames[armyIndex][k])
                    repeat
                        WaitSeconds(3)
                        if not aiBrain:PlatoonExists(platoon) then
                            return
                        end
                    until eng:IsIdleState()
                    bManager.UnfinishedBuildings[v] = false
                end
            end
        end
    until not unfinishedBuildings
end


