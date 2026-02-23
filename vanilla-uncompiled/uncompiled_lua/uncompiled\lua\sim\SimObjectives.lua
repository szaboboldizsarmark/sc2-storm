--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--*******************************************************************
--*
--*  File     : /data/lua/SimObjectives.lua
--*	 Author(s):
--*
--*  Summary  : Sim side Objectives handling.
--*
--*  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*******************************************************************

local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Triggers = import('/lua/sim/ScenarioTriggers.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local DecalLOD = 9001

---NOTE: this should NOT be here - bfricks 10/9/09
local objectiveDecal = '/textures/decals/objective_debug_albedo.dds'
local objNum = 0

local SavedList = {}

--*******************************************************************
-- OBJECTIVE FUNCTIONS:
--*******************************************************************

---------------------------------------------------------------------
--	Supported Types:
--      Camera						critical
--      Capture						critical
--      Kill						critical
--      KillOrCapture				critical
--      CategoriesInArea			critical
--      ArmyStatCompare				critical
--      Protect						critical
--		Research					critical
--      Timer						critical
--      Basic						critical
--
--      CategoryStatCompare			obsolete/unused - MFD
--      Unknown						obsolete/unused - MFD
--      Reclaim						obsolete/unused - MFD
--      Locate						obsolete/unused - MFD
--      SpecificUnitsInArea			obsolete/unused - MFD
--      UnitStatCompare				obsolete/unused - MFD
---------------------------------------------------------------------

--*******************************************************************
-- TYPE: CAMERA
--*******************************************************************
-- Camera objective by roates
-- Creates markers that satisfy the objective when they are all inside of the camera viewport
--
-- Camera( objectiveType, CompletionStatus, title, description, positionTable)
--
-- objectiveType = 'primary' or 'bonus' etc...
-- completeState = 'complete' or 'incomplete'
-- title = title string table from map's string file
-- description = description string table from map's string file
-- positionTable = table of position tables where markers will be created. { {x1, y1, z1}, {x2, y2, z2} } format
---DEV NOTE: This is needed for tutorial. - bfricks 1/18/09
---------------------------------------------------------------------
function Camera(objectiveType, CompletionStatus, title, description, positionTable)
    local numMarkers = 0
    local curMarkers = 0

    local image = GetActionIcon('locate')

    local objective = AddObjective(objectiveType, CompletionStatus, title, description, image, positionTable)

    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( title, 'complete', resultStr, self.Tag )
    end

    local RemoveMarker = function(mark)
        mark:Destroy()
        curMarkers = curMarkers + 1

        UpdateObjective( title, 'Progress', '('..curMarkers..'/'..numMarkers..')', objective.Tag )
        objective:OnProgress(curMarkers, numMarkers)

        if objective.Active and curMarkers == numMarkers then
            --Win an Internet
            objective.Active = false
            UpdateObjective( title, 'complete', 'complete', objective.Tag )
            objective:OnResult(true)
        end
    end

    for i,v in positionTable do
        numMarkers = numMarkers + 1

        local newMark = import('/lua/sim/simcameramarkers.lua').AddCameraMarker(v)
        newMark:AddCallback(RemoveMarker)
    end

    objective:OnProgress(curMarkers, numMarkers)
    UpdateObjective( title, 'Progress', '('..curMarkers..'/'..numMarkers..')', objective.Tag )

    return objective
end

--*******************************************************************
-- TYPE: CAPTURE
--*******************************************************************
function Capture(Type,CompletionStatus,Title,Description,Target)
    Target.captured = 0
    Target.total = table.getn(Target.Units)
    local required = Target.NumRequired or Target.total
    local returnUnits = {}

    local image = GetActionIcon('capture')
    local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)

    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    local function OnUnitCaptured(unit, captor)
        table.insert(returnUnits, unit)
        if not objective.Active then
            return
        end

        Target.captured = Target.captured + 1
        local progress = string.format('(%s/%s)', Target.captured, required)
        objective:OnProgress(Target.captured,required)
        UpdateObjective( Title, 'Progress', progress, objective.Tag )
        if Target.captured >= required then
            objective.Active = false
            objective:OnResult(true, unit)
            UpdateObjective( Title, 'complete', "complete", objective.Tag )
        end
    end

    local function OnUnitKilled(unit)
        if not objective.Active then
            return
        end
        Target.total = Target.total - 1
        if Target.total < required then
            objective.Active = false
            objective:OnResult(false)
            UpdateObjective( Title, 'complete', 'failed', objective.Tag )
        end
    end

    for k,unit in Target.Units do
        if not unit:IsDead() then
            -- Mark the units unless MarkUnits == false
            if ( Target.MarkUnits == nil ) or Target.MarkUnits then
                local ObjectiveArrow = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow
                local spec = {}
                spec.AttachTo = unit
                spec.Offset = Target.ArrowOffset or 0
                spec.Size = Target.ArrowSize or 1.0
                local arrow = ObjectiveArrow(spec)
            end

            Triggers.CreateUnitCapturedTrigger(nil,OnUnitCaptured,unit)
            Triggers.CreateUnitDeathTrigger(OnUnitKilled, unit)
			Triggers.CreateUnitReclaimedTrigger(OnUnitKilled, unit) --same functionality as killed

            if Target.FlashVisible then
                FlashViz( unit )
            end
        else
            --treat as killed Matt 8.30.06
            OnUnitKilled(unit)
        end
    end

    local progress = string.format('(%s/%s)', Target.captured, required)
    UpdateObjective( Title, 'Progress', progress, objective.Tag )

    return objective
end


--*******************************************************************
-- TYPE: KILL
--*******************************************************************
function Kill(Type,CompletionStatus,Title,Description,Target)
	Target.killed = 0
	Target.total = table.getn(Target.Units)

	local image = GetActionIcon('kill')
	local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)

	-- call ManualResult
	objective.ManualResult = function(self, result)
		if not self.Active then
    		return
    	end
		objective.Active = false
		objective:OnResult(result)
		local resultStr
		if result then
			resultStr = 'complete'
		else
			resultStr = 'failed'
		end
		UpdateObjective( Title, 'complete', resultStr, objective.Tag)
	end

	local function OnUnitKilled(unit)
		Target.killed = Target.killed + 1

		local progress = string.format('(%s/%s)', Target.killed, Target.total)
		UpdateObjective( Title, 'Progress', progress, objective.Tag )
		objective:OnProgress(Target.killed,Target.total)

		if Target.killed == Target.total then
			UpdateObjective( Title, 'complete', "complete", objective.Tag )
			objective.Active = false
			objective:OnResult(true, unit)
		end
	end

	for k,unit in Target.Units do
		if not unit:IsDead() then
			-- Mark the units unless MarkUnits == false
			if ( Target.MarkUnits == nil ) or Target.MarkUnits then
				local ObjectiveArrow = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow
				local spec = {}
                spec.AttachTo = unit
                spec.Offset = Target.ArrowOffset or 0
                spec.Size = Target.ArrowSize or 1.0
				local arrow = ObjectiveArrow(spec)
			end
			if Target.FlashVisible then
				FlashViz( unit )
			end
			Triggers.CreateUnitDeathTrigger(OnUnitKilled, unit)
			Triggers.CreateUnitReclaimedTrigger(OnUnitKilled, unit) --same as killing for our purposes
		else
			OnUnitKilled(unit)
		end
	end

	local progress = string.format('(%s/%s)', Target.killed, Target.total)
	UpdateObjective( Title, 'Progress', progress, objective.Tag )

	return objective
end

