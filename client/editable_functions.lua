-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

Editable = {}
Editable.playerData = {}

function Editable:getAllJobs()
    self.allJobs = {}
    if Config.Hospitals then
        for k, v in pairs(Config.Hospitals) do
            if v.jobs then
                for _, jobName in pairs(v.jobs) do
                    self.allJobs[jobName] = 0
                end
            end
        end
    end
    if Config.PrescriptionJobs then
        for _, jobName in ipairs(Config.PrescriptionJobs) do
            self.allJobs[jobName] = 0
        end
    end
    self.allJobs['ambulance'] = 0
    self.allJobs['pharmacy'] = 0
end

function Editable:onGarageVehicleCreated(vehicle)
    -- you can implement your own logic here on spawned vehicle garage
end

function Editable:playClothesAnim()
    local animDict = lib.requestAnimDict('clothingtie')
    TaskPlayAnim(cache.ped, animDict, 'try_tie_negative_a', 2.0, 2.0, 2000, 49, 0, false, false, false)
    RemoveAnimDict(animDict)
    Citizen.Wait(1000)
end

function Editable:initRadial()
    if not Config.Radial or not Config.Radial.enabled then return end

    lib.registerRadial({
        id = 'ambulance_menu',
        items = Config.Radial.items
    })
    self.registeredRadial = true
end

function Editable:initRadio()
    if not Config.Radio or not Config.Radio.enabled then return end
    local playerJob = Bridge.Framework.fetchPlayerJob()
    if not self.allJobs[playerJob.name] then return end

    local options = {
        { label = locale('off_radio'), icon = 'xmark', onSelect = function() exports['pma-voice']:setRadioChannel(0) end }
    }
    for k, v in pairs(Config.Radio.channels) do
        if lib.table.contains(v.jobs, playerJob.name) then
            options[k + 1] = {
                label = v.label,
                icon = 'walkie-talkie',
                onSelect = function()
                    exports['pma-voice']:setRadioChannel(v.channel)
                end
            }
        end
    end

    lib.registerRadial({
        id = 'ambulance_radio_menu',
        items = options
    })
    lib.addRadialItem({
        {
            id = 'ambulance_radio',
            label = locale('radio'),
            icon = 'walkie-talkie',
            menu = 'ambulance_radio_menu',
        }
    })
end

RegisterNetEvent('p_bridge/client/setPlayerData', function(player)
    local time = GetGameTimer() + 3000
    while not Editable.allJobs do
        Citizen.Wait(100)
        if time < GetGameTimer() then return end
    end

    if not Config.Radial or not Config.Radial.enabled then return end
    local jobName = player and player.job and player.job.name
    if jobName and Editable.allJobs[jobName] then
        if not Editable.registeredRadial then
            Editable:initRadial()
        end

        lib.addRadialItem({
            {
                id = 'ambulance_job_menu',
                label = locale('job_menu'),
                icon = 'fa-solid fa-briefcase-medical',
                menu = 'ambulance_menu',
            }
        })

        Editable:initRadio()
    else
        lib.removeRadialItem('ambulance_job_menu')
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local job = Bridge.Framework.fetchPlayerJob()
    TriggerEvent('p_bridge/client/setPlayerData', { job = job })
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    TriggerEvent('p_bridge/client/setPlayerData', { job = job })
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    Editable:getAllJobs()
    local job = Bridge.Framework.fetchPlayerJob()
    TriggerEvent('p_bridge/client/setPlayerData', { job = job })
end)