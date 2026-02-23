-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/uhandcannon01/uhandcannon01_script.lua
--  Author(s):	Gordon Duclos, Aaron Lundquist
--  Summary  :  SC2 UEF Hand Cannon: UHandCannon01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat
local Projectile = import('/lua/sim/Projectile.lua').Projectile

UHandCannon01 = Class(Projectile) { 
  
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Water' then 
			local scale = RandomFloat(13,18)
			CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale, scale, 150, 15, self:GetArmy(), 5)
		end	 

		Projectile.OnImpact( self, TargetType, targetEntity )
    end,
  
  
--[[
	OnImpact = function(self, TargetType, TargetEntity)
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            -- Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end
	        
			local sides = 12
			local angle = (2*math.pi) / sides
			local velocity = 20
			local OffsetMod = 5
			local projectiles = {}

			for i = 0, (sides-1) do
				local X = math.sin(i*angle)
				local Z = math.cos(i*angle)
				local proj =  self:CreateProjectile('/effects/entities/UEFHandCannonShockwave/UEFHandCannonShockwave01_proj.bp', X * OffsetMod , 1, Z * OffsetMod, X, 0, Z)
					:SetVelocity(velocity)
					:SetAcceleration(-30)
				table.insert( projectiles, proj )
			end  
        end
        Projectile.OnImpact(self, TargetType, TargetEntity)  
    end,
]]--  

}
TypeClass = UHandCannon01