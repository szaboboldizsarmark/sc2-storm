-----------------------------------------------------------------------------
--  File     : /lua/sim/constructionunit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Construction Unit
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local HoverUnit = import('/lua/sim/HoverUnit.lua').HoverUnit

ConstructionUnit = Class(HoverUnit) {

	IsHoverUnit = false,

    OnCreate = function(self, createArgs)
        HoverUnit.OnCreate(self, createArgs)
        self.EffectsBag = {}
	end,
	
	OnKilled = function(self, instigator, type, overkillRatio)
		local layer = self:GetCurrentLayer()
		if layer == 'Water' then
			if self.BuildEffectsBag then
				self.BuildEffectsBag:Destroy()
			end
			if self.CaptureEffectsBag then
				self.CaptureEffectsBag:Destroy()
			end
			if self.ReclaimEffectsBag then
				self.ReclaimEffectsBag:Destroy()
			end
			if self.OnBeingBuiltEffectsBag then
				self.OnBeingBuiltEffectsBag:Destroy()
			end
			if self.UpgradeEffectsBag then
				self.UpgradeEffectsBag:Destroy()
			end
		end
		if self.BuildingOpenAnim and self.BuildingOpenAnimManip then
			self.BuildingOpenAnimManip:Destroy()
		end
		HoverUnit.OnKilled(self, instigator, type, overkillRatio)		
	end,

	OnStopBeingBuilt = function(self, builder, layer)
		HoverUnit.OnStopBeingBuilt(self, builder, layer)
        if self:GetBlueprint().Display.AnimationBuild then
            self.BuildingOpenAnim = self:GetBlueprint().Display.AnimationBuild
			self.BuildingOpenAnimManip = CreateAnimator(self)
			self.BuildingOpenAnimManip:SetPrecedence(1)            
        end

        self.BuildingUnit = false
    end,

    OnPaused = function(self)
        --When construction is paused take some action
		if self:IsUnitState('Upgrading') or self:IsUnitState('Repairing') then
			self:StopUnitAmbientSound( 'ConstructLoop' )
			HoverUnit.OnPaused(self)
			if self.BuildingUnit then
				HoverUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
			end
		end
    end,

    OnUnpaused = function(self)
		if self:IsUnitState('Upgrading') or self:IsUnitState('Repairing') then
			if self.BuildingUnit then
				self:PlayUnitAmbientSound( 'ConstructLoop' )
				HoverUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
			end
			HoverUnit.OnUnpaused(self)
		end
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )
        HoverUnit.OnStartBuild(self,unitBeingBuilt, order)
        --Fix up info on the unit id from the blueprint and see if it matches the 'UpgradeTo' field in the BP.
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true
        local bp = self:GetBlueprint()

		if order == 'Upgrade' then
			self.Upgrading = true
			self.BuildingUnit = false
		else
			if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and
				self.UnitBeingBuilt.BuildScaffoldUnit and not self.UnitBeingBuilt.BuildScaffoldUnit:IsDead() then
				self.UnitBeingBuilt.BuildScaffoldUnit:OnUnpaused()
			end
            HoverUnit.StartBuildingEffects(self, unitBeingBuilt, order)
        end
    end,

    OnStopBuild = function(self, unitBeingBuilt)
        HoverUnit.OnStopBuild(self,unitBeingBuilt)
        if self.Upgrading then
            NotifyUpgrade(self,unitBeingBuilt)
            self:Destroy()
        end
		if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and
			self.UnitBeingBuilt.BuildScaffoldUnit and not self.UnitBeingBuilt.BuildScaffoldUnit:IsDead() then
			self.UnitBeingBuilt.BuildScaffoldUnit:OnPaused()
		end
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil

        if self:GetBuildArmManipulator(0) then
            self.StoppedBuilding = true
        else
            self:ForkThread( self.WaitForBuildAnimation, false )
        end
        self.BuildingUnit = false
    end,

    OnStopCapture = function(self, targetUnit)
        HoverUnit.OnStopCapture(self,targetUnit)

        if self:GetBuildArmManipulator(0) then
            self.StoppedBuilding = true
        else
             self:ForkThread( self.WaitForBuildAnimation, false )
        end
    end,
    
    OnStopReclaim = function(self, target)
        HoverUnit.OnStopReclaim(self,target)
        
        if self:GetBuildArmManipulator(0) then
            self.StoppedBuilding = true
        else
             self:ForkThread( self.WaitForBuildAnimation, false )
        end
    end,
    
    -- Empty function. Each engineer that needs one has it as a part of their script.
    HandleBuildArm = function(enable)
    end,

    WaitForBuildAnimation = function(self, enable)
		if self and not self:IsDead() and self:GetBuildArmManipulator(0) then
			if enable then
				if self.BuildingOpenAnim then
					self.BuildingOpenAnimManip:PlayAnim(self.BuildingOpenAnim, false):SetRate(1)
					WaitFor(self.BuildingOpenAnimManip)
				else
					self:HandleBuildArm(true)
				end
				if self:IsDead() then return end
				self:BuildManipulatorsSetEnabled(true)
			else
				if self.BuildingOpenAnim then
					self.BuildingOpenAnimManip:PlayAnim(self.BuildingOpenAnim, false):SetRate(-1)
				else
					self:HandleBuildArm(false)
				end
			end
		end
    end,

    OnPrepareArmToBuild = function(self)
        HoverUnit.OnPrepareArmToBuild(self)

        if self:GetBuildArmManipulator(0) then
            self.StoppedBuilding = false
            self:ForkThread( self.WaitForBuildAnimation, true )
        end
    end,

    OnStopBuilderTracking = function(self)
        HoverUnit.OnStopBuilderTracking(self)

        if self.StoppedBuilding then
            self.StoppedBuilding = false
            self:BuildManipulatorsSetEnabled(false)
            self:ForkThread( self.WaitForBuildAnimation, false )
        end
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
		local isBeingBuilt = unitBeingBuilt:IsBeingBuilt()
		if order == 'MobileBuild' then
			local scaffoldUnit = unitBeingBuilt:GetBuildScaffoldUnit()
			if scaffoldUnit then
				CreateBlueWavyBuildBeams( self, scaffoldUnit, self:GetBlueprint().Build.EffectBones, self.BuildEffectsBag )
			else
				CreateBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().Build.EffectBones, self.BuildEffectsBag )
			end
		elseif order == 'Repair' then
            CreateRepairBeams( self, unitBeingBuilt, self:GetBlueprint().Build.EffectBones, self.BuildEffectsBag )
		elseif order == 'BuildAssist' then
            CreateBuildAssistBeams( self, unitBeingBuilt, self:GetBlueprint().Build.EffectBones, self.BuildEffectsBag )
		end
    end,
}