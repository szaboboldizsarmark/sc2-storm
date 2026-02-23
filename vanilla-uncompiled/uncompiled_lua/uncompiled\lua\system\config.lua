--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--
-- Configuration file to globally control how Lua behaves

--====================================================================================
-- Disable the LuaPlus bit where you can add attributes to nil, numbers, and strings.
--------------------------------------------------------------------------------------

local LuaVersion = _VERSION

local function metacleanup(obj)
    local name = type(obj)
    mmt = {
        __newindex = function(table,key,value)
            error(string.format("Attempt to set attribute '%s' on %s", tostring(key), name), 2)
        end,
        --__index = function(table,key)
        --    error(string.format("Attempt to get attribute '%s' on %s", tostring(key), name), 2)
        --end
    }
    if LuaVersion == "Lua 5.0.1" then
		setmetatable(getmetatable(obj), mmt)
	else
		debug.setmetatable(obj, mmt)
	end
end

metacleanup(nil)
metacleanup(0)
metacleanup('')


--====================================================================================
-- Set up a metatable for coroutines (a.k.a. threads)
--------------------------------------------------------------------------------------
local thread_mt = {Destroy = KillThread}
thread_mt.__index = thread_mt
function thread_mt.__newindex(table,key,value)
    error('Attempt to set an attribute on a thread',2)
end
local function dummy() end
if LuaVersion == "Lua 5.0.1" then
	setmetatable(getmetatable(coroutine.create(dummy)),thread_mt)
else
	debug.setmetatable(coroutine.create(dummy),thread_mt)
end


--====================================================================================
-- Replace math.random with our custom random.  On the sim side, this is
-- a rng with consistent state across all clients.
--------------------------------------------------------------------------------------
if Random then
    math.random = Random
end


--====================================================================================
-- Give globals an __index() with an error function. This causes an error message
-- when a nonexistent global is accessed, instead of just quietly returning nil.
--------------------------------------------------------------------------------------
local globalsmeta = {
    __index = function(table, key)
        -- No error here because we don't care!  
        -- (The prefetcherscenarios is a global table that may not have certain keys)
    end
}
setmetatable(_G, globalsmeta)


--====================================================================================
-- Check if an item is callable, ie not a variable. Returns the callable item,
-- otherwise returns nil
--------------------------------------------------------------------------------------
function iscallable(f)
    local tt = type(f)
    if tt == 'function' or tt == 'cfunction' then
        return f
    end
    if tt == 'table' and getmetatable(f).__call then
        return f
    end
end
