-----------------------------------------------------------------------------
--  File     : /props/Lights/UEF/ULight03/ULight03_script.lua
--  Author(s): Gordon Duclos, Morien
--  Summary  : SC2 Prop: ULight03
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop

I03_Ulight03 = Class(Prop) {
    OnCreate = function(self)
        Prop.OnCreate(self)
		self:AddUserThreadAnimation( '/props/Lights/UEF/ULight03/ULight03_Apan01.sca', 1, true )
		
		self:AttachOrnament( '/props/Lights/UEF/ULight03/ULight03_beam01_mesh', 'LightBottom', 0.2 )
		self:AttachOrnament( '/props/Lights/UEF/ULight03/ULight03_beam02_mesh', 'LightBottom', 0.2 )
    end,
}
TypeClass = I03_Ulight03
