---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_U01/SC2_CA_U01_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_U01/SC2_CA_U01_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_U01/SC2_CA_U01_script.lua')
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
				func_OPENING_MoveCDR(true)
				func_OPENING_MoveTanks(true)
				func_OPENING_CreateAndMoveTransport(true)
				func_OPENING_Nukes(true)
				func_OPENING_CourtyardAssault(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('U01_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.U01_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.U01_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PlayMovie('/movies/FMV_UEF_OPENING')

	NIS.PreloadDialogData(
		{
			OpDialog.U01_NIS_OPENING_010,
			OpDialog.U01_NIS_OPENING_020,
			OpDialog.U01_NIS_OPENING_030,
			OpDialog.U01_NIS_OPENING_035,
			OpDialog.U01_NIS_OPENING_040,
			OpDialog.U01_NIS_OP_SETUP_010,
			OpDialog.U01_NIS_OP_SETUP_END,
		}
	)

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('U01_NIS_OPENING_Start')

 	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance and the stat position
	NIS.StartNIS_Opening('NIS1_CAM_A_01', 0.0, 'NIS1_CAM_A_01', 75.0)

	NIS.EnableShadowDepthOverride(1000)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	ForkThread(
		function()
			WaitSeconds(2.0)
			func_OPENING_MoveCDR()
			WaitSeconds(2.0)
			WaitSeconds(10.0)
			func_OPENING_MoveTanks()
		end
	)

	ForkThread(
		function()
			--Establishing shot--
			NIS.ZoomTo(GetPos('NIS1_CAM_A_02'), GetOrient('NIS1_CAM_A_02'), 0.0, 8.0)

			WaitSeconds(2.5)
			func_OPENING_CreateAndMoveTransport()

			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 210.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -4.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= -0.50,						-- if specified, offset in the X direction
					nOffsetY			= 1.30,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)

			NIS.EnableShadowDepthOverride(20)

			WaitSeconds(6.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 120.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 2.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.30,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	WaitSeconds(9.0)
	NIS.Dialog(OpDialog.U01_NIS_OPENING_010)

	NIS.EnableShadowDepthOverride(1000)

	ForkThread(
		function()
			--start camera to reveal array
			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_3_01'), GetOrient('NIS_VIC_CAM_SHOT_3_01'), 150.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_3_02'), GetOrient('NIS_VIC_CAM_SHOT_3_02'), 170.0, 5.2)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_OPENING_020)

	WaitSeconds(2.0)

	ForkThread(
		function()
			-- Wide shot of base
			NIS.SetFOV(70.0)
			NIS.ZoomTo(GetPos('NIS_NukeCams_03'), GetOrient('NIS_NukeCams_03'), 20.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_NukeCams_03'), GetOrient('NIS_NukeCams_03'), 10.0, 2.5)
		end
	)
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U01_NIS_OPENING_NukeLaunch')
	NIS.Dialog(OpDialog.U01_NIS_OPENING_030)

	-- Needs to run concurrently
	ForkThread(
		function()
			func_OPENING_Nukes()
		end
	)

	-- Opening shot
	-- Final VO timing: 1.9 seconds
	ForkThread(
		function()
			-- Next shots showcase nukes
			WaitSeconds(2.0)
			NIS.SetFOV(45.0)
			NIS.ZoomTo(GetPos('NIS_NukeCams_02'), GetOrient('NIS_NukeCams_02'), 0.0, 0.0)
			NIS.AddFade(
				{
					nFadeIn 		= 1.0,			-- Number of seconds to fade in.
					nFadeOut	 	= 0.0,			-- Number of seconds to fade out.
					sColor			= 'ffffffff',	-- Hex color (as string) for fade color.
					nShotDurration 	= 2.5,			-- Length of the shot in seconds.
					fcnCamBehavior 	= NIS.ZoomTo,	-- The function that controls the camera behavior.
					tblParams 		= {				-- The table of the parameters need for the behavior function.
						GetPos('NIS_NukeCams_02'),
						GetOrient('NIS_NukeCams_02'),
						10.0,
						4.5
					}
				}
			)

			NIS.SetFOV(70.0)
			NIS.ZoomTo(GetPos('NIS_NukeCams_03'), GetOrient('NIS_NukeCams_03'), 10.0, 0.0)
			NIS.AddFade(
				{
					nFadeIn 		= 1.0,			-- Number of seconds to fade in.
					nFadeOut	 	= 0.0,			-- Number of seconds to fade out.
					sColor			= 'ffffffff',	-- Hex color (as string) for fade color.
					nShotDurration 	= 5.0,			-- Length of the shot in seconds.
					fcnCamBehavior 	= NIS.ZoomTo,	-- The function that controls the camera behavior.
					tblParams 		= {				-- The table of the parameters need for the behavior function.
						GetPos('NIS_NukeCams_03'),
						GetOrient('NIS_NukeCams_03'),
						20.0,
						5.0
					}
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_OPENING_035)
	WaitSeconds(9.0)

	-- Final VO timing: 2.8 seconds
	ForkThread(
		function()

			-- Fugly, but needs to run concurrently
			ForkThread(
				function()
					WaitSeconds(2.0)
					-- trigger music system for this transition point
					NIS.PlayMusicEventByHandle('U01_NIS_OPENING_Enemy_Transports')
					func_OPENING_CourtyardAssault()
					WaitSeconds(1.0)
				end
			)

			-- Crane into incoming transports
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_01'), GetOrient('NIS1_CAM_E_01'), 0.0, 0.0)
			WaitSeconds(1.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_02'), GetOrient('NIS1_CAM_E_02'), 0.0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_OPENING_040)
	WaitSeconds(2.2)

	-- Final VO timing: 2.9 seconds
	ForkThread(
		function()
			-- Track transports
			NIS.SetFOV(55.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_01'), GetOrient('NIS1_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_02'), GetOrient('NIS1_CAM_C_02'), 10.0, 7.0)
		end
	)
	WaitSeconds(4.0)
	NIS.Dialog(OpDialog.U01_NIS_OP_SETUP_010)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U01_NIS_OPENING_End')

	NIS.SetFOV(60.0)
	NIS.ZoomTo(GetPos('NIS_CAM_END'), GetOrient('NIS_CAM_END'), 10.0, 0.0)
	WaitSeconds(0.5)

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	-- Final VO timing: 1.5 seconds
	NIS.DialogNoWait(OpDialog.U01_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_REVEAL_ENEMY:
---------------------------------------------------------------------
function NIS_REVEAL_ENEMY()

	NIS.PreloadDialogData(
		{
			OpDialog.U01_NIS_REVEAL_ENEMY_010,
			OpDialog.U01_NIS_REVEAL_ENEMY_020,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U01_NIS_REVEAL_ENEMY_Start')

	NIS.StartNIS_MidOp()

	func_REVEAL_ENEMY_ExperimentalAssault()

	-- dialog as we zoom out
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS3_CAM_B_01'), GetOrient('NIS3_CAM_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS3_CAM_B_02'), GetOrient('NIS3_CAM_B_02'), 0.0, 4.5)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_REVEAL_ENEMY_010)

	--temp for UI
	WaitSeconds(2.0)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ENEM01_EXPERIMENTAL_01,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 4.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 15.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= -0.50,								-- if specified, offset in the X direction
					nOffsetY			= 1.60,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(3.0)
			NIS.SetZoom(100.0, 10.0)
		end
	)
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U01_NIS_REVEAL_ENEMY_Enemy_Attack')
	NIS.Dialog(OpDialog.U01_NIS_REVEAL_ENEMY_020)

	--temp for UI
	WaitSeconds(2.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS3_CAM_C_01'), GetOrient('NIS3_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS3_CAM_C_02'), GetOrient('NIS3_CAM_C_02'), 0.0, 6.5)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_REVEAL_ENEMY_OP_SETUP_010)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U01_NIS_REVEAL_ENEMY_End')

	-- use EndNIS_MidOp and restore to the player
	NIS.EndNIS_MidOp()
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.U01_NIS_VICTORY_010,
			OpDialog.U01_NIS_VICTORY_011,
			OpDialog.U01_NIS_VICTORY_020,
			OpDialog.U01_NIS_VICTORY_030,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U01_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueStop( {ScenarioInfo.PLAYER_CDR} )

	func_VICTORY_EnemyMovement()

	-- Wide shot of death
	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit				= deathUnit,			-- unit to be killed
			vizRadius			= 300,					-- optional distance for a visibility marker ring
			degreesHeading		= 200.0,				-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 35.0,					-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 40.0,					-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,					-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,					-- if specified, offset in the X direction
			nOffsetY			= 0.0,					-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,					-- if specified, offset in the Z direction
		}
	)

	ForkThread(
		function()
			WaitSeconds(3.0)

			func_VICTORY_Flee()

			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_7_01'), GetOrient('NIS_VIC_CAM_SHOT_7_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_7_02'), GetOrient('NIS_VIC_CAM_SHOT_7_02'), 0.0, 5.0)
		end
	)
	WaitSeconds(2.0)
	NIS.Dialog(OpDialog.U01_NIS_VICTORY_010) -- 5.7 secs

	ForkThread(
		function()
			-- Track Maddox
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -8.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.4,									-- if specified, offset in the X direction
					nOffsetY			= 2.1,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(0.1)
			NIS.SetZoom(8.0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_VICTORY_011) --5.5 secs

	-- Extremely wide shot of base
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_NukeCams_03'), GetOrient('NIS_NukeCams_03'), 10.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_NukeCams_03'), GetOrient('NIS_NukeCams_03'), 30.0, 12.0)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_VICTORY_020) --13.5

	ForkThread(
		function()
			-- Track Maddox
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -8.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.4,									-- if specified, offset in the X direction
					nOffsetY			= 2.1,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U01_NIS_VICTORY_030)

	NIS.EndNIS_Victory(nil, false)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_MoveCDR(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('NIS_DEST_CDR_01'))
		return
	end

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('NIS_DEST_CDR_00') )
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('NIS_DEST_CDR_01') )
end
function func_OPENING_MoveTanks(bSkip)
	if bSkip then
		local dest01 = GetPos('NIS_DEST_TANKS_01')
		local dest02 = GetPos('NIS_DEST_TANKS_02')
		dest01[3] = dest01[3] - 5.0
		dest02[3] = dest02[3] - 5.0

		NIS.WarpGroup(ScenarioInfo.PLAYER_TANKS_01, dest01)
		NIS.WarpGroup(ScenarioInfo.PLAYER_TANKS_02, dest02)
		WaitTicks(1)
	end

	IssueFormMove( ScenarioInfo.PLAYER_TANKS_01, GetPos('NIS_DEST_TANKS_01'), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.PLAYER_TANKS_02, GetPos('NIS_DEST_TANKS_02'), 'AttackFormation', 180 )
end

function func_OPENING_CreateAndMoveTransport(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	local transport = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'PLAYER_TRANS')

	-- issue a move to the destination chain
	for k,v in import('/lua/sim/ScenarioUtilities.lua').ChainToPositions('Player_Trans_Path') do
		IssueMove( {transport}, v )
	end
end

function func_OPENING_Nukes(bSkip)
	if bSkip then
		NIS.ForceUnitDeath(ScenarioInfo.ALLY01_COMM_ARRAY)
		NIS.ForceGroupDeath(ScenarioInfo.NIS_NUKED_UNITS_AREA_02)
		NIS.ForceGroupDeath(ScenarioInfo.NIS_NUKED_UNITS_AREA_01)
		return
	end

	WaitSeconds(1.8)

	NIS.NukePosition('NUKE_DESTINATION_01', 0)
	WaitSeconds(1.5)
	NIS.ForceUnitDeath(ScenarioInfo.ALLY01_COMM_ARRAY)
	WaitSeconds(3.3)

	NIS.NukePosition('NUKE_DESTINATION_05', 0)
	NIS.ForceGroupDeath(ScenarioInfo.NIS_NUKED_UNITS_AREA_02)
	WaitSeconds(0.4)

	NIS.NukePosition('NUKE_DESTINATION_06', 0)
	NIS.ForceGroupDeath(ScenarioInfo.NIS_NUKED_UNITS_AREA_01)
end

function func_OPENING_CourtyardAssault(bSkip)
	-- setup for the first courtyard attack
	OpScript.P1_CourtyardAssault(bSkip)
end

function func_REVEAL_ENEMY_ExperimentalAssault()
	IssueMove( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, GetPos( 'NIS_DEST_EXPERIMENTAL_01' ) )
	IssueMove( {ScenarioInfo.ENEM01_EXPERIMENTAL_02}, GetPos( 'NIS_DEST_EXPERIMENTAL_02' ) )
	IssuePatrol( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, GetPos( 'OUTSIDE_GATE_POS_1' ) )
	IssuePatrol( {ScenarioInfo.ENEM01_EXPERIMENTAL_01}, GetPos( 'OUTSIDE_GATE_POS_2' ) )

	IssueMove( ScenarioInfo.ENEM01_ESCORT, GetPos( 'NIS_DEST_EXPERIMENTAL_01' ) )
	IssuePatrol( ScenarioInfo.ENEM01_ESCORT, GetPos( 'OUTSIDE_GATE_POS_3' ) )

	IssueFormMove( ScenarioInfo.ENEM01_SECONDWAVE_01, GetPos( 'NIS_DEST_SECONDWAVE_01' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.ENEM01_SECONDWAVE_02, GetPos( 'NIS_DEST_SECONDWAVE_02' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.ENEM01_SECONDWAVE_03, GetPos( 'NIS_DEST_SECONDWAVE_03' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.ENEM01_SECONDWAVE_04, GetPos( 'NIS_DEST_SECONDWAVE_04' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.ENEM01_SECONDWAVE_05, GetPos( 'NIS_DEST_SECONDWAVE_05' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.ENEM01_SECONDWAVE_06, GetPos( 'NIS_DEST_SECONDWAVE_06' ), 'AttackFormation', 180 )
end

function func_VICTORY_EnemyMovement()
	if ScenarioInfo.ENEM01_REINFORCEMENTS then
		IssueClearCommands(ScenarioInfo.ENEM01_REINFORCEMENTS)
		IssueMove( ScenarioInfo.ENEM01_REINFORCEMENTS, GetPos( 'ENEM01_TRANSPORT_EXIT_ZONE' ) )
	end

	if ScenarioInfo.COURTYARD_ASSAULT_PLATOONS then
		for k, platoon in ScenarioInfo.COURTYARD_ASSAULT_PLATOONS do
			IssueClearCommands(platoon:GetPlatoonUnits())
			IssueMove( platoon:GetPlatoonUnits(), GetPos( 'ENEM01_TRANSPORT_EXIT_ZONE' ) )
		end
	end

	if ScenarioInfo.ENEM01_ESCORT then
		IssueClearCommands(ScenarioInfo.ENEM01_ESCORT)
		IssueMove( ScenarioInfo.ENEM01_ESCORT, GetPos( 'ENEM01_TRANSPORT_EXIT_ZONE' ) )
	end

	if ScenarioInfo.ENEM01_SECONDWAVE_01 then
		IssueClearCommands(ScenarioInfo.ENEM01_SECONDWAVE_01)
		IssueMove( ScenarioInfo.ENEM01_SECONDWAVE_01, GetPos( 'ENEM01_TRANSPORT_EXIT_ZONE' ) )
	end

	if ScenarioInfo.ENEM01_SECONDWAVE_02 then
		IssueClearCommands(ScenarioInfo.ENEM01_SECONDWAVE_02)
		IssueMove( ScenarioInfo.ENEM01_SECONDWAVE_02, GetPos( 'ENEM01_TRANSPORT_EXIT_ZONE' ) )
	end
end

function func_VICTORY_Flee()
	local fleeGroup = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_FLEE')
	IssueMove( fleeGroup, GetPos( 'NIS_VIC_FleeLocation' ) )
end