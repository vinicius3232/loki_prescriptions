-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

return {
    Hospital = {
        ['energy_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(-1028.4659, -412.5527, 39.6151)
            },
            duty = {
                enabled = true,
                coords = vec4(-1008.56, -419.80, 39.58, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = {
                vec3(-1018.35, -426.94, 39.55),
                vec3(-1016.34, -427.67, 39.57),
            },
            management = {
                coords = vec3(-1006.74, -418.58, 39.55), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['energy_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(-1014.88, -408.44, 40.81), 
                rot = vec3(2.00, -0.00, 27.00),
            },
        },
    },

    CheckIn = {
        ['energy_hospital'] = {
            label = 'Pillbox Hospital',
            coords = vec4(-1012.74, -413.04, 39.62, 25.00),
            driveCoords = vec4(-1046.16, -388.91, 37.63, 292.00), -- optional, if you want ai medic to drive to specific coords before going to bed
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            duration = 5000,
            maxDutyMedics = 2,
            -- hide = true, -- hide in respawn menu [useful for illegal hospitals]
            price = {
                money = 500, -- price in cash
                bank = 500, -- price in bank
                black_money = 500, -- price in black money [if you want to disable some payment method, just remove it from table]
                insurance = true, -- can be used insurance for check-in? [only will work if player own insurance]
            }
        },
    },

    CheckInBeds = {
        ['energy_hospital'] = {
            vec4(-993.66, -424.83, 40.37, 209.00),
            vec4(-991.29, -429.42, 40.37, 31.00),
            vec4(-995.11, -431.30, 40.37, 34.00),
            vec4(-998.89, -433.28, 40.37, 32.00),
            vec4(-1002.49, -435.21, 40.37, 28.00),
            vec4(-1006.23, -437.11, 40.37, 21.00),
            vec4(-1009.82, -432.93, 40.37, 213.00),
        },
    },

    Insurances = {
        ['energy_hospital'] = {
            coords = vec4(-1008.39, -410.90, 39.62, 21.00),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['energy_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(-1013.24, -415.89, 39.62, 305.00),
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
        ['energy_hospital_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(-1029.01, -442.26, 39.62, 32.00),
            ped = 's_m_m_paramedic_01',
            items = {
                {name = 'gauze', price = 50},
                {name = 'adrenaline', price = 100},
                {name = 'bandage', price = 200},
                {name = 'cyclonamine', price = 300},
                {name = 'tourniquet', price = 500},
            }
        },
    },

    Garages = {
        ['energy_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(-1022.75, -418.24, 33.27, 20.00),
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
                vec4(-1019.03, -420.41, 33.27, 22.00),
                vec4(-1015.32, -418.56, 33.27, 32.00),
                vec4(-1011.54, -416.78, 33.27, 26.00),
                vec4(-1007.91, -414.70, 33.27, 32.00),
                vec4(-1004.10, -412.67, 33.27, 33.00),
            }
        },
        ['energy_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(-1031.09, -441.60, 63.21, 24.00),
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
                    extras = {
                        [1] = true,
                        [2] = true,
                    },
                    livery = 1,
                    allowedGrades = {0, 1, 2, 3, 4, 5},
                }
            },
            spawnPoints = {
                vec4(-1028.94, -426.19, 65.06, 0.00),
            }
        },
    },

    Elevators = {}
}