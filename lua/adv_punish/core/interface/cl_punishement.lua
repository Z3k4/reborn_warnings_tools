local PANEL = {}

function PANEL:Init()
    self:SetTall(self:GetParent():GetTall())
    if !RebornAPS:HasAccess(LocalPlayer(), "rebornaps viewpunishment") then return end

    self.PList = self:Add("aps_plist")
    self.PList:Dock(TOP)
    self.PList:SetTall(self:GetTall())
    self.PList:LoadPunishments()

    if RebornAPS:HasAccess(LocalPlayer(), "rebornaps editpunishment") then
        self.AddPunishBtn = self:Add("DButton")
        self.AddPunishBtn:SetText("+")
        self.AddPunishBtn:Dock(TOP)
        self.AddPunishBtn.DoClick = function()
            self.PList:CreateNewPunish()
        end
    


    self.SaveEditedValues = self:Add("DButton")
    self.SaveEditedValues:SetText("Save all changes")
    self.SaveEditedValues:Dock(TOP)
    self.SaveEditedValues.DoClick = function()
        self.PList:GetAllPunish()
    end

end



end

function PANEL:Paint(w,h)
 
end

derma.DefineControl("aps_allpunish", "Panel will show all players", PANEL, "DPanel")