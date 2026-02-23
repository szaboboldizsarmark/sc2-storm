-----------------------------------------------------------------------------
--  File     : /projectiles/cybran/ctacticalmissile03/ctacticalmissile03_script.lua
--  Author(s): Aaron Lundquist
--  Summary  : SC2 Cybran (SHORT RANGE) Tactical Missile: CTacticalMissile03
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
			LOG( 'CTacticalMissile02 created with no target' )
			self.cachedTargetPos = Vector(0,0,0)
		end

		self.MoveThread = self:ForkThread(self.MovementThread)
    end,

	InitialMovementBehavior = function(self)
		WaitSeconds( 1.0 )

        -- Slow down projectile after initial launch before boosters fire
        self:SetAcceleration(-35)               
        self:SetBallisticAcceleration(-15)

        -- Snag vector from initial launch to be used later
        WaitSeconds(0.1)
        local vx, vy, vz = self:GetVelocity()

        -- Pause before launching, create booster ignition effects + trails
        WaitSeconds( 0.3 )
        self:CreateThrustEffects()

		-- Set accelerations, velocity and direction vector
		-- These are tuned to be inline with other short range tactical
		-- missile speeds
		self:SetAcceleration(3)
		self:SetBallisticAcceleration(0)	-- Turn off gravity
		self:SetVelocity(vx, vy, vz)		-- Reset velocity vector
        self:SetVelocity(3)

		-- After ignition, turn on alignment and target tracking
		self:SetVelocityAlign(true)
		self:TrackTarget(true)
		WaitSeconds(0.4)
	end,


	CreateThrustEffects = function(self)
		for k, v in EffectTemplates.Weapons.Cybran_Missile03_Trails01 do
			CreateAttachedEmitter ( self, -1, self:GetArmy(), v )
		end
		for k, v in EffectTemplates.Weapons.Cybran_Missile03_Polytrails01 do
			CreateTrail( self, -1, self:GetArmy(), v )
		end
	end,

	MovementThread = function(self)
        self.WaitTime = 0.1
        self.Distance = self:GetDistanceToTarget()

		-- Initial movement behavior includes a 1 second delay before continuing
		-- (similar to other factions short range tactical missiles)
		self:InitialMovementBehavior()
		if self.Distance > 10 then
			WaitSeconds( 1 )
		elseif self.Distance <= 10 then
			WaitSeconds( 0.5 )
		end

        -- Adjust turn rate based on distance to target
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
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