--[[
    ============================================================================
    LOKI PRESCRIPTIONS - MCI START TRIAGE SYSTEM (SERVER)
    Protocolo de Triagem para Incidentes com Múltiplas Vítimas
    Cores: GREEN (Leve) | YELLOW (Urgente) | RED (Imediato) | BLACK (Expectante/Óbito)
    ============================================================================
]]

local validTags = {
    GREEN  = { label = 'VERDE (Prioridade 3 - Ambulatorial)', color = '#22c55e' },
    YELLOW = { label = 'AMARELO (Prioridade 2 - Urgente)',     color = '#eab308' },
    RED    = { label = 'VERMELHO (Prioridade 1 - Imediato)',    color = '#ef4444' },
    BLACK  = { label = 'PRETO (Prioridade 0 - Óbito)',         color = '#1e293b' },
}

RegisterNetEvent('loki_prescriptions:server:setTriageTag', function(targetServerId, tag)
    local src = source
    if not src or src <= 0 then return end
    targetServerId = tonumber(targetServerId)
    if not targetServerId or targetServerId <= 0 then return end

    -- Validação de Job Médico
    local playerJob = Bridge.Framework.fetchPlayerJob(src)
    if not playerJob or (playerJob.name ~= 'ambulance' and playerJob.name ~= 'doctor') then
        Bridge.Notify.showNotify(src, 'Acesso restrito ao corpo médico de emergência.', 'error')
        return
    end

    local targetPed = GetPlayerPed(targetServerId)
    if not targetPed or targetPed == 0 then
        Bridge.Notify.showNotify(src, 'Vítima não encontrada.', 'error')
        return
    end

    -- Distância de segurança física
    local medicPed = GetPlayerPed(src)
    local dist = #(GetEntityCoords(medicPed) - GetEntityCoords(targetPed))
    if dist > 4.5 then
        Bridge.Notify.showNotify(src, 'Muito distante da vítima para aplicar etiqueta.', 'error')
        return
    end

    if tag == 'CLEAR' then
        Player(targetServerId).state:set('triageTag', nil, true)
        Bridge.Notify.showNotify(src, 'Etiqueta de triagem removida da vítima.', 'inform')
        Bridge.Notify.showNotify(targetServerId, 'Sua etiqueta de triagem foi retirada pelo socorrista.', 'inform')
        return
    end

    if not validTags[tag] then
        Bridge.Notify.showNotify(src, 'Classificação de triagem inválida.', 'error')
        return
    end

    -- Sincroniza via State Bag replicada
    Player(targetServerId).state:set('triageTag', tag, true)

    local tagInfo = validTags[tag]
    Bridge.Notify.showNotify(src, string.format('Vítima classificada como: %s', tagInfo.label), 'success')
    Bridge.Notify.showNotify(targetServerId, string.format('Você recebeu uma etiqueta de triagem médica: %s', tagInfo.label), 'inform')
end)

exports('getPlayerTriageTag', function(targetServerId)
    local p = Player(tonumber(targetServerId))
    return p and p.state and p.state.triageTag or nil
end)
