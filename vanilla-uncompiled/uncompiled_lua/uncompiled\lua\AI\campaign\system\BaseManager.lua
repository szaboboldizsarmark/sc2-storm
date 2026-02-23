--****************************************************************************
--**
--**  File     :  /lua/ai/campaign/system/BaseManager.lua
--**
--**  Summary  : Base manager for operations
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioPlatoonAI = import('/lua/ai/ScenarioPlatoonAI.lua')
local BuildingIdToType = import('/lua/ai/BuildingTemplates.lua').BuildingIdToType
local RebuildStructuresTemplate = import('/lua/ai/BuildingTemplates.lua').RebuildStructuresTemplate

local OpAI = import('/lua/ai/campaign/system/baseopai.lua').OpAI
local PlatoonGeneratedOpAI = import('/lua/ai/campaign/system/GeneratedOpAI.lua').PlatoonGeneratedOpAI
local TemplateGeneratedOpAI = import('/lua/ai/campaign/system/GeneratedOpAI.lua').TemplateGeneratedOpAI
local GroupGeneratedOpAI = import('/lua/ai/campaign/system/GeneratedOpAI.lua').GroupGeneratedOpAI

import('/lua/sim/buffs/OpBuffDefinitions.lua')




local IgnoreList = {
    uul0001 = true,
    ucl0001 = true,
    uil0001 = true,
}

-- Default rebuild numbers for buildings based on type; -1 is infinite
local BuildingCounterDefaultValues = {
    -- Difficulty 1
    {
        Default = 1,
    },

    -- Difficulty 2
    {
        Default = 2,

        Wall = 1,

        Sonar = 5,
        Radar = 5,
        DualIntelStation = 5,

        LandFactory = 5,

        AirFactory = 10,

        SeaFactory = 10,

        ResearchStation = 5,

        AirDefenseTower = 5,
        LandDefenseTower = 5,

        ArtilleryStructure = 5,
        LongRangeArtilleryStructure = 5,

        ShieldGenerator = 5,

        DualProduction = 10,
        EnergyProduction = 10,
        MassExtraction = 10,

        MassFabrication = 10,

        TacticalMissileLauncher = 5,
        TacticalMissileDefense = 5,

        StrategicMissileLauncher = 1,
        StrategicMissileDefense = 1,

        ComboMissileDefense = 1,
    },

    -- Difficulty 3
    {
        Default = -1,
    },
}

-- Level Table format
-- {
--     GroupName = Priority, -- Name not in quotes
-- }


