-----------------------------------------------------------------------------
--  File     : /lua/sim/Buff.lua
--  Author(s): John Comes, Gordon Duclos
--  Summary  : Buff application and removal methods
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

-- The Unit's BuffTable for applied buffs looks like this:
--
-- Unit.Buffs = {
--    Affects = {
--        <AffectType (Regen/MaxHealth/etc)> = {
--            BuffName = {
--                Count = i,
--                Add = X,
--                Mult = X,
--            }
--        }
--    }
--    BuffTable = {
--        <BuffType (LEVEL/CATEGORY)> = {
--            BuffName = {
--                Count = i,
--                Trash = trashbag,
--            }
--        }
--    }

-- Function to apply a buff to a unit.
-- This function is a fire-and-forget.  Apply this and it'll be applied over time if there is a duration.
function ApplyBuff(unit, buffName, instigator)

    if unit:IsDeadForever() then 
        return 
    end
    
    instigator = instigator or unit

    --buff = table of buff data
    local def = Buffs[buffName]
    if not def then
        error("*ERROR: Tried to add a buff that doesn\'t exist! Name: ".. buffName, 2)
        return
    end
    
    if def.EntityCategory then
        local cat = ParseEntityCategory(def.EntityCategory)
        if not EntityCategoryContains(cat, unit) then
            return
        end
    end
    
    if def.BuffCheckFunction then
        if not def:BuffCheckFunction(unit) then
            return
        end
    end
    
    local ubt = unit.Buffs.BuffTable

    if def.Stacks == 'REPLACE' and ubt[def.BuffType] then
        for key, bufftbl in unit.Buffs.BuffTable[def.BuffType] do
            RemoveBuff(unit, key, true)
        end
    end

	if def.Stacks == 'REFRESH' and ubt[def.BuffType] and table.getsize(ubt[def.BuffType]) > 0 then
        for key, bufftbl in ubt[def.BuffType] do
			--If the buff has a duration, then refresh it's duration thread.
			if def.Duration and def.Duration > 0 then
				if buffTable.DurationPulse then
					-- Kill the previous buffs trash (e.g. previous BuffWorkThread)
					bufftbl.Trash:Destroy()
					local thread = ForkThread(BuffWorkThread, unit, buffName, instigator) 
					unit.Trash:Add(thread)
					bufftbl.Trash:Add(thread)
				else
					local curTick = GetGameTick()
					bufftbl.LastTick = curTick + (def.Duration * 10)
				end
			end
        end
		return
	end
    
    --If add this buff to the list of buffs the unit has becareful of stacking buffs.
    if not ubt[def.BuffType] then
        ubt[def.BuffType] = {}
    end
    
    if def.Stacks == 'IGNORE' and ubt[def.BuffType] and table.getsize(ubt[def.BuffType]) > 0 then
        return
    end
    
    local data = ubt[def.BuffType][buffName]
    if not data then
        -- This is a new buff (as opposed to an additional one being stacked)
        data = {
            Count = 1,
			LastTick = -1,
            Trash = TrashBag(),
            BuffName = buffName,
        }
        ubt[def.BuffType][buffName] = data
    else
        -- This buff is already on the unit so stack another by incrementing the
        -- counts. data.Count is how many times the buff has been applied
        data.Count = data.Count + 1
        
    end
    
    local uaffects = unit.Buffs.Affects
    if def.Affects then
        for k,v in def.Affects do
            -- Don't save off 'instant' type affects like health and energy
            if k != 'Health' and k != 'Energy' then
                if not uaffects[k] then
                    uaffects[k] = {}
                end
                
                if not uaffects[k][buffName] then
                    -- This is a new affect.
                    local affectdata = { 
                        BuffName = buffName, 
                        Count = 1, 
                    }
                    for buffkey, buffval in v do
                        affectdata[buffkey] = buffval
                    end
                    uaffects[k][buffName] = affectdata
                else
                    -- This affect is already there, increment the count
                    uaffects[k][buffName].Count = uaffects[k][buffName].Count + 1
                end
            end
        end
    end
    
    --If the buff has a duration, then 
    if def.Duration and def.Duration > 0 then
		local curTick = GetGameTick()
		data.LastTick = curTick + (def.Duration * 10)
        local thread = ForkThread(BuffWorkThread, unit, buffName, instigator) 
        unit.Trash:Add(thread)
        data.Trash:Add(thread)
    end
    
    PlayBuffEffect(unit, buffName, data.Trash)
    
    ubt[def.BuffType][buffName] = data

    if def.OnApplyBuff then
        def:OnApplyBuff(unit, instigator)
    end
    
    --LOG('*DEBUG: Applying buff :',buffName, ' to unit ',unit:GetUnitId())
    --LOG('Buff = ',repr(ubt[def.BuffType][buffName]))
    --LOG('Affects = ',repr(uaffects))
    BuffAffectUnit(unit, buffName, instigator, false)
end

--Function to do work on the buff.  Apply it over time and in pulses.
function BuffWorkThread(unit, buffName, instigator)
    
    local buffTable = Buffs[buffName]
    
    --Non-Pulsing Buff
    local totPulses = buffTable.DurationPulse
    
    if not totPulses then
		local curTick = GetGameTick()
		local lastTick = unit.Buffs.BuffTable[buffTable.BuffType][buffName].LastTick
		while curTick < lastTick do
			WaitTicks(lastTick - curTick)
			curTick = GetGameTick()
			lastTick = unit.Buffs.BuffTable[buffTable.BuffType][buffName].LastTick
		end
    else
        local pulse = 0
        local pulseTime = buffTable.Duration / totPulses
    
        while pulse <= totPulses and not unit:IsDead() do
            WaitSeconds(pulseTime)
            BuffAffectUnit(unit, buffName, instigator, false)
            pulse = pulse + 1
        end
    end

    RemoveBuff(unit, buffName)
end

--Function to affect the unit.  Everytime you want to affect a new part of unit, add it in here.
--afterRemove is a bool that defines if this buff is affecting after the removal of a buff.  
--We reaffect the unit to make sure that buff type is recalculated accurately without the buff that was on the unit.
--However, this doesn't work for stunned units because it's a fire-and-forget type buff, not a fire-and-keep-track-of type buff.
function BuffAffectUnit(unit, buffName, instigator, afterRemove)
    
    local buffDef = Buffs[buffName]
    local buffAffectTable = buffDef.Affects

	if not buffAffectTable then
		WARN('*Trying to apply a buff(' .. buffName .. ') that does nothing, specify an affect table.' )
		return
	end
    
    if buffDef.OnBuffAffect and not afterRemove then
        buffDef:OnBuffAffect(unit, instigator)
    end
	
	for atype, vals in buffAffectTable do
		if not BuffAffects[atype] then
			WARN('*BUFF ERROR: Trying to apply a buff(' .. buffName .. ') for an invalid type - ' .. atype)
			continue
		end	

		BuffAffects[atype](unit, buffName, buffDef.WeaponCategory, afterRemove )
	end
end

--Calculates the buff from all the buffs of the same time the unit has.
function BuffCalculate( unit, buffName, affectType, initialVal )
    
    --Add all the 
    local adds = 0
    local mults = 1.0
    
    local highestCeil = false
    local lowestFloor = false
    
    if not unit.Buffs.Affects[affectType] then 
		return initialVal 
	end
    
    for k, v in unit.Buffs.Affects[affectType] do
    
        if v.Add and v.Add != 0 then
            adds = adds + (v.Add * v.Count)
        end
        
        if v.Mult then
			mults = mults + (v.Mult * v.Count)
            if mults < 0 then
                mults = 0
            end
        end
        
        if v.Ceil and (not highestCeil or highestCeil < v.Ceil) then
            highestCeil = v.Ceil
        end
        
        if v.Floor and (not lowestFloor or lowestFloor > v.Floor) then
            lowestFloor = v.Floor
        end
    end
    
    --Adds are calculated first, then the mults.  May want to expand that later.
    local returnVal = (initialVal + adds) * mults
    
    if lowestFloor and returnVal < lowestFloor then 
		returnVal = lowestFloor 
	end
    
    if highestCeil and returnVal > highestCeil then 
		returnVal = highestCeil 
	end 
    
    return returnVal
end

-- Removes buffs
function RemoveBuff(unit, buffName, removeAllCounts, instigator)
    
    local def = Buffs[buffName]
    local unitBuff = unit.Buffs.BuffTable[def.BuffType][buffName]
    
    for atype,_ in def.Affects do
        local list = unit.Buffs.Affects[atype]
        if list and list[buffName] then
            -- If we're removing all buffs of this name, only remove as 
            -- many affects as there are buffs since other buffs may have
            -- added these same affects.
            if removeAllCounts then
                list[buffName].Count = list[buffName].Count - unitBuff.Count
            else
                list[buffName].Count = list[buffName].Count - 1
            end
            
            if list[buffName].Count <= 0 then
                list[buffName] = nil
            end
        end
    end

	if not unitBuff.Count then
        local stg = "*WARNING: BUFF: unitBuff.Count is nil.  Unit: "..unit:GetUnitId().." Buff Name: ".. buffName.." Unit BuffTable: ", repr(unitBuff)
        LOG(stg)
        return
    else
        unitBuff.Count = unitBuff.Count - 1
    end

    if removeAllCounts or unitBuff.Count <= 0 then
        -- unit:PlayEffect('RemoveBuff', buffName)
        unitBuff.Trash:Destroy()
        unit.Buffs.BuffTable[def.BuffType][buffName] = nil
    end

    if def.OnBuffRemove then
        def:OnBuffRemove(unit, instigator)
    end

    -- FIXME: This doesn't work because the magic sync table doesn't detect
    -- the change. Need to give all child tables magic meta tables too.
    if def.Icon then
        -- If the user layer was displaying an icon, remove it from the sync table
        local newTable = unit.Sync.Buffs
        table.removeByValue(newTable,buffName)
        unit.Sync.Buffs = table.copy(newTable)
    end

    BuffAffectUnit(unit, buffName, unit, true)
    
    --LOG('*BUFF: Removed ', buffName)
end

function HasBuff(unit, buffName)
    local def = Buffs[buffName]
    if not def then
        return false
    end
    local bonu = unit.Buffs.BuffTable[def.BuffType][buffName]
    if bonu then
        return true
    end
    return false
end

function PlayBuffEffect(unit, buffName, trsh)
    
    local def = Buffs[buffName]
    if not def.Effects then 
        return 
    end
    
	local emitters = CreateAttachedEmitters( unit, 0, unit:GetArmy(), fx )

	for _, fx in emitters do
		if def.EffectsScale then
            fx:ScaleEmitter(def.EffectsScale)
        end
        trsh:Add(fx)
        unit.Trash:Add(fx)
	end
end

--
-- DEBUG FUNCTIONS
-- 
_G.PrintBuffs = function()
    local selection = DebugGetSelection()
    for k,unit in selection do
        if unit.Buffs then
            LOG('Buffs = '..repr(unit.Buffs))
        end
    end
end