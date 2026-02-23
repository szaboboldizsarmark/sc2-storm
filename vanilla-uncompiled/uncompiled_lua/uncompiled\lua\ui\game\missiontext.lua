--*******************************************************************
--* File: lua/modules/ui/game/missiontext.lua
--* Author: Ted Snook
--* Summary: Mission text HUD
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*******************************************************************

--*******************************************************************
-- VARIABLES:
--*******************************************************************
local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/Bitmap.lua').Bitmap
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local WrapText = import('/lua/maui/text.lua').WrapText
local Movie = import('/lua/maui/movie.lua').Movie
local GameMain = import('/lua/ui/game/gamemain.lua')
local subtitleThread = false
local currentMovie = false

controls = {}

--*******************************************************************
-- FUNCTIONS:
--*******************************************************************

---------------------------------------------------------
function SetLayout()
    import(UIUtil.GetLayoutFilename('missiontext')).SetLayout()
end

---------------------------------------------------------
function OnGamePause(paused)
    if controls.movieBrackets then
        controls.movieBrackets:Pause(paused)
    end
end

---------------------------------------------------------
function IsHeadPlaying()
    if controls.movieBrackets then
        return true
    else
        return false
    end
end

---------------------------------------------------------
-- good chance this doesn't work - as currentMovie is never set - bfricks 3/11/09
---------------------------------------------------------
function PauseTransmission()
    if currentMovie then
        currentMovie:Stop()
    end
end

---------------------------------------------------------
-- good chance this doesn't work - as currentMovie is never set - bfricks 3/11/09
---------------------------------------------------------
function ResumeTransmission()
    if currentMovie then
        currentMovie:Play()
    end
end

---------------------------------------------------------
-- I made some significant modifications to this function to support dialog prototyping in SC2 - bfricks 3/11/09
---------------------------------------------------------
function PlayMFDMovie(movieData)

	-- if there is a movie playing, cleanup the movie
	if controls.movieBrackets.movie then
		controls.movieBrackets.movie:Destroy()
	end

	-- if there is text, clean up the text
	if controls.subtitles then
		controls.subtitles:Destroy()
	end

	-- extract some data that might need to be modified locally, before passing to the UI code
	local movieInfo		= movieData.movie
	local speakerName	= movieData.speaker

	--*****************************************************
	--*****************************************************
	--*****************************************************
	--*****************************************************
	--*****************************************************
	--*****************************************************
	---TODO: remove this override once we have properly setup our SC2 movies - bfricks 6/12/09
	if speakerName == '<LOC CHARACTER_0022>Dr. Brackman' then
		movieInfo = '/movies/' .. 'PH_Brain.sfd'
	end
	--*****************************************************
	--*****************************************************
	--*****************************************************
	--*****************************************************
	--*****************************************************
	--*****************************************************

	DisplayPIP(movieInfo, movieData.bank, movieData.cue, movieData.duration, movieData.numLines, movieData.vidText)
	ForkThread(
		function()
			WaitSeconds(movieData.duration)
			SimCallback( { Func = "OnMovieFinished", Args = movieData.ID} )
		end
	)
end

