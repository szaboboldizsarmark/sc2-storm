-----------------------------------------------------------------------------
--  File     : /props/Mine_Crawler/Mine_Crawler_script.lua
--  Author(s):
--  Summary  : SC2 Mine Crawler: Prop
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop

Mine_Crawler = Class(Prop) {
	OnCreate = function(self)
        Prop.OnCreate(self)
        self:AddUserThreadAnimation( '/Units/Scenario/SCL2101/SCL2101_Amine01.sca', 1, false )
    end,

}
TypeClass = Mine_Crawler