-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cartillery01/cartillery01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Artillery: CArtillery01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local Projectile = import('/lua/sim/Projectile.lua').Projectile
CArtillery01 = Class(Projectile) {

    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local scale = RandomFloat(14,20)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 8)
		end	
		
		if self.Data.Radius and self.Data.Lifetime then
			local pos = self:GetPosition()
			local spec = {
				X = pos[1],
				Z = pos[3],
				Radius = self.Data.Radius,
				LifeTime = self.Data.Lifetime,
				Army = self.Data.Army,
				Omni = false,
				WaterVision = false,
			}
			local vizEntity = VizMarker(spec)
		end
		
		Projectile.OnImpact( self, TargetType, targetEntity )
		self:ShakeCamera( 10, 1, 0.2, 0.3 )
    end,

    ForceThread = function(self, pos)
        DamageArea(self, pos, 10, 1, 'Force', true)
        WaitTicks(2)
        DamageArea(self, pos, 10, 1, 'Force', true)
        DamageRing(self, pos, 10, 15, 1, 'Fire', true)
    end,

}
TypeClass = CArtillery01