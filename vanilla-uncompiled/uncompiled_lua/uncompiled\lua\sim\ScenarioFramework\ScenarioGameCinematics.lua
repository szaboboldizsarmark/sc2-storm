--------------------------------------------------------------------------
-- NOTE: THIS IS A GAME SPECIFIC FILE
-- Where possible, additions to this system that are not game specific
-- should be added to the shared parent file.
--------------------------------------------------------------------------

-----------------------------------------------------------------------------
--  File     :  /data/lua/sim/ScenarioFramework/ScenarioGameCinematics.lua
--  Author(s): Brian Fricks, Bret Alfieri
--  Summary  : Game specific functions for use in operation NISs.
--  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

---------------------------------------------------------------------
-- IMPORTS:
---------------------------------------------------------------------
local StartCameraSequence		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').StartCameraSequence
local EndCameraSequence			= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').EndCameraSequence
local GetPos					= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetPos
local GetOrient					= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').GetOrient
local ValidateCamera			= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').ValidateCamera
local AddToNISOnlyEntities		= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').AddToNISOnlyEntities
local AddToNISOnlyTransports	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').AddToNISOnlyTransports
local CreateNISQueue			= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').CreateNISQueue
local NISAddToProtectedUnitList	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').NISAddToProtectedUnitList
local DisableAllUnitAttackers	= import('/lua/sim/ScenarioFramework/ScenarioGameCinematicsSupport.lua').DisableAllUnitAttackers

---------------------------------------------------------------------
-- NIS Queue:
---------------------------------------------------------------------
-- ### NOTE: Having the queue here relies on StartNIS_Opening
-- ### being called at the start of every scenario. -balfieri 10/01/09
local NIS_Queue = CreateNISQueue()

---------------------------------------------------------------------
-- FUNCTIONS:
---------------------------------------------------------------------

---------------------------------------------------------------------
-- @name	- PlayMovie
-- @author	- Brian Fricks
-- @brief 	- request that movie <movieName> be played.
---------------------------------------------------------------------
function PlayMovie(movieName)
	-- If a request is play a movie is made, clera the movies finished flag (in case another movie has finished
	-- but the flag was skipped due to a bail condition)
	UIAreMoviesFinished()
	
	-- Here we do a special check to see if we have any updated movies for the Japanese build, and switch to that, if necessary.
	if __language == "jp" then		
		local jpMovieName = '/movies/jp' .. string.sub(movieName,8)		
		if DiskGetFileInfo(jpMovieName..'.usm') != false then 
			movieName = jpMovieName					
		end
	end

	Sync.PlayMovies = movieName
	---NOTE: going forward we might want to re-support /nofmv, but for now - this is the cleanest fix for black-screen doom due to the way we are
	---			using UIAreMoviesFinished() - bfricks 1/5/09
	---if not ScenarioInfo.Options.NoFMV then
	---	LOG('----------------Starting Movie:[', movieName, ']-------------------')
	---	Sync.PlayMovies = movieName
	---else
	---	LOG('----------------Skipping Movie:[', movieName, ']-------------------')
	---end
end

---------------------------------------------------------------------
-- @name	- StartCaptureMovie
-- @author	- Steve Bauman
-- @brief 	- Start Capturing full frame images.
---------------------------------------------------------------------
function StartMovieCapture(FPS)
	LOG('----------------Starting Movie Capture-------------------')
	import('/lua/system/Utilities.lua').UserConRequest('dump_rate ' .. (FPS * 2) )
	import('/lua/system/Utilities.lua').UserConRequest('dump_Frames on')
end

---------------------------------------------------------------------
-- @name	- EndCaptureMovie
-- @author	- Steve Bauman
-- @brief 	- End Capturing full frame images.
---------------------------------------------------------------------
function EndMovieCapture()
	LOG('----------------End Movie Capture------------------------')
	import('/lua/system/Utilities.lua').UserConRequest('dump_Frames off')
end

---------------------------------------------------------------------
-- @name	- FadeOutWhite
-- @author	- Brian Fricks
-- @brief 	- full screen fade to white that takes <time> seconds to complete.
---------------------------------------------------------------------
function FadeOutWhite(time)
	Sync.NISFadeOut = { ["seconds"] = time, ["colour"] = 'ffffffff' }
end

---------------------------------------------------------------------
-- @name	- FadeInWhite
-- @author	- Brian Fricks
-- @brief 	- full screen fade from white that takes <time> seconds to complete.
---------------------------------------------------------------------
function FadeInWhite(time)
	Sync.NISFadeIn = { ["seconds"] = time, ["colour"] = 'ffffffff' }
end

---------------------------------------------------------------------
-- @name	- FadeOut
-- @author	- Brian Fricks
-- @brief 	- full screen fade to black that takes <time> seconds to complete.
---------------------------------------------------------------------
function FadeOut(time)
	Sync.NISFadeOut = { ["seconds"] = time }
end

---------------------------------------------------------------------
-- @name	- FadeIn
-- @author	- Brian Fricks
-- @brief 	- full screen fade from black that takes <time> seconds to complete.
---------------------------------------------------------------------
function FadeIn(time)
	Sync.NISFadeIn = { ["seconds"] = time }
end

---------------------------------------------------------------------
-- @name	- DisableEaseInOut
-- @author	- Brian Fricks
-- @brief 	- standard camera command to disable ease in and out behavior.
---------------------------------------------------------------------
function DisableEaseInOut()
	if not ValidateCamera('DisableEaseInOut') then return end
	ScenarioInfo.Camera:DisableEaseInOut()
end

---------------------------------------------------------------------
-- @name	- EnableEaseInOut
-- @author	- Brian Fricks
-- @brief 	- standard camera command to enable ease in and out behavior.
---------------------------------------------------------------------
function EnableEaseInOut()
	if not ValidateCamera('EnableEaseInOut') then return end
	ScenarioInfo.Camera:EnableEaseInOut()
end

---------------------------------------------------------------------
-- @name	- UnProtectUnit
-- @author	- Brian Fricks
-- @brief 	- heavy-handy removal of all protection flags from specified <unit> (like damage, death, capture, and reclaim restrictions).
---------------------------------------------------------------------
function UnProtectUnit(unit)
	import('/lua/sim/ScenarioFramework.lua').UnProtectUnit(unit)
end

---------------------------------------------------------------------
-- @name	- UnProtectGroup
-- @author	- Brian Fricks
-- @brief 	- heavy-handy removal of all protection flags from specified <group> (like damage, death, capture, and reclaim restrictions).
---------------------------------------------------------------------
function UnProtectGroup(group)
	import('/lua/sim/ScenarioFramework.lua').UnProtectGroup(group)
end

---------------------------------------------------------------------
-- @name	- ForceUnitDeath
-- @author	- Brian Fricks
-- @brief 	- force death of specified <unit>.
---------------------------------------------------------------------
function ForceUnitDeath(unit)
	import('/lua/sim/ScenarioFramework.lua').ForceUnitDeath(unit)
end

---------------------------------------------------------------------
-- @name	- ForceGroupDeath
-- @author	- Brian Fricks
-- @brief 	- force death of specified <group>.
---------------------------------------------------------------------
function ForceGroupDeath(group)
	import('/lua/sim/ScenarioFramework.lua').ForceGroupDeath(group)
end

---------------------------------------------------------------------
-- @name	- AllowUnitDeath
-- @author	- Brian Fricks
-- @brief 	- Allow death of specified <unit>.
---------------------------------------------------------------------
function AllowUnitDeath(unit)
	import('/lua/sim/ScenarioFramework.lua').AllowUnitDeath(unit)
end

---------------------------------------------------------------------
-- @name	- AllowGroupDeath
-- @author	- Brian Fricks
-- @brief 	- Allow death of specified <group>.
---------------------------------------------------------------------
function AllowGroupDeath(group)
	import('/lua/sim/ScenarioFramework.lua').AllowGroupDeath(group)
end

---------------------------------------------------------------------
-- @name	- DestroyUnit
-- @author	- Brian Fricks
-- @brief 	- destroy specified <unit>.
---------------------------------------------------------------------
function DestroyUnit(unit)
	import('/lua/sim/ScenarioFramework.lua').DestroyUnit(unit)
end

---------------------------------------------------------------------
-- @name	- DestroyGroup
-- @author	- Brian Fricks
-- @brief 	- destroy specified <group>.
---------------------------------------------------------------------
function DestroyGroup(group)
	import('/lua/sim/ScenarioFramework.lua').DestroyGroup(group)
end

---------------------------------------------------------------------
-- @name	- EnableShadowDepthOverride
-- @author	- Brian Fricks
-- @brief 	- Custom function for showcasing optimal shadows during NISs.
---------------------------------------------------------------------
function EnableShadowDepthOverride(nDepth)
	ScenarioInfo.NISShadowDepthOverride = nDepth or 20
	LOG('EnableShadowDepthOverride: setting shadowDepthOverride to:[', ScenarioInfo.NISShadowDepthOverride, ']')

	---NOTE: this might not be safe for ship - retail valid? works without cheats enabled? - several unclear details - bfricks 12/2/09
	import('/lua/system/Utilities.lua').UserConRequest('shadowDepthOverride true ' .. ScenarioInfo.NISShadowDepthOverride)
end

