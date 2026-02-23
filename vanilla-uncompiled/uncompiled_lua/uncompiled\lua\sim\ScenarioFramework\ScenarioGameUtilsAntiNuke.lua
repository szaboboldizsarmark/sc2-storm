--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameUtilsAntiNuke.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for handling anti-nuke automation.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local checkInterval = 33
---------------------------------------------------------------------
-- EXTERNAL FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- StartAntiNukeManagers:
--	this function simply checks non-player anti-nukes every checkInterval seconds, and if needed re-stocks them
function StartAntiNukeManagers()
	ForkThread(AntiNukeManagerThread)
end

---------------------------------------------------------------------
-- INTERNAl FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- AntiNukeManagerThread:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function AntiNukeManagerThread()
	while not ScenarioInfo.OpEnded do
		-- go through all anti-nuke units for all non-player armies
		for i = 2, table.getn(ArmyBrains) do
			-- construct a category filter for just the anit-nuke capable units
			local cats = categories.uub0203 + categories.ucb0204 + categories.uib0203

			-- get a filtered list of all of these units for this army
			local list = ArmyBrains[i]:GetListOfUnits(cats, false, true)

			-- for every unit in the list adjust its ammo count if needed
			for k, unit in list do
				if unit and not unit:IsDead() then
					local curCount = unit:GetAntiNukeSiloAmmoCount()
					local maxCount = 5
					if curCount < maxCount then
						LOG('ScenarioGameUtilsAntiNuke: giving ammo to unit:[', unit, '] for army:[', i, ']')
						unit:GiveAntiNukeSiloAmmo(1)
					end
				end
			end
		end

		-- wait for a bit, and then repeat
		WaitSeconds(checkInterval)
	end
end
