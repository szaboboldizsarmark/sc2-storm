--****************************************************************************
--**
--**  File     :  /lua/ai/campaign/system/CAIEngineerBuilderBlueprint.lua
--**
--**  Summary  :  Global buff table and blueprint methods
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- Global list of all buffs found in the system.
CAIEngineerBuilders = {}

-- Engineer Builders are created by invoking CAIEngineerBuilderBlueprint() with a table
-- as the builder data. They can be defined in any module at any time.
-- e.g.
--
-- CAIEngineerBuilderBlueprint {
--    Name = 'Factory Builder Engineer',
--    EngineerType = {
--        uul0001 = true,
--    },
--    Conditions = {
--        {
--            { BCondition },
--            { BCondition },
--        },
--        {
--            { BCondition },
--        },
--    },
--    EngineerData = {
--        ConstructionGoal = 'uub0001',
--    },
--    PlatoonThread = 'PlatoonThreadBlueprintName',
--    Priority = 900,
-- }
--
--
--
CAIEngineerBuilderBlueprint = {}
CAIEngineerBuilderBlueprintDefMeta = {}

CAIEngineerBuilderBlueprintDefMeta.__index = CAIEngineerBuilderBlueprintDefMeta
CAIEngineerBuilderBlueprintDefMeta.__call = function(...)
    
    if type(arg[2]) ~= 'table' then
        WARN('Invalid CAIEngineerBuilderBlueprint: ', repr(arg))
        return
    end
    
    if not arg[2].Name then
        WARN('Missing name for CAIEngineerBuilderBlueprint definition: ',repr(arg))
        return
    end
    
    if CAIEngineerBuilders[arg[2].Name] then
        WARN('Duplicate CAIEngineerBuilderBlueprint detected: ', arg[2].Name)
    end

    if not arg[2].Priority then
        WARN('Missing Priority for CAIEngineerBuilderBlueprint definition: ',arg[2].Name)
        return
    end
    
    if not arg[2].EngineerType then
        WARN('Missing BuilderType for CAIEngineerBuilderBlueprint definition: ',arg[2].Name)
        return
    end

    if not arg[2].EngineerData and not arg[2].PlatoonThread then
        WARN('Missing EngineerData or PlatoonThread for CAIEngineerBuilderBlueprint definition: ',arg[2].Name)
        return
    end
    
    if not CAIEngineerBuilders[arg[2].Name] then
        CAIEngineerBuilders[arg[2].Name] = {}
    end

    SPEW('CAIEngineerBuilder Registered: ', arg[2].Name)
    
    CAIEngineerBuilders[arg[2].Name] = arg[2]
    return arg[2].Name
end

setmetatable(CAIEngineerBuilderBlueprint, CAIEngineerBuilderBlueprintDefMeta)