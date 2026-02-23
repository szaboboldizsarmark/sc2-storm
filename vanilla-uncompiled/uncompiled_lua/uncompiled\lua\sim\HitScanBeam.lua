--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     : /lua/sim/hitscanbeam.lua
--  Author(s): Gautham Vasudevan
--  Summary  : HitScanBeam is the simulation (gameplay-relevant) portion of a
--			   beam. It wraps a special effect that may or may not exist
--			   depending on how the simulation is executing.
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local DefaultDamage = import('/lua/sim/damage.lua')
local Utilities = import('/lua/system/utilities.lua')

HitScanBeam = Class(moho.CollisionBeamEntity) {

    FxImpactProp = {},
    FxImpactShield = {},
    FxImpactNone = {},

    FxUnitHitScale = 1,
    FxLandHitScale = 1,
    FxWaterHitScale = 1,
    FxUnderWaterHitScale = 0.25,
    FxAirUnitHitScale = 1,
    FxPropHitScale = 1,
    FxShieldHitScale = 1,
    FxNoneHitScale = 1,

    TerrainImpactType = 'Default',
    TerrainImpactScale = 1,

    OnCreate = function(self)
        self.LastTerrainType = nil
        self.TerrainEffectsBag = {}
		self.TracerEffectsBag = {}
        self.Trash = TrashBag()
    end,

    OnDestroy = function(self)
        if self.Trash then
            self.Trash:Destroy()
        end
    end,

    OnEnable = function(self)
    end,

    OnDisable = function(self)
        self:DestroyTerrainEffects()
        self.LastTerrainType = nil
    end,

    SetParentWeapon = function(self, weapon)
        self.Weapon = weapon
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)
		-- Early out, if we don't have a valid entity to damage
		if not targetEntity then
			return
		end

		local damage = damageData.DamageAmount or 0

        if instigator and damage > 0 then

			if damageData.CriticalChance > 0 then
				if Random(1,100) < damageData.CriticalChance then
					damage = math.floor( damage * damageData.CriticalDamageMultiplier )
				end
			end

			if damageData.StunChance > 0 then
				if Random(1,100) < damageData.StunChance then
					targetEntity:SetStunned(damageData.StunDuration or 1)
				end
			end

            local radius = damageData.DamageRadius
            if radius and radius > 0 then
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    DamageArea(instigator, self:GetPosition(1), radius, damage, damageData.DamageType or 'Normal', damageData.DamageFriendly or false)
                else
                    ForkThread(DefaultDamage.AreaDoTThread, instigator, self:GetPosition(1), damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly)
                end
            elseif targetEntity then
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    Damage(instigator, self:GetPosition(), targetEntity, damage, damageData.DamageType)
                else
                    ForkThread(DefaultDamage.UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly)
                end
            else
                DamageArea(instigator, self:GetPosition(1), 0.25, damage, damageData.DamageType, damageData.DamageFriendly)
            end

            local bp = self.Weapon:GetBlueprint()
            if( bp.KnockbackDistance > 0 and targetEntity.PerformKnockback) then
				local randRange = bp.KnockbackDistanceRand or 0

				if not bp.KnockbackRadius then
					targetEntity:PerformKnockback( instigator, bp.KnockbackDistance + Utilities.GetRandomFloat(-randRange, randRange), (bp.KnockbackScale or 5) )
				else
					local brain = instigator:GetAIBrain()
					local units = brain:GetUnitsAroundPoint( categories.LAND * categories.MOBILE, targetEntity:GetPosition(), bp.KnockbackRadius, 'Enemy' )

					for index,enemyUnit in units do
						if enemyUnit.PerformKnockback then
							enemyUnit:PerformKnockback( instigator, bp.KnockbackDistance + Utilities.GetRandomFloat(-randRange, randRange), (bp.KnockbackScale or 5) )
						end
					end
				end
			end
        else
            LOG('*ERROR: THERE IS NO INSTIGATOR FOR DAMAGE ON THIS COLLISIONBEAM = ', repr(damageData))
        end
    end,



    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
        EffectTable = EffectTable or {}
        EffectScale = EffectScale or 1
        for k, v in EffectTable do
            emit = CreateEmitterAtBone(self,1,army,v)
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale)
            end
        end
    end,

    CreateTerrainEffects = function( self, army, EffectTable, EffectScale )
        local emit = nil
        for k, v in EffectTable do
            emit = CreateAttachedEmitter(self,1,army,v)
            table.insert(self.TerrainEffectsBag, emit )
            if emit and EffectScale != 1 then
                emit:ScaleEmitter(EffectScale)
            end
        end
    end,

    DestroyTerrainEffects = function( self )
        for k, v in self.TerrainEffectsBag do
            v:Destroy()
        end
        self.TerrainEffectsBag = {}
    end,

    UpdateTerrainCollisionEffects = function( self, TargetType )
        local pos = self:GetPosition(1)
        local TerrainType = nil

        if self.TerrainImpactType != 'Default' then
            TerrainType = GetTerrainType( pos.x,pos.z )
        else
            TerrainType = GetTerrainType( -1, -1 )
        end

        local TerrainEffects = TerrainType.FXImpact[TargetType][self.TerrainImpactType] or nil

        if TerrainEffects and (self.LastTerrainType != TerrainType) then
            self:DestroyTerrainEffects()
            self:CreateTerrainEffects( self:GetArmy(), TerrainEffects, self.TerrainImpactScale )
            self.LastTerrainType = TerrainType
        end
    end,

    -- This is called when the collision beam hits something new. Because the beam
    -- is continuously detecting collisions it only executes this function when the
    -- thing it is touching changes. Expect Impacts with non-physical things like
    -- 'Air' (hitting nothing) and 'Underwater' (hitting nothing underwater).
    OnImpact = function(self, impactType, targetEntity)
        --LOG('*DEBUG: COLLISION BEAM ONIMPACT ', repr(self))
        --LOG('*DEBUG: COLLISION BEAM ONIMPACT, WEAPON =  ', repr(self.Weapon), 'Type = ', impactType)
        --LOG('CollisionBeam impacted with: ' .. impactType )
        -- Possible 'type' values are:
        --  'Unit'
        --  'Terrain'
        --  'Water'
        --  'Air'
        --  'UnitAir'
        --  'Underwater'
        --  'UnitUnderwater'
        --  'Projectile'
        --  'Prop'
        --  'Shield'

        local instigator = self:GetLauncher()

		-- SetDamageTable must be calculated each time because buffs can and will change the weapon
		self:SetDamageTable()
        local damageData = self.DamageTable

        -- Do Damage
        self:DoDamage( instigator, damageData, targetEntity)

        local ImpactEffects = {}
        local ImpactEffectScale = 1
        local army = self:GetArmy()

        if impactType == 'Water' then
            ImpactEffects = self.FxImpactWater
            ImpactEffectScale = self.FxWaterHitScale
        elseif impactType == 'Underwater' or impactType == 'UnitUnderwater' then
            ImpactEffects = self.FxImpactUnderWater
            ImpactEffectScale = self.FxUnderWaterHitScale
        elseif impactType == 'Unit' then
            ImpactEffects = self.FxImpactUnit
            ImpactEffectScale = self.FxUnitHitScale
        elseif impactType == 'UnitAir' then
            ImpactEffects = self.FxImpactAirUnit
            ImpactEffectScale = self.FxAirUnitHitScale
        elseif impactType == 'Terrain' then
            ImpactEffects = self.FxImpactLand
            ImpactEffectScale = self.FxLandHitScale
        elseif impactType == 'Air' or impactType == 'Projectile' then
            ImpactEffects = self.FxImpactNone
            ImpactEffectScale = self.FxNoneHitScale
        elseif impactType == 'Prop' then
            ImpactEffects = self.FxImpactProp
            ImpactEffectScale = self.FxPropHitScale
        elseif impactType == 'Shield' then
            ImpactEffects = self.FxImpactShield
            ImpactEffectScale = self.FxShieldHitScale
        else
            LOG('*ERROR: CollisionBeam:OnImpact(): UNKNOWN TARGET TYPE ', repr(impactType))
        end

        self:CreateImpactEffects( army, ImpactEffects, ImpactEffectScale )
        self:UpdateTerrainCollisionEffects( impactType )
    end,

    GetCollideFriendly = function(self)
        return self.DamageData.CollideFriendly
    end,

    SetDamageTable = function(self)
        local weaponBlueprint = self.Weapon:GetBlueprint()
        self.DamageTable = {}
		self.DamageTable.CriticalChance = self.Weapon:GetCriticalChance()
		self.DamageTable.CriticalDamageMultiplier = self.Weapon:GetCriticalDamageMultiplier()
        self.DamageTable.DamageRadius = weaponBlueprint.DamageRadius
        self.DamageTable.DamageAmount = self.Weapon:GetDamage()
        self.DamageTable.DamageType = weaponBlueprint.DamageType
        self.DamageTable.DamageFriendly = weaponBlueprint.DamageFriendly
        self.DamageTable.CollideFriendly = weaponBlueprint.CollideFriendly
        self.DamageTable.DoTTime = weaponBlueprint.DoTTime
        self.DamageTable.DoTPulses = weaponBlueprint.DoTPulses
        self.DamageTable.Buffs = weaponBlueprint.Buffs
    end,

    CreateTracerEffects = function(self, tracerEffects)
        local army = self:GetArmy()
        if tracerEffects and not table.empty(tracerEffects) then
            local fxTracer = CreateBeamEmitter(tracerEffects[Random(1, table.getn(tracerEffects))], army)
            AttachBeamToEntity(fxTracer, self, 0, army)

            -- collide on start if it's a continuous beam
            local weaponBlueprint = self.Weapon:GetBlueprint()
            self:SetBeamFx(fxTracer, true)

            table.insert( self.TracerEffectsBag, fxTracer )
            self.Trash:Add(fxTracer)
        end
    end,

    DestroyTracerEffects = function(self)
        for k, v in self.TracerEffectsBag do
            v:Destroy()
        end
        self.TracerEffectsBag = {}
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
}