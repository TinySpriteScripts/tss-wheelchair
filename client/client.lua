---@type TSSClientModules
local TSS = exports.tss_bridge:GetModules({ 'Vehicles', 'Notify' }, Config.TSS)

local resource = GetCurrentResourceName()
local busy = false

local function L(section, key)
    local lang = Loc[Config.Lan] or Loc.en
    return lang[section] and lang[section][key] or key
end

local function notify(section, key, label, kind)
    TSS.Notify.Send({ message = L(section, key):format(label or ''), type = kind or section })
end

local function labelOf(item)
    local settings = Config.Vehicles[item]
    return settings and settings.Label or item
end

local function setFuel(vehicle, level)
    SetVehicleFuelLevel(vehicle, level)
    Entity(vehicle).state:set('fuel', level, true) -- ox_fuel
    for _, fuel in ipairs({ 'LegacyFuel', 'cdn-fuel', 'ps-fuel', 'lj-fuel' }) do
        if GetResourceState(fuel) == 'started' then
            pcall(function() exports[fuel]:SetFuel(vehicle, level) end)
            break
        end
    end
end

-- Sent by the server when a player without a vehicle out uses a vehicle item.
RegisterNetEvent(resource .. ':client:Spawn', function(item, plate)
    local settings = Config.Vehicles[item]
    if not settings then return notify('error', 'notconfigured', nil, 'error') end
    if busy then return notify('error', 'busy', nil, 'error') end
    busy = true

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = TSS.Vehicles.Create({
        model = settings.Model,
        coords = vector4(coords.x, coords.y, coords.z, GetEntityHeading(ped)),
    }, nil, { fade = false })

    if not vehicle or not DoesEntityExist(vehicle) then
        busy = false
        return notify('error', 'spawnfailed', settings.Label, 'error')
    end

    -- Wait for the vehicle to be networked so the server can verify it.
    local timeout = GetGameTimer() + 5000
    while not NetworkGetEntityIsNetworked(vehicle) and GetGameTimer() < timeout do Wait(0) end

    SetVehicleNumberPlateText(vehicle, plate)
    setFuel(vehicle, Config.Fuel + 0.0)
    SetPedIntoVehicle(ped, vehicle, -1)

    TriggerServerEvent(resource .. ':server:Spawned', NetworkGetNetworkIdFromEntity(vehicle))
    notify('success', 'spawned', settings.Label)
    busy = false
end)

-- Sent by the server when a player who already has a vehicle out uses the item again.
RegisterNetEvent(resource .. ':client:Store', function(netId, item)
    local label = labelOf(item)
    local vehicle = NetworkDoesNetworkIdExist(netId) and NetToVeh(netId) or 0

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify('info', 'gone', label)
        TriggerServerEvent(resource .. ':server:Stored')
        return
    end

    local ped = PlayerPedId()
    if #(GetEntityCoords(vehicle) - GetEntityCoords(ped)) > Config.PickupDistance then
        return notify('error', 'toofar', label, 'error')
    end

    -- Allow the owner to pack it away while sitting in it, but not with anyone else on board.
    for seat = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        local occupant = GetPedInVehicleSeat(vehicle, seat)
        if occupant ~= 0 and occupant ~= ped then
            return notify('error', 'seated', label, 'error')
        end
    end

    if GetVehiclePedIsIn(ped, false) == vehicle then
        TaskLeaveVehicle(ped, vehicle, 16) -- 16 = teleport out
        Wait(100)
    end

    if not NetworkHasControlOfEntity(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = GetGameTimer() + 2000
        while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do Wait(0) end
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    TSS.Vehicles.Delete(vehicle)
    TriggerServerEvent(resource .. ':server:Stored')
    notify('success', 'stored', label)
end)
