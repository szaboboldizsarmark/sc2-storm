local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

CAIPlatoonThreadBlueprint {
    Name = 'MoveTeleportPatrolThread',
    Function = function(platoon, data)
        local platoonCmd = false
        local aiBrain = platoon:GetBrain()

        if not data.TeleportPos then
            WARNING('*CAMPAIGN AI: MoveTeleportPatrolThread requires a TeleportPos in passed in data')
            return
        end

        local chain = {}
        if data.StartChain then
            chain = ScenarioUtils.ChainToPositions( data.StartChain )
        elseif data.StartPos then
            chain = { ScenarioUtils.MarkerToPosition( data.StartPos ) }
        end

        for k,v in chain do
            if not data.MoveAggressive then
                platoonCmd = platoon:MoveToLocation( v, false )
            else
                platoonCmd = platoon:AggressiveMoveToLocation( v )
            end
        end

        -- TODO: Verify range based on teleportation range

        platoonCmd = platoon:Teleport( ScenarioUtils.MarkerToPosition(data.TeleportPos) )

        chain = {}
        if data.EndChain then
            chain = ScenarioUtils.ChainToPositions( data.EndChain )
        elseif data.EndPos then
            chain = { ScenarioUtils.MarkerToPosition(data.TeleportPos), ScenarioUtils.MarkerToPosition( data.EndPos ) }
        end

        for k,v in chain do
            platoonCmd = platoon:Patrol(v)
        end
    end
}
