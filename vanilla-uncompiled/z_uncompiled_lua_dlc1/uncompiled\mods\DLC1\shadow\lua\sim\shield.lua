----------------------------------------------------------------------------
--  File     : /lua/sim/shield.lua
--  Author(s): Gordon Duclos
--  Summary  : Shield lua module
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Entity = import('/lua/sim/Entity.lua').Entity

Shield = Class(moho.shield_methods,Entity) {

    __init = function(self,spec)
        _c_CreateShield(self,spec)
    end,

    OnCreate = function(self,spec)
        self.Owner = spec.Owner

		-- Set any lua specific shield variables that need to be stored.
        self.AbsorbEnergySpongePercent = spec.AbsorbEnergySpongePercent or 0
		self.RechargeTime = spec.RechargeTime or nil
		self.ShieldType = spec.ShieldType
		self.ReflectRandomVector = spec.ReflectRandomVector or false

        if spec.ImpactEffects != '' then
			self.ImpactEffects = EffectTemplates[spec.ImpactEffects] or {}
		else
			self.ImpactEffects = {}
		end

		self:UpdateShieldValue()

        self.Owner:OnShieldEnabled()
		self.IsOn = true
    end,

    OnDestroy = function(self)
		self:UpdateShieldValue()
        self:Destroy()
    end,

    TurnOn = function(self)
		self:Activate()
		self:UpdateShieldValue()
        self.Owner:OnShieldEnabled()
		self.IsOn = true
    end,

    TurnOff = function(self)
		self:Deactivate()
        self:UpdateShieldValue()
		self.Owner:OnShieldDisabled()
		self.IsOn = false
    end,

    IsShieldActive = function(self)
        return self.IsOn
    end,

	OnShieldActivate = function(self)
        self:UpdateShieldValue()
        self.Owner:OnShieldEnabled()
		self.IsOn = true
	end,

    UpdateShieldValue = function(self)
        self.Owner:SetShieldCurrentValue(self:GetHealth())
        self.Owner:SetShieldMaxValue(self:GetMaxHealth())
    end,

    OnDamage =  function(self,instigator,amount,vector,type)
		if self.IsOn then
			-- If this shield converts energy from damage taken, then give energy based
			-- on the damage amount multiplied by the AbsorbEnergySpongePercent
			if self.AbsorbEnergySpongePercent > 0 then
				-- LOG( 'Converting Damage to Energy :', amount * self.AbsorbEnergySpongePercent )
				local aiBrain = self.Owner:GetAIBrain()
				aiBrain:GiveResource( 'ENERGY', amount * self.AbsorbEnergySpongePercent )
			end

			self:AdjustHealth(instigator, -amount)
			self:UpdateShieldValue()

			-- LOG('Shield Health: ' .. self:GetHealth())
			if self:GetHealth() <= 0 then
				self:Deactivate( self.RechargeTime, false )
				self.Owner:OnShieldDisabled()				
				self.IsOn = false
			elseif self.Owner and IsUnit(self.Owner) and not self.Owner:IsDead() then
				-- Activate any shield panels that my be on this impact vector.
				if self.ShieldType == 'Panel' then
					self:OnPanelImpact(vector)
				end

				self:CreateImpactEffect(vector)
			end
		end
    end,

    -- Note, this is called by native code to calculate spillover damage. The
    -- damage logic will subtract this value from any damage it does to units
    -- under the shield. The default is to always absorb as much as possible
    -- but the reason this function exists is to allow flexible implementations
    -- like shields that only absorb partial damage (like armor).
    OnGetDamageAbsorption = function(self,instigator,amount,type)
        --LOG('absorb: ', math.min( self:GetHealth(), amount ))

        -- Like armor damage, first multiply by armor reduction, then apply handicap
        -- See SimDamage.cpp (DealDamage function) for how this should work
        amount = amount * (self.Owner:GetArmorMult(type))
        amount = amount * ( 1.0 - ArmyGetHandicap(self:GetArmy()) )
        return math.min( self:GetHealth(), amount )
    end,

    DamageAbsorbed = function(self,damage)
        self.Owner:ShieldDamageAbsorbed(damage)
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)

        if not self:IsShieldActive() then
            return false
        end

		local weaponBP = firingWeapon:GetBlueprint()
        local collide = weaponBP.CollideFriendly
        if collide == false then
            if not ( IsEnemy(self:GetArmy(),firingWeapon.unit:GetArmy()) ) then
                return false
            end
        end

        --Check DNC list
        if weaponBP.DoNotCollideList then
			for k, v in pairs(weaponBP.DoNotCollideList) do
				if EntityCategoryContains(ParseEntityCategory(v), self) then
					return false
				end
			end
		end

        return true
    end,

    GetOverkill = function(self,instigator,amount,type)
        --LOG('absorb: ', math.min( self:GetHealth(), amount ))

        -- Like armor damage, first multiply by armor reduction, then apply handicap
        -- See SimDamage.cpp (DealDamage function) for how this should work
        amount = amount * (self.Owner:GetArmorMult(type))
        amount = amount * ( 1.0 - ArmyGetHandicap(self:GetArmy()) )
        local finalVal =  amount - self:GetHealth()
        if finalVal < 0 then
            finalVal = 0
        end
        return finalVal
    end,

    OnReflectProjectile = function(self, other)
        other:SetCollideFriendly(true)
		other.DamageData.DamageFriendly = true
		other.DamageData.DamageSelf = true
		
		local x, y, z = other:GetProjectileVelocity()
		local relectMul = 1
		
		self:CreateImpactEffect(other:GetPosition())

		if self.ReflectRandomVector then
			x = x + (relectMul * ((Random() * 2) - 1))
			y = z + (relectMul * ((Random() * 2) - 1))
			z = z + (relectMul * ((Random() * 2) - 1))
		end
		other:SetVelocityAlign(true)
		other:TrackTarget(false)
		other:SetVelocity(-x,-y,-z)
		other:SetVelocity(12)
		other:SetLifetime(5)
		other:SetReflected(self)
    end,

	SetAbsorbEnergySpongePercent = function( self, amount )
		self.AbsorbEnergySpongePercent = amount
	end,

	-- Create impact effect at impact position with impact orientation
    CreateImpactEffect = function(self, vector)
		local pos = table.copy(self:GetPosition())
		local army = self:GetArmy()
		pos[1] = pos[1] - vector.x
		pos[2] = pos[2] - vector.y
		pos[3] = pos[3] - vector.z

		for k, v in self.ImpactEffects do
			CreateEmitterPositionVector(pos,vector,army, v )
		end
    end,
}