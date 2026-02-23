--
-- UEF Artillery Projectile
--
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local Projectile = import('/lua/sim/Projectile.lua').Projectile

UDisruptorArtillery01 = Class(Projectile) {
    OnCreate = function(self, inWater)
        
        local randomPolyTrail = EffectTemplates.Weapons.UEF_DisruptorArtillery01_Polytrails01[Random(1,table.getn(EffectTemplates.Weapons.UEF_DisruptorArtillery01_Polytrails01))]

        for k, v in randomPolyTrail do
		    CreateTrail( self, -2, self:GetArmy(), v )
		end
        
        Projectile.OnCreate(self)
    end,
    
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local scale = RandomFloat(13,18)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 5)
		end	 

		Projectile.OnImpact( self, TargetType, targetEntity )
    end,
}
TypeClass = UDisruptorArtillery01

