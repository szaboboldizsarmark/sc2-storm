-----------------------------------------------------------------------------
--  File     : /units/illuminate/uix0114/ucb0401D1_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 Cybran Mass Reclaimer: UCB0401D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local Unit = import('/lua/sim/Unit.lua').Unit
local Utils = import('/lua/system/utilities.lua')
local StopReclaimThread = nil

UCB0401D1 = Class(StructureUnit) {
	
	RecycleEffectBones = {
		'arm_fl',
		'arm_fr',
		'arm_cl',
		'arm_cr',
		'arm_bl',
		'arm_br',
    },
    
    RecycleEffects = {
		'/effects/emitters/units/cybran/ucb0401d1/ambient/cybran_recycler_05_debris_emit.bp',
		'/effects/emitters/units/cybran/ucb0401d1/ambient/cybran_recycler_02_electricity_emit.bp',
    },
    
	OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)

        self:ForkThread( self.AutoReclaim )
        self:InitAnimatedBones()
		self.AmbientEffectsBag = {}
		self.RecyclerEffects = {}
    end,

    CreateReclaimEffects = function( self, target )
        PlayReclaimEffects( self, target, self:GetBlueprint().General.Build.Bones.BuildEffectBones or {0,}, self.ReclaimEffectsBag )
    end,

    AutoReclaim = function(self)
        local unitBp = self:GetBlueprint()
        local aiBrain = self:GetAIBrain()

        while not self:IsDead() do
            if not self:IsUnitState('Reclaiming') and not self:IsStunned() then --and self:GetFireState() == 0 then

				local position = self:GetPosition()
				local fpSize = self:GetFootPrintSize()
				-- The + 30 is to give us a bit of a fudge factor for getting large debris further out.
				-- We will still check to make sure it is actually in range below.
				local radius = unitBp.Economy.MaxBuildDistance + fpSize + 30
				local x1 = position[1] - radius
				local x2 = position[1] + radius
				local z1 = position[3] - radius
				local z2 = position[3] + radius
				local rect = Rect( x1, z1, x2, z2 )
				local ents = GetReclaimablesInRect( rect )

                if not table.empty(ents) then
                    local sorted = SortEntitiesByDistanceXZ( position, ents )

                    -- order capture
                    for k,v in sorted do
                        if not v or not IsProp(v) or v:GetMassValue() <= 0 or not EntityCategoryContains( categories.RECLAIMABLE, v) then
                            continue
                        end
						
						local targFpSize = v:GetFootPrintSize()
						
						if Utils.XZDistanceTwoVectors(position, v:GetPosition()) > unitBp.Economy.MaxBuildDistance + fpSize + targFpSize + 1 then
							continue
						end
						
						local bp = v:GetBlueprint()
						
						-- If the wreckage has a rebuild bonus, don't auto reclaim it.
						if bp.Economy.AssociatedUnitBP != "" then
							continue
						end
						
                        IssueReclaim( {self}, v )
                        break
                    end
                end
            end
            WaitSeconds(1)
        end
    end,
    
    InitAnimatedBones = function(self)
		self.ArmBones = {
			{Bone = 'arm_fl',	Axis= 'x',	AngleOn = -55,	AngleOff = 0},
			{Bone = 'arm_cl',	Axis= 'x',	AngleOn = -55,	AngleOff = 0},	
			{Bone = 'arm_bl',	Axis= 'x',	AngleOn = -55,	AngleOff = 0},	
			{Bone = 'arm_fr',	Axis= 'x',	AngleOn = -55,	AngleOff = 0},	
			{Bone = 'arm_cr',	Axis= 'x',	AngleOn = -55,	AngleOff = 0},	
			{Bone = 'arm_br',	Axis= 'x',	AngleOn = -55,	AngleOff = 0},	
		}
		self.ShaftSpinner = CreateRotator(self, 'shaft_spin', 'x', nil, 0, 45 )
		self.Trash:Add( self.ShaftSpinner )
--PZ CreateSlider(unit, bone, [goal_x, goal_y, goal_z, [speed, [world_space]]])
		self.ShaftSlider = CreateSlider( self, 'shaft', -30,0,0, 25,false)
		self.Trash:Add( self.ShaftSlider )
		self.ArmRotators = {}
		for k, v in self.ArmBones do
			local rotator = CreateRotator(self, v.Bone, v.Axis, v.AngleOff, 30, 30, 90)
			table.insert( self.ArmRotators, { Rotator = rotator, AngleOn = v.AngleOn, AngleOff = v.AngleOff })
			self.Trash:Add( rotator )
		end
    end,
    
    ReclaimMode = function(self, bToggle)
    	if bToggle == true then
    		for k, v in self.ArmRotators do
    			v.Rotator:SetGoal(v.AngleOn)
    		end
    		self.ShaftSpinner:SetTargetSpeed(-180)
    		self.ShaftSlider:SetGoal(0,0,0)

			table.insert( self.RecyclerEffects, CreateAttachedEmitter( self, 'aim', self:GetArmy(), '/effects/emitters/units/cybran/ucb0401d1/ambient/cybran_recycler_01_rings_emit.bp' ) )		
			table.insert( self.RecyclerEffects, CreateAttachedEmitter( self, 'aim', self:GetArmy(), '/effects/emitters/units/cybran/ucb0401d1/ambient/cybran_recycler_06_top_electricity_emit.bp' ) )			
			table.insert( self.RecyclerEffects, CreateAttachedEmitter( self, 'shaft_spin', self:GetArmy(), '/effects/emitters/units/cybran/ucb0401d1/ambient/cybran_recycler_04_debris_ring_emit.bp' ) )
    		table.insert( self.RecyclerEffects, CreateAttachedEmitter( self, 'shaft_spin', self:GetArmy(), '/effects/emitters/units/cybran/ucb0401d1/ambient/cybran_recycler_03_line_emit.bp' ) )
    		
    		for kE, vE in self.RecycleEffects do
				for kB, vB in self.RecycleEffectBones do
					table.insert( self.RecyclerEffects, CreateAttachedEmitter( self, vB, self:GetArmy(), vE ) )
				end
			end
    	
    	elseif bToggle == false then
    		for k, v in self.ArmRotators do
    			v.Rotator:SetGoal(v.AngleOff)
    		end
    		self.ShaftSpinner:SetTargetSpeed(0)
    		self.ShaftSlider:SetGoal(-30,0,0)
    		self:DestroyRecyclerEffects()
    	else
    		LOG("ERROR: ReclaimMode Toggle is not a boolean")
    	end
    end,
    
    LReclaimStopDelay = function(self)
    	WaitSeconds(1.5)
    	self:ReclaimMode(false)
    end,
    
    OnStartReclaim = function( self, target )
    	Unit.OnStartReclaim( self, target )
    	if StopReclaimThread then
    		KillThread(StopReclaimThread)
    		StopReclaimThread = nil
    	end
    	self:ReclaimMode(true)
    end,
    
    OnStopReclaim = function( self, target )
    	Unit.OnStopReclaim( self, target )
    	StopReclaimThread = self:ForkThread(self.LReclaimStopDelay)
		self:DestroyRecyclerEffects()
    end,
    
    OnStunned = function(self,stunned)
		if stunned then
			IssueClearCommands({self})
			self:DestroyRecyclerEffects()
		end
    end,
    
    DestroyRecyclerEffects = function(self)
		if self.RecyclerEffects then
			for k, v in self.RecyclerEffects do
				v:Destroy()
			end
			self.RecyclerEffects = {}	
		end
	end,
}
TypeClass = UCB0401D1