local ESX, QB, inv

if GetResourceState('es_extended') == 'started' then
    ESX = exports["es_extended"]:getSharedObject()
    ESX.RegisterUsableItem(Config.PrescriptionItem, function(src, item, properties)
        ShowPrescription(src, properties?.metadata or properties?.info or item?.info or item?.metadata)
    end)
    ESX.RegisterUsableItem(Config.PrescriptionPadItem, function(src)
        CreatePrescription(src)
    end)
elseif GetResourceState("qb-core") == "started" then -- should also work with qbx through the compatibility bridge
    QB = exports['qb-core']:GetCoreObject()
    QB.Functions.CreateUseableItem(Config.PrescriptionItem, function(src, item)
        ShowPrescription(src, item.info or item.metadata)
    end)
    QB.Functions.CreateUseableItem(Config.PrescriptionPadItem, function(src)
        CreatePrescription(src)
    end)
else
    -- custom framework
end

function SQL(query, params) -- only change this in case you use a different db wrapper (not recommended)
    return MySQL.query.await(query, params)
end

if GetResourceState('ox_inventory') == 'started' then
    inv = 'ox'
elseif GetResourceState('qs-inventory') == 'started' then
    inv = 'qs'
elseif GetResourceState('qb-inventory') == 'started' then
    inv = 'qb'
end


function GiveItem(src, item, count, metadata)
    if inv == 'ox' then
        exports.ox_inventory:AddItem(src, item, count, metadata)
    elseif inv == 'qs' then
        exports['qs-inventory']:AddItem(src, item, count, nil, metadata)
    elseif inv == 'qb' then
        exports['qb-inventory']:AddItem(src, item, count, false, metadata, 'loki_prescriptions', false)
    else
        -- custom inventory
        error("Custom inventory not yet configured")
    end
end


function RemoveItem(src, item, metadata)
    if inv == 'qs' then
        return exports['qs-inventory']:RemoveItem(src, item, 1, nil, metadata)
    elseif inv == 'ox' then
        return exports['ox_inventory']:RemoveItem(src, item, 1, metadata)
    elseif inv == 'qb' then
        return exports['qb-inventory']:RemoveItem(src, item, 1, false, "loki_prescriptions")
    else
        -- custom inventory
        error("Custom inventory not yet configured")
    end
end


function RemovePlayerMoney(src, amount)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        local money = xPlayer.getAccount('bank').money
        if money < amount then return false end
        xPlayer.removeAccountMoney('bank', amount)
        return true
    elseif QB then
        local xPlayer = QB.Functions.GetPlayer(src)
        if xPlayer.PlayerData.money.bank < amount then return false end
        xPlayer.Functions.RemoveMoney('bank', amount)
        return true
    else
        -- custom framework
        error("Custom framework not yet configured")
    end
end


function GetPlayerIdentifier(src)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getIdentifier()
    elseif QB then
        local xPlayer = QB.Functions.GetPlayer(src)
        return xPlayer.PlayerData.citizenid
    else
        -- custom framework
        return GetPlayerIdentifierByType(src, 'license')
    end
end


function GetPlayerJob(src)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.getJob().name
    elseif QB then
        local xPlayer = QB.Functions.GetPlayer(src)
        return xPlayer.PlayerData.job.name
    else
        -- custom framework
        error("Custom framework not yet configured")
    end
end


function HasItem(src, item)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer.hasItem(item)
    elseif QB then
        if inv == 'ox' then
            return exports.ox_inventory:Search(src, "count", item) ~= nil
        else
            local xPlayer = QB.Functions.GetPlayer(src)
            return xPlayer.Functions.HasItem(item, 1)
        end
    else
        -- custom framework
        error("Custom framework not yet configured")
    end
end


function GetItem(src, item)
    if inv == 'qb' then
        return exports['qb-inventory']:GetItemsByName(src, item)[1]
    elseif inv == 'qs' then
        local inventory = exports['qs-inventory']:GetInventory(src)
        for _, data in pairs(inventory) do
            if data.name == item then
                return data
            end
        end
    elseif inv == 'ox' then
        return exports['ox_inventory']:Search(src, 'slots', item)[1]
    else
        -- custom inventory
    end
end
