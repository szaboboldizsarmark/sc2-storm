-----------------------------------------------------------------------------
--  File     : /lua/sim/scaffoldunit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Structure Unit
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

ScaffoldUnit = Class(StructureUnit) {

	OnCreate = function(self)
		StructureUnit.OnCreate(self)
		self:SetDoNotTarget(true)
		self:SetCanTakeDamage(false)
		self:SetUnSelectable(true)
		self.IgnoreDamage = true
		self.IsPaused = false

		local bp = self:GetBlueprint()

		-- Initialize illuminate build scaffolding animset
		local animset = bp.AnimSet
		if animset then
			self:PushAnimSet(animset, "Base");
		end

		self.EffectScale = bp.Display.BuildEffectsScale or 1
		self.Advancing = false
		self.ForceCompleted = false
		self.FinalPhase = false
		self.tt1 = nil
		self.tt2 = nil
	end,
	
    OnPaused = function(self)
		self:SendAnimEvent( 'SetPaused', 'true' )
		self.IsPaused = true
        StructureUnit.OnPaused(self)
    end,
	
    OnUnpaused = function(self)
		self:SendAnimEvent( 'SetPaused', 'false' )
		self.IsPaused = false
        StructureUnit.OnUnpaused(self)
    end,

	DeployScaffold = function( self, unitBeingBuilt )
		self.unitBeingBuilt = unitBeingBuilt	
		self:SendAnimEvent( 'play_deploy' )
		self:PlayUnitSound( 'Deploy' )
	end,

	GetClosestBuildPoint = function( self, builder )
		local buildPoints = self:GetBlueprint().Display.BuildPointBones or {}
		local closestBuildPoint = -2
		local buildDist = 100
		local builderPos = builder:GetPosition()

		for k, v in buildPoints do
			local currentBuildDist = VDist3(self:GetPosition(v),builderPos)
			if currentBuildDist < buildDist then
				buildDist = currentBuildDist
				closestBuildPoint = v
			end
		end	

		return closestBuildPoint
	end,

	BuildUnitComplete = function(self)
	end,
}