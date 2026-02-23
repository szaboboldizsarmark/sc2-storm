---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings	= import('/maps/SC2_CA_TUT_02/SC2_CA_TUT_02_OpStrings.lua')
local OpDialog	= import('/maps/SC2_CA_TUT_02/SC2_CA_TUT_02_OpDialog.lua')
local OpScript	= import('/maps/SC2_CA_TUT_02/SC2_CA_TUT_02_script.lua')
local NIS		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua')
local GetPos	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetPos
local GetOrient	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetOrient
local ScenarioUtils			= import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework		= import('/lua/sim/ScenarioFramework.lua')

---------------------------------------------------------------------
-- NIS_OPENING:
---------------------------------------------------------------------
function NIS_OPENING()

	NIS.PreloadDialogData(
		{
			OpDialog.TUT2_NIS_OPEN_10,
			OpDialog.TUT2_NIS_OPEN_20,
			OpDialog.TUT2_RESEARCH_ASSIGN,
			OpDialog.TUT2_NIS_RESEARCH_010,
			OpDialog.TUT2_NIS_RESEARCH_020,
			OpDialog.TUT2_NIS_RESEARCH_030,
			OpDialog.TUT2_NIS_RESEARCH_040,
			OpDialog.TUT2_FACEOFF_ASSIGN,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('T02_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('CAM_OPENING', 50.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_CAMERA_OPENING_01'), GetOrient('NIS_CAMERA_OPENING_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_CAMERA_OPENING_02'), GetOrient('NIS_CAMERA_OPENING_02'), 0.0, 10.0)
		end
	)
	WaitSeconds(3.0)
	NIS.Dialog(OpDialog.TUT2_NIS_OPEN_10)

	NIS.Dialog(OpDialog.TUT2_NIS_OPEN_20)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('T02_NIS_OPENING_End')

	NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 0.0)

	NIS.Dialog(OpDialog.TUT2_RESEARCH_ASSIGN)

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_OPENING:
---------------------------------------------------------------------
function NIS_RESEARCH()

	NIS.StartNIS_Standard()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.Camera_Tank), GetOrient('CAM_OPENING'), 50.0, 0.0)
			NIS.Track({ScenarioInfo.Camera_Tank}, 50.0, 0.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_NIS_RESEARCH_010)

	ForkThread(
		function()
			WaitSeconds(1.5)
			ArmyBrains[ScenarioInfo.ARMY_PLAYER]:CompleteResearch( {'ULP_DOUBLEBARREL'} )
		end
	)
	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.Camera_Tank,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.005,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 10.0,							-- how close to spin relative to the unit
					nSpinDuration		= 10.0,							-- how long to allow the spin to persist
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 1.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.TUT2_NIS_RESEARCH_020)

	ForkThread(
		function()
			WaitSeconds(1.5)
			ArmyBrains[ScenarioInfo.ARMY_PLAYER]:CompleteResearch( {'ULP_AA'} )
		end
	)
	NIS.Dialog(OpDialog.TUT2_NIS_RESEARCH_030)

	ForkThread(
		function()
			WaitSeconds(1.5)
			ArmyBrains[ScenarioInfo.ARMY_PLAYER]:CompleteResearch( {'ULP_SHIELDS'} )
		end
	)
	NIS.Dialog(OpDialog.TUT2_NIS_RESEARCH_040)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.Camera_Tank), GetOrient('CAM_OPENING'), 50.0, 0.0)
			NIS.Track({ScenarioInfo.Camera_Tank}, 50.0, 0.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_FACEOFF_ASSIGN)

	IssueClearCommands(ScenarioInfo.RESEARCH_TANKS)
	IssueMove(ScenarioInfo.RESEARCH_TANKS, ScenarioUtils.MarkerToPosition( 'Attack_Tank_Dest' ))

	IssueClearCommands({ScenarioInfo.Camera_Tank})
	IssueMove({ScenarioInfo.Camera_Tank}, ScenarioUtils.MarkerToPosition( 'Attack_Tank_Dest' ))

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_TRANSITION:
---------------------------------------------------------------------
function NIS_TRANSITION()

	NIS.PreloadDialogData(
		{
			OpDialog.TUT2_TRANSITION_010,
			OpDialog.TUT2_TRANSITION_020,
			OpDialog.TUT2_TRANSITION_030,
			OpDialog.TUT2_STRATEGIC_ASSIGN,
			OpDialog.TUT2_NIS_FINALE_010,
			OpDialog.TUT2_NIS_FINALE_020,
			OpDialog.TUT2_NIS_FINALE_ASSIGN,
		}
	)

	NIS.StartNIS_Standard()

	ForkThread(
		function()
			--- Time Dilation: clear builds, add bases
			NIS.FadeOut(1.5)
			WaitSeconds(2.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_TRANSITION_010)

	--Setup player base
	ScenarioInfo.REAL_BASE = ScenarioUtils.CreateArmyGroup('ARMY_PLAYER', 'REAL_BASE')

	ForkThread(
		function()
			NIS.FadeIn(1.5)
			NIS.ZoomTo(GetPos('NIS_BASE_REVEAL_01'), GetOrient('NIS_BASE_REVEAL_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_BASE_REVEAL_02'), GetOrient('NIS_BASE_REVEAL_02'), 0.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_TRANSITION_020)

	WaitSeconds(2.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_BASE_REVEAL_03'), GetOrient('NIS_BASE_REVEAL_03'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_BASE_REVEAL_04'), GetOrient('NIS_BASE_REVEAL_04'), 0.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_TRANSITION_030)

	WaitSeconds(2.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 0.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_STRATEGIC_ASSIGN)

	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_FINALE:
---------------------------------------------------------------------
function NIS_FINALE()

	NIS.StartNIS_Standard()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 0.0)
			NIS.CreateVizMarker('ENEMY_BASE_SOUTH', 120)
			NIS.CreateVizMarker('ENEMY_BASE_NORTH', 120)
		end
	)
	NIS.Dialog(OpDialog.TUT2_NIS_FINALE_010)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_NORTH_REVEAL_01'), GetOrient('NIS_NORTH_REVEAL_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_NORTH_REVEAL_02'), GetOrient('NIS_NORTH_REVEAL_02'), 0.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_NIS_FINALE_020)

	WaitSeconds(2.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_SOUTH_REVEAL_01'), GetOrient('NIS_SOUTH_REVEAL_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos('NIS_SOUTH_REVEAL_02'), GetOrient('NIS_SOUTH_REVEAL_02'), 0.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_NIS_FINALE_ASSIGN)

	NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 3.0)

	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(tableVictoryData)

	NIS.PreloadDialogData(
		{
			OpDialog.TUT2_VICTORY_010,
			OpDialog.TUT2_VICTORY_020,
			OpDialog.TUT2_VICTORY_030,
		}
	)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('T02_NIS_VICTORY_Start')

	-- use the standard NIS start
	NIS.StartNIS_Standard()

	-- TEMP: track to the player CDR. This should be replaced by proper camera work. - bfricks 6/13/09
	NIS.Track({ScenarioInfo.PLAYER_CDR}, 50.0, 2.0)

	ForkThread(
	function()
		NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 0.0)
	end
	)
	NIS.Dialog(OpDialog.TUT2_VICTORY_010)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 0.0)
		end
	)
	NIS.Dialog(OpDialog.TUT2_VICTORY_030)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end

---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------

