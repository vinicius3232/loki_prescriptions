fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Loki Scripts'
description 'Script for realistic prescriptions'
version '1.0.0'

shared_scripts {
    'config.lua',
    'locales.lua',
    'locales/*.lua',
    -- "@ox_lib/init.lua" -- for ox_lib notify support, uncomment if you want to use it, otherwise not needed
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/custom.lua',
    'server/database.lua',
    'server/server.lua'
}

client_scripts {
    'client/custom.lua',
    'client/client.lua'
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
