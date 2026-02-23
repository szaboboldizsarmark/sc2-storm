---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
local ScenarioUtils		= import('/lua/sim/ScenarioUtilities.lua')
local SimCamera			= import('/lua/sim/simcamera.lua').SimCamera

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function EnterNISMode()
    ScenarioInfo.Camera = SimCamera('WorldCamera')
    LockInput()
    ScenarioInfo.Camera:UseGameClock()
    Sync.NISMode = 'on'
    ScenarioInfo.OpNISActive = true

    for index,brain in ArmyBrains do
		brain:OnEnterNIS()
	end
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function CameraFadeOut( time, colour, clearOnFinish )
    Sync.NISFadeOut = { ["seconds"] = time, ["colour"] = colour, ["clearOnFinish"] = clearOnFinish }
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function CameraFadeIn( time, colour )
    Sync.NISFadeIn = { ["seconds"] = time, ["colour"] = colour }
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function ExitNISMode(keepCamera)
	ScenarioInfo.OpNISActive = false
	Sync.NISMode = 'off'
	ScenarioInfo.Camera:UseSystemClock()
	UnlockInput()
	ScenarioInfo.Camera = nil

	for index,brain in ArmyBrains do
		brain:OnExitNIS()
	end
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function CameraMoveToMarker( marker, seconds )

    -- Adding this in case we just want to start the camera
    -- somewhere at the beginning of an operation without
    -- playing a full NIS
    if not ScenarioInfo.Camera then
        ScenarioInfo.Camera = SimCamera('WorldCamera')
    end

    if type(marker) == 'string' then
        local actualmarker = ScenarioUtils.GetMarker(marker)
		if not actualmarker then
			error("CameraMoveToMarker: Couldn't find marker ", marker)
			return
		end
		marker = actualmarker
    end

    -- Move the camera
    ScenarioInfo.Camera:MoveToMarker( marker, seconds )

    if ( seconds ) and ( seconds != 0 ) then
        -- Wait for it to be done
        WaitForCamera()
    end
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function CameraTrackEntity( entity, zoom, seconds )
    CameraTrackEntities({entity}, zoom, seconds)
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function CameraTrackEntities( units, zoom, seconds )
    local army = GetFocusArmy()
    for i,v in units do
        if army ~= v:GetArmy() then
            units[i] = v:GetBlip(army)
        end
    end

    -- Watch the entities
    ScenarioInfo.Camera:TrackEntities( units, zoom, seconds )

    -- Keep it from pitching up all the way
    ScenarioInfo.Camera:HoldRotation()

    if ( seconds ) and ( seconds != 0 ) then
        -- Wait for it to be done
        WaitForCamera()
    end
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function WaitForCamera()
    -- Wait for it to be done
    ScenarioInfo.Camera:WaitFor()

    -- Reset the event tracker, so that the next
    -- camera action can be waited for
    ScenarioInfo.Camera:EventReset()
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function DisableEaseInOut()
	-- early out with bad required data
	if not ScenarioInfo.Camera then	error('DisableEaseInOut caled with invalid ScenarioInfo.Camera!') return end
	ScenarioInfo.Camera:DisableEaseInOut()
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function EnableEaseInOut()
	-- early out with bad required data
	if not ScenarioInfo.Camera then	error('EnableEaseInOut caled with invalid ScenarioInfo.Camera!') return end
	ScenarioInfo.Camera:EnableEaseInOut()
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function SetAccLinear()
	-- early out with bad required data
	if not ScenarioInfo.Camera then	error('SetAccLinear caled with invalid ScenarioInfo.Camera!') return end
	ScenarioInfo.Camera:SetAccMode('Linear')
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function SetAccFastInSlowOut()
	-- early out with bad required data
	if not ScenarioInfo.Camera then	error('SetAccFastInSlowOut caled with invalid ScenarioInfo.Camera!') return end
	ScenarioInfo.Camera:SetAccMode('FastInSlowOut')
end

---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
function SetAccSlowInOut()
	-- early out with bad required data
	if not ScenarioInfo.Camera then	error('SetAccSlowInOut caled with invalid ScenarioInfo.Camera!') return end
	ScenarioInfo.Camera:SetAccMode('SlowInOut')
end
