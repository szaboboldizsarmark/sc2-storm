-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/ctorpedo01/ctorpedo01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran Torpedo: CTorpedo01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
CTorpedo01 = Class(Projectile) {
    OnCreate = function(self, inWater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        Projectile.OnCreate(self, inWater)
    end,
}
TypeClass = CTorpedo01