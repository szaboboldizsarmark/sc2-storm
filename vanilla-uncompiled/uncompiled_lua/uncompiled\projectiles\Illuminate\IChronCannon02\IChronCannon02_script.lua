-----------------------------------------------------------------------------
--  File     : /projectiles/Illuminate/IChronCannon02/IChronCannon02_script.lua
--  Author(s): Matt Vainio, Gordon Duclos
--  Summary  : Chronatron Cannon Projectile script, UIL0001
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

IChronCannon02 = Class(Projectile) {

    -- Custom directional impact effect.
	OnImpact = function( self, targetType, targetEntity )
	    Projectile.OnImpact(self, targetType, targetEntity)

	    -- Get velocity vector from projectile impact.
	    local vx, vy, vz = self:GetVelocity()

	    -- Zero out the vertical vector so that
	    -- our effect doesnt clip into the ground.
	    vy = 0

	    for k, v in EffectTemplates.Weapons.Illuminate_ChronCannon02_Impact02 do
	        CreateEmitterPositionVector(self:GetPosition(), Vector(vx,vy,vz), -1, v )
	    end
	end,
}
TypeClass = IChronCannon02