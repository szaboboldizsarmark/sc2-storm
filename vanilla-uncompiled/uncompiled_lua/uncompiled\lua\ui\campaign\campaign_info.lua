--****************************************************************************
--**
--**  File     : /data/lua/ui//campaign/campaign_info.lua
--**  Author(s): Chad Queen
--**
--**  Summary  : Contains data and strings used by the UI for campaigns.
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

CampaignInfo = {

	ops_per_faction = 6,
	
	medals = {
		pc = {
			difficulty_1 = '/textures/ui/common/pc/frontend/summary/medal_bronze.dds',
			difficulty_2 = '/textures/ui/common/pc/frontend/summary/medal_silver.dds',
			difficulty_3 = '/textures/ui/common/pc/frontend/summary/medal_gold.dds',
			off = '/textures/ui/common/pc/frontend/summary/medal_off.dds',			
			star_off = '/textures/ui/common/pc/frontend/summary/star_off.dds',
			star_on = '/textures/ui/common/pc/frontend/summary/star_on.dds',
		},
		
		gamepad = {
			difficulty_1 = '/textures/ui/common/360/hd/common/medal_bronze.dds',
			difficulty_2 = '/textures/ui/common/360/hd/common/medal_silver.dds',
			difficulty_3 = '/textures/ui/common/360/hd/common/medal_gold.dds',
			off = '/textures/ui/common/360/hd/common/medal_grey.dds',
			star_off = '/textures/ui/common/360/hd/summary/rating_grey.dds',
			star_on = '/textures/ui/common/360/hd/summary/rating_gold.dds',
		},
	},
	
	sounds = {
		highlight = "SC2/SC2/Interface/XBOX360/Campaign/snd_UI_360_Campaign_Generic_Highlight",
		select = "SC2/SC2/Interface/XBOX360/Campaign/snd_UI_360_Campaign_Generic_Select",
		launch = "SC2/SC2/Interface/XBOX360/Campaign/snd_UI_360_Campaign_Launch",
	},
	
	UEF = {		
		gamepad = {
			title = '<LOC CAMPAIGN_INFO_000>Campaign - UEF',
			logo = '/textures/ui/common/360/hd/campaign/uef/uef_logo.dds',
			op_image_dir = '/textures/ui/common/360/hd/campaign/uef/',		
			movie = '/movies/UEF_Campaign',
		},
		pc = {
			op_image_dir = '/textures/ui/common/pc/frontend/campaign/ops/uef',		
			movie = '/movies/UEF_Campaign',
			faction_logo = '/textures/ui/common/pc/frontend/summary/logo_uef.dds',
		},
	},
	
	Cybran = {		
		gamepad = {
			title = '<LOC CAMPAIGN_INFO_001>Campaign - Cybran',
			logo = '/textures/ui/common/360/hd/campaign/cybran/cyb_logo.dds',
			op_image_dir = '/textures/ui/common/360/hd/campaign/cybran/',	
			movie = '/movies/CYBRAN_Campaign',	
		},
		pc = {
			op_image_dir = '/textures/ui/common/pc/frontend/campaign/ops/cybran',	
			movie = '/movies/CYBRAN_Campaign',	
			faction_logo = '/textures/ui/common/pc/frontend/summary/logo_cybran.dds',
		},
	},
	
	Illuminate = {	
		
		gamepad = {
			title = '<LOC CAMPAIGN_INFO_002>Campaign - Illuminate',
			logo = '/textures/ui/common/360/hd/campaign/illuminate/ill_logo.dds',
			op_image_dir = '/textures/ui/common/360/hd/campaign/illuminate/',		
			movie = '/movies/Ill_Campaign',
		},
		pc = {
			op_image_dir = '/textures/ui/common/pc/frontend/campaign/ops/illuminate',		
			movie = '/movies/Ill_Campaign',
			faction_logo = '/textures/ui/common/pc/frontend/summary/logo_illuminate.dds',
		},
	},	
	
	Tutorial = {
	
		gamepad = {
			title = '<LOC CAMPAIGN_INFO_003>Campaign - Tutorial',
			logo = '/textures/ui/common/360/hd/campaign/uef/uef_logo.dds',
			op_image_dir = '/textures/ui/common/360/hd/campaign/uef/',		
			movie = '/movies/UEF_Campaign',
		},
		pc = {
			op_image_dir = '/textures/ui/common/pc/frontend/campaign/ops/uef',		
			movie = '/movies/UEF_Campaign',
			faction_logo = '/textures/ui/common/pc/frontend/summary/logo_uef.dds',
		},
		
	},	
}