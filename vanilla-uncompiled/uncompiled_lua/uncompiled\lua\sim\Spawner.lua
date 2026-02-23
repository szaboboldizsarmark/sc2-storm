--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--****************************************************************************
--**
--**  File     :  /lua/sim/Spawner.lua
--**  Author(s):
--**
--**  Summary  :
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
--
-- The base Spawner lua class
--
local Entity = import('/lua/sim/Entity.lua').Entity

Spawner = Class {
    __init = function(self, spawnerData, callbackFn)
		self.Trash = TrashBag()
		self.mSpawnerName = spawnerData.spawnerName
		self.mSpawnUnit = spawnerData.spawnUnit
		self.mSpawnArmyName = spawnerData.spawnArmyName
		self.mSpawnMinTime = spawnerData.spawnMinTime
		self.mSpawnMaxTime = spawnerData.spawnMaxTime
		self.mSpawnRandomOffsetX = spawnerData.spawnRandomOffsetX or 0
		self.mSpawnRandomOffsetZ = spawnerData.spawnRandomOffsetZ or 0
		self.mActive = false
		self.mPosition = spawnerData.position
		self.mOrientation = spawnerData.orientation
		self.mPlatoonName = spawnerData.spawnPlatoonName
		self.mSpawnNumberPerRound = spawnerData.spawnNumberPerRound or 1
		self.mSpawnMaxRounds = spawnerData.spawnMaxRounds or -1
		self.mNumRoundsSpawned = 0
		self.mCallbackFn = callbackFn

		self.mSpawnAnimSet = {}
		local animSetFound = false
		for i=1,5 do
			if spawnerData["spawnAnim"..i] and spawnerData["spawnAnim"..i] ~= "" then
				table.insert( self.mSpawnAnimSet, spawnerData["spawnAnim"..i] )
				animSetFound = true
			end
		end

		if not animSetFound then
			self.mSpawnAnimSet = nil
		end

		if spawnerData.spawnStartActive then			
			self:Activate()
		end
    end,

    ForkThread = function(self, fn, ...)
		if fn then
			local thread = ForkThread(fn, self, unpack(arg))
			self.Trash:Add(thread)
			return thread
		else
			return nil
		end
	end,

	--[[
			Interface methods
			use these to interact with the spawner
	]]

	-- Set the min time to spawn a round of units
	SetSpawnMinTime =          function( self, v ) self.mSpawnMinTime = v or 1 end,
	-- Set the max time to spawn a round of units
	SetSpawnMaxTime =          function( self, v ) self.mSpawnMaxTime = v or 1 end,
	-- Set the number of units to spawn per round
	SetSpawnNumberPerRound =   function( self, v ) self.mSpawnNumberPerRound = v or 1 end,
	-- Set the number of rounds to spawn from this
	SetSpawnMaxRounds =        function( self, v ) self.mSpawnMaxRounds = v or -1 end,

	-- Set the unit to spawn (blueprint ID)
	SetSpawnUnit = function( self, v ) self.mSpawnUnit = v or self.mSpawnUnit end,

	GetPosition = function( self ) return self.mPosition end,

	-- returns if the spawner has run through all the rounds it was going to spawn
	IsEmpty = function( self )
		if self.mSpawnMaxRounds >= 0 then
			return self.mNumRoundsSpawned >= self.mSpawnMaxRounds
		end
		return false
	end,

	-- Activates a spawner and resets the number of rounds spawned
	Activate = function( self )
		self.mNumRoundsSpawned = 0
		if self.mActive then
			return
		end
		self.mActive = true
		self.mSpawnThread = self:ForkThread( self.LSpawnUnitThread )
	end,

	-- Deactivates a spawner
	Deactivate = function( self )
		if not self.mActive then
			return
		end
		KillThread(self.mSpawnThread)
		self.mActive = false
	end,

	-----------------------------

    OnDestroy = function(self)
    end,

	LSpawnUnitThread = function( self )
		while self.mActive do
			if self.mSpawnMaxRounds >= 0 and self.mNumRoundsSpawned >= self.mSpawnMaxRounds then
				self:Deactivate()
				break
			end

			local waittime = Random(self.mSpawnMinTime,self.mSpawnMaxTime )
			WaitSeconds( waittime )
			for i=1,self.mSpawnNumberPerRound do
				self:SpawnUnit()
			end
			self.mNumRoundsSpawned = self.mNumRoundsSpawned + 1
		end
	end,

	SpawnUnit = function(self)
		local strArmy = self.mSpawnArmyName
		local brain = GetArmyBrain(strArmy)
		if not brain.IgnoreArmyCaps then
			SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
		end

		
		local positionX = self.mPosition[1] + Random( -self.mSpawnRandomOffsetX, self.mSpawnRandomOffsetX )
		local positionZ = self.mPosition[3] + Random( -self.mSpawnRandomOffsetZ, self.mSpawnRandomOffsetZ )
		
		local unit = CreateUnit(
			self.mSpawnUnit,
			strArmy,
			positionX, self.mPosition[2], positionZ,
			self.mOrientation[1], self.mOrientation[2], self.mOrientation[3], self.mOrientation[4],
			nil,
			self.mSpawnAnimSet and { UseSpawnAnim = self.mSpawnAnimSet[Random(1,table.getsize(self.mSpawnAnimSet))] } or nil
		)
		if unit then

			unit:SetOrientation( self.mOrientation, true )
			if unit:GetBlueprint().Physics.OccupyGround then
				unit:CreateTarmac(true, true, false, false)
			end
	
			local armyIndex = brain:GetArmyIndex()
			if ScenarioInfo.UnitNames[armyIndex] then
				ScenarioInfo.UnitNames[armyIndex][self.mSpawnUnit] = unit
			end
			unit.UnitName = self.mSpawnUnit
	
			if self.mCallbackFn then
				self.mCallbackFn( self.mSpawnerName, unit )
			end
		end
		if not brain.IgnoreArmyCaps then
			SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
		end
	end
}