--*****************************************************************************
--* File: lua/modules/ui/game/construction.lua
--* Author: Chris Blackwell / Ted Snook
--* Summary: Construction management UI
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local SpecialGrid = import('/lua/ui/controls/specialgrid.lua').SpecialGrid
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Button = import('/lua/maui/button.lua').Button
local Edit = import('/lua/maui/edit.lua').Edit
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local RadioGroup = import('/lua/maui/mauiutil.lua').RadioGroup
local Tooltip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua').Tooltips
local Prefs = import('/lua/user/prefs.lua')
local BuildMode = import('/lua/ui/game/buildmode.lua')
local UnitViewDetail = import('/lua/ui/game/unitviewDetail.lua')
--local ResearchLayout = import('/lua/ui/game/layouts/research_layout.lua').ResearchLayout

local capturingKeys = false
local layoutVar = false
local DisplayData = {}
local sortedOptions = {}
local newTechUnits = {}
local currentCommandQueue = false
local previousTabSet = nil
local previousTabSize = nil
local activeTab = nil

local showBuildIcons = false

controls = {
    minBG = false,
    maxBG = false,
    midBG = false,
    tabs = {},
}

------------------------------------------------------------------------------
-- SC2: handling for the prototype research tree panel
local ProtoResearchTree
local ProtoResearchBranch
local CurrentResearchBranch = 'INVALID'
local ResearchInfoDisplay = false
local ResearchTreeSpacing_Title		= 22
local ResearchTreeSpacing_TreeName	= 16
local ResearchTreeSpacing_Button	= 26
local ResearchTechColorOver			= 'FFFFFFFF'
local ResearchTechColorLabel		= 'FF999999'
local ResearchTechColorDown			= 'FF444444'
local ResearchTechColorInfo			= 'FF8888FF'
local ResearchTechColorCost			= 'FFFF9933'
local ResearchTechColorTime			= 'FFFF9933'
local ResearchTechColorReq			= 'FFFF2222'
local ResearchTechColorComp			= 'FF11FF11'
local ResearchTechColorStart		= 'FFFFFF22'
------------------------------------------------------------------------------

local constructionTabs = {'rb_tab_1','rb_tab_2','rb_tab_3'}
local nestedTabKey = {
    rb_tab_1 = 'construction',
    rb_tab_2 = 'construction',
    rb_tab_3 = 'construction',
}

local enhancementTooltips = {
    LCH = 'construction_tab_enhancment_left',
    RCH = 'construction_tab_enhancment_right',
    Back = 'construction_tab_enhancment_back',
    off = 'construction_tab_enhancment_off',
    def = 'construction_tab_enhancment_def',
    int = 'construction_tab_enhancment_int',
    sup = 'construction_tab_enhancment_sup',
}

local whatIfBuilder = nil
local whatIfBlueprintID = nil
local selectedwhatIfBuilder = nil
local selectedwhatIfBlueprintID = nil

function CreateTab(parent, id, onCheckFunc)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~CreateTab: top')
    local btn = Checkbox(parent)
    btn.Depth:Set(function() return parent.Depth() + 10 end)

    btn.disabledGroup = Group(parent)
    btn.disabledGroup.Depth:Set(function() return btn.Depth() + 1 end)

    btn.HandleEvent = function(self, event)
        if event.Type == 'MouseEnter' then
            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Tab_Rollover_02'}))
        elseif event.Type == 'ButtonPress' then
            PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Tab_Click_02'}))
        end
        Checkbox.HandleEvent(self, event)
    end

    -- Do this to prevent errors if the tab is created and destroyed in the same frame
    -- Happens when people double click super fast to select units
    btn.OnDestroy = function(self)
        btn.disabledGroup.Depth:Set(1)
    end
    if onCheckFunc then
        btn.OnCheck = onCheckFunc
    end

    btn.OnClick = function(self)
        if self._checkState != 'checked' then
            self:ToggleCheck()
        end
    end

    btn:UseAlphaHitTest(true)
    return btn
end

function GetBackgroundTextures(unitID)
    local bp = GetUnitBlueprintByName(unitID)
    local validIcons = {land = true, air = true, sea = true, amph = true}
    if validIcons[bp.General.Icon] then
        return UIUtil.UIFile('/icons/units/'..bp.General.Icon..'_up.dds'),
            UIUtil.UIFile('/icons/units/'..bp.General.Icon..'_down.dds'),
            UIUtil.UIFile('/icons/units/'..bp.General.Icon..'_over.dds'),
            UIUtil.UIFile('/icons/units/'..bp.General.Icon..'_up.dds')
    else
        return UIUtil.UIFile('/icons/units/land_up.dds'),
            UIUtil.UIFile('/icons/units/land_down.dds'),
            UIUtil.UIFile('/icons/units/land_over.dds'),
            UIUtil.UIFile('/icons/units/land_up.dds')
    end
end

function GetEnhancementPrefix(unitID, iconID)
    local prefix = ''
    if string.sub(unitID, 2, 2) == 'a' then
        prefix = '/game/aeon-enhancements/'..iconID
    elseif string.sub(unitID, 2, 2) == 'e' then
        prefix = '/game/uef-enhancements/'..iconID
    elseif string.sub(unitID, 2, 2) == 'r' then
        prefix = '/game/cybran-enhancements/'..iconID
    elseif string.sub(unitID, 2, 2) == 's' then
        prefix = '/game/seraphim-enhancements/'..iconID
    end
    return prefix
end

function GetEnhancementTextures(unitID, iconID)
    local prefix = GetEnhancementPrefix(unitID, iconID)
    return UIUtil.UIFile(prefix..'_btn_up.dds'),
        UIUtil.UIFile(prefix..'_btn_down.dds'),
        UIUtil.UIFile(prefix..'_btn_over.dds'),
        UIUtil.UIFile(prefix..'_btn_up.dds'),
        UIUtil.UIFile(prefix..'_btn_sel.dds')
end

local UPPER_GLOW_THRESHHOLD = .5
local LOWER_GLOW_THRESHHOLD = .1
local GLOW_SPEED = 2

function CommonLogic()
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~CommonLogic: top')
    controls.choices:SetupScrollControls(controls.scrollMin, controls.scrollMax, controls.pageMin, controls.pageMax)
    controls.secondaryChoices:SetupScrollControls(controls.secondaryScrollMin, controls.secondaryScrollMax, controls.secondaryPageMin, controls.secondaryPageMax)

    controls.secondaryProgress:SetNeedsFrameUpdate(true)
    controls.secondaryProgress.OnFrame = function(self, delta)
        if sortedOptions.selection[1] and not sortedOptions.selection[1]:IsDead() and sortedOptions.selection[1]:GetWorkProgress() then
            controls.secondaryProgress:SetValue(sortedOptions.selection[1]:GetWorkProgress())
        end
        if controls.secondaryChoices.top == 1 and not controls.selectionTab:IsChecked() and not controls.constructionGroup:IsHidden() then
            self:SetAlpha(1, true)
        else
            self:SetAlpha(0, true)
        end
    end

    controls.secondaryChoices.SetControlToType = function(control, type)
        local function SetIconTextures(control)
            if DiskGetFileInfo(UIUtil.UIFile('/icons/units/'..control.Data.id..'_icon.dds')) then
                control.Icon:SetTexture(UIUtil.UIFile('/icons/units/'..control.Data.id..'_icon.dds'))
            else
                control.Icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
            end
            if GetUnitBlueprintByName(control.Data.id).StrategicIconName then
                local iconName = GetUnitBlueprintByName(control.Data.id).StrategicIconName
                if DiskGetFileInfo('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds') then
                    control.StratIcon:SetTexture('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds')
                    control.StratIcon.Height:Set(control.StratIcon.BitmapHeight)
                    control.StratIcon.Width:Set(control.StratIcon.BitmapWidth)
                else
                    control.StratIcon:SetSolidColor('ff00ff00')
                end
            else
                control.StratIcon:SetSolidColor('00000000')
            end
        end

        if type == 'spacer' then
            if controls.secondaryChoices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_horizontal_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Width:Set(control.Icon.BitmapWidth)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Count:SetText('')
            control:Disable()
            control.StratIcon:SetSolidColor('00000000')
            control:SetSolidColor('00000000')
