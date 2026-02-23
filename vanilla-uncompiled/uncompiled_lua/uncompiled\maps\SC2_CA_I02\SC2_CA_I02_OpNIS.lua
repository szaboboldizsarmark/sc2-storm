---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_I02/SC2_CA_I02_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_I02/SC2_CA_I02_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_I02/SC2_CA_I02_script.lua')
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
	local nOverrideZoom	= 200.0

	if ScenarioInfo.Options.NoNIS then
		-- skip away
		SkipOpeningNIS(
			function()
				func_OPENING_AllowDeaths(true)
				func_OPENING_PlayerTransportSequence(true)
				func_OPENING_MoveEnemyLand(true)
				func_OPENING_ForceDeaths(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('I02_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.I02_NIS_OP_SETUP_010)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.I02_NIS_OPENING_010,
			OpDialog.I02_NIS_OP_SETUP_010,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('I02_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance and a start position
	NIS.StartNIS_Opening('NIS_CAM_A_01', 10.0,'NIS_CAM_A_01',45.0)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	--Allow all of the enemy AA and PDs to die
	--Allow initial enemy land group to die
	func_OPENING_AllowDeaths()

	--
	--Part I: 19 seconds of VO
	--

	ForkThread(
		function()
			WaitSeconds(6.5)
			func_OPENING_PlayerTransportSequence()
		end
	)

	--Final VO: 17.6 seconds
	NIS.CreateVizMarker('NIS_VISMARKER', 80)
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_CAM_A_02'), GetOrient('NIS_CAM_A_02'), 150.0, 7.5)

			NIS.SetFOV(80)
			NIS.ZoomTo(GetPos('NIS_CAM_A_03'), GetOrient('NIS_CAM_A_03'), -12.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_A_04'), GetOrient('NIS_CAM_A_04'), -5.0, 7.5)

			NIS.SetFOV(60)
			NIS.ZoomTo(GetPos('NIS_CAM_D_01'), GetOrient('NIS_CAM_D_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_D_02'), GetOrient('NIS_CAM_D_02'), 0.0, 3.0)

			NIS.SetFOV(50)
			NIS.ZoomTo(GetPos('NIS_CAM_E_01'), GetOrient('NIS_CAM_E_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_E_02'), GetOrient('NIS_CAM_E_02'), 0.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.I02_NIS_OPENING_010)

	-- Create viz markers to see the enemies
	NIS.CreateVizMarker('NIS_SWARM_01', 80)
	NIS.CreateVizMarker('PAN_01', 50)
	NIS.CreateVizMarker('PAN_02', 50)

	--Final VO: 9.1 seconds
	ForkThread(
		function()
			NIS.SetFOV(40)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.INTRONIS_Group1Transport,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= -160.0,									-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,										-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 35.0,										-- how close to track relative to the unit
					nTrackToDuration	= 0.0,										-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
				}
			)
            WaitSeconds(3.0)

         	NIS.SetFOV(75)
			NIS.ZoomTo(GetPos('NIS_CAM_B_01'), GetOrient('NIS_CAM_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_B_02'), GetOrient('NIS_CAM_B_02'), 0.0, 4.0)

			func_OPENING_MoveEnemyLand()

			NIS.SetFOV(60)
			NIS.ZoomTo(GetPos('NIS_CAM_C_01'), GetOrient('NIS_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_C_02'), GetOrient('NIS_CAM_C_02'), 5.0, 4.0)
		end
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_OPENING_EnterCombat')
	NIS.Dialog(OpDialog.I02_NIS_OP_SETUP_010)

	--Kill off any remaining units in the initial land group before the OP starts
	func_OPENING_ForceDeaths()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)
end

---------------------------------------------------------------------
-- NIS_REVEAL_ENEMY:
---------------------------------------------------------------------
function NIS_REVEAL_ENEMY()

	NIS.PreloadDialogData(
		{
			OpDialog.I02_NIS_REVEAL_ENEMY_010,
			OpDialog.I02_NIS_REVEAL_ENEMY_020,
			OpDialog.I02_NIS_REVEAL_ENEMY_030,
			OpDialog.I02_NIS_REVEAL_ENEMY_OP_SETUP,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('P2_Research_Area_Marker', 250)

	-- disable base and hide Urchinow
	func_REVEAL_ENEMY_BaseDeActivate()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_REVEAL_ENEMY_Start')

	-- use StartNIS_MidOp to expand the playable area and allow a smooth camera reveal
	NIS.StartNIS_MidOp('P2_Playable_Area')

	-- Slight pause after starting the NIS
	WaitSeconds(1.0)

	--Final VO: 7.9 seconds
	ForkThread(
		function()
			NIS.SetFOV(35.0)--WS Panning the Factories
			NIS.ZoomTo(GetPos('NIS_REVEAL_FACTORY_PAN_03'), GetOrient('NIS_REVEAL_FACTORY_PAN_03'), 10.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_REVEAL_FACTORY_PAN_04'), GetOrient('NIS_REVEAL_FACTORY_PAN_04'), 10.0, 6.0)

			NIS.SetFOV(45.0)--LA CU on Exp. Fac. as Alarm turns on.
			NIS.ZoomTo(GetPos('NIS2_CAM_E_01'), GetOrient('NIS2_CAM_E_01'), 10.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_E_02'), GetOrient('NIS2_CAM_E_02'), 10.0, 5.9)
		end
	)
	NIS.Dialog(OpDialog.I02_NIS_REVEAL_ENEMY_010)

	-- start the alarm
	func_REVEAL_ENEMY_Alarm()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_REVEAL_ENEMY_Alarm')

	--Hold to finish camera move in fork, and for drama...
	WaitSeconds(3.5)

	-- Currently not forked; could fork if required to time properly
	LOG('REVEAL: Activate the base/move out units')

	ForkThread(
		function()
			func_REVEAL_ENEMY_EscortMove()
			func_REVEAL_ENEMY_BaseActivate()
			WaitSeconds(3.0)
			func_REVEAL_ENEMY_EastAir()
			func_REVEAL_ENEMY_EastDefenseMove()
			func_REVEAL_ENEMY_WestAir()
			func_REVEAL_ENEMY_WestDefenseMove()
		end
	)

	--Final VO: 10.3 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)--HA LS of West Factory switching on.
			NIS.ZoomTo(GetPos('NIS_REVEAL_04'), GetOrient('NIS_REVEAL_04'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_REVEAL_05'), GetOrient('NIS_REVEAL_05'), 0.0, 5.0)

			NIS.SetFOV(75.0)--REV WS of active factories.
			NIS.ZoomTo(GetPos('NIS_REVEAL_FACTORY_PAN_02'), GetOrient('NIS_REVEAL_FACTORY_PAN_02'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_REVEAL_FACTORY_PAN_01'), GetOrient('NIS_REVEAL_FACTORY_PAN_01'), 5.0, 7.3)
		end
	)
	NIS.Dialog(OpDialog.I02_NIS_REVEAL_ENEMY_020)

	-- Assault Block Reveal
	func_REVEAL_ENEMY_AssaultBlockMove()
	func_REVEAL_ENEMY_LandAttackMove()

	WaitSeconds(2.0)

	--Final VO: 9.3 seconds
	ForkThread(
		function()
			NIS.SetFOV(75.0)--LA Pan Left as AssaultBlock moves forward.
			NIS.ZoomTo(GetPos('NIS2_CAM_A_01'), GetOrient('NIS2_CAM_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_A_02'), GetOrient('NIS2_CAM_A_02'), 0.0, 9.3)
		end
	)
	NIS.Dialog(OpDialog.I02_NIS_REVEAL_ENEMY_030)

	NIS.CreateArrow('NIS_ARROW_01', 15.0)
	NIS.CreateArrow('NIS_ARROW_02', 15.0)
	NIS.CreateArrow('NIS_ARROW_03', 10.0)
	NIS.CreateArrow('NIS_ARROW_04', 10.0)
	NIS.CreateArrow('NIS_ARROW_05', 15.0)
	NIS.CreateArrow('NIS_ARROW_06', 15.0)

	func_REVEAL_ENEMY_BaseReset()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_REVEAL_ENEMY_End')

	-- use EndNIS_MidOp and restore to the player
	---NOTE: intentionally flush the intel - bfricks 10/31/09
	NIS.EndNIS_MidOp(true)

	NIS.DialogNoWait(OpDialog.I02_NIS_REVEAL_ENEMY_OP_SETUP)
end
---------------------------------------------------------------------
-- NIS_COLOSSUS:
---------------------------------------------------------------------
function NIS_COLOSSUS()

	NIS.PreloadDialogData(
		{
			OpDialog.I02_P2_COLOSSUS_REVEALED_010,
			OpDialog.I02_P2_COLOSSUS_REVEALED_020,
			OpDialog.I02_P2_COLOSSUS_REVEALED_030,
		}
	)

	-- setup the colossus and factory before we continue
	func_NIS_COLOSSUS_Setup()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_COLOSSUS_Start')

	NIS.StartNIS_MidOp()

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('P2_Research_Area_Marker', 250)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_COLOSSUS_Reveal')

	NIS.Dialog(OpDialog.I02_P2_COLOSSUS_REVEALED_010)--2.0

	func_NIS_COLOSSUS_RaisePlatform()

	WaitSeconds(1.0)

	NIS.SetFOV(25.0)
	NIS.ZoomTo(GetPos('NIS_COLOSSUS_REVEAL_06'), GetOrient('NIS_COLOSSUS_REVEAL_06'), 0.0, 0.0)
	NIS.ZoomTo(GetPos('NIS_COLOSSUS_REVEAL_06'), GetOrient('NIS_COLOSSUS_REVEAL_06'), 5.0, 1.0)

	ForkThread(
		function()
			NIS.SetFOV(30.0)
			NIS.ZoomTo(GetPos('NIS_COLOSSUS_REVEAL_05'), GetOrient('NIS_COLOSSUS_REVEAL_05'), 10.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_COLOSSUS_REVEAL_03'), GetOrient('NIS_COLOSSUS_REVEAL_03'), 50.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.I02_P2_COLOSSUS_REVEALED_020)--1.4

	-- release the colossus and destroy the factory
	func_NIS_COLOSSUS_ReleaseColossus()

	WaitSeconds(1.0)

	NIS.Dialog(OpDialog.I02_P2_COLOSSUS_REVEALED_030)--1.5

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_COLOSSUS_End')

	-- use EndNIS_MidOp and restore to the player
	NIS.EndNIS_MidOp()
end
---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.I02_NIS_VICTORY_010,
			OpDialog.I02_NIS_VICTORY_020,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I02_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	-- do a basic zoomto to the death unit (optionally this could be a trackto)
	-- this should NOT be forked - it needs to occur before we do any dialog
	NIS.SetFOV(30.0, 2.0)
	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit				= deathUnit,	-- unit to be killed
			vizRadius			= 300,			-- optional distance for a visibility marker ring
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 10.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 150.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 5.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)

	NIS.SetZoom(150.0, 0.0)
	NIS.SetZoom(50.0, 0.75)

	WaitSeconds(6.0)

	--Final VO: 5.2 seconds
	-- fork this part - so it happens while the dialog is going down
	ForkThread(
		function()
			WaitSeconds(2.0)
			NIS.EntitySpinRelative(
				{
					ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 35.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.01,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 50.0,			-- how close to spin relative to the unit
					nSpinDuration		= 300.0,		-- how long to allow the spin to persist
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 0.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I02_NIS_VICTORY_010)

	-- wreck the base
	ForkThread(func_VICTORY_DestroyBase)

	--Final VO: 15.4 seconds
	NIS.Dialog(OpDialog.I02_NIS_VICTORY_020)

	-- wrap up and not allow for optional gameplay
	NIS.EndNIS_Victory(nil, false)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_AllowDeaths(bSkip)
	-- when skipping, just kill them all
	if bSkip then
		NIS.ForceGroupDeath(ScenarioInfo.P1_ENEM01_Defense_KillOnStart)
		NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Bot_01)
		NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Bot_02)
		NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Tank_01)
		NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Tank_02)
		NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Tank_03)
		return
	end

	NIS.AllowGroupDeath(ScenarioInfo.P1_ENEM01_Defense_KillOnStart)
	NIS.AllowUnitDeath(ScenarioInfo.P1_ENEM01_Bot_01)
	NIS.AllowUnitDeath(ScenarioInfo.P1_ENEM01_Bot_02)
	NIS.AllowUnitDeath(ScenarioInfo.P1_ENEM01_Tank_01)
	NIS.AllowUnitDeath(ScenarioInfo.P1_ENEM01_Tank_02)
	NIS.AllowUnitDeath(ScenarioInfo.P1_ENEM01_Tank_03)
end

function func_OPENING_PlayerTransportSequence(bSkip)
	-- group1
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_Group1,				-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_Group1Transport,	-- unit handle for the actual transport
			approachChain			= 'NIS_TRANS01',							-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker_01',	-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= bSkip and false or true,					-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group01_Formup',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= func_OPENING_Kill_Group1Transport,		-- optional function to call when the transport finishes unloading
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
			approachChain			= 'NIS_TRANS02',							-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_03',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker_02',	-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= bSkip and false or true,					-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group02_Formup',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= func_OPENING_Kill_Group2Transport,		-- optional function to call when the transport finishes unloading
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
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_02',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker_03',	-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= bSkip and false or true,					-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= func_OPENING_GroupCDR_Attacks,			-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
end

function func_OPENING_Kill_Group1Transport()
	NIS.AllowUnitDeath(ScenarioInfo.INTRONIS_Group1Transport)
	WaitSeconds(1.0)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_Group1Transport)
end

function func_OPENING_Kill_Group2Transport()
	NIS.AllowUnitDeath(ScenarioInfo.INTRONIS_Group2Transport)
	WaitSeconds(4.5)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_Group2Transport)
end

function func_OPENING_GroupCDR_Attacks()
	-- move the CDR and engineers into position
	IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos( 'INTRONIS_CommanderDestination_Marker' ) )

	local eng01 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_PLAYER]['PLAYER_ENG01']
	IssueClearCommands( {ScenarioInfo.eng01} )
	IssueMove( {eng01}, GetPos( 'INTRONIS_EngineerDest_01' ) )

	local eng02 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_PLAYER]['PLAYER_ENG02']
	IssueClearCommands( {ScenarioInfo.eng02} )
	IssueMove( {eng02}, GetPos( 'INTRONIS_EngineerDest_02' ) )

	NIS.AllowUnitDeath(ScenarioInfo.INTRONIS_CommanderTransport)
	WaitSeconds(2.5)
	NIS.ForceUnitDeath(ScenarioInfo.INTRONIS_CommanderTransport)
end

function func_OPENING_MoveEnemyLand(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	IssueMove( {ScenarioInfo.P1_ENEM01_Bot_01}, GetPos( 'P1_ENEM01_Land_Marker_01' ) )
	IssueMove( {ScenarioInfo.P1_ENEM01_Bot_02}, GetPos( 'P1_ENEM01_Land_Marker_01' ) )
	IssueMove( {ScenarioInfo.P1_ENEM01_Tank_01}, GetPos('P1_ENEM01_Land_Marker_01' ) )
	IssueMove( {ScenarioInfo.P1_ENEM01_Tank_02}, GetPos( 'P1_ENEM01_Land_Marker_01' ) )
	IssueMove( {ScenarioInfo.P1_ENEM01_Tank_03}, GetPos( 'P1_ENEM01_Land_Marker_01' ) )
end

function func_OPENING_ForceDeaths(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Bot_01)
	NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Bot_02)
	NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Tank_01)
	NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Tank_02)
	NIS.ForceUnitDeath(ScenarioInfo.P1_ENEM01_Tank_03)
