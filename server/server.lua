-- ┌───────────────────┐
-- │    SERVER.lua     │
-- ├─┬─────────────────┘
-- │ │
-- │ │

onResourceStart(function()
    createUseableItem(Config.WheelchairItem, function(source, item)
        TriggerClientEvent(getScript()..":client:wheelchair", source)
    end)
end, true)