--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameUtilsUnitCannon.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for the SC2 Unit Cannon.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local TriggerFile		= import('/lua/sim/ScenarioTriggers.lua')
local ScenarioUtils		= import('/lua/sim/ScenarioUtilities.lua')

---------------------------------------------------------------------
-- EXTERNAL FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- StartCannon:
-- local data = {
-- 	cannonUnit			= <unit>,
--	strArmyName			= <strArmyName>,
-- 	destChainName		= <strChain>,
-- 	shotsPerVolley		= <int>,
-- 	delayBetweenVolleys	= <float>,
-- 	ammoUnitType		= <strUnitType>,
-- 	patrolChainName		= <strChain>,
-- }
function StartCannon(data)
	if data then
		ForkThread(FireAtPositionsThread, data)
	end
end

---------------------------------------------------------------------
-- INTERNAl FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- AddAmmoReadyCheck:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function AddAmmoReadyCheck(unit, patrolChainName)
	local argTable = { patrolChainName }
	if unit and not unit:IsDead() then
		unit.Callbacks.OnLayerChange:Add( CheckAmmoReadyForCombat, nil, argTable )
	end
end

---------------------------------------------------------------------
-- CheckAmmoReadyForCombat:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function CheckAmmoReadyForCombat(argTable, unit, newLayer, oldLayer)

	---TODO: fricks review this item - the tempLock thing is not the right way to do this - bfricks 11/10/09
	local tempLock = false
	if not tempLock and unit and not unit:IsDead() then
		local patrolChainName = argTable[1]

		if oldLayer == 'Air' and newLayer == 'Land' then
			tempLock = true
--			unit.Callbacks.OnLayerChange:Remove(import('/lua/sim/ScenarioFramework/ScenarioGameUtilsUnitCannon.lua').CheckAmmoReadyForCombat)

			ForkThread(
				function()
					if unit and not unit:IsDead() then
						IssueClearCommands({unit})
						Warp(unit, unit:GetPosition())
						WaitTicks(1)
						for k,v in ScenarioUtils.ChainToPositions(patrolChainName) do
							IssuePatrol( {unit}, v )
						end
					end
				end
			)
		end
	end
end

---------------------------------------------------------------------
-- FireAtPositionsThread:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function FireAtPositionsThread(data)
	local cannonUnit = data.cannonUnit

	if cannonUnit and not cannonUnit:IsDead() then
		local weapon = cannonUnit:GetWeapon('MainGun')

		if weapon then
			-- remove firing randomness, we want precision shooting
			weapon:SetFiringRandomness(0.0)

			-- setup our data tracking table
			if not cannonUnit.ScenarioUnitData then
				cannonUnit.ScenarioUnitData = {}
			end
			cannonUnit.ScenarioUnitData.FireShotFired = false

			-- begin firing volleys
			while cannonUnit and not cannonUnit:IsDead() do
				LoadAndLaunchVolley(data)
				local delay = data.delayBetweenVolleys or 10.0
				WaitSeconds(delay)
			end
		else
			WARN('WARNING: unit cannon failed due to bad weapon reference - pass to Campaign Design.')
		end
	end
end

---------------------------------------------------------------------
-- LoadAndLaunchVolley:
-- NOT INTENDED FOR USAGE OUTSIDE THIS MODULE
function LoadAndLaunchVolley(data)
	local cannonUnit = data.cannonUnit

	if cannonUnit and not cannonUnit:IsDead() then
		-- get the rest of our data
		local strArmyName			= data.strArmyName
		local destChainName			= data.destChainName
		local shotsPerVolley		= data.shotsPerVolley
		local delayBetweenVolleys	= data.delayBetweenVolleys
		local ammoUnitType			= data.ammoUnitType
		local patrolChainName		= data.patrolChainName

		-- early out if any of our data is bad
		if not strArmyName			then WARN('WARNING: unit cannon failed due to bad strArmyName - pass to Campaign Design.') return end
		if not destChainName		then WARN('WARNING: unit cannon failed due to bad destChainName - pass to Campaign Design.') return end
		if not shotsPerVolley		then WARN('WARNING: unit cannon failed due to bad shotsPerVolley - pass to Campaign Design.') return end
		if not delayBetweenVolleys	then WARN('WARNING: unit cannon failed due to bad delayBetweenVolleys - pass to Campaign Design.') return end
		if not ammoUnitType			then WARN('WARNING: unit cannon failed due to bad ammoUnitType - pass to Campaign Design.') return end
		if not patrolChainName		then WARN('WARNING: unit cannon failed due to bad patrolChainName - pass to Campaign Design.') return end

		local curAmmoIndex = 1
		local currentTargetMarker = 1

		-- clear any lingering commands
		IssueClearCommands({cannonUnit})

		-- allow the cannon to fire
		cannonUnit:AddCommandCap('RULEUCC_Attack')
		cannonUnit:SetWeaponEnabledByLabel( 'MainGun', true )

		while curAmmoIndex <= shotsPerVolley do
			if cannonUnit and not cannonUnit:IsDead() then
				-- build a spawn position for the ammo
				local pos = cannonUnit:GetPosition()
				pos[2] = GetTerrainHeight(pos[1], pos[3])

				-- spawn the ammo
				local newUnit = CreateUnitHPR(ammoUnitType, strArmyName, pos[1], pos[2], pos[3],  0, 0, 0)

				-- load the ammo
				cannonUnit:AddUnitAmmo(newUnit)

				-- register the patrol this unit will use when it lands
				AddAmmoReadyCheck( newUnit, patrolChainName )

				-- pick a destination for launching
				local markerList = ScenarioUtils.ChainToPositions(destChainName)
				if currentTargetMarker > table.getn(markerList) then
					currentTargetMarker = 1
				end

				-- clear last command and attack the position
				IssueClearCommands({cannonUnit})
				IssueAttack( {cannonUnit}, markerList[currentTargetMarker] )

				-- wait a bit, then proceed
				WaitSeconds(1.1)
			else
				break
			end

			curAmmoIndex = curAmmoIndex + 1
			currentTargetMarker = currentTargetMarker + 1
		end
	end
end
