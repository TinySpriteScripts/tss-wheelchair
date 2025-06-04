-- ┌───────────────────┐
-- │    CLIENT.lua     │
-- ├─┬─────────────────┘
-- │ │
-- │ │

local wheelchairs = {}

RegisterNetEvent(GetCurrentResourceName()..":client:wheelchair", function(item)
    local model = Config.WheelchairVeh
    local ped = PlayerPedId()
    local pedId = tostring(ped)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    if not wheelchairs[pedId] then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        while not DoesEntityExist(vehicle) do Wait(0) end

        wheelchairs[pedId] = vehicle

        SetVehicleOnGroundProperly(vehicle)
        local plate = (getPlayer().job:sub(1, 5) .. math.random(100, 999)):upper()
        SetVehicleNumberPlateText(vehicle, plate)
        SetPedIntoVehicle(ped, vehicle, -1)
        SetVehicleFuelLevel(vehicle, 90.0)
        SetModelAsNoLongerNeeded(model)

        TriggerEvent("vehiclekeys:client:SetOwner", plate)
        if isStarted("qs-vehiclekeys") then
            local displayName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            exports['qs-vehiclekeys']:GiveKeys(plate, displayName, true)
        end

    elseif wheelchairs[pedId] and #(GetEntityCoords(wheelchairs[pedId]) - coords) < 3.0 then
        local vehicle = wheelchairs[pedId]

        if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == 0 then
            DeleteVehicle(vehicle)
            wheelchairs[pedId] = nil
        else
            triggerNotify(nil, "Someone is sitting in the chair", "error")
        end
    else
        triggerNotify(nil, "Too far from the chair", "error")
    end
end)
