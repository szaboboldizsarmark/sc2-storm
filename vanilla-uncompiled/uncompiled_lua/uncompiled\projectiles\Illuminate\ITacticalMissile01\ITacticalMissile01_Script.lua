-----------------------------------------------------------------------------
--  File     : /projectiles/illuminate/itacticalmissile01/itacticalmissile01_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Illuminate (SHORT RANGE) Tactical Missile: ITacticalMissile01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

ITacticalMissile01 = Class(Projectile) {

    OnCreate = function(self)
        Projectile.OnCreate(self)

		-- Cache target position, since this projectile does not track targets
		self.cachedTargetPos = self:GetCurrentTargetPosition()
		if not self.cachedTargetPos then
			LOG( 'ITacticalMissile01 created with no target' )
			self.cachedTargetPos = Vector(0,0,0)
		end

		self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)
        self.WaitTime = 0.1
        self.Distance = self:GetDistanceToTarget()

		if self.Distance > 10 then
			WaitSeconds( 1.5 )
		elseif self.Distance <= 10 then
			WaitSeconds( 1 )
		end

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
TypeClass = ITacticalMissile01