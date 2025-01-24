if SERVER then
    return
end

local PANEL = {}
function PANEL:Init()
    self:SetBackground(HTMLGradient([[radial-gradient(
        circle, 
        rgba(32, 40, 47, 0.95) 0%,
        rgb(39, 44, 49, 0.95) 50%
    )]], ScrW(), ScrH()))
end

function PANEL:Paint(w, h)
    SymPanel.Paint(self, w, h)

    local hndl = ScreenScale(2)
    surface.SetDrawColor(255, 255, 255, 16)
    surface.DrawLine(0, 0, w, 0)
    surface.DrawLine(0, 0, 0, h)
    surface.DrawLine(0, 0, w, 0)
    surface.DrawLine(0, h-1, w, h-1)
    surface.DrawLine(w-1, 0, w-1, h)

    surface.SetDrawColor(255, 255, 255, 128)
    surface.DrawLine(0, 0, hndl, 0)
    surface.DrawLine(0, 0, 0, hndl)
    surface.DrawLine(0, h-hndl, 0, h)
    surface.DrawLine(0, h-1, hndl, h-1)
    surface.DrawLine(w-1, h-hndl, w-1, h)
    surface.DrawLine(w-hndl, h-1, w, h-1)
    surface.DrawLine(w-1, 0, w-1, hndl)
    surface.DrawLine(w-hndl, 0, w, 0)
end
vgui.Register("SymFrame", PANEL, "SymPanel")