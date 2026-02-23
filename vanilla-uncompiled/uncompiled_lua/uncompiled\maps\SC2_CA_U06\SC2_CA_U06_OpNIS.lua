---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_U06/SC2_CA_U06_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_U06/SC2_CA_U06_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_U06/SC2_CA_U06_script.lua')
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
				func_OPENING_Structure_Blow_Up(true)
				func_OPENING_AllyCDRSetup(true)
				func_OPENING_TransportWarp(true)
				func_OPENING_TransportDestructionPart01(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('U06_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.U06_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.U06_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.U06_NIS_OPENING_010,
			OpDialog.U06_NIS_OPENING_020,
			OpDialog.U06_NIS_OPENING_030,
			OpDialog.U06_NIS_OPENING_040,
			OpDialog.U06_NIS_OP_SETUP_010,
			OpDialog.U06_NIS_OP_SETUP_END,
		}
	)

	-- spawn transports loaded with the CDR and the player starting units
	---NOTE: this call creates units that are not properly managed by the NIS system - because they are created outside the
	---			scope of the actual NIS - in this case, it seems fine, but ideally we should not do things this way - bfricks 11/29/09
	func_OPENING_PlayerTransportSequence()
	WaitSeconds(2.0)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('U06_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('CAM_OPENING', 600.0)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	ForkThread(
		function()
			NIS.SetFOV(15.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.INTRONIS_CommanderTransport,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= -165.0,									-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,										-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 55.0,										-- how close to track relative to the unit
					nTrackToDuration	= 5.0,										-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= -2.0,										-- if specified, offset in the X direction
					nOffsetY			= 0.0,										-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,										-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(5.0)
			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS_CAM_A_01'), GetOrient('NIS_CAM_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_A_02'), GetOrient('NIS_CAM_A_02'), 0.0, 6.5)
		end
	)

	-- Approach/Graveyard	--Final VO: 11.1 seconds
	NIS.Dialog(OpDialog.U06_NIS_OPENING_010)

	-- Land Structure Destruction for NIS
	ForkThread(func_OPENING_Structure_Blow_Up)

	-- slight delay to prevent fake structure pop-in.
	WaitSeconds(0.5)

	ForkThread(
		function()
			func_OPENING_AllyCDRSetup()

			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS_CAM_B_01'), GetOrient('NIS_CAM_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_B_02'), GetOrient('NIS_CAM_B_02'), 0.0, 4.0)

			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ALLY_CDR,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= -175.0,					-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 0.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,						-- how close to track relative to the unit
					nTrackToDuration	= 0.0,						-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,						-- if specified, offset in the X direction
					nOffsetY			= 1.0,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,						-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(4.6)
		end
	)

	-- Talk to Greer	--Final VO: 8.6 seconds
	NIS.Dialog(OpDialog.U06_NIS_OPENING_020)

	func_OPENING_TransportWarp()

	-- part 1 of the transport Destruction for NIS
	ForkThread(func_OPENING_TransportDestructionPart01)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_CAM_C_01'), GetOrient('NIS_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_C_02'), GetOrient('NIS_CAM_C_02'), 0.0, 5.0)

			NIS.SetFOV(35.0)
			NIS.ZoomTo(GetPos('NIS_CAM_E_01'), GetOrient('NIS_CAM_E_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_E_02'), GetOrient('NIS_CAM_E_02'), 0.0, 1.7)
		end
	)

	-- Incoming air
	NIS.Dialog(OpDialog.U06_NIS_OPENING_030)

	-- slight delay to showcase transport destruction
	WaitSeconds(4.0)

	ForkThread(
		function()
			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS_CAM_D_01'), GetOrient('NIS_CAM_D_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_D_02'), GetOrient('NIS_CAM_D_02'), 0.0, 4.7)

			NIS.SetFOV(35.0)
			NIS.ZoomTo(GetPos('NIS_CAM_F_01'), GetOrient('NIS_CAM_F_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_F_02'), GetOrient('NIS_CAM_F_02'), 0.0, 5.0)
		end
	)

	-- Taking fire 	--Final VO: 9.7 seconds
	NIS.Dialog(OpDialog.U06_NIS_OPENING_040)

	--Set off nuke/substation blows
	NIS.NukePosition('NIS_NUKE_LOCATION_01')
	WaitSeconds(1.0)

	ForkThread(
		function()
			NIS.SetFOV(85.0)
			NIS.ZoomTo(GetPos('NIS_NUKE_CAM_01'), GetOrient('NIS_NUKE_CAM_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_NUKE_CAM_01'), GetOrient('NIS_NUKE_CAM_01'), -15.0, 4.5)
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_CAM_G_01'), GetOrient('NIS_CAM_G_01'), 0.0, 0.0)
		end
	)

	-- 6 seconds (game over, man)
	NIS.Dialog(OpDialog.U06_NIS_OP_SETUP_010)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U06_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	-- 14.7 seconds (explaining reactor)
	NIS.DialogNoWait(OpDialog.U06_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_REVEAL_ENEMY:
---------------------------------------------------------------------
function NIS_REVEAL_ENEMY()

	NIS.PreloadDialogData(
		{
			OpDialog.U06_NIS_REVEAL_ENEMY_010,
			OpDialog.U06_NIS_REVEAL_ENEMY_020,
			OpDialog.U06_NIS_REVEAL_ENEMY_OP_SETUP_10,
			OpDialog.U06_NIS_REVEAL_ENEMY_OP_SETUP_20,
			OpDialog.U06_NIS_REVEAL_ENEMY_OP_SETUP_30,
			OpDialog.U06_NIS_REVEAL_RODGERS,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('NIS_REVEAL_ENEMY_VisLoc_01', 350)
	NIS.CreateVizMarker('NIS_REVEAL_ENEMY_WestCamp_Vis_Marker', 350)
	NIS.CreateVizMarker('NIS_REVEAL_ENEMY_EastCamp_Vis_Marker', 350)

	-- trigger music system for t his transition point
	NIS.PlayMusicEventByHandle('U06_NIS_REVEAL_ENEMY_Start')

	-- use StartNIS_MidOp to expand the playable area and allow a smooth camera reveal
	NIS.StartNIS_MidOp('P2_Playable_Area')

	WaitSeconds(1.0)

	-- clearing Ally CDR commands, so he does what we want precisely
	func_REVEAL_ENEMY_SetupAllyCDR()

	-- spawn transports loaded unit that will attack the Ally Commander
	func_REVEAL_ENEMY_Transports()

	--Final VO: 7.8 seconds
	ForkThread(
		function()
			NIS.SetFOV(65.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_C_01'), GetOrient('NIS2_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_C_02'), GetOrient('NIS2_CAM_C_02'), 0.0, 7.8)
		end
	)
	NIS.Dialog(OpDialog.U06_NIS_REVEAL_ENEMY_010)

	--Final VO: 4.2 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('P1_ENDNIS_NukeLocation_Marker_01'), GetOrient('P1_ENDNIS_NukeLocation_Marker_01'), 20.0, 0.0)
			NIS.ZoomTo(GetPos('P1_ENDNIS_NukeLocation_Marker_01'), GetOrient('P1_ENDNIS_NukeLocation_Marker_01'), 120.0, 7.2)
			func_REVEAL_ENEMY_NukeCommanderSequence()
		end
	)
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U06_NIS_REVEAL_ENEMY_GreerDies')
	NIS.Dialog(OpDialog.U06_NIS_REVEAL_ENEMY_020)

	-- holding on nuke for dramatic affect
	WaitSeconds(6.0)

	-- Warp player units and CDR to new base area.
	func_REVEAL_ENEMY_WarpPlayerUnits()

	-- Swap ally units to player
	func_REVEAL_ENEMY_SwapUnits()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U06_NIS_REVEAL_ENEMY_FortressReveal')

	NIS.CreateArrow('MidOp_CreateArrows_01', 5.0)
	NIS.CreateArrow('MidOp_CreateArrows_02', 5.0)
	NIS.CreateArrow('MidOp_CreateArrows_03', 5.0)

	--Final VO: 5.3 seconds
	ForkThread(
		function()
			-- Next shot: MFS on Commander
			NIS.SetFOV(75.0)
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 190.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -4.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= -0.001,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 15.0,							-- how close to spin relative to the unit
					nSpinDuration		= 5.3,							-- how long to allow the spin to persist
					nOffsetX			= -5.0,							-- if specified, offset in the X direction
					nOffsetY			= 4.4,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U06_NIS_REVEAL_ENEMY_OP_SETUP_10)

	--Final VO: 8.3 seconds
	ForkThread(
		function()
			-- Next shot: main reactor area in the newly revealed playable area
			NIS.SetFOV (45.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_E_01'), GetOrient('NIS2_CAM_E_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_E_02'), GetOrient('NIS2_CAM_E_02'), 0.0, 7.3)
			WaitSeconds(1.0)
		end
	)
	NIS.Dialog(OpDialog.U06_NIS_REVEAL_ENEMY_OP_SETUP_20)

	--Final VO: 1.9 seconds
	ForkThread(
		function()
			-- Next shot: main reactor area in the newly revealed playable area
			NIS.SetFOV(60.0)
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -1.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= -0.001,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 8.0,							-- how close to spin relative to the unit
					nSpinDuration		= 2.9,							-- how long to allow the spin to persist
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 4.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U06_NIS_REVEAL_ENEMY_OP_SETUP_30)
	WaitSeconds(1.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U06_NIS_REVEAL_ENEMY_End')

	-- use EndNIS_MidOp and restore to the player
	---NOTE: intentionally flush the intel - bfricks 10/31/09
	NIS.EndNIS_MidOp(true)

	NIS.DialogNoWait(OpDialog.U06_NIS_REVEAL_RODGERS)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.U06_NIS_VICTORY_010,
			OpDialog.U06_NIS_VICTORY_020,
			OpDialog.U06_NIS_VICTORY_030,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U06_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	NIS.DisableEaseInOut()

	-- make the reactor unit into and entity
	position	= deathUnit:GetPosition()
	orientation	= deathUnit:GetOrientation()
	local reactor = NIS.CreateNISOnlyEntity(position, orientation)

	reactor:ShakeCamera(5.0, 5.0, 1.0, 8.0)

	--Final VO: 5.2 seconds
	ForkThread(
		function()
			-- Reactor reveal
			NIS.SetFOV(80.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_1_01'), GetOrient('NIS_VIC_CAM_SHOT_1_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_1_02'), GetOrient('NIS_VIC_CAM_SHOT_1_02'), 0.0, 5.2)
		end
	)
	--WaitSeconds(3.0)
	NIS.Dialog(OpDialog.U06_NIS_VICTORY_010)

	-- clear and stop the player ACU
	func_VICTORY_ClearAndStopPlayerCDR()

	--Final VO: 25.4 seconds
	ForkThread(
		function()
			-- Wide battlefield shot
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_3_01'), GetOrient('NIS_VIC_CAM_SHOT_3_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_3_02'), GetOrient('NIS_VIC_CAM_SHOT_3_02'), 0.0, 4.0)

			-- Maddox CU Zoom
			local pos = GetPos(ScenarioInfo.PLAYER_CDR)
			local heading = ScenarioInfo.PLAYER_CDR:GetHeading()
			NIS.ZoomTo({pos[1]+2, pos[2]+ 4.2, pos[3]-1}, {-heading, 0.1, 0.0}, 12.0, 0.0)
			NIS.ZoomTo({pos[1]+2, pos[2]+ 4.2, pos[3]-1}, {-heading, 0.1, 0.3}, 6.0, 7.0)

			-- Maddox about to do something stupid
			NIS.ZoomTo(GetPos('NIS_VIC_A_01'), GetOrient('NIS_VIC_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_A_02'), GetOrient('NIS_VIC_A_02'), 0.0, 7.0)

			-- Maddox medium
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 190.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= -0.001,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 15.0,							-- how close to spin relative to the unit
					nSpinDuration		= 4.4,							-- how long to allow the spin to persist
					nOffsetX			= -3.0,							-- if specified, offset in the X direction
					nOffsetY			= 3.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)

			-- trigger music system for this transition point
			NIS.PlayMusicEventByHandle('U06_NIS_VICTORY_FadeStart')

			-- Maddox medium
			NIS.AddFade(
				{
					nFadeIn 		= 0.0,						-- Number of seconds to fade in.
					nFadeOut	 	= 1.0,						-- Number of seconds to fade out.
					sColor			= 'ff000000',				-- Hex color (as string) for fade color.
					nShotDurration 	= 3.0,						-- Length of the shot in seconds.
					fcnCamBehavior 	= NIS.EntitySpinRelative,	-- The function that controls the camera behavior.
					tblParams 		= {
						{
							ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
							degreesHeading		= 170.0,						-- heading offset relative to the unit (180.0 == frontside)
							degreesPitch		= 10.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
							nSpinRate			= -0.001,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
							nSpinDistance		= 5.5,							-- how close to spin relative to the unit
							nSpinDuration		= 3.0,							-- how long to allow the spin to persist
							nOffsetX			= 0.0,							-- if specified, offset in the X direction
							nOffsetY			= 4.5,							-- if specified, offset in the Y direction
							nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
						}
					}
				}
			)

		end
	)
	--WaitSeconds(3.0)
	NIS.Dialog(OpDialog.U06_NIS_VICTORY_020)

	-- Spawns troops to finish off Rodgers, kills off remaining enemy units
	NIS_VICTORY_TroopSpawn()

	NIS.FadeIn(1.0)

	ForkThread(
		function()
			WaitSeconds(5.0)
			NIS.NukePosition('P1_TransAttack_Return_Marker')
			WaitSeconds(0.5)
			NIS.NukePosition('P2_ENEM01_EastAirCamp_SwitchPatrol_05')
			WaitSeconds(0.5)
			NIS.NukePosition('P2_ENEM01_AirCampWest_Base_Marker')
			WaitSeconds(0.5)
			NIS.NukePosition('P2_TransHeavy_AltLanding_01')
			NIS.NukePosition('P2_ENEM01_EastAirCamp_AirPatrol_01_07')
			WaitSeconds(0.0)
			NIS.NukePosition('P2_ReactorArea_Vis_Marker')
		end
	)
	----Final VO: 26.1 seconds
	ForkThread(
		function()
			-- Teleports ACU for NIS ending
			func_VICTORY_MovePlayerCDR()

			-- Spawns a transport to pick up CDR
			func_VICTORY_AirMoveToTarget()

			NIS.SetFOV(70.0)
			NIS.ZoomTo(GetPos('NIS_VIC_B_01'), GetOrient('NIS_VIC_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_B_02'), GetOrient('NIS_VIC_B_02'), 0.0, 6.0)

			NIS.ZoomTo(GetPos('NIS_VIC_C_01'), GetOrient('NIS_VIC_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_C_02'), GetOrient('NIS_VIC_C_02'), 0.0, 6.0)

			NIS.SetFOV(55.0)
			NIS.ZoomTo(GetPos('NIS_VIC_D_01'), GetOrient('NIS_VIC_D_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_D_02'), GetOrient('NIS_VIC_D_02'), 0.0, 6.0)

			NIS.SetFOV(70.0)
			func_VICTORY_AirTransportPickup()
			NIS.ZoomTo(GetPos('NIS_VIC_E_01'), GetOrient('NIS_VIC_E_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_E_02'), GetOrient('NIS_VIC_E_02'), 0.0, 6.0)

			NIS.SetFOV(30.0)
			NIS.ZoomTo(GetPos('NIS_VIC_F_01'), GetOrient('NIS_VIC_F_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_F_02'), GetOrient('NIS_VIC_F_02'), 0.0, 6.0)
		end
	)

	NIS.Dialog(OpDialog.U06_NIS_VICTORY_030)

	-- Pause for shot of Fatboy blasting reactor
	WaitSeconds(5.0)

	-- destroy reactor
	NIS.ForceUnitDeath(deathUnit)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('OP_HOLDING_SOUNDLESS')

	NIS.FadeOut(0.0)
	NIS.PlayMovie('/movies/FMV_UEF_CLOSING')

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
function func_OPENING_PlayerTransportSequence(bSkip)
	-- group1
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_Group1,				-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_Group1Transport,	-- unit handle for the actual transport
			approachChain			= 'NIS_INTRO_TRANSPORT_CHAIN_02',			-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker_01',	-- optional destination for where the transports will fly-away
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
			approachChain			= 'NIS_INTRO_TRANSPORT_CHAIN_03',			-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_02',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker_02',	-- optional destination for where the transports will fly-away
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
			approachChain			= 'NIS_INTRO_TRANSPORT_CHAIN_01',			-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_03',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker_03',	-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_CommanderDestination_Marker',	-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)

	-- early out at this point
	if bSkip then
		return
	end

	--Death Transports
	ScenarioInfo.INTRONIS_Group4Transport = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_04')
	ScenarioInfo.INTRONIS_Group5Transport = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_05')
	ScenarioInfo.INTRONIS_Group6Transport = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_06')
	ScenarioInfo.INTRONIS_Group7Transport = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_07')
	ScenarioInfo.INTRONIS_Group8Transport = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_08')

	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/22/09
	---			this specific case is only safe because these are throw-away units - bfricks 11/29/09

	-- make sure the transport movement is set to the needed value for our NIS timing
	local currSpeed = ScenarioInfo.INTRONIS_Group4Transport:GetBlueprint().Air.MaxAirspeed
	local destSpeed = 15.0
	local multSpeed = destSpeed/currSpeed

	-- modify the speeds
	ScenarioInfo.INTRONIS_Group4Transport:SetSpeedMult(multSpeed)
	ScenarioInfo.INTRONIS_Group4Transport:SetNavMaxSpeedMultiplier(multSpeed)

	ScenarioInfo.INTRONIS_Group5Transport:SetSpeedMult(multSpeed)
	ScenarioInfo.INTRONIS_Group5Transport:SetNavMaxSpeedMultiplier(multSpeed)

	ScenarioInfo.INTRONIS_Group6Transport:SetSpeedMult(multSpeed)
	ScenarioInfo.INTRONIS_Group6Transport:SetNavMaxSpeedMultiplier(multSpeed)

	ScenarioInfo.INTRONIS_Group7Transport:SetSpeedMult(multSpeed)
	ScenarioInfo.INTRONIS_Group7Transport:SetNavMaxSpeedMultiplier(multSpeed)

	ScenarioInfo.INTRONIS_Group8Transport:SetSpeedMult(multSpeed)
	ScenarioInfo.INTRONIS_Group8Transport:SetNavMaxSpeedMultiplier(multSpeed)
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	NIS.GroupMoveChain( {ScenarioInfo.INTRONIS_Group4Transport}, 'NIS_INTRO_TRANSPORT_CHAIN_02' )
	NIS.GroupMoveChain( {ScenarioInfo.INTRONIS_Group5Transport}, 'NIS_INTRO_TRANSPORT_CHAIN_01' )
	NIS.GroupMoveChain( {ScenarioInfo.INTRONIS_Group6Transport}, 'NIS_INTRO_TRANSPORT_CHAIN_02' )
	NIS.GroupMoveChain( {ScenarioInfo.INTRONIS_Group7Transport}, 'NIS_INTRO_TRANSPORT_CHAIN_03' )
	NIS.GroupMoveChain( {ScenarioInfo.INTRONIS_Group8Transport}, 'NIS_INTRO_TRANSPORT_CHAIN_02' )
end

function func_OPENING_Structure_Blow_Up(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ScenarioInfo.Fake_Structure_01 = NIS.CreateNISOnlyUnit('ARMY_ALLY01', 'Fake_Structure_01')
	ScenarioInfo.Fake_Structure_02 = NIS.CreateNISOnlyUnit('ARMY_ALLY01', 'Fake_Structure_02')
	ScenarioInfo.Fake_Structure_03 = NIS.CreateNISOnlyUnit('ARMY_ALLY01', 'Fake_Structure_03')
	WaitSeconds(2.0)
	NIS.ForceUnitDeath(ScenarioInfo.Fake_Structure_01)
	WaitSeconds(1.0)
	NIS.ForceUnitDeath(ScenarioInfo.Fake_Structure_02)
	WaitSeconds(1.0)
	NIS.ForceUnitDeath(ScenarioInfo.Fake_Structure_03)
end

function func_OPENING_AllyCDRSetup(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.ALLY_CDR, GetPos('Greer_NIS_Mark'))
		return
	end

	IssueClearCommands({ScenarioInfo.ALLY_CDR})
	IssueMove( {ScenarioInfo.ALLY_CDR}, GetPos('Greer_NIS_Mark') )
end

function func_OPENING_TransportWarp(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	Warp(ScenarioInfo.INTRONIS_Group1Transport, GetPos('Warp_Chain_01'))
	Warp(ScenarioInfo.INTRONIS_Group2Transport, GetPos('Warp_Chain_02'))
	Warp(ScenarioInfo.INTRONIS_CommanderTransport, GetPos('Warp_Chain_03'))
	Warp(ScenarioInfo.INTRONIS_Group4Transport, GetPos('Warp_Chain_04'))
	Warp(ScenarioInfo.INTRONIS_Group5Transport, GetPos('Warp_Chain_05'))
	Warp(ScenarioInfo.INTRONIS_Group6Transport, GetPos('Warp_Chain_06'))
	Warp(ScenarioInfo.INTRONIS_Group7Transport, GetPos('Warp_Chain_07'))
	Warp(ScenarioInfo.INTRONIS_Group8Transport, GetPos('Warp_Chain_08'))
end

function func_OPENING_TransportDestructionPart01(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	WaitSeconds(2.75)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_Group8Transport)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_Group7Transport)
	WaitSeconds(0.5)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_Group6Transport)
	WaitSeconds(1.75)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_Group5Transport)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_Group4Transport)
end

function func_REVEAL_ENEMY_SetupAllyCDR()
	ScenarioInfo.ALLY_CDR:SetDoNotTarget(false)
	IssueClearCommands({ScenarioInfo.ALLY_CDR})
	Warp(ScenarioInfo.ALLY_CDR, GetPos('P1_ENDNIS_CDR_WarpMarker_01'))
	IssueMove({ScenarioInfo.ALLY_CDR}, GetPos('P1_ENDNIS_CDR_MoveMarker_01'))
end

function func_REVEAL_ENEMY_Transports()
	LOG('----- NIS_REVEAL_ENEMY: Transport Attack being created')
	-- Group 1
	local data01 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					= 'P1_ENDNIS_LandTransGroup_01',			-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= 'P1_ENDNIS_Transport_01',					-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= 'P1_ENDNIS_Trans_Landing_Marker_01',		-- destination for the transport drop-off
		returnDest				= 'P1_ENDNIS_Trans_Return_Marker_01',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		onUnloadCallback		= func_REVEAL_ENEMY_TransportLanding,		-- optional function to call when the transport finishes unloading
		OnCreateCallback		= func_REVEAL_ENEMY_TransportCreation,		-- optional function to call for the transport and spawned platoon after they are created
	}
	NIS.TransportArrival(data01)

	-- Group 2
	local data02 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					= 'P1_ENDNIS_LandTransGroup_01',			-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= 'P1_ENDNIS_Transport_02',					-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= 'P1_ENDNIS_Trans_Landing_Marker_02',		-- destination for the transport drop-off
		returnDest				= 'P1_ENDNIS_Trans_Return_Marker_01',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		onUnloadCallback		= func_REVEAL_ENEMY_TransportLanding,		-- optional function to call when the transport finishes unloading
		OnCreateCallback		= func_REVEAL_ENEMY_TransportCreation,		-- optional function to call for the transport and spawned platoon after they are created
	}
	NIS.TransportArrival(data02)

	-- Group 3
	local data03 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					= 'P1_ENDNIS_LandTransGroup_01',			-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= 'P1_ENDNIS_Transport_03',					-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= 'P1_ENDNIS_Trans_Landing_Marker_03',		-- destination for the transport drop-off
		returnDest				= 'P1_ENDNIS_Trans_Return_Marker_01',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
		onUnloadCallback		= func_REVEAL_ENEMY_TransportLanding,		-- optional function to call when the transport finishes unloading
		OnCreateCallback		= func_REVEAL_ENEMY_TransportCreation,		-- optional function to call for the transport and spawned platoon after they are created
	}
	NIS.TransportArrival(data03)
