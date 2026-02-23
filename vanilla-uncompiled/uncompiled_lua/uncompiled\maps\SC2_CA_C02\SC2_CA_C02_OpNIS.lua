---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings			= import('/maps/SC2_CA_C02/SC2_CA_C02_OpStrings.lua')
local OpDialog			= import('/maps/SC2_CA_C02/SC2_CA_C02_OpDialog.lua')
local OpScript			= import('/maps/SC2_CA_C02/SC2_CA_C02_script.lua')
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
				func_OPENING_HideOpeningUnits(true)
				func_OPENING_WarpAndMoveUnits(true)

				WaitSeconds(1.0)

				-- trigger music system for this transition point
				NIS.PlayMusicEventByHandle('C02_NIS_OPENING_Skip')

				NIS.DialogNoWait(OpDialog.C02_NIS_OP_SETUP_010)
				NIS.DialogNoWait(OpDialog.C02_NIS_OP_SETUP_020)
				NIS.DialogNoWait(OpDialog.C02_NIS_OP_SETUP_END)
			end,
			nOverrideZoom
		)

		-- return
		return
	end

	NIS.PreloadDialogData(
		{
			OpDialog.C02_NIS_OPENING_010,
			OpDialog.C02_NIS_OPENING_020,
			OpDialog.C02_NIS_OP_SETUP_010,
			OpDialog.C02_NIS_OP_SETUP_020,
			OpDialog.C02_NIS_OP_SETUP_END,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('C02_NIS_OPENING_Start')

	NIS.CreateVizMarker('NIS_AlgGenerator_Marker', 200)

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS_OPENING_CAM_01', 0.0, 'NIS_OPENING_CAM_01', 60.0)

	func_OPENING_HideOpeningUnits()

	NIS.DisplayTitle(OpStrings.OPERATION_NAME)

	ForkThread(func_OPENING_WarpAndMoveUnits)

	ForkThread(
		function()
			-- while dialog begins, use the starting shot and zoom in
			NIS.ZoomTo(GetPos('NIS_OPENING_CAM_02'), GetOrient('NIS_OPENING_CAM_02'), 0.0, 11.0)
		end
	)
	WaitSeconds(4.0)
	NIS.Dialog(OpDialog.C02_NIS_OPENING_010)	--Final VO: ~5 seconds (I've arrived)

	ForkThread(
		function()
			NIS.SetFOV(75.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_07'), GetOrient('NIS1_CAM_C_07'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_08'), GetOrient('NIS1_CAM_C_08'), 0.0, 12.0)
		end
	)
	NIS.Dialog(OpDialog.C02_NIS_OPENING_020) 	--Final VO: ~9.0 seconds (Strange structures)

	ForkThread(
		function()
			NIS.SetFOV(65.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_04'), GetOrient('NIS1_CAM_C_04'), -150.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_C_05'), GetOrient('NIS1_CAM_C_05'), -150.0, 14.0)
		end
	)
	NIS.Dialog(OpDialog.C02_NIS_OP_SETUP_010)	--Final VO: ~11.6 seconds (Constructed a base)

	ForkThread(
		function()
			NIS.SetFOV(60.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_03'), GetOrient('NIS1_CAM_D_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_D_04'), GetOrient('NIS1_CAM_D_04'), 0.0, 15.0)
		end
	)
	NIS.Dialog(OpDialog.C02_NIS_OP_SETUP_020)	--Final VO: ~11.3 seconds (Data Center/Server Core)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C02_NIS_OPENING_End')

	NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 100.0, 0.0)

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(nOverrideZoom)

	NIS.DialogNoWait(OpDialog.C02_NIS_OP_SETUP_END)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY()

	NIS.PreloadDialogData(
		{
			OpDialog.C02_NIS_VICTORY_010,
			OpDialog.C02_NIS_VICTORY_020,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('C02_NIS_VICTORY_Start')

	-- Highlight generator area
	NIS.CreateVizMarker('Blank Marker 02', 1000.0)

	-- use the victory NIS start
	NIS.StartNIS_Victory()

	--We use this function to always set the ACU to be un-hunkered
	NIS.UnHunker(ScenarioInfo.PLAYER_CDR)

	-- Final VO: 17.8 seconds
	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS1_CAM_G_01'), GetOrient('NIS1_CAM_G_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS1_CAM_G_02'), GetOrient('NIS1_CAM_G_02'), 0.0, 16.0)
		end
	)
	NIS.Dialog(OpDialog.C02_NIS_VICTORY_010)

	func_VICTORY_MoveCDR()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_FINAL_CAM_01'), GetOrient('NIS_FINAL_CAM_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_FINAL_CAM_02'), GetOrient('NIS_FINAL_CAM_02'), 0.0, 7.0)
		end
	)
	NIS.Dialog(OpDialog.C02_NIS_VICTORY_020)

	func_VICTORY_CleanupCDR()

	WaitSeconds(2.0)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end


------------------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
------------------------------------------------------------------------------
function func_OPENING_HideOpeningUnits(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	NIS.HideUnit(ScenarioInfo.PLAYER_CDR)

	for k, unit in ScenarioInfo.Engineers do
		NIS.HideUnit(unit)
	end

	for k, unit in ScenarioInfo.Warp_Units do
		NIS.HideUnit(unit)
	end
end

function func_OPENING_WarpAndMoveUnits(bSkip)
	---NOTE: this function has no current behavior that is game-critical -so when we are skipping NISs, just ignore - bfricks 12/5/09
	if bSkip then return end

	WaitSeconds(2.0)

	-- Warp in, move out
	NIS.WarpUnit( ScenarioInfo.PLAYER_CDR, GetPos('ARMY_WARP_01'))
	NIS.ShowUnit( ScenarioInfo.PLAYER_CDR )
	CreateTeleportEffects( ScenarioInfo.PLAYER_CDR )
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('ARMY_PLAYER') )

	WaitSeconds(2.5)

	for k, unit in ScenarioInfo.Engineers do
		NIS.WarpUnit( unit, GetPos('ARMY_WARP_01'))
		NIS.ShowUnit( unit )
		CreateTeleportEffects( unit )
		IssueMove( {unit}, GetPos('ARMY_UNITS_01') )
		WaitSeconds(1.5)
	end

	WaitSeconds(1.25)

	for k, unit in ScenarioInfo.Warp_Units do
		NIS.WarpUnit( unit, GetPos('ARMY_WARP_01'))
		NIS.ShowUnit( unit )
		CreateTeleportEffects( unit )
		IssueMove( {unit}, GetPos('ARMY_UNITS_02') )
		WaitSeconds(1.0)
	end
end

function func_VICTORY_MoveCDR()
	IssueClearCommands( {ScenarioInfo.PLAYER_CDR} )
	IssueStop ( {ScenarioInfo.PLAYER_CDR} )

	Warp( ScenarioInfo.PLAYER_CDR, GetPos('NIS_FINAL_WARP_02'))
	IssueMove( {ScenarioInfo.PLAYER_CDR}, GetPos('NIS_FINAL_WARP_01') )
end

function func_VICTORY_CleanupCDR()
	CreateTeleportEffects( ScenarioInfo.PLAYER_CDR )
	NIS.HideUnit(ScenarioInfo.PLAYER_CDR)
end