--            control.ConsBar:SetAlpha(0, true)
            control.BuildKey = nil
        elseif type == 'queuestack' or type == 'attachedunit' then
            SetIconTextures(control)
            local up, down, over, dis = GetBackgroundTextures(control.Data.id)
            control:SetNewTextures(up, down, over, dis)
            control:SetUpAltButtons(down,down,down,down)
            control.tooltipID = LOC(GetUnitBlueprintByName(control.Data.id).Description) or 'no description'
            control.mAltToggledFlag = false
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
--            if GetUnitBlueprintByName(control.Data.id).General.ConstructionBar then
--                control.ConsBar:SetAlpha(1, true)
--            else
--                control.ConsBar:SetAlpha(0, true)
--            end
            control.BuildKey = nil
            if control.Data.count > 1 then
                control.Count:SetText(control.Data.count)
                control.Count:SetColor('ffffffff')
            else
                control.Count:SetText('')
            end
            control.Icon:Show()
            control:Enable()
        end
    end

    controls.secondaryChoices.CreateElement = function()
        local btn = Button(controls.choices)

        btn.Icon = Bitmap(btn)
        btn.Icon:DisableHitTest()
        LayoutHelpers.AtCenterIn(btn.Icon, btn)

        btn.StratIcon = Bitmap(btn.Icon)
        btn.StratIcon:DisableHitTest()
        LayoutHelpers.AtTopIn(btn.StratIcon, btn.Icon, 4)
        LayoutHelpers.AtLeftIn(btn.StratIcon, btn.Icon, 4)

        btn.Count = UIUtil.CreateText(btn.Icon, '', 20, UIUtil.bodyFont)
        btn.Count:SetColor('ffffffff')
        btn.Count:SetDropShadow(true)
        btn.Count:DisableHitTest()
        LayoutHelpers.AtBottomIn(btn.Count, btn, 4)
        LayoutHelpers.AtRightIn(btn.Count, btn, 3)
        btn.Count.Depth:Set(function() return btn.Icon.Depth() + 10 end)

--        btn.ConsBar = Bitmap(btn, UIUtil.UIFile('/icons/units/cons_bar.dds'))
--        btn.ConsBar:DisableHitTest()
--        LayoutHelpers.AtCenterIn(btn.ConsBar, btn)

        btn.Glow = Bitmap(btn)
        btn.Glow:SetTexture(UIUtil.UIFile('/game/units_bmp/glow.dds'))
        btn.Glow:DisableHitTest()
        LayoutHelpers.FillParent(btn.Glow, btn)
        btn.Glow:SetAlpha(0)
        btn.Glow.Incrementing = 1
        btn.Glow.OnFrame = function(glow, elapsedTime)
            local curAlpha = glow:GetAlpha()
            curAlpha = curAlpha + (elapsedTime * glow.Incrementing * GLOW_SPEED)
            if curAlpha > UPPER_GLOW_THRESHHOLD then
                curAlpha = UPPER_GLOW_THRESHHOLD
                glow.Incrementing = -1
            elseif curAlpha < LOWER_GLOW_THRESHHOLD then
                curAlpha = LOWER_GLOW_THRESHHOLD
                glow.Incrementing = 1
            end
            glow:SetAlpha(curAlpha)
        end

        btn.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                PlaySound(Sound({Cue = "UI_MFD_Rollover", Bank = "Interface"}))
                Tooltip.CreateMouseoverDisplay(self, self.tooltipID, nil, false)
            elseif event.Type == 'MouseExit' then
                Tooltip.DestroyMouseoverDisplay()
            end
            return Button.HandleEvent(self, event)
        end

        btn.OnRolloverEvent = OnRolloverHandler
        btn.OnClick = OnClickHandler

        return btn
    end

    controls.choices.CreateElement = function()
        local btn = Button(controls.choices)

        btn.Icon = Bitmap(btn)
        btn.Icon:DisableHitTest()
        LayoutHelpers.AtCenterIn(btn.Icon, btn)

        btn.StratIcon = Bitmap(btn.Icon)
        btn.StratIcon:DisableHitTest()
        LayoutHelpers.AtTopIn(btn.StratIcon, btn.Icon, 4)
        LayoutHelpers.AtLeftIn(btn.StratIcon, btn.Icon, 4)

        btn.Count = UIUtil.CreateText(btn.Icon, '', 20, UIUtil.bodyFont)
        btn.Count:SetColor('ffffffff')
        btn.Count:SetDropShadow(true)
        btn.Count:DisableHitTest()
        LayoutHelpers.AtBottomIn(btn.Count, btn)
        LayoutHelpers.AtRightIn(btn.Count, btn)

--        btn.ConsBar = Bitmap(btn, UIUtil.UIFile('/icons/units/cons_bar.dds'))
--        btn.ConsBar:DisableHitTest()
--        LayoutHelpers.AtCenterIn(btn.ConsBar, btn)

        btn.LowFuel = Bitmap(btn)
        btn.LowFuel:SetSolidColor('ffff0000')
        btn.LowFuel:DisableHitTest()
        LayoutHelpers.FillParent(btn.LowFuel, btn)
        btn.LowFuel:SetAlpha(0)
        btn.LowFuel:DisableHitTest()
        btn.LowFuel.Incrementing = 1

        btn.LowFuelIcon = Bitmap(btn.LowFuel, UIUtil.UIFile('/game/unit_view_icons/fuel.dds'))
        LayoutHelpers.AtLeftIn(btn.LowFuelIcon, btn, 4)
        LayoutHelpers.AtBottomIn(btn.LowFuelIcon, btn, 4)
        btn.LowFuelIcon:DisableHitTest()

        btn.LowFuel.OnFrame = function(glow, elapsedTime)
            local curAlpha = glow:GetAlpha()
            curAlpha = curAlpha + (elapsedTime * glow.Incrementing)
            if curAlpha > .4 then
                curAlpha = .4
                glow.Incrementing = -1
            elseif curAlpha < 0 then
                curAlpha = 0
                glow.Incrementing = 1
            end
            glow:SetAlpha(curAlpha)
        end

        btn.Glow = Bitmap(btn)
        btn.Glow:SetTexture(UIUtil.UIFile('/game/units_bmp/glow.dds'))
        btn.Glow:DisableHitTest()
        LayoutHelpers.FillParent(btn.Glow, btn)
        btn.Glow:SetAlpha(0)
        btn.Glow.Incrementing = 1
        btn.Glow.OnFrame = function(glow, elapsedTime)
            local curAlpha = glow:GetAlpha()
            curAlpha = curAlpha + (elapsedTime * glow.Incrementing * GLOW_SPEED)
            if curAlpha > UPPER_GLOW_THRESHHOLD then
                curAlpha = UPPER_GLOW_THRESHHOLD
                glow.Incrementing = -1
            elseif curAlpha < LOWER_GLOW_THRESHHOLD then
                curAlpha = LOWER_GLOW_THRESHHOLD
                glow.Incrementing = 1
            end
            glow:SetAlpha(curAlpha)
        end


        btn.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                PlaySound(Sound({Cue = "UI_MFD_Rollover", Bank = "Interface"}))
                Tooltip.CreateMouseoverDisplay(self, self.tooltipID, nil, false)
            elseif event.Type == 'MouseExit' then
                Tooltip.DestroyMouseoverDisplay()
            end
            return Button.HandleEvent(self, event)
        end

        btn.OnRolloverEvent = OnRolloverHandler
        btn.OnClick = OnClickHandler

        return btn
    end

    controls.choices.SetControlToType = function(control, type)
        local function SetIconTextures(control, optID)
            local id = optID or control.Data.id
            if DiskGetFileInfo(UIUtil.UIFile('/icons/units/'..id..'_icon.dds')) then
                control.Icon:SetTexture(UIUtil.UIFile('/icons/units/'..id..'_icon.dds'))
            else
                control.Icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
            end
            if GetUnitBlueprintByName(id).StrategicIconName then
                local iconName = GetUnitBlueprintByName(id).StrategicIconName
                if DiskGetFileInfo('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds') then
                    control.StratIcon:SetTexture('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds')
                    control.StratIcon.Height:Set(control.StratIcon.BitmapHeight)
                    control.StratIcon.Width:Set(control.StratIcon.BitmapWidth)
                else
                    control.StratIcon:SetSolidColor('ff00ff00')
                end
            else
                control.StratIcon:SetSolidColor('00000000')
            end
        end

        if type == 'arrow' then
            control.Count:SetText('')
            control:Disable()
            control:SetSolidColor('00000000')
            if controls.choices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/arrow_vert_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/arrow_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Depth:Set(function() return control.Depth() + 5 end)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Icon.Width:Set(30)
            control.StratIcon:SetSolidColor('00000000')
            control.LowFuel:SetAlpha(0, true)
--            control.ConsBar:SetAlpha(0, true)
            control.LowFuel:SetNeedsFrameUpdate(false)
            control.BuildKey = nil
        elseif type == 'spacer' then
            if controls.choices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_horizontal_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Width:Set(control.Icon.BitmapWidth)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Count:SetText('')
            control:Disable()
            control.StratIcon:SetSolidColor('00000000')
            control:SetSolidColor('00000000')
            control.LowFuel:SetAlpha(0, true)
