--****************************************************************************
--**
--**  File     :  /lua/ai/campaign/system/CAIConditionBlueprint.lua
--**
--**  Summary  :  Global condition table and blueprint methods
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- Global list of all buffs found in the system.
AIConditions = {}

-- Conditions are created by invoking CAIConditionBlueprint() with a table
-- as the condition data. They can be defined in any module at any time.
-- e.g.
--
-- CAIConditionBlueprint {
--    Name = 'UnitsLessThan',
--    Function = function(brain, args),
-- }
--
--
--
CAIConditionBlueprint = {}
CAIConditionBlueprintDefMeta = {}

CAIConditionBlueprintDefMeta.__index = CAIConditionBlueprintDefMeta
CAIConditionBlueprintDefMeta.__call = function(...)
    
    if type(arg[2]) ~= 'table' then
        WARN('Invalid CAIConditionBlueprint: ', repr(arg))
        return
    end
    
    if not arg[2].Name then
        WARN('Missing name for CAIConditionBlueprint definition: ',repr(arg))
        return
    end
    
    if AIConditions[arg[2].Name] then
        WARN('Duplicate CAIConditionBlueprint detected: ', arg[2].Name)
    end

    if not arg[2].Function then
        WARN('Missing FunctionName for CAIConditionBlueprint definition: ',arg[2].Name)
        return
    end
    
    if not AIConditions[arg[2].Name] then
        AIConditions[arg[2].Name] = {}
    end

    SPEW('CAIConditionBlueprint Registered: ', arg[2].Name)
    
    AIConditions[arg[2].Name] = arg[2]
    return arg[2].Name
end

setmetatable(CAIConditionBlueprint, CAIConditionBlueprintDefMeta)