--*******************************************************************
-- TYPE: KILL OR CAPTURE
--*******************************************************************
function KillOrCapture(Type,CompletionStatus,Title,Description,Target)
    Target.killed_or_captured = 0
    Target.total = table.getn(Target.Units)

    local image = GetActionIcon('KillOrCapture')
    local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)

    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    local function OnUnitDestroyed(unit)
        if not objective.Active then
            return
        end

        Target.killed_or_captured = Target.killed_or_captured + 1
        local progress = string.format('(%s/%s)', Target.killed_or_captured, Target.total)
        objective:OnProgress(Target.killed_or_captured,Target.total)
        UpdateObjective( Title, 'Progress', progress, objective.Tag )
        if Target.killed_or_captured == Target.total then
            objective.Active = false
            ---NOTE: passing the unit here is critical as this allows NIS work to reference the unit position, orientation, heading info
            ---			at the exact time of death. - bfricks 7/5/09
            objective:OnResult(true, unit)
            UpdateObjective( Title, 'complete', "complete", objective.Tag )
        end
    end

	---NOTE: this function allows us to add new units to the objective after it has been created.
	---			The only concern with this handling is that it is possible to complete the objective
	---			in between 'waves' of attackers. If this is not desired, currently the best fix is to
	---			handle the objective management in the mission/operation script. - bfricks 3/16/2009 10:01AM
    objective.AddTargetUnits = function(self, targetUnits, bNewUnits)
	    for k,unit in targetUnits do
	        if not unit:IsDead() then
	            -- Mark the units unless MarkUnits == false
	            if ( Target.MarkUnits == nil ) or Target.MarkUnits then
	                local ObjectiveArrow = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow
					local spec = {}
	                spec.AttachTo = unit
	                spec.Offset = Target.ArrowOffset or 0
	                spec.Size = Target.ArrowSize or 1.0
					local arrow = ObjectiveArrow(spec)
	            end

	            if Target.FlashVisible then
	                FlashViz( unit )
	            end

				---NOTE: revised to handle all three cases: capture/ reclaim/ and kill. - bfricks 6/12/09
	            Triggers.CreateUnitDestroyedTrigger(OnUnitDestroyed, unit)
	        else
	            OnUnitDestroyed(unit)
	        end

    		if bNewUnits then
    			objective:AddUnitTarget( unit )
    		end
	    end

    	if bNewUnits then
    		Target.total = Target.total + table.getn(targetUnits)
    		local progress = string.format('(%s/%s)', Target.killed_or_captured, Target.total)
    		UpdateObjective( Title, 'Progress', progress, objective.Tag )
    	end
    end

    objective:AddTargetUnits(Target.Units, false)

    local progress = string.format('(%s/%s)', Target.killed_or_captured, Target.total)
    UpdateObjective( Title, 'Progress', progress, objective.Tag )

    return objective
end

--*******************************************************************
-- TYPE: CATEGORIES IN AREA
--*******************************************************************
-- CategoriesInArea
--   Complete when specified units matching the target blueprint types are in
-- the target area. We don't care exactly which units they are (pre-built or
-- newly constructed) or how they got there (cheat teleport, etc). We just check
-- the area for what units are inside and look at the blueprints (and optionally
-- match the army, use -1 for don't care).
--
-- Target = {
--   Requirements = {
--       { Area = <areaName>, Category=<cat1>, CompareOp=<op>, Value=<x>, [ArmyIndex=<index>]},
--       { Area = <areaName>, Category=<cat2>, CompareOp=<op>, Value=<y>, [ArmyIndex=<index>] },
--       ...
--       { Area = <areaName>, Category=<cat3>, CompareOp=<op>, Value=<z>, [ArmyIndex=<index>] },
--   }
-- }
--
-- -- op is one of: '<=', '>=', '<', '>', or '=='
--
---------------------------------------------------------------------
function CategoriesInArea(Type,CompletionStatus,Title,Description,Action,Target)

    local image = GetActionIcon(Action)
    local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)
    local lastReqsMet = 0

    -- call ManualResult
    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    local function WatchArea(requirements)
        local totalReqs = table.getn(requirements)
        while objective.Active do
            local reqsMet = 0

            for i,requirement in requirements do
                local units = GetUnitsInRect(requirement.Rect)
                local cnt = 0
                if units then
                    for k,unit in units do
                        if not unit:IsDead() and not unit:IsBeingBuilt() then
                            if not requirement.ArmyIndex or (requirement.ArmyIndex == unit:GetArmy()) then
                                if EntityCategoryContains(requirement.Category, unit) then
                                    if not unit.Marked and objective.MarkUnits then
                                        unit.Marked = true
                                        local ObjectiveArrow = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow
										local spec = {}
						                spec.AttachTo = unit
						                spec.Offset = Target.ArrowOffset or 0
										spec.Size = Target.ArrowSize or 1.0
										local arrow = ObjectiveArrow(spec)

                                        objective:AddUnitTarget(unit)
                                    end
                                    cnt = cnt+1
                                end
                            end
                        end
                    end
                    --LOG('debug: CategoriesInArea: reqsmet '..reqsMet..'count '.. cnt )
                end
                if requirement.CompareFunc(cnt,requirement.Value) then
                    reqsMet = reqsMet +1
					if requirement.LinkedAreaArrow and requirement.LinkedAreaArrowActive then
						-- if the requirement is met, check to see if there is an area arrow that needs to be turned off
						requirement.LinkedAreaArrowActive = false
						requirement.LinkedAreaArrow:HideMesh()
					end
				elseif requirement.LinkedAreaArrow and not requirement.LinkedAreaArrowActive then
					-- if the requirement is not met, check to see if there is an area arrow that needs to be turned back on
					requirement.LinkedAreaArrowActive = true
					requirement.LinkedAreaArrow:ShowMesh()
                end
            end

            if lastReqsMet != reqsMet then
                local progress = string.format('(%s/%s)', reqsMet, totalReqs)
                UpdateObjective( Title, 'Progress', progress, objective.Tag )
                objective:OnProgress(reqsMet,totalReqs)
                lastReqsMet = reqsMet
            end

            if reqsMet == totalReqs then
                objective.Active = false
                objective:OnResult(true)
                UpdateObjective( Title, 'complete', 'complete', objective.Tag)
                return
            end
            WaitTicks(10)
        end
    end

    for k,requirement in Target.Requirements do
        local rect = ScenarioUtils.AreaToRect( requirement.Area )

        local w = rect.x1 - rect.x0
        local h = rect.y1 - rect.y0
        local x = rect.x0 + ( w / 2.0 )
        local z = rect.y0 + ( h / 2.0 )

		if Target.AddArrow then
			local arrowSpec = {}
			local arrowHeight = Target.ArrowHeight or 2.0
			arrowSpec.position = {x, GetTerrainHeight(x,z)+arrowHeight, z}
			arrowSpec.orientation = {0, 6.28, 0}
			arrowSpec.Size = Target.ArrowSize or 4.0
			arrowSpec.IgnoreVizRules = true

			if Target.ArrowMesh then
				arrowSpec.DefaultMesh = Target.ArrowMesh
			end

			local ArrowMarkerObj = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow(arrowSpec)

			-- tag the handle to the arrow to the requirement so it can be managed
			requirement.LinkedAreaArrowActive = true
			requirement.LinkedAreaArrow = ArrowMarkerObj

			table.insert( objective.UnitMarkers, ArrowMarkerObj )
		end

        if Target.MarkArea and not objective.Decals[requirement.Area] then
            local decal = CreateObjectiveDecal(x, z, w, h)
            objective.Decals[requirement.Area] = decal
        elseif Target.FlashVisible then
            FlashViz( requirement.Area )
        end

        if Target.MarkUnits then
            objective.MarkUnits = true
        end

        local reqRef = requirement
        reqRef.Rect = rect
        reqRef.CompareFunc = GetCompareFunc(requirement.CompareOp)
    end

    UpdateObjective( Title, 'Progress', string.format('(0/%d)', table.getsize(Target.Requirements)), objective.Tag )
    ForkThread( WatchArea, Target.Requirements )

    return objective
