local PANEL = {}
PANEL.Value = ""

function PANEL:Init()
    self:SetSize(200,60)
    self:Center()
    self:ShowCloseButton(false)
    self:MakePopup()
    self:SetTitle("Commentaire")
    
    self.closeBtn = self:Add("DButton")
    self.closeBtn:SetText("")
    self.closeBtn:SetIcon("icon16/cross.png")
    self.closeBtn:SetSize(20,16)
    self.closeBtn:SetPos(self:GetWide() - 25, 4)
    self.closeBtn.DoClick = function()
        self:Remove()
    end

    self.popupValue = self:Add("DTextEntry")
    self.popupValue:SetSize(self:GetWide() - 20, 20)
    self.popupValue:SetPos(10,30)
    self.popupValue:RequestFocus()
    self.popupValue.OnChange = function()
        self.Value = self.popupValue:GetValue()
    end
    self.popupValue.OnKeyCodePressed = function()

        self:Remove()
    end

    function self.closeBtn:Paint() end

end

function PANEL:GetCValue()
    return self.Value
end


function PANEL:Paint(w,h)
    
    surface.SetDrawColor(30,30,30)
    surface.DrawRect(0,0,w,h)

    surface.SetDrawColor(255,255,255)
    surface.DrawOutlinedRect(0,0,w,h)
end


derma.DefineControl("DRePopup", "Panel will show all players", PANEL, "DFrame")