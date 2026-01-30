AddCSLuaFile()

if SERVER then
    return
end


local PANEL = vguix.RegisterFromXML("SSTRP.Modal", [[
    <Rect Name="Component" Absolute="true" Blur="3" Align="5" X="0" Y="0" Width="1vw" Height="1vh" Fill="0, 0, 0, 200" Flow="Y" Func:LeftClick="function (self, src)
            if not src or src == self then
                self:Close()
            end
            return true 
        end" Cursor="hand">
        <Rect Func:TestHover="function () return false end" Absolute="true" :X="Parent.Width - Width - 16" Y="16" Width="24" Height="24" 
            Mat="sstrp25/v2/cross64.png"
            Fill="255, 255, 255, 128"
        />
    </Rect>
]])

function PANEL:Close()
    return self:Remove()
end