local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local TreeWheel = import('/lua/maui/treewheel.lua').TreeWheel
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button


-- These are external controls used for positioning, so don't add them to our local control table
controlClusterGroup = false
controls = {
}
menuActive = false


function SetupWheelMenu(parent)	

	controls.wheelGroup = Group(GetFrame(0))	
	controls.background = Bitmap(controls.wheelGroup)
	controls.background:SetNewTexture( '/textures/ui/common/360wheel480/back.dds' )
	
	SetLayout()	
	
	controls.wheelGroup.HandleEvent = function(self, event)
		if ( event.Type == 'JoystickButtonPress' and event.JoystickButton == 'B' ) then
			CloseRootMenu()
		end
	end		
end

function ActivateRootMenu()

	-- The trigger is touchy, let's just bring this up once.
	if menuActive then
		return
	end
	
	menuActive = true	

	-- Show the interface
	Expand()
	
	-- Grab the joystick focus so we have exclusive control over the joystick actions
	controls.wheelGroup:TakeJoystickFocus()

	-- Add the appropriate menu items
	-- Make sure they each handle the appropriate events
	controls.buildButton = Button(controls.wheelGroup)

	controls.buildButton:SetNewTextures( UIUtil.UIFile('/game/mfd_btn/control_btn_up.dds' ), 
										 UIUtil.UIFile('/game/mfd_btn/control_btn_up.dds'), 
										 UIUtil.UIFile('/game/mfd_btn/control_btn_up.dds'), 
										 UIUtil.UIFile('/game/mfd_btn/control_btn_up.dds') )	
	-- PositionButtonAtRadialSlot( controls.rootMenu.buildButton, controls.background, 0, 4 )
	
	-- Activate transition to the Build Menu
	controls.buildButton.HandleEvent = function(self, event)
		LOG( 'Build Menu Selected' )
	end	
	
	-- Here we will add the rest of the buttons in the root menu.
--[[
	controls.researchButton = Button(controls.wheelGroup)
		
	-- Activate transition to the Build Menu
	controls.researchButton.HandleEvent = function(self, event)
	end
	
	controls.idleUnitsButton = Button(controls.wheelGroup)	

	-- Activate transition to the Build Menu
	controls.idleUnitsButton.HandleEvent = function(self, event)
	end
	
	controls.acuSelectionButton = Button(controls.wheelGroup)
	
	-- Activate transition to the Build Menu
	controls.acuSelectionButton.HandleEvent = function(self, event)
	end	
]]--
end

-- This is called when the player presses the back button on the gamepad. 
function CloseRootMenu()
	menuActive = false
	Contract()
	
	-- Make sure we give the joystick focus back to the game when we close.
	import('/lua/ui/game/worldview.lua').viewLeft:TakeJoystickFocus()
end

function SetLayout()	
    import(UIUtil.GetLayoutFilename('wheelmenu_root')).SetLayout()    
end

function Contract()	
	controls.wheelGroup:Hide()    
end

function Expand()	
    controls.wheelGroup:Show()    
end