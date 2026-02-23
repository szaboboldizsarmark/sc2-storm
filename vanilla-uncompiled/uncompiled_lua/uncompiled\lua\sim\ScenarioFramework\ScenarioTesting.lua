-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioTesting.lua
--  Author(s): Brian Fricks
--  Summary  : Game specific helper functions for testing game system.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ScenarioUtils	= import('/lua/sim/ScenarioUtilities.lua')
local DATA = import('/lua/sim/ScenarioFramework/ScenarioTestingData.lua')
local RandomInt = import('/lua/system/utilities.lua').GetRandomInt

---------------------------------------------------------------------
function BeginSimTest()
	ForkThread(
		function()
			-- if needed, setup all aliances
			if ScenarioInfo.x360_maptype and ScenarioInfo.x360_maptype == '2v2' then
				for k, brain in ArmyBrains do
					-- ally all odd armies
					if (k == 1) or (k == 3) or (k == 5) or (k == 7) then
						if k != 1 and ArmyBrains[1] then
							SetAlliance(k,1,"Ally")
						end
						if k != 3 and ArmyBrains[3] then
							SetAlliance(k,3,"Ally")
						end
						if k != 5 and ArmyBrains[5] then
							SetAlliance(k,5,"Ally")
						end
						if k != 7 and ArmyBrains[7] then
							SetAlliance(k,7,"Ally")
						end
					end

					-- ally all even armies
					if (k == 2) or (k == 4) or (k == 6) or (k == 8) then
						if k != 2 and ArmyBrains[2] then
							SetAlliance(k,2,"Ally")
						end
						if k != 4 and ArmyBrains[4] then
							SetAlliance(k,4,"Ally")
						end
						if k != 6 and ArmyBrains[6] then
							SetAlliance(k,6,"Ally")
						end
						if k != 8 and ArmyBrains[8] then
							SetAlliance(k,8,"Ally")
						end
					end
				end
			end

			-- start the engine stat logging
			BeginLoggingStats('perftest.log')

			-- enable
			import('/lua/system/Utilities.lua').UserConRequest('ren_ShowFrameTime')
			import('/lua/system/Utilities.lua').UserConRequest('gpnav_Stats')
			import('/lua/system/Utilities.lua').UserConRequest('gpnav_ShowPathWork')
			import('/lua/system/Utilities.lua').UserConRequest('gpnav_Overlay')

			-- wait 20 minutes
			WaitSeconds(1200.0)

			-- pause the game effectively
			import('/lua/system/Utilities.lua').UserConRequest('WLD_GameSpeed -20.0')

			-- end the engine stat logging
			EndLoggingStats()
		end
	)
end

---------------------------------------------------------------------
ScenarioInfo.Testing = nil
local ST = {}
function InitTestData()
	if not ScenarioInfo.Testing then
		if not ArmyBrains[1] then
			error('ERROR: TEST FAILURE - ScenarioTesting requires a valid army for slot 1!!!!!')
			return false
		elseif not GetArmyBrain('ARMY_1') then
			error('ERROR: TEST FAILURE - ScenarioTesting requires a valid army for ARMY_1!!!!!')
			return false
		end

		if not ArmyBrains[2] then
			error('ERROR: TEST FAILURE - ScenarioTesting requires a valid army for slot 2!!!!!')
			return false
		elseif not GetArmyBrain('ARMY_2') then
			error('ERROR: TEST FAILURE - ScenarioTesting requires a valid army for ARMY_2!!!!!')
			return false
		end

		local startMarker = ScenarioUtils.GetMarker('ARMY_1')
		if not startMarker then
			error('ERROR: TEST FAILURE - ScenarioTesting requires a valid marker named ARMY_1!!!!!')
			return false
		end

		local MassMarkerList = ScenarioUtils.GetMarkersByType('Mass')
		if not MassMarkerList then
			error('ERROR: TEST FAILURE - ScenarioTesting requires at least one mass deposit for the map to be testable!!!!!')
			return false
		end

		-- remove all current units from the army 2
		local startingUnits = ArmyBrains[2]:GetListOfUnits(categories.ALLUNITS, true)
		for k, unit in startingUnits do
			unit:Destroy()
		end

		-- define our storage tables
		ScenarioInfo.Testing = {}
		ST = ScenarioInfo.Testing

		-- setup data for all groups
		ST.GroupList		= PropogateGroups()
		ST.GroupCurrentID	= 1
		ST.GroupMaxID		= table.getn(ST.GroupList)

		-- setup data for all tests
		ST.TestList			= PropogateTests()
		ST.TestCurrentID	= 1
		ST.TestMaxID		= table.getn(ST.TestList)

		-- setup start positions
		ST.StartPos = startMarker.position

		-- setup mass position list
		ST.MassPosList = {}
		for k, marker in MassMarkerList do
			table.insert(ST.MassPosList, marker.position)
		end
	end

	return true
