
AddCSLuaFile()
if SERVER then return end
local PANEL = xvgui.RegisterFromXML("XSlider", [[
    <Rect Ref="Top" Height="5ss" Width="1pw" Flex="5" Value="0" Min="0" Max="1">
        <Rect 
            Ref="Bar"
            Fill="Material(sstrp25/ui/window-hazard.png)"
            FillColor="Color(255, 255, 255, 32)" 
            FillRepeatX="true" 
            FillRepeatY="true" 
            FillRepeatScale="0.001" 
            Width="1pw" 
            Height="0.5ph"
            Radius="0.25ph"
            Cursor="hand"
        >
        </Rect>

        <Rect 
            Ref="Handle"
            Absolute="true" 
            Width="1ph" 
            Height="1ph" 
            :X="math.Remap(Value, Min, Max, Width/2, PW-Width/2) - Width/2"
            Hover="true" 
            FillColor="Color(158, 200, 213, 128)" 
            Radius="0.5ph" 
            Hover:FillColor="Color(158, 200, 213, 245)" 
            Cursor="hand"
        >
            <Popover 
                Ref="Hint" 
                :X="PW/2-Width/2" 
                :Y="PH + ScreenScale(4)" 
                FontSize="7"     
                FontColor="Color(255, 255, 255, 255)" 
                FontName="Rajdhani"
                FontWeight="500"
                Radius="1cw"
                PaddingX="1cw"
                Height="1.5ch"
                Flex="5"
                FillColor="Color(16, 55, 66, 245)"
            >
                <XLabel Ref="Text" :Text="Value" />
            </Popover>
        </Rect>
    </Rect>
]])

function PANEL:Init()
    self:LoadXML()

    function self.Handle.OnMousePressed(el, code)
        local ax, ay = self:ScreenToLocal(gui.MousePos())

        self.Handle.Hint:Open()

        hook.Add("Think", self, function ()
            if not input.IsMouseDown(MOUSE_LEFT) then
                self.Handle.Hint:Close()
                hook.Remove("Think", self)
                return
            end

            local x, y = self:ScreenToLocal(gui.MousePos())
            local dx, dy = x - ax, y - ay

            local w2 = self:GetWide() - el:GetWide()
            local x = math.Clamp(x, 0, w2)

            local mins, maxs = self:GetProperty("Min", true) or 0, self:GetProperty("Max", true) or 1

            self.Setting = true
            self:SetProperty("Value", math.Round(math.Remap(x/w2, 0, 1, mins, maxs), self:GetProperty("Rounding", true) or 2))
            self.Setting = false

            self:Emit("Change:Value", self:GetProperty("Value", true))
            
            self:InvalidateChildren(true)
        end)
    end

    function self.Bar.OnMousePressed(el, code)
        local ax, ay = self:ScreenToLocal(gui.MousePos())
        --self.Handle:SetProperty("X", ax - self.Handle:GetWide()/2)
        self.Handle:OnMousePressed(MOUSE_LEFT)
    end

    slider = self
end