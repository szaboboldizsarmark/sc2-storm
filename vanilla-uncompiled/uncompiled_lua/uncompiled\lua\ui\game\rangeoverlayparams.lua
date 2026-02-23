--*****************************************************************************
--* File: lua/modules/ui/game/rangeoverlayparams.lua
--* Author: ???
--* Summary: Range overlay definitions
--*
--* "NormalColor" - overlay color used (AARRGGBB, AA = glow amount)
--* "SelectedColor" - overlay color when the unit is selected (RRGGBB
--* "RolloverColor" - overlay color when the unit is hovered over (RRGGBB
--* "Inner" - Thickness of minimum range line (zoomed in, zoomed out)
--* "Outer" - Thickness of maximum range line (zoomed in, zoomed out)
--*
--* Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local innerMilAll = {0.03,3.0}
local outerMilAll = {0.06,6.0}
local innerMilitary = {0.02,2.0}
local outerMilitary = {0.04,4.0}

local innerIntelAll = {1,1} -- Not really used
local outerIntelAll = {0.03,3.0}
local innerIntel = {1,1} -- Not really used
local outerIntel = {0.02,2.0}

local glowAllNormal = '08'
local glowAllSelect = '08'
local glowAllOver = '08'

local glowMilNormal = '08'
local glowMilSelect = '08'
local glowMilOver = '08'

local glowIntelNormal = '08'
local glowIntelSelect = '08'
local glowIntelOver = '08'


RangeOverlayParams = { 
	AllIntel = {
        key = 'allintel',
        Label = '<LOC range_0013>Combine Intel',
        Categories = categories.OVERLAYRADAR * categories.OVERLAYSONAR * categories.OVERLAYCOUNTERINTEL,
        NormalColor = glowIntelNormal..'36648b',
        SelectColor = glowIntelSelect..'104e8b',
        RolloverColor = glowIntelOver..'045aae',
        Inner = innerIntelAll,
        Outer = outerIntelAll,
        Type = 2,
        Combo = true,
        Tooltip = "overlay_combine_intel",
        UseCutOut = true,
    },     
    Maximum = {
        key = 'directfire',
        Label = '<LOC range_0003>Primary Weapon Range',
        Categories = categories.ALLUNITS,
        NormalColor = glowMilNormal..'b92121',
        SelectColor = glowMilSelect..'971f1f',
        RolloverColor = glowMilOver..'c80000',
        Inner = innerMilitary,
        Outer = outerMilitary,
        Type = 1,
        Tooltip = "overlay_direct_fire",
        UseCutOut = true,
    },   
    Radar = {
        key = 'radar',
        Label = '<LOC range_0007>Radar',
        Categories = categories.OVERLAYRADAR,
        NormalColor = glowIntelNormal..'36648b',
        SelectColor = glowIntelSelect..'104e8b',
        RolloverColor = glowIntelOver..'045aae',
        Inner = innerIntel,
        Outer = outerIntel,
        Type = 2,
        Tooltip = "overlay_radar",
        UseCutOut = true,
    },
    Sonar = {
        key = 'sonar',
        Label = '<LOC range_0008>Sonar',
        Categories = categories.OVERLAYSONAR,
        NormalColor = glowIntelNormal..'36868b',
        SelectColor = glowIntelSelect..'108b84',
        RolloverColor = glowIntelOver..'049cae',
        Inner = innerIntel,
        Outer = outerIntel,
        Type = 2,
        Tooltip = "overlay_sonar",
        UseCutOut = true,
    },    
    Shields = {
        key = 'shields',
        Label = 'Shields',
        Categories = categories.SHIELD + categories.STRUCTURE - categories.FACTORY,
        NormalColor = glowIntelNormal..'8a8b36',
        SelectColor = glowIntelSelect..'8b8a10',
        RolloverColor = glowIntelOver..'a8ae04',
        Inner = innerIntel,
        Outer = outerIntel,
        Type = 2,
        Tooltip = "overlay_sonar",
        UseCutOut = true,
    }, 	
    WaypointAbility = {
        key = 'sonar',
        Label = '<LOC range_waypoint_0001>Waypoint Ability',
        Categories = categories.ALLUNITS,
        NormalColor = glowIntelNormal..'067d06',
        SelectColor = glowIntelSelect..'067d06',
        RolloverColor = glowIntelOver..'067d06',
        Inner = innerIntel,
        Outer = outerIntel,
        Type = 2,
        Tooltip = "overlay_waypoint_ability",
        UseCutOut = false,
    },   
}