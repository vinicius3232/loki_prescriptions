--[[
    ============================================================================
    Coma Sensorial - Servidor (Sensory Coma Sync & Security)
    Rate limit, autoridade de coordenadas e broadcast para jogadores próximos
    ============================================================================
]]

local lastPlayerMoans = {}

RegisterNetEvent('loki_prescriptions:server:playerMoan', function()
    local src = source
    local now = os.time()

    -- Proteção contra spam de rede
    if lastPlayerMoans[src] and (now - lastPlayerMoans[src]) < 3 then
        return
    end
    lastPlayerMoans[src] = now

    local ped = GetPlayerPed(src)
    if not DoesEntityExist(ped) then return end

    local coords = GetEntityCoords(ped)

    -- Broadcast apenas para clientes dentro do raio de audição (15 metros)
    local players = GetPlayers()
    for _, targetId in ipairs(players) do
        local targetPed = GetPlayerPed(targetId)
        if DoesEntityExist(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            if #(coords - targetCoords) <= 15.0 then
                TriggerClientEvent('loki_prescriptions:client:hearMoan', targetId, coords)
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    lastPlayerMoans[source] = nil
end)
