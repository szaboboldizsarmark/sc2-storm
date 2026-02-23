-----------------------------------------------------------------------------
--  File     : /abilities/Mobile_Hunker_Ability.lua
--  Author(s): Gordon Duclos
--  Summary  : Mobile Hunker ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local function CreateHunkerShieldOrnament( unit )
	if not unit.HunkerShieldOrnamentId then
		unit.HunkerShieldOrnamentId = unit:AttachOrnament( '/effects/Entities/HunkerShield/HunkerShield_mesh', -1, 0.04 )
	end
end

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' then
		unit:PlayUnitSound('Hunker')
		unit:SetRepairable(false)
		unit:SetBuildDisabled(true)
		unit:SetIgnoreWorldForces(true)
		unit:SetNavMaxSpeedMultiplier(0)
		
		CreateHunkerShieldOrnament( unit )
	else
		unit:PlayUnitSound('UnHunker')
		unit:SetRepairable(true)
		unit:SetBuildDisabled(false)
		unit:SetIgnoreWorldForces(false)
		unit:SetNavMaxSpeedMultiplier(unit:GetSpeedMult())
		
		if unit.HunkerShieldOrnamentId then
			unit:RemoveOrnament( unit.HunkerShieldOrnamentId )
			unit.HunkerShieldOrnamentId = nil
		end
	end
end