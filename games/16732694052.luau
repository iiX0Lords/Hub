local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local plr = game.Players.LocalPlayer
local virtualInputManager = game:GetService('VirtualInputManager')
local uis = game:GetService("UserInputService")
local mouse = plr:GetMouse()
local playerGui = plr:FindFirstChild("PlayerGui")
local runservice = game:GetService("RunService")
local guiService = game:GetService('GuiService')

local world = workspace.world
local map = world.map

local progess = false

local toggles = {
    Autofishing = false,
    InstantCatch = false,
    Freeze = false,
    InstantCollect = false,
}

local Window = Rayfield:CreateWindow({
    Name = "Fisching",
    LoadingTitle = "Fisching",
    LoadingSubtitle = "by xlords",
 })

function mouseclick(state : boolean)
    virtualInputManager:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

function autoReel()
    progess = true
    mouseclick(true)
    local power : BillboardGui = plr.Character.HumanoidRootPart:WaitForChild("power")
    local bar : Frame = power.powerbar:FindFirstChild("bar")
    repeat
        task.wait()
    until bar.Size.Y.Scale >= 0.97
    mouseclick(false)
end

function createToggle(parent, name, default, linked, callback)
    local toggle = parent:CreateToggle({
        Name = name,
        CurrentValue = default,
        Callback = function(Value)
            toggles[linked] = Value
            if callback ~= nil then
                callback(Value)
            end
        end
    })
    return toggle
end


local main = Window:CreateTab("Auto Fishing")
local crabcagesW = Window:CreateTab("Crab Cages")

local autoFishToggle = createToggle(main, "Auto Fish Toggle", false, "Autofishing", function(value)
    Rayfield:Notify{
        Title = "Autofishing",
        Content = `Autofishing set to {tostring(toggles.Autofishing)}`,
        Duration = 2
    }

    if value == false then
        progess = false
    end
end)



local autoFishkeybind = main:CreateKeybind({
    Name = "Keybind",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Callback = function()
        autoFishToggle:Set(not toggles.Autofishing)
    end
})
main:CreateLabel("Configuration")

local instaCatchToggle = createToggle(main, "Instant Catch", false, "InstantCatch")
local freezeToggle = createToggle(main, "Freeze While Fishing", false, "Freeze")

plr.PlayerGui.DescendantAdded:Connect(function(Descendant)
    if toggles.Autofishing then
        if Descendant.Name == 'button' and Descendant.Parent.Name == 'safezone' then
            task.wait(0.01)
            guiService.SelectedObject = Descendant
            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait(0.01)
            guiService.SelectedObject = nil
        elseif Descendant.Name == 'playerbar' and Descendant.Parent.Name == 'bar' then
            progess = true

            if toggles.InstantCatch then

                delay(1,function()
                    Descendant.Size = UDim2.new(0.5, 0, 1.3, 0)
                end)

                Descendant:GetPropertyChangedSignal('Position'):Wait()
                game.ReplicatedStorage.events.reelfinished:FireServer(100, true)
            else
                delay(0.5,function()
                    Descendant.Size = UDim2.new(1, 0, 1.3, 0)
                end)
            end
        end
    end
end)

plr.PlayerGui.DescendantRemoving:Connect(function(Descendant)
    if Descendant.Name == 'reel' then
        task.wait(1)
        progess = false
    end
end)

task.spawn(function()
    while task.wait() do
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        if tool ~= nil then
            if tool.Name:find("Rod") then
                if toggles.Autofishing and not progess then
                    
                    if toggles.Freeze then
                        plr.Character.HumanoidRootPart.Anchored = true
                    end

                    autoReel()
                    repeat
                        task.wait()
                    until progess == false
                    plr.Character.HumanoidRootPart.Anchored = false
                end
                else
                progess = false
            end
            else
            progess = false
        end
        
    end
end)


local shop = Window:CreateTab("Shop")

local items = {
    ["Crab Cage"] = CFrame.new(476.3, 150.5, 231.9),
}

function purchaseItem(item : string, itemPos : CFrame)
    
    plr.Character.HumanoidRootPart.CFrame = itemPos
    local model : Model = world:FindFirstChild("interactables"):WaitForChild(item)
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt",true)
    prompt.Enabled = false
    task.wait(.1)
    prompt.Enabled = true

    virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

    local prompt = plr.PlayerGui:WaitForChild("over")
    local confirm : TextButton = prompt:WaitForChild("prompt",20):WaitForChild("confirm",20)
    task.wait(1)
    print(confirm.AbsolutePosition.X, confirm.AbsolutePosition.Y)
    
    virtualInputManager:SendMouseButtonEvent(confirm.AbsolutePosition.X, confirm.AbsolutePosition.Y, 0, true, game, 0)
    virtualInputManager:SendMouseButtonEvent(confirm.AbsolutePosition.X, confirm.AbsolutePosition.Y, 0, false, game, 0)

