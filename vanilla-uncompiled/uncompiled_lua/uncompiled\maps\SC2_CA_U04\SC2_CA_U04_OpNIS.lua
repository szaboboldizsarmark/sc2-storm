---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_U04/SC2_CA_U04_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_U04/SC2_CA_U04_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_U04/SC2_CA_U04_script.lua')
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
				func_OPENING_HideRealPlayerUnits(true)
				func_OPENING_MoveCDR01(true)
				func_OPENING_EnemyTransportSequence(true)
				func_OPENING_EnemyCaptureFatboyBuild(true)
				func_OPENING_UpperAreaCleanup(true)
				func_OPENING_PlayerAirSequence(true)
				func_OPENING_PlayerTransportSequence(true)
				---NOTE: this is a potential solution to inconsistent flight durations - if this is not deemed appropriate we will need to
				---			consider fake ACUs for the NIS - bfricks 10/28/09
				while not ScenarioInfo.CDR_LANDED do
					WARN('WARNING: NIS paused due to CDR not being in position for scripted commands - if this spams, pass to campaign design.')
					WaitTicks(1)
				end
				func_OPENING_StructureSwap(true)
				func_OPENING_TimeDilationStart(true)
				func_OPENING_EnemyFatboyAreaSetup(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('U04_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.U04_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.U04_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.U04_NIS_OPENING_010,
			OpDialog.U04_NIS_OPENING_020,
			OpDialog.U04_NIS_OPENING_025,
			OpDialog.U04_NIS_OPENING_030,
			OpDialog.U04_NIS_OPENING_040,
			OpDialog.U04_NIS_OPENING_050,
			OpDialog.U04_NIS_OPENING_060,
			OpDialog.U04_NIS_OPENING_065,
			OpDialog.U04_NIS_OP_SETUP_010,
			OpDialog.U04_NIS_OP_SETUP_END,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('U04_NIS_OPENING_Start')

	-- hide the real player units
	func_OPENING_HideRealPlayerUnits()

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS1_CAM_A_01',0.0,'NIS1_CAM_A_01')
	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	--Commander moves forked in case we want some more movement in NIS
	ForkThread(func_OPENING_MoveCDR01)

	--Final VO: 14.8 seconds
	ForkThread(
		function()
			-- Wide shot of Maddox on cliff
			NIS.ZoomTo(GetPos('NIS1_CAM_A_02'), GetOrient('NIS1_CAM_A_02'), 0.0, 8.0)

			-- Track Maddox
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.INTRONIS_FauxCDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 140.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= -8.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 8.0,									-- how close to track relative to the unit
					nTrackToDuration	= 0.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 1.2,									-- if specified, offset in the X direction
					nOffsetY			= 2.1,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
		end
	)
	WaitSeconds(4.0)
	NIS.Dialog(OpDialog.U04_NIS_OPENING_010)

	--Fork the enemy commader arrival to time with NIS_OPENING_030
	ForkThread(
		function()
			WaitSeconds(4.0)
			func_OPENING_EnemyTransportSequence()
		end
	)

	---NOTE: moving this viz marker to earlier - not seeing any problems with this - but let me know if there are - bfricks 12/6/09
	NIS.CreateVizMarker('GantryArea_03_Marker', 200.0)

	--Final VO: 7.4 seconds
	ForkThread(
		function()
			-- OSS on Maddox, establish level area
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.INTRONIS_FauxCDR,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 0.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 0.0,								-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 10.0,								-- how close to track relative to the unit
					nTrackToDuration	= 0.0,								-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= 3.0,								-- if specified, offset in the X direction
					nOffsetY			= 3.0,								-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,								-- if specified, offset in the Z direction
				}
			)
			NIS.ZoomTo(GetPos('NIS1_CAM_B_04'), GetOrient('NIS1_CAM_B_04'), 0.0, 13.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_OPENING_020)

	WaitSeconds(2.0)

	NIS.Dialog(OpDialog.U04_NIS_OPENING_025)

	WaitSeconds(2.0)

	--Final VO: ~24 seconds
	ForkThread(
		function()
			-- Reveal experimental factory
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_G_01'), GetOrient('NIS1_CAM_G_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_G_02'), GetOrient('NIS1_CAM_G_02'), 0.0, 10.0)

			--WaitSeconds(2.0)

			-- Wide shot of Coleman landing
			NIS.ZoomTo(GetPos('NIS1_CAM_D1_05'), GetOrient('NIS1_CAM_D1_05'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D1_06'), GetOrient('NIS1_CAM_D1_06'), 0.0, 14.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_OPENING_030)

	--Final VO: ~10 seconds
	ForkThread(
		function()
			-- Pan into Coleman's experimental factory
			NIS.ZoomTo(GetPos('NIS1_CAM_D1_03'), GetOrient('NIS1_CAM_D1_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D1_04'), GetOrient('NIS1_CAM_D1_04'), 0.0, 8.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_OPENING_040)

	-- cleanup the upper area
	func_OPENING_UpperAreaCleanup()
	func_OPENING_PlayerAirSequence()
	func_OPENING_PlayerTransportSequence()

	NIS.SetFOV(60.0)
	NIS.ZoomTo(GetPos('NIS1_CAM_E_01'), GetOrient('NIS1_CAM_E_01'), 0.0, 0.0)
	NIS.ZoomTo(GetPos('NIS1_CAM_E_02'), GetOrient('NIS1_CAM_E_02'), 0.0, 6.0)

	-- execute the gantry-related structure swap, giving the player a set of units
	ForkThread(func_OPENING_StructureSwap)

	--Final VO: 3.0 seconds
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 210.0,					-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.005,					-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 10.0,						-- how close to spin relative to the unit
					nSpinDuration		= 4.5,						-- how long to allow the spin to persist
					nOffsetX			= 0.0,						-- if specified, offset in the X direction
					nOffsetY			= 4.0,						-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,						-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_OPENING_050)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_OPENING_TimeDilationStart')

	---NOTE: this is a potential solution to inconsistent flight durations - if this is not deemed appropriate we will need to
	---			consider fake ACUs for the NIS - bfricks 10/28/09
	while not ScenarioInfo.CDR_LANDED do
		WARN('WARNING: NIS paused due to CDR not being in position for scripted commands - if this spams, pass to campaign design.')
		WaitTicks(1)
	end

	-- fake build before we time dilate, then while dilated - create the full group
	func_OPENING_TimeDilationStart()
	NIS.SetFOV(60.0)
	NIS.ZoomTo(GetPos('NIS1_CAM_F_01'), GetOrient('NIS1_CAM_F_01'), 0.0, 0.0)
	NIS.FadeIn(1.5)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_OPENING_TimeDilationEnd')

	NIS.Dialog(OpDialog.U04_NIS_OPENING_060)

	--Final VO: ~18 seconds
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_F_02'), GetOrient('NIS1_CAM_F_02'), 0.0, 12.0)

			NIS.ZoomTo(GetPos('NIS1_CAM_C_01'), GetOrient('NIS1_CAM_C_01'), 0.0, 0.0)
 			NIS.ZoomTo(GetPos('NIS1_CAM_C_02'), GetOrient('NIS1_CAM_C_02'), 20.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_OPENING_065)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_OPENING_Fatboys')

	func_OPENING_EnemyFatboyAreaSetup()

	WaitSeconds(0.5) -- Wait for tanks to spawn

	--Final VO: ~9.6 seconds
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_02'), GetOrient('NIS1_CAM_D_02'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_01'), GetOrient('NIS1_CAM_D_01'), 0.0, 11.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_OP_SETUP_010)

	NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('NIS1_CAM_D_05'), 150.0, 0.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.U04_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_COLEMAN BANZAI MOVE:
---------------------------------------------------------------------
function NIS_TRANSPORT_ATTACK()

	NIS.PreloadDialogData(
		{
			OpDialog.U04_COLEMAN_ATTACK_020,
			OpDialog.U04_COLEMAN_ATTACK_022,
			OpDialog.U04_COLEMAN_ATTACK_025,
			OpDialog.U04_COLEMAN_ATTACK_030,
			OpDialog.U04_COLEMAN_ATTACK_035,
			OpDialog.U04_COLEMAN_ATTACK_040,
			OpDialog.U04_COLEMAN_ATTACK_050,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_TRANSPORT_ATTACK_Start')

	NIS.StartNIS_MidOp()

	-- call the setup function
	---NOTE: I am moving this call to inside the NIS, NIS only units need to be created during an NIS for them to be properly managed - bfricks 11/29/09
	func_TRANSPORT_ATTACK_Setup()

	func_TRANSPORT_ATTACK_TransportsLoad()

	NIS.Dialog(OpDialog.U04_COLEMAN_ATTACK_020) -- 1.6 Coleman is sick of it all

	ForkThread(
		function()
			-- Track Maddox
			NIS.ZoomTo(GetPos('NIS2_NukeCam_A_01'), GetOrient('NIS2_NukeCam_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_NukeCam_A_02'), GetOrient('NIS2_NukeCam_A_02'), 0.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.U04_COLEMAN_ATTACK_022) -- 3.7 Coleman is sick of it all

	func_TRANSPORT_ATTACK_MoveTransports()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_TRANSPORT_ATTACK_NukeLaunch')

	func_TRANSPORT_ATTACK_StopTransports()

	NIS.Dialog(OpDialog.U04_COLEMAN_ATTACK_025)--2 seconds (strategic launch)

	NIS.Dialog(OpDialog.U04_COLEMAN_ATTACK_030)--1.8 seconds "He's making sense"

	func_TRANSPORT_ATTACK_NukeSequence()

	NIS.CreateVizMarker('TransportAttack_NukeSpot', 500.0)

	NIS.ZoomTo(GetPos('TransportAttack_NukeSpot'), GetOrient('NUKE_CAM_01'), 250.0, 0.0)
	NIS.ZoomTo(GetPos('TransportAttack_NukeSpot'), GetOrient('NUKE_CAM_02'), 350.0, 5.0)

	func_TRANSPORT_ATTACK_TransportsUnload()

	ForkThread(
		function()
			--Camera stuff
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos(ScenarioInfo.P1_TransAttack_Transport_03), GetOrient('NIS2_NukeCam_D_01'), 30.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_NukeCam_D_02'), GetOrient('NIS2_NukeCam_D_02'), 30.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.U04_COLEMAN_ATTACK_035)--3.1 seconds (Maddox brain)

	WaitSeconds(2.0)

	--Final VO: 3.2 seconds
	NIS.Dialog(OpDialog.U04_COLEMAN_ATTACK_040)-- 1.6 seconds (Brings the hurt)

	WaitSeconds(4.0)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_TRANSPORT_ATTACK_ColemanMoves')

	-- call the cleanup function
	func_TRANSPORT_ATTACK_Cleanup()

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_TRANSPORT_ATTACK_End')

	NIS.EndNIS_MidOp()

	NIS.DialogNoWait(OpDialog.U04_COLEMAN_ATTACK_050)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(deathUnit)

	NIS.PreloadDialogData(
		{
			OpDialog.U04_NIS_VICTORY_005,
			OpDialog.U04_NIS_VICTORY_010,
			OpDialog.U04_NIS_VICTORY_015,
			OpDialog.U04_NIS_VICTORY_020,
			OpDialog.U04_NIS_VICTORY_030,
			OpDialog.U04_NIS_VICTORY_040,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('U04_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	NIS.CreateVizMarker(GetPos(deathUnit), 300.0)

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	local targetEnt = NIS.UnitDeathZoomTo(
		{
			unit					= deathUnit,	-- unit to be killed
			vizRadius				= 300,			-- optional distance for a visibility marker ring
			degreesHeading			= 170.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch			= 80.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance			= 225.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration			= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX				= 1.0,			-- if specified, offset in the X direction
			nOffsetY				= 3.0,			-- if specified, offset in the Y direction
			nOffsetZ				= 0.0,			-- if specified, offset in the Z direction
		}
	)
	NIS.Dialog(OpDialog.U04_NIS_VICTORY_005)

	func_VICTORY_ClearTransportZone()

	ForkThread(
		function()
			NIS.SetZoom(275.0, 20.0)
		end
	)
	WaitSeconds(7.0)
	NIS.Dialog(OpDialog.U04_NIS_VICTORY_010) --Final VO: 9.7 seconds (Rodgers speech)

	--Final VO: 7.9 seconds
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_WinCam_A_03'), GetOrient('NIS_WinCam_A_03'), 50.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_WinCam_A_04'), GetOrient('NIS_WinCam_A_04'), 50.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_VICTORY_015) -- 6.8 seconds (manly chat with Rodgers)

	-- Transport pickup
	func_VICTORY_CreateTransportPickup()

	WaitSeconds(2.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_EXIT_TRANSPORT_CAM_01'), GetOrient('NIS_EXIT_TRANSPORT_CAM_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_EXIT_TRANSPORT_CAM_02'), GetOrient('NIS_EXIT_TRANSPORT_CAM_02'), -10.0, 9.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_VICTORY_020) -- 7.9 seconds (talk to Daxil)

	ForkThread(
		function()
			NIS.EntityTrackRelative(
				{
					ent					= ScenarioInfo.NIS_EXIT_TRANSPORT,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 315.0,								-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 20.0,									-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nTrackDistance		= 30.0,									-- how close to track relative to the unit
					nTrackToDuration	= 15.0,									-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
					nOffsetX			= -2.0,									-- if specified, offset in the X direction
					nOffsetY			= 3.0,									-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,									-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_VICTORY_030) --Final VO: 19.4 seconds (talk to wife)

	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_WinCam_A_01'), GetOrient('NIS_WinCam_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_WinCam_A_02'), GetOrient('NIS_WinCam_A_02'), 0.0, 40.0)
		end
	)
	NIS.Dialog(OpDialog.U04_NIS_VICTORY_040) --Final VO: 6.1 seconds

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_HideRealPlayerUnits(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.HideGroup(ScenarioInfo.P1_PLAYER_InitAir_Fighters_01)
	NIS.HideGroup(ScenarioInfo.P1_PLAYER_InitAir_Bombers_01)
	NIS.HideGroup(ScenarioInfo.P1_PLAYER_InitAir_Gunships_01)
	NIS.HideUnit(ScenarioInfo.INTRONIS_Group1Transport)
	NIS.HideUnit(ScenarioInfo.INTRONIS_CommanderTransport)
end

function func_OPENING_MoveCDR01(bSkip)
	--NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	IssueMove ( ScenarioInfo.INTRONIS_Upper_Air, GetPos('FAUX_PLANE_PATROL01_01') )
	WaitSeconds(7.0)
	IssueMove ( {ScenarioInfo.INTRONIS_Upper_Prop_Transport}, GetPos('FAUX_PLANE_PATROL01_01') )
	IssueMove( {ScenarioInfo.INTRONIS_FauxCDR}, GetPos( 'INTRONIS_Upper_Commander_Move_01' ))
end

function func_OPENING_EnemyTransportSequence(bSkip)

	-- Group 1
	local data01 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					= 'P1_ENEM01_InitLand_SE_01',				-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= 'INTRONIS_ENEM01_Transport_01',			-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= 'INTRONIS_EnemTrans_LandingMarker_01',	-- destination for the transport drop-off
		returnDest				= 'INTRONIS_EnemTrans_ReturnMarker',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= 'INTRONIS_EnemTrans_Group01_Formup',		-- optional destination for the group to be moved to after being dropped-off
		onUnloadCallback		= nil,										-- optional function to call when the transport finishes unloading
	}
	NIS.TransportArrival(data01, bSkip)

	-- Group 2
	local data02 = {
		armyName				= 'ARMY_ENEM01',							-- name of the army for whom the transport and group are being created
		units					='P1_ENEM01_InitLand_SE_02',				-- group handle for units to be stored, transported, unloaded, then told to move
		transport				= 'INTRONIS_ENEM01_Transport_02',			-- unit handle for the actual transport
		approachChain			= nil,										-- optional chainName for the approach travel route
		unloadDest				= 'INTRONIS_EnemTrans_LandingMarker_02',	-- destination for the transport drop-off
		returnDest				= 'INTRONIS_EnemTrans_ReturnMarker',		-- optional destination for where the transports will fly-away
		bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
		platoonMoveDest			= 'INTRONIS_EnemTrans_Group01_Formup',		-- optional destination for the group to be moved to after being dropped-off
		onUnloadCallback		= func_OPENING_EnemyCaptureFatboyBuild,		-- optional function to call when the transport finishes unloading
	}
	NIS.TransportArrival(data02, bSkip)
end

function func_OPENING_EnemyCaptureFatboyBuild(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip == true then
		return
	end

	local delay = 1.2

	---NOTE: this is a special case, we need this to be on the transport callback - and we also don't want to wait when skipping NISs
	---			so we use the global variable here - bfricks 12/5/09
	if ScenarioInfo.Options.NoNIS then
		delay = 0.0
	end

	-- Begin the swap sequence for SE gantry structures
	ForkThread(
		function()
			local structures	= ScenarioInfo.SE_Gantry_Buildings		-- table containing structure handle and army info to be army-swapped
			local newArmy		= ScenarioInfo.ARMY_EXPENEM				-- the army that the structures will be swapped to

			for k, v in structures do
				if v.unit and not v.unit:IsDead() then
					v.unit = import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy( v.unit, newArmy)
					v.army = newArmy
					import('/lua/sim/ScenarioFramework.lua').ProtectUnit(v.unit)
					WaitSeconds(delay)
				end
			end
		end
	)
end

function func_OPENING_UpperAreaCleanup(bSkip)
	---NOTE: bSkip is not needed - this function is non-latent - bfricks 12/5/09

	NIS.DestroyUnit(ScenarioInfo.INTRONIS_UpperTrans)
	NIS.DestroyUnit(ScenarioInfo.INTRONIS_FauxCDR)
	NIS.DestroyGroup(ScenarioInfo.INTRONIS_Upper_Air)
end

function func_OPENING_PlayerAirSequence(bSkip)
	if not bSkip then
		-- show the units
		NIS.ShowGroup(ScenarioInfo.P1_PLAYER_InitAir_Fighters_01)
		NIS.ShowGroup(ScenarioInfo.P1_PLAYER_InitAir_Bombers_01)
		NIS.ShowGroup(ScenarioInfo.P1_PLAYER_InitAir_Gunships_01)
		NIS.ShowUnit(ScenarioInfo.INTRONIS_Group1Transport)
		NIS.ShowUnit(ScenarioInfo.INTRONIS_CommanderTransport)
	end

	-- send player air units to the main base area
	IssueMove( ScenarioInfo.P1_PLAYER_InitAir_Fighters_01, GetPos( 'P1_PLAYER_AirDest_01' ))
	IssueMove( ScenarioInfo.P1_PLAYER_InitAir_Bombers_01, GetPos( 'P1_PLAYER_AirDest_02' ))
	IssueMove( ScenarioInfo.P1_PLAYER_InitAir_Gunships_01, GetPos( 'P1_PLAYER_AirDest_03' ))
end

function func_OPENING_PlayerTransportSequence(bSkip)
	-- ENG group
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= ScenarioInfo.INTRONIS_Group1,				-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.INTRONIS_Group1Transport,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'INTRO_Engineer_Trans_LandingMarker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_PlayerTrans_ReturnMarker',		-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,										-- optional destination for the group to be moved to after being dropped-off
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
			unloadDest				= 'INTRONIS_PlayerTrans_LandingMarker_01',	-- destination for the transport drop-off
			returnDest				= 'INTRONIS_PlayerTrans_ReturnMarker',		-- optional destination for where the transports will fly-away
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

function func_OPENING_StructureSwap(bSkip)
	local delay = 1.3
	if bSkip then
		delay = 0.0
	end

	local structures	= ScenarioInfo.Player_Gantry_Buildings	-- table containing structure handle and army info to be army-swapped
	local newArmy		= ScenarioInfo.ARMY_EXPALLY				-- the army that the structures will be swapped to

	for k, v in structures do
		if v.unit and not v.unit:IsDead() then
			v.unit = import('/lua/sim/ScenarioFramework.lua').GiveUnitToArmy( v.unit, newArmy)
			v.army = newArmy
			import('/lua/sim/ScenarioFramework.lua').ProtectUnit(v.unit)
			WaitSeconds(delay)
		end
	end
end

function func_OPENING_TimeDilationStart(bSkip)
	if bSkip then
		NIS.FakeBuild(ScenarioInfo.PLAYER_CDR, 'ARMY_PLAYER', ScenarioInfo.ARMY_PLAYER, 'INTRONIS_PlayerFactory', 'P1_PLAYER_Starting_Base', 3.0, bSkip)
		return
	end

	NIS.FakeBuildNoWait(ScenarioInfo.PLAYER_CDR, 'ARMY_PLAYER', ScenarioInfo.ARMY_PLAYER, 'INTRONIS_PlayerFactory', 'P1_PLAYER_Starting_Base', 3.0)
	WaitSeconds(1.0)
	NIS.FadeOut(1.5)
	WaitSeconds(3.0)
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('INTRO_Engineer_Trans_LandingMarker_01') )
end

function func_OPENING_EnemyFatboyAreaSetup(bSkip)
	--NOTE: this function has no latent behavior - so doing full function when we are skipping - bfricks 12/5/09

	-- Clear the command of the enemy gantry, as we have now
	-- time-dilatd past that point, and we now see the result: two fatboys.
	-- Set up the 2 enemy fatboys, and send them in.
	-- Send the initial SE Fatboys along their way

	---### TODO: Sort the whole "for show" build sequence out. Commenting this out for now, as it should be done by timing, not as
	---### an emergent event (tuning changes could change timing, makes nonis difficult). -Greg 10/12/2009 1:51:55 PM
	--IssueClearCommands( {ScenarioInfo.P1_Southeast_Gantry} )

	for i = 1, 2 do
		local platoon = import('/lua/sim/ScenarioUtilities.lua').CreateArmyGroupAsPlatoon('ARMY_EXPENEM', 'EXPSE_Init_Fatboy_0' .. i, 'AttackFormation')
		import('/lua/sim/ScenarioFramework.lua').PlatoonPatrolChain(platoon, 'EXP01_SE_Fatboy_Chain_Playerbound')
		ScenarioInfo.EXP01_SE_Fatboy_OpAI:AddActivePlatoon(platoon, false)
		OpScript.P1_CreateEffectsOnFatboy(platoon)
	end

	ScenarioInfo.P1_SEFatboy01 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_EXPENEM]['EXPSE_Init_Fatboy_01_unit']
	ScenarioInfo.P1_SEFatboy02 = ScenarioInfo.UnitNames[ScenarioInfo.ARMY_EXPENEM]['EXPSE_Init_Fatboy_02_unit']
	ScenarioInfo.P1_SEFatboy01:SetCapturable(false)
	ScenarioInfo.P1_SEFatboy02:SetCapturable(false)

	-- Some starting air defenses at the SE gantry area for the enemy <ASEGD>
	ScenarioInfo.P1_ENEM01_SEGantry_Init_Air_01 = import('/lua/sim/ScenarioUtilities.lua').CreateArmyGroupAsPlatoon('ARMY_ENEM01', 'P1_ENEM01_SEGantry_Init_Air_01', 'AttackFormation')
	for k, v in ScenarioInfo.P1_ENEM01_SEGantry_Init_Air_01:GetPlatoonUnits() do
		local route = import('/lua/AI/ScenarioPlatoonAI.lua').GetRandomPatrolRoute(import('/lua/sim/ScenarioUtilities.lua').ChainToPositions('P1_ENEM01_SEGantry_AirPatrol_01'))
		import('/lua/sim/ScenarioFramework.lua').GroupPatrolRoute({v}, route)
	end
end

function func_TRANSPORT_ATTACK_Setup()
	-- hide the real commanders for the NIS
	NIS.HideUnit(ScenarioInfo.PLAYER_CDR)
	NIS.HideUnit(ScenarioInfo.P1_EnemyCommander)

	-- Stop the enemy Commander, so he is ready for subsequent commands.
	IssueClearCommands({ScenarioInfo.P1_EnemyCommander})

	-- Create a fake enemy commander, for largely tinfoil hat reasons.
	ScenarioInfo.TRANSNIS_FAKE_CDR = NIS.CreateNISOnlyUnit('ARMY_ENEM01', 'P1_ENEM01_TransNIS_FauxCDR')
end

function func_TRANSPORT_ATTACK_TransportsLoad()
	-- Get the fake enemy CDR in movement, so we see him walking to the pickup destination to meet the incoming transports.
	IssueMove({ScenarioInfo.TRANSNIS_FAKE_CDR}, GetPos( 'TransAttack_EnemyBase_TransDest_03' ))

	-- Move the transports to the pickup point.
	IssueMove( {ScenarioInfo.P1_TransAttack_Transport_01}, GetPos( 'TransAttack_EnemyBase_TransDest_01' ) )
	IssueMove( {ScenarioInfo.P1_TransAttack_Transport_02}, GetPos( 'TransAttack_EnemyBase_TransDest_02' ) )
	IssueMove( {ScenarioInfo.P1_TransAttack_Transport_03}, GetPos( 'TransAttack_EnemyBase_TransDest_03' ) )

	-- Transport 3 picks up the fake enemy commander
	IssueTransportLoad({ScenarioInfo.TRANSNIS_FAKE_CDR}, ScenarioInfo.P1_TransAttack_Transport_03 )
end

function func_TRANSPORT_ATTACK_MoveTransports()
	-- Send the transports to a destination, after loading the enemy fake commander.
	-- Because 2 of 3 transports are not doing any loading, we cant just queue up move
	-- commands for them: they would fail to wait for trans3 to pick up the CDR.
	IssueMove( {ScenarioInfo.P1_TransAttack_Transport_01}, GetPos( 'P1_TransAttack_LandingDest_01' ) )
	IssueMove( {ScenarioInfo.P1_TransAttack_Transport_02}, GetPos( 'P1_TransAttack_LandingDest_02' ) )
	IssueMove( {ScenarioInfo.P1_TransAttack_Transport_03}, GetPos( 'P1_TransAttack_LandingDest_03' ) )
end

function func_TRANSPORT_ATTACK_StopTransports()
	-- stop the transports
	for k, v in ScenarioInfo.P1_TransAttack_TransportTable do
		if v and not v:IsDead() then
			IssueClearCommands({v})
			IssueStop({v})
		end
	end
end

function func_TRANSPORT_ATTACK_NukeSequence()
	LOG('----- Transport NIS: Nuke sequence')

	-- If for some reason the fake enemy CDR failed to get picked up, manually attach him here while the transports
	-- are not in frame.
	if not ScenarioInfo.TRANSNIS_FAKE_CDR then
		WARN('WARNING: failure to find ScenarioInfo.TRANSNIS_FAKE_CDR during func_TRANSPORT_ATTACK_NukeSequence - this could be significant - pass to Campaign Design. - bfricks 10/3/09')
	elseif ScenarioInfo.TRANSNIS_FAKE_CDR:IsUnitState('Attached') then
		import('/lua/sim/ScenarioFramework/ScenarioGameUtilsTransport.lua').AddUnitsToTransportStorage({ScenarioInfo.TRANSNIS_FAKE_CDR}, {ScenarioInfo.P1_TransAttack_Transport_03})
	end

	-- light off a nuke effect at the location, and start a thread that will destroy all units around the point over time.
	NIS.NukePosition('TransportAttack_NukeSpot')

	local pos = GetPos('TransportAttack_NukeSpot')

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_PLAYER],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
		ArmyBrains[ScenarioInfo.ARMY_EXPENEM],
		ArmyBrains[ScenarioInfo.ARMY_EXPALLY],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 28, true, 5000, 90001, brainList)
end

function func_TRANSPORT_ATTACK_TransportsUnload()
	LOG('----- Transport NIS: Transports unload')

	-- warp them to the nuke area
	Warp(ScenarioInfo.P1_TransAttack_Transport_01, GetPos('TransAttack_NukeArea_TransWarp_01'))
	Warp(ScenarioInfo.P1_TransAttack_Transport_02, GetPos('TransAttack_NukeArea_TransWarp_02'))
	Warp(ScenarioInfo.P1_TransAttack_Transport_03, GetPos('TransAttack_NukeArea_TransWarp_03'))

	-- give them their unload commands
	IssueTransportUnload({ScenarioInfo.P1_TransAttack_Transport_01}, GetPos('P1_TransAttack_LandingDest_01'))
	IssueTransportUnload({ScenarioInfo.P1_TransAttack_Transport_02}, GetPos('P1_TransAttack_LandingDest_02'))
	IssueTransportUnload({ScenarioInfo.P1_TransAttack_Transport_03}, GetPos('P1_TransAttack_LandingDest_03'))

	-- send the transports back to base
	IssueMove({ScenarioInfo.P1_TransAttack_Transport_01}, GetPos( 'TransAttack_EnemyBase_TransDest_01'))
	IssueMove({ScenarioInfo.P1_TransAttack_Transport_02}, GetPos( 'TransAttack_EnemyBase_TransDest_02'))
	IssueMove({ScenarioInfo.P1_TransAttack_Transport_03}, GetPos( 'TransAttack_EnemyBase_TransDest_03'))

	-- Add faux CDR to the appropriate group of units he will attack with, so we can just give him and his group a single command.
	table.insert(ScenarioInfo.P1_TransAttack_Units_03, ScenarioInfo.TRANSNIS_FAKE_CDR)
end

function func_TRANSPORT_ATTACK_Cleanup()
	-- Clean up the NIS and prepare stuff for the game again. This function is from the main script, so doesnt
	-- need to be called here in the NIS.
	LOG('----- Transport NIS: Cleanup')

	-- REVISED: we never want this guy around - so we always destroy him - even if he is on the transport - bfricks 10/3/09
	NIS.DestroyUnit(ScenarioInfo.TRANSNIS_FAKE_CDR)

	-- get the real enemy commander in position
	Warp(ScenarioInfo.P1_EnemyCommander, GetPos('P1_TransAttack_LandingDest_03'))

	-- unhide the player and enemy cdr
	NIS.ShowUnit(ScenarioInfo.PLAYER_CDR)
	NIS.ShowUnit(ScenarioInfo.P1_EnemyCommander)
end

function func_VICTORY_ClearTransportZone()
	local pos = GetPos('NIS_TRANSPORT_EXIT_03')

	local brainList = {
		ArmyBrains[ScenarioInfo.ARMY_PLAYER],
		ArmyBrains[ScenarioInfo.ARMY_ENEM01],
		ArmyBrains[ScenarioInfo.ARMY_EXPENEM],
		ArmyBrains[ScenarioInfo.ARMY_EXPALLY],
	}
	-- function DamageUnitsAroundPosition(position, nRadius, bRestrictACUs, nDamagePlayer, nDamageOther, tableBrainList)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').DamageUnitsAroundPosition(pos, 28, true, 5000, 90001, brainList)
end

function func_VICTORY_CreateTransportPickup()
	ScenarioInfo.NIS_EXIT_TRANSPORT = NIS.CreateNISOnlyUnit('ARMY_PLAYER', 'NIS_EXIT_TRANSPORT')
	IssueClearCommands({ScenarioInfo.NIS_EXIT_TRANSPORT})
	IssueMove({ScenarioInfo.NIS_EXIT_TRANSPORT}, GetPos('NIS_TRANSPORT_EXIT_03'))

	Warp(ScenarioInfo.PLAYER_CDR, GetPos('NIS_TRANSPORT_EXIT_02'))
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('NIS_TRANSPORT_EXIT_03'))
	IssueTransportLoad({ScenarioInfo.PLAYER_CDR}, ScenarioInfo.NIS_EXIT_TRANSPORT)
	IssueMove({ScenarioInfo.NIS_EXIT_TRANSPORT}, GetPos('NIS_TRANSPORT_EXIT_04'))
	IssueMove({ScenarioInfo.NIS_EXIT_TRANSPORT}, GetPos('NIS_TRANSPORT_EXIT_05'))
	IssueMove({ScenarioInfo.NIS_EXIT_TRANSPORT}, GetPos('NIS_TRANSPORT_EXIT_06'))
end