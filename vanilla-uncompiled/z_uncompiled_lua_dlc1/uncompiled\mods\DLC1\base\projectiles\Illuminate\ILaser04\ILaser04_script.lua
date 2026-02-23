-----------------------------------------------------------------------------
--  File     :  /projectiles/illuminate/ilaser04/ilaser04_script.lua
--  Author(s):	Aaron Lundquist
--  Summary  :  SC2 Illuminate Experimental Gunship Laser: ILaser04
--  Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
ILaser04 = Class(Projectile) {

-- Custom directional impact effect.
OnImpact = function( self, targetType, targetEntity )
    Projectile.OnImpact(self, targetType, targetEntity)

    -- Get velocity vector from projectile impact.
    local vx, vy, vz = self:GetVelocity()

    -- Zero out the vertical vector so that
    -- our effect doesnt clip into the ground.
    vy = 0

    for k, v in EffectTemplates.Weapons.Illuminate_Plasma02_Impact02 do
        CreateEmitterPositionVector(self:GetPosition(), Vector(vx,vy,vz), -1, v )
    end
end,

}
TypeClass = ILaser04