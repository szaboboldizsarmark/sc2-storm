--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameUtilsCarrier.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for scenario management of aircraft carriers.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---------------------------------------------------------------------
-- COMMON FUNCTIONS:
---------------------------------------------------------------------
local CreateUnitDestroyedTrigger	= import('/lua/sim/ScenarioTriggers.lua').CreateUnitDestroyedTrigger
local GetPatrolChainAroundUnit		= import('/lua/sim/ScenarioFramework.lua').GetPatrolChainAroundUnit
local GroupPatrolRoute				= import('/lua/sim/ScenarioFramework.lua').GroupPatrolRoute
local GetEnemyUnitsInSphere			= import('/lua/system/utilities.lua').GetEnemyUnitsInSphere
local GetRandomPatrolRoute 			= import('/lua/AI/ScenarioPlatoonAI.lua').GetRandomPatrolRoute

---------------------------------------------------------------------
-- NOTES:
---------------------------------------------------------------------
-- High level, this is a small module for just managing aircraft carriers.
-- Each function in this file leverages adding a table to the carrier and all spawned units: ScenarioUnitData
-- Additionally, many functions in this file are designed to really only be used within the scope of this module

-- Below is a breakdown of this table, as used by this file:
-- <unit>.ScenarioUnitData = {}
-- <unit>.ScenarioUnitData.IsSpawningStoredUnit		= boolean tracking flag indicating if the specified <unit> is spawning
-- <unit>.ScenarioUnitData.IsLoading				= boolean tracking flag indicating if the specified <unit> is loading up
-- <unit>.ScenarioUnitData.ForceCleared				= boolean tracking flag indicating if the specified <unit> has been force cleared recently
-- <unit>.ScenarioUnitData.UnderThreat				= boolean tracking flag indicating if the specified <unit> is under threat
-- <unit>.ScenarioUnitData.HasUnloaded				= boolean tracking flag for if we have already unloaded
-- <unit>.ScenarioUnitData.CurrenntPatrolPoint		= tracking value for the current position of the CarrierPatrol
-- <unit>.ScenarioUnitData.StoredUnitList			= table listing the children for the specified <unit>
-- <unit>.ScenarioUnitData.StoredUnitParent			= unit handle to carrier that spawned the specified <unit>
-- <unit>.ScenarioUnitData.MaxAliveChildCount		= number of children max for the specified <unit>
-- <unit>.ScenarioUnitData.SpawnDelay				= standard spawn delay for the given carrier <unit>
-- <unit>.ScenarioUnitData.UnitType					= string version of the unit ID for the specified <unit>
-- <unit>.ScenarioUnitData.ArmyName					= string name of the unit army <unit>
-- <unit>.ScenarioUnitData.ThreatRadius				= threat radius for the carrier <unit>
-- <unit>.ScenarioUnitData.DeathPatrol				= optional patrol to use for children when the parent carrier <unit> dies
-- <unit>.ScenarioUnitData.CarrierPatrol			= optional patrol used by the carrier - handled in a manner that works with building and rebuilding units
-- <unit>.ScenarioUnitData.UnloadOnly				= optional to restrict the carrier from ever trying to reload

-- the general usage case, is to simply call the highest level faction functions:
--		SetupUEFAircraftCarrier (for the SC2 UEF Atlantis)
--		SetupCYBAircraftCarrier (for the SC2 Cybran Aircraft Carrier UCS0901)
--
-- 		each of these functions will automatically manage the following:
--			when called, the carrier will begin filling its storage with the desired units
--			when threatened, the carrier will auto-unload these units - who will then guard the carrier
--			when no longer threatened, the carrier will re-load these units
--			when the carrier dies, the units will patrol using the final position of the unit - and a hardcoded radius

-- the other common cases will be to force a carrier to unload/ load or adjust its ThreatRadius

