-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/UArtillery05/UArtillery05_script.lua
--  Author(s): Aaron Lundquist, Gordon Duclos
--  Summary  : SC2 UEF Artillery Child Shell: UArtillery05
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

UArtillery05 = Class(Projectile) {
    OnCreate = function(self)
        Projectile.OnCreate(self)
        
        -- Add a tumble/spin to projectiles to simulate cluster bomblets
        self:SetLocalAngularVelocity(Random(-10,10), Random(-10,10), Random(-10,10))
    end,
}
TypeClass = UArtillery05