end

--*******************************************************************
-- TYPE: ARMY STAT COMPARE
--*******************************************************************
-- ArmyStatCompare
--   Army stat is compared <=, >=, >, <, or == to some value.
--
-- Target = {
--		Army=<index>,
--		StatName=<name>,
--		CompareOp=<op>,			-- op is one of: '<=', '>=', '<', '>', or '=='
--		Value=<value>,
--		[Category=<category>],		-- optional: to compare to a blueprint stat
--		ShowProgress,				-- optional: shows --/--. may not make sense for all compare types
--		ExcludeValue,				-- optional: if specified, the testValue and value will both be reduced by this amount
-- }
--
-- Note: Be careful when using '==' as the stat is only checked every 5 ticks.
--
---------------------------------------------------------------------
function ArmyStatCompare(Type,CompletionStatus,Title,Description,Action,Target)
    local image = GetActionIcon(Action)
    local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)

    local function WatchStat(statName,brain,compareFunc,value,category,excludeValue)
        local oldVal
        excludeValue = excludeValue or 0

        while objective.Active do
            local result = false
            local testVal = 0

            if category then
                testVal = brain:GetBlueprintStat(statName,category)

            else
                testVal = brain:GetArmyStat(statName,value).Value
            end

            if (Target.ShowProgress) then
                if (testVal ~= oldVal) then
                	local adjustedTestVal = (testVal - excludeValue) > 0 and (testVal - excludeValue) or 0
					local adjustedVal = value - excludeValue
                    local progress = string.format('(%s/%s)', adjustedTestVal, adjustedVal)
					LOG('*** progress! testVal:[', testVal, '] oldVal:[', oldVal, '] adjustedTestVal:[', adjustedTestVal, '] adjustedVal:[', adjustedVal, ']')
                    UpdateObjective( Title, 'Progress', progress, objective.Tag )
                    objective:OnProgress(adjustedTestVal,adjustedVal)
                    oldVal = testVal
                end
            end

            result = compareFunc(testVal,value)

            if result then
                objective.Active = false
                objective:OnResult(true)
                UpdateObjective( Title, 'complete', 'complete', objective.Tag )
                return
            end
            WaitTicks(5)
        end
    end

    local op = GetCompareFunc(Target.CompareOp)
    if op then
        ForkThread( WatchStat, Target.StatName, GetArmyBrain(Target.Army), op, Target.Value, Target.Category, Target.ExcludeValue )
    end

    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    return objective
end

--*******************************************************************
-- TYPE: PROTECT
--*******************************************************************
-- Protect
--   Fails if -- of units in list falls below NumRequired before the timer expires
-- or, in the case of no timer, the objective is manually update to complete.
--
-- Target = {
--       Units = {},
--       Timer = <seconds> or nil,   -- if nil, requires manual completion
--       NumRequired = <-->,          -- how many must survive
-- }
---------------------------------------------------------------------
function Protect(Type,CompletionStatus,Title,Description,Target)

    local image = GetActionIcon("protect")
    local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)
    local total = table.getn(Target.Units)
    local max = total
    local numRequired = Target.NumRequired or total
    local timer = nil

    local function OnUnitDestroyed(unit)
        if not objective.Active then
            return
        end

        total = total - 1
        objective:OnProgress( total, numRequired )

        if (Target.ShowProgress) then
            local progress = string.format('(%s/%s)', total, numRequired)
            UpdateObjective( Title, 'Progress', progress, objective.Tag )
        elseif (Target.PercentProgress) then
            --local progress = LOCF('(%s%%/%s%%)',math.ceil( total / max * 100),math.ceil( numRequired / max * 100))
            local progress = string.format('(%s%%)',math.ceil( total / max * 100))
            UpdateObjective( Title, 'Progress', progress, objective.Tag )
        end

        if objective.Active and total < numRequired then
            objective.Active = false
            objective:OnResult(false,unit)
            UpdateObjective( Title, 'complete', 'failed', objective.Tag)
            Sync.ObjectiveTimer = 0
            if timer then
                KillThread(timer)
            end
        end
    end

    local function OnExpired()
        if objective.Active then
            objective.Active = false
            objective:OnResult(true)
            UpdateObjective( Title, 'complete', 'complete', objective.Tag)
        end
        Sync.ObjectiveTimer = 0
    end

    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    if Target.Timer then
        timer = import('/lua/sim/ScenarioTriggers.lua').CreateTimerTrigger(
            OnExpired,
            Target.Timer,
            true
        )
    end

	---NOTE: revised to handle all three cases: capture/ reclaim/ and kill. - bfricks 6/12/09
    for k,v in Target.Units do
		---NOTE: revised to handle all three cases: capture/ reclaim/ and kill. - bfricks 6/12/09
		Triggers.CreateUnitDestroyedTrigger(OnUnitDestroyed, v)
    end

    if (Target.ShowProgress) then
        local progress = string.format('(%s/%s)', total, numRequired)
        UpdateObjective( Title, 'Progress', progress, objective.Tag )
    elseif (Target.PercentProgress) then
        --local progress = LOCF('(%s%%/%s%%)',math.ceil( total / max * 100),math.ceil( numRequired / max * 100))
        local progress = string.format('(%s%%)',math.ceil( total / max * 100))
        UpdateObjective( Title, 'Progress', progress, objective.Tag )
    end

    return objective
end

