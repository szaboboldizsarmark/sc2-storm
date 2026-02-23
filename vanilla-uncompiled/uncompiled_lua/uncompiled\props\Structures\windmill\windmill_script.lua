-----------------------------------------------------------------------------
--  File     : /MP_201_tubeprop_script.lua
--  Author(s): Julie Brockett
--  Summary  : SC2 Prop: TubeProp Fan
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Prop = import('/lua/sim/Prop.lua').Prop
local Utils = import('/lua/system/utilities.lua')

MP_201_tubeprop = Class(Prop) {
	
	RandomAnimPicker = function(self)
		local animPath = nil
		animNum = Utils.GetRandomInt(1,3)
		animPath = '/props/Structures/windmill/windmill_ASpin0' .. animNum .. '.sca'
		return animPath
	end,
	
    OnCreate = function(self)
        Prop.OnCreate(self)
		self:AddUserThreadAnimation( self:RandomAnimPicker(), 1, true )
    end,
}
TypeClass = MP_201_tubeprop
