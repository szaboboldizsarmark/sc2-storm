-- Class methods:
-- AddLayer( int layer, float u0, float v0, float u1, float v1 );

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap

WheelBits = Class(moho.wheelbits_methods, Bitmap) {

    __init = function(self, parent, filename, debugname)
        InternalCreateWheelBits(self, parent)
        if debugname then
            self:SetName(debugname)
        end

        self._items = {}
        self._dismissOnSelection = true
        
    end,

    OnInit = function(self)
        Bitmap.OnInit(self)
    end
}