--*******************************************************************
-- TYPE: RESEARCH
--*******************************************************************
-- Research
-- Fails is research completion falls below NumRequired before the timer expires
-- or, in the case of no timer, the objective is manually updated to complete.
--
-- Target = {
--       AiBrain = ArmyBrainEntity,
--       ResearchList = {},
--		 ResearchEvent = 'complete',
--       Timer = <seconds> or nil,		-- if nil, requires manual completion
--       NumRequired = <-->,				-- how many must be completed
--		 ShowProgress/PercentProgress	-- how to show research completion rate
-- }
-------------------------------------------------------------
function Research(Type,CompletionStatus,Title,Description,Target)
    local image = GetActionIcon("research")
	local event = Target.ResearchEvent or 'complete'
	local aiBrain = Target.AiBrain
	local total = table.getn(Target.ResearchList)
	local numRequired = Target.NumRequired or total
    local max = total
	local numAquired = 0
    local timer = nil

    local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)

	-- Show initial progress
    if (Target.ShowProgress) then
        local progress = string.format('(%s/%s)', numAquired, numRequired)
        UpdateObjective( Title, 'Progress', progress, objective.Tag )
    elseif (Target.PercentProgress) then
        local progress = string.format('(%s%%)',math.ceil( numAquired / max * 100))
        UpdateObjective( Title, 'Progress', progress, objective.Tag )
    end

    local function OnResearchCompleted( researchName, event )
        if not objective.Active then
            return
        end

        total = total - 1
		numAquired = numAquired + 1
        objective:OnProgress( total, numRequired )

		if (Target.ShowProgress) then
			--local progress = string.format('(%s/%s)', numAquired, numRequired)
			--UpdateObjective( Title, 'Progress', researchName, objective.Tag )
			UpdateObjective(
				Title,
				'Target',
				{
					Type = 'Research',
					Value = string.format('%s:(%s/%s)', event, numAquired, numRequired),
					BlueprintId = nil,
					TargetTag = nil,
				},
				objective.Tag)

		elseif (Target.PercentProgress) then
			--local progress = string.format('(%s%%)',math.ceil( numAquired / max * 100))
			--UpdateObjective( Title, 'Progress', researchName, objective.Tag )
			UpdateObjective(
				Title,
				'Target',
				{
					Type = 'Research',
					Value = string.format('%s:(%s/%s)', event, numAquired, numRequired),
					BlueprintId = nil,
					TargetTag = nil,
				},
				objective.Tag)

		end

        if objective.Active and total == 0 then
            objective.Active = false
            objective:OnResult(true)
            UpdateObjective( Title, 'complete', 'complete', objective.Tag)
            Sync.ObjectiveTimer = 0
            if timer then
                KillThread(timer)
            end
        end
    end

    local function OnExpired()
        if objective.Active then
			objective.Active = false
			if numAquired < numRequired then
				objective:OnResult(false)
				UpdateObjective( Title, 'complete', 'failed', objective.Tag)
			else
				objective:OnResult(true)
				UpdateObjective( Title, 'complete', 'complete', objective.Tag)
			end
        end
        Sync.ObjectiveTimer = 0
    end

    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    if Target.Timer then
        timer = import('/lua/sim/ScenarioTriggers.lua').CreateTimerTrigger(
            OnExpired,
            Target.Timer,
            true
        )
    end

	-- Create Research Trigger callback
	for k,v in Target.ResearchList do
		---NOTE: ran into an issue where it was possible for scripts to AddObjective, then AddResultCallback such that
		---			the research trigger would fire off during the execution of AddObjective (therefore before AddResultCallback).
		---			This problem exposed a vulnerability in the objective system:
		---				any objective type that can be completed immediately, can lead to a game blocker if the operation script
		---				expects AddResultCallback to always lead to a callback function getting executed. Because in fact,
		---				AddResultCallback only leads to a callback IF it gets called before the objective executes the OnResult function.
		---			Soo... I am choosing to fork each trigger such that completion can not occur immediately. - bfricks 6/5/09
		ForkThread(Triggers.CreateOnResearchTrigger, OnResearchCompleted, aiBrain, v, event )
		--Triggers.CreateOnResearchTrigger( OnResearchCompleted, aiBrain, v, event )
	end

	-- Update the objective with the initial values.
	objective:OnProgress( numRequired-total, numRequired )

    return objective
end


--*******************************************************************
-- TYPE: TIMER
--*******************************************************************
-- Timer
--   OnResult() is called when the timer expires. The result depends on whether
-- ExpireResult is set to complete or failed.
--
-- Target = {
--       Timer = <seconds>
--       ExpireResult = 'complete' or 'failed'
-- }
---------------------------------------------------------------------
function Timer(Type,CompletionStatus,Title,Description,Target)

    local image = GetActionIcon("timer")
    local objective = AddObjective(Type,CompletionStatus,Title,Description,image,Target)

    -- call ManualResult
    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    local function onTick(newTime)
        UpdateObjective( Title, 'timer', {Time = newTime}, objective.Tag)
    end

    local function OnExpired()
        objective.Active = false
        if Target.ExpireResult == 'complete' then
            objective:OnResult(true)
            UpdateObjective( Title, 'complete', 'complete', objective.Tag)
        else
            objective:OnResult(false)
            UpdateObjective( Title, 'complete', 'failed', objective.Tag)
        end
        Sync.ObjectiveTimer = 0
    end

    import('/lua/sim/ScenarioTriggers.lua').CreateTimerTrigger(
        OnExpired,
        Target.Timer,
        false,
        true,
        onTick
    )

    return objective
end

--*******************************************************************
-- TYPE: BASIC
--*******************************************************************
function Basic(Type,CompletionStatus,Title,Description,Image,Target)
    local objective = AddObjective(Type,CompletionStatus,Title,Description,Image,Target)

    -- call ManualResult
    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        objective.Active = false
        objective:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, objective.Tag)
    end

    objective.AddBasicUnitTarget = function(self, unit)
        objective:AddUnitTarget( unit )
        local ObjectiveArrow = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow
		local spec = {}
		spec.AttachTo = unit
		spec.Offset = Target.ArrowOffset or 1.0
		spec.Size = Target.ArrowSize or 1.0
		local arrow = ObjectiveArrow(spec)

        table.insert( objective.UnitMarkers, arrow )
    end

    objective.AddTarget = function(self, target)
        if (target.Area) then
            local rect = ScenarioUtils.AreaToRect( target.Area )

            local w = rect.x1 - rect.x0
            local h = rect.y1 - rect.y0
            local x = rect.x0 + ( w / 2.0 )
            local z = rect.y0 + ( h / 2.0 )

            if target.MarkArea then
                objective.Decals[target.Area] = CreateObjectiveDecal(x, z, w, h)
            end
            if Target.FlashVisible then
                FlashViz( target.Area )
            end
        end
        if target.Areas and target.MarkArea then
            for k,v in target.Areas do
                local rect = ScenarioUtils.AreaToRect( v )

                local w = rect.x1 - rect.x0
                local h = rect.y1 - rect.y0
                local x = rect.x0 + ( w / 2.0 )
                local z = rect.y0 + ( h / 2.0 )

                objective.Decals[v] = CreateObjectiveDecal(x, z, w, h)
                if Target.FlashVisible then
                    FlashViz( v )
                end
            end
        end
        if (target.Units) then
            if (target.MarkUnits) then
                for k,unit in target.Units do
                    if not unit:IsDead() then
                        local ObjectiveArrow = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow
						local spec = {}
						spec.AttachTo = unit
						spec.Offset = Target.ArrowOffset or 0
						spec.Size = Target.ArrowSize or 1.0
						local arrow = ObjectiveArrow(spec)

                        table.insert( objective.UnitMarkers, arrow )

   				        if Target.AlwaysVisible or Target.AlwaysInRadar then
				        	---NOTE: due to how VizMarker has been setup - we need to force nil to explicitly mean false - bfricks 11/20/09
				        	if not Target.AlwaysVisible then Target.AlwaysVisible = false end
				        	if not Target.AlwaysInRadar then Target.AlwaysInRadar = false end
				            SetupVizMarker(self, unit, Target.AlwaysVisible, Target.AlwaysInRadar)
				        end

                        if Target.FlashVisible then
                            FlashViz( unit )
                        end
                    end
                end
            end
        end
    end

    if Target then
        objective:AddTarget(Target)
    end

    return objective
end

--*******************************************************************
-- CORE OBJECTIVE FUNCTIONS:
--*******************************************************************

---------------------------------------------------------------------
function IsComplete(obj)
    if obj then
        if obj.Complete then
            return true
        end
    end

    return false
end

