-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait until Config.Stretcher is available
while not (Config and Config.Stretcher) do
  Citizen.Wait(1)
end

-- Early exit if stretcher feature is disabled
if not Config.Stretcher.enabled then
  return
end


Stretcher = {
  isAttached   = false,
  attachedTo   = false,
  folded       = {},
}


Citizen.CreateThread(function()
  Citizen.Wait(2000)

  -- Optional: global detach-target interactions (put down / put in vehicle)
  if Config.Stretcher.useDetachTarget then
    Bridge.Target.addGlobal({
      {
        name        = "p_ambulancejob/stretcher/detach",
        label       = locale("put_down_stretcher"),
        icon        = "fa-solid fa-hand",
        distance    = 2.0,
        groups      = Editable.allJobs,
        onSelect    = function() Stretcher:detach() end,
        canInteract = function() return Stretcher.isAttached end,
      },
      {
        name        = "p_ambulancejob/stretcher/putInVehicle",
        label       = locale("put_stretcher_in_vehicle"),
        icon        = "fa-solid fa-car",
        distance    = 2.0,
        groups      = Editable.allJobs,
        onSelect    = function() Stretcher:vehicle(true) end,
        canInteract = function() return Stretcher.isAttached end,
      },
    })
  end

  -- Vehicle target: pick up stretcher from vehicle
  Bridge.Target.addVehicle({
    {
      name        = "p_ambulancejob/stretcher/removeFromVehicle",
      label       = locale("pickup_stretcher"),
      icon        = "fa-solid fa-hand",
      distance    = 3.0,
      groups      = Editable.allJobs,
      onSelect    = function() Stretcher:vehicle(false) end,
      canInteract = function(vehicle)
        -- Only show if our stretcher object is attached to this specific vehicle
        if not (Stretcher.object and DoesEntityExist(Stretcher.object)) then
          return false
        end
        return GetEntityAttachedTo(Stretcher.object) == vehicle
      end,
    },
  })

  -- Player target: put a player onto the stretcher
  Bridge.Target.addPlayer({
    {
      name        = "p_ambulancejob/stretcher/putOnStretcher",
      label       = locale("put_player_on_stretcher"),
      icon        = "fa-solid fa-person-walking",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function(data)
        -- Resolve entity handle: accept raw number or table with .entity
        local entity = (type(data) ~= "number" or not data) and data.entity or data
        if not entity or entity == 0 then return end
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
        Stretcher:attachPlayer(targetServerId)
      end,
      canInteract = function(entity)
        if not Stretcher.object then return false end
        if Stretcher.attachedPlayer then return false end
        return #(GetEntityCoords(entity) - GetEntityCoords(Stretcher.object)) < 7.0
      end,
    },
  })

  -- Model target: actions on the stretcher prop itself
  local stretcherModels = {
    Config.Stretcher.prop.model,
    Config.Stretcher.prop.foldModel,
    'sittingstrykergurney',
    'combicarrier2',
    'fernocot',
    'sittingfernocot',
    'loweredfernocot',
  }

  -- Helper: returns true only when the interacted entity IS our current stretcher object
  local function isOurStretcher(entity)
    return Stretcher.object and Stretcher.object == entity
  end

  Bridge.Target.addModel(stretcherModels, {
    {
      name        = "p_ambulancejob/stretcher/toggleFold",
      label       = locale("toggle_fold"),
      icon        = "fa-solid fa-compress",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function() Stretcher:toggleFold() end,
      canInteract = isOurStretcher,
    },
    {
      name        = "p_ambulancejob/stretcher/pickup",
      label       = locale("pickup_stretcher"),
      icon        = "fa-solid fa-hand",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function(data)
        local entity = (type(data) ~= "number" or not data) and data.entity or data
        Stretcher:attach(entity)
      end,
      canInteract = isOurStretcher,
    },
    {
      name        = "p_ambulancejob/stretcher/remove",
      label       = locale("remove_stretcher"),
      icon        = "fa-solid fa-trash",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function(data)
        local entity = (type(data) ~= "number" or not data) and data.entity or data
        Stretcher:delete(entity)
      end,
    },
    {
      name        = "p_ambulancejob/stretcher/putInVehicle",
      label       = locale("put_stretcher_in_vehicle"),
      icon        = "fa-solid fa-car",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function() Stretcher:vehicle(true) end,
      canInteract = isOurStretcher,
    },
    {
      name        = "p_ambulancejob/stretcher/takePlayerOut",
      label       = locale("take_player_out_stretcher"),
      icon        = "fa-solid fa-person-walking",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function() Stretcher:detachPlayer() end,
      canInteract = isOurStretcher,
    },
    {
      name        = "p_ambulancejob/stretcher/placeBodyBag",
      label       = locale("place_bodybag_on_stretcher"),
      icon        = "fa-solid fa-skull",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function() BodyBag:attachToStretcher() end,
      canInteract = function(entity)
        -- Only show if carrying a bag, our stretcher exists, and the bag isn't already here
        return BodyBag.isCarrying
          and Stretcher.object ~= nil
          and Stretcher.attachedBag ~= entity
      end,
    },
    {
      name        = "p_ambulancejob/stretcher/removeBodyBag",
      label       = locale("remove_bodybag_from_stretcher"),
      icon        = "fa-solid fa-skull",
      distance    = 2.0,
      groups      = Editable.allJobs,
      onSelect    = function()
        if Stretcher.attachedBag and DoesEntityExist(Stretcher.attachedBag) then
          BodyBag:detachFromStretcher()
        end
      end,
      canInteract = function(entity)
        return Stretcher.object ~= nil
          and Stretcher.attachedBag ~= nil
          and DoesEntityExist(Stretcher.attachedBag)
          and Stretcher.attachedBag == entity
      end,
    },
  })
end)

