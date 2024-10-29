
if _G.fisching ~= nil then
    _G.fisching:Destroy()
end

local OrionLib = loadstring(game:HttpGet("https://twix.cyou/Orion.txt", true))()
_G.fisching = OrionLib
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

local Window = OrionLib:MakeWindow({
    Name = "Fisching",
    TestMode = false,
    SaveConfig = false,
    IntroEnabled = false,
    CloseCallback = function()
        for i,v in pairs(toggles) do
            toggles[i] = false
        end
    end
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
    local toggle = parent:AddToggle({
        Name = name,
        Default = default,
        Callback = function(Value)
            toggles[linked] = Value
            if callback ~= nil then
                callback(Value)
            end
        end
    })
    return toggle
end


local main = Window:MakeTab({Name="Auto Fishing"})
local crabcagesW = Window:MakeTab({Name="Crab Cages"})

local autoFishToggle = createToggle(main, "Auto Fish Toggle", false, "Autofishing", function(value)
    OrionLib:MakeNotification({
        Name = "Autofishing",
        Content = `Autofishing set to {tostring(toggles.Autofishing)}`,
        Time = 2
    })

    if value == false then
        progess = false
    end
end)



local autoFishkeybind = main:AddBind({
    Name = "Keybind",
    Default = Enum.KeyCode.F,
    Hold = false,
    Callback = function()
        autoFishToggle:Set(not toggles.Autofishing)
    end
})
main:AddLabel("Configuration")

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


local shop = Window:MakeTab({Name="Shop"})

function load(cframe : CFrame)
    local cf = plr.Character.HumanoidRootPart.CFrame
    plr.Character.HumanoidRootPart.CFrame = cframe
    task.wait(0.5)
    plr.Character.HumanoidRootPart.CFrame = cf
end

shop:AddLabel("Purchases")
shop:AddButton({
    Name = "Enchant Relic - 11k",
    Callback = function()
        workspace.world.npcs.Merlin.Merlin.power:InvokeServer()
    end
})
shop:AddButton({
    Name = "Luck VI - 5k",
    Callback = function()
        workspace.world.npcs.Merlin.Merlin.luck:InvokeServer()
    end
})


--crabcagesW:AddLabel("Crab Cages")

crabcagesW:AddButton({
    Name = "Place All",
    Callback = function()

        if plr.Character:FindFirstChild("Crab Cage") then
            repeat
                task.wait()
                pcall(function()
                    local ohTable1 = {
                        ["CFrame"] = workspace.Camera:FindFirstChild("Cage").MeshPart.CFrame
                    }
                    workspace.iiX0Lord["Crab Cage"].Deploy:FireServer(ohTable1)
                end)
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
crabcagesW:AddButton({
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

local teleprots = Window:MakeTab({Name="Misc"})

teleprots:AddToggle({
    Name = "Drowning Enabled",
    Default = true,
    Callback = function(Value)
        plr.Character:FindFirstChild("client"):FindFirstChild("oxygen").Enabled = Value
    end
})

teleprots:AddLabel("Teleports")

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
        teleprots:AddButton({
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
        drop = teleprots:AddDropdown({
            Name = i,
            Options = opss,
            Default = nil,
            Callback = function(Option)
                plr.Character.HumanoidRootPart.CFrame = v[Option]
            end,
         })
    end
end


OrionLib:Init()