--            control.ConsBar:SetAlpha(0, true)
            control.LowFuel:SetNeedsFrameUpdate(false)
            control.BuildKey = nil
        elseif type == 'enhancement' then
            control.Icon:SetSolidColor('00000000')
            control:SetNewTextures(GetEnhancementTextures(control.Data.unitID, control.Data.icon))
            local _,down,over,_,up = GetEnhancementTextures(control.Data.unitID, control.Data.icon)
            control:SetUpAltButtons(up,up,up,up)
            control.tooltipID = LOC(control.Data.enhTable.Name) or 'no description'
            control.mAltToggledFlag = control.Data.Selected
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.Icon.Depth:Set(function() return control.Depth() + 1 end)
            control.Count:SetText('')
            control.StratIcon:SetSolidColor('00000000')
            control.LowFuel:SetAlpha(0, true)
--            control.ConsBar:SetAlpha(0, true)
            control.LowFuel:SetNeedsFrameUpdate(false)
            control.BuildKey = nil
            if control.Data.Disabled then
                control:Disable()
                if not control.Data.Selected then
                    control.Icon:SetSolidColor('aa000000')
                end
            else
                control:Enable()
            end
        elseif type == 'item' then
            SetIconTextures(control)
            control:SetNewTextures(GetBackgroundTextures(control.Data.id))
            local _,down = GetBackgroundTextures(control.Data.id)
            control.tooltipID = LOC(GetUnitBlueprintByName(control.Data.id).Description) or 'no description'
            control:SetUpAltButtons(down,down,down,down)
            control.mAltToggledFlag = false
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.Icon.Depth:Set(function() return control.Depth() + 1 end)
            control.BuildKey = nil
            if showBuildIcons then
                local unitBuildKeys = BuildMode.GetUnitKeys(sortedOptions.selection[1]:GetBlueprint().BlueprintId, GetCurrentTechTab())
                control.Count:SetText(unitBuildKeys[control.Data.id] or '')
                control.Count:SetColor('ffff9000')
            else
                control.Count:SetText('')
            end
            control.Icon:Show()
            control:Enable()
            control.LowFuel:SetAlpha(0, true)
--            if GetUnitBlueprintByName(control.Data.id).General.ConstructionBar then
--                control.ConsBar:SetAlpha(1, true)
--            else
--                control.ConsBar:SetAlpha(0, true)
--            end
            control.LowFuel:SetNeedsFrameUpdate(false)
            if newTechUnits and table.find(newTechUnits, control.Data.id) then
                table.remove(newTechUnits, table.find(newTechUnits, control.Data.id))
                control.NewInd = Bitmap(control, UIUtil.UIFile('/game/selection/selection_brackets_player_highlighted.dds'))
                control.NewInd.Height:Set(80)
                control.NewInd.Width:Set(80)
                LayoutHelpers.AtCenterIn(control.NewInd, control)
                control.NewInd:DisableHitTest()
                control.NewInd.Incrementing = false
                control.NewInd:SetNeedsFrameUpdate(true)
                control.NewInd.OnFrame = function(ind, delta)
                    local newAlpha = ind:GetAlpha() - delta / 5
                    if newAlpha < 0 then
                        ind:SetAlpha(0)
                        ind:SetNeedsFrameUpdate(false)
                        return
                    else
                        ind:SetAlpha(newAlpha)
                    end
                    if ind.Incrementing then
                        local newheight = ind.Height() + delta * 100
                        if newheight > 80 then
                            ind.Height:Set(80)
                            ind.Width:Set(80)
                            ind.Incrementing = false
                        else
                            ind.Height:Set(newheight)
                            ind.Width:Set(newheight)
                        end
                    else
                        local newheight = ind.Height() - delta * 100
                        if newheight < 50 then
                            ind.Height:Set(50)
                            ind.Width:Set(50)
                            ind.Incrementing = true
                        else
                            ind.Height:Set(newheight)
                            ind.Width:Set(newheight)
                        end
                    end
                end
            end
        elseif type == 'unitstack' then
            SetIconTextures(control)
            control:SetNewTextures(GetBackgroundTextures(control.Data.id))
            control.tooltipID = LOC(GetUnitBlueprintByName(control.Data.id).Description) or 'no description'
            control.mAltToggledFlag = false
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.LowFuel:SetAlpha(0, true)
--            if GetUnitBlueprintByName(control.Data.id).General.ConstructionBar then
--                control.ConsBar:SetAlpha(1, true)
--            else
--                control.ConsBar:SetAlpha(0, true)
--            end
            control.BuildKey = nil
            if control.Data.lowFuel then
                control.LowFuel:SetNeedsFrameUpdate(true)
                control.LowFuelIcon:SetAlpha(1)
            else
                control.LowFuel:SetNeedsFrameUpdate(false)
            end
            if table.getn(control.Data.units) > 1 then
                control.Count:SetText(table.getn(control.Data.units))
                control.Count:SetColor('ffffffff')
            else
                control.Count:SetText('')
            end
            control.Icon:Show()
            control:Enable()
        end
    end
end

function OnRolloverHandler(button, state)
    local item = button.Data
    if state == 'enter' then
        button.Glow:SetNeedsFrameUpdate(true)
        if item.type == 'item' then
            UnitViewDetail.Show(GetUnitBlueprintByName(item.id), sortedOptions.selection[1], item.id)
        elseif item.type == 'enhancement' then
            UnitViewDetail.ShowEnhancement(item.enhTable, item.unitID, item.icon, GetEnhancementPrefix(item.unitID, item.icon), sortedOptions.selection[1])
        end
    else
        button.Glow:SetNeedsFrameUpdate(false)
        button.Glow:SetAlpha(0)
        UnitViewDetail.Hide()
    end
end

function CreateSubMenu(parentMenu, contents, onClickFunc, setupOnClickHandler)
    local menu = Group(parentMenu)
    menu.Left:Set(function() return parentMenu.Right() + 25 end)
    menu.Bottom:Set(parentMenu.Bottom)

    local totHeight = 0
    local maxWidth = 0
    for index, inControl in contents do
        local i = index
        local control = inControl
        if i == 1 then
            LayoutHelpers.AtLeftTopIn(control, menu)
        else
            LayoutHelpers.Below(control, contents[i-1])
        end
        if setupOnClickHandler != false then
            control.bg = Bitmap(control)
            control.bg.HandleEvent = function(self, event)
                if event.Type == 'MouseEnter' then
                    self:SetSolidColor('ff777777')
                elseif event.Type == 'MouseExit' then
                    self:SetSolidColor('00000000')
                elseif event.Type == 'ButtonPress' then
                    onClickFunc(control.ID)
                end
            end
            control.bg.Depth:Set(function() return control.Depth() - 1 end)
            control.bg.Top:Set(control.Top)
            control.bg.Bottom:Set(control.Bottom)
            control.bg.Left:Set(function() return control.Left() - 2 end)
            control.bg.Right:Set(function() return control.Right() + 2 end)
        end
        control:SetParent(menu)
        control.Depth:Set(function() return menu.Depth() + 5 end)
        control:DisableHitTest()
        totHeight = totHeight + control.Height()
        maxWidth = math.max(maxWidth, control.Width() + 4)
    end

    menu.Height:Set(totHeight)
    menu.Width:Set(maxWidth)
    local bg = CreateMenuBorder(menu)
    return menu
end

function CreateMenuBorder(group)
    local bg = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_m.dds'))
    bg.tl = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_ul.dds'))
    bg.tm = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_horz_um.dds'))
    bg.tr = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_ur.dds'))
    bg.l = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_vert_l.dds'))
    bg.r = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_vert_r.dds'))
    bg.bl = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_ll.dds'))
    bg.bm = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_lm.dds'))
    bg.br = Bitmap(group, UIUtil.UIFile('/game/chat_brd/drop-box_brd_lr.dds'))

    LayoutHelpers.FillParent(bg, group)
    bg.Depth:Set(group.Depth)

    bg.tl.Bottom:Set(group.Top)
    bg.tl.Right:Set(group.Left)
    bg.tl.Depth:Set(group.Depth)

    bg.tm.Bottom:Set(group.Top)
    bg.tm.Right:Set(group.Right)
    bg.tm.Left:Set(group.Left)
    bg.tm.Depth:Set(group.Depth)

    bg.tr.Bottom:Set(group.Top)
    bg.tr.Left:Set(group.Right)
    bg.tr.Depth:Set(group.Depth)

    bg.l.Bottom:Set(group.Bottom)
    bg.l.Right:Set(group.Left)
    bg.l.Top:Set(group.Top)
    bg.l.Depth:Set(group.Depth)

    bg.r.Bottom:Set(group.Bottom)
    bg.r.Left:Set(group.Right)
    bg.r.Top:Set(group.Top)
    bg.r.Depth:Set(group.Depth)

    bg.bl.Top:Set(group.Bottom)
    bg.bl.Right:Set(group.Left)
    bg.bl.Depth:Set(group.Depth)

    bg.br.Top:Set(group.Bottom)
    bg.br.Left:Set(group.Right)
    bg.br.Depth:Set(group.Depth)

    bg.bm.Top:Set(group.Bottom)
    bg.bm.Right:Set(group.Right)
    bg.bm.Left:Set(group.Left)
    bg.bm.Depth:Set(group.Depth)

    return bg
