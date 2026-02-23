-----------------------------------------------------------------------------
--  File     : /lua/sim/FactoryUnit.lua
--  Author(s): Gordon Duclos
--  Summary  : Base Factory Unit
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit

FactoryUnit = Class(StructureUnit) {

    OnCreate = function(self, createArgs)
        StructureUnit.OnCreate(self, createArgs)
        self.BuildingUnit = nil
		self.InRolloffAnim = false

		-- Initialize factory animset
		local animset = self:GetBlueprint().AnimSet
		if animset then
			self:PushAnimSet(animset, "Base");
		end
    end,

    --[[OnPaused = function(self)
        -- When factory is paused take some action
        self:StopUnitAmbientSound( 'ConstructLoop' )
		self:ChangeBlinkingLights('Yellow')
		if self.BuildingUnit then
			if self.InRolloffAnim then
				self:SendAnimEvent( 'SetPaused', 'true' )
			else
				local animset = self:GetBlueprint().AnimSet
				if animset.build_loop then 
					self:SendAnimEvent( 'SetLooping', 'false' )
				end
			end
			self:StopBuildingEffects(self.UnitBeingBuilt)			
		end
        StructureUnit.OnPaused(self)
    end,

    OnUnpaused = function(self)
        if self.BuildingUnit then
            self:PlayUnitAmbientSound( 'ConstructLoop' )
			self:ChangeBlinkingLights('Green')
			if self.InRolloffAnim then
				self:SendAnimEvent( 'SetPaused', 'false' )
			else
				local animset = self:GetBlueprint().AnimSet
				if animset.build_loop then 			
					self:SendAnimEvent( 'SetLooping', 'true' )
				end
			end
			self:StartBuildFx(unitBeingBuilt)
		else
			self:ChangeBlinkingLights('Red')
        end
        StructureUnit.OnUnpaused(self)
    end,]]--

    OnStopBeingBuilt = function(self,builder,layer)
        self:ChangeBlinkingLights('Red')
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    ChangeBlinkingLights = function(self, state)
		self:CreateBlinkingLights(state)
		self.BlinkingLightsState = state
    end,

    OnBuildIdle  = function(self)
		self.UnitBeingBuilt = nil
		self.BuildingUnit = nil
        self:ChangeBlinkingLights('Red')
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)
        self:DestroyBuildRotator()
		self.RolloffPoint = nil
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )
        StructureUnit.OnStartBuild(self, unitBeingBuilt, order )
       
		self.FactoryBuildFailed = false
			
		-- SC2 - adding upgrade module checks to factory units so that factories do the
		-- right thing, when they have upgrades. 
		if EntityCategoryContains(categories.UPGRADEMODULE, unitBeingBuilt) then
			self:AttachUpgradeUnit( unitBeingBuilt )
		else
			self:ChangeBlinkingLights('Green')
			self.BuildingUnit = unitBeingBuilt

			-- Make our unit being built untargetable and unable to take damage
			unitBeingBuilt:SetDoNotTarget(true)
			unitBeingBuilt:SetCanTakeDamage(false)
			unitBeingBuilt:SetUnSelectable(true)

			-- If we are currently in a rolloff animation, hide the new unit being built
			-- otherwise play the factory build animation
			if self.InRolloffAnim then
				unitBeingBuilt:HideMesh()
			else
				self:PlayBuildAnim()
			end

            local bp = self:GetBlueprint()
            local bone = 0
			if bp.Display.BuildAttachBone != "" then
				bone = bp.Display.BuildAttachBone
			end

            self:DetachAll(bone)
            unitBeingBuilt:AttachBoneTo(-2, self, bone)
			self:CalculateRollOffPoint(unitBeingBuilt)
            self:CreateBuildRotator()
            self:StartBuildFx(unitBeingBuilt)
		end
    end,

    OnFailedToBuild = function(self)
        self.FactoryBuildFailed = true
        StructureUnit.OnFailedToBuild(self)
        self:DestroyBuildRotator()
        self:StopBuildFx()

	    -- If we have failed to build, then stop our current build animation.
        local animset = self:GetBlueprint().AnimSet
		if not self.InRolloffAnim then
			local animset = self:GetBlueprint().AnimSet
			if animset then
				if animset.build_loop then 
					self:SendAnimEvent( 'SetLooping', 'false' )
				end
				if animset.reverse_start_build then
					self:SendAnimEvent( 'FailedReverseBuild' )
				end
			end
			
		end
        if self.InRolloffAnim then
            if animset and animset.reverse_finish_build then 
                self:SendAnimEvent( 'ReverseFinishBuild' )
            end
        end
        self:OnBuildIdle()
    end,

	OnBuildPreRelease = function(self, unitBeingBuilt )
		local animset = self:GetBlueprint().AnimSet

		-- Stop our looping build animation if we have one, otherwise play our finish building animation
		if animset and animset.finish_build then
			self:SendAnimEvent( 'FinishBuild' )
			self.InRolloffAnim = true
		else
			WARN( 'OnBuildPreRelease triggered with no Finish Build animation. A FinishBuildAnimDelay is specified without needing it or the factory has no animset with finish_build.' )
		end

		self:PlayUnitSound('ConstructOpen')
	end,

    OnStopBuild = function(self, unitBeingBuilt, order )
        StructureUnit.OnStopBuild(self, unitBeingBuilt, order )

		-- SC2 - adding upgrade module checks to factory units so that factories do the
		-- right thing, when they have upgrades. This will be replaced once I go through
		-- and clean up our content structure. - GD 10/16/2008
        if not self.FactoryBuildFailed and EntityCategoryContains(categories.UPGRADEMODULE, unitBeingBuilt) then
            table.insert( self.UpgradeUnits, unitBeingBuilt )
		elseif not self.FactoryBuildFailed and not EntityCategoryContains(categories.UPGRADEMODULE, unitBeingBuilt) then
			self.UnitBeingBuilt = nil
			if not EntityCategoryContains(categories.AIR, unitBeingBuilt) then
				self:RollOffUnit(unitBeingBuilt)
			end

			self:StopBuildFx()
			self:SetBusy(true)
			self:SetBlockCommandQueue(true)

			local delay = self:GetBlueprint().Build.FinishBuildRolloffDelay
			if delay then
				self:ForkThread(self.FinishBuildThread, delay)
			else
				self:FinishBuildThread()
			end
		end
    end,

	PlayBuildAnim = function(self)
		local animset = self:GetBlueprint().AnimSet
		if animset then
			if animset.start_build then
				self:SendAnimEvent( 'StartBuild' )
			elseif animset.build_loop then
				self:SendAnimEvent( 'BuildLoop' )
			else
				self:SendAnimEvent( 'BuildIdle' )
			end
		end
	end,

	PlayReverseRolloffAnim = function(self)
		local animset = self:GetBlueprint().AnimSet

		if animset and animset.reverse_finish_build then 
			self:SendAnimEvent( 'ReverseFinishBuild' )
			self.InRolloffAnim = true
		else
			self.InRolloffAnim = false
		end	
	end,

	OnAnimEndTrigger = function( self, event )
		if event == 'FinishBuild' then
			if self.FactoryBuildFailed then
				self:SendAnimEvent( 'StopBuild' )
			end
		elseif event == 'ReverseFinishBuild' then
			self.InRolloffAnim = false

			-- We've finished our reverse build animation and already started building.
			-- Just start up the build animation if we have one, and unhide the new unit
			-- being built.
			if self.BuildingUnit and not self.BuildingUnit:IsDead() then
				self.BuildingUnit:ShowMesh()
				self:PlayBuildAnim()
			end
		end
	end,

	FinishBuildThread = function( self, delay )
        if self.BuildingUnit and not self.BuildingUnit:IsDead() then
            self.BuildingUnit:DetachFrom(true)
			self.BuildingUnit:SetDoNotTarget(false)
			self.BuildingUnit:SetCanTakeDamage(true)
			self.BuildingUnit:SetUnSelectable(false)
        end

		self:DetachAll(self:GetBlueprint().Display.BuildAttachBone or 0)
        self:DestroyBuildRotator()	
		
		if delay then
			WaitSeconds(delay)
		end

		self:PlayReverseRolloffAnim()
		self:PlayUnitSound('ConstructClose')
		self:OnBuildIdle()
	end,

    RollOffUnit = function(self,unitBeingBuilt)
		-- Only issue a rolloff point move, if we have a valid rolloff point.
		if self.RolloffPoint then
			local currentRally = self:GetRallyPoint()
			local bp = self:GetBlueprint()
			local forceMoveToRolloffPoint = bp.Build.ForceMoveToRolloffPoint or false			

			-- If our rallypoint has changed, calc the new rallypoint position and re-rotate the unit.
			if currentRally and not forceMoveToRolloffPoint and VDist2Sq( self.RolloffPoint.Rally[1], self.RolloffPoint.Rally[3],  currentRally[1], currentRally[3] ) > 0 then
				self:CalculateRollOffPoint(unitBeingBuilt)
				self:DestroyBuildRotator()
				self:CreateBuildRotator()
			end

			local units = { unitBeingBuilt }
			self.MoveCommand = IssueMove(units, self.RolloffPoint.Position )
		end
    end,

    CalculateRollOffPoint = function(self,unitBeingBuilt)
		local bp = self:GetBlueprint()
        local bpRollOffPoints = bp.Physics.RollOffPoints
        local forceMoveToRolloffPoint = bp.Build.ForceMoveToRolloffPoint or false
        local px, py, pz = unpack(self:GetPosition())
        
        local storedRallyVec = self:GetRallyPoint()
		
        -- If we have no rolloff points, return waypoint position
		-- If the waypoint is close to the factory ( < 50grids, in squared space is 2500), return waypoint position
        if not bpRollOffPoints or (not forceMoveToRolloffPoint and VDist2Sq( px, pz, storedRallyVec[1], storedRallyVec[3] ) < 2500) then
        	self.RolloffPoint = { 
				Spin = 0,
				Position = { px, py, pz, },
				Rally = self:GetRallyPoint(),
			}
			return
		end
		
        local bpKey = 1

		-- Choose closest roll off point 
		local distance, lowest = nil
		for k, v in bpRollOffPoints do
			distance = VDist2Sq(storedRallyVec[1], storedRallyVec[3], v.X + px, v.Z + pz)
			if not lowest or distance < lowest then
				bpKey = k
				lowest = distance
			end
		end		

        local fx, fy, fz, spin
        local point = bpRollOffPoints[bpKey]
        local unitBP = unitBeingBuilt:GetBlueprint().Display.ForcedBuildSpin
        if unitBP then
            spin = unitBP
        else
            spin = point.UnitSpin
        end
        fx = point.X + px
        fy = point.Y + py
        fz = point.Z + pz

		self.RolloffPoint = { 
			Spin = spin, 
			Position = {
				fx, 
				fy, 
				fz, 
			},
			Rally = storedRallyVec,
		}
    end,

    StartBuildFx = function(self, unitBeingBuilt)
    end,

    StopBuildFx = function(self)
    end,

    PlayFxRollOff = function(self)
    end,

    PlayFxRollOffEnd = function(self)
        if self.RollOffAnim then
            self.RollOffAnim:SetRate(-1)
            WaitFor(self.RollOffAnim)
            self.RollOffAnim:Destroy()
            self.RollOffAnim = nil
        end
    end,

    CreateBuildRotator = function(self)
        if not self.BuildBoneRotator then
            local bone = 0
			local bp = self:GetBlueprint()
			if bp.Display.BuildAttachBone != "" then
				bone = bp.Display.BuildAttachBone
			end
            self.BuildBoneRotator = CreateRotator(self, bone, 'y', self.RolloffPoint.Spin, 10000)
            self.Trash:Add(self.BuildBoneRotator)
        end
    end,

    DestroyBuildRotator = function(self)
        if self.BuildBoneRotator then
            self.BuildBoneRotator:Destroy()
            self.BuildBoneRotator = nil
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        StructureUnit.OnKilled(self, instigator, type, overkillRatio)
        if self.UnitBeingBuilt then
            self.UnitBeingBuilt:Destroy()
        end
    end,

	OnGiveUnitUpgrade = function( self, unitUpgrade )
		self:AttachUpgradeUnit( unitUpgrade )
		table.insert( self.UpgradeUnits, unitUpgrade )
	end,

	AttachUpgradeUnit = function( self, unitUpgrade )
		-- SC2 - Attaches and sets up upgrade units attached to this structure
	
		local unitId = unitUpgrade:GetUnitId()

		-- Find slot
		local Upgrades = self:GetBlueprint().Upgrades
		if Upgrades == nil then 
			return
		end

		for kUpgradeSlot, vUpgradeSlot in Upgrades do
			for kUnitId, vUnitId in vUpgradeSlot.UpgradeUnits do
				if string.lower(vUnitId) == unitId then
					
					--LOG( 'Adding unit upgrade, slot= ', kUpgradeSlot, 'data= ', repr(vUpgradeSlot) )
					local boneIndex = AddUnitUpgrade( self:GetEntityId(), vUpgradeSlot, kUpgradeSlot, unitId )
					local bone = vUpgradeSlot.Bones[boneIndex]
					unitUpgrade:AttachBoneTo(-2, self, bone )

					-- Set upgrade parent, this is important so the upgrade unit will pass damage
					unitUpgrade.UpgradeParent = self
					return
				end
			end
		end

		LOG( 'Unit upgrade ', unitId, ' being built has no valid slot to be placed on unit ', self:GetUnitId(), '.' )
	end,
}