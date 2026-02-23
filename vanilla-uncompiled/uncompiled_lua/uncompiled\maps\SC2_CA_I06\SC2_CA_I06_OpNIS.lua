---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_I06/SC2_CA_I06_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_I06/SC2_CA_I06_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_I06/SC2_CA_I06_script.lua')
local NIS				= import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua')
local GetPos			= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetPos
local GetOrient			= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetOrient
local SkipOpeningNIS	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').SkipOpeningNIS
local SkipMidOpNIS		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').SkipMidOpNIS

---------------------------------------------------------------------
-- NIS_OPENING:
---------------------------------------------------------------------
function NIS_OPENING()
	-- set ending camera zoom
	local nOverrideZoom	= 150.0

	if ScenarioInfo.Options.NoNIS then
		-- skip away
		SkipOpeningNIS(
			function()
				func_OPENING_PlayerTransportSequence(true)
				---NOTE: this is a potential solution to inconsistent flight durations - if this is not deemed appropriate we will need to
				---			consider fake ACUs for the NIS - bfricks 10/28/09
				while not ScenarioInfo.CDR_LANDED do
					WARN('WARNING: NIS paused due to CDR not being in position for scripted commands - if this spams, pass to campaign design.')
					WaitTicks(1)
				end
				func_OPENING_CreateNukeTransports(true)
				func_OPENING_WarpAndMoveACUS(true)
				func_OPENING_TransportsBoogie(true)
				func_OPENING_Nukes(true)
				func_OPENING_CleanupACUs(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('I06_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.I06_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.I06_NIS_OP_SETUP_020)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	---NOTE: speak to me before adjusting any of these - bfricks 12/6/09
	NIS.CreateVizMarker('NIS_TRANSPORT_VIZ', 100)
	NIS.CreateVizMarker('P1_ALLY01_Main_Base_Marker', 120)
	NIS.CreateVizMarker('P1_UEF01_Main_Base_Marker', 30)
	NIS.CreateVizMarker('P1_ILLUM01_Main_Base_Marker', 80)
	NIS.CreateVizMarker('P1_CYBRAN01_Main_Base_Marker', 80)
	NIS.CreateVizMarker('TEMP_NUKE_OBJECT_01', 50)
	NIS.CreateVizMarker('TEMP_NUKE_OBJECT_03', 50)
	NIS.CreateVizMarker('TEMP_NUKE_OBJECT_04', 70)

	NIS.PreloadDialogData(
		{
			OpDialog.I06_NIS_OPENING_010,
			OpDialog.I06_NIS_OPENING_015,
			OpDialog.I06_NIS_OPENING_020,
			OpDialog.I06_NIS_OPENING_022,
			OpDialog.I06_NIS_OPENING_023,
			OpDialog.I06_NIS_OPENING_024,
			OpDialog.I06_NIS_OPENING_025,
			OpDialog.I06_NIS_OPENING_030,
			OpDialog.I06_NIS_OPENING_035,
			OpDialog.I06_NIS_OPENING_040,
			OpDialog.I06_NIS_OPENING_050,
			OpDialog.I06_NIS_OPENING_052,
			OpDialog.I06_NIS_OPENING_055,
			OpDialog.I06_NIS_OPENING_060,
			OpDialog.I06_NIS_OP_SETUP_010,
			OpDialog.I06_NIS_OP_SETUP_020,
		}
	)

	-- spawn transports loaded with the CDR and the player starting units
	func_OPENING_PlayerTransportSequence()

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('I06_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS_OPENING_01', 0.0, 'NIS_OPENING_01', 80.0)

	func_OPENING_CreateNukeTransports()

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	ForkThread(
		function()
			-- while dialog begins, use the starting shot and zoom in to a tracking shot
			NIS.ZoomTo(GetPos('NIS_OPENING_02'), GetOrient('NIS_OPENING_02'), 150.0, 10.0)
		end
	)
	WaitSeconds(4.0)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_010) -- approaching commander (6.1)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ILLUM_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 200.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_015) --Illuminate ACU, 2.2 sec

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.CYBRAN_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_020) --Cybran ACUs, 2.5 sec

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_OPENING_03'), GetOrient('NIS_OPENING_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_OPENING_03'), GetOrient('NIS_OPENING_03'), 10.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_022) --Maddox, 1.5 sec

	WaitSeconds(1.0)

	func_OPENING_WarpAndMoveACUS()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.INTRONIS_CommanderTransport), GetOrient('NIS_TRANSPORT_ARRIVAL_01'), 50.0, 0.0)
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('NIS_TRANSPORT_ARRIVAL_02'), 50.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_023) --Thalia transport arrival (4.5)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 12.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.10,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_024) --Thalia chat (4.2)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_OPN_CAM_H_01'), GetOrient('NIS_OPN_CAM_H_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_OPN_CAM_H_01'), GetOrient('NIS_OPN_CAM_H_01'), 30.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_025) --Gate thing (3.1)

	WaitSeconds(1.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_STANDOFF_01'), GetOrient('NIS_STANDOFF_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_STANDOFF_02'), GetOrient('NIS_STANDOFF_02'), 0.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_030) --2.3 Illum: Kael is a Traitor!

	WaitSeconds(1.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_STANDOFF_03'), GetOrient('NIS_STANDOFF_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_STANDOFF_04'), GetOrient('NIS_STANDOFF_04'), 0.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_035) --2.3 Cybran: Stand down!

	WaitSeconds(1.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_OPENING_03'), GetOrient('NIS_OPENING_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_OPENING_03'), GetOrient('NIS_OPENING_03'), 100.0, 14.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_040) -- Maddox: Calm down (7.3)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_OPENING_NukeLaunch')

	NIS.Dialog(OpDialog.I06_NIS_OPENING_050) -- Nukes! (2)

	func_OPENING_TransportsBoogie()

	ForkThread(func_OPENING_Nukes)

	NIS.Dialog(OpDialog.I06_NIS_OPENING_052) -- Nukes! (5.3)

	WaitSeconds(4.0)

	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 12.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.10,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			NIS.SetZoom(7.0, 0.5)
		end
	)
	WaitSeconds(1.0)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_055) -- Gauge is here (1 sec)

	WaitSeconds(2.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_ACUS_BAILING_01'), GetOrient('NIS_ACUS_BAILING_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_ACUS_BAILING_02'), GetOrient('NIS_ACUS_BAILING_02'), 0.0, 6.5)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_OPENING_060) -- Everyone bails, 5.7

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_OPENING_End')

	NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('NIS_OPENING_03'), 150.0, 0.0)

	--Put ACUs back in their base
	func_OPENING_CleanupACUs()

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.I06_NIS_OP_SETUP_010)
	NIS.DialogNoWait(OpDialog.I06_NIS_OP_SETUP_020)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_UEF_CDR_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.I06_M1_obj10_UPDATE_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_UEF_CDR_DEATH_Start')

	NIS.CreateVizMarker(GetPos(deathUnit), 300)

	NIS.StartNIS_Standard()

	-- kill the unit
	local deadEnt = NIS.UnitDeathToEnt(deathUnit)

	-- anything else specific to this CDR - including a dialog call
	-- Final VO timing: 2.3 seconds
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= deadEnt,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 35.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 35.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.01,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 300.0,		-- how close to spin relative to the unit
					nSpinDuration		= 6.0,			-- how long to allow the spin to persist
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 1.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I06_M1_obj10_UPDATE_010)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_UEF_CDR_DEATH_End')

	func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)
