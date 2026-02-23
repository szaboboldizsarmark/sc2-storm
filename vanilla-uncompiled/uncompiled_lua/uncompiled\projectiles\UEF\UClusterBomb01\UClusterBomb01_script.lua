-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/uclusterbomb01/uclusterbomb01_script.lua
--  Author(s):	Gordon Duclos, Aaron Lundquist
--  Summary  :  SC2 UEF Bomber Cluster Bomb: UClusterBomb01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

UClusterBomb01 = Class(Projectile) {

    ChildProjectile = '/projectiles/UEF/UClusterBomb02/UClusterBomb02_proj.bp',

    OnCreate = function(self)
        Projectile.OnCreate(self)
        self.Impacted = false
		self.CreateVisMarker = false
		self.VisMarkerLifeTime = 40
		self.VisMarkerCreated = false
    end,

    -- Note: Damage is done once by main projectile. Secondary projectiles
    -- are just visual.
    OnImpact = function(self, TargetType, TargetEntity)
		if TargetType == 'Terrain' then
			local scale = RandomFloat(3.75,5.0)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 8 )
		end

		-- If we have bomb camera attached, create a vis marker
		if self.CreateVisMarker and not self.VisMarkerCreated then
			if TargetType != 'Air' then
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
				self.VisMarkerCreated = true
			end
		end

        if not self.Impacted then
			if TargetType != 'Air' and TargetType != 'Shield' then
				self.Impacted = true
				self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1,3),Random(1.5,3),Random(2,3))
				self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1.25,2),Random(1,3),Random(1,2))
				self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1,3),Random(1.5,3),-Random(2,3))
				self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1.5,3),Random(1,3),Random(1,3))
				self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(2,3),Random(1,3),Random(1,2))
				self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(2,4),Random(1.5,3),Random(2,3))
				self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(3,4),Random(1.5,3),Random(2,4))
			end
		end
        
		Projectile.OnImpact(self, TargetType, TargetEntity)
    end,

	SetBombCamera = function(self, enable, duration)
		self.CreateVisMarker = enable
		self.VisMarkerLifeTime = duration
	end,
}
TypeClass = UClusterBomb01