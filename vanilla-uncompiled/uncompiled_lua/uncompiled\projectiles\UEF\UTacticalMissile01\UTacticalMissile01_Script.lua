-----------------------------------------------------------------------------
--  File     : /projectiles/uef/utacticalmissile01/utacticalmissile01_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 UEF (SHORT RANGE) Tactical Missile: UTacticalMissile01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local GetVectorLength = import('/lua/system/utilities.lua').GetVectorLength

UTacticalMissile01 = Class(Projectile) {

    OnCreate = function(self)
        Projectile.OnCreate(self)

		-- Cache target position, since this projectile does not track targets
		self.cachedTargetPos = self:GetCurrentTargetPosition()
		if not self.cachedTargetPos then
			LOG( 'UTacticalMissile01 created with no target' )
			self.cachedTargetPos = Vector(0,0,0)
		end

		self.MoveThread = self:ForkThread(self.MovementThread)
    end,

	InitialMovementBehavior = function(self)
		WaitSeconds( 0.2 )

        -- Slow down projectile after initial launch before boosters fire
        self:SetAcceleration(-22)               -- -35 original tuning
        self:SetBallisticAcceleration(-7)       -- -15 original tuning

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
		for k, v in EffectTemplates.Weapons.UEF_Cruisemissile01_Trails01 do
			CreateAttachedEmitter ( self, -1, self:GetArmy(), v )
		end
		for k, v in EffectTemplates.Weapons.UEF_Cruisemissile01_Polytrails01 do
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
TypeClass = UTacticalMissile01