end

---------------------------------------------------------------------

function NIS_CYBRAN_CDR_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.I06_M1_obj10_UPDATE_020,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_CYBRAN_CDR_DEATH_Start')

	NIS.CreateVizMarker(GetPos(deathUnit), 300)

	NIS.StartNIS_Standard()

	-- get a generic entitry to spin around
	local ent = NIS.UnitToEnt(deathUnit)

	-- anything else specific to this CDR - including a dialog call
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= ent,			-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 35.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 65.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.001,		-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 250.0,		-- how close to spin relative to the unit
					nSpinDuration		= 10.0,			-- how long to allow the spin to persist
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 0.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	-- Destroy the commander
	ForkThread(
		function()
			WaitSeconds(1.8)
			NIS.ForceUnitDeath(deathUnit)
		end
	)
	NIS.Dialog(OpDialog.I06_M1_obj10_UPDATE_020)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_CYBRAN_CDR_DEATH_End')

	func_VICTORY_CheckForVictory(ent, numCDRDeaths)
end

---------------------------------------------------------------------

function NIS_ILLUM_CDR_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.I06_M1_obj10_UPDATE_030,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_ILLUM_CDR_DEATH_Start')

	NIS.CreateVizMarker(GetPos(deathUnit), 300)

	NIS.StartNIS_Standard()

	-- get a generic entitry to spin around
	local ent = NIS.UnitToEnt(deathUnit)

	-- anything else specific to this CDR - including a dialog call
	-- Final VO timing: ~8 seconds
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= ent,			-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 35.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 75.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.001,		-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 250.0,		-- how close to spin relative to the unit
					nSpinDuration		= 10.0,			-- how long to allow the spin to persist
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 0.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	-- Destroy the commander
	ForkThread(
		function()
			WaitSeconds(4.5)
			NIS.ForceUnitDeath(deathUnit)
		end
	)
	NIS.Dialog(OpDialog.I06_M1_obj10_UPDATE_030)

	WaitSeconds(1.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_ILLUM_CDR_DEATH_End')

	func_VICTORY_CheckForVictory(ent, numCDRDeaths)
end

---------------------------------------------------------------------
function NIS_VICTORY(deadEnt)

	NIS.PreloadDialogData(
		{
			OpDialog.I06_NIS_VICTORY_010,
			OpDialog.I06_NIS_VICTORY_015,
			OpDialog.I06_NIS_VICTORY_017,
			OpDialog.I06_NIS_VICTORY_020,
			OpDialog.I06_NIS_VICTORY_030,
			OpDialog.I06_NIS_VICTORY_035,
			OpDialog.I06_NIS_VICTORY_037,
			OpDialog.I06_NIS_VICTORY_040,
			OpDialog.I06_NIS_VICTORY_050,
			OpDialog.I06_NIS_VICTORY_END,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_VICTORY_Start')

	-- NOTE: No NIS start. NIS_VICTORY is called from another function that has alread started the NIS
	NIS.CreateVizMarker('NIS_VIC_CDRWarp_Center', 1000.0)

	WaitSeconds(7.0)

	NIS.FadeOut(3.0)

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	WaitSeconds(2.0)

	-- disable combat for the duration of the remaining sequence
	NIS.DisableCombat()

	NIS.SetFOV(80.0)
	NIS.SetZoom(1000.0,0)

	WaitSeconds(1.0)

	-- Destroy all enemy units and hide units around conversation area
	func_VICTORY_Cleanup()

	WaitSeconds(3.0)

	NIS.FadeIn(3.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_OPENING_01'), GetOrient('NIS_OPENING_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_OPENING_01'), GetOrient('NIS_OPENING_01'), -10.0, 7.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_010) -- 6.7 protected gate

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_A_01'), GetOrient('NIS_VIC_CAM_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_A_02'), GetOrient('NIS_VIC_CAM_A_02'), 0.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_015) --3.9 (Stealth)

	NIS.Dialog(OpDialog.I06_NIS_VICTORY_017) -- Maddox

	ForkThread(
		function()
			WaitSeconds(2.5)
			func_VICTORY_HunkerACUs()
		end
	)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_HUNKER_CAM_01'), GetOrient('NIS_HUNKER_CAM_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_HUNKER_CAM_02'), GetOrient('NIS_HUNKER_CAM_02'), 0.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_020) -- Hunker!

	NIS.ZoomTo(GetPos('NIS_HUNKER_CAM_03'), GetOrient('NIS_HUNKER_CAM_03'), 0.0, 0.0)

	func_VICTORY_GaugeTransportSequence()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I06_NIS_VICTORY_NukeLaunch')

	ForkThread(
		function()
			WaitSeconds(3.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_B_01'), GetOrient('NIS_VIC_CAM_B_01'), 0.0, 0.0)
			WaitSeconds(1.0)
			NIS.NukePosition('NIS_VIC_CDRWarp_Center')
			NIS.FadeOutWhite()
			NIS.FadeInWhite(1.0)
			WaitSeconds(5.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_030) -- 8.7 Gauge

	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.ZoomTo(GetPos('NIS_GAUGE_EXIT_01'), GetOrient('NIS_GAUGE_EXIT_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_GAUGE_EXIT_02'), GetOrient('NIS_GAUGE_EXIT_02'), 0.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_035) -- 7.8 Gauge

	NIS.Dialog(OpDialog.I06_NIS_VICTORY_037) -- Good day (3.4)

	WaitSeconds(1.0)

	func_VICTORY_TeleportGauge()

	WaitSeconds(2.0)

	func_VICTORY_HunkerACUs()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_A_02'), GetOrient('NIS_VIC_CAM_A_02'), 0.0, 0.0)
			WaitSeconds(3.0)
			NIS.ZoomTo(GetPos('NIS_OPN_CAM_H_02'), GetOrient('NIS_OPN_CAM_H_02'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_OPN_CAM_H_02'), GetOrient('NIS_OPN_CAM_H_02'), 15.0, 6.0)
		end
	)

	-- Chat 4.4
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_040)

	ForkThread(
		function()
			WaitSeconds(3.5)
			func_VICTORY_FinalTransportArrivals()
		end
	)
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_050) -- Jaran (3.5)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('FINAL_CAMERA'), GetOrient('FINAL_CAMERA'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('FINAL_CAMERA'), GetOrient('FINAL_CAMERA'), -20.0, 7.0)
		end
	)

	-- 5 secs: Here come the Guardians
	NIS.Dialog(OpDialog.I06_NIS_VICTORY_END)

	-- wrap up without optional continued gameplay
	NIS.EndNIS_Victory(nil, false)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_PlayerTransportSequence(bSkip)
	-- group1
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_Group1,				-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_Group1Transport,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group01_Formup',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)

	-- CDR group
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_GroupCDR,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_CommanderTransport,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_03',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_CommanderDestination_Marker',	-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= func_OPENING_SetCDRLanded,				-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
end

function func_OPENING_SetCDRLanded()
	ScenarioInfo.CDR_LANDED = true

	local eng01 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_PLAYER]['PLAYER_ENG01']
	IssueClearCommands( {eng01} )
	IssueMove( {eng01}, GetPos( 'Engineer_Marker_01' ) )

	local eng02 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_PLAYER]['PLAYER_ENG02']
	IssueClearCommands( {eng02} )
	IssueMove( {eng02}, GetPos( 'Engineer_Marker_02' ) )
end

function func_OPENING_CreateNukeTransports(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ScenarioInfo.NIS_CYB_TRANS = NIS.CreateNISOnlyUnit('ARMY_CYBRAN01', 'NIS_CYB_TRANS')
	ScenarioInfo.NIS_ILL_TRANS = NIS.CreateNISOnlyUnit('ARMY_ILLUM01', 'NIS_ILL_TRANS')
	ScenarioInfo.NIS_UEF_TRANS = NIS.CreateNISOnlyUnit('ARMY_UEF01', 'NIS_UEF_TRANS')

	IssueMove( {ScenarioInfo.NIS_CYB_TRANS}, GetPos('TEMP_NUKE_OBJECT_01') )
	IssueMove( {ScenarioInfo.NIS_ILL_TRANS}, GetPos('TEMP_NUKE_OBJECT_03') )
	IssueMove( {ScenarioInfo.NIS_UEF_TRANS}, GetPos('TEMP_NUKE_OBJECT_04') )
end

function func_OPENING_WarpAndMoveACUS(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.WarpUnit(ScenarioInfo.CYBRAN_CDR, GetPos('TEMP_NUKE_OBJECT_01'))
	NIS.WarpUnit(ScenarioInfo.ILLUM_CDR, GetPos('TEMP_NUKE_OBJECT_03'))
	NIS.WarpUnit(ScenarioInfo.UEF_CDR, GetPos('TEMP_NUKE_OBJECT_04'))

	CreateTeleportEffects( ScenarioInfo.CYBRAN_CDR )
	CreateTeleportEffects( ScenarioInfo.ILLUM_CDR )
	CreateTeleportEffects( ScenarioInfo.UEF_CDR )

	IssueMove({ScenarioInfo.UEF_CDR}, GetPos('NIS_ACU_MOVE_01'))
	IssueMove({ScenarioInfo.ILLUM_CDR}, GetPos('NIS_ACU_MOVE_02'))
	IssueMove({ScenarioInfo.CYBRAN_CDR}, GetPos('NIS_ACU_MOVE_03'))
end

function func_OPENING_TransportsBoogie(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	WaitSeconds(1.0)
	-- CYB
	CreateTeleportEffects( ScenarioInfo.CYBRAN_CDR )
	NIS.HideUnit(ScenarioInfo.CYBRAN_CDR)
	NIS.WarpUnit(ScenarioInfo.CYBRAN_CDR, GetPos('P1_CYBRAN01_Main_Base_Marker'))
	IssueClearCommands({ScenarioInfo.NIS_CYB_TRANS})
	IssueMove( {ScenarioInfo.NIS_CYB_TRANS}, GetPos('P1_CYBRAN01_Main_Base_Marker') )

	-- ILL
	CreateTeleportEffects( ScenarioInfo.ILLUM_CDR )
	NIS.HideUnit(ScenarioInfo.ILLUM_CDR)
	NIS.WarpUnit(ScenarioInfo.ILLUM_CDR, GetPos('P1_ILLUM01_Main_Base_Marker'))
	IssueClearCommands({ScenarioInfo.NIS_ILL_TRANS})
	IssueMove( {ScenarioInfo.NIS_ILL_TRANS}, GetPos('P1_ILLUM01_Main_Base_Marker') )

	-- UEF
	CreateTeleportEffects( ScenarioInfo.UEF_CDR )
	NIS.HideUnit(ScenarioInfo.UEF_CDR)
	NIS.WarpUnit(ScenarioInfo.UEF_CDR, GetPos('P1_UEF01_Main_Base_Marker'))
	IssueClearCommands({ScenarioInfo.NIS_UEF_TRANS})
	IssueMove( {ScenarioInfo.NIS_UEF_TRANS}, GetPos('P1_UEF01_Main_Base_Marker') )
end

function func_OPENING_Nukes(bSkip)
	if bSkip then
		NIS.ForceGroupDeath(ScenarioInfo.P1_CYBRAN01_Init)
		NIS.ForceGroupDeath(ScenarioInfo.P1_UEF01_Init)
		NIS.ForceGroupDeath(ScenarioInfo.P1_ILLUM01_Init)
		return
	end

	-- Enemy transports fly out:
	WaitSeconds(3.0)

	NIS.NukePosition('TEMP_NUKE_OBJECT_01')
	NIS.ForceGroupDeath(ScenarioInfo.P1_CYBRAN01_Init)

	NIS.FadeOutWhite()
	NIS.FadeInWhite(1.0)

	WaitSeconds(0.5)

	NIS.NukePosition('TEMP_NUKE_OBJECT_04')
	NIS.ForceGroupDeath(ScenarioInfo.P1_UEF01_Init)

	NIS.FadeOutWhite()
	NIS.FadeInWhite(1.0)

	NIS.NukePosition('TEMP_NUKE_OBJECT_03')
	NIS.ForceGroupDeath(ScenarioInfo.P1_ILLUM01_Init)

	NIS.FadeOutWhite()
	NIS.FadeInWhite(1.0)
end

function func_OPENING_CleanupACUs(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.CYBRAN_CDR, GetPos('P1_CYBRAN01_Main_Base_Marker'))
		NIS.WarpUnit(ScenarioInfo.ILLUM_CDR, GetPos('P1_ILLUM01_Main_Base_Marker'))
		NIS.WarpUnit(ScenarioInfo.UEF_CDR, GetPos('P1_UEF01_Main_Base_Marker'))
		return
	end

	NIS.ShowUnit(ScenarioInfo.UEF_CDR)
	NIS.ShowUnit(ScenarioInfo.ILLUM_CDR)
	NIS.ShowUnit(ScenarioInfo.CYBRAN_CDR)
end

function func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)
	-- If all three commanders are dead
	if numCDRDeaths == 3 then
		-- goto victory
		NIS_VICTORY(deadEnt)
	-- otherwise
	else
		-- end the NIS with the standard nis function
		NIS.EndNIS_Standard()
	end
end

function func_VICTORY_Cleanup()
	-- Destroy enemies
	local unitList = ArmyBrains[ScenarioInfo.ARMY_CYBRAN01]:GetListOfUnits(categories.ALLUNITS - categories.scb9001, false)
	for k, unit in unitList do
		NIS.ForceUnitDeath(unit)
	end

	unitList = ArmyBrains[ScenarioInfo.ARMY_ILLUM01]:GetListOfUnits(categories.ALLUNITS - categories.scb9001, false)
	for k, unit in unitList do
		NIS.ForceUnitDeath(unit)
	end

	unitList = ArmyBrains[ScenarioInfo.ARMY_UEF01]:GetListOfUnits(categories.ALLUNITS - categories.scb9001, false)
	for k, unit in unitList do
		NIS.ForceUnitDeath(unit)
	end

	-- Make sure CDRs are not hidden by warping them to a safe location
	Warp(ScenarioInfo.PLAYER_CDR, GetPos('P1_ILLUM01_Air_AttackMaddox_Chain_01_07'))
	Warp(ScenarioInfo.ALLY01_CDR, GetPos('P1_ILLUM01_Air_AttackMaddox_Chain_01_07'))

	local catsToDestroy = categories.ALLUNITS - categories.COMMAND

	-- Destroy ally units
	unitList = ArmyBrains[ScenarioInfo.ARMY_ALLY01]:GetUnitsAroundPoint( catsToDestroy, GetPos('NIS_VIC_CDRWarp_Center'), 30.0, 'Ally' )
	NIS.DestroyGroup(unitList)

	-- Destroy player units
	unitList = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetUnitsAroundPoint( catsToDestroy, GetPos('NIS_VIC_CDRWarp_Center'), 30.0, 'Ally' )
	NIS.DestroyGroup(unitList)

	-- Destroy ally units around teleporter
	unitList = ArmyBrains[ScenarioInfo.ARMY_ALLY01]:GetUnitsAroundPoint( catsToDestroy, GetPos('NIS_VIC_GuageTransRoute_Formup'), 60.0, 'Ally' )
	NIS.DestroyGroup(unitList)

	-- Destroy player units around teleporter
	unitList = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetUnitsAroundPoint ( catsToDestroy, GetPos('NIS_VIC_GuageTransRoute_Formup'), 60.0, 'Ally' )
	NIS.DestroyGroup(unitList)

	-- Stop CDR AIs
	ScenarioInfo.ALLY01_CDR.PlatoonHandle:StopAI()
	IssueClearCommands({ScenarioInfo.ALLY01_CDR})
	IssueStop({ScenarioInfo.ALLY01_CDR})
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})

	-- Warp CDRs to conversation location
	Warp(ScenarioInfo.ALLY01_CDR, GetPos('NIS_VIC_CDRWarp_Maddox'))
	ScenarioInfo.ALLY01_CDR:SetOrientation(GetOrient('NIS_VIC_CDRWarp_Maddox'), true)

	Warp(ScenarioInfo.PLAYER_CDR, GetPos('NIS_VIC_CDRWarp_Thalia'))
	ScenarioInfo.PLAYER_CDR:SetOrientation(GetOrient('NIS_VIC_CDRWarp_Thalia'), true)
end

function func_VICTORY_HunkerACUs()
	if not ScenarioInfo.AlreadyNISHunkered then
		ScenarioInfo.AlreadyNISHunkered = true
		ArmyBrains[ScenarioInfo.ARMY_PLAYER]:CompleteResearch( {'ICA_HUNKER'} )
		ArmyBrains[ScenarioInfo.ARMY_ALLY01]:CompleteResearch( {'UCA_HUNKER'} )
	end

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueClearCommands({ScenarioInfo.ALLY01_CDR})

	local Thalia = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:MakePlatoon('', '')
	local Maddox = ArmyBrains[ScenarioInfo.ARMY_ALLY01]:MakePlatoon('', '')

	ArmyBrains[ScenarioInfo.ARMY_PLAYER]:AssignUnitsToPlatoon( Thalia, {ScenarioInfo.PLAYER_CDR}, 'Attack', 'AttackFormation' )
	ArmyBrains[ScenarioInfo.ARMY_ALLY01]:AssignUnitsToPlatoon( Maddox, {ScenarioInfo.ALLY01_CDR}, 'Attack', 'AttackFormation' )

	Maddox:UseAbility("acu_hunker")
	Thalia:UseAbility("acu_hunker")
end

function func_VICTORY_GaugeTransportSequence()
	---NOTE: this should have been created as a single unit in ScenarioInfo... - bfricks 12/6/09
	local CDR_Group = NIS.CreateNISOnlyGroup('ARMY_GAUGE', 'GAUGE')
	local GAUGE_TRANS = NIS.CreateNISOnlyUnit('ARMY_GAUGE', 'GAUGE_TRANS')

	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',						-- name of the army for whom the transport and group are being created
			units					= CDR_Group,							-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= GAUGE_TRANS,							-- unit handle for the actual transport
			approachChain			= 'NIS_VIC_GuageTransRoute',			-- optional chainName for the approach travel route
			unloadDest				= 'NIS_VIC_GuageTransRoute_06',			-- destination for the transport drop-off
			returnDest				= 'NIS_VIC_GuageTransRoute_Return',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= true,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'NIS_VIC_GuageTransRoute_Formup',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,									-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= false,								-- will this transport be usable after the NIS?
		}
	)
end

function func_VICTORY_TeleportGauge()
	---NOTE: wow the below iteration is really bad - this should have been created as a single unit in ScenarioInfo... - bfricks 12/6/09

	unitList = ArmyBrains[ScenarioInfo.ARMY_GAUGE]:GetListOfUnits(categories.ucl0001, false)
	for k, unit in unitList do
		if unit and not unit:IsDead() then
			NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_01_ring_emit.bp', GetPos(unit))
			NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_02_glow_emit.bp', GetPos(unit))
			CreateTeleportEffects( unit )
			NIS.HideUnit( unit)
			break
		end
	end
end

function func_VICTORY_FinalTransportArrivals()
	ScenarioInfo.FINAL_TRANSPORTS = NIS.CreateNISOnlyGroup('ARMY_ILLUM01', 'FINAL_TRANSPORTS')
	IssueFormMove(ScenarioInfo.FINAL_TRANSPORTS, GetPos('NIS_VIC_GuageTransRoute_06'), 'AttackFormation', 0)
end
