-- ┌───────────────────┐
-- │    SERVER.lua     │
-- ├─┬─────────────────┘
-- │ │
-- │ │

onResourceStart(function()
    for k in pairs(Config.Vehicles) do
        createUseableItem(k, function(source, item)
            TriggerClientEvent(getScript()..":client:usedVehicleItem", source, k)
        end)
    end
end, true)