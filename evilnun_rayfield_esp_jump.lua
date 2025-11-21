-- Evil Nun Educational Rayfield ESP + Jump Script (by github.com/kauuuvuvu-max)

-- 1. Импорт Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- [НАСТРОЙКА ESP ПРЕДМЕТОВ]
local itemFolders = {} -- предметные папки
-- Собираем папки, где точно лежат ключи и инструменты (можно добавить ещё)
if RS:FindFirstChild("Items") then table.insert(itemFolders, RS.Items) end
if RS:FindFirstChild("Tools") then table.insert(itemFolders, RS.Tools) end
do -- Maps (Map1, Map2, ...)
    local maps = RS:FindFirstChild("Maps")
    if maps then
        for _,map in ipairs(maps:GetChildren()) do table.insert(itemFolders, map) end
    end
end
if Workspace:FindFirstChild("MapFolder") and Workspace.MapFolder:FindFirstChild("Map1") then
    table.insert(itemFolders, Workspace.MapFolder.Map1)
end

-- Список категорий ESP (можно добавить ещё)
local ESP_CATEGORIES = {
    Keys   = { names={"Key","Key-Card","Golden Key","Safe Key","Brown Key","Gray Key","Blue Key","Red Key","Violet Key","Purple Key","Green Key","Master Key","Barn Key","Locker Key","Storeroom Key","Helicopter Key"}, color=Color3.fromRGB(255,255,0) },
    Wires  = { names={"Cabel","Cable","small cabel"}, color=Color3.fromRGB(80,255,255) },
    Lockpicks = { names={"Lockpick"}, color=Color3.fromRGB(255,180,60) }
}
-- Для добавления ещё предметов просто дополняй категории по образцу выше

-- Стейт для включения/выключения селективного ESP
local espState = {}; for cat in pairs(ESP_CATEGORIES) do espState[cat] = false end

-- Цвета ESP по категориям (можно менять с помощью GUI)
local espColors = {}; for cat,data in pairs(ESP_CATEGORIES) do espColors[cat] = data.color end

-- Хранилище ярлыков подсветки
local highlights = setmetatable({}, {__mode="k"})

-- Очистить все подсветки
local function clearHighlights()
    for obj,hl in pairs(highlights) do if hl and hl.Parent then pcall(function() hl:Destroy() end) end end
    table.clear(highlights)
end

-- Главный цикл подсветки
local function updateESP()
    clearHighlights()
    -- Для каждой категории
    for cat,data in pairs(ESP_CATEGORIES) do
        if espState[cat] then
            local itemNames = {}
            for _,n in ipairs(data.names) do itemNames[n:lower()] = true end
            -- Проходим по всем папкам
            for _,folder in ipairs(itemFolders) do
                if folder then
                    for _,obj in ipairs(folder:GetDescendants()) do
                        if (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Tool")) and obj.Name and itemNames[obj.Name:lower()] then
                            if not highlights[obj] then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = obj
                                hl.FillColor = espColors[cat]
                                hl.OutlineColor = Color3.new(1,1,1)
                                hl.FillTransparency = 0.15
                                hl.OutlineTransparency = 0
                                hl.Parent = obj
                                highlights[obj] = hl
                            else
                                highlights[obj].FillColor = espColors[cat]
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Автоматический цикл обновления ESP
local autoESP = false
spawn(function()
    while true do
        if autoESP then updateESP() end
        task.wait(1)
    end
end)

-- =================== RAYFIELD GUI ===================
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun ESP+Jump (Educational)",
    LoadingTitle = "Evil Nun Educational",
    LoadingSubtitle = "by kauuuvuvu-max",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})

-- ========== ESP TAB ==========
local TabESP = Window:CreateTab("ESP")
TabESP:CreateSection("Включить ESP для...")

for cat,data in pairs(ESP_CATEGORIES) do
    TabESP:CreateToggle({
        Name = "["..cat.."] ("..table.concat(data.names, ", ")..")",
        CurrentValue = false,
        Callback = function(state)
            espState[cat]=state
            autoESP = next(espState, nil) ~= nil and (function()
                for _,v in pairs(espState) do if v then return true end end return false end
            end)()
            if not autoESP then clearHighlights() end
        end
    })
    TabESP:CreateColorPicker({
        Name = "Цвет ESP для "..cat,
        Color = data.color,
        Callback = function(color)
            espColors[cat]=color
            if autoESP then updateESP() end
        end
    })
end

TabESP:CreateButton({
    Name = "Очистить все подсветки",
    Callback = function()
        clearHighlights()
    end
})

-- ========== JUMP TAB ==========
local TabJump = Window:CreateTab("Jump")

local jumpBtnGui, jumpBtnConn
local function showJumpBtn(state)
    if state then
        if jumpBtnGui and jumpBtnGui.Parent then jumpBtnGui.Enabled=true return end
        jumpBtnGui = Instance.new("ScreenGui")
        jumpBtnGui.Name = "JumpButtonGui"
        jumpBtnGui.Parent = game.CoreGui

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 110, 0, 46)
        btn.Position = UDim2.new(0.85, 0, 0.85, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
        btn.Text = "JUMP"
        btn.TextSize = 28
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = jumpBtnGui

        jumpBtnConn = btn.MouseButton1Click:Connect(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildWhichIsA("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if jumpBtnGui then jumpBtnGui.Enabled=false end
    end
end

TabJump:CreateToggle({
    Name = "Показать/спрятать кнопку прыжка",
    CurrentValue = false,
    Callback = showJumpBtn
})

Rayfield:Notify({
    Title="Evil Nun ESP+Jump готов",
    Content="Можешь включать ESP для каждой категории отдельно и пользоваться кнопкой JUMP!",
    Duration=9
})