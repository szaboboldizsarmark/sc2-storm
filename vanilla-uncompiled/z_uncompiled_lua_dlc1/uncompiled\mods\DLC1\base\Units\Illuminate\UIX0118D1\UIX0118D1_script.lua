-----------------------------------------------------------------------------
--  File     : /units/illuminate/UIX0118D1/UIX0118D1_script.lua
--  Author(s):
--  Summary  : SC2 Illuminate Radar System: UIX0118D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

UIX0118D1 = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
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
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v ):ScaleEmitter(0.5):OffsetEmitter( 0, 7, 0 )
		end
        WaitSeconds(0.4)
        self:CreateExplosionDebris( army, 'left_ref' )
        WaitSeconds(0.1)      
        self:CreateExplosionDebris( army, 'front_ref' )
		WaitSeconds(0.3)
		self:CreateExplosionDebris( army, 'back_ref' )
		self:CreateExplosionDebris( army, 'right_ref' )
		WaitSeconds(0.4)
		
		for k, v in EffectTemplates.Explosions.Land.IlluminateStructureDestroyEffectsExtraLarge01 do
			CreateAttachedEmitter ( self, -2, self:GetArmy(), v )
		end
		
		self:CreateUnitDestructionDebris()
		
		WaitSeconds(0.4)    
        self:CreateWreckage(0.1)
        
        self:Destroy()
    end,
}
TypeClass = UIX0118D1