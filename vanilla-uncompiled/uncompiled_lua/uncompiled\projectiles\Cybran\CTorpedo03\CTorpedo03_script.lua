-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/ctorpedo03/ctorpedo03_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Torpedo: CTorpedo03
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
CTorpedo03 = Class(Projectile) {
    OnCreate = function(self, inWater)
        Projectile.OnCreate(self, inWater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)

        if inWater then
            self:SetBallisticAcceleration(0)
        else
            self:SetBallisticAcceleration(-20)
            self:TrackTarget(false)
            self:SetTurnRate(0)
        end
    end,

    OnEnterWater = function(self)
        Projectile.OnEnterWater(self)
        self:SetBallisticAcceleration(0)
        self:SetTurnRate(120)
        self:TrackTarget(true)
    end,
}

TypeClass = CTorpedo03