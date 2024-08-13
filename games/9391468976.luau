
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()

local runservice = game:GetService('RunService')
local uis = game:GetService('UserInputService')
local tweenservice = game:GetService('TweenService')


local Window = OrionLib:MakeWindow({Name = "SigmaMale9000", HidePremium = false, SaveConfig = false, ConfigFolder = "SigmaMale", IntroEnabled = false})


local toggles = {
    AntiStun = {
        Toggled = false,
        LegitMode = false,
    },
    AutoDodge = {
        Toggled = false,
        TpDistance = 6,
        ActivationDistance = 15,
    },
    AutoBlock = {
        Toggled = false,
        ActivationDistance = 15,
        Delay = 100,
        LookAt = false,
    },
    Lockon = {
        Toggled = false,
        Radius = 10,
    }
}

local aStunSection = Window:MakeTab({
	Name = "Anti-Stun",
	Icon = nil,
	PremiumOnly = false
})


aStunSection:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        toggles.AntiStun.Toggled = Value
    end
})

aStunSection:AddToggle({
    Name = "Legit Mode",
    Default = false,
    Callback = function(Value)
        toggles.AntiStun.LegitMode = Value
    end
})

local animationInfo = {}

function getInfo(id)
  local success, info = pcall(function()
      return game:GetService("MarketplaceService"):GetProductInfo(id)
  end)
  if success then
      return info
  end
  return {Name=''}
end

function handler(character)
    character.Info.ChildAdded:Connect(function(child)
        if toggles.AntiStun.Toggled then
            if toggles.AntiStun.LegitMode == false then

                if child.Name == "Stun" then
                    child.Name = ""
                end

                else

                if character.Info:FindFirstChild("InSkill") then
                    if child.Name == "Stun" then
                        child.Name = ""
                    end
                end

            end

        end
    end)
end
plr.CharacterAdded:Connect(function(character)
    task.wait(2)
    handler(character)
end)
handler(plr.Character)

--// Auto lockon

local lockOn = Window:MakeTab({
	Name = "Lock-On",
	Icon = nil,
	PremiumOnly = false
})


lockOn:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        toggles.Lockon.Toggled = Value
    end
})

lockOn:AddSlider({
	Name = "Activation Distance",
	Min = 5,
	Max = 20,
	Default = 10,
	Color = Color3.fromRGB(0, 140, 255),
	Increment = 1,
	ValueName = "Studs",
	Callback = function(Value)
		toggles.Lockon.Radius = Value
	end    
})

function findNearest()
    local maxDistance = toggles.Lockon.Radius
    local nearestPlayer, nearestDistance
    for _, player in pairs(game.Players:GetPlayers()) do
        if player == plr then continue end
        local character = player.Character
        local distance = player:DistanceFromCharacter(plr.Character.HumanoidRootPart.Position)
        if not character or 
            distance > maxDistance or
            (nearestDistance and distance >= nearestDistance)
        then
            continue
        end
        nearestDistance = distance
        nearestPlayer = player
    end
    return nearestPlayer
end

uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Q and not gameProcessedEvent then
        task.spawn(function()
            repeat
                task.wait()
                local nearest = findNearest()
                if nearest ~= nil then
                    plr.Character.Humanoid.AutoRotate = false
                    nearest = nearest.Character
                    local pos = plr.Character.HumanoidRootPart.Position
                    local targetPos = nearest.HumanoidRootPart.Position
                    local cf = CFrame.lookAt(pos, Vector3.new(targetPos.X, pos.Y, targetPos.Z))
                    plr.Character.HumanoidRootPart.CFrame = cf
                end
            until not plr.Character.Info:FindFirstChild("InSkill")
            plr.Character.Humanoid.AutoRotate = true
        end)
    end
end)

--// Auto Dodge

local autoDodge = Window:MakeTab({
	Name = "Auto Dodge",
	Icon = nil,
	PremiumOnly = false
})

autoDodge:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        toggles.AutoDodge.Toggled = Value
    end
})

autoDodge:AddSlider({
	Name = "Activation Distance",
	Min = 5,
	Max = 20,
	Default = 15,
	Color = Color3.fromRGB(0, 140, 255),
	Increment = 1,
	ValueName = "Studs",
	Callback = function(Value)
		toggles.AutoDodge.ActivationDistance = Value
	end    
})

autoDodge:AddSlider({
	Name = "TP Distance",
	Min = 1,
	Max = 10,
	Default = 6,
	Color = Color3.fromRGB(0, 140, 255),
	Increment = 1,
	ValueName = "Studs",
	Callback = function(Value)
		toggles.AutoDodge.TpDistance = Value
	end    
})

