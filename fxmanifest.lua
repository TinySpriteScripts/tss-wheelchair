fx_version "cerulean"
game "gta5"
lua54 'yes'

name "TSS-Wheelchair"
author "TinySprite-Scripts"
description "Use of Wheelchairs"
version "1.0.2"
discord "https://discord.gg/ZMFfC54FdJ"
tebex "https://tinysprite-scripts.tebex.io/"

dependency 'jim_bridge' -- https://github.com/jimathy/jim_bridge

shared_scripts {
	'locales/*.lua',
    'config.lua',
    -- 'locations/*.lua',
    'escrowed/functions.lua',
    -- Required scripts
    '@jim_bridge/starter.lua',
}

client_scripts { 'client/*.lua', }

server_scripts { '@oxmysql/lib/MySQL.lua', 'server/*.lua', 'escrowed/serverfunctions.lua' }

-- files {
--     'html/index.html', 'html/*.js', 'html/*.css',
-- }

-- ui_page "html/index.html"

escrow_ignore {
    'client/*.lua*',
    'html/**',
    'Install/**',
    'locales/*.lua*',
    'locations/*.lua',
    'server/*.lua*',
    'config.lua',
}

dependency '/assetpacks'