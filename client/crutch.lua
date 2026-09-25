-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait until Config.Crutch is ready
while not (Config and Config.Crutch) do
    Wait(1)
end

-- Early exit if the crutch system is disabled
if not Config.Crutch.enabled then
    return
end


Crutch = {}
Crutch.__index    = Crutch
Crutch.isEnabled  = false   -- true while this player is on a crutch
Crutch.currentObject = nil  -- handle to the spawned crutch prop
Crutch.clipSet    = nil     -- original movement clipset (saved on enable)


local CRUTCH_MODEL  = "prop_mads_crutch01"
local CRUTCH_BONE   = 70       -- right hand bone index
local CRUTCH_OFFSET = { x = 1.18,  y = -0.36, z = -0.2  }
local CRUTCH_ROT    = { x = -20.0, y = -87.0, z = -20.0 }

local function spawnCrutchProp()
    local modelHash = lib.requestModel(CRUTCH_MODEL)
    local coords    = GetEntityCoords(cache.ped)
    local prop      = CreateObject(modelHash, coords, true, true, false)

    AttachEntityToEntity(
        prop, cache.ped,
        CRUTCH_BONE,
        CRUTCH_OFFSET.x, CRUTCH_OFFSET.y, CRUTCH_OFFSET.z,
        CRUTCH_ROT.x,    CRUTCH_ROT.y,    CRUTCH_ROT.z,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(modelHash)
    return prop
end


function Crutch:enable()
    if self.isEnabled then
        return
    end

    self.isEnabled = true

    -- Save current movement clipset so we can restore it later
    self.clipSet = GetPedMovementClipset(cache.ped)

    -- Apply limp / crutch walk animation
    lib.requestAnimSet("move_heist_lester")
    SetPedMovementClipset(cache.ped, "move_heist_lester", 100)
    RemoveClipSet("move_heist_lester")

    -- Spawn the crutch prop
    self.currentObject = spawnCrutchProp()

    -- Thread 1: Disable configured controls every frame while active
    Citizen.CreateThread(function()
        while self.isEnabled do
            for _, control in pairs(Config.Crutch.disabledControls) do
                DisableControlAction(0, control, true)
            end
            Citizen.Wait(1)
        end
    end)

    -- Thread 2: Watchdog — re-spawn the prop every second if it disappears
    Citizen.CreateThread(function()
        while self.isEnabled do
            Citizen.Wait(1000)

            if self.isEnabled and not DoesEntityExist(self.currentObject) then
                self.currentObject = spawnCrutchProp()
            end
        end
    end)
end


function Crutch:disable()
    if not self.isEnabled then
        return
    end

    self.isEnabled = false

    -- Delete the prop
    if self.currentObject then
        DeleteEntity(self.currentObject)
        self.currentObject = nil
    end

    -- Restore normal movement
    ResetPedMovementClipset(cache.ped, 1.0)
end


function Crutch:give()
    -- Job check
    local job = Bridge.Framework.fetchPlayerJob()
    if not (job and Config.Crutch.allowedJobs[job.name]) then
        Bridge.Notify.showNotify(locale("no_access"), "error")
        return
    end

    -- Collect nearby players (within 5 m), excluding self
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 5.0, true)
    local menuOptions   = {}

    for _, player in pairs(nearbyPlayers) do
        local serverId = GetPlayerServerId(player.id)
        if serverId ~= cache.serverId then
            menuOptions[#menuOptions + 1] = {
                label = locale("player", serverId),
                args  = { id = player.id },
            }
        end
    end

    if #menuOptions < 1 then
        Bridge.Notify.showNotify(locale("no_players"), "error")
        return
    end

    -- Track which ped is currently highlighted in the menu
    local highlightedPed = nil

    -- Marker draw thread: draws a white cylinder above the selected player while the menu is open
    Citizen.CreateThread(function()
        while lib.getOpenMenu() == "crutch_menu_players" do
            Citizen.Wait(1)

            if highlightedPed then
                local pos = GetEntityCoords(highlightedPed)
                DrawMarker(
                    25,                          -- type: cylinder
                    pos.x, pos.y, pos.z - 0.925, -- position (slightly below feet)
                    0.0, 0.0, 0.0,               -- direction
                    0.0, 0.0, 0.0,               -- rotation
                    0.75, 0.75, 0.75,            -- scale
                    255, 255, 255, 125,           -- RGBA
                    false, false, false, true     -- options
                )
            end
        end
    end)

    -- Register and show the player selection menu
    lib.registerMenu(
        {
            id      = "crutch_menu_players",
            title   = locale("crutch_menu_players"),
            options = menuOptions,

            -- onSelected: highlight the hovered player
            onSelected = function(_, _, args)
                highlightedPed = GetPlayerPed(args.id)
            end,
        },
        -- onConfirm: prompt for duration and fire server event
        function(_, _, args)
            local input = lib.inputDialog(locale("crutch_time_menu"), {
                {
                    type     = "number",
                    label    = locale("crutch_time_label"),
                    required = true,
                    icon     = "clock",
                    min      = 1,
                },
            })

            if not input then
                return
            end

            TriggerServerEvent("p_ambulancejob/server/crutch/forceCrutch", {
                targetId = GetPlayerServerId(args.id),
                time     = input[1],
            })
        end
    )

    lib.showMenu("crutch_menu_players")
