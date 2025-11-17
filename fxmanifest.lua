fx_version 'cerulean'
game 'gta5'

author 'QuanXk5 Development'
description 'Advanced Storage System with Upgrades and Password Protection'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- or '@mysql-async/lib/MySQL.lua'
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'es_extended',
    'oxmysql', -- or 'mysql-async'
    'ox_inventory'
}

lua54 'yes'
