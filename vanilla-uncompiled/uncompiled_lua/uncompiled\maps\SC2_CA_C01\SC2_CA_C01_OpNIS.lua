---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_C01/SC2_CA_C01_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_C01/SC2_CA_C01_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_C01/SC2_CA_C01_script.lua')
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

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('C01_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.C01_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.C01_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PlayMovie('/movies/FMV_CYB_OPENING')

	NIS.PreloadDialogData(
		{
			OpDialog.C01_NIS_OPENING_010,
			OpDialog.C01_NIS_OP_SETUP_010,
			OpDialog.C01_NIS_OP_SETUP_END,
		}
	)

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('C01_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS1_CAM_A_01', 40.0, 'NIS1_CAM_A_01', 55.0)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	func_OPENING_PlayerTransportSequence()

	--Final VO: 16.2 seconds
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_A_02'), GetOrient('NIS1_CAM_A_02'), 0.0, 10.0)

			NIS.SetFOV(50.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_01'), GetOrient('NIS1_CAM_B_01'), -30.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_02'), GetOrient('NIS1_CAM_B_02'), 0.0, 7.0)
		end
	)
	NIS.Dialog(OpDialog.C01_NIS_OPENING_010)

	--Final VO: 8.9 seconds
	ForkThread(
		function()
			WaitSeconds(1.0)
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_01'), GetOrient('NIS1_CAM_D_01'), 20.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_02'), GetOrient('NIS1_CAM_D_02'), 20.0, 7.0)
		end
	)
	NIS.Dialog(OpDialog.C01_NIS_OP_SETUP_010)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C01_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.C01_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY()
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C01_NIS_VICTORY_Start')

	NIS.PreloadDialogData(
		{
			OpDialog.C01_NIS_VICTORY_010,
			OpDialog.C01_NIS_VICTORY_015,
			OpDialog.C01_NIS_VICTORY_020,
		}
	)

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	NIS.CreateVizMarker('P1_Intro_NIS_VisLoc01', 200)

	func_VICTORY_MoveCDR_01()

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.P1_PLAYER_Gate,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 135.0,							-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 35.0,								-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 60.0,								-- how close to track relative to the unit
					nTrackToDuration	= 2.0,								-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,								-- if specified, offset in the X direction
					nOffsetY			= 1.0,								-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,								-- if specified, offset in the Z direction
				}
			)
			NIS.SetZoom(63.0, 4.0)
		end
	)
	WaitSeconds(2.0)

	NIS.Dialog(OpDialog.C01_NIS_VICTORY_010)	--Final VO: 1.2 seconds

	if ScenarioInfo.P1_PLAYER_Brain and not ScenarioInfo.P1_PLAYER_Brain:IsDead() then
		ForkThread(func_VICTORY_BaseDestruction)

		ForkThread(
			function()
				NIS.EntityTrackRelative(
					{
						ent					= ScenarioInfo.P1_PLAYER_Brain,		-- a handle to the in-game object being used as the center of the zoom
						degreesHeading		= 125.0,							-- heading offset relative to the unit (180.0 == frontside)
						degreesPitch		= 15.0,								-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
						nTrackDistance		= 35.0,								-- how close to track relative to the unit
						nTrackToDuration	= 10.0,								-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
						nOffsetX			= 0.0,								-- if specified, offset in the X direction
						nOffsetY			= 1.2,								-- if specified, offset in the Y direction
						nOffsetZ			= 0.0,								-- if specified, offset in the Z direction
					}
				)
				NIS.SetZoom(60.0, 10.0)
			end
		)
	end

	NIS.Dialog(OpDialog.C01_NIS_VICTORY_015)	--Final VO: 9.3 seconds

	func_VICTORY_MoveCDR_02()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_FINAL_CAM_02'), GetOrient('NIS_FINAL_CAM_02'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_FINAL_CAM_01'), GetOrient('NIS_FINAL_CAM_01'), 0.0, 13.0)
		end
	)
	NIS.Dialog(OpDialog.C01_NIS_VICTORY_020)	--Final VO: 9.5 seconds
	WaitSeconds(1.0)

	func_VICTORY_CleanupCDR()
	WaitSeconds(2.0)

	-- wrap up without optional continued gameplay
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
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_Marker_01',	-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_CommanderDestination_Marker',	-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
end

function func_VICTORY_MoveCDR_01()
	IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
	IssueStop ( {ScenarioInfo.PLAYER_CDR} )
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('TELEPORT_LOCATION01') )
end

function func_VICTORY_MoveCDR_02()
	IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
	IssueStop ( {ScenarioInfo.PLAYER_CDR} )

	Warp( ScenarioInfo.PLAYER_CDR, GetPos('TELEPORT_LOCATION01') )
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('TELEPORT_LOCATION') )
end

function func_VICTORY_CleanupCDR()
	CreateTeleportEffects( ScenarioInfo.PLAYER_CDR )
	NIS.HideUnit(ScenarioInfo.PLAYER_CDR)
end

function func_VICTORY_BaseDestruction()
	WaitSeconds(6.0)
	local pos = {}
	local brainPos = ScenarioInfo.P1_PLAYER_Brain:GetPosition()
	pos = {brainPos[1], brainPos[2], brainPos[3]}

	NIS.ForceUnitDeath(ScenarioInfo.P1_PLAYER_Brain)

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_PLAYER],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 150, true, 90001, 90001, brainList)
end
