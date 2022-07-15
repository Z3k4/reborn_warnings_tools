local PANEL = {}

PANEL.PrimaryColor = Color(255,255,255,0)
PANEL.SecondaryColor = Color(255,255,255,0)

PANEL.NowColor = PANEL.PrimaryColor

function PANEL:Init()
    self:SetSecondaryColor(Color(0,200,0,130))
end


function PANEL:SetPrimaryColor(color)
    self.PrimaryColor = color
end

function PANEL:SetSecondaryColor(color)
    self.SecondaryColor = color
end

function PANEL:OnCursorEntered()
    self.NowColor = self.SecondaryColor
end 

function PANEL:OnCursorExited()
    self.NowColor = self.PrimaryColor
end

function PANEL:Paint(w,h)
    surface.SetDrawColor(255,255,255,120)
    surface.DrawOutlinedRect(0,0,w,h)

    surface.SetDrawColor(self.NowColor)
    surface.DrawRect(1, 1, w-2, h-2)
end 

derma.DefineControl("DReButton", "Panel will show all players", PANEL, "DButton")