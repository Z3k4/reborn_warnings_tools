require('mysqloo')
RebornAPS = RebornAPS or {}

util.AddNetworkString("RebornAPS_SendDataHeader")
util.AddNetworkString("RebornAPS_RequestData")
util.AddNetworkString("RebornAPS_SendData")


RebornAPS.ReturnsByTypeFunctions = {}

RebornAPS.DBs = {}
local gex = RebornAPS.DatabaseLogin["gextension"]
local aps = RebornAPS.DatabaseLogin["aps"]
RebornAPS.DBs.gex = mysqloo.connect(gex.host, gex.user, gex.password, gex.database, 3306)
RebornAPS.DBs.aps = mysqloo.connect(aps.host, aps.user, aps.password, aps.database, 3306)
 
RebornAPS:InitializePunishment()
RebornAPS:InitializeGExtension()


function RebornAPS:Query(db, sql, callback)
    if db != nil && db:status() == mysqloo.DATABASE_CONNECTED then
        
        local q = db:query(sql)
        function q:onSuccess(results)
            if(callback != nil) then
                callback(results)
            end
        end

        function q:onError(result)
            print(result)
        end

        q:start()
    end
end


function RebornAPS:RegisterDataReturnsByType(name, func)
    --if !RebornAPS.ReturnsByTypeFunctions[name] then
        RebornAPS.ReturnsByTypeFunctions[name] = func
        print("[APS] Adding "..name.. " to the register data return")
    --end
end


net.Receive("RebornAPS_RequestData", function(len, ply) 
    local typ = net.ReadString()
    local args = util.JSONToTable(net.ReadString())

    if RebornAPS.ReturnsByTypeFunctions[typ] then
        RebornAPS.ReturnsByTypeFunctions[typ](ply, args)
    else
        ply:ChatPrint("No function registered for "..typ.. " data type")
    end
end) 



local function parsingData(data, index, amount)

    local i = index
    local totalData = table.Count(data) + 1
    local endIndex = (index + amount)
    

    local parsingTbl = {}

    while(i < totalData && i < endIndex && data[i]) do

        table.insert(parsingTbl, data[i])
        i = i + 1
    end

    return parsingTbl
end


function RebornAPS:SendDataToClient(data, dataType, client)
    --client:ChatPrint("Sending data..")
    local totalcount = 0
    local amountData = table.Count(data)
    local resteDonnee = amountData
    local readingHead = 1
    local packageSize = 32
    local blockSent = 0

    local amountSent = 0
    --client:ChatPrint("Need to send "..(amountData/32).. "blocks for a total of ".. amountData)
    while (resteDonnee != 0 && resteDonnee) do
        local parsedData = {}
        if(resteDonnee >= 32) then
            --client:ChatPrint("Reading head position : "..readingHead)
            parsedData = parsingData(data, readingHead, 32)
            --client:ChatPrint("Parsed data size ".. #parsedData)
            if(readingHead + 32 < amountData) then
                readingHead = readingHead + 32
            end
            
            resteDonnee = resteDonnee - #parsedData
        else

            --resteDonnee = resteDonnee 
            --client:ChatPrint("Reading head position : "..readingHead.. " données restantes "..resteDonnee .. " / "..amountData)
            --client:ChatPrint("Données restantes " ..resteDonnee)
            
            parsedData = parsingData(data, readingHead, resteDonnee)
            resteDonnee = 0
        end

        amountSent = amountSent + #parsedData

        --client:ChatPrint("Data sent "..amountSent)

        local finished = resteDonnee == 0

        blockSent = blockSent + 1


        net.Start("RebornAPS_SendData")
        net.WriteBool(false)
        --net.WriteInt(blockSent)
        net.WriteString(dataType)
        net.WriteString(util.TableToJSON(parsedData))
        net.Send(client)


    end

    net.Start("RebornAPS_SendData")
    net.WriteBool(true)
    net.WriteString(dataType)
    net.Send(client)

end 