RebornAPS = RebornAPS or {}

util.AddNetworkString("APS_AddPunishmentToPlayer")
util.AddNetworkString("APS_RemovePlayerPunishment")

function RebornAPS:ApplyPunish(ply, ptype, args)
    if(ptype == "Ban") then
        ply:ChatPrint("Vous êtes banni")
    elseif ptype == "Slay" then
        ply:ChatPrint("Vous êtes slay")
        --ply:Slay()
        RunConsoleCommand("ulx", "slay", "$"..ply:SteamID())
    elseif ptype == "Mute" then
        ply:ChatPrint("Vous êtes mute")

    elseif ptype == "Gag" then
        ply:ChatPrint("Vous êtes gag")

    elseif ptype == "Kick" then
        ply:ChatPrint("Vous êtes kick")
        RunConsoleCommand("ulx", "kick", "$"..ply:SteamID())

    end
end

function RebornAPS:MakeApplied(remainingIDs)
    local separatedId = string.Explode(",", remainingIDs )
    RebornAPS:Query(self.DBs.aps, [[
       UPDATE aps_playerspunishement SET applied = '1' WHERE id IN (]]..remainingIDs..[[)
    ]], function(result)
    end)
end

function RebornAPS:CheckForApply(ply)
    --[[SELECT COUNT(*) FROM aps_playerspunishement as pp WHERE pp.applied = 1]]
    print(ply:SteamID64())
    local steamid = ply:SteamID64()

    RebornAPS:Query(self.DBs.aps, [[
        SELECT COUNT(*) as remaining, pl.title, pl.data, appliedData.nb as applied, GROUP_CONCAT(pp.id) as remainingids
        FROM aps_playerspunishement as pp INNER JOIN aps_punishlist as pl ON pp.punishuuid = pl.uuid 
        LEFT JOIN (SELECT COUNT(*) as nb, ppp.punishuuid as puuid 
        FROM aps_playerspunishement as ppp WHERE ppp.usersteamid = ']]..steamid..[[' AND applied = 1 GROUP BY ppp.punishuuid) as appliedData 
        ON appliedData.puuid = pp.punishuuid WHERE applied = 0 AND pp.usersteamid = ']]..steamid..[[' GROUP BY pp.punishuuid; 
    ]], function(result)
        for _, punish in ipairs(result) do
            
            local applied = punish.applied or 0
            local remaining = punish.remaining
            local remainingIDs = punish.remainingids

            --PrintTable(punish)
            local punishTable = util.JSONToTable(punish.data)
            for index, punishInformations in ipairs(punishTable) do
                --Checking to apply the last punishment
                if applied + remaining <= (index-1) + punishInformations.treshshold then
                    --PrintTable(punishInformations)
                    print("[APS] Vous allez être sanctionné pour d'un "..punishInformations.ptype.. " pour "..punish.title)
                    self:ApplyPunish(ply, punishInformations.ptype)
                    self:MakeApplied(remainingIDs)
                    break
                end 
            end
            --PrintTable(punishData)
        end
    end)
end

--SELECT COUNT(*) as applied, pl.data, remaindata.remaining FROM aps_playerspunishement as pp INNER JOIN aps_punishlist as pl ON pp.punishuuid = pl.uuid INNER JOIN (SELECT COUNT(*) as remaining, ppp.punishuuid FROM aps_playerspunishement as ppp WHERE applied = 0 GROUP BY ppp.punishuuid) as remaindata ON remaindata.punishuuid = pp.punishuuid WHERE applied = 1 GROUP BY pl.uuid;
function RebornAPS:GetPlayerBySteamID64(steamid64)
    
    for k,v in ipairs(player.GetAll()) do
        if v:SteamID64() == steamid64 then 
            return v
        end
    end

    return nil
end

function RebornAPS:AddPlayerPunishement(steamid, adminsteam, puuid, commentary, callback)
    local escapedComment = self.DBs.aps:escape(commentary)
    RebornAPS:Query(self.DBs.aps, [[
        INSERT INTO aps_playerspunishement VALUES (NULL, ']]..steamid..[[', ']]..puuid..[[', ']]..adminsteam..[[', ']]..escapedComment..[[',  DEFAULT, 0)
    ]], function(result)
        callback(result)
        
    end)
end

function RebornAPS:RemovePlayerPunishement(steamid, punishID, callback)
    RebornAPS:Query(self.DBs.aps, [[
        DELETE FROM aps_playerspunishement WHERE usersteamid = ']]..steamid..[[' AND id = ']]..punishID..[['
    ]], function(result)
        callback(result)
    end)
end

function RebornAPS:GetPlayerPunishement(steamid32)

end

net.Receive("APS_AddPunishmentToPlayer", function(len, ply)
    local adminsteam = ply:SteamID64()

    local steamid = net.ReadString()
    local puuid = net.ReadString()
    local commentary = net.ReadString()

    RebornAPS:AddPlayerPunishement(steamid, adminsteam, puuid, commentary, function()
        ply:ChatPrint("Infraction enregistrée")
        local user = RebornAPS:GetPlayerBySteamID64(steamid)
        if user != nil then
            RebornAPS:CheckForApply(user)
        end
    end)
end)

net.Receive("APS_RemovePlayerPunishment", function(len, ply)
    local steamid = net.ReadString()
    local punishID = net.ReadString()

    RebornAPS:RemovePlayerPunishement(steamid, punishID, function()
        ply:ChatPrint("L'infraction a bien été retiré")
    end)
end)