-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/utorpedo01/utorpedo01_script.lua
--  Author(s):
--  Summary  :  SC2 UEF Torpedo: UTorpedo01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
UTorpedo01 = Class(Projectile) {
    OnCreate = function(self, inWater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        Projectile.OnCreate(self, inWater)
    end,
}
TypeClass = UTorpedo01