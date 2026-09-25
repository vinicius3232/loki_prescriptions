--[[
    ============================================================================
    LOKI PRESCRIPTIONS - INTERACTIVE MINIGAMES CLIENT
    Absorbed from Pluto Framework & Re-architectured with Lation UI Design System
    Surgical Suturing | Vascular Hemostasis | Bullet Canal Extraction
    Blood Pressure Monitor | Trauma Dressing | Breathalyzer | Keycard Swipe
    ============================================================================
]]

local isMinigameActive = false
local currentActiveMinigame = nil
local pendingSwipeCallback = nil

-- Helper to safely stop ped animations and release NUI
local function EndActiveMinigame()
    isMinigameActive = false
    currentActiveMinigame = nil
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
end

-- ============================================================================
-- 1. SUTURA CIRÚRGICA (SURGICAL SUTURE MINIGAME)
-- ============================================================================

local function StartSuture(targetServerId, part)
    if isMinigameActive then return end
    isMinigameActive = true
    currentActiveMinigame = "suture"

    local myPed = PlayerPedId()
    TaskStartScenarioInPlace(myPed, "CODE_HUMAN_MEDIC_TEND_TO_KNOT", 0, true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "loki:startSuture",
        targetSrc = targetServerId or GetPlayerServerId(PlayerId()),
        part = part or "torso"
    })
end

RegisterNetEvent("loki_prescriptions:client:startSutureMinigame", StartSuture)
RegisterNetEvent("amb_client:startSutureMinigame", StartSuture)

RegisterNUICallback("sutureMinigameResult", function(data, cb)
    EndActiveMinigame()
    local success = data and data.success
    local sid = tonumber(data and data.targetSrc)
    local part = data and data.part or "torso"

    if success and sid then
        TriggerServerEvent("loki_prescriptions:server:completeSuture", sid, part)
        Bridge.Notify.showNotify("Sutura cirúrgica concluída com precisão anatômica.", "success")
    else
        Bridge.Notify.showNotify("Procedimento de sutura interrompido ou falhou.", "error")
    end
    cb("ok")
end)

-- ============================================================================
-- 2. HEMOSTASIA E ANASTOMOSE (VESSEL CLAMPING & MICROSUTURE)
-- ============================================================================

local function StartClamp(targetServerId, part)
    if isMinigameActive then return end
    isMinigameActive = true
    currentActiveMinigame = "clamp"

    local myPed = PlayerPedId()
    TaskStartScenarioInPlace(myPed, "CODE_HUMAN_MEDIC_TEND_TO_KNOT", 0, true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "loki:startClamp",
        targetSrc = targetServerId or GetPlayerServerId(PlayerId()),
        part = part or "torso"
    })
end

RegisterNetEvent("loki_prescriptions:client:startClampMinigame", StartClamp)
RegisterNetEvent("amb_client:startClampMinigame", StartClamp)

RegisterNUICallback("clampMinigameResult", function(data, cb)
    EndActiveMinigame()
    local success = data and data.success
    local sid = tonumber(data and data.targetSrc)
    local part = data and data.part or "torso"

    if success and sid then
        TriggerServerEvent("loki_prescriptions:server:completeClamp", sid, part)
        Bridge.Notify.showNotify("Hemorragia estancada e vasos anastomosados com sucesso.", "success")
    else
        Bridge.Notify.showNotify("Falha no controle hemostático dos vasos sanguíneos.", "error")
    end
    cb("ok")
end)

-- ============================================================================
-- 3. EXTRAÇÃO DE PROJÉTIL (ARTERIAL BULLET EXTRACTION)
-- ============================================================================

local function StartBullet(targetServerId, part)
    if isMinigameActive then return end
    isMinigameActive = true
    currentActiveMinigame = "bullet"

    local myPed = PlayerPedId()
    TaskStartScenarioInPlace(myPed, "CODE_HUMAN_MEDIC_TEND_TO_KNOT", 0, true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "loki:startBullet",
        targetSrc = targetServerId or GetPlayerServerId(PlayerId()),
        part = part or "torso"
    })
end

RegisterNetEvent("loki_prescriptions:client:startBulletMinigame", StartBullet)
RegisterNetEvent("amb_client:startBulletMinigame", StartBullet)

RegisterNUICallback("bulletMinigameResult", function(data, cb)
    EndActiveMinigame()
    local success = data and data.success
    local sid = tonumber(data and data.targetSrc)
    local part = data and data.part or "torso"

    if success and sid then
        TriggerServerEvent("loki_prescriptions:server:completeBulletExtraction", sid, part)
        Bridge.Notify.showNotify("Projétil extraído com sucesso do canal tecidual.", "success")
    else
        Bridge.Notify.showNotify("Extração balística cancelada ou interrompida.", "error")
    end
    cb("ok")
end)

