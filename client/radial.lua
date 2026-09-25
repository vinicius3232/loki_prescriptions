--[[
    ============================================================================
    Menu Radial Integrado do Ox Lib para Profissionais de Saúde (Radial Menu)
    Ações clínicas rápidas e intuitivas com atalhos de alta produtividade
    ============================================================================
]]

local function isDoctor()
    local job = Bridge.Framework.fetchPlayerJob()
    if not job then return false end
    if Config.PrescriptionJobs and lib.table.contains(Config.PrescriptionJobs, job.name) then
        return true
    end
    return job.name == 'ambulance'
end

-- Registro do Menu Radial no ox_lib
CreateThread(function()
    Wait(1500)

    if not lib or not lib.registerRadial then return end

    lib.registerRadial({
        id = 'loki_ems_menu',
        items = {
            {
                id = 'ems_diagnose',
                label = 'Diagnóstico Corporal',
                icon = 'stethoscope',
                onSelect = function()
                    local closest = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
                    if closest then
                        local targetServerId = GetPlayerServerId(closest)
                        TriggerEvent('p_ambulancejob/client/damages/openDamages', targetServerId)
                    else
                        Bridge.Notify.showNotify('Nenhum paciente próximo para examinar.', 'error')
                    end
                end
            },
            {
                id = 'ems_cpr',
                label = 'Reanimação / RCP',
                icon = 'heart-pulse',
                onSelect = function()
                    local closest = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.5, false)
                    if closest then
                        local targetServerId = GetPlayerServerId(closest)
                        TriggerEvent('loki_prescriptions:client:startCPR', targetServerId)
                    else
                        Bridge.Notify.showNotify('Nenhum paciente desacordado próximo.', 'error')
                    end
                end
            },
            {
                id = 'ems_sedate',
                label = 'Aplicar Sedativo',
                icon = 'syringe',
                onSelect = function()
                    TriggerEvent('loki_prescriptions:client:useSedative')
                end
            },
            {
                id = 'ems_xray',
                label = 'Raio-X & Tomografia',
                icon = 'x-ray',
                onSelect = function()
                    ExecuteCommand('raiox')
                end
            },
            {
                id = 'ems_certificate',
                label = 'Emitir Atestado',
                icon = 'file-medical',
                onSelect = function()
                    ExecuteCommand('atestado')
                end
            },
            {
                id = 'ems_forensics',
                label = 'Necropsia / Laudo',
                icon = 'skull-crossbones',
                onSelect = function()
                    local closest = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
                    if closest then
                        local targetPed = GetPlayerPed(closest)
                        if Entity(targetPed).state.isDead then
                            TriggerEvent('loki_prescriptions:client:startAutopsyFromRadial', targetPed)
                        else
                            Bridge.Notify.showNotify('O indivíduo precisa estar em óbito para perícia tanatológica.', 'error')
                        end
                    else
                        Bridge.Notify.showNotify('Nenhum corpo encontrado próximo.', 'error')
                    end
                end
            },
            {
                id = 'ems_vehicle',
                label = 'Embarcar / Desembarcar',
                icon = 'truck-medical',
                onSelect = function()
                    local closest = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
                    if closest then
                        local targetServerId = GetPlayerServerId(closest)
                        TriggerServerEvent('p_ambulancejob/server/interactions/putInVehicle', targetServerId)
                    else
                        Bridge.Notify.showNotify('Nenhum paciente próximo para embarcar.', 'error')
                    end
                end
            }
        }
    })

    -- Adiciona ou remove item da roda principal com base no emprego
    local function updateRadial()
        if isDoctor() then
            lib.addRadialItem({
                {
                    id = 'ems_general_radial',
                    label = 'Medicina & Socorro',
                    icon = 'suitcase-medical',
                    menu = 'loki_ems_menu'
                }
            })
        else
            lib.removeRadialItem('ems_general_radial')
        end
    end

    updateRadial()

    -- Monitoramento de troca de emprego
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
        Wait(500)
        updateRadial()
    end)
    RegisterNetEvent('qbx_core:client:jobUpdated', function()
        Wait(500)
        updateRadial()
    end)
    RegisterNetEvent('esx:setJob', function()
        Wait(500)
        updateRadial()
    end)
end)
