--------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local OpStrings	= import('/maps/SC2_CA_TUT_01/SC2_CA_TUT_01_OpStrings.lua')
local OpDialog	= import('/maps/SC2_CA_TUT_01/SC2_CA_TUT_01_OpDialog.lua')
local OpScript	= import('/maps/SC2_CA_TUT_01/SC2_CA_TUT_01_script.lua')
local OpNIS		= import('/maps/SC2_CA_TUT_01/SC2_CA_TUT_01_OpNIS.lua')

local NIS		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua')
local GetPos	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetPos
local GetOrient	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetOrient

local RandomInt	= import('/lua/system/utilities.lua').GetRandomInt

---------------------------------------------------------------------
-- NIS_OPENING:
---------------------------------------------------------------------
function NIS_OPENING()

	NIS.PreloadDialogData(
		{
			OpDialog.TUT1_NIS_OPEN_10,
			OpDialog.TUT1_NIS_OPEN_20,
			OpDialog.TUT1_NIS_OPEN_30,
			OpDialog.TUT1_PAN_ASSIGN,
			OpDialog.TUT1_PAN_COMPLETE,
			OpDialog.TUT1_ROTATE_ASSIGN,
			OpDialog.TUT1_ROTATE_COMPLETE,
			OpDialog.TUT1_TILT_ASSIGN,
			OpDialog.TUT1_ZOOM_ASSIGN,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('T01_NIS_OPENING_Start')

	NIS.CreateVizMarker('CDR_INITIAL_LOCATION', 800)

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Opening('NIS_OPENING_CAM_01', 0.0)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_OPENING_CAM_01'), GetOrient('NIS_OPENING_CAM_01'), 0.0, 0.0)
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('NIS_OPENING_CAM_02'), 100.0, 15.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_NIS_OPEN_10)

	NIS.Dialog(OpDialog.TUT1_NIS_OPEN_20)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_NIS_OPEN_30)

	NIS.Dialog(OpDialog.TUT1_PAN_ASSIGN)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('T01_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_ROATATE:
---------------------------------------------------------------------
function NIS_ROTATE()

	NIS.StartNIS_Standard()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 2.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_PAN_COMPLETE)

	NIS.Dialog(OpDialog.TUT1_ROTATE_ASSIGN)

	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_TILT:
---------------------------------------------------------------------
function NIS_TILT()

	LOG('----- NIS_SELECTION_INTRO: Start.')
	NIS.StartNIS_Standard()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 2.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_ROTATE_COMPLETE)

	--NIS.Dialog(OpDialog.TUT1_RESET_HINT)

	NIS.Dialog(OpDialog.TUT1_TILT_ASSIGN)

	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_TILT:
---------------------------------------------------------------------
function NIS_ZOOM()

	LOG('----- NIS_SELECTION_INTRO: Start.')
	NIS.StartNIS_Standard()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 2.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_TILT_COMPLETE)

	NIS.Dialog(OpDialog.TUT1_ZOOM_ASSIGN)

	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_SELECTION_INTRO:
