--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     : /lua/defaultcollisionbeams.lua
--  Author(s): Gordon Duclos
--  Summary  : Default definitions collision beams
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam

-------------------------------
--   Base class that defines supreme commander specific defaults
-------------------------------
SCCollisionBeam = Class(CollisionBeam) {
    FxImpactUnit = nil,
    FxImpactLand = {},
    FxImpactWater = nil,
    FxImpactUnderWater = nil,
    FxImpactAirUnit = nil,
    FxImpactProp = {},
    FxImpactShield = {},    
    FxImpactNone = {},
}

ZapperCollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {
	    '/effects/emitters/weapons/uef/antimissile01/projectile/w_u_am01_p_01_polytrails_emit.bp',
    },
    FxBeamEndPoint = {
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_01_flash_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_02_largeflash_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_03_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_04_sparks_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_05_smoke_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_06_debris_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_07_spikeflash_emit.bp',
    },
}

ZapperCollisionBeam02 = Class(SCCollisionBeam) {
    FxBeam = {
	    '/effects/emitters/weapons/uef/antimissile01/projectile/w_u_am01_p_02_polytrails_emit.bp',
    },
    FxBeamEndPoint = {
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_01_flash_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_02_largeflash_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_03_shockwave_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_04_sparks_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_05_smoke_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_06_debris_emit.bp',
		'/effects/emitters/weapons/uef/antimissile01/impact/unit/w_u_am01_i_u_07_spikeflash_emit.bp',
    },
}

MegalithCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 1,
        
    FxBeam = {
		'/effects/emitters/weapons/cybran/laser04/projectile/w_c_las04_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_01_groundflash_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_03_sparks_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_04_electricity_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_05_debris_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_06_smoke_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_07_ring_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_09_lines_emit.bp',
	},
    FxBeamStartPoint = {
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_01_flash_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_02_glow_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_03_line_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_04_sparks_emit.bp',
    },
}

BrainCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 1,
        
    FxBeam = {
		'/effects/emitters/weapons/cybran/laser04/projectile/w_c_las04_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {		
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_05_debris_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_07_ring_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_09_lines_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/impact/unit/w_c_las04_i_u_10_sparks_emit.bp',
	},
    FxBeamStartPoint = {
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_01_flash_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_02_glow_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_03_line_emit.bp',
		'/effects/emitters/weapons/cybran/laser04/launch/w_c_las04_l_04_sparks_emit.bp',
    },
}

CollosusCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = {
		'/effects/emitters/weapons/illuminate/beam01/launch/w_i_bem01_l_01_flash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/launch/w_i_bem01_l_02_leftflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/launch/w_i_bem01_l_03_rightflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/launch/w_i_bem01_l_04_spin_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/launch/w_i_bem01_l_05_fwdflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/launch/w_i_bem01_l_22_fwdembers_emit.bp',
	},
    FxBeam = {
		'/effects/emitters/weapons/illuminate/beam01/projectile/w_i_bem01_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/effects/emitters/weapons/illuminate/beam01/impact/unit/w_i_bem01_i_u_01_groundflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/impact/unit/w_i_bem01_i_u_02_flash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/impact/unit/w_i_bem01_i_u_03_sparks_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/impact/unit/w_i_bem01_i_u_04_plasma_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/impact/unit/w_i_bem01_i_u_06_plasmasmoke_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/impact/unit/w_i_bem01_i_u_07_ring_emit.bp',
		'/effects/emitters/weapons/illuminate/beam01/impact/unit/w_i_bem01_i_u_08_topflash_emit.bp',
    },
}

DarkenoidMainCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = {
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_01_flash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_02_flatflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_03_flatflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_04_spin_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_05_electricity_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_06_lines_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_07_centerline_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_08_beamlines_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_10_darkbeamlines_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/launch/w_i_bem02_l_11_ring_emit.bp',
	},
    FxBeam = {
		'/effects/emitters/weapons/illuminate/beam02/projectile/w_i_bem02_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_01_groundflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_02_flatgroundflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_03_sparks_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_04_plasma_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_06_flatcenterglow_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_07_ring_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_08_ring_emit.bp',
		'/effects/emitters/weapons/illuminate/beam02/impact/unit/w_i_bem02_i_u_09_lines_emit.bp',
    },
}

DarkenoidSmallCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = {
		'/effects/emitters/weapons/illuminate/beam03/launch/w_i_bem03_l_01_flash_emit.bp',
	},
    FxBeam = {
		'/effects/emitters/weapons/illuminate/beam03/projectile/w_i_bem03_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/effects/emitters/weapons/illuminate/beam03/impact/unit/w_i_bem03_i_u_01_groundflash_emit.bp',
		'/effects/emitters/weapons/illuminate/beam03/impact/unit/w_i_bem03_i_u_02_flatglow_emit.bp',
		'/effects/emitters/weapons/illuminate/beam03/impact/unit/w_i_bem03_i_u_05_plasmaflat_emit.bp',
		'/effects/emitters/weapons/illuminate/beam03/impact/unit/w_i_bem03_i_u_06_plasmasmoke_emit.bp',
		'/effects/emitters/weapons/illuminate/beam03/impact/unit/w_i_bem03_i_u_09_lines_emit.bp',
    },
}

