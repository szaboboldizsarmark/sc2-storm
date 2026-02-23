--------------------------------------------------------------------------
-- File: lua/ui/file_validation.lua
-- Summary: Extracted from the filepicker.  Just hands back a validation
--			string if there are any problems with a particular string.
--
-- Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
--------------------------------------------------------------------------

local maxFilenameSize = 30;

errorMsg = {
    zero = "<LOC filepicker_0000>A filename must have at least one character",
    toolong = "<LOC filepicker_0001>A filename can contain no more than %d characters",
    invalidchars = "<LOC filepicker_0002>A filename can not contain the characters \\ / : * ? < > | \" ' .",
    invalidlast = "<LOC filepicker_0006>A filename can not begin or end with a space or a period",
    invalidname = "<LOC filepicker_0007>You have requested an invalid file name",
}

local invalidCharSet = {
    [9] = true,    -- tab
    [92] = true,   -- \  
    [47] = true,   -- /
    [58] = true,   -- :
    [42] = true,   -- *
    [63] = true,   -- ?
    [60] = true,   -- <
    [62] = true,   -- >
    [124] = true,  -- |
    [39] = true,   -- '
    [34] = true,   -- "
    [46] = true,   -- .
}

local columConfigurations = {
    {
        {title = '<LOC _Name>', width = 435, sortby = 'name', key = 'name'},
        {title = '<LOC Date>', width = 130, sortby = 'TimeStamp', key = 'date'},
    },
    {
        {title = '<LOC _Name>', width = 267, sortby = 'name', key = 'name'},
        {title = '<LOC tooltipui0147>', width = 150, sortby = 'profile', key = 'owner'},
        {title = '<LOC Date>', width = 130, sortby = 'TimeStamp', key = 'date'},
    },
}

local invalidStringSet = {
    ['\\'] = true,
    ['/'] = true,
    [':'] = true,
    ['*'] = true,
    ['?'] = true,
    ['<'] = true,
    ['>'] = true,
    ['|'] = true,
    ["'"] = true,
    ['"'] = true,
    ['%.'] = true,
}

local invalidNameSet = {
    ["CON"] = true,
    ["PRN"] = true,
    ["AUX"] = true,
    ["CLOCK$"] = true,
    ["NUL"] = true,
    ["COM0"] = true,
    ["COM1"] = true,
    ["COM2"] = true,
    ["COM3"] = true,
    ["COM4"] = true,
    ["COM5"] = true,
    ["COM6"] = true,
    ["COM7"] = true,
    ["COM8"] = true,
    ["COM9"] = true,
    ["LPT0"] = true,
    ["LPT1"] = true,
    ["LPT2"] = true,
    ["LPT3"] = true,
    ["LPT4"] = true,
    ["LPT5"] = true,
    ["LPT6"] = true,
    ["LPT7"] = true,
    ["LPT8"] = true,
    ["LPT9"] = true,
}

-- this function tests a character to see if it's invalid in a file name
function IsCharInvalid(charcode)
    return invalidCharSet[charcode] or false
end

-- tests a filename for several validity issues, returns error code key
function GetFilenameValidationMessage(filename)
    -- check for nil
    if not filename then
        return errorMsg['zero']
    end    
    
    local len = STR_Utf8Len(filename)

    -- check length
    if len == 0 then
        return errorMsg['zero']
    end

    if len > maxFilenameSize then
        return errorMsg['toolong']
    end

    -- check for invalid chars
    for char, val in invalidStringSet do
        if string.find(filename, char) then
            return errorMsg['invalidchars']
        end
    end

    -- last characher may not be space or .
    local lastChar = string.sub(filename, len)
    if lastChar == " " or lastChar == "." then
        return errorMsg['invalidlast']
    end
    
    local firstChar = string.sub(filename, 1, 1)
    if firstChar == " " or firstChar == "." then
        return errorMsg['invalidlast']
    end
    
    -- check for invalid names
    if invalidNameSet[string.upper(filename)] then
        return errorMsg['invalidname']
    end

    return ""
end