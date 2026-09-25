-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait until Config.Wheelchair is available before proceeding
while not (Config and Config.Wheelchair) do
    Wait(1)
end

-- Exit early if the wheelchair feature is disabled
if not Config.Wheelchair.enabled then
    return
end

Wheelchair = {}
Wheelchair.isEnabled = false

-- When the player enters a wheelchair vehicle, force engine on and unlock doors
lib.onCache("vehicle", function(vehicle)
    if vehicle and vehicle ~= 0 then
        local model = GetEntityModel(vehicle)
        if model == -1963629913 then
            SetVehicleEngineOn(vehicle, true, true, false)
            SetVehicleDoorsLocked(vehicle, 1)
        end
    end
end)

-- Opens a player-picker menu to select who receives a forced wheelchair,
-- then prompts for a duration and fires the server event
function Wheelchair.give(self)
    local job = Bridge.Framework.fetchPlayerJob()

    -- Check if the player has an authorised job
    if not (job and Editable.allJobs[job.name]) then
        Bridge.Notify.showNotify(locale("no_access"), "error")
        return
    end

    -- Gather nearby players (excluding self) within 5 units
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 5.0, true)
    local options = {}
    for _, playerData in pairs(nearbyPlayers) do
        local serverId = GetPlayerServerId(playerData.id)
        if serverId ~= cache.serverId then
            options[#options + 1] = {
                label = locale("player", serverId),
                args  = { id = playerData.id },
            }
        end
    end

    if #options < 1 then
        Bridge.Notify.showNotify(locale("no_players"), "error")
        return
    end

    -- Track the currently highlighted player's ped for the marker thread
    local highlightedPed = nil

    -- Draw a marker above the selected player while the menu is open
    Citizen.CreateThread(function()
        while lib.getOpenMenu() == "wheelchair_menu_players" do
            Citizen.Wait(1)
            if highlightedPed then
                local coords = GetEntityCoords(highlightedPed)
                DrawMarker(
                    25,
                    coords.x, coords.y, coords.z - 0.925,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.75, 0.75, 0.75,
                    255, 255, 255, 125,
                    false, false, false, true
                )
            end
        end
    end)

    lib.registerMenu({
        id      = "wheelchair_menu_players",
        title   = locale("wheelchair_menu_players"),
        options = options,

        -- Highlight the hovered player's ped
        onSelected = function(_, _, args)
            highlightedPed = GetPlayerPed(args.id)
        end,
    }, function(_, _, args)
        -- On confirm: ask for duration then fire server event
        local input = lib.inputDialog(locale("wheelchair_time_menu"), {
            {
                type     = "number",
                label    = locale("wheelchair_time_label"),
                required = true,
                icon     = "clock",
                min      = 1,
            },
        })
        if not input then return end

        TriggerServerEvent("p_ambulancejob/server/wheelchair/forceWheelchair", {
            targetId = GetPlayerServerId(args.id),
            time     = input[1],
        })
    end)

    lib.showMenu("wheelchair_menu_players")
end

-- Opens the main wheelchair action menu (enable / disable / give)
function Wheelchair.menu(self)
    lib.registerMenu({
        id      = "wheelchair_menu",
        title   = locale("wheelchair_menu"),
        options = {
            { label = locale("use_wheelchair"),    args = "enable"  },
            { label = locale("remove_wheelchair"), args = "disable" },
            { label = locale("give_wheelchair"),   args = "give"    },
        },
    }, function(_, _, args)
        if args == "enable" then
            Wheelchair:enable()
        elseif args == "disable" then
            Wheelchair:disable()
        elseif args == "give" then
            Wheelchair:give()
        end
    end)

    lib.showMenu("wheelchair_menu")
end

-- Net event: open the wheelchair menu remotely
RegisterNetEvent("p_ambulancejob/client/wheelchair/menu", function()
    Wheelchair:menu()
end)

-- Spawns the wheelchair vehicle and (optionally) warps the local ped into it
function Wheelchair.enable(self, warpIn)
    if self.isEnabled then return end
    self.isEnabled = true

    local model  = lib.requestModel("iak_wheelchair")
    local spawnCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.5, 0.1)

    -- Create the wheelchair in front of the player
    local vehicle = CreateVehicle(
        model,
        spawnCoords.x, spawnCoords.y, spawnCoords.z,
        GetEntityHeading(cache.ped),
        true, true
    )
    self.currentVehicle = vehicle

    -- Engine on, unlocked
    SetVehicleEngineOn(vehicle, true, true, false)

    -- Set fuel if bridge supports it
    if Bridge.Fuel then
        Bridge.Fuel.SetFuel(vehicle, 100.0)
    end

    -- Create keys if bridge supports it
    if Bridge.CarKeys then
        Bridge.CarKeys.CreateKeys(GetVehicleNumberPlateText(vehicle), vehicle)
    end

    SetVehicleDoorsLocked(vehicle, 1)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)

    if warpIn then
        -- Seat the local ped into the driver seat
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)

        -- Disable exit-vehicle control while wheelchair is active
        Citizen.CreateThread(function()
            while self.isEnabled do
                Citizen.Wait(1)
                DisableControlAction(0, 75, true)
            end
        end)
    end
end

-- Net event: force a wheelchair on the local client
-- warpIn = true so the player is seated and exit is disabled
RegisterNetEvent("p_ambulancejob/wheelchair/client/forceWheelchair", function()
    Wheelchair:enable(true)
end)

-- Removes the wheelchair vehicle and resets state
function Wheelchair.disable(self)
    if not self.isEnabled then return end
    self.isEnabled = false

    if self.currentVehicle then
        DeleteVehicle(self.currentVehicle)
        self.currentVehicle = nil
    end
end

-- Net event: remove wheelchair from the local client
RegisterNetEvent("p_ambulancejob/wheelchair/client/removeWheelchair", function()
    Wheelchair:disable()
end)

-- Net event: show a notification on the local client (triggered from server)
RegisterNetEvent("p_ambulancejob/client/notify", function(message, notifyType)
    Bridge.Notify.showNotify(message, notifyType)
end)