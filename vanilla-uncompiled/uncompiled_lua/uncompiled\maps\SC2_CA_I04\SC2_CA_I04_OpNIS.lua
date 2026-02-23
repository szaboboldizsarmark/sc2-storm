---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_I04/SC2_CA_I04_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_I04/SC2_CA_I04_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_I04/SC2_CA_I04_script.lua')
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
				func_OPENING_MovePlayerCDR(true)
				func_OPENING_PlayerBuildFactory(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('I04_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.I04_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.I04_NIS_OP_SETUP_020)
				NIS.DialogNoWait(OpDialog.I04_NIS_OP_SETUP_030)
				NIS.DialogNoWait(OpDialog.I04_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.I04_NIS_OPENING_010,
			OpDialog.I04_NIS_OPENING_012,
			OpDialog.I04_NIS_OPENING_015,
			OpDialog.I04_NIS_OPENING_020,
			OpDialog.I04_NIS_OP_SETUP_010,
			OpDialog.I04_NIS_OP_SETUP_020,
			OpDialog.I04_NIS_OP_SETUP_030,
			OpDialog.I04_NIS_OP_SETUP_END,
		}
	)

	-- spawn transports loaded with the CDR and the player starting units
	func_OPENING_PlayerTransportSequence()

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('I04_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance and a start position
	NIS.StartNIS_Opening('NIS1_CAM_A_01', -100.0,'NIS1_CAM_A_01')

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	ForkThread(
		function()
			-- Pan out from core
			NIS.ZoomTo(GetPos('NIS1_CAM_A_02'), GetOrient('NIS1_CAM_A_02'), 0.0, 12.0)
			WaitSeconds(2.0)

			-- Track transports
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.INTRONIS_CommanderTransport,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 10.0,											-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 65.0,											-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 75.0,											-- how close to track relative to the unit
					nTrackToDuration	= 0.0,											-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 5.0,											-- if specified, offset in the X direction
					nOffsetY			= 0.0,											-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,											-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I04_NIS_OPENING_010)--14.9

	ForkThread(
		function()
			-- Pan to CU of Thalia
			NIS.SetFOV(45.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 175.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 3.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)

			---NOTE: this is potentially not safe - as the units may or may not have landed yet - bfricks 12/5/09
			-- move the player a bit
			func_OPENING_MovePlayerCDR()

			NIS.ZoomTo(GetPos('NIS1_CAM_E_03'), GetOrient('NIS1_CAM_E_03'), 10.0, 7.5)
		end
	)
	NIS.Dialog(OpDialog.I04_NIS_OPENING_012)--6.5

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_OPENING_TimeDilationStart')

	---NOTE: this is potentially not safe - as the units may or may not have landed yet - bfricks 12/5/09
	func_OPENING_PlayerBuildFactory()

	-- Get a base VO
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			-- Pan out to establishing shot of base
			NIS.ZoomTo(GetPos('NIS1_CAM_B_01'), GetOrient('NIS1_CAM_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_02'), GetOrient('NIS1_CAM_B_02'), 0.0, 10.0)
		end
	)
	-- 4.2
	NIS.Dialog(OpDialog.I04_NIS_OPENING_015)

	--- Time Dilation: clear builds, add bases
	NIS.FadeOut(2.0)

	WaitSeconds(2.0)

	NIS.CreateVizMarker('ARMY_ENEM01', 300)
	NIS.CreateVizMarker('ARMY_ENEM03', 300)

	-- 9.0
	NIS.Dialog(OpDialog.I04_NIS_OPENING_020)

	-- Time Dialation player base created
	NIS.FadeIn(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_OPENING_TimeDilationEnd')

	-- Final VO timing: 7.3 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_H_01'), GetOrient('NIS1_CAM_H_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_H_02'), GetOrient('NIS1_CAM_H_02'), 0.0, 8.0)
		end
	)
	NIS.Dialog(OpDialog.I04_NIS_OP_SETUP_010)

	--for dramatic affect
	WaitSeconds(1.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_OPENING_ShowAlpha')

	-- Final VO timing: 6.1 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_01'), GetOrient('NIS1_CAM_D_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_02'), GetOrient('NIS1_CAM_D_02'), 0.0, 9.0)
		end
	)
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_OPENING_ShowBravo')
	NIS.Dialog(OpDialog.I04_NIS_OP_SETUP_020)

	NIS.Dialog(OpDialog.I04_NIS_OP_SETUP_030)

	NIS.SetFOV(60.0)
	NIS.ZoomTo(GetPos('NIS1_CAM_C_01'), GetOrient('NIS1_CAM_C_01'), 0.0, 0.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	-- Final VO timing: 9.7 seconds
	NIS.DialogNoWait(OpDialog.I04_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_ALLY_GAUGE_ARRIVAL:
---------------------------------------------------------------------
function NIS_ALLY_GAUGE_ARRIVAL()

	NIS.PreloadDialogData(
		{
			OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_020,
			OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_025,
			OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_030,
			OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_END,
		}
	)

	-- hide guage units that spanw near player
	func_ALLY_GAUGE_ARRIVAL_HideUnits()

	-- Probably need Gauge spawn function here
	func_ALLY_GAUGE_ARRIVAL_TransportSequence()

	NIS.CreateVizMarker('ARMY_PLAYER', 200)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_ALLY_GAUGE_ARRIVAL_Start')

	NIS.StartNIS_MidOp()

	-- Final VO timing: 12.2 seconds
	-- Hi Thalia, I'm William Gauge
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			-- Pan around Building of structures
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_02_03'), GetOrient('NIS_MIDOP_CAM_SHOT_02_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_02_04'), GetOrient('NIS_MIDOP_CAM_SHOT_02_04'), 0.0, 6.0)
			WaitSeconds(1.50)
			-- Guage FS
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_04_03'), GetOrient('NIS_MIDOP_CAM_SHOT_04_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_04_04'), GetOrient('NIS_MIDOP_CAM_SHOT_04_04'), 20.0, 7.0)
		end
	)

	-- reveal guage units that spanw near player
	func_ALLY_GAUGE_ARRIVAL_RevealUnits()

	NIS.Dialog(OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_020)

	func_ALLY_GAUGE_ARRIVAL_TransportDeployToPlayer()

	NIS.CreateVizMarker('Ally_Transport_Group02_Formup', 100)

	WaitSeconds(0.5)
	-- Dispose of forces
	-- Final VO timing: 2.7 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_03_06'), GetOrient('NIS_MIDOP_CAM_SHOT_03_06'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_03_01'), GetOrient('NIS_MIDOP_CAM_SHOT_03_01'), 0.0, 6.0)
			NIS.SetFOV(35.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_03_03'), GetOrient('NIS_MIDOP_CAM_SHOT_03_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_03_02'), GetOrient('NIS_MIDOP_CAM_SHOT_03_02'), 0.0, 3.7)
		end
	)
	NIS.Dialog(OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_025)

	WaitSeconds(7.0)

	-- The saving of bacon
	-- Final VO timing: 3.0 seconds
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_03_04'), GetOrient('NIS_MIDOP_CAM_SHOT_03_04'), -10.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_03_05'), GetOrient('NIS_MIDOP_CAM_SHOT_03_05'), -10.0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_030)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_ALLY_GAUGE_ARRIVAL_End')

	-- use EndNIS_MidOp and restore to the player
	NIS.EndNIS_MidOp()

	-- Final VO timing: 9.8 seconds
	NIS.DialogNoWait(OpDialog.I04_NIS_ALLY_GAUGE_ARRIVAL_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_FIRST_CDR_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.I04_ENEM01_DEAD_010,
			OpDialog.I04_ENEM02_DEAD_020,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_FIRST_CDR_DEATH_Start')

	NIS.StartNIS_Standard()

	-- kill the unit
	local deadEnt = NIS.UnitDeathToEnt(deathUnit)

	-- anything else specific to this CDR - including a dialog call
	-- Final VO timing: 1.3 seconds
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= deadEnt,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 8.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 35.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.01,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 200.0,		-- how close to spin relative to the unit
					nSpinDuration		= 5.0,			-- how long to allow the spin to persist
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 3.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	WaitSeconds(1.0)
	NIS.Dialog(OpDialog.I04_ENEM01_DEAD_010)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_FIRST_CDR_DEATH_End')

	func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)

	-- Final VO timing: 2.0 seconds
	NIS.DialogNoWait(OpDialog.I04_ENEM02_DEAD_020)
