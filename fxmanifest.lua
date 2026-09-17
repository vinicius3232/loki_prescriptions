fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Loki Scripts & Vinicius'
description 'Sistema Avançado de Prescrições Médicas e Farmacologia'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales.lua',
    'locales/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/custom.lua',
    'server/database.lua',
    'server/server.lua',
    'server/medicine_consumer.lua'
}

client_scripts {
    'client/custom.lua',
    'client/client.lua',
    'client/medicine_effects.lua'
}

ui_page {
    'web/build/index.html'
}

files {
    'web/build/app.js',
    'web/build/index.html',
    'web/build/style.css',
    'web/build/assets/*.*',
}