-- Glass Bridge ESP - ПРАВИЛЬНЫЙ МЕТОД
-- Использует реальную структуру игры: segmentSystem.Segments + BoolValue

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}
local SafeTiles = {}
local DangerTiles = {}

local Window = Fluent:CreateWindow({
    Title = "Glass Bridge ESP (FIXED)",
    SubTitle = "v2.0 - Правильный метод",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tab = Window:AddTab({Title = "ESP", Icon = "eye"})

-- ГЛАВНАЯ ФУНКЦИЯ: Поиск плиток по реальной структуре игры
function FindBridgeTiles()
    SafeTiles = {}
    DangerTiles = {}
    
    -- Метод 1: segmentSystem.Segments (ОСНОВНОЙ МЕТОД)
    local segmentSystem = Workspace:FindFirstChild("segmentSystem")
    if segmentSystem then
        local segments = segmentSystem:FindFirstChild("Segments")
        if segments then
            print("✅ Найден segmentSystem!")
            
            -- Проходим по всем сегментам (обычно от 1 до 55)
            for i = 1, 60 do
                local segment = segments:FindFirstChild("Segment" .. i)
                if segment then
                    local folder = segment:FindFirstChild("Folder")
                    if folder then
                        -- Проверяем каждую плитку в папке
                        for _, part in ipairs(folder:GetChildren()) do
                            if part:IsA("Part") or part:IsA("MeshPart") then
                                -- КЛЮЧЕВОЙ МОМЕНТ: Проверка BoolValue
                                local boolValue = part:FindFirstChildOfClass("BoolValue")
                                
                                if boolValue then
                                    -- Если BoolValue существует = ОПАСНАЯ плитка
                                    table.insert(DangerTiles, part)
                                    print("🔴 Опасная плитка:", part:GetFullName())
                                else
                                    -- Если BoolValue НЕТ = БЕЗОПАСНАЯ плитка
                                    table.insert(SafeTiles, part)
                                    print("🟢 Безопасная плитка:", part:GetFullName())
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Метод 2: Поиск в Bridge (запасной метод)
    if #SafeTiles == 0 and #DangerTiles == 0 then
        local bridge = Workspace:FindFirstChild("Bridge") or Workspace:FindFirstChild("GlassBridge")
        if bridge then
            print("✅ Найден Bridge (запасной метод)")
            for _, obj in pairs(bridge:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local boolValue = obj:FindFirstChildOfClass("BoolValue")
                    if boolValue then
                        table.insert(DangerTiles, obj)
                    else
                        table.insert(SafeTiles, obj)
                    end
                end
            end
        end
    end
    
    -- Метод 3: Глобальный поиск по всему Workspace (крайний случай)
    if #SafeTiles == 0 and #DangerTiles == 0 then
        print("⚠️ Используем глобальный поиск...")
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:match("glass") or name:match("tile") or name:match("panel") then
                    local boolValue = obj:FindFirstChildOfClass("BoolValue")
                    if boolValue then
                        table.insert(DangerTiles, obj)
                    else
                        table.insert(SafeTiles, obj)
                    end
                end
            end
        end
    end
    
    print(string.format("📊 Результат: 🟢 Безопасных: %d | 🔴 Опасных: %d", #SafeTiles, #DangerTiles))
    
    return #SafeTiles + #DangerTiles
end

-- Очистка всех ESP
function ClearESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function()
            obj:Destroy()
        end)
    end
    ESPObjects = {}
end

-- Создание ESP для плитки
function CreateTileESP(tile, color, label, isSafe)
    if not tile or not tile.Parent then return end
    if tile:FindFirstChild("TileESP") then return end
    
    pcall(function()
        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "TileESP"
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.Adornee = tile
        highlight.Parent = tile
        
        -- Billboard GUI
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "TileLabel"
        billboard.Adornee = tile
        billboard.Size = UDim2.new(0, 120, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = tile
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = color
        frame.BackgroundTransparency = 0.5
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        frame.Parent = billboard
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 0.6, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = label
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = frame
        
        -- Дистанция (будет обновляться)
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.4, 0)
        distLabel.Position = UDim2.new(0, 0, 0.6, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = ""
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextScaled = true
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = frame
        
        table.insert(ESPObjects, highlight)
        table.insert(ESPObjects, billboard)
    end)
end

-- Показать безопасные плитки (ЗЕЛЕНЫЕ)
function ShowSafeTiles()
    local count = 0
    for _, tile in ipairs(SafeTiles) do
        CreateTileESP(tile, Color3.fromRGB(0, 255, 0), "✓ SAFE", true)
        count = count + 1
    end
    
    Fluent:Notify({
        Title = "🟢 Безопасные плитки",
        Content = string.format("Создано ESP: %d плиток", count),
        Duration = 3
    })
end

-- Показать опасные плитки (КРАСНЫЕ)
function ShowDangerTiles()
    local count = 0
    for _, tile in ipairs(DangerTiles) do
        CreateTileESP(tile, Color3.fromRGB(255, 0, 0), "✗ DANGER", false)
        count = count + 1
    end
    
    Fluent:Notify({
        Title = "🔴 Опасные плитки",
        Content = string.format("Создано ESP: %d плиток", count),
        Duration = 3
    })
end

-- Обновление дистанции
local DistanceUpdateEnabled = false
spawn(function()
    while task.wait(0.5) do
        if DistanceUpdateEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            for _, billboard in pairs(ESPObjects) do
                if billboard:IsA("BillboardGui") and billboard.Adornee then
                    local dist = (hrp.Position - billboard.Adornee.Position).Magnitude
                    local frame = billboard:FindFirstChildOfClass("Frame")
                    if frame then
                        local distLabel = frame:FindFirstChild("TextLabel", true)
                        if distLabel and distLabel.Name ~= "TextLabel" then
                            distLabel.Text = string.format("[%.1fm]", dist)
                        end
                    end
                end
            end
        end
    end
end)

-- UI СОЗДАНИЕ
Tab:AddParagraph({
    Title = "🎯 Glass Bridge ESP",
    Content = "Использует ПРАВИЛЬНЫЙ метод определения плиток\n(segmentSystem + BoolValue)"
})

local ScanButton = Tab:AddButton({
    Title = "🔍 Сканировать мост",
    Description = "Найти все плитки на мосту",
    Callback = function()
        ClearESP()
        local count = FindBridgeTiles()
        
        if count > 0 then
            Fluent:Notify({
                Title = "✅ Сканирование завершено",
                Content = string.format("🟢 Безопасных: %d\n🔴 Опасных: %d", #SafeTiles, #DangerTiles),
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "⚠️ Ничего не найдено",
                Content = "Возможно вы не на мосту.\nИли мост еще не загружен.",
                Duration = 5
            })
        end
    end
})

Tab:AddSection("Подсветка")

local SafeToggle = Tab:AddToggle("Safe", {
    Title = "🟢 Показать БЕЗОПАСНЫЕ",
    Description = "Зеленая подсветка безопасных плиток",
    Default = false
})

SafeToggle:OnChanged(function(Value)
    if Value then
        if #SafeTiles == 0 then
            FindBridgeTiles()
        end
        ShowSafeTiles()
    else
        -- Удаляем только зеленые
        for _, obj in pairs(ESPObjects) do
            if obj.Name == "TileESP" and obj.FillColor == Color3.fromRGB(0, 255, 0) then
                obj:Destroy()
            elseif obj.Name == "TileLabel" and obj.Adornee and obj.Adornee:FindFirstChild("TileESP") then
                if obj.Adornee.TileESP.FillColor == Color3.fromRGB(0, 255, 0) then
                    obj:Destroy()
                end
            end
        end
    end
end)

local DangerToggle = Tab:AddToggle("Danger", {
    Title = "🔴 Показать ОПАСНЫЕ",
    Description = "Красная подсветка опасных плиток",
    Default = false
})

DangerToggle:OnChanged(function(Value)
    if Value then
        if #DangerTiles == 0 then
            FindBridgeTiles()
        end
        ShowDangerTiles()
    else
        -- Удаляем только красные
        for _, obj in pairs(ESPObjects) do
            if obj.Name == "TileESP" and obj.FillColor == Color3.fromRGB(255, 0, 0) then
                obj:Destroy()
            elseif obj.Name == "TileLabel" and obj.Adornee and obj.Adornee:FindFirstChild("TileESP") then
                if obj.Adornee.TileESP.FillColor == Color3.fromRGB(255, 0, 0) then
                    obj:Destroy()
                end
            end
        end
    end
end)

local AllButton = Tab:AddButton({
    Title = "🎨 ПОКАЗАТЬ ВСЁ",
    Description = "Включить обе подсветки сразу",
    Callback = function()
        if #SafeTiles == 0 and #DangerTiles == 0 then
            FindBridgeTiles()
        end
        
        ShowSafeTiles()
        ShowDangerTiles()
        
        Fluent:Notify({
            Title = "🎨 Полный ESP",
            Content = string.format("🟢 %d | 🔴 %d", #SafeTiles, #DangerTiles),
            Duration = 3
        })
    end
})

Tab:AddSection("Настройки")

local DistToggle = Tab:AddToggle("Distance", {
    Title = "📏 Показывать дистанцию",
    Description = "Расстояние до каждой плитки",
    Default = false
})

DistToggle:OnChanged(function(Value)
    DistanceUpdateEnabled = Value
end)

local TransSlider = Tab:AddSlider("Trans", {
    Title = "Прозрачность",
    Description = "Прозрачность подсветки (0 = непрозрачно)",
    Default = 0.3,
    Min = 0,
    Max = 0.9,
    Rounding = 1
})

TransSlider:OnChanged(function(Value)
    for _, obj in pairs(ESPObjects) do
        if obj:IsA("Highlight") then
            obj.FillTransparency = Value
        end
    end
end)

Tab:AddSection("Действия")

local RefreshButton = Tab:AddButton({
    Title = "🔄 Обновить ESP",
    Description = "Пересканировать мост",
    Callback = function()
        ClearESP()
        FindBridgeTiles()
        
        if SafeToggle.Value then ShowSafeTiles() end
        if DangerToggle.Value then ShowDangerTiles() end
        
        Fluent:Notify({
            Title = "✅ Обновлено",
            Content = "ESP пересканирован",
            Duration = 2
        })
    end
})

local ClearButton = Tab:AddButton({
    Title = "🗑️ Очистить всё",
    Description = "Удалить весь ESP",
    Callback = function()
        ClearESP()
        SafeToggle:SetValue(false)
        DangerToggle:SetValue(false)
        Fluent:Notify({
            Title = "🗑️ Очищено",
            Content = "Весь ESP удален",
            Duration = 2
        })
    end
})

-- Debug вкладка
local DebugTab = Window:AddTab({Title = "🔧 Debug", Icon = "bug"})

DebugTab:AddParagraph({
    Title = "🔍 Отладочная информация",
    Content = "Поиск структуры игры для точной настройки"
})

local DebugButton = DebugTab:AddButton({
    Title = "🔍 Поиск segmentSystem",
    Description = "Проверить наличие segmentSystem в Workspace",
    Callback = function()
        local segmentSystem = Workspace:FindFirstChild("segmentSystem")
        
        if segmentSystem then
            print("✅ segmentSystem найден!")
            print("Путь:", segmentSystem:GetFullName())
            
            local segments = segmentSystem:FindFirstChild("Segments")
            if segments then
                print("✅ Segments найден!")
                print("Количество сегментов:", #segments:GetChildren())
                
                for i, segment in ipairs(segments:GetChildren()) do
                    print(string.format("Сегмент %d: %s", i, segment.Name))
                    if i <= 3 then -- Показываем только первые 3 для примера
                        local folder = segment:FindFirstChild("Folder")
                        if folder then
                            print("  └─ Папка найдена, плиток:", #folder:GetChildren())
                            for _, part in ipairs(folder:GetChildren()) do
                                local boolValue = part:FindFirstChildOfClass("BoolValue")
                                print(string.format("    └─ %s (BoolValue: %s)", part.Name, boolValue and "🔴 ДА (опасная)" or "🟢 НЕТ (безопасная)"))
                            end
                        end
                    end
                end
            else
                print("❌ Segments НЕ найден в segmentSystem")
            end
            
            Fluent:Notify({
                Title = "✅ Найдено!",
                Content = "segmentSystem существует!\nСмотри консоль (F9)",
                Duration = 5
            })
        else
            print("❌ segmentSystem НЕ найден в Workspace")
            print("Доступные объекты в Workspace:")
            for _, obj in ipairs(Workspace:GetChildren()) do
                print("  - " .. obj.Name)
            end
            
            Fluent:Notify({
                Title = "❌ Не найдено",
                Content = "segmentSystem отсутствует\nСмотри консоль (F9)",
                Duration = 5
            })
        end
    end
})

local ListAllButton = DebugTab:AddButton({
    Title = "📋 Список всех Part с BoolValue",
    Description = "Найти все Part которые имеют BoolValue",
    Callback = function()
        print("=== ПОИСК PARTS С BOOLVALUE ===")
        local count = 0
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local boolValue = obj:FindFirstChildOfClass("BoolValue")
                if boolValue then
                    count = count + 1
                    print(string.format("%d. %s (BoolValue = %s)", count, obj:GetFullName(), tostring(boolValue.Value)))
                end
            end
        end
        
        print("=== ВСЕГО НАЙДЕНО: " .. count .. " ===")
        
        Fluent:Notify({
            Title = "📋 Найдено",
            Content = string.format("Parts с BoolValue: %d\nСмотри консоль (F9)", count),
            Duration = 5
        })
    end
})

local StructureButton = DebugTab:AddButton({
    Title = "🌳 Структура Workspace",
    Description = "Показать все главные объекты",
    Callback = function()
        print("=== СТРУКТУРА WORKSPACE ===")
        for _, obj in ipairs(Workspace:GetChildren()) do
            print("📁 " .. obj.Name .. " (" .. obj.ClassName .. ")")
            
            -- Показываем детей для важных объектов
            if obj.Name:lower():match("segment") or obj.Name:lower():match("bridge") or obj.Name:lower():match("map") then
                for _, child in ipairs(obj:GetChildren()) do
                    print("  └─ " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
        print("======================")
        
        Fluent:Notify({
            Title = "🌳 Готово",
            Content = "Смотри консоль (F9)",
            Duration = 3
        })
    end
})

DebugTab:AddParagraph({
    Title = "💡 Инструкция",
    Content = "1. Нажми 'Поиск segmentSystem'\n2. Открой консоль (F9)\n3. Посмотри результаты\n4. Если что-то не так - пришли мне инфо!"
})

-- Инфо вкладка
local InfoTab = Window:AddTab({Title = "ℹ️ Инфо", Icon = "info"})

InfoTab:AddParagraph({
    Title = "✅ Как работает скрипт",
    Content = "Скрипт использует ПРАВИЛЬНУЮ структуру игры:\n\n" ..
             "workspace.segmentSystem.Segments\n" ..
             "└─ Segment1, Segment2, ... Segment55\n" ..
             "   └─ Folder\n" ..
             "      └─ Part (с BoolValue = опасная)\n" ..
             "      └─ Part (без BoolValue = безопасная)\n\n" ..
             "🟢 БЕЗ BoolValue = БЕЗОПАСНАЯ\n" ..
             "🔴 С BoolValue = ОПАСНАЯ"
})

InfoTab:AddParagraph({
    Title = "📝 Инструкция",
    Content = "1. Зайди на мост в игре\n" ..
             "2. Нажми '🔍 Сканировать мост'\n" ..
             "3. Включи нужные подсветки\n" ..
             "4. Profit! 🎉"
})

InfoTab:AddParagraph({
    Title = "🐛 Если не работает",
    Content = "1. Перейди на вкладку Debug\n" ..
             "2. Нажми все кнопки\n" ..
             "3. Открой консоль (F9)\n" ..
             "4. Скопируй информацию\n" ..
             "5. Отправь мне!"
})

-- Автосканирование при загрузке
task.spawn(function()
    task.wait(2)
    local count = FindBridgeTiles()
    if count > 0 then
        Fluent:Notify({
            Title = "✅ Автосканирование",
            Content = string.format("Найдено плиток: %d\n🟢 Безопасных: %d\n🔴 Опасных: %d", count, #SafeTiles, #DangerTiles),
            Duration = 5
        })
    end
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "✅ Glass Bridge ESP загружен",
    Content = "v2.0 - Правильный метод!",
    Duration = 3
})

print("=== Glass Bridge ESP v2.0 ===")
print("Метод: segmentSystem.Segments + BoolValue")
print("🟢 Без BoolValue = Безопасная")
print("🔴 С BoolValue = Опасная")
print("========================")