end

function func_REVEAL_ENEMY_TransportCreation(transport)
	-- Protect a unit with all flags *except targetable*. This means the unit is safe, but will
	-- still be attacked during the NIS.
	if transport and not transport:IsDead() then
		transport:SetCanTakeDamage(false)
		transport:SetCanBeKilled(false)
		transport:SetReclaimable(false)
		transport:SetCapturable(false)
	end
end

function func_REVEAL_ENEMY_TransportLanding(platoon)
	LOG('----- NIS_REVEAL_ENEMY: Transport landed')
	-- All units attack the ally commander
	if platoon and ArmyBrains[ScenarioInfo.ARMY_ENEM01]:PlatoonExists(platoon) then
		if ScenarioInfo.ALLY_CDR and not ScenarioInfo.ALLY_CDR:IsDead() then
			IssueAttack( platoon:GetPlatoonUnits(), ScenarioInfo.ALLY_CDR )
		end
	end
end

function func_REVEAL_ENEMY_NukeCommanderSequence()
	LOG('----- NIS_REVEAL_ENEMY: Commander nuke')
	-- Nuke, and kill commander
	local pos = {}
	local CDRPos = ScenarioInfo.ALLY_CDR:GetPosition()
	pos = {CDRPos[1], CDRPos[2], CDRPos[3]}

	NIS.NukePosition(pos)
	NIS.DestroyUnit(ScenarioInfo.ALLY_CDR)
	WaitSeconds(0.1)

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_ALLY01],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 40, true, 0, 90001, brainList)
end

