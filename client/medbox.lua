--[[
    ============================================================================
    LOKI PRESCRIPTIONS - PORTABLE MEDICAL FIELD BOX / STASH (CLIENT)
    Absorbed from ak47_qb_ambulancejob and upgraded for QBox & ox_target
    ============================================================================
]]

local spawnedBoxes = {}

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

RegisterCommand('medbox', function()
    local job = Bridge.Framework.fetchPlayerJob()
    if not job or (job.name ~= 'ambulance' and job.name ~= 'doctor') then
        Bridge.Notify.showNotify('Acesso exclusivo ao corpo médico.', 'error')
        return
    end

    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local heading = GetEntityHeading(myPed)
    local forwardCoords = GetOffsetFromEntityInWorldCoords(myPed, 0.0, 0.85, -0.90)

    if lib and lib.progressBar then
        local success = lib.progressBar({
            duration = 3000,
            label = 'Posicionando caixa de suprimentos médicos...',
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer'
            }
        })
        if not success then return end
    end

    TriggerServerEvent('loki_prescriptions:server:deployMedBox', forwardCoords, heading)
end, false)

RegisterNetEvent('loki_prescriptions:client:syncSpawnMedBox', function(boxId, coords, heading)
    if spawnedBoxes[boxId] and DoesEntityExist(spawnedBoxes[boxId]) then
        DeleteEntity(spawnedBoxes[boxId])
    end

    local modelHash = loadModel('prop_medbox')
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(obj, heading or 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(modelHash)

    spawnedBoxes[boxId] = obj

    -- Registra interação ox_target
    if exports.ox_target and exports.ox_target.addLocalEntity then
        exports.ox_target:addLocalEntity(obj, {
            {
                name = 'loki_medbox_open_' .. boxId,
                icon = 'fas fa-box-open',
                label = 'Abrir Caixa de Suprimentos',
                distance = 2.0,
                onSelect = function()
                    if exports.ox_inventory then
                        exports.ox_inventory:openInventory('stash', boxId)
                    end
                end
            },
            {
                name = 'loki_medbox_pickup_' .. boxId,
                icon = 'fas fa-box-archive',
                label = 'Recolher Caixa de Suprimentos',
                groups = { 'ambulance', 'doctor' },
                distance = 2.0,
                onSelect = function()
                    TriggerServerEvent('loki_prescriptions:server:removeMedBox', boxId)
                end
            }
        })
    end
end)

RegisterNetEvent('loki_prescriptions:client:syncRemoveMedBox', function(boxId)
    if spawnedBoxes[boxId] then
        if DoesEntityExist(spawnedBoxes[boxId]) then
            DeleteEntity(spawnedBoxes[boxId])
        end
        spawnedBoxes[boxId] = nil
    end
end)

AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    for _, obj in pairs(spawnedBoxes) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
end)
