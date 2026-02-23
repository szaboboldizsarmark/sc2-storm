-----------------------------------------------------------------------------
--  File     : /projectiles/uef/uclusterbomb02/uclusterbomb02_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Bomb: UClusterBomb02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
UClusterBomb02 = Class(import('/lua/sim/Projectile.lua').Projectile) {
    -- No damage dealt by this child.
    DoDamage = function(self, instigator, damageData, targetEntity)
    end,
}
TypeClass = UClusterBomb02