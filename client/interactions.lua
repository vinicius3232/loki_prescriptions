-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait for Config.Interactions to be available
while true do
    if Config and Config.Interactions then
        break
    end
    Citizen.Wait(100)
end

-- Early exit if interactions system is disabled
if not Config.Interactions.enabled then
    return
end

Interactions = {}

-- Seat label lookup (index as string → locale string)
Interactions.seats = {
    ["-1"] = locale("driver_seat"),
    ["0"]  = locale("passenger_seat"),
    ["1"]  = locale("back_left_passenger"),
    ["2"]  = locale("back_right_passenger"),
}

Interactions.carryRole     = "none"
Interactions.activeCarry   = false
Interactions.carryPlayerId = nil

local function getSeatLabel(seatIndex)
    return Interactions.seats[tostring(seatIndex)] or locale("additional_seat")
end

local function buildSeatOptions(optionKey, optionData, targetList)
    for seatIndex = -1, 6 do
        table.insert(targetList, {
            name        = string.format("p_ambulancejob/interaction/%s/%d", optionKey, seatIndex),
            label       = string.format("%s (%s)", optionData.label, getSeatLabel(seatIndex)),
            icon        = optionData.icon,
            distance    = optionData.distance,
            groups      = optionData.jobs,
            onSelect    = function(entity) optionData.onSelect(entity, seatIndex) end,
            canInteract = function(entity) return optionData.canInteract(entity, seatIndex) end,
        })
    end
end

lib.callback.register("p_ambulancejob/server/interactions/canCarry", function(requesterName, requesterServerId)
    local result = lib.alertDialog({
        header   = locale("carry_player"),
        content  = locale("carry_player_request", requesterName, requesterServerId),
        centered = true,
        cancel   = true,
    })
    return result == "confirm"
end)

function Interactions.playCarry(self)
    local animData = Config.Interactions.options.carryPlayer.animData[self.carryRole]
    lib.requestAnimDict(animData.dict)
    TaskPlayAnim(cache.ped, animData.dict, animData.clip, 8.0, -8.0, -1, animData.flag, 0, false, false, false)
end

function Interactions.carry(self, carryData)
    -- If already carrying someone, stop
    if self.activeCarry then
        self.activeCarry = false
        ClearPedTasksImmediately(cache.ped)
        DetachEntity(cache.ped, true, false)
        return
    end

    -- Small delay: longer for bleeding players so animation syncs
    local isBleedingPlayer = Player(carryData.id).state.deathType == "bleeding"
    Citizen.Wait(isBleedingPlayer and 2000 or 100)

    self.activeCarry   = true
    self.carryPlayerId = carryData.id
    self.carryRole     = carryData.isCarrying and "carrying" or "carried"

    local animData = Config.Interactions.options.carryPlayer.animData[self.carryRole]

    if self.carryRole == "carried" then
        Citizen.Wait(500)
        ClearPedTasksImmediately(cache.ped)

        local carrierPed = GetPlayerPed(GetPlayerFromServerId(carryData.id))
        AttachEntityToEntity(
            cache.ped,
            carrierPed,
            0,
            animData.offset.coords,
            animData.offset.rotation,
            false, false, false, false,
            2, false
        )
        Citizen.Wait(10)
        self:playCarry()
    else
        self:playCarry()
    end

    -- Loop: keep animation going and watch if carrier leaves
    Citizen.CreateThread(function()
        while self.activeCarry do
            Citizen.Wait(250)

            if self.activeCarry then
                -- Re-play animation if it stopped
                local roleAnimData = Config.Interactions.options.carryPlayer.animData[self.carryRole]
                if roleAnimData and not IsEntityPlayingAnim(cache.ped, roleAnimData.dict, roleAnimData.clip, 3) then
                    self:playCarry()
                end

                -- Stop carry if the other player's ped has vanished
                local otherPed = GetPlayerPed(GetPlayerFromServerId(self.carryPlayerId))
                if not otherPed or otherPed == 0 or not DoesEntityExist(otherPed) or otherPed == cache.ped then
                    self:carry({
                        id         = self.carryPlayerId,
                        isCarrying = self.carryRole == "carrying",
                    })
                    break
                end
            end
        end
    end)

    -- Thread: show stop-carry UI and listen for the stop input (Cover key)
    Citizen.CreateThread(function()
        if self.carryRole == "carried" then return end

        lib.showTextUI(locale("stop_carry_textui"))

        while self.activeCarry do
            Citizen.Wait(1)
            if IsControlJustReleased(0, 73) then
                TriggerServerEvent("p_ambulancejob/server/interactions/carryPlayer", self.carryPlayerId)
                break
            end
        end

        lib.hideTextUI()
    end)
