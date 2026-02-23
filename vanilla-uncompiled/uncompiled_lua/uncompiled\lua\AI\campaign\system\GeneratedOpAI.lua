--***************************************************************************
--*
--**  File     :  /lua/ai/OpAI/GeneratedOpAI.lua
--**  Author(s): Dru Staltman
--**
--**  Summary  : Base manager for operations
----**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioPlatoonAI = import('/lua/ai/ScenarioPlatoonAI.lua')
local OpAI = import('/lua/ai/campaign/system/BaseOpAI.lua').OpAI

PlatoonGeneratedOpAI = Class(OpAI) {
    -- Set up variables local to this OpAI instance
    __init = function(self, brain, baseManager, platoon, name, builderData)
        -- Build an OpAI Blueprint
        local factoryBuilderName = self:BuildFactoryBuilderBlueprint(platoon, name)

        self:BuildOpAIBlueprint(factoryBuilderName, name)

        -- Make the base OpAI
        OpAI.__init(self, brain, baseManager, name, name, builderData)
    end,

    BuildFactoryBuilderBlueprint = function(self, platoon, name)
        local unitTable = {}
        local builderType = false

        for k,v in platoon:GetPlatoonUnits() do
            local unitId = v:GetUnitId()

            if not builderType then
                if EntityCategoryContains( categoreis.ENGINEER, v ) then
                    builderType = 'All'
                elseif EntityCategoryContains( categories.EXPERIMENTAL, v ) then
                    builderType = 'Gantry'
                elseif EntityCategoryContains( categories.LAND, v ) then
                    builderType = 'Land'
                elseif EntityCategoryContains( categories.AIR, v ) then
                    builderType = 'Air'
                elseif EntityCategoryContains( categories.NAVAL, v ) then
                    builderType = 'Sea'
                else
                    WARN('*AI WARNING: Could not get builder type for GenerateOpAI - UnitId = ' .. unitId)
                    builderType = 'Land'
                end
            end

            if not unitTable[unitId] then
                unitTable[unitId] = 0
            end

            unitTable[unitId] = unitTable[unitId] + 1
        end

        local platoonString = ''
        local platoonTable = {}
        for unitName,unitCount in unitTable do
            platoonString = platoonString .. unitName .. unitCount
            table.insert( platoonTable, { unitName, unitCount } )
        end

        if not CAIFactoryBuilders[platoonString] then
            CAIFactoryBuilderBlueprint {
                Name = platoonString,
                MasterName = name,
                Faction = 'All',
                BuilderType = builderType,
                Platoons = { platoonTable, },
                Priority = 500,
            }
        end

        --LOG(repr(CAIFactoryBuilders[platoonString]))

        return platoonString
    end,

    BuildOpAIBlueprint = function(self, factoryBuilderName, name)
        CAIOperationAIBlueprint {
            Name = name,
            FactoryBuilders = { factoryBuilderName, },
            ChildCount = 1,
            MaxActivePlatoons = 1,
        }
        --LOG(repr(OpAIBlueprints[name]))
    end,
}

