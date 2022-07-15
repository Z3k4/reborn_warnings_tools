local PANEL = {}
PANEL.IsNew = false

function PANEL:Init()
    
    self:SetSize(self:GetParent():GetSize())
    --self:SetTall(300)
end

function PANEL:SetPunish(punish)
    
    self:SetTall(self:GetParent():GetParent():GetTall())
    --PrintTable(punish)
    self.punishTitle = punish.title
    self.uuid = punish.uuid

    if punish.data then
        self.registeredPunish = util.JSONToTable(punish.data)
    else
        self.registeredPunish = {}
        self.IsNew = true
    end

    self.punishInfoPanel = self:Add("DButton")
    self.punishInfoPanel:SetText("")
    self.punishInfoPanel:SetTall(64)
    self.punishInfoPanel:Dock(TOP)

    self.returnBtn = self.punishInfoPanel:Add("DButton")
    self.returnBtn:SetSize(34,56)
    self.returnBtn:SetPos(4,4)
    self.returnBtn:SetText("")


    self.returnBtn.DoClick = function(slf)
        self:Remove()
    end
    
    self.punishInfoPanel.DoClick = function(slf)
        local punishTitle = vgui.Create("DRePopup")
        punishTitle:SetTitle("Titre infraction")
        punishTitle.OnRemove = function(slf)
            local comment = slf:GetCValue()
            if string.len(comment) > 0 then
                self.punishTitle = comment
            end
        end

    end

    self:PrintAddSaveButtons()

    self.PunishPlayerList = self:Add("DScrollPanel")
    self.PunishPlayerList:Dock(FILL)
    self.PunishPlayerList:DockMargin(0,3,0,0)
    

    self.punishInfoPanel.Paint = function (slf, w,h)
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0, w, h)

        surface.SetDrawColor(255,255,255,20)
        surface.DrawOutlinedRect(0,0,w,h)

        draw.SimpleText(self.punishTitle, "APS_Arial_Small", w * 0.5, 16, Color(255,255,255,255), TEXT_ALIGN_CENTER)
        draw.SimpleText("UUID: "..punish.uuid, "APS_Roboto_Small", w * 0.5, 32, Color(200,200,200,255), TEXT_ALIGN_CENTER)
    end

    function self.returnBtn:Paint(w,h)
        surface.SetDrawColor(255,255,255,20)
        --surface.DrawOutlinedRect(0,0,w,h)
        draw.SimpleText("<", "APS_ReturnBtn",  w * 0.5, h *0.5, Color(60,60,60,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end

    
    for index, pData in ipairs(self.registeredPunish) do
        self:PrintPunishment(index, pData)
    end

end

function PANEL:GetPunishItems()
    local punishUpdated = {}
    for k, v in ipairs(self.PunishPlayerList:GetChildren()[1]:GetChildren()) do
        for index, punishValues in ipairs(v:GetChildren()) do
            
            table.insert(punishUpdated, punishValues:GetData())
            --PrintTable(punishValues:GetData())
            --self.registeredPunish[k] = punishValues:GetData()
        end
    end

    return punishUpdated
end

function PANEL:PrintAddSaveButtons()

    local container = self:Add("DPanel")
    container:Dock(TOP)
    container:SetTall(64)


    local add = container:Add("DButton")
    add:Dock(TOP)
    add:SetTall(32)
    add:SetText("+")

    local percent = 0
    local clicking = false

    local save = container:Add("DButton")
    save:Dock(TOP)
    save:SetTall(32)
    save:SetText("Sauvegarder")

    function add:Paint(w,h)
        surface.SetDrawColor(30,30,30,255)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(100,0,0)
        

        surface.SetDrawColor(255,255,255, 20)
        surface.DrawOutlinedRect(0,0,w,h)

        
    end

    function save:Paint(w,h)
        surface.SetDrawColor(30,30,30,255)
        surface.DrawRect(0,0,w,h)

       

        surface.SetDrawColor(255,255,255, 20)
        surface.DrawOutlinedRect(0,0,w,h)

        surface.SetDrawColor(0,120,0,255)
        surface.DrawRect(0,0,(percent/100) * w,h) 

        if clicking then
            percent = math.Clamp(percent + 0.4, 0, 100)
        end
    end

    function save:OnMousePressed(code)
        clicking = true
        percent = 0
    end

    save.OnMouseReleased = function(slf, code)
        slf:MouseCapture( false )
        clicking = false
        
        if percent >= 100 then
            --PrintTable(self.registeredPunish)
            local punishToUpdate = {}
            punishToUpdate.uuid =self.uuid
            punishToUpdate.title = self.punishTitle
            punishToUpdate.data = self:GetPunishItems()

            
            
            --TODO : Sauvegarder

            if !self.IsNew then
                net.Start("APS_UpdatePunishment")
                net.WriteTable(punishToUpdate)
                net.SendToServer()
            else
                net.Start("APS_CreatePunishment")
                net.WriteTable(punishToUpdate)
                net.SendToServer()

            end
            --punish:Remove()
        end
        percent = 0
    end

    

    add.DoClick = function(slf )
        local count = table.Count(self.registeredPunish)
        table.insert(self.registeredPunish, count , {
            ptype = 'Kick',
            value = "",
            treshshold = 1
        })
        self:PrintPunishment(count, self.registeredPunish[count])

    end
end

function PANEL:PrintPunishment(index, data)

    local punish = self.PunishPlayerList:Add("DButton")
    punish:Dock(TOP)
    punish:DockMargin(0,0,0,2)
    punish:SetTall(64)
    punish:SetText("")

    local embedData = punish:Add("aps_punish_item")
    embedData:SetWide(self:GetWide())
    embedData:Dock(FILL)
    embedData:DockMargin(10,20,0,20)
    embedData:SetTall(64)
    embedData:SetIndex(index)

    embedData:SetData(data.ptype, data.value, data.treshshold)
  

    local percent = 0
    local clicking = false

    function punish:Paint(w,h)
        surface.SetDrawColor(30,30,30,255)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(100,0,0)
        surface.DrawRect(0,0,(percent/100) * w,h) 

        surface.SetDrawColor(255, 255,255,20)
        surface.DrawOutlinedRect(0,0,w,h)

        if clicking then
            percent = math.Clamp(percent + 0.4, 0, 100)
        end

    end

    if RebornAPS:HasAccess(LocalPlayer(), "rebornaps removeuserpunishment") then

        function punish:OnMousePressed(code)
            clicking = true
            percent = 0
        end

        punish.OnMouseReleased = function (slf, code)
            self:MouseCapture( false )
            clicking = false
            
            if percent >= 100 then 
                /*net.Start("APS_RemovePlayerPunishment")
                net.WriteString(userSteamID)
                net.WriteString(data.id)
                net.SendToServer()*/
                table.remove(self.registeredPunish, index)
                punish:Remove()
            end
            percent = 0
        end
    end


end


function PANEL:Paint(w, h)
    surface.SetDrawColor(30,30,30,255)

    surface.DrawRect(0,0,w,h)
end


derma.DefineControl("aps_punishdetails", "Panel will show all players", PANEL, "DPanel") 