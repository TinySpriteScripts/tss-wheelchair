-- TSS-PocketVehicles by [TinySprite](https://tinysprite.dev/) | [Discord](https://discord.gg/ZMFfC54FdJ)
Config = {
    Lan = "en",                 -- "en"
    Debug = false,

    -- Presentation providers used through tss_bridge ("auto" follows the tss_bridge config)
    TSS = {
        Notify = "auto",        -- "auto", "ox", "qb", "okok", "tss", "native", ...
    },

    PickupDistance = 3.0,       -- How close a player must be to pack their vehicle away again
    Fuel = 100.0,               -- Fuel level the vehicle spawns with
    PlatePrefix = nil,          -- nil = first 5 letters of the player's job, or set a fixed prefix e.g. "CHAIR"

    -- [item name] = { Model = vehicle spawned, Label = shown in messages }
    Vehicles = {
        ['wheelchair'] = {
            Model = "iak_wheelchair", -- https://www.gta5-mods.com/vehicles/wheelchair-add-on-sp-fivem
            Label = "Wheelchair",
        },
        ['cruiser'] = {
            Model = "cruiser",
            Label = "Cruiser",
        },
    },
}
