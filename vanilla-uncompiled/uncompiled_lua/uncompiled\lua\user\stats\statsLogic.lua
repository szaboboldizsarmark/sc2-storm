-- stats logic code
local Prefs = import('/lua/user/prefs.lua')
local Achievs = import ('/lua/user/stats/Achievements.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

--local sessionInfo = SessionGetScenarioInfo()
-- contains the current stats data
local stats
-- handy mapping of keys to stat items
local statItemMap

local oldAchievements = {}
local newAchievements = {}
local currentmap =''
local gamemode = ''
local gmcode = 0
local gmdiff = -1
local gametype = ''
local myFaction = ''

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
          table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= string.len(str) then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


function split_path(str)
   return split(str,'[\\/]+')
end

-- returns the stats table with any adjustments needed
function GetStatsData()
    if not stats then
        stats = import('/lua/user/stats/stats.lua').stats

        -- build stat item map
        statItemMap = {}
        local itms = table.getn(stats.items)
        for sindex = 1, itms do
          statItemMap[stats.items[sindex].key] = table.deepcopy(stats.items[sindex])
        end
    end
    return stats
end

-- returns a copy of the current stats table, fills in with defaults if not found
-- also will create an stats section if needed
function GetCurrent( skipSave )
--TODO:  maps, save load properly

    local curStats = Prefs.GetFromCurrentProfile('stats')
    if not curStats then  -- make a table if there aren't stats yet
        curStats = {}
    end
    local needSave = false

    local locStats = GetStatsData()
    local itms = table.getn(locStats.items)
    for index = 1, itms do
        local item = locStats.items[index]
        if curStats[index] == nil then
            needSave = true
            curStats[index] = {}
            curStats[index].key = item.key
            if curStats[index].value == nil then
              curStats[index].value = item.default
            end
            curStats[index].type = item.type
            if item.lev then
              curStats[index].lev = item.lev
            end
            if item.fac then
              curStats[index].fac = item.fac
            end
        end
        if item.type == 'faction_build' then
            curStats[index].key = item.key
            curStats[index].type = item.type
            local faccnt = table.getn(item.factions)
            if curStats[index].factions == nil then  -- build the faction
                curStats[index].factions = {}
                for findex = 1, faccnt do
                    local facitem = item.factions[findex]
                    if curStats[index].factions[findex] == nil then
                        curStats[index].factions[findex] = {}
                        curStats[index].factions[findex].fac = facitem.fac

                        ---- could actually search for units expected.... hard code to 1.
                        local unitcnt = table.getn(facitem.units)
                        local facunits = {}
                        facunits = facitem.units
                        if curStats[index].factions[findex].units == nil then
                          curStats[index].factions[findex].units = {}
                          curStats[index].factions[findex].units[unitcnt]= {}
                          curStats[index].factions[findex].units[unitcnt].key = facitem.units[1].key
                          curStats[index].factions[findex].units[unitcnt].value  = facitem.units[1].default
                        end
                    end
                end
                needSave = true
            end
        elseif item.type == 'faction_win' then
            curStats[index].key = item.key
            curStats[index].type = item.type
            local faccnt = table.getn(item.factions)
            if curStats[index].factions == nil then  -- build the faction
                curStats[index].factions = {}
                for findex = 1, faccnt do
                    local facitem = item.factions[findex]
                    if curStats[index].factions[findex] == nil then
                        curStats[index].factions[findex] = {}
                       curStats[index].factions[findex].fac = facitem.fac
                        curStats[index].factions[findex].skirmish_played = facitem.skirmish_played
                        curStats[index].factions[findex].skirmish_won = facitem.skirmish_won
                    end
                end
                needSave = true
            end
        elseif item.type == 'map' then
            local mapcnt = table.getn(item.maps)
            if curStats[index].maps == nil then
                curStats[index].maps = {}
                for mindex = 1, mapcnt do
                    local mapitem = item.maps[mindex]
                    if curStats[index].maps[mindex] == nil then
                        curStats[index].maps[mindex] = {}
                        curStats[index].maps[mindex].key = mapitem.key          -- map name
                        curStats[index].maps[mindex].lev = mapitem.lev          -- 1:easy 2:medium 4:hard
                        curStats[index].maps[mindex].winmode = mapitem.winmode  -- 1:assasination 2:anialation 4:KOTH 8:Control 16:multiplayer
                        curStats[index].maps[mindex].multi = mapitem.multi      -- won in a multiplayer game
                        curStats[index].maps[mindex].skirmish = mapitem.skirmish -- won in a skirmish game
                    end
                end
                needSave = true
            end
        end
    end
    if needSave and not skipSave then
        Prefs.SetToCurrentProfile('stats', curStats)
        UIUtil.SavePreferences()
    end
    return curStats
end

-- given a well formed stats table, sets them in to the current stats, and applies them
-- if compareStats table is passed in, uses that to compare instead of current set
function SetCurrent(newStats)
    -- don't save until after apply in case new stats corrupt something
    Prefs.SetToCurrentProfile('stats', newStats)
    UIUtil.SavePreferences()
end


-- resets all stats to their default
function ResetToDefaults()
    local resetStats = {}

    local locStats = GetStatsData()
    local itms = table.getn(locStats.items)
    for index = 1, itms do
        resetStats[index] = {}
        resetStats[index].key   = locStats.items[index].key
        resetStats[index].value = locStats.items[index].default
        resetStats[index].type  = locStats.items[index].type
        if locStats.items[index].lev then
            resetStats[index].lev   = locStats.items[index].lev
        end

       -- resetStats[index].locStats.items[index].key] = locStats.items[index].default
       -- resetStats[locStats.items[index].key].type = locStats.items[index].type
        if locStats.items[index].type == 'map' then
            local mapcnt = table.getn(locStats.items[index].maps)
            resetStats[index].maps = {}
            for mindex = 1, mapcnt do
                local mapitem = locStats.items[index].maps[mindex]
                if resetStats[index].maps[mindex] == nil then
                    resetStats[index].maps[mindex] = {}
                end
                resetStats[index].maps[mindex].key = mapitem.key
                resetStats[index].maps[mindex].lev = 0        -- 1:easy 2:medium 4:hard
                resetStats[index].maps[mindex].winmode = 0    -- 1:assasination 2:anialation 4:KOTH 8:Control 16:multiplayer
                resetStats[index].maps[mindex].multi = 0
            end
        end
    end
    SetCurrent(resetStats)
