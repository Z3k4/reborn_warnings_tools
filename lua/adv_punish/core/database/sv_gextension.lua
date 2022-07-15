RebornAPS = RebornAPS or {}


function RebornAPS:InitializeGExtension()

    
    RebornAPS.DBs.gex.onConnectionFailed = function(db, err)
        print("[APS] Error with database connection")
    end 
    
    RebornAPS.DBs.gex.onConnected = function()
        print("Connected to GExtension database")

        RebornAPS:RegisterDataReturnsByType("players", function(ply)
            RebornAPS:GetPlayers(function(data)
                RebornAPS:SendDataToClient(data, "players", ply)
            end)
        end)  
    end

    print("Trying to communicate with GExtension database..")
    RebornAPS.DBs.gex:connect()
end



function RebornAPS:GetPlayers(callback)
   
    self:Query(self.DBs.gex, [[SELECT steamid64, nick, UNIX_TIMESTAMP(date_registered) as date_registered, UNIX_TIMESTAMP(date_lastonline_gmod) as last_online
    FROM gextension.gex_users WHERE steamid64 > 0 ORDER BY last_online DESC]], function(result)
        callback(result)
    end)
end

/* Register functions */

