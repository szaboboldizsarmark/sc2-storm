-- Class methods:
-- SetInnerThickness(float 0..1)
-- SetOuterThickness(float --pixels)
-- SetNumberOfSegments(int)
-- GetNumberOfSegments(int)

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

WheelBackdrop = Class(moho.wheelbackdrop_methods, Bitmap) {

    __init = function(self, parent, filename, debugname)
        InternalCreateWheelBackdrop(self, parent)
        if debugname then
            self:SetName(debugname)
        end

        self._items = {}
        self._dismissOnSelection = true
        
        self:SetNumberOfSegments( 5 )
    end,

    OnInit = function(self)
        Bitmap.OnInit(self)
    end
}
