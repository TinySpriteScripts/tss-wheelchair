---@type TSSServerModules
local TSS = exports.tss_bridge:GetModules({ 'Inventory', 'Player', 'VehicleKeys' }, Config.TSS)

local resource = GetCurrentResourceName()
local pending = {}  -- [source] = { item, plate, expires } waiting for the client to spawn
local active = {}   -- [source] = { item, plate, netId } currently spawned vehicle

local SPAWN_TIMEOUT = 15000
local MAX_SPAWN_DISTANCE = 15.0

local function debugPrint(...)
    if Config.Debug then print(("^5Debug^7: ^3%s^7:"):format(resource), ...) end
end

local function trim(value)
    return type(value) == 'string' and value:match('^%s*(.-)%s*$') or value
end

-- Builds an 8 character plate: up to 5 prefix letters followed by random digits.
local function makePlate(src)
    local prefix = Config.PlatePrefix
    if not prefix then
        local job = TSS.Player.Job(src)
        prefix = type(job) == 'table' and job.name or 'TSS'
    end
    prefix = tostring(prefix):gsub('[^%w]', ''):sub(1, 5):upper()
    if prefix == '' then prefix = 'TSS' end
    for _ = #prefix + 1, 8 do prefix = prefix .. math.random(0, 9) end
    return prefix
end

local function entityFromNetId(netId)
    if type(netId) ~= 'number' then return nil end
    -- The server can take a moment to learn about a freshly created client entity.
    for _ = 1, 20 do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity ~= 0 and DoesEntityExist(entity) then return entity end
        Wait(100)
    end
    return nil
end

local function vehicleExists(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    return entity ~= 0 and DoesEntityExist(entity), entity
end

---------- / Useable Items
CreateThread(function()
    local items = TSS.Inventory.Items() or {}
    for itemName in pairs(Config.Vehicles) do
        if next(items) and not items[itemName] then
            print(("^1Error^7: ^2Vehicle item ^7'^6%s^7' ^2not found in your items^7"):format(itemName))
        else
            local ok, err = TSS.Inventory.CreateUseableItem(itemName, function(source)
                local current = active[source]
                if current then
                    -- Already has a vehicle out: ask the client to pack it away.
                    TriggerClientEvent(resource .. ':client:Store', source, current.netId, current.item)
                    return
                end
                if pending[source] and pending[source].expires > GetGameTimer() then return end

                local plate = makePlate(source)
                pending[source] = { item = itemName, plate = plate, expires = GetGameTimer() + SPAWN_TIMEOUT }
                debugPrint(("Spawning ^6%s^7 for ^6%s^7 (plate ^6%s^7)"):format(itemName, source, plate))
                TriggerClientEvent(resource .. ':client:Spawn', source, itemName, plate)
            end)
            if not ok then
                print(("^1Error^7: ^2Could not register ^6%s^7 (%s)"):format(itemName, tostring(err)))
            end
        end
    end
end)

-- The client spawned the vehicle; verify it before handing out keys.
RegisterNetEvent(resource .. ':server:Spawned', function(netId)
    local src = source
    local request = pending[src]
    pending[src] = nil
    if not request or request.expires < GetGameTimer() then return end

    local settings = Config.Vehicles[request.item]
    local entity = entityFromNetId(netId)
    if not settings or not entity or GetEntityType(entity) ~= 2 then return end

    local ped = GetPlayerPed(src)
    if GetEntityModel(entity) ~= joaat(settings.Model)
        or trim(GetVehicleNumberPlateText(entity)) ~= request.plate
        or #(GetEntityCoords(entity) - GetEntityCoords(ped)) > MAX_SPAWN_DISTANCE then
        debugPrint(("Rejected spawn report from ^6%s^7"):format(src))
        return
    end

    active[src] = { item = request.item, plate = request.plate, netId = netId }
    TSS.VehicleKeys.Give(src, request.plate)
end)

-- The client packed the vehicle away (or it no longer exists).
RegisterNetEvent(resource .. ':server:Stored', function()
    local src = source
    local current = active[src]
    if not current then return end
    Wait(500) -- let the client deletion reach the server
    -- Only free the slot once the vehicle is really gone, so players can't stack up vehicles.
    if vehicleExists(current.netId) then return end
    active[src] = nil
    TSS.VehicleKeys.Remove(src, current.plate)
end)

AddEventHandler('playerDropped', function()
    local src = source
    pending[src] = nil
    local current = active[src]
    active[src] = nil
    if not current then return end
    local exists, entity = vehicleExists(current.netId)
    if exists then DeleteEntity(entity) end
end)
