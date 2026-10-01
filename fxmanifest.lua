fx_version 'cerulean'
game 'gta5'

author 'SzCode / SzCore'
description 'SzCore character selector and creator'
version '1.4.0-rc1'

shared_script '@szcore/shared/config.lua'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
    'szcore'
}
