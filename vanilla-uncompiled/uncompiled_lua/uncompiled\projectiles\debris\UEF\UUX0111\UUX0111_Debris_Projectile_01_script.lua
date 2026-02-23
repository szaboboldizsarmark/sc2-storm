-----------------------------------------------------------------------------
--  File     :  /projectiles/debris/Illuminate/UIB0001/UIB0001_Tower_script.lua
--  Author(s):  Aaron Lundquist
--  Summary  :  SC2 Illuminate: UUX0111 Debris Projectile 01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
UUX0111_Debris_Projectile_01 = Class(Projectile) {
    OnCreate = function(self)
        self:SetCollisionShape('Sphere', 0, 2, 0.5, 3.2)
        Projectile.OnCreate(self)
    end,
}
TypeClass = UUX0111_Debris_Projectile_01
