fx_version 'cerulean'

game 'gta5'

description 'ESX Clothes Shop to work with ox library'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	'esx_skin',
	'ox_lib'
}