---------------------------------------------------------
function CreateSubtitles(parent, text)
    local bg = Bitmap(parent, UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_m.dds'))

    bg.text = {}
    bg.text[1] = UIUtil.CreateText(bg, '', 12, UIUtil.bodyFont)

    bg.tl = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ul.dds'))
    bg.tm = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_horz_um.dds'))
    bg.tr = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ur.dds'))
    bg.ml = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_vert_l.dds'))
    bg.mr = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_vert_r.dds'))
    bg.bl = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_ll.dds'))
    bg.bm = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_lm.dds'))
    bg.br = Bitmap(bg, UIUtil.SkinnableFile('/game/filter-ping-list-panel/panel_brd_lr.dds'))

    bg.tl.Bottom:Set(bg.Top)
    bg.tl.Right:Set(bg.Left)
    bg.tr.Bottom:Set(bg.Top)
    bg.tr.Left:Set(bg.Right)
    bg.bl.Top:Set(bg.Bottom)
    bg.bl.Right:Set(bg.Left)
    bg.br.Top:Set(bg.Bottom)
    bg.br.Left:Set(bg.Right)
    bg.tm.Bottom:Set(bg.Top)
    bg.tm.Left:Set(bg.Left)
    bg.tm.Right:Set(bg.Right)
    bg.bm.Top:Set(bg.Bottom)
    bg.bm.Left:Set(bg.Left)
    bg.bm.Right:Set(bg.Right)
    bg.ml.Right:Set(bg.Left)
    bg.ml.Top:Set(bg.Top)
    bg.ml.Bottom:Set(bg.Bottom)
    bg.mr.Left:Set(bg.Right)
    bg.mr.Top:Set(bg.Top)
    bg.mr.Bottom:Set(bg.Bottom)

    local wrapped = import('/lua/maui/text.lua').WrapText(LOC(text), 300,
        function(curText) return bg.text[1]:GetStringAdvance(curText) end)

    for index, line in wrapped do
        local i = index
        if not bg.text[i] then
            bg.text[i] = UIUtil.CreateText(bg.text[1], '', 12, UIUtil.bodyFont)
            LayoutHelpers.Below(bg.text[i], bg.text[i-1])
        end
        bg.text[i]:SetText(line)
    end

    bg.Top:Set(bg.text[1].Top)
    bg.Left:Set(bg.text[1].Left)
    bg.Width:Set(300)
    bg.Height:Set(function() return table.getsize(bg.text) * bg.text[1].Height() end)
    bg:SetAlpha(1, true)

    return bg
end

---------------------------------------------------------
function DisplaySubtitles(textControl,captions)
    subtitleThread = ForkThread(
        function()
            -- Display subtitles
            local lastOff = 0
            for k,v in captions do
                WaitSeconds(v.offset - lastOff)
                textControl:DeleteAllItems()
                locText = LOC(v.text)
                --LOG("Wrap: ",locText)
                local lines = WrapText(locText, textControl.Width(), function(text) return textControl:GetStringAdvance(text) end)
                for i,line in lines do
                    textControl:AddItem(line)
                end
                textControl:ScrollToBottom()
                lastOff = v.offset
            end
            subtitleThread = false
        end
    )
end

---------------------------------------------------------
function EndGameFMV(faction)
	WARN('EndGameFMV: is being called - this needs to be reviewed further and likely replaced in SC2 - bfricks 3/17/09')

	---DEV NOTE: this was a table outside this function - but only referenced inside, so i moved it here,commented it out
	---				and we can resolve how this whole thing will work farther down the road. SC2 will not have factional
	---				specific endings - so this whole function is likely off. - bfricks 3/17/09
--	local FMVData = {
--	    uef			= {name = 'UEF', voicecue = 'SCX_UEF_Credits_VO', soundcue = 'X_FMV_UEF_Credits'},
--	    cybran		= {name = 'Cybran', voicecue = 'SCX_Cybran_Credits_VO', soundcue = 'X_FMV_Cybran_Credits'},
--	    illuminate	= {name = 'Aeon', voicecue = 'SCX_Aeon_Credits_VO', soundcue = 'X_FMV_Aeon_Credits'},
--	}
--
--    local setResume = SessionIsPaused()
--    SessionRequestPause()
--    ConExecute("ren_Oblivion true")
--    local parent = GetFrame(0)
--    local nisBG = Bitmap(parent)
--    nisBG:SetSolidColor('FF000000')
--    LayoutHelpers.FillParent(nisBG, parent)
--    nisBG.Depth:Set(99998)
--    local nis = Movie(parent, "/movies/FMV_SCX_Outro.sfd")
--    nis.Depth:Set(99999)
--    nis.faction = faction
--    nis.stage = 1
--    LayoutHelpers.FillParentPreserveAspectRatio(nis, parent)
--    nis.voicecue = 'SCX_Outro_VO'
--    nis.soundcue = 'X_FMV_Outro'
--
--    GameMain.gameUIHidden = true
--
--    local textArea = ItemList(parent)
--    textArea:SetFont(UIUtil.bodyFont, 13)
--
--    local height = 6 * textArea:GetRowHeight()
--    textArea.Height:Set( height )
--    textArea.Top:Set( function() return nis.Bottom() end )
--    textArea.Width:Set( function() return nis.Width() / 2 end )
--    LayoutHelpers.AtHorizontalCenterIn(textArea,parent)
--
--    textArea:SetColors(UIUtil.fontColor, "00000000", UIUtil.fontColor,  UIUtil.highlightColor)
--    textArea.Depth:Set(100000)
--
--    --local strings = import('/tutorials/' .. subtitleKey .. '/' .. subtitleKey .. '.lua')[subtitleKey]
--    AddInputCapture(nis)
--
--    local loading = true
--
--    local function SetMovie(filename, soundcue, voicecue)
--        nis:Set(filename,
--                Sound({Cue = soundcue, Bank = 'FMV_BG'}),
--                Sound({Cue = voicecue, Bank = 'X_FMV'}))
--    end
--
--    nis.OnLoaded = function(self)
--        GetCursor():Hide()
--        nis:Play()
--        --DisplaySubtitles(textArea, strings.captions)
--        loading = false
--    end
--
--    function DoExit(onFMVFinished)
--        nis:Stop()
--        loading = true
--        if nis.stage == 1 then
--            SetMovie("/movies/Credits_"..FMVData[nis.faction].name..".sfd",
--                     FMVData[nis.faction].soundcue,
--                     FMVData[nis.faction].voicecue)
--        elseif nis.stage == 2 and onFMVFinished then
--            SetMovie("/movies/FMV_SCX_Post_Outro.sfd",
--                     'X_FMV_Post_Outro',
--                     'SCX_Post_Outro_VO')
--        else
--            GameMain.gameUIHidden = false
--            GetCursor():Show()
--            if not setResume then
--                SessionResume()
--            end
--            ConExecute("ren_Oblivion")
--            if subtitleThread then
--                KillThread(subtitleThread)
--                subtitleThread = false
--            end
--            nisBG:Destroy()
--            RemoveInputCapture(nis)
--            nis:Destroy()
--            if textArea then
--                textArea:Destroy()
--            end
--            SimCallback({Func = "OnEndGameFMVFinished"})
--        end
--        nis.stage = nis.stage + 1
--    end
--
--    nis.OnFinished = function(self)
--        DoExit(true)
--    end
--
--    nis.HandleEvent = function(self, event)
--        if loading then
--            return false
--        end
--        -- cancel movie playback on mouse click or key hit
--        if event.Type == "ButtonPress" or event.Type == "KeyDown" then
--            DoExit()
--            return true
--        end
--    end
end
