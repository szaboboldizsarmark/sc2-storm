--------------------------------------------------------------------------
-- WARNING: THIS IS A REPLICATED FILE
-- Please note that this file is replicated by the P4 replicator service.
-- Only edit the version of this file that is located in rts_engine,
-- otherwise your changes will be lost.
--------------------------------------------------------------------------

local Entity = import('/lua/sim/Entity.lua').Entity

ObjectiveArrow = Class(Entity) {

	OnCreate = function(self,spec)
		-- unpack the spec and store the data to self
		self.mOffset			= spec.Offset or 0.0
		self.mSize				= spec.Size or 1.0
		self.mDefaultMesh		= spec.DefaultMesh or '/meshes/game/arrow_mesh'
		self.mAttachTo			= spec.AttachTo
		self.mPos				= spec.position
		self.mOrient			= spec.orientation
		self.mIgnoreVizRules	= spec.IgnoreVizRules or false

		---NOTE: the concept here is that for some arrows we want to show them independent of the VizRules - but for others, we only want
		---			the arrows to show when the player has sight on the arrow - bfricks 4/20/09
		if not self.mIgnoreVizRules then
			self:SetVizToFocusPlayer('Always')
			self:SetVizToEnemies('Intel')
			self:SetVizToAllies('Never')
			self:SetVizToNeutrals('Intel')
		end

		self:SetMesh(self.mDefaultMesh)

		local unitScale = 1.0

		if self.mAttachTo then
			-- first handle the case of an attached arrow
			self.mAttachTo.Trash:Add(self)

			if IsUnit(self.mAttachTo) and EntityCategoryContains(categories.NAVAL * categories.MOBILE, self.mAttachTo) then
				self.mAttachTo.Callbacks.OnKilled:Add(
					function()
						if self then
							self:SetMesh('')
						end
					end
				)
			end

			self:AttachBoneTo(-1,self.mAttachTo,-1)

			-- Position from the top of the parent's collision box
			local yOff = 0
			local extents = self.mAttachTo:GetCollisionExtents()
			if extents then
				-- scale up arrow based on unit's size
				unitScale = math.min( extents.Max.x - extents.Min.x, extents.Max.z - extents.Min.z)
				unitScale = math.max( unitScale, 1.0 )

				yOff = (self.mSize * unitScale) / 2.0 + extents.Max.y - self.mAttachTo:GetPosition().y
				yOff = yOff + 0.5
			else
				yOff = spec.Size / 2.0 + 0.5
			end

			self:SetParentOffset(Vector(0,yOff,0))
			self.mOffset = self.mOffset + yOff;
			ForkThread(self.BounceThread,self)

			-- magic 0.4 scaling so spec.Size can be specified in OGrid units
			---NOTE: this magic is confusing - so for now, I am only preserving this for when we do the old-school AttachTo - bfricks 4/20/09
			self:SetDrawScale(0.4 * self.mSize * unitScale)

		elseif self.mPos and self.mOrient then
			-- now handle the case of a freestanding arrow
			self:SetPosition( {self.mPos[1], self.mPos[2] + self.mOffset, self.mPos[3]}, true )
			self:SetOrientationHPR( self.mOrient[1], self.mOrient[2], self.mOrient[3], true )
			ForkThread(self.BounceThread,self)
			self:SetDrawScale(self.mSize)
		end

	end,

	BounceThread = function(self)
		-- bounce time is a tracking value, that we just want to init at zero
		self.mBounceTime = 0.0

		while true do
			if self:BeenDestroyed() then
				return
			end

			-- LOG('sin =',math.sin(self.mBounceTime))
			local yOff = self.mOffset + math.sin(self.mBounceTime) / 4

			if self.mAttachTo then
				self:SetParentOffset( Vector(0,yOff,0) )
			else
				self:SetDrawScale(self.mSize + ( math.sin(self.mBounceTime) / 4 ) )
			end

			WaitSeconds(0.1)
			self.mBounceTime = self.mBounceTime + math.pi * 0.25
		end
	end,
}
