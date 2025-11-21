-- Evil Nun Rayfield Universal ESP + Jump Button (Максимальная совместимость для любых карт и предметов!)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace, RS, Players = game:GetService("Workspace"), game:GetService("ReplicatedStorage"), game:GetService("Players")
local LP = Players.LocalPlayer

-- Автоматический сбор ВСЕХ папок с картами/предметами (никогда не устареет)
local function getItemFolders()
    local folders = {}
    -- ReplicatedStorage.Items, Tools
    for _,name in ipairs({"Items","Tools"}) do
        local f = RS:FindFirstChild(name)
        if f then table.insert(folders, f) end
    end
    -- ReplicatedStorage.Maps и все вложенные
    local mapsRS = RS:FindFirstChild("Maps")
    if mapsRS then
        for _,map in ipairs(mapsRS:GetChildren()) do
            table.insert(folders, map)
        end
    end
    -- Workspace.MapFolder и все MapX
    local mf = Workspace:FindFirstChild("MapFolder")
    if mf then
        for _,map in ipairs(mf:GetChildren()) do
            table.insert(folders, map)
        end
    end
    return folders
end

-- Категории предметов для ESP
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
    local folders = getItemFolders()
    -- Предметы
    for cat,def in pairs(ESP_CATEGORIES) do
        if espState[cat] and not (cat=="Killer" or cat=="Player") then
            local nameSet = {}; for _,name in ipairs(def.names) do nameSet[name:lower()] = true end
            for _,folder in ipairs(folders) do
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
    -- Киллеры (ищем по HumanoidRootPart и имени)
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
    -- Игроки (все, кроме LP)
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

-- Постоянное обновление ESP по новым картам и динамике игры
spawn(function()
    while true do
        if autoESP then updateESP() end
        task.wait(1)
    end
end)

-- ===== Rayfield GUI ===========
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun ESP + Jump [UNIVERSAL]",
    LoadingTitle = "Evil Nun ESP",
    LoadingSubtitle = "Работает на любых локациях",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})

-- === ESP Tab ===
local TabESP = Window:CreateTab("ESP")
TabESP:CreateSection("Включить ESP для нужных предметов:")

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
    Callback = clearHighlights
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
    Content="ESP работает на любых картах! Кнопка прыжка обновлена!",
    Duration=8
})