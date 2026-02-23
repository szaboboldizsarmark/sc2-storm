--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific functions designed to support NIS work - but outside the set of core functions.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

---------------------------------------------------------------------
-- ValidateCamera
function ValidateCamera(strFuncName)
	if ScenarioInfo.Camera then
		return true
	else
		local strWarningText = '] called with invalid camera - somehow this function is being called outside the scope of an NIS!'
		if strFuncName and type(strFuncName) == 'string' then
			strWarningText = 'WARNING: NIS FAILURE: [' .. strFuncName .. strWarningText
		end

		WARN(strWarningText)
		return false
	end
end

---------------------------------------------------------------------
-- AddToNISOnlyTransports
function AddToNISOnlyTransports(transport, loadedUnits, unloadDest, returnDest)
	if loadedUnits and transport and not transport:IsDead() then
		-- add the entity to the cleanup list
		if not ScenarioInfo.NISOnlyTransports then
			ScenarioInfo.NISOnlyTransports = {}
		end

		-- store the loaded units
		if not transport.ScenarioUnitData then
			transport.ScenarioUnitData = {}
		end
		transport.ScenarioUnitData.loadedUnits	= loadedUnits
		transport.ScenarioUnitData.unloadDest	= unloadDest
		transport.ScenarioUnitData.returnDest	= returnDest

		table.insert(ScenarioInfo.NISOnlyTransports, transport)
	end
end

---------------------------------------------------------------------
-- CleanupNISTransports
function CleanupNISOnlyTransports()
	if ScenarioInfo.NISOnlyTransports then
		for k, transport in ScenarioInfo.NISOnlyTransports do
			if transport and not transport:IsDead() then
				-- flag the transport unselectable
				transport:SetUnSelectable(true)

				local needsUnload = false
				if transport.ScenarioUnitData and transport.ScenarioUnitData.loadedUnits then
					for i, unit in transport.ScenarioUnitData.loadedUnits do
						if not unit:IsDead() and unit:IsUnitState('Attached') then
							WARN('WARNING: an NIS is ending with critical units still on a transport - this needs to be sent to Campaign Design!')
							if transport.ScenarioUnitData.unloadDest then
								needsUnload = true
							end
						end
					end
				end

				---NOTE: this entire section is super tinfoil hat - the goal is to be double-sure the transports complete their planned route
				--- 		This section was added because we observed several failures on U06. - bfricks 10/19/09
				if needsUnload then
					ForkThread(TinFoilTransportDeployThread,transport)
				elseif transport.ScenarioUnitData and transport.ScenarioUnitData.returnDest then
					local pos = GetPos(transport.ScenarioUnitData.returnDest)
					IssueMove({transport}, pos)
				end
			end
		end

		ScenarioInfo.NISOnlyTransports = {}
	end
end
---------------------------------------------------------------------
function TinFoilTransportDeployThread(transport)
	if transport and not transport:IsDead() then
		local pos = GetPos(transport.ScenarioUnitData.unloadDest)
		IssueTransportUnload({transport}, pos)
		local attached = true
		while attached do
			WaitTicks(1)
			if transport:IsDead() then
				return
			end
			attached = false
			for num, unit in transport.ScenarioUnitData.loadedUnits do
				if not unit:IsDead() and unit:IsUnitState('Attached') then
					attached = true
					break
				end
			end
		end
	end

	if transport and not transport:IsDead() then
		IssueClearCommands({transport})
		if transport.ScenarioUnitData.returnDest then
			local pos = GetPos(transport.ScenarioUnitData.returnDest)
			IssueMove({transport}, pos)
		end
	end
end

---------------------------------------------------------------------
-- AddToNISOnlyEntities
function AddToNISOnlyEntities(ent)
	-- add the entity to the cleanup list
	if not ScenarioInfo.NISOnlyEntities then
		ScenarioInfo.NISOnlyEntities = {}
	end

	table.insert(ScenarioInfo.NISOnlyEntities, ent)
end

---------------------------------------------------------------------
-- DestroyNISOnlyEntities
function DestroyNISOnlyEntities()
	---NOTE: eventually this should handoff arrows to the objective system instead of this - bfricks 7/12/09
	---NOTE: eventualy the vizMarkers in this list need a solution for popping - bfricks 7/10/09
	if ScenarioInfo.NISOnlyEntities then
		for k, v in ScenarioInfo.NISOnlyEntities do
			v:Destroy()
		end

		ScenarioInfo.NISOnlyEntities = {}
	end
end