end

-- given an stat key, finds the stat item
function FindstatItem(key)
    local statItem = nil

    local locStats = GetStatsData()
    local itms = table.getn(locStats)
    for index = 1, itms do
      local item = locStats.items[index]
      if item.key == key then
          statItem = item
          break
      end
    end
    return statItem
end

-- given an stat key, finds the stat item indx
function FindstatId(key)
    local statId = -1

    local locStats = GetStatsData()
    local itms = table.getn(locStats)
    for index = 1, itms do
      local item = locStats[index]
      if item.key == key then
          statId = index
          break
      end
    end

    return statId
end

function findMapID(mname)
    local locStats = GetStatsData()
    local itms = table.getn(locStats)
    local mapidx = -1;
    local statindex = FindstatId('maps')

    local maps = {}
    maps = locStats[statindex].maps
    local mapcnt = table.getn(maps)
    for midx = 1, mapcnt do
      if  maps[midx].key == mname then
        mapidx = midx
        break
      end
    end
    if mapidx < 0 then -- add the map ?
       stats[statindex].maps[mapcnt+1] = {}
       stats[statindex].maps[mapcnt+1].lev = 0
       stats[statindex].maps[mapcnt+1].key = mname
       stats[statindex].maps[mapcnt+1].winmode = 0
       stats[statindex].maps[mapcnt+1].multi = 0

       mapidx = mapcnt+1
       Prefs.SetToCurrentProfile('stats', stats)
       UIUtil.SavePreferences()
    end

    return mapidx
end

function findFactionID (faction, stat)
    local locStats = GetStatsData()
    local itms = table.getn(locStats)
    local facidx = -1;
    local statindex = FindstatId(stat)

    local factions = {}
    local facbuilds = {}
    facbuilds = locStats[statindex]
    factions = facbuilds.factions

    local faccnt = table.getn(factions)
    for fidx = 1, faccnt do
      if factions[fidx].fac == faction then
        facidx = fidx
        break
      end
    end
    return facidx
