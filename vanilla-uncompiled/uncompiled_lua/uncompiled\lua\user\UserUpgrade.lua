--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--****************************************************************************
--**  File     :  /lua/upgrade.lua
--**  Author(s): Gordon Duclos
--**
--**  Summary  : Common upgrade functions, stores unit id upgrade map data
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local upgradeTable = {}

function GetUpgradeTable(entityID)
    return upgradeTable[tostring(entityID)]
end

function SetUpgradeTable(entry)
    upgradeTable = entry
end