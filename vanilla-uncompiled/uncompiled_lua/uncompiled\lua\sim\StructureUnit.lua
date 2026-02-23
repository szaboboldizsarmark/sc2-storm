-----------------------------------------------------------------------------
--  File     : /lua/sim/structureunit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Structure Unit
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Unit = import('/lua/sim/Unit.lua').Unit
local AdjacencyBuffs = import('/lua/sim/buffs/AdjacencyBuffs.lua')
local utilities = import('/lua/system/utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat
local GetRandomInt = utilities.GetRandomInt

StructureUnit = Class(Unit) {

	MinConsumptionPerSecondEnergy = 1,
    MinWeaponRequiresEnergy = 0,

    -- Stucture unit specific damage effects and smoke
    FxDamage1 = { EffectTemplates.DamageStructureSmoke01, EffectTemplates.DamageStructureSparks01 },
    FxDamage2 = { EffectTemplates.DamageElectricity01, EffectTemplates.DamageStructureSparks01 },
    FxDamage3 = { EffectTemplates.DamageStructureSparks01, EffectTemplates.DamageStructureSparks01 },

    OnCreate = function(self)
        Unit.OnCreate(self)
        self.FxBlinkingLightsBag = {}
        if self:GetCurrentLayer() == 'Land'then
              -- Units creating structure units tell unit to create the tarmac.
            -- This left here to help with F2 unit creation and testing.
            self:CreateTarmac(true, true, false, false)
        end

		-- SC2 - Upgrade units data, used when upgrade units are built on
		-- structure units.
		self.UpgradeUnits = {}

		local bp = self:GetBlueprint().General
		if bp and bp.StructureUpgradeUnit then
			self:SetUnSelectable(true)
			self:SetDoNotTarget(true)
			self:SetCanTakeDamage(false)
			self:SetCollisionShape('None')
		end

		self.UpgradeParent = nil
		self.BuildScaffoldUnit = nil
    end,

    OnStartBuildWithBonus = function(self)
		local unitbp = self:GetBlueprint()
		local unitwidth = (unitbp.SizeX + unitbp.SizeZ) / 2

		CreateEmittersAtEntity( self, self:GetArmy(), EffectTemplates.BuildBonusEffect, false, unitwidth )
    end,
    
	OnStartBeingBuilt = function(self, builder, layer)
		Unit.OnStartBeingBuilt(self, builder, layer)

		local bp = self:GetBlueprint()
		if bp.Build.BuildScaffoldUnit then
			local x, y, z = unpack(self:GetPosition())
			local qx, qy, qz, qw = unpack(self:GetOrientation())
			self.BuildScaffoldUnit = CreateUnit(bp.Build.BuildScaffoldUnit, self:GetArmy(), x, y, z, qx, qy, qz, qw )
			self.BuildScaffoldUnit:DeployScaffold(self)
			self.Trash:Add(self.BuildScaffoldUnit)
		elseif self:GetBlueprint().Build.UseBuildMaterial then
			self:SetTextureSetByName("Build")
		end
	end,

	GetBuildScaffoldUnit = function(self)
		return self.BuildScaffoldUnit
	end,

    OnStopBeingBuilt = function(self,builder,layer)
		-- Sets Base mesh first, (Shields done by texture set can change this.		
    	if self:GetBlueprint().Build.UseBuildMaterial then
			self:SetTextureSetByName("Base")
		end
    
        Unit.OnStopBeingBuilt(self,builder,layer)

		-- Build scaffold is on it's own at this point.
		if self.BuildScaffoldUnit and not self.BuildScaffoldUnit:IsDead() then
			self.BuildScaffoldUnit:BuildUnitComplete()
		end

		self.BuildScaffoldUnit = nil



        self:PlayActivateAnimation()
    end,

    OnFailedToBeBuilt = function(self)
        Unit.OnFailedToBeBuilt(self)
        self:DestroyTarmac()
    end,

    CreateTarmac = function(self, diffuse, normal, orientation, specTarmac, lifeTime)
		if self:GetCurrentLayer() != 'Land' then return end
        local tarmac
        local bp = self:GetBlueprint().Display.Tarmacs
        if not specTarmac then
            if bp and table.getn(bp) > 0 then
                local num = Random(1, table.getn(bp))
                --LOG('*DEBUG: NUM + ', repr(num))
                tarmac = bp[num]
            else
                return false
            end
        else
            tarmac = specTarmac
        end

        local army = self:GetArmy()
        local w = tarmac.Width
        local l = tarmac.Length
        local fadeout = tarmac.FadeOut

        local x, y, z = unpack(self:GetPosition())

        --I'm disabling this for now since there are so many things wrong with it.
        --SetTerrainTypeRect(self.tarmacRect, {TypeCode= (aiBrain:GetFactionIndex() + 189) } )
        local orient = orientation
        if not orientation then
            if tarmac.Orientations and table.getn(tarmac.Orientations) > 0 then
                orient = tarmac.Orientations[Random(1, table.getn(tarmac.Orientations))]
                orient = (0.01745 * orient)
            else
                orient = 0
            end
        end

        if not self.TarmacBag then
            self.TarmacBag = {
                Decals = {},
                Orientation = orient,
                CurrentBP = tarmac,
            }
        end

		local diffuseTexture = ''
		local normalTexture = ''
		local tarmacDir = '/textures/tarmacs'

		if diffuse and tarmac.Diffuse and tarmac.Diffuse != '' then
			diffuseTexture = tarmacDir .. tarmac.Diffuse .. '.dds'
		end

		if normal and tarmac.Normal and tarmac.Normal != '' then
			normalTexture = tarmacDir .. tarmac.Normal .. '.dds'
		end

		if diffuseTexture != '' or normalTexture != '' then
			local physicsBp = self:GetBlueprint().Physics
			local scale = (physicsBp.SkirtSizeX + physicsBp.SkirtSizeZ) * 0.2
			local tarmacHndl = CreateDecal(self:GetPosition(), orient, diffuseTexture, normalTexture, '', w, l, fadeout, lifeTime or 0, army, scale, 0 )
			table.insert(self.TarmacBag.Decals, tarmacHndl)
			if tarmac.RemoveWhenDead then
				self.Trash:Add(tarmacHndl)
			end
		end
     end,

    DestroyTarmac = function(self)
        if not self.TarmacBag then return end
        for k, v in self.TarmacBag.Decals do
            v:Destroy()
        end

        self.TarmacBag.Orientation = nil
        self.TarmacBag.CurrentBP = nil
    end,

    HasTarmac = function(self)
        if not self.TarmacBag then return false end
        return (table.getn(self.TarmacBag.Decals) != 0)
    end,

    CreateBlinkingLights = function(self, color)
        self:DestroyBlinkingLights()
        local bp = self:GetBlueprint().Display.BlinkingLights
        local bpEmitters = self:GetBlueprint().Display.BlinkingLightsFx
        if bp then
            local fxbp = bpEmitters[color]
            for k, v in bp do
                if type(v) == 'table' then
                    local fx = CreateAttachedEmitter(self, v.BLBone, self:GetArmy(), fxbp)
                    fx:OffsetEmitter(v.BLOffsetX or 0, v.BLOffsetY or 0, v.BLOffsetZ or 0)
                    fx:ScaleEmitter(v.BLScale or 1)
                    table.insert(self.FxBlinkingLightsBag, fx)
                    self.Trash:Add(fx)
                end
            end
        end
    end,

    DestroyBlinkingLights = function(self)
        for k, v in self.FxBlinkingLightsBag do
            v:Destroy()
        end
        self.FxBlinkingLightsBag = {}
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )
        Unit.OnStartBuild(self,unitBeingBuilt, order)
		self.UnitBeingBuilt = unitBeingBuilt

		if unitBeingBuilt:GetBlueprint().Physics.OccupyGround and not unitBeingBuilt:HasTarmac() then
            if self.TarmacBag and self:HasTarmac() then
                unitBeingBuilt:CreateTarmac(true, true, self.TarmacBag.Orientation, self.TarmacBag.CurrentBP )
            else
                unitBeingBuilt:CreateTarmac(true, true, false, false)
            end
        end
    end,

    StartUpgradeEffects = function(self, unitBeingBuilt)
        unitBeingBuilt:HideMesh()
    end,

    StopUpgradeEffects = function(self, unitBeingBuilt)
        unitBeingBuilt:ShowMesh()
    end,

    PlayActivateAnimation = function(self)
		local DisplayBp = self:GetBlueprint().Display
		if DisplayBp.AnimationActivate then
			if not self.AnimationManipulator then
				self.AnimationManipulator = CreateAnimator(self)
				self.Trash:Add(self.AnimationManipulator)
			end
			self.AnimationManipulator:PlayAnim(DisplayBp.AnimationActivate, DisplayBp.AnimationActivateLoop or false )

			if not DisplayBp.AnimationActivateLoop then
				self:ForkThread(function()
					WaitSeconds(self.AnimationManipulator:GetAnimationDuration()*self.AnimationManipulator:GetRate())
					self.AnimationManipulator:Destroy()
				end)
			end
		end
    end,

    --Adding into OnKilled the ability to destroy the tarmac but put a new one down that looks exactly like it but
    --will time out over the time spec'd or 300 seconds.
    OnKilled = function(self, instigator, type, overkillRatio)
        Unit.OnKilled(self, instigator, type, overkillRatio)
		if self.UpgradeParent and not self.UpgradeParent:IsDead() then
			self.UpgradeParent:OnUnitUpgradeKilled( self )
		end
        local orient = self.TarmacBag.Orientation
        local currentBP = self.TarmacBag.CurrentBP
        self:DestroyTarmac()
        self:CreateTarmac(true, true, orient, currentBP, currentBP.DeathLifetime or 300)
        self.OnKilledTarmacsCleanedUp = true
		self:KillUpgradeUnits()
    end,

	-- SC2 - Utility function that kills any spawned 'Upgrade' units that are have been built
	-- and attached to this structure.
	KillUpgradeUnits = function( self )
		for index, upgradeUnit in self.UpgradeUnits do
			if upgradeUnit and not upgradeUnit:IsDead() then
				upgradeUnit:Kill()
			end
		end
		self.UpgradeUnits = {}
	end,

	OnUnitUpgradeKilled = function( self, upgradeUnit )
		self:OnRemoveUnitUpgrade( upgradeUnit )
	end,

	OnRemoveUnitUpgrade = function( self, upgradeUnit )
		for k, v in self.UpgradeUnits do
			if v == upgradeUnit then
				table.remove( self.UpgradeUnits, k )
				continue
			end
		end
		RemoveUnitUpgrade( self:GetEntityId(), upgradeUnit:GetUnitId() )
	end,

	OnDestroy = function(self)
		RemoveAllUnitUpgrades(self)
		self:KillUpgradeUnits()
		
		-- If the structure was destroyed without killing it, replace the tarmac
		if not self.OnKilledTarmacsCleanedUp then
			local orient = self.TarmacBag.Orientation
			local currentBP = self.TarmacBag.CurrentBP			
		    self:DestroyTarmac()
			self:CreateTarmac(true, true, orient, currentBP, currentBP.DeathLifetime or 300)
		end
		
		Unit.OnDestroy(self)
	end,

	CreateDestructionPart = function(self, partInfo, scale, mesh)
		local proj = self:CreateProjectileAtBone( partInfo.Projectile, partInfo.AttachBone )
		proj:SetMesh( mesh )
		proj:SetScale( scale )
		local offsetBone = partInfo.PivotBone or 'DebrisPivot01'
		local pos = VAdd( proj:GetPosition(), VDiff( proj:GetPosition(), proj:GetPosition(offsetBone) ) )
		Warp( proj, pos )		
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

    DebrisPieces = function( self )
		WaitSeconds(0.2)
        local num_projectiles = GetRandomFloat( 5, 10 )

		for i = 1,num_projectiles do
			local horizontal_angle = (2*math.pi) / num_projectiles
			local angleInitial = GetRandomFloat( 0, horizontal_angle )
			local xVec, yVec, zVec
			local angleVariation = 0.5
			local px, py, pz

			xVec = math.sin(angleInitial + (i*horizontal_angle) + GetRandomFloat(-angleVariation, angleVariation) )
			yVec = GetRandomFloat( 0.2, 5.0 )
			zVec = math.cos(angleInitial + (i*horizontal_angle) + GetRandomFloat(-angleVariation, angleVariation) )
			px = GetRandomFloat( 0.3, 0.8 ) * xVec
			py = GetRandomFloat( 0.0, 0.6 ) * yVec
			pz = GetRandomFloat( 0.3, 0.8 ) * zVec

			local proj = self:CreateProjectile( '/effects/Entities/DebrisMisc04/DebrisMisc04_proj.bp', px, py, pz, xVec, yVec, zVec )
			local velocity = GetRandomFloat( 1, 15 )
			local scale = GetRandomFloat( 0.15, 0.7 )
			proj:SetVelocity( velocity )
			proj:SetBallisticAcceleration( -velocity * 0.6 )
			proj:SetLifetime( velocity * 0.13 )
			proj:SetScale( scale )
			
			-- Debris projectile trails, random chance.
			local randomTrailChance = GetRandomInt( 1, 3 )
			if randomTrailChance > 2 then
				for k, v in EffectTemplates.Units.UEF.Land.UUL0101.UnitDestroyDebrisEffectsTrail01 do
					CreateAttachedEmitter ( proj, -1, self:GetArmy(), v ):ScaleEmitter(scale*2)
				end
			end

			--WaitSeconds( 0.1 )
		end
	end,

    ExplosionTendrils = function( self )
		WaitSeconds(0.2)
        local num_projectiles = GetRandomFloat( 3, 5 )

		for i = 1,num_projectiles do
			local horizontal_angle = (2*math.pi) / num_projectiles
			local angleInitial = GetRandomFloat( 0, horizontal_angle )
			local xVec, yVec, zVec
			local angleVariation = 0.5
			local px, py, pz

			xVec = math.sin(angleInitial + (i*horizontal_angle) + GetRandomFloat(-angleVariation, angleVariation) )
			yVec = GetRandomFloat( 0.5, 1.0 )
			zVec = math.cos(angleInitial + (i*horizontal_angle) + GetRandomFloat(-angleVariation, angleVariation) )
			px = GetRandomFloat( 0.2, 0.9 ) * xVec
			py = GetRandomFloat( 0.1, 0.3 ) * yVec
			pz = GetRandomFloat( 0.2, 0.9 ) * zVec

			local proj = self:CreateProjectile( '/effects/Entities/DebrisMisc04/DebrisMisc04_proj.bp', px, py, pz, xVec, yVec, zVec )
			local velocity = GetRandomFloat( 5, 15 )
			proj:SetVelocity( velocity )
            proj:SetBallisticAcceleration( -velocity * 1.0 )
			proj:SetLifetime( velocity * 0.8 )
			proj:SetScale( GetRandomFloat( 0.15, 0.5 ) )
			
			-- Debris projectile trails, random chance.
			for k, v in EffectTemplates.Units.UEF.Land.UUL0101.UnitDestroyDebrisEffectsTrail02 do
				CreateAttachedEmitter ( proj, -1, self:GetArmy(), v )
			end
		end
	end,

    DeathThread = function( self, overkillRatio, instigator)
        --LOG('*DEBUG: OVERKILL RATIO = ', repr(overkillRatio))
		self:PrecacheDebris()
		-- If we want a destruction delay *** Move these values to bp.
        WaitSeconds( utilities.GetRandomFloat( self.DestructionExplosionWaitDelayMin, self.DestructionExplosionWaitDelayMax) )

		-- Destroy any ambient damage effects on unit
        self:DestroyAllDamageEffects()

		-- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect

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

		-- Create unit wreckage
        self:CreateWreckage( overkillRatio )

		local scale = bp.Physics.SkirtSizeX + bp.Physics.SkirtSizeZ 
		if bp.Death.ScorchDecal then
			CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi), bp.Death.ScorchDecal, '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		else
			CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		end
        
        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,
}