end


function findUnitFactionID (factionID, unitkey)
    local locStats = GetStatsData()
    local itms = table.getn(locStats)
    local facidx = factionID;
    local statindex = FindstatId('f_units_built')
    local facuid = -1

    if facidx > -1 then
        local factionUnits = {}
        factionUnits = locStats[statindex].factions[facidx].units
        local faccnt = table.getn(factionUnits)
        for fuidx = 1, faccnt do
          if factionUnits[fuidx].key == unitkey then
            facuid = fuidx
            break
          end
        end
    end

    return facuid
end


function findAchievement(achievLst, aID)
    local aidx = -1
    if achievLst.count > 0 then
        for k, v in achievLst do
            if v.id and (v.id == aID) then
                 aidx = k
                 break
            end
        end
    end

    return aidx
end


function CheckCurrentStats()
    -- Update the running stats at 10 sec intervals
    local running = true
    while running do
        UpdtateStats()
        WaitSeconds(10)  -- update scores every 10 seconds
        if Sync.GameEnding then
          running = false
        end
    end
end

function UpdtateStats()
  --
end

-- stats name by 'KEY' index , 'newvalue' to set
-- if key='map' determin what map and mode from the Preferences file
function appendStats( statname, newvalue, extradata )
-- TODO: find the scenario played,           ie: map, level, & mode
-- TODO: award the Achievement!!
	--LOG( 'appendStats ', statname, ' ', newvalue )

    local mapname = currentmap
  --  lev  =  1:easy 2:medium 4:hard
  --  mode =  0:sandbox 1:commandpoint  2:kingofthehill 4:eradication 8:domination 16:demoralization
    local lev = gmdiff
    local mode = gmcode
    local type = gametype

    local aLst = {}
    local tmplst = ''
    local achiewoncnt =0
    local filled =0
    local total = nil
    local statindex = FindstatId(statname)
    if statindex < 0 then
      return
    end;

    -- has this been acheived already?
    local prev = table.deepcopy(stats[statindex])
    local preA = {} -- empty Achievement table
    local A = {} -- empty Achievement table
    local preAMap = {} -- empty Achievement table
    local AMap = {} -- empty Achievement table
    local isnew = false
--    if prev and statname != 'maps' and statname != 'faction_build' then          -- check previous unit against Achievements list
    if prev and stats[statindex].type != 'map' and stats[statindex].type != 'f_units_built' and stats[statindex].type != 'faction_win' then          -- check previous unit against Achievements list
        preA = Achievs.checkAchievement(prev.type, statname, prev.value, lev)  --( atype, value, level)
    else
       preA.count = 0
    end

    -- Check map related Achievements, add new, check for Achievements
    local mapidx = -1;
    if (stats[statindex].type == 'map') then
      if (newvalue == true)  then
        mapidx = findMapID( mapname )
        if mapidx < 0 then
            return
        end
        preA = Achievs.checkMapAchievement( stats[statindex].maps )

        --- won a multiplayer game on this map
        if extradata then
            stats[statindex].maps[mapidx].multi = 1
        end

        if type == 'skirmish' then
            stats[statindex].maps[mapidx].skirmish = 1
        end
        local premode =0
        premode = stats[statindex].maps[mapidx].winmode
        if (bitlib.band(premode,mode)) == 0 then  -- game play mode
            stats[statindex].maps[mapidx].winmode = stats[statindex].maps[mapidx].winmode + mode
        end
        premode = stats[statindex].maps[mapidx].lev
        if (bitlib.band(premode,lev)) == 0 then  -- game play level easy, medium, hard
            stats[statindex].maps[mapidx].lev = stats[statindex].maps[mapidx].lev + lev
        end

		LOG('---------------------------------------------------------------')
		LOG('checkMapAchievement: BEGIN:')
        A = Achievs.checkMapAchievement( stats[statindex].maps, true )
		LOG('checkMapAchievement: END.')
		LOG('---------------------------------------------------------------')
      end
    elseif (stats[statindex].type == 'min_stat') then -- only set the stat if it lower than the previous value
       if stats[statindex].value > newvalue then
           stats[statindex].value = newvalue
       end
		LOG('---------------------------------------------------------------')
		LOG('checkAchievement (STATS:[', stats[statindex].type, ': ', statname, ']): BEGIN:')
		A = Achievs.checkAchievement(stats[statindex].type, statname, stats[statindex].value, stats[statindex].lev, extradata, true )
		LOG('checkAchievement (STATS): END.')
		LOG('---------------------------------------------------------------')
    elseif (stats[statindex].type == 'set_stat') then -- set the stat dont append it...even though this is append stats...
       -- Set the stat dont add it
       stats[statindex].value = newvalue
		LOG('---------------------------------------------------------------')
		LOG('checkAchievement (STATS:[', stats[statindex].type, ': ', statname, ']): BEGIN:')
		A = Achievs.checkAchievement(stats[statindex].type, statname, stats[statindex].value, stats[statindex].lev, extradata, true )
		LOG('checkAchievement (STATS): END.')
		LOG('---------------------------------------------------------------')
    elseif (stats[statindex].type == 'campaign_score') then -- campaign specific check
       -- Set the stat dont add it
       stats[statindex].value = newvalue
		LOG('---------------------------------------------------------------')
		LOG('checkAchievement (STATS:[', stats[statindex].type, ': ', statname, ']): BEGIN:')
		A = Achievs.checkAchievement(stats[statindex].type, statname, stats[statindex].value, stats[statindex].lev, extradata, true )
		LOG('checkAchievement (STATS): END.')
		LOG('---------------------------------------------------------------')
    elseif (stats[statindex].type == 'faction_build') then -- faction specific data check
