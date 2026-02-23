function Evaluate(AIInfo)
    returnScore = 0
    
	if string.find(AIInfo.PreferredAI, 'Rush') then
        returnScore = 100
    elseif not AIInfo.LandMap or AIInfo.NoLand then
        returnScore = -1
    elseif AIInfo.EnemyRange <= 300 then
        returnScore = 50
    elseif AIInfo.EnemyRange <= 350 then
        returnScore = 45
    elseif AIInfo.EnemyRange <= 400 then
        returnScore = 40
    elseif AIInfo.EnemyRange <= 450 then
		returnScore = 40
    elseif AIInfo.EnemyRange <= 500 then
		returnScore = 20
    elseif AIInfo.EnemyRange > 500 then
		returnScore = 10
    end
    
    return returnScore, 'DefaultRushArchetype'
end