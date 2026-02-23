-----------------------------------------------------------------------------
--  File     : /units/uef/UUX0105D1/UUX0105D1_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 UEF Battleship: UUX0105D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalSeaUnit = import('/lua/sim/ExperimentalSeaUnit.lua').ExperimentalSeaUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local CollisionBeamFile = import('/lua/sim/defaultcollisionbeams.lua')

UUX0105D1 = Class(ExperimentalSeaUnit) {

    ExhaustEffects = {
		'/effects/emitters/units/uef/uux0105d1/ambient/uux0105d1_a_01_smoke_emit.bp',
    },
    
    OnStopBeingBuilt = function(self)
        ExperimentalSeaUnit.OnStopBeingBuilt(self)
        self.AmbientEffectsBag = {}
        
        -- Exhaust smoke effects
        for k, v in self.ExhaustEffects do
            table.insert( self.AmbientEffectsBag, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
        end
        
        if self:GetBlueprint().Build.UseBuildMaterial then
			self:SetTextureSetByName("Base")
		end
    end,
    
    Weapons = {
        MainTurret01 = Class(DefaultProjectileWeapon) {
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 15, 4, 0.0, 0.0, 0.255 )
		        
		        -- Base dust effects when unit fires
		        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Experimental.UUX0105D1.BaseLaunch01 )
            end,
        },
        FrontTurret01 = Class(DefaultProjectileWeapon) {},
        FrontTurret02 = Class(DefaultProjectileWeapon) {},
		
		RightTurret01 = Class(DefaultProjectileWeapon) {},
        RightTurret02 = Class(DefaultProjectileWeapon) {},
        RightTurret03 = Class(DefaultProjectileWeapon) {},
        
        LeftTurret01 = Class(DefaultProjectileWeapon) {},
        LeftTurret02 = Class(DefaultProjectileWeapon) {},
        LeftTurret03 = Class(DefaultProjectileWeapon) {},
    },
    

}
TypeClass = UUX0105D1