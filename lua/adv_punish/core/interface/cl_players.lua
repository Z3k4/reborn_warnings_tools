local PANEL = {}
PANEL.IconLayout = nil

local trustedIcon = Material("icon16/tick.png")
function PANEL:Init()

    self.ScrollPanel = self:Add("DScrollPanel")
    self.ScrollPanel:Dock(FILL)


    self.DNumPage = self.ScrollPanel:Add("DNumberWang")
    self.DNumPage:SetValue(1)
    self.DNumPage:SetMin(1)
    self.DNumPage:SetPos(self:GetParent():GetWide() - 90, 5)

    self.SearchField = self.ScrollPanel:Add("DTextEntry")
    self.SearchField:SetPos(10,5)
    self.SearchField:SetWide(150)
    self.SearchField:SetPlaceholderText("Rechercher..")

    self.IconLayout = self.ScrollPanel:Add("DIconLayout")
    self.IconLayout:Dock(TOP)
    self.IconLayout:DockMargin(5, 30,0,0)
    self.IconLayout:SetSpaceX(5)
    self.IconLayout:SetSpaceY(5) 

    self.RefreshBtn = self.ScrollPanel:Add("DButton")
    self.RefreshBtn:SetIcon("icon16/arrow_refresh.png")
    self.RefreshBtn:SetText("")
    self.RefreshBtn:SetSize(20,16)
    self.RefreshBtn:SetPos(self:GetParent():GetWide() - 120, 7)
    self.RefreshBtn:SetToolTip("Rafraîchir les données")
    self.RefreshBtn.DoClick = function()
        RebornAPS.DataCache.HasRetriviedPlayers = false
        self:RegisterStoredPlayers()
    end

    self.DNumPage.OnValueChanged = function(slf, val)
        local val = tonumber(val)

        self:AddRowPlayers(tonumber(val))
    end

    self.SearchField.OnChange = function(slf)
        local val = slf:GetValue()
        if(val != "") then
            self:SearchPlayer(val)
        else
            self:AddRowPlayers(1)
        end
    end

    function self.RefreshBtn:Paint() end

end

function PANEL:Paint(w, h)
    surface.SetDrawColor(32,32,32)
    surface.DrawRect(0,0,w,h)

    draw.SimpleText("Nombre total "..(RebornAPS.DataCache.PlayersCount or 0) .. " joueurs", "APS_Roboto_Small", w * 0.7, 7, Color(255,255,255,255), TEXT_ALIGN_LEFT)
end

function PANEL:SearchPlayer(nameOrID)
    self.IconLayout:Clear()
    for _, playerTbl in ipairs(RebornAPS.DataCache.StoredUsers) do
        for _, ply in ipairs(playerTbl) do
            
            if(nameOrID == ply.steamid32 || string.find(ply.nick:lower(), nameOrID:lower()) != nil ) then
                self:AddPlayer(ply, true)
            end
        end
    end
end

function PANEL:AddPlayer(ply)
    local user = self.IconLayout:Add("aps_user")
    user:SetPlayer(ply)

    user.DoClick = function()
        parent = self:GetParent()
        local userDetails = parent:Add("aps_userpunishdetails")
        userDetails:SetPlayer(ply)
    end
end

function PANEL:AddOnlinePlayers()
    self.IconLayout:Clear()
    for _, ply in ipairs(player.GetAll()) do
        local plytbl = {}
        plytbl.nick = ply:Name()
        plytbl.steamid64 = ply:SteamID64()
        self:AddPlayer(plytbl)
    end
end

function PANEL:AddRowPlayers(numPage)
    self.IconLayout:Clear()
    if(RebornAPS.DataCache.StoredUsers[numPage]) then

        for k, v in ipairs(RebornAPS.DataCache.StoredUsers[numPage]) do
            self:AddPlayer(v, true)
        end
    end
end

function PANEL:RegisterStoredPlayers()
    
    if RebornAPS.DataCache.HasRetriviedPlayers then
        self:AddRowPlayers(1)
    else
        RebornAPS.DataCache.StoredUsers = {}
        RebornAPS:RequestPlayers(function(players)
            if self then
                RebornAPS.DataCache.PlayersCount = table.Count(players)
                for k, v in ipairs(players) do
                    local index = math.floor(k / 32) + 1 
                    RebornAPS.DataCache.StoredUsers[index] = RebornAPS.DataCache.StoredUsers[index] or {}

                    table.insert(RebornAPS.DataCache.StoredUsers[index], v)
                end

                self.DNumPage:SetMax(math.floor(table.Count(players) / 32))
                self.DNumPage:SetValue(1)
                self:AddRowPlayers(1)
                RebornAPS.DataCache.HasRetriviedPlayers = true
            end
            
        end)
    end
end


derma.DefineControl("aps_playersdata", "Panel will show all players", PANEL, "DPanel")