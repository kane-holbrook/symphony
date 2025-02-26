AddCSLuaFile()
if SERVER then
    return
end

local PANEL = xvgui.RegisterFromXML("Window", [[
    <Rect 
        Ref="Window"
        FontColor="Color(182, 208, 216, 255)" 
        FontName="Rajdhani" 
        FontSize="8.5" 
        FillColor="Color(0, 0, 0, 245)" 
        Radius="5ss"
        Direction="Y"
        :Window="self"
        Title="Untitled window"
        Closeable="false"
        Moveable="false"
        Sizeable="false"
        Blur="2"
    >         
        <Rect 
            Ref="Header"
            FontName="Orbitron SemiBold" 
            FontColor="Color(158, 200, 213, 255)"
            FontSize="12"
            Flex="4"
            Width="1pw"
            PaddingLeft="4ss"
            PaddingRight="4ss"
            MarginTop="4ss"
            MarginBottom="5ss"
            :Cursor="Moveable and 'sizeall' or nil"
            :Click="function (...) Window:StartMove() end"
        >

            <Rect 
                Fill="Material(sstrp25/ui/window-hazard.png)"
                FillColor="Color(158, 200, 213, 32)" 
                FillRepeatX="true" 
                FillRepeatY="true" 
                FillRepeatScale="0.1" 
                Width="4cw" 
                Height="1ph" 
                TopLeftRadius="0.5ph"
                BottomLeftRadius="0.5ph"
            />

            <XLabel 
                :Text="isstring(Title) and Title or ''" 
                MarginLeft="2cw"
                MarginRight="2cw"
            />

            <Rect
                Fill="Material(sstrp25/ui/window-hazard.png)"
                FillColor="Color(158, 200, 213, 32)" 
                FillRepeatX="true" 
                FillRepeatY="true" 
                FillRepeatScale="0.1"
                BottomRightRadius="0.5ph"
                TopRightRadius="0.5ph"
                Grow="true"
            />

            <Rect Flex="9" Height="1ph" Direction="Y" Gap="2ss" MarginLeft="8cw" :Display="Closeable">
                <Rect Slot="HeaderButtons">
                    <Rect :Click="function (...) Window:Remove() end" Hover="true" Cursor="hand" StrokeWidth="1" Width="1.5cw" Height="1.5cw" Radius="0.75cw" Flex="5" StrokeColor="Color(255, 255, 255, 16)" FillColor="Color(97, 0, 0, 98)" Hover:FillColor="Color(173, 0, 0)">
                    </Rect>
                </Rect>
            </Rect>
        </Rect>

        <Rect Width="1pw" Height="1" FillColor="Color(158, 200, 213, 16)" />

        <Rect Ref="Body" Grow="true" Width="1pw" Padding="4ss" Slot="Default">
        </Rect>

        <Rect Ref="Footer" Height="2ss" Width="1pw" FooterColor="Color(158, 200, 213, 32)">
            <Rect 
                Fill="Material(sstrp25/ui/window-hazard.png)"
                :FillColor="FooterColor" 
                FillRepeatX="true" 
                FillRepeatY="true" 
                FillRepeatScale="0.05" 
                Width="1ph" 
                Height="1ph"
                BottomLeftRadius="1ph"
            />
            
            <Rect 
                Fill="Material(sstrp25/ui/window-hazard.png)"
                :FillColor="FooterColor" 
                FillRepeatX="true" 
                FillRepeatY="true" 
                FillRepeatScale="0.05" 
                Grow="true"
                Height="1ph"
            />
            
            <Rect 
                Fill="Material(sstrp25/ui/window-hazard.png)"
                :FillColor="FooterColor" 
                FillRepeatX="true" 
                FillRepeatY="true" 
                FillRepeatScale="0.05" 
                Width="1ph" 
                Height="1ph"
                BottomRightRadius="1ph"
            />
        </Rect>

        
    
        <Rect Absolute="true" Ref="SizeTL" :Click="function () Window:StartResize('tl') end" :Display="Sizeable" Cursor="sizenwse" X="0" Y="0" Width="5ss" Height="5ss">
        </Rect>
        
        <Rect Absolute="true" Ref="SizeTR" :Click="function () Window:StartResize('tr') end" :Display="Sizeable" Cursor="sizenesw" :X="self:GetParent():GetWide() - ScreenScale(4)" Y="0" Width="4ss" Height="4ss">
        </Rect>
                
        <Rect Absolute="true" Ref="SizeBR" :Click="function () Window:StartResize('br') end" :Display="Sizeable" Cursor="sizenwse" :X="self:GetParent():GetWide() - ScreenScale(4)" :Y="self:GetParent():GetTall() - ScreenScale(4)" Width="4ss" Height="4ss">
        </Rect>
        
        <Rect Absolute="true" Ref="SizeBL" :Click="function () Window:StartResize('bl') end" :Display="Sizeable" Cursor="sizenesw" X="0" :Y="self:GetParent():GetTall() - ScreenScale(4)" Width="4ss" Height="4ss">
        </Rect>
    </Rect>
]])

function PANEL:Init()
    self:LoadXML()
end

function PANEL:StartMove()

    if not self:GetProperty("Moveable") then
        return
    end

    local ax, ay = gui.MousePos()

    hook.Add("Think", self, function ()
        if not input.IsMouseDown(MOUSE_LEFT) then
            self:FinishMove()
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
end

function PANEL:FinishMove()
end

function PANEL:StartResize(handle)

    if not self:GetProperty("Sizeable") then
        return
    end

    local ax, ay = gui.MousePos()

    hook.Add("Think", self, function ()
        if not input.IsMouseDown(MOUSE_LEFT) then
            self:FinishResize()
            hook.Remove("Think", self)
            return
        end

        local x, y = gui.MousePos()
        local dx, dy = x - ax, y - ay
        ax, ay = x, y

        if handle == "tl" then
            local x = self:GetX() + dx
            local y = self:GetY() + dy
            local w = self:GetWide() - dx
            local h = self:GetTall() - dy

            self:SetProperty("Width", w)
            self:SetProperty("Height", h)
            self:SetSize(w, h)
            
            self:SetProperty("X", x)
            self:SetProperty("Y", y)
            self:SetPos(x, y)
        elseif handle == "tr" then
            local x = self:GetX()
            local y = self:GetY() + dy
            local w = self:GetWide() + dx
            local h = self:GetTall() - dy

            self:SetProperty("Width", w)
            self:SetProperty("Height", h)
            self:SetSize(w, h)
            
            self:SetProperty("X", x)
            self:SetProperty("Y", y)
            self:SetPos(x, y)
        elseif handle == "br" then
            local x = self:GetX()
            local y = self:GetY()
            local w = self:GetWide() + dx
            local h = self:GetTall() + dy

            self:SetProperty("Width", w)
            self:SetProperty("Height", h)
            self:SetSize(w, h)
            
            self:SetProperty("X", x)
            self:SetProperty("Y", y)
            self:SetPos(x, y)
        elseif handle == "bl" then
            local x = self:GetX() + dx
            local y = self:GetY()
            local w = self:GetWide() - dx
            local h = self:GetTall() + dy

            self:SetProperty("Width", w)
            self:SetProperty("Height", h)
            self:SetSize(w, h)
            
            self:SetProperty("X", x)
            self:SetProperty("Y", y)
            self:SetPos(x, y)
        end

        self:InvalidateChildren(true)
    end)
end

function PANEL:FinishResize()
end
