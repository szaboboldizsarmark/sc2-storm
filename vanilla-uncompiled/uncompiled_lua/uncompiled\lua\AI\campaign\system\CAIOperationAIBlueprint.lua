--****************************************************************************
--**
--**  File     :  /lua/ai/campaign/system/CAIOperationAIBlueprint.lua
--**
--**  Summary  :  Global OpAI table and blueprint methods
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- Global list of all buffs found in the system.
OpAIBlueprints = {}

-- OpAI are created by invoking CAIOperationAIBlueprint() with a table
-- as the OpAI data. They can be defined in any module at any time.
-- e.g.
--
-- CAIOperationAIBlueprint {
--    Name = 'UnitsLessThan',
--    FactoryBuilders = {
--         'BuilderName',
--         'BuilderName',
--    },
--    ChildCount = 3,
--    MaxActivePlatoons = 1,
-- }
--
--
--
CAIOperationAIBlueprint = {}
CAIOperationAIBlueprintDefMeta = {}

CAIOperationAIBlueprintDefMeta.__index = CAIOperationAIBlueprintDefMeta
CAIOperationAIBlueprintDefMeta.__call = function(...)
    
    if type(arg[2]) ~= 'table' then
        WARN('Invalid CAIOperationAIBlueprint: ', repr(arg))
        return
    end
    
    if not arg[2].Name then
        WARN('Missing name for CAIOperationAIBlueprint definition: ',repr(arg))
        return
    end
    
    if OpAIBlueprints[arg[2].Name] then
        WARN('Duplicate CAIOperationAIBlueprint detected: ', arg[2].Name)
    end

    if not arg[2].FactoryBuilders then
        WARN('Missing FactoryBuilders for CAIOperationAIBlueprint definition: ',arg[2].Name)
        return
    end

    if not arg[2].ChildCount then
        WARN('Missing ChildCount for CAIOperationAIBlueprint definition: ',arg[2].Name)
        return
    end

    if not arg[2].MaxActivePlatoons then
        WARN('Missing MaxActivePlatoons for CAIOperationAIBlueprint definition: ',arg[2].Name)
        return
    end

    
    if not OpAIBlueprints[arg[2].Name] then
        OpAIBlueprints[arg[2].Name] = {}
    end

    SPEW('CAIOperationAIBlueprint Registered: ', arg[2].Name)
    
    OpAIBlueprints[arg[2].Name] = arg[2]
    return arg[2].Name
end

setmetatable(CAIOperationAIBlueprint, CAIOperationAIBlueprintDefMeta)