-- =====================================================
--  Stretcher:create  –  spawn the prop and attach it
-- =====================================================

function Stretcher:create()
  local plyJob = Bridge.Framework.fetchPlayerJob()

  -- Job authorization check
  if not (plyJob and Editable.allJobs[plyJob.name]) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end

  local modelHash = GetHashKey(Config.Stretcher.prop.model)
  lib.requestModel(modelHash)

  -- Remove item from inventory, then spawn object at player position
  TriggerServerEvent("p_bridge/server/removeItem", "stretcher", 1)
  local obj = CreateObject(modelHash, GetEntityCoords(cache.ped), true, false, false)
  self.object = obj

  -- Network setup: make entity visible and controllable by all
  local netId = NetworkGetNetworkIdFromEntity(obj)
  SetEntityAsMissionEntity(obj, true, true)
  SetNetworkIdExistsOnAllMachines(netId, true)
  SetNetworkIdCanMigrate(netId, true)
  SetEntityCollision(obj, true, true)
  NetworkRequestControlOfEntity(obj)

  self:attach()
end

Stretcher.create = Stretcher.create

-- Net event: server tells this client to create a stretcher
RegisterNetEvent("p_ambulancejob/client/stretcher/create")
AddEventHandler("p_ambulancejob/client/stretcher/create", function()
  Stretcher:create()
end)

-- =====================================================
--  Stretcher:delete  –  request server to remove prop
-- =====================================================

function Stretcher:delete(entity)
  if entity and DoesEntityExist(entity) then
    TriggerServerEvent("p_ambulancejob/server/stretcher/remove", {
      netId = Utils:getNetId(entity),
    })
  end
end

Stretcher.delete = Stretcher.delete

-- Net event: server cleared the stretcher for this client
RegisterNetEvent("p_ambulancejob/client/stretcher/clear")
AddEventHandler("p_ambulancejob/client/stretcher/clear", function()
  Stretcher.object         = nil
  Stretcher.attachedPlayer = nil
  LocalPlayer.state:set("usingStretcher", false, true)
end)

-- =====================================================
--  Stretcher:attach  –  pick up and carry the stretcher
-- =====================================================

