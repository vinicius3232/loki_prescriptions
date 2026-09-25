-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

return {
    Hospital = {
        ['thunder_medicalcenter'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(1151.13, -1529.12, 34.23),
            },
            duty = {
                enabled = true,
                coords = vec4(1137.10, -1536.30, 35.29, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(1151.64, -1583.56, 35.19),
            management = {
                coords = vec3(1139.34, -1545.59, 35.34), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['thunder_medicalcenter'] = {
            ['Entrance TV'] = {
                coords = vec3(1146.43, -1529.03, 35.81), 
                rot = vec3(0.00, -0.00, 0.00),
            },
        },
    },

    CheckIn = {
        ['thunder_medicalcenter'] = {
            label = 'El Burro Heights Hospital',
            coords = vec4(1141.34, -1538.10, 35.38, 310.00),
            driveCoords = vec4(1153.51, -1513.19, 34.69, 272.00), -- optional, if you want ai medic to drive to specific coords before going to bed
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
        ['thunder_medicalcenter'] = {
            vec4(1121.60, -1553.59, 35.90, 177.00),
            vec4(1124.44, -1553.73, 35.90, 188.00),
            vec4(1127.30, -1553.70, 35.90, 183.00),
            vec4(1126.44, -1562.23, 35.90, 0.00),
            vec4(1123.69, -1562.25, 35.90, 0.00),
            vec4(1120.99, -1562.28, 35.90, 0.00),
        },
    },

    Insurances = {
        ['thunder_medicalcenter'] = {
            coords = vec4(1138.36, -1535.40, 35.38, 331.00),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['thunder_medicalcenter'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(1135.59, -1564.57, 35.38, 91.00),
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
        ['thunder_medicalcenter_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(1148.04, -1552.39, 35.38, 48.00),
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
        ['thunder_medicalcenter'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(1175.25, -1549.98, 34.79, 87.00),
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
                vec4(1177.04, -1545.11, 34.69, 0.00),
                vec4(1180.78, -1545.13, 34.69, 0.00),
                vec4(1184.18, -1545.26, 34.69, 0.00),
                vec4(1187.65, -1545.14, 34.69, 0.00),
            }
        },
    },

    Elevators = {}
}