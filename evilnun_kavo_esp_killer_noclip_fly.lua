-- Evil Nun Kavo UI: ESP на киллера + NOCLIP + Флай [by kauuuvuv-coder]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Evil Nun | KILLER ESP+NoClip+Fly", "Ocean")

local KILLER_COLOR = Color3.fromRGB(255,50,60)
local killerCustomColor = KILLER_COLOR
local highlights = setmetatable({}, {__mode="k"})
local KILLER_ESP_ACTIVE = false

local function clearESP()
    for obj,hl in pairs(highlights) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    table.clear(highlights)
end

local function updateKillerESP()
    clearESP()
    if not KILLER_ESP_ACTIVE then return end
    local WS = game:GetService("Workspace")
    for _,obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local lname = tostring(obj.Name):lower()
            if lname:find("nun") or lname:find("killer") or lname:find("bot") then
                if not highlights[obj] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = obj
                    hl.FillColor = killerCustomColor
                    hl.OutlineColor = Color3.fromRGB(0,0,0)
                    hl.FillTransparency = 0.08
                    hl.OutlineTransparency = 0.01
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = obj
                    highlights[obj] = hl
                else
                    highlights[obj].FillColor = killerCustomColor
                    highlights[obj].OutlineColor = Color3.fromRGB(0,0,0)
                end
            end
        end
    end
end

-- NOCLIP logic
local noclip_active = false
local noclip_conn = nil
local function toggle_noclip(state)
    noclip_active = state
    if noclip_conn then pcall(function() noclip_conn:Disconnect() end) end
    if noclip_active then
        noclip_conn = game:GetService("RunService").Stepped:Connect(function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                for _,v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide == true then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- FLY logic (v3: shift - up, ctrl - down, WASD move)
local fly_active = false
local flyConn = nil
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local fly_speed = 60
local flying = false
local fly_dir = Vector3.new(0,0,0)
local last_cf = nil

local function toggle_fly(state)
    fly_active = state
    if flyConn then pcall(function() flyConn:Disconnect() end) end

    local key_dir = {Forward=false,Back=false,Left=false,Right=false, Up=false, Down=false}
    local move_keys = {
        [Enum.KeyCode.W] = "Forward", [Enum.KeyCode.S] = "Back",
        [Enum.KeyCode.A] = "Left", [Enum.KeyCode.D] = "Right",
        [Enum.KeyCode.Space] = "Up", [Enum.KeyCode.LeftControl]="Down", [Enum.KeyCode.RightControl]="Down"
    }

    if fly_active then
        flying = true
        flyConn = RS.RenderStepped:Connect(function(dt)
            local player = game.Players.LocalPlayer
            local char = player.Character
            if not flying or not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            local cam = workspace.CurrentCamera
            local camCF = cam and cam.CFrame or hrp.CFrame
            -- Calculate move dir:
            local move = Vector3.new()
            if key_dir.Forward then move = move + camCF.LookVector end
            if key_dir.Back then move = move - camCF.LookVector end
            if key_dir.Left then move = move - camCF.RightVector end
            if key_dir.Right then move = move + camCF.RightVector end
            if key_dir.Up then move = move + Vector3.new(0,1,0) end
            if key_dir.Down then move = move - Vector3.new(0,1,0) end
            if move.Magnitude > 0.1 then
                hrp.Velocity = move.Unit * fly_speed
                last_cf = camCF
            else
                hrp.Velocity = Vector3.new(0,0,0)
            end
            hrp.RotVelocity = Vector3.new(0,0,0)
        end)
        -- Key control --
        UIS.InputBegan:Connect(function(input,gp)
            if gp then return end
            local nm = move_keys[input.KeyCode]
            if nm then key_dir[nm] = true end
        end)
        UIS.InputEnded:Connect(function(input,gp)
            if gp then return end
            local nm = move_keys[input.KeyCode]
            if nm then key_dir[nm] = false end
        end)
    else
        flying = false
        if flyConn then flyConn:Disconnect() end
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Velocity = Vector3.new(0,0,0) end
    end
end

-- Kavo UI Setup
local TabESP = Window:NewTab("KILLER ESP")
local SectionKiller = TabESP:NewSection("Подсвечивает врагов/килеров (через стены)")
SectionKiller:NewToggle("Включить ESP на Киллера", "Подсвечивает модели с именем 'nun', 'killer' или 'bot'", function(state)
    KILLER_ESP_ACTIVE = state
    updateKillerESP()
end)
SectionKiller:NewColorPicker("Цвет ESP Киллера", "Выбери цвет подсветки", KILLER_COLOR, function(c)
    killerCustomColor = c
    updateKillerESP()
end)
SectionKiller:NewButton("Очистить подсветку", "Убрать все ESP", clearESP)

local TabNC = Window:NewTab("NOCLIP / FLY")
local SectionNC = TabNC:NewSection("Движение по карте — баги снимаются перезапуском персонажа")
SectionNC:NewToggle("NOCLIP (проходить сквозь стены)", "Выкл/Вкл", toggle_noclip)
SectionNC:NewToggle("FLY (WASD + Space/CTRL)", "Выкл/Вкл, скорость: 60", toggle_fly)

Library:Notify("Killer ESP+Noclip+Fly загружен!\nКоллизии только у NOCLIP, FLY - WASD/Space/CTRL")