end

function func_REVEAL_ENEMY_Alarm()
	LOG('REVEAL: Turn on siren light')
	ScenarioInfo.P2_ENEM01_Experimental_Factory:TurnOnWarningLights()

	LOG('REVEAL: Play Siren Sound')
	CreateSimSyncSound( Sound{ Bank = 'SC2', Cue = 'Environments/s_env_generic_klax_lp_01' } )
end

function func_REVEAL_ENEMY_EscortMove()
	IssueFormMove( ScenarioInfo.AssaultBlockEscort:GetPlatoonUnits(), GetPos('P2_ENEM01_AssaultBlockEscort_Target'), 'AttackFormation', 0 )
end

function func_REVEAL_ENEMY_AssaultBlockMove()
	NIS.ShowUnit(ScenarioInfo.AssaultBlock)
	IssueFormMove( {ScenarioInfo.AssaultBlock}, GetPos('P2_ENEM01_AssaultBlock_Target'), 'AttackFormation', 0 )
end

function func_REVEAL_ENEMY_WestAir()
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_WestAirPatrol01 )
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_WestAirPatrol02 )
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_WestAirPatrol03 )
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_WestAirPatrol04 )

	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol01, GetPos('DEST_West_Air_01') )
	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol02, GetPos('DEST_West_Air_02') )
	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol03, GetPos('DEST_West_Air_03') )
	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol04, GetPos('DEST_West_Air_04') )

	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol01, GetPos('DEST_East_Air_End') )
	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol02, GetPos('DEST_East_Air_End') )
	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol03, GetPos('DEST_East_Air_End') )
	IssueMove( ScenarioInfo.P2_ENEM01_WestAirPatrol04, GetPos('DEST_East_Air_End') )
