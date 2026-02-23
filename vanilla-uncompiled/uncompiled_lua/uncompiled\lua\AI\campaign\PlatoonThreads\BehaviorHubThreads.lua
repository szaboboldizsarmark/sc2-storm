local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local HubData = {

    Patrol = {
        RequiredFields = { 'Chain' },
        Action = function(platoon, aiBrain, data)
            for k,v in ScenarioUtils.ChainToPositions(data.Chain) do
                platoon:Patrol(v)
            end
        end,
    },

    AggressiveMove = {
        RequiredFields = { 'Chain' },
        Action = function(platoon, aiBrain, data)
            local cmd = false
            for k,v in ScenarioUtils.ChainToPositions(data.Chain) do
                cmd = platoon:AggressiveMoveToLocation(v)
            end
            while platoon:IsCommandsActive(cmd) do
                WaitSeconds(1)
                if not aiBrain:PlatoonExists(platoon) then
                    return false
                end
            end
            return true
        end,
    },

    Move = {
        RequiredFields = { 'Chain' },
        Action = function(platoon, aiBrain, data)
            local cmd = false
            for k,v in ScenarioUtils.ChainToPositions(data.Chain) do
                cmd = platoon:MoveToLocation(v, false)
            end
            while platoon:IsCommandsActive(cmd) do
                WaitSeconds(1)
                if not aiBrain:PlatoonExists(platoon) then
                    return false
                end
            end
            return true
        end,
    },
    
    TeleportPlatoon = {
        RequiredFields = { 'TeleportMarkerName' },
        Action = function(platoon, aiBrain, data)
            local cmd = platoon:Teleport( ScenarioUtils.MarkerToPosition(data.TeleportMarkerName) )
            
            while platoon:IsCommandsActive(cmd) do
                WaitSeconds(1)
                if not aiBrain:PlatoonExists(platoon) then
                    return false
                end
            end
            return true
        end,
    },

    UseTeleporter = {
        RequiredFields = { 'TeleporterArmyIndex', 'TeleporterUnitName', },
        Action = function(platoon, aiBrain, data)
            local teleporterUnit = ScenarioInfo.UnitNames[data.TeleporterArmyIndex][data.TeleporterUnitName]
            if not teleporterUnit then
                for k,v in ArmyBrains do
                    teleporterUnit = ScenarioInfo.UnitNames[v:GetArmyIndex()][data.TeleporterUnitName]
                    if teleporterUnit then
                        break
                    end
                end
            end

            if not teleporterUnit then
                WARN('*CAMPAIGN AI ERROR: Could not find Teleporter unit or unit is dead - TeleporterUnitName = ' .. data.TeleporterUnitName
                    .. ' - TeleporterArmyIndex = ' .. data.TeleporterArmyIndex)
                return false
            end

            if teleporterUnit:IsDead() then
                return true
            end

            local cmd = platoon:UseTeleporter(teleporterUnit)

            while platoon:IsCommandsActive(cmd) do
                WaitSeconds(1)
                if not aiBrain:PlatoonExists(platoon) then
                    return false
                end
            end
            return true
        end,
    },

    Callback = {
        RequiredFields = { 'Function' },
        Action = function(platoon, aiBrain, data)
            data.Function(platoon, aiBrain, unpack(data.Parameters))
            return true
        end,
    },

}

function LoopingBehaviorCheck(behaviorName)
    if behaviorName == 'Patrol' then
        return true
    end
    return false
end

function BehaviorCheck(behaviorData)
    if not HubData[behaviorData.BehaviorName] then
        WARN('*AI ERROR: BehaviorName not found for PlatoonBehaviorHub - ' .. behaviorData.BehaviorName)
        return false
    end

    for _,fieldName in HubData[behaviorData.BehaviorName].RequiredFields do
        if not behaviorData[fieldName] then
            WARN('*AI ERROR: Missing field - ' .. behaviorData[fieldName] .. ' - for behavior - ' .. behaviorData.BehaviorName)
            return false
        end
    end

    return true
end

CAIPlatoonThreadBlueprint {
    Name = 'PlatoonBehaviorHub',
    Function = function(platoon, data)
        local aiBrain = platoon:GetBrain()

        if data.Announce then
            LOG('*CAMPAIGN AI DEBUG: Starting PlatoonBehaviorHub')
        end

        local loopStart = false
        for _,behavior in data.Behaviors do

            -- Make sure we have a name for this behavior
            if not behavior.BehaviorName then
                WARN('*AI ERROR: No BehaviorName for a behavior in PlatoonBehaviorHub - ' .. repr(data.Behaviors))
                return
            end

            -- Make sure all the data for this behavior is there
            if not BehaviorCheck(behavior) then
                return
            end

            if loopStart then
                WARN('*AI ERROR: A behavior is found in PlatoonBehaviorHub after a looping behavior; this operation will never run!')
                return
            end

            -- Check if this behavior loops; if it loops we want to error if another behavior is in queue
            loopStart = LoopingBehaviorCheck(behavior.BehaviorName)
        end

        for _,behavior in data.Behaviors do
            if data.Announce then
                LOG('*AI DEBUG: PlatoonBehaviorHub starting behavior named - ' .. behavior.BehaviorName)
            end

            if not HubData[behavior.BehaviorName].Action(platoon,aiBrain,behavior) then
                return
            end
        end
    end,
}

