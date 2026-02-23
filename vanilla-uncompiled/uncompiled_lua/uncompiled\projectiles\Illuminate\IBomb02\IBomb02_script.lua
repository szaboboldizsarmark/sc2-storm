-----------------------------------------------------------------------------
--  File     :  /projectiles/illuminate/ibomb02/ibomb02_script.lua
--  Author(s):	Aaron Lundquist
--  Summary  :  SC2 Illuminate Bomb 02: IBomb02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local Projectile = import('/lua/sim/Projectile.lua').Projectile

IBomb02 = Class(Projectile) {

    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then
			local scale = RandomFloat(3.75,5.0)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 8 )
		end

		Projectile.OnImpact( self, TargetType, targetEntity )
    end,

    DoImpactEffects = function(self,targetType,targetEntity)
	    local EffectsBp = self:GetBlueprint().Effects

        if EffectsBp and EffectsBp.Impacts then
            local impactEffect = EffectsBp.Impacts[targetType]

	        if targetType == 'Unit' and self and targetEntity then    		    
		        if self:GetPosition()[2] - targetEntity:GetPosition()[2] >=  2.0 then
		            if impactEffect and (impactEffect.Template and impactEffect.Template != '') then
                        CreateImpactEffectsOnProjectileCollision( self, 'Illuminate_Bomb01_Impact02', impactEffect.Scale, impactEffect.Offset, impactEffect.TrajectoryAligned or false  )
                    end
		        else	            
		            if impactEffect and (impactEffect.Template and impactEffect.Template != '') then
                        CreateImpactEffectsOnProjectileCollision( self, impactEffect.Template, impactEffect.Scale, impactEffect.Offset, impactEffect.TrajectoryAligned or false  )
                    end
		        end
		    else
		        if impactEffect and (impactEffect.Template and impactEffect.Template != '') then
                    CreateImpactEffectsOnProjectileCollision( self, impactEffect.Template, impactEffect.Scale, impactEffect.Offset, impactEffect.TrajectoryAligned or false  )
                end
                CreateTerrainImpactEffects( self, targetType, EffectsBp.TerrainClass )
		    end
		    
	    end
    end,
}
TypeClass = IBomb02