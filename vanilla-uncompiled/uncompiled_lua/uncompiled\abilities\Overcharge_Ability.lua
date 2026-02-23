-----------------------------------------------------------------------------
--  File     : /abilities/Overcharge_Ability.lua
--  Author(s): Gordon Duclos
--  Summary  : Commander Overcharge ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == "activate" then
		-- Get the current main weapon label from the commander unit
		local currentMainWeapon = unit:GetMainWeaponLabel()

		-- Turn of the commanders main weapon, and enable overcharge
		unit:SetWeaponEnabledByLabel( currentMainWeapon, false)
		unit:SetWeaponEnabledByLabel('OverCharge', true)
		unit:PlayUnitSound('OverchargeOn')

		-- Set the proper aim manipulator precedence and set the overcharge weapons
		-- aim heading to be that of the main weapon
		local mainWeaponAim = unit:GetWeapon(currentMainWeapon):GetAimManipulator()
		local overChargeAim = unit:GetWeapon('OverCharge'):GetAimManipulator()
		overChargeAim:SetHeadingPitch(mainWeaponAim:GetHeadingPitch())

	elseif state == "deactivate" or state == "interrupt" then
		-- Get the current main weapon label from the commander unit
		local currentMainWeapon = unit:GetMainWeaponLabel()

		-- Turn of the commanders overcharge weapon, and re-enable the main weapon
		unit:SetWeaponEnabledByLabel('OverCharge', false)
		unit:SetWeaponEnabledByLabel(currentMainWeapon, true)
		unit:PlayUnitSound('OverchargeOff')

		-- Set the proper aim manipulator precedence and set the main weapons
		-- aim heading to be that of the overcharge weapon
		local mainWeaponAim = unit:GetWeapon(currentMainWeapon):GetAimManipulator()
		local overChargeAim = unit:GetWeapon('OverCharge'):GetAimManipulator()
		mainWeaponAim:SetHeadingPitch(overChargeAim:GetHeadingPitch())
	end
end