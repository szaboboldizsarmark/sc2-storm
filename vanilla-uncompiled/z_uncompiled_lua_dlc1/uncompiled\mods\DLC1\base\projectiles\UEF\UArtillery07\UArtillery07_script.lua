-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/UArtillery07/UArtillery07_script.lua
--  Author(s): Aaron Lundquist
--  Summary  : SC2 UEF Artillery: UArtillery07
--  Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat

UArtillery07 = Class(import('/lua/sim/Projectile.lua').Projectile) {
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local scale = RandomFloat(10,15)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 70, 15, self:GetArmy(), 8)
		end	 

		Projectile.OnImpact( self, TargetType, targetEntity )
		self:ShakeCamera( 10, 1, 0.2, 0.3 )
    end,
}
TypeClass = UArtillery07