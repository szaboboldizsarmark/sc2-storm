--*****************************************************************************
--* File: lua/modules/ui/game/gamemain.lua
--* Author: Chris Blackwell
--* Summary: Entry point for the in game UI
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Prefs = import('/lua/user/prefs.lua')

local NISActive = false
local isReplay = false

IsSavedGame = false
supressExitDialog = false
gameUIHidden = false

local OnDestroyFuncs = {}

function GetReplayState()
    return isReplay
end

function SetLayout(layout)
    if not UseGamepad() then
		import('/lua/ui/game/gamemain_pc.lua').SetLayout(layout, isReplay)
	else
		import('/lua/ui/game/gamemain_console.lua').SetLayout(layout, isReplay)
	end
end

function CreateUI(isReplay)
    if not UseGamepad() then
		import('/lua/ui/game/gamemain_pc.lua').CreateUI(isReplay)
	else
		import('/lua/ui/game/gamemain_console.lua').CreateUI(isReplay)
	end
end

function CreateWldUIProvider()
    if not UseGamepad() then
		import('/lua/ui/game/gamemain_pc.lua').CreateWldUIProvider()
	else
		import('/lua/ui/game/gamemain_console.lua').CreateWldUIProvider()
	end
end


function AddOnUIDestroyedFunction(func)
    table.insert(OnDestroyFuncs, func)
end

-- This function is called whenever the set of currently selected units changes
-- See /lua/unit.lua for more information on the lua unit object
--      oldSelection: What the selection was before
--      newSelection: What the selection is now
--      added: Which units were added to the old selection
--      removed: Which units where removed from the old selection
function OnSelectionChanged(oldSelection, newSelection, added, removed)
	if not UseGamepad() then
		import('/lua/ui/game/gamemain_pc.lua').OnSelectionChanged(oldSelection, newSelection, added, removed)
	else
		import('/lua/ui/game/gamemain_console.lua').OnSelectionChanged(oldSelection, newSelection, added, removed)
	end
    local unitIDs = {}
    for _, unit in newSelection do
        table.insert(unitIDs, unit:GetEntityId())
    end
    SimCallback({Func = 'OnUnitsSelected', Args = unitIDs})
end

function OnQueueChanged(newQueue)
    if not UseGamepad() then
		import('/lua/ui/game/gamemain_pc.lua').OnQueueChanged(newQueue)
	else
		import('/lua/ui/game/gamemain_console.lua').OnQueueChanged(newQueue)
	end
end

-- Called after the Sim has confirmed the game is indeed paused. This will happen
-- on everyone's machine in a network game.
function OnPause(pausedBy, timeoutsRemaining)
    local isOwner = false
    if pausedBy == SessionGetLocalCommandSource() then
        isOwner = true
    end
    PauseSound("World",true)
    PauseSound("Music",true)
    PauseVoice("VO",true)
    import('/lua/ui/game/tabs.lua').OnPause(true, pausedBy, timeoutsRemaining, isOwner)
    import('/lua/ui/game/missiontext.lua').OnGamePause(true)
end

-- Called after the Sim has confirmed that the game has resumed.
function OnResume()
    PauseSound("World",false)
    PauseSound("Music",false)
    PauseVoice("VO",false)
    import('/lua/ui/game/tabs.lua').OnPause(false)
    import('/lua/ui/game/missiontext.lua').OnGamePause(false)
end

