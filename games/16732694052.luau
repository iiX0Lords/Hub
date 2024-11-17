
local identifier = Instance.new("Configuration")
identifier.Name = "Fisching"
identifier.Parent = game.Players.LocalPlayer
game:GetService("Debris"):AddItem(identifier,1)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local plr = game.Players.LocalPlayer
local virtualInputManager = game:GetService('VirtualInputManager')
local uis = game:GetService("UserInputService")
local mouse = plr:GetMouse()
local playerGui = plr:FindFirstChild("PlayerGui")
local runservice = game:GetService("RunService")
local guiService = game:GetService('GuiService')

local world = workspace.world
local map = world.map
local active : Folder = workspace.active

local progess = false
local destroyed = false

local toggles = {
    Autofishing = false,
    InstantCatch = false,
    Freeze = false,
    InstantCollect = false,
    ClickTP = true
}

local values = {
    casted = Instance.new("ObjectValue"),
    bite = Instance.new("ObjectValue"),
}

local thresshold = 0.97

local teleports = {
    ["Moosewood"] = CFrame.new(377.7, 134.5, 249.8),
    ["Terrapin Island"] = CFrame.new(-165, 145.1, 1939.9),
    ["Sunstone Island"] = {
        ["Main Dock"] = CFrame.new(-928, 131, -1114),
        ["Merlin"] = CFrame.new(-932, 223, -986),
        ["Sundial Totem"] = CFrame.new(-1143, 134, -1070),
    },
    ["Roslit Bay"] = CFrame.new(-1470, 132, 696),
    ["Statue Of Sovereignty"] = {
        ["Main Entrance"] = CFrame.new(20, 159, -1043),
        ["Enchanting Alter"] = CFrame.new(1307.9, -805.3, -121.4),
    },
    ["Mushgrove"] = CFrame.new(2441, 131, -690),
    ["Snowcap Island"] = CFrame.new(2606, 135, 2402),
    ["Desolate Deep"] = {
        ["Shop"] = CFrame.new(-978, -244, -2702),
        ["Main Cave/Shop"] = CFrame.new(-1654, -213, -2855),
        ["Brine Pool"] = CFrame.new(-1797, -142, -3399),
        ["Trident Temple"] = CFrame.new(-1477, -225, -2346),
    },
    ["Forsaken Shores"] = CFrame.new(-2498, 132, 1543),
    ["The Depths"] = CFrame.new(947.5, -711.7, 1243.2),
}

local version = "<!#FV> 1.6.5 </#FV>"
version = string.sub(version,8,13)
local Window = Fluent:CreateWindow({
    Title = `Fisching | {version}`,
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.K
 })
 Fluent:ToggleTransparency(false)
 local Options = Fluent.Options

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
    until bar.Size.Y.Scale >= thresshold
    mouseclick(false)
end

function createToggle(parent, name, default, linked, callback)
    local toggle = parent:AddToggle(name,{
        Title = name,
        Default = default,
        Callback = function(Value)
            toggles[linked] = Value
            if callback ~= nil then
                callback(Value)
            end
        end
    })

    -- toggle:OnChanged(function()
    --     local Value = Options[name].Value
    --     toggles[linked] = Value
    --     if callback ~= nil then
    --         callback(Value)
    --     end
    -- end)
    return toggle
end


local main = Window:AddTab({Title = "Auto Fishing"})
local crabcagesW = Window:AddTab({Title = "Crab Cages"})

local autoFishToggle = createToggle(main, "Auto Fish Toggle", false, "Autofishing", function(value)
    Fluent:Notify{
        Title = "Autofishing",
        Content = `Autofishing set to {tostring(toggles.Autofishing)}`,
        Duration = 2
    }

    if value == false then
        progess = false
        else
        autoReel()
    end
end)



local autoFishkeybind = main:AddKeybind("AutoFishKeybind",{
    Title = "Keybind",
    Mode = "Toggle",
    Default = "F",
    HoldToInteract = false,
    Callback = function()
        Options["Auto Fish Toggle"]:SetValue(not toggles.Autofishing)
    end
})
main:AddParagraph({Title = "Configuration"})

