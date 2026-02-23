--****************************************************************************
--**
--**  File     :  /lua/AI/campaign/system/AIUnitManager.lua
--**  Author(s):
--**
--**  Summary  :
--**
--**  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local BuilderManager = import('/lua/ai/BuilderManager.lua').BuilderManager
local AIUtils = import('/lua/ai/aiutilities.lua')
local Builder = import('/lua/ai/campaign/system/Builder.lua')

AIUnitManager = Class(BuilderManager) {
    __init = function(self, brain, lType, location, radius)
        BuilderManager.__init(self,brain)

        if not lType or not location or not radius then
            error('*PLATOOM FORM MANAGER ERROR: Invalid parameters; requires locationType, location, and radius')
            return false
        end
        
        self.Location = location
        self.Radius = radius
        self.LocationType = lType

        self.Units = {}
        
        self:AddBuilderType('Land')
        self:AddBuilderType('Sea')
        self:AddBuilderType('Air')
    end,

    AddUnit = function(self, builder, unit)
        -- LOG('*AI DEBUG: Adding unit to AIUnitManager')
        table.insert( self.Units, unit )
    end,

    RemoveUnits = function(self, units)
        for k,v in units do
            for index,u in self.Units do
                if v == u then
                    table.remove( self.Units, index )
                end
            end
        end
    end,
}