--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

--****************************************************************************
--**
--**  File     :  /lua/sim/WeaponProp.lua
--**  Author(s):  Gautam Vasudevan
--**
--**  Summary  :  Weapon Prop definition
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local LightClass = import('/lua/system/class.lua').LightClass

-- this should derive from a render entity (user side only) when all is said and done
WeaponProp = LightClass 
{
    OnCreate = function( self, spec )
        self.spec = spec
	end,
	
	Initialize = function( self, owner )
		self.mOwner = owner
	end,
	
	SetEnabled = function( self, enable )
		if enable then
			self:UpdateAnimSet()
			--self:UpdateCostume(true)
		else
			--self:UpdateCostume(false)
		end
	end,	
	
	UpdateAnimSet = function( self )
		-- Get rid of any existing base anim set
		self.mOwner:PopAnimSet("Base");
		
		-- Set a random animation set
		local animsets = import(self.spec.AnimSets).AnimSets
		local animset = animsets[Random(1,table.getn(animsets))]
		
		self.mCurAnimset = animset
		self.mOwner:PushAnimSet( self.mCurAnimset.base, "Base")
	end,
	
	UpdateCostume = function( self, add )
		if not self.spec.CostumeSets then
			return
		end
		
		for _,costumeSet in self.spec.CostumeSets do
			if add then
				self.mOwner:AddCostumeSet(costumeSet, 'Dynamic')
			else
				self.mOwner:RemoveCostumeSet(costumeSet, 'Dynamic')
			end
		end
			
		self.mOwner:ApplyCostume()
	end,
	
	Destroy = function( self )
	end,
}
