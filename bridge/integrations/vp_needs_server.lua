--[[
    LOKI MEDICAL SUITE - VP_NEEDS INTEGRATION (SERVER)
    Ponte de autoridade médica entre Loki Prescriptions e o motor fisiológico vp_needs.
]]

VpNeedsBridge = {}

function VpNeedsBridge.IsActive()
    return GetResourceState('vp_needs') == 'started'
end

--- Aplica efeitos metabólicos e fisiológicos de medicamentos consumidos
---@param src number Source do jogador consumidor
---@param med table Configuração do medicamento em Config.Medicine
function VpNeedsBridge.ApplyMedicineEffects(src, med)
    if not VpNeedsBridge.IsActive() or not med or not med.vp_effects then return end

    local effects = med.vp_effects

    -- Alívio de Estresse
    if effects.stress and effects.stress ~= 0 then
        pcall(function()
            if exports.vp_needs and exports.vp_needs.RelieveStress then
                exports.vp_needs:RelieveStress(src, math.abs(effects.stress))
            elseif exports.vp_needs and exports.vp_needs.AdjustNeed then
                exports.vp_needs:AdjustNeed(src, 'stress', effects.stress)
            end
        end)
    end

    -- Tratamento de Doença / Enfermidade
    if effects.cure_sickness then
        pcall(function()
            if exports.vp_needs and exports.vp_needs.AdjustNeed then
                exports.vp_needs:AdjustNeed(src, 'sickness', -(effects.cure_sickness or 20))
            end
        end)
    end

    -- Tratamento de Dependência Química (Addiction)
    if effects.treat_addiction and effects.treat_addiction > 0 then
        pcall(function()
            if exports.vp_needs and exports.vp_needs.TreatAddiction then
                exports.vp_needs:TreatAddiction(src, effects.treat_addiction)
            end
        end)
    end

    -- Alívio de Náusea / Vômito
    if effects.cure_nausea then
        pcall(function()
            TriggerClientEvent('vp_needs:client:cureNausea', src)
        end)
    end

    -- Alívio de Crise de Engasgo / Asfixia
    if effects.cure_choking then
        pcall(function()
            TriggerClientEvent('vp_needs:client:cureChoking', src)
        end)
    end
end

--- Aplica suporte metabólico ao receber transfusão de sangue
---@param target number Source do paciente que recebeu sangue
function VpNeedsBridge.ApplyBloodTransfusion(target)
    if not VpNeedsBridge.IsActive() then return end
    pcall(function()
        if exports.vp_needs and exports.vp_needs.AdjustNeed then
            -- Recupera volemia e hidratação crítica
            exports.vp_needs:AdjustNeed(target, 'thirst', 25)
        end
    end)
end

--- Aplica reposição volêmica contínua de soro fisiológico
---@param target number Source do paciente recebendo soro
---@param thirst number Quantidade de hidratação restaurada
---@param hunger number Quantidade de nutrição restaurada
---@param stress number Quantidade de alívio de estresse
function VpNeedsBridge.ApplySalineTick(target, thirst, hunger, stress)
    if not VpNeedsBridge.IsActive() then return end
    pcall(function()
        if exports.vp_needs and exports.vp_needs.AdjustNeed then
            if thirst and thirst > 0 then
                exports.vp_needs:AdjustNeed(target, 'thirst', thirst)
            end
            if hunger and hunger > 0 then
                exports.vp_needs:AdjustNeed(target, 'hunger', hunger)
            end
            if stress and stress > 0 then
                exports.vp_needs:AdjustNeed(target, 'stress', -stress)
            end
        end
    end)
end


--- Alívio profundo de estresse ao receber sedação clínica
---@param target number Source do paciente sedado
function VpNeedsBridge.ApplySedation(target)
    if not VpNeedsBridge.IsActive() then return end
    pcall(function()
        if exports.vp_needs and exports.vp_needs.RelieveStress then
            exports.vp_needs:RelieveStress(target, 70)
        elseif exports.vp_needs and exports.vp_needs.AdjustNeed then
            exports.vp_needs:AdjustNeed(target, 'stress', -70)
        end
    end)
end

--- Obtém a leitura toxicológica completa do paciente para o corpo médico
---@param targetId number Source do paciente
---@return table Dados toxicológicos
function VpNeedsBridge.GetToxicology(targetId)
    if not VpNeedsBridge.IsActive() then
        return { available = false }
    end

    local entity = Player(targetId)
    local state = entity and entity.state or {}

    local toxicity = state.toxicity or 0
    local bac = state.bac or 0.0
    local isOverdosing = state.isOverdosing or false
    local overdoseFamily = state.overdoseFamily or nil

    local addictionLvl = 0
    pcall(function()
        if exports.vp_needs and exports.vp_needs.GetAddiction then
            local addData = exports.vp_needs:GetAddiction(targetId)
            if type(addData) == 'table' then
                for _, rec in pairs(addData) do
                    if type(rec) == 'table' then
                        addictionLvl = math.max(addictionLvl, tonumber(rec.level) or 0)
                    end
                end
            end
        end
    end)

    return {
        available      = true,
        toxicity       = toxicity,
        bac            = bac,
        isOverdosing   = isOverdosing,
        overdoseFamily = overdoseFamily,
        addictionLevel = addictionLvl
    }
end

-- Callback para o médico solicitar relatório toxicológico no exame físico
lib.callback.register('loki_prescriptions:getPatientToxicology', function(source, targetServerId)
    if not targetServerId or targetServerId <= 0 then return { available = false } end
    return VpNeedsBridge.GetToxicology(targetServerId)
end)

exports('GetVpNeedsBridge', function()
    return VpNeedsBridge
end)
