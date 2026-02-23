--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--
--  File     :  /lua/weatherdefinitions.lua
--  Author(s):  Gordon Duclos, Aaron Lundquist
--
--  Summary  :  Weather definitions
--
--  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--
--------------------------------------------------------------------------

--[[
	Map Style Types:
		Desert
		Evergreen
		Geothermal
		Lava
		RedRock
		Tropical
		Tundra
		
	Style Weather Types: 
		Desert
			LightStratus -
		Evergreen
			CumulusClouds -
			StormClouds -
			RainClouds - WARNING, only use these a ForceType on a weather generator, max 2 per map
		Geothermal
		Lava
		RedRock
			LightStratus -
		Tropical
			LightStratus -
		Tundra
			WhitePatchyClouds - 
			SnowClouds - WARNING, only use these a ForceType on a weather generator, max 2 per map
		
		All Styles:
			Notes: ( Cirrus style cloud emitters, should be used on a ForceType Weather Generator, placed )
				   ( in the center of a map. Take note that the these are sized specific for map scale    )
			CirrusSparse256 - 
			CirrusMedium256 - 
			CirrusHeavy256 - 
			CirrusSparse512 -
			CirrusMedium512 - 
			CirrusHeavy512 - 
			CirrusSparse1024 - 
			CirrusMedium1024 - 
			CirrusHeavy1024 - 
			CirrusSparse4096 - 
			CirrusMedium4096 - 
			CirrusHeavy4096 - 
]]--

-- Map Style Type List - defines the different map styles
MapStyleList = {
	'Desert',
	'Evergreen',
	'Geothermal',
	'Lava',
	'RedRock',
	'Tropical',
	'Tundra',
}

CloudBasePath = '/effects/emitters/ambient/weather/clouds/'
RainBasePath = '/effects/emitters/ambient/weather/rain/'
SnowBasePath = '/effects/emitters/ambient/weather/snow/'

CirrusSparse256Definition = {
	{
		CloudBasePath .. 'weather_cirrus_256_01_emit.bp',	
	},
}
CirrusMedium256Definition = {
	{
		CloudBasePath .. 'weather_cirrus_256_02_emit.bp',	
		CloudBasePath .. 'weather_cirrus_256_03_emit.bp',	
	},
}
CirrusHeavy256Definition = {
	{
		CloudBasePath .. 'weather_cirrus_256_01_emit.bp',
		CloudBasePath .. 'weather_cirrus_256_02_emit.bp',
		CloudBasePath .. 'weather_cirrus_256_03_emit.bp',
		CloudBasePath .. 'weather_cirrus_256_04_emit.bp',
	},
}
CirrusSparse512Definition = {
	{
		CloudBasePath .. 'weather_cirrus_512_01_emit.bp',	
	},
}
CirrusMedium512Definition = {
	{
		CloudBasePath .. 'weather_cirrus_512_02_emit.bp',	
		CloudBasePath .. 'weather_cirrus_512_03_emit.bp',	
	},
}
CirrusHeavy512Definition = {
	{
		CloudBasePath .. 'weather_cirrus_512_01_emit.bp',
		CloudBasePath .. 'weather_cirrus_512_02_emit.bp',
		CloudBasePath .. 'weather_cirrus_512_03_emit.bp',
		CloudBasePath .. 'weather_cirrus_512_04_emit.bp',
	},
}
CirrusSparse1024Definition = {
	{
		CloudBasePath .. 'weather_cirrus_1024_01_emit.bp',	
	},
}
CirrusMedium1024Definition = {
	{
		CloudBasePath .. 'weather_cirrus_1024_02_emit.bp',	
		CloudBasePath .. 'weather_cirrus_1024_03_emit.bp',	
	},
}
CirrusHeavy1024Definition = {
	{
		CloudBasePath .. 'weather_cirrus_1024_01_emit.bp',
		CloudBasePath .. 'weather_cirrus_1024_02_emit.bp',
		CloudBasePath .. 'weather_cirrus_1024_03_emit.bp',
		CloudBasePath .. 'weather_cirrus_1024_04_emit.bp',
	},
}
CirrusSparse4096Definition = {
	{
		CloudBasePath .. 'weather_cirrus_4096_01_emit.bp',	
	},
}
CirrusMedium4096Definition = {
	{
		CloudBasePath .. 'weather_cirrus_4096_02_emit.bp',	
		CloudBasePath .. 'weather_cirrus_4096_03_emit.bp',	
	},    
}
CirrusHeavy4096Definition = {
	{
		CloudBasePath .. 'weather_cirrus_4096_01_emit.bp',
		CloudBasePath .. 'weather_cirrus_4096_02_emit.bp',
		CloudBasePath .. 'weather_cirrus_4096_03_emit.bp',
		CloudBasePath .. 'weather_cirrus_4096_04_emit.bp',
	},
}

