-- maps joystick controls
-- IMPORTANT : no internal checks to ensure that every control is uniquely mapped
--             Ensure you do not map more than one control to a particular control
--             i.e., mapping both 'Y Button' and 'X Button' to 'Right Shoulder Button' is BAD
-- Buttons, Thumbsticks and Triggers are independent of each other
-- i.e., cannot map a trigger to a button, or even a stick to a trigger
--
JoystickButtonMap = {
    --
    -- Start/Back Buttons
    --
    ['Start Button']            = { remapTo = 'Start Button',},
    ['Back Button']             = { remapTo = 'Back Button',},
    --
    -- A, B, X, Y Buttons
    --
    ['A Button']                = { remapTo = 'A Button',},
    ['B Button']                = { remapTo = 'B Button',},
    ['X Button']                = { remapTo = 'X Button',},
    ['Y Button']                = { remapTo = 'Y Button',},
    --
    -- Shoulder Buttons
    --
    ['Left Shoulder Button']    = { remapTo = 'Left Shoulder Button',},
    ['Right Shoulder Button']   = { remapTo = 'Right Shoulder Button',},
    --
    -- Directional Pad Buttons
    --
    ['D-Up Button']             = { remapTo = 'D-Up Button',},
    ['D-Down Button']           = { remapTo = 'D-Down Button',},
    ['D-Left Button']           = { remapTo = 'D-Left Button',},
    ['D-Right Button']          = { remapTo = 'D-Right Button',},
    --
    -- Left Thumbstick (Analog)
    --
    ['Left Thumb Button']       = { remapTo = 'Left Thumb Button',},
    ['Left Thumbstick']         = { remapTo = 'Left Thumbstick',},
    --
    -- Right Thumbstick (Analog)
    --
    ['Right Thumb Button']      = { remapTo = 'Right Thumb Button',},
    ['Right Thumbstick']        = { remapTo = 'Right Thumbstick',},
    --
    -- Left/Right Triggers (Analog)
    --
    ['Left Trigger']            = { remapTo = 'Left Trigger',},
    ['Right Trigger']           = { remapTo = 'Right Trigger',},
}
