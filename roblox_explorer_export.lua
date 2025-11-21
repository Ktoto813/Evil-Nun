-- Сохраняем дерево объектов игры в файл через writefile (Synapse/ScriptWare и т.д.)

local function collectTree(obj, indent)
    indent = indent or ""
    local lines = {}
    table.insert(lines, indent .. obj.ClassName .. " | " .. obj:GetFullName())
    for _,child in ipairs(obj:GetChildren()) do
        for _,line in ipairs(collectTree(child, indent .. "  ")) do
            table.insert(lines, line)
        end
    end
    return lines
end

local allLines = {}
table.insert(allLines, "======== WORKSPACE ========")
for _,line in ipairs(collectTree(game.Workspace)) do table.insert(allLines, line) end
table.insert(allLines, "\n======== REPLICATEDSTORAGE ========")
for _,line in ipairs(collectTree(game:GetService("ReplicatedStorage"))) do table.insert(allLines, line) end
table.insert(allLines, "\n======== STARTERPACK ========")
for _,line in ipairs(collectTree(game:GetService("StarterPack"))) do table.insert(allLines, line) end
table.insert(allLines, "\n======== STARTERGUI ========")
for _,line in ipairs(collectTree(game:GetService("StarterGui"))) do table.insert(allLines, line) end
table.insert(allLines, "\n======== LIGHTING ========")
for _,line in ipairs(collectTree(game:GetService("Lighting"))) do table.insert(allLines, line) end

-- Собираем всё в одну строку
local output = table.concat(allLines, "\n")

-- Путь к файлу – в Synapse X это папка scripts или workspace, у Script-Ware — workspace/
-- Можно сделать и на рабочий стол (C:/Users/<ИМЯ>/Desktop/roblox_objects.txt), если эксплойт поддержит!
local USERNAME = os.getenv("USERNAME") or "User"
local filename = "C:\\Users\\"..USERNAME.."\\Desktop\\roblox_game_objects.txt"
-- Если не работает путь выше — можешь использовать просто "roblox_game_objects.txt" (файл будет в папке эксплойта)

writefile(filename, output)
rconsoleprint("Файл cо структурой игры сохранён: "..filename.."\n")