---------------------------------------------------------------------
-- @name	- HideUnit
-- @author	- Brian Fricks
-- @brief 	- hide specified <unit>.
---------------------------------------------------------------------
function HideUnit(unit)
	if unit and not unit:IsDead() then
		unit:DisableShield()
		unit:SetAttackerEnabled(false)
		unit:DestroyIdleEffects()
		unit:HideMesh()
	end
end

---------------------------------------------------------------------
-- @name	- HideGroup
-- @author	- Brian Fricks
-- @brief 	- hide specified <group>.
---------------------------------------------------------------------
function HideGroup(group)
	for k, unit in group do
		HideUnit(unit)
	end
end

---------------------------------------------------------------------
-- @name	- ShowUnit
-- @author	- Brian Fricks
-- @brief 	- show specified <unit>.
---------------------------------------------------------------------
function ShowUnit(unit)
	if unit and not unit:IsDead() then
		unit:EnableShield()
		unit:SetAttackerEnabled(true)
		unit:CreateIdleEffects()
		unit:ShowMesh()
	end
end

---------------------------------------------------------------------
-- @name	- ShowGroup
-- @author	- Brian Fricks
-- @brief 	- show specified <group>.
---------------------------------------------------------------------
function ShowGroup(group)
	for k, unit in group do
		ShowUnit(unit)
	end
end

---------------------------------------------------------------------
-- @name	- WarpUnit
-- @author	- Brian Fricks
-- @brief 	- straight forward warp with comand clearing and validation
---------------------------------------------------------------------
function WarpUnit(unit, position)
	if unit and not unit:IsDead() then
		IssueClearCommands({unit})
		if type(position) == 'string' then
			position = GetPos(position)
		end
		Warp(unit,position)
	end
end

---------------------------------------------------------------------
-- @name	- WarpGroup
-- @author	- Brian Fricks
-- @brief 	- straight forward warp with comand clearing and validation
---------------------------------------------------------------------
function WarpGroup(group, position)
	for k, unit in group do
		WarpUnit(unit, position)
	end
end

---------------------------------------------------------------------
-- @name	- HideAndWarpUnit
-- @author	- Brian Fricks
-- @brief 	- hide the specfied <unit> then warp it to the desired <position>, wait 5 ticks, then reveal the unit.
--				if <position> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid position.
---------------------------------------------------------------------
function HideAndWarpUnit(unit, position)
	if unit and not unit:IsDead() then
		unit:HideMesh()

		if type(position) == 'string' then
			position = GetPos(position)
		end

		Warp(unit,position)
		WaitTicks(5)
		unit:ShowMesh()
	end
end

---------------------------------------------------------------------
-- @name	- HideAndWarpGroup
-- @author	- Brian Fricks
-- @brief 	- same as HideAndWarpUnit, but with a full group
---------------------------------------------------------------------
function HideAndWarpGroup(group, position)
	for k, unit in group do
		ForkThread(HideAndWarpUnit, unit, position)
	end
end

---------------------------------------------------------------------
-- @name	- DisableCombat
-- @author	- Brian Fricks
-- @brief	- for the duration of the NIS - turn off combat.
--
---NOTE: this function is very heavy handed - if you use it in the middle of an operation
---			it is possible to break the normal unit functionality of certain units - as designed by gameplay engineering
---			as such - it needs to be used sparingly - bfricks 10/29/09
---------------------------------------------------------------------
function DisableCombat()
	DisableAllUnitAttackers()
end

---------------------------------------------------------------------
-- @name	- PreloadDialogData
-- @author	- Brian Fricks
-- @brief	- given a list of dialog tables, preload their videos.
---------------------------------------------------------------------
function PreloadDialogData(data)
	LOG(".............Preloading MFD Movies")
	if not Sync.PreloadMFDMovie then
		Sync.PreloadMFDMovie = {}
	end

	for k, dialogTable in data do
		for i, line in dialogTable do
			if line.vid then
				LOG("...............Preloading MFD Movie: ", line.vid)
				table.insert(  Sync.PreloadMFDMovie, "/movies/" .. line.vid )
			end
		end
	end
end

---------------------------------------------------------------------
-- @name	- Dialog
-- @author	- Brian Fricks
-- @brief	- request that the specified <tableDialog> be used to start a head-in-hud sequence.
--				wait for the dialog to be complete before allowing the NIS script to proceed.
---------------------------------------------------------------------
function Dialog(tableDialog)
	local dialogComplete = false
	import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').Dialogue(
		tableDialog,
		function()
			dialogComplete = true
		end,
		true
	)

	while not dialogComplete do
		WaitTicks(1)
	end
end

---------------------------------------------------------------------
-- @name	- DialogNoWait
-- @author	- Brian Fricks
-- @brief	- request that the specified <tableDialog> be used to start a head-in-hud sequence.
--				allow the rest of the NIS script to proceed without waiting.
---------------------------------------------------------------------
function DialogNoWait(tableDialog)
	import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').Dialogue(tableDialog, nil, true)
end

---------------------------------------------------------------------
-- @name	- Sound
-- @author	- Brian Fricks
-- @brief	- request that the specified <strBank> and <strCue> be used to start a sound effect.
---------------------------------------------------------------------
function Sound(strBank,strCue)
	CreateSimSyncSound( Sound{ Bank = strBank, Cue = strCue } )
end

---------------------------------------------------------------------
-- @name	- PlayMusicEventByHandle
-- @author	- Brian Fricks
-- @brief	- using the specified <eventHandle>, find the intended music event to request.
-- 				NOTE: this system requires prior understanding of the event list in ScenarioGameMusic.lua
---------------------------------------------------------------------
function PlayMusicEventByHandle(eventHandle)
	import('/lua/sim/ScenarioFramework/ScenarioGameMusic.lua').PlayMusicEventByHandle(eventHandle)
end

---------------------------------------------------------------------
-- @name	- DisplayTitle
-- @author	- Brian Fricks
-- @brief	- request that the specified <strTitle> be used to display the operation Title.
---------------------------------------------------------------------
function DisplayTitle(strTitle)
    if(not Sync.PrintText) then
        Sync.PrintText = {}
    end

	local strText = '\"' .. LOC(strTitle) .. '\"'

	local data = {
		text = strText,
		size = 24,
		color = 'ffffffff',
		duration = 5.0,
		location = 'center'
	}

	table.insert(Sync.PrintText, data)
end

---------------------------------------------------------------------
-- @name	- DisplayLocationDate
-- @author	- Brian Fricks
-- @brief	- request that the specified <strLocation> and <strDate> be used to display the operation location and date info.
---------------------------------------------------------------------
function DisplayLocationDate(strLocation, strDate)
    if(not Sync.PrintText) then
        Sync.PrintText = {}
    end

	local strText = LOC(strLocation) .. ': ' .. LOC(strDate)

	local data = {
		text = strText,
		size = 14,
		color = 'ffffffff',
		duration = 5.0,
		location = 'leftbottom'
	}

	table.insert(Sync.PrintText, data)
end

---------------------------------------------------------------------
-- @name	- CreateArrow
-- @author	- Brian Fricks
-- @brief	- create an objective arrow at the location of the specified <marker> and if desired, offset up by <arrowHeightOverride>.
--				if <marker> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid marker object.
--				default arrow height is 2.0
--
---TODO: incorporate a system for allowing this marker to be stored and re-used by the
--			objective system AFTER the NIS. - bfricks 7/7/09
---------------------------------------------------------------------
function CreateArrow(marker, arrowHeightOverride)
	if type(marker) == 'string' then
		marker = import('/lua/sim/ScenarioUtilities.lua').GetMarker(marker)
	end

	-- adjust the arrow up a bit
	arrowHeightOverride = arrowHeightOverride or 2.0

	-- create the arrow object
	marker.Size = 4.0
	marker.position[2] = marker.position[2] + arrowHeightOverride
	local ArrowMarkerObj = import('/lua/sim/objectiveArrow.lua').ObjectiveArrow(marker)

	-- add the arrow for cleanup
	---NOTE: eventually this should handoff arrows to the objective system instead of this - bfricks 7/12/09
	AddToNISOnlyEntities(ArrowMarkerObj)

	-- return the handle to the arrow
	return ArrowMarkerObj
end

---------------------------------------------------------------------
-- @name	- CreateVizMarker
-- @author	- Brian Fricks
-- @brief	- create a vizMarkerObj at the location of the specified <marker> that allows for visibility within <nRadius>.
--				If desired, you can specify an <nOverrideDuration>, otherwise the extra visibility will persist until the end of the NIS.
--				if <marker> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a position.
---------------------------------------------------------------------
function CreateVizMarker(marker, nRadius, nOverrideDuration)
	local lifetime = nOverrideDuration or -1
	local vizMarkerObj = import('/lua/sim/ScenarioFramework.lua').CreateVisibleAreaLocation(
		nRadius,
		marker,
		lifetime,
		ArmyBrains[ScenarioInfo.ARMY_PLAYER]
	)

	-- add the marker for cleanup
	AddToNISOnlyEntities(vizMarkerObj)

	-- return the handle to the marker
	return vizMarkerObj
end

