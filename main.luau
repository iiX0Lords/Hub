
repeat
    task.wait()
until game:IsLoaded()

--// Constants
local plr = game.Players.LocalPlayer
local gameId = game.GameId

--// Services
local httpService = game:GetService("HttpService")

--// Variables
local placeId = game.PlaceId
local universeId = nil

--// Init
local success, response = pcall(function()
    local data = game:HttpGet(`https://apis.roblox.com/universes/v1/places/{placeId}/universe`)
    data = game:GetService("HttpService"):JSONDecode(data)

    universeId = data.universeId
end)
if not success then
    error("[Rapist Hub] - Error Fetching Universe Id")
    return
end

local function getPlaceIdfromUniverseId(universeId:number)
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
        error("[Rapist Hub] - Error Fetching Place Id")
        return
    end
end
placeId = getPlaceIdfromUniverseId(universeId)
print(placeId)