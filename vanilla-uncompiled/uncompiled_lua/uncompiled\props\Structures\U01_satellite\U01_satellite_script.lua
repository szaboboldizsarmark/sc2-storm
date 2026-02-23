-----------------------------------------------------------------------------
--  File     : /MP_201_tubeprop_script.lua
--  Author(s): Julie Brockett
--  Summary  : SC2 Prop: TubeProp Fan
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop

U01_satellite = Class(Prop) {
    OnCreate = function(self)
        Prop.OnCreate(self)
		self:AddUserThreadAnimation( '/props/Structures/U01_satellite/U01_satellite_ASpin01.sca', 1, true )
    end,
}
TypeClass = U01_satellite