local instaCatchToggle = createToggle(main, "Instant Catch", false, "InstantCatch")
local freezeToggle = createToggle(main, "Freeze While Fishing", false, "Freeze")

main:AddSlider("Reel",{
    Title = "Auto reel threshold",
    Min = 0,
    Max = 100,
    Rounding = 0,
    --Suffix = "Height",
    Default = 97,
    Callback = function(Value)
        thresshold = (Value / 100)
    end,
})

plr.PlayerGui.DescendantAdded:Connect(function(Descendant)
    if toggles.Autofishing and not destroyed then
        if Descendant.Name == 'button' and Descendant.Parent.Name == 'safezone' then
            task.wait(0.01)
            Descendant.Selectable = true
            Descendant.Visible = true
            Descendant.Parent.Visible = true
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

-- task.spawn(function()
--     while task.wait() do

--         if destroyed then
--             break
--         end

--         local tool = plr.Character:FindFirstChildOfClass("Tool")
--         if tool ~= nil then
--             if tool.Name:find("Rod") then
--                 if toggles.Autofishing then
--                     if not progess then
--                         if toggles.Freeze then

--                             local velocity = Instance.new("BodyVelocity")
--                             velocity.Name = "Freeze"
--                             velocity.Parent = plr.Character.HumanoidRootPart
--                             velocity.MaxForce = Vector3.new(999999,999999,999999)
--                             velocity.Velocity = Vector3.new(0,0,0)
--                         end

--                         autoReel()
--                         repeat
--                             task.wait()
--                         until progess == false
                        
--                         if plr.Character.HumanoidRootPart:FindFirstChild("Freeze") then
--                             plr.Character.HumanoidRootPart:FindFirstChild("Freeze"):Destroy()
--                         end
--                     end
--                 end
--                 else
--                 progess = false
--             end
--             else
--             progess = false
--         end
        
--     end
-- end)

castConnection = nil
biteConnection = nil

function castedChange(value)
    if value == false and toggles.Autofishing then
        task.wait(0.5)
        autoReel()
    end
end

function childRemovedFunc(child)
    if destroyed then
        if castConnection ~= nil then
            castConnection:Disconnect()
        end
        return
    end
    wait()
    if child.Parent == plr.Character then
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        if tool == nil then return end
        if tool.Name:find("Rod") then
            
            local values = tool:FindFirstChild("values")
            local bite : BoolValue,casted : BoolValue = values:FindFirstChild("bite"), values:FindFirstChild("casted")

            if castConnection ~= nil then
                castConnection:Disconnect()
                print(`Disconnected from {tool.Name}`)
            end

            castConnection = casted.Changed:Connect(castedChange)
            print(`Connceted to {tool.Name}`)
        end
    end
end

plr.Backpack.ChildRemoved:Connect(childRemovedFunc)

if plr.Character:FindFirstChildOfClass("Tool") then
    childRemovedFunc(plr.Character:FindFirstChildOfClass("Tool"))
end

local shop = Window:AddTab({Title = "Shop"})

local items = {
    ["Crab Cage"] = {
        CFrame = CFrame.new(476.3, 150.5, 231.9),
        Price = 45,
    },
    ["Bait Crate"] = {
        CFrame = CFrame.new(386.5, 137, 336.9),
        Price = 120,
    },
    ["Quality Bait Crate"] = {
        CFrame = CFrame.new(-174.9, 143.3, 1933.8),
        Price = 525,
    },
}

local totems = {
    ["Sundial Totem"] = {
        CFrame = CFrame.new(-1148.8, 134.5, -1073.7),
        Price = 2000,
    },
    ["Tempest Totem"] = {
        CFrame = CFrame.new(35.1, 132.5, 1943.1),
        Price = 2000,
    },
    ["Smokescreen Totem"] = {
        CFrame = CFrame.new(2791.1, 139.7, -627.4),
        Price = 2000,
    },
}

local prompt : PlayerGui = plr.PlayerGui:FindFirstChild("over")

function purchaseItem(item : string, itemPos : CFrame, amount : number)
    local callb = nil
    local originalCFrame = plr.Character.HumanoidRootPart.CFrame

    local count = 0
    local shown = false

    callb = prompt.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "confirm" then
            shown = true

            if count >= amount then
                task.wait(0.01)
                guiService.SelectedObject = descendant.Parent:FindFirstChild("deny")
                virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                task.wait(0.01)
                guiService.SelectedObject = nil

                callb:Disconnect()
                plr.Character.HumanoidRootPart.CFrame = originalCFrame
            end
            -- dont ask im pulling these waits out of my ass
            task.wait(0.01)
            guiService.SelectedObject = descendant
            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait(0.01)
            guiService.SelectedObject = nil
            count += 1

            if count >= amount then
                callb:Disconnect()
                plr.Character.HumanoidRootPart.CFrame = originalCFrame
            end
            
        end
    end)

    plr.Character.HumanoidRootPart.CFrame = itemPos
    local model : Model = world:FindFirstChild("interactables"):WaitForChild(item)
    local proxprompt = model:FindFirstChildWhichIsA("ProximityPrompt",true)

    repeat
        task.wait()
        proxprompt = model:FindFirstChildWhichIsA("ProximityPrompt",true)
    until proxprompt ~= nil

    -- selene: allow(undefined_variable)

    local function interact()
        if fireproximityprompt ~= nil then
            print("dddSS")
            fireproximityprompt(proxprompt)
            else
            proxprompt.Enabled = false
            task.wait(0.2)
            proxprompt.Enabled = true
        
            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    end

    repeat
        
        if shown then break end

        interact()
        task.wait(0.1)
    until shown == true

    if amount > 1 then
        for i = 1,(amount - 1) do
            interact()
            prompt.ChildRemoved:Wait()
        end    
    end
