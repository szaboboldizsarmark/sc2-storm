-----------------------------------------------------------------------------
--  File     : /abilities/StructureSacrifice_Ability.lua
--  Author(s): Mike Robbins
--  Summary  : Structure Sacrifice ability script
--  Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' then
		local bp = unit:GetUnitWeaponBlueprint( 'Sacrifice' )
		if bp then
			local brain = unit:GetAIBrain()
			local units = brain:GetUnitsAroundPoint( categories.ALLUNITS, unit:GetPosition(), bp.DamageRadius or 1, 'Ally' )
			
			unit:SetDeathWeaponEnabled(false)
			unit.ForceNoWreckage = true
			
			for k,v in units do
				if v == unit then continue end
				v:AdjustHealth(unit, bp.Damage)
			end
			
			unit:Kill()
		end
	end
end