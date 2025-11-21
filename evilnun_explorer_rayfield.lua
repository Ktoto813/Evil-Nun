-- Evil Nun: Educational Explorer & ESP Script
-- Всё в одном: Rayfield GUI, автоматический поиск ключевых папок/предметов/килеров (и их вывод)

-- [1] Подключаем Rayfield для красивого GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [2] Главные сервисы и структуры
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer

-- [3] Сканировщик: ищет и сохраняет все найденные папки/модели, которые похожи на нужные (для ESP)
local foundItemFolders, foundKillerModels, foundOtherInteresting = {}, {}, {}

local function scanForTargets()
    foundItemFolders = {}
    foundKillerModels = {}
    foundOtherInteresting = {}
    local objlist = {}

    -- Соберём все объекты в Workspace, ReplicatedStorage (можно добавить больше сервисов)
    for _,serv in ipairs({Workspace, ReplicatedStorage}) do
        for _,obj in ipairs(serv:GetDescendants()) do
            local n = (obj.Name or ""):lower()

            -- Поиск потенциальных папок с предметами
            if (obj:IsA("Folder") or obj:IsA("Model")) and (n:find("key") or n:find("item") or n:find("pick")) then
                table.insert(foundItemFolders, obj:GetFullName())
            end

            -- Поиск потенциальных моделей-килеров/монстров
            if obj:IsA("Model") and (n:find("killer") or n:find("nun") or n:find("monster") or n:find("enemy")) then
                table.insert(foundKillerModels, obj:GetFullName())
            end

            -- Просто интересные объекты для вывода
            if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Tool") then
                if n:find("key") or n:find("card") or n:find("cog") or n:find("bible") then
                    table.insert(foundOtherInteresting, obj:GetFullName())
                end
            end
        end
    end
end

-- [4] Простой визуальный ESP — подсвечиваем предметы по имени
local highlights = setmetatable({}, {__mode="k"})
local function clearHighlights()
    for inst,hl in pairs(highlights) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    table.clear(highlights)
end

local function highlightIfNameMatch()
    clearHighlights()
    local itemKeys = {"golden key","small cabel","shovel key-card","pink key","blue key","heaven bible","cogwheel","blue key"}
    local killerKeys = {"killer","nun","evil nun"}
    for _,obj in ipairs(Workspace:GetDescendants()) do
        local n = (obj.Name or ""):lower()
        -- Highlight items
        for _,iname in ipairs(itemKeys) do
            if n:find(iname) and (obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Tool")) then
                local hl = Instance.new("Highlight")
                hl.Adornee = obj
                hl.FillColor = Color3.fromRGB(0,255,255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                hl.FillTransparency = 0.15
                hl.OutlineTransparency = 0
                hl.Parent = obj
                highlights[obj] = hl
            end
        end
        -- Highlight killers
        for _,kg in ipairs(killerKeys) do
            if n:find(kg) and obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local hl = Instance.new("Highlight")
                hl.Adornee = obj
                hl.FillColor = Color3.fromRGB(255,30,30)
                hl.OutlineColor = Color3.fromRGB(235,0,0)
                hl.FillTransparency = 0
                hl.OutlineTransparency = 0
                hl.Parent = obj
                highlights[obj] = hl
            end
        end
    end
end

-- [5] Rayfield GUI
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun AutoExplorer + ESP",
    LoadingTitle = "Evil Nun Tools",
    LoadingSubtitle = "auto-search, explorer, esp",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local Tab = Window:CreateTab("Игра Evil Nun")

-- Скрин/поиск структуры
Tab:CreateButton({
    Name = "Сканировать и показать важные разделы",
    Callback = function()
        scanForTargets()
        local msg = "\n[Потенциальные папки с предметами:]\n"
        for i,v in ipairs(foundItemFolders) do msg = msg .. tostring(i) .. ". " .. v .. "\n" end
        msg = msg .. "\n[Модели КИЛЛЕРОВ:]\n"
        for i,v in ipairs(foundKillerModels) do msg = msg .. tostring(i) .. ". " .. v .. "\n" end
        msg = msg .. "\n[Все ключевые объекты:]\n"
        for i,v in ipairs(foundOtherInteresting) do msg = msg .. tostring(i) .. ". " .. v .. "\n" end
        Rayfield:Notify({
            Title = "Результаты Поиска",
            Content = msg:sub(1, 1100), -- Rayfield limit
            Duration = 20
        })
    end
})

-- Добавь ESP
Tab:CreateToggle({
    Name = "ESP (выделить ключи и киллеров)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            highlightIfNameMatch()
        else
            clearHighlights()
        end
    end
})

Tab:CreateButton({
    Name = "Очистить все подсветки",
    Callback = function()
        clearHighlights()
    end
})

Tab:CreateButton({
    Name = "Скопировать результат поиска в Output",
    Callback = function()
        scanForTargets()
        print("=== [Evil Nun] ItemFolders ===")
        for i,v in ipairs(foundItemFolders) do print(i,v) end
        print("=== Killers ===")
        for i,v in ipairs(foundKillerModels) do print(i,v) end
        print("=== Interesting ===")
        for i,v in ipairs(foundOtherInteresting) do print(i,v) end
        Rayfield:Notify({Title="Эксплорер",Content="Результаты отправлены в Output",Duration=7})
    end
})

Rayfield:Notify({
    Title = "Evil Nun Explorer+ESP",
    Content = "Готово! Теперь легко найти, где лежат ключи и киллеры.",
    Duration = 6
})