---------------------------------------------------------------------
-- Adds objective for the objectives screen
---------------------------------------------------------------------
function AddObjective(Type,         		-- 'primary', 'bonus', etc
                      CompletionStatus,     -- 'complete', 'incomplete'
                      Title,        		-- e.g. "Destroy Radar Stations"
                      Description,  		-- e.g. "A reason why you need to destroy the radar stations"
                      ActionImage,			-- '/textures/ui/common/missions/mission1.dds'
                      Target,       		-- Can be one of:
                                    		--   Units = { unit1, unit2, ... }
                                    		--   Areas = { 'areaName1', 'areaName2', ... }
                      IsLoading,    		-- Are we loading a saved game?
                      loadedTag,     		-- If IsLoading is specified, what's the tag?
					  loadingProgress		-- If IsLoading is specifiec, what is the status of our progress?
                      )

    if Type == 'bonus' then
    	---NOTE: this seems obsolete in a big way... suggest removal after SC2 ships - bfricks 12/9/09
    	---			not to mention if it ever comes up - we will get mission script failures.
        return {Tag = 'Invalid'} -- bonus objectives cut
    end

    local tag

    if IsLoading then
        tag = loadedTag
    else
        tag = 'Objective' .. objNum
        objNum = objNum + 1

		---NOTE: converting to key-value pairs for easier referencing - bfricks 1/31/10
		local data = {}
		data.saveType				= Type
		data.saveCompletionStatus	= CompletionStatus
		data.saveTitle				= Title
		data.saveDescription		= Description
		data.saveActionImage		= ActionImage
		data.saveTarget				= Target
		data.saveIsLoading			= true
		data.saveLoadedTag			= tag
		data.saveProgress			= ''

        table.insert( SavedList, {AddArgs=data,Tag=tag} )
    end

    --LOG("Debug: AddObjective: ", Title,":", Description, " (Tag=",tag,")")

    -- Set up objective table to return.
    local objective = {
        -- Used to synchronize sim objectives with user side objectives
        Tag = tag,

        -- Whether the objective is in progress or not and does not indicate
        -- success or failure.
        Active = true,

        -- success or failure.
        Complete = (CompletionStatus == 'complete') and true or false,

        -- Decal table, key'd by area names
        Decals = {},

        -- Unit arrow table
        UnitMarkers = {},

        -- Visibility markers that we manage
        VizMarkers = {},

        -- Single decal
        Decal = false,

        -- Strategic icon overrides
        IconOverrides = {},

        -- For tracking targets
        NextTargetTag = 0,
        PositionUpdateThreads = {},

        Title = Title,
        Description = Description,

        SimStartTime = GetGameTimeSeconds(),

        -- Called on success or failure
        ResultCallbacks = {},
        AddResultCallback = function(self,cb)
            table.insert(self.ResultCallbacks,cb)
        end,

        -- Some objective types can provide progress updates (not success/fail)
        ProgressCallbacks = {},
        AddProgressCallback = function(self,cb)
            table.insert(self.ProgressCallbacks,cb)
        end,

        -- Don't override these if you want notification. Call Add???Callback
        -- intead
        OnResult = function(self,success,data)
			if ScenarioInfo.ReadyToBlockObjectiveUpdates then
				WARN('WARNING: OnResult is attempting to be called after OpEnded - skipping. - if this leads to operation failures pring to Campaign Design.')
				return
			end

            self.Complete = success

            for k,v in self.ResultCallbacks do v(success,data) end

            -- Destroy decals
            for k,v in self.Decals do v:Destroy() end

            -- Destroy unit marker things
            for k,v in self.UnitMarkers do
                v:Destroy()
            end

            -- Revert strategic icons
            for k,v in self.IconOverrides do
                if not v:BeenDestroyed() then
                    v:SetStrategicUnderlay("")
                end
            end

            -- Destroy visibility markers
            for k,v in self.VizMarkers do
                v:Destroy()
            end

            if self.PositionUpdateThreads then
                for k,v in self.PositionUpdateThreads do
                    if v then
                        KillThread(self.PositionUpdateThreads[k])
                        self.PositionUpdateThreads[k] = false
                    end
                end
            end
        end,

        OnProgress = function(self,current,total)
			if ScenarioInfo.ReadyToBlockObjectiveUpdates then
				WARN('WARNING: OnProgress is attempting to be called after OpEnded - skipping. - if this leads to operation failures pring to Campaign Design.')
				return
			end
            for k,v in self.ProgressCallbacks do v(current,total) end
        end,

        -- Call this to manually fail the objective
        Fail = function(self)
            self.Active = false
            self:OnResult(false)
            UpdateObjective(self.Title,'complete','failed',self.Tag)
        end,

        AddUnitTarget = function(self,unit) end, -- defined below
        AddAreaTarget = function(self,area) end, -- defined below
    }

    -- Takes a unit that is an objective target and uses its recon detect
    -- event to notify the objectives that we have a blip for the unit.
    local function SetupNotify(obj,unit,targetTag)

        -- Add a detectedBy callback to notify the user layer when our recon
        -- on the target comes in and out.
        local detectedByCB = function(cbunit,armyindex)
            --LOG('detected by ',armyindex, ' focus = ',GetFocusArmy())
            if not obj.Active then
                return
            end

            -- now if we've been detected by the focus army ...
            if armyindex == GetFocusArmy() then
                -- get the blip that is associated with the unit
                local blip = cbunit:GetBlip(armyindex)

                -- Only provide the target position to the user layer if
                -- the blip IsSeenEver() (i.e. has been identified).
                obj.PositionUpdateThreads[targetTag] = ForkThread(
                    function()
                        while obj.Active do
                            WaitTicks(10)
                            if blip:BeenDestroyed() then
                                return
                            end

                            if blip:IsSeenEver(armyindex) then
                                UpdateObjective(Title,
                                                'Target',
                                                {
                                                    Type = 'Position',
                                                    Value = blip:GetPosition(),
                                                    BlueprintId = blip:GetBlueprint().BlueprintId,
                                                    TargetTag=targetTag
                                                },
                                                obj.Tag )

                                -- If it's not mobile we can exit the thread since
                                -- the blip won't move.
                                if not unit:IsDead() and not unit:BeenDestroyed() and not EntityCategoryContains( categories.MOBILE, unit ) then
                                    return
                                end
                            end
                        end
                    end
                )

                local destroyCB = function(cbblip)
                    if not obj.Active then
                        return
                    end

                    if obj.PositionUpdateThreads[targetTag] then
                        --LOG('killing thread')
                        KillThread( obj.PositionUpdateThreads[targetTag] )
                        obj.PositionUpdateThreads[targetTag] = false
                    end

                    -- when the blip is destroyed, tell objectives we dont
                    -- have a blip anymore. This doesn't necessarily mean the
                    -- unit is killed, we simply lost the blip.
                    UpdateObjective(Title,
                                    'Target',
                                    {
                                        Type = 'Position',
                                        Value = nil,
                                        BlueprintId = nil,
                                        TargetTag=targetTag,
                                    },
                                    obj.Tag )
                end

                -- When the blip is destroyed, have it call this callback
                -- function (defined above)
                blip:AddDestroyHook(destroyCB)
            end
        end

        -- When the unit is detected by an army, have it call this callback
        -- function (defined above)
        unit:AddDetectedByHook(detectedByCB)

        -- See if we can detect the unit right now
        local blip = unit:GetBlip(GetFocusArmy())
        if blip then
            detectedByCB(unit,GetFocusArmy())
        end
    end

    -- Take an objective target unit that is owned by the focus army
    -- Info passed to user layer to handle zoom to button and chiclet image
    function SetupFocusNotify(obj, unit, targetTag)
        obj.PositionUpdateThreads[targetTag] = ForkThread(
            function()
                while obj.Active do
                    if unit:BeenDestroyed() then
                        return
                    end

                    UpdateObjective(Title,
                                    'Target',
                                    {
                                        Type = 'Position',
                                        Value = unit:GetPosition(),
                                        BlueprintId = unit:GetBlueprint().BlueprintId,
                                        TargetTag=targetTag
                                    },
                                    obj.Tag )

                    -- If it's not mobile we can exit the thread since
                    -- the unit won't move.
                    if not unit:IsDead() and not unit:BeenDestroyed() and not EntityCategoryContains( categories.MOBILE, unit ) then
                        return
                    end
                    WaitTicks(10)
                end
            end
        )

        local destroyCB = function()
            if not obj.Active then
                return
            end

            if obj.PositionUpdateThreads[targetTag] then
                --LOG('killing thread')
                KillThread( obj.PositionUpdateThreads[targetTag] )
                obj.PositionUpdateThreads[targetTag] = false
            end

            -- when the blip is destroyed, tell objectives we dont
            -- have a blip anymore. This doesn't necessarily mean the
            -- unit is killed, we simply lost the blip.
            UpdateObjective(Title,
                            'Target',
                            {
                                Type = 'Position',
                                Value = nil,
                                BlueprintId = nil,
                                TargetTag=targetTag,
                            },
                            obj.Tag )
        end

        -- When the unit is destroyed have it call this callback
        -- function (defined above)
        ---NOTE: updated to a destroyed trigger - which handles death, reclaim, and capture - bfricks 11/14/09
        Triggers.CreateUnitDestroyedTrigger(destroyCB, unit )
    end

    function SetupVizMarker(objective, object, bVision, bIntel)
        if IsEntity(object) then
            local pos = object:GetPosition()
            local spec = {
                X = pos[1],
                Z = pos[2],
                Radius = 8,
                LifeTime = -1,
                Omni = false,
                Vision = bVision,
                Radar = bIntel,
                Army = GetFocusArmy(),
            }
            local vizmarker = VizMarker(spec)
            object.Trash:Add(vizmarker)
            vizmarker:AttachBoneTo(-1,object,-1)
        else
            local rect = ScenarioUtils.AreaToRect(Target.Area)
            local width = rect.x1 - rect.x0
            local height = rect.y1 - rect.y0
            local spec = {
                X = rect.x0 + width/2,
                Z = rect.y0 + height/2,
                Radius = math.max( width, height ),
                LifeTime = -1,
                Omni = false,
                Vision = bVision,
                Radar = bIntel,
                Army = GetFocusArmy(),
            }
            local vizmarker = VizMarker(spec)
            table.insert(objective.VizMarkers,vizmarker);
        end
    end

    function FlashViz (object)
        if IsEntity(object) then

            local pos = object:GetPosition()
            local spec = {
                X = pos[1],
                Z = pos[2],
                Radius = 2,
                LifeTime = 1.00,
                Omni = false,
                Vision = true,
                Radar = false,
                Army = GetFocusArmy(),
            }
            local vizmarker = VizMarker(spec)
            object.Trash:Add(vizmarker)
            vizmarker:AttachBoneTo(-1,object,-1)
        else
            local rect = ScenarioUtils.AreaToRect(object)
            local width = rect.x1 - rect.x0
            local height = rect.y1 - rect.y0
            local spec = {
                X = rect.x0 + width/2,
                Z = rect.y0 + height/2,
                Radius = math.max( width, height ),
                LifeTime = 0.01,
                Omni = false,
                Vision = true,
                Radar = false,
                Army = GetFocusArmy(),
            }
            local vizmarker = VizMarker(spec)
        end
    end

    local userTargets = nil
    if Target.ShowFaction then
        if Target.ShowFaction == 'Cybran' then
            Target.Image = '/textures/ui/common/faction_icon-lg/cybran_ico.dds'
        elseif Target.ShowFaction == 'Aeon' then
            Target.Image = '/textures/ui/common/faction_icon-lg/aeon_ico.dds'
        elseif Target.ShowFaction == 'UEF' then
            Target.Image = '/textures/ui/common/faction_icon-lg/uef_ico.dds'
        end
    end

    if Target and Target.Requirements then
        for k,req in Target.Requirements do
            if req.Area then
				---NOTE: for this specific handling, we want to allow multiple area requirements to be suppported
				---			so we only set the table on the first run - every other time, we insert - bfricks 2/3/10
				if not userTargets then
					userTargets = {}
				end
                table.insert(userTargets, { Type = 'Area', Value = ScenarioUtils.AreaToRect(req.Area) })
            end
        end
    elseif Target and Target.Timer then
		userTargets = {}
        table.insert(userTargets, {Type = 'Timer', Time = Target.Timer})
	elseif Target and Target.ResearchList then
		userTargets = {}
		for k, tech in Target.ResearchList do
			local screenName = ResearchDefinitions[tech] and ResearchDefinitions[tech].NAME or "INVALID"
			table.insert(userTargets, {Type = 'Research', Value = tech, Name = screenName})
		end
	end

    if Target.Category then
        local bps = EntityCategoryGetUnitList(Target.Category)
        if table.getn(bps) > 0 then
			userTargets = {}
            table.insert(userTargets, { Type = 'Blueprint', BlueprintId = bps[1] })
        end
    end

    objective.AddUnitTarget = function(self,unit)
        self.NextTargetTag = self.NextTargetTag + 1
        if unit:GetArmy() == GetFocusArmy() then
            SetupFocusNotify(self,unit,self.NextTargetTag)
        else
            SetupNotify(self,unit,self.NextTargetTag)
        end

        if Target.AlwaysVisible or Target.AlwaysInRadar then
        	---NOTE: due to how VizMarker has been setup - we need to force nil to explicitly mean false - bfricks 11/20/09
        	if not Target.AlwaysVisible then Target.AlwaysVisible = false end
        	if not Target.AlwaysInRadar then Target.AlwaysInRadar = false end
            SetupVizMarker(self, unit, Target.AlwaysVisible, Target.AlwaysInRadar)
        end

        table.insert(self.IconOverrides,unit)

        -- Mark the units unless MarkUnits == false
        if ( Target.MarkUnits == nil ) or Target.MarkUnits then
            if Type == 'primary' then
                unit:SetStrategicUnderlay('icon_objective_primary')
            elseif Type == 'secondary' then
                unit:SetStrategicUnderlay('icon_objective_secondary')
            end
        end
    end

    objective.AddAreaTarget = function(self,area)
        self.NextTargetTag = self.NextTargetTag + 1
        UpdateObjective(Title,
                        'Target',
                        {
                            Type = 'Area',
                            Value = ScenarioUtils.AreaToRect(area),
                            TargetTag=self.NextTargetTag
                        },
                        self.Tag )

        if Target.AlwaysVisible or Target.AlwaysInRadar then
        	---NOTE: due to how VizMarker has been setup - we need to force nil to explicitly mean false - bfricks 11/20/09
        	if not Target.AlwaysVisible then Target.AlwaysVisible = false end
        	if not Target.AlwaysInRadar then Target.AlwaysInRadar = false end
            SetupVizMarker(self, area, Target.AlwaysVisible, Target.AlwaysInRadar)
        end
    end

    if Target then
        if Target.Units then
            for k,v in Target.Units do
                if v and v.IsDead and not v:IsDead() then
                    objective:AddUnitTarget(v)
                end
            end
        end

        if Target.Unit then
            if Target.Unit.IsDead and not Target.Unit:IsDead() then
                objective:AddUnitTarget(Target.Unit)
            end
        end

        if Target.Areas then
            for k,v in Target.Areas do
                objective:AddAreaTarget(v)
            end
        end

        if Target.Area then
            objective:AddAreaTarget(Target.Area)
        end
    end

	if ScenarioInfo.ReadyToBlockObjectiveUpdates then
		WARN('WARNING: AddObjective has been called after OpEnded has been set, and as such will be skipped. - if this leads to operation failures pring to Campaign Design.')
		return objective
	end

	---NOTE: this makes more sense at the end of our function - so moving it here, allowing me to more easily
	---			handle the OpEnded case without getting a broken objective on the mission script side - bfricks 12/9/09
    local userObjectiveData = {
        tag = tag,
        type = Type,
        complete = CompletionStatus,
        title = Title,
        description = Description,
        actionImage = ActionImage,
        targetImage = Target.Image,
        progress = loadingProgress or "",
        targets = userTargets,
        loading = IsLoading,
        StartTime = objective.SimStartTime,
    }

	---NOTE: adding the sound event for objective assigned - bfricks 1/6/10
	CreateSimSyncSound( Sound{ Bank = 'SC2', Cue = 'Interface/snd_UI_Objective_Received' } )

    if(not Sync.ObjectivesTable) then
        Sync.ObjectivesTable = {}
    end

    Sync.ObjectivesTable[tag] = userObjectiveData

    return objective
