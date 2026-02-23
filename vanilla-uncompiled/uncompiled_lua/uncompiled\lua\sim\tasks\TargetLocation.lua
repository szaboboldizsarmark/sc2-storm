--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--*****************************************************************************
--* File: lua/TargetLocation.lua
--*
--* Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************
local ScriptTask = import('/lua/sim/tasks/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/tasks/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT

TargetLocation = Class(ScriptTask) {
    
    OnCreate = function(self,commandData)
        ScriptTask.OnCreate(self,commandData)
        local unit = self:GetUnit():OnTargetLocation(commandData.Location)
    end,
    
    TaskTick = function(self)
        self:SetAIResult(AIRESULT.Success)
        return TASKSTATUS.Done
    end,

    IsInRange = function(self)
        return true
    end,
}
