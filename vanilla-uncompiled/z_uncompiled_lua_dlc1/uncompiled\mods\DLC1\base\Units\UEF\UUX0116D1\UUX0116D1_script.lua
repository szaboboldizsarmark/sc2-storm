-----------------------------------------------------------------------------
--  File     : /units/uef/UUX0116D1/UUX0116D1_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 UEF Shield Generator: UUX0116D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UUX0116D1 = Class(StructureUnit) {

    ShieldActivationEffects = {
		'/effects/emitters/units/uef/uux0116d1/activate/uux0116d1_activate_ring_01_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/activate/uux0116d1_activate_ring_02_emit.bp',
    },
    ShieldEffects = {
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_01_glow_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_02_centerglow_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_03_wisps_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_04_centerwisps_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_07_electricity_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_09_plasma_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_10_largering_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_11_largeglow_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_12_baseglow_emit.bp',
    },   	
    ShieldEffects02 = {
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_05_smallwisps_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_06_smallglow_emit.bp',
		'/effects/emitters/units/uef/uux0116d1/ambient/uef_uux0116d1_08_smallplasma_emit.bp',
    },

    OnCreate = function(self, createArgs)
		StructureUnit.OnCreate(self, createArgs)
		self:InitShieldBones()
		self.ShieldEffectsBag = {}
	end,

    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    InitShieldBones = function(self)
    	self.ShieldBones = {
    		'Tower02',
    		'Tower03', 
    		'Tower04',
    		'Tower05',
    	}
    	self.ShieldSpinner = CreateRotator(self, 'Tower01', 'z', nil, 0, 25 )
    	self.ShieldRotators = {}
		for k, v in self.ShieldBones do
			--table.insert ( self.ShieldRotators, CreateRotator(self, v, 'z', nil, 0, 25 ))
		end

    end,
    
    OnShieldEnabled = function(self)
        self:PlayUnitSound('ShieldOn')
        --StructureUnit.OnShieldEnabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
		
		for kRing, vRing in self.ShieldActivationEffects do
            CreateAttachedEmitter( self, -2, self:GetArmy(), vRing )
        end
        
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
        end

        for kEffect, vEffect in self.ShieldEffects02 do
			table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Tower02', self:GetArmy(), vEffect ) )
			table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Tower03', self:GetArmy(), vEffect ) )
			table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Tower04', self:GetArmy(), vEffect ) )
			table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'Tower05', self:GetArmy(), vEffect ) )
        end
        
		self.ShieldSpinner:SetTargetSpeed(30) 
		for k, v in self.ShieldRotators do
			v:SetTargetSpeed(100) 
		end
		
		StructureUnit.OnShieldEnabled(self)

    end,

    OnShieldDisabled = function(self)
        self:PlayUnitSound('ShieldOff')
        StructureUnit.OnShieldDisabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
		
		self.ShieldSpinner:SetTargetSpeed(0) 
		for k, v in self.ShieldRotators do
			v:SetTargetSpeed(0) 
		end
		self:PlayUnitSound('Pack')
    end,
    
    CreateExplosionDebris = function( self, army, bone )
        for k, v in EffectTemplates.Units.Illuminate.Experimental.UIX0111.Death02 do
            CreateAttachedEmitter( self, bone, army, v )
        end
    end,
    
    DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        -- Create explosion effects
        for k, v in EffectTemplates.Units.UEF.Experimental.UUX0111.Death01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(0.5):OffsetEmitter( 0, 4, 0 )
		end
        WaitSeconds(1.5)
        self:CreateExplosionDebris( army, 'Tower02' )
        WaitSeconds(0.2)      
        self:CreateExplosionDebris( army, 'Tower04' )
		WaitSeconds(0.3)
		self:CreateExplosionDebris( army, 'Tower03' )
		WaitSeconds(0.5)
		
		for k, v in EffectTemplates.Explosions.Land.UEFStructureDestroyEffectsExtraLarge01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v )
		end
		
		self:CreateUnitDestructionDebris()
		
		WaitSeconds(0.5)    
        self:CreateWreckage(0.1)
        
        self:Destroy()
    end,
}
TypeClass = UUX0116D1