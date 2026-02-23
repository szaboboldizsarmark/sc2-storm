----------------------------------------------------------------------
-- File: lua/common/patchable_metadata.lua
-- Author: Steve Bauman
-- Summary: This is a dumping ground for any kind of data you may want to alter via patches
--
-- Copyright © 2010 Gas Powered Games, Inc.  All rights reserved.
-- Current map list:
--
-- 		'SC2_MP_001', -- Seton (4v4)
-- 		'SC2_MP_002', -- Open Palms (FFA 6)
-- 		'SC2_MP_003', -- Finn (1v1)
-- 		'SC2_MP_004', -- Duel (1v1)
-- 		'SC2_MP_005', -- Isis (2v2)
--		'SC2_MP_006', -- Arctic Refuge (FFA 4)
--		'SC2_MP_007', -- Emerald Crater (FFA 4)
--		'SC2_MP_101', -- Clarke (1v1)
--		'SC2_MP_102', -- Powderhorn (2v2)
--		'SC2_MP_103', -- Weddell (2v2)
--		'SC2_MP_104', -- Boolon (3v3)
--		'SC2_MP_105', -- Shipyard (1v1)
--		'SC2_MP_106', -- Command Center (3v1)
--		'SC2_MP_201', -- Markon (1v1)
--		'SC2_MP_202', -- Armory (2v2)
--		'SC2_MP_203', -- Mirror Island (2v2)
--		'SC2_MP_204', -- Borehole (2v2)
--		'SC2_MP_205', -- Corvana (3v3)
--		'SC2_MP_206', -- Van Horne (3v3)
--		'SC2_MP_301', -- Seraphim (1v1)
--		'SC2_MP_302', -- Treallach (FFA 4)
--		'SC2_MP_303', -- QAI (2v2)
--		'SC2_MP_304', -- Iskellian (4v4)
--		'SC2_MP_305', -- Boras (6 FFA)
-- 		'SC2_MP_306', -- Shiva (3)
--
--------------------------------------------------------------------------

pc_ranked_maps = {
	launch = {
		'SC2_MP_002',
		'SC2_MP_003',
		'SC2_MP_006',
		'SC2_MP_101',
		'SC2_MP_105',
		'SC2_MP_201',
	},
	season_01 = {
		'SC2_MP_003',
		'SC2_MP_004',
		'SC2_MP_101',
		'SC2_MP_105',
		'SC2_MP_301',
		'SC2_MP_302',
	},
	season_02 = {
		'SC2_MP_002',
		'SC2_MP_006',
		'SC2_MP_102',
		'SC2_MP_103',
		'SC2_MP_105',
		'SC2_MP_301',
		'SC2_MP_302',
		'SC2_MP_303',
	},
}

pc_unranked_maps = {
	launch = {
		'SC2_MP_002',
		'SC2_MP_003',
		'SC2_MP_004',
		'SC2_MP_005',
		'SC2_MP_006',
		'SC2_MP_007',
		'SC2_MP_101',
		'SC2_MP_102',
		'SC2_MP_103',
		'SC2_MP_105',
		'SC2_MP_201',
		'SC2_MP_203',
		'SC2_MP_301',
		'SC2_MP_302',
		'SC2_MP_303',
	}
}

x360_ranked_maps = {
	launch = {
		'SC2_MP_005',
		'SC2_MP_006',
		'SC2_MP_101',
		'SC2_MP_105',
		'SC2_MP_201',
		'SC2_MP_203',
		'SC2_MP_206',
		'SC2_MP_301',
	}
}

pc_matching_brackets = {
	bracket_01 = {
		name = 'bracket_01',
		min_rating = 0,
		max_rating = 1199,
	},
	bracket_02 = {
		name = 'bracket_03',
		min_rating = 1200,
		max_rating = 1399,
	},
	bracket_03 = {
		name = 'bracket_04',
		min_rating = 1400,
		max_rating = 1599,
	},
	bracket_04 = {
		name = 'bracket_05',
		min_rating = 1600,
		max_rating = 1799,
	},
	bracket_05 = {
		name = 'bracket_06',
		min_rating = 1800,
		max_rating = 1999,
	},
	bracket_06 = {
		name = 'bracket_07',
		min_rating = 2000,
		max_rating = 5000,
	},
}
