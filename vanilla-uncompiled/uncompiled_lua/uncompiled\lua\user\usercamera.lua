--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--
-- UserCamera
--
-- Provides direct control over a specific game camera. Also listens to request from the Sim and manipulates
-- the cameras as instructed.
--
local lastSavedCamera = {}

function ProcessCameraRequests()
    for k,v in Sync.CameraRequests do
        if v.Exec then
            local cam = GetCamera(v.Name)
            if v.Params then
                cam[v.Exec](cam, unpack(v.Params))
            else
                cam[v.Exec](cam)
            end
		elseif v.Type == 'CAMERA_DEFAULT_INIT' then
			ForkThread(UserDefaultCameraInit, v)
        elseif v.Type == 'CAMERA_MOVE' then
            ForkThread(WaitForCamera, v)
        elseif v.Type == 'CAMERA_TRACK_ENTITIES' then
            ForkThread(WaitForCamera,v)
        elseif v.Type == 'CAMERA_NOSE_CAM' then
            ForkThread(WaitForCamera,v)
        elseif v.Type == 'CAMERA_SET_ACC_MODE' then
            ForkThread(WaitForCamera,v)
        elseif v.Type == 'CAMERA_SET_ZOOM' then
            ForkThread(WaitForCamera,v)
        elseif v.Type == 'CAMERA_ADJUST_ZOOM' then
            ForkThread(WaitForCamera,v)
        elseif v.Type == 'CAMERA_ADJUST_ORIENT' then
            ForkThread(WaitForCamera,v)
        elseif v.Type == 'CAMERA_SET_ABSOLUTE_FOV' then
            ForkThread(WaitForCamera,v)
        elseif v.Type == 'CAMERA_SYNC_PLAYABLE_RECT' then
            SyncPlayableRect(v.Region)
            local miniMapCam = GetCamera('MiniMap')
            if miniMapCam then
                miniMapCam:Reset()
            end
        elseif v.Type == 'CAMERA_SNAP' then
            local position = v.Marker.position
            local hpr = v.Marker.orientation
            local zoom = v.Marker.zoom
			local fov = v.Marker.fov
            GetCamera(v.Name):SnapTo(position, hpr, zoom, fov)
        elseif v.Type == 'CAMERA_SPIN' then
            GetCamera(v.Name):Spin(v.HeadingRate, v.ZoomRate or 0)
        elseif v.Type == 'CAMERA_UNIT_SPIN' then
            local cam = GetCamera(v.Name)
            cam:SnapTo( v.Marker.position, v.Marker.orientation, v.Marker.zoom, v.Marker.fov)
            cam:Spin(v.HeadingRate)
        elseif v.Type == 'CAMERA_USE_ABSOLUTE_COORDS' then
            local cam = GetCamera(v.Name)
            cam:UseAbsoluteCoords(v.Use)
        elseif v.Type == 'CAMERA_USE_ABSOLUTE_FOV' then
            local cam = GetCamera(v.Name)
            cam:UseAbsoluteFOV(v.Use)
        elseif v.Type == 'CAMERA_UPDATE_DEFAULTS' then
			local CameraDefaults = import('/lua/system/CameraDefaults.lua')
			CameraDefaults.UpdateCurrentCameraDefaults( v.Data )
		elseif v.Type == 'CAMERA_REVERT_TO_DEFAULT' then
			ForkThread(WaitForCamera,v)
		elseif v.Type == 'CAMERA_SAVE_SETTINGS' then
            lastSavedCamera = GetCamera(v.Name):SaveSettings()
		elseif v.Type == 'CAMERA_RESTORE_LAST_SAVED_SETTINGS' then
			ForkThread(WaitForCamera,v)
        else
            error("Unknown Camera Request type specified.")
        end
    end
end

function UserDefaultCameraInit(req)
    if req.Time > 0 then
        WaitSeconds(req.Time)
    end
	local avatars = GetArmyAvatars()
	UIZoomTo(avatars, 2)
	WaitSeconds(1)
	SelectUnits(avatars)
