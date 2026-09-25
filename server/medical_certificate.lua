--[[
    ============================================================================
    Módulo de Atestado Médico Oficial (Server)
    ============================================================================
]]

RegisterServerEvent('loki_prescriptions:server:issueCertificate', function(data)
    local src = source
    if not src or src <= 0 then return end
    if type(data) ~= 'table' then return end

    -- Validação de cargo médico
    local plyJob = Bridge.Framework.getPlayerJob(src)
    local allowed = false
    if Config.PrescriptionJobs then
        for _, j in ipairs(Config.PrescriptionJobs) do
            if j == plyJob.name then
                allowed = true
                break
            end
        end
    else
        allowed = plyJob.name == 'ambulance'
    end

    if not allowed then
        Bridge.Notify.showNotify(src, 'Você não possui autorização médica para emitir atestados.', 'error')
        return
    end

    local doctorName = Bridge.Framework.getPlayerName(src)
    local doctorCid = Bridge.Framework.getUniqueId(src)

    local targetSrc = tonumber(data.targetServerId)
    local patientName = data.patientName and tostring(data.patientName):sub(1, 50) or 'Paciente'
    local patientCid = 'N/A'

    local recipientSrc = src
    if targetSrc and targetSrc > 0 and targetSrc ~= src then
        local doctorPed = GetPlayerPed(src)
        local targetPed = GetPlayerPed(targetSrc)
        if targetPed > 0 and #(GetEntityCoords(doctorPed) - GetEntityCoords(targetPed)) <= 4.0 then
            recipientSrc = targetSrc
            patientName = Bridge.Framework.getPlayerName(targetSrc)
            patientCid = Bridge.Framework.getUniqueId(targetSrc)
        end
    else
        patientCid = Bridge.Framework.getUniqueId(src)
    end

    local days = math.max(1, math.min(5, tonumber(data.days) or 2))
    local now = os.time()
    local expiresAt = now + (days * 86400)

    local metadata = {
        data = {
            patient = patientName,
            patient_cid = patientCid,
            doctor = doctorName,
            doctor_cid = doctorCid,
            diagnosis = data.diagnosis and tostring(data.diagnosis):sub(1, 80) or 'Avaliação Geral',
            days = days,
            notes = data.notes and tostring(data.notes):sub(1, 150) or 'Repouso domiciliar.',
            created_at = now,
            expires_at = expiresAt
        },
        description = ('Dr(a). %s | Paciente: %s (%d dia(s))'):format(doctorName, patientName, days)
    }

    local given = Bridge.Inventory.addItem(recipientSrc, 'medical_certificate', 1, metadata)
    if given then
        Bridge.Notify.showNotify(src, ('Atestado de %d dia(s) emitido com sucesso!'):format(days), 'success')
        if recipientSrc ~= src then
            Bridge.Notify.showNotify(recipientSrc, ('Você recebeu um Atestado Médico de Dr(a). %s.'):format(doctorName), 'inform')
            if NexusBridge then
                NexusBridge.SendNotification(recipientSrc, 'LSMC Departamento Médico', ('Seu atestado médico de %d dia(s) foi homologado pelo Dr(a). %s.'):format(days, doctorName), 'docs')
            end
            if VpPhoneBridge then
                VpPhoneBridge.SendNotification(recipientSrc, 'LSMC Atestado', ('Atestado de %d dia(s) homologado pelo Dr(a). %s.'):format(days, doctorName), 'Health')
            end
            if VpTabletBridge then
                VpTabletBridge.RecordAmbulanceReport(patientCid, doctorName, 'Atestado Médico Oficial', ('Atestado de %d dia(s) homologado. Motivo: %s'):format(days, data.diagnosis or 'Avaliação Geral'))
            end
        end
    else
        Bridge.Notify.showNotify(src, 'Mochila cheia. Não foi possível entregar o atestado.', 'error')
    end
end)

-- Registro do item utilizável para leitura do atestado
CreateThread(function()
    Wait(1500)
    Bridge.Framework.registerItem('medical_certificate', function(source, item)
        local meta = item and (item.metadata or item.info)
        TriggerClientEvent('loki_prescriptions:client:viewCertificate', source, meta)
    end)
end)
