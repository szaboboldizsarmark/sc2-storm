---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings	= import('/maps/SC2_GC_DEMO/SC2_GC_DEMO_OpStrings.lua')
local OpDialog	= import('/maps/SC2_GC_DEMO/SC2_GC_DEMO_OpDialog.lua')
local OpScript	= import('/maps/SC2_GC_DEMO/SC2_GC_DEMO_script.lua')
local NIS		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua')
local GetPos	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetPos
local GetOrient	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetOrient

---------------------------------------------------------------------
-- NIS_OPENING:
---------------------------------------------------------------------
function NIS_OPENING()
	LOG('Gamescom DEMO:::: TEMP wait until PRELOAD/MENU FIXED 8/2/09 SB.....')
	WaitSeconds(3.0)

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS_CAM_01', 100.0, 'NIS_CAM_01')

	LOG('Play mellow base music')
	Sync.PlayMusic = 'UI_demo_base'

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_Opening(100.0)
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(tableVictoryData)
	-- use the standard NIS start
	NIS.StartNIS_Standard()

	-- TEMP: track to the player CDR. This should be replaced by proper camera work. - bfricks 6/13/09
	NIS.Track({ScenarioInfo.PLAYER_CDR}, 40.0, 2.0)
	WaitSeconds(5.0)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(OpDialog.I04_NIS_VICTORY_010, true)
end