-- Called immediately when the user hits the pause button. This only ever gets
-- called on the machine that initiated the pause (i.e. other network players
-- won't call this)
function OnUserPause(pause)
    local Tabs = import('/lua/ui/game/tabs.lua')
    local focus = GetArmiesTable().focusArmy
    if Tabs.CanUserPause() then
        if focus == -1 and not SessionIsReplay() then
            return
        end

        if pause then
            import('/lua/ui/game/missiontext.lua').PauseTransmission()
        else
            import('/lua/ui/game/missiontext.lua').ResumeTransmission()
        end
    end
end

local _beatFunctions = {}

function AddBeatFunction(fn)
    table.insert(_beatFunctions, fn)
end

function RemoveBeatFunction(fn)
    for i,v in _beatFunctions do
        if v == fn then
            table.remove(_beatFunctions, i)
            break
        end
    end
end

-- this function is called whenever the sim beats
function OnBeat()
    for i,v in _beatFunctions do
        if v then v() end
    end
end

function GetStatusCluster()
	WARN('WARNING: GetStatusCluster is being referenced and is no longer supported - bfricks 1/12/10')
	return nil
end

function GetControlCluster()
	WARN('WARNING: GetControlCluster is being referenced and is no longer supported - bfricks 1/12/10')
	return nil
end

function GetGameParent()
    if not UseGamepad() then
		return import('/lua/ui/game/gamemain_pc.lua').GetGameParent()
	end
end

function HideGameUI(state)
    if not UseGamepad() then
		import('/lua/ui/game/gamemain_pc.lua').HideGameUI(state)
	else
		import('/lua/ui/game/gamemain_console.lua').HideGameUI(state)
	end
end

-- Given a userunit that is adjacent to a given blueprint, does it yield a
-- bonus? Used by the UI to draw extra info
function OnDetectAdjacencyBonus(userUnit, otherBp)
    -- fixme: todo
    return true
end

function OnFocusArmyUnitDamaged(unit)
	import('/lua/user/UserMusic.lua').NotifyBattle()
end

local NISControls = {
    barTop = false,
    barBot = false,
}

local rangePrefs = {
    range_RenderHighlighted = false,
    range_RenderSelected = false,
    range_RenderHighlighted = false
}

local preNISSettings = {}
function NISMode(state)
    NISActive = state
    local worldView = import("/lua/ui/game/worldview.lua")
    if state == 'on' then
        ShowNISBars()
        if worldView.viewRight then
            import("/lua/ui/game/borders.lua").SplitMapGroup(false, true)
            preNISSettings.restoreSplitScreen = true
        else
            preNISSettings.restoreSplitScreen = false
        end
        preNISSettings.Resources = worldView.viewLeft:IsResourceRenderingEnabled()
        worldView.viewLeft:EnableResourceRendering(false)
        ConExecute('UI_NisRenderUnitBars false')
        ConExecute('UI_NisRenderIcons false')
        preNISSettings.gameSpeed = GetGameSpeed()
        if preNISSettings.gameSpeed != 0 then
            SetGameSpeed(0)
        end
        preNISSettings.Units = GetSelectedUnits()
        SelectUnits({})
        RenderOverlayEconomy(false)

        UISetNISActive(true)
    else
        import('/lua/ui/game/worldview.lua').UnlockInput()

        HideNISBars()
        if preNISSettings.restoreSplitScreen then
            import("/lua/ui/game/borders.lua").SplitMapGroup(true, true)
        end
        worldView.viewLeft:EnableResourceRendering(preNISSettings.Resources)
        -- Todo: Restore settings of overlays, lifebars properly
        ConExecute('UI_NisRenderUnitBars true')
        ConExecute('UI_NisRenderIcons true')
--        ConExecute('ren_SelectBoxes true')
        if GetGameSpeed() != preNISSettings.gameSpeed then
            SetGameSpeed(preNISSettings.gameSpeed)
        end
        SelectUnits(preNISSettings.Units)

        UISetNISActive(false)
    end
end

function ShowNISBars()
    if not NISControls.barTop then
        NISControls.barTop = Bitmap(GetFrame(0))
    end
    NISControls.barTop:SetSolidColor('ff000000')
    NISControls.barTop.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    NISControls.barTop.Left:Set(function() return GetFrame(0).Left() end)
    NISControls.barTop.Right:Set(function() return GetFrame(0).Right() end)
    NISControls.barTop.Top:Set(function() return GetFrame(0).Top() end)
    NISControls.barTop.Height:Set(1)

    if not NISControls.barBot then
        NISControls.barBot = Bitmap(GetFrame(0))
    end
    NISControls.barBot:SetSolidColor('ff000000')
    NISControls.barBot.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    NISControls.barBot.Left:Set(function() return GetFrame(0).Left() end)
    NISControls.barBot.Right:Set(function() return GetFrame(0).Right() end)
    NISControls.barBot.Bottom:Set(function() return GetFrame(0).Bottom() end)
    NISControls.barBot.Height:Set(NISControls.barTop.Height)

    NISControls.barTop:SetNeedsFrameUpdate(true)
    NISControls.barTop.OnFrame = function(self, delta)
        if delta then
            if self.Height() > GetFrame(0).Height() / 10 then
                self:SetNeedsFrameUpdate(false)
            else
                local curHeight = self.Height()
                self.Height:Set(function() return curHeight * 1.25 end)
            end
        end
    end
end

function IsNISMode()
    if NISActive == 'on' then
        return true
    else
        return false
    end
end

function HideNISBars()
    NISControls.barTop:SetNeedsFrameUpdate(true)
    NISControls.barTop.OnFrame = function(self, delta)
        if delta then
            local newAlpha = self:GetAlpha()*.8
            if newAlpha < .1 then
                NISControls.barBot:Destroy()
                NISControls.barBot = false
                NISControls.barTop:Destroy()
                NISControls.barTop = false
            else
                NISControls.barTop:SetAlpha(newAlpha)
                NISControls.barBot:SetAlpha(newAlpha)
            end
        end
    end
end

function FadeToBlack( fadeTable )
	if not NISControls.fadeToBlack then
		NISControls.fadeToBlack = Bitmap(GetFrame(0))
		NISControls.fadeToBlack:SetAlpha(0.0)
	end
	
	NISControls.fadeToBlack:SetSolidColor(fadeTable.colour or 'ff000000')
	NISControls.fadeToBlack.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
	NISControls.fadeToBlack.Left:Set(function() return GetFrame(0).Left() end)
	NISControls.fadeToBlack.Right:Set(function() return GetFrame(0).Right() end)
	NISControls.fadeToBlack.Top:Set(function() return GetFrame(0).Top() end)
	NISControls.fadeToBlack.Height:Set(function() return GetFrame(0).Bottom() - GetFrame(0).Top() end )

	local defaultAlpha = 0.0
	local currentAlpha = NISControls.fadeToBlack:GetAlpha()
	if currentAlpha > 0.0 then
		defaultAlpha = currentAlpha
	end

	NISControls.fadeToBlack:SetAlpha(defaultAlpha)

	NISControls.fadeToBlack:SetNeedsFrameUpdate(true)
	NISControls.fadeToBlack.OnFrame = function(self, delta)
		if delta then
			local newAlpha = self:GetAlpha() + (delta / fadeTable.seconds)
			if newAlpha >= 1 then
				if fadeTable.destroyOnFinish then
					NISControls.fadeToBlack:Destroy()
					NISControls.fadeToBlack = false
				else
					NISControls.fadeToBlack:SetNeedsFrameUpdate( false )
					NISControls.fadeToBlack:SetAlpha(1)
				end
			else
				NISControls.fadeToBlack:SetAlpha(newAlpha)
			end
		end
	end
end


function FadeFromBlack( fadeTable )
	if not NISControls.fadeToBlack then
		NISControls.fadeToBlack = Bitmap(GetFrame(0))
		NISControls.fadeToBlack:SetAlpha(1.0)
	end
	
	NISControls.fadeToBlack:SetSolidColor(fadeTable.colour or 'ff000000')
	NISControls.fadeToBlack.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
	NISControls.fadeToBlack.Left:Set(function() return GetFrame(0).Left() end)
	NISControls.fadeToBlack.Right:Set(function() return GetFrame(0).Right() end)
	NISControls.fadeToBlack.Top:Set(function() return GetFrame(0).Top() end)
	NISControls.fadeToBlack.Height:Set(function() return GetFrame(0).Bottom() - GetFrame(0).Top() end )

	local defaultAlpha = 1.0
	local currentAlpha = NISControls.fadeToBlack:GetAlpha()
	if currentAlpha > 0.0 then
		defaultAlpha = currentAlpha
	end

	NISControls.fadeToBlack:SetAlpha(defaultAlpha)

	NISControls.fadeToBlack:SetNeedsFrameUpdate(true)
	NISControls.fadeToBlack.OnFrame = function(self, delta)
		if delta then
			local newAlpha = self:GetAlpha() - (delta / fadeTable.seconds)
			if newAlpha <= 0 then
				NISControls.fadeToBlack:Destroy()
				NISControls.fadeToBlack = false
			else
				NISControls.fadeToBlack:SetAlpha(newAlpha)
			end
		end
	end
end

function SwipeDownToBlack( swipeTable )
	if not NISControls.swipeToBlack then
		NISControls.swipeToBlack = Bitmap(GetFrame(0))
	end

	local curHeight = 0
	NISControls.swipeToBlack:SetSolidColor(swipeTable.colour or 'ff000000')
	NISControls.swipeToBlack.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
	NISControls.swipeToBlack.Left:Set(function() return GetFrame(0).Left() end)
	NISControls.swipeToBlack.Right:Set(function() return GetFrame(0).Right() end)
	NISControls.swipeToBlack.Top:Set(function() return GetFrame(0).Top() end)
	NISControls.swipeToBlack.Height:Set(function() return 0 end )

	NISControls.swipeToBlack:SetNeedsFrameUpdate(true)
	NISControls.swipeToBlack.OnFrame = function(self, delta)
		if delta then
			if self.Height() > GetFrame(0).Height() then
				if swipeTable.destroyOnFinish then
					NISControls.swipeToBlack:Destroy()
					NISControls.swipeToBlack = false
				else
					self:SetNeedsFrameUpdate(false)
				end
			else
				curHeight = curHeight + (delta / swipeTable.seconds) * GetFrame(0).Height()
				NISControls.swipeToBlack.Height:Set(function() return curHeight end )
			end
		end
	end
end


function SwipeUpFromBlack( swipeTable )
	if not NISControls.swipeToBlack then
		NISControls.swipeToBlack = Bitmap(GetFrame(0))
	end

	local curHeight = GetFrame(0).Height()
	NISControls.swipeToBlack:SetSolidColor(swipeTable.colour or 'ff000000')
	NISControls.swipeToBlack.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
	NISControls.swipeToBlack.Left:Set(function() return GetFrame(0).Left() end)
	NISControls.swipeToBlack.Right:Set(function() return GetFrame(0).Right() end)
	NISControls.swipeToBlack.Top:Set(function() return GetFrame(0).Top() end)
	NISControls.swipeToBlack.Height:Set(function() return GetFrame(0).Height() end )

	NISControls.swipeToBlack:SetNeedsFrameUpdate(true)
	NISControls.swipeToBlack.OnFrame = function(self, delta)
		if delta then
			if self.Height() <= 0 then
				if swipeTable.destroyOnFinish then
					NISControls.swipeToBlack:Destroy()
					NISControls.swipeToBlack = false
				else
					self:SetNeedsFrameUpdate(false)
				end
			else
				curHeight = curHeight - (delta / swipeTable.seconds) * GetFrame(0).Height()
				NISControls.swipeToBlack.Height:Set(function() return curHeight end )
			end
		end
	end
end

local chatFuncs = {}

function RegisterChatFunc(func, dataTag)
    table.insert(chatFuncs, {id = dataTag, func = func})
end

function ReceiveChat(sender, data)
    for i, chatFuncEntry in chatFuncs do
        if data[chatFuncEntry.id] then
            chatFuncEntry.func(sender, data)
        end
    end
end

defaultZoom = 1.4
function SimChangeCameraZoom(newMult)
    if SessionIsActive() and
        WorldIsPlaying() and
        not SessionIsGameOver() and
        not SessionIsMultiplayer() and
        not SessionIsReplay() and
        not IsNISMode() then

        defaultZoom = newMult
        local views = import('/lua/ui/game/worldview.lua').GetWorldViews()
        --[[ GV 2/19/09: SetMaxZoomMult was setting a member that wasn't being used anywhere... this code was broken
        for _, viewControl in views do
            if viewControl._cameraName != 'MiniMap' then
                GetCamera(viewControl._cameraName):SetMaxZoomMult(newMult)
            end
        end
        ]]
    end
end

function PurchaseResearchPoint()
	IssueCommand( "UNITCOMMAND_Script", { TaskName	= "ResearchAddPointTask" } )
end

function CloseCustomUIScene(sceneName)
	LOG( 'Closing custom ui scene: ', sceneName )
	SimCallback({Func = 'OnCloseCustomUIScene', Args = sceneName})
end

function InitOverlayFilters()
	LOG( "InitOverlayFilters 1" )
	local Filters = import('/lua/ui/game/rangeoverlayparams.lua').RangeOverlayParams
	for filterName,filterData in Filters do
		LOG( "InitOverlayFilters 2: " .. filterData.key )
		SetOverlayFilter(filterName,filterData.Categories,filterData.NormalColor,filterData.SelectColor,filterData.RolloverColor,filterData.Inner[1],filterData.Inner[2],filterData.Outer[1],filterData.Outer[2],filterData.UseCutOut)
	end
end