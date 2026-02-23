-----------------------------------------------------------------------------
--  File     : /MP_201_tubeprop_script.lua
--  Author(s): Julie Brockett
--  Summary  : SC2 Prop: TubeProp Fan
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop

MP_201_tubeprop = Class(Prop) {
    OnCreate = function(self)
        Prop.OnCreate(self)
		self:AddUserThreadAnimation( '/props/Structures/MP_201_tubeprop/MP_201_tubeprop_ASpin01.sca', 1, true )
    end,
}
TypeClass = MP_201_tubeprop
