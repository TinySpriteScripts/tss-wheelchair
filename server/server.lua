-- ┌───────────────────┐
-- │    SERVER.lua     │
-- ├─┬─────────────────┘
-- │ │
-- │ │

createUseableItem(Config.WheelchairItem, function(source, item)
    TriggerClientEvent(GetCurrentResourceName()..":client:wheelchair", source)
end)
