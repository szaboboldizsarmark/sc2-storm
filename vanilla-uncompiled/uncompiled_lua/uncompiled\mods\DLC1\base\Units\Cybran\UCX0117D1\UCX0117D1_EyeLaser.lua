-----------------------------------------------------------------------------
--  File     : /Units/Cybran/UCX0117D1/UCX0117D1_EyeLaser.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : SC2 Cybran Eye Laser Weapon: UCX0117D1_EyeLaser
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local MonkeyLordCollisionBeam = import('/lua/sim/defaultcollisionbeams.lua').MonkeyLordCollisionBeam

EyeLaser = Class(DefaultBeamWeapon) {
    BeamType = MonkeyLordCollisionBeam,
    FxUpackingChargeEffectScale = 1,
    
    OnCreate = function(self)
        DefaultBeamWeapon.OnCreate(self)
        
        self.BeamEffectsBag = {}
        self.Trash = TrashBag()
    end,
    
    OnDestroy = function(self)
        DefaultBeamWeapon.OnDestroy(self)
    
        if self.Trash then
            self.Trash:Destroy()
        end
    end,

    PlayFxWeaponUnpackSequence = function( self )
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self:GetBlueprint()
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,

    PlayFxBeamStart = function(self, muzzle)
        DefaultBeamWeapon.PlayFxBeamStart(self, muzzle)
        
        local army = self.unit:GetArmy()
        for k, v in EffectTemplates.Weapons.Cybran_MonkeyLord01_CustomMuzzle01 do
            local fx = CreateAttachedEmitter(self.unit, 'main_turret_muzzle', army, v)
            table.insert( self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end              
    end,	

    PlayFxBeamEnd = function(self, beam)
        DefaultBeamWeapon.PlayFxBeamEnd(self, beam)
        
        for k, v in self.BeamEffectsBag do
            v:Destroy()
        end
        self.BeamEffectsBag = {}
    end,
}