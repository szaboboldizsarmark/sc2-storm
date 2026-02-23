-----------------------------------------------------------------------------
--  File     : /MP_201_tubeprop_script.lua
--  Author(s): Julie Brockett
--  Summary  : SC2 Prop: TubeProp Fan
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop

driller01 = Class(Prop) {
    OnCreate = function(self)
        Prop.OnCreate(self)
		self:AddUserThreadAnimation( '/props/Cranes/UEF_Driller/driller01_ASpin01.sca', 1, true )
    end,
}
TypeClass = driller01
