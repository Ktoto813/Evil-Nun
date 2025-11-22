-- Evil Nun Rayfield: ESP + JUMP + SCANNER (works only after scan) [2025 by kauuuvuv-coder]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace, RS, Players = game:GetService("Workspace"), game:GetService("ReplicatedStorage"), game:GetService("Players")
local LP = Players.LocalPlayer

-- Whitelisted предметы для ESP:
local WHITELIST = {
    ["Golden Key"] = Color3.fromRGB(255, 213, 51),
    ["Blue Key"] = Color3.fromRGB(67,134,255),
    ["Pink Key"] = Color3.fromRGB(255,107,182),
    ["Master Key"] = Color3.fromRGB(202,245,110),
    ["Lockpick"] = Color3.fromRGB(255,170,75),
    ["Heaven Bible"] = Color3.fromRGB(163,126,252),
    ["Cogwheel"] = Color3.fromRGB(128, 227, 153),
    ["small cabel"] = Color3.fromRGB(70,255,255),
}
local ITEM_CUSTOMCOLOR = {}; for k,v in pairs(WHITELIST) do ITEM_CUSTOMCOLOR[k]=v end

-- Scanner: только предметы, которые реально лежат на карте и подходят под whitelist
local scannedItems, scannedNames, scannerWasUsed = {}, {}, false
local function scanAllGameItems()
    scannedItems, scannedNames = {}, {}
    local folders = {}
    local function add(f) if f then table.insert(folders, f) end end
    add(RS:FindFirstChild("Items")); add(RS:FindFirstChild("Tools"))
    local maps = RS:FindFirstChild("Maps") if maps then for _,m in ipairs(maps:GetChildren())do add(m) end end
    local mf = Workspace:FindFirstChild("MapFolder") if mf then for _,m in ipairs(mf:GetChildren())do add(m) end end
    for _,folder in ipairs(folders)do
        for _,obj in ipairs(folder:GetDescendants())do
            if obj.Name and WHITELIST[obj.Name] and (obj:IsA("Tool") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                scannedItems[obj]=true scannedNames[obj.Name]=true
            end
        end
    end
    scannerWasUsed = true
end
local function getScannedNamesText()
    local t = {}; for n in pairs(scannedNames) do table.insert(t, n) end
    table.sort(t)
    return #t==0 and "<нет>" or table.concat(t, "\n")
end

-- ESP logic
local highlights, ESP_ACTIVE = setmetatable({}, {__mode="k"}), false
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
            hl.Adornee, hl.Parent = obj, obj
            hl.FillColor = ITEM_CUSTOMCOLOR[obj.Name] or Color3.new(1,1,1)
            hl.OutlineColor = Color3.fromRGB(10,10,10)
            hl.FillTransparency, hl.OutlineTransparency = 0.15, 0.01
            highlights[obj]=hl
        end
    end
end

-- JUMP logic (Screen button + пробел)
local jumpBtnGui, jumpBtnConn, jumpKeyConn
local jumpEnabled = false
local function jumpAction()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Jump = true end
    end
end
local function showJumpBtn(state)
    jumpEnabled = state
    -- КНОПКА НА ЭКРАНЕ
    if state then
        if jumpBtnGui and jumpBtnGui.Parent then jumpBtnGui.Enabled = true else
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
            jumpBtnConn = btn.MouseButton1Click:Connect(jumpAction)
        end
        -- Пробел (Space)
        if jumpKeyConn then jumpKeyConn:Disconnect() end
        jumpKeyConn = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.Space and jumpEnabled then
                jumpAction()
            end
        end)
    else
        if jumpBtnGui then jumpBtnGui.Enabled = false end
        if jumpKeyConn then jumpKeyConn:Disconnect() end
    end
end

-- === RAYFIELD UI ===
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun: ESP + SCANNER + JUMP",
    LoadingTitle = "Evil Nun Tools",
    LoadingSubtitle = "Rayfield MOD by kauuuvuv-coder",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})

-- SCANNER TAB
local tabScan = Window:CreateTab("Scanner")
tabScan:CreateSection("1. Сканируй whitelisted предметы")
tabScan:CreateButton({
    Name = "🔎 Сканировать карту (только whitelisted)",
    Callback = function()
        scanAllGameItems()
        Rayfield:Notify({
            Title = "Сканер завершён!",
            Content = "На карте: "..tostring(#(function() local n=0 for _ in pairs(scannedNames)do n=n+1 end return {n} end)()[1]).." предмет(а/ов)",
            Duration = 4
        })
        updateESP()
    end
})
tabScan:CreateParagraph({
    Title = "Найдено на карте:",
    Content = function() return getScannedNamesText() end
})

-- ESP TAB
local tabESP = Window:CreateTab("ESP")
tabESP:CreateSection("2. Включай ESP только после сканера!")
tabESP:CreateToggle({
    Name = "Включить ESP (по найденным)",
    CurrentValue = false,
    Callback = function(val)
        ESP_ACTIVE = val
        updateESP()
    end
})
for item,defColor in pairs(WHITELIST) do
    tabESP:CreateColorPicker({
        Name = "Цвет: "..item,
        Color = defColor,
        Callback = function(v)
            ITEM_CUSTOMCOLOR[item]=v
            updateESP()
        end
    })
end
tabESP:CreateButton({
    Name = "Очистить подсветку",
    Callback = clearESP
})

-- JUMP TAB
local tabJump = Window:CreateTab("Jump")
tabJump:CreateSection("3. Экранная кнопка и пробел (space) для прыжка")
tabJump:CreateToggle({
    Name = "Включить прыжок (кнопка и Space)",
    CurrentValue = false,
    Callback = showJumpBtn
})

Rayfield:Notify({
    Title="Evil Nun Tools",
    Content="1. Сканируй карту во вкладке Scanner\n2. Потом включай ESP! Прыжок через вкладку Jump, кнопка или пробел (Space).",
    Duration=7
})

spawn(function() -- авто ESP refresh, если было изменение
    while true do
        if ESP_ACTIVE and scannerWasUsed then updateESP() end
        wait(2)
    end
end)