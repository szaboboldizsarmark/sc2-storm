-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/utacticalmissile02/utacticalmissile02_script.lua
--  Author(s):	Gordon Duclos, Aaron Lundquist, Eric Williamson
--  Summary  :  SC2 UEF (LONG RANGE) Tactical Missile: UTacticalMissile02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

UTacticalMissile02 = Class(Projectile) {

    OnCreate = function(self)
        Projectile.OnCreate(self)

		-- Cache target position, since this projectile does not track targets
		self.cachedTargetPos = self:GetCurrentTargetPosition()
		if not self.cachedTargetPos then
			LOG( 'ITacticalMissile01 created with no target' )
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
}
TypeClass = UTacticalMissile02