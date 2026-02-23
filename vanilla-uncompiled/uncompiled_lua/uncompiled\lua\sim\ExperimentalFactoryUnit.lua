-----------------------------------------------------------------------------
--  File     : /lua/sim/ExperimentalFactoryUnit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Experimental Factory Unit
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit
local FAIL_CHANCE_INTERVAL = 30
local STUN_DURATION = 15

ExperimentalFactoryUnit = Class(FactoryUnit) {

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