ElectroShockCollisionBeam = Class(SCCollisionBeam) {
    FxBeam = {
	    '/effects/emitters/weapons/illuminate/electroshock01/projectile/w_i_es01_p_01_polytrails_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/effects/emitters/weapons/illuminate/electroshock01/impact/unit/w_i_es01_i_u_01_groundflash_emit.bp',
		'/effects/emitters/weapons/illuminate/electroshock01/impact/unit/w_i_es01_i_u_02_cameraflash_emit.bp',
		'/effects/emitters/weapons/illuminate/electroshock01/impact/unit/w_i_es01_i_u_03_sparks_emit.bp',
		'/effects/emitters/weapons/illuminate/electroshock01/impact/unit/w_i_es01_i_u_04_plasma_emit.bp',
		'/effects/emitters/weapons/illuminate/electroshock01/impact/unit/w_i_es01_i_u_05_plasmasmoke_emit.bp',
		'/effects/emitters/weapons/illuminate/electroshock01/impact/unit/w_i_es01_i_u_07_glow_emit.bp',
		'/effects/emitters/weapons/illuminate/electroshock01/impact/unit/w_i_es01_i_u_08_lines_emit.bp',
    },
}

KrakenCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = {
		'/effects/emitters/weapons/cybran/laser06/launch/w_c_las06_l_01_flash_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/launch/w_c_las06_l_02_core_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/launch/w_c_las06_l_03_center_emit.bp',
	},
    FxBeam = {
		'/effects/emitters/weapons/cybran/laser06/projectile/w_c_las06_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_01_flash_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_02_debris_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_03_sparks_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_04_electricity_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_05_core_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_06_smoke_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_07_ring_emit.bp',
		'/effects/emitters/weapons/cybran/laser06/impact/unit/w_c_las06_i_u_08_lines_emit.bp',
    },
}

DeathClawCollisionBeam = Class(CollisionBeam) {
    
    FxBeam = EffectTemplates.ACollossusTractorBeam01,
    FxBeamEndPoint = EffectTemplates.ACollossusTractorBeamGlow02,
    FxBeamEndPointScale = 1.0,
    FxBeamStartPoint = EffectTemplates.ACollossusTractorBeamGlow01,

    CreateBeamEffects = function(self)
        local army = self:GetArmy()
        for k, y in self.FxBeamStartPoint do
            local fx = CreateAttachedEmitter(self, 0, army, y ):ScaleEmitter(self.FxBeamStartPointScale)
            table.insert( self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        for k, y in self.FxBeamEndPoint do
            local fx = CreateAttachedEmitter(self, 1, army, y ):ScaleEmitter(self.FxBeamEndPointScale)
            table.insert( self.BeamEffectsBag, fx)
            self.Trash:Add(fx)
        end
        if table.getn(self.FxBeam) != 0 then
            local fxBeam = CreateBeamEmitter(self.FxBeam[Random(1, table.getn(self.FxBeam))], army)
            AttachBeamToEntity(fxBeam, self, 0, army)
            
            -- Give the beam effect to the collision beam to adjust the beam length over distances.
            self:SetBeamFx(fxBeam, true)
            
            table.insert( self.BeamEffectsBag, fxBeam )
            self.Trash:Add(fxBeam)
        else
            LOG('*ERROR: THERE IS NO BEAM EMITTER DEFINED FOR THIS COLLISION BEAM ', repr(self.FxBeam))
        end
    end,
}

MonkeyLordCollisionBeam = Class(SCCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = {
		'/effects/emitters/weapons/cybran/laser09/launch/w_c_las09_l_01_flash_emit.bp',
		'/effects/emitters/weapons/cybran/laser09/launch/w_c_las09_l_02_largeflash_emit.bp',
		'/effects/emitters/weapons/cybran/laser09/launch/w_c_las09_l_03_embers_emit.bp',
	},
    FxBeam = {
		'/effects/emitters/weapons/cybran/laser09/projectile/w_c_las09_p_01_beam_emit.bp',
    },
    FxBeamEndPoint = {     	
		'/effects/emitters/weapons/cybran/laser09/impact/unit/w_c_las09_i_u_01_groundglow_emit.bp',
		'/effects/emitters/weapons/cybran/laser09/impact/unit/w_c_las09_i_u_02_glow_emit.bp',
		'/effects/emitters/weapons/cybran/laser09/impact/unit/w_c_las09_i_u_03_sparks_emit.bp',
		'/effects/emitters/weapons/cybran/laser09/impact/unit/w_c_las09_i_u_04_redsmoke_emit.bp',
		'/effects/emitters/weapons/cybran/laser09/impact/unit/w_c_las09_i_u_05_whitesmoke_emit.bp',
    },
}