TemplateGeneratedOpAI = Class(OpAI) {
    -- Set up variables local to this OpAI instance
    __init = function(self, brain, baseManager, platoonTemplate, name, builderData)
        -- Build an OpAI Blueprint
        local factoryBuilderName = self:BuildFactoryBuilderBlueprint(platoonTemplate, name)

        self:BuildOpAIBlueprint(factoryBuilderName, name)

        -- Make the base OpAI
        OpAI.__init(self, brain, baseManager, name, name, builderData)
    end,

    BuildFactoryBuilderBlueprint = function(self, platoonTemplate, name)
        local unitTable = {}
        local builderType = false

        for _,template in platoonTemplate[2] do
            local unitId = template[1]

            if not builderType then
                local typeChar = string.sub(unitId,3,3)
                if typeChar == 'x' then
                    builderType = 'Gantry'
                elseif typeChar == 'l' then
					if string.sub(unitId,3,7) == 'l0002' then
                        builderType = 'All'
                    else
                        builderType = 'Land'
                    end
                elseif typeChar == 'a' then
                    builderType = 'Air'
                elseif typeChar == 's' then
                    builderType = 'Sea'
                else
                    WARN('*AI WARNING: Could not get builder type for GenerateOpAI - UnitId = ' .. unitId)
                    builderType = 'Land'
                end
            end

            if not unitTable[unitId] then
                unitTable[unitId] = 0
            end

            unitTable[unitId] = unitTable[unitId] + template[2]
        end

        local platoonString = platoonTemplate[1]
        local platoonTable = {}
        for unitName,unitCount in unitTable do
            if platoonString == '' then
                platoonString = platoonString .. unitName .. unitCount
            end
            table.insert( platoonTable, { unitName, unitCount } )
        end

        if not CAIFactoryBuilders[platoonString] then
            CAIFactoryBuilderBlueprint {
                Name = platoonString,
                MasterName = name,
                Faction = 'All',
                BuilderType = builderType,
                Platoons = { platoonTable, },
                Priority = 500,
            }
        end

        -- LOG(repr(CAIFactoryBuilders[platoonString]))

        return platoonString
    end,

    BuildOpAIBlueprint = function(self, factoryBuilderName, name)
        CAIOperationAIBlueprint {
            Name = name,
            FactoryBuilders = { factoryBuilderName, },
            ChildCount = 1,
            MaxActivePlatoons = 1,
        }
        -- LOG(repr(OpAIBlueprints[name]))
    end,
}

GroupGeneratedOpAI = Class(OpAI) {
    -- Set up variables local to this OpAI instance
    __init = function(self, brain, baseManager, armyName, groupName, name, builderData)
        -- Build an OpAI Blueprint
        local factoryBuilderName = self:BuildFactoryBuilderBlueprint(armyName, groupName, name)

        self:BuildOpAIBlueprint(factoryBuilderName, name)

        -- Make the base OpAI
        OpAI.__init(self, brain, baseManager, name, name, builderData)
    end,

    BuildFactoryBuilderBlueprint = function(self, armyName, groupName, name)
        local unitTable = {}
        local builderType = false

        local unitsTable = ScenarioUtils.FlattenTreeGroup( armyName, groupName )

        for k,v in unitsTable do
            local unitId = v.type

            if not builderType then
                local typeChar = string.sub(unitId,3,3)
                if typeChar == 'x' then
                    builderType = 'Gantry'
                elseif typeChar == 'l' then
                    if string.sub(unitId,3,7) == 'l0002' then
                        builderType = 'All'
                    else
                        builderType = 'Land'
                    end
                elseif typeChar == 'a' then
                    builderType = 'Air'
                elseif typeChar == 's' then
                    builderType = 'Sea'
                else
                    WARN('*AI WARNING: Could not get builder type for GenerateOpAI - UnitId = ' .. unitId)
                    builderType = 'Land'
                end
            end

            if not unitTable[unitId] then
                unitTable[unitId] = 0
            end

            unitTable[unitId] = unitTable[unitId] + 1
        end

        local platoonString = groupName
        local platoonTable = {}
        for unitName,unitCount in unitTable do
            table.insert( platoonTable, { unitName, unitCount } )
        end

        if not CAIFactoryBuilders[platoonString] then
            CAIFactoryBuilderBlueprint {
                Name = platoonString,
                MasterName = name,
                Faction = 'All',
                BuilderType = builderType,
                Platoons = { platoonTable, },
                Priority = 500,
            }
        end

        --LOG(repr(CAIFactoryBuilders[platoonString]))

        return platoonString
    end,

    BuildOpAIBlueprint = function(self, factoryBuilderName, name)
        CAIOperationAIBlueprint {
            Name = name,
            FactoryBuilders = { factoryBuilderName, },
            ChildCount = 1,
            MaxActivePlatoons = 1,
        }
        -- LOG(repr(OpAIBlueprints[name]))
    end,
}