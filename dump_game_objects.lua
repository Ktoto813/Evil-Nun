
-- Автоопределение Desktop
local user = os.getenv("v8675")
local desktop = "C:\\Users\\"v8675"\\Desktop\\RobloxGameDump\\"

-- 1. Создаем папку
if not isfolder(desktop) then
    makefolder(desktop)
end

-- 2. Собираем дерево для каждого сервиса
local function collectTree(obj, indent)
    indent = indent or ""
    local lines = {}
    local ok = pcall(function()
        table.insert(lines, indent .. obj.ClassName .. " | " .. obj:GetFullName())
    end)
    for _,child in ipairs(obj:GetChildren()) do
        for _,line in ipairs(collectTree(child, indent .. "  ")) do
            table.insert(lines, line)
        end
    end
    return lines
end

local services = {
    {obj = game.Workspace, name = "workspace.txt"},
    {obj = game:GetService("ReplicatedStorage"), name = "replicatedstorage.txt"},
    {obj = game:GetService("StarterPack"), name = "starterpack.txt"},
    {obj = game:GetService("StarterGui"), name = "startergui.txt"},
    {obj = game:GetService("Lighting"), name = "lighting.txt"},
    -- Добавить еще сервисы при необходимости
}

for _,svc in ipairs(services) do
    local lines = collectTree(svc.obj)
    local result = table.concat(lines, "\n")
    writefile(desktop..svc.name, result)
end

rconsoleprint("Все объекты сохранены в папку "..desktop.."\n")