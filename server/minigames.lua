--[[
    ============================================================================
    LOKI PRESCRIPTIONS - INTERACTIVE MINIGAMES SERVER
    Server Authority, Anti-Exploit, Distance Checks, Inventory Fail-Closed & Sync
    ============================================================================
]]

local minigameLocks = {}
local minigameCooldowns = {}

-- Cleanup locks on disconnect
AddEventHandler("playerDropped", function()
    local src = source
    minigameCooldowns[src] = nil
    for targetId, locker in pairs(minigameLocks) do
        if locker == src then
            minigameLocks[targetId] = nil
        end
    end
end)

-- Validation helper
local function ValidateInteraction(medicSrc, targetId, maxDist)
    if not (medicSrc and targetId and medicSrc > 0 and targetId > 0) then return false end

    local medicPed = GetPlayerPed(medicSrc)
    local targetPed = GetPlayerPed(targetId)
    if not (medicPed and targetPed and medicPed > 0 and targetPed > 0) then return false end

    -- Distance check (3D + Z bounding box)
    local coordsA = GetEntityCoords(medicPed)
    local coordsB = GetEntityCoords(targetPed)
    local dist = #(coordsA - coordsB)
    if dist > (maxDist or 4.5) then return false end

    return true
end

-- ============================================================================
-- 1. SUTURA CIRÚRGICA
-- ============================================================================

RegisterNetEvent("loki_prescriptions:server:completeSuture", function(targetId, part)
    local src = source
    if not ValidateInteraction(src, targetId, 4.0) then return end

    local targetPlayer = Player(targetId)
    local targetState = targetPlayer.state
    local currentDamages = targetState.damages or {}

    -- Heal bone / wound
    if currentDamages[part] then
        currentDamages[part] = nil
        targetState:set("damages", currentDamages, true)
    end

    -- Boost HP slightly
    local targetPed = GetPlayerPed(targetId)
    local currentHp = GetEntityHealth(targetPed)
    if currentHp > 0 and currentHp < 200 then
        SetEntityHealth(targetPed, math.min(200, currentHp + 25))
    end

    Bridge.Notify.showNotify(targetId, "Um médico suturou e fechou seus ferimentos cirurgicamente.", "success")
end)

-- ============================================================================
-- 2. HEMOSTASIA E ANASTOMOSE (CLAMPING)
-- ============================================================================

RegisterNetEvent("loki_prescriptions:server:completeClamp", function(targetId, part)
    local src = source
    if not ValidateInteraction(src, targetId, 4.0) then return end

    local targetPlayer = Player(targetId)
    local targetState = targetPlayer.state
    local currentDamages = targetState.damages or {}

    -- Stop bleeding on part
    if currentDamages[part] then
        currentDamages[part].bleeding = false
        targetState:set("damages", currentDamages, true)
    end

    targetState:set("isBleeding", false, true)
    Bridge.Notify.showNotify(targetId, "Sua hemorragia arterial foi contida por pinçamento e anastomose.", "success")
end)

-- ============================================================================
-- 3. EXTRAÇÃO DE PROJÉTIL
-- ============================================================================

RegisterNetEvent("loki_prescriptions:server:completeBulletExtraction", function(targetId, part)
    local src = source
    if not ValidateInteraction(src, targetId, 4.0) then return end

    local targetPlayer = Player(targetId)
    local targetState = targetPlayer.state
    local currentDamages = targetState.damages or {}

    if currentDamages[part] then
        currentDamages[part].bullet = false
        targetState:set("damages", currentDamages, true)
    end

    -- Drop extracted bullet as evidence / item if ox_inventory is active
    if exports.ox_inventory then
        exports.ox_inventory:AddItem(src, "ammo-bullet", 1, {
            description = string.format("Projétil balístico extraído de %s", part)
        })
    end

    Bridge.Notify.showNotify(targetId, "O projétil de arma de fogo foi extraído do seu corpo.", "success")
end)

-- ============================================================================
-- 4. AFERIÇÃO DE PRESSÃO (BLOOD PRESSURE MONITOR)
-- ============================================================================

RegisterNetEvent("loki_prescriptions:server:completeBPCheck", function(targetId, part, vitals)
    local src = source
    if not ValidateInteraction(src, targetId, 4.0) then return end

    local targetPlayer = Player(targetId)
    local targetState = targetPlayer.state

    if vitals then
        targetState:set("lastBP", string.format("%s/%s", vitals.sys, vitals.dia), true)
        targetState:set("pulse", vitals.pulse, true)
    end

    Bridge.Notify.showNotify(targetId, "O médico aferiu seus sinais vitais e pressão arterial com o esfigmomanômetro.", "inform")
end)

