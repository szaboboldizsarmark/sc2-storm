--------------------------------------------------------------------------------------------------------------------------------
--
--    
--
--------------------------------------------------------------------------------------------------------------------------------

CommandTargetMap = {
    -- Common rules		
    -- Selected Unit Commands			Target Ground		  |	Target Area			|	Target Friendly		|	Target Enemy			|	Target Neutral			|	Target Prop			|	Non-Targeted
    RULEUCC_Move					= {	TType_GROUND = true,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Attack					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = true,			TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Patrol					= {	TType_GROUND = true,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Stop					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    RULEUCC_Guard					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = true,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_RetaliateToggle			= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = true,			TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    RULEUCC_Pause					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    Builder							= {	TType_GROUND = true,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
																																																					 
	-- Unit specific rules       	   																																												 
    RULEUCC_Reclaim 				= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = true,			TType_NEUTRAL = true,  		TType_PROP = true,		TType_NONE = false,	},
    RULEUCC_Capture 				= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = true,			TType_NEUTRAL = true,  		TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Repair					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = true,	TType_ENEMY = false,		TType_NEUTRAL = true,  		TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Dive					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    RULEUCC_Ferry					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = true,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Transport				= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = true,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
	RULEUCC_SiloBuildAntiNuke		= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
	RULEUCC_SiloBuildRedirectNuke	= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
	RULEUCC_SiloBuildNuke			= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
	RULEUCC_SiloBuildEMP			= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    RULEUCC_Nuke					= {	TType_GROUND = false,	TType_AREA = true,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_EMP						= {	TType_GROUND = false,	TType_AREA = true,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    Anti_Nuke						= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    Escape_Pod						= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    Harden_Artillery				= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    Hunker							= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
	RULEUCC_Jump					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    Mass_conversion					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    Power_Detonate					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    Radar_overdrive					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = true,	},
    RULEUCC_Teleport				= {	TType_GROUND = true,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Script					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Sacrifice				= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = true,			TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
    RULEUCC_Dock					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
																																																		 
	RULEUCC_Ability					= {	TType_GROUND = false,	TType_AREA = false,		TType_FRIEND = false,	TType_ENEMY = false,		TType_NEUTRAL = false,  	TType_PROP = false,		TType_NONE = false,	},
}