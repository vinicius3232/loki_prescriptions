local function versionChecker()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    if not currentVersion or currentVersion == "" then
        error("Unable to read resource version")
        return 
    end

    PerformHttpRequest('https://api.github.com/repos/LokiLeiche/loki_prescriptions/releases/latest', function(status, response, headers)
        if status ~= 200 or not response then return end

        local release = json.decode(response)
        if release and release.tag_name then
            local latestVersion = release.tag_name:gsub('^v', '')

            if latestVersion ~= currentVersion then
                print('^1You are using an old version of loki_prescriptions!^0')
                print('Your version: '..currentVersion..' | latest version: '..latestVersion)
                print('Please update the resource for the best experience. You can download the latest version from https://github.com/LokiLeiche/loki_prescriptions/releases/latest')
            elseif not Config.VersionCheckOmitLatest then
                print('^2You are using the latest version of loki_prescriptions!^0')
            end
        end
    end)
end

if Config.VersionCheck then
    Citizen.CreateThread(function()
        Wait(5000)
        versionChecker()
    end)
end


Config.Notification = string.lower(Config.Notification)
local function notify(type, msg, heading, src)
    if Config.Notification == 'custom' then
        CustomNotify(type, msg, heading, src)
    elseif Config.Notification == 'okoknotify' then
        TriggerClientEvent('okokNotify:Alert', src, heading, msg, 5000, type, true)
    elseif Config.Notification == 'esx' then
        TriggerClientEvent('esx:showNotification', src, msg, type, 5000)
    elseif Config.Notification == 'rip-notify' then
        TriggerClientEvent('RiP-Notify:Notify', src, type, 5000, heading, msg)
    elseif Config.Notification == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, msg, 'primary', 5000)
    elseif Config.Notification == 'wasabi_notify' then
        TriggerClientEvent('wasabi_notify:notify', src, heading, msg, 5000, type, true)
    elseif Config.Notification == 'mythic_notify' then
        if type == 'info' then
            type = 'inform'
        end
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = type, text = msg})
    elseif Config.Notification == 'sy_notify' then
        TriggerClientEvent('SY_Notify:Alert', src, heading, msg, 5000, type)
    elseif Config.Notification == "lib" then
        TriggerClientEvent('loki_prescriptions:oxNotify', src, heading, msg, type)
    else
        error('Unable to find notify system from config')
    end
end


local function hasInsurance(src)
    local rs = SQL("SELECT date FROM prescription_insurance WHERE identifier = ? LIMIT 1", {GetPlayerIdentifier(src)})
    if not rs[1] then
        return false
    else
        if not Config.Insurance.duration then return true end
        local time = os.time() * 1000
        if time - rs[1].date < Config.Insurance.duration * 1000 then return true else return false end
    end
end
exports('hasInsurance', hasInsurance)


RegisterServerEvent('loki_prescriptions:createPrescription', function(data)
    local src = source
    print('creating prescription!')
    print(json.encode(data))
    data.date = os.time()

    if Config.PrescriptionJobs then
        local playerjob = GetPlayerJob(src)
        local allowed = false
        for _, v in pairs(Config.PrescriptionJobs) do
            if v == playerjob then
                allowed = true
                break
            end
        end
        if not allowed then return end
    end
    print('job check')
    if not HasItem(src, Config.PrescriptionPadItem) then return end
    print('item')

    data.timestamp = os.time()
    GiveItem(src, Config.PrescriptionItem, 1, data)
end)


function ShowPrescription(src, properties)
    TriggerClientEvent('loki_prescriptions:viewPrescription', src, properties)
end


function CreatePrescription(src)
    if not HasItem(src, Config.PrescriptionPadItem) then return end

    if Config.PrescriptionJobs then
        local playerjob = GetPlayerJob(src)
        local allowed = false
        for _, v in pairs(Config.PrescriptionJobs) do
            if v == playerjob then
                allowed = true
                break
            end
        end
        if not allowed then
            notify("error", _U("invalidJob"), _U("pharmacy"), src)
            return
        end
    end

    TriggerClientEvent('loki_prescriptions:createPrescription', src)
end


RegisterServerEvent('loki_prescriptions:buyInsurance', function()
    local src = source
    if not src then return end
    local npcPos = vector3(Config.Insurance.npc.position.x, Config.Insurance.npc.position.y, Config.Insurance.npc.position.z)
    if #(npcPos - GetEntityCoords(GetPlayerPed(src))) > 10 then return end

    local ident = GetPlayerIdentifier(src)
    local rs = SQL("SELECT date FROM prescription_insurance WHERE identifier = ? LIMIT 1", {ident})
    if rs[1] then
        local time = os.time() * 1000
        if not Config.Insurance.duration or time - rs[1].date < Config.Insurance.duration * 1000 then
            notify('info', _U('insuranceStillValid'), _U('insurancy'), src)
            return
        end
    end

    if RemovePlayerMoney(src, Config.Insurance.price) then
        if rs[1] then
            SQL("UPDATE prescription_insurance SET date = CURRENT_TIMESTAMP() WHERE identifier = ? LIMIT 1", {ident})
        else
            SQL("INSERT INTO prescription_insurance (identifier) VALUES (?)", {ident})
        end
        notify('info', _U('insuranceBought'), _U('insurancy'), src)
    else
        notify('info', _U('insufficientFunds'), _U('insurancy'), src)
    end
end)


RegisterServerEvent('loki_prescriptions:redeemPrescription', function()
    local src = source

    local item = GetItem(src, Config.PrescriptionItem)
    if not item then
        notify('info', _U('noPrescription'), _U('pharmacy'), src)
        return
    end

    local metadata = item.metadata or item.info
    local prescribed = metadata.data.medications or {{
        label = metadata.data.medication,
        amount = metadata.data.amount
    }}
    local items = {}
    local price = 0
    for _, prescriptionMed in pairs(prescribed) do
        local med
        for _, v in pairs(Config.Medicine) do
            if v.label == prescriptionMed.label then
                med = v
                break
            end
        end
        local amount = tonumber(prescriptionMed.amount)
        if not med or not amount or amount < 1 then
            error('Unable to find valid medication in prescription')
        end
        table.insert(items, {med = med, amount = math.floor(amount)})
        price = price + med.cost * math.floor(amount)
    end
    if hasInsurance(src) then
        price = math.floor(price * Config.Insurance.reduction)
    end
    if price > 0 then
        if not RemovePlayerMoney(src, price) then
            notify('info', _U('insufficientFunds'), _U('pharmacy'), src)
            return
        end
    end
    RemoveItem(src, Config.PrescriptionItem, metadata)
    for _, item in pairs(items) do
        GiveItem(src, item.med.item, item.amount)
    end
    notify('info', _U('medsGiven'), _U('pharmacy'), src)
end)
