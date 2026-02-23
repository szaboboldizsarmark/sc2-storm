--***************************************************************************
--*
--**  File     :  /lua/ai/campaign/system/Builder.lua
--**
--**  Summary  : Builder class
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local AIUtils = import('/lua/ai/aiutilities.lua')
local AIEconUtils = import('/lua/ai/AIEconomyUtilities.lua')

-- Root builder class
-- Builder Sped
-- {
--        Priority = integer,
--        Name = string,
--        BuilderType = string,
--        BuilderData = table,
--        Conditions = list of functions that return true/false, list of args,  { < function>, {<args>}}
-- }

Builder = Class {
    __init = function(self, brain, data, locationName, parent)
        -- make sure the table of strings exist, they are required for the builder        
        self.Priority = data.Priority
        self.OriginalPriority = self.Priority

        self.Brain = brain
        
        self.BuilderName = data.Name
        
        self.ReportFailure = data.ReportFailure
        
        self.LocationName = locationName
        if brain.CampaignAISystem.BaseManagers[locationName] then
            self.BaseManager = brain.CampaignAISystem.BaseManagers[locationName]
        end

        self:SetupConditionSets(data, locationName, parent)
        
        self.BuilderStatus = false

        return true
    end,
    
    GetPriority = function(self)
        return self.Priority
    end,
    
    SetPriority = function(self, val, temporary)
        if temporary then
            self.OldPriority = self.Priority
        end
        if val != self.Priority then
            self.PriorityAltered = true
        end
        self.Priority = val
    end,
    
    ResetPriority = function(self)
        self.Priority = self.OldPriority
        self.OldPriority = nil
    end,
    
    CalculatePriority = function(self, builderManager)
        self.PriorityAltered = false
        
        -- Builders can have a function to update the priority
        if self.PriorityFunction then
            local newPri = self.PriorityFunction[1]( self, self.Brain, builderManager, unpack(self.PriorityFunction[2]) )
            if newPri != self.Priority then
                self.Priority = newPri
                self.PriorityAltered = true
            end
        end
        
        -- Returns true if a priority change happened
        local returnVal = self.PriorityAltered
        return returnVal
    end,
    
    AdjustPriority = function(self, val)
        self.Priority = self.Priority + val
    end,
    
    GetBuilderData = function(self, locationName, builderData )
        -- Get builder data out of the globals and convert data here
        local returnData = {}
        builderData = builderData or Builders[self.BuilderName].BuilderData
        for k,v in builderData do
            if type(v) == 'table' then
                returnData[k] = self:GetBuilderData(locationName, v )
            else
                if type(v) == 'string' and v == 'LocationType' then
                    returnData[k] = locationName
                else
                    returnData[k] = v
                end
            end
        end
        return returnData
    end,
    
    GetBuilderType = function(self)
        return Builders[self.BuilderName].BuilderType
    end,
    
    GetBuilderName = function(self)
        return self.BuilderName
    end,
    
    GetBuilderStatus = function(self)
        if self.GetStatusFunction then
            self.GetStatusFunction()
        end
        self:CheckConditionSets()
        return self.BuilderStatus
    end,
    
    GetPlatoonTemplate = function(self)
        if Builders[self.BuilderName].PlatoonTemplate then
            return Builders[self.BuilderName].PlatoonTemplate
        end
        return false
    end,
    
    GetPlatoonAIFunction = function(self)
        if Builders[self.BuilderName].PlatoonAIFunction then
            return Builders[self.BuilderName].PlatoonAIFunction
        end
        return false
    end,
    
    GetPlatoonAIPlan = function(self)
        if Builders[self.BuilderName].PlatoonAIPlan then
            return Builders[self.BuilderName].PlatoonAIPlan
        end
        return false
    end,
    
    GetPlatoonAddPlans = function(self)
        if Builders[self.BuilderName].PlatoonAddPlans then
            return Builders[self.BuilderName].PlatoonAddPlans
        end
        return false
    end,
    
    GetPlatoonAddFunctions = function(self)
        if Builders[self.BuilderName].PlatoonAddFunctions then
            return Builders[self.BuilderName].PlatoonAddFunctions
        end
        return false
    end,
    
    GetPlatoonAddBehaviors = function(self)
        if Builders[self.BuilderName].PlatoonAddBehaviors then
            return Builders[self.BuilderName].PlatoonAddBehaviors
        end
        return false
    end,
    
    ConditionTest = function(self)
        if table.empty(self.ConditionSets) then
            self.BuilderStatus = true
            return true
        end

        for setIndex,setData in self.ConditionSets do
            local allTrue = true
            for k,v in setData do
                if not self.Brain.ConditionsMonitor:CheckKeyedCondition(v, self.ReportFailure) then
                    if self.ReportFailure then
                        LOG('*AI DEBUG: ' .. self.BuilderName .. ' - Failure Report Complete')
                    end
                    allTrue = false
                    break
                end
            end

            if allTrue then
                self.BuilderStatus = true
                return true
            end
        end
        self.BuilderStatus = false
        return false
    end,
    
    SetupConditionSets = function(self, data, locationName, parent)
        self.ConditionSets = {}
        if not data.Conditions then
            return
        end

        for setIndex,setData in data.Conditions do
            self.ConditionSets[setIndex] = {}

            for k,v in setData do
                if v.ConditionName then
                    table.insert( self.ConditionSets[setIndex], self.Brain.ConditionsMonitor:AddConditionFromBlueprint( v.ConditionName, v.Parameters, locationName, self.OpAI ) )
                elseif v.Function then
                else
                end
            end
        end
    end,
    
    CheckConditionSets = function(self)
        self:ConditionTest(self.Brain)
    end,    
    
    VerifyDataName = function(self, valueName, data)
        if not data[valueName] and not data.BuilderName then
            WARN('*BUILDER ERROR: Invalid builder data missing: ' .. valueName .. ' - BuilderName not given' .. repr(data))
            return false
        elseif not data[valueName] then
            WARN('*BUILDER ERROR: Invalid builder data missing: ' .. valueName .. ' - BuilderName given: ' .. data.BuilderName)
            return false
        end
        return true
    end,
}

