function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t={} ; i=1

	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local visualAssistEnabled = false
local originalSettings = {}

local function applyVisualSettings()
	DoScreenFadeOut(500)
	Wait(500)

	local settingsFile = LoadResourceFile(GetCurrentResourceName(), "visualsettings.dat")
	if not settingsFile then
		print("[Visual Assist] Error: visualsettings.dat not found")
		DoScreenFadeIn(500)
		return
	end

	local lines = stringsplit(settingsFile, "\n")
	local getHash = GetHashKey('GET_VISUAL_SETTING_FLOAT') & 0xFFFFFFFF
	local setHash = GetHashKey('SET_VISUAL_SETTING_FLOAT') & 0xFFFFFFFF

	for k,v in ipairs(lines) do
		if not starts_with(v, '#') and not starts_with(v, '//') and (v ~= "" or v ~= " ") and #v > 1 then
			v = v:gsub("%s+", " ")
			local setting = stringsplit(v, " ")

			if setting[1] ~= nil and setting[2] ~= nil and tonumber(setting[2]) ~= nil then
				if setting[1] ~= 'weather.CycleDuration' then
					if originalSettings[setting[1]] == nil then
						pcall(function()
							originalSettings[setting[1]] = Citizen.InvokeNative(getHash, setting[1], Citizen.ReturnResultAnyway(), Citizen.ResultAsFloat())
						end)
					end

					pcall(function()
						Citizen.InvokeNative(setHash, setting[1], tonumber(setting[2])+.0)
					end)
				end
			end
		end
	end

	Wait(100)
	DoScreenFadeIn(500)
end

local function revertToDefault()
	DoScreenFadeOut(500)
	Wait(500)

	local setHash = GetHashKey('SET_VISUAL_SETTING_FLOAT') & 0xFFFFFFFF

	for settingName, originalValue in pairs(originalSettings) do
		pcall(function()
			Citizen.InvokeNative(setHash, settingName, originalValue)
		end)
	end

	Wait(100)
	DoScreenFadeIn(500)
end

local function toggleVisualAssist()
	if not visualAssistEnabled then
		applyVisualSettings()
		visualAssistEnabled = true
		-- ADD YOUR NOTIFICATION HERE TO ALERT PLAYER THIS HAS BEEN ENABLED
	else
		revertToDefault()
		visualAssistEnabled = false
		-- ADD YOUR NOTIFICATION HERE TO ALERT PLAYER THIS HAS BEEN DISABLED
	end
end

RegisterCommand('epilepsymode', function()
	toggleVisualAssist()
end, false)