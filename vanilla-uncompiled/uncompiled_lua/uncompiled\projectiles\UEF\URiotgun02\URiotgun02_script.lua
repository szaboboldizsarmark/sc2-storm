-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/uriotgun02/uriotgun02_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Riot Gun: URiotgun02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

URiotgun02 = Class(Projectile) {
	SetReflected = function(self, entityReflecting)
		self:DoImpactEffects('Shield',entityReflecting)
		self:Destroy()
	end,
}
TypeClass = URiotgun02