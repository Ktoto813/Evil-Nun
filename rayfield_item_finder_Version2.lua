-- Evil Nun: Rayfield GUI предметоискатель с выделением целевых объектов (ключи, ломы, кабеля, книга, шестерёнка, карточки)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace, RS, Players = game:GetService("Workspace"), game:GetService("ReplicatedStorage"), game:GetService("Players")

-- Ключевые слова для важных предметов
local TARGETS = {"key","lockpick","cabel","cable","heaven bible","cogwheel","card","key-card"}
local lower = string.lower

local function is_target(name)
    name = lower(name or "")
    for _,key in ipairs(TARGETS) do
        if name:find(key, 1, true) then return true end
    end
    return false
end

-- Главная функция поиска всех предметов и выделения целевых
local function scanAndShow()
    local all, targets = {}, {}
    for _,obj in ipairs(game:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Tool") or obj:IsA("Model") then
            local full = obj:GetFullName()
            local foundType = obj.ClassName
            if is_target(obj.Name) then
                table.insert(targets, "TARGET: "..obj.Name.." | "..foundType.." | "..full)
            else
                table.insert(all, "ITEM: "..obj.Name.." | "..foundType.." | "..full)
            end
        end
    end

    -- Формируем сообщение (Rayfield может только короткие, поэтому только TARGETS)
    local msg
    if #targets > 0 then
        msg = "Найдено целевых предметов: "..#targets.."\n\n" .. table.concat(targets, "\n")
        if #msg > 1100 then msg = string.sub(msg, 1, 1100) .. "\n... (урезано для Rayfield)" end
    else
        msg = "Целевых предметов не найдено!"
    end
    Rayfield:Notify({
        Title = "Результаты поиска",
        Content = msg,
        Duration = 15
    })
    print("=== [SCANNER START] ===")
    for _,line in ipairs(targets) do print(line) end
    for _,line in ipairs(all) do print(line) end
    print("=== [SCANNER END] ===")
    print("Всего предметов найдено:", #all + #targets, "| целевых (TARGET):", #targets)
end

-- ===== Rayfield GUI =====
local Window = Rayfield:CreateWindow({
    Name = "Evil Nun: Поиск предметов",
    LoadingTitle = "Идентификация предметов",
    LoadingSubtitle = "найти важные предметы на карте",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})

local Tab = Window:CreateTab("Искать")
Tab:CreateSection("Найти предметы на карте")
Tab:CreateButton({
    Name = "Показать список целевых предметов",
    Callback = scanAndShow
})

Rayfield:Notify({
    Title="Rayfield: Поиск предметов",
    Content="Нажми кнопку для вывода списка ключей, ломов, кабелей и т.п. (результаты также в Output/Console)",
    Duration=8
})