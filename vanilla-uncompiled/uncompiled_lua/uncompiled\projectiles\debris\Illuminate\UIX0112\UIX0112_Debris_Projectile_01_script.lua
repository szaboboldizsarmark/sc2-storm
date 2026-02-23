-----------------------------------------------------------------------------
--  File     :  /projectiles/debris/Illuminate/UIB0001/UIB0001_Tower_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate: UIX0112 Debris Projectile 01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
UIX0112_Debris_Projectile_01 = Class(Projectile) {
    OnCreate = function(self)
        self:SetCollisionShape('Sphere', 0, 2, 0.5, 3.2)
        Projectile.OnCreate(self)
    end,
}
TypeClass = UIX0112_Debris_Projectile_01
