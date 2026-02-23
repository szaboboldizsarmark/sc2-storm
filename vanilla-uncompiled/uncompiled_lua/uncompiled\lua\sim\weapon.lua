-----------------------------------------------------------------------------
--  File     :  /lua/sim/Weapon.lua
--  Author(s):  John Comes, Gordon Duclos
--  Summary  :  The base weapon class for all weapons in the game.
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Entity = import('/lua/sim/Entity.lua').Entity

Weapon = Class(moho.weapon_methods) {

	__init = function(self, unit)
		self.unit = unit
	end,

	OnCreate = function(self)
	end,

	HasTurret = function(self)
		return false
	end,

	AimManipulatorSetEnabled = function(self, enabled)
		if self.AimControl then
			self.AimControl:SetEnabled(enabled)
		end
	end,

	GetAimManipulator = function(self)
		return self.AimControl
	end,

	OnFire = function(self)
		local bp = self:GetBlueprint()
		if bp.Audio.Fire then
			self:PlaySound(bp.Audio.Fire)
		end
	end,
	
	OnHaltFire = function(self)
	end,

	OnEnableWeapon = function(self, enable)
	end,
	
	OnGotTarget = function(self)
		--LOG('Got the target')
		if self.DisabledFiringBones and self.unit.Animator then
			for key, value in self.DisabledFiringBones do
				self.unit.Animator:SetBoneEnabled(value, false)
			end
		end
	end,

	OnLostTarget = function(self)
		if self.DisabledFiringBones and self.unit.Animator then
			for key, value in self.DisabledFiringBones do
				self.unit.Animator:SetBoneEnabled(value, true)
			end
		end
	end,

	-- lua only
	OnStartTracking = function(self, label)
		self:PlayWeaponSound('BarrelStart')
		self:PlayWeaponAmbientSound('BarrelLoop')
	end,

	-- lua only?
	OnStopTracking = function(self, label)
		self:PlayWeaponSound('BarrelStop')
		self:StopWeaponAmbientSound('BarrelLoop')
		if EntityCategoryContains(categories.STRUCTURE, self.unit) then
			self.AimControl:SetResetPoseTime(9999999)
		end
	end,

	-- lua only?
	PlayWeaponSound = function(self, sound)
		local bp = self:GetBlueprint()
		if not bp.Audio[sound] then return end
		self:PlaySound(bp.Audio[sound])
	end,

	-- lua only?
	PlayWeaponAmbientSound = function(self, sound)
		local bp = self:GetBlueprint()
		if not bp.Audio[sound] then return end
		if not self.AmbientSounds then
			self.AmbientSounds = {}
		end
		if not self.AmbientSounds[sound] then
			local sndEnt = Entity {}
			self.AmbientSounds[sound] = sndEnt
			self.unit.Trash:Add(sndEnt)
			sndEnt:AttachTo(self.unit,-1)
		end
		self.AmbientSounds[sound]:SetAmbientSound( bp.Audio[sound], nil )
	end,

	-- lua only?
	StopWeaponAmbientSound = function(self, sound)
		if not self.AmbientSounds then return end
		if not self.AmbientSounds[sound] then return end
		local bp = self:GetBlueprint()
		if not bp.Audio[sound] then return end
		self.AmbientSounds[sound]:Destroy()
		self.AmbientSounds[sound] = nil
	end,

	-- lua only... called from CreateProjectileForWeapon and cybranweapons.lua
	GetDamageTable = function(self)
		local weaponBlueprint = self:GetBlueprint()
		local damageTable = {}
		damageTable.CriticalChance = self:GetCriticalChance()
		damageTable.CriticalDamageMultiplier = self:GetCriticalDamageMultiplier()
		damageTable.StunChance = self:GetStunChance()
		damageTable.StunDuration = self:GetStunDuration()
		damageTable.DamageRadius = self:GetDamageRadius()
		damageTable.DamageAmount = self:GetDamage()
		if weaponBlueprint.DamageAreaAmount then
			damageTable.DamageAreaAmount = weaponBlueprint.DamageAreaAmount
		end
		damageTable.DamageType = weaponBlueprint.DamageType
		damageTable.DamageFriendly = weaponBlueprint.DamageFriendly
		damageTable.DamageSelf = weaponBlueprint.DamageSelf
		if damageTable.DamageFriendly == nil then
			damageTable.DamageFriendly = false
		end
		damageTable.CollideFriendly = weaponBlueprint.CollideFriendly or false
		damageTable.DoTTime = weaponBlueprint.DoTTime
		damageTable.DoTPulses = weaponBlueprint.DoTPulses
		damageTable.KnockbackDistance = weaponBlueprint.KnockbackDistance
		damageTable.KnockbackDistanceRand = weaponBlueprint.KnockbackDistanceRand
		damageTable.KnockbackRadius = weaponBlueprint.KnockbackRadius
        damageTable.KnockbackScale = weaponBlueprint.KnockbackScale

		--LOG( 'Damage table, damage amount = ', damageTable.DamageAmount )
		return damageTable
	end,

	-- ugh nukes.  rework.
	CreateProjectileForWeapon = function(self, bone)
		local proj = self:CreateProjectile(bone)
		if proj and not proj:BeenDestroyed() then
			proj:PassDamageData( self:GetDamageTable() )
		end
		return proj
	end,

	OnDestroy = function(self)
	end,

	ForkThread = function(self, fn, ...)
		if fn then
			local thread = ForkThread(fn, self, unpack(arg))
			self.unit.Trash:Add(thread)
			return thread
		else
			return nil
		end
	end,

	--Method to mark weapon when parent unit gets loaded on to a transport unit
	SetOnTransport = function(self, transportstate)
		self.onTransport = transportstate
		if not transportstate then
			--send a message to tell the weapon that the unit just got dropped and needs to restart aim
			self:OnLostTarget()
		end
		--Disable weapon if on transport and not allowed to fire from it
		if not self.unit:GetBlueprint().Transport.CanFireFromTransport then
			if transportstate then
				self.WeaponDisabledOnTransport = true
				self:SetEnabled(false)
			else
				self:SetEnabled(true)
				self.WeaponDisabledOnTransport = false
			end
		end
	end,

	--Method to retreive onTransport information. True if the parent unit has been loaded on to a transport unit
	GetOnTransport = function(self)
		return self.onTransport
	end,


	-- Gets a random weapon anim with type
	GetRandomWeaponAnimOverride = function( self )
		-- Get the current animation set
		local curAnimset = self.weaponProp.mCurAnimset
		if not curAnimset or not curAnimset.weapon_set then
			return nil, nil
		end
		
		-- Return the type and anim from weapon set
		return table.getrandom(curAnimset.weapon_set)
	end,
}

