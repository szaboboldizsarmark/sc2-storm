-- Class methods
-- Destroy()
-- control GetParent()
-- ClearChildren()
-- SetParent(control)
-- DisableHitTest()
-- EnableHitTest()
-- boolean IsHitTestDisabled()
-- Hide()
-- Show()
-- SetHidden(bool)
-- bool IsHidden()
-- SetRenderPass(int)
-- int GetRenderPass()
-- AcquireKeyboardFocus(bool blocksKeyDown)
-- AbandonKeyboardFocus()
-- TakeJoystickFocus()
-- bool HasJoystickFocus()
-- bool NeedsFrameUpdate()
-- SetNeedsFrameUpdate(bool needsIt)
-- SetAlpha(float newAlpha, bool children)
-- float GetAlpha()


-- debug methods
    -- string GetName()
    -- SetName(string name)
    -- Dump()
RepeaterInfo= {  ThreadId= 0  }
RepeatButtonThread = function()
    -- Keep an Id around to make sure we don't update dead things
    RepeaterInfo.ThreadId= RepeaterInfo.ThreadId + 1
    local ThreadId= RepeaterInfo.ThreadId

    while ThreadId == RepeaterInfo.ThreadId and
            RepeaterInfo.Parent and
            RepeaterInfo.Thread do
        if RepeaterInfo.ThreadLoops == 0 then
            WaitSeconds(RepeaterInfo.Time)
        elseif RepeaterInfo.ThreadLoops < 10 then
            WaitSeconds(RepeaterInfo.Time/2)
        elseif RepeaterInfo.ThreadLoops < 30 then
            WaitSeconds(RepeaterInfo.Time/4)
        else
            WaitSeconds(RepeaterInfo.Time/8)
        end
        if ThreadId == RepeaterInfo.ThreadId and RepeaterInfo.Thread then
            RepeaterInfo.ThreadLoops= RepeaterInfo.ThreadLoops + 1
            RepeaterInfo.Parent:HandleEvent(RepeaterInfo.ThreadEvent)
        end
    end
end
function StartRepeatButtonThread(self, event, time, allowMigrate)
    RepeaterInfo.Parent= self
    RepeaterInfo.ThreadLoops= 0
    RepeaterInfo.Time= time
    RepeaterInfo.ThreadMigrate= allowMigrate
    RepeaterInfo.ThreadEvent= event

    return ForkThread(RepeatButtonThread)
end

