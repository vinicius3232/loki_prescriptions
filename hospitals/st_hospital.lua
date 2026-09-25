-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

return {
    Hospital = {
        ['st_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(1151.6356, -1522.5471, 34.8434),
            },
            duty = {
                enabled = false,
                coords = vec3(1143.5797, -1542.2646, 35.0327),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(1138.6316, -1538.1908, 35.0327),
            management = {
                coords = vec3(1118.5719, -1564.3008, 39.5036), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {12, 13} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['st_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(1149.7705, -1540.2498, 35.8),
                rot = vec3(7.00, 0.00, 256.00)
            },
        },
    },

    CheckIn = {
        ['st_hospital'] = {
            label = 'St Fiacre Hospital',
            coords = vec4(1123.4321, -1530.6240, 35.0327, 355.5858),
            driveCoords = vec4(1129.8717, -1552.5981, 35.7389, 180.5243), -- optional, if you want ai medic to drive to specific coords before going to bed
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
        ['st_hospital'] = {
            vec4(1129.6039, -1552.3583, 35.7389, 179.2730),
            vec4(1124.7445, -1554.7224, 35.9583, 184.3055),
            vec4(1121.2377, -1554.6732, 35.9583, 195.9555),
            vec4(1117.7406, -1554.6533, 35.9583, 189.5894),
            vec4(1118.0461, -1563.0457, 35.9583, 8.6322),
            vec4(1121.3431, -1563.0864, 35.9583, 348.4404),
            vec4(1124.8201, -1563.1167, 35.9583, 359.3209),
        },
    },

    Insurances = {
        ['st_hospital'] = {
            coords = vec4(1146.0883, -1540.3732, 35.0327, 303.2739),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['st_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(1135.7147, -1542.9255, 35.0327, 180.2431),
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
        ['st_hospital_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(1141.7877, -1529.8796, 35.0327, 97.7012),
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
        ['st_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(1128.7922, -1579.6775, 34.8640, 184.7221),
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
                vec4(1129.2037, -1584.7091, 34.7206, 272.6064),
                vec4(1129.6564, -1587.5389, 34.7206, 275.9036),
                vec4(1129.6638, -1590.7584, 34.7206, 264.4355),
            }
        },
    },

    Elevators = {}
}