TurretWeapon = Class( Weapon ) {

	OnCreate = function( self )
		local bp = self:GetBlueprint()
		if bp.Turreted == true then
			self:SetupTurret()
		else
			local rackBones = self:GetBlueprint().RackBones
			local num = table.getn(rackBones)
			if rackBones and rackBones[1].MuzzleBones then
				local muzzleBone = rackBones[1].MuzzleBones[1]
				self:SetWeaponBone(muzzleBone)
			end
		end

		Weapon.OnCreate( self )
	end,

	-- tougher to move into code, may still be possible.  Need to figure out what to do with AimControl, etc.
	SetupTurret = function( self )
		local bp = self:GetBlueprint()
		local yawBone = bp.TurretBoneYaw
		local pitchBone = bp.TurretBonePitch
		local muzzleBone = bp.TurretBoneMuzzle
		local precedence = bp.AimControlPrecedence or 10
		local pitchBone2
		local muzzleBone2
		if bp.TurretBoneDualPitch and bp.TurretBoneDualPitch != '' then
			pitchBone2 = bp.TurretBoneDualPitch
		end
		if bp.TurretBoneDualMuzzle and bp.TurretBoneDualMuzzle != '' then
			muzzleBone2 = bp.TurretBoneDualMuzzle
		end
		if not (self.unit:ValidateBone(yawBone) and self.unit:ValidateBone(pitchBone) and self.unit:ValidateBone(muzzleBone)) then
			error('*ERROR: Bone aborting turret setup due to bone issues.', 2)
			return
		elseif pitchBone2 and muzzleBone2 then
			if not (self.unit:ValidateBone(pitchBone2) and self.unit:ValidateBone(muzzleBone2)) then
				error('*ERROR: Bone aborting turret setup due to pitch/muzzle bone2 issues.', 2)
				return
			end
		end
		if yawBone and pitchBone and muzzleBone then
			if bp.TurretDualManipulators then
				self.AimControl = CreateAimController(self, 'Torso', yawBone)
				self.AimRight = CreateAimController(self, 'Right', pitchBone, pitchBone, muzzleBone)
				self.AimLeft = CreateAimController(self, 'Left', pitchBone2, pitchBone2, muzzleBone2)
				self.AimControl:SetEnabled(self:IsEnabled())
				self.AimRight:SetEnabled(self:IsEnabled())
				self.AimLeft:SetEnabled(self:IsEnabled())
				self.AimControl:SetPrecedence(precedence)
				self.AimRight:SetPrecedence(precedence)
				self.AimLeft:SetPrecedence(precedence)
				if EntityCategoryContains(categories.STRUCTURE, self.unit) then
					self.AimControl:SetResetPoseTime(9999999)
				end
				self:SetFireControl('Right')
				self.unit.Trash:Add(self.AimControl)
				self.unit.Trash:Add(self.AimRight)
				self.unit.Trash:Add(self.AimLeft)
			else
				self.AimControl = CreateAimController(self, 'Default', yawBone, pitchBone, muzzleBone)
				self.AimControl:SetEnabled(self:IsEnabled())
				if EntityCategoryContains(categories.STRUCTURE, self.unit) then
					self.AimControl:SetResetPoseTime(9999999)
				end
				self.unit.Trash:Add(self.AimControl)
				self.AimControl:SetPrecedence(precedence)
				if bp.RackSlavedToTurret and table.getn(bp.RackBones) > 0 then
					for k, v in bp.RackBones do
						if v.RackBone != pitchBone then
							local slaver = CreateSlaver(self.unit, v.RackBone, pitchBone)
							slaver:SetPrecedence(precedence-1)
							self.unit.Trash:Add(slaver)
						end
					end
				end
			end
		else
			error('*ERROR: Trying to setup a turreted weapon but there are yaw bones, pitch bones or muzzle bones missing from the blueprint.', 2)
		end

		local numbersexist = true
		local turretyawmin, turretyawmax, turretyawspeed
		local turretpitchmin, turretpitchmax, turretpitchspeed

		--SETUP MANIPULATORS AND SET TURRET YAW, PITCH AND SPEED
		if self:GetBlueprint().TurretYaw and self:GetBlueprint().TurretYawRange then
			turretyawmin, turretyawmax = self:GetTurretYawMinMax()
		else
			numbersexist = false
		end
		if self:GetBlueprint().TurretYawSpeed then
			turretyawspeed = self:GetTurretYawSpeed()
		else
			numbersexist = false
		end
		if self:GetBlueprint().TurretPitch and self:GetBlueprint().TurretPitchRange then
			turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
		else
			numbersexist = false
		end
		if self:GetBlueprint().TurretPitchSpeed then
			turretpitchspeed = self:GetTurretPitchSpeed()
		else
			numbersexist = false
		end
		if numbersexist then
			self.AimControl:SetFiringArc(turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
			if self.AimRight then
				self.AimRight:SetFiringArc(turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
			end
			if self.AimLeft then
				self.AimLeft:SetFiringArc(turretyawmin/12, turretyawmax/12, turretyawspeed, turretpitchmin, turretpitchmax, turretpitchspeed)
			end
		else
			local strg = '*ERROR: TRYING TO SETUP A TURRET WITHOUT ALL TURRET NUMBERS IN BLUEPRINT, ABORTING TURRET SETUP. WEAPON: ' .. self:GetBlueprint().Label .. ' UNIT: '.. self.unit:GetUnitId()
			error(strg, 2)
		end
	end,

	HasTurret = function(self)
		return self:GetBlueprint().Turreted or false
	end,

	SetTurretYawSpeed = function(self, speed)
		local turretyawmin, turretyawmax = self:GetTurretYawMinMax()
		local turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
		local turretpitchspeed = self:GetTurretPitchSpeed()
		if self.AimControl then
			self.AimControl:SetFiringArc(turretyawmin, turretyawmax, speed, turretpitchmin, turretpitchmax, turretpitchspeed)
		end
	end,

	SetTurretPitchSpeed = function(self, speed)
		local turretyawmin, turretyawmax = self:GetTurretYawMinMax()
		local turretpitchmin, turretpitchmax = self:GetTurretPitchMinMax()
		local turretyawspeed = self:GetTurretYawSpeed()
		if self.AimControl then
			self.AimControl:SetFiringArc(turretyawmin, turretyawmax, turretyawspeed, turretpitchmin, turretpitchmax, speed)
		end
	end,

	GetTurretYawMinMax = function(self)
		local halfrange = self:GetBlueprint().TurretYawRange
		local yaw = self:GetBlueprint().TurretYaw
		turretyawmin = yaw - halfrange
		turretyawmax = yaw + halfrange
		return turretyawmin, turretyawmax
	end,

	GetTurretYawSpeed = function(self)
		return self:GetBlueprint().TurretYawSpeed
	end,

	GetTurretPitchMinMax = function(self)
		local halfrange = self:GetBlueprint().TurretPitchRange
		local pitch = self:GetBlueprint().TurretPitch
		turretpitchmin = pitch - halfrange
		turretpitchmax = pitch + halfrange
		return turretpitchmin, turretpitchmax
	end,

	GetTurretPitchSpeed = function(self)
		return self:GetBlueprint().TurretPitchSpeed
	end,
}