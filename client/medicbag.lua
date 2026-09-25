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

local function isMedicBagEntity(entity)
    if NetworkGetEntityIsNetworked(entity) then
        local netId = NetworkGetNetworkIdFromEntity(entity)
        if netId then
            return MedicBag.netId == netId
        end
    end
    return false
end

Citizen.CreateThread(function()
    Bridge.Target.addModel(Config.MedicBag.prop.model, {
        {
            name     = "p_ambulancejob/medicbag/open",
            label    = locale("open_medic_bag"),
            icon     = "fa-solid fa-bag-shopping",
            distance = 2,
            onSelect = function()
                MedicBag:open()
            end,
            canInteract = isMedicBagEntity,
        },
        {
            name     = "p_ambulancejob/medicbag/remove",
            label    = locale("remove_medic_bag"),
            icon     = "fa-solid fa-trash",
            distance = 2,
            onSelect = function()
                MedicBag:remove()
            end,
            canInteract = isMedicBagEntity,
        },
    })
end)

RegisterNetEvent("p_ambulancejob/client/medicbag/use")
AddEventHandler("p_ambulancejob/client/medicbag/use", function(bagData)
    MedicBag:use(bagData)
end)

function MedicBag.use(self, bagType)
    -- Job check
    local job = Bridge.Framework.fetchPlayerJob()
    if not job or not Editable.allJobs[job.name] then
        Bridge.Notify.showNotify(locale("no_access"), "error")
        return
    end

    -- Play put-down animation and block until finished (or cancelled)
    local completed = Bridge.Progress.Start({
        duration  = 1200,
        label     = locale("putting_down_medic_bag"),
        canCancel = true,
        anim      = Config.MedicBag.anims.putdown,
    })

    if not completed then
        return
    end

    -- Consume one bag from inventory
    TriggerServerEvent("p_bridge/server/removeItem", bagType, 1)

    -- Spawn the prop 0.75 units in front of the ped, on the ground
    local spawnCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.75, 0.0)
    local modelHash   = lib.requestModel(Config.MedicBag.prop.model)

    local obj = CreateObject(
        modelHash,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z - 0.95,
        true, true, true
    )

    SetEntityAsMissionEntity(obj, true, true)
    NetworkRequestControlOfEntity(obj)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(modelHash)

    -- Store state on MedicBag table
    self.netId       = Utils:getNetId(obj)
    self.object      = obj
    self.medicBagType = bagType

    -- Mark the entity state so other scripts can identify it
    Entity(obj).state:set("isMedicBag", bagType, true)

    ClearPedTasks(cache.ped)
end

function MedicBag.remove(self)
    if not self.object or not DoesEntityExist(self.object) then
        return
    end

    local completed = Bridge.Progress.Start({
        duration  = 1200,
        label     = locale("picking_up_medic_bag"),
        canCancel = true,
        anim      = Config.MedicBag.anims.pickup,
    })

    if not completed then
        return
    end

    TriggerServerEvent(
        "p_ambulancejob/server/medicbag/remove",
        NetworkGetNetworkIdFromEntity(self.object)
    )

    self.object = nil
    ClearPedTasks(cache.ped)
end

function MedicBag.open(self)
    if Bridge.Config and Bridge.Config.Debug then
        print(self.medicBagType)
    end

    -- Collect items configured for this bag type
    local bagItems = (Config.MedicBag.items[self.medicBagType]) or {}
    local options  = {}

    for itemName, _ in pairs(bagItems) do
        local itemData  = Bridge.Inventory.getItemData(itemName)
        local itemLabel = (itemData and itemData.label) or itemName
        local itemIcon  = (itemData and itemData.image) or "fa-solid fa-hand"

        options[#options + 1] = {
            title       = itemLabel,
            description = locale("take_item", itemLabel),
            icon        = itemIcon,
            onSelect    = function()
                -- Prompt for quantity (1–10)
                local input = lib.inputDialog(locale("take_item", itemLabel), {
                    {
                        type     = "number",
                        label    = locale("amount"),
                        default  = 1,
                        required = true,
                        min      = 1,
                        max      = 10,
                    },
                })

                if not input then
                    return
                end

                TriggerServerEvent(
                    "p_ambulancejob/server/medicbag/take",
                    itemName,
                    NetworkGetNetworkIdFromEntity(self.object),
                    input[1],
                    self.medicBagType
                )

                -- Refresh the context menu
                lib.showContext("p_ambulancejob/medicbag")
            end,
        }
    end

    lib.registerContext({
        id      = "p_ambulancejob/medicbag",
        title   = locale("medic_bag"),
        options = options,
    })

    lib.showContext("p_ambulancejob/medicbag")
end