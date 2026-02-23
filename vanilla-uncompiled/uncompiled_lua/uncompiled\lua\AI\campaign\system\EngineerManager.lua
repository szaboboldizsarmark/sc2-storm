--****************************************************************************
--*
--**  File     :  /lua/ai/EngineerManager.lua
--**
--**  Summary  : Manage engineers for a location
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local BuilderManager = import('/lua/ai/BuilderManager.lua').BuilderManager
local AIUtils = import('/lua/ai/aiutilities.lua')
local EngineerBuilder = import('/lua/ai/campaign/system/Builder.lua').EngineerBuilder
local AIBuildUnits = import('/lua/ai/aibuildunits.lua')

AIEngineerManager = Class(BuilderManager) {
    __init = function(self, brain, locationName, location, radius)
        BuilderManager.__init(self,brain)

        if not locationName or not location or not radius then
            error('*PLATOOM FORM MANAGER ERROR: Invalid parameters; requires locationName, location, and radius')
            return false
        end
        
        self.Location = location
        self.Radius = radius
        self.LocationName = locationName

        self.Count = 0
        self.UnitsList = {}
        
        self:AddBuilderType('Any')
    end,
    

    -- =============================== --
    --     Builder based functions
    -- =============================== --
    AddBuilder = function(self, builderName)
        local newBuilder = EngineerBuilder(self.Brain, builderName, self.LocationName)
        self:AddInstancedBuilder(newBuilder, 'Any')
        return newBuilder
    end,

    AddUnit = function(self, unit, dontAssign)
        LOG('*AI DEBUG: Adding unit to Engineer Manager - ' .. unit:GetUnitId() .. ' - Base = ' ..self.LocationName)
        table.insert( self.UnitsList, unit )
        self.Count = self.Count + 1
        
        if not unit.BuilderManagerData then
            unit.BuilderManagerData = {} 
        end
        unit.BuilderManagerData.EngineerManager = self
        unit.BuilderManagerData.LocationName = self.LocationName

        self:AssignEngineerTask(unit)
    end,
    
    RemoveUnit = function(self, unit)
        for k,v in self.UnitsList do
            if v == unit then
                table.remove(self.UnitsList, k)
                self.Count = self.Count - 1
                if unit.PlatoonHandle then
                    LOG('*AI DEBUG: ARMY ' .. unit:GetArmy() .. ': Removing enginner working from base - ' .. self.LocationName)
                    self.Brain.CampaignAISystem.BaseManagers[self.LocationName]:SetEngineersWorking(-1)
                end
                break
            end
        end
    end,
    
    ReassignUnit = function(self, unit)
        local managers = self.Brain.BuilderManagers
        local bestManager = false
        local distance = false
        local unitPos = unit:GetPosition()
        for k,v in managers do
            local checkDistance = VDist3( v.EngineerManager:GetLocationCoords(), unitPos)
            if not distance or checkDistance < distance then
                distance = checkDistance
                bestManager = v.EngineerManager
            end
        end
        bestManager:AddUnit(unit)
    end,
    
    TaskFinished = function(self, unit)
        self.Brain.CampaignAISystem.BaseManagers[self.LocationName]:SetEngineersWorking(-1)
        self:AssignEngineerTask(unit)
    end,
    
    EngineerWaiting = function( self, unit )
        WaitSeconds(5)
        self:AssignEngineerTask( unit )
    end,
    
    AssignTimeout = function(self, builderName)
        local oldPri = self:GetBuilderPriority(builderName)
        if oldPri then
            self:SetBuilderPriority(builderName, 0, true)
        end
    end,
    
    AssignEngineerTask = function(self, unit)
        if not unit or unit:IsDead() then
            return
        end
        unit.DesiresAssist = false
        unit.NumAssistees = nil
        -- LOG('*AI DEBUG: Engineer Manager finding task for - ' .. unit:GetUnitId() .. ' - Base = ' ..self.LocationName)
        local builder = self:GetHighestBuilder('Any', {unit})
        if builder then
            -- Fork off the platoon here
            local hndl = self.Brain:MakePlatoon( '', '' )
            self.Brain:AssignUnitsToPlatoon( hndl, {unit}, 'support', 'none' )
            unit.PlatoonHandle = hndl

            LOG('*AI DEBUG: ARMY '..repr(self.Brain:GetArmyIndex())..': Engineer Manager Forming - '..repr(builder.BuilderName)..' - Priority: '..builder:GetPriority()..' - Base = ' ..self.LocationName)
            hndl.PlanName = ''

            --If we have specific AI, fork that AI thread
            if builder.Blueprint.PlatoonThread then
                hndl:StopAI()
                
                if not CAIPlatoonThreads[builder.Blueprint.PlatoonThread] then
                    WARN('*ENGINEER MANAGER WARNING: Could not find PlatoonThread named ' .. builder.Blueprint.PlatoonThread)
                    self:ForkThread( self.EngineerWaiting, unit )
                    return
                end
                local aiFunction = CAIPlatoonThreads[builder.Blueprint.PlatoonThread].Function
                hndl:ForkAIThread(aiFunction, self.Brain, self.LocationName)
            end

            hndl.Priority = builder:GetPriority()
            hndl.BuilderName = builder:GetBuilderName()
            LOG('*AI DEBUG: Engineer Manager assigning task to - ' .. unit:GetUnitId() .. ' - Base = ' ..self.LocationName)
            -- builder:StoreHandle(hndl)
            self.Brain.CampaignAISystem.BaseManagers[self.LocationName]:SetEngineersWorking(1)
            return
        end
        -- LOG('*AI DEBUG: Engineer Manager no builder for - ' .. unit:GetUnitId() .. ' - Base = ' ..self.LocationName)
        self:ForkThread( self.EngineerWaiting, unit )
    end,
    
    DelayAssign = function(self, unit)
        if not unit.DelayThread then
            unit.DelayThread = unit:ForkThread( self.DelayAssignBody, self )
        end
    end,
    
    DelayAssignBody = function( unit, manager )
        WaitSeconds(1)
        if not unit:IsDead() then
            manager:AssignEngineerTask(unit)
        end
        unit.DelayThread = nil
    end,
    
    ManagerLoopBody = function(self,builder,bType)
        if builder.OldPriority then
            builder:ResetPriority()
        end
        BuilderManager.ManagerLoopBody(self,builder,bType)
    end,

    BuilderParamCheck = function(self,builder,params)
        local unit = params[1]
        
        builder:FormDebug()
        
        -- Check if the category of the unit matches the category of the builder
        if not builder:TestUnit(unit) then
            return false
        end
        
        -- Nope
        return true
    end,
    
}