---------------------------------------------------------------------
-- @name	- Track
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to Track the specified <units>. The transition takes <transitionDur> seconds to reach the specified <zoom> distance.
--				Track will persist until another camera command is given.
--				Because track can extend beyond the scope of the NIS - it should never be the final camera command.
--				To track a single unit: {unit}
--				You can not properly track anything other than units (unlike NoseCam)
---------------------------------------------------------------------
function Track(units, zoom, transitionDur)
	if not ValidateCamera('Track') then return end

	ScenarioInfo.Camera:DisableEaseInOut()
	ScenarioInfo.Camera:TrackEntities(units, zoom, transitionDur)
end

---------------------------------------------------------------------
-- @name	- NoseCam
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to NoseCam the specified <unit>. The transition takes <transitionDur> seconds to reach the specified <zoom> distance.
--				<pitchAdjust> allows the orientation of the camera to be tilted up or down (measured in radians 3.14 = 180degrees).
--				<seconds> does not appear to be functional at this time - set it to zero.
--				<bone> allows the behavior to use a specific named or indexed bone.
---------------------------------------------------------------------
function NoseCam(unit, pitchAdjust, zoom, seconds, transitionDur, bone)
	if not ValidateCamera('NoseCam') then return end

	ScenarioInfo.Camera:DisableEaseInOut()
	ScenarioInfo.Camera:NoseCam(unit, pitchAdjust, zoom, seconds, transitionDur, bone)
end

---------------------------------------------------------------------
-- @name	- ClearTracking
-- @author	- Brian Fricks
-- @brief	- stop the camera from tracking such that we use the last position of the camera and the specified <nZoomDistance>.
--				this event will take 0.1 seconds, or the specified <nZoomDuration> seconds.
--				NOTE: this should also work to clear NoseCam - bfricks 7/12/09
---------------------------------------------------------------------
function ClearTracking(nZoomDistance, nZoomDuration)
	if not ValidateCamera('ClearTracking') then return end

	ScenarioInfo.Camera:SetZoom(nZoomDistance, nZoomDuration)
	if nZoomDuration and nZoomDuration > 0.1 then
		WaitSeconds(nZoomDuration)
	else
		WaitSeconds(0.1)
	end
end

---------------------------------------------------------------------
-- @name	- SetZoom
-- @author	- Brian Fricks
-- @brief	- use the last position of the camera and the specified <nZoomDistance>.
--				this event will take 0.1 seconds, or the specified <nZoomDuration> seconds.
---------------------------------------------------------------------
function SetZoom(nZoomDistance, nZoomDuration)
	if not ValidateCamera('SetZoom') then return end

	ScenarioInfo.Camera:SetZoom(nZoomDistance, nZoomDuration)
	if nZoomDuration and nZoomDuration > 0.1 then
		WaitSeconds(nZoomDuration)
	else
		WaitSeconds(0.1)
	end
end

---------------------------------------------------------------------
-- @name	- SetFOV
-- @author	- Brian Fricks
-- @brief	- using the current camera, set the FOV to the specified <nFOV> value over <nFOVDuration> seconds.
---------------------------------------------------------------------
function SetFOV(nFOV, nFOVDuration)
	if not ValidateCamera('SetFOV') then return end

	nFOVDuration = nFOVDuration or 0.0
	ScenarioInfo.Camera:SetAbsoluteFov(nFOV, nFOVDuration)
end

---------------------------------------------------------------------
-- @name	- UnitDeathZoomTo
-- @author	- Brian Fricks
-- @brief	- Sequence of events:
--				clear the commands of the specified <unit> (data.unit).
--				spawn a <vizRadius> at the position of the <unit> (which lasts until the end of the NIS).
--				zoom from the current camera to the postion of the <unit>
--				use the provided relative <degreesHeading>, <degreesPitch>, <nZoomToDistance>, and <nZoomToDuration>
--				kill the <unit>
--				return an entity at the same position and orientation of the <unit>
--
--	Data setup:
--	local ent = NIS.UnitDeathZoomTo(
--		{
--			unit				= <unit>,				-- unit to be killed
--			vizRadius			= <float>,				-- optional distance for a visibility marker ring
--			degreesHeading		= <-360.0 to 360.0>,	-- heading offset relative to the unit (180.0 == frontside)
--			degreesPitch		= <-360.0 to 360.0>,	-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
--			nZoomToDistance		= <float>,				-- how close to zoom-in relative to the unit
--			nZoomToDuration		= <float>,				-- how long to allow the zoom-in to take
--			nOffsetX			= <float>,				-- if specified, offset in the X direction
--			nOffsetY			= <float>,				-- if specified, offset in the Y direction
--			nOffsetZ			= <float>,				-- if specified, offset in the Z direction
--		}
--	)
---------------------------------------------------------------------
function UnitDeathZoomTo(data)
	if not ValidateCamera('UnitDeathZoomTo') then return end

	-- unwrap data into the various local variables
	local unit			= data.unit
	local vizRadius		= data.vizRadius

	-- validate required data
	if not unit then WARN('WARNING: NIS FAILURE: UnitDeathZoomTo called with invalid data.unit!') return end

	-- generate required data using the unit
	local position		= unit:GetPosition()
	local orientation	= unit:GetOrientation()

	-- stop the unit
	IssueClearCommands({unit})

	-- spawn the vizMarker if required
	if vizRadius and vizRadius > 0.0 then
		CreateVizMarker(position, vizRadius)
	end

	-- zoom in
	data.ent = unit
	EntityZoomToRelative(data)

	-- spawn an entity at the location and orientation of the unit
	local ent = import('/lua/sim/Entity.lua').Entity()
	Warp(ent,position)
	ent:SetOrientation(orientation, true)

	-- force kill the unit
	ForceUnitDeath(unit)

	-- return the handle to the entity
	return ent
end

---------------------------------------------------------------------
-- @name	- UnitDeathTrack
-- @author	- Brian Fricks
-- @brief	- Sequence of events:
--				spawn a <vizRadius> at the position of the <unit> (which lasts until the end of the NIS).
--				cut to a camera view of the <unit> generated
--				use the provided relative <degreesHeading>, <degreesPitch>, and <nTrackDistance>
--				track the <unit> for the <nMinTrackDuration>
--				kill the <unit>
--				if the <unit> is an air unit, continue to track until it hits the ground
--				return an entity at the same position and orientation of the <unit>
--
--	Data setup:
--	local ent = NIS.UnitDeathTrack(
--		{
--			unit				= <unit>,				-- unit to be killed
--			vizRadius			= <float>,				-- optional distance for a visibility marker ring
--			degreesHeading		= <-360.0 to 360.0>,	-- heading offset relative to the unit (180.0 == frontside)
--			degreesPitch		= <-360.0 to 360.0>,	-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
--			nTrackDistance		= <float>,				-- how close to track relative to the unit
--			nMinTrackDuration	= <float>,				-- how long to allow the track to persist, before killing the unit
--			nOffsetX			= <float>,				-- if specified, offset in the X direction
--			nOffsetY			= <float>,				-- if specified, offset in the Y direction
--			nOffsetZ			= <float>,				-- if specified, offset in the Z direction
--		}
--	)
---------------------------------------------------------------------
function UnitDeathTrack(data)
	if not ValidateCamera('UnitDeathTrack') then return end

	-- unwrap data into the various local variables
	local unit				= data.unit
	local vizRadius			= data.vizRadius
	local nTrackDistance	= data.nTrackDistance or 0.0
	local nMinTrackDuration	= data.nMinTrackDuration or 0.0

	-- validate required data
	if not unit then WARN('WARNING: NIS FAILURE: UnitDeathZoomTo called with invalid data.unit!') return end

	-- generate required data using the unit
	local position		= unit:GetPosition()
	local orientation	= unit:GetOrientation()

	-- spawn the vizMarker if required
	if vizRadius and vizRadius > 0.0 then
		CreateVizMarker(position, vizRadius)
	end

	-- cut to the camera view, and track the unit for nMinTrackDuration seconds
	data.ent = unit
	EntityTrackRelative(data)

	-- track for at least the 0.1 seconds
	if nMinTrackDuration > 0.0 then
		WaitSeconds(nMinTrackDuration)
	else
		WaitSeconds(0.1)
	end

	-- force kill the unit
	ForceUnitDeath(unit)

	-- extend the tracking for air units, until they hit the ground or the safety time has elapsed
	local safetyTickCnt = 0
	local safetyTickMax = 100
	local bIsAirUnit = false
	if EntityCategoryContains( categories.AIR, data.unit ) and data.unit:GetCurrentLayer() == 'Air' then
		-- flag that we are dealing with an air unit
		bIsAirUnit = true

		-- flag that the camera is tracking the falling air unit
		ScenarioInfo.Camera.TrackingFallingAirUnit = true

		-- wait for the unit to hit the ground before ending the Track
		data.unit.Callbacks.OnLayerChange:Add(
			function()
				-- because of the safetyTickMax, we don't automatically assume that the value of this global needs to be set false
				--	there is a rare case where two units could be tracked back-to-back.
				if ScenarioInfo.Camera.TrackingFallingAirUnit then
					ScenarioInfo.Camera.TrackingFallingAirUnit = false
				end
			end
		)

		-- now wait for the the callback to get called
		while ScenarioInfo.Camera.TrackingFallingAirUnit do
			safetyTickCnt = safetyTickCnt + 1
			if safetyTickCnt > safetyTickMax then
				ScenarioInfo.Camera.TrackingFallingAirUnit = false
				break
			else
				WaitTicks(1)
			end
		end
	end

	-- clear tracking
	ClearTracking(nTrackDistance,  0.0)

	-- if required and possible, update position and orientation for the crashed air unit
	if unit and bIsAirUnit then
		position	= unit:GetPosition()
		orientation	= unit:GetOrientation()
	end

	-- spawn an entity at the location and orientation of the unit
	local ent = import('/lua/sim/Entity.lua').Entity()
	Warp(ent,position)
	ent:SetOrientation(orientation, true)

	-- add the entity for cleanup
	AddToNISOnlyEntities(ent)

	-- return the handle to the entity
	return ent
