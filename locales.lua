Locale = Locale or {}

function _U(key, ...)
    local arg = {...}
    local trans = Locale[Config.Locale][key] or Locale["en"][key] --fallback to english for partial translations
    trans = string.format(trans, table.unpack(arg))
    return trans
end
