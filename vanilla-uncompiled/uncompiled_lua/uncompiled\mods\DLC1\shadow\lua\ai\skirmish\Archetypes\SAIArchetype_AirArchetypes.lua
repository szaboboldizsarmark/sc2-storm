function Evaluate(AIInfo)
    returnScore = 0
    
    if string.find(AIInfo.PreferredAI, 'Air') then
        returnScore = 100
	elseif AIInfo.NoAir then
		returnScore = -1
    elseif AIInfo.EnemyRange <= 350 then
        returnScore = 10
    elseif AIInfo.EnemyRange <= 400 then
        returnScore = 20
    elseif AIInfo.EnemyRange <= 450 then
        returnScore = 35
    elseif AIInfo.EnemyRange <= 500 then
        returnScore = 40
    elseif AIInfo.EnemyRange <= 550 then
        returnScore = 50
    elseif AIInfo.EnemyRange <= 600 then
        returnScore = 40
    elseif AIInfo.EnemyRange <= 650 then
        returnScore = 30
    elseif AIInfo.EnemyRange <= 700 then
        returnScore = 20
    elseif AIInfo.EnemyRange > 700 then
        returnScore = 10
    end
    
    return returnScore, 'DefaultAirArchetype'
end