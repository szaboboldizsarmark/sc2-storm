--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameUtilsArtifact.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for the SC2 custom artifact defense system units.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local TriggerFile		= import('/lua/sim/ScenarioTriggers.lua')
local ScenarioUtils		= import('/lua/sim/ScenarioUtilities.lua')

---------------------------------------------------------------------
-- COMMON FUNCTIONS:
---------------------------------------------------------------------
local GroupPatrolChain = import('/lua/sim/ScenarioFramework.lua').GroupPatrolChain

---------------------------------------------------------------------
-- NOTES:
---------------------------------------------------------------------
	-- concept:
	--	each drone launcher maintains a max drone count, which can be respawned at a set interval
	--	each drone follows a patrol specific to the launcher

---------------------------------------------------------------------
-- EXTERNAL FUNCTIONS:
---------------------------------------------------------------------
function ActivateDroneLauncher(unitLauncher, strArmy, maxDroneCount, strPatrol, droneRespawnDelay, droneInitDelay)
	if unitLauncher and not unitLauncher:IsDead() then
		if not unitLauncher.ScenarioUnitData then
			unitLauncher.ScenarioUnitData = {}
		end
		unitLauncher.ScenarioUnitData.Active			= true
		unitLauncher.ScenarioUnitData.strArmy			= strArmy
		unitLauncher.ScenarioUnitData.maxDroneCount		= maxDroneCount
		unitLauncher.ScenarioUnitData.strPatrol			= strPatrol
		unitLauncher.ScenarioUnitData.droneRespawnDelay	= droneRespawnDelay
		unitLauncher.ScenarioUnitData.droneInitDelay	= droneInitDelay or 0.0
		unitLauncher.ScenarioUnitData.droneList			= {}

		-- force a min duration on the spawntimes
		if droneRespawnDelay < 1.0 then
			unitLauncher.ScenarioUnitData.droneRespawnDelay = 1.0
		end

		StartDrones(unitLauncher)
	end
end

function UpdateInitDelay(unitLauncher, newDelay)
	if unitLauncher and not unitLauncher:IsDead() and unitLauncher.ScenarioUnitData then
		unitLauncher.ScenarioUnitData.droneInitDelay = newDelay
	end
end

function UpdateMaxDroneCount(unitLauncher, newCount)
	if unitLauncher and not unitLauncher:IsDead() and unitLauncher.ScenarioUnitData then
		unitLauncher.ScenarioUnitData.maxDroneCount = newCount
	end
end

function UpdateDronePatrol(unitLauncher, newPatrol)
	if unitLauncher and not unitLauncher:IsDead() and unitLauncher.ScenarioUnitData then
		unitLauncher.ScenarioUnitData.strPatrol = strPatrol

		if unitLauncher.ScenarioUnitData.droneList then
			IssueClearCommands(unitLauncher.ScenarioUnitData.droneList)

			-- send the drone on patrol
			GroupPatrolChain({drone}, unitLauncher.ScenarioUnitData.strPatrol)
		end
	end
end

function DeactivateDroneLauncher(unitLauncher)
	if unitLauncher and not unitLauncher:IsDead() then
		if unitLauncher.ScenarioUnitData then
			unitLauncher.ScenarioUnitData.Active = false
		end
	end
end

---------------------------------------------------------------------
-- INTERNAl FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- StartDrones:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function StartDrones(unitLauncher)
	if unitLauncher and not unitLauncher:IsDead() then
		local currentDelay = unitLauncher.ScenarioUnitData.droneInitDelay

		if currentDelay > 0.0 then
			ForkThread(
				function()
					-- spawn each drone with a slight delay in-between
					for i=1, unitLauncher.ScenarioUnitData.maxDroneCount do
						SpawnDrone(unitLauncher)
						WaitSeconds(unitLauncher.ScenarioUnitData.droneInitDelay)
					end

					ForkThread(StartDroneWatch,unitLauncher)
				end
			)
		else
			-- spawn drones immediately on this tick
			for i=1, unitLauncher.ScenarioUnitData.maxDroneCount do
				SpawnDrone(unitLauncher)
			end

			ForkThread(StartDroneWatch,unitLauncher)
		end
	end
end

---------------------------------------------------------------------
-- SpawnDrone:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function SpawnDrone(unitLauncher)
	if unitLauncher and not unitLauncher:IsDead() then
		-- determine the launcher position
		local pos = unitLauncher:GetPosition()

		-- create the drone at the position
		local drone = CreateUnitHPR('sca3601', unitLauncher.ScenarioUnitData.strArmy, pos[1], pos[2], pos[3],  0, 0, 0)

		-- add the new drone to the list
		table.insert(unitLauncher.ScenarioUnitData.droneList, drone)

		-- send the drone on patrol
		GroupPatrolChain({drone}, unitLauncher.ScenarioUnitData.strPatrol)
	end
end

---------------------------------------------------------------------
-- StartDroneWatch:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function StartDroneWatch(unitLauncher)
	while unitLauncher and not unitLauncher:IsDead() and unitLauncher.ScenarioUnitData and unitLauncher.ScenarioUnitData.Active do
		local newList = {}
		for k, unit in unitLauncher.ScenarioUnitData.droneList do
			if unit and not unit:IsDead() then
				table.insert(newList, unit)
			end
		end
		unitLauncher.ScenarioUnitData.droneList = newList

		if table.getn(unitLauncher.ScenarioUnitData.droneList) < unitLauncher.ScenarioUnitData.maxDroneCount then
			SpawnDrone(unitLauncher)
		end

		WaitSeconds(unitLauncher.ScenarioUnitData.droneRespawnDelay)
	end
end
