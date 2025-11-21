-- Evil Nun Rayfield Universal ESP + Jump Button (Оптимизировано, без лагов!)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace, RS, Players = game:GetService("Workspace"), game:GetService("ReplicatedStorage"), game:GetService("Players")
local LP = Players.LocalPlayer

-- Автоматический сбор всех папок с предметами для ESP
local function getItemFolders()
    local folders = {}
    for _,name in ipairs({"Items","Tools"}) do
        local f = RS:FindFirstChild(name)
        if f then table.insert(folders, f) end
    end
    local mapsRS = RS:FindFirstChild("Maps")
    if mapsRS then
        for _,map in ipairs(mapsRS:GetChildren()) do table.insert(folders, map) end
    end
    local mf = Workspace:FindFirstChild("MapFolder")
    if mf then
        for _,map in ipairs(mf:GetChildren()) do table.insert(folders, map) end
    end
    return folders
end

-- Категории ESP
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

-- Основной массив подсветок
local highlights = setmetatable({}, {__mode="k"})

-- Утилиты поиска имени
local function matchCat(obj, cat)
    local def = ESP_CATEGORIES[cat]
    if not (obj and obj.Name) then return false end
    local n = obj.Name:lower()
    for _,cmp in ipairs(def.names) do
        if n == cmp:lower() then return true end
    end
    return false
end

-- Оптимизированное "подвешивание" Highlight только к новым объектам
local function tryHighlight(obj, cat)
    if not obj or highlights[obj] or not obj.Parent then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = (obj:IsA("Model") and obj or obj)
    hl.FillTransparency = 0.15
    hl.OutlineTransparency = 0
    hl.FillColor = espColors[cat]
    hl.OutlineColor = Color3.new(1,1,1)
    hl.Parent = obj
    highlights[obj] = hl
end

-- Убираем только то, что реально нужно убрать
local function removeHighlight(obj)
    local hl = highlights[obj]
    if hl then pcall(function() hl:Destroy() end); highlights[obj]=nil end
end

-- Продвинутая подписка на объекты для ESP (Только когда включено!)
local listeners = {}
local function clearListeners()
    for _,conn in ipairs(listeners) do pcall(function() conn:Disconnect() end) end
    table.clear(listeners)
end

-- MAIN: Запуск оптимального ESP
local function enableESP()
    local folders = getItemFolders()
    -- Подсветка для ключей и других предметов
    for cat in pairs(ESP_CATEGORIES) do
        if cat ~= "Killer" and cat ~= "Player" and espState[cat] then
            for _,folder in ipairs(folders) do
                for _,obj in ipairs(folder:GetDescendants()) do
                    if (obj:IsA("BasePart") or obj:IsA("Tool")) and matchCat(obj, cat) then
                        tryHighlight(obj, cat)
                    end
                end
                -- следим за новыми
                local conn = folder.DescendantAdded:Connect(function(obj)
                    if (obj:IsA("BasePart") or obj:IsA("Tool")) and matchCat(obj, cat) then
                        tryHighlight(obj, cat)
                    end
                end)
                table.insert(listeners, conn)
            end
        end
    end
    -- Киллеры
    if espState.Killer then
        local function isKiller(model)
            if not (model and model:IsA("Model")) then return false end
            local n = (model.Name or ""):lower()
            if (n:find("nun") or n:find("killer") or n:find("bot")) and model:FindFirstChild("HumanoidRootPart") then
                return true
            end
            return false
        end
        for _,model in ipairs(Workspace:GetDescendants()) do
            if isKiller(model) then tryHighlight(model, "Killer") end
        end
        -- следим за всеми новыми
        local conn = Workspace.DescendantAdded:Connect(function(obj) if isKiller(obj) then tryHighlight(obj, "Killer") end end)
        table.insert(listeners, conn)
    end
    -- Игроки
    if espState.Player then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                tryHighlight(pl.Character, "Player")
            end
            local conn = pl.CharacterAdded:Connect(function(char)
                wait(0.2)
                if char and char:FindFirstChild("HumanoidRootPart") then tryHighlight(char, "Player") end
            end)
            table.insert(listeners, conn)
        end
        -- новых игроков вешаем тоже
        local conn = Players.PlayerAdded:Connect(function(pl)
            local chConn
            chConn = pl.CharacterAdded:Connect(function(char)
                wait(0.2)
                if char and char:FindFirstChild("HumanoidRootPart") then tryHighlight(char, "Player") end
            end)
            table.insert(listeners, chConn)
        end)
        table.insert(listeners, conn)
    end
end

-- Полная очистка ESP и слушателей
local function disableESP()
    for obj,hl in pairs(highlights) do if hl then pcall(function() hl:Destroy() end) highlights[obj]=nil end end
    clearListeners()
end

-- ====== RAYFIELD GUI ======
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun ESP + Jump [TurboOptimized]",
    LoadingTitle = "Evil Nun ESP",
    LoadingSubtitle = "Оптимизация для любых карт и без лагов",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})

-- ESP Tab
local TabESP = Window:CreateTab("ESP")
TabESP:CreateSection("Включить ESP для нужных предметов:")

for cat,def in pairs(ESP_CATEGORIES) do
    TabESP:CreateToggle({
        Name = "ESP: " .. cat,
        CurrentValue = false,
        Callback = function(state)
            espState[cat]=state
            disableESP()
            local active = false; for _,v in pairs(espState) do active = active or v end
            if active then enableESP() end
        end,
    })
    TabESP:CreateColorPicker({
        Name = "Цвет: " .. cat,
        Color = def.color,
        Callback = function(color)
            espColors[cat]=color
            -- обновить только цвет у уже подсвеченных:
            for obj,hl in pairs(highlights) do
                if hl and hl.Parent and matchCat(obj,cat) then
                    hl.FillColor = color
                end
            end
        end
    })
end

TabESP:CreateButton({
    Name = "Очистить всю подсветку",
    Callback = disableESP
})

-- Jump Tab (новая реализация!)
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
        if jumpBtnConn then jumpBtnConn:Disconnect() end
        jumpBtnConn = btn.MouseButton1Click:Connect(function()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Jump = true end
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
    Content="Работает без лагов! Предметы и киллеры подсвечиваются сразу, без фризов.",
    Duration=9
})