BaseManager = Class {
    -- TO DO LIST:
    -- Expansion at mass positions ( Probably a must, but may not fit here - perhaps an OpAI which is enable/disable through bool )
    -- Maybe build T2 shields if no T3 engs are available for Illuminate/UEF
    -- Artillery, Nukes, and TML control ( At least toggling nukes and TML required, much want for control of where to attack )
    -- Engineer counts when needing higher tech level engineers (possibly not needed since recovery is hard and not always wanted)

    -- This function just sets up variables local to the new BaseManager Instance
    __init = function(self, brain, campaignSystem, baseName, markerName, radius, levelTable, difficultySeparate, vetLevel)
        self.Trash = TrashBag()

        self.Active = false
        self.AIBrain = brain
        self.BaseName = baseName
        self.Position = ScenarioUtils.MarkerToPosition( markerName )
        self.Radius = radius
        self.MarkerName = markerName
        self.CampaignSystem = campaignSystem
        self.DefaultVetLevel = vetLevel or 0
        
        self.CampaignSystem.BaseManagers[baseName] = self

        -- Base needs to have all the builder managers added now
        -- Add a Factory, Engineer, and Unit Manager for this location
        local builderManagers = self.CampaignSystem:AddBuilderManagers(self.Position, self.Radius, self.BaseName, true, self.DefaultVetLevel )
        self.FactoryManager = builderManagers.FactoryManager
        self.UnitManager = builderManagers.UnitManager
        self.EngineerManager = builderManagers.EngineerManager

        self.DefaultEngineerPatrolChain = false
        self.DefaultAirScoutPatrolChain = false
        self.DefaultLandScoutPatrolChain = false

        self.CurrentEngineerCount = 0
        self.EngineerQuantity = 0
        self.EngineersBuilding = 0
        self.EngineersWorking = 0
        self.MaximumConstructionEngineers = 2
        self.ExpansionEngineerCount = 0
        self.CommanderExpansion = false

        self.BuildingCounterData = {
            Default = true,
        }
        self.BuildTable = {}
        self.ConstructionEngineers = {}
        self.ExpansionBaseData = {}
        self.FunctionalityStates = {
            AirAttacks = true,
            AirScouting = false,
            AntiAir = true,
            Artillery = true,
            BuildEngineers = true,
            CounterIntel = true,
            EngineerReclaiming = true,
            Engineers = true,
            ExpansionBases = false,
            Fabrication = true,
            GroundDefense = true,
            Intel = true,
            LandAttacks = true,
            LandScouting = false,
            Nukes = true,
            Patrolling = true,
            SeaAttacks = true,
            Shields = true,
            TML = true,
            Torpedos = true,
            Walls = true,

            Custom = {},
        }
        self.LevelNames = {}
        self.OpAITable = {}
        self.UnfinishedBuildings = {}
        self.UnfinishedEngineers = {}

        for groupName,priority in levelTable do
            if not difficultySeparate then
                -- Do not spawn units, do not sort
                self:AddBuildGroup(groupName, priority, false, true)
            else
                -- Do not spawn units, do not sort
                self:AddBuildGroupDifficulty(groupName, priority, false, true)
            end
        end

        -- Force sort since no sorting when adding groups earlier
        self:SortGroupNames()

        -- Check for a default patrol chain for engineers
        if Scenario.Chains[baseName..'_EngineerChain'] then
            self:AddEngineerPatrolChain(baseName..'_EngineerChain')
        end

        -- Add Default builders
        self:AddDefaultBuilders()
    end,

    AddDefaultBuilders = function(self)
        self.FactoryManager:AddBuilder('BM Build Engineer')
        self.EngineerManager:AddBuilder('Default Base Manager Engineer Platoon')
    end,

    -- If base is inactive, all functionality at the base manager should stop
    BaseActive = function(self, status)
        self.Active = status
    end,

    -- Allows LD to pass in tables with Difficulty tags at the end of table names ('_D1', '_D2', '_D3')
    InitializeDifficultyTables = function(self, brain, baseName, markerName, radius, levelTable)
        self:Initialize(brain, baseName, markerName, radius, levelTable, true)
    end,
    
    SetDefaultVeterancy = function(self, vetLevel)
        if vetLevel then
            self.DefaultVetLevel = vetLevel
            self.FactoryManager:SetDefaultVeterancy(self.DefaultVetLevel)
        end
    end,

    -- Auto trashbags all threads on a base manager
    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,

    GenerateOpAIFromPlatoon = function(self, platoon, name, data)
        if not self:CheckOpAIName(name) then return false end

        self.OpAITable[name] = PlatoonGeneratedOpAI(self.AIBrain, self, platoon, name, data)
        return self.OpAITable[name]
    end,

    GenerateOpAIFromPlatoonTemplate = function(self, platoonTemplate, name, data)
        if not self:CheckOpAIName(name) then return false end

        self.OpAITable[name] = TemplateGeneratedOpAI(self.AIBrain, self, platoonTemplate, name, data)
        return self.OpAITable[name]
    end,

    GenerateOpAIFromGroup = function(self, armyName, groupName, name, data)
        if not self:CheckOpAIName(name) then return false end

        self.OpAITable[name] = GroupGeneratedOpAI(self.AIBrain, self, armyName, groupName, name, data)
        return self.OpAITable[name]
    end,

    -- Note: if "type" is a unit name, then this creates an AI to build the unit when the conditions are met.
    AddOpAI = function(self, aiName, name, data)
        if not self:CheckOpAIName(name) then return false end

        self.OpAITable[name] = OpAI(self.AIBrain, self, aiName, name, data)
        return self.OpAITable[name]
    end,

    GetOpAI = function(self, name)
        if self.OpAITable[name] then
            return self.OpAITable[name]
        else
            return false
        end
    end,

    -- Make sure name of OpAI doesn't already exist
    CheckOpAIName = function(self, name)
        if self.OpAITable[name] then
            error('*AI ERROR: Duplicate OpAI name: ' .. name .. ' - for base manager: ' .. self.BaseName)
            return false
        end
        return true
    end,

    -- Add a group created in the editor to the base manager to be maintained by the manager
    AddBuildGroup = function(self, groupName, priority, spawn, initial)
        -- make sure the group exists
        if not self:FindGroup(groupName) then
            table.insert( self.LevelNames, { Name = groupName, Priority = priority } )

            -- Setup the brain base template for use in the base manager ( Don't create so we can get a unitnames table )
            self.AIBrain.BaseTemplates[self.BaseName .. groupName] = { Template={}, List={}, UnitNames = {}, BuildCounter = {} }

            -- Now that we have a group name find it and add data
            self:AddToBuildingTemplate( groupName, self.BaseName .. groupName )

            -- spawn with SpawnGroup so we can track number of times this unit has existed
            if spawn then
                self:SpawnGroup(groupName)
            end
            if not initial then
                self:SortGroupNames()
            end
        else
            error( '*AI DEBUG: Group Name - ' .. groupName .. ' already exists in Base Manager group data', 2 )
        end
    end,

    AddBuildGroupDifficulty = function( self, groupName, priority, spawn, initial)
        groupName = groupName .. '_D' .. ScenarioInfo.Options.Difficulty
        self:AddBuildGroup( groupName, priority, spawn, initial )
    end,

    ClearGroupTemplate = function(self, groupName)
        self.AIBrain.BaseTemplate[self.BaseName .. groupLevel] = { Template = {}, List = {}, UnitNames = {}, BuildCounter = {} }
    end,

    -- Find a build group in the class
    FindGroup = function(self, groupName)
        for num,data in self.LevelNames do
            if data.Name == groupName then
                return data
            end
        end
        return false
    end,

    SetBuildGroupPriority = function(self, groupName, pri)
        for num,data in self.LevelNames do
            if data.Name == groupName then
                self.LevelNames[num].Priority = pri
            end
        end
    end,

    GetPosition = function(self)
        return self.Position
    end,

    GetRadius = function(self)
        return self.Radius
    end,

    SetRadius = function(self, rad)
        self.Radius = rad
    end,

    --------------------------------------------------------------------------------
    ---- Functions for tracking the number of engineers working in a base manager --
    --------------------------------------------------------------------------------
    AddEngineer = function(self, unit)
        self.EngineerManager:AddUnit(unit)
        if not unit.BaseManagerData then
            unit.BaseManagerData = {}
        end
        unit.BaseManagerData[self.BaseName] = {
            Subtracted = false,
        }
        if not unit.BaseManagerData[self.BaseName].Subtracted then
            unit.Callbacks.OnKilled:Add( self.RemoveEngineer, self )
            self.CurrentEngineerCount = self.CurrentEngineerCount + 1
            -- LOG('*AI DEBUG: AddEngineer NumEngineers = ' .. self.CurrentEngineerCount .. ' - Base = ' .. self.BaseName )
        end
    end,

    RemoveEngineer = function(self, unit)
        if unit.BaseManagerData and unit.BaseManagerData[self.BaseName] and not unit.BaseManagerData[self.BaseName].Subtracted then
            unit.BaseManagerData[self.BaseName].Subtracted = true
            self.CurrentEngineerCount = self.CurrentEngineerCount - 1
            self.EngineerManager:RemoveUnit(unit)
            -- LOG('*AI DEBUG: RemoveEngineer NumEngineers = ' .. self.CurrentEngineerCount .. ' - Base = ' .. self.BaseName )
        end
    end,

    GetCurrentEngineerCount = function(self)
        return self.CurrentEngineerCount
    end,

    GetMaximumEngineers = function(self)
        return self.EngineerQuantity
    end,

    NeedsEngineerBuilt = function(self, unitId)
        if self.EngineerQuantity > self.CurrentEngineerCount + self.EngineersBuilding then
            return true
        end
        return false
    end,

    NeedsEngineer = function(self, unitId)
        if self.EngineerQuantity > self.EngineersWorking then
            return true
        end
        return false
    end,
    
    SetEngineersWorking = function(self, count)
        self.EngineersWorking = self.EngineersWorking + count
    end,

    SetEngineerCount = function(self, count)
        -- If we have a table, we have various possible ways of counting engineers
        -- { tNum1, tNum2, tNum3 } - This is a difficulty defined total number of engs
        -- num - this is the number of total engineers

        if type(count) == 'table' then
            -- Table with 3 entries is a dificulty table
            self:SetTotalEngineerCount(count[ScenarioInfo.Options.Difficulty])
        else
            self:SetTotalEngineerCount(count)
        end
    end,

    SetTotalEngineerCount = function(self, num)
        self.EngineerQuantity = num
        ScenarioInfo.VarTable[self.BaseName .. '_EngineerNumber'] = num
    end,

    GetEngineersBuilding = function( self )
        return self.EngineersBuilding
    end,

    SetEngineersBuilding = function( self, count )
        self.EngineersBuilding = self.EngineersBuilding + count
    end,

    SetSupportACUCount = function(self,count)
        ScenarioInfo.VarTable[self.BaseName ..'_sACUNumber'] = count
    end,

    --------------------------------------------------------
    ---- Get/Set of default chains for base funcitonality --
    --------------------------------------------------------
    GetEngineerPatrolChain = function(self)
        if not self.EngineerPatrolChains then
            return false
        end

        return self.EngineerPatrolChains[ Random(1, table.getn(self.EngineerPatrolChains) ) ]
    end,

    AddEngineerPatrolChain = function(self, chainName)
        if not self.EngineerPatrolChains then
            self.EngineerPatrolChains = {}
        end

        table.insert( self.EngineerPatrolChains, chainName )
    end,

    GetDefaultAirScoutPatrolChain = function(self)
        return self.DefaultAirScoutPatrolChain
    end,

    SetDefaultAirScoutPatrolChain = function(self, chainName)
        self.DefaultAirScoutPatrolChain = chainName
        return true
    end,

    GetDefaultLandScoutPatrolChain = function(self)
        return self.DefaultLandScoutPatrolChain
    end,

    SetDefaultLandScoutPatrolChain = function(self, chainName)
        self.DefaultLandScoutPatrolChain = chainName
        return true
    end,

    -- Add in the ability for an expansion base to move out and help another base manager at another location
    --   Functionality should mean that you simply specifiy the name of the base and it will then send out an
    --   engineer to build it.  You can also specify the number of engineers you would like to support with
    --   baseData is a field that does nothing currently.  If we ever need more data (transports maybe) it would
    --   be housed there.
    AddExpansionBase = function(self,baseName,engQuantity,baseData)
        if not engQuantity then
            engQuantity = 1
        end
        table.insert( self.ExpansionBaseData, { BaseName = baseName, Engineers = engQuantity } )
        self.FunctionalityStates.ExpansionBases = true
        if baseData then
            -- Setup base here
        end
    end,

    ExpansionBasesNeedEngineer = function(self, unit)
        if not self.ExpansionBaseData then
            return false
        end
        for num,eData in self.ExpansionBaseData do
            local eBaseName = eData.BaseName
            local base = self.AIBrain.CampaignAISystem.BaseManagers[eBaseName]
            if base and base.Active then
                local count = base:GetCurrentEngineerCount()
                count = count + base:GetExpansionEngineerCount()

                if not base:DesireExpansionEngineer(unit) then
                    continue
                end

                if count < eData.Engineers then
                    return true
                end
            end
        end
        return false
    end,

    GetExpansionEngineerCount = function(self)
        return self.ExpansionEngineerCount
    end,

    AddExpansionEngineer = function(self, unit)
        unit.ExpansionEngineer = true
        self.ExpansionEngineerCount = self.ExpansionEngineerCount + 1
        -- LOG('*AI DEBUG: NumExpansionEngineers = ' .. self.ExpansionEngineerCount )
        -- Death Triggers here
        unit.Callbacks.OnKilled:Add( self.RemoveExpansionEngineer, self )
    end,

    RemoveExpansionEngineer = function(self, unit)
        if unit.ExpansionEngineer then
            self.ExpansionEngineerCount = self.ExpansionEngineerCount - 1
            -- LOG('*AI DEBUG: NumExpansionEngineers = ' .. self.ExpansionEngineerCount )
            -- Remove death trigger here
            unit.Callbacks.OnKilled:Remove( self.RemoveExpansionEngineer )
            unit.ExpansionEngineer = false
        end
    end,

    SetCommanderExpansion = function(self, val)
        self.CommanderExpansion = val
    end,

    DesireExpansionEngineer = function(self, unit)
        if EntityCategoryContains( categories.COMMAND, unit ) and not self.CommanderExpansion then
            return false
        end
        return true
    end,



    -- Sort build groups by priority
    SortGroupNames = function(self)
        local sortedList = {}
        for i = 1,table.getn(self.LevelNames) do
            local highest, highPos
            for num,data in self.LevelNames do
                if not highest or data.Priority > highest.Priority then
                    highest = data
                    highPos = num
                end
            end
            sortedList[i] = highest
            table.remove(self.LevelNames, highPos)
        end
        self.LevelNames = sortedList
    end,

    -- Sets a group's priority
    SetGroupPriority = function(self, groupName, priority)
        for num,data in self.LevelNames do
            if data.Name == groupName then
                data.Priority = priority
                break
            end
        end
        self:SortGroupNames()
    end,

    -- Spawns a group, tracks number of times it has been built, gives nuke and anti-nukes ammo
    SpawnGroup = function(self, groupName, uncapturable, balance)

        local unitGroup = ScenarioUtils.CreateArmyGroup( self.AIBrain.Name, groupName, nil, balance )

        for k,v in unitGroup do
            self:DecrementUnitBuildCounter(v.UnitName)
            if uncapturable then
                v:SetCapturable(false)
                v:SetReclaimable(false)
            end
            if EntityCategoryContains( categories.FACTORY, v ) then
                self.FactoryManager:AddFactory( v )
            end
            if EntityCategoryContains( categories.ENGINEER, v ) then
                self:AddEngineer(v)
            end
            if EntityCategoryContains( categories.SILO, v ) then
                if ScenarioInfo.Options.Difficulty == 1 then
                    v:GiveNukeSiloAmmo(1)
                    v:GiveTacticalSiloAmmo(1)
                else
                    v:GiveNukeSiloAmmo(2)
                    v:GiveTacticalSiloAmmo(2)
                end
            end
        end
    end,

    -- If we want a group in the base manager to be wreckage, use this function
    SpawnGroupAsWreckage = function(self,groupName)
        local unitGroup = ScenarioUtils.CreateArmyGroup( self.AIBrain.Name, groupName, true)
    end,

    -- Sets Engineer Count, spawns in all groups that have priority greater than zero
    StartNonZeroBase = function(self, engineerNumber, uncapturable)
        self.Active = true
        if not engineerNumber and not ScenarioInfo.VarTable[self.BaseName ..'_EngineerNumber'] then
            self:SetEngineerCount(0)
        elseif engineerNumber then
            self:SetEngineerCount(engineerNumber)
        end
        for num,data in self.LevelNames do
            if data.Priority and data.Priority > 0 then
                if ScenarioInfo.LoadBalance and ScenarioInfo.LoadBalance.Enabled then
                    table.insert(ScenarioInfo.LoadBalance.SpawnGroups, {self, data.Name, uncapturable})
                else
                    self:SpawnGroup(data.Name, uncapturable)
                end
            end
        end
    end,

    StartDifficultyBase = function(self, groupNames, engineerNumber, uncapturable)
        self.Active = true
        local newNames = {}
        for k,v in groupNames do
            table.insert( newNames, v .. '_D' .. ScenarioInfo.Options.Difficulty )
        end
        self:StartBase( newNames, engineerNumber, uncapturable )
    end,

    -- Sets engineer count, spawns in all groups passed in in groupNames table
    StartBase = function(self, groupNames, engineerNumber, uncapturable)
        self.Active = true
        if not engineerNumber and not ScenarioInfo.VarTable[self.BaseName ..'_EngineerNumber'] then
            self:SetEngineerCount(0)
        elseif engineerNumber then
            self:SetEngineerCount(engineerNumber)
        end
        for num, name in groupNames do
            local group = self:FindGroup( name )
            if not group then
                error( '*AI DEBUG: Unable to create group - ' .. name .. ' - Data does not exist in Base Manager', 2 )
            else
                self:SpawnGroup(group.Name, uncapturable)
            end
        end
    end,

    -- Sets engineer count and spawns in no groups
    StartEmptyBase = function(self, engineerNumber)
        self.Active = true
        if not engineerNumber and not ScenarioInfo.VarTable[self.BaseName ..'_EngineerNumber'] then
            self:SetEngineerCount(1)
        elseif engineerNumber then
            self:SetEngineerCount(engineerNumber)
        end
    end,


    -- ===== BASE CONSTRUCTION ===== --
    CheckStructureBuildable = function( self, buildingType )
        if self.BuildTable[buildingType] == false then
            return false
        end
        return true
    end,

    AddToBuildingTemplate = function(self, groupName, addName)
        local tblUnit = ScenarioUtils.AssembleArmyGroup( self.AIBrain.Name, groupName )
        local template = self.AIBrain.BaseTemplates[addName].Template
        local list = self.AIBrain.BaseTemplates[addName].List
        local unitNames = self.AIBrain.BaseTemplates[addName].UnitNames
        local buildCounter = self.AIBrain.BaseTemplates[addName].BuildCounter

        if not tblUnit then
            error('*AI DEBUG - Group: ' .. repr(name) .. ' not found for Army: ' .. repr(army), 2)
        else

            for i, unit in tblUnit do
                local unitAdded = false

                self:StoreStructureName(i,unit,unitNames)

                -- Make sure the
                if BuildingIdToType[unit.type] then
                    local unitPos = { unit.Position[1], unit.Position[3], 0 }

                    -- if unit to be built is the same id as the buildList unit it needs to be added
                    self:StoreBuildCounter(buildCounter, BuildingIdToType[unit.type], unit.type, unitPos, i)
                    local inserted = false
                    -- check each section of the template for the right type
                    for k,section in template do
                        if section[1][1] == BuildingIdToType[unit.type] then
                            -- add position of new unit if found
                            table.insert( section, unitPos )
                            -- increment num wanted if found
                            list[unit.type].AmountWanted = list[unit.type].AmountWanted + 1
                            inserted = true
                            break
                        end
                    end
                    -- if section doesn't exist create new one
                    if not inserted then
                        -- add new build type to list with new unit
                        table.insert( template, { {BuildingIdToType[unit.type]}, unitPos } )
                        -- add new section of build list with new unit type information
                        list[unit.type] =  {
                            StructureType = BuildingIdToType[unit.type],
                            StructureCategory = unit.type,
                            AmountNeeded = 0,
                            AmountWanted = 1,
                            CloseToBuilder = nil
                        }
                    end

                -- Unit is not in the BuildingIdToType list - Spit a warning so we can fix this
                elseif not IgnoreList[unit.type] then
                    WARN('*BASE MANAGER WARNING: Could not add unit to building template - UnitId = ' .. unit.type)
                end
            end
        end
    end,

    StoreStructureName = function(self, unitName, unitData, namesTable)
        if not namesTable[unitData.Position[1]] then
            namesTable[unitData.Position[1]] = {}
        end
        namesTable[unitData.Position[1]][unitData.Position[3]] = unitName
    end,

    StoreBuildCounter = function(self, buildCounter, buildingType, buildingId, unitPos, unitName)
        if not buildCounter[unitPos[1]] then
            buildCounter[unitPos[1]] = {}
        end
        buildCounter[unitPos[1]][unitPos[2]] = {}
        buildCounter[unitPos[1]][unitPos[2]].BuildingID = buildingId
        buildCounter[unitPos[1]][unitPos[2]].BuildingType = buildingType
        buildCounter[unitPos[1]][unitPos[2]].Position = unitPos
        if unitName then
            buildCounter[unitPos[1]][unitPos[2]].UnitName = unitName
        end
        if self.BuildingCounterData.Default then
            buildCounter[unitPos[1]][unitPos[2]].Counter = self:BuildingCounterDifficultyDefault(buildingType)
        end
    end,

    SetUnitNameRebuildCounter = function(self, unitName, count)
        local unit = ScenarioInfo.UnitNames[self.Brain:GetArmyIndex()][unitName]
        if not unit then
            WARN('*AI WARNING: Could not find unit for rebuild counter named - ' .. unitName)
            return
        end
        self:SetUnitRebuildCounter(unit,count)
    end,

    SetUnitRebuildCounter = function(self, unit, count)
        local unitPos = unit:GetPosition()
        buildCounter[unitPos[1]][unitPos[3]].Counter = count
    end,

    BuildingCounterDifficultyDefault = function(self, buildingType)
        local diff = ScenarioInfo.Options.Difficulty
        if not diff then diff = 1 end
        for k,v in BuildingCounterDefaultValues[diff] do
            if buildingType == k then
                return v
            end
        end
        return BuildingCounterDefaultValues[diff].Default
    end,

    CheckUnitBuildCounter = function(self,location,buildCounter)
        if self.InfiniteRebuild then
            return true
        end

        for xVal,xData in buildCounter do
            if xVal == location[1] then
                for yVal,yData in xData do
                    if yVal == location[2] then
                        if yData.Counter > 0 or yData.Counter == -1 then
                            return true
                        else
                            return false
                        end
                    end
                end
            end
        end
        return false
    end,

    DecrementUnitBuildCounter = function(self,unitName)
        for levelNum,levelData in self.LevelNames do
            for firstNum,firstData in self.AIBrain.BaseTemplates[self.BaseName .. levelData.Name].BuildCounter do
                for secondNum,secondData in firstData do
                    if secondData.UnitName == unitName then
                        if secondData.Counter > 0 then
                            secondData.Counter = secondData.Counter - 1
                        end
                        return true
                    end
                end
            end
        end
        return false
    end,

    SetBaseInfiniteRebuild = function(self)
        self.InfiniteRebuild = true
    end,

    NeedAnyStructure = function(self, unit)
        for dNum,data in self.LevelNames do
            if data.Priority > 0 then
                local buildTemplate = self.AIBrain.BaseTemplates[self.BaseName .. data.Name].Template
                local buildList = self.AIBrain.BaseTemplates[self.BaseName .. data.Name].List
                local buildCounter = self.AIBrain.BaseTemplates[self.BaseName .. data.Name].BuildCounter

                if not buildTemplate or not buildList then
                    return false
                end
                for k,v in buildTemplate do
                    if self:CheckStructureBuildable(v[1][1]) then
                        -- get the building to build
                        local category
                        for catName,catData in buildList do
                            if catData.StructureType == v[1][1] then
                                category = catData.StructureCategory
                                break
                            end
                        end
                        -- iterate through build locations
                        for num, location in v do
                            if category and num > 1 then
                                if unit and not unit:CanBuild(category) then
                                    continue
                                end
                                
                                -- Check if it can be built and then build
                                if self.AIBrain:CanBuildStructureAt( category, {location[1], 0, location[2]} )
                                and self:CheckUnitBuildCounter(location, buildCounter) then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end,


    -- ===== BASE FUNCTIONALITY ===== --

    -- Enable/Disable functionality of base parts through functions
    SetActive = function(self,actType,val)
        if self.ActivationFunctions[actType..'Active'] then
            self.ActivationFunctions[actType..'Active'](self,val)
        else
            error('*AI DEBUG: Invalid Activation type type - ' .. actType, 2 )
        end
    end,

    ActivationFunctions = {
        ShieldsActive = function(self,val)
            local shields = AIUtils.GetOwnUnitsAroundPoint( self.AIBrain, categories.SHIELD * categories.STRUCTURE, self.Position, self.Radius )
            for k,v in shields do
                if val then
                    v:OnScriptBitSet(0) -- if turning on shields
                else
                    v:OnScriptBitClear(0) -- if turning off shields
                end
            end
            self.FunctionalityStates.Shields = val
        end,

        FabricationActive = function(self,val)
            local fabs = AIUtils.GetOwnUnitsAroundPoint( self.AIBrain, categories.MASSFABRICATION * categories.STRUCTURE, self.Position, self.Radius )
            for k,v in fabs do
                if val then
                    v:OnScriptBitClear(4) -- if turning on
                else
                    v:OnScriptBitSet(4) -- if turning off
                end
            end
            self.FunctionalityStates.Fabrication = val
        end,

        IntelActive = function(self,val)
            local intelUnits = AIUtils.GetOwnUnitsAroundPoint( self.AIBrain, (categories.RADAR + categories.SONAR + categories.OMNI) * categories.STRUCTURE, self.Position, self.Radius )
            for k,v in intelUnits do
                if val then
                    v:OnScriptBitClear(3) -- if turning on
                else
                    v:OnScriptBitSet(3) -- if turning off
                end
            end
            self.FunctionalityStates.Intel = val
        end,

        CounterIntelActive = function(self,val)
            local intelUnits = AIUtils.GetOwnUnitsAroundPoint( self.AIBrain, categories.COUNTERINTELLIGENCE * categories.STRUCTURE, self.Position, self.Radius )
            for k,v in intelUnits do
                if val then
                    v:OnScriptBitClear(3) -- if turning on intel
                    --v:OnScriptBitClear(2) -- if turning on Jamming
                    --v:OnScriptBitClear(5) -- stealth
                    --v:OnScriptBitClear(8) -- cloak
                else
                    v:OnScriptBitSet(2) -- if turning off intel
                    --v:OnScriptBitSet(2) -- if turning off jamming
                    --v:OnScriptBitSet(5) -- stealth
                    --v:OnScriptBitSet(8) -- cloak
                end
            end
            self.FunctionalityStates.CounterIntel = val
        end,

        TMLActive = function(self,val)
        end,

        PatrolActive = function(self,val)
            self.FunctionalityStates.Patrolling = val
        end,

        ReclaimActive = function(self,val)
            self.FunctionalityStates.EngineerReclaiming = val
        end,

        LandScoutingActive = function(self,val)
            self.FunctionalityStates.LandScouting = val
        end,

        AirScoutingActive = function(self,val)
            self.FunctionalityStates.AirScouting = val
        end,
    },





    -- Enable/Disable building of buildings and stuff
    SetBuild = function(self,buildType,val)
        if not self.Active then
            return false
        end
        if self.BuildFunctions['Build'..buildType] then
            self.BuildFunctions['Build'..buildType](self,val)
        else
            error('*AI DEBUG: Invalid build type - ' .. buildType, 2 )
        end
    end,

    -- Disable all buildings
    SetBuildAllStructures = function(self,val)
        for k,v in self.BuildFunctions do
            if k ~= 'BuildEngineers' then
                v(self,val)
            end
        end
    end,

    BuildFunctions = {
        BuildEngineers = function(self,val)
            self.FunctionalityStates.BuildEngineers = val
        end,

        BuildAntiAir = function(self,val)
            self.BuildTable['AirDefenseTower'] = val
        end,

        BuildGroundDefense = function(self,val)
            self.BuildTable['LandDefenseTower'] = val
        end,

        BuildAirFactories = function(self,val)
            self.BuildTable['AirFactory'] = val
        end,

        BuildLandFactories = function(self,val)
            self.BuildTable['LandFactory'] = val
        end,

        BuildSeaFactories = function(self,val)
            self.BuildTable['SeaFactory'] = val
        end,
        
        BuildGantries = function(self,val)
            self.BuildTable['ExperimentalGantry'] = val
            self.BuildTable['LandGantry'] = val
            self.BuildTable['AirGantry'] = val
            self.BuildTable['AssaultGantry'] = val
            self.BuildTable['UtilityGantry'] = val
        end,

        BuildFactories = function(self,val)
            self.BuildFunctions['BuildAirFactories'](self,val)
            self.BuildFunctions['BuildSeaFactories'](self,val)
            self.BuildFunctions['BuildLandFactories'](self,val)
        end,

        BuildMissileDefense = function(self,val)
            self.BuildTable['MissileLaunchAndDefense'] = val
            self.BuildTable['ComboMissileDefense'] = val
        end,

        BuildShields = function(self,val)
            self.BuildTable['ShieldGenerator'] = val
        end,

        BuildArtillery = function(self,val)
            self.BuildTable['ArtilleryStructure'] = val
            self.BuildTable['LongRangeArtilleryStructure'] = val
        end,

        BuildExperimentals = function(self,val)
            self.BuildTable['SpaceTemple'] = val
            self.BuildTable['LoyaltyGun'] = val
            self.BuildTable['Magnetron'] = val
            self.BuildTable['ProtoBrain'] = val
            self.BuildTable['NoahCannon'] = val
            self.BuildTable['DisruptorStation'] = val
        end,

        BuildWalls = function(self,val)
            self.BuildTable['Wall'] = val
        end,

        BuildDefenses = function(self,val)
            self.BuildFunctions['BuildAntiAir'](self,val)
            self.BuildFunctions['BuildGroundDefense'](self,val)
            self.BuildFunctions['BuildArtillery'](self,val)
            self.BuildFunctions['BuildShields'](self,val)
            self.BuildFunctions['BuildWalls'](self,val)
        end,

        BuildRadar = function(self,val)
            self.BuildTable['Radar'] = val
            self.BuildTable['DualIntelStation'] = val
        end,

        BuildSonar = function(self,val)
            self.BuildTable['Sonar'] = val
            self.BuildTable['DualIntelStation'] = val
        end,

        BuildIntel = function(self,val)
            self.BuildFunctions['BuildSonar'](self,val)
            self.BuildFunctions['BuildRadar'](self,val)
        end,

        BuildMissiles = function(self,val)
            self.BuildTable['StrategicMissileLauncher'] = val
            self.BuildTable['MissileLaunchAndDefense'] = val
            self.BuildTable['TacticalMissile'] = val
        end,

        BuildFabrication = function(self,val)
            self.BuildTable['MassFabrication'] = val
        end,

        BuildMassExtraction = function(self,val)
            self.BuildTable['Resource'] = val
        end,

        BuildEnergyProduction = function(self,val)
            self.BuildTable['EnergyProduction'] = val
        end,

        BuildResearch = function(self, val)
            self.BuildTable['ResearchStation'] = val
        end,
    },

}

