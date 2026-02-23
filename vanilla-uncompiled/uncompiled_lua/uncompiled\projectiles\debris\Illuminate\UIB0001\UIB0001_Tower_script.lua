-----------------------------------------------------------------------------
--  File     :  /projectiles/debris/Illuminate/UIB0001/UIB0001_Tower_script.lua
--  Author(s):
--  Summary  :  SC2 Illuminate: UIB0001 Tower Projectile
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
UIB0001_Tower = Class(Projectile) {
    OnCreate = function(self)
        self:SetCollisionShape('Sphere', 0, 2, 0.5, 3.2)
        Projectile.OnCreate(self)
    end,
}
TypeClass = UIB0001_Tower