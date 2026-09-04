Config = {}

--[[
  _____       ___   ___  ____   _____   ______     ______  _______     _____  _______   _________   ______          
 |_   _|    .'   `.|_  ||_  _| |_   _|.' ____ \  .' ___  ||_   __ \   |_   _||_   __ \ |  _   _  |.' ____ \         
   | |     /  .-.  \ | |_/ /     | |  | (___ \_|/ .'   \_|  | |__) |    | |    | |__) ||_/ | | \_|| (___ \_|        
   | |   _ | |   | | |  __'.     | |   _.____`. | |         |  __ /     | |    |  ___/     | |     _.____`.         
  _| |__/ |\  `-'  /_| |  \ \_  _| |_ | \____) |\ `.___.'\ _| |  \ \_  _| |_  _| |_       _| |_   | \____) |        
 |________| `.___.'|____||____||_____| \______.' `.____ .'|____| |___||_____||_____|     |_____|   \______.'        
  _____       ___   ___  ____   _____           _______  _______     ________   ______     ______  _______     _____  _______   _________  _____   ___   ____  _____   ______   
 |_   _|    .'   `.|_  ||_  _| |_   _|         |_   __ \|_   __ \   |_   __  |.' ____ \  .' ___  ||_   __ \   |_   _||_   __ \ |  _   _  ||_   _|.'   `.|_   \|_   _|.' ____ \  
   | |     /  .-.  \ | |_/ /     | |             | |__) | | |__) |    | |_ \_|| (___ \_|/ .'   \_|  | |__) |    | |    | |__) ||_/ | | \_|  | | /  .-.  \ |   \ | |  | (___ \_| 
   | |   _ | |   | | |  __'.     | |             |  ___/  |  __ /     |  _| _  _.____`. | |         |  __ /     | |    |  ___/     | |      | | | |   | | | |\ \| |   _.____`.  
  _| |__/ |\  `-'  /_| |  \ \_  _| |_  _______  _| |_    _| |  \ \_  _| |__/ || \____) |\ `.___.'\ _| |  \ \_  _| |_  _| |_       _| |_    _| |_\  `-'  /_| |_\   |_ | \____) | 
 |________| `.___.'|____||____||_____||_______||_____|  |____| |___||________| \______.' `.____ .'|____| |___||_____||_____|     |_____|  |_____|`.___.'|_____|\____| \______.' 
                                                                                                                                                                                
]]

Config.VersionCheck = true
Config.VersionCheckOmitLatest = false -- if true, will not print anything unless your version is outdated
Config.CreateDatabase = true -- auto create database, recommended

Config.NuiStyle = "de" -- us, uk or de
Config.TimeFormat = "de-DE" -- for example en-US, de-DE or similar. Used to format the date in nui
Config.Locale = "de" -- de, en or es

Config.Target = true -- recommended, otherwise uses markers and press E

Config.PrescriptionJobs = {"ambulance", "pharmacy"} -- all jobs that can issue prescriptions
Config.PrescriptionItem = 'prescription'
Config.PrescriptionPadItem = 'prescription_pad'

Config.Anim = {
    enabled = true,
    dict = "amb@world_human_tourist_map@male@base",
    anim = "base",
    prop = {
        model = `prop_notepad_02`,
        bone = 28422,
        offsets = {0.1, 0.0, 0.0},
        rotations = {50.0, 0.0, 0.0}
    }
}


-- medicine is preconfigured for K_Diseases: https://kbase.tebex.io/package/5509125
Config.Medicine = {
    {
        item = 'tylacare',
        label = "Tylacare",
        cost = 200
    },
    {
        item = 'flurimax',
        label = "Flurimax",
        cost = 250
    },
    {
        item = 'dayrelief',
        label = "Dayrelief",
        cost = 300
    },
    {
        item = 'gutguard',
        label = "GutGuard",
        cost = 300
    },
    {
        item = 'stopdiaril',
        label = "Stopdiaril",
        cost = 300
    },
    {
        item = 'triptaril',
        label = "Triptaril",
        cost = 300
    },
    {
        item = 'ibrofenix',
        label = "Ibrofenix",
        cost = 300
    },
    {
        item = 'allerblock',
        label = "AllerBlock",
        cost = 300
    },
    {
        item = 'clearairin',
        label = "Clearairin",
        cost = 300
    },
    {
        item = 'motionex',
        label = "Motionex",
        cost = 300
    },
    {
        item = 'meklirin',
        label = "Meklirin",
        cost = 300
    },
    {
        item = 'vironix',
        label = "Vironix",
        cost = 300
    },
    {
        item = 'vaxora',
        label = "Vaxora",
        cost = 300
    },
    {
        item = 'cycurex',
        label = "Cycurex",
        cost = 300
    },
    {
        item = 'painaway',
        label = "PainAway",
        cost = 300
    },
    {
        item = 'zithromed',
        label = "ZithroMed",
        cost = 300
    },
    {
        item = 'doxallin',
        label = "Doxallin",
        cost = 300
    },
    {
        item = 'loprexin',
        label = "Loprexin",
        cost = 300
    },
}


--- INSURANCE
--- Players can buy insurance to save money on prescriptions
Config.Insurance = {
    duration = 60 --[[seconds]] * 60 --[[minutes]] * 24 --[[hours]] * 7 --[[days]], -- duration of the insurance in seconds, change to nil for permanent
    price = 500,
    reduction = 0.35, -- reduces the price of meds to 35% (price * reduction)
    npc = {
        position = vector4(-291.5244, -430.6360, 29.2375, 341.2159),
        model = `ig_andreas`,
        anim = {dict = "amb@world_human_hang_out_street@female_arms_crossed@idle_a", anim = "idle_a", flags = 17}
    },
    blip = {
        sprite = 276,
        color = 3,
        label = "Health Insurance",
        shortRange = true,
        display = 4,
        scale = 1.0
    }
}


--- PHARMACIES
--- Players can redeem their prescriptions here
Config.Pharmacies = {
    {
        position = vector4(343.5782, -1398.8131, 31.5092, 50.1448),
        pedModel = `s_m_m_doctor_01`,
        anim = {dict = "amb@world_human_hang_out_street@female_arms_crossed@idle_a", anim = "idle_a", flags = 17},
        blip = {sprite = 153, color = 2, label = "Pharmacy", shortRange = true, display = 4, scale = 1.0}
    },
    {
        position = vector4(-248.3205, 6332.7231, 31.4261, 226.4288),
        pedModel = `s_m_m_doctor_01`,
        anim = {dict = "amb@world_human_hang_out_street@female_arms_crossed@idle_a", anim = "idle_a", flags = 17},
        blip = {sprite = 153, color = 2, label = "Pharmacy", shortRange = true, display = 4, scale = 1.0}
    },
}


---------------------- Notifications ---------------
Config.Notification = 'esx' -- Available notification systems: okokNotify, esx, lib (ox_lib), RiP-Notify, qb, wasabi_notify, mythic_notify, sy_notify, custom

---- Write your custom Notify system here if you wish to use your own
function CustomNotify(type, msg, heading, src)
    -- Your Custom function goes here
    -- Used types are error, success and info
    -- msg is the displayed notification text 
    -- heading is for systems like okokNotify with headings on the notification. Just dont use it if your system does not have one. 
    -- currentID is the server ID of the player that gets the notification
    print('customNotify')
end
