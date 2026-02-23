-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/claser04/claser04_script.lua
--  Author(s):	Gordon Duclos, Matt Vainio
--  Summary  :  SC2 Cybran Laser: CLaser04
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile

CLaser04 = Class(Projectile) {
    OnImpact = function(self, TargetType, TargetEntity)
        Projectile.OnImpact (self, TargetType, TargetEntity)
		self:ShakeCamera( 15, 0.25, 0, 0.3 )
	end,
}
TypeClass = CLaser04