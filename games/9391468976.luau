--// Jujutsu Shenanigans

local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/iiX0Lords/Prisma_Utility/main/src/main/main.luau'),true))()
-- library:ChangeConfig({
--     ["Visible On Execution"] = tr,
-- })
library:Init()

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()

local runservice = game:GetService("RunService")

local toggles = {
    AntiStun = {
        Toggled = false,
        LegitMode = false,
    },
}


local combat = library:Window({
    Name = "Combat"
})

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

local antiStun = combat:Toggle({
    Name = "Anti-Stun",
    State = false,
    Func = function(self)
        toggles.AntiStun.Toggled = true
    end,
    OffFunc = function(self)
        toggles.AntiStun.Toggled = false
    end,
    Arguments = {
        {
            Title = "Legit Mode",
            Type = "Toggle",
            Repeating = false,
            State = false,
            Func = function(self, input)
                toggles.AntiStun.LegitMode = true
            end,
            OffFunc = function(self)
                toggles.AntiStun.LegitMode = false
            end
        },
    }
})