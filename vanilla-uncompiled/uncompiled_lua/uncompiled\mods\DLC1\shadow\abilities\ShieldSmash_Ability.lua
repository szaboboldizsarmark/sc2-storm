-----------------------------------------------------------------------------
--  File     : /abilities/Overcharge_Ability.lua
--  Author(s): Gordon Duclos
--  Summary  : Commander Overcharge ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == "activate" then
		unit.ShieldSmash = true
	else
		unit.ShieldSmash = false
	end
end