end

function func_REVEAL_ENEMY_EastAir()
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_EastAirPatrol01 )
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_EastAirPatrol02 )
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_EastAirPatrol03 )
	IssueClearCommands ( ScenarioInfo.P2_ENEM01_EastAirPatrol04 )

	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol01, GetPos('DEST_East_Air_01') )
	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol02, GetPos('DEST_East_Air_02') )
	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol03, GetPos('DEST_East_Air_03') )
	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol04, GetPos('DEST_East_Air_04') )

	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol01, GetPos('DEST_West_Air_End') )
	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol02, GetPos('DEST_West_Air_End') )
	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol03, GetPos('DEST_West_Air_End') )
	IssueMove( ScenarioInfo.P2_ENEM01_EastAirPatrol04, GetPos('DEST_West_Air_End') )
end

function func_REVEAL_ENEMY_WestDefenseMove()
	IssueFormMove( ScenarioInfo.P2_ENEM01_WestBase_Defense:GetPlatoonUnits(), GetPos('DEST_West_Land'), 'AttackFormation', 0 )
end

function func_REVEAL_ENEMY_EastDefenseMove()
	IssueFormMove( ScenarioInfo.P2_ENEM01_EastBase_Defense:GetPlatoonUnits(), GetPos('DEST_East_Land'), 'AttackFormation', 0 )
