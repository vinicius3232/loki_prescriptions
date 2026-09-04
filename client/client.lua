local Cache = {
    ped = PlayerPedId()
}

local nuiCb = RegisterNuiCallback
local RegisterNuiCallback = function(name, fn, keepCallback)
    nuiCb(name, function(data, cb)
        if keepCallback then
            fn(data, cb)
        else
            fn(data)
            cb()
        end
    end)
end

RegisterNetEvent('loki_prescriptions:oxNotify', function(heading, description, style)
    if style == "info" then
        style = "inform"
    end
    lib.notify({
        title = heading,
        description = description,
        type = style
    })
end)

local function loadModel(model)
    RequestModel(model)
    local i = 0
    while not HasModelLoaded(model) do
        i = i + 1
        if i > 500 then
            error('Failed to load model: '..model)
        end
        Wait(0)
    end
end

local function loadAnim(dict)
    RequestAnimDict(dict)
    local i = 0
    while not HasAnimDictLoaded(dict) do
        i = i + 1
        if i > 500 then
            error('Failed to load anim dict: '..dict)
        end
        Wait(0)
    end
end

local function openPrescription(data)
    Cache.nuiFocused = not Cache.nuiFocused
    SetNuiFocus(Cache.nuiFocused, Cache.nuiFocused)
    if Cache.nuiFocused then
        if not data then
            SendNUIMessage({event = 'open_nui'})
        else
            SendNUIMessage({
                event = 'show_prescription',
                prescription = data.data,
                date = data.date,
            })
        end
        if Config.Anim and Config.Anim.enabled then
            RequestAnimDict(Config.Anim.dict)
            while not HasAnimDictLoaded(Config.Anim.dict) do
                Wait(0)
            end
            if Config.Anim.prop then
                RequestModel(Config.Anim.prop.model)
                while not HasModelLoaded(Config.Anim.prop.model) do
                    Wait(0)
                end
                local pCoords = GetEntityCoords(Cache.ped)
                Cache.prop = CreateObject(Config.Anim.prop.model, pCoords.x, pCoords.y, pCoords.z + 1, true, true, false)
                AttachEntityToEntity(Cache.prop, Cache.ped, GetPedBoneIndex(Cache.ped, 28422), Config.Anim.prop.offsets[1], Config.Anim.prop.offsets[2], Config.Anim.prop.offsets[3], Config.Anim.prop.rotations[1], Config.Anim.prop.rotations[2], Config.Anim.prop.rotations[3], false, false, false, false, 2, true)
                SetModelAsNoLongerNeeded(Config.Anim.prop.model)
            end
            TaskPlayAnim(Cache.ped, Config.Anim.dict, Config.Anim.anim, 8.0, 1.0, -1, 17, 1.0, false, false, false)
            RemoveAnimDict(Config.Anim.dict)
        end
    else
        SendNUIMessage({evebt = 'close_nui'})
        DeleteEntity(Cache.prop)
        ClearPedTasksImmediately(Cache.ped)
        ClearPedTasks(Cache.ped)
    end
end

RegisterNuiCallback('nuiClosed', function()
    Cache.nuiFocused = false
    SetNuiFocus(Cache.nuiFocused, Cache.nuiFocused)
    DeleteEntity(Cache.prop)
    ClearPedTasksImmediately(Cache.ped)
    ClearPedTasks(Cache.ped)
end)

RegisterNuiCallback('load_config', function()
    SendNUIMessage({
        event = "load_config",
        style = Config.NuiStyle,
        locale = Config.TimeFormat,
        medicine = Config.Medicine,
        label_submit = _U('nui_submit'),
        label_cancel = _U('nui_cancel')
    })
end)

RegisterNuiCallback('submit_prescription', function(data)
    TriggerServerEvent('loki_prescriptions:createPrescription', data)
end)

AddEventHandler('playerSpawned', function()
    Cache.ped = PlayerPedId()
end)

RegisterNetEvent('loki_prescriptions:viewPrescription', function(data)
    openPrescription(data)
end)

RegisterNetEvent('loki_prescriptions:createPrescription', function()
    openPrescription()
end)

