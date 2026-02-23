-----------------------------------------------------------------------------
--  File     :  /projectiles/uef/uantiair04/uantiair04_script.lua
--  Author(s):
--  Summary  :  SC2 UEF AntiAir: UAntiAir04
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
UAntiAir04 = Class(Projectile) {
    OnCreate = function(self)
        Projectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,

    UpdateThread = function(self)
        WaitSeconds(1)
        self:SetMaxSpeed(3)
        self:SetBallisticAcceleration(-0.5)

        WaitSeconds(0.5)
        self:CreateThrustEffects()
        self:SetMesh('/projectiles/UEF/UAntiAir04/UAntiAirUnpacked04_mesh')
        self:SetMaxSpeed(50)
        self:SetAcceleration(8 + Random() * 5)

        WaitSeconds(0.3)
        self:SetTurnRate(360)

    end,

    CreateThrustEffects = function(self)
		for k, v in EffectTemplates.Weapons.UEF_Cruisemissile04_Trails02 do
			CreateAttachedEmitter ( self, -1, self:GetArmy(), v )
		end

		for k, v in EffectTemplates.Weapons.UEF_Cruisemissile04_Polytrails02 do
			CreateTrail( self, -1, self:GetArmy(), v )
		end
	end,
}

TypeClass = UAntiAir04