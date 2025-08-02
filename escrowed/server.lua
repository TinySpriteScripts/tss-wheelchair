onResourceStart(function() -- Automate extra shop info (`info`, `type` and `slots`)
    for k in pairs(Shops) do
        Shops[k].slots = #Shops[k].items
        for i = 1, #Shops[k].items do
            Shops[k].items[i].info = Shops[k].items[i].info or {}
            Shops[k].items[i].type = Shops[k].items[i].type or "item"
            Shops[k].items[i].slot = i
        end
    end

	for _, loc in pairs(Locations) do
		if Config.System.debugLocation and _ ~= Config.System.debugLocation then
			goto continue
		end
		if loc.ZoneEnable then
			if loc.Job and not Jobs[loc.Job] then
				print("^1Error^7: ^2Job role not found in server ^7- '^6"..loc.Job.."^7'")
			end
			if loc.Gang and (not Jobs[loc.Gang] and not Gangs[loc.Gang]) then
				print("^1Error^7: ^2Gang role not found in server ^7- '^6"..loc.Gang.."^7'")
			end
			if loc.garage then
				TriggerEvent("jim-jobgarage:server:syncAddLocations", { -- Job Garage creation
					job = loc.Job,
					garage = loc.garage
				})
			end
			if loc.Booth then
				if isStarted("jim-djbooth") then
					TriggerEvent("jim-djbooth:server:AddLocation", { -- DJ Booth Creation
						job = loc.Job,
						enableBooth = loc.Booth.enableBooth,
						DefaultVolume = loc.Booth.DefaultVolume,
						radius = loc.Booth.radius,
						coords = loc.Booth.coords or loc.Booth.soundLoc,
						soundLoc = loc.Booth.soundLoc or loc.Booth.coords
					})
				end
			end
		end
		::continue::
	end
	local itemCheck = {}
	for k, v in pairs(Crafting) do
		for i = 1, #v.Recipes do
			for l, b in pairs(v.Recipes[i]) do
				if l ~= "amount" and l ~= "metadata" then
					if not Items[l] then
						itemCheck["result"] = itemCheck["result"] or {}
						itemCheck.result[l] = true
						--print("^5Debug^7: ^6Crafting^7: ^2Missing Item from ^4Items^7: '^6"..l.."^7'")
					end
					for j, c in pairs(b) do
						if not Items[j] then
							itemCheck["ingredient"] = itemCheck["ingredient"] or {}
							itemCheck.ingredient[j] = true
							--print("^5Debug^7: ^6Crafting^7: ^2Missing Item from ^4Items^7: '^6"..j.."^7'")
						end
					end
				end
			end
		end
	end
	for k, v in pairs(Shops) do
		for i = 1, #v.items do
			if not Items[v.items[i].name] then
				itemCheck["shop"] = itemCheck["shop"] or {}
				itemCheck.shop[v.items[i].name] = true
				--print("^5Debug^7: ^6Store^7: ^2Missing Item from ^4Items^7: '^6"..v.items[i].name.."^7'")
			end
		end
	end
	for k, v in pairs(itemCheck) do
		if k == "result" then
			for l, b in pairs(v) do
				print("^1Error^7: ^2Missing ^3Recipe Item ^2from ^4Items^7: '^6"..l.."^7'")
			end
		end
		if k == "ingredient" then
			for l, b in pairs(v) do
				print("^1Error^7: ^2Missing ^3ingredient Item ^2from ^4Items^7: '^6"..l.."^7'")
			end
		end
		if k == "shop" then
			for l, b in pairs(v) do
				print("^1Error^7: ^2Missing ^3Shop Item ^2from ^4Items^7: '^6"..l.."^7'")
			end
		end
	end

	for k in pairsByKeys(Locations) do
		if Config.System.debugLocation and k ~= Config.System.debugLocation then
			goto continue
		end
		if Locations[k].ZoneEnable then
			if Locations[k].blip or Locations[k].Blip then
				if isStarted("jim-blipcontroller") and Config.blipController and Config.blipController.enable and Config.blipController.onDutyBlips then
					local blipInfo = Locations[k].blip or Locations[k].Blip
					exports["jim-blipcontroller"]:addDutyBlip({
						label = Locations[k].label,
						coords = blipInfo.coords,
						col = blipInfo.blipcolor,
						sprite = blipInfo.blipsprite,
						scale = blipInfo.blipscale,
						disp = blipInfo.blipcat
					},
					Locations[k].job or Locations[k].gang)
				end
			end
			for v in pairsByKeys(Locations[k]) do

				if v == "Stash" then
					for i = 1, #Locations[k].Stash do
						local info = Locations[k].Stash[i]
						--debugPrint("^2Registering ^3"..k.." ^1Job^2 Stash^7 - ^5id^7: "..info.stashName.." ^5Label^7: '"..info.stashLabel.."^7' - ^5Slots^7: "..(info.slots or "50").." ^5Weight^7: "..(info.maxWeight and (info.maxWeight / 100).."kg" or "4000.0kg").."^7")
						registerStash(info.stashName, info.stashLabel..(debugMode and " ["..info.stashName.."]" or "")..((Locations[k].StashCraft and Locations[k].StashCraft == info.stashName) and " - Crafting Stash" or ""), info.slots, info.maxWeight)
					end
				end
				if v == "PublicStash" then
					for i = 1, #Locations[k].PublicStash do
						local info = Locations[k].PublicStash[i]
						--debugPrint("^2Registering ^3"..k.." ^4Public^2 Stash^7 - ^5id^7: "..info.stashName.." ^5Label^7: '"..info.stashLabel.."^7' - ^5Slots^7: "..(info.slots or "50").." ^5Weight^7: "..(info.maxWeight and (info.maxWeight / 100).."kg" or "4000.0kg").."^7")
						registerStash(info.stashName, info.stashLabel..(debugMode and " ["..info.stashName.."]" or ""), info.slots, info.maxWeight)
					end
				end
				if v == "PlayerStash" then
					for i = 1, #Locations[k].PlayerStash do
						local info = Locations[k].PlayerStash[i]
						--debugPrint("^2Registering ^3"..k.." ^4Public^2 Stash^7 - ^5id^7: "..info.stashName.." ^5Label^7: '"..info.stashLabel.."^7' - ^5Slots^7: "..(info.slots or "50").." ^5Weight^7: "..(info.maxWeight and (info.maxWeight / 100).."kg" or "4000.0kg").."^7")
						registerStash(info.stashName, info.stashLabel..(debugMode and " ["..info.stashName.."]" or ""), info.slots, info.maxWeight)
					end
				end
				if v == "Fence" then
					for i = 1, #Locations[k].Fence do
						local info = Locations[k].Fence[i]
						--debugPrint("^2Registering ^3"..k.." ^1Job^2 Stash^7 - ^5id^7: "..info.stashName.." ^5Label^7: '"..info.stashLabel.."^7' - ^5Slots^7: "..(info.slots or "50").." ^5Weight^7: "..(info.maxWeight and (info.maxWeight / 100).."kg" or "4000.0kg").."^7")
						registerStash(info.stashName, info.stashLabel..(debugMode and " ["..info.stashName.."]" or "")..((Locations[k].StashCraft and Locations[k].StashCraft == info.stashName) and " - Crafting Stash" or ""), info.slots, info.maxWeight)
					end
				end
				if v == "BossStash" then
					for i = 1, #Locations[k].BossStash do
						local info = Locations[k].BossStash[i]
						--debugPrint("^2Registering ^3"..k.." ^6Boss^2 Stash^7 - ^5id^7: "..info.stashName.." ^5Label^7: '"..info.stashLabel.."^7' - ^5Slots^7: "..(info.slots or "50").." ^5Weight^7: "..(info.maxWeight and (info.maxWeight / 100).."kg" or "4000.0kg").."^7")
						registerStash(info.stashName, info.stashLabel..(debugMode and " ["..info.stashName.."]" or ""), info.slots, info.maxWeight)
					end
				end
				if v == "TrashStash" then
					for i = 1, #Locations[k].TrashStash do
						local info = Locations[k].TrashStash[i]
						clearStash(info.stashName) -- Clear Trash Stash on resource start
						--debugPrint("^2Registering ^3"..k.." ^6Boss^2 Stash^7 - ^5id^7: "..info.stashName.." ^5Label^7: '"..info.stashLabel.."^7' - ^5Slots^7: "..(info.slots or "50").." ^5Weight^7: "..(info.maxWeight and (info.maxWeight / 100).."kg" or "4000.0kg").."^7")
						registerStash(info.stashName, info.stashLabel..(debugMode and " ["..info.stashName.."]" or ""), info.slots, info.maxWeight)
					end
				end
				if v == "Shop" then
					for i = 1, #Locations[k].Shop do
						--debugPrint("^2Registering ^3"..k.." ^5Shop^7 - ^5id^7: "..Locations[k].Shop[i].shopName.." ^5Label^7: '"..Locations[k].Shop[i].items.label.."^7'")
						registerShop(Locations[k].Shop[i].shopName, Locations[k].Shop[i].items.label, Locations[k].Shop[i].items.items, Locations[k].Shop[i].items.society)
					end
				end
			end
		end
		::continue::
	end
end, true)

onResourceStop(function()
	for k, v in pairs(Locations) do
		if Locations[k].Booth and Locations[k].Booth.playing then
			local zoneLabel = Locations[k].label..k
			xSound:Destroy(-1, zoneLabel)
		end
	end
end, true)

RegisterNetEvent(getScript()..":server:StashPropHandle", function(target, data, remove)
	TriggerClientEvent(getScript()..":client:StashPropHandle", -1, target, data, remove)
end)

RegisterNetEvent(getScript()..":server:setStashMetaData", function(data)
	--jsonPrint(data)
	exports[OXInv]:SetMetadata(data.stash, data.slot, data.metadata)
end)
