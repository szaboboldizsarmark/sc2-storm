-----------------------------------------------------------------------------
--  File     : /lua/sim/MobileUnit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Mobile Unit
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Unit = import('/lua/sim/Unit.lua').Unit
local utilities = import('/lua/system/utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat
local GetRandomInt = utilities.GetRandomInt

MobileUnit = Class(Unit) {

	OnCreate = function(self, createArgs)
		Unit.OnCreate(self, createArgs)

        -- Setup effect emitter bags
        self.MovementEffectsBag = {}
	end,

	OnStopBeingBuilt = function(self, builder, layer)
		Unit.OnStopBeingBuilt(self, builder, layer)

		if self:GetBlueprint().Display.AnimationIdle then
			if (not self.Animator) then
				self.Animator = CreateAnimator(self)
			end
			--LOG( self:GetBlueprint().Display.AnimationIdle )
			self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationIdle, true, false)
		end

        if ( self:GetCurrentLayer() == 'Water' ) then
            self:StartRocking()
            local surfaceAnim = self:GetBlueprint().Display.AnimationSurface
            if not self.SurfaceAnimator and surfaceAnim then
                self.SurfaceAnimator = CreateAnimator(self)
            end
            if surfaceAnim and self.SurfaceAnimator then
                self.SurfaceAnimator:PlayAnim(surfaceAnim):SetRate(1)
            end
        end
	end,

    OnMotionHorzEventChange = function( self, new, old )
        if self:IsDead() then
            return
        end
        local layer = self:GetCurrentLayer()
        local moveType = self:GetBlueprint().Physics.MotionType
        --LOG( 'OnMotionHorzEventChange, unit=', repr(self:GetBlueprint().BlueprintId), ' old = ', old, ', new = ', new, ', layer = ', self:GetCurrentLayer() )

        if ( new == 'Cruise' and not self:IsUnitState( 'Jumping' )) then
            -- This will play the first appropriate StartMove sound that it finds
            self:StopUnitAmbientSound('AmbientHover')

			if not (
			((layer == 'Water') and self:PlayUnitAmbientSound('AmbientMoveWater')) or
			((layer == 'Sub') and self:PlayUnitAmbientSound('AmbientMoveSub')) or
			((layer == 'Land') and self:PlayUnitAmbientSound('AmbientMoveLand')) or
			((layer == 'Air') and self:PlayUnitAmbientSound('AmbientMoveAir'))
			)
			then
				self:PlayUnitAmbientSound('AmbientMove')
			end
            self:StopRocking()
        end

        if ( new == 'Stopped' ) then
            -- Stop ambient sounds
            self:StopUnitAmbientSound( 'AmbientMove' )
            self:StopUnitAmbientSound( 'AmbientMoveWater' )
            self:StopUnitAmbientSound( 'AmbientMoveSub' )
            self:StopUnitAmbientSound( 'AmbientMoveLand' )
            if layer == "Air" or moveType == "RULEUMT_Hover" then
                self:PlayUnitAmbientSound('AmbientHover')
            end
            -- Units in the water will rock back and forth a bit
            if ( layer == 'Water' ) then
                self:StartRocking()
            end
        end

        if self.MovementEffectsExist then
            self:UpdateMovementEffectsOnMotionEventChange( new, old )
        end

		-- Support for SC walking land unit animations
		local bpDisplay = self:GetBlueprint().Display

		if bpDisplay.AnimationWalk then
			if new == 'Cruise' and not self:IsUnitState( 'Jumping' ) and not self.MoveAnimDisabled then
				if (not self.Animator) then
					self.Animator = CreateAnimator(self)
				end

				self.Animator:PlayAnim(bpDisplay.AnimationWalk, true, true)
				self.Animator:SetRate(bpDisplay.AnimationWalkRate or 1)

			elseif ( new == 'Stopped' ) and self.Animator then
				-- only keep the animator around if we are dying and playing a death anim
				-- or if we have an idle anim
				local bpDisplay = self:GetBlueprint().Display
				if(bpDisplay.AnimationIdle and not self:IsDead()) then
					self.Animator:PlayAnim(bpDisplay.AnimationIdle, true, false)
				elseif(not self.DeathAnim or not self:IsDead()) then
					self.Animator:Destroy()
					self.Animator = false
				end
			end
		end
    end,

	OnMotionVertEventChange = function( self, new, old )
        if self:IsDead() then
            return
        end
        local layer = self:GetCurrentLayer()
        --LOG( 'OnMotionVertEventChange, unit=', repr(self:GetBlueprint().BlueprintId), ' old = ', old, ', new = ', new, ', layer = ', self:GetCurrentLayer() )

		-- Support only for walking land unit animations with jump jets
		if new == 'Bottom' and old == 'Down' then
			if self.JumpEffects then
				for k, v in self.JumpEffects do
					v:Destroy()
				end
				self.JumpEffects = nil
			end
			if self:IsMoving() and not self.MoveAnimDisabled then
				if (not self.Animator) then
					self.Animator = CreateAnimator(self)
				end
				local bpDisplay = self:GetBlueprint().Display
				if bpDisplay.AnimationWalk then
					self.Animator:PlayAnim(bpDisplay.AnimationWalk, true, true)
					self.Animator:SetRate(bpDisplay.AnimationWalkRate or 1)
				end
			end
		elseif new == 'Up' and self.Animator then
			local bpDisplay = self:GetBlueprint().Display
			if(bpDisplay.AnimationIdle and not self:IsDead()) then
				self.Animator:PlayAnim(bpDisplay.AnimationIdle, true, false)
			elseif(not self.DeathAnim or not self:IsDead()) then
				self.Animator:Destroy()
				self.Animator = false
			end
		end

        -- Surfacing and sinking, landing and take off idle effects
        if (new == 'Up' and old == 'Bottom') or
           (new == 'Down' and old == 'Top') then
            self:DestroyIdleEffects()
            if new == 'Up' and layer == 'Sub' then
                self:PlayUnitSound('SurfaceStart')
            end
            if new == 'Down' and layer == 'Water' then
                self:PlayUnitSound('SubmergeStart')
                if self.SurfaceAnimator then
                    self.SurfaceAnimator:SetRate(-1)
                end
            end
        end

        if (new == 'Top' and old == 'Up') or
           (new == 'Bottom' and old == 'Down') then
            self:CreateIdleEffects()
            if new == 'Bottom' and layer == 'Sub' then
                self:PlayUnitSound('SubmergeEnd')
            end
            if new == 'Top' and layer == 'Water' then
                self:PlayUnitSound('SurfaceEnd')
                local surfaceAnim = self:GetBlueprint().Display.AnimationSurface
                if not self.SurfaceAnimator and surfaceAnim then
                    self.SurfaceAnimator = CreateAnimator(self)
                end
                if surfaceAnim and self.SurfaceAnimator then
                    self.SurfaceAnimator:PlayAnim(surfaceAnim):SetRate(1)
                end
            end
		end

		self:CreateMotionChangeEffects(new,old)
	end,

    PerformKnockback = function( self, instigator, knockbackDistance, knockbackScale )
		if not instigator then
			return false
		end

        KnockbackScaledByRadius(instigator:GetPosition(), self, knockbackDistance, (knockbackScale or 5) )

		return true
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
		self:StopRocking()
		
        Unit.OnKilled(self, instigator, type, overkillRatio)
    end,

    CreateReclaimEffects = function( self, target )
        PlayReclaimEffects( self, target, self:GetBlueprint().General.Build.Bones.BuildEffectBones or {0,}, self.ReclaimEffectsBag )
    end,

    CreateReclaimEndEffects = function( self, target )
        PlayReclaimEndEffects( self, target )
    end,

    CreateCaptureEffects = function( self, target )
        PlayCaptureEffects( self, target, self:GetBlueprint().General.Build.Bones.BuildEffectBones or {0,}, self.CaptureEffectsBag )
    end,

	PlayAnimationLand = function( self )
		local AnimLand = self:GetBlueprint().Display.AnimationLand
		if AnimLand then
			local LandingAnimManip = CreateAnimator(self)
			LandingAnimManip:SetPrecedence(0)
			self.Trash:Add(LandingAnimManip)
			LandingAnimManip:PlayAnim(AnimLand)
			self:ForkThread(function()
				WaitSeconds(LandingAnimManip:GetAnimationDuration())
				LandingAnimManip:Destroy()
			end)
		end
	end,

	OnUnitJump = function( self, state )
		if state then
			--LOG('Jumpjets engaged')
			self.InJump = true
			self:StopUnitAmbientSound( 'AmbientMove' )
			self:PlayUnitAmbientSound( 'JumpLoop' )
			local bones = self:GetBlueprint().Display.JumpjetEffectBones
			if bones then
				self.JumpEffects = {}
				local army = self:GetArmy()
				for k, v in bones do
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/general/jump_jet_exhaust_01_emit.bp') )
					table.insert( self.JumpEffects, CreateBeamEmitterOnEntity( self, v, army, '/effects/emitters/units/cybran/general/cybran_jumpjets_01_emit.bp') )
				end
			end

			ApplyBuff(self, 'JumpMoveSpeedIncrease01')
		else
			self:StopUnitAmbientSound( 'JumpLoop' )
			self.InJump = false
			if self.JumpEffects then
				for k, v in self.JumpEffects do
					v:Destroy()
				end
				self.JumpEffects = nil
			end

			RemoveBuff(self, 'JumpMoveSpeedIncrease01')
		end
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
			proj:SetScale( scale )

			-- Debris projectile trails, random chance, also adjust the lifetime depending on whether it has a effect trail
			local randomTrailChance = GetRandomInt( 1, 3 )
			if randomTrailChance > 2 then
				for k, v in EffectTemplates.Units.UEF.Land.UUL0101.UnitDestroyDebrisEffectsTrail01 do
					CreateAttachedEmitter( proj, -1, self:GetArmy(), v ):ScaleEmitter(scale*2)
				end
				proj:SetLifetime( velocity * 0.15 )
			else
				proj:SetLifetime( velocity * 0.33 )
			end
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

			CreateAttachedEmitters( proj, -1, self:GetArmy(), EffectTemplates.Units.UEF.Land.UUL0101.UnitDestroyDebrisEffectsTrail02 )
		end
	end,

    DeathThread = function( self, overkillRatio, instigator)
        --LOG('*DEBUG: OVERKILL RATIO = ', repr(overkillRatio))
		-- Destroy idle animation
		if(self.Animator) then
			self.Animator:Destroy()
			self.Animator = false
		end

		self:PrecacheDebris()
		-- If we want a destruction delay *** Move these values to bp.
        WaitSeconds( utilities.GetRandomFloat( self.DestructionExplosionWaitDelayMin, self.DestructionExplosionWaitDelayMax) )

		-- Destroy any ambient damage effects on unit
        self:DestroyAllDamageEffects()

		-- Play destruction effects
		local bp = self:GetBlueprint()
		local deathBp = bp.Death

		if deathBp.ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][deathBp.ExplosionEffect]
			
			if emitters then
				CreateBoneEffects( self, -2, self:GetArmy(), emitters )
			end
		end

		if deathBp.DebrisPieces then
			self:DebrisPieces( self )
		end

		if deathBp.ExplosionTendrils then
			self:ExplosionTendrils( self )
		end

		if deathBp.Light then
			local myPos = self:GetPosition()
			myPos[2] = myPos[2] + 7
			CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 10, 4, 0.1, 0.1, 0.5 )
		end

		-- Create destruction debris fragments.
		self:CreateUnitDestructionDebris()

		-- If the unit has a death animation running, wait for it to finish
        if self.DeathAnimManip and not deathBp.DoNotWaitForDeathAnim then
			WaitFor(self.DeathAnimManip)
        end

		-- Create unit wreckage
        self:CreateWreckage( overkillRatio )
		local scale = (bp.SizeX + bp.SizeZ) * 1.5
		if deathBp.ScorchDecal then
			CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),deathBp.ScorchDecal, '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 1.25 )
		else
			CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 1.25 )
		end

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,

    OnAnimCollision = function(self, bone, x, y, z)
        local layer = self:GetCurrentLayer()
        local bpTable = self:GetBlueprint().Display.MovementEffects

        if bpTable[layer].Footfall then
            bpTable = bpTable[layer].Footfall
            local effects = {}
            local scale = 1
            local offset = nil
            local army = self:GetArmy()
            local boneTable = nil

            if bpTable.Damage then
                local bpDamage = bpTable.Damage
                DamageArea(self, self:GetPosition(bone), bpDamage.Radius, bpDamage.Amount, bpDamage.Type, bpDamage.DamageFriendly )
            end

            if bpTable.CameraShake then
                local shake = bpTable.CameraShake
                self:ShakeCamera( shake.Radius, shake.MaxShakeEpicenter, shake.MinShakeAtRadius, shake.Interval )
            end

            for k, v in bpTable.Bones do
                if bone == v.FootBone then
                    boneTable = v
                    bone = v.FootBone
                    scale = boneTable.Scale or 1
                    offset = bone.Offset
                    if v.Type then
                        effects = self.GetTerrainTypeEffects( 'FXMovement', layer, self:GetPosition(v.FootBone), v.Type )
                    end
                    break
                end
            end

            if boneTable.Tread and self:GetTTTreadType(self:GetPosition(bone)) != 'None' then
                CreateSplatOnBone(self, boneTable.Tread.TreadOffset, 0, boneTable.Tread.TreadMarks, boneTable.Tread.TreadMarksSizeX, boneTable.Tread.TreadMarksSizeZ, 100, boneTable.Tread.TreadLifeTime or 15, army )
                local treadOffsetX = boneTable.Tread.TreadOffset[1]
                if x and x > 0 then
                    if layer != 'Seabed' then
                    self:PlayUnitSound('FootFallLeft')
                    else
                        self:PlayUnitSound('FootFallLeftSeabed')
                    end
                elseif x and x < 0 then
                    if layer != 'Seabed' then
                    self:PlayUnitSound('FootFallRight')
                    else
                        self:PlayUnitSound('FootFallRightSeabed')
                    end
                end
            end

            for k, v in effects do
                CreateEmitterAtBone(self, bone, army, v):ScaleEmitter(scale):OffsetEmitter(offset.x or 0,offset.y or 0,offset.z or 0)
            end

			if layer != 'Seabed' then
				self:PlayUnitSound('FootFallGeneric')
			else
				self:PlayUnitSound('FootFallGenericSeabed')
			end
        end
    end,

    OnLayerChange = function(self, new, old)
        --LOG('LayerChange old=',old,' new=',new,' for ',self:GetBlueprint().BlueprintId )
		Unit.OnLayerChange(self, new, old)
		self:StopUnitAmbientSound( 'AmbientMove' )
		self:StopUnitAmbientSound( 'AmbientMoveWater' )
		self:StopUnitAmbientSound( 'AmbientMoveSub' )
		self:StopUnitAmbientSound( 'AmbientMoveLand' )

		if old != 'None' and old != 'Air' and not self:IsUnitState('Attached') then
			if( new == 'Land' ) then
				self:PlayUnitSound('TransitionLand')
				if not self:PlayUnitAmbientSound('AmbientMoveLand') then
					self:PlayUnitAmbientSound('AmbientMove')
				end
			elseif(( new == 'Water' ) or ( new == 'Seabed' )) then
				self:PlayUnitSound('TransitionWater')
				if not self:PlayUnitAmbientSound('AmbientMoveWater') then
					self:PlayUnitAmbientSound('AmbientMove')
				end
			elseif ( new == 'Sub' ) then
				if not self:PlayUnitAmbientSound('AmbientMoveSub') then
					self:PlayUnitAmbientSound('AmbientMove')
				end
			end
		end

        local bpTable = self:GetBlueprint().Display.MovementEffects
        self:CreateLayerChangeEffects( new, old )
    end,

    OnMotionTurnEventChange = function(self, newEvent, oldEvent)
        if self:IsDead() then
            return
        end

        if newEvent == 'Straight' then
            self:PlayUnitSound('MoveStraight')
        elseif newEvent == 'Turn' then
            self:PlayUnitSound('MoveTurn')
        elseif newEvent == 'SharpTurn' then
            self:PlayUnitSound('MoveSharpTurn')
        end
    end,

    OnTerrainTypeChange = function(self, new, old)
        --LOG('TerrainChange old=',repr(old.Description),' new=',repr(new.Description),' for ',self:GetBlueprint().BlueprintId)
        if self.MovementEffectsExist then
            self:DestroyMovementEffects()
            self:CreateMovementEffects( self.MovementEffectsBag, nil, new )
        end
    end,

    GetTTTreadType = function( self, pos )
        local TerrainType = GetTerrainType( pos.x,pos.z )
        return TerrainType.Treads or 'None'
    end,

    CreateLayerChangeEffects = function( self, new, old )
        local key = old..new
        local bpTable = self:GetBlueprint().Display.LayerChangeEffects[key]

        if bpTable then
            self:CreateTerrainTypeEffects( bpTable.Effects, 'FXLayerChange', key )
        end
        if (self.MovementEffectsBag) then
            self:DestroyMovementEffects()
            self:CreateMovementEffects( self.MovementEffectsBag, nil )
        end
    end,

    UpdateMovementEffectsOnMotionEventChange = function( self, new, old )
        --LOG('UpdateMovementEffectsOnMotionEventChange ', new, ' ', old )
        local layer = self:GetCurrentLayer()
        local bpMTable = self:GetBlueprint().Display.MovementEffects

        if ( new == 'Cruise' ) then
            self:DestroyIdleEffects()
            self:DestroyMovementEffects()
            self:CreateMovementEffects( self.MovementEffectsBag, nil )
			
            if bpMTable[layer].Contrails and self.ContrailEffects then
                self:CreateContrails( bpMTable[layer].Contrails )
            end
            if bpMTable[layer].TopSpeedFX then
                self:CreateMovementEffects( self.MovementEffectsBag, 'TopSpeed' )
            end
			
            if bpMTable.BeamExhaust then
                self:UpdateBeamExhaust( 'Cruise' )
            end
            if self.Detector then
                self.Detector:Enable()
            end
        end

        if ( new == 'Stopped' ) then
            self:DestroyMovementEffects()
            self:DestroyIdleEffects()
			if not self.OnTransport then
				self:CreateIdleEffects()
			end
            if bpMTable.BeamExhaust then
                self:UpdateBeamExhaust( 'Idle' )
            end
            if self.Detector then
                self.Detector:Disable()
            end
        end
    end,

    CreateMovementEffects = function( self, EffectsBag, TypeSuffix, TerrainType )
        local layer = self:GetCurrentLayer()
        local bpTable = self:GetBlueprint().Display.MovementEffects

        if bpTable[layer] then
            bpTable = bpTable[layer]
            local effectTypeGroups = bpTable.Effects


            if bpTable.Treads then
                self:CreateTreads( bpTable.Treads )
				if bpTable.Treads.ScrollTreads then
					self:AddThreadUVRScroller(1, 1, 1.0, bpTable.Treads.ScrollMultiplier or 0.2)
					self:AddThreadUVRScroller(2, 1, -1.0, bpTable.Treads.ScrollMultiplier or 0.2)
				end
            end

            if (not effectTypeGroups or (effectTypeGroups and (table.getn(effectTypeGroups) == 0))) then
                if not self.Footfalls and bpTable.Footfall then
                    LOG('*WARNING: No movement effect groups defined for unit ',repr(self:GetUnitId()),', Effect groups with bone lists must be defined to play movement effects. Add these to the Display.MovementEffects', layer, '.Effects table in unit blueprint. ' )
                end
                return false
            end

            if bpTable.CameraShake then
                self.CamShakeT1 = self:ForkThread(self.MovementCameraShakeThread, bpTable.CameraShake )
            end

            self:CreateTerrainTypeEffects( effectTypeGroups, 'FXMovement', layer, TypeSuffix, EffectsBag, TerrainType )
        end
    end,

	CreateMotionChangeEffects = function( self, new, old )
        local key = self:GetCurrentLayer()..old..new
        local bpTable = self:GetBlueprint().Display.MotionChangeEffects[key]

        if bpTable then
            self:CreateTerrainTypeEffects( bpTable.Effects, 'FXMotionChange', key )
        end
    end,

    DestroyMovementEffects = function( self )
        local bpTable = self:GetBlueprint().Display.MovementEffects
        local layer = self:GetCurrentLayer()

        CleanupEffectBag(self,'MovementEffectsBag')

        -- Cleanup any camera shake going on.
        if self.CamShakeT1 then
            KillThread( self.CamShakeT1 )
            local shake = bpTable[layer].CameraShake
            if shake and shake.Radius and shake.MaxShakeEpicenter and shake.MinShakeAtRadius then
                self:ShakeCamera( shake.Radius, shake.MaxShakeEpicenter * 0.25, shake.MinShakeAtRadius * 0.25, 1 )
            end
        end

        -- Cleanup treads
        if self.TreadThreads then
            for k, v in self.TreadThreads do
                KillThread(v)
            end
            self.TreadThreads = {}
        end

        if bpTable[layer].Treads.ScrollTreads then
            self:RemoveUVRScroller(1)
            self:RemoveUVRScroller(2)
        end
    end,

    OnStartTransportBeamUp = function(self, transport, bone)
        self:DestroyIdleEffects()
        self:DestroyMovementEffects()
        local army =  self:GetArmy()
        self:TransportAnimation()
    end,

    OnStopTransportBeamUp = function(self)
        self:DestroyIdleEffects()
        self:DestroyMovementEffects()
        for k, v in self.TransportBeamEffectsBag do
            v:Destroy()
        end
	end,

    --*******************************************************************
    -- ROCKING
    --*******************************************************************
    -- While not as exciting as Rock 'n Roll, this will make the unit rock from side to side slowly
    -- in the water
    StartRocking = function(self)
        KillThread(self.StopRockThread)
        self.StartRockThread = self:ForkThread( self.RockingThread )
    end,

    StopRocking = function(self)
		if self.StartRockThread then
			KillThread(self.StartRockThread)
			self.StartRockThread = nil
			self.StopRockThread = self:ForkThread( self.EndRockingThread )
		end
    end,

    RockingThread = function(self)
        local bp = self:GetBlueprint().Display
        if not self:IsDead() and (bp.MaxRockSpeed and bp.MaxRockSpeed > 0) then
			if not self.RockManip then
				self.RockManip = CreateRotator( self, 0, 'z', nil, 0, (bp.MaxRockSpeed or 1.5) / 5, (bp.MaxRockSpeed or 1.5) * 3 / 5 )
			    self.Trash:Add(self.RockManip)
				self.RockManip:SetPrecedence(0)
			else
				self.RockManip:ClearGoal()
			end
            while (true) do
                WaitFor( self.RockManip )
                if self:IsDead() then break end -- abort if the unit died
                self.RockManip:SetTargetSpeed( -(bp.MaxRockSpeed or 1.5) )
                WaitFor( self.RockManip )
                if self:IsDead() then break end -- abort if the unit died
                self.RockManip:SetTargetSpeed( bp.MaxRockSpeed or 1.5 )
            end
        end
    end,

    EndRockingThread = function(self)
        local bp = self:GetBlueprint().Display
        if self.RockManip then
            self.RockManip:SetGoal( 0 )
            self.RockManip:SetSpeed( (bp.MaxRockSpeed or 1.5) / 4 )
            WaitFor( self.RockManip )

            if self.RockManip then
                self.RockManip:Destroy()
                self.RockManip = nil
            end
        end
    end,
}