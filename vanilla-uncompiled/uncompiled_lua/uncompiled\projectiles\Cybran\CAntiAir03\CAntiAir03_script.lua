-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cantiair03/cantiair03_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran AntiAir: CAntiAir03
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
CAntiAir03 = Class(Projectile) {
    OnCreate = function(self)
        Projectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,

    UpdateThread = function(self)
        WaitSeconds(0.1)
        self:SetMaxSpeed(10)
        --self:SetBallisticAcceleration(-0.5)

        WaitSeconds(0.1)
        self:SetMesh('/projectiles/Cybran/CAntiAir03/CAntiAirUnpacked03_mesh')
        self:SetMaxSpeed(50)
        self:SetAcceleration(15 + Random() * 5)

        WaitSeconds(0.1)
        self:SetTurnRate(360)

    end,
}

TypeClass = CAntiAir03