end

---------------------------------------------------------------------
-- @name	- EntityZoomToRelative
-- @author	- Brian Fricks
-- @brief	- zoom from the current camera to the postion of the <ent>
--				use the provided relative <degreesHeading>, <degreesPitch>, <nZoomToDistance>, and <nZoomToDuration>
--
--	Data setup:
--	NIS.EntityZoomToRelative(
--		{
--			ent					= <entity or unit>,		-- a handle to the in-game object being used as the center of the zoom
--			degreesHeading		= <-360.0 to 360.0>,	-- heading offset relative to the unit (180.0 == frontside)
--			degreesPitch		= <-360.0 to 360.0>,	-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
--			nZoomToDistance		= <float>,				-- how close to zoom-in relative to the unit
--			nZoomToDuration		= <float>,				-- how long to allow the zoom-in to take
--			nOffsetX			= <float>,				-- if specified, offset in the X direction
--			nOffsetY			= <float>,				-- if specified, offset in the Y direction
--			nOffsetZ			= <float>,				-- if specified, offset in the Z direction
--		}
--	)
---------------------------------------------------------------------
function EntityZoomToRelative(data)
	if not ValidateCamera('EntityZoomToRelative') then return end

	-- unwrap data into the various local variables
	local ent				= data.ent
	local degreesHeading	= data.degreesHeading or 0.0
	local degreesPitch		= data.degreesPitch or 0.0
	local nZoomToDistance	= data.nZoomToDistance or 0.0
	local nZoomToDuration	= data.nZoomToDuration or 0.0
	local nOffsetX			= data.nOffsetX or 0.0
	local nOffsetY			= data.nOffsetY or 0.0
	local nOffsetZ			= data.nOffsetZ or 0.0

	-- validate required data
	if not ent then WARN('WARNING: NIS FAILURE: EntityZoomToRelative called with invalid data.ent!') return end

	-- generate required data using the ent
	local heading	= (degreesHeading * 3.14 / 180.0) + ent:GetHeading()
	local pitch		= (degreesPitch * 3.14 / 180.0)
	local pos		= ent:GetPosition()
	local hpr		= {heading, pitch, 0.0,}

	-- if required, adjust position with the offsets
	if nOffsetX > 0.0 or nOffsetY > 0.0 or nOffsetZ > 0.0 then
		-- adjust the position
		pos[1] = pos[1] + nOffsetX
		pos[2] = pos[2] + nOffsetY
		pos[3] = pos[3] + nOffsetZ
	end

	-- using the provided position and interpreted orientation hpr and zoom info, zoom the camera
	ZoomTo(pos, hpr, nZoomToDistance, nZoomToDuration)
end

---------------------------------------------------------------------
-- @name	- EntityTrackRelative
-- @author	- Brian Fricks
-- @brief	- for <nTrackToDuration> seconds, track to a camera view of the <ent> generated
--				use the provided relative <degreesHeading>, <degreesPitch>, and <nTrackDistance>
--				once there, remain tracking until told otherwise.
--
--	Data setup:
--	NIS.EntityTrackRelative(
--		{
--			ent					= <entity or unit>,		-- a handle to the in-game object being used as the center of the zoom
--			degreesHeading		= <-360.0 to 360.0>,	-- heading offset relative to the unit (180.0 == frontside)
--			degreesPitch		= <-360.0 to 360.0>,	-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
--			nTrackDistance		= <float>,				-- how close to track relative to the unit
--			nTrackToDuration	= <float>,				-- how long to take to get in position for the track (usually 0.0 for this sort of thing)
--			nOffsetX			= <float>,				-- if specified, offset in the X direction
--			nOffsetY			= <float>,				-- if specified, offset in the Y direction
--			nOffsetZ			= <float>,				-- if specified, offset in the Z direction
--		}
--	)
---------------------------------------------------------------------
function EntityTrackRelative(data)
	if not ValidateCamera('EntityTrackRelative') then return end

	-- unwrap data into the various local variables
	local ent				= data.ent
	local degreesHeading	= data.degreesHeading or 0.0
	local degreesPitch		= data.degreesPitch or 0.0
	local nTrackDistance	= data.nTrackDistance or 0.0
	local nTrackToDuration	= data.nTrackToDuration or 0.0
	local nOffsetX			= data.nOffsetX or 0.0
	local nOffsetY			= data.nOffsetY or 0.0
	local nOffsetZ			= data.nOffsetZ or 0.0

	-- validate required data
	if not ent then WARN('WARNING: NIS FAILURE: EntityTrackRelative called with invalid data.ent!') return end

	-- generate required data using the ent
	local heading	= (degreesHeading * 3.14 / 180.0) + ent:GetHeading()
	local pitch		= (degreesPitch * 3.14 / 180.0)
	local pos		= ent:GetPosition()
	local hpr		= {heading, pitch, 0.0,}

	-- if required, adjust position and ent with the offsets
	if nOffsetX > 0.0 or nOffsetY > 0.0 or nOffsetZ > 0.0 then
		-- adjust the position
		pos[1] = pos[1] + nOffsetX
		pos[2] = pos[2] + nOffsetY
		pos[3] = pos[3] + nOffsetZ

		-- if the provided entity is a unit, we need to attach to it, otherwise just warp it to the new pos
		if IsUnit(ent) then
			-- create a new entity
			local newEnt = import('/lua/sim/Entity.lua').Entity()

			-- now for the fun part, slap the new ent onto the old ent
			newEnt:AttachTo(data.ent, -1)
			newEnt:SetParentOffset(Vector(nOffsetX,nOffsetY,nOffsetZ))

			-- add the entity for cleanup
			AddToNISOnlyEntities(newEnt)

			-- and finally set the value of ent
			ent = newEnt

			-- wait a tick - so the offset can take effect
			WaitTicks(1)
		else
			Warp(ent, pos)
		end
	end

	-- using the provided position and interpreted orientation hpr and zoom info, zoom the camera
	---NOTE: using the noWait because we need an actual 0.0 duration zoom - possibly this should be a snap - review. - bfricks 7/13/09
	ZoomToNoWait(pos, hpr, nTrackDistance, 0.0)

	-- now begin tracking
	Track({ent}, nTrackDistance, nTrackToDuration)
end

---------------------------------------------------------------------
-- @name	- EntitySpinRelative
-- @author	- Brian Fricks
-- @brief	- cut to a camera view of the <ent> generated
--				use the provided relative <degreesHeading>, <degreesPitch>, and <nSpinDistance>
--				then spin at the specified <nSpinRate> for <nSpinDuration> seconds.
--
--	Data setup:
--	NIS.EntitySpinRelative(
--		{
--			ent					= <entity or unit>,		-- a handle to the in-game object being used as the center of the zoom
--			degreesHeading		= <-360.0 to 360.0>,	-- heading offset relative to the unit (180.0 == frontside)
--			degreesPitch		= <-360.0 to 360.0>,	-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
--			nSpinRate			= <float>,				-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
--			nSpinDistance		= <float>,				-- how close to spin relative to the unit
--			nSpinDuration		= <float>,				-- how long to allow the spin to persist
--			nOffsetX			= <float>,				-- if specified, offset in the X direction
--			nOffsetY			= <float>,				-- if specified, offset in the Y direction
--			nOffsetZ			= <float>,				-- if specified, offset in the Z direction
--		}
--	)
---------------------------------------------------------------------
function EntitySpinRelative(data)
	if not ValidateCamera('EntitySpinRelative') then return end

	-- unwrap data into the various local variables
	local ent				= data.ent
	local degreesHeading	= data.degreesHeading or 0.0
	local degreesPitch		= data.degreesPitch or 0.0
	local nSpinRate			= data.nSpinRate or 0.0
	local nSpinDistance		= data.nSpinDistance or 0.0
	local nSpinDuration		= data.nSpinDuration or 0.0
	local nOffsetX			= data.nOffsetX or 0.0
	local nOffsetY			= data.nOffsetY or 0.0
	local nOffsetZ			= data.nOffsetZ or 0.0

	-- validate required data
	if not ent then WARN('WARNING: NIS FAILURE: EntityTrackRelative called with invalid data.ent!') return end

	-- generate required data using the ent
	local heading	= (degreesHeading * 3.14 / 180.0) + ent:GetHeading()
	local pitch		= (degreesPitch * 3.14 / 180.0)
	local pos		= ent:GetPosition()
	local hpr		= {heading, pitch, 0.0,}

	-- if required, adjust position and ent with the offsets
	if nOffsetX > 0.0 or nOffsetY > 0.0 or nOffsetZ > 0.0 then
		-- adjust the position
		pos[1] = pos[1] + nOffsetX
		pos[2] = pos[2] + nOffsetY
		pos[3] = pos[3] + nOffsetZ
	end

	-- using the provided position and interpreted orientation hpr and zoom info, zoom the camera
	---NOTE: using the noWait because we need an actual 0.0 duration zoom - possibly this should be a snap - review. - bfricks 7/13/09
	ZoomToNoWait(pos, hpr, nSpinDistance, 0.0)
	WaitTicks(1)

	-- now begin spinning
	Spin(nSpinRate, nSpinDuration)
