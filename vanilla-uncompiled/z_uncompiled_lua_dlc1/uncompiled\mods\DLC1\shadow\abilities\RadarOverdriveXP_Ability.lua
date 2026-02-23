-----------------------------------------------------------------------------
--  File     : /abilities/RadarOverdriveXP_Ability.lua
--  Author(s): Aaron Lundquist
--  Summary  : Radar Overdrive XP ability script
--  Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' then
		unit:PlayUnitSound('Overdrive')
	end
end