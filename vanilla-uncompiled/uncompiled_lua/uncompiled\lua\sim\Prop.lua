-----------------------------------------------------------------------------
--  File     : /lua/sim/Prop.lua
--  Author(s): Gordon Duclos
--  Summary  : The base Prop lua class
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Entity = import('/lua/sim/Entity.lua').Entity

Prop = Class(moho.prop_methods, Entity) {

    -- Do not call the base class __init and __post_init, we already have a c++ object
    __init = function(self,spec)
    end,

    __post_init = function(self,spec)
    end,

    OnCreate = function(self)
        Entity.OnCreate(self)
        self.CachePosition = self:GetPosition()

        local defense = self:GetBlueprint().Defense
        local maxHealth = 50
        if defense then
            maxHealth = math.max(maxHealth,defense.MaxHealth)
        end

        self:SetMaxHealth(maxHealth)
        self:SetHealth(self,maxHealth)
        if not EntityCategoryContains(categories.INVULNERABLE, self) then
            self:SetCanTakeDamage(true)
        else
            self:SetCanTakeDamage(false)
        end
        
        self:SetCanBeKilled(true)
        self:PlayPropAmbientSound('AmbientFire')

		local bp = self:GetBlueprint()
		local propAnim = bp.PropAnimation
		if propAnim and propAnim.AnimSCA then
			-- returns an anim ID
			self:AddUserThreadAnimation(propAnim.AnimSCA, propAnim.AnimRate, propAnim.Looping)
		end
    end,
    
    -- Sets if the unit can take damage.  val = true means it can take damage.
    -- val = false means it can't take damage
    SetCanTakeDamage = function(self, val)
        self.CanTakeDamage = val
    end,
    
    -- Sets if the unit can be killed.  val = true means it can be killed.
    -- val = false means it can't be killed
    SetCanBeKilled = function(self, val)
        self.CanBeKilled = val
    end,

    CheckCanBeKilled = function(self,other)
        return self.CanBeKilled
    end,

    OnKilled = function(self, instigator, type, exceessDamageRatio )
        if not self.CanBeKilled then return end
        self:Destroy()
    end,
    
    OnReclaimed = function(self, entity)
        self.CreateReclaimEndEffects( entity, self )        
        self:Destroy()
    end,
    
    CreateReclaimEndEffects = function( self, target )
        PlayReclaimEndEffects( self, target )
    end,    

    OnDestroy = function(self)
    end,

    OnDamage = function(self, instigator, amount, direction, damageType)
        if not self.CanTakeDamage then return end
        local preAdjHealth = self:GetHealth()
        self:AdjustHealth(instigator, -amount)
        local health = self:GetHealth()
        if( health <= 0 ) then
            if( damageType == 'Reclaimed' ) then
                self:Destroy()
            else
                local excessDamageRatio = 0.0
                -- Calculate the excess damage amount
                local excess = preAdjHealth - amount
                local maxHealth = self:GetMaxHealth()
                if(excess < 0 and maxHealth > 0) then
                    excessDamageRatio = -excess / maxHealth
                end
                self:Kill(instigator, damageType, excessDamageRatio)
            end
        end
    end,
 
    HandleDestructiveCollision = function(self, instigator)
		if self.HasFallen == true then
			return
		end	
		
		self.HasFallen = true
		
		local bp = self:GetBlueprint().Display
		if bp.CollisionMeshBP then
			self:SetMesh(bp.CollisionMeshBP)
		end
		if bp.FallingAnimationSet then
			-- apply a user-side anim that drops the tree in the required direction
			local orient = self:GetHeading()
			local impulseDir = self:GetIncidentHeadingToEntity(instigator) - orient
				
			impulseDir = (impulseDir * 180) / 3.14
		
			if impulseDir < 0 then
				impulseDir = impulseDir + 360
			end
		
			local animRate = 1.0
			
			if bp.FallingAnimationSet.AnimRate then
				animRate = bp.FallingAnimationSet.AnimRate
			end	
			
			if bp.FallingAnimationSet.AudioEvent then
				 self:PlaySound(bp.FallingAnimationSet.AudioEvent)
			end
			
			local animName
			if impulseDir  < 22 then animName = bp.FallingAnimationSet.d0
				elseif impulseDir < 67 then animName = bp.FallingAnimationSet.d315
				elseif impulseDir < 112 then animName = bp.FallingAnimationSet.d270
				elseif impulseDir < 157 then animName = bp.FallingAnimationSet.d225
				elseif impulseDir < 202 then animName = bp.FallingAnimationSet.d180
				elseif impulseDir < 247 then animName = bp.FallingAnimationSet.d135
				elseif impulseDir < 292 then animName = bp.FallingAnimationSet.d90
				elseif impulseDir < 333 then animName = bp.FallingAnimationSet.d45
				else animName = bp.FallingAnimationSet.d0
			end
			
			self:AddUserThreadAnimation(animName, animRate, false )
		end
    end,
  
    PlayPropSound = function(self, sound)
        local bp = self:GetBlueprint().Audio
        if bp and bp[sound] then
            self:PlaySound(bp[sound])
            return true
        end
        return false
    end,

    -- Play the specified ambient sound for the unit, and if it has AmbientRumble defined, play that too
    PlayPropAmbientSound = function(self, sound)
        if sound == nil then
            self:SetAmbientSound( nil, nil )
            return true
        else
            local bp = self:GetBlueprint().Audio
            if bp and bp[sound] then
                if bp.Audio['AmbientRumble'] then
                    self:SetAmbientSound( bp[sound], bp.Audio['AmbientRumble'] )
                else
                    self:SetAmbientSound( bp[sound], nil )
                end
                return true
            end
            return false
        end
    end,

    SetPropCollision = function(self, shape, centerx, centery, centerz, sizex, sizey, sizez, radius)
        self.CollisionRadius = radius
        self.CollisionSizeX = sizex
        self.CollisionSizeY = sizey
        self.CollisionSizeZ = sizez
        self.CollisionCenterX = centerx
        self.CollisionCenterY = centery
        self.CollisionCenterZ = centerz
        self.CollisionShape = shape
        if radius and shape == 'Sphere' then
            self:SetCollisionShape(shape, centerx, centery, centerz, sizex, sizey, sizez, radius)
        else
            self:SetCollisionShape(shape, centerx, centery, centerz, sizex, sizey, sizez)
        end
    end,

	-- Stub for non-wreckage prop decay, just in case a wreckage prop is
	-- inhererited incorrectly.
	StartDecay = function(self, decayTime)
	end,
}