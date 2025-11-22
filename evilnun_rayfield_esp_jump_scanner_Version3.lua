-- Evil Nun Universal - Rayfield ESP, Scanner, Jump [STRICT WHITELIST, оптимизировано]
-- По пожеланиям: только Golden Key, Blue Key, Master Key, Pink Key, Lockpick, Small Cable, Heaven Bible, Cogwheel
if not game:GetService('CoreGui') then error("CoreGui не найден! Попробуй другой Executor.") end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace, RS, Players = game:GetService("Workspace"), game:GetService("ReplicatedStorage"), game:GetService("Players")
local LP = Players.LocalPlayer

--==== СТРОГОЕ МЕНЮ ПРЕДМЕТОВ ====--
local ITEM_WHITELIST = {
    ["Golden Key"] = true,
    ["Blue Key"] = true,
    ["Master Key"] = true,
    ["Pink Key"] = true,
    ["Lockpick"] = true,
    ["small cabel"] = true,
    ["Heaven Bible"] = true,
    ["Cogwheel"] = true,
}
local ESP_COLORS = {
    ["Golden Key"] = Color3.fromRGB(255, 213, 51),
    ["Blue Key"]   = Color3.fromRGB(67,134,255),
    ["Master Key"] = Color3.fromRGB(202,245,110),
    ["Pink Key"]   = Color3.fromRGB(255,107,182),
    ["Lockpick"]   = Color3.fromRGB(255,170,75),
    ["small cabel"]= Color3.fromRGB(70,255,255),
    ["Heaven Bible"]= Color3.fromRGB(163,126,252),
    ["Cogwheel"]   = Color3.fromRGB(128, 227, 153),
}
local ITEM_COLOR_PICKER = {}
for name,col in pairs(ESP_COLORS) do ITEM_COLOR_PICKER[name]=col end

--======== СКАННЕР =======--
local scannedItems = {}      -- [Instance] = true
local scannedNames = {}      -- [имя (с регистрацией)] = true
local scannerWasUsed = false

local function scanAllGameItems()
    table.clear(scannedItems)
    table.clear(scannedNames)
    -- Только строго whitelisted!
    local folders = {}
    local function addFolder(f) if f then table.insert(folders, f) end end
    addFolder(RS:FindFirstChild("Items"))
    addFolder(RS:FindFirstChild("Tools"))
    local maps = RS:FindFirstChild("Maps") if maps then for _,m in ipairs(maps:GetChildren()) do addFolder(m) end end
    local worldMap = Workspace:FindFirstChild("MapFolder") if worldMap then for _,m in ipairs(worldMap:GetChildren()) do addFolder(m) end end

    for _,folder in ipairs(folders) do
        for _,desc in ipairs(folder:GetDescendants()) do
            if desc.Name and ITEM_WHITELIST[desc.Name] and (desc:IsA("Tool") or desc:IsA("Part") or desc:IsA("MeshPart")) then
                scannedItems[desc] = true
                scannedNames[desc.Name] = true
            end
        end
    end
    scannerWasUsed = true
end

local function getScannedNamesText()
    local items = {}
    for n in pairs(scannedNames) do table.insert(items, n) end
    table.sort(items)
    return #items==0 and "<нет ничего>" or table.concat(items, "\n")
end

--======== ESP =======--
local highlights = setmetatable({}, {__mode="k"})
local ESP_ACTIVE = false
local function clearESP()
    for obj,hl in pairs(highlights) do if hl and hl.Parent then pcall(function() hl:Destroy() end) end end
    table.clear(highlights)
end
local function updateESP()
    clearESP()
    if not (ESP_ACTIVE and scannerWasUsed) then return end
    for obj in pairs(scannedItems) do
        if obj:IsDescendantOf(game) then
            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            local cname = obj.Name
            hl.FillColor = ITEM_COLOR_PICKER[cname] or Color3.new(1,1,1)
            hl.OutlineColor = Color3.fromRGB(10,10,10)
            hl.FillTransparency = 0.15
            hl.OutlineTransparency = 0.01
            hl.Parent = obj
            highlights[obj] = hl
        end
    end
end

--=== JUMP ===--
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
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Jump = true end
            end
        end)
    else
        if jumpBtnGui then jumpBtnGui.Enabled = false end
    end
end

--========= RAYFIELD UI =========--
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun: ESP/SCAN/JUMP",
    LoadingTitle = "Evil Nun Tools",
    LoadingSubtitle = "Whitelist ESP Edition",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})

--=== 1. SCANNER TAB ===
local tabScan = Window:CreateTab("Scanner")
tabScan:CreateSection("Просканируй только whitelisted-предметы")

tabScan:CreateButton({
    Name = "🔎 Сканировать карту на ключи и нужные предметы",
    Callback = function()
        scanAllGameItems()
        Rayfield:Notify({
            Title = "Сканер завершён!",
            Content = "На карте найдено: " .. tostring(#(function() local c=0 for _ in pairs(scannedNames) do c=c+1 end return {c} end)()[1]),
            Duration = 5
        })
        updateESP()
    end
})

tabScan:CreateParagraph({
    Title = "Можно подсветить:",
    Content = function()
        return getScannedNamesText()
    end
})

--=== 2. ESP TAB ===
local tabESP = Window:CreateTab("ESP")
tabESP:CreateSection("Подсветка ТОЛЬКО после сканирования!")
tabESP:CreateToggle({
    Name = "Включить ESP на whitelisted-предметы",
    CurrentValue = false,
    Callback = function(val)
        ESP_ACTIVE = val
        updateESP()
    end
})
for item,defColor in pairs(ESP_COLORS) do
    tabESP:CreateColorPicker({
        Name = "Цвет: " .. item,
        Color = defColor,
        Callback = function(v)
            ITEM_COLOR_PICKER[item] = v
            updateESP()
        end
    })
end
tabESP:CreateButton({
    Name = "Очистить всю подсветку",
    Callback = function()
        clearESP()
        Rayfield:Notify({Title = "ESP", Content = "Подсветка OFF", Duration = 2})
    end
})

--=== 3. JUMP TAB ===
local tabJump = Window:CreateTab("JUMP")
tabJump:CreateToggle({
    Name = "Показать кнопку прыжка (JUMP)",
    CurrentValue = false,
    Callback = showJumpBtn
})

Rayfield:Notify({
    Title="Evil Nun Tools: ESP + SCANNER + JUMP",
    Content="Сначала сканируй, потом включай ESP. Только актуальные whitelisted объекты.",
    Duration=8
})

--=== Автообновление ESP при появлении/уходе ===--
spawn(function()
    while true do
        if ESP_ACTIVE and scannerWasUsed then updateESP() end
        wait(2)
    end
end)