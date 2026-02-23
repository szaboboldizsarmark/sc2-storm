-- Class methods:
-- SetNumberOfSelections(int)
-- int GetNumberOfSelections()
-- int GetCurrentSelectionIndex()

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local UIUtil = import('/lua/ui/uiutil.lua')

WheelSelector = Class(moho.wheelselector_methods, Bitmap) {

    __init = function(self, parent, filename, debugname)
        InternalCreateWheelSelector(self, parent)
        if debugname then
            self:SetName(debugname)
        end

        self._items = {}
        self._dismissOnSelection = true
        self._manualpositioning = false

        self:SetIconScaleFactors( 0.7, 1.0 )
    end,

    OnInit = function(self)
        Bitmap.OnInit(self)
    end,

    -- Override this with an implementation which will observe 
    -- the selector passing over items (or nil if the thumbstick is released)
    OnSelectionChanged = function(self, selectionIndex)
    end,

    -- Items are added to _items as 1..nItems.  There's no item 0.
    AddItem = function( self, control, batch )
        control:SetParent( self )
        control.Depth:Set( function() return self.Depth() - 1 end ) -- render the icons under the selector
        control._wheelIndex = self:ItemCount()+1
        self._items[control._wheelIndex] = control
        self:SetSelectable( control._wheelIndex, true )
        self:SetNumberOfSelections( self:ItemCount() )
        if not batch then self:_CalculateVisible() end
    end,

    -- Discard and destroy the entire content of the selection wheel.    
    DeleteAndDestroyAll = function(self, batch)
        for i = 1, self:ItemCount() do
            if self._items[i] then
                self._items[i]:Destroy()
                self._items[i] = nil
            end
        end
        self:SetNumberOfSelections( self:ItemCount() )
        if batch then self:_CalculateVisible() end
    end,

    DestroyAllItems = function(self, batch)
        for i = 1, self:ItemCount() do
            if self._items[i] then 
                self._items[i]:Destroy()
                self._items[i] = nil
            end
        end
        if not batch then self:_CalculateVisible() end
    end,

    -- Batch mode operators don't calculate visible after adding/removing so make sure you call
    -- EndBatch when done adding
    EndBatch = function(self)
        self:SetNumberOfSelections( self:ItemCount() )
        self:_CalculateVisible()
        self:RethinkSelection()
    end,

    AppendSlots = function(self, count, batch)
        count = count or 1
        for i = self:ItemCount()+1, self:ItemCount()+count do
            self._items[i] = false
            self:SetSelectable( i, false )
        end
        self:SetNumberOfSelections( self:ItemCount() )
        if not batch then self:_CalculateVisible() end
    end,

    SetItem = function( self, control, index, batch )
        if not self:_CheckIndex( index ) then return end
        control:SetParent( self )
        control.Depth:Set( function() return self.Depth() - 1 end ) -- render the icons under the selector
        control._wheelIndex = index
        self._items[index] = control
        self:SetSelectable( index, true )
        self:SetNumberOfSelections( self:ItemCount() )
        if not batch then self:_CalculateVisible() end
    end,

    -- Look-up a specific icon around this wheel.
    GetItem = function(self, itemIndex)
        return self._items[itemIndex]
    end,

    DestroyItem = function(self, index, batch)
        if not self:_CheckIndex(index) then return end
        if self._items[index] then
            self._items[index]:Destroy()
            self._items[index] = false
        end
        if not batch then self:_CalculateVisible() end
    end,

    _CheckIndex = function(self, index)
        if (index > self:ItemCount()) or (index < 1) then
            if not index then
               error("WheelSelector: Attempt to set index out of range (requested = nil range = " .. self:ItemCount() .. ")")
            else
               error("WheelSelector: Attempt to set index out of range (requested = " .. index .. " range = " .. self:ItemCount() .. ")")
            end
            return false
        end
        return true
    end,

    SetSelectable = function( self, index, selectable )
        if self:_HasItem( index ) then
            local item = self:GetItem( index )
            item.selectable = selectable
        end
    end,

    -- Return TRUE if at least one item can be displayed by the selection wheel.
    HasVisibleItems = function(self)
        for i = 1, self:ItemCount() do
            if self:_HasItem( i ) then
                return true
            end
        end
        return false
    end,

    -- Return TRUE if at least one item on the wheel is selectable
    HasSelectableItems = function(self)
        for i = 1, self:ItemCount() do
            if self:IsSelectableItem( i ) then
                return true
            end
        end
        return false
    end,

    IsSelectableItem = function( self, index )
        if self:_HasItem( index ) then
            local item = self:GetItem( index )
            if ( item.selectable == true ) then
                return true
            end
        end
        return false
    end,

    _HasItem = function(self, index)
        if self._items[index] then
            return true
        end
        return false
    end,

    -- Ensure the icons assigned to this wheel, are visible and positioned correctly.
    _CalculateVisible = function(self)
        if not self._items then return end -- protect against premature calls
        for i = 1, self:ItemCount() do
            local control = self._items[i]
            if control then
                self:_PositionItem(control)
            end
        end
    end,

    -- Discover how many icons are assigned to the wheel.
    -- NOTE: items are numbered beginning at 1, so the last item is == ItemCount().
    -- The first available array slot, is thus, ItemCount()+1.
    ItemCount = function(self)
        if self._items then
            return table.getn(self._items)
        else
            return 0
        end
    end,

    -- overrides calculated positioning of all added items
    -- NOTE: only set before any items are added to the wheel
    SetManualPositioning = function( self, doManualPositioning )
        self._manualpositioning = doManualPositioning
    end,

    -- Assign a position, large, and small dimensions to the icon.
    _PositionItem = function(self, control)

        if ( self._manualpositioning == false ) then
            -- Assign a top/left coordinate by centering the icon over one of the 
            -- icon positions around the wheel.
            control.Left:Set(
                function() 
                    local index = control._wheelIndex
                    local count = self:ItemCount()
                    local x,y = self:GetIconPosition(
                        control._wheelIndex-1, 
                        self:ItemCount())
                    return x - control.Width() / 2
                end 
            )
            control.Top:Set(
                function() 
                    local x,y = self:GetIconPosition(
                        control._wheelIndex-1, 
                        self:ItemCount())
                    return y - control.Height() / 2
                end
            )
        end

        -- Assign an icon size when unselected and selected
        control.WidthUnselected = function(selfIcon)
            return selfIcon.BitmapWidth() * self.scaleUnselected
        end

        control.HeightUnselected = function(selfIcon)
            return selfIcon.BitmapHeight() * self.scaleUnselected
        end

        control.WidthSelected = function(selfIcon)
            return selfIcon.BitmapWidth() * self.scaleSelected
        end

        control.HeightSelected = function(selfIcon)
            return selfIcon.BitmapHeight() * self.scaleSelected
        end

        -- By default, the icon is unselected.
        self:_DoDeselect(control)
    end,

    -- Cause the icon to become selected (larger)
    DoSelect = function( self, control )
        self._currentItem = control
        self._currentItem.Width:Set( 
            function()
                return control:WidthSelected()
            end
        )
        self._currentItem.Height:Set( 
            function()
                return control:HeightSelected()
            end
        )
        -- call the control's DoSelect to allow it to scale any child controls
        if self._currentItem.DoSelect then
            self._currentItem.DoSelect( control )
        end
    end,

    -- Cause the large icon to become deselected (smaller)
    DoDeselectCurrent = function( self )
        if self._currentItem then
            self:_DoDeselect( self._currentItem )
            self._currentItem = nil
        end
    end,

    -- Cause the specified icon to become deselected (smaller)
    _DoDeselect = function( self, control )
        control.Width:Set( 
            function()
                return control:WidthUnselected()
            end
        )
        control.Height:Set( 
            function()
                return control:HeightUnselected()
            end
        )
        -- call the control's _DoDeselect to allow it to scale any child controls
        if self._currentItem._DoDeselect then
            self._currentItem._DoDeselect( control )
        end
    end,

    -- called when the control is shown or hidden
    -- if this function returns true, its children will not get their OnHide functions called
    OnHide = function(self, hidden)
        if hidden then
            UIUtil.ShowCursor()
        else
            UIUtil.HideCursor()
        end
    end,

    SetDismissOnSelection = function(self,dismiss)
        self._dismissOnSelection = dismiss
    end,
    
    IsDismissOnSelection = function(self)
        return self._dismissOnSelection
    end,

    -- NOTE: If this is called when items are visible, 
    -- you will need to cause all layout of this control to be re-computed.
    -- It's intended that this be called only once, before items are added.
    SetIconScaleFactors = function(self, _unselectedScale, _selectedScale)
        self.scaleUnselected = _unselectedScale
        self.scaleSelected = _selectedScale
    end,
}