---------------------------------------------------------------------
-- EXTERNAL FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- SetupUEFAircraftCarrier:
--
--	Data setup:
--	SetupUEFAircraftCarrier(
--		{
--			carrierUnit			= <unit>,				-- unit to be used as the parent carrier
--			nMaxGunshipCount	= <int>,				-- number of gunships to maintain
--			nMaxFighterCount	= <int>,				-- number of fighters to maintain
--			nMaxBomberCount		= <int>,				-- number of bombers to maintain
--			nSpawnDelay			= <float>,				-- time between each spawn
--			strArmyName			= <string>,				-- name of the army for the carrier and its children
--			nThreatRadius		= <float>,				-- radius about the carrier to be considered the threat range
--			onDeathPatrolChain	= <string OR pos list>,	-- optional patrol when a carrier dies, otherwise, all children scatter-patrol
--			CarrierPatrol		= <string OR pos list>,	-- optional patrol for the carrier to follow, works in unison with building and unloading
--			UnloadOnly			= <bool>,				-- optional flag to allow a carrier to unload once and then proceed
--		}
--	)
--
function SetupUEFAircraftCarrier(data)
	WARN('SetupUEFAircraftCarrier is being called - this function is incomplete!')
end

---------------------------------------------------------------------
-- SetupCybranAircraftCarrier:
--
--	Data setup:
--	SetupCYBAircraftCarrier(
--		{
--			carrierUnit			= <unit>,				-- unit to be used as the parent carrier
--			nMaxGunshipCount	= <int>,				-- number of gunships to maintain
--			nMaxFighterCount	= <int>,				-- number of fighter-bombers to maintain
--			nSpawnDelay			= <float>,				-- time between each spawn
--			strArmyName			= <string>,				-- name of the army for the carrier and its children
--			nThreatRadius		= <float>,				-- radius about the carrier to be considered the threat range
--			onDeathPatrolChain	= <string OR pos list>,	-- optional patrol when a carrier dies, otherwise, all children scatter-patrol
--			CarrierPatrol		= <string OR pos list>,	-- optional patrol for the carrier to follow, works in unison with building and unloading
--			UnloadOnly			= <bool>,				-- optional flag to allow a carrier to unload once and then proceed
--		}
--	)
--
function SetupCYBAircraftCarrier(data)
	-- unwrap data
	local carrierUnit			= data.carrierUnit
	local nMaxGunshipCount		= data.nMaxGunshipCount or 0
	local nMaxFighterCount		= data.nMaxFighterCount or 0
	local nSpawnDelay			= data.nSpawnDelay or 0.0
	local strArmyName			= data.strArmyName
	local nThreatRadius			= data.nThreatRadius
	local onDeathPatrolChain	= data.onDeathPatrolChain
	local CarrierPatrol			= data.CarrierPatrol
	local UnloadOnly			= data.UnloadOnly
	local HasUnloaded			= false

	if not carrierUnit or carrierUnit:IsDead() then WARN('WARNING: SetupCybranAircraftCarrier is exiting early due to a dead or invalid carrierUnit!') return end
	if not strArmyName then WARN('WARNING: SetupCybranAircraftCarrier is exiting early due to a missing strArmyName!') return end

	-- define the max storage capacity
	local MaxAliveChildCount = nMaxGunshipCount + nMaxFighterCount

	-- if required, append the parent with a table for storing scenario unit data
	if not carrierUnit.ScenarioUnitData then
		carrierUnit.ScenarioUnitData = {}
	end

	-- set the parent's stored data
	carrierUnit.ScenarioUnitData.MaxAliveChildCount		= MaxAliveChildCount
	carrierUnit.ScenarioUnitData.SpawnDelay				= nSpawnDelay
	carrierUnit.ScenarioUnitData.ArmyName				= strArmyName
	carrierUnit.ScenarioUnitData.ThreatRadius			= nThreatRadius
	carrierUnit.ScenarioUnitData.DeathPatrol			= onDeathPatrolChain
	carrierUnit.ScenarioUnitData.CarrierPatrol			= CarrierPatrol
	carrierUnit.ScenarioUnitData.UnloadOnly				= UnloadOnly

	-- start building the fighters
	---NOTE: for the first time we create children, the spawnDelay is set to 0.0 - bfricks 7/23/09
	if nMaxFighterCount and nMaxFighterCount > 0 then
		CreateAndStoreUnit('uca0104', strArmyName, carrierUnit, 0.0, nMaxFighterCount, GetStartingChildAction, HandleChildDeath)
	end

	-- start building the gunships
	if nMaxGunshipCount and nMaxGunshipCount > 0 then
		CreateAndStoreUnit('uca0103', strArmyName, carrierUnit, 0.0, nMaxGunshipCount, GetStartingChildAction, HandleChildDeath)
	end

	-- add a destroyed trigger
	CreateUnitDestroyedTrigger(HandleCarrierDeath, carrierUnit)

	-- add a watch thread
	StartCarrierWatch(carrierUnit)

	-- if required, add a patrol thread
	if CarrierPatrol then
		StartCarrierPatrol(carrierUnit)
	end
