-----------------------------------------------------------------------------
--  File     : /projectiles/Cybran/CNanobot01/CNanobot01_Script.lua
--  Author(s): Aaron Lundquist
--  Summary  : SC2 Cybran Nanobot Weapon: CNanobot01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat

CNanobot01 = Class(Projectile) {

    OnImpact = function(self, TargetType, TargetEntity)
        local ChildProjectileBP = '/projectiles/Cybran/CNanobotSplit01/CNanobotSplit01_proj.bp'
        
		-- Create several projectiles in a dispersal pattern
        local numProjectiles = 7
        local angle = (2*math.pi) / numProjectiles
        local angleInitial = RandomFloat( 0, angle )

        -- Randomization of the spread
        local angleVariation = angle * 2.0	-- Adjusts angle variance spread
        local spreadMul = 0.35				-- Adjusts the width of the dispersal

        local xVec = 0
        local yVec = 1
        local zVec = 0
        local velocity = 0        
        
        -- Launch projectiles at semi-random angles away from split location
        for i = 0, (numProjectiles -1) do
            xVec = (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            zVec = (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
            yVec = Random()
            local proj = self:CreateChildProjectile(ChildProjectileBP)
            proj:SetVelocity(xVec,yVec,zVec)
            velocity = RandomFloat( 10, 14 )
            proj:SetVelocity(velocity)
            proj:SetBallisticAcceleration(-20)
            proj:SetLifetime( RandomFloat( 1.3, 2.6 ) )
        end
       
		Projectile.OnImpact( self, TargetType, TargetEntity )
    end,
}
TypeClass = CNanobot01