end

-------------------------------------------------------------------
-- @name	- Spin
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to Spin the specified <nSpinRate> for the specified <nSpinDuration> seconds.
--				wait for the Spin to be complete before allowing the NIS script to proceed.
--				the focal point of the spin will be whatever the camera is already using as a target position.
--				NOTE: nSpinRate is rotations per minute - so you will little numbers like 0.01 for a slow spin
---------------------------------------------------------------------
function Spin(nSpinRate, nSpinDuration)
	if not ValidateCamera('Spin') then return end

	local nSpinRate		= nSpinRate or 0.01
	local nSpinDuration	= nSpinDuration or 1.0

	-- now begin spinning
	ScenarioInfo.Camera:Spin(nSpinRate,0.0)

	-- continue to spin for the specified duration
	WaitSeconds(nSpinDuration)

	-- clear the spinning
	if ScenarioInfo.Camera then
		ScenarioInfo.Camera:Spin(0.0,0.0)
	else
		WARN('WARNING: A camera Spin command is resolving after NIS completion - if the camera appears wierd - bug this for Campaign Design.')
	end
end

-------------------------------------------------------------------
-- @name	- MoveTo
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to MoveTo the specified <dest> over <transitionDur> seconds.
--				wait for the MoveTo to be complete before allowing the NIS script to proceed.
--				if <dest> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid marker object.
---------------------------------------------------------------------
function MoveTo(dest, transitionDur)
	if not ValidateCamera('MoveTo') then return end

	MoveToNoWait(dest, transitionDur)
    if transitionDur and transitionDur > 0.1 then
        -- Wait for it to be done
    	WaitSeconds(transitionDur)
    else
    	WaitTicks(1)
    end
end

---------------------------------------------------------------------
-- @name	- MoveToNoWait
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to MoveTo the specified <dest> over <transitionDur> seconds.
--				allow the rest of the NIS script to proceed without waiting.
--				if <dest> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid marker object.
---------------------------------------------------------------------
function MoveToNoWait(dest, transitionDur)
	if not ValidateCamera('MoveToNoWait') then return end

	-- allow the user to simply pass in a marker name
	if type(dest) == 'string' then
		dest = import('/lua/sim/ScenarioUtilities.lua').GetMarker(dest)
	end

	-- early out with bad required data
	if not dest then				WARN('WARNING: NIS FAILURE: MoveTo called with invalid dest!') return end
	if not dest.position then		WARN('WARNING: NIS FAILURE: MoveTo called with invalid dest.position!') return end
	if not dest.orientation then	WARN('WARNING: NIS FAILURE: MoveTo called with invalid dest.orientation!') return end

	-- adjust incomplete data, if needed
	dest.zoom = dest.zoom or 0.0

	-- set transitionDur to zero if not already specified
	transitionDur = transitionDur or 0.0

	-- instruct the camera to snap
	ScenarioInfo.Camera:MoveToMarker(dest,transitionDur)
end

---------------------------------------------------------------------
-- @name	- ZoomTo
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to ZoomTo the composite destination of <destPos> <destOrient> and <nZoomDist> over <transitionDur> seconds.
--				wait for the ZoomTo to be complete before allowing the NIS script to proceed.
--				<destPos> must be a position.
--				<destOrient> must be an orientation.
--
--				A typical method for using this function will be:
--					ZoomTo(GetPos('CAM_OPENING'), GetOrient('CAM_OPENING'), 50.0, 4.0)
--					In that example, we are using a placed marker of the name 'CAM_OPENING', and telling the system to move to 50.0 zoom units away from
--					the position over a duration of 4.0 seconds.
--
--				By splitting up the position and orientation we allow ourselves to create precise camera movements using different positions, but the same camera angle.
--				Also - we can use a unit position instead of a marker, and allow for more easiliy editable NIS sequences.
---------------------------------------------------------------------
function ZoomTo(destPos, destOrient, nZoomDist, transitionDur)
	if not ValidateCamera('ZoomTo') then return end

	ZoomToNoWait(destPos, destOrient, nZoomDist, transitionDur)
    if transitionDur and transitionDur > 0.1 then
        -- Wait for it to be done
    	WaitSeconds(transitionDur)
    else
    	WaitTicks(1)
    end
end

---------------------------------------------------------------------
-- @name	- ZoomToNoWait
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to ZoomTo the composite destination of <destPos> <destOrient> and <nZoomDist> over <transitionDur> seconds.
--				allow the rest of the NIS script to proceed without waiting.
--				if <dest> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid marker object.
---------------------------------------------------------------------
function ZoomToNoWait(destPos, destOrient, nZoomDist, transitionDur)
	if not ValidateCamera('ZoomToNoWait') then return end

	-- early out with bad required data
	if not destPos then				WARN('WARNING: NIS FAILURE: ZoomTo called with invalid destPos!') return end
	if not destOrient then			WARN('WARNING: NIS FAILURE: ZoomTo called with invalid destOrient!') return end

	-- construct data table
	local dest = {}
	dest.position = destPos
	dest.orientation = destOrient
	dest.zoom = nZoomDist or 0.0

	-- set transitionDur to zero if not already specified
	transitionDur = transitionDur or 0.0

	-- instruct the camera to move
	ScenarioInfo.Camera:MoveToMarker(dest,transitionDur)
end

---------------------------------------------------------------------
-- @name	- SnapTo
-- @author	- Brian Fricks
-- @brief	- Change camera behavior to SnapTo the specified <dest> immediately.
--				if <dest> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid marker object.
---------------------------------------------------------------------
function SnapTo(dest)
	if not ValidateCamera('SnapTo') then return end

	-- allow the user to simply pass in a marker name
	if type(dest) == 'string' then
		dest = import('/lua/sim/ScenarioUtilities.lua').GetMarker(dest)
	end

	-- early out with bad required data
	if not dest then				WARN('WARNING: NIS FAILURE: SnapTo called with invalid dest!') return end
	if not dest.position then		WARN('WARNING: NIS FAILURE: SnapTo called with invalid dest.position!') return end
	if not dest.orientation then	WARN('WARNING: NIS FAILURE: SnapTo called with invalid dest.orientation!') return end

	-- adjust incomplete data, if needed
	dest.zoom = dest.zoom or 0.0

	-- instruct the camera to snap
	ScenarioInfo.Camera:SnapToMarker(dest)
end

---------------------------------------------------------------------
-- @name	- StartNIS_Standard
-- @author	- Brian Fricks
-- @brief	- Handle all things required for launching a standard NIS.
--				if specified, <nStartFOV> will be used to establish a starting FOV
---------------------------------------------------------------------
function StartNIS_Standard(nStartFOV, bBlackBars, bLockInput)

	if bBlackBars == nil	then bBlackBars = true	end
	if bLockInput == nil	then bLockInput = true	end

	NIS_Queue.AddStartNIS(
		{
			fnc = function()
			-- ###############################################
			-- Actual StartNIS_Standard functionality goes here. -balfieri 10/01/09

				StartCameraSequence(bBlackBars, bLockInput, nStartFOV)
			-- ###############################################
			end,

			-- ###############################################
			-- Actual StartNIS_Standard parameters go here
				params = { nStartFOV }
			-- ###############################################
		}
	)
end

---------------------------------------------------------------------
-- @name	- StartNIS_Victory
-- @author	- Brian Fricks
-- @brief	- Handle all things required for launching a victory NIS.
--				if specified, <nStartFOV> will be used to establish a starting FOV
---------------------------------------------------------------------
function StartNIS_Victory(nStartFOV, bBlackBars, bLockInput)

	if bBlackBars == nil	then bBlackBars = true	end
	if bLockInput == nil	then bLockInput = true	end

	NIS_Queue.AddStartNIS(
		{
			fnc = function()
			-- ###############################################
			-- Actual StartNIS_Victory functionality goes here. -balfieri 10/01/09

				StartCameraSequence(bBlackBars, bLockInput, nStartFOV)

				DisableCombat()
			-- ###############################################
			end,

			-- ###############################################
			-- Actual StartNIS_Standard parameters go here
				params = { nStartFOV }
			-- ###############################################
		}
	)
end

