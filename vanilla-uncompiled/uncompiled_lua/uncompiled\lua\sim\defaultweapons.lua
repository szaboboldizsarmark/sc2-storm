-----------------------------------------------------------------------------
--  File     :  /lua/sim/defaultweapons.lua
--  Author(s):  Gordon Duclos
--  Summary  :  Default derived weapon definitions
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Weapons = import('/lua/sim/Weapon.lua')
local TurretWeapon = Weapons.TurretWeapon
local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local HitScanBeam = import('/lua/sim/HitScanBeam.lua').HitScanBeam
local Utilities = import('/lua/system/utilities.lua')

DefaultProjectileWeapon = Class(TurretWeapon) {

	PackingSetBusy = true,

	OnCreate = function(self)
		TurretWeapon.OnCreate(self)
		
		local bp = self:GetBlueprint()
		self.WeaponCanFire = true
		
		if bp.RackRecoilDistance != 0 then
			self:CreateRecoilManipulators()
		end
		
		if not bp.RackBones then
		   local strg = '*ERROR: No RackBones table specified, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
		   error(strg, 2)
		   return
		end

        for k,v in bp.RackBones do
            for _,boneName in v.MuzzleBones do
                self.unit:AddSparseBone(boneName)
            end
        end

		if not bp.MuzzleSalvoSize then
		   local strg = '*ERROR: No MuzzleSalvoSize specified, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
		   error(strg, 2)
		   return
		end
		
		if not bp.MuzzleSalvoDelay then
		   local strg = '*ERROR: No MuzzleSalvoDelay specified, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
		   error(strg, 2)
		   return
		end
		
		self.CurrentRackSalvoNumber = 1
		self.MuzzleSalvoSize = bp.MuzzleSalvoSize
		
		--Calculate recoil speed so that it finishes returning just as the next shot is ready.
		if bp.RackRecoilDistance != 0 then
			local dist = bp.RackRecoilDistance
			if bp.RackBones[1].TelescopeRecoilDistance then
				local tpDist = bp.RackBones[1].TelescopeRecoilDistance
				if math.abs(tpDist) > math.abs(dist) then
					dist = tpDist
				end
			end
			self.RackRecoilReturnSpeed = bp.RackRecoilReturnSpeed or math.abs( dist / (( 1 / bp.RateOfFire ) - (bp.MuzzleChargeDelay or 0))) * 1.25
		end

		--Error Checking
		self.NumMuzzles = 0
		for rk, rv in bp.RackBones do
			self.NumMuzzles = self.NumMuzzles + table.getn(rv.MuzzleBones or 0)
		end
		
		self.NumMuzzles = self.NumMuzzles / table.getn(bp.RackBones)
		local totalMuzzleFiringTime = (self.NumMuzzles - 1) * bp.MuzzleSalvoDelay
		
		if totalMuzzleFiringTime > (1 / bp.RateOfFire) then
			local strg = '*ERROR: The total time to fire muzzles is longer than the RateOfFire allows, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
			error(strg, 2)
			return false
		end
		
		if bp.RackRecoilDistance != 0 and bp.MuzzleSalvoDelay != 0 then
			local strg = '*ERROR: You can not have a RackRecoilDistance with a MuzzleSalvoDelay not equal to 0, aborting weapon setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
			error(strg, 2)
			return false
		end
		
		if bp.RenderFireClock then
			self.unit:SetWorkProgress(1)
		end
		
		ChangeState(self, self.IdleState)
	end,

	CreateProjectileAtMuzzle = function(self, muzzle)
		local proj = self:CreateProjectileForWeapon(muzzle)
		if not proj or proj:BeenDestroyed() then
			return nil
		end
		local bp = self:GetBlueprint()
		if bp.DetonatesAtTargetHeight == true then
			local pos = self:GetCurrentTargetPos()
			if pos then
				local theight = GetSurfaceHeight(pos[1], pos[3])
				local hght = pos[2] - theight
				proj:ChangeDetonateAboveHeight(hght)
			end
		end
		if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
			self:PlaySound(bp.Audio.FireUnderWater)
		elseif bp.Audio.Fire then
			self:PlaySound(bp.Audio.Fire)
		end
		return proj
	end,

	--Effect functions: Not only visual effects but also plays animations, recoil, etc.

	--PlayFxMuzzleSequence: Played when a muzzle is fired.  Mostly used for muzzle flashes
	PlayFxMuzzleSequence = function(self, muzzle)
		CreateWeaponMuzzleFlashEffect(self.unit, muzzle, self:GetBlueprint().MuzzleFlashEffect )
	end,

	--PlayFxMuzzleSequence: Played during the beginning of the MuzzleChargeDelay time when a muzzle in a rack is fired.
	PlayFxMuzzleChargeSequence = function(self, muzzle)
		CreateWeaponMuzzleFlashEffect(self.unit, muzzle, self:GetBlueprint().MuzzleChargeEffect )
	end,

	--PlayFxRackSalvoChargeSequence: Played when a rack salvo charges.  Do not put a wait in here or you'll
	--make the time value in the bp off.  Spawn another thread to do waits.
	PlayFxRackSalvoChargeSequence = function(self)
		local bp = self:GetBlueprint().RackChargeMuzzleFlash
		if bp then
			CreateWeaponMuzzleFlashEffect(self.unit, muzzle, bp)
			for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
				CreateWeaponMuzzleFlashEffect(self.unit, v, bp)
			end
		end
		if bp.Audio.ChargeStart then
			self:PlaySound(bp.Audio.ChargeStart)
		end
		if bp.AnimationCharge and not self.Animator then
			self.Animator = CreateAnimator(self.unit)
			self.Animator:PlayAnim(self:GetBlueprint().AnimationCharge):SetRate(bp.AnimationChargeRate or 1)
		end
	end,

	--PlayFxRackSalvoReloadSequence: Played when a rack salvo reloads.  Do not put a wait in here or you'll
	--make the time value in the bp off.  Spawn another thread to do waits.
	PlayFxRackSalvoReloadSequence = function(self)
		local bp = self:GetBlueprint()
		if bp.AnimationReload and not self.Animator then
			self.Animator = CreateAnimator(self.unit)
			self.Animator:PlayAnim(self:GetBlueprint().AnimationReload):SetRate(bp.AnimationReloadRate or 1)
		end
	end,

	--PlayFxRackSalvoReloadSequence: Played when a rack reloads. Mostly used for Recoil.
	PlayFxRackReloadSequence = function(self)
		local bp = self:GetBlueprint()
		if bp.CameraShakeRadius and bp.CameraShakeMax and bp.CameraShakeMin and bp.CameraShakeDuration and
			bp.CameraShakeRadius > 0 and bp.CameraShakeMax > 0 and bp.CameraShakeMin >= 0 and bp.CameraShakeDuration > 0 then
			self.unit:ShakeCamera(bp.CameraShakeRadius, bp.CameraShakeMax, bp.CameraShakeMin, bp.CameraShakeDuration)
		end
		if bp.ShipRock == true then
			local ix,iy,iz = self.unit:GetBoneDirection(bp.RackBones[self.CurrentRackSalvoNumber].RackBone)
			self.unit:RecoilImpulse(-ix,-iy,-iz)
		end
		if bp.RackRecoilDistance != 0 then
			self:PlayRackRecoil({bp.RackBones[self.CurrentRackSalvoNumber]})
		end
	end,

	--PlayFxWeaponUnpackSequence: Played when a weapon unpacks.  Here a wait is used because by definition a weapon
	--can not fire while packed up.
	PlayFxWeaponUnpackSequence = function(self)
		local bp = self:GetBlueprint()
		local unitBP = self.unit:GetBlueprint()
		if unitBP.Audio.Activate then
			self:PlaySound(unitBP.Audio.Activate)
		end
		if unitBP.Audio.Open then
			self:PlaySound(unitBP.Audio.Open)
		end
		if bp.Audio.Unpack then
			self:PlaySound(bp.Audio.Unpack)
		end
		if bp.WeaponUnpackAnimation and not self.UnpackAnimator then
			self.UnpackAnimator = CreateAnimator(self.unit)
			self.UnpackAnimator:PlayAnim(bp.WeaponUnpackAnimation):SetRate(0)
			self.UnpackAnimator:SetPrecedence(bp.WeaponUnpackAnimatorPrecedence or 0)
			self.unit.Trash:Add(self.UnpackAnimator)
		end
		if self.UnpackAnimator then
			self.UnpackAnimator:SetRate(bp.WeaponUnpackAnimationRate)
			WaitFor(self.UnpackAnimator)
		end
	end,

	--PlayFxWeaponPackSequence: Played when a weapon packs up.  It has no target and is done with all of its rack salvos
	PlayFxWeaponPackSequence = function(self)
		local bp = self:GetBlueprint()
		local unitBP = self.unit:GetBlueprint()
		if unitBP.Audio.Close then
			self:PlaySound(unitBP.Audio.Close)
		end
		if bp.WeaponUnpackAnimation and self.UnpackAnimator then
			self.UnpackAnimator:SetRate(-bp.WeaponUnpackAnimationRate)
		end
		if self.UnpackAnimator then
			WaitFor(self.UnpackAnimator)
		end
	end,
	
	CreateRecoilManipulators = function(self )
		local bp = self:GetBlueprint()
		self.RecoilManipulators = {}
		for k, v in bp.RackBones do
			local tmpSldr = CreateSlider(self.unit, v.RackBone)
			self.RecoilManipulators[v.RackBone] = tmpSldr
			tmpSldr:SetPrecedence(11)
			self.unit.Trash:Add(tmpSldr)
		end
	end,	


	PlayRackRecoil = function(self, rackList)
		local RackRecoilDistance = self:GetBlueprint().RackRecoilDistance
		for k, v in rackList do
			local manip = self.RecoilManipulators[v.RackBone]
			if manip then
				manip:SetGoal(0, 0, RackRecoilDistance)
				manip:SetSpeed(-1)
			end
		end
		
		self:ForkThread(self.PlayRackRecoilReturn, rackList)
	end,

	PlayRackRecoilReturn = function(self, rackList)
		WaitTicks(1)
		for k, v in rackList do
			local manip = self.RecoilManipulators[v.RackBone]
			if manip then
				manip:SetGoal(0, 0, 0)
				manip:SetSpeed(self.RackRecoilReturnSpeed)				
			end
		end	
	end,

	DestroyRecoilManips = function(self)
		local manips = self.RecoilManipulators
		if manips then
			for k, v in manips do
				v:Destroy()
			end
			self.RecoilManipulators = {}
		end
	end,

	--General State-less event handling
	OnLostTarget = function(self)
		TurretWeapon.OnLostTarget(self)
		local bp = self:GetBlueprint()
		if bp.WeaponUnpacks == true then
			ChangeState(self, self.WeaponPackingState)
		else
			ChangeState(self, self.IdleState)
		end
	end,

	OnDestroy = function(self)
		self:DestroyRecoilManips()
		ChangeState(self, self.DeadState)
	end,

	PackAndMove = function(self)
		ChangeState(self, self.WeaponPackingState)
	end,

	CanWeaponFire = function(self)
		if self.WeaponCanFire then
			return self.WeaponCanFire
		else
			return true
		end
	end,

	OnWeaponFired = function(self)
	end,

	OnEnableWeapon = function(self, enable)
		self:DestroyRecoilManips()
		if enable then
			self:CreateRecoilManipulators()
		end
	end,

	SetMuzzleSalvoSize = function(self, size )
		self.MuzzleSalvoSize = math.max( 1, size )
	end,

	-- WEAPON STATES:

	--Weapon is in idle state when it does not have a target and is done with any animations or unpacking.
	IdleState = State {
		WeaponWantEnabled = true,
		WeaponAimWantEnabled = true,

		Main = function(self)
			if self.unit:IsDead() then return end

			self.unit:SetBusy(false)
			local bp = self:GetBlueprint()
			--LOG('Weapon ', bp.Label .. ' entered IdleState.')
			if not bp.RackBones then
				error('Error on rackbones ' .. self.unit:GetUnitId() )
			end
			for k, v in bp.RackBones do
				if v.HideMuzzle == true then
					for mk, mv in v.MuzzleBones do
						self.unit:ShowBone(mv, true)
					end
				end
			end
			if table.getn(bp.RackBones) > 1 and self.CurrentRackSalvoNumber > 1 then
				WaitSeconds(self:GetBlueprint().RackReloadTimeout)
				self:PlayFxRackSalvoReloadSequence()
				self.CurrentRackSalvoNumber = 1
			end

		end,

		OnGotTarget = function(self)
			local bp = self:GetBlueprint()
			--LOG( 'Weapon ', bp.Label, ' IdleState: OnGotTarget, LockMotion= ', bp.WeaponUnpackLockMotion, ' Moving= ', self.unit:IsUnitState('Moving'), ' RequiresAmmo=', bp.RequiresAmmo, ' CanFire()=', self:CanFire(),  ' Unpacks= ', bp.WeaponUnpacks ) 
			if (bp.WeaponUnpackLockMotion != true or (bp.WeaponUnpackLocksMotion == true and not self.unit:IsUnitState('Moving'))) then
				if bp.RequiresAmmo == true and not self:CanFire() then
					return
				end
				if bp.WeaponUnpacks == true then
					self.unit:SetUnitState( 'Unpacking', true )
					ChangeState(self, self.WeaponUnpackingState)
				else
					if bp.RackSalvoChargeTime and bp.RackSalvoChargeTime > 0 then
						ChangeState(self, self.RackSalvoChargeState)
					else
						ChangeState(self, self.RackSalvoFireReadyState)
					end
				end
			end
		end,

		OnFire = function(self)
			local bp = self:GetBlueprint()
			--LOG( 'Weapon ', bp.Label, ' IdleState: OnFire, Unpacks = ', bp.WeaponUnpacks ) 
			if bp.WeaponUnpacks == true then
				ChangeState(self, self.WeaponUnpackingState)
			else
				if bp.RackSalvoChargeTime and bp.RackSalvoChargeTime > 0 then
					ChangeState(self, self.RackSalvoChargeState)
				elseif bp.SkipReadyState and bp.SkipReadyState == true then
					ChangeState(self, self.RackSalvoFiringState)
				else
					ChangeState(self, self.RackSalvoFireReadyState)
				end
			end
		end,

		OnLostTarget = function(self)
		end,
	},

	RackSalvoChargeState = State {
		WeaponWantEnabled = true,
		WeaponAimWantEnabled = true,

		Main = function(self)
			self.unit:SetBusy(true)
			local bp = self:GetBlueprint()
			self:PlayFxRackSalvoChargeSequence()
			--LOG('Weapon ' .. bp.Label .. ' entered RackSalvoChargeState.')
			if bp.NotExclusive then
				self.unit:SetBusy(false)
			end
			WaitSeconds(bp.RackSalvoChargeTime)
			if bp.NotExclusive then
				self.unit:SetBusy(true)
			end

			if bp.RackSalvoFiresAfterCharge == true then
				ChangeState(self, self.RackSalvoFiringState)
			else
				ChangeState(self, self.RackSalvoFireReadyState)
			end
		end,

		OnFire = function(self)
		end,
	},

	RackSalvoFireReadyState = State {
		WeaponWantEnabled = true,
		WeaponAimWantEnabled = true,

		Main = function(self)
			local bp = self:GetBlueprint()
			--LOG('Weapon ' .. bp.Label .. ' entered RackSalvoFireReadyState.')
			if (bp.RequiresAmmo == true and bp.WeaponUnpacks == true) then
				self.unit:SetBusy(true)
			else
				self.unit:SetBusy(false)
			end
			self.WeaponCanFire = true

			--We change the state on counted projectiles because we won't get another OnFire call.
			--The second part is a hack for units with reload animations.  They have the same problem
			--they need a RackSalvoReloadTime that's 1/RateOfFire set to avoid firing twice on the first shot
			if bp.RequiresAmmo == true or bp.AnimationReload or self.fireImmediately then
                --LOG('Weapon ' .. bp.Label .. ' Fire Immediately.')
                self.fireImmediately = false
				ChangeState(self, self.RackSalvoFiringState)
			end
		end,

		OnFire = function(self)
			--LOG('Weapon ' .. self:GetBlueprint().Label .. ' RackSalvoFireReadyState OnFire().')
			if self.WeaponCanFire then
				ChangeState(self, self.RackSalvoFiringState)
			end
		end,
	},

	-- This state handles most of the actual firing.  It's pretty crazy and delicately balanced, so take caution with it.
	RackSalvoFiringState = State {
		WeaponWantEnabled = true,
		WeaponAimWantEnabled = true,

		RenderClockThread = function(self, rof)
			local clockTime = rof
			local totalTime = clockTime
			while clockTime > 0.0 and not self:BeenDestroyed() and not self.unit:IsDead() do
				self.unit:SetWorkProgress( 1 - clockTime / totalTime )
				clockTime = clockTime - 0.1
				WaitSeconds(0.1)
			end
		end,

		Main = function(self)
			local bp = self:GetBlueprint()			
			local numRackFiring = self.CurrentRackSalvoNumber
			--LOG('Weapon ' .. bp.Label .. ' entered RackSalvoFiringState.')

			self.unit:SetBusy(true)

			--This is done to make sure that when racks fire together, they fire together.
			if bp.RackFireTogether == true then
				numRackFiring = table.getsize(bp.RackBones)
			end

			-- Fork timer counter thread carefully....
			if not self:BeenDestroyed() and
			   not self.unit:IsDead() then
				if bp.RenderFireClock and bp.RateOfFire > 0 then
					local rof = 1 / bp.RateOfFire
					self:ForkThread(self.RenderClockThread, rof)
				end
			end

			--Most of the time this will only run once, the only time it doesn't is when racks fire together.
			while self.CurrentRackSalvoNumber <= numRackFiring and not self.HaltFireOrdered do
				local rackInfo = bp.RackBones[self.CurrentRackSalvoNumber]
				local numMuzzlesFiring = self.MuzzleSalvoSize
				local muzzleIndex = 1

				if bp.MuzzleSalvoDelay == 0 then
					numMuzzlesFiring = table.getn(rackInfo.MuzzleBones)
				end

				-- Play audio trigger at the beginning of playing a rack salvo. An alternative sound cue used to
				-- decrease the number of indvidual fire sounds that trigger in CreateProjectileAtMuzzle.
				if bp.Audio.RackSalvoBeginFire then
					self:PlaySound(bp.Audio.RackSalvoBeginFire)
				end

				for i = 1, numMuzzlesFiring do

					if self.HaltFireOrdered then
						continue
					end

					local muzzle = rackInfo.MuzzleBones[muzzleIndex]

					if rackInfo.HideMuzzle == true then
						self.unit:ShowBone(muzzle, true)
					end

					if bp.MuzzleChargeDelay and bp.MuzzleChargeDelay > 0 then
						if bp.Audio.MuzzleChargeStart then
							self:PlaySound(bp.Audio.MuzzleChargeStart)
						end
						self:PlayFxMuzzleChargeSequence(muzzle)
						if bp.NotExclusive then
							self.unit:SetBusy(false)
						end
						WaitSeconds(bp.MuzzleChargeDelay)
						if bp.NotExclusive then
							self.unit:SetBusy(true)
						end
					end

					self:PlayFxMuzzleSequence(muzzle)

					if rackInfo.HideMuzzle == true then
						self.unit:HideBone(muzzle, true)
					end

					if self.HaltFireOrdered then
						continue
					end

					-- It is possible for a target to be lost during this sequence, and
					-- the result is, we need to valid the target having a valid position
					-- at this time.
					if not self:GetCurrentTargetPos() then
						continue
					end

					self:CreateProjectileAtMuzzle(muzzle)

					--Decrement the ammo if they are a counted projectile
					if bp.RequiresAmmo == true then
						if bp.NukeWeapon == true then
							self.unit:NukeCreatedAtUnit()
							self.unit:RemoveNukeSiloAmmo(1)
						else
							self.unit:RemoveAntiNukeSiloAmmo(1)
						end
					end

					muzzleIndex = muzzleIndex + 1

					if muzzleIndex > table.getn(rackInfo.MuzzleBones) then
						muzzleIndex = 1
					end

					if bp.MuzzleSalvoDelay > 0 then
						if bp.NotExclusive then
							self.unit:SetBusy(false)
						end
						WaitSeconds(bp.MuzzleSalvoDelay)
						if bp.NotExclusive then
							self.unit:SetBusy(true)
						end
					end
				end

				self:PlayFxRackReloadSequence()
				if self.CurrentRackSalvoNumber <= table.getn(bp.RackBones) then
					self.CurrentRackSalvoNumber = self.CurrentRackSalvoNumber + 1
				end
			end

			self:OnWeaponFired()

			-- We can fire again after reaching here
			self.HaltFireOrdered = false

			if self.CurrentRackSalvoNumber > table.getn(bp.RackBones) then
				self.CurrentRackSalvoNumber = 1
				if bp.RackSalvoReloadTime > 0 then
					ChangeState(self, self.RackSalvoReloadState)
				elseif bp.RackSalvoChargeTime > 0 then
					ChangeState(self, self.IdleState)
				elseif bp.RequiresAmmo == true and bp.WeaponUnpacks == true then
					ChangeState(self, self.WeaponPackingState)
				elseif bp.RequiresAmmo == true and not bp.WeaponUnpacks then
					ChangeState(self, self.IdleState)
				else
					ChangeState(self, self.RackSalvoFireReadyState)
				end
			elseif bp.RequiresAmmo == true and not bp.WeaponUnpacks then
				ChangeState(self, self.IdleState)
			elseif bp.RequiresAmmo == true and bp.WeaponUnpacks == true then
				ChangeState(self, self.WeaponPackingState)
			else
				ChangeState(self, self.RackSalvoFireReadyState)
			end
		end,

		OnLostTarget = function(self)
			TurretWeapon.OnLostTarget(self)
			local bp = self:GetBlueprint()
            --LOG('Weapon ' .. bp.Label .. ' entered OnLostTarget.')
			if bp.WeaponUnpacks == true then
				ChangeState(self, self.WeaponPackingState)
			end
		end,

		-- Set a bool so we won't fire if the target reticle is moved
		OnHaltFire = function(self)
			self.HaltFireOrdered = true
		end,
	},

	RackSalvoReloadState = State {
		WeaponWantEnabled = true,
		WeaponAimWantEnabled = true,

		Main = function(self)
			self.unit:SetBusy(true)
			local bp = self:GetBlueprint()
			--LOG('Weapon ' .. bp.Label .. ' entered RackSalvoReloadState.')
			self:PlayFxRackSalvoReloadSequence()
			if bp.NotExclusive then
				self.unit:SetBusy(false)
			end
			WaitSeconds(bp.RackSalvoReloadTime)
			if bp.NotExclusive then
				self.unit:SetBusy(true)
			end
			if self:WeaponHasTarget() and bp.RackSalvoChargeTime > 0 and self:CanFire() then
				ChangeState(self, self.RackSalvoChargeState)
			elseif self:WeaponHasTarget() and self:CanFire() then
				ChangeState(self, self.RackSalvoFireReadyState)
			elseif not self:WeaponHasTarget() and bp.WeaponUnpacks == true and bp.WeaponUnpackLocksMotion != true then
				ChangeState(self, self.WeaponPackingState)
			else
				ChangeState(self, self.IdleState)
			end
		end,

		OnFire = function(self)
		end,
	},

	WeaponUnpackingState = State {
		WeaponWantEnabled = false,
		WeaponAimWantEnabled = false,

		Main = function(self)
			if self.PackingSetBusy then
				self.unit:SetBusy(true)
			end
			local bp = self:GetBlueprint()
			--LOG('Weapon ' .. bp.Label .. ' entered WeaponUnpackingState.')

			if bp.WeaponUnpackLocksMotion then
				self.unit:SetImmobile(true)
			end

			self:PlayFxWeaponUnpackSequence()
			self.unit:SetUnitState( 'Unpacking', false )
			self:AimManipulatorSetEnabled(true)
			local rackSalvoChargeTime = self:GetBlueprint().RackSalvoChargeTime
			if rackSalvoChargeTime and rackSalvoChargeTime > 0 then
				ChangeState(self, self.RackSalvoChargeState)
			else
				ChangeState(self, self.RackSalvoFireReadyState)
			end
		end,

		OnFire = function(self)
			--LOG( 'WeaponUnpackingState OnFire ', self:GetBlueprint().Label )
            -- Unpacking weapons end up getting a Fire() order while unpacking and wont get another one
            -- until the fire clock resets. This causes a delay before the first shot is fired.
            -- This flag is set to combat that. - Sorian
            self.fireImmediately = true
		end,
	},

	WeaponPackingState = State {
		WeaponWantEnabled = true,
		WeaponAimWantEnabled = true,

		Main = function(self)
			if self.PackingSetBusy then
				self.unit:SetBusy(true)
			end
			local bp = self:GetBlueprint()
			--LOG('Weapon ' .. bp.Label .. ' entered WeaponPackingState.')
			WaitSeconds(bp.WeaponRepackTimeout)
			self:AimManipulatorSetEnabled(false)
			self:PlayFxWeaponPackSequence()
			if bp.WeaponUnpackLocksMotion then
				self.unit:SetImmobile(false)
			end
			ChangeState(self, self.IdleState)
		end,

		OnGotTarget = function(self)
			if not self:GetBlueprint().ForceSingleFire then
				ChangeState(self, self.WeaponUnpackingState)
			end
		end,

		-- Override so that it doesn't play the firing sound when
		-- we're not actually creating the projectile yet
		OnFire = function(self)
			local bp = self:GetBlueprint()
			if bp.RequiresAmmo and not bp.ForceSingleFire then
				ChangeState(self, self.WeaponUnpackingState)
			end
		end,
	},

	DeadState = State {
		OnEnterState = function(self)
		end,

		Main = function(self)
		end,

		OnLostTarget = function(self)
		end,
	},
}