---------------------------------------------------------------------
-- NISAddToProtectedUnitList
function NISAddToProtectedUnitList(group)
	if not ScenarioInfo.NISProtectedUnits then
		WARN('WARNING: attempting to call NISAddToProtectedUnitList when there is no list to operate on - this should be reviewed by Campaign Design - bfricks 10/7/09.')
		return
	end

	for k, unit in group do
		-- if we are on a transport, there is no clean way to do any of this management now, so we wait
		if unit and unit.OnTransport then
			ForkThread(NISOnTransportProtectionDelay, unit)
		else
			NISProtect(unit)
		end
	end
end

---------------------------------------------------------------------
-- SetupProtectedUnits
---NOTE: the limitations of this function are as follows:
---			this will not override any special case units that have been flagged as Protected prior to the NIS
---			these settings will be ignored when force-killing during an NIS
---			any unit created during an NIS will be excluded from this list
function SetupProtectedUnits()
	-- create a table to store all of our units
	ScenarioInfo.NISProtectedUnits = {}

	for i, aiBrain in ArmyBrains do
		local units = aiBrain:GetListOfUnits( categories.ALLUNITS, false )
		for k, unit in units do
			-- if we are on a transport, there is no clean way to do any of this management now, so we wait
			if unit and unit.OnTransport then
				ForkThread(NISOnTransportProtectionDelay, unit)
			else
				NISProtect(unit)
			end
		end
	end
end

---------------------------------------------------------------------
-- CleanupProtectedUnits
---NOTE: the limitations of this function are as follows:
---			this function only changes the settings of units identified at the start of the NIS as needing the restriction
---			any unit that was protected during the middle of an NIS will be broken by this function
---				(so be sure to only apply protections during the setup before the NIS or followup after the NIS)
function CleanupProtectedUnits()
	if ScenarioInfo.NISProtectedUnits then
		for k, unit in ScenarioInfo.NISProtectedUnits do
			NISUnProtect(unit)
		end

		-- clear the list
		ScenarioInfo.NISProtectedUnits = {}
	end
end

---------------------------------------------------------------------
-- NISOnTransportProtectionDelay(unit)
function NISOnTransportProtectionDelay(unit)
	while unit and not unit:IsDead() and unit.OnTransport do
		WaitTicks(1)
	end
	if ScenarioInfo.OpNISActive then
		NISProtect(unit)
	end
end

---------------------------------------------------------------------
-- NISProtect(unit)
function NISProtect(unit)
	if unit and not unit:IsDead() then
		local bNeedsProtection = false

		-- check to see if the unit can reclaim/repair, and if so, disable, and flag the unit so we remember we have adjusted these values
		---NOTE: basically we always restrict all functionality for all engineers during the NIS - bfricks 12/8/09
		if EntityCategoryContains( categories.ENGINEER * categories.MOBILE, unit ) and not unit.Hunkered then
			if not unit.ScenarioUnitData then
				unit.ScenarioUnitData = {}
			end

			unit.ScenarioUnitData.NISReclaimRepairOff = true
			unit:RemoveCommandCap('RULEUCC_Reclaim')
			unit:RemoveCommandCap('RULEUCC_Repair')
			bNeedsProtection = true
		end

		if unit:CheckCanTakeDamage() then
			-- flag the unit as protected
			unit:SetCanTakeDamage(false)
			bNeedsProtection = true
		elseif bNeedsProtection then
			if not unit.ScenarioUnitData then
				unit.ScenarioUnitData = {}
			end
			unit.ScenarioUnitData.NISSkipDmgToggle = true
		end

		if bNeedsProtection then
			-- store the unit in our NIS protection list
			table.insert(ScenarioInfo.NISProtectedUnits, unit)
		else
		end
	end
end

