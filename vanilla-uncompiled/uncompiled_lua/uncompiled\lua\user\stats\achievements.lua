--****************************************************************************
--**
--**  File     :  /lua/stats/achievements.lua
--**  Author(s):  James Baxter
--**
--**  Summary  :  Achiements requirments checklist
--**
--**  Copyright © 2007 Hellbent Games, Inc.  All rights reserved.
--****************************************************************************

--[[

  'Achievments' are expected in the following format
     -title: readble text for the achievment title
     -done : achievment accomplished
     -key  : key
     -id   : id found in src/user/SupComConfig.spa.h
     -points: points awarded for achievment
     -type : (map), (build), (kill) or (used)
             win on listed/ALL maps, unit built, units killed, units used/fired
     -need :table or requirements.  A list of 'items', with the id (campaign name, or (B)unitName )

--]]

-- for debug only
local logged ={}


local scenarios = import('/lua/ui/maputil.lua').EnumerateSkirmishScenarios()

---NOTE: before editing this review the following details:
---			this list should be a copy of the AcheivementMap array in LiveConnObject.cpp and indexed numerically
---			that array should be a copy of all valid defined acheivements in SupremeCommander2.spa.h
---			and finally SupremeCommander2.spa.h should be created from an XLAST export before attempting to change any of these
---			To delete or add:
---					1) start with XLAST, build, generate the spa.h file
---					2) update LiveConnObject.cpp, then edit this list
---					3) edit this list and re-number it
---					4) delete/ add the corresponding lua block in the table below (Achievments.items)
local ACHIEVEMENT_ACH_STARTHERE					= 0
local ACHIEVEMENT_ACH_COMMUNICATIONBREAKDOWN	= 1
local ACHIEVEMENT_ACH_SECONDTARGET				= 2
local ACHIEVEMENT_ACH_DEEPFREEZE				= 3
local ACHIEVEMENT_ACH_FATBOYPARADE				= 4
local ACHIEVEMENT_ACH_NUCLEARSTRIKE				= 5
local ACHIEVEMENT_ACH_RODGERSISRELIEVED			= 6
local ACHIEVEMENT_ACH_BARGEAHEAD				= 7
local ACHIEVEMENT_ACH_ALARMING					= 8
local ACHIEVEMENT_ACH_PRISONBREAK				= 9
local ACHIEVEMENT_ACH_HOLEINTHEGROUND			= 10
local ACHIEVEMENT_ACH_GORGED					= 11
local ACHIEVEMENT_ACH_REUNITED					= 12
local ACHIEVEMENT_ACH_DOWNLOADING				= 13
local ACHIEVEMENT_ACH_BUGSINTHESYSTEM			= 14
local ACHIEVEMENT_ACH_ANIMALMAGNETISM			= 15
local ACHIEVEMENT_ACH_CLASSREUNION				= 16
local ACHIEVEMENT_ACH_WELLSTOCKED				= 17
local ACHIEVEMENT_ACH_TERRAFIRMA				= 18
local ACHIEVEMENT_ACH_EASYGOING					= 19
local ACHIEVEMENT_ACH_AWINNERISYOU				= 20
local ACHIEVEMENT_ACH_SUPREMESTCOMMANDER		= 21
local ACHIEVEMENT_ACH_KNOWSITALL				= 22
local ACHIEVEMENT_ACH_COMPLETIST				= 23
local ACHIEVEMENT_ACH_SCOREHOARDER				= 24
local ACHIEVEMENT_ACH_SURVIVOR					= 25
local ACHIEVEMENT_ACH_BOTLORD					= 26
local ACHIEVEMENT_ACH_SURVIVALIST				= 27
local ACHIEVEMENT_ACH_REPLAYER					= 28
local ACHIEVEMENT_ACH_CAKEWALK					= 29
local ACHIEVEMENT_ACH_GOODGAME					= 30
local ACHIEVEMENT_ACH_LUDDITE					= 31
local ACHIEVEMENT_ACH_TOTHEVICTOR				= 32
local ACHIEVEMENT_ACH_RUSHINFRONT				= 33
local ACHIEVEMENT_ACH_SAMPLING					= 34
local ACHIEVEMENT_ACH_DATING					= 35
local ACHIEVEMENT_ACH_COMMITTEDRELATIONSHIP		= 36
local ACHIEVEMENT_ACH_SIGHTSEER					= 37
local ACHIEVEMENT_ACH_SHARPSHOOTER				= 38
local ACHIEVEMENT_ACH_MASSTER					= 39
local ACHIEVEMENT_ACH_MASTERBUILDER				= 40
local ACHIEVEMENT_ACH_TIMECRUNCHER				= 41
local ACHIEVEMENT_ACH_INTERNETCOMMANDER			= 42
local ACHIEVEMENT_ACH_FRIENDS					= 43
local ACHIEVEMENT_ACH_RANKER					= 44
local ACHIEVEMENT_ACH_SUPREMEONLINECOMMANDER	= 45
local ACHIEVEMENT_ACH_GOODFRIENDS				= 46

