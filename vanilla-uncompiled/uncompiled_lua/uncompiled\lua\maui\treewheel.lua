--*****************************************************************************
--* File: lua/ui/game/treewheel.lua
--* Author: Chad Queen
--* Summary: This file contains all the functions and tables necessary to 
--*			manage the control wheel interface.
--*
--* Copyright 2009 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local Control = import('control.lua').Control
local UIUtil = import('/lua/ui/uiutil.lua')

------------------------------------------------------------------------------
-- Settings and Tables

TreeWheelSettings = {
	-- This should be a multiplier of the pixel size of the 'MiniSize' shape, for best results.
	GridUnitSize = 32,
	ConnectionLineTexture = '',	
}

WheelShapes = {
	Circle = {
		Maximized = {
			Texture = '',			
			ConnectPoints = {
				N = { x = 0, y = 0, nav_indicator = '' },					
				NE = { x = 0, y = 0 },					
				E = { x = 0, y = 0 },					
				SE = { x = 0, y = 0 },					
				S = { x = 0, y = 0 },					
				SW = { x = 0, y = 0 },					
				W = { x = 0, y = 0 },					
				NW = { x = 0, y = 0 },					
			}			
		},
		Minimized = {	
			Texture = '',
			ConnectPoints = {
				N = { x = 0, y = 0 },					
				NE = { x = 0, y = 0 },					
				E = { x = 0, y = 0 },					
				SE = { x = 0, y = 0 },					
				S = { x = 0, y = 0 },					
				SW = { x = 0, y = 0 },					
				W = { x = 0, y = 0 },					
				NW = { x = 0, y = 0 },					
			},
		},
	},
	
	MenuItem = {
		MenuItem = {
			Texture = '',
			ConnectPoints = {
			},
		},
	},
}

WheelMenu = {
	EmptyItemTexture = '',	
}

------------------------------------------------------------------------------
-- Class methods and functions
TreeWheel = Class(moho.treewheel_methods, Control) {

	__init = function(self, parent, debugname)		
		InternalCreateTreeWheel(self, parent)
        if debugname then
            self:SetName(debugname)
        end                
    end,
        
    ResetLayout = function(self)               
    end,
    
    OnInit = function(self)
        Control.OnInit(self)
    end,
    
    OnDestroy = function(self)       
    end,

}