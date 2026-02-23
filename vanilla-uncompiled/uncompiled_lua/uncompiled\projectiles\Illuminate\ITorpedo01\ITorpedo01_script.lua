-----------------------------------------------------------------------------
--  File     :  /projectiles/illuminate/itorpedo01/itorpedo01_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate Torpedo: ITorpedo01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
ITorpedo01 = Class(Projectile) {
    OnCreate = function(self, inWater)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.0)
        Projectile.OnCreate(self, inWater)
    end,
}
TypeClass = ITorpedo01