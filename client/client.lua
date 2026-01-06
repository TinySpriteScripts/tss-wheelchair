-- ┌───────────────────┐
-- │    CLIENT.lua     │
-- ├─┬─────────────────┘
-- │ │
-- │ │

local spawnedVehicles = {}

RegisterNetEvent(getScript()..":client:usedVehicleItem", function(item)
    local settings = Config.Vehicles[item]
    if not settings then print("no such item configured ["..item.."]") return end
    local model = settings.Model
    local ped = PlayerPedId()
    local pedId = tostring(ped)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local fail_timer = 0

    if not spawnedVehicles[pedId] then
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        while not DoesEntityExist(vehicle) do 
            fail_timer = fail_timer + 1
            if fail_timer >= 5000 then print("vehicle failed to load") return end
            Wait(1) 
        end

        spawnedVehicles[pedId] = vehicle

        SetVehicleOnGroundProperly(vehicle)
        local plate = (getPlayer().job:sub(1, 5) .. math.random(100, 999)):upper()
        SetVehicleNumberPlateText(vehicle, plate)
        SetPedIntoVehicle(ped, vehicle, -1)
        SetVehicleFuelLevel(vehicle, 99.0)
        SetModelAsNoLongerNeeded(model)

        TriggerEvent("vehiclekeys:client:SetOwner", plate)
        if isStarted("qs-vehiclekeys") then
            print("qs-vehiclekeys detected, we don't support creators who steal code.")
        end

    elseif spawnedVehicles[pedId] then
        local vehicle = spawnedVehicles[pedId]

        if DoesEntityExist(vehicle) then
            if #(GetEntityCoords(spawnedVehicles[pedId]) - coords) < 3.0 then
                if GetPedInVehicleSeat(vehicle, -1) == 0 then
                    DeleteVehicle(vehicle)
                    spawnedVehicles[pedId] = nil
                else
                    triggerNotify(nil, "Someone is seated", "error")
                end
            else
                triggerNotify(nil, "Too far", "error")
            end
        else
            triggerNotify(nil, "Vehicle no longer exists", "error")
            spawnedVehicles[pedId] = nil
        end
    end
end)
