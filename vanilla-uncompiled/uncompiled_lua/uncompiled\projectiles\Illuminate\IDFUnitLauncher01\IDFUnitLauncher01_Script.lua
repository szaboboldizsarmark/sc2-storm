--****************************************************************************
--**
--**  File     :
--**  Author(s):
--**
--**  Summary  :
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local Projectile = import('/lua/sim/Projectile.lua').Projectile
IDFUnitLauncher01 = Class(Projectile) {

	SetUnitAmmo = function( self, newUnitAmmo )
		self.UnitAmmo = newUnitAmmo
		self:SetCollisionShape('Sphere', 0, 0, 0, 2)
		
		-- Add a tumble/spin to projectiles to simulate cluster bomblets
        self:SetLocalAngularVelocity(Random(-12,12), Random(-12,12), Random(-12,12))
	end,

	OnDestroy = function(self)
		Projectile.OnDestroy(self)
		if self.UnitAmmo and not self.UnitAmmo:IsDead() then
			self.UnitAmmo:Kill()
			self.UnitAmmo = nil
		end 
	end,

    OnImpact = function(self, impactType, impactEntity)
		Projectile.OnImpact(self, impactType, impactEntity)
		if self.UnitAmmo and not self.UnitAmmo:IsDead() then
			self.UnitAmmo:Kill()
			self.UnitAmmo = nil
		end 
    end,
}
TypeClass = IDFUnitLauncher01