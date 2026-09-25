--[[
    LOKI MEDICAL SUITE - VP_TABLET INTEGRATION (CLIENT)
    Registro de aplicativo médico no VP Tablet para paramédicos e doutores.
]]

local function registerTabletApp()
    if GetResourceState('vp_tablet') ~= 'started' then return end

    pcall(function()
        exports['vp_tablet']:RegisterApp({
            identifier  = 'loki_medical',
            name        = 'LSMC Receituário',
            description = 'Portal clínico para prescrições digitais, laudos e atestados médicos.',
            icon        = 'https://cfx-nui-loki_prescriptions/web/assets/lifepak.png',
            defaultApp  = true,
            removable   = false,
            category    = 'services',
            author      = 'Los Santos Medical Center',
            onOpen      = function()
                exports['vp_tablet']:CloseTablet()
                TriggerEvent('loki_prescriptions:createPrescription')
            end,
        })
    end)
end

CreateThread(function()
    Wait(2500)
    registerTabletApp()
end)

AddEventHandler('onResourceStart', function(resName)
    if resName == 'vp_tablet' then
        Wait(1500)
        registerTabletApp()
    end
end)
