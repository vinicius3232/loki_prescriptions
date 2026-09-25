--[[
    ============================================================================
    Módulo de Atestado Médico Oficial (Medical Certificate & Sick Leave)
    ============================================================================
]]

-- Abertura do formulário de emissão de atestado pelo médico
local function openCertificateDialog(targetServerId, patientName)
    local job = Bridge.Framework.fetchPlayerJob()
    if not job or not (Config.PrescriptionJobs and lib.table.contains(Config.PrescriptionJobs, job.name)) then
        Bridge.Notify.showNotify('Apenas médicos e profissionais de saúde podem emitir atestados.', 'error')
        return
    end

    local input = lib.inputDialog('Emissão de Atestado Médico', {
        {
            type = 'input',
            label = 'Nome do Paciente',
            default = patientName or '',
            required = true,
            icon = 'fa-solid fa-user'
        },
        {
            type = 'select',
            label = 'Diagnóstico Clínico (CID)',
            options = {
                { value = 'CID 10: T14.2 - Fratura Óssea Traumática em Membro', label = 'T14.2 - Fratura Óssea Traumática' },
                { value = 'CID 10: T14.1 - Ferimento Cortante / Perfuração por Arma', label = 'T14.1 - Perfuração / Lacerção Cirúrgica' },
                { value = 'CID 10: S06.0 - Concussão Cerebral e Traumatismo Craniano', label = 'S06.0 - Concussão / Trauma Craniano' },
                { value = 'CID 10: J06.9 - Infecção Respiratória Aguda / Crise Asmática', label = 'J06.9 - Infecção Respiratória Aguda' },
                { value = 'CID 10: K52.9 - Intoxicação Alimentar e Gastrenterite Aguda', label = 'K52.9 - Intoxicação e Desidratação' },
                { value = 'CID 10: F43.0 - Reação Aguda ao Estresse e Choque Psíquico', label = 'F43.0 - Crise de Pânico e Choque' },
                { value = 'CID 10: Z02.7 - Consulta Médica para Obtenção de Atestado', label = 'Z02.7 - Avaliação Clínica Geral' }
            },
            required = true,
            icon = 'fa-solid fa-stethoscope'
        },
        {
            type = 'slider',
            label = 'Dias de Afastamento e Repouso',
            min = 1,
            max = 5,
            default = 2,
            icon = 'fa-solid fa-calendar-days'
        },
        {
            type = 'textarea',
            label = 'Recomendações Médicas & Restrições',
            placeholder = 'Ex: Proibido esforço físico intenso, dirigir ou pegar peso. Tomar medicação prescrita.',
            required = false,
            icon = 'fa-solid fa-notes-medical'
        }
    })

    if not input then return end

    local certificateData = {
        patientName = input[1],
        diagnosis = input[2],
        days = input[3],
        notes = input[4] or 'Repouso domiciliar recomendado.',
        targetServerId = targetServerId
    }

    if lib and lib.progressBar then
        local success = lib.progressBar({
            duration = 2500,
            label = 'Preenchendo e carimbando atestado médico...',
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = 'missfam4',
                clip = 'base'
            },
            prop = {
                model = 'p_amb_clipboard_01',
                bone = 36029,
                coords = vec3(0.16, 0.08, 0.1),
                rot = vec3(-130.0, -50.0, 0.0)
            }
        })
        if not success then return end
    end

    TriggerServerEvent('loki_prescriptions:server:issueCertificate', certificateData)
end

-- Comando para o médico emitir atestado para si ou paciente próximo
RegisterCommand('atestado', function(source, args)
    local targetId = args[1] and tonumber(args[1])
    if targetId and targetId > 0 then
        openCertificateDialog(targetId)
    else
        -- Procura o jogador mais próximo
        local closestPlayer = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
        if closestPlayer then
            local srvId = GetPlayerServerId(closestPlayer)
            openCertificateDialog(srvId)
        else
            -- Emite para preenchimento manual
            openCertificateDialog(nil)
        end
    end
end, false)

-- Visualizador do Atestado Médico (Disparado quando qualquer pessoa usa o item no inventário)
RegisterNetEvent('loki_prescriptions:client:viewCertificate', function(metadata)
    if not metadata or not metadata.data then
        Bridge.Notify.showNotify('Atestado ilegível ou rasurado.', 'error')
        return
    end

    local d = metadata.data
    local issuedDate = d.created_at and os.date('%d/%m/%Y às %H:%M', d.created_at) or 'Recente'
    local expiresDate = d.expires_at and os.date('%d/%m/%Y', d.expires_at) or 'Indeterminado'

    lib.alertDialog({
        header = '📋 ATESTADO MÉDICO DE AFASTAMENTO',
        content = ([[
### **HOSPITAL CENTRAL DE LOS SANTOS**
*Departamento de Medicina Clínica e Ocupacional*

---

👤 **Paciente:** %s  
🆔 **Passaporte:** %s  

🩺 **Diagnóstico Clínico (CID):**  
> *%s*

📅 **Período de Afastamento:** %d dia(s)  
⏳ **Válido até:** %s  
🗓️ **Emitido em:** %s  

📝 **Observações & Prescrições:**  
%s

---
👨‍⚕️ **Médico Emissor:** Dr(a). %s  
🔖 **Registro Profissional (CRM):** %s  
🏛️ *Documento autêntico carimbado pelo sistema hospitalar.*
        ]]):format(
            d.patient or 'Paciente',
            d.patient_cid or 'N/A',
            d.diagnosis or 'Avaliação Geral',
            tonumber(d.days) or 1,
            expiresDate,
            issuedDate,
            d.notes or 'Repouso clínico recomendado.',
            d.doctor or 'Médico de Plantão',
            d.doctor_cid or 'CRM-LS'
        ),
        centered = true,
        cancel = false
    })
end)

-- Integração de Target em Pacientes Próximos
Citizen.CreateThread(function()
    Wait(2000)
    Bridge.Target.addPlayer({
        {
            name = 'issue_medical_certificate_target',
            label = 'Emitir Atestado Médico',
            icon = 'fa-solid fa-file-signature',
            distance = 2.5,
            groups = Config.PrescriptionJobs or { 'ambulance', 'pharmacy' },
            onSelect = function(data)
                local entity = type(data) == 'number' and data or data.entity
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                openCertificateDialog(targetId)
            end
        }
    })
end)
