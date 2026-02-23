--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameMusic.lua
--  Author(s):  Brian Fricks/ Howard Mostrom
--  Summary  :  This file is for wiring and calling scenario specific music events.
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local MusicList = nil

---------------------------------------------------------------------
-- BuildMusicList
--
-- Usage:
--	For every entry in the MusicList - there should be a key and value, and an in-game trigger calling the key.
--	use 'INVALID' when you do not know a valid FMOD event to use for a new eventHandle.
--	use 'DELETE' when you want the Campaign Designers to delete the wiring trigger, because it is not needed.
--
-- NOTES:
--	OP_COMPLETE_VICTORY		- triggered in concert with the "Operation Complete" UI prompt - at the end of a Victory NIS
--	OP_COMPLETE_PLAYERDEATH	- triggered when the player dies
--	OP_COMPLETE_DEFEAT		- triggered when the player loses for a reason other than ACU death
--	XXX_NIS_OPENING_Start	- will always be the first music call for every operation
--	_Start					- used for the begining of every NIS in the game
--	_End					- used for the ending of every NIS
--	_NukeLaunch				- used for all the points where a NUKE is launched in a dramatic moment
--	_TimeDilationStart		- many NIS sequences fade out for a few seconds to signify the passing of time - this happens on FadeOut
--	_TimeDilationEnd		- after a dilation is complete - this is triggered on FadeIn
--	XXX_GEN_XXX				- we will use this syntax for any non NIS event trigger handles (e.g. 'U02_GEN_Enemy_Transports')
--
function BuildMusicList()
	MusicList = {
		['OP_COMPLETE_VICTORY']						= 'SC2/MUSIC/Win',
		['OP_COMPLETE_PLAYERDEATH']					= 'SC2/MUSIC/Lose',
		['OP_COMPLETE_DEFEAT']						= 'SC2/MUSIC/Lose',
		['OP_HOLDING_SOUNDLESS']					= 'SC2/MUSIC/Silent_Music',

		['U01_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/U01/Opening_NIS',
		['U01_NIS_OPENING_NukeLaunch']				= 'INVALID',
		['U01_NIS_OPENING_Enemy_Transports']		= 'INVALID',
		['U01_NIS_OPENING_End']						= 'INVALID',
		['U01_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/U01/Opening_NIS',
		['U01_NIS_REVEAL_ENEMY_Start']				= 'SC2/MUSIC/SC2/CA/U01/U01_NIS_REVEAL_ENEMY_Start',
		['U01_NIS_REVEAL_ENEMY_Enemy_Attack']		= 'INVALID',
		['U01_NIS_REVEAL_ENEMY_End']				= 'INVALID',
		['U01_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/U01/U01_VICTORY_NIS',

		['U02_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/U02/Opening_NIS',
		['U02_NIS_OPENING_ShowColeman']				= 'INVALID',
		['U02_NIS_OPENING_End']						= 'INVALID',
		['U02_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/U02/Opening_NIS',
		['U02_NIS_REVEAL_ENEMY_Start']				= 'SC2/MUSIC/SC2/CA/U02/U02_NIS_REVEAL_ENEMY_Start',
		['U02_NIS_REVEAL_ENEMY_End']				= 'INVALID',
		['U02_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/U02/U02_VICTORY_NIS',
		['U02_GEN_Enemy_Transports']				= 'INVALID',

		['U03_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/U03/Opening_NIS',
		['U03_NIS_OPENING_TimeDilationStart']		= 'INVALID',
		['U03_NIS_OPENING_TimeDilationEnd']			= 'INVALID',
		['U03_NIS_OPENING_End']						= 'INVALID',
		['U03_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/U03/Opening_NIS',
		['U03_NIS_REVEAL_ENEMY_Start']				= 'SC2/MUSIC/SC2/CA/U03/U03_NIS_REVEAL_ENEMY_Start',
		['U03_NIS_REVEAL_ENEMY_Krakken']			= 'INVALID',
		['U03_NIS_REVEAL_ENEMY_End']				= 'INVALID',
		['U03_NIS_GAUGE_ESCAPE_Start']				= 'SC2/MUSIC/SC2/CA/U03/U03_NIS_Guage_Escape_Start',
		['U03_NIS_GAUGE_ESCAPE_Megaliths']			= 'INVALID',
		['U03_NIS_GAUGE_ESCAPE_End']				= 'INVALID',
		['U03_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/U03/U03_VICTORY_NIS',

		['U04_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/U04/Opening_NIS',
		['U04_NIS_OPENING_TimeDilationStart']		= 'SC2/MUSIC/SC2/CA/U04/Opening_NIS_Time_Lapse',
		['U04_NIS_OPENING_TimeDilationEnd']			= 'INVALID',
		['U04_NIS_OPENING_Fatboys']					= 'INVALID',
		['U04_NIS_OPENING_End']						= 'INVALID',
		['U04_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/U04/Opening_NIS_Time_Lapse',
		['U04_NIS_TRANSPORT_ATTACK_Start']			= 'INVALID',
		['U04_NIS_TRANSPORT_ATTACK_NukeLaunch']		= 'INVALID',
		['U04_NIS_TRANSPORT_ATTACK_ColemanMoves']	= 'INVALID',
		['U04_NIS_TRANSPORT_ATTACK_End']			= 'INVALID',
		['U04_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/U04/U04_VICTORY_NIS',

		['U05_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/U05/Opening_NIS',
		['U05_NIS_OPENING_EnemyAttacks']			= 'INVALID',
		['U05_NIS_OPENING_End']						= 'INVALID',
		['U05_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/U05/Opening_NIS',
		['U05_NIS_REVEAL_ENEMY_Start']				= 'SC2/MUSIC/SC2/CA/U05/U01_NIS_REVEAL_ENEMY_Start',
		['U05_NIS_REVEAL_ENEMY_NukeLaunch']			= 'SC2/MUSIC/SC2/CA/U05/Silence_only',
		['U05_NIS_REVEAL_ENEMY_End']				= 'INVALID',
		['U05_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/U05/Silence_only',

		['U06_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/U06/Opening_NIS',
		['U06_NIS_OPENING_End']						= 'INVALID',
		['U06_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/U06/Opening_NIS',
		['U06_NIS_REVEAL_ENEMY_Start']				= 'SC2/MUSIC/SC2/CA/U06/U06_NIS_MID',
		['U06_NIS_REVEAL_ENEMY_GreerDies']			= 'INVALID',
		['U06_NIS_REVEAL_ENEMY_FortressReveal']		= 'INVALID',
		['U06_NIS_REVEAL_ENEMY_End']				= 'INVALID',
		['U06_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/U06/U06_VICTORY_NIS_Start_Wife_talk',
		['U06_NIS_VICTORY_FadeStart']				= 'SC2/MUSIC/SC2/CA/U06/U06_VICTORY_NIS_AfterFade',
		['U06_NIS_VICTORY_FadeEnd']					= 'INVALID',
		['U06_NIS_VICTORY_NukeLaunch']				= 'INVALID',

		['I01_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/I01/Opening_NIS',
		['I01_NIS_OPENING_End']						= 'INVALID',
		['I01_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/I01/Opening_NIS',
		['I01_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/I01/I01_VICTORY_NIS',

		['I02_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/I02/Opening_NIS',
		['I02_NIS_OPENING_EnterCombat']				= 'INVALID',
		['I02_NIS_OPENING_End']						= 'INVALID',
		['I02_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/I02/Opening_NIS',
		['I02_NIS_REVEAL_ENEMY_Start']				= 'SC2/MUSIC/SC2/CA/I02/Silence_only',
		['I02_NIS_REVEAL_ENEMY_Alarm']				= 'INVALID',
		['I02_NIS_REVEAL_ENEMY_End']				= 'INVALID',
		['I02_NIS_COLOSSUS_Start']					= 'SC2/MUSIC/SC2/CA/I02/I02_NIS_REVEAL_Colossus',
		['I02_NIS_COLOSSUS_Reveal']					= 'INVALID',
		['I02_NIS_COLOSSUS_End']					= 'INVALID',
		['I02_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/I02/I02_VICTORY_NIS',

		['I03_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/I03/Opening_NIS',
		['I03_NIS_OPENING_End']						= 'INVALID',
		['I03_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/I03/Opening_NIS',
		['I03_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/I03/I03_VICTORY_NIS',

		['I04_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/I04/Opening_NIS',
		['I04_NIS_OPENING_TimeDilationStart']		= 'INVALID',
		['I04_NIS_OPENING_TimeDilationEnd']			= 'INVALID',
		['I04_NIS_OPENING_ShowAlpha']				= 'INVALID',
		['I04_NIS_OPENING_ShowBravo']				= 'INVALID',
		['I04_NIS_OPENING_End']						= 'INVALID',
		['I04_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/I04/Opening_NIS',
		['I04_NIS_ALLY_GAUGE_ARRIVAL_Start']		= 'SC2/MUSIC/SC2/CA/I04/I04_NIS_REVEAL_GaugeStart',
		['I04_NIS_ALLY_GAUGE_ARRIVAL_End']			= 'INVALID',
		['I04_NIS_ENEMAIR_CDR_DEATH_Start']			= 'SC2/MUSIC/SC2/CA/I04/Silence_only',
		['I04_NIS_ENEMAIR_CDR_DEATH_End']			= 'INVALID',
		['I04_NIS_ENEMLAND_CDR_DEATH_Start']		= 'SC2/MUSIC/SC2/CA/I04/Silence_only',
		['I04_NIS_ENEMLAND_CDR_DEATH_End']			= 'INVALID',
		['I04_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/I04/I04_VICTORY_NIS',

		['I05_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/I05/Opening_NIS',
		['I05_NIS_OPENING_End']						= 'INVALID',
		['I05_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/I05/Opening_NIS',
		['I05_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/I05/Silence_only',
		['I05_NIS_VICTORY_NukeLaunch']				= 'SC2/MUSIC/SC2/CA/I05/I05_VICTORY_NIS_NUKE',

		['I06_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/I06/Opening_NIS',
		['I06_NIS_OPENING_NukeLaunch']				= 'INVALID',
		['I06_NIS_OPENING_End']						= 'INVALID',
		['I06_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/I06/Opening_NIS',
		['I06_NIS_UEF_CDR_DEATH_Start']				= 'SC2/MUSIC/SC2/CA/I06/I06_VICTORY_Silence',
		['I06_NIS_UEF_CDR_DEATH_End']				= 'INVALID',
		['I06_NIS_CYBRAN_CDR_DEATH_Start']			= 'SC2/MUSIC/SC2/CA/I06/I06_VICTORY_Silence',
		['I06_NIS_CYBRAN_CDR_DEATH_End']			= 'INVALID',
		['I06_NIS_ILLUM_CDR_DEATH_Start']			= 'SC2/MUSIC/SC2/CA/I06/I06_VICTORY_Silence',
		['I06_NIS_ILLUM_CDR_DEATH_End']				= 'INVALID',
		['I06_NIS_VICTORY_Start']					= 'INVALID',
		['I06_NIS_VICTORY_NukeLaunch']				= 'INVALID',

		['C01_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/C01/Opening_NIS',
		['C01_NIS_OPENING_End']						= 'INVALID',
		['C01_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/C01/Opening_NIS',
		['C01_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/C01/C01_VICTORY',

		['C02_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/C02/Opening_NIS',
		['C02_NIS_OPENING_End']						= 'INVALID',
		['C02_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/C02/Opening_NIS',
		['C02_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/C02/C02_Victory',

		['C03_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/C03/Opening_NIS',
		['C03_NIS_OPENING_End']						= 'INVALID',
		['C03_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/C03/Opening_NIS',
		['C03_NIS_REVEAL_ENEMY_Start']				= 'SC2/MUSIC/SC2/CA/C03/C03_ILL_reveal',
		['C03_NIS_REVEAL_ENEMY_End']				= 'INVALID',
		['C03_NIS_DINO_Start']						= 'SC2/MUSIC/SC2/CA/C03/C03_MID_NIS_START',
		['C03_NIS_DINO_Reveal']						= 'SC2/MUSIC/SC2/CA/C03/C03_ILL_DINO_reveal',
		['C03_NIS_DINO_End']						= 'INVALID',
		['C03_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/C03/C03_VICTORY',

		['C04_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/C04/Opening_NIS',
		['C04_NIS_OPENING_End']						= 'INVALID',
		['C04_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/C04/Opening_NIS',
		['C04_NIS_ENEM01_CDR01_DEATH_Start']		= 'SC2/MUSIC/SC2/CA/C04/C04_EnemyCommander_Death',
		['C04_NIS_ENEM01_CDR01_DEATH_End']			= 'INVALID',
		['C04_NIS_ENEM01_CDR02_DEATH_Start']		= 'SC2/MUSIC/SC2/CA/C04/C04_EnemyCommander_Death',
		['C04_NIS_ENEM01_CDR02_DEATH_End']			= 'INVALID',
		['C04_NIS_ENEM01_CDR03_DEATH_Start']		= 'INVALID',
		['C04_NIS_ENEM01_CDR03_DEATH_End']			= 'INVALID',
		['C04_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/C04/C04_VICTORY',

		['C05_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/C05/Opening_NIS',
		['C05_NIS_OPENING_End']						= 'INVALID',
		['C05_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/C05/Opening_NIS',
		['C05_NIS_DESTROYER_REVEAL_Start']			= 'SC2/MUSIC/SC2/CA/C05/C05_Ship_reveal',
		['C05_NIS_DESTROYER_REVEAL_End']			= 'INVALID',
		['C05_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/C05/C05_VICTORY',

		['C06_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/C06/Opening_NIS',
		['C06_NIS_OPENING_End']						= 'SC2/MUSIC/SC2/CA/C06/Opening_NIS_After_Movie',
		['C06_NIS_OPENING_Skip']					= 'SC2/MUSIC/SC2/CA/C06/Opening_NIS_After_Movie',
		['C06_NIS_FIRST_COIL_DOWN_Start']			= 'INVALID',
		['C06_NIS_FIRST_COIL_DOWN_End']				= 'INVALID',
		['C06_NIS_ALL_COILS_DOWN_Start']			= 'SC2/MUSIC/SC2/CA/C06/C06_MID_NIS',
		['C06_NIS_ALL_COILS_DOWN_DefenseActive']	= 'INVALID',
		['C06_NIS_ALL_COILS_DOWN_End']				= 'INVALID',
		['C06_NIS_VICTORY_Start']					= 'SC2/MUSIC/SC2/CA/C06/C06_VICTORY',
		['C06_NIS_VICTORY_TimeDilationStart']		= 'INVALID',
		['C06_NIS_VICTORY_TimeDilationEnd']			= 'INVALID',
		['C06_NIS_VICTORY_IvanSaysNo']				= 'INVALID',

		['T01_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/T01/Opening_NIS',
		['T01_NIS_OPENING_End']						= 'INVALID',
		['T01_NIS_VICTORY_Start']					= 'INVALID',

		['T02_NIS_OPENING_Start']					= 'SC2/MUSIC/SC2/CA/T02/Opening_NIS',
		['T02_NIS_OPENING_End']						= 'INVALID',
		['T02_NIS_VICTORY_Start']					= 'INVALID',
	}
end

---------------------------------------------------------------------
-- PlayMusicEvent
-- use the specified <eventHandle> to find a specific event which, if valid is then played.
function PlayMusicEventByHandle(eventHandle)
	if not MusicList then
		BuildMusicList()
	end

	if MusicList[eventHandle] then
		local strMusic = MusicList[eventHandle]
		if strMusic == 'DELETE' then
			WARN('WARNING: ScenarioGameMusic: Campaign design needs to delete the trigger and entry for eventHandle[', eventHandle, '].')
		elseif strMusic != 'INVALID' then
			LOG('SIM: Music: [', strMusic, ']')
			Sync.PlayMusic = strMusic
		else
			LOG('UNUSED MUSIC TRIGGER: ScenarioGameMusic: eventHandle[', eventHandle, '] has no music event - skipping call.')
		end
	else
		WARN('WARNING: ScenarioGameMusic: unable to find a valid MusicList entry for eventHandle[', eventHandle, ']. Pass to Campaign Design.')
	end
end
