--[[
    LOKI MEDICAL SUITE - VP_NEEDS INTEGRATION (CLIENT)
    Comandos clínicos de toxicologia e alertas de overdose para socorristas.
]]

RegisterNetEvent('loki_prescriptions:client:showToxicologyAlert', function(data)
    if not data or not data.available then return end

    local alertType = data.isOverdosing and 'error' or 'inform'
    local statusTitle = data.isOverdosing and '🚨 ALERTA CRÍTICO: OVERDOSE' or '🔬 Avaliação Toxicológica'

    local msg = string.format('Toxicidade: %d%% | Álcool (BAC): %.2f g/L', math.floor(data.toxicity or 0), data.bac or 0)
    if data.isOverdosing then
        msg = msg .. ' | PACIENTE EM OVERDOSE! Requer Lavagem Gástrica ou Naloxona imediata.'
    end

    lib.notify({
        title = statusTitle,
        description = msg,
        type = alertType,
        duration = data.isOverdosing and 10000 or 6000
    })
end)

-- Comando rápido para socorristas avaliarem toxicologia integrada com vp_needs
RegisterCommand('vertoxicologia', function(_, args)
    local target = tonumber(args[1])
    if not target then
        -- Se não informou id, tenta pegar o jogador mais próximo
        local coords = GetEntityCoords(cache.ped)
        local closestPlayer = lib.getClosestPlayer(coords, 3.0, false)
        if closestPlayer then
            target = GetPlayerServerId(closestPlayer)
        end
    end

    if not target then
        lib.notify({
            title = 'Toxicologia Clínica',
            description = 'Uso: /vertoxicologia [id_do_paciente] ou aproxime-se de um paciente.',
            type = 'error'
        })
        return
    end

    local toxData = lib.callback.await('loki_prescriptions:getPatientToxicology', false, target)
    if toxData and toxData.available then
        TriggerEvent('loki_prescriptions:client:showToxicologyAlert', toxData)
    else
        lib.notify({
            title = 'Toxicologia Clínica',
            description = 'Módulo fisiológico vp_needs não detectado no paciente.',
            type = 'inform'
        })
    end
end, false)
