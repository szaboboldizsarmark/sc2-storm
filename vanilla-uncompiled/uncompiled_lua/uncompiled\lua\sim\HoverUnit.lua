-----------------------------------------------------------------------------
--  File     : /lua/sim/HoverUnit.lua
--  Author(s): Matt Vainio
--  Summary  : Hover Unit, inherits from MobileUnit.Lua, custom logic for hover units dying over water.
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local utilities = import('/lua/system/utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat

HoverUnit = Class(MobileUnit) {

	DestructionExplosionWaitDelayMin = 0,
	DestructionExplosionWaitDelayMax = 0,
	IsHoverUnit = true,

    OnStopBeingBuilt = function(self,builder,layer)
        MobileUnit.OnStopBeingBuilt(self,builder,layer)
        
        local sx, sy, sz = self:GetUnitSizes() 
        self.volume = sx * sz
    end,  
    
    -- By default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)
        self:DestroyIdleEffects()
        if instigator and IsUnit(instigator) then
            instigator:OnKilledUnit(self)
        end
        
        --LOG (self:GetCurrentLayer())
        local layer = self:GetCurrentLayer()
        if not self.IsHoverUnit and layer == 'Land' or layer == 'Air' then
			MobileUnit.OnKilled(self, instigator, type, overkillRatio)
        else
			self.Callbacks.OnKilled:Call(self, instigator, type)
		end		

		if layer == 'Water' then
			self:PlayUnitSound('HoverKilledOnWater')
		end
    end,

    OnImpact = function(self, with, other)   
		if not self:IsDead() then
			return
		end
		
        if with == 'Water' then
            self:PlayUnitSound('AirUnitWaterImpact')
			self:PlayUnitAmbientSound('Sinking')
            
            -- Play water impact effects
            for k, v in EffectTemplates.WaterSplash01 do
                CreateEmitterAtBone( self, -2, self:GetArmy(), v ):ScaleEmitter( self.volume/5 )
            end
            
            self:DestroyAllDamageEffects()
            self:ForkThread(self.SinkingEffects)
        elseif with == 'Seabed' or with == 'Terrain' then
            self:ForkThread(self.DeathThread)
        end
    end,
    
    DeathThread = function(self, overkillRatio, instigator) 
		self:StopUnitAmbientSound('Sinking')

		if self:PrecacheDebris() then
			WaitTicks(1)
		end
		
		-- If we want a destruction delay *** Move these values to bp.
        WaitSeconds( utilities.GetRandomFloat( self.DestructionExplosionWaitDelayMin, self.DestructionExplosionWaitDelayMax) )		

        -- Play destruction effects
		local bp = self:GetBlueprint()
		local deathBp = bp.Death
        local layer = self:GetCurrentLayer()

		if deathBp.ExplosionEffect then
			local emitters = EffectTemplates.Explosions[layer][deathBp.ExplosionEffect]
			
			if emitters then
				CreateBoneEffects( self, -2, self:GetArmy(), emitters )
			end
		end

        if layer == 'Seabed' then
            self:ForkThread(self.SeaFloorImpactEffects)
        else
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

			self:CreateUnitDestructionDebris()

            local scale = (bp.SizeX + bp.SizeZ) * 1.5
		    if deathBp.ScorchDecal then
			    CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi), deathBp.ScorchDecal, '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		    else
			    CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi), '/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), scale * 0.75 )
		    end        
        end

		-- If the unit has a death animation running, wait for it to finish
		if self.DeathAnimManip and not deathBp.DoNotWaitForDeathAnim then
			WaitFor(self.DeathAnimManip)
        end   
        
        --LOG('*DEBUG: OVERKILL RATIO = ', repr(overkillRatio))

		-- Create unit wreckage
        self:CreateWreckage( overkillRatio )

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,

    SeaFloorImpactEffects = function(self)
        CreateAttachedEmitter(self,-2,self:GetArmy(),'/effects/emitters/units/general/event/death/destruction_underwater_seafloordust_01_emit.bp'):ScaleEmitter(self.volume/4)
    end,
    
    SinkingEffects = function(self)
        local i = 2 -- initializing the above surface counter     
        local army = self:GetArmy()
        
        while i >= 0 do
            if i > 0 then
                local rx, ry, rz = self:GetRandomOffset(1)
                local rs = Random(self.volume/2, self.volume*2) / (self.volume*2)
                CreateAttachedEmitter(self,-1,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            end

            local rx, ry, rz = self:GetRandomOffset(1)
            local rs = Random(self.volume/2.5, self.volume*2.5) / (self.volume*2.5)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            CreateAttachedEmitter(self,-2,army,'/effects/emitters/units/general/event/death/destruction_water_sinking_bubbles_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(self.volume/4)
            
            i = i - 1
            WaitSeconds(1)
        end
    end,
}