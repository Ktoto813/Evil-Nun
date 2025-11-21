-- Evil Nun Rayfield ESP + Jump (for: Golden Key, Lockpick, Blue Key, Pink Key, small cabel, Heaven Bible, Cogwheel, Киллеры, Игроки)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Где ищем предметы
local itemFolders = {}
if RS:FindFirstChild("Items") then table.insert(itemFolders, RS.Items) end
if RS:FindFirstChild("Tools") then table.insert(itemFolders, RS.Tools) end
do
    local maps = RS:FindFirstChild("Maps")
    if maps then
        for _,map in ipairs(maps:GetChildren()) do
            table.insert(itemFolders, map)
        end
    end
end
if Workspace:FindFirstChild("MapFolder") and Workspace.MapFolder:FindFirstChild("Map1") then
    table.insert(itemFolders, Workspace.MapFolder.Map1)
end

-- Список ESP категорий
local ESP_CATEGORIES = {
    GoldenKey   = { names={"Golden Key"}, color=Color3.fromRGB(255, 213, 51) },
    Lockpick    = { names={"Lockpick"}, color=Color3.fromRGB(255,170,75) },
    BlueKey     = { names={"Blue Key"}, color=Color3.fromRGB(67,134,255) },
    PinkKey     = { names={"Pink Key"}, color=Color3.fromRGB(255,107,182) },
    SmallCabel  = { names={"small cabel"}, color=Color3.fromRGB(70,255,255) },
    HeavenBible = { names={"Heaven Bible"}, color=Color3.fromRGB(163,126,252) },
    Cogwheel    = { names={"Cogwheel"}, color=Color3.fromRGB(202,245,110) },
    Killer      = { names={}, color=Color3.fromRGB(255,0,64) },
    Player      = { names={}, color=Color3.fromRGB(80,180,255) },
}

local espState, espColors = {}, {}
for cat,v in pairs(ESP_CATEGORIES) do espState[cat] = false; espColors[cat] = v.color end
local highlights = setmetatable({}, {__mode="k"})

local function clearHighlights()
    for obj,hl in pairs(highlights) do if hl and hl.Parent then pcall(function() hl:Destroy() end) end end
    table.clear(highlights)
end

local autoESP = false
local function updateESP()
    clearHighlights()
    -- Предметы
    for cat,def in pairs(ESP_CATEGORIES) do
        if espState[cat] and not (cat=="Killer" or cat=="Player") then
            local nameSet = {}; for _,name in ipairs(def.names) do nameSet[name:lower()] = true end
            for _,folder in ipairs(itemFolders) do
                if folder then
                    for _,obj in ipairs(folder:GetDescendants()) do
                        if (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Tool")) and obj.Name and nameSet[obj.Name:lower()] then
                            local hl = highlights[obj]
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Adornee = obj
                                hl.FillTransparency = 0.15
                                hl.OutlineTransparency = 0
                                hl.Parent = obj
                                highlights[obj] = hl
                            end
                            hl.FillColor = espColors[cat]
                            hl.OutlineColor = Color3.new(1,1,1)
                        end
                    end
                end
            end
        end
    end
    -- Киллеры (ищем по модели с HumanoidRootPart и именам)
    if espState.Killer then
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local n = (obj.Name or ""):lower()
                if n:find("nun") or n:find("killer") or n:find("bot") then
                    if not highlights[obj] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = obj
                        hl.FillTransparency = 0.08
                        hl.OutlineTransparency = 0
                        hl.Parent = obj
                        highlights[obj] = hl
                    end
                    highlights[obj].FillColor = espColors.Killer
                    highlights[obj].OutlineColor = Color3.fromRGB(0,0,0)
                end
            end
        end
    end
    -- Игроки (все, кроме тебя)
    if espState.Player then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                if not highlights[pl.Character] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = pl.Character
                    hl.FillTransparency = 0.11
                    hl.OutlineTransparency = 0
                    hl.Parent = pl.Character
                    highlights[pl.Character] = hl
                end
                highlights[pl.Character].FillColor = espColors.Player
                highlights[pl.Character].OutlineColor = Color3.fromRGB(0,0,0)
            end
        end
    end
end

-- Авто-обновление ESP
spawn(function()
    while true do
        if autoESP then updateESP() end
        task.wait(1)
    end
end)

-- ==== Rayfield GUI ====
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun ESP+Jump",
    LoadingTitle = "Evil Nun",
    LoadingSubtitle = "by kauuuvuvu-max",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})

-- === ESP Tab ===
local TabESP = Window:CreateTab("ESP")
TabESP:CreateSection("Включить ESP:")

-- Индивидуальные тумблеры и цвета
for cat,def in pairs(ESP_CATEGORIES) do
    TabESP:CreateToggle({
        Name = "ESP: " .. cat,
        CurrentValue = false,
        Callback = function(state)
            espState[cat]=state
            autoESP = false; for _,v in pairs(espState) do autoESP = autoESP or v end
            if not autoESP then clearHighlights() end
        end,
    })
    TabESP:CreateColorPicker({
        Name = "Цвет: " .. cat,
        Color = def.color,
        Callback = function(color)
            espColors[cat]=color
            if autoESP then updateESP() end
        end
    })
end
TabESP:CreateButton({
    Name = "Очистить подсветку",
    Callback = function() clearHighlights() end
})

-- === Jump Tab ===
local TabJump = Window:CreateTab("Jump")
local jumpBtnGui, jumpBtnConn
local function showJumpBtn(state)
    if state then
        if jumpBtnGui and jumpBtnGui.Parent then jumpBtnGui.Enabled = true return end
        jumpBtnGui = Instance.new("ScreenGui")
        jumpBtnGui.Name = "JumpButtonGui"
        jumpBtnGui.Parent = game.CoreGui

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 0, 48)
        btn.Position = UDim2.new(0.8, 0, 0.82, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0,160,255)
        btn.Text = "JUMP"
        btn.TextSize = 30
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = jumpBtnGui

        jumpBtnConn = btn.MouseButton1Click:Connect(function()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if jumpBtnGui then jumpBtnGui.Enabled = false end
    end
end

TabJump:CreateToggle({
    Name = "Кнопка прыжка (JUMP)",
    CurrentValue = false,
    Callback = showJumpBtn
})

Rayfield:Notify({
    Title="Evil Nun ESP+Jump",
    Content="Можешь включать и менять цвет для: Golden Key, Lockpick, Blue Key, Pink Key, small cabel, Heaven Bible, Cogwheel, Киллеров и игроков.",
    Duration=9
})