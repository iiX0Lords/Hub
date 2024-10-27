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
                Descendant.Size = UDim2.new(0.5, 0, 1.3, 0)
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

function load(cframe : CFrame)
    local cf = plr.Character.HumanoidRootPart.CFrame
    plr.Character.HumanoidRootPart.CFrame = cframe
    task.wait(0.5)
    plr.Character.HumanoidRootPart.CFrame = cf
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