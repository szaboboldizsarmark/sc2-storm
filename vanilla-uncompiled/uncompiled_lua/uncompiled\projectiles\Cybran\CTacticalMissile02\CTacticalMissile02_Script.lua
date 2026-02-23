-----------------------------------------------------------------------------
--  File     : /projectiles/cybran/ctacticalmissile02/ctacticalmissile02_script.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Cybran (LONG RANGE) Tactical Missile: CTacticalMissile02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

CTacticalMissile02 = Class(Projectile) {

    OnCreate = function(self)
        Projectile.OnCreate(self)

		-- Cache target position, since this projectile does not track targets
		self.cachedTargetPos = self:GetCurrentTargetPosition()
		if not self.cachedTargetPos then
			LOG( 'CTacticalMissile02 created with no target' )
			self.cachedTargetPos = Vector(0,0,0)
		end

        self:ForkThread( self.MovementThread )
    end,

    MovementThread = function(self)
        self.WaitTime = 0.1
        self:SetTurnRate(4)
        WaitSeconds(3)
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
        self:SetTurnRate(2000/dist)
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
TypeClass = CTacticalMissile02