end

---------------------------------------------------------------------

function NIS_SECOND_CDR_DEATH(deathUnit, numCDRDeaths)

	NIS.PreloadDialogData(
		{
			OpDialog.I04_ENEMIES_DEAD_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_SECOND_CDR_DEATH_Start')

	NIS.StartNIS_Standard()

	-- kill the unit
	local deadEnt = NIS.UnitDeathToEnt(deathUnit)

	-- anything else specific to this CDR - including a dialog call
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= deadEnt,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 50.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.01,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 200.0,		-- how close to spin relative to the unit
					nSpinDuration		= 15.0,			-- how long to allow the spin to persist
					nOffsetX			= 5.0,			-- if specified, offset in the X direction
					nOffsetY			= 3.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	WaitSeconds(1.0)

	NIS.Dialog(OpDialog.I04_ENEMIES_DEAD_010)

	WaitSeconds(2.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_SECOND_CDR_DEATH_End')

	func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)
end

---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.I04_NIS_VICTORY_010,
			OpDialog.I04_NIS_VICTORY_020,
			OpDialog.I04_NIS_VICTORY_025,
			OpDialog.I04_NIS_VICTORY_030,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I04_NIS_VICTORY_Start')

	-- NOTE: No NIS start. NIS_VICTORY is called from another function that has alread started the NIS

	-- disable combat for the duration of the remaining sequence
	NIS.DisableCombat()

	-- Final VO timing: 12.5 seconds; new Cathedral
	NIS.Dialog(OpDialog.I04_NIS_VICTORY_010)

	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos(deathUnit), GetOrient('NIS_VICTORY_01'), 250.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VICTORY_02'), GetOrient('NIS_VICTORY_02'), 0.0, 25.0)
		end
	)

	-- Final VO timing: 14.8 seconds (Maddox reveal)
	NIS.Dialog(OpDialog.I04_NIS_VICTORY_020)

	-- Final VO timing: 7.8 seconds (Maddox reveal)
	NIS.Dialog(OpDialog.I04_NIS_VICTORY_025)

	func_VICTORY_GaugePickup()

	ForkThread(
		function()
			-- Track transports
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.GAUGE_Transport_02,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 150.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 40.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 35.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 5.0,									-- if specified, offset in the X direction
					nOffsetY			= 0.0,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
		end
	)
	-- Final VO timing: 6.9 seconds
	NIS.Dialog(OpDialog.I04_NIS_VICTORY_030)

	func_VICTORY_GaugeExit()

	-- wrap up and allow for optional continued gameplay
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
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= func_OPENING_SetCDRLanded,				-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
end

function func_OPENING_SetCDRLanded()
	ScenarioInfo.CDR_LANDED = true
end

function func_OPENING_MovePlayerCDR(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('INTRONIS_CommanderDestination_Marker'))
		return
	end

	IssueMove({ScenarioInfo.PLAYER_CDR},GetPos('INTRONIS_CommanderDestination_Marker'))
end

function func_OPENING_PlayerBuildFactory(bSkip)
	if bSkip then
		-- if we are skipping, just create the unit and move on
		import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_LF01')
		import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_RADAR01')
		import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'P1_PLAYER_ME01')
		return
	end

	-- clear the ACU commands
	IssueClearCommands(ScenarioInfo.PLAYER_CDR)

	-- Called when Commander lands
	-- CDR and support engineers build player base during INTRO_NIS
	local unitData = import('/lua/sim/ScenarioUtilities.lua').FindUnit('P1_PLAYER_LF01', Scenario.Armies['ARMY_PLAYER'].Units)
	ArmyBrains[ScenarioInfo.ARMY_PLAYER]:BuildStructure(ScenarioInfo.PLAYER_CDR, unitData.type, { unitData.Position[1], unitData.Position[3], 0}, false)

	local unitData2 = import('/lua/sim/ScenarioUtilities.lua').FindUnit('P1_PLAYER_RADAR01', Scenario.Armies['ARMY_PLAYER'].Units)
	ArmyBrains[ScenarioInfo.ARMY_PLAYER]:BuildStructure(ScenarioInfo.P1_PLAYER_ENG01, unitData2.type, { unitData2.Position[1], unitData2.Position[3], 0}, false)

	local unitData3 = import('/lua/sim/ScenarioUtilities.lua').FindUnit('P1_PLAYER_ME01', Scenario.Armies['ARMY_PLAYER'].Units)
	ArmyBrains[ScenarioInfo.ARMY_PLAYER]:BuildStructure(ScenarioInfo.P1_PLAYER_ENG02, unitData3.type, { unitData3.Position[1], unitData3.Position[3], 0}, false)
