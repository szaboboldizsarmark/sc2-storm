--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

local Entity = import('/lua/sim/Entity.lua').Entity

ObjectiveDirectionArrow = Class(Entity) {

    OnCreate = function(self,spec)
		self.Trash = TrashBag()

		self:SetPosition( spec.position, true )
		self:SetOrientation( spec.orientation, true )

		self.mDefaultMesh = spec.objectiveArrowMeshName or "/meshes/game/objective_arrow_mesh"
		self:SetMesh(self.mDefaultMesh)
		self:SetDrawScale( self:GetMeshBlueprint().UniformScale or 1 )
        local unitScale = 1.0
		self.mActive = true
		self:Deactivate()
    end,


    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,

	Activate = function( self, blinkTime, blinkRate )
		if self.mActive then return end
		self.mActive = true
		self:SetMesh(self.mDefaultMesh)

		if not self.mBlinkThread then
			self.mBlinkThread = self:ForkThread( self.LBlink, blinkTime, blinkRate  )
		end
	end,

	Deactivate = function( self )
		if not self.mActive then return end
		self.mActive = false
		if self.mBlinkThread then
			KillThread( self.mBlinkThread )
			self.mBlinkThread = nil
		end
		self:SetMesh("")
	end,

	LBlink = function( self, totalTime, rate )
		local on = not self.mActive
		while self.mActive and totalTime > 0 do
			on = not on
			if on then self:SetMesh( self.mDefaultMesh ) else self:SetMesh("") end
			WaitSeconds( rate )
			totalTime = totalTime - rate
		end

		self:Deactivate()
	end,
}
