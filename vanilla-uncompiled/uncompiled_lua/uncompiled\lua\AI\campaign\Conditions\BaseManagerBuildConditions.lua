--****************************************************************************
--**
--**  File     :  /lua/sim/ai/campaign/conditions/BaseManagerBuildConditions.lua
--**
--**  Summary  : Build conditions specific to teh campaign AI base manager
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utils = import('/lua/system/utilities.lua')


CAIConditionBlueprint {
    Name = 'BaseManagerNeedsEngineerBuilt',
    InstantCondition = true,
    Function = function(self, brain, locationName, unitId)
        local bManager = brain.CampaignAISystem.BaseManagers[locationName]
        return bManager:NeedsEngineerBuilt(unitId)
    end,
}

CAIConditionBlueprint {
    Name = 'BaseManagerNeedsEngineer',
    InstantCondition = true,
    Function = function(self, brain, locationName, unitId)
        local bManager = brain.CampaignAISystem.BaseManagers[locationName]
        return bManager:NeedsEngineer(unitId)
    end,
}

