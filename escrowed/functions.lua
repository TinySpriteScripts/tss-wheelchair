-- ┌─────────────────────┐
-- │    FUNCTIONS.lua    │
-- ├─┬───────────────────┘
-- │ │
-- │ │
local TSSDiscord = GetResourceMetadata(getScript(), "discord") or "No Discord Link Set"
print("^2TinySpriteScripts^7 - " .. TSSDiscord)
local Bikes = {}

function CreateZoneAndProps(name, coords, radius, l, w, heading, minZ, maxZ, model1, model2, type, options, props, peds)

	if type == "box" then createBoxTarget({ name, coords, l, w, { name=name, heading=heading, debugPoly=debugMode, minZ=minZ, maxZ=maxZ }}, options, 2.0)
	elseif type == "circle" then createCircleTarget({ name, coords, radius }, options, 2.0)
	elseif type == "model" then createModelTarget({ model1, model2 }, options, 2.0) end

	if props then
		for _, prop in pairs(props) do							 
			makeDistProp({
                prop = prop.model, 
                coords = prop.coords
            }, 
                true,   -- freeze
                false   -- synced
            )
		end
	end

    if peds then
		for _, ped in pairs(peds) do
			makeDistPed(
                ped.model,
                ped.coords, 
                true,	-- freeze
                false,	-- collision
                ped.scenario or "WORLD_HUMAN_STAND_IMPATIENT", 
                ped.anim or nil, 
                false	-- synced
            )
		end
	end
end

-- ┌──────────────┐
-- │    DEBUG     │
-- └──────────────┘

function Debug(data)
    if Config.System.Debug then
        if data then print(data) end
        return true
    end
    return false
end

function OnPlayerLoaded()
    TriggerServerEvent(getScript()..":Server:OnPlayerLoaded")
end

function ClientPrint(columns, title, ...)
	if Debug() then 
		local boxWidth = 60
		local function textLength(text) return #text:gsub("%^%d", "") end

		local function centerText(text, width)
			local length = textLength(text)
			local padding = math.floor((width - length) / 2)
			return string.rep(" ", padding) .. text .. string.rep(" ", width - padding - length)
		end

		print("┌" .. string.rep("─", boxWidth) .. "┐")
		print("│" .. centerText(title, boxWidth) .. "│")
		print("│" .. string.rep(" ", boxWidth) .. "│")

		local args = {...}
		for i = 1, #args, columns do
			local lineText = ""
			for j = 0, columns - 1 do
				local argIndex = i + j
				if args[argIndex] then
					local text = args[argIndex]
					local color = "^7"
					if type(text) == "table" then color = text.color or "^7" text = text.text or "" end
					lineText = lineText .. color .. text .. " "
				end
			end
			print("^7│" .. centerText(lineText, boxWidth) .. "^7│")
		end
		print("^7└" .. string.rep("─", boxWidth) .. "┘^7")
	end
end

-- ┌───────────────────────────────┐
-- │    INVENTORY SLOT CHECKER     │
-- └───────────────────────────────┘

local inventoryCheckCallbacks = {}

RegisterNetEvent(getScript()..":Client:InventorySlotsChecked", function(id, canCarry)
    if inventoryCheckCallbacks[id] then
        inventoryCheckCallbacks[id](canCarry)
        inventoryCheckCallbacks[id] = nil
    end
end)

-- Function to check if the player has at least 4 free inventory slots
function HasFreeInventorySlots(requiredSlots, callback)
    local id = tostring(math.random(100000, 999999))
    inventoryCheckCallbacks[id] = callback
    TriggerServerEvent(getScript()..":Server:CheckInventorySlots", id, requiredSlots)
end

function GetBike(data)
    local Bike = GetHashKey(data.Bike)
    RequestModel(Bike) while not HasModelLoaded(Bike) do Wait(2) end 
    Bikes[#Bikes+1] = CreateVehicle(Bike, data.Coords,false,false,false)
    SetModelAsNoLongerNeeded(Bike)
    SetEntityAsMissionEntity(Bikes[#Bikes], true, true)
    SetVehicleOnGroundProperly(Bikes[#Bikes])
    SetEntityInvincible(Bikes[#Bikes], data.Invincible)
    SetVehicleDirtLevel(Bikes[#Bikes], 0.0)
    SetVehicleDoorsLocked(Bikes[#Bikes], 3)
    SetEntityHeading(Bikes[#Bikes], data.Head-180) 
    SetVehicleCustomPrimaryColour(Bikes[#Bikes], data.Red, data.Green, data.Blue)
    SetVehicleCustomSecondaryColour(Bikes[#Bikes], data.Red, data.Green, data.Blue)
    SetVehicleExtraColours(Bikes[#Bikes], 1, 1)
    FreezeEntityPosition(Bikes[#Bikes], data.Freeze)
    SetVehicleNumberPlateText(Bikes[#Bikes], data.Plate)
end

LoadDict = function(Dict) while not HasAnimDictLoaded(Dict) do  Wait(0) RequestAnimDict(Dict) end end

function GetDance(data)
    local ped = PlayerPedId()
	LoadDict(data.Dict..data.Pole)
	local scene = NetworkCreateSynchronisedScene(vector3(data.LocoX, data.LocoY, data.LocoZ), vector3(0.0, 0.0, 0.0), 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene, data.Dict..data.Pole, data.Anim..data.Pole, 1.5, -4.0, 1, 1, 1148846080, 0)
    NetworkStartSynchronisedScene(scene)
end


-- ┌───────────────┐
-- │    FOOTER     │
-- └───────────────┘
AddEventHandler('onResourceStop', function(resource) if resource ~= getScript() then return end
    for k,v in pairs(Bikes) do DeleteVehicle(v) end
end)