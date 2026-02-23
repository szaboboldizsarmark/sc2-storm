-----------------------------------------------------------------------------
--  File     : /projectiles/cybran/ctacticalmissile01/cfragmissile01_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 Cybran Fragmentation Missile: CFragMissile01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat

CFragMissile01 = Class(Projectile) {

    OnCreate = function(self)
        Projectile.OnCreate(self)
		self:SetBallisticAcceleration(-12)
		self.SequencingId = 1
		self.Side = 'Right'
    end,

	SetSide = function(self, side)
		self.Side = side
	end,

	SetSequencingId = function(self, id)
		self.SequencingId = id
	end,

    OnImpact = function(self, TargetType, TargetEntity)
        local ChildProjectileBP = '/projectiles/Cybran/CFragMissileSplit01/CFragMissileSplit01_proj.bp'

        -- Split effects
        for k, v in EffectTemplates.Weapons.Cybran_Missile02_Split01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end

		-- Create several projectiles in a dispersal pattern
        local numProjectiles = 3
		local x, y, z = self:GetVelocity()
		local crossVec = VCross( Vector(x,y,z), Vector(0,1,0) )
		local speed = self:GetCurrentSpeed()
		local splitMul = 0.5

		-- Divide damage by the number of projectiles
		self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles

		if self.Side == 'Right' then
			if self.SequencingId == 1 then
				-- Launch projectiles at semi-random angles away from split location
				for i = 0, (numProjectiles -1) do
					local proj = self:CreateChildProjectile(ChildProjectileBP)
					proj:SetVelocity(x + crossVec[1]*splitMul-(crossVec[1]*splitMul*i), y, z + crossVec[3]*splitMul-(crossVec[3]*splitMul*i))
					proj:SetVelocity(speed * 4 + (i*3))
					proj:SetBallisticAcceleration(-12 + ((numProjectiles-i) * 2))
					proj:PassDamageData(self.DamageData)
				end
			elseif self.SequencingId == 2 then
				-- Launch projectiles at semi-random angles away from split location
				for i = 0, (numProjectiles -1) do
					local proj = self:CreateChildProjectile(ChildProjectileBP)
					proj:SetVelocity(x + crossVec[1]*splitMul-(crossVec[1]*splitMul*i), y, z + crossVec[3]*splitMul-(crossVec[3]*splitMul*i))
					proj:SetVelocity(speed * 4 + ((numProjectiles-i)*2))
					proj:SetBallisticAcceleration(-8 - (i * 2))
					proj:PassDamageData(self.DamageData)
				end
			elseif self.SequencingId == 3 then
				-- Launch projectiles at semi-random angles away from split location
				for i = 0, (numProjectiles -1) do
					local proj = self:CreateChildProjectile(ChildProjectileBP)
					proj:SetVelocity(x + crossVec[1]*splitMul-(crossVec[1]*splitMul*i), y, z + crossVec[3]*splitMul-(crossVec[3]*splitMul*i))
					proj:SetVelocity(speed * 4 + ((numProjectiles-i)*2))
					proj:SetBallisticAcceleration(-8 - (i * 2))
					proj:PassDamageData(self.DamageData)
				end
			end
		else
			if self.SequencingId == 1 then
				-- Launch projectiles at semi-random angles away from split location
				for i=0,(numProjectiles -1) do
					local proj = self:CreateChildProjectile(ChildProjectileBP)
					proj:SetVelocity(x + crossVec[1]*splitMul-(crossVec[1]*splitMul*i), y, z + crossVec[3]*splitMul-(crossVec[3]*splitMul*i))
					proj:SetVelocity(speed * 4 + ((numProjectiles-i)*3))
					proj:SetBallisticAcceleration(-12 + (i * 2))
					proj:PassDamageData(self.DamageData)
				end
			elseif self.SequencingId == 2 then
				-- Launch projectiles at semi-random angles away from split location
				for i=0,(numProjectiles -1) do
					local proj = self:CreateChildProjectile(ChildProjectileBP)
					proj:SetVelocity(x + crossVec[1]*splitMul-(crossVec[1]*splitMul*i), y, z + crossVec[3]*splitMul-(crossVec[3]*splitMul*i))
					proj:SetVelocity(speed * 4 + ((numProjectiles-i)*2))
					proj:SetBallisticAcceleration(-16 + (i * 3))
					proj:PassDamageData(self.DamageData)
				end
			elseif self.SequencingId == 3 then
				-- Launch projectiles at semi-random angles away from split location
				for i=0,(numProjectiles -1) do
					local proj = self:CreateChildProjectile(ChildProjectileBP)
					proj:SetVelocity(x + crossVec[1]*splitMul-(crossVec[1]*splitMul*i), y, z + crossVec[3]*splitMul-(crossVec[3]*splitMul*i))
					proj:SetVelocity(speed * 4 + ((numProjectiles-i)*2))
					proj:SetBallisticAcceleration(-16 + (i * 3))
					proj:PassDamageData(self.DamageData)
				end
			end
		end

        self:Destroy()
    end,
}
TypeClass = CFragMissile01