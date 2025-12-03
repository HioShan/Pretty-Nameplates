local addonName, ns = ...


function ns:CreateAuras(myPlate)
    myPlate.auras = {}
    for i = 1, 8 do
        local frame = CreateFrame("Frame", nil, myPlate)
        frame:SetSize(16, 16)

        local icon = frame:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        local cd = frame:CreateFontString(nil, "OVERLAY")
        cd:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        cd:SetPoint("CENTER", 0, 0)
        cd:SetTextColor(1, 1, 0)

        local border = frame:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
        border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        border:SetAllPoints()

        local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetReverse(true)
        cooldown:Hide()

        frame.icon = icon
        frame.cd = cd
        frame.border = border
        frame.cooldown = cooldown

        frame:SetScript("OnUpdate", function(self, elapsed)
            if self.expirationTime and self.expirationTime > 0 then
                local timeLeft = self.expirationTime - GetTime()
                if timeLeft > 0 then
                    if timeLeft > 60 then
                        self.cd:SetText(string.format("%dm", math.ceil(timeLeft / 60)))
                    else
                        self.cd:SetText(string.format("%d", math.ceil(timeLeft)))
                    end
                else
                    self.cd:SetText("")
                end
            else
                self.cd:SetText("")
            end
        end)

        frame:Hide()
        myPlate.auras[i] = frame
    end

    myPlate.important = {}
    for i = 1, 3 do
        local frame = CreateFrame("Frame", nil, myPlate)
        frame:SetSize(22, 22)

        local icon = frame:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        local cd = frame:CreateFontString(nil, "OVERLAY")
        cd:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        cd:SetPoint("CENTER", 0, 0)
        cd:SetTextColor(1, 1, 1)

        local bd = CreateFrame("Frame", nil, frame)
        bd:SetPoint("TOPLEFT", -1, 1)
        bd:SetPoint("BOTTOMRIGHT", 1, -1)
        bd:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        bd:SetBackdropBorderColor(1, 0, 0, 1)

        local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetReverse(true)
        cooldown:Hide()

        frame.icon = icon
        frame.cd = cd
        frame.cooldown = cooldown

        frame:SetScript("OnUpdate", function(self, elapsed)
            if self.expirationTime and self.expirationTime > 0 then
                local timeLeft = self.expirationTime - GetTime()
                if timeLeft > 0 then
                    if timeLeft > 60 then
                        self.cd:SetText(string.format("%dm", math.ceil(timeLeft / 60)))
                    else
                        self.cd:SetText(string.format("%d", math.ceil(timeLeft)))
                    end
                else
                    self.cd:SetText("")
                end
            else
                self.cd:SetText("")
            end
        end)

        frame:Hide()
        myPlate.important[i] = frame
    end
end

function ns:UpdateAuras(myPlate)
    local db = PrettyNameplatesDB or ns.defaults

    -- Hide all existing auras first
    if myPlate.auras then
        for _, frame in pairs(myPlate.auras) do
            frame:Hide()
            frame.expirationTime = nil
        end
    end
    if myPlate.important then
        for _, frame in pairs(myPlate.important) do
            frame:Hide()
            frame.expirationTime = nil
        end
    end

    -- Simple check to see if this nameplate belongs to the target
    if not myPlate.nameText then return end

    local plateName = myPlate.nameText:GetText()
    local targetName = UnitName("target")

    if not plateName or not targetName or plateName ~= targetName then
        return
    end

    local unit = "target"
    local i = 1
    local auraIndex = 1
    local impIndex = 1

    while true do
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, _, _, spellId = UnitDebuff(unit,
            i)
        if not name then break end

        local show = true
        if db.showMyDebuffsOnly then
            local isMine = (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle")
            if not isMine then
                show = false
            end
        end

        if show then
            -- Check for Important Buffs (if the table exists)
            if ns.ImportantBuffs and ns.ImportantBuffs[spellId] then
                if myPlate.important and myPlate.important[impIndex] then
                    local frame = myPlate.important[impIndex]
                    frame:Show()
                    frame.icon:SetTexture(icon)
                    frame.expirationTime = expirationTime

                    if duration and duration > 0 then
                        frame.cooldown:Show()
                        frame.cooldown:SetCooldown(expirationTime - duration, duration)
                    else
                        frame.cooldown:Hide()
                    end

                    impIndex = impIndex + 1
                end
            else
                -- Normal Auras
                if myPlate.auras and myPlate.auras[auraIndex] and auraIndex <= 8 then
                    local frame = myPlate.auras[auraIndex]
                    frame:Show()
                    frame.icon:SetTexture(icon)
                    frame.expirationTime = expirationTime

                    if duration and duration > 0 then
                        frame.cooldown:Show()
                        frame.cooldown:SetCooldown(expirationTime - duration, duration)
                    else
                        frame.cooldown:Hide()
                    end

                    auraIndex = auraIndex + 1
                end
            end
        end

        i = i + 1
    end
end