function func_REVEAL_ENEMY_WarpPlayerUnits()
	LOG('----- NIS_REVEAL_ENEMY: Warping player units to ally base area.')
	-- Warp the player's units to the ally base area.
	-- We loop through 4 home positions, warping to a growing
	-- x-offset of each position: position 1 @ offset, position 2 @ offset ...
	-- etc, and repeat, till we are out of units.
	local units = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetListOfUnits(categories.MOBILE - categories.uul0001, false)
	local homePos = 0
	local posXOffest = 0
	for k, unit in units do
		if unit and not unit:IsDead() then
			-- 4 positions are available to loop through. Once we have used the 4, reset back to 0 to begin another
			-- loop through.
			if homePos >= 4 then
				homePos = 0

				-- now that we have warped 4 units, we want the next batch of 4 to be offset, so they dont overlap.
				posXOffest = posXOffest + 5
			end

			-- 1 of four home positions from which we will offset-warp a unit to.
			homePos = homePos + 1
			location =  GetPos('NIS_REVEAL_PlayerUnit_Destination_0' .. homePos)

			IssueClearCommands({unit})
			Warp( unit, {location[1] - posXOffest, location[2], location[3]} )
		end
	end

	-- Warp the player commander to a central spot amid the other warped units.
	if ScenarioInfo.PLAYER_CDR and not ScenarioInfo.PLAYER_CDR:IsDead() then
		IssueClearCommands({ScenarioInfo.PLAYER_CDR})
		Warp( ScenarioInfo.PLAYER_CDR, GetPos('NIS_REVEAL_Commander_Destination_01') )
	else
		WARN('WARNING: U06 Opening - somehow the player ACU is invalid or dead??? - This needs to be reviewed by Campaign Design.')
	end
