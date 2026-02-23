-----------------------------------------------------------------------------
--  File     : /projectiles/Cybran/CBuild01/CBuild01_Script.lua
--  Author(s): Gordon Duclos
--  Summary  : SC2 Cybran Build Latice Effect Projectile
--  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Projectile = import('/lua/sim/Projectile.lua').Projectile
local Entity = import('/lua/sim/Entity.lua').Entity
local beamBlueprint = '/effects/emitters/units/cybran/general/adjacency_cybran_beam_01_emit.bp'

local EffectTemplate = import('/lua/sim/EffectTemplates.lua').EffectTemplates

CBuild01 = Class(Projectile) {

	OnCreate = function(self, inWater)
		Projectile.OnCreate(self, inWater)
		self:ForkThread(self.MovementThread)
		
		self.SpikeAmbientEffects = {}		
	end,

	SetInitialVector = function( self, initialVec )
		self.InitialVec = initialVec
	end,

	UpdateTrackingBeam = function( self, node )
		self.CurrentTrackingBeam:Destroy()
		self.CurrentTrackingBeam = AttachBeamEntityToEntity( self, -2, node, -1, self:GetArmy(), beamBlueprint )
	end,

	CreateBeamBetweenNodes = function( self, nodeFirst, nodeSecond )
		self.Trash:Add(AttachBeamEntityToEntity( nodeFirst, 0, nodeSecond, 0, self:GetArmy(), beamBlueprint ))
	end,

	CreateNewNode = function( self )
		local nodeEntity = nil
		local pos = table.copy(self:GetPosition())
		local height = GetTerrainHeight( pos[1], pos[3] )
		local waterHeight = GetWaterHeight()
		
		if waterHeight > height then
			height = waterHeight
		end

		local heightDiff = math.abs( pos[2] - height )
		local spec = {Owner = self,}		

		if heightDiff < 6 then
			pos[2] = height
			nodeEntity = Entity(spec)
			nodeEntity:SetMesh('/units/cybran/ucb0021/ucb0021-spike_mesh', false)
			nodeEntity:SetScale(0.015)
			self.Trash:Add(nodeEntity)

			Warp( nodeEntity, pos )
			
			-- add ambient effects at node entities	
			for kEffect, vEffect in EffectTemplate.CybranScaffoldingEffects03 do
				table.insert( self.SpikeAmbientEffects, CreateAttachedEmitter( nodeEntity, -2, self:GetArmy(), vEffect ))
			end
		end
		
		return nodeEntity
	end,

	MovementThread = function(self)
		local currentNode = self:CreateNewNode()
		if not currentNode then
			self:SetVelocity( 0 )
			return
		end
		local speed = Random(2,4)
		self.CurrentTrackingBeam = AttachBeamEntityToEntity( self, -2, currentNode, -1, self:GetArmy(), beamBlueprint )
		WaitSeconds(0.1)
		local crossVel = VCross( self.InitialVec, VECTOR3(0,1,0) )

		if Random(0,1) == 1 then
			crossVel = VECTOR3( -crossVel[1], -crossVel[2], -crossVel[3] )
		end

		local waitDelay =  (Random()*0.5)+0.5

		WaitSeconds(waitDelay)

		local newNode = self:CreateNewNode()
		if not newNode then
			self:SetVelocity( 0 )
			return
		end
		self:CreateBeamBetweenNodes( currentNode, newNode )
		self:UpdateTrackingBeam( newNode )
		currentNode = newNode
		self:SetVelocity( crossVel[1] + (self.InitialVec[1]*0.6), 0, crossVel[3] + (self.InitialVec[1]*0.6) )
		self:SetVelocity( speed )

		waitDelay =  (Random()*0.5)+0.5
		WaitSeconds(waitDelay)

		newNode = self:CreateNewNode()
		if not newNode then
			self:SetVelocity( 0 )
			return
		end
		self:CreateBeamBetweenNodes( currentNode, newNode )
		self:UpdateTrackingBeam( newNode )
		currentNode = newNode
		self:SetVelocity( self.InitialVec[1], 0, self.InitialVec[3] )
		self:SetVelocity( speed )

		waitDelay =  (Random()*0.5)+0.5
		WaitSeconds(waitDelay)

		newNode = self:CreateNewNode()
		if not newNode then
			self:SetVelocity( 0 )
			return
		end
		self:CreateBeamBetweenNodes( currentNode, newNode )
		self:UpdateTrackingBeam( newNode )
		currentNode = newNode
		self:SetVelocity( -crossVel[1] + (self.InitialVec[1]*0.9), 0, -crossVel[3] + (self.InitialVec[1]*0.9) )
		self:SetVelocity( speed )

		waitDelay =  (Random()*0.5)+0.5
		WaitSeconds(waitDelay)
		newNode = self:CreateNewNode()
		if not newNode then
			self:SetVelocity( 0 )
			return
		end
		self:CreateBeamBetweenNodes( currentNode, newNode )
		self.CurrentTrackingBeam:Destroy()
		self:SetVelocity( 0 )
		WaitSeconds(12)
	end,
}
TypeClass = CBuild01