--       local facid = findFactionID(myFaction, 'f_units_built')
--       local fuid = findUnitFactionID(facid, extradata)
--       preA = Achievs.checkFactionAchievement( stats[statindex].factions )
--       local oldval = stats[statindex].factions[facid].units[fuid].value
--       if oldval == nil then
--         oldval = 0
--       end
--       stats[statindex].factions[facid].units[fuid].value = oldval + newvalue
--       A = Achievs.checkFactionAchievement( stats[statindex].factions )
    elseif (stats[statindex].type == 'faction_win') then -- faction specific data check
         local facid = findFactionID(myFaction, 'f_wins')
         preA = Achievs.checkFactionAchievement( stats[statindex].factions )
         if type == 'skirmish' then
             local oldval = stats[statindex].factions[facid].skirmish_played
             if oldval == nil then
               oldval = 0
             end
             stats[statindex].factions[facid].skirmish_played = oldval + 1

            if newvalue == true then -- update if we won on this map or not
                oldval = stats[statindex].factions[facid].skirmish_won
                if oldval == nil then
                    oldval = 0
                end
                stats[statindex].factions[facid].skirmish_won = oldval + 1
            end
         end

		LOG('---------------------------------------------------------------')
		LOG('checkFactionAchievement: BEGIN:')
		A = Achievs.checkFactionAchievement( stats[statindex].factions, true )
		LOG('checkFactionAchievement: END.')
		LOG('---------------------------------------------------------------')
    else  ---- else not a map statistic likley unit related... Check it.
      stats[statindex].value = stats[statindex].value + newvalue;
		LOG('---------------------------------------------------------------')
		LOG('checkAchievement (STATS:[', stats[statindex].type, ': ', statname, ']): BEGIN:')
		A = Achievs.checkAchievement(stats[statindex].type, statname, stats[statindex].value, stats[statindex].lev, extradata, true )
		LOG('checkAchievement (STATS): END.')
		LOG('---------------------------------------------------------------')
    end

-----------------------------------
----  add up any new Achievements...
    tmplst = ''
    achiewoncnt =0

    filled = table.getn(newAchievements)
    if A.count > 0 then
      for k, v in A do
        if v.id then
           tmplst = tmplst .. v.id .. ', '
           achiewoncnt = achiewoncnt +1
           local idx = filled + achiewoncnt
           newAchievements[idx]= v
        end
      end
    end

-----------------------------------
----  add up any old Achievements...
    tmplst = ''
    achiewoncnt =0

    filled = table.getn(oldAchievements)
    if preA.count > 0 then
      for k, v in preA do
        if v.id then
           tmplst = tmplst .. v.id .. ', '
           achiewoncnt = achiewoncnt +1
           oldAchievements[ filled + achiewoncnt ]= v
        end
      end
    end

