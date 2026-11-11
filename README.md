# |‾‾‾|/‾‾‾\ /‾‾‾\
#   |  \__‾‾\\__‾‾\
#   |   |___/ |___/
# tinysprite.dev

# [`tss-pocketvehicles`] by [TinySprite](https://tinysprite.dev/) | [Discord](https://discord.gg/ZMFfC54FdJ)

Keep a vehicle in your pocket. Wheelchairs, bicycles, scooters or any other vehicle can be tied to an item and taken out or packed away whenever you need it.

---

## 📦 Dependencies
- [tss_bridge](https://github.com/TinySpriteScripts/tss_bridge) (**required**) - handles framework, inventory, notify and vehicle keys
- Any vehicle models you configure, e.g. the [Wheelchair Add-On](https://www.gta5-mods.com/vehicles/wheelchair-add-on-sp-fivem) (`iak_wheelchair`)

Works with any framework and inventory supported by `tss_bridge` (QBCore, Qbox, ESX / qb-inventory, ox_inventory, ...).

---

## 🧰 Installation

> **This script requires [`tss_bridge`](https://github.com/TinySpriteScripts/tss_bridge).** Start your framework and inventory, then `tss_bridge`, then `tss-pocketvehicles`.

1. Place `tss-pocketvehicles` in your `[tinysprite]` folder and make sure it starts after `tss_bridge`:
   ```cfg
   ensure tss_bridge
   ensure [tinysprite]
   ```
2. Add the items to your inventory (examples below). Each item in `Config.Vehicles` must exist as a **useable** item. Copy `install/wheelchair.png` into your inventory's image folder.
3. Adjust `config.lua` - vehicles per item, pickup distance, fuel and plate prefix.

### qb-inventory (`qb-core/shared/items.lua`)
```lua
wheelchair = { name = 'wheelchair', label = 'Wheelchair', weight = 1500, type = 'item', image = 'wheelchair.png', unique = true, useable = true, shouldClose = true, description = 'A wheelchair' },
```

### ox_inventory (`ox_inventory/data/items.lua`)
```lua
['wheelchair'] = { label = 'Wheelchair', weight = 1500, stack = false, close = true, description = 'A wheelchair',
    client = { image = 'wheelchair.png' },
},
```

---

## ✨ Features
- Use the item to take out your vehicle - you are seated in it automatically
- Use it again to pack it away (only when nearby and nobody else is seated)
- Any vehicle can be tied to any item through `Config.Vehicles`
- Vehicle keys given and removed through `tss_bridge` (qb-vehiclekeys, qbx_vehiclekeys)
- Spawns on the ground with full fuel (native, ox_fuel, LegacyFuel, cdn-fuel, ps-fuel, lj-fuel) and a job-based plate
- Server-validated: keys are only handed out for the vehicle the server asked for
- One vehicle out per player, cleaned up when they disconnect

---

## 📜 History
- v1.0.0 - Released as TSS-Wheelchair
- v1.0.3 - Not just wheelchairs: any item → vehicle through config
- v2.0.0 - Renamed from TSS-Wheelchair to TSS-PocketVehicles and converted to `tss_bridge` (multi-framework/inventory, server-side plates and keys, cleanup on disconnect)

---

## 🔧 Support
Need help? Join our Discord: [Join Support Server](https://discord.gg/ZMFfC54FdJ)

**© TinySprite** — Quality resources built for FiveM servers.