end

---------------------------------------------------------------------
-- SetCarrierThreatRadius:
function SetCarrierThreatRadius(carrierUnit, nThreatRadius)
	if not carrierUnit or carrierUnit:IsDead() then WARN('WARNING: SetCarrierThreatRadius is exiting early due to a dead or invalid carrierUnit!') return end
	if not carrierUnit.ScenarioUnitData then WARN('WARNING: SetCarrierThreatRadius is exiting early, carrier must be setup with valid ScenarioUnitData!') return end

	-- set the threat radius
	carrierUnit.ScenarioUnitData.ThreatRadius = nThreatRadius
end

---------------------------------------------------------------------
-- UpdateCarrierPatrol:
function UpdateCarrierPatrol(carrierUnit, newPatrol)
	if not carrierUnit or carrierUnit:IsDead() then WARN('WARNING: UpdateCarrierPatrol is exiting early due to a dead or invalid carrierUnit!') return end
	if not carrierUnit.ScenarioUnitData then WARN('WARNING: UpdateCarrierPatrol is exiting early, carrier must be setup with valid ScenarioUnitData!') return end

	-- stop the carrier - DO NOT CLEAR THE COMMAND QUEUE
	IssueStop({carrierUnit})

	-- get a handle to the old patrol
	local oldPatrol = carrierUnit.ScenarioUnitData.CarrierPatrol

	-- clear out and update the current patrol point and patrol
	carrierUnit.ScenarioUnitData.CurrenntPatrolPoint = nil
	carrierUnit.ScenarioUnitData.CarrierPatrol = newPatrol

	-- if there was no patrol thread at all before - then give it one now
	if not oldPatrol then
		StartCarrierPatrol(carrierUnit)
	end
end

---------------------------------------------------------------------
-- CarrierUnload:
function CarrierUnload(carrierUnit, callbackOnComplete, enemyList)
	ForkThread(CarrierUnloadThread, carrierUnit, callbackOnComplete, enemyList)
end

---------------------------------------------------------------------
-- CarrierLoad:
function CarrierLoad(carrierUnit)
	ForkThread(CarrierLoadThread, carrierUnit)
end

---------------------------------------------------------------------
-- INTERNAl FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- GetMaxAliveChildCount:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function GetMaxAliveChildCount(parentUnit)
	local count = 0
	if parentUnit and parentUnit.ScenarioUnitData then
		count = parentUnit.ScenarioUnitData.MaxAliveChildCount or 0
	end

	return count
end

---------------------------------------------------------------------
-- GetStoredAliveChildCount:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function GetStoredAliveChildCount(parentUnit)
	local count = 0
	local list = GetStoredChildList(parentUnit)
	if list then
		for k, unit in list do
			if unit and not unit:IsDead() then
				count = count + 1
			end
		end
	end

	return count
end

---------------------------------------------------------------------
-- GetStoredChildList:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function GetStoredChildList(parentUnit)
	local list = nil
	if parentUnit and parentUnit.ScenarioUnitData and parentUnit.ScenarioUnitData.StoredUnitList then
		list = parentUnit.ScenarioUnitData.StoredUnitList
	end

	return list
end

---------------------------------------------------------------------
-- GetStoredUnitParent:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function GetStoredUnitParent(childUnit)
	local parentUnit = nil
	if childUnit and childUnit.ScenarioUnitData then
		parentUnit = childUnit.ScenarioUnitData.StoredUnitParent
	end

	return parentUnit
end

