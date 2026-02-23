--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--
-- General Sim scripts

--==============================================================================
-- Diplomacy
--==============================================================================

function BreakAlliance( data )

    -- You can't change alliances in a team game
    if ScenarioInfo.TeamGame then
        return
    end

    if OkayToMessWithArmy(data.From) then
        SetAlliance(data.From,data.To,"Enemy")

        if Sync.BrokenAlliances == nil then
            Sync.BrokenAlliances = {}
        end
        table.insert(Sync.BrokenAlliances, { From = data.From, To = data.To })
    end
    import('/lua/sim/SimPing.lua').OnAllianceChange()
end

function OnAllianceResult( resultData )
    -- You can't change alliances in a team game
    if ScenarioInfo.TeamGame then
        return
    end

    if OkayToMessWithArmy(resultData.From) then
        if resultData.ResultValue == "accept" then
            SetAlliance(resultData.From,resultData.To,"Ally")
            if Sync.FormedAlliances == nil then
                Sync.FormedAlliances = {}
            end
            table.insert(Sync.FormedAlliances, { From = resultData.From, To = resultData.To })
        end
    end
    import('/lua/sim/SimPing.lua').OnAllianceChange()
end
import('/lua/sim/SimPlayerQuery.lua').AddResultListener( "OfferAlliance", OnAllianceResult )

function GiveUnitsToPlayer( data, units )
    if units then
        local toBrain = GetArmyBrain(data.To)
        if toBrain:IsDefeated() then return end
        for k,v in units do
            local owner = v:GetArmy()
            if OkayToMessWithArmy(owner) and IsAlly(owner,data.To) and not GetArmyBrain(owner):IsDefeated() then

                -- Only allow units not attached to be given.
                -- This is because units will give all of it's children
                -- over as well, so we only want the top level units to be given.
                -- Also, don't allow commanders to be given.

                if v:GetParent() == v then
                    ChangeUnitArmy(v,data.To)
                end
            end
        end
    end
end

function GiveResourcesToPlayer( data )
    if not OkayToMessWithArmy(data.From) then return end
    local fromBrain = GetArmyBrain(data.From)
    local toBrain = GetArmyBrain(data.To)
    if fromBrain:IsDefeated() or toBrain:IsDefeated() then return end
    local massTaken = fromBrain:TakeResource('Mass',data.Mass * fromBrain:GetEconomyStored('Mass'))
    local energyTaken = fromBrain:TakeResource('Energy',data.Energy * fromBrain:GetEconomyStored('Energy'))
    toBrain:GiveResource('Mass',massTaken)
    toBrain:GiveResource('Energy',energyTaken)
end

function SetResourceSharing( data )
    if not OkayToMessWithArmy(data.Army) then return end
    local brain = GetArmyBrain(data.Army)
    brain:SetResourceSharing(data.Value)
end

function RequestAlliedVictory( data )
    -- You can't change this in a team game
    if ScenarioInfo.TeamGame then
        return
    end

    if not OkayToMessWithArmy(data.Army) then return end

    local brain = GetArmyBrain(data.Army)
    brain.RequestingAlliedVictory = data.Value
end

function SetOfferDraw(data)
    if not OkayToMessWithArmy(data.Army) then return end

    local brain = GetArmyBrain(data.Army)
    brain.OfferingDraw = data.Value
end


--==============================================================================
-- UNIT CAP
--==============================================================================
function UpdateUnitCap()
    -- If we are asked to share out unit cap for the defeated army, do the following...
    if not ScenarioInfo.Options.DoNotShareUnitCap then
        local aliveCount = 0
        for k,brain in ArmyBrains do
            if not brain:IsDefeated() then
                aliveCount = aliveCount + 1
            end
        end
        if aliveCount > 0 then
            local initialCap = tonumber(ScenarioInfo.Options.UnitCap)
            local totalCap = aliveCount * initialCap
            for k,brain in ArmyBrains do
                if not brain:IsDefeated() then
                    SetArmyUnitCap(brain:GetArmyIndex(),math.floor(totalCap / aliveCount))
                end
            end
        end
    end
end

