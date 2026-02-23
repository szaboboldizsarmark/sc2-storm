-----------------------------------------------------------------------------
--  File     : /abilities/StealthField_Ability.lua
--  Author(s): Mike Robbins
--  Summary  : Commander Knockback weapon ability script
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

OnAbility = function( unit, abilityBp, state )
	if state == 'activate' then
		unit:EnableIntel('CloakField')
		unit:EnableIntel('RadarStealthField')
		unit:EnableIntel('SonarStealthField')
		unit:OnIntelEnabled()
	else
		unit:DisableIntel('CloakField')
		unit:DisableIntel('RadarStealthField')
		unit:DisableIntel('SonarStealthField')
		unit:OnIntelDisabled()
	end
end