----------------------------------------------------------------------
-- File: lua/common/LightFX.lua
-- Author: Chad Queen
-- Summary: Custom light handling sequences for LightFX-enabled machiens
--
-- Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
--------------------------------------------------------------------------

lightfx = {		
	nuke_launch = {
		loops = 2,
		item_1 = { 
			color = 'FFFF0000',
			duration = 2.0,
		},
		
		item_2 = {
			color = 'FF0000FF',
			duration = 2.0,
		},
	},
	
	antinuke_launch = {
		loops = 1,
		item_1 = { 
			color = 'FFFF0000',
			duration = 2.0,
		},
		
		item_2 = {
			color = 'FFFFFFFF',
			duration = 2.0,
		},
	},
	
	acu_attack = {
		loops = 2,
		item_1 = { 
			color = 'default',
			duration = 2.0,
		},
		
		item_2 = {
			color = '00000000',
			duration = 2.0,
		},
	},	
	
	acu_nuke = {
		loops = 2,
		item_1 = { 
			color = 'FFFF0000',
			duration = 2.0,
		},
		
		item_2 = {
			color = 'FFFFFF00',
			duration = 2.0,
		},
		
		item_3 = {
			color = 'FF00FF00',
			duration = 2.0,
		},
		
		item_4 = {
			color = 'FF00FFFF',
			duration = 2.0,
		},		
		
		item_5 = {
			color = 'FF0000FF',
			duration = 2.0,
		},		
	},	
}