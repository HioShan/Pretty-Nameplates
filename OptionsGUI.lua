local addonName, ns = ...
local L = ns.L

local guiFrame = nil
local previewPlate = nil

-- == ОБНОВЛЕНИЕ ==
local function UpdateAll()
    if ns.UpdateAllPlates then ns:UpdateAllPlates() end
    if ns.UpdateMinimapButton then ns:UpdateMinimapButton() end
end

-- == ШРИФТЫ ==
local function ForceFont(fs, size)
    fs:SetFont("Fonts\\FRIZQT__.TTF", size or 10, "OUTLINE")
    fs:SetTextColor(1, 0.82, 0)
end

local function ForceText(fs)
    fs:SetFont("Fonts\\FRIZQT__.TTF", 10)
    fs:SetTextColor(1, 1, 1)
end

-- == СОЗДАНИЕ ПРЕВЬЮ ==
local function CreatePreviewFrame(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetSize(300, 90)
    p:SetPoint("TOP", 0, -45)

    local bg = p:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0, 0, 0, 0.3)

    local lbl = p:CreateFontString(nil, "OVERLAY")
    ForceFont(lbl, 10)
    lbl:SetPoint("BOTTOM", p, "TOP", 0, 2)
    lbl:SetText("LIVE PREVIEW (Живой макет)")

    -- ФЕЙКОВЫЙ ПЛЕЙТ
    local plate = CreateFrame("Frame", nil, p)
    plate:SetSize(120, 20)
    plate:SetPoint("CENTER")

    local hp = CreateFrame("StatusBar", nil, plate)
    hp:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    hp:SetMinMaxValues(0, 100)
    hp:SetValue(75)
    hp:SetPoint("CENTER")

    local hpBg = hp:CreateTexture(nil, "BACKGROUND")
    hpBg:SetAllPoints()
    hpBg:SetTexture(0, 0, 0, 0.8)

    local hpBd = CreateFrame("Frame", nil, hp)
    hpBd:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    hpBd:SetBackdropBorderColor(0, 0, 0, 1)
    hpBd:SetPoint("TOPLEFT", -1, 1)
    hpBd:SetPoint("BOTTOMRIGHT", 1, -1)

    local cb = CreateFrame("StatusBar", nil, plate)
    cb:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    cb:SetMinMaxValues(0, 100)
    cb:SetValue(50)

    local cbBg = cb:CreateTexture(nil, "BACKGROUND")
    cbBg:SetAllPoints()
    cbBg:SetTexture(0, 0, 0, 0.8)

    local cbBd = CreateFrame("Frame", nil, cb)
    cbBd:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    cbBd:SetBackdropBorderColor(0, 0, 0, 1)
    cbBd:SetPoint("TOPLEFT", -1, 1)
    cbBd:SetPoint("BOTTOMRIGHT", 1, -1)

    local nameText = hp:CreateFontString(nil, "OVERLAY")
    local hpText = hp:CreateFontString(nil, "OVERLAY")
    local centerText = hp:CreateFontString(nil, "OVERLAY")

    local cbTime = cb:CreateFontString(nil, "OVERLAY")
    local cbName = cb:CreateFontString(nil, "OVERLAY")
    local cbIcon = cb:CreateTexture(nil, "OVERLAY")
    cbIcon:SetTexture("Interface\\Icons\\Spell_Holy_MagicalSentry")
    local cbIconBg = cb:CreateTexture(nil, "ARTWORK")
    cbIconBg:SetTexture(0, 0, 0, 1)

    local auras = {}
    for i = 1, 3 do
        local a = CreateFrame("Frame", nil, plate)
        a.icon = a:CreateTexture(nil, "BACKGROUND")
        a.icon:SetAllPoints()
        a.icon:SetTexture(i == 1 and "Interface\\Icons\\Spell_Fire_FlameShock" or
        "Interface\\Icons\\Spell_Shadow_CurseOfTounges")

        a.cd = a:CreateFontString(nil, "OVERLAY")
        a.cd:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        a.cd:SetText(i * 5)

        a:SetSize(16, 16)
        auras[i] = a
    end

    local imp = CreateFrame("Frame", nil, plate)
    imp.icon = imp:CreateTexture(nil, "BACKGROUND")
    imp.icon:SetAllPoints()
    imp.icon:SetTexture("Interface\\Icons\\Spell_Holy_DivineIntervention")

    imp.cd = imp:CreateFontString(nil, "OVERLAY")
    imp.cd:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    imp.cd:SetText("4")

    imp.bd = CreateFrame("Frame", nil, imp)
    imp.bd:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    imp.bd:SetBackdropBorderColor(1, 0, 0, 1)
    imp.bd:SetAllPoints()
    imp:SetSize(24, 24)

    local cps = {}
    for i = 1, 5 do
        local cp = plate:CreateTexture(nil, "OVERLAY")
        cp:SetSize(6, 6)
        cp:SetTexture("Interface\\COMMON\\Indicator-Yellow")
        cps[i] = cp
    end

    local castTimer = 0
    local auraTimer = 5

    plate:SetScript("OnUpdate", function(self, elapsed)
        if not guiFrame:IsShown() then return end

        castTimer = castTimer + elapsed
        if castTimer > 1.5 then castTimer = 0 end
        cb:SetValue((1.5 - castTimer) / 1.5 * 100)
        cbTime:SetText(string.format("%.1f", 1.5 - castTimer))

        auraTimer = auraTimer - elapsed
        if auraTimer < 0 then auraTimer = 5 end
        for i = 1, 3 do
            auras[i].cd:SetText(math.ceil(auraTimer + i))
        end
    end)

    ns.UpdatePreview = function()
        if not guiFrame:IsShown() then return end
        local db = PrettyNameplatesDB

        hp:SetSize(db.width, db.hpHeight)
        cb:SetSize(db.width, db.castHeight)

        hp:SetStatusBarTexture(db.texture)
        cb:SetStatusBarTexture(db.texture)

        hp:SetStatusBarColor(db.hpColor.r, db.hpColor.g, db.hpColor.b)
        cb:SetStatusBarColor(db.castColor.r, db.castColor.g, db.castColor.b)
        
        -- Update background color
        local bgColor = db.hpBgColor or ns.defaults.hpBgColor
        local alpha = (db.hpBgAlpha or ns.defaults.hpBgAlpha or 80) / 100
        hpBg:SetTexture(bgColor.r, bgColor.g, bgColor.b, alpha)

        cb:ClearAllPoints()
        cb:SetPoint("TOP", hp, "BOTTOM", 0, -2)

        local f, fs, fo = db.font, db.fontSize, db.fontOutline
        nameText:SetFont(f, fs, fo)
        hpText:SetFont(f, fs - 2, fo)
        centerText:SetFont(f, fs - 2, fo)
        cbTime:SetFont(f, 8, "OUTLINE")
        cbName:SetFont(f, 8, "OUTLINE")
        imp.cd:SetFont(f, 12, "OUTLINE")

        nameText:ClearAllPoints()
        nameText:SetPoint("BOTTOMLEFT", hp, "TOPLEFT", 0, 3)
        nameText:SetPoint("RIGHT", hpText, "LEFT", -5, 0)
        nameText:SetText("Target Dummy")

        hpText:ClearAllPoints()
        hpText:SetPoint("BOTTOMRIGHT", hp, "TOPRIGHT", 0, 3)
        if db.showHpPerc then hpText:SetText("75%") else hpText:SetText("") end

        centerText:ClearAllPoints()
        centerText:SetPoint("CENTER", hp, "CENTER")
        if db.showHpVal then centerText:SetText("15K / 20K") else centerText:SetText("") end

        if db.showCastbar then
            cb:Show()
            local isz = db.castHeight + 4
            cbIcon:SetSize(isz, isz)
            cbIconBg:SetSize(isz + 2, isz + 2)
            cbIcon:ClearAllPoints()
            cbIcon:SetPoint("RIGHT", cb, "LEFT", -4, 0)
            cbIconBg:SetPoint("CENTER", cbIcon)

            -- ИСПРАВЛЕНО: ИНВЕРСИЯ ЛОГИКИ ЗУМА В МЕНЮ
            if db.zoomIcons then
                cbIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- CROP
            else
                cbIcon:SetTexCoord(0, 1, 0, 1)             -- FULL
            end

            cbTime:SetPoint("RIGHT", cb, "RIGHT", -4, 0)
            cbTime:SetText("1.2")
            cbName:SetPoint("LEFT", cb, "LEFT", 4, 0)
            cbName:SetText("Casting...")
        else
            cb:Hide()
        end

        local as = db.auraSize
        local bo = fs + 6
        for i = 1, 3 do
            local a = auras[i]
            if db.showAuras then
                a:Show()
                a:SetSize(as, as)
                a.cd:SetFont(f, math.max(8, as / 1.5), "OUTLINE")

                -- ИСПРАВЛЕНО: ИНВЕРСИЯ ЛОГИКИ ЗУМА
                if db.zoomIcons then
                    a.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
                else
                    a.icon:SetTexCoord(0, 1, 0, 1)
                end

                a:ClearAllPoints()
                if i == 1 then
                    a:SetPoint("BOTTOMLEFT", hp, "TOPLEFT", 0, bo)
                else
                    a:SetPoint("LEFT", auras[i - 1], "RIGHT", 1, 0)
                end
            else
                a:Hide()
            end
        end

        if db.showImportant then
            imp:Show()
            local isz = db.importantSize or 24
            imp:SetSize(isz, isz)
            imp:ClearAllPoints()
            imp:SetPoint("LEFT", hp, "RIGHT", 6, 0)

            -- ИСПРАВЛЕНО: ИНВЕРСИЯ ЛОГИКИ ЗУМА
            if db.zoomIcons then
                imp.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            else
                imp.icon:SetTexCoord(0, 1, 0, 1)
            end
        else
            imp:Hide()
        end

        local cpOffset = -(db.castHeight + 2)
        local cpx = db.cpX or 0
        local cpy = db.cpY or 0
        local cpSize = db.cpSize or 6
        for i = 1, 5 do
            cps[i]:ClearAllPoints()
            cps[i]:SetSize(cpSize, cpSize)
            if i == 1 then
                cps[i]:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", cpx, cpOffset + cpy)
            else
                cps[i]:SetPoint("LEFT", cps[i - 1], "RIGHT", 2, 0)
            end
            cps[i]:Show()
        end
        plate:SetScale(db.scale)
    end
    ns.UpdatePreview()
