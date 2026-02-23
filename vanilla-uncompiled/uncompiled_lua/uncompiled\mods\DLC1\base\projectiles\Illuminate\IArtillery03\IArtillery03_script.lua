-----------------------------------------------------------------------------
--  File     : /projectiles/UEF/IArtillery03/IArtillery03_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 UEF Artillery: IArtillery03
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local RandomFloat = import('/lua/system/utilities.lua').GetRandomFloat

IArtillery03 = Class(import('/lua/sim/Projectile.lua').Projectile) {
    OnImpact = function( self, targetType, targetEntity )
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
					self.DamageData.DamageAmount = (self.DamageData.DamageAmount * self.Data.ShieldMult) * absorbMul
					self:DoDamage( instigator, self.DamageData, targetEntity, passThrough )

                    targetEntity:DamageAbsorbed( self.DamageData.DamageAmount )

					-- Remove the absorbed damaged amount from the damage this projectile will do.
					self.DamageData.DamageAmount = initialDamage - (initialDamage * absorbMul)--self.DamageData.DamageAmount
				else
					local shieldHealth = targetEntity:GetHealth()
					local initialDamage = self.DamageData.DamageAmount
					self.DamageData.DamageAmount = (self.DamageData.DamageAmount * self.Data.ShieldMult)
					if shieldHealth < initialDamage and (not self.DamageData.DoTTime or self.DamageData.DoTTime <= 0) then
						passThrough = true
					end
					self:DoDamage( instigator, self.DamageData, targetEntity, passThrough )
					self.DamageData.DamageAmount = initialDamage - shieldHealth
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
			self:DoDamage( instigator, self.DamageData, targetEntity, false )
		end

        self:Destroy()
		self:ShakeCamera( 10, 1, 0.2, 0.3 )
    end,
}
TypeClass = IArtillery03