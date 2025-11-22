-- Evil Nun Kavo UI: ESP только на киллера [by kauuuvuv-coder]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Evil Nun | KILLER ESP", "Ocean")

local KILLER_COLOR = Color3.fromRGB(255,50,60)
local killerCustomColor = KILLER_COLOR
local highlights = setmetatable({}, {__mode="k"})
local KILLER_ESP_ACTIVE = false

local function clearESP()
    for obj,hl in pairs(highlights) do
        if hl and hl.Parent then pcall(function() hl:Destroy() end) end
    end
    table.clear(highlights)
end

local function updateKillerESP()
    clearESP()
    if not KILLER_ESP_ACTIVE then return end
    local WS = game:GetService("Workspace")
    for _,obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
            local lname = tostring(obj.Name):lower()
            if lname:find("nun") or lname:find("killer") or lname:find("bot") then
                if not highlights[obj] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = obj
                    hl.FillColor = killerCustomColor
                    hl.OutlineColor = Color3.fromRGB(0,0,0)
                    hl.FillTransparency = 0.08
                    hl.OutlineTransparency = 0.01
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = obj
                    highlights[obj] = hl
                else
                    highlights[obj].FillColor = killerCustomColor
                    highlights[obj].OutlineColor = Color3.fromRGB(0,0,0)
                end
            end
        end
    end
end

local TabESP = Window:NewTab("KILLER ESP")
local SectionKiller = TabESP:NewSection("Подсвечивает врагов/килеров (через стены)")

SectionKiller:NewToggle("Включить ESP на Киллера", "Подсвечивает модели с именем 'nun', 'killer' или 'bot'", function(state)
    KILLER_ESP_ACTIVE = state
    updateKillerESP()
end)

SectionKiller:NewColorPicker("Цвет ESP Киллера", "Выбери цвет подсветки", KILLER_COLOR, function(c)
    killerCustomColor = c
    updateKillerESP()
end)

SectionKiller:NewButton("Очистить подсветку", "Убрать все ESP", clearESP)

Library:Notify("Включи тоггл — и Killer ESP через стены активируется!")