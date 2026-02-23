-----------------------------------------------------------------------------
--  File     : /lua/sim/unit.lua
--  Author(s): John Comes, David Tomandl, Gordon Duclos
--  Summary  : The Unit lua module
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------
local Entity = import('/lua/sim/Entity.lua').Entity
local Game = import('/lua/sim/game.lua')
local utilities = import('/lua/system/utilities.lua')
local Shield = import('/lua/sim/shield.lua').Shield
local AIUtils = import('/lua/ai/aiutilities.lua')

SyncMeta = {
    __index = function(t,key)
        local id = rawget(t,'id')
        return UnitData[id].Data[key]
    end,

    __newindex = function(t,key,val)
        --LOG( "SYNC: " .. key .. ' = ' .. repr(val))
        local id = rawget(t,'id')
        local army = rawget(t,'army')
        if not UnitData[id] then
            UnitData[id] = {
                OwnerArmy = rawget(t,'army'),
                Data = {}
            }
        end
        UnitData[id].Data[key] = val

        if army == GetFocusArmy() then
            if not Sync.UnitData[id] then
                Sync.UnitData[id] = {}
            end
            Sync.UnitData[id][key] = val
        end
    end,
}

Unit = Class(moho.unit_methods) {
    Weapons = {},

	-- Class callbacks apply to all units with this meta-table. A class callback will
	-- affect everyunit of this type.
    ClassCallbacks = {
        OnStopBuild = Callback(),
		OnStopBeingBuilt = Callback(),
    },

    FxScale = 1,
    FxDamageScale = 1,
    -- FX Damage tables. A random damage effect table of emitters is choosen out of this table
    FxDamage1 = { EffectTemplates.DamageSparks01, EffectTemplates.DamageSparks01 },
    FxDamage2 = { EffectTemplates.DamageElectricity01, EffectTemplates.DamageSparks01 },
    FxDamage3 = { EffectTemplates.DamageSmoke01, EffectTemplates.DamageSparks01 },

    -- This will be true for all units being constructed as upgrades
    DisallowCollisions = false,

    -- Destruction params
    DestructionExplosionWaitDelayMin = 0,
    DestructionExplosionWaitDelayMax = 0.5,

    EconomyProductionInitiallyActive = true,

    --*******************************************************************
    -- INITIALIZATION
    --*******************************************************************
    OnPreCreate = function(self)
        -- Each unit has a sync table that magically knows when values change and stuffs it
        -- in the global sync table to copy to the user layer at sync time.
        self.Sync = {}
        self.Sync.id = self:GetEntityId()
        self.Sync.army = self:GetArmy()
        setmetatable(self.Sync,SyncMeta)

        --Entity.OnPreCreate(self)
        if not self.Trash then
            self.Trash = TrashBag()
        end

		-- Unit instance specific callback, this callback will only occur for this instance of
		-- of a unit.
		self.Callbacks = {
            OnCaptured = Callback(),
            OnStopCapture = Callback(),
            OnCapturedNewUnit = Callback(),
            OnDestroyedOnTransport = Callback(),
            OnDamaged = Callback(),
            OnHealthChanged = Callback(),
            OnKilled = Callback(),
            OnKilledUnit = Callback(),
			OnLayerChange = Callback(),
			OnReclaimed = Callback(),
			OnResurrected = Callback(),
			OnStopBuild = Callback(),
            OnStartBuild = Callback(),
            OnSelected = Callback(),
		}
    end,

    OnCreate = function(self, createArgs)
        Entity.OnCreate(self)

		local bp = self:GetBlueprint()

        -- Set number of effects per damage depending on its volume
        local x, y, z = self:GetUnitSizes()
        local vol = x*y*z
        --print('Created ' .. self:GetBlueprint().Display.DisplayName .. ': Volume:' .. vol)
        local damageamounts = 1
        if vol >= 20 then
            damageamounts = 6
            self.FxDamageScale = 2
        elseif vol >= 10 then
            damageamounts = 4
            self.FxDamageScale = 1.5
        elseif vol >= 0.5 then
            damageamounts = 2
        end
        --print('Damage Amounts: ' .. damageamounts)
        self.FxDamage1Amount = self.FxDamage1Amount or damageamounts
        self.FxDamage2Amount = self.FxDamage2Amount or damageamounts
        self.FxDamage3Amount = self.FxDamage3Amount or damageamounts
        self.DamageEffectsBag = {
            {},
            {},
            {},
        }

        -- Setup effect emitter bags
        self.IdleEffectsBag = {}
		self.TeleportChargeBag = {}
        self.TransportBeamEffectsBag = {}
        self.BuildEffectsBag = TrashBag()
        self.ReclaimEffectsBag = TrashBag()
        self.OnBeingBuiltEffectsBag = TrashBag()
        self.CaptureEffectsBag = TrashBag()
        self.UpgradeEffectsBag = TrashBag()

        local bpEcon = bp.Economy

        self:SetConsumptionPerSecondEnergy(bpEcon.MaintenanceConsumptionPerSecondEnergy or 0)
        self:SetConsumptionPerSecondMass(bpEcon.MaintenanceConsumptionPerSecondMass or 0)

        if self.EconomyProductionInitiallyActive then
            --LOG('*DEBUG: SETTING PRODUCTION ACTIVE')
            self:SetProductionActive(true)
        end

        self.Buffs = {
            BuffTable = {},
            Affects = {},
        }

        local bpVision = bp.Intel.VisionRadius
        if bpVision then
            self:SetIntelRadius('Vision', bpVision)
        else
            self:SetIntelRadius('Vision', 0)
        end

        self:SetCanTakeDamage(true)
        self:SetCanBeKilled(true)

        local bpDeathAnim = bp.Display.AnimationDeath

        if bpDeathAnim and table.getn(bpDeathAnim) > 0 then
            self.PlayDeathAnimation = true
        end

        -- Used for keeping track of resource consumption
        self.MaintenanceConsumption = false
        self.ActiveConsumption = false
        self.ProductionEnabled = true
        self.EnergyModifier = 0
        self.MassModifier = 0

        if self:GetAIBrain().CampaignBuffs then
            for _, buffName in self:GetAIBrain().CampaignBuffs do
                ApplyBuff(self, buffName)
            end
        end

        self.Dead = false
		self.DeathWeaponEnabled = true
		self.OnTransport = false

		-- SC2 - Disable any mesh bones that we don't want visible when a unit is created.
		local disabledMeshBones = bp.Display.DisabledMeshBones
		if disabledMeshBones then
			for k, vBone in disabledMeshBones do
				self:HideBone(vBone, true)
			end
		end

		-- Unit levels
		self.Level = 1
		self.VeteranLevel = 0
        
        if ScenarioInfo.type == 'skirmish' and self:GetAIBrain().BrainType == "AI" then
            self:GetAIBrain():ApplyCheatBuffs(self)
        end

		if EntityCategoryContains( categories.UNCAPTURABLE, self ) then
		    self:SetCapturable(false)
		end

		if EntityCategoryContains( categories.UNREPAIRABLE, self ) then
		    self:SetRepairable(false)
		end
    end,

    --*******************************************************************
    -- MISC FUNCTIONS
    --*******************************************************************
    SetDead = function(self)
        self.Dead = true
    end,

    IsDead = function(self)
        return self.Dead
    end,

    GetUnitSizes = function(self)
        local bp = self:GetBlueprint()
        return bp.SizeX, bp.SizeY, bp.SizeZ
    end,

    GetRandomOffset = function(self, scalar)
        local sx, sy, sz = self:GetUnitSizes()
        local heading = self:GetHeading()
        sx = sx * scalar
        sy = sy * scalar
        sz = sz * scalar
        local rx = Random() * sx - (sx * 0.5)
        local y  = Random() * sy + (self:GetBlueprint().CollisionOffsetY or 0)
        local rz = Random() * sz - (sz * 0.5)
        local x = math.cos(heading)*rx - math.sin(heading)*rz
        local z = math.sin(heading)*rx - math.cos(heading)*rz
        return x,y,z
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

    LifeTimeThread = function(self)
        local bp = self:GetBlueprint().Defense.LifeTime
        if not bp then return end
        WaitSeconds(bp)
        self:Destroy()
    end,

    --*******************************************************************
    -- TOGGLES
    --*******************************************************************
	OnScriptBitSet = function(self, bit)
        if bit == 0 then -- shield toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:EnableShield()
        elseif bit == 1 then -- weapon toggle
            -- do something
        elseif bit == 2 then -- jamming toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Jammer')
        elseif bit == 3 then -- intel toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('Omni')
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('CloakField')
            self:DisableUnitIntel('Spoof')
            self:DisableUnitIntel('Jammer')
            self:DisableUnitIntel('Radar')
        elseif bit == 4 then -- production toggle
            self:OnProductionPaused()
        elseif bit == 5 then -- stealth toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')
        elseif bit == 6 then -- generic pause toggle
            self:SetPaused(true)
        elseif bit == 7 then -- special toggle
            self:EnableSpecialToggle()
        elseif bit == 8 then -- cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 0 then -- shield toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:DisableShield()
        elseif bit == 1 then -- weapon toggle
            -- do something
        elseif bit == 2 then -- jamming toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Jammer')
        elseif bit == 3 then -- intel toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('Omni')
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('CloakField')
            self:EnableUnitIntel('Spoof')
            self:EnableUnitIntel('Jammer')
        elseif bit == 4 then -- production toggle
            self:OnProductionUnpaused()
        elseif bit == 5 then -- stealth toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        elseif bit == 6 then -- generic pause toggle
            self:SetPaused(false)
        elseif bit == 7 then -- special toggle
            self:DisableSpecialToggle()
        elseif bit == 8 then -- cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
        end
    end,

    OnPaused = function(self)
		if self:IsUnitState('Upgrading') or self:IsUnitState('Repairing') then
			self:SetActiveConsumptionInactive()
			self:StopUnitAmbientSound( 'ConstructLoop' )
		end
    end,

    OnUnpaused = function(self)
        if self:IsUnitState('Upgrading') or self:IsUnitState('Repairing') then
            self:SetActiveConsumptionActive()
            self:PlayUnitAmbientSound( 'ConstructLoop' )
        end
    end,

    EnableSpecialToggle = function(self)
        if self.Callbacks.SpecialToggleEnableFunction then
            self.Callbacks.SpecialToggleEnableFunction(self)
        end
    end,

    DisableSpecialToggle = function(self)
        if self.Callbacks.SpecialToggleDisableFunction then
            self.Callbacks.SpecialToggleDisableFunction(self)
        end
    end,

    AddSpecialToggleEnable = function(self, fn)
        if fn then
            self.Callbacks.SpecialToggleEnableFunction = fn
        end
    end,

    AddSpecialToggleDisable = function(self, fn)
        if fn then
            self.Callbacks.SpecialToggleDisableFunction = fn
        end
    end,

    EnableDefaultToggleCaps = function( self )
        if self.ToggleCaps then
            for k,v in self.ToggleCaps do
                self:AddToggleCap(v)
            end
        end
    end,

    DisableDefaultToggleCaps = function( self )
        self.ToggleCaps = {}
        local capsCheckTable = {'RULEUTC_WeaponToggle', 'RULEUTC_ProductionToggle', 'RULEUTC_GenericToggle', 'RULEUTC_SpecialToggle'}
        for k,v in capsCheckTable do
            if self:TestToggleCaps(v) == true then
                table.insert( self.ToggleCaps, v )
            end
            self:RemoveToggleCap(v)
        end
    end,

    --*******************************************************************
    -- MISC EVENTS
    --*******************************************************************

	---------------------------------------------------------------------
	--- SC2: research tracking
	---------------------------------------------------------------------
    OnResearchedTechnologyAdded = function( self, upgradeName, level, modifierGroup )
		--LOG( ' OnResearchedTechnologyAdded: ', upgradeName, ' Level: ', level, ' ModifierGroup: ', modifierGroup )

		-- add some dev text to the unit
		local GResearchInfo

		if level > 1 then
			GResearchInfo = ResearchDefinitions[upgradeName].BOOSTS[level-1]
		else
			GResearchInfo = ResearchDefinitions[upgradeName]
		end

		if modifierGroup > 0 then
			GResearchInfo = GResearchInfo.Modifiers[modifierGroup]
		end

		-- Apply global research definitions upgrades.
		if GResearchInfo then

			if GResearchInfo.WIP then
				return
			end

			-- Apply any buffs we need for this upgrade
			if GResearchInfo.Buffs then
				for kBuff, vBuff in GResearchInfo.Buffs do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' ApplyBuff: ', vBuff )
					ApplyBuff(self, vBuff)
				end
			end

            if GResearchInfo.IntelEnable then
				for kIntel, vIntel in GResearchInfo.IntelEnable do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' IntelEnabled: ', vIntel)
					self:EnableUnitIntel(vIntel)
				end
            end

			if GResearchInfo.CommandEnable then
				for kCommand, vCommand in GResearchInfo.CommandEnable do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' CommandEnable: ', vCommand )
					self:AddCommandCap(vCommand)
				end
			end

			if GResearchInfo.AbilityEnable then
				for kAbility, vAbility in GResearchInfo.AbilityEnable do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' AbilityEnable: ', vAbility )
					self:SetAbilityEnabled( vAbility, true )
				end
			end

            if GResearchInfo.UnitFlags then
                for kFlagName, vFlagValue in GResearchInfo.UnitFlags do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' UnitFlag: ', kFlagName, ' - Value: ', vFlagValue )
                    self[kFlagName] = vFlagValue
                end
            end

            if GResearchInfo.UnitStateEnable then
                for kStateName, vStateValue in GResearchInfo.UnitStateEnable do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' UnitStateEnable: ', vStateValue )
                    self:SetUnitState(vStateValue,true)
                end
            end

            if GResearchInfo.UnitStateDisable then
                for kStateName, vStateValue in GResearchInfo.UnitStateDisable do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' UnitStateDisable: ', vStateValue )
                    self:SetUnitState(vStateValue,false)
                end
            end

            if GResearchInfo.MovementTypeChange then
				--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' MotionType changed to: ', GResearchInfo.MovementTypeChange )
                self:SetMotionType(GResearchInfo.MovementTypeChange)
            end

			-- Create any shields on the unit
			if GResearchInfo.Shield then
				--LOG('OnResearchedTechnologyAdded CreateShield ', upgradeName )
				self:CreateShield()
			end
		else
			LOG('Unit:OnResearchedTechnologyAdded() Trying to apply upgrade ', upgradeName, ', which is not a defined ResearchDefinition. Level ', level )
		end

		-- Look for ResearchUpgrades for this unit
		local ResearchUpgradesBp = self:GetBlueprint().ResearchUpgrades

		-- Apply any unit specific upgrades for this particular unit.
		if ResearchUpgradesBp[upgradeName] then

			-- Cycle through an visual bones that we need to toggle on/off.
			if ResearchUpgradesBp[upgradeName].Bones then
				for kBoneName, vEnable in ResearchUpgradesBp[upgradeName].Bones do
					if vEnable then
						self:ShowBone(kBoneName, true)
					else
						self:HideBone(kBoneName, true)
					end
				end
				-- create upgrade effect
				self:PlayUpgradeEffects()
			end

			-- Enable/Disable any weapons that we need.
			if ResearchUpgradesBp[upgradeName].Weapons then
				for kWeapon, vEnable in ResearchUpgradesBp[upgradeName].Weapons do
					self:SetWeaponEnabledByLabel( kWeapon, vEnable )
				end
			end

			-- Apply unit specific buffs
			if ResearchUpgradesBp[upgradeName].Buffs then
				for kBuff, vBuff in ResearchUpgradesBp[upgradeName].Buffs do
					--LOG( 'OnResearchedTechnologyAdded ApplyBuff: ', vBuff )
					ApplyBuff(self, vBuff)
				end
			end
			
			if ResearchUpgradesBp[upgradeName].CommandEnable then
				for kCommand, vCommand in ResearchUpgradesBp[upgradeName].CommandEnable do
					--LOG( 'OnResearchedTechnologyAdded ', upgradeName, ' CommandEnable: ', vCommand )
					self:AddCommandCap(vCommand)
				end
			end			
		end
    end,
    
    PlayUpgradeEffects = function(self)
        local army = self:GetArmy()
        local bp = self:GetBlueprint()

        self.EffectsBag = {}
        for k, v in EffectTemplates.UpgradeEffect01 do
            local fx = CreateEmitterAtEntity(self,army,v):OffsetEmitter(0, (bp.Physics.MeshExtentsY or 1) / 2, 0)
            self.Trash:Add(fx)
            table.insert( self.EffectsBag, fx)
        end
    end,

    CleanupUpgradeEffects = function( self )
        if self.EffectsBag then
            for k,v in self.EffectsBag do
                v:Destroy()
            end
            self.EffectsBag = {}
        end
    end,
	---------------------------------------------------------------------

	OnProductionActive = function(self)
         --LOG('*DEBUG: PRODUCTION IS NOW ACTIVE')
    end,

    OnActive = function(self)
    end,

    OnInactive = function(self)
    end,

    OnStartCapture = function(self, target)
        self:StartCaptureEffects(target)
        self:PlayUnitSound('StartCapture')
        self:PlayUnitAmbientSound('CaptureLoop')
    end,

    OnStopCapture = function(self, target)
		self.Callbacks.OnStopCapture:Call(self, target)
        self:StopCaptureEffects(target)
        self:PlayUnitSound('StopCapture')
        self:StopUnitAmbientSound('CaptureLoop')
    end,

    StartCaptureEffects = function( self, target )
		self.CaptureEffectsBag:Add( self:ForkThread( self.CreateCaptureEffects, target ) )
    end,

    CreateCaptureEffects = function( self, target )
    end,

    StopCaptureEffects = function( self, target )
		self.CaptureEffectsBag:Destroy()
    end,

    OnFailedCapture = function(self, target)
        self:StopCaptureEffects(target)
        self:PlayUnitSound('FailedCapture')
    end,

    OnStartBeingCaptured = function(self, captor)
        self:PlayUnitSound('StartBeingCaptured')
    end,

    OnStopBeingCaptured = function(self, captor)
        self:PlayUnitSound('StopBeingCaptured')
    end,

    OnFailedBeingCaptured = function(self, captor)
        self:PlayUnitSound('FailedBeingCaptured')
    end,

    OnReclaimed = function(self, entity)
       	self.Callbacks.OnReclaimed:Call(self, entity)
        self.CreateReclaimEndEffects( entity, self )
		self:PlayUnitSound('OnReclaimed')
        self:Destroy()
    end,

    OnStartReclaim = function(self, target)
        self:StartReclaimEffects(target)
        self:PlayUnitSound('StartReclaim')
        self:PlayUnitAmbientSound('ReclaimLoop')
    end,

    OnStopReclaim = function(self, target)
		self:StopReclaimEffects(target)
		self:StopUnitAmbientSound('ReclaimLoop')
		self:PlayUnitSound('StopReclaim')
    end,

    StartReclaimEffects = function( self, target )
		self.ReclaimEffectsBag:Add( self:ForkThread( self.CreateReclaimEffects, target ) )
    end,

    CreateReclaimEffects = function( self, target )
    end,

    CreateReclaimEndEffects = function( self, target )
    end,

    StopReclaimEffects = function( self, target )
		self.ReclaimEffectsBag:Destroy()
    end,

    OnCaptured = function(self, captor)

		if self and not self:IsDead() and captor and not captor:IsDead() and self:GetAIBrain() ~= captor:GetAIBrain() then

			if not self:IsCapturable() then
                self:Kill()
                return
            end

            -- kill non capturable things on a transport
            if EntityCategoryContains( categories.TRANSPORTATION, self ) then
                local cargo = self:GetCargo()
                for _,v in cargo do
                    if not v:IsDead() and not v:IsCapturable() then
                        v:Kill()
                    end
                end
            end
			self.Callbacks.OnCaptured:Call(self)
            local entId = self:GetEntityId()
            local captorArmyIndex = captor:GetArmy()
            local captorBrain = false

            -- For campaigns:
            -- We need the brain to ignore army cap when transfering the unit
            -- do all necessary steps to set brain to ignore, then un-ignore if necessary the unit cap
            if ScenarioInfo.CampaignMode then
                captorBrain = captor:GetAIBrain()
                SetIgnoreArmyUnitCap(captorArmyIndex, true)
            end

            local newUnit = ChangeUnitArmy(self, captorArmyIndex)

            if ScenarioInfo.CampaignMode and not captorBrain.IgnoreArmyCaps then
                SetIgnoreArmyUnitCap(captorArmyIndex, false)
            end

            -- Because the old unit is lost we cannot call a member function for newUnit callbacks
			self.Callbacks.OnCapturedNewUnit:Call(newUnit, captor)
        end
    end,

    --*******************************************************************
    -- ECONOMY
    --*******************************************************************
    OnConsumptionActive = function(self)
    end,
    OnConsumptionInActive = function(self)
    end,

    -- We are splitting Consumption into two catagories:
    --   Maintenance -- for units that are usually "on": radar, mass extractors, etc.
    --   Active -- when upgrading, constructing, or something similar.
    --
    -- It will be possible for both or neither of these consumption methods to be
    -- in operation at the same time.  Here are the functions to turn them off and on.
    SetMaintenanceConsumptionActive = function(self)
        self.MaintenanceConsumption = true
        self:UpdateConsumptionValues()
    end,

    SetMaintenanceConsumptionInactive = function(self)
        self.MaintenanceConsumption = false
        self:UpdateConsumptionValues()
    end,

    SetActiveConsumptionActive = function(self)
        self.ActiveConsumption = true
        self:UpdateConsumptionValues()
    end,

    SetActiveConsumptionInactive = function(self)
        self.ActiveConsumption = false
        self:UpdateConsumptionValues()
    end,
	
    OnProductionPaused = function(self)
        self:SetMaintenanceConsumptionInactive()
        self:SetProductionActive(false)
    end,

    OnProductionUnpaused = function(self)
        self:SetMaintenanceConsumptionActive()
        self:SetProductionActive(true)
    end,

    GetEconomyBuildRate = function(self)
        return self:GetBuildRate()
    end,

    --
    -- Called when we start building a unit, turn on/off, get/lose bonuses, or on
    -- any other change that might affect our build rate or resource use.
    --
    UpdateConsumptionValues = function(self)
        local myBlueprint = self:GetBlueprint()

        local energy_rate = 0
        local mass_rate = 0
        local build_rate = 0
        local build = false

        if self.ActiveConsumption then
            local focus = self:GetFocusUnit()
            local time = 1
            local mass = 0
            local energy = 0
            if self.WorkItem then
                time, energy, mass = Game.GetConstructEconomyModel(self, self.WorkItem)
            elseif focus and focus:IsUnitState('SiloBuildingAmmo') then
                -- If building silo ammo; create the energy and mass costs based on build rate of the silo
                --     against the build rate of the assisting unit
                time, energy, mass = focus:GetBuildCosts(focus.SiloProjectile)

                local siloBuildRate = focus:GetBuildRate() or 1
                energy = (energy / siloBuildRate) * (self:GetBuildRate() or 1)
                mass = (mass / siloBuildRate) * (self:GetBuildRate() or 1)
            elseif focus then
                -- bonuses are already factored in by GetBuildCosts
                time, energy, mass = self:GetBuildCosts(focus:GetBlueprint())
            end
            energy = energy * (self.EnergyBuildAdjMod or 1)
            if energy > 0 and energy < 1 then
                energy = 1
            end
            mass = mass * (self.MassBuildAdjMod or 1)
            if mass > 0 and mass < 1 then
                mass = 1
            end

            if time > 0 then
                build = true
            end

            energy_rate = energy / time
            mass_rate = mass / time
        end

        if self.MaintenanceConsumption then
            local mai_energy = (self.EnergyMaintenanceConsumptionOverride or myBlueprint.Economy.MaintenanceConsumptionPerSecondEnergy)  or 0
            local mai_mass = myBlueprint.Economy.MaintenanceConsumptionPerSecondMass or 0

            -- apply bonuses
            mai_energy = mai_energy * (100 + self.EnergyModifier) * (self.EnergyMaintAdjMod or 1) * 0.01
            mai_mass = mai_mass * (100 + self.MassModifier) * (self.MassMaintAdjMod or 1) * 0.01

            energy_rate = energy_rate + mai_energy
            mass_rate = mass_rate + mai_mass
        end

        -- apply minimum rates
        energy_rate = math.max(energy_rate, myBlueprint.Economy.MinConsumptionPerSecondEnergy or 0)
        mass_rate = math.max(mass_rate, myBlueprint.Economy.MinConsumptionPerSecondMass or 0)

        self:SetConsumptionPerSecondEnergy(energy_rate)
        self:SetConsumptionPerSecondMass(mass_rate)

        if (energy_rate > 0) or (mass_rate > 0) or build then
            self:SetConsumptionActive(true)
        else
            self:SetConsumptionActive(false)
        end
    end,

    --*******************************************************************
    -- DAMAGE
    --*******************************************************************
    --Sets if the unit can take damage.  val = true means it can take damage.
    --val = false means it can't take damage
    SetCanTakeDamage = function(self, val)
        self.CanTakeDamage = val
    end,

    CheckCanTakeDamage = function(self)
        return self.CanTakeDamage
    end,

    OnDamage = function(self, instigator, amount, vector, damageType)
        if self.CanTakeDamage then
			self.Callbacks.OnDamaged:Call(self, instigator, amount, damageType)
			self:TakeDamage(instigator, amount, damageType)
        end
    end,

    ManageDamageEffects = function(self, newHealth, oldHealth)
        --LOG('*DEBUG: ManageDamageEffects, New: ', repr(newHealth), ' Old: ', repr(oldHealth))

        -- Health values come in at fixed 25% intervals
        if newHealth < oldHealth then
            if oldHealth == 0.75 then
                for i = 1, self.FxDamage1Amount do
                    self:PlayDamageEffect(self.FxDamage1, self.DamageEffectsBag[1])
                end
            elseif oldHealth == 0.5 then
                for i = 1, self.FxDamage2Amount do
                    self:PlayDamageEffect(self.FxDamage2, self.DamageEffectsBag[2])
                end
            elseif oldHealth == 0.25 then
                for i = 1, self.FxDamage3Amount do
                    self:PlayDamageEffect(self.FxDamage3, self.DamageEffectsBag[3])
                end
            end
        else
            if newHealth <= 0.25 and newHealth > 0 then
                for k, v in self.DamageEffectsBag[3] do
                    v:Destroy()
                end
            elseif newHealth <= 0.5 and newHealth > 0.25 then
                for k, v in self.DamageEffectsBag[2] do
                    v:Destroy()
                end
            elseif newHealth <= 0.75 and newHealth > 0.5 then
                for k, v in self.DamageEffectsBag[1] do
                    v:Destroy()
                end
            elseif newHealth > 0.75 then
                self:DestroyAllDamageEffects()
            end
        end
    end,

    PlayDamageEffect = function(self, fxTable, fxBag)
        local army = self:GetArmy()
        local effects = fxTable[Random(1,table.getn(fxTable))]
        if not effects then return end
        local totalBones = self:GetBoneCount()
        local bone = Random(1, totalBones) - 1
        local bpDE = self:GetBlueprint().Display.DamageEffects
		local layer = self:GetCurrentLayer()
		if bpDE and bpDE[layer] and bpDE[layer].EffectSets and bpDE[layer].BoneSets then
			local effectNum = Random(1, table.getsize(bpDE[layer].EffectSets))
			local effect = EffectTemplates[bpDE[layer].EffectSets[effectNum]]
			local bonesetNum = Random(1, table.getsize(bpDE[layer].BoneSets))
			local bpFx = bpDE[layer].BoneSets[bonesetNum]
			local emitters = CreateAttachedEmitters(self, bpFx.Bone or 0,army, effect, true, self.FxDamageScale, {bpFx.OffsetX or 0, bpFx.OffsetY or 0, bpFx.OffsetZ or 0} )
			for k,v in emitters do
				table.insert(fxBag, v)
			end
		else		
			for k, v in effects do
				if bpDE then
					local num = Random(1, table.getsize(bpDE))
					local bpFx = bpDE[num]
					table.insert(fxBag, CreateAttachedEmitter(self, bpFx.Bone or 0,army, v):ScaleEmitter(self.FxDamageScale):OffsetEmitter(bpFx.OffsetX or 0, bpFx.OffsetY or 0, bpFx.OffsetZ or 0))
				else
					table.insert(fxBag, CreateAttachedEmitter(self, bone, army, v):ScaleEmitter(self.FxDamageScale))
				end
			end
		end
    end,

    OnHealthChanged = function(self, new, old)
        self:ManageDamageEffects(new, old)
       	self.Callbacks.OnHealthChanged:Call(self, new, old)
    end,

    DestroyAllDamageEffects = function(self)
        for kb, vb in self.DamageEffectsBag do
            for ke, ve in vb do
                ve:Destroy()
            end
        end
    end,
	
	TransitionDamageEffects = function(self)
		self:DestroyAllDamageEffects()
		local health = self:GetHealth()
		local maxHealth = self:GetMaxHealth()
		local healthFrac = math.floor((health / maxHealth)*4) * 0.25
		if healthFrac == 0.50 then
			for i = 1, self.FxDamage1Amount do
				self:PlayDamageEffect(self.FxDamage1, self.DamageEffectsBag[1])
			end
		end
		if healthFrac == 0.25 then
			for i = 1, self.FxDamage2Amount do
				self:PlayDamageEffect(self.FxDamage2, self.DamageEffectsBag[2])
			end
		end
		if healthFrac == 0.0 then
			for i = 1, self.FxDamage3Amount do
				self:PlayDamageEffect(self.FxDamage3, self.DamageEffectsBag[3])
			end
		end
	end,

    CheckCanBeKilled = function(self,other)
        return self.CanBeKilled
    end,

	OnKilledPlaySound = function(self,motionType)
        if self:GetCurrentLayer() == 'Water' and motionType == 'RULEUMT_Hover' then
            self:PlayUnitSound('HoverKilledOnWater')
        end

        if self:GetCurrentLayer() == 'Land' and motionType == 'RULEUMT_AmphibiousFloating' then
            --Handle ships that can walk on land...
            self:PlayUnitSound('AmphibiousFloatingKilledOnLand')
        else
            self:PlayUnitSound('Killed')
        end
	end,

	PrecacheDebris = function( self )
		local bp = self:GetBlueprint()
		if not bp.Death then return false end
		local death = bp.Death
		if not death.DestructionParts then return false end
		local DestructionParts = death.DestructionParts
		if DestructionParts then
			local meshBPs = {}
			for k, v in DestructionParts do
				if v.Mesh then
					table.insert(meshBPs,  v.Mesh )
				elseif v.Meshes then
					for kMesh, vMesh in v.Meshes do
						table.insert(meshBPs, vMesh )
					end
				end
			end
			self:PrefetchMeshes( meshBPs )
			return true
		end
		return false
	end,

    -- On killed: this function plays when the unit takes a mortal hit.  It plays all the default death effect
    -- it also spawns the wreckage based upon how much it was overkilled.
    OnKilled = function(self, instigator, type, overkillRatio)

        self.Dead = true

        local bp = self:GetBlueprint()

		self:OnKilledPlaySound(bp.Physics.MotionType)

        --If factory, destroy what I'm building if I die
        if EntityCategoryContains(categories.FACTORY, self) then
            if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and self.UnitBeingBuilt:GetFractionComplete() != 1 then
                self.UnitBeingBuilt:Kill()
            end
        end

        if self.PlayDeathAnimation and not self:IsBeingBuilt() then
			if bp.Display['AnimationDeath'] then
				self:ForkThread(self.PlayAnimationThread, 'AnimationDeath')
			end
            self:SetCollisionShape('None')
        end
        self:OnKilledVO()
        self.Callbacks.OnKilled:Call( self, instigator, type )

        if self.UnitBeingTeleported and not self.UnitBeingTeleported:IsDead() then
            self.UnitBeingTeleported:Destroy()
            self.UnitBeingTeleported = nil
        end

        --Notify instigator that you killed me.
        if instigator and IsUnit(instigator) then
            instigator:OnKilledUnit(self)
        end
        if self.DeathWeaponEnabled != false then
            self:DoDeathWeapon()
        end
        self:DestroyShield()
        self:DisableUnitIntel()

        -- Do not spawn a DeathThread for units that are destroyed by an animation event
        if not self.DestroyByAnimationEvent then
			self.DeathThreadObject = self:ForkThread(self.DeathThread, overkillRatio , instigator)
		end
    end,

    DoDeathWeapon = function(self)
        if self:IsBeingBuilt() then return end

		local wpn = self:GetWeapon('DeathWeapon')

		-- If a weapon exists then the death weapon has custom logic within that
		-- requires the weapon to actually fire, otherwise the weapon is dummyweapon
		-- and we just need to damage the immediate area.
		if wpn then
			wpn:SetEnabled(true)
			wpn:AimManipulatorSetEnabled(true)
            wpn:Fire()
		else
			local bp = self:GetUnitWeaponBlueprint('DeathWeapon')
			if bp then
				DamageArea(self, self:GetPosition(), bp.DamageRadius or 1, bp.Damage or 1, bp.DamageType or 'Normal', bp.DamageFriendly or false)
			end
		end
    end,

	-- Overidden by Mobile units.
    PerformKnockback = function( self, instigator, knockbackDistance, knockbackScale )
		return false
    end,

    --Sets if the unit can be killed.  val = true means it can be killed.
    --val = false means it can't be killed
    SetCanBeKilled = function(self, val)
        self.CanBeKilled = val
    end,

    OnKilledUnit = function(self, unitKilled)
        self.Callbacks.OnKilledUnit:Call( self, unitKilled )
    end,

    OnResurrected = function(self, instigator, cause)
        self.Dead = false
        self.Callbacks.OnResurrected:Call( self, instigator, cause )
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)
        if self.DisallowCollisions then
            return false
        end
        local weaponBP = firingWeapon:GetBlueprint()

		-- skip friendly collisions if specified
        local allowFriendlyCollisions = weaponBP.CollideFriendly
        if not allowFriendlyCollisions and IsAlly( self:GetArmy(), firingWeapon.unit:GetArmy() ) then
            return false
        end

		-- if this unit category is on the weapon's do-not-collide list, skip!
		if weaponBP.DoNotCollideList then
			for k, v in pairs(weaponBP.DoNotCollideList) do
				if EntityCategoryContains(ParseEntityCategory(v), self) then
					return false
				end
			end
		end

        return true
    end,

    ChooseAnimBlock = function(self, bp)
        local totWeight = 0
        for k, v in bp do
            if v.Weight then
                totWeight = totWeight + v.Weight
            end
        end
        local val = 1
        local num = Random(0, totWeight)
        for k, v in bp do
            if v.Weight then
                val = val + v.Weight
            end
            if num < val then
                return v
            end
        end
    end,

    PlayAnimationThread = function(self, anim, rate)
        local bp = self:GetBlueprint().Display[anim]
        if bp then
            local animBlock = self:ChooseAnimBlock( bp )
            if animBlock.Mesh then
                self:SetMesh(animBlock.Mesh)
            end
            if animBlock.Animation then
                local sinkAnim = CreateAnimator(self)
                self.DeathAnimManip = sinkAnim
                sinkAnim:PlayAnim(animBlock.Animation)
                rate = rate or 1
                if animBlock.AnimationRateMax and animBlock.AnimationRateMin then
                    rate = Random(animBlock.AnimationRateMin * 10, animBlock.AnimationRateMax * 10) / 10
                end
                sinkAnim:SetRate(rate)
                self.Trash:Add(sinkAnim)
                WaitFor(sinkAnim)
            end
        end
    end,

    --
    -- Create a unit's wrecked mesh blueprint from its regular mesh blueprint, by changing the shader and albedo
    --
    CreateWreckage = function( self, overkillRatio )

		-- if this has been set for any reason, we don't create the wreckage
		if self.ForceNoWreckage then
			return
		end

		-- if overkill ratio is high, the wreck is vaporized! No wreackage for you!
		if overkillRatio then
			if overkillRatio > 1.0 then
				return
			end
		end

		-- generate wreakage in place of the dead unit
        if self:GetBlueprint().Wreckage.WreckageLayers[self:GetCurrentLayer()] then
			self:CreateWreckageProp(overkillRatio)
        end
    end,

    CreateWreckageProp = function( self, overkillRatio )
		local bp = self:GetBlueprint()
		local wreck = bp.Wreckage.Blueprint
		if wreck then
			--LOG('*DEBUG: Spawning Wreckage = ', repr(wreck), 'overkill = ',repr(overkillRatio))
			local pos = self:GetPosition()
			
			local mass = self:GetActualBuildMass() * (bp.Wreckage.MassMult or 0)
			local energy = self:GetActualBuildEnergy() * (bp.Wreckage.EnergyMult or 0)
			local time = self:GetActualBuildTime() * (bp.Wreckage.ReclaimTimeMultiplier or 0)

			if self:GetCurrentLayer() == 'Seabed' or self:GetCurrentLayer() == 'Land' then
			    pos[2] = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
			else
			    pos[2] = GetSurfaceHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
			end

			local prop = CreatePropResource( self:GetArmy(), pos, wreck, mass, energy, time )

			-- We make sure keep only a bounded list of wreckages around so we don't get into perf issues when
			-- we accumulate too many wreckages
			prop:AddBoundedProp(mass)

			prop:SetScale(bp.Display.UniformScale)
			prop:SetOrientation(self:GetOrientation(), true)
			prop:SetPropCollision('Box', bp.CollisionOffsetX, bp.CollisionOffsetY, bp.CollisionOffsetZ, bp.SizeX* 0.5, bp.SizeY* 0.5, bp.SizeZ * 0.5)

			prop:SetMaxHealth(bp.Defense.Health)
			prop:SetHealth(self, bp.Defense.Health * (bp.Wreckage.HealthMult or 1))

			prop:SetVizToNeutrals('Intel')
            if not bp.Wreckage.UseCustomMesh then
    	        prop:SetMesh(bp.Display.MeshBlueprintWrecked)
            end

            -- Attempt to copy our animation pose to the prop. Only works if
            -- the mesh and skeletons are the same, but will not produce an error
            -- if not.
            TryCopyPose(self,prop,false)

            prop.AssociatedBP = self:GetBlueprint().BlueprintId

			-- Create some ambient wreckage smoke
			CreateWreckageEffects(self,prop)

			-- If this wreckage has a decay time then set in the blueprint use it. For the 360 we will halve the
			-- the any specified decay times. If no bp value is set for the wreckage, we default to a base decay 
			-- of 4 minutes for the PC and 2 minutes on the 360. Since the decay can be negated by blueprints
			-- defining 0 decay, we use values less then or equal to 0 to negate wreckage decaying.
			local decay = bp.Wreckage.Decay or 240

			if decay > 0 then
				if IsXbox() then 
					decay = decay * 0.5
				end

				prop:StartDecay(decay)
			end

			return prop
	    else
	        return nil
		end
    end,

    DeathThread = function( self, overkillRatio, instigator)
		self:Destroy()
    end,

    OnDestroy = function(self)

        self.Dead = true

        -- Clear out our sync data
        UnitData[self:GetEntityId()] = false
        Sync.UnitData[self:GetEntityId()] = false

        -- Don't allow anyone to stuff anything else in the table
        self.Sync = false

        -- Let the user layer know this id is kaput
        Sync.ReleaseIds[self:GetEntityId()] = true

        -- If factory, destroy what I'm building if I die
        if EntityCategoryContains(categories.FACTORY, self) then
            if self.UnitBeingBuilt and not self.UnitBeingBuilt:IsDead() and self.UnitBeingBuilt:GetFractionComplete() != 1 then
                self.UnitBeingBuilt:Destroy()
            end
        end

        -- Destroy everything added to the trash.
        --LOG('*DEBUG: Unit:OnDestroy')
        self.Trash:Destroy()
        
        -- Destroy things in other utility trashbags.
        if self.BuildEffectsBag then
            self.BuildEffectsBag:Destroy()
        end
        if self.CaptureEffectsBag then
			self.CaptureEffectsBag:Destroy()
		end
        if self.ReclaimEffectsBag then
			self.ReclaimEffectsBag:Destroy()
        end
        if self.OnBeingBuiltEffectsBag then
            self.OnBeingBuiltEffectsBag:Destroy()
        end
        if self.UpgradeEffectsBag then
            self.UpgradeEffectsBag:Destroy()
        end
    end,

    --GENERIC FUNCTION FOR SHOWING A TABLE OF BONES
    --TABLE = LIST OF BONES
    --CHILDREND = TRUE/FALSE TO SHOW CHILD BONES
    ShowBones = function(self, table, children)
        --LOG('*DEBUG: IN SHOWBONES TABLE = ', repr(table))
        for k, v in table do
            if self:IsValidBone(v) then
                self:ShowBone(v, children)
            else
                LOG('*WARNING: TRYING TO SHOW BONE ', repr(v), ' ON UNIT ',repr(self:GetUnitId()),' BUT IT DOES NOT EXIST IN THE MODEL. PLEASE CHECK YOUR SCRIPT IN THE BUILD PROGRESS BONES.')
            end
        end
    end,

    OnFerryPointSet = function(self)
        local bp = self:GetBlueprint().Audio
        if bp then
            local aiBrain = self:GetAIBrain()
            local factionIndex = aiBrain:GetFactionIndex()
            if factionIndex == 1 then
                if bp['FerryPointSetByUEF'] then
                    aiBrain:FerryPointSet(bp['FerryPointSetByUEF'])
                end
            elseif factionIndex == 2 then
                if bp['FerryPointSetByCybran'] then
                    aiBrain:FerryPointSet(bp['FerryPointSetByCybran'])
                end
            elseif factionIndex == 3 then
                if bp['FerryPointSetByIlluminate'] then
                    aiBrain:FerryPointSet(bp['FerryPointSetByIlluminate'])
                end
            end
        end
    end,

    OnDamageBy = function(self,index)
        local bp = self:GetBlueprint().Audio
        if bp then
            local aiBrain = self:GetAIBrain()
            local factionIndex = aiBrain:GetFactionIndex()
            if factionIndex == 1 then
                if bp['UnderAttackUEF'] then
                    aiBrain:UnderAttack(bp['UnderAttackUEF'])
                end
                if EntityCategoryContains(categories.STRUCTURE, self) then
                    if bp['BaseUnderAttackUEF'] then
                        aiBrain:BaseUnderAttack(bp['BaseUnderAttackUEF'])
                    end
                end
            elseif factionIndex == 2 then
                if bp['UnderAttackCybran'] then
                    aiBrain:UnderAttack(bp['UnderAttackCybran'])
                end
                if EntityCategoryContains(categories.STRUCTURE, self) then
                    if bp['BaseUnderAttackCybran'] then
                        aiBrain:BaseUnderAttack(bp['BaseUnderAttackCybran'])
                    end
                end
            elseif factionIndex == 3 then
                if bp['UnderAttackIlluminate'] then
                    aiBrain:UnderAttack(bp['UnderAttackIlluminate'])
                end
                if EntityCategoryContains(categories.STRUCTURE, self) then
                    if bp['BaseUnderAttackIlluminate'] then
                        aiBrain:BaseUnderAttack(bp['BaseUnderAttackIlluminate'])
                    end
                end
            end
        end
    end,

    OnNukeArmed = function(self)
        local bp = self:GetBlueprint().Audio
        if bp then
            local aiBrain = self:GetAIBrain()
            local factionIndex = aiBrain:GetFactionIndex()
            if factionIndex == 1 then
                if bp['NukeArmedUEF'] then
                    aiBrain:NukeArmed(bp['NukeArmedUEF'])
                end
            elseif factionIndex == 2 then
                if bp['NukeArmedCybran'] then
                    aiBrain:NukeArmed(bp['NukeArmedCybran'])
                end
            elseif factionIndex == 3 then
                if bp['NukeArmedIlluminate'] then
                    aiBrain:NukeArmed(bp['NukeArmedIlluminate'])
                end
            end
        end
    end,

    OnNukeLaunched = function(self)
    end,

    NukeCreatedAtUnit = function(self)
        if self:GetNukeSiloAmmoCount() <= 0 then
            return
        end
        local bp = self:GetBlueprint().Audio
        local unitBrain = self:GetAIBrain()
        if bp then
            for num, aiBrain in ArmyBrains do
                local factionIndex = aiBrain:GetFactionIndex()
                if unitBrain == aiBrain then
                    if bp['NuclearLaunchInitiated'] then
                        aiBrain:NuclearLaunchInitiated(bp['NuclearLaunchInitiated'])
                    end
                else
                    if bp['NuclearLaunchDetected'] then
                        aiBrain:NuclearLaunchDetected(bp['NuclearLaunchDetected'])
                    end
                end
            end
        end
    end,

    OnKilledVO = function(self)
        local bp = self:GetBlueprint().Audio
        if bp then
            for num, aiBrain in ArmyBrains do
                local factionIndex = aiBrain:GetFactionIndex()
                if factionIndex == 1 then
                    if bp['ExperimentalUnitDestroyedUEF'] then
                        aiBrain:ExperimentalUnitDestroyed(bp['ExperimentalUnitDestroyedUEF'])
                    elseif bp['BattleshipDestroyedUEF'] then
                        aiBrain:BattleshipDestroyed(bp['BattleshipDestroyedUEF'])
                    end
                elseif factionIndex == 2 then
                    if bp['ExperimentalUnitDestroyedCybran'] then
                        aiBrain:ExperimentalUnitDestroyed(bp['ExperimentalUnitDestroyedCybran'])
                    elseif bp['BattleshipDestroyedCybran'] then
                        aiBrain:BattleshipDestroyed(bp['BattleshipDestroyedCybran'])
                    end
                elseif factionIndex == 3 then
                    if bp['ExperimentalUnitDestroyedIlluminate'] then
                        aiBrain:ExperimentalUnitDestroyed(bp['ExperimentalUnitDestroyedIlluminate'])
                    elseif bp['BattleshipDestroyedIlluminate'] then
                        aiBrain:BattleshipDestroyed(bp['BattleshipDestroyedIlluminate'])
                    end
                end
            end
        end
    end,

    SetAllWeaponsEnabled = function(self, enable)
        for i = 1, self:GetWeaponCount() do
            local wep = self:GetWeapon(i)
            wep:SetEnabled(enable)
            wep:AimManipulatorSetEnabled(enable)
        end
    end,

    SetWeaponEnabledByLabel = function(self, label, enable)
        local wep = self:GetWeapon(label)
        if not wep then 
			WARN( 'SetWeaponEnabledByLabel, trying to set weapon with label:  ', label, ' and it does not exit on this unit' )
			return 
		end
        if not enable then
            wep:OnLostTarget()
        end
        wep:SetEnabled(enable)
        wep:AimManipulatorSetEnabled(enable)
    end,

    GetWeaponManipulatorByLabel = function(self, label)
        local wep = self:GetWeapon(label)
        return wep:GetAimManipulator()
    end,

    GetWeaponsByWeaponCategory = function( self, category )
		local weapons = {}
		local wep
        for i = 1, self:GetWeaponCount() do
            wep = self:GetWeapon(i)
            if (wep:GetBlueprint().WeaponCategory == category) then
				table.insert( weapons, wep )
            end
        end

		if not table.empty( weapons ) then
			return weapons
		end

        return nil
    end,

    ResetWeaponByLabel = function(self, label)
        local wep = self:GetWeapon(label)
        wep:ResetTarget()
    end,

    SetDeathWeaponEnabled = function(self, enable)
        self.DeathWeaponEnabled = enable
    end,

    --*******************************************************************
    -- CONSTRUCTING - BEING BUILT
    --*******************************************************************
    OnStartBeingBuilt = function(self, builder, layer)
        self:StartBeingBuiltEffects(builder, layer)
        local aiBrain = self:GetAIBrain()
        if table.getn(aiBrain.UnitBuiltTriggerList) > 0 then
            for k,v in aiBrain.UnitBuiltTriggerList do
                if EntityCategoryContains(v.Category, self) then
                    self:ForkThread(self.UnitBuiltPercentageCallbackThread, v.Percent, v.Callback)
                end
            end
        end
    end,

    UnitBuiltPercentageCallbackThread = function(self, percent, callback)
        while not self:IsDead() and self:GetHealthPercent() < percent do
            WaitSeconds(1)
        end
        local aiBrain = self:GetAIBrain()
        for k,v in aiBrain.UnitBuiltTriggerList do
            if v.Callback == callback then
                callback(self)
                aiBrain.UnitBuiltTriggerList[k] = nil
            end
        end
    end,

    OnStopBeingBuilt = function(self, builder, layer)
        local bp = self:GetBlueprint()
        self:SetupIntel()
        self:ForkThread( self.StopBeingBuiltEffects, builder, layer )

        if bp.Defense.LifeTime then
            self:ForkThread(self.LifeTimeThread)
        end

        self:PlayUnitSound('DoneBeingBuilt')
        self:PlayUnitAmbientSound( 'ActiveLoop' )

        if self.DisallowCollisions and builder then
            self.DisallowCollisions = false
            local healthPercentage = builder:GetHealthPercent()
            local newHealthAmount = healthPercentage * self:GetBlueprint().Defense.MaxHealth
            self:SetHealth(self, newHealthAmount)
        end

        -- Create any idle effects on unit
        if( table.getn( self.IdleEffectsBag ) == 0) then
            self:CreateIdleEffects()
        end

        -- If we have a shield spec'd create it.
        if bp.Defense.Shield.StartOn != false then
            self:CreateShield()
        end

        if bp.Display.AnimationPermOpen then
            self.PermOpenAnimManipulator = CreateAnimator(self):PlayAnim(bp.Display.AnimationPermOpen)
            self.Trash:Add(self.PermOpenAnimManipulator)
        end

        -- Initialize movement effects subsystems, idle effects, beam exhaust, and footfall manipulators
        local bpTable = bp.Display.MovementEffects
        if bpTable.Land or bpTable.Air or bpTable.Water or bpTable.Sub or bpTable.BeamExhaust then
            self.MovementEffectsExist = true
            if bpTable.BeamExhaust and (bpTable.BeamExhaust.Idle != false) then
                self:UpdateBeamExhaust( 'Idle' )
            end
            if not self.Footfalls and bpTable[layer].Footfall then
                --LOG('Creating Footfall Manips')
                self.Footfalls = self:CreateFootFallManipulators( bpTable[layer].Footfall )
            end
        else
            self.MovementEffectsExist = false
        end

		--*******************************************************************
		-- SC2: research tracking
        local aiBrain = self:GetAIBrain()
		aiBrain:ApplyAllResearchToUnit( self )
		--*******************************************************************

		Unit.ClassCallbacks.OnStopBeingBuilt:Call( self, builder, layer )
    end,

    StartBeingBuiltEffects = function(self, builder, layer)
    end,

    StopBeingBuiltEffects = function(self, builder, layer)
        local bp = self:GetBlueprint().Display
        local useTerrainType = false
        if bp then
            if bp.TerrainMeshes then
                local bpTM = bp.TerrainMeshes
                local pos = self:GetPosition()
                local terrainType = GetTerrainType( pos[1], pos[3] )
                if bpTM[terrainType.Style] then
                    self:SetMesh(bpTM[terrainType.Style])
                    useTerrainType = true
                end
            end
        end
        self.OnBeingBuiltEffectsBag:Destroy()
    end,

    OnFailedToBeBuilt = function(self)
        self:Destroy()
    end,

    OnSiloBuildStart = function(self, weapon)
        self.SiloWeapon = weapon
        self.SiloProjectile = weapon:GetProjectileBlueprint()
    end,

    OnSiloBuildEnd = function(self, weapon)
        self.SiloWeapon = nil
        self.SiloProjectile = nil
    end,

    --*******************************************************************
    -- CONSTRUCTING - BUILDING - REPAIR
    --*******************************************************************
    OnStartBuild = function(self, unitBeingBuilt, order)
		if order != 'Repair' then
			self:SetActiveConsumptionActive()
		end

        self.Callbacks.OnStartBuild:Call( self, unitBeingBuilt )

        self:PlayUnitSound('Construct')
        self:PlayUnitAmbientSound('ConstructLoop')
    end,

    OnStopBuild = function(self, unitBeingBuilt, order)
		if order != 'Repair' then
			self:SetActiveConsumptionInactive()
		end

		-- Callbacks
		Unit.ClassCallbacks.OnStopBuild:Call( self, unitBeingBuilt )
		self.Callbacks.OnStopBuild:Call( self, unitBeingBuilt )

		-- Audio triggers
		self:StopUnitAmbientSound('ConstructLoop')
        self:PlayUnitSound('ConstructStop')

        self:StopBuildingEffects(unitBeingBuilt)
    end,

    GetUnitBeingBuilt = function(self)
        return self.UnitBeingBuilt
    end,

    OnFailedToBuild = function(self)
        self:SetActiveConsumptionInactive()
        self:StopUnitAmbientSound('ConstructLoop')
    end,

    OnPrepareArmToBuild = function(self)
    end,

    OnStartBuilderTracking = function(self)
    end,

    OnStopBuilderTracking = function(self)
    end,

    OnBuildProgress = function(self, unit, oldProg, newProg)
    end,

    StartBuildingEffects = function(self, unitBeingBuilt, order)
        self.BuildEffectsBag:Add( self:ForkThread( self.CreateBuildEffects, unitBeingBuilt, order ) )
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
    end,

    StopBuildingEffects = function(self, unitBeingBuilt)
        self.BuildEffectsBag:Destroy()
    end,

    --*******************************************************************
    -- INTEL
    --*******************************************************************
    --Setup the initial intelligence of the unit.  Return true if it can, false if it can't.
    SetupIntel = function(self)
        local bp = self:GetBlueprint().Intel
        self:EnableIntel('Vision')
        if bp then
            self.IntelDisables = {
                Radar = 1,
                Sonar = 1,
                Omni = 1,
                RadarStealth = 1,
                SonarStealth = 1,
                RadarStealthField = 1,
                SonarStealthField = 1,
                Cloak = 1,
                CloakField = 1,
                Spoof = 1,
                Jammer = 1,
            }
            self:EnableUnitIntel(nil)
            return true
        end
        return false
    end,

    DisableUnitIntel = function(self, intel)
		local intDisabled = false
        if not self.IntelDisables then return end
        if intel then
            self.IntelDisables[intel] = self.IntelDisables[intel] + 1
            if self.IntelDisables[intel] == 1 then
				--LOG('*DEBUG: Disabling Intel: ', repr(intel))
				self:DisableIntel(intel)
				intDisabled = true
			end
        else
            for k, v in self.IntelDisables do
                self.IntelDisables[k] = v + 1
                if self.IntelDisables[k] == 1 then
                    --LOG('*DEBUG: Disabling Intel: ', repr(k))
                    self:DisableIntel(k)
                    intDisabled = true
                end
            end
        end
        if intDisabled then
			self:OnIntelDisabled()
		end
    end,

    EnableUnitIntel = function(self, intel)
        local layer = self:GetCurrentLayer()
        local bp = self:GetBlueprint()
        local intEnabled = false
        if layer == 'Seabed' or layer == 'Sub' or layer == 'Water' then
            self:EnableIntel('WaterVision')
        end
        if intel then
            if self.IntelDisables[intel] == 1 then
                self:EnableIntel(intel)
                --LOG('*DEBUG: Enabling Intel: ', repr(intel))
                intEnabled = true
            end
            self.IntelDisables[intel] = self.IntelDisables[intel] - 1
        else
            for k, v in self.IntelDisables do
                if v == 1 then
                    self:EnableIntel(k)
                    --LOG('*DEBUG: Enabling Intel: ', repr(k))
                    if self:IsIntelEnabled(k) then
                        intEnabled = true
                    end
                end
                self.IntelDisables[k] = v - 1
            end
        end

        if intEnabled then
            self:OnIntelEnabled()
        end
    end,

    OnIntelEnabled = function(self)

    end,

    OnIntelDisabled = function(self)

    end,

    AddDetectedByHook = function(self,hook)
        if not self.DetectedByHooks then
            self.DetectedByHooks = {}
        end
        table.insert(self.DetectedByHooks,hook)
    end,

    RemoveDetectedByHook = function(self,hook)
        if self.DetectedByHooks then
            for k,v in self.DetectedByHooks do
                if v == hook then
                    table.remove(self.DetectedByHooks,k)
                    return
                end
            end
        end
    end,

    OnDetectedBy = function(self, index)
        if self.DetectedByHooks then
            for k,v in self.DetectedByHooks do
                v(self,index)
            end
        end

        local bp = self:GetBlueprint().Audio
        if bp then
            local aiBrain = ArmyBrains[index]
            local factionIndex = aiBrain:GetFactionIndex()
            if factionIndex == 1 then
                if bp['ExperimentalDetectedByUEF'] then
                    aiBrain:ExperimentalDetected(bp['ExperimentalDetectedByUEF'])
                elseif bp['EnemyForcesDetectedByUEF'] then
                    aiBrain:EnemyForcesDetected(bp['EnemyForcesDetectedByUEF'])
                end
            elseif factionIndex == 2 then
				if bp['ExperimentalDetectedByCybran'] then
                    aiBrain:ExperimentalDetected(bp['ExperimentalDetectedByCybran'])
                elseif bp['EnemyForcesDetectedByCybran'] then
                    aiBrain:EnemyForcesDetected(bp['EnemyForcesDetectedByCybran'])
                end
			elseif factionIndex == 3 then
                if bp['ExperimentalDetectedByIlluminate'] then
                    aiBrain:ExperimentalDetected(bp['ExperimentalDetectedByIlluminate'])
                elseif bp['EnemyForcesDetectedByIlluminate'] then
                    aiBrain:EnemyForcesDetected(bp['EnemyForcesDetectedByIlluminate'])
                end
            end
        end
    end,

    --*******************************************************************
    --
    --*******************************************************************
    OnLayerChange = function(self, new, old)
        --LOG('LayerChange old=',old,' new=',new,' for ',self:GetBlueprint().BlueprintId )

        if old == 'Seabed' and new == 'Land' then
            self:EnableIntel('Vision')
            self:DisableIntel('WaterVision')
			self:TransitionDamageEffects()
        elseif old == 'Land' and new == 'Seabed' then
            self:EnableIntel('WaterVision')
			self:TransitionDamageEffects()
        end

		-- Layer change callback
		self.Callbacks.OnLayerChange:Call(self, new, old)
    end,

    GetTerrainTypeEffects = function( FxType, layer, pos, type, typesuffix )
        local TerrainType

        -- Get terrain type mapped to local position and if none defined use default
        if type then
            TerrainType = GetTerrainType( pos.x,pos.z )
        else
            TerrainType = GetTerrainType( -1, -1 )
            type = 'Default'
        end

        -- Add in type suffix to type mask name
        if typesuffix then
            type = type .. typesuffix
        end

        -- If our current masking is empty try and get the default layer effect
        if TerrainType[FxType][layer][type] == nil then
			TerrainType = GetTerrainType( -1, -1 )
		end

        --LOG( 'GetTerrainTypeEffects ', TerrainType.Name .. ' ' .. TerrainType.Description, ' ', layer, ' ', type )
        return TerrainType[FxType][layer][type] or {}
    end,

    CreateTerrainTypeEffects = function( self, effectTypeGroups, FxBlockType, FxBlockKey, TypeSuffix, EffectBag, TerrainType )
        local army = self:GetArmy()
        local pos = self:GetPosition()
        local effects = {}
        local emit = nil

        for kBG, vTypeGroup in effectTypeGroups do
            if TerrainType then
                effects = TerrainType[FxBlockType][FxBlockKey][vTypeGroup.Type] or {}
            else
                effects = self.GetTerrainTypeEffects( FxBlockType, FxBlockKey, pos, vTypeGroup.Type, TypeSuffix )
            end

            if not vTypeGroup.Bones or (vTypeGroup.Bones and (table.getn(vTypeGroup.Bones) == 0)) then
                LOG('*WARNING: No effect bones defined for layer group ',repr(self:GetUnitId()),', Add these to a table in Display.[EffectGroup].', self:GetCurrentLayer(), '.Effects { Bones ={} } in unit blueprint.' )
                continue
            end

            for kb, vBone in vTypeGroup.Bones do
                for ke, vEffect in effects do
                    emit = CreateAttachedEmitter(self,vBone,army,vEffect):ScaleEmitter(vTypeGroup.Scale or 1)
                    if vTypeGroup.Offset then
                        emit:OffsetEmitter(vTypeGroup.Offset[1] or 0, vTypeGroup.Offset[2] or 0,vTypeGroup.Offset[3] or 0)
                    end
                    if EffectBag then
                        table.insert( EffectBag, emit )
                    end
                end
            end
        end
    end,

    CreateIdleEffects = function( self )
        local layer = self:GetCurrentLayer()
        local bpTable = self:GetBlueprint().Display.IdleEffects
        if bpTable[layer] and bpTable[layer].Effects then
            self:CreateTerrainTypeEffects( bpTable[layer].Effects, 'FXIdle',  layer, nil, self.IdleEffectsBag )
        end
    end,

    DestroyIdleEffects = function( self )
        CleanupEffectBag(self,'IdleEffectsBag')
    end,

    UpdateBeamExhaust = function( self, motionState )
    end,

    CreateContrails = function(self, tableData )
    end,

    MovementCameraShakeThread = function( self, camShake )
        local radius = camShake.Radius or 5.0
        local maxShakeEpicenter = camShake.MaxShakeEpicenter or 1.0
        local minShakeAtRadius = camShake.MinShakeAtRadius or 0.0
        local interval = camShake.Interval or 10.0
        if interval != 0.0 then
            while true do
                self:ShakeCamera( radius, maxShakeEpicenter, minShakeAtRadius, interval )
                WaitSeconds(interval)
            end
        end
    end,

    CreateTreads = function(self, treads)
        if treads.ScrollTreads then
            self:AddThreadUVRScroller(1, 1, 1.0, treads.ScrollMultiplier or 0.2)
            self:AddThreadUVRScroller(2, 1, -1.0, treads.ScrollMultiplier or 0.2)
        end
        self.TreadThreads = {}
        if treads.TreadMarks then
            local type = self:GetTTTreadType(self:GetPosition())
            if type != 'None' then
                for k, v in treads.TreadMarks do
                    table.insert( self.TreadThreads, self:ForkThread(self.CreateTreadsThread, v, type ))
                end
            end
        end
    end,

    CreateTreadsThread = function(self, treads, type )
        local sizeX = treads.TreadMarksSizeX
        local sizeZ = treads.TreadMarksSizeZ
        local interval = treads.TreadMarksInterval
        local treadOffset = treads.TreadOffset
        local treadBone = treads.BoneName or 0
        local treadTexture = treads.TreadMarks
        local duration = treads.TreadLifeTime or 10
        local army = self:GetArmy()

        while true do
            -- Syntatic reference
            -- CreateSplatOnBone(entity, offset, boneName, textureName, sizeX, sizeZ, lodParam, duration, army)
            CreateSplatOnBone(self, treadOffset, treadBone, treadTexture, sizeX, sizeZ, 130, duration, army)
            WaitSeconds(interval)
        end
    end,

    CreateFootFallManipulators = function( self, footfall )
        if not footfall.Bones or (footfall.Bones and (table.getn(footfall.Bones) == 0)) then
            LOG('*WARNING: No footfall bones defined for unit ',repr(self:GetUnitId()),', ', 'these must be defined to animation collision detector and foot plant controller' )
            return false
        end

        self.Detector = CreateCollisionDetector(self)
        self.Trash:Add(self.Detector)
        for k, v in footfall.Bones do
            self.Detector:WatchBone(v.FootBone)
            if v.FootBone and v.KneeBone and v.HipBone then
                CreateFootPlantController(self, v.FootBone, v.KneeBone, v.HipBone, v.AnkleBone or -1, v.StraightLegs or true, v.MaxFootFall or 0, v.OrientFoot or false, v.OrientFootAngleMax or 20, v.OrientFootBlendHeight or 0):SetPrecedence(10)
            end
        end
        return true
    end,
    
	GetBuildScaffoldUnit = function(self)
		return nil
	end,

    -- Return the total time in seconds, cost in energy, and cost in mass to build the given target type.
    GetBuildCosts = function(self, target_bp)
        return Game.GetConstructEconomyModel(self, target_bp.Economy)
    end,

    GetWeaponClass = function(self, label)
        return self.Weapons[label] or import('/lua/sim/Weapon.lua').Weapon
    end,

    -- Return the Bonus Build Multiplier for the target we are re-building if we are trying to rebuild the same
    -- structure that was destroyed earlier.
    GetRebuildBonus = function(self, rebuildUnitBP)
        -- for now everything is re-built is 50% complete to begin with
        return 0.5
    end,

    GetHealthPercent = function(self)
        local health = self:GetHealth()
        local maxHealth = self:GetBlueprint().Defense.MaxHealth
        return health / maxHealth
    end,

    ValidateBone = function(self, bone)
        if self:IsValidBone(bone) then
            return true
        end
        error('*ERROR: Trying to use the bone, ' .. bone .. ' on unit ' .. self:GetUnitId() .. ' and it does not exist in the model.', 2)
        return false
    end,

    PlayUnitSound = function(self, sound)
        local bp = self:GetBlueprint().Audio
        if bp and bp[sound] then
            --LOG( 'Playing ', sound )
            self:PlaySound(bp[sound])
            return true
        end
        --LOG( 'Could not play ', sound )
        return false
    end,

    PlayUnitAmbientSound = function(self, sound)
        local bp = self:GetBlueprint()
        local id = bp.BlueprintId
        if not bp.Audio[sound] then return false end
        if not self.AmbientSounds then
            self.AmbientSounds = {}
        end
        if not self.AmbientSounds[sound] then
			-- We're setting the army here to that of the parent, so other armies do not hear the sound if they should not.
            local sndEnt = Entity { Army = self:GetArmy() }
            self.AmbientSounds[sound] = sndEnt
            self.Trash:Add(sndEnt)
            sndEnt:AttachTo(self,-1)
        end
        self.AmbientSounds[sound]:SetAmbientSound( bp.Audio[sound], nil )
        return true
    end,

    StopUnitAmbientSound = function(self, sound)
        local id = self:GetUnitId()
        if not self.AmbientSounds then return end
        if not self.AmbientSounds[sound] then return end
        self.AmbientSounds[sound]:SetAmbientSound(nil, nil)
        self.AmbientSounds[sound]:Destroy()
        self.AmbientSounds[sound] = nil
    end,

    --*******************************************************************
    -- UNIT CALLBACKS
    --*******************************************************************
    AddOnCapturedCallback = function(self, cbOldUnit, cbNewUnit)
        --LOG("*DEBUG: ONCAPTURED Callback made")
        if not cbOldUnit and not cbNewUnit then
            error('*ERROR: Tried to add an OnCaptured callback without any functions', 2)
            return
        end
        if cbOldUnit then
            self.Callbacks.OnCaptured:Add(cbOldUnit)
        end
        if cbNewUnit then
            self.Callbacks.OnCapturedNewUnit:Add(cbNewUnit)
        end
    end,

    --*******************************************************************
    -- EXPERIENCE/ VETERANCY
    --*******************************************************************
	OnAwardExperience = function( self, new, total )
		local expTableKey = self:GetBlueprint().General.ExperienceTable
		local expTable = Experience[expTableKey]

		if not expTable then
			LOG('OnAwardExperience, Unit ', self:GetBlueprint().Display.DisplayName, ' defined experience table (', expTableKey, ') is not defined!')
			return
		end

		local maxLevel = table.getn(expTable.ExperienceToLevel)

		if self.Level <= maxLevel then
			local levelGain = 0

			-- Check for multiple levels gained from this new experience
			while levelGain + self.Level <= maxLevel do
                if total >= expTable.ExperienceToLevel[self.Level + levelGain] then
                    levelGain = levelGain + 1
                else
                    break
                end
			end

			-- If we've gained any levels
			if levelGain > 0 then

				-- Apply any affects gained for each new level
				for i=0, levelGain - 1 do
					if expTable.LevelRewards[self.Level + i].Buff then
						ApplyBuff( self, expTable.LevelRewards[self.Level + i].Buff  )
					end
				end

				self.Level = self.Level + levelGain
				self.VeteranLevel = self.VeteranLevel + levelGain
				self:GetAIBrain():OnBrainUnitVeterancyLevel(self, self.VeteranLevel )
			end
		end
        local aiBrain = self:GetAIBrain()
        if aiBrain then
            aiBrain:AwardResearchExperience(new)
        end
	end,

	SetVeterancy = function( self, veteranLevel )
		local expTableKey = self:GetBlueprint().General.ExperienceTable
		local expTable = Experience[expTableKey]
        
		if not expTable then
			--LOG('SetVeterancy, Unit ', self:GetBlueprint().Display.DisplayName, ' defined experience table (', expTableKey, ') is not defined!')
			return
		end
        
        local maxLevel = table.getn(expTable.ExperienceToLevel)
        if self.Level > veteranLevel then
            --LOG('Trying to set a unit to a lower Veteran Level than it currently is')
            return
        end
        if veteranLevel > maxLevel then
            LOG('Trying to set a unit to a higher Veteran Level than the max level of '..maxLevel)
			return
        end
        
        local currentExperience = self:GetCurrentExperience()
        local expToLevel = expTable.ExperienceToLevel[veteranLevel]
        local expToGive = expToLevel - currentExperience
        
        self:AwardExperience(expToGive)        
	end,

    --*******************************************************************
    -- SHIELDS
    --*******************************************************************
    CreateShield = function(self, shieldSpec)
		local bp = self:GetBlueprint()
        local bpShield = shieldSpec
        if not shieldSpec then
            bpShield = bp.Defense.Shield
        end
		if bpShield.ShieldSize == 0 and not bpShield.OwnerShieldTextureSet then
			return
		end
        if bpShield then
            self:DestroyShield()
            self.MyShield = Shield {
                Owner = self,

				CollisionShape = bpShield.CollisionShape or 'Box',
                SizeX = bpShield.SizeX or 1,
                SizeY = bpShield.SizeY or 1,
                SizeZ = bpShield.SizeZ or (bpShield.ShieldSize * 0.5) or 1,
                ParentOffsetX = bpShield.CollisionOffsetX or 0,
                ParentOffsetY = bpShield.CollisionOffsetY or 0,
                ParentOffsetZ = bpShield.CollisionOffsetZ or 0,

				DrawScale = bpShield.ShieldSize or 10,
				ImpactEffects = bpShield.ImpactEffects or nil,
				MeshBlueprint = bpShield.Mesh or nil,
				OwnerShieldTextureSet = bpShield.OwnerShieldTextureSet or '',

				ShieldType = bpShield.ShieldType or '',
				PanelArray = bpShield.PanelArray or nil,

				AllowPenetration = bpShield.AllowPenetration or false,
                AbsorbEnergySpongePercent = bpShield.AbsorbEnergySpongePercent or 0,
				DamageAbsorb = bpShield.ShieldDamageAbsorb or 0,
                Health = bpShield.ShieldMaxHealth or 250,
                RechargeTime = bpShield.ShieldRechargeTime or nil,
                RegenRate = bpShield.ShieldRegenRate or 1,
				ReflectChance = bpShield.ShieldReflectChance or 0,
				ReflectRandomVector = bpShield.ShieldReflectRandomVector or false,
            }

            self.Trash:Add(self.MyShield)
        end
    end,

    OnShieldEnabled = function(self)
        --self:PlayUnitSound('Activate')
        self:PlayUnitSound('ShieldOn')
        -- Make the shield drain energy
        self:SetMaintenanceConsumptionActive()
    end,

    OnShieldDisabled = function(self)
        --self:PlayUnitSound('Deactivate')
        self:PlayUnitSound('ShieldOff')
        -- Turn off the energy drain
        self:SetMaintenanceConsumptionInactive()
    end,

    EnableShield = function(self)
        if self.MyShield then
            self.MyShield:TurnOn()
        end
    end,

    DisableShield = function(self)
        if self.MyShield then
            self.MyShield:TurnOff()
        end
    end,

    DestroyShield = function(self)
        if self.MyShield then
            self.MyShield:Destroy()
            self.MyShield = nil
        end
    end,

	GetShield = function(self)
		return self.MyShield or nil
	end,

    ShieldIsOn = function(self)
        if self.MyShield then
            return self.MyShield:IsShieldActive()
        else
            return false
        end
    end,

    ShieldDamageAbsorbed = function(self, damage)
    end,
    
    GetShieldHealth = function(self)
        if not self.MyShield or not self.MyShield:IsShieldActive() then
            return 0
        end
        
        return self.MyShield:GetHealth()
    end,

    --*******************************************************************
    -- TRANSPORTING
    --*******************************************************************
    MarkWeaponsOnTransport = function(self, unit, transport)
        --Mark the weapons on a transport
        if unit then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                wep:SetOnTransport(transport)
            end
        end
    end,
	
	HaltAllWeapons = function(self, unit)
		if unit then
			for i = 1, unit:GetWeaponCount() do
				local wep = unit:GetWeapon(i)
				wep:OnHaltFire()
			end
		end
	end,

    DestroyedOnTransport = function(self)
        self.Callbacks.OnDestroyedOnTransport:Call(self)
    end,

    OnTransportAttach = function(self, attachBone, unit)
        self:PlayUnitSound('Load')
        self:MarkWeaponsOnTransport(unit, true)
        if unit:ShieldIsOn() then
            unit:DisableShield()
            unit:DisableDefaultToggleCaps()
        end
        if not EntityCategoryContains(categories.PODSTAGINGPLATFORM, self) then
            self:RequestRefreshUI()
        end
		self.OnTransport = true
    end,

    OnTransportDetach = function(self, attachBone, unit)
        self:PlayUnitSound('Unload')
        self:MarkWeaponsOnTransport(unit, false)
        unit:EnableShield()
        unit:EnableDefaultToggleCaps()
        if not EntityCategoryContains(categories.PODSTAGINGPLATFORM, self) then
            self:RequestRefreshUI()
        end
        unit:TransportAnimation(-1)
		self:CreateIdleEffects()
		self.OnTransport = false
    end,

    OnAddToStorage = function(self, unit)
		CreateTeleportEffects(self,false)
        --self:MarkWeaponsOnTransport(self, true)
		self:SetAttackerEnableState(false)
		self:HaltAllWeapons(self)
        self:HideMesh()
        self:SetCanTakeDamage(false)
        self:SetReclaimable(false)
        self:SetCapturable(false)
		self:SetDoNotTarget(true)
        self:DisableShield()
		self:SetCollisionTestType('None')
        unit:PlayUnitSound('Load')
        if EntityCategoryContains(categories.TRANSPORTATION, self) then
            local cargo = self:GetCargo()
            if table.getn(cargo) > 0 then
                for k, v in cargo do
                    --v:MarkWeaponsOnTransport(self, true)
					v:SetAttackerEnableState(false)
					v:HaltAllWeapons(self)
                    v:HideMesh()
                    v:SetCanTakeDamage(false)
                    v:SetReclaimable(false)
                    v:SetCapturable(false)
					v:SetDoNotTarget(true)
                    v:DisableShield()
                end
            end
        end
		self.OnTransport = true
    end,

    OnRemoveFromStorage = function(self, unit)
        self:SetCanTakeDamage(true)
        self:SetReclaimable(true)
        self:SetCapturable(true)
		self:SetDoNotTarget(false)
        self:ShowMesh()
        --self:MarkWeaponsOnTransport(self, false)
		self:SetAttackerEnableState(true)
        self:EnableShield()
		self:SetCollisionTestType('Unit')
        unit:PlayUnitSound('Unload')
        if EntityCategoryContains(categories.TRANSPORTATION, self) then
            local cargo = self:GetCargo()
            if table.getn(cargo) > 0 then
                for k, v in cargo do
                    --v:MarkWeaponsOnTransport(self, false)
					v:SetAttackerEnableState(true)
                    v:ShowMesh()
                    v:SetCanTakeDamage(true)
                    v:SetReclaimable(true)
                    v:SetCapturable(true)
					v:SetDoNotTarget(false)
                    v:EnableShield()
                end
            end
        end
		CreateTeleportEffects(self,true)
		self:CreateIdleEffects()
		self.OnTransport = false
    end,

    GetTransportClass = function(self)
        local bp = self:GetBlueprint().Transport
        return bp.TransportClass
    end,

    TransportAnimation = function(self, rate)
        self:ForkThread( self.TransportAnimationThread, rate )
    end,

    TransportAnimationThread = function(self,rate)
        local bp = self:GetBlueprint().Display.TransportAnimation

        if rate and rate < 0 and self:GetBlueprint().Display.TransportDropAnimation then
            bp = self:GetBlueprint().Display.TransportDropAnimation
            rate = -rate
        end

        WaitSeconds(.5)
        if bp then
            local animBlock = self:ChooseAnimBlock( bp )
            if animBlock.Animation then
                if not self.TransAnimation then
                    self.TransAnimation = CreateAnimator(self)
                    self.Trash:Add(self.TransAnimation)
                end
                self.TransAnimation:PlayAnim(animBlock.Animation)
                rate = rate or 1
                self.TransAnimation:SetRate(rate)
                WaitFor(self.TransAnimation)
            end
        end
    end,

    --*******************************************************************
    -- TELEPORTING
    --*******************************************************************
    OnTeleportUnit = function(self, teleporter, location, orientation)
        if self.TeleportThread then
            KillThread(self.TeleportThread)
            self.TeleportThread = nil
        end
        self.TeleportThread = self:ForkThread(self.InitiateTeleportThread, teleporter, location, orientation)
    end,

    OnFailedTeleport = function(self)
        if self.TeleportThread then
            KillThread(self.TeleportThread)
            self.TeleportThread = nil
        end
        self:StopUnitAmbientSound('TeleportLoop')
        self:SetWorkProgress(0.0)
        self:SetImmobile(false)
        self.UnitBeingTeleported = nil
    end,

    UpdateTeleportProgress = function(self, progress)
        --LOG(' UpdatingTeleportProgress ')
        self:SetWorkProgress(progress)
    end,

    InitiateTeleportThread = function(self, teleporter, location, orientation)
        local tbp = teleporter:GetBlueprint()
        local ubp = self:GetBlueprint()
        self.UnitBeingTeleported = self
        self:SetImmobile(true)
        self:PlayUnitSound('TeleportStart')
        self:PlayUnitAmbientSound('TeleportLoop')

        CreateTeleportEffects( self )
        Warp(self, location, orientation)
        CreateTeleportEffects( self )

        --Landing Sound
        self:StopUnitAmbientSound('TeleportLoop')
        self:PlayUnitSound('TeleportEnd')
        self:SetImmobile(false)
        self.UnitBeingTeleported = nil
        self.TeleportThread = nil
    end,
    
