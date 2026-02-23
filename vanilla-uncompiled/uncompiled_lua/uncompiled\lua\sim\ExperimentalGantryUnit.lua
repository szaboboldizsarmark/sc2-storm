-----------------------------------------------------------------------------
--  File     : /lua/sim/ExperimentalGantryUnit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Experimental Factory Unit
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FactoryUnit = import('/lua/sim/FactoryUnit.lua').FactoryUnit

ExperimentalGantryUnit = Class(FactoryUnit) {

	OnCreate = function(self)
		FactoryUnit.OnCreate(self)
		self.BakedUnitPercentage = 0
        self.ProgressToRelease = 0
	end,

	OnStartBuild = function(self, unitBeingBuilt, order )
		FactoryUnit.OnStartBuild(self, unitBeingBuilt, order )
		unitBeingBuilt:PlayOnStartBuildAnimation()
        local buildTime = unitBeingBuilt:GetBlueprint().Economy.BuildTime
        
        local excluded = false
        if self:GetBlueprint().Build.BuildModifiersExclusionCategory then
            for k, v in self:GetBlueprint().Build.BuildModifiersExclusionCategory do
                if EntityCategoryContains(ParseEntityCategory(v), unitBeingBuilt) then
                    excluded = true
                    break
                end
            end
        end

        if not excluded then
            buildTime = buildTime * self:GetBuildTimeMultiplier()
        end
        
        local prepReleaseTime = self:GetBlueprint().Build.FinishBuildAnimDelay
        local buildRate = buildTime / self:GetBlueprint().Economy.BuildRate
        
        if prepReleaseTime and prepReleaseTime > 0 then
            if (prepReleaseTime * 2) > buildRate then
                self.ProgressToRelease = 0
            else
                self.ProgressToRelease = (buildTime - prepReleaseTime)/buildTime
            end
        end
	end,

	OnBuildPreRelease = function(self, unitBeingBuilt)
		FactoryUnit.OnBuildPreRelease(self, unitBeingBuilt)
		unitBeingBuilt:PlayDeployAnimation()
	end,

	OnStopBuild = function(self, unitBeingBuilt, order )
		FactoryUnit.OnStopBuild(self, unitBeingBuilt, order )
        self.ProgressToRelease = 0
		self.BakedUnitPercentage = 0
	end,

}