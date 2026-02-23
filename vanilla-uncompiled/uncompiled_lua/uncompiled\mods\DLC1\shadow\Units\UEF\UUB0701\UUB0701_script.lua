-----------------------------------------------------------------------------
--  File     : /units/uef/uub0701/uub0701_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF: Mass Extractor
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MassCollectionUnit = import('/lua/sim/MassCollectionUnit.lua').MassCollectionUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUB0701 = Class(MassCollectionUnit) {

    Weapons = {
        PointDefense01 = Class(DefaultProjectileWeapon) {},
        AntiAir01 = Class(DefaultProjectileWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		MassCollectionUnit.OnStopBeingBuilt(self,builder,layer)
		self:ForkThread( self.VeterancyThread )
	end,
	
	VeterancyThread = function(self)
		while (true) do
			WaitSeconds(5)
			self:AwardExperience(1)
		end
	end,

	PlayActivateAnimation = function(self)
		self:ForkThread(function()
			WaitSeconds(Random(1,15) * 0.1)
			local DisplayBp = self:GetBlueprint().Display

			if not self.AnimationManipulator then
				self.AnimationManipulator = CreateAnimator(self)
				self.Trash:Add(self.AnimationManipulator)
			end
			self.AnimationManipulator:PlayAnim(DisplayBp.AnimationActivate, DisplayBp.AnimationActivateLoop or false )
		end)
    end,
}
TypeClass = UUB0701