end

function GetTabByID(id)
    for _, control in controls.tabs do
        if control.ID == id then
            return control
        end
    end
    return false
end

local pauseEnabled = false
function EnablePauseToggle()
    if controls.extraBtn2 then
        controls.extraBtn2:Enable()
    end
    pauseEnabled = true
end
function DisablePauseToggle()
    if controls.extraBtn2 then
        controls.extraBtn2:Disable()
    end
    pauseEnabled = false
end

function ToggleUnitPause()
    if controls.selectionTab:IsChecked() or controls.constructionTab:IsChecked() then
        controls.extraBtn2:ToggleCheck()
    else
        SetPaused(sortedOptions.selection, not GetIsPaused(sortedOptions.selection))
    end
end

function CreateExtraControls(controlType)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~CreateExtraControls: top')
    if controlType == 'construction' then

------------------------------------------------------------------------------
-- SC2: removing the repeat build functionality - bfricks 9/9/2008
		controls.extraBtn1:Disable()
--        Tooltip.AddCheckboxTooltip(controls.extraBtn1, 'construction_infinite')
--        controls.extraBtn1.OnClick = function(self, modifiers)
--            return Checkbox.OnClick(self, modifiers)
--        end
--        controls.extraBtn1.OnCheck = function(self, checked)
--            for i,v in sortedOptions.selection do
--                if checked then
--                    v:ProcessInfo('SetRepeatQueue', 'true')
--                else
--                    v:ProcessInfo('SetRepeatQueue', 'false')
--                end
--            end
--        end
--        local allFactories = true
--        local currentInfiniteQueueCheckStatus = false
--        for i,v in sortedOptions.selection do
--            if v:IsRepeatQueue() then
--                currentInfiniteQueueCheckStatus = true
--            end
--            if not v:IsInCategory('FACTORY') then
--                allFactories = false
--            end
--        end
--        if allFactories then
--            controls.extraBtn1:SetCheck(currentInfiniteQueueCheckStatus, true)
--            controls.extraBtn1:Enable()
--        else
--            controls.extraBtn1:Disable()
--        end
------------------------------------------------------------------------------

        Tooltip.AddCheckboxTooltip(controls.extraBtn2, 'construction_pause')
        controls.extraBtn2.OnCheck = function(self, checked)
            SetPaused(sortedOptions.selection, checked)
        end
        if pauseEnabled then
            controls.extraBtn2:Enable()
        else
            controls.extraBtn2:Disable()
        end
        controls.extraBtn2:SetCheck(GetIsPaused(sortedOptions.selection),true)
    elseif controlType == 'selection' then
        Tooltip.AddCheckboxTooltip(controls.extraBtn1, 'save_template')
        local validForTemplate = true
        local faction = false
        for i,v in sortedOptions.selection do
            if not v:IsInCategory('STRUCTURE') then
                validForTemplate = false
                break
            end
            if i == 1 then
                local factions = import('/lua/common/factions.lua').Factions
                for _, factionData in factions do
                    if v:IsInCategory(factionData.Category) then
                        faction = factionData.Category
                        break
                    end
                end
            elseif not v:IsInCategory(faction) then
                validForTemplate = false
                break
            end
        end
        if validForTemplate then
            controls.extraBtn1:Enable()
            controls.extraBtn1.OnClick = function(self, modifiers)
                Templates.CreateBuildTemplate()
            end
        else
            controls.extraBtn1:Disable()
        end
        Tooltip.AddCheckboxTooltip(controls.extraBtn2, 'construction_pause')
        controls.extraBtn2.OnCheck = function(self, checked)
            SetPaused(sortedOptions.selection, checked)
        end
        if pauseEnabled then
            controls.extraBtn2:Enable()
        else
            controls.extraBtn2:Disable()
        end
        controls.extraBtn2:SetCheck(GetIsPaused(sortedOptions.selection),true)
    else
        controls.extraBtn1:Disable()
        controls.extraBtn2:Disable()
    end
end

------------------------------------------------------------------------------
-- SC2: handling for the prototype research tree panel
-- SC2: support for tracking research across sim and user layers
-- SC2: economy support for pre-evaluating enhancement costs
--		WORK IN PROGRESS - not optimally organized or functional by any stretch - bfricks 9/29/08

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ResearchClickHandler(button)
	local techID				= button.Data.techID
	local branchID				= button.Data.branchID
	local buttonDataInfo		= button.Data.techInfo
	local preReq				= button.Data.preReq
	local preReqAlt				= button.Data.preReqAlt
	local preReqBrk				= button.Data.preReqBrk
	local researchID			= button.Data.researchID
	local researchLevel			= GetResearchLevel( researchID )
	local researchCompleted		= GetCompletedResearchTotal( researchID ) 
    local isLocked				= false
    local isStarted				= false
    local isCompleted			= false
	local isBoostable			= false
	local techName				= buttonDataInfo.NAME
	local isWIP					= buttonDataInfo.WIP
	local maxLevel				= 1
	
	if( buttonDataInfo.BOOSTS ) then
		maxLevel = table.getsize( buttonDataInfo.BOOSTS ) + 1
	end

	--LOG( 'Research Click Handler, Focus army index: ', GetFocusArmy() )

	if IsStartedResearch( researchID ) then
		isStarted = true
	end

	if not isWIP and (maxLevel > 1) and (researchLevel > 0) then
		if researchLevel < maxLevel then
			isBoostable = true
		elseif researchLevel == maxLevel then
			if researchCompleted < maxLevel then
				isStarted = true
			else
				isCompleted = true
			end
		end
	elseif IsCompletedResearch( researchID ) then
		isCompleted = true
	end


