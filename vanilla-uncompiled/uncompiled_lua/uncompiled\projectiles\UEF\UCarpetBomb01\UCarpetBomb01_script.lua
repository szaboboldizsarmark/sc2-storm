-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/ucarpetbomb01/ucarpetbomb01_script.lua
--  Author(s):	Gordon Duclos, Aaron Lundquist
--  Summary  :  SC2 UEF Bomber Carpet Bomb: UCarpetBomb01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

UCarpetBomb01 = Class(Projectile) {

	OnCreate = function(self, inWater)
		Projectile.OnCreate(self, inWater)
		self.CreateVisMarker = false
		self.VisMarkerLifeTime = 40
	end,

    OnImpact = function(self, TargetType, targetEntity)

		if TargetType != 'Water' then
			local scale = RandomFloat(3.75,5.0)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 8 )
		end

		-- If we have bomb camera attached, create a vis marker
		if self.CreateVisMarker then
			local pos = self:GetPosition()
			local spec = {
				X = pos[1],
				Z = pos[3],
				Radius = 20,
				LifeTime = self.VisMarkerLifeTime,
				Army = self:GetArmy(),
				Omni = false,
				WaterVision = false,
			}
			local vizEntity = VizMarker(spec)
		end
		Projectile.OnImpact( self, TargetType, targetEntity )
    end,

	SetBombCamera = function(self, enable, duration)
		self.CreateVisMarker = enable
		self.VisMarkerLifeTime = duration
	end,
	
	DoImpactEffects = function(self,targetType,targetEntity)
	    local EffectsBp = self:GetBlueprint().Effects

        if EffectsBp and EffectsBp.Impacts then
            local impactEffect = EffectsBp.Impacts[targetType]

	        if targetType == 'Unit' and self and targetEntity then
		        if self:GetPosition()[2] - targetEntity:GetPosition()[2] >=  2.0 then
		            if impactEffect and (impactEffect.Template and impactEffect.Template != '') then
                        CreateImpactEffectsOnProjectileCollision( self, 'UEF_Napalm01_ImpactAir01', impactEffect.Scale, impactEffect.Offset, impactEffect.TrajectoryAligned or false  )
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
TypeClass = UCarpetBomb01