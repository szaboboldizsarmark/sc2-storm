-----------------------------------------------------------------------------
--  File     : /lua/sim/AirUnit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Air Unit
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local utilities = import('/lua/system/utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat

AirUnit = Class(MobileUnit) {

    -- Contrails
    ContrailEffects = {'/effects/emitters/ambient/units/contrail_polytrail_01_emit.bp',},
	BeamExhaustCruise = {'/effects/emitters/ambient/units/air_move_trail_beam_03_emit.bp',},
	BeamExhaustIdle = {'/effects/emitters/ambient/units/air_idle_trail_beam_01_emit.bp',},

    -- DESTRUCTION PARAMS
    DestructionExplosionWaitDelayMax = 0,
	-- self.DestroyNoFallRandomChance is currently set to 1.0 so I am commenting both out until we decide to change it
	-- so we aren't generating a random number for no reason - Sorian 1/20/2010
    --DestroyNoFallRandomChance = 1.0,

    OnCreate = function(self, createArgs)
        MobileUnit.OnCreate(self, createArgs)
	    self.BeamExhaustEffectsBag = {}
        self.DestroyedEffectsBag = {}

		-- Initialize animset
		self.animset = self:GetBlueprint().AnimSet or nil
		if self.animset then
			self:PushAnimSet(self.animset, "Base");
		end
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        MobileUnit.OnStopBeingBuilt(self,builder,layer)
        local bp = self:GetBlueprint()
        if bp.SizeSphere then
            self:SetCollisionShape(
                'Sphere',
                bp.CollisionSphereOffsetX or 0,
                bp.CollisionSphereOffsetY or 0,
                bp.CollisionSphereOffsetZ or 0,
                bp.SizeSphere
            )
        end

        if self.animset and self:GetCurrentLayer() == 'Air' then
            self:SendAnimEvent( 'OnTakeOff' )
        end
    end,

    OnMotionVertEventChange = function( self, new, old )
        MobileUnit.OnMotionVertEventChange( self, new, old )
        --LOG('*DEBUG: OnMotionVertEventChange')

	    if (new == 'Down') then
            -- Play the "landing" sound
            -- Turn off the ambient hover sound
            self:PlayUnitSound('Landing')
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:StopUnitAmbientSound('AmbientHover')

			if self.animset then
				self:SendAnimEvent( 'OnLanding' )
			end
			self:UpdateBeamExhaust('Landed')
        elseif (new == 'Bottom') then
            -- Turn off the ambient hover sound
            -- It will probably already be off, but there are some odd cases that
            -- make this a good idea to include here as well.
            self:StopUnitAmbientSound( 'ActiveLoop' )
            -- Play the "landed" sound
            self:PlayUnitSound('Landed')
        elseif (new == 'Hover') then
            -- Play the "landed" sound
            self:PlayUnitSound('Landed')
        elseif (new == 'Up' or ( new == 'Top' and ( old == 'Down' or old == 'Bottom' ))) then
            -- Play the "takeoff" sound
            self:PlayUnitSound('TakeOff')

			if self.animset then
				self:SendAnimEvent( 'OnTakeOff' )
			end

			self:UpdateBeamExhaust('Cruise')
        end
    end,

    DeathThread = function( self, overkillRatio, instigator)
        --LOG('*DEBUG: OVERKILL RATIO = ', repr(overkillRatio))

		self:PrecacheDebris()
		-- If we want a destruction delay *** Move these values to bp.
        WaitSeconds( utilities.GetRandomFloat( self.DestructionExplosionWaitDelayMin, self.DestructionExplosionWaitDelayMax) )

		-- Destroy any ambient damage effects on unit
        self:DestroyAllDamageEffects()

		self:StopUnitAmbientSound('Sinking')

		-- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect

		self:PlayUnitSound('Destroyed')

		if ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][ExplosionEffect]

			if emitters then
				CreateBoneEffects( self, -2, self:GetArmy(), emitters )
			end
		end

		if bp.Death.DebrisPieces then
			self:DebrisPieces( self )
		end

		if bp.Death.ExplosionTendrils then
			self:ExplosionTendrils( self )
		end

		if bp.Death.Light then
			local myPos = self:GetPosition()
			myPos[2] = myPos[2] + 7
			CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 10, 4, 0.1, 0.1, 0.5 )
		end

		-- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

		-- If the unit has a death animation running, wait for it to finish
        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
        
        -- Test TerrainType at impact position
        local pos = self:GetPosition()
        local terrainType = GetTerrainType( pos[1], pos[3] )
        local createTerrainWreckage = true
        if terrainType and terrainType.Name == "Chasm_Bottom" then
			createTerrainWreckage = false
		end

        local layer = self:GetCurrentLayer()
        if layer == 'Seabed' then
            self:ForkThread(self.SeaFloorImpactEffects)
        elseif createTerrainWreckage then
            local scale = (bp.SizeX + bp.SizeZ) * 1.5
		    if bp.Death.ScorchDecal then
			    CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi), bp.Death.ScorchDecal, '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		    else
			    CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		    end
        end

		
		-- Create unit wreckage
		if createTerrainWreckage then
			self:CreateWreckage( overkillRatio )
		end

        self:Destroy()
    end,

    OnImpact = function(self, with, other)
		if not self:IsDead() then
			return
		end

        -- Damage the area we have impacted with.
		local bp = self:GetUnitWeaponBlueprint('DeathImpact')
		if bp then
			DamageArea(self, self:GetPosition(), bp.DamageRadius, bp.Damage, bp.DamageType, bp.DamageFriendly)
		end

		self:StopUnitAmbientSound('FallingLoop')

        if with == 'Water' then
            self:PlayUnitSound('AirUnitWaterImpact')
			self:PlayUnitAmbientSound('Sinking')
            self:ForkThread(self.CreateUnitWaterImpactEffect)
        else
            -- This is a bit of safety to keep us from calling the death thread twice in case we bounce twice quickly
            if not self.DeathBounce then
                self:DestroyDestroyedEffects()
                self:ForkThread(self.DeathThread, self.OverKillRatio )
                self.DeathBounce = 1
            end
        end
    end,

    CreateUnitAirDestructionEffects = function( self, scale )
		local bp = self:GetBlueprint()
		local AirExplosionEffect = bp.Death.AirExplosionEffect
		local AirPlumeEffect = bp.Death.AirDestructionPlumeEffect
		local army = self:GetArmy()

		if AirExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][AirExplosionEffect]

			if emitters then
				CreateBoneEffects( self, -2, army, emitters )
			end
		end

		if AirPlumeEffect then
			local emitters = EffectTemplates.Wreckage[AirPlumeEffect] or {}
			for kEffect, vEffect in emitters do
                table.insert( self.DestroyedEffectsBag, CreateEmitterOnEntity( self, army, vEffect ))
			end
		end
    end,

    CreateUnitWaterTrailEffect = function( self )
		local bp = self:GetBlueprint()

		local WaterTrailEffect = bp.Death.AirDestructionWaterPlumeEffect

		if WaterTrailEffect and EffectTemplates.Wreckage[WaterTrailEffect]  then
			local army = self:GetArmy()
			for kEffect, vEffect in EffectTemplates.Wreckage[WaterTrailEffect] do
                table.insert( self.DestroyedEffectsBag, CreateEmitterOnEntity( self, army, vEffect ))
			end
		end
    end,

    CreateUnitWaterImpactEffect = function( self )
		local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz
        for k, v in EffectTemplates.WaterSplash01 do
            CreateEmitterAtEntity( self, self:GetArmy(), v ):ScaleEmitter(vol/10)
        end

        self:DestroyAllDamageEffects()
        self:DestroyDestroyedEffects()
        self:CreateUnitWaterTrailEffect( self )
        --self:Destroy()
    end,

	CreateUnitDestructionDebris = function( self )
		if not self.DestructionPartsCreated then
			self.DestructionPartsCreated = true
			local DestructionParts = self:GetBlueprint().Death.DestructionParts

			if DestructionParts then
				local x,y,z = self:GetVelocity()
				local scale = self:GetBlueprint().Display.UniformScale
				for k, v in DestructionParts do
					local proj = self:CreateProjectileAtBone( v.Projectile, v.AttachBone )
					proj:SetMesh( v.Mesh )
					proj:SetScale( scale )
					local offsetBone = v.PivotBone or 'DebrisPivot01'
					local pos = VAdd( proj:GetPosition(), VDiff( proj:GetPosition(), proj:GetPosition(offsetBone) ) )
					Warp( proj, pos )
					proj:SetVelocity( x, y, z )
					proj:SetVelocity( Random(1,12) )
					proj:SetBallisticAcceleration( -1 * Random(2,6)  )
					self:HideBone( v.AttachBone, true )
				end
			end
		end
	end,

    -- ON KILLED: THIS FUNCTION PLAYS WHEN THE UNIT TAKES A MORTAL HIT.  IT PLAYS ALL THE DEFAULT DEATH EFFECT
    -- IT ALSO SPAWNS THE WRECKAGE BASED UPON HOW MUCH IT WAS OVERKILLED. UNIT WILL SPIN OUT OF CONTROL TOWARDS
    -- GROUND AND WHEN IT IMPACTS IT WILL DESTROY ITSELF
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp = self:GetBlueprint()
		-- self.DestroyNoFallRandomChance is currently set to 1.0 so I am commenting both out until we decide to change it
		-- so we aren't generating a random number for no reason - Sorian 1/20/2010
        if (self:GetCurrentLayer() == 'Air' ) then -- and Random() <= self.DestroyNoFallRandomChance) then
            self.CreateUnitAirDestructionEffects( self, 1.0 )
			self:CreateUnitDestructionDebris()
            self:DestroyBeamExhaust()
            self:DestroyMovementEffects()
            self:DestroyIdleEffects()
            self.OverKillRatio = overkillRatio
			self:StopUnitAmbientSound( 'AmbientMove' )
            self:PlayUnitSound('Killed')
			self:PlayUnitAmbientSound('FallingLoop')
            self:OnKilledVO()
            self.Callbacks.OnKilled:Call(self, instigator, type)
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
        else
            self.DeathBounce = 1
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
            MobileUnit.OnKilled(self, instigator, type, overkillRatio)
        end
    end,

    UpdateBeamExhaust = function( self, motionState )
        local bpTable = self:GetBlueprint().Display.MovementEffects.BeamExhaust
        if not bpTable then
            return false
        end
        if motionState == 'Idle' then
            if self.BeamExhaustCruise  then
                self:DestroyBeamExhaust()
            end
            if self.BeamExhaustIdle and (table.getn(self.BeamExhaustEffectsBag) == 0) and (bpTable.Idle != false) then
                self:CreateBeamExhaust( bpTable, self.BeamExhaustIdle )
            end
        elseif motionState == 'Cruise' then
            if self.BeamExhaustIdle and self.BeamExhaustCruise then
                self:DestroyBeamExhaust()
            end
            if self.BeamExhaustCruise and (bpTable.Cruise != false) then
                self:CreateBeamExhaust( bpTable, self.BeamExhaustCruise )
            end
        elseif motionState == 'Landed' then
            if not bpTable.Landed then
                self:DestroyBeamExhaust()
            end
        end
    end,

    CreateBeamExhaust = function( self, bpTable, beamBPs )
        local effectBones = bpTable.Bones
        if not effectBones or (effectBones and (table.getn(effectBones) == 0)) then
            LOG('*WARNING: No beam exhaust effect bones defined for unit ',repr(self:GetUnitId()),', Effect Bones must be defined to play beam exhaust effects. Add these to the Display.MovementEffects.BeamExhaust.Bones table in unit blueprint.' )
            return false
        end
        local army = self:GetArmy()
		for k, v in beamBPs do
			for kb, vb in effectBones do
				table.insert( self.BeamExhaustEffectsBag, CreateBeamEmitterOnEntity(self, vb, army, v ))
			end
		end
    end,

    DestroyBeamExhaust = function( self )
        CleanupEffectBag(self,'BeamExhaustEffectsBag')
    end,

    DestroyDestroyedEffects = function( self )
        CleanupEffectBag(self,'DestroyedEffectsBag')
    end,

    CreateContrails = function(self, tableData )
        local effectBones = tableData.Bones
        if not effectBones or (effectBones and (table.getn(effectBones) == 0)) then
            LOG('*WARNING: No contrail effect bones defined for unit ',repr(self:GetUnitId()),', Effect Bones must be defined to play contrail effects. Add these to the Display.MovementEffects.Air.Contrail.Bones table in unit blueprint. ' )
            return false
        end
        local army = self:GetArmy()
        local ZOffset = tableData.ZOffset or 0.0
        for ke, ve in self.ContrailEffects do
            for kb, vb in effectBones do
                table.insert(self.MovementEffectsBag, CreateTrail(self,vb,army,ve):SetEmitterParam('POSITION_Z', ZOffset))
            end
        end
    end,

    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        volume = sx * sz
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(volume/7)
    end,
}