--*****************************************************************************
--* File: lua/modules/ui/game/minimap.lua
--* Author: Chris Blackwell
--* Summary: UI for the minimap display
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local Prefs = import('/lua/user/prefs.lua')
local Window = import('/lua/maui/window.lua').Window

local minimap = Prefs.GetFromCurrentProfile('stratview') or false
local minimap_resources = Prefs.GetFromCurrentProfile('minimap_resources') or false

controls = {    
    miniMap = false,
    displayGroup = false,
}

function SetLayout(layout)
   
end

function CreateMinimap(parent)  
	local defPosition = {Left = 10, Top = 157, Bottom = 367, Right = 237}
	controls.displayGroup = Window(GetFrame(0), nil, nil, false, false, false, false, 'mini_ui_minimap', 
								    defPosition, nil)
    controls.displayGroup.Depth:Set(4)
    controls.displayGroup.window_m:SetRenderPass(UIUtil.UIRP_PostGlow)
    controls.displayGroup:SetMinimumResize(150, 150)     
    controls.miniMap = import('/lua/ui/controls/worldview.lua').WorldView(controls.displayGroup:GetClientGroup(), 'MiniMap', 2, true, 'WorldCamera')    -- depth value is above minimap
    controls.miniMap:SetName("Minimap")
    controls.miniMap:Register('MiniMap', true, '<LOC map_view_0001>MiniMap', 1)
    controls.miniMap:SetRenderPass(UIUtil.UIRP_PostGlow) -- don't change this or the camera will lag one frame behind
    controls.miniMap.Depth:Set(controls.displayGroup.Depth)
    controls.miniMap:SetNeedsFrameUpdate(true)
    -- defer the camera reset one frame so a view is created, this causes a fully zoomed out map
    local frameCount = 0
    controls.miniMap.OnFrame = function(self, elapsedTime)
        if frameCount == 1 then
            controls.miniMap:EnableResourceRendering(minimap_resources)
            controls.miniMap:CameraReset()
            --GetCamera(controls.miniMap._cameraName):SetMaxZoomMult(1.0) -- GV 2/19/09: removed SetMaxZoomMult because it wasn't actually being used anywhere in code
            controls.miniMap.OnFrame = nil  -- we want the control to continue to get frame updates in the engine, but not in Lua. PLEASE DON'T CHANGE THIS OR IT BREAKS CAMERA DRAGGING
        end
        frameCount = frameCount + 1
    end    
    
    controls.displayGroup.OnDestroy = function(self)
        controls.miniMap = false
        Window.OnDestroy(self)
    end  
    
    controls.displayGroup:Hide()  
    
end