end

function func_REVEAL_ENEMY_LandAttackMove()
	IssueFormMove( ScenarioInfo.P2_ENEM01_Land_Attack:GetPlatoonUnits(), GetPos('DEST_Attack_Start'), 'AttackFormation', 0 )
end

function func_REVEAL_ENEMY_BaseReset()
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS, false)
	for k, unit in unitList do
		if EntityCategoryContains( categories.uib0001, unit ) then
			unit:SetBuildRate( ScenarioInfo.LandFactoryRestoreBuildRate )
		elseif EntityCategoryContains( categories.uib0002, unit ) then
			unit:SetBuildRate( ScenarioInfo.AirFactoryRestoreBuildRate )
		elseif EntityCategoryContains( categories.uib0202, unit ) then
			-- SHIELD GEN:
			unit:EnableShield()
		end
	end
end
function func_REVEAL_ENEMY_BaseDeActivate()
	NIS.HideUnit(ScenarioInfo.AssaultBlock)

	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS, false)

	for k, unit in unitList do
		if EntityCategoryContains( categories.uib0001, unit ) then
			-- LAND FACTORY: Disable and set build rate
			unit:DestroyIdleEffects()
			ScenarioInfo.LandFactoryRestoreBuildRate = unit:GetBlueprint().Economy.BuildRate
			unit:SetBuildRate( 4 )
		elseif EntityCategoryContains( categories.uib0002, unit ) then
			-- AIR FACTORY: disable and set build rate
			unit:DestroyIdleEffects()
			ScenarioInfo.AirFactoryRestoreBuildRate = unit:GetBlueprint().Economy.BuildRate
			unit:SetBuildRate( 4 )
		elseif EntityCategoryContains( categories.uib0202, unit ) then
			-- SHIELD GEN:
			unit:DestroyIdleEffects()
			unit:DisableShield()
		elseif EntityCategoryContains( categories.uib0702, unit ) then
			-- ENERGY PROD:
			unit:DestroyIdleEffects()
			if unit.Spinners then
				if unit.Spinners.Spinner1 then
					unit.Spinners.Spinner1:SetTargetSpeed(0)
				end
				if unit.Spinners.Spinner2 then
					unit.Spinners.Spinner2:SetTargetSpeed(0)
				end
				if unit.Spinners.Spinner3 then
					unit.Spinners.Spinner3:SetTargetSpeed(0)
				end
				if unit.Spinners.Spinner4 then
					unit.Spinners.Spinner4:SetTargetSpeed(0)
				end
				if unit.Spinners.Spinner5 then
					unit.Spinners.Spinner5:SetTargetSpeed(0)
				end
				if unit.Spinners.Spinner6 then
					unit.Spinners.Spinner6:SetTargetSpeed(0)
				end
			end
		elseif EntityCategoryContains( categories.uib0301, unit ) then
			-- RADAR:
			unit:DestroyIdleEffects()
			if unit.Spinners then
				if unit.Spinners.Spinner1 then
					unit.Spinners.Spinner1:SetTargetSpeed(0)
				end
				if unit.Spinners.Spinner2 then
					unit.Spinners.Spinner2:SetTargetSpeed(0)
				end
			end
		elseif EntityCategoryContains( categories.uib0801, unit ) then
			-- RESEARCH STATION:
			unit:DestroyIdleEffects()
			if unit.Spinners then
				if unit.Spinners.Spinner1 then
					unit.Spinners.Spinner1:SetTargetSpeed(0)
				end
				if unit.Spinners.Spinner2 then
					unit.Spinners.Spinner2:SetTargetSpeed(0)
				end
			end
		end
	end
