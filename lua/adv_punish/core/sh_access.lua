RebornAPS = RebornAPS or {}
RebornAPS.ULib_Enabled = true

if SERVER then
    if ULib then
        local catname = "Reborn"
        ULib.ucl.registerAccess( "rebornaps open", ULib.ACCESS_ADMIN, "Ability to open aps menu", catname )
        ULib.ucl.registerAccess( "rebornaps adduserpunishment", ULib.ACCESS_ADMIN, "Ability to open aps menu", catname )
        ULib.ucl.registerAccess( "rebornaps removeuserpunishment", ULib.ACCESS_ADMIN, "Ability to open aps menu", catname )
        --ULib.ucl.registerAccess( "rebornaps viewuserpunishment", ULib.ACCESS_ADMIN, "Ability to see all punishment", catname )
        ULib.ucl.registerAccess( "rebornaps viewpunishment", ULib.ACCESS_ADMIN, "Ability to see all punishment", catname )
        ULib.ucl.registerAccess( "rebornaps editpunishment", ULib.ACCESS_ADMIN, "Ability to see all punishment", catname )
    end
end



function RebornAPS:HasAccess(ply, access)
    local hasAccess = false
    if ULib && self.ULib_Enabled then
        
        hasAccess = ULib.ucl.query(ply, access)
    else
        hasAccess =  ply:IsAdmin()
    end

    return hasAccess
end