-----------------------------------------------------------------------------
--  File     : /abilities/EscapePod_Ability.lua
--  Author(s): Gordon Duclos
--  Summary  : Commander Escape Pod ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' and not unit.Ejected then
		unit.Ejected = true
        unit:SetCustomName( '' )

        local bp = unit:GetBlueprint()
        local headUnit = CreateUnitAtBone(bp.EscapePod.EscapePodUnitId, unit:GetArmy(), unit, bp.EscapePod.EscapePodAttachBone)
        unit:HideBone(bp.EscapePod.EscapePodAttachBone, true)

		-- If we have a death weapon that is enabled, then we need to disable it on the Commander, and 
		-- the death weapon on the escape pod will be active by default. If the death weapon is disabled, 
		-- then Core Dump (tm) has been researched, and in this case, the escape pod is non-nukey!
		if unit.DeathWeaponEnabled then
			unit:SetDeathWeaponEnabled(false)
		else
			headUnit:SetDeathWeaponEnabled(false)
		end
		
		Sync.SetSelection = {headUnit:GetEntityId()}

		unit:Kill()
    end
end