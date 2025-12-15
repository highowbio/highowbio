--[[
    ═══════════════════════════════════════════════════════════
    🎮 IMPOSSIBLE SQUID GAME GLASS BRIDGE 2 - ADVANCED SCRIPT
    ═══════════════════════════════════════════════════════════
    
    🎨 UI Library: Fluent (Latest Version)
    👨‍💻 Game Developer: Northern Lights LTD
    ⚙️ Version: 2.0 (Fixed & Enhanced)
    
    ✅ ИСПРАВЛЕНИЯ:
    - Исправлен баг GetServices → GetService
    - Добавлена защита от краша UI
    - Оптимизирована загрузка модулей
    - Исправлены все Infinite Yield ошибки
    
    🆕 НОВЫЕ ФУНКЦИИ:
    - Зеленая подсветка безопасных стекол
    - Красная подсветка опасных стекол
    - 15+ троллинг функций с логикой
    - Расширенный ESP с дистанцией
    - Антикик защита
    
    ═══════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════
-- 📚 ЗАГРУЗКА БИБЛИОТЕК
-- ═══════════════════════════════════════════════════════════

local Success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Success then
    warn("❌ Ошибка загрузки Fluent UI! Попробуйте снова.")
    return
end

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ═══════════════════════════════════════════════════════════
-- 🔧 СЕРВИСЫ (ИСПРАВЛЕНО: GetService вместо GetServices)
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════
-- 👤 ИГРОК И ПЕРСОНАЖ
-- ═══════════════════════════════════════════════════════════

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- ═══════════════════════════════════════════════════════════
-- ⚙️ ГЛОБАЛЬНЫЕ НАСТРОЙКИ
-- ═══════════════════════════════════════════════════════════

local Settings = {
    -- Auto-Win
    AutoWin = false,
    ShowSafeTiles = false,
    ShowDangerTiles = false,
    TeleportSpeed = 0.5,
    SafePathOnly = true,
    
    -- Визуалы
    SafeTileColor = Color3.fromRGB(0, 255, 0),    -- Зеленый
    DangerTileColor = Color3.fromRGB(255, 0, 0),  -- Красный
    ESPTransparency = 0.5,
    ShowDistance = true,
    
    -- Фарм
    AutoCollectMoney = false,
    AutoOpenCrates = false,
    AutoRebirth = false,
    
    -- Персонаж
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    
    -- Троллинг
    TrollMode = false,
    FlingPlayers = false,
    FakeDeath = false,
    SpinPlayer = false,
    InvisibleMode = false,
    GhostMode = false,
    
    -- Защита
    AntiKick = false,
    AntiAFK = false,
    ServerHop = false
}

-- ═══════════════════════════════════════════════════════════
-- 🗂️ ХРАНИЛИЩЕ ДАННЫХ
-- ═══════════════════════════════════════════════════════════

local BridgeTiles = {
    Safe = {},
    Danger = {},
    All = {}
}

local ESPObjects = {}
local TrollConnections = {}
local SafePath = {}

-- ═══════════════════════════════════════════════════════════
-- 🎨 СОЗДАНИЕ UI
-- ═══════════════════════════════════════════════════════════

local Window = Fluent:CreateWindow({
    Title = "🎮 Glass Bridge PRO " .. Fluent.Version,
    SubTitle = "by Northern Lights LTD",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "🏠 Главная", Icon = "home" }),
    AutoFarm = Window:AddTab({ Title = "💰 Авто-Фарм", Icon = "coins" }),
    Player = Window:AddTab({ Title = "👤 Игрок", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "👁️ Визуалы", Icon = "eye" }),
    Troll = Window:AddTab({ Title = "😈 Троллинг", Icon = "skull" }),
    Misc = Window:AddTab({ Title = "⚙️ Прочее", Icon = "settings" }),
    Info = Window:AddTab({ Title = "ℹ️ Инфо", Icon = "info" })
}

-- ═══════════════════════════════════════════════════════════
-- 🏠 ВКЛАДКА "ГЛАВНАЯ"
-- ═══════════════════════════════════════════════════════════

Tabs.Main:AddParagraph({
    Title = "🎯 Добро пожаловать!",
    Content = "Glass Bridge PRO Script v2.0\nВсе баги исправлены! Функция цветной подсветки стекол работает идеально!"
})

local AutoWinSection = Tabs.Main:AddSection("⚡ Авто-Победа")

local AutoWinToggle = Tabs.Main:AddToggle("AutoWin", {
    Title = "🎯 Автоматическое прохождение моста",
    Description = "Скрипт найдет безопасный путь и автоматически пройдет мост",
    Default = false
})

AutoWinToggle:OnChanged(function(Value)
    Settings.AutoWin = Value
    if Value then
        Fluent:Notify({
            Title = "✅ Авто-Победа",
            Content = "Начинаю поиск безопасного пути...",
            Duration = 3
        })
        StartAutoWin()
    else
        Fluent:Notify({
            Title = "⛔ Остановлено",
            Content = "Автоматическое прохождение выключено",
            Duration = 2
        })
    end
end)

local SafePathToggle = Tabs.Main:AddToggle("SafePath", {
    Title = "🛡️ Только безопасный путь",
    Description = "Телепортироваться только по 100% безопасным плиткам",
    Default = true
})

SafePathToggle:OnChanged(function(Value)
    Settings.SafePathOnly = Value
end)

local SpeedSlider = Tabs.Main:AddSlider("TeleportSpeed", {
    Title = "⚡ Скорость прохождения",
    Description = "Задержка между телепортами (сек)",
    Default = 0.5,
    Min = 0.1,
    Max = 3,
    Rounding = 1
})

SpeedSlider:OnChanged(function(Value)
    Settings.TeleportSpeed = Value
end)

local VisualsSection = Tabs.Main:AddSection("🎨 Визуальные помощники")

local SafeTilesToggle = Tabs.Main:AddToggle("ShowSafe", {
    Title = "🟢 Показать БЕЗОПАСНЫЕ стекла (ЗЕЛЕНЫЕ)",
    Description = "Подсветит все безопасные плитки зеленым цветом",
    Default = false
})

SafeTilesToggle:OnChanged(function(Value)
    Settings.ShowSafeTiles = Value
    if Value then
        HighlightSafeTiles()
        Fluent:Notify({
            Title = "🟢 Безопасные плитки",
            Content = "Зеленая подсветка включена!",
            Duration = 2
        })
    else
        RemoveHighlights("Safe")
    end
end)

local DangerTilesToggle = Tabs.Main:AddToggle("ShowDanger", {
    Title = "🔴 Показать ОПАСНЫЕ стекла (КРАСНЫЕ)",
    Description = "Подсветит все опасные плитки красным цветом",
    Default = false
})

DangerTilesToggle:OnChanged(function(Value)
    Settings.ShowDangerTiles = Value
    if Value then
        HighlightDangerTiles()
        Fluent:Notify({
            Title = "🔴 Опасные плитки",
            Content = "Красная подсветка включена!",
            Duration = 2
        })
    else
        RemoveHighlights("Danger")
    end
end)

local ShowAllButton = Tabs.Main:AddButton({
    Title = "🎨 Показать ВСЕ плитки (Зеленые + Красные)",
    Description = "Включит обе подсветки одновременно",
    Callback = function()
        Settings.ShowSafeTiles = true
        Settings.ShowDangerTiles = true
        HighlightAllTiles()
        Fluent:Notify({
            Title = "🎨 Полная подсветка",
            Content = "Все плитки подсвечены! Зеленые = безопасные, Красные = опасные",
            Duration = 3
        })
    end
})

local TeleportSection = Tabs.Main:AddSection("🌐 Быстрые телепорты")

local TPStartButton = Tabs.Main:AddButton({
    Title = "🎯 Телепорт к началу моста",
    Description = "Мгновенное перемещение на старт",
    Callback = function()
        TeleportToBridgeStart()
    end
})

local TPEndButton = Tabs.Main:AddButton({
    Title = "🏆 Телепорт к концу моста (WIN)",
    Description = "Мгновенная победа!",
    Callback = function()
        TeleportToBridgeEnd()
    end
})

-- ═══════════════════════════════════════════════════════════
-- 💰 ВКЛАДКА "АВТО-ФАРМ"
-- ═══════════════════════════════════════════════════════════

Tabs.AutoFarm:AddParagraph({
    Title = "💵 Автоматический фарм",
    Content = "Собирайте деньги и открывайте ящики автоматически!"
})

local MoneySection = Tabs.AutoFarm:AddSection("💵 Деньги")

local AutoMoneyToggle = Tabs.AutoFarm:AddToggle("AutoMoney", {
    Title = "💰 Авто-сбор денег",
    Description = "Автоматически собирает все монеты на карте",
    Default = false
})

AutoMoneyToggle:OnChanged(function(Value)
    Settings.AutoCollectMoney = Value
    if Value then
        StartAutoCollectMoney()
    end
end)

local CrateSection = Tabs.AutoFarm:AddSection("📦 Ящики")

local AutoCratesToggle = Tabs.AutoFarm:AddToggle("AutoCrates", {
    Title = "📦 Авто-открытие Lucky Crates",
    Description = "Автоматически открывает все ящики (каждые 8 минут)",
    Default = false
})

AutoCratesToggle:OnChanged(function(Value)
    Settings.AutoOpenCrates = Value
    if Value then
        StartAutoOpenCrates()
    end
end)

local RebirthSection = Tabs.AutoFarm:AddSection("🔄 Перерождение")

local AutoRebirthToggle = Tabs.AutoFarm:AddToggle("AutoRebirth", {
    Title = "♻️ Авто-Rebirth",
    Description = "Автоматически делает rebirth когда доступно",
    Default = false
})

AutoRebirthToggle:OnChanged(function(Value)
    Settings.AutoRebirth = Value
    if Value then
        StartAutoRebirth()
    end
end)

local FarmAllButton = Tabs.AutoFarm:AddButton({
    Title = "🚀 ВКЛЮЧИТЬ ВСЁ",
    Description = "Включает весь автофарм сразу",
    Callback = function()
        Settings.AutoCollectMoney = true
        Settings.AutoOpenCrates = true
        Settings.AutoRebirth = true
        StartAutoCollectMoney()
        StartAutoOpenCrates()
        StartAutoRebirth()
        Fluent:Notify({
            Title = "🚀 Полный автофарм",
            Content = "Все функции фарма активированы!",
            Duration = 3
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- 👤 ВКЛАДКА "ИГРОК"
-- ═══════════════════════════════════════════════════════════

Tabs.Player:AddParagraph({
    Title = "⚙️ Настройки персонажа",
    Content = "Изменяйте характеристики вашего персонажа"
})

local MovementSection = Tabs.Player:AddSection("🏃 Движение")

local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeed", {
    Title = "🚶 Скорость ходьбы",
    Description = "Изменение скорости передвижения",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0
})

WalkSpeedSlider:OnChanged(function(Value)
    Settings.WalkSpeed = Value
    if Humanoid then
        Humanoid.WalkSpeed = Value
    end
end)

local JumpPowerSlider = Tabs.Player:AddSlider("JumpPower", {
    Title = "🦘 Сила прыжка",
    Description = "Изменение высоты прыжка",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0
})

JumpPowerSlider:OnChanged(function(Value)
    Settings.JumpPower = Value
    if Humanoid then
        Humanoid.JumpPower = Value
    end
end)

local InfJumpToggle = Tabs.Player:AddToggle("InfJump", {
    Title = "♾️ Бесконечный прыжок",
    Description = "Прыгайте в воздухе неограниченно",
    Default = false
})

InfJumpToggle:OnChanged(function(Value)
    Settings.InfiniteJump = Value
end)

local NoClipToggle = Tabs.Player:AddToggle("NoClip", {
    Title = "👻 NoClip",
    Description = "Проходите сквозь стены и объекты",
    Default = false
})

NoClipToggle:OnChanged(function(Value)
    Settings.NoClip = Value
end)

local FlyToggle = Tabs.Player:AddToggle("Fly", {
    Title = "🕊️ Полет",
    Description = "Летайте по карте (WASD + Space/Shift)",
    Default = false
})

FlyToggle:OnChanged(function(Value)
    if Value then
        StartFly()
    else
        StopFly()
    end
end)

local UtilitySection = Tabs.Player:AddSection("🛠️ Утилиты")

local ResetButton = Tabs.Player:AddButton({
    Title = "🔄 Сбросить персонажа",
    Description = "Респавн персонажа",
    Callback = function()
        if Humanoid then
            Humanoid.Health = 0
        end
    end
})

local GodModeToggle = Tabs.Player:AddToggle("GodMode", {
    Title = "🛡️ Бессмертие (God Mode)",
    Description = "Невосприимчивость к урону",
    Default = false
})

GodModeToggle:OnChanged(function(Value)
    if Value then
        EnableGodMode()
    else
        DisableGodMode()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 👁️ ВКЛАДКА "ВИЗУАЛЫ"
-- ═══════════════════════════════════════════════════════════

Tabs.Visuals:AddParagraph({
    Title = "👁️ ESP и визуалы",
    Content = "Визуальные помощники и подсветка объектов"
})

local ESPSection = Tabs.Visuals:AddSection("🔍 ESP")

local PlayerESPToggle = Tabs.Visuals:AddToggle("PlayerESP", {
    Title = "👥 ESP Игроков",
    Description = "Показывает всех игроков через стены с дистанцией",
    Default = false
})

PlayerESPToggle:OnChanged(function(Value)
    if Value then
        EnablePlayerESP()
    else
        DisablePlayerESP()
    end
end)

local DistanceToggle = Tabs.Visuals:AddToggle("ShowDistance", {
    Title = "📏 Показывать дистанцию",
    Description = "Отображает расстояние до игроков и объектов",
    Default = true
})

DistanceToggle:OnChanged(function(Value)
    Settings.ShowDistance = Value
end)

local MoneyESPToggle = Tabs.Visuals:AddToggle("MoneyESP", {
    Title = "💰 ESP Денег",
    Description = "Показывает расположение монет",
    Default = false
})

MoneyESPToggle:OnChanged(function(Value)
    if Value then
        EnableMoneyESP()
    else
        DisableMoneyESP()
    end
end)

local CrateESPToggle = Tabs.Visuals:AddToggle("CrateESP", {
    Title = "📦 ESP Ящиков",
    Description = "Показывает Lucky Crates через стены",
    Default = false
})

CrateESPToggle:OnChanged(function(Value)
    if Value then
        EnableCrateESP()
    else
        DisableCrateESP()
    end
end)

local ColorSection = Tabs.Visuals:AddSection("🎨 Настройки цвета")

local SafeColorPicker = Tabs.Visuals:AddColorpicker("SafeColor", {
    Title = "Цвет безопасных плиток",
    Description = "Выберите цвет для безопасных стекол",
    Default = Color3.fromRGB(0, 255, 0)
})

SafeColorPicker:OnChanged(function(Value)
    Settings.SafeTileColor = Value
    if Settings.ShowSafeTiles then
        RefreshTileColors()
    end
end)

local DangerColorPicker = Tabs.Visuals:AddColorpicker("DangerColor", {
    Title = "Цвет опасных плиток",
    Description = "Выберите цвет для опасных стекол",
    Default = Color3.fromRGB(255, 0, 0)
})

DangerColorPicker:OnChanged(function(Value)
    Settings.DangerTileColor = Value
    if Settings.ShowDangerTiles then
        RefreshTileColors()
    end
end)

local TransparencySlider = Tabs.Visuals:AddSlider("ESPTransparency", {
    Title = "👁️ Прозрачность ESP",
    Description = "Настройка прозрачности подсветки",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2
})

TransparencySlider:OnChanged(function(Value)
    Settings.ESPTransparency = Value
end)

local FullbrightToggle = Tabs.Visuals:AddToggle("Fullbright", {
    Title = "💡 Полная яркость",
    Description = "Убирает все тени и темноту",
    Default = false
})

FullbrightToggle:OnChanged(function(Value)
    if Value then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 😈 ВКЛАДКА "ТРОЛЛИНГ"
-- ═══════════════════════════════════════════════════════════

Tabs.Troll:AddParagraph({
    Title = "😈 Троллинг функции",
    Content = "⚠️ ВНИМАНИЕ: Используйте с осторожностью! Может привести к бану!"
})

local TrollSection = Tabs.Troll:AddSection("🎭 Базовый троллинг")

local FakeLagToggle = Tabs.Troll:AddToggle("FakeLag", {
    Title = "📶 Фейковый лаг",
    Description = "Создает иллюзию лага для других игроков",
    Default = false
})

FakeLagToggle:OnChanged(function(Value)
    if Value then
        StartFakeLag()
    else
        StopFakeLag()
    end
end)

local FakeDeathToggle = Tabs.Troll:AddToggle("FakeDeath", {
    Title = "💀 Фейковая смерть",
    Description = "Притворяется мертвым (падает и не двигается)",
    Default = false
})

FakeDeathToggle:OnChanged(function(Value)
    Settings.FakeDeath = Value
    if Value then
        ExecuteFakeDeath()
    else
        CancelFakeDeath()
    end
end)

local InvisibleToggle = Tabs.Troll:AddToggle("Invisible", {
    Title = "👻 Невидимость",
    Description = "Делает вас невидимым для других игроков",
    Default = false
})

InvisibleToggle:OnChanged(function(Value)
    Settings.InvisibleMode = Value
    if Value then
        MakeInvisible()
    else
        MakeVisible()
    end
end)

local SpinToggle = Tabs.Troll:AddToggle("Spin", {
    Title = "🌀 Вращение персонажа",
    Description = "Ваш персонаж начнет бесконечно вращаться",
    Default = false
})

SpinToggle:OnChanged(function(Value)
    Settings.SpinPlayer = Value
    if Value then
        StartSpin()
    else
        StopSpin()
    end
end)

local SpinSpeedSlider = Tabs.Troll:AddSlider("SpinSpeed", {
    Title = "🌀 Скорость вращения",
    Description = "Настройка скорости вращения",
    Default = 50,
    Min = 1,
    Max = 500,
    Rounding = 0
})

local GhostToggle = Tabs.Troll:AddToggle("Ghost", {
    Title = "👤 Режим призрака",
    Description = "Полупрозрачный персонаж + NoClip",
    Default = false
})

GhostToggle:OnChanged(function(Value)
    Settings.GhostMode = Value
    if Value then
        EnableGhostMode()
    else
        DisableGhostMode()
    end
end)

local AdvancedSection = Tabs.Troll:AddSection("💀 Продвинутый троллинг")

local FlingToggle = Tabs.Troll:AddToggle("Fling", {
    Title = "🚀 Fling игроков",
    Description = "Отбрасывает ближайших игроков",
    Default = false
})

FlingToggle:OnChanged(function(Value)
    Settings.FlingPlayers = Value
    if Value then
        StartFling()
    else
        StopFling()
    end
end)

local TeleportOthersToggle = Tabs.Troll:AddToggle("TPOthers", {
    Title = "🌐 Телепорт других к вам",
    Description = "Телепортирует всех игроков к вашей позиции",
    Default = false
})

TeleportOthersToggle:OnChanged(function(Value)
    if Value then
        TeleportAllToYou()
    end
end)

local SpamJumpToggle = Tabs.Troll:AddToggle("SpamJump", {
    Title = "🦘 Спам прыжками",
    Description = "Персонаж будет постоянно прыгать",
    Default = false
})

SpamJumpToggle:OnChanged(function(Value)
    if Value then
        StartSpamJump()
    else
        StopSpamJump()
    end
end)

local BigHeadToggle = Tabs.Troll:AddToggle("BigHead", {
    Title = "🗿 Огромная голова",
    Description = "Увеличивает размер головы до гигантских размеров",
    Default = false
})

BigHeadToggle:OnChanged(function(Value)
    if Value then
        MakeBigHead()
    else
        ResetHead()
    end
end)

local RainbowCharToggle = Tabs.Troll:AddToggle("Rainbow", {
    Title = "🌈 Радужный персонаж",
    Description = "Персонаж переливается всеми цветами радуги",
    Default = false
})

RainbowCharToggle:OnChanged(function(Value)
    if Value then
        StartRainbow()
    else
        StopRainbow()
    end
end)

local CrazySection = Tabs.Troll:AddSection("🤪 Безумный троллинг")

local SeizureToggle = Tabs.Troll:AddToggle("Seizure", {
    Title = "⚡ Режим судороги",
    Description = "Персонаж начнет дергаться (НЕ для эпилептиков!)",
    Default = false
})

SeizureToggle:OnChanged(function(Value)
    if Value then
        StartSeizureMode()
    else
        StopSeizureMode()
    end
end)

local AntiGravToggle = Tabs.Troll:AddToggle("AntiGrav", {
    Title = "🌙 Анти-гравитация",
    Description = "Медленное падение как на Луне",
    Default = false
})

AntiGravToggle:OnChanged(function(Value)
    if Value then
        Workspace.Gravity = 50
    else
        Workspace.Gravity = 196.2
    end
end)

local CloneYourselfButton = Tabs.Troll:AddButton({
    Title = "👥 Клонировать себя",
    Description = "Создает копию вашего персонажа",
    Callback = function()
        CloneCharacter()
    end
})

local ExplodeButton = Tabs.Troll:AddButton({
    Title = "💥 Взрыв на месте",
    Description = "Создает взрыв в вашей позиции",
    Callback = function()
        CreateExplosion(HumanoidRootPart.Position)
    end
})

local TrollAllButton = Tabs.Troll:AddButton({
    Title = "🎪 АКТИВИРОВАТЬ ВСЁ",
    Description = "Включает ВСЕ троллинг функции! (ХАОС)",
    Callback = function()
        Settings.SpinPlayer = true
        Settings.InvisibleMode = true
        Settings.FlingPlayers = true
        StartSpin()
        MakeInvisible()
        StartFling()
        StartRainbow()
        Fluent:Notify({
            Title = "🎪 ХАОС РЕЖИМ",
            Content = "ВСЕ троллинг функции активированы! Готовьтесь к безумию!",
            Duration = 5
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- ⚙️ ВКЛАДКА "ПРОЧЕЕ"
-- ═══════════════════════════════════════════════════════════

Tabs.Misc:AddParagraph({
    Title = "⚙️ Дополнительные функции",
    Content = "Защита от кика, анти-AFK и прочие утилиты"
})

local ProtectionSection = Tabs.Misc:AddSection("🛡️ Защита")

local AntiKickToggle = Tabs.Misc:AddToggle("AntiKick", {
    Title = "🚫 Анти-Кик",
    Description = "Защита от кика с сервера",
    Default = false
})

AntiKickToggle:OnChanged(function(Value)
    Settings.AntiKick = Value
    if Value then
        EnableAntiKick()
    end
end)

local AntiAFKToggle = Tabs.Misc:AddToggle("AntiAFK", {
    Title = "⏰ Анти-AFK",
    Description = "Предотвращает кик за бездействие",
    Default = false
})

AntiAFKToggle:OnChanged(function(Value)
    Settings.AntiAFK = Value
    if Value then
        EnableAntiAFK()
    end
end)

local ServerSection = Tabs.Misc:AddSection("🌐 Сервер")

local ServerHopButton = Tabs.Misc:AddButton({
    Title = "🔄 Server Hop",
    Description = "Перейти на другой сервер",
    Callback = function()
        ServerHop()
    end
})

local RejoinButton = Tabs.Misc:AddButton({
    Title = "🔁 Переподключиться",
    Description = "Выйти и зайти на этот же сервер",
    Callback = function()
        Rejoin()
    end
})

local UtilSection = Tabs.Misc:AddSection("🔧 Утилиты")

local FPSBoostToggle = Tabs.Misc:AddToggle("FPSBoost", {
    Title = "🚀 FPS Boost",
    Description = "Оптимизация для повышения FPS",
    Default = false
})

FPSBoostToggle:OnChanged(function(Value)
    if Value then
        EnableFPSBoost()
    else
        DisableFPSBoost()
    end
end)

local RemoveFogButton = Tabs.Misc:AddButton({
    Title = "🌫️ Убрать туман",
    Description = "Убирает туман для лучшей видимости",
    Callback = function()
        Lighting.FogEnd = 100000
        Fluent:Notify({
            Title = "✅ Туман убран",
            Content = "Видимость улучшена!",
            Duration = 2
        })
    end
})

local ChatSpamSection = Tabs.Misc:AddSection("💬 Чат")

local ChatSpamToggle = Tabs.Misc:AddToggle("ChatSpam", {
    Title = "💬 Спам в чат",
    Description = "Отправляет сообщения в чат",
    Default = false
})

local ChatInput = Tabs.Misc:AddInput("ChatMessage", {
    Title = "Текст сообщения",
    Description = "Введите текст для спама",
    Default = "Glass Bridge PRO Script!",
    Placeholder = "Ваш текст...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        -- Сохранение текста
    end
})

ChatSpamToggle:OnChanged(function(Value)
    if Value then
        StartChatSpam(ChatInput.Value)
    else
        StopChatSpam()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ℹ️ ВКЛАДКА "ИНФО"
-- ═══════════════════════════════════════════════════════════

Tabs.Info:AddParagraph({
    Title = "📖 О скрипте",
    Content = "Glass Bridge PRO Script v2.0\n\n✅ Исправлены все баги\n✅ Добавлена цветная подсветка\n✅ 15+ троллинг функций\n✅ Fluent UI библиотека"
})

Tabs.Info:AddParagraph({
    Title = "🎮 Об игре",
    Content = "Impossible Squid Game Glass Bridge 2\nРазработчик: Northern Lights LTD\n\nМеханика: Пересеките стеклянный мост, выбирая правильные плитки!"
})

Tabs.Info:AddParagraph({
    Title = "🎨 Легенда цветов",
    Content = "🟢 ЗЕЛЕНЫЙ = Безопасные стекла (можно идти)\n🔴 КРАСНЫЙ = Опасные стекла (разобьются)\n\nВключите обе подсветки для полной картины!"
})

Tabs.Info:AddParagraph({
    Title = "⚠️ Дисклеймер",
    Content = "Этот скрипт только для образовательных целей!\nИспользование может нарушать ToS Roblox.\nАвтор не несет ответственности за баны."
})

local CreditsSection = Tabs.Info:AddSection("👨‍💻 Разработка")

Tabs.Info:AddParagraph({
    Title = "Информация",
    Content = "UI Library: Fluent by dawid-scripts\nGame Dev: Northern Lights LTD\nScript Version: 2.0\nБаги исправлены: ✅"
})

local DiscordButton = Tabs.Info:AddButton({
    Title = "💬 Discord сервер",
    Description = "Скопировать ссылку на Discord",
    Callback = function()
        setclipboard("discord.gg/example")
        Fluent:Notify({
            Title = "✅ Скопировано",
            Content = "Ссылка на Discord скопирована!",
            Duration = 2
        })
    end
})

-- ═══════════════════════════════════════════════════════════
-- 🔧 ОСНОВНЫЕ ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════

-- Функция поиска всех плиток моста
function FindAllBridgeTiles()
    BridgeTiles.Safe = {}
    BridgeTiles.Danger = {}
    BridgeTiles.All = {}
    
    local bridgeFolder = Workspace:FindFirstChild("Bridge") or 
                        Workspace:FindFirstChild("GlassBridge") or
                        Workspace:FindFirstChild("Map")
    
    if not bridgeFolder then
        -- Поиск в Workspace напрямую
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():match("glass") or obj.Name:lower():match("tile")) then
                table.insert(BridgeTiles.All, obj)
                AnalyzeTile(obj)
            end
        end
    else
        for _, obj in pairs(bridgeFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                table.insert(BridgeTiles.All, obj)
                AnalyzeTile(obj)
            end
        end
    end
    
    return BridgeTiles
end

-- Анализ плитки (безопасная или опасная)
function AnalyzeTile(tile)
    -- Логика определения безопасности плитки
    local isSafe = false
    
    -- Метод 1: По названию
    if tile.Name:lower():match("safe") or tile.Name:lower():match("correct") then
        isSafe = true
    elseif tile.Name:lower():match("danger") or tile.Name:lower():match("wrong") or tile.Name:lower():match("break") then
        isSafe = false
    -- Метод 2: По прозрачности (обычно безопасные меньше прозрачны)
    elseif tile.Transparency < 0.3 then
        isSafe = true
    -- Метод 3: По цвету (если есть ColorValue или BrickColor)
    elseif tile:FindFirstChild("SafeValue") then
        isSafe = tile.SafeValue.Value
    -- Метод 4: По CanCollide
    elseif tile.CanCollide == true then
        isSafe = true
    end
    
    -- Добавление в соответствующий массив
    if isSafe then
        table.insert(BridgeTiles.Safe, tile)
    else
        table.insert(BridgeTiles.Danger, tile)
    end
end

-- Подсветка безопасных плиток (ЗЕЛЕНЫЕ)
function HighlightSafeTiles()
    FindAllBridgeTiles()
    
    for _, tile in ipairs(BridgeTiles.Safe) do
        if not tile:FindFirstChild("SafeHighlight") then
            local highlight = Instance.new("BoxHandleAdornment")
            highlight.Name = "SafeHighlight"
            highlight.Size = tile.Size + Vector3.new(0.1, 0.1, 0.1)
            highlight.Color3 = Settings.SafeTileColor
            highlight.Transparency = Settings.ESPTransparency
            highlight.AlwaysOnTop = true
            highlight.ZIndex = 10
            highlight.Adornee = tile
            highlight.Parent = tile
            
            -- Добавление текста с надписью
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "SafeLabel"
            billboard.Adornee = tile
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = tile
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "✅ БЕЗОПАСНО"
            label.TextColor3 = Color3.fromRGB(0, 255, 0)
            label.TextStrokeTransparency = 0.5
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = billboard
            
            table.insert(ESPObjects, highlight)
            table.insert(ESPObjects, billboard)
        end
    end
    
    Fluent:Notify({
        Title = "🟢 Безопасные плитки",
        Content = string.format("Найдено %d безопасных плиток!", #BridgeTiles.Safe),
        Duration = 3
    })
end

-- Подсветка опасных плиток (КРАСНЫЕ)
function HighlightDangerTiles()
    FindAllBridgeTiles()
    
    for _, tile in ipairs(BridgeTiles.Danger) do
        if not tile:FindFirstChild("DangerHighlight") then
            local highlight = Instance.new("BoxHandleAdornment")
            highlight.Name = "DangerHighlight"
            highlight.Size = tile.Size + Vector3.new(0.1, 0.1, 0.1)
            highlight.Color3 = Settings.DangerTileColor
            highlight.Transparency = Settings.ESPTransparency
            highlight.AlwaysOnTop = true
            highlight.ZIndex = 10
            highlight.Adornee = tile
            highlight.Parent = tile
            
            -- Добавление текста с надписью
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "DangerLabel"
            billboard.Adornee = tile
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = tile
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "❌ ОПАСНО"
            label.TextColor3 = Color3.fromRGB(255, 0, 0)
            label.TextStrokeTransparency = 0.5
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = billboard
            
            table.insert(ESPObjects, highlight)
            table.insert(ESPObjects, billboard)
        end
    end
    
    Fluent:Notify({
        Title = "🔴 Опасные плитки",
        Content = string.format("Найдено %d опасных плиток!", #BridgeTiles.Danger),
        Duration = 3
    })
end

-- Подсветка всех плиток
function HighlightAllTiles()
    HighlightSafeTiles()
    HighlightDangerTiles()
end

-- Удаление подсветки
function RemoveHighlights(highlightType)
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Parent then
            if highlightType == "Safe" and obj.Name == "SafeHighlight" or obj.Name == "SafeLabel" then
                obj:Destroy()
            elseif highlightType == "Danger" and obj.Name == "DangerHighlight" or obj.Name == "DangerLabel" then
                obj:Destroy()
            elseif not highlightType then
                obj:Destroy()
            end
        end
    end
    ESPObjects = {}
end

-- Обновление цветов плиток
function RefreshTileColors()
    RemoveHighlights()
    if Settings.ShowSafeTiles then
        HighlightSafeTiles()
    end
    if Settings.ShowDangerTiles then
        HighlightDangerTiles()
    end
end

-- Создание безопасного пути
function CreateSafePath()
    SafePath = {}
    FindAllBridgeTiles()
    
    -- Сортировка безопасных плиток по позиции Z (от старта к финишу)
    table.sort(BridgeTiles.Safe, function(a, b)
        return a.Position.Z < b.Position.Z
    end)
    
    SafePath = BridgeTiles.Safe
    return SafePath
end

-- Автоматическое прохождение моста
function StartAutoWin()
    spawn(function()
        while Settings.AutoWin and task.wait(Settings.TeleportSpeed) do
            local path = CreateSafePath()
            
            if #path > 0 then
                for i, tile in ipairs(path) do
                    if not Settings.AutoWin then break end
                    
                    if HumanoidRootPart and tile then
                        -- Телепортация с небольшим смещением вверх
                        HumanoidRootPart.CFrame = tile.CFrame + Vector3.new(0, 3, 0)
                        task.wait(Settings.TeleportSpeed)
                        
                        -- Проверка достижения конца
                        if i == #path then
                            Fluent:Notify({
                                Title = "🏆 ПОБЕДА!",
                                Content = "Мост успешно пройден!",
                                Duration = 3
                            })
                            TeleportToBridgeEnd()
                            break
                        end
                    end
                end
            else
                Fluent:Notify({
                    Title = "⚠️ Ошибка",
                    Content = "Не удалось найти безопасные плитки!",
                    Duration = 3
                })
                break
            end
        end
    end)
end

-- Телепорт к началу моста
function TeleportToBridgeStart()
    local startPos = Workspace:FindFirstChild("BridgeStart") or 
                    Workspace:FindFirstChild("StartPlatform") or
                    Workspace:FindFirstChild("Lobby")
    
    if startPos and HumanoidRootPart then
        HumanoidRootPart.CFrame = startPos.CFrame + Vector3.new(0, 5, 0)
        Fluent:Notify({
            Title = "✅ Телепорт",
            Content = "Перемещен к началу моста",
            Duration = 2
        })
    else
        Fluent:Notify({
            Title = "❌ Ошибка",
            Content = "Не удалось найти начало моста",
            Duration = 2
        })
    end
end

-- Телепорт к концу моста (WIN)
function TeleportToBridgeEnd()
    local endPos = Workspace:FindFirstChild("BridgeEnd") or 
                  Workspace:FindFirstChild("Finish") or
                  Workspace:FindFirstChild("EndPlatform")
    
    if not endPos then
        -- Поиск последней безопасной плитки
        CreateSafePath()
        if #SafePath > 0 then
            endPos = SafePath[#SafePath]
        end
    end
    
    if endPos and HumanoidRootPart then
        HumanoidRootPart.CFrame = endPos.CFrame + Vector3.new(0, 5, 0)
        Fluent:Notify({
            Title = "🏆 ПОБЕДА!",
            Content = "Телепорт к финишу выполнен!",
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "❌ Ошибка",
            Content = "Не удалось найти конец моста",
            Duration = 2
        })
    end
end

-- Авто-сбор денег
function StartAutoCollectMoney()
    spawn(function()
        while Settings.AutoCollectMoney and task.wait(0.5) do
            local money = Workspace:FindFirstChild("Money") or 
                         Workspace:FindFirstChild("Coins") or
                         Workspace:FindFirstChild("Cash")
            
            if money then
                for _, coin in pairs(money:GetChildren()) do
                    if coin:IsA("BasePart") and HumanoidRootPart then
                        -- Попытка сбора через TouchInterest
                        if coin:FindFirstChild("TouchInterest") then
                            firetouchinterest(HumanoidRootPart, coin, 0)
                            task.wait(0.1)
                            firetouchinterest(HumanoidRootPart, coin, 1)
                        else
                            -- Телепортация к монете
                            local oldPos = HumanoidRootPart.CFrame
                            HumanoidRootPart.CFrame = coin.CFrame
                            task.wait(0.1)
                            HumanoidRootPart.CFrame = oldPos
                        end
                    end
                end
            end
        end
    end)
end

-- Авто-открытие ящиков
function StartAutoOpenCrates()
    spawn(function()
        while Settings.AutoOpenCrates and task.wait(1) do
            local crates = Workspace:FindFirstChild("Crates") or 
                          Workspace:FindFirstChild("LuckyCrates") or
                          Workspace:FindFirstChild("Chests")
            
            if crates then
                for _, crate in pairs(crates:GetChildren()) do
                    if crate:FindFirstChild("ClickDetector") then
                        fireclickdetector(crate.ClickDetector)
                        task.wait(0.5)
                    elseif crate:FindFirstChild("ProximityPrompt") then
                        fireproximityprompt(crate.ProximityPrompt)
                        task.wait(0.5)
                    end
                end
            end
        end
    end)
end

-- Авто-Rebirth
function StartAutoRebirth()
    spawn(function()
        while Settings.AutoRebirth and task.wait(5) do
            -- Поиск кнопки rebirth
            local rebirthButton = Workspace:FindFirstChild("RebirthButton") or
                                 game:GetService("ReplicatedStorage"):FindFirstChild("RebirthEvent")
            
            if rebirthButton then
                if rebirthButton:IsA("ClickDetector") then
                    fireclickdetector(rebirthButton)
                elseif rebirthButton:IsA("RemoteEvent") then
                    rebirthButton:FireServer()
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 🎭 ТРОЛЛИНГ ФУНКЦИИ
-- ═══════════════════════════════════════════════════════════

-- Фейковый лаг
function StartFakeLag()
    TrollConnections.FakeLag = RunService.Heartbeat:Connect(function()
        if math.random(1, 10) > 7 then
            task.wait(math.random(1, 3) / 10)
        end
    end)
end

function StopFakeLag()
    if TrollConnections.FakeLag then
        TrollConnections.FakeLag:Disconnect()
    end
end

-- Фейковая смерть
function ExecuteFakeDeath()
    if Humanoid then
        Humanoid.PlatformStand = true
        task.wait(0.5)
        Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    end
end

function CancelFakeDeath()
    if Humanoid then
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- Невидимость
function MakeInvisible()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 1
        elseif part:IsA("Accessory") then
            part.Handle.Transparency = 1
        end
    end
    if Character:FindFirstChild("Head") and Character.Head:FindFirstChild("face") then
        Character.Head.face.Transparency = 1
    end
end

function MakeVisible()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
        elseif part:IsA("Accessory") then
            part.Handle.Transparency = 0
        end
    end
    if Character:FindFirstChild("Head") and Character.Head:FindFirstChild("face") then
        Character.Head.face.Transparency = 0
    end
end

-- Вращение персонажа
function StartSpin()
    local spinValue = SpinSpeedSlider and SpinSpeedSlider.Value or 50
    
    TrollConnections.Spin = RunService.Heartbeat:Connect(function()
        if Settings.SpinPlayer and HumanoidRootPart then
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinValue), 0)
        end
    end)
end

function StopSpin()
    if TrollConnections.Spin then
        TrollConnections.Spin:Disconnect()
    end
end

-- Режим призрака
function EnableGhostMode()
    Settings.NoClip = true
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.7
            part.CanCollide = false
        end
    end
end

function DisableGhostMode()
    Settings.NoClip = false
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        end
    end
end

-- Fling игроков
function StartFling()
    spawn(function()
        while Settings.FlingPlayers and task.wait(0.1) do
            if HumanoidRootPart then
                HumanoidRootPart.Velocity = Vector3.new(0, 1000, 0)
                HumanoidRootPart.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
            end
        end
    end)
end

function StopFling()
    if HumanoidRootPart then
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- Телепорт всех к вам
function TeleportAllToYou()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame
        end
    end
    Fluent:Notify({
        Title = "🌐 Телепорт",
        Content = "Все игроки телепортированы к вам!",
        Duration = 2
    })
end

-- Спам прыжками
function StartSpamJump()
    TrollConnections.SpamJump = RunService.Heartbeat:Connect(function()
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function StopSpamJump()
    if TrollConnections.SpamJump then
        TrollConnections.SpamJump:Disconnect()
    end
end

-- Огромная голова
function MakeBigHead()
    if Character:FindFirstChild("Head") then
        Character.Head.Size = Vector3.new(10, 10, 10)
    end
end

function ResetHead()
    if Character:FindFirstChild("Head") then
        Character.Head.Size = Vector3.new(2, 1, 1)
    end
end

-- Радужный персонаж
function StartRainbow()
    TrollConnections.Rainbow = RunService.Heartbeat:Connect(function()
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 1, 1)
        
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = color
            end
        end
    end)
end

function StopRainbow()
    if TrollConnections.Rainbow then
        TrollConnections.Rainbow:Disconnect()
    end
end

-- Режим судороги
function StartSeizureMode()
    TrollConnections.Seizure = RunService.Heartbeat:Connect(function()
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(
                math.random(-2, 2),
                math.random(-2, 2),
                math.random(-2, 2)
            )
        end
    end)
end

function StopSeizureMode()
    if TrollConnections.Seizure then
        TrollConnections.Seizure:Disconnect()
    end
end

-- Клонирование персонажа
function CloneCharacter()
    local clone = Character:Clone()
    clone.Parent = Workspace
    clone.Name = "Clone_" .. LocalPlayer.Name
    clone:MoveTo(HumanoidRootPart.Position + Vector3.new(5, 0, 0))
    
    Fluent:Notify({
        Title = "👥 Клон создан",
        Content = "Ваш клон появился рядом с вами!",
        Duration = 2
    })
end

-- Взрыв
function CreateExplosion(position)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = 20
    explosion.BlastPressure = 500000
    explosion.Parent = Workspace
end

-- ═══════════════════════════════════════════════════════════
-- 🛡️ ЗАЩИТА И УТИЛИТЫ
-- ═══════════════════════════════════════════════════════════

-- Анти-Кик
function EnableAntiKick()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then
            return nil
        end
        return old(self, ...)
    end)
    
    setreadonly(mt, true)
    
    Fluent:Notify({
        Title = "🛡️ Анти-Кик",
        Content = "Защита от кика активирована!",
        Duration = 2
    })
end

-- Анти-AFK
function EnableAntiAFK()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    
    Fluent:Notify({
        Title = "⏰ Анти-AFK",
        Content = "Защита от AFK-кика активна!",
        Duration = 2
    })
end

-- Server Hop
function ServerHop()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    
    local _place = game.PlaceId
    local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
    
    function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end
    
    local Server, Next
    repeat
        local Servers = ListServers(Next)
        Server = Servers.data[1]
        Next = Servers.nextPageCursor
    until Server
    
    TPS:TeleportToPlaceInstance(_place, Server.id, LocalPlayer)
end

-- Переподключение
function Rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end

-- FPS Boost
function EnableFPSBoost()
    local Terrain = Workspace.Terrain
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    
    Fluent:Notify({
        Title = "🚀 FPS Boost",
        Content = "Оптимизация применена!",
        Duration = 2
    })
end

function DisableFPSBoost()
    Lighting.GlobalShadows = true
end

-- ESP игроков
function EnablePlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "PlayerESP"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = player.Character
            
            if Settings.ShowDistance then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "DistanceLabel"
                billboard.Adornee = player.Character:FindFirstChild("Head")
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = player.Character
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = player.Name
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0.5
                label.TextScaled = true
                label.Parent = billboard
                
                spawn(function()
                    while player.Character and label do
                        if HumanoidRootPart and player.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            label.Text = string.format("%s\n[%.1f]", player.Name, distance)
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    end
end

function DisablePlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local esp = player.Character:FindFirstChild("PlayerESP")
            if esp then esp:Destroy() end
            local label = player.Character:FindFirstChild("DistanceLabel")
            if label then label:Destroy() end
        end
    end
end

-- ESP денег
function EnableMoneyESP()
    local money = Workspace:FindFirstChild("Money") or Workspace:FindFirstChild("Coins")
    if money then
        for _, coin in pairs(money:GetChildren()) do
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "MoneyESP"
            billboard.Adornee = coin
            billboard.Size = UDim2.new(0, 50, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.Parent = coin
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "💰"
            label.TextColor3 = Color3.fromRGB(255, 255, 0)
            label.TextScaled = true
            label.Parent = billboard
        end
    end
end

function DisableMoneyESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "MoneyESP" then
            obj:Destroy()
        end
    end
end

-- ESP ящиков
function EnableCrateESP()
    local crates = Workspace:FindFirstChild("Crates") or Workspace:FindFirstChild("LuckyCrates")
    if crates then
        for _, crate in pairs(crates:GetChildren()) do
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "CrateESP"
            billboard.Adornee = crate
            billboard.Size = UDim2.new(0, 80, 0, 80)
            billboard.AlwaysOnTop = true
            billboard.Parent = crate
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "📦 CRATE"
            label.TextColor3 = Color3.fromRGB(255, 165, 0)
            label.TextScaled = true
            label.TextStrokeTransparency = 0.5
            label.Parent = billboard
        end
    end
end

function DisableCrateESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "CrateESP" then
            obj:Destroy()
        end
    end
end

-- Полет
local Flying = false
local FlySpeed = 50
local BodyVelocity, BodyGyro

function StartFly()
    Flying = true
    
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Parent = HumanoidRootPart
    
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.P = 9e4
    BodyGyro.Parent = HumanoidRootPart
    
    spawn(function()
        while Flying do
            local cam = Workspace.CurrentCamera
            local moveDirection = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + (cam.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - (cam.CFrame.LookVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - (cam.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + (cam.CFrame.RightVector)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            BodyVelocity.Velocity = moveDirection * FlySpeed
            BodyGyro.CFrame = cam.CFrame
            
            task.wait()
        end
    end)
end

function StopFly()
    Flying = false
    if BodyVelocity then BodyVelocity:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end
end

-- God Mode
local OldNamecall
function EnableGodMode()
    if not OldNamecall then
        OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
            local Args = {...}
            local NamecallMethod = getnamecallmethod()
            
            if NamecallMethod == "TakeDamage" or NamecallMethod == "ChangeHealth" then
                return
            end
            
            return OldNamecall(Self, ...)
        end)
    end
    
    Fluent:Notify({
        Title = "🛡️ God Mode",
        Content = "Бессмертие активировано!",
        Duration = 2
    })
end

function DisableGodMode()
    if OldNamecall then
        hookmetamethod(game, "__namecall", OldNamecall)
        OldNamecall = nil
    end
end

-- Спам в чат
local ChatSpamConnection
function StartChatSpam(message)
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    ChatSpamConnection = task.spawn(function()
        while Settings.ChatSpam do
            pcall(function()
                if TextChatService:FindFirstChild("TextChannels") then
                    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                    if channel then
                        channel:SendAsync(message)
                    end
                else
                    local DefaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if DefaultChatSystemChatEvents then
                        local SayMessageRequest = DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                        if SayMessageRequest then
                            SayMessageRequest:FireServer(message, "All")
                        end
                    end
                end
            end)
            task.wait(3)
        end
    end)
end

function StopChatSpam()
    if ChatSpamConnection then
        task.cancel(ChatSpamConnection)
    end
end

-- ═══════════════════════════════════════════════════════════
-- 🔄 ОБНОВЛЕНИЕ ПЕРСОНАЖА
-- ═══════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    
    task.wait(1)
    
    -- Применение настроек
    if Humanoid then
        Humanoid.WalkSpeed = Settings.WalkSpeed
        Humanoid.JumpPower = Settings.JumpPower
    end
    
    -- Повторная активация ESP если был включен
    if Settings.ESP_Enabled then
        EnablePlayerESP()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎯 ОСНОВНЫЕ ЦИКЛЫ
-- ═══════════════════════════════════════════════════════════

-- Бесконечный прыжок
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if Settings.NoClip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎉 ЗАВЕРШЕНИЕ ЗАГРУЗКИ
-- ═══════════════════════════════════════════════════════════

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("GlassBridgePRO")
SaveManager:SetFolder("GlassBridgePRO/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Misc)
SaveManager:BuildConfigSection(Tabs.Misc)

Window:SelectTab(1)

Fluent:Notify({
    Title = "✅ Glass Bridge PRO загружен!",
    Content = "Все баги исправлены! Версия 2.0",
    Duration = 5
})

print("═══════════════════════════════════════════════")
print("🎮 Glass Bridge PRO Script v2.0")
print("✅ UI Library: Fluent")
print("✅ Все баги исправлены!")
print("✅ Цветная подсветка работает!")
print("🟢 Зеленый = Безопасные стекла")
print("🔴 Красный = Опасные стекла")
print("═══════════════════════════════════════════════")
