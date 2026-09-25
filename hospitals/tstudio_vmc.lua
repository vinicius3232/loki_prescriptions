-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

return {
    Hospital = {
        ['tstudio_vmc'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(-825.00, -1220.85, 6.34),
            },
            duty = {
                enabled = true,
                coords = vec4(-817.71, -1232.73, 6.46, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(-818.80, -1234.75, 6.72),
            management = {
                coords = vec3(-811.31, -1236.34, 6.70), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['tstudio_vmc'] = {
            ['Entrance TV'] = {
                coords = vec3(-822.01, -1227.20, 7.52), 
                rot = vec3(-0.00, 0.00, 50.00),
            },
        },
    },

    CheckIn = {
        ['tstudio_vmc'] = {
            label = 'Pillbox Hospital',
            coords = vec4(-810.27, -1238.22, 6.72, 231.00),
            driveCoords = vec4(-828.66, -1218.45, 6.94, 331.00), -- optional, if you want ai medic to drive to specific coords before going to bed
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            duration = 5000,
            maxDutyMedics = 2,
            price = {
                money = 500, -- price in cash
                bank = 500, -- price in bank
                black_money = 500, -- price in black money [if you want to disable some payment method, just remove it from table]
                insurance = true, -- can be used insurance for check-in? [only will work if player own insurance]
            }
        },
    },

    CheckInBeds = {
        ['tstudio_vmc'] = {
            vec4(-807.97, -1223.97, 7.65, 325.00),
            vec4(-805.23, -1226.23, 7.65, 327.00),
            vec4(-802.37, -1228.55, 7.65, 326.00),
            vec4(-799.57, -1230.91, 7.65, 315.00),
            vec4(-796.83, -1233.23, 7.65, 321.00),
        },
    },

    Insurances = {
        ['tstudio_vmc'] = {
            coords = vec4(-810.32, -1235.77, 6.72, 322.00),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['tstudio_vmc'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(-803.42, -1217.69, 6.72, 134.00),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            jobRestricted = true, -- only for jobs from Config.Hospitals?
            items = {
                {name = 'medicbag', price = 0},
                {name = 'ambulance_gps', price = 0},
                {name = 'wheelchair', price = 0},
                {name = 'crutch', price = 0},
                {name = 'stretcher', price = 0},
                {name = 'bodybag', price = 0},
                {name = 'bandage', price = 0},
                {name = 'icepack', price = 0},
                {name = 'ointment', price = 0},
                {name = 'defibrilator', price = 0},
                {name = 'splint', price = 0},
                {name = 'suture_kit', price = 0},
                {name = 'morphine', price = 0},
                {name = 'medical_kit', price = 0},
                {name = 'disinfectant', price = 0},
                {name = 'advanced_medical_kit', price = 0},
                {name = 'blood_bag_250', price = 0},
                {name = 'blood_bag_500', price = 0},
                {name = 'antipyretics', price = 0},
                {name = 'painkillers', price = 0},
                {name = 'gauze', price = 5},
                {name = 'adrenaline', price = 10},
                {name = 'cyclonamine', price = 15},
                {name = 'tourniquet', price = 20},
            }
        },
    },

    Garages = {
        ['tstudio_vmc'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(-847.37, -1246.63, 6.91, 45.00),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 10.0,
            vehicles = {
                ['ambulance'] = {
                    label = 'Ambulance',
                    image = 'https://docs.fivem.net/vehicles/ambulance.webp',
                    mods = {
                        [0] = 1,
                    },
                    allowedGrades = {0, 1, 2, 3, 4, 5},
                }
            },
            spawnPoints = {
                vec4(-854.00, -1234.67, 6.91, 325.00),
                vec4(-849.55, -1237.89, 6.91, 323.00),
            }
        },
        ['tstudio_vmc_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(-835.35, -1256.26, 13.13, 319.00),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 15.0,
            vehicles = {
                ['maverick'] = {
                    label = 'Maverick',
                    image = 'https://docs.fivem.net/vehicles/maverick.webp',
                    mods = {
                        [0] = -1,
                    },
                    allowedGrades = {0, 1, 2, 3, 4, 5},
                }
            },
            spawnPoints = {
                vec4(-831.67, -1244.89, 13.13, 0.00),
            }
        },
    },

    Elevators = {
        ['tstudio_vmc'] = {
            {
                coords = vec3(-839.55, -1252.42, 6.98),
                jobRestricted = true,
                floors = {
                    {label = locale('roof'), coords = vec4(-836.9503, -1254.6631, 13.1335, 320.0278)},
                }
            },
            {
                coords = vec3(-837.30, -1255.15, 13.38),
                floors = {
                    {label = locale('hospital'), coords = vec4(-839.06, -1251.77, 6.72, 323.00)},
                }
            },
        },
    }
}