end

function func_REVEAL_ENEMY_SwapUnits()
	-- Swap the ally units to the player army, and set the units health appropriately.
	local units = ArmyBrains[ScenarioInfo.ARMY_ALLY01]:GetListOfUnits(categories.ALLUNITS - categories.uul0001, false)
	for k, v in units do
		if v and not v:IsDead() then
			local damage = v:GetMaxHealth() - v:GetHealth()
			local newUnit = import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy(v, ScenarioInfo.ARMY_PLAYER)
			if (damage > 0.0) and newUnit and not newUnit:IsDead() then
				local curMax = v:GetMaxHealth()
				--LOG('TESTING: func_REVEAL_ENEMY_SwapUnits: damage:[', damage, '] curMax:[', curMax, ']')
				v:AdjustHealth( v, (curMax - damage) )
			end
		end
	end
end

function func_VICTORY_ClearAndStopPlayerCDR()
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueStop({ScenarioInfo.PLAYER_CDR})
end

function func_VICTORY_MovePlayerCDR()
	-- Move the ally to a point to meet the incoming transport
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	Warp( ScenarioInfo.PLAYER_CDR, GetPos('NIS_VIC_CDR_Warp'))
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('NIS_VIC_CDR_MoveToMark'))
end

function func_VICTORY_AirMoveToTarget()
	-- Create a Transport, send it to meet the Ally commander, pick up him, and return offmap.
	ScenarioInfo.VIC_NIS_Transport = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'VIC_NIS_Transport')

	IssueClearCommands({ScenarioInfo.VIC_NIS_Transport})
	IssueMove( {ScenarioInfo.VIC_NIS_Transport}, GetPos('NIS_VIC_FakeTRANSPORT_ARRIVE') )