end

---------------------------------------------------------------------
function PropogateGroups()
	groups = {
		DATA.UEF_TANK_SINGLE,
		DATA.UEF_TANK_GROUP,
		DATA.UEF_ACU_SINGLE,
		DATA.UEF_ENG_SINGLE,
		DATA.UEF_FATBOY_SINGLE,
		DATA.UEF_FATBOY_GROUP,
		DATA.UEF_FATBOY_TANK_BIG_GROUP,
		DATA.ALL_SMALL_LAND,
		DATA.CYB_NAVAL_SINGLE,
		DATA.CYB_NAVAL_GROUP,
		DATA.ALL_EXP_LAND,
		DATA.ALL_LAND,
		DATA.UEF_FIGHTER_SINGLE,
		DATA.UEF_GUNSHIP_SINGLE,
		DATA.ALL_BASIC_AIR,
		DATA.ALL_AIR,
		DATA.ALL_BUT_SUBS,
	}

	return groups
end

---------------------------------------------------------------------
function PropogateTests()
	local tests = {
		{
			func = f_FORM_MOVE_ALL,
			name = 'f_FORM_MOVE_ALL',
		},
		{
			func = f_FORM_ATTACK_SINGLE,
			name = 'f_FORM_ATTACK_SINGLE',
		},
		{
			func = f_FORM_ATTACK_ALL,
			name = 'f_FORM_ATTACK_ALL',
		},
		{
			func = f_FORM_PATROL_SINGLE,
			name = 'f_FORM_PATROL_SINGLE',
		},
		{
			func = f_FORM_PATROL_ALL,
			name = 'f_FORM_PATROL_ALL',
		},
		{
			func = f_FORM_PATROL_RANDOM_5,
			name = 'f_FORM_PATROL_RANDOM_5',
		},
	}

	return tests
end

---------------------------------------------------------------------
function PrintGroupInfo()
	local groupData = ST.GroupList[ST.GroupCurrentID]

	if not groupData then
		error('ERROR: TEST FAILURE - NO GROUP DATA!!!!!')
		return
	end

	if not groupData.name then
		error('ERROR: TEST FAILURE - NO GROUP NAME!!!!!')
		return
	end

    if not Sync.PrintText then
        Sync.PrintText = {}
    end

	local data = {
		text = 'Press ShiftF5 To Create: [' .. groupData.name .. ']',
		size = 18,
		color = 'ffffffff',
		duration = 4.0,
		location = 'center'
	}
	table.insert(Sync.PrintText, data)
end

---------------------------------------------------------------------
function PrintTestInfo()
	local testData = ST.TestList[ST.TestCurrentID]

	if not testData then
		error('ERROR: TEST FAILURE - NO TEST DATA!!!!!')
		return
	end

	if not testData.name then
		error('ERROR: TEST FAILURE - NO TEST NAME!!!!!')
		return
	end

    if not Sync.PrintText then
        Sync.PrintText = {}
    end

	local data = {
		text = 'Press ShiftF5 To Test: [' .. testData.name .. ']',
		size = 18,
		color = 'ffffffff',
		duration = 4.0,
		location = 'center'
	}
	table.insert(Sync.PrintText, data)
