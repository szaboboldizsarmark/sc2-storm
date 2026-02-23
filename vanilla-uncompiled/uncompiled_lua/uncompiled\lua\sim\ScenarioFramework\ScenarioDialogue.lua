-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioDialogue.lua
--  Author(s):  John Comes, Drew Staltman, Brian Fricks
--  Summary  : Helper functions for dialogue.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

---------------------------------------------------------------------
-- Dialogue is the core function used to play dialog
--	<dialogueTable> is the block of content references needed to process the dialog in the UI
--			it also contains variables that get referenced on the Sim to properly queue the dialog
--
--	<callback> is a function that will play when a full block of dialog content is finished
--
--	<bCritical> is a flag that ONLY means, the dialog block is allowed to play when ScenarioInfo.OpNISActive is true
--			NOTE 1: critical does NOT interrupt
--			NOTE 2: critical means nothing if the ScenarioInfo.OpNISActive flag is not set
--
-- <requiredAliveUnit> is still supported but rarely used, it is a unit handle, that can prevent dialog from playing if the unit is dead
--
---------------------------------------------------------------------
function Dialogue(dialogueTable, callback, bCritical, requiredAliveUnit)
	-- gather a deepcopy of our dialogue data
	local dTable = table.deepcopy( dialogueTable )

	-- if we have a callback - append it to our table
	if callback then
		dTable.Callback = callback
	end

	-- if we are critical - make sure we can play
	if bCritical then
		dTable.Critical = bCritical
	end

	-- if we are not critical and an NIS is playing right now, we tag ourselves as flushed immediately
	if not bCritical and ScenarioInfo.OpNISActive then
		LOG('SCENARIO DIALOG: tagging dialog for flush - ScenarioInfo.OpNISActive')
		dTable.Flushed = true
	end

	-- if we have a unit that must be alive, and it is dead, also tag ourselves as flushed immediately
	if requiredAliveUnit and requiredAliveUnit:IsDead() then
		LOG('SCENARIO DIALOG: tagging dialog for flush - requiredAliveUnit:IsDead()')
		dTable.Flushed = true
	end

	-- and finally, if the op is over, we dont want non-critical dialog, but we might still need the callback - so proceed as if we are flushed
	if ScenarioInfo.OpEnded and not bCritical then
		LOG('SCENARIO DIALOG: tagging dialog for flush - ScenarioInfo.OpEnded')
		dTable.Flushed = true
	end

	-- if this is the first time calling this function - setup the queue
	if ScenarioInfo.DialogueLock == nil then
		ScenarioInfo.DialogueLock = false
		ScenarioInfo.DialogueLockPosition = 0
		ScenarioInfo.DialogueQueue = {}
		ScenarioInfo.DialogueFinished = {}
	end

	-- add our table to the queue
	table.insert(ScenarioInfo.DialogueQueue, dTable)

	-- if we are locked, begin a thread to play the dialogue
	if not ScenarioInfo.DialogueLock then
		ScenarioInfo.DialogueLock = true
		ForkThread( PlayDialogue )
	end
end

---------------------------------------------------------------------
-- FlushDialogueQueue is used when we want our new dialog to take precedent
--	over any dialog that has not yet played but is in the queue
-- 	the flag <bUnlockQueue> will unlock the queue - allowing any subsequent dialog to
--	get called on top of any currently playing lines (in otherwords - it lets the UI sort it out)
--	NOTE: for SC2, our UI doesn't try and manage any sort of queue for incomming dialog
--		so this would just blow out the current PIP - bfricks 9/30/09
--
--	NOTE: in the future, we should support a clear function on the User side, so this
--		can be more explicit - and not just an outcome of the current UI code. - bfricks 9/30/09
---------------------------------------------------------------------
function FlushDialogueQueue(bUnlockQueue)
	if ScenarioInfo.DialogueQueue then
		for k,v in ScenarioInfo.DialogueQueue do
			v.Flushed = true
		end

		if bUnlockQueue then
			ScenarioInfo.DialogueLock = false
		end
	end
end

