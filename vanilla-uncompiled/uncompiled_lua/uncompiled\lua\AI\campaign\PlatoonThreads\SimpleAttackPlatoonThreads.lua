local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-- HuntAI - This thread tells the platoon to attack the nearest enemy it can attack

CAIPlatoonThreadBlueprint {
    Name = 'HuntAI',
    Function = function(platoon, data)
        platoon:SetAIPlan( 'HuntAI' )
    end,
}

-- PatrolRandomRoute - This thread randomly chooses a chain from a table and tells the platoon to patrol it
-- Data = {
--   PatrolChains = { Table of chain string names },
--   AnnounceRoute = bool, -- if set it will announce which attack route the attack is on
-- }

CAIPlatoonThreadBlueprint {
    Name = 'PatrolRandomRoute',
    Function = function(platoon, data)
        if not data.PatrolChains then
            if platoon.OpAIName then
                WARN('*CAMPAIGN AI ERROR: Missing PatrolChains for platoon using PatrolRandomRoute - OpAIName = ' .. platoon.OpAIName)
                return
            else
                WARN('*CAMPAIGN AI ERROR: Missing PatrolChains for platoon using PatrolRandomRoute')
                return
            end
        end

        if not data.PatrolChains or type(data.PatrolChains) != 'table' then
            if platoon.OpAIName then
                WARN('*CAMPAIGN AI ERROR: PatrolChains in PlatoonThread "PatrolRandomRoute" must be a table - OpAIName = ' .. platoon.OpAIName)
                return
            else
                WARN('*CAMPAIGN AI ERROR: PatrolChains in PlatoonThread "PatrolRandomRoute" must be a table')
                return
            end
        end

        local chainName = data.PatrolChains[ Random( 1, table.getn(data.PatrolChains) ) ]

        if not chainName or not Scenario.Chains[chainName] then
            if platoon.OpAIName then
                WARN('*CAMPAIGN AI ERROR: Invalid PatrolChains for platoon using PatrolRandomRoute - OpAIName = ' .. platoon.OpAIName)
                return
            else
                WARN('*CAMPAIGN AI ERROR: Invalid PatrolChains for platoon using PatrolRandomRoute')
                return
            end
            return
        end

        local route = ScenarioUtils.ChainToPositions(chainName)

        if data.AnnounceRoute then
            LOG('*AI DEBUG: OpAI = ' .. platoon.PlatoonData.PlatoonName .. ' - Attacking on route - ' .. chainName)
        end

        for k,v in route do
            platoon:Patrol(v)
        end
    end,
}

-- PatrolRandomizedPoints - This thread gives each unit in the platoon a random route from the points in a given chain
-- Data = {
--   PatrolChain = string, -- Name of the chain to use
--   AnnounceRoute = bool, -- if set it will announce which attack route the attack is on
-- }

CAIPlatoonThreadBlueprint {
    Name = 'PatrolRandomizedPoints',
    Function = function(platoon, data)
        local chainName = data.PatrolChain

        if not chainName or not Scenario.Chains[chainName] then
            if platoon.OpAIName then
                WARN('*CAMPAIGN AI ERROR: Invalid PatrolChain for platoon using PatrolRandomizedPoints - OpAIName = ' .. platoon.OpAIName)
            else
                WARN('*CAMPAIGN AI ERROR: Invalid PatrolChain for platoon using PatrolRandomizedPoints')
            end
            return
        end

        local points = ScenarioUtils.ChainToPositions(chainName)

        local numPoints = table.getn(points)

        for _,unit in platoon:GetPlatoonUnits() do
            local remainingPoints = {}
            for i=1,numPoints do
                remainingPoints[i] = i
            end

            local route = {}
            while not table.empty(remainingPoints) do
                local index = Random( 1, table.getn(remainingPoints) )
                table.insert( route, points[index] )
                table.remove( remainingPoints, index )
            end

            --if data.AnnounceRoute then
            --    LOG('*AI DEBUG: OpAI = ' .. platoon.PlatoonData.PlatoonName .. ' - Attacking on route - ' .. chainName)
            --end

            for k,v in route do
                IssuePatrol( {unit}, v )
            end
        end
    end,
}

-- MoveAlongChain - This thread tells teh platoon to move along all points on the chain
-- Data = {
--   MoveChain = 'ChainName',
--   AnnounceMove = bool, -- Announces when the platoon behavior starts
-- }

CAIPlatoonThreadBlueprint {
    Name = 'MoveAlongChain',
    Function = function(platoon, data)
        local chainName = data.MoveChain

        if not chainName or not Scenario.Chains[chainName] then
            if platoon.OpAIName then
                WARN('*CAMPAIGN AI ERROR: Invalid MoveChain for platoon using MoveAlongChain - OpAIName = ' .. platoon.OpAIName)
            else
                WARN('*CAMPAIGN AI ERROR: Invalid MoveChain for platoon using MoveAlongChain')
            end
            return
        end

        local route = ScenarioUtils.ChainToPositions(chainName)

        if data.AnnounceMove then
            LOG('*AI DEBUG: OpAI = ' .. platoon.PlatoonData.PlatoonName .. ' - Moving on route - ' .. chainName)
        end

        for k,v in route do
            platoon:MoveToLocation(v, false)
        end
    end,
}

