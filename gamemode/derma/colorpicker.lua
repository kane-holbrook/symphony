AddCSLuaFile()

if SERVER then return end

local PANEL = xvgui.RegisterFromXML("ColorPicker", [[
    <Rect Ref="Top" ShowAlpha="true" RGB="Color(255, 255, 255, 255)">
        <Textbox Ref="Input" Width="30cw" :Value="tostring(RGB)" :On:GetFocus="function (el)
            if self.Popover:GetProperty('Opened', true) then
                return true
            end

            self.Popover:Open()
            return true
        end" :On:LoseFocus="function (el) 
            self.Popover:Close()
            return true
        end"

            :On:Change:Value="function (el, val)
                if self.Setting then
                    return
                end
                self.Setting = true

                local col = Color(255, 255, 255, 255)
                local r, g, b, a = unpack(string.Split(val, ' '))

                r = math.Clamp(tonumber(r) or 0, 0, 255)
                g = math.Clamp(tonumber(g) or 0, 0, 255)
                b = math.Clamp(tonumber(b) or 0, 0, 255)
                
                if ShowAlpha then
                    a = math.Clamp(tonumber(a) or 255, 0, 255)
                end

                col = Color(r, g, b, a)
                Top:SetProperty('RGB', col)
                Top:InvalidateLayout()

                self.Popover.Cube:SetRGB(col)
                self.Popover.Cube:SetColor(col)
                self.Popover.Cube:SetBaseRGB(col)

                local h, s, v = ColorToHSV(col)
                self.Popover.RGB.LastY = ( 1 - h / 360 ) * self.Popover.RGB:GetTall()

                self.Popover.Alpha:SetBarColor(ColorAlpha(col, 255))
                self.Popover.Alpha:SetValue(col.a / 255)

                self.Setting = false

            end"
        >
            <Slot Name="Left">
                <Rect Ref="Color" Width="0.3ph" Height="0.3ph" Radius="0.15ph" StrokeColor="Color(255, 255, 255, 32)" StrokeWidth="1px" 
                    Fill="Material(sstrp25/ui/window-hazard.png)"
                    FillColor="Color(255, 255, 255, 255)" 
                    FillRepeatX="true" 
                    FillRepeatY="true" 
                    FillRepeatScale="0.01"
                >
                    <Rect :FillColor="RGB" Width="1pw" Height="1ph" Radius="0.5pw" />
                </Rect>
            </Slot>

            <Popover 
                Ref="Popover" 
                :Y="1 * PH + ScreenScale(2)"
                Blur="5"
                FillColor="Color(0, 0, 0, 64)"
                StrokeWidth="1"
                StrokeColor="Color(255, 255, 255, 16)"
                Radius="2ss"
                Cursor="none"
                KeyboardInputEnabled="false"
                Slot="Default"
                Direction="Y"
                FontSize="8"
                FontWeight="500"
                FontColor="Color(182, 208, 216, 255)" 
                FontName="Rajdhani"
                Hover="true"
            >
                <Rect 
                    Fill="Material(sstrp25/ui/window-hazard.png)"
                    FillColor="Color(158, 200, 213, 16)" 
                    FillRepeatX="true" 
                    FillRepeatY="true" 
                    FillRepeatScale="0.01"
                    Radius="2ss"
                    Padding="2ss"
                    Height="40ss"
                >
                    <DColorCube Ref="Cube" Width="1ph" Height="1ph" />
                    <DRGBPicker Ref="RGB" Width="7.5ss" Height="1ph" />
                    <DAlphaBar Ref="Alpha" Width="7.5ss" Height="1ph" :Display="ShowAlpha" />
                </Rect>
            </Popover>
        </Textbox>
    </Rect>
]])

function PANEL:Init()
    self:LoadXML()
    
    local cube = self.Input.Popover.Cube
    local rgb = self.Input.Popover.RGB
    local alpha = self.Input.Popover.Alpha

    cube.OnUserChanged = function (el, col)
        self.Input.Setting = true

        local old = self:GetProperty("RGB") or Color(255, 255, 255, 255)

        local col = Color(col.r, col.g, col.b, old.a)
        local str = string.format("%i %i %i %i", col.r, col.g, col.b, col.a)

        self:SetProperty("RGB", col)
        
        self.Input:SetProperty("Value", tostring(col))
        self.Input.TextEntry:SetText(tostring(col))

        local h, s, l = ColorToHSV(col)
        rgb.LastY = ( 1 - h / 360 ) * rgb:GetTall()
        alpha:SetBarColor(ColorAlpha(col, 255))
        self.Input.Setting = false

        self:InvalidateLayout()
    end

    function rgb.OnChange(el, col)
        local old = self:GetProperty("RGB") or Color(255, 255, 255, 255)
        col.a = old.a
        
        self:SetProperty("RGB", Color(col.r, col.g, col.b, col.a))
        
        self.Input:SetProperty("Value", tostring(col))
        self.Input.TextEntry:SetText(tostring(col))
        self.Input:InvalidateLayout()

        alpha:SetBarColor(ColorAlpha(col, 255))
        self:InvalidateLayout()
    end

    function alpha.OnChange(el, alpha)

        local col = self:GetProperty("RGB") or Color(255, 255, 255, 255)
        col.a = math.Clamp(alpha * 255, 0, 255)

        self:SetProperty("RGB", col)
        
        self.Input:SetProperty("Value", tostring(col))
        self.Input.TextEntry:SetText(tostring(col))
        self.Input:InvalidateLayout()

        local h, s, l = ColorToHSV(col)
        rgb.LastY = ( 1 - h / 360 ) * rgb:GetTall()


        self:InvalidateLayout()
    end
end