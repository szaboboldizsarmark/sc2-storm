---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_U05/SC2_CA_U05_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_U05/SC2_CA_U05_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_U05/SC2_CA_U05_script.lua')
local NIS				= import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua')
local GetPos			= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetPos
local GetOrient			= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetOrient
local SkipOpeningNIS	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').SkipOpeningNIS
local SkipMidOpNIS		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').SkipMidOpNIS

-- Table for nukes, for ENEMY_REVEAL nis.
local NukeHandles = {}

---------------------------------------------------------------------
-- NIS_OPENING:
---------------------------------------------------------------------
function NIS_OPENING()
	-- set ending camera zoom
	local nOverrideZoom	= 120.0

	if ScenarioInfo.Options.NoNIS then
		-- skip away
		SkipOpeningNIS(
			function()
				func_OPENING_CreateStartingMobiles(true)
				func_OPENING_Transports(true)
				func_OPENING_EnemyTransportSequence(true)
				func_OPENING_EnemyArrival(true)
				func_OPENING_MoveCDR(true)
				func_OPENING_EnemyLandAttacks(true)
				func_OPENING_PlayerLandAttacks(true)
				func_OPENING_DestroyNISUnits(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('U05_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.U05_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.U05_NIS_OP_SETUP_011)
				NIS.DialogNoWait(OpDialog.U05_NIS_OP_SETUP_015)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.U05_NIS_OPENING_010,
			OpDialog.U05_NIS_OPENING_015,
			OpDialog.U05_NIS_OPENING_020,
			OpDialog.U05_NIS_OPENING_030,
			OpDialog.U05_NIS_OPENING_035,
			OpDialog.U05_NIS_OPENING_040,
			OpDialog.U05_NIS_OP_SETUP_010,
			OpDialog.U05_NIS_OP_SETUP_011,
			OpDialog.U05_NIS_OP_SETUP_015,
		}
	)

	NIS.CreateVizMarker('PLAYER_Radar_Marker', 300.0)
	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('U05_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS_CAM_OPENING_01', 0.0, 'NIS_CAM_OPENING_01', 75.0)

	NIS.EnableShadowDepthOverride(1000)

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	-- Create the starting units of player and enemy to be used (and cleaned up in) the nis
	---NOTE: I am moving this call to inside the NIS, NIS only units need to be created during an NIS for them to be properly managed - bfricks 11/29/09
	func_OPENING_CreateStartingMobiles()

	ForkThread(
		function()
			-- Establishing shot of city
			NIS.ZoomTo(GetPos('NIS_CAM_OPENING_02'), GetOrient('NIS_CAM_OPENING_02'), 0.0, 10.0)
		end
	)
	WaitSeconds(3.0) -- Pad for camera work and transports

	func_OPENING_Transports()

	WaitSeconds(3.0)

	NIS.Dialog(OpDialog.U05_NIS_OPENING_010)

	NIS.FadeOut(1.5)
	WaitSeconds(2.0) -- Pad for camera work

	NIS.SetFOV(70.0)
	ForkThread(
		function()
			-- Pan from transports to reveal of base
			NIS.FadeIn(1.5)
			NIS.ZoomTo(GetPos('NIS1_CAM_A_03'), GetOrient('NIS1_CAM_A_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_A_04'), GetOrient('NIS1_CAM_A_04'), 0.0, 8.0)
		end
	)
	WaitSeconds(3.0)
	NIS.Dialog(OpDialog.U05_NIS_OPENING_015) --4.6 transports

	NIS.FadeOut(1.5)
	WaitSeconds(3.0)

	NIS.SetFOV(40.0)

	NIS.Dialog(OpDialog.U05_NIS_OPENING_020) -- 1.9 The UEF forces have arrived

	func_OPENING_EnemyTransportSequence()

	func_OPENING_EnemyArrival()

	WaitSeconds(2.0)

	NIS.ZoomTo(GetPos(ScenarioInfo.NIS_TRANSPORT_01), GetOrient('NIS_ARMY_ARRIVAL_01'), 30.0, 0.0)

	NIS.FadeIn(1.5)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_TRANSPORT_07'), GetOrient('NIS_ARMY_ARRIVAL_02'), 30.0, 8.0)
		end
	)
	NIS.Dialog(OpDialog.U05_NIS_OPENING_030) -- 7.7 seconds (chatting with Lynch)

	func_OPENING_MoveCDR()

	NIS.EntityTrackRelative(
		{
			ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 190.0,						-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 10.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nTrackDistance		= 25.0,							-- how close to track relative to the unit
			nTrackToDuration	= 10.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
			nOffsetX			= -3.0,							-- if specified, offset in the X direction
			nOffsetY			= 1.0,							-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
		}
	)
	NIS.Dialog(OpDialog.U05_NIS_OPENING_035) -- 3.2 seconds (maddox line)

	NIS.Dialog(OpDialog.U05_NIS_OPENING_040) -- 4.7 rodgers response

	func_OPENING_EnemyLandAttacks()		-- enemy units advance to attack.
	func_OPENING_PlayerLandAttacks()	-- player units advance to attack.

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U05_NIS_OPENING_EnemyAttacks')

	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_ARMY_ARRIVAL_09'), GetOrient('NIS_ARMY_ARRIVAL_09'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_ARMY_ARRIVAL_10'), GetOrient('NIS_ARMY_ARRIVAL_10'), -40.0, 11.0)
		end
	)
	NIS.Dialog(OpDialog.U05_NIS_OP_SETUP_010) -- 1.5 secs

	ForkThread(
		function()
			WaitSeconds(3.0)
			func_OPENING_DestroyNISUnits()
			WaitSeconds(4.0)
			NIS.ForceUnitDeath(ScenarioInfo.NIS_FATBOY)
		end
	)
	NIS.Dialog(OpDialog.U05_NIS_OP_SETUP_011) -- 6.3 secs

	WaitSeconds(2.0)

	NIS.ZoomTo(GetPos('NIS_ARMY_ARRIVAL_06'), GetOrient('NIS_ARMY_ARRIVAL_06'), 100.0, 0.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U05_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	---NOTE: this is a rare case where we do not want to flush the intel - thuse the setting of 'false' - bfricks 11/2/09
	NIS.EndNIS_Opening(nOverrideZoom, false)

	NIS.DialogNoWait(OpDialog.U05_NIS_OP_SETUP_015)
end

---------------------------------------------------------------------
-- NIS_REVEAL_ENEMY:
---------------------------------------------------------------------
function NIS_REVEAL_ENEMY()

	NIS.PreloadDialogData(
		{
			OpDialog.U05_NIS_REVEAL_ENEMY_010,
			OpDialog.U05_NIS_REVEAL_ENEMY_020,
			OpDialog.U05_NIS_REVEAL_ENEMY_030,
			OpDialog.U05_NIS_REVEAL_ENEMY_035,
			OpDialog.U05_NIS_REVEAL_ENEMY_040,
			OpDialog.U05_NIS_REVEAL_ENEMY_050,
			OpDialog.U05_NIS_REVEAL_ENEMY_OP_SETUP_010,
			OpDialog.U05_NIS_REVEAL_ENEMY_OP_SETUP_020,
		}
	)

	-- enable temp visible areas around the destination(s) of the NIS
	NIS.CreateVizMarker('P2_Intro_NIS_VisLoc01', 170)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U05_NIS_REVEAL_ENEMY_Start')

	-- use StartNIS_MidOp to expand the playable area and allow a smooth camera reveal
	NIS.StartNIS_MidOp('AREA_2')

	-- Stop the enemy CDR from wandering all over
	---NOTE: even this can be problematic - but for now I'm comfortable with leaving this AS IS - bfricks 11/29/09
	IssueClearCommands( {ScenarioInfo.EnemyCommander} )

	ForkThread(
		function()
			-- CU Maddox
			NIS.SetFOV(80.0)
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 175.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= -1.0,							-- if specified, offset in the X direction
					nOffsetY			= 2.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U05_NIS_REVEAL_ENEMY_010) 	-- Final VO: 3.5 seconds
	WaitSeconds(0.30)

	ForkThread(
		function()
 			-- CU Lynch
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.EnemyCommander,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 45.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 50.0,							-- how close to track relative to the unit
					nTrackToDuration	= 0.0,							-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
			NIS.SetZoom(60.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.U05_NIS_REVEAL_ENEMY_020) 	-- Final VO: 1.1 seconds

	WaitSeconds(0.60)

	LOG('REVEAL: Duck sound during nuke')
	CreateSimSyncSound( Sound{ Bank = 'SC2', Cue = 'NIS/snd_Ducking_U05_nuke' } )

	func_REVEAL_ENEMY_LaunchWestNuke()

	ForkThread(
		function()
			--After this shot, we'd want to delete them in mid-air and use the explosion function to simulate their landing
			--This could also track the nuke before we jump to block 030, which is them hitting; may take too long, though

			-- Track launched ICBM to sky
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_6_01'), GetOrient('NIS_MIDOP_CAM_SHOT_6_01'), 0.0, 0.0)
			WaitSeconds(2.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_6_02'), GetOrient('NIS_MIDOP_CAM_SHOT_6_02'), 0.0, 2.0)
			NIS.FadeOutWhite(1.0)
		end
	)
	NIS.Dialog(OpDialog.U05_NIS_REVEAL_ENEMY_030)

	WaitSeconds(1.0)

	NIS.Dialog(OpDialog.U05_NIS_REVEAL_ENEMY_035)

	NIS.DisableEaseInOut()

	NIS.FadeInWhite(1.5)

	ForkThread(
		function()
			-- Track ICBM to city
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_7_01'), GetOrient('NIS_MIDOP_CAM_SHOT_7_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_7_02'), GetOrient('NIS_MIDOP_CAM_SHOT_7_02'), 0.0, 1.5)

			func_REVEAL_ENEMY_DeleteNukes()
			func_REVEAL_ENEMY_CreateExplosion()

			-- Low angle, wide shot of city with explosion
			NIS.FadeOutWhite(0.0)
			NIS.FadeInWhite(1.5)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_8_01'), GetOrient('NIS_MIDOP_CAM_SHOT_8_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_8_02'), GetOrient('NIS_MIDOP_CAM_SHOT_8_02'), 0.0, 11.0)
		end
	)
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U05_NIS_REVEAL_ENEMY_NukeLaunch')

	-- Wait for explosions to finish
	WaitSeconds(7.0)

	NIS.Dialog(OpDialog.U05_NIS_REVEAL_ENEMY_040)

	WaitSeconds(4.0)

	NIS.Dialog(OpDialog.U05_NIS_REVEAL_ENEMY_050)

	-- Final VO: 5.6 seconds
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			-- Reveal objective to destroy ICBM launchers
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_10_01'), GetOrient('NIS_MIDOP_CAM_SHOT_10_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_10_02'), GetOrient('NIS_MIDOP_CAM_SHOT_10_02'), 0.0, 1.5)
			WaitSeconds(2.0)
			NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_10_03'), GetOrient('NIS_MIDOP_CAM_SHOT_10_03'), 0.0, 1.5)
		end
	)
	NIS.Dialog(OpDialog.U05_NIS_REVEAL_ENEMY_OP_SETUP_010) -- 5.6 seconds

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U05_NIS_REVEAL_ENEMY_End')

	-- use EndNIS_MidOp and restore to the player
	---NOTE: intentionally do not flush the intel it is handled differently for this operation - and inside the main script - bfricks 11/14/09
	NIS.EndNIS_MidOp()

	NIS.DialogNoWait(OpDialog.U05_NIS_REVEAL_ENEMY_OP_SETUP_020)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.U05_ENEMY_CDR_DESTROYED_010,
			OpDialog.U05_NIS_VICTORY_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U05_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	-- track if this unit is the enemy CDR - who gets custom handling
	local isCDR = false
	if deathUnit == ScenarioInfo.EnemyCommander then
		isCDR = true
	end

	local deathUnitPos = GetPos(deathUnit)
	NIS.ForceUnitDeath(deathUnit)

	ForkThread(
		function()
			NIS.ZoomTo(deathUnitPos, GetOrient('NIS_VIC_CAM_SHOT_2_01'), 250.0, 0.0)
			NIS.Spin(0.001, 10.0)
		end
	)
	-- if the CDR was just killed - play some custom VO for the scenario
	if isCDR then
		NIS.Dialog(OpDialog.U05_ENEMY_CDR_DESTROYED_010)
		--Added drama for ending if it's the ACU
		WaitSeconds(5.0)
	end

	WaitSeconds(5.0)

	func_VICTORY_MoveCDR()

	WaitSeconds(0.5)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 0.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 20.0,						-- how close to track relative to the unit
					nTrackToDuration	= 0.0,						-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.0,						-- if specified, offset in the X direction
					nOffsetY			= 3.0,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,						-- if specified, offset in the Z direction
				}
			)
			NIS.ZoomTo(GetPos('NIS_VIC_CAM_SHOT_3_02'), GetOrient('NIS_VIC_CAM_SHOT_3_02'), 0.0, 10.0)

		end
	)
	NIS.Dialog(OpDialog.U05_NIS_VICTORY_010) --8.4

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_CreateStartingMobiles(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	-- Starting units of player and enemy, used for NIS
	ScenarioInfo.INTRO_EnemyLand01 = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'P1_ENEM01_NIS_Land_01')
	ScenarioInfo.INTRO_EnemyLand02 = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'P1_ENEM01_NIS_Land_02')
	ScenarioInfo.INTRO_EnemyLand03 = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'P1_ENEM01_NIS_Land_03')

	ScenarioInfo.INTRO_PlayerLand01 = NIS.CreateNISOnlyGroup('ARMY_PLAYER', 'P1_PLAYER_NIS_Land_01')
	ScenarioInfo.INTRO_PlayerLand02 = NIS.CreateNISOnlyGroup('ARMY_PLAYER', 'P1_PLAYER_NIS_Land_02')
