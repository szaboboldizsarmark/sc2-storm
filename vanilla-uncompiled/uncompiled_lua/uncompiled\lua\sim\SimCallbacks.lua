--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--
--
-- This module contains the Sim-side lua functions that can be invoked
-- from the user side.  These need to validate all arguments against
-- cheats and exploits.
--

-- We store the callbacks in a sub-table (instead of directly in the
-- module) so that we don't include any

local Callbacks = {}

function DoCallback(name, data, units)
    local fn = Callbacks[name];
    if fn then
        fn(data, units)
    else
        error('No callback named ' .. repr(name))
    end
end



local SimUtils = import('/lua/sim/SimUtils.lua')
local SimPing = import('/lua/sim/SimPing.lua')
local SimTriggers = import('/lua/sim/scenariotriggers.lua')

Callbacks.BreakAlliance = SimUtils.BreakAlliance

Callbacks.GiveUnitsToPlayer = SimUtils.GiveUnitsToPlayer

Callbacks.GiveResourcesToPlayer = SimUtils.GiveResourcesToPlayer

Callbacks.SetResourceSharing = SimUtils.SetResourceSharing

Callbacks.RequestAlliedVictory = SimUtils.RequestAlliedVictory

Callbacks.SetOfferDraw = SimUtils.SetOfferDraw

Callbacks.SpawnPing = SimPing.SpawnPing

Callbacks.UpdateMarker = SimPing.UpdateMarker

Callbacks.ToggleSelfDestruct = import('/lua/sim/selfdestruct.lua').ToggleSelfDestruct

Callbacks.MarkerOnScreen = import('/lua/sim/simcameramarkers.lua').MarkerOnScreen

Callbacks.SimDialogueButtonPress = import('/lua/sim/SimDialogue.lua').OnButtonPress

Callbacks.DiplomacyHandler = import('/lua/sim/SimDiplomacy.lua').DiplomacyHandler

function Callbacks.OnMovieFinished(name)
    ScenarioInfo.DialogueFinished[name] = true
end

function Callbacks.OnCloseCustomUIScene(sceneName)
    ScenarioInfo.ClosedCustomUIScene = true
end

---NOTE: updated to support both the tutorial and situations where we want to allow these callbacks - bfricks 11/1/09
Callbacks.OnUnitsSelected = function(units)
    if units and (ScenarioInfo.tutorial or ScenarioInfo.OnSelectCallbacksAllowed) then
        local entities = {}
        for k,v in units do
            table.insert(entities, GetEntityById(v))
        end

        for k,v in entities do
            v.Callbacks.OnSelected:Call(v)
        end
    end
end

Callbacks.OnControlGroupAssign = function(units)
    if ScenarioInfo.tutorial then
        local function OnUnitKilled(unit)
            if ScenarioInfo.ControlGroupUnits then
                for i,v in ScenarioInfo.ControlGroupUnits do
                   if unit == v then
                        table.remove(ScenarioInfo.ControlGroupUnits, i)
                   end
                end
            end
        end


        if not ScenarioInfo.ControlGroupUnits then
            ScenarioInfo.ControlGroupUnits = {}
        end

        -- add units to list
        local entities = {}
        for k,v in units do
            table.insert(entities, GetEntityById(v))
        end
        ScenarioInfo.ControlGroupUnits = table.merged(ScenarioInfo.ControlGroupUnits, entities)

        -- remove units on any method of destruction
        ---NOTE: updated to a destroyed trigger - which handles death, reclaim, and capture - bfricks 11/14/09
        for k,v in entities do
            SimTriggers.CreateUnitDestroyedTrigger(OnUnitKilled, v)
        end
    end
end

Callbacks.OnControlGroupApply = function(units)
    --LOG(repr(units))
end

local SimCamera = import('/lua/sim/SimCamera.lua')

Callbacks.OnCameraFinish = SimCamera.OnCameraFinish




local SimPlayerQuery = import('/lua/sim/SimPlayerQuery.lua')

Callbacks.OnPlayerQuery = SimPlayerQuery.OnPlayerQuery

Callbacks.OnPlayerQueryResult = SimPlayerQuery.OnPlayerQueryResult

Callbacks.PingGroupClick = import('/lua/sim/SimPingGroup.lua').OnClickCallback

Callbacks.StopVictoryCheck = import('/lua/sim/victory.lua').StopVictoryCheck