-----------------------------------------------------------------------------
--  File     : /units/cybran/ucb0205D1/ucb0205D1_script.lua
--  Author(s): Mike Robbins
--  Summary  : SC2 Cybran Missile Launch/Defense Combo: UCB0205D1
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local StructureUnit = import('/lua/sim/StructureUnit.lua').StructureUnit
local Unit = import('/lua/sim/Unit.lua').Unit
local TurretWeapon = import('/lua/sim/weapon.lua').TurretWeapon

UCB0205D1 = Class(StructureUnit) {

  	BaseEffects01 = {
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_01_glow_emit.bp',
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_02_electricity_emit.bp',
	},
	TargetEffects01 = {
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_06_sparks_emit.bp',
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_07_electricity_emit.bp',
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_08_glow_emit.bp',
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_09_smoke_emit.bp',
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_10_ring_emit.bp',
		'/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_11_distortion_emit.bp',
	},

    Weapons = {
        NukeRedirector = Class(TurretWeapon) {
            OnFire = function(self)
                local target = self:GetCurrentTarget()

				if target.Redirected then
					return
				end

				if target.cachedLaunchPos then
					target.Redirected = true
					ForkThread(self.unit.RedirectNuke, self.unit, target, target.cachedLaunchPos)
				else
					ForkThread(self.unit.DestroyNuke, self.unit, target)
				end

				self.unit:RemoveAntiNukeSiloAmmo(1)
            end,
		},
    },

    OnCreate = function(self, createArgs)
    	StructureUnit.OnCreate(self, createArgs)
    	self:InitRotatorBones()
    end,

    InitRotatorBones = function(self)
		self.SatBones = {
			{Bone = 'sat_l_base',		Axis = 'z', AngleOn = 60, AngleOff = -179},
			{Bone = 'sat_l_arm',		Axis = 'x', AngleOn = -10, AngleOff = -50},
			{Bone = 'sat_l_neck',		Axis = 'x', AngleOn = 45, AngleOff = -75},
			--{Bone = 'sat_l_rotator',	Axis = 'z', AngleOn = 0, AngleOff = 0},
			{Bone = 'sat_l_point_01',	Axis = 'y', AngleOn = -30, AngleOff = -115},
			{Bone = 'sat_l_point_02',	Axis = 'y', AngleOn = -30, AngleOff = -115},
			{Bone = 'sat_l_point_03',	Axis = 'y', AngleOn = -30, AngleOff = -115},
			{Bone = 'sat_r_base',		Axis = 'z', AngleOn = -60, AngleOff = 179},
			{Bone = 'sat_r_arm',		Axis = 'x', AngleOn = -10, AngleOff = -50},
			{Bone = 'sat_r_neck',		Axis = 'x', AngleOn = 45, AngleOff = -75},
			--{Bone = 'sat_r_rotator',	Axis = 'z', AngleOn = 0, AngleOff = 0},
			{Bone = 'sat_r_point_01',	Axis = 'y', AngleOn = -30, AngleOff = -115},
			{Bone = 'sat_r_point_02',	Axis = 'y', AngleOn = -30, AngleOff = -115},
			{Bone = 'sat_r_point_03',	Axis = 'y', AngleOn = -30, AngleOff = -115},
		}
		self.SatSpinner01 = CreateRotator(self, 'sat_l_rotator', 'z', nil, 0, 20)
		self.SatSpinner02 = CreateRotator(self, 'sat_r_rotator', 'z', nil, 0, 20)
		self.BaseSpinner = CreateRotator(self, 'main_spinner', 'z', nil, 0, 50):SetTargetSpeed(30)

		self.Trash:Add( self.SatSpinner01 )
		self.Trash:Add( self.SatSpinner02 )
		self.Trash:Add( self.BaseSpinner )

		self.SatRotators = {}
		for k, v in self.SatBones do
			local rotator = CreateRotator(self, v.Bone, v.Axis, v.AngleOff, 50, 10, 100)
			table.insert( self.SatRotators, {Rotator = rotator, AngleOn = v.AngleOn, AngleOff = v.AngleOff} )
			self.Trash:Add( rotator )
		end
    end,

    RedirectMode = function(self, bToggle)
    	if bToggle == true then
    		for k, v in self.SatRotators do
    			v.Rotator:SetGoal(v.AngleOn)
    		end
    		self.SatSpinner01:SetTargetSpeed(120)
    		self.SatSpinner02:SetTargetSpeed(-120)
    	elseif bToggle == false then
    		for k, v in self.SatRotators do
    			v.Rotator:SetGoal(v.AngleOff)
    		end
    		self.SatSpinner01:SetTargetSpeed(0)
    		self.SatSpinner02:SetTargetSpeed(0)
    	else
    		LOG("ERROR: RedirectMode Toggle is not a boolean")
    	end
    end,

    OnSiloBuildStart = function(self, unitBeingBuilt, order )
    	LOG("PZ: BUILDING")
    	StructureUnit.OnSiloBuildStart(self, unitBeingBuilt, order )
    	self:RedirectMode(true)
    	self:PlayUnitAmbientSound( 'BuildingLoop' )
    end,

    OnSiloBuildEnd = function(self, unitBeingBuilt, order)
    	LOG("PZ: STOPPED BUILDING")
    	Unit.OnSiloBuildEnd(self, unitBeingBuilt, order )
    	self:RedirectMode(false)
		self:StopUnitAmbientSound( 'BuildingLoop' )
    end,

	DestroyNuke = function(self, target)
		-- Create our beam between base unit and target nuke entity
		local effects = {}
		table.insert( effects, AttachBeamEntityToEntity(self, 'muzzle', target, -1, army, '/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_beam_01_emit.bp' ) )

		-- Create emitters on beam end entity
		for _, v in self.TargetEffects01 do
			table.insert( effects, CreateAttachedEmitter(target, -1, army, v) )
		end

		WaitSeconds(1)
		for _, v in effects do
			v:Destroy()
		end
		target:Destroy()
	end,

	RedirectNuke = function(self, target, targetPos)
		local currentTarPos = target:GetCurrentTargetPosition()
		target:SetNewTargetGround({currentTarPos[1], 999999, currentTarPos[3]})
		target:SetTurnRate(125)

		-- Create our beam between base unit and target nuke entity
		local effects = {}
		table.insert( effects, AttachBeamEntityToEntity(self, 'muzzle', target, -1, army, '/effects/emitters/units/cybran/ucb0205d1/redirect/ucb0205d1_redirect_beam_01_emit.bp' ) )

		-- Create emitters on beam end entity
		for _, v in self.TargetEffects01 do
			table.insert( effects, CreateAttachedEmitter(target, -1, army, v) )
		end

		self:PlayUnitAmbientSound('OnRedirectLoop')

		WaitSeconds(4)
		self:StopUnitAmbientSound('OnRedirectLoop')
		for _, v in effects do
			v:Destroy()
		end

		target:SetNewTargetGround(targetPos)
		target:UpdateCachedTarget()
	end,
}
TypeClass = UCB0205D1