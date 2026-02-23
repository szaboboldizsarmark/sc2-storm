local Control = import('control.lua').Control
local Group = import('group.lua').Group
local LazyVar = import('/lua/system/lazyvar.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

Grid = Class(Group) {
    -- note that the grid "assumes" your entries will be the correct width and height but doesn't enforce it
    -- controls could be bigger or smaller, it's up to you, but if they're bigger they will overlap as only
    -- the left top is placed, the whole grid is not resized
    __init = function(self, parent, itemWidth, itemHeight)
        Group.__init(self, parent, "Grid")
        self._itemWidth = itemWidth
        self._itemHeight = itemHeight
        self._items = {}
        self._top = {}
        self._top["Horz"] = 1
        self._top["Vert"] = 1
        self._visible = {}
        self._lines = {}
        self._lines["Horz"] = 0
        self._lines["Vert"] = 0
        
        -- visible
        self._visible["Horz"] = LazyVar.Create()
        self._visible["Vert"] = LazyVar.Create()
        
        self._visible["Horz"]:Set(function() return math.floor(self.Width() / itemWidth) end)
        self._visible["Vert"]:Set(function() return math.floor(self.Height() / itemHeight) end)
    
        -- get frame update to check visibility
        self:SetNeedsFrameUpdate(true)
        self._lastVisible = {}
        self._lastVisible["Horz"] = 0
        self._lastVisible["Vert"] = 0
    end,

    OnInit = function(self)
        Control.OnInit(self)
    end,

    OnFrame = function(self, elapsedTime)
--TODO get rid of this frame function and use the OnDirty of the lazy vars
        if (self._lastVisible["Horz"] != self._visible["Horz"]()) or
           (self._lastVisible["Vert"] != self._visible["Vert"]()) then
            self:_CalculateVisible()
            self._lastVisible["Horz"] = self._visible["Horz"]()
            self._lastVisible["Vert"] = self._visible["Vert"]()
        end
    end,

    _CheckRow = function(self, row)
        if (row > self._lines["Vert"]) or (row < 1) then
            error("Grid: Attempt to set row out of range (requested = " .. row .. " range = " .. self._lines["Vert"] .. ")")
            return false
        end
        return true
    end,
    
    _CheckCol = function(self, col)
        if (col > self._lines["Horz"]) or (col < 1) then
            error("Grid: Attempt to set column out of range (requested = " .. col .. " range = " .. self._lines["Horz"] .. ")")
            return false
        end
        return true
    end,

    _HasRow = function(self, row)
        if (row > self._lines["Vert"]) or (row < 1) then
            return false
        end
        return true
    end,
    
    _HasCol = function(self, col)
        if (col > self._lines["Horz"]) or (col < 1) then
            return false
        end
        return true
    end,

    HasColRow = function(self,col,row)
        if not self:_HasRow(row) or not self:_HasCol(col) then
            return false
        end
        return true
    end,
    GetVisible = function(self)
        return self._visible["Horz"](), self._visible["Vert"]()
    end,

    GetDimensions = function(self)
        return self._lines["Horz"], self._lines["Vert"]
    end,

    AppendRows = function(self, count, batch)
        if count < 1 then
            count = 1
        end
        for row = self._lines["Vert"] + 1, self._lines["Vert"] + count do
            self._items[row] = {}
        end
        self._lines["Vert"] = self._lines["Vert"] + count
        if not batch then self:_CalculateVisible() end
    end,
    
    AppendCols = function(self, count, batch)
        if count < 1 then
            count = 1
        end
        self._lines["Horz"] = self._lines["Horz"] + count
        if not batch then self:_CalculateVisible() end
    end,
    
    DeleteRow = function(self, row, batch)
        if not self:_CheckRow(row) then return end
        for col = 1, self._lines["Horz"] do
            if self._items[row][col] then self._items[row][col]:Hide() end
            self._items[row][col] = nil
        end
        table.remove(self._items, row)
        self._lines["Vert"] = self._lines["Vert"] - 1
        if not batch then self:_CalculateVisible() end
    end,
    
    DeleteCol = function(self, col, batch)
        if not self:_CheckCol(col) then return end
        for row = 1, self._lines["Vert"] do
            if self._items[row][col] then 
                self._items[row][col]:Hide()
                self._items[row][col] = nil
                table.remove(self.items[row], col)
            end
        end
        self._lines["Horz"] = self._lines["Horz"] - 1
        if not batch then self:_CalculateVisible() end
    end,
    
    DeleteAll = function(self, batch)
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                if self._items[row][col] then self._items[row][col]:Hide() end
                self._items[row][col] = nil
            end
            self._items[row] = nil
        end
        self._lines["Horz"] = 0
        self._lines["Vert"] = 0
        self:ScrollSetTop("Horz", 1)
        self:ScrollSetTop("Vert", 1)
        if not batch then self:_CalculateVisible() end
    end,

    -- When the Grid control gains joystick focus, it hands it off to the first visible and enabled item.
    TakeJoystickFocus = function(self)
        Log("Grid:TakeJoystickFocus")
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                local control = self._items[row][col]
                if control != nil and not control:IsDisabled() then
                    if  (col >= self._top["Horz"]) and (col < self._top["Horz"] + self._visible["Horz"]()) and
                        (row >= self._top["Vert"]) and (row < self._top["Vert"] + self._visible["Vert"]()) then
                        control:TakeJoystickFocus()
                        return
                    end
                end
            end
        end
        Control.TakeJoystickFocus(self)
    end,
    DumpGrid = function(self)
        Log("Grid:DumpGrid ["..self._lines["Vert"].."x"..self._lines["Horz"].."], getn="..table.getn(self._items))
        for row = 1, self._lines["Vert"] do
            local rowText = ""
            for col = 1, self._lines["Horz"] do
                if self._items[row][col] then
                    rowText = rowText.."X"
                else
                    rowText = rowText.."."
                end
            end
            Log(rowText)
        end
    end,
    -- The joystick needs navigation information for how to move between 
    -- buttons in the grid.  This method prepares the information for 
    -- how to move away from or onto the current button, from any adjascent 
    -- visible button in the grid.  If the user attempts to navigate off the 
    -- grid, the grid itself will see that particular event, and can act 
    -- appropriately.
    SetupJoystickNavigationForButtonAt = function(self,col,row)
        local above = nil
        local below = nil
        local left  = nil
        local right = nil
        if self:HasColRow(col,row-1) then above = self._items[row-1][col] end
        if self:HasColRow(col,row+1) then below = self._items[row+1][col] end
        if self:HasColRow(col-1,row) then left  = self._items[row][col-1] end
        if self:HasColRow(col+1,row) then right = self._items[row][col+1] end
        if above and above:IsHidden() then above = nil end
        if below and below:IsHidden() then below = nil end
        if left  and left:IsHidden()  then left  = nil end
        if right and right:IsHidden() then right = nil end
        local control = self._items[row][col]
        if control then
            if control.JoystickNavigation then
                if control:IsHidden() then
                    -- Remove all navigation for the hidden button.
                    control:SetupJoystickNavigation(nil,nil,nil,nil)
                    if above != nil then above.JoystickNavigation.OnRelease.DPadDown  = nil end
                    if below != nil then below.JoystickNavigation.OnRelease.DPadUp    = nil end
                    if left  != nil then  left.JoystickNavigation.OnRelease.DPadRight = nil end
                    if right != nil then right.JoystickNavigation.OnRelease.DPadLeft  = nil end
                else
                    -- Add navigation for the visible button.
                    control:SetupJoystickNavigation(above,below,left,right)
                    if above != nil then above.JoystickNavigation.OnRelease.DPadDown  = control end
                    if below != nil then below.JoystickNavigation.OnRelease.DPadUp    = control end
                    if left  != nil then  left.JoystickNavigation.OnRelease.DPadRight = control end
                    if right != nil then right.JoystickNavigation.OnRelease.DPadLeft  = control end
                end
            end
        end
    end,
    -- change and item at a particular position and destroy anything already there
    -- note that setting an item will reparent it to the grid control
    SetItem = function(self, control, col, row, batch)
        if not self:_CheckRow(row) then return end
        if not self:_CheckCol(col) then return end
        control:SetParent(self)
        control.Depth:Set(function() return self.Depth() + 1 end)
        self._items[row][col] = control
        if not batch then self:_CalculateVisible() end
    end,
    
    GetItem = function(self, col, row)
        if not self:_CheckRow(row) then return end
        if not self:_CheckCol(col) then return end
        return self._items[row][col]
    end,
    
    GetItemPosition = function(self, control)
        local row, col
        for col= 1, self._lines["Horz"] do
            for row= 1, self._lines["Vert"] do
                if self._items[row][col] == control then
                    return row,col
                end
            end
        end 
        return nil
    end,

    -- Request the control which is the top-most visible one (on the optionally specified column)
    -- or nil, if not available.
    GetTopmostVisibleItem = function(self,col)
        col = col or 1
        local row = self._top["Vert"]
        if self:HasColRow(col,row) then
            return self._items[row][col]
        else
            return nil
        end
    end,
    
    -- Request the control which is the bottom-most visible one (on the optionally specified column)
    -- or nil, if not available.
    GetBottommostVisibleItem = function(self,col)
        col = col or 1
        local row = (self._top["Vert"]) + self._visible["Vert"]() - 1
        if self:HasColRow(col,row) then
            return self._items[row][col]
        else
            return nil
        end
    end,
    
    -- Request the control which is the left-most visible one (on the optionally specified row)
    -- or nil, if not available.
    GetLeftmostVisibleItem = function(self,row)
        row = row or 1
        local col = self._top["Horz"]
        if self:HasColRow(col,row) then
            return self._items[row][col]
        else
            return nil
        end
    end,
    
    -- Request the control which is the right-most visible one (on the optionally specified row)
    -- or nil, if not available.
    GetRightmostVisibleItem = function(self,row)
        row = row or 1
        local col = (self._top["Horz"]) + self._visible["Horz"]() - 1
        if self:HasColRow(col,row) then
            return self._items[row][col]
        else
            return nil
        end
    end,
    
    -- Ask the grid if it has at-least one enabled item in it.
    HasEnabledItems = function(self)
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                if self._items[row][col] then 
                    if not self._items[row][col]:IsDisabled() then
                        return true 
                    end
                end
            end
        end
        return false
    end,
    
    -- remove is useful when the grid doesn't own the items
    RemoveItem = function(self, col, row, batch)
        if not self:_CheckRow(row) then return end
        if not self:_CheckCol(col) then return end
        if self._items[row][col] != nil then
            if self._items[row][col] then self._items[row][col]:Hide() end
            self._items[row][col] = nil
        end
        if not batch then self:_CalculateVisible() end
    end,
    
    RemoveAllItems = function(self, batch)
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                if self._items[row][col] then self._items[row][col]:Hide() end
                self._items[row][col] = nil
            end
        end
        self:ScrollSetTop("Horz", 1)
        self:ScrollSetTop("Vert", 1)
        if not batch then self:_CalculateVisible() end
    end,
    
    -- destroy is useful when the grid has ownership of the items
    DestroyItem = function(self, col, row, batch)
        if not self:_CheckRow(row) then return end
        if not self:_CheckCol(col) then return end
        if self._items[row][col] != nil then
            if ( self._items[row][col] == GetJoystickFocus() ) then
                LOG( "*** WARNING! -- Grid::DestroyItem() is destroying the joystick focus! ***" )
                LOG( "*** resetting focus to main world view... BUT FIX THIS! ***" )
                -- revert focus to the main world view
                self._items[row][col]:RelinquishJoystickFocus( import( '/lua/ui/game/worldview.lua' ).viewLeft )
            end
            self._items[row][col]:Destroy()
            self._items[row][col] = nil
        end
        if not batch then self:_CalculateVisible() end
    end,

    DestroyAllItems = function(self, batch)
        local focus = GetJoystickFocus()
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                if self._items[row][col] then 
                    if ( self._items[row][col] == focus ) then
                        LOG( "*** WARNING! -- Grid::DestroyAllItems() is destroying the joystick focus! ***" )
                        LOG( "*** resetting focus to main world view... BUT FIX THIS! ***" )
                        -- revert focus to the main world view
                        self._items[row][col]:RelinquishJoystickFocus( import( '/lua/ui/game/worldview.lua' ).viewLeft )
                    end
                    self._items[row][col]:Destroy()
                    self._items[row][col] = nil
                end
            end
        end
        self:ScrollSetTop("Horz", 1)
        self:ScrollSetTop("Vert", 1)
        if not batch then self:_CalculateVisible() end
    end,

    DeleteAndDestroyAll = function(self, batch)
        local focus = GetJoystickFocus()
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                if self._items[row][col] then
                    if ( self._items[row][col] == focus ) then
                        LOG( "*** WARNING! -- Grid::DeleteAndDestroyAll() is destroying the joystick focus! ***" )
                        LOG( "*** resetting focus to main world view... BUT FIX THIS! ***" )
                        -- revert focus to the main world view
                        self._items[row][col]:RelinquishJoystickFocus( import( '/lua/ui/game/worldview.lua' ).viewLeft )
                    end
                    self._items[row][col]:Destroy()
                    self._items[row][col] = nil
                end
            end
            self._items[row] = nil
        end
        self._lines["Horz"] = 0
        self._lines["Vert"] = 0
        self:ScrollSetTop("Horz", 1)
        self:ScrollSetTop("Vert", 1)
        if batch then self:_CalculateVisible() end
    end,

    -- Batch mode operators don't calculate visible after adding/removing so make sure you call
    -- EndBatch when done adding
    EndBatch = function(self)
        self:_CalculateVisible()
    end,
    
    GetScrollValues = function(self, axis)
        local rangeMin = 0
        local rangeMax = math.max(self._lines[axis], self._visible[axis]())
        local visibleMin = self._top[axis] - 1
        local visibleMax = (self._top[axis] - 1) + self._visible[axis]()
        return rangeMin, rangeMax, visibleMin, visibleMax
    end,
    
    ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self._top[axis] + delta)
    end,
    
    ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self._top[axis] + (delta * self._visible[axis]()))
    end,
    
    ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self._top[axis] then return end
        self._top[axis] = math.max(math.min(self._lines[axis] - self._visible[axis]() + 1 , top), 1)
        self:_CalculateVisible()
    end,
    
    IsScrollable = function(self, axis)
        if self._lines[axis] > self._visible[axis]() then
            return true
        else
            return false
        end
    end,

    _CalculateVisible = function(self)
        if not self._lines then return end -- protect against premature calls
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                local control = self._items[row][col]
                if control != nil then
                    if  (col >= self._top["Horz"]) and (col < self._top["Horz"] + self._visible["Horz"]()) and
                        (row >= self._top["Vert"]) and (row < self._top["Vert"] + self._visible["Vert"]()) then
                        control:SetHidden(false)
                        local column = col
                        local rowumn = row
                        local horzPad = math.max(0, (self._itemWidth - control.Width()) / 2)
                        local vertPad = math.max(0, (self._itemHeight - control.Height()) / 2)
                        control.Left:Set(function() return math.floor(((column - self._top["Horz"]) * self._itemWidth) + self.Left() + horzPad) end)
                        control.Top:Set(function() return math.floor(((rowumn - self._top["Vert"]) * self._itemHeight) + self.Top() + vertPad) end)
                    else
                        control:SetHidden(true)
                    end
                end
            end
        end

        -- Next, apply joystick navigation.
        for row = 1, self._lines["Vert"] do
            for col = 1, self._lines["Horz"] do
                local control = self._items[row][col]
                if control != nil then
                    self:SetupJoystickNavigationForButtonAt(col,row)
                end
            end
        end
    end,

    -- If the grid, or any control it owns, has joystick focus, 
    -- then give it up, in favor of the newFocus.
    RelinquishJoystickFocus = function( self, newFocus )
        local focus = GetJoystickFocus()
        if ( focus == self ) then
            Control.RelinquishJoystickFocus( self, newFocus )
        else
            for row = 1, self._lines["Vert"] do
                for col = 1, self._lines["Horz"] do
                    local control = self._items[row][col]
                    if ( ( control != nil ) and ( focus == control ) ) then
                        control:RelinquishJoystickFocus( newFocus )
                    end
                end
            end
        end
    end,

    OnHide = function(self, hidden)
        self:_CalculateVisible()
        -- when the grid is being shown, we want to return true so its children are not shown
        -- note that this only works if the grid elements are children of the grid, and it's
        -- possible to make them not so.
        return not hidden
    end,
}
-- RM: Needed, because grid._items.getn() seems to get stuck once in a 
--     while, even though the table remains linear without any gaps in 
--     the index sequence.  table.remove() relies on getn() returning 
--     an accurate number, so I had to write my own version.
function Table_Remove(aTable, index)
    repeat 
        aTable[index] = aTable[index+1]
        index = index + 1
    until not aTable[index]