end

-- == GUI MAIN ==
function ns:ToggleGUI()
    if guiFrame then
        if guiFrame:IsShown() then guiFrame:Hide() else
            guiFrame:Show()
            ns.UpdatePreview()
        end
        return
    end

    if not PrettyNameplatesDB then PrettyNameplatesDB = {} end

    guiFrame = CreateFrame("Frame", "PrettyNameplatesGUI", UIParent)
    guiFrame:SetSize(500, 550)
    guiFrame:SetPoint("CENTER")
    guiFrame:SetFrameStrata("HIGH")
    guiFrame:EnableMouse(true)
    guiFrame:SetMovable(true)
    guiFrame:RegisterForDrag("LeftButton")
    guiFrame:SetScript("OnDragStart", guiFrame.StartMoving)
    guiFrame:SetScript("OnDragStop", guiFrame.StopMovingOrSizing)

    guiFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    local header = guiFrame:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetSize(350, 64)
    header:SetPoint("TOP", 0, 12)

    local title = guiFrame:CreateFontString(nil, "OVERLAY")
    ForceFont(title, 12)
    title:SetPoint("CENTER", header, "CENTER", 0, 12)
    title:SetText(L.Title)

    local close = CreateFrame("Button", nil, guiFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    CreatePreviewFrame(guiFrame)

    local content = CreateFrame("Frame", nil, guiFrame)
    content:SetSize(460, 350)
    content:SetPoint("BOTTOM", 0, 20)

    local tabs = {}
    local function ShowTab(id)
        for i, f in pairs(tabs) do
            if i == id then f:Show() else f:Hide() end
        end
    end

    local function CreateTabButton(id, text, x)
        local btn = CreateFrame("Button", nil, guiFrame, "UIPanelButtonTemplate")
        btn:SetSize(100, 24)
        btn:SetPoint("TOPLEFT", x, -140)
        local t = btn:CreateFontString(nil, "OVERLAY")
        ForceFont(t, 10)
        t:SetPoint("CENTER")
        t:SetText(text)
        btn:SetScript("OnClick", function() ShowTab(id) end)
        return btn
    end

    CreateTabButton(1, L.TabGeneral, 20)
    CreateTabButton(2, L.TabStyle, 125)
    CreateTabButton(3, L.TabText, 230)
    CreateTabButton(4, L.TabWidgets, 335)

    -- WIDGETS
    local function AddCheck(p, label, var, x, y)
        local cb = CreateFrame("CheckButton", nil, p, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", x, y)
        local t = p:CreateFontString(nil, "OVERLAY")
        ForceText(t)
        t:SetPoint("LEFT", cb, "RIGHT", 5, 1)
        t:SetText(label)
        cb:SetChecked(PrettyNameplatesDB[var])
        cb:SetScript("OnClick",
            function(self)
                PrettyNameplatesDB[var] = self:GetChecked()
                UpdateAll()
                ns.UpdatePreview()
            end)
        cb:SetScript("OnShow", function(self) self:SetChecked(PrettyNameplatesDB[var]) end)
        return cb
    end

    local function AddSlide(p, label, var, min, max, x, y, isFloat)
        local s = CreateFrame("Slider", "PnpGuiSld" .. var, p, "OptionsSliderTemplate")
        s:SetPoint("TOPLEFT", x, y)
        s:SetMinMaxValues(min, max)
        s:SetWidth(180)
        if isFloat then s:SetValueStep(0.1) else s:SetValueStep(1) end
        _G[s:GetName() .. "Text"]:SetText(label)
        _G[s:GetName() .. "Low"]:SetText(min)
        _G[s:GetName() .. "High"]:SetText(max)
        s:SetValue(PrettyNameplatesDB[var] or min)
        _G[s:GetName() .. "Text"]:SetText(label .. ": " .. (PrettyNameplatesDB[var] or min))
        s:SetScript("OnValueChanged", function(self, v)
            if isFloat then v = math.floor(v * 10 + 0.5) / 10 else v = math.floor(v) end
            if var == "scale" and v < 0.1 then v = 0.1 end
            PrettyNameplatesDB[var] = v
            UpdateAll()
            ns.UpdatePreview()
            _G[s:GetName() .. "Text"]:SetText(label .. ": " .. v)
        end)
        s:SetScript("OnShow", function(self)
            local v = PrettyNameplatesDB[var] or min
            self:SetValue(v)
            _G[s:GetName() .. "Text"]:SetText(label .. ": " .. v)
        end)
    end

    local function AddColor(p, label, key, x, y)
        local b = CreateFrame("Button", nil, p)
        b:SetSize(16, 16)
        b:SetPoint("TOPLEFT", x, y)
        local bg = b:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(1, 1, 1, 1)
        b.bg = bg
        local t = p:CreateFontString(nil, "OVERLAY")
        ForceText(t)
        t:SetPoint("LEFT", b, "RIGHT", 5, 0)
        t:SetText(label)
        b:SetScript("OnClick", function()
            local c = PrettyNameplatesDB[key]
            ColorPickerFrame:SetColorRGB(c.r, c.g, c.b)
            ColorPickerFrame.func = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local newColor = { r = r, g = g, b = b }
                -- Preserve alpha if it exists
                if c.a then newColor.a = c.a end
                PrettyNameplatesDB[key] = newColor
                b.bg:SetTexture(r, g, b, 1)
                UpdateAll()
                ns.UpdatePreview()
            end
            ColorPickerFrame:Show()
        end)
        b:SetScript("OnShow", function()
            local c = PrettyNameplatesDB[key]
            b.bg:SetTexture(c.r, c.g, c.b, 1)
        end)
    end

    local function AddDropdown(p, label, key, list, x, y)
        local dd = CreateFrame("Button", "PnpGuiDrop" .. key, p, "UIDropDownMenuTemplate")
        dd:SetPoint("TOPLEFT", x, y)
        UIDropDownMenu_SetWidth(dd, 140)
        local t = p:CreateFontString(nil, "OVERLAY")
        ForceText(t)
        t:SetPoint("BOTTOMLEFT", dd, "TOPLEFT", 16, 3)
        t:SetText(label)
        UIDropDownMenu_Initialize(dd, function()
            for _, item in ipairs(list) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.name
                info.value = item.path or item.value
                info.func = function(self)
                    UIDropDownMenu_SetSelectedValue(dd, self.value)
                    PrettyNameplatesDB[key] = self.value
                    UpdateAll()
                    ns.UpdatePreview()
                end
                info.checked = (PrettyNameplatesDB[key] == info.value)
                UIDropDownMenu_AddButton(info)
            end
        end)
        dd:SetScript("OnShow", function()
            UIDropDownMenu_SetSelectedValue(dd, PrettyNameplatesDB[key])
            UIDropDownMenu_SetText(dd, "Select...")
            for _, item in ipairs(list) do
                if (item.path or item.value) == PrettyNameplatesDB[key] then
                    UIDropDownMenu_SetText(dd, item.name)
                    break
                end
            end
        end)
    end

    -- TAB 1
    local t1 = CreateFrame("Frame", nil, content)
    t1:SetAllPoints()
    tabs[1] = t1
    AddCheck(t1, L.ShowCastbar, "showCastbar", 20, -20)
    AddCheck(t1, L.ShowAuras, "showAuras", 20, -55)
    AddCheck(t1, L.ShowHpVal, "showHpVal", 20, -90)
    local mm = CreateFrame("CheckButton", nil, t1, "InterfaceOptionsCheckButtonTemplate")
    mm:SetPoint("TOPLEFT", 20, -125)
    local mmt = t1:CreateFontString(nil, "OVERLAY")
    ForceText(mmt)
    mmt:SetPoint("LEFT", mm, "RIGHT", 5, 1)
    mmt:SetText(L.ShowMinimap)
    mm:SetScript("OnClick", function(s)
        if type(PrettyNameplatesDB.minimap) ~= "table" then PrettyNameplatesDB.minimap = { hide = false, pos = 45 } end
        PrettyNameplatesDB.minimap.hide = not s:GetChecked()
        if ns.UpdateMinimapButton then ns:UpdateMinimapButton() end
    end)
    mm:SetScript("OnShow", function(s)
        if type(PrettyNameplatesDB.minimap) ~= "table" then PrettyNameplatesDB.minimap = { hide = false, pos = 45 } end
        s:SetChecked(not PrettyNameplatesDB.minimap.hide)
    end)

    -- TAB 2
    local t2 = CreateFrame("Frame", nil, content)
    t2:SetAllPoints()
    t2:Hide()
    tabs[2] = t2
    AddSlide(t2, L.Width, "width", 50, 250, 20, -20, false)
    AddSlide(t2, L.HpHeight, "hpHeight", 5, 50, 240, -20, false)
    AddSlide(t2, L.CastHeight, "castHeight", 5, 50, 20, -60, false)
    AddSlide(t2, L.Scale, "scale", 0.5, 2.5, 240, -60, true)
    AddDropdown(t2, L.Texture, "texture", ns.Textures, 0, -110)
    AddColor(t2, L.HpColor, "hpColor", 20, -160)
    AddColor(t2, L.HpBgColor, "hpBgColor", 240, -160)
    AddColor(t2, L.CastColor, "castColor", 20, -200)
    local hpBgAlphaSlider = CreateFrame("Slider", "PnpGuiSldhpBgAlpha", t2, "OptionsSliderTemplate")
    hpBgAlphaSlider:SetPoint("TOPLEFT", 240, -200)
    hpBgAlphaSlider:SetMinMaxValues(0, 100)
    hpBgAlphaSlider:SetWidth(180)
    hpBgAlphaSlider:SetValueStep(1)
    _G[hpBgAlphaSlider:GetName() .. "Text"]:SetText(L.HpBgAlpha)
    _G[hpBgAlphaSlider:GetName() .. "Low"]:SetText("0")
    _G[hpBgAlphaSlider:GetName() .. "High"]:SetText("100")
    hpBgAlphaSlider:SetValue(PrettyNameplatesDB.hpBgAlpha or 80)
    _G[hpBgAlphaSlider:GetName() .. "Text"]:SetText(L.HpBgAlpha .. ": " .. (PrettyNameplatesDB.hpBgAlpha or 80) .. "%")
    hpBgAlphaSlider:SetScript("OnValueChanged", function(self, v)
        v = math.floor(v)
        PrettyNameplatesDB.hpBgAlpha = v
        UpdateAll()
        ns.UpdatePreview()
        _G[self:GetName() .. "Text"]:SetText(L.HpBgAlpha .. ": " .. v .. "%")
    end)
    hpBgAlphaSlider:SetScript("OnShow", function(self)
        local v = PrettyNameplatesDB.hpBgAlpha or 80
        self:SetValue(v)
        _G[self:GetName() .. "Text"]:SetText(L.HpBgAlpha .. ": " .. v .. "%")
    end)
    AddCheck(t2, L.TankMode, "tankMode", 20, -240)
    AddCheck(t2, L.ColorNeutral, "colorNeutral", 240, -240)
    AddSlide(t2, L.NonTargetAlpha, "nonTargetAlpha", 0.2, 1, 20, -280, true)

    -- TAB 3
    local t3 = CreateFrame("Frame", nil, content)
    t3:SetAllPoints()
    t3:Hide()
    tabs[3] = t3
    AddDropdown(t3, L.Font, "font", ns.Fonts, 0, -20)
    AddDropdown(t3, L.FontOutline, "fontOutline", ns.Outlines, 220, -20)
    AddSlide(t3, L.FontSize, "fontSize", 8, 24, 20, -80, false)
    AddCheck(t3, L.ShowHpVal, "showHpVal", 20, -120)
    AddCheck(t3, L.ShowHpPerc, "showHpPerc", 240, -120)

    -- TAB 4
    local t4 = CreateFrame("Frame", nil, content)
    t4:SetAllPoints()
    t4:Hide()
    tabs[4] = t4
    AddSlide(t4, L.AuraSize, "auraSize", 10, 40, 20, -20, false)
    AddCheck(t4, L.ZoomIcons, "zoomIcons", 240, -25)
    AddCheck(t4, L.CompactTotems, "compactTotems", 20, -60)
    AddCheck(t4, L.ShowPets, "showPets", 240, -60)
    AddCheck(t4, L.ShowImportant, "showImportant", 20, -95)
    AddSlide(t4, L.ImportantSize, "importantSize", 12, 50, 240, -95, false)
    AddCheck(t4, L.ShowMyDebuffsOnly, "showMyDebuffsOnly", 20, -130)

    local cpT = t4:CreateFontString(nil, "OVERLAY")
    ForceText(cpT)
    cpT:SetPoint("TOPLEFT", 20, -160)
    cpT:SetText(L.CPHeader)
    AddSlide(t4, L.CPSize, "cpSize", 4, 20, 20, -190, false)
    AddSlide(t4, L.CPX, "cpX", -50, 50, 240, -190, false)
    AddSlide(t4, L.CPY, "cpY", -20, 20, 20, -230, false)

    ns.UpdatePreview()
end

-- LAUNCHER
local function CreateLauncher()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel.name = "Pretty Nameplates"
    InterfaceOptions_AddCategory(panel)
    local t = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    t:SetPoint("TOPLEFT", 16, -16)
    t:SetText("Pretty Nameplates v1.3.1")
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(200, 30)
    btn:SetPoint("CENTER")
    btn:SetText("Open Settings (Открыть настройки)")
    btn:SetScript("OnClick", function()
        InterfaceOptionsFrame:Hide()
        ns:ToggleGUI()
    end)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function() CreateLauncher() end)
