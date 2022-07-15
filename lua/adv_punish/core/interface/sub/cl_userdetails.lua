local PANEL = {}


local function isOnline(ply)
    for k,v in ipairs(player.GetAll()) do
        if v:SteamID64() == ply.steamid64 then
            return true
        end
    end

    return false
end

function PANEL:Init()
    
    
end

function PANEL:SetPlayer(ply)
    self.steamID = ply.steamid64
    self.steamName = ply.nick
    local firstConnection = os.date( "%d/%m/%Y", ply.date_registered)
    local lastConnection = os.date( "%A %d %B %Y - %X", ply.last_online) 
    local online = isOnline(ply) 

    self.userInfoPanel = self:Add("DPanel")
    self.userInfoPanel:SetTall(64)
    self.userInfoPanel:Dock(TOP)

    self:SetSize(self:GetParent():GetSize())

    self.returnBtn = self.userInfoPanel:Add("DButton")
    self.returnBtn:SetSize(34,56)
    self.returnBtn:SetText("")
    self.returnBtn:SetPos(4,4)
    

    self.ava = self.userInfoPanel:Add("AvatarImage")
    self.ava:SetSize(48,48)
    self.ava:SetPos(48,8)
    self.ava:SetSteamID(self.steamID, 128)


    self.PunishPlayerList = self:Add("DScrollPanel")
    self.PunishPlayerList:Dock(TOP)
    self.PunishPlayerList:DockMargin(0,3,0,0)
    self.PunishPlayerList:SetTall(self:GetTall() - 128)


    self.returnBtn.DoClick = function(slf)
        self:Remove()
    end

    function self.userInfoPanel:Paint(w,h)
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0, w, h)

        surface.SetDrawColor(255,255,255,20)
        surface.DrawOutlinedRect(0,0,w,h)

        draw.SimpleText(ply.nick, "APS_Arial_Small", 104, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT)
        draw.SimpleText(ply.steamid64, "APS_Roboto_Small", 104, 30, Color(200,200,200,255), TEXT_ALIGN_LEFT)

        draw.SimpleText(firstConnection, "APS_Arial_Small",  w - 10, 13, Color(200,200,200,255), TEXT_ALIGN_RIGHT)
        
        if online then
            draw.SimpleText("En ligne", "APS_Arial_Small",  w - 10, 33, Color(0,200,0,255), TEXT_ALIGN_RIGHT)
        else
            draw.SimpleText(lastConnection, "APS_Arial_Small",  w - 10, 33, Color(200,0,0,255), TEXT_ALIGN_RIGHT)
        end
    end

    function self.returnBtn:Paint(w,h)
        surface.SetDrawColor(255,255,255,20)
        --surface.DrawOutlinedRect(0,0,w,h)
        draw.SimpleText("<", "APS_ReturnBtn",  w * 0.5, h *0.5, Color(60,60,60,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end


    self:AddPunishments()
end

function PANEL:PrintAddButton()
    local playerName = self.steamName
    local playerSteamID = self.steamID
    local add = self.PunishPlayerList:Add("DButton")
    add:Dock(TOP)
    add:SetTall(64)
    add:SetText("+")

    function add:Paint(w,h)
        surface.SetDrawColor(30,30,30,255)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(255,255,255, 20)
        surface.DrawOutlinedRect(0,0,w,h)
    end

    local pnl = self
    add.DoClick = function()
        local menu = DermaMenu()
        RebornAPS:RequestAvailablePunishments(function(result)
            for _, punish in ipairs(result) do
                menu:AddOption(punish.title, function()
                    local commentary = vgui.Create("DRePopup")

                    commentary.OnRemove = function(self)
                        local comment = self:GetCValue()
                        if(string.len(comment) >= 1) then
                            chat.AddText("Enregistrement de l'infraction de "..playerName)
                            net.Start("APS_AddPunishmentToPlayer")
                            net.WriteString(playerSteamID)
                            net.WriteString(punish.uuid)
                            net.WriteString(comment)
                            net.SendToServer()


                            pnl:AddPunishments()
                        end
                    end

                    
                end)
            end 
        end)
        menu:Open()
    end
end

function PANEL:PrintPunishment(data)
    
    local steamID32 = util.SteamIDFrom64(data.adminsteamid)
    local punish = self.PunishPlayerList:Add("DButton")
    punish:SetText("")
    punish:Dock(TOP)
    punish:DockMargin(0,0,0,2)
    punish:SetTall(64)

    local adminAvatar = punish:Add("AvatarImage")
    adminAvatar:SetSize(48,48)
    adminAvatar:SetPos(8,8)
    adminAvatar:SetSteamID(data.adminsteamid, 64)

    local statusIcon = punish:Add("DButton")
    statusIcon:SetText("")
    statusIcon:SetPos(self:GetWide() - 48, 24)
    statusIcon:SetSize(20,16)
    if data.applied == 0 then
        statusIcon:SetIcon("icon16/status_away.png")
        statusIcon:SetToolTip("La sanction correspondante n'a pas encore été appliquée")
    else
        statusIcon:SetIcon("icon16/tick.png")
        statusIcon:SetToolTip("La sanction correspondante a été appliquée")
    end

    local percent = 0
    local clicking = false

    function punish:Paint(w,h)
        surface.SetDrawColor(30,30,30,255)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(100,0,0)
        surface.DrawRect(0,0,(percent/100) * w,h) 

        surface.SetDrawColor(255, 255,255,20)
        surface.DrawOutlinedRect(0,0,w,h)

        draw.SimpleText(data.anick, "APS_Arial_Small", 64, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT)

        draw.SimpleText(steamID32, "APS_Roboto_Small", 65, 31, Color(80,80,80,255), TEXT_ALIGN_LEFT)
        draw.SimpleText(steamID32, "APS_Roboto_Small", 64, 30, Color(200,200,200,255), TEXT_ALIGN_LEFT)

        draw.SimpleText("A CONSTATE LE", "APS_Roboto_Small", w * 0.3, h*0.5, Color(200,200,200,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(data.date, "APS_Arial_Small", w * 0.4, h*0.5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.SimpleText(data.title, "APS_Arial_Small", w * 0.75 + 2, h*0.3 + 2, Color(20,20,20,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(data.title, "APS_Arial_Small", w * 0.75, h*0.3, Color(255,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        draw.SimpleText(data.commentary, "APS_Roboto_Small", w * 0.75 + 2, h*0.55 + 2, Color(40,40,40,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(data.commentary, "APS_Roboto_Small", w * 0.75, h*0.55, Color(220,220,220,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if clicking then
            percent = math.Clamp(percent + 0.4, 0, 100)
        end


    end

    if RebornAPS:HasAccess(LocalPlayer(), "rebornaps removeuserpunishment") then
        local userSteamID = self.steamID
        function punish:OnMousePressed(code)
            clicking = true
            percent = 0
        end

        function punish:OnMouseReleased(code)
            self:MouseCapture( false )
            clicking = false
            
            if percent >= 100 then
                net.Start("APS_RemovePlayerPunishment")
                net.WriteString(userSteamID)
                net.WriteString(data.id)
                net.SendToServer()
                punish:Remove()
            end
            percent = 0
        end
    end



    function statusIcon:Paint() end


end

function PANEL:AddPunishments()
    self.PunishPlayerList:Clear()
    RebornAPS:RequestPlayerPunishments(self.steamID, function(punishments)
        
        for _, punishDetails in ipairs(punishments) do
            self:PrintPunishment(punishDetails)
        end

        self:PrintAddButton()
    end)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(30,30,30,255)

    surface.DrawRect(0,0,w,h)
end


derma.DefineControl("aps_userpunishdetails", "Panel will show all players", PANEL, "DPanel") 