-----------------------------------------------------------------------------
--  File     : /projectiles/illuminate/iflare01/iflare01_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Illuminate Flare: IFlare01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local FlareProjectile = import('/lua/sim/Projectile.lua').FlareProjectile

IFlare01 = Class(FlareProjectile) {

	OnCreate = function(self, inWater)
		FlareProjectile.OnCreate(self, inWater)
		self:SetCanTakeDamage(false)
	end,
}
TypeClass = IFlare01