local function createInsuranceNPC()
    loadModel(Config.Insurance.npc.model)
    Cache.InsuranceNPC = CreatePed(0, Config.Insurance.npc.model, Config.Insurance.npc.position.x, Config.Insurance.npc.position.y, Config.Insurance.npc.position.z, Config.Insurance.npc.position.w, false, true)
    SetModelAsNoLongerNeeded(Config.Insurance.npc.model)
    loadAnim(Config.Insurance.npc.anim.dict)
    TaskPlayAnim(Cache.InsuranceNPC, Config.Insurance.npc.anim.dict, Config.Insurance.npc.anim.anim, 8.0, 1.0, -1, Config.Insurance.npc.anim.flags, 1.0, false, false, false)
    FreezeEntityPosition(Cache.InsuranceNPC, true)
    SetEntityInvincible(Cache.InsuranceNPC, true)
    SetBlockingOfNonTemporaryEvents(Cache.InsuranceNPC, true)

    if Config.Insurance.blip then
        Cache.InsuranceBlip = AddBlipForCoord(Config.Insurance.npc.position.x, Config.Insurance.npc.position.y, Config.Insurance.npc.position.z)
        SetBlipAsShortRange(Cache.InsuranceBlip, Config.Insurance.blip.shortRange)
        SetBlipSprite(Cache.InsuranceBlip, Config.Insurance.blip.sprite)
        SetBlipColour(Cache.InsuranceBlip, Config.Insurance.blip.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Insurance.blip.label)
        EndTextCommandSetBlipName(Cache.InsuranceBlip)
        SetBlipDisplay(Cache.InsuranceBlip, Config.Insurance.blip.display)
        SetBlipScale(Cache.InsuranceBlip, Config.Insurance.blip.scale)
    end

    if Config.Target then
        AddTarget(Cache.InsuranceNPC, _U("insuranceHelpText"), "fa-solid fa-sack-dollar", function()
            TriggerServerEvent('loki_prescriptions:buyInsurance')
        end)
    else
        AddTextEntry("loki_prescriptions_insurance", _U('insuranceHelpText'))
        CreateThread(function()
            local interval = 10000
            while true do
                local dist = #(GetEntityCoords(Cache.ped) - Config.Insurance.npc.position)
                if dist < 2 then
                    interval = 0
                    DisplayHelpTextThisFrame("loki_prescriptions_insurance", false)
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('loki_prescriptions:buyInsurance')
                        interval = 5000 -- cooldown
                    end
                elseif dist < 50 then
                    interval = 2000
                else
                    interval = 10000
                end
                Citizen.Wait(interval)
            end
        end)
    end
end

local function createPharmacies()
    Cache.PharmaciePeds = {}
    for k, v in pairs(Config.Pharmacies) do
        loadModel(v.pedModel)
        local ped = CreatePed(0, v.pedModel, v.position.x, v.position.y, v.position.z, v.position.w, false, true)
        SetModelAsNoLongerNeeded(v.pedModel)
        loadAnim(v.anim.dict)
        TaskPlayAnim(ped, v.anim.dict, v.anim.anim, 8.0, 1.0, -1, v.anim.flags, 1.0, false, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        Cache.PharmaciePeds[k] = ped

        if v.blip then
            local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
            SetBlipAsShortRange(blip, v.blip.shortRange)
            SetBlipSprite(blip, v.blip.sprite)
            SetBlipColour(blip, v.blip.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blip.label)
            EndTextCommandSetBlipName(blip)
            SetBlipDisplay(blip, v.blip.display)
            SetBlipScale(blip, v.blip.scale)
        end

        if Config.Target then
            AddTarget(ped, _U('redeemPrescription'), "fa-solid fa-capsules", function()
                TriggerServerEvent('loki_prescriptions:redeemPrescription')
            end)
        else
            AddTextEntry("loki_prescriptions_pharmacy", _U('redeemPrescription'))
            CreateThread(function()
                local interval = 10000
                while true do
                    local dist = #(GetEntityCoords(Cache.ped) - v.position)
                    if dist < 2 then
                        interval = 0
                        DisplayHelpTextThisFrame("loki_prescriptions_pharmacy", false)
                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent('loki_prescriptions:redeemPrescription')
                            interval = 5000 -- cooldown
                        end
                    elseif dist < 50 then
                        interval = 2000
                    else
                        interval = 10000
                    end
                    Citizen.Wait(interval)
                end
            end)
        end
    end
end

CreateThread(function()
    createInsuranceNPC()
    createPharmacies()
end)
