
repeat
    task.wait()
until game:IsLoaded()

--// Constants
local plr = game.Players.LocalPlayer
local gameId = game.GameId
local baseUrl = "https://raw.githubusercontent.com/iiX0Lords/Hub/main/games/"

--// Services
local httpService = game:GetService("HttpService")

--// Variables
local placeId = game.PlaceId
local universeId = nil
local loadedScript = nil

--// Functions
function getPlaceIdfromUniverseId(universeId:number)
	if not tonumber(universeId) then return nil end
	
	local data
	local success, response = pcall(function()
		data = game:HttpGet("https://games.roproxy.com/v1/games?universeIds="..universeId)
	end)

	if success and data then
		data = httpService:JSONDecode(data)

		return data["data"][1]["rootPlaceId"]
	end
    if not success then
        warn("[Rapist Hub] - Error fetching PlaceId")
        warn(response)
        return
    end
end

function getScriptFromPlaceId(id)
    local finalUrl = baseUrl..tostring(id)..".luau"
    local result
    local success, response = pcall(function()
        result = game:HttpGet(finalUrl)
    end)
    if success and result then
        return result
    else
        return nil
    end
end

--// Runtime

local success, response = pcall(function()
    local data = game:HttpGet(`https://apis.roblox.com/universes/v1/places/{placeId}/universe`)
    data = game:GetService("HttpService"):JSONDecode(data)

    universeId = data.universeId
end)
if not success then
    warn("[Rapist Hub] - Error fetching UniverseId")
    warn(response)
    return
end
placeId = getPlaceIdfromUniverseId(universeId)

loadedScript = getScriptFromPlaceId(placeId)
if loadedScript == nil then warn(`[Rapist Hub] - Couldnt find script for PlaceId: {tostring(placeId)}`) return end

print(`[Rapist Hub] - Running script for PlaceId: {tostring(placeId)}`)
local success, response = pcall(function()
    task.spawn(loadstring(loadedScript))
end)

if not success then
    warn("[Rapist Hub] - Error Running script")
    warn(response)
end