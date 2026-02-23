--*****************************************************************************
--* File: lua/modules/ui/game/gameresult.lua
--* Summary: Victory and Defeat behavior
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local OtherArmyResultStrings = {
    victory = '<LOC usersync_0001>wins!',
    defeat = '<LOC usersync_0002>has been defeated!',
    draw = '<LOC usersync_0003>receives a draw.',
    gameOver = '<LOC usersync_0004>Game Over.',
}

local MyArmyResultStrings = {
    victory = "<LOC GAMERESULT_0000>Victory!",
    defeat = "<LOC GAMERESULT_0001>You have been defeated!",
    draw = "<LOC GAMERESULT_0002>It's a draw.",
    replay = "<LOC GAMERESULT_0003>Replay Finished.",
}

function OnReplayEnd()
	-- $$$ Todo: replace this with new announcement interface
    --import('/lua/ui/game/tabs.lua').TabAnnouncement('main', LOC(MyArmyResultStrings.replay))
end

local announced = {}

function DoGameResult(armyIndex, result)
    local sessionInfo = SessionGetScenarioInfo()

    if not announced[armyIndex] then
        announced[armyIndex] = true
        if armyIndex == GetFocusArmy() then
            local armies = GetArmiesTable().armiesTable
            displayMessage(LOC(MyArmyResultStrings[result]))

			if SessionIsObservingAllowed() then
                SetFocusArmy(-1)
            end

            if result == 'victory' then
				LOG( "U WIN" )
				import('/lua/user/UserMusic.lua').SetMusicEvent( 'SC2/MUSIC/MP/Win' )

			else
				LOG( "U LOSE" )
				import('/lua/user/UserMusic.lua').SetMusicEvent( 'SC2/MUSIC/MP/Lose' )
			end

            local victory = true
            if result == 'defeat' then
                victory = false
            end

            --Put a victory flag in the session info for stats and achievment tracking
            if victory then
				sessionInfo.MapVictory = true
			else
				sessionInfo.MapVictory = false
            end
        else
			-- Using old logic to get the army name and result string, then passing it to the PrintToScreen function
			-- Only called on death of an ACU
            local armies = GetArmiesTable().armiesTable
            displayMessage(LOC(armies[armyIndex].nickname) .. ' ' .. LOC(OtherArmyResultStrings[result]))
        end
    end
end

function displayMessage(strTitle)
	local data = {
		text = strTitle,
		size = 24,
		color = 'ffffffff',
		duration = 15.0,
		location = 'center'
	}

	import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
end