end

function func_OPENING_Transports(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	-- create a transport that will move south. It will be cleaned up at the end of the NIS,
	-- and the Opscript will turn on the 'real' transport loop afterwards.
	local transport = NIS.CreateNISOnlyUnit('ARMY_CIVL01', 'P1_CIVL01_NIS_SouthTransport')

	-- create another group of transports to sequence as well
	local transportGroup = NIS.CreateNISOnlyGroup('ARMY_CIVL01', 'NIS_TRANS_Group01')

	IssueMove( {transport}, GetPos('P1_TransportEvacReturn_South_02') )
	IssueMove( {transport}, GetPos('P1_TransportEvacReturn_South_01') )

	ForkThread(
		function()
			WaitSeconds(3.0)

			for k, unit in transportGroup do
				WaitSeconds(1.8)
				IssueMove( {unit}, GetPos('P1_TransportEvacReturn_South_02') )
				IssueMove( {unit}, GetPos('P1_TransportEvacReturn_South_01') )
			end
		end
	)
end

function func_OPENING_EnemyArrival(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ForkThread(
		function()
			-- Enemy land units move in to attack via different routes.
	 		NIS.GroupMoveChain(ScenarioInfo.INTRO_EnemyLand03, 'P1_ENEM01_Init_NIS_Chain3')
	 		WaitSeconds(2.0)
	 		NIS.GroupMoveChain(ScenarioInfo.INTRO_EnemyLand02, 'P1_ENEM01_Init_NIS_Chain2')
			WaitSeconds(3.0)
			NIS.GroupMoveChain(ScenarioInfo.INTRO_EnemyLand01, 'P1_ENEM01_Init_NIS_Chain1')
		end
	)
end

function func_OPENING_MoveCDR(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('INTRONIS_CommanderMove_01_Marker'))
		return
	end

	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('INTRONIS_CommanderMove_01_Marker'))
end

function func_OPENING_EnemyLandAttacks(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	-- Enemy land units move in to attack via different routes.
	NIS.GroupMoveChain(ScenarioInfo.INTRO_EnemyLand01, 'P1_ENEM01_Init_Mid1_Chain')
	NIS.GroupMoveChain(ScenarioInfo.INTRO_EnemyLand02, 'P1_ENEM01_Init_Mid2_Chain')
	NIS.GroupMoveChain(ScenarioInfo.INTRO_EnemyLand03, 'P1_ENEM01_Init_Mid3_Chain')
end

function func_OPENING_PlayerLandAttacks(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ScenarioInfo.NIS_FATBOY = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'NIS_FATBOY')
	ScenarioInfo.NIS_MOBILES = NIS.CreateNISOnlyGroup('ARMY_PLAYER', 'NIS_MOBILES')

	-- Player units move in to attack.
	NIS.GroupMoveChain(ScenarioInfo.INTRO_PlayerLand01, 'P1_ENEM01_Init_NIS_Chain1')
	NIS.GroupMoveChain(ScenarioInfo.INTRO_PlayerLand02, 'P1_ENEM01_Init_NIS_Chain3')
	NIS.GroupMoveChain(ScenarioInfo.NIS_MOBILES, 'P1_ENEM01_Init_NIS_Chain2')

	IssueMove({ScenarioInfo.NIS_FATBOY}, GetPos('P1_PLAYER_Init_Mid1_Chain_01'))
end

function func_OPENING_EnemyTransportSequence(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ScenarioInfo.NIS_TRANSPORT_01 = NIS.CreateNISOnlyUnit('ARMY_ENEM01', 'NIS_TRANSPORT_01')
	ScenarioInfo.NIS_TRANSPORT_02 = NIS.CreateNISOnlyUnit('ARMY_ENEM01', 'NIS_TRANSPORT_02')
	ScenarioInfo.NIS_TRANSPORT_03 = NIS.CreateNISOnlyUnit('ARMY_ENEM01', 'NIS_TRANSPORT_03')

	ScenarioInfo.NIS_TRANS_GROUP_01 = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_TRANS_GROUP_01')
	ScenarioInfo.NIS_TRANS_GROUP_02 = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_TRANS_GROUP_02')
	ScenarioInfo.NIS_TRANS_GROUP_03 = NIS.CreateNISOnlyGroup('ARMY_ENEM01', 'NIS_TRANS_GROUP_03')

	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_TRANS_GROUP_01,		-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_TRANSPORT_01,		-- unit handle for the actual transport
			approachChain			= nil,									-- optional chainName for the approach travel route
			unloadDest				= 'NIS_TRANSPORT_05',					-- destination for the transport drop-off
			returnDest				= 'NIS_TRANSPORT_09',					-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= true,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'P1_PLAYER_Init_Mid1_Chain_03',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,									-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,									-- will this transport be usable after the NIS?
		}
	)

	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_TRANS_GROUP_02,		-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_TRANSPORT_02,		-- unit handle for the actual transport
			approachChain			= nil,									-- optional chainName for the approach travel route
			unloadDest				= 'NIS_TRANSPORT_06',					-- destination for the transport drop-off
			returnDest				= 'NIS_TRANSPORT_10',					-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= true,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'P1_PLAYER_Init_Mid1_Chain_01',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,									-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,									-- will this transport be usable after the NIS?
		}
	)

	NIS.TransportArrival(
		{
			armyName				= 'ARMY_ENEM01',						-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.NIS_TRANS_GROUP_03,		-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.NIS_TRANSPORT_03,		-- unit handle for the actual transport
			approachChain			= nil,									-- optional chainName for the approach travel route
			unloadDest				= 'NIS_TRANSPORT_07',					-- destination for the transport drop-off
			returnDest				= 'NIS_TRANSPORT_11',					-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= true,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= 'P1_PLAYER_Init_Mid1_Chain_02',		-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= nil,									-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= true,									-- will this transport be usable after the NIS?
		}
	)
