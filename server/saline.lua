--[[
    ============================================================================
    LOKI PRESCRIPTIONS - SALINE IV DRIP INFUSION (SERVER)
    Absorbed from ak47_qb_ambulancejob and integrated with vp_needs & QBox
    ============================================================================
]]

local activeSalineSessions = {}

RegisterNetEvent('loki_prescriptions:server:attachSaline', function(targetServerId)
    local src = source
    if not src or src <= 0 then return end
    targetServerId = tonumber(targetServerId)
    if not targetServerId or targetServerId <= 0 then return end

    local targetPed = GetPlayerPed(targetServerId)
    if not targetPed or targetPed == 0 then
        Bridge.Notify.showNotify(src, 'Paciente invlido ou desconectado.', 'error')
        return
    end

    -- Distncia de segurana fsica server-side
    local medicPed = GetPlayerPed(src)
    local medicCoords = GetEntityCoords(medicPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(medicCoords - targetCoords) > 4.5 then
        Bridge.Notify.showNotify(src, 'Muito longe do paciente para instalar o soro.', 'error')
        return
    end

    -- Se j estiver com soro, remove
    if activeSalineSessions[targetServerId] then
        TriggerEvent('loki_prescriptions:server:removeSaline', targetServerId)
        return
    end

    -- Validao e consumo de inventrio fail-closed
    local itemCount = Bridge.Inventory.getItemCount(src, 'saline')
    if not itemCount or itemCount < 1 then
        Bridge.Notify.showNotify(src, 'Voc no possui uma bolsa de soro fisiolgico.', 'error')
        return
    end

    Bridge.Inventory.removeItem(src, 'saline', 1)

    -- Marca state bag replicada
    Player(targetServerId).state:set('hasSaline', true, true)

    activeSalineSessions[targetServerId] = {
        medic = src,
        ticks = 0,
        maxTicks = 60, -- 60 ticks x 3s = 180s (3 minutos de infuso)
    }

    -- Sincroniza entidade fsica do prop nos clientes
    TriggerClientEvent('loki_prescriptions:client:syncAttachSaline', -1, targetServerId)
    Bridge.Notify.showNotify(src, 'Bolsa de soro fisiolgico instalada com sucesso.', 'success')
    Bridge.Notify.showNotify(targetServerId, 'Uma infuso intravenosa de soro fisiolgico foi iniciada.', 'inform')

    -- Thread de infuso contnua
    CreateThread(function()
        local sid = targetServerId
        while activeSalineSessions[sid] do
            Wait(3000)

            local session = activeSalineSessions[sid]
            if not session then break end

            local pPed = GetPlayerPed(sid)
            if not pPed or pPed == 0 then
                activeSalineSessions[sid] = nil
                break
            end

            session.ticks = session.ticks + 1

            -- Cura gradual de HP
            TriggerClientEvent('loki_prescriptions:client:healSalineTick', sid, 3)

            -- Suporte metablico e volemia via vp_needs
            if VpNeedsBridge and VpNeedsBridge.ApplySalineTick then
                VpNeedsBridge.ApplySalineTick(sid, 3, 1, 2)
            end

            -- Trmino da bolsa
            if session.ticks >= session.maxTicks then
                activeSalineSessions[sid] = nil
                Player(sid).state:set('hasSaline', false, true)
                TriggerClientEvent('loki_prescriptions:client:syncRemoveSaline', -1, sid)
                Bridge.Notify.showNotify(sid, 'A bolsa de soro fisiolgico terminou.', 'inform')
                break
            end
        end
    end)
end)

RegisterNetEvent('loki_prescriptions:server:removeSaline', function(targetServerId)
    local src = source
    targetServerId = tonumber(targetServerId)
    if not targetServerId then return end

    if activeSalineSessions[targetServerId] then
        activeSalineSessions[targetServerId] = nil
        Player(targetServerId).state:set('hasSaline', false, true)
        TriggerClientEvent('loki_prescriptions:client:syncRemoveSaline', -1, targetServerId)
        if src and src > 0 then
            Bridge.Notify.showNotify(src, 'Bolsa de soro fisiolgico desconectada.', 'inform')
        end
        Bridge.Notify.showNotify(targetServerId, 'A infuso de soro foi interrompida.', 'inform')
    end
end)

-- Registro do item utilizvel
Bridge.Framework.registerItem('saline', function(source)
    TriggerClientEvent('loki_prescriptions:client:useSalineItem', source)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if activeSalineSessions[src] then
        activeSalineSessions[src] = nil
        TriggerClientEvent('loki_prescriptions:client:syncRemoveSaline', -1, src)
    end
end)

exports('isSalineActive', function(targetServerId)
    return activeSalineSessions[tonumber(targetServerId)] ~= nil
end)
