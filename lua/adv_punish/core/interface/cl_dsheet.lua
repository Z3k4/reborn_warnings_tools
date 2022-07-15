local PANEL = {}

PANEL.LeftContainer = nil
PANEL.RightContainer = nil

PANEL.RegisteredSheet = {}


function PANEL:Init()
    self.LeftContainer = self:Add("DPanel")
    self.LeftContainer:Dock(TOP)
    self.LeftContainer:SetTall(60)

    function self.LeftContainer:Paint(w, h)
        surface.SetDrawColor(20,20,20)
        surface.DrawRect(0,0,w,h)
    end

    self.RightContainer = self:Add("DPanel")
    self.RightContainer:Dock(FILL)

    function self.RightContainer:Paint(w, h)
        surface.SetDrawColor(20,20,20)
        surface.DrawRect(0,0,w,h)
    end
end

function PANEL:AddSheet(string, pnl, icon, func)
    local sheetBtn = self.LeftContainer:Add("DButton")
    sheetBtn:SetText(string)
    sheetBtn:Dock(LEFT)
    sheetBtn:DockMargin(10,0,0,5)
    sheetBtn:SetTall(60)
    sheetBtn:SetText("")
    sheetBtn.DoClick = function()
        self.RightContainer:Clear()
        print(pnl)
        local registeredPnl = self.RightContainer:Add(pnl)
        registeredPnl:Dock(FILL)

        
        func(sheetBtn, registeredPnl)
    end

    local showColor = Color(40,40,40)
    local textColor = Color(255,255,255)

    function sheetBtn:Paint(w,h)
        surface.SetDrawColor(showColor)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(255,170,40)
        surface.DrawRect(0,h - 4,w,4)

        draw.SimpleText(string, "APS_Arial_Small", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end 

    function sheetBtn:OnCursorEntered()
        showColor = Color(40,40,40)
        textColor = Color(180,180,180)
    end

    function sheetBtn:OnCursorExited()
        showColor = Color(30,30,30)
        textColor = Color(255,255,255)
    end
end 

function PANEL:OnActiveTabChanged()
    
end

function PANEL:GetAPSActiveTab() 
    return self:GetActiveTab()
end


derma.DefineControl("aps_dsheet", "Panel will show all players", PANEL, "DPanel")