end

function func_VICTORY_AirTransportPickup()
	--Warp( ScenarioInfo.PLAYER_CDR, GetPos('NIS_VIC_CDR_Warp'))
	IssueTransportLoad({ScenarioInfo.PLAYER_CDR}, ScenarioInfo.VIC_NIS_Transport )
	IssueMove({ScenarioInfo.VIC_NIS_Transport}, GetPos('P2_ENEM01_AirAttack_01_Chain_02'))
end

function NIS_VICTORY_TroopSpawn()

	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS, false)
	for k, unit in unitList do
		NIS.ForceUnitDeath(unit)
	end

	ScenarioInfo.EndNIS_Fatboys		= NIS.CreateNISOnlyGroup('ARMY_PLAYER', 'EndNIS_Fatboys')
	ScenarioInfo.EndNIS_Tanks		= NIS.CreateNISOnlyGroup('ARMY_PLAYER', 'EndNIS_Tanks')
	ScenarioInfo.EndNIS_AssaultBot	= NIS.CreateNISOnlyGroup('ARMY_PLAYER', 'EndNIS_AssaultBot')

	if ScenarioInfo.P2_ReactorStructure and not ScenarioInfo.P2_ReactorStructure:IsDead() then
		for k, unit in ScenarioInfo.EndNIS_Fatboys do
			IssueAttack({unit}, ScenarioInfo.P2_ReactorStructure)
		end

		for k, unit in ScenarioInfo.EndNIS_Tanks do
			IssueAttack({unit}, ScenarioInfo.P2_ReactorStructure)
		end

		for k, unit in ScenarioInfo.EndNIS_AssaultBot do
			IssueAttack({unit}, ScenarioInfo.P2_ReactorStructure)
		end
	end
