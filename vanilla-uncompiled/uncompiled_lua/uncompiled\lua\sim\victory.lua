--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

function CheckVictory(scenarioInfo)

    local categoryCheck = nil
    if scenarioInfo.Options.Victory == 'demoralization' then
        -- You're dead if you have no commanders or escape pods
        categoryCheck = categories.COMMAND + categories.ESCAPEPOD
    elseif scenarioInfo.Options.Victory == 'domination' then
        -- You're dead if all structures and engineers are destroyed
        categoryCheck = categories.STRUCTURE + categories.ENGINEER - categories.WALL - categories.EXPERIMENTALFACTORY
    elseif scenarioInfo.Options.Victory == 'eradication' then
        -- You're dead if you have no units
        categoryCheck = categories.ALLUNITS - categories.WALL
    else
        -- no victory condition
        return
    end

    -- tick number we are going to issue a victory on.  Or nil if we are not.
    local victoryTime = nil
    local potentialWinners = {}

    while true do

        -- Look for newly defeated brains and tell them they're dead
        local stillAlive = {}
        local defeatedThisPass = {}

        for index,brain in ArmyBrains do
            if not brain:IsDefeated() and not ArmyIsCivilian(brain:GetArmyIndex()) then
                if brain:GetCurrentUnits(categoryCheck) == 0 then
                    table.insert(defeatedThisPass, brain)
                else
                    table.insert(stillAlive, brain)
                end
            end
        end

		--Anyone left?
        if table.empty(stillAlive) then
			if not table.empty(defeatedThisPass) then
				--promote someone to 'mostly dead'
				local size = table.getn(defeatedThisPass)
				local brain = table.remove(defeatedThisPass, Random(1, size))
				table.insert(stillAlive, brain)
			else
				CallEndGame(true, false)
				return
			end
        end

        --Tell the dead people they're dead
        for index,brain in defeatedThisPass do
            brain:OnDefeat()
			if brain:GetArmyIndex() == GetFocusArmy() then
				SubmitEliminatedArmyStats()
			end

            CallEndGame(false, true)
		end

        -- check to see if everyone still alive is allied and is requesting an allied victory.
        local win = true
        local draw = true
        for index,brain in stillAlive do
            for index2,other in stillAlive do
                if index != index2 then
                    if not brain.RequestingAlliedVictory or not IsAlly(brain:GetArmyIndex(), other:GetArmyIndex()) then
                        win = false
                    end
                end
            end
            if not brain.OfferingDraw then
                draw = false
            end
        end

        if win then
            if table.equal(stillAlive, potentialWinners) then
                if GetGameTimeSeconds() > victoryTime then
                    CallEndGame(true, true)
                    return
                end
            else
				-- It's a win!
				for index,brain in stillAlive do
					brain:OnVictory()
				end
				LOG('VICTORY: about to submit victory army stats - case: Its a win')
				SubmitVictoryArmyStats()
                victoryTime = GetGameTimeSeconds() + 15
                potentialWinners = stillAlive
            end
        elseif draw then
            for index,brain in stillAlive do
                brain:OnDraw()
            end
            CallEndGame(true, true)
            return
        else
            victoryTime = nil
            potentialWinners = {}
        end

        WaitSeconds(0.1)
    end
end

function CallEndGame(callEndGame, submitXMLStats)
    if submitXMLStats then
        SubmitXMLArmyStats()
    end
    if callEndGame then
        gameOver = true
        EndGame()
    end
end

gameOver = false
