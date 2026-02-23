--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameUtilsKrakken.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for scenario management of Krakken.
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
	--	the unit will patrol on the surface if anyone gets near his home
	--	however, if he takes enough damage, he will dive and retreat home for a bit
	--	then he will begin again
	-- NOTE: it is required that the unit start ABOVE WATER

---------------------------------------------------------------------
-- EXTERNAL FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- LaunchKrakkenAI:
--		<unit> should be the Krakken unit
--		<strPatrol> should be a chain
--		<posHome> can be a position or a string name of a marker
--		<areaHome> can be either a valid rectangle or a string name of an area
--		<restartDelay> should be duration in seconds
--
function LaunchKrakkenAI(unit, strPatrol, posHome, areaHome, restartDelay)
	if unit and not unit:IsDead() then
		if not unit.ScenarioUnitData then
			unit.ScenarioUnitData = {}
		end
		unit.ScenarioUnitData.strPatrol		= strPatrol
		unit.ScenarioUnitData.posHome		= posHome
		unit.ScenarioUnitData.areaHome		= areaHome
		unit.ScenarioUnitData.restartDelay	= restartDelay
		unit.ScenarioUnitData.Surfaced		= true
		unit.ScenarioUnitData.Surfacing		= false
		unit.ScenarioUnitData.Diving		= false
		unit.ScenarioUnitData.CurrentRatio	= 0.75

		if type(unit.ScenarioUnitData.posHome) == 'string' then
			unit.ScenarioUnitData.posHome = ScenarioUtils.MarkerToPosition(unit.ScenarioUnitData.posHome)
		end

		StartKrakkenRetreat(unit)
	end
end

---------------------------------------------------------------------
-- INTERNAl FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- StartKrakkenGuardHome:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function StartKrakkenGuardHome(unit)
	if unit and not unit:IsDead() then
		-- clear commands
		IssueClearCommands({unit})

		-- guard our home
		IssueGuard({unit}, unit.ScenarioUnitData.posHome)

		-- setup a trigger to switch on our patrol if enemies get near
		TriggerFile.CreateAreaTrigger(
			function()
				StartKrakkenPatrol(unit)
			end,
			unit.ScenarioUnitData.areaHome,
			categories.ALLUNITS,
			true,
			false,
			ArmyBrains[ScenarioInfo.ARMY_PLAYER],
			1
		)
	end
end

---------------------------------------------------------------------
-- StartKrakkenPatrol:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function StartKrakkenPatrol(unit)
	if unit and not unit:IsDead() then
		-- clear commands
		IssueClearCommands({unit})

		-- if needed, surface
		if not unit.ScenarioUnitData.Surfaced then
			IssueDive({unit})
			unit.ScenarioUnitData.Surfacing = true
		end

		-- wait a few secs, then patrol
		ForkThread(
			function()
				WaitSeconds(5.0)
				unit.ScenarioUnitData.Surfacing = false
				unit.ScenarioUnitData.Surfaced = true
				GroupPatrolChain({unit}, unit.ScenarioUnitData.strPatrol)

				-- if our health drops too low - run away
				TriggerFile.CreateUnitHealthRatioTrigger(
					function()
						-- try to retreat, if we are almost dead - screw it
						unit.ScenarioUnitData.CurrentRatio = unit.ScenarioUnitData.CurrentRatio - 0.25
						if unit.ScenarioUnitData.CurrentRatio > 0.0 then
							StartKrakkenRetreat(unit)
						end
					end,
					unit,
					unit.ScenarioUnitData.CurrentRatio,
					true,
					true
				)
			end
		)
	end
end

---------------------------------------------------------------------
-- StartKrakkenRetreat:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function StartKrakkenRetreat(unit)
	if unit and not unit:IsDead() then
		-- clear commands
		IssueClearCommands({unit})

		-- if needed, dive
		if unit.ScenarioUnitData.Surfaced then
			IssueDive({unit})
			unit.ScenarioUnitData.Diving = true
		end

		-- wait a few secs, then run away
		ForkThread(
			function()
				WaitSeconds(5.0)
				unit.ScenarioUnitData.Diving = false
				unit.ScenarioUnitData.Surfaced = false

				-- guard our home
				IssueGuard({unit}, unit.ScenarioUnitData.posHome)

				-- restart the patrol after our delay
				TriggerFile.CreateTimerTrigger(
					function()
						StartKrakkenGuardHome(unit)
					end,
					unit.ScenarioUnitData.restartDelay
				)
			end
		)
	end
end