-- this can live in code easily
BareBonesWeapon = Class(Weapons.Weapon) {
	Data = {},

	OnCreate = function(self)
		local bp = self:GetBlueprint()
		if bp.MuzzleBones then
			for mk, mv in bp.MuzzleBones do
				-- add sparse bone so it animates on the sim
				self.unit:AddSparseBone(mv)
			end
		end
		Weapons.Weapon.OnCreate( self )
	end,

	OnFire = function(self)
		local myBlueprint = self:GetBlueprint()
		local myProjectile = self.unit:CreateProjectile( myBlueprint.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
		if self.Data then
			myProjectile:PassData(self.Data)
		end
	end,
}

-- this can live in code easily
DefaultMeleeWeapon = Class(Weapons.Weapon) {
	Data = {},

	OnCreate = function(self)
		local bp = self:GetBlueprint()
		if bp.MuzzleBones then
			for mk, mv in bp.MuzzleBones do
				-- add sparse bone so it animates on the sim
				self.unit:AddSparseBone(mv)
			end
		end
		Weapons.Weapon.OnCreate( self )
	end,

	CanWeaponFire = function(self)
		if self.WeaponCanFire then
			return self.WeaponCanFire
		else
			return true
		end
	end,

	FireMelee = function( self )
		local bp = self:GetBlueprint()
		local unit = self.unit
		local damage = self:GetDamage()

		-- The GetCurrentTarget may return a unit or a blip
		-- If it's a blip we need to get the blip's source (the actual unit)
		local target = self:GetCurrentTarget()
		local realTarget = target
		if realTarget and not IsUnit(realTarget) then
			realTarget = realTarget:GetSource()
		end

		-- get damage dir if it exists

		local animVariation, animName = self:GetRandomWeaponAnimOverride()

		if animVariation and animName then
			unit:PushAnimPack( "attack_normal", animName, "Override")
			self.unit.LastAttackVariation = animVariation
		end

		-- Play attack animation
		unit:SendAnimEvent( (bp.AbilityType or "Weapon") .. "Fired" )

		if animVariation and animName then
			unit:PopAnimPack( "attack_normal", "Override" )
		end
		
		-- Play a fire weapon sound
		if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
			self:PlaySound(bp.Audio.FireUnderWater)
		elseif bp.Audio.Fire then
			self:PlaySound(bp.Audio.Fire)
		end

		if bp.WeaponFireDelay then
			WaitSeconds( bp.WeaponFireDelay )
		end

		if self.unit:IsDead() then return end

		-- No target to deal damage to so return. This is not done at
		--  function start because despite have
		if not realTarget or realTarget:IsDead() then
			return
		end

		if Random(1,100) < self:GetCriticalChance() then
			damage = math.floor( damage * self:GetCriticalDamageMultiplier() )
		end

		if Random(1,100) < self:GetStunChance() then
			realTarget:SetStunned(self:GetStunDuration())
		end

		if( bp.DamageRadius > 0 ) then
			-- have damage point not be exactly where the unit is, but slightly before it
			-- I hope this code goes away, trying to do this in Lua is dumb.
			local unitPos = unit:GetPosition()
			local targetPos = realTarget:GetPosition()
			local dmgPos = Vector((targetPos.x - unitPos.x) * 0.75 + unitPos.x, 
								(targetPos.y - unitPos.y)* 0.75 + unitPos.y, 
								(targetPos.z - unitPos.z)* 0.75 + unitPos.z);
			local num = DamageArea( unit, dmgPos, bp.DamageRadius, bp.DamageAreaAmount, bp.DamageAreaType, bp.DamageFriendly )
			--LOG( 'Damaged ', num, ' units!')
		else
			Damage( unit, unit:GetPosition(), realTarget, damage, bp.DamageType )
		end
		
		if( bp.KnockbackDistance > 0 and realTarget.PerformKnockback) then
			local randRange = bp.KnockbackDistanceRand or 0
			
			if not bp.KnockbackRadius then
				realTarget:PerformKnockback( unit, bp.KnockbackDistance + Utilities.GetRandomFloat(-randRange, randRange), (bp.KnockbackScale or 5) )
			else
				local brain = unit:GetAIBrain()
				local units = brain:GetUnitsAroundPoint( categories.LAND * categories.MOBILE, realTarget:GetPosition(), bp.KnockbackRadius, 'Enemy' )
				
				for index,enemyUnit in units do
					if enemyUnit.PerformKnockback then
						enemyUnit:PerformKnockback( unit, bp.KnockbackDistance + Utilities.GetRandomFloat(-randRange, randRange), (bp.KnockbackScale or 5) )
					end
				end
			end
		end
		
		self:OnWeaponFired()
	end,

	OnFire = function(self)
		ForkThread( self.FireMelee, self )
	end,

	OnWeaponFired = function(self )
	end,
}


DefaultBeamWeapon = Class(DefaultProjectileWeapon) {

	BeamType = CollisionBeam,

	OnCreate = function(self)
		self.Beams = {}
		local bp = self:GetBlueprint()
		if not bp.BeamCollisionDelay then
			local strg = '*ERROR: No BeamCollisionDelay specified for beam weapon, aborting setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
			error(strg, 2)
			return
		end
		if not bp.BeamLifetime then
			local strg = '*ERROR: No BeamLifetime specified for beam weapon, aborting setup.  Weapon: ' .. bp.DisplayName .. ' on Unit: ' .. self.unit:GetUnitId()
			error(strg, 2)
			return
		end
		for rk, rv in bp.RackBones do
			for mk, mv in rv.MuzzleBones do
				local beam
				beam = self.BeamType{
					Weapon = self,
					BeamBone = 0,
					OtherBone = mv,
					CollisionCheckInterval = bp.BeamCollisionDelay * 10,
				}
				local beamTable = { Beam = beam, Muzzle = mv, Destroyables = {} }
				table.insert(self.Beams, beamTable)
				self.unit.Trash:Add(beam)
				beam:SetParentWeapon(self)
				beam:Disable()
			end
		end
		DefaultProjectileWeapon.OnCreate(self)
	end,

	CreateProjectileAtMuzzle = function(self, muzzle)
		--LOG('*DEBUG: DefaultBeamWeapon CreateProjectileAtMuzzle, Weapon = ', self:GetBlueprint().Label, ' Muzzle = ', muzzle, ' Time = ', GetGameTimeSeconds())
		local enabled = false
		for k, v in self.Beams do
			if v.Muzzle == muzzle and v.Beam:IsEnabled() then
				enabled = true
			end
		end
		if not enabled then
			self:PlayFxBeamStart(muzzle)
		end
		local bp = self:GetBlueprint()
		if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
			self:PlaySound(bp.Audio.FireUnderWater)
		elseif bp.Audio.Fire then
			self:PlaySound(bp.Audio.Fire)
		end

	end,

	PlayFxBeamStart = function(self, muzzle)
		local army = self.unit:GetArmy()
		local bp = self:GetBlueprint()
		self.BeamDestroyables = {}
		local beam
		local beamTable
		for k, v in self.Beams do
			if v.Muzzle == muzzle then
				beam = v.Beam
				beamTable = v
			end
		end
		if not beam then
			error('*ERROR: We have a beam created that does not coincide with a muzzle bone.  Internal Error, aborting beam weapon.', 2)
			return
		end
		if beam:IsEnabled() then return end
		beam:Enable()
		self.unit.Trash:Add(beam)
		if bp.BeamLifetime > 0 then
			self:ForkThread(self.BeamLifetimeThread, beam, bp.BeamLifetime or 1)
		end
		if bp.BeamLifetime == 0 then
			self.HoldFireThread = self:ForkThread(self.WatchForHoldFire, beam)
		end
		if bp.Audio.BeamStart then
			self:PlaySound(bp.Audio.BeamStart)
		end
		if bp.Audio.BeamLoop and self.Beams[1].Beam then
			self.Beams[1].Beam:SetAmbientSound(bp.Audio.BeamLoop, nil)
		end
		self.BeamStarted = true
	end,

	PlayFxWeaponUnpackSequence = function(self)
		local bp = self:GetBlueprint()
		-- if it's not a continuous beam, or  if it's a continuous beam that's off...
		if (bp.BeamLifetime > 0) or ((bp.BeamLifetime <= 0) and not self.ContBeamOn) then
			DefaultProjectileWeapon.PlayFxWeaponUnpackSequence(self)
		end
	end,

	IdleState = State (DefaultProjectileWeapon.IdleState) {
		Main = function(self)
			DefaultProjectileWeapon.IdleState.Main(self)
			self:PlayFxBeamEnd()
			self:ForkThread(self.ContinuousBeamFlagThread)
		end,
	},

	WeaponPackingState = State (DefaultProjectileWeapon.WeaponPackingState) {
		Main = function(self)
			local bp = self:GetBlueprint()
			-- if not a continuous beam...
			if (bp.BeamLifetime > 0) then
				self:PlayFxBeamEnd()
			else
				self.ContBeamOn = true
			end
			DefaultProjectileWeapon.WeaponPackingState.Main(self)
		end,
	},

	PlayFxBeamEnd = function(self, beam)
		if not self.unit:IsDead() then
			local bp = self:GetBlueprint()
			if bp.Audio.BeamStop and self.BeamStarted then
				self:PlaySound(bp.Audio.BeamStop)
			end
			if bp.Audio.BeamLoop and self.Beams[1].Beam then
				self.Beams[1].Beam:SetAmbientSound(nil, nil)
			end
			if beam then
				beam:Disable()
			else
				for k, v in self.Beams do
					v.Beam:Disable()
				end
			end
			self.BeamStarted = false
		end
		if self.HoldFireThread then
			KillThread(self.HoldFireThread)
		end
	end,

	ContinuousBeamFlagThread = function(self)
		WaitTicks(1)
		self.ContBeamOn = false
	end,

	BeamLifetimeThread = function(self, beam, lifeTime)
		WaitSeconds(lifeTime)
		self:PlayFxBeamEnd(beam)
	end,

	WatchForHoldFire = function(self, beam)
		while true do
			WaitSeconds(1)
			--if we're at hold fire, stop beam
			if self.unit and self.unit:GetFireState() == 1 then
				self.BeamStarted = false
				self:PlayFxBeamEnd(beam)
			end
		end
	end,

	OnHaltFire = function(self)
		for k,v in self.Beams do
			-- Only halt fire on the beams that are currently enabled
			if not v.Beam:IsEnabled() then
				continue
			end

			self:PlayFxBeamEnd( v.Beam )
		end
	end,

	RackSalvoFireReadyState = State (DefaultProjectileWeapon.RackSalvoFireReadyState) {
		Main = function(self)
			DefaultProjectileWeapon.RackSalvoFireReadyState.Main(self)
		end,
	},
}


NukeWeapon = Class(DefaultProjectileWeapon) {

	CreateProjectileForWeapon = function(self, bone)
		local proj = DefaultProjectileWeapon.CreateProjectileForWeapon(self, bone)
		if proj and not proj:BeenDestroyed() then
			local bp = self:GetBlueprint()
			if bp.NukeData then
				proj:PassData(bp.NukeData)
			end
		end
		return proj
	end,
}