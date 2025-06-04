fx_version "cerulean"
game "gta5"
lua54 'yes'

name "TSS-Wheelchair"
author "TinySpriteScripts"
description "Use of Wheelchairs"
version "1.0"
discord "https://discord.gg/ZMFfC54FdJ"
tebex "https://tinyspritescripts.tebex.io/"

dependency 'jim_bridge' -- https://github.com/jimathy/jim_bridge

shared_scripts {
	'locales/*.lua',
    'config.lua',
    -- Required scripts
    '@jim_bridge/starter.lua', -- https://github.com/jimathy/jim_bridge
}

client_scripts { 'client/*.lua', }

server_scripts { 
    '@oxmysql/lib/MySQL.lua',
    'shared/serverfunctions.lua',
    'server/*.lua',
}

dependency '/assetpacks'