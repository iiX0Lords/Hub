
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
local stillLoading = true

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

--/ Make gui

task.spawn(function()
local loading = Instance.new("ScreenGui")
loading.IgnoreGuiInset = true
loading.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
loading.ResetOnSpawn = false
loading.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loading.Name = "Loading"
loading.Parent = plr.PlayerGui

local contents = Instance.new("Frame")
contents.AnchorPoint = Vector2.new(0.5, 0.5)
contents.BackgroundColor3 = Color3.new(0.152941, 0.152941, 0.152941)
contents.BorderColor3 = Color3.new(0, 0, 0)
contents.BorderSizePixel = 0
contents.Position = UDim2.new(0.5, 0, 0.5, 0)
contents.Size = UDim2.new(0.186915889, 0, 0.311041981, 0)
contents.Visible = true
contents.Name = "contents"
contents.Parent = loading

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 10)
uicorner.Parent = contents

local drop_shadow_holder = Instance.new("Frame")
drop_shadow_holder.BackgroundTransparency = 1
drop_shadow_holder.BorderSizePixel = 0
drop_shadow_holder.Size = UDim2.new(1, 0, 1, 0)
drop_shadow_holder.Visible = true
drop_shadow_holder.ZIndex = 0
drop_shadow_holder.Name = "DropShadowHolder"
drop_shadow_holder.Parent = contents

local drop_shadow = Instance.new("ImageLabel")
drop_shadow.Image = "rbxassetid://6014261993"
drop_shadow.ImageColor3 = Color3.new(0, 0, 0)
drop_shadow.ImageTransparency = 0.5
drop_shadow.ScaleType = Enum.ScaleType.Slice
drop_shadow.SliceCenter = Rect.new(49, 49, 450, 450)
drop_shadow.AnchorPoint = Vector2.new(0.5, 0.5)
drop_shadow.BackgroundTransparency = 1
drop_shadow.BorderSizePixel = 0
drop_shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
drop_shadow.Size = UDim2.new(1, 47, 1, 47)
drop_shadow.Visible = true
drop_shadow.ZIndex = 0
drop_shadow.Name = "DropShadow"
drop_shadow.Parent = drop_shadow_holder

local aspect_ratio = Instance.new("UIAspectRatioConstraint")
aspect_ratio.AspectRatio = 1.590000033378601
aspect_ratio.Name = "AspectRatio"
aspect_ratio.Parent = contents

local loading_2 = Instance.new("CanvasGroup")
loading_2.AnchorPoint = Vector2.new(0.5, 0.5)
loading_2.BackgroundColor3 = Color3.new(0.152941, 0.152941, 0.152941)
loading_2.BorderColor3 = Color3.new(0, 0, 0)
loading_2.BorderSizePixel = 0
loading_2.Position = UDim2.new(0.5, 0, 0.5, 0)
loading_2.Size = UDim2.new(1, 0, 1, 0)
loading_2.Visible = true
loading_2.Name = "loading"
loading_2.Parent = contents

local uicorner_2 = Instance.new("UICorner")
uicorner_2.CornerRadius = UDim.new(0, 10)
uicorner_2.Parent = loading_2

local title = Instance.new("TextLabel")
title.Font = Enum.Font.GothamBold
title.Text = "Rapist Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.TextSize = 14
title.TextWrapped = true
title.AnchorPoint = Vector2.new(0.5, 0)
title.BackgroundColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.BorderColor3 = Color3.new(0, 0, 0)
title.BorderSizePixel = 0
title.Position = UDim2.new(0.5, 0, 0, 0)
title.Size = UDim2.new(1, 0, 0.211999997, 0)
title.Visible = true
title.Name = "title"
title.Parent = loading_2

local uitext_size_constraint = Instance.new("UITextSizeConstraint")
uitext_size_constraint.MaxTextSize = 30
uitext_size_constraint.Parent = title

local line = Instance.new("Frame")
line.AnchorPoint = Vector2.new(0.5, 1)
line.BackgroundColor3 = Color3.new(1, 1, 1)
line.BorderColor3 = Color3.new(0, 0, 0)
line.BorderSizePixel = 0
line.Position = UDim2.new(0.5, 0, 1, 0)
line.Size = UDim2.new(1, 0, 0.0450000018, 0)
line.Visible = true
line.Name = "line"
line.Parent = title

local bar = Instance.new("CanvasGroup")
bar.AnchorPoint = Vector2.new(0.5, 0.5)
bar.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.141176)
bar.BorderColor3 = Color3.new(0, 0, 0)
bar.BorderSizePixel = 0
bar.Position = UDim2.new(0.5, 0, 0.600000024, 0)
bar.Size = UDim2.new(0.850000024, 0, 0.150000006, 0)
bar.Visible = true
bar.Name = "bar"
bar.Parent = loading_2

local uicorner_3 = Instance.new("UICorner")
uicorner_3.CornerRadius = UDim.new(0, 6)
uicorner_3.Parent = bar

local fill = Instance.new("Frame")
fill.BackgroundColor3 = Color3.new(1, 1, 1)
fill.BorderColor3 = Color3.new(0, 0, 0)
fill.BorderSizePixel = 0
fill.Size = UDim2.new(0, 0, 1, 0)
fill.Visible = true
fill.Name = "fill"
fill.Parent = bar

local uistroke = Instance.new("UIStroke")
uistroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uistroke.Color = Color3.new(1, 1, 1)
uistroke.Thickness = 1.899999976158142
uistroke.Parent = bar

local ui = bar
local mainUi = loading

local tweenservice = game:GetService("TweenService")
while task.wait(.1) do
	if stillLoading then
		local rand = Random.new()
		local increment = rand:NextNumber()/100
		tweenservice:Create(ui.fill,TweenInfo.new(.1),{
			Size = ui.fill.Size + UDim2.new(increment, 0, 0, 0)
		}):Play()
	else
		tweenservice:Create(ui.fill,TweenInfo.new(.1),{
			Size = UDim2.new(1, 0, 1, 0)
		}):Play()
		break
	end
end

local speed = 0.4
tweenservice:Create(ui.Parent,TweenInfo.new(speed),{
	GroupTransparency = 1
}):Play()
tweenservice:Create(mainUi.contents,TweenInfo.new(speed),{
	BackgroundTransparency = 1
}):Play()
tweenservice:Create(mainUi.contents.DropShadowHolder.DropShadow,TweenInfo.new(speed),{
	ImageTransparency = 1
}):Play()

task.wait(speed)
mainUi:Destroy()

end)

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
stillLoading = false