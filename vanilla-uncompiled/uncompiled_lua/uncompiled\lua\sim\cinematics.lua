---------------------------------------------------------------------
---NOTE: OBSOLETE - MARKED FOR DEPRICATION - bfricks 10/31/09
---NOTE: the contents of this file have either been depricated or migrated to the new ScenarioFramework files:
---					/data/lua/sim/ScenarioFramework/
---			the obvious exception being this singular function - which is used in SimMan.cpp as the primary query to test if the game
---			is in NIS mode or not. Ideally, this will be deleted and that check done in a more meaningful manner. - bfricks 7/12/09
function IsOpEnded()
	---NOTE: this was changed as part of a full game review of ScenarioInfo global usage cases - it now exclusively means we are in an NIS - bfricks 10/31/09
	return ScenarioInfo.OpNISActive
end