end

shop:CreateLabel("Purchases")
shop:CreateButton({
    Name = "Enchant Relic - 11k",
    Callback = function()
        workspace.world.npcs.Merlin.Merlin.power:InvokeServer()
    end
})
shop:CreateButton({
    Name = "Luck VI - 5k",
    Callback = function()
        workspace.world.npcs.Merlin.Merlin.luck:InvokeServer()
    end
})


for name,index in pairs(items) do
    shop:CreateButton({
        Name = name,
        Callback = function()
            purchaseItem(name, index)
        end
    })
end

--crabcagesW:CreateLabel("Crab Cages")

crabcagesW:CreateButton({
    Name = "Place All",
    Callback = function()

        if plr.Character:FindFirstChild("Crab Cage") then
            repeat
                task.wait()
                local success, response = pcall(function()
                    local ohTable1 = {
                        ["CFrame"] = workspace.Camera:FindFirstChild("Cage").MeshPart.CFrame
                    }
                    plr.Character["Crab Cage"].Deploy:FireServer(ohTable1)
                end)
                print(success, response)
            until not plr.Character:FindFirstChild("Crab Cage")
        end
    end
})
local active : Folder = workspace.active
local freezeToggle = createToggle(crabcagesW, "Instant Collect", false, "InstantCollect", function()
    for _,child in pairs(active:GetChildren()) do
        if child.Name == plr.Name then
            if child:FindFirstChild("Cage") then
                child:FindFirstChildOfClass("ProximityPrompt").HoldDuration = 0
            end
        end
    end
end)
active.ChildAdded:Connect(function(child)
    if toggles.InstantCollect then
        if child.Name == plr.Name then
            if child:FindFirstChild("Cage") then
                child:FindFirstChildOfClass("ProximityPrompt").HoldDuration = 0
            end
        end
    end
end)

-- selene: allow(undefined_variable)
if fireproximityprompt ~= nil then
crabcagesW:CreateButton({
    Name = "Collect All",
    Callback = function()
        for _,child in pairs(active:GetChildren()) do
            if child.Name == plr.Name then
                if child:FindFirstChild("Cage") then
                    local prompt = child:FindFirstChildOfClass("ProximityPrompt")
                    
                    plr.Character.HumanoidRootPart.CFrame = child.Cage.cage.CFrame
                    fireproximityprompt(prompt)

                end
            end
        end
    end
})
end


local teleprots = Window:CreateTab("Misc")

teleprots:CreateToggle({
    Name = "Drowning Enabled",
    CurrentValue = true,
    Callback = function(Value)
        plr.Character:FindFirstChild("client"):FindFirstChild("oxygen").Enabled = Value
    end
})

teleprots:CreateLabel("Teleports")

local teleports = {
    ["Moose Wood"] = CFrame.new(377.7, 134.5, 249.8),
    ["Terrapin"] = CFrame.new(-165, 145.1, 1939.9),
    ["Sunstone"] = {
        ["Dock"] = CFrame.new(-928, 131, -1114),
        ["Merlin"] = CFrame.new(-932, 223, -986),
        ["Sundial Totem"] = CFrame.new(-1143, 134, -1070),
    },
    ["Roslit Bay"] = CFrame.new(-1470, 132, 696),
    ["Statue Of Scat"] = CFrame.new(20, 159, -1043),
    ["Mushgrove Swamp"] = CFrame.new(2441, 131, -690),
    ["Snowscat Island"] = CFrame.new(2606, 135, 2402),
    ["Desolate Deep"] = {
        ["Shop"] = CFrame.new(-978, -244, -2702),
        ["Main Cave/Shop"] = CFrame.new(-1654, -213, -2855),
        ["Brine Pool"] = CFrame.new(-1797, -142, -3399),
        ["Trident Temple"] = CFrame.new(-1477, -225, -2346),
    },
}


for i,v in pairs(teleports) do
    if typeof(v) == "CFrame" then
        teleprots:CreateButton({
            Name = i,
            Callback = function()
                plr.Character.HumanoidRootPart.CFrame = v
            end
        })
    elseif typeof(v) == "table" then

        local opss = {}

        for i,v in pairs(v) do
            table.insert(opss, i)
        end
        local drop = nil
        drop = teleprots:CreateDropdown({
            Name = i,
            Options = opss,
            CurrentOption = nil,
            MultipleOptions = false,
            Callback = function(Option)
                plr.Character.HumanoidRootPart.CFrame = v[Option[1]]
            end,
         })
    end
end