end

function func_REVEAL_ENEMY_BaseActivate()
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS, false)

	for k, unit in unitList do
		if EntityCategoryContains( categories.uib0001, unit ) then
			-- LAND FACTORY:
			unit:CreateIdleEffects()
			IssueBuildFactory( {unit}, 'uil0101', 2 )

			-- add a callback - allowing us to cleanup these units
			unit.Callbacks.OnStopBuild:Add(
				function(builderUnit, builtUnit)
					if builtUnit and not builtUnit:IsDead() then
						import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').AddToNISOnlyEntities(builtUnit)
					end
				end
			)

		elseif EntityCategoryContains( categories.uib0002, unit ) then
			-- AIR FACTORY:
			unit:CreateIdleEffects()
			IssueBuildFactory( {unit}, 'uia0103', 2 )

			-- add a callback - allowing us to cleanup these units
			unit.Callbacks.OnStopBuild:Add(
				function(builderUnit, builtUnit)
					if builtUnit and not builtUnit:IsDead() then
						import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').AddToNISOnlyEntities(builtUnit)
					end
				end
			)

		elseif EntityCategoryContains( categories.uib0702, unit ) then
			-- ENERGY PROD:
			unit:CreateIdleEffects()
			if unit.Spinners then
				if unit.Spinners.Spinner1 then
					unit.Spinners.Spinner1:SetTargetSpeed(10)
				end
				if unit.Spinners.Spinner2 then
					unit.Spinners.Spinner2:SetTargetSpeed(20)
				end
				if unit.Spinners.Spinner3 then
					unit.Spinners.Spinner3:SetTargetSpeed(-30)
				end
				if unit.Spinners.Spinner4 then
					unit.Spinners.Spinner4:SetTargetSpeed(-30)
				end
				if unit.Spinners.Spinner5 then
					unit.Spinners.Spinner5:SetTargetSpeed(-30)
				end
				if unit.Spinners.Spinner6 then
					unit.Spinners.Spinner6:SetTargetSpeed(-30)
				end
			end
		elseif EntityCategoryContains( categories.uib0202, unit ) then
			-- SHIELD GEN:
			unit:CreateIdleEffects()
		elseif EntityCategoryContains( categories.uib0301, unit ) then
			-- RADAR:
			unit:CreateIdleEffects()
			if unit.Spinners then
				if unit.Spinners.Spinner1 then
					unit.Spinners.Spinner1:SetTargetSpeed(160)
				end
				if unit.Spinners.Spinner2 then
					unit.Spinners.Spinner2:SetTargetSpeed(-40)
				end
			end
		elseif EntityCategoryContains( categories.uib0801, unit ) then
			-- RESEARCH STATION:
			unit:CreateIdleEffects()
			if unit.Spinners then
				if unit.Spinners.Spinner1 then
					unit.Spinners.Spinner1:SetTargetSpeed(50)
				end
				if unit.Spinners.Spinner2 then
					unit.Spinners.Spinner2:SetTargetSpeed(50)
				end
			end
		end
	end
