-----------------------------------------------------------------------------
--  File     : /projectiles/Illuminate/IPullinsmash02/IPullinsmash02_proj.bp
--  Author(s): Gordon Duclos
--  Summary  : Pulinsmash utility projectile
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
IPullinsmash02 = Class(Projectile) {

	OnCreate = function(self, inWater)
		Projectile.OnCreate(self, inWater)
		self.AttachedUnit = nil
	end,

	SetAttachedUnit = function( self, attachUnit )
		self.AttachedUnit = attachUnit
	end,

	OnImpact = function( self, targetType, targetEntity )
		if self.AttachedUnit then
			self.AttachedUnit:CreateWreckageProp()
			self.AttachedUnit:Destroy()
		end
		Projectile.OnImpact( self, targetType, targetEntity )
	end,
}
TypeClass = IPullinsmash02