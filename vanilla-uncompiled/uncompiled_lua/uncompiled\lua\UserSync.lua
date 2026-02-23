-- The global sync table is copied from the sim layer every time the main and sim threads are
-- synchronized on the sim beat (which is like a tick but happens even when the game is paused)
Sync = {}

-- The PreviousSync table holds just what you'd expect it to, the sync table from the previous
-- beat.
PreviousSync = {}

-- Unit specific data that's been sync'd. Data changes are accumulated by merging
-- the Sync.UnitData table into this table each sync (if there's new data)
UnitData = {}

-- Here's an opportunity for user side script to examine the Sync table for the new tick
function OnSync()

    --Play Sounds
    if Sync.Sounds then
		for _, v in Sync.Sounds do
			PlaySound(v)
		end
	end
	
    --Play Voices
    if Sync.Voice and not import('/lua/ui/game/missiontext.lua').IsHeadPlaying() then
        for _, v in Sync.Voice do
            PlayVoice(v, true)
        end
    end	

    if Sync.PlayMusic then
    	local str = Sync.PlayMusic
    	if str then
	    	LOG('USER SYNC: SetMusicEvent: [', str, ']')
	    	import('/lua/user/UserMusic.lua').SetMusicEvent( str )
		end
    end
	
	if Sync.ShowUIDialog != nil then
		UIShowDialog( Sync.ShowUIDialog[1], Sync.ShowUIDialog[2], 
					  Sync.ShowUIDialog[3], Sync.ShowUIDialog[4], 
					  Sync.ShowUIDialog[5], Sync.ShowUIDialog[6],
					  Sync.ShowUIDialog[7], Sync.ShowUIDialog[8] ) 
	end
	
	if Sync.LoadAllowPlayerReady then
		UILoadingAllowPlayerReady(true)
	elseif Sync.LoadDisallowPlayerReady then
		UILoadingAllowPlayerReady(false)
	end    

    if Sync.UserConRequests then
        for num, execRequest in Sync.UserConRequests do
            ConExecute(execRequest)
        end
    end

    if not table.empty(Sync.UnitData) then
        UnitData = table.merged(UnitData,Sync.UnitData)
    end

    for id,v in Sync.ReleaseIds do
        UnitData[id] = nil
    end

	if Sync.CameraRequests then
		import('/lua/user/UserCamera.lua').ProcessCameraRequests()
	end

    if Sync.FocusArmyChanged then
        import('/lua/ui/game/avatars.lua').FocusArmyChanged()
        import('/lua/ui/game/multifunction.lua').FocusArmyChanged()
    end

    if Sync.CampaignMode then
        import('/lua/ui/campaign/campaignmanager.lua').campaignMode = Sync.CampaignMode
    end

    if Sync.ChangeTerrainRNMSet then
		ChangeTerrainRNMSet( Sync.ChangeTerrainRNMSet[1], Sync.ChangeTerrainRNMSet[2] )
	end

    if Sync.PreloadMFDMovie then
		PreloadPIP(Sync.PreloadMFDMovie)
    end

    if Sync.PlayMFDMovie then
        import('/lua/ui/game/missiontext.lua').PlayMFDMovie(Sync.PlayMFDMovie)
    end

	if Sync.UserUnitUpgrades then
        import('/lua/user/UserUpgrade.lua').SetUpgradeTable(Sync.UserUnitUpgrades)
    end

    if Sync.ObjectivesTable and next(Sync.ObjectivesTable) then
		SetObjectives(Sync.ObjectivesTable)
    end

    if Sync.ObjectivesUpdateTable and next(Sync.ObjectivesUpdateTable) then
		SetObjectivesUpdate(Sync.ObjectivesUpdateTable)
    end

    if Sync.ObjectiveTimer then
        if Sync.ObjectiveTimer != false then
            import('/lua/ui/game/timer.lua').SetTimer(Sync.ObjectiveTimer)
        else
            import('/lua/ui/game/timer.lua').ResetTimer()
        end
    end

    if Sync.NewTech then
        import('/lua/ui/game/construction.lua').NewTech(Sync.NewTech)
    end

    if Sync.AddTransmissions then
        import('/lua/ui/game/transmissionlog.lua').OnPostLoad(Sync.AddTransmissions)
    end

    if Sync.NISVideo then
        import('/lua/ui/game/missiontext.lua').PlayNIS(Sync.NISVideo)
    end

    if Sync.EndGameMovie then
        import('/lua/ui/game/missiontext.lua').PlayEndGameMovie(Sync.EndGameMovie)
    end

    if Sync.MPTaunt then
        local msg = {}
        msg.tauntid = Sync.MPTaunt[1]
        msg.taunthead = Sync.MPTaunt[2]
        SessionSendChatMessage(msg)
    end

    if Sync.Ping then
        import('/lua/ui/game/ping.lua').DisplayPing(Sync.Ping)
    end

    if Sync.MaxPingMarkers then
        import('/lua/ui/game/ping.lua').MaxMarkers = Sync.MaxPingMarkers
    end

    if Sync.Score then
		for index, scoreData in Sync.Score do
			UpdateUIScore(index, scoreData.score)
		end
    end

	if Sync.GameResult then
		for _,gameResult in Sync.GameResult do
			local armyIndex, result = unpack(gameResult)        
			import('/lua/ui/game/gameresult.lua').DoGameResult(armyIndex, result)
		end
	end

    if Sync.PausedBy then
        if not PreviousSync.PausedBy then
            import('/lua/ui/game/gamemain.lua').OnPause(Sync.PausedBy, Sync.TimeoutsRemaining)
        end
    else
        if PreviousSync.PausedBy then
			LOG( "PausedBy Resume "..PreviousSync.PausedBy )
            import('/lua/ui/game/gamemain.lua').OnResume()
        end
    end

    if Sync.Paused != PreviousSync.Paused then
        import("/lua/ui/game/gamemain.lua").OnPause(Sync.Paused);
    end

    if Sync.PlayerQueries then
        import('/lua/user/UserPlayerQuery.lua').ProcessQueries(Sync.PlayerQueries)
    end

    if Sync.QueryResults then
        import('/lua/user/UserPlayerQuery.lua').ProcessQueryResults(Sync.QueryResults)
    end

    if Sync.OperationComplete then
        import('/lua/ui/campaign/campaignmanager.lua').OperationVictory(Sync.OperationComplete)
    end

    if Sync.Cheaters then
        -- Ted, this is where you would hook in better cheater reporting.
        local names = ''
        local isare = LOC('<LOC cheating_fragment_0000>is')
        local srcs = SessionGetCommandSourceNames()
        for k,v in ipairs(Sync.Cheaters) do
            if names != '' then
                names = names .. ', '
                isare = LOC('<LOC cheating_fragment_0001>are')
            end
            names = names .. (srcs[v] or '???')
        end
        local msg = names .. ' ' .. isare
        if Sync.Cheaters.CheatsEnabled then
            msg = msg .. LOC('<LOC cheating_fragment_0002> cheating!')
        else
            msg = msg .. LOC('<LOC cheating_fragment_0003> trying to cheat!')
        end
        print(msg)
    end

    if Sync.DiplomacyAction then
        import('/lua/ui/game/diplomacy.lua').ActionHandler(Sync.DiplomacyAction)
    end

    if Sync.DiplomacyAnnouncement then
        import('/lua/ui/game/diplomacy.lua').AnnouncementHandler(Sync.DiplomacyAnnouncement)
    end

    if Sync.LockInput then
		LOG( 'Sync.LockInput' )
        import('/lua/ui/game/worldview.lua').LockInput()
    end

    if Sync.UnlockInput then
        import('/lua/ui/game/worldview.lua').UnlockInput()
    end
    
    if Sync.PlayMovies then
		LOG( "*** UserSync.PlayMovies" )
		PlayMovies( Sync.PlayMovies, true )
	end

    if Sync.NISMode then
        import('/lua/ui/game/gamemain.lua').NISMode(Sync.NISMode)
    end

	if Sync.NISFadeOut then
		import('/lua/ui/game/gamemain.lua').FadeToBlack(Sync.NISFadeOut)
	end

	if Sync.NISFadeIn then
		import('/lua/ui/game/gamemain.lua').FadeFromBlack(Sync.NISFadeIn)
	end

	if Sync.NISSwipeDown then
		import('/lua/ui/game/gamemain.lua').SwipeDownToBlack(Sync.NISSwipeDown)
	end

	if Sync.NISSwipeUp then
		import('/lua/ui/game/gamemain.lua').SwipeUpFromBlack(Sync.NISSwipeUp)
	end

	if Sync.UICustomScene then
		UILoadCustomScene( Sync.UICustomScene )
	end

    if Sync.RequestPlayerFaction then
        import('/lua/ui/game/factionselect.lua').RequestPlayerFaction()
    end

    if Sync.PrintText then
        for _, textData in Sync.PrintText do
            local data = textData
            if type(Sync.PrintText) == 'string' then
                data = {text = Sync.PrintText, size = 14, color = 'ffffffff', duration = 5, location = 'center'}
            end
            import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
        end
    end

    if Sync.FloatingEntityText then
        for _, textData in Sync.FloatingEntityText do
            import('/lua/ui/game/unittext.lua').FloatingEntityText(textData)
        end
    end

    if Sync.StartCountdown then
        for _, textData in Sync.StartCountdown do
            import('/lua/ui/game/unittext.lua').StartCountdown(textData)
        end
    end

    if Sync.CancelCountdown then
        for _, textData in Sync.CancelCountdown do
            import('/lua/ui/game/unittext.lua').CancelCountdown(textData)
        end
    end

    if Sync.AddPingGroups then
        WARN('WARNING: Sync.AddPingGroups is being referenced and is no longer supported - bfricks 1/12/10')
    end

    if Sync.RemovePingGroups then
        WARN('WARNING: Sync.AddPingGroups is being referenced and is no longer supported - bfricks 1/12/10')
    end

    if Sync.SetAlliedVictory != nil then
        import('/lua/ui/game/diplomacy.lua').SetAlliedVictory(Sync.SetAlliedVictory)
    end

    if Sync.AddCameraMarkers then
        import('/lua/ui/game/tutorial.lua').AddCameraMarkers(Sync.AddCameraMarkers)
    end

    if Sync.RemoveCameraMarkers then
        import('/lua/ui/game/tutorial.lua').RemoveCameraMarkers(Sync.RemoveCameraMarkers)
    end

    if Sync.CreateSimDialogue then
        import('/lua/ui/game/simdialogue.lua').CreateSimDialogue(Sync.CreateSimDialogue)
    end

    if Sync.SetButtonDisabled then
        import('/lua/ui/game/simdialogue.lua').SetButtonDisabled(Sync.SetButtonDisabled)
    end

    if Sync.UpdatePosition then
        import('/lua/ui/game/simdialogue.lua').UpdatePosition(Sync.UpdatePosition)
    end

    if Sync.UpdateButtonText then
        import('/lua/ui/game/simdialogue.lua').UpdateButtonText(Sync.UpdateButtonText)
    end

    if Sync.SetDialogueText then
        import('/lua/ui/game/simdialogue.lua').SetDialogueText(Sync.SetDialogueText)
    end

    if Sync.DestroyDialogue then
        import('/lua/ui/game/simdialogue.lua').DestroyDialogue(Sync.DestroyDialogue)
    end

    if Sync.IsSavedGame == true then
        import('/lua/ui/game/gamemain.lua').IsSavedGame = true
    end

	--Research lockout
	if Sync.LockResearch then
		UIResearchLockHidden( true )
	end

	if Sync.UnLockResearch then
		UIResearchLockHidden( false )
	end

    -- Request to hide the ingame UI
    if Sync.DeactivateUI != nil then
        DeactivateUI(Sync.DeactivateUI)
        if Sync.DeactivateUI == false then
			UIGameActiveRecall()
        end
    end
	
	-- Set the current selection
	if Sync.SetSelection != nil then
		if not table.empty(Sync.SetSelection) then
			unitList = {}
			for _, id in Sync.SetSelection do
				local unit = GetUnitById(id)
				if unit:GetArmy() == GetFocusArmy() then
					table.insert(unitList, GetUnitById(id))
				end
			end
			if not table.empty(unitList) then
				SelectUnits(unitList)
			end
		end
	end
end