end

function func_ALLY_GAUGE_ARRIVAL_HideUnits()
	NIS.HideUnit(ScenarioInfo.NIS_INTRONIS_Transport_02)
	NIS.HideUnit(ScenarioInfo.NIS_INTRONIS_Transport_06)
end

function func_ALLY_GAUGE_ARRIVAL_RevealUnits()
	NIS.ShowUnit(ScenarioInfo.NIS_INTRONIS_Transport_02)
	NIS.ShowUnit(ScenarioInfo.NIS_INTRONIS_Transport_06)
end

function func_ALLY_GAUGE_ARRIVAL_TransportSequence()
	-- Gauge arrival
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_AllyCDR,					-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_GaugeTransport,			-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'GAUGE_Transport_Landing_Marker_01',		-- destination for the transport drop-off
			returnDest				= 'GAUGE_Transport_Return_Marker',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= GAUGE_CDRUnloadCallback,					-- optional function to call when the transport finishes unloading
		}
	)
	-- group1
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_AllyGroup_01,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_INTRONIS_Transport_01,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'ALLY_Transport_Landing_Marker_01',		-- destination for the transport drop-off
			returnDest				= 'ALLY_Transport_Return_Marker_01',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
		}
	)
	-- group3
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_AllyGroup_03,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_INTRONIS_Transport_03,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'ALLY_Transport_Markers_05_01',			-- destination for the transport drop-off
			returnDest				= 'ALLY_Transport_Return_Marker_02',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
		}
	)
	-- group4
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_AllyGroup_04,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_INTRONIS_Transport_04,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'ALLY_Transport_Markers_06_01',			-- destination for the transport drop-off
			returnDest				= 'ALLY_Transport_Return_Marker_02',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
		}
	)
	-- group5
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_AllyGroup_05,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_INTRONIS_Transport_05,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'ALLY_Transport_Landing_Marker_01',		-- destination for the transport drop-off
			returnDest				= 'ALLY_Transport_Return_Marker_02',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
		}
	)

