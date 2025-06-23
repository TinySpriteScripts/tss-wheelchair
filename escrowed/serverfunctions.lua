
function MakeStash(data)
	local id = data.id
	local label = data.label
	local slots = data.slots or 20
	local maxWeight = data.maxWeight or 400000
	local owner = data.owner or nil
	local groups = data.groups or nil
	local coords = data.coords or nil
	exports.ox_inventory:RegisterStash(id, label, slots, maxWeight, owner, groups, coords)
	Debug("^5Debug^7: ^3Registering ^2Stash^7: ^3", id, label, slots, maxWeight, owner, groups, coords)
end


function GetStashItems(stashId)
	local items = {}
	local result = MySQL.Sync.fetchScalar('SELECT items FROM stashitems WHERE stash = ?', {stashId})
	if result then
		local stashItems = json.decode(result)
		if stashItems then
			for k, item in pairs(stashItems) do
				local itemInfo = Core.Shared.Items[item.name:lower()]
				if itemInfo then
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"],
						type = itemInfo["type"],
						unique = itemInfo["unique"],
						useable = itemInfo["useable"],
						image = itemInfo["image"],
						slot = item.slot,
					}
				end
			end
		end
	end
	return items
end

function ServerPrint(columns, title, ...)
	if Debug() then 
		local boxWidth = 60
		local function textLength(text) return #text:gsub("%^%d", "") end

		local function centerText(text, width)
			local length = textLength(text)
			local padding = math.floor((width - length) / 2)
			return string.rep(" ", padding) .. text .. string.rep(" ", width - padding - length)
		end

		print("┌" .. string.rep("─", boxWidth) .. "┐")
		print("│" .. centerText(title, boxWidth) .. "│")
		print("│" .. string.rep(" ", boxWidth) .. "│")

		local args = {...}
		for i = 1, #args, columns do
			local lineText = ""
			for j = 0, columns - 1 do
				local argIndex = i + j
				if args[argIndex] then
					local text = args[argIndex]
					local color = "^7"
					if type(text) == "table" then color = text.color or "^7" text = text.text or "" end
					lineText = lineText .. color .. text .. " "
				end
			end
			print("^7│" .. centerText(lineText, boxWidth) .. "^7│")
		end
		print("^7└" .. string.rep("─", boxWidth) .. "┘^7")
	end
end


-- ┌───────────────────────────────┐
-- │    INVENTORY SLOT CHECKER     │
-- └───────────────────────────────┘

-- Check inv Slots
RegisterNetEvent(GetCurrentResourceName()..":Server:CheckInventorySlots", function(id, requiredSlots)
    local src = source
    local totalSlots = Config.System.InvSlots
    local usedSlots = 0
    local inventoryItems = {}

    -- ox_inventory support
    if GetResourceState(OXInv):find("start") then
        inventoryItems = exports[OXInv]:GetInventoryItems(src)
    
    -- qb-inventory support
    elseif GetResourceState(QBInv):find("start") then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            inventoryItems = Player.PlayerData.items or {}
        end

    -- ps-inventory support
    elseif GetResourceState(PSInv):find("start") then
        local inventory = exports[PSInv]:GetInventory(src)
        inventoryItems = inventory.items or {}

    -- qs-inventory support
    elseif GetResourceState(QSInv):find("start") then
        inventoryItems = exports[QSInv]:GetPlayerInventory(src)

    -- core_inventory support
    elseif GetResourceState(CoreInv):find("start") then
        local inventory = exports[CoreInv]:GetPlayerInventory(src)
        inventoryItems = inventory or {}

    -- codem_inventory support
    elseif GetResourceState(CodeMInv):find("start") then
        local Player = Core.Functions.GetPlayer(src)
        if Player then
            inventoryItems = exports[CodeMInv]:GetPlayerInventory(Player.PlayerData.citizenid)
        end

    -- origen_inventory support
    elseif GetResourceState(OrigenInv):find("start") then
        inventoryItems = exports[OrigenInv]:GetPlayerInventory(src)

    else
        print('^1Error:^7 Unsupported inventory system detected')
        return
    end

    -- Calculate used slots
    for _, item in pairs(inventoryItems) do
        if item then
            usedSlots = usedSlots + 1
        end
    end

    -- Calculate free slots
    local freeSlots = totalSlots - usedSlots
    local canCarry = freeSlots >= requiredSlots

    -- Trigger client event with result
    TriggerClientEvent(GetCurrentResourceName()..":Client:InventorySlotsChecked", src, id, canCarry)
end)

-- Utility function to check if a table includes a value
function table.includes(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end


-- TinySprite Scripts Server Console Print
local NotUpToDate = [[
|||^2 |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| ^1%s^7 ^7(^1%s^7) → ^2%s^7 available! Update at ^6portal.cfx.re^7
|||^2   |  \__‾‾\\__‾‾\ ^7|||
|||^2   |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

local UpToDate = [[
|||^2 |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| ^2%s^7
|||^2   |  \__‾‾\\__‾‾\ ^7|||
|||^2   |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

local Error = [[
|||^2 |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| ^1ERROR:^7 There was an error getting the latest version information.
|||^2   |  \__‾‾\\__‾‾\ ^7|||
|||^2   |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

local ResourceNameWarning = [[
^1ERROR:^7 Wrong Resource Name Detected!!!
|||^2 |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| Resource name is not ^2%s^7, expect there to be issues with the resource.
|||^2   |  \__‾‾\\__‾‾\ ^7||| ^5Rename the script back to^7: ^2%s^7 To Receive Support!
|||^2   |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

-- Fetches the latest version, name, and Discord link from the .txt file
local function GetCurrentVersion()
	local versionURL = ("https://raw.githubusercontent.com/TinySpriteScripts/version_check/main/%s-version.txt"):format(GetCurrentResourceName())
	PerformHttpRequest(versionURL, function(err, responseText, headers)
		Wait(3000)
		if err ~= 200 or not responseText or responseText == "" then print(Error:format("Unknown Discord Link")) return end

		local lines = {}
		for line in responseText:gmatch("[^\r\n]+") do table.insert(lines, line) end
		if #lines < 3 then print(Error:format("Unknown Discord Link")) return end

		local latestVersion, expectedName, discordLink = lines[1], lines[2], lines[3]
		local currentVersion, currentName = GetResourceMetadata(GetCurrentResourceName(), "version"), GetCurrentResourceName()

		if currentName ~= expectedName then print(ResourceNameWarning:format(expectedName, expectedName)) return end

		if currentVersion ~= latestVersion then print(NotUpToDate:format(expectedName, currentVersion, latestVersion, discordLink))
		else print(UpToDate:format(expectedName, discordLink)) end
	end)
end
GetCurrentVersion()