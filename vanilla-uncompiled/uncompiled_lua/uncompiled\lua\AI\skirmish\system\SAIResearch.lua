
SAIResearchBody = {
    Create = function(self, brain)
        self.Brain = brain

        self.ResearchItem = false
        self.ResearchLevel = false

        --LOG('*AI DEBUG: ARMY ' .. self.Brain:GetArmyIndex() .. ': Starting Research')

        self.Brain.Callbacks.OnResearchTechnology:Add( self.ResearchFinished, self )

        ForkThread(self.StartResearch, self)
        
        return true
    end,

    StartResearch = function(self)
        while true do
            if not self.ResearchLocked then
                if not self.ResearchItem then
                    local researchItem, researchLevel = self.Brain.SkirmishAISystem:GetResearchItem()
                    self.ResearchItem = researchItem
                    self.ResearchLevel = researchLevel
                    if not researchItem then
                        return
                    end
                end

                local researchBp = ResearchDefinitions[self.ResearchItem]

                if self.ResearchItem and self.Brain:GetEconomyStored('RESEARCH') > researchBp.COST then
                    --LOG('*AI DEBUG: ARMY ' .. self.Brain:GetArmyIndex() .. ': Beginning Research - ' .. self.ResearchItem)
                    self.Brain:StartResearch(self.ResearchItem, self.ResearchLevel)
                    self.ResearchItem = false
                    self.ResearchLevel = false
                    self.ResearchLocked = true
                end
            end
            WaitSeconds(1)
        end
    end,

    ResearchFinished = function(self, name, event)
        self.ResearchLocked = false

        if event == 'complete' then
            self.Brain.SkirmishAISystem:ResearchCompleted(name)
        end
    end,
}

SAIResearch = function(brain, unit)
    local research = table.copy( SAIResearchBody )
    if research:Create(brain) then
        return research
    end
    return false
end
