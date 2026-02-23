---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings	= import('/maps/SC2_CA_I03/SC2_CA_I03_OpStrings.lua')
local OpDialog	= import('/maps/SC2_CA_I03/SC2_CA_I03_OpDialog.lua')
local OpScript	= import('/maps/SC2_CA_I03/SC2_CA_I03_script.lua')
local NIS		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua')
local GetPos	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetPos
local GetOrient	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetOrient
local SkipOpeningNIS	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').SkipOpeningNIS
local SkipMidOpNIS		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').SkipMidOpNIS

---------------------------------------------------------------------
-- NIS_OPENING:
---------------------------------------------------------------------
function NIS_OPENING()
	-- set ending camera zoom
	local nOverrideZoom	= 80.0

	if ScenarioInfo.Options.NoNIS then
		-- skip away
		SkipOpeningNIS(
			function()
				func_OPENING_AllowOutpostDeath(true)
				func_OPENING_PlayerTransportSequence(true)
				---NOTE: this is a potential solution to inconsistent flight durations - if this is not deemed appropriate we will need to
				---			consider fake ACUs for the NIS - bfricks 10/28/09
				while not ScenarioInfo.CDR_LANDED do
					WARN('WARNING: NIS paused due to CDR not being in position for scripted commands - if this spams, pass to campaign design.')
					WaitTicks(1)
				end
				func_OPENING_PlayerCDR_Capture(true)
				func_OPENING_DestroyExtraAC1000(true)

				WaitSeconds(3.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('I03_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.I03_NIS_OP_SETUP_020)
				NIS.DialogNoWait(OpDialog.I03_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.I03_NIS_OPENING_010,
			OpDialog.I03_NIS_OPENING_020,
			OpDialog.I03_NIS_OP_SETUP_010,
			OpDialog.I03_NIS_OP_SETUP_020,
			OpDialog.I03_NIS_OP_SETUP_END,
		}
	)

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance
	func_OPENING_PlayerTransportSequence()

	NIS.CreateVizMarker('ARMY_ENEM01', 200)
	NIS.CreateVizMarker('ARMY_PLAYER', 50)
	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('I03_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance and a start position
	NIS.StartNIS_Opening('NIS1_CAM_A_01', 0.0, 'NIS1_CAM_A_01', 65.0)

	-- Allow all of the enemy base structures in the central outpost to die
	func_OPENING_AllowOutpostDeath()

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	-- while dialog begins, use the starting shot and zoom in
	--Final VO: 17.3 seconds
	ForkThread(
		function()
			--Zoom from OPENING POS/ORIENT
			NIS.ZoomTo(GetPos('NIS1_CAM_A_02'), GetOrient('NIS1_CAM_A_02'), 0.0, 12.0)

			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_01'), GetOrient('NIS1_CAM_B_01'), 20.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_02'), GetOrient('NIS1_CAM_B_02'), 0.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.I03_NIS_OPENING_010)
	WaitSeconds(3.3)

	ForkThread(
		function()
			NIS.SetFOV(65.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_F_01'), GetOrient('NIS1_CAM_F_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_F_03'), GetOrient('NIS1_CAM_F_03'), 10.0, 9.4)

			---NOTE: this is potentially not safe - as the units may or may not have landed yet - bfricks 12/5/09
			func_OPENING_PlayerCDR_Capture()
		end
	)
	NIS.Dialog(OpDialog.I03_NIS_OPENING_020)

	---NOTE: this is a potential solution to inconsistent flight durations - if this is not deemed appropriate we will need to
	---			consider fake ACUs for the NIS - bfricks 10/28/09
	while not ScenarioInfo.CDR_LANDED do
		WARN('WARNING: NIS paused due to CDR not being in position for scripted commands - if this spams, pass to campaign design.')
		WaitTicks(1)
	end

	--Final VO: 14.3 seconds
	ForkThread(
		function()
			NIS.SetFOV(65.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_01'), GetOrient('NIS1_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_02'), GetOrient('NIS1_CAM_C_02'), 1.0, 3.0)
			WaitSeconds(1.0)

			NIS.SetFOV(85.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_01'), GetOrient('NIS1_CAM_D_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_02'), GetOrient('NIS1_CAM_D_02'), 0.0, 13.3)
		end
	)
	WaitSeconds(3.0)
	NIS.Dialog(OpDialog.I03_NIS_OP_SETUP_010)

	--Final VO: 10.3 seconds
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_01'), GetOrient('NIS1_CAM_E_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_02'), GetOrient('NIS1_CAM_E_02'), 0.0, 10.3)
		end
	)
	NIS.Dialog(OpDialog.I03_NIS_OP_SETUP_020)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I03_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	--Final VO: 1.3 seconds
	NIS.DialogNoWait(OpDialog.I03_NIS_OP_SETUP_END)

	-- Destroy the INTRO NIS AC1000s
	func_OPENING_DestroyExtraAC1000()
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY()

	NIS.PreloadDialogData(
		{
			OpDialog.I03_NIS_VICTORY_010,
			OpDialog.I03_NIS_VICTORY_020,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I03_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	-- setup the transport pickup
	func_VICTORY_TransportPickup()

	--Final VO: 2.6 seconds
	ForkThread(
		function()
			NIS.SetFOV(70.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_G_07'), GetOrient('NIS1_CAM_G_07'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_G_08'), GetOrient('NIS1_CAM_G_08'), 0.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.I03_NIS_VICTORY_010)

	WaitSeconds(6.0)

	-- send the transport away
	func_VICTORY_TransportExit()

	--Final VO: 12.5 seconds
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_H_03'), GetOrient('NIS1_CAM_H_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_H_04'), GetOrient('NIS1_CAM_H_04'), 0.0, 8.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.NIS_PICKUP_TRANSPORT,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= -160.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 35.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
				}
			)
		end
	)
	NIS.Dialog(OpDialog.I03_NIS_VICTORY_020)

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
			returnDest				= 'INTRONIS_Transport_Return_03',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group_Formup_01',		-- optional destination for the group to be moved to after being dropped-off
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
			returnDest				= 'INTRONIS_Transport_Return_01',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group_Formup_02',		-- optional destination for the group to be moved to after being dropped-off
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
			returnDest				= 'INTRONIS_Transport_Return_02',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group_Formup_03',		-- optional destination for the group to be moved to after being dropped-off
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
	IssueMove( {eng01}, GetPos( 'INTRONIS_EngineerDest_01' ) )

	local eng02 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_PLAYER]['PLAYER_ENG02']
	IssueClearCommands( {eng02} )
	IssueMove( {eng02}, GetPos( 'INTRONIS_EngineerDest_02' ) )

	-- Give the INTRO NIS AC1000s a series of move commands
	NIS.GroupMoveChain(ScenarioInfo.INTRONIS_AC1000_West, 'INTRONIS_West_AC1000_Chain')
	NIS.GroupMoveChain(ScenarioInfo.INTRONIS_AC1000_East, 'INTRONIS_East_AC1000_Chain')

	-- Do it again so they stay busy for the whole NIS
	NIS.GroupMoveChain(ScenarioInfo.INTRONIS_AC1000_West, 'INTRONIS_West_AC1000_Chain')
	NIS.GroupMoveChain(ScenarioInfo.INTRONIS_AC1000_East, 'INTRONIS_East_AC1000_Chain')
end

function func_OPENING_AllowOutpostDeath(bSkip)
	-- when skipping, just kill them all
	if bSkip then
		NIS.ForceGroupDeath(ScenarioInfo.INTRONIS_Outpost)
		return
	end

	NIS.UnProtectGroup(ScenarioInfo.INTRONIS_Outpost)
end

function func_OPENING_PlayerCDR_Capture(bSkip)
	if bSkip then
		import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy(ScenarioInfo.P1_ENEM01_Intel, ScenarioInfo.ARMY_PLAYER)
		return
	end

	IssueCapture( {ScenarioInfo.PLAYER_CDR}, ScenarioInfo.P1_ENEM01_Intel )
end

function func_OPENING_DestroyExtraAC1000(bSkip)
	---NOTE: bSkip is not needed - this function is non-latent - bfricks 12/5/09

	NIS.DestroyGroup(ScenarioInfo.INTRONIS_AC1000_West)
	NIS.DestroyGroup(ScenarioInfo.INTRONIS_AC1000_East)
end
function func_VICTORY_TransportPickup()
	-- get the player ACU in position
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueStop({ScenarioInfo.PLAYER_CDR})
	NIS.HideAndWarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('NIS_WARP_POINT'))

	-- move the player toward our pick-up point
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('NIS_TRANSPORT_DESTINATION'))

	-- create the transport
	ScenarioInfo.NIS_PICKUP_TRANSPORT = import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit('ARMY_PLAYER', 'NIS_PICKUP_TRANSPORT')
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/29/09
	---			this specific case is only safe because these are throw-away units - bfricks 11/29/09
	local currSpeed = ScenarioInfo.NIS_PICKUP_TRANSPORT:GetBlueprint().Air.MaxAirspeed
	local destSpeed = 15.0
	local multSpeed = destSpeed/currSpeed

	if multSpeed != 1.0 then
		-- modify the speeds
		ScenarioInfo.NIS_PICKUP_TRANSPORT:SetSpeedMult(multSpeed)
		ScenarioInfo.NIS_PICKUP_TRANSPORT:SetNavMaxSpeedMultiplier(multSpeed)

		LOG('NIS: TransportArrival: adjusting speed of transport: currSpeed:[', currSpeed, '] multSpeed:[', multSpeed, ']')
	end
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	IssueMove({ScenarioInfo.NIS_PICKUP_TRANSPORT}, GetPos('NIS_TRANSPORT_DESTINATION'))
	IssueTransportLoad( {ScenarioInfo.PLAYER_CDR}, ScenarioInfo.NIS_PICKUP_TRANSPORT )
end

function func_VICTORY_TransportExit()
	IssueMove({ScenarioInfo.NIS_PICKUP_TRANSPORT}, GetPos('NIS_TRANSPORT_DESTINATION01'))
end