---------------------------------------------------------------------
-- NISUnProtect(unit)
function NISUnProtect(unit)
	if unit and not unit:IsDead() then
		if not unit.ScenarioUnitData then
			-- unflag the unit as protected
			unit:SetCanTakeDamage(true)
		elseif unit.ScenarioUnitData.NISSkipDmgToggle then
			-- skip the dmg toggle, but unflag this variable
			unit.ScenarioUnitData.NISSkipDmgToggle = false
		else
			-- unflag the unit as protected
			unit:SetCanTakeDamage(true)
		end

		-- if needed, reset the speed of the transport
		if unit.ScenarioUnitData and unit.ScenarioUnitData.TransportSpeedAdjusted then
			-- unflag this variable
			unit.ScenarioUnitData.TransportSpeedAdjusted = false

			-- and now adjust the mults
			unit:SetSpeedMult(1.0)
			unit:SetNavMaxSpeedMultiplier(1.0)
		end

		-- check to see if the unit has had reclaim/repair turned off during protection, and if so, re-enable them
		---NOTE: now that it is time to un-restrict, we need to be careful not to restore non player ACU reclaim, and ally ACU repair - bfricks 12/8/09
		if unit.ScenarioUnitData and unit.ScenarioUnitData.NISReclaimRepairOff then
			unit.ScenarioUnitData.NISReclaimRepairOff = false

			local cmdCats = categories.COMMAND - categories.ESCAPEPOD

			-- reclaimRestricted == non-player ACUs cannot reclaim
			local reclaimRestricted = (unit:GetArmy() > 1) and EntityCategoryContains( cmdCats, unit )
			if not reclaimRestricted then
				unit:AddCommandCap('RULEUCC_Reclaim')
			end

			-- repairRestricted == certain key units have also been flagged to not repair
			local repairRestricted = unit.ScenarioUnitData.RepairRestricted
			if not repairRestricted then
				unit:AddCommandCap('RULEUCC_Repair')
			end
		end
	end
end

---------------------------------------------------------------------
-- DisableAllUnitAttackers
function DisableAllUnitAttackers()
	ScenarioInfo.NISCombatDisabled = true
	for i, aiBrain in ArmyBrains do
		local units = aiBrain:GetListOfUnits( categories.ALLUNITS, false )
		for k, unit in units do
			if unit and not unit:IsDead() then
				unit:SetAttackerEnabled(false)
			end
		end
	end
end

---------------------------------------------------------------------
-- RestoreAllUnitAttackers
function RestoreAllUnitAttackers()
	if ScenarioInfo.NISCombatDisabled then
		for i, aiBrain in ArmyBrains do
			local units = aiBrain:GetListOfUnits( categories.ALLUNITS, false )
			for k, unit in units do
				if unit and not unit:IsDead() then
					unit:SetAttackerEnabled(false)
				end
			end
		end
		ScenarioInfo.NISCombatDisabled = false
	end
end

---------------------------------------------------------------------
-- SkipOpeningNIS
---------------------------------------------------------------------
function SkipOpeningNIS(func, nOverrideZoom, OverridePos)
	-- lock input
	LockInput()

	-- protect normal units from damage and other odd behaviors
	SetupProtectedUnits()

	-- call the func
	func()

	-- set the camera
	if not ScenarioInfo.Camera then
		ScenarioInfo.Camera = import('/lua/sim/simcamera.lua').SimCamera('WorldCamera')
	end

	-- determine final zoom
	local finalZoom = nOverrideZoom or nil

	-- save camera settings
	ScenarioInfo.Camera:SaveSettings()

	-- set the final camera
	if OverridePos then
		ScenarioInfo.Camera:RestoreSettings(OverridePos, finalZoom, 0.0)
	else
		ScenarioInfo.Camera:RestoreSettings(ScenarioInfo.PLAYER_CDR:GetPosition(), finalZoom, 0.0)
	end

	-- wait a brief bit
	WaitTicks(1)

	-- unset the camera
	ScenarioInfo.Camera = nil

	-- allow normal damage and other odd behaviors
	CleanupProtectedUnits()

	-- unlock input
	UnlockInput()

	-- record the game time, for score tracking
	ScenarioInfo.CampaignOpeningEndTime = GetGameTick() * 0.1
	LOG('TIME TRACKING: SkipOpeningNIS: ScenarioInfo.CampaignOpeningEndTime:[', ScenarioInfo.CampaignOpeningEndTime, ']' )

	-- fade in
	Sync.NISFadeIn = { ["seconds"] = 3.0 }
end

---------------------------------------------------------------------
-- SkipMidOpNIS
---------------------------------------------------------------------
function SkipMidOpNIS(func)
	-- fade out
	Sync.NISFadeOut = { ["seconds"] = 1.0 }

	-- lock input
	LockInput()

	-- protect normal units from damage and other odd behaviors
	SetupProtectedUnits()

	WaitSeconds(4.0)

	-- call the func
	func()

	WaitSeconds(1.0)

	-- allow normal damage and other odd behaviors
	CleanupProtectedUnits()

	-- unlock input
	UnlockInput()

	-- fade in
	Sync.NISFadeIn = { ["seconds"] = 1.0 }
end


