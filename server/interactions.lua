-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

Interactions = {}
Interactions.bloodCooldowns = {}

function Interactions.putInVehicle(_, targetPlayer, seat)
    TriggerClientEvent("p_ambulancejob/client/interactions/putInVehicle", targetPlayer, seat)
end

function Interactions.takeOutVehicle(_, targetPlayer, seat)
    TriggerClientEvent("p_ambulancejob/client/interactions/takeOutVehicle", targetPlayer, seat)
end

function Interactions.takeBlood(_, medicPlayer, targetPlayer, bloodAmount)
    if not Config.Interactions.playerBlood.enabled then
        return
    end

    -- Debug logging
    if Bridge and Bridge.Config and Bridge.Config.Debug then
        print("blood types enabled?", Config.BloodTypes and Config.BloodTypes.enabled)
        print("target blood type", targetPlayer, Player(targetPlayer).state.bloodType)
        print("giving item", string.format("blood_bag_%s", bloodAmount))
    end

    -- Build optional metadata if blood types are enabled
    local metadata = nil
    if Config.BloodTypes and Config.BloodTypes.enabled then
        metadata = { bloodType = Player(targetPlayer).state.bloodType }
    end

    -- Add the blood bag item to the medic's inventory
    Bridge.Inventory.addItem(medicPlayer, string.format("blood_bag_%s", bloodAmount), 1, metadata)

    -- Notify the target client that blood was taken
    TriggerClientEvent("p_ambulancejob/client/interactions/takeBlood", targetPlayer)

    -- Apply cooldown (double if full 500ml draw)
    local cooldownSeconds = Config.Interactions.playerBlood.cooldownPerPlayer * 60
    if bloodAmount == 500 and Config.Interactions.playerBlood.doubleCooldown then
        cooldownSeconds = cooldownSeconds * 2
    end
    Interactions.bloodCooldowns[targetPlayer] = os.time() + cooldownSeconds
end

function Interactions.carry(_, carrierPlayer, targetPlayer)
    local carrierState = Player(carrierPlayer).state

    -- If a confirm prompt is needed and the target declines, abort
    if not carrierState.isCarrying then
        if Config.Interactions.options.carryPlayer.needConfirm then
            local carrierName = Bridge.Framework.getPlayerName(carrierPlayer)
            local confirmed = lib.callback.await(
                "p_ambulancejob/server/interactions/canCarry",
                targetPlayer,
                carrierName,
                carrierPlayer
            )
            if not confirmed then
                return Bridge.Notify.showNotify(carrierPlayer, locale("carry_request_declined"), "error")
            end
        end
    end

    -- Toggle isCarrying on the carrier
    carrierState:set("isCarrying", not carrierState.isCarrying, true)

    -- Toggle isCarried on the target
    local targetState = Player(targetPlayer).state
    targetState:set("isCarried", not targetState.isCarried, true)

    -- Sync both clients
    TriggerClientEvent("p_ambulancejob/client/interactions/toggleCarry", carrierPlayer, {
        id        = targetPlayer,
        isCarrying = true,
    })
    TriggerClientEvent("p_ambulancejob/client/interactions/toggleCarry", targetPlayer, {
        id        = carrierPlayer,
        isCarrying = false,
    })
end