end

---------------------------------------------------------------------
function DeleteObjective(Objective, IsLoading)
    local userObjectiveUpdate = {
        tag = Objective.Tag,
        updateField = 'delete',
    }
    if not IsLoading then
        table.insert( SavedList, {DeleteArgs = userObjectiveUpdate} )
    end
    table.insert(Sync.ObjectivesUpdateTable, userObjectiveUpdate)
end

---------------------------------------------------------------------
-- Updates an objective, referencing it by objective title
---------------------------------------------------------------------
function UpdateObjective(Title, UpdateField, NewData, objTag, IsLoading, InTime)

	if ScenarioInfo.ReadyToBlockObjectiveUpdates then
		WARN('WARNING: UpdateObjective has been called after OpEnded has been set, and as such will be skipped. - if this leads to operation failures pring to Campaign Design.')
		return
	end

    if objTag == 'Invalid' then
        return
    end

    if(not Sync.ObjectivesUpdateTable) then
        Sync.ObjectivesUpdateTable = {}
    end

    if type(objTag) ~= 'string' then
        error('SimObjectives error: Invalid type for objTag in UpdateObjective.  String expected but got '
        .. type(objTag), 2)
    end
    if type(UpdateField) ~= 'string' then
        error('SimObjectives error: Invalid type for UpdateField in UpdateObjective. String expected but got ' .. type(UpdateField), 2)
    end
    --if type(Title) ~= 'string' then
    --    error('SimObjectives error: Invalid type for Title in UpdateObjective. String expected but got ' .. type(Title), 2)
    --end

    if not IsLoading then
		---NOTE: this system is fairly terrible - and should be gutted, but for time constraints, I am performing a surgical fix:
		---		rather than save every single update ever made, what we want to do here is only save that an update is needed when
		---		we are actually modifying the status of completion or progress. In all other cases - we can just NOT save the update
		---		since it will be auto-understood when the objective is re-added on load of a saved game. - bfricks 1/31/10

		if UpdateField == 'complete' or UpdateField == 'Progress' then
			-- search through all objectives that have been added to the objective list....
			local foundMatch = false
			for k, obj in SavedList do
				-- find the match
				if obj.Tag and obj.Tag == objTag then
					if obj.AddArgs then
						if UpdateField == 'complete' then
							-- in this case, we are going to save the status change for our objective to use on being re-added
							LOG('SIM OBJECTIVES: UpdateObjective: modifying the SavedList: old completetionStatus:[', obj.AddArgs.saveCompletionStatus, '] new:[', NewData, ']')
							obj.AddArgs.saveCompletionStatus = NewData
						elseif UpdateField == 'Progress' then
							-- in this case, we are going to save the progress change for our objective to use on being re-added
							LOG('SIM OBJECTIVES: UpdateObjective: modifying the SavedList: old progress:[', obj.AddArgs.saveProgress, '] new:[', NewData, ']')
							obj.AddArgs.saveProgress = NewData
						end
					else
						WARN('WARNING: somehow the objectives SavedList contains data that is not flagged as and AddArgs list - bug Campaign Design.')
					end

					foundMatch = true
					break
				end
			end

			if not foundMatch then
				WARN('WARNING: attmepting to update the status of an objective that does not appear in the SavedList - this should not be possible!')
			end
		end
    end

    -- All fields are stored with lowercase names
    UpdateField = string.lower(UpdateField)
    --$$$ If this table goes through any changes we need to change the Cpp equivalent not on UIObjectives.cpp
    if not (
        (UpdateField == 'type') or
        (UpdateField == 'complete') or
        (UpdateField == 'title') or
        (UpdateField == 'description') or
        (UpdateField == 'image') or
        (UpdateField == 'progress') or
        (UpdateField == 'target') or
        (UpdateField == 'timer') or
        (UpdateField == 'delete')
        )
      then
        error( 'Unknown UpdateField: ' .. UpdateField .. '.  Cannot process UpdateObjective request.', 2 )
    else
        local userObjectiveUpdate = {
            title = Title,
            updateField = UpdateField,
            updateData = NewData,
            tag = objTag,
            loading = IsLoading,
        }
        if UpdateField == 'complete' then
            userObjectiveUpdate['time'] = InTime or GetGameTimeSeconds()

            if NewData == 'complete' then
            	---NOTE: adding the sound event for objective completed - bfricks 12/6/09
				CreateSimSyncSound( Sound{ Bank = 'SC2', Cue = 'Interface/snd_UI_Objective_Complete' } )
			end
        end
        table.insert(Sync.ObjectivesUpdateTable, userObjectiveUpdate)
    end
