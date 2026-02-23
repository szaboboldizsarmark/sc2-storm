--*****************************************************************************
--* File: lua/modules/ui/game/buildmode.lua
--* Author: Chris Blackwell
--* Summary: Build key mode logic
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Group = import('/lua/maui/group.lua').Group
local Prefs = import('/lua/user/prefs.lua')
local Construction = import('/lua/ui/game/construction.lua')
local Tabs = import('/lua/ui/game/tabs.lua')

local trackingMasterControl = nil

-- precompute some key codes we want to use
local keyCode = {
    ['0'] = string.byte('0'),
    ['1'] = string.byte('1'),
    ['5'] = string.byte('5'),
    ['A'] = string.byte('A'),
    ['B'] = string.byte('B'),
    ['U'] = string.byte('U'),
    ['Z'] = string.byte('Z'),
}

local function PlayErrorSound()
    local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
    PlaySound(sound)
    ToggleBuildMode()
end

local function SetTechLevel(level)
    if not import('/lua/ui/game/construction.lua').SetCurrentTechTab(level) then
        -- play error sound if we can't set the tech level with our key
        PlayErrorSound()
    end
end

local function HandleBuildTemplate(key, modifiers)
    if not Construction.HandleBuildModeKey(key) then
        PlayErrorSound()
    end
    return true
end

local function HandleCommand(key, modifiers)
    local selection = GetSelectedUnits()
    
    if not selection then
        PlayErrorSound()
        return
    end

    -- make sure the units are all of the same type
    local types = {}
    for index, unit in selection do
        local bpid = unit:GetBlueprint().BlueprintId
        if not types[bpid] then
            types[bpid] = true
        end
        if table.getsize(types) > 1 then
            -- different types selected
            PlayErrorSound()
            return
        end
    end

    if Construction.GetCurrentTechTab() == 5 then
        return HandleBuildTemplate(key, modifiers)
    end
    
    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(selection)
    local buildableUnits = EntityCategoryGetUnitList(buildableCategories)

    local function CanBuild(blueprintID)
        local canBuild = false
        for i, v in buildableUnits do
            if v == blueprintID then
                canBuild = true
                break
            end
        end
        return canBuild
    end

    local bmdata = import('/lua/ui/game/buildmodedata.lua').buildModeKeys
    local bp = selection[1]:GetBlueprint()
    local bpid = bp.BlueprintId
    
    if not bmdata[bpid] then
        PlayErrorSound()
        return
    end
    
    local curTechLevel = Construction.GetCurrentTechTab()
    if not curTechLevel then
        WARN("No cur tech level found!")
        return
    end

	-- look up the tab and build data for the key given
    local tobuild = bmdata[bpid][curTechLevel][string.char(key)]
    if not tobuild or not CanBuild(tobuild) then
		-- if tabs are not supported, jump straight to the build data
		tobuild = bmdata[bpid][string.char(key)]
		if not tobuild or not CanBuild(tobuild) then
			PlayErrorSound()
			return
        end
    end
    
	-- Determine how many units should be built.
    local unitCount = 1
    if modifiers.Shift then
		unitCount = 5
	elseif modifiers.Ctrl then
		unitCount = 25
	end
    
    UIBuildUnit( tobuild, unitCount )
end

local function HandleKey(key, modifiers)
--TODO This we need to be rethought when key mapper is added
    if key == UIUtil.VK_ESCAPE or key == keyCode['B'] then
        ToggleBuildMode()
    elseif key == UIUtil.VK_TAB then
        Construction.ToggleInfinateMode()
    elseif key == UIUtil.VK_BACKSPACE then
--TODO clear queue
    elseif key == UIUtil.VK_PAUSE then
--TODO pause construction
    else
        if key >= keyCode['1']  and key <= keyCode['5'] then
            SetTechLevel(key - keyCode['0'])
        elseif key >= keyCode['A'] and key <= keyCode['Z'] then
            HandleCommand(key, modifiers)
        end
    end
end

local function Initialize()
    local worldView = import('/lua/ui/game/borders.lua').GetMapGroup(true)
    trackingMasterControl = Group(worldView)
    trackingMasterControl.Top:Set(1)
    trackingMasterControl.Left:Set(1)
    trackingMasterControl.Height:Set(1)
    trackingMasterControl.Width:Set(1)

    trackingMasterControl:AcquireKeyboardFocus(false)

    trackingMasterControl.OnDestroy = function(self)
        trackingMasterControl:AbandonKeyboardFocus()
    end

    trackingMasterControl.HandleEvent = function(self, event)
        if event.Type == 'KeyDown' then
            HandleKey(event.KeyCode, event.Modifiers)
        elseif event.Type == 'ButtonPress' then
            ToggleBuildMode()
        end            
        return true
    end
    
    trackingMasterControl.OnKeyboardFocusChange = function(self)
        if IsInBuildMode() then
            ToggleBuildMode()
        end
    end
end

local modeID = false

-- turn build mode on and off
function ToggleBuildMode()
	-- Toggle build mode is not available until the session is active.
	if not SessionIsActive() then	
		return
	end
	
    if trackingMasterControl then
        import('/lua/ui/game/construction.lua').ShowBuildModeKeys(false)
        trackingMasterControl:Destroy()
        trackingMasterControl = nil
        
    elseif GetFocusArmy() != -1 and GetSelectedUnits()[1] and UIIsConstructionEnabled() then
        Initialize()
        
        import('/lua/ui/game/construction.lua').ShowBuildModeKeys(true)
    end
    
    UIShowConstructionKeyBindings()
end

-- Turns off build mode if build mode is active; otherwise, this does nothing.
function ResetBuildMode()
	if IsInBuildMode() then
		ToggleBuildMode()
	end
end


function KeyboardBHandler()
    ToggleBuildMode()
end

function IsInBuildMode()
    return (trackingMasterControl != nil)
end

-- given a builder unit and tech level, returns the units there are keys for
-- techlevel is ignored for units with only upgrades
function GetUnitKeys(factoryID, techLevel)
    local bmdata = import('/lua/ui/game/buildmodedata.lua').buildModeKeys
    
    if not bmdata[factoryID] then
        return nil
    end   

    local retKeyTable = {}

    if bmdata[factoryID]['U'] then
        retKeyTable[bmdata[factoryID]['U']] = 'U'
    end

    if techLevel and bmdata[factoryID][techLevel] then
        for key, id in bmdata[factoryID][techLevel] do
            retKeyTable[id] = key
        end
    end

    return retKeyTable
end