---------------------------------------------------------------------
function NIS_SELECTION_INTRO()

	NIS.PreloadDialogData(
		{
			OpDialog.TUT1_ZOOM_COMPLETE,
			OpDialog.TUT1_NIS_SELECT_010,
			OpDialog.TUT1_SELECT_ASSIGN,
			OpDialog.TUT1_MOVE_COMPLETE,
			OpDialog.TUT1_NIS_ATTACK_010,
			OpDialog.TUT1_ATTACK_ASSIGN,
			OpDialog.TUT1_NIS_COMBAT_010,
			OpDialog.TUT1_COMBAT_ASSIGN,
		}
	)

	LOG('----- NIS_SELECTION_INTRO: Start.')
	NIS.StartNIS_Standard()

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 2.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_ZOOM_COMPLETE)

	ForkThread(
		function()
			NIS.EntitySpinRelative(
				{
					ent					= ScenarioInfo.PLAYER_CDR,		-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 160.0,						-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 5.0,							-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nSpinRate			= 0.005,						-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
					nSpinDistance		= 10.0,							-- how close to spin relative to the unit
					nSpinDuration		= 9.0,							-- how long to allow the spin to persist
					nOffsetX			= 0.0,							-- if specified, offset in the X direction
					nOffsetY			= 4.0,							-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,							-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.TUT1_NIS_SELECT_010)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 2.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_SELECT_ASSIGN)

	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_ATTACK:
---------------------------------------------------------------------
function NIS_COMMANDS_ATTACK()

	LOG('----- NIS_COMMANDS_ATTACK: Start.')
	NIS.StartNIS_Standard()

	if ScenarioInfo.arrow01 then
		ScenarioInfo.arrow01:Destroy()
	end

	if ScenarioInfo.arrow02 then
		ScenarioInfo.arrow02:Destroy()
	end

	if ScenarioInfo.arrow03 then
		ScenarioInfo.arrow03:Destroy()
	end

	IssueClearCommands(ScenarioInfo.PlayerTanks)
	IssueFormMove(ScenarioInfo.PlayerTanks, GetPos('MOVE_MARKER'), 'AttackFormation', 180)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('NIS_ATTACK_CAM_01'), GetOrient('NIS_ATTACK_CAM_01'), 0.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_MOVE_COMPLETE)

	NIS.Dialog(OpDialog.TUT1_NIS_ATTACK_010)

	NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('Move_Markers_03'))
	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('MOVE_MARKER'))

	NIS.Dialog(OpDialog.TUT1_ATTACK_ASSIGN)

	NIS.EndNIS_Standard()
end

---------------------------------------------------------------------
-- NIS_COMBAT:
---------------------------------------------------------------------
function NIS_COMBAT()

	LOG('----- NIS_COMMANDS_ATTACK: Start.')

	NIS.StartNIS_Standard()

	func_NIS_COMBAT_TransportGroups2()

	IssueClearCommands({ScenarioInfo.PLAYER_CDR})
	IssueMove({ScenarioInfo.PLAYER_CDR}, GetPos('COMBAT_MARKER'))

	IssueClearCommands(ScenarioInfo.PlayerTanks)
	IssueFormMove(ScenarioInfo.PlayerTanks, GetPos('COMBAT_MARKER'), 'AttackFormation', 180)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('TUT01_Combat2_Camera_01'), GetOrient('TUT01_Combat2_Camera_01'), 20.0, 2.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_NIS_COMBAT_010)

	NIS.EndNIS_Standard()

	NIS.DialogNoWait(OpDialog.TUT1_COMBAT_ASSIGN)
end

