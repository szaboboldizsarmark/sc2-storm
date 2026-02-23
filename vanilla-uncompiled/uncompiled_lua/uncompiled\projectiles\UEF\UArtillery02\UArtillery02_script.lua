-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/UArtillery02/UArtillery02_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 UEF Artillery: UArtillery02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat

UArtillery02 = Class(import('/lua/sim/Projectile.lua').Projectile) {
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local scale = RandomFloat(14,20)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 8)
		end	 

		Projectile.OnImpact( self, TargetType, targetEntity )
		self:ShakeCamera( 10, 1, 0.2, 0.3 )
    end,
}
TypeClass = UArtillery02