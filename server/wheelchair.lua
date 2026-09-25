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
Wheelchair.players = {}

-- Starts a background thread that periodically checks for expired wheelchair timers
-- and removes the wheelchair from players whose time has run out
function Wheelchair.init(self)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)

            for playerId, expiryTime in pairs(self.players) do
                if expiryTime < os.time() then
                    -- Timer expired: clean up the player entry
                    self.players[playerId] = nil

                    local ped = GetPlayerPed(playerId)
                    if ped and ped ~= 0 then
                        -- Tell the client to remove the wheelchair vehicle
                        TriggerClientEvent("p_ambulancejob/wheelchair/client/removeWheelchair", playerId)

                        -- Notify the player their wheelchair has been removed (client-side)
                        TriggerClientEvent("p_ambulancejob/client/notify", playerId, locale("wheelchair_removed"), "inform")

                        -- Send a log entry
                        local playerName = Bridge.Framework.getPlayerName(playerId)
                        local webhook = Webhooks and Webhooks.wheelchair or nil
                        Bridge.Logs.Send(
                            playerId,
                            "Wheelchair Removed",
                            string.format("Player %s has had their wheelchair removed", playerName),
                            webhook
                        )
                    end
                end
            end
        end
    end)
end

-- Registers a player as having a wheelchair for `durationMinutes` minutes
function Wheelchair.newPlayer(self, playerId, durationMinutes)
    self.players[playerId] = os.time() + (durationMinutes * 60)
end

-- Start the expiry timer thread
Wheelchair:init()

-- Server event: force a wheelchair on a target player
-- Expects data = { targetId = <serverId>, time = <minutes> }
RegisterNetEvent("p_ambulancejob/server/wheelchair/forceWheelchair", function(data)
    -- Validate payload
    if not (type(data) == "table" and data.targetId and data.time) then
        return
    end

    local callerId = source
    local job = Bridge.Framework.getPlayerJob(callerId)
    if not job then return end

    -- Check if the caller's job is allowed to issue wheelchairs
    local requiredGrade = Config.Wheelchair.allowedJobs[job.name]
    if not requiredGrade or job.grade < requiredGrade then
        Bridge.Notify.showNotify(callerId, locale("not_allowed"), "error")
        return
    end

    -- Force the wheelchair on the target client
    TriggerClientEvent("p_ambulancejob/wheelchair/client/forceWheelchair", data.targetId)

    -- Register the timer so it gets cleaned up automatically
    Wheelchair:newPlayer(data.targetId, data.time)

    -- Send a log entry
    local targetName = Bridge.Framework.getPlayerName(data.targetId)
    local webhook = Webhooks and Webhooks.wheelchair or nil
    Bridge.Logs.Send(
        callerId,
        "Wheelchair Added",
        string.format("Player %s has been given a wheelchair for %s minutes", targetName, data.time),
        webhook
    )
end)