---------------------------------------------------------------------
-- @name	- StartNIS_Opening
-- @author	- Brian Fricks
-- @brief	- Handle all things required for launching an operation opening NIS.
--				<strOrientCam> is the name of the camera marker used for the starting framed shot of each operation.
--				<nOpeningZoom> is the zoom distance out from the <strOrientCam>.
--				the position of the camera will always begin with the player CDR unit.
--				if specified, <OverridePos> will be used instead of the position of the CDR.
--				if <OverridePos> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid position.
--				if specified, <nStartFOV> will be used to establish a starting FOV
---------------------------------------------------------------------
function StartNIS_Opening(strOrientCam, nOpeningZoom, OverridePos, nStartFOV, bBlackBars, bLockInput)

	if bBlackBars == nil	then bBlackBars = true	end
	if bLockInput == nil	then bLockInput = true	end

	-- ***Clear the NIS queue***
	NIS_Queue.ClearAll()

	NIS_Queue.AddStartNIS(
		{
			fnc	= function()
			-- ###############################################
			-- Actual StartNIS_Opening functionality goes here. -balfieri 10/01/09
				StartCameraSequence(bBlackBars, bLockInput, nStartFOV)

				local pos		= GetPos(ScenarioInfo.PLAYER_CDR)
				local orient	= GetOrient(strOrientCam)
				local zoom		= nOpeningZoom or 300.0

				-- set the position using the OverridePos
				if OverridePos then
					if type(OverridePos) == 'string' then
						pos = GetPos(OverridePos)
					else
						pos = OverridePos
					end
				end

				-- set starting shot, then fade in
				ZoomTo(pos, orient, zoom, 0.0)

				FadeIn(3.0)
			-- ###############################################
			end,

			-- ###############################################
			-- Actual StartNIS_Opening parameters go here
				params = { strOrientCam, nOpeningZoom, OverridePos, nStartFOV }
			-- ###############################################
		}
	)
end

---------------------------------------------------------------------
-- @name	- StartNIS_MidOp
-- @author	- Brian Fricks
-- @brief	- Handle all things required for launching a mid Op NIS.
--				<strNewArea> is the optional name of the new area we are expanding to.
--				<nOverrideMinZoom> will force the NIS to use a zoom out that goes at least as far out as requested.
--				if no nOverrideMinZoom is specified, the system will use 600.0 as a default.
--				if specified, <nStartFOV> will be used to establish a starting FOV
---------------------------------------------------------------------
function StartNIS_MidOp(strNewArea, nOverrideMinZoom, nStartFOV, bBlackBars, bLockInput)

	if bBlackBars == nil	then bBlackBars = true	end
	if bLockInput == nil	then bLockInput = true	end

	NIS_Queue.AddStartNIS(
		{
			fnc = function()
			-- ###############################################
			-- Actual StartNIS_MidOp functionality goes here. -balfieri 10/01/09
				if strNewArea then
					import('/lua/sim/ScenarioFramework.lua').SetPlayableArea(strNewArea, false)
				end

				StartCameraSequence(bBlackBars, bLockInput, nStartFOV)
			-- ###############################################
			end,

			-- ###############################################
			-- Actual StartNIS_MidOp parameters go here
				params = {strNewArea, nOverrideMinZoom, nStartFOV}
			-- ###############################################
		}
	)
end

---------------------------------------------------------------------
-- @name	- EndNIS_NoRestore
-- @author	- Brian Fricks
-- @brief	- Handle all things required for ending a no restore style NIS.
--				in this format - we are using the last set camera period - no changes.
--				<bFlushIntel> will force the NIS to flush intel for the entire map.
---------------------------------------------------------------------
function EndNIS_NoRestore(bFlushIntel, nRestoreDurration)
	if not ValidateCamera('EndNIS_NoRestore') then return end

	-- set bBlackBars == true, bRestoreInput == true, bUseCDRPos == false, bNoRestore == true, bFlushIntel == bFlushIntel
	EndCameraSequence(true, true, false, true, bFlushIntel, nil, nRestoreDurration)

	NIS_Queue.RemoveNIS()
end

---------------------------------------------------------------------
-- @name	- EndNIS_Standard
-- @author	- Brian Fricks
-- @brief	- Handle all things required for ending a standard NIS.
--				<bFlushIntel> will force the NIS to flush intel for the entire map.
--				<nOverrideZoom> will force the NIS to end with the specified zoom distance.
--				if no OverrideZoom is specified, the system will use the zoom of the player's last
--				saved camera (from before the NIS started), but constrained within a ceiling of 200 units.
---------------------------------------------------------------------
function EndNIS_Standard(nOverrideZoom, bFlushIntel, nRestoreDurration)
	if not ValidateCamera('EndNIS_Standard') then return end

	-- set bBlackBars == true, bRestoreInput == true, bUseCDRPos == false, bNoRestore == false, bFlushIntel == bFlushIntel
	EndCameraSequence(true, true, false, false, bFlushIntel, nOverrideZoom, nRestoreDurration)

	NIS_Queue.RemoveNIS()
end

---------------------------------------------------------------------
-- @name	- EndNIS_Opening
-- @author	- Brian Fricks
-- @brief	- Handle all things required for ending an operation opening NIS.
--				<bFlushIntel> will force the NIS to flush intel for the entire map.
--				<nOverrideZoom> will force the NIS to end with the specified zoom distance.
--				if no OverrideZoom is specified, the system will use the zoom of the player's last
--				saved camera (from before the NIS started), but constrained within a ceiling of 200 units.
---------------------------------------------------------------------
function EndNIS_Opening(nOverrideZoom, bFlushIntel, nRestoreDurration)
	if not ValidateCamera('EndNIS_Opening') then return end

	-- force bFlushIntel to be true for any case except where we manually need it to be false
	if bFlushIntel != false then
		bFlushIntel = true
	end

	-- set bBlackBars == true, bRestoreInput == true, bUseCDRPos == true, bNoRestore == false, bFlushIntel == bFlushIntel
	EndCameraSequence(true, false, true, false, bFlushIntel, nOverrideZoom, nRestoreDurration)

	-- record the game time, for score tracking
	ScenarioInfo.CampaignOpeningEndTime = GetGameTick() * 0.1
	LOG('TIME TRACKING: EndNIS_Opening: ScenarioInfo.CampaignOpeningEndTime:[', ScenarioInfo.CampaignOpeningEndTime, ']' )

	NIS_Queue.RemoveNIS()
end

---------------------------------------------------------------------
-- @name	- EndNIS_MidOp
-- @author	- Brian Fricks
-- @brief	- Handle all things required for ending a midOp NIS.
--				<bFlushIntel> will force the NIS to flush intel for the entire map.
---------------------------------------------------------------------
function EndNIS_MidOp(bFlushIntel, nRestoreDurration)
	if not ValidateCamera('EndNIS_MidOp') then return end

---NOTE: commenting out special handling - we no longer want a smooth transition at all - just do a full restore - bfrcisk 9/30/09
---	local minZoom = nOverrideMinZoom or 600.0
---
---	---AdjustZoom = function(self,nMinZoomFloor,nMaxZoomCeiling,seconds,bUseSaved)
---	ScenarioInfo.Camera:AdjustZoom(minZoom, nil, 1.0, true)
---	WaitSeconds(2.0)

	-- set bBlackBars == true, bRestoreInput == true, bUseCDRPos == false, bNoRestore == false, bFlushIntel == bFlushIntel
	EndCameraSequence(true, true, false, false, bFlushIntel, nRestoreDurration)

	NIS_Queue.RemoveNIS()
end

---------------------------------------------------------------------
-- @name	- EndNIS_Victory
-- @author	- Brian Fricks
-- @brief	- Handle all things required for ending a map victory NIS.
--				<tableDialog> if specified, is the final dialog to call before checking if we have an optional ending
--				<bAllowOptionalEnding> indicates if the operation is designed to allow for continued play or not
---------------------------------------------------------------------
function EndNIS_Victory(tableDialog, bAllowOptionalEnding)
	if not ValidateCamera('EndNIS_Victory') then return end

	if tableDialog then
		import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').FlushDialogueQueue(true)
		import('/lua/sim/ScenarioFramework/ScenarioDialogue.lua').Dialogue(
			tableDialog,
			function()
				---TODO: get this functional - bfricks 7/5/09
				if bAllowOptionalEnding then
					LOG('EndNIS_Victory: flagged to allow for optional ending, but that support is not yet functional')
				end

				import('/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua').Victory()
			end,
			true
		)
	else
		import('/lua/sim/ScenarioFramework/ScenarioGameCleanup.lua').Victory()
	end

	NIS_Queue.RemoveNIS()
end

