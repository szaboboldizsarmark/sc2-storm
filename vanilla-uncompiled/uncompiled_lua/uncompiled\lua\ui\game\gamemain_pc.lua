local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local WldUIProvider = import('/lua/ui/game/wlduiprovider.lua').WldUIProvider
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Prefs = import('/lua/user/prefs.lua')
local Group = import('/lua/maui/group.lua').Group
local Movie = import('/lua/maui/movie.lua').Movie

local isReplay = false
local gameParent = false
local controlClusterGroup = false
local statusClusterGroup = false
local mapGroup = false
local mfdControl = false
local ordersControl = false
local provider = false
local waitingDialog = false

-- query this to see if the UI is hidden
gameUIHidden = false

-- check this flag to see if it's valid to show the exit dialog
supressExitDialog = false

function GetStatusCluster()
    return statusClusterGroup
end

function GetControlCluster()
    return controlClusterGroup
end

function SetLayout(layout, isReplay)
    import('/lua/ui/game/unitviewDetail.lua').Hide()
    import('/lua/ui/game/borders.lua').SetLayout(layout)
    import('/lua/ui/game/unitviewDetail.lua').SetLayout(layout, mapGroup)
    import('/lua/ui/game/missiontext.lua').SetLayout()
    import('/lua/ui/game/chat.lua').SetLayout()
end

function OnFirstUpdate()
    EnableWorldSounds()
    local avatars = GetArmyAvatars()
    if avatars and avatars[1]:IsInCategory("COMMAND") then
        local armiesInfo = GetArmiesTable()
        local focusArmy = armiesInfo.focusArmy
		if not import('/lua/ui/campaign/campaignmanager.lua').campaignMode then
			local playerName = armiesInfo.armiesTable[focusArmy].nickname
			avatars[1]:SetCustomName(playerName)
		end
    end
    import('/lua/user/UserMusic.lua').StartPeaceMusic()


    FlushEvents()
	import('/lua/ui/game/worldview.lua').UnlockInput()
end

function CreateUI(isReplay)
    --ConExecute("Cam_Free true")
    local sessionInfo = SessionGetScenarioInfo()
    if sessionInfo["UIDeactivate"] and not UIGameIsLoadingSave() then
        DeactivateUI(true)
    end
    local prefetchTable = { models = {}, anims = {}, d3d_textures = {}, batch_textures = {} }

    -- set up our layout change function
    UIUtil.changeLayoutFunction = SetLayout

    -- update loc table with player's name
    local focusarmy = GetFocusArmy()
    if focusarmy >= 1 then
        LocGlobals.PlayerName = GetArmiesTable().armiesTable[focusarmy].nickname
    end

    GameCommon.InitializeUnitIconBitmaps(prefetchTable.batch_textures)

    gameParent = UIUtil.CreateScreenGroup(GetFrame(0), "GameMain ScreenGroup")

    controlClusterGroup, statusClusterGroup, mapGroup, windowGroup = import('/lua/ui/game/borders.lua').SetupBorderControl(gameParent)

    controlClusterGroup:SetNeedsFrameUpdate(true)
    controlClusterGroup.OnFrame = function(self, deltaTime)
        controlClusterGroup:SetNeedsFrameUpdate(false)
        OnFirstUpdate()
    end

	LOG( "SessionResume: CreateUI Lock Input Called" )
    import('/lua/ui/game/worldview.lua').CreateMainWorldView(gameParent, mapGroup)
    import('/lua/ui/game/worldview.lua').LockInput()

    import('/lua/ui/game/unitviewDetail.lua').SetupUnitViewLayout(mapGroup, mapGroup)

	import('/lua/ui/game/transmissionlog.lua').CreateTransmissionLog()
    import('/lua/ui/game/timer.lua').CreateTimerDialog(mapGroup)
    import('/lua/ui/game/consoleecho.lua').CreateConsoleEcho(mapGroup)

	import('/lua/ui/game/chat.lua').SetupChatLayout(windowGroup)
	import('/lua/ui/game/minimap.lua').CreateMinimap(windowGroup)

    if GetNumRootFrames() > 1 then
        import('/lua/ui/game/multihead.lua').CreateSecondView()
    end

    -- Ensure the main view has joystick focus, at the beginning.
    import('/lua/ui/game/worldview.lua').viewLeft:TakeJoystickFocus();
    Prefetcher:Update(prefetchTable)
end

local function LoadDialog(parent)

    local movieFile = '/movies/cybran_load.sfd'

    local color = 'FFbadbdb'

	-- Changed to account for Skirmish writing out the 'LoadingFaction' preference in the root of profile instead of in profile.profiles
	-- The campaign menu is doing it in profile.profiles; however, it's not writing out a valid faction for each campaign.
	-- When/if it does, either change Skirmish or write logic to pick the proper one by checking whether loading skirmish or campaign. SB 1.7.10
    local loadingPref = Prefs.GetPreference('profile')['LoadingFaction']
    local factions = import('/lua/common/factions.lua').Factions

    if factions[loadingPref] and factions[loadingPref].loadingMovie then
        movieFile = factions[loadingPref].loadingMovie
        color = factions[loadingPref].loadingColor
    end

	UIShowLoadingScreen( movieFile )

    ConExecute('UI_RenderUnitBars true')
    ConExecute('UI_NisRenderIcons true')