---------------------------------------------------------------------
-- NIS_PART2_OPENING:
---------------------------------------------------------------------
function NIS_PART2_OPENING()

	NIS.PreloadDialogData(
		{
			OpDialog.TUT1_COMBAT_OVER,
			OpDialog.TUT1_NIS_PART2_10,
			OpDialog.TUT1_NIS_PART2_20,
			OpDialog.TUT1_FACTORY_ASSIGN,
			OpDialog.TUT1_MASS_ASSIGN_10,
			OpDialog.TUT1_MASS_ASSIGN_20,
			OpDialog.TUT1_BUILD_ASSIGN,
		}
	)

	-- begin music as the game starts to fade-in
	NIS.PlayMusicEventByHandle('T02_NIS_OPENING_Start')

	-- use StartNIS_Opening and pass in the starting orient cam and zoom distance - auto-centers on the playerCDR
	NIS.StartNIS_Standard()

	local unitList = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetListOfUnits(categories.ALLUNITS, false)
	for k, unit in unitList do
		IssueClearCommands({unit})
		IssueFormMove({unit}, GetPos('PART2_WARP'), 'AttackFormation', 180)
	end

	ForkThread(
		function()
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_COMBAT_OVER)

	ForkThread(
		function()
			--- Time Dilation: clear builds, add bases
			NIS.FadeOut(1.5)
			WaitSeconds(2.0)

			IssueClearCommands({ScenarioInfo.PLAYER_CDR})
			NIS.WarpUnit(ScenarioInfo.PLAYER_CDR, GetPos('PART2_WARP'))
			IssueClearCommands({ScenarioInfo.PLAYER_CDR})
			IssueFormMove({ScenarioInfo.PLAYER_CDR}, GetPos('CDR_INITIAL_LOCATION'), 'AttackFormation', 0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_NIS_PART2_10)

	ForkThread(
		function()
			NIS.FadeIn(1.5)
			NIS.ZoomTo(GetPos('CDR_INITIAL_LOCATION'), GetOrient('CAM_OPENING'), 50.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_NIS_PART2_20)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('CDR_INITIAL_LOCATION'), GetOrient('CAM_OPENING'), 50.0, 0.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_FACTORY_ASSIGN)

	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('T02_NIS_OPENING_End')

	-- use EndNIS_Opening and pass in the ZoomOverride if desired
	NIS.EndNIS_NoRestore()
end

---------------------------------------------------------------------
-- NIS_MASS:
---------------------------------------------------------------------
function NIS_MASS()
	LOG('----- NIS_COMBAT1: Start.')
	NIS.StartNIS_Standard()

	ForkThread(
		function()
			WaitSeconds(3.0)
			NIS.EntityZoomToRelative(
				{
					ent					= ScenarioInfo.PLAYER_ENGINEERS01,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,	-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 15.0,	-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nZoomToDistance		= 30.0,				-- how close to zoom-in relative to the unit
					nZoomToDuration		= 0.0,				-- how long to allow the zoom-in to take
					nOffsetX			= 0.0,				-- if specified, offset in the X direction
					nOffsetY			= 0.0,				-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,				-- if specified, offset in the Z direction
				}
			)
			NIS.Track({ScenarioInfo.PLAYER_ENGINEERS01}, 30.0, 4.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_MASS_ASSIGN_10)

	ForkThread(
		function()
			NIS.ZoomTo(GetPos('Mass_03'), GetOrient('CAM_OPENING'), 20.0, 3.0)
			WaitSeconds(3.0)
			NIS.ZoomTo(GetPos(ScenarioInfo.PLAYER_CDR), GetOrient('CAM_OPENING'), 50.0, 3.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_MASS_ASSIGN_20)

	NIS.EndNIS_Standard()
end

---------------------------------------------------------------------
-- NIS_BUILD_INTRO:
---------------------------------------------------------------------
function NIS_BUILD_INTRO()
	LOG('----- NIS_ADDON: Start.')
	NIS.StartNIS_Standard()

	-- Get a handle to a player factory. This table was generated when the player would
	-- only have been able to build a single factory (and so contains just one factory), but
	-- just out of extreme paranoia, get a definite handle to a single structure.
	local factory
	for k, v in ScenarioInfo.PlayerLandFactory do
		if v and not v:IsDead() then
			factory = v
			break
		end
	end

	ForkThread(
		function()
			NIS.EntityZoomToRelative(
				{
					ent					= factory,	-- a handle to the in-game object being used as the center of the zoom
					degreesHeading		= 180.0,	-- heading offset relative to the unit (180.0 == frontside)
					degreesPitch		= 25.0,	-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
					nZoomToDistance		= 60.0,				-- how close to zoom-in relative to the unit
					nZoomToDuration		= 2.0,				-- how long to allow the zoom-in to take
					nOffsetX			= 0.0,				-- if specified, offset in the X direction
					nOffsetY			= 0.0,				-- if specified, offset in the Y direction
					nOffsetZ			= 0.0,				-- if specified, offset in the Z direction
				}
			)
		end
	)
	NIS.Dialog(OpDialog.TUT1_BUILD_ASSIGN)

	NIS.EndNIS_Standard()
end

---------------------------------------------------------------------
-- NIS_COMBAT1:
---------------------------------------------------------------------
function NIS_END_COMBAT()

	NIS.PreloadDialogData(
		{
			OpDialog.TUT1_NIS_ENDCOMBAT,
			OpDialog.TUT1_ENDCOMBAT_COMPLETE,
			OpDialog.TUT1_NIS_VICTORY_010,
		}
	)

	LOG('----- NIS_COMBAT1: Start.')
	NIS.StartNIS_Standard()

	local unitList = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:GetListOfUnits(categories.uul0101 + categories.uul0103, false)
	for k, unit in unitList do
		if unit and not unit:IsDead() then
			IssueClearCommands({unit})
			IssueFormMove({unit}, GetPos('BATTLE_MARKER'), 'AttackFormation', 180)
			local killed = RandomInt(1,3)
			if killed == 1 then
				unit:SetCanBeKilled(false)
 			end
 		end
	end

	ForkThread(
		function()
			WaitSeconds(3.0)
			NIS.ZoomTo(GetPos('NIS_ENDCOMBAT_02'), GetOrient('NIS_ENDCOMBAT_02'), 0.0, 0.0)
			WaitSeconds(3.0)
			NIS.ZoomTo(GetPos('NIS_ENDCOMBAT'), GetOrient('NIS_ENDCOMBAT'), 0.0, 6.0)
		end
	)
	NIS.Dialog(OpDialog.TUT1_NIS_ENDCOMBAT)

	NIS.EndNIS_Standard()
end

---------------------------------------------------------------------
-- NIS_VICTORY:
---------------------------------------------------------------------
function NIS_VICTORY(tableVictoryData)
	-- trigger music system for this transition point
	NIS.PlayMusicEventByHandle('T01_NIS_VICTORY_Start')

	-- use the standard NIS start
	NIS.StartNIS_Standard()

	WaitSeconds(2.0)

	-- TEMP: track to the player CDR. This should be replaced by proper camera work. - bfricks 6/13/09
	NIS.Track({ScenarioInfo.PLAYER_CDR}, 40.0, 2.0)
	NIS.Dialog(OpDialog.TUT1_ENDCOMBAT_COMPLETE)

	NIS.Dialog(OpDialog.TUT1_NIS_VICTORY_010)

	-- wrap up and allow for optional continued gameplay
	NIS.EndNIS_Victory(nil, true)
end


---------------------------------------------------------------------
-- SUPPORT FUNCTIONS:
---------------------------------------------------------------------

function func_NIS_COMBAT_TransportGroups2()
	-- group2
	NIS.TransportArrival(
		{
			armyName				= 'ARMY_PLAYER',							-- name of the army for whom the transport and group are being created
			units					= 'TUT01_Combat_Group02',					-- group handle for units to be stored, transported, unloaded, then told to move
			transport				= ScenarioInfo.P2_Selection_Transport02,	-- unit handle for the actual transport
			approachChain			= nil,										-- optional chainName for the approach travel route
			unloadDest				= 'TUT01_Combat_TransportDestination_02',	-- destination for the transport drop-off
			returnDest				= 'TUT01_Combat_TransportReturn01',			-- optional destination for where the transports will fly-away
			bSkipTransportCleanup	= false,									-- will this transport be deleted when near returnDest?
			platoonMoveDest			= nil,			-- optional destination for the group to be moved to after being dropped-off
			onUnloadCallback		= FlagTransportPlatoon_Callback,										-- optional function to call when the transport finishes unloading
			bUnSelectAfterNIS		= false,										-- will this transport be usable after the NIS?
		}
	)
end

function FlagTransportPlatoon_Callback(platoon)
	-- keep one group unkillable for safety, leave the other not so for some realism
	-- dont let this group of units be destroyed in any way, tho taking damage is ok.
	for k, v in platoon:GetPlatoonUnits() do
		if v and not v:IsDead() then
        	v:SetVeterancy(5)
        	v:SetReclaimable(false)
        	v:SetCapturable(false)
        	v:SetCanBeKilled(false)
		end
	end
end