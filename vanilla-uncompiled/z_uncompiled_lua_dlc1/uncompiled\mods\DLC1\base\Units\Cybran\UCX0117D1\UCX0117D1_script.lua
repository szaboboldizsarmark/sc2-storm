-----------------------------------------------------------------------------
--  File     : /units/cybran/UCX0117D1/UCX0117D1_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UCX0117D1: Cybran Monkeylord
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local EyeLaser = import('UCX0117D1_EyeLaser.lua').EyeLaser
local utilities = import('/lua/system/Utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local MegalithCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').MegalithCollisionBeam

local MegalithBeamWeapon = Class(DefaultBeamWeapon){
	BeamType = MegalithCollisionBeam,
}

UCX0117D1 = Class(ExperimentalMobileUnit) {

    Weapons = {
        EyeLaser01 = Class(EyeLaser) {},
        Laser01 = Class(DefaultProjectileWeapon) {},
        Laser02 = Class(DefaultProjectileWeapon) {},
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        AntiAir02 = Class(DefaultProjectileWeapon) {},
        AntiAir03 = Class(DefaultProjectileWeapon) {},
        AntiAir04 = Class(DefaultProjectileWeapon) {},
    },

    OnCreate = function(self, createArgs)
        ExperimentalMobileUnit.OnCreate(self, createArgs)
		self:HideBone('main_turret_pitch', true)
		self.AmbientEffectsBag = {}
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
        ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
        self.WeaponsEnabled = true
        self:ShowBone('main_turret_pitch', true)
        self:CreateAmbientEffect()
    end,
	
	OnBeingBuiltPreRelease = function(self, builder)
		self:ShowBone('main_turret_pitch', true)
	end,

    CreateAmbientEffect = function(self)
        -- Ambient effects
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Ambient01 do
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'exhaust_c_ref', self:GetArmy(), v ) )
		end
		for kEffect, vEffect in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Ambient02 do
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'exhaust_u_ref', self:GetArmy(), vEffect ) )
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'exhaust_d_ref', self:GetArmy(), vEffect ) )
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'exhaust_r_ref', self:GetArmy(), vEffect ) )
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'exhaust_l_ref', self:GetArmy(), vEffect ) )
		end
    end,
 
	OnAddToStorage = function(self, unit)
		self:DestroyAmbientEffect{}
		ExperimentalMobileUnit.OnAddToStorage(self, unit)
	end,
	
	DestroyAmbientEffect = function(self)
		if self.AmbientEffectsBag then
			for k, v in self.AmbientEffectsBag do
				v:Destroy()
			end
			self.AmbientEffectsBag = {}	
		end
	end,
	
	OnRemoveFromStorage = function(self, unit)
		self:CreateAmbientEffect()
		ExperimentalMobileUnit.OnRemoveFromStorage(self, unit)
	end,
	
    CreateDamageEffects = function(self, bone, army )
        for k, v in EffectTemplates.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end
    end,

    CreateDeathExplosionDustRing = function( self )
        local blanketSides = 18
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 11

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)

            local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 1.5, blanketZ + 0.5, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.5)
        end
    end,

    CreateFirePlumes = function( self, army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )
            velocity.x = velocity.x + GetRandomFloat(-0.3, 0.3)
            velocity.z = velocity.z + GetRandomFloat(-0.3, 0.3)
            velocity.y = velocity.y + GetRandomFloat( 0.0, 0.3)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, -2)):SetVelocity(utilities.GetRandomFloat(3, 4)):SetCollision(false)

            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/units/general/event/death/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = GetRandomFloat( 12, 22 )
        end
    end,

    CreateExplosionDebris = function( self, army )
        for k, v in EffectTemplates.Explosions.Land.CybranDefaultDestroyEffectsSmall01 do
            CreateAttachedEmitter( self, 'root', army, v ):OffsetEmitter( 0, 1, 0 )
        end
    end,

    DeathThread = function(self)
		-- Destroy idle animation
		if(self.Animator) then
			self.Animator:Destroy()
			self.Animator = false
		end

        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create Initial explosion effects
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'root', army, v )
		end

        self:CreateFirePlumes( army, {'root'}, 0 )
        self:CreateFirePlumes( army, {'main_turret_pitch', 'leg_cl_02', 'leg_cr_02',}, 0.5 )
        WaitSeconds(0.5)
        self:CreateFirePlumes( army, {'chassis', 'leg_fr_03', 'leg_bl_03',}, 0.5 )

        self:CreateExplosionDebris( army )
        WaitSeconds(0.5)

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'left_turret_yaw', army, v ):ScaleEmitter(0.8)
		end
		
        -- Create damage effects on turret bone
        self:CreateDamageEffects( 'main_turret_yaw', army )
        
        WaitSeconds( 0.6 )
        self:CreateFirePlumes( army, {'leg_br_01', 'leg_cr_01', 'leg_fr_01', 'leg_bl_01', 'leg_bl_01', 'leg_bl_01',}, 0.5 )
        WaitSeconds(0.2)

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'leg_cr_01', army, v ):ScaleEmitter(0.6)
		end
		WaitSeconds(1.0)
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'main_turret_yaw', army, v )
		end
		self:CreateUnitDestructionDebris()
		for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death03 do
			CreateEmitterAtBone( self, 'root', army, v )
		end
        WaitSeconds( 2.1 )
        
        -- When the spider bot impacts with the ground
        -- Effects: Explosion on turret, dust effects on the muzzle tip, large dust ring around unit
        -- Other: Damage force ring to force trees over and camera shake
        
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'root', army, v ):ScaleEmitter(1.2)
		end
		
		self:PlayUnitSound( 'Killed' )
        
        self:ShakeCamera(20, 4, 1, 2.0)
		self:CreateDeathExplosionDustRing()
		WaitSeconds( 1.5 )
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death01 do
			CreateEmitterAtBone( self, -2, army, v ):ScaleEmitter(1.7)
		end
		
		self:PlayUnitSound( 'Killed' )
		
		local bp = self:GetBlueprint()
		local scale = (bp.SizeX + bp.SizeZ) * 1.5
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 4 )

        self:CreateExplosionDebris( army )

		local bp = self:GetUnitWeaponBlueprint('MegalithDeath')
		if bp then
			DamageArea(self, self:GetPosition(), bp.DamageRadius, bp.Damage, bp.DamageType, bp.DamageFriendly)
		end
        self:CreateWreckage()
        self:ShakeCamera(2, 1, 0, 0.05)

        self:Destroy()
    end,

    OnMotionHorzEventChange = function( self, new, old )
        ExperimentalMobileUnit.OnMotionHorzEventChange(self, new, old)

        if ( old == 'Stopped' ) then
            local bpDisplay = self:GetBlueprint().Display
            if bpDisplay.AnimationWalk and self.Animator then
                self.Animator:SetDirectionalAnim(true)
                self.Animator:SetRate(bpDisplay.AnimationWalkRate)
            end
         end
    end,

    OnLayerChange = function(self, new, old)
        --LOG('LayerChange old=',old,' new=',new,' for ',self:GetBlueprint().BlueprintId )

        if old == 'Seabed' and new == 'Land' then
            self:EnableIntel('Vision')
            self:DisableIntel('WaterVision')
			self:TransitionDamageEffects()
			self:CreateAmbientEffect()
        elseif old == 'Land' and new == 'Seabed' then
            self:EnableIntel('WaterVision')
			self:TransitionDamageEffects()
			self:DestroyAmbientEffect()
        end

		-- Layer change callback
		self.Callbacks.OnLayerChange:Call(self, new, old)
    end,
    
    PlayNISTeleportInEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()
        for k, v in EffectTemplates.GenericTeleportIn01 do
            CreateEmitterAtEntity(self,army,v):ScaleEmitter(1.7)
        end
    end,
}
TypeClass = UCX0117D1