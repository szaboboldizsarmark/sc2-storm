---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_C04/SC2_CA_C04_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_C04/SC2_CA_C04_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_C04/SC2_CA_C04_script.lua')
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
				func_OPENING_CreateOpeningBattle(true)
				func_OPENING_PlayerTransportSequence(true)
				func_OPENING_AllowCombatDeaths(true)
				func_OPENING_DestroyAllBattleUnits(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('C04_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.C04_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.C04_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.C04_NIS_OPENING_010,
			OpDialog.C04_NIS_OPENING_020,
			OpDialog.C04_NIS_OPENING_030,
			OpDialog.C04_NIS_OP_SETUP_010,
			OpDialog.C04_NIS_OP_SETUP_END,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('C04_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS1_CAM_A_05', 0.0, 'NIS1_CAM_A_05')

	func_OPENING_CreateOpeningBattle()

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	func_OPENING_PlayerTransportSequence()

	NIS.CreateVizMarker('P1_ENEM01_West_Base_Marker', 100.0)
	NIS.CreateVizMarker('P1_ENEM01_East_Base_Marker', 100.0)

	ForkThread(
		function()
			-- while dialog begins, use the starting shot and zoom in
			NIS.ZoomTo(GetPos('NIS1_CAM_A_06'), GetOrient('NIS1_CAM_A_06'), 0.0, 14.0)

			-- Track transports
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.INTRONIS_CommanderTransport,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 10.0,										-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 65.0,										-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 75.0,										-- how close to track relative to the unit
					nTrackToDuration	= 0.0,										-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 5.0,										-- if specified, offset in the X direction
					nOffsetY			= 0.0,										-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,										-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_OPENING_010) 	--Final VO: 18.4 seconds

	func_OPENING_AllowCombatDeaths()

	--Final VO: 8.4 seconds
	ForkThread(
		function()
			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_01'), GetOrient('NIS1_CAM_D_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_02'), GetOrient('NIS1_CAM_D_02'), 0.0, 5.5)

			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 150.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -10.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 8.5,							-- how close to spin relative to the unit
					nTrackToDuration	= 0.0,							-- how long to allow the spin to persist
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_OPENING_020)

	--Final VO: 16.3 seconds
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			--NIS.ZoomTo(GetPos('NIS1_CAM_E_03'), GetOrient('NIS1_CAM_E_03'), 0.0, 14.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_04'), GetOrient('NIS1_CAM_E_04'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_06'), GetOrient('NIS1_CAM_E_05'), 0.0, 15.0)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_OPENING_030)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_OPENING_End')

	NIS.ZoomTo(GetPos('NIS1_CAM_H_02'), GetOrient('NIS1_CAM_H_02'), 0.0, 0.0)

	func_OPENING_DestroyAllBattleUnits()

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.C04_NIS_OP_SETUP_010)

	NIS.DialogNoWait(OpDialog.C04_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_ENEM01_CDR01_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.C04_WALKER_DEATH_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_ENEM01_CDR01_DEATH_Start')
	NIS.StartNIS_Standard()

	local deadEnt = nil

	NIS.EntityTrackRelative(
		{
			ent					= deathUnit,	-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 50.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nTrackDistance		= 300.0,		-- how close to spin relative to the unit
			nTrackToDuration	= 0.0,			-- how long to allow the spin to persist
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 1.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)

	ForkThread(
		function()
			WaitSeconds(1.0)
			deadEnt = NIS.UnitDeathZoomTo(
				{
					unit				= deathUnit,	-- unit to be killed
					vizRadius			= 100,			-- optional distance for a visibility marker ring
					degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 50.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nZoomToDistance		= 300.0,		-- how close to zoom-in relative to the unit
					nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 1.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_WALKER_DEATH_010)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_ENEM01_CDR01_DEATH_End')

	func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)
end

---------------------------------------------------------------------
function NIS_ENEM01_CDR02_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.C04_LARSON_DEATH_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_ENEM01_CDR02_DEATH_Start')
	NIS.StartNIS_Standard()

	local deadEnt = nil

	NIS.EntityTrackRelative(
		{
			ent					= deathUnit,	-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 30.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nTrackDistance		= 200.0,		-- how close to spin relative to the unit
			nTrackToDuration	= 0.0,			-- how long to allow the spin to persist
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 1.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)

	--Final VO: 6.9 seconds
	-- anything else specific to this CDR - including a dialog call
	ForkThread(
		function()
			deadEnt = NIS.UnitDeathZoomTo(
				{
					unit				= deathUnit,	-- unit to be killed
					vizRadius			= 100,			-- optional distance for a visibility marker ring
					degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 30.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nZoomToDistance		= 200.0,		-- how close to zoom-in relative to the unit
					nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 1.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_LARSON_DEATH_010)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_ENEM01_CDR02_DEATH_End')

	func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)
end

---------------------------------------------------------------------
function NIS_ENEM01_CDR03_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.C04_BURKETT_DEATH_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_ENEM01_CDR03_DEATH_Start')
	NIS.StartNIS_Standard()

	local deadEnt = nil

	NIS.EntityTrackRelative(
		{
			ent					= deathUnit,	-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 80.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nTrackDistance		= 250.0,		-- how close to spin relative to the unit
			nTrackToDuration	= 0.0,			-- how long to allow the spin to persist
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 1.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)


	--Final VO: 5.2 seconds
	-- anything else specific to this CDR - including a dialog call
	ForkThread(
		function()
			WaitSeconds(1.0)
			deadEnt = NIS.UnitDeathZoomTo(
				{
					unit				= deathUnit,	-- unit to be killed
					vizRadius			= 100,			-- optional distance for a visibility marker ring
					degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 70.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nZoomToDistance		= 250.0,		-- how close to zoom-in relative to the unit
					nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 1.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_BURKETT_DEATH_010)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_ENEM01_CDR03_DEATH_End')

	func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)
end

---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)
	-- disable combat for the duration of the remaining sequence
	NIS.DisableCombat()

	NIS.PreloadDialogData(
		{
			OpDialog.C04_NIS_VICTORY_010,
			OpDialog.C04_NIS_VICTORY_020,
			OpDialog.C04_NIS_VICTORY_030,
			OpDialog.C04_NIS_VICTORY_033,
			OpDialog.C04_NIS_VICTORY_035,
			OpDialog.C04_NIS_VICTORY_040,
			OpDialog.C04_NIS_VICTORY_045,
			OpDialog.C04_NIS_VICTORY_050,
			OpDialog.C04_NIS_VICTORY_060,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C04_NIS_VICTORY_Start')

	NIS.Dialog(OpDialog.C04_NIS_VICTORY_010)

	NIS.FadeOut(3.0)
	WaitSeconds(3.0)

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	NIS.SetZoom(1000.0, 0.0)

	func_VICTORY_ClearAllUnits()

	WaitSeconds(3.0)

	func_VICTORY_SetupAllUnits()

	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 10.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 50.0,							-- how close to spin relative to the unit
					nTrackToDuration	= 10.0,							-- how long to allow the spin to persist
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			NIS.FadeIn(3.0)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_020) -- 9.9 stay behind

	func_VICTORY_StopACUs()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_FINAL_CAMS_01'), GetOrient('NIS_FINAL_CAMS_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_FINAL_CAMS_02'), GetOrient('NIS_FINAL_CAMS_02'), 0.0, 7.0)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_030) -- 5.8 (contacted authorities)

	func_VICTORY_MoveEndingCDRs()

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ALLYUEF_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to spin relative to the unit
					nTrackToDuration	= 5.0,							-- how long to allow the spin to persist
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_033) -- 5 (maddox response)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 20.0,							-- how close to spin relative to the unit
					nTrackToDuration	= 5.0,							-- how long to allow the spin to persist
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_035) -- 5.4 (ivan to maddox)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ALLYILL_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 20.0,							-- how close to spin relative to the unit
					nTrackToDuration	= 8.0,							-- how long to allow the spin to persist
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_040) -- 2.9 (talking to thalia)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_045) -- 4.9 (thalia)

	func_VICTORY_ACUsMoveAway()

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 0.0,							-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 10.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 150.0,						-- how close to spin relative to the unit
					nTrackToDuration	= 0.0,							-- how long to allow the spin to persist
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_050) -- 3.1 (good luck)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 10.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to spin relative to the unit
					nTrackToDuration	= 7.0,							-- how long to allow the spin to persist
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C04_NIS_VICTORY_060) -- 6.3 (return)

	func_VICTORY_TeleportPlayerACU()

	WaitSeconds(2.0)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_CreateOpeningBattle(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ScenarioInfo.NIS_ARMY_CLOSE = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_ARMY_CLOSE')
	ScenarioInfo.NIS_ARMY_FAR = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_ARMY_FAR')

	ScenarioInfo.NIS_THALIA = NIS.CreateNISOnlyGroup('ARMY_ALLYILL', 'NIS_THALIA')
	ScenarioInfo.NIS_MADDOX = NIS.CreateNISOnlyGroup('ARMY_ALLYUEF', 'NIS_MADDOX')

	IssueMove (ScenarioInfo.NIS_ARMY_CLOSE, GetPos('NIS_ATTACK_03'))
	IssueMove (ScenarioInfo.NIS_ARMY_FAR, GetPos('NIS_ATTACK_01'))

	IssueMove (ScenarioInfo.NIS_THALIA, GetPos('NIS_ATTACK_04'))
	IssueMove (ScenarioInfo.NIS_MADDOX, GetPos('NIS_ATTACK_02'))
end

function func_OPENING_PlayerTransportSequence(bSkip)
	-- CDR group
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_GroupCDR,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_CommanderTransport,	-- unit handle for the actual transport
			approachChain			= 'INTRONIS_Transport_Approach_Chain',		-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_01',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= func_OPENING_UnloadFormup,				-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
	-- Initial Army group
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_Group1,				-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_Group1Transport,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_02',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_01',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group_Formup_02',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
	-- Initial Army group
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_Group2,				-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_Group2Transport,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_03',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_02',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group_Formup_03',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
end

function func_OPENING_UnloadFormup()
	IssueFormMove( ScenarioInfo.INTRONIS_GroupCDR, GetPos( 'INTRONIS_Transport_Group_Formup_01' ), 'AttackFormation', 0 )
end

function func_OPENING_AllowCombatDeaths(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.AllowGroupDeath(ScenarioInfo.NIS_ARMY_CLOSE)
	NIS.AllowGroupDeath(ScenarioInfo.NIS_ARMY_FAR)
	NIS.AllowGroupDeath(ScenarioInfo.NIS_THALIA)
	NIS.AllowGroupDeath(ScenarioInfo.NIS_MADDOX)
end

function func_OPENING_DestroyAllBattleUnits(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ForkThread(
		function()
			for k, unit in ScenarioInfo.NIS_ARMY_CLOSE do
				if unit and not unit:IsDead() then
					NIS.ForceUnitDeath(unit)
				end
			end

			for k, unit in ScenarioInfo.NIS_ARMY_FAR do
				if unit and not unit:IsDead() then
					NIS.ForceUnitDeath(unit)
				end
			end

			for k, unit in ScenarioInfo.NIS_THALIA do
				if unit and not unit:IsDead() then
					NIS.ForceUnitDeath(unit)
				end
			end

			for k, unit in ScenarioInfo.NIS_MADDOX do
				if unit and not unit:IsDead() then
					NIS.ForceUnitDeath(unit)
				end
			end
		end
	)
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

function func_VICTORY_ClearAllUnits()
	-- Destroy base leftovers
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS, false)
	for k, unit in unitList do
		NIS.ForceUnitDeath(unit)
	end

	local catsToDestroy = categories.ALLUNITS - categories.COMMAND

	-- Destroy player units around teleporter
	unitList = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetUnitsAroundPoint( catsToDestroy, GetPos('VICTORY_WALK_01'), 60.0, 'Ally' )
	NIS.DestroyGroup(unitList)

	-- Destroy Thalia's units around teleporter
	unitList = ArmyBrains[ScenarioInfo.ARMY_ALLYILL]:GetUnitsAroundPoint ( catsToDestroy, GetPos('VICTORY_WALK_01'), 60.0, 'Ally' )
	NIS.DestroyGroup(unitList)

	-- Destroy Maddox's units around teleporter
	unitList = ArmyBrains[ScenarioInfo.ARMY_ALLYUEF]:GetUnitsAroundPoint( catsToDestroy, GetPos('VICTORY_WALK_01'), 60.0, 'Ally' )
	NIS.DestroyGroup(unitList)

end

function func_VICTORY_SetupAllUnits()
	-- stop the ACUs
	func_VICTORY_StopACUs()

	ScenarioInfo.ArmyBase_ALLYUEF_Main_Base:BaseActive(false)
	ScenarioInfo.ArmyBase_ALLYILL_Main_Base:BaseActive(false)

	Warp(ScenarioInfo.PLAYER_CDR, GetPos('VICTORY_WALK_04'))
	Warp(ScenarioInfo.ALLYUEF_CDR, GetPos('VICTORY_WALK_03'))
	Warp(ScenarioInfo.ALLYILL_CDR, GetPos('VICTORY_WALK_02'))

	-- move the ending CDRs
	func_VICTORY_MoveEndingCDRs()
end

function func_VICTORY_StopACUs()
	IssueStop({ScenarioInfo.PLAYER_CDR})
	IssueStop({ScenarioInfo.ALLYUEF_CDR})
	IssueStop({ScenarioInfo.ALLYILL_CDR})
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueClearCommands({ScenarioInfo.ALLYUEF_CDR})
	IssueClearCommands({ScenarioInfo.ALLYILL_CDR})
end

function func_VICTORY_MoveEndingCDRs()
	IssueStop({ScenarioInfo.PLAYER_CDR})
	IssueStop({ScenarioInfo.ALLYUEF_CDR})
	IssueStop({ScenarioInfo.ALLYILL_CDR})
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueClearCommands({ScenarioInfo.ALLYUEF_CDR})
	IssueClearCommands({ScenarioInfo.ALLYILL_CDR})


	IssueFormMove({ScenarioInfo.PLAYER_CDR}, GetPos('VICTORY_WALK_01'), 'AttackFormation', 0)
	IssueFormMove({ScenarioInfo.ALLYUEF_CDR}, GetPos('VICTORY_WALK_05'), 'AttackFormation', 0)
	IssueFormMove({ScenarioInfo.ALLYILL_CDR}, GetPos('VICTORY_WALK_06'), 'AttackFormation', 0 )
end

function func_VICTORY_ACUsMoveAway()
	IssueStop(ScenarioInfo.ALLYUEF_CDR)
	IssueStop(ScenarioInfo.ALLYILL_CDR)
	IssueClearCommands(ScenarioInfo.ALLYUEF_CDR)
	IssueClearCommands(ScenarioInfo.ALLYILL_CDR)

	IssueMove({ScenarioInfo.ALLYUEF_CDR}, GetPos('VICTORY_WALK_03'))
	IssueMove({ScenarioInfo.ALLYILL_CDR}, GetPos('VICTORY_WALK_02'))
end

function func_VICTORY_TeleportPlayerACU()
	NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_01_ring_emit.bp', GetPos(ScenarioInfo.PLAYER_CDR))
	NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_02_glow_emit.bp', GetPos(ScenarioInfo.PLAYER_CDR))
	CreateTeleportEffects( ScenarioInfo.PLAYER_CDR )
	NIS.HideUnit(ScenarioInfo.PLAYER_CDR)
end
