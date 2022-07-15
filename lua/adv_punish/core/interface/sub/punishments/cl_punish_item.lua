local PANEL = {}
PANEL.PunishType = nil
PANEL.PunishValue = nil
PANEL.Treshshold = 1


local banTypeMinutes = {}
banTypeMinutes["Minutes"] = 1
banTypeMinutes["Heures"] = 60
banTypeMinutes["Jours"] = 1440
--banTypeMinutes["Semaines"] = 10080
--banTypeMinutes["Mois"] = 40320

function PANEL:SelectPunishType(pType)
    self.PunishType = pType
    self.dContainerType:Clear()
    self.wantedValue = nil

    local timeType

    if (pType == "Warn" || pType == "Slay") then
    elseif (pType == "Ban" || pType == "Gag" || pType == "Mute") then
        local valueLabel = self.dContainerType:Add("DLabel")
        valueLabel:SetText("Temps")
        valueLabel:Dock(LEFT)
        valueLabel:DockMargin(10, 0,0,0)

        timeType = self.dContainerType:Add("DComboBox")
        timeType:Dock(LEFT)
        timeType:SetSortItems(false)
        timeType:AddChoice("Minutes")
        timeType:AddChoice("Heures")
        timeType:AddChoice("Jours")
        --timeType:AddChoice("Semaines")
        --timeType:AddChoice("Mois") 
        timeType:SetValue("Minutes")

        self.wantedValue = self.dContainerType:Add("DNumberWang")
        self.wantedValue:Dock(LEFT)
        self.wantedValue:DockMargin(5, 0,0,0)

    elseif (pType == "Custom command") then
        local valueLabel = self.dContainerType:Add("DLabel")
        valueLabel:SetText("Commande")
        valueLabel:Dock(LEFT)
        valueLabel:DockMargin(10, 0,0,0)

        self.wantedValue = self.dContainerType:Add("DTextEntry")
        self.wantedValue:SetWide(self.dContainerType:GetParent():GetWide() * 0.2)
        self.wantedValue:Dock(LEFT)

        local argsLabel = self.dContainerType:Add("DLabel")
        argsLabel:Dock(LEFT)
        argsLabel:DockMargin(5,0,0,0)
        argsLabel:SetWide(self:GetWide())
        argsLabel:SetText("Paramètres : {steamid64}, {name}")
    end

    if pType != "Slay" && pType != "Warn" && pType != "Kick" then

            --Check if it's transmitted data
        if self.PunishValue != nil && string.len(self.PunishValue) > 0 then
            --Fix ban printing
            if self.PunishType == "Ban" then
                --To count where we are
                local index = 0
                local maxValue = 0
                for bantype,minutes in pairs(banTypeMinutes) do
        
                    if bantype == "Minutes" then
                        maxValue = 60  -- 60 minutes
                    elseif bantype == "Heures" then
                        maxValue = 24 * 60  -- 24 hours
                    elseif bantype == "Jours" then
                        maxValue = 90 * 1440 -- 90 day
                    end

                    if self.PunishValue <  maxValue  && (self.PunishValue % minutes) == 0  then
                        timeType:SetValue(bantype)
                        self.wantedValue:SetValue(self.PunishValue / minutes)
                        break
                    end

                    index = index + 1
                end 
            else
                
                self.wantedValue:SetValue(self.PunishValue)
            end
        end
        --For text entry
        self.wantedValue.OnChange = function ()
            self.PunishValue = self.wantedValue:GetValue()
        end

        --For the rest
        self.wantedValue.OnValueChanged = function (_, value)
            if pType == "Ban" then

                self.PunishValue = banTypeMinutes[timeType:GetValue()] * value
                chat.AddText("Ban pour ".. self.PunishValue.. " minutes")
                
            else
                self.PunishValue = value
            end
        end
    end

end

function PANEL:Init()

    self.infoTypeLabel = self:Add("DButton")
    self.infoTypeLabel:Dock(LEFT)
    self.infoTypeLabel:DockMargin(10,0,0,0)
    self.infoTypeLabel:SetWide(125)
    self.infoTypeLabel:SetText("")

    self.dPunishType = self:Add("DComboBox")
    self.dPunishType:SetWide(125)
    self.dPunishType:Dock(LEFT)
    self.dPunishType:DockMargin(10,0,0,0)
    self.dPunishType:AddChoice("Mute")
    self.dPunishType:AddChoice("Gag")
    self.dPunishType:AddChoice("Slay")
    self.dPunishType:AddChoice("Warn")
    self.dPunishType:AddChoice("Ban")
    self.dPunishType:AddChoice("Kick")
    self.dPunishType:AddChoice("Custom command")

    self.dPunishType.OnSelect = function(slf, index, value,data)
        self:SelectPunishType(value)
        self.dPunishType:Hide()
        self.infoTypeLabel:Show()

    end

    self.infoTypeLabel.DoClick = function(slf)
        slf:Hide()
        self.dPunishType:Show()
        
        self.dPunishType:RequestFocus()
        
    end

    self.dPunishType:Hide()

    
    self.dContainerType = self:Add("DPanel")
    self.dContainerType:Dock(FILL)

    self.infoTypeLabel.Paint = function (slf, w, h)
        draw.SimpleText(self.dPunishType:GetValue(), "APS_Arial_Small", 12, h * 0.5 + 2, Color(20,20,20,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.dPunishType:GetValue(), "APS_Arial_Small", 10, h* 0.5, Color(255,120,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    

    function self.dContainerType:Paint()

    end
end

function PANEL:SetIndex(index)
    self.itemIndex = index
end

function PANEL:SetData(ptype, value, treshshold)
    --self.PunishIndex = index
    self.PunishType = ptype
    self.PunishValue = value
    self.Treshshold = treshshold

    

    local allowNumberLabel = self:Add("DLabel")
    allowNumberLabel:SetText("Seuil")
    allowNumberLabel:SetPos(self:GetWide() - 160, 4)
    allowNumberLabel.OnValueChange = function(slf, value)
        self.Treshshold = value
    end

    self.allowNumberValue = self:Add("DNumberWang")
    self.allowNumberValue:SetPos(self:GetWide() - 130, 4)
    self.allowNumberValue:SetMin(1)
    self.allowNumberValue:SetValue(1)
    self.allowNumberValue.OnValueChanged = function(slf)
        
        if slf:GetValue() < slf:GetMin() then
            slf:SetText(slf:GetMin())
        end
        self.Treshshold = slf:GetValue()
    end

    self.allowNumberValue:SetValue(self.Treshshold)
    self.dPunishType:SetValue(self.PunishType)
    self:SelectPunishType(self.PunishType)

    
    

end

function PANEL:GetData()
    local data = {}
    data.ptype = self.PunishType
    data.value = self.PunishValue
    data.treshshold = self.Treshshold

    return data
end

function PANEL:Paint(w, h)
    draw.DrawText(self.itemIndex + 1, "APS_Arial_Small", 0,5, Color(255,255,255,255))
    --surface.SetDrawColor(255,255,255,30)
    --surface.DrawOutlinedRect(0,0, w,h)
end

derma.DefineControl("aps_punish_item", "Panel will show all players", PANEL, "DPanel") 