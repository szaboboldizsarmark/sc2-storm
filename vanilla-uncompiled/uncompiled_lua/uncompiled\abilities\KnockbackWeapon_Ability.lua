-----------------------------------------------------------------------------
--  File     : /abilities/KnockbackWeapon_Ability.lua
--  Author(s): Gordon Duclos, Aaron Lundquist
--  Summary  : Commander Knockback weapon ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' then
        unit.KnockbackActive = true
        unit:PlayUnitSound('Knockback')
        unit:CreateKnockbackEffects()
	else
        unit.KnockbackActive = false
        unit:DestroyKnockbackEffects()
	end
end