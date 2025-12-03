local addonName, ns = ...
local locale = GetLocale()

local L = {
    Title = "Pretty Nameplates v1.3.3", -- Обновлено
    Author = "Author: Baime / Metkiymuu",

    TabGeneral = "General",
    TabStyle = "Style",
    TabText = "Text",
    TabWidgets = "Widgets",
    ShowCastbar = "Enable Castbars",
    ShowAuras = "Enable Debuffs",
    ShowHpVal = "Show HP Numbers",
    ShowMinimap = "Minimap Button",

    Width = "Width",
    HpHeight = "HP Height",
    CastHeight = "Cast Height",
    Scale = "Scale",
    Texture = "Texture",
    HpColor = "PvE HP Color",
    CastColor = "Castbar Color",
    TankMode = "Tank Mode",
    ColorNeutral = "Color Neutral",
    NonTargetAlpha = "Alpha",

    Font = "Font",
    FontSize = "Font Size",
    FontOutline = "Outline",
    ShowHpPerc = "Show %",

    AuraSize = "Icon Size",
    ZoomIcons = "Zoom Icons",
    CompactTotems = "Compact Totems",
    ShowPets = "Show Pets",
    PetScale = "Pet Scale",
    PetColor = "Pet Color",
    ShowImportant = "Show Saves",
    ImportantSize = "Save Size",
    ShowMyDebuffsOnly = "Show My Debuffs Only",

    CPHeader = "Combo Points",
    CPSize = "Size",
    CPX = "X",
    CPY = "Y",
    LeftClick = "Left Click: ",
    Settings = "Settings",
    Reload = "Right Click: Reload UI"
}

if locale == "ruRU" then
    L.Title = "Pretty Nameplates v1.3.1"
    L.Author = "Автор: Baime / Меткиймуу"

    L.TabGeneral = "Общее"
    L.TabStyle = "Стиль"
    L.TabText = "Текст"
    L.TabWidgets = "Виджеты"
    L.ShowCastbar = "Показывать кастбары"
    L.ShowAuras = "Показывать дебаффы"
    L.ShowHpVal = "Показывать здоровье (Числа)"
    L.ShowMinimap = "Кнопка у миникарты"

    L.Width = "Ширина"
    L.HpHeight = "Высота здоровья"
    L.CastHeight = "Высота кастбара"
    L.Scale = "Масштаб"
    L.Texture = "Текстура"
    L.HpColor = "Цвет ХП (PvE)"
    L.CastColor = "Цвет Кастбара"
    L.TankMode = "Танк режим"
    L.ColorNeutral = "Красить нейтральных"
    L.NonTargetAlpha = "Прозрачность остальных"

    L.Font = "Шрифт"
    L.FontSize = "Размер шрифта"
    L.FontOutline = "Обводка текста"
    L.ShowHpPerc = "Показывать проценты"

    L.AuraSize = "Размер иконок"
    L.ZoomIcons = "Обрезать края иконок"
    L.CompactTotems = "Компактные Тотемы"
    L.ShowPets = "Показывать Питомцев"
    L.PetScale = "Масштаб Питомцев"
    L.PetColor = "Цвет Питомцев"
    L.ShowImportant = "Отслеживать Сейвы"
    L.ImportantSize = "Размер Сейвов"
    L.ShowMyDebuffsOnly = "Только мои дебаффы"

    L.CPHeader = "Комбо Поинты"
    L.CPSize = "Размер"
    L.CPX = "Смещение X"
    L.CPY = "Смещение Y"
    L.LeftClick = "ЛКМ: "
    L.Settings = "Настройки"
    L.Reload = "ПКМ: Перезагрузить интерфейс"
end
ns.L = L
ns.ClassCache = {}

