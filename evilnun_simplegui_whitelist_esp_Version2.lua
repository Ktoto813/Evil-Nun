-- Evil Nun: SIMPLE GUI ESP/SCAN/JUMP [Only Roblox ScreenGui, Xeno-compatible]
-- kauuuvuv-coder, 2025

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

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")

local function CreateGui()
    -- Remove old GUI if any
    pcall(function() game.CoreGui:FindFirstChild("EvilNunGui"):Destroy() end)

    -- MainGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "EvilNunGui"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    -- Tabs frame
    local tabFrame = Instance.new("Frame", gui)
    tabFrame.Size = UDim2.new(0,370,0,42)
    tabFrame.Position = UDim2.new(0,20,0,130)
    tabFrame.BackgroundColor3 = Color3.fromRGB(32,32,32)
    tabFrame.BorderSizePixel = 0

    -- Helper to make tab buttons
    local function makeTabBtn(txt,pos)
        local b = Instance.new("TextButton", tabFrame)
        b.Size = UDim2.new(0,120,1,0)
        b.Position = UDim2.new(0,pos*120,0,0)
        b.Text = txt
        b.BackgroundColor3 = Color3.fromRGB(56,56,64)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 20
        b.TextColor3 = Color3.new(1,1,1)
        return b
    end

    -- Content containers
    local content = Instance.new("Frame", gui)
    content.Position = UDim2.new(0,20,0,180)
    content.Size = UDim2.new(0,370,0,250)
    content.BackgroundTransparency = 1
    local espCont = Instance.new("Frame", content)
    local scanCont = Instance.new("Frame", content)
    local jumpCont = Instance.new("Frame", content)
    for _,c in ipairs({espCont,scanCont,jumpCont}) do
        c.Size = UDim2.new(1,0,1,0)
        c.Visible = false
        c.BackgroundTransparency = 1
        c.ClipsDescendants = true
    end

    -- "Tabs"
    local currentTab = 2
    local function switchTab(i)
        currentTab = i
        espCont.Visible = i==1
        scanCont.Visible = i==2
        jumpCont.Visible = i==3
        for idx,b in ipairs(tabFrame:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = idx==i and Color3.fromRGB(45,110,180) or Color3.fromRGB(56,56,64)
            end
        end
    end
    makeTabBtn("ESP",0).MouseButton1Click:Connect(function() switchTab(1) end)
    makeTabBtn("СКАНЕР",1).MouseButton1Click:Connect(function() switchTab(2) end)
    makeTabBtn("JUMP",2).MouseButton1Click:Connect(function() switchTab(3) end)
    switchTab(2)

    -- ESP DATA
    local highlights = setmetatable({}, {__mode="k"})
    local scannedItems = {}
    local scannedNames = {}
    local scannerWasUsed = false
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
                hl.Adornee, hl.Parent = obj, obj
                hl.FillColor = WHITELIST[obj.Name] or Color3.new(1,1,1)
                hl.OutlineColor = Color3.fromRGB(15,15,15)
                hl.FillTransparency, hl.OutlineTransparency = 0.13, 0.01
                highlights[obj]=hl
            end
        end
    end

    -- === SCANNER SECTION ===
    local scanLbl = Instance.new("TextLabel", scanCont)
    scanLbl.Position = UDim2.new(0,0,0,0)
    scanLbl.Size = UDim2.new(1,0,0,32)
    scanLbl.Text = "Нажмите для сканирования карты!"
    scanLbl.Font = Enum.Font.GothamBold
    scanLbl.TextSize = 18
    scanLbl.TextColor3 = Color3.new(1,1,1)
    scanLbl.BackgroundTransparency = 1

    local scanButton = Instance.new("TextButton", scanCont)
    scanButton.Position = UDim2.new(0,0,0,36)
    scanButton.Size = UDim2.new(1,0,0,38)
    scanButton.Text = "🔎 Сканировать карту (только whitelisted)"
    scanButton.Font = Enum.Font.GothamBold
    scanButton.TextSize = 18
    scanButton.BackgroundColor3 = Color3.fromRGB(68,90,110)
    scanButton.TextColor3 = Color3.new(1,1,1)
    scanButton.AutoButtonColor = true

    local scanFrame = Instance.new("ScrollingFrame", scanCont)
    scanFrame.Position = UDim2.new(0,0,0,80)
    scanFrame.Size = UDim2.new(1,0,1,-80)
    scanFrame.BackgroundColor3 = Color3.fromRGB(52,54,56)
    scanFrame.BorderSizePixel = 0
    scanFrame.CanvasSize = UDim2.new(0,0,0,600)
    scanFrame.ScrollBarThickness = 5
    local scanLab = Instance.new("TextLabel", scanFrame)
    scanLab.Size=UDim2.new(1,-10,0,550)
    scanLab.BackgroundTransparency=1
    scanLab.TextXAlignment="Left"
    scanLab.TextYAlignment="Top"
    scanLab.TextSize=16
    scanLab.TextColor3=Color3.new(1,1,1)
    scanLab.Font=Enum.Font.Gotham

    local function drawScanNames()
        local t = {}
        for n in pairs(scannedNames) do table.insert(t, n) end
        table.sort(t)
        scanLab.Text = #t==0 and "(Ничего не найдено)" or "Найдено:\n"..table.concat(t,"\n")
    end

    scanButton.MouseButton1Click:Connect(function()
        -- SCAN!
        scannedItems = {}
        scannedNames = {}
        local folders = {}
        local function add(f) if f then table.insert(folders, f) end end
        add(RS:FindFirstChild("Items")); add(RS:FindFirstChild("Tools"))
        local maps = RS:FindFirstChild("Maps") if maps then for _,m in ipairs(maps:GetChildren()) do add(m) end end
        local mf = WS:FindFirstChild("MapFolder") if mf then for _,m in ipairs(mf:GetChildren()) do add(m) end end
        for _,folder in ipairs(folders) do
            for _,obj in ipairs(folder:GetDescendants()) do
                if obj.Name and WHITELIST[obj.Name] and (obj:IsA("Tool") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                    scannedItems[obj]=true scannedNames[obj.Name]=true
                end
            end
        end
        scannerWasUsed = true
        drawScanNames()
        if ESP_ACTIVE then updateESP() end
        scanLbl.Text = "Готово! Теперь включи ESP."
    end)
    drawScanNames()

    -- === ESP SECTION ===
    local espLbl = Instance.new("TextLabel", espCont)
    espLbl.AnchorPoint = Vector2.new(0.5,0)
    espLbl.Position = UDim2.new(0.5,0,0,0)
    espLbl.Size = UDim2.new(1,0,0,52)
    espLbl.Text = "Включить подсветку (только после сканирования)\nТолько строго whitelisted предметы!"
    espLbl.BackgroundTransparency = 1
    espLbl.Font = Enum.Font.GothamBold
    espLbl.TextSize = 15
    espLbl.TextColor3 = Color3.new(1,1,1)
    espLbl.TextWrapped = true

    local espBtn = Instance.new("TextButton", espCont)
    espBtn.Position = UDim2.new(0,0,0,55)
    espBtn.Size = UDim2.new(1,0,0,40)
    espBtn.Font = Enum.Font.GothamBold
    espBtn.TextSize = 20
    espBtn.BackgroundColor3 = Color3.fromRGB(35,200,120)
    espBtn.TextColor3 = Color3.new(1,1,1)
    espBtn.Text = "ВКЛЮЧИТЬ ESP"
    espBtn.AutoButtonColor = true

    local function updESPBtn()
        espBtn.Text = ESP_ACTIVE and "ОТКЛЮЧИТЬ ESP" or "ВКЛЮЧИТЬ ESP"
        espBtn.BackgroundColor3 = ESP_ACTIVE and Color3.fromRGB(128,40,30) or Color3.fromRGB(35,200,120)
    end
    updESPBtn()
    espBtn.MouseButton1Click:Connect(function()
        ESP_ACTIVE = not ESP_ACTIVE
        updESPBtn()
        updateESP()
    end)

    local espClrBtn = Instance.new("TextButton", espCont)
    espClrBtn.Position = UDim2.new(0,0,0,100)
    espClrBtn.Size = UDim2.new(1,0,0,32)
    espClrBtn.Text = "Очистить ESP"
    espClrBtn.Font = Enum.Font.Gotham
    espClrBtn.TextSize = 16
    espClrBtn.BackgroundColor3 = Color3.fromRGB(95,100,120)
    espClrBtn.TextColor3 = Color3.new(1,1,1)
    espClrBtn.MouseButton1Click:Connect(clearESP)

    -- === JUMP SECTION ===
    local jumpLbl = Instance.new("TextLabel", jumpCont)
    jumpLbl.Position = UDim2.new(0,0,0,0)
    jumpLbl.Size = UDim2.new(1,0,0,42)
    jumpLbl.BackgroundTransparency = 1
    jumpLbl.Text = "Кнопка прыжка на экране"
    jumpLbl.Font = Enum.Font.GothamBold
    jumpLbl.TextSize = 17
    jumpLbl.TextColor3 = Color3.new(1,1,1)

    local jumpBtnGui, jumpBtnConn
    local jumpBtn = Instance.new("TextButton", jumpCont)
    jumpBtn.Text = "Включить кнопку прыжка"
    jumpBtn.Position = UDim2.new(0,0,0,60)
    jumpBtn.Size = UDim2.new(1,0,0,40)
    jumpBtn.Font = Enum.Font.GothamBold
    jumpBtn.BackgroundColor3 = Color3.fromRGB(0,170,240)
    jumpBtn.TextSize = 20
    jumpBtn.TextColor3 = Color3.new(1,1,1)
    local jumpActive = false

    local function setJumpBtnState()
        jumpBtn.Text = jumpActive and "Убрать кнопку прыжка" or "Включить кнопку прыжка"
        jumpBtn.BackgroundColor3 = jumpActive and Color3.fromRGB(120,70,60) or Color3.fromRGB(0,170,240)
    end

    jumpBtn.MouseButton1Click:Connect(function()
        jumpActive = not jumpActive
        setJumpBtnState()
        if jumpActive then
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
    end)
    setJumpBtnState()

    -- === AUTO ESP REFRESH (optional) ===
    spawn(function()
        while true do
            if ESP_ACTIVE and scannerWasUsed then updateESP() end
            wait(2)
        end
    end)

    -- Notification tip
    local notif = Instance.new("TextLabel", gui)
    notif.AnchorPoint=Vector2.new(1,0)
    notif.Position=UDim2.new(1,-20,0,20)
    notif.Size=UDim2.new(0,270,0,33)
    notif.Text="Сначала вкладка СКАНЕР, потом ESP!"
    notif.TextColor3=Color3.fromRGB(255,255,245)
    notif.Font=Enum.Font.GothamBold
    notif.TextSize=18
    notif.BackgroundColor3=Color3.fromRGB(34,34,32)
    notif.BorderSizePixel=0
    notif.BackgroundTransparency=0.13
    notif.TextStrokeTransparency=0.74
    notif.TextXAlignment="Right"
    notif.TextYAlignment="Center"
    notif.ZIndex=55
    delay(8, function() notif:Destroy() end)
end

CreateGui()