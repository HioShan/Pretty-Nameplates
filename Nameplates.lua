local addonName, ns = ...
local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

local Blacklist = {
    ["Totem"] = "totem",
    ["Тотем"] = "totem",
    ["Ghoul"] = "pet",
    ["Вурдалак"] = "pet",
    ["Army"] = "pet",
    ["Войско"] = "pet",
    ["Gargoyle"] = "pet",
    ["Горгулья"] = "pet",
    ["Bloodworm"] = "pet",
    ["Червь"] = "pet",
    ["Imp"] = "pet",
    ["Бес"] = "pet",
    ["Voidwalker"] = "pet",
    ["Демон"] = "pet",
    ["Succubus"] = "pet",
    ["Суккуб"] = "pet",
    ["Felhunter"] = "pet",
    ["Охотник"] = "pet",
    ["Felguard"] = "pet",
    ["Страж"] = "pet",
    ["Infernal"] = "pet",
    ["Инфернал"] = "pet",
    ["Cat"] = "pet",
    ["Кошка"] = "pet",
    ["Boar"] = "pet",
    ["Вепрь"] = "pet",
    ["Wolf"] = "pet",
    ["Волк"] = "pet",
    ["Bear"] = "pet",
    ["Медведь"] = "pet",
    ["Snake"] = "pet",
    ["Змея"] = "pet",
    ["Viper"] = "pet",
    ["Гадюка"] = "pet",
    ["Elemental"] = "pet",
    ["Элементаль"] = "pet",
    ["Treant"] = "pet",
    ["Древень"] = "pet",
    ["Minion"] = "pet",
    ["Прислужник"] = "pet",
    ["Guardian"] = "pet",
    ["Страж"] = "pet",
    ["Pet"] = "pet",
    ["Питомец"] = "pet",
    ["Construct"] = "pet",
    ["Конструкция"] = "pet",
}

local function GetUnitType(name)
    if not name then return nil end
    for key, type in pairs(Blacklist) do if name:find(key) then return type end end
    return nil
end

local function GetThreatGlowRegion(frame)
    if frame.threatGlowRegion then return frame.threatGlowRegion end
    local regions = { frame:GetRegions() }
    for _, region in ipairs(regions) do
        if region:IsObjectType("Texture") then
            local texture = region:GetTexture()
            -- Поиск текстуры агро (стандартная текстура 3.3.5)
            if texture and (texture:find("Nameplate-Glow") or texture:find("UI-TargetingFrame-Flash")) then
                frame.threatGlowRegion = region
                return region
            end
        end
    end
    return nil
end

local function CreateComboPoints(myPlate)
    myPlate.cps = {}
    for i = 1, 5 do
        local cp = myPlate:CreateTexture(nil, "OVERLAY")
        cp:SetSize(6, 6)
        cp:SetTexture("Interface\\COMMON\\Indicator-Yellow")
        cp:Hide()
        myPlate.cps[i] = cp
    end
end

