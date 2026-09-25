--[[
    ============================================================================
    Módulo de Radiologia & Raio-X Digital Hospitalar (Server)
    Processamento radiológico, validação de fraturas e impressão de laudos
    ============================================================================
]]

local function isDoctor(src)
    local job = Bridge.Framework.getPlayerJob(src)
    if not job then return false end
    if Config.PrescriptionJobs then
        for _, j in ipairs(Config.PrescriptionJobs) do
            if j == job.name then return true end
        end
    end
    return job.name == 'ambulance'
end

-- Callback de varredura radiológica
lib.callback.register('loki_prescriptions:server:scanPatientXray', function(source, targetServerId)
    local src = source
    if not isDoctor(src) then return {} end

    local target = tonumber(targetServerId)
    if not target or target <= 0 then return {} end

    local damages = Player(target).state.damages or {}
    local detectedInjuries = {}

    -- Mapeamento dos ossos do sistema de danos para o Raio-X
    local boneMap = {
        head = 'head',
        mouth = 'head',
        neck = 'head',
        upper_body = 'chest',
        spine = 'chest',
        lower_body = 'chest',
        larm = 'left_arm',
        rarm = 'right_arm',
        lleg = 'left_leg',
        rleg = 'right_leg'
    }

    local alreadyMarked = {}

    for boneKey, weapons in pairs(damages) do
        local mappedPart = boneMap[boneKey]
        if mappedPart and not alreadyMarked[mappedPart] then
            alreadyMarked[mappedPart] = true
            
            -- Detecta se há ferimento por projétil balístico ou fratura mecânica
            local isBullet = false
            for _, entry in pairs(weapons) do
                local wName = entry.data and entry.data.weapon and tostring(entry.data.weapon):upper() or ''
                if wName:find('PISTOL') or wName:find('RIFLE') or wName:find('SMG') or wName:find('SHOTGUN') or wName:find('WEAPON') then
                    isBullet = true
                    break
                end
            end

            table.insert(detectedInjuries, {
                part = mappedPart,
                type = isBullet and 'bullet' or 'fracture'
            })
        end
    end

    return detectedInjuries
end)

-- Emissão e impressão do Laudo Radiológico no Inventário
RegisterServerEvent('loki_prescriptions:server:printXrayReport', function(payload)
    local src = source
    if not isDoctor(src) then return end
    if type(payload) ~= 'table' then return end

    local patient = payload.patient or {}
    local results = payload.results or {}
    local doctorName = Bridge.Framework.getPlayerName(src)

    local findings = {}
    for _, res in ipairs(results) do
        local typeLabel = res.type == 'bullet' and 'Corpo Estranho / Projétil Balístico' or 'Fratura Óssea'
        table.insert(findings, ('Região: %s [%s]'):format(res.part:upper(), typeLabel))
    end

    local findingsStr = #findings > 0 and table.concat(findings, ', ') or 'Estrutura óssea íntegra sem fraturas aparentes.'
    local now = os.time()

    local metadata = {
        data = {
            patient = patient.name or 'Paciente',
            doctor = doctorName,
            diagnosis = 'Exame Radiológico Digital / Tomografia',
            days = 0,
            notes = ('Laudo Radiológico: %s'):format(findingsStr),
            created_at = now
        },
        description = ('Chapa de Raio-X | Paciente: %s (Dr(a). %s)'):format(patient.name or 'Paciente', doctorName)
    }

    local given = Bridge.Inventory.addItem(src, 'medical_certificate', 1, metadata)
    if given then
        Bridge.Notify.showNotify(src, 'Chapa e Laudo Radiológico impressos com sucesso no seu inventário.', 'success')
    else
        Bridge.Notify.showNotify(src, 'Mochila cheia para receber o laudo radiológico.', 'error')
    end
end)