RegisterNetEvent("p_ambulancejob/server/interactions/takeBlood")
AddEventHandler("p_ambulancejob/server/interactions/takeBlood", function(targetPlayer, bloodAmount)
    -- Validate target player id
    if not targetPlayer or type(targetPlayer) ~= "number" or targetPlayer < 1 then
        return
    end

    local medicPlayer = source

    -- Distance check
    if not Utils:checkDistance(medicPlayer, targetPlayer) then
        return
    end

    -- Job check
    local job = Bridge.Framework.getPlayerJob(medicPlayer)
    if not job or not Editable.allJobs[job.name] then
        Bridge.Notify.showNotify(medicPlayer, locale("no_access"), "error")
        return
    end

    -- Cooldown check
    local cooldownExpiry = Interactions.bloodCooldowns[targetPlayer]
    if cooldownExpiry and cooldownExpiry > os.time() then
        Bridge.Notify.showNotify(medicPlayer, locale("you_cant_take_blood_again"), "error")
        return
    end

    -- Perform the action
    Interactions:takeBlood(medicPlayer, targetPlayer, bloodAmount)

    -- Logging
    local medicName = Bridge.Framework.getPlayerName(medicPlayer)
    local targetName = Bridge.Framework.getPlayerName(targetPlayer)
    local webhook = Webhooks and Webhooks.interactions or nil
    Bridge.Logs.Send(medicPlayer, "Blood Taken",
        string.format("Player %s has taken blood from %s", medicName, targetName),
        webhook)
end)

RegisterNetEvent("p_ambulancejob/server/interactions/putInPlayer")
AddEventHandler("p_ambulancejob/server/interactions/putInPlayer", function(data)
    local targetPlayer = data.player
    local seat         = data.seat

    if not targetPlayer or type(targetPlayer) ~= "number" or targetPlayer < 1 or not seat then
        return
    end

    local medicPlayer = source

    if not Utils:checkDistance(medicPlayer, targetPlayer) then
        return
    end

    local job = Bridge.Framework.getPlayerJob(medicPlayer)
    if not job or not Editable.allJobs[job.name] then
        Bridge.Notify.showNotify(medicPlayer, locale("no_access"), "error")
        return
    end

    Interactions:putInVehicle(targetPlayer, seat)

    local medicName  = Bridge.Framework.getPlayerName(medicPlayer)
    local targetName = Bridge.Framework.getPlayerName(targetPlayer)
    local webhook    = Webhooks and Webhooks.interactions or nil
    Bridge.Logs.Send(medicPlayer, "Player Put In Vehicle",
        string.format("Player %s has been put in vehicle seat %s", targetName, seat),
        webhook)
end)

RegisterNetEvent("p_ambulancejob/server/interactions/takeOutPlayer")
AddEventHandler("p_ambulancejob/server/interactions/takeOutPlayer", function(data)
    local targetPlayer = data.player
    local seat         = data.seat

    if not targetPlayer or type(targetPlayer) ~= "number" or targetPlayer < 1 or not seat then
        return
    end

    local medicPlayer = source

    if not Utils:checkDistance(medicPlayer, targetPlayer) then
        return
    end

    local job = Bridge.Framework.getPlayerJob(medicPlayer)
    if not job or not Editable.allJobs[job.name] then
        Bridge.Notify.showNotify(medicPlayer, locale("no_access"), "error")
        return
    end

    Interactions:takeOutVehicle(targetPlayer, seat)

    local medicName  = Bridge.Framework.getPlayerName(medicPlayer)
    local targetName = Bridge.Framework.getPlayerName(targetPlayer)
    local webhook    = Webhooks and Webhooks.interactions or nil
    Bridge.Logs.Send(medicPlayer, "Player Took Out Vehicle",
        string.format("Player %s has been taken out of vehicle seat %s", targetName, seat),
        webhook)
end)

RegisterNetEvent("p_ambulancejob/server/interactions/carryPlayer")
AddEventHandler("p_ambulancejob/server/interactions/carryPlayer", function(targetPlayer)
    if not targetPlayer or type(targetPlayer) ~= "number" or targetPlayer < 1 then
        return
    end

    local carrierPlayer = source

    if not Utils:checkDistance(carrierPlayer, targetPlayer) then
        return
    end

    Interactions:carry(carrierPlayer, targetPlayer)

    local carrierName = Bridge.Framework.getPlayerName(carrierPlayer)
    local targetName  = Bridge.Framework.getPlayerName(targetPlayer)
    local webhook     = Webhooks and Webhooks.interactions or nil
    Bridge.Logs.Send(carrierPlayer, "Player Carried",
        string.format("Player %s has started carrying %s", carrierName, targetName),
        webhook)
end)