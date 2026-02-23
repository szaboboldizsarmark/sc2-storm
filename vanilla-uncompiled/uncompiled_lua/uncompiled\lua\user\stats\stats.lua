--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--[[
This file contains a table which defines stats available collected by the user

tab data defines each statistic collected
Each tab has:
    .title - the text that will appear on the tab
    .key - the key that will group the stats ( in the prefs file )
    .items - an array of the items for this key (this is an array rather than a genericly keyed table so display order can be imposed)
        .key - the prefs key to identify this property
        .default - the default value of the property
        .populate - an optional function which when called, will repopulate the stats custom data. The value passed in is the current value of the control (function(value))
        .set - an optional function that takes a value parameter and is responsible for determining what happens when the stat is set (function(key, value))

the statsOrder table is just an array of keys in to the option table, and their order will determine what
order the tabs show in the dialog

  -type :(win), (map), (build), (kill) or (used)
--]]

--local savedMasterVol = false
--local savedFXVol = false
--local savedMusicVol = false
--local savedVOVol = false

local WorkingLoad = '<LOC WORKING_LOADING_0000>Loading...'
local WorkingSave = '<LOC WORKING_SAVING_0000>Saving...'

local stat1  = '<LOC STAT_0001>Ground units killed'
local stat2  = '<LOC STAT_0002>Ground units built'
local stat3  = '<LOC STAT_0003>Air units killed'
local stat4  = '<LOC STAT_0004>Air units built'
local stat5  = '<LOC STAT_0005>Naval units killed'
local stat6  = '<LOC STAT_0006>Naval units built'
local stat7  = '<LOC STAT_0007>Units captured'
local stat8  = '<LOC STAT_0008>Commander units killed'
local stat9  = '<LOC STAT_0009>Nukes fired'
local stat10 = '<LOC STAT_0010>Point defense kills'
local stat11 = '<LOC STAT_0011>Anti-air kills'
local stat12 = '<LOC STAT_0012>Structures destroyed'
local stat13 = '<LOC STAT_0013>Structures built'
local stat14 = '<LOC STAT_0014>Engineers built'
local stat15 = '<LOC STAT_0015>Mass built'
local stat16 = '<LOC STAT_0016>Energy built'
local stat17 = '<LOC STAT_0017>Experimental units built'
local stat18 = '<LOC STAT_0018>Experimental units killed'
local stat19 = '<LOC STAT_0019>Campaign Score'
local stat20 = '<LOC STAT_0020>Units built'
local stat21 = '<LOC STAT_0021>Units killed'
local stat22 = '<LOC STAT_0022>Total time played'
local stat23 = '<LOC STAT_0023>Won skirmish against any AI opponent'
local stat24 = '<LOC STAT_0024>Won skirmish against all AI opponent'
local stat25 = '<LOC STAT_0025>Minimum skirmish win time'
local stat26 = '<LOC STAT_0026>Skirmish win count'
local stat27 = '<LOC STAT_0027>Won skirmish with no experimentals'
local stat28 = '<LOC STAT_0028>Improved campaign score'
local stat29 = '<LOC STAT_0029>Online matches won'
local stat30 = '<LOC STAT_0030>Ranked online matches won'
local stat31 = '<LOC STAT_0031>Co-op Matches won vs AI'
local TipsForGame = {
}
function GetMeSupComTips(TipIndex)
    local size=table.getn(TipsForGame)
    local Tip='nothing'
    if( TipIndex<=size ) then
        Tip=LOCF("%s",TipsForGame[TipIndex])
    end
    return Tip
end

