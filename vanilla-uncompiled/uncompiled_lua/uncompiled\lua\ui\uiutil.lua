 --*****************************************************************************
--* File: lua/modules/ui/uiutil.lua
--* Author: Chris Blackwell
--* Summary: Various utility functions to make UI scripts easier and more consistent
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local LazyVar = import('/lua/system/lazyvar.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Text = import('/lua/maui/text.lua').Text
local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
local Button = import('/lua/maui/button.lua').Button
local Edit = import('/lua/maui/edit.lua').Edit
local Checkbox = import('/lua/maui/Checkbox.lua').Checkbox
local Scrollbar = import('/lua/maui/scrollbar.lua').Scrollbar
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Cursor = import('/lua/maui/cursor.lua').Cursor
local Prefs = import('/lua/user/prefs.lua')
local Border = import('/lua/maui/border.lua').Border
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Layouts = import('/lua/ui/skins/layouts.lua')

----FIX: this variable should be reviewed - it was being referenced below without being innitialized - so not entirely sure what it should be set to, or where
----				this is a temp fix to allow MP testing to proceed - bfricks 1/7/09
local takeFocus = false

local EffectHelpers= nil
local CursorHiddenRefCount= 0
--* Handy global variables to assist skinning
buttonFont = import('/lua/system/lazyvar.lua').Create()            -- default font used for button faces
factionFont = import('/lua/system/lazyvar.lua').Create()      -- default font used for dialog button faces
dialogButtonFont = import('/lua/system/lazyvar.lua').Create()      -- default font used for dialog button faces
bodyFont = import('/lua/system/lazyvar.lua').Create()              -- font used for all other text
fixedFont = import('/lua/system/lazyvar.lua').Create()             -- font used for fixed width characters
titleFont = import('/lua/system/lazyvar.lua').Create()             -- font used for titles and labels
fontColor = import('/lua/system/lazyvar.lua').Create()             -- common font color
fontOverColor = import('/lua/system/lazyvar.lua').Create()             -- common font color
fontDownColor = import('/lua/system/lazyvar.lua').Create()             -- common font color
tooltipTitleColor = import('/lua/system/lazyvar.lua').Create()             -- common font color
tooltipBorderColor = import('/lua/system/lazyvar.lua').Create()             -- common font color
bodyColor = import('/lua/system/lazyvar.lua').Create()             -- common color for dialog body text
dialogCaptionColor = import('/lua/system/lazyvar.lua').Create()    -- common color for dialog titles
dialogColumnColor = import('/lua/system/lazyvar.lua').Create()     -- common color for column headers in a dialog
dialogButtonColor = import('/lua/system/lazyvar.lua').Create()     -- common color for buttons in a dialog
highlightColor = import('/lua/system/lazyvar.lua').Create()        -- text highlight color
disabledColor = import('/lua/system/lazyvar.lua').Create()         -- text disabled color
panelColor = import('/lua/system/lazyvar.lua').Create()            -- default color when drawing a panel
transparentPanelColor = import('/lua/system/lazyvar.lua').Create() -- default color when drawing a transparent panel
consoleBGColor = import('/lua/system/lazyvar.lua').Create()        -- console background color
consoleFGColor = import('/lua/system/lazyvar.lua').Create()        -- console foreground color (text)
consoleTextBGColor = import('/lua/system/lazyvar.lua').Create()    -- console text background color
menuFontSize = import('/lua/system/lazyvar.lua').Create()          -- font size used on main in game escape menu
CurrentControls= {}
local CurrentResolution = nil -- '480' or '720'.  Use nil for autoselect based on xbox resolution setting
-- Central place for all fonts, sizes, etc for the game.  Add more as we need them.
local AllFontsX360 =
{
	['480'] =
	{
		General =           { size= 14, fontName= titleFont },
		Title =             { size= 30, fontName= titleFont },
		MenuButtonText=     { size= 14, fontName= titleFont },  -- Example "Single Player"
		MenuTitleText=      { size= 14, fontName= titleFont },  -- Example "Main Menu"
		MenuProfileText=      { size= 14, fontName= titleFont },  -- Example "shaelive"
		ScreenTitleText=    { size= 18, fontName= titleFont },  -- Example "Skirmish Setup"
		ComboBoxText=       { size= 12, fontName= titleFont, overColor = 'FFFFFFFF', color = 'FFA0A0A0', disabledColor = 'FF707070' },
		StandardButtonText= { size= 12, fontName= titleFont },  -- Example "OK", "Cancel" on bottom panel
		DescriptionText=    { size= 12, fontName= bodyFont },  -- Any long descriptions: briefing text, etc.
		CampaignBriefingText=    { size= 12 },  -- uses faction color & font
		CampaignDifficultyText= { size= 14, fontName= titleFont },  -- "Difficulty"
		CampaignFactionNameText= { size= 18, fontName= titleFont },
		CampaignChooseFactionText=    { size= 14, fontName= titleFont },  -- Example "Skirmish Setup"
		CampaignUEFFont=    { fontName= titleFont, color= 'FF709090' },
		CampaignCybranFont=    { fontName= titleFont, color= 'orange' },
		CampaignAeonFont=    { fontName= titleFont, color= 'FF55FF00' },
		CampaignMissionSelectText=    { size= 14 },  -- uses faction color & font
		FileListHeadingText= { size= 16, fontName= titleFont },  -- Name, Date
		FileListElementText= { size= 14, fontName= bodyFont, color= fontColor, highlightColor= 'ffffffa0' },  -- Bob's UEF Game
		OptionDescriptionText= { size= 13, fontName= titleFont },
		LobbyHeaderText= { size= 14, fontName= titleFont },
		LobbyMapInfoText =	{ size= 12, fontName= titleFont },
		LobbyMapDescriptionText =	{ size= 10, fontName= titleFont },
		LobbySettingsCol1Text = { size= 12, fontName= titleFont, color= 'FF709090' },
		LobbySettingsCol2Text = { size= 12, fontName= titleFont  },
		DialogBoxText =	{ size= 18, fontName= titleFont },
		EconomyIncome =	    { size= 12, fontName= bodyFont, color= 'FF50F050' },
		EconomyExpense =	{ size= 12, fontName= bodyFont, color= 'FFF05050' },
		EconomyWarning =	{ size= 12, fontName= titleFont },
		EconomyRate =	    { size= 18, fontName= bodyFont },
		EconomyStorage =	{ size= 14, fontName= bodyFont, color= 'FFD0D0D0' },
		SubTitlesText = { size= 12, fontName= bodyFont },
		ContextualHelp = { size= 12, fontName= bodyFont },
		ScoreHUDText = { size= 12, fontName= bodyFont },
		TalkingHeadTitleText = { size= 16, fontName= bodyFont },
		TalkingHeadText = { size= 12, fontName= bodyFont },
		ConstructionWheelText = { size= 12, fontName= bodyFont },
		DebriefScoreLabelText = { size= 12, fontName= bodyFont },
		DebriefScoreValueText = { size= 14, fontName= bodyFont },
		DebriefScoreHeadingText = { size= 14, fontName= bodyFont },
		DebriefReportText = { size= 14, fontName= bodyFont },
		DebriefReportHeadingText = { size= 18, fontName= bodyFont },
		SkirmishScoreValueText = { size= 13, fontName= bodyFont },
		SkirmishGamerTagText = { size= 16, fontName= bodyFont },
		ToolTipTitleText = { size= 14, fontName= titleFont, color= 'black', bgColor= 'FF93ADAD' },
		ToolTipText = { size= 12, fontName= titleFont },
		UnitViewText = { size= 12, fontName= bodyFont },
		ConnectivityTitleText = { size= 16, fontName= bodyFont },
		ConnectivityText = { size= 14, fontName= bodyFont },
		ConnectDialogs=      { size= 14, fontName=bodyFont}, -- Any disconnect dialogs
		ObjectiveDescriptionText = { size= 14, fontName= bodyFont },
		ObjectiveShortDescriptionText = { size= 14, fontName= bodyFont },
		ObjectiveTimeText = { size= 12, fontName= bodyFont },
		ObjectiveTypeText = { size= 18, fontName= bodyFont },
		RankingsColumnTitleText = { size= 14, fontName= bodyFont },
		RankingsRowText = { size= 14, fontName= bodyFont },
		ResourceText = { green= 'FF50F050', red= 'FFF05050' },
	},
	['720'] =
	{
		General =           { size= 14, fontName= titleFont },
		Title =             { size= 30, fontName= titleFont },
		MenuButtonText=     { size= 22, fontName= titleFont },
		MenuTitleText=      { size= 24, fontName= titleFont },
		MenuProfileText=    { size= 24, fontName= bodyFont },  -- Example "shaelive"
		ScreenTitleText=    { size= 26, fontName= titleFont },
		ComboBoxText=       { size= 18, fontName= titleFont, overColor = 'FFFFFFFF', color = 'FFFFFFFF', disabledColor = 'FF404040' },
		StandardButtonText= { size= 20, fontName= titleFont },  -- Example "OK", "Cancel" on bottom panel
		DescriptionText=    { size= 18, fontName= bodyFont },  -- Any long descriptions: briefing text, etc.
		CampaignBriefingText=    { size= 20 },
		CampaignDifficultyText= { size= 18, fontName= titleFont },  -- "Difficulty"
		CampaignFactionNameText= { size= 24, fontName= titleFont },
		CampaignChooseFactionText=    { size= 20, fontName= titleFont },  -- Example "Skirmish Setup"
		CampaignUEFFont=    { fontName= titleFont, color= 'FF709090' },
		CampaignCybranFont=    { fontName= titleFont, color= 'orange' },
		CampaignAeonFont=    { fontName= titleFont, color= 'FF55FF00' },
		CampaignMissionSelectText=    { size= 20 },  -- uses faction color & font
		FileListHeadingText= { size= 18, fontName= titleFont },  -- Name, Date
		FileListElementText= { size= 16, fontName= bodyFont, color= fontColor, highlightColor= 'ffffffa0' },  -- Bob's UEF Game
		OptionDescriptionText= { size= 18, fontName= titleFont },
		LobbyHeaderText= { size= 18, fontName= titleFont },
		LobbyMapInfoText =	{ size= 16, fontName= titleFont },
		LobbyMapDescriptionText =	{ size= 18, fontName= titleFont },
		LobbySettingsCol1Text = { size= 18, fontName= titleFont, color= 'FF709090' },
		LobbySettingsCol2Text = { size= 18, fontName= titleFont  },
		DialogBoxText =	{ size= 18, fontName= titleFont },
		EconomyIncome =	    { size= 20, fontName= bodyFont, color= 'FF50F050' },
		EconomyExpense =	{ size= 20, fontName= bodyFont, color= 'FFF05050' },
		EconomyWarning =	{ size= 16, fontName= titleFont },
		EconomyRate =	    { size= 25, fontName= bodyFont },
		EconomyStorage =	{ size= 20, fontName= bodyFont, color= 'FFD0D0D0' },
		SubTitlesText = { size= 22, fontName=bodyFont },
		ContextualHelp = { size= 12, fontName= bodyFont },
		ScoreHUDText = { size= 14, fontName= bodyFont },
		TalkingHeadTitleText = { size= 20, fontName= bodyFont },
		TalkingHeadText = { size= 18, fontName= bodyFont },
		ConstructionWheelText = { size= 18, fontName= bodyFont },
		DebriefScoreLabelText = { size= 16, fontName= bodyFont },
		DebriefScoreValueText = { size= 16, fontName= bodyFont },
		DebriefScoreHeadingText = { size= 18, fontName= bodyFont },
		DebriefReportText = { size= 18, fontName= bodyFont },
		DebriefReportHeadingText = { size= 20, fontName= bodyFont },
		SkirmishScoreValueText = { size= 18, fontName= bodyFont },
		SkirmishGamerTagText = { size= 20, fontName= bodyFont },
		ToolTipTitleText = { size= 18, fontName= titleFont, color= 'black', bgColor= 'FF93ADAD' },
		ToolTipText = { size= 16, fontName= titleFont },
		UnitViewText = { size= 18, fontName= bodyFont },
		ConnectivityTitleText = { size= 18, fontName= bodyFont },
		ConnectivityText = { size= 16, fontName= bodyFont },
		ConnectDialogs=      { size= 20, fontName=bodyFont}, -- Any disconnect dialogs
		ObjectiveDescriptionText = { size= 18, fontName= bodyFont },
		ObjectiveShortDescriptionText = { size= 18, fontName= bodyFont },
		ObjectiveShortDescriptionScoreText = { size= 16, fontName= bodyFont },
		ObjectiveTimeText = { size= 16, fontName= bodyFont },
		ObjectiveTypeText = { size= 22, fontName= bodyFont },
		RankingsColumnTitleText = { size= 20, fontName= bodyFont },
		RankingsRowText = { size= 18, fontName= bodyFont },
		ResourceText = { green= 'FF50F050', red= 'FFF05050' },
	},
}
DefaultControls = {
	Forward = 'A',
	ComboActivate = 'A',
	LeftRightComboActivate = 'Y',
}

Fonts = nil
if (IsXbox()) then
	Fonts = AllFontsX360[CurrentResolution or GetXboxScreenHeight()]
end

-- table of layouts supported by this skin, not a lazy var as we don't need updates
layouts = nil

--* other handy variables!
consoleDepth = false  -- in order to get the console to always be on top, assign this number and never go over
local CurrentControlStack= {}
local CurrentStackRefCount= 0
networkBool = import('/lua/system/lazyvar.lua').Create()    -- boolean whether the game is local or networked

-- Default scenario for skirmishes / MP Lobby
defaultScenario = '/maps/scmp_039/scmp_039_scenario.lua'

--* These values MUST NOT CHANGE! They syncronize with values in UIManager.h and are used to
--* specify a render pass
-- render before the world is rendered
UIRP_UnderWorld     = 1
-- reserved for world views
UIRP_World          = 2
-- render with glow (note, won't render when world isn't visible)
UIRP_Glow           = 4
-- render without glow
UIRP_PostGlow       = 8

--* useful key codes, weirdly inconsistent, some are MSW vk codes, some are wxW codes :(
VK_BACKSPACE = 8
VK_TAB = 9
VK_ENTER = 13
VK_ESCAPE = 27
VK_SPACE = 32
VK_PRIOR = 33
VK_NEXT = 34
VK_UP = 38
VK_DOWN = 40
VK_F1 = 112
VK_F2 = 113
VK_F3 = 114
VK_F4 = 115
VK_F5 = 116
VK_F6 = 117
VK_F7 = 118
VK_F8 = 119
VK_F9 = 120
VK_F10 = 121
VK_F11 = 122
VK_F12 = 123
VK_PAUSE = 310

local currentSkin = import('/lua/system/lazyvar.lua').Create()

currentLayout = false
changeLayoutFunction = false    -- set this function to get called with the new layout name when layout changes

function HideCursor()
	CursorHiddenRefCount= CursorHiddenRefCount + 1
	GetCursor():HideJoystickCursor()
end

function ShowCursor()
	CursorHiddenRefCount= CursorHiddenRefCount - 1
	if CursorHiddenRefCount <= 0 then
		GetCursor():ShowJoystickCursor()
		CursorHiddenRefCount= 0
	end
end
--* layout control, sets current layout preference
function SetCurrentLayout(layout)
	if not layout then return end
	-- make sure this skin contains the layout, otherwise do nothing
	local foundLayout = false
	for index, complayout in layouts do
		if layout == complayout then
			foundLayout = true
			break
		end
	end
	if not foundLayout then return end

	currentLayout = layout
	Prefs.SetToCurrentProfile("layout", currentLayout)
	--TEMP - this is here because the grids get hosed when you switch layouts. The grids will be fixed
	-- but until then this will have to suffice
	SelectUnits(nil)
	if changeLayoutFunction then changeLayoutFunction(layout) end
end

function GetNetworkBool()
	local sessionClientsTable = GetSessionClients()
	local networkBool = false
	local sessionBool = true
	if sessionClientsTable != nil then
		networkBool = SessionIsMultiplayer()
	else
		sessionBool = false
	end
	return networkBool, sessionBool
end

function GetAnimationPrefs()
	return true
end

function GetLayoutFilename(key)
	if Layouts[currentLayout][key] then
		return Layouts[currentLayout][key]
	else
		WARN('No layout file for \'', key, '\' in the current layout. Expect layout errors.')
		return false
	end
end

--* skin control, sets the current skin table
function SetCurrentSkin(skin)
	local skins = import('/lua/ui/skins/skins.lua').skins

	if skins[skin] == nil then
        skin = 'uef'
	end

	currentSkin:Set(skin)

	tooltipTitleColor:Set(skins[skin].tooltipTitleColor or skins['default'].tooltipTitleColor)
	tooltipBorderColor:Set(skins[skin].tooltipBorderColor or skins['default'].tooltipBorderColor)
	buttonFont:Set(skins[skin].buttonFont or skins['default'].buttonFont)
	factionFont:Set(skins[skin].factionFont or skins['default'].factionFont)
	dialogButtonFont:Set(skins[skin].dialogButtonFont or skins['default'].dialogButtonFont)
	bodyFont:Set(skins[skin].bodyFont or skins['default'].bodyFont)
	fixedFont:Set(skins[skin].fixedFont or skins['default'].fixedFont)
	titleFont:Set(skins[skin].titleFont or skins['default'].titleFont)
	fontColor:Set(skins[skin].fontColor or skins['default'].fontColor)
	bodyColor:Set(skins[skin].bodyColor or skins['default'].bodyColor)
	fontOverColor:Set(skins[skin].fontOverColor or skins['default'].fontOverColor)
	fontDownColor:Set(skins[skin].fontDownColor or skins['default'].fontDownColor)
	dialogCaptionColor:Set(skins[skin].dialogCaptionColor or skins['default'].dialogCaptionColor)
	dialogColumnColor:Set(skins[skin].dialogColumnColor or skins['default'].dialogColumnColor)
	dialogButtonColor:Set(skins[skin].dialogButtonColor or skins['default'].dialogButtonColor)
	highlightColor:Set(skins[skin].highlightColor or skins['default'].highlightColor)
	disabledColor:Set(skins[skin].disabledColor or skins['default'].disabledColor)
	panelColor:Set(skins[skin].panelColor or skins['default'].panelColor)
	transparentPanelColor:Set(skins[skin].transparentPanelColor or skins['default'].transparentPanelColor)
	consoleBGColor:Set(skins[skin].consoleBGColor or skins['default'].consoleBGColor)
	consoleFGColor:Set(skins[skin].consoleFGColor or skins['default'].consoleFGColor)
	consoleTextBGColor:Set(skins[skin].consoleTextBGColor or skins['default'].consoleTextBGColor)
	menuFontSize:Set(skins[skin].menuFontSize or skins['default'].menuFontSize)
	layouts = skins[skin].layouts or skins['default'].layouts

	local curLayout = Prefs.GetFromCurrentProfile("layout")

	if not curLayout then
		SetCurrentLayout(layouts[1])
	else
		local validLayout = false
		for i, layoutName in layouts do
			if layoutName == curLayout then
				validLayout = true
				break
			end
		end
		if validLayout then
			SetCurrentLayout(curLayout)
		else
			SetCurrentLayout(layouts[1])
		end
	end

	Prefs.SetToCurrentProfile("skin", skin)
end

--* cycle through all available skins
function RotateSkin(direction)
	if not SessionIsActive() or import('/lua/ui/game/gamemain.lua').IsNISMode() then
		return
	end

	local skins = import('/lua/ui/skins/skins.lua').skins

	-- build an array of skin names
	local skinNames = {}
	for skin in skins do
		table.insert(skinNames, skin)
	end

	local dir
	if direction == '+' then
		dir = 1
	else
		dir = -1
	end

	-- Find the next skin from our current skin, skipping default, as it's not really a skin!
	-- note that if the skin table is updated while running, the order of the table might change
	-- so your cycle may be different. No big deal, just be aware it's a side effect.
	local numSkins = table.getn(skinNames)
	for index, skinName in skinNames do
		if skinName == currentSkin() then
			local nextSkinIndex = index + dir
			if nextSkinIndex > numSkins then nextSkinIndex = 1 end
			if nextSkinIndex < 1 then nextSkinIndex = numSkins end
			if skinNames[nextSkinIndex] == 'default' then   -- skip default entry as it's not really a skin
				nextSkinIndex = nextSkinIndex + dir
				if nextSkinIndex > numSkins then nextSkinIndex = 1 end
				if nextSkinIndex < 1 then nextSkinIndex = numSkins end
			end
			LOG('attempting to set skin to: ', skinNames[nextSkinIndex])
			SetCurrentSkin(skinNames[nextSkinIndex])
			break
		end
	end
end

--* cycle through all available layouts
function RotateLayout(direction)

	-- disable when in Screen Capture mode
	if import('/lua/ui/game/gamemain.lua').gameUIHidden then
		return
	end

	local dir
	if direction == '+' then
		dir = 1
	else
		dir = -1
	end

	local numLayouts = table.getn(layouts)
	for index, layoutName in layouts do
		if layoutName == currentLayout then
			local nextLayoutIndex = index + dir
			if nextLayoutIndex > numLayouts then nextLayoutIndex = 1 end
			if nextLayoutIndex < 1 then nextLayoutIndex = numLayouts end
			SetCurrentLayout(layouts[nextLayoutIndex])
			break
		end
	end
end

--* given a path and name relative to the skin path, returns the full path based on the current skin
function UIFile(filespec)
	local skins = import('/lua/ui/skins/skins.lua').skins
	local visitingSkin = currentSkin()
	local currentPath = skins[visitingSkin].texturesPath

	if visitingSkin == nil or currentPath == nil then
		return nil
	end

	-- if current skin is default, then don't bother trying to look for it, just append the default dir
	if visitingSkin == 'default' then
		return currentPath .. filespec
	else
		while visitingSkin do
			local curFile = currentPath .. filespec
			if DiskGetFileInfo(curFile) then
				return curFile
			else
				visitingSkin = skins[visitingSkin].default
				if visitingSkin then currentPath = skins[visitingSkin].texturesPath end
			end
		end
	end

	LOG("Warning: Unable to find file ", filespec)
	-- pass out the final string anyway so resource loader can gracefully fail
	return filespec
end

--* return the filename as a lazy var function to allow triggering of OnDirty
function SkinnableFile(filespec)
	return function()
		return UIFile(filespec)
	end
end

function GetCurrentXboxScreenHeight()
	local widescreen
	if not CurrentResolution then
		CurrentResolution, widescreen = GetXboxScreenHeight()
		Fonts= AllFontsX360[CurrentResolution]
	end
	return CurrentResolution, widescreen
end

function GetRightScreenSafeEdge()
	local res
	local wideScreen
	res, wideScreen = GetXboxScreenHeight()
	if wideScreen then
		if res == '480' then
			return 680
		else
			return 1200
		end
	else
		if res == '480' then
			return 600
		else
			return 900
		end
	end
end

function GetInGameEdgeOffset(rightEdge)
	local res
	local wideScreen
	res, wideScreen = GetXboxScreenHeight()
	if wideScreen then
		wideScreen= 'wide'
	else
		wideScreen= 'normal'
	end
	if rightEdge then
		rightEdge= 'Right'
	else
		rightEdge= 'Left'
	end
	local Offsets=
	{
		['480'] =
		{
			wide =
			{
				Left= 20,  -- Extra screen safe area
				Right= 200, -- 854 - 15 - 640 ish.
			},
			normal =
			{
				Left= 0,
				Right= 0,
			},
		},
		['720'] =
		{
			wide =
			{
				Left= 10,
				Right= 0, -- (1280-960)
			},
			normal =
			{
				Left= 0,
				Right= 0,
			},
		},
	}

	return Offsets[res][wideScreen][rightEdge]
end

local function CheckCurrentResolution()
	if not CurrentResolution then
		CurrentResolution = GetXboxScreenHeight()
		Fonts= AllFontsXbox360[CurrentResolution]
	end
end

function UIGetFileForRes(filespec, noskin)
	local newFilespec= filespec
--    CheckCurrentResolution()
--    if CurrentResolution != '480' then
--        newFilespec = string.gsub(filespec, '480', CurrentResolution)
--    end
	if not noskin then
		return function() return UIFile(newFilespec) end
	else
		return UIFile(newFilespec)
	end
end

ButtonIcons=
{
	{   'A',        UIGetFileForRes('/game/buttons480/ButtonA.dds'),  },
	{   'B',        UIGetFileForRes('/game/buttons480/ButtonB.dds'),  },
	{   'X',        UIGetFileForRes('/game/buttons480/ButtonX.dds'),  },
	{   'Y',        UIGetFileForRes('/game/buttons480/ButtonY.dds'),  },
	{   'DPadUp',   UIGetFileForRes('/game/buttons480/DPadUp.dds'),   },
	{   'DPadDown', UIGetFileForRes('/game/buttons480/DPadDown.dds'),   },
	{   'DPadLeft', UIGetFileForRes('/game/buttons480/DPadLeft.dds'),   },
	{   'DPadRight',UIGetFileForRes('/game/buttons480/DPadRight.dds'),   },
	{   'Start',    UIGetFileForRes('/game/buttons480/ButtonStart.dds'),  },
	{   'Back',     UIGetFileForRes('/game/buttons480/ButtonBack.dds'),  },
	{   'LeftShoulder', UIGetFileForRes('/game/buttons480/LeftShoulder.dds'),  },
	{   'RightShoulder',UIGetFileForRes('/game/buttons480/RightShoulder.dds'),  },
	{   'LeftThumb', UIGetFileForRes('/game/buttons480/LeftThumb.dds'),  },
	{   'RightThumb',UIGetFileForRes('/game/buttons480/RightThumb.dds'),  },
	{   'LeftTrigger', UIGetFileForRes('/game/buttons480/LeftTrigger.dds'),  },
	{   'RightTrigger',UIGetFileForRes('/game/buttons480/RightTrigger.dds'),  },
}

--* each UI screen needs something to be responsible for parenting all its controls so
--* placement and destruction can occur. This creates a group which fills the screen.
function CreateScreenGroup(root, debugName)
	if not root then return end
	local screenGroup = Group(root, debugName or "screenGroup")
	LayoutHelpers.FillParent(screenGroup, root)
	return screenGroup
end

--* Get cursor information for a given cursor ID
function GetCursor(id)
	local skins = import('/lua/ui/skins/skins.lua').skins
	local cursors = skins[currentSkin()].cursors or skins['default'].cursors
	if not cursors[id] then
		LOG("Requested cursor not found: " .. id)
	end
	return cursors[id][1], cursors[id][2], cursors[id][3], cursors[id][4], cursors[id][5]
end

--* create the one cursor used by the game
function CreateCursor()
	if not UseGamepad() then
		local cursor = Cursor(true, GetCursor('DEFAULT'))
		return cursor
	else  
		local cursor = Cursor(false, GetCursor('DEFAULT_GAMEPAD'))
		cursor:UseQuadCursor(true)
		return cursor
	end
end

--* return a text object with the appropriate font set
function CreateText(parent, label, pointSize, font)
	label = LOC(label) or LOC("<LOC uiutil_0000>[no text]")
	font = font or buttonFont
	local text = Text(parent, "Text: " .. label)
	text:SetFont(font, pointSize)
	text:SetColor(fontColor)
	text:SetText(label)
	return text
end

function SetupEditStd(control, foreColor, backColor, highlightFore, highlightBack, fontFace, fontSize, charLimit)
	if charLimit then
		control:SetMaxChars(charLimit)
	end
	if foreColor then
		control:SetForegroundColor(foreColor)
	end
	if backColor then
		control:SetBackgroundColor(backColor)
	end
	if highlightFore then
		control:SetHighlightForegroundColor(highlightFore)
	end
	if highlightBack then
		control:SetHighlightBackgroundColor(highlightBack)
	end
	if fontFace and fontSize then
		control:SetFont(fontFace, fontSize)
	end

	control.OnCharPressed = function(self, charcode)
		if charcode == VK_TAB then
			return true
		end
		local charLim = self:GetMaxChars()
		if STR_Utf8Len(self:GetText()) >= charLim then
			local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
			PlaySound(sound)
		end
	end
end

--* return a button set up with a text overlay and a click sound
function CreateButton(parent, up, down, over, disabled, label, pointSize, textOffsetVert, textOffsetHorz, clickCue, rolloverCue)
	textOffsetVert = textOffsetVert or 0
	textOffsetHorz = textOffsetHorz or 0
	if clickCue == "NO_SOUND" then
		clickCue = nil
	else
		clickCue = clickCue or "UI_Menu_MouseDown_Sml"
	end
	if rolloverCue == "NO_SOUND" then
		rolloverCue = nil
	else
		rolloverCue = rolloverCue or "UI_Menu_Rollover_Sml"
	end
	if type(up) == 'string' then
		up = SkinnableFile(up)
	end
	if type(down) == 'string' then
		down = SkinnableFile(down)
	end
	if type(over) == 'string' then
		over = SkinnableFile(over)
	end
	if type(disabled) == 'string' then
		disabled = SkinnableFile(disabled)
	end

	local button = Button(parent, up, down, over, disabled, clickCue, rolloverCue)
	button:UseAlphaHitTest(true)

	if label and pointSize then
		button.label = CreateText(button, label, pointSize)
		LayoutHelpers.AtCenterIn(button.label, button, textOffsetVert, textOffsetHorz)
		button.label:DisableHitTest()

		-- if text exists, set up to grey it out
		button.OnDisable = function(self)
			Button.OnDisable(self)
			button.label:SetColor(disabledColor)
		end

		button.OnEnable = function(self)
			Button.OnEnable(self)
			button.label:SetColor(fontColor)
		end
		button.OnRolloverEvent = function(self, event)
			if event == 'enter' then
				button.label:SetColor(fontOverColor)
			elseif event == 'exit' then
				button.label:SetColor(fontColor)
			elseif event == 'down' then
				button.label:SetColor(fontDownColor)
			end
		end
	end

	return button
end

function SetNewButtonTextures(button, up, down, over, disabled)
	-- if strings passed in, make them skinnables, otherwise assume they are already skinnables
	if type(up) == 'string' then
		up = SkinnableFile(up)
	end
	if type(down) == 'string' then
		down = SkinnableFile(down)
	end
	if type(over) == 'string' then
		over = SkinnableFile(over)
	end
	if type(disabled) == 'string' then
		disabled = SkinnableFile(disabled)
	end

	button:SetNewTextures(up, down, over, disabled)
end

--* create a button with standardized texture names
--* given a path and button name prefix, generates the four button asset file names according to the naming convention
function CreateButtonStd(parent, filename, label, pointSize, textOffsetVert, textOffsetHorz, clickCue, rolloverCue)
	return CreateButton(parent
		, filename .. "_btn_up.dds"
		, filename .. "_btn_down.dds"
		, filename .. "_btn_over.dds"
		, filename .. "_btn_dis.dds"
		, label
		, pointSize
		, textOffsetVert
		, textOffsetHorz
		, clickCue
		, rolloverCue
		)
end

function CreateCheckbox(parent, up, upsel, over, oversel, dis, dissel, clickCue, rollCue)
	local clickSound = clickCue or 'UI_Mini_MouseDown'
	local rollSound = rollCue or 'UI_Mini_Rollover'
	local checkbox = Checkbox( parent, up, upsel, over, oversel, dis, dissel, clickSound, rollSound)
	checkbox:UseAlphaHitTest(true)
	return checkbox
end

function CreateCheckboxStd(parent, filename, clickCue, rollCue)
	local checkbox = CreateCheckbox( parent,
		SkinnableFile(filename .. '-d_btn_up.dds'),
		SkinnableFile(filename .. '-s_btn_up.dds'),
		SkinnableFile(filename .. '-d_btn_over.dds'),
		SkinnableFile(filename .. '-s_btn_over.dds'),
		SkinnableFile(filename .. '-d_btn_dis.dds'),
		SkinnableFile(filename .. '-s_btn_dis.dds'),
		clickCue, rollCue)
	return checkbox
end

function CreateDialogButtonStd(parent, filename, label, pointSize, textOffsetVert, textOffsetHorz, clickCue, rolloverCue)
	local button = CreateButtonStd(parent,filename,label,pointSize,textOffsetVert,textOffsetHorz, clickCue, rolloverCue)
	button.label:SetFont( dialogButtonFont, pointSize )
	button.label:SetColor( dialogButtonColor )
	return button
end

function SetNewButtonStdTextures(button, filename)
	SetNewButtonTextures(button
		, filename .. "_btn_up.dds"
		, filename .. "_btn_down.dds"
		, filename .. "_btn_over.dds"
		, filename .. "_btn_dis.dds")
end

--* return the standard scrollbar
function CreateVertScrollbarFor(attachto, offset, filename)
	offset = offset or 0
	local textureName = filename or '/small-vert_scroll/'
	local scrollbg = textureName..'back_scr_mid.dds'
	local scrollbarmid = textureName..'bar-mid_scr_over.dds'
	local scrollbartop = textureName..'bar-top_scr_up.dds'
	local scrollbarbot = textureName..'bar-bot_scr_up.dds'
	if filename then
		scrollbg = textureName..'back_scr_mid.dds'
		scrollbarmid = textureName..'bar-mid_scr_up.dds'
		scrollbartop = textureName..'bar-top_scr_up.dds'
		scrollbarbot = textureName..'bar-bot_scr_up.dds'
	end
	local scrollbar = Scrollbar(attachto, import('/lua/maui/scrollbar.lua').ScrollAxis.Vert)
	scrollbar:SetTextures(  SkinnableFile(scrollbg)
							,SkinnableFile(scrollbarmid)
							,SkinnableFile(scrollbartop)
							,SkinnableFile(scrollbarbot))

	local scrollUpButton = Button(  scrollbar
									, SkinnableFile(textureName..'arrow-up_scr_up.dds')
									, SkinnableFile(textureName..'arrow-up_scr_over.dds')
									, SkinnableFile(textureName..'arrow-up_scr_down.dds')
									, SkinnableFile(textureName..'arrow-up_scr_dis.dds')
									, "UI_Arrow_Click")

	local scrollDownButton = Button(  scrollbar
									, SkinnableFile(textureName..'arrow-down_scr_up.dds')
									, SkinnableFile(textureName..'arrow-down_scr_over.dds')
									, SkinnableFile(textureName..'arrow-down_scr_down.dds')
									, SkinnableFile(textureName..'arrow-down_scr_dis.dds')
									, "UI_Arrow_Click")

	scrollbar.Left:Set(function() return attachto.Right() + offset end)
	scrollbar.Top:Set(scrollUpButton.Bottom)
	scrollbar.Bottom:Set(scrollDownButton.Top)

	scrollUpButton.Left:Set(scrollbar.Left)
	scrollUpButton.Top:Set(attachto.Top)
	scrollDownButton.Left:Set(scrollbar.Left)
	scrollDownButton.Bottom:Set(attachto.Bottom)

	scrollbar.Right:Set(scrollUpButton.Right)

	scrollbar:AddButtons(scrollUpButton, scrollDownButton)
	scrollbar:SetScrollable(attachto)

	return scrollbar
end

function CreateHorzScrollbarFor(attachto, offset)
	offset = offset or 0
	local scrollbar = Scrollbar(attachto, import('/lua/maui/scrollbar.lua').ScrollAxis.Horz)
	local scrollRightButton = Button(  scrollbar
									, SkinnableFile('/widgets/large-h_scr/arrow-right_scr_up.dds')
									, SkinnableFile('/widgets/large-h_scr/arrow-right_scr_down.dds')
									, SkinnableFile('/widgets/large-h_scr/arrow-right_scr_over.dds')
									, SkinnableFile('/widgets/large-h_scr/arrow-right_scr_dis.dds'))
	scrollRightButton.Right:Set(attachto.Right)
	scrollRightButton.Bottom:Set(function() return attachto.Top() + offset end)

	local scrollLeftButton = Button(  scrollbar
									, SkinnableFile('/widgets/large-h_scr/arrow-left_scr_up.dds')
									, SkinnableFile('/widgets/large-h_scr/arrow-left_scr_down.dds')
									, SkinnableFile('/widgets/large-h_scr/arrow-left_scr_over.dds')
									, SkinnableFile('/widgets/large-h_scr/arrow-left_scr_dis.dds'))
	scrollLeftButton.Left:Set(attachto.Left)
	scrollLeftButton.Bottom:Set(function() return attachto.Top() + offset end)

	scrollbar:SetTextures(  UIFile('/widgets/back_scr/back_scr_mid.dds')
							,UIFile('/widgets/large-h_scr/bar-mid_scr_over.dds')
							,UIFile('/widgets/large-h_scr/bar-right_scr_over.dds')
							,UIFile('/widgets/large-h_scr/bar-left_scr_over.dds'))
	scrollbar.Left:Set(scrollLeftButton.Right)
	scrollbar.Right:Set(scrollRightButton.Left)
	scrollbar.Top:Set(scrollRightButton.Top)
	scrollbar.Bottom:Set(scrollRightButton.Bottom)

	scrollbar:AddButtons(scrollLeftButton, scrollRightButton)
	scrollbar:SetScrollable(attachto)

	return scrollbar
end

-- cause a dialog to get input focus, optional functions to perform when the user hits enter or escape
-- functions signature is: function()
function MakeInputModal(control, onEnterFunc, onEscFunc)
	AddInputCapture(control)

	local oldOnDestroy = control.OnDestroy
	control.OnDestroy = function(self)
		RemoveInputCapture(control)
		oldOnDestroy(self)
	end

	if onEnterFunc or onEscFunc then
		control.oldHandleEvent = control.HandleEvent
		control.HandleEvent = function(self, event)
			if event.Type == 'KeyDown' then
				if event.KeyCode == VK_ESCAPE then
					if onEscFunc then
						onEscFunc()
						return true
					end
				elseif event.KeyCode == VK_ENTER then
					if onEnterFunc then
						onEnterFunc()
						return true
					end
				end
			end
			if control.oldHandleEvent then
				return control.oldHandleEvent(self, event)
			end
			return true
		end
	end
end

-- create and manage an info dialog
-- parent: the control to parent the dialog to
-- dialogText: the text to display in the dialog
-- button1Text: text for the first button (opt)
-- button1Callback: callback function for the first button, signature function() (opt)
-- button2Text: text for the second button (opt)
-- button2Callback: callback function for the second button, signature function() (opt)
-- button3Text: text for the second button (opt)
-- button3Callback: callback function for the second button, signature function() (opt)
-- destroyOnCallback: if true, destroy when any button is pressed (if false, you must destroy) (opt)
-- modalInfo: Sets up modal info for dialog using a table in the form:
--  escapeButton = int 1-3 : the button function to mimic when the escape button is pressed
--  enterButton = int 1-3 : the button function to mimic when the enterButton is pressed
--  worldCover = bool : control if a world cover should be shown
function QuickDialog(parent, dialogText, button1Text, button1Callback, button2Text, button2Callback, button3Text, button3Callback, destroyOnCallback, modalInfo)
	-- if there is a callback and destroy not specified, assume destroy
	if (destroyOnCallback == nil) and (button1Callback or button2Callback or button3Callback) then
		destroyOnCallback = true
	end

	local dialog = Group(parent, "quickDialogGroup")

	LayoutHelpers.AtCenterIn(dialog, parent)
	dialog.Depth:Set(GetFrame(parent:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)
	local background = Bitmap(dialog, SkinnableFile('/dialogs/dialog/panel_bmp_m.dds'))
	dialog._background = background
	dialog.Width:Set(background.Width)
	dialog.Height:Set(background.Height)
	LayoutHelpers.FillParent(background, dialog)

	local textLine = {}
	textLine[1] = CreateText(dialog, "", 18, titleFont)
	textLine[1].Top:Set(background.Top)
	LayoutHelpers.AtHorizontalCenterIn(textLine[1], dialog)

	local textBoxWidth = (dialog.Width() - 80)
	local tempTable = import('/lua/maui/text.lua').WrapText(LOC(dialogText), textBoxWidth,
	function(text)
		return textLine[1]:GetStringAdvance(text)
	end)

	local tempLines = table.getn(tempTable)

	local prevControl = false
	for i, v in tempTable do
		if i == 1 then
			textLine[1]:SetText(v)
			prevControl = textLine[1]
		else
			textLine[i] = CreateText(dialog, v, 18, titleFont)
			LayoutHelpers.Below(textLine[i], prevControl)
			LayoutHelpers.AtHorizontalCenterIn(textLine[i], dialog)
			prevControl = textLine[i]
		end
	end

	background:SetTiled(true)
	background.Bottom:Set(textLine[tempLines].Bottom)

	local backgroundTop = Bitmap(dialog, SkinnableFile('/dialogs/dialog/panel_bmp_T.dds'))
	backgroundTop.Bottom:Set(background.Top)
	backgroundTop.Left:Set(background.Left)
	local backgroundBottom = Bitmap(dialog, SkinnableFile('/dialogs/dialog/panel_bmp_b.dds'))
	backgroundBottom.Top:Set(background.Bottom)
	backgroundBottom.Left:Set(background.Left)

	background.brackets = CreateDialogBrackets(background, 35, 65, 35, 115, true)

	if not modalInfo or modalInfo.worldCover then
		CreateWorldCover(dialog)
	end

	local function MakeButton(text, callback)
		local button = CreateButtonStd( background
										, '/scx_menu/small-btn/small'
										, text
										, 14
										, 2)
		if callback then
			button.OnClick = function(self)
				callback()
				if destroyOnCallback then
					dialog:Destroy()
				end
			end
		else
			button.OnClick = function(self)
				dialog:Destroy()
			end
		end
		return button
	end

	dialog._button1 = false
	dialog._button2 = false
	dialog._button3 = false

	if button1Text then
		dialog._button1 = MakeButton(button1Text, button1Callback)
		LayoutHelpers.Below(dialog._button1, background, 0)
	end
	if button2Text then
		dialog._button2 = MakeButton(button2Text, button2Callback)
		LayoutHelpers.Below(dialog._button2, background, 0)
	end
	if button3Text then
		dialog._button3 = MakeButton(button3Text, button3Callback)
		LayoutHelpers.Below(dialog._button3, background, 0)
	end

	if dialog._button3 then
		-- center each button to one third of the dialog
		LayoutHelpers.AtHorizontalCenterIn(dialog._button2, dialog)
		LayoutHelpers.LeftOf(dialog._button1, dialog._button2, -8)
		LayoutHelpers.ResetLeft(dialog._button1)
		LayoutHelpers.RightOf(dialog._button3, dialog._button2, -8)
		backgroundTop:SetTexture(SkinnableFile('/dialogs/dialog_02/panel_bmp_T.dds'))
		backgroundBottom:SetTexture(SkinnableFile('/dialogs/dialog_02/panel_bmp_b.dds'))
		background:SetTexture(SkinnableFile('/dialogs/dialog_02/panel_bmp_m.dds'))
		-- Assign joystick navigation info
		dialog._button1:SetupJoystickNavigation(dialog._button3, dialog._button2, dialog._button3, dialog._button2)
		dialog._button2:SetupJoystickNavigation(dialog._button1, dialog._button3, dialog._button1, dialog._button3)
		dialog._button3:SetupJoystickNavigation(dialog._button2, dialog._button1, dialog._button2, dialog._button1)
		-- Assign default hilited button
		dialog._button1:TakeJoystickFocus()
	elseif dialog._button2 then
		-- center each button to half the dialog
		dialog._button1.Left:Set(function()
			return dialog.Left() + (((dialog.Width() / 2) - dialog._button1.Width()) / 2) + 8
		end)
		dialog._button2.Left:Set(function()
			local halfWidth = dialog.Width() / 2
			return dialog.Left() + halfWidth + ((halfWidth - dialog._button2.Width()) / 2) - 8
		end)
		-- Assign joystick navigation info
		dialog._button1:SetupJoystickNavigation(dialog._button2, dialog._button2, dialog._button2, dialog._button2)
		dialog._button2:SetupJoystickNavigation(dialog._button1, dialog._button1, dialog._button1, dialog._button1)
		-- Assign default hilited button
		dialog._button1:TakeJoystickFocus()
	elseif dialog._button1 then
		LayoutHelpers.AtHorizontalCenterIn(dialog._button1, dialog)
		-- Assign default hilited button
		dialog._button1:TakeJoystickFocus()
	else
		backgroundBottom:SetTexture(UIFile('/dialogs/dialog/panel_bmp_alt_b.dds'))
		-- No default hilited button - dialog sees joystick presses instead.
		background.brackets:Hide()
		if takeFocus then
			dialog:TakeJoystickFocus()
		end
	end

	if modalInfo and not modalInfo.OnlyWorldCover then
		local function OnEnterFunc()
			if modalInfo.enterButton then
				if modalInfo.enterButton == 1 then
					if dialog._button1 then
						dialog._button1.OnClick(dialog._button1)
					end
				elseif modalInfo.enterButton == 2 then
					if dialog._button2 then
						dialog._button2.OnClick(dialog._button2)
					end
				elseif modalInfo.enterButton == 3 then
					if dialog._button3 then
						dialog._button3.OnClick(dialog._button3)
					end
				end
			end
		end

		local function OnEscFunc()
			if modalInfo.escapeButton then
				if modalInfo.escapeButton == 1 then
					if dialog._button1 then
						dialog._button1.OnClick(dialog._button1)
					end
				elseif modalInfo.escapeButton == 2 then
					if dialog._button2 then
						dialog._button2.OnClick(dialog._button2)
					end
				elseif modalInfo.escapeButton == 3 then
					if dialog._button3 then
						dialog._button3.OnClick(dialog._button3)
					end
				end
			end
		end

		MakeInputModal(dialog, OnEnterFunc, OnEscFunc)
	end

	return dialog
end

function QuickDialog360(parent, dialogText, button1Info, button2Info, button3Info, destroyOnCallback, modalInfo)
	-- if there is a callback and destroy not specified, assume destroy
	if (destroyOnCallback == nil) and
		((button1Info and button1Info.callback) or
		 (button2Info and button2Info.callback) or
		 (button3Info and button3Info.callback)) then
		destroyOnCallback = true
	end

	local baseName= 'dialog_quit_480'
	if GetCurrentResolution() == '720' and GetLanguageFromXbox() == 'FR' then  -- let the hacks begin!
		baseName= 'dialog_quit_480F'
	end
	local dialog = Group(parent, "quickDialog360Group")
	local layout = UIGetFileForRes('/dialogs/360/'..baseName..'/'..baseName..'_layout.lua')
	local layoutTable = import(layout()).layout

	SetDialogActive(true)
	SaveCurrentControl()
	HideCursor()
	if not destroyOnCallback then
		dialog.OnDestroy= function(self)
			SetDialogActive(false)
			RestoreLastControl()
			ShowCursor()
		end
	end

	LayoutHelpers.AtCenterIn(dialog, parent)
	dialog.Depth:Set(GetFrame(parent:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)
	local background = Bitmap(dialog, UIGetFileForRes('/dialogs/360/'..baseName..'/panel_bmp_m.dds'))
	dialog._background = background
	dialog.Width:Set(background.Width)
	dialog.Height:Set(background.Height)
	LayoutHelpers.FillParent(background, dialog)

	local textLine = {}
	textLine[1] = CreateText(dialog, "", Fonts.DialogBoxText.size, Fonts.DialogBoxText.fontName)
	textLine[1].Top:Set(background.Top)
	LayoutHelpers.AtHorizontalCenterIn(textLine[1], dialog)

	local textBoxWidth = (dialog.Width() - 80)
	local tempTable = import('/lua/maui/text.lua').WrapText(LOC(dialogText), textBoxWidth,
	function(text)
		return textLine[1]:GetStringAdvance(text)
	end)

	local tempLines = table.getn(tempTable)

	local prevControl = false
	for i, v in tempTable do
		if i == 1 then
			textLine[1]:SetText(v)
			prevControl = textLine[1]
		else
			textLine[i] = CreateText(dialog, v, 18, titleFont)
			LayoutHelpers.Below(textLine[i], prevControl)
			LayoutHelpers.AtHorizontalCenterIn(textLine[i], dialog)
			prevControl = textLine[i]
		end
		LayoutHelpers.DepthOverParent(textLine[i], background)
	end

	background:SetTiled(true)
	background.Bottom:Set(textLine[tempLines].Bottom)

	local backgroundTop = Bitmap(dialog, UIGetFileForRes('/dialogs/360/'..baseName..'/panel_bmp_T.dds'))
	backgroundTop.Bottom:Set(background.Top)
	backgroundTop.Left:Set(background.Left)
	local backgroundBottom = Bitmap(dialog, UIGetFileForRes('/dialogs/360/'..baseName..'/panel_bmp_b.dds'))
	backgroundBottom.Top:Set(background.Bottom)
	backgroundBottom.Left:Set(background.Left)

	if not modalInfo or modalInfo.worldCover then
		CreateWorldCover(dialog)
	end

	dialog.ButtonList= {}

	local function MakeButton(buttonInfo, placement)
		if not buttonInfo then
			return
		end

		local buttonNameList= { 'l_A_button', 'l_X_Button copy', 'l_B_Button', 'l_2button_left', 'l_2button_right' }

		local ButtonFileName= nil
		for j,bmap in ButtonIcons do
			if bmap[1] == buttonInfo.button then
				ButtonFileName= bmap[2]
				break
			end
		end

		if ButtonFileName then
			local ctrl= Bitmap(background, ButtonFileName)
			ctrl.label= CreateText(ctrl, buttonInfo.text or "", Fonts.StandardButtonText.size, Fonts.StandardButtonText.fontName)

			LayoutHelpers.AtLeftTopIn(ctrl, backgroundBottom,
				layoutTable[buttonNameList[placement]].left - layoutTable['panel_bmp_b'].left,
				layoutTable[buttonNameList[placement]].top - layoutTable['panel_bmp_b'].top)

			LayoutHelpers.RightOf(ctrl.label, ctrl, 15)
			LayoutHelpers.AtVerticalCenterIn(ctrl.label, ctrl, 1)

			LayoutHelpers.DepthOverParent(ctrl, background)
			LayoutHelpers.DepthOverParent(ctrl.label, background)

			ctrl.info= buttonInfo
			table.insert(dialog.ButtonList, ctrl)
			return ctrl
		else
			return nil
		end
	end

	local ValidButtons= 0
	for i, info in {button1Info, button2Info, button3Info} do
		if info then
			ValidButtons= ValidButtons + 1
		end
	end
	for i, info in {button1Info, button2Info, button3Info} do
		if info.button == 'A' then
			if ValidButtons == 3 then
				info.pos= 3
			else
				info.pos= 5
			end
		elseif info.button == 'B' then
			if ValidButtons == 3 then
				info.pos= 1
			else
				info.pos= 4
			end
		else
			if ValidButtons == 3 then
				info.pos= 2
			else
				info.pos= 3+i
			end
		end
	end

	MakeButton(button1Info, button1Info.pos)
	MakeButton(button2Info, button2Info.pos)
	MakeButton(button3Info, button3Info.pos)

	dialog.HandleEvent = function(self, event)
		for i,ctrl in dialog.ButtonList do
			if ((event.Type == ('JoystickButtonRelease')) and
				(event.JoystickButton == ctrl.info.button)) then
				if destroyOnCallback then
					SetDialogActive(false)
					RestoreLastControl()
					ShowCursor()
				end
				if ctrl.info.callback then
					ctrl.info.callback()
				end
				if destroyOnCallback then
					dialog:Destroy()
				end
			end
		end
-- Hack just for the self destruct box to hide when pausing the game.
		if ((modalInfo.startEscape) and (event.Type == ('JoystickButtonPress')) and
			(event.JoystickButton == 'Start')) then
			if destroyOnCallback then
				SetDialogActive(false)
				RestoreLastControl()
				ShowCursor()
			end
			if modalInfo.startEscape then
				modalInfo.startEscape()
			end
			if destroyOnCallback then
				dialog:Destroy()
			end
			return false
		end
		return true
	end

	dialog:TakeJoystickFocus()

	return dialog
end
function CreateWorldCover(parent, colorOverride)
	local NumFrame = GetNumRootFrames() - 1
	local worldCovers = {}
	for i = 0, NumFrame do
		local index = i
		if GetFrame(index) == parent:GetRootFrame() then
			worldCovers[index] = Bitmap(parent)
			worldCovers[index].ID = index
			worldCovers[index].OnDestroy = function(self)
				for h, x in worldCovers do
					if x and h != self.ID then
						x:Destroy()
					end
				end
			end
			worldCovers[index].OnHide = function(self, hidden)
				for h, x in worldCovers do
					if x and h != self.ID then
						x:SetHidden(hidden)
					end
				end
			end
		else
			worldCovers[index] = Bitmap(GetFrame(index))
		end
		worldCovers[index]:SetSolidColor(colorOverride or 'ff000000')
		LayoutHelpers.FillParent(worldCovers[index], GetFrame(index))
		worldCovers[index].Depth:Set(function() return parent.Depth() - 2 end)
		worldCovers[index]:SetAlpha(0)
		worldCovers[index]:SetNeedsFrameUpdate(true)
		worldCovers[index].OnFrame = function(self, delta)
			local targetAlpha = self:GetAlpha() + (delta * 1.5)
			if targetAlpha < .8 then
				self:SetAlpha(targetAlpha)
			else
				self:SetAlpha(.8)
				self:SetNeedsFrameUpdate(false)
			end
		end
	end

	return worldCovers
end

function ShowInfoDialog(parent, dialogText, buttonText, buttonCallback, destroyOnCallback)
	local dlg = QuickDialog(parent, dialogText, buttonText, buttonCallback, nil, nil, nil, nil, destroyOnCallback, {worldCover = false, enterButton = 1, escapeButton = 1})
	return dlg
end

-- create a table of sequential file names (useful for loading animations)
function CreateSequentialFilenameTable(root, ext, first, last, numPlaces)
	local retTable = {}
	local formatString = string.format("%%s%%0%dd.%%s", numPlaces)
	for index = first, last do
		retTable[(index - first) + 1] = SkinnableFile(string.format(formatString, root, index, ext))
	end
	return retTable
end

-- create a box which is controlled by its external borders, and gives access to the "client" area as well
function CreateBox(parent)
	local border = Border(parent)
	border:SetTextures(
		SkinnableFile('/game/generic_brd/generic_brd_vert_l.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_horz_um.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_ul.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_ur.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_ll.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_lr.dds'))
	local clientArea = Bitmap(parent, SkinnableFile('/game/generic_brd/generic_brd_m.dds'))
	border:LayoutControlInside(clientArea)
	clientArea.Width:Set(function() return clientArea.Right() - clientArea.Left() end)
	clientArea.Height:Set(function() return clientAreat.Bottom() - clientArea.Top() end)
	return border, clientArea
end

-- create borders around a control, with optional background
function CreateBorder(parent, addBg)
	local border = Border(parent)
	border:SetTextures(
		SkinnableFile('/game/generic_brd/generic_brd_vert_l.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_horz_um.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_ul.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_ur.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_ll.dds'),
		SkinnableFile('/game/generic_brd/generic_brd_lr.dds'))
	border:LayoutAroundControl(parent)

	local bg = nil
	if addBg then
		bg = Bitmap(parent, SkinnableFile('/game/generic_brd/generic_brd_m.dds'))
		border:LayoutControlInside(bg)
		bg.Width:Set(function() return bg.Right() - bg.Left() end)
		bg.Height:Set(function() return bg.Bottom() - bg.Top() end)
	end

	return border, bg
end

function GetFactionIcon(factionIndex)
	return import('/lua/common/factions.lua').Factions[factionIndex + 1].Icon
end

-- make sure you lay out text box before you attempt to set text
function CreateTextBox(parent)
	local box = ItemList(parent)
	box:SetFont(bodyFont, 14)
	box:SetColors(bodyColor, "black",  highlightColor, "white")
	CreateVertScrollbarFor(box)
	return box
end

function SetTextBoxText(textBox, text)
	textBox:DeleteAllItems()
	local wrapped = import('/lua/maui/text.lua').WrapText(LOC(text), textBox.Width(), function(curText) return textBox:GetStringAdvance(curText) end)
	for i, line in wrapped do
		textBox:AddItem(line)
	end
end
function ClearStandardNavControl()
	if not CurrentControls or not CurrentControls.parent then
		return
	end
	if CurrentControls.parent.OldHandleEvent then
		CurrentControls.parent.HandleEvent= CurrentControls.parent.OldHandleEvent
		CurrentControls.parent.OldHandleEvent= nil
	else
		CurrentControls.parent.HandleEvent= nil
	end
	if CurrentControls.ScreenGroup then
		CurrentControls.ScreenGroup:Destroy()
		CurrentControls.ScreenGroup= nil
	end
	CurrentControls= {}
	CurrentControls.parent= nil
end

function CreateDialogBrackets(parent, leftOffset, topOffset, rightOffset, bottomOffset, altTextures)
	local ret = Group(parent)

	if altTextures then
		ret.topleft = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-ul_bmp.dds'))
		ret.topright = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-ur_bmp.dds'))
		ret.bottomleft = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-ll_bmp.dds'))
		ret.bottomright = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-lr_bmp.dds'))

		ret.topleftglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-glow-ul_bmp.dds'))
		ret.toprightglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-glow-ur_bmp.dds'))
		ret.bottomleftglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-glow-ll_bmp.dds'))
		ret.bottomrightglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets-small/bracket-glow-lr_bmp.dds'))
	else
		ret.topleft = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-ul_bmp.dds'))
		ret.topright = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-ur_bmp.dds'))
		ret.bottomleft = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-ll_bmp.dds'))
		ret.bottomright = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-lr_bmp.dds'))

		ret.topleftglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-glow-ul_bmp.dds'))
		ret.toprightglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-glow-ur_bmp.dds'))
		ret.bottomleftglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-glow-ll_bmp.dds'))
		ret.bottomrightglow = Bitmap(ret, UIFile('/scx_menu/panel-brackets/bracket-glow-lr_bmp.dds'))
	end

	ret.topleftglow.Depth:Set(function() return ret.topleft.Depth() - 1 end)
	ret.toprightglow.Depth:Set(function() return ret.topright.Depth() - 1 end)
	ret.bottomleftglow.Depth:Set(function() return ret.bottomleft.Depth() - 1 end)
	ret.bottomrightglow.Depth:Set(function() return ret.bottomright.Depth() - 1 end)

	LayoutHelpers.AtCenterIn(ret.topleftglow, ret.topleft)
	LayoutHelpers.AtCenterIn(ret.toprightglow, ret.topright)
	LayoutHelpers.AtCenterIn(ret.bottomleftglow, ret.bottomleft)
	LayoutHelpers.AtCenterIn(ret.bottomrightglow, ret.bottomright)

	ret.topleft.Left:Set(function() return parent.Left() - leftOffset end)
	ret.topleft.Top:Set(function() return parent.Top() - topOffset end)

	ret.topright.Right:Set(function() return parent.Right() + rightOffset end)
	ret.topright.Top:Set(function() return parent.Top() - topOffset end)

	ret.bottomleft.Left:Set(function() return parent.Left() - leftOffset end)
	ret.bottomleft.Bottom:Set(function() return parent.Bottom() + bottomOffset end)

	ret.bottomright.Right:Set(function() return parent.Right() + rightOffset end)
	ret.bottomright.Bottom:Set(function() return parent.Bottom() + bottomOffset end)

	ret:DisableHitTest(true)
	LayoutHelpers.FillParent(ret, parent)

	return ret
end
function SetDialogActive(active)
	if not CurrentControls or not CurrentControls.list then
		return
	end
	if active then
		for i,ctrl in CurrentControls.list do
			if ctrl.UI then
				ctrl.UI:SetAlpha(0, true)
			end
		end
	else
		for i,ctrl in CurrentControls.list do
			if ctrl.UI then
				ctrl.UI:SetAlpha(1, true)
			end
		end
	end
end

function GetStandardNavControl(key)
	if CurrentControls and CurrentControls.list then
		for i,ctrl in CurrentControls.list do
			if ctrl.key and ctrl.key == key then
				return ctrl
			end
		end
	end
	return nil
end

-- Setup any global buttons which do NOT require joystick focus to trigger (for forward, back mostly)
function SetupStandardNavControl(Controls)
-- Controls=
-- {
--      parent= the parent control where these button events are caught
--      setupBorderPanels = true/false
--      list= list of buttons
--      {
--          text=
--          {
--                parent= GUI.BotBar,
--                name= "<LOC _Back>",
--                font= Fonts.General.fontName,
--                size= Fonts.General.size,
--                left= 100,
--                layoutFile= layout file name,
--                controlName= control name (from layout file),
--          }
--          event= 'JoystickButtonPress' or 'JoystickButtonRelease' or nil
--          button= joystick button name
--          callback= function to call when this button is pressed
--      }
-- }

	local layout= UIGetFileForRes('/480/480_Button_Layouts/480_Button_Layouts_layout.lua')
	local layoutTable = import(layout()).layout

	if CurrentControls then
		ClearStandardNavControl()
	end

	CurrentControls= Controls
	if not CurrentControls.parent then
		return
	end

	CurrentControls.ScreenGroup= CreateScreenGroup(CurrentControls.parent, "Standard controls group")
	if CurrentControls.depth then
		CurrentControls.ScreenGroup.Depth:Set(CurrentControls.depth)
	else
		CurrentControls.ScreenGroup.Depth:Set(CurrentControls.parent.Depth() + 100)
	end

	if CurrentControls.setupBorderPanels then
		local OverrideTop= nil
		local OverrideBot= nil
		local OverrideLayout= nil
		if IsInGame() then
			local res
			local wideScreen
			res, wideScreen = GetScreenResolution()
			if res == '480' and wideScreen then
				OverrideTop= UIFile('/480/480W_Button_Layouts/top.dds')
				OverrideBot= UIFile('/480/480W_Button_Layouts/bottom.dds')
				OverrideLayout= SkinnableFile('/480/480W_Button_Layouts/480W_Button_Layouts_layout.lua')
			end
		end
		CurrentControls.panelTop = Bitmap(CurrentControls.ScreenGroup, OverrideTop or CurrentControls.topPanel or UIGetFileForRes('/480/480_Button_Layouts/top.dds'))
		LayoutHelpers.RelativeTo(CurrentControls.panelTop, CurrentControls.ScreenGroup, OverrideLayout or layout, CurrentControls.topPanelName or 'top', nil)
		LayoutHelpers.DimensionsRelativeTo(CurrentControls.panelTop, OverrideLayout or layout, CurrentControls.topPanelName or 'top')
		LayoutHelpers.DepthOverParent(CurrentControls.panelTop, CurrentControls.ScreenGroup)

		CurrentControls.panelBot = Bitmap(CurrentControls.ScreenGroup, OverrideBot or CurrentControls.botPanel or UIGetFileForRes('/480/480_Button_Layouts/bottom.dds'))
		LayoutHelpers.RelativeTo(CurrentControls.panelBot, CurrentControls.ScreenGroup, OverrideLayout or layout, CurrentControls.botPanelName or 'bottom', nil)
		LayoutHelpers.DimensionsRelativeTo(CurrentControls.panelBot, OverrideLayout or layout, CurrentControls.botPanelName or 'bottom')
		LayoutHelpers.DepthOverParent(CurrentControls.panelBot, CurrentControls.ScreenGroup)

		if OverrideLayout then
			LayoutHelpers.AtHorizontalCenterIn(CurrentControls.panelTop, CurrentControls.ScreenGroup)
			LayoutHelpers.AtHorizontalCenterIn(CurrentControls.panelBot, CurrentControls.ScreenGroup)
		end
	end

	for i,ctrl in CurrentControls.list do
		ctrl.UI= Group(CurrentControls.ScreenGroup)
		if ctrl.text then
			local ButtonFileName= nil
			for j,bmap in ButtonIcons do
				if bmap[1] == ctrl.button then
					ButtonFileName= bmap[2]
					break
				end
			end
			if not ctrl.text.layoutFile then
				ctrl.text.layoutFile= layout
			end
			ctrl.textWidget= CreateText(ctrl.UI, ctrl.text.name or "", ctrl.text.size or Fonts.StandardButtonText.size, ctrl.text.font or Fonts.StandardButtonText.fontName)
			ctrl.textWidget:SetColor(ctrl.text.color or fontColor)

			ctrl.buttonWidget= nil
			if ButtonFileName then
				ctrl.buttonWidget= Bitmap(ctrl.UI, ButtonFileName)
				if ctrl.text.layoutFile and ctrl.text.controlName then
					LayoutHelpers.LeftRelativeTo(ctrl.buttonWidget, ctrl.text.parent, ctrl.text.layoutFile, ctrl.text.controlName, nil, ctrl.text.left)
					LayoutHelpers.CenteredVerticallyRelativeTo(ctrl.buttonWidget, ctrl.text.parent, ctrl.text.layoutFile, ctrl.text.controlName, nil, ctrl.text.top)
				else
					LayoutHelpers.AtLeftIn(ctrl.buttonWidget, ctrl.text.parent or CurrentControls.parent, ctrl.text.left or 0)
					if ctrl.text.top then
						LayoutHelpers.AtTopIn(ctrl.buttonWidget, ctrl.text.parent or CurrentControls.parent, ctrl.text.top or 0)
					else
						LayoutHelpers.AtVerticalCenterIn(ctrl.buttonWidget, ctrl.text.parent or CurrentControls.parent)
					end
				end
				LayoutHelpers.DepthOverParent(ctrl.buttonWidget, ctrl.UI, 2)
				LayoutHelpers.RightOf(ctrl.textWidget, ctrl.buttonWidget, 10)
				LayoutHelpers.AtVerticalCenterIn(ctrl.textWidget, ctrl.buttonWidget, 1)
			else
				if ctrl.text.layoutFile and ctrl.text.controlName then
					LayoutHelpers.RelativeTo(ctrl.textWidget, ctrl.text.parent, ctrl.text.layoutFile, ctrl.text.controlName, nil, ctrl.text.top, ctrl.text.left)
				else
					LayoutHelpers.AtLeftIn(ctrl.textWidget, ctrl.text.parent or CurrentControls.parent, ctrl.text.left or 0)
					if ctrl.text.top then
						LayoutHelpers.AtTopIn(ctrl.textWidget, ctrl.text.parent or CurrentControls.parent, ctrl.text.top or 0)
					else
						LayoutHelpers.AtVerticalCenterIn(ctrl.textWidget, ctrl.text.parent or CurrentControls.parent, 1)
					end
				end
			end
			LayoutHelpers.DepthOverParent(ctrl.textWidget, ctrl.UI, 2)
		end
	end

	if CurrentControls.parent.HandleEvent then
		CurrentControls.parent.OldHandleEvent= CurrentControls.parent.HandleEvent
	end
	CurrentControls.parent.HandleEvent = function(self, event)
		local eventHandled = false

		if event.Type == 'JoystickAnalogMotion' then
			-- Handle Left Thumbstick control imitating DPadUp/DPadDown/DPadLeft/DPadRight button events
			local fakeEvent = HandleTriggerToButtonEmulation( event )
			if fakeEvent != {} then
				eventHandled = self:HandleEvent( fakeEvent )
			end
			return eventHandled
		end

		for i,ctrl in CurrentControls.list do
			if ((ctrl.callback) and (not ctrl.UI:IsHidden()) and
				(event.Type == (ctrl.event or 'JoystickButtonRelease')) and
				(event.JoystickButton == ctrl.button)) then

				local sound = Sound( { Cue = "UI_Menu_MouseDown", Bank = "Interface", } )
				if ctrl.button == 'B' then
					sound = Sound( { Cue = "UI_Back_MouseDown", Bank = "Interface", } )
				end
				PlaySound( sound )
				ctrl.callback()
				eventHandled= true;
			end
		end
		if CurrentControls.captureAllInput then
			eventHandled= true
		end
		if eventHandled then
			return eventHandled
		elseif CurrentControls.extraHandleEvent then
			CurrentControls.extraHandleEvent(CurrentControls.parent, event)
		elseif CurrentControls.parent.OldHandleEvent then
			return CurrentControls.parent.OldHandleEvent(CurrentControls.parent, event) -- Flakey, doesn't seem to work sometimes.
		end
		return false
	end
end

local cAxisZeroRange = 3000
local cAxisThreshold = 6000

LeftThumbstickEmulation = {
	bWaitForXAxisZero = false,
	bWaitForYAxisZero = false,
	lastXAxisEmulation = nil,
	lastYAxisEmulation = nil,
}

-- Handle Left Thumbstick control imitating DPadUp/DPadDown/DPadLeft/DPadRight button events
function HandleLeftThumbstickDPadEmulation( event, queryOnly )
	local isQuery = queryOnly or false
	local fakeEvent = {}

	if event.Type == 'JoystickAnalogMotion' then
		-- Left Thumbstick control imitating DPadUp/DPadDown/DPadLeft/DPadRight button events
		if event.JoystickAxis == 'LeftThumbstick' then

			-- Handle X-Axis -- DPadLeft/Right
			if LeftThumbstickEmulation.bWaitForXAxisZero then

				if event.JoystickX < cAxisZeroRange and event.JoystickX > -cAxisZeroRange then
					if LeftThumbstickEmulation.lastXAxisEmulation then
						fakeEvent.JoystickButton = LeftThumbstickEmulation.lastXAxisEmulation
						fakeEvent.Type = 'JoystickButtonRelease'
						fakeEvent.WasAnalogStick = true
						if not isQuery then
							LeftThumbstickEmulation.bWaitForXAxisZero = false
							LeftThumbstickEmulation.lastXAxisEmulation = nil
						end
						return fakeEvent
					end
				end

			elseif not LeftThumbstickEmulation.bWaitForXAxisZero then

				if event.JoystickX > cAxisThreshold then
					fakeEvent.Type = 'JoystickButtonPress'
					fakeEvent.JoystickButton = 'DPadRight'
					fakeEvent.WasAnalogStick = true
					if not isQuery then
						LeftThumbstickEmulation.lastXAxisEmulation = fakeEvent.JoystickButton
						LeftThumbstickEmulation.bWaitForXAxisZero = true
					end
					return fakeEvent
				elseif event.JoystickX < -cAxisThreshold then
					fakeEvent.Type = 'JoystickButtonPress'
					fakeEvent.JoystickButton = 'DPadLeft'
					fakeEvent.WasAnalogStick = true
					if not isQuery then
						LeftThumbstickEmulation.lastXAxisEmulation = fakeEvent.JoystickButton
						LeftThumbstickEmulation.bWaitForXAxisZero = true
					end
					return fakeEvent
				end
			end

			-- Handle Y-Axis -- DPadUp/Down
			if LeftThumbstickEmulation.bWaitForYAxisZero then

				if event.JoystickY < cAxisZeroRange and event.JoystickY > -cAxisZeroRange then
					if LeftThumbstickEmulation.lastYAxisEmulation then
						fakeEvent.JoystickButton = LeftThumbstickEmulation.lastYAxisEmulation
						fakeEvent.Type = 'JoystickButtonRelease'
						fakeEvent.WasAnalogStick = true
						if not isQuery then
							LeftThumbstickEmulation.bWaitForYAxisZero = false
							LeftThumbstickEmulation.lastYAxisEmulation = nil
						end
						return fakeEvent
					end
				end

			elseif not LeftThumbstickEmulation.bWaitForYAxisZero then

				if event.JoystickY > cAxisThreshold then
					fakeEvent.Type = 'JoystickButtonPress'
					fakeEvent.JoystickButton = 'DPadUp'
					fakeEvent.WasAnalogStick = true
					if not isQuery then
						LeftThumbstickEmulation.lastYAxisEmulation = fakeEvent.JoystickButton
						LeftThumbstickEmulation.bWaitForYAxisZero = true
					end
					return fakeEvent
				elseif event.JoystickY < -cAxisThreshold then
					fakeEvent.Type = 'JoystickButtonPress'
					fakeEvent.JoystickButton = 'DPadDown'
					fakeEvent.WasAnalogStick = true
					if not isQuery then
						LeftThumbstickEmulation.lastYAxisEmulation = fakeEvent.JoystickButton
						LeftThumbstickEmulation.bWaitForYAxisZero = true
					end
					return fakeEvent
				end
			end
		end
	end

	return fakeEvent

end



local cTriggerZeroRange = 50
local cTriggerThreshold = 200

TriggerEmulation = {
	bWaitForLeftZero = false,
	bWaitForRightZero = false,
	lastLeftEmulation = nil,
	lastRightEmulation = nil,
}

-- Handle Left Thumbstick control imitating DPadUp/DPadDown/DPadLeft/DPadRight button events
function HandleTriggerToButtonEmulation( event, queryOnly )
	local isQuery = queryOnly or false
	local fakeEvent = {}

	if event.Type == 'JoystickAnalogMotion' then
		-- Left Thumbstick control imitating DPadUp/DPadDown/DPadLeft/DPadRight button events
		if event.JoystickAxis == 'LeftTrigger' then

			-- Handle X-Axis -- DPadLeft/Right
			if TriggerEmulation.bWaitForLeftZero then

				if event.JoystickTrigger < cTriggerZeroRange then
					if TriggerEmulation.lastLeftEmulation then
						fakeEvent.JoystickButton = TriggerEmulation.lastLeftEmulation
						fakeEvent.Type = 'JoystickButtonRelease'
						fakeEvent.WasAnalogStick = true
						if not isQuery then
							TriggerEmulation.bWaitForLeftZero = false
							TriggerEmulation.lastLeftEmulation = nil
						end
						return fakeEvent
					end
				end

			elseif not TriggerEmulation.bWaitForLeftZero then

				if event.JoystickTrigger > cTriggerThreshold then
					fakeEvent.Type = 'JoystickButtonPress'
					fakeEvent.JoystickButton = 'LeftTrigger'
					fakeEvent.WasAnalogStick = true
					TriggerEmulation.lastLeftEmulation = fakeEvent.JoystickButton
					if not isQuery then
						TriggerEmulation.bWaitForLeftZero = true
					end
					return fakeEvent
				end
			end
		elseif event.JoystickAxis == 'RightTrigger' then
			-- Handle Y-Axis -- DPadUp/Down
			if TriggerEmulation.bWaitForRightZero then

				if event.JoystickTrigger < cTriggerZeroRange then
					if TriggerEmulation.lastRightEmulation then
						fakeEvent.JoystickButton = TriggerEmulation.lastRightEmulation
						fakeEvent.Type = 'JoystickButtonRelease'
						fakeEvent.WasAnalogStick = true
						if not isQuery then
							TriggerEmulation.bWaitForRightZero = false
							TriggerEmulation.lastRightEmulation = nil
						end
						return fakeEvent
					end
				end

			elseif not TriggerEmulation.bWaitForRightZero then

				if event.JoystickTrigger > cTriggerThreshold then
					fakeEvent.Type = 'JoystickButtonPress'
					fakeEvent.JoystickButton = 'RightTrigger'
					fakeEvent.WasAnalogStick = true
					TriggerEmulation.lastRightEmulation = fakeEvent.JoystickButton
					if not isQuery then
						TriggerEmulation.bWaitForRightZero = true
					end
					return fakeEvent
				end
			end
		end
	end

	return fakeEvent

end
function ResetInGameRefCounters()
	for i, fadeInfo in FadeTable do
		fadeInfo.RefCount= 0
	end
	CursorHiddenRefCount= 0
end

function controllerStateChange( plugedin )
  local function PauseIt()
	  local pause=true;
	  local time=0.0

	  while 1 do
		PauseSound("World",pause)
		PauseSound("Music", pause)
		PauseVoice("VO",pause)
		WaitSeconds(0.25)
		time = time + 0.25
		if( time>4.0 ) then
			break
		end
	  end

	  LOG("all sounds paused")
  end

  import('/lua/ui/dialogs/saveload.lua').SetControllerState(plugedin)

  if not plugedin then
	  if not import('/lua/ui/dialogs/exitdialog.lua').IsExitDialogOpen() and not SessionIsPaused() and
		 not import('/lua/ui/dialogs/exitdialog.lua').DoNotPopupPauseMenu then
		  import('/lua/ui/dialogs/exitdialog.lua').CreateDialog(false)

		  ForkThread(PauseIt);

	  end
  end
end
function SaveCurrentControl()
-- Use this instead of take joystick focus.  Pass in a different ctrlRecord variable for each 'window'
-- Add/Remove capture pushes the ctrl onto a stack, so we'll be able to tell which ctrl to give focus
-- to when closing a window and still be assured the ctrl still exists.
	local CurCtrl= GetJoystickFocus()
	if CurCtrl then
		local OldDestroy= CurCtrl.OnDestroy
		CurCtrl.OnDestroy= function(self)
-- Remove all occurances of this control from the saved control stack
			local CtrlRemoved= true
			while CtrlRemoved do
				CtrlRemoved= false
				for i,ctrl in pairs(CurrentControlStack) do
					if ctrl == self then
--                    LOG("a control was deleted")
						table.remove(CurrentControlStack, i)
						CtrlRemoved= true
						break;
					end
				end
			end
-- Call the old on destroy function
			if OldDestroy then
				OldDestroy(self)
			end
		end
		CurrentStackRefCount= CurrentStackRefCount + 1
		table.insert(CurrentControlStack, CurCtrl)
--        LOG("control inserted: " .. CurrentStackRefCount)
	else
		LOG("Warning, no control has focus!")
		CurrentStackRefCount= CurrentStackRefCount + 1
	end
end

function RestoreLastControl()
	local lastCtrl= table.getn(CurrentControlStack)
	if lastCtrl > 0 then
		CurrentControlStack[lastCtrl]:TakeJoystickFocus()
		if lastCtrl == CurrentStackRefCount then
			table.remove(CurrentControlStack)
		end
		CurrentStackRefCount= CurrentStackRefCount - 1
--        LOG("control removed, " .. CurrentStackRefCount .. " left.")
	else
		LOG("Warning:  RestoreLastControl called on an empty CurrentControlStack!!")
		CurrentStackRefCount= CurrentStackRefCount - 1
		if CurrentStackRefCount < 0 then
			CurrentStackRefCount= 0
		end
--        LOG(SCR_Traceback("Error stacktrace:"))
	end
end

function returnFocusToGame( ruthless )
  local GamesFocus= import('/lua/ui/game/worldview.lua').viewLeft
  local layer_wheelCons = import('/lua/ui/game/construction.lua')
  local layer_wheelOrd  = import('/lua/ui/game/orders.lua')
  local layer_wheelGrp  = import('/lua/ui/game/groups.lua')
  local layer_queue     = import('/lua/ui/game/queue.lua')

--- TODO: if 'Ruthless', close all other layers. go direct to game.  properly test this...
  if ruthless then
	  layer_wheelCons.EndUnitGridNavigation()
	  layer_wheelOrd.EndOrdersGridNavigation()
	  layer_wheelGrp.EndGroupsGridNavigation()
	  GamesFocus:TakeJoystickFocus();
	  return
  end

  if layer_wheelCons.IsWheelVisible() then
	  import('/lua/ui/game/templateWheel.lua').EndTemplateWheelNavigation()
	  import('/lua/ui/game/groups.lua').EndGroupsGridNavigation()
	  import('/lua/ui/game/orders.lua').EndOrdersGridNavigation()
	  import('/lua/ui/game/queue.lua').EndQueueGridNavigation()
	  if not GetTutorialDisableConstructionWheel() then
		  import('/lua/ui/game/construction.lua').BeginUnitGridNavigation()
	  end
  elseif layer_wheelOrd.IsWheelVisible() then
	  layer_wheelOrd.BeginOrdersGridNavigation()
  elseif layer_wheelGrp.IsWheelVisible() then
	  layer_wheelGrp.BeginGroupsGridNavigation()
  elseif layer_queue.IsVisible() then
	  layer_queue.BeginQueueGridNavigation();
  else
	  GamesFocus:TakeJoystickFocus();
  end

end
function displayShortSaveMsg()
--    LOG("calling displayShortSaveMsg()")
	local infoStr = "<LOC uisaveload_0098>Do not turn off your console or remove the storage device. Saving preferences..."
	local status = ShowSplashDialog(GetFrame(0), infoStr )
	  return status
end

local statusStrDialogSaving ="<LOC uisaveload_0098>Do not turn off your console or remove the storage device. Saving preferences..."
local statusStrDialogLoading="<LOC uisaveload_0097>Do not turn off your console or remove the storage device. Loading preferences..."
local statusStrDialogCorruptSaving="<LOC uisaveload_0100>Preference file corrupt. Re-writing file. Do not turn off Xbox 360."

local statusDialogSave=false
local statusDialogLoad=false
local ShowDoNotTurnOffDeviceDialogThread=false

function QuickDialogLocal(parent, dialogText, button1Text, button1Callback, button2Text, button2Callback, button3Text, button3Callback, destroyOnCallback, modalInfo)
	-- if there is a callback and destroy not specified, assume destroy
	if (destroyOnCallback == nil) and (button1Callback or button2Callback or button3Callback) then
		destroyOnCallback = true
	end

	local dialog = Group(parent, "quickDialogGroup")

	--SetDialogActive(true)
	--SaveCurrentControl()
	--HideCursor()
	dialog.OnDestroy= function(self)
		--SetDialogActive(false)
		--RestoreLastControl()
		--ShowCursor()
	end

	LayoutHelpers.AtCenterIn(dialog, parent)
	dialog.Depth:Set(GetFrame(parent:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)
	local background = Bitmap(dialog, SkinnableFile('/dialogs/dialog/panel_bmp_m.dds'))
	dialog._background = background
	dialog.Width:Set(background.Width)
	dialog.Height:Set(background.Height)
	LayoutHelpers.FillParent(background, dialog)

	local textLine = {}
	textLine[1] = CreateText(dialog, "", 18, titleFont)
	textLine[1].Top:Set(background.Top)
	LayoutHelpers.AtHorizontalCenterIn(textLine[1], dialog)

	local textBoxWidth = (dialog.Width() - 80)
	local tempTable = import('/lua/maui/text.lua').WrapText(LOC(dialogText), textBoxWidth,
	function(text)
		return textLine[1]:GetStringAdvance(text)
	end)

	local tempLines = table.getn(tempTable)

	local prevControl = false
	for i, v in tempTable do
		if i == 1 then
			textLine[1]:SetText(v)
			prevControl = textLine[1]
		else
			textLine[i] = CreateText(dialog, v, 18, titleFont)
			LayoutHelpers.Below(textLine[i], prevControl)
			LayoutHelpers.AtHorizontalCenterIn(textLine[i], dialog)
			prevControl = textLine[i]
		end
		LayoutHelpers.DepthOverParent(textLine[i], background)
	end

	background:SetTiled(true)
	background.Bottom:Set(textLine[tempLines].Bottom)

	local backgroundTop = Bitmap(dialog, SkinnableFile('/dialogs/dialog/panel_bmp_T.dds'))
	backgroundTop.Bottom:Set(background.Top)
	backgroundTop.Left:Set(background.Left)
	local backgroundBottom = Bitmap(dialog, SkinnableFile('/dialogs/dialog/panel_bmp_b.dds'))
	backgroundBottom.Top:Set(background.Bottom)
	backgroundBottom.Left:Set(background.Left)

	if not modalInfo or modalInfo.worldCover then
		CreateWorldCover(dialog)
	end

	local function MakeButton(text, callback)
		local button = CreateButtonStd( background
										, '/widgets/small'
										, text
										, 12
										, 0)
		if callback then
			button.OnClick = function(self)
				callback()
				if destroyOnCallback then
					dialog:Destroy()
				end
			end
		else
			button.OnClick = function(self)
				dialog:Destroy()
			end
		end
		LayoutHelpers.DepthOverParent(button, background)
		return button
	end

	dialog._button1 = false
	dialog._button2 = false
	dialog._button3 = false

	if button1Text then
		dialog._button1 = MakeButton(button1Text, button1Callback)
		LayoutHelpers.Below(dialog._button1, background, 22)
	end
	if button2Text then
		dialog._button2 = MakeButton(button2Text, button2Callback)
		LayoutHelpers.Below(dialog._button2, background, 22)
	end
	if button3Text then
		dialog._button3 = MakeButton(button3Text, button3Callback)
		LayoutHelpers.Below(dialog._button3, background, 22)
	end

	if dialog._button3 then
		-- center each button to one third of the dialog
		LayoutHelpers.AtHorizontalCenterIn(dialog._button2, dialog)
		LayoutHelpers.LeftOf(dialog._button1, dialog._button2)
		LayoutHelpers.ResetLeft(dialog._button1)
		LayoutHelpers.RightOf(dialog._button3, dialog._button2)
		backgroundTop:SetTexture(SkinnableFile('/dialogs/dialog_02/panel_bmp_T.dds'))
		backgroundBottom:SetTexture(SkinnableFile('/dialogs/dialog_02/panel_bmp_b.dds'))
		background:SetTexture(SkinnableFile('/dialogs/dialog_02/panel_bmp_m.dds'))
		-- Assign joystick navigation info
		dialog._button1:SetupJoystickNavigation(dialog._button3, dialog._button2, dialog._button3, dialog._button2)
		dialog._button2:SetupJoystickNavigation(dialog._button1, dialog._button3, dialog._button1, dialog._button3)
		dialog._button3:SetupJoystickNavigation(dialog._button2, dialog._button1, dialog._button2, dialog._button1)
		-- Assign default hilited button
		--dialog._button1:TakeJoystickFocus()
	elseif dialog._button2 then
		-- center each button to half the dialog
		dialog._button1.Left:Set(function()
			return dialog.Left() + (((dialog.Width() / 2) - dialog._button1.Width()) / 2)
		end)
		dialog._button2.Left:Set(function()
			local halfWidth = dialog.Width() / 2
			return dialog.Left() + halfWidth + ((halfWidth - dialog._button2.Width()) / 2)
		end)
		-- Assign joystick navigation info
		dialog._button1:SetupJoystickNavigation(dialog._button2, dialog._button2, dialog._button2, dialog._button2)
		dialog._button2:SetupJoystickNavigation(dialog._button1, dialog._button1, dialog._button1, dialog._button1)
		-- Assign default hilited button
		--dialog._button1:TakeJoystickFocus()
	elseif dialog._button1 then
		LayoutHelpers.AtHorizontalCenterIn(dialog._button1, dialog)
		-- Assign default hilited button
		--dialog._button1:TakeJoystickFocus()
	else
		backgroundBottom:SetTexture(UIFile('/dialogs/dialog/panel_bmp_alt_b.dds'))
		-- No default hilited button - dialog sees joystick presses instead.
		--dialog:TakeJoystickFocus()
	end

	dialog.HandleEvent = function(self, event)
		return true
	end

	if modalInfo then
		local function OnEnterFunc()
			if modalInfo.enterButton then
				if modalInfo.enterButton == 1 then
					if dialog._button1 then
						dialog._button1.OnClick(dialog._button1)
					end
				elseif modalInfo.enterButton == 2 then
					if dialog._button2 then
						dialog._button2.OnClick(dialog._button2)
					end
				elseif modalInfo.enterButton == 3 then
					if dialog._button3 then
						dialog._button3.OnClick(dialog._button3)
					end
				end
			end
		end

		local function OnEscFunc()
			if modalInfo.escapeButton then
				if modalInfo.escapeButton == 1 then
					if dialog._button1 then
						dialog._button1.OnClick(dialog._button1)
					end
				elseif modalInfo.escapeButton == 2 then
					if dialog._button2 then
						dialog._button2.OnClick(dialog._button2)
					end
				elseif modalInfo.escapeButton == 3 then
					if dialog._button3 then
						dialog._button3.OnClick(dialog._button3)
					end
				end
			end
		end

--        MakeInputModal(dialog, OnEnterFunc, OnEscFunc)
	end

	return dialog
end

local DepthSize = 110000
local NeedStorageDeviceMsg2Thread=false
function SetDialogDepth(depth)
	if( depth>DepthSize ) then
		DepthSize=depth
	end
end

function NeedStorageDeviceMsg2(NeedStorageDevice, info)

	local Ready=false
	local strDialog=info

--    local MainMenu = import('/lua/ui/menus/main.lua').CreateUI
--    MainMenu('hideAll')

	if info==nil then
		strDialog = "<LOC SIGNIN_WARNING_004>To load or save your game preferences you must have a storage device and be signed in with a gamer profile."
	end

	if( WorldIsLoading() ) then
		NeedStorageDeviceMsg2Thread=false
		return
	end

	--LOG(" IN NeedStorageDeviceMsg2 ")

	local quick=QuickDialog360(GetFrame(0), strDialog
								  , {
										button = 'A',
										text = "<LOC _OK>",
										callback = function() Ready=true end,
									}
								  , nil
								  , nil
								  , false
								  , {escapeButton = 2, enterButton = 1, worldCover = false} )
	if( not quick ) then
		NeedStorageDeviceMsg2Thread=false
		return
	end

	quick.Depth:Set( DepthSize )

	--if xbox panel is up then hide the dialog (user could be selecting the storage device)

	while not Ready do
		if( GetStorageDevice()!=0 ) then
			break
		end
		if XGetPanelState()==1 then
			quick:Hide()
		else
			quick:Show()
		end
		WaitSeconds(0.25)
	end
	quick:Destroy()
	if( NeedStorageDevice and XGetSignedInUser()~=-1 ) then
		AskForStorageDevice()
	end

--    MainMenu('showAll')
	NeedStorageDeviceMsg2Thread=false
end

local AskForStorageDeviceThread=false
function AskForStorageDevice()
	-- determine if a storage device is available
	--
	local StorageDevice = GetStorageDevice()
	if( StorageDevice==0 ) then
		XChooseStorageDevice()
		while( GetStorageDevice()==0 ) do
			WaitSeconds(0.5)
			-- Once panel is hidden, user has made a choice of storage device, or not
			--
			if( XGetPanelState()==1 ) then
				break
			end
		end

		while XGetPanelState()!=0 do
			WaitSeconds(0.5)
		end

		if( GetStorageDevice()>0 ) then
			if( HaveRoomToSavePreferences() ) then
				--LOG("in SavePreferences()")
				if( ShowDoNotTurnOffDeviceDialogThread==false ) then
					ShowDoNotTurnOffDeviceDialogThread=ForkThread(ShowDoNotTurnOffDeviceDialog, false)
				end
				--InternalSavePreferences()
				--LOG("OUT SavePreferences()")
			else
				if( PrompUserToChangeDeviceThread==nil or PrompUserToChangeDeviceThread==false ) then
					PrompUserToChangeDeviceThread = ForkThread(PrompUserToChangeDevice)
				end
			end
		else
			NeedStorageDeviceMsg2(false)
		end
	end
	AskForStorageDeviceThread=false
end

local inShowDoNotTurnOffDeviceDialog=false
function ShowDoNotTurnOffDeviceDialog(isLoading)

	if( inShowDoNotTurnOffDeviceDialog ) then
		return
	end

	inShowDoNotTurnOffDeviceDialog=true;

	if( not WorldIsLoading() ) then

		local statusDialog
		if( isLoading ) then
			statusDialog = QuickDialogLocal(GetFrame(0), statusStrDialogLoading,
											nil, nil, nil, nil,
											nil, nil, nil, {worldCover = false, enterButton = 1, escapeButton = 1})
		else
			local FileInfo = XGetFileInfo( XGetPrefsFileName() )
			if( FileInfo ) then
--                if (XOpenReadContent( XGetPrefsFileName() )==false )then
--                    statusDialog = QuickDialogLocal(GetFrame(0), statusStrDialogCorruptSaving,
--                                                    nil, nil, nil, nil,
--                                                    nil, nil, nil, {worldCover = false, enterButton = 1, escapeButton = 1})
--                else
				statusDialog = QuickDialogLocal(GetFrame(0), statusStrDialogSaving,
												nil, nil, nil, nil,
												nil, nil, nil, {worldCover = false, enterButton = 1, escapeButton = 1})
--                end
--                XCloseReadContent()
			else
				statusDialog = QuickDialogLocal(GetFrame(0), statusStrDialogSaving,
												nil, nil, nil, nil,
												nil, nil, nil, {worldCover = false, enterButton = 1, escapeButton = 1})
			end
		end

		--Wait while the storage device unavailable dialog is showing
		--
		while( NeedStorageDeviceMsg2Thread ) do
			WaitSeconds(0.25)
		end

		if( statusDialog ) then
			local parent = GetFrame(0)
			statusDialog.Depth:Set( DepthSize )

			--PV cheap hack to make sure the Saving/Loading prefs dialog always draws on top of the pause menu
			--
			DepthSize = DepthSize + 50
			statusDialog:Show()

			--LOG("in ShowDoNotTurnOffDeviceDialog()")
			WaitSeconds(0.5)

			StartLoadingAnim(LoadingAnimEffects.SPINNING_EFFECT, isLoading)

			if( isLoading ) then
				LoadPreferences()
			else
				InternalSavePreferences()
			end

			WaitSeconds(2.50)
			StopLoadingAnim()

			statusDialog:Destroy()
			FlushEvents()
		end

	end


	ShowDoNotTurnOffDeviceDialogThread=false;
	inShowDoNotTurnOffDeviceDialog=false;
end

function ChangeDeviceNoRoom()
	XChooseStorageDevice(1)
	while( GetStorageDevice()==0 ) do
		WaitSeconds(0.5)
		-- Once panel is hidden, user has made a choice of storage device
		--
		if( XGetPanelState()==1 ) then
			break
		end
	end

	while XGetPanelState()!=0 do
		WaitSeconds(0.5)
	end

	-- User has not choosen a storage device (stupid git)
	--
	if( GetStorageDevice()==0 ) then
		NeedStorageDeviceMsg2(false)
	end
end

local DeviceChangeCount=-1
PrompUserToChangeDeviceThread=false
function PrompUserToChangeDevice()

	local infoStr = "<LOC uisaveload_0099>Insufficent room on storage device to save your preferences!"

	while(1) do
		local Ready=false
		local DoChangeDevice=false
		local count = XGetStorageDeviceCount()

		local quick=QuickDialog360(GetFrame(0), infoStr
									  , {
											button = 'Y',
											text ="<LOC _Device>Change Device",
											callback = function()
														Ready=true
														DoChangeDevice=true
													   end,
										}
									  , {
											button = 'A',
											text = "<LOC _OK>",
											callback = function()
														Ready=true
													   end,
										}
									  , nil
									  , nil
									  , true
									  , {escapeButton = 2, enterButton = 1, worldCover = false} )

		while not Ready do
			WaitSeconds(0.5)
		end

		quick:Destroy()

		if( DoChangeDevice ) then
			ChangeDeviceNoRoom()
			if( GetStorageDevice()==0 ) then
				break
			end
		end

		if( HaveRoomToSavePreferences() ) then
			if( ShowDoNotTurnOffDeviceDialogThread==false ) then
				ShowDoNotTurnOffDeviceDialogThread=ForkThread(ShowDoNotTurnOffDeviceDialog, false)
			end
			--InternalSavePreferences()
			break;
		else
			if( not DoChangeDevice ) then
				break;
			end
		end

	end --while(1) do
	PrompUserToChangeDeviceThread=false
end --function PrompUserToChangeDevice()...

function StartDoingPrefSaves(state)
	SetFrontEndData("PrefSaveEnabled", state)
	--LOG("PrefSaveEnabled="..repr(state))
end

function SetWarnedOnce(state)
	SetFrontEndData("WarnedOnce", state)
end

function MonitorSignIn()
	if( XGetSignedInUser()!=-1 ) then

	end
end

function SavePreferences()

	--LOG("before SavePreferences()")
	local PrefSaveEnabled = GetFrontEndData("PrefSaveEnabled")
	if( PrefSaveEnabled==nil or PrefSaveEnabled==false ) then
		--LOG(" SavePreferences() false or nil")
		return
	end

	if( IsDemoBuild() ) then
		return
	end

	local StorageDevice = GetStorageDevice()
	local count = XGetStorageDeviceCount()

	--LOG("in SavePreferences()..Count="..repr(count))

	if( NeedStorageDeviceMsg2Thread ) then
		KillThread(NeedStorageDeviceMsg2Thread)
		NeedStorageDeviceMsg2Thread=false
	end

	if( StorageDevice>0 ) then
		--LOG("in SavePreferences(): StorageDevice>0 ")
		if( HaveRoomToSavePreferences() ) then
			--LOG("in SavePreferences(): HaveRoomToSavePreferences()==true ")
			SetFrontEndData("WarnedOnce", false)
			--LOG("in SavePreferences()")

			if( ShowDoNotTurnOffDeviceDialogThread==false ) then
				ShowDoNotTurnOffDeviceDialogThread=ForkThread(ShowDoNotTurnOffDeviceDialog, false)
			end
			--InternalSavePreferences()
			--LOG("OUT SavePreferences()")
		else
			local WarnedOnce = GetFrontEndData("WarnedOnce")
			--LOG("in SavePreferences(): HaveRoomToSavePreferences()==false ")

			if( WarnedOnce==nil or WarnedOnce==false ) then
				--SetFrontEndData("WarnedOnce", true)
				DeviceChangeCount=count
			end
			if( ( WarnedOnce==nil or WarnedOnce==false or DeviceChangeCount!=count ) ) then
				if( PrompUserToChangeDeviceThread==nil or PrompUserToChangeDeviceThread==false ) then
					--LOG("in SavePreferences(): ( WarnedOnce==nil or WarnedOnce==false or DeviceChangeCount!=count )==true ")
					PrompUserToChangeDeviceThread = ForkThread(PrompUserToChangeDevice)
				end
			end
		end
	else
		local WarnedOnce = GetFrontEndData("WarnedOnce")
		--LOG("WarnedOnce.."..repr(WarnedOnce))
		LOG("in SavePreferences(): StorageDevice>0 (false) ")
		if( WarnedOnce==nil or WarnedOnce==false ) then
			--SetFrontEndData("WarnedOnce", true)
			--LOG("in SavePreferences(): ( WarnedOnce==nil or WarnedOnce==false )==true ")
			NeedStorageDeviceMsg2Thread=ForkThread(NeedStorageDeviceMsg2, true, "<LOC SIGNIN_WARNING_005>Storage Device unavailable.")
			DeviceChangeCount=count
		else
			--LOG("in SavePreferences(): ( WarnedOnce==nil or WarnedOnce==false )==false ")
			if( count!=DeviceChangeCount ) then
				DeviceChangeCount=count
				--LOG("in SavePreferences(): ( count!=DeviceChangeCount )==true")
				NeedStorageDeviceMsg2Thread=ForkThread(NeedStorageDeviceMsg2, true, "<LOC SIGNIN_WARNING_005>Storage Device unavailable.")
				--if( AskForStorageDeviceThread==false ) then
				--    AskForStorageDeviceThread=ForkThread(AskForStorageDevice)
				--end
			end
		end
	end
end
