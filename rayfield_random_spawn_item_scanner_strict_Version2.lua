-- Rayfield: Только рандомно спавнящиеся собираемые предметы (ключи, кабели, ломы, cogwheel, heaven bible, card)

local RayfieldOk, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not RayfieldOk or not Rayfield then
    warn("[Rayfield] Не удалось загрузить Rayfield! Проверь интернет/эксплойт!")
    return
end

-- Чётко определенные имена для собираемых предметов
local ITEM_LIST = {
    ["key"] = true, ["blue key"] = true, ["golden key"] = true, ["pink key"] = true, ["master key"] = true,
    ["lockpick"] = true,
    ["cabel"] = true, ["cable"] = true,
    ["cogwheel"] = true,
    ["heaven bible"] = true,
    ["key-card"] = true, ["card"] = true
}
local lower = string.lower
local function is_collectible(name)
    name = lower(name or "")
    -- Проверяем полностью совпадающее имя либо содержит точное по reg-exp фрагменту (например, Blue Key)
    for target,_ in pairs(ITEM_LIST) do
        if name == target then return true end
    end
    return false
end

-- Главная функция: ищет только "спавнящиеся" нужные предметы!
local function is_random_collectible(obj)
    -- Самый частый тип: Tool (предмет/оружие/ключи в Roblox)
    if obj:IsA("Tool") and is_collectible(obj.Name) then
        if obj.Parent and not obj:IsDescendantOf(game.Players) then
            return true
        end
    -- Отдельный Part/MeshPart, не вложен в игрока
    elseif (obj:IsA("BasePart") or obj:IsA("MeshPart")) and is_collectible(obj.Name) then
        if obj.Parent and not obj:IsDescendantOf(game.Players) then
            return true
        end
    -- Иногда это Model с нужным именем (например, rare cases)
    elseif obj:IsA("Model") and is_collectible(obj.Name) then
        local hasPart = false
        for _,v in ipairs(obj:GetChildren()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then hasPart=true end
        end
        return hasPart
    end
    return false
end

local function scan_random_items()
    local targets = {}
    for _,obj in ipairs(game:GetDescendants()) do
        if is_random_collectible(obj) then
            local full = obj:GetFullName()
            local foundType = obj.ClassName
            table.insert(targets, "SPAWN: "..obj.Name.." | "..foundType.." | "..full)
        end
    end
    -- Отображаем результат в Rayfield и Output
    local msg
    if #targets > 0 then
        msg = "Рандомных предметов: "..#targets.."\n\n" .. table.concat(targets, "\n")
        if #msg > 1100 then msg = string.sub(msg, 1, 1100) .. "\n... (полный список в Output/Console)" end
    else
        msg = "Ни одного собираемого предмета не найдено!"
    end
    Rayfield:Notify({
        Title = "Scan: Random Collectible Items",
        Content = msg,
        Duration = 13
    })
    print("=== [RANDOM COLLECTIBLE ITEM SCANNER START] ===")
    for _,line in ipairs(targets) do print(line) end
    print("=== [SCANNER END] ===")
    print("Всего найдены такие предметы:", #targets)
end

-- Rayfield GUI
local Window = Rayfield:CreateWindow({
    Name = "Random Collectible Item Scanner",
    LoadingTitle = "Сканер собираемых предметов",
    LoadingSubtitle = "Ключи, кабели, лом, cogwheel, bible, id card",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})
local Tab = Window:CreateTab("Сканер")
Tab:CreateSection("Только рандомные ключевые предметы")
Tab:CreateButton({
    Name = "Сканировать карту на собираемые предметы",
    Callback = scan_random_items
})

Rayfield:Notify({
    Title="Collectible Item Scanner",
    Content="Нажми кнопку, чтобы увидеть только собираемые предметы — ключи, ломы, кабели, cogwheel, heaven bible, id cards.",
    Duration=8
})