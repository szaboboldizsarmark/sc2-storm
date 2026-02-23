--****************************************************************************
--**
--**  File     :  /lua/AI/AIEconomyUtilities.lua
--**
--**  Summary  :
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BuildingTemplates = import('/lua/ai/BuildingTemplates.lua').BuildingTemplates
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utils = import('/lua/system/utilities.lua')
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
local AIUtils = import('/lua/AI/AIUtilities.lua')

function GetEconomyStorage(aiBrain)
    local econ = {}
    econ.EnergyStorage = aiBrain:GetEconomyStored('ENERGY')
    econ.MassStorage = aiBrain:GetEconomyStored('MASS')
    return econ
end

function GetUnitEconomyCost(unitId)
    local unitBp = GetUnitBlueprintByName(unitId)

    if not unitBp.Economy.MassValue or not unitBp.Economy.EnergyValue then
        WARN('*AI WARNING: Unit does not have MassValue or EnergyValue - using 5000; unitId = ' .. unitId)
    end

    return {
        Mass = unitBp.Economy.MassValue or 5000,
        Energy = unitBp.Economy.EnergyValue or 5000,
    }    
end

function GetFactoryOutputCost(unitId)
    -- Build a list of all units buildable by the factory

    -- Figure out the level of cost based on these units
        -- The desire of each unit based on current world

    -- Return the highest cost unit built from the factory
end