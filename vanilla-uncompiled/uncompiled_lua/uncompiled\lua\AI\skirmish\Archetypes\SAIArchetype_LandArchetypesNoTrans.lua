function Evaluate(AIInfo)
    returnScore = 0
    
    -- do not use if it's island maps; no transports in this build
    if (not AIInfo.LandMap and not AIInfo.AmphibiousMap) or AIInfo.NoLand then
        returnScore = -1
    elseif AIInfo.EnemyRange <= 250 then
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
    
    return returnScore, 'DefaultLandArchetypeNoTrans'
end