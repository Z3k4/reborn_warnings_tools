
local PANEL = {}
PANEL.clicking = false
PANEL.percent = 0
PANEL.lastClick = CurTime()
PANEL.numberClick = 0

function PANEL:Init()
    self:SetText("")
    

end

function PANEL:SetNewPunish(boolean)
    self.newPunish = boolean
end

function PANEL:IsNewPunish()
    return self.newPunish
end

function PANEL:SetPunishDetails(details) 
    self.PunishDetails = details
end

function PANEL:Paint(w,h)
    surface.SetDrawColor(30,30,30)
    surface.DrawRect(0,0,w,h)


    surface.SetDrawColor(100,0,0)
    surface.DrawRect(0,0,(self.percent/100) * w,h) 


    draw.SimpleText(self.PunishDetails.title, "APS_Roboto_Small", w* 0.5 + 2, h * 0.5 + 2, Color(20,20,20,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.PunishDetails.title, "APS_Roboto_Small", w * 0.5, h * 0.5, Color(200,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


    surface.SetDrawColor(255,255,255, 20)
    surface.DrawOutlinedRect(0, 0, w, h)

    if self.clicking && CurTime() then
        self.percent = math.Clamp(self.percent + 0.4, 0, 100)
    end

    if CurTime() > self.lastClick then
        self.lastClick = math.Clamp(self.lastClick - 1, 0, 2)
    end
end

function PANEL:OnMousePressed(code)
    
    if code == MOUSE_LEFT then
        if CurTime() < self.lastClick then 
            self.numberClick = self.numberClick + 1
            if self.numberClick > 0 then
                local item = self:GetParent():Add("aps_punishdetails")
                item:SetTall(self:GetParent():GetTall())
                item:SetPunish(self.PunishDetails)
            
            end
        else
            self.clicking = true
            self.percent = 0
        end

        self.lastClick = CurTime() + 0.5
    end

end

function PANEL:OnMouseReleased(code)
    self:MouseCapture( false )
    self.clicking = false
    
    --Request for deleting punish
    if self.percent >= 100 then 
        net.Start("APS_DropPunishment")
        net.WriteString(self.PunishDetails.uuid)
        net.SendToServer()

        self:Remove()
    end
    self.percent = 0
end

derma.DefineControl("aps_punishTitleBtn", "Panel will show all players", PANEL, "DButton") 