end

function commitStats( score )

    if not stats then
        stats = GetCurrent()
    end

    --LOG( 'commitStats Score', repr(score))

    local sessionInfo = SessionGetScenarioInfo()
    local isMulti = SessionIsMultiplayer() and sessionInfo.Options.Ranked
    local isMultiNonRanked = SessionIsMultiplayer()
    local armies = {}
    local locArmiesTable = {}
    local myArmy = {}
    local topai = 0 ------- 0:noAI   -- 1:easy   2:medium  3: hard
    local fac = 'UEF'   -- dummy value.
    local isSkirmish = false
    local againstAnyAi = false
    local againstAllAi = false
    local isCoopGame = false
    local mapwin = false

	-- This is invalid when the game is shutting down.
    local playerarmy = GetFocusArmy()
    if playerarmy < 0 then
		playerarmy = 1
    end

    if sessionInfo then

        if (sessionInfo.Options.Victory == 'sandbox') then
            LOG('-- Sandbox Session => no stats for you')
            return
        end

        locArmiesTable = GetArmiesTable()
        armies = locArmiesTable.armiesTable

        fac = armies[playerarmy].faction

        if fac == 1 then
			fac = 'UEF'
        elseif fac == 2 then
			fac = 'CYBRAN'
        elseif fac == 3 then
			fac = 'ILLUMINATE'
        end

        myFaction = fac

        if sessionInfo.map then
            local mapname
            currentmap = sessionInfo.map

            if sessionInfo.description != nil then
                 mapname = sessionInfo.description
                 currentmap = mapname
            end

            gametype = sessionInfo.type

            if gametype == 'campaign' then

                if not mapname then
                    LOG('*** Unexpected lack of sessionInfo.description ....')
                else
                    currentmap = mapname
                end

                gmdiff  = sessionInfo.Options.Difficulty
                gamemode = 'campaign'
                local cm = import('/lua/ui/campaign/campaignmanager.lua')

                if cm then
                    if cm.WasOperationSuccessful(sessionInfo.campaignID, mapname) then
                        mapwin = true
                        gmcode = 1;
                    end

                    local objAch = Achievs.checkObjectiveAchievements(cm)
                    for k, ach in objAch do
                        if ach.id then
                            table.insert(newAchievements, ach)
                        end
                    end
                end
            else
				LOG('---------------------------------------------------------------')
				LOG('skipping checkObjectiveAchievements...')

				LOG('..........gametype:[', gametype, ']')
				LOG('---------------------------------------------------------------')

				LOG('---------------------------------------------------------------')
				LOG('CHECKING FOR VICTORY (NON CAMPAIGN SESSION): sessionInfo.MapVictory:[', sessionInfo.MapVictory, ']')
				LOG('---------------------------------------------------------------')
				if sessionInfo.MapVictory == true then
				    mapwin = true
				end

                if gametype == 'skirmish' then
                    isSkirmish = true
                end

                gamemode = sessionInfo.Options.Victory

                for k, v in armies do
                    local myAlly = IsAlly(playerarmy, k)
                    if v.civilian == false and (v.human == false) and (myAlly==false) then
                       local aidifficulty = v.personality
                       if (topai < 1) and (aidifficulty == 'easy') then
                           topai = 1
                       end
                       if (aidifficulty != 'easy') then
                           if topai <= 1 then
                               if aidifficulty == 'medium' then
                                 topai = 2
                               else ------ all others are rated hard
                                 topai = 3
                                 break
                               end
                           end
                       end
                    end
                end

                local aiCount = 0
                local humanAllyCount = 0
                for k, v in armies do
                    local myAlly = IsAlly(playerarmy, k)
                    if v.civilian == false and (v.human == false) and (myAlly==false) then
                       aiCount = aiCount + 1
                    else
                        if( v.human == true) and (myAlly == true) then
                            humanAllyCount = humanAllyCount + 1
                        end
                    end
                end

                if topai > 0 then
                    againstAnyAi = true
                end
                local MaxAiArmies = locArmiesTable.numArmies - 1
                if MaxAiArmies == aiCount then
                    againstAllAi = true
                end

                if( humanAllyCount > 1 ) then -- we are considered our own ally
                    isCoopGame = true
                end

                gmdiff = topai
            end

            ------ to bit code
            if gmdiff == 3 then
                gmdiff = 4
            end

            --0:sandbox 1:commandpoint 2:kingofthehill 4:eradication 8:domination 16:demoralization
            if gamemode == 'demoralization' then gmcode = 16 end
            if gamemode == 'domination'     then gmcode = 8 end
            if gamemode == 'eradication'    then gmcode = 4 end
            if gamemode == 'kingofthehill'  then gmcode = 2 end
            if gamemode == 'commandpoint'   then gmcode = 1 end
            if gamemode == 'sandbox' then gmcode = 0 end
        end
    else
        LOG('No SessionInfo = no stats');
        return
    end

    if (gamemode == 'campaign' or gmcode > 0) and score then
        appendStats('maps', mapwin, isMulti)
        appendStats('f_units_built', score['Units_Experimentals_Built'], 'experimental')
        appendStats('f_wins', mapwin)

        gmdiff  = sessionInfo.Options.Difficulty
        local cm = import('/lua/ui/campaign/campaignmanager.lua')
        if cm then
            local campScore = cm.CalculateTotalCampaignScore(gmdiff)
            local didScoreImprove = cm.DidCampaignScoreImprove(sessionInfo.campaignID, gmdiff)
            if  didScoreImprove == true then
                appendStats('improved_campaign_score', 1)
			else
				LOG('---------------------------------------------------------------')
				LOG('skipping appendStats for improved_campaign_score...')

				LOG('..........didScoreImprove:[', didScoreImprove, ']')
				LOG('---------------------------------------------------------------')
            end
            appendStats('total_campaign_score', campScore)
		else
			WARN('WARNING: commitStats was unable to import campaignmanager.lua - is evrything loading saving out correctly?')
        end

		---NOTE: no longer incrementing these when in a campaign - to avoid repeat save incrementing - bad last minute fix - bfricks 2/1/10
		if gamemode != 'campaign' then
	        appendStats('total_time_played', score['Time_Played'])
	        appendStats('units_built', score['Units_History'])
			---appendStats('units_killed', score['Units_Killed'])
	        appendStats('enemies_killed', score['Enemies_Killed'])
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for total_time_played...')
			LOG('skipping appendStats for units_built...')
			LOG('skipping appendStats for enemies_killed...')

			LOG('..........gamemode[', gamemode, ']')
			LOG('---------------------------------------------------------------')
		end

        -- find out if we won against any ai players
        if isSkirmish == true and (againstAnyAi == true) and (mapwin == true) then
            appendStats('won_skirmish_any_ai', 1)
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for won_skirmish_any_ai...')

			LOG('..........isSkirmish:[', isSkirmish, ']')
			LOG('..........againstAnyAi:[', againstAnyAi, ']')
			LOG('..........mapwin:[', mapwin, ']')
			LOG('---------------------------------------------------------------')
        end

        -- find out if we won against all AI players
        if isSkirmish == true and (againstAllAi == true) and (mapwin == true) then
            appendStats('won_skirmish_all_ai', 1)
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for won_skirmish_all_ai...')

			LOG('..........isSkirmish:[', isSkirmish, ']')
			LOG('..........againstAnyAi:[', againstAnyAi, ']')
			LOG('..........mapwin:[', mapwin, ']')
			LOG('---------------------------------------------------------------')
        end

        if isSkirmish == true and (mapwin == true) then
            appendStats('min_skirmish_win_time', score['Time_Played'])
            appendStats('skirmish_win_count', 1)
            if score['Units_Experimentals_Built'] == 0 then
                appendStats('won_skirmish_no_experimentals', 1)
			else
				LOG('---------------------------------------------------------------')
				LOG('skipping appendStats for won_skirmish_no_experimentals...')

				LOG('..........Units_Experimentals_Built:[', score['Units_Experimentals_Built'], ']')
				LOG('---------------------------------------------------------------')
            end
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for won_skirmish_no_experimentals...')
			LOG('skipping appendStats for min_skirmish_win_time...')
			LOG('skipping appendStats for skirmish_win_count...')

			LOG('..........isSkirmish[', isSkirmish, ']')
			LOG('..........mapwin[', mapwin, ']')
			LOG('---------------------------------------------------------------')
        end

        local isAnyMultiplayerGameType = (isMulti == true or (isMultiNonRanked == true))

        if isAnyMultiplayerGameType == true and (mapwin == true) then
            appendStats('online_matches_won', 1)
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for online_matches_won...')

			LOG('..........isAnyMultiplayerGameType[', isAnyMultiplayerGameType, ']')
			LOG('..........mapwin[', mapwin, ']')
			LOG('---------------------------------------------------------------')
        end

        if isMulti == true and (mapwin == true) then
            appendStats('ranked_online_matches_won', 1)
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for ranked_online_matches_won...')

			LOG('..........isMulti[', isMulti, ']')
			LOG('..........mapwin[', mapwin, ']')
			LOG('---------------------------------------------------------------')
        end

        if isAnyMultiplayerGameType == true and isCoopGame == true and (mapwin == true) and (againstAnyAi == true) then
            appendStats('coop_matches_won_vs_ai', 1)
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for coop_matches_won_vs_ai...')

			LOG('..........isAnyMultiplayerGameType[', isAnyMultiplayerGameType, ']')
			LOG('..........againstAnyAi[', againstAnyAi, ']')
			LOG('..........isCoopGame[', isCoopGame, ']')
			LOG('..........mapwin[', mapwin, ']')
			LOG('---------------------------------------------------------------')
        end

		---NOTE: no longer incrementing this when in a campaign - to avoid repeat save incrementing - bad last minute fix - bfricks 2/1/10
		if gamemode != 'campaign' then
			appendStats('resources_mass_built', score['Economy_TotalProduced_Mass']) -- now Economy_TotalProduced_Mass
		else
			LOG('---------------------------------------------------------------')
			LOG('skipping appendStats for resources_mass_built...')

			LOG('..........gamemode[', gamemode, ']')
			LOG('---------------------------------------------------------------')
		end

		LOG('---------------------------------------------------------------')
        LOG('Stats save block begin')
		LOG('-------------------Prefs.SetToCurrentProfile')
        Prefs.SetToCurrentProfile('stats', stats)

        for no, sdata in stats do
           if (sdata.key == 'f_units_built') then
               LOG(' [Factions] begin')
               for fno, fdata in sdata.factions do
                   LOG('   '..fdata.fac);
               end
               LOG(' [Factions] end.')
           elseif ( sdata.key == 'f_wins') then
               LOG(' [Faction Wins] begin')
               for fno, fdata in sdata.factions do
                   LOG('   '..fdata.fac);
               end
               LOG(' [Faction Wins] end.')
           elseif ( sdata.key == 'maps') then
               LOG(' [maps] begin')
               for mno, mdata in sdata.maps do
                   LOG('   '..mdata.key..'  winmode:'..mdata.winmode)
               end
               LOG(' [maps] end.')
           else
               LOG(' '..sdata.key..':'..sdata.value)
           end
        end

        local StorageDevice = GetStorageDevice()
        if( StorageDevice>0 ) and ( HaveRoomToSavePreferences() ) then

			LOG('-------------------UIUtil.SavePreferences')
            UIUtil.SavePreferences()
        end

		-- DumpPrefsToConsole()
        LOG('Stats save block end')
		LOG('---------------------------------------------------------------')

        -- We have new Achievements to register
		if table.getn(newAchievements) > 0 then -- > table.getn(oldAchievements ) then
			--Award the Achievement...
			local foundpos =-1
			LOG('---------------------------------------------------------------')
			LOG('---------------------------------------------------------------')
			LOG('---------------------------------------------------------------')
			for k, v in newAchievements do
				if v.id then
					foundpos = findAchievement(oldAchievements, v.id)  --  is this a new Achievement?
					if foundpos < 1 then
						LOG('Award the Achievements... ID=' .. v.id .. ': ' .. v.title )
						SetOnlineAchievement(v.id)
					end
				end
			end
			LOG('---------------------------------------------------------------')
			LOG('---------------------------------------------------------------')
			LOG('---------------------------------------------------------------')

			SaveOnlineAchievements()
		end
	else
		WARN('WARNING: commitStats did not get a chance to append stats, are we in some sort of odd game mode?')
	end
	--end -- matches with 'if sscore.units == nil'
end