end

function func_NIS_COLOSSUS_Setup()
	NIS.HideUnit(ScenarioInfo.P2_Colossus)
	ScenarioInfo.P2_ENEM01_Experimental_Factory:FakeBuildStart(ScenarioInfo.P2_Colossus)
	WaitSeconds(1.0)
end

function func_NIS_COLOSSUS_RaisePlatform()
	NIS.ShowUnit(ScenarioInfo.P2_Colossus)
	ScenarioInfo.P2_ENEM01_Experimental_Factory:RaisePlatform(ScenarioInfo.P2_Colossus)
end

function func_NIS_COLOSSUS_ReleaseColossus()
	ScenarioInfo.P2_ENEM01_Experimental_Factory:FakeBuildComplete(ScenarioInfo.P2_Colossus)
	NIS.ForceUnitDeath(ScenarioInfo.P2_ENEM01_Experimental_Factory)
	IssueMove({ScenarioInfo.P2_Colossus}, GetPos('P1_ENEM01_Colossus_Attack_Chain_01'))
end

function func_VICTORY_DestroyBase()
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS - categories.scb9001, false)
	for k, unit in unitList do
		NIS.ForceUnitDeath(unit)
		WaitSeconds (import('/lua/system/utilities.lua').GetRandomInt(0,2))
	end
end
