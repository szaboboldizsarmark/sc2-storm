--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--*******************************************************************
-- Call Callback:Add(fun) to set a trigger function which is called when the
-- event is set. Arguments passed to the trigger function are the same as those
-- passed to Call(...)
-- You can add as many callbacks as you want.
--*******************************************************************

Callback = Class {

    ---------------------------------------------------------
    -- Init
    ---------------------------------------------------------
    __init = function(self)
        self.EventCallbacks = {}
        self.EventIsSet = false
        self.ManualReset = false
    end,

    ---------------------------------------------------------
    -- Add a function to be called when this event is set. If the event is already set,
    -- nothing happens.
    ---------------------------------------------------------
    Add = function(self, fn, cbObj, argTable)
        if not fn then
            return
        end
        table.insert(self.EventCallbacks, {Func = fn, Caller = cbObj, cbArgTable = argTable})
    end,

    ---------------------------------------------------------
    -- Remove a callback function.
    ---------------------------------------------------------
    Remove = function(self,fn)
        for k,cb in self.EventCallbacks do
            if cb.Func == fn then
                table.remove(self.EventCallbacks,k)
            end
        end
    end,

    ---------------------------------------------------------
    -- Set the event, calling all triggers waiting on it
    ---NOTE: we should take a look at the unpack being used here - Gautam indicated this was something he wants to replace - bfricks 3/11/2009 12:11PM
    ---------------------------------------------------------
    Call = function( self, ... )
        if not self.EventIsSet then
            self.EventIsSet = true

            for k, cb in self.EventCallbacks do
                if cb.Caller then
	            	if cb.cbArgTable then
                    	cb.Func(cb.Caller, cb.cbArgTable, unpack(arg))
                    else
                    	cb.Func(cb.Caller, unpack(arg))
	            	end
                else
	            	if cb.cbArgTable then
                    	cb.Func(cb.cbArgTable, unpack(arg))
	            	else
                    	cb.Func(unpack(arg))
                    end
                end
            end
        end

        if not self.ManualReset then
            self.EventIsSet = false
        end
    end,

    ---------------------------------------------------------
    -- Reset the event
    ---------------------------------------------------------
    Reset = function(self)
        --LOG('*DEBUG: ..EventReset..')
        self.EventIsSet = false
    end,

    ---------------------------------------------------------
    -- Clear all callbacks
    ---------------------------------------------------------
    Clear = function(self)
        self.EventCallbacks = {}
    end,

    ---------------------------------------------------------
    -- Destroy the event. Any triggers waiting for it are abandoned.
    -- We define 'Destroy' so we can stick this in a trashbag.
    ---------------------------------------------------------
    Destroy = function(self)
        self:Clear()
    end,
}