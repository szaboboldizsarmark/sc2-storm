-----------------------------------------------------------------------------
--  File     : /abilities/Point_Defense_Hunker_Ability.lua
--  Author(s): Gordon Duclos
--  Summary  : Point Defense Hunker ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local function CreateHunkerShieldOrnament( unit )
	if not unit.HunkerShieldOrnamentId then
		unit.HunkerShieldOrnamentId = unit:AttachOrnament( '/effects/Entities/HunkerShield/HunkerShield_mesh', -1, 0.075 )
	end
end

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' then
		unit:PlayUnitSound('Hunker')
		unit:SetRepairable(false)
		unit:SetBuildDisabled(true)
		
		CreateHunkerShieldOrnament( unit )
	else
		unit:PlayUnitSound('UnHunker')
		unit:SetRepairable(true)
		unit:SetBuildDisabled(false)

		if unit.HunkerShieldOrnamentId then
			unit:RemoveOrnament( unit.HunkerShieldOrnamentId )
			unit.HunkerShieldOrnamentId = nil
		end
	end
end