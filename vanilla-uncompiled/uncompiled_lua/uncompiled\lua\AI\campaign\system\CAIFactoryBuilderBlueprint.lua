--****************************************************************************
--**
--**  File     :  /lua/ai/campaign/system/CAIFactoryBuilderBlueprint.lua
--**
--**  Summary  :  Global buff table and blueprint methods
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- Global list of all buffs found in the system.
CAIFactoryBuilders = {}

-- Factory Builders are created by invoking CAIFactoryBuilderBlueprint() with a table
-- as the builder data. They can be defined in any module at any time.
-- e.g.
--
-- CAIFactoryBuilderBlueprint {
--    Name = 'Air Attack 1C',
--    MasterName = 'AirAttack',
--    Faction = 'UEF',
--    BuilderType = 'Air',
--    Platoons = {
--        {
--            { 'uul0101', 3 },
--        },
--        {
--            { 'uul0101', 1 },
--            { 'uul0102', 2 },
--        },
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
--    Priority = 900,
-- }
--
--
--
CAIFactoryBuilderBlueprint = {}
CAIFactoryBuilderBlueprintDefMeta = {}

CAIFactoryBuilderBlueprintDefMeta.__index = CAIFactoryBuilderBlueprintDefMeta
CAIFactoryBuilderBlueprintDefMeta.__call = function(...)
    
    if type(arg[2]) ~= 'table' then
        WARN('Invalid CAIFactoryBuilderBlueprint: ', repr(arg))
        return
    end
    
    if not arg[2].Name then
        WARN('Missing name for CAIFactoryBuilderBlueprint definition: ',repr(arg))
        return
    end
    
    if CAIFactoryBuilders[arg[2].Name] then
        WARN('Duplicate CAIFactoryBuilderBlueprint detected: ', arg[2].Name)
    end

    if not arg[2].Platoons then
        WARN('Missing Platoons for CAIFactoryBuilderBlueprint definition: ',arg[2].Name)
        return
    end
    
    if not arg[2].Priority then
        WARN('Missing Priority for CAIFactoryBuilderBlueprint definition: ',arg[2].Name)
        return
    end
    
    if not arg[2].BuilderType then
        WARN('Missing BuilderType for CAIFactoryBuilderBlueprint definition: ',arg[2].Name)
        return
    end
    
    if not CAIFactoryBuilders[arg[2].Name] then
        CAIFactoryBuilders[arg[2].Name] = {}
    end

    SPEW('CAIFactoryBuilder Registered: ', arg[2].Name)
    
    CAIFactoryBuilders[arg[2].Name] = arg[2]
    return arg[2].Name
end

setmetatable(CAIFactoryBuilderBlueprint, CAIFactoryBuilderBlueprintDefMeta)