-- ============================================================================
-- 4. AFERIÇÃO DE PRESSÃO (BLOOD PRESSURE MONITOR & CUFF)
-- ============================================================================

local function StartBP(targetServerId, part)
    if isMinigameActive then return end
    isMinigameActive = true
    currentActiveMinigame = "bp"

    local myPed = PlayerPedId()
    TaskStartScenarioInPlace(myPed, "CODE_HUMAN_MEDIC_TEND_TO_KNOT", 0, true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "loki:startBP",
        targetSrc = targetServerId or GetPlayerServerId(PlayerId()),
        part = part or "rightArm"
    })
end

RegisterNetEvent("loki_prescriptions:client:startBPMinigame", StartBP)
RegisterNetEvent("amb_client:startBPMinigame", StartBP)

RegisterNUICallback("bpMinigameResult", function(data, cb)
    EndActiveMinigame()
    local success = data and data.success
    local sid = tonumber(data and data.targetSrc)
    local part = data and data.part or "rightArm"
    local vitals = data and data.vitals

    if success and sid then
        TriggerServerEvent("loki_prescriptions:server:completeBPCheck", sid, part, vitals)
        if vitals then
            Bridge.Notify.showNotify(string.format("Sinais Vitais: %s/%s mmHg • Pulso: %s", vitals.sys, vitals.dia, vitals.pulse), "inform")
        else
            Bridge.Notify.showNotify("Pressão arterial aferida com sucesso.", "success")
        end
    end
    cb("ok")
end)

-- ============================================================================
-- 5. CURATIVO DE TRAUMA (TRAUMA DRESSING PROCEDURE)
-- ============================================================================

local function StartBandage(targetServerId, part)
    if isMinigameActive then return end
    isMinigameActive = true
    currentActiveMinigame = "bandage"

    local myPed = PlayerPedId()
    TaskStartScenarioInPlace(myPed, "CODE_HUMAN_MEDIC_TEND_TO_KNOT", 0, true)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "loki:startBandage",
        targetSrc = targetServerId or GetPlayerServerId(PlayerId()),
        part = part or "torso"
    })
end

RegisterNetEvent("loki_prescriptions:client:startBandageMinigame", StartBandage)
RegisterNetEvent("amb_client:startBandageMinigame", StartBandage)

RegisterNUICallback("bandageMinigameResult", function(data, cb)
    EndActiveMinigame()
    local success = data and data.success
    local sid = tonumber(data and data.targetSrc)
    local part = data and data.part or "torso"

    if success and sid then
        TriggerServerEvent("loki_prescriptions:server:completeBandage", sid, part)
        Bridge.Notify.showNotify("Curativo de trauma estéril concluído e fixado.", "success")
    else
        Bridge.Notify.showNotify("Aplicação de curativo interrompida.", "error")
    end
    cb("ok")
end)

-- ============================================================================
-- 6. ETILÔMETRO / BAFÔMETRO DIGITAL (BREATHALYZER)
-- ============================================================================

--- Inicia o teste de bafômetro
RegisterNetEvent("loki_prescriptions:client:startBreathTest", function(officerId, isPlayer)
    SetNuiFocus(isPlayer, isPlayer)
    SendNUIMessage({
        action    = "loki:openBreathalyzer",
        officerId = officerId,
        isPlayer  = isPlayer,
    })

    if isPlayer then
        local ped = PlayerPedId()
        local animDict = "mp_player_int_upperfinger"
        lib.requestAnimDict(animDict)
        TaskPlayAnim(ped, animDict, "mp_player_int_upperfinger", 8.0, -8.0, -1, 49, 0, false, false, false)
    end
end)

RegisterNetEvent("plt_departments:client:startBreathTest", function(officerId, isPlayer)
    TriggerEvent("loki_prescriptions:client:startBreathTest", officerId, isPlayer)
end)

RegisterNetEvent("loki_prescriptions:client:updateBreathProgress", function(progress, indicatorPos)
    SendNUIMessage({
        action       = "syncBreathProgress",
        progress     = progress,
        indicatorPos = indicatorPos,
    })
end)

RegisterNetEvent("plt_departments:client:updateBreathProgress", function(progress, indicatorPos)
    TriggerEvent("loki_prescriptions:client:updateBreathProgress", progress, indicatorPos)
end)

RegisterNetEvent("loki_prescriptions:client:breathTestResult", function(result, targetName)
    SendNUIMessage({
        action     = "showBreathResult",
        result     = result,
        targetName = targetName,
    })
end)

RegisterNetEvent("plt_departments:client:breathTestResult", function(result, targetName)
    TriggerEvent("loki_prescriptions:client:breathTestResult", result, targetName)
end)

