local itemNames = {
    ["golden key"] = true,
    ["small cabel"] = true,
    ["shovel key-card"] = true,
    ["pink key"] = true,
    ["blue key"] = true,
    ["heaven bible"] = true,
    ["cogwheel"] = true
}

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,170,0,44)
btn.Position = UDim2.new(0,16,0.75,0)
btn.BackgroundColor3 = Color3.fromRGB(50,180,255)
btn.TextSize = 23
btn.Text = "ВКЛЮЧИТЬ ESP"
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.Parent = gui

local espEnabled = false
local highlights = {}

local function highlightItems()
    for _,obj in ipairs(game.Workspace:GetDescendants()) do
        local objName = string.lower(obj.Name or "")
        if itemNames[objName] and (obj:IsA("Part") or obj:IsA("MeshPart")) then
            if not highlights[obj] then
                local hl = Instance.new("Highlight")
                hl.Adornee = obj
                hl.FillColor = Color3.fromRGB(0, 255, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                hl.FillTransparency = 0.2
                hl.OutlineTransparency = 0
                hl.Parent = obj
                highlights[obj] = hl
            end
        end
    end
end

local function removeHighlights()
    for obj,hl in pairs(highlights) do
        if hl and hl.Parent then
            hl:Destroy()
        end
    end
    table.clear(highlights)
end

btn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        highlightItems()
        btn.Text = "ВЫКЛЮЧИТЬ ESP"
        btn.BackgroundColor3 = Color3.fromRGB(255,130,0)
    else
        removeHighlights()
        btn.Text = "ВКЛЮЧИТЬ ESP"
        btn.BackgroundColor3 = Color3.fromRGB(50,180,255)
    end
end)