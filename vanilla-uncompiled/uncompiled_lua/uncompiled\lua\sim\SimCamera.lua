--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--
-- SimCamera
--
-- SimCamera buffers control requests to push to the user layer at sync time. It provides facilities
-- for waiting on the camera to perform certain actions. At the moment, the facilities that wait can
-- not be used in multiplayer and are considered to finish immediately when running the simulation in
-- a headless mode. Thus the primary use for such features is in the single player campaign. We have
-- a plan to add multiplayer and headless support for these features but it may be some time before
-- this gets implemented.
--
-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

SingleEvent = import('/lua/system/SingleEvent.lua').SingleEvent

-- Name / Object table for cameras
Cameras = {}

-- The user layer calls this via SimCallback when the camera finishes moving to its target.
function OnCameraFinish(name)
    --LOG('Signal')
    Cameras[name]:EventSet()
end

SimCamera = Class(SingleEvent) {
    __init = function(self,name)
        self.CameraName = name
        self.Callback = {
            Func = "OnCameraFinish",
            Args = name,
        }
        Cameras[name] = self
    end,

    ScaleMoveVelocity = function(self,val)
        WARN('ScaleMoveVelocity is defunct. Please remove.')
    end,

    MoveTo = function(self,rectRegion,seconds,fov)
        --LOG('Camera:MoveTo ', repr(rectRegion), ' ',seconds)
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_MOVE',
            Region = rectRegion,
            Time = seconds or 0,
            Callback = self.Callback,
			Fov = fov,
        }
        CreateSimSyncCameraRequest( request )
    end,

    MoveToMarker = function(self,marker,seconds)
        --LOG('Camera:MoveToMarker ', repr(marker.type), ' ',seconds)
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_MOVE',
            Marker = marker,
            Time = seconds or 0,
            Callback = self.Callback,
        }
        CreateSimSyncCameraRequest( request )
    end,

    ZoomToAvatar = function(self,seconds)
        --LOG('Camera:ZoomToAvatar ',seconds)
        local request = {
            Type = 'CAMERA_DEFAULT_INIT',
            Time = seconds or 0,
        }
        CreateSimSyncCameraRequest( request )
    end,

    SyncPlayableRect = function(self,rectRegion)
        LOG('Camera:SyncPlayableRect ', repr(rectRegion))
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_SYNC_PLAYABLE_RECT',
            Region = rectRegion,
        }
        LOG('Request: ',repr(request))
        CreateSimSyncCameraRequest( request )
    end,

    SnapToMarker = function(self,marker)
        --LOG('Camera:SnapToMarker('..repr(marker.type)..')')
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_SNAP',
            Marker = marker,
        }
        CreateSimSyncCameraRequest( request )
    end,

    TrackEntities = function(self, units, zoom, seconds)
        --LOG('Camera:TrackEntities')
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_TRACK_ENTITIES',
            Ents = {},
            Time = seconds or 0,
            Zoom = zoom,
            Callback = self.Callback
        }
        for k,v in units do
            for k,v in units do
				-- By default, let's assume we want to use the sim-side entity id.
				local unitId = v:GetEntityId()

				-- If we're not the focus army, then we need to get the the recon blip id,
				-- otherwise the user side will be unable to find the entity and do anything with it.
				if v:GetAIBrain() and v:GetAIBrain():GetArmyIndex() != GetFocusArmy() then
					local entBlip = v:GetBlip( GetFocusArmy() )
					if entBlip then
						unitId = entBlip:GetEntityId()
					else
						WARN( 'Tried to track an entity of a non-focus army, but no recon blip exists.  Tracking request will not succeed. EntId: ' .. v:GetEntityId() )
					end
				end

				table.insert( request.Ents, unitId )
			end
        end
        CreateSimSyncCameraRequest( request )
    end,

    NoseCam = function(self, ent, pitchAdjust, zoom, seconds, transition, bone)
        --LOG('Camera:NoseCam')
        local idNum = false
        if ent:GetAIBrain() and ent:GetAIBrain():GetArmyIndex() ~= ArmyBrains[1]:GetArmyIndex() then
            local entBlip = ent:GetBlip(1)
            if entBlip then
                idNum = entBlip:GetEntityId()
            end
        else
            idNum = ent:GetEntityId()
        end
        if idNum then
            local request = {
                Name = self.CameraName,
                Type = 'CAMERA_NOSE_CAM',
                Entity = idNum,
                PitchAdjust = pitchAdjust,
                Time = seconds or 0,
                Transition = transition or 0,
                Zoom = zoom,
                Callback = self.Callback,
                Bone = bone,
            }
            CreateSimSyncCameraRequest( request )
        else
            error( '*CAMERA ERROR: Nose Cam not given valid unit or unit does not have a blip', 2 )
        end
    end,

    SetAccMode = function(self,accModeName)
        --LOG('Camera:SetAccMode')
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_SET_ACC_MODE',
            Data = accModeName,
            Callback = self.Callback
        }
        CreateSimSyncCameraRequest( request )
    end,

    SetZoom = function(self,zoom,seconds)
        --LOG('Camera:SetZoom')
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_SET_ZOOM',
            Zoom = zoom,
            Time = seconds or 0,
            Callback = self.Callback
        }
        CreateSimSyncCameraRequest( request )
    end,

    AdjustOrient = function(self,heading,pitch,seconds,bUseSaved,fov)
        --LOG('Camera:AdjustOrient')
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_ADJUST_ORIENT',
            Heading = heading,
            Pitch = pitch,
            UseSaved = bUseSaved or false,
            Time = seconds or 0,
            Callback = self.Callback,
			Fov = fov
        }
        CreateSimSyncCameraRequest( request )
    end,

    AdjustZoom = function(self,nMinZoomFloor,nMaxZoomCeiling,seconds,bUseSaved)
        --LOG('Camera:AdjustZoom')
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_ADJUST_ZOOM',
            MinZoomFloor = nMinZoomFloor,
            MaxZoomCeiling = nMaxZoomCeiling,
            UseSaved = bUseSaved or false,
            Time = seconds or 0,
            Callback = self.Callback
        }
        CreateSimSyncCameraRequest( request )
    end,

	SetAbsoluteFov = function(self,fov,seconds)
		--LOG('Camera:SetAbsoluteFov')
		local request = {
			Name = self.CameraName,
			Type = 'CAMERA_SET_ABSOLUTE_FOV',
			Fov = fov,
			Time = seconds or 0,
			Callback = self.Callback
		}
		CreateSimSyncCameraRequest( request )
	end,

	UseAbsoluteCoords = function(self,use)
		--LOG('Camera:UseAbsoluteCoords')
		local request = {
			Name = self.CameraName,
			Type = 'CAMERA_USE_ABSOLUTE_COORDS',
			Use = use,
			Callback = self.Callback
		}
		CreateSimSyncCameraRequest( request )
	end,

	UseAbsoluteFov = function(self,use)
		--LOG('Camera:UseAbsoluteFov')
		local request = {
			Name = self.CameraName,
			Type = 'CAMERA_USE_ABSOLUTE_FOV',
			Use = use,
			Callback = self.Callback
		}
		CreateSimSyncCameraRequest( request )
	end,

    SpinAroundUnit = function(self, location, unitHeading, headingRate )
        local marker = {
            orientation = VECTOR3( unitHeading, .35, 0 ),
            position = location,
            zoom = FLOAT( 75 ),
        }
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_UNIT_SPIN',
            Marker = marker,
            HeadingRate = headingRate,
            Callback = self.Callback
        }
        CreateSimSyncCameraRequest( request )
    end,

    Spin = function(self,headingRate,zoomRate)
        local request = {
            Name = self.CameraName,
            Type = 'CAMERA_SPIN',
            HeadingRate = headingRate,
            ZoomRate = zoomRate,
        }
        CreateSimSyncCameraRequest( request )
    end,

    HoldRotation = function(self)
        --LOG('Camera:HoldRotation')
        CreateSimSyncCameraRequest( { Name = self.CameraName, Exec = 'HoldRotation' } )
    end,

    RevertRotation = function(self)
        --LOG('Camera:RevertRotation')
        CreateSimSyncCameraRequest( { Name = self.CameraName, Exec = 'RevertRotation' } )
    end,

    UseGameClock = function(self)
        --LOG('Camera:UseGameClock')
        CreateSimSyncCameraRequest( { Name = self.CameraName, Exec = 'UseGameClock' } )
    end,

    UseSystemClock = function(self)
        --LOG('Camera:UseSystemClock')
        CreateSimSyncCameraRequest( { Name = self.CameraName, Exec = 'UseSystemClock' } )
    end,

    EnableEaseInOut = function(self)
        --LOG('Camera:EnableEaseInOut')
        CreateSimSyncCameraRequest( { Name = self.CameraName, Exec = 'EnableEaseInOut' } )
    end,

    DisableEaseInOut = function(self)
        --LOG('Camera:DisableEaseInOut')
        CreateSimSyncCameraRequest( { Name = self.CameraName, Exec = 'DisableEaseInOut' } )
    end,

    Reset = function(self)
        --LOG('Camera:Reset')
        CreateSimSyncCameraRequest( { Name = self.CameraName, Exec='Reset'} )
    end,

    UpdateDefaults = function( self, data )
		--LOG('Camera:UpdateDefaults')
		local request = {
            Name = self.CameraName,
            Type = 'CAMERA_UPDATE_DEFAULTS',
            Data = data,
        }

		---NOTE: adding ScenarioInfo data storing so we can manage save/load of updated defaults
		---			this is NOT the best idea - but covers things for ship - bfricks 1/30/10
		ScenarioInfo.UpdatedCameraDefaults = data

        CreateSimSyncCameraRequest( request )
	end,

	RevertToDefault = function( self, time, zoom, file, tble )
		--LOG('Camera:RevertToDefault')
		local request = {
			Name = self.CameraName,
			Type = 'CAMERA_REVERT_TO_DEFAULT',
			Time = time or 0.0,
			Zoom = zoom or -1,
			File = file or '/lua/system/CameraDefaults.lua',
			Tble = tble or 'CurrentCameraDefaults',
			Callback = self.Callback,
		}
		CreateSimSyncCameraRequest( request )
	end,

    SaveSettings = function(self)
		--LOG('Camera:SaveSettings')
		local request = {
            Name = self.CameraName,
            Type = 'CAMERA_SAVE_SETTINGS',
        }
        CreateSimSyncCameraRequest( request )
	end,

    RestoreSettings = function(self, position, zoom, duration, fov)
		--LOG('Camera:RestoreSettings')
		local request = {
            Name = self.CameraName,
            Type = 'CAMERA_RESTORE_LAST_SAVED_SETTINGS',
            Position = position,
			Time = duration,
			Zoom = zoom,
			Callback = self.Callback,
			Fov = fov,
        }
        CreateSimSyncCameraRequest( request )
	end,
}