end

function WaitForCamera(req)
    local cam = GetCamera(req.Name)

    if req.Type == 'CAMERA_TRACK_ENTITIES' then
        cam:TrackEntities(req.Ents,req.Zoom,req.Time)
    elseif req.Type == 'CAMERA_NOSE_CAM' then
        cam:NoseCam(req.Entity, req.PitchAdjust, req.Zoom, req.Time, req.Transition, req.Bone)
    elseif req.Type == 'CAMERA_SET_ACC_MODE' then
        cam:SetAccMode(req.Data)
    elseif req.Type == 'CAMERA_SET_ZOOM' then
        cam:SetZoom(req.Zoom, req.Time)
    elseif req.Type == 'CAMERA_ADJUST_ZOOM' then
		local settings = cam:SaveSettings()
		local position = req.UseSaved and lastSavedCamera.Focus or settings.Focus
		local hpr = {settings.Heading,settings.Pitch,0.0,}
		local time = req.Time or 0.0
		local zoom = req.UseSaved and lastSavedCamera.Zoom or settings.Zoom

		-- test the zoom relative to our provided min and max threshholds
		if req.MinZoomFloor and zoom < req.MinZoomFloor then
			zoom = req.MinZoomFloor
		elseif req.MaxZoomCeiling and zoom > req.MaxZoomCeiling then
			zoom = req.MaxZoomCeiling
		end

		-- MoveTo using the constructed data
		cam:MoveTo(position,hpr,zoom,time)
    elseif req.Type == 'CAMERA_ADJUST_ORIENT' then
		local settings = cam:SaveSettings()
		local position = req.UseSaved and lastSavedCamera.Focus or settings.Focus
		local heading = req.UseSaved and lastSavedCamera.Heading or (req.Heading or settings.Heading)
		local pitch = req.UseSaved and lastSavedCamera.Pitch or (req.Pitch or settings.Pitch)
		local hpr = {heading,pitch,0.0,}
		local time = req.Time or 0.0
		local zoom = settings.Zoom
		local fov = req.Fov

		-- MoveTo using the constructed data
		cam:MoveTo(position,hpr,zoom,time, fov)
    elseif req.Type == 'CAMERA_SET_ABSOLUTE_FOV' then
        cam:SetAbsoluteFOV(req.Fov, req.Time)
    elseif req.Type == 'CAMERA_MOVE' then
        -- Move to specified marker
        if req.Marker then
            local position = req.Marker.position
            local hpr = req.Marker.orientation
            local zoom = req.Marker.zoom
			local fov = req.Marker.fov
            cam:MoveTo(position,hpr,zoom,req.Time,fov)
        -- Move to specified region (make region visible)
        elseif req.Region then
            cam:MoveToRegion(req.Region,req.Time)
        else
            error("Invalid move request: " .. repr(req))
            SimCallback(req.Callback)
            return
        end
    elseif req.Type == 'CAMERA_REVERT_TO_DEFAULT' then
		cam:RevertToDefault( req.Time, req.Zoom, req.File, req.Tble )
    elseif req.Type == 'CAMERA_RESTORE_LAST_SAVED_SETTINGS' then
    	-- extract data from the request (when an override is needed) or from the lastSavedCamera
		local position = req.Position or lastSavedCamera.Focus
		local hpr = {lastSavedCamera.Heading,lastSavedCamera.Pitch,0.0,}
		local zoom = req.Zoom or lastSavedCamera.Zoom
		local time = req.Time or 0.0
		local fov = req.Fov

    	-- MoveTo the last saved camera orientation - but allow for the position and zoom to be modified if needed
    	-- also, allow this process to take time - as specfied, or snap otherwise
		cam:MoveTo(position,hpr,zoom,time,fov)

		-- clear the lastSavedCamera
		lastSavedCamera = {}
    else
        error("Invalid camera request: " .. repr(req))
        SimCallback(req.Callback)
        return
    end

    if req.Time > 0 then
        WaitFor(cam)
        SimCallback(req.Callback)
    end
end