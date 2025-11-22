local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local win = Rayfield:CreateWindow({
    Name = "Rayfield WORK TEST",
    LoadingTitle = "RayfieldTest",
    LoadingSubtitle = "Скрипт теста запуска",
    ConfigurationSaving = {Enabled=false},
    KeySystem = false
})
local Tab = win:CreateTab("Тест")
Tab:CreateLabel("Если ты это видишь — Rayfield работает!")