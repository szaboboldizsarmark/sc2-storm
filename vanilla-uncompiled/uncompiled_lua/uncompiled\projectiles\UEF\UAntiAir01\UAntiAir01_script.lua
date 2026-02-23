-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/uantiair01/uantiair01_script.lua
--  Author(s):
--  Summary  :  SC2 UEF AntiAir: UAntiAir01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
UAntiAir01 = Class(Projectile) {
    OnCreate = function(self)
        Projectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,

    UpdateThread = function(self)
        WaitSeconds(0.35)
        self:SetMaxSpeed(2)
        self:SetBallisticAcceleration(-0.5)

        WaitSeconds(0.5)
        self:SetMesh('/projectiles/UEF/UAntiAir01/UAntiAirUnpacked01_mesh')
        self:SetMaxSpeed(50)
        self:SetAcceleration(8 + Random() * 5)

        WaitSeconds(0.3)
        self:SetTurnRate(360)

    end,
}

TypeClass = UAntiAir01