function BuffBlueprint(...)	     
	if not arg[1].Name then
        LOG('Missing name for buff definition: ',repr(arg))
        return
    end
    
    UIRegisterResearchBuff( arg[1].Name, arg[1].Affects )
end

doscript '/lua/sim/Buffs/ResearchBuffDefinitions.lua'
