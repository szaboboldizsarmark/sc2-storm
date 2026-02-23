--*****************************************************************************
--* File: lua/modules/ui/lobby/aitypes.lua
--* Author: Chris Blackwell
--* Summary: Contains a list of AI types and names for the game
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

aitypes = {
--	***********************
--	*		Easy
--	***********************
    {
        key = 'Easy',
        name = "<LOC lobui_0432>AI: Easy",
    },
--	***********************
--	*		Medium
--	***********************
    {
        key = 'Normal',
        name = "<LOC lobui_0433>AI: Normal",
    },
--	***********************
--	*		Normal
--	***********************
    {
        key = 'Hard',
        name = "<LOC lobui_0434>AI: Hard",
    },
--	***********************
--	*		Cheat
--	***********************
    {
        key = 'Cheat',
        name = "<LOC lobui_0435>AI: Cheating",
    },
--	***********************
--	*	   Custom
--	***********************
--  This has to be the last AI option in the list. - MR
    {
        key = 'Custom',
        name = "<LOC lobui_0436>AI: Custom",
    },
}

aioptions = {
--	**********************
--	*	Custom AI Settings
--	**********************
	{
		catname = "<LOC lobui_0424>Custom AI Settings",
		{
			{
				reloadrequest = 'default',
				changed = "<LOC lobui_0437>Custom",
				name = "<LOC lobui_0425>AI Profile",
				key = 'aitype',
				preset = false,
				type = "ECAIT_Selection",
				default = {1, 2, 3, 4},
				selectionkeys = {
					"Easy",
					"Normal",
					"Hard",
					"Cheat",
					-- This last key needs to be the last in the list - MR
					"Custom",
				},	
				selections = {
					"<LOC lobui_0438>Easy",
					"<LOC lobui_0439>Normal",
					"<LOC lobui_0440>Hard",
					"<LOC lobui_0441>Cheat",
					-- Custom intentionally left out - MR
				},			
			},
			{
				name = "<LOC lobui_0426>AI Type",
				key = 'aiarchetype',
				preset = false,
				type = "ECAIT_Selection",
				default = {1, 1, 1, 1},
				selectionkeys = {
					"Random",
					"Air",
					"Balanced",
					"Land",
					"Naval",
					"Rush",
					"Turtle",
				},
				selections = {
					"<LOC lobui_0442>Random",
					"<LOC lobui_0443>Air",
					"<LOC lobui_0444>Balanced",
					"<LOC lobui_0445>Land",
					"<LOC lobui_0446>Naval",
					"<LOC lobui_0447>Rush",
					"<LOC lobui_0448>Turtle",
				},			
			},
		},
	},
--	**********************
--	*	Cheating Options
--	**********************
	{
		catname = "<LOC lobui_0427>Cheating Options",
		{
			{
				name = "<LOC lobui_0428>Build Speed Bonus",
				key = 'aibuildbonus',
				preset = true,
				type = "ECAIT_Range",
				default = {-0.25, 0.0, 0.5, 0.9},
				selections = { -0.5, 1.5 },			
			},
			{
				name = "<LOC lobui_0429>Resource Income Bonus",
				key = 'airesourcebonus',
				preset = true,
				type = "ECAIT_Range",
				default = {-0.3, 0.0, 0.65, 1.0},
				selections = { -0.5, 1.5 },			
			},
			{
				name = "<LOC lobui_0449>Unit Veterancy Bonus",
				key = 'aivetbonus',
				preset = true,
				type = "ECAIT_Range",
				default = {0.0, 0.0, 0.25, 1.0},
				selections = { 0.0, 2.0 },			
			},
			{
				name = "<LOC lobui_0430>Intel",
				key = 'aiintel',
				preset = true,
				type = "ECAIT_Selection",
				default = {1, 1, 1, 3},
				selectionkeys = {
					"None",
					"Radar",
					"LOS",
				},	
				selections = {
					"<LOC lobui_0450>No Bonus",
					"<LOC lobui_0451>Full Map Radar Only",
					"<LOC lobui_0452>Full Map Visibility",
				},	
			},
		},
	},
--	**********************
--	*	Behavior
--	**********************
	{
		catname = "<LOC lobui_0431>Behavior",
		{
			{
				name = "<LOC lobui_0453>Target Preference",
				key = 'aitargetpreference',
				preset = true,
				type = "ECAIT_Selection",
				default = {1, 1, 1, 2},
				selectionkeys = {
					"Strongest",
					"Weakest",
				},
				selections = {
					"<LOC lobui_0454>Engage Strongest",
					"<LOC lobui_0455>Cull Weakest",
				},	
			},
		},
	},
}