--  ConExecute('ren_SelectBoxes true')
    HideGameUI('off')

    return true
end

function CreateWldUIProvider()

    provider = WldUIProvider()

    local loadingDialog = false
    local frame1Logo = false

    local lastTime = 0

    provider.StartLoadingDialog = function(self)
		GetCursor():Hide()
		supressExitDialog = true
        if not loadingDialog then
            self.loadingDialog = LoadDialog(GetFrame(0))
            if GetNumRootFrames() > 1 then
                local frame1 = GetFrame(1)
                local frame1Logo = Bitmap(frame1, UIUtil.UIFile('/marketing/splash.dds'))
                LayoutHelpers.FillParent(frame1Logo, frame1)
            end
        end
    end

    provider.UpdateLoadingDialog = function(self, elapsedTime)
        if loadingDialog then
        end
    end

    provider.StopLoadingDialog = function(self)
		GetCursor():Show()
        FlushEvents()
    end

    provider.StartWaitingDialog = function(self)
		-- Launch waiting dialog
		UIShowDialog("<LOC gamemain_0001>Waiting For Other Players...",  "<LOC label_quit_0001>QUIT TO MENU", "ExitGame", "", "", "", "", false );
    end

    provider.UpdateWaitingDialog = function(self, elapsedTime)
        -- currently no function, but could animate waiting dialog
    end

    provider.StopWaitingDialog = function(self)
		UIHideDialog();
        FlushEvents()
    end

    provider.CreateGameInterface = function(self, inIsReplay)
        isReplay = inIsReplay
        if frame1Logo then
            frame1Logo:Destroy()
            frame1Logo = false
        end
        CreateUI(isReplay)
        if not import('/lua/ui/campaign/campaignmanager.lua').campaignMode then
            HideGameUI('on')
        elseif not UIGameIsLoadingSave() then
			UILoadingAllowPlayerReady(false)
        end
		supressExitDialog = false
		import('/lua/ui/game/gamemain.lua').InitOverlayFilters();
    end

	provider.CreateNewUI = function( self )
		UIGameInit()
		UILoadingScreenPushToFront()
	end

	provider.PostNewUIInit = function( self )
        UIGamePostInit()
		UILoadingScreenLoadComplete()
	    FlushEvents()
    end

    provider.DestroyGameInterface = function(self)
        if gameParent then gameParent:Destroy() end
        import('rallypoint.lua').ClearAllRallyPoints()
        import('/lua/user/UserMusic.lua').StopMusicEvent()
        UIGameShutdown();
    end

    provider.GetPrefetchTextures = function(self)
        return import('/lua/ui/game/prefetchtextures.lua').prefetchPC
    end

end

function GetGameParent()
	return gameParent
end

-- This function is called whenever the set of currently selected units changes
-- See /lua/unit.lua for more information on the lua unit object
--      oldSelection: What the selection was before
--      newSelection: What the selection is now
--      added: Which units were added to the old selection
--      removed: Which units where removed from the old selection
function OnSelectionChanged(oldSelection, newSelection, added, removed)

    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(newSelection)
    local isOldSelection = table.equal(oldSelection, newSelection)
    UIGameSelectionChanged(newSelection)
    if not isOldSelection then
        import('/lua/ui/game/selection.lua').PlaySelectionSound(added)
        import('/lua/ui/game/rallypoint.lua').OnSelectionChanged(newSelection)
    end
end

function OnQueueChanged(newQueue)
    if not gameUIHidden then
        UIConstructionOnQueueChanged()
    end
end

function HideGameUI(state)
    if gameParent then
        if gameUIHidden or state == 'off' then
            gameUIHidden = false
            controlClusterGroup:Show()
            statusClusterGroup:Show()
            import('/lua/ui/game/worldview.lua').Contract()
            import('/lua/ui/game/borders.lua').HideBorder(false)
            --import('/lua/ui/game/unitview.lua').Expand()

            --import('/lua/ui/game/objectives2.lua').Expand()
            import('/lua/ui/game/unitviewDetail.lua').Expand()
            --import('/lua/ui/game/controlgroups.lua').Expand()
            --import('/lua/ui/game/tabs.lua').Contract()
            import('/lua/ui/game/announcement.lua').Expand()
        else
            gameUIHidden = true
            controlClusterGroup:Hide()
            statusClusterGroup:Hide()
            import('/lua/ui/game/worldview.lua').Expand()
            import('/lua/ui/game/borders.lua').HideBorder(true)
            --import('/lua/ui/game/unitview.lua').Contract()
            import('/lua/ui/game/unitviewDetail.lua').Contract()

            --import('/lua/ui/game/objectives2.lua').Contract()
            --import('/lua/ui/game/controlgroups.lua').Contract()
            --import('/lua/ui/game/tabs.lua').Contract()
            import('/lua/ui/game/announcement.lua').Contract()
        end
    end
end