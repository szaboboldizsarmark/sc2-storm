---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_C06/SC2_CA_C06_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_C06/SC2_CA_C06_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_C06/SC2_CA_C06_script.lua')
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
				func_OPENING_HidePlayerUnits(true)
				func_OPENING_MakeWreckage(true)
				func_OPENING_WarpPlayerUnits01(true)
				func_OPENING_MoveGauge01(true)
				func_OPENING_WarpPlayerUnits02(true)
				func_OPENING_StopCDR(true)
				func_OPENING_PlayerAdvance(true)
				func_OPENING_MoveGauge02(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('C06_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.C06_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.C06_NIS_OP_SETUP_015)
				NIS.DialogNoWait(OpDialog.C06_NIS_OP_SETUP_020)
				NIS.DialogNoWait(OpDialog.C06_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.C06_NIS_OPENING_010,
			OpDialog.C06_NIS_OPENING_011,
			OpDialog.C06_NIS_OPENING_013,
			OpDialog.C06_NIS_OPENING_014,
			OpDialog.C06_NIS_OPENING_015,
			OpDialog.C06_NIS_OPENING_020,
			OpDialog.C06_NIS_OPENING_030,
			OpDialog.C06_NIS_OP_SETUP_010,
			OpDialog.C06_NIS_OP_SETUP_015,
			OpDialog.C06_NIS_OP_SETUP_020,
			OpDialog.C06_NIS_OP_SETUP_END,
		}
	)

	---NOTE: if these are showing up in a way that is not good for display - speak to me before changing please - bfricks 11/8/09
	NIS.CreateVizMarker('COILS_01', 50)
	NIS.CreateVizMarker('COILS_02', 50)
	NIS.CreateVizMarker('COILS_03', 50)
	NIS.CreateVizMarker('COILS_04', 50)
	NIS.CreateVizMarker('ARMY_ENEM01', 150)

	--Hide your units and blow up the guardians
	func_OPENING_HidePlayerUnits()
	func_OPENING_MakeWreckage()

	WaitSeconds(2.0)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('C06_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS_OPENING_CAM_03', -30.0, 'NIS_OPENING_CAM_03')

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_OPENING_CAM_04'), GetOrient('NIS_OPENING_CAM_04'), -40.0, 6.0)
		end
	)

	-- warp in player units
	func_OPENING_WarpPlayerUnits01()

	WaitSeconds(3.0)

	-- Move Gauge
	func_OPENING_MoveGauge01()

	NIS.SetFOV(30.0, 5.0)
	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.GAUGE_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -7.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(3.0)
			NIS.SetZoom(13.0, 2.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OPENING_010) --Ivan!, buddy (5 secs)

	WaitSeconds(2.0)

	ForkThread(func_OPENING_WarpPlayerUnits02)

	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -1.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 25.0,							-- how close to track relative to the unit
					nTrackToDuration	= 7.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OPENING_011) -- My friends 4.7 secs

	WaitSeconds(2.0)

	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.GAUGE_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 182.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -2.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 70.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(1.0)
			NIS.ZoomTo(GetPos('NIS_GAUGE_OPEN_REVEAL_03'), GetOrient('NIS_GAUGE_OPEN_REVEAL_03'), 200.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OPENING_013) -- Showing the machine (6.1)

	NIS.Dialog(OpDialog.C06_NIS_OPENING_014) -- I have learned (4.4)

	WaitSeconds(1.0)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.GAUGE_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -2.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 7.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(0.1)
			NIS.SetZoom(6.5,4.0)
		end
	)
	WaitSeconds(1.0)
	NIS.Dialog(OpDialog.C06_NIS_OPENING_015) -- Let me demonstrate (1.2)

	WaitSeconds(1.0)

	NIS.FadeOut(0.0)

	func_OPENING_StopCDR()

	--and we warp
	NIS.PlayMovie('/movies/FMV_CYB_C06_OPENING')

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	NIS.SetFOV(60.0)
	NIS.FadeIn(3.0)
	NIS.EntityTrackRelative(
		{
			ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= -1.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nTrackDistance		= 10.0,							-- how close to track relative to the unit
			nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
			nOffsetX			= 1.0,							-- if specified, offset in the X direction
			nOffsetY			= 2.0,							-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
		}
	)
	WaitSeconds(1.0)
	NIS.Dialog(OpDialog.C06_NIS_OPENING_020) -- What was that? (0.8)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 0.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 40.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 75.0,						-- how close to track relative to the unit
					nTrackToDuration	= 4.0,						-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,						-- if specified, offset in the X direction
					nOffsetY			= 0.0,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,						-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(2.0)
			func_OPENING_PlayerAdvance()
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OPENING_030) -- Operational (5.9)

	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_A_03'), GetOrient('NIS1_CAM_A_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_A_04'), GetOrient('NIS1_CAM_A_04'), 0.0, 10.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OPENING_040) -- Above Altair (8.5)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 170.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 55.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 70.0,							-- how close to track relative to the unit
					nTrackToDuration	= 4.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 0.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(5.0)
			NIS.ZoomTo(GetPos('Intro_NIS_MovePoint_CDR'), GetOrient('NIS_BASE_BUILD_01'), 120.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OP_SETUP_010) -- 10.1 (need to stop Gauge)

	-- Move Gauge back
	func_OPENING_MoveGauge02()

	ForkThread(
		function()
			WaitSeconds(1.0)
			NIS.ZoomTo(GetPos('NIS_GAUGE_FIELD_REVEAL_02'), GetOrient('NIS_GAUGE_FIELD_REVEAL_02'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_GAUGE_FIELD_REVEAL_02'), GetOrient('NIS_GAUGE_FIELD_REVEAL_02'), 50.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OP_SETUP_015) -- 8.1 (Quantum Field reveal)

	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.ZoomTo(GetPos('NIS_POWER_SOURCE_05'), GetOrient('NIS_POWER_SOURCE_05'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_POWER_SOURCE_06'), GetOrient('NIS_POWER_SOURCE_06'), 0.0, 7.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_OP_SETUP_020) -- 7.9 (power source)

	NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 100.0, 0.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_OPENING_End')

	---NOTE: this is intentional - and works better for timing - bfricks 12/6/09
	NIS.DialogNoWait(OpDialog.C06_NIS_OP_SETUP_END)

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)
end

---------------------------------------------------------------------
-- NIS_FIRST_COIL_DOWN:
---------------------------------------------------------------------
function NIS_FIRST_COIL_DOWN(unit)

	NIS.PreloadDialogData(
		{
			OpDialog.C06_COIL_DESTROYED_010,
			OpDialog.C06_COIL_DESTROYED_015,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_FIRST_COIL_DOWN_Start')

	NIS.StartNIS_Standard()

	local ent = NIS.UnitToEnt(unit)
	NIS.ForceUnitDeath(unit)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ent,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,	-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 30.0,		-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 240.0,	-- how close to spin relative to the unit
					nTrackToDuration	= 0.0,		-- how long to allow the spin to persist
					nOffsetX			= 0.0,		-- if specified, offset in the X direction
					nOffsetY			= 6.0,		-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,		-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C06_COIL_DESTROYED_010)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_FIRST_COIL_DOWN_End')

	NIS.EndNIS_Standard()

	NIS.DialogNoWait(OpDialog.C06_COIL_DESTROYED_015)
end

---------------------------------------------------------------------
-- NIS_ALL_COILS_DOWN:
---------------------------------------------------------------------
function NIS_ALL_COILS_DOWN(unit)

	NIS.PreloadDialogData(
		{
			OpDialog.C06_NIS_REVEAL_OPENING_010,
			OpDialog.C06_NIS_REVEAL_OPENING_015,
			OpDialog.C06_NIS_REVEAL_OPENING_020,
			OpDialog.C06_NIS_REVEAL_OP_SETUP_010,
			OpDialog.C06_NIS_REVEAL_OP_SETUP_END,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_ALL_COILS_DOWN_Start')

	NIS.CreateVizMarker('ARMY_ENEM01', 300)
	NIS.CreateVizMarker('COILS_01', 150)
	NIS.CreateVizMarker('COILS_02', 150)
	NIS.CreateVizMarker('COILS_03', 150)
	NIS.CreateVizMarker('COILS_04', 150)

	NIS.StartNIS_Standard()

	local ent = NIS.UnitToEnt(unit)
	NIS.ForceUnitDeath(unit)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ent,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,	-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 30.0,		-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 240.0,	-- how close to spin relative to the unit
					nTrackToDuration	= 0.0,		-- how long to allow the spin to persist
					nOffsetX			= 0.0,		-- if specified, offset in the X direction
					nOffsetY			= 6.0,		-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,		-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_REVEAL_OPENING_010) -- 2.1 destroyed

	ForkThread(
		function()
			WaitSeconds(2.0)
			OpScript.DestroyInvField()
		end
	)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_GAUGE_FIELD_REVEAL_02'), GetOrient('NIS_GAUGE_FIELD_REVEAL_02'), 100.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_GAUGE_FIELD_REVEAL_02'), GetOrient('NIS_GAUGE_FIELD_REVEAL_02'), 130.0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_REVEAL_OPENING_015) -- Field down (3.9)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_ALL_COILS_DOWN_DefenseActive')

	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.ZoomTo(GetPos('NIS_SPAWNER_REVEAL_01'), GetOrient('NIS_SPAWNER_REVEAL_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_SPAWNER_REVEAL_02'), GetOrient('NIS_SPAWNER_REVEAL_02'), 0.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_REVEAL_OPENING_020) --6.4 Shiva angry, defenses online

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_ALL_COILS_DOWN_End')

	NIS.EndNIS_Standard()

	NIS.DialogNoWait(OpDialog.C06_NIS_REVEAL_OP_SETUP_010)
	NIS.DialogNoWait(OpDialog.C06_NIS_REVEAL_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.C06_NIS_VICTORY_005,
			OpDialog.C06_NIS_VICTORY_007,
			OpDialog.C06_NIS_VICTORY_009,
			OpDialog.C06_NIS_VICTORY_010,
			OpDialog.C06_NIS_VICTORY_015,
			OpDialog.C06_NIS_VICTORY_020,
			OpDialog.C06_NIS_VICTORY_030,
			OpDialog.C06_NIS_VICTORY_040,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	NIS.CreateVizMarker('ArmyBase_P1_ENEM01_Front_Base_EngineerChain_03', 1000)

	IssueClearCommands( {deathUnit} )
	IssueStop( {deathUnit} )

	ForkThread(
		function()
			-- Hero spin
			NIS.EntitySpinRelative(
				{
					ent					= deathUnit,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -10.5,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.01,				-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 12.0,				-- how close to spin relative to the unit
					nSpinDuration		= 6.0,				-- how long to allow the spin to persist
					nOffsetX			= 1.0,				-- if specified, offset in the X direction
					nOffsetY			= 4.1,				-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,				-- if specified, offset in the Z direction
				}
			)
			-- Gauges Escape Pod
			NIS.EntitySpinRelative(
				{
					ent					= deathUnit,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 35.0,				-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.009,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 10.0,				-- how close to spin relative to the unit
					nSpinDuration		= 3.5,				-- how long to allow the spin to persist
					nOffsetX			= 1.0,				-- if specified, offset in the X direction
					nOffsetY			= 3.5,				-- if specified, offset in the Y direction
					nOffsetZ			= -1.0,				-- if specified, offset in the Z direction
				}
			)

		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_005)--Gauge speech: 7.7 seconds

	func_BlowGauge()

	WaitSeconds(1.0)

	--setting nuke, since escape podded ACUs don't blow up
	NIS.NukePosition(GetPos(deathUnit))

	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit				= deathUnit,	-- unit to be killed
			vizRadius			= 300,			-- optional distance for a visibility marker ring
			degreesHeading		= 155.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 35.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 150.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX			= 1.0,			-- if specified, offset in the X direction
			nOffsetY			= 1.1,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)

	ForkThread(
		function()
			--Epic Gauge Nuke WS
			NIS.EntitySpinRelative(
				{
					ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 155.0,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 35.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.01,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 150.0,		-- how close to spin relative to the unit
					nSpinDuration		= 13.0,			-- how long to allow the spin to persist
					nOffsetX			= 1.0,			-- if specified, offset in the X direction
					nOffsetY			= 4.1,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_007)--Ivan gloats (11.2 seconds)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_VICTORY_TimeDilationStart')

	ForkThread(
		function()
			WaitSeconds(3.5)
			NIS.FadeOut(4.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_009)--Ivan gloats (7.4 seconds)

	WaitSeconds(3.0)

	-- while faded out, clean up units, etc.
	NIS.ZoomTo(GetPos('NIS_VICTORY_PAN_01'), GetOrient('NIS_VICTORY_PAN_01'), 500.0, 0.0)
	func_CleanGauge()

	--Warp ACU to a position for camera work, then issue a move
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueStop( {ScenarioInfo.PLAYER_CDR} )
	Warp(ScenarioInfo.PLAYER_CDR, GetPos('NIS_VIC_Warp'))

	WaitSeconds(3.0)

	ForkThread(
		function()
			-- WS crane up over Shiva
			NIS.ZoomTo(GetPos('NIS_VICTORY_PAN_01'), GetOrient('NIS_VICTORY_PAN_01'), 0.0, 0.0)
			NIS.FadeIn(4.0)
			NIS.ZoomTo(GetPos('NIS_VICTORY_PAN_02'), GetOrient('NIS_VICTORY_PAN_02'), 0.0, 5.1)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_010) --5.1 secs (what's left of it)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_VICTORY_TimeDilationEnd')

	ForkThread(
		function()
			-- Ivan's epic walk
			IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('NIS_VIC_MoveTo'))

			NIS.ZoomTo(GetPos('NIS1_CAM_B_01'), GetOrient('NIS1_CAM_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_02'), GetOrient('NIS1_CAM_B_02'), 0.0, 10.0)

		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_015)-- First of many battles (9.4)

	ForkThread(
		function()
			--FS on Ivan
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 175.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -5.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.75,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_020)--7.4 (Ivan gets tough)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_A_03'), GetOrient('NIS1_CAM_A_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_A_04'), GetOrient('NIS1_CAM_A_04'), 0.0, 12.0)
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_030)--10.1 (Dr. Brackman turns)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C06_NIS_VICTORY_IvanSaysNo')

	ForkThread(
		function()
			--CU on Ivan
			NIS.SetFOV(75.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 175.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -5.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.75,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(3.0)
			IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
			IssueStop( {ScenarioInfo.PLAYER_CDR} )
		end
	)
	NIS.Dialog(OpDialog.C06_NIS_VICTORY_040)--3.8 seconds, "I'm destroying Shiva"

	NIS.FadeOut(2.0)
	WaitSeconds(3.0)

	NIS.PlayMovie('/movies/FMV_CYB_CLOSING')

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	NIS.PlayMovie('/movies/FMV_CREDITS_END')

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	NIS.PlayMovie('/movies/FMV_CYB_OUTRO')

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	-- wrap up without optional continued gameplay
	NIS.EndNIS_Victory(nil, false)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_HidePlayerUnits(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	-- hide the player units
	local unitList = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetListOfUnits(categories.ALLUNITS, false)
	for k, unit in unitList do
		IssueClearCommands( {unit} )
		NIS.HideUnit( unit )
	end
end

function func_OPENING_MakeWreckage(bSkip)
	---NOTE: bSkip is not needed - this function is non-latent - bfricks 12/5/09

	-- blow up the guardians
	ArmyBrains[ScenarioInfo.ARMY_ENEM01]:CompleteResearch( {'ICA_ESCAPEPOD'} )

	--Blow the heads to create wreckage
	for k, unit in ScenarioInfo.GuardianACUs do
		IssueClearCommands( {unit} )
		local platoon = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:MakePlatoon('', '')
		ArmyBrains[ScenarioInfo.ARMY_ENEM01]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
		platoon:UseAbility("escapepod")
	end

	WaitSeconds(0.5)

	--Destroy heads
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.uim0001, false)
	for k, head in unitList do
		IssueClearCommands( {head} )
		NIS.DestroyUnit( head )
	end

	--Blow up units
	for k, unit in ScenarioInfo.BlowUps do
		IssueClearCommands( {unit} )
		NIS.ForceUnitDeath( unit )
	end
end

function func_OPENING_WarpPlayerUnits01(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('Intro_NIS_MovePoint_CDR'))
		NIS.WarpUnit(ScenarioInfo.PLAYER_Engineer03, GetPos('Intro_NIS_MovePoint_Engineer3'))
		NIS.WarpUnit(ScenarioInfo.PLAYER_InitLand_Destro_01, GetPos('Intro_NIS_MovePoint_Destro01'))
		NIS.WarpUnit(ScenarioInfo.PLAYER_InitLand_Destro_02, GetPos('Intro_NIS_MovePoint_Destro02'))
		return
	end

	NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('WARP_IN_01'))
	NIS.WarpUnit(ScenarioInfo.PLAYER_Engineer03, GetPos('WARP_IN_03'))
	NIS.WarpUnit(ScenarioInfo.PLAYER_InitLand_Destro_01, GetPos('WARP_IN_02'))
	NIS.WarpUnit(ScenarioInfo.PLAYER_InitLand_Destro_02, GetPos('WARP_IN_03'))

	NIS.ShowUnit(ScenarioInfo.PLAYER_CDR)
	NIS.ShowUnit(ScenarioInfo.PLAYER_Engineer03)
	NIS.ShowUnit(ScenarioInfo.PLAYER_InitLand_Destro_01)
	NIS.ShowUnit(ScenarioInfo.PLAYER_InitLand_Destro_02)

	NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_01_ring_emit.bp', GetPos(ScenarioInfo.PLAYER_CDR))
	NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_02_glow_emit.bp', GetPos(ScenarioInfo.PLAYER_CDR))
	CreateTeleportEffects(ScenarioInfo.PLAYER_CDR)
	CreateTeleportEffects(ScenarioInfo.PLAYER_Engineer03)
	CreateTeleportEffects(ScenarioInfo.PLAYER_InitLand_Destro_01)
	CreateTeleportEffects(ScenarioInfo.PLAYER_InitLand_Destro_02)

	-- delay for the teleport to get to a good visual point
	WaitSeconds(2.0)

	-- Move CDR and Engineers ahead (2 eng will build stuff)
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('Intro_NIS_MovePoint_CDR'))
	IssueMove({ScenarioInfo.PLAYER_Engineer03}, GetPos('Intro_NIS_MovePoint_Engineer3'))

	-- Destroyers
	IssueMove({ScenarioInfo.PLAYER_InitLand_Destro_01}, GetPos('Intro_NIS_MovePoint_Mid01'))
	IssueMove({ScenarioInfo.PLAYER_InitLand_Destro_01}, GetPos('Intro_NIS_MovePoint_Destro01'))
	IssueMove({ScenarioInfo.PLAYER_InitLand_Destro_02}, GetPos('Intro_NIS_MovePoint_Mid02'))
	IssueMove({ScenarioInfo.PLAYER_InitLand_Destro_02}, GetPos('Intro_NIS_MovePoint_Destro02'))
end

function func_OPENING_MoveGauge01(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.GAUGE_CDR, GetPos('GAUGE_APPROACH_02'))
		return
	end

	IssueMove( {ScenarioInfo.GAUGE_CDR}, GetPos('GAUGE_APPROACH_02') )
end

function func_OPENING_WarpPlayerUnits02(bSkip)
	if bSkip then
		-- if we are skipping, just create the turret and radar and move on
		import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'PLAYER_BUILD_Turret01')
		import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'PLAYER_BUILD_Radar')

		-- warp the rest of the units
		NIS.WarpGroup(ScenarioInfo.PLAYER_Group01_Front, GetPos('Intro_NIS_MovePoint_FrontGroup01'))
		NIS.WarpGroup(ScenarioInfo.PLAYER_Group02_Front, GetPos('Intro_NIS_MovePoint_FrontGroup02'))
		NIS.WarpGroup(ScenarioInfo.PLAYER_Group01_Back, GetPos('Intro_NIS_MovePoint_BackGroup01'))
		NIS.WarpGroup(ScenarioInfo.PLAYER_Group02_Back, GetPos('Intro_NIS_MovePoint_BackGroup02'))
		return
	end

	-- reveal the last two units from the player's initial group
	NIS.ShowUnit(ScenarioInfo.PLAYER_Engineer01)
	NIS.ShowUnit(ScenarioInfo.PLAYER_Engineer02)

	local unitData1 = import('/lua/sim/ScenarioUtilities.lua').FindUnit('PLAYER_BUILD_Turret01', Scenario.Armies['ARMY_PLAYER'].Units)
	ArmyBrains[ScenarioInfo.ARMY_PLAYER]:BuildStructure(ScenarioInfo.PLAYER_Engineer01, unitData1.type, { unitData1.Position[1], unitData1.Position[3], 0}, false)

	local unitData2 = import('/lua/sim/ScenarioUtilities.lua').FindUnit('PLAYER_BUILD_Radar', Scenario.Armies['ARMY_PLAYER'].Units)
	ArmyBrains[ScenarioInfo.ARMY_PLAYER]:BuildStructure(ScenarioInfo.PLAYER_Engineer02, unitData2.type, { unitData2.Position[1], unitData2.Position[3], 0}, false)

	IssueClearCommands(ScenarioInfo.PLAYER_Group01_Front)
	for k, unit in ScenarioInfo.PLAYER_Group01_Front do
		NIS.WarpUnit(unit, GetPos('WARP_IN_01'))
		WaitSeconds(0.1)
		NIS.ShowUnit( unit )
		CreateTeleportEffects(unit)
	end
	IssueMove(ScenarioInfo.PLAYER_Group01_Front, GetPos('Intro_NIS_MovePoint_Mid01'))
	IssueMove(ScenarioInfo.PLAYER_Group01_Front, GetPos('Intro_NIS_MovePoint_FrontGroup01'))

	WaitSeconds(0.5)

	IssueClearCommands(ScenarioInfo.PLAYER_Group02_Front)
	for k, unit in ScenarioInfo.PLAYER_Group02_Front do
		NIS.WarpUnit(unit, GetPos('WARP_IN_02'))
		WaitSeconds(0.1)
		NIS.ShowUnit( unit )
		CreateTeleportEffects(unit)
	end
	IssueMove(ScenarioInfo.PLAYER_Group02_Front, GetPos('Intro_NIS_MovePoint_Mid02'))
	IssueMove(ScenarioInfo.PLAYER_Group02_Front, GetPos('Intro_NIS_MovePoint_FrontGroup02'))

	WaitSeconds(0.5)

	IssueClearCommands(ScenarioInfo.PLAYER_Group01_Back)
	for k, unit in ScenarioInfo.PLAYER_Group01_Back do
		NIS.WarpUnit(unit, GetPos('WARP_IN_03'))
		WaitSeconds(0.1)
		NIS.ShowUnit( unit )
		CreateTeleportEffects(unit)
	end
	IssueMove(ScenarioInfo.PLAYER_Group01_Back, GetPos('Intro_NIS_MovePoint_Mid01'))
	IssueMove(ScenarioInfo.PLAYER_Group01_Back, GetPos('Intro_NIS_MovePoint_BackGroup01'))

	WaitSeconds(0.5)

	IssueClearCommands(ScenarioInfo.PLAYER_Group02_Back)
	for k, unit in ScenarioInfo.PLAYER_Group02_Back do
		NIS.WarpUnit(unit, GetPos('WARP_IN_03'))
		WaitSeconds(0.1)
		NIS.ShowUnit( unit )
		CreateTeleportEffects(unit)
	end
	IssueMove(ScenarioInfo.PLAYER_Group02_Back, GetPos('Intro_NIS_MovePoint_Mid02'))
	IssueMove(ScenarioInfo.PLAYER_Group02_Back, GetPos('Intro_NIS_MovePoint_BackGroup02'))
end

function func_OPENING_StopCDR(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueStop({ScenarioInfo.PLAYER_CDR})
end

function func_OPENING_PlayerAdvance(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	-- Land ahead to their point
	IssueFormMove( ScenarioInfo.PLAYER_Group01_Front,GetPos( 'Intro_NIS_MovePoint_FrontGroup01' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.PLAYER_Group01_Back,GetPos( 'Intro_NIS_MovePoint_BackGroup01' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.PLAYER_Group02_Front,GetPos( 'Intro_NIS_MovePoint_FrontGroup02' ), 'AttackFormation', 90 )
	IssueFormMove( ScenarioInfo.PLAYER_Group02_Back,GetPos( 'Intro_NIS_MovePoint_BackGroup02' ), 'AttackFormation', 90 )

	-- Move CDR and Engineers ahead (2 eng will build stuff)
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('Intro_NIS_MovePoint_CDR'))
	IssueMove({ScenarioInfo.PLAYER_Engineer03}, GetPos('Intro_NIS_MovePoint_Engineer3'))

	-- Destroyers
	IssueMove({ScenarioInfo.PLAYER_InitLand_Destro_01}, GetPos('Intro_NIS_MovePoint_Destro01'))
	IssueMove({ScenarioInfo.PLAYER_InitLand_Destro_02}, GetPos('Intro_NIS_MovePoint_Destro02'))
end

function func_OPENING_MoveGauge02(bSkip)
	---NOTE: bSkip is not needed - this function is non-latent - bfricks 12/5/09

	IssueMove( {ScenarioInfo.GAUGE_CDR}, GetPos('GAUGE_FINAL_POSITION') )
end


function func_BlowGauge()
	if ScenarioInfo.ARMY_ENEM01 and ScenarioInfo.GAUGE_CDR then
		local brain = ArmyBrains[ScenarioInfo.ARMY_ENEM01]

		if brain then
			brain:CompleteResearch( {'CCA_ESCAPEPOD'} )
			IssueClearCommands( {ScenarioInfo.GAUGE_CDR} )
			local platoon = brain:MakePlatoon('', '')

			if platoon then
				brain:AssignUnitsToPlatoon( platoon, {ScenarioInfo.GAUGE_CDR}, 'Attack', 'AttackFormation' )
				platoon:UseAbility("escapepod")

				WaitSeconds(0.5)

				local unitList = brain:GetListOfUnits(categories.ucm0001, false)
				for k, head in unitList do
					if head and not head:IsDead() then
						import('/lua/sim/ScenarioFramework.lua').ProtectUnit(head)
						IssueClearCommands( {head} )
						IssueMove({head}, GetPos('zz_SUBCHAIN_PlayerBaseArea_ForLand_15'))
					else
						WARN('WARNING: Blow Gauge - no Head? - pass to Campaign Design ASAP - bfricks 1/13/2010.')
					end
				end
			else
				WARN('WARNING: Blow Gauge - no platoon? - pass to Campaign Design ASAP - bfricks 1/13/2010.')
			end
		else
			WARN('WARNING: Blow Gauge - no brain? - pass to Campaign Design ASAP - bfricks 1/13/2010.')
		end
	else
		WARN('WARNING: Blow Gauge - no army? no Gauge? - pass to Campaign Design ASAP - bfricks 1/13/2010.')
	end
end

function func_CleanGauge()
	-- Destroy head
	local head = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ucm0001, false)
	for k, unit in head do
		NIS.DestroyUnit(unit)
	end

	-- Blow up Gauge's army
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS, false)
	for k, unit in unitList do
		NIS.ForceUnitDeath(unit)
	end

	-- Blow up artifact units
	local artList = ArmyBrains[ScenarioInfo.ARMY_ART]:GetListOfUnits(categories.ALLUNITS, false)
	for k, unit in artList do
		NIS.ForceUnitDeath(unit)
	end
end

---------------------------------------------------------------------
-- FMV ONLY FUNCTIONS:
---------------------------------------------------------------------
function funcTerraformerFlyby()

	local UserConRequest = import('/lua/system/Utilities.lua').UserConRequest

	UserConRequest('ren_ui')
	UserConRequest('ui_rendericons')
	UserConRequest('ui_renderunitbars')
	UserConRequest('shadowfidelity 4')
	UserConRequest('ren_skydome')
	UserConRequest('ren_clearcolor 0x00ff00')--GreenScreen
	UserConRequest('sallysheers')

	NIS.StartMovieCapture(15)

	NIS.ZoomTo(GetPos('SWANSON_NIS_01'), GetOrient('SWANSON_NIS_01'), 40.0, 0.0)
	NIS.ZoomTo(GetPos('SWANSON_NIS_02'), GetOrient('SWANSON_NIS_02'), 40.0, 6.0)

	NIS.ZoomTo(GetPos('SWANSON_NIS_03'), GetOrient('SWANSON_NIS_03'), 40.0, 6.0)
	NIS.ZoomTo(GetPos('SWANSON_NIS_04'), GetOrient('SWANSON_NIS_04'), 40.0, 6.0)

	NIS.ZoomTo(GetPos('SWANSON_NIS_05'), GetOrient('SWANSON_NIS_05'), 40.0, 6.0)
	NIS.ZoomTo(GetPos('SWANSON_NIS_06'), GetOrient('SWANSON_NIS_06'), 40.0, 6.0)

	NIS.ZoomTo(GetPos('SWANSON_NIS_07'), GetOrient('SWANSON_NIS_07'), 40.0, 6.0)
	NIS.ZoomTo(GetPos('SWANSON_NIS_08'), GetOrient('SWANSON_NIS_08'), 40.0, 6.0)

	NIS.ZoomTo(GetPos('SWANSON_NIS_09'), GetOrient('SWANSON_NIS_09'), 40.0, 6.0)

	NIS.EndMovieCapture()
	-----------------------
	UserConRequest('ren_ui')

end
