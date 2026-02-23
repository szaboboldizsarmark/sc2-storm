--****************************************************************************
--**
--**  File     :  /lua/sim/CheatBuffs.lua
--**
--**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************

BuffBlueprint {
    Name = 'CheatBuffSet',
    DisplayName = 'CheatBuffSet',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 0.0,
        },
        ExperienceGain = {
            Mult = 0.0,
        },
    },
}

-- Easy
BuffBlueprint {
    Name = 'CheatBuffSet01',
    DisplayName = 'CheatBuffSet01',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = -0.25,
        },
        --RadarRadius = {
        --    Mult = 0,
        --},
    },
}

-- Medium
BuffBlueprint {
    Name = 'CheatBuffSet02',
    DisplayName = 'CheatBuffSet02',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 0,
        },
        --RadarRadius = {
        --    Mult = 0.75,
        --},
    },
}

-- Hard
BuffBlueprint {
    Name = 'CheatBuffSet03',
    DisplayName = 'CheatBuffSet02',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 0.5,
        },
        --RadarRadius = {
        --    Mult = 1.5,
        --},
        --VisionRadius = {
        --    Mult = 1.0,
        --},
        VeterancyLevel = {
            Add = 0.25,
        },
    },
}

-- Cheat
BuffBlueprint {
    Name = 'CheatBuffSet04',
    DisplayName = 'CheatBuffSet04',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 0.9,
        },
        VeterancyLevel = {
            Add = 1.0,
        },
        --RadarRadius = {
        --    Mult = 3.0,
        --},
        --VisionRadius = {
        --    Mult = 2.0,
        --},
    },
}

--************
--*   XBox
--************
-- Easy
BuffBlueprint {
    Name = '360CheatBuffSet01',
    DisplayName = 'CheatBuffSet01',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = -0.25,
        },
    },
}

-- Medium
BuffBlueprint {
    Name = '360CheatBuffSet02',
    DisplayName = 'CheatBuffSet02',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 0,
        },
        RadarRadius = {
            Mult = 0.5,
        },
    },
}

-- Normal
BuffBlueprint {
    Name = '360CheatBuffSet03',
    DisplayName = 'CheatBuffSet03',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 0.25,
        },
        RadarRadius = {
            Mult = 1.0,
        },
        VisionRadius = {
            Mult = 1.0,
        },
        VeterancyLevel = {
            Add = 0.25,
        },
    },
}

-- Cheat
BuffBlueprint {
    Name = '360CheatBuffSet04',
    DisplayName = 'CheatBuffSet04',
    BuffType = 'CHEATBUFFSET',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Mult = 1.0,
        },
        VeterancyLevel = {
            Add = 1.0,
        },
        RadarRadius = {
            Mult = 2.0,
        },
        VisionRadius = {
            Mult = 2.0,
        },
    },
}