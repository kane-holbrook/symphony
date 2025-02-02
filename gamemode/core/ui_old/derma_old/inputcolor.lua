if SERVER then
    return
end

local PANEL = {}
PANEL.IsInput = true

local function BindToInput(name)
    local set = "Set" .. name
    PANEL[set] = function (panel, value)
        return panel.Input[set](panel.Input, value)
    end

    local get = "Get" .. name
    PANEL[get] = function (panel, value)
        return panel.Input[get](panel.Input)
    end
end

function PANEL:Init()
    self:SetBackground(Color(40, 40, 40, 255))
    self:SetHover(Color(40, 40, 40, 255))
    self:SetFlex(4)
    self:SetCursor("hand")

    self.Left = vgui.Create("SymPanel", self)
    self.Left:SetSize(0, 0)

    self.Center = vgui.Create("SymPanel", self)
    self.Center:SetFlexGrow(true)
    self.Center:SetFlex(5)

    self.Input = vgui.Create("DTextEntry", self.Center)
    self.Input:SetFlexGrow(true)
    self.Input:SetFlexMargin(SS(3), 0, SS(1), 0)
    
    self.Input:SetPaintBackground(false)
    self.Input:SetTextColor(color_white)
    self.Input:SetFont(tostring(sym.fonts.default))
    self.Input:SetCursorColor(color_white)
    self.Input.OnGetFocus = self.InputGetFocus
    self.Input.OnLoseFocus = self.InputLoseFocus
    self.Input.OnTextChanged = self.InputTextChanged

    self.Chevron = vgui.Create("SymLabel", self)
    self.Chevron:SetText("▼")
    self.Chevron:SetFlexMargin(0, 0, SS(4), 0)
    self.Chevron:SetColor(Color(255, 255, 255, 64))
    self.Chevron:SetFont(sym.Font(nil, 16, nil))

    self.Popover = vgui.Create("SymPopover", self)
    self.Popover:SetAlignment(2)
    self.Popover:SetOn("click")
    
    self.Picker = vgui.Create("SymPanel", self.Popover)
    self.Picker:SetFlex(4)
    self.Picker:SetSizeEx(REL(1), SSH(80))
    self.Picker:SetFlexFlow(FLEX_FLOW_X)
    self.Picker:SetFlexGap(SS(1))
    self.Picker.Paint = self.PaintPopover

    self.Picker
        :AddEx("SymPanel", { Ref = "MixerContainer", SizeEx = { REL(0.5), REL(1) }, NoClipping = true })
            :Add("DColorMixer", { Ref = "Mixer", Dock = Fill, Palette = false, NoClipping = true })
            :GetParent()
        :AddEx("SymPanel", { Ref = "Details", FlexGrow = true, Flex = 8, FlexFlow = FLEX_FLOW_Y, FlexGap = SS(1) })
            :AddEx("SymPanel", { Ref = "R", Flex = 5, FlexFlow = FLEX_FLOW_X, FlexGap = SS(3), FlexMargin = { SS(0), SS(4), SS(0), SS(0)  }, SizeEx = { REL(1, SS(-8)) } })
                :Add("SymLabel", { Text = "R", Font = sym.Font(16) })
                :Add("SymInputSlider", { Ref = "Slider", FlexGrow = true, Bounds = { 0, 255 } })
                :Add("SymInputText", { Ref = "Input", SizeEx = { SS(14), SSH(20) }, Font = sym.Font(16) })
                :GetParent()
            :AddEx("SymPanel", { Ref = "G", Flex = 5, FlexFlow = FLEX_FLOW_X, FlexGap = SS(3), SizeEx = { REL(1, SS(-8)) } })
                :Add("SymLabel", { Text = "G", Font = sym.Font(16) })
                :Add("SymInputSlider", { Ref = "Slider", FlexGrow = true, Bounds = { 0, 255 } })
                :Add("SymInputText", { Ref = "Input", SizeEx = { SS(14), SSH(20) }, Font = sym.Font(16) })
                :GetParent()
            :AddEx("SymPanel", { Ref = "B", Flex = 5, FlexFlow = FLEX_FLOW_X, FlexGap = SS(3), SizeEx = { REL(1, SS(-8)) } })
                :Add("SymLabel", { Text = "B", Font = sym.Font(16) })
                :Add("SymInputSlider", { Ref = "Slider", FlexGrow = true, Bounds = { 0, 255 } })
                :Add("SymInputText", { Ref = "Input", SizeEx = { SS(14), SSH(20) }, Font = sym.Font(16) })
                :GetParent()
            :AddEx("SymPanel", { Ref = "A", Flex = 5, FlexFlow = FLEX_FLOW_X, FlexGap = SS(3), SizeEx = { REL(1, SS(-8)) } })
                :Add("SymLabel", { Text = "A", Font = sym.Font(16) })
                :Add("SymInputSlider", { Ref = "Slider", FlexGrow = true, Bounds = { 0, 255 } })
                :Add("SymInputText", { Ref = "Input", SizeEx = { SS(14), SSH(20) }, Font = sym.Font(16) })
                :GetParent()
    -- self.Picker.Details.R.Slider etc.

    self.Picker.MixerContainer.Mixer.ValueChanged = function (mixer, value)
        self:SetValue(Color(value.r, value.g, value.b, value.a))
    end
    
    self.Picker.Details.R.Slider.ValueChanged = function (mixer, value)
        local c = self:GetValue()
        c.r = value
        self:SetValue(c)
    end
    
    self.Picker.Details.G.Slider.ValueChanged = function (mixer, value)
        local c = self:GetValue()
        c.g = value
        self:SetValue(c)
    end
    
    self.Picker.Details.B.Slider.ValueChanged = function (mixer, value)
        local c = self:GetValue()
        c.b = value
        self:SetValue(c)
    end
    
    self.Picker.Details.A.Slider.ValueChanged = function (mixer, value)
        local c = self:GetValue()
        c.a = value
        self:SetValue(c)
    end
