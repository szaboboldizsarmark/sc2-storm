---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_C03/SC2_CA_C03_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_C03/SC2_CA_C03_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_C03/SC2_CA_C03_script.lua')
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
	local nOverrideZoom	= 160.0

	if ScenarioInfo.Options.NoNIS then
		-- skip away
		SkipOpeningNIS(
			function()
				func_OPENING_HideUnits(true)
				func_OPENING_WarpAndMoveUnits(true)
				func_OPENING_StartBattle(true)
				func_OPENING_FinalWarp(true)

				WaitSeconds(3.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('C03_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.C03_NIS_OPENING_010)
				NIS.DialogNoWait(OpDialog.C03_NIS_OPENING_020)
				NIS.DialogNoWait(OpDialog.C03_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.C03_NIS_OPENING_010,
			OpDialog.C03_NIS_OPENING_020,
			OpDialog.C03_NIS_OP_SETUP_END,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('C03_NIS_OPENING_Start')

	func_OPENING_HideUnits()

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS1_CAM_A_05', 0.0,'NIS1_CAM_A_05', 75.0)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	ForkThread(func_OPENING_WarpAndMoveUnits)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_A_04'), GetOrient('NIS1_CAM_A_04'), 0.0, 10.0)
		end
	)
	WaitSeconds(4.0)
	NIS.Dialog(OpDialog.C03_NIS_OPENING_010) --Final VO: 3.5 seconds

	ForkThread(func_OPENING_StartBattle)

	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('NIS1_CAM_B_03'), 50.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_04'), GetOrient('NIS1_CAM_B_04'), 50.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.C03_NIS_OPENING_020) --Final VO: 11.2 seconds

	func_OPENING_FinalWarp()

	WaitSeconds(2.0)

	NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 100.0, 0.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C03_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.C03_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_REVEAL_ENEMY:
---------------------------------------------------------------------
function NIS_REVEAL_ENEMY()
	NIS.CreateVizMarker('P2_Intro_NIS_VisLoc01', 1000.0)

	NIS.PreloadDialogData(
		{
			OpDialog.C03_NIS_REVEAL_ENEMY_010,
			OpDialog.C03_NIS_REVEAL_ENEMY_OP_SETUP_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C03_NIS_REVEAL_ENEMY_Start')

	-- use StartNIS_MidOp to expand the playable area and allow a smooth camera reveal
	NIS.StartNIS_MidOp('AREA_2')

	ForkThread(
		function()
		NIS.ZoomTo(GetPos('NIS_MIDOP1_SHOT_1_03'), GetOrient('NIS_MIDOP1_SHOT_1_03'), 0.0, 0.0)
		NIS.ZoomTo(GetPos('NIS_MIDOP1_SHOT_1_04'), GetOrient('NIS_MIDOP1_SHOT_1_04'), 0.0, 16.0)
		end
	)
	NIS.Dialog(OpDialog.C03_NIS_REVEAL_ENEMY_010) 	--Final VO: 11.5 seconds

	NIS.Dialog(OpDialog.C03_NIS_REVEAL_ENEMY_OP_SETUP_010) --Final VO: 6.3 seconds

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C03_NIS_REVEAL_ENEMY_End')

	-- use EndNIS_MidOp and restore to the player
	---NOTE: intentionally flush the intel - bfricks 10/31/09
	NIS.EndNIS_MidOp(true)

end

---------------------------------------------------------------------
-- NIS_DINO:
---------------------------------------------------------------------
function NIS_DINO(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.C03_NIS_DINO_010,
			OpDialog.C03_NIS_DINO_020,
			OpDialog.C03_NIS_DINO_OP_SETUP_010,
			OpDialog.C03_NIS_DINO_OP_SETUP_020,
			OpDialog.C03_NIS_DINO_OP_SETUP_030,
			OpDialog.C03_NIS_DINO_OP_SETUP_040,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('P2_DINO_RevealNIS_Marker', 50)

	-- setup the DINO and factory before we continue
	func_DINO_Setup()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C03_NIS_DINO_Start')

	NIS.StartNIS_MidOp()

	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit				= deathUnit,			-- unit to be killed
			vizRadius			= 300,					-- optional distance for a visibility marker ring
			degreesHeading		= 180.0,				-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 60.0,					-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 225.0,				-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,					-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,					-- if specified, offset in the X direction
			nOffsetY			= 1.0,					-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,					-- if specified, offset in the Z direction
		}
	)
	NIS.Dialog(OpDialog.C03_NIS_DINO_010) 	--Final VO: 10.1 seconds

	WaitSeconds(3.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_F_01'), GetOrient('NIS1_CAM_F_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_F_02'), GetOrient('NIS1_CAM_F_02'), 0.0, 12.0)

			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 15.0,							-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 20.0,							-- how close to track relative to the unit
					nTrackToDuration	= 7.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= -2.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)

		end
	)
	NIS.Dialog(OpDialog.C03_NIS_DINO_020) 	--Final VO: 15.0 seconds

	func_DINO_RaisePlatform()

	WaitSeconds(3.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C03_NIS_DINO_Reveal')

	func_DINO_ReleaseDINO()

	ForkThread(
		function()
			WaitSeconds(3.0)

			func_DINO_Move01()

			WaitSeconds(1.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.P2_ALIEN01_Dinosaur,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 35.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 50.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,									-- if specified, offset in the X direction
					nOffsetY			= 2.0,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
			WaitSeconds(4.0)

			func_DINO_KillStuff01()
		end
	)
	NIS.Dialog(OpDialog.C03_NIS_DINO_OP_SETUP_010)--8.3 "Creature is loose'

	func_DINO_Move02()

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.P2_ALIEN01_Dinosaur,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 0.0,									-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 55.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 40.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 0.0,									-- if specified, offset in the X direction
					nOffsetY			= 1.0,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C03_NIS_DINO_OP_SETUP_020)--5.3 "Destroyed a building"

	func_DINO_KillStuff02()

	LOG('----------------------------------------SOUND: Play Roar')
	CreateSimSyncSound( Sound {Bank = 'SC2', Cue = 'Experimentals/CYBRAN/UCX0111_zilla/snd_UCX0111_zilla_NIS_Scream' } )

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('FIRE_SHOT'), GetOrient('FIRE_SHOT'), 0.0, 0.0)
			WaitSeconds(2.5)
			NIS.FadeOutWhite(0.5)
		end
	)
	WaitSeconds(2.0)
	NIS.Dialog(OpDialog.C03_NIS_DINO_OP_SETUP_030)--5.1 "Breathes fire"

	func_DINO_Cleanup()

	WaitSeconds(1.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C03_NIS_DINO_End')

	-- use EndNIS_MidOp and restore to the player
	NIS.EndNIS_MidOp()

	NIS.FadeInWhite(0.0)

	NIS.DialogNoWait(OpDialog.C03_NIS_DINO_OP_SETUP_040)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.C03_NIS_VICTORY_010,
			OpDialog.C03_NIS_VICTORY_020,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C03_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit				= deathUnit,	-- unit to be killed
			vizRadius			= 300,			-- optional distance for a visibility marker ring
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 15.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 150.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 1.4,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)
	NIS.SetZoom (50.0,0.8)
	WaitSeconds(5.0)

	NIS.Dialog(OpDialog.C03_NIS_VICTORY_010)

	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 35.0,			-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 80.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.005,		-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 50.0,			-- how close to spin relative to the unit
					nSpinDuration		= 20.0,			-- how long to allow the spin to persist
					nOffsetX			= 0.0,			-- if specified, offset in the X direction
					nOffsetY			= 0.0,			-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.C03_NIS_VICTORY_020)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_HideUnits(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.HideUnit( ScenarioInfo.PLAYER_CDR )
	NIS.HideGroup( ScenarioInfo.PLAYER_StartingLand )
	NIS.HideGroup( ScenarioInfo.PLAYER_StartingGunship )
	NIS.HideGroup( ScenarioInfo.PLAYER_StartingBomber )
	NIS.HideGroup( ScenarioInfo.PLAYER_StartingTransport )
	NIS.HideGroup( ScenarioInfo.PLAYER_ENGINEERS )
end

function func_OPENING_WarpAndMoveUnits(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.WarpUnit( ScenarioInfo.PLAYER_CDR, GetPos('WARP_IN_02'))
	NIS.ShowUnit(ScenarioInfo.PLAYER_CDR)
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos( 'INTRONIS_Marker_CDRDest' ) )

	ForkThread(
		function()
			-- send the engineers
			NIS.WarpGroup(ScenarioInfo.PLAYER_ENGINEERS, GetPos('WARP_IN_01'))
			WaitTicks(3)
			NIS.ShowGroup(ScenarioInfo.PLAYER_ENGINEERS)
			IssueFormMove( ScenarioInfo.PLAYER_ENGINEERS, GetPos( 'INTRONIS_Marker_EngDest' ), 'AttackFormation', 120 )
			WaitTicks(3)

			-- send the other land units
			NIS.WarpGroup(ScenarioInfo.PLAYER_StartingLand, GetPos('WARP_IN_01'))
			WaitTicks(3)
			NIS.ShowGroup(ScenarioInfo.PLAYER_StartingLand)
			IssueFormMove( ScenarioInfo.PLAYER_StartingLand, GetPos( 'INTRONIS_Marker_LandDest' ), 'AttackFormation', 180 )
			WaitTicks(3)

			-- send the transports
			NIS.WarpGroup(ScenarioInfo.PLAYER_StartingTransport, GetPos('WARP_IN_01'))
			WaitTicks(3)
			NIS.ShowGroup(ScenarioInfo.PLAYER_StartingTransport)
			IssueFormMove( ScenarioInfo.PLAYER_StartingTransport, GetPos( 'INTRONIS_Markers_TransportDest' ), 'AttackFormation', 180 )
			WaitTicks(3)

			-- send the gunships
			NIS.WarpGroup(ScenarioInfo.PLAYER_StartingGunship, GetPos('WARP_IN_01'))
			WaitTicks(3)
			NIS.ShowGroup(ScenarioInfo.PLAYER_StartingGunship)
			IssueFormMove( ScenarioInfo.PLAYER_StartingGunship, GetPos( 'INTRONIS_Marker_GunshipDest' ), 'AttackFormation', 180 )
			WaitTicks(3)

			-- send the bombers
			NIS.WarpGroup(ScenarioInfo.PLAYER_StartingBomber, GetPos('WARP_IN_01'))
			WaitTicks(3)
			NIS.ShowGroup(ScenarioInfo.PLAYER_StartingBomber)
			IssueFormMove( ScenarioInfo.PLAYER_StartingBomber, GetPos( 'INTRONIS_Marker_BomberDest' ), 'AttackFormation', 180 )
		end
	)
end

function func_OPENING_StartBattle(bSkip)
	IssueAttack(ScenarioInfo.NIS_ATTACKERS, ScenarioInfo.ALLY01_Station)

	---NOTE: everything after this point can be skipped - bfricks 12/5/09
	if bSkip then return end

	ScenarioInfo.ZOE_STRUCTURES			= NIS.CreateNISOnlyGroup('ARMY_ALLY01', 'ZOE_STRUCTURES')
	ScenarioInfo.ZOE_UNITS_01			= NIS.CreateNISOnlyGroup('ARMY_ALLY01', 'ZOE_UNITS_01')
	ScenarioInfo.ZOE_UNITS_02			= NIS.CreateNISOnlyGroup('ARMY_ALLY01', 'ZOE_UNITS_02')
	ScenarioInfo.NIS_ONLY_ATTACKERS_01	= NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_ONLY_ATTACKERS_01')
	ScenarioInfo.NIS_ONLY_ATTACKERS_02	= NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_ONLY_ATTACKERS_02')

	IssueFormMove(ScenarioInfo.ZOE_UNITS_01, GetPos('NIS_BATTLES_02'), 'AttackFormation', 120 )
	IssueFormMove(ScenarioInfo.ZOE_UNITS_01, GetPos('NIS_BATTLES_08'), 'AttackFormation', 120 )
	IssueFormMove(ScenarioInfo.ZOE_UNITS_02, GetPos('NIS_BATTLES_05'), 'AttackFormation', 120 )
	IssueFormMove(ScenarioInfo.ZOE_UNITS_02, GetPos('NIS_BATTLES_06'), 'AttackFormation', 120 )

	IssueFormMove(ScenarioInfo.NIS_ONLY_ATTACKERS_01, GetPos('NIS_BATTLES_02'), 'AttackFormation', 120 )
	IssueFormMove(ScenarioInfo.NIS_ONLY_ATTACKERS_01, GetPos('NIS_BATTLES_08'), 'AttackFormation', 120 )
	IssueFormMove(ScenarioInfo.NIS_ONLY_ATTACKERS_02, GetPos('NIS_BATTLES_05'), 'AttackFormation', 120 )
	IssueFormMove(ScenarioInfo.NIS_ONLY_ATTACKERS_02, GetPos('NIS_BATTLES_06'), 'AttackFormation', 120 )

	-- begin random deaths
	WaitSeconds(4.0)

	local RandomInt	= import('/lua/system/utilities.lua').GetRandomInt

	--Allow all of the enemy AA and PDs to die
	NIS.AllowGroupDeath(ScenarioInfo.ZOE_STRUCTURES)
	NIS.AllowGroupDeath(ScenarioInfo.ZOE_UNITS_01)
	NIS.AllowGroupDeath(ScenarioInfo.ZOE_UNITS_02)
	NIS.AllowGroupDeath(ScenarioInfo.NIS_ONLY_ATTACKERS_01)
	NIS.AllowGroupDeath(ScenarioInfo.NIS_ONLY_ATTACKERS_02)

	for k, unit in ScenarioInfo.ZOE_STRUCTURES do
		if unit and not unit:IsDead() then
			local hp = RandomInt(0, 100)
			unit:SetMaxHealth(hp)
			unit:AdjustHealth(unit, hp)
		end
	end

	for k, unit in ScenarioInfo.ZOE_UNITS_01 do
		if unit and not unit:IsDead() then
			local hp = RandomInt(0, 100)
			unit:SetMaxHealth(hp)
			unit:AdjustHealth(unit, hp)
		end
	end

	for k, unit in ScenarioInfo.ZOE_UNITS_02 do
		if unit and not unit:IsDead() then
			local hp = RandomInt(0, 100)
			unit:SetMaxHealth(hp)
			unit:AdjustHealth(unit, hp)
		end
	end

	for k, unit in ScenarioInfo.NIS_ONLY_ATTACKERS_01 do
		if unit and not unit:IsDead() then
			local hp = RandomInt(0, 100)
			unit:SetMaxHealth(hp)
			unit:AdjustHealth(unit, hp)
		end
	end

	for k, unit in ScenarioInfo.NIS_ONLY_ATTACKERS_02 do
		if unit and not unit:IsDead() then
			local hp = RandomInt(0, 100)
			unit:SetMaxHealth(hp)
			unit:AdjustHealth(unit, hp)
		end
	end
end

function func_OPENING_FinalWarp(bSkip)
	---NOTE: bSkip is not needed - this function is non-latent - bfricks 12/5/09

	NIS.WarpUnit( ScenarioInfo.PLAYER_CDR, GetPos('INTRONIS_Marker_CDRDest'))
	NIS.WarpGroup( ScenarioInfo.PLAYER_StartingLand, GetPos('INTRONIS_Marker_LandDest'))
	NIS.WarpGroup( ScenarioInfo.PLAYER_StartingTransport, GetPos('INTRONIS_Markers_TransportDest'))
	NIS.WarpGroup( ScenarioInfo.PLAYER_ENGINEERS, GetPos('INTRONIS_Marker_EngDest'))

	---NOTE: man this doesn't seem right - but it works - so for now leaving it, otherwise the units don't seem to make it
	---			to their dest positions - bfricks 12/6/09
	NIS.WarpGroup( ScenarioInfo.PLAYER_StartingGunship, GetPos('INTRONIS_Marker_CDRDest'))
	NIS.WarpGroup( ScenarioInfo.PLAYER_StartingBomber, GetPos('INTRONIS_Marker_CDRDest'))

	IssueFormMove( ScenarioInfo.PLAYER_StartingGunship, GetPos( 'INTRONIS_Marker_GunshipDest' ), 'AttackFormation', 180 )
	IssueFormMove( ScenarioInfo.PLAYER_StartingBomber, GetPos( 'INTRONIS_Marker_BomberDest' ), 'AttackFormation', 180 )
end

function func_DINO_Setup()
	NIS.HideUnit(ScenarioInfo.P2_ALIEN01_Dinosaur)
	ScenarioInfo.P2_GANTRY_DinoFactory:FakeBuildStart(ScenarioInfo.P2_ALIEN01_Dinosaur)
	WaitSeconds(1.0)
end

function func_DINO_RaisePlatform()
	NIS.ShowUnit(ScenarioInfo.P2_ALIEN01_Dinosaur)
	ScenarioInfo.P2_GANTRY_DinoFactory:RaisePlatform(ScenarioInfo.P2_ALIEN01_Dinosaur)
end

function func_DINO_ReleaseDINO()
	ScenarioInfo.P2_GANTRY_DinoFactory:FakeBuildComplete(ScenarioInfo.P2_ALIEN01_Dinosaur)
end

function func_DINO_Move01()
	IssueMove( {ScenarioInfo.P2_ALIEN01_Dinosaur}, GetPos('NIS_DINO_PATH_01') )
end

function func_DINO_KillStuff01()
	NIS.ForceUnitDeath(ScenarioInfo.DINO_BLOWS_UP_01)
	NIS.ForceUnitDeath(ScenarioInfo.DINO_BLOWS_UP_02)
end

function func_DINO_Move02()
	IssueClearCommands( {ScenarioInfo.P2_ALIEN01_Dinosaur} )
	IssueMove( {ScenarioInfo.P2_ALIEN01_Dinosaur}, GetPos('NIS_DINO_PATH_02') )
end

function func_DINO_KillStuff02()
	ScenarioInfo.DINO_FIRE_TARGET = NIS.CreateNISOnlyUnit('ARMY_ALLY01', 'DINO_FIRE_TARGET')
	IssueClearCommands( {ScenarioInfo.P2_ALIEN01_Dinosaur} )
	IssueAttack( {ScenarioInfo.P2_ALIEN01_Dinosaur}, ScenarioInfo.DINO_FIRE_TARGET )
end

function func_DINO_Cleanup()
	NIS.HideUnit(ScenarioInfo.DINO_FIRE_TARGET)
	NIS.ForceUnitDeath(ScenarioInfo.DINO_BLOWS_UP_03)
	IssueClearCommands( {ScenarioInfo.P2_ALIEN01_Dinosaur} )
end