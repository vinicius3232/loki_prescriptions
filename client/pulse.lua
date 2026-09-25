-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait until Config.Pulse is loaded
while not (Config and Config.Pulse) do
    Citizen.Wait(100)
end

-- Exit early if the pulse feature is disabled
if not Config.Pulse.enabled then
    return
end

Pulse = {
    value          = math.random(Config.Pulse.minPulse, Config.Pulse.minPulse + 30),
    antiSpam       = GetGameTimer(),
    critical       = false,
    canGetCritical = true,
}

-- Unused test function retained from decompilation (queries DMV school state)
local function test()
    local schools = GlobalState["p_dmvschool/Schools"]
    if schools then
        local entry = schools[k]
        if entry then
            return entry.theoryQuestions
        end
    end
end

AddEventHandler("CEventGunShot", function()
    -- Only react when the local ped is the one shooting
    if not IsPedShooting(cache.ped) then return end

    -- Throttle to once per second
    if Pulse.antiSpam > GetGameTimer() then return end

    Pulse.antiSpam = GetGameTimer() + 1000
    Pulse:add(math.random(1, 3))
end)

function Pulse:init()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)

            local injuries = Damages:getInjuriesAmount()

            if injuries < 1 then
                -- No injuries: slowly decay pulse toward minPulse
                self.value = math.max(
                    Config.Pulse.minPulse,
                    self.value - math.random(1, 5)
                )
                LocalPlayer.state:set("pulse", self.value, true)
            else
                -- Has injuries: check whether a critical pulse event should trigger
                local critCfg = Config.Pulse.critical
                if critCfg.enabled
                    and injuries >= critCfg.requiredInjuries
                    and not self.critical
                    and self.canGetCritical
                then
                    -- Roll against the configured chance
                    if math.random(1, 100) <= critCfg.chance then
                        Bridge.Notify.showNotify(locale("critical_pulse"), "inform")

                        -- Pick a random critical pulse value from the config table
                        self.value          = critCfg.pulse[math.random(1, 2)]
                        self.critical       = true
                        self.canGetCritical = false

                        LocalPlayer.state:set("pulse",         self.value, true)
                        LocalPlayer.state:set("criticalPulse", true,       true)
                    end
                end
            end
        end
    end)
end
Pulse.init = Pulse.init

function Pulse:reset(canGetCritical)
    if canGetCritical == nil then canGetCritical = true end

    self.value          = math.random(Config.Pulse.minPulse, Config.Pulse.minPulse + 30)
    self.critical       = false
    self.canGetCritical = canGetCritical

    LocalPlayer.state:set("pulse",         self.value, true)
    LocalPlayer.state:set("criticalPulse", false,      true)

    Bridge.Notify.showNotify(locale("pulse_stable"), "inform")
end
Pulse.reset = Pulse.reset

RegisterNetEvent("p_ambulancejob/client/pulse/reset")
AddEventHandler("p_ambulancejob/client/pulse/reset", function()
    -- Reset called from server passes false so the player can't immediately
    -- go critical again after being defibrillated
    Pulse:reset(false)
end)

function Pulse:add(amount)
    self.value = math.min(Config.Pulse.maxPulse, self.value + amount)
    LocalPlayer.state:set("pulse", self.value, true)
end
Pulse.add = Pulse.add

exports("resetPulse", function()
    Pulse:reset()
end)

exports("addPulse", function(amount)
    Pulse:add(amount)
end)

Citizen.CreateThread(function()
    Pulse:init()
end)