stats = {
        title = "Player statistics",
        key = 'scorestats',
        items = {
            {
                title = "Ground units built",
                locString = "<LOC STAT_0002>",
                key = 'units_ground_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "Ground units killed",
                locString = "<LOC STAT_0001>",
                key = 'units_ground_kills',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "Air units built",
                locString = "<LOC STAT_0004>",
                key = 'units_air_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "Air units killed",
                locString = "<LOC STAT_0003>",
                key = 'units_air_kills',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "Sea units built",
                locString = "<LOC STAT_0006>",
                key = 'units_naval_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "Sea units killed",
                locString = "<LOC STAT_0005>",
                key = 'units_naval_kills',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "Units captured",
                locString = "<LOC STAT_0007>",
                key = 'units_general_captured',
                type = 'captured',
                default = 0,
                value = 0,
            },
            {
                title = "Commander units killed",
                locString = "<LOC STAT_0008>",
                key = 'units_cdr_kills',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "units_nukes_fired",
                locString = "<LOC STAT_0009>",
                key = 'units_nukes_fired',
                type = 'used',
                default = 0,
                value = 0,
            },
            {
                title = "units_pointdef_killed",
                locString = "<LOC STAT_0010>",
                key = 'units_pointdef_kills',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "units_antiair_killed",
                locString = "<LOC STAT_0011>",
                key = 'units_antiair_kills',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "units_structure_killed",
                locString = "<LOC STAT_0012>",
                key = 'units_structure_kills',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "units_structure_built",
                locString = "<LOC STAT_0013>",
                key = 'units_structure_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "units_engineer_built",
                locString = "<LOC STAT_0014>",
                key = 'units_engineer_built',
                type = 'build',
                default = 0,
                value = 0,
            },

            {
                title = "resources_mass_built",
                locString = "<LOC STAT_0015>",
                key = 'resources_mass_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "resources_energy_built",
                locString = "<LOC STAT_0016>",
                key = 'resources_energy_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "unit_experimental_built",
                locString = "<LOC STAT_0017>",
                key = 'units_experimental_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "unit_experimental_killed",
                locString = "<LOC STAT_0018>",
                key = 'units_experimental_killed',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "Units built",
                locString = "<LOC STAT_0020>",
                key = 'units_built',
                type = 'build',
                default = 0,
                value = 0,
            },
            {
                title = "Units killed",
                locString = "<LOC STAT_0021>",
                key = 'units_killed',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "Enemies killed",
                locString = "<LOC STAT_0021>",---NOTE: this is fine to be a dupe of units killed even though the game treats these as opposites - bfricks 1/21/10
                key = 'enemies_killed',
                type = 'kills',
                default = 0,
                value = 0,
            },
            {
                title = "Total time played",
                locString = "<LOC STAT_0022>",
                key = 'total_time_played',
                type = 'time',
                default = 0,
                value = 0,
            },
            {
                title = "Total campaign score",
                locString = "<LOC STAT_0019>",
                key = 'total_campaign_score',
                type = 'campaign_score',
                default = 0,
                value = 0,
            },
            {
                title = "Won skirmish against any AI opponent",
                locString = "<LOC STAT_0023>",
                key = 'won_skirmish_any_ai',
                type = 'set_stat',
                default = 0,
                value = 0,
            },
            {
                title = "Won skirmish against all AI opponent",
                locString = "<LOC STAT_0024>",
                key = 'won_skirmish_all_ai',
                type = 'set_stat',
                default = 0,
                value = 0,
            },
            {
                title = "Minimum skirmish win time",
                locString = "<LOC STAT_0025>",
                key = 'min_skirmish_win_time',
                type = 'min_stat',
                default = 86400,
                value = 0,
            },
            {
                title = "Skirmish win count",
                locString = "<LOC STAT_0026>",
                key = 'skirmish_win_count',
                type = 'skirmish_wins',
                default = 0,
                value = 0,
            },
            {
                title = "Won skirmish with no experimentals",
                locString = "<LOC STAT_0027>",
                key = 'won_skirmish_no_experimentals',
                type = 'skirmish_wins',
                default = 0,
                value = 0,
            },
            {
                title = "Improved campaign score",
                locString = "<LOC STAT_0028>",
                key = 'improved_campaign_score',
                type = 'set_stat',
                default = 0,
                value = 0,
            },
            {
                title = "Online Matches won",
                locString = "<LOC STAT_0029>",
                key = 'online_matches_won',
                type = 'online_won',
                default = 0,
                value = 0,
            },
            {
                title = "Ranked online Matches won",
                locString = "<LOC STAT_0030>",
                key = 'ranked_online_matches_won',
                type = 'online_won',
                default = 0,
                value = 0,
            },
            {
                title = "Co-op Matches won vs AI",
                locString = "<LOC STAT_0031>",
                key = 'coop_matches_won_vs_ai',
                type = 'online_won',
                default = 0,
                value = 0,
            },
            {
                title = "faction_builds",
                key = 'f_units_built',  -- faction  specific
                type = 'faction_build',
                factions = {
                     {
                         fac = 'UEF',
                         units={
                            {
                             key =  'experimental',
                             value = 0,
                             default = 0,
                            },
                         },
                     },
                     {
                         fac = 'CYBRAN',
                         units={
                             {
                              key =  'experimental',
                              value = 0,
                              default = 0,
                             },
                         },
                     },
                     {
                         fac = 'ILLUMINATE',
                         units={
                             {
                              key =  'experimental',
                              value = 0,
                              default = 0,
                             },
                         },
                     }
                }
            },
            {
                title = "faction_wins",
                key = 'f_wins',  -- faction  specific
                type = 'faction_win',
                factions = {
                     {
                         fac = 'UEF',
                         skirmish_played = 0,
                         skirmish_won = 0,
                     },
                     {
                         fac = 'CYBRAN',
                         skirmish_played = 0,
                         skirmish_won = 0,
                     },
                     {
                         fac = 'ILLUMINATE',
                         skirmish_played = 0,
                         skirmish_won = 0,
                     }
                }
            },
            {
                title = "Maps",
                key = 'maps',
                type = 'map',
                maps = {
                      {
                        key =  'SC2_MP_001',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_002',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_003',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_004',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_005',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_006',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_007',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_101',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_102',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_103',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_104',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_105',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_106',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_201',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_202',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_203',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_204',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_205',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_206',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_206',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_301',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_302',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_303',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_304',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_304_1K',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_305',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                      {
                        key =  'SC2_MP_306',
                        lev = 0,
                        winmode = 0,
                        multi = 0,
                        skirmish = 0,
                      },
                    }
            },
        },
}