-- FactoryBuilderSpec
-- This is the spec to have built by a factory
--{
--   Platoons = platoon template, -- Table of platoon templates
--   RequiresConstruction = true/false do I need to build this from a factory or should I just try to form it?,
--   PlatoonBuildCallbacks = {FunctionsToCallBack when the platoon starts to build}
--}

FactoryBuilder = Class(Builder) {
    __init = function(self,brain,factoryBuilderName,locationName,parent)
        local bp = CAIFactoryBuilders[factoryBuilderName]
        if not bp then
            WARN('*FACTORY BUILDER ERROR: Could not find factory builder named - ' .. factoryBuilderName)
            return
        end

        self.OpAI = parent

        Builder.__init(self,brain,bp,locationName,parent)

        self.Blueprint = bp
    end,

    -- If we have a parent, set it here
    SetOpAIParent = function(self,parent)
        self.OpAI = parent
    end,

    -- Returns the buildertype ( 'air', 'land', 'sea', 'all' ) defined in blueprint
    GetBuilderType = function(self)
        return self.Blueprint.BuilderType
    end,

    GetPlatoonCost = function(self, platoonData)
        local platoonCost = {
            Mass = 0,
            Energy = 0,
        }

        for k,v in platoonData do
            local unitCost = AIEconUtils.GetUnitEconomyCost(v[1])
            platoonCost.Mass = platoonCost.Mass + ( unitCost.Mass * v[2] )
            platoonCost.Energy = platoonCost.Energy + ( unitCost.Energy * v[2] )
        end

        return platoonCost
    end,

    -- The build template is the makeup of units to build; it's a table of tables.
    -- FactoryBuilders have a list of platoons; we random between them to get some variety
    -- This function also verifies that it CAN build a platoon; returns false if it cannot
    -- returns a valid platoon table if it can
    -- Eg:
    -- { { 'uul0101', 1 }, { 'uul0101', 2 } }
    GetBuildTemplate = function(self, params)
        local economyStorage = AIEconUtils.GetEconomyStorage(self.Brain)

        local buildablePlatoons = {}

        for k,v in self.Blueprint.Platoons do
            local platoonCost = self:GetPlatoonCost(v)

            if economyStorage.MassStorage < platoonCost.Mass or economyStorage.EnergyStorage < platoonCost.Energy then
                continue
            end

            if params and not self.Brain:CanBuildPlatoon( v, params ) then
                continue
            end

            table.insert( buildablePlatoons, v )
        end

        if table.empty( buildablePlatoons ) then
            return false
        end

        return buildablePlatoons[ Random(1, table.getn(buildablePlatoons) ) ]
    end,

    -- If we have an OpAI; notify it that we are being built
    -- We want to be able to lock the OpAI as necessary
    BuilderConstructionStarted = function(self, factory, constructionTemplate)
        if self.Blueprint.BuilderStartedCallback then
            self.Blueprint.BuilderStartedCallback(self, factory, constructionTemplate)
        end

        if not self.OpAI then
            return
        end

        self.OpAI:FactoryBuilderStarted(self, factory)
    end,

    BuilderConstructionFinished = function(self)
        if self.Blueprint.BuilderFinishedCallback then
            self.Blueprint.BuilderFinishedCallback(builder)
        end

        if not self.OpAI then
            return
        end

        self.OpAI:FactoryBuilderFinished(self)
    end,

    UnitConstructionFinished = function(self, newUnit)
        if self.Blueprint.UnitFinishedCallback then
            self.Blueprint.UnitFinishedCallback(self, newUnit)
        end

        if self.OpAI then
            self.OpAI:UnitConstructionFinished(self, newUnit)
        else
            if EntityCategoryContains( categories.ENGINEER, newUnit ) then
                self.BaseManager:AddEngineer(newUnit)
            else
                self.BaseManager.UnitManager:AddUnit(self, newUnit)
            end
        end
    end,

    GetBuilderStatus = function(self)
        -- If the factory builder has an opAI, make sure the OpAI isn't locked
        if self.OpAI then
            -- True means the lock is engaged; we cannot built this builder
            if self.OpAI:CheckFactoryBuilderLock() then
                return false
            end

            if not self.OpAI:CheckChildTypes(self.Blueprint.ChildrenTypes) then
                return false
            end
        end

        return Builder.GetBuilderStatus(self)
    end,
}