---------------------------------------------------------------------
-- StartCameraSequence
function StartCameraSequence(bBlackBars, bLockInput, nStartFOV)
	-- if required, prevent input
	if bLockInput then
		LockInput()
	end

	-- set the camera
	if not ScenarioInfo.Camera then
		ScenarioInfo.Camera = import('/lua/sim/simcamera.lua').SimCamera('WorldCamera')
	end

	-- force the camera to use the GameClock
	ScenarioInfo.Camera:UseGameClock()

	-- flag that we are in NIS mode
	ScenarioInfo.OpNISActive = true

	-- if required, setup the black bars
	if bBlackBars then
		Sync.NISMode = 'on'
	end

	-- enable absoluteCoords and FOV
	local FOV = nStartFOV or 60.0
	ScenarioInfo.Camera:UseAbsoluteCoords(true)
	ScenarioInfo.Camera:UseAbsoluteFov(true)
	WaitTicks(1)
	ScenarioInfo.Camera:SetAbsoluteFov(FOV)

	-- save camera settings
	ScenarioInfo.Camera:SaveSettings()

	-- protect normal units from damage and other odd behaviors
	SetupProtectedUnits()

	import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').FlushDialogueQueue(true)

	-- return a handle to the camera
	return ScenarioInfo.Camera
end

---------------------------------------------------------------------
-- EndCameraSequence
function EndCameraSequence(bBlackBars, bRestoreInput, bUseCDRPos, bNoRestore, bFlushIntel, nOverrideZoom, nFinalDuration)
	-- restore camera settings
	local finalZoom = nOverrideZoom or nil
	local finalDuration = nFinalDuration or 1.0

	if bUseCDRPos then

		-- disable absoluteCoords and FOV
		ScenarioInfo.Camera:SetAbsoluteFov(60.0)
		WaitTicks(1)
		ScenarioInfo.Camera:UseAbsoluteCoords(false)
		ScenarioInfo.Camera:UseAbsoluteFov(false)

		-- then move, using the override position
		ScenarioInfo.Camera:RestoreSettings(ScenarioInfo.PLAYER_CDR:GetPosition(), finalZoom, finalDuration)
		WaitSeconds(finalDuration)
	else
		-- disable absoluteCoords and FOV
		ScenarioInfo.Camera:SetAbsoluteFov(60.0)
		WaitTicks(1)
		ScenarioInfo.Camera:UseAbsoluteCoords(false)
		ScenarioInfo.Camera:UseAbsoluteFov(false)

		if not bNoRestore then
			-- move using the saved position info
			ScenarioInfo.Camera:RestoreSettings(nil, finalZoom, 0.0)
		end
	end

	-- if required, remove the black bars
	if bBlackBars then
		Sync.NISMode = 'off'
	end

	-- destroy any NIS only entities
	DestroyNISOnlyEntities()

	-- cleanup any NIS only transports
	CleanupNISOnlyTransports()

	-- if required, flush intel
	if bFlushIntel then
		WaitTicks(1)
		FlushIntelInRect( 0, 0, 1024, 1024 )
	end

	-- if required, reset the shadow depth override
	if ScenarioInfo.NISShadowDepthOverride then
		ScenarioInfo.NISShadowDepthOverride = nil

		---NOTE: this might not be safe for ship - retail valid? works without cheats enabled? - several unclear details - bfricks 12/2/09
		import('/lua/system/Utilities.lua').UserConRequest('shadowDepthOverride false')
	end

	-- if required, allow input
	if bRestoreInput then
		UnlockInput()
	end

	-- force the camera to use the SystemClock
	ScenarioInfo.Camera:UseSystemClock()

	-- flag that we are no longer in NIS mode
	ScenarioInfo.OpNISActive = false

	-- allow normal damage and other odd behaviors
	CleanupProtectedUnits()

	-- restore combat, if needed
	RestoreAllUnitAttackers()

	-- unset the camera
	ScenarioInfo.Camera = nil
end

---------------------------------------------------------------------
-- GetPos
-- return a position in the form of a table for the specified <obj>.
--		if <obj> is a string, the function assumes you are giving it a marker name.
--		otherwise, the function assumes you are giving it a unit.
function GetPos(obj)
	if type(obj) == 'string' then
		return import('/lua/sim/ScenarioUtilities.lua').GetMarker(obj).position
	else
		return obj:GetPosition()
	end
end