function ns:UpdatePlateStyle(myPlate)
    local db = PrettyNameplatesDB or ns.defaults

    myPlate.hp:SetWidth(db.width)
    myPlate.hp:SetHeight(db.hpHeight or 14)

    local tex = db.texture or "Interface\\Buttons\\WHITE8X8"
    myPlate.hp:SetStatusBarTexture(tex)

    local font = db.font or "Fonts\\FRIZQT__.TTF"
    local outline = db.fontOutline or "OUTLINE"
    local fSize = db.fontSize or 10

    myPlate.nameText:SetFont(font, fSize, outline)
    myPlate.hpText:SetFont(font, fSize - 2, outline)

    if db.showHpPerc then myPlate.hpText:Show() else myPlate.hpText:Hide() end

    myPlate.nameText:ClearAllPoints()
    myPlate.nameText:SetPoint("BOTTOMLEFT", myPlate.hp, "TOPLEFT", 0, 3)
    myPlate.nameText:SetPoint("RIGHT", myPlate.hpText, "LEFT", -5, 0)

    if myPlate.centerText then
        myPlate.centerText:SetFont(font, fSize - 2, outline)
        if db.showHpVal then myPlate.centerText:Show() else myPlate.centerText:Hide() end
    end

    local scale = db.scale or 1
    if scale < 0.1 then scale = 1 end
    myPlate:SetScale(scale)

    if myPlate.castbar then
        myPlate.castbar:SetWidth(db.width)
        myPlate.castbar:SetHeight(db.castHeight or 10)
        myPlate.castbar:SetStatusBarTexture(tex)
        myPlate.castbar:ClearAllPoints()
        myPlate.castbar:SetPoint("TOP", myPlate.hp, "BOTTOM", 0, -2)

        if myPlate.castbar.icon then
            local iconSize = (db.castHeight or 10) + 4
            myPlate.castbar.icon:SetSize(iconSize, iconSize)
            myPlate.castbar.icon:ClearAllPoints()
            myPlate.castbar.icon:SetPoint("RIGHT", myPlate.castbar, "LEFT", -4, 0)
            if myPlate.castbar.iconBg then myPlate.castbar.iconBg:SetSize(iconSize + 2, iconSize + 2) end

            -- ZOOM
            if db.zoomIcons then
                myPlate.castbar.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            else
                myPlate.castbar.icon:SetTexCoord(0, 1, 0, 1)
            end
        end
    end

    local cpOffset = -((db.castHeight or 10) + 2)
    local cpx = db.cpX or 0; local cpy = db.cpY or 0; local cpSize = db.cpSize or 6
    if myPlate.cps then
        for i = 1, 5 do
            myPlate.cps[i]:ClearAllPoints()
            myPlate.cps[i]:SetSize(cpSize, cpSize)
            if i == 1 then
                myPlate.cps[i]:SetPoint("TOPLEFT", myPlate.hp, "BOTTOMLEFT", cpx, cpOffset + cpy)
            else
                myPlate.cps[i]:SetPoint("LEFT", myPlate.cps[i - 1], "RIGHT", 2, 0)
            end
        end
    end

    if myPlate.auras then
        local size = db.auraSize or 16
        local bottomOffset = fSize + 6
        for i, frame in ipairs(myPlate.auras) do
            frame:SetSize(size, size)
            frame:ClearAllPoints()
            if i == 1 then
                frame:SetPoint("BOTTOMLEFT", myPlate.hp, "TOPLEFT", 0, bottomOffset)
            else
                frame:SetPoint("LEFT", myPlate.auras[i - 1], "RIGHT", 1, 0)
            end
            frame.cd:SetFont(font, math.max(8, size / 1.5), "OUTLINE")

            -- ZOOM
            if db.zoomIcons then
                frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            else
                frame.icon:SetTexCoord(0, 1, 0, 1)
            end
        end
    end

    if myPlate.important then
        local impSize = db.importantSize or 24
        for i, frame in ipairs(myPlate.important) do
            frame:SetSize(impSize, impSize)
            frame:ClearAllPoints()
            if i == 1 then
                frame:SetPoint("LEFT", myPlate.hp, "RIGHT", 6, 0)
            else
                frame:SetPoint("LEFT", myPlate.important[i - 1], "RIGHT", 4, 0)
            end

            -- ZOOM
            if db.zoomIcons then
                frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            else
                frame.icon:SetTexCoord(0, 1, 0, 1)
            end

            if not db.showImportant then frame:Hide() end
        end
    end
end