end


function Crutch:menu()
    lib.registerMenu(
        {
            id      = "crutch_menu",
            title   = locale("crutch_menu"),
            options = {
                { label = locale("use_crutch"),    args = "enable"  },
                { label = locale("remove_crutch"), args = "disable" },
                { label = locale("give_crutch"),   args = "give"    },
            },
        },
        function(_, _, action)
            if action == "enable" then
                Crutch:enable()
            elseif action == "disable" then
                Crutch:disable()
            elseif action == "give" then
                Crutch:give()
            end
        end
    )

    lib.showMenu("crutch_menu")
end


--- Returns true if this player currently has a crutch active.
exports("isCrutchEnabled", function()
    return Crutch.isEnabled
end)

--- Force-assign a crutch to the local player from an external resource.
--- @param duration number  optional crutch duration (forwarded to server)
exports("assignCrutch", function(duration)
    if Crutch.isEnabled then
        return
    end
    TriggerServerEvent("p_ambulancejob/server/crutch/forceSelfCrutch", duration)
end)


-- Server: force this client onto a crutch (e.g. assigned by a medic)
RegisterNetEvent("p_ambulancejob/crutch/client/forceCrutch")
AddEventHandler("p_ambulancejob/crutch/client/forceCrutch", function()
    Crutch:enable()
end)

-- Server: remove the crutch from this client
RegisterNetEvent("p_ambulancejob/crutch/client/removeCrutch")
AddEventHandler("p_ambulancejob/crutch/client/removeCrutch", function()
    Crutch:disable()
end)

-- Server: open the crutch management menu on this client
RegisterNetEvent("p_ambulancejob/client/crutch/menu")
AddEventHandler("p_ambulancejob/client/crutch/menu", function()
    Crutch:menu()
end)


Citizen.CreateThread(function()
    Citizen.Wait(1000)

    Bridge.Target.addPlayer({
        {
            name     = "p_ambulancejob/crutch/remove",
            label    = locale("remove_crutch"),
            icon     = "fa-solid fa-person-walking-with-cane",
            distance = 2,
            groups   = Config.Crutch.allowedJobs,

            onSelect = function(targetData)
                -- Resolve entity to a server ID
                local entity   = (type(targetData) == "number" and targetData) or targetData.entity
                local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                TriggerServerEvent("p_ambulancejob/server/crutch/remove", serverId)
            end,

            canInteract = function(targetData)
                -- Only show if the target player currently has a crutch active
                local entity   = (type(targetData) == "number" and targetData) or targetData.entity
                local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                local crutchPlayers = GlobalState["p_ambulancejob/crutchPlayers"]
                return crutchPlayers and crutchPlayers[serverId] or false
            end,
        }
    })
end)