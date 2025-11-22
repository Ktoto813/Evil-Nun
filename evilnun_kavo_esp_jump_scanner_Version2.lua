-- Evil Nun ESP+Jump+Scanner [Kavo UI, Whitelist, fully optimized for Xeno/any executor!]
-- Три вкладки: ESP, Jump, Scanner — подсвечиваются только нужные whitelist предметы ПОСЛЕ сканирования!
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Evil Nun | ESP + Jump + Scanner", "Ocean")

-- ==== ONLY THESE ITEMS WILL BE ESP'D! ====
local WHITELIST = {
    ["Golden Key"] = Color3.fromRGB(255, 213, 51),
    ["Blue Key"] = Color3.fromRGB(67,134,255),
    ["Master Key"] = Color3.fromRGB(202,245,110),
    ["Pink Key"] = Color3.fromRGB(255,107,182),
    ["Lockpick"] = Color3.fromRGB(255,170,75),
    ["small cabel"] = Color3.fromRGB(70,255,255),
    ["Heaven Bible"] = Color3.fromRGB(163,126,252),
    ["Cogwheel"] = Color3.fromRGB(128, 227, 153),
}
local ITEM_CUSTOMCOLOR = {}; for k,v in pairs(WHITELIST)do ITEM_CUSTOMCOLOR[k]=v end

-- =============== Сканер ==================
local scannedItems, scannedNames, scannerWasUsed = {}, {}, false

local function scanAllGameItems()
    scannedItems, scannedNames = {}, {}
    local RS, WS = game:GetService("ReplicatedStorage"), game:GetService("Workspace")
    local function folders()
        local f = {}
        local function add(x) if x then table.insert(f, x) end end
        add(RS:FindFirstChild("Items")); add(RS:FindFirstChild("Tools"))
        local maps = RS:FindFirstChild("Maps") if maps then for _,m in ipairs(maps:GetChildren())do add(m) end end
        local mf = WS:FindFirstChild("MapFolder") if mf then for _,m in ipairs(mf:GetChildren())do add(m) end end
        return f
    end
    for _,folder in ipairs(folders()) do
        for _,obj in ipairs(folder:GetDescendants())do
            if obj.Name and WHITELIST[obj.Name] and (obj:IsA("Tool") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                scannedItems[obj]=true scannedNames[obj.Name]=true
            end
        end
    end
    scannerWasUsed = true
end

local function getScannedNamesText()
    local t = {}
    for n in pairs(scannedNames) do table.insert(t, n) end
    table.sort(t)
    return #t==0 and "<нет>" or table.concat(t, "\n")
end

-- =============== ESP =====================
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
            hl.OutlineColor = Color3.fromRGB(15,15,15)
            hl.FillTransparency, hl.OutlineTransparency = 0.13, 0.01
            highlights[obj]=hl
        end
    end
end

-- =============== Jump ====================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local jumpBtn, jumpScreen, jumpConn
local function showJumpBtn(state)
    if state then
        if jumpScreen and jumpScreen.Parent then jumpScreen.Enabled=true return end
        jumpScreen = Instance.new("ScreenGui")
        jumpScreen.Name = "EvilNunJumpBtn"
        jumpScreen.Parent = game.CoreGui
        jumpBtn = Instance.new("TextButton")
        jumpBtn.Size = UDim2.new(0,120,0,48)
        jumpBtn.Position = UDim2.new(0.8,0,0.82,0)
        jumpBtn.BackgroundColor3 = Color3.fromRGB(0,160,255)
        jumpBtn.Text = "JUMP"
        jumpBtn.Font = Enum.Font.GothamBold
        jumpBtn.TextColor3 = Color3.new(1,1,1)
        jumpBtn.TextSize = 30
        jumpBtn.Parent = jumpScreen
        if jumpConn then jumpConn:Disconnect() end
        jumpConn = jumpBtn.MouseButton1Click:Connect(function()
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Jump=true end
            end
        end)
    else
        if jumpScreen then jumpScreen.Enabled=false end
    end
end

-- ===== Kavo UI: Вкладки и секции =====
local TabESP = Window:NewTab("ESP")
local TabJump = Window:NewTab("Jump")
local TabScan = Window:NewTab("Scanner")
local SectionESP = TabESP:NewSection("Подсветка работает ТОЛЬКО после сканирования карты!")
local SectionJump = TabJump:NewSection("Кнопка прыжка на экране")
local SectionScan = TabScan:NewSection("Сначала сканируй карту на whitelisted предметы")

SectionScan:NewButton("🔎 Сканировать карту", "Ищи только нужные предметы", function()
    scanAllGameItems()
    Library:Notify("Сканер завершён: "..getScannedNamesText())
    updateESP()
end)

SectionScan:NewTextBox("Все найденные:", "Будут ESP после включения", function() end, {
    ["clearTextOnFocus"] = false,
    ["text"] = getScannedNamesText(),
    ["OnlyNumbers"] = false
})

SectionESP:NewToggle("Включить ESP на whitelisted", "Подсвечивает только найденные сканнером!", function(state)
    ESP_ACTIVE = state
    updateESP()
end)
for item,defColor in pairs(WHITELIST) do
    SectionESP:NewColorPicker("Цвет ESP: "..item, "Измени цвет подсветки", defColor,
        function(clr) ITEM_CUSTOMCOLOR[item]=clr updateESP() end)
end
SectionESP:NewButton("Очистить всю подсветку", "Отключить ESP полностью", clearESP)

SectionJump:NewToggle("Показать кнопку прыжка (JUMP)", "Для мобильных/ПК", showJumpBtn)

-- Автообновление ESP
spawn(function()
    while true do
        if ESP_ACTIVE and scannerWasUsed then updateESP() end
        wait(2)
    end
end)

Library:Notify("Сначала вкладка Scanner, потом включай ESP! Цвета меняй в ESP!")