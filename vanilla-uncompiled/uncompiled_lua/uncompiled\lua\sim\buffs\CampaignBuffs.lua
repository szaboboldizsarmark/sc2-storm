--****************************************************************************
--**
--**  File     :  /lua/sim/buffs/campaignbuffs.lua
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

------------------------------------------------------------------
-- CAMPAIGN BUFFS - USED FOR DIFFICULTY/ GLOBAL TUNING
------------------------------------------------------------------

BuffBlueprint {
    Name = 'CAMPAIGN_ResearchMod',
    DisplayName = 'CAMPAIGN_ResearchMod',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	ResearchProduction = { Mult = -0.2, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff01',
    DisplayName = 'CAMPAIGN_buff01',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.1, },
        HealthMax = { Mult = 0.1, },
        HealthRegen = { Mult = 0.25, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff02',
    DisplayName = 'CAMPAIGN_buff02',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.2, },
        HealthMax = { Mult = 0.2, },
        HealthRegen = { Mult = 0.5, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff03',
    DisplayName = 'CAMPAIGN_buff03',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.3, },
        HealthMax = { Mult = 0.3, },
        HealthRegen = { Mult = 0.75, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff04',
    DisplayName = 'CAMPAIGN_buff04',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.4, },
        HealthMax = { Mult = 0.4, },
        HealthRegen = { Mult = 1, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff05',
    DisplayName = 'CAMPAIGN_buff05',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.5, },
        HealthMax = { Mult = 0.5, },
        HealthRegen = { Mult = 1.25, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff06',
    DisplayName = 'CAMPAIGN_buff06',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.6, },
        HealthMax = { Mult = 0.6, },
        HealthRegen = { Mult = 1.5, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff07',
    DisplayName = 'CAMPAIGN_buff07',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.7, },
        HealthMax = { Mult = 0.7, },
        HealthRegen = { Mult = 1.75, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff08',
    DisplayName = 'CAMPAIGN_buff08',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.8, },
        HealthMax = { Mult = 0.8, },
        HealthRegen = { Mult = 2.0, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff09',
    DisplayName = 'CAMPAIGN_buff09',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 0.9, },
        HealthMax = { Mult = 0.9, },
        HealthRegen = { Mult = 2.25, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_buff10',
    DisplayName = 'CAMPAIGN_buff10',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = 1.0, },
        HealthMax = { Mult = 1.0, },
        HealthRegen = { Mult = 2.5, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff01',
    DisplayName = 'CAMPAIGN_debuff01',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.1, },
        HealthMax = { Mult = -0.1, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff02',
    DisplayName = 'CAMPAIGN_debuff02',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.2, },
        HealthMax = { Mult = -0.2, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff03',
    DisplayName = 'CAMPAIGN_debuff03',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.3, },
        HealthMax = { Mult = -0.3, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff04',
    DisplayName = 'CAMPAIGN_debuff04',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.4, },
        HealthMax = { Mult = -0.4, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff05',
    DisplayName = 'CAMPAIGN_debuff05',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.5, },
        HealthMax = { Mult = -0.5, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff06',
    DisplayName = 'CAMPAIGN_debuff06',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.6, },
        HealthMax = { Mult = -0.6, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff07',
    DisplayName = 'CAMPAIGN_debuff07',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.7, },
        HealthMax = { Mult = -0.7, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff08',
    DisplayName = 'CAMPAIGN_debuff08',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.8, },
        HealthMax = { Mult = -0.8, },
    },
}

BuffBlueprint {
    Name = 'CAMPAIGN_debuff09',
    DisplayName = 'CAMPAIGN_debuff09',
    BuffType = 'CAMPAIGN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	Damage = { Mult = -0.9, },
        HealthMax = { Mult = -0.9, },
    },
}
__moduleinfo.auto_reload = true