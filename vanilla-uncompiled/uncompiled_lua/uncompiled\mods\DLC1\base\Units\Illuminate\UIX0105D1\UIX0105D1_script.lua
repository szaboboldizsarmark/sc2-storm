-----------------------------------------------------------------------------
--  File     : UIX0105D1
--  Author(s): Mike Robbins
--  Summary  : SC2 Illuminate Mega Gunship
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalAirUnit = import('/lua/sim/ExperimentalAirUnit.lua').ExperimentalAirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local util = import('/lua/system/utilities.lua')
local utilities = import('/lua/system/Utilities.lua')
local RandomFloat = utilities.GetRandomFloat

UIX0105D1 = Class(ExperimentalAirUnit) {

	BeamExhaustCruise = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_01_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_02_emit.bp',
	},
    BeamExhaustIdle = {
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_03_emit.bp',
		'/effects/emitters/units/illuminate/general/illuminate_air_move_beam_04_emit.bp',
    },

    Weapons = {
        Laser01 = Class(DefaultProjectileWeapon){},
        Laser02 = Class(DefaultProjectileWeapon){},
        Laser03 = Class(DefaultProjectileWeapon){},
    },

    MovementAmbientExhaustBones = {
		'Exhaust01',
		'Exhaust02',
		'Exhaust03',
		'Exhaust04',
    },

    MovementAmbientExhaustThread = function(self)
		while not self:IsDead() do
            local ExhaustEffects = EffectTemplates.Units.Cybran.Experimental.UCX0116.Thrust01
			local ExhaustBeam = '/effects/emitters/ambient/units/missile_exhaust_fire_beam_06_emit.bp'
			local army = self:GetArmy()

			for kE, vE in ExhaustEffects do
				for kB, vB in self.MovementAmbientExhaustBones do
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateBeamEmitterOnEntity( self, vB, army, ExhaustBeam ))
				end
			end

			WaitSeconds(2)
			CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')

			WaitSeconds(util.GetRandomFloat(1,7))
		end
    end,

	CreateFirePlumes = function( self, army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )
            velocity.x = velocity.x + RandomFloat(-0.8, 0.8)
            velocity.z = velocity.z + RandomFloat(-0.5, 0.8)
            velocity.y = velocity.y + RandomFloat(-0.3, 0.3)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(RandomFloat(-1, 1)):SetVelocity(RandomFloat(3, 10)):SetCollision(false)

            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/units/general/event/death/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = RandomFloat( 15, 25 )
        end
    end,
    
    CreateUnitDestructionDebris = function( self )
		if not self.DestructionPartsCreated then
			self.DestructionPartsCreated = true
			local DestructionParts = self:GetBlueprint().Death.DestructionParts
			
			if DestructionParts then
				local scale = self:GetBlueprint().Display.UniformScale
				for k, v in DestructionParts do
					
					if v.Mesh then
						self:CreateDestructionPart( v, scale, v.Mesh)
						self:HideBone( v.AttachBone, true )
					elseif v.Meshes then
						for kMesh, vMesh in v.Meshes do
							self:CreateDestructionPart(v, scale, vMesh)
						end
						self:HideBone( v.AttachBone, true )						
					end
				end
			end
		end
	end,
	
    CreateUnitAirDestructionEffects = function( self, scale )
		local bp = self:GetBlueprint()
		local AirExplosionEffect = bp.Death.AirExplosionEffect
		local AirPlumeEffect = bp.Death.AirDestructionPlumeEffect
		local army = self:GetArmy()

		if AirExplosionEffect then
			local faction = bp.General.FactionName
			local layer = self:GetCurrentLayer() 
			local emitters = EffectTemplates.Units.Illuminate.Experimental.UIX0112.Death01
			if emitters then
				CreateBoneEffects( self, -2, army, emitters )
			end
		end

		self:CreateFirePlumes( army, {'T01_Barrel01', 'Exhaust01', 'Exhaust03'}, 1 )	
    end,
    
    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/80)
        end
        
        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
    end,
    
    DeathThread = function(self)
        local army = self:GetArmy()

        local layer = self:GetCurrentLayer()
        if layer == 'Seabed' then
            self:ForkThread(self.SeaFloorImpactEffects)
        else
            -- explosion effects override on ground impact.
            for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0101.Death01 do
			    CreateEmitterAtEntity( self, army, v )
		    end

		    -- Ground decal
		    CreateDecal(self:GetPosition(),RandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', 20, 20, 150, 15, army, 7 )

            self:ShakeCamera(20, 4, 1, 0.5)
        end

        ExperimentalAirUnit.DeathThread(self)
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
        self.detector = CreateCollisionDetector(self)
        self.Trash:Add(self.detector)
        self.detector:WatchBone('Exhaust01')
        self.detector:WatchBone('Exhaust03')
        self.detector:EnableTerrainCheck(true)
        self.detector:Enable()
        ExperimentalAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnAnimTerrainCollision = function(self, bone,x,y,z)
        DamageArea(self, {x,y,z}, 5, 5000, 'Default', true, false)
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0112.Death02 do
			CreateAttachedEmitter ( self, bone, self:GetArmy(), v )
		end  
    end,
    
    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        volume = sx * sz
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(volume/10)
    end,
}
TypeClass = UIX0105D1