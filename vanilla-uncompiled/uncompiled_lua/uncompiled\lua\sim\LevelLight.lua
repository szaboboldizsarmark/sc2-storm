--****************************************************************************
--**
--**  File     :  /lua/sim/LevelLight.lua
--**  Author(s):
--**
--**  Summary  :
--**
--**  Copyright © 2009 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
--
-- The base dynamic light in level lua class
--
local Entity = import('/lua/sim/Entity.lua').Entity
LevelLight = Class {
	__init = function(self, lightData)
		self.Trash = TrashBag()
		self.mLightName = lightData.lightName
		self.mPosition = lightData.position
		self.mOrientation = VRotateY(lightData.orientation) -- get the up direction
		self.mOrientation = VMult( self.mOrientation, -1 )
		self.mLightRadius = lightData.lightRadius
		self.mLightIndex = lightData.lightIndex
		self.mLightFadeInTime = lightData.lightFadeInTime
		self.mLightDuration = lightData.lightDuration
		self.mLightFadeOutTime = lightData.lightFadeOut

		self.mEffectsBag = {}
		self.mEffectMarkerEntities ={}
		self:Activate()
	end,

	ForkThread = function(self, fn, ...)
		if fn then
			local thread = ForkThread(fn, self, unpack(arg))
			self.Trash:Add(thread)
			return thread
		else
			return nil
		end
	end,


	-- Activates the light
	Activate = function( self )
		if self.mActive then
			return
		end
		if self.mLightHandle then
			return
		end
		self.mActive = true
		self.mLightHandle = CreateLight( self.mPosition[1], self.mPosition[2], self.mPosition[3], 
					self.mOrientation[1], self.mOrientation[2], self.mOrientation[3], 
					self.mLightRadius, self.mLightIndex, self.mLightFadeInTime, self.mLightDuration, self.mLightFadeOutTime )

		if self.mEffects and self.mEffectMarkers then
			for _,marker in self.mEffectMarkers do
				local ent = Entity()
				table.insert(self.mEffectMarkerEntities, ent)
				Warp( ent, marker.position )
				ent:SetOrientation(OrientFromDir(marker.orientation), true)
				for k,v in self.mEffects do
					table.insert( self.mEffectsBag, CreateEmitterAtBone(ent,-2,-1,v) )
				end
			end
		end
	end,

	-- Deactivates the light
	Deactivate = function( self )
		if not self.mActive then
			return
		end
		if self.mLightHandle then
			DestroyLight(self.mLightHandle)
			self.mLightHandle = false
		end
		self.mActive = false
		if self.mEffects then
			for _,v in self.mEffectsBag do
				v:Destroy()
			end
			self.mEffectsBag = {}
			for _,v in self.mEffectMarkerEntities do
				v:Destroy()
			end
			self.mEffectMarkerEntities = {}
		end
	end,


	Blink = function( self, blinkRate, effect, effectMarkers )
		if self.mBlinkThread then
			KillThread( self.mBlinkThread )
			self.mBlinkThread = false
		end
		self.mEffects = effect
		self.mEffectMarkers = effectMarkers
		self.mBlinkThread = self:ForkThread( self.LBlink, blinkRate or 1 )
	end,


	LBlink = function( self, blinkRate )
		while true do
			WaitSeconds( blinkRate )
			if self.mActive then self:Deactivate() else self:Activate() end
		end
	end,

	-----------------------------

	OnDestroy = function(self)
		if self.mBlinkThread then
			KillThread( self.mBlinkThread )
			self.mBlinkThread = false
		end
		if self.mLightHandle then
			DestroyLight(self.mLightHandle)
			self.mLightHandle = false
		end
	end,


}

