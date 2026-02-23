-- Maps specific key combinations to console commands
-- Key combos should be seperated by -'s
-- See keyNames.lua for key names! Key names for modifiers are as follows and must be followed by a dash ('-')
-- Shift = 0x10
-- Ctrl = 0x11
-- Alt = 0x12
defaultKeyMap = {
    ['Esc']                 = 'escape',
    ['Pause']               = 'pause',
    ['Ctrl-F']              = 'cap_frame',
    ['Alt-L']               = 'toggle_lifebars',
	['Ctrl-Q']             = 'toggle_voice',

-- Weapon and Intel Rings and Strategic View
    ['Ctrl-W']              = 'tog_military',
    ['Ctrl-I']              = 'tog_intel',
    ['Ctrl-O']              = 'tog_strategic_overlay',
	['Ctrl-Y']				= 'tog_stratmode_icons',

    ['F1']                  = 'toggle_key_bindings',
    ['F2']                  = 'toggle_score_screen',

-- Currently waiting for a new mesh
    ['F5']                  = 'ping_alert',
    ['F6']                  = 'ping_move',
    ['F7']                  = 'ping_attack',

	['F10']                 = 'toggle_main_menu',

    ['1']                   = 'group1',
    ['2']                   = 'group2',
    ['3']                   = 'group3',
    ['4']                   = 'group4',
    ['5']                   = 'group5',
    ['6']                   = 'group6',
    ['7']                   = 'group7',
    ['8']                   = 'group8',
    ['9']                   = 'group9',
    ['0']                   = 'group0',

    ['Ctrl-1']              = 'set_group1',
    ['Ctrl-2']              = 'set_group2',
    ['Ctrl-3']              = 'set_group3',
    ['Ctrl-4']              = 'set_group4',
    ['Ctrl-5']              = 'set_group5',
    ['Ctrl-6']              = 'set_group6',
    ['Ctrl-7']              = 'set_group7',
    ['Ctrl-8']              = 'set_group8',
    ['Ctrl-9']              = 'set_group9',
    ['Ctrl-0']              = 'set_group0',

    ['Shift-1']             = 'append_group1',
    ['Shift-2']             = 'append_group2',
    ['Shift-3']             = 'append_group3',
    ['Shift-4']             = 'append_group4',
    ['Shift-5']             = 'append_group5',
    ['Shift-6']             = 'append_group6',
    ['Shift-7']             = 'append_group7',
    ['Shift-8']             = 'append_group8',
    ['Shift-9']             = 'append_group9',
    ['Shift-0']             = 'append_group0',

    ['Ctrl-H']              = 'select_all_factory_onscreen',
    ['H']                   = 'select_nearest_factory',
    ['Ctrl-Shift-L']        = 'select_nearest_land_factory',
    ['Ctrl-Shift-A']        = 'select_nearest_air_factory',
    ['Ctrl-Shift-S']        = 'select_nearest_naval_factory',

    ['L']                   = 'pause_unit',
	['Ctrl-Shift-P']        = 'pause_all',
	['Ctrl-Shift-U']        = 'unpause_all',

	['B']                   = 'toggle_build_mode',
	['Shift-B']             = 'toggle_build_mode',

    ['Ctrl-A']              = 'select_air',
    ['Ctrl-S']              = 'select_naval',
    ['Ctrl-L']              = 'select_land',

    ['Ctrl-Z']              = 'select_all_units_of_same_type',
    ['Ctrl-X']              = 'select_all',
    ['Ctrl-C']              = 'select_all_onscreen',

    ['Ctrl-B']              = 'select_engineers',

--	['Shift-Period']        = 'goto_engineer',
	['Alt-Period']          = 'select_idle_engineer',
	['Period']              = 'cycle_engineers',
    ['Comma']               = 'goto_commander',
    ['Alt-Comma']           = 'select_commander',

    ['LeftBracket']         = 'mode',

    ['Ctrl-K']              = 'suicide',

	['Tab']					= 'toggle_research_menu',

-- Currently not supported in SC2; we should consider remapping them
    --['Tab']                 = 'next_cam_position',
    --['Shift-Tab']           = 'add_cam_position',
    --['Ctrl-Tab']            = 'rem_cam_position',

    ['Q']                   = 'zoom_in',
    ['W']                   = 'zoom_out',
    ['Shift-Q']             = 'zoom_in_fast',
    ['Shift-W']             = 'zoom_out_fast',

    ['V']                   = 'reset_camera',

    ['T']                   = 'track_unit',

    ['R']                   = 'repair',
    ['E']                   = 'reclaim',
    ['P']                   = 'patrol',
    ['A']                   = 'attack',
    ['C']                   = 'capture',
    ['S']                   = 'stop',
	['D']                   = 'dive',
    ['F']                   = 'ferry',
    ['G']                   = 'guard',
    ['U']                   = 'transport',
    ['M']                   = 'move',
    ['N']                   = 'nuke',

	['Ctrl-U']				= 'toggle_ui',

	-- Abilities
	['Ctrl-P']				= 'pullinsmash',
	['O']					= 'overcharge',
	['K']					= 'acu_hunker',
	['Ctrl-E']				= 'escapepod',
	['Ctrl-J']				= 'jump',
	['Ctrl-T']				= 'teleport',

--	['']					= 'disrupterstation',
--	['']					= 'halfbake',
--	['']					= 'hardenartillery',
--	['']					= 'knockbackweapon',
--	['']					= 'radaroverdrive',
--	['']					= 'roguenanites',
--	['K']					= 'point_defense_hunker',

	['Alt-Z']				= 'bombbouncercharge',
	['Alt-X']				= 'bombbouncermegablast',
	['Alt-M']				= 'convertenergy',
	['Alt-E']				= 'electroshock',
	['Alt-H']				= 'mobile_hunker',
	['Alt-D']				= 'powerdetonate',
	['Alt-R']				= 'triarmorhalfspeed',
	['Alt-Q']				= 'magnet',
	['Alt-W']				= 'magnetpush',

    ['Shift-R']             = 'shift_repair',
    ['Shift-E']             = 'shift_reclaim',
    ['Shift-P']             = 'shift_patrol',
    ['Shift-A']             = 'shift_attack',
    ['Shift-C']             = 'shift_capture',
    ['Shift-D']             = 'shift_dive',
    ['Shift-F']             = 'shift_ferry',
    ['Shift-G']             = 'shift_guard',
    ['Shift-U']             = 'shift_transport',
    ['Shift-M']             = 'shift_move',
    ['Shift-N']             = 'shift_nuke',

    ['NumMinus']            = 'decrease_game_speed',
    ['NumPlus']             = 'increase_game_speed',
    ['NumStar']             = 'reset_game_speed',
}

