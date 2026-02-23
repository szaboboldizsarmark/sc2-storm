-----------------------------------------------------------------------------
--  File     : /projectiles/uef/uantiairmissile02/uantiairmissile02_script.lua
--  Author(s): Matt Vainio
--  Summary  : SC2 UEF AntiAir Fighter Missile: UAntiAirMissile02
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

UAntiAirMissile02 = Class(Projectile) {
    OnCreate = function(self)
        Projectile.OnCreate(self)

        -- Missile movement thread
        self:ForkThread(self.UpdateThread)
    end,

    OnLostTarget = function(self)
        Projectile.OnLostTarget(self)

        self:TrackTarget(false)
        self:SetBallisticAcceleration(-12)
        self:SetAcceleration(-45)
        self:SetLocalAngularVelocity(Random(-10,10), Random(-10,10), Random(-10,10))
        self:SetVelocityAlign(false)
        self:ChangeMaxZigZag(0)
		self:ChangeZigZagFrequency(0)
    end,

    UpdateThread = function(self)
        -- Slow down projectile after initial launch before boosters fire
        self:SetAcceleration(-15)               -- -35 original tuning
        self:SetBallisticAcceleration(-45)      -- -15 original tuning

        -- Pause before launching, create booster ignition effects + trails
        WaitSeconds(0.3)
        for k, v in EffectTemplates.Weapons.UEF_Airmissile01_Trails01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v )
		end
		for k, v in EffectTemplates.Weapons.UEF_Airmissile01_Polytrails01 do
			CreateTrail( self, -1, self:GetArmy(), v )
		end

		-- Set accelerations
		self:SetAcceleration(15)         -- 15 original tuning
		self:SetBallisticAcceleration(0)

		-- Set missile rotation and zigzag
		self:ChangeMaxZigZag(35)
		self:ChangeZigZagFrequency(0.2)

		-- Set velocity
        self:SetVelocity(30)             -- 20 original tuning

		-- After ignition, turn on alignment and target tracking
		self:SetVelocityAlign(true)
		self:TrackTarget(true)
    end,

}
TypeClass = UAntiAirMissile02