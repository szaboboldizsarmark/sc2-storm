---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_C05/SC2_CA_C05_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_C05/SC2_CA_C05_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_C05/SC2_CA_C05_script.lua')
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
				func_OPENING_HideUnits(true)
				func_OPENING_WarpPlayerUnits(true)
				func_OPENING_ShowEnemyCDR(true)
				func_OPENING_MoveEnemyCDR(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('C05_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.C05_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.C05_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PlayMovie('/movies/FMV_CYB_C05_REVEAL')

	NIS.PreloadDialogData(
		{
			OpDialog.C05_NIS_OPENING_010,
			OpDialog.C05_NIS_OPENING_020,
			OpDialog.C05_NIS_OPENING_030,
			OpDialog.C05_NIS_OPENING_040,
			OpDialog.C05_NIS_OP_SETUP_010,
			OpDialog.C05_NIS_OP_SETUP_END,
		}
	)

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	-- Hide opening units.
	func_OPENING_HideUnits()

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('C05_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS1_CAM_C_01', 0.0,'NIS1_CAM_C_01', 75.0)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	func_OPENING_WarpPlayerUnits()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_C_02'), GetOrient('NIS1_CAM_C_02'), 0.0, 8.0)

			NIS.ZoomTo(GetPos('NIS1_CAM_B_01'), GetOrient('NIS1_CAM_B_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_02'), GetOrient('NIS1_CAM_B_02'), 0.0, 7.7)
		end
	)
	WaitSeconds(2.0)
	NIS.Dialog(OpDialog.C05_NIS_OPENING_010) 	--Final VO: 15.7 seconds

	NIS.CreateVizMarker('INTRO_NIS_EnemyCDR_VisLoc_01', 80)
	func_OPENING_ShowEnemyCDR()

	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_03'), GetOrient('NIS1_CAM_B_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_04'), GetOrient('NIS1_CAM_B_04'), 0.0, 3.0)

			ForkThread(
				function()
					NIS.SetFOV(35.0, 0.7)
				end
			)
			NIS.SetZoom(-200.0, 0.8)
			func_OPENING_MoveEnemyCDR()
		end
	)
	NIS.Dialog(OpDialog.C05_NIS_OPENING_020)	--Final VO: 4.5 seconds

	--Final VO: 15 seconds
	ForkThread(
		function()
			WaitSeconds(3.0)
			--cam stuff
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_01'), GetOrient('NIS1_CAM_E_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_E_02'), GetOrient('NIS1_CAM_E_02'), 30.0, 8.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.ENEM01_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -2.5,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 8.5,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.10,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C05_NIS_OPENING_030)

	NIS.Dialog(OpDialog.C05_NIS_OPENING_040)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C05_NIS_OPENING_End')

	NIS.SetFOV(60.0)
	NIS.ZoomTo(GetPos('NIS1_CAM_D_02'), GetOrient('NIS1_CAM_D_02'), 0.0, 0.0)

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.C05_NIS_OP_SETUP_010)
	NIS.DialogNoWait(OpDialog.C05_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_DESTROYER:
---------------------------------------------------------------------
function NIS_DESTROYER_REVEAL()

	NIS.PreloadDialogData(
		{
			OpDialog.C05_NIS_DESTROYER_REVEAL_010,
			OpDialog.C05_NAVAL_WARNING_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C05_NIS_DESTROYER_REVEAL_Start')

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('NIS_DESTROYER_VisLoc_01', 50)

	NIS.StartNIS_MidOp()

	-- Get the destroyers moving
	func_DESTROYER_MoveUnits()

	--Final VO: 9.1 seconds
	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.P1_EnemDestroyer03,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 105.0,							-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 30.0,								-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 25.0,								-- how close to track relative to the unit
					nTrackToDuration	= 10.0,								-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,								-- if specified, offset in the X direction
					nOffsetY			= 5.0,								-- if specified, offset in the Y direction
					nOffsetZ			= 10.0,								-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C05_NIS_DESTROYER_REVEAL_010)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C05_NIS_DESTROYER_REVEAL_End')

	-- use EndNIS_MidOp and restore to the player
	NIS.EndNIS_MidOp()

	-- parting VO
	NIS.DialogNoWait(OpDialog.C05_NAVAL_WARNING_010)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.C05_ILL_DEATH_010,
			OpDialog.C05_NIS_VICTORY_010,
			OpDialog.C05_NIS_VICTORY_020,
			OpDialog.C05_NIS_VICTORY_030,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C05_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	local targetEnt = nil

	ForkThread(
		function()
			WaitSeconds(1.5)
			targetEnt = NIS.UnitDeathZoomTo(
				{
					unit				= deathUnit,	-- unit to be killed
					vizRadius			= 300,			-- optional distance for a visibility marker ring
					degreesHeading		= 120.0,		-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 35.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nZoomToDistance		= 400.0,		-- how close to zoom-in relative to the unit
					nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 1.4,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C05_ILL_DEATH_010) -- 2 seconds

	WaitSeconds(5.0)

	ForkThread(
		function()
			WaitSeconds(14.0)
			NIS.FadeOut(3.0)
		end
	)

	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 35.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.005,		-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 150.0,		-- how close to spin relative to the unit
					nSpinDuration		= 17.0,			-- how long to allow the spin to persist
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 10.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)

		end
	)
	NIS.Dialog(OpDialog.C05_NIS_VICTORY_010) --16.1 blah blah

	WaitSeconds(3.0)

	NIS.SetZoom(1000.0,0.0)

	-- Prepare final army
	func_VICTORY_Setup()

	NIS.Dialog(OpDialog.C05_NIS_VICTORY_020) -- 10 seconds

	NIS.FadeIn(3.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_EXIT_01'), GetOrient('NIS_EXIT_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_EXIT_02'), GetOrient('NIS_EXIT_02'), 0.0, 12.0)
		end
	)
	NIS.Dialog(OpDialog.C05_NIS_VICTORY_030) -- 10 seconds

	WaitSeconds(1.0)

	func_VICTORY_FinalTeleport()

	WaitSeconds(2.0)

	-- wrap up without optional continued gameplay
	NIS.EndNIS_Victory(nil, false)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_HideUnits(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	-- Prepare the enemy CDR for her reveal (if desired) by getting her hidden, and commandcleared.
	NIS.HideUnit(ScenarioInfo.PLAYER_CDR)
	NIS.HideUnit(ScenarioInfo.ENEM01_CDR)
	NIS.HideGroup(ScenarioInfo.P1_PlayerInitEng)
	NIS.HideGroup(ScenarioInfo.P1_PlayerInitLand)

	IssueClearCommands({ScenarioInfo.ENEM01_CDR})
end

function func_OPENING_WarpPlayerUnits(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('INTRO_NIS_CDR_Destination'))
		NIS.WarpGroup(ScenarioInfo.P1_PlayerInitEng, GetPos('INTRO_NIS_CDR_Destination'))
		NIS.WarpGroup(ScenarioInfo.P1_PlayerInitLand, GetPos('INTRO_NIS_CDR_Destination'))

		IssueFormMove( ScenarioInfo.P1_PlayerInitEng, GetPos('INTRO_NIS_Engineers_Destination'), 'AttackFormation', 180 )
		IssueFormMove( ScenarioInfo.P1_PlayerInitLand, GetPos('INTRO_NIS_Land_Destination'), 'AttackFormation', 180 )
		return
	end

	NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('ARMY_PLAYER'))
	NIS.ShowUnit(ScenarioInfo.PLAYER_CDR)
	CreateTeleportEffects( ScenarioInfo.PLAYER_CDR  )
	WaitSeconds(1.0)
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('INTRO_NIS_CDR_Destination'))

	ForkThread(
		function()
			WaitSeconds(8.0)
			NIS.WarpGroup(ScenarioInfo.P1_PlayerInitEng, GetPos('ARMY_PLAYER'))
			NIS.WarpGroup(ScenarioInfo.P1_PlayerInitLand, GetPos('ARMY_PLAYER'))

			for k, unit in ScenarioInfo.P1_PlayerInitEng do
				CreateTeleportEffects( unit )
			end

			for k, unit in ScenarioInfo.P1_PlayerInitLand do
				CreateTeleportEffects( unit )
			end

			WaitSeconds(0.2)
			NIS.ShowGroup(ScenarioInfo.P1_PlayerInitEng)
			NIS.ShowGroup(ScenarioInfo.P1_PlayerInitLand)
			NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_01_ring_emit.bp', GetPos('ARMY_PLAYER'))
			NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_02_glow_emit.bp', GetPos('ARMY_PLAYER'))
			WaitSeconds(0.4)
			IssueFormMove( ScenarioInfo.P1_PlayerInitEng, GetPos('INTRO_NIS_Engineers_Destination'), 'AttackFormation', 180 )
			IssueFormMove( ScenarioInfo.P1_PlayerInitLand, GetPos('INTRO_NIS_Land_Destination'), 'AttackFormation', 180 )
		end
	)
end

function func_OPENING_ShowEnemyCDR(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	-- Reveal the enemy commander. If needed, warp in etc effect would go here.
	NIS.ShowUnit(ScenarioInfo.ENEM01_CDR)
	CreateTeleportEffects( ScenarioInfo.ENEM01_CDR  )

	ForkThread(
		function()
			WaitSeconds(2.0)
			CreateTeleportEffects( ScenarioInfo.ENEM01_CDR  )
			NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_01_ring_emit.bp', GetPos(ScenarioInfo.ENEM01_CDR))
			NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_02_glow_emit.bp', GetPos(ScenarioInfo.ENEM01_CDR))
		end
	)
end

function func_OPENING_MoveEnemyCDR(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.ENEM01_CDR, GetPos('INTRO_NIS_EnemyCDR_Move_Point_01'))
		return
	end

	-- Move the enemy CDR out.
	IssueMove( {ScenarioInfo.ENEM01_CDR}, GetPos('INTRO_NIS_EnemyCDR_Move_Point_01'))
end

function func_DESTROYER_MoveUnits()
	LOG('----- NIS_DESTROYER: Moving units.')
	if ScenarioInfo.P1_EnemDestroyer01 and not ScenarioInfo.P1_EnemDestroyer01:IsDead() then
		IssueMove({ScenarioInfo.P1_EnemDestroyer01}, GetPos('P1_ENEM01_DestroyerAttack_Chain01_01') )
	end
	if ScenarioInfo.P1_EnemDestroyer02 and not ScenarioInfo.P1_EnemDestroyer02:IsDead() then
		IssueMove({ScenarioInfo.P1_EnemDestroyer02}, GetPos('P1_ENEM01_DestroyerAttack_Chain01_02_01') )
	end
	if ScenarioInfo.P1_EnemDestroyer03 and not ScenarioInfo.P1_EnemDestroyer03:IsDead() then
		IssueMove({ScenarioInfo.P1_EnemDestroyer03}, GetPos('P1_ENEM01_DestroyerAttack_Chain01_03_01') )
	end
end

function func_VICTORY_Setup()
	IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
	IssueStop ( {ScenarioInfo.PLAYER_CDR} )

	Warp(ScenarioInfo.PLAYER_CDR, GetPos('INTRO_NIS_EnemyCDR_Move_Point_01'))
	ScenarioInfo.NIS_EXIT = NIS.CreateNISOnlyGroup('ARMY_PLAYER','NIS_EXIT')
	IssueFormMove (ScenarioInfo.NIS_EXIT, GetPos('INTRO_NIS_EnemyCDR_VisLoc_01'), 'AttackFormation', 0 )

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueMove ({ScenarioInfo.PLAYER_CDR}, GetPos('INTRO_NIS_EnemyCDR_VisLoc_01'))

	-- Destroy base leftovers
	---NOTE: we exclude several unit types so the player doesn't get objective completion - bfricks 1/5/10
	local unitList = ArmyBrains[ScenarioInfo.ARMY_ENEM01]:GetListOfUnits(categories.ALLUNITS - categories.scb9001 - categories.ucs0901, false)
	NIS.ForceGroupDeath(unitList)
end

function func_VICTORY_FinalTeleport()
	NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_01_ring_emit.bp', GetPos(ScenarioInfo.PLAYER_CDR))
	NIS.CreateNISOnlyFX('/effects/emitters/ambient/terrain/teleport/ambient_t_t_02_glow_emit.bp', GetPos(ScenarioInfo.PLAYER_CDR))
	CreateTeleportEffects( ScenarioInfo.PLAYER_CDR  )
	NIS.HideUnit(ScenarioInfo.PLAYER_CDR)

	for k, unit in ScenarioInfo.NIS_EXIT do
		CreateTeleportEffects( unit )
		NIS.HideUnit( unit )
	end
end