---------------------------------------------------------------------
-- CarrierLoadThread:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function CarrierLoadThread(carrierUnit)
	if not carrierUnit or carrierUnit:IsDead() then WARN('WARNING: CarrierLoad is exiting early due to a dead or invalid carrierUnit!') return end
	if not carrierUnit.ScenarioUnitData then WARN('WARNING: CarrierLoad is exiting early, carrier must be setup with valid ScenarioUnitData!') return end

	-- if we are not allowed to reload - early out
	if carrierUnit.ScenarioUnitData.UnloadOnly then
		return
	end

	local passengers = carrierUnit.ScenarioUnitData.StoredUnitList

	if passengers and table.getn(passengers) > 0 then
		carrierUnit.ScenarioUnitData.ForceCleared = true
		carrierUnit.ScenarioUnitData.IsLoading = true

		IssueClearCommands({carrierUnit})
		IssueStop({carrierUnit})

		IssueClearCommands(passengers)

		local unattachedPassengers = {}
		for k, unit in passengers do
			if unit and not unit:IsDead() and not unit:IsUnitState('Attached') then
				table.insert(unattachedPassengers,unit)
			end
		end

		if table.getn(unattachedPassengers) > 0 then
			IssueTransportLoad(unattachedPassengers, carrierUnit)

			local attached = false
			while not attached do
				---LOG('```````````````````LOADING')
				WaitSeconds(1)
				if carrierUnit:IsDead() then
					return
				end

				attached = true
				for num, unit in passengers do
					-- if any alive unit is unattached - fall through
					if not unit:IsDead() and not unit:IsUnitState('Attached') then
						attached = false
						break
					end
				end
			end
		end

		carrierUnit.ScenarioUnitData.IsLoading = false
	end
end

---------------------------------------------------------------------
-- CarrierUnloadThread:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function CarrierUnloadThread(carrierUnit, callbackOnComplete, enemyList)
	if not carrierUnit or carrierUnit:IsDead() then WARN('WARNING: CarrierUnload is exiting early due to a dead or invalid carrierUnit!') return end
	if not carrierUnit.ScenarioUnitData then WARN('WARNING: CarrierUnload is exiting early, carrier must be setup with valid ScenarioUnitData!') return end

	-- early out if we have already unloaded - no need to proceed
	if carrierUnit.ScenarioUnitData.UnloadOnly and carrierUnit.ScenarioUnitData.HasUnloaded	then
		return
	end

	local passengers = carrierUnit.ScenarioUnitData.StoredUnitList

	if passengers and table.getn(passengers) > 0 then
		carrierUnit.ScenarioUnitData.ForceCleared = true
		IssueClearCommands({carrierUnit})
		IssueTransportUnload({carrierUnit}, carrierUnit:GetPosition())

		local attached = true
		while attached do
			WaitSeconds(1)
			if carrierUnit:IsDead() then
				return
			end
			attached = false
			for num, unit in passengers do
				-- if any alive unit is attached - fall through
				if not unit:IsDead() and unit:IsUnitState('Attached') then
					attached = true
					break
				end
			end
		end

		IssueClearCommands(passengers)

		if enemyList then
			---LOG('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~enemyList DETECTED')
			for k, unit in enemyList do
				if unit and not unit:IsDead() then
					---LOG('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~enemyList LOCATED')
					IssueAggressiveMove(passengers,unit:GetPosition())
					break
				end
			end
		end

		IssueGuard(passengers,carrierUnit)
	end

	carrierUnit.ScenarioUnitData.HasUnloaded = true

	if callbackOnComplete then
		callbackOnComplete(carrierUnit, passengers)
	end
end

---------------------------------------------------------------------
-- HandleCarrierDeath:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function HandleCarrierDeath(carrierUnit)
	if not carrierUnit then WARN('WARNING: HandleCarrierDeath is exiting early due to a dead or invalid carrierUnit!') return end
	if not carrierUnit.ScenarioUnitData then WARN('WARNING: HandleCarrierDeath is exiting early, carrier must be setup with valid ScenarioUnitData!') return end

	local passengers = carrierUnit.ScenarioUnitData.StoredUnitList

	local chain = carrierUnit.ScenarioUnitData.DeathPatrol

	if not chain then
		-- since no chain is specified, form a scatter-patrol around the location of the dead carrier
		chain = GetPatrolChainAroundUnit(carrierUnit, 40.0)

		for k, unit in passengers do
			IssueClearCommands({unit})
			GroupPatrolRoute({unit},GetRandomPatrolRoute(chain))
		end
	else
		-- if the chain is a string, build a position list
		if type(chain) == 'string' then
			chain = ScenarioUtils.ChainToPositions(chain)
		end

		IssueClearCommands(passengers)
		GroupPatrolRoute(passengers, chain)
	end
end