end

function PANEL:OnMousePressed(mouse)
    if mouse == MOUSE_LEFT then
        if not self:IsOpen() then
            self:Open()
        else
            self:Close()
        end
    end
end

function PANEL:MixerValueChanged(value)
    local p = self:GetParent():GetParent()
    value = Color(value.r, value.g, value.b, value.a)
    p:SetValue(value)
end

function PANEL:InputGetFocus()
    local p = self:GetParent():GetParent()
    if p.OpenTime and CurTime() < p.OpenTime + 0.5 then
        return
    end

    p:Open()
    self:RequestFocus()
end

function PANEL:InputLoseFocus()
    local p = self:GetParent():GetParent()
    if CurTime() < p.OpenTime + 0.5 then
        return
    end

    local text = string.lower(self:GetText())

    local col = colorex.FromHex(text)
    if not col then
        p:SetValue(color_white)
    end
    
    p:Close()
end

function PANEL:InputTextChanged()
    local p = self:GetParent():GetParent()
    local text = string.lower(self:GetText())

    local col = colorex.FromHex(text)
    if col then
        p:SetValue(col)
    end

end


function PANEL:Open()
    self.Popover:SizeToChildren(false, true)

    --self.List:SetOpenParent(self:GetParent())
    self.Popover:Open()
    self.Popover:SetWide(self:GetWide())
    self.OpenTime = CurTime()

    self.Popover:SetKeyboardInputEnabled(false)
    timer.Simple(0, function ()
        self.Popover:SetKeyboardInputEnabled(true)
    end)
    self.Input:RequestFocus()
end

function PANEL:Close()
    self.Popover:Close()
    self.Last = nil
end

function PANEL:IsOpen()
    return self.Popover:IsOpen()
end

function PANEL:OnCursorEntered()
    self.Chevron:SetColor(Color(255, 255, 255, 255))
end

function PANEL:OnCursorExited()
    self.Chevron:SetColor(Color(255, 255, 255, 64))
end

function PANEL:SetValue(col)
    if self.DeferValue then
        return
    end

    self.DeferValue = true

    self.Value = col
    self.Input:SetText(col:ToHex())
    self.Picker.MixerContainer.Mixer:SetColor(col)
    self.Picker.Details.R.Slider:SetValue(col.r)
    self.Picker.Details.R.Input:SetText(col.r)
    self.Picker.Details.G.Slider:SetValue(col.g)
    self.Picker.Details.G.Input:SetText(col.g)
    self.Picker.Details.B.Slider:SetValue(col.b)
    self.Picker.Details.B.Input:SetText(col.b)
    self.Picker.Details.A.Slider:SetValue(col.a)
    self.Picker.Details.A.Input:SetText(col.a)

    self.DeferValue = false
    
    --self:Close()
    --self:KillFocus()
end

function PANEL:GetValue()
    return self.Value
end

function PANEL:PerformLayout(w, h)
    w, h = SymPanel.PerformLayout(self, w, h)
    self.Popover:SetWide(w)

    return w, h
end

function PANEL:PaintPopover(w, h)
    local ss = ScreenScale(0.75)
    local parent = self:GetParent():GetRealParent()

    local col = Color(52, 54, 61)

    draw.RoundedBox(ss, ss, ss, w-ss, h-ss, Color(0, 0, 0, 64))
    draw.RoundedBox(ss, 0, 0, w-ss, h-ss, col)
end

function PANEL:Paint(w, h)
    local ss = ScreenScale(0.75)
    local col = self:IsHovered() and self:GetHover() or self:GetBackground()

    if self:IsOpen() then
        draw.RoundedBox(ss, ss, ss, w-ss, h-ss, Color(0, 0, 0, 64))
        draw.RoundedBox(ss, 0, 0, w-ss, h, col)
    else
        draw.RoundedBox(ss, ss, ss, w-ss, h-ss, Color(0, 0, 0, 64))
        draw.RoundedBox(ss, 0, 0, w-ss, h-ss, col)
    end
end
vgui.Register("SymInputColor", PANEL, "SymPanel")