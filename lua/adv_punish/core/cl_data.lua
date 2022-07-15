RebornAPS = RebornAPS or {}
RebornAPS.DataCache = {}
RebornAPS.DataCache.StoredUsers = {}
RebornAPS.DataCache.HasRetriviedPlayers = false

function RebornAPS:GetData(typ, callback, ...)
    local collectingData = {}
    local args = {...}
    local block = 0
    local dataType = typ

    net.Start("RebornAPS_RequestData")
    net.WriteString(dataType)
    net.WriteString(util.TableToJSON(args))
    net.SendToServer()

    net.Receive("RebornAPS_SendData", function()
        local finished = net.ReadBool()
        local typ = net.ReadString()

        if(finished && typ == dataType) then
            callback(typ, collectingData)

        else
            --LocalPlayer():ChatPrint("Collecting data..")
            
            local data = util.JSONToTable(net.ReadString())
            table.Add(collectingData, data)
        end

    end)

end

function RebornAPS:MergePlayersData(players, punishments)
    local plyWithPunish = {}
    PrintTable(players)
    
    for _, plyGex in pairs(players) do
        local plyData = {}

        --Merge gextension data first
        for key, value in pairs(plyGex) do
            if !plyData[key] then
                plyData[key] = value
            end
        end
        
        -- Now merge plyAps with gextension player which corresponding 
        for _, plyAps in pairs(punishments) do
            if plyAps.steamid64 == plyGex.steamid64 then
                for key, value in pairs(plyAps) do
                    if !plyData[key] then
                        plyData[key] = value or nil
                    end
                end
            end
        end

        table.insert(plyWithPunish, plyData)
    end


    return plyWithPunish
end