---------------------------------------------------------------------
-- StartCarrierWatch:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function StartCarrierWatch(carrierUnit)
	ForkThread(StartCarrierWatchThread, carrierUnit)
end
function StartCarrierWatchThread(carrierUnit)
	if not carrierUnit or carrierUnit:IsDead() then WARN('WARNING: StartCarrierWatch is exiting early due to a dead or invalid carrierUnit!') return end
	if not carrierUnit.ScenarioUnitData then WARN('WARNING: StartCarrierWatch is exiting early, carrier must be setup with valid ScenarioUnitData!') return end

	-- start by flagging the carrier as not under threat
	carrierUnit.ScenarioUnitData.UnderThreat = false

	-- use this variable to allow us to generate a list of enemies that we target when unloaded
	local enemyList = nil

	-- loop a check to see if we are under threat
	while not carrierUnit.ScenarioUnitData.UnderThreat do
		-- early out if the carrier is dead
		if not carrierUnit or carrierUnit:IsDead() then return end

		-- get a list of all the enemies
		local radius = carrierUnit.ScenarioUnitData.ThreatRadius or 50.0
		local enemies = GetEnemyUnitsInSphere(carrierUnit, carrierUnit:GetPosition(), radius)

		local count = 0
		if enemies then
			count = table.getn(enemies)
		end

		---LOG('TESTING:-------StartCarrierWatchThread: carrierUnit.ScenarioUnitData.UnderThreat == FALSE. count:[', count, ']')

		if count > 0 then
			carrierUnit.ScenarioUnitData.UnderThreat = true
			enemyList = enemies
		else
			enemyList = nil
			WaitSeconds(3.0)
		end
	end

	-- if the carrier is still alive, unload
	if carrierUnit and not carrierUnit:IsDead() then
		-- we call the thread directly here, because we want to allow this entire function to be on hold while the unload transpires
		CarrierUnloadThread(carrierUnit, nil, enemyList)
	else
		return
	end

	while carrierUnit.ScenarioUnitData.UnderThreat do
		-- early out if the carrier is dead
		if not carrierUnit or carrierUnit:IsDead() then return end

		-- get a list of all the enemies
		local radius = carrierUnit.ScenarioUnitData.ThreatRadius or 50.0
		local enemies = GetEnemyUnitsInSphere(carrierUnit, carrierUnit:GetPosition(), radius)

		local count = 0
		if enemies then
			count = table.getn(enemies)
		end

		---LOG('TESTING:-------StartCarrierWatchThread: carrierUnit.ScenarioUnitData.UnderThreat == TRUE. count:[', count, ']')

		if count < 1 then
			carrierUnit.ScenarioUnitData.UnderThreat = false
		else
			WaitSeconds(3.0)
		end
	end

	-- wait for a brief sanity period
	WaitSeconds(5.0)

	-- if the carrier is still alive, load up
	if carrierUnit and not carrierUnit:IsDead() then
		-- we call the thread directly here, because we want to allow this entire function to be on hold while the load transpires
		CarrierLoadThread(carrierUnit)
	else
		return
	end

	-- wait for a brief sanity period
	WaitSeconds(1.0)

	-- if the carrier is still alive, repeat the process
	if carrierUnit and not carrierUnit:IsDead() then
		StartCarrierWatch(carrierUnit)
	else
		return
	end
end

---------------------------------------------------------------------
-- StartCarrierPatrol:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function StartCarrierPatrol(carrierUnit)
	ForkThread(StartCarrierPatrolThread, carrierUnit)
end

