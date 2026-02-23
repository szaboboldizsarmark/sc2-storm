-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/URiotgun01/URiotgun01_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 UEF Artillery Child Shell: URiotgun01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

URiotgun01 = Class(Projectile) {
	SetReflected = function(self, entityReflecting)
		self:DoImpactEffects('Shield',entityReflecting)
		self:Destroy()
	end,
}
TypeClass = URiotgun01