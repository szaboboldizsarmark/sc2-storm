-----------------------------------------------------------------------------
--  File     :  /projectiles/debris/Cybran/UCX0112/UCX0112_Debris_Projectile_01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran: UCX0112 Debris Projectile 01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
UCX0112_Debris_Projectile_01 = Class(Projectile) {
    OnCreate = function(self)
        self:SetCollisionShape('Sphere', 0, 2, 0.5, 3.2)
        Projectile.OnCreate(self)
    end,
}
TypeClass = UCX0112_Debris_Projectile_01