end

---------------------------------------------------------------------
function GroupPicker_Increment()
	if not InitTestData() then return end
	ST.GroupCurrentID = ST.GroupCurrentID + 1

	if ST.GroupCurrentID > ST.GroupMaxID then
		ST.GroupCurrentID = 1
	end

	PrintGroupInfo()
end

---------------------------------------------------------------------
function GroupPicker_Decrement()
	if not InitTestData() then return end
	ST.GroupCurrentID = ST.GroupCurrentID - 1

	if ST.GroupCurrentID < 1 then
		ST.GroupCurrentID = ST.GroupMaxID
	end

	PrintGroupInfo()
end

---------------------------------------------------------------------
function TestPicker_Increment()
	if not InitTestData() then return end
	ST.TestCurrentID = ST.TestCurrentID + 1

	if ST.TestCurrentID > ST.TestMaxID then
		ST.TestCurrentID = 1
	end

	PrintTestInfo()
end

---------------------------------------------------------------------
function TestPicker_Decrement()
	if not InitTestData() then return end
	ST.TestCurrentID = ST.TestCurrentID - 1

	if ST.TestCurrentID < 1 then
		ST.TestCurrentID = ST.TestMaxID
	end

	PrintTestInfo()
end

---------------------------------------------------------------------
function ExecuteCurrentTest()
	ForkThread(
		function()
			if not InitTestData() then return end
			if ST.ARMY_1_UNITS then
				for k, unit in ST.ARMY_1_UNITS do
					if unit and not unit:IsDead() then
						unit:Destroy()
					end
				end
			end

			local startingUnits = ArmyBrains[2]:GetListOfUnits(categories.ALLUNITS, true)
			for k, unit in startingUnits do
				unit:Destroy()
			end

			WaitTicks(10)

			--------------------
			ST.ARMY_1_UNITS = {}
			local groupName = 'INVALID'
			local groupData = ST.GroupList[ST.GroupCurrentID]
			--------------------
			if groupData then
				if groupData.name then
					groupName =  groupData.name
				else
					error('ERROR: TEST FAILURE - no name for group data index:[', ST.GroupCurrentID, ']!!!!!')
					return
				end

				if groupData.units then
					local pos = ST.StartPos
					for k, unitDataSet in groupData.units do
						if not unitDataSet.type then
							error('ERROR: TEST FAILURE - no type defined for index:[', k, '] of group name:[', groupName, ']!!!!!')
							return
						end

						if not unitDataSet.count or unitDataSet.count < 1 then
							error('ERROR: TEST FAILURE - invalid count defined for index:[', k, '] of group name:[', groupName, ']!!!!!')
							return
						end

						for i = 1, unitDataSet.count do
							local unit = CreateUnitHPR(unitDataSet.type, 'ARMY_1', pos[1], pos[2], pos[3],  0, 0, 0)
							table.insert(ST.ARMY_1_UNITS,unit)
						end
					end
				else
					error('ERROR: TEST FAILURE - no units data for group name:[', groupName, ']!!!!!')
					return
				end
			else
				error('ERROR: TEST FAILURE - NO GROUP DATA!!!!!')
				return
			end

			--------------------
			local testName = 'INVALID'
			local testData = ST.TestList[ST.TestCurrentID]
			--------------------
			if testData then
				if testData.name then
					testName =  testData.name
				else
					error('ERROR: TEST FAILURE - no name for test data index:[', ST.TestCurrentID, ']!!!!!')
					return
				end

				if testData.func then
					testData.func(ST.ARMY_1_UNITS)
				else
					error('ERROR: TEST FAILURE - no func defined for test name:[', testName, ']!!!!!')
					return
				end
			else
				error('ERROR: TEST FAILURE - NO TEST DATA!!!!!')
				return
			end

		    if not Sync.PrintText then
		        Sync.PrintText = {}
		    end

			local data = {
				text = 'Testing: group: [' .. groupName .. '] test: [' .. testName .. ']',
				size = 18,
				color = 'ffffffff',
				duration = 4.0,
				location = 'center'
			}
			table.insert(Sync.PrintText, data)
		end
	)