-- Temporarily disabling prerequisites for Playtesting purposes until we have adequate systems to handle queuing.
-- --ewilliamson 01/28/09
--
--	if lastCompletedBoost == 0 and not isCompleted then
--		-- if we have already reached a new boostLevel or we are completed, then we know we are already unlocked, otherwise...
--		if preReq then
--			if not IsCompletedResearch( preReq ) then
--				if preReqAlt then
--					if not IsCompletedResearch( preReqAlt ) then
--						isLocked = true
--					end
--				else
--					isLocked = true
--				end
--			end
--		end
--
--		if not isLocked and preReqBrk then
--			if not IsCompletedResearch( preReqBrk ) then
--				isLocked = true
--			end
--		end
--	end

	if isCompleted then
		-- SC2 FEEDBACK TAG:
		-- If we are completed then simply display a message that we are complete.
		local info = 'RESEARCH: ' .. techName .. ' already complete.'
		local data = {text = info, size = 20, color = 'ffffff22', duration = 5, location = 'centertop'}
		import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
	elseif isStarted and not isBoostable then
		-- SC2 FEEDBACK TAG:
		-- If we are already started and we aren't boostable
		local info = 'Already researching: ' .. techName
		local data = {text = info, size = 20, color = 'ffffff22', duration = 5, location = 'centertop'}
		import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
	elseif isLocked then
		--SC2 FEEDBACK TAG:
		-- If we need prequisites.
		local info = 'Prerequisites are required for: ' .. techName
		local data = {text = info, size = 20, color = 'ffff2222', duration = 5, location = 'centertop'}
		import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
	else
		-- Otherwise lets issue our research.

		local econData = GetEconomyTotals()
		local currMass = econData["stored"]["MASS"]
		local currEnergy = econData["stored"]["ENERGY"]
		local currResearchPoints = econData["stored"]["RESEARCH"]
		local needMass = buttonDataInfo.MASS
		local needEnergy = buttonDataInfo.ENERGY
		local needResearchCost = buttonDataInfo.COST
		local boostLevel = 0

		--LOG( 'Boostable:', isBoostable, ' Started:', isStarted, ' Completed:', isCompleted  )
		--LOG( 'researchLevel', researchLevel )

		-- Calculate our boost level
		if isBoostable then
			boostLevel = researchLevel
			local boosts = buttonDataInfo.BOOSTS
			if boosts[boostLevel] then
				needMass = boosts[boostLevel].MASS
				needEnergy = boosts[boostLevel].ENERGY
			else
				WARN('SC2 WARNING: Trying to lookup cost/time values for ', techID, 'Boost level ', boostLevel, ', which is not a defined ResearchDefinition.' )
			end
		end

		-- Validate costs before trying to apply research
		if not isWIP then
			local buildHelpInfo = nil

			if currMass < needMass then
				buildHelpInfo = ', need mass.'
			elseif currEnergy < needEnergy then
				buildHelpInfo = ', need energy.'
			elseif (currResearchPoints - GetResearchCosts()) < needResearchCost then
				buildHelpInfo = ', need research points. Current:' .. currResearchPoints .. ' Queued:' .. GetResearchCosts()
			end

			if buildHelpInfo then
				--SC2 FEEDBACK TAG:
				local info = 'NOT ENOUGH RESOURCES TO BUILD: ' .. techName .. buildHelpInfo
				local data = {text = info, size = 20, color = 'ffff2222', duration = 3, location = 'centertop'}
				import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
				local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
				PlaySound(sound)
				return
			end
		end

		-- special highlighting while being researched
		button:SetAlpha(1.00)
		button.label:SetAlpha(1.00)
		button.label:SetColor(ResearchTechColorStart)
		local buttonText = 'Researching...'
		if( researchLevel > 0 ) then
			buttonText = buttonText .. '(' .. researchLevel .. ')'
		end
		button.label:SetText( buttonText )

		IssueResearchCommand( researchID, needResearchCost, researchLevel )
	end
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ResearchRollOverHandler(button, event)
	local techID				= button.Data.techID
	local buttonDataInfo		= button.Data.techInfo
	local researchID			= button.Data.researchID
	local researchLevel			= GetResearchLevel( researchID )
	local researchCompleted		= GetCompletedResearchTotal( researchID ) 
	local infoSize				= 10
	local cost					= 'Research Point Cost: ' .. buttonDataInfo.COST
	local time					= 'Build Time: ' .. buttonDataInfo.TIME
	local info					= buttonDataInfo.INFO
	local isWIP					= buttonDataInfo.WIP
	local BoostInfo				= buttonDataInfo.BOOSTS 
	local maxLevel				= 1
	
	if BoostInfo then
		maxLevel = table.getsize( BoostInfo ) + 1
	end

	if not isWIP and maxLevel > 1 and researchLevel > 0 then
		if IsCompletedResearch( researchID ) then

			--LOG( researchCompleted )
			--LOG( maxLevel )
			if researchCompleted == maxLevel then
				cost = 'Research Point Cost: 0'
				time = 'Build Time: 0'
			else
				local BoostIndex = researchLevel

				if researchLevel == maxLevel then
					BoostIndex = maxLevel
				end

				if BoostInfo[BoostIndex] then
					cost = 'Research Point Cost: ' .. BoostInfo[BoostIndex].COST
					time = 'Build Time: ' .. BoostInfo[BoostIndex].TIME
				else
					cost = 'Research Point Cost: INVALID'
					time = 'Build Time: INVALID'
					WARN('SC2 WARNING: Trying to lookup cost/time values for ', techID, 'Boost level ', BoostIndex, ', which is not a defined ResearchDefinition.' )
				end
			end
		end
	end

	if event == 'enter' then
		--clear any current info panel
		if ResearchInfoDisplay then
			ResearchInfoDisplay:Destroy()
			ResearchInfoDisplay = false
		end

		--determine heightOffset based on how many lines of text we need
		local displayInfoCount = table.getn(button.Data.rolloverInfo)
		local heightOffset = (infoSize + 4) * (3 + displayInfoCount)

		if isWIP then
			heightOffset = heightOffset + (infoSize + 4)
		end

		--construct the info pane
	    ResearchInfoDisplay = Group(button, "ResearchInfoDisplay")
	    LayoutHelpers.Above(ResearchInfoDisplay, button, 5 )
	    ResearchInfoDisplay.Depth:Set(GetFrame(button:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)
	    local infoPanel = Bitmap(ResearchInfoDisplay, UIUtil.SkinnableFile('/scx_menu/panel-brd/panel_brd_m.dds'))
	    ResearchInfoDisplay._background = infoPanel
	    ResearchInfoDisplay.Width:Set(120)
	    ResearchInfoDisplay.Height:Set(heightOffset)
	    LayoutHelpers.FillParent(infoPanel, ResearchInfoDisplay)

		if isWIP then
			local infoTag1 = UIUtil.CreateText(infoPanel, 'WORK IN PROGRESS', infoSize, "Arial")
			LayoutHelpers.AtTopIn( infoTag1, infoPanel )
			LayoutHelpers.AtLeftIn( infoTag1, infoPanel )
			infoTag1:SetColor(ResearchTechColorInfo)

			local infoTag2 = UIUtil.CreateText(infoPanel, 'Click to advance tech tree', infoSize, "Arial")
			LayoutHelpers.Below( infoTag2, infoTag1 )
			infoTag2:SetColor(ResearchTechColorInfo)

			local costTag = UIUtil.CreateText(infoPanel, 'Research Point Cost: Free', infoSize, "Arial")
			LayoutHelpers.Below( costTag, infoTag2 )
			costTag:SetColor(ResearchTechColorCost)

			local timeTag = UIUtil.CreateText(infoPanel, 'Build Time: 1', infoSize, "Arial")
			LayoutHelpers.Below( timeTag, costTag )
			timeTag:SetColor(ResearchTechColorTime)
		else
			local infoTag = UIUtil.CreateText(infoPanel, info, infoSize, "Arial")
			LayoutHelpers.AtTopIn( infoTag, infoPanel )
			LayoutHelpers.AtLeftIn( infoTag, infoPanel )
			infoTag:SetColor(ResearchTechColorInfo)

			local costTag = UIUtil.CreateText(infoPanel, cost, infoSize, "Arial")
			LayoutHelpers.Below( costTag, infoTag )
			costTag:SetColor(ResearchTechColorCost)

			local timeTag = UIUtil.CreateText(infoPanel, time, infoSize, "Arial")
			LayoutHelpers.Below( timeTag, costTag )
			timeTag:SetColor(ResearchTechColorTime)

			if displayInfoCount > 0 then
				local displayColor = ResearchTechColorReq
				if maxLevel > 0 and researchLevel == maxLevel then
					displayColor = ResearchTechColorComp
				elseif IsCompletedResearch( researchID ) then
					displayColor = ResearchTechColorComp
				end

				if IsStartedResearch( researchID ) then
					displayColor = ResearchTechColorStart
				end
				-- info panel
				local lastTag = timeTag
				for _, displayInfo in button.Data.rolloverInfo do
					local extraTag = UIUtil.CreateText(infoPanel, displayInfo, infoSize, "Arial")
					LayoutHelpers.Below( extraTag, lastTag )
					extraTag:SetColor(displayColor)
					lastTag = extraTag
				end
			end
		end
	elseif event == 'exit' then
		--clear any current info panel
		if ResearchInfoDisplay then
			ResearchInfoDisplay:Destroy()
			ResearchInfoDisplay = false
		end
	end
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function CreateResearchBranchPanel(parent, branchID, branchInfo )

	-- set local tracking values
	local branchName	= branchInfo.name or 'INVALID'
	local panelArt		= branchInfo.panelArt or '/scx_menu/panel-brd/panel_brd_m.dds'

	ProtoResearchBranch = Group(GetFrame(0), "ProtoResearchBranch")
	ProtoResearchBranch.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
	LayoutHelpers.RightOf(ProtoResearchBranch, parent, 10)

	local background = Bitmap(ProtoResearchBranch, UIUtil.UIFile(panelArt))
	ProtoResearchBranch._background = background
	ProtoResearchBranch.Width:Set(560)
	ProtoResearchBranch.Height:Set(480)
	LayoutHelpers.FillParent(background, ProtoResearchBranch)

	ProtoResearchBranch.border = UIUtil.CreateBorder(ProtoResearchBranch, true)

	local name = 'Branch: ' .. branchName
	local title = UIUtil.CreateText(ProtoResearchBranch, name, 18, "Arial")
	LayoutHelpers.AtTopIn(title, ProtoResearchBranch, 2 )
	LayoutHelpers.AtLeftIn(title, ProtoResearchBranch, 20 )

	if branchInfo.Technologies then
		for k, techLayoutInfo in branchInfo.Technologies do
			local techID = techLayoutInfo[1]
			if ResearchDefinitions[techID] then
				CreateResearchTechButton(background, techID, branchID, techLayoutInfo )
			else
				WARN('SC2 WARNING: Trying to add ', techID, ', which is not a defined ResearchDefinition.' )
			end
		end
	end

	if branchInfo.Bars then
		for _, bar in branchInfo.Bars do
			local newBar
			local vertStart = bar.vertStart or 0
			local horzStart = bar.horzStart or 0
			local barLength = bar.Length or 100
			local barWidth = bar.Width or 20

			if bar.Vertical then
				newBar = Bitmap(background, UIUtil.SkinnableFile('/proto/generic_bar_vert.dds'))
				LayoutHelpers.AtTopIn( newBar, parent, vertStart )
				LayoutHelpers.AtLeftIn( newBar, parent, horzStart )
				newBar.Width:Set(barWidth)
				newBar.Height:Set(barLength)
				newBar:SetAlpha(0.40)
			else
				newBar = Bitmap(background, UIUtil.SkinnableFile('/proto/generic_bar_horz.dds'))
				LayoutHelpers.AtTopIn( newBar, parent, vertStart )
				LayoutHelpers.AtLeftIn( newBar, parent, horzStart )
				newBar.Width:Set(barLength)
				newBar.Height:Set(barWidth)
				newBar:SetAlpha(0.40)
			end
		end
	end

	local closeButton = UIUtil.CreateButtonStd(background, '/dialogs/check-box_btn/radio-s' )
	LayoutHelpers.AtBottomIn(closeButton, ProtoResearchBranch, 2 )
	LayoutHelpers.AtRightIn(closeButton, ProtoResearchBranch, 2 )
	closeButton.OnClick = function(self, modifiers)
		DestroyResearchBranchPanel()
	end
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function DestroyResearchBranchPanel()
	CurrentResearchBranch = 'INVALID'
    if ProtoResearchBranch then
        ProtoResearchBranch:Destroy()
        ProtoResearchBranch = false
	end
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function CreateResearchTree( parent, treeID, treeInfo, branches, startVert )
	-- add tree name
	local treeName = UIUtil.CreateText(parent, treeInfo.name, 14, "Arial")
	LayoutHelpers.AtTopIn(treeName, parent, startVert )
	LayoutHelpers.AtRightIn(treeName, parent, 2 )

	for branchID, branchInfo in branches do
		if branchInfo.name and branchInfo.order and branchInfo.tree and branchInfo.tree == treeID then
			local tempVert = startVert + ResearchTreeSpacing_TreeName + ((branchInfo.order-1) * ResearchTreeSpacing_Button)
			CreateResearchBranchButton(parent, branchID, branchInfo, tempVert )
		end
	end
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function CreateResearchBranchButton(parent, branchID, branchInfo, startVert, isTest )

	-- set local tracking values
	local branchName	= branchInfo.name or 'INVALID'
	local buttonArt		= branchInfo.buttonArt or '/proto/branch'
	local labelSize		= branchInfo.labelSize or 12
	local clickCue		= "UI_Menu_MouseDown_Sml"
	local rolloverCue	= "UI_Menu_Rollover_Sml"
	local up			= UIUtil.SkinnableFile(buttonArt .. '_btn_up.dds')
	local down			= UIUtil.SkinnableFile(buttonArt .. '_btn_down.dds')
	local over			= UIUtil.SkinnableFile(buttonArt .. '_btn_over.dds')
	local disabled		= UIUtil.SkinnableFile(buttonArt .. '_btn_dis.dds')

	-- create button object
    local button = Button(parent, up, down, over, disabled, clickCue, rolloverCue)
    if isTest then
		LayoutHelpers.AtBottomIn(button, parent, 2 )
		LayoutHelpers.AtRightIn(button, parent, 32 )
    else
		LayoutHelpers.AtTopIn(button, parent, startVert )
		LayoutHelpers.AtRightIn(button, parent, 2 )
	end
	button:UseAlphaHitTest(true)

	-- set button label
    button.label = UIUtil.CreateText(button, branchName, labelSize, "Arial")
	LayoutHelpers.CenteredLeftOf(button.label, button, 2 )
	button.label:SetColor(ResearchTechColorLabel)
	--button.label:DisableHitTest()

    button.OnRolloverEvent = function(self, event)
		if event == 'enter' then
			button.label:SetColor(ResearchTechColorOver)
			-- NOTE: this below is the mechanic required for supporting a rollover preview - bfricks 12/15/08
			--if CurrentResearchBranch != branchID then
			--	DestroyResearchBranchPanel()
			--	CurrentResearchBranch = branchID
			--	CreateResearchBranchPanel(parent, branchID, branchInfo )
			--end
		elseif event == 'exit' then
			button.label:SetColor(ResearchTechColorLabel)
		elseif event == 'down' then
			button.label:SetColor(ResearchTechColorDown)
		end
    end

	button.OnClick = function(self)
		if CurrentResearchBranch == branchID then
			DestroyResearchBranchPanel()
		else
			DestroyResearchBranchPanel()
			CurrentResearchBranch = branchID
			CreateResearchBranchPanel(parent, branchID, branchInfo )
		end
	end

    return button
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function CreateResearchTechButton(parent, techID, branchID, techLayoutInfo )
	-- pull and innitialize common data for all tech tree buttons
	local techInfo		= ResearchDefinitions[techID]	-- table of data from research.lua
    local isLocked		= false							-- tracking value
    local isStarted		= false							-- tracking value
    local isCompleted	= false							-- tracking value
    local isWIP			= techInfo.WIP					-- is this technology still under construction enough that we should flag it as a Work in Progress?
    local techName		= techInfo.NAME					-- screen name
	local researchID	= GetResearchId(techID)
	local researchLevel	= GetResearchLevel( researchID )

	-- Disabling tech tree prerequisite visuals until systems properly support queuing.
	-- --ewilliamson 01/28/09
	local preReq		= nil -- techLayoutInfo[11] != '' and techLayoutInfo[11] or nil	-- PreRequisite research required for the current technology
	local preReqBrk		= nil -- techLayoutInfo[12] != '' and techLayoutInfo[12] or nil	-- PreRequisiteBreakthrough research required for the current technology
	local preReqAlt		= nil -- techLayoutInfo[13] != '' and techLayoutInfo[13] or nil	-- PreRequisiteAlt research required for the current technology

	-- setup a table for storing rollover info
	rolloverInfo = {}

	-- set values for data params that change based on boost status
	local maxBoost				= table.getsize( techInfo.BOOSTS )
	local lastCompletedBoost	= 0

	-- set tracking values for button status
	if isWIP then
		maxBoost = 0
	elseif maxBoost > 0 then
		-- determine how far down the boost path we have traveled for this research option
		lastCompletedBoost = GetResearchLevel( researchID ) - 1
	end

	if maxBoost > 0 then
		if lastCompletedBoost == maxBoost then
			table.insert(rolloverInfo, 'COMPLETE')
			isCompleted = true
		end
	elseif IsCompletedResearch( researchID ) then
		table.insert(rolloverInfo, 'COMPLETE')
		isCompleted = true
	end

	if IsStartedResearch( researchID ) then
		table.insert(rolloverInfo, 'RESEARCHING')
		isStarted = true
	end

	if lastCompletedBoost == 0 and not isCompleted then
		-- if we have already reached a new boostLevel or we are completed, then we know we are already unlocked, otherwise...
		if preReq then
			if not IsCompletedResearch( GetResearchId(preReq) ) then
				if preReqAlt then
					if not IsCompletedResearch( GetResearchId(preReqAlt) ) then
						isLocked = true
					end
				else
					isLocked = true
				end
				if isLocked then
					if ResearchDefinitions[preReq] then
						local displayInfo = 'Requires: ' .. ResearchDefinitions[preReq].NAME
						table.insert(rolloverInfo, displayInfo)
					end
					if preReqAlt and ResearchDefinitions[preReqAlt] then
						local displayInfo = 'Alternate: ' .. ResearchDefinitions[preReqAlt].NAME
						table.insert(rolloverInfo, displayInfo)
					end
				end
			end
		end

		if preReqBrk then
			if not IsCompletedResearch( GetResearchId(preReqBrk) ) then
				if ResearchDefinitions[preReqBrk] then
					local displayInfo = 'Requires: ' .. ResearchDefinitions[preReqBrk].NAME
					table.insert(rolloverInfo, displayInfo)
				end
				isLocked = true
			end
		end
	end

	-- make sure we have some icon art before proceeding
	local iconTag = techLayoutInfo[2] or '/widgets/64x32'

	-- set tracking values for layout and visualization
	local labelSize				= 11
	local statusSize			= 11
	local clickCue				= "UI_Menu_MouseDown_Sml"
	local rolloverCue			= "UI_Menu_Rollover_Sml"
	local up					= UIUtil.SkinnableFile(iconTag .. '_btn_up.dds')
	local down					= UIUtil.SkinnableFile(iconTag .. '_btn_down.dds')
	local over					= UIUtil.SkinnableFile(iconTag .. '_btn_over.dds')
	local disabled				= UIUtil.SkinnableFile(iconTag .. '_btn_dis.dds')
	local horzDimension			= techLayoutInfo[3] or 1
	local vertDimension			= techLayoutInfo[4] or 1
	local horzOffset			= techLayoutInfo[5] or 0
	local vertOffset			= techLayoutInfo[6] or 0
	local arrowLeft				= techLayoutInfo[7] or 0
	local arrowRight			= techLayoutInfo[8] or 0
	local arrowUp				= techLayoutInfo[9] or 0
	local arrowDown				= techLayoutInfo[10] or 0

	-- adjust vert and horz dimensions to fit a grid
	vertDimension = 10 + ( (vertDimension-1) * 60) + vertOffset
	horzDimension = 26 + ( (horzDimension-1) * 112) + horzOffset

	-- create button object
	local button = Button(parent, up, down, over, disabled, clickCue, rolloverCue)
	LayoutHelpers.AtTopIn( button, parent, vertDimension )
	LayoutHelpers.AtLeftIn( button, parent, horzDimension )
	button:UseAlphaHitTest(true)

	-- set button label
	button.label = UIUtil.CreateText(button, techName, labelSize, "Arial")
	LayoutHelpers.Below(button.label, button)
	LayoutHelpers.AtHorizontalCenterIn(button.label, button)
	button.label:SetColor(ResearchTechColorLabel)
	button.label:DisableHitTest()

	-- set button status
	local offset = -2
	button.statusTracker = UIUtil.CreateText(button, '', statusSize, "Arial")
	LayoutHelpers.AtCenterIn(button.statusTracker, button, offset, offset)
	button.statusTracker:SetColor('FF111111')
	button.statusTracker:DisableHitTest()

	if isCompleted then
		button.statusTracker:SetText('Complete')
		button.statusTracker:SetColor(ResearchTechColorComp)
	elseif isWIP then
		button.statusTracker:SetText('W.I.P.')
		button.statusTracker:SetColor('FFFFFF22')
		button.statusTracker:SetAlpha(1.0)
	elseif maxBoost > 0 then
		local level = 0
		if IsCompletedResearch( researchID ) then
			level = lastCompletedBoost+1
		end
		currentBoostCount = level .. ' of ' .. maxBoost+1
		button.statusTracker:SetText(currentBoostCount)
	end

	-- add arrows if needed
	--		0 == no arrow
	--		1 == arrow pointed out from tech
	--		2 == arrow pointed in at tech
	--		3 == long arrow pointed out from tech
	--		4 == long arrow pointed in at tech
	if arrowLeft > 0 then
		local arrowArt = '/proto/arrow_left.dds'
		local arrowOffset = 45
		local arrowLength = 45
		local arrowThickness = 20
		local arrowAlpha = 0.60

		if arrowLeft == 2 then
			arrowArt = '/proto/arrow_right.dds'
			arrowLength = 35
			arrowOffset = 35
		elseif arrowLeft == 3 then
			arrowLength = 100
			arrowOffset = 100
			arrowThickness = 16
		elseif arrowLeft == 4 then
			arrowArt = '/proto/arrow_right.dds'
			arrowLength = 100
			arrowOffset = 100
			arrowThickness = 16
		end

		button.ArrowLeft = Bitmap(button, UIUtil.SkinnableFile(arrowArt))
		LayoutHelpers.AtVerticalCenterIn(button.ArrowLeft, button )
		LayoutHelpers.AtLeftIn(button.ArrowLeft, button, -1 * arrowOffset )
		button.ArrowLeft.Width:Set(arrowLength)
		button.ArrowLeft.Height:Set(arrowThickness)
		button.ArrowLeft:SetAlpha(arrowAlpha)
	end
	if arrowRight > 0 then
		local arrowArt = '/proto/arrow_right.dds'
		local arrowOffset = 45
		local arrowLength = 45
		local arrowThickness = 20
		local arrowAlpha = 0.60

		if arrowRight == 2 then
			arrowArt = '/proto/arrow_left.dds'
			arrowLength = 35
			arrowOffset = 35
		elseif arrowRight == 3 then
			arrowLength = 100
			arrowOffset = 100
			arrowThickness = 16
		elseif arrowRight == 4 then
			arrowArt = '/proto/arrow_left.dds'
			arrowLength = 100
			arrowOffset = 100
			arrowThickness = 16
		end

		button.ArrowRight = Bitmap(button, UIUtil.SkinnableFile(arrowArt))
		LayoutHelpers.AtVerticalCenterIn(button.ArrowRight, button )
		LayoutHelpers.AtRightIn(button.ArrowRight, button, -1 * arrowOffset )
		button.ArrowRight.Width:Set(arrowLength)
		button.ArrowRight.Height:Set(arrowThickness)
		button.ArrowRight:SetAlpha(arrowAlpha)
	end
	if arrowUp > 0 then
		local arrowArt = '/proto/arrow_up.dds'
		local arrowOffset = 20
		local arrowLength = 25
		local arrowThickness = 25
		local arrowAlpha = 0.60

		if arrowUp == 2 or arrowUp == 4 then
			arrowArt = '/proto/arrow_down.dds'
		end

		if arrowUp == 3 or arrowUp == 4 then
			arrowOffset = 95
			arrowLength = 100
			arrowThickness = 20
		end

		button.ArrowUp = Bitmap(button, UIUtil.SkinnableFile(arrowArt))
		LayoutHelpers.AtHorizontalCenterIn(button.ArrowUp, button )
		LayoutHelpers.AtTopIn(button.ArrowUp, button, -1 * arrowOffset )
		button.ArrowUp.Width:Set(arrowThickness)
		button.ArrowUp.Height:Set(arrowLength)
		button.ArrowUp:SetAlpha(arrowAlpha)
	end
	if arrowDown > 0 then
		local arrowArt = '/proto/arrow_down.dds'
		local arrowOffset = 30
		local arrowLength = 25
		local arrowThickness = 25
		local arrowAlpha = 0.60

		if arrowDown == 2 or arrowDown == 4 then
			arrowArt = '/proto/arrow_up.dds'
		end

		if arrowDown == 3 or arrowDown == 4 then
			arrowOffset = 105
			arrowLength = 100
			arrowThickness = 20
		end

		button.ArrowDown = Bitmap(button, UIUtil.SkinnableFile(arrowArt))
		LayoutHelpers.AtHorizontalCenterIn(button.ArrowDown, button )
		LayoutHelpers.AtBottomIn(button.ArrowDown, button, -1 * arrowOffset )
		button.ArrowDown.Width:Set(arrowThickness)
		button.ArrowDown.Height:Set(arrowLength)
		button.ArrowDown:SetAlpha(arrowAlpha)
	end
	if isLocked then
		-- zero functionality
		button:SetAlpha(0.25)
		button.label:SetAlpha(0.25)
	elseif isStarted then
		-- special highlighting while being researched
		button:SetAlpha(1.00)
		button.label:SetAlpha(1.00)
		button.label:SetColor(ResearchTechColorStart)
		local buttonText = 'Researching...'
		if( researchLevel > 0 ) then
			buttonText = buttonText .. '(' .. researchLevel .. ')'
		end
		button.label:SetText( buttonText )
	elseif isCompleted then
		-- filled border
		button:SetAlpha(0.75)
		button.label:SetAlpha(0.75)
	else
		-- ready for use
		button:SetAlpha(1.00)
		button.label:SetAlpha(1.00)
	end

	-- setup handling for onClick and onRollover
	button.Data = {
		researchID		= researchID,
		techID			= techID,
		branchID		= branchID,
		techInfo		= techInfo,
		rolloverInfo	= rolloverInfo,
		preReq			= preReq,
		preReqAlt		= preReqAlt,
		preReqBrk		= preReqBrk,
	}

	button.OnClick = function(self)
		ResearchClickHandler(button)
	end

	button.OnRolloverEvent = function(self, event)
		ResearchRollOverHandler(button, event)
	end

   	return button
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function CreateEnergyToResearchConversionButton( parent )

    --local conversionButton = UIUtil.CreateButtonStd( parent, '/dialogs/check-box_btn/radio-d' )
	--LayoutHelpers.Above(conversionButton, ProtoResearchTree, 3 )

	local buttonArt		= '/proto/branch'
	local clickCue		= "UI_Menu_MouseDown_Sml"
	local rolloverCue	= "UI_Menu_Rollover_Sml"
	local up			= UIUtil.SkinnableFile(buttonArt .. '_btn_up.dds')
	local down			= UIUtil.SkinnableFile(buttonArt .. '_btn_down.dds')
	local over			= UIUtil.SkinnableFile(buttonArt .. '_btn_over.dds')
	local disabled		= UIUtil.SkinnableFile(buttonArt .. '_btn_dis.dds')

	ProtoResearchTree.BuyOptionsPanel = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_m.dds'))
	ProtoResearchTree.BuyOptionsPanel.Width:Set(160)
	ProtoResearchTree.BuyOptionsPanel.Height:Set(30)
	LayoutHelpers.Above(ProtoResearchTree.BuyOptionsPanel, ProtoResearchTree, 8)

	ProtoResearchTree.BuyOptionsPanel.border = UIUtil.CreateBorder(ProtoResearchTree.BuyOptionsPanel, true)

	local conversionButton = Button( ProtoResearchTree.BuyOptionsPanel, up, down, over, disabled, clickCue, rolloverCue)
	conversionButton.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
	LayoutHelpers.AtVerticalCenterIn(conversionButton, ProtoResearchTree.BuyOptionsPanel, -6 )
	LayoutHelpers.AtLeftIn(conversionButton, ProtoResearchTree.BuyOptionsPanel )

	conversionButton.label1 = UIUtil.CreateText(conversionButton, '<- Buy 1 Research Point:', 12, "Arial")
	conversionButton.label2 = UIUtil.CreateText(conversionButton, '150 Mass and 450 Energy', 12, "Arial")
	LayoutHelpers.RightOf( conversionButton.label1, conversionButton, 2 )
	LayoutHelpers.Below( conversionButton.label2, conversionButton.label1 )
	conversionButton.label1:SetColor('white')
	conversionButton.label2:SetColor('white')
	conversionButton:UseAlphaHitTest(true)

    conversionButton.OnClick = function(self, modifiers)
		local econData = GetEconomyTotals()
		local currEnergy = econData["stored"]["ENERGY"]
		local currMass = econData["stored"]["MASS"]
		local currResearchPoints = econData["stored"]["RESEARCH"]

		if currEnergy >= 450 and currMass >= 150 then
			IssueCommand( "UNITCOMMAND_Script", { TaskName	= "ResearchAddPointTask" } )

			--SC2 FEEDBACK TAG:
			local info = 'Research Point Purchased'
			--LOG(info)
			local data = {text = info, size = 20, color = 'ff22ff22', duration = 3, location = 'centertop'}
			import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
		else
			--SC2 FEEDBACK TAG:
			local info = 'Not enough resources available to convert to research points'
			--LOG(info)
			local data = {text = info, size = 20, color = 'ffff2222', duration = 3, location = 'centertop'}
			import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)

			local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
			PlaySound(sound)
		end
    end
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