function ns:CreatePlateFrame(parentFrame)
    local healthBar, castBar = parentFrame:GetChildren()
    healthBar:SetStatusBarTexture("")
    castBar:SetStatusBarTexture("")

    local myPlate = CreateFrame("Frame", nil, parentFrame)
    myPlate:SetAllPoints(parentFrame)
    myPlate:SetFrameLevel(parentFrame:GetFrameLevel())
    parentFrame.myPlate = myPlate

    local hp = CreateFrame("StatusBar", nil, myPlate)
    hp:SetPoint("CENTER", myPlate, "CENTER", 0, -3)

    local bg = hp:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(hp)
    bg:SetTexture(0, 0, 0, 0.8)

    local backdrop = CreateFrame("Frame", nil, hp)
    backdrop:SetPoint("TOPLEFT", -1, 1)
    backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
    backdrop:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    backdrop:SetBackdropBorderColor(0, 0, 0, 1)

    local highlight = hp:CreateTexture(nil, "OVERLAY")
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
    highlight:SetVertexColor(1, 1, 1, 0.3)
    highlight:Hide()
    myPlate.highlight = highlight

    local totemIcon = myPlate:CreateTexture(nil, "ARTWORK")
    totemIcon:SetSize(24, 24)
    totemIcon:SetPoint("CENTER", myPlate, "CENTER", 0, -10)
    totemIcon:Hide()
    myPlate.totemIcon = totemIcon

    local hpText = hp:CreateFontString(nil, "OVERLAY")
    hpText:SetPoint("BOTTOMRIGHT", hp, "TOPRIGHT", 0, 3)
    hpText:SetTextColor(0.8, 0.8, 0.8)
    hpText:SetJustifyH("RIGHT")

    local centerText = hp:CreateFontString(nil, "OVERLAY")
    centerText:SetPoint("CENTER", hp, "CENTER", 0, 0)
    centerText:SetTextColor(1, 1, 1)

    local nameText = hp:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("BOTTOMLEFT", hp, "TOPLEFT", 0, 3)
    nameText:SetPoint("RIGHT", hpText, "LEFT", -5, 0)
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("LEFT")

    myPlate.hp = hp
    myPlate.nameText = nameText
    myPlate.hpText = hpText
    myPlate.centerText = centerText
    myPlate.oldHealth = healthBar

    local myRaidIcon = myPlate:CreateTexture(nil, "OVERLAY")
    myRaidIcon:SetSize(22, 22)
    myRaidIcon:SetPoint("RIGHT", hp, "LEFT", -8, 0)
    myRaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    myRaidIcon:Hide()
    myPlate.raidIcon = myRaidIcon

    CreateComboPoints(myPlate)
    if ns.CreateCastbar then ns:CreateCastbar(myPlate) end
    if ns.CreateAuras then ns:CreateAuras(myPlate) end

    ns:UpdatePlateStyle(myPlate)

    myPlate:SetScript("OnUpdate", function(self, elapsed)
        local db = PrettyNameplatesDB or ns.defaults

        if UnitIsUnit("mouseover", "target") or (self.nameText:GetText() == UnitName("mouseover")) then
            self.highlight:Show()
        else
            self.highlight:Hide()
        end

        local regions = { parentFrame:GetRegions() }
        local hasAggro = false

        for _, region in pairs(regions) do
            if region and not region.pnp_ignore then
                local type = region:GetObjectType()
                if type == "Texture" then
                    local tex = region:GetTexture()
                    if tex and tex:find("RaidTargetingIcons") then
                        if region:IsShown() then
                            self.raidIcon:Show()
                            self.raidIcon:SetTexCoord(region:GetTexCoord())
                        else
                            self.raidIcon:Hide()
                        end
                        region:SetAlpha(0)
                    elseif tex and (tex:find("Glow") or tex:find("NamePlateGlow")) then
                        -- Hide default glow
                        region:SetAlpha(0)
                    else
                        region:SetTexture(nil)
                        region:SetAlpha(0)
                        if tex and (tex:find("Skull") or tex:find("Totem") or tex:find("Elite")) then region:Hide() end
                    end
                elseif type == "FontString" then
                    local text = region:GetText()
                    if text then
                        if tonumber(text) or text == "??" then
                            region:SetAlpha(0)
                        else
                            if text ~= self.nameText:GetText() then self.nameText:SetText(text) end
                            region:SetAlpha(0)
                        end
                    end
                end
            end
        end

        self.oldHealth:SetStatusBarTexture("")

        local name = self.nameText:GetText() or ""
        local unitType = GetUnitType(name)
        local shouldHide = false

        if unitType == "totem" then
            if db.compactTotems then
                self.hp:Hide()
                self.totemIcon:Show()
                self.totemIcon:SetTexture("Interface\\Icons\\Spell_Nature_StoneClawTotem")
            else
                self.hp:Show()
                self.totemIcon:Hide()
            end
        elseif unitType == "pet" and db.showPets == false then
            shouldHide = true
        else
            self.hp:Show()
            self.totemIcon:Hide()
        end

        if shouldHide then
            self.hp:Hide()
            self.totemIcon:Hide()
            self:SetScale(0.001)
            self:SetAlpha(0)
            return
        else
            self:SetScale(db.scale or 1)
        end

        local min, max = self.oldHealth:GetMinMaxValues()
        local curr = self.oldHealth:GetValue()
        self.hp:SetMinMaxValues(min, max)
        self.hp:SetValue(curr)

        local isTarget = (parentFrame:GetAlpha() == 1)
        local classColor = nil
        if name and ns.ClassCache[name] then classColor = RAID_CLASS_COLORS[ns.ClassCache[name]] end

        -- Aggro Logic Refactoring
        local glowRegion = GetThreatGlowRegion(parentFrame)
        local hasAggro = glowRegion and glowRegion:IsShown()

        if classColor then
            self.hp:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
        else
            local r, g, b = self.oldHealth:GetStatusBarColor()
            if db.tankMode then
                if hasAggro then
                    -- Tank Mode ON: Aggro = Green (OK)
                    self.hp:SetStatusBarColor(0, 1, 0)
                else
                    -- Tank Mode ON: No Aggro = Red (Warning)
                    self.hp:SetStatusBarColor(1, 0, 0)
                end
            else
                if hasAggro then
                    -- Tank Mode OFF: Aggro = Red (Danger)
                    self.hp:SetStatusBarColor(1, 0, 0)
                else
                    -- Tank Mode OFF: No Aggro = Standard Color
                    if r > 0.8 and g > 0.8 and b < 0.3 then
                        if db.colorNeutral then
                            self.hp:SetStatusBarColor(db.hpColor.r, db.hpColor.g, db.hpColor.b)
                        else
                            self.hp:SetStatusBarColor(r, g, b)
                        end
                    elseif r > 0.8 and g < 0.3 then
                        self.hp:SetStatusBarColor(db.hpColor.r, db.hpColor.g, db.hpColor.b)
                    else
                        self.hp:SetStatusBarColor(r, g, b)
                    end
                end
            end
        end

        if isTarget then self:SetAlpha(1) else self:SetAlpha(db.nonTargetAlpha) end

        if max and max > 0 then
            if db.showHpPerc then self.hpText:SetText(math.ceil((curr / max) * 100) .. "%") else self.hpText:SetText("") end
            if self.centerText:IsShown() then
                self.centerText:SetText(ns:FormatNumber(curr) .. " / " .. ns:FormatNumber(max))
            end
        else
            self.hpText:SetText("")
            self.centerText:SetText("")
        end

        if parentFrame:IsShown() then self:Show() else self:Hide() end

        if self.cps and UnitName("target") == name and isTarget then
            local points = GetComboPoints("player", "target")
            for i = 1, 5 do
                if i <= points then
                    self.cps[i]:Show()
                    self.cps[i]:SetTexture("Interface\\COMMON\\Indicator-Yellow")
                else
                    self.cps[i]:Hide()
                end
            end
        elseif self.cps then
            for i = 1, 5 do self.cps[i]:Hide() end
        end

        if ns.UpdateCastbar then ns:UpdateCastbar(self, parentFrame) end
        if ns.UpdateAuras then ns:UpdateAuras(self, parentFrame) end
    end)
end
