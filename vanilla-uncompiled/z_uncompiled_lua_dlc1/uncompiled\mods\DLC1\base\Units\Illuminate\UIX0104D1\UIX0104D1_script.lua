-----------------------------------------------------------------------------
--  File     :  /units/uef/UIX0104D1/UIX0104D1_script.lua
--  Author(s):  Mike Robbins
--  Summary  :  SC2 UEF Long Range Artillery: UIX0104D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local NukeWeapon = import('/lua/sim/DefaultWeapons.lua').NukeWeapon

UIX0104D1 = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
		self.Trash:Add( CreateRotator(self, 'upperring', 'y', nil, 0, 100, 100) )
        self.Trash:Add( CreateRotator(self, 'innerring', 'y', nil, 0, -100, -100) )
		self.Trash:Add( CreateRotator(self, 'lowerring', 'y', nil, 0, -100, -100) )
    end,

    Weapons = {
        EMP = Class(NukeWeapon) {},
    },
}
TypeClass = UIX0104D1