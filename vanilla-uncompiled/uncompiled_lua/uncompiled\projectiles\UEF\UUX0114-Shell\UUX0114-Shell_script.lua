-----------------------------------------------------------------------------
--  File     :  /projectiles/UEF/UUX0114-Shell/UUX0114-Shell_script.lua
--  Author(s):  Gordon Duclos
--  Summary  :  UEF Unit Cannon Shell Projectile
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile

KILL_SHELL_HEIGHT = 12

UnitCannonShell01 = Class(Projectile) {

    ThrustEffects = {'/effects/emitters/weapons/uef/noah01/projectile/w_u_noah01_p_01_beam_emit.bp',},  
    
    ThrustEffects02 = {'/effects/emitters/weapons/uef/noah01/projectile/w_u_noah01_p_04_fire_emit.bp',},  
    
    ThrustBones = {
		'Jet01_REF',
		'Jet02_REF',
		'Jet03_REF',
		'Jet04_REF',
    },  
    
	OnCreate = function(self, inWater)
		Projectile.OnCreate(self, inWater)
		self:SetCanTakeDamage(false)
		self.UnitAmmo = nil
		local orient = self:GetOrientation()
		local pos = self:GetPosition()
		self.ShellEntity = CreateUnit( 'UUX0114-Shell', self:GetArmy(), pos[1], pos[2], pos[3], orient[1], orient[2], orient[3], orient[4] )
        self.ShellEntity:SetCanTakeDamage(false)
		self.ShellEntity:SetDoNotTarget(true)
		self.ShellEntity:SetUnSelectable(true)
		self.ShellEntity:SetCapturable(false)
        self:SetCollisionShape( 'Sphere', 0, 0, 0, 1 )
		self:ForkThread( self.HeightCheck )
	end,

	HeightCheck = function( self )
		local previousPos = table.copy(self:GetPosition())
		local currentPos
		while not self:BeenDestroyed() do
            WaitSeconds(0.1)
			currentPos = table.copy(self:GetPosition())
			if 0 > (currentPos[2] - previousPos[2]) and not self.ShellEntity:IsDead() then
				self:SetVelocityAlign(false)
				self.ShellEntity.Animator = CreateAnimator(self.ShellEntity)
				self.ShellEntity.Animator:PlayAnim('/projectiles/UEF/UUX0114-Shell/UUX0114-Shell_AOpen01.sca')
				WaitFor(self.ShellEntity.Animator)
				local army = self:GetArmy()

				for kBone, vBone in self.ThrustBones do
					for kEffect, vEffect in self.ThrustEffects do
						CreateBeamEmitterOnEntity(self.ShellEntity, vBone, army, vEffect)
					end
				end
				for kBone, vBone in self.ThrustBones do
					for kEffect, vEffect in self.ThrustEffects02 do
						CreateAttachedEmitter( self.ShellEntity, vBone, army, vEffect )
					end
				end
                self:ForkThread(self.LandingCheck)
				return
			end
			previousPos = currentPos
        end
	end,
    
    LandingCheck = function(self)    
        while not self:BeenDestroyed() and self.ShellEntity and not self.ShellEntity:IsDead() do
            WaitSeconds(0.1)
            local currentPos = table.copy(self:GetPosition())
            local terrainHeight = GetTerrainHeight(currentPos[1], currentPos[3])
            if GetSurfaceHeight(currentPos[1], currentPos[3]) . terrainHeight then  
                terrainHeight = GetTerrainHeight(currentPos[1], currentPos[3])
            end
            if currentPos[2] < KILL_SHELL_HEIGHT + terrainHeight then
				if self.ShellEntity and not self.ShellEntity:IsDead() then
					self.ShellEntity:Kill()
					self.ShellEntity = nil
				end
                if self.UnitAmmo and not self.UnitAmmo:IsDead() then
                    self.UnitAmmo:ShowMesh()
                    self.UnitAmmo:PlayAnimationLand()
                end                
                return
            end
        end
    end,
    
    OnImpact = function(self, targetType, targetEntity)
		if self.UnitAmmo and not self.UnitAmmo:IsDead() then
            self.UnitAmmo:SetOrientation(self:GetOrientation(), true)
            self.UnitAmmo:SetDoNotTarget(false)
            self.UnitAmmo:SetCanTakeDamage(true)
            self.UnitAmmo:SetUnSelectable(false)
			self.UnitAmmo:SetAttackerEnableState(true)
			self.UnitAmmo:SetCapturable(true)
            self.UnitAmmo:EnableShield()
			self.UnitAmmo:DetachFrom()
			self.UnitAmmo = nil
		end
        self:Destroy()
    end,
    
	AddAmmo = function( self, unit )
		self.UnitAmmo = unit
		self.ShellEntity:SetMesh( '/projectiles/UEF/UUX0114-Shell/UUX0114-Shell_mesh' )
		self.ShellEntity:AttachBoneTo(0, unit, -1 )
		self.ShellEntity:SetScale( 0.15 )
	end,
}
TypeClass = UnitCannonShell01