util.AddNetworkString("APS_CreatePunishment")
util.AddNetworkString("APS_DropPunishment")
util.AddNetworkString("APS_UpdatePunishment")

RebornAPS = RebornAPS or {}


function RebornAPS:InitializePunishment()

    
    RebornAPS.DBs.aps.onConnectionFailed = function(db, err)
        print("[APS] Error with database connection")
    end 

    RebornAPS.DBs.aps.onConnected = function() 
        print("Connected to APS database")


        RebornAPS:RegisterDataReturnsByType("players_punishement_rate", function(ply)
            RebornAPS:GetAllPunishmentRate(function(data)
                RebornAPS:SendDataToClient(data, "players_punishement_rate", ply)
            end)
        end)
        
        RebornAPS:RegisterDataReturnsByType("user_punishments", function(ply, args)
            
            local steamid = args[1]
            
        
            RebornAPS:GetPlayerPunishements(steamid, function(data)
                RebornAPS:SendDataToClient(data, "user_punishments", ply)
            end)
        end)  

        RebornAPS:RegisterDataReturnsByType("available_punishments", function(ply, args)
        
            RebornAPS:GetAvailablePunishments(function(data)
                RebornAPS:SendDataToClient(data, "available_punishments", ply)
            end)
        end)  
    end

    print("Trying to communicate with APS database..")

    RebornAPS.DBs.aps:connect()
end


function RebornAPS:IntializePunishementDatabase()

    --Query
    RebornAPS:Query(self.DBs.aps, 
    [[CREATE TABLE IF NOT EXISTS aps_punishlist 
        (id INT NOT NULL AUTO_INCREMENT,
        uuid VARCHAR(255) PRIMARY KEY,
        punishtitle VARCHAR(40), 
        punishdata TEXT,
        level INT)
    ]])

end  

function RebornAPS:GetPunishment()

end

function RebornAPS:GetAllPunishmentRate(callback)
    
    RebornAPS:Query(self.DBs.aps,[[
        SELECT (SUM(level)/100) as rate,usersteamid FROM aps_punishlist as alist JOIN aps_playerspunishement as aps ON aps.punishuuid = alist.uuid GROUP BY usersteamid;
    ]], function(result)
        PrintTable(result)
        callback(result)
    end)
    
end

function RebornAPS:AddPunishment(punishData, callback)
    local uuid = self.DBs.aps:escape(punishData.uuid)
    local title = self.DBs.aps:escape(punishData.title)
    local list = self.DBs.aps:escape(util.TableToJSON(punishData.data))
    local level = 1

    /*print([[INSERT INTO aps_punishlist VALUES (NULL, ]]..uuid..[[, ]]..title..[[, ]]..list..[[, ]]..level..[[)
    ]])*/
    RebornAPS:Query(self.DBs.aps, [[
        INSERT INTO aps_punishlist VALUES (NULL, ']]..uuid..[[', ']]..title..[[', ']]..list..[[', ]]..level..[[)
    ]], function(result)
        callback(result)
    end)
end

function RebornAPS:EditPunishment(punishData, callback)
    local uuid = self.DBs.aps:escape(punishData.uuid)
    local title = self.DBs.aps:escape(punishData.title)
    local list = self.DBs.aps:escape(util.TableToJSON(punishData.data))
    local level = 1

    print([[
        UPDATE aps_punishlist SET title = ']]..title..[[', data = ']]..list..[[', level = ]]..level..[[ WHERE uuid = ']]..uuid..[[')
    ]])
    RebornAPS:Query(self.DBs.aps, [[
        UPDATE aps_punishlist SET title = ']]..title..[[', data = ']]..list..[[', level = ']]..level..[[' WHERE uuid = ']]..uuid..[['
    ]], function(result)
        callback()
        print("Punition éditer")
    end)
end

function RebornAPS:RemovePunishement(uuid, ply)
    local escape = self.DBs.aps:escape(uuid)
    RebornAPS:Query(self.DBs.aps, 
    [[DELETE FROM aps_playerspunishement as pp WHERE pp.punishuuid =']]..uuid..[[']], function()
        RebornAPS:Query(self.DBs.aps, [[
            DELETE FROM aps_punishlist WHERE uuid = ']]..uuid..[['
        ]], function(result)
            ply:ChatPrint("Sanction supprimée")
        end)
    end)

end


function RebornAPS:GetPlayerPunishements(steamid, callback)
    local steamid = self.DBs.aps:escape(steamid)
    RebornAPS:Query(self.DBs.aps, [[
        SELECT aps.id, alist.title, gex.nick as unick, admindata.anick, admindata.adminsteamid, aps.commentary, aps.date, aps.applied 
        FROM aps_playerspunishement as aps 
        INNER JOIN (SELECT aps.id, gex.nick as anick, gex.steamid64 as adminsteamid FROM aps_playerspunishement as aps INNER JOIN gextension.gex_users as gex ON gex.steamid64 = aps.adminsteamid) as admindata
        ON admindata.id = aps.id
        INNER JOIN gextension.gex_users as gex ON gex.steamid64 = aps.usersteamid
        INNER JOIN aps_punishlist as alist ON alist.uuid = aps.punishuuid WHERE aps.usersteamid = ']]..steamid..[[' ORDER BY aps.date DESC
    ]], function(result)
        callback(result)
    end)
end

function RebornAPS:GetAvailablePunishments(callback)
    self:Query(self.DBs.aps, [[
        SELECT uuid, title, data, level FROM aps_punishlist
    ]], function(result)
        callback(result)
    end)
end

net.Receive("APS_CreatePunishment", function(len, ply)
    local punish = net.ReadTable()
    RebornAPS:AddPunishment(punish, function(result)
        ply:ChatPrint("Type d'infraction enregistrée")
    end)
end)

net.Receive("APS_UpdatePunishment", function(len, ply)
    local punish = net.ReadTable()
    RebornAPS:EditPunishment(punish, function()
        ply:ChatPrint("Infraction éditée")
    end)
end)

net.Receive("APS_DropPunishment", function(len, ply)
    local uuid = net.ReadString()
    RebornAPS:RemovePunishement(uuid, ply)
end)

--RebornAPS:IntializePunishementDatabase()  
--RebornAPS:AddPunishement() 


/*
Register functions
*/

