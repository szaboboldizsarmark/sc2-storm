local ScenarioFramework = import('/lua/sim/ScenarioFramework.lua')

-- CategoryHunter
    -- Sends out units to hunt and attack Experimental Air units (Soul Ripper, Czar, etc)
    -- It cheats to find the air units.  This should *NOT* ever be used in skirmish.
    -- This platoon only seeks out PLAYER experimentals.  It will never find any other army's

-- PlatoonData = {
--   CategoryList = { categories }, -- The categories we are going to find and attack
--   CenterPoint = Position, -- OPTIONAL: if set, the platoon will attack the target closest to this point
--   PatrolChain = Chain, -- OPTIONAL: If set, the platoon will patrol this chain if no targets found
-- }

CAIPlatoonThreadBlueprint {
    Name = 'CategoryHunter',
    Function = function(platoon, data)
        local aiBrain = platoon:GetBrain()
        local platoonUnits = platoon:GetPlatoonUnits()
        local target = false
        local targetBrainIndex = platoon.OpAI.TargetBrain

        if data.Announce then
            LOG('*AI DEBUG: OpAI = ' .. platoon.PlatoonData.PlatoonName .. ' - Using CategoryHunter platoon thread' )
        end

        while aiBrain:PlatoonExists(platoon) do

            -- Find nearest enemy category to this platoon
            -- Cheat to find the focus army's units
            local newTarget = false
            local platPos = data.CenterPoint or platoon:GetPlatoonPosition()
            for catNum,category in data.CategoryList do
                local unitList = ArmyBrains[targetBrainIndex]:GetListOfUnits( category, false, false )
                if table.empty(unitList) then
                    continue
                end

                local sortedList = SortEntitiesByDistanceXZ(platPos, unitList)
            
                -- If the target has changed, attack new target
                if sortedList[1] and sortedList[1] != target then
                    newTarget = sortedList[1]
                    platoon:Stop()
                    platoon:AttackTarget( newTarget )
                end

                if newTarget then
                    break
                end
            end

            -- If there are no targets, seek out and fight nearest enemy the platoon can find; no cheeting here
            if not newTarget then
                if data.PatrolChain then
                    ScenarioFramework.PlatoonPatrolChain(platoon, data.PatrolChain)
                else
                    target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS-categories.WALL)
                    if target and not target:IsDead() then
                        platoon:Stop()
                        platoon:AggressiveMoveToLocation( target:GetPosition() )

                    -- If we still cant find a target, go to the highest threat position on the map
                    else
                        platoon:Stop()
                        platoon:AggressiveMoveToLocation( aiBrain:GetHighestThreatPosition(1, true) )
                    end
                end
            end
            WaitSeconds(Random(73,181) * .1)
        end
    end,
}
