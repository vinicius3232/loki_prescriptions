--[[
    ============================================================================
    Módulo de Sedação Clínica & Anestesia Hospitalar (Client)
    Permite aplicação de sedativos injetáveis para acalmar ou conter pacientes
    ============================================================================
]]

local isSedated = false

local function isAuthorized()
    local job = Bridge.Framework.fetchPlayerJob()
    if not job then return false end
    if job.name == 'police' then return true end
    if Config.PrescriptionJobs and lib.table.contains(Config.PrescriptionJobs, job.name) then
        return true
    end
    return job.name == 'ambulance'
end

-- Uso do sedativo no paciente próximo
RegisterNetEvent('loki_prescriptions:client:useSedative', function()
    if not isAuthorized() then
        Bridge.Notify.showNotify('Apenas profissionais autorizados podem administrar sedativos.', 'error')
        return
    end

    local closestPlayer = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.5, false)
    if not closestPlayer then
        Bridge.Notify.showNotify('Nenhum paciente próximo para administrar a medicação.', 'error')
        return
    end

    local targetServerId = GetPlayerServerId(closestPlayer)

    -- Animação de preparação e injeção intramuscular
    local success = lib.progressBar({
        duration = 4000,
        label = 'Administrando injeção intramuscular de sedativo...',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer'
        },
        prop = {
            model = 'prop_syringe_01',
            bone = 28422,
            coords = vec3(0.0, 0.0, -0.04),
            rot = vec3(0.0, 0.0, 0.0)
        }
    })

    if not success then
        Bridge.Notify.showNotify('Procedimento de sedação cancelado.', 'error')
        return
    end

    -- Toca áudio de injeção
    SendNUIMessage({
        action = 'playSound',
        sound = 'inject',
        volume = 0.5
    })

    TriggerServerEvent('loki_prescriptions:server:sedatePlayer', targetServerId)
end)

-- Paciente recebendo os efeitos da sedação
RegisterNetEvent('loki_prescriptions:client:receiveSedative', function()
    if isSedated then return end
    isSedated = true

    Bridge.Notify.showNotify('Você recebeu uma injeção de sedativo... Seus músculos estão relaxando profundamente.', 'inform')

    -- Efeitos visuais e sensoriais de torpor anestésico
    SetTimecycleModifier('Bloom')
    SetTimecycleModifierStrength(2.2)
    ShakeGameplayCam('DRUNK_SHAKE', 1.2)

    -- Coloca o ped em relaxamento / repouso
    ClearPedTasksImmediately(cache.ped)
    TaskStartScenarioInPlace(cache.ped, 'WORLD_HUMAN_BUM_SLUMPED', 0, true)

    -- Duração da sedação: 20 segundos
    SetTimeout(20000, function()
        isSedated = false
        ClearTimecycleModifier()
        StopGameplayCamShaking(true)
        ClearPedTasks(cache.ped)
        Bridge.Notify.showNotify('Os efeitos do sedativo começaram a passar.', 'success')
    end)
end)

-- Registro do item no Ox Target em Peds
CreateThread(function()
    Wait(2000)
    if exports.ox_target then
        exports.ox_target:addGlobalPlayer({
            {
                name = 'loki_sedative_target',
                icon = 'fa-solid fa-syringe',
                label = 'Administrar Sedativo Injetável',
                distance = 2.0,
                canInteract = function(entity)
                    if not isAuthorized() then return false end
                    local count = exports.ox_inventory:Search('count', 'sedative')
                    return count and count > 0
                end,
                onSelect = function()
                    TriggerEvent('loki_prescriptions:client:useSedative')
                end
            }
        })
    end
end)