--// Auto block
local autoBlock = Window:MakeTab({
	Name = "Auto Block",
	Icon = nil,
	PremiumOnly = false
})
autoBlock:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
        toggles.AutoBlock.Toggled = Value
    end
})
autoBlock:AddSlider({
	Name = "Activation Distance",
	Min = 5,
	Max = 20,
	Default = 5,
	Color = Color3.fromRGB(0, 140, 255),
	Increment = 1,
	ValueName = "Studs",
	Callback = function(Value)
		toggles.AutoBlock.ActivationDistance = Value
	end    
})
autoBlock:AddSlider({
	Name = "Delay",
	Min = 100,
	Max = 5000,
	Default = 100,
	Color = Color3.fromRGB(0, 140, 255),
	Increment = 10,
	ValueName = "MS",
	Callback = function(Value)
		toggles.AutoBlock.Delay = Value
	end    
})

autoBlock:AddToggle({
    Name = "Auto Face",
    Default = false,
    Callback = function(Value)
        toggles.AutoBlock.LookAt = Value
    end
})

local blocking = false
function block()
    game:GetService("ReplicatedStorage").Knit.Knit.Services.BlockService.RE.Activated:FireServer()
    blocking = true
end
function unblock()
    game:GetService("ReplicatedStorage").Knit.Knit.Services.BlockService.RE.Deactivated:FireServer()
    blocking = false
end

runservice.RenderStepped:Connect(function(deltaTime)
    if toggles.AutoDodge.Toggled then
        function getRoots()
            local roots = {}
            for _,player in pairs(game.Players:GetChildren()) do
                if player ~= plr then
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        table.insert(roots,player.Character.HumanoidRootPart)
                    end
                end
            end
            return roots
        end
        
        position = plr.Character.HumanoidRootPart.Position
        radius = toggles.AutoDodge.ActivationDistance
        overlapParams = OverlapParams.new()
        overlapParams.FilterType = Enum.RaycastFilterType.Include
        overlapParams.FilterDescendantsInstances = getRoots()
        
        parts = workspace:GetPartBoundsInRadius(position, radius, overlapParams)
        local characters = {}
        for i,v in pairs(parts) do
            if v.Parent:FindFirstChildOfClass("Humanoid") then
                local char = v.Parent
                if char.Info:FindFirstChild("InSkill") then
                    plr.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,toggles.AutoDodge.TpDistance)
                end
            end
        end
    end
end)

local blackList = {
    "melee",
    "shutter doors",
    "chase",
    "red",
    "twofold kick",
    "cursed",
    "reserve balls",
    "fever breaker",
    "lapse blue"
}

local function lookAt(Character, Target)
	if Character.PrimaryPart then
        local chrPos = Character.PrimaryPart.CFrame.Position
		local tPos = Target.Character.PrimaryPart.CFrame.Position
        local modTPos = (chrPos - tPos).Unit * Vector3.new(1,0,1)
        local upVector = Character.PrimaryPart.CFrame.UpVector
        local newCF = CFrame.lookAt(chrPos, chrPos + modTPos, upVector) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.pi)
		Character:SetPrimaryPartCFrame(newCF)
	end
end

function playerAdded(v)
    function charadded(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.AnimationPlayed:Connect(function(track)
                if toggles.AutoBlock.Toggled then
                    local info = animationInfo[track.Animation.AnimationId]
                    if not info then
                        
                        info = getInfo(tonumber(track.Animation.AnimationId:match("%d+")))
                        animationInfo[track.Animation.AnimationId] = info
                        print(info.Name)
                    end
                    if (plr.Character and plr.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Head")) then
                        local mag = (v.Character.Head.Position - plr.Character.Head.Position).Magnitude

                        local actDistance = toggles.AutoBlock.ActivationDistance
                        
                        if info.Name:match("cursed") or info.Name:match("lapse blue") then
                            actDistance = actDistance * 2
                        end

                        if mag < actDistance  then
                            for _, animName in pairs(blackList) do
                                if info.Name:match(animName) then
                                    print("skibidi")
                                    if toggles.AutoBlock.LookAt then
                                        lookAt(plr.Character,v)
                                    end
                                    block()
                                    delay(toggles.AutoBlock.Delay/1000,function()
                                        unblock()
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    if v.Character then
        charadded(v.Character)
    end
    v.CharacterAdded:Connect(charadded)
end

for i,v in pairs(game.Players:GetPlayers()) do
   if v ~= plr then
       playerAdded(v)
   end
end
game.Players.PlayerAdded:Connect(function(player)
    playerAdded(player)
end)


OrionLib:Init()
