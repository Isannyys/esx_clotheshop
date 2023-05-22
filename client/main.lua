
local hasAlreadyEnteredMarker, hasPaid, currentActionData = false, false, {}
local lastZone, currentAction, currentActionMsg

function OpenShopMenu()
	local hasPaid = false

	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
		menu.close()

		TriggerEvent('esx_clotheshop:purchasecontext')
		hasPaid = true
	end, function(data, menu)
		menu.close()

		local currentAction = 'shop_menu'
		local currentActionMsg = (Config.TextUI)
		local currentActionData = {}
	end, 
	Config.ClothingOptions
	)
end

RegisterNetEvent('esx_clotheshop:purchasecontext', function(data)
	lib.registerContext({
		id = 'BuyClothes',
		title = (Config.Purchase),
		menu = 'BuyClothes',
		options = {
			{
				title = (Config.Yes),
				arrow = true,
				event = 'esx_clotheshop:event_yes',
			},
			{
				title = (Config.No),
				arrow = false,
				event = 'esx_clotheshop:event_no',
			}
		}
	})
	lib.showContext('BuyClothes')
end)

RegisterNetEvent('esx_clotheshop:event_yes', function()
	ESX.TriggerServerCallback('esx_clotheshop:buyClothes', function(bought)
		if bought then
			lib.notify({title = Config.YouPaid..Config.ClothingPrice, type = 'success'})
			TriggerEvent('skinchanger:getSkin', function(skin)
				TriggerServerEvent('esx_skin:save', skin)
				lib.hideContext(onExit)

				ESX.TriggerServerCallback('esx_clotheshop:checkPropertyDataStore', function(foundStore)
					if foundStore then
						TriggerEvent('esx_clotheshop:savecontext')
					end
				end)
			end)
		else
			lib.notify({title = Config.NotEnoughMoney, type = 'error'})
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
				lib.hideContext(onExit)
			end)
		end
	end)
end)

RegisterNetEvent('esx_clotheshop:event_no', function()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
		lib.hideContext(onExit)
	end)
end)

RegisterNetEvent('esx_clotheshop:savecontext', function(data)
	lib.registerContext({
		id = 'SaveClothes',
		title = (Config.SaveClothes),
		menu = 'SaveClothes',
		options = {
			{
				title = (Config.Yes),
				arrow = true,
				event = 'esx_clotheshop:save_yes',
			},
			{
				title = (Config.No),
				arrow = false,
				event = 'esx_clotheshop:save_no',
			}
		}
	})
	lib.showContext('SaveClothes')
end)

RegisterNetEvent('esx_clotheshop:save_yes', function()
	TriggerEvent('skinchanger:getSkin', function(skin)
		lib.hideContext(onExit)

		local input = lib.inputDialog(Config.NameOutfit, {Config.NameLine})

		if not input then return end
		print(input, input[1])

		TriggerServerEvent('esx_clotheshop:saveOutfit', input[1], skin)
		lib.notify({title = Config.SavedClothes, type = 'success'})
	end)
end)

RegisterNetEvent('esx_clotheshop:save_no', function()
		lib.hideContext(onExit)
end)

AddEventHandler('esx_clotheshop:hasEnteredMarker', function(zone)
	currentAction     = 'shop_menu'
	currentActionMsg  = (Config.TextUI)
	currentActionData = {}
	lib.showTextUI(currentActionMsg)
end)

AddEventHandler('esx_clotheshop:hasExitedMarker', function(zone)
	ESX.CloseContext()
	lib.hideTextUI()
	currentAction = nil

	if not hasPaid then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
	end
end)

CreateThread(function()
	if Config.ShopBlips.UseBlips then
		
	for k,v in ipairs(Config.ClotheShops) do
		local blip = AddBlipForCoord(v)

		SetBlipSprite (blip, Config.ShopBlips.Sprite)
		SetBlipScale (blip, Config.ShopBlips.Scale)
		SetBlipColour (blip, Config.ShopBlips.Color)
		SetBlipDisplay (blip, Config.ShopBlips.Display)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName((Config.BlipName))
		EndTextCommandSetBlipName(blip)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, nil, true

		for k, v in pairs(Config.ClotheShops) do
			local distance = #(playerCoords - v)

			if distance < Config.ClothingZone then
				isInMarker, currentZone = true, k
			end
		end

		if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
			hasAlreadyEnteredMarker, lastZone = true, currentZone
			TriggerEvent('esx_clotheshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_clotheshop:hasExitedMarker', lastZone)
			ESX.UI.Menu.CloseAll()
		end

		if letSleep then
			Wait(500)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)

		if currentAction then

			if IsControlJustReleased(0, 38) then
				if currentAction == 'shop_menu' then
					OpenShopMenu()
				end

			end
		else
			Wait(500)
		end
	end
end)