keymapTooltipHotkeys = {
    ['RULEUCC_Repair']              = 'R',
    ['RULEUCC_Reclaim']             = 'E',
    ['RULEUCC_Patrol']              = 'P',
    ['RULEUCC_Attack']              = 'A',
    ['RULEUCC_Capture']             = 'C',
    ['RULEUCC_Stop']                = 'S',
	['RULEUCC_Dive']                = 'D',
    ['RULEUCC_Ferry']               = 'F',
    ['RULEUCC_Guard']               = 'G',
    ['RULEUCC_Transport']           = 'U',
    ['RULEUCC_Move']                = 'M',
    ['RULEUCC_Nuke']                = 'N',
	['RULEUCC_Jump']				= 'Ctrl-J',
	['RULEUCC_Teleport']			= 'Ctrl-T',

	['pullinsmash']					= 'Ctrl-P',
	['overcharge']					= 'O',
	['acu_hunker']					= 'K',
	['escapepod']					= 'Ctrl-E',

	['convertenergy']				= 'Alt-M',
	['convertenergyid']				= 'Ctrl-M',
	['electroshock']				= 'Alt-E',
	['mobile_hunker']				= 'Alt-H',
	['powerdetonate']				= 'Alt-D',
	['triarmorhalfspeed']			= 'Alt-R',
	['bombbouncercharge']			= 'Alt-Z',
	['bombbouncermegablast']		= 'Alt-X',
	['magnet']						= 'Alt-Q',
	['magnetpush']					= 'Alt-W',

--	['point_defense_hunker']		= 'K',
--	['disrupterstation']			= '',
--	['halfbake']					= '',
--	['hardenartillery']				= '',
--	['knockbackweapon']				= '',
--	['radaroverdrive']				= '',
--	['roguenanites']				= '',
}