function StartCarrierPatrolThread(carrierUnit)
	if not carrierUnit or carrierUnit:IsDead() then WARN('WARNING: StartCarrierPatrol is exiting early due to a dead or invalid carrierUnit!') return end
	if not carrierUnit.ScenarioUnitData then WARN('WARNING: StartCarrierPatrol is exiting early, carrier must be setup with valid ScenarioUnitData!') return end
	if not carrierUnit.ScenarioUnitData.CarrierPatrol then WARN('WARNING: StartCarrierPatrol is exiting early due to an invalid CarrierPatrol!') return end


	while carrierUnit and not carrierUnit:IsDead() do
		-- get the patrol chain (which may have updated since our last runthrough)
		local patrolChain = ScenarioUtils.ChainToPositions(carrierUnit.ScenarioUnitData.CarrierPatrol)

		-- if needed, set the currentPatrolPoint, otherwise increment it
		if not carrierUnit.ScenarioUnitData.CurrenntPatrolPoint then
			carrierUnit.ScenarioUnitData.CurrenntPatrolPoint = 1
		elseif not carrierUnit.ScenarioUnitData.ForceCleared then
			carrierUnit.ScenarioUnitData.CurrenntPatrolPoint = carrierUnit.ScenarioUnitData.CurrenntPatrolPoint + 1

			if carrierUnit.ScenarioUnitData.CurrenntPatrolPoint > table.getn(patrolChain) then
				carrierUnit.ScenarioUnitData.CurrenntPatrolPoint = 1
			end
		end

		---LOG('TESTING:-------StartCarrierPatrol: Moving to position:[', carrierUnit.ScenarioUnitData.CurrenntPatrolPoint, ']')
		local dest = patrolChain[carrierUnit.ScenarioUnitData.CurrenntPatrolPoint]
		local cmd = IssueAggressiveMove({carrierUnit}, dest)

		-- always reset this tracking value after to our move command - so if we are cleared while this cmd is operational we know not to
		--	increment our patrol position
		carrierUnit.ScenarioUnitData.ForceCleared = false

		while cmd and not IsCommandDone(cmd) do
			WaitSeconds(1.0)
		end

		if carrierUnit.ScenarioUnitData.IsLoading then
			-- wait for the carrier to finish loading before continuing
			while carrierUnit.ScenarioUnitData.IsLoading do
				WaitSeconds(1.0)
			end
		else
			-- wait for a brief sanity period
			WaitSeconds(1.0)
		end
	end
end

---------------------------------------------------------------------
-- GetStartingChildAction:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function GetStartingChildAction(childUnit, parentUnit)
	if not childUnit or childUnit:IsDead()  then WARN('WARNING: GetStartingChildAction is exiting early due to a dead or invalid parentUnit!') return end
	if not parentUnit or parentUnit:IsDead()  then WARN('WARNING: GetStartingChildAction is exiting early due to a dead or invalid parentUnit!') return end
	if not parentUnit.ScenarioUnitData then WARN('WARNING: GetStartingChildAction is exiting early, parentUnit must be setup with valid ScenarioUnitData!') return end

	local isUnderThreat = parentUnit.ScenarioUnitData.UnderThreat

	if isUnderThreat then
		---LOG('TESTING:-------GetStartingChildAction: isUnderThreat == TRUE.')
		CarrierUnload(parentUnit)
	end
end

---------------------------------------------------------------------
-- HandleChildDeath:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function HandleChildDeath(childUnit)
	local parentUnit = GetStoredUnitParent(childUnit)

	if parentUnit and not parentUnit:IsDead() and parentUnit.ScenarioUnitData then
		local curCount = GetStoredAliveChildCount(parentUnit)
		local maxCount = GetMaxAliveChildCount(parentUnit)

		if curCount < maxCount then
			local strChildType = childUnit.ScenarioUnitData.UnitType
			local strArmyName = childUnit.ScenarioUnitData.ArmyName
			local nSpawnDelay = parentUnit.ScenarioUnitData.SpawnDelay
			CreateAndStoreUnit(strChildType, strArmyName, parentUnit, nSpawnDelay, 1, GetStartingChildAction, HandleChildDeath)
		end
	end
end

---------------------------------------------------------------------
-- CreateAndStoreUnit:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function CreateAndStoreUnit(strChildType, strArmyName, parentUnit, nSpawnDelay, nChildCount, callbackonChildCreate, callbackOnChildDeath)
	---LOG('CreateAndStoreUnit: requesting:[', nChildCount, '] instances of:[', strChildType, '] for army:[', strArmyName, '] with a delay of:[', nSpawnDelay, ']')
	ForkThread(CreateAndStoreUnitThread, strChildType, strArmyName, parentUnit, nSpawnDelay, nChildCount, callbackonChildCreate, callbackOnChildDeath)
end

