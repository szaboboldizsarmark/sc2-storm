--****************************************************************************
--**
--**  File     :  /lua/AI/CampaignAISystem.lua
--**  Author(s):
--**
--**  Summary  :
--**
--**  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local BaseManager = import('/lua/AI/campaign/system/BaseManager.lua').BaseManager

local BuilderManager = import('/lua/AI/BuilderManager.lua')
local AIFactoryManager = import('/lua/AI/campaign/system/FactoryBuilderManager.lua').AIFactoryManager
local AIEngineerManager = import('/lua/AI/campaign/system/EngineerManager.lua').AIEngineerManager
local AIUnitManager = import('/lua/AI/campaign/system/AIUnitManager.lua').AIUnitManager

local ConditionsMonitor = import('/lua/ai/BrainConditionsMonitor.lua').ConditionsMonitor
local Unit = import('/lua/sim/Unit.lua').Unit

CampaignAISystem = Class() {
    __init = function(self, aiBrain)
        self.Brain = aiBrain
        
        self.BuilderManagers = {}

        self.BaseManagers = {}

        local function constructionCallback(self, unit, finishedUnit)
            self:ConstructionFinished(unit,finishedUnit)
        end
        Unit.ClassCallbacks.OnStopBuild:Add( constructionCallback, self )
    end,

    ConstructionFinished = function(self, unit, finishedUnit)
        if unit:GetArmy() != self.Brain:GetArmyIndex() then
            return
        end
		
		if not finishedUnit or finishedUnit:IsDead() then
			return
		end

        if unit.BuilderManagerData then
            if unit.BuilderManagerData.FactoryManager then
                -- unit.BuilderManagerData.FactoryManager:FactoryFinishBuilding(unit, finishedUnit)
                unit.BuilderManagerData.FinishedUnitAdded = false
                unit.BuilderManagerData.FactoryManager:ForkThread( unit.BuilderManagerData.FactoryManager.FactoryFinishBuilding, unit, finishedUnit )
            end
        end

        --if EntityCategoryContains( categories.ENGINEER, finishedUnit ) then
        --    -- No builder manager; exit
        --    if not unit.BuilderManagerData.EngineerManager then
        --        return
        --    end
        --    -- LOG('*AI DEBUG: Adding Engineer to EngineerManager at Location - ' .. unit.BuilderManagerData.EngineerManager.Location)

        if EntityCategoryContains( categories.FACTORY, finishedUnit ) then
            -- No builder manager; exit
            if not unit.BuilderManagerData.LocationName then
                return
            end

            if not self.BaseManagers[unit.BuilderManagerData.LocationName] then
                return
            end

            if self.BaseManagers[unit.BuilderManagerData.LocationName].FactoryManager then
                -- LOG('*AI DEBUG: Adding Factory to FactoryManager at Location - ' .. unit.BuilderManagerData.LocationName)
                self.BaseManagers[unit.BuilderManagerData.LocationName].FactoryManager:AddFactory(finishedUnit)
            end
        else

            -- Default here; Do nothign right now
        end
    end,

    GetLocationPosition = function(self, locationType)
        if not self.BuilderManagers[locationType] then
            WARN('*AI ERROR: Invalid location type - ' .. locationType )
            return false
        end
        return self.BuilderManagers[locationType].Position
    end,
    
    FindClosestBuilderManagerPosition = function(self, position)
        local distance, closest
        for k,v in self.BuilderManagers do
            if v.EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) <= 0 and v.FactoryManager:GetNumCategoryFactories(categories.ALLUNITS) <= 0 then
                continue
            end
            
            if not closest then
                distance = VDist3( position, v.Position )
                closest = v.Position
            else
                local tempDist = VDist3( position, v.Position )
                if tempDist < distance then
                    distance = tempDist
                    closest = v.Position
                end
            end
        end
        return closest
    end,
    
    ForceManagerSort = function(self)
        for k,v in self.BuilderManagers do
            v.EngineerManager:SortBuilderList('Any')
            v.FactoryManager:SortBuilderList('Land')
            v.FactoryManager:SortBuilderList('Air')
            v.FactoryManager:SortBuilderList('Sea')
            v.PlatoonFormManager:SortBuilderList('Any')
        end
    end,

    GetManagerCount = function(self, type)
        local count = 0
        for k,v in self.BuilderManagers do
            if type then
                if type == 'Start Location' and not ( string.find(k, 'ARMY_') or string.find(k, 'Large Expansion') ) then
                    continue
                elseif type == 'Naval Area' and not ( string.find(k, 'Naval Area') ) then
                    continue
                elseif type == 'Expansion Area' and ( not string.find(k, 'Expansion Area') or string.find(k, 'Large Expansion') ) then
                    continue
                end
            end
        
            if v.EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) <= 0 and v.FactoryManager:GetNumCategoryFactories(categories.ALLUNITS) <= 0 then
                continue
            end
            
            count = count + 1
        end
        return count
    end,

    AddBaseManager = function(self, baseName, markerName, radius, levelTable, difficultySeparate, vetLevel)
        BaseManager(self.Brain, self, baseName, markerName, radius, levelTable, difficultySeparate, vetLevel)
        return self.BaseManagers[baseName]
    end,

    AddBuilderManagers = function(self, position, radius, baseName, useCenter, vetLevel )
        self.BuilderManagers[baseName] = {
            FactoryManager = AIFactoryManager(self.Brain, baseName, position, radius, useCenter, vetLevel),
            UnitManager = AIUnitManager(self.Brain, baseName, position, radius, useCenter),
            EngineerManager = AIEngineerManager(self.Brain, baseName, position, radius),

            BuilderHandles = {},
            
            Position = position,
        }

        return self.BuilderManagers[baseName]
    end,
    
    DisableAllOpAI = function(self)
        for bName, base in self.BaseManagers do
            for opName, opAI in base.OpAITable do
                opAI:Disable()
            end
        end
    end,

}

function SetupCampaignSystems(aiBrain)
    aiBrain.ConditionsMonitor = ConditionsMonitor(aiBrain)

    aiBrain.CampaignAISystem = CampaignAISystem(aiBrain)
end