-- Educational script: смотреть всю структуру предметов и сущностей Roblox-игры (Evil Nun или любая другая)
-- Вставь этот скрипт в эксплойт, нажми Execute

local function printTree(obj, indent)
	indent = indent or ""
	local success, _ = pcall(function()
		print(indent .. obj.ClassName .. " | " .. obj:GetFullName())
	end)
	for _,child in ipairs(obj:GetChildren()) do
		printTree(child, indent .. "  ")
	end
end

print("========================")
print("=== WORKSPACE STRUCTURE (ВСЁ: предметы, сущности, NPC, монстры, объекты) ===")
print("========================")
printTree(game.Workspace)

print("========================")
print("=== REPLICATEDSTORAGE STRUCTURE (общие предметы, шаблоны, данные) ===")
print("========================")
printTree(game:GetService("ReplicatedStorage"))

print("========================")
print("=== STARTERPACK STRUCTURE (инструменты при входе/оружие) ===")
print("========================")
printTree(game:GetService("StarterPack"))

print("========================")
print("=== STARTERGUI/GUI STRUCTURE (интерфейс) ===")
print("========================")
printTree(game:GetService("StarterGui"))

print("========================")
print("=== LIGHTING STRUCTURE (эффекты/объекты в освещении) ===")
print("========================")
printTree(game:GetService("Lighting"))

print("========================")
print("=== NPC FOLDERS (если присутствуют) ===")
print("========================")
for _,obj in ipairs(game.Workspace:GetChildren()) do
	if obj.Name:lower():find("npc") or obj.Name:lower():find("enemy") or obj.Name:lower():find("monster") then
		print(">> Папка NPC/мобов: " .. obj.Name)
		printTree(obj)
	end
end

print("========================")
print("=== ЕСЛИ ЕСТЬ PARTICLES, SOUND, SPECIAL OBJECTS... ===")
print("========================")
for _,obj in ipairs(game.Workspace:GetDescendants()) do
	if obj:IsA("ParticleEmitter") or obj:IsA("Sound") or obj:IsA("SpecialMesh") then
		print("> [SPECIAL] " .. obj.ClassName .. " | " .. obj:GetFullName())
	end
end

print("========================")
print("=== КОНЕЦ ДЕРЕВА ===")
print("========================")