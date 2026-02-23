-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/UArtillery04/UArtillery04_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 UEF Artillery Shell: UArtillery04
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

UArtillery04 = Class(Projectile) {

    OnCreate = function(self)
        Projectile.OnCreate(self)

        -- Adjust height where projectile splits to correct for different distance targets (lower arcs).
        self:ChangeDetonateBelowHeight(5)
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        -- Damaging projectile cluster bombs spawned during split
        local ChildProjectileBP = '/projectiles/UEF/UArtillery05/UArtillery05_proj.bp'

        -- Split effects
        for k, v in EffectTemplates.Weapons.UEF_Artillery01_Split01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v )
        end

        -- Get velocity angle of primary shell
        local vx, vy, vz = self:GetVelocity()
        local velocity = Random() + 5.0

		-- One initial projectile following same directional path as the original
        self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, vy, vz):SetVelocity(velocity):PassDamageData(self.DamageData)

		-- Create several other projectiles in a dispersal pattern
        local numProjectiles = 4
        local angle = (2*math.pi) / numProjectiles
        local angleInitial = Random() * angle

        -- Randomization of the spread
        local angleVariation = angle * 5.0 -- Adjusts angle variance spread
        local spreadMul = 0.075 -- Adjusts the width of the dispersal

        local xVec = 0
        local yVec = vy
        local zVec = 0

        -- Launch projectiles at semi-random angles away from split location
        for i = 0, (numProjectiles -1) do
            xVec = vx + (math.sin(angleInitial + (i*angle) + ((-angleVariation * Random() * 2) + angleVariation))) * spreadMul
            zVec = vz + (math.cos(angleInitial + (i*angle) + ((-angleVariation * Random() * 2) + angleVariation))) * spreadMul
            local proj = self:CreateChildProjectile(ChildProjectileBP)
            proj:SetVelocity(xVec,yVec,zVec)
            proj:SetVelocity(velocity * (Random() + 0.7))
            proj:PassDamageData(self.DamageData)
        end

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
        self:Destroy()
    end,
}
TypeClass = UArtillery04