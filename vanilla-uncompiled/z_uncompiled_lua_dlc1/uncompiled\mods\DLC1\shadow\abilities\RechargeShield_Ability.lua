-----------------------------------------------------------------------------
--  File     : /abilities/RechargeShield_Ability.lua
--  Author(s): Mike Robbins
--  Summary  : Structure Sacrifice ability script
--  Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' then
		unit.MyShield:SetHealth(unit.MyShield, unit.MyShield:GetMaxHealth())
		unit.MyShield:TurnOn()
	end
end