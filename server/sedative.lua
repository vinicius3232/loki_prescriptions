--[[
    ============================================================================
    Módulo de Sedação Clínica & Anestesia Hospitalar (Server)
    Validação de autoridade, consumo do item e aplicação no alvo
    ============================================================================
]]

local function isAuthorized(src)
    local job = Bridge.Framework.getPlayerJob(src)
    if not job then return false end
    if job.name == 'police' then return true end
    if Config.PrescriptionJobs then
        for _, j in ipairs(Config.PrescriptionJobs) do
            if j == job.name then return true end
        end
    end
    return job.name == 'ambulance'
end

RegisterServerEvent('loki_prescriptions:server:sedatePlayer', function(targetServerId)
    local src = source
    if not isAuthorized(src) then return end

    local target = tonumber(targetServerId)
    if not target or target <= 0 or target == src then return end

    local docPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    if not DoesEntityExist(docPed) or not DoesEntityExist(targetPed) then return end

    if #(GetEntityCoords(docPed) - GetEntityCoords(targetPed)) > 4.5 then
        Bridge.Notify.showNotify(src, 'Paciente muito distante.', 'error')
        return
    end

    local removed = Bridge.Inventory.removeItem(src, 'sedative', 1)
    if removed then
        TriggerClientEvent('loki_prescriptions:client:receiveSedative', target)
        if VpNeedsBridge then
            VpNeedsBridge.ApplySedation(target)
        end
        Bridge.Notify.showNotify(src, 'Sedativo administrado com sucesso no paciente.', 'success')
    else
        Bridge.Notify.showNotify(src, 'Você não possui sedativo no inventário.', 'error')
    end
end)

-- Registro do item utilizável
CreateThread(function()
    Wait(1500)
    Bridge.Framework.registerItem('sedative', function(source)
        TriggerClientEvent('loki_prescriptions:client:useSedative', source)
    end)
end)
