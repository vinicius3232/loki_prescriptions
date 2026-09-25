-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Helper: returns true when the caller's job is in Editable.allJobs.
-- Notifies the source player and returns false on failure.
local function checkJob(src)
  local plyJob = Bridge.Framework.getPlayerJob(src)
  if plyJob and Editable.allJobs[plyJob.name] then
    return true
  end
  Bridge.Notify.showNotify(src, locale("no_access"), "error")
  return false
end

-- Helper: resolve a net-id to a valid, existing entity or return nil.
local function getValidEntity(netId)
  if not netId then return nil end
  local entity = NetworkGetEntityFromNetworkId(netId)
  if entity and entity ~= 0 and DoesEntityExist(entity) then
    return entity
  end
  return nil
end

-- Helper: distance between two player peds (by server id).
local function playerDist(srcA, srcB)
  local coordsA = GetEntityCoords(GetPlayerPed(srcA))
  local coordsB = GetEntityCoords(GetPlayerPed(srcB))
  return #(coordsA - coordsB)
end

RegisterNetEvent("p_ambulancejob/server/stretcher/remove")
AddEventHandler("p_ambulancejob/server/stretcher/remove", function(data)
  local src = source

  -- Validate payload
  if not (data and data.netId) then return end

  local stretcherObj = getValidEntity(data.netId)
  if not stretcherObj then return end

  -- Distance check: caller must be within 7 units of the prop
  local srcCoords   = GetEntityCoords(GetPlayerPed(src))
  local propCoords  = GetEntityCoords(stretcherObj)
  if #(srcCoords - propCoords) > 7.0 then return end

  -- Job check
  if not checkJob(src) then return end

  -- Notify the entity owner so they can clear client-side state
  local owner = NetworkGetEntityOwner(stretcherObj)
  if owner and owner ~= 0 then
    TriggerClientEvent("p_ambulancejob/client/stretcher/clear", owner)
  end

  -- Return the stretcher item and delete the prop
  Bridge.Inventory.addItem(src, "stretcher", 1)
  DeleteEntity(stretcherObj)
end)

RegisterNetEvent("p_ambulancejob/server/stretcher/attachPlayer")
AddEventHandler("p_ambulancejob/server/stretcher/attachPlayer", function(targetId, stretcherNetId)
  local src = source

  -- Both arguments must be valid positive numbers
  if not (type(targetId) == "number" and targetId >= 1
      and type(stretcherNetId) == "number") then
    return
  end

  -- Distance check: caller must be within 7 units of the target player
  if playerDist(src, targetId) > 7.0 then return end

  -- Resolve stretcher entity
  local stretcherObj = getValidEntity(stretcherNetId)
  if not stretcherObj then return end

  -- Distance check: target player must also be within 7 units of the stretcher
  local targetCoords    = GetEntityCoords(GetPlayerPed(targetId))
  local stretcherCoords = GetEntityCoords(stretcherObj)
  if #(targetCoords - stretcherCoords) > 7.0 then return end

  -- Job check
  if not checkJob(src) then return end

  -- Tell the target client to lay on the stretcher
  TriggerClientEvent("p_ambulancejob/client/stretcher/attachPlayer", targetId, stretcherNetId)
end)

RegisterNetEvent("p_ambulancejob/server/stretcher/detachPlayer")
AddEventHandler("p_ambulancejob/server/stretcher/detachPlayer", function(targetId, stretcherNetId)
  local src = source

  -- Both arguments must be valid positive numbers
  if not (type(targetId) == "number" and targetId >= 1
      and type(stretcherNetId) == "number") then
    return
  end

  -- Distance check: caller must be within 7 units of the target player
  if playerDist(src, targetId) > 7.0 then return end

  -- Resolve stretcher entity
  local stretcherObj = getValidEntity(stretcherNetId)
  if not stretcherObj then return end

  -- Distance check: target player must also be within 7 units of the stretcher
  local targetCoords    = GetEntityCoords(GetPlayerPed(targetId))
  local stretcherCoords = GetEntityCoords(stretcherObj)
  if #(targetCoords - stretcherCoords) > 7.0 then return end

  -- Job check
  if not checkJob(src) then return end

  -- Tell the target client to stand up
  TriggerClientEvent("p_ambulancejob/client/stretcher/detachPlayer", targetId, stretcherNetId)
end)

RegisterNetEvent("p_ambulancejob/server/stretcher/vehicle")
AddEventHandler("p_ambulancejob/server/stretcher/vehicle", function(data)
  local src = source

  -- Validate payload: netId and a boolean state are required
  if not (data and data.netId and type(data.state) == "boolean") then return end

  local srcCoords = GetEntityCoords(GetPlayerPed(src))

  -- Resolve stretcher entity
  local stretcherObj = getValidEntity(data.netId)
  if not stretcherObj then return end

  -- Distance check: caller must be within 7 units of the stretcher
  if #(srcCoords - GetEntityCoords(stretcherObj)) > 7.0 then return end

  -- Resolve vehicle entity
  local vehicle = getValidEntity(data.vehicleId)
  if not vehicle then return end

  -- Job check
  if not checkJob(src) then return end

  if data.state then
    -- Putting stretcher IN the vehicle
    if Entity(vehicle).state.hasStretcher then
      -- Vehicle already occupied – notify and bail
      Bridge.Notify.showNotify(src, locale("vehicle_already_has_stretcher"), "error")
      return
    end
    -- Mark vehicle as carrying this stretcher (store net-id for later lookup)
    Entity(vehicle).state:set("hasStretcher", data.netId, true)
  else
    -- Taking stretcher OUT of the vehicle
    Entity(vehicle).state:set("hasStretcher", false, true)
  end

  -- Notify the entity owner (may differ from the requesting player)
  local owner = NetworkGetEntityOwner(vehicle)
  if owner and owner ~= 0 then
    TriggerClientEvent("p_ambulancejob/client/stretcher/vehicle", owner, data)
  end

  -- Always notify the requesting player too (handles the case where they are the owner)
  TriggerClientEvent("p_ambulancejob/client/stretcher/vehicle", src, data)
end)