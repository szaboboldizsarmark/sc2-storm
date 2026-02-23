--****************************************************************************
--**
--**  File     :  /lua/ArmyBonusBlueprints.lua
--**
--**  Summary  :  Global Army Bonus table and blueprint methods
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

-- Global list of all abilities found in the system.
ArmyBonuses = {}

-- ArmyBonus blueprints are created by invoking ArmyBonusBlueprint() with a table
-- as the bonus data. Bonuses can be defined in any module at any time.
-- e.g.
--
-- ArmyBonusBlueprint {
--    Name = SoldierBonus,
--    DisplayName = 'This Bonus benefits soldiers',
--    [...]
--    Buffs = {
--        'SoldierBuff01',
--        'SoldierBuff02',
--    },
--    Abilities = {
--        'SoldierAbility01',
--        'SoldierAbility02',
--    },
--    ApplyArmies = <Single|Team>,
--    UnitCategory = 'MOBILE GRUNT',
--    RemoveOnUnitDeath = false, -- defaults to false/nil
-- }
ArmyBonusBlueprint = {}
ArmyBonusDefMeta = {}

ArmyBonusDefMeta.__index = ArmyBonusDefMeta
ArmyBonusDefMeta.__call = function(...)

    local a = arg[2]
    
    if type(a) ~= 'table' then
        LOG('Invalid ArmyBonusDefinition: ', repr(arg))
        return
    end
    
    if not a.Name then
        LOG('Missing name for ArmyBonus definition: ',repr(arg))
        return
    end

    if not a.Buffs and not a.Abilities and not a.OnApplyBonus then
        WARN('Missing Buffs or Abilities or OnApplyBonus in ArmyBonus = ' .. a.Name)
        return
    end

    if not a.ApplyArmies then
        WARN('Missing ApplyArmies in ArmyBonus = ' .. a.Name)
        return
    end
    
    if InitialRegistration and ArmyBonuses[a.Name] then
        WARN('Duplicate ArmyBonus detected: ', a.Name)
    end

    if not ArmyBonuses[a.Name] then
        ArmyBonuses[a.Name] = {}
    end

    --SPEW('ArmyBonus Registered: ', a.Name)

    ArmyBonuses[a.Name] = arg[2]

    if not arg[2].UnitCategory and (a.Buffs or a.Abilities) then
        ArmyBonuses[a.Name].UnitCategory = 'ALLUNITS'
    end

    return arg[2].Name
end

setmetatable(ArmyBonusBlueprint, ArmyBonusDefMeta)
