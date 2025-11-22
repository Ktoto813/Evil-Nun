-- Evil Nun Kavo UI: ESP на киллера + NOCLIP + Флай + FLING ALL [by kauuuvuv-coder]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Evil Nun | KILLER ESP+NoClip+Fly+Fling", "Ocean")

-- ESP Киллера
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

local function findKillers()
    local WS = game:GetService("Workspace")
    local list = {}
    for _,obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local lname = tostring(obj.Name):lower()
            if lname:find("nun") or lname:find("killer") or lname:find("bot") or lname:find("enemy") then
                table.insert(list, obj)
            end
        end
    end
    return list
end

local function updateKillerESP()
    clearESP()
    if not KILLER_ESP_ACTIVE then return end
    for _,obj in ipairs(findKillers()) do
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

-- FLY logic (WASD + Space/CTRL)
local fly_active = false
local flyConn = nil
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local fly_speed = 60
local flying = false
local key_dir = {Forward=false,Back=false,Left=false,Right=false,Up=false,Down=false}
local move_keys = {
    [Enum.KeyCode.W] = "Forward", [Enum.KeyCode.S] = "Back",
    [Enum.KeyCode.A] = "Left", [Enum.KeyCode.D] = "Right",
    [Enum.KeyCode.Space] = "Up", [Enum.KeyCode.LeftControl]="Down", [Enum.KeyCode.RightControl]="Down"
}

-- Для fly-keys:
local flyInputBegan, flyInputEnded
local function flyKeysInit()
    if flyInputBegan then flyInputBegan:Disconnect() end
    if flyInputEnded then flyInputEnded:Disconnect() end
    flyInputBegan = UIS.InputBegan:Connect(function(input,gp)
        if gp then return end
        local nm = move_keys[input.KeyCode]
        if nm then key_dir[nm] = true end
    end)
    flyInputEnded = UIS.InputEnded:Connect(function(input,gp)
        if gp then return end
        local nm = move_keys[input.KeyCode]
        if nm then key_dir[nm] = false end
    end)
end
local function flyKeysDisconnect()
    if flyInputBegan then flyInputBegan:Disconnect() end
    if flyInputEnded then flyInputEnded:Disconnect() end
end

local function toggle_fly(state)
    fly_active = state
    if flyConn then pcall(function() flyConn:Disconnect() end) end
    if not fly_active then
        flying = false
        flyKeysDisconnect()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
        return
    end
    flying = true
    flyKeysInit()
    flyConn = RS.RenderStepped:Connect(function(dt)
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not flying or not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local camCF = cam and cam.CFrame or hrp.CFrame
        local move = Vector3.new()
        if key_dir.Forward then move = move + camCF.LookVector end
        if key_dir.Back then move = move - camCF.LookVector end
        if key_dir.Left then move = move - camCF.RightVector end
        if key_dir.Right then move = move + camCF.RightVector end
        if key_dir.Up then move = move + Vector3.new(0,1,0) end
        if key_dir.Down then move = move - Vector3.new(0,1,0) end
        if move.Magnitude > 0.1 then
            hrp.Velocity = move.Unit * fly_speed
        else
            hrp.Velocity = Vector3.new(0,0,0)
        end
        hrp.RotVelocity = Vector3.new(0,0,0)
    end)
end

-- FLING ALL logic (KILLER)
local function flingAll()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local p = root.Position
    for _,mob in ipairs(findKillers()) do
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp and (hrp.Position - p).Magnitude < 100 then -- не слишком далеко
            hrp.Velocity = (hrp.Position - p).Unit * 200 + Vector3.new(0,80,0)
            -- Альтернативно: для сильного отлета
            -- hrp.Velocity = root.CFrame.LookVector*250 + Vector3.new(0,150,0)
            -- Или вообще в случайную сторону:
            -- hrp.Velocity = Vector3.new(math.random(-200,200),150,math.random(-200,200))
        end
    end
end

-- Kavo UI setup
local TabESP = Window:NewTab("KILLER ESP")
local SectionKiller = TabESP:NewSection("Подсвечивает врагов/килеров (через стены)")
SectionKiller:NewToggle("Включить ESP на Киллера", "Подсвечивает модели с именем 'nun', 'killer', 'enemy', 'bot'", function(state)
    KILLER_ESP_ACTIVE = state
    updateKillerESP()
end)
SectionKiller:NewColorPicker("Цвет ESP Киллера", "Выбери цвет подсветки", KILLER_COLOR, function(c)
    killerCustomColor = c
    updateKillerESP()
end)
SectionKiller:NewButton("Очистить подсветку", "Убрать все ESP", clearESP)
SectionKiller:NewButton("FLING ALL (отбросить всех врагов)", "Fling всех найденных NPC вокруг!", flingAll)

local TabNC = Window:NewTab("NOCLIP / FLY")
local SectionNC = TabNC:NewSection("Почти все стены и потолки — проходишь без коллизий\nФлай: WASD/Space/CTRL")
SectionNC:NewToggle("NOCLIP (проходить сквозь стены)", "Выкл/Вкл", toggle_noclip)
SectionNC:NewToggle("FLY (WASD + Space/CTRL)", "Выкл/Вкл, скорость: 60", toggle_fly)

Library:Notify("Killer ESP+Noclip+Fly+Fling загружен!\nFLING отбросит всех kill-ботов рядом.")