-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

return {
    Hospital = {
        ['ocean_medical_center'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(-1860.0563, -350.5019, 49.3767)
            },
            duty = {
                enabled = true,
                coords = vec4(-1852.96, -336.80, 49.36, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(-1814.03, -353.31, 49.55),
            management = {
                coords = vec3(-1850.66, -338.46, 49.35), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['ocean_medical_center'] = {
            ['Entrance TV'] = {
                coords = vec3(-1854.12, -349.88, 50.48), 
                rot = vec3(2.00, -0.00, 154.00),
            },
        },
    },

    CheckIn = {
        ['ocean_medical_center'] = {
            label = 'Pillbox Hospital',
            coords = vec4(-1851.41, -339.37, 49.44, 170.00),
            driveCoords = vec4(-1862.3031, -351.1439, 49.2542, 63.7404), -- optional, if you want ai medic to drive to specific coords before going to bed
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
        ['ocean_medical_center'] = {
            vec4(-1865.76, -332.13, 50.17, 322.00),
            vec4(-1868.59, -329.94, 50.17, 331.00),
            vec4(-1865.74, -325.49, 50.17, 150.00),
            vec4(-1872.29, -326.85, 50.17, 324.00),
            vec4(-1868.79, -323.09, 50.17, 153.00),
            vec4(-1875.22, -324.71, 50.17, 328.00),
            vec4(-1871.95, -320.58, 50.17, 152.00),
        },
    },

    Insurances = {
        ['ocean_medical_center'] = {
            coords = vec4(-1854.03, -336.63, 49.45, 122.00),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['ocean_medical_center'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(-1843.13, -356.52, 49.43, 33.00),
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
        ['ocean_medical_center_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(-1833.44, -384.86, 49.39, 41.00),
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
        ['ocean_medical_center'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(-1888.53, -343.30, 49.41, 49.00),
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
                vec4(-1891.02, -340.57, 49.22, 322.00),
                vec4(-1893.98, -337.85, 49.22, 314.00),
                vec4(-1896.92, -335.52, 49.23, 320.00),
                vec4(-1899.97, -333.11, 49.23, 326.00),
            }
        },
        ['ocean_medical_center_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(-1876.71, -352.93, 58.05, 298.00),
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
                vec4(-1867.16, -352.57, 58.07, 0.00),
            }
        },
    },

    Elevators = {}
}