------------------------------------------------------------------------------

function FormatData(unitData, type)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~FormatData: top')
    local retData = {}
    if type == 'construction' then
        local function SortFunc(unit1, unit2)
            local bp1 = GetUnitBlueprintByName(unit1).BuildIconSortPriority or GetUnitBlueprintByName(unit1).StrategicIconSortPriority
            local bp2 = GetUnitBlueprintByName(unit2).BuildIconSortPriority or GetUnitBlueprintByName(unit2).StrategicIconSortPriority
            if bp1 >= bp2 then
                return false
            else
                return true
            end
        end
        local sortedUnits = {}
        local sortCategories = {
            categories.SORTCONSTRUCTION,
			categories.SORTMOBILE,
            categories.SORTECONOMY,
            categories.SORTDEFENSE,
            categories.SORTSTRATEGIC,
            categories.SORTINTEL,
			categories.SORTUPGRADES,
            categories.SORTOTHER,
        }
        local miscCats = categories.ALLUNITS
        local borders = {}
        for i, v in sortCategories do
            local category = v
            local index = i - 1
            local tempIndex = i
            while index > 0 do
                category = category - sortCategories[index]
                index = index - 1
            end
            local units = EntityCategoryFilterDown(category, unitData)
            table.insert(sortedUnits, units)
            miscCats = miscCats - v
        end

        table.insert(sortedUnits, EntityCategoryFilterDown(miscCats, unitData))

        for i, units in sortedUnits do
            table.sort(units, SortFunc)
            local index = i
            if table.getn(units) > 0 then
                if table.getn(retData) > 0 then
                    table.insert(retData, {type = 'spacer'})
                end
                for unitIndex, unit in units do
                    table.insert(retData, {type = 'item', id = unit})
                end
            end
        end

        CreateExtraControls('construction')
        SetSecondaryDisplay('buildQueue')
    elseif type == 'selection' then
        local sortedUnits = {}
        local lowFuelUnits = {}
        local ids = {}
        for _, unit in unitData do
            local id = unit:GetBlueprint().BlueprintId

            if unit:IsInCategory('AIR') and unit:GetFuelRatio() < .2 and unit:GetFuelRatio() > -1 then
                if not lowFuelUnits[id] then
                    table.insert(ids, id)
                    lowFuelUnits[id] = {}
                end
                table.insert(lowFuelUnits[id], unit)
            else
                if not sortedUnits[id] then
                    table.insert(ids, id)
                    sortedUnits[id] = {}
                end
                table.insert(sortedUnits[id], unit)
            end
        end

        local displayUnits = true
        if table.getsize(sortedUnits) == table.getsize(lowFuelUnits) then
            displayUnits = false
            for id, units in sortedUnits do
                if lowFuelUnits[id] and not table.equal(lowFuelUnits[id], units) then
                    displayUnits = true
                    break
                end
            end
        end
        if displayUnits then
            for i, v in sortedUnits do
                table.insert(retData, {type = 'unitstack', id = i, units = v})
            end
        end
        for i, v in lowFuelUnits do
            table.insert(retData, {type = 'unitstack', id = i, units = v, lowFuel = true})
        end
        CreateExtraControls('selection')
        SetSecondaryDisplay('attached')
    elseif type == 'templates' then
        table.sort(unitData, function(a,b)
            if a.key and not b.key then
                return true
            elseif b.key and not a.key then
                return false
            elseif a.key and b.key then
                return a.key <= b.key
            elseif a.name == b.name then
                return false
            else
                if LOC(a.name) <= LOC(b.name) then
                    return true
                else
                    return false
                end
            end
        end)
        for _, v in unitData do
            table.insert(retData, {type = 'templates', id = 'template', template = v})
        end
        CreateExtraControls('templates')
        SetSecondaryDisplay('buildQueue')
    else
        ------------------------------------------------------------------------------
		-- SC2: removing the enhancement functionality - it has been converted to the proto research system - and is handled elsewhere - bfricks 10/22/2008
		WARN("SC2 WARNING: the enhancement system is being referenced but no longer supported. - bfricks 10/22/08")
        ------------------------------------------------------------------------------
    end
    import(UIUtil.GetLayoutFilename('construction')).OnTabChangeLayout(type)
    return retData