end
---------------------------------------------------------------------
-- FMV ONLY FUNCTIONS:
---------------------------------------------------------------------
function TransportExit()
	-------------------------------------------------------------------------------------------------------------------
	---NOTE: ScenarioInfo.P1_PLAYER_NIS_Transport_04 only used for frame dumping purposes: JTM 11/11/09
	-------------------------------------------------------------------------------------------------------------------
	ScenarioInfo.P1_PLAYER_NIS_Transport_04		= import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_04')
	ScenarioInfo.FMV_ACU						= import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'FMV_ACU')
	--ScenarioInfo.FMV_ACU:SetMaxHealth(100000)
	--ScenarioInfo.FMV_ACU:AdjustHealth(ScenarioInfo.FMV_ACU, 1)
	-------------------------------------------------------------------------------------------------------------------

	import('/lua/system/Utilities.lua').UserConRequest('ren_ui')
	NIS.StartMovieCapture(15)

	ForkThread(
		function()
			WaitSeconds(0.0)
			NIS.NukePosition('FrameDumpNukes_01')
			WaitSeconds(0.5)
			NIS.NukePosition('FrameDumpNukes_02')
			WaitSeconds(3.5)
			NIS.NukePosition('FrameDumpNukes_03')
			WaitSeconds(3.5)
			NIS.NukePosition('FrameDumpNukes_04')
			NIS.NukePosition('FrameDumpNukes_05')
			WaitSeconds(1.0)
			NIS.NukePosition('FrameDumpNukes_06')
		end
	)

	NIS.HideAndWarpUnit(ScenarioInfo.P1_PLAYER_NIS_Transport_04, 'Transport_FMV_Warp')

	NIS.GroupMoveChain({ScenarioInfo.P1_PLAYER_NIS_Transport_04}, 'EndNuke_Patrol')

	NIS.SetFOV(75.0)
	NIS.ZoomTo(GetPos('EndNuke_CAM_01'), GetOrient('EndNuke_CAM_01'), 0.0, 0.0)
	NIS.ZoomTo(GetPos('EndNuke_CAM_02'), GetOrient('EndNuke_CAM_02'), 0.0, 12.0)

	NIS.EntityTrackRelative(
		{
			ent					= ScenarioInfo.P1_PLAYER_NIS_Transport_04,	-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 180.0,									-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 4.0,										-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nTrackDistance		= 30.0,										-- how close to track relative to the unit
			nTrackToDuration	= 0.0,										-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
			nOffsetX			= 2.0,										-- if specified, offset in the X direction
			nOffsetY			= 0.0,										-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,										-- if specified, offset in the Z direction
		}
	)
	WaitSeconds(30.0)

	NIS.EndMovieCapture()
	import('/lua/system/Utilities.lua').UserConRequest('ren_ui')
