local QBCore = exports['qb-core']:GetCoreObject()
local playerEnhancements = {}

local function AddEnhancement(playerIdentifier, enhancementName, time)
    if not playerEnhancements[playerIdentifier] or not playerEnhancements[playerIdentifier][enhancementName] then
        if not time then
            time = Config.Enhancements[enhancementName].times
        end
        playerEnhancements[playerIdentifier][enhancementName] = time
    else
        local currTime = playerEnhancements[playerIdentifier][enhancementName]
        playerEnhancements[playerIdentifier][enhancementName] = currTime + time
    end
    return true
end
exports('AddEnhancement', AddEnhancement)

local function RemoveEnhancement(playerIdentifier, enhancementName)
    playerEnhancements[playerIdentifier][enhancementName] = nil
    return true
end
exports('RemoveEnhancement', RemoveEnhancement)

local function HasEnhancement(playerIdentifier, enhancementName)
    return playerEnhancements[playerIdentifier][enhancementName] ~= nil
end
exports('HasEnhancement', HasEnhancement)

QBCore.Functions.CreateCallback('enhancements:server:fetchEnhancements', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    local playerIdentifier = player.PlayerData.citizenid
    cb(playerEnhancements[playerIdentifier])
    return true
end)

Citizen.CreateThread(function()
    local function DecrementEnhancement(playerIdentifier, enhancementName)
        if playerEnhancements[playerIdentifier][enhancementName] - 1 < 0 then
            playerEnhancements[playerIdentifier][enhancementName] = nil
        else
            local currTime = playerEnhancements[playerIdentifier][enhancementName]
            playerEnhancements[playerIdentifier][enhancementName] = currTime - 1
        end
    end

    -- Not proud but need to loop through all timers but decrement it
    while true do
        for _, player in pairs(playerEnhancements) do
            for _, enhancement in pairs(player) do
                if enhancement ~= nil then
                    DecrementEnhancement(player, enhancement)
                end
            end
        end

        Wait(Config.TickTime)
    end
end)