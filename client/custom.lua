local oxTarget = GetResourceState('ox_target') == 'started'
local qbTarget = GetResourceState('qb-target') == 'started'

---@param entity number entity handle
---@param label string
---@param icon string? icon to display with target (optional)
---@param cb function function to be executed when target is selected
function AddTarget(entity, label, icon, cb)
    if oxTarget then
        local options = {
            label = label,
            name = label,
            distance = 2.0,
            onSelect = cb,
            icon = icon
        }
        exports['ox_target']:addLocalEntity(entity, options)
    elseif qbTarget then
        local parameters = {
            options = {{
                label = label,
                action = cb,
                targeticon = icon
            }},
            distance = 2.0
        }
        exports['qb-target']:AddTargetEntity(entity, parameters)
    else
        -- custom target
    end
end