--[[
    ----------------------------------------------------------------------------------------
	-- ** Available methods for use, but currently un-necessary to define for all units. **
	----------------------------------------------------------------------------------------

	-- For a unit with weapons, the attacker logic will send this script event, when it
	-- determines a good target for the unit and it's weapons to attack.
	OnAttackerSetDesiredTarget = function(self, target)
	end,

	-- On 25%, 50%, and 75%, this build progress event triggers for unit's being built
    OnBeingBuiltProgress = function(self, unit, oldProg, newProg)
    end,

	-- Transport load/unload events
    OnTransportAborted = function(self)
    end,

    OnTransportOrdered = function(self)
    end,

    OnStartTransportLoading = function(self)
    end,

    OnStopTransportLoading = function(self)
    end,

    OnStartTransportUnloading = function(self)
    end,

    OnStopTransportUnloading = function(self)
    end,
    
    OnTransportUnloadUnit = function(self,unit)
    end,

	-- Teleporter single unit load/unload events
	OnAssignTeleportSpot = function(self,unitBeingTeleported,loadPosition)
	end,

	OnTeleporterReleaseUnit = function(self,unitBeingTeleported)
	end,

	OnAnimCollision = function(self, bone, x, y, z)
	end,

    OnMotionTurnEventChange = function(self, newEvent, oldEvent)
    end,

    OnMotionHorzEventChange = function( self, new, old )
    end,

    OnMotionVertEventChange = function( self, new, old )
    end,

    OnStartTransportBeamUp = function(self, transport, bone)
    end,

    OnStopTransportBeamUp = function(self)
    end,

    OnStartRefueling = function(self)
    end,

    OnRunOutOfFuel = function(self)
    end,

    OnGotFuel = function(self)
    end,

	OnRemoveUnitUpgrade = function( self, upgradeUnit )
	end,
	
	-- Unit lua method to trigger special case functionality when a unit is stunned.
    OnStunned = function(self,stunned)
    end,	
]]--
}