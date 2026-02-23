--***************************************************************************
--*
--**  File     :  /lua/ai/campaign/system/FactoryBuilderManager.lua
--**
--**  Summary  : Manage factory builders and factories
--**
--**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

local BuilderManager = import('/lua/ai/BuilderManager.lua').BuilderManager
local AIUtils = import('/lua/ai/aiutilities.lua')
local Builder = import('/lua/ai/campaign/system/Builder.lua')
local AIBuildUnits = import('/lua/ai/aibuildunits.lua')

local FactoryBuilder = import('/lua/ai/campaign/system/Builder.lua').FactoryBuilder

AIFactoryManager = Class(BuilderManager) {
    FactoryCategory = categories.uub0001 + categories.uub0002 + categories.uub0003 + categories.uub0801 + categories.uub0011 + categories.uub0012
        + categories.ucb0001 + categories.ucb0002 + categories.ucb0003 + categories.ucb0801 + categories.ucb0011 + categories.ucb0012
        + categories.uib0001 + categories.uib0002 + categories.uib0801 + categories.uib0011 + categories.scb1402,

    __init = function(self, brain, locationName, position, radius, useCenterPoint, vetLevel)
        BuilderManager.__init(self,brain)

        if not locationName or not position or not radius then
            error('*FACTORY BUILDER MANAGER ERROR: Invalid parameters; requires locationName, position, and radius')
            return false
        end

        local builderTypes = { 'Air', 'Land', 'Sea', 'Gantry', }
        for k,v in builderTypes do
            self:AddBuilderType(v)
        end

        self.Position = position
        self.Radius = radius
        self.LocationName = locationName
        self.DefaultVetLevel = vetLevel or 0

        self.PrimaryFactories = {
            Air = false,
            Land = false,
            Sea = false,
        }

        self.FactoryList = {}

        self.LocationActive = false

        self.RandomSamePriority = true
        self.PlatoonListEmpty = true

        self.UseCenterPoint = useCenterPoint or false
    end,

    AddBuilder = function(self, builderName, opAI)
        local newBuilder = FactoryBuilder(self.Brain, builderName, self.LocationName, opAI)
        if newBuilder:GetBuilderType() == 'All' then
            for k,v in self.BuilderData do
                self:AddInstancedBuilder(newBuilder, k)
            end
        else
            self:AddInstancedBuilder(newBuilder)
        end
        return newBuilder
    end,

    SetDefaultVeterancy = function(self, vetLevel)
        if vetLevel then
            self.DefaultVetLevel = vetLevel
        end
    end,

    HasPlatoonList = function(self)
        return self.PlatoonListEmpty
    end,

    GetNumFactories = function(self)
        if self.FactoryList then
            return table.getn(self.FactoryList)
        end
        return 0
    end,

    GetNumCategoryFactories = function(self, category)
        if self.FactoryList then
            return EntityCategoryCount( category, self.FactoryList )
        end
        return 0
    end,

    GetNumCategoryBeingBuilt = function(self, category, facCategory )
        return table.getn(self:GetFactoriesBuildingCategory(category, facCategory ))
    end,

    GetFactoriesBuildingCategory = function(self, category, facCategory )
        local units = {}
        for k,v in EntityCategoryFilterDown( facCategory, self.FactoryList ) do
            if v:IsDead() then
                continue
            end

            if not v:IsUnitState('Upgrading') and not v:IsUnitState('Building') then
                continue
            end

            local beingBuiltUnit = v:GetUnitBeingBuilt()
            if not beingBuiltUnit or beingBuiltUnit:IsDead() then
                continue
            end

            if not EntityCategoryContains( category, beingBuiltUnit ) then
                continue
            end

            table.insert( units, v )
        end
        return units
    end,

    GetFactories = function(self, category)
        local retUnits = EntityCategoryFilterDown( category, self.FactoryList )
        return retUnits
    end,

    AddFactory = function(self,unit)

        if not EntityCategoryContains( self.FactoryCategory, unit ) then
            return
        end

        table.insert(self.FactoryList, unit)
        if EntityCategoryContains( categories.uub0011 + categories.uub0012 + categories.ucb0011 + categories.ucb0012 + categories.uib0011 + categories.scb1402, unit ) then
            self:SetupNewFactory(unit, 'Gantry')
        elseif EntityCategoryContains( categories.LAND, unit ) then
            self:SetupNewFactory(unit, 'Land')
        elseif EntityCategoryContains( categories.AIR, unit ) then
            self:SetupNewFactory(unit, 'Air')
        elseif EntityCategoryContains( categories.NAVAL, unit ) then
            self:SetupNewFactory(unit, 'Sea')
        else
            WARN('*AI ERROR: Could not add unit to FactoryManager - ' .. unit:GetUnitId())
            return false
        end
        self.LocationActive = true
    end,

    SetupNewFactory = function(self,unit,bType)
        if not unit.BuilderManagerData then
            local unitDestroyed = function(unit)
                        -- Call function on builder manager; let it handle death of unit
                        self:FactoryDestroyed(unit)
                    end
            import('/lua/sim/ScenarioTriggers.lua').CreateUnitDestroyedTrigger(unitDestroyed, unit )

            local startBuild = function(unit, unitBeingBuilt)
                        unit.BuilderManagerData.FinishedUnitAdded = false
                    end
            unit.Callbacks.OnStartBuild:Add(startBuild)
        end

        -- we set finished unit added to true because only factories that start building set it to false
        -- that way if any factories do not build, we aren't blocking the builder with a factory that did nothing
        unit.BuilderManagerData = { FactoryManager = self, BuilderType = bType, FinishedUnitAdded = true, }
        
        -- BUG 4984, Add Guard command cap to all factories, so OpAi can assist build, currently disabled
        -- for factories, till we fix factory assist build
        unit:AddCommandCap('RULEUCC_Guard')

        -- no primary factory; setup this factory as the primary factory
        if not self.PrimaryFactories[bType] or bType == 'Gantry' then
            self.PrimaryFactories[bType] = unit
            self:ForkThread(self.DelayBuildOrder, unit, bType, 1)
            unit.BuilderManagerData.PrimaryFactory = unit
        elseif self.PrimaryFactories[bType]:IsDead() then
            self:FactoryDestroyed(self.PrimaryFactories[bType])
        else
            -- setup unit to assist primary factory
            unit.BuilderManagerData.PrimaryFactory = self.PrimaryFactories[bType]
            IssueFactoryAssist( {unit}, self.PrimaryFactories[bType] )
        end

        self:ForkThread( self.DelayRallyPoint, unit)
    end,

    FactoryDestroyed = function(self, factory)
        for k,v in self.FactoryList do
            if v == factory then
                self.FactoryList[k] = nil
            end
        end

        local bType = factory.BuilderManagerData.BuilderType

        -- this is the primary factory; we need to find a new primary factory if we can
        -- LOG('*AI DEBUG: Checking primary factory')
        if factory.BuilderManagerData.PrimaryFactory == factory then
            -- LOG('*AI DEBUG: Reassigning primary factory')
            self.PrimaryFactories[bType] = false
            local guards = factory:GetGuards()

            local primarySet = false
            local currentBuilder = factory.CurrentBuilder

            for k,v in guards do
                if not v:IsDead() and not primarySet then
                    self.PrimaryFactories[bType] = v
                    primarySet = v
                    v.CurrentBuilder = currentBuilder
                elseif not v:IsDead() then
                    IssueFactoryAssist( {v}, primarySet )
                end
                if v.BuilderManagerData then
                    v.BuilderManagerData.PrimaryFactory = primarySet
                end
            end


            if primarySet and not self.PrimaryFactories[bType]:IsUnitState('Building') then
                -- now check to see if all jobs are completed due to death of the primary factory
                self:ForkThread( function()
                        WaitTicks(1)
                        self:FactoryFinishBuilding( self.PrimaryFactories[bType], nil )
                    end
                )
			elseif not primarySet then
				self.PrimaryFactories[bType] = nil
            end
        end

        -- check if we still have active factories in this location
        for k,v in self.FactoryList do
            if not v:IsDead() then
                return
            end
        end
        self.LocationActive = false
    end,

    DelayBuildOrder = function(self,factory,bType,time)
        if factory.DelayThread then
            return
        end
        factory.DelayThread = true
        WaitSeconds(time)
        factory.DelayThread = false
        self:AssignBuildOrder(factory,bType)
    end,

    GetFactoryFaction = function(self, factory)
        if EntityCategoryContains( categories.UEF, factory ) then
            return 'UEF'
        elseif EntityCategoryContains( categories.CYBRAN, factory ) then
            return 'Cybran'
        elseif EntityCategoryContains( categories.ILLUMINATE, factory ) then
            return 'Illuminate'
        end
        return false
    end,

    --Adjusts a build template to support -1 platoons
    AdjustTemplate = function(self, bType, template)
        local category = ParseEntityCategory(string.upper(bType))
        local factoriesLeft = self:GetNumCategoryFactories(category - categories.EXPERIMENTALFACTORY)
        -- Get the positive build orders first
        for _,unitTable in template do
            if unitTable[2] > 0 then
                factoriesLeft = factoriesLeft - unitTable[2]
            end
        end
        -- Get the negative build orders
        -- A calculation to support multiple -1 build orders can be added here if needed
        if factoriesLeft > 0 then
            for _,unitTable in template do
                if unitTable[2] < 0 then
                    unitTable[2] = factoriesLeft
                    break
                end
            end
        end
        -- return the altered template
        return template
    end,

    AssignBuildOrder = function(self,factory,bType)
        -- Find a builder the factory can build
        if factory:IsDead() then
            return
        end

        if not factory:IsIdleState() then
            self:ForkThread(self.DelayBuildOrder, factory, bType, 2)
            return
        end

        local builder = self:GetHighestBuilder(bType,{factory})
        if builder then
            local template = builder:GetBuildTemplate({factory})
            -- LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Factory Builder Manager Building - ',repr(builder.BuilderName)
            --         .. ' - BuilderTemplate = ' .. repr(template))
            -- {
            --   { 'uul0101', 1 },
            --   { 'uul0101', 2 },
            -- }
            for _,unitTable in template do
                if unitTable[2] < 0 then
                    template = self:AdjustTemplate(bType, template)
                    break
                end
            end

            for _,unitTable in template do
                IssueBuildFactory( {factory}, unitTable[1], unitTable[2] )
            end

            -- Tell the builder we are building it
            builder:BuilderConstructionStarted(factory, template)
            factory.CurrentBuilder = builder
        else
            -- No builder found setup way to check again
            self:ForkThread(self.DelayBuildOrder, factory, bType, 2)
        end
    end,

    -- checks to see if a primary factories and its guards are finished building
    CheckFactoriesFinished = function(self, factory)
        local primaryFactory = factory.BuilderManagerData.PrimaryFactory

        if not primaryFactory or primaryFactory:IsDead() then
            return false
        end

        local primaryFactoryQueueSize = primaryFactory:GetNumBuildOrders( categories.ALLUNITS )
        -- the queue on the primary factory is never 0; the queue is updated after this call.
        -- the queue on the primary factory is reduced down to 1 by the assisters. so all
        -- we care about is making sure its 1 or less
        if primaryFactoryQueueSize > 1 or primaryFactory:IsUnitState('Building') then
            return false
        end

        for k,v in primaryFactory:GetGuards() do
            if v:IsDead() or not v.BuilderManagerData then
                continue
            end
            
            if not v.BuilderManagerData.FactoryManager or not v.BuilderManagerData.FactoryManager == self then
                continue
            end

            local isBuilding = v:IsUnitState('Building')
            if isBuilding then
                return false
            end

            if not v.BuilderManagerData.FinishedUnitAdded then
                return false
            end
        end

        return true
    end,

    FactoryFinishBuilding = function(self,factory,finishedUnit)
        while finishedUnit and not finishedUnit:IsDead() and finishedUnit:IsUnitState('Attached') do
            WaitTicks(1)
        end

        -- factory is dead; return out
        if not factory or factory:IsDead() then
            return
        end

		if finishedUnit and not finishedUnit:IsDead() then
            if factory.CurrentBuilder then
                -- LOG('*AI DEBUG: Finished unit - primary factory builder')
			    factory.CurrentBuilder:UnitConstructionFinished(finishedUnit)
            elseif factory.BuilderManagerData.PrimaryFactory.CurrentBuilder then
                -- LOG('*AI DEBUG: Finished unit - sending to primary factory builder')
                factory.BuilderManagerData.PrimaryFactory.CurrentBuilder:UnitConstructionFinished(finishedUnit)
            end
            factory.BuilderManagerData.FinishedUnitAdded = true
            if self.DefaultVetLevel > 0 and finishedUnit:GetBlueprint().General.ExperienceTable != "" then
                finishedUnit:SetVeterancy(self.DefaultVetLevel)
            end
		end

        -- check if the currentbuilder is finished based on the primary and all assisters
        if self:CheckFactoriesFinished(factory) then
            -- LOG('*AI DEBUG: FACTORIES FINISHED')

            -- tell the current builder that a unit is finished
            if factory.BuilderManagerData.PrimaryFactory.CurrentBuilder then
                -- LOG('*AI DEBUG: Informing builder of completion')
                factory.BuilderManagerData.PrimaryFactory.CurrentBuilder:BuilderConstructionFinished()
                factory.BuilderManagerData.PrimaryFactory.CurrentBuilder = false
            end

            -- tell the primary factory it's time to start working again
            self:AssignBuildOrder(factory.BuilderManagerData.PrimaryFactory, factory.BuilderManagerData.BuilderType)
        end
    end,

    -- Check if given factory can build the builder
    BuilderParamCheck = function(self,builder,params)
        -- params[1] is factory, no other params

        -- Make sure we have the resources to start construction
        -- FactoryBuilder:GetBuildTemplate() verifies that there is enough in the coffers to build
        -- a platoon; it returns false if it CANNOT and returns a valid platoons if it can
        local template = builder:GetBuildTemplate(params)
        if not template then
            -- WARN('*Factory Builder Error: Could not get a build template for builder named: ' .. builder.BuilderName )
            return false
        end

        -- This faction doesn't have unit of this type
        --if table.getn(template) == 2 then
        --    return false
        --end

        -- This function takes a table of factories to determine if it can build
        return true
    end,

    DelayRallyPoint = function(self, factory)
        WaitTicks(1)
        if not factory:IsDead() then
            self:SetRallyPoint(factory)
        end
    end,

    SetRallyPoint = function(self, factory)
        local position = factory:GetPosition()
        local rally = false

        local rallyType = 'Rally Point'
        if EntityCategoryContains( categories.NAVAL, factory ) then
            rallyType = 'Naval Rally Point'
        end

        if not self.UseCenterPoint then
            -- Find closest marker to averaged location
            rally = AIUtils.AIGetClosestMarkerLocation( self, rallyType, position[1], position[3] )
        elseif self.UseCenterPoint then
            -- use BuilderManager location
            rally = AIUtils.AIGetClosestMarkerLocation( self, rallyType, position[1], position[3] )
            local expPoint = AIUtils.AIGetClosestMarkerLocation( self, 'Expansion Area', position[1], position[3] )

            if expPoint and rally then
                local rallyPointDistance = VDist2(position[1], position[3], rally[1], rally[3])
                local expansionDistance = VDist2(position[1], position[3], expPoint[1], expPoint[3])

                if expansionDistance < rallyPointDistance then
                    rally = expPoint
                end
            end
        end

        if not rally or VDist2( rally[1], rally[3], position[1], position[3] ) > self.Radius then
            return true
        end

        IssueClearFactoryCommands( {factory} )
        LOG('*AI DEBUG: Setting factory rally point')
        IssueFactoryRallyPoint({factory}, rally)
        return true
    end,
}