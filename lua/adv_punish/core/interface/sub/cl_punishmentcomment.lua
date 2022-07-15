local PANEL = {}


function PANEL:Init()
    self.DCommentaryEntry = self:Add("DTextEntry")
    
    self.DCommentaryEntry:AllowInput(false)
    self.DCommentaryEntry:SetMultiline(true)
    self.DCommentaryEntry:SetTall(50)
    self.DCommentaryEntry:Dock(BOTTOM)
end

function PANEL:SetTitle()

end

function PANEL:SetAdmin()

end


function PANEL:SetCommentary(txt)
    self.DCommentaryEntry:SetText(txt)
end

function PANEL:SetDate()

end

derma.DefineControl("aps_punishmentcomment", "Panel will show all players", PANEL, "DPanel") 