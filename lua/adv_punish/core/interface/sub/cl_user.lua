local PANEL = {}

function PANEL:Init()
    self:SetText("")
    local sizeX, sizeY
    sizeX = RebornAPS.menuconfig.menuWidth * 0.33 - 11
    sizeY =  64

    self:SetSize(sizeX, sizeY)
end

function PANEL:SetPlayer(ply)

    local plyName
    local steamID
    local usergroup = "Inconnu"
    local rate = ply.rate or 0

    
    plyName = ply.nick
    steamID = ply.steamid64
 

    local pRate = math.Clamp(rate, 0, 100)

    local colorRate = 255 - (255/100) * pRate

    


    local plyAvatar = self:Add("AvatarImage")
    plyAvatar:SetSize(48,48)
    plyAvatar:SetPos(8,8)

    if(!table) then
        plyAvatar:SetPlayer(ply, 64)
    else
        plyAvatar:SetSteamID(steamID, 64)
    end

    local steamid32 = util.SteamIDFrom64(steamID)
    function self:Paint(w, h) 
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText(plyName, "APS_Arial_Small", 64, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT)
        draw.SimpleText(steamid32, "APS_Roboto_Small", 64, 30, Color(200,200,200,255), TEXT_ALIGN_LEFT)

        surface.SetDrawColor(255,255,255, 20)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    /*function viewPunishBtn:Paint(w, h)
        surface.SetDrawColor(30,30,30)
        surface.DrawRect(0,0,w,h)
        
        draw.SimpleText("Profil serveur", "APS_Roboto_Small", w * 0.5, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER)
    end*/

    /*function trustedInfo:Paint() end
    function usergroupInfo:Paint() end
    function punishmentRate:Paint() end*/
end

derma.DefineControl("aps_user", "Panel will show all players", PANEL, "DButton") 