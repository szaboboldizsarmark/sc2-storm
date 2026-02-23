--*****************************************************************************
--* File: lua/modules/ui/game/gamecommon.lua
--* Author: Chris Blackwell
--* Summary: Functionality that is used by several game UI components
--*
--* Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

iconBmpHeight = 48
iconBmpWidth = 48
iconVertPadding = 1
iconHorzPadding = 1
iconHeight = iconBmpHeight + (2 * iconVertPadding)
iconWidth = iconBmpWidth + (2 * iconHorzPadding)


-- add the filenames of the icons to the blueprint, creating a new RuntimeData table in the process where runtime things
-- can be stored in blueprints for convenience
-- Now also prefetches the icons and keeps them in the cache
function InitializeUnitIconBitmaps(prefetchTable)
--[[
	$$NOTE: GV -disabled because __blueprints is not properly exposed to Lua anymore
    local alreadyFound = {}
    for i,v in __blueprints do
        if v.Display.IconName then -- filter for icon name
            if not alreadyFound[v.RuntimeData.IconFileName] then
                table.insert(prefetchTable, v.RuntimeData.IconFileName)
                alreadyFound[v.RuntimeData.IconFileName] = true
            end
            if not alreadyFound[v.RuntimeData.UpIconFileName] then
                table.insert(prefetchTable, v.RuntimeData.UpIconFileName)
                alreadyFound[v.RuntimeData.UpIconFileName] = true
            end
            if not alreadyFound[v.RuntimeData.DownIconFileName] then
                table.insert(prefetchTable, v.RuntimeData.DownIconFileName)
                alreadyFound[v.RuntimeData.DownIconFileName] = true
            end
            if not alreadyFound[v.RuntimeData.OverIconFileName] then
                table.insert(prefetchTable, v.RuntimeData.OverIconFileName)
                alreadyFound[v.RuntimeData.OverIconFileName] = true
            end
        end
    end
	]]
end

-- call this to get the cached version of the filename, and will recache if the cache is lost
function GetCachedUnitIconFileNames(blueprint)    
    -- Handle finding Unit icons
    if not blueprint.RuntimeData.IconFileName then
        if not blueprint.RuntimeData then
            blueprint.RuntimeData = {}
        end
        blueprint.RuntimeData.IconFileName, blueprint.RuntimeData.UpIconFileName, blueprint.RuntimeData.DownIconFileName, blueprint.RuntimeData.OverIconFileName = GetUnitIconFileNames(blueprint)
    end
    return blueprint.RuntimeData.IconFileName, blueprint.RuntimeData.UpIconFileName, blueprint.RuntimeData.DownIconFileName, blueprint.RuntimeData.OverIconFileName
end

-- generic function that can be used to replace the OnHide that supresses showing the item
-- when returning from HideUI state
-- supress showing when coming back from hidden UI
function SupressShowingWhenRestoringUI(self, hidden)
    if not hidden then
        if import('/lua/ui/game/gamemain.lua').gameUIHidden then
            self:Hide()
            return true
        end
    end
end