end

---------------------------------------------------------------------
function AddTargets()
	--------------------
	ST.ARMY_2_UNITS = {}
	--------------------
	if ST.MassPosList and ST.StartPos then
		for k, pos in ST.MassPosList do
			if VDist2( pos[1], pos[3], ST.StartPos[1], ST.StartPos[3]) > 50.0 then
				local unit01 = CreateUnitHPR('uub0701', 'ARMY_2', pos[1], pos[2], pos[3],  0, 0, 0)
				unit01:SetMaxHealth(500)
				unit01:AdjustHealth(unit01, 500)
				table.insert(ST.ARMY_2_UNITS, unit01)

				local unit02 = CreateUnitHPR('uul0002', 'ARMY_2', pos[1], pos[2], pos[3],  0, 0, 0)
				unit01:SetMaxHealth(10)
				unit01:AdjustHealth(unit01,10)
				table.insert(ST.ARMY_2_UNITS, unit02)
			end
		end
	end
end

---------------------------------------------------------------------
function f_FORM_MOVE_ALL(group)
	LOG('SCENARIO TESTING: executing test: f_FORM_MOVE_ALL')

	if ST.MassPosList then
		for k, pos in ST.MassPosList do
			IssueFormMove(group,pos, 'AttackFormation', 0 )
		end
	end
end

---------------------------------------------------------------------
function f_FORM_ATTACK_SINGLE(group)
	LOG('SCENARIO TESTING: executing test: f_FORM_ATTACK_SINGLE')
	AddTargets()

	if ST.ARMY_2_UNITS then
		local maxTargets = table.getn(ST.ARMY_2_UNITS)
		if maxTargets > 0 then
			IssueFormAttack(group,ST.ARMY_2_UNITS[RandomInt(1,maxTargets)], 'AttackFormation', 0 )
		end
	end
end

---------------------------------------------------------------------
function f_FORM_ATTACK_ALL(group)
	LOG('SCENARIO TESTING: executing test: f_FORM_ATTACK_ALL')
	AddTargets()

	if ST.ARMY_2_UNITS then
		for k, target in ST.ARMY_2_UNITS do
			IssueFormAttack(group,target, 'AttackFormation', 0 )
		end
	end
end

---------------------------------------------------------------------
function f_FORM_PATROL_SINGLE(group)
	LOG('SCENARIO TESTING: executing test: f_FORM_PATROL_SINGLE')
	AddTargets()

	if ST.MassPosList and ST.StartPos then
		IssueFormPatrol(group,ST.StartPos, 'AttackFormation', 0 )

		local maxPos = table.getn(ST.MassPosList)
		if maxPos > 0 then
			IssueFormPatrol(group,ST.MassPosList[RandomInt(1,maxPos)], 'AttackFormation', 0 )
		end
	end
end

---------------------------------------------------------------------
function f_FORM_PATROL_ALL(group)
	LOG('SCENARIO TESTING: executing test: f_FORM_PATROL_ALL')
	AddTargets()

	if ST.MassPosList and ST.StartPos then
		IssueFormPatrol(group,ST.StartPos, 'AttackFormation', 0 )

		for k, pos in ST.MassPosList do
			IssueFormPatrol(group,pos, 'AttackFormation', 0 )
		end
	end
end

---------------------------------------------------------------------
function f_FORM_PATROL_RANDOM_5(group)
	LOG('SCENARIO TESTING: executing test: f_FORM_PATROL_RANDOM_5')
	AddTargets()

	if ST.MassPosList and ST.StartPos then
		IssueFormPatrol(group,ST.StartPos, 'AttackFormation', 0 )

		local maxPos = table.getn(ST.MassPosList)
		if maxPos > 0 then
			for i=1,5 do
				IssueFormPatrol(group,ST.MassPosList[RandomInt(1,maxPos)], 'AttackFormation', 0 )
			end
		end
	end
end