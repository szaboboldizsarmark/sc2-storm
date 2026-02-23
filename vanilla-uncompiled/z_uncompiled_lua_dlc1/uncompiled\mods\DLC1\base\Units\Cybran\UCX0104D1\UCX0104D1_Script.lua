-----------------------------------------------------------------------------
--  File     : /units/cybran/ucx0103/ucx0104D1_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 Cybran Experimental Bomb Bouncer: UCX0103
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local ExperimentalMobileUnit = import('/lua/sim/ExperimentalMobileUnit.lua').ExperimentalMobileUnit
local MobileUnit = import('/lua/sim/MobileUnit.lua').MobileUnit
local utilities = import('/lua/system/Utilities.lua')
local GetRandomFloat = utilities.GetRandomFloat

UCX0104D1 = Class(ExperimentalMobileUnit) {

    OnCreate = function(self, createArgs)
        ExperimentalMobileUnit.OnCreate(self, createArgs)
        self:InitSatBones()
        self.activatedEmitters = {}
        self.ambientEmitters = {}
		self.StealthOn = false
    end,
	
	-- Override the setup intel function so we don't enable the radar/sonar/cloak field when constructed.
    SetupIntel = function(self)
        local bp = self:GetBlueprint().Intel
        self:EnableIntel('Vision')
        if bp then
            self.IntelDisables = {
                Radar = 1,
                Sonar = 1,
                Omni = 1,
                RadarStealth = 1,
                SonarStealth = 1,
                RadarStealthField = 1,
                SonarStealthField = 1,
                Cloak = 1,
                CloakField = 1,
                Spoof = 1,
                Jammer = 1,
            }
            return true
        end
        return false
    end,
    
    InitSatBones = function(self)
    	self.SatBones = {
    		{Bone = 'sat_arm', 			Axis = 'y', AngleOn = -20, AngleOff = 65},
    		{Bone = 'sat_head', 		Axis = 'y', AngleOn = -15, AngleOff = 130},
    		--{Bone = 'sat_spin', 		Axis = 'x', AngleOn = 0, AngleOff = 0},
    		{Bone = 'sat_finger1_01', 	Axis = 'x', AngleOn = -20, AngleOff = -89},
    		{Bone = 'sat_finger1_02', 	Axis = 'x', AngleOn = -20, AngleOff = -99},
    		{Bone = 'sat_finger2_01', 	Axis = 'x', AngleOn = -20, AngleOff = -89},
    		{Bone = 'sat_finger2_02', 	Axis = 'x', AngleOn = -20, AngleOff = -99},
    		{Bone = 'sat_finger3_01', 	Axis = 'x', AngleOn = -20, AngleOff = -89},
    		{Bone = 'sat_finger3_02', 	Axis = 'x', AngleOn = -20, AngleOff = -99},
    		{Bone = 'sat_finger4_01', 	Axis = 'x', AngleOn = -20, AngleOff = -89},
    		{Bone = 'sat_finger4_02', 	Axis = 'x', AngleOn = -20, AngleOff = -99},
    		{Bone = 'sat_finger5_01', 	Axis = 'x', AngleOn = -20, AngleOff = -89},
    		{Bone = 'sat_finger5_02', 	Axis = 'x', AngleOn = -20, AngleOff = -99},
    		{Bone = 'sat_finger6_01', 	Axis = 'x', AngleOn = -20, AngleOff = -89},
    		{Bone = 'sat_finger6_02', 	Axis = 'x', AngleOn = -20, AngleOff = -99},
    	}
--PZ CreateRotator(unit, bone, axis, [goal], [startspeed], [accel], [goalspeed])
    	self.SatSpinner = CreateRotator(self, 'sat_spin', 'x', nil, 0, 20 )
    	self.SatRotators = {}
    	for k, v in self.SatBones do
    		local rotator = CreateRotator(self, v.Bone, v.Axis, v.AngleOff, 100, 90, 180 )
    		table.insert( self.SatRotators, { Rotator = rotator, AngleOn = v.AngleOn, AngleOff = v.AngleOff }) 
    		self.Trash:Add( rotator )
    	end
    end,
    
    SneakMode = function(self, bToggle)
    	if bToggle == true then
    		for k, v in self.SatRotators do
    			v.Rotator:SetGoal(v.AngleOn)
    		end
    		self.SatSpinner:SetTargetSpeed(180) 
			self:PlayUnitSound('Unpack')
    	elseif bToggle == false then
    		for k, v in self.SatRotators do
    			v.Rotator:SetGoal(v.AngleOff)
    		end
    		self.SatSpinner:SetTargetSpeed(0) 
			self:PlayUnitSound('Pack')
    	else
    		LOG("ERROR: SneakStance Toggle is not a boolean")
    	end
    	
    end,
    
    ActivationEffects = function(self)
	    WaitSeconds(1.7)
	    for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0104D1.Activate01 do
			table.insert( self.activatedEmitters, CreateAttachedEmitter( self, 'sat_head', self:GetArmy(), v ) )
		end
		for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0104D1.Activate02 do
			table.insert( self.activatedEmitters, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
		end
    end,
    
    OnIntelEnabled = function(self)
		if not self.StealthOn then
			self.StealthOn = true
			self:SneakMode(true)
			
			self:PlayUnitAmbientSound( 'CloakActive' )
			self:ForkThread(self.ActivationEffects)
		end
    end,

    OnIntelDisabled = function(self)
		if self.StealthOn then
			self.StealthOn = false
			if self.activatedEmitters then
				for k, v in self.activatedEmitters do
					v:Destroy()
				end
				self.activatedEmitters = {}
			end
			self:SneakMode(false)
			self:StopUnitAmbientSound( 'CloakActive' )
			
			for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0104D1.Deactivate01 do
				table.insert( self.activatedEmitters, CreateAttachedEmitter( self, -2, self:GetArmy(), v ) )
			end
		end
    end,
	
	OnAddToStorage = function(self, unit)
		if self.StealthOn then
			self:DisableIntel('CloakField')
			self:DisableIntel('RadarStealthField')
			self:DisableIntel('SonarStealthField')
			self:OnIntelDisabled()
		end
		ExperimentalMobileUnit.OnAddToStorage(self, unit)
	end,
	
	OnRemoveFromStorage = function(self, unit)
		if not self.StealthOn and self:IsAbilityActive('StealthField') and self:IsUnitAbilityState('StealthField', 'Activated') then
			self:EnableIntel('CloakField')
			self:EnableIntel('RadarStealthField')
			self:EnableIntel('SonarStealthField')
			self:OnIntelEnabled()
		end
		ExperimentalMobileUnit.OnRemoveFromStorage(self, unit)
	end,

	OnStopBeingBuilt = function(self,builder,layer)
		ExperimentalMobileUnit.OnStopBeingBuilt(self,builder,layer)
		
		for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0104D1.Ambient01 do
			table.insert( self.ambientEmitters, CreateAttachedEmitter( self, 'Root', self:GetArmy(), v ) )
		end
		
		self.SpinnerTarget = false
		self:ForkThread( self.SpinnerThread )
	end,
	
	OnKilled = function(self, instigator, type, overkillRatio)
		MobileUnit.OnKilled(self, instigator, type, overkillRatio)
		self:SneakMode(false)
	end,

    CreateFirePlumes = function( self, army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )
            velocity.x = velocity.x + GetRandomFloat(-0.3, 0.3)
            velocity.z = velocity.z + GetRandomFloat(-0.3, 0.3)
            velocity.y = velocity.y + GetRandomFloat( 0.0, 0.3)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, -2)):SetVelocity(utilities.GetRandomFloat(3, 4)):SetCollision(false)

            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/units/general/event/death/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = GetRandomFloat( 12, 22 )
        end
    end,
    
    DeathThread = function(self)
		-- Destroy idle animation
		if(self.Animator) then
			self.Animator:Destroy()
			self.Animator = false
		end

        self:PlayUnitSound('Destroyed')
        local army = self:GetArmy()

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'Root', army, v ):ScaleEmitter(0.2)
		end

        self:CreateFirePlumes( army, {'foot_fr', 'knee_bl', 'foot_br',}, 0.5 )
        WaitSeconds(0.5)
        self:CreateFirePlumes( army, {'foot_cl', 'knee_br', 'foot_bl',}, 0.5 )

        WaitSeconds(0.2)

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'Root', army, v ):ScaleEmitter(0.3)
		end
		
        WaitSeconds( 0.2 )

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'sat_arm', army, v ):ScaleEmitter(0.5)
		end
		
		self:CreateUnitDestructionDebris()
		        
        WaitSeconds(1.0)
        		        
        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death02 do
			CreateEmitterAtBone( self, 'Root', army, v ):ScaleEmitter(0.3)
		end
		
        self:ShakeCamera(20, 4, 1, 2.0)

		WaitSeconds( 0.5 )

        for k, v in EffectTemplates.Units.Cybran.Experimental.UCX0117d1.Death01 do
			CreateEmitterAtBone( self, -2, army, v )
		end

		local bp = self:GetBlueprint()
		local scale = (bp.SizeX + bp.SizeZ) * 1.5
		CreateDecal(self:GetPosition(),GetRandomFloat(0,2*math.pi),'/textures/Terrain/Decals/scorch_001_diffuse.dds', '', '', scale , scale, GetRandomFloat(200,350), GetRandomFloat(300,600), self:GetArmy(), 4 )

		local bp = self:GetUnitWeaponBlueprint('MegalithDeath')
		if bp then
			DamageArea(self, self:GetPosition(), bp.DamageRadius, bp.Damage, bp.DamageType, bp.DamageFriendly)
		end

        self:CreateWreckage()
        self:ShakeCamera(2, 1, 0, 0.03)

        self:Destroy()
    end,
}
TypeClass = UCX0104D1