function Stretcher:attach(entity)
  if self.isAttached then return end

  -- Use provided entity or fall back to our own object
  local obj = entity or self.object

  -- Wait until we have network control of the entity
  NetworkRequestControlOfEntity(obj)
  while not NetworkHasControlOfEntity(obj) do
    Citizen.Wait(1)
    NetworkRequestControlOfEntity(obj)
  end

  LocalPlayer.state:set("usingStretcher", true, true)

  -- Attach object to the player's specified hand bone
  local boneIdx = GetPedBoneIndex(cache.ped, Config.Stretcher.prop.bone)
  AttachEntityToEntity(
    obj, cache.ped, boneIdx,
    Config.Stretcher.prop.coords,
    Config.Stretcher.prop.rot,
    true, true, false, true, 1, true
  )
  self.isAttached = true

  -- Carry animation + put-down key listener
  Citizen.CreateThread(function()
    local animDict = Config.Stretcher.anims.carry.dict
    local animClip = Config.Stretcher.anims.carry.clip

    lib.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animClip, 8.0, 8.0, -1, 50, 0, false, false, false)

    -- Show put-down hint when not using the detach-target system
    if not Config.Stretcher.useDetachTarget then
      lib.showTextUI(locale("put_down_stretcher_textui"))
    end

    while self.isAttached do
      -- Slower tick when a bag is attached (less CPU usage)
      Citizen.Wait(self.attachedBag and 500 or 1)

      -- Re-apply animation if it stopped playing
      if not IsEntityPlayingAnim(cache.ped, animDict, animClip, 3) then
        TaskPlayAnim(cache.ped, animDict, animClip, 8.0, 8.0, -1, 50, 0, false, false, false)
      end

      -- Keyboard put-down (only when not using detach-target)
      if not Config.Stretcher.useDetachTarget and IsControlJustPressed(0, 73) then
        self:detach()
        break
      end
    end

    lib.hideTextUI()
    ClearPedTasks(cache.ped)
    RemoveAnimDict(animDict)
  end)
end

Stretcher.attach = Stretcher.attach

-- =====================================================
--  Stretcher:detach  –  put the stretcher down
-- =====================================================

function Stretcher:detach()
  Citizen.CreateThread(function()
    if not self.isAttached then return end

    -- If a body bag is attached, temporarily float it above the stretcher
    if self.attachedBag then
      FreezeEntityPosition(self.attachedBag, true)
      DetachEntity(self.attachedBag, true, true)
      local floatPos = GetOffsetFromEntityInWorldCoords(self.object, 0.0, 0.0, 2.0)
      SetEntityCoordsNoOffset(self.attachedBag, floatPos, true, true, true)
      Citizen.Wait(10)
    end

    LocalPlayer.state:set("usingStretcher", false, true)
    SetEntityNoCollisionEntity(self.object, self.attachedBag, true)
    DetachEntity(self.object, true, true)
    PlaceObjectOnGroundProperly(self.object)
    FreezeEntityPosition(self.object, true)
    self.isAttached = false

    Citizen.Wait(50)
    ClearPedTasks(cache.ped)
    PlaceObjectOnGroundProperly(self.object)

    -- Re-attach body bag at height appropriate for fold state
    if self.attachedBag then
      Citizen.Wait(50)
      local bagZ = self.isFolded and 0.7 or 1.1
      AttachEntityToEntity(
        self.attachedBag, self.object,
        0, 0.225, 0.0, bagZ,
        0.0, 0.0, 270.0,
        false, false, false, false, 2, true
      )
      FreezeEntityPosition(self.attachedBag, false)
    end
  end)
end

Stretcher.detach = Stretcher.detach

-- =====================================================
--  Stretcher:vehicle  –  load/unload from ambulance
-- =====================================================

function Stretcher:vehicle(putIn)
  local closestVeh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 7.0, true)
  if not (closestVeh and closestVeh ~= 0) then return end

  -- Validate the vehicle model is in the allowed list
  local vehConfig = Config.Stretcher.vehicleModels[joaat(GetEntityModel(closestVeh))]
  if not vehConfig then
    Bridge.Notify.showNotify(locale("you_cant_put_stretcher_in_this_vehicle"), "error")
    return
  end

  local vehicleNetId   = Utils:getNetId(closestVeh)
  local stretcherNetId = Utils:getNetId(self.object)
  if not vehicleNetId   or vehicleNetId   == 0 then return end
  if not stretcherNetId or stretcherNetId == 0 then return end

  -- Detach from player first if currently carrying the stretcher
  if putIn and self.isAttached then
    self:detach()
    Citizen.Wait(250)
  end

  LocalPlayer.state:set("usingStretcher", false, true)
  TriggerServerEvent("p_ambulancejob/server/stretcher/vehicle", {
    netId     = stretcherNetId,
    vehicleId = vehicleNetId,
    state     = putIn,
  })
