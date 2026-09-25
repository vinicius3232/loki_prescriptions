-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Wait for Config.Temperature to be available before proceeding
while not (Config and Config.Temperature) do
  Citizen.Wait(100)
end

-- Exit early if the Temperature system is disabled in config
if not Config.Temperature.enabled then
  return
end

-- Initialize the Temperature table
Temperature = {}

-- Set initial temperature to a random value in the configured range
Temperature.value        = math.random(Config.Temperature.minTemperature, Config.Temperature.maxTemperature)
Temperature.canGetCritical = true

-- Temperature.init: starts the background thread that ticks temperature over time
Temperature.init = function(self)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000)

      local injuryAmount = Damages.getInjuriesAmount(Damages)

      if injuryAmount < 1 then
        -- No injuries: slowly decay temperature toward minTemperature (only when not critical)
        if not self.critical then
          local decay = math.random(1, 5)
          self.value = math.max(Config.Temperature.minTemperature, self.value - decay)
          LocalPlayer.state:set("temperature", self.value, true)
        end

      else
        -- Has injuries: check whether a critical temperature event should trigger
        if Config.Temperature.critical.enabled then
          if injuryAmount >= Config.Temperature.critical.requiredInjuries then
            if not self.critical and self.canGetCritical then
              -- Roll for critical chance
              local roll = math.random(1, 100)
              if roll <= Config.Temperature.critical.chance then
                -- Trigger critical temperature: pick one of the two critical values
                local criticalTemps = Config.Temperature.critical.temperature
                self.value = criticalTemps[math.random(1, 2)]
                self.critical = true
                self.canGetCritical = false

                LocalPlayer.state:set("temperature", self.value, true)
                LocalPlayer.state:set("criticalTemperature", true, true)

                -- Notify the player whether temperature is critically low or high
                if self.value < Config.Temperature.minTemperature then
                  Bridge.Notify.showNotify(locale("temperature_low"), "inform")
                else
                  Bridge.Notify.showNotify(locale("temperature_high"), "inform")
                end
              end
            end
          end
        end
      end
    end
  end)
end

-- Network event: an item was used that affects temperature
RegisterNetEvent("p_ambulancejob/client/temperature/usedItem", function(itemName)
  -- Validate that the item exists and has a defined temperature effect
  if not itemName then return end
  local itemEffect = Config.Temperature.items[itemName]
  if not itemEffect then return end

  -- Apply the item's temperature change
  Temperature.value = Temperature.value + itemEffect

  local criticalTemps    = Config.Temperature.critical.temperature
  local criticalLow      = criticalTemps[1]
  local criticalHigh     = criticalTemps[2]

  if Temperature.value < criticalLow - 3 then
    -- Clamp to the lowest critical value
    Temperature.value = criticalLow

  elseif Temperature.value > criticalHigh + 3 then
    -- Clamp to the highest critical value
    Temperature.value = criticalHigh
  end

  -- Sync updated temperature to player state
  LocalPlayer.state:set("temperature", Temperature.value, true)

  -- Check if temperature is now back within normal range → reset critical state
  local min = Config.Temperature.minTemperature
  local max = Config.Temperature.maxTemperature

  if Temperature.value >= min and Temperature.value <= max then
    Temperature.reset(Temperature, false)
  else
    -- Still out of range: notify player of direction
    if Temperature.value < min then
      Bridge.Notify.showNotify(locale("temperature_low"), "inform")
    else
      Bridge.Notify.showNotify(locale("temperature_high"), "inform")
    end
  end
end)

-- Temperature.reset: restores temperature to a healthy random value and clears critical state
Temperature.reset = function(self, canGetCritical)
  if canGetCritical == nil then
    canGetCritical = true
  end

  self.value = math.random(Config.Temperature.minTemperature, Config.Temperature.maxTemperature)
  self.critical = false
  self.canGetCritical = canGetCritical

  LocalPlayer.state:set("temperature", self.value, true)
  LocalPlayer.state:set("criticalTemperature", false, true)

  Bridge.Notify.showNotify(locale("temperature_stable"), "inform")
end

-- Network event: server requests a temperature reset (without restoring canGetCritical)
RegisterNetEvent("p_ambulancejob/client/temperature/reset", function()
  Temperature.reset(Temperature)
end)

-- Temperature.add: increases temperature by amount, capped at maxTemperature
Temperature.add = function(self, amount)
  self.value = math.min(Config.Temperature.maxTemperature, self.value + amount)
  LocalPlayer.state:set("temperature", self.value, true)
end

-- Kick off the temperature tick thread on resource start
Citizen.CreateThread(function()
  Temperature.init(Temperature)
end)

-- Export: reset temperature from external resources
exports("resetTemperature", function()
  Temperature.reset(Temperature)
end)

-- Export: add to temperature from external resources
exports("addTemperature", function(amount)
  Temperature.add(Temperature, amount)
end)