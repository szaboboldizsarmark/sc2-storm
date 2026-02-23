---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_I01/SC2_CA_I01_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_I01/SC2_CA_I01_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_I01/SC2_CA_I01_script.lua')
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
				func_OPENING_MovePlayerCDR(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('I01_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.I01_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	---NOTE: this seemed intentional as a way to flash intel - but it is odd to have a 0.0 duration... - bfricks 12/6/09
	NIS.CreateVizMarker('CDR_Formup', 400.0, 0.0)

	NIS.PlayMovie('/movies/FMV_ILL_OPENING')

	NIS.PreloadDialogData(
		{
			OpDialog.I01_NIS_OPENING_010,
			OpDialog.I01_NIS_OP_SETUP_010,
			OpDialog.I01_NIS_OP_SETUP_020,
			OpDialog.I01_NIS_OP_SETUP_030,
			OpDialog.I01_NIS_OP_SETUP_END,
		}
	)

	-- We need to make absolutely sure the movies are finished before proceeding past this point.
	while UIAreMoviesFinished() == false do
		-- Don't want to set this too high, otherwise it could affect our response time counter
		WaitSeconds(0.1)
	end

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('I01_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance and a start position
	NIS.StartNIS_Opening('CAM_A_03', 100.0, 'CDR_Formup')

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	func_OPENING_MovePlayerCDR()

	--Final VO: 16.4 seconds
	ForkThread(
		function()
			NIS.SetFOV(40.0)
			NIS.ZoomTo(GetPos('CDR_Formup'), GetOrient('CAM_A_03'), 50.0, 8.0)

			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS_CAM_B_03'), GetOrient('NIS_CAM_B_03'), -40.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_B_04'), GetOrient('NIS_CAM_B_04'), 0.0, 9.0)
		end
	)
    NIS.Dialog(OpDialog.I01_NIS_OPENING_010)

	--Final VO: 10.1 seconds
	ForkThread(
		function()
			NIS.SetFOV(70.0)
			NIS.ZoomTo(GetPos('NIS_CAM_F_05'), GetOrient('NIS_CAM_F_05'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_F_06'), GetOrient('NIS_CAM_F_06'), 0.0, 9.0)

			NIS.ZoomTo(GetPos('NIS_CAM_C_01'), GetOrient('NIS_CAM_C_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_C_02'), GetOrient('NIS_CAM_C_02'), 0.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.I01_NIS_OP_SETUP_010)

	--Final VO: 5.0 seconds
	--Combat
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_CAM_E_03'), GetOrient('NIS_CAM_E_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_E_04'), GetOrient('NIS_CAM_E_04'), 0.0, 5.0)
		end
	)
	NIS.Dialog(OpDialog.I01_NIS_OP_SETUP_020)

	--Final VO: 6.7 seconds
	--Capture
	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS_CAM_D_03'), GetOrient('NIS_CAM_D_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAM_D_04'), GetOrient('NIS_CAM_D_04'), 0.0, 7.0)
		end
	)
	NIS.Dialog(OpDialog.I01_NIS_OP_SETUP_030)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I01_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	--Final VO: 7.3 seconds
	NIS.DialogNoWait(OpDialog.I01_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY()

	NIS.PreloadDialogData(
		{
			OpDialog.I01_NIS_VICTORY_010,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('I01_NIS_VICTORY_Start')

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
	IssueStop ( {ScenarioInfo.PLAYER_CDR} )

	ForkThread(
		function()
			NIS.SetFOV(50.0)
			NIS.ZoomTo(GetPos('NIS2_VIC_CAM_A_01'), GetOrient('NIS2_VIC_CAM_A_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS2_VIC_CAM_A_02'), GetOrient('NIS2_VIC_CAM_A_02'), 0.0, 10.0)

		NIS.EntitySpinRelative(
			{
				ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
				degreesHeading		= 150.0,						-- heading offset relative to the unit (180.0 == frontside)
				degreesPitch		= -10.0,						-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
				nSpinRate			= 0.002,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
				nSpinDistance		= 7.0,							-- how close to spin relative to the unit
				nSpinDuration		= 17.0,							-- how long to allow the spin to persist
				nOffsetX			= 0.0,							-- if specified, offset in the X direction
				nOffsetY			= 4.6,							-- if specified, offset in the Y direction
				nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
			}
		)

		NIS.SetFOV(50.0)
		NIS.ZoomTo(GetPos('NIS2_VIC_CAM_B_01'), GetOrient('NIS2_VIC_CAM_B_01'), 0.0, 0.0)
		NIS.ZoomTo(GetPos('NIS2_VIC_CAM_B_02'), GetOrient('NIS2_VIC_CAM_B_02'), 0.0, 8.5)
		end
	)

	--Final VO: 30.5 seconds
	NIS.Dialog(OpDialog.I01_NIS_VICTORY_010)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------
function func_OPENING_MovePlayerCDR(bSkip)
	if bSkip then
		NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('CDR_Formup'))
		return
	end
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('CDR_Formup'))
end