end

Stretcher.vehicle = Stretcher.vehicle

-- Net event: server confirmed vehicle attach/detach
RegisterNetEvent("p_ambulancejob/client/stretcher/vehicle")
AddEventHandler("p_ambulancejob/client/stretcher/vehicle", function(data)
  local stretcherObj = Utils:getEntityFromNetId(data.netId)
  if not (stretcherObj and stretcherObj ~= 0 and DoesEntityExist(stretcherObj)) then return end

  local vehicle = Utils:getEntityFromNetId(data.vehicleId)
  if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)) then return end

  local vehConfig = Config.Stretcher.vehicleModels[joaat(GetEntityModel(vehicle))]
  if not vehConfig then return end

  if data.state then
    -- Attach stretcher into vehicle slot
    AttachEntityToEntity(
      stretcherObj, vehicle,
      0, vehConfig.coords, vehConfig.rot,
      true, true, false, false, 1, true
    )
  else
    -- Detach stretcher from vehicle
    DetachEntity(stretcherObj, true, true)
    Citizen.Wait(250)
    -- Re-attach to player if this is our own stretcher
    if Stretcher.object == stretcherObj then
      Stretcher:attach()
    end
  end
end)

-- =====================================================
--  Stretcher:toggleFold  –  fold / unfold the stretcher
-- =====================================================

function Stretcher:toggleFold()
  self.isFolded = not self.isFolded
  Entity(self.object).state:set("isFolded", self.isFolded, true)
end

Stretcher.toggleFold = Stretcher.toggleFold

-- =====================================================
--  Stretcher:attachPlayer  –  put a player on stretcher
-- =====================================================

function Stretcher:attachPlayer(targetServerId)
  if self.attachedPlayer then return end

  local stretcherNetId = Utils:getNetId(self.object)
  if not stretcherNetId or stretcherNetId == 0 then return end

  TriggerServerEvent("p_ambulancejob/server/stretcher/attachPlayer", targetServerId, stretcherNetId)
  self.attachedPlayer = targetServerId
end

Stretcher.attachPlayer = Stretcher.attachPlayer

-- =====================================================
--  Stretcher:detachPlayer  –  remove player from stretcher
-- =====================================================

function Stretcher:detachPlayer()
  if not self.attachedPlayer then return end

  local stretcherNetId = Utils:getNetId(self.object)
  if not stretcherNetId or stretcherNetId == 0 then return end

  TriggerServerEvent("p_ambulancejob/server/stretcher/detachPlayer", self.attachedPlayer, stretcherNetId)
  self.attachedPlayer = nil
end

Stretcher.detachPlayer = Stretcher.detachPlayer

-- Net event: lay local ped on the stretcher (as the patient)
RegisterNetEvent("p_ambulancejob/client/stretcher/attachPlayer")
AddEventHandler("p_ambulancejob/client/stretcher/attachPlayer", function(stretcherNetId)
  local stretcherObj = Utils:getEntityFromNetId(stretcherNetId)
  if not (stretcherObj and stretcherObj ~= 0 and DoesEntityExist(stretcherObj)) then return end

  -- Attach ped lying on top of the stretcher
  AttachEntityToEntity(
    cache.ped, stretcherObj,
    0, 0, 0.0, 2.1,
    195.0, 0.0, 90.0, 0.0,
    false, false, false, false, 2
  )
  Stretcher.attachedTo = stretcherObj

  -- Play the lying-down animation and monitor attachment validity
  local layAnim = Config.Stretcher.anims.lay
  lib.requestAnimDict(layAnim.dict)

  Citizen.CreateThread(function()
    while Stretcher.attachedTo do
      -- Auto-detach if the stretcher entity no longer exists
      if not DoesEntityExist(Stretcher.attachedTo) then
        Stretcher.attachedTo = false
        DetachEntity(cache.ped, true, true)
        ClearPedTasks(cache.ped)
        return
      end

      -- Keep playing lay animation while alive
      if Death.deathType == "none" then
        if not IsEntityPlayingAnim(cache.ped, layAnim.dict, layAnim.clip, 3) then
          TaskPlayAnim(cache.ped, layAnim.dict, layAnim.clip, -8.0, 8.0, -1, 1, 1)
        end
      end

      Citizen.Wait(500)
    end

    RemoveAnimDict(layAnim.dict)
  end)
end)

