-----------------------------------------------------------------------------
--  File     : /lua/sim/Projectile.lua
--  Author(s): John Comes, Gordon Duclos, Matt Vainio
--  Summary  : Base projectile class
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Entity = import('/lua/sim/Entity.lua').Entity
local DefaultDamage = import('/lua/sim/damage.lua')
local Utilities = import('/lua/system/utilities.lua')
local Flare = import('/lua/sim/antiprojectile.lua').Flare

Projectile = Class(moho.projectile_methods, Entity) {

    -- Do not call the base class __init and __post_init, we already have a c++ object
    __init = function(self,spec)
    end,
    __post_init = function(self,spec)
    end,

    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,

    OnCreate = function(self, inWater)
        self.DamageData = {
            DamageRadius = nil,
            DamageAmount = nil,
            DamageType = nil,
            DamageFriendly = nil,
        }
        self.Trash = TrashBag()
        local bp = self:GetBlueprint()

        local snd = bp.Audio.ExistLoop
        if snd then
            self:SetAmbientSound(snd, nil)
        end

        -- Create all attached effects for this projectile
        local EffectsBp = bp.Effects
        if EffectsBp then
            if EffectsBp.Emitters and (EffectsBp.Emitters.Template and EffectsBp.Emitters.Template != '' ) then
                AttachEffectsOnProjectile( self, EffectsBp.Emitters.Template, EffectsBp.Emitters.Scale, EffectsBp.Emitters.Offset )
			end

            if EffectsBp.Beams and (EffectsBp.Beams.Template and EffectsBp.Beams.Template  != '' ) then
                AttachBeamsOnProjectile( self, EffectsBp.Beams.Template, EffectsBp.Beams.Scale, EffectsBp.Beams.Offset )
            end
            if EffectsBp.PolyTrails and (EffectsBp.PolyTrails.Template and EffectsBp.PolyTrails.Template != '' ) then
                AttachPolytrailsOnProjectile( self, EffectsBp.PolyTrails.Template, EffectsBp.PolyTrails.Scale, EffectsBp.PolyTrails.Offset )
            end
        end

		self.Reflected = nil
		self.CanTakeDamage = true
    end,
	
    SetCanTakeDamage = function(self, val)
        self.CanTakeDamage = val
    end,

    CheckCanTakeDamage = function(self)
        return self.CanTakeDamage
    end,

    OnDamage = function(self, instigator, amount, vector, damageType)
        -- check for valid projectile
        if not self or self:BeenDestroyed() or not self.CanTakeDamage then
            return
        end
        
        local health = self:GetHealth()
        self:AdjustHealth(instigator, -amount)
        local health = self:GetHealth()
        
        if( health <= 0 ) then
            local excessDamageRatio = 0.0
            -- Calculate the excess damage amount
            local excess = health - amount
            local maxHealth = self:GetBlueprint().Defense.MaxHealth or 10
            if(excess < 0 and maxHealth > 0) then
                excessDamageRatio = -excess / maxHealth
            end
            --self:Kill(instigator, damageType, excessDamageRatio)
            self:OnKilled(instigator, damageType, excessDamageRatio)
        end		
    end,

    OnDestroy = function(self)
        if self.Trash then
            self.Trash:Destroy()
        end
    end,

    -----------------------------------------------
    -- Altered OnKilled to remove effects when killed by another
    -- projectile, can add back in later if we need - mvainio 01/12/09
    -----------------------------------------------
    OnKilled = function(self)
        self:Destroy()
    end,

    DoDamage = function(self, instigator, damageData, targetEntity, fireAOE)
        local damage = damageData.DamageAmount

		--LOG( 'Projectile:DoDamage ', damage )
	    --LOG( 'Critchance = ', damageData.CriticalChance )

		-- Modify damage amount if this projectile can trigger a critical hit
		if damageData.CriticalChance > 0 then
			if Random(1,100) <= damageData.CriticalChance then
				damage = math.floor( damage * damageData.CriticalDamageMultiplier )
			end
		end

		-- Perform damage in an area, possibly over time
		local radius = damageData.DamageRadius

        if radius and radius > 0 and fireAOE then
			if not damageData.DoTTime or damageData.DoTTime <= 0 then
				if damage and damage > 0 then
					DamageArea(instigator, self:GetPosition(), radius, damage, damageData.DamageType, damageData.DamageFriendly, damageData.DamageSelf or false)
				end
			else
				ForkThread(DefaultDamage.AreaDoTThread, instigator, self:GetPosition(), damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly)
			end
			if damageData.StunChance > 0 then
				StunArea( self:GetArmy(), self:GetPosition(), radius, damageData.StunChance, damageData.StunDuration, damageData.DamageFriendly )
			end
		else
			-- Early out, if we don't have a valid entity to damage
			if not targetEntity then
				return
			end

			if damageData.StunChance > 0 then
				if Random(1,100) <= damageData.StunChance then
					if IsUnit( targetEntity ) then
						targetEntity:SetStunned(damageData.StunDuration or 1)
					end
				end
			end

			if damage and damage > 0 then
				--ONLY DO DAMAGE IF THERE IS DAMAGE DATA.  SOME PROJECTILE DO NOT DO DAMAGE WHEN THEY IMPACT.
				if damageData.DamageAmount then
					if not damageData.DoTTime or damageData.DoTTime <= 0 then
						Damage(instigator, self:GetPosition(), targetEntity, damageData.DamageAmount, damageData.DamageType)
					else
						ForkThread(DefaultDamage.UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly)
					end
				end
			end
		end

        if( targetEntity and targetEntity.PerformKnockback and (damageData.KnockbackDistance > 0) ) then
            local randRange = damageData.KnockbackDistanceRand or 0

            if not damageData.KnockbackRadius then
                targetEntity:PerformKnockback( instigator, damageData.KnockbackDistance + Utilities.GetRandomFloat(-randRange, randRange), (damageData.KnockbackScale or 5) )
            else
                local brain = instigator:GetAIBrain()
                local units = brain:GetUnitsAroundPoint( categories.LAND * categories.MOBILE, targetEntity:GetPosition(), damageData.KnockbackRadius, 'Enemy' )

                for index,enemyUnit in units do
					if enemyUnit.PerformKnockback then
						enemyUnit:PerformKnockback( instigator, damageData.KnockbackDistance + Utilities.GetRandomFloat(-randRange, randRange), (damageData.KnockbackScale or 5) )
					end
                end
            end
        end
    end,

    -- Projectile has impacted with something (or nothing)
    --
    -- Possible 'targetType' values are:
    -- 'Unit', 'Terrain', 'Water', 'Air', 'Prop', 'Shield', 'UnitAir', 'UnderWater', 'UnitUnderwater', 'Projectile', 'ProjectileUnderWater
    --
    OnImpact = function( self, targetType, targetEntity )
        --LOG('*DEBUG: ', self:GetBlueprint().BlueprintId, ' IMPACT, TYPE = ', repr(targetType) )

        -- Try to use the launcher as instigator first. If its been deleted, use ourselves (this
        -- projectile is still associated with an army)
        local instigator = self:GetLauncher()
        if instigator == nil then
            instigator = self
        end

		self:DoImpactEffects(targetType,targetEntity)

        -- Sounds for all other impacts, ie: Impact<TargetTypeName>
        local bpAud = self:GetBlueprint().Audio
        local snd = bpAud['Impact'..targetType]
        if snd then
            self:PlaySound(snd)
            --Generic Impact Sound
        elseif bpAud.Impact then
            self:PlaySound(bpAud.Impact)
        end

		-- SC2 - Projectile damage reduction for shields with damage absorption, this will be changed
		-- with up coming projectile/shield optimizations
		if targetType == 'Shield' then

			-- If our target entity is no longer valid, early out.
			if not targetEntity then
				return
			end
			
			local passThrough = false

			if self.DamageData.DamageAmount then
				local absorbMul = 0 
                if targetEntity.Owner and not targetEntity.Owner:IsDead() then
                    absorbMul = targetEntity:GetAbsorbPercent()
                end
				if absorbMul > 0 then
					-- Calculate our absorption and the correct damage to what we impacted
					local initialDamage = self.DamageData.DamageAmount
                    passThrough = true
					self.DamageData.DamageAmount = self.DamageData.DamageAmount * absorbMul
					self:DoDamage( instigator, self.DamageData, targetEntity, false )

                    targetEntity:DamageAbsorbed( self.DamageData.DamageAmount )

					-- Remove the absorbed damaged amount from the damage this projectile will do.
					self.DamageData.DamageAmount = initialDamage - self.DamageData.DamageAmount
				else
					local shieldHealth = targetEntity:GetHealth()
					if shieldHealth < self.DamageData.DamageAmount and (not self.DamageData.DoTTime or self.DamageData.DoTTime <= 0) then
						passThrough = true
					end
					self:DoDamage( instigator, self.DamageData, targetEntity, false )
					self.DamageData.DamageAmount = self.DamageData.DamageAmount - shieldHealth
				end
			end

			-- If we have already impacted the same reflection shield or penetrated it, do nothing.
			if self.Reflected == targetEntity  then
				return
			end
			
			if passThrough then 
				return
			end
		else
			self:DoDamage( instigator, self.DamageData, targetEntity, true )
		end

        self:Destroy()
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)
		-- if this unit category is on the weapon's do-not-collide list, skip!
		local weaponBP = firingWeapon:GetBlueprint()
		if weaponBP.DoNotCollideList then
			for k, v in pairs(weaponBP.DoNotCollideList) do
				if EntityCategoryContains(ParseEntityCategory(v), self) then
					return false
				end
			end
		end
        return true
    end,

    DoImpactEffects = function(self,targetType,targetEntity)
        local EffectsBp = self:GetBlueprint().Effects

        if EffectsBp and EffectsBp.Impacts then
            local impactEffect = EffectsBp.Impacts[targetType]
            --LOG ('impactEffect = ', repr(impactEffect))
            --LOG ('impactEffect.Template = ', repr(impactEffect.Template))

            if impactEffect and (impactEffect.Template and impactEffect.Template != '') then
                CreateImpactEffectsOnProjectileCollision( self, impactEffect.Template, impactEffect.Scale, impactEffect.Offset, impactEffect.TrajectoryAligned or false  )
            end

            CreateTerrainImpactEffects( self, targetType, EffectsBp.TerrainClass )
        end
    end,

    PassData = function(self, data)
        self.Data = table.copy(data)
    end,

    PassDamageData = function(self, damageData)
		self.DamageData = damageData
    end,

    OnExitWater = function(self)
        local bp = self:GetBlueprint().Audio['ExitWater']
        if bp then
            self:PlaySound(bp)
        end
    end,

    OnEnterWater = function(self)
        local bp = self:GetBlueprint().Audio['EnterWater']
        if bp then
            self:PlaySound(bp)
        end
    end,

    OnLostTarget = function(self)
        local bp = self:GetBlueprint().Physics
        if (bp.TrackTarget and bp.TrackTarget == true) then
            if (bp.OnLostTargetLifetime) then
                self:SetLifetime(bp.OnLostTargetLifetime)
            else
                self:SetLifetime(0.5)
            end
        end
    end,

	-- Currently the way projectile positions are calculated, the projectile is actually past the
	-- shield collision volume when this event occurs. Hence causing the projectile to bounce back
	-- and forth indefinitely due to this imprecision. Will fix this in a optimization pass of lua
	-- scripts when these interfaces are migrated to code.
	HasReflected = function(self)
		return self.Reflected
	end,

	SetReflected = function(self, entityReflecting )
		self.Reflected = entityReflecting
	end,
}

FlareProjectile = Class(Projectile){
	    
    AddFlare = function(self, tbl)
        if not tbl then return end
        if not tbl.Radius then return end
        self.MyFlare = Flare {
            Owner = self,
            Radius = tbl.Radius or 5,
            RedirectCat = tbl.Category or 'MISSILE',
            RedirectCount = tbl.RedirectCount or 3,
        }
        self.Trash:Add(self.MyFlare)
    end,
}