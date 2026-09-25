-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait for Config to be available
while true do
    if Config and Config.BodyBag then
        break
    end
    Wait(1)
end

-- Early exit if crutch system is disabled
if not Config.Crutch.enabled then
    return
end

-- Module table
local Crutch = {}
Crutch.players = {}

-- Expose players to GlobalState
GlobalState["p_ambulancejob/crutchPlayers"] = Crutch.players

function Crutch.init(self)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)

            for playerId, expiryTime in pairs(self.players) do
                local now = os.time()
                if expiryTime < now then
                    self.players[playerId] = nil

                    local ped = GetPlayerPed(playerId)
                    if ped and ped ~= 0 then
                        Bridge.Notify.showNotify(playerId, locale("crutch_removed"), "inform")
                        TriggerClientEvent("p_ambulancejob/crutch/client/removeCrutch", playerId)

                        local playerName = Bridge.Framework.getPlayerName(playerId)
                        local webhook = Webhooks and Webhooks.crutch or nil
                        Bridge.Logs.Send(
                            _source,
                            "Crutch Removed",
                            string.format("Player %s has had their crutch removed", playerName),
                            webhook
                        )
                    end
                end
            end

            GlobalState["p_ambulancejob/crutchPlayers"] = self.players
        end
    end)
end

function Crutch.newPlayer(self, sourcePlayer, targetId, durationMinutes)
    local expiryTime = os.time() + (durationMinutes * 60)
    self.players[targetId] = expiryTime
    GlobalState["p_ambulancejob/crutchPlayers"] = self.players

    local playerName = Bridge.Framework.getPlayerName(targetId)
    local webhook = Webhooks and Webhooks.crutch or nil
    Bridge.Logs.Send(
        sourcePlayer,
        "Crutch Added",
        string.format("Player %s has been given a crutch for %s minutes", playerName, durationMinutes),
        webhook
    )
end

-- Helper: Check if a player's job allows crutch actions
local function hasAllowedJob(sourcePlayer)
    local job = Bridge.Framework.getPlayerJob(sourcePlayer)
    if not job then return false end

    local allowedGrade = Config.Crutch.allowedJobs[job.name]
    if not allowedGrade then return false end

    return job.grade >= allowedGrade
end

-- Event: Force self crutch (player applies to themselves)
RegisterNetEvent("p_ambulancejob/server/crutch/forceSelfCrutch", function(durationMinutes)
    if type(durationMinutes) ~= "number" or durationMinutes < 1 then return end

    local sourcePlayer = source
    Crutch:newPlayer(sourcePlayer, sourcePlayer, durationMinutes)
    TriggerClientEvent("p_ambulancejob/crutch/client/forceCrutch", sourcePlayer)
end)

-- Event: Force crutch on another player (medic action)
RegisterNetEvent("p_ambulancejob/server/crutch/forceCrutch", function(data)
    if type(data) ~= "table" then return end
    if not data.targetId or not data.time then return end

    local sourcePlayer = source

    if not hasAllowedJob(sourcePlayer) then
        Bridge.Notify.showNotify(sourcePlayer, locale("not_allowed"), "error")
        return
    end

    Crutch:newPlayer(sourcePlayer, data.targetId, data.time)
    TriggerClientEvent("p_ambulancejob/crutch/client/forceCrutch", data.targetId)
end)

-- Event: Remove crutch from a player (medic action)
RegisterNetEvent("p_ambulancejob/server/crutch/remove", function(targetId)
    if type(targetId) ~= "number" or targetId < 1 then return end

    local sourcePlayer = source

    if not hasAllowedJob(sourcePlayer) then
        Bridge.Notify.showNotify(sourcePlayer, locale("not_allowed"), "error")
        return
    end

    -- Check proximity (must be within 7 units)
    local sourceCoords = GetEntityCoords(GetPlayerPed(sourcePlayer))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    if #(sourceCoords - targetCoords) > 7.0 then return end

    -- Check player actually has a crutch
    if not Crutch.players[targetId] then return end

    Crutch.players[targetId] = nil
    TriggerClientEvent("p_ambulancejob/crutch/client/removeCrutch", targetId)
    GlobalState["p_ambulancejob/crutchPlayers"] = Crutch.players

    local playerName = Bridge.Framework.getPlayerName(targetId)
    local webhook = Webhooks and Webhooks.crutch or nil
    Bridge.Logs.Send(
        sourcePlayer,
        "Crutch Removed",
        string.format("Player %s has had their crutch removed", playerName),
        webhook
    )
end)
Crutch:init()