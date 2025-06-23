-- ┌───────────────────┐
-- │    SERVER.lua     │
-- ├─┬─────────────────┘
-- │ │
-- │ │

onResourceStart(function()
    createUseableItem(Config.WheelchairItem, function(source, item)
        TriggerClientEvent(GetCurrentResourceName()..":client:wheelchair", source)
    end)
end, true)