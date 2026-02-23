--****************************************************************************
--**
--**  File     :  /lua/sim/buffs/armybonusdefinition.lua
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

ArmyBonusBlueprint {
	Name = 'PLACEHOLDER',

	Buffs = {
		BuffBlueprint {
			Name = 'PLACEHOLDER',
			DisplayName = 'Placeholder',
			BuffType = 'PLACEHOLDER',
			Stacks = 'REPLACE',
			Duration = -1,
			Affects = {
				Damage = {
					Add = 1000000,
				},
				MoveSpeed = {
					Add = 20,
				},
			},
		},
	},

	ApplyArmies = 'Single',
	UnitCategory = 'LAND',
}


__moduleinfo.auto_reload = true