end

function SetSecondaryDisplay(type)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SetSecondaryDisplay: top')
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SetSecondaryDisplay: type:[', type, ']')
    local data = {}
    if type == 'buildQueue' then
        if currentCommandQueue and table.getn(currentCommandQueue) > 0 then
            for index, unit in currentCommandQueue do
                table.insert(data, {type = 'queuestack', id = unit.id, count = unit.count, position = index})
            end
        end
        if table.getn(sortedOptions.selection) == 1 and table.getn(data) > 0 then
            controls.secondaryProgress:SetNeedsFrameUpdate(true)
        else
            controls.secondaryProgress:SetNeedsFrameUpdate(false)
            controls.secondaryProgress:SetAlpha(0, true)
        end
    elseif type == 'attached' then
        local attachedUnits = EntityCategoryFilterDown(categories.MOBILE, GetAttachedUnitsList(sortedOptions.selection))
        if attachedUnits and table.getn(attachedUnits) > 0 then
            for _, v in attachedUnits do
                table.insert(data, {type = 'attachedunit', id = v:GetBlueprint().BlueprintId, unit = v})
            end
        end
        controls.secondaryProgress:SetAlpha(0, true)
    end
    controls.secondaryChoices:Refresh(data)
end

local prevBuildables = false
local prevSelection = false
local prevBuildCategories = false

