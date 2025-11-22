-- Evil Nun Heavy Bypass Whitelist ESP (сильно оптимизировано и обходит много зависимостей!)
-- by kauuuvuv-coder 2025
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Evil Nun | MAX-BYPASS ESP + Fast", "Ocean")

local WHITELIST = {
    ["Golden Key"]   = Color3.fromRGB(255, 213, 51),
    ["Blue Key"]     = Color3.fromRGB(67,134,255),
    ["Pink Key"]     = Color3.fromRGB(255,107,182),
    ["Master Key"]   = Color3.fromRGB(202,245,110),
    ["Lockpick"]     = Color3.fromRGB(255,170,75),
    ["Heaven Bible"] = Color3.fromRGB(163,126,252),
    ["Cogwheel"]     = Color3.fromRGB(128, 227, 153),
    ["small cabel"]  = Color3.fromRGB(70,255,255),
}

local ITEM_CUSTOMCOLOR = {}; for k,v in pairs(WHITELIST)do ITEM_CUSTOMCOLOR[k]=v end

local highlights = setmetatable({}, {__mode="k"})
local ESP_ACTIVE = false

-- Быстрый обход: не хранить большой список, всегда только реальный предмет и только если его нет в highlights!
local function getAllCandidates()
    local RS, WS = game:GetService("ReplicatedStorage"), game:GetService("Workspace")
    local folders = {}
    local function add(f) if f then table.insert(folders, f) end end
    add(RS:FindFirstChild("Items")); add(RS:FindFirstChild("Tools"))
    local maps = RS:FindFirstChild("Maps") if maps then for _,m in ipairs(maps:GetChildren())do add(m) end end
    local mf = WS:FindFirstChild("MapFolder") if mf then for _,m in ipairs(mf:GetChildren())do add(m) end end
    local items = {}
    for _,folder in ipairs(folders)do
        for _,obj in ipairs(folder:GetDescendants())do
            if obj.Name and WHITELIST[obj.Name]
                and (obj:IsA("Tool") or obj:IsA("Part") or obj:IsA("MeshPart"))
                and obj:IsDescendantOf(game)
                and not highlights[obj]
            then
                items[#items+1] = obj
            end
        end
    end
    return items
end

local function addESP()
    local items = getAllCandidates()
    for _,obj in ipairs(items) do
        local ok,hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Adornee = obj
            h.FillColor = ITEM_CUSTOMCOLOR[obj.Name] or Color3.new(1,1,1)
            h.OutlineColor = Color3.fromRGB(43,51,89)
            h.FillTransparency = 0.11
            h.OutlineTransparency = 0.01
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = obj
            return h
        end)
        if ok and hl then
            highlights[obj] = hl
        end
    end
end

local function clearESP()
    for obj,hl in next, highlights do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end; highlights[obj]=nil
    end
end

-- Killer ESP (heavy bypass/opt)
local KILLER_COLOR = Color3.fromRGB(230,60,40)
local killerCustomColor = KILLER_COLOR
local KILLER_ESP_ACTIVE = false
local function updateKillerESP()
    if not KILLER_ESP_ACTIVE then return end
    local WS = game:GetService("Workspace")
    for _,obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local lname = tostring(obj.Name):lower()
            if lname:find("nun") or lname:find("killer") or lname:find("bot") then
                if not highlights[obj] then
                    local ok,hl=pcall(function()
                        local h=Instance.new("Highlight")
                        h.Adornee=obj
                        h.FillColor=killerCustomColor
                        h.OutlineColor=Color3.fromRGB(0,0,0)
                        h.FillTransparency=0.02
                        h.OutlineTransparency=0
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent=obj
                        return h
                    end)
                    if ok and hl then highlights[obj]=hl end
                else
                    highlights[obj].FillColor = killerCustomColor
                    highlights[obj].OutlineColor = Color3.fromRGB(0,0,0)
                end
            end
        end
    end
end

local TabESP = Window:NewTab("ESP")
local SectionESP = TabESP:NewSection("Whitelisted предметы + KILLER (Heavy/Bypass)")
SectionESP:NewToggle("Включить ESP по whitelisted", "Сильный оптимизированный обход", function(state)
    ESP_ACTIVE = state
    if not state then clearESP() else addESP() end
end)
SectionESP:NewButton(" Моментально обновить ESP", "Добавить ESP на появившееся вещи", function()
    if ESP_ACTIVE then addESP() end
end)
for item,defColor in pairs(WHITELIST) do
    SectionESP:NewColorPicker("Цвет ESP: "..item, "Меняй цвет предмета", defColor,
        function(clr) ITEM_CUSTOMCOLOR[item]=clr if ESP_ACTIVE then addESP() end end)
end
SectionESP:NewButton("Очистить всю подсветку", "Отключить ESP", clearESP)
SectionESP:NewToggle("ESP на Киллера", "Красная сильная подсветка на врага", function(state)
    KILLER_ESP_ACTIVE = state
    if state then updateKillerESP() else clearESP() end
end)
SectionESP:NewColorPicker("Цвет ESP Киллера", "Меняй цвет кильлера", KILLER_COLOR, function(c)
    killerCustomColor = c
    updateKillerESP()
end)

-- Jump
local TabJump = Window:NewTab("Jump")
local SectionJump = TabJump:NewSection("Кнопка прыжка на экране и Space")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local jumpBtn, jumpScreen, jumpConn, jumpKeyConn
local jumpEnabled = false

local function jumpAction()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Jump=true end
    end
end
local function showJumpBtn(state)
    jumpEnabled = state
    if state then
        if jumpScreen and jumpScreen.Parent then jumpScreen.Enabled=true else
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
            jumpConn = jumpBtn.MouseButton1Click:Connect(jumpAction)
        end
        if jumpKeyConn then jumpKeyConn:Disconnect() end
        jumpKeyConn = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.Space and jumpEnabled then
                jumpAction()
            end
        end)
    else
        if jumpScreen then jumpScreen.Enabled=false end
        if jumpKeyConn then jumpKeyConn:Disconnect() end
    end
end
SectionJump:NewToggle("Прыжок (Space+кнопка)", "Включает прыжок", showJumpBtn)

Library:Notify("MAX-обход ESP: он подсвечивает только whitelisted предметы моментально и не грузит FPS!\n(Нажимайте 'Моментально обновить ESP' при необходимости!)")