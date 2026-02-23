-----------------------------------------------------------------------------
--  File     : /lua/selfdestruct.lua
--  Author(s): 
--  Summary  : Self destruct sim code
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

function ToggleSelfDestruct(data)
    -- supress self destruct in tutorial missions as they screw up the mission end
    if ScenarioInfo.tutorial and ScenarioInfo.tutorial == true then
        return
    end
    if data.owner != -1 then
        local unitEntities = {}
        for _, unitId in data.units do
            local unit = GetEntityById(unitId)
            if unit and not unit:IsDead() and OkayToMessWithArmy(unit:GetArmy()) and unit.CanTakeDamage then
                table.insert(unitEntities, unit)
            end
        end
        if table.getsize(unitEntities) > 0 then
            local togglingOff = false
            for _, unit in unitEntities do
                if unit.SelfDestructThread then
                    togglingOff = true
                    KillThread(unit.SelfDestructThread)
                    unit.SelfDestructThread = false
                    local entityId = unit:GetEntityId()
                    CancelCountdown(entityId)
                end
            end
            if not togglingOff then
                for _, unitEnt in unitEntities do
                    local unit = unitEnt
                    local entityId = unit:GetEntityId()
                    StartCountdown(entityId)
                    unit.SelfDestructThread = ForkThread(function()
						if not data.immediate then
							WaitSeconds(5)
						end
						if unit and not unit:IsDead() then
							unit:Kill()
						end
                    end)
                end
            end
        end
    end
end