-----------------------------------------------------------------------------
--  File     :  /units/uef/UUX0113D1/UUX0113D1_Script.lua
--  Author(s): Mike Robbins
--  Summary  :  SC2 UEF Mobile Artillery: UUX0113D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UUX0113D1 = Class(ExperimentalMobileUnit) {
    Weapons = {
        MainGun = Class(DefaultProjectileWeapon) {
        
            CreateProjectileAtMuzzle = function(self, muzzle)
				DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)

				-- Light on Muzzle
		        local myPos = self.unit:GetPosition(muzzle)
		        local lightHandle = CreateLight( myPos[1], myPos[2], myPos[3], 0, -1, 0, 12, 4, 0.0, 0.0, 0.255 )
		        
				-- Base dust effects when unit fires
		        CreateBoneEffects( self.unit, -2, self.unit:GetArmy(), EffectTemplates.Units.UEF.Base.UUB0105.BaseLaunch01 )
            end,
		        
            PlayFxWeaponUnpackSequence = function(self)
				DefaultProjectileWeapon.PlayFxWeaponUnpackSequence(self)
				ApplyBuff(self.unit, 'Hunker')
            end,

            PlayFxWeaponPackSequence = function(self)
				DefaultProjectileWeapon.PlayFxWeaponPackSequence(self)
				RemoveBuff(self.unit, 'Hunker')
            end,
		},
    },
}
TypeClass = UUX0113D1