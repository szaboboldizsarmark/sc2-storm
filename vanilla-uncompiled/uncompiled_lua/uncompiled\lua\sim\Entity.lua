--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     : /lua/sim/Entity.lua
--  Author(s): (unknown)
--  Summary  : The Entity lua module
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

Entity = Class(moho.entity_methods) {

	__init = function(self,spec)
		_c_CreateEntity(self,spec)
	end,

	__post_init = function(self,spec)
		self:OnCreate(spec)
	end,

	OnCreate = function(self,spec)
		self.Spec = spec
	end,

	OnDestroy = function(self)
	end,
}