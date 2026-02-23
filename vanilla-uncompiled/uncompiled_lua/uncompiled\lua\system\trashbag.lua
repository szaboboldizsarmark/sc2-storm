-----------------------------------------------------------------------------
-- File     : /lua/system/trashbag.lua
-- Author(s): Gordon Duclos
-- Summary  : TrashBag is a class to help manage objects that need destruction. You add objects to it with Add().
--			  When TrashBag:Destroy() is called, it calls Destroy() in turn on all its contained objects.
--            If an object in a TrashBag is destroyed through other means, it automatically disappears from the TrashBag.
--            This doesn't necessarily happen instantly, so it's possible in this case that Destroy() will be called twice.
--            So Destroy() should always be idempotent.
-- Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local getn = table.getn
local getsize = table.getsize

TrashBag = Class {
    
    __init = function(self)
		self._trash = { __mode = 'v',}
    end,

    -- Add an object to the TrashBag.
    Add = function(self, obj)
        if obj == nil then 
			return 
        end

        assert( obj.Destroy, 'Attempted to add an object with no Destroy() method to a TrashBag' )
        
        local i = getn(self._trash)+1
        self._trash[i] = obj
    end,

    -- Call Destroy() for all objects in this bag.
    Destroy = function(self)
        -- Destroy requires and indexed ordered table to insure syncronization between systems.

        local size = getsize(self._trash)
        for i = 1, size do
			local obj = self._trash[i]
			if obj then
				obj:Destroy()
				self._trash[i] = nil
			end
        end   
    end
}