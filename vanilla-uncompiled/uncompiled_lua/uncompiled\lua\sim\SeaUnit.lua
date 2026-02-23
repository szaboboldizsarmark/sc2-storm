-----------------------------------------------------------------------------
--  File     : /lua/sim/SeaUnit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Sea Unit, these units typically float on the water
--			   and have wake when they move.
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local utilities = import('/lua/system/utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat
local GetRandomInt = utilities.GetRandomInt

SeaUnit = Class(MobileUnit) {

    DestructionExplosionWaitDelayMax = 0,

    OnStopBeingBuilt = function(self,builder,layer)
        MobileUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionActive()
    end,

    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
        local layer = self:GetCurrentLayer()
        self:DestroyIdleEffects()
        self:DestroyMovementEffects()
        if (not self:IsBeingBuilt() or (self:IsBeingBuilt() and self:GetFractionComplete() > 0.5)) and ( layer == 'Water' or layer == 'Seabed' or layer == 'Sub' ) then
			-- Remove any build scaffolding
			if self.BuildScaffoldUnit and not self.BuildScaffoldUnit:IsDead() then
				self.BuildScaffoldUnit:BuildUnitComplete()
			end
			
			self:PlayUnitSound('Killed')
			self:PlayUnitAmbientSound('Sinking')
            self.SinkThread = self:ForkThread(self.SinkingThread)
            self.Callbacks.OnKilled:Call( self, instigator, type )
            if instigator and IsUnit(instigator) then
                instigator:OnKilledUnit(self)
            end
        else
			if layer != 'Air' then
				self.DeathBounce = 1
			end
            MobileUnit.OnKilled(self, instigator, type, overkillRatio)
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
				--CreateBoneEffects( self, -2, self:GetArmy(), emitters )
				
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
        if with == 'Water' and not self.DeathBounce then
			self:PlayUnitAmbientSound('Sinking')
            self.SinkThread = self:ForkThread(self.SinkingThread)
		elseif not self.DeathBounce then
            self:ForkThread(self.DeathThread, self.OverKillRatio )
            self.DeathBounce = 1
        end
    end,
    
    DeathThread = function(self, overkillRatio, instigator)
        self:ForkThread(self.SeaFloorImpactEffects)
		self:PrecacheDebris()
        -- delay so dust impact effects can cover up the wreckage/prop swap
        WaitSeconds(1.0)    
    
        --LOG('*DEBUG: OVERKILL RATIO = ', repr(overkillRatio))

        local bp = self:GetBlueprint()
		self:StopUnitAmbientSound('Sinking')

		-- Create unit wreckage
        self:CreateWreckage( overkillRatio )

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,

    SeaFloorImpactEffects = function(self)
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz  
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(vol/12)
    end,
    
    SinkingEffects = function(self)
        local i = 8 -- initializing the above surface counter
        local sx, sy, sz = self:GetUnitSizes()
        local vol = sx * sz        
        local army = self:GetArmy()
        
        while i >= 0 do
            if i > 0 then
                local rx, ry, rz = self:GetRandomOffset(1)
                local rs = Random(vol/2, vol*2) / (vol*2)
                CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                local rx, ry, rz = self:GetRandomOffset(1)
                CreateAttachedEmitter(self,self.LeftFrontWakeBone,army, '/effects/emitters/units/general/event/death/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                local rx, ry, rz = self:GetRandomOffset(1)
                CreateAttachedEmitter(self,self.RightFrontWakeBone,army, '/effects/emitters/units/general/event/death/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
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