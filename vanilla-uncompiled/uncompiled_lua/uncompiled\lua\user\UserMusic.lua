--****************************************************************************
-- UserMusic
-- Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
--
--****************************************************************************

--****************************************************************************
-- Config options
--****************************************************************************

-- This represents our current music cue.
local MusicEvent = false

-- How many battle events do we receive before switching to battle music
local BattleEventThreshold = 20

-- Current count of battle events
local BattleEventCounter = 0

-- How many ticks can elapse between NotifyBattle events before we reset the
-- BattleEventCounter (only used in peace time)
local BattleCounterReset = 30 -- 3 seconds

-- How many ticks of battle inactivity until we switch back to peaceful music
local PeaceTimer = 900 -- 20 seconds

--****************************************************************************
-- Internal
--****************************************************************************

-- The last tick in which we got a battle notification
local LastBattleNotify = 0

-- Current music loop if music is active
local Music = false

-- Watcher thread
local MusicThread = false

-- Crossfade thread
local CrossFadeThread = false

-- Tick when battle started, or 0 if at peace
local BattleStart = 0

-- This represents the current parameter crossfade value
local CrossfadeTime = 8.0

-- Last value set as Battle_Level parameter
local Battle_Level = 0.0

-- When SetMusicEvent is called, this is how long until the music crossfades in with the last piece.
local NewMusicCrossfadeTime = 2.5 

function SetMusicEvent( newMusicEvent )
	-- LOG( "*** SetMusicEvent " .. newMusicEvent )
	if newMusicEvent != MusicEvent then	
		if ( newMusicEvent != nil ) then		
			local newMusic = PlaySound( newMusicEvent )			
			SetSoundEventVolume( newMusic, 0.0 )	
			SetSoundEventParameter( newMusic, "Battle_Level", Battle_Level )        
			
			if CrossFadeThread then KillThread(CrossFadeThread) end
			CrossFadeThread = ForkThread(			
				function ()								
					WaitSeconds(0.05)
					local startTime = CurrentTime()    						
					while (CurrentTime() - startTime) < NewMusicCrossfadeTime do
						WaitSeconds(0.05)
						
						if ( Music != nil and Music != false ) then
							SetSoundEventVolume( Music, 1.0 - ((CurrentTime() - startTime) / NewMusicCrossfadeTime) )
						end
						
						SetSoundEventVolume( newMusic, ((CurrentTime() - startTime) / NewMusicCrossfadeTime) )
					end	
					
					if ( Music != nil and Music != false ) then
						StopSound(Music,true) -- true means stop immediately
					end
					
					Music = newMusic
					MusicEvent = newMusicEvent
				end
			)
		else
			Music = false
			MusicEvent = newMusicEvent	        
			
		end
    end   
end

function StopMusicEvent()	
	if ( MusicEvent != nil and MusicEvent != false ) then
		StopSound( Music, true )
	end
end

function NotifyBattle()

    local tick = GameTick()
    local prevNotify = LastBattleNotify
    LastBattleNotify = tick

    -- LOG("*** NotifyBattle, tick=" .. repr(tick))

    if BattleStart == 0 then
        if tick - prevNotify > BattleCounterReset then
            BattleEventCounter = 1
        else
            BattleEventCounter = BattleEventCounter + 1
            if BattleEventCounter > BattleEventThreshold then
                StartBattleMusic()
            end
        end
    end
end


function StartBattleMusic()
    -- LOG("*** StartBattleMusic")   
    
    if ( Music ) then
		local startTime = CurrentTime()    
		if CrossFadeThread then KillThread(CrossFadeThread) end
		CrossFadeThread = ForkThread(
			function ()
				while (CurrentTime() - startTime) < CrossfadeTime do
					--LOG( "Battle Param: " .. (CurrentTime() - startTime) / CrossfadeTime )
					WaitSeconds(0.05)
					Battle_Level = (CurrentTime() - startTime) / CrossfadeTime;
					SetSoundEventParameter( Music, "Battle_Level", Battle_Level )
				end
				Battle_Level = 1
				SetSoundEventParameter( Music, "Battle_Level", Battle_Level )
				CrossFadeThread = false        
			end
		)
	        
		BattleStart = GameTick()
		if MusicThread then KillThread(MusicThread) end
		MusicThread = ForkThread(
			function ()
				while GameTick() - LastBattleNotify < PeaceTimer do
					WaitSeconds(1)
				end
				MusicThread = false
				StartPeaceMusic(true)
			end
		)
	end
end

function StartPeaceMusic()
    -- LOG("*** StartPeaceMusic")
    BattleStart = 0
    BattleEventCounter = 0
    LastBattleNotify = GameTick()        
    
    if ( Music ) then
		local startTime = CurrentTime()    
		if CrossFadeThread then KillThread(CrossFadeThread) end
		CrossFadeThread = ForkThread(
			function ()
				while (CurrentTime() - startTime) < CrossfadeTime do
					--LOG( "Battle Param: " .. (CurrentTime() - startTime) / CrossfadeTime )     
					WaitSeconds(0.05)           
					Battle_Level = 1.0 - ((CurrentTime() - startTime) / CrossfadeTime)
					SetSoundEventParameter( Music, "Battle_Level", Battle_Level )
				end
				CrossFadeThread = false 
				Battle_Level = 0
				SetSoundEventParameter( Music, "Battle_Level", Battle_Level )        
			end
		)
	end

    if MusicThread then KillThread(MusicThread) end    
end