ns.Fonts = {
    { name = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF" },
    { name = "Arial Narrow",  path = "Fonts\\ARIALN.TTF" },
    { name = "Morpheus",      path = "Fonts\\MORPHEUS.TTF" },
    { name = "Skurri",        path = "Fonts\\SKURRI.TTF" },
}
ns.Outlines = { { name = "None", value = "" }, { name = "Thin", value = "OUTLINE" }, { name = "Thick", value = "THICKOUTLINE" }, { name = "Monochrome", value = "MONOCHROME" } }
ns.Textures = {
    { name = "Flat",       path = "Interface\\Buttons\\WHITE8X8" },
    { name = "Blizzard",   path = "Interface\\TargetingFrame\\UI-StatusBar" },
    { name = "Smooth",     path = "Interface\\AddOns\\PrettyNameplates\\Media\\Smooth.tga" },
    { name = "Minimalist", path = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill" },
}

ns.ImportantBuffs = {
    [642] = true,
    [10278] = true,
    [498] = true,
    [64205] = true,
    [31821] = true,
    [1044] = true,
    [53563] = true,
    [31884] = true,
    [871] = true,
    [12975] = true,
    [23920] = true,
    [2565] = true,
    [1719] = true,
    [46924] = true,
    [12292] = true,
    [22812] = true,
    [61336] = true,
    [29166] = true,
    [50334] = true,
    [53312] = true,
    [47585] = true,
    [33206] = true,
    [47788] = true,
    [10060] = true,
    [6346] = true,
    [48066] = true,
    [15473] = true,
    [48707] = true,
    [48792] = true,
    [49039] = true,
    [55233] = true,
    [49222] = true,
    [51271] = true,
    [45438] = true,
    [11426] = true,
    [12042] = true,
    [12472] = true,
    [12051] = true,
    [66] = true,
    [26669] = true,
    [31224] = true,
    [2983] = true,
    [51713] = true,
    [13750] = true,
    [19263] = true,
    [19574] = true,
    [3045] = true,
    [34477] = true,
    [53480] = true,
    [30823] = true,
    [16188] = true,
    [2825] = true,
    [32182] = true,
    [28527] = true,
    [7812] = true,
    [19438] = true,
    [19440] = true,
    [19441] = true,
    [19442] = true,
    [19443] = true,
    [47891] = true,
    [28610] = true,
    [6229] = true,
    [19028] = true,
    [18708] = true,
    [54370] = true,
    [54371] = true,
    [54372] = true,
    [54373] = true,
    [54374] = true,
    [54375] = true,
    [20594] = true,
    [59547] = true,
    [20572] = true,
    [26297] = true,
    [7744] = true,
}

ns.defaults = {
    width = 130,
    hpHeight = 14,
    castHeight = 12,
    scale = 1,
    texture = "Interface\\Buttons\\WHITE8X8",
    hpColor = { r = 1, g = 0.2, b = 0.2 },
    castColor = { r = 1, g = 0.8, b = 0 },
    tankMode = false,
    colorNeutral = true,
    nonTargetAlpha = 0.6,
    font = "Fonts\\FRIZQT__.TTF",
    fontSize = 10,
    fontOutline = "OUTLINE",
    showHpVal = true,
    showHpPerc = true,
    showCastbar = true,
    showAuras = true,
    auraSize = 18,
    showMyDebuffsOnly = true,
    zoomIcons = true,
    compactTotems = true,
    showPets = true,
    petScale = 0.7,
    petColor = { r = 0.5, g = 0.5, b = 0.5 },
    showImportant = true,
    importantSize = 24,
    cpSize = 6,
    cpX = 0,
    cpY = 0,
    minimap = { hide = false, pos = 45 },
}

function ns:LoadVariables()
    if not PrettyNameplatesDB then PrettyNameplatesDB = {} end
    for k, v in pairs(ns.defaults) do
        if PrettyNameplatesDB[k] == nil then PrettyNameplatesDB[k] = v end
    end
    if not PrettyNameplatesDB.texture or PrettyNameplatesDB.texture == "" then
        PrettyNameplatesDB.texture = ns.defaults
            .texture
    end
end
