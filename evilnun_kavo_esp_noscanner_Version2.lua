-- Evil Nun ESP (без сканера) только для whitelist предметов [Kavo UI, Xeno compatible, игрок может поднимать]
-- kauuuvuv-coder, 2025

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Evil Nun ESP | Whitelist Only", "Ocean")

-- Только эти предметы (можно поднимать!)
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

local ITEM_CUSTOMCOLOR = {}; for k,v in pairs(WHITELIST) do ITEM_CUSTOMCOLOR[k]=v end

local highlights, ESP_ACTIVE = setmetatable({}, {__mode="k"}), false

local function clearESP()
    for obj,hl in pairs(highlights) do if hl and hl.Parent then pcall(function() hl:Destroy() end) end end
    table.clear(highlights)
end

local function updateESP()
    clearESP()
    if not ESP_ACTIVE then return end
    local RS, WS = game:GetService("ReplicatedStorage"), game:GetService("Workspace")
    local items = {}
    local folders = {}
    local function add(f) if f then table.insert(folders, f) end end
    add(RS:FindFirstChild("Items")); add(RS:FindFirstChild("Tools"))
    local maps = RS:FindFirstChild("Maps") if maps then for _,m in ipairs(maps:GetChildren())do add(m) end end
    local mf = WS:FindFirstChild("MapFolder") if mf then for _,m in ipairs(mf:GetChildren())do add(m) end end
    for _,folder in ipairs(folders)do
        for _,obj in ipairs(folder:GetDescendants())do
            if obj.Name and WHITELIST[obj.Name] and (obj:IsA("Tool") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                table.insert(items, obj)
            end
        end
    end
    for _,obj in ipairs(items) do
        if obj and obj:IsDescendantOf(game) then
            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillColor = ITEM_CUSTOMCOLOR[obj.Name] or Color3.new(1,1,1)
            hl.OutlineColor = Color3.fromRGB(15,15,15)
            hl.FillTransparency = 0.13
            hl.OutlineTransparency = 0.01
            hl.Parent = obj
            highlights[obj] = hl
        end
    end
end

local TabESP = Window:NewTab("ESP")
local SectionESP = TabESP:NewSection("Только whitelisted предметы")

SectionESP:NewToggle("Включить ESP по whitelisted", "Подсветит все нужные сразу", function(state)
    ESP_ACTIVE = state
    updateESP()
end)

for item,defColor in pairs(WHITELIST) do
    SectionESP:NewColorPicker("Цвет ESP: "..item, "Меняй цвет предмета", defColor,
        function(clr) ITEM_CUSTOMCOLOR[item]=clr updateESP() end)
end

SectionESP:NewButton("Очистить всю подсветку", "Отключить ESP", clearESP)

spawn(function()
    while true do
        if ESP_ACTIVE then updateESP() end
        wait(2)
    end
end)

Library:Notify("ESP подсвечивает только whitelisted предметы, которые можно подобрать!")