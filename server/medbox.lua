--[[
    ============================================================================
    LOKI PRESCRIPTIONS - PORTABLE MEDICAL FIELD BOX / STASH (SERVER)
    Absorbed from ak47_qb_ambulancejob and upgraded for QBox & ox_inventory
    ============================================================================
]]

local activeMedBoxes = {}

RegisterNetEvent('loki_prescriptions:server:deployMedBox', function(coords, heading)
    local src = source
    if not src or src <= 0 then return end

    local job = Bridge.Framework.fetchPlayerJob(src)
    if not job or (job.name ~= 'ambulance' and job.name ~= 'doctor') then
        Bridge.Notify.showNotify(src, 'Apenas membros do corpo médico podem posicionar a caixa de campo.', 'error')
        return
    end

    local boxId = string.format('medbox_%d_%d', src, os.time())
    activeMedBoxes[boxId] = {
        owner = src,
        coords = coords,
        heading = heading
    }

    -- Registra o stash no ox_inventory
    pcall(function()
        if exports.ox_inventory and exports.ox_inventory.RegisterStash then
            exports.ox_inventory:RegisterStash(boxId, 'Caixa de Suprimentos de Campo', 25, 60000)
        end
    end)

    TriggerClientEvent('loki_prescriptions:client:syncSpawnMedBox', -1, boxId, coords, heading)
    Bridge.Notify.showNotify(src, 'Caixa de suprimentos de campo posicionada.', 'success')
end)

RegisterNetEvent('loki_prescriptions:server:removeMedBox', function(boxId)
    local src = source
    if not src or src <= 0 or not boxId then return end

    if activeMedBoxes[boxId] then
        activeMedBoxes[boxId] = nil
        TriggerClientEvent('loki_prescriptions:client:syncRemoveMedBox', -1, boxId)
        Bridge.Notify.showNotify(src, 'Caixa de suprimentos recolhida e guardada.', 'inform')
    end
end)

AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    activeMedBoxes = {}
end)
