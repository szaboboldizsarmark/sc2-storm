--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- Author: Bob Berry
--
-- This file is the SIM side of the query system. See the documentation in
-- /lua/UserPlayerQuery.lua for details on the QUERY facility.
--
--------------------------------------------------------------------------------

-- Listeners interested in specific incoming queries (the query itself, not the
-- result)
local QueryListeners = {}

-- Listeners interested in specific query results
local ResultListeners = {}

-- Listen to incoming query requests of the given name (not the results, the
-- query itself as it comes in). listener is a function called when a query
-- with a matching name comes in.
function AddQueryListener( queryName, listener )
    table.insert( QueryListeners, { Name=queryName, Listener=listener } )
end

-- Listen to a particular query result. listener is a function called when
-- a query with a matching name has produced a result.
function AddResultListener( queryName, listener )
    table.insert( ResultListeners, { Name=queryName, Listener=listener } )
end

-- Called by the engine whenever a new query between two players is requested.
-- All players receive all query traffic.
function OnPlayerQuery( queryData )
    queryData.FromCommandSource = GetCurrentCommandSource()
    for k,v in QueryListeners do
        if v.Name == queryData.Name then
            v.Listener(queryData)
        end
    end
    
    CreateSimSyncPlayerQuery( queryData )
end

-- Called by the engine whenever a query result has been sent. All players
-- receive the result.
function OnPlayerQueryResult( resultData )
    resultData.FromCommandSource = GetCurrentCommandSource()
    for k,v in ResultListeners do
        if v.Name == resultData.Name then
            v.Listener(resultData)
        end
    end

	CreateSimSyncPlayerQueryResults( resultData )
end