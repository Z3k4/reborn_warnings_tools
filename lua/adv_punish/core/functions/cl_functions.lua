RebornAPS = RebornAPS or {}


function RebornAPS:RequestPlayers(callback)
    RebornAPS:GetData("players", function(typ, players)
        RebornAPS:GetData("players_punishement_rate", function(typ, punishements)
            callback(self:MergePlayersData(players, punishements))
        end)
    end)
end

function RebornAPS:RequestPlayerPunishments(ply, callback)
    print("test")
    RebornAPS:GetData("user_punishments", function(typ, punishments)
        callback(punishments)
    end, ply)
end 


function RebornAPS:RequestAvailablePunishments(callback)
    RebornAPS:GetData("available_punishments", function(typ, punishments)
        callback(punishments)
    end, ply)
end 