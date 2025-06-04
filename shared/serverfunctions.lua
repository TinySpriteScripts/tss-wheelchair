-- TinySprite Scripts Server Console Print
local NotUpToDate = [[
	|||^2  |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| ^1%s^7 ^7(^1%s^7) → ^2%s^7 available! Update at ^6portal.cfx.re^7
	|||^2    |  \__‾‾\\__‾‾\ ^7|||
	|||^2    |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

local UpToDate = [[
	|||^2  |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| ^2%s^7
	|||^2    |  \__‾‾\\__‾‾\ ^7|||
	|||^2    |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

local Error = [[
	|||^2  |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| ^1ERROR:^7 There was an error getting the latest version information.
	|||^2    |  \__‾‾\\__‾‾\ ^7|||
	|||^2    |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

local ResourceNameWarning = [[
		^1ERROR:^7 Wrong Resource Name Detected!!!
	|||^2  |‾‾‾|/‾‾‾\ /‾‾‾\  ^7||| Resource name is not ^2%s^7, expect there to be issues with the resource.
	|||^2    |  \__‾‾\\__‾‾\ ^7||| ^5Rename the script back to^7: ^2%s^7 To Receive Support!
	|||^2    |   |___/ |___/ ^7||| ^2TinySprite Scripts^7 | ^6%s^7 ]]

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