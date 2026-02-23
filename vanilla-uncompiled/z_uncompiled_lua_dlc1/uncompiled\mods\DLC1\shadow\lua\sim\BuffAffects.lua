-----------------------------------------------------------------------------
--  File     : /lua/sim/BuffAffects.lua
--  Author(s): Gordon Duclos
--  Summary  : Buff implementation function table
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

BuffAffects = {

	AntiMissileCapacity = function( unit, buffName )
	end,

    ArmorBoostCapacity = function( unit, buffName )
	end,

    BuildRate = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'BuildRate', unit:GetBlueprint().Economy.BuildRate or 1)
        unit:SetBuildRate( val )
	end,

	-- Multiplier that reduces the time of a builder unit to build another unit
    BuildTime = function( unit, buffName )
		local val = BuffCalculate(unit, buffName, 'BuildTime', unit:GetBlueprint().Economy.BuildTimeMultiplier or 1)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'BuildTime buffed to ', val )
		unit:SetBuildTimeMultiplier(val)
	end,

	-- Multiplier that reduces the energy cost of a builder unit to build all units.
	BuildCostEnergy = function( unit, buffName )
		local val = BuffCalculate(unit, buffName, 'BuildCostEnergy', unit:GetBlueprint().Economy.BuildEnergyCostMultiplier or 1)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'BuildCostEnergy buffed to ', val )
		unit:SetBuildCostMultiplier('ENERGY', val)
	end,

	-- Multiplier that reduces the mass cost of a builder unit to build all units.
	BuildCostMass = function( unit, buffName )
		local val = BuffCalculate(unit, buffName, 'BuildCostMass', unit:GetBlueprint().Economy.BuildMassCostMultiplier or 1)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'BuildCostMass buffed to ', val )
		unit:SetBuildCostMultiplier('MASS', val)
	end,

    CaptureRate = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'CaptureRate', 1)
        unit:SetCaptureRate(val)
        --LOG('*BUFF: CaptureRate = ' .. val)
	end,

	-- Weapon buff
    CriticalChance = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local val = BuffCalculate(unit, buffName, 'CriticalChance', vWeapon:GetBlueprint().CriticalChance or 0 )
					vWeapon:SetCriticalChance(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'weapon CriticalChance buffed to ', repr(val))
				end
			--else
				--LOG( 'Warning CriticalChance weapon buff ', buffName, ', buff definition specified invalid weapon category ', weaponCategory, '.' )
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				local val = BuffCalculate(unit, buffName, 'CriticalChance', wep:GetBlueprint().CriticalChance or 0 )
				wep:SetCriticalChance(val)
				--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'weapon CriticalChance buffed to ', repr(val))
			end
		end
	end,

	-- Weapon buff (Needs to be converted to single weapon buff)
    Damage = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local val = BuffCalculate(unit, buffName, 'Damage', vWeapon:GetBlueprint().Damage )
		    
					if val >= ( math.abs(val) + 0.5 ) then
						val = math.ceil(val)
					else
						val = math.floor(val)
					end

					vWeapon:ChangeDamage(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed damage to ', repr(val))
				end
			--else
				--LOG( 'Warning WeaponRange weapon buff ', buffName, ', buff definition specified invalid weapon category ', weaponCategory, '.' )
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				if wep.Label != 'DeathWeapon' and wep.Label != 'DeathImpact' then
					local val = BuffCalculate(unit, buffName, 'Damage', wep:GetBlueprint().Damage )
	        
					if val >= ( math.abs(val) + 0.5 ) then
						val = math.ceil(val)
					else
						val = math.floor(val)
					end
	    
					wep:ChangeDamage(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed damage to ', repr(val))
				end
			end
		end
	end,

	-- Weapon buff
    DamageRadius = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local val = BuffCalculate(unit, buffName, 'DamageRadius', vWeapon:GetBlueprint().DamageRadius or 0 )
					vWeapon:ChangeDamageRadius(val)
				end
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				if wep.Label != 'DeathWeapon' and wep.Label != 'DeathImpact' then
					local val = BuffCalculate(unit, buffName, 'DamageRadius', wep:GetBlueprint().DamageRadius or 0 )
					wep:ChangeDamageRadius(val)
				end
			end
		end
	end,

	DamageReduction = function( unit, buffName )
		local val = BuffCalculate(unit, buffName, 'DamageReduction', 1)
        unit:SetDamageReductionMultiplier(val)
	end,

	EnergyProduction = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'EnergyProduction', unit:GetBlueprint().Economy.ProductionPerSecondEnergy or 1 )
        unit:SetProductionPerSecondEnergy(val)
        --LOG('*BUFF: EnergyProduction = ' .. val)
	end,

	ExperienceGain = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'ExperienceGain', 1)
        unit:SetExperienceGainMultiplier(val)
        --LOG('*BUFF: ExperienceGain = ' .. val)
	end,

    HealthMax = function( unit, buffName )
        local unitbphealth = unit:GetBlueprint().Defense.MaxHealth or 1
        local val = BuffCalculate(unit, buffName, 'HealthMax', unitbphealth)
		
		local healthPerc = unit:GetHealth() / unit:GetMaxHealth()
		
        --local oldmax = unit:GetMaxHealth()
  
        unit:SetMaxHealth(val)
		unit:SetHealth(unit, unit:GetMaxHealth()*healthPerc) 

		-- Never adjust maxhealth unless our health is already at max health.
		-- Needed for replace style buffs that end up giving a health buff as a result of this of,
		-- the previous buff removing. This could be fixed by using stacking buffs, but with an 
		-- additional cost of 5x per unit in the case of SC2 veterancy. 
		--if unit:GetHealth() == oldmax then
		--	unit:AdjustHealth(unit, val - oldmax)
		--else
		--	unit:SetHealth(unit, math.min(unit:GetHealth(), unit:GetMaxHealth())) 
		--end
         
        --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max health to ', repr(val))
	end,

    HealthRegen = function( unit, buffName )
        local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
        local val = BuffCalculate(unit, buffName, 'HealthRegen', bpregn)
    
        unit:SetRegenRate(val)
        --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed regen rate to ', repr(val))
	end,

	JumpRange = function( unit, buffName )
        local bpDuration = unit:GetBlueprint().General.JumpRange or 1
        local val = BuffCalculate(unit, buffName, 'JumpRange', bpDuration)
        unit:SetJumpRange(val)
        --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed jump range to ', repr(val))
	end,

	LiftFactor = function( unit, buffName )
        local val = BuffCalculate( unit, buffName, 'LiftFactor', 1 )
		unit:SetLiftMult(val)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed lift factor multiplier to ', repr(val))
	end,

	MassProduction = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'MassProduction', unit:GetBlueprint().Economy.ProductionPerSecondMass or 1 )
        unit:SetProductionPerSecondMass(val)
        --LOG('*BUFF: MassProduction = ' .. val)
	end,

	MissileDecoyCapacity = function( unit, buffName )
	end,

	MoveSpeed = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'MoveSpeed', 1)
        unit:SetSpeedMult(val)
		unit:SetNavMaxSpeedMultiplier(val)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed speed mult to ', repr(val))
	end,

	MoveAccel = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'MoveAccel', 1)
        unit:SetAccMult(val)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed accel mult to ', repr(val))
	end,

	MoveTurning = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'MoveTurning', 1)
        unit:SetTurnMult(val)
		unit:SetNavMaxTurnSpeedMultiplier(val)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed move mult to ', repr(val))
	end,

	OmniRadius = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'OmniRadius', unit:GetBlueprint().Intel.RadarRadius or 0)
        if not unit:IsIntelEnabled('Omni') then
            unit:InitIntel(unit:GetArmy(),'Omni', val)
            unit:EnableIntel('Omni')
        else
            unit:SetIntelRadius('Omni', val)
            unit:EnableIntel('Omni')
        end
        
        if val <= 0 then
            unit:DisableIntel('Omni')
        end    
	end,

	-- Weapon buff
	ProjectileTurnRate = function( unit, buffName )
	end,

	-- Weapon buff
	ProjectileVelocity = function( unit, buffName )
	end,

	RadarRadius = function( unit, buffName )
		local bp = unit:GetBlueprint()
		local initialVal = bp.Intel.RadarRadius or 0
		-- if our initial value is less than 0, then lets initial radar to the vision radius
		-- to enable it, if no vision radius defined, we default to 10.
		if initialVal <= 0 then
			initialVal = bp.Intel.VisionRadius or 10
		end
		local val = BuffCalculate(unit, buffName, 'RadarRadius', initialVal )

        if val > 0 then
            if not unit:IsIntelEnabled('Radar') then
                unit:InitIntel(unit:GetArmy(),'Radar', val)
                unit:EnableIntel('Radar')
            else
                unit:SetIntelRadius('Radar', val)
                unit:EnableIntel('Radar')
            end
        else -- val <= 0
            unit:DisableIntel('Radar')
        end
	end,

	-- Weapon buff (Needs to be converted to single weapon buff)
	RateOfFire = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local wepbp = vWeapon:GetBlueprint()
					local weprof = wepbp.RateOfFire

					-- Set new rate of fire based on blueprint rate of fire.=
					local val = BuffCalculate(unit, buffName, 'RateOfFire', 1)
		            
					local delay = 1 / wepbp.RateOfFire
		            
					vWeapon:ChangeRateOfFire( 1 / ( val * delay ) )
					--LOG('*BUFF: RateOfFire = ' ..  (1 / ( val * delay )) )
				end
			--else
				--LOG( 'Warning WeaponRange weapon buff ', buffName, ', buff definition specified invalid weapon category ', weaponCategory, '.' )
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				local wepbp = wep:GetBlueprint()
				local weprof = wepbp.RateOfFire

				-- Set new rate of fire based on blueprint rate of fire.=
				local val = BuffCalculate(unit, buffName, 'RateOfFire', 1)
	            
				local delay = 1 / wepbp.RateOfFire
	            
				wep:ChangeRateOfFire( 1 / ( val * delay ) )
				--LOG('*BUFF: RateOfFire = ' ..  (1 / ( val * delay )) )
			end
		end
	end,

	RegenPercent = function( unit, buffName, weaponCategory, afterRemove )
        if afterRemove then
            --Restore normal regen value plus buffs so I don't break stuff. Love, Robert
            local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
            unit:SetRegenRate(BuffCalculate(unit, nil, 'Regen', bpregn))
        else
            --Buff this sucka
            unit:SetRegenRate(BuffCalculate(unit, buffName, 'RegenPercent', unit:GetMaxHealth()))
        end
	end,

	ResearchProduction = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'ResearchProduction', unit:GetBlueprint().Economy.ProductionPerSecondResearch or 1 )
        unit:SetProductionPerSecondResearch(val)
        --LOG('*BUFF: ResearchProduction = ' .. val)
	end,

	RepairScanRadius = function( unit, buffName )
		local val = BuffCalculate( unit, buffName, 'RepairScanRadius', uunit:GetBlueprint().Build.RepairScanRadius or 1 )
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'RepairScanRadius buffed to ', val )
		unit:SetRepairScanRadius(val)
	end,

	RepairMaxDistance = function( unit, buffName )
		local val = BuffCalculate( unit, buffName, 'RepairMaxDistance', unit:GetBlueprint().Build.MaxRepairDistance or 1 )
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'RepairMaxDistance buffed to ', val )
		unit:SetMaxRepairDistance(val)
	end,

	RepairRate = function( unit, buffName )
		local val = BuffCalculate( unit, buffName, 'RepairRate', unit:GetBlueprint().Economy.RepairRate or 1 )
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'RepairRate buffed to ', val )
		unit:SetRepairRate(val)
	end,

	RepairRegenRate = function( unit, buffName )
		local val = BuffCalculate( unit, buffName, 'RepairRegenRate', unit:GetBlueprint().Defense.RepairRegenRate or 10 )
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), 'RepairRegenRate buffed to ', val )
		unit:SetRepairRegenRate(val)
	end,

	SalvoSize = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local val = BuffCalculate(unit, buffName, 'SalvoSize', vWeapon:GetBlueprint().MuzzleSalvoSize or 1 )
					vWeapon:SetMuzzleSalvoSize(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed SalvoSize to ', repr(val))
				end
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				local val = BuffCalculate(unit, buffName, 'SalvoSize', wep:GetBlueprint().MuzzleSalvoSize or 1 )
				wep:SetMuzzleSalvoSize(val)
				--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed SalvoSize to ', repr(val))
			end
		end		
	end,

	ShieldHealthMax = function( unit, buffName )
		local shield = unit:GetShield()
		if shield then
			local val = BuffCalculate(unit, buffName, 'ShieldHealthMax', unit:GetBlueprint().Defense.Shield.ShieldMaxHealth or 1 )
			local oldmax = shield:GetMaxHealth()
	    
			shield:SetMaxHealth(val)

			if val > oldmax then
				shield:AdjustHealth(unit, val - oldmax)
			else
				shield:SetHealth( shield, math.min(shield:GetHealth(), shield:GetMaxHealth())) 
			end
			
			shield:UpdateShieldValue()
		end
          
        --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' applying ShieldHealthMax buff to unit that has no shield' )
	end,

	ShieldRegen = function( unit, buffName )
		local shield = unit:GetShield()
		if shield then
			local val = BuffCalculate(unit, buffName, 'ShieldRegen', unit:GetBlueprint().Defense.Shield.ShieldRegenRate or 1 )
			shield:SetRegenRate(val)
		end
          
        --LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' applying ShieldRegen buff to unit that has no shield' )
	end,

	SonarRadius = function( unit, buffName )
		local bp = unit:GetBlueprint()
		local initialVal = bp.Intel.SonarRadius or 0
		-- if our initial value is less than 0, then lets initial radar to the vision radius
		-- to enable it, if no vision radius defined, we default to 10.
		if initialVal <= 0 then
			initialVal = bp.Intel.VisionRadius or 10
		end
		local val = BuffCalculate(unit, buffName, 'SonarRadius', initialVal )

        if val > 0 then
            if not unit:IsIntelEnabled('Sonar') then
                unit:InitIntel(unit:GetArmy(),'Sonar', val)
                unit:EnableIntel('Sonar')
            else
                unit:SetIntelRadius('Sonar', val)
                unit:EnableIntel('Sonar')
            end
        else -- val <= 0
            unit:DisableIntel('Sonar')
        end
	end,

	StoredUnitCapacity = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'StoredUnitCapacity', unit:GetBlueprint().Transport.StorageSlots or 0)
        unit:SetNumberOfStorageSlots(val)
	end,
    
	VeterancyLevel = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'VeterancyLevel', 0)
        unit:SetVeterancy(val)
	end,

	TeleportDistance = function( unit, buffName )
        --LOG('*DEBUG: Starting teleport distance = ' .. unit:GetTeleportRange() )
        local val = BuffCalculate(unit, buffName, 'TeleportDistance', unit:GetBlueprint().General.TeleportRange or 0)
        unit:SetTeleportRange(val)
        --LOG('*DEBUG: Starting teleport distance = ' .. unit:GetTeleportRange() )
	end,

	-- Weapon buff
	StunChance = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local val = BuffCalculate(unit, buffName, 'StunChance', vWeapon:GetBlueprint().StunChance or 0 )
					vWeapon:SetStunChance(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed stun chance to ', repr(val))
				end
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				local val = BuffCalculate(unit, buffName, 'StunChance', wep:GetBlueprint().StunChance or 0 )
				wep:SetStunChance(val)
				--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed stun chance to ', repr(val))
			end
		end
	end,

	-- Weapon buff
	StunDuration = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local val = BuffCalculate(unit, buffName, 'StunDuration', vWeapon:GetBlueprint().StunDuration or 0 )
					vWeapon:SetStunDuration(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed stun duration to ', repr(val))
				end
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				local val = BuffCalculate(unit, buffName, 'StunDuration', wep:GetBlueprint().StunDuration or 0 )
				wep:SetStunDuration(val)
				--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed stun duration to ', repr(val))
			end
		end
	end,

	VisionPersistence = function( unit, buffName )
		local val = BuffCalculate(unit, buffName, 'VisionPersistence', unit:GetIntelPersistenceDelay('Vision') or 0 )
		unit:SetIntelPersistenceDelay('Vision',val)
		--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' Vision Persistence to ', repr(val))
	end,

	-- Weapon buff (Needs to be converted to single weapon buff)
	WeaponRange = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					local val = BuffCalculate(unit, buffName, 'WeaponRange', vWeapon:GetBlueprint().MaxRadius )
					vWeapon:ChangeMaxRadius(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max radius to ', repr(val))
				end
			--else
				--LOG( 'Warning WeaponRange weapon buff ', buffName, ', buff definition specified invalid weapon category ', weaponCategory, '.' )
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				local val = BuffCalculate(unit, buffName, 'WeaponRange', wep:GetBlueprint().MaxRadius )
				wep:ChangeMaxRadius(val)
				--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max radius to ', repr(val))
			end
		end
	end,

	-- Weapon buff
	WeaponYawSpeed = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					if vWeapon:HasTurret() then
						local val = BuffCalculate(unit, buffName, 'WeaponYawSpeed', vWeapon:GetTurretYawSpeed() )
						vWeapon:SetTurretYawSpeed(val)
						--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' WeaponYawSpeed to ', repr(val))
					end
				end
			--else
				--LOG( 'Warning WeaponYawSpeed weapon buff ', buffName, ', buff definition specified invalid weapon category ', weaponCategory, '.' )
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				if wep:HasTurret() then
					local val = BuffCalculate(unit, buffName, 'WeaponYawSpeed', wep:GetTurretYawSpeed() )
					wep:SetTurretPitchSpeed(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' WeaponYawSpeed to ', repr(val))
				end
			end
		end
	end,

	-- SC2 Weapon buff
	WeaponPitchSpeed = function( unit, buffName, weaponCategory )
		if weaponCategory then
			local weapons = unit:GetWeaponsByWeaponCategory(weaponCategory)
			if weapons then
				for kWeapon, vWeapon in weapons do
					if vWeapon:HasTurret() then
						local val = BuffCalculate(unit, buffName, 'WeaponPitchSpeed', vWeapon:GetTurretPitchSpeed() )
						vWeapon:SetTurretYawSpeed(val)
						--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' WeaponPitchSpeed to ', repr(val))
					end
				end
			--else
				--LOG( 'Warning WeaponPitchSpeed weapon buff ', buffName, ', buff definition specified invalid weapon category ', weaponCategory, '.' )
			end
		else
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				if wep:HasTurret() then
					local val = BuffCalculate(unit, buffName, 'WeaponPitchSpeed', wep:GetTurretPitchSpeed() )
					wep:SetTurretPitchSpeed(val)
					--LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' WeaponPitchSpeed to ', repr(val))
				end
			end
		end
	end,

	WaterVisionRadius = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'WaterVisionRadius', unit:GetBlueprint().Intel.WaterVisionRadius or 0)
        unit:SetIntelRadius('WaterVisionRadius', val)
	end,

	VisionRadius = function( unit, buffName )
        local val = BuffCalculate(unit, buffName, 'VisionRadius', unit:GetBlueprint().Intel.VisionRadius or 0)
        unit:SetIntelRadius('Vision', val)
	end,
}