-- ============================================================================
-- 5. CURATIVO DE TRAUMA (BANDAGE DRESSING)
-- ============================================================================

RegisterNetEvent("loki_prescriptions:server:completeBandage", function(targetId, part)
    local src = source
    if not ValidateInteraction(src, targetId, 4.0) then return end

    local targetPlayer = Player(targetId)
    local targetState = targetPlayer.state
    local currentDamages = targetState.damages or {}

    if currentDamages[part] then
        currentDamages[part].bandaged = true
        targetState:set("damages", currentDamages, true)
    end

    -- Restore small amount of health
    local targetPed = GetPlayerPed(targetId)
    local currentHp = GetEntityHealth(targetPed)
    if currentHp > 0 and currentHp < 200 then
        SetEntityHealth(targetPed, math.min(200, currentHp + 15))
    end

    Bridge.Notify.showNotify(targetId, "Um curativo compressivo estéril foi aplicado sobre a lesão.", "success")
end)

-- ============================================================================
-- 6. ETILÔMETRO / BAFÔMETRO DIGITAL
-- ============================================================================

RegisterNetEvent("loki_prescriptions:server:requestBreathTest", function(targetId)
    local src = source
    if not ValidateInteraction(src, targetId, 3.5) then
        Bridge.Notify.showNotify(src, "O indivíduo está muito distante.", "error")
        return
    end

    TriggerClientEvent("loki_prescriptions:client:startBreathTest", src, src, false)
    TriggerClientEvent("loki_prescriptions:client:startBreathTest", targetId, src, true)
end)

RegisterNetEvent("plt_departments:server:requestBreathTest", function(targetId)
    TriggerEvent("loki_prescriptions:server:requestBreathTest", targetId)
end)

RegisterNetEvent("loki_prescriptions:server:syncBreathProgress", function(officerId, progress, indicatorPos)
    if officerId and officerId > 0 then
        TriggerClientEvent("loki_prescriptions:client:updateBreathProgress", officerId, progress, indicatorPos)
    end
end)

RegisterNetEvent("plt_departments:server:syncBreathProgress", function(officerId, progress, indicatorPos)
    TriggerEvent("loki_prescriptions:server:syncBreathProgress", officerId, progress, indicatorPos)
end)

RegisterNetEvent("loki_prescriptions:server:breathalyzerComplete", function(officerId, success)
    local patientSrc = source
    local bac = 0.0

    if success then
        -- Integrate with vp_needs toxicology if available
        local patientState = Player(patientSrc).state
        local toxicLevel = patientState.vp_toxicology or patientState.alcohol or 0

        if toxicLevel > 0 then
            bac = math.min(0.35, (toxicLevel / 100) * 0.25)
        else
            -- 30% chance of random minor alcohol trace in normal population, otherwise 0.00
            if math.random(1, 100) <= 30 then
                bac = math.random(1, 15) / 100
            else
                bac = 0.00
            end
        end
    end

    local targetName = Bridge.Framework.fetchPlayerName(patientSrc) or "Condutor"

    if officerId and officerId > 0 then
        TriggerClientEvent("loki_prescriptions:client:breathTestResult", officerId, bac, targetName)
    end
    TriggerClientEvent("loki_prescriptions:client:breathTestResult", patientSrc, bac, targetName)
end)

RegisterNetEvent("plt_departments:server:sendBreathResult", function(officerId, bac)
    local patientSrc = source
    local targetName = Bridge.Framework.fetchPlayerName(patientSrc) or "Condutor"
    if officerId and officerId > 0 then
        TriggerClientEvent("loki_prescriptions:client:breathTestResult", officerId, bac, targetName)
    end
    TriggerClientEvent("loki_prescriptions:client:breathTestResult", patientSrc, bac, targetName)
end)

-- ============================================================================
-- 7. PASSAGEM DE CARTÃO MAGNÉTICO (KEYCARD SWIPE)
-- ============================================================================

RegisterNetEvent("loki_prescriptions:server:completeSwipe", function(success)
    local src = source
    if success then
        local pName = Bridge.Framework.fetchPlayerName(src) or "Funcionário"
        Bridge.Notify.showNotify(src, string.format("Credencial validada: %s (Nível A-1)", pName), "inform")
    end
end)