end

function Interactions.putInVehicle(self, seatIndex)
    -- Must not already be in a vehicle
    if cache.vehicle and cache.vehicle ~= 0 then return end

    local vehicle, _ = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)
    if not IsVehicleSeatFree(vehicle, seatIndex) then return end

    Death.inVehicle = true
    Citizen.Wait(10)
    ClearPedTasksImmediately(cache.ped)
    Citizen.Wait(1)

    if Death.deathType == "none" then
        TaskWarpPedIntoVehicle(cache.ped, vehicle, seatIndex)
    else
        SetPedIntoVehicle(cache.ped, vehicle, seatIndex)
    end
end

function Interactions.takeOutVehicle(self)
    if not cache.vehicle or cache.vehicle == 0 then return end

    Death.inVehicle = false
    Citizen.Wait(10)
    TaskLeaveVehicle(cache.ped, cache.vehicle, 16)
    Citizen.Wait(1000)
    ClearPedTasksImmediately(cache.ped)
end

function Interactions.takeBlood(self)
    if not Config.Interactions.playerBlood.enabled then return end

    local currentHealth = GetEntityHealth(cache.ped)
    local newHealth     = math.max(0, currentHealth - Config.Interactions.playerBlood.healthToRemove)
    SetEntityHealth(cache.ped, newHealth)
    Bridge.Notify.showNotify(locale("medic_taken_blood_from_you"), "success")
end


RegisterNetEvent("p_ambulancejob/client/interactions/takeBlood", function()
    Interactions:takeBlood()
end)

RegisterNetEvent("p_ambulancejob/client/interactions/putInVehicle", function(seatIndex)
    Interactions:putInVehicle(seatIndex)
end)

RegisterNetEvent("p_ambulancejob/client/interactions/takeOutVehicle", function()
    Interactions:takeOutVehicle()
end)

RegisterNetEvent("p_ambulancejob/client/interactions/toggleCarry", function(carryData)
    Interactions:carry(carryData)
end)

Citizen.CreateThread(function()
    Citizen.Wait(3000)

    local playerOptions  = {}
    local vehicleOptions = {}

    for optionKey, optionData in pairs(Config.Interactions.options) do
        if optionKey == "putPlayerInVehicle" then
            buildSeatOptions(optionKey, optionData, playerOptions)

        elseif optionKey == "takeOutPlayerVehicle" then
            buildSeatOptions(optionKey, optionData, vehicleOptions)

        else
            -- Generic single-target option (player or vehicle, per optionData.type)
            local targetList = optionKey == "vehicle" and vehicleOptions or playerOptions
            table.insert(targetList, {
                name        = "p_ambulancejob/interaction/" .. optionKey,
                label       = optionData.label,
                icon        = optionData.icon,
                distance    = optionData.distance,
                groups      = optionData.jobs,
                onSelect    = optionData.onSelect,
                canInteract = optionData.canInteract,
            })
        end
    end

    if #playerOptions  > 0 then Bridge.Target.addPlayer(playerOptions)  end
    if #vehicleOptions > 0 then Bridge.Target.addVehicle(vehicleOptions) end
end)