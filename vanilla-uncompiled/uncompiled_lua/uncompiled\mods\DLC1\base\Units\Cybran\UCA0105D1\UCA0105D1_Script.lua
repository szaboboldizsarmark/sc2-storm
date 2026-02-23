-----------------------------------------------------------------------------
--  File     : /units/cybran/UCA0105D1/UCA0105D1_script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Fighter/Bomber: UCA0104
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local AirUnit = import('/lua/sim/AirUnit.lua').AirUnit
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UCA0105D1 = Class(AirUnit) {

	BeamExhaustCruise = {'/effects/emitters/units/cybran/general/cybran_gunship_thruster_beam_02_emit.bp',},
	BeamExhaustIdle = {'/effects/emitters/units/cybran/general/cybran_gunship_thruster_beam_01_emit.bp',},

    Weapons = {
        AntiMissile = Class(DefaultProjectileWeapon) {
			CreateProjectileAtMuzzle = function(self, muzzle)
				local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
				if proj then
					local bp = self:GetBlueprint()
					if bp.Flare then
						proj:AddFlare(bp.Flare)
					end
				end
			end,
        },
    },
    
   	EngineRotateBones = {'VTOL01', 'VTOL02'},
    
    OnStopBeingBuilt = function(self,builder,layer)
        AirUnit.OnStopBeingBuilt(self,builder,layer)
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, 'Thruster', value))
        end

        -- set up the thursting arcs for the engines
        for key,value in self.EngineManipulators do
            --                          XMAX, XMIN, YMAX,YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
            value:SetThrustingParam( 0, 0, -0.3, 0.3, 0, 0, 35, 0.1 )
        end

        for k, v in self.EngineManipulators do
            self.Trash:Add(v)
        end
    end,
}
TypeClass = UCA0105D1