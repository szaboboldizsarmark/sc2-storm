---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_U02/SC2_CA_U02_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_U02/SC2_CA_U02_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_U02/SC2_CA_U02_script.lua')
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
	local nOverrideZoom	= 140.0

	if ScenarioInfo.Options.NoNIS then
		-- skip away
		SkipOpeningNIS(
			function()
				func_OPENING_PlayerTransportSequence(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('U02_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.U02_NIS_OP_SETUP_020)
				NIS.DialogNoWait(OpDialog.U02_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.U02_NIS_OPENING_010,
			OpDialog.U02_NIS_OPENING_015,
			OpDialog.U02_NIS_OP_SETUP_010,
			OpDialog.U02_NIS_OP_SETUP_020,
			OpDialog.U02_NIS_OP_SETUP_END,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('U02_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS_CAM_OPENING_03', -50.0,'NIS_CAM_OPENING_03', 65.0 )

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	func_OPENING_PlayerTransportSequence()

	ForkThread(
		function()
			-- Track transport in
			NIS.ZoomTo(GetPos('NIS_CAM_OPENING_04'), GetOrient('NIS_CAM_OPENING_04'), 0.0, 14.0)
		end
	)
	WaitSeconds(4.0)
	NIS.Dialog(OpDialog.U02_NIS_OPENING_010) -- 8.5 (tons of damage)

	ForkThread(
		function()
			-- Track transport in
			NIS.ZoomTo(GetPos('TRANSPORT_CAM_01'), GetOrient('TRANSPORT_CAM_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('TRANSPORT_CAM_02'), GetOrient('TRANSPORT_CAM_02'), 30.0, 12.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_OPENING_015) -- 11.2 (maddox drop off)

	ForkThread(
		function()
			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_G_01'), GetOrient('NIS1_CAM_G_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_G_02'), GetOrient('NIS1_CAM_G_02'), 0.0, 4.0)

			NIS.ZoomTo(GetPos('NIS1_CAM_B_01'), GetOrient('NIS1_CAM_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_02'), GetOrient('NIS1_CAM_B_02'), 0.0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_OP_SETUP_010) -- Gunship problem: 7.4 seconds

	WaitSeconds(1.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U02_NIS_OPENING_ShowColeman')

	ForkThread(
		function()
			--Cam stuff at Alpha
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_03'), GetOrient('NIS1_CAM_E_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_04'), GetOrient('NIS1_CAM_E_04'), 10.0, 11.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_OP_SETUP_020) 	-- Get an air factory online: 10.4 seconds

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U02_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom, true)

	NIS.DialogNoWait(OpDialog.U02_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_REVEAL_ENEMY:
---------------------------------------------------------------------
function NIS_REVEAL_ENEMY()

	NIS.PreloadDialogData(
		{
			OpDialog.U02_NIS_ENEMY_REVEAL_010,
			OpDialog.U02_NIS_ENEMY_REVEAL_015,
			OpDialog.U02_NIS_ENEMY_REVEAL_020,
			OpDialog.U02_NIS_ENEMY_REVEAL_030,
			OpDialog.U02_NIS_ENEMY_REVEAL_OP_SETUP_010,
			OpDialog.U02_NIS_ENEMY_REVEAL_OP_SETUP_020,
			OpDialog.U02_NIS_ENEMY_REVEAL_OP_SETUP_END,
		}
	)

	-- prepare the ally CDR and engineers for the NIS.
	func_REVEAL_ENEMY_PrepareAllyUnits()

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('NIS_REVEAL_ENEMY_Vis_Marker', 90)
	NIS.CreateVizMarker('NIS_REVEAL_ENEMY_South_VisMarker', 90)
	NIS.CreateVizMarker('P2_IntroNIS_AllyTransport_VisLoc_01', 90)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U02_NIS_REVEAL_ENEMY_Start')

	-- use StartNIS_MidOp to expand the playable area and allow a smooth camera reveal
	NIS.StartNIS_MidOp('AREA_3')

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_MIDOP_START_01'), GetOrient('NIS_MIDOP_START_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_START_02'), GetOrient('NIS_MIDOP_START_02'), 0.0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_ENEMY_REVEAL_010) -- Charlie is clear (4 seconds)

	-- pick up the Ally CDR
	func_REVEAL_ENEMY_Transport_Pickup()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS2_CAM_C_03'), GetOrient('NIS2_CAM_C_03'), 10.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_C_04'), GetOrient('NIS2_CAM_C_04'), -20.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_ENEMY_REVEAL_015) -- Coleman has new orders (5.8 secs)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.P2_IntroNIS_AllyTransport,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 175.0,									-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -5.0,										-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 20.0,										-- how close to track relative to the unit
					nTrackToDuration	= 3.0,										-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= -3.0,										-- if specified, offset in the X direction
					nOffsetY			= 1.0,										-- if specified, offset in the Y direction
					nOffsetZ			= -1.0										-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_ENEMY_REVEAL_020) -- Coleman says good bye (3.3 secs)

	WaitSeconds(1.0)

	-- clean up the ally CDR transport
	func_REVEAL_ENEMY_AllyCDR_Cleanup()

	-- Final VO timing: 3.3 seconds
	ForkThread(
		function()
			--Cam Stuff: Show base conversaion mixed in here (or fork factory reveals separate from cameras)
			-- Swap each of the 3 ally factories to the player, one at a time.
			WaitSeconds(1.0)
			func_REVEAL_ENEMY_SwapWestFactory()
			WaitSeconds(1.5)
			func_REVEAL_ENEMY_SwapMiddleFactory()
			WaitSeconds(1.0)
			func_REVEAL_ENEMY_SwapEastFactory()
			WaitSeconds(2.0)
			-- Then, swap the rest of the ally units over.
			func_REVEAL_ENEMY_SwapUnits()
		end
	)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS2_CAM_B_03'), GetOrient('NIS2_CAM_B_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_B_04'), GetOrient('NIS2_CAM_B_04'), 0.0, 5.0)

			NIS.ZoomTo(GetPos('NIS2_CAM_D_07'), GetOrient('NIS2_CAM_D_07'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_CAM_D_08'), GetOrient('NIS2_CAM_D_08'), 0.0, 8.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_ENEMY_REVEAL_030) -- Army switch (8.8 seconds)

	ForkThread(
		function()
			WaitSeconds(5.0)
			NIS.CreateArrow('FACTORY_ARROWS_01', 10.0)
			NIS.CreateArrow('FACTORY_ARROWS_02', 10.0)
			NIS.CreateArrow('FACTORY_ARROWS_03', 10.0)
			NIS.CreateArrow('FACTORY_ARROWS_04', 10.0)
			NIS.CreateArrow('FACTORY_ARROWS_05', 10.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_ENEMY_REVEAL_OP_SETUP_010) -- Reveal base/factories (6.9 secs)

	NIS.Dialog(OpDialog.U02_NIS_ENEMY_REVEAL_OP_SETUP_020) -- AA in west/PD in east (7.6 secs)

	-- clean up the ally transport
	func_REVEAL_ENEMY_Transport_Cleanup()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U02_NIS_REVEAL_ENEMY_End')

	-- use EndNIS_MidOp and restore to the player
	---NOTE: intentionally flush the intel - bfricks 10/31/09
	NIS.EndNIS_MidOp(true)

	NIS.DialogNoWait(OpDialog.U02_NIS_ENEMY_REVEAL_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY()

	NIS.PreloadDialogData(
		{
			OpDialog.U02_NIS_VICTORY_010,
			OpDialog.U02_NIS_VICTORY_020,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('NIS_REVEAL_ENEMY_Vis_Marker', 150)
	NIS.CreateVizMarker('NIS_REVEAL_ENEMY_South_VisMarker', 150)
	NIS.CreateVizMarker('P2_IntroNIS_AllyTransport_VisLoc_01', 150)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U02_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueStop( {ScenarioInfo.PLAYER_CDR} )

	func_VICTORY_ExitTransport()

	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_3_01'), GetOrient('NIS_VIC_CAM_SHOT_3_01'), 0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_3_02'), GetOrient('NIS_VIC_CAM_SHOT_3_02'), 0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.U02_NIS_VICTORY_010) --4.5 seconds

	func_VICTORY_TransportPickup()

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 165.0,					-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,						-- how close to track relative to the unit
					nTrackToDuration	= 4.0,						-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,						-- if specified, offset in the X direction
					nOffsetY			= 2.0,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0						-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(3.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ExitTransport,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 0.0,							-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 25.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 90.0,							-- how close to track relative to the unit
					nTrackToDuration	= 3.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0							-- if specified, offset in the Z direction
				}
			)
		end
	)
	-- Final VO timing: 15.8 seconds
	NIS.Dialog(OpDialog.U02_NIS_VICTORY_020)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
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
			approachChain			= 'TRANSPORT_ARRIVAL_PATH',					-- optional chainName for the approach travel route
			unloadDest				= 'INTRONIS_Transport_Landing_Marker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_Transport_Return_01',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'INTRONIS_Transport_Group_Formup_01',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,										-- will this transport be usable after the NIS?
		},
		bSkip
	)
end

function func_REVEAL_ENEMY_PrepareAllyUnits()
	-- at the start of the NIS, we need to remove all engineers (and the commander) from the
	-- the list of engineers that the ally base manager controls. This is so the base manager
	-- doesnt move these units around during our NIS. This needs to take place prior to any
	-- unit swapping or movement for the ally.
	local engineers = ArmyBrains[ScenarioInfo.ARMY_ALLY01]:GetListOfUnits(categories.uul0002, false)
	for k, v in engineers do
		if v and not v:IsDead() then
			ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:RemoveEngineer(v)
		end
	end
	ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:RemoveEngineer(ScenarioInfo.ALLY01_CDR)
end

function func_REVEAL_ENEMY_Transport_Pickup()
	-- Create transport, shut down Coleman and his base AI
	ScenarioInfo.P2_IntroNIS_AllyTransport = NIS.CreateNISOnlyUnit('ARMY_ALLY01', 'P2_IntroNIS_AllyCarrier')
	ScenarioInfo.ArmyBase_P1_ALLY01_MainBase:BaseActive(false)
	ScenarioInfo.ALLY01_CDR.PlatoonHandle:StopAI()

	IssueClearCommands({ScenarioInfo.ALLY01_CDR})
	IssueStop({ScenarioInfo.ALLY01_CDR})
	Warp( ScenarioInfo.ALLY01_CDR, GetPos('P2_IntroNIS_AllyCDR_WarpTo_Destination'))
	WaitSeconds(0.1)

	IssueMove({ScenarioInfo.ALLY01_CDR}, GetPos('P2_IntroNIS_Transport_MoveTo_Destination'))

	IssueClearCommands({ScenarioInfo.P2_IntroNIS_AllyTransport})
	IssueMove( {ScenarioInfo.P2_IntroNIS_AllyTransport}, GetPos('P2_IntroNIS_Transport_MoveTo_Destination') )
	IssueTransportLoad({ScenarioInfo.ALLY01_CDR}, ScenarioInfo.P2_IntroNIS_AllyTransport )
	IssueMove({ScenarioInfo.P2_IntroNIS_AllyTransport}, GetPos('P2_IntroNIS_Transport_Return_Destination'))
end

function func_REVEAL_ENEMY_SwapWestFactory()
	-- Swap the west factory to player army
	if ScenarioInfo.P1_ALLY_Factory_01 and not ScenarioInfo.P1_ALLY_Factory_01:IsDead() then
		import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy(ScenarioInfo.P1_ALLY_Factory_01, ScenarioInfo.ARMY_PLAYER)
	end
end

function func_REVEAL_ENEMY_SwapMiddleFactory()
	-- Swap the middle factory to player army
	if ScenarioInfo.P1_ALLY_Factory_02 and not ScenarioInfo.P1_ALLY_Factory_02:IsDead() then
		import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy(ScenarioInfo.P1_ALLY_Factory_02, ScenarioInfo.ARMY_PLAYER)
	end
end

function func_REVEAL_ENEMY_SwapEastFactory()
	-- Swap the east factory to player army
	if ScenarioInfo.P1_ALLY_Factory_03 and not ScenarioInfo.P1_ALLY_Factory_03:IsDead() then
		import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy(ScenarioInfo.P1_ALLY_Factory_03, ScenarioInfo.ARMY_PLAYER)
	end
end

function func_REVEAL_ENEMY_SwapUnits()
	-- Swap the ally units to the player army:

	-- (Not for the NIS) before we swap the whole ally army, swap any existing attack platoons, and give
	-- them a patrol, so they dont appeared stalled when given to the player. This needs to happen before the main unit swap below.
	for k, platoon in ScenarioInfo.P1_AllyPlatoonTable do
		if platoon and ArmyBrains[ScenarioInfo.ARMY_ALLY01]:PlatoonExists(platoon) then
			if table.getn(platoon:GetPlatoonUnits()) > 0 then
				local newPlatoon = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:MakePlatoon('', '')
				for k, unit in platoon:GetPlatoonUnits() do
					if unit and not unit:IsDead() then
						local newUnit = import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy(unit, ScenarioInfo.ARMY_PLAYER)
						if newUnit and not newUnit:IsDead() then -- not as paranoid as you might think.
							ArmyBrains[ScenarioInfo.ARMY_PLAYER]:AssignUnitsToPlatoon( newPlatoon, {newUnit}, 'Attack', 'AttackFormation' )
						end
					end
				end
				import('/lua/sim/ScenarioFramework.lua').PlatoonPatrolChain (newPlatoon, 'P2_ALLY01_LandAttack_01')
			end
		end
	end

	-- get ally units, minus transports (potentially from NIS), ally commander, and factories (which are swapped separately).
	local units = ArmyBrains[ScenarioInfo.ARMY_ALLY01]:GetListOfUnits(categories.ALLUNITS - categories.uul0001 - categories.uua0901 - categories.uub0001, false)
	for k, v in units do
		if v and not v:IsDead() then
			import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy(v, ScenarioInfo.ARMY_PLAYER)
		end
	end
end

function func_REVEAL_ENEMY_AllyCDR_Cleanup()
	NIS.DestroyUnit(ScenarioInfo.ALLY01_CDR)
end

function func_REVEAL_ENEMY_Transport_Cleanup()
	NIS.DestroyUnit(ScenarioInfo.P2_IntroNIS_AllyTransport)
end

function func_VICTORY_TransportPickup()
	IssueTransportLoad({ScenarioInfo.PLAYER_CDR}, ScenarioInfo.ExitTransport )
	IssueMove({ScenarioInfo.ExitTransport}, GetPos('TRANSPORT_DESTINATION'))
end

function func_VICTORY_ExitTransport()
	ScenarioInfo.ExitTransport = NIS.CreateNISOnlyUnit('ARMY_PLAYER','ExitTransport')
	IssueClearCommands({ScenarioInfo.ExitTransport})
	Warp(ScenarioInfo.ExitTransport, GetPos('TRANSPORT_ARRIVAL_PATH_02'))
	IssueMove({ScenarioInfo.ExitTransport}, GetPos('INTRONIS_Transport_Landing_Marker_01'))

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	Warp(ScenarioInfo.PLAYER_CDR, GetPos('INTRONIS_Transport_Group_Formup_01'))
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('INTRONIS_Transport_Landing_Marker_01'))
end