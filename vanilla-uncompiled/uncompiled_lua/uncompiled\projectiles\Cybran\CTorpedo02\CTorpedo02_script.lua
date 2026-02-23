-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/ctorpedo02/ctorpedo02_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Torpedo: CTorpedo02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

CTorpedo02 = Class(Projectile) {
    TrailDelay = 0,

    OnCreate = function(self, inWater)
        Projectile.OnCreate(self, inWater)
        self:ForkThread( self.MovementThread )
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
    end,

    MovementThread = function(self)
        while not self:BeenDestroyed() and (self:GetDistanceToTarget() > 8) do
            WaitSeconds(0.25)
        end
        if not self:BeenDestroyed() then
			self:ChangeMaxZigZag(0)
			self:ChangeZigZagFrequency(0)
		end
    end,

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
		local dist = 0
		if tpos then
			local mpos = self:GetPosition()
			local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
		end
        return dist
    end,

    OnEnterWater = function(self)
        Projectile.OnEnterWater(self)
        self:StayUnderwater(true)
        self:TrackTarget(true)
        self:SetTurnRate(120)
        self:SetMaxSpeed(18)
        self:SetVelocity(3)
    end,
}
TypeClass = CTorpedo02