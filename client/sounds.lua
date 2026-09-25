-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- Initialize the Sounds table
Sounds = {}

-- Sounds.play: sends a NUI message to play a specific sound file at the given volume
Sounds.play = function(self, file, volume)
  if Config.Sounds.enabled then
    SendNUIMessage({
      action = "playSound",
      data = {
        file = file,
        volume = volume,
      }
    })
  end
end

-- Sounds.preset: plays a random sound from a named preset defined in Config.Sounds.presets
Sounds.preset = function(self, presetName)
  if not Config.Sounds.enabled then return end

  local preset = Config.Sounds.presets[presetName]
  if preset then
    local randomIndex = math.random(1, #preset.sounds)
    local randomFile = preset.sounds[randomIndex]
    self:play(randomFile, preset.volume)
  end
end

-- Network event: server requests a sound to be played on this client
RegisterNetEvent("p_policejob/sounds/play", function(file, volume)
  Sounds:play(file, volume)
end)