end

function merlinBuy(purchase : string, amount : number)

    local original : CFrame = plr.Character.HumanoidRootPart.CFrame

    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-932, 223, -986)
    task.wait(0.5)
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-932.5, 22.9, -991.6)
    task.wait(0.2)

    for i = 1,amount do
        workspace.world.npcs.Merlin.Merlin:FindFirstChild(purchase):InvokeServer()
    end

    virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

    task.wait(0.3)
    plr.Character.HumanoidRootPart.CFrame = original
end

shop:AddParagraph({Title = "Items"})

for name,index in pairs(items) do

    shop:AddInput(name,{
        Title = `{name} - {tostring(index.Price)}C$`,
        Placeholder = "1",
        Numeric = true,
        Finished = true,
        Callback = function(txt)
            local amount = tonumber(txt) or 1
            purchaseItem(name, index.CFrame, amount)
        end
    })
end

shop:AddInput("Relic",{
    Title = "Enchant Relic - 11,000C$",
    Placeholder = "1",
    Numeric = true,
    Finished = true,
    Callback = function(txt)
        local amount = tonumber(txt)
        if amount == nil then return end
        merlinBuy("power", amount)
    end
})

shop:AddParagraph({Title = "Totems"})

for name,index in pairs(totems) do

    shop:AddInput("name",{
        Title = `{name} - {tostring(index.Price)}C$`,
        Placeholder = "1",
        Numeric = true,
        Finished = true,
        Callback = function(txt)
            local amount = tonumber(txt) or 1
            purchaseItem(name, index.CFrame, amount)
        end
    })
end

shop:AddParagraph({Title = "Modifiers"})
shop:AddInput("Luck",{
    Title = "Luck VI - 5,000C$",
    Placeholder = "1",
    Numeric = true,
    Finished = true,
    Callback = function(txt)
        local amount = tonumber(txt)
        if amount == nil then return end
        merlinBuy("luck", amount)
    end
})


--crabcagesW:CreateLabel("Crab Cages")

