--***************************************************************************
--*
--**  File     :  /lua/sim/BrainConditionsMonitor.lua
--**
--**  Summary  : Monitors conditions for a brain and stores them in a keyed
--**             table
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

ConditionsMonitor = Class {

    __init = function(self, brain)
        self.Trash = TrashBag()
        
        self.ThreadWaitDuration = 7
        
        self.Active = false
        
        self.ResultTable = {}
        self.ConditionData = {
            TableConditions = {},
            FunctionConditions = {},
        }
        self.ConditionsTable = {}
                
        self.Brain = brain
    end,

    -- Gets result for the keyed condition
    CheckKeyedCondition = function(self, conditionKey, reportFailure)
        if self.ResultTable[conditionKey] != nil then
            return self.ResultTable[conditionKey]:GetStatus(reportFailure)
        end
        WARN('*WARNING: No Condition found with condition key: ' .. conditionKey)
        return false
    end,
    
    -- Checks the condition and returns the result
    CheckConditionTable = function(self, cFilename, cFunctionName, cData)
        if not cData or not type(cData) == 'table' then
            WARN('*WARNING: Invalid argumetns for build condition: ' .. cFilename .. '[' .. cFunctionName .. ']')
            return false
        end
        return import(cFilename)[cFunctionName](self.Brain, unpack(cData))
    end,
    
    -- Runs the function and retuns the result
    CheckConditionFunction = function(self, func, params)
        return func(unpack(params))
    end,
    
    -- Find the key for a condition or adds it to the table and checks the condition
    GetConditionBlueprintKey = function(self, conditionName, conditionParameters, locationName, opAI)
        locationName = locationName or false
        opAI = opAI or false
        if not AIConditions[conditionName] then
            error('*CONDITION MONITOR: Could not find Condition named = ' .. conditionName)
        end

        local conditionBp = AIConditions[conditionName]
        
        -- Key the TableConditions by function condition blueprint name
        if not self.ConditionData.TableConditions[conditionName] then
            self.ConditionData.TableConditions[conditionName] = {}
        end
        
        -- Check if the cData matches up
        for num,data in self.ConditionData.TableConditions[conditionName] do
            -- Check if the data is the same length
            if table.getn(data.ConditionParameters) == table.getn(conditionParameters) then
                local match = true

                if (locationName != data.LocationName) then
                    match = false
                end
                
                if (opAI and data.OpAI and data.OpAI.OpAIName != opAI.OpAIName) then
                    match = false
                end

                -- Check each piece of data to make sure it matches
                for k,v in data.ConditionParameters do
                    if v != conditionParameters[k] then
                        match = false
                        break
                    end
                end

                -- Match found, return the key
                if match then
                    return data.Key
                end
            end
        end
        
        -- No match found, so add the data to the table and return the key (same number as num items)
        local newCondition
        if conditionBp.InstantCondition then
            newCondition = InstantBlueprintCondition()
        else
            newCondition = BlueprintCondition()
        end

        newCondition:Create(self.Brain, table.getn(self.ResultTable) + 1, conditionName, locationName, conditionParameters, opAI)
        table.insert( self.ResultTable, newCondition )
        
        -- Add in a hashed table for quicker key lookup, may not be necessary
        local newTable = { 
            ConditionParameters = conditionParameters, 
            LocationName = locationName,
            Key = newCondition:GetKey(),
        }
        table.insert( self.ConditionData.TableConditions[conditionName], newTable )
        return newTable.Key
    end,
    
    -- Find the key for a condition that is a function
    GetConditionKeyFunction = function(self, func, parameters)
        -- See if there is a matching function
        for k,v in self.ConditionData.FunctionConditions do
            if v.Function == func then
                local found = true
                for num,data in v.ConditionParameters do
                    if data != parameters[num] then
                        found = false
                        break
                    end
                end
                if found then
                    return v.Key
                end
            end
        end
        
        -- No match, insert data into the function conditions table
        local newCondition = FunctionCondition()
        newCondition:Create(self.Brain, table.getn(self.ResultTable) + 1, func, parameters )
        table.insert( self.ResultTable, newCondition )
        
        local newTable = {
            Function = func,
            Key = newCondition:GetKey(),
            ConditionParameters = parameters,
        }
        table.insert( self.ConditionData.FunctionConditions, newTable )
        return newTable.Key
    end,
    
    -- Thread that will monitor conditions the brain asks for over time
    ConditionMonitorThread = function(self)
        while true do
            local checks = 0
            local numChecks = table.getn(self.ResultTable)
            local numPerTick = math.ceil( numChecks / ( self.ThreadWaitDuration * 10 ) )
            
            for k,v in self.ResultTable do
                v:CheckCondition()
                
                -- Load balance per tick here
                checks = checks + 1
                if checks >= numPerTick then
                    WaitTicks(1)
                    checks = 0
                end
            end
            WaitTicks(1)
        end
    end,
    
    -- Adds a condition to the table and returns the key
    AddConditionFromBlueprint = function(self, conditionName, conditionParameters, locationName, opAI)
        if not self.Active then
            self.Active = true
            self:ForkThread(self.ConditionMonitorThread)
        end
        return self:GetConditionBlueprintKey(conditionName, conditionParameters, locationName, opAI)
    end,

    AddConditionFromFunction = function(self, func, parameters, locationName)
        if not self.Active then
            self.Active = true
            self:ForkThread(self.ConditionMonitorThread)
        end
        return self:GetConditionKeyFunction(func, parameters)
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
}

Condition = Class {
    -- Create the thing
    Create = function(self,brain,key)
        self.Status = false
        self.Brain = brain
        self.Key = key
    end,

    CheckCondition = function(self)
        self.Status = false
        return self.Status
    end,
    
    GetStatus = function(self, reportFailure)
        return self.Status
    end,
    
    GetKey = function(self)
        return self.Key
    end
}

BlueprintCondition = Class(Condition) {
    Create = function(self, brain, key, blueprintName, locationName, parameters, opAI)
        Condition.Create(self, brain, key)
        
        local bp = AIConditions[blueprintName]
        self.BlueprintName = blueprintName
        self.Function = bp.Function
        self.Parameters = parameters
        self.LocationName = locationName
        self.OpAI = opAI
    end,

    CheckCondition = function(self)
        if self.CheckTime != GetGameTimeSeconds() then
            self.Status = self:Function(self.Brain, self.LocationName, unpack(self.Parameters))
            self.CheckTime = GetGameTimeSeconds()
        end
        return self.Status
    end,

    GetStatus = function(self, reportFailure)
        if reportFailure and not self.Status then
            LOG('*AI DEBUG: Build Condition failed - ' .. self.BlueprintName .. ' - Data: ' .. repr(self.Parameters))
        end
        return self.Status
    end,
}

InstantBlueprintCondition = Class(Condition) {
    Create = function(self, brain, key, blueprintName, locationName, parameters, opAI)
        Condition.Create(self, brain, key)
        
        local bp = AIConditions[blueprintName]
        self.BlueprintName = blueprintName
        self.Function = bp.Function
        self.Parameters = parameters
        self.LocationName = locationName
        self.OpAI = opAI
    end,

    CheckCondition = function(self)
        return self.Status
    end,

    GetStatus = function(self, reportFailure)
        self.Status = self:Function(self.Brain, self.LocationName, unpack(self.Parameters))

        if reportFailure and not self.Status then
            LOG('*AI DEBUG: Build Condition failed - ' .. self.BlueprintName .. ' - Data: ' .. repr(self.Parameters))
        end

        return self.Status
    end,
}