-- Map Style Weather Type List - defines the different weather types for each style
MapWeatherList = {
	Desert = {
		LightStratus = {
			{
				CloudBasePath .. 'weather_stratus_09_emit.bp',	-- 40x40		Med			
			},		
			{
				CloudBasePath .. 'weather_stratus_11_emit.bp',	-- 10x10		Med			
			},				
		},
		CirrusSparse256 = CirrusSparse256Definition,
		CirrusMedium256 = CirrusMedium256Definition,
		CirrusHeavy256 = CirrusHeavy256Definition,
		CirrusSparse512 = CirrusSparse512Definition,
		CirrusMedium512 = CirrusMedium512Definition,
		CirrusHeavy512 = CirrusHeavy512Definition,
		CirrusSparse1024 = CirrusSparse1024Definition,
		CirrusMedium1024 = CirrusMedium1024Definition,
		CirrusHeavy1024 = CirrusHeavy1024Definition,
		CirrusSparse4096 = CirrusSparse4096Definition,
		CirrusMedium4096 = CirrusMedium4096Definition,
		CirrusHeavy4096 = CirrusHeavy4096Definition,	
	},
	Evergreen = {
		CumulusClouds = {
			{
				CloudBasePath .. 'weather_stratus_07_emit.bp',	-- 60x50		Med			
			},
			{
				CloudBasePath .. 'weather_stratus_08_emit.bp',	-- 100x100	Med
			},
			{
				CloudBasePath .. 'weather_stratus_09_emit.bp',	-- 40x40		Med
			},
			{
				CloudBasePath .. 'weather_stratus_10_emit.bp',	-- 40x40		Med			
			},	
		},
		StormClouds = {
			{
				CloudBasePath .. 'weather_cumulus_storm_01_emit.bp',	-- 40x40		Heavy			
			},	
			{
				CloudBasePath .. 'weather_cumulus_storm_02_emit.bp',	-- 100x100	Heavy			
			},		
			{
				CloudBasePath .. 'weather_cumulus_storm_03_emit.bp',	-- 40x40		Heavy			
			},	
		},
		RainClouds = {
			{
				CloudBasePath .. 'weather_stratus_08_emit.bp',		-- 100x100	Med
				RainBasePath .. 'weather_rainfall_01_emit.bp',	
			},
		},	    
		CirrusSparse256 = CirrusSparse256Definition,
		CirrusMedium256 = CirrusMedium256Definition,
		CirrusHeavy256 = CirrusHeavy256Definition,
		CirrusSparse512 = CirrusSparse512Definition,
		CirrusMedium512 = CirrusMedium512Definition,
		CirrusHeavy512 = CirrusHeavy512Definition,
		CirrusSparse1024 = CirrusSparse1024Definition,
		CirrusMedium1024 = CirrusMedium1024Definition,
		CirrusHeavy1024 = CirrusHeavy1024Definition,
		CirrusSparse4096 = CirrusSparse4096Definition,
		CirrusMedium4096 = CirrusMedium4096Definition,
		CirrusHeavy4096 = CirrusHeavy4096Definition,			
	},
	Geothermal = {
		CirrusSparse256 = CirrusSparse256Definition,
		CirrusMedium256 = CirrusMedium256Definition,
		CirrusHeavy256 = CirrusHeavy256Definition,
		CirrusSparse512 = CirrusSparse512Definition,
		CirrusMedium512 = CirrusMedium512Definition,
		CirrusHeavy512 = CirrusHeavy512Definition,
		CirrusSparse1024 = CirrusSparse1024Definition,
		CirrusMedium1024 = CirrusMedium1024Definition,
		CirrusHeavy1024 = CirrusHeavy1024Definition,
		CirrusSparse4096 = CirrusSparse4096Definition,
		CirrusMedium4096 = CirrusMedium4096Definition,
		CirrusHeavy4096 = CirrusHeavy4096Definition,	
	},
	Lava = {
		CirrusSparse256 = CirrusSparse256Definition,
		CirrusMedium256 = CirrusMedium256Definition,
		CirrusHeavy256 = CirrusHeavy256Definition,
		CirrusSparse512 = CirrusSparse512Definition,
		CirrusMedium512 = CirrusMedium512Definition,
		CirrusHeavy512 = CirrusHeavy512Definition,
		CirrusSparse1024 = CirrusSparse1024Definition,
		CirrusMedium1024 = CirrusMedium1024Definition,
		CirrusHeavy1024 = CirrusHeavy1024Definition,
		CirrusSparse4096 = CirrusSparse4096Definition,
		CirrusMedium4096 = CirrusMedium4096Definition,
		CirrusHeavy4096 = CirrusHeavy4096Definition,	
	},
	Redrock = {
		LightStratus = {
			{
				CloudBasePath .. 'weather_stratus_09_emit.bp',	-- 40x40		Med			
			},		
			{
				CloudBasePath .. 'weather_stratus_11_emit.bp',	-- 10x10		Med			
			},				
		},	    
		CirrusSparse256 = CirrusSparse256Definition,
		CirrusMedium256 = CirrusMedium256Definition,
		CirrusHeavy256 = CirrusHeavy256Definition,
		CirrusSparse512 = CirrusSparse512Definition,
		CirrusMedium512 = CirrusMedium512Definition,
		CirrusHeavy512 = CirrusHeavy512Definition,
		CirrusSparse1024 = CirrusSparse1024Definition,
		CirrusMedium1024 = CirrusMedium1024Definition,
		CirrusHeavy1024 = CirrusHeavy1024Definition,
		CirrusSparse4096 = CirrusSparse4096Definition,
		CirrusMedium4096 = CirrusMedium4096Definition,
		CirrusHeavy4096 = CirrusHeavy4096Definition,	
	},
	Tropical = {
		LightStratus = {
			{
				CloudBasePath .. 'weather_stratus_09_emit.bp',	-- 40x40		Med			
			},		
			{
				CloudBasePath .. 'weather_stratus_11_emit.bp',	-- 10x10		Med			
			},				
		},
		CirrusSparse256 = CirrusSparse256Definition,
		CirrusMedium256 = CirrusMedium256Definition,
		CirrusHeavy256 = CirrusHeavy256Definition,
		CirrusSparse512 = CirrusSparse512Definition,
		CirrusMedium512 = CirrusMedium512Definition,
		CirrusHeavy512 = CirrusHeavy512Definition,
		CirrusSparse1024 = CirrusSparse1024Definition,
		CirrusMedium1024 = CirrusMedium1024Definition,
		CirrusHeavy1024 = CirrusHeavy1024Definition,
		CirrusSparse4096 = CirrusSparse4096Definition,
		CirrusMedium4096 = CirrusMedium4096Definition,
		CirrusHeavy4096 = CirrusHeavy4096Definition,	
	},
	Tundra = {
		SnowClouds = {
			{															-- Size		Opacity
				CloudBasePath .. 'weather_cumulus_snow_01_emit.bp',	-- 60x50		Heavy	
				SnowBasePath .. 'weather_snow_falling_01_emit.bp',			
			},
			{
				CloudBasePath .. 'weather_cumulus_snow_02_emit.bp',		-- 100x100	Med
				SnowBasePath .. 'weather_snow_falling_01_emit.bp',	
			},
			{
				CloudBasePath .. 'weather_cumulus_snow_03_emit.bp',		-- 40x40		Med
				SnowBasePath .. 'weather_snow_falling_01_emit.bp',	
			},
			{
				CloudBasePath .. 'weather_cumulus_snow_04_emit.bp',		-- 40x40		Med	
				SnowBasePath .. 'weather_snow_falling_01_emit.bp',			
			},
		},
		DuskClouds01 = {										-- Size		Opacity
			{
				CloudBasePath .. 'weather_stratus_20_emit.bp',	-- 60x50		Med			
			},
			{
				CloudBasePath .. 'weather_stratus_21_emit.bp',	-- 100x100		Med
			},
			{
				CloudBasePath .. 'weather_stratus_22_emit.bp',	-- 40x40		Med
			},
			{
				CloudBasePath .. 'weather_stratus_23_emit.bp',	-- 40x40		Med			
			},
		},
		WhitePatchyClouds = {										-- Size		Opacity
			{
				CloudBasePath .. 'weather_stratus_07_emit.bp',	-- 60x50		Med			
			},
			{
				CloudBasePath .. 'weather_stratus_08_emit.bp',	-- 100x100		Med
			},
			{
				CloudBasePath .. 'weather_stratus_09_emit.bp',	-- 40x40		Med
			},
			{
				CloudBasePath .. 'weather_stratus_10_emit.bp',	-- 40x40		Med			
			},
		},
		WhitePatchyClouds02 = {										-- Size		Opacity
			{
				CloudBasePath .. 'weather_stratus_12_emit.bp',	-- 60x50		Med			
			},
			{
				CloudBasePath .. 'weather_stratus_13_emit.bp',	-- 100x100		Med
			},
			{
				CloudBasePath .. 'weather_stratus_14_emit.bp',	-- 40x40		Med
			},
			{
				CloudBasePath .. 'weather_stratus_15_emit.bp',	-- 40x40		Med			
			},
		},
		WhitePatchyClouds03 = {										-- Size		Opacity
			{
				CloudBasePath .. 'weather_stratus_16_emit.bp',	-- 60x50		Med			
			},
			{
				CloudBasePath .. 'weather_stratus_17_emit.bp',	-- 100x100		Med
			},
			{
				CloudBasePath .. 'weather_stratus_18_emit.bp',	-- 40x40		Med
			},
			{
				CloudBasePath .. 'weather_stratus_19_emit.bp',	-- 40x40		Med			
			},
		},
		CirrusSparse256 = CirrusSparse256Definition,
		CirrusMedium256 = CirrusMedium256Definition,
		CirrusHeavy256 = CirrusHeavy256Definition,
		CirrusSparse512 = CirrusSparse512Definition,
		CirrusMedium512 = CirrusMedium512Definition,
		CirrusHeavy512 = CirrusHeavy512Definition,
		CirrusSparse1024 = CirrusSparse1024Definition,
		CirrusMedium1024 = CirrusMedium1024Definition,
		CirrusHeavy1024 = CirrusHeavy1024Definition,
		CirrusSparse4096 = CirrusSparse4096Definition,
		CirrusMedium4096 = CirrusMedium4096Definition,
		CirrusHeavy4096 = CirrusHeavy4096Definition,	
	},
}