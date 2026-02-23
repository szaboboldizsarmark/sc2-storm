-----------------------------------------------------------------------------
--  File     : /projectiles/uef/utorpedo02/utorpedo02_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Torpedo: UTorpedo02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

UTorpedo02 = Class(Projectile) {
    OnCreate = function(self, inWater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        Projectile.OnCreate(self, inWater)
		self:TrackTarget(false)
		self:SetBallisticAcceleration( -14.8 )
    end,

    OnEnterWater = function(self)
        Projectile.OnEnterWater(self)
		self:SetBallisticAcceleration( 0 )
		self:SetVelocity( 0 )
		self:SetTurnRate(180)
        self:TrackTarget(true)
        self:StayUnderwater(true)
    end,
}
TypeClass = UTorpedo02