end

function func_ALLY_GAUGE_ARRIVAL_TransportDeployToPlayer()

	-- group2
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_AllyGroup_02,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_INTRONIS_Transport_02,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'ALLY_Transport_Landing_Marker_02',		-- destination for the transport drop-off
			returnDest				= 'ALLY_Transport_Return_Marker_02',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
		}
	)
	-- group6
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ALLY01',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_AllyGroup_06,			-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_INTRONIS_Transport_06,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'ALLY_Transport_Markers_07_01',			-- destination for the transport drop-off
			returnDest				= 'ALLY_Transport_Return_Marker_02',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
		}
	)
end


--function func_ALLY_GAUGE_ARRIVAL_Deploy_01()
--	NIS.GroupMoveChain( ScenarioInfo.NIS_AllyGroup_02, 'ALLY_Land_Attack01' )
--end

--function func_ALLY_GAUGE_ARRIVAL_Deploy_02()
--	NIS.GroupMoveChain( ScenarioInfo.NIS_AllyGroup_06, 'ALLY_Land_Attack01' )
--end

function GAUGE_CDRUnloadCallback(platoon)
	LOG('---- GAUGE_CDRUnloadCallback: platoon Commander landed')
	-- Called when Commander lands

	-- Call the function in the Op Script to begin gauge's base construction
	OpScript.P1_AISetup_ALLY01_Main()
end

function func_VICTORY_CheckForVictory(deadEnt, numCDRDeaths)
	-- If both commanders are dead
	LOG('----- func_VICTORY_CheckForVictory ' .. numCDRDeaths)
	if numCDRDeaths == 2 then
		-- goto victory
		NIS_VICTORY(deadEnt)
	-- otherwise
	else
		-- end the NIS with the standard nis function
		NIS.EndNIS_Standard()
	end
end

function func_VICTORY_GaugePickup()
	-- get Gauge in position
	IssueClearCommands( {ScenarioInfo.ALLYCYB_CDR} )
	IssueStop( {ScenarioInfo.ALLYCYB_CDR} )
	ScenarioInfo.ArmyBase_ALLY01_Main_Base:BaseActive(false)
	ScenarioInfo.ALLYCYB_CDR.PlatoonHandle:StopAI()
	NIS.HideAndWarpUnit( ScenarioInfo.ALLYCYB_CDR, GetPos('INTRONIS_Transport_Return_Marker') )

	-- create the transport
	ScenarioInfo.GAUGE_Transport_02 = import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_ALLY01', 'GAUGE_Transport_02')
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/29/09
	---			this specific case is only safe because these are throw-away units - bfricks 11/29/09
	local currSpeed = ScenarioInfo.GAUGE_Transport_02:GetBlueprint().Air.MaxAirspeed
	local destSpeed = 15.0
	local multSpeed = destSpeed/currSpeed

	if multSpeed != 1.0 then
		-- modify the speeds
		ScenarioInfo.GAUGE_Transport_02:SetSpeedMult(multSpeed)
		ScenarioInfo.GAUGE_Transport_02:SetNavMaxSpeedMultiplier(multSpeed)

		LOG('NIS: TransportArrival: adjusting speed of transport: currSpeed:[', currSpeed, '] multSpeed:[', multSpeed, ']')
	end
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	IssueMove({ScenarioInfo.GAUGE_Transport_02}, GetPos('INTRONIS_Transport_Return_Marker'))
	IssueTransportLoad( {ScenarioInfo.ALLYCYB_CDR}, ScenarioInfo.GAUGE_Transport_02 )
end

function func_VICTORY_GaugeExit()
	IssueMove( {ScenarioInfo.GAUGE_Transport_02}, GetPos('ALLY_Transport_Return_Marker_02') )
end