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
    self.Input.Paint = self.PaintTextEntry

    self.Chevron = vgui.Create("SymLabel", self)
    self.Chevron:SetText("▼")
    self.Chevron:SetFlexMargin(0, 0, SS(4), 0)
    self.Chevron:SetColor(Color(255, 255, 255, 64))
    self.Chevron:SetFont(sym.Font(nil, 8, nil))

    self.Popover = vgui.Create("SymPopover", self)
    self.Popover:SetAlignment(2)
    self.Popover:SetOn("click")
    
    self.List = vgui.Create("SymPanel", self.Popover)
    self.List:SetFlex(4)
    self.List:SetFlexFlow(FLEX_FLOW_Y)
    self.List:SetFlexGap(SS(1))
    self.List:SetSizeEx(REL(1))
    self.List.Paint = self.PaintPopover
    self.Items = {}

    self:SetAllowText(false)
    self:SetEnforceValues(true)
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

function PANEL:SetPlaceholderText(txt)
    self.Input:SetPlaceholderText(txt)
    self.PlaceholderText = txt
end

function PANEL:GetPlaceholderText()
    return self.PlaceholderText
end

function PANEL:SetAllowText(bool)
    if bool == true then
        self.Input.TestHover = nil
    else
        print("Setting TestHover of text entry to return false")
        self.Input.TestHover = function () return false end
    end
end

function PANEL:GetAllowText()
    return self.Input.TestHover == nil
end

function PANEL:SetEnforceValues(bool)
    self.EnforceValues = bool
end

function PANEL:GetEnforceValues()
    return self.EnforceValues
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

    if p:GetEnforceValues() then
        local text = string.lower(self:GetText())
        local clear = text ~= ""
        for k, v in pairs(p:GetItems()) do
            local label = string.lower(v[2])
            if text == label then
                clear = false
            end
        end

        if clear then
            self:SetText(self.Last or "")
        end
    end
    
    p:Close()
end

function PANEL:InputTextChanged()
    local p = self:GetParent():GetParent()
    local text = string.lower(self:GetText())
    local ph

    for k, v in pairs(p:GetItems()) do
        local cont = v[1]
        local label = string.lower(v[2])

        if string.find(label, text) then
            cont:SetDisplay(DISPLAY_VISIBLE)
            if not ph then
                ph = v[2]
            end
        else
            cont:SetDisplay(DISPLAY_NONE)
        end
    end

    if string.len(text) < 1 then
        self:SetPlaceholderText(p:GetPlaceholderText())
    else
        self:SetPlaceholderText(ph)
    end

    p.List:SizeToChildren(false, true, SS(0), SS(4))
    p.Popover:SizeToChildren(false, true)

end


function PANEL:Open()
    if self:GetAllowText() then       
        local text = self.Input:GetText()
        for k, v in pairs(self:GetItems()) do
            local cont = v[1]
            local label = string.lower(v[2])

            cont:SetDisplay(string.find(label, text) and DISPLAY_VISIBLE or DISPLAY_NONE)
        end
    else
        print("BOOP")
        for k, v in pairs(self:GetItems()) do
            local cont = v[1]
            cont:SetDisplay(DISPLAY_VISIBLE)
        end
    end
    self.List:SizeToChildren(false, true, SS(0), SS(4))
    self.Popover:SizeToChildren(false, true)

    --self.List:SetOpenParent(self:GetParent())
    self.Popover:Open()
    self.Popover:SetWide(self:GetWide())
    self.OpenTime = CurTime()
    self.Last = self.Last or self.Input:GetText()

    self.Popover:SetKeyboardInputEnabled(false)

    if self:GetAllowText() then
        self.Input:RequestFocus()
    end
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

function PANEL:AddItem(ele, label)
    local cont = vgui.Create("SymPanel", self.List)
    cont:SetSizeEx(REL(1))
    cont:SetHover(Color(255, 255, 255, 32))
    cont:SetCursor("hand")
    cont:SetFlex(4)
    cont:SetFlexMargin(0, 0, SS(1), 0)

    if isstring(ele) then
        label = ele

        local lbl = SymLabel(cont, ele)
        ele = lbl
    end

    cont.ele = ele
    
    ele:SetFlexMargin(SS(4), SS(1))

    table.insert(self.Items, { cont, label })
    ele:SetParent(cont)
    ele:SetNoHover(true)
    cont.OnMousePressed = function ()
        self:SetValue(label, ele)
    end
    cont:SizeToChildren(false, true)
    self.List:SizeToChildren(false, true, SS(0), SS(4))
    self.Popover:SizeToChildren(false, true)
    return self
end

function PANEL:SetValue(label, ele)
    self.Value = label
    self.Input:SetText(label)
    self:Close()
    self:KillFocus()
end

function PANEL:GetValue()
    return self.Value
end

function PANEL:GetItems()
    return self.Items
end

function PANEL:ClearItems()
    for k, v in pairs(self.List:GetChildren()) do
        v:Remove()
    end

    self.Items = nil
end

function PANEL:PerformLayout(w, h)
    w, h = SymPanel.PerformLayout(self, w, h)
    self.Popover:SetWide(w)

    return w, h
end

function PANEL:PaintPopover(w, h)
    local ss = ScreenScale(0.75)
    local parent = self:GetParent():GetRealParent()

    local col = parent:IsHovered() and parent:GetHover() or parent:GetBackground()

    draw.RoundedBox(ss, ss, ss, w-ss, h-ss, Color(0, 0, 0, 64))
    draw.RoundedBox(ss, 0, 0, w-ss, h-ss, col)
end

-- Slight amendment to GMod's paint in order to fix placeholders continually re-rendering.
function PANEL:PaintTextEntry(w, h)
    if ( self.m_bBackground ) then

		if ( panel:GetDisabled() ) then
			self.tex.TextBox_Disabled( 0, 0, w, h )
		elseif ( panel:HasFocus() ) then
			self.tex.TextBox_Focus( 0, 0, w, h )
		else
			self.tex.TextBox( 0, 0, w, h )
		end

	end

	-- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
	if ( self.GetPlaceholderText && self.GetPlaceholderColor && self:GetPlaceholderText() && self:GetPlaceholderText():Trim() != "" && self:GetPlaceholderColor() ) then

		local oldText = self:GetText()

		local str = self:GetPlaceholderText()
		if ( str:StartsWith( "#" ) ) then str = str:sub( 2 ) end
		str = language.GetPhrase( str )

        draw.SimpleText(str, self:GetFont(), 2, h/2, self:GetPlaceholderColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		self:DrawTextEntryText(self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor())
        --[[self:SetText( str )
		self:DrawTextEntryText( self:GetPlaceholderColor(), self:GetHighlightColor(), self:GetCursorColor() )
		self:SetText( oldText )--]]

		return
	end

	self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
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
vgui.Register("SymInputSelect", PANEL, "SymPanel")