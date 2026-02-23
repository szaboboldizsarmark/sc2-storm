-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cflamethrower01/cflamethrower01_script.lua
--  Author(s):	Gordon Duclos
--  Summary  :  SC2 Cybran Flame Thrower: CFlameThrower01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
CFlameThrower01 = Class(Projectile) {

	-- Custom directional impact effect.
	OnImpact = function( self, targetType, targetEntity )
	    Projectile.OnImpact(self, targetType, targetEntity)

	    -- Get velocity vector from projectile impact.
	    local vx, vy, vz = self:GetVelocity()

	    -- Zero out the vertical vector so that
	    -- our effect doesnt clip into the ground.
	    vy = 0

	    for k, v in EffectTemplates.Weapons.Cybran_Flamethrower01_Impact02 do
	        CreateEmitterPositionVector(self:GetPosition(), Vector(vx,vy,vz), -1, v )
	    end
	end,
}
TypeClass = CFlameThrower01