-----------------------------------------------------------------------------
--  File     : /lua/sim/ExperimentalSeaUnit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Experimental Sea Unit
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local FAIL_CHANCE_INTERVAL = 5
local STUN_DURATION = 5

ExperimentalSeaUnit = Class(SeaUnit) {

	OnCreate = function(self)
		SeaUnit.OnCreate(self)		
		self.BuildScaffoldUnit = nil		
	end,
	
	GetBuildScaffoldUnit = function(self)
		return self.BuildScaffoldUnit
	end,
	
	OnStartBeingBuilt = function(self, builder, layer)
		SeaUnit.OnStartBeingBuilt(self, builder, layer)

		local bp = self:GetBlueprint()
		if bp.Build.BuildScaffoldUnit then
			local x, y, z = unpack(self:GetPosition())
			local qx, qy, qz, qw = unpack(self:GetOrientation())
			self.BuildScaffoldUnit = CreateUnit(bp.Build.BuildScaffoldUnit, self:GetArmy(), x, y, z, qx, qy, qz, qw )
			self.BuildScaffoldUnit:DeployScaffold(self)
			self.Trash:Add(self.BuildScaffoldUnit)
		end
	end,
	
    OnStopBeingBuilt = function(self,builder,layer)
        SeaUnit.OnStopBeingBuilt(self,builder,layer)

		-- Build scaffold is on it's own at this point.
		if self.BuildScaffoldUnit and not self.BuildScaffoldUnit:IsDead() then
			self.BuildScaffoldUnit:BuildUnitComplete()
		end

		self.BuildScaffoldUnit = nil
    end,

	PlayOnStartBuildAnimation = function( self )
		if self:GetBlueprint().Display.AnimationOnStartBuild then
			if (not self.Animator) then
				self.Animator = CreateAnimator(self)
			end
			self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationOnStartBuild)
		end
	end,

	PlayDeployAnimation = function( self )
		if self:GetBlueprint().Display.AnimationOnStartBuild then
			self:ForkThread( self.DeployAnimationThread )
		elseif self.Animator then
			self.Animator:Destroy()
			self.Animator = nil
		end
	end,

	DeployAnimationThread = function( self )
		if (not self.Animator) then
			self.Animator = CreateAnimator(self)
		end
		self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationDeploy)
		WaitFor(self.Animator)
		self.Animator:Destroy()
		self.Animator = nil
	end,
}