end

function PostNuke()
	-------------------------------------------------------------------------------------------------------------------
	---NOTE: ScenarioInfo.P1_PLAYER_NIS_Transport_04 only used for frame dumping purposes: JTM 11/11/09
	-------------------------------------------------------------------------------------------------------------------
	ScenarioInfo.P1_PLAYER_NIS_Transport_04		= import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_NIS_Transport_04')
	ScenarioInfo.FMV_ACU						= import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'FMV_ACU')
	--ScenarioInfo.FMV_ACU:SetMaxHealth(100000)
	--ScenarioInfo.FMV_ACU:AdjustHealth(ScenarioInfo.FMV_ACU, 1)
	-------------------------------------------------------------------------------------------------------------------

	--NIS.NukePosition('EndNuke_PostNuke_Warp_01')
	--WaitSeconds(30.0)
	ScenarioInfo.FMV_ACU:AdjustHealth(ScenarioInfo.FMV_ACU, 1)

	NIS.StartMovieCapture(15)
	import('/lua/system/Utilities.lua').UserConRequest('ren_ui')

	NIS.HideAndWarpUnit(ScenarioInfo.P1_PLAYER_NIS_Transport_04, 'EndNuke_PostNuke_Warp_01')
	NIS.ForceUnitDeath(ScenarioInfo.P1_PLAYER_NIS_Transport_04)

	NIS.HideAndWarpUnit(ScenarioInfo.FMV_ACU, 'EndNuke_PostNuke_CDR_Warp_01')
	WaitSeconds(3.0)

	IssueMove( {ScenarioInfo.FMV_ACU}, GetPos('EndNuke_PostNuke_CDR_Rally_01'))

	NIS.SetFOV(45.0)
	NIS.ZoomTo(GetPos('EndNukeCAM2_01'), GetOrient('EndNukeCAM2_01'), 0.0, 0.0)
	NIS.ZoomTo(GetPos('EndNukeCAM2_02'), GetOrient('EndNukeCAM2_02'), 0.0, 6.0)
	WaitSeconds(6.0)

	NIS.EndMovieCapture()
	import('/lua/system/Utilities.lua').UserConRequest('ren_ui')
end