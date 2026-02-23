--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--*******************************************************************
--*
--*  File     : /data/lua/SimPingGroup.lua
--*	 Author(s):
--*
--*  Summary  : Sim side PingGroup handling.
--*
--*  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*******************************************************************

local idNum = 1
local PingGroups = {}

--*******************************************************************
-- PING GROUP HANDLING:
--*******************************************************************

---------------------------------------------------------------------
-- Add a ping chicklet for the user to click on
-- This function returns an ID of the ping group for use if you need to delete it later.

-- callback    - function to be executed when the ping is issued by the user
-- name        - string that appears on the tooltip
-- blueprintID - used to create the unit icon
-- type        - type of ping, can be "move", "alert", or "attack"
---------------------------------------------------------------------
function AddPingGroup(name, blueprintID, type, description)
    local PingGroup = {
        _id = idNum,
        Name = name,
        Description = description,
        BlueprintID = blueprintID,
        Type = type,
        _callbacks = {},
        AddCallback = function(self, cb)
            table.insert(self._callbacks, cb)
        end,
        Destroy = function(self)
            if not Sync.RemovePingGroups then
                Sync.RemovePingGroups = {}
            end
            table.insert(Sync.RemovePingGroups, self._id)
            PingGroups[self._id] = nil
        end,
    }
    idNum = idNum + 1
    if not Sync.AddPingGroups then
        Sync.AddPingGroups = {}
    end
    table.insert(Sync.AddPingGroups, {ID = PingGroup._id, Name = name, BlueprintID = blueprintID, description = description, Type = type})
    PingGroups[PingGroup._id] = PingGroup
    return PingGroup
end

---------------------------------------------------------------------
function OnClickCallback(data)
    -- Check to make sure all of the pings are numbers (happens if the user clicks off the map somewhere)
    for i, v in data.Location do
        if v != v then
            return
        end
    end

    if PingGroups[data.ID] then
        for _, callback in PingGroups[data.ID]._callbacks do
            if callback then callback(data.Location) end
        end
    end
end

---------------------------------------------------------------------
function OnPostLoad()
    ForkThread(function()
        WaitSeconds(5)
        if not Sync.AddPingGroups then
            Sync.AddPingGroups = {}
        end
        for _, PingGroup in PingGroups do
            table.insert(Sync.AddPingGroups, {ID = PingGroup._id, Name = PingGroup.Name, BlueprintID = PingGroup.BlueprintID, Type = PingGroup.Type})
        end
    end)
end