end

---------------------------------------------------------------------
function GetCompareFunc( op )
    function gt(a,b) return a > b end
    function lt(a,b) return a < b end
    function gte(a,b) return a >= b end
    function lte(a,b) return a <= b end
    function eq(a,b) return a == b end

    if op == '<=' then return lte end
    if op == '>=' then return gte end
    if op == '<' then return lt end
    if op == '>' then return gt end
    if op == '==' then return eq end

    WARN("Unsupported CompareOp '",op,"'")
end


---------------------------------------------------------------------
function GetActionIcon(actionString)
    local action = string.lower(actionString)
    if action == "killorcapture"	then return "/icons/hud/objectives/obj_kill_u.dds"	end
    if action == "kill"     		then return "/icons/hud/objectives/obj_kill_u.dds"	end
    if action == "capture"  		then return "/icons/hud/objectives/obj_capture_u.dds"  end
    if action == "build"    		then return "/icons/hud/objectives/obj_build_u.dds"    end
    if action == "protect"  		then return "/icons/hud/objectives/obj_protect_u.dds"         end
    if action == "timer"    		then return "/game/orders/guard_btn_up.dds"         end
    if action == "move"     		then return "/icons/hud/objectives/obj_move_u.dds"          end
    if action == "reclaim"  		then return "/icons/hud/objectives/obj_reclaim_u.dds"       end
    if action == "repair"   		then return "/icons/hud/objectives/obj_repair_u.dds"        end
    if action == "locate"   		then return "/icons/hud/objectives/obj_locate_u.dds"          end
    if action == "group"    		then return "/game/orders/move_btn_up.dds"          end
	if action == "research"			then return "/icons/hud/objectives/obj_research_u.dds" end
    return ""
end

---------------------------------------------------------------------
function CreateObjectiveDecal(x, z, w, h)
    return CreateDecal(Vector(x,GetTerrainHeight(x,z),z), 0, objectiveDecal, '', 'Water Albedo', w, h, DecalLOD, 0, 1)
