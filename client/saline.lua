--[[
    ============================================================================
    LOKI PRESCRIPTIONS - SALINE IV DRIP INFUSION (CLIENT)
    Absorbed from ak47_qb_ambulancejob and upgraded for QBox & ox_target
    ============================================================================
]]

local activeSalineProps = {}

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 200 do
        Wait(10)
        timeout = timeout + 1
    end
    return hash
end

RegisterNetEvent('loki_prescriptions:client:useSalineItem', function()
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)

    -- Procura o jogador mais prximo
    local closestPlayer, closestDist = lib.getClosestPlayer(myCoords, 2.5, false)
    local targetServerId = nil

    if closestPlayer and closestDist <= 2.5 then
        targetServerId = GetPlayerServerId(closestPlayer)
    else
        -- Fallback: auto-aplicao se estiver deitado em maca ou cama
        local isLying = IsEntityPlayingAnim(myPed, 'amb@world_human_sunbathe@male@back@base', 'base', 3) or
                        IsEntityPlayingAnim(myPed, 'savecouch@', 't_sleep_loop_couch', 3) or
                        LocalPlayer.state.inBed or LocalPlayer.state.onStretcher
        if isLying then
            targetServerId = cache.serverId
        else
            Bridge.Notify.showNotify('Nenhum paciente prximo para instalar o soro.', 'error')
            return
        end
    end

    if lib and lib.progressBar then
        local success = lib.progressBar({
            duration = 3500,
            label = 'Instalando cateter e bolsa de soro fisiolgico...',
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = 'mini@cpr@char_a@cpr_str',
                clip = 'cpr_pumpchest'
            }
        })
        if not success then return end
    end

    TriggerServerEvent('loki_prescriptions:server:attachSaline', targetServerId)
end)

RegisterNetEvent('loki_prescriptions:client:syncAttachSaline', function(targetServerId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetServerId))
    if not targetPed or targetPed == 0 then return end

    if activeSalineProps[targetServerId] and DoesEntityExist(activeSalineProps[targetServerId]) then
        DeleteEntity(activeSalineProps[targetServerId])
    end

    local modelHash = loadModel('prop_saline')
    local pCoords = GetEntityCoords(targetPed)
    local obj = CreateObject(modelHash, pCoords.x, pCoords.y, pCoords.z, true, true, false)

    -- Anexa prximo ao ombro/tronco do paciente
    AttachEntityToEntity(
        obj, targetPed, 0,
        -0.25, -0.15, 0.40,
        0.0, 0.0, 0.0,
        false, false, false, false, 2, true
    )
    SetModelAsNoLongerNeeded(modelHash)

    activeSalineProps[targetServerId] = obj
end)

RegisterNetEvent('loki_prescriptions:client:syncRemoveSaline', function(targetServerId)
    if activeSalineProps[targetServerId] then
        if DoesEntityExist(activeSalineProps[targetServerId]) then
            DeleteEntity(activeSalineProps[targetServerId])
        end
        activeSalineProps[targetServerId] = nil
    end
end)

RegisterNetEvent('loki_prescriptions:client:healSalineTick', function(healAmount)
    local myPed = PlayerPedId()
    if IsEntityDead(myPed) then return end

    local currentHp = GetEntityHealth(myPed)
    local maxHp = GetEntityMaxHealth(myPed)
    if currentHp < maxHp then
        SetEntityHealth(myPed, math.min(maxHp, currentHp + (healAmount or 3)))
    end
end)

-- Limpeza ao parar o resource
AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    for sid, obj in pairs(activeSalineProps) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
end)

exports('hasActiveSaline', function(targetServerId)
    return activeSalineProps[tonumber(targetServerId)] ~= nil
end)