-- Net event: stand the local ped back up (detach from stretcher)
RegisterNetEvent("p_ambulancejob/client/stretcher/detachPlayer")
AddEventHandler("p_ambulancejob/client/stretcher/detachPlayer", function(stretcherNetId)
  local stretcherObj = NetworkGetEntityFromNetworkId(stretcherNetId)
  if not (stretcherObj and stretcherObj ~= 0 and DoesEntityExist(stretcherObj)) then return end

  -- Only act if the player is attached to this specific stretcher
  if not (Stretcher.attachedTo and Stretcher.attachedTo == stretcherObj) then return end

  -- Place ped slightly in front of the stretcher after detaching
  local dropCoords = GetOffsetFromEntityInWorldCoords(stretcherObj, 1.0, 0.0, 0.0)
  DetachEntity(cache.ped, true, true)
  ClearPedTasks(cache.ped)
  Stretcher.attachedTo = nil

  Citizen.Wait(100)
  SetEntityCoordsNoOffset(cache.ped, dropCoords.x, dropCoords.y, dropCoords.z, true, true, true)
end)

-- =====================================================
--  StateBag handler: "isFolded" – swap stretcher model
-- =====================================================

AddStateBagChangeHandler("isFolded", nil, function(bagName, _, isFolded, _, isReplicated)
  -- Skip replicated (server-echo) updates to avoid duplicate swaps
  if isReplicated then return end

  local entity = GetEntityFromStateBagName(bagName)
  if not entity or entity == 0 then return end
  if not DoesEntityExist(entity) then return end

  local netId = NetworkGetNetworkIdFromEntity(entity)
  if not netId or netId == 0 then return end

  local coords = GetEntityCoords(entity)

  -- Decide which model is "new" (target) and which is "old" (current)
  local newModelName = isFolded and Config.Stretcher.prop.model     or Config.Stretcher.prop.foldModel
  local oldModelName = isFolded and Config.Stretcher.prop.foldModel or Config.Stretcher.prop.model
  local newModel     = GetHashKey(newModelName)
  local oldModel     = GetHashKey(oldModelName)

  -- Remove any previous model swap for this network entity
  local foldEntry = Stretcher.folded[netId]
  if foldEntry then
    RemoveModelSwap(coords.x, coords.y, coords.z, 1.25, foldEntry.modelOne, foldEntry.modelTwo, true)
    Citizen.Wait(100)
  end

  CreateModelSwap(coords.x, coords.y, coords.z, 1.25, newModel, oldModel, true)
  Stretcher.folded[netId] = { value = isFolded, modelOne = newModel, modelTwo = oldModel }

  -- Adjust attached body bag height for the new fold state
  if Stretcher.object == entity and Stretcher.attachedBag then
    local bagZ = isFolded and 0.7 or 1.1
    AttachEntityToEntity(
      Stretcher.attachedBag, Stretcher.object,
      0, 0.225, 0.0, bagZ,
      0.0, 0.0, 270.0,
      false, false, false, false, 2, true
    )
  end

  -- Adjust local ped attachment height if they are lying on this stretcher
  if Stretcher.attachedTo == entity then
    local pedZ = isFolded and 1.7 or 2.1
    AttachEntityToEntity(
      cache.ped, entity,
      0, 0, 0.0, pedZ,
      195.0, 0.0, 90.0, 0.0,
      false, false, false, false, 2
    )
  end
end)