---------------------------------------------------------------------
-- GetOrient
-- return an hpr orientation vector in the form of a table for the specified <obj>.
--		if <obj> is a string, the function assumes you are giving it a marker name.
--		otherwise, the function assumes you are giving it a unit (where we use the unit's heading).
function GetOrient(obj)
	if type(obj) == 'string' then
		return import('/lua/sim/ScenarioUtilities.lua').GetMarker(obj).orientation
	else
		return {obj:GetHeading(),0.0,0.0,}
	end
end

---------------------------------------------------------------------
-- GetTerrainPosAtRectCenter
--		if <rect> is a string, the function assumes you are giving it an area name.
--		otherwise, the function assumes you are giving it a valid rect.
function GetTerrainPosAtRectCenter(rect)
	if type(rect) == 'string' then
		rect = import('/lua/sim/ScenarioUtilities.lua').AreaToRect(rect)
	end

	local pos = {0,0,0,}
	pos[1] = rect.x0 + ((rect.x1 - rect.x0)/2)
	pos[3] = rect.y0 + ((rect.y1 - rect.y0)/2)
	pos[2] = GetTerrainHeight(pos[1], pos[3])
	return pos
end

---------------------------------------------------------------------
-- GetRectCenterZoomHeight
--		if <rect> is a string, the function assumes you are giving it an area name.
--		otherwise, the function assumes you are giving it a valid rect.
function GetRectCenterZoomHeight(rect, nZoomMult)
	if type(rect) == 'string' then
		rect = import('/lua/sim/ScenarioUtilities.lua').AreaToRect(rect)
	end

	local xDist = math.abs(rect.x1 - rect.x0)
	local yDist = math.abs(rect.y1 - rect.y0)

	return ((xDist > yDist) and xDist or yDist) * nZoomMult
end

--------------------------------------------------------------------------------
-- @name			- CreateNISQueue
-- @author			- Bret Alfieri
-- @brief 			- Creates a queue "class" for managing NIS squences.
--					***NOTE: assumes all NIS are called in a new thread.
--------------------------------------------------------------------------------
function CreateNISQueue()

	local List = {
		-- Private Data:
		Head = 0,	-- Index location of Head
		Tail = -1	-- Index location of Tail
	}
	----------------------------------------------------------------------------
	-- @name			- AddStartNIS
	-- @brief 			- Adds an NIS start function to the queue
	-- @param[in] data	- A table.
	--					  {
	--						fnc,	-- NIS start function
	--						params	-- table of NIS start function parameters
	--					  }
	----------------------------------------------------------------------------
	function AddStartNIS(data)
		-- Debug ---------
		--print("Added")
		--WaitSeconds(1.0)
		------------------

		-- Increment the number of items in the list
		List.Tail = List.Tail + 1
		-- Add <value> to <List> at index <List.ItemCount>
		List[List.Tail] = data
		RunNIS(List.Tail)
	end
	----------------------------------------------------------------------------
	-- @name			- RemoveNIS
	-- @brief 			- Removes an NIS from the queue
	----------------------------------------------------------------------------
	function RemoveNIS()
		-- Debug ---------
		--print("Deleted")
		--WaitSeconds(1.0)
		------------------

		-- Disallow popping from an empty queue
		if IsEmpty() then
			WARN("Calling PopFront on an empty Queue")
			return
		end

		-- Pop value off the front of the queue
		local popVal = List[List.Head]
		-- Remove that value from the list
		List[List.Head] = nil
		-- Decrement the item count
		List.Head = List.Head + 1
	end
	----------------------------------------------------------------------------
	-- @name			- ClearAll
	-- @brief 			- Removes all NIS from the queue
	----------------------------------------------------------------------------
	function ClearAll()
		while(not IsEmpty()) do
			RemoveNIS()
		end
	end
	----------------------------------------------------------------------------
	-- @name			- IsEmpty
	-- @brief 			- Checks if the queue is empty
	-- @return			- True if the queue is empty, false otherwise
	----------------------------------------------------------------------------
	function IsEmpty()
		return List.Tail < List.Head
	end
	----------------------------------------------------------------------------
	-- @name			- RunNIS
	-- @brief 			- Runs the NIS if it's the only NIS at the head of the queue,
	--					  otherwise it waits until it's at the head.
	-- @param[in] index	- Index of the NIS to run in the queue
	----------------------------------------------------------------------------
	function RunNIS(index)
		-- While NIS at index is not at the head of the queue, wait
		while(index ~= List.Head) do
			WaitSeconds(0.1)
		end
		-- Run the NIS
		List[index].fnc(unpack(List[index].params))

		-- Debug ---------
		--print("Running")
		--WaitSeconds(1.0)
		------------------
	end

	-- Debug ---------
	function GetHead()
		return List.Head
	end
	function GetTail()
		return List.Tail
	end
	------------------

	-- Return queue "object"
	return {
		AddStartNIS = AddStartNIS,
		RemoveNIS 	= RemoveNIS,
		ClearAll 	= ClearAll,
		IsEmpty		= IsEmpty,
		GetHead		= GetHead,
		GetTail		= GetTail
	}

end
