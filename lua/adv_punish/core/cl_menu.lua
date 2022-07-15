local function ShowPanel()
    if RebornAPS:HasAccess(LocalPlayer(), "rebornaps open") then
        local apsFrame = vgui.Create("DFrame")
        apsFrame:MakePopup()
        apsFrame:SetSize(RebornAPS.menuconfig.menuWidth, 600)
        apsFrame:Center()
        apsFrame:SetTitle("")
        apsFrame:Show()
        apsFrame:ShowCloseButton(false)

        local btn = apsFrame:Add("DButton")
        btn:SetSize(16,16)
        btn:SetText("")
        btn:SetPos(apsFrame:GetWide() - 18, 2)
        btn.DoClick = function()
            apsFrame:Close()
        end

        local dSheet = apsFrame:Add("aps_dsheet")
        dSheet:Dock(FILL)
        


        dSheet:AddSheet("En ligne", "aps_playersdata", nil, function(btn, pnl)
            pnl:AddOnlinePlayers()
        end)

        
        dSheet:AddSheet("Tous", "aps_playersdata", nil, function(btn, pnl)
            pnl:RegisterStoredPlayers()
        end)

        if RebornAPS:HasAccess(LocalPlayer(), "rebornaps viewpunishment") then
            dSheet:AddSheet("Sanctions", "aps_allpunish", nil, function(btn, pnl)
                
            end)
        end

        /*dSheet:AddSheet("Paramètres", "aps_allplayers", nil, function(btn, pnl)
            
        end)*/

        function apsFrame:Paint(w,h)
            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,0,w,h)

            draw.DrawText("Le super addon mega stylé et privé et aussi bg et aussi en développement (v1.0)", "APS_Roboto_Small",10, 4, Color(255,255,255), TEXT_ALIGN_LEFT)

        end

        function btn:Paint(w,h)
            surface.SetDrawColor(255,0,0)
            surface.DrawRect(0,0,w,h)
            draw.DrawText("x", "APS_Roboto_Small",w * 0.5, 0, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else
        chat.AddText("Vous n'avez pas accès à cette commande")
    end
end


concommand.Add("open_aps", ShowPanel)