end
GridEx = Class(Group) {
    -- Excel Grid type thing.  Rows are fixed height, cols can vary in width
    -- ColumnData example:
    --{
    --    {
    --        Width= 25,
    --        Text= "<LOC _Rank>Rank",
    --    },
    --    {
    --        Width= 50,
    --        Text= "<LOC _GamerTag>GamerTag",
    --    },
    --}
    __init = function(self, parent, rowHeight, columnData, debugname)
        Group.__init(self, parent, "GridEx", debugname)
        self.rowHeight= rowHeight
        self.Columns= columnData
        self.Rows= {}
        self.Parent= parent
        self.CurRow= LazyVar.Create()  -- Use a lazyvar for this so the highlight box moves automagically!
        self.CurRow:Set(0)
        self.StartCol= 1
        self.TopRow= 1
        
        -- visible
        self._visible = {}
        self._visible["Horz"] = LazyVar.Create()
        self._visible["Vert"] = LazyVar.Create()
        
        self._visible["Horz"]:Set(function() 
                local CurWidth= 0
                for col= self.StartCol, table.getn(self.Columns) do
                    if CurWidth + self.Columns[col].Width > self.Width() then
                        return col-self.StartCol
                    end
                    CurWidth= CurWidth + self.Columns[col].Width
                end
                return table.getn(self.Columns) - self.StartCol + 1
            end
        )
        self._visible["Vert"]:Set(function() return math.floor(self.Height() / self.rowHeight) end)

        -- Highlight bar
        self.Highlight= Bitmap(self)
        self.Highlight.VertOffset= 0
        self.Highlight.Height:Set(function()  return self.rowHeight  end)
        self.Highlight.Width:Set(function()  
                local CurWidth= 0
                for col= 1, self._visible["Horz"]() do
                    CurWidth= CurWidth + self.Columns[col + self.StartCol - 1].Width
                end
                return CurWidth
            end
        )
        self.Highlight:SetSolidColor('ff777777')
        self.Highlight.Top:Set(function()  return (self.CurRow() - self.TopRow + 1) * self.rowHeight + self.Columns[self.StartCol].Group.Top() + self.Highlight.VertOffset end)
        self.Highlight.Left:Set(function()  return self.Columns[self.StartCol].Group.Left()  end)

        self.GetScrollValues = function(control, axis)
            return 1, table.getn(self.Rows), self.TopRow, math.min(table.getn(self.Rows), self.TopRow + self._visible["Vert"]() - 1)
        end

        self.ScrollBar= UIUtil.CreateVertScrollbarFor(self)
        
        -- Setup the event handler for scrolling
        self.HandleEvent = function(ctrl, event)
            local eventHandled = false

            if self.CurRow() == 0 then
                return false
            end
            
            if event.Type == 'JoystickButtonDClick' then
                event.Type= 'JoystickButtonPress'
            end

            -- This can be expanded to scroll horizontally as well... If needed.
            if event.Type == 'JoystickButtonPress' then
                if event.JoystickButton == 'DPadUp' then
                    if self.CurRow() == 1 then
                        self.CurRow:Set(table.getn(self.Rows))
                        self.TopRow= math.max(1, table.getn(self.Rows) - self._visible["Vert"]() + 1)
                        self:ScrollSetTop(nil, self.TopRow)
                    else
                        self.CurRow:Set(self.CurRow() - 1)
                        self.TopRow= math.min(self.TopRow, self.CurRow())
                        self:ScrollSetTop(nil, self.TopRow)
                    end
                    local sound = Sound( { Cue = "UI_Options_Rollover", Bank = "Interface", } )
                    PlaySound( sound )
                    eventHandled = true
                elseif event.JoystickButton == 'DPadDown' then
                    if self.CurRow() == table.getn(self.Rows) then
                        self.CurRow:Set(1)
                        self.TopRow= 1
                        self:ScrollSetTop(nil, self.TopRow)
                    else
                        self.CurRow:Set(self.CurRow() + 1)
                        self.TopRow= math.max(self.TopRow, self.CurRow() - self._visible["Vert"]() + 1)
                        self:ScrollSetTop(nil, self.TopRow)
                    end
                    local sound = Sound( { Cue = "UI_Options_Rollover", Bank = "Interface", } )
                    PlaySound( sound )
                    eventHandled = true
                end
                if eventHandled then
                    self:UpdateDisplay()
                end
            elseif event.Type == 'JoystickButtonRelease' then
                if event.JoystickButton == 'A' then
                    self:OnSelect(self.CurRow())
                end
            elseif event.Type == 'JoystickAnalogMotion' then
                -- Handle Left Thumbstick control imitating DPadUp/DPadDown/DPadLeft/DPadRight button events
                local fakeEvent = UIUtil.HandleLeftThumbstickDPadEmulation( event )
                if fakeEvent != {} then
                    eventHandled = self:HandleEvent( fakeEvent )
                end
            end

            return eventHandled
        end
    end,
    
    AddRow = function(self, rowData)
        table.insert(self.Rows, rowData)
    end, 

    Clear = function(self)
        self.Rows= {}
        self.CurRow:Set(0)
        self.StartCol= 1
        self.TopRow= 1
    end,
    
    InitTableText = function(self)
        self.Text= {}
        for j= 1, self._visible["Vert"]() do
            self.Text[j]= {}
            for i= 1, table.getn(self.Columns) do
                self.Columns[i].Group= Group(self.Parent)
                LayoutHelpers.DepthOverParent(self.Columns[i].Group, self.Highlight)
                if i==1 then
                    LayoutHelpers.Above(self.Columns[i].Group, self)
                else
                    LayoutHelpers.RightOf(self.Columns[i].Group, self.Columns[i-1].Group)
                end
                self.Columns[i].Group.Width:Set(self.Columns[i].Width)
                self.Columns[i].Group.Height:Set(self.rowHeight)
                self.Text[j][i]= UIUtil.CreateText(self.Columns[i].Group, "", 
                                    self.Columns[i].FontSize or UIUtil.Fonts.FileListElementText.size, 
                                    self.Columns[i].FontName or UIUtil.Fonts.FileListElementText.fontName)
--                self.Text[j][i].Width:Set(self.Columns[i].Width)
--                self.Text[j][i].Height:Set(self.rowHeight)
                self.Text[j][i].Top:Set(((self.rowHeight / 2) - (self.Text[j][i].Height() / 2)) + self.Columns[i].Group.Top() + j * self.rowHeight)

--[[                if j == 1 then
                    LayoutHelpers.Below(self.Text[j][i], self.Columns[i].Group)
                else
                    LayoutHelpers.Below(self.Text[j][i], self.Text[j-1][i])
                end--]]
                if self.Columns[i].Alignment == 'Center' then
--                    LayoutHelpers.AtHorizontalCenterIn(self.Text[j][i], self.Columns[i].Group)
                    LayoutHelpers.AtHorizontalCenterIn(self.Text[j][i], self.Columns[i].AlignmentControl())
                else
                    self.Text[j][i].Left:Set(self.Columns[i].Group.Left())
                end
                LayoutHelpers.DepthOverParent(self.Text[j][i], self.Columns[i].Group)
            end
        end
    end,
    
    OnSelect = function(self, row)
    end,
    
    UpdateDisplay = function(self)
        for j= 1, self._visible["Vert"]() do
            for i= self.StartCol, self._visible["Horz"]() do
                if self.Rows[j-1+self.TopRow] and self.Rows[j-1+self.TopRow][i] then
                    self.Text[j][i]:SetText(self.Rows[j-1+self.TopRow][i])
                else
                    self.Text[j][i]:SetText("")
                end                    
            end
        end
        if table.getn(self.Rows) > 0 then
            self.Highlight:Show()
            if self.CurRow() == 0 then
                self.CurRow:Set(1)
            end
        else
            self.CurRow:Set(0)
            self.Highlight:Hide()
        end
    end,
}    
