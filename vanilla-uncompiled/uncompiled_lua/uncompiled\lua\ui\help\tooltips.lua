--****************************************************************************
--**  File     :  lua/modules/ui/help/tooltips.lua
--**  Author(s):  Ted Snook
--**
--**  Summary  :  Strings and images for the tooltips System
--**
--**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

Tooltips = {
    --*******************
    --** Orders Strings
    --*******************
    move = {
        title = "Move",
        description = "",
        keyID = "move",
    },
    attack = {
        title = "Attack",
        description = "",
        keyID = "attack",
    },
    patrol = {
        title = "Patrol",
        description = "",
        keyID = "patrol",
    },
    stop = {
        title = "Stop",
        description = "",
        keyID = "stop",
    },
    assist = {
        title = "Assist",
        description = "",
        keyID = "guard",
    },
    mode_hold = {
        title = "Hold Fire",
        description = "Units will not engage enemies",
        keyID = "mode",
    },
    mode_aggressive = {
        title = "Ground Fire",
        description = "Units will attack targeted positions rather attack-move",
        keyID = "mode",
    },
    mode_return_fire = {
        title = "Return Fire",
        description = "Units will move and engage normally",
        keyID = "mode",
    },
    mode_mixed = {
        title = "Mixed Modes",
        description = "You have selected units that have multiple fire states",
        keyID = "mode",
    },
    mode_hold_fire = {
        title = "Hold Fire",
        description = "Units will not engage enemies",
        keyID = "mode",
    },
    mode_hold_ground = {
        title = "Ground Fire",
        description = "Units will attack targeted positions rather than attack-move",
        keyID = "mode",
    },
    mode_aggressive = {
        title = "Aggressive",
        description = "Units will actively return fire and pursue enemies",
        keyID = "mode",
    },
    build_tactical = {
        title = "Build Missile",
        description = "Right-click to toggle Auto-Build",
    },
    build_tactical_auto = {
        title = "Build Missile (Auto)",
        description = "Auto-Build Enabled",
    },
    build_nuke = {
        title = "Build Strategic Missile",
        description = "Right-click to toggle Auto-Build",
    },
    build_nuke_auto = {
        title = "Build Strategic Missile (Auto)",
        description = "Auto-Build Enabled",
    },
    overcharge = {
        title = "Overcharge",
        description = "",
        keyID = "overcharge",
    },
    transport = {
        title = "Transport",
        description = "",
        keyID = "transport",
    },
    fire_nuke = {
        title = "Launch Strategic Missile",
        description = "",
        keyID = "nuke",
    },
    fire_billy = {
        title = "Launch Advanced Tactical Missile",
        description = "",
        keyID = "nuke",
    },
    build_billy = {
        title = "Build Advanced Tactical Missile",
        description = "",
    },
    fire_tactical = {
        title = "Launch Missile",
        description = "",
        keyID = "launch_tactical",
    },
    teleport = {
        title = "Teleport",
        description = "",
        keyID = "teleport",
    },
    ferry = {
        title = "Ferry",
        description = "",
        keyID = "ferry",
    },
    sacrifice = {
        title = "Sacrifice",
        description = "",
    },
    dive = {
        title = "Surface/Dive Toggle",
        description = "Right-click to toggle auto-surface",
        keyID = "dive",
    },
    dive_auto = {
        title = "Surface/Dive Toggle",
        description = "Auto-surface enabled",
        keyID = "dive",
    },
    dock = {
        title = "Dock",
        description = "Recall aircraft to nearest air staging facility for refueling and repairs",
        keyID = "dock",
    },
    deploy = {
        title = "Deploy",
        description = "",
    },
    reclaim = {
        title = "Reclaim",
        description = "",
        keyID = "reclaim",
    },
    capture = {
        title = "Capture",
        description = "",
        keyID = "capture",
    },
    repair = {
        title = "Repair",
        description = "",
        keyID = "repair",
    },
    pause = {
        title = "Pause Construction",
        description = "Pause/unpause current construction order",
        keyID = "pause_unit",
    },
    toggle_omni = {
        title = "Omni Toggle",
        description = "Turn the selected units omni on/off",
    },
    toggle_shield = {
        title = "Shield Toggle",
        description = "Turn the selected units shields on/off",
    },
    toggle_shield_dome = {
        title = "Shield Dome Toggle",
        description = "Turn the selected units shield dome on/off",
    },
    toggle_shield_personal = {
        title = "Personal Shield Toggle",
        description = "Turn the selected units personal shields on/off",
    },
    toggle_sniper = {
        title = "Sniper Toggle",
        description = "Toggle sniper mode. Range, accuracy and damage are enhanced, but rate of fire is decreased when enabled",
    },
    toggle_weapon = {
        title = "Weapon Toggle",
        description = "Toggle between air and ground weaponry",
    },
    toggle_jamming = {
        title = "Radar Jamming Toggle",
        description = "Turn the selected units radar jamming on/off",
    },
    toggle_intel = {
        title = "Intelligence Toggle",
        description = "Turn the selected units radar, sonar or Omni on/off",
    },
    toggle_radar = {
        title = "Radar Toggle",
        description = "Turn the selection units radar on/off",
    },
    toggle_sonar = {
        title = "Sonar Toggle",
        description = "Turn the selection units sonar on/off",
    },
    toggle_production = {
        title = "Production Toggle",
        description = "Turn the selected units production capabilities on/off",
    },
    toggle_area_assist = {
        title = "Area-Assist Toggle",
        description = "Turn the engineering area assist capabilities on/off",
    },
    toggle_scrying = {
        title = "Scrying Toggle",
        description = "Turn the selected units scrying capabilities on/off",
    },
    scry_target = {
        title = "Scry",
        description = "View an area of the map",
    },
    vision_toggle = {
        title = "Vision Toggle",
        description = "",
    },
    toggle_stealth_field = {
        title = "Stealth Field Toggle",
        description = "Turn the selected units stealth field on/off",
    },
    toggle_stealth_personal = {
        title = "Personal Stealth Toggle",
        description = "Turn the selected units personal stealth field on/off",
    },
    toggle_cloak = {
        title = "Personal Cloak",
        description = "Turn the selected units cloaking on/off",
    },

    toggle_generic = {
        title = "Pause Toggle",
        description = "",
    },
    toggle_special = {
        title = "Fire Black Sun",
        description = "End the Infinite War",
    },
    first_helptip = {
        title = "Help Tips",
        description = "Click on the question mark icon to view detailed suggestions on how to play Supreme Commander: Forged Alliance",
    },
    drone = {
        title = "Select Drone",
        description = "Right click to toggle auto-assist",
    },
    drone_station = {
        title = "Select Station",
        description = "Right click to toggle auto-assist",
    },
    drone_ACU = {
        title = "Select ACU",
        description = "Right click to toggle auto-assist",
    },
    drone_SACU = {
        title = "Select SACU",
        description = "Right click to toggle auto-assist",
    },
    avatar_Avatar_ACU = {
        title = "ACU",
        description = "Left-click to select your ACU. Right-click to select and zoom to your ACU.",
    },

    avatar_Engineer_t1 = {
        title = "Tech 1 Engineers",
        description = "Right-click to cycle through idle T1 Engineers",
    },

    avatar_Engineer_t2 = {
        title = "Tech 2 Engineers",
        description = "Right-click to cycle through idle T2 Engineers",
    },

    avatar_Engineer_t3 = {
        title = "Tech 3 Engineers",
        description = "Right-click to cycle through idle T3 Engineers",
    },
    avatar_Engineer_t4 = {
        title = "Sub Commanders",
        description = "Right-click to cycle through idle Sub Commanders",
    },
    avatar_toggle = {
        title = "Toggle Avatars",
        description = "Click here to toggle avatars on or off",
    },
    avatar_group = {
        title = "Group [--]",
        description = "Click or press %s to select this group",
    },
    marker_move = {
        title = "<>",
        description = "",
    },
    marker_rename = {
        title = "Rename",
        description = "",
    },
    marker_delete = {
        title = "Delete",
        description = "",
    },

    --**********************
    --** Chat Strings
    --**********************
    chat_config = {
        title = "Configure Chat",
        description = "Click here to configure various chat options.",
    },
    chat_pin = {
        title = "AutoHide (Enabled)",
        description = "Click here to disable automatic hiding of this window.",
    },
    chat_pinned = {
        title = "AutoHide (Disabled)",
        description = "Click here to enable automatic hiding of this window.",
    },
    chat_close = {
        title = "Close",
        description = "Click here to close this window.",
    },
    chat_camera = {
        title = "Camera Link Toggle",
        description = "Adds a camera link to the end of your messages",
    },
    chat_private = {
        title = "Private Message",
        description = "Click here to choose a private message recipient.",
    },
    chat_allies = {
        title = "Allied Chat",
        description = "Click here to send your message to all of your allies.",
    },
    chat_all = {
        title = "All Chat",
        description = "Click here to send your message to all players.",
    },
    chat_filter = {
        title = "Chat Filters",
        description = "Show or hide messages from players",
    },
    chat_color = {
        title = "Chat Color",
        description = "Change the font color for various messages",
    },
    chat_fontsize = {
        title = "Font Size",
        description = "Set the font size of your messages",
    },
    chat_fadetime = {
        title = "Fade Time",
        description = "Set the fade time of the chat window",
    },
    chat_alpha = {
        title = "Window Alpha",
        description = "Set the alpha of the chat window",
    },
    chat_reset = {
        title = "Reset Chat Window",
        description = "Resets the position and layout of the chat window",
    },
    minimap_reset = {
        title = "Reset Minimap Window",
        description = "Resets the position and layout of the minimap window",
    },

    toggle_resource_icons = {
        title = "View Resources",
        description = "Toggle the display of resource locations",
    },
    toggle_mini_expanded_options = {
        title = "Toggle Option Buttons",
        description = "Toggles option and MFD buttons on or off.",
    },

    --**********************
    --** AI Strings
    --**********************
    aitype_easy = {
        title = "AI: Easy",
        description = "An AI for beginners",
    },
    aitype_medium = {
        title = "AI: Normal",
        description = "An average AI",
    },
    aitype_supreme = { -- needed?
        title = "AI: Supreme",
        description = "A very difficult AI",
    },
    aitype_unleashed = { -- needed?
        title = "AI: Unleashed",
        description = "The most difficult AI that follows its own rules",
    },
    aitype_adaptive = {
        title = "AI: Adaptive",
        description = "A very difficult AI that shifts between offense and defense as the game progresses",
    },
    aitype_rush = {
        title = "AI: Rush",
        description = "A very difficult aggressive AI that balances land, air and naval forces",
    },
    aitype_rushair = {
        title = "AI: Air Rush",
        description = "A very difficult aggressive AI that prefers air forces",
    },
    aitype_rushland = {
        title = "AI: Land Rush",
        description = "A very difficult aggressive AI that prefers land forces",
    },
    aitype_rushnaval = {
        title = "AI: Naval Rush",
        description = "A very difficult aggressive AI that prefers naval forces",
    },
    aitype_turtle = {
        title = "AI: Turtle",
        description = "A very difficult AI that favors defense and careful expansion",
    },
    aitype_tech = {
        title = "AI: Tech",
        description = "A very difficult AI that aggressively persues high tier units",
    },
    aitype_adaptivecheat = {
        title = "AIx: Adaptive",
        description = "An extremely difficult cheating AI that shifts between offense and defense as the game progresses",
    },
    aitype_rushcheat = {
        title = "AIx: Rush",
        description = "An extremely difficult cheating AI that balances land, air and naval forces",
    },
    aitype_rushaircheat = {
        title = "AIx: Air Rush",
        description = "An extremely difficult cheating AI that prefers air forces",
    },
    aitype_rushlandcheat = {
        title = "AIx: Land Rush",
        description = "An extremely difficult cheating AI that prefers land forces",
    },
    aitype_rushnavalcheat = {
        title = "AIx: Naval Rush",
        description = "An extremely difficult cheating AI that prefers naval forces",
    },
    aitype_turtlecheat = {
        title = "AIx: Turtle",
        description = "An extremely difficult cheating AI that favors defense and careful expansion",
    },
    aitype_techcheat = {
        title = "AIx: Tech",
        description = "An extremely difficult cheating AI that aggressively persues high tier units",
    },
    aitype_random = {
        title = "AI: Random",
        description = "Randomly chooses an AI type",
    },
    aitype_randomcheat = {
        title = "AIx: Random",
        description = "Randomly chooses one of the cheating AI types",
    },


    --**********************
    --** Economy Strings
    --**********************
    mass_rate = {
        title = "Economic Mass Rate",
        description = "Toggle between income-per-second and efficiency rating values",
    },
    energy_rate = {
        title = "Economic Energy Rate",
        description = "Toggle between income per second and efficiency rating values",
    },
    mass_storage = {
        title = "Mass Storage",
        description = "Current and maximum Mass storage values",
    },
    energy_storage = {
        title = "Energy Storage",
        description = "Current and maximum Energy storage values",
    },
    mass_extended_display = {
        title = "Mass Income/Expense",
        description = "Toggle display of Mass being generated and spent per second",
    },
    energy_extended_display = {
        title = "Energy Income and Expense",
        description = "Toggle display Energy generated and spent per second",
    },
    overall = {
        title = "Build Efficiency",
        description = "Your overall Economic Efficiency",
    },


    --**********************
    --** Options Strings
    --**********************
    options_wheel_sensitivity = {
        title = "Zoom Wheel Sensitivity",
        description = "Sets the Zoom Speed when using the Mouse Wheel",
    },
    options_quick_exit = {
        title = "Quick Exit",
        description = "When close box or alt-f4 are pressed, no confirmation dialog is shown",
    },
    options_help_prompts = {
        title = "Help Prompts",
        description = "Toggles display of In-game Help and Tutorial Prompts",
    },
    options_mainmenu_bgmovie = {
        title = "Main Menu Background Movie",
        description = "Toggles the movie playing in the background of the main menu",
    },
    options_reset_help_prompts = {
        title = "Reset Help Prompts",
        description = "Sets all In-game Help Prompts as unread",
    },
     options_stratview = {
        title = "Strategic View",
        description = "Sets whether or not the mini-map is automatically on or off",
    },
      options_strat_icons_always_on = {
        title = "Always Render Strategic Icons",
        description = "Strategic icons are always shown, regardless of zoom distance",
    },
      options_uvd_format = {
        title = "Construction Tooltip Information",
        description = "Shows full, partial or no description when the unit icon is moused over",
    },
     options_mp_taunt_head = {
        title = "MP Taunt Head",
        description = "Select which 3D head is displayed when taunts are used in multiplayer",
    },
    options_mp_taunt_head_enabled = {
        title = "Multiplayer Taunts",
        description = "Turns taunts on and off in multiplayer",
    },
    options_dual_mon_edge = {
        title = "Dual Monitor Screen Edge",
        description = "Toggles the Edge between 2 Monitors as blocking Mouse Movement or allowing a Cursor Transition",
    },
    options_tooltips = {
        title = "Display Tooltips",
        description = "Toggles whether or not Tooltips are displayed",
    },
    options_tooltip_delay = {
        title = "Tooltip Delay",
        description = "Sets the Delay before Tooltips are displayed",
    },
    options_persistent_built_mode = {
        title = "Persistent Build Mode",
        description = "Toggles whether build mode is cancelled after pressing a key for a unit",
    },
    options_econ_warnings = {
        title = "Economy Warnings",
        description = "Shows automatic alerts when the economy is performing poorly",
    },
    options_ui_animation = {
        title = "UI Animation",
        description = "Toggles whether or not Interface Animations are shown",
    },
    options_primary_adapter = {
        title = "Primary Adapter",
        description = "Sets the Resolution or Display Mode for the Primary Monitor (1024x768 = fastest)",
    },
    options_fidelity_presets = {
        title = "Fidelity Presets",
        description = "Preset values for video options (low = fastest)",
    },
    options_bg_image = {
        title = "Background Image",
        description = "Toggles display of the Image under the World Map (off = fastest)",
    },
    options_fidelity = {
        title = "Fidelity",
        description = "Sets Rendering Fidelity for Objects, Terrain, and Water (low = fastest)",
    },
    options_shadow_quality = {
        title = "Shadow Fidelity",
        description = "Sets Rendering Fidelity for Shadows (off = fastest)",
    },
    options_antialiasing = {
        title = "Anti-Aliasing",
        description = "Toggles Full Scene Anti-Aliasing (off = fastest)",
    },
    options_texture_level = {
        title = "Texture Detail",
        description = "Sets the number of Mip Levels that are not Rendered (low = fastest)",
    },
    options_level_of_detail = {
        title = "Level Of Detail",
        description = "Set the rate at which objects LOD out (low = fastest)",
    },
    options_master_volume = {
        title = "Master Volume",
        description = "Sets the Games overall Volume Level",
    },
    options_fx_volume = {
        title = "FX Volume",
        description = "Sets the Volume of the Game Sound Effects",
    },
    options_music_volume = {
        title = "Music Volume",
        description = "Sets the Volume of the Game Music",
    },
    options_ui_volume = {
        title = "Interface Volume",
        description = "Sets the Volume of all Interface Sounds",
    },
    options_vo_volume = {
        title = "VO Volume",
        description = "Sets the Volume of all Voice and Movie Sounds",
    },
    options_credits = {
        title = "Credits",
        description = "View the Game Credits",
    },
    options_eula = {
        title = "EULA",
        description = "View the End-User License Agreement",
    },
    options_show_help_prompts_now = {
        title = "Show Help Now",
        description = "View Help Prompts",
    },

    options_tab_gameplay = {
        title = "Gameplay",
        description = "View and adjust Game options",
    },

    options_tab_video = {
        title = "Video",
        description = "View and adjust Display and Graphic options",
    },

    options_tab_sound = {
        title = "Sound",
        description = "View and adjust Sound and Volume options",
    },

    options_tab_about = {
        title = "About",
        description = "View the EULA and Credits",
    },

    options_tab_apply = {
        title = "Apply",
        description = "Save any Changes",
    },

    options_reset_all = {
        title = "Reset",
        description = "Restore original Game Settings",
    },
    map_select_sizeoption = {
        title = "Map Size",
        description = "",
    },
    map_select_size = {
        title = "Map Size",
        description = "Sort by Battlefield size",
    },
    map_select_maxplayers = {
        title = "Supported Players",
        description = "",
    },
    map_select_supportedplayers = {
        title = "Supported Players",
        description = "Sort by the maximum number of Players allowed",
    },
    options_vsync = {
        title = "Vertical Sync",
        description = "Sync to vertical refresh of monitor",
    },
    options_subtitles = {
        title = "Display Subtitles",
        description = "Toggles the display of subtitles during movies",
    },
    options_screen_edge_pans_main_view = {
        title = "Screen Edge Pans Main View",
        description = "Toggles the ability to pan the main map view by moving the mouse to the edge of the screen in full screen mode",
    },
    options_arrow_keys_pan_main_view = {
        title = "Arrow Keys Pan Main View",
        description = "Toggles the ability to pan the main map view by holding down the arrow keys",
    },
    options_secondary_adapter = {
        title = "Secondary Adapter",
        description = "If available on your system, sets the resolution or display mode for the secondary monitor (full screen only)",
    },
    options_keyboard_pan_accelerate_multiplier = {
        title = "Accelerated Pan Speed Multiplier",
        description = "This multiplies the pan speed of camera when the ctrl key is held down",
    },
    options_keyboard_pan_speed = {
        title = "Pan Speed",
        description = "This dictates how fast the map scrolls when pressing the arrow keys or moving your mouse to the edge of the screen",
    },
    options_keyboard_rotate_speed = {
        title = "Keyboard Rotation Speed",
        description = "This dictates how fast the map rotates",
    },
    options_keyboard_rotate_accelerate_multiplier = {
        title = "Accelerated Keyboard Rotate Speed Multiplier",
        description = "This multiplies the rotation speed of the camera when the ctrl key is held down",
    },
    options_lock_fullscreen_cursor_to_window = {
        title = "Lock Full Screen Cursor to Window",
        description = "This will prevent the cursor from going outside of the game window while in full screen mode",
    },
    options_kill_confirm = {
        title = "Confirm Unit Self-Destruction",
        description = "This will prompt you before issuing the self-destruction order",
    },
    options_render_skydome = {
        title = "Render Sky",
        description = "Toggles rendering of the sky when the camera is tilted (off = fastest)",
    },
    options_bloom_render = {
        title = "Bloom Render",
        description = "Toggles a glow type effect that is used on many weapon effects and some UI elements (off = fastest)",
    },
    options_use_mydocuments = {
        title = "Save Games and Replays in My Documents",
        description = "When on, changes the location where save games and replays get stored (My Documents\\My Games\\Supreme Commander Forged Alliance\\). Note that you will only see save games and replays in the active directory. Also, files saved to the alternate location will not be removed when the game is uninstalled.",
    },
    options_display_eta = {
        title = "Show Waypoint ETAs",
        description = "Toggles the display of ETA numbers when waypoint lines are visible",
    },
    options_show_attached_unit_lifebars = {
        title = "Show Lifebars of Attached Units",
        description = "Toggle the visibility of lifebars of on screen units (lifebars will still show in tooltip information)",
    },
    options_skin_change_on_start = {
        title = "Use Factional UI Skin",
        description = "When on, the UI skin will change to match the faction you are playing",
    },

    --**********************
    --** Lobby Strings
    --**********************
    Lobby_Advanced = {
        title = "Advanced Options",
        description = "Sets Advanced Options for this Map",
    },
    Lobby_Ready = {
        title = "Ready",
        description = "Click here when Ready to play",
    },
    Lobby_BuildRestrict_Option = {
        title = "Build Restrictions Enabled",
        description = "The host has enabled build restrictions. Be sure to check the restriction manager.",
    },
    Lobby_Mod_Option = {
        title = "Mods Enabled",
        description = "The host has enabled mods. Be sure to check the mod manager.",
    },
    Lobby_Mods = {
        title = "Mod Manager",
        description = "View, enable and disable all available Mods",
    },
    Lobby_Load = {
        title = "Load",
        description = "Load a previously saved skirmish game",
    },
    Lobby_Launch = {
        title = "Launch Game",
        description = "Launch the Game with the Current Settings",
    },
    Lobby_Launch_Waiting = {
        title = "Unable To Launch",
        description = "Waiting for all players to check the ready checkbox",
    },
    Lobby_Back = {
        title = "Back",
        description = "Go Back to the Main Menu",
    },
    Lobby_Add_AI = {
        title = "Add AI",
        description = "Click here to Add an AI Player",
    },
    Lobby_Del_AI = {
        title = "Delete AI",
        description = "Click here to Delete this AI Player",
    },
    Lobby_Kick = {
        title = "Kick",
        description = "Click here to Eject this Player from the Game",
    },
    Lobby_Team_Spawn = {
        title = "<LOC lobui_0088>",
        description = "<LOC lobui_0089>",
    },
    Lobby_Gen_ShareResources = {
        title = "Share Resources",
        description = "Determines whether Allies share Resources with each other",
    },
    Lobby_Gen_ShareUnits = {
        title = "Share Units",
        description = "Specifies how much control Teams have over each others Units",
    },
    Lobby_Gen_Deployment = {
        title = "Deployment",
        description = "Determines your Starting Forces",
    },
    Lobby_Gen_Victory = {
        title = "Victory Conditions",
        description = "<LOC lobui_0121>",
    },
    Lobby_Gen_Fog = {
        title = "Fog of War",
        description = "<LOC lobui_0113>",
    },
    Lobby_Gen_Cap = {
        title = "Unit Cap",
        description = "Set individual Army unit limit",
    },
    Lobby_Gen_CheatsEnabled = {
        title = "Cheating",
        description = "Enable or disable Cheats in the game",
    },
        Lobby_Gen_Timeouts = {
        title = "Timeouts",
        description = "Set number of Pauses each Player is allowed",
    },
        Lobby_Gen_GameSpeed = {
        title = "Game Speed",
        description = "Set how quickly the Game runs",
    },
    Lobby_Team_Lock = {
        title = "Teams",
        description = "<LOC lobui_0097>",
    },
        Lobby_Gen_Civilians = {
        title = "Civilians",
        description = "<LOC lobui_0280>Set civilian unit behavior",
    },
        Lob_CivilianAlliance_enemy = {
        title = "Enemy",
        description = "<LOC lobui_0281>Civilian units will attack",
    },
        Lob_CivilianAlliance_neutral = {
        title = "Neutral",
        description = "<LOC lobui_0282>Civilian units will ignore other factions",
    },
        Lob_CivilianAlliance_removed = {
        title = "Removed",
        description = "<LOC lobui_0283>No civilian units are present",
    },
    Lobby_NoRushOption = {
        title = "No Rush Option",
        description = "Set a time in which players may not expand past their initial starting area",
    },
    lob_NoRushOption_Off = {
        title = "No Time",
        description = "You may expand past your starting area immediately",
    },
    lob_NoRushOption_5 = {
        title = "5 Minutes",
        description = "You must stay in your starting area for 5 minutes",
    },
    lob_NoRushOption_10 = {
        title = "10 Minutes",
        description = "You must stay in your starting area for 10 minutes",
    },
    lob_NoRushOption_20 = {
        title = "20 Minutes",
        description = "You must stay in your starting area for 20 minutes",
    },
    Lobby_Gen_DisplayScores = {
        title = "Display Scores",
        description = "Turn the in game display of army scores on or off",
    },
    lob_DisplayScores_off = {
        title = "No Scores",
        description = "No scores will be displayed until the game is over",
    },
    lob_DisplayScores_on = {
        title = "Scores On",
        description = "The scores are displayed during gameplay",
    },
    Lobby_Prebuilt_Units = {
        title = "<LOC lobui_0310>Prebuilt Units",
        description = "<LOC lobui_0326>Each army will start with a basic prebuilt base",
        image = ""
    },
    lob_PrebuiltUnits_Off = {
        title = "<LOC lobui_0312>Off",
        description = "<LOC lobui_0327>No prebuilt base",
    },
    lob_PrebuiltUnits_On = {
        title = "<LOC lobui_0314>On",
        description = "<LOC lobui_0328>Prebuilt bases are on",
    },
    lob_slot = {
        title = "Player Slot",
        description = "Context sensitive menu which allows you to modify the player or AI for a given slot",
    },
    lob_color = {
        title = "Color",
        description = "Choose your Team Color",
    },
    lob_faction = {
        title = "Faction",
        description = "Choose your Team Faction",
    },
    lob_team = {
        title = "Team",
        description = "Players with the same Team will start off Allied with each other",
    },
    lob_select_map = {
        title = "Game Options",
        description = "Choose a map to play on and adjust game settings",
    },
    lob_cybran = {
        title = "<LOC _Cybran>",
        description = ''
    },
    lob_uef = {
        title = "<LOC _UEF>",
        description = ''
    },
    lob_seraphim = {
        title = "<LOC Illuminate>",
        description = ''
    },
    lob_random = {
        title = '<LOC lobui_0090>',
        description = '',
    },
    lob_team_none = {
        title = 'No Team',
        description = '',
    },
    lob_team_one = {
        title = 'Team 1',
        description = '',
    },
    lob_team_two = {
        title = 'Team 2',
        description = '',
    },
    lob_team_three = {
        title = 'Team 3',
        description = '',
    },
    lob_team_four = {
        title = 'Team 4',
        description = '',
    },
    lob_GameSpeed_normal = {
        title = '<LOC lobui_0260>',
        description = '<LOC lobui_0261>',
    },
    lob_GameSpeed_fast = {
        title = '<LOC lobui_0262>',
        description = '<LOC lobui_0263>',
    },
    lob_GameSpeed_adjustable = {
        title = '<LOC lobui_0264>',
        description = '<LOC lobui_0265>',
    },
    lob_UnitCap_100 = {
        title = '<LOC lobui_0168>',
        description = '<LOC lobui_0169>',
    },
    lob_UnitCap_250 = {
        title = '<LOC lobui_0170>',
        description = '<LOC lobui_0171>',
    },
    lob_UnitCap_500 = {
        title = '<LOC lobui_0172>',
        description = '<LOC lobui_0173>',
    },
    lob_UnitCap_750 = {
        title = '<LOC lobui_0174>',
        description = '<LOC lobui_0175>',
    },
    lob_UnitCap_1000 = {
        title = '<LOC lobui_0235>',
        description = '<LOC lobui_0236>',
    },
    lob_FogOfWar_explored = {
        title = '<LOC lobui_0114>',
        description = '<LOC lobui_0115>',
    },
    lob_FogOfWar_unexplored = {
        title = '<LOC lobui_0116>',
        description = '<LOC lobui_0117>',
    },
    lob_FogOfWar_none = {
        title = '<LOC lobui_0118>',
        description = '<LOC lobui_0119>',
    },
    lob_Victory_demoralization = {
        title = '<LOC lobui_0122>',
        description = '<LOC lobui_0123>',
    },
    lob_Victory_domination = {
        title = '<LOC lobui_0124>',
        description = '<LOC lobui_0125>',
    },
    lob_Victory_eradication = {
        title = '<LOC lobui_0126>',
        description = '<LOC lobui_0127>',
    },
    lob_Victory_sandbox = {
        title = '<LOC lobui_0128>',
        description = '<LOC lobui_0129>',
    },
    lob_Timeouts_0 = {
        title = '<LOC lobui_0244>',
        description = '<LOC lobui_0245>',
    },
    lob_Timeouts_3 = {
        title = '<LOC lobui_0246>',
        description = '<LOC lobui_0247>',
    },
    ['lob_Timeouts_-1'] = {
        title = '<LOC lobui_0248>',
        description = '<LOC lobui_0249>',
    },
    ['Give Units'] = {
        title = '<LOC tooltips_0000>Give Units',
        description = '',
    },
    ['Give Resources'] = {
        title = '<LOC tooltips_0001>Give Resources',
        description = '',
    },
    lob_CheatsEnabled_false = {
        title = '<LOC _Off>',
        description = '<LOC lobui_0210>',
    },
    lob_CheatsEnabled_true = {
        title = '<LOC _On>',
        description = '<LOC lobui_0211>',
    },
    lob_TeamSpawn_random = {
        title = '<LOC lobui_0090>',
        description = '<LOC lobui_0091>',
    },
    lob_TeamSpawn_fixed = {
        title = '<LOC lobui_0092>',
        description = '<LOC lobui_0093>',
    },
    lob_TeamLock_locked = {
        title = '<LOC lobui_0098>',
        description = '<LOC lobui_0099>',
    },
    lob_TeamLock_unlocked = {
        title = '<LOC lobui_0100>',
        description = '<LOC lobui_0101>',
    },
    lob_describe_observers = {
        title = "<LOC lobui_0284>Observers",
        description = "<LOC lobui_0285>Observers are clients connected to the lobby who will not participate directly in gameplay. Right click an observers name to remove an observer from the lobby.",
    },
    lob_observers_allowed = {
        title = "<LOC lobui_0286>Allow Observers",
        description = "<LOC lobui_0287>If checked, participants can join the game as an impartial observer (Unchecking this option will boot potential observers from the lobby)",
    },
    lob_become_observer = {
        title = "<LOC lobui_0288>Become Observer",
        description = "<LOC lobui_0289>When clicked, a player will become an observer",
    },
    lob_CivilianAlliance_enemy = {
        title = "<LOC lobui_0293>",
        description = "<LOC lobui_0294>",
    },
    lob_CivilianAlliance_neutral = {
        title = "<LOC lobui_0295>",
        description = "<LOC lobui_0296>",
    },
    lob_CivilianAlliance_removed = {
        title = "<LOC lobui_0297>",
        description = "<LOC lobui_0298>",
    },
    lob_RestrictedUnits = {
        title = "<LOC lobui_0332>Unit Manager",
        description = "<LOC lobui_0333>View and set unit restrictions for this game (The AI may behave unexpectedly with these options set)",
    },
    lob_RestrictedUnitsClient = {
        title = "<LOC lobui_0337>Unit Manager",
        description = "<LOC lobui_0338>View what units are allowed to be played in game",
    },

    --**********************
    --** Profile Strings
    --**********************
    Profile_name = {
        title = "Name",
        description = "The Name of this Profile",
    },
    Profile_create = {
        title = "Create",
        description = "Generate a New Profile",
    },
    Profile_cancel = {
        title = "Cancel",
        description = "Exit this screen without changing Profiles",
    },
    Profile_delete = {
        title = "Delete",
        description = "Delete the Selected Profile",
    },
    Profile_ok = {
        title = "Ok",
        description = "Continue with the Selected Profile",
    },
    Profile_profilelist = {
        title = "Profile List",
        description = "All saved Profiles",
    },

    --**********************
    --** Options Strings
    --**********************
    exit_menu = {
        title = "Menu",
        description = "Opens the Game Menu",
        keyID = "toggle_main_menu",
    },
    objectives = {
        title = "Objectives",
        description = "Shows all current and completed Objectives",
        keyID = "toggle_objective_screen",
    },
    map_info = {
        title = "<LOC sel_map_0000>",
        description = "",
        keyID = "toggle_objective_screen",
    },
    inbox = {
        title = "Transmission Log",
        description = "Replay any Received Transmissions",
        keyID = "toggle_transmission_screen",
    },
    score = {
        title = "Score",
        description = "Shows the Score, -- of Units, and Elapsed Time",
        keyID = "toggle_score_screen",
    },
    diplomacy = {
        title = "Diplomacy",
        description = "Access all Diplomacy Options",
        keyID = "toggle_diplomacy_screen",
    },
    options_Pause = {
        title = "Pause",
        description = "",
        --description = "Pause Supreme Commander: Forged Alliance",
    },
    options_Play = {
        title = "Play",
        description = "",
        --description = "Resume Supreme Commander: Forged Alliance",
    },

    --**********************
    --** Construction Manager
    --**********************
    construction_tab_t1 = {
        title = "Tech 1",
        description = "",
    },
    construction_tab_t1_dis = {
        title = "Tech 1",
        description = "Unit's tech level is insufficient. Unable to access this technology.",
    },
    construction_tab_t2 = {
        title = "Tech 2",
        description = "",
    },
    construction_tab_t2_dis = {
        title = "Tech 2",
        description = "Unit's tech level is insufficient. Unable to access this technology.",
    },
    construction_tab_t3 = {
        title = "Tech 3",
        description = "",
    },
    construction_tab_t3_dis = {
        title = "Tech 3",
        description = "Unit's tech level is insufficient. Unable to access this technology.",
    },
    construction_tab_t4 = {
        title = "Experimental Tech",
        description = "",
    },
    construction_tab_t4_dis = {
        title = "Experimental Tech",
        description = "Unit's tech level is insufficient. Unable to access this technology.",
    },
    construction_tab_selection = {
        title = "Selected Units",
        description = "",
    },
    construction_tab_construction = {
        title = "Construction",
        description = "Allows you to build new units with the selected units",
    },
    construction_tab_construction_dis = {
        title = "Construction",
        description = "The selected units can't build other units",
    },
    construction_tab_enhancement = {
        title = "RESEARCH",
        description = "Research new technologies to improve your army.",
    },
    construction_tab_enhancment_dis = {
        title = "Enhancements",
        description = "No enhancements available for the selected units",
    },
    construction_tab_enhancment_left = {
        title = "Customize [Left Arm]",
        description = "",
    },
    construction_tab_enhancment_back = {
        title = "Customize [Back]",
        description = "",
    },
    construction_tab_enhancment_right = {
        title = "Customize [Right Arm]",
        description = "",
    },
    construction_tab_enhancment_off = {
        title = "OFFENSE",
        description = "Research technologies to enhance your offensive capabilities.",
    },
    construction_tab_enhancment_def = {
        title = "DEFENSE",
        description = "Research technologies to enhance your defensive capabilities.",
    },
    construction_tab_enhancment_int = {
        title = "INTEL",
        description = "Research technologies to enhance your intel gathering and sabotage capabilities.",
    },
    construction_tab_enhancment_sup = {
        title = "SUPPORT",
        description = "Research technologies to enhance your support capabilities.",
    },
    construction_tab_attached = {
        title = "Selection and Storage",
        description = "Displays selected and stored or attached units",
    },
    construction_tab_attached_dis = {
        title = "Selection and Storage",
        description = "The selected unit(s) do not have any units attached to them",
    },
    construction_tab_templates = {
        title = "Build Templates",
        description = "Display the build templates manager",
    },
    construction_tab_templates_dis = {
        title = "Build Templates (no templates)",
        description = "Display the build templates manager",
    },
    construction_infinite = {
        title = "Infinite Build",
        description = "Toggle the infinite construction of the current queue",
    },
    construction_pause = {
        title = "Pause Construction",
        description = "[Pause/Unpause] the current construction order",
    },


    --**********************
    --** In Game Replay Manager
    --**********************
    esc_return = {
        title = "Return to Game",
        description = "Closes the menu and returns you to the current game",
    },
    esc_save = {
        title = "Save Menu",
        description = "Save your Current Game",
    },
    esc_resume = {
        title = "Resume",
        description = "Continue your Current Game",
    },
    esc_quit = {
        title = "Surrender",
        description = "Exit to the Main Menu",
    },
    esc_restart = {
        title = "Restart",
        description = "Begin this Game again",
    },
    esc_exit = {
        title = "Exit",
        description = "Close Supreme Commander: Forged Alliance",
    },
    esc_options = {
        title = "Options Menu",
        description = "Adjust Gameplay, Video and Sound Options",
    },
    esc_conn = {
        title = "Connectivity Menu",
        description = "Adjust Connectivity Options",
    },
    esc_load = {
        title = "Load",
        description = "Continue a Previously Saved Game",
    },

    --**********************
    --** In Game Replay Manager
    --**********************
    replay_pause = {
        title = "Pause",
        description = "Pause or Resume the Replay",
    },
    replay_speed = {
        title = "Game Speed",
        description = "Sets the Replay Speed",
    },
    replay_team = {
        title = "Team Focus",
        description = "Select which Army to focus on",
    },
    replay_progress = {
        title = "Progress",
        description = "Indicates your Position in the Replay",
    },
    replay_restart = {
        title = "Restart",
        description = "Plays the Current Replay from the Beginning",
    },

    --**********************
    --** Post Game Score Screen
    --**********************
    PostScore_campaign = {
        title = "Campaign",
        description = "Shows the Campaign Debriefing and Objectives",
    },
    PostScore_Grid = {
        title = "Players",
        description = "Shows the Players and Scores",
    },
    PostScore_Graph = {
        title = "Graph",
        description = "Shows a Timeline of the Game",
    },
    PostScore_general = {
        title = "General",
        description = "Shows the Overall Performance of each Player",
    },
    PostScore_units = {
        title = "Units",
        description = "Shows the Performance of each Players Military",
    },
    PostScore_resources = {
        title = "Resources",
        description = "Show the Efficiency of each Players Economy",
    },
    PostScore_Player = {
        title = "Player",
        description = "Sort by Player Name",
    },
    PostScore_Team = {
        title = "Team",
        description = "Sort by Team",
    },
    PostScore_score = {
        title = "Score",
        description = "Sort by Overall Performance",
    },
    PostScore_kills = {
        title = "Kills",
        description = "Sort by Units Destroyed",
    },
    PostScore_built = {
        title = "Built",
        description = "Sort by Structures Built",
    },
    PostScore_lost = {
        title = "Losses",
        description = "Sort by Units Lost",
    },
    PostScore_cdr = {
        title = "Command Units",
        description = "Sort by Command Units",
    },
    PostScore_land = {
        title = "Land Units",
        description = "Sort by Land Units",
    },
    PostScore_naval = {
        title = "Naval",
        description = "Sort by Naval Units",
    },
    PostScore_air = {
        title = "Air",
        description = "Sort by Air Units",
    },
    PostScore_structures = {
        title = "Structures",
        description = "Sort by Structures",
    },
    PostScore_experimental = {
        title = "Experimental",
        description = "Sort by Experimental Units",
    },
    PostScore_massin = {
        title = "Mass Collected",
        description = "Sort by Mass Collected",
    },
    PostScore_massover = {
        title = "Mass Wasted",
        description = "Sort by Mass Wasted",
    },
    PostScore_massout = {
        title = "Mass Spent",
        description = "Sort by Mass Spent",
    },
    PostScore_energyin = {
        title = "Energy Collected",
        description = "Sort by Energy Collected",
    },
    PostScore_energyout = {
        title = "Energy Spent",
        description = "Sort by Energy Spent",
    },
    PostScore_energyover = {
        title = "Energy Wasted",
        description = "Sort by Energy Wasted",
    },
    PostScore_total = {
        title = "Total",
        description = "Sort by Totals",
    },
    PostScore_rate = {
        title = "Rate",
        description = "Sort by Rates",
    },
    PostScore_kills = {
        title = "Kills",
        description = "Sort by Kills",
    },
    PostScore_built = {
        title = "Built",
        description = "Sort by Units Built",
    },
    PostScore_lost = {
        title = "Losses",
        description = "Sort by Units Lost",
    },
    PostScore_count = {
        title = "Count",
        description = "Sort by Total Units Built",
    },
    PostScore_mass = {
        title = "Mass",
        description = "Sort by Total Mass Collected",
    },
    PostScore_energy = {
        title = "Energy",
        description = "Sort by Total Energy Collected",
    },
    PostScore_Replay = {
        title = "Replay",
        description = "Save the Replay of this Match",
    },
    PostScore_Quit = {
        title = "Continue",
        description = "Exit the Score Screen",
    },

    --**********************
    --** Campaign Score
    --**********************

    CampaignScore_Skip = {
        title = "Skip",
        description = "Skip this operation and continue to the next",
    },
    CampaignScore_Restart = {
        title = "Restart",
        description = "Restart this Operation from the beginning",
    },

    --**********************
    --** MFD Strings
    --**********************
    mfd_military = {
        title = "Strategic Overlay Toggle",
        description = "View weapon and intelligence ranges",
        keyID = "tog_military",
    },
    mfd_military_dropout = {
        title = "Strategic Overlay Menu",
        description = "Select the ranges to display for the Strategic Overlay Toggle",
    },
    mfd_defense = {
        title = "Player Colors",
        description = "Toggle unit coloring between player and allegiance colors:\nYour Units\nAllied Units\nNeutral Units\nEnemy Units",
        keyID = "tog_defense",
    },
    mfd_economy = {
        title = "Economy Overlay",
        description = "Toggle income and expense overlays over units",
        keyID = "tog_econ",
    },
    mfd_intel = {
        title = "Intel",
        description = "Toggle the Intelligence Overlay. This shows the ranges of your intelligence and counter-intelligence structures",
        keyID = "tog_intel",
    },
    mfd_control = {
        title = "Control",
        description = "Toggle the Control Overlay",
    },
    mfd_idle_engineer = {
        title = "Idle Engineers",
        description = "Select Idle Engineers",
    },
    mfd_idle_factory = {
        title = "Idle Factories",
        description = "Select Idle Factories",
    },
    mfd_army = {
        title = "Land",
        description = "Target all Land Forces",
    },
    mfd_airforce = {
        title = "Air",
        description = "Target all Air Forces",
    },
    mfd_navy = {
        title = "Navy",
        description = "Target all Naval Forces",
    },
    mfd_strat_view = {
        title = "Map Options",
        description = "Adjust different viewport and map display options",
    },
    mfd_attack_ping = {
        title = "Attack Signal",
        description = "Place an allied attack request at a specific location",
        keyID = "ping_attack",
    },
    mfd_alert_ping = {
        title = "Assist Signal",
        description = "Place an allied assist request at a specific location",
        keyID = "ping_alert",
    },
    mfd_move_ping = {
        title = "Move Signal",
        description = "Request your allies move to a location",
        keyID = "ping_move",
    },
    mfd_marker_ping = {
        title = "Message Marker",
        description = "Place a message marker on the map (Shift + Control + right-click to delete)",
        keyID = "ping_marker",
    },

    --**********************
    --** Misc Strings
    --**********************
    infinite_toggle = {
        title = "Infinite Build",
        description = "Toggle infinite construction on/off for current build queue",
    },
    mass_button = {
        title = "Mass",
        description = "Mass is the basic building blocks of any unit or structure in the game",
    },
    energy_button = {
        title = "Energy",
        description = "Energy represents the effort required to build units and structures",
    },
    dip_send_alliance = {
        title = "Send Alliance Offer",
        description = "Check this box to send an Alliance Offer to this Player",
    },
    dip_share_resources = {
        title = "Share Resources",
        description = "Toggle the distribution of excess mass and energy to your allies",
    },
    dip_allied_victory = {
        title = "Allied Victory",
        description = "Toggle between individual or team victory/defeat conditions",
    },
    dip_give_resources = {
        title = "Give Resources",
        description = "Send Mass and/or Energy from storage to specified player",
    },
    dip_offer_draw = {
        title = "Propose Draw",
        description = "Propose ending the game in a draw.  All players must click this to accept.",
    },
    dip_give_units = {
        title = "Give Units",
        description = "Give currently selected units to specified player",
    },
    dip_break_alliance = {
        title = "Break Alliance",
        description = "Cancel the alliance with specified player",
    },
    dip_offer_alliance = {
        title = "Propose Alliance",
        description = "Offer an alliance to specified player",
    },
    dip_accept_alliance = {
        title = "Accept Alliance",
        description = "Specified player has offered an alliance to you",
    },
    dip_alliance_proposed = {
        title = "Alliance Proposed",
        description = "You have proposed an alliance to specified player",
    },

    score_time = {
        title = "Game Time",
        description = "",
    },
    score_units = {
        title = "Unit Count",
        description = "Current and maximum unit counts",
    },
    score_collapse = {
        title = "[Hide/Show] Score Bar",
        description = "",
        keyID = "toggle_score_screen",
    },
    econ_collapse = {
        title = "[Hide/Show] Resource Bar",
        description = "",
    },
    control_collapse = {
        title = "[Hide/Show] Control Group Bar",
        description = "",
    },
    mfd_collapse = {
        title = "[Hide/Show] Multifunction Bar",
        description = "",
    },
    objectives_collapse = {
        title = "[Hide/Show] Objectives Bar",
        description = "",
        keyID = "toggle_score_screen",
    },
    menu_collapse = {
        title = "[Hide/Show] Menu Bar",
        description = "",
    },
    avatars_collapse = {
        title = "[Hide/Show] Avatars Bar",
        description = "",
    },

    --**********************
    --** Front End Strings
    --**********************
    mainmenu_exit = {
        title = "Exit Game",
        description = "Close Supreme Commander: Forged Alliance",
    },
    mainmenu_campaign = {
        title = "Campaign",
        description = "Start a new campaign or continue a previous one",
    },
    mainmenu_mp = {
        title = "Multiplayer",
        description = "Join or host a multiplayer game",
    },
    mainmenu_skirmish = {
        title = "Skirmish Mode",
        description = "Play a quick game against one or more AI Opponents",
    },
    mainmenu_replay = {
        title = "Replay",
        description = "List and play any available replays",
    },
    mainmenu_options = {
        title = "Options",
        description = "View and adjust Gameplay, Interface, Video, and Sound options",
    },
    mainmenu_mod = {
        title = "Mod Manager",
        description = "View, enable and disable all available Mods",
    },
    mainmenu_tutorial = {
        title = "Tutorial",
        description = "Learn to play Supreme Commander: Forged Alliance",
    },
    mainmenu_extras = {
    	title = "Extras",
    	description = "Access additional SupCom content and functionality",
    },
    profile = {
        title = "Profile",
        description = "Manage your Profiles",
    },
    mpselect_observe = {
        title = "Observe",
        description = "Watch a Game being played",
    },
    mpselect_join = {
        title = "Join",
        description = "Play on the Selected Server",
    },
	mpselect_lan = {
        title = "LAN",
        description = "Host, Join or Observe a LAN Game",
    },
    mpselect_connect = {
        title = "Direct Connect",
        description = "Join a Game by supplying the IP Address and Port",
    },
    mpselect_create = {
        title = "Create Game",
        description = "Host a new LAN Game",
    },
    mpselect_exit = {
        title = "Back",
        description = "",
    },
    mpselect_serverinfo = {
        title = "Server Information",
        description = "Displays the Status of the Currently Selected Server",
    },
    mpselect_serverlist = {
        title = "Server List",
        description = "Displays available LAN Games",
    },
    mpselect_name = {
        title = "Name",
        description = "Sets your Multiplayer Nickname",
    },
    mainmenu_quickcampaign = {
        title = "Quick Campaign",
        description = "Launches the most recent saved campaign",
    },
    mainmenu_quicklanhost = {
        title = "Quick LAN",
        description = "Launches a LAN lobby with your last settings",
    },
    mainmenu_quickipconnect = {
        title = "Direct Connect",
        description = "Direct connect to another computer using an IP address and port value",
    },
    mainmenu_quickskirmishload = {
        title = "Quick Skirmish Load",
        description = "Loads the last saved skirmish game",
    },
    mainmenu_quickreplay = {
        title = "Quick Replay",
        description = "Loads and plays the last saved replay",
    },
    modman_controlled_by_host = {
        title = "<LOC uimod_0007>Gameplay mod",
        description = "<LOC uimod_0008>This mod can only be selected by the game host",
        image = ""
    },
    modman_some_missing = {
        title = "<LOC uimod_0007>Gameplay mod",
        description = "<LOC uimod_0009>Not all players have this mod",
        image = ""
    },
    campaignselect_continue = {
        title = "Continue",
        description = "Play the latest Operation in this factions Campaign",
        image = ""
    },
    campaignselect_replay = {
        title = "Replay Op",
        description = "Replay this Operation",
        image = ''
    },
    campaignselect_fmv = {
        title = "Playback",
        description = "Watch this video then return to this screen",
        image = ''
    },
    campaignselect_select = {
        title = "Select",
        description = "Select this operation and enter the briefing room",
        image = ''
    },
    campaignselect_movie = {
        title = "Play Movie",
        description = "Watch the selected movie",
        image = ''
    },
    campaignselect_tutorial = {
        title = "Play Tutorial",
        description = "",
        image = ''
    },
    campaignselect_restart = {
        title = "Restart",
        description = "Restart the [Campaign/Skirmish] game",
        image = ''
    },
    campaignselect_load = {
        title = "Load",
        description = "Load a previously saved campaign game",
    },

    --**********************
    --** Campaign briefing
    --**********************
    campaignbriefing_restart = {
        title = "Restart",
        description = "Start the briefing from the beginning",
    },
    campaignbriefing_pause = {
        title = "Pause",
        description = "Pause the briefing",
    },
    campaignbriefing_skip = {
        title = "Skip",
        description = "Skip to the end of the briefing",
    },
    campaignbriefing_play = {
        title = "Play",
        description = "Continue playing the briefing",
    },
    campaignbriefing_launch = {
        title = "Launch",
        description = "Start the operation",
    },


    --**********************
    --** Restricted Units
    --**********************
    restricted_units_proto = {
        title = "SC2 Prototyping",
        description = "You're limited to whatever it is we want you to build, yo.",
    },
    restricted_uints_T1 = {
        title = "No Tech 1",
        description = "Players will not be able to build tech 1 units",
    },
    restricted_uints_T2 = {
        title = "No Tech 2",
        description = "Players will not be able to build tech 2 units",
    },
    restricted_uints_T3 = {
        title = "No Tech 3",
        description = "Players will not be able to build tech 3 units",
    },
    restricted_uints_experimental = {
        title = "No Experimental",
        description = "Players will not be able to build experimental units",
    },
    restricted_uints_naval = {
        title = "No Naval",
        description = "Players will not be able to build mobile naval units",
    },
    restricted_uints_air = {
        title = "No Air",
        description = "Players will not be able to build mobile air units",
    },
    restricted_uints_land = {
        title = "No Land",
        description = "Players will not be able to build mobile land units",
    },
    restricted_uints_uef = {
        title = "No UEF",
        description = "Players will not be able to build UEF units",
    },
    restricted_uints_cybran = {
        title = "No Cybran",
        description = "Players will not be able to build Cybran units",
    },
    restricted_uints_aeon = {
        title = "No Aeon",
        description = "Players will not be able to build Aeon units",
    },
    restricted_uints_seraphim = {
        title = "No Seraphim",
        description = "Players will not be able to build Seraphim units",
    },
    restricted_uints_nukes = {
        title = "No Nukes",
        description = "Players will not be able to build Tech 3 strategic missile launchers ",
    },
    restricted_uints_gameenders = {
        title = "No Game Enders",
        description = "Players will not be able to build Tech 3 strategic missile launchers and artillery",
    },
    restricted_uints_bubbles = {
        title = "No Bubbles",
        description = "Players will not be able to build mobile shield generators and shield defenses",
    },
    restricted_uints_intel = {
        title = "No Intel Structures",
        description = "Players will not be able to build radar, sonar and omni installations",
    },
    restricted_uints_supcom = {
        title = "No Support Commanders",
        description = "Players will not be able to build support commanders",
    },
    restricted_units_supremecommander = {
        title = "No Supreme Commander",
        description = "Players will not be able to build Supreme Commander units"
    },
    restricted_units_forgedalliance = {
        title = "No Forged Alliance",
        description = "Players will not be able to build Forged Alliance units"
    },
    restricted_units_downloaded = {
        title = "No Downloaded",
        description = "Players will not be able to build downloaded GPG units"
    },
    restricted_units_massfab = {
        title = "No Fabrication",
        description = "Players will not be able to build mass fabricators"
    },

    --**********************
    --** Strategic overlay
    --**********************
    overlay_conditions = {
        title = "Conditional Overlays",
        description = "Toggle all conditional overlays",
    },
    overlay_rollover = {
        title = "Rollover Range Overlay",
        description = "Toggle the range overlay of the unit you are mousing over",
    },
    overlay_selection = {
        title = "Selection Range Overlay",
        description = "Toggle the range overlay of the unit(s) you have selected",
    },
    overlay_build_preview = {
        title = "Build Preview",
        description = "Toggle the range overlay of the unit you are about to build",
    },
    overlay_military = {
        title = "Military Overlays",
        description = "Toggle all military overlays ",
    },
    overlay_direct_fire = {
        title = "Direct Fire",
        description = "Toggle the range overlays of your point defenses, tanks and other direct-fire weaponry ",
    },
    overlay_indirect_fire = {
        title = "Indirect Fire",
        description = "Toggle the range overlays of your artillery and missile weaponry",
    },
    overlay_anti_air = {
        title = "Anti-Air",
        description = "Toggle the range overlays of your AA weaponry",
    },
    overlay_anti_navy = {
        title = "Anti-Navy",
        description = "Toggle the range overlays of your torpedo weaponry",
    },
    overlay_defenses = {
        title = "Countermeasure",
        description = "Toggle the range overlays of your shields and other countermeasure defenses",
    },
    overlay_misc = {
        title = "Miscellaneous",
        description = "Toggle the range overlays of your air staging platforms and engineering stations",
    },
    overlay_combine_military = {
        title = "Combine Military",
        description = "Combine all sub-filters into a single overlay",
    },
    overlay_intel = {
        title = "Intelligence Overlays",
        description = "Toggle all intelligence overlays ",
    },
    overlay_radar = {
        title = "Radar",
        description = "Toggle the range overlays of your radar",
    },
    overlay_sonar = {
        title = "Sonar",
        description = "Toggle the range overlays of your sonar",
    },
    overlay_omni = {
        title = "Omni",
        description = "Toggle the range overlays of your Omni sensors",
    },
    overlay_counter_intel = {
        title = "Counter-Intelligence",
        description = "Toggle the range overlays of your stealth and jamming equipment",
    },
    overlay_combine_intel = {
        title = "Combine Intelligence",
        description = "Combine all sub-filters into a single overlay",
    },

    --**********************
    --** Faction select
    --**********************
    faction_select_uef = {
        title = "UEF",
        description = "Play campaign as a UEF Commander",
    },
    faction_select_cybran = {
        title = "Cybran",
        description = "Play campaign as a Cybran Commander",
    },
    faction_select_aeon = {
        title = "Aeon",
        description = "Play campaign as an Aeon Commander",
    },

    --**********************
    --** Misc
    --**********************
    minimap_reset = {
        title = "Reset Minimap",
        description = "Sets the minimap to its default position and size",
    },
    no_rush_clock = {
        title = "No Rush Clock",
        description = "Displays time remaining in the no rush clock",
    },
    save_template = {
        title = "Save Template",
        description = "Creates construction template by saving units/structures and their position",
    },

    --**********************
    --** Misc
    --**********************
    jump = {
        title = "Jump",
        description = "",
        keyID = "jump",
    },
    shunt = {
        title = "Shunt",
        description = "",
        keyID = "shunt",
    },
}
