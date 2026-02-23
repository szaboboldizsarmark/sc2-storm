-----------------------------------------------------------------------------
--  File     : /lua/ai/platoon.lua
--  Author(s): Drew Staltman, Robert Oates, Gautam Vasudevan, Daniel Teh?, ...?
--  Summary  : Platoon Lua Module  
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
--SC2 FIX NEED: file contains specific unit references that are no longer valid - needs reolution - bfricks 9/19/08
local AIUtils = import('/lua/ai/aiutilities.lua')
local Utilities = import('/lua/system/utilities.lua')
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local SPAI = import('/lua/ai/ScenarioPlatoonAI.lua')

Platoon = Class(moho.platoon_methods) {
    NeedCoolDown = false,
    LastAttackDestination = {},
    
    OnCreate = function(self, plan)
        self.Trash = TrashBag()
        if plan != "" then
            self:SetAIPlan(plan)
        end
        self.PlatoonData = {}
        self.Callbacks = {
            OnDestroyed = Callback(),
        }
        self.CreationTime = GetGameTimeSeconds()
    end,

    SetPlatoonData = function(self, dataTable)
        self.PlatoonData = table.deepcopy(dataTable)
    end,

    ForkAIThread = function(self, fn, ...)
        if fn then
            self.AIThread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(self.AIThread)
            return self.AIThread
        else
            return nil
        end
    end,

    StopAI = function(self)
        if self.AIThread ~= nil then
            self.AIThread:Destroy()
        end
    end,

    OnDestroy = function(self)
        self.Callbacks.OnDestroyed:Call(self)
        if self.Trash then
            self.Trash:Destroy()
        end
    end,

    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,

    SetAIPlan = function(self, plan)
        if not self[plan] then return end
        if self.AIThread then
            self.AIThread:Destroy()
        end
        self.PlanName = plan
        self:ForkAIThread(self[plan])
    end,

    GetPlan = function(self)
        if self.PlanName then
            return self.PlanName
        end
    end,

    WaitPlan = function(self)
        WaitSeconds(3)
        local aiBrain = self:GetBrain()
        local skirmishBase = aiBrain:GetSkirmishBase( self:GetSkirmishBaseName() )
        for k,v in self:GetPlatoonUnits() do
            skirmishBase:UnitTaskComplete(v)
        end
    end,

    GetThreatLevel = function(self, rings)
        local brain = self:GetBrain()
        return brain:GetThreatAtPosition(self:GetPlatoonPosition(), rings, true)
    end,

    CheckCommandsCompleted = function(self, commands)
        for k, v in commands do
            if self:IsCommandsActive(commands) then
                return false
            end
        end
        return true
    end,
    
    OnUnitsAddedToPlatoon = function(self)
        for k,v in self:GetPlatoonUnits() do
            if not v:IsDead() then
                v.PlatoonHandle = self
            end 
        end
    end,
    
    PlatoonDisband = function(self)
        --LOG('*AI DEBUG: Platoon Disbanding - ' .. self.BuilderName )
        if self.BuilderHandle then
            self.BuilderHandle:RemoveHandle(self)
        end
        for k,v in self:GetPlatoonUnits() do
            v.PlatoonHandle = nil
            if not v:IsDead() and v.BuilderManagerData then
                if self.CreationTime == GetGameTimeSeconds() and v.BuilderManagerData.EngineerManager then
                    if self.BuilderName then
                        --LOG('*AI DEBUG: ERROR - Platoon disbanded same tick as created - ' .. self.BuilderName .. ' - Army: ' .. self:GetBrain():GetArmyIndex() .. ' - Location: ' .. v.BuilderManagerData.LocationType )
                        v.BuilderManagerData.EngineerManager:AssignTimeout(v, self.BuilderName)
                    else
                        --LOG('*AI DEBUG: ERROR - Platoon disbanded same tick as created - Army: ' .. self:GetBrain():GetArmyIndex() .. ' - Location: ' .. v.BuilderManagerData.LocationType )
                    end
                    v.BuilderManagerData.EngineerManager:DelayAssign(v)
                elseif v.BuilderManagerData.EngineerManager then
                    v.BuilderManagerData.EngineerManager:TaskFinished(v)
                end
            end
        end
        self:GetBrain():DisbandPlatoon(self)
    end,
    
    GetPlatoonThreat = function(self, threatType, unitCategory, position, radius)
        local threat = 0
        if position then
            threat = self:CalculatePlatoonThreatAroundPosition( threatType, unitCategory, position, radius )
        else
            threat = self:CalculatePlatoonThreat( threatType, unitCategory )
        end
        return threat
    end,
    
    GetUnitsAroundPoint = function(self, category, point, radius)
        local units = {}
        for k,v in self:GetPlatoonUnits() do
        
            -- Wrong unit type
            if not EntityCategoryContains( category, v ) then
                continue
            end
            
            -- Too far away
            if Utilities.XZDistanceTwoVectors( v:GetPosition(), point ) > radius then
                continue
            end
            
            table.insert( units, v )
        end
        return units
    end,
    
    GetNumCategoryUnits = function(self, category, position, radius)
        local numUnits = 0
        if position then
            numUnits = self:PlatoonCategoryCountAroundPosition( category, position, radius )
        else
            numUnits = self:PlatoonCategoryCount( category )
        end
        return numUnits
    end,
    
    DisbandAI = function(self)
        self:Stop()
        self:PlatoonDisband()
    end,
    
    DrawDebugCircle = function(self, point, radius)
        self:ForkThread( self.DrawDebugCircleFunc, point, radius )
    end,
    
    DrawDebugCircleFunc = function(self, point, radius)
        local count = 1
        local color = "LimeGreen"
        point[2] = GetSurfaceHeight(point[1], point[3])
        while count <= 100 do
            DrawCircle(point, radius, color )
            WaitTicks(1)
            count = count + 1
        end
    end,
 
}
