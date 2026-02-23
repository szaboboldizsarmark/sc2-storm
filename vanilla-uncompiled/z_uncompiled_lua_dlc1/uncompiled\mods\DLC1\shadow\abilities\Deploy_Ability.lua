-----------------------------------------------------------------------------
--  File     : /abilities/Overcharge_Ability.lua
--  Author(s): Gordon Duclos
--  Summary  : Commander Overcharge ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

DeployWeapon = function(unit, unitBP)
	local weapon = unit:GetWeapon(1)
	local weapLabel = weapon:GetBlueprint().Label
	
	if (not unit.Animator) then
		unit.Animator = CreateAnimator(unit)
	end

	unit.Animator:PlayAnim(unitBP.Display.AnimationOpen, false)
	WaitSeconds(1.5)
	unit:SetIgnoreWorldForces(true)
	unit:SetNavMaxSpeedMultiplier(0)
	WaitFor(unit.Animator)
	unit:SetWeaponEnabledByLabel( weapLabel, true)
end

OnAbility = function( unit, abilityBp, state )
	local unitBP = unit:GetBlueprint()
	if state == "activate" then
		ForkThread(DeployWeapon, unit, unitBP)
		unit:PlayUnitSound('Deploy')
	elseif state == "deactivate" or state == "interrupt" then
		local weapon = unit:GetWeapon(1)
		local weapLabel = weapon:GetBlueprint().Label
		
		unit.Animator:PlayAnim(unitBP.Display.AnimationClose, false)
		unit:SetWeaponEnabledByLabel( weapLabel, false)
		unit:SetIgnoreWorldForces(false)
		unit:SetNavMaxSpeedMultiplier(unit:GetSpeedMult())
		unit:PlayUnitSound('UnDeploy')
	end
end