---------------------------------------------------------------------
-- CreateAndStoreUnitThread:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function CreateAndStoreUnitThread(strChildType, strArmyName, parentUnit, nSpawnDelay, nChildCount, callbackonChildCreate, callbackOnChildDeath)
	if not parentUnit or parentUnit:IsDead() then WARN('WARNING: CreateAndStoreUnitThread is exiting early due to a dead or invalid parentUnit!') return end

	-- if required, append the parent with a table for storing scenario unit data
	if not parentUnit.ScenarioUnitData then
		---LOG('TESTING:-------CreateAndStoreUnit: adding data table.')
		parentUnit.ScenarioUnitData = {}
	elseif parentUnit.ScenarioUnitData.IsSpawningStoredUnit then
		-- wait for the parent to be done spawning
		while parentUnit.ScenarioUnitData.IsSpawningStoredUnit do
			---LOG('TESTING:-------CreateAndStoreUnit: waiting.......')
			WaitTicks(10)
		end
	end

	-- if required, set the value of max alive children
	if not parentUnit.ScenarioUnitData.MaxAliveChildCount then
		parentUnit.ScenarioUnitData.MaxAliveChildCount = 15
	end

	-- if required, set the value of spawn delay
	if not parentUnit.ScenarioUnitData.SpawnDelay then
		parentUnit.ScenarioUnitData.SpawnDelay = nSpawnDelay or 0.0
	end

	for i = 1, nChildCount do
		-- early out if we have no more room
		local curChildCount = GetStoredAliveChildCount(parentUnit)
		local maxChildCount = parentUnit.ScenarioUnitData.MaxAliveChildCount
		if curChildCount >= parentUnit.ScenarioUnitData.MaxAliveChildCount then
			---LOG('CreateAndStoreUnitThread: early out, max storage[', curChildCount, '] of [', maxChildCount, '] reached.')
			break
		end

		---LOG('TESTING:-------CreateAndStoreUnit: starting to spawn.......')
		-- flag that the unit is spawning a child
		parentUnit.ScenarioUnitData.IsSpawningStoredUnit = true

		-- wait for the specified delay, before proceeding
		if nSpawnDelay and nSpawnDelay > 0.0 then
			WaitSeconds(nSpawnDelay)
		end

		local childUnit = nil
		if parentUnit and not parentUnit:IsDead() then
			-- determine the parent position
			local pos = parentUnit:GetPosition()
			pos[2] = GetTerrainHeight(pos[1], pos[3])

			-- create the child at the position
			childUnit = CreateUnitHPR(strChildType, strArmyName, pos[1], pos[2], pos[3],  0, 0, 0)

			-- hide the newly created unit
			childUnit:HideMesh()

			-- if required, add or clean a list for tracking all stored units
			if not parentUnit.ScenarioUnitData.StoredUnitList then
				parentUnit.ScenarioUnitData.StoredUnitList = {}
			else
				-- build a new list of only the living children
				local newList = {}
				for k, child in parentUnit.ScenarioUnitData.StoredUnitList do
					if child and not child:IsDead() then
						table.insert(newList, child)
					end
				end

				-- replace the old list with the new list
				parentUnit.ScenarioUnitData.StoredUnitList = newList

			end

			-- add the new child unit to our stored list
			table.insert(parentUnit.ScenarioUnitData.StoredUnitList, childUnit)

			-- add the new child to storage
			parentUnit:TransportAddUnitToStorage(childUnit)

			-- append the child with a table for storing scenario unit data
			childUnit.ScenarioUnitData = {}

			-- store additional data for this child - so it can be re-created easily when it dies
			childUnit.ScenarioUnitData.StoredUnitParent = parentUnit
			childUnit.ScenarioUnitData.UnitType = strChildType
			childUnit.ScenarioUnitData.ArmyName = strArmyName


			-- if required, call the create callback
			if callbackonChildCreate then
				---LOG('TESTING:-------CreateAndStoreUnit: callbackonChildCreate.')
				callbackonChildCreate(childUnit, parentUnit)
			end

			-- if required, add the death callback
			if callbackOnChildDeath then
				---LOG('TESTING:-------CreateAndStoreUnit: adding callbackOnChildDeath.')
				CreateUnitDestroyedTrigger(callbackOnChildDeath, childUnit)
			end
		else
			---LOG('TESTING:-------CreateAndStoreUnit: parent is dead, exiting out.')
			break
		end
	end

	-- flag that the unit is no longer spawning a child
	parentUnit.ScenarioUnitData.IsSpawningStoredUnit = false
	---LOG('TESTING:-------CreateAndStoreUnit: finished spawning.')
end