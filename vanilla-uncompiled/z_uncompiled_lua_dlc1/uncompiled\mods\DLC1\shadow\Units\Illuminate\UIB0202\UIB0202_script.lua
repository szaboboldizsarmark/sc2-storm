-----------------------------------------------------------------------------
--  File     :  /units/illuminate/uib0202/uib0202_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  SC2 UIB0202: Illuminate Shield Structure
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local SeaUnit = import('/lua/sim/SeaUnit.lua').SeaUnit
local ABSORB_ENERGY_SPONGE_PERCENT = 0.0125

UIB0202 = Class(StructureUnit) {

    ShieldEffects = {
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_05_glow_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_06_upwardwisps_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_07_plasmacore_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_08_corewisps_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_09_ring_emit.bp',
		'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_10_groundring_emit.bp',
    },

    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self.ShieldEffectsBag = {}
	end,

	OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
		StructureUnit.OnResearchedTechnologyAdded( self, upgradeName, level, modifierGroup )
		if upgradeName == 'IBP_SHIELDENERGYSPONGE' then
			local shield = self:GetShield()
			if shield then
				shield:SetAbsorbEnergySpongePercent( ABSORB_ENERGY_SPONGE_PERCENT )
			end
		end
	end,

    OnShieldEnabled = function(self)
        StructureUnit.OnShieldEnabled(self)
		if self.AnimationManipulator then
			self.AnimationManipulator:SetRate(1)
		end

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
        end

		self.Spinner = CreateRotator(self, 'UIB0202_Ring02', 'y', nil, 0, 60, 360):SetTargetSpeed(-10)
		self.Trash:Add(self.Spinner)
    end,

    OnShieldDisabled = function(self)
        StructureUnit.OnShieldDisabled(self)
		if self.AnimationManipulator then
			self.AnimationManipulator:SetRate(-1)
		end

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,

    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio)
        if self.ShieldEffctsBag then
            for k,v in self.ShieldEffectsBag do
                v:Destroy()
            end
        end
        
        local layer = self:GetCurrentLayer()
        self:DestroyIdleEffects()
		
        if (not self:IsBeingBuilt() or (self:IsBeingBuilt() and self:GetFractionComplete() > 0.5)) and ( layer == 'Water' or layer == 'Seabed' or layer == 'Sub' ) then
			-- Remove any build scaffolding
			if self.BuildScaffoldUnit and not self.BuildScaffoldUnit:IsDead() then
				self.BuildScaffoldUnit:BuildUnitComplete()
			end
			
			if self.DeathWeaponEnabled != false then
				self:DoDeathWeapon()
			end
			
			-- Give us a move type so we can sink
			self:SetImmobile(false)
			self:OccupyGround(false)
			self:SetMotionType('RULEUMT_AmphibiousFloating')
			self:CreateNavigator()
			self:PlayUnitSound('Killed')
			self:PlayUnitAmbientSound('Sinking')
            self.SinkThread = self:ForkThread(self.SinkingThread)
            self.Callbacks.OnKilled:Call( self, instigator, type )
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
        else
            self.DeathBounce = 1
            StructureUnit.OnKilled(self, instigator, type, overkillRatio)
        end
    end,
	
    SinkingThread = function(self)
		if self:PrecacheDebris() then
			WaitTicks(1)
		end

		-- Destroy any ambient damage effects on unit
        self:DestroyAllDamageEffects()

		-- Play destruction effects
		local bp = self:GetBlueprint()
		local ExplosionEffect = bp.Death.ExplosionEffect
		local ExplosionScale = bp.Death.ExplosionEffectScale or 1

		if ExplosionEffect then
			local layer = self:GetCurrentLayer()
			local emitters = EffectTemplates.Explosions[layer][ExplosionEffect]

			if emitters then
                for k, v in emitters do
                    CreateEmitterAtBone( self, -2, self:GetArmy(), v ):ScaleEmitter( ExplosionScale )
                end
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

        self:ForkThread(self.SinkingEffects)
    end,

    OnImpact = function(self, with, other)
		if not self:IsDead() then
			return
		end

        -- This is a bit of safety to keep us from calling the death thread twice in case we bounce twice quickly
        if not self.DeathBounce then
            self:ForkThread(self.DeathThread, self.OverKillRatio )
            self.DeathBounce = 1
        end
    end,

    DeathThread = function(self, overkillRatio, instigator)
        if self:GetCurrentLayer() == 'Water' then
			SeaUnit.DeathThread(self, overkillRatio)
        else
            StructureUnit.DeathThread(self, overkillRatio)
        end
        self:ForkThread(self.SeaFloorImpactEffects)

        -- delay so dust impact effects can cover up the wreckage/prop swap
        WaitSeconds(1.0)

        local bp = self:GetBlueprint()
		self:StopUnitAmbientSound('Sinking')

		-- Create unit wreckage
        self:CreateWreckage( overkillRatio )

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,

    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  / 7
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(vol/12)
    end,

    SinkingEffects = function(self)
        local i = 8 -- initializing the above surface counter
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz / 7
        local army = self:GetArmy()

        while i >= 0 do
            if i > 0 then
                local rx, ry, rz = self:GetRandomOffset(1)
                local rs = Random(vol/2, vol*2) / (vol*2)
                CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                local rx, ry, rz = self:GetRandomOffset(1)
                CreateAttachedEmitter(self,-1,army, '/effects/emitters/units/general/event/death/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            end

            local rx, ry, rz = self:GetRandomOffset(1)
            local rs = Random(vol/2.5, vol*2.5) / (vol*2.5)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_bubbles_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(vol/8)

            i = i - 1
            WaitSeconds(1)
        end
    end,
}
TypeClass = UIB0202