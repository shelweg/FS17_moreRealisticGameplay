
--**************************************************************************************
-- make use of the gameplay dirt multiplier setting
Washable.mrGetIntervalMultiplier = function(superFunc)
    if g_currentMission.missionInfo.dirtInterval == 1 then
        return 0
    elseif g_currentMission.missionInfo.dirtInterval == 2 then
        return 0.25 * g_currentMission.mrGameplayDirtSpeedMultiplier
    elseif g_currentMission.missionInfo.dirtInterval == 3 then
        return 0.5 * g_currentMission.mrGameplayDirtSpeedMultiplier
    elseif g_currentMission.missionInfo.dirtInterval == 4 then
        return 1 * g_currentMission.mrGameplayDirtSpeedMultiplier
    end
end
Washable.getIntervalMultiplier = Utils.overwrittenFunction(Washable.getIntervalMultiplier, Washable.mrGetIntervalMultiplier)