RegisterNUICallback("syncBreathProgress", function(data, cb)
    TriggerServerEvent("loki_prescriptions:server:syncBreathProgress", data.officerId, data.progress, data.indicatorPos)
    cb("ok")
end)

RegisterNUICallback("breathalyzerComplete", function(data, cb)
    SetNuiFocus(false, false)
    local officerId = data and data.officerId
    local success   = data and data.success
    ClearPedTasks(PlayerPedId())

    TriggerServerEvent("loki_prescriptions:server:breathalyzerComplete", officerId, success)
    cb("ok")
end)

RegisterNUICallback("closeBreathalyzer", function(data, cb)
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    cb("ok")
end)

-- ============================================================================
-- 7. PASSAGEM DE CARTÃO MAGNÉTICO (KEYCARD SWIPE)
-- ============================================================================

local function StartSwipeCard(cb)
    pendingSwipeCallback = cb
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "loki:startSwipe"
    })
end

RegisterNetEvent("loki_prescriptions:client:startSwipeMinigame", function()
    StartSwipeCard(nil)
end)

RegisterNetEvent("plt_departments:client:startSwipeMinigame", function()
    StartSwipeCard(nil)
end)

RegisterNUICallback("swipeSuccess", function(data, cb)
    SetNuiFocus(false, false)
    Bridge.Notify.showNotify("Acesso autorizado pelo leitor de cartão magnético.", "success")
    if pendingSwipeCallback then
        pendingSwipeCallback(true)
        pendingSwipeCallback = nil
    end
    TriggerServerEvent("loki_prescriptions:server:completeSwipe", true)
    cb("ok")
end)

RegisterNUICallback("closeSwipe", function(data, cb)
    SetNuiFocus(false, false)
    if pendingSwipeCallback then
        pendingSwipeCallback(false)
        pendingSwipeCallback = nil
    end
    cb("ok")
end)

-- ============================================================================
-- EXPORTS PÚBLICOS
-- ============================================================================

exports("StartSutureMinigame", StartSuture)
exports("StartClampMinigame", StartClamp)
exports("StartBulletMinigame", StartBullet)
exports("StartBPMinigame", StartBP)
exports("StartBandageMinigame", StartBandage)
exports("StartBreathalyzerTest", function(targetServerId)
    local closestPlayer, dist = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
    local tid = targetServerId or (closestPlayer and GetPlayerServerId(closestPlayer))
    if tid and tid > 0 then
        TriggerServerEvent("loki_prescriptions:server:requestBreathTest", tid)
    else
        Bridge.Notify.showNotify("Nenhum paciente ou condutor próximo para testar.", "error")
    end
end)
exports("StartSwipeCardMinigame", StartSwipeCard)

-- ============================================================================
-- COMANDOS DE TESTE E ATALHOS CLÍNICOS
-- ============================================================================

RegisterCommand("sutureminigame", function(_, args)
    local part = args[1] or "torso"
    local sid = tonumber(args[2]) or GetPlayerServerId(PlayerId())
    StartSuture(sid, part)
end, false)

RegisterCommand("clampminigame", function(_, args)
    local part = args[1] or "torso"
    local sid = tonumber(args[2]) or GetPlayerServerId(PlayerId())
    StartClamp(sid, part)
end, false)

RegisterCommand("bulletminigame", function(_, args)
    local part = args[1] or "torso"
    local sid = tonumber(args[2]) or GetPlayerServerId(PlayerId())
    StartBullet(sid, part)
end, false)

RegisterCommand("bpminigame", function(_, args)
    local part = args[1] or "rightArm"
    local sid = tonumber(args[2]) or GetPlayerServerId(PlayerId())
    StartBP(sid, part)
end, false)

RegisterCommand("bandageminigame", function(_, args)
    local part = args[1] or "torso"
    local sid = tonumber(args[2]) or GetPlayerServerId(PlayerId())
    StartBandage(sid, part)
end, false)

RegisterCommand("bafometro", function(_, args)
    local target = tonumber(args[1])
    if not target then
        local closestPlayer, dist = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.5, false)
        if closestPlayer then target = GetPlayerServerId(closestPlayer) end
    end
    if target and target > 0 then
        TriggerServerEvent("loki_prescriptions:server:requestBreathTest", target)
    else
        Bridge.Notify.showNotify("Nenhum indivíduo próximo para realizar o teste de etilômetro.", "error")
    end
end, false)

RegisterCommand("swipeminigame", function()
    StartSwipeCard(function(ok)
        if ok then
            Bridge.Notify.showNotify("Portão/Armário hospitalar destravado!", "success")
        end
    end)
end, false)