end

--*******************************************************************
-- SIM INIT:
--*******************************************************************

---------------------------------------------------------------------
---DEV NOTE: OnPostLoad() is tied into SimInit. - bfricks 1/18/09
---------------------------------------------------------------------
function OnPostLoad()
	LOG('SIM OBJECTIVES: OnPostLoad: checking for objectives...')

	for k,v in SavedList do
		if v.AddArgs then
			LOG('SIM OBJECTIVES: OnPostLoad: caling AddObjective for:[', v.AddArgs.saveTitle, '] status:[', v.AddArgs.saveCompletionStatus, '] progress:[', v.AddArgs.saveProgress, ']')
			AddObjective(
				v.AddArgs.saveType,					---Type,         		-- 'primary', 'bonus', etc
				v.AddArgs.saveCompletionStatus,		---CompletionStatus,	-- 'complete', 'incomplete'
				v.AddArgs.saveTitle,				---Title,        		-- e.g. "Destroy Radar Stations"
				v.AddArgs.saveDescription,			---Description,  		-- e.g. "A reason why you need to destroy the radar stations"
				v.AddArgs.saveActionImage,			---ActionImage,			-- '/textures/ui/common/missions/mission1.dds'
				v.AddArgs.saveTarget,				---Target,       		-- Can be one of:
				v.AddArgs.saveIsLoading,			---IsLoading,    		-- Are we loading a saved game?
				v.AddArgs.saveLoadedTag,			---loadedTag     		-- If IsLoading is specified, what's the tag?
				v.AddArgs.saveProgress				---loadingProgress		-- If IsLoading is specified, what is the status of our progress?
			)
		elseif v.UpdateArgs then
			WARN('SIM OBJECTIVES: OnPostLoad: trying to call UpdateObjective - DEPRICATED')
			---UpdateObjective(unpack(v.UpdateArgs))
		elseif v.DeleteArgs then
			DeleteObjective(v.DeleteArgs, true)
		end
	end
end

--*******************************************************************
-- CUSTOM OBJECTIVE FUNCTIONS:
--*******************************************************************

---------------------------------------------------------------------
-- ControlGroup
--   Complete when specified units matching the target blueprint types are in
-- a control group. We don't care exactly which units they are (pre-built or
-- newly constructed), as long as the requirements are ment. We just check
-- the area for what units are in control groups and look at the blueprints (and optionally
-- match the army, use -1 for don't care).
--
-- Target = {
--   Requirements = {
--       {  Category=<cat1>, CompareOp=<op>, Value=<x>, [ArmyIndex=<index>]},
--       {  Category=<cat2>, CompareOp=<op>, Value=<y>, [ArmyIndex=<index>] },
--       ...
--       {  Category=<cat3>, CompareOp=<op>, Value=<z>, [ArmyIndex=<index>] },
--   }
-- }
--
-- -- op is one of: '<=', '>=', '<', '>', or '=='
---------------------------------------------------------------------
function ControlGroup(Type,CompletionStatus,Title,Description,Target)

    local image = GetActionIcon('group')
    local objective = AddObjective(Type, CompletionStatus, Title, Description, image, Target)
    local lastReqsMet = -1

    -- call ManualResult
    objective.ManualResult = function(self, result)
    	if not self.Active then
    		return
    	end
        self.Active = false
        self:OnResult(result)
        local resultStr
        if result then
            resultStr = 'complete'
        else
            resultStr = 'failed'
        end
        UpdateObjective( Title, 'complete', resultStr, self.Tag )
    end

    local function WatchGroups(requirements)
        local totalReqs = table.getn(requirements)
        while objective.Active do
            local reqsMet = 0

            for i,requirement in requirements do
                local units = ScenarioInfo.ControlGroupUnits
                local cnt = 0
                if units then
                    for k,unit in units do
                        if not requirement.ArmyIndex or (requirement.ArmyIndex == unit:GetArmy()) then
                            if EntityCategoryContains(requirement.Category, unit) then
                                if not unit.Marked and objective.MarkUnits then
                                    unit.Marked = true
                                    local ObjectiveArrow = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow
									local spec = {}
									spec.AttachTo = unit
									spec.Offset = Target.ArrowOffset or 0
									spec.Size = Target.ArrowSize or 1.0
									local arrow = ObjectiveArrow(spec)

                                    objective:AddUnitTarget(unit)
                                end
                                cnt = cnt+1
                            end
                        end
                    end
                    --LOG('debug: ControlGroup: reqsmet '..reqsMet..'count '.. cnt )
                end
                if not requirement.CompareFunc then
                    requirement.CompareFunc = GetCompareFunc(requirement.CompareOp)
                end
                if requirement.CompareFunc(cnt,requirement.Value) then
                    reqsMet = reqsMet +1
                end
            end

            if lastReqsMet != reqsMet then
                local progress = string.format('(%s/%s)', reqsMet, totalReqs)
                UpdateObjective( Title, 'Progress', progress, objective.Tag )
                objective:OnProgress(reqsMet,totalReqs)
                lastReqsMet = reqsMet
            end

            if reqsMet == totalReqs then
                objective.Active = false
                objective:OnResult(true)
                UpdateObjective( Title, 'complete', 'complete', objective.Tag)
                return
            end
            WaitTicks(10)
        end
    end

    UpdateObjective( Title, 'Progress', '(0/0)', objective.Tag )
    ForkThread( WatchGroups, Target.Requirements )

    return objective
end

---------------------------------------------------------------------
-- CreateGroup
--
--   Takes list of objective tables which are produced by the objective creation
-- functions such as Kill, Protect, Capture, etc.
--
--   UserCallback is executed when all objectives in the list are complete
---DEV NOTE: Need to investigate this further - but in general it looks like we are
---					creating a parent objective that completes when the NumRequired quantity of
---					children objectives are themselves complete.
---					This was used in Op6 for FA. - bfricks 1/18/09
---------------------------------------------------------------------
function CreateGroup( name, userCallback, numRequired )
    LOG('Creating objective group ',name)
    local objectiveGroup =  {
        Name = name,
        Active = true,
        Objectives = {},
        NumRequired = numRequired,
        NumCompleted = 0,
        AddObjective = function(self,objective) end, -- defined later
        RemoveObjective = function(self,objective) end, -- defined later
        OnComplete = userCallback,
    }

    local function OnResult(result)
        if not objectiveGroup.Active then
            LOG('ObjectiveGroup ',objectiveGroup.Name,' is not active.')
            return
        end

        if result then
            objectiveGroup.NumCompleted = objectiveGroup.NumCompleted + 1
        end

        if objectiveGroup.NumRequired then
            LOG('ObjectiveGroup ',objectiveGroup.Name,' Progress ',objectiveGroup.NumRequired, '/',objectiveGroup.NumCompleted)
            if objectiveGroup.NumCompleted < objectiveGroup.NumRequired then
                return
            end
        else
            if objectiveGroup.Objectives then
                for k,v in objectiveGroup.Objectives do
                    if v.Active then
                        return
                    end
                end
            end
        end

        -- Complete!
        objectiveGroup.Active = false
        objectiveGroup.OnComplete()
    end

    objectiveGroup.AddObjective = function(self,objective)
        table.insert(self.Objectives,objective)
        objective:AddResultCallback(OnResult)
    end

    objectiveGroup.RemoveObjective = function(self,objective)
        table.removeByValue(self.Objectives,objective)
    end

    return objectiveGroup
end