---------------------------------------------------------------------
-- @name	- TransportArrival
-- @author	- Brian Fricks
-- @brief	- Manage the transport arrival behavior for a single transport and group (both the transport and group must already exist).
--				To use this function you need to construct a data table with the following information:
--
--	Data setup:
--	NIS.TransportArrival(
--		{
--			armyName				= <strArmyName>,	-- name of the army for whom the transport and group are being created
--			units					= <str/group>,		-- if a string, group name of units to be spawned as platoon, otherwise the units to be added to storage
--			transport				= <str/unit>,		-- if a string, the name of transport unit to create, otherwise the actual
--			approachChain			= <chain> or nil,	-- optional chainName for the approach travel route
--			unloadDest				= <marker>,			-- destination for the transport drop-off
--			returnDest				= <marker> or nil,	-- optional destination for where the transports will fly-away
--			bSkipTransportCleanup	= true or false,	-- will this transport be deleted when near returnDest?
--			platoonMoveDest			= <marker> or nil,	-- optional destination for the group to be moved to after being dropped-off
--			OnCreateCallback		= <func> or nil,	-- optional function to call for the transport and spawned platoon after they are created
--			onUnloadCallback		= <func> or nil,	-- optional function to call when the transport finishes unloading
--			bUnSelectAfterNIS		= true or false,	-- will this transport be unselectable after the NIS?
--		}
--	)
---------------------------------------------------------------------
function TransportArrival(data, bSkip)
	-- force the units into existence right away - NISs need these for proper cleanup tracking
	if data.units and type(data.units) == 'string' then
		data.units = import('/lua/sim/ScenarioUtilities.lua').CreateArmyGroup(data.armyName, data.units)
		NISAddToProtectedUnitList(data.units)
	end

	-- force the transport into existence right away - for proper cleanup tracking
	if data.transport and type(data.transport) == 'string' then
		data.transport = import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit(data.armyName, data.transport)
		NISAddToProtectedUnitList({data.transport})
	end

	if not bSkip then
		-- make sure the transport movement is set to the needed value for our NIS timing
		local currSpeed = data.transport:GetBlueprint().Air.MaxAirspeed
		local destSpeed = 15.0
		local multSpeed = destSpeed/currSpeed

		if multSpeed != 1.0 then
			-- create a place on the unit for tracking scenario data
			if not data.transport.ScenarioUnitData then
				data.transport.ScenarioUnitData = {}
			end

			-- store the fact that we are modified
			data.transport.ScenarioUnitData.TransportSpeedAdjusted = true

			-- modify the speeds
			data.transport:SetSpeedMult(multSpeed)
			data.transport:SetNavMaxSpeedMultiplier(multSpeed)

			LOG('NIS: TransportArrival: adjusting speed of transport: currSpeed:[', currSpeed, '] multSpeed:[', multSpeed, ']')
		end
	end

	-- transport
	import('/lua/sim/ScenarioFramework/ScenarioGameUtilsTransport.lua').SpawnTransportDeployGroup(data, bSkip)

	if data.bUnSelectAfterNIS then
		-- add the transport for cleanup
		AddToNISOnlyTransports(data.transport, data.units, data.unloadDest, data.returnDest)
	end
end

---------------------------------------------------------------------
-- @name	- NukePosition
-- @author	- Brian Fricks
-- @brief	- create a nuke at the specified <position>, with the specified <nRandomRange>.
--				if <position> is a string, the function assumes you are giving it a marker name.
--				otherwise, the function assumes you are giving it a valid position.
---------------------------------------------------------------------
function NukePosition(position, nRandomRange)
	import('/lua/sim/ScenarioFramework/ScenarioGameEvents.lua').NukePosition(position, nRandomRange)
end


---------------------------------------------------------------------
-- @name	- FakeBuild
-- @author	- Brian Fricks
-- @brief	- instruct <mobileBuilder> to fake build the <unitNameToFake> at its location as placed in LED.
-- 				<armyName> needs to be the string name of the army - e.g. 'ARMY_PLAYER'
--				<armyIndex> needs to be the integer method for the army - e.g. ScenarioInfo.ARMY_PLAYER
--				<delayBeforeCleanup> allows us to wait for a period of time before cleaning up the fake built unit.
--				We will auto-create the specified <groupNameToSpawn> after cleaning up.
--
--				<bSkip> id used to advance through the building when skipping NISs
--
--				NOTE: if the builder is still attached to a transport - this function will not try and build
--					so it is important that NIS developers call this after landing
---------------------------------------------------------------------
function FakeBuild(mobileBuilder, armyName, armyIndex, unitNameToFake, groupNameToSpawn, delayBeforeCleanup, bSkip)
	if bSkip then
		local group = import('/lua/sim/ScenarioUtilities.lua').CreateArmyGroup(armyName, groupNameToSpawn)
		return group
	end

	local cleanupUnit = nil

	-- only try to build if the builder is valid, alive, and un-attached
	if mobileBuilder and not mobileBuilder:IsDead() and not mobileBuilder:IsUnitState('Attached') then
		-- clear commands in case the unit is busy
		IssueClearCommands({mobileBuilder})

		-- start the fake building
		local unitData = import('/lua/sim/ScenarioUtilities.lua').FindUnit(unitNameToFake, Scenario.Armies[armyName].Units)
		ArmyBrains[armyIndex]:BuildStructure(mobileBuilder, unitData.type, { unitData.Position[1], unitData.Position[3], 0}, false)
		mobileBuilder.Callbacks.OnStartBuild:Add(
			function(builderUnit, unitBeingBuilt)
				if unitBeingBuilt then
					cleanupUnit = unitBeingBuilt
				end
			end
		)
	else
		error('ERROR: FakeBuild failed due to one of the following cases: invalid builder, dead builder, or builder attached to a transport - this needs to go to Campaign Design.')
	end

	-- wait for the delay period
	WaitSeconds(delayBeforeCleanup)
	if cleanupUnit then
		cleanupUnit:Destroy()
	end

	-- repeat clear commands in case there is any lingering building going on
	if mobileBuilder and not mobileBuilder:IsDead() and not mobileBuilder:IsUnitState('Attached') then
		IssueClearCommands({mobileBuilder})
	end

	-- wait a tick
	WaitTicks(1)

	-- spawn and NIS protect the group
	local group = import('/lua/sim/ScenarioUtilities.lua').CreateArmyGroup(armyName, groupNameToSpawn)
	NISAddToProtectedUnitList(group)

	-- return the group in case someone needs it
	return group
end

---------------------------------------------------------------------
-- @name	- FakeBuildNoWait
-- @author	- Brian Fricks
-- @brief	- call FakeBuild on a forked thread
---------------------------------------------------------------------
function FakeBuildNoWait(mobileBuilder, armyName, armyIndex, unitNameToFake, groupNameToSpawn, delayBeforeCleanup, bSkip)
	ForkThread(FakeBuild, mobileBuilder, armyName, armyIndex, unitNameToFake, groupNameToSpawn, delayBeforeCleanup, bSkip)
end

---------------------------------------------------------------------
-- @name	- RandomNIS
-- @author	- Brian Fricks
-- @brief	- select a generic NIS using the specified <targetEnt> and <dialog>.
---------------------------------------------------------------------
function RandomNIS(targetEnt,dialog)
	local num = import('/lua/system/utilities.lua').GetRandomInt(1,3)

	if num == 1 then
		GenericNIS01(targetEnt,dialog)
	elseif num == 2 then
		GenericNIS02(targetEnt,dialog)
	else
		GenericNIS03(targetEnt,dialog)
	end
end

