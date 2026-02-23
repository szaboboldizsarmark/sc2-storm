-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cantitorpedo01/cantitorpedo01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran AntiTorpedo: CAntiTorpedo01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
local DepthCharge = import('/lua/sim/antiprojectile.lua').DepthCharge

CAntiTorpedo01 = Class(Projectile) {
    FxTrails = {
		'/effects/emitters/weapons/cybran/antitorpedo01/projectile/anti_torpedo_flare_01_emit.bp',
		'/effects/emitters/weapons/cybran/antitorpedo01/projectile/anti_torpedo_flare_02_emit.bp',
	},
	FxEnterWater= EffectTemplates.WaterSplash01,
	TrailDelay = 5,

    OnCreate = function(self, inWater)
        Projectile.OnCreate(self)
        if inWater then
			local army = self:GetArmy()
			for i in self.FxTrails do
				CreateEmitterOnEntity(self, army, self.FxTrails[i])
			end
		end

        self:TrackTarget(false)
    end,

    EnterWaterThread = function(self)
        WaitTicks(self.TrailDelay)
        local army = self:GetArmy()
        for i in self.FxTrails do
            CreateEmitterOnEntity(self, army, self.FxTrails[i])
        end
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        Projectile.OnImpact(self, TargetType, TargetEntity)
        KillThread(self.TTT1)
    end,

    OnEnterWater = function(self)
        Projectile.OnEnterWater(self)
        local army = self:GetArmy()

        for k, v in self.FxEnterWater do --splash
            CreateEmitterAtEntity(self,army,v)
        end

        self:TrackTarget(false)
        self:StayUnderwater(true)
        self:SetTurnRate(0)
        self:SetMaxSpeed(1)
        self:SetVelocity(0, -0.25, 0)
        self:SetVelocity(0.25)

        self.TTT1 = self:ForkThread(self.EnterWaterThread)
    end,

    AddDepthCharge = function(self, tbl)
        if not tbl then return end
        if not tbl.Radius then return end
        self.MyDepthCharge = DepthCharge {
            Owner = self,
            Radius = tbl.Radius or 10,
        }
        self.Trash:Add(self.MyDepthCharge)
    end,
}
TypeClass = CAntiTorpedo01