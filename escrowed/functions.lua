-- ┌─────────────────────┐
-- │    FUNCTIONS.lua    │
-- ├─┬───────────────────┘
-- │ │
-- │ │
local TSSDiscord = GetResourceMetadata(GetCurrentResourceName(), "discord") or "No Discord Link Set"
print("^2TinySpriteScripts^7 - " .. TSSDiscord)
local Props, peds, Bikes = {}, {}, {}

function CreateZoneAndProps(name, coords, l, w, heading, minZ, maxZ, options, props)
	createBoxTarget({ name, coords, l or 0.8, w or 0.8, { name=name, heading=heading, debugPoly=debugMode, minZ=minZ, maxZ=maxZ } }, options, 2.0)
	if props then
		for _, prop in pairs(props) do
			GetProp({ Prop = prop.model, Coords = prop.coords.xyz, Head = prop.coords.w })
		end
	end
end

function Debug(data)
    if Config.System.Debug then
        if data then print(data) end
        return true
    end
    return false
end

function OnPlayerLoaded()
    TriggerServerEvent(GetCurrentResourceName()..":Server:OnPlayerLoaded")
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

function hasItem(itemName, requiredQuantity)
    local itemCount = exports.ox_inventory:Search('count', itemName)
    return itemCount >= (requiredQuantity or 1)
end

function MKProgress(data)
    local result = nil
    local options = {
        label = data.Label or "Processing... ...",
        duration = Debug() and 500 or data.Time or 5000,
        position = data.Position or "bottom",
        useWhileDead = data.WhileDead or false,
        canCancel = data.CanCancel or true,
        disable = {
            move = data.DisMovement or false,
            car = data.DisCarMovement or false,
            combat = data.DisCombat or false,
            mouse = data.DisMouse or false
        },
        anim = (data.Dict and data.Anim) and {
            dict = data.Dict,
            clip = data.Anim,
            flag = data.Flag or 49
        } or nil,
    }
    if data.Prop and data.Prop.Model then
        options.prop = {
            model = data.Prop.Model,
            pos = data.Prop.Pos or vec3(0, 0, 0),
            rot = data.Prop.Rot or vec3(0, 0, 0),
            bone = data.Prop.Bone or 0
        }
    end
    if data.PropTwo and data.PropTwo.Model then
        options.propTwo = {
            model = data.PropTwo.Model,
            pos = data.PropTwo.Pos or vec3(0, 0, 0),
            rot = data.PropTwo.Rot or vec3(0, 0, 0),
            bone = data.PropTwo.Bone or 0
        }
    end
    if data.ProgressType == "circle" then result = lib.progressCircle(options)
    elseif data.ProgressType == "bar" then result = lib.progressBar(options)
    else
        print("^1[MKProgress] Invalid ProgressType specified. Defaulting to circle.^0")
        result = lib.progressCircle(options)
    end
    return result
end

function GetPed(data)
    RequestModel(data.Model) while not HasModelLoaded(data.Model) do Wait(0) end
    peds[#peds+1] = CreatePed(0, data.Model, data.Coords.x, data.Coords.y, data.Coords.z-0.9, data.Head, false, false)
    SetEntityInvincible(peds[#peds], data.Invincible)
    SetBlockingOfNonTemporaryEvents(peds[#peds], true)
    FreezeEntityPosition(peds[#peds], data.Freeze)
    TaskStartScenarioInPlace(peds[#peds], data.Scenario, 0, true)
    Debug(string.format(Loc[Config.Lan].clientdebug["debug1"], data.Label, data.Coords))
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

function GetBlip(data)
    blip = AddBlipForCoord(data.Coords)
    SetBlipAsShortRange(blip, true)
    SetBlipSprite(blip, data.Sprite or 226)
    SetBlipColour(blip, data.Color or 69)
    SetBlipScale(blip, data.Scale or 0.5)
    SetBlipDisplay(blip, data.Display or 4)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.Label)
    EndTextCommandSetBlipName(blip)
    Debug(string.format(Loc[Config.Lan].clientdebug["debug2"], data.Label))
end

function GetProp(data)
    RequestModel(data.Prop) while not HasModelLoaded(data.Prop) do Wait(2) end 
    Props[#Props+1] = CreateObject(data.Prop, data.Coords,false,false,false)
    SetEntityHeading(Props[#Props], data.Head-180) 
    FreezeEntityPosition(Props[#Props], true)
end


function RemoveProp()
    for _, v in pairs(GetGamePool("CObject")) do
        if IsEntityAttachedToEntity(cache.ped, v) then
          SetEntityAsMissionEntity(v, true, true)
          DeleteObject(v)
          DeleteEntity(v)
        end
    end
end


function Notify(title, description, type)
    if IsDuplicityVersion() then
        local src = source
        if src == 0 then
            print(("[%s] %s: %s"):format(type:upper(), title or "Notification", description))
        else
            TriggerClientEvent(GetCurrentResourceName()..":Client:Notify", src, title, description, type)
        end
    else
        lib.notify({ title = title or nil, description = description or "No description provided", type = type or "inform" })
    end
end

RegisterNetEvent(GetCurrentResourceName()..":Client:Notify", function(title, description, type)
    Notify(title, description, type)
end)

-- ┌───────────────────────────────┐
-- │    INVENTORY SLOT CHECKER     │
-- └───────────────────────────────┘

local inventoryCheckCallbacks = {}

RegisterNetEvent(GetCurrentResourceName()..":Client:InventorySlotsChecked", function(id, canCarry)
    if inventoryCheckCallbacks[id] then
        inventoryCheckCallbacks[id](canCarry)
        inventoryCheckCallbacks[id] = nil
    end
end)

-- Function to check if the player has at least 4 free inventory slots
function HasFreeInventorySlots(requiredSlots, callback)
    local id = tostring(math.random(100000, 999999))
    inventoryCheckCallbacks[id] = callback
    TriggerServerEvent(GetCurrentResourceName()..":Server:CheckInventorySlots", id, requiredSlots)
end


-- ┌───────────────┐
-- │    FOOTER     │
-- └───────────────┘
AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
	for k,v in pairs(Props) do DeleteObject(v) end
    for k,v in pairs(peds) do DeletePed(v) end
    for k,v in pairs(Bikes) do DeleteVehicle(v) end
end)