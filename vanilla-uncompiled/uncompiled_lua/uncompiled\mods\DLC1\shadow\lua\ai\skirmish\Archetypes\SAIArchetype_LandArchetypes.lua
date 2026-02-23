function Evaluate(AIInfo)
    returnScore = 0
    
	if string.find(AIInfo.PreferredAI, 'Land') then
        returnScore = 100
	elseif string.find(AIInfo.PreferredAI, 'Naval') and AIInfo.Faction == 3 then
        returnScore = 100
	-- Do not use on maps that don't support land; unless potentially Illumiate due to their
    -- high number of hover units
    elseif (not AIInfo.LandMap and AIInfo.Faction != 3) or AIInfo.NoLand then
        returnScore = -1
	else
		if not AIInfo.LandMap and AIInfo.Faction == 3 then
			if not AIInfo.AmphibiousMap or not AIInfo.HasNavalNearby or AIInfo.NoNaval then
				returnScore = -1
			elseif AIInfo.EnemyRange <= 300 then
				returnScore = 15
			elseif AIInfo.EnemyRange <= 350 then
				returnScore = 20
			elseif AIInfo.EnemyRange <= 400 then
				returnScore = 30
			elseif AIInfo.EnemyRange <= 450 then
				returnScore = 40
			elseif AIInfo.EnemyRange > 450 then
				returnScore = 50
			end
		else
			if AIInfo.EnemyRange <= 250 then
				returnScore = 10
			elseif AIInfo.EnemyRange <= 300 then
				returnScore = 20
			elseif AIInfo.EnemyRange <= 350 then
				returnScore = 30
			elseif AIInfo.EnemyRange <= 400 then
				returnScore = 35
			elseif AIInfo.EnemyRange <= 450 then
				returnScore = 50
			elseif AIInfo.EnemyRange <= 500 then
				returnScore = 40
			elseif AIInfo.EnemyRange <= 550 then
				returnScore = 25
			elseif AIInfo.EnemyRange > 550 then
				returnScore = 10
			end
		end
	end
    
    return returnScore, 'DefaultLandArchetype'
end