
local function loadFile(folder, fileName)
    local fileType = string.sub(fileName, 0, 3)
    local filePath = folder.."/"..fileName

    if fileType == "sv_" then
        print("Include "..filePath)
        include(filePath)
    else
        print("Register "..filePath)
        AddCSLuaFile(filePath)

        if fileType == "sh_" then
            include(filePath)
        elseif fileType == "cl_" then
            
            if(CLIENT) then
                include(filePath)
            end
        end
    end
end 

local function lookUpDirectory(dirName)
    print("Look up at "..dirName)
    local files, directories = file.Find(dirName.."/*", "LUA")

    for _, dir in ipairs(directories) do
        lookUpDirectory(dirName.."/"..dir)
    end

    for _, file in ipairs(files) do
        loadFile(dirName, file)
    end
end

local function loadAddon()
    print("|************ Load Advanced Punishment System ***********|")

    local files, directories = file.Find("adv_punish/*", "LUA")
    for _, file in ipairs(files) do
        loadFile("adv_punish", file)
    end

    for _, dir in ipairs(directories) do
        lookUpDirectory("adv_punish/"..dir)
    end

    print("|********************************************************|")
end

loadAddon() 
 