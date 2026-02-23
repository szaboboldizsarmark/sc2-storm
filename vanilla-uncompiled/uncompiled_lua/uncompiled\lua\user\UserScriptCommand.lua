--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- File: lua/modules/ui/game/userScriptCommand.lua
-- Author(s):
-- Summary: User layer ability handling
-- Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
--------------------------------------------------------------------------
local CM = import('/lua/ui/game/commandmode.lua')

-- The user wants to issue an ability order in the current command mode. This
-- function validates the request. If the request is valid we set 
-- UserValidated to allow the order to be issued. If it's not valid we end the 
-- commandmode or do nothing depending on the context.
--
-- VerifyAbility should return a result table of the following format:
-- result = {
--    string AbilityName - What ability to execute
--    string TaskName - Which task class to execute (e.g. AbilityTask, SkillTask)
--    bool UserValidated - Whether or not this request has been validated
--    table AuthorizedUnits - List of units to issue the command to
-- }
function VerifyScriptCommand(data)
    local mode, modeData = CM.GetCommandMode()
   
    local result = {
        TaskName = modeData.TaskName,
        UserValidated = false,
        Location = data.Target.Position
    }
    
    if mode != "order" then
        WARN('VerifyScriptCommand() called when command mode is not "order"')
        return result
    end

    if modeData.name != "RULEUCC_Script" and  modeData.name != "RULEUCC_Ability" then
        WARN('VerifyScriptCommand() called when command name is not "Script" or "Ability"')
        return result
    end
    
    --LOG('verify script: ' ,modeData.UserVerifyScript )
    if modeData.name == "RULEUCC_Ability" then
        result.AbilityId = modeData.AbilityId
    elseif modeData.UserVerifyScript then
        import(modeData.UserVerifyScript).VerifyScriptCommand(data,result)
    else
        result.AuthorizedUnits = data.Units
        result.UserValidated = true
    end
    
    return result
end
