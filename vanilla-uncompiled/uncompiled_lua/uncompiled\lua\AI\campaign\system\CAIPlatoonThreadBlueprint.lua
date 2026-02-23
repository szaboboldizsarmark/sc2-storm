--****************************************************************************
--**
--**  File     :  /lua/ai/campaign/system/CAIPlatoonThreadBlueprint.lua
--**
--**  Summary  :  Global buff table and blueprint methods
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- Global list of all buffs found in the system.
CAIPlatoonThreads = {}

-- Engineer Builders are created by invoking CAIPlatoonThreadBlueprint() with a table
-- as the builder data. They can be defined in any module at any time.
-- e.g.
--
-- CAIPlatoonThreadBlueprint {
--    Name = 'Base Manager Engineer',
--    Function = function(platoon, aiBrain)
--        DoStuff()
--    end,
-- }
--
--
--
CAIPlatoonThreadBlueprint = {}
CAIPlatoonThreadBlueprintDefMeta = {}

CAIPlatoonThreadBlueprintDefMeta.__index = CAIPlatoonThreadBlueprintDefMeta
CAIPlatoonThreadBlueprintDefMeta.__call = function(...)
    
    if type(arg[2]) ~= 'table' then
        WARN('Invalid CAIPlatoonThreadBlueprint: ', repr(arg))
        return
    end
    
    if not arg[2].Name then
        WARN('Missing name for CAIPlatoonThreadBlueprint definition: ',repr(arg))
        return
    end
    
    if CAIPlatoonThreads[arg[2].Name] then
        WARN('Duplicate CAIPlatoonThreadBlueprint detected: ', arg[2].Name)
    end

    if not arg[2].Function then
        WARN('Missing Function for CAIPlatoonThreadBlueprint definition: ',arg[2].Name)
        return
    end
    
    if not CAIPlatoonThreads[arg[2].Name] then
        CAIPlatoonThreads[arg[2].Name] = {}
    end

    SPEW('CAIPlatoonThread Registered: ', arg[2].Name)
    
    CAIPlatoonThreads[arg[2].Name] = arg[2]
    return arg[2].Name
end

setmetatable(CAIPlatoonThreadBlueprint, CAIPlatoonThreadBlueprintDefMeta)