---------------------------------------------------------------------
-- The actual thread used by Dialogue
---------------------------------------------------------------------
function PlayDialogue()
	while table.getn(ScenarioInfo.DialogueQueue) > 0 do

		-- get the next block of dialog to process
		local dTable = ScenarioInfo.DialogueQueue[1]

		-- if we are not flushed AND we are also either flagged as critical or the OpEnded flag has not been set
		if not dTable.Flushed and ( not ScenarioInfo.OpNISActive or dTable.Critical ) then
			for k,v in dTable do
				if v and v.vid and not dTable.Flushed and ( not ScenarioInfo.OpNISActive or dTable.Critical ) then
					-- using the data from line v, create a movieData table to send to the User
					local movieData = {}
					movieData.ID		= GetNextDialogID()
					movieData.movie		= '/movies/' .. v.vid
					movieData.bank		= v.bank
					movieData.cue		= v.cue
					movieData.faction	= v.faction
					movieData.duration	= GetMovieDuration(movieData.movie)
					movieData.numLines	= table.getn(dTable) - k
					movieData.portrait	= v.portrait or ''
					movieData.emotion	= v.emotion or ''
					movieData.speaker	= v.speaker or ''
					movieData.rawText	= v.text or ''
					movieData.vidText	= movieData.speaker .. ': ' .. movieData.rawText

					-- if we have no real movie length, force the length to a value
					if not movieData.duration > 0 then
						vidDuration = 3.0
					end

					-- if we have a forced duration, use that instead of the video duration
					if v.forced_duration and v.forced_duration > 0 then
						movieData.duration = v.forced_duration
					end

					--LOG('----- ')
					--LOG('----- DIALOG TRACKER: TIME:[', GetGameTick(), ']')
					--LOG('----- DIALOG TRACKER: TEXT:[', movieData.rawText, ']')
					--LOG('----- DIALOG TRACKER: ID:  [', movieData.ID, ']')
					--LOG('----- ')

					-- all the data is processed, so lets play the line of dialog (a latent call)
					--- NOTE: in the future it would be nice to allow the User to handle the queue a bit more
					---			but with the current usage cases, this is not something we can just do easily.
					---			I suggest we try and address this after SC2. - bfricks 9/30/09
					SetupMFDSync(movieData)
				end
			end
		end

		-- now that we are done, remove ourselves from the queue
		table.remove(ScenarioInfo.DialogueQueue, 1)

		-- if needed, callback
		if dTable.Callback then
			ForkThread(dTable.Callback)
		end

		WaitTicks(1)
	end

	ScenarioInfo.DialogueLock = false
end

---------------------------------------------------------------------
function GetNextDialogID()
	if not ScenarioInfo.CurrentDialogID then
		ScenarioInfo.CurrentDialogID = 1
	else
		ScenarioInfo.CurrentDialogID = ScenarioInfo.CurrentDialogID + 1
	end

	local ret = 'DIALOG_ID_' .. ScenarioInfo.CurrentDialogID

	return ret
end

---------------------------------------------------------------------
-- This function sends movie data to the sync table and saves it off for reloading in save games
---------------------------------------------------------------------
function SetupMFDSync(movieData)
	Sync.PlayMFDMovie = movieData
	ScenarioInfo.DialogueFinished[movieData.ID] = false

	AddTransmissionData(movieData)
	WaitForDialogue(movieData.ID)
end

---------------------------------------------------------------------
function AddTransmissionData(movieData)
	---NOTE: hey - with the updates to how movieData works and all the new variables - it seems likely that this save
	---		process could have some bugs - perhaps we will just need to make entryData == movieData??? - bfricks 9/30/09

	local entryData = {}
	entryData.text = LOC(movieData.rawText)

	if movieData.speaker != '' then
		entryData.name = LOC(movieData.speaker) .. ': '
	else
		entryData.name = "INVALID NAME"
	end

	local timeSecs = GetGameTimeSeconds()
	entryData.time = string.format("%02d:%02d:%02d", math.floor(timeSecs/360), math.floor(timeSecs/60), math.mod(timeSecs, 60))
	entryData.color = 'ffffffff'

	if movieData.faction then
		if movieData.faction == 'UEF' then
			entryData.color = 'ff00c1ff'
		elseif movieData.faction == 'Cybran' then
			entryData.color = 'ffff0000'
		elseif movieData.faction == 'Illuminate' then
			entryData.color = 'ff89d300'
		end
	end

	import('/lua/sim/SimUIState.lua').SaveEntry(entryData)
end

---------------------------------------------------------------------
function WaitForDialogue(ID)
	while not ScenarioInfo.DialogueFinished[ID] do
		WaitTicks(1)
	end
end