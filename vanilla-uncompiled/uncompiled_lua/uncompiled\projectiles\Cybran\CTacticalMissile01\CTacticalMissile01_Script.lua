-----------------------------------------------------------------------------
--  File     : /projectiles/cybran/ctacticalmissile01/ctacticalmissile01_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Cybran (SHORT RANGE) Tactical Missile: CTacticalMissile01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat

CTacticalMissile01 = Class(Projectile) {

    OnCreate = function(self)
        Projectile.OnCreate(self)

		-- Cache target position, since this projectile does not track targets
		self.cachedTargetPos = self:GetCurrentTargetPosition()
		if not self.cachedTargetPos then
			LOG( 'CTacticalMissile01 created with no target' )
			self.cachedTargetPos = Vector(0,0,0)
		end

		self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)
        self.WaitTime = 0.1
        self.Distance = self:GetDistanceToTarget()
		self.TurnByDist = true

		if self.Distance > 10 then
			WaitSeconds( 1.4 )
		elseif self.Distance <= 10 then
			WaitSeconds( 1 )
		end

        local DestroyDistance = (self.Distance / 4 )

        while not self:BeenDestroyed() do
			self.Distance = self:GetDistanceToTarget()
            if self.Distance < DestroyDistance then
				self.OnImpact(self)
			end
			if self.TurnByDist then
				self:SetTurnRateByDist()
			end
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > self.Distance then
        	self:SetTurnRate(20)
        	self.Distance = self:GetDistanceToTarget()
        end
        self:SetTurnRate(800/dist)
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        -- Damaging projectile lasers spawned during split
        local ChildProjectileBP = '/projectiles/Cybran/CTacticaMissile01SplitLaser01/CTacticaMissile01SplitLaser01_proj.bp'

        -- Split effects
        
        CreateEmittersAtBone( self, -2, self:GetArmy(), EffectTemplates.Weapons.Cybran_Missile01_Split01, false )
        
        -- Get velocity angle of primary shell
        local vx, vy, vz = self:GetVelocity()
        local velocity = 30 --RandomFloat( 2.0, 5.0 )

        -- Get position angle of target
        local mpos = self:GetPosition()
        vx = self.cachedTargetPos[1] - mpos[1]
        vy = self.cachedTargetPos[2] - mpos[2]
        vz = self.cachedTargetPos[3] - mpos[3]

		-- Create several projectiles in a dispersal pattern
        local numProjectiles = 3
        local angle = (2*math.pi) / numProjectiles
        local angleInitial = RandomFloat( 0, angle )

        -- Randomization of the spread
        local angleVariation = angle * 2.0 -- Adjusts angle variance spread
        local spreadMul = 0.35 -- Adjusts the width of the dispersal

        local xVec = 0
        local yVec = vy
        local zVec = 0

		-- Divide damage by the number of projectiles
		self.DamageData.DamageAmount = self.DamageData.DamageAmount / numProjectiles

        -- Launch projectiles at semi-random angles away from split location
        for i = 0, (numProjectiles -1) do
            xVec = vx + (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = vz + (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            local proj = self:CreateChildProjectile(ChildProjectileBP)
            proj:SetVelocity(xVec,yVec,zVec)
            proj:SetVelocity(velocity)
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
        self:Destroy()
    end,

    GetDistanceToTarget = function(self)
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], self.cachedTargetPos[1], self.cachedTargetPos[3])
        return dist
    end,

    OnLostTarget = function(self)
        Projectile.OnLostTarget(self)
        self:TrackTarget(false)
        self:SetBallisticAcceleration(-6)
    end,
}
TypeClass = CTacticalMissile01