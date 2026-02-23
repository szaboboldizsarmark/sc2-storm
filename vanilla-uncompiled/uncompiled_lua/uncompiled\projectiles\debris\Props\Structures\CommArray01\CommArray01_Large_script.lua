-----------------------------------------------------------------------------
--  File     :  /projectiles/debris/Props/Structures/CommArray01/CommArray01_Large_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate: CommArray Large Projectile
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
CommArray01_Large = Class(Projectile) {
    OnCreate = function(self)
        self:SetCollisionShape('Sphere', 0, 2, 0.5, 3.2)
        Projectile.OnCreate(self)
    end,
}
TypeClass = CommArray01_Large