--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameUtilsTransport.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for SC2 transports.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local TriggerFile		= import('/lua/sim/ScenarioTriggers.lua')
local ScenarioUtils		= import('/lua/sim/ScenarioUtilities.lua')

---------------------------------------------------------------------
-- AddUnitsToTransportStorage:
function AddUnitsToTransportStorage(units, transports)
    local numTransports = table.getn(transports)
    local currentTransport = 1

    for k,v in units do
        if not transports[currentTransport]:TransportAddUnitToStorage(v) then
            WARN('*SCENARIO FRAMEWORK WARNING: Could not add unit to transport storage.')
        end
        if currentTransport == numTransports then
            currentTransport = 1
        else
            currentTransport = currentTransport + 1
        end
    end
end
---------------------------------------------------------------------
-- SpawnTransportDeployGroup:
--	Create a transport and platoon. Load them up, send them out, and get them sorted out with subsequent commands and cleanup.
--	The bSkip variable is used by NIS skipping functions to auto-advance the transport to the deployment phase.
--
--	Data setup:
--	TransportUtils.SpawnTransportDeployGroup(
--		{
--			armyName				= <strArmyName>,	-- name of the army for whom the transport and group are being created
--			units					= <str/group>,		-- if a string, group name of units to be spawned as platoon, otherwise the units to be added to storage
--			transport				= <str/unit>,		-- if a string, the name of transport unit to create, otherwise the actual
--			approachChain			= <chain> or nil,	-- optional chainName for the approach travel route
--			unloadDest				= <marker>,			-- destination for the transport drop-off
--			returnDest				= <marker> or nil,	-- optional destination for where the transports will fly-away
--			bSkipTransportCleanup	= true or false,	-- will this transport be deleted when near returnDest?
--			platoonMoveDest			= <marker> or nil,	-- optional destination for the group to be moved to after being dropped-off
--			OnCreateCallback		= <func> or nil,	-- optional function to call for the transport and spawned platoon after they are created
--			onUnloadCallback		= <func> or nil,	-- optional function to call when the transport finishes unloading
--		}
--	)
--
---------------------------------------------------------------------
function SpawnTransportDeployGroup(data, bSkip)
	ForkThread(SpawnTransportDeployGroupThread, data, bSkip)
end

---------------------------------------------------------------------
-- SpawnTransportDeployGroupThread:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function SpawnTransportDeployGroupThread(data, bSkip)
	local aiBrain = GetArmyBrain(data.armyName)

	-- spawn the transported group, if needed
	local units = {}
	if type(data.units) == 'string' then
		units = ScenarioUtils.CreateArmyGroup(data.armyName, data.units)
	elseif data.units then
		units = data.units
	else
		error('SpawnTransportDeployGroupThread failure - invalid data.units. It must be either a string name of an editor defined group of units, or a valid group handle.')
		return
	end

	-- spawn the transport, if needed
	local transport
	if type(data.transport) == 'string' then
		transport = ScenarioUtils.CreateArmyUnit(data.armyName, data.transport)
	elseif data.transport then
		transport = data.transport
	else
		error('SpawnTransportDeployGroupThread failure - invalid data.transport. It must be a string name of an editor defined unit, or a valid unit handle.')
		return
	end

	-- put the units in a platoon
	local platoon = aiBrain:MakePlatoon('','')
	aiBrain:AssignUnitsToPlatoon( platoon, units, 'Attack', 'AttackFormation' )

	if data.OnCreateCallback then
		data.OnCreateCallback(transport, platoon)
	end

	-- attach, issue an unload, and quueue up a subsequent return for the transport.
	-- If a data.approachChain has been passed in, then queue up that route prior to the final
	-- unlead destination.

	---NOTE: this function will now force the storage to allow for all passed in units - bfricks 11/27/09
	local count = table.getn(units)
	transport:SetNumberOfStorageSlots(count)
	for k, unit in units do
		transport:TransportAddUnitToStorage(unit)
	end

	if bSkip then
		IssueClearCommands({transport})
		Warp(transport, ScenarioUtils.MarkerToPosition(data.unloadDest))
		WaitTicks(1)
	elseif data.approachChain then
		for k, v in ScenarioUtils.ChainToPositions(data.approachChain) do
			IssueMove({transport}, v)
		end
	end

    -- This is a redundant move; IssueTransportUnload has a move built into it. See dstaltman for info
    -- This should not have been an issue, but something is causing the move command to not complete
	-- IssueMove({transport}, ScenarioUtils.MarkerToPosition(data.unloadDest))

	IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(data.unloadDest))
	local attached = true
	while attached do
		WaitTicks(1)
		if transport:IsDead() then
			return
		end
		attached = false
		for num, unit in units do
			if not unit:IsDead() and unit:IsUnitState('Attached') then
				attached = true
				break
			end
		end
	end

	IssueClearCommands({transport})
	if bSkip and not data.bSkipTransportCleanup then
		-- if we intend on skipping - go ahead and delete the transport now
		if transport and not transport:IsDead() then
			transport:Destroy()
		end
	elseif data.returnDest then
		IssueMove({transport}, ScenarioUtils.MarkerToPosition(data.returnDest))
		if not data.bSkipTransportCleanup then
			TriggerFile.CreateUnitToPositionDistanceTrigger(
				function()
					-- Delete a passed in unit
					if transport and not transport:IsDead() then
						transport:Destroy()
					end
				end,
				transport,
				ScenarioUtils.MarkerToPosition(data.returnDest),
				10
			)
		end
	end


	if data.platoonMoveDest then
		IssueFormMove( units, ScenarioUtils.MarkerToPosition(data.platoonMoveDest), 'AttackFormation', 180 )
	end

	if data.onUnloadCallback then
		data.onUnloadCallback(platoon)
	end
end
