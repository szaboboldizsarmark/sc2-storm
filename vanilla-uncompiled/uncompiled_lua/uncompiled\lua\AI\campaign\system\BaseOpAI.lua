--***************************************************************************
--*
--**  File     :  /lua/ai/OpAI/BaseOpAI.lua
--**  Author(s): Dru Staltman
--**
--**  Summary  : Base manager for operations
----**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioPlatoonAI = import('/lua/ai/ScenarioPlatoonAI.lua')

OpAI = Class {
    -- Set up variables local to this OpAI instance
    __init = function(self, brain, baseManager, builderType, name, builderData)
        local OpAIBp = OpAIBlueprints[builderType]
        if not OpAIBp then
            WARN('*OpAI ERROR: No OpAI Global named: '.. builderType)
            return false
        end
        self.Blueprint = OpAIBp

        self.Announce = false

        self.Trash = TrashBag()
        self.Active = true

        -- Callbacks
        self.FormCallback = Callback()

        -- local tables to this class instance
        self.ChildrenNames = {}
        self.EnabledTypes = {}
        self.Builders = {}

        -- Store off local instances of some variables
        self.AIBrain = brain
        self.BaseManager = baseManager
        self.LocationType = self.BaseManager.BaseName

        self.DefaultVetLevel = 0

        self.BuilderType = builderType
        self.GlobalVarName = name .. '_' .. self.BuilderType
        self.OpAIName = name .. '_' .. self.LocationType

        -- Variables to help define base "character"
        self.ChildCount = self.Blueprint.ChildCount
        self.MaxActivePlatoons = self.Blueprint.MaxActivePlatoons
        self.AttackDelay = -1
        self.TargetBrain = 1

        -- We keep a tally of the number of factory builders built; when we form and attack
        -- we reset this number; the personality of the base determines the number of attacks
        self.FactoryBuildersUnderConstruction = 0
        self.WaitingBuilders = 0
        self.ActivePlatoons = 0
        self.LastFormTime = 0

        -- Data for forming platoons
        self.PlatoonThreadName = false
        self.PlatoonThreadData = {}

        -- Load all the platoon data info in the formation desired
        local platoonData = {
            PlatoonName = self.OpAIName,
        }
        if not builderData then
            platoonData.Priority = 0
            platoonData.PlatoonData = {}
        else
            -- Set PlatoonData
            if builderData.PlatoonData then
                platoonData.PlatoonData = builderData.PlatoonData
            else
                platoonData.PlatoonData = {}
            end
            -- Set priority
            if builderData.Priority then
                platoonData.Priority = builderData.Priority
            else
                platoonData.Priority = 0
            end
        end
        self.PlatoonData = platoonData


        -- Add the factory builders here
        for _,builderName in OpAIBp.FactoryBuilders do
            local builderBp = CAIFactoryBuilders[builderName]
            if not builderName then
                WARN('*OpAI ERROR: No CAIFactoryBuilders named: '..builderName)
                continue
            end

            local builder = self.BaseManager.FactoryManager:AddBuilder(builderName, self)

            table.insert( self.Builders, builder )

            if builderBp.ChildrenTypes then
                self:AddChildType( builderBp.ChildrenTypes )
            end
        end

        -- self:AddBuildCondition(BMBC, 'BaseActive', { self.LocationType } )
    end,

    Enable = function(self)
        self.Active = true
    end,

    Disable = function(self)
        self.Active = false
    end,

    Destroy = function(self)
        self.Trash:Destroy()
    end,

    SetAnnounce = function(self, value)
        self.Announce = value
    end,

    -- forking and storing a thread on the monitor
    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,

    AdjustPriority = function(self, amount)
        for k,v in self.Builders do
            v:SetPriority( v.Priority + amount )
        end
    end,

    SetDefaultVeterancy = function(self, vetLevel)
        if vetLevel then
            self.DefaultVetLevel = vetLevel
        end
    end,

    -- When a factory builder starts being constructed, we have it call the OpAI to inform it
    -- The OpAI will do bookkeeping regarding the number of FactoryBuilders to allow, etc
    FactoryBuilderStarted = function(self, builder, factory)
        self.FactoryBuildersUnderConstruction = self.FactoryBuildersUnderConstruction + 1

        if self.Blueprint.AnnounceBuilder or self.Announce then
            LOG('*OPAI Logging: OpAI = ' .. self.OpAIName .. ' - Starting Builder = ' .. builder.BuilderName )
        end

        -- This base op AI is now starting
        if self.WaitingBuilders == 0 or table.empty(self.WaitingUnits) then
            self.WaitingUnits = {}
        end
    end,

    -- When a factory builder for an OpAI is finished; it calls back so the OpAI can handle it
    FactoryBuilderFinished = function(self, builder)
        self.WaitingBuilders = self.WaitingBuilders + 1
        self.FactoryBuildersUnderConstruction = self.FactoryBuildersUnderConstruction - 1

        if self.Blueprint.AnnounceBuilder or self.Announce then
            LOG('*OPAI Logging: OpAI = ' .. self.OpAIName .. ' - BuilderFinished = ' .. builder.BuilderName )
        end
        if self.WaitingBuilders >= self.ChildCount then
            self.WaitingBuilders = 0
            self:FormPlatoon()
        end
    end,

    -- When a unit is finshed; we are given the unit to do with as we wish
    UnitConstructionFinished = function(self, builder, unit)
        -- LOG('*AI DEBUG: UnitFinished - UnderConstruction = ' .. self.FactoryBuildersUnderConstruction .. ' - Waiting = ' .. self.WaitingBuilders )
        if self.DefaultVetLevel > 0 and unit:GetBlueprint().General.ExperienceTable != "" then
            unit:SetVeterancy(self.DefaultVetLevel)
        end
        if not EntityCategoryContains( categories.UPGRADEMODULE, unit ) then
            table.insert(self.WaitingUnits, unit)
        end
    end,

    PlatoonDestroyed = function(self, platoon)
        self.ActivePlatoons = self.ActivePlatoons - 1
    end,

    -- This will add a platoon as an active platoon and set up callbacks and such for it.
    -- If useDefaultThread is nil or true, the platoon will have the default AI thread for the OpAI forked
    AddActivePlatoon = function(self, platoon, useDefaultThread)
        self.ActivePlatoons = self.ActivePlatoons + 1

        platoon.Callbacks.OnDestroyed:Add(self.PlatoonDestroyed, self)

        if self.PlatoonThreadName and useDefaultThread != false then
            -- LOG('*AI DEBUG: Forking Platoon Thread')
            platoon:SetPlatoonData(self.PlatoonData)
            if not CAIPlatoonThreads[self.PlatoonThreadName].Function then
                WARN('*OPAI ERROR: No Platoon Thread found with name - ' .. self.PlatoonThreadName )
            end
            platoon:ForkAIThread( CAIPlatoonThreads[self.PlatoonThreadName].Function, self.PlatoonThreadData )
        end
    end,

    -- This will spawn a platoon from editor army list as an active platoon and set up callbacks and such for it.
    -- If useDefaultThread is nil or true, the platoon will have the default AI thread for the OpAI forked
    SpawnActivePlatoon = function(self, armyName, groupName, formationName, useDefaultThread)
        formationName = formationName or 'AttackFormation'

        local newPlat = ScenarioUtils.CreateArmyGroupAsPlatoon(armyName, groupName, 'AttackFormation')

        self:AddActivePlatoon(newPlat, useDefaultThread)
    end,

    FormPlatoon = function(self)

        if self.Blueprint.AnnounceBuilder or self.Announce then
            LOG('*OPAI Logging: OpAI = ' .. self.OpAIName .. ' - Forming a platoon from children' )
        end

        local platoon = self.AIBrain:MakePlatoon('','')
        local addUnits = {}
        for k,v in self.WaitingUnits do
            if v:IsDead() then
                continue
            end
            table.insert(addUnits, v)
        end

        self.AIBrain:AssignUnitsToPlatoon( platoon, addUnits, 'Attack', 'AttackFormation' )
        self.WaitingUnits = {}

        platoon.OpAIName = self.OpAIName
        platoon.OpAI = self

        platoon:SetPlatoonData(self.PlatoonData)

        self.FormCallback:Call(platoon)

        self.ActivePlatoons = self.ActivePlatoons + 1
        -- Setup platoon death callback here
        platoon.Callbacks.OnDestroyed:Add(self.PlatoonDestroyed, self)
        self.LastFormTime = GetGameTimeSeconds()

        self:ForkThread( function(self)
            if self.PlatoonThreadName then
                for k,v in platoon:GetPlatoonUnits() do
                    while not v:IsDead() and v:IsUnitState('Attached') do
                        WaitTicks(1)
                    end
                end
                if not CAIPlatoonThreads[self.PlatoonThreadName].Function then
                    WARN('*OPAI ERROR: No Platoon Thread found with name - ' .. self.PlatoonThreadName )
                end
                platoon:Stop()
                platoon:ForkAIThread( CAIPlatoonThreads[self.PlatoonThreadName].Function, self.PlatoonThreadData )
            end
        end )
    end,

    -- When we form up the factory builders; we reset the number and add to the count of active platoons
    -- We are passed the platoon builder that is formed, the platoon,  and a table of all the children it's formed from
    PlatoonBuilderFormed = function(self, builder, platoon, children)
        self.FactoryBuildersUnderConstruction = self.FactoryBuildersUnderConstruction - table.getn(children)
        self.ActivePlatoonBuilders = self.ActivePlatoonBuilders + 1

        -- Setup platoon death callback here
    end,

    CheckFactoryBuilderLock = function(self)
        if not self.Active then
            return true
        end

        if self.FactoryBuildersUnderConstruction + self.WaitingBuilders >= self.ChildCount then
            return true
        end

        if self.ActivePlatoons >= self.MaxActivePlatoons then
            return true
        end

        if self.AttackDelay > 0 then
            if GetGameTimeSeconds() < self.LastFormTime + self.AttackDelay and self.LastFormTime > 0 then
                return true
            end
        end

        return false
    end,

    AddChildType = function( self,typeTable )
        if typeTable then
            for tNum, tName in typeTable do
                if self.EnabledTypes[tName] == nil then
                    self.EnabledTypes[tName] = true
                end
            end
        end
    end,

    DisableChildTypes = function(self, typeTable)
        for k,v in typeTable do
            self.EnabledTypes[v] = false
        end
    end,

    EnableChildTypes = function(self, typeTable)
        for k,v in self.EnabledTypes do
            self.EnabledTypes[k] = false
        end

        for k,v in typeTable do
            self.EnabledTypes[v] = true
        end
    end,

    CheckChildTypes = function(self,childTypes)
        if not childTypes then
            return true
        end

        for k,v in childTypes do
            if not self.EnabledTypes[v] then
                return false
            end
        end
        return true
    end,

    SetTargetArmyIndex = function(self, index)
        self.TargetBrain = index
    end,

    SetChildCount = function(self,count)
        self.ChildCount = count
    end,

    SetFormation = function(self, formationName)
        self.OverrideFormation = formationName
        return true
    end,

    SetMaxActivePlatoons = function(self,count)
        self.MaxActivePlatoons = count
    end,

    SetAttackDelay = function(self,time)
        self.AttackDelay = time
    end,

    SetPlatoonThread = function(self, threadName, threadData)
        if not CAIPlatoonThreads[threadName] then
            WARN('*AI ERROR: Could not find CAIPlatoonThreadBlueprint named - ' .. threadName)
            return
        end

        self.PlatoonThreadName = threadName
        if threadData then
            self.PlatoonThreadData = threadData
        end
    end,

    -- Build conditions for PBM; Attack Conditions for AM Platoons
    AddBuildCondition = function(self, fileName, funcName, parameters, bName)
        return true
    end,

    RemoveBuildCondition = function(self, funcName, bName)
        return true
    end,

    -- Add Functions for PBM Platoons; FormCallbacks for AM Platoons
    AddAddFunction = function(self, fileName, funcName, bName)
        return true
    end,

    RemoveAddFunction = function(self, funcName, bName)
        return true
    end,

    RemoveFormCallback = function(self,filename,funcName,bName)
        self:RemoveAddFunction(filename,funcName,bName)
    end,

    -- Add Build Callback for PBM Platoons; Death Callback for AM Platoons
    AddBuildCallback = function(self, fileName, funcName, bName)
        return true
    end,

    AddDestroyCallback = function(self,fileName,funcName,bName)
        self:AddBuildCallback(fileName,funcName,bName)
    end,

    RemoveBuildCallback = function(self, funcName, bName)
        return true
    end,

    RemoveDestroyCallback = function(self,fileName,funcName,bName)
        self:RemoveBuildCallback(fileName,funcName,bName)
    end,

}