---------------------------------------------------------------------
-- @name	- GenericNIS01
-- @author	- Brian Fricks
-- @brief	- perform a full on custom NIS using the specified <targetEnt> and <dialog>.
---------------------------------------------------------------------
function GenericNIS01(targetEnt,dialog)
	-- use the standard NIS start
	StartNIS_Standard()

	if dialog then
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('GenericNIS01:', repr(dialog))
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		DialogNoWait(dialog)
	end

	EntityZoomToRelative(
		{
			ent					= targetEnt,	-- unit to be killed
			vizRadius			= 300,			-- optional distance for a visibility marker ring
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 60.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 250.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 0.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)

	WaitSeconds(2.0)

	EntitySpinRelative(
		{
			ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 60.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nSpinRate			= 0.001,		-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
			nSpinDistance		= 250.0,		-- how close to spin relative to the unit
			nSpinDuration		= 5.0,			-- how long to allow the spin to persist
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 0.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)
end

---------------------------------------------------------------------
-- @name	- GenericNIS02
-- @author	- Brian Fricks
-- @brief	- perform a full on custom NIS using the specified <targetEnt> and <dialog>.
---------------------------------------------------------------------
function GenericNIS02(targetEnt,dialog)
	-- use the standard NIS start
	StartNIS_Standard()

	if dialog then
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('GenericNIS02:', repr(dialog))
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		DialogNoWait(dialog)
	end

	EntityZoomToRelative(
		{
			ent					= targetEnt,	-- unit to be killed
			vizRadius			= 300,			-- optional distance for a visibility marker ring
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 30.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 200.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 0.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)

	WaitSeconds(2.0)

	EntitySpinRelative(
		{
			ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 30.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nSpinRate			= 0.01,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
			nSpinDistance		= 200.0,		-- how close to spin relative to the unit
			nSpinDuration		= 5.0,			-- how long to allow the spin to persist
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 0.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)
end

---------------------------------------------------------------------
-- @name	- GenericNIS03
-- @author	- Brian Fricks
-- @brief	- perform a full on custom NIS using the specified <targetEnt> and <dialog>.
---------------------------------------------------------------------
function GenericNIS03(targetEnt,dialog)
	-- use the standard NIS start
	StartNIS_Standard()

	if dialog then
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('GenericNIS03:', repr(dialog))
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		LOG('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		DialogNoWait(dialog)
	end

	EntityZoomToRelative(
		{
			ent					= targetEnt,	-- unit to be killed
			vizRadius			= 300,			-- optional distance for a visibility marker ring
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 80.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nZoomToDistance		= 250.0,		-- how close to zoom-in relative to the unit
			nZoomToDuration		= 0.0,			-- how long to allow the zoom-in to take
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 0.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)

	WaitSeconds(2.0)

	EntitySpinRelative(
		{
			ent					= targetEnt,	-- a handle to the in-game object being used as the center of the zoom
			degreesHeading		= 180.0,		-- heading offset relative to the unit (180.0 == frontside)
			degreesPitch		= 80.0,			-- up and down tilt of the camera (90.0 == topdown, 0.0 == horizontal
			nSpinRate			= 0.01,			-- rotations per second (typically we would want slow spins like 0.01 to 0.05)
			nSpinDistance		= 250.0,		-- how close to spin relative to the unit
			nSpinDuration		= 5.0,			-- how long to allow the spin to persist
			nOffsetX			= 0.0,			-- if specified, offset in the X direction
			nOffsetY			= 0.0,			-- if specified, offset in the Y direction
			nOffsetZ			= 0.0,			-- if specified, offset in the Z direction
		}
	)
end

---------------------------------------------------------------------
-- @name			- AddFade
-- @author			- Bret Alfieri
-- @brief 			- Performs a camera fade in and/or out concurrently with
--					- another camera behavior.
-- @param[in] data	- A table. See Data setup.
--
-- @details			-
--
-- Data setup:
--	NIS.AddFade(
--		{
--			nFadeIn 		= <float>,		-- Number of seconds to fade in.
--			nFadeOut	 	= <float>,		-- Number of seconds to fade out.
--			sColor			= <string>,		-- Hex color (as string) for fade color. (white: 'ffffffff', black: 'ff000000')
--			nShotDurration 	= <float>,		-- Length of the shot in seconds.
--			fcnCamBehavior 	= <fuction>,	-- The function that controls the camera behavior.
--			tblParams 		= <table>		-- The table of the parameters need for the behavior function.
--		}
--	)
--
-- EXAMPLE:
-- 	NIS.ZoomTo(GetPos('NIS_MIDOP_CAM_SHOT_8_01'), GetOrient('NIS_MIDOP_CAM_SHOT_8_01'), 0.0, 0.0)
-- 	NIS.AddFade(
-- 		{
-- 			nFadeIn 		= 1.0,			-- Number of seconds to fade in.
-- 			nFadeOut	 	= 0.0,			-- Number of seconds to fade out.
-- 			sColor			= 'ffffffff',	-- Hex color (as string) for fade color.
-- 			nShotDurration 	= 6.0,			-- Length of the shot in seconds.
-- 			fcnCamBehavior 	= NIS.ZoomTo,	-- The function that controls the camera behavior.
-- 			tblParams 		= {GetPos('NIS_MIDOP_CAM_SHOT_8_02'), GetOrient('NIS_MIDOP_CAM_SHOT_8_02'), 0.0, 6.0}		-- The table of the parameters need for the behavior function.
-- 		}
-- 	)
---------------------------------------------------------------------
function AddFade(data)
	if data.fcnCamBehavior then
		-- Process fades concurrently with camera behavior
		ForkThread(
			function()
				-- If the user doesn't specify a fade in time, then don't fade in
				if data.nFadeIn > 0.0 then
					Sync.NISFadeIn = { ["seconds"] = data.nFadeIn, ["colour"] = data.sColor }
				end

				local waitTime = data.nShotDurration - (data.nFadeIn + data.nFadeOut)
				WaitSeconds(waitTime)

				-- If the user doesn't specify a fade out time, then don't fade out
				if data.nFadeOut > 0.0 then
					Sync.NISFadeOut = { ["seconds"] = data.nFadeOut, ["colour"] = data.sColor }
				end
			end
		)
		data.fcnCamBehavior(unpack(data.tblParams))
	else
		WARN('AddFade: NO CAMERA BEHAVIOR!')
	end	-- end if

end

---------------------------------------------------------------------
-- @name			- DPStoRPS
-- @author			- Bret Alfieri
-- @brief 			- Converts degrees per second to revolutions per second.
-- @param[in] nDeg	- Number of degrees to rotate through.
-- @param[in] nSec	- Duration of rotation.
-- @return			- none.
---------------------------------------------------------------------
function DPStoRPS(nDeg, nSec)
	return (nDeg / nSec) / 360.0
end

---------------------------------------------------------------------
-- @name			- UnitoEnt
-- @author			- Bret Alfieri
-- @brief 			- Creates an entity from a unit.
-- @param[in] unit	- Unit to make into entity.
-- @return			- An entity.
---------------------------------------------------------------------
function UnitToEnt(unit)
	position	= unit:GetPosition()
	orientation	= unit:GetOrientation()

	local ent = import('/lua/sim/Entity.lua').Entity()
	Warp(ent,position)
	ent:SetOrientation(orientation, true)

	AddToNISOnlyEntities(ent)

	return ent
end

---------------------------------------------------------------------
-- @name			- UnitDeathToEnt
-- @author			- Bret Alfieri
-- @brief 			- Destroys a unit and returns an entity generated from the unit.
-- @param[in] unit	- Unit to destroy.
-- @return			- An entity.
---------------------------------------------------------------------
function UnitDeathToEnt(unit)
	position	= unit:GetPosition()
	orientation	= unit:GetOrientation()

	local ent = import('/lua/sim/Entity.lua').Entity()
	Warp(ent,position)
	ent:SetOrientation(orientation, true)

	AddToNISOnlyEntities(ent)

	ForceUnitDeath(unit)

	return ent
end

---------------------------------------------------------------------
-- @name					- CreateNISOnlyEntity
-- @author					- Bret Alfieri
-- @brief 					- Creates a generic entity at the specified position with
--					  	  	  the specified orientation.
-- @param[in] position		- New entities position.
-- @param[in] orientation	- New entities orientation.
-- @return					- An entity.
---------------------------------------------------------------------
function CreateNISOnlyEntity(position, orientation)
	local ent = import('/lua/sim/Entity.lua').Entity()
	Warp(ent,position)

	if orientation then
		ent:SetOrientation(orientation, true)
	end

	AddToNISOnlyEntities(ent)

	return ent
end

---------------------------------------------------------------------
-- @name					- CreateNISOnlyUnit
-- @author					- Brian Fricks
-- @brief 					- Create a unit that will be tracked for deletion and protection.
-- @param[in] strArmy		- name of the army for the unit to create.
-- @param[in] strUnit		- name of the group as placed in LED.
-- @return					- a unit.
---------------------------------------------------------------------
function CreateNISOnlyUnit(strArmy, strUnit)
	local unit = import('/lua/sim/ScenarioUtilities.lua').CreateArmyUnit(strArmy, strUnit)

	AddToNISOnlyEntities(unit)

	NISAddToProtectedUnitList({unit})

	return unit
end

---------------------------------------------------------------------
-- @name					- CreateNISOnlyUnit
-- @author					- Brian Fricks
-- @brief 					- Create a group of unit thats will be tracked for deletion and protection.
-- @param[in] strArmy		- name of the army for the group to create.
-- @param[in] strGroup		- name of the group as placed in LED.
-- @return					- a group.
---------------------------------------------------------------------
function CreateNISOnlyGroup(strArmy, strGroup)
	local group = import('/lua/sim/ScenarioUtilities.lua').CreateArmyGroup(strArmy, strGroup)

	for k, unit in group do
		AddToNISOnlyEntities(unit)
	end

	NISAddToProtectedUnitList(group)

	return group
end

---------------------------------------------------------------------
-- @name					- CreateNISOnlyEntity
-- @author					- Bret Alfieri
-- @brief 					- Creates a generic entity at the specified position with
--					  	  	  the specified orientation.
-- @param[in] position		- New entities position.
-- @param[in] orientation	- New entities orientation.
-- @return					- An entity.
---------------------------------------------------------------------
function CreateNISOnlyEntity(position, orientation)
	local ent = import('/lua/sim/Entity.lua').Entity()
	Warp(ent,position)

	if orientation then
		ent:SetOrientation(orientation, true)
	end

	AddToNISOnlyEntities(ent)

	return ent
end

---------------------------------------------------------------------
-- @name					- GroupMoveChain
-- @author					- Brian Fricks
-- @brief 					- Have units move for each point in the specified chain.
-- @param[in] group			- List of units to be given the move commands.
-- @param[in] chain			- string name of a marker chain to use.
-- @return					- An entity.
---------------------------------------------------------------------
function GroupMoveChain( group, chain )
    for k,v in import('/lua/sim/ScenarioUtilities.lua').ChainToPositions(chain) do
       	IssueMove( group, v )
    end
end

---------------------------------------------------------------------
-- @name					- CreateNISOnlyFX
-- @author					- Brian Fricks
-- @brief 					- Create an effect emitter at a location.
-- @param[in] strEffectBP	- str name of the effect blueprint to use.
-- @param[in] pos			- position where the effect should be created.
---------------------------------------------------------------------
function CreateNISOnlyFX(strEffectBP, pos)
	local ent = import('/lua/sim/Entity.lua').Entity()
	Warp(ent,pos)

	CreateEmitterOnEntity( ent, 1, strEffectBP ):SetEmitterParam('LODCutoff', 9001)
	AddToNISOnlyEntities(ent)
end

---------------------------------------------------------------------
-- @name					- UnHunker
-- @author					- Steve Bauman
-- @brief 					- Un hunker a passed-in unit
-- @param[in] strEffectBP	- unit name
---------------------------------------------------------------------
function UnHunker(unit)
	local platoon = ArmyBrains[ScenarioInfo.ARMY_PLAYER]:MakePlatoon('', '')
	ArmyBrains[ScenarioInfo.ARMY_PLAYER]:AssignUnitsToPlatoon( platoon, {unit}, 'Attack', 'AttackFormation' )
	platoon:ToggleAbility("acu_hunker", false)
end
