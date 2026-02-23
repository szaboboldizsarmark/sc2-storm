-----------------------------------------------------------------------------
--  File     : /units/uef/UUB0705D1/UUB0705D1_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 UEF Mass Convertor: UUB0705D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UUB0705D1 = Class(StructureUnit) {    

    AmbientEffectBones01 = {
        'FX01',
        'FX02',
        'FX03',
        'FX04',
    },
    
    AmbientEffectBones02 = {
        'FX05',
        'FX06',
        'FX07',
        'FX08',
    },
    
  	AmbientEffects01 = { 
		'/effects/emitters/units/uef/uub0705d1/ambient/uef_researchconverter_01_electricity_emit.bp',
		'/effects/emitters/units/uef/uub0705d1/ambient/uef_researchconverter_02_glow_emit.bp',
	},  
	 
    OnStopBeingBuilt = function(self, createArgs)
		StructureUnit.OnStopBeingBuilt(self, createArgs)	
		self.AmbientEffectsBag = {}

		-- Initialize animset
		self.animset = self:GetBlueprint().AnimSet or nil
		if self.animset then
			self:PushAnimSet(self.animset, "Base");
		end		
    	
		-- Ambient effects
        for k, v in self.AmbientEffectBones01 do
			table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, v, self:GetArmy(), '/effects/emitters/units/uef/uub0705d1/ambient/uef_researchconverter_03_steam_emit.bp' ) )
		end
        
        for kEffect, vEffect in self.AmbientEffects01 do
			for kBone, vBone in self.AmbientEffectBones02 do
				table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, vBone, self:GetArmy(), vEffect ) )
			end
		end
	end,
	
	OnMassConvert = function(self, abilityBP, state )  
		if state == 'activate' then		
			self:SendAnimEvent('OnConvert')
			self:PlayUnitSound('OnConvert')
			
			for k, v in EffectTemplates.Units.UEF.Base.UUB0705D1.ConvertResearch01 do
                CreateAttachedEmitter( self, -2, self:GetArmy(), v ) 
            end		
		end
    end,
}
TypeClass = UUB0705D1