Control = Class(moho.control_methods) {

    -- reset the control's layout to the defaults, in this case
    -- makes a circular dependency where you must have at least 4 defined
    -- Overload this in your own classes to make it behave differently
    ResetLayout = function(self)
        self.Left:Set(function() return self.Right() - self.Width() end)
        self.Top:Set(function() return self.Bottom() - self.Height() end)
        self.Right:Set(function() return self.Left() + self.Width() end)
        self.Bottom:Set(function() return self.Top() + self.Height() end)
        self.Width:Set(function() return self.Right() - self.Left() end)
        self.Height:Set(function() return self.Bottom() - self.Top() end)
    end,

    OnInit = function(self)
        self:ResetLayout()

        -- default to setting the depth to parent + 1
        self.Depth:Set(function() return self:GetParent().Depth() + 1 end)
        
        self._isDisabled = false
        -- Initial structures for Joystick Navigation...
        self.JoystickNavigation = {}
        self.JoystickNavigation.OnPress = {}
        self.JoystickNavigation.OnRelease = {}

        self.JoystickRepeater = {}
    end,

    AddRepeatHandler = function(self, buttonName, navigateToControl, repeatTime)
        local useNavigationMigration= false
        if navigateToControl then
            self.JoystickNavigation.OnPress[buttonName] = navigateToControl
            useNavigationMigration= true
        end
        local OldRepeater= self:FindRepeater(buttonName)
        if OldRepeater == 0 then
            table.insert(self.JoystickRepeater, { Button= buttonName, Migrate= useNavigationMigration, Time= repeatTime or 0.3} )
        else
            self.JoystickRepeater[OldRepeater].Time= repeatTime or 0.3
            self.JoystickRepeater[OldRepeater].Migrate= useNavigationMigration
        end    
        self:SetUsingRepeater(true)
    end,

    FindRepeater = function(self, button)
        for i,rep in self.JoystickRepeater do
            if button == rep.Button then
                return i
            end
        end
        return 0
    end,

    HandleRepeaterEvent = function(parent, event)
        if event.Type == 'JoystickAnalogMotion' then
            local queryOnly = true
            local fakeEvent = import('/lua/ui/uiutil.lua').HandleLeftThumbstickDPadEmulation( event, queryOnly )
            if fakeEvent != {} then
                parent:HandleRepeaterEvent( fakeEvent )
                return
            end
        end

        if event.Type == 'JoystickButtonDClick' then
            event.Type= 'JoystickButtonPress'
        end

        -- If currently repeating a button, cancel it
        if (event.Type == 'JoystickButtonPress' or event.Type == 'JoystickButtonRelease') and
                RepeaterInfo.Thread then
            KillThread(RepeaterInfo.Thread)
            RepeaterInfo.Thread= nil
            RepeaterInfo.ThreadMigrate= nil
            RepeaterInfo.ThreadLoops= nil
            RepeaterInfo.ThreadEvent= nil
            RepeaterInfo.Parent= nil
        end

        local ButtonIndex= parent:FindRepeater(event.JoystickButton)
        if ButtonIndex > 0 then
            -- User pressed a button?  Fork a thread to spawn the same event later in time repeatedly
            if event.Type == 'JoystickButtonPress' then
                -- Start a thread which will repeat this button every so often
                RepeaterInfo.Thread= StartRepeatButtonThread(parent,
                                                             event,
                                                             parent.JoystickRepeater[ButtonIndex].Time,
                                                             parent.JoystickRepeater[ButtonIndex].Migrate)
            end
        end
    end,

    HandleRepeaterMigration = function(self, lastFocus)
        if lastFocus and lastFocus != self then
            if RepeaterInfo.ThreadEvent and RepeaterInfo.ThreadMigrate then
                local ButtonIndex= self:FindRepeater(RepeaterInfo.ThreadEvent.JoystickButton)
                if ButtonIndex > 0 then
                    -- Assign the new parent and parameters
                    RepeaterInfo.Parent= self
                    RepeaterInfo.Time= self.JoystickRepeater[ButtonIndex].Time
                    RepeaterInfo.ThreadMigrate= self.JoystickRepeater[ButtonIndex].Migrate
                else
                    -- Currently repeating button does not repeat for this control, cancel it
                    if RepeaterInfo.Thread then
                        KillThread(RepeaterInfo.Thread)
                        RepeaterInfo.Thread= nil
                    end
                    RepeaterInfo.ThreadMigrate= nil
                    RepeaterInfo.ThreadLoops= nil
                    RepeaterInfo.ThreadEvent= nil
                    RepeaterInfo.Parent= nil
                end
            end
        end
    end,

    HandleEvent = function(self, event)
        return false
    end,

    Disable = function(self)
        self._isDisabled = true
        self:DisableHitTest()
        self:OnDisable()
    end,

    Enable = function(self)
        self._isDisabled = false
        self:EnableHitTest()
        self:OnEnable()
    end,

    IsDisabled = function(self)
        return self._isDisabled
    end,

    -- called when the control is destroyed
    OnDestroy = function(self)
    end,

    -- called when a frame update is ready, elapsedTime is time since last frame
    OnFrame = function(self, elapsedTime)
    end,

    -- called when the control is enabled
    OnEnable = function(self)
    end,

    -- called when the control is disabled
    OnDisable = function(self)
    end,
    
    -- called when the control is shown or hidden
    -- if this function returns true, its children will not get their OnHide functions called
    OnHide = function(self, hidden)
    end,
    
    -- called when we have keyboard focus and another control is clicked on
    OnLoseKeyboardFocus = function(self)
    end,
    
    -- called when joystick focus is lost due to control switch
    OnLoseJoystickFocus = function(self)
    end,
    -- called when another control takes keyboard focus
    OnKeyboardFocusChange = function(self)
    end,
    
    -- called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax
    -- aixs can be "Vert" or "Horz"
    GetScrollValues = function(self, axis)
        return 0, 0, 0, 0
    end,

    -- called when the scrollbar wants to scroll a specific number of lines (negative indicates scroll up)
    ScrollLines = function(self, axis, delta)
    end,

    -- called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    ScrollPages = function(self, axis, delta)
    end,

    -- called when the scrollbar wants to set a new visible top line
    ScrollSetTop = function(self, axis, top)
    end,

    -- called to determine if the control is scrollable on a particular access. Must return true or false.
    IsScrollable = function(self, axis)
        return false
    end,
    IsNavigable = function(self)
        return (not self:IsHidden()) and (not self:IsDisabled())
    end,
    -- up, down, left, right, and back point to controls which will become
    -- active when the specified direction is pressed on the joystick.
    SetupJoystickNavigation = function(self, up, down, left, right, back)
        self.JoystickNavigation.OnRelease.DPadUp    = up
        self.JoystickNavigation.OnRelease.DPadDown  = down
        self.JoystickNavigation.OnRelease.DPadLeft  = left
        self.JoystickNavigation.OnRelease.DPadRight = right
        if back then
            self.JoystickNavigation.OnRelease.B = back
        end
    end,

    -- Implement Joystick Navigation
    NavigatesTo = function(self, event)
        local navigateToControl = nil
        if event.Type == 'JoystickButtonPress' then
            -- discover what control we are changing to,
            -- while using the joystick directions...
            navigateToControl = self.JoystickNavigation.OnPress[event.JoystickButton]
        elseif event.Type == 'JoystickButtonRelease' then
            navigateToControl = self.JoystickNavigation.OnRelease[event.JoystickButton]
        end
        -- Skip over any inactive/disabled controls
        if navigateToControl.IsNavigable and not navigateToControl:IsNavigable() then
            navigateToControl= navigateToControl:NavigatesTo(event)
        end
        return navigateToControl
    end,

    -- If this control has focus, then give focus to the specified object instead.
    RelinquishJoystickFocus = function(self, newFocus)
        if self:HasJoystickFocus() then
            newFocus:TakeJoystickFocus()
        end
    end
}
