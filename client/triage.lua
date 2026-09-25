--[[
    ============================================================================
    LOKI PRESCRIPTIONS - MCI START TRIAGE SYSTEM (CLIENT)
    Visualização de Etiquetas de Triagem 3D & Menu de Classificação Rápida
    ============================================================================
]]

local tagColors = {
    GREEN  = { r = 34,  g = 197, b = 94,  a = 210, label = 'PRIORIDADE 3 (LEVE)' },
    YELLOW = { r = 234, g = 179, b = 8,   a = 210, label = 'PRIORIDADE 2 (URGENTE)' },
    RED    = { r = 239, g = 68,  b = 68,  a = 230, label = 'PRIORIDADE 1 (IMEDIATO)' },
    BLACK  = { r = 15,  g = 23,  b = 42,  a = 230, label = 'PRIORIDADE 0 (ÓBITO)' },
}

local function OpenTriageMenu(targetServerId)
    if not targetServerId or targetServerId <= 0 then return end

    lib.registerContext({
        id = 'loki_triage_select_menu',
        title = 'Triagem START de Vítimas',
        options = {
            {
                title = 'Vermelho (Prioridade 1 - Imediato)',
                description = 'Hemorragia maciça, vias aéreas obstruídas, choque hipovolêmico.',
                icon = 'skull-crossbones',
                iconColor = '#ef4444',
                onSelect = function()
                    TriggerServerEvent('loki_prescriptions:server:setTriageTag', targetServerId, 'RED')
                end
            },
            {
                title = 'Amarelo (Prioridade 2 - Urgente)',
                description = 'Fraturas fechadas, queimaduras moderadas, paciente estável.',
                icon = 'triangle-exclamation',
                iconColor = '#eab308',
                onSelect = function()
                    TriggerServerEvent('loki_prescriptions:server:setTriageTag', targetServerId, 'YELLOW')
                end
            },
            {
                title = 'Verde (Prioridade 3 - Leve / Ambulatorial)',
                description = 'Ferimentos leves, paciente deambula e responde a comandos.',
                icon = 'person-walking',
                iconColor = '#22c55e',
                onSelect = function()
                    TriggerServerEvent('loki_prescriptions:server:setTriageTag', targetServerId, 'GREEN')
                end
            },
            {
                title = 'Preto (Prioridade 0 - Expectante / Óbito)',
                description = 'PCR sem resposta, lesões catastróficas incompatíveis com a vida.',
                icon = 'cross',
                iconColor = '#64748b',
                onSelect = function()
                    TriggerServerEvent('loki_prescriptions:server:setTriageTag', targetServerId, 'BLACK')
                end
            },
            {
                title = 'Remover Classificação de Triagem',
                icon = 'trash',
                onSelect = function()
                    TriggerServerEvent('loki_prescriptions:server:setTriageTag', targetServerId, 'CLEAR')
                end
            },
        }
    })

    lib.showContext('loki_triage_select_menu')
end

RegisterNetEvent('loki_prescriptions:client:openTriageMenu', function(targetServerId)
    OpenTriageMenu(targetServerId)
end)

-- Comando de atalho para paramédicos
RegisterCommand('triagem', function()
    local job = Bridge.Framework.fetchPlayerJob()
    if not job or (job.name ~= 'ambulance' and job.name ~= 'doctor') then
        Bridge.Notify.showNotify('Acesso exclusivo para socorristas e médicos.', 'error')
        return
    end

    local myCoords = GetEntityCoords(cache.ped)
    local closestPlayer, closestDist = lib.getClosestPlayer(myCoords, 3.0, false)
    if not closestPlayer or closestDist > 3.0 then
        Bridge.Notify.showNotify('Nenhuma vítima próxima para realizar triagem.', 'error')
        return
    end

    local targetServerId = GetPlayerServerId(closestPlayer)
    OpenTriageMenu(targetServerId)
end, false)

-- Thread de Renderização 3D de Marcadores de Triagem
CreateThread(function()
    while true do
        local sleep = 1200
        local job = Bridge.Framework.fetchPlayerJob()
        local isMedicOrPolice = job and (job.name == 'ambulance' or job.name == 'doctor' or job.name == 'police')

        if isMedicOrPolice then
            local myCoords = GetEntityCoords(cache.ped)
            local players = lib.getNearbyPlayers(myCoords, 25.0, false)

            if #players > 0 then
                sleep = 0
                for _, pData in ipairs(players) do
                    local sid = GetPlayerServerId(pData.id)
                    local tag = Player(sid).state.triageTag
                    if tag and tagColors[tag] then
                        local conf = tagColors[tag]
                        local pPed = pData.ped
                        local pPos = GetEntityCoords(pPed)

                        -- Marcador luminoso flutuante sobre a cabeça
                        DrawMarker(
                            2,
                            pPos.x, pPos.y, pPos.z + 1.25,
                            0.0, 0.0, 0.0,
                            180.0, 0.0, 0.0,
                            0.25, 0.25, 0.25,
                            conf.r, conf.g, conf.b, conf.a,
                            true, true, 2, false, nil, nil, false
                        )
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

exports('openTriageMenu', function(targetServerId)
    OpenTriageMenu(targetServerId)
end)
