-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait until Config.MedicBag is available
while not (Config and Config.MedicBag) do
    Citizen.Wait(100)
end

if not Config.MedicBag.enabled then
    return
end

MedicBag = {}

function MedicBag.takeItem(_, player, itemName, amount, bagType)
    -- Validate the item exists in this bag type's config
    local bagItems = Config.MedicBag.items[bagType]
    if not bagItems or not bagItems[itemName] then
        return
    end

    local quantity = amount or 1
    Bridge.Inventory.addItem(player, itemName, quantity)

    -- Logging
    local webhook = Webhooks and Webhooks.medicbag or nil
    Bridge.Logs.Send(
        player,
        "Medic Bag Item Taken",
        string.format("Player has taken item %s from medic bag", itemName),
        webhook
    )
end

RegisterNetEvent("p_ambulancejob/server/medicbag/take")
AddEventHandler("p_ambulancejob/server/medicbag/take", function(itemName, netId, amount, bagType)
    local player = source

    -- Job check
    local job = Bridge.Framework.getPlayerJob(player)
    if not job or not Editable.allJobs[job.name] then
        Bridge.Notify.showNotify(player, locale("no_access"), "error")
        return
    end

    -- Validate the entity is a real, networked medic bag prop
    local obj = NetworkGetEntityFromNetworkId(netId)
    if not obj or not DoesEntityExist(obj) then
        return
    end

    if not Entity(obj).state.isMedicBag then
        return
    end

    MedicBag:takeItem(player, itemName, amount, bagType)
end)

RegisterNetEvent("p_ambulancejob/server/medicbag/remove")
AddEventHandler("p_ambulancejob/server/medicbag/remove", function(netId)
    local player = source

    -- Job check
    local job = Bridge.Framework.getPlayerJob(player)
    if not job or not Editable.allJobs[job.name] then
        Bridge.Notify.showNotify(player, locale("no_access"), "error")
        return
    end

    -- Validate the entity
    local obj = NetworkGetEntityFromNetworkId(netId)
    if not obj or not DoesEntityExist(obj) then
        return
    end

    local bagType = Entity(obj).state.isMedicBag
    if not bagType then
        return
    end

    -- Return the bag item to the player and delete the prop
    Bridge.Inventory.addItem(player, bagType, 1)
    DeleteEntity(obj)
end)