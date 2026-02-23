-----------------------------------------------------------------------------
--  File     : /effects/Entities/IlluminateEMPEffectController01/IlluminateEMPEffectController01.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : EMP Damage Controller and Effect Visuals
--  Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local Util = import('/lua/system/utilities.lua')
local RandomFloat = Util.GetRandomFloat
local GetRandomInt = Util.GetRandomInt

IlluminateEMPEffectController01 = Class(Projectile) {
   
    OnCreate = function(self, inWater)
        Projectile.OnCreate(self, inWater)

        self.UseNukeDecal = true
    end,
   
    -- NOTE: This script has been modified to REQUIRE that data is passed in!  The EMP won't detonate until this happens!
    --OnCreate = function(self)
    PassData = function(self, Data)
		-- Setup default values for incoming nuke data if it doesn't exist
		self.EMPRadius = Data.EMPRadius or 10
		self.EMPDuration = Data.EMPDuration or 5
		self.StunDuration = Data.StunDuration or 0
		self.StunRadius = Data.StunRadius or 0
		self:ForkThread(self.DoEMPStun)

        self:CreateEMPExplosion()
    end,

    DoEMPStun = function(self)
		local position = self:GetPosition()
        local instigator = self:GetLauncher()
        if instigator == nil then
            instigator = self
        end
		
		local brain = instigator:GetAIBrain()		
		local shields = brain:GetUnitsAroundPoint( categories.SHIELD + categories.SHIELDUPGRADE + categories.SHIELDADDON, position, self.EMPRadius, 'Enemy' )

		for _,v in shields do
			if v:IsDead() then continue end
			local shield = v:GetShield()
			if shield then
				if not shield.RechargeTime or shield.RechargeTime <= 0 then
					shield:Deactivate( nil, true )
				else
					shield:Deactivate( self.EMPDuration, true )
				end
				v:OnShieldDisabled()				
				shield.IsOn = false
			end
		end

		if self.StunDuration > 0 then
			StunArea( self:GetArmy(), position, self.StunRadius, 100.0, self.StunDuration, false )
		end		
    end,

    CreateEMPExplosion = function(self)
        local myBlueprint = self:GetBlueprint()

        -- Play the "EMP Explosion" sound
        if myBlueprint.Audio.EMPExplosion then
            self:PlaySound(myBlueprint.Audio.EMPExplosion, false)
        end

		-- Create thread that spawns and controls effects
        self:ForkThread(self.EffectThread)
    end,    

    EffectThread = function(self)
        local army = -1
        local position = self:GetPosition()

        -- Create light at location
        local lightHandle = CreateLight( position[1], position[2]+25, position[3], 0, -1, 0, 100, 5, 0.1, 3, 5 )
        
        -- Base flash, glow and shockwave
		for k, v in EffectTemplates.Weapons.Illuminate_EMP_Impact01 do
			  CreateEmitterAtEntity(self, army, v ) 
		end
    end,
}
TypeClass = IlluminateEMPEffectController01