debugKeyMap = {
-- Network Diagnostics
	['Ctrl-Alt-5']				= 'diag_toggle_netstats',
	['Ctrl-Alt-6']				= 'diag_toggle_bandwidth',

-- Perf diagnostics
	['Ctrl-Alt-7']				= 'diag_toggle_frametime',

    ['NumSlash']            = 'show_fps',
    ['Ctrl-V']              = 'cam_free',
    ['Alt-0'] 				= 'print_buffs',
    ['Ctrl-Alt-P']          = 'debug_navpath',
    ['Alt-F2']              = 'debug_create_unit',
    ['Alt-T']               = 'debug_teleport',
    ['Alt-A']               = 'debug_run_opponent_AI',
    ['Ctrl-Alt-B']          = 'debug_blingbling',
    ['Alt-Delete']          = 'debug_destroy_units',

    ['Ctrl-Alt-Comma']      = 'debug_graphics_fidelity_0',
    ['Ctrl-Alt-Period']     = 'debug_graphics_fidelity_2',

    ['Alt-F']				= 'debug_cam_zoom_far',
    ['Alt-C']               = 'debug_cam_zoom_near',

    ['Alt-F3']              = 'debug_scenario_method_f3',
    ['Shift-F3']            = 'debug_scenario_method_shift_f3',
    ['Ctrl-F3']             = 'debug_scenario_method_ctrl_f3',
    ['Shift-F4']            = 'debug_scenario_method_shift_f4',
    ['Ctrl-F4']             = 'debug_scenario_method_ctrl_f4',
    ['Ctrl-Alt-F4']         = 'debug_scenario_method_ctrl_alt_f3',
    ['Ctrl-Shift-F4']       = 'debug_scenario_method_f4',
    ['Ctrl-Shift-F5']       = 'debug_scenario_method_f5',
    ['Shift-F5']            = 'debug_scenario_method_shift_f5',
    ['Ctrl-F5']             = 'debug_scenario_method_ctrl_f5',
    ['Ctrl-Alt-F5']         = 'debug_scenario_method_ctrl_alt_f5',

    ['Ctrl-Alt-Shift-F8']   = 'debug_campaign_instawin',
    ['Shift-F6']            = 'debug_create_entity',
    ['Shift-F7']            = 'debug_show_stats',
--    ['Shift-F8']            = 'debug_show_army_stats',
    ['F9']                  = 'debug_toggle_log_window',
    ['Alt-F9']              = 'debug_open_lua_debugger',
--    ['Alt-F11']             = 'debug_show_frame_stats',
    ['Ctrl-Alt-W']          = 'debug_render_wireframe',
    ['Ctrl-Shift-W']        = 'debug_weapons',
    ['Ctrl-Alt-O']          = 'debug_grid',
    ['Ctrl-Alt-U']          = 'debug_toggle_ui',
    ['Ctrl-Alt-N']          = 'debug_gpnav_overlay',
--  ['Alt-Q']               = 'debug_show_focus_ui_control',
--  ['Alt-W']               = 'debug_dump_focus_ui_control',
--  ['Alt-D']               = 'debug_dump_ui_controls',
    ['Alt-V']               = 'debug_skeletons',
    ['Alt-B']               = 'debug_bones',
	['Alt-G']				= 'debug_selected_attack_ground',

    ['Ctrl-Shift-X']        = 'debug_redo_console_command',
    ['Ctrl-Shift-C']        = 'debug_copy_units',
    ['Ctrl-Shift-V']        = 'debug_paste_units',

    ['Alt-N']               = 'debug_nodamage',
    ['Ctrl-Alt-E']          = 'debug_show_emitter_window',
    ['Ctrl-Alt-R']          = 'debug_reload_effect_templates',
    ['Ctrl-Alt-Shift-R']    = 'debug_reload_effect_utilities',
	['Ctrl-Shift-R']		= 'debug_give_me_all_research',
    ['Ctrl-Alt-Z']          = 'debug_sally_shears',
    ['Ctrl-Shift-Alt-C']    = 'debug_collision',
    ['Ctrl-Slash']          = 'debug_pause_single_step',
    ['Ctrl-F10']            = 'debug_restart_session',
    ['Ctrl-Shift-F1']       = 'debug_toggle_pannels',

    ['Alt-S']               = 'debug_toggle_sound_info',
    ['Ctrl-Alt-S']          = 'debug_toggle_sound_logging',

    ['Minus']				= 'debug_set_unit_scale_down',
    ['Equals']				= 'debug_set_unit_scale_up',
}