-- PlatoonBuilderSpec
--{
--   PlatoonTemplate = platoon template,
--   InstanceCount = number of active platoons available,
--   PlatoonBuildCallbacks = { functions to call when platoon is formed }
--   PlatoonAIFunction = function the platoon uses when formed,
--   PlatoonAddFunctions = { other functions to run when platoon is formed }
--}

PlatoonBuilder = Class(Builder) {
    __init = function(self,brain,data,locationName)
        Builder.Create(self,brain,data,locationName)
        
        local verifyDictionary = { 'PlatoonTemplate', }
        for k,v in verifyDictionary do
            if not self:VerifyDataName( v, data ) then return false end
        end
        
        -- Setup for instances to be stored inside a table rather than creating new
        self.InstanceCount = {}
        local num = 1
        while num <= ( data.InstanceCount or 1 ) do
            table.insert( self.InstanceCount, { Status = 'Available', PlatoonHandle = false } )
            num = num + 1
        end
        return true
    end,
    
    FormDebug = function(self)
        if self.FormDebugFunction then
            self.FormDebugFunction()
        end
    end,
    
    CheckInstanceCount = function(self)
        for k,v in self.InstanceCount do
            if v.Status == 'Available' then
                return true
            end
        end
        return false
    end,
    
    GetFormRadius = function(self)
        if Builders[self.BuilderName].FormRadius then
            return Builders[self.BuilderName].FormRadius
        end
        return false
    end,
    
    StoreHandle = function(self,platoon)
        for k,v in self.InstanceCount do
            if v.Status == 'Available' then
                v.Status = 'ActivePlatoon'
                v.PlatoonHandle = platoon
                
                platoon.BuilderHandle = self
                platoon.InstanceNumber = k
                local destroyedCallback = function(brain,platoon)
                    if platoon.BuilderHandle then
                        platoon.BuilderHandle:RemoveHandle(platoon)
                    end
                end
                platoon:AddDestroyCallback(destroyedCallback)
                break
            end
        end
    end,
    
    RemoveHandle = function(self,platoon)
        self.InstanceCount[platoon.InstanceNumber].Status = 'Available'
        self.InstanceCount[platoon.InstanceNumber].PlatoonHandle = false
        platoon.BuilderHandle = nil
    end,
}

-- EngineerBuilderSpec
-- This is the spec to have built by a factory
--{
--   PlatoonBuildCallbacks = {FunctionsToCallBack when the platoon starts to build}
--   BuilderData = {
--       Construction = {
--           BaseTemplate = basetemplates, must contain templates for all 3 factions it will be viewed by faction index,
--           BuildingTemplate = building templates, contain templates for all 3 factions it will be viewed by faction index,
--           BuildClose = true/false do I follow the table order or do build the best spot near me?
--           BuildRelative = true/false are the build coordinates relative to the starting location or absolute coords?,
--           BuildStructures = { List of structure types and the order to build them.}
--       }
--   }
--}

EngineerBuilder = Class(Builder) {
    __init = function(self, brain, engineerBuilderName, locationName)
        local bp = CAIEngineerBuilders[engineerBuilderName]
        if not bp then
            WARN('*ENGINEER BUILDER ERROR: Could not find engineer builder named - ' .. engineerBuilderName)
            return
        end

        Builder.__init(self,brain,bp,locationName)

        self.Blueprint = bp
    end,

    TestUnit = function(self, unit)
        if unit:IsDead() then
            return false
        end

        return self.Blueprint.EngineerType[unit:GetUnitId()]
    end,

    FormDebug = function(self)
        if self.FormDebugFunction then
            self.FormDebugFunction()
        end
    end, 
}
