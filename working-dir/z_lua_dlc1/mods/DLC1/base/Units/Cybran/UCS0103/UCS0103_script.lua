-----------------------------------------------------------------------------
--  File     : /units/cybran/ucs0103/ucs0103_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Destroyer: UCS0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCS0103 = Class(SeaUnit) {

    IsWaiting = false,
    ModeWalking = false,

    Weapons = {
        Cannon01 = Class(DefaultProjectileWeapon) {},
        AntiAir01 = Class(DefaultProjectileWeapon) {},
        Torpedo01 = Class(DefaultProjectileWeapon) {
			CreateProjectileForWeapon = function(self, bone)
				local projectile = self:CreateProjectile(bone)
				local damageTable = self:GetDamageTable()
				local bp = self:GetBlueprint()
				local data = {
					Instigator = self.unit,
					Damage = bp.DoTDamage,
					Duration = bp.DoTDuration,
					Frequency = bp.DoTFrequency,
					Type = 'Normal',
					PreDamageEffects = {},
					DuringDamageEffects = {},
					PostDamageEffects = {},
				}
				if projectile and not projectile:BeenDestroyed() then
					projectile:PassData(data)
					projectile:PassDamageData(damageTable)
				end
				return projectile
			end,		
		},
    },

    OnCreate = function(self, createArgs)
        SeaUnit.OnCreate(self, createArgs)

		-- Initialize amphibious walker animset
		local animset = self:GetBlueprint().AnimSet
		if animset then
			self:PushAnimSet(animset, "Base");
		end
		self.HasSeaMoveSpeedBuff = false
		self.HasLandMoveSpeedBuff = false
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        SeaUnit.OnStopBeingBuilt(self,builder,layer)
        -- If created with F2 on land, then play the transform anim.
        if( self:GetCurrentLayer() == 'Land') then
            self:SendAnimEvent( 'OnTransitionToLand' )
            self.AT1 = self:ForkThread(self.TransformThread, true)
			self.ModeWalking = true
		elseif( self:GetCurrentLayer() == 'Water') then
			self:SendAnimEvent( 'OnTransitionToSea' )
            self.AT1 = self:ForkThread(self.TransformThread, false)
			self.ModeWalking = false
        end
    end,
    
    OnAnimStartTrigger = function( self, event )
		if event == 'TransformForLand' then
	        CreateAttachedEmitter(self, -2, self:GetArmy(), '/effects/emitters/ambient/units/tt_water_submerge04_03_emit.bp'):ScaleEmitter(1.4)
		end
	end,

    OnMotionHorzEventChange = function(self, new, old)
        SeaUnit.OnMotionHorzEventChange(self, new, old)
        if self:IsDead() then return end
        if( not self.IsWaiting ) then
            if( self.ModeWalking ) then
                if( old == 'Stopped' ) and not self:IsUnitState( 'Jumping' ) then
                    self:SendAnimEvent( 'OnMove' )
                elseif( new == 'Stopped' ) then
					self:SendAnimEvent( 'OnIdle' )
                end
            end
        end
    end,
	
    OnMotionVertEventChange = function(self, new, old)
        SeaUnit.OnMotionHorzEventChange(self, new, old)
        if self:IsDead() then return end
        if( not self.IsWaiting ) then
            if( self.ModeWalking ) then
                if new == 'Bottom' and old == 'Down' and self:GetCurrentLayer() == 'Land' then
                    self:SendAnimEvent( 'OnMove' )
                elseif new == 'Up' and self:GetCurrentLayer() == 'Land' and self:IsUnitState( 'Jumping' ) then
					self:SendAnimEvent( 'OnIdle' )
                end
            end
        end
    end,

    OnLayerChange = function(self, new, old)
        SeaUnit.OnLayerChange(self, new, old)
		
		if self:IsDead() then
			return
		end
		
        if( old != 'None' ) then
            if( self.AT1 ) then
                self.AT1:Destroy()
                self.AT1 = nil
            end
            local myBlueprint = self:GetBlueprint()
   -- Still Jumping, but coming out of the air
            if ( self.InJump and old == "Air" ) then
        -- If I'm ending my jump on land, hit the ground running
            	if new == "Land" then
            		--LOG("PZ LANDING ON LAND")
            		self.ModeWalking = true
            		self:StopRocking()
					self:AdjustCollisionBox(true)
				-- If I'm ending my jump on water, play normal water transition
            	elseif new == "Water" then
            		--LOG("PZ LANDING ON WATER")
            		self.ModeWalking = false
            		self:SendAnimEvent( 'OnTransitionToSea' )
            		self.AT1 = self:ForkThread(self.TransformThread, false)
            	end
     -- Just started my jump
            elseif ( self.InJump and new == "Air" ) then
        -- Play proper jump start based on the terrain type I came from
				if (old == "Land") then
					self:PushAnimPack( "custom_anim", 'ucs0103_JumpStart_Land', "Override" )
				elseif (old == "Water") then
					self:PushAnimPack( "custom_anim", 'ucs0103_JumpStart_Water', "Override" )
					self:AdjustCollisionBox(true)
				end
				self:SendAnimEvent("OnCustomAnim")
				self:PopAnimPack( "custom_anim", "Override" )
			elseif( new == 'Land' ) then
				self:SendAnimEvent( 'OnTransitionToLand' )
		        self.AT1 = self:ForkThread(self.TransformThread, true)
            elseif( new == 'Water' ) then
				self.ModeWalking = false				
				self:SendAnimEvent( 'OnTransitionToSea' )
                self.AT1 = self:ForkThread(self.TransformThread, false)
            end
        end        
    end,
	
	AdjustCollisionBox = function(self, land)
		local bp = self:GetBlueprint()
		if ( land ) then
			self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0, 2.0,bp.CollisionOffsetZ or 0, bp.SizeX * 0.75, bp.SizeY * 0.85, bp.SizeZ * 0.5 )
		else
			self:SetCollisionShape( 'Box', bp.CollisionOffsetX or 0,(bp.CollisionOffsetY + (bp.SizeY * 0.5)) or 0,bp.CollisionOffsetZ or 0, bp.SizeX * 0.5, bp.SizeY * 0.5, bp.SizeZ * 0.5 )	
		end
	end,

    TransformThread = function(self, land)
        local bp = self:GetBlueprint()

        if( land ) then
            -- Change movement speed to the multiplier in blueprint
			self.ModeWalking = true	
			WaitSeconds(bp.Physics.LayerTransitionDuration)
			ApplyBuff(self, 'CybranLandMoveSpeedRedux01')
			self:AdjustCollisionBox(land)
		else
            -- Revert speed to maximum speed
            WaitSeconds(bp.Physics.LayerTransitionDuration)
            RemoveBuff(self, 'CybranLandMoveSpeedRedux01')
			self:AdjustCollisionBox(land)
        end
        
        self:ApplyMovementSpeedBuffsForLayer(land)
    end,

    DeathThread = function(self, overkillRatio)
        if self:GetCurrentLayer() == 'Seabed' then
			LOG('*DEBUG: DT Water')
			SeaUnit.DeathThread(self, overkillRatio)
        else
			LOG('*DEBUG: DT Other')
            MobileUnit.DeathThread(self, overkillRatio)
        end
        		
		-- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect

		if ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][ExplosionEffect]
			
			if emitters then
				CreateBoneEffects( self, 'ucs0103_Root', self:GetArmy(), emitters )
			end
		end
    end,

    OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
        SeaUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
        if upgradeName == "CSB_SEAMOVESPEED" then
            self:ForkThread(self.SpeedCheck)
        end
    end,

    SpeedCheck = function(self)
        while not self:IsDead() do
            WaitSeconds( 5 )
            self:SetNavMaxSpeedMultiplier(self:GetSpeedMult())
        end
    end,
    
	OnUnitJump = function( self, state )
		if state then
			self.InJump = true
			self:StopUnitAmbientSound( 'AmbientMove' )
			self:PlayUnitAmbientSound( 'JumpLoop' )
			local bones = self:GetBlueprint().Display.JumpjetEffectBones
			if bones then
				self.JumpEffects = {}
				local army = self:GetArmy()
				for k, v in bones do
					table.insert( self.JumpEffects, CreateBeamEmitterOnEntity( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_01_beam_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_02_smoke_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_03_fire_emit.bp') )
					table.insert( self.JumpEffects, CreateAttachedEmitter( self, v, army, '/effects/emitters/units/cybran/ucl0001/event/jump/ucl0001_jumpjet_04_largesmoke_emit.bp') )
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
}
TypeClass = UCS0103