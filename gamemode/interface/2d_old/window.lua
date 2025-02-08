AddCSLuaFile()
if SERVER then
    return 
end

local PANEL = Interface.RegisterFromXML("Window", [[
    <Rect Root="true" Direction="Y">
        <Rect 
            Ref="Header" 
            Width="100%" 
            Height="15ssh" 
        >
            <Rect Padding="5ssh">
                Header
            </Rect>
        </Rect>

        <Rect 
            Ref="Body" 
            Grow="true"
            BottomLeftRadius="5ssh" 
            BottomRightRadius="5ssh"
            Background="0 0 0 225"
            Slot="Default"
        >
        </Rect>
    </Rect>
]])

function PANEL:Init()
    Interface.Apply(self)
    self:LoadXML()

    
    function self.Header:Paint(w, h)
        local x, y = self:LocalToScreen(0, 0)

        self:StartStencil(w, h)
            DrawLinearGradient(x, y, w, h, Color(69, 142, 190), Color(0, 63, 105), 1)
            DrawLinearGradient(x, y, w, h, Color(255, 255, 255, 3), Color(0, 3, 41, 40), 1)
        self:FinishStencil()
    end
    
    function self.Body:Paint(w, h)
        local x, y = self:LocalToScreen(0, 0)

        self:StartStencil(w, h)
            DrawCircularGradient(x, y, w, h, Color(6, 20, 29), Color(0, 63, 105))
            DrawLinearGradient(x, y, w, h, Color(255, 255, 255, 20), Color(255, 255, 255, 3), 1)
        self:FinishStencil()
    end
end