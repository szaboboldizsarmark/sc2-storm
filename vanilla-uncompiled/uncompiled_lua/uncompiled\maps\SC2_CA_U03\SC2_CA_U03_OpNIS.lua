---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_U03/SC2_CA_U03_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_U03/SC2_CA_U03_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_U03/SC2_CA_U03_script.lua')
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
	local nOverrideZoom	= 100.0

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
				func_OPENING_TimeDilationStart(true)
				func_OPENING_TransportCleanup(true)
				func_OPENING_MoveCDR(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('U03_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.U03_NIS_OP_SETUP_020)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.U03_NIS_OPENING_010,
			OpDialog.U03_NIS_OP_SETUP_010,
			OpDialog.U03_NIS_OP_SETUP_020,
		}
	)

	func_OPENING_PlayerTransportSequence()

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('U03_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance and the stat position
	NIS.StartNIS_Opening('NIS1_CAM_A_01', 0.0, 'NIS1_CAM_A_01', 80.0)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	-- Final VO timing: 8.2 seconds
	ForkThread(
		function()
			-- transport fly by
			NIS.ZoomTo(GetPos('NIS1_CAM_A_02'), GetOrient('NIS1_CAM_A_02'), 50.0, 7.0)

			-- track transport
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.INTRONIS_CommanderTransport,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 190.0,									-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,										-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 30.0,										-- how close to track relative to the unit
					nTrackToDuration	= 0.0,										-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,										-- if specified, offset in the X direction
					nOffsetY			= -1.25,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,										-- if specified, offset in the Z direction
				}
			)

			WaitSeconds(4.3)

			-- Wide shot of Maddox building base
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_04'), GetOrient('NIS1_CAM_E_04'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_03'), GetOrient('NIS1_CAM_E_03'), 0.0, 4.0)
		end
	)
	WaitSeconds(5.0)
	NIS.Dialog(OpDialog.U03_NIS_OPENING_010)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_OPENING_TimeDilationStart')


	---NOTE: this is a potential solution to inconsistent flight durations - if this is not deemed appropriate we will need to
	---			consider fake ACUs for the NIS - bfricks 10/28/09
	while not ScenarioInfo.CDR_LANDED do
		WARN('WARNING: NIS paused due to CDR not being in position for scripted commands - if this spams, pass to campaign design.')
		WaitTicks(1)
	end

	-- Time Dilation: clear builds, add bases
	func_OPENING_TimeDilationStart()

	-- cleanup the transport
	func_OPENING_TransportCleanup()

	-- setup a bunch of viz markers and arrows
	NIS.CreateVizMarker('P2_ENEMY01_AirAttack_Route_01_11', 25)
	NIS.CreateVizMarker('P2_ENEMY01_AirAttack_Route_01_12', 25)
	NIS.CreateArrow('NIS_MASS_01', 10.0)
	NIS.CreateArrow('NIS_MASS_02', 10.0)

	-- Final VO timing: 16.4 seconds
	ForkThread(
		function()
			WaitSeconds(1.0)

			-- move the CDR
			func_OPENING_MoveCDR()

			-- set FOV and fade-in
			NIS.SetFOV(60.0)
			NIS.FadeIn(1.5)

			-- trigger music system for this transition point
			NIS.PlayMusicEventByHandle('U03_NIS_OPENING_TimeDilationEnd')

			-- Reverse from mass extractors to Maddox
			NIS.SetFOV(40.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_01'), GetOrient('NIS1_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_03'), GetOrient('NIS1_CAM_C_03'), 10.0, 8.0)
		end
	)
	NIS.Dialog(OpDialog.U03_NIS_OP_SETUP_010)

	NIS.SetFOV(60.0)
	NIS.ZoomTo(GetPos('NIS1_CAM_D_04'), GetOrient('NIS1_CAM_D_04'), 10.0, 0.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.U03_NIS_OP_SETUP_020)
end

---------------------------------------------------------------------
-- NIS_REVEAL_ENEMY:
---------------------------------------------------------------------
function NIS_REVEAL_ENEMY()

	NIS.PreloadDialogData(
		{
			OpDialog.U03_NIS_REVEAL_ENEMY_005,
			OpDialog.U03_NIS_REVEAL_ENEMY_015,
			OpDialog.U03_NIS_REVEAL_ENEMY_030,
			OpDialog.U03_NIS_REVEAL_OP_SETUP_010,
			OpDialog.U03_NIS_REVEAL_ENEMY_040,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('P2_Intro_NIS_VisLoc01', 1000)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_REVEAL_ENEMY_Start')

	-- tell the krakken to dive
	func_REVEAL_ENEMY_KrakenDive()

	-- use StartNIS_MidOp to expand the playable area and allow a smooth camera reveal
	NIS.StartNIS_MidOp('AREA_2')

	--Hail dialog; use current camera
	NIS.Dialog(OpDialog.U03_NIS_REVEAL_ENEMY_005)

	WaitSeconds(1.0)

	-- Final VO timing: 6.9 seconds
	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 150.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.5,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(6.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ENEM01_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 45.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 35.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.5,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U03_NIS_REVEAL_ENEMY_015)

	-- Final VO timing: 7.5 seconds
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS3_CAM_A_01'),GetOrient('NIS3_CAM_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS3_CAM_A_02'),GetOrient('NIS3_CAM_A_02'), 0.0, 7.5)
		end
	)
	NIS.Dialog(OpDialog.U03_NIS_REVEAL_ENEMY_030)

	-- To better time the arrival of Kraken and not have gunship dialog go on too long.
	ForkThread(
		function()
			WaitSeconds(6.0)
			func_REVEAL_ENEMY_KrakenSurface()
		end
	)

	ForkThread(
		function()
			--Need to show the enemy gunships here
			NIS.ZoomTo(GetPos('NIS_MID_PAN_01'),GetOrient('NIS_MID_PAN_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MID_PAN_02'),GetOrient('NIS_MID_PAN_02'), 0.0, 8.0)
		end
	)

	NIS.Dialog(OpDialog.U03_NIS_REVEAL_OP_SETUP_010)
	WaitSeconds(2.0)

	-- Final VO timing: 8.5 seconds
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.P2_Kraken,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 150.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.005,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 20.0,							-- how close to spin relative to the unit
					nSpinDuration		= 13.0,							-- how long to allow the spin to persist
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_REVEAL_ENEMY_Krakken')
	NIS.Dialog(OpDialog.U03_NIS_REVEAL_ENEMY_040)

	--Get the kraken back underwater for the start of P2.
	func_REVEAL_ENEMY_KrakenDive()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_REVEAL_ENEMY_End')

	-- use EndNIS_MidOp and restore to the player
	---NOTE: intentionally flush the intel - bfricks 10/31/09
	NIS.EndNIS_MidOp(true)
end

---------------------------------------------------------------------
-- NIS_GAUGE_ESCAPE:
---------------------------------------------------------------------
function NIS_GAUGE_ESCAPE()

	NIS.PreloadDialogData(
		{
			OpDialog.U03_NIS_GAUGE_RECALLED_010,
			OpDialog.U03_NIS_GAUGE_RECALLED_020,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('NIS_GAUGE_ESCAPE_VisLoc_01', 40.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_GAUGE_ESCAPE_Start')

	NIS.StartNIS_MidOp()

	-- Gauge exit forked to keep separate from cameras
	ForkThread(func_GAUGE_ESCAPE_ExitGauge)

	-- Final VO timing: 21.1 seconds
	ForkThread(
		function()
			-- camera stuff
			WaitSeconds(4.0)
			NIS.SetFOV(85.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_G_01'),GetOrient('NIS2_CAM_G_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_G_02'),GetOrient('NIS2_CAM_G_02'), 0.0, 8.5)

			NIS.ZoomTo(GetPos('NIS2_CAM_I_01'),GetOrient('NIS2_CAM_I_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_I_02'),GetOrient('NIS2_CAM_I_02'), 0.0, 13.5)
		end
	)
	NIS.Dialog(OpDialog.U03_NIS_GAUGE_RECALLED_010)

	-- Megaliths show up; forked to keep separate from cameras
	ForkThread(func_GAUGE_ESCAPE_EnterMegaliths)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_GAUGE_ESCAPE_Megaliths')

	-- Final VO timing: 4.6 seconds
	ForkThread(
		function()
			-- camera stuff
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_H_03'),GetOrient('NIS2_CAM_H_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_H_04'),GetOrient('NIS2_CAM_H_04'), 0.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.U03_NIS_GAUGE_RECALLED_020)
	WaitSeconds(4.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_GAUGE_ESCAPE_End')

	-- use EndNIS_MidOp and restore to the player
	NIS.EndNIS_MidOp()
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.U03_NIS_VICTORY_010,
			OpDialog.U03_NIS_VICTORY_015,
			OpDialog.U03_NIS_VICTORY_040,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U03_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	local CamSet01_heading 	= 190.0
	local CamSet01_pitch 	= 45.0
	local CamSet01_distance = 30.0

	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit				= deathUnit,			-- unit to be killed
			vizRadius			= 300.0,				-- optional distance for a visibility marker ring
			degreesHeading		= CamSet01_heading,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= CamSet01_pitch,		-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= CamSet01_distance,	-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,					-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,					-- if specified, offset in the X direction
			nOffsetY			= 0.0,					-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,					-- if specified, offset in the Z direction
		}
	)

	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= targetEnt,			-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= CamSet01_heading,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= CamSet01_pitch,		-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.01,					-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= CamSet01_distance,	-- how close to spin relative to the unit
					nSpinDuration		= 5.0,					-- how long to allow the spin to persist
					nOffsetX			= 0.0,					-- if specified, offset in the X direction
					nOffsetY			= 0.0,					-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,					-- if specified, offset in the Z direction
				}
			)

			NIS.SetFOV(50.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_J_01'),GetOrient('NIS2_CAM_J_01'), 0.0, 0.0)
			NIS.AddFade(
				{
					nFadeIn 		= 0.0,			-- Number of seconds to fade in.
					nFadeOut	 	= 1.0,			-- Number of seconds to fade out.
					sColor			= 'ff000000',	-- Hex color (as string) for fade color.
					nShotDurration 	= 5.0,			-- Length of the shot in seconds.
					fcnCamBehavior 	= NIS.ZoomTo,	-- The function that controls the camera behavior.
					tblParams 		= {				-- The table of the parameters need for the behavior function.
						GetPos('NIS2_CAM_J_02'),
						GetOrient('NIS2_CAM_J_02'),
						0.0,
						5.0
					}
				}
			)
		end
	)
	WaitSeconds(3.3)
	NIS.Dialog(OpDialog.U03_NIS_VICTORY_010)
	WaitSeconds(1.0)

	-- Destroy base leftovers
	ForkThread(func_VICTORY_DestroyEnemyBase)

	-- Put Maddox back in his base
	func_VICTORY_SetupMaddox()

	ForkThread(
		function()
			-- Establish Maddox in player base
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_B_01'),GetOrient('NIS2_CAM_B_01'), 0.0, 0.0)
			NIS.AddFade(
				{
					nFadeIn 		= 1.0,			-- Number of seconds to fade in.
					nFadeOut	 	= 0.0,			-- Number of seconds to fade out.
					sColor			= 'ff000000',	-- Hex color (as string) for fade color.
					nShotDurration 	= 7.0,			-- Length of the shot in seconds.
					fcnCamBehavior 	= NIS.ZoomTo,	-- The function that controls the camera behavior.
					tblParams 		= {				-- The table of the parameters need for the behavior function.
						GetPos('NIS2_CAM_B_02'),
						GetOrient('NIS2_CAM_B_02'),
						0.0,
						7.0
					}
				}
			)
			WaitSeconds(0.5)

			NIS.ZoomTo(GetPos('NIS2_CAM_D_01'),GetOrient('NIS2_CAM_D_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_D_02'),GetOrient('NIS2_CAM_D_02'), 0.0, 7.0)

			-- Medium shot of Maddox
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 195.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -10.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= -0.002,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 15.0,							-- how close to spin relative to the unit
					nSpinDuration		= 6.0,							-- how long to allow the spin to persist
					nOffsetX			= 1.5,							-- if specified, offset in the X direction
					nOffsetY			= 4.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)

			ForkThread(func_VICTORY_TransMoveToTarget)

			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.NIS_VIC_TRANS,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 190.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 20.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= -1.25,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U03_NIS_VICTORY_015)--new shorter version

	ForkThread(
		function()
			-- track transport
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.NIS_VIC_TRANS,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 60.0,							-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 40.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= -1.25,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)

			WaitSeconds(5.0)

			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.NIS_VIC_TRANS,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 100.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 60.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= -1.25,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U03_NIS_VICTORY_040)--new shortened ending

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, false)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_PlayerTransportSequence(bSkip)
	-- CDR group
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_GroupCDR,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_CommanderTransport,	-- unit handle for the actual transport
			approachChain			= 'Player_Transport_Chain',					-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_01',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group_Formup_01',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= func_OPENING_SetCDRLanded,				-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
end
function func_OPENING_SetCDRLanded()
	ScenarioInfo.CDR_LANDED = true
end

function func_OPENING_TimeDilationStart(bSkip)
	if bSkip then
		NIS.FakeBuild(ScenarioInfo.PLAYER_CDR, 'ARMY_PLAYER', ScenarioInfo.ARMY_PLAYER, 'PLAYER_Factory', 'PLAYER_StartingStructures', 3.0, bSkip)
		return
	end

	-- fake build before we time dilate, then while dilated - create the full group
	NIS.FakeBuildNoWait(ScenarioInfo.PLAYER_CDR, 'ARMY_PLAYER', ScenarioInfo.ARMY_PLAYER, 'PLAYER_Factory', 'PLAYER_StartingStructures', 3.0)
	WaitSeconds(1.0)
	NIS.FadeOut(1.5)
	WaitSeconds(2.0)
end

function func_OPENING_TransportCleanup(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.DestroyUnit(ScenarioInfo.INTRONIS_CommanderTransport)
end

function func_OPENING_MoveCDR(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('PLAYER_CDR_START'))
		return
	end

	IssueClearCommands( ScenarioInfo.PLAYER_CDR )
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('PLAYER_CDR_START') )
end

function func_REVEAL_ENEMY_KrakenSurface()
	if ScenarioInfo.P2_Kraken and not ScenarioInfo.P2_Kraken:IsDead() then
		if ScenarioInfo.P2_Kraken.Surfaced == nil then
			WARN('WARNING: ScenarioInfo.P2_Kraken.Surfaced is invalid which might lead to some problems with the unit looking correct in the NIS.')
			ScenarioInfo.P2_Kraken.Surfaced = false
		end

		if not ScenarioInfo.P2_Kraken.Surfaced then
			-- toggle our state
			ScenarioInfo.P2_Kraken.Surfaced = true

			-- if we are under the water, surface, otherwise do nothing
			IssueClearCommands({ScenarioInfo.P2_Kraken})
			IssueDive({ScenarioInfo.P2_Kraken})
		end
	end
end

function func_REVEAL_ENEMY_KrakenDive()
	if ScenarioInfo.P2_Kraken and not ScenarioInfo.P2_Kraken:IsDead() then
		if ScenarioInfo.P2_Kraken.Surfaced == nil then
			WARN('WARNING: ScenarioInfo.P2_Kraken.Surfaced is invalid which might lead to some problems with the unit looking correct in the NIS.')
			ScenarioInfo.P2_Kraken.Surfaced = false
		end

		if ScenarioInfo.P2_Kraken.Surfaced then
			-- toggle our state
			ScenarioInfo.P2_Kraken.Surfaced = false

			-- if we are on the surface, dive, otherwise do nothing
			IssueClearCommands({ScenarioInfo.P2_Kraken})
			IssueDive({ScenarioInfo.P2_Kraken})
		end
	end
end

function func_GAUGE_ESCAPE_ExitGauge()
	-- create the beacon
	ScenarioInfo.P2_GaugeBeacon = NIS.CreateNISOnlyUnit('ARMY_ENEM01', 'P2_ENEM01_GaugeNIS_Beacon')

	-- march Gauge to in front of the Beacon
	IssueMove({ScenarioInfo.ENEM01_CDR}, GetPos('NIS_GAUGE_ESCAPE_Beacon_Marker'))

	-- Sufficient time for Gauge to get to beacon, then warp him offmap.
	WaitSeconds(12.0)
	Warp( ScenarioInfo.ENEM01_CDR, GetPos('NIS_GAUGE_ESCAPE_Beacon_Marker') )
	CreateTeleportEffects( ScenarioInfo.ENEM01_CDR )
	NIS.DestroyUnit(ScenarioInfo.ENEM01_CDR)
end

function func_GAUGE_ESCAPE_EnterMegaliths()
	-- The megaliths stomp in: create them, then warp them to the beacon, and send them to a position.
	Warp( ScenarioInfo.P2_Megalith01, GetPos('NIS_GAUGE_ESCAPE_Beacon_Marker') )
	IssueMove({ScenarioInfo.P2_Megalith01}, GetPos('NIS_GAUGE_ESCAPE_Magalith_Dest_01'))
	CreateTeleportEffects( ScenarioInfo.P2_Megalith01 )
	WaitSeconds(3.0)

	Warp( ScenarioInfo.P2_Megalith02, GetPos('NIS_GAUGE_ESCAPE_Beacon_Marker') )
	IssueMove({ScenarioInfo.P2_Megalith02}, GetPos('NIS_GAUGE_ESCAPE_Magalith_Dest_02'))
	CreateTeleportEffects( ScenarioInfo.P2_Megalith02 )
	WaitSeconds(3.0)

	Warp( ScenarioInfo.P2_Megalith03, GetPos('NIS_GAUGE_ESCAPE_Beacon_Marker') )
	IssueMove({ScenarioInfo.P2_Megalith03}, GetPos('NIS_GAUGE_ESCAPE_Magalith_Dest_03'))
	CreateTeleportEffects( ScenarioInfo.P2_Megalith03 )
	WaitSeconds(2.0)

	NIS.DestroyUnit(ScenarioInfo.P2_GaugeBeacon)
end

function func_VICTORY_DestroyEnemyBase()
	---NOTE: we exclude several unit types so the player doesn't get objective completion - bfricks 1/5/10
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS - categories.scb9001 - categories.ucx0113, false)
	NIS.ForceGroupDeath(unitList)
end

function func_VICTORY_SetupMaddox()
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueStop( {ScenarioInfo.PLAYER_CDR} )
	Warp( ScenarioInfo.PLAYER_CDR, GetPos('P1_Intro_NIS_VisLoc01') )
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('NIS_VIC_PLAYER_CDR_WARP_01') )
end

function func_VICTORY_TransMoveToTarget()
	-- Create a Transport, send it to meet the Ally commander, pick up him, and return offmap.
	ScenarioInfo.NIS_VIC_TRANS = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'NIS_VIC_TRANS')
	local cmd = IssueMove( {ScenarioInfo.NIS_VIC_TRANS}, GetPos('NIS_VIC_PLAYER_CDR_WARP_01') )
	while cmd and not IsCommandDone(cmd) do
		WaitTicks(1)
	end
	IssueTransportLoad({ScenarioInfo.PLAYER_CDR}, ScenarioInfo.NIS_VIC_TRANS )

	for k,v in import('/lua/sim/ScenarioUtilities.lua').ChainToPositions('NIS_VIC_TRAN_PATH') do
		IssueMove( {ScenarioInfo.NIS_VIC_TRANS}, v )
	end
end