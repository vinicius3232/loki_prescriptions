--[[
    ============================================================================
    Módulo de Necropsia & Perícia Médico-Legal (Client)
    Permite exames cadavéricos, análise tanatológica e emissão de laudo oficial
    ============================================================================
]]

local function isAuthorizedJob()
    local job = Bridge.Framework.fetchPlayerJob()
    if not job then return false end
    if job.name == 'police' then return true end
    if Config.PrescriptionJobs and lib.table.contains(Config.PrescriptionJobs, job.name) then
        return true
    end
    return job.name == 'ambulance'
end

-- Visualização do Laudo de Necropsia ao usar o item
RegisterNetEvent('loki_prescriptions:client:viewAutopsyReport', function(metadata)
    if not metadata or not metadata.data then
        lib.alertDialog({
            header = 'Laudo Ilegível',
            content = 'Este documento está rasurado ou não possui dados tanatológicos legíveis.',
            centered = true
        })
        return
    end

    local d = metadata.data
    local toxicText = d.toxicology and d.toxicology ~= '' and d.toxicology or 'Nenhuma substância tóxica ou tóxico-farmacológica detectada no sangue.'
    local injuriesText = d.injuries and d.injuries ~= '' and d.injuries or 'Sem evidências de fraturas ósseas cominutivas aparentes.'

    local reportContent = ([[
### 🏛️ LAUDO PERICIAL MÉDICO-LEGAL
**Protocolo Tanatológico:** `%s`  
**Data/Hora do Exame:** %s  
**Perito Legista:** Dr(a). %s (Registro: %s)  

---

#### 👤 IDENTIFICAÇÃO DO CORPO
- **Nome da Vítima:** %s
- **Registro Civil / ID:** %s

---

#### 💀 CAUSA MORTIS PRINCIPAL
**%s**

---

#### 🔬 ACHADOS TRAUMATOLÓGICOS
%s

---

#### 🧪 EXAME TOXICOLÓGICO SANGUÍNEO
%s

---
*Documento lavrado pelo Departamento de Medicina Legal com fé pública processual.*
]]):format(
        d.reportId or 'IML-7532',
        d.date or os.date('%d/%m/%Y %H:%M'),
        d.coronerName or 'Legista Plantonista',
        d.coronerCid or 'CRML-000',
        d.victimName or 'Não Identificado',
        d.victimCid or 'N/A',
        d.causeOfDeath or 'Colapso Cardiorrespiratório Agudo',
        injuriesText,
        toxicText
    )

    lib.alertDialog({
        header = 'Instituto Médico-Legal',
        content = reportContent,
        centered = true,
        size = 'lg'
    })
end)

-- Processo pericial de autópsia no cadáver
local function startForensicAutopsy(targetEntity)
    if not isAuthorizedJob() then
        Bridge.Notify.showNotify('Você não possui credenciamento pericial para conduzir necropsias.', 'error')
        return
    end

    local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetEntity))
    if not targetServerId or targetServerId <= 0 then
        Bridge.Notify.showNotify('Cadáver inválido ou não sincronizado.', 'error')
        return
    end

    -- Confirmação e início dos procedimentos periciais
    local proceed = lib.alertDialog({
        header = 'Exame Cadavérico Pericial',
        content = 'Deseja iniciar os procedimentos de necropsia e coleta tanatológica deste corpo?',
        centered = true,
        cancel = true
    })

    if proceed ~= 'confirm' then return end

    -- Progress Bar com animações de inspeção médica detalhada
    local success = lib.progressBar({
        duration = 7000,
        label = 'Realizando incisão pericial e análise tanatológica...',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'amb@medic@standing@kneel@base',
            clip = 'base'
        },
        prop = {
            model = 'p_amb_clipboard_01',
            bone = 36029,
            coords = vec3(0.16, 0.08, 0.1),
            rot = vec3(-130.0, -50.0, 0.0)
        }
    })

    if not success then
        Bridge.Notify.showNotify('Procedimento pericial interrompido.', 'error')
        return
    end

    -- Solicita dados ao servidor
    lib.callback('loki_prescriptions:server:performAutopsy', false, function(reportData)
        if not reportData then
            Bridge.Notify.showNotify('Falha ao tabular dados periciais da vítima.', 'error')
            return
        end

        -- Exibe resumo prévio ao legista com opção de emissão
        local confirmIssue = lib.alertDialog({
            header = 'Laudo Pericial Concluído',
            content = ('**Vítima:** %s  \n**Causa Mortis:** %s  \n**Lesões:** %s  \n\nDeseja lavrar e imprimir o laudo oficial no seu inventário?'):format(
                reportData.victimName,
                reportData.causeOfDeath,
                reportData.injuries
            ),
            centered = true,
            cancel = true
        })

        if confirmIssue == 'confirm' then
            TriggerServerEvent('loki_prescriptions:server:issueAutopsyReport', reportData)
        end
    end, targetServerId)
end

-- Registro de Target Global em Peds/Jogadores
CreateThread(function()
    Wait(2000)

    if exports.ox_target then
        exports.ox_target:addGlobalPlayer({
            {
                name = 'loki_prescriptions:autopsy_target',
                icon = 'fa-solid fa-skull-crossbones',
                label = 'Realizar Exame Cadavérico / Necropsia',
                distance = 2.2,
                canInteract = function(entity)
                    if not isAuthorizedJob() then return false end
                    -- Checa se o alvo está morto no state bag
                    local isDead = Entity(entity).state.isDead
                    return isDead == true
                end,
                onSelect = function(data)
                    startForensicAutopsy(data.entity)
                end
            }
        })
    end
end)