end

function func_OPENING_DestroyNISUnits(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	ForkThread(
		function()
			for k, unit in ScenarioInfo.NIS_TRANS_GROUP_01 do
				NIS.ForceUnitDeath(unit)
				WaitSeconds(0.4)
			end
		end
	)

	ForkThread(
		function()
			for k, unit in ScenarioInfo.NIS_MOBILES do
				NIS.ForceUnitDeath(unit)
				WaitSeconds(0.4)
			end
		end
	)

	ForkThread(
		function()
			for k, unit in ScenarioInfo.NIS_TRANS_GROUP_02 do
				NIS.ForceUnitDeath(unit)
				WaitSeconds(0.4)
			end
		end
	)

	ForkThread(
		function()
			for k, unit in ScenarioInfo.INTRO_PlayerLand01 do
				NIS.ForceUnitDeath(unit)
				WaitSeconds(0.4)
			end
		end
	)

	ForkThread(
		function()
			for k, unit in ScenarioInfo.NIS_TRANS_GROUP_02 do
				NIS.ForceUnitDeath(unit)
				WaitSeconds(0.4)
			end
		end
	)

	ForkThread(
		function()
			for k, unit in ScenarioInfo.INTRO_PlayerLand02 do
				NIS.ForceUnitDeath(unit)
				WaitSeconds(0.4)
			end
		end
	)
end

function func_REVEAL_ENEMY_LaunchWestNuke()
	func_REVEAL_ENEMY_LaunchNuke(ScenarioInfo.P1_ENEM01_NukeLauncher1)
end

function func_REVEAL_ENEMY_LaunchEastNuke()
	func_REVEAL_ENEMY_LaunchNuke(ScenarioInfo.P1_ENEM01_NukeLauncher2)
end

function func_REVEAL_ENEMY_DeleteNukes()
    for k, nuke in NukeHandles do
        if nuke then
            LOG('----- NIS NUKE: destroying nuke in flight, ' .. k .. ' ', nuke)
            nuke:Destroy()
        end
    end
end

function func_REVEAL_ENEMY_CreateExplosion()
	NIS.NukePosition('P2_INTRONIS_Nuke_Target_01')

	local pos = GetPos('P2_INTRONIS_Nuke_Target_01')

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_CIVL01],
	}
	-- function KillUnitsAroundPosition(position, nRadius, bRestrictACUs, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').KillUnitsAroundPosition(pos, 50, true, brainList)
end

function func_REVEAL_ENEMY_LaunchNuke(launcher)
	--NOTE: this is a special one-off for U05s NIS, to get a handle to a launched nuke (so we can then delete it).
	-- Dont use the following elsewhere without running it by Gordon and Brian. -Greg 8/25/2009 10:23:03 AM
	if launcher and not launcher:IsDead() then
 		launcher:GiveNukeSiloAmmo(1)
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---NOTE: if you are considering copying any of the below content ever - ask the question why? Really why? Dont do it! - bfricks 11/22/09
 		local wpn = launcher:GetWeapon('NukeMissiles')
		if wpn then
			LOG('----- NIS NUKE: found our valid wpn')
			wpn.CreateProjectileAtMuzzle = function(self, muzzle)
				LOG('----- NIS NUKE: rebound our muzzle creation function')
				local proj = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
				LOG('----- NIS NUKE: nuke id ', proj)
				table.insert(NukeHandles, proj)
			end
			local proj = wpn:CreateProjectileAtMuzzle()
			table.insert(NukeHandles, proj)
		else
			WARN('WARNING: NIS missile launch will fail - unable to get a handle to the weapon!')
		end
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		---@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

		IssueNuke({launcher}, GetPos('P2_INTRONIS_Nuke_Target_01'))
	end
end

function func_VICTORY_MoveCDR()
	IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
	IssueStop( {ScenarioInfo.PLAYER_CDR} )
	Warp(ScenarioInfo.PLAYER_CDR, GetPos('NIS_FINAL_WARP'))
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('NIS_FINAL_POSITION'))
end

