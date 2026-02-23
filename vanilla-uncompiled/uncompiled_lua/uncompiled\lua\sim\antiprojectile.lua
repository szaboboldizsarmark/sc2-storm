-----------------------------------------------------------------------------
--  File     :  /lua/defaultantimissile.lua
--  Author(s):  Gordon Duclos
--  Summary  :  Anti missile classes
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Entity = import('/lua/sim/Entity.lua').Entity

Flare = Class(Entity) {

    OnCreate = function(self, spec)
        self.Owner = spec.Owner
        self.Radius = spec.Radius or 5
        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetCollisionTestType('Script')
        self:SetDrawScale(self.Radius)
        self:AttachTo(spec.Owner, -1)
        self.RedirectCat = spec.RedirectCat or 'MISSILE ANTIAIR'
        self.RedirectCount = spec.RedirectCount or 3
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)
        return false
    end,

    -- We only divert projectiles. The flare-projectile itself will be responsible for
    -- accepting the collision and causing the hostile projectile to impact.
    OnProjectileCollisionCheck = function(self,other)
        if (self.RedirectCount != -1 and self.RedirectCount > 0)
                and EntityCategoryContains(ParseEntityCategory(self.RedirectCat), other)
                and (self:GetArmy() != other:GetArmy())then

            --LOG('*DEBUG FLARE COLLISION CHECK - success')
            other:SetNewTarget(self.Owner)
            other:TrackTarget(true)
            other:SetMaxSpeed(10)
            other:SetTurnRate(720)

            -- update redirect count if we don't have infinite redirects
            if self.RedirectCount != -1 then
                self.RedirectCount = self.RedirectCount - 1

                -- we disable collision tests on the flare if we can not longer redirect
                if self.RedirectCount == 0 then
                    self:SetCollisionTestType('None')
                end
            end
        end
        return false
    end,
}

DepthCharge = Class(Flare) {

    OnCreate = function(self, spec)
        Flare.OnCreate(self, spec)
        self.RedirectCat = spec.Category or 'TORPEDO'
    end,
}

MissileRedirect = Class(Entity) {

    RedirectBeams = {'/effects/emitters/ambient/units/particle_cannon_beam_02_emit.bp'},
    EndPointEffects = {'/effects/emitters/ambient/units/particle_cannon_end_01_emit.bp',},

    --AttachBone = function( AttachBone )
    --    self:AttachTo(spec.Owner, self.AttachBone)
    --end,

    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)
        --LOG('*DEBUG MISSILEREDIRECT START BEING CREATED')
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1
        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetCollisionTestType('Script')
        self:SetDrawScale(self.Radius)
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
        ChangeState(self, self.WaitingState)
        --LOG('*DEBUG MISSILEREDIRECT DONE BEING CREATED')
    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        ChangeState(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.

    WaitingState = State{
        OnProjectileCollisionCheck = function(self, other)
            --LOG('*DEBUG MISSILE REDIRECT COLLISION CHECK')
            if EntityCategoryContains(categories.MISSILE, other) and not EntityCategoryContains(categories.STRATEGIC, other)
                        and other != self.EnemyProj and IsEnemy( self:GetArmy(), other:GetArmy() ) then
                self.Enemy = other:GetLauncher()
                self.EnemyProj = other
                --NOTE: Fix me We need to test enemy validity if there is no enemy
                --      set target to 180 of the unit
                if self.Enemy then
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)
                end
                ChangeState(self, self.RedirectingState)
            end
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
            if not self or self:BeenDestroyed()
            or not self.EnemyProj or self.EnemyProj:BeenDestroyed()
            or not self.Owner or self.Owner:IsDead() then
                return
            end

            local beams = {}
            for k, v in self.RedirectBeams do
                table.insert(beams, AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self:GetArmy(), v))
            end
            if self.Enemy then
            -- Set collision to friends active so that when the missile reaches its source it can deal damage.
                self.EnemyProj:SetIgnoreAlly(false)
			    self.EnemyProj.DamageData.DamageFriendly = true
			    self.EnemyProj.DamageData.DamageSelf = true
			end
            if self.Enemy and not self.Enemy:BeenDestroyed() then
                WaitSeconds(1/self.RedirectRateOfFire)
                if not self.EnemyProj:BeenDestroyed() then
                     self.EnemyProj:TrackTarget(false)
                end
            else
                WaitSeconds(1/self.RedirectRateOfFire)
                local vectordam = {}
                vectordam.x = 0
                vectordam.y = 1
                vectordam.z = 0
                self.EnemyProj:OnDamage(self.Owner, 30, vectordam, 'Fire')
            end
            for k, v in beams do
                v:Destroy()
            end
            ChangeState(self, self.WaitingState)
        end,

        OnProjectileCollisionCheck = function(self, other)
            return false
        end,
    },
}