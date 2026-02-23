-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/uhandcannon02/uhandcannon02_script.lua
--  Author(s):	Gordon Duclos, Aaron Lundquist
--  Summary  :  SC2 UEF Hand Cannon: UHandCannon02
--  Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local Projectile = import('/lua/sim/Projectile.lua').Projectile

UHandCannon02 = Class(Projectile) { 
  
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local scale = RandomFloat(13,18)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 5)
		end	 

		Projectile.OnImpact( self, TargetType, targetEntity )
    end,
}
TypeClass = UHandCannon02