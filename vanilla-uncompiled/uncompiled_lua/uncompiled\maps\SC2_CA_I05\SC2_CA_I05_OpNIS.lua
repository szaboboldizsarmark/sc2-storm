---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_I05/SC2_CA_I05_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_I05/SC2_CA_I05_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_I05/SC2_CA_I05_script.lua')
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

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('I05_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.I05_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.I05_NIS_OP_SETUP_020)
				NIS.DialogNoWait(OpDialog.I05_NIS_OP_SETUP_025)
				NIS.DialogNoWait(OpDialog.I05_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.I05_NIS_OPENING_010,
			OpDialog.I05_NIS_OPENING_015,
			OpDialog.I05_NIS_OPENING_020,
			OpDialog.I05_NIS_OPENING_030,
			OpDialog.I05_NIS_OPENING_035,
			OpDialog.I05_NIS_OPENING_040,
			OpDialog.I05_NIS_OP_SETUP_010,
			OpDialog.I05_NIS_OP_SETUP_020,
			OpDialog.I05_NIS_OP_SETUP_025,
			OpDialog.I05_NIS_OP_SETUP_END,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('INTRONIS_Init_VisLoc', 130)
	NIS.CreateVizMarker('P1_Intro_NIS_VisLoc01', 60)
	NIS.CreateVizMarker('P1_ALLY01_AirAttack_Route03_01_18', 100)
	NIS.CreateVizMarker('P1_ALLY01_AirAttack_Route03_01_01', 100)
	NIS.CreateVizMarker('ARMY_ENEM02', 150)

	---NOTE: these two locations were the ends of platforms with Tech Caches - and as such - I want to not reveal if at all possible
	---			please consult with me before un-commenting these - bfricks 12/6/09
	---NIS.CreateVizMarker('P1_ALLY01_AirAttack_Route03_01_16', 100)
	---NIS.CreateVizMarker('P1_ALLY01_AirAttack_Route03_01_19', 100)

	-- spawn transports loaded with the CDR and the player starting units
	func_OPENING_PlayerTransportSequence()

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('I05_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance and a start position
	NIS.StartNIS_Opening('NIS1_CAM_A_01', 0.0, 'NIS1_CAM_A_01', 70.0)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	-- Final VO timing: 9.1 seconds
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_A_02'), GetOrient('NIS1_CAM_A_02'), 00.0, 7.0)
			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_01'), GetOrient('NIS1_CAM_C_01'), 00.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_02'), GetOrient('NIS1_CAM_C_02'), 00.0, 6.0)
		end
	)
	WaitSeconds(4.0)
	NIS.Dialog(OpDialog.I05_NIS_OPENING_010)

	-- Final VO timing: 13.0 seconds
	ForkThread(
		function()
			NIS.SetFOV(55)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -2.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 8.5,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.90,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_OPENING_015)

	-- Final VO timing: 12.2 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_01'), GetOrient('NIS1_CAM_B_01'), 20.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_02'), GetOrient('NIS1_CAM_B_02'), 20.0, 13.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_OPENING_020)

	-- Final VO timing: 9.4 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS_CITY_PAN_01'), GetOrient('NIS_CITY_PAN_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CITY_PAN_02'), GetOrient('NIS_CITY_PAN_02'), 30.0, 14.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_OPENING_030)

	WaitSeconds(1.0)

	NIS.Dialog(OpDialog.I05_NIS_OPENING_035)

	-- Final VO timing: 8.3 seconds
	-- This needs to be... something else
	ForkThread(
		function()
			NIS.SetFOV(65.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_03'), GetOrient('NIS1_CAM_D_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_04'), GetOrient('NIS1_CAM_D_04'),	50.0, 10.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_OPENING_040)

	-- Final VO timing: 10.3 seconds
	ForkThread(
		function()
			NIS.SetFOV(65.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_01'), GetOrient('NIS1_CAM_E_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_02'), GetOrient('NIS1_CAM_E_02'),	50.0, 11.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_OP_SETUP_010)

	-- Final VO timing: 15.5 seconds
	-- Space Temple reveal
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_H_01'), GetOrient('NIS1_CAM_H_01'), 00.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_H_02'), GetOrient('NIS1_CAM_H_02'), 00.0, 8.0)

			NIS.ZoomTo(GetPos('NIS1_CAM_H_03'), GetOrient('NIS1_CAM_H_03'), 00.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_H_04'), GetOrient('NIS1_CAM_H_04'), 00.0, 8.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_OP_SETUP_020)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I05_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	-- Final VO timing: 4.0 seconds
	NIS.DialogNoWait(OpDialog.I05_NIS_OP_SETUP_025)

	NIS.DialogNoWait(OpDialog.I05_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.I05_NIS_VICTORY_010,
			OpDialog.I05_NIS_VICTORY_015,
			OpDialog.I05_NIS_VICTORY_020,
			OpDialog.I05_NIS_VICTORY_050,
			OpDialog.I05_NIS_VICTORY_052,
			OpDialog.I05_NIS_VICTORY_055,
			OpDialog.I05_NIS_VICTORY_060,
			OpDialog.I05_NIS_VICTORY_062,
			OpDialog.I05_NIS_VICTORY_064,
			OpDialog.I05_NIS_VICTORY_066,
			OpDialog.I05_NIS_VICTORY_068,
			OpDialog.I05_NIS_VICTORY_070,
			OpDialog.I05_NIS_VICTORY_080,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I05_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit				= deathUnit,	-- unit to be killed
			vizRadius			= 300,			-- optional distance for a visibility marker ring
			degreesHeading		= 160.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 5.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 100.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 10.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)
	WaitSeconds(1.0)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_010)

	WaitSeconds(2.0)

	--Show Gauge
	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.ALLY01_CDR), GetOrient('GAUGE_CAMERA_01'), 40.0, 0.0)
			WaitSeconds(2.0)
			NIS.ZoomTo(GetPos('GAUGE_CAMERA_02'), GetOrient('GAUGE_CAMERA_02'), 00.0, 8.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_015)

	NIS.Dialog(OpDialog.I05_NIS_VICTORY_020)

	NIS.NukePosition('NIS_FINAL_NUKES_10')
	func_VICTORY_BaseDestruction('NIS_FINAL_NUKES_10')

	WaitSeconds(2.0)

	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.EntitySpinRelative(
				{
					ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 170.0,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.003,		-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 350.0,		-- how close to spin relative to the unit
					nSpinDuration		= 10.0,			-- how long to allow the spin to persist
					nOffsetX			= 10.0,			-- if specified, offset in the X direction
					nOffsetY			= 0.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	WaitSeconds(6.0)

	func_VICTORY_GaugeEscapeBeacon()

	ForkThread(
		function()
			WaitSeconds(1.5)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ALLY01_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 170.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 7.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.10,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_050)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I05_NIS_VICTORY_NukeLaunch')

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('CAM_NUKE_BUILDING_01'), GetOrient('CAM_NUKE_BUILDING_01'), -30.0, 0.0)
			NIS.ZoomTo(GetPos('CAM_NUKE_BUILDING_01'), GetOrient('CAM_NUKE_BUILDING_01'), 0.0, 20.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_052)

	NIS.Dialog(OpDialog.I05_NIS_VICTORY_055)

	NIS.NukePosition('NIS_FINAL_NUKES_01', 0, false)
	NIS.NukePosition('NIS_FINAL_NUKES_07', 0, false)

	WaitSeconds(3.0)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_060)--3.5

	NIS.NukePosition('NIS_FINAL_NUKES_05', 0, false)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_062)--6.1

	NIS.NukePosition('NIS_FINAL_NUKES_08', 0, false)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_064)--4.2

	NIS.NukePosition('NIS_FINAL_NUKES_02', 0, false)
	NIS.NukePosition('NIS_FINAL_NUKES_03', 0, false)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_066)--5.5

	NIS.Dialog(OpDialog.I05_NIS_VICTORY_068)--7.4

	--Gauge exits
	func_VICTORY_GaugeEscapeMove()

	-- Final VO timing: 2.9 seconds
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_BEACON_EXIT_02'), GetOrient('NIS_BEACON_EXIT_02'), 00.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_BEACON_EXIT_01'), GetOrient('NIS_BEACON_EXIT_01'), 00.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_070)

	-- Gauge Teleport
	func_VICTORY_GaugeEscapeTeleport()
	WaitSeconds(2.0)

	-- Make sure we're not moving
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})

	-- Final VO timing: 9.8 seconds
	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 15.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I05_NIS_VICTORY_080)

	WaitSeconds(2.0)

	NIS.EndNIS_Victory(nil, true)
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

	-- group2
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_Group2,				-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_Group2Transport,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_02',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group02_Formup',		-- optional destination for the group to be moved to after being dropped-off
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
	IssueMove( {eng01}, GetPos( 'PLAYER_Engineer_Formup01' ) )

	local eng02 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_PLAYER]['PLAYER_ENG02']
	IssueClearCommands( {eng02} )
	IssueMove( {eng02}, GetPos( 'PLAYER_Engineer_Formup02' ) )
end

function func_VICTORY_BaseDestruction(strMarker)
	local pos = GetPos(strMarker)

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_PLAYER],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 100, true, 90001, 90001, brainList)
end

function func_VICTORY_GaugeEscapeBeacon()
	LOG('----- func_VICTORY_GaugeEscapeBeacon: creating beacon.')
	ScenarioInfo.GaugeNISBeacon = NIS.CreateNISOnlyUnit('ARMY_ENEM01', 'GaugeNIS_Beacon')
end

function func_VICTORY_GaugeEscapeMove()
	Warp( ScenarioInfo.ALLY01_CDR, GetPos('GAUGE_TEMPLE') )
	IssueClearCommands({ScenarioInfo.ALLY01_CDR})
	IssueFormMove({ScenarioInfo.ALLY01_CDR}, GetPos(ScenarioInfo.GaugeNISBeacon), 'AttackFormation', 0)
end

function func_VICTORY_GaugeEscapeTeleport()
	IssueClearCommands({ScenarioInfo.ALLY01_CDR})
	CreateTeleportEffects( ScenarioInfo.ALLY01_CDR )
	NIS.DestroyUnit(ScenarioInfo.ALLY01_CDR)
end