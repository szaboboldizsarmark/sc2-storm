-----------------------------------------------------------------------------
--  File     :  /projectiles/cybran/cantiair01/cantiair01_script.lua
--  Author(s):
--  Summary  :  SC2 Cybran AntiAir: CAntiAir01
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------

local Projectile = import('/lua/sim/Projectile.lua').Projectile
CAntiAir01 = Class(Projectile) {
    OnCreate = function(self)
        Projectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)
        self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)        
        self.WaitTime = 0.1
        self.Distance = self:GetDistanceToTarget()
		
        self:SetTurnRate(30)     
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > self.Distance then
        	self:SetTurnRate(20)
        	self.Distance = self:GetDistanceToTarget()
        end
        if dist > 50 then        
            --Freeze the turn rate as to prevent steep angles at long distance targets
            self:SetTurnRate(20)
        elseif dist > 30 and dist <= 50 then
			self:SetTurnRate(35)
			WaitSeconds(0.2)
            self:SetTurnRate(50)
        elseif dist > 10 and dist <= 25 then
            self:SetTurnRate(70)
				elseif dist > 0 and dist <= 10 then           
            self:SetTurnRate(120)   
            KillThread(self.MoveThread)         
        end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
}

TypeClass = CAntiAir01