--#TODO fix the lag when placing to many
crabcagesW:AddButton({
    Title = "Place All",
    Callback = function()

        if plr.Character:FindFirstChild("Crab Cage") then
            repeat
                task.wait(0.1)
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
-- if fireproximityprompt ~= nil then
-- crabcagesW:AddButton({
--     Title = "Collect All",
--     Callback = function()
--         for _,child in pairs(active:GetChildren()) do
--             if child.Name == plr.Name then
--                 if child:FindFirstChild("Cage") then
--                     local prompt = child:FindFirstChildOfClass("ProximityPrompt")
                    
--                     plr.Character.HumanoidRootPart.CFrame = child.Cage.cage.CFrame
--                     fireproximityprompt(prompt)

--                 end
--             end
--         end
--     end
-- })
-- end


local teleprots = Window:AddTab({Title = "Misc"})

teleprots:AddToggle("Drowning",{
    Title = "Drowning Enabled",
    Default = true,
    Callback = function(Value)
        plr.Character:FindFirstChild("client"):FindFirstChild("oxygen").Enabled = Value
    end
})

local pois = active:FindFirstChild("OceanPOI's")
local zones : Model = workspace.zones.fishing
teleprots:AddToggle("ISLAND",{
    Title = "Click Island Text To TP",
    Default = true,
    Callback = function(Value)
        for i,v in pairs(plr.PlayerGui:GetChildren()) do
            if v:IsA("BillboardGui") then
                if v:FindFirstChild(v.Name) then
                    v.Enabled = Value
                end
            end
        end
    end
})

function doteleport(to : CFrame)
    if plr.Character.Humanoid.SeatPart ~= nil then
        plr.Character.Humanoid.SeatPart.Parent.Base.CFrame = to
        else
        plr.Character.HumanoidRootPart.CFrame = to
    end
end

function poiHeaderClicked(header : BillboardGui, isIsland)
    if not isIsland then
        doteleport(header.Parent.CFrame)
        else
        if teleports[header.Parent.Name] then
            if typeof(teleports[header.Parent.Name]) == "CFrame" then
                doteleport(teleports[header.Parent.Name])
                else
                for i,v in pairs(teleports[header.Parent.Name]) do
                    if string.find(i, "Main") then
                        doteleport(v)
                        break
                    end
                end
            end
            
        end
    end
end

function prepareHeader(header : BillboardGui, isIsland)
    local title : TextLabel = header:FindFirstChild("title")
    if title == nil then warn("no header"..header.Parent.Name) return end
    if plr.PlayerGui:FindFirstChild(header.Parent.Name) then plr.PlayerGui:FindFirstChild(header.Parent.Name):Destroy() end
    local p = header:Clone()
    p.Name = header.Parent.Name
    p.Parent = plr.PlayerGui
    p:ClearAllChildren()
    p.Adornee = header.Parent
    local btn = Instance.new("TextButton",p)
    btn.Name = header.Parent.Name
    btn.AnchorPoint = title.AnchorPoint
    btn.Size = title.Size
    btn.Position = title.Position
    btn.BackgroundTransparency = 1
    btn.TextTransparency = 1
    btn.ZIndex = 2

    header:GetPropertyChangedSignal("Enabled"):Connect(function()
        if p ~= nil then
            p.Enabled = header.Enabled
        end
    end)


    btn.MouseButton1Click:Connect(function()
        poiHeaderClicked(header, isIsland)
    end)
end

for i,v in pairs(pois:GetChildren()) do
    if v:FindFirstChild("POIHeader") then
        prepareHeader(v:FindFirstChild("POIHeader"), true)
    end
end

for i,descendant in pairs(zones:GetDescendants()) do
    if descendant.Name == "POIHeader" then
        prepareHeader(descendant)
    end
end

zones.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "POIHeader" then
        prepareHeader(descendant)
    end
end)

teleprots:AddParagraph({Title = "Teleports"})

for i,v in pairs(teleports) do
    if typeof(v) == "CFrame" then
        teleprots:AddButton({
            Title = i,
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
        drop = teleprots:AddDropdown(i,{
            Title = i,
            Values = opss,
            Default = nil,
            Multi = false,
         })
        drop:OnChanged(function(Value)
            if Value ~= nil then
                plr.Character.HumanoidRootPart.CFrame = v[Value]
            end
        end)
    end
end


plr.ChildAdded:Connect(function(child)
    if child.Name == "Fisching" then
        print("Loaded gui again")
        destroyed = true
        for i,v in pairs(toggles) do
            toggles[i] = false
        end
        --Rayfield:Destroy()
    end
end)

Window:SelectTab(1)