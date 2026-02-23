-----------------------------------------------------------------------------
--  File     :  /projectiles/illuminate/ibomb01/ibomb01_script.lua
--  Author(s):	Aaron Lundquist
--  Summary  :  SC2 Illuminate Bomb 01: IBomb01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat

local Projectile = import('/lua/sim/Projectile.lua').Projectile
IBomb01 = Class(Projectile) {
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local rotation = RandomFloat(0,2*math.pi)
			local scale = RandomFloat(3.75,5.0)
	        
			--CreateDecal(self:GetPosition(), rotation, '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, 150, 15, self:GetArmy())
		end	 
		Projectile.OnImpact( self, TargetType, targetEntity )
    end,
}
TypeClass = IBomb01