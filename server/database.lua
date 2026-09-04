local function setupDatabase()
    SQL([[
        CREATE TABLE IF NOT EXISTS prescription_insurance (
        `identifier` VARCHAR(255) PRIMARY KEY,
        `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP()
    )]], {})
end

CreateThread(function()
    if Config.CreateDatabase then
        setupDatabase()
    end
    if Config.Insurance.duration then
        SQL("DELETE FROM prescription_insurance WHERE date < date_sub(CURRENT_TIMESTAMP(), INTERVAL ? SECOND);", {Config.Insurance.duration})
    end
end)
