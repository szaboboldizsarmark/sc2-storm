--------------------------------------------------------------------------
--
--  File     :  /lua/commom/TerrainTypes.lua
--  Author(s):  Bob Berry, Gordon Duclos, Aaron Lundquist
--
--  Summary  :  Weather definitions, general terrain / movement related effects
--
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--
--------------------------------------------------------------------------

--[[ 
	Each terrain type has a type code that must be unique, with a max of 255. If you
	modify a terrain type you will modify all maps using that type, so be careful.
	Also note that changes in these values can could potentially affect the 
	simulation (for example, the Bumpy type could jostle a unit's orientation as it 
	is driving). 
	 
	In script use GetTerrainType() with the current map o-grid position, to get access
	to the terrain type type table at that location. Position (-1, -1) will return the 
	'Default' terrain type.

	**** SC2 ****
	Terrain type mappings changing, to a small list < 16, functionally this will change with the new 
	terrain system too. Currently purging all old Terrain Types, to be replace soon. -GD
]]--

-- No longer using this path.  Clean up in future.
local EmitterBasePath = '/effects/emitters/'

-- Terrain type definitions

TerrainTypes = {
    {
        Name = 'Default',
        TypeCode = 1,
        Color = 'FFFFFF00',
        Description = 'Default',
        Style = 'Default',
        Slippery = 0,
        Bumpiness = 0,
        Blocking = false,
        FXIdle = {
            Air = {
                CybranAirIdleExhaust01 = {
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_17_smoke_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_18_glow_emit.bp',
				},
				CybranEscapePodMoveExhaust01 = {
					'/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_02_fire_emit.bp',
					'/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_03_smoke_emit.bp',
					'/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_05_glow_emit.bp',
				},
                CybranGunshipIdleExhaust01 = {
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_12_smoke_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_13_glow_emit.bp',
				},
                CybranTransportIdleExhaust01 = {
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_01_fire_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_02_smoke_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_03_glow_emit.bp',
				},
				DroneIdleExhaust01 = {
					'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_03_glow_emit.bp',
					'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_04_plasma_emit.bp',
				},
				IlluminateAirIdleExhaust01 = {
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_17_smoke_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_18_glow_emit.bp',
				},
				IlluminateEscapePodMoveExhaust01 = {
					'/effects/emitters/units/illuminate/uil0001/event/escapepod/movement/uil0001_evt_e_m_02_fire_emit.bp',
					'/effects/emitters/units/illuminate/uil0001/event/escapepod/movement/uil0001_evt_e_m_03_smoke_emit.bp',
					'/effects/emitters/units/illuminate/uil0001/event/escapepod/movement/uil0001_evt_e_m_05_glow_emit.bp',
				},
				IlluminateGunshipIdleExhaust01 = {
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_12_smoke_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_13_glow_emit.bp',
				},
                IlluminateTransportIdleExhaust01 = {
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_01_plasma_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_02_smoke_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_03_glow_emit.bp',
				},
				UCA0021IdleExhaust01 = {
					'/effects/emitters/units/cybran/uca0021/ambient/uca0021_amb_01_glow_emit.bp',
					'/effects/emitters/units/cybran/uca0021/ambient/uca0021_amb_02_electricity_emit.bp',
				},
				UEFAirIdleExhaust01 = {
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_19_glow_emit.bp',
				},
				UEFEscapePodMoveExhaust01 = {
					'/effects/emitters/units/uef/uul0001/event/escapepod/movement/uul0001_evt_e_m_02_fire_emit.bp',
					'/effects/emitters/units/uef/uul0001/event/escapepod/movement/uul0001_evt_e_m_05_glow_emit.bp',
				},
				UEFGunshipIdleExhaust01 = {
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_14_glow_emit.bp',
				},
            	UEFTransportIdleExhaust01 = {
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_01_fire_emit.bp',
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_03_glow_emit.bp',
				},
				UIX0112IdleEffects01 = {
					'/effects/emitters/units/illuminate/uix0112/ambient/uix0112_a_01_ring_emit.bp',
				},
				UIX0116IdleEffects01 = {
					'/effects/emitters/units/illuminate/uix0116/ambient/uix0116_a_01_glow_emit.bp',
					'/effects/emitters/units/illuminate/uix0116/ambient/uix0116_a_02_plasma_emit.bp',
				},
            },
            Land = {
                Cloak01 = { 
					'/effects/emitters/ambient/units/cloak_ambient_01_emit.bp', 
				},
				CybranLandFactory01 = { 
					'/effects/emitters/units/cybran/ucb0001/ambient/ucb0001_ambient_01_emit.bp',
				},
				CybranMagnetron01 = { 
					'/effects/emitters/units/cybran/ucx0114/ambient/ucx0114_amb_01_glow_emit.bp',
					'/effects/emitters/units/cybran/ucx0114/ambient/ucx0114_amb_02_electricity_emit.bp',
				},
				CybranMassExtractor01 = { 
					'/effects/emitters/units/cybran/ucb0701/ambient/cybran_massextractor_01_dirt_emit.bp',
					'/effects/emitters/units/cybran/ucb0701/ambient/cybran_massextractor_02_debris_emit.bp',
				},
				CybranPowerGenerator01 = { 
					'/effects/emitters/units/cybran/ucb0702/ambient/cybran_powergenerator_01_glow_emit.bp',
					'/effects/emitters/units/cybran/ucb0702/ambient/cybran_powergenerator_02_electricity_emit.bp',
				},
				CybranRadar01 = { 
					'/effects/emitters/units/cybran/ucb0303/ambient/cybran_radar_01_rings_emit.bp',
					'/effects/emitters/units/cybran/ucb0303/ambient/cybran_radar_02_pattern_emit.bp',
				},
				CybranRadar02 = { 
					'/effects/emitters/units/cybran/ucb0303/ambient/cybran_radar_03_line_emit.bp',
				},
				CybranResearchStation01 = { 
					'/effects/emitters/units/cybran/ucb0801/ambient/cybran_researchstation_01_emit.bp', -- pyramid
					'/effects/emitters/units/cybran/ucb0801/ambient/cybran_researchstation_02_emit.bp', -- glow
					'/effects/emitters/units/cybran/ucb0801/ambient/cybran_researchstation_04_emit.bp', -- hologram
					'/effects/emitters/units/cybran/ucb0801/ambient/cybran_researchstation_05_emit.bp', -- steam
					'/effects/emitters/units/cybran/ucb0801/ambient/cybran_researchstation_06_emit.bp', -- heat distortion
				},
				CybranMissileLauncher01 = { 
					'/effects/emitters/units/cybran/ucb0204/ambient/cybran_missilelauncher_01_glow_emit.bp',
					'/effects/emitters/units/cybran/ucb0204/ambient/cybran_missilelauncher_03_electricity_emit.bp',
				},
				CybranMissileLauncher02 = { 
					'/effects/emitters/units/cybran/ucb0204/ambient/cybran_missilelauncher_02_smoke_emit.bp',
				},
				CybranProtoBrainBase01 = { 
					'/effects/emitters/units/cybran/ucx0115/ambient/ucx0115_amb_05_steam_emit.bp',
					'/effects/emitters/units/cybran/ucx0115/ambient/ucx0115_amb_01_ring_emit.bp',
					'/effects/emitters/units/cybran/ucx0115/ambient/ucx0115_amb_02_mist_emit.bp',
					'/effects/emitters/units/cybran/ucx0115/ambient/ucx0115_amb_07_core_emit.bp',
					'/effects/emitters/units/cybran/ucx0115/ambient/ucx0115_amb_08_glow_emit.bp',
				},
				CybranShieldGenerator01 = { 
					'/effects/emitters/units/cybran/ucb0202/ambient/cybran_shieldgenerator_01_glow_emit.bp',
					'/effects/emitters/units/cybran/ucb0202/ambient/cybran_shieldgenerator_02_electricity_emit.bp',
					'/effects/emitters/units/cybran/ucb0202/ambient/cybran_shieldgenerator_03_refraction_emit.bp',
					'/effects/emitters/units/cybran/ucb0202/ambient/cybran_shieldgenerator_04_core_emit.bp',
				},
                IlluminateGroundFX01 = { 
					'/effects/emitters/units/illuminate/general/seraphim_groundfx_emit.bp',
				},
				IlluminateGroundFX04 = { 
					'/effects/emitters/units/illuminate/general/seraphim_groundfx_07_emit.bp', 
				},
				IlluminateExpHoverFX01 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_09_expglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_14_expflatglow_emit.bp',				
				},				
				IlluminateExpHoverFX02 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_11_largeexpring_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_16_expdistort_emit.bp',
				},
				IlluminateHoverFX01 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_01_glow_emit.bp',
				},					
				IlluminateHoverFX03 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_07_glow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},	
				IlluminateHoverFX04 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_08_faintglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},		
				IlluminateUIL0202_01 = { 
					'/effects/emitters/units/illuminate/uil0202/ambient/uil0202_amb_03_ringpulse_emit.bp',
				},
				IlluminateUIL0202_02 = { 
					'/effects/emitters/units/illuminate/uil0202/ambient/uil0202_amb_01_electricity_emit.bp',
					'/effects/emitters/units/illuminate/uil0202/ambient/uil0202_amb_02_glow_emit.bp',
					'/effects/emitters/units/illuminate/uil0202/ambient/uil0202_amb_04_ring_emit.bp',
				},
				IlluminateICBMLauncher01 = { 
					'/effects/emitters/units/illuminate/uib0203/ambient/illuminate_icbm_01_base_emit.bp',
					'/effects/emitters/units/illuminate/uib0203/ambient/illuminate_icbm_02_wisps_emit.bp',
					'/effects/emitters/units/illuminate/uib0203/ambient/illuminate_icbm_03_beam_emit.bp',
				},
				IlluminateMassConverter01 = { 
					'/effects/emitters/units/illuminate/uib0704/ambient/illuminate_massconverter_01_glow_emit.bp',
					'/effects/emitters/units/illuminate/uib0704/ambient/illuminate_massconverter_02_swirl_emit.bp',
				},
				IlluminateMassExtractor01 = { 
					'/effects/emitters/units/illuminate/uib0701/ambient/illuminate_massextractor_01_core_emit.bp',
					'/effects/emitters/units/illuminate/uib0701/ambient/illuminate_massextractor_02_base_emit.bp',
					'/effects/emitters/units/illuminate/uib0701/ambient/illuminate_massextractor_03_steam_emit.bp',
				},
				IlluminateMassExtractor02 = { 
					'/effects/emitters/units/illuminate/uib0701/ambient/illuminate_massextractor_03_steam_emit.bp',
				},
				IlluminatePowerGenerator01 = { 
					'/effects/emitters/units/illuminate/uib0702/ambient/illuminate_powergenerator_01_glow_emit.bp',
					'/effects/emitters/units/illuminate/uib0702/ambient/illuminate_powergenerator_02_plasma_emit.bp',
					'/effects/emitters/units/illuminate/uib0702/ambient/illuminate_powergenerator_03_ring_emit.bp',
				},
				IlluminateRadarStation01 = { 
					'/effects/emitters/units/illuminate/uib0301/ambient/illuminate_radar_01_base_emit.bp',
					'/effects/emitters/units/illuminate/uib0301/ambient/illuminate_radar_02_wisps_emit.bp',
					'/effects/emitters/units/illuminate/uib0301/ambient/illuminate_radar_03_beam_emit.bp',
				},
				IlluminateResearchStation01 = { 
					'/effects/emitters/units/illuminate/uib0801/ambient/illuminate_researchstation_01_emit.bp', --rings
				},
				IlluminateResearchStation02 = { 
					'/effects/emitters/units/illuminate/uib0801/ambient/illuminate_researchstation_02_emit.bp', --glow
					'/effects/emitters/units/illuminate/uib0801/ambient/illuminate_researchstation_03_emit.bp', --plasma
					'/effects/emitters/units/illuminate/uib0801/ambient/illuminate_researchstation_04_emit.bp', --inner image
				},
				IlluminateShieldGenerator01 = { 
					'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_01_core_emit.bp',
					'/effects/emitters/units/illuminate/uib0202/ambient/illuminate_shieldgenerator_02_base_emit.bp',
				},
				Radar01 = { 
					'/effects/emitters/ambient/units/radar_ambient_01_emit.bp', 
				},
				UEFLandFactory01 = { 
					'/effects/emitters/units/uef/uub0001/ambient/uef_landfactory_01_steam_emit.bp', 
				},
				UEFMassConverter01 = { 
					'/effects/emitters/units/uef/uub0704/ambient/uef_massconverter_01_steam_emit.bp',
				},
				UEFMassExtractor01 = { 
					'/effects/emitters/units/uef/uub0701/ambient/uef_massextractor_01_dirt_emit.bp',
					'/effects/emitters/units/uef/uub0701/ambient/uef_massextractor_02_debris_emit.bp',
					'/effects/emitters/units/uef/uub0701/ambient/uef_massextractor_03_debris_emit.bp',
					'/effects/emitters/units/uef/uub0701/ambient/uef_massextractor_04_dirt_emit.bp',
				},
				UEFPowerGenerator01 = { 
					'/effects/emitters/units/uef/uub0702/ambient/uef_powergenerator_01_electricity_emit.bp', 
					'/effects/emitters/units/uef/uub0702/ambient/uef_powergenerator_02_glow_emit.bp',
					'/effects/emitters/units/uef/uub0702/ambient/uef_powergenerator_03_steam_emit.bp',
				},
				UEFRadar01 = { 
					'/effects/emitters/units/uef/uub0301/ambient/uef_radar_01_lines_emit.bp',
					'/effects/emitters/units/uef/uub0301/ambient/uef_radar_02_pattern_emit.bp',
				},
				UEFResearchStation01 = { 
					'/effects/emitters/units/uef/uub0801/ambient/uef_researchstation_01_emit.bp', -- inner ring
					'/effects/emitters/units/uef/uub0801/ambient/uef_researchstation_02_emit.bp', -- center glow
					'/effects/emitters/units/uef/uub0801/ambient/uef_researchstation_03_emit.bp', -- outer ring
					'/effects/emitters/units/uef/uub0801/ambient/uef_researchstation_04_emit.bp', -- center
				},
				UEFShieldGenerator01 = { 
					'/effects/emitters/units/uef/uub0202/ambient/uef_shieldgenerator_02_rings_emit.bp',
				},
				UEFUnitCannon01 = { 
					'/effects/emitters/units/uef/uux0114/ambient/uux0114_01_smoke_emit.bp',
				},
            },
            Sub = {
                UnderWater01 = { 
					'/effects/emitters/ambient/units/underwater_idle_bubbles_01_emit.bp',
				},
            },
            Seabed = {
                UnderWater01 = { 
					'/effects/emitters/ambient/units/underwater_idle_bubbles_01_emit.bp', 
				},
            },
            Water = {
            	CybranSeaFactory01 = { 
					'/effects/emitters/units/cybran/ucb0003/ambient/ucb0003_ambient_01_emit.bp',
				},          
				CybranSonar01 = { 
					'/effects/emitters/units/cybran/ucb0303/ambient/cybran_sonar_01_rings_emit.bp',
					'/effects/emitters/units/cybran/ucb0303/ambient/cybran_sonar_02_pattern_emit.bp',
				},
				CybranSonar02 = { 
					'/effects/emitters/units/cybran/ucb0303/ambient/cybran_radar_01_rings_emit.bp',
				},
				CybranSonar03 = { 
					'/effects/emitters/units/cybran/ucb0303/ambient/cybran_radar_03_line_emit.bp',
				},
                IlluminateGroundFX01 = { 
					'/effects/emitters/units/illuminate/general/seraphim_groundfx_emit.bp',
				},
				IlluminateExpHoverFX01 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_09_expglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_14_expflatglow_emit.bp',			
				},				
				IlluminateExpHoverFX02 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_11_largeexpring_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_16_expdistort_emit.bp',
				},
				IlluminateHoverFX01 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_01_glow_emit.bp',
				},
				IlluminateHoverFX03 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_07_glow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},	
				IlluminateHoverFX04 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_08_faintglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},	
				UEFSonar01 = { 
					'/effects/emitters/units/uef/uub0302/ambient/uef_sonar_01_rings_emit.bp',
					'/effects/emitters/units/uef/uub0302/ambient/uef_sonar_02_line_emit.bp',
				},
				SeaIdle01 = { 
				    '/effects/emitters/ambient/units/water_idle_ripples_02_emit.bp', 
					'/effects/emitters/ambient/units/water_idle_ripples_04_emit.bp', 
				},
				SeaIdle02 = { 
					'/effects/emitters/ambient/units/water_idle_ripples_03_emit.bp', 
				},
				SeaIdle03 = { 
					'/effects/emitters/ambient/units/water_idle_ripples_05_emit.bp', 
				},
				SeaIdle04 = { 
					'/effects/emitters/ambient/units/water_idle_ripples_06_emit.bp',
					'/effects/emitters/ambient/units/water_idle_ripples_07_emit.bp',
				},
                SonarBuoy01 = { 
					'/effects/emitters/ambient/units/water_idle_ripples_01_emit.bp', 
				},
				UEFSeaFactory01 = { 
					'/effects/emitters/units/uef/uub0003/ambient/uef_seafactory_01_emit.bp',
				},
            },            
        },
        FXImpact = {
            Terrain = {
                Small01 = { 
					'/effects/emitters/ambient/terrain/tti_dirt02_small01_01_emit.bp', 
				},
                Small02 = { 
					'/effects/emitters/ambient/terrain/tti_dirt02_small02_01_emit.bp', 
				},   
                Medium01 = { 
					'/effects/emitters/ambient/terrain/tti_dirt02_medium01_01_emit.bp', 
				},
                Medium02 = { 
					'/effects/emitters/ambient/terrain/tti_dirt02_medium02_01_emit.bp', 
				},
                Medium03 = { 
					'/effects/emitters/ambient/terrain/tti_dirt02_medium03_01_emit.bp', 
				},
                Large01 = {
					'/effects/emitters/ambient/terrain/tti_dirt02_large01_01_emit.bp',
					'/effects/emitters/ambient/terrain/tti_dirt02_large01_02_emit.bp',
				},
                LargeBeam01 = {
					'/effects/emitters/ambient/terrain/tti_dirt02_largebeam01_01_emit.bp',
					'/effects/emitters/ambient/terrain/tti_dirt02_largebeam01_02_emit.bp',
				},
				LargeBeam02 = {
					'/effects/emitters/ambient/terrain/tti_dirt02_largebeam01_01_emit.bp',
					'/effects/emitters/ambient/terrain/tti_dirt02_largebeam01_02_emit.bp',				
                },
            },
            UnderWater = {
                Small01 = {
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',
                },
            },
            UnitUnderwater = {
                Small01 = {
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',
                },
            },            
            Water = {
                Small01 = {
                    '/effects/emitters/ambient/terrain/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',
                },
                Small02 = {
                    '/effects/emitters/ambient/terrain/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',
                },                
                Medium01 = {
                    '/effects/emitters/ambient/terrain/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',                
                },                
                Medium02 = {
                    '/effects/emitters/ambient/terrain/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',                
                },
                Medium03 = {
                    '/effects/emitters/ambient/terrain/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',                
                },                
                Large01 = {
                    '/effects/emitters/ambient/terrain/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/ambient/terrain/water_splash_plume_02_emit.bp',                
                },                
            },
        },
        FXLayerChange = {
            AirLand = {
                Landing01 = { 
					'/effects/emitters/ambient/units/tt_dirt02_landing01_01_emit.bp', 
					'/effects/emitters/ambient/units/tt_dirt02_landing01_02_emit.bp', 
					'/effects/emitters/ambient/units/tt_dirt02_landing01_03_emit.bp', 
                },
                Landing02 = { 
					'/effects/emitters/ambient/units/layerchange/airland/a_u_lc_al_01_flatflash_emit.bp',
					'/effects/emitters/ambient/units/layerchange/airland/a_u_lc_al_02_dirtlines_emit.bp',
					'/effects/emitters/ambient/units/layerchange/airland/a_u_lc_al_03_debris_emit.bp',
					'/effects/emitters/ambient/units/layerchange/airland/a_u_lc_al_04_smoke_emit.bp',
					'/effects/emitters/ambient/units/layerchange/airland/a_u_lc_al_05_shockwave_emit.bp',
					'/effects/emitters/ambient/units/layerchange/airland/a_u_lc_al_06_smokering_emit.bp',
                },
            },
            LandAir = {
                TakeOff01 = { 
					'/effects/emitters/ambient/units/tt_dirt02_takeoff01_01_emit.bp', 
				},
				CybranTransportLayerChangeExhaust01 = {
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_11_distort_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_08_fire_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_09_smoke_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_10_glow_emit.bp',
				},
				IlluminateTransportLayerChangeExhaust01 = {
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_08_plasma_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_09_smoke_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_10_glow_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_11_distort_emit.bp',
				},
            	UEFTransportLayerChangeExhaust01 = {
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_08_fire_emit.bp',
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_10_glow_emit.bp',
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_11_distort_emit.bp',
				},
            },
            LandWater = {
                Submerge01 = {
                    '/effects/emitters/ambient/units/tt_water_submerge04_02_emit.bp', -- water lines
                    '/effects/emitters/ambient/units/tt_water_submerge04_03_emit.bp', -- mist spray
                    '/effects/emitters/ambient/units/tt_water_submerge04_04_emit.bp', -- surface water
                    '/effects/emitters/ambient/units/tt_water_submerge04_05_emit.bp', -- surface rings
                },
                UIX0102LandWaterFX01 = { 
					'/effects/emitters/units/illuminate/uix0102/movement/water/uix0102_m_w_02_plasmaflat_emit.bp',
				},
            },
            WaterLand = {
                Surface01 = {
                    '/effects/emitters/ambient/units/tt_water_surface03_03_emit.bp', -- surface water
                    '/effects/emitters/ambient/units/tt_water_surface03_04_emit.bp', -- surface rings
                },
                UIX0102WaterLandFX01 = { 
					'/effects/emitters/units/illuminate/uix0102/movement/land/uix0102_m_l_02_dustflat_emit.bp',
				},
            },
        },
        FXMotionChange = {
            SubBottomUp = {
                Surface01 = {
                    '/effects/emitters/ambient/units/tt_water_surface01_01_emit.bp',
                    '/effects/emitters/ambient/units/tt_water_surface01_02_emit.bp',
                    '/effects/emitters/ambient/units/tt_water_surface01_03_emit.bp',
                },
                Surface02 = {
                    '/effects/emitters/ambient/units/tt_water_surface02_01_emit.bp',  -- splashes
                    '/effects/emitters/ambient/units/tt_water_surface02_02_emit.bp', -- flat ripples
                    '/effects/emitters/ambient/units/tt_water_surface02_03_emit.bp',
                    '/effects/emitters/ambient/units/tt_water_surface02_04_emit.bp', -- upward splash
                },
                Surface03 = { -- UCX0113 Krakken and UUX0104 Atlantis
                    '/effects/emitters/ambient/units/tt_water_surface03_01_emit.bp', -- water lines
                    '/effects/emitters/ambient/units/tt_water_surface03_02_emit.bp', -- mist spray
                    '/effects/emitters/ambient/units/tt_water_surface03_03_emit.bp', -- surface water
                    '/effects/emitters/ambient/units/tt_water_surface03_04_emit.bp', -- surface rings
                    '/effects/emitters/ambient/units/tt_water_surface03_05_emit.bp', -- released bubbles at start
                },
                Surface04 = { -- UUS0104 Submarine
                    '/effects/emitters/ambient/units/tt_water_surface04_01_emit.bp', -- water lines
                    '/effects/emitters/ambient/units/tt_water_surface04_02_emit.bp', -- mist spray
                    '/effects/emitters/ambient/units/tt_water_surface04_03_emit.bp', -- surface water
                    '/effects/emitters/ambient/units/tt_water_surface03_04_emit.bp', -- surface rings
                    '/effects/emitters/ambient/units/tt_water_surface03_05_emit.bp', -- released bubbles at start
                },
            },        
            WaterTopDown = {
                Submerge01 = { 
					'/effects/emitters/ambient/units/tt_water_submerge01_01_emit.bp', 
					'/effects/emitters/ambient/units/tt_water_submerge01_02_emit.bp', 
				},
                Submerge02 = { 
					'/effects/emitters/ambient/units/tt_water_submerge02_01_emit.bp', 
					'/effects/emitters/ambient/units/tt_water_submerge02_02_emit.bp',
					'/effects/emitters/ambient/units/tt_water_submerge02_03_emit.bp',
				},
				Submerge03 = {  -- UCX0113 Krakken and UUX0104 Atlantis
                    '/effects/emitters/ambient/units/tt_water_submerge03_01_emit.bp', -- water lines
                    '/effects/emitters/ambient/units/tt_water_submerge03_02_emit.bp', -- mist spray
                    '/effects/emitters/ambient/units/tt_water_surface04_03_emit.bp', -- surface water
                },
                Submerge04 = {  -- UUS0104 Submarine
                    '/effects/emitters/ambient/units/tt_water_submerge04_01_emit.bp', -- water lines
                    '/effects/emitters/ambient/units/tt_water_submerge03_02_emit.bp', -- mist spray
                    '/effects/emitters/ambient/units/tt_water_surface04_03_emit.bp', -- surface water
                },
            },
        },
        FXMovement = {
            Air = {
				CybranAirMovementExhaust01 = {
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_19_fire_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_20_smoke_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_21_glow_emit.bp',
				},
				CybranEscapePodMoveExhaust01 = {
					'/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_02_fire_emit.bp',
					'/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_03_smoke_emit.bp',
					'/effects/emitters/units/cybran/ucl0001/event/escapepod/movement/ucl0001_evt_e_m_05_glow_emit.bp',
				},
				CybranGunshipMovementExhaust01 = {
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_14_fire_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_15_smoke_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_16_glow_emit.bp',
				},
				CybranTransportMovementExhaust01 = {
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_04_fire_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_05_smoke_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_06_glow_emit.bp',
					'/effects/emitters/units/cybran/air/general/movement/cybran_air_g_m_07_distort_emit.bp',
				},
				DroneMovementExhaust01 = {
					'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_03_glow_emit.bp',
					'/effects/emitters/units/scenario/sca3601/movement/sca3601_m_04_plasma_emit.bp',
				},
				IlluminateAirMovementExhaust01 = {
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_19_plasma_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_20_smoke_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_21_glow_emit.bp',
				},
				IlluminateEscapePodMoveExhaust01 = {
					'/effects/emitters/units/illuminate/uil0001/event/escapepod/movement/uil0001_evt_e_m_02_fire_emit.bp',
					'/effects/emitters/units/illuminate/uil0001/event/escapepod/movement/uil0001_evt_e_m_03_smoke_emit.bp',
					'/effects/emitters/units/illuminate/uil0001/event/escapepod/movement/uil0001_evt_e_m_05_glow_emit.bp',
				},
				IlluminateGunshipMovementExhaust01 = {
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_14_plasma_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_15_smoke_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_16_glow_emit.bp',
				},
				IlluminateTransportMovementExhaust01 = {
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_04_plasma_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_05_smoke_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_06_glow_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_07_distort_emit.bp',
				},
				UCA0021MovementExhaust01 = {
					'/effects/emitters/units/cybran/uca0021/ambient/uca0021_amb_01_glow_emit.bp',
					'/effects/emitters/units/cybran/uca0021/ambient/uca0021_amb_02_electricity_emit.bp',
				},
				UEFAirMovementExhaust01 = {
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_20_fire_emit.bp',
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_22_glow_emit.bp',
				},
				UEFEscapePodMoveExhaust01 = {
					'/effects/emitters/units/uef/uul0001/event/escapepod/movement/uul0001_evt_e_m_02_fire_emit.bp',
					'/effects/emitters/units/uef/uul0001/event/escapepod/movement/uul0001_evt_e_m_05_glow_emit.bp',
				},
				UEFGunshipMovementExhaust01 = {
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_15_fire_emit.bp',
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_17_glow_emit.bp',
				},
				UEFTransportMovementExhaust01 = {
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_04_fire_emit.bp',
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_06_glow_emit.bp',
					'/effects/emitters/units/uef/air/general/movement/uef_air_g_m_07_distort_emit.bp',
				},
				UIX0112MovementEffects01 = {
					'/effects/emitters/units/illuminate/uix0112/ambient/uix0112_a_01_ring_emit.bp',
				},
				UIX0116MovementEffects01 = {
					'/effects/emitters/units/illuminate/uix0116/ambient/uix0116_a_01_glow_emit.bp',
					'/effects/emitters/units/illuminate/uix0116/ambient/uix0116_a_02_plasma_emit.bp',
				},
            },        
            Land = {          
                FootFall01 = {
                    '/effects/emitters/ambient/units/tt_dirt02_footfall01_01_emit.bp',
                    '/effects/emitters/ambient/units/tt_dirt02_footfall01_02_emit.bp',
                    '/effects/emitters/ambient/units/tt_dirt02_footfall01_03_emit.bp',
                },
                FootFall02 = { 
					'/effects/emitters/ambient/units/tt_dirt02_footfall02_01_emit.bp', 
				},
                GroundKickup01 = { 
					'/effects/emitters/ambient/units/tt_dirt02_groundkickup01_01_emit.bp', 
				},
                GroundKickup03 = { 
					'/effects/emitters/ambient/units/tt_dirt02_groundkickup03_01_emit.bp', 
				},
				IlluminateUIL0202_02 = { 
					'/effects/emitters/units/illuminate/uil0202/ambient/uil0202_amb_01_electricity_emit.bp',
					'/effects/emitters/units/illuminate/uil0202/ambient/uil0202_amb_02_glow_emit.bp',
				},
                IlluminateGroundFX01 = { 
					'/effects/emitters/units/illuminate/general/seraphim_groundfx_emit.bp',
				},
				IlluminateGroundFX04 = { 
					'/effects/emitters/units/illuminate/general/seraphim_groundfx_07_emit.bp',
				},
				IlluminateExpHoverFX01 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_09_expglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_14_expflatglow_emit.bp',				
				},				
				IlluminateExpHoverFX02 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_16_expdistort_emit.bp',
				},
				IlluminateHoverFX01 = { 
				    '/effects/emitters/units/illuminate/general/hover/general_hvr_01_glow_emit.bp',
				},
				IlluminateHoverFX03 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_07_glow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},	
				IlluminateHoverFX04 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_08_faintglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},	
				UIX0102GroundFX01 = { 
					'/effects/emitters/units/illuminate/uix0102/movement/land/uix0102_m_l_01_dustflat_emit.bp',
				},
				UIX0102Movement01 = { 
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_04_plasma_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_06_glow_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_07_distort_emit.bp',
				},
				UUX0101Movement01 = { 
					'/effects/emitters/units/uef/uux0101/movement/uux0101_01_dust_emit.bp', 
				},
            },
            Sub = {
                BackWake = { 
					'/effects/emitters/ambient/units/underwater_move_trail_01_emit.bp', 
				},
            }, 
            Seabed = {
                UnderWater01 = { 
					'/effects/emitters/ambient/units/underwater_idle_bubbles_01_emit.bp', 
				},
            },
            Water = {   
                BackWake = {
                    '/effects/emitters/ambient/units/water_move_trail_back_01_emit.bp',
                    '/effects/emitters/ambient/units/water_move_trail_back_02_emit.bp',
                },
                LeftFrontWake = { 
					'/effects/emitters/ambient/units/water_move_wake_front_l_01_emit.bp', 
				},
                RightFrontWake = { 
					'/effects/emitters/ambient/units/water_move_wake_front_r_01_emit.bp', 
				},
				LeftFrontWake02 = { 
					'/effects/emitters/ambient/units/water_move_wake_front_l_02_emit.bp', 
				},
                RightFrontWake02 = { 
					'/effects/emitters/ambient/units/water_move_wake_front_r_02_emit.bp', 
				},
                IlluminateGroundFX01 = { 
					'/effects/emitters/units/illuminate/general/seraphim_groundfx_emit.bp',
				},
				IlluminateExpHoverFX01 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_09_expglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_14_expflatglow_emit.bp',			
				},				
				IlluminateExpHoverFX02 = { 
                    '/effects/emitters/units/illuminate/general/hover/general_hvr_16_expdistort_emit.bp',
                    '/effects/emitters/units/illuminate/general/hover/general_hvr_17_expwake_emit.bp',
				},	
				IlluminateHoverFX01 = { 
				    '/effects/emitters/units/illuminate/general/hover/general_hvr_01_glow_emit.bp',
				},
				IlluminateHoverFX03 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_07_glow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},	
				IlluminateHoverFX04 = { 
					'/effects/emitters/units/illuminate/general/hover/general_hvr_08_faintglow_emit.bp',
					'/effects/emitters/units/illuminate/general/hover/general_hvr_02_ring_emit.bp',
				},	
				UIX0102GroundFX02 = { 
					'/effects/emitters/units/illuminate/uix0102/movement/water/uix0102_m_w_01_plasmaflat_emit.bp',
				},
				UIX0102Movement02 = { 
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_04_plasma_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_06_glow_emit.bp',
					'/effects/emitters/units/illuminate/air/general/movement/illuminate_air_g_m_07_distort_emit.bp',
				},
            },                              
        },
        FXOther = {
			Land = {
				TreeRootDirt01 = { },
			},			
        },
    },
	{
		Name = "Chasm_Bottom",
		TypeCode = 3,
		Color = 'FF00FF00',
		Style = 'Default',
		Blocking = false,
	},
}

-- These are the names of the columns to create and populate (in order) in the editor's
-- TerrainType tool.
EditorColumns = {
    'Name',
    'TypeCode',
    'Blocking',
    'Style',
    'Description',
}