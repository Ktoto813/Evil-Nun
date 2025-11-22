-- Evil Nun ESP на ВСЕ ПОДНИМАЕМЫЕ предметы в MapFolder по наличию ItemScript [Kavo UI]
-- Работает даже если появляются новые вещи! 
-- kauuuvuv-coder, 2025

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Evil Nun ESP | Все подбираемые в MapFolder", "Ocean")

local ITEM_DEFAULT_COLOR = Color3.fromRGB(0, 255, 180)
local ITEM_CUSTOMCOLOR = {}
local highlights = setmetatable({}, {__mode="k"})
local ESP_ACTIVE = false

local function findPickupModels()
    local workspace = game:GetService("Workspace")
    local items = {}
    local mapfolder = workspace:FindFirstChild("MapFolder")
    if not mapfolder then return items end
    for _, model in ipairs(mapfolder:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("ItemScript", true) then
            table.insert(items, model)
        end
    end
    return items
end

local function clearESP()
    for obj,hl in pairs(highlights) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    table.clear(highlights)
end

local function updateESP()
    clearESP()
    if not ESP_ACTIVE then return end
    local items = findPickupModels()
    for _, model in ipairs(items) do
        if not highlights[model] then
            local color = ITEM_CUSTOMCOLOR[model.Name] or ITEM_DEFAULT_COLOR
            local ok,hl = pcall(function()
                local h = Instance.new("Highlight")
                h.Adornee = model
                h.FillColor = color
                h.OutlineColor = Color3.fromRGB(12,50,64)
                h.FillTransparency = 0.07
                h.OutlineTransparency = 0.01
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = model
                return h
            end)
            if ok and hl then highlights[model]=hl end
        end
    end
end

-- UI
local TabESP = Window:NewTab("ESP")
local SectionESP = TabESP:NewSection("Все подбираемые предметы (по ItemScript)")

SectionESP:NewToggle("Включить ESP на всё что можно поднять", "Любой предмет с ItemScript из MapFolder", function(state)
    ESP_ACTIVE = state
    updateESP()
end)

SectionESP:NewButton("Обновить ESP", "Подсветить новопоявившиеся предметы", updateESP)
SectionESP:NewButton("Очистить всю подсветку", "Убрать ESP со всех предметов", clearESP)

SectionESP:NewTextBox("Установить цвет по имени", "Введи имя предмета (например: Crowbar), затем выбери цвет.", function(val)
    if val and #val > 0 then
        SectionESP:NewColorPicker("Цвет для "..val, "Сделай свой цвет!", ITEM_DEFAULT_COLOR, function(color)
            ITEM_CUSTOMCOLOR[val] = color
            updateESP()
        end)
    end
end, {["clearTextOnFocus"]=false})

Library:Notify("Все предметы в MapFolder с ItemScript теперь ESP!\nВключи тумблер и жми 'Обновить ESP', когда появляются новые.")