function OnQueueChanged(newQueue)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~OnQueueChanged: top')
    currentCommandQueue = newQueue
    if not controls.selectionTab:IsChecked() then
        SetSecondaryDisplay('buildQueue')
    end
end

function CheckForOrderQueue(newSelection)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~CheckForOrderQueue: top')
    if table.getn(selection) == 1 then
        -- render the command queue
        if currentCommandQueue then
            SetQueueGrid(currentCommandQueue, selection)
        else
            ClearQueueGrid()
        end
        SetQueueState(false)
    elseif table.getn(selection) > 0 then
        ClearCurrentFactoryForQueueDisplay()
        ClearQueueGrid()
        SetQueueState(false)
    else
        ClearCurrentFactoryForQueueDisplay()
        ClearQueueGrid()
        SetQueueState(true)
    end
end

function ShowBuildModeKeys(show)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ShowBuildModeKeys: top')
    showBuildIcons = show
    
    local bmdata = import('/lua/ui/game/buildmodedata.lua').buildModeKeys
    
end

function NewTech(Data)
    for _, unitList in Data do
        for _, unit in unitList do
            table.insert(newTechUnits, unit)
        end
    end
end

-- given a tech level, sets that tech level, returns false if tech level not available
function SetCurrentTechTab(techLevel)
	UISelectConstructionTab( techLevel )
    return true
end

function GetCurrentTechTab()
    return UIGetSelectedConstructionTabIndex()
end

function HandleBuildModeKey(key)
	--LOG('CONSTRUCTION TESTING: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~HandleBuildModeKey: top')
    if capturingKeys then
        ProcessKeybinding(key)
    else
        BuildTemplate(key)
    end
end

function BuildTemplate(key, modifiers)
    for _, item in controls.choices.Items do
        if item.BuildKey == key then
            OnClickHandler(item, modifiers)
            return true
        end
    end
    return false
end
