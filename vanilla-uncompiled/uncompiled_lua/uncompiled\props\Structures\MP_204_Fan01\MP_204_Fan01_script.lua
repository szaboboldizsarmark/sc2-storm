-----------------------------------------------------------------------------
--  File     : /MP_204_Fan01_prop_script.lua
--  Author(s): Gordon Duclos, Julie Brockett
--  Summary  : SC2 Prop: Fan01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop

MP_204_Fan01 = Class(Prop) {
    OnCreate = function(self)
        Prop.OnCreate(self)
		self:AddUserThreadAnimation( '/props/Structures/MP_204_Fan01/MP_204_Fan01_ASpin01.sca', 1, true )
    end,
}
TypeClass = MP_204_Fan01
