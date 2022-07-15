local PANEL = {}


function PANEL:LoadPunishments()
    self:Clear()
    --Store available punishments
    local allPData

    local newBtn = self:Add("DButton")
    newBtn:Dock(TOP)
    newBtn:DockMargin(0,0,0,2)
    newBtn:SetText("+")
    newBtn.DoClick = function(slf)
        self:CreateNewPunish()
    end


    RebornAPS:RequestAvailablePunishments(function(result)
        if self then
            allPData = result
            if result then
                for k, pData in ipairs(result) do

                    local item = self:Add("aps_punishTitleBtn") 
                    item:Dock(TOP)
                    item:SetTall(48)
                    item:SetPunishDetails(pData)
                


                end
            end
        end
    end)

    function newBtn:Paint(w,h)
        surface.SetDrawColor(255,255,255,20)
        surface.DrawOutlinedRect(0,0,w,h)
    end

    
end

function PANEL:CreateNewPunish()
    local punish = {}
    punish.uuid = LibK.GetUUID()
    punish.title = "Undefined"
    punish.data = nil
 
    local item = self:Add("aps_punishTitleBtn") 
    item:Dock(TOP)
    item:SetTall(48)
    item:SetPunishDetails(punish)

    /*net.Start("APS_CreatePunishment")
    net.WriteTable(punish)
    net.SendToServer()*/

end

function PANEL:GetAllPunish()
    local allAvailablePunish = {}
    for index, itemCollapsed in ipairs(self:GetChild(0):GetChildren()) do
        allAvailablePunish[index] = itemCollapsed:GetAllPunishDetails()
    end

end


function PANEL:Init()
   
    self:SetWide(self:GetParent():GetWide())
    self:SetTall(self:GetParent():GetTall())

end



derma.DefineControl("aps_plist", "Panel will show all players", PANEL, "DScrollPanel") 
