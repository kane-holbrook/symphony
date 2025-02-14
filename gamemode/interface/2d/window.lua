AddCSLuaFile()
if SERVER then
    return 
end

--[[
    Close button
    Wrap text
    Moveable
    Size handles
    Scrollbar
]]
local PANEL = Interface.RegisterFromXML("Window", [[
    <Rect Root="true" Direction="Y" :FontColor="Color(182, 208, 216)" >

        <Rect FontName="Rajdhani" FontSize="8.5" Background="0, 0, 0, 245" Grow="true" Radius="4" Direction="Y">

            <Rect Ref="Header" Width="100%" :Cursor="Moveable and 'sizeall' or nil">
                <Rect Padding="6" Width="100%">
                    <Img Material="sstrp25/ui/window-hazard.png" Repeat="true" Scale="0.2" TopLeftRadius="4" Width="1ph" Height="100%" Color="255, 255, 255, 22" />
                    <Rect FontName="Orbitron SemiBold" :FontColor="Color(158, 200, 213)"  FontSize="12" MarginLeft="0.5ch" MarginRight="0.5ch"><Text :Content="string.upper(Title)" /></Rect>
                    <Img Material="sstrp25/ui/window-hazard.png" Repeat="true" Scale="0.2" Flex="6" Grow="true" TopRightRadius="4" Height="100%" Color="255, 255, 255, 22" Padding="1" PaddingRight="2" Gap="1" />
                </Rect>
            </Rect>

            <Rect Grow="true" Padding="6" MarginTop="2.5" MarginBottom="2.5" Direction="Y" Slot="Default">
            </Rect>

            
            <Rect Width="100%" Height="2.5ssh" PaddingX="8" MarginY="4" Direction="Y">
                <Img Material="sstrp25/ui/window-hazard.png" Repeat="true" Scale="0.04" Grow="true" Radius="1" Height="100%" Color="255, 255, 255, 22" />
            </Rect>

            
            <Rect :Display="Sizable" Ref="HandleNW" Absolute="true" X="0" Y="0" Width="5" Height="5ss" Cursor="sizenwse" />
            <Rect :Display="Sizable" Ref="HandleNE" Absolute="true" :X="PW - ScreenScale(5)" Y="0" Width="5" Height="5ss" Cursor="sizenesw" />
            <Rect :Display="Sizable" Ref="HandleSE" Absolute="true" :X="PW - ScreenScale(5)" :Y="PH - ScreenScale(5)" Width="5" Height="5ss" Cursor="sizenwse" />
            <Rect :Display="Sizable" Ref="HandleSW" Absolute="true" X="0" :Y="PH - ScreenScale(5)" Width="5" Height="5ss" Cursor="sizenesw" />
            
            <Rect Absolute="true" :Click="function () self:GetProperty('Window'):Remove() end" :X="PW - ScreenScale(7)" Y="3" :Display="Closeable" Hover="true" FontSize="4.5" Width="5" Flex="5" Height="5ss" Background="0, 0, 0, 192" Hover:Background="128, 0, 0, 192" Cursor="hand" Radius="2.5">
                x
            </Rect>
        </Rect>
    </Rect>
]])

function PANEL:Init()
    Interface.Apply(self)
    self:LoadXML()
    
    self:SetProperty("Window", self)

    self.Header:SetProperty("Click", function (...)
        local ax, ay = gui.MousePos()

        hook.Add("Think", self, function ()
            if not input.IsMouseDown(MOUSE_LEFT) then
                hook.Remove("Think", self)
                return
            end

            local x, y = gui.MousePos()
            local dx, dy = x - ax, y - ay
            ax, ay = x, y


            local x = self:GetX() + dx
            local y = self:GetY() + dy

            self:SetProperty("X", x)
            self:SetProperty("Y", y)
            self:SetPos(x, y)
        end)
    end, true)
    
    self.HandleSE:SetProperty("Click", function (...)
        -- Resize from the south east corner
        local ax, ay = gui.MousePos()

        hook.Add("Think", self, function ()
            if not input.IsMouseDown(MOUSE_LEFT) then
                hook.Remove("Think", self)
                return
            end

            local x, y = gui.MousePos()
            local dx, dy = x - ax, y - ay
            ax, ay = x, y

            local w, h = self:ScreenToLocal(x, y)
            self:SetProperty("Width", w)
            self:SetProperty("Height", h)
            self:SetSize(w, h)
            self:InvalidateLayout()
        end)
    end, true)
end