function findInTable( tbl, val)
    local fnd = false
    for i,tblitm in tbl do
        if tblitm == val then
            fnd = true
            break
        end
    end
    return fnd
end


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

Achievments = {
    title = "Player achievments",
    key = 'achievments',
	items =
	{
		{
			title='Start Here',
			key  ='ACH_STARTHERE',
			id = ACHIEVEMENT_ACH_STARTHERE,
			type ='map',               		-- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_TUT_01',   -- UEF - Tutorial 1 and 2
					mode = 1,
				},
				{
					id  = 'SC2_CA_TUT_02',
					mode = 1,
				},
			}
		},
		{
			title='Communication Breakdown',
			key  ='ACH_COMMUNICATIONBREAKDOWN',
			id = ACHIEVEMENT_ACH_COMMUNICATIONBREAKDOWN,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U01',    -- UEF - Prime Target
					mode = 1,
				},
			}
		},
		{
			title='Second Target',
			key  ='ACH_SECONDTARGET',
			id = ACHIEVEMENT_ACH_SECONDTARGET,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U02',    -- UEF - Off Base
					mode = 1,
				},
			}
		},
		{
			title='Deep Freeze',
			key  ='ACH_DEEPFREEZE',
			id = ACHIEVEMENT_ACH_DEEPFREEZE,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U03',    -- UEF - Strike While Cold
					mode = 1,
				},
			}
		},
		{
			title='Fatboy Parade',
			key  ='ACH_FATBOYPARADE',
			id = ACHIEVEMENT_ACH_FATBOYPARADE,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U04',    -- UEF - Titans of Industry
					mode = 1,
				},
			}
		},
		{
			title='Nuclear Strike',
			key  ='ACH_NUCLEARSTRIKE',
			id = ACHIEVEMENT_ACH_NUCLEARSTRIKE,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U05',    -- UEF - Factions or Family Plan
					mode = 1,
				},
			}
		},
		{
			title='Rodgers is Relieved',
			key  ='ACH_RODGERSISRELIEVED',
			id = ACHIEVEMENT_ACH_RODGERSISRELIEVED,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U06',    -- UEF - End of an Alliance
					mode = 1,
				},
			}
		},
		{
			title='Barge Ahead',
			key  ='ACH_BARGEAHEAD',
			id = ACHIEVEMENT_ACH_BARGEAHEAD,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_I01',    -- Delta Force
					mode = 1,
				},
			}
		},
		{
			title='Alarming',
			key  ='ACH_ALARMING',
			id = ACHIEVEMENT_ACH_ALARMING,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_I02',    -- Lethal Weapons
					mode = 1,
				},
			}
		},
		{
			title='Prison Break',
			key  ='ACH_PRISONBREAK',
			id = ACHIEVEMENT_ACH_PRISONBREAK,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_I03',    -- Back on the Chain Gang
					mode = 1,
				},
			}
		},
		{
			title='Hole in the Ground',
			key  ='ACH_HOLEINTHEGROUND',
			id = ACHIEVEMENT_ACH_HOLEINTHEGROUND,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_I04',    -- Steamed
					mode = 1,
				},
			}
		},
		{
			title='Gorged',
			key  ='ACH_GORGED',
			id = ACHIEVEMENT_ACH_GORGED,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_I05',    -- Cliff Diving
					mode = 1,
				},
			}
		},
		{
			title='Reunited',
			key  ='ACH_REUNITED',
			id = ACHIEVEMENT_ACH_REUNITED,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_I06',    -- Prime Time
					mode = 1,
				},
			}
		},
		{
			title='Downloading',
			key  ='ACH_DOWNLOADING',
			id = ACHIEVEMENT_ACH_DOWNLOADING,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_C01',    -- Fact Finder
					mode = 1,
				},
			}
		},
		{
			title='Bugs in the System',
			key  ='ACH_BUGSINTHESYSTEM',
			id = ACHIEVEMENT_ACH_BUGSINTHESYSTEM,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_C02',    -- The Trouble With Technology
					mode = 1,
				},
			}
		},
		{
			title='Animal Magnetism',
			key  ='ACH_ANIMALMAGNETISM',
			id = ACHIEVEMENT_ACH_ANIMALMAGNETISM,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_C03',    -- The Great Leap Forward
					mode = 1,
				},
			}
		},
		{
			title='Class Reunion',
			key  ='ACH_CLASSREUNION',
			id = ACHIEVEMENT_ACH_CLASSREUNION,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_C04',    -- Gatekeeper
					mode = 1,
				},
			}
		},
		{
			title='Well Stocked',
			key  ='ACH_WELLSTOCKED',
			id = ACHIEVEMENT_ACH_WELLSTOCKED,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_C05',    -- Surface Tension
					mode = 1,
				},
			}
		},
		{
			title='Terra Firma',
			key  ='ACH_TERRAFIRMA',
			id = ACHIEVEMENT_ACH_TERRAFIRMA,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_C06',    -- The Final Countdown
					mode = 1,
				},
			}
		},
		{
			title='Easy Going',  -- Complete all three campaigns on Easy difficulty
			key  ='ACH_EASYGOING',
			id = ACHIEVEMENT_ACH_EASYGOING,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U06',
					mode = 1,
				},
				{
					id  = 'SC2_CA_I06',
					mode = 1,
				},
				{
					id  = 'SC2_CA_C06',
					mode = 1,
				},
			},
		},
		{
			title='A Winner is You',  -- Complete all three campaigns on Normal difficulty
			key  ='ACH_AWINNERISYOU',
			id = ACHIEVEMENT_ACH_AWINNERISYOU,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U01',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_U02',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_U03',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_U04',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_U05',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_U06',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_I01',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_I02',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_I03',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_I04',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_I05',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_I06',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_C01',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_C02',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_C03',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_C04',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_C05',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
				{
					id  = 'SC2_CA_C06',
					mode = 1,
					lev = 6, -- allow normal or hard
				},
			},
			includes ={
				{
					id = ACHIEVEMENT_ACH_EASYGOING, -- Also unlocks achievement for 'easy'
				},
			},
		},
		{
			title='Supremest Commander',  -- Complete all three campaigns on Hard difficulty
			key  ='ACH_SUPREMESTCOMMANDER',
			id = ACHIEVEMENT_ACH_SUPREMESTCOMMANDER,
			type ='map',               -- campaign - (win) / (build) / (kill) / (used)
			need ={
				{
					id  = 'SC2_CA_U01',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_U02',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_U03',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_U04',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_U05',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_U06',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_I01',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_I02',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_I03',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_I04',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_I05',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_I06',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_C01',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_C02',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_C03',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_C04',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_C05',
					mode = 1,
					lev = 4,
				},
				{
					id  = 'SC2_CA_C06',
					mode = 1,
					lev = 4,
				},
			},
			includes ={
				{
					id = ACHIEVEMENT_ACH_EASYGOING, -- Also unlocks achievement for 'easy'
				},
				{
					id = ACHIEVEMENT_ACH_AWINNERISYOU, -- Also unlocks achievement for 'normal'
				},
			},

		},
		{
			title='Knows it All',
			key  ='ACH_KNOWSITALL',
			id = ACHIEVEMENT_ACH_KNOWSITALL,
			type ='objective',
			need ={
				{
					camp = 'UEF',
					map = 'SC2_CA_U01',
					objs = {
						'Experimental Invasion', --Last primary objective
						'Research Technology',   --Seconary objective
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U02',
					objs = {
						'Base of Operations',    --Last primary objective
						'Research Technology',   --Seconary objective
						'Economic Meltdown',     --Seconary objective
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U03',
					objs = {
						'Left Behind',           --Last primary objective
						'Get Kraken',            --Seconary objective
						'Research Technology',   --Seconary objective
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U04',
					objs = {
						'Cool Off Coleman',      --Only primary objective
						'Big and Deadly',        --Seconary objective
						'Take Control',          --Seconary objective
						'More Control',          --Seconary objective
						'Research Technology',   --Seconary objective
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U05',
					objs = {
						'Nuke Nuker',            --Last primary objective
						'Research Technology',   --Seconary objective
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U06',
					objs = {
						'Core Damage',           --Last primary objective
						'Research Technology',   --Seconary objective
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I01',
					objs = {
						'Sink or Swim',           --Only primary objective
						'Ripped to Shreds',       --Seconary objective
						'Research Technology',    --Seconary objective
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I02',
					objs = {
						'Big Surprise',           --Last primary objective
						'Research Technology',    --Seconary objective
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I03',
					objs = {
						'The Big House',          --Only primary objective
						'Out of Control',         --Seconary objective
						'Research Technology',    --Seconary objective
						'Insecure',               --Seconary objective
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I04',
					objs = {
						'UEF No More',            --Only primary objective
						'Research Technology',    --Seconary objective
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I05',
					objs = {
						'Center of Attention',    --Only primary objective
						'Mesa Mass',              --Seconary objective
						'Space Temple Pilots',    --Seconary objective
						'Research Technology',    --Seconary objective
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I06',
					objs = {
						'Classmates',             --Last primary objective
						'Research Technology',    --Seconary objective
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C01',
					objs = {
						'The Gate Escape',        --Last primary objective
						'Research Technology',    --Seconary objective
						'The Shield',             --Seconary objective
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C02',
					objs = {
						'Serve the Server',      --Only primary objective
						'Research Technology',   --Seconary objective
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C03',
					objs = {
						'Lizard King',           --Last primary objective
						'Research Technology',   --Seconary objective
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C04',
					objs = {
						'Brothers and Sisters in Arms', --Last primary objective
						'Research Technology',          --Seconary objective
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C05',
					objs = {
						'Well Stocked',           --Only primary objective
						'Carrier Away',           --Seconary objective
						'Research Technology',    --Seconary objective
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C06',
					objs = {
						'End Gauge',              --Only primary objective
						'Those Mortal Coils',     --Seconary objective
						'Research Technology',    --Seconary objective
					},
				},

			}
		},
		{
			title='Completist',
			key  ='ACH_COMPLETIST',
			id = ACHIEVEMENT_ACH_COMPLETIST,
			type ='objective',
			need ={
				{
					camp = 'UEF',
					map = 'SC2_CA_U01',
					objs = {
						'Survivor',
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U02',
					objs = {
						'Economic Opportunist',
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U03',
					objs = {
						'Master of the Seas',
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U04',
					objs = {
						'Brutal Conqueror',
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U05',
					objs = {
						'Experimenter',
					},
				},
				{
					camp = 'UEF',
					map = 'SC2_CA_U06',
					objs = {
						'Nuke King',
						'None Shall Pass!',
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I01',
					objs = {
						'Blockhead',
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I02',
					objs = {
						'Master Tactician',
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I03',
					objs = {
						'Not the Bees!',
						'Pro Anti%-Air',
						'Agent Provocateur',
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I04',
					objs = {
						'Experimental Fanatic',
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I05',
					objs = {
						'Supremest Commander',
					},
				},
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I06',
					objs = {
						'Bot Lord',
						'A Czar is Born',
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C01',
					objs = {
						'Survival Expert',
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C02',
					objs = {
						'Master Thief',
						'Great Escapist',
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C03',
					objs = {
						'Cache and Carry',
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C04',
					objs = {
						'Sultan of Soul',
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C05',
					objs = {
						'Master of the Deep',
					},
				},
				{
					camp = 'Cybran',
					map = 'SC2_CA_C06',
					objs = {
						'Research Savant',
						'Master of Pawns',
					},
				},
			}
		},
		{
			title='Score Hoarder', -- Get a complete campaign score over 150,000
			key  ='ACH_SCOREHOARDER',
			id = ACHIEVEMENT_ACH_SCOREHOARDER,
			points = 50,
			type ='campaign_score',
			need ={
				{
					id  = 'total_campaign_score',
					lev = 150000,
				},
			}
		},
		{
			title='Survivor',
			key  ='ACH_SURVIVOR',
			id = ACHIEVEMENT_ACH_SURVIVOR,
			type ='objective',
			need ={
				{
					camp = 'UEF',
					map = 'SC2_CA_U01',
					objs = {
						'Survivor',
					},
				},
			}
		},
		{
			title='Bot Lord',
			key  ='ACH_BOTLORD',
			id = ACHIEVEMENT_ACH_BOTLORD,
			type ='objective',
			need ={
				{
					camp = 'Illuminate',
					map = 'SC2_CA_I06',
					objs = {
						'Bot Lord',
					},
				},
			}
		},
		{
			title='Survivalist',
			key  ='ACH_SURVIVALIST',
			id = ACHIEVEMENT_ACH_SURVIVALIST,
			type ='objective',
			need ={
				{
					camp = 'Cybran',
					map = 'SC2_CA_C01',
					objs = {
						'Survival Expert',
					},
				},
			}
		},
		{
			title='Replayer', -- Improve your score on any operation
			key  ='ACH_REPLAYER',
			id = ACHIEVEMENT_ACH_REPLAYER,
			points = 5,
			type ='set_stat',
			need ={
				{
					id  = 'improved_campaign_score',
					lev = 1,
				},
			}
		},
		{
			title='Cakewalk', -- Win a skirmish match against any AI opponent
			key  ='ACH_CAKEWALK',
			id = ACHIEVEMENT_ACH_CAKEWALK,
			points = 5,
			type ='set_stat',
			need ={
				{
					id  = 'won_skirmish_any_ai',
					lev = 1,
				},
			}
		},
		{
			title='Good Game', -- Win a skirmish match against all AI opponents
			key  ='ACH_GOODGAME',
			id = ACHIEVEMENT_ACH_GOODGAME,
			points = 10,
			type ='set_stat',
			need ={
				{
					id  = 'won_skirmish_all_ai',
					lev = 1,
				},
			}
		},
		{
			title='Luddite', -- Win a skirmish match without building any Experimentals
			key  ='ACH_LUDDITE',
			id = ACHIEVEMENT_ACH_LUDDITE,
			points = 10,
			type ='skirmish_wins',
			need ={
				{
					id  = 'won_skirmish_no_experimentals',
					lev = 1
					,
				},
			}
		},
		{
			title='To The Victor...', -- Win 25 skirmish matches
			key  ='ACH_TOTHEVICTOR',
			id = ACHIEVEMENT_ACH_TOTHEVICTOR,
			points = 25,
			type ='skirmish_wins',
			need ={
				{
					id  = 'skirmish_win_count',
					lev = 25,
				},
			}
		},
		{
			title='Rushin\' Front', -- Win a skirmish match in less than five minutes
			key  ='ACH_RUSHINFRONT',
			id = ACHIEVEMENT_ACH_RUSHINFRONT,
			points = 10,
			type ='min_stat',
			need ={
				{
					id  = 'min_skirmish_win_time',
					low_lev = 299,
				},
			}
		},
		{
			title='Sampling', -- Win a skirmish match with each faction
			key  ='ACH_SAMPLING',
			id = ACHIEVEMENT_ACH_SAMPLING,
			points = 10,
			type ='faction_win',
			need ={
				{
					fac  = 'UEF',
					skirmish_won = 1,
				},
				{
					fac  = 'CYBRAN',
					skirmish_won = 1,
				},
				{
					fac  = 'ILLUMINATE',
					skirmish_won = 1,
				},
			}
		},
		-- begin Dating block
		-- the following 3 entries simulate a OR in the needs operation, one for each faction. Thats whay they have the same id and key, they have different need blocks
		{
			title='Dating', -- Play 10 skirmish matches with one faction
			key  ='ACH_DATING',
			id = ACHIEVEMENT_ACH_DATING,
			points = 15,
			type ='faction_win',
			need ={
				{
					count = 1,
					fac  = 'UEF',
					skirmish_played = 10,
				},
				{
					fac  = 'CYBRAN',
					skirmish_played = 10,
				},
				{
					fac  = 'ILLUMINATE',
					skirmish_played = 10,
				},
			}
		},
		{
			title='Committed Relationship', -- Play 25 skirmish matches with one faction
			key  ='ACH_COMMITTEDRELATIONSHIP',
			id = ACHIEVEMENT_ACH_COMMITTEDRELATIONSHIP,
			points = 25,
			type ='faction_win',
			need ={
				{
					count = 1,
					fac  = 'UEF',
					skirmish_played = 25,
				},
				{
					fac  = 'CYBRAN',
					skirmish_played = 25,
				},
				{
					fac  = 'ILLUMINATE',
					skirmish_played = 25,
				},
			}
		},
        {
			title='Sightseer', -- Win a skirmish match on every multiplayer map
			key  ='ACH_SIGHTSEER',
			id = ACHIEVEMENT_ACH_SIGHTSEER,
			points = 20,
			type ='map',
			need ={
					{id = 'SC2_MP_001',},
					{id = 'SC2_MP_002',},
					{id = 'SC2_MP_003',},
					{id = 'SC2_MP_004',},
					{id = 'SC2_MP_005',},
					{id = 'SC2_MP_006',},
					{id = 'SC2_MP_101',},
					{id = 'SC2_MP_102',},
					{id = 'SC2_MP_104',},
					{id = 'SC2_MP_105',},
					{id = 'SC2_MP_106',},
					{id = 'SC2_MP_201',},
					{id = 'SC2_MP_202',},
					{id = 'SC2_MP_203',},
					{id = 'SC2_MP_204',},
					{id = 'SC2_MP_205',},
					{id = 'SC2_MP_206',},
					{id = 'SC2_MP_302',},
					{id = 'SC2_MP_305',},
					{id = 'SC2_MP_306',},
			}
		},
		{
			title='Sharp Shooter', -- Destroy 10,000 units
			key  ='ACH_SHARPSHOOTER',
			id = ACHIEVEMENT_ACH_SHARPSHOOTER,
			points = 25,
			type ='kills',
			need ={
				{
					id  = 'enemies_killed',
					lev = 10000,
				},
			}
		},
		{
			title='Masster', -- Extract 1,000,000 mass
			key  ='ACH_MASSTER',
			id = ACHIEVEMENT_ACH_MASSTER,
			points = 25,
			type ='build',
			need ={
				{
					id  = 'resources_mass_built',
					lev = 1000000,
				},
			}
		},
		{
			title='Master Builder', -- Build 10,000 units
			key  ='ACH_MASTERBUILDER',
			id = ACHIEVEMENT_ACH_MASTERBUILDER,
			points = 25,
			type ='build',
			need ={
				{
					id  = 'units_built',
					lev = 10000,
				},
			}
		},
		{
			title='Time Cruncher', -- Play the game for over 24 hours in total
			key  ='ACH_TIMECRUNCHER',
			id = ACHIEVEMENT_ACH_TIMECRUNCHER,
			points = 20,
			type ='time',
			need ={
				{
					id  = 'total_time_played',
					lev = 86400,
				},
			}
		},
		{
			title='Internet Commander', -- Win an online match
			key  ='ACH_INTERNETCOMMANDER',
			id = ACHIEVEMENT_ACH_INTERNETCOMMANDER,
			points = 10,
			type ='online_won',
			need ={
				{
					id  = 'online_matches_won',
					lev = 1,
				},
			}
		},
		{
			title='Friends', -- Win a co-op match vs AI
			key  ='ACH_FRIENDS',
			id = ACHIEVEMENT_ACH_FRIENDS,
			points = 10,
			type ='online_won',
			need ={
				{
					id  = 'coop_matches_won_vs_ai',
					lev = 1,
				},
			}
		},
		{
			title='Ranker', -- Win a Ranked online match
			key  ='ACH_RANKER',
			id = ACHIEVEMENT_ACH_RANKER,
			points = 10,
			type ='online_won',
			need ={
				{
					id  = 'ranked_online_matches_won',
					lev = 1,
				},
			}
		},
		{
			title='Supreme Online Commander', -- Win 25 Ranked online matches
			key  ='ACH_SUPREMEONLINECOMMANDER',
			id = ACHIEVEMENT_ACH_SUPREMEONLINECOMMANDER,
			points = 50,
			type ='online_won',
			need ={
				{
					id  = 'ranked_online_matches_won',
					lev = 25,
				},
			}
		},
		{
			title='Good Friends', -- Win 10 co-op matches vs AI
			key  ='ACH_GOODFRIENDS',
			id = ACHIEVEMENT_ACH_GOODFRIENDS,
			points = 20,
			type ='online_won',
			need ={
				{
					id  = 'coop_matches_won_vs_ai',
					lev = 10,
				},
			}
		},
	}
}

function achLOG_Check(strACH,bIsCurrent)
	if bIsCurrent then
		LOG('CHECKING FOR:[', strACH, ']')
	end
end

function achLOG_Success(bIsCurrent)
	if bIsCurrent then
		LOG('..........SUCCESS!!!..........')
	end
end

function achLOG_Bonus(strACH,bIsCurrent)
	if bIsCurrent then
		LOG('..........BONUS SUCCESS:[', strACH, ']!!!..........')
	end
end

function achLOG_MapComplete(strMAP,bIsCurrent)
	if bIsCurrent then
		LOG('..........MAP COMPLETE:[', strMAP, ']')
	end
end

function achLOG_SkirmCheck(bPlayed,curStat,needStat,Faction,bIsCurrent)
	if bIsCurrent then
		if bPlayed then
			LOG('..........SKIRMISH CHECK (PLAYED):[', curStat, ' of ', needStat, '] FAC:[', Faction, ']')
		else
			LOG('..........SKIRMISH CHECK (WON):[', curStat, ' of ', needStat, '] FAC:[', Faction, ']')
		end
	end
end

function achLOG_StatCheck(curStat,needStat,bIsCurrent)
	if bIsCurrent then
		LOG('..........STAT CHECK:[', curStat, ' of ', needStat, ']')
	end
end

function achLOG_Incomplete(bIsCurrent)
	if bIsCurrent then
		LOG('..........NOT FINISHED YET..........')
	end
end

function setAchievement( aid )
    local acdone = {}
    local alst = {}
    alst = Achievments.items
    acdone.id = alst[aid].id
    acdone.title = alst[aid].title

    return acdone
end

function GetAchievementNO( AID )
    local acc = nil
    for k, v in Achievments.items do
        if v.id == AID then
            acc = v
            break
        end
    end
    return acc
end

function fillSkirmishMaps(lev,mode,count, multi, skirmish, KOTH,CP)
    local reqMaps = {}
    local mapcnt = 0
    local str_test = ''

    for i,sceninfo in scenarios do
        if  sceninfo.type == "skirmish"  then
            if KOTH and (not sceninfo.KOTHValid ) then
                continue
            end
            if CP and (not sceninfo.CPValid ) then
                continue
            end
            mapcnt = mapcnt + 1
            reqMaps[mapcnt]={}
            local mapname = ""
            --local mapparts = split_path(sceninfo.map)
            --if table.getn(mapparts) > 1 then
            --    mapname= mapparts[2]
            --else
                mapname = sceninfo.description
            --end
       ----     str_test = str_test..", "..i.."="..mapname
       ----     LOG('Skirmish map ('..mapname..'):'..sceninfo.description)
            reqMaps[mapcnt].id   = mapname
            if lev then
                reqMaps[mapcnt].lev  = lev
            end
            if mode then
                reqMaps[mapcnt].mode = mode
            end
            if skirmish then
                reqMaps[mapcnt].skirmish = skirmish
            end
            if count then
                reqMaps[mapcnt].count = count
            end
            if multi then
                reqMaps[mapcnt].multi = multi
            end
        end
    end
    return reqMaps
end

function checkAchievement( atype, statname, value, level, extradata, bIsCurrent )
    local acdone = {}
    local cnt = 0
    local needsmet =0
--  if it meets an acheiment level set its id, and points
    local alst = {}
    alst = Achievments.items
    local max = table.getn(alst)

    for index = 1, max do
       if alst[index].type == atype then
            needsmet =0

			-- adding this bool to indicate if the statnames required for this instance of the given type of
			--		acheivement are matches for the statname being checked - otherwise, there is no reall acheivement to report about
			local bReportIncomplete = false

            local needcnt = table.getn(alst[index].need)
            -- check that the need are met (there should only be 1 for all acheivements that are not map based
            for i = 1, needcnt do
                local needitm = alst[index].need[i]
                if needitm.id == statname then

					-- since this specific instance of this type of acheivement contains at least one need of the same statname
					--		we are currently testing, include it in our reporting if it proves to be incomplete
					bReportIncomplete = true

					achLOG_Check( alst[index].title, bIsCurrent )
                    if extradata then
						achLOG_StatCheck( value, needitm.lev, bIsCurrent )
                        if (needitm.fac == extradata) and ((needitm.lev == nil) or(needitm.lev <= value)) then
                            needsmet = needsmet + 1
                        end
                    else
                        -- low level will check that the defined value is greater than or equal to the new value
                        if (needitm.low_lev != nil) then
							achLOG_StatCheck( value, needitm.low_lev, bIsCurrent )
                            if (needitm.low_lev >= value) then
                                needsmet = needsmet + 1
                            end
                        else
							achLOG_StatCheck( value, needitm.lev, bIsCurrent )
							if (needitm.lev == nil) or(needitm.lev <= value) then
                            	needsmet = needsmet + 1
                        	end
						end
                    end
                end
            end
            if needsmet >= needcnt then
				achLOG_Success(bIsCurrent)
                  cnt = cnt + 1
                  acdone[cnt] = {}
                  acdone[cnt].id = alst[index].id
                  acdone[cnt].title = alst[index].title
			elseif bReportIncomplete then
				achLOG_Incomplete(bIsCurrent)
            end
       end
    end

    acdone.count = cnt
  return acdone
end

-- for checking an acheivment across the 'completed' user maps
function checkMapAchievNo( aid, maps, bIsCurrent )
  local acOK = false
  local aItem = Achievments.items[aid]
  local needCnt = table.getn(aItem.need)
  local totalNeeds = 0
  local needsmeet = 0

  if aItem.need[1].id == 'SCMP' then
    local newitems ={}
    local setNeeds = true
    newitems = fillSkirmishMaps( aItem.need[1].lev, aItem.need[1].mode, aItem.need[1].count, aItem.need[1].multi, aItem.need[1].skirmish, aItem.need[1].mtype=="KOTH", aItem.need[1].mtype=="CP" )
    if aItem.need[1].multi and aItem.need[1].lev  then
       needCnt = aItem.need[1].lev
       setNeeds = false
    end
    aItem.need = table.deepcopy(newitems)
    if setNeeds then
       needCnt = table.getn(aItem.need)
    end
  end

  totalNeeds = table.getn(aItem.need)
  if aItem.need[1].count and aItem.need[1].count > 0 then
      needCnt = aItem.need[1].count
  end

  for i =1, totalNeeds do      -- check each A. need is met
      local aNeed = aItem.need[i]
      for k, v in maps do   -- check ALL user saved maps..
          if string.find(v.key, aNeed.id) != nil then  -- map name matches, or close match ie: SCMP if string.find(k.key, aNeed.id) != nil then
             if aNeed.lev then       -- need has a required level
              ---   if (( bitlib.band(aNeed.lev,v.lev) ) != 0) or ( (aNeed.lev == 7) and (v.lev >= 4)) then
                 if (( bitlib.band(aNeed.lev,v.lev) ) != 0) or ( (v.lev >= aNeed.lev)) then

                      if aNeed.mode then
                          if (bitlib.band(aNeed.mode,v.winmode)) != 0 then
                            -- achievement need is met
                            if (aNeed.multi ==nil)or(aNeed.multi == v.multi) then
                                needsmeet = needsmeet +1
								achLOG_MapComplete(aNeed.id,bIsCurrent)
                            end
                          end
                      else   --------- no mode required
                          -- achievement need is met
                          if (aNeed.multi ==nil)or(aNeed.multi == v.multi) then
								needsmeet = needsmeet +1
								achLOG_MapComplete(aNeed.id,bIsCurrent)
                          end
                      end

                 end
             else ----------------------------------- no level requirments...
                  if aNeed.mode then
                    if (bitlib.band(aNeed.mode,v.winmode)) != 0 then
                        -- achievment need is met
                        if (aNeed.multi ==nil)or(aNeed.multi == v.multi) then
                            needsmeet = needsmeet +1
							achLOG_MapComplete(aNeed.id,bIsCurrent)
                        end
                    end
                  else  --------- no mode required
                      -- achievment need is met
                      if (v.winmode > 0 ) then   -- and v.lev > 0) then --and v.lev > 0) then
                          if (aNeed.multi ==nil)or(aNeed.multi == v.multi) then
                            needsmeet = needsmeet +1
							achLOG_MapComplete(aNeed.id,bIsCurrent)
                          end
                      end
                  end
             end

          end
          local lid = aid..needsmeet
          if needsmeet >= needCnt then   --Achievement fully met.
             acOK = true
             break;
          elseif (needsmeet > 0) and (not findInTable( logged, lid )) then   -- for debug
             table.insert(logged,lid)
          end
      end
  end
  return acOK
end

function checkMapAchievement( maps, bIsCurrent )
  local acdone = {}
  local cnt = 0;

  for k, v in Achievments.items do
      if v.type == 'map' then
			achLOG_Check( v.title, bIsCurrent )
          if checkMapAchievNo(k, maps,bIsCurrent) then
				achLOG_Success(bIsCurrent)
              cnt = cnt + 1
              acdone[cnt] = {}
              acdone[cnt].id = v.id
              acdone[cnt].title = v.title
              if v.includes then
                  for j, inc in v.includes do
                      local currAC = nil
                      currAC = GetAchievementNO(inc.id)
                      if currAC then
							achLOG_Bonus(currAC.title,bIsCurrent)
                          cnt = cnt + 1
                          acdone[cnt] = {}
                          acdone[cnt].id = currAC.id
                          acdone[cnt].title = currAC.title
                      end
                  end
              end
		  else
				achLOG_Incomplete(bIsCurrent)
          end
      end
  end

  acdone.count = cnt
  return acdone
end

---NOTE: SC2 does not appear to use this check at all - bfricks 1/21/10
-- for checking an acheivment across the 'completed' user maps
function checkFactionAchievNo( aid, facBuilds, bIsCurrent )
  local acOK = false
  local aItem = Achievments.items[aid]
  local needCnt = table.getn(aItem.need)
  local totalNeeds = 0
  local needsmeet = 0
  totalNeeds = table.getn(aItem.need)

  for i =1, totalNeeds do      -- check each A. need is met
      local aNeed = aItem.need[i]
      for k, v in facBuilds do
          if v.fac == aNeed.fac then  --
             local funits = {}
             funits = v.units
             local funitcnt = table.getn(funits)
             for j= 1, funitcnt do
                 if funits[j].key == aNeed.id then
                     if aNeed.lev then  -- need has a required level
                         if aNeed.lev <= funits[j].value  then
                            needsmeet = needsmeet +1
                         end
                     else
                        needsmeet = needsmeet +1
                     end
                 end
             end
          end
          if needsmeet >= needCnt then   --achievment fully met.
             acOK = true
             break;
          end
      end
  end
  return acOK
end

function checkFactionWinAchievNo( aid, factions, bIsCurrent )
  local acOK = false
  local aItem = Achievments.items[aid]
  local needCnt = table.getn(aItem.need)
  local totalNeeds = 0
  local needsmeet = 0
  totalNeeds = table.getn(aItem.need)

  if aItem.need[1].count and aItem.need[1].count > 0 then
      needCnt = aItem.need[1].count
  end

  for i =1, totalNeeds do      -- check each A. need is met
      local aNeed = aItem.need[i]
      for k, v in factions do
          if v.fac == aNeed.fac then
              if aNeed.skirmish_played then
					achLOG_SkirmCheck( true, v.skirmish_played, aNeed.skirmish_played, v.fac, bIsCurrent )
					if aNeed.skirmish_played <= v.skirmish_played then
                    	needsmeet = needsmeet +1
					end
              end
              if aNeed.skirmish_won then
					achLOG_SkirmCheck( false, v.skirmish_won, aNeed.skirmish_won, v.fac, bIsCurrent )
					if aNeed.skirmish_won <= v.skirmish_won then
						needsmeet = needsmeet +1
					end
              end
          end
          if needsmeet >= needCnt then   --achievment fully met.
             acOK = true
             break;
          end
      end
  end
  return acOK
end

function checkFactionAchievement( factions, bIsCurrent )
-- TODO : logic to check all map  related achievments
  local acdone = {}
  local cnt = 0;

  for k, v in Achievments.items do
      if v.type == 'faction_build' then
			achLOG_Check( v.title, bIsCurrent )
          if checkFactionAchievNo(k, factions, bIsCurrent) then
				achLOG_Success(bIsCurrent)
                cnt = cnt + 1
                acdone[cnt] = {}
                acdone[cnt].id = v.id
                acdone[cnt].title = v.title
		  else
				achLOG_Incomplete(bIsCurrent)
          end
      elseif v.type == 'faction_win' then
			achLOG_Check( v.title, bIsCurrent )
          if checkFactionWinAchievNo(k, factions, bIsCurrent) then
				achLOG_Success(bIsCurrent)
                cnt = cnt + 1
                acdone[cnt] = {}
                acdone[cnt].id = v.id
                acdone[cnt].title = v.title
		  else
				achLOG_Incomplete(bIsCurrent)
          end
      end
  end

  acdone.count = cnt
  return acdone
end

function checkObjectiveAchievNo( aid, campMan )
  local aItem = Achievments.items[aid]
  local totalNeeds = table.getn(aItem.need)

  for i =1, totalNeeds do      -- check each A. need is met
      local aNeed = aItem.need[i]
      if not campMan.AreObjectivesComplete(aNeed) then
          return false
      end
  end
  return true
end

function checkObjectiveAchievements(campMan)
  local acdone = {}
  local cnt = 0
		LOG('---------------------------------------------------------------')
	LOG('checkObjectiveAchievements: BEGIN:')
  for k, v in Achievments.items do
      if v.type == 'objective' then
			LOG('CHECKING FOR:[', v.title, ']')
          if checkObjectiveAchievNo(k, campMan) then
				LOG('..........SUCCESS!!!..........')
              cnt = cnt + 1
              acdone[cnt] = {}
              acdone[cnt].id = v.id
              acdone[cnt].title = v.title
          end
      end
  end
	LOG('checkObjectiveAchievements: END.')
		LOG('---------------------------------------------------------------')

  acdone.count = cnt
  return acdone
end
