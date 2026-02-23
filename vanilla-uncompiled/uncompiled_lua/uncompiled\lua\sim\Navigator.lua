--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--*****************************************************************************
--* File: lua/sim/Navigator.lua
--*
--* Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

NAVSTATUS = {
    Idle = 0,
    Thinking = 1,
    Steering = 2,
}

Navigator = Class(moho.navigator_methods) {
    
    -- NATIVE METHODS 
    --[[
    -- Set the navigator's destination as a particular position
    SetGoal(vector)

    -- Set the navigator's destination as another unit (chase/follow)
    SetDestUnit(Entity *unit)

    -- Abort the current move and put the navigator back to an idle state
    AbortMove()

    -- Broadcast event to resume any listening task that is currently suspended
    BroadcastResumeTaskEvent()

    -- Set flag in navigator so the unit will know whether to stop at final goal 
    -- or speed through it. This would be set to True during a patrol or a series 
    -- of waypoints in a complex path.
    SetSpeedThroughGoal(bool flag)

    -- This returns the current navigator target position for the unit.
    vector GetCurrentTargetPos()

    -- This returns the current goal position of our navigator
    vector GetGoalPos()

    -- Get the status of the navigator in terms of reaching the destination
    NAVSTATUS GetStatus()
    bool HasGoodPath()
    bool FollowingLeader()
    
    IgnoreFormation(bool flag)
    bool IsIgnorningFormation()
    
    bool AtGoal()
    bool CanPathToGoal(vector)
    
    --]]
}
