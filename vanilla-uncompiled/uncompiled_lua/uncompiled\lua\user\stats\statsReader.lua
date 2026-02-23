--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

 --[[
 -- 
 --   Return a statistic for the current player.
 --   calls include, randomStat(), GetStatNo(), CountStats()
 --
 --]]
 
 
---local statsLog = import('/lua/user/stats/statsLogic.lua').GetCurrent()
---local statsBase = import('/lua/user/stats/stats.lua').stats.items
local Prefs = import('/lua/user/prefs.lua')

function CountStats()
    local doNotSave = true
    local curStats = Prefs.GetFromCurrentProfile('stats')

    if curStats == nil then
        curStats = import('/lua/user/stats/statsLogic.lua').GetCurrent( doNotSave )
    end 
    local cnt = 0
    for k, v in curStats do
        if (v.value ~= nil) then
            cnt = cnt+1
        end
    end
    return cnt
end

function GetStat( idx )
   local curStats = Prefs.GetFromCurrentProfile('stats')

   if curStats == nil then
       curStats = import('/lua/user/stats/statsLogic.lua').GetCurrent()
   end 
   local currstat = 0
   local stat = nil
   for k, v in curStats do
       if v.value ~= nil then
           currstat = currstat +1
           if currstat == idx then
               stat = v
               break
           end
       end
   end
   return stat
end

function GetStatName( key ) 
    local text = 'stat'
    local statsBase = import('/lua/stats/stats.lua').stats.items
    for k, v in statsBase do
       if v.value~=nil then
          if v.key == key then
              statName = v.locString
                      
              text = LOC(statName)
              break
          end
        end
    end
    return text
end

function GetStatNo( idx )
    local data = ''
    local stat = nil
    local max = CountStats()
    if max < idx then
        idx = max
    end
    stat = GetStat( idx )
    if string.len(stat.value) > 1 then
        data = string.format("%u", stat.value)
        LOG('trimmed statDATA:'..data)
    else
        data = stat.value
        LOG('statDATA:'..data)
    end
    
    if stat~= nil then
        data = GetStatName(stat.key)..":"..data
    end
    LOG('Stat id'..idx..data)
    return data
end

function GetRandomStat()
    local data = ''
    local max = countStats()
    local idx = Random(1,max)
    return GetStatNo( idx )
end