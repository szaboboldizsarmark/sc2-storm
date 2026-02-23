-----------------------------------------------------------------------------
--  File     : /lua/sim/wreckage.lua
--  Author(s): Gordon Duclos
--  Summary  : Wreckage module
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop

Wreckage = Class(Prop) {

    OnCreate = function(self)
        Prop.OnCreate(self)
		self.DecayTime = 0 
		self.DestroyThreadId = nil
    end,

	SetDecayTime = function(self, time)
		self.DecayTime = time
	end,

	StartDecay = function(self, decayTime)
		if decayTime then
			self.DecayTime = decayTime
		end

		if not ScenarioInfo.PropDecayDisabled and self.DecayTime and self.DecayTime > 0 then
			self.DestroyThreadId = ForkThread( self.DestroyThread, self )
		end
	end,

	DestroyThread = function(self)
		WaitSeconds( self.DecayTime )
		self:Destroy()
	end,

    OnDestroy = function(self)
		